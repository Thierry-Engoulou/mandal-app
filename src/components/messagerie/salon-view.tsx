import { useQuery, useQueryClient } from "@tanstack/react-query";
import { useServerFn } from "@tanstack/react-start";
import { useEffect, useRef, useState } from "react";
import { Bot, GraduationCap, LoaderCircle, Send, Trash2 } from "lucide-react";
import { toast } from "sonner";
import { supabase } from "@/integrations/supabase/client";
import { demanderIASalon } from "@/lib/messagerie.functions";
import { MATIERES, NIVEAUX } from "@/lib/epreuves";
import { Button } from "@/components/ui/button";
import { MathText } from "@/components/math-text";
import { cn } from "@/lib/utils";

const selectClass = "rounded-xl border border-border bg-background px-3 py-2 text-sm";

/** Choix du salon (matière + niveau). */
export function SalonPicker({
  matiere,
  niveau,
  onChange,
}: {
  matiere: string;
  niveau: string;
  onChange: (matiere: string, niveau: string) => void;
}) {
  return (
    <div className="flex flex-wrap items-center gap-2">
      <select
        aria-label="Matière"
        value={matiere}
        onChange={(e) => onChange(e.target.value, niveau)}
        className={selectClass}
      >
        {MATIERES.filter((m) => m !== "Autre").map((m) => (
          <option key={m}>{m}</option>
        ))}
      </select>
      <select
        aria-label="Niveau"
        value={niveau}
        onChange={(e) => onChange(matiere, e.target.value)}
        className={selectClass}
      >
        {NIVEAUX.map((n) => (
          <option key={n}>{n}</option>
        ))}
      </select>
    </div>
  );
}

type SalonMessage = {
  id: string;
  auteur_id: string | null;
  auteur_nom: string;
  auteur_role: string;
  contenu: string;
  created_at: string;
};

/** Salon de discussion d'une matière et d'un niveau (élèves + enseignants + Mandal IA). */
export function SalonView({
  matiere,
  niveau,
  myId,
  isTeacher,
}: {
  matiere: string;
  niveau: string;
  myId: string;
  isTeacher: boolean;
}) {
  const queryClient = useQueryClient();
  const demanderIA = useServerFn(demanderIASalon);
  const [draft, setDraft] = useState("");
  const [sending, setSending] = useState(false);
  const [iaPending, setIaPending] = useState(false);
  const bottomRef = useRef<HTMLDivElement>(null);
  const key = ["salon", matiere, niveau];

  const { data: messages = [], isLoading } = useQuery({
    queryKey: key,
    queryFn: async (): Promise<SalonMessage[]> => {
      const { data, error } = await supabase
        .from("salon_messages")
        .select("id, auteur_id, auteur_nom, auteur_role, contenu, created_at")
        .eq("matiere", matiere)
        .eq("niveau", niveau)
        .order("created_at", { ascending: false })
        .limit(100);
      if (error) throw new Error(error.message);
      return (data ?? []).reverse();
    },
  });

  // Temps réel : nouveaux messages et suppressions dans ce salon.
  useEffect(() => {
    const channel = supabase
      .channel(`salon-${matiere}-${niveau}`)
      .on(
        "postgres_changes",
        // Pas de filtre côté serveur : les noms de matière contiennent des espaces et
        // des parenthèses ; le volume reste faible.
        { event: "*", schema: "public", table: "salon_messages" },
        () => void queryClient.invalidateQueries({ queryKey: ["salon", matiere, niveau] }),
      )
      .subscribe();
    return () => {
      void supabase.removeChannel(channel);
    };
  }, [matiere, niveau, queryClient]);

  useEffect(() => {
    bottomRef.current?.scrollIntoView({ behavior: "smooth" });
  }, [messages.length, iaPending]);

  const send = async (askIa: boolean) => {
    const contenu = draft.trim();
    if (sending || iaPending) return;
    if (contenu) {
      setSending(true);
      const { error } = await supabase.from("salon_messages").insert({
        matiere,
        niveau,
        contenu,
        // Auteur, nom et rôle sont fixés par la base.
        auteur_nom: "",
        auteur_role: "eleve",
      });
      setSending(false);
      if (error) {
        toast.error(error.message);
        return;
      }
      setDraft("");
      await queryClient.invalidateQueries({ queryKey: key });
    } else if (!askIa) {
      return;
    }
    if (askIa) {
      setIaPending(true);
      try {
        await demanderIA({ data: { matiere, niveau } });
        await queryClient.invalidateQueries({ queryKey: key });
      } catch (err) {
        toast.error(err instanceof Error ? err.message : "Mandal IA est indisponible.");
      } finally {
        setIaPending(false);
      }
    }
  };

  const remove = async (id: string) => {
    if (!confirm("Supprimer ce message ?")) return;
    const { error } = await supabase.from("salon_messages").delete().eq("id", id);
    if (error) toast.error(error.message);
    await queryClient.invalidateQueries({ queryKey: key });
  };

  return (
    <div className="rounded-2xl bg-card p-4 shadow-sm">
      <div className="max-h-[60vh] min-h-[200px] space-y-3 overflow-y-auto pr-1">
        {isLoading ? (
          <p className="text-sm text-muted-foreground">Chargement…</p>
        ) : messages.length === 0 ? (
          <p className="py-8 text-center text-sm text-muted-foreground">
            Aucun message dans ce salon. Lance la discussion !
          </p>
        ) : (
          messages.map((m) => {
            const mine = m.auteur_id === myId;
            const ia = m.auteur_role === "ia";
            const prof = m.auteur_role === "enseignant";
            return (
              <div key={m.id} className={cn("group flex", mine ? "justify-end" : "justify-start")}>
                <div
                  className={cn(
                    "max-w-[85%] rounded-2xl px-4 py-2.5",
                    mine
                      ? "bg-primary text-primary-foreground"
                      : ia
                        ? "border border-primary/30 bg-primary/5"
                        : prof
                          ? "border border-amber-500/40 bg-amber-500/10"
                          : "bg-secondary",
                  )}
                >
                  <p className="mb-1 flex items-center gap-1.5 text-xs font-semibold opacity-80">
                    {ia ? (
                      <Bot className="size-3.5" />
                    ) : prof ? (
                      <GraduationCap className="size-3.5" />
                    ) : null}
                    {mine ? "Moi" : m.auteur_nom}
                    {prof && !mine ? " · Enseignant" : ""}
                    <span className="font-normal">
                      ·{" "}
                      {new Date(m.created_at).toLocaleString("fr-FR", {
                        dateStyle: "short",
                        timeStyle: "short",
                      })}
                    </span>
                    {mine || isTeacher ? (
                      <button
                        type="button"
                        onClick={() => remove(m.id)}
                        aria-label="Supprimer le message"
                        className="ml-1 opacity-0 transition group-hover:opacity-100"
                      >
                        <Trash2 className="size-3.5" />
                      </button>
                    ) : null}
                  </p>
                  {ia ? (
                    <MathText text={m.contenu} className="text-sm leading-relaxed" />
                  ) : (
                    <p className="whitespace-pre-wrap text-sm">{m.contenu}</p>
                  )}
                </div>
              </div>
            );
          })
        )}
        {iaPending ? (
          <p className="animate-pulse text-sm text-muted-foreground">Mandal IA réfléchit…</p>
        ) : null}
        <div ref={bottomRef} />
      </div>

      <div className="mt-3 space-y-2">
        <textarea
          value={draft}
          onChange={(e) => setDraft(e.target.value)}
          onKeyDown={(e) => {
            if (e.key === "Enter" && !e.shiftKey) {
              e.preventDefault();
              void send(false);
            }
          }}
          rows={2}
          maxLength={4000}
          placeholder={`Écris dans le salon ${matiere} — ${niveau}…`}
          className="w-full resize-none rounded-xl border border-border bg-background p-3 text-sm"
        />
        <div className="flex flex-wrap gap-2">
          <Button
            onClick={() => send(false)}
            disabled={sending || iaPending || !draft.trim()}
            className="rounded-xl"
          >
            {sending ? <LoaderCircle className="animate-spin" /> : <Send className="size-4" />}{" "}
            Envoyer
          </Button>
          <Button
            variant="secondary"
            onClick={() => send(true)}
            disabled={sending || iaPending || messages.length + (draft.trim() ? 1 : 0) === 0}
            className="rounded-xl"
          >
            {iaPending ? <LoaderCircle className="animate-spin" /> : <Bot className="size-4" />}
            {draft.trim() ? "Envoyer et demander à Mandal IA" : "Demander à Mandal IA"}
          </Button>
        </div>
      </div>
    </div>
  );
}
