import { Link, useNavigate, useRouterState } from "@tanstack/react-router";
import { useQueryClient } from "@tanstack/react-query";
import { useEffect, useState, type ReactNode } from "react";
import {
  LayoutDashboard,
  FileText,
  BookOpen,
  Trophy,
  Presentation,
  Flame,
  LifeBuoy,
  MessageSquare,
  Bell,
  History,
  Compass,
  Settings,
  ChevronDown,
  Sparkles,
  Menu,
  type LucideIcon,
} from "lucide-react";
import { supabase } from "@/integrations/supabase/client";
import { cn } from "@/lib/utils";
import { Button } from "@/components/ui/button";
import { Sheet, SheetClose, SheetContent, SheetTitle, SheetTrigger } from "@/components/ui/sheet";
import { MandalLogo } from "@/components/mandal-logo";

const navItems = [
  { to: "/etudiant", label: "Tableau de bord", icon: LayoutDashboard, exact: true },
  { to: "/etudiant/examens", label: "Examens", exact: false, icon: FileText },
  { to: "/etudiant/sujets", label: "Sujets", exact: false, icon: FileText },
  { to: "/etudiant/cours", label: "Mes cours", exact: false, icon: BookOpen },
  { to: "/etudiant/mediatheque", label: "Médiathèque", exact: false, icon: Presentation },
  { to: "/etudiant/classement", label: "Classement", exact: false, icon: Trophy },
  { to: "/etudiant/defis", label: "Défis", exact: false, icon: Flame },
  { to: "/etudiant/aide", label: "Aide", exact: false, icon: LifeBuoy },
  { to: "/etudiant/messages", label: "Messages", exact: false, icon: MessageSquare },
  { to: "/etudiant/notifications", label: "Notifications", exact: false, icon: Bell },
  { to: "/etudiant/historique", label: "Historique", exact: false, icon: History },
] satisfies { to: string; label: string; icon: LucideIcon; exact: boolean }[];

const orientationChildren = [
  { to: "/etudiant/orientation/conseiller", label: "Conseiller IA" },
  { to: "/etudiant/orientation/filieres", label: "Filières" },
  { to: "/etudiant/orientation/metiers", label: "Métiers" },
] as const;

function initialsOf(name: string) {
  return (
    name
      .split(" ")
      .filter(Boolean)
      .slice(0, 2)
      .map((p) => p[0]?.toUpperCase() ?? "")
      .join("") || "ET"
  );
}

export function StudentShell({ children }: { children: ReactNode }) {
  const navigate = useNavigate();
  const queryClient = useQueryClient();
  const pathname = useRouterState({ select: (s) => s.location.pathname });
  const [name, setName] = useState("Étudiant");
  const [orientationOpen, setOrientationOpen] = useState(
    pathname.startsWith("/etudiant/orientation"),
  );

  useEffect(() => {
    supabase.auth.getUser().then(({ data }) => {
      const meta = data.user?.user_metadata as { full_name?: string } | undefined;
      if (meta?.full_name) setName(meta.full_name);
      else if (data.user?.email) setName(data.user.email.split("@")[0] ?? "Étudiant");
    });
  }, []);

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

  return (
    <div className="flex min-h-screen bg-background">
      <header className="fixed inset-x-0 top-0 z-40 flex h-16 items-center justify-between border-b border-border bg-card px-4 md:hidden">
        <MandalLogo />
        <Sheet>
          <SheetTrigger asChild>
            <Button variant="ghost" size="icon" aria-label="Ouvrir la navigation"><Menu /></Button>
          </SheetTrigger>
          <SheetContent side="left" className="flex w-[280px] flex-col p-3">
            <SheetTitle className="px-2 py-3"><MandalLogo /></SheetTitle>
            <nav className="mt-3 flex-1 space-y-1 overflow-y-auto">
              {navItems.map((item) => (
                <SheetClose asChild key={item.to}>
                  <Link to={item.to} className={itemClass(isActive(item.to, item.exact))}>
                    <item.icon className="h-4 w-4 shrink-0" /><span>{item.label}</span>
                  </Link>
                </SheetClose>
              ))}
              <p className="px-3 pt-4 text-[11px] font-bold uppercase text-muted-foreground">Orientation</p>
              {orientationChildren.map((child) => (
                <SheetClose asChild key={child.to}>
                  <Link to={child.to} className={itemClass(pathname === child.to)}><Compass className="h-4 w-4" /><span>{child.label}</span></Link>
                </SheetClose>
              ))}
              <SheetClose asChild><Link to="/etudiant/parametres" className={itemClass(pathname === "/etudiant/parametres")}><Settings className="h-4 w-4" /><span>Paramètres</span></Link></SheetClose>
            </nav>
            <div className="border-t border-border p-3">
              <div className="flex items-center gap-3"><div className="flex h-9 w-9 items-center justify-center rounded-full bg-primary/10 text-xs font-bold text-primary">{initialsOf(name)}</div><div className="min-w-0"><p className="truncate text-sm font-semibold">{name}</p><p className="text-[11px] text-muted-foreground">ÉTUDIANT</p></div></div>
              <Button variant="ghost" className="mt-2 justify-start px-0 text-destructive hover:text-destructive" onClick={handleSignOut}>Se déconnecter</Button>
            </div>
          </SheetContent>
        </Sheet>
      </header>
      <aside className="fixed inset-y-0 left-0 hidden w-[220px] flex-col border-r border-border bg-card md:flex">
        <div className="flex justify-center px-4 py-6">
          <MandalLogo />
        </div>

        <nav className="flex-1 space-y-1 overflow-y-auto px-3 pb-4">
          {navItems.map((item) => (
            <Link key={item.to} to={item.to} className={itemClass(isActive(item.to, item.exact))}>
              <item.icon className="h-4 w-4 shrink-0" />
              <span>{item.label}</span>
            </Link>
          ))}

          <Button
            variant="ghost"
            type="button"
            onClick={() => setOrientationOpen((v) => !v)}
            className={cn(itemClass(pathname.startsWith("/etudiant/orientation")), "w-full")}
          >
            <Compass className="h-4 w-4 shrink-0" />
            <span className="flex-1 text-left">Orientation</span>
            <ChevronDown
              className={cn("h-4 w-4 transition-transform", orientationOpen && "rotate-180")}
            />
          </Button>
          {orientationOpen && (
            <div className="ml-7 space-y-1">
              {orientationChildren.map((child) => (
                <Link key={child.to} to={child.to} className={itemClass(pathname === child.to)}>
                  <span>{child.label}</span>
                </Link>
              ))}
            </div>
          )}

          <Link to="/etudiant/parametres" className={itemClass(pathname === "/etudiant/parametres")}>
            <Settings className="h-4 w-4 shrink-0" />
            <span>Paramètres</span>
          </Link>
        </nav>

        <div className="border-t border-border p-4">
          <div className="flex items-center gap-3">
            <div className="flex h-9 w-9 items-center justify-center rounded-full bg-primary/10 text-xs font-bold text-primary">
              {initialsOf(name)}
            </div>
            <div className="min-w-0">
              <p className="truncate text-sm font-semibold text-foreground">{name}</p>
              <p className="text-[11px] font-medium tracking-wide text-muted-foreground">ÉTUDIANT</p>
            </div>
          </div>
          <Button
            variant="ghost"
            type="button"
            onClick={handleSignOut}
            className="mt-3 h-auto justify-start px-0 text-sm font-medium text-destructive hover:text-destructive hover:underline"
          >
            Se déconnecter
          </Button>
        </div>
      </aside>

      <main className="flex-1 overflow-y-auto px-4 pb-6 pt-22 md:ml-[220px] md:p-8">{children}</main>
    </div>
  );
}
