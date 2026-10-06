import { Link, useNavigate, useRouterState } from "@tanstack/react-router";
import { useQueryClient } from "@tanstack/react-query";
import type { ReactNode } from "react";
import {
  LayoutDashboard,
  School,
  UserCheck,
  FileCheck2,
  BarChart3,
  Layers,
  Users,
  Bell,
  LogOut,
} from "lucide-react";
import { supabase } from "@/integrations/supabase/client";
import { cn } from "@/lib/utils";
import { Button } from "@/components/ui/button";
import { MandalLogo } from "@/components/mandal-logo";

const items = [
  { to: "/etablissement", label: "Pilotage", icon: LayoutDashboard, exact: true },
  { to: "/etablissement/classes", label: "Classes", icon: School, exact: false },
  {
    to: "/etablissement/validation-enseignants",
    label: "Validation enseignants",
    icon: UserCheck,
    exact: false,
  },
  {
    to: "/etablissement/validation-contenus",
    label: "Validation contenus",
    icon: FileCheck2,
    exact: false,
  },
  { to: "/etablissement/statistiques", label: "Statistiques", icon: BarChart3, exact: false },
  {
    to: "/etablissement/composition",
    label: "Composition de classe",
    icon: Layers,
    exact: false,
  },
  { to: "/etablissement/utilisateurs", label: "Utilisateurs", icon: Users, exact: false },
  { to: "/etablissement/alertes", label: "Alertes", icon: Bell, exact: false },
] as const;

export function ChefShell({ children }: { children: ReactNode }) {
  const pathname = useRouterState({ select: (s) => s.location.pathname });
  const navigate = useNavigate();
  const queryClient = useQueryClient();

  const handleSignOut = async () => {
    await queryClient.cancelQueries();
    queryClient.clear();
    await supabase.auth.signOut();
    navigate({ to: "/auth", replace: true });
  };

  return (
    <div className="flex min-h-screen bg-background">
      <aside className="sticky top-0 hidden h-screen w-64 shrink-0 flex-col border-r border-border bg-card p-4 md:flex">
        <div className="px-2 py-3">
          <MandalLogo />
          <p className="mt-1 text-xs font-semibold uppercase tracking-wide text-violet">
            Chef d'établissement
          </p>
        </div>
        <nav className="mt-4 flex-1 space-y-1 overflow-y-auto">
          {items.map((item) => {
            const active = item.exact ? pathname === item.to : pathname.startsWith(item.to);
            return (
              <Link
                key={item.to}
                to={item.to}
                className={cn(
                  "flex items-center gap-3 rounded-xl px-3 py-2 text-sm font-medium transition-colors",
                  active
                    ? "bg-violet/10 text-violet"
                    : "text-muted-foreground hover:bg-secondary hover:text-foreground",
                )}
              >
                <item.icon className="h-4 w-4 shrink-0" />
                {item.label}
              </Link>
            );
          })}
        </nav>
        <Button variant="ghost" className="justify-start rounded-xl" onClick={handleSignOut}>
          <LogOut className="h-4 w-4" /> Se déconnecter
        </Button>
      </aside>

      <div className="flex min-w-0 flex-1 flex-col">
        <header className="flex items-center gap-2 overflow-x-auto border-b border-border bg-card px-4 py-3 md:hidden">
          {items.map((item) => (
            <Link
              key={item.to}
              to={item.to}
              className="whitespace-nowrap rounded-full px-3 py-1.5 text-sm text-muted-foreground"
            >
              {item.label}
            </Link>
          ))}
        </header>
        <main className="flex-1 p-4 md:p-8">{children}</main>
      </div>
    </div>
  );
}
