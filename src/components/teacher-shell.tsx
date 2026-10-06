import { Link, useNavigate, useRouterState } from "@tanstack/react-router";
import { useQuery, useQueryClient } from "@tanstack/react-query";
import { useEffect, type ReactNode } from "react";
import {
  LayoutDashboard,
  Users,
  School,
  ListChecks,
  ClipboardList,
  MessageSquare,
  GraduationCap,
  Settings,
  Bell,
  Building2,
  Library,
  Menu,
  type LucideIcon,
} from "lucide-react";
import { supabase } from "@/integrations/supabase/client";
import { Button } from "@/components/ui/button";
import { Sheet, SheetClose, SheetContent, SheetTitle, SheetTrigger } from "@/components/ui/sheet";
import { MandalLogo } from "@/components/mandal-logo";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import { cn } from "@/lib/utils";
import { displayName, useProfile } from "@/lib/use-profile";
import { useSelectedSchool } from "@/lib/use-teacher";
import { setSelectedSchoolId } from "@/lib/teacher-store";

const navItems = [
  { to: "/enseignant", label: "Overview", icon: LayoutDashboard, exact: true },
  { to: "/enseignant/classes", label: "My Classes", exact: false, icon: Users },
  { to: "/enseignant/ecole", label: "My School", exact: false, icon: School },
  { to: "/enseignant/syllabus", label: "Syllabus", exact: false, icon: ListChecks },
  { to: "/enseignant/examens", label: "Exams", exact: false, icon: ClipboardList },
  { to: "/enseignant/mediatheque", label: "Médiathèque", exact: false, icon: Library },
  { to: "/enseignant/messages", label: "Messages", exact: false, icon: MessageSquare },
  { to: "/enseignant/eleves", label: "All Students", exact: false, icon: GraduationCap },
  { to: "/enseignant/parametres", label: "Paramètres", exact: false, icon: Settings },
] satisfies { to: string; label: string; icon: LucideIcon; exact: boolean }[];

function initialsOf(name: string) {
  return (
    name
      .split(" ")
      .filter(Boolean)
      .slice(0, 2)
      .map((p) => p[0]?.toUpperCase() ?? "")
      .join("") || "EN"
  );
}

function useUnreadNotifications() {
  const { data: profile } = useProfile();
  const queryClient = useQueryClient();

  const query = useQuery({
    enabled: !!profile,
    queryKey: ["notifications-non-lues", profile?.id],
    queryFn: async () => {
      const { count, error } = await supabase
        .from("notifications")
        .select("id", { count: "exact", head: true })
        .eq("profile_id", profile!.id)
        .eq("lu", false);
      if (error) throw new Error(error.message);
      return count ?? 0;
    },
  });

  useEffect(() => {
    if (!profile) return;
    const channel = supabase
      .channel("notifications-enseignant-badge")
      .on(
        "postgres_changes",
        {
          event: "*",
          schema: "public",
          table: "notifications",
          filter: `profile_id=eq.${profile.id}`,
        },
        () => queryClient.invalidateQueries({ queryKey: ["notifications-non-lues"] }),
      )
      .subscribe();
    return () => {
      supabase.removeChannel(channel);
    };
  }, [profile, queryClient]);

  return query.data ?? 0;
}

export function TeacherShell({ children }: { children: ReactNode }) {
  const navigate = useNavigate();
  const queryClient = useQueryClient();
  const pathname = useRouterState({ select: (s) => s.location.pathname });
  const { data: profile } = useProfile();
  const { schools, schoolId } = useSelectedSchool();
  const unreadNotifications = useUnreadNotifications();

  const name = profile ? displayName(profile) : "Enseignant";

  const isActive = (to: string, exact?: boolean) =>
    exact ? pathname === to : pathname.startsWith(to);

  const itemClass = (active: boolean) =>
    cn(
      "flex items-center gap-3 rounded-xl px-3 py-2 text-sm font-medium transition-colors",
      active
        ? "bg-success/10 text-success"
        : "text-muted-foreground hover:bg-secondary hover:text-foreground",
    );

  const handleSignOut = async () => {
    await queryClient.cancelQueries();
    queryClient.clear();
    await supabase.auth.signOut();
    navigate({ to: "/auth", replace: true });
  };

  const schoolSelector = (
    <Select
      value={schoolId ?? "none"}
      onValueChange={(v) => setSelectedSchoolId(v === "none" ? null : v)}
      disabled={schools.length === 0}
    >
      <SelectTrigger className="w-full rounded-xl">
        <span className="flex items-center gap-2 truncate">
          <Building2 className="h-4 w-4 text-muted-foreground" />
          <SelectValue placeholder="Aucun établissement" />
        </span>
      </SelectTrigger>
      <SelectContent>
        {schools.length === 0 ? (
          <SelectItem value="none">Aucun établissement</SelectItem>
        ) : (
          schools.map((s) => (
            <SelectItem key={s.id} value={s.id}>
              {s.nom}
            </SelectItem>
          ))
        )}
      </SelectContent>
    </Select>
  );

  return (
    <div className="flex min-h-screen bg-background">
      <header className="fixed inset-x-0 top-0 z-40 flex h-16 items-center justify-between border-b border-border bg-card px-4 md:hidden">
        <MandalLogo />
        <Sheet>
          <SheetTrigger asChild>
            <Button variant="ghost" size="icon" aria-label="Ouvrir la navigation">
              <Menu />
            </Button>
          </SheetTrigger>
          <SheetContent side="left" className="flex w-[280px] flex-col p-3">
            <SheetTitle className="px-2 py-3">
              <MandalLogo />
            </SheetTitle>
            <div className="px-1 pb-2">{schoolSelector}</div>
            <nav className="mt-3 flex-1 space-y-1 overflow-y-auto">
              {navItems.map((item) => (
                <SheetClose asChild key={item.to}>
                  <Link to={item.to} className={itemClass(isActive(item.to, item.exact))}>
                    <item.icon className="h-4 w-4 shrink-0" />
                    <span>{item.label}</span>
                  </Link>
                </SheetClose>
              ))}
              <SheetClose asChild>
                <Link
                  to="/enseignant/notifications"
                  className={itemClass(pathname === "/enseignant/notifications")}
                >
                  <Bell className="h-4 w-4 shrink-0" />
                  <span className="flex-1">Notifications</span>
                  {unreadNotifications > 0 && (
                    <span className="flex h-5 min-w-5 items-center justify-center rounded-full bg-destructive px-1.5 text-[11px] font-bold text-destructive-foreground">
                      {unreadNotifications}
                    </span>
                  )}
                </Link>
              </SheetClose>
            </nav>
            <div className="border-t border-border p-3">
              <div className="flex items-center gap-3">
                <div className="flex h-9 w-9 items-center justify-center rounded-full bg-violet/10 text-xs font-bold text-violet">
                  {initialsOf(name)}
                </div>
                <div className="min-w-0">
                  <p className="truncate text-sm font-semibold">{name}</p>
                  <p className="text-[11px] text-muted-foreground">TEACHER</p>
                </div>
              </div>
              <Button
                variant="ghost"
                className="mt-2 justify-start px-0 text-destructive hover:text-destructive"
                onClick={handleSignOut}
              >
                Sign Out
              </Button>
            </div>
          </SheetContent>
        </Sheet>
      </header>
      <aside className="fixed inset-y-0 left-0 hidden w-[240px] flex-col border-r border-border bg-card md:flex">
        <div className="flex justify-center px-4 pt-6">
          <MandalLogo />
        </div>
        <div className="px-3 py-4">{schoolSelector}</div>

        <nav className="flex-1 space-y-1 overflow-y-auto px-3 pb-4">
          {navItems.map((item) => (
            <Link key={item.to} to={item.to} className={itemClass(isActive(item.to, item.exact))}>
              <item.icon className="h-4 w-4 shrink-0" />
              <span>{item.label}</span>
            </Link>
          ))}
          <Link
            to="/enseignant/notifications"
            className={itemClass(pathname === "/enseignant/notifications")}
          >
            <Bell className="h-4 w-4 shrink-0" />
            <span className="flex-1">Notifications</span>
            {unreadNotifications > 0 && (
              <span className="flex h-5 min-w-5 items-center justify-center rounded-full bg-destructive px-1.5 text-[11px] font-bold text-destructive-foreground">
                {unreadNotifications}
              </span>
            )}
          </Link>
        </nav>

        <div className="border-t border-border p-4">
          <div className="flex items-center gap-3">
            <div className="flex h-9 w-9 items-center justify-center rounded-full bg-violet/10 text-xs font-bold text-violet">
              {initialsOf(name)}
            </div>
            <div className="min-w-0">
              <p className="truncate text-sm font-semibold text-foreground">{name}</p>
              <p className="text-[11px] font-medium tracking-wide text-muted-foreground">TEACHER</p>
            </div>
          </div>
          <button
            type="button"
            onClick={handleSignOut}
            className="mt-3 text-sm font-medium text-destructive hover:underline"
          >
            Sign Out
          </button>
        </div>
      </aside>

      <main className="flex-1 overflow-y-auto p-6 md:ml-[240px] md:p-8">{children}</main>
    </div>
  );
}
