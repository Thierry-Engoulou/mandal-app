import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { useServerFn } from "@tanstack/react-start";
import { toast } from "sonner";
import { supabase } from "@/integrations/supabase/client";
import { useProfile } from "@/lib/use-profile";
import { approveResource, rejectResource } from "@/lib/etablissement.functions";

export type ChefSchool = {
  id: string;
  nom: string;
  type: string | null;
  systeme_educatif: string;
  logo_url: string | null;
};

/** Établissement du chef connecté (profiles.etablissement_id). */
export function useChefSchool() {
  const { data: profile, isLoading: profileLoading } = useProfile();
  const etabId = profile?.etablissement_id ?? null;

  const query = useQuery({
    enabled: !!etabId,
    queryKey: ["chef-etablissement", etabId],
    queryFn: async (): Promise<ChefSchool | null> => {
      const { data, error } = await supabase
        .from("etablissements")
        .select("id, nom, type, systeme_educatif, logo_url")
        .eq("id", etabId!)
        .maybeSingle();
      if (error) throw new Error(error.message);
      return (data as ChefSchool | null) ?? null;
    },
  });

  return {
    profile,
    etabId,
    school: query.data ?? null,
    isLoading: profileLoading || (!!etabId && query.isLoading),
  };
}

export type ChefTeacher = {
  id: string;
  nom: string;
  statut_validation: string;
};

export function fullName(p: {
  prenom?: string | null;
  nom?: string | null;
  full_name?: string | null;
}) {
  return [p.prenom, p.nom].filter(Boolean).join(" ").trim() || p.full_name || "Sans nom";
}

/** Membres (enseignants + élèves) de l'établissement. */
export function useChefMembers(etabId: string | null) {
  return useQuery({
    enabled: !!etabId,
    queryKey: ["chef-membres", etabId],
    queryFn: async () => {
      const { data, error } = await supabase
        .from("profiles")
        .select("id, role, nom, prenom, full_name, statut_validation, xp_total, created_at")
        .eq("etablissement_id", etabId!)
        .order("created_at", { ascending: false });
      if (error) throw new Error(error.message);
      return (data ?? []).map((p) => ({
        id: p.id,
        role: p.role as string,
        nom: fullName(p),
        statut_validation: p.statut_validation as string,
        xp_total: p.xp_total,
        created_at: p.created_at,
      }));
    },
  });
}

export type ChefClass = {
  id: string;
  nom: string;
  niveau: string | null;
  filiere: string | null;
  annee_scolaire: string | null;
  description: string | null;
  effectif: number;
  is_composite: boolean;
  enseignant_id: string | null;
  enseignant_nom: string | null;
};

export function useChefClasses(etabId: string | null) {
  return useQuery({
    enabled: !!etabId,
    queryKey: ["chef-classes", etabId],
    queryFn: async (): Promise<ChefClass[]> => {
      const { data, error } = await supabase
        .from("classes")
        .select(
          "id, nom, niveau, filiere, annee_scolaire, description, effectif, is_composite, enseignant_id, profiles!classes_enseignant_id_fkey(nom, prenom, full_name)",
        )
        .eq("etablissement_id", etabId!)
        .order("nom");
      if (error) throw new Error(error.message);
      return (data ?? []).map((c) => {
        const t = c.profiles as unknown as {
          nom: string | null;
          prenom: string | null;
          full_name: string | null;
        } | null;
        return {
          id: c.id,
          nom: c.nom,
          niveau: c.niveau,
          filiere: c.filiere,
          annee_scolaire: c.annee_scolaire,
          description: c.description,
          effectif: c.effectif,
          is_composite: c.is_composite,
          enseignant_id: c.enseignant_id,
          enseignant_nom: t ? fullName(t) : null,
        };
      });
    },
  });
}

export type ChefValidation = {
  id: string;
  enseignant_id: string;
  statut: string;
  created_at: string;
  date_validation: string | null;
  nom: string;
};

export function useChefValidations(etabId: string | null) {
  return useQuery({
    enabled: !!etabId,
    queryKey: ["chef-validations", etabId],
    queryFn: async (): Promise<ChefValidation[]> => {
      const { data, error } = await supabase
        .from("validations_enseignants")
        .select(
          "id, enseignant_id, statut, created_at, date_validation, profiles!validations_enseignants_enseignant_id_fkey(nom, prenom, full_name)",
        )
        .eq("etablissement_id", etabId!)
        .order("created_at", { ascending: false });
      if (error) throw new Error(error.message);
      return (data ?? []).map((v) => ({
        id: v.id,
        enseignant_id: v.enseignant_id,
        statut: v.statut as string,
        created_at: v.created_at,
        date_validation: v.date_validation,
        nom: fullName(
          (v.profiles as unknown as {
            nom: string | null;
            prenom: string | null;
            full_name: string | null;
          }) ?? {},
        ),
      }));
    },
  });
}

export type ChefResource = {
  id: string;
  titre: string;
  description: string | null;
  type: "video" | "audio" | "document";
  statut_validation: string;
  url_storage: string;
  created_at: string;
};

export function useChefResources(etabId: string | null, statut?: "en_attente" | "approuve") {
  return useQuery({
    enabled: !!etabId,
    queryKey: ["chef-ressources", etabId, statut ?? "all"],
    queryFn: async (): Promise<ChefResource[]> => {
      let q = supabase
        .from("ressources_mediatheque")
        .select("id, titre, description, type, statut_validation, url_storage, created_at")
        .eq("etablissement_id", etabId!)
        .order("created_at", { ascending: false });
      if (statut) q = q.eq("statut_validation", statut);
      const { data, error } = await q;
      if (error) throw new Error(error.message);
      return (data ?? []) as ChefResource[];
    },
  });
}

/** Élèves de l'établissement avec la filière de leur classe et leur score moyen. */
export function useChefStats(etabId: string | null) {
  return useQuery({
    enabled: !!etabId,
    queryKey: ["chef-stats", etabId],
    queryFn: async () => {
      const { data: classes, error: cErr } = await supabase
        .from("classes")
        .select("id, nom, filiere, class_membres(eleve_id)")
        .eq("etablissement_id", etabId!);
      if (cErr) throw new Error(cErr.message);

      const { data: examens, error: eErr } = await supabase
        .from("examens")
        .select("id, classe_id, resultats_examens(score)")
        .eq("etablissement_id", etabId!);
      if (eErr) throw new Error(eErr.message);

      const byClassFiliere = new Map<string, string>();
      const rows = new Map<
        string,
        { filiere: string; classes: number; eleves: number; scores: number[] }
      >();

      for (const c of classes ?? []) {
        const filiere = c.filiere?.trim() || "Non renseignée";
        byClassFiliere.set(c.id, filiere);
        const entry =
          rows.get(filiere) ?? { filiere, classes: 0, eleves: 0, scores: [] as number[] };
        entry.classes += 1;
        entry.eleves += (c.class_membres as unknown as unknown[] | null)?.length ?? 0;
        rows.set(filiere, entry);
      }

      for (const ex of examens ?? []) {
        const filiere = ex.classe_id ? byClassFiliere.get(ex.classe_id) : undefined;
        if (!filiere) continue;
        const entry = rows.get(filiere);
        if (!entry) continue;
        for (const r of (ex.resultats_examens as unknown as { score: number }[] | null) ?? []) {
          entry.scores.push(Number(r.score) || 0);
        }
      }

      return [...rows.values()]
        .map((r) => ({
          filiere: r.filiere,
          classes: r.classes,
          eleves: r.eleves,
          scoreMoyen: r.scores.length
            ? Math.round((r.scores.reduce((a, b) => a + b, 0) / r.scores.length) * 10) / 10
            : 0,
        }))
        .sort((a, b) => b.eleves - a.eleves);
    },
  });
}

/* ============================ MUTATIONS ============================ */

/** Approuve ou rejette une demande d'enseignant (validation + profil). */
export function useTeacherDecision(etabId: string | null) {
  const queryClient = useQueryClient();
  const { data: profile } = useProfile();

  return useMutation({
    mutationFn: async (input: {
      validationId: string;
      enseignantId: string;
      decision: "approuve" | "rejete";
    }) => {
      const { error: vErr } = await supabase
        .from("validations_enseignants")
        .update({
          statut: input.decision,
          valide_par: profile?.id ?? null,
          date_validation: new Date().toISOString(),
        })
        .eq("id", input.validationId);
      if (vErr) throw new Error(vErr.message);

      const { error: pErr } = await supabase
        .from("profiles")
        .update({ statut_validation: input.decision })
        .eq("id", input.enseignantId);
      if (pErr) throw new Error(pErr.message);
    },
    onSuccess: (_d, input) => {
      toast.success(
        input.decision === "approuve" ? "Enseignant approuvé." : "Demande rejetée.",
      );
      queryClient.invalidateQueries({ queryKey: ["chef-validations", etabId] });
      queryClient.invalidateQueries({ queryKey: ["chef-membres", etabId] });
    },
    onError: (e: Error) => toast.error(e.message),
  });
}

/** Approuve une ressource : déplace le fichier vers le bon bucket définitif. */
export function useResourceDecision(etabId: string | null) {
  const queryClient = useQueryClient();
  const approve = useServerFn(approveResource);
  const reject = useServerFn(rejectResource);

  return useMutation({
    mutationFn: async (input: { resourceId: string; decision: "approuve" | "rejete" }) => {
      if (input.decision === "approuve") {
        return approve({ data: { resourceId: input.resourceId } });
      }
      return reject({ data: { resourceId: input.resourceId } });
    },
    onSuccess: (_d, input) => {
      toast.success(
        input.decision === "approuve" ? "Contenu publié dans la médiathèque." : "Contenu rejeté.",
      );
      queryClient.invalidateQueries({ queryKey: ["chef-ressources", etabId] });
    },
    onError: (e: Error) => toast.error(e.message),
  });
}

/** Création / modification / suppression d'une classe de l'établissement. */
export function useClassMutations(etabId: string | null) {
  const queryClient = useQueryClient();
  const invalidate = () => {
    queryClient.invalidateQueries({ queryKey: ["chef-classes", etabId] });
    queryClient.invalidateQueries({ queryKey: ["chef-stats", etabId] });
  };

  const create = useMutation({
    mutationFn: async (input: {
      nom: string;
      niveau: string | null;
      filiere: string | null;
      enseignant_id: string | null;
    }) => {
      if (!etabId) throw new Error("Aucun établissement rattaché.");
      const { error } = await supabase.from("classes").insert({ ...input, etablissement_id: etabId });
      if (error) throw new Error(error.message);
    },
    onSuccess: () => {
      toast.success("Classe créée.");
      invalidate();
    },
    onError: (e: Error) => toast.error(e.message),
  });

  const update = useMutation({
    mutationFn: async (input: {
      id: string;
      nom: string;
      niveau: string | null;
      filiere: string | null;
      enseignant_id: string | null;
    }) => {
      const { id, ...rest } = input;
      const { error } = await supabase.from("classes").update(rest).eq("id", id);
      if (error) throw new Error(error.message);
    },
    onSuccess: () => {
      toast.success("Classe mise à jour.");
      invalidate();
    },
    onError: (e: Error) => toast.error(e.message),
  });

  const remove = useMutation({
    mutationFn: async (id: string) => {
      const { error } = await supabase.from("classes").delete().eq("id", id);
      if (error) throw new Error(error.message);
    },
    onSuccess: () => {
      toast.success("Classe supprimée.");
      invalidate();
    },
    onError: (e: Error) => toast.error(e.message),
  });

  return { create, update, remove };
}

/** Crée une classe composite et y rattache les élèves des classes sources. */
export function useCreateCompositeClass(etabId: string | null) {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: async (input: {
      nom: string;
      description: string | null;
      annee_scolaire: string | null;
      sourceIds: string[];
    }) => {
      if (!etabId) throw new Error("Aucun établissement rattaché.");
      if (input.sourceIds.length === 0) throw new Error("Sélectionnez au moins une classe.");

      const { data: membres, error: mErr } = await supabase
        .from("class_membres")
        .select("eleve_id")
        .in("class_id", input.sourceIds);
      if (mErr) throw new Error(mErr.message);

      const eleveIds = [...new Set((membres ?? []).map((m) => m.eleve_id))];

      const { data: created, error: cErr } = await supabase
        .from("classes")
        .insert({
          etablissement_id: etabId,
          nom: input.nom,
          description: input.description,
          annee_scolaire: input.annee_scolaire,
          is_composite: true,
          effectif: eleveIds.length,
        })
        .select("id")
        .single();
      if (cErr) throw new Error(cErr.message);

      if (eleveIds.length > 0) {
        const { error: insErr } = await supabase
          .from("class_membres")
          .insert(eleveIds.map((eleve_id) => ({ class_id: created.id, eleve_id })));
        if (insErr) throw new Error(insErr.message);
      }

      return { id: created.id, eleves: eleveIds.length };
    },
    onSuccess: (res) => {
      toast.success(`Classe composite créée avec ${res.eleves} élève(s).`);
      queryClient.invalidateQueries({ queryKey: ["chef-classes", etabId] });
      queryClient.invalidateQueries({ queryKey: ["chef-stats", etabId] });
    },
    onError: (e: Error) => toast.error(e.message),
  });
}
