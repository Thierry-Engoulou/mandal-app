import { createFileRoute, Link } from "@tanstack/react-router";
import { GraduationCap, Users, ClipboardList } from "lucide-react";
import {
  useChefSchool,
  useChefMembers,
  useChefValidations,
  useChefResources,
} from "@/lib/use-chef";
import { ChefNoSchool } from "@/components/chef-empty";
import { TeacherStatusBadge } from "@/components/teacher-status-badge";
import { Skeleton } from "@/components/ui/skeleton";

export const Route = createFileRoute("/_authenticated/etablissement/")({
  component: PilotagePage,
  head: () => ({
    meta: [
      { title: "Pilotage établissement — MANDAL" },
      {
        name: "description",
        content: "Tableau de bord du chef d'établissement : comptes, validations et classes.",
      },
      { name: "robots", content: "noindex" },
    ],
  }),
});

const actions = [
  { to: "/etablissement/validation-enseignants", label: "Valider enseignants" },
  { to: "/etablissement/validation-contenus", label: "Valider contenus" },
  { to: "/etablissement/composition", label: "Composer une classe" },
  { to: "/etablissement/classes", label: "Voir mes classes" },
  { to: "/etablissement/utilisateurs", label: "Utilisateurs" },
] as const;

function PilotagePage() {
  const { school, etabId, isLoading } = useChefSchool();
  const { data: members = [] } = useChefMembers(etabId);
  const { data: validations = [] } = useChefValidations(etabId);
  const { data: pendingResources = [] } = useChefResources(etabId, "en_attente");

  if (isLoading) return <Skeleton className="h-40 rounded-2xl" />;
  if (!etabId) return <ChefNoSchool />;

  const teachers = members.filter((m) => m.role === "teacher");
  const approvedTeachers = teachers.filter((t) => t.statut_validation === "approuve").length;
  const students = members.filter((m) => m.role === "student").length;
  const pendingValidations = validations.filter((v) => v.statut === "en_attente");
  const pendingTotal = pendingValidations.length + pendingResources.length;

  const cards = [
    { label: "Enseignants approuvés", value: approvedTeachers, icon: GraduationCap },
    { label: "Élèves", value: students, icon: Users },
    { label: "En attente de validation", value: pendingTotal, icon: ClipboardList },
  ];

  const latest = [
    ...pendingValidations.slice(0, 5).map((v) => ({
      id: `t-${v.id}`,
      titre: v.nom,
      type: "Enseignant",
      date: v.created_at,
      to: "/etablissement/validation-enseignants" as const,
    })),
    ...pendingResources.slice(0, 5).map((r) => ({
      id: `r-${r.id}`,
      titre: r.titre,
      type: r.type === "video" ? "Vidéo" : r.type === "audio" ? "Audio" : "Document",
      date: r.created_at,
      to: "/etablissement/validation-contenus" as const,
    })),
  ]
    .sort((a, b) => (a.date < b.date ? 1 : -1))
    .slice(0, 8);

  return (
    <div className="space-y-6">
      <header className="gradient-progress rounded-2xl p-6 text-primary-foreground shadow-sm">
        <h1 className="font-display text-2xl font-bold tracking-tight">
          {school?.nom ?? "Mon établissement"}
        </h1>
        <p className="mt-1 text-sm opacity-90">
          Bienvenue dans votre espace de pilotage : validez les comptes, les contenus et composez
          vos classes.
        </p>
      </header>

      <div className="grid gap-4 sm:grid-cols-3">
        {cards.map((c) => (
          <div key={c.label} className="rounded-2xl bg-card p-5 shadow-sm">
            <span className="flex size-10 items-center justify-center rounded-xl bg-violet/10 text-violet">
              <c.icon className="size-5" />
            </span>
            <p className="mt-3 font-display text-2xl font-bold text-foreground">{c.value}</p>
            <p className="text-sm text-muted-foreground">{c.label}</p>
          </div>
        ))}
      </div>

      <div className="flex flex-wrap gap-3">
        {actions.map((a) => (
          <Link
            key={a.to}
            to={a.to}
            className="rounded-xl bg-violet/10 px-4 py-2 text-sm font-medium text-violet transition-colors hover:bg-violet/20"
          >
            {a.label}
          </Link>
        ))}
      </div>

      <section className="rounded-2xl bg-card p-6 shadow-sm">
        <h2 className="font-display text-lg font-semibold text-foreground">
          Dernières demandes en attente
        </h2>
        {latest.length === 0 ? (
          <p className="mt-2 text-sm text-muted-foreground">Aucune demande en attente.</p>
        ) : (
          <ul className="mt-4 divide-y divide-border">
            {latest.map((item) => (
              <li key={item.id} className="flex items-center justify-between gap-3 py-3">
                <div className="min-w-0">
                  <p className="truncate text-sm font-medium text-foreground">{item.titre}</p>
                  <p className="text-xs text-muted-foreground">
                    {item.type} · {new Date(item.date).toLocaleDateString("fr-FR")}
                  </p>
                </div>
                <div className="flex shrink-0 items-center gap-3">
                  <TeacherStatusBadge status="en_attente" />
                  <Link to={item.to} className="text-sm font-medium text-violet">
                    Traiter
                  </Link>
                </div>
              </li>
            ))}
          </ul>
        )}
      </section>
    </div>
  );
}
