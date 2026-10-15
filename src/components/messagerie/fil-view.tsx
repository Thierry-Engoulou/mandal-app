import { useQuery, useQueryClient } from "@tanstack/react-query";
import { useServerFn } from "@tanstack/react-start";
import { useEffect, useRef, useState } from "react";
import { Bot, CheckCircle2, LoaderCircle, PenLine, ScanLine, Send } from "lucide-react";
import { toast } from "sonner";
import { supabase } from "@/integrations/supabase/client";
import { correctionProvisoireIA, repondreIAFil } from "@/lib/messagerie.functions";
import { Button } from "@/components/ui/button";
import { MathText } from "@/components/math-text";
import { cn } from "@/lib/utils";

type FilMessage = {
  id: string;
  sender_id: string | null;
  auteur_ia: boolean;
  verification: string | null;
  contenu: string;
  created_at: string;
};

/** Fil privé élève ↔ enseignant d'une épreuve, avec relais de Mandal IA. */
export function FilView({
  conversationId,
  myId,
  role,
  autreNom,
  enseignantIndisponible,
}: {
  conversationId: string;
  myId: string;
  role: "eleve" | "enseignant";
  autreNom: string;
  enseignantIndisponible?: boolean | undefined;
}) {
  const queryClient = useQueryClient();
  const repondreIA = useServerFn(repondreIAFil);
  const corrigerIA = useServerFn(correctionProvisoireIA);
  const [draft, setDraft] = useState("");
  const [sending, setSending] = useState(false);
  const [iaPending, setIaPending] = useState<string | null>(null);
  const bottomRef = useRef<HTMLDivElement>(null);
  const key = ["fil", conversationId];

  const { data: messages = [] } = useQuery({
    queryKey: key,
    queryFn: async (): Promise<FilMessage[]> => {
      const { data, error } = await supabase
        .from("messages")
        .select("id, sender_id, auteur_ia, verification, contenu, created_at")
        .eq("conversation_id", conversationId)
        .order("created_at", { ascending: true });
      if (error) throw new Error(error.message);
      return data ?? [];
    },
  });

  useEffect(() => {
    const channel = supabase
      .channel(`fil-${conversationId}`)
      .on(
        "postgres_changes",
        {
          event: "*",
          schema: "public",
          table: "messages",
          filter: `conversation_id=eq.${conversationId}`,
        },
        () => void queryClient.invalidateQueries({ queryKey: ["fil", conversationId] }),
      )
      .subscribe();
    return () => {
      void supabase.removeChannel(channel);
    };
  }, [conversationId, queryClient]);

  useEffect(() => {
    bottomRef.current?.scrollIntoView({ behavior: "smooth" });
  }, [messages.length, iaPending]);

  const refresh = async () => {
    await Promise.all([
      queryClient.invalidateQueries({ queryKey: key }),
      queryClient.invalidateQueries({ queryKey: ["fils"] }),
    ]);
  };

  const callIa = async (label: string, run: () => Promise<unknown>) => {
    setIaPending(label);
    try {
      await run();
      await refresh();
    } catch (err) {
      toast.error(err instanceof Error ? err.message : "Mandal IA est indisponible.");
    } finally {
      setIaPending(null);
    }
  };

  const send = async () => {
    const contenu = draft.trim();
    if (!contenu || sending) return;
    setSending(true);
    const { error } = await supabase
      .from("messages")
      .insert({ conversation_id: conversationId, sender_id: myId, contenu });
    if (!error) {
      await supabase
        .from("conversations")
        .update({ updated_at: new Date().toISOString() })
        .eq("id", conversationId);
    }
    setSending(false);
    if (error) {
      toast.error(error.message);
      return;
    }
    setDraft("");
    await refresh();
    // Élève : si l'enseignant s'est déclaré indisponible, Mandal IA répond tout de suite.
    if (role === "eleve") {
      await callIa("Mandal IA répond à la place de ton enseignant…", () =>
        repondreIA({ data: { conversationId, auto: true } }),
      );
    }
  };

  const verifier = async (messageId: string, verification: "valide" | "corrige" | null) => {
    const { error } = await supabase.rpc("verifier_message_ia", {
      p_message_id: messageId,
      p_verification: verification,
    });
    if (error) toast.error(error.message);
    await refresh();
  };

  return (
    <div className="rounded-2xl bg-card p-4 shadow-sm">
      {role === "eleve" && enseignantIndisponible ? (
        <p className="mb-3 rounded-xl bg-amber-500/10 p-3 text-sm text-foreground">
          Ton enseignant est indisponible pour le moment : Mandal IA répond à sa place. Il verra
          l'échange et pourra confirmer ou corriger.
        </p>
      ) : null}

      <div className="max-h-[60vh] min-h-[200px] space-y-3 overflow-y-auto pr-1">
        {messages.length === 0 ? (
          <p className="py-8 text-center text-sm text-muted-foreground">
            {role === "eleve"
              ? "Pose ta question sur le sujet ou signale une erreur : ton enseignant (ou Mandal IA s'il est indisponible) te répondra ici."
              : "Aucun message pour l'instant."}
          </p>
        ) : (
          messages.map((m) => {
            const mine = !m.auteur_ia && m.sender_id === myId;
            return (
              <div key={m.id} className={cn("flex", mine ? "justify-end" : "justify-start")}>
                <div
                  className={cn(
                    "max-w-[88%] rounded-2xl px-4 py-2.5",
                    mine
                      ? "bg-primary text-primary-foreground"
                      : m.auteur_ia
                        ? "border border-primary/30 bg-primary/5"
                        : "bg-secondary",
                  )}
                >
                  <p className="mb-1 flex flex-wrap items-center gap-1.5 text-xs font-semibold opacity-80">
                    {m.auteur_ia ? <Bot className="size-3.5" /> : null}
                    {m.auteur_ia ? "Mandal IA" : mine ? "Moi" : autreNom}
                    <span className="font-normal">
                      ·{" "}
                      {new Date(m.created_at).toLocaleString("fr-FR", {
                        dateStyle: "short",
                        timeStyle: "short",
                      })}
                    </span>
                    {m.verification === "valide" ? (
                      <span className="rounded-full bg-emerald-500/15 px-2 text-emerald-700 dark:text-emerald-400">
                        Validé par l'enseignant
                      </span>
                    ) : m.verification === "corrige" ? (
                      <span className="rounded-full bg-amber-500/15 px-2 text-amber-700 dark:text-amber-400">
                        Corrigé par l'enseignant (voir sa réponse)
                      </span>
                    ) : m.auteur_ia ? (
                      <span className="rounded-full bg-secondary px-2 font-normal">
                        À vérifier par l'enseignant
                      </span>
                    ) : null}
                  </p>
                  {m.auteur_ia ? (
                    <MathText text={m.contenu} className="text-sm leading-relaxed" />
                  ) : (
                    <p className="whitespace-pre-wrap text-sm">{m.contenu}</p>
                  )}
                  {role === "enseignant" && m.auteur_ia ? (
                    <div className="mt-2 flex flex-wrap gap-2">
                      <Button
                        size="sm"
                        variant={m.verification === "valide" ? "default" : "outline"}
                        className="h-7 rounded-lg text-xs"
                        onClick={() =>
                          verifier(m.id, m.verification === "valide" ? null : "valide")
                        }
                      >
                        <CheckCircle2 className="size-3.5" /> Valider
                      </Button>
                      <Button
                        size="sm"
                        variant={m.verification === "corrige" ? "default" : "outline"}
                        className="h-7 rounded-lg text-xs"
                        onClick={() =>
                          verifier(m.id, m.verification === "corrige" ? null : "corrige")
                        }
                      >
                        <PenLine className="size-3.5" /> À corriger (je réponds)
                      </Button>
                    </div>
                  ) : null}
                </div>
              </div>
            );
          })
        )}
        {iaPending ? (
          <p className="animate-pulse text-sm text-muted-foreground">{iaPending}</p>
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
              void send();
            }
          }}
          rows={2}
          maxLength={4000}
          placeholder={
            role === "eleve"
              ? "Ta question sur le sujet, ou l'erreur que tu as repérée…"
              : "Ta réponse à l'élève…"
          }
          className="w-full resize-none rounded-xl border border-border bg-background p-3 text-sm"
        />
        <div className="flex flex-wrap gap-2">
          <Button
            onClick={send}
            disabled={sending || !!iaPending || !draft.trim()}
            className="rounded-xl"
          >
            {sending ? <LoaderCircle className="animate-spin" /> : <Send className="size-4" />}
            Envoyer
          </Button>
          {role === "eleve" ? (
            <>
              <Button
                variant="secondary"
                className="rounded-xl"
                disabled={!!iaPending || messages.length === 0}
                onClick={() =>
                  callIa("Mandal IA réfléchit…", () =>
                    repondreIA({ data: { conversationId, auto: false } }),
                  )
                }
              >
                <Bot className="size-4" /> Demander à Mandal IA sans attendre
              </Button>
              <Button
                variant="outline"
                className="rounded-xl"
                disabled={!!iaPending}
                onClick={() =>
                  callIa("Mandal IA corrige ta copie… (jusqu'à une minute)", () =>
                    corrigerIA({ data: { conversationId } }),
                  )
                }
              >
                <ScanLine className="size-4" /> Correction provisoire de ma copie
              </Button>
            </>
          ) : null}
        </div>
      </div>
    </div>
  );
}
