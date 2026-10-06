import { createFileRoute } from "@tanstack/react-router";
import { useQuery, useQueryClient } from "@tanstack/react-query";
import { useEffect, useRef, useState } from "react";
import { MessageSquare, Send } from "lucide-react";
import { toast } from "sonner";
import { supabase } from "@/integrations/supabase/client";
import { useProfile } from "@/lib/use-profile";
import { TeacherStatusBadge } from "@/components/teacher-status-badge";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";

export const Route = createFileRoute("/_authenticated/enseignant/messages")({
  component: TeacherMessagesPage,
  head: () => ({
    meta: [
      { title: "Messages — M'Andal" },
      { name: "description", content: "Messages sur la plateforme M'Andal." },
      { name: "robots", content: "noindex" },
    ],
  }),
});

function TeacherMessagesPage() {
  const { data: profile } = useProfile();
  const queryClient = useQueryClient();
  const [activeId, setActiveId] = useState<string | null>(null);
  const [draft, setDraft] = useState("");
  const bottomRef = useRef<HTMLDivElement>(null);

  const { data: conversations = [] } = useQuery({
    enabled: !!profile,
    queryKey: ["enseignant-conversations", profile?.id],
    queryFn: async () => {
      const { data, error } = await supabase
        .from("conversations")
        .select("id, sujet, type, statut, updated_at, eleve_id, profiles!conversations_eleve_id_fkey(full_name, nom, prenom)")
        .eq("enseignant_id", profile!.id)
        .order("updated_at", { ascending: false });
      if (error) throw new Error(error.message);
      return data ?? [];
    },
  });

  useEffect(() => {
    if (!activeId && conversations.length > 0) setActiveId(conversations[0]!.id);
  }, [conversations, activeId]);

  const active = conversations.find((c) => c.id === activeId) ?? null;

  const { data: messages = [] } = useQuery({
    enabled: !!activeId,
    queryKey: ["messages", activeId],
    queryFn: async () => {
      const { data, error } = await supabase
        .from("messages")
        .select("id, contenu, sender_id, created_at")
        .eq("conversation_id", activeId!)
        .order("created_at", { ascending: true });
      if (error) throw new Error(error.message);
      return data ?? [];
    },
  });

  useEffect(() => {
    if (!activeId) return;
    const channel = supabase
      .channel(`messages-enseignant-${activeId}`)
      .on(
        "postgres_changes",
        {
          event: "INSERT",
          schema: "public",
          table: "messages",
          filter: `conversation_id=eq.${activeId}`,
        },
        () => queryClient.invalidateQueries({ queryKey: ["messages", activeId] }),
      )
      .subscribe();
    return () => {
      supabase.removeChannel(channel);
    };
  }, [activeId, queryClient]);

  useEffect(() => {
    bottomRef.current?.scrollIntoView({ behavior: "smooth" });
  }, [messages.length]);

  const studentName = (c: (typeof conversations)[number]) => {
    const p = c.profiles as unknown as {
      full_name: string | null;
      nom: string | null;
      prenom: string | null;
    } | null;
    return [p?.prenom, p?.nom].filter(Boolean).join(" ").trim() || p?.full_name || "Élève";
  };

  const sendMessage = async () => {
    if (!profile || !activeId || !draft.trim()) return;
    const contenu = draft.trim();
    setDraft("");
    const { error } = await supabase
      .from("messages")
      .insert({ conversation_id: activeId, sender_id: profile.id, contenu });
    if (error) {
      toast.error(error.message);
      return;
    }
    await supabase
      .from("conversations")
      .update({ updated_at: new Date().toISOString() })
      .eq("id", activeId);
    await queryClient.invalidateQueries({ queryKey: ["messages", activeId] });
  };

  const changeStatus = async (statut: string) => {
    if (!activeId) return;
    const { error } = await supabase.from("conversations").update({ statut }).eq("id", activeId);
    if (error) {
      toast.error(error.message);
      return;
    }
    toast.success("Statut mis à jour");
    await queryClient.invalidateQueries({ queryKey: ["enseignant-conversations"] });
    await queryClient.invalidateQueries({ queryKey: ["enseignant-messages-attente"] });
  };

  return (
    <div className="space-y-6">
      <header>
        <h1 className="font-display text-2xl font-bold tracking-tight text-foreground">Messages</h1>
        <p className="text-sm text-muted-foreground">Répondez aux questions de vos élèves.</p>
      </header>

      <div className="grid gap-4 lg:grid-cols-[320px_1fr]">
        <aside className="rounded-2xl bg-card p-4 shadow-sm">
          <ul className="space-y-1">
            {conversations.length === 0 ? (
              <li className="px-2 py-4 text-sm text-muted-foreground">
                Aucune conversation ne vous est adressée.
              </li>
            ) : (
              conversations.map((c) => (
                <li key={c.id}>
                  <button
                    onClick={() => setActiveId(c.id)}
                    className={`w-full rounded-xl px-3 py-2 text-left text-sm ${
                      activeId === c.id ? "bg-success/10 text-success" : "hover:bg-secondary"
                    }`}
                  >
                    <span className="block truncate font-medium">{c.sujet}</span>
                    <span className="mt-0.5 flex items-center justify-between gap-2">
                      <span className="truncate text-xs text-muted-foreground">
                        {studentName(c)}
                      </span>
                      <TeacherStatusBadge status={c.statut} />
                    </span>
                  </button>
                </li>
              ))
            )}
          </ul>
        </aside>

        <section className="flex min-h-[420px] flex-col rounded-2xl bg-card p-5 shadow-sm">
          {!active ? (
            <div className="m-auto text-center">
              <MessageSquare className="mx-auto size-6 text-muted-foreground" />
              <p className="mt-3 text-sm text-muted-foreground">
                Sélectionnez une conversation pour répondre.
              </p>
            </div>
          ) : (
            <>
              <div className="flex flex-wrap items-center justify-between gap-3 border-b pb-3">
                <div>
                  <p className="font-semibold text-foreground">{active.sujet}</p>
                  <p className="text-xs text-muted-foreground">{studentName(active)}</p>
                </div>
                <div className="flex gap-2">
                  <Button
                    size="sm"
                    variant={active.statut === "en_attente" ? "default" : "outline"}
                    className="rounded-xl"
                    onClick={() => changeStatus("en_attente")}
                  >
                    En attente
                  </Button>
                  <Button
                    size="sm"
                    variant={active.statut === "accepte" ? "default" : "outline"}
                    className="rounded-xl"
                    onClick={() => changeStatus("accepte")}
                  >
                    Accepté
                  </Button>
                </div>
              </div>

              <div className="mt-4 flex-1 space-y-3 overflow-y-auto">
                {messages.length === 0 ? (
                  <p className="text-sm text-muted-foreground">Aucun message pour l'instant.</p>
                ) : (
                  messages.map((m) => (
                    <div
                      key={m.id}
                      className={
                        m.sender_id === profile?.id ? "flex justify-end" : "flex justify-start"
                      }
                    >
                      <p
                        className={`max-w-[75%] whitespace-pre-wrap rounded-2xl px-4 py-2.5 text-sm ${
                          m.sender_id === profile?.id
                            ? "bg-success text-success-foreground"
                            : "bg-secondary text-foreground"
                        }`}
                      >
                        {m.contenu}
                      </p>
                    </div>
                  ))
                )}
                <div ref={bottomRef} />
              </div>

              <form
                className="mt-4 flex gap-2"
                onSubmit={(e) => {
                  e.preventDefault();
                  void sendMessage();
                }}
              >
                <Input
                  value={draft}
                  onChange={(e) => setDraft(e.target.value)}
                  placeholder="Votre réponse"
                  className="rounded-xl"
                />
                <Button type="submit" size="icon" className="size-10 shrink-0 rounded-xl">
                  <Send className="size-4" />
                </Button>
              </form>
            </>
          )}
        </section>
      </div>
    </div>
  );
}
