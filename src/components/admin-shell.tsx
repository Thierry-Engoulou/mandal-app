import { Link, useNavigate, useRouterState } from "@tanstack/react-router";
import { useQueryClient } from "@tanstack/react-query";
import type { ReactNode } from "react";
import { Users, Mail, LayoutDashboard, Inbox, LogOut } from "lucide-react";
import { supabase } from "@/integrations/supabase/client";
import { cn } from "@/lib/utils";
import { Button } from "@/components/ui/button";
import { MandalLogo } from "@/components/mandal-logo";

const items = [
  { to: "/admin", label: "Vue d'ensemble", icon: LayoutDashboard, exact: true },
  { to: "/admin/utilisateurs", label: "Utilisateurs", icon: Users, exact: false },
  { to: "/admin/demandes", label: "Demandes d'inscription", icon: Inbox, exact: false },
] as const;

export function AdminShell({ children }: { children: ReactNode }) {
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
      <aside className="hidden w-64 shrink-0 flex-col border-r border-border bg-card p-4 md:flex">
        <div className="px-2 py-3">
          <MandalLogo />
          <p className="mt-1 text-xs font-semibold uppercase tracking-wide text-violet">
            Administration
          </p>
        </div>
        <nav className="mt-4 flex-1 space-y-1">
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
