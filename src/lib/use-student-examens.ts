import { useQuery } from "@tanstack/react-query";
import { supabase } from "@/integrations/supabase/client";
import { useProfile } from "@/lib/use-profile";

/**
 * Déverrouillage des quiz : un examen dont `deverrouille_si = 'tous_concepts_termines'`
 * reste verrouillé tant que tous les concepts de son `chapitre_id` ne sont pas
 * `termine = true` dans progression_concepts pour l'élève connecté.
 * `deverrouille_si = 'toujours'` (valeur par défaut) : jamais verrouillé.
 */

export type LockInfo = {
  isLocked: boolean;
  chapitreTitre: string | null;
  totalConcepts: number;
  conceptsTermines: number;
};

function computeLock(
  deverrouilleSi: string,
  chapitre: { titre: string; conceptIds: string[] } | null,
  doneSet: Set<string>,
): LockInfo {
  if (deverrouilleSi !== "tous_concepts_termines" || !chapitre) {
    return { isLocked: false, chapitreTitre: chapitre?.titre ?? null, totalConcepts: 0, conceptsTermines: 0 };
  }
  const total = chapitre.conceptIds.length;
  const done = chapitre.conceptIds.filter((id) => doneSet.has(id)).length;
  return {
    isLocked: total > 0 && done < total,
    chapitreTitre: chapitre.titre,
    totalConcepts: total,
    conceptsTermines: done,
  };
}

/** Liste des examens publiés + leur statut de verrouillage, pour la page /etudiant/examens. */
export function useStudentExamensWithLock() {
  const { data: profile } = useProfile();

  return useQuery({
    enabled: !!profile,
    queryKey: ["etudiant-examens-lock", profile?.id],
    queryFn: async () => {
      const [examensRes, resultatsRes] = await Promise.all([
        supabase
          .from("examens")
          .select(
            "id, titre, description, duree_minutes, nb_questions, statut, date_fin, deverrouille_si, chapitre_id, chapitres(titre, concepts(id))",
          )
          .eq("statut", "publie")
          .order("created_at", { ascending: false }),
        supabase.from("resultats_examens").select("examen_id, score").eq("eleve_id", profile!.id),
      ]);
      if (examensRes.error) throw new Error(examensRes.error.message);
      if (resultatsRes.error) throw new Error(resultatsRes.error.message);

      const rows = (examensRes.data ?? []) as unknown as Array<Record<string, unknown>>;
      const passed = new Map((resultatsRes.data ?? []).map((r) => [r.examen_id, Number(r.score)]));

      const chapitreByExam = rows.map((raw) => {
        const rawChapitre = Array.isArray(raw.chapitres) ? raw.chapitres[0] : raw.chapitres;
        if (!rawChapitre) return null;
        const c = rawChapitre as Record<string, unknown>;
        const conceptIds = ((c.concepts as { id: string }[]) ?? []).map((k) => k.id);
        return { titre: c.titre as string, conceptIds };
      });
      const allConceptIds = chapitreByExam.flatMap((c) => c?.conceptIds ?? []);

      let doneSet = new Set<string>();
      if (allConceptIds.length > 0) {
        const { data: progression, error: progressionError } = await supabase
          .from("progression_concepts")
          .select("concept_id")
          .eq("eleve_id", profile!.id)
          .eq("termine", true)
          .in("concept_id", allConceptIds);
        if (progressionError) throw new Error(progressionError.message);
        doneSet = new Set((progression ?? []).map((r) => r.concept_id));
      }

      return rows.map((raw, i) => {
        const lock = computeLock((raw.deverrouille_si as string) ?? "toujours", chapitreByExam[i], doneSet);
        return {
          id: raw.id as string,
          titre: raw.titre as string,
          description: (raw.description as string) ?? null,
          duree_minutes: raw.duree_minutes as number,
          nb_questions: raw.nb_questions as number,
          score: passed.get(raw.id as string) ?? null,
          lock,
        };
      });
    },
  });
}

/** Statut de verrouillage d'un seul examen, pour la page de passage du quiz. */
export function useExamenLock(examenId: string) {
  const { data: profile } = useProfile();

  return useQuery({
    enabled: !!profile && !!examenId,
    queryKey: ["examen-lock", examenId, profile?.id],
    queryFn: async (): Promise<LockInfo> => {
      const { data, error } = await supabase
        .from("examens")
        .select("deverrouille_si, chapitre_id, chapitres(titre, concepts(id))")
        .eq("id", examenId)
        .maybeSingle();
      if (error) throw new Error(error.message);
      if (!data) return { isLocked: false, chapitreTitre: null, totalConcepts: 0, conceptsTermines: 0 };

      const raw = data as unknown as Record<string, unknown>;
      const rawChapitre = Array.isArray(raw.chapitres) ? raw.chapitres[0] : raw.chapitres;
      const chapitre = rawChapitre
        ? {
            titre: (rawChapitre as Record<string, unknown>).titre as string,
            conceptIds: (((rawChapitre as Record<string, unknown>).concepts as { id: string }[]) ?? []).map(
              (k) => k.id,
            ),
          }
        : null;

      let doneSet = new Set<string>();
      if (chapitre && chapitre.conceptIds.length > 0) {
        const { data: progression, error: progressionError } = await supabase
          .from("progression_concepts")
          .select("concept_id")
          .eq("eleve_id", profile!.id)
          .eq("termine", true)
          .in("concept_id", chapitre.conceptIds);
        if (progressionError) throw new Error(progressionError.message);
        doneSet = new Set((progression ?? []).map((r) => r.concept_id));
      }

      return computeLock((raw.deverrouille_si as string) ?? "toujours", chapitre, doneSet);
    },
  });
}
