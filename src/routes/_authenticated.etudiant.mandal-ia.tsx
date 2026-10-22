import { createFileRoute } from "@tanstack/react-router";
import { avecGardeMajorite } from "@/components/garde-majorite";
import { useQuery, useQueryClient } from "@tanstack/react-query";
import { useServerFn } from "@tanstack/react-start";
import { useEffect, useRef, useState } from "react";
import { Bot, Send, LoaderCircle, Trash2 } from "lucide-react";
import { toast } from "sonner";
import { supabase } from "@/integrations/supabase/client";
import { useProfile } from "@/lib/use-profile";
import { askMandalIA } from "@/lib/mandal-ia.functions";
import { Button } from "@/components/ui/button";
import { MathText } from "@/components/math-text";

export const Route = createFileRoute("/_authenticated/etudiant/mandal-ia")({
  component: avecGardeMajorite(MandalIAPage),
  head: () => ({
    meta: [
      { title: "Mandal IA — votre répétiteur numérique" },
      {
        name: "description",
        content: "Posez vos questions de cours, d'exercices et d'orientation à Mandal IA.",
      },
      { name: "robots", content: "noindex" },
    ],
  }),
});

const SUGGESTIONS = [
  "Explique-moi la dérivée d'une fonction avec un exemple",
  "Donne-moi un exercice sur le théorème de Thalès",
  "Comment bien réviser pour le Probatoire ?",
  "Quelles études après un Bac C ?",
];

function MandalIAPage() {
  const { data: profile } = useProfile();
  const queryClient = useQueryClient();
  const ask = useServerFn(askMandalIA);
  const [input, setInput] = useState("");
  const [pending, setPending] = useState<string | null>(null);
  const inputRef = useRef<HTMLTextAreaElement>(null);
  const bottomRef = useRef<HTMLDivElement>(null);

  const { data: messages = [] } = useQuery({
    enabled: !!profile,
    queryKey: ["ia-messages", profile?.id],
    queryFn: async () => {
      const { data, error } = await supabase
        .from("ia_messages")
        .select("id, role, contenu, created_at")
        .eq("eleve_id", profile!.id)
        .order("created_at", { ascending: true })
        .limit(200);
      if (error) throw new Error(error.message);
      return data ?? [];
    },
  });

  useEffect(() => {
    bottomRef.current?.scrollIntoView({ behavior: "smooth" });
  }, [messages.length, pending]);

  useEffect(() => {
    if (!pending) inputRef.current?.focus();
  }, [pending]);

  const send = async (text: string) => {
    const value = text.trim();
    if (!value || pending) return;
    setInput("");
    setPending(value);
    try {
      await ask({ data: { message: value } });
      await queryClient.invalidateQueries({ queryKey: ["ia-messages"] });
    } catch (error) {
      setInput(value);
      toast.error(error instanceof Error ? error.message : "Mandal IA est indisponible.");
    } finally {
      setPending(null);
    }
  };

  const clearHistory = async () => {
    if (!profile || !confirm("Effacer toute la conversation avec Mandal IA ?")) return;
    const { error } = await supabase.from("ia_messages").delete().eq("eleve_id", profile.id);
    if (error) toast.error(error.message);
    await queryClient.invalidateQueries({ queryKey: ["ia-messages"] });
  };

  return (
    <div className="space-y-6">
      <header className="gradient-progress flex items-start justify-between gap-4 rounded-2xl p-6 text-primary-foreground shadow-sm">
        <div>
          <Bot className="mb-2 size-6" />
          <h1 className="font-display text-2xl font-bold tracking-tight">Mandal IA</h1>
          <p className="mt-1 max-w-2xl text-sm opacity-90">
            Ton répétiteur numérique : pose tes questions sur tes cours, tes exercices, tes examens
            ou ton orientation. Mandal IA tient compte des cours que tu suis.
          </p>
        </div>
        {messages.length > 0 ? (
          <Button
            variant="secondary"
            size="sm"
            onClick={clearHistory}
            disabled={!!pending}
            className="shrink-0 rounded-xl"
          >
            <Trash2 className="size-4" /> Effacer
          </Button>
        ) : null}
      </header>

      <div className="rounded-2xl bg-card p-5 shadow-sm">
        <div className="max-h-[60vh] space-y-4 overflow-y-auto pr-1">
          {messages.length === 0 && !pending ? (
            <div className="py-8 text-center">
              <p className="text-sm text-muted-foreground">Commence par exemple par :</p>
              <div className="mt-4 flex flex-wrap justify-center gap-2">
                {SUGGESTIONS.map((s) => (
                  <button
                    key={s}
                    onClick={() => send(s)}
                    className="rounded-full border border-border px-3 py-1.5 text-sm text-foreground hover:border-primary"
                  >
                    {s}
                  </button>
                ))}
              </div>
            </div>
          ) : null}

          {messages.map((m) =>
            m.role === "user" ? (
              <UserBubble key={m.id} text={m.contenu} />
            ) : (
              <div key={m.id} className="flex gap-3">
                <span className="mt-0.5 flex size-7 shrink-0 items-center justify-center rounded-full bg-primary/10 text-primary">
                  <Bot className="size-4" />
                </span>
                <MathText
                  text={m.contenu}
                  className="min-w-0 max-w-[90%] text-sm leading-relaxed text-foreground"
                />
              </div>
            ),
          )}

          {pending ? (
            <>
              <UserBubble text={pending} />
              <p className="animate-pulse text-sm text-muted-foreground">Mandal IA réfléchit…</p>
            </>
          ) : null}
          <div ref={bottomRef} />
        </div>

        <form
          className="mt-4 flex items-end gap-2"
          onSubmit={(e) => {
            e.preventDefault();
            void send(input);
          }}
        >
          <textarea
            ref={inputRef}
            value={input}
            onChange={(e) => setInput(e.target.value)}
            onKeyDown={(e) => {
              if (e.key === "Enter" && !e.shiftKey) {
                e.preventDefault();
                void send(input);
              }
            }}
            rows={2}
            maxLength={4000}
            placeholder="Écris ta question…"
            className="flex-1 resize-none rounded-xl border border-border bg-background p-3 text-sm"
          />
          <Button type="submit" size="icon" className="size-10 rounded-xl" disabled={!!pending}>
            {pending ? <LoaderCircle className="animate-spin" /> : <Send className="size-4" />}
          </Button>
        </form>
        <p className="mt-2 text-xs text-muted-foreground">
          Mandal IA est une intelligence artificielle : elle peut se tromper. Vérifie les points
          importants avec ton enseignant, et n'écris pas d'informations personnelles (nom complet,
          téléphone, adresse).
        </p>
      </div>
    </div>
  );
}

function UserBubble({ text }: { text: string }) {
  return (
    <div className="flex justify-end">
      <p className="max-w-[80%] whitespace-pre-wrap rounded-2xl bg-primary px-4 py-2.5 text-sm text-primary-foreground">
        {text}
      </p>
    </div>
  );
}
