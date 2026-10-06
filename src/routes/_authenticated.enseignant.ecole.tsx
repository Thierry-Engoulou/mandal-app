import { createFileRoute } from "@tanstack/react-router";
import { useQuery } from "@tanstack/react-query";
import { Building2, Users } from "lucide-react";
import { supabase } from "@/integrations/supabase/client";
import { useSelectedSchool, useTeacherClasses } from "@/lib/use-teacher";

export const Route = createFileRoute("/_authenticated/enseignant/ecole")({
  component: TeacherSchoolPage,
  head: () => ({
    meta: [
      { title: "My School — M'Andal" },
      { name: "description", content: "My School sur la plateforme M'Andal." },
      { name: "robots", content: "noindex" },
    ],
  }),
});

function TeacherSchoolPage() {
  const { school, schoolId } = useSelectedSchool();
  const { data: classes = [] } = useTeacherClasses(schoolId);
  const classIds = classes.map((c) => c.id);

  const { data: counts = {} } = useQuery({
    enabled: classIds.length > 0,
    queryKey: ["enseignant-effectifs-classes", classIds],
    queryFn: async () => {
      const { data, error } = await supabase
        .from("class_membres")
        .select("class_id")
        .in("class_id", classIds);
      if (error) throw new Error(error.message);
      const out: Record<string, number> = {};
      for (const row of data ?? []) out[row.class_id] = (out[row.class_id] ?? 0) + 1;
      return out;
    },
  });

  const { data: logoUrl } = useQuery({
    enabled: !!school?.logo_url,
    queryKey: ["logo-etablissement", school?.id, school?.logo_url],
    queryFn: async () => {
      const path = school!.logo_url!;
      if (path.startsWith("http")) return path;
      const { data } = await supabase.storage
        .from("logos-etablissements")
        .createSignedUrl(path, 60 * 60);
      return data?.signedUrl ?? null;
    },
  });

  const total = classIds.reduce((sum, id) => sum + (counts[id] ?? 0), 0);

  if (!school) {
    return (
      <div className="rounded-2xl bg-card p-10 text-center shadow-sm">
        <Building2 className="mx-auto size-6 text-muted-foreground" />
        <p className="mt-3 text-sm text-muted-foreground">
          Aucun établissement sélectionné. Vous devez être assigné à une classe.
        </p>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      <section className="flex flex-wrap items-center gap-5 rounded-2xl bg-card p-6 shadow-sm">
        {logoUrl ? (
          <img
            src={logoUrl}
            alt={school.nom}
            className="size-20 rounded-2xl object-cover"
          />
        ) : (
          <div className="flex size-20 items-center justify-center rounded-2xl bg-success/10 text-success">
            <Building2 className="size-8" />
          </div>
        )}
        <div>
          <h1 className="font-display text-2xl font-bold tracking-tight text-foreground">
            {school.nom}
          </h1>
          <p className="mt-1 text-sm text-muted-foreground">
            {[school.type, school.systeme_educatif].filter(Boolean).join(" · ")}
          </p>
          <p className="mt-2 flex items-center gap-2 text-sm text-foreground">
            <Users className="size-4 text-muted-foreground" />
            {total} élèves dans vos {classes.length} classe{classes.length > 1 ? "s" : ""}
          </p>
        </div>
      </section>

      <section className="rounded-2xl bg-card p-6 shadow-sm">
        <h2 className="font-display text-lg font-bold text-foreground">Mes classes ici</h2>
        {classes.length === 0 ? (
          <p className="mt-2 text-sm text-muted-foreground">Aucune classe dans cet établissement.</p>
        ) : (
          <ul className="mt-4 divide-y">
            {classes.map((c) => (
              <li key={c.id} className="flex items-center justify-between gap-3 py-3">
                <div>
                  <p className="font-medium text-foreground">{c.nom}</p>
                  <p className="text-xs text-muted-foreground">
                    {[c.niveau, c.filiere, c.annee_scolaire].filter(Boolean).join(" · ")}
                  </p>
                </div>
                <span className="rounded-full bg-secondary px-2.5 py-1 text-xs font-semibold text-muted-foreground">
                  {counts[c.id] ?? 0} élèves
                </span>
              </li>
            ))}
          </ul>
        )}
      </section>
    </div>
  );
}
