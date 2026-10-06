import { createFileRoute } from "@tanstack/react-router";
import { useQuery, useQueryClient } from "@tanstack/react-query";
import { useEffect } from "react";
import { Bell, CheckCheck } from "lucide-react";
import { supabase } from "@/integrations/supabase/client";
import { useProfile } from "@/lib/use-profile";
import { Button } from "@/components/ui/button";

export const Route = createFileRoute("/_authenticated/etudiant/notifications")({
  component: StudentNotificationsPage,
  head: () => ({
    meta: [
      { title: "Notifications — MANDAL" },
      { name: "description", content: "Vos notifications MANDAL." },
      { name: "robots", content: "noindex" },
    ],
  }),
});

function StudentNotificationsPage() {
  const { data: profile } = useProfile();
  const queryClient = useQueryClient();

  const { data: notifications = [] } = useQuery({
    enabled: !!profile,
    queryKey: ["notifications", profile?.id],
    queryFn: async () => {
      const { data, error } = await supabase
        .from("notifications")
        .select("id, titre, contenu, lu, created_at")
        .order("created_at", { ascending: false });
      if (error) throw new Error(error.message);
      return data ?? [];
    },
  });

  useEffect(() => {
    if (!profile) return;
    const channel = supabase
      .channel("notifications-eleve")
      .on(
        "postgres_changes",
        { event: "INSERT", schema: "public", table: "notifications", filter: `profile_id=eq.${profile.id}` },
        () => queryClient.invalidateQueries({ queryKey: ["notifications"] }),
      )
      .subscribe();
    return () => {
      supabase.removeChannel(channel);
    };
  }, [profile, queryClient]);

  const markAllRead = async () => {
    if (!profile) return;
    await supabase.from("notifications").update({ lu: true }).eq("profile_id", profile.id).eq("lu", false);
    await queryClient.invalidateQueries({ queryKey: ["notifications"] });
  };

  return (
    <div className="space-y-6">
      <header className="flex items-center justify-between">
        <h1 className="font-display text-2xl font-bold tracking-tight text-foreground">Notifications</h1>
        <Button variant="outline" className="rounded-xl" onClick={markAllRead}>
          <CheckCheck className="size-4" /> Tout marquer comme lu
        </Button>
      </header>

      {notifications.length === 0 ? (
        <div className="rounded-2xl bg-card p-10 text-center shadow-sm">
          <Bell className="mx-auto size-6 text-muted-foreground" />
          <p className="mt-3 text-sm text-muted-foreground">Aucune notification pour l'instant.</p>
        </div>
      ) : (
        <ul className="divide-y overflow-hidden rounded-2xl bg-card shadow-sm">
          {notifications.map((n) => (
            <li key={n.id} className={`px-5 py-4 ${n.lu ? "" : "bg-primary/5"}`}>
              <p className="font-medium text-foreground">{n.titre}</p>
              {n.contenu ? <p className="mt-1 text-sm text-muted-foreground">{n.contenu}</p> : null}
              <p className="mt-1 text-xs text-muted-foreground">
                {new Date(n.created_at).toLocaleString("fr-FR")}
              </p>
            </li>
          ))}
        </ul>
      )}
    </div>
  );
}
