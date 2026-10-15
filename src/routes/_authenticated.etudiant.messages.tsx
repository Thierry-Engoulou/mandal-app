import { createFileRoute } from "@tanstack/react-router";
import { useQuery } from "@tanstack/react-query";
import { useEffect, useState } from "react";
import { z } from "zod";
import { ClipboardCheck, LoaderCircle, MessagesSquare, Users } from "lucide-react";
import { toast } from "sonner";
import { supabase } from "@/integrations/supabase/client";
import { useProfile } from "@/lib/use-profile";
import { MATIERES, NIVEAUX } from "@/lib/epreuves";
import { SalonPicker, SalonView } from "@/components/messagerie/salon-view";
import { FilView } from "@/components/messagerie/fil-view";
import { TabButton } from "@/components/messagerie/tab-button";
import { cn } from "@/lib/utils";

const searchSchema = z.object({
  onglet: z.enum(["salons", "epreuves"]).optional(),
  epreuve: z.string().uuid().optional(),
});

export const Route = createFileRoute("/_authenticated/etudiant/messages")({
  validateSearch: (search) => searchSchema.parse(search),
  component: StudentMessagesPage,
  head: () => ({
    meta: [
      { title: "Messages — MANDAL" },
      {
        name: "description",
        content: "Salons de matière et échanges avec tes enseignants sur MANDAL.",
      },
      { name: "robots", content: "noindex" },
    ],
  }),
});

function StudentMessagesPage() {
  const { data: profile } = useProfile();
  const search = Route.useSearch();
  const navigate = Route.useNavigate();
  const onglet = search.onglet ?? (search.epreuve ? "epreuves" : "salons");
  const [matiere, setMatiere] = useState(MATIERES[0]!);
  const [niveau, setNiveau] = useState<string>(NIVEAUX[5]);

  return (
    <div className="space-y-6">
      <header className="gradient-welcome rounded-2xl p-6 text-primary-foreground shadow-sm">
        <MessagesSquare className="mb-2 size-6" />
        <h1 className="font-display text-2xl font-bold tracking-tight">Messages</h1>
        <p className="mt-1 max-w-2xl text-sm opacity-90">
          Échange avec les élèves et les enseignants de ta matière, ou pose une question privée à
          l'enseignant qui a donné une épreuve. Quand il est indisponible, Mandal IA te répond.
        </p>
      </header>

      <div className="flex gap-2">
        <TabButton
          active={onglet === "salons"}
          onClick={() => navigate({ search: { onglet: "salons" } })}
          icon={<Users className="size-4" />}
          label="Salons de matière"
        />
        <TabButton
          active={onglet === "epreuves"}
          onClick={() => navigate({ search: { onglet: "epreuves" } })}
          icon={<ClipboardCheck className="size-4" />}
          label="Mes épreuves"
        />
      </div>

      {!profile ? null : onglet === "salons" ? (
        <div className="space-y-3">
          <SalonPicker
            matiere={matiere}
            niveau={niveau}
            onChange={(m, n) => {
              setMatiere(m);
              setNiveau(n);
            }}
          />
          <SalonView matiere={matiere} niveau={niveau} myId={profile.id} isTeacher={false} />
        </div>
      ) : (
        <EpreuvesFils myId={profile.id} initialEpreuveId={search.epreuve ?? null} />
      )}
    </div>
  );
}

function EpreuvesFils({
  myId,
  initialEpreuveId,
}: {
  myId: string;
  initialEpreuveId: string | null;
}) {
  const [epreuveId, setEpreuveId] = useState<string | null>(initialEpreuveId);
  const [conversationId, setConversationId] = useState<string | null>(null);
  const [opening, setOpening] = useState(false);

  const { data } = useQuery({
    queryKey: ["fils", "eleve", myId],
    queryFn: async () => {
      const [epreuves, fils] = await Promise.all([
        supabase
          .from("epreuves")
          .select("id, titre, matiere, niveau, enseignant_id")
          .eq("statut", "publiee")
          .order("created_at", { ascending: false }),
        supabase
          .from("conversations")
          .select("id, epreuve_id, updated_at")
          .eq("eleve_id", myId)
          .not("epreuve_id", "is", null),
      ]);
      if (epreuves.error) throw new Error(epreuves.error.message);
      const enseignants = [...new Set((epreuves.data ?? []).map((e) => e.enseignant_id))];
      const { data: dispos } = enseignants.length
        ? await supabase
            .from("enseignant_disponibilite")
            .select("enseignant_id, disponible")
            .in("enseignant_id", enseignants)
        : { data: [] };
      return {
        epreuves: epreuves.data ?? [],
        fils: new Map((fils.data ?? []).map((f) => [f.epreuve_id, f])),
        indisponibles: new Set(
          (dispos ?? []).filter((d) => !d.disponible).map((d) => d.enseignant_id),
        ),
      };
    },
  });

  // Ouvre (ou crée) le fil de l'épreuve choisie.
  useEffect(() => {
    if (!epreuveId) return;
    let cancelled = false;
    setOpening(true);
    void supabase
      .rpc("ouvrir_fil_epreuve", { p_epreuve_id: epreuveId })
      .then(({ data: id, error }) => {
        if (cancelled) return;
        setOpening(false);
        if (error) {
          toast.error(error.message);
          setEpreuveId(null);
          return;
        }
        setConversationId(id);
      });
    return () => {
      cancelled = true;
    };
  }, [epreuveId]);

  const epreuves = data?.epreuves ?? [];
  const active = epreuves.find((e) => e.id === epreuveId);

  return (
    <div className="grid gap-4 lg:grid-cols-[300px_1fr]">
      <aside className="space-y-2 rounded-2xl bg-card p-3 shadow-sm">
        {epreuves.length === 0 ? (
          <p className="p-3 text-sm text-muted-foreground">Aucune épreuve disponible.</p>
        ) : (
          epreuves.map((e) => (
            <button
              key={e.id}
              type="button"
              onClick={() => {
                setConversationId(null);
                setEpreuveId(e.id);
              }}
              className={cn(
                "w-full rounded-xl px-3 py-2 text-left transition",
                e.id === epreuveId ? "bg-primary/10" : "hover:bg-secondary",
              )}
            >
              <span className="block truncate text-sm font-semibold text-foreground">
                {e.titre}
              </span>
              <span className="block truncate text-xs text-muted-foreground">
                {e.matiere} · {e.niveau}
                {data?.fils.has(e.id) ? " · échange en cours" : ""}
              </span>
            </button>
          ))
        )}
      </aside>

      <section>
        {!epreuveId ? (
          <div className="rounded-2xl bg-card p-10 text-center text-sm text-muted-foreground shadow-sm">
            Choisis une épreuve pour poser une question à son enseignant ou signaler une erreur dans
            le sujet.
          </div>
        ) : opening || !conversationId ? (
          <div className="flex items-center justify-center gap-2 rounded-2xl bg-card p-10 text-sm text-muted-foreground shadow-sm">
            <LoaderCircle className="size-4 animate-spin" /> Ouverture de l'échange…
          </div>
        ) : (
          <div className="space-y-2">
            {active ? (
              <p className="text-sm font-semibold text-foreground">
                {active.titre} — {active.matiere}, {active.niveau}
              </p>
            ) : null}
            <FilView
              key={conversationId}
              conversationId={conversationId}
              myId={myId}
              role="eleve"
              autreNom="Ton enseignant"
              enseignantIndisponible={
                active ? data?.indisponibles.has(active.enseignant_id) : false
              }
            />
          </div>
        )}
      </section>
    </div>
  );
}
