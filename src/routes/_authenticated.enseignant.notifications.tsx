import { createFileRoute } from "@tanstack/react-router";
import { useQuery, useQueryClient } from "@tanstack/react-query";
import { useEffect } from "react";
import { Bell, CheckCheck } from "lucide-react";
import { supabase } from "@/integrations/supabase/client";
import { useProfile } from "@/lib/use-profile";
import { Button } from "@/components/ui/button";

export const Route = createFileRoute("/_authenticated/enseignant/notifications")({
  component: TeacherNotificationsPage,
  head: () => ({
    meta: [
      { title: "Notifications — M'Andal" },
      { name: "description", content: "Notifications sur la plateforme M'Andal." },
      { name: "robots", content: "noindex" },
    ],
  }),
});

function TeacherNotificationsPage() {
  const { data: profile } = useProfile();
  const queryClient = useQueryClient();

  const { data: notifications = [] } = useQuery({
    enabled: !!profile,
    queryKey: ["notifications", profile?.id],
    queryFn: async () => {
      const { data, error } = await supabase
        .from("notifications")
        .select("id, titre, contenu, lu, created_at")
        .eq("profile_id", profile!.id)
        .order("created_at", { ascending: false });
      if (error) throw new Error(error.message);
      return data ?? [];
    },
  });

  useEffect(() => {
    if (!profile) return;
    const channel = supabase
      .channel("notifications-enseignant")
      .on(
        "postgres_changes",
        {
          event: "*",
          schema: "public",
          table: "notifications",
          filter: `profile_id=eq.${profile.id}`,
        },
        () => {
          queryClient.invalidateQueries({ queryKey: ["notifications"] });
          queryClient.invalidateQueries({ queryKey: ["notifications-non-lues"] });
        },
      )
      .subscribe();
    return () => {
      supabase.removeChannel(channel);
    };
  }, [profile, queryClient]);

  const refresh = async () => {
    await queryClient.invalidateQueries({ queryKey: ["notifications"] });
    await queryClient.invalidateQueries({ queryKey: ["notifications-non-lues"] });
  };

  const markOne = async (id: string) => {
    await supabase.from("notifications").update({ lu: true }).eq("id", id);
    await refresh();
  };

  const markAllRead = async () => {
    if (!profile) return;
    await supabase
      .from("notifications")
      .update({ lu: true })
      .eq("profile_id", profile.id)
      .eq("lu", false);
    await refresh();
  };

  const unread = notifications.filter((n) => !n.lu).length;

  return (
    <div className="space-y-6">
      <header className="flex flex-wrap items-center justify-between gap-3">
        <div>
          <h1 className="font-display text-2xl font-bold tracking-tight text-foreground">
            Notifications
          </h1>
          <p className="text-sm text-muted-foreground">{unread} non lue(s)</p>
        </div>
        <Button variant="outline" className="rounded-xl" onClick={markAllRead} disabled={!unread}>
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
            <li
              key={n.id}
              className={`flex items-start justify-between gap-4 px-5 py-4 ${n.lu ? "" : "bg-success/5"}`}
            >
              <div>
                <p className="font-medium text-foreground">{n.titre}</p>
                {n.contenu ? (
                  <p className="mt-1 text-sm text-muted-foreground">{n.contenu}</p>
                ) : null}
                <p className="mt-1 text-xs text-muted-foreground">
                  {new Date(n.created_at).toLocaleString("fr-FR")}
                </p>
              </div>
              {!n.lu && (
                <Button
                  size="sm"
                  variant="ghost"
                  className="shrink-0 rounded-xl"
                  onClick={() => markOne(n.id)}
                >
                  Marquer lu
                </Button>
              )}
            </li>
          ))}
        </ul>
      )}
    </div>
  );
}
