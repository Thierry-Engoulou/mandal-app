import { createFileRoute, Link } from "@tanstack/react-router";
import { useQuery } from "@tanstack/react-query";
import { BookOpen, ClipboardCheck, MessageSquare, Users } from "lucide-react";
import { supabase } from "@/integrations/supabase/client";
import { useProfile, displayName } from "@/lib/use-profile";
import { useSelectedSchool, useTeacherClasses, useTeacherValidation } from "@/lib/use-teacher";
import { TeacherPendingBanner } from "@/components/teacher-pending-banner";
import { TeacherStatusBadge } from "@/components/teacher-status-badge";

export const Route = createFileRoute("/_authenticated/enseignant/")({
  component: TeacherOverviewPage,
  head: () => ({
    meta: [
      { title: "Overview — M'Andal" },
      { name: "description", content: "Overview sur la plateforme M'Andal." },
      { name: "robots", content: "noindex" },
    ],
  }),
});

function StatCard({
  icon: Icon,
  label,
  value,
  tint,
}: {
  icon: typeof Users;
  label: string;
  value: number | string;
  tint: string;
}) {
  return (
    <div className="rounded-2xl bg-card p-5 shadow-sm">
      <div className={`flex size-10 items-center justify-center rounded-xl ${tint}`}>
        <Icon className="size-5" />
      </div>
      <p className="mt-4 font-display text-3xl font-bold text-foreground">{value}</p>
      <p className="mt-1 text-sm text-muted-foreground">{label}</p>
    </div>
  );
}

function TeacherOverviewPage() {
  const { data: profile } = useProfile();
  const { school, schoolId, schools } = useSelectedSchool();
  const { data: classes = [] } = useTeacherClasses(schoolId);
  const { data: validation } = useTeacherValidation(schoolId);

  const classIds = classes.map((c) => c.id);

  const { data: studentCount = 0 } = useQuery({
    enabled: classIds.length > 0,
    queryKey: ["enseignant-effectif", classIds],
    queryFn: async () => {
      const { count, error } = await supabase
        .from("class_membres")
        .select("id", { count: "exact", head: true })
        .in("class_id", classIds);
      if (error) throw new Error(error.message);
      return count ?? 0;
    },
  });

  const { data: toGrade = 0 } = useQuery({
    enabled: classIds.length > 0,
    queryKey: ["enseignant-a-corriger", classIds],
    queryFn: async () => {
      const { data: exams, error: examErr } = await supabase
        .from("examens")
        .select("id")
        .in("classe_id", classIds);
      if (examErr) throw new Error(examErr.message);
      const ids = (exams ?? []).map((e) => e.id);
      if (ids.length === 0) return 0;
      const { count, error } = await supabase
        .from("resultats_examens")
        .select("id", { count: "exact", head: true })
        .in("examen_id", ids)
        .eq("score", 0);
      if (error) throw new Error(error.message);
      return count ?? 0;
    },
  });

  const { data: pendingMessages = 0 } = useQuery({
    enabled: !!profile,
    queryKey: ["enseignant-messages-attente", profile?.id],
    queryFn: async () => {
      const { count, error } = await supabase
        .from("conversations")
        .select("id", { count: "exact", head: true })
        .eq("enseignant_id", profile!.id)
        .eq("statut", "en_attente");
      if (error) throw new Error(error.message);
      return count ?? 0;
    },
  });

  return (
    <div className="space-y-6">
      <header className="gradient-welcome rounded-2xl p-6 text-primary-foreground shadow-sm">
        <h1 className="font-display text-2xl font-bold tracking-tight">
          Bonjour {displayName(profile)}
        </h1>
        <p className="mt-1 text-sm opacity-90">
          {school ? school.nom : "Aucun établissement assigné pour le moment."}
        </p>
      </header>

      <TeacherPendingBanner statut={validation?.statut} />

      {schools.length === 0 ? (
        <div className="rounded-2xl bg-card p-10 text-center shadow-sm">
          <p className="text-sm text-muted-foreground">
            Aucune classe ne vous est encore assignée. Votre chef d'établissement doit vous
            rattacher à une classe.
          </p>
        </div>
      ) : (
        <>
          <div className="grid gap-4 sm:grid-cols-2 xl:grid-cols-4">
            <StatCard
              icon={BookOpen}
              label="Classes"
              value={classes.length}
              tint="bg-success/10 text-success"
            />
            <StatCard
              icon={Users}
              label="Élèves"
              value={studentCount}
              tint="bg-primary/10 text-primary"
            />
            <StatCard
              icon={ClipboardCheck}
              label="Examens à corriger"
              value={toGrade}
              tint="bg-warning/15 text-warning"
            />
            <StatCard
              icon={MessageSquare}
              label="Messages en attente"
              value={pendingMessages}
              tint="bg-violet/10 text-violet"
            />
          </div>

          <section className="rounded-2xl bg-card p-6 shadow-sm">
            <div className="flex items-center justify-between gap-3">
              <h2 className="font-display text-lg font-bold text-foreground">Statut du compte</h2>
              <TeacherStatusBadge status={validation?.statut ?? "en_attente"} />
            </div>
            <p className="mt-2 text-sm text-muted-foreground">
              {validation?.statut === "approuve"
                ? "Votre compte est validé : vous pouvez créer des programmes, des examens et déposer des ressources."
                : "En attendant la validation, la consultation reste possible mais la création de contenu est bloquée."}
            </p>
          </section>

          <section className="rounded-2xl bg-card p-6 shadow-sm">
            <h2 className="font-display text-lg font-bold text-foreground">Mes classes</h2>
            {classes.length === 0 ? (
              <p className="mt-2 text-sm text-muted-foreground">
                Aucune classe dans cet établissement.
              </p>
            ) : (
              <ul className="mt-4 grid gap-3 sm:grid-cols-2">
                {classes.map((c) => (
                  <li key={c.id} className="rounded-xl bg-secondary/60 px-4 py-3">
                    <p className="font-semibold text-foreground">{c.nom}</p>
                    <p className="text-xs text-muted-foreground">
                      {[c.niveau, c.filiere, c.annee_scolaire].filter(Boolean).join(" · ")}
                    </p>
                  </li>
                ))}
              </ul>
            )}
            <Link
              to="/enseignant/ecole"
              className="mt-4 inline-block text-sm font-medium text-success hover:underline"
            >
              Voir mon établissement
            </Link>
          </section>
        </>
      )}
    </div>
  );
}
