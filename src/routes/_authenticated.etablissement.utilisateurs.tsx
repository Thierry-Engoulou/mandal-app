import { useState } from "react";
import { createFileRoute } from "@tanstack/react-router";
import { useMutation, useQueryClient } from "@tanstack/react-query";
import { toast } from "sonner";
import { supabase } from "@/integrations/supabase/client";
import { useChefSchool, useChefMembers } from "@/lib/use-chef";
import { ChefNoSchool } from "@/components/chef-empty";
import { TeacherStatusBadge } from "@/components/teacher-status-badge";
import { Button } from "@/components/ui/button";
import { Skeleton } from "@/components/ui/skeleton";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";

export const Route = createFileRoute("/_authenticated/etablissement/utilisateurs")({
  component: UtilisateursPage,
  head: () => ({
    meta: [
      { title: "Utilisateurs de l'établissement — MANDAL" },
      { name: "description", content: "Enseignants et élèves rattachés à votre établissement." },
      { name: "robots", content: "noindex" },
    ],
  }),
});

const ROLE_LABELS: Record<string, string> = {
  teacher: "Enseignant",
  student: "Élève",
  chef_etablissement: "Chef d'établissement",
  admin: "Administrateur",
  super_admin: "Super administrateur",
};

function UtilisateursPage() {
  const { etabId, isLoading } = useChefSchool();
  const { data: members = [], isLoading: membersLoading } = useChefMembers(etabId);
  const queryClient = useQueryClient();
  const [filter, setFilter] = useState<"all" | "teacher" | "student">("all");

  const detach = useMutation({
    mutationFn: async (userId: string) => {
      const { error } = await supabase
        .from("profiles")
        .update({ etablissement_id: null, statut_validation: "rejete" })
        .eq("id", userId);
      if (error) throw new Error(error.message);
    },
    onSuccess: () => {
      toast.success("Compte retiré de l'établissement.");
      queryClient.invalidateQueries({ queryKey: ["chef-membres"] });
    },
    onError: (e: Error) => toast.error(e.message),
  });

  if (isLoading) return <Skeleton className="h-40 rounded-2xl" />;
  if (!etabId) return <ChefNoSchool />;

  const rows = members.filter(
    (m) => m.role === "teacher" || m.role === "student",
  ).filter((m) => (filter === "all" ? true : m.role === filter));

  return (
    <div className="space-y-6">
      <header>
        <h1 className="font-display text-2xl font-bold text-foreground">Utilisateurs</h1>
        <p className="mt-1 text-sm text-muted-foreground">
          Enseignants et élèves rattachés à votre établissement.
        </p>
      </header>

      <div className="flex gap-2">
        {(
          [
            ["all", "Tous"],
            ["teacher", "Enseignants"],
            ["student", "Élèves"],
          ] as const
        ).map(([value, label]) => (
          <button
            key={value}
            onClick={() => setFilter(value)}
            className={
              filter === value
                ? "rounded-full bg-violet/10 px-4 py-1.5 text-sm font-medium text-violet"
                : "rounded-full px-4 py-1.5 text-sm text-muted-foreground hover:bg-secondary"
            }
          >
            {label}
          </button>
        ))}
      </div>

      <div className="overflow-x-auto rounded-2xl bg-card p-2 shadow-sm">
        {membersLoading ? (
          <Skeleton className="h-40 rounded-xl" />
        ) : (
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead>Nom</TableHead>
                <TableHead>Rôle</TableHead>
                <TableHead>Statut</TableHead>
                <TableHead>XP</TableHead>
                <TableHead className="text-right">Action</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {rows.length === 0 ? (
                <TableRow>
                  <TableCell colSpan={5} className="text-sm text-muted-foreground">
                    Aucun utilisateur.
                  </TableCell>
                </TableRow>
              ) : (
                rows.map((m) => (
                  <TableRow key={m.id}>
                    <TableCell className="font-medium">{m.nom}</TableCell>
                    <TableCell>{ROLE_LABELS[m.role] ?? m.role}</TableCell>
                    <TableCell>
                      <TeacherStatusBadge status={m.statut_validation} />
                    </TableCell>
                    <TableCell>{m.xp_total}</TableCell>
                    <TableCell className="text-right">
                      <Button
                        variant="ghost"
                        size="sm"
                        className="text-destructive"
                        disabled={detach.isPending}
                        onClick={() => detach.mutate(m.id)}
                      >
                        Retirer
                      </Button>
                    </TableCell>
                  </TableRow>
                ))
              )}
            </TableBody>
          </Table>
        )}
      </div>
    </div>
  );
}
