import { createFileRoute } from "@tanstack/react-router";
import { useQuery, useQueryClient } from "@tanstack/react-query";
import { useEffect, useRef, useState } from "react";
import { MessageSquarePlus, Send } from "lucide-react";
import { toast } from "sonner";
import { supabase } from "@/integrations/supabase/client";
import { useProfile } from "@/lib/use-profile";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";

export const Route = createFileRoute("/_authenticated/etudiant/messages")({
  component: StudentMessagesPage,
  head: () => ({
    meta: [
      { title: "Messages — MANDAL" },
      { name: "description", content: "Échangez avec vos enseignants sur MANDAL." },
      { name: "robots", content: "noindex" },
    ],
  }),
});

function StudentMessagesPage() {
  const { data: profile } = useProfile();
  const queryClient = useQueryClient();
  const [activeId, setActiveId] = useState<string | null>(null);
  const [draft, setDraft] = useState("");
  const [newSubject, setNewSubject] = useState("");
  const bottomRef = useRef<HTMLDivElement>(null);

  const { data: conversations = [] } = useQuery({
    enabled: !!profile,
    queryKey: ["conversations", profile?.id],
    queryFn: async () => {
      const { data, error } = await supabase
        .from("conversations")
        .select("id, sujet, type, statut, updated_at")
        .order("updated_at", { ascending: false });
      if (error) throw new Error(error.message);
      return data ?? [];
    },
  });

  useEffect(() => {
    if (!activeId && conversations.length > 0) setActiveId(conversations[0]!.id);
  }, [conversations, activeId]);

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
      .channel(`messages-${activeId}`)
      .on(
        "postgres_changes",
        { event: "INSERT", schema: "public", table: "messages", filter: `conversation_id=eq.${activeId}` },
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

  const createConversation = async () => {
    if (!profile || !newSubject.trim()) return;
    const { data, error } = await supabase
      .from("conversations")
      .insert({ eleve_id: profile.id, sujet: newSubject.trim(), type: "question", statut: "ouverte" })
      .select("id")
      .single();
    if (error) {
      toast.error(error.message);
      return;
    }
    setNewSubject("");
    setActiveId(data.id);
    await queryClient.invalidateQueries({ queryKey: ["conversations"] });
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
    await supabase.from("conversations").update({ updated_at: new Date().toISOString() }).eq("id", activeId);
    await queryClient.invalidateQueries({ queryKey: ["messages", activeId] });
  };

  return (
    <div className="space-y-6">
      <header className="gradient-welcome rounded-2xl p-6 text-primary-foreground shadow-sm">
        <h1 className="font-display text-2xl font-bold tracking-tight">Messages</h1>
        <p className="mt-1 text-sm opacity-90">Posez vos questions à vos enseignants.</p>
      </header>

      <div className="grid gap-4 lg:grid-cols-[300px_1fr]">
        <aside className="rounded-2xl bg-card p-4 shadow-sm">
          <div className="flex gap-2">
            <Input
              value={newSubject}
              onChange={(e) => setNewSubject(e.target.value)}
              placeholder="Nouveau sujet"
              className="rounded-xl"
            />
            <Button size="icon" className="size-10 shrink-0 rounded-xl" onClick={createConversation}>
              <MessageSquarePlus className="size-4" />
            </Button>
          </div>
          <ul className="mt-4 space-y-1">
            {conversations.length === 0 ? (
              <li className="px-2 py-4 text-sm text-muted-foreground">Aucune conversation.</li>
            ) : (
              conversations.map((c) => (
                <li key={c.id}>
                  <button
                    onClick={() => setActiveId(c.id)}
                    className={`w-full rounded-xl px-3 py-2 text-left text-sm ${
                      activeId === c.id ? "bg-primary/10 text-primary" : "hover:bg-secondary"
                    }`}
                  >
                    <span className="block truncate font-medium">{c.sujet}</span>
                    <span className="block text-xs text-muted-foreground">{c.statut}</span>
                  </button>
                </li>
              ))
            )}
          </ul>
        </aside>

        <section className="flex min-h-[420px] flex-col rounded-2xl bg-card p-5 shadow-sm">
          {!activeId ? (
            <p className="m-auto text-sm text-muted-foreground">
              Créez une conversation pour démarrer un échange.
            </p>
          ) : (
            <>
              <div className="flex-1 space-y-3 overflow-y-auto">
                {messages.length === 0 ? (
                  <p className="text-sm text-muted-foreground">Aucun message pour l'instant.</p>
                ) : (
                  messages.map((m) => (
                    <div
                      key={m.id}
                      className={m.sender_id === profile?.id ? "flex justify-end" : "flex justify-start"}
                    >
                      <p
                        className={`max-w-[75%] whitespace-pre-wrap rounded-2xl px-4 py-2.5 text-sm ${
                          m.sender_id === profile?.id
                            ? "bg-primary text-primary-foreground"
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
                  placeholder="Votre message"
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
