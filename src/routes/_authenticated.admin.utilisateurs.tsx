import { createFileRoute } from "@tanstack/react-router";
import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { useServerFn } from "@tanstack/react-start";
import { useState } from "react";
import { toast } from "sonner";
import { listAdminUsers, updateAdminUser, listEtablissements, type UpdateAdminUserInput } from "@/lib/admin.functions";
import { Input } from "@/components/ui/input";
import { Skeleton } from "@/components/ui/skeleton";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";

export const Route = createFileRoute("/_authenticated/admin/utilisateurs")({
  component: AdminUsersPage,
  head: () => ({
    meta: [
      { title: "Utilisateurs — Administration MANDAL" },
      { name: "description", content: "Gestion des comptes et des rôles sur MANDAL." },
      { name: "robots", content: "noindex" },
    ],
  }),
});

const ROLES = [
  { value: "student", label: "Élève" },
  { value: "teacher", label: "Enseignant" },
  { value: "chef_etablissement", label: "Chef d'établissement" },
  { value: "admin", label: "Administrateur" },
  { value: "super_admin", label: "Super admin" },
] as const;

const STATUTS = [
  { value: "en_attente", label: "En attente" },
  { value: "approuve", label: "Approuvé" },
  { value: "rejete", label: "Rejeté" },
] as const;

function AdminUsersPage() {
  const fetchUsers = useServerFn(listAdminUsers);
  const fetchEtabs = useServerFn(listEtablissements);
  const saveUser = useServerFn(updateAdminUser);
  const queryClient = useQueryClient();
  const [search, setSearch] = useState("");

  const { data: users, isLoading } = useQuery({ queryKey: ["admin-users"], queryFn: () => fetchUsers() });
  const { data: etablissements = [] } = useQuery({
    queryKey: ["admin-etablissements"],
    queryFn: () => fetchEtabs(),
  });

  const mutation = useMutation({
    mutationFn: (input: UpdateAdminUserInput) => saveUser({ data: input }),
    onSuccess: async () => {
      toast.success("Compte mis à jour");
      await queryClient.invalidateQueries({ queryKey: ["admin-users"] });
      await queryClient.invalidateQueries({ queryKey: ["admin-overview"] });
    },
    onError: (e: Error) => toast.error(e.message),
  });

  const term = search.trim().toLowerCase();
  const filtered = (users ?? []).filter(
    (u) =>
      !term ||
      (u.email ?? "").toLowerCase().includes(term) ||
      u.nom.toLowerCase().includes(term),
  );

  return (
    <div className="space-y-6">
      <header>
        <h1 className="font-display text-2xl font-bold tracking-tight text-foreground">Utilisateurs</h1>
        <p className="mt-1 text-sm text-muted-foreground">
          Attribuez les rôles, rattachez un établissement et validez les enseignants.
        </p>
      </header>

      <Input
        value={search}
        onChange={(e) => setSearch(e.target.value)}
        placeholder="Rechercher par nom ou e-mail"
        className="max-w-md rounded-xl"
      />

      {isLoading ? (
        <Skeleton className="h-64 rounded-2xl" />
      ) : filtered.length === 0 ? (
        <div className="rounded-2xl bg-card p-10 text-center text-sm text-muted-foreground shadow-sm">
          Aucun compte trouvé.
        </div>
      ) : (
        <div className="overflow-hidden rounded-2xl bg-card shadow-sm">
          <div className="overflow-x-auto">
            <table className="w-full min-w-[820px] text-sm">
              <thead className="border-b bg-muted/40 text-left text-xs uppercase tracking-wide text-muted-foreground">
                <tr>
                  <th className="px-5 py-3">Compte</th>
                  <th className="px-5 py-3">Rôle</th>
                  <th className="px-5 py-3">Établissement</th>
                  <th className="px-5 py-3">Statut</th>
                  <th className="px-5 py-3">XP</th>
                </tr>
              </thead>
              <tbody className="divide-y">
                {filtered.map((u) => (
                  <tr key={u.id}>
                    <td className="px-5 py-3">
                      <p className="font-medium text-foreground">{u.nom}</p>
                      <p className="text-xs text-muted-foreground">{u.email ?? "—"}</p>
                    </td>
                    <td className="px-5 py-3">
                      <Select
                        value={u.role}
                        onValueChange={(role) =>
                          mutation.mutate({ userId: u.id, role: role as (typeof ROLES)[number]["value"] })
                        }
                      >
                        <SelectTrigger className="w-[190px] rounded-xl">
                          <SelectValue />
                        </SelectTrigger>
                        <SelectContent>
                          {ROLES.map((r) => (
                            <SelectItem key={r.value} value={r.value}>
                              {r.label}
                            </SelectItem>
                          ))}
                        </SelectContent>
                      </Select>
                    </td>
                    <td className="px-5 py-3">
                      <Select
                        value={u.etablissement_id ?? "none"}
                        onValueChange={(value) =>
                          mutation.mutate({
                            userId: u.id,
                            etablissementId: value === "none" ? null : value,
                          })
                        }
                      >
                        <SelectTrigger className="w-[210px] rounded-xl">
                          <SelectValue placeholder="Aucun" />
                        </SelectTrigger>
                        <SelectContent>
                          <SelectItem value="none">Aucun</SelectItem>
                          {etablissements.map((e) => (
                            <SelectItem key={e.id} value={e.id}>
                              {e.nom}
                            </SelectItem>
                          ))}
                        </SelectContent>
                      </Select>
                    </td>
                    <td className="px-5 py-3">
                      <Select
                        value={u.statut_validation}
                        onValueChange={(value) =>
                          mutation.mutate({
                            userId: u.id,
                            statutValidation: value as (typeof STATUTS)[number]["value"],
                          })
                        }
                      >
                        <SelectTrigger className="w-[150px] rounded-xl">
                          <SelectValue />
                        </SelectTrigger>
                        <SelectContent>
                          {STATUTS.map((s) => (
                            <SelectItem key={s.value} value={s.value}>
                              {s.label}
                            </SelectItem>
                          ))}
                        </SelectContent>
                      </Select>
                    </td>
                    <td className="px-5 py-3 font-medium text-foreground">{u.xp_total}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>
      )}
    </div>
  );
}
