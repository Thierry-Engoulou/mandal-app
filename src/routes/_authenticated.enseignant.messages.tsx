import { createFileRoute } from "@tanstack/react-router";
import { useQuery, useQueryClient } from "@tanstack/react-query";
import { useEffect, useState } from "react";
import { z } from "zod";
import { Bot, ClipboardCheck, Users } from "lucide-react";
import { toast } from "sonner";
import { supabase } from "@/integrations/supabase/client";
import { useProfile } from "@/lib/use-profile";
import { MATIERES, NIVEAUX } from "@/lib/epreuves";
import { SalonPicker, SalonView } from "@/components/messagerie/salon-view";
import { FilView } from "@/components/messagerie/fil-view";
import { TabButton } from "@/components/messagerie/tab-button";
import { cn } from "@/lib/utils";

const searchSchema = z.object({ onglet: z.enum(["epreuves", "salons"]).optional() });

export const Route = createFileRoute("/_authenticated/enseignant/messages")({
  validateSearch: (search) => searchSchema.parse(search),
  component: TeacherMessagesPage,
  head: () => ({
    meta: [
      { title: "Messages — M'Andal" },
      { name: "description", content: "Questions des élèves et salons de matière sur M'Andal." },
      { name: "robots", content: "noindex" },
    ],
  }),
});

function TeacherMessagesPage() {
  const { data: profile } = useProfile();
  const search = Route.useSearch();
  const navigate = Route.useNavigate();
  const onglet = search.onglet ?? "epreuves";
  const [salon, setSalon] = useState<{ matiere: string; niveau: string } | null>(null);

  // Salon par défaut : matière / niveau de la dernière épreuve de l'enseignant.
  const { data: derniere } = useQuery({
    enabled: !!profile,
    queryKey: ["derniere-epreuve", profile?.id],
    queryFn: async () => {
      const { data } = await supabase
        .from("epreuves")
        .select("matiere, niveau")
        .eq("enseignant_id", profile!.id)
        .order("created_at", { ascending: false })
        .limit(1)
        .maybeSingle();
      return data;
    },
  });
  const matiere = salon?.matiere ?? derniere?.matiere ?? MATIERES[0]!;
  const niveau = salon?.niveau ?? derniere?.niveau ?? NIVEAUX[5];

  return (
    <div className="space-y-6">
      <header className="flex flex-wrap items-start justify-between gap-4">
        <div>
          <h1 className="font-display text-2xl font-bold tracking-tight text-foreground">
            Messages
          </h1>
          <p className="text-sm text-muted-foreground">
            Questions de vos élèves sur vos épreuves et salons de matière.
          </p>
        </div>
        {profile ? <Disponibilite myId={profile.id} /> : null}
      </header>

      <div className="flex gap-2">
        <TabButton
          active={onglet === "epreuves"}
          onClick={() => navigate({ search: { onglet: "epreuves" } })}
          icon={<ClipboardCheck className="size-4" />}
          label="Questions sur mes épreuves"
        />
        <TabButton
          active={onglet === "salons"}
          onClick={() => navigate({ search: { onglet: "salons" } })}
          icon={<Users className="size-4" />}
          label="Salons de matière"
        />
      </div>

      {!profile ? null : onglet === "salons" ? (
        <div className="space-y-3">
          <SalonPicker
            matiere={matiere}
            niveau={niveau}
            onChange={(m, n) => setSalon({ matiere: m, niveau: n })}
          />
          <p className="text-xs text-muted-foreground">
            En tant qu'enseignant, vos messages sont mis en avant et vous pouvez supprimer les
            messages inappropriés.
          </p>
          <SalonView matiere={matiere} niveau={niveau} myId={profile.id} isTeacher />
        </div>
      ) : (
        <FilsEnseignant myId={profile.id} />
      )}
    </div>
  );
}

/** Interrupteur « disponible / indisponible » : indisponible, Mandal IA répond aux élèves. */
function Disponibilite({ myId }: { myId: string }) {
  const queryClient = useQueryClient();
  const { data: disponible = true } = useQuery({
    queryKey: ["ma-disponibilite", myId],
    queryFn: async () => {
      const { data } = await supabase
        .from("enseignant_disponibilite")
        .select("disponible")
        .eq("enseignant_id", myId)
        .maybeSingle();
      return data?.disponible ?? true;
    },
  });

  const toggle = async () => {
    const { error } = await supabase.from("enseignant_disponibilite").upsert({
      enseignant_id: myId,
      disponible: !disponible,
      updated_at: new Date().toISOString(),
    });
    if (error) {
      toast.error(error.message);
      return;
    }
    toast.success(
      disponible
        ? "Vous êtes indisponible : Mandal IA répondra à vos élèves en attendant."
        : "Vous êtes de nouveau disponible.",
    );
    await queryClient.invalidateQueries({ queryKey: ["ma-disponibilite", myId] });
  };

  return (
    <button
      type="button"
      onClick={toggle}
      className={cn(
        "flex items-center gap-2 rounded-xl border px-4 py-2 text-sm font-semibold transition",
        disponible
          ? "border-emerald-500/40 bg-emerald-500/10 text-emerald-700 dark:text-emerald-400"
          : "border-amber-500/40 bg-amber-500/10 text-amber-700 dark:text-amber-400",
      )}
    >
      <span
        className={cn("size-2.5 rounded-full", disponible ? "bg-emerald-500" : "bg-amber-500")}
      />
      {disponible ? "Disponible" : "Indisponible — Mandal IA répond"}
      {!disponible ? <Bot className="size-4" /> : null}
    </button>
  );
}

function FilsEnseignant({ myId }: { myId: string }) {
  const queryClient = useQueryClient();
  const [activeId, setActiveId] = useState<string | null>(null);

  const { data: fils = [] } = useQuery({
    queryKey: ["fils", "enseignant", myId],
    queryFn: async () => {
      const { data, error } = await supabase
        .from("conversations")
        .select(
          "id, sujet, eleve_nom, updated_at, messages(sender_id, auteur_ia, verification, created_at)",
        )
        .eq("enseignant_id", myId)
        .not("epreuve_id", "is", null)
        .order("updated_at", { ascending: false });
      if (error) throw new Error(error.message);
      return (data ?? []).map((c) => {
        const msgs = [...(c.messages ?? [])].sort((a, b) =>
          a.created_at.localeCompare(b.created_at),
        );
        const last = msgs[msgs.length - 1];
        return {
          id: c.id,
          sujet: c.sujet,
          eleveNom: c.eleve_nom ?? "Élève",
          updatedAt: c.updated_at,
          // À traiter : dernier message de l'élève, ou réponse de l'IA pas encore vérifiée.
          aTraiter:
            !!last &&
            (last.auteur_ia
              ? !msgs.some((m) => m.auteur_ia && m.verification)
              : last.sender_id !== myId),
        };
      });
    },
  });

  useEffect(() => {
    const channel = supabase
      .channel(`fils-enseignant-${myId}`)
      .on("postgres_changes", { event: "INSERT", schema: "public", table: "messages" }, () => {
        void queryClient.invalidateQueries({ queryKey: ["fils", "enseignant", myId] });
      })
      .subscribe();
    return () => {
      void supabase.removeChannel(channel);
    };
  }, [myId, queryClient]);

  const active = fils.find((f) => f.id === activeId);

  return (
    <div className="grid gap-4 lg:grid-cols-[320px_1fr]">
      <aside className="space-y-2 rounded-2xl bg-card p-3 shadow-sm">
        {fils.length === 0 ? (
          <p className="p-3 text-sm text-muted-foreground">
            Aucune question d'élève sur vos épreuves pour l'instant.
          </p>
        ) : (
          fils.map((f) => (
            <button
              key={f.id}
              type="button"
              onClick={() => setActiveId(f.id)}
              className={cn(
                "w-full rounded-xl px-3 py-2 text-left transition",
                f.id === activeId ? "bg-primary/10" : "hover:bg-secondary",
              )}
            >
              <span className="flex items-center justify-between gap-2">
                <span className="truncate text-sm font-semibold text-foreground">{f.eleveNom}</span>
                {f.aTraiter ? <span className="size-2 shrink-0 rounded-full bg-primary" /> : null}
              </span>
              <span className="block truncate text-xs text-muted-foreground">{f.sujet}</span>
            </button>
          ))
        )}
      </aside>
      <section>
        {active ? (
          <div className="space-y-2">
            <p className="text-sm font-semibold text-foreground">
              {active.eleveNom} — {active.sujet}
            </p>
            <FilView
              key={active.id}
              conversationId={active.id}
              myId={myId}
              role="enseignant"
              autreNom={active.eleveNom}
            />
          </div>
        ) : (
          <div className="rounded-2xl bg-card p-10 text-center text-sm text-muted-foreground shadow-sm">
            Choisissez un élève pour lire ses questions. Les réponses de Mandal IA (quand vous êtes
            indisponible) apparaissent avec « À vérifier » : validez-les ou corrigez-les.
          </div>
        )}
      </section>
    </div>
  );
}
