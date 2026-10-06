import { createFileRoute } from "@tanstack/react-router";
import { useQuery } from "@tanstack/react-query";
import { useMemo, useState } from "react";
import { GraduationCap, Search } from "lucide-react";
import { supabase } from "@/integrations/supabase/client";
import { useSelectedSchool, useTeacherClasses } from "@/lib/use-teacher";
import { Input } from "@/components/ui/input";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";

export const Route = createFileRoute("/_authenticated/enseignant/eleves")({
  component: TeacherStudentsPage,
  head: () => ({
    meta: [
      { title: "All Students — M'Andal" },
      { name: "description", content: "All Students sur la plateforme M'Andal." },
      { name: "robots", content: "noindex" },
    ],
  }),
});

type StudentRow = {
  id: string;
  classId: string;
  name: string;
  xp: number;
  niveau: string;
  lastExam: string | null;
  average: number | null;
};

function TeacherStudentsPage() {
  const { schoolId } = useSelectedSchool();
  const { data: classes = [] } = useTeacherClasses(schoolId);
  const classIds = classes.map((c) => c.id);
  const [search, setSearch] = useState("");
  const [classFilter, setClassFilter] = useState("all");

  const { data: students = [], isLoading } = useQuery({
    enabled: classIds.length > 0,
    queryKey: ["enseignant-eleves", classIds],
    queryFn: async (): Promise<StudentRow[]> => {
      const { data: membres, error } = await supabase
        .from("class_membres")
        .select("class_id, eleve_id, profiles(id, full_name, nom, prenom, xp_total, niveau)")
        .in("class_id", classIds);
      if (error) throw new Error(error.message);

      const { data: exams } = await supabase.from("examens").select("id, titre").in("classe_id", classIds);
      const examTitles = new Map((exams ?? []).map((e) => [e.id, e.titre]));
      const examIds = [...examTitles.keys()];

      const results =
        examIds.length > 0
          ? (
              await supabase
                .from("resultats_examens")
                .select("examen_id, eleve_id, score, date_passage")
                .in("examen_id", examIds)
                .order("date_passage", { ascending: false })
            ).data ?? []
          : [];

      const byStudent = new Map<string, { scores: number[]; last: string | null }>();
      for (const r of results) {
        const entry = byStudent.get(r.eleve_id) ?? { scores: [], last: null };
        entry.scores.push(Number(r.score));
        if (!entry.last) entry.last = examTitles.get(r.examen_id) ?? null;
        byStudent.set(r.eleve_id, entry);
      }

      return (membres ?? []).map((m) => {
        const p = m.profiles as unknown as {
          id: string;
          full_name: string | null;
          nom: string | null;
          prenom: string | null;
          xp_total: number;
          niveau: string;
        };
        const stats = byStudent.get(m.eleve_id);
        const average =
          stats && stats.scores.length > 0
            ? Math.round((stats.scores.reduce((a, b) => a + b, 0) / stats.scores.length) * 10) / 10
            : null;
        return {
          id: m.eleve_id,
          classId: m.class_id,
          name:
            [p?.prenom, p?.nom].filter(Boolean).join(" ").trim() || p?.full_name || "Élève",
          xp: p?.xp_total ?? 0,
          niveau: p?.niveau ?? "—",
          lastExam: stats?.last ?? null,
          average,
        };
      });
    },
  });

  const filtered = useMemo(() => {
    const q = search.trim().toLowerCase();
    return students
      .filter((s) => (classFilter === "all" ? true : s.classId === classFilter))
      .filter((s) => (q ? s.name.toLowerCase().includes(q) : true))
      .sort((a, b) => a.name.localeCompare(b.name));
  }, [students, search, classFilter]);

  const className = (id: string) => classes.find((c) => c.id === id)?.nom ?? "—";

  return (
    <div className="space-y-6">
      <header className="flex flex-wrap items-end justify-between gap-3">
        <h1 className="font-display text-2xl font-bold tracking-tight text-foreground">
          Tous mes élèves
        </h1>
        <div className="flex flex-wrap gap-2">
          <div className="relative">
            <Search className="pointer-events-none absolute left-3 top-1/2 size-4 -translate-y-1/2 text-muted-foreground" />
            <Input
              value={search}
              onChange={(e) => setSearch(e.target.value)}
              placeholder="Rechercher un élève"
              className="w-56 rounded-xl pl-9"
            />
          </div>
          <Select value={classFilter} onValueChange={setClassFilter}>
            <SelectTrigger className="w-48 rounded-xl">
              <SelectValue />
            </SelectTrigger>
            <SelectContent>
              <SelectItem value="all">Toutes les classes</SelectItem>
              {classes.map((c) => (
                <SelectItem key={c.id} value={c.id}>
                  {c.nom}
                </SelectItem>
              ))}
            </SelectContent>
          </Select>
        </div>
      </header>

      {isLoading ? (
        <p className="text-sm text-muted-foreground">Chargement…</p>
      ) : filtered.length === 0 ? (
        <div className="rounded-2xl bg-card p-10 text-center shadow-sm">
          <GraduationCap className="mx-auto size-6 text-muted-foreground" />
          <p className="mt-3 text-sm text-muted-foreground">Aucun élève trouvé.</p>
        </div>
      ) : (
        <div className="overflow-x-auto rounded-2xl bg-card shadow-sm">
          <table className="w-full min-w-[640px] text-sm">
            <thead className="border-b text-left text-xs uppercase tracking-wide text-muted-foreground">
              <tr>
                <th className="px-5 py-3">Élève</th>
                <th className="px-5 py-3">Classe</th>
                <th className="px-5 py-3">XP</th>
                <th className="px-5 py-3">Dernier examen</th>
                <th className="px-5 py-3">Moyenne</th>
              </tr>
            </thead>
            <tbody className="divide-y">
              {filtered.map((s) => (
                <tr key={`${s.id}-${s.classId}`}>
                  <td className="px-5 py-3 font-medium text-foreground">{s.name}</td>
                  <td className="px-5 py-3 text-muted-foreground">{className(s.classId)}</td>
                  <td className="px-5 py-3">
                    <span className="rounded-full bg-success/10 px-2.5 py-1 text-xs font-semibold text-success">
                      {s.xp} XP
                    </span>
                  </td>
                  <td className="px-5 py-3 text-muted-foreground">{s.lastExam ?? "—"}</td>
                  <td className="px-5 py-3 text-foreground">
                    {s.average === null ? "—" : `${s.average}/20`}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}
    </div>
  );
}
