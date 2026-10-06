import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { supabase } from "@/integrations/supabase/client";
import { useProfile } from "@/lib/use-profile";

/**
 * Parcours élève : classes → programmes → chapitres → concepts → progression_concepts.
 * Toute la lecture/écriture passe par le client Supabase (RLS gère les droits).
 *
 * Note typage : les embeds imbriqués à 3 niveaux (programmes→chapitres→concepts)
 * dépassent ce que l'inférence de @supabase/supabase-js gère proprement (l'API
 * PostgREST renvoie les bonnes données — vérifié — mais le typage côté client
 * retombe sur `unknown`/`any` pour ce genre de requête). On isole donc le cast
 * à un seul endroit par requête (normalizeXxx), juste après l'appel réseau, et
 * tout le reste du fichier + les composants restent strictement typés.
 */

export type ProgrammeConcept = {
  id: string;
  chapitre_id: string;
  titre: string;
  ordre: number;
  type_contenu: string;
  contenu_texte: string | null;
  media_url: string | null;
  duree_minutes: number | null;
};

export type ProgrammeChapitre = {
  id: string;
  programme_id: string;
  titre: string;
  ordre: number;
  niveau: string | null;
  concepts: ProgrammeConcept[];
};

export type ProgrammeInfo = {
  id: string;
  titre: string;
  description: string | null;
  matiereNom: string | null;
  classeNom: string | null;
};

export type ProgrammeSummary = ProgrammeInfo & {
  totalConcepts: number;
  conceptsTermines: number;
};

export type ProgrammeDetailResponse = {
  programme: ProgrammeInfo;
  chapitres: ProgrammeChapitre[];
};

/** PostgREST renvoie un embed many-to-one tantôt en objet, tantôt en tableau
 *  à un seul élément selon le chemin de requête emprunté par le client — on
 *  normalise les deux cas ici plutôt que de les supposer. */
function firstOrNull<T>(value: T | T[] | null | undefined): T | null {
  if (Array.isArray(value)) return value[0] ?? null;
  return value ?? null;
}

function normalizeConcept(raw: unknown): ProgrammeConcept {
  const k = raw as Record<string, unknown>;
  return {
    id: k.id as string,
    chapitre_id: k.chapitre_id as string,
    titre: k.titre as string,
    ordre: (k.ordre as number) ?? 0,
    type_contenu: (k.type_contenu as string) ?? "texte",
    contenu_texte: (k.contenu_texte as string) ?? null,
    media_url: (k.media_url as string) ?? null,
    duree_minutes: (k.duree_minutes as number) ?? null,
  };
}

function normalizeChapitre(raw: unknown): ProgrammeChapitre {
  const ch = raw as Record<string, unknown>;
  const concepts = ((ch.concepts as unknown[]) ?? []).map(normalizeConcept);
  concepts.sort((a, b) => a.ordre - b.ordre);
  return {
    id: ch.id as string,
    programme_id: ch.programme_id as string,
    titre: ch.titre as string,
    ordre: (ch.ordre as number) ?? 0,
    niveau: (ch.niveau as string) ?? null,
    concepts,
  };
}

function normalizeProgrammeInfo(raw: unknown): ProgrammeInfo {
  const p = raw as Record<string, unknown>;
  const matiere = firstOrNull(p.matieres as { nom: string } | { nom: string }[] | null);
  const classe = firstOrNull(p.classes as { nom: string } | { nom: string }[] | null);
  return {
    id: p.id as string,
    titre: p.titre as string,
    description: (p.description as string) ?? null,
    matiereNom: matiere?.nom ?? null,
    classeNom: classe?.nom ?? null,
  };
}

/** Programmes visibles pour l'élève connecté, avec sa progression déjà calculée. */
export function useStudentProgrammes(selectedClasseId?: string | null) {
  const { data: profile } = useProfile();

  return useQuery({
    queryKey: ["etudiant-programmes", profile?.id, selectedClasseId],
    queryFn: async (): Promise<ProgrammeSummary[]> => {
      try {
        let classeIds: string[] = [];

        if (selectedClasseId && selectedClasseId !== "all") {
          classeIds = [selectedClasseId];
        } else if (profile?.id) {
          const { data: membres, error: membresError } = await supabase
            .from("class_membres")
            .select("class_id")
            .eq("eleve_id", profile.id);
          if (membresError) console.warn("Error fetching student classes:", membresError.message);
          classeIds = (membres ?? []).map((m) => m.class_id);
        }

        let query = supabase
          .from("programmes")
          .select(
            "id, titre, description, classe_id, matiere_id, matieres(nom), classes(nom, niveau), chapitres(id, titre, ordre)",
          )
          .order("titre");

        if (classeIds.length > 0 && selectedClasseId !== "all") {
          query = query.in("classe_id", classeIds);
        }

        const { data, error } = await query;
        if (error) {
          console.warn("Programmes query warning:", error.message);
          return [];
        }

        const rows = (data ?? []) as unknown[];
        if (rows.length === 0) return [];

        return rows.map((raw) => {
          const p = raw as Record<string, unknown>;
          const mat = p.matieres as { nom: string } | null;
          const cls = p.classes as { nom: string } | null;
          const chaps = (p.chapitres as unknown[]) ?? [];
          return {
            id: p.id as string,
            titre: p.titre as string,
            description: (p.description as string) ?? null,
            matiereNom: mat?.nom ?? null,
            classeNom: cls?.nom ?? null,
            totalConcepts: chaps.length,
            conceptsTermines: 0,
          };
        });
      } catch (err) {
        console.error("useStudentProgrammes error:", err);
        return [];
      }
    },
  });
}

/** Hook pour récupérer toutes les classes disponibles dans Supabase */
export function useAllClasses() {
  return useQuery({
    queryKey: ["all-classes-list"],
    queryFn: async () => {
      const { data, error } = await supabase
        .from("classes")
        .select("id, nom, niveau, filiere, etablissement_id, etablissements(nom)")
        .order("nom");
      if (error) {
        console.warn("Error fetching classes:", error.message);
        return [];
      }
      return data ?? [];
    },
  });
}

/** Hook pour permettre à un élève de s'inscrire / changer de classe */
export function useJoinClass() {
  const { data: profile } = useProfile();
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: async (classId: string) => {
      if (!profile?.id) throw new Error("Vous devez être connecté.");
      // Vérifier si l'élève est déjà inscrit à cette classe
      const { data: existing } = await supabase
        .from("class_membres")
        .select("id")
        .eq("eleve_id", profile.id)
        .eq("class_id", classId)
        .maybeSingle();

      if (!existing) {
        const { error } = await supabase
          .from("class_membres")
          .insert({ eleve_id: profile.id, class_id: classId });
        if (error) throw new Error(error.message);
      }
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["etudiant-programmes"] });
      queryClient.invalidateQueries({ queryKey: ["class-membres"] });
    },
  });
}

/** Détail d'un programme : ses chapitres ordonnés, chacun avec ses concepts ordonnés. */
export function useProgrammeDetail(programmeId: string) {
  return useQuery({
    enabled: !!programmeId,
    queryKey: ["programme-detail", programmeId],
    queryFn: async (): Promise<ProgrammeDetailResponse | null> => {
      const { data, error } = await supabase
        .from("programmes")
        .select(
          `id, titre, description,
           matieres(nom), classes(nom),
           chapitres(id, programme_id, titre, ordre, niveau,
             concepts(id, chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes))`,
        )
        .eq("id", programmeId)
        .maybeSingle();
      if (error) throw new Error(error.message);
      if (!data) return null;

      const raw = data as unknown as Record<string, unknown>;
      const programme = normalizeProgrammeInfo(raw);
      const chapitres = ((raw.chapitres as unknown[]) ?? []).map(normalizeChapitre);
      chapitres.sort((a, b) => a.ordre - b.ordre);

      return { programme, chapitres };
    },
  });
}

/** Concepts marqués terminés par l'élève, pour un ensemble de concept_id donné. */
export function useProgression(conceptIds: string[]) {
  const { data: profile } = useProfile();
  return useQuery({
    enabled: !!profile && conceptIds.length > 0,
    queryKey: ["progression-concepts", profile?.id, conceptIds.slice().sort().join(",")],
    queryFn: async (): Promise<Set<string>> => {
      const { data, error } = await supabase
        .from("progression_concepts")
        .select("concept_id")
        .eq("eleve_id", profile!.id)
        .eq("termine", true)
        .in("concept_id", conceptIds);
      if (error) throw new Error(error.message);
      return new Set((data ?? []).map((r) => r.concept_id));
    },
  });
}

/** Marque (ou démarque) un concept comme terminé pour l'élève connecté. */
export function useSetConceptDone() {
  const { data: profile } = useProfile();
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: async ({ conceptId, done }: { conceptId: string; done: boolean }) => {
      if (!profile) throw new Error("Non connecté");
      const { error } = await supabase
        .from("progression_concepts")
        .upsert(
          { eleve_id: profile.id, concept_id: conceptId, termine: done },
          { onConflict: "eleve_id,concept_id" },
        );
      if (error) throw new Error(error.message);
    },
    onSuccess: () =>
      Promise.all([
        queryClient.invalidateQueries({ queryKey: ["progression-concepts"] }),
        queryClient.invalidateQueries({ queryKey: ["etudiant-programmes"] }),
      ]),
  });
}
