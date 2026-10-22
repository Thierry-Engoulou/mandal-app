import { createFileRoute } from "@tanstack/react-router";
import { useQuery, useQueryClient } from "@tanstack/react-query";
import { useServerFn } from "@tanstack/react-start";
import { useEffect, useRef, useState } from "react";
import { Compass, Send, LoaderCircle } from "lucide-react";
import { toast } from "sonner";
import { supabase } from "@/integrations/supabase/client";
import { useProfile } from "@/lib/use-profile";
import { askOrientationAdvisor } from "@/lib/orientation.functions";
import { Button } from "@/components/ui/button";
import { MathText } from "@/components/math-text";

export const Route = createFileRoute("/_authenticated/etudiant/orientation/conseiller")({
  component: OrientationAdvisorPage,
  head: () => ({
    meta: [
      { title: "Conseiller d'orientation IA — MANDAL" },
      { name: "description", content: "Échangez avec le conseiller d'orientation IA de MANDAL." },
      { name: "robots", content: "noindex" },
    ],
  }),
});

const SUGGESTIONS = [
  "Série C ou série D : laquelle choisir ?",
  "Quels concours puis-je passer après le Bac ?",
  "Comment devenir infirmier au Cameroun ?",
  "Quels métiers après une série A ?",
  "Which A Level subjects for medicine?",
];

function OrientationAdvisorPage() {
  const { data: profile } = useProfile();
  const queryClient = useQueryClient();
  const ask = useServerFn(askOrientationAdvisor);
  const [input, setInput] = useState("");
  const [pending, setPending] = useState(false);
  const inputRef = useRef<HTMLTextAreaElement>(null);
  const bottomRef = useRef<HTMLDivElement>(null);

  const { data: messages = [] } = useQuery({
    enabled: !!profile,
    queryKey: ["orientation-messages", profile?.id],
    queryFn: async () => {
      const { data, error } = await supabase
        .from("orientation_messages")
        .select("id, role, contenu, created_at")
        .eq("eleve_id", profile!.id)
        .order("created_at", { ascending: true });
      if (error) throw new Error(error.message);
      return data ?? [];
    },
  });

  useEffect(() => {
    bottomRef.current?.scrollIntoView({ behavior: "smooth" });
  }, [messages.length, pending]);

  useEffect(() => {
    inputRef.current?.focus();
  }, [pending]);

  const send = async (text: string) => {
    const value = text.trim();
    if (!value || pending) return;
    setInput("");
    setPending(true);
    try {
      await ask({ data: { message: value } });
      await queryClient.invalidateQueries({ queryKey: ["orientation-messages"] });
    } catch (error) {
      toast.error(error instanceof Error ? error.message : "Le conseiller est indisponible.");
    } finally {
      setPending(false);
    }
  };

  return (
    <div className="space-y-6">
      <header className="gradient-progress rounded-2xl p-6 text-primary-foreground shadow-sm">
        <Compass className="mb-2 size-6" />
        <h1 className="font-display text-2xl font-bold tracking-tight">Conseiller d'orientation</h1>
        <p className="mt-1 text-sm opacity-90">
          Posez vos questions sur les filières, les séries, les concours et les métiers au Cameroun.
          Chaque réponse cite ses références.
        </p>
      </header>

      <div className="rounded-2xl bg-card p-5 shadow-sm">
        <div className="max-h-[52vh] space-y-4 overflow-y-auto pr-1">
          {messages.length === 0 && !pending ? (
            <div className="py-8 text-center">
              <p className="text-sm text-muted-foreground">
                Commencez la conversation, par exemple :
              </p>
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
              <div key={m.id} className="flex justify-end">
                <p className="max-w-[80%] whitespace-pre-wrap rounded-2xl bg-primary px-4 py-2.5 text-sm text-primary-foreground">
                  {m.contenu}
                </p>
              </div>
            ) : (
              <MathText
                key={m.id}
                text={m.contenu}
                className="max-w-[90%] text-sm leading-relaxed text-foreground"
              />
            ),
          )}

          {pending ? (
            <p className="animate-pulse text-sm text-muted-foreground">Le conseiller réfléchit…</p>
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
            placeholder="Écrivez votre question…"
            className="flex-1 resize-none rounded-xl border border-border bg-background p-3 text-sm"
          />
          <Button type="submit" size="icon" className="size-10 rounded-xl" disabled={pending}>
            {pending ? <LoaderCircle className="animate-spin" /> : <Send className="size-4" />}
          </Button>
        </form>
        <p className="mt-2 text-center text-[11px] text-muted-foreground">
          Mandal IA est une intelligence artificielle : elle peut se tromper. Vérifie les points
          importants avec ton enseignant, et n'écris pas d'informations personnelles (nom complet,
          téléphone, adresse).
        </p>
      </div>
    </div>
  );
}
