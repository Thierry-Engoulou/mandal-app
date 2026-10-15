import { createServerFn } from "@tanstack/react-start";
import { z } from "zod";
import type { SupabaseClient } from "@supabase/supabase-js";
import { requireSupabaseAuth } from "@/integrations/supabase/auth-middleware";
import type { Database, Json } from "@/integrations/supabase/types";
import type { AiPart } from "./gemini.server";

type Supabase = SupabaseClient<Database>;

// ---------------------------------------------------------------------------
// Formats échangés avec la page /etudiant/sujets
// ---------------------------------------------------------------------------

const questionSchema = z.object({
  numero: z.coerce.string(),
  enonce: z.string(),
  points: z.coerce.number().nonnegative().catch(0),
});

const partieSchema = z.object({
  titre: z.string(),
  points: z.coerce.number().nonnegative().catch(0),
  description: z.string().catch(""),
  questions: z.array(questionSchema).min(1),
});

const epreuveSchema = z.object({
  titre: z.string(),
  niveau: z.string().catch(""),
  matiere: z.string().catch(""),
  dureeMinutes: z.coerce.number().int().positive().catch(120),
  consignes: z.string().catch(""),
  parties: z.array(partieSchema).min(1),
});

const corrigeSchema = z.array(
  z.object({
    numero: z.coerce.string(),
    reponse: z.string(),
    bareme: z.string().catch(""),
  }),
);

const rapportSchema = z.object({
  note: z.coerce.number().nonnegative(),
  sur: z.coerce.number().positive().catch(20),
  appreciation: z.string().catch(""),
  questions: z
    .array(
      z.object({
        numero: z.coerce.string(),
        points: z.coerce.number().nonnegative().catch(0),
        sur: z.coerce.number().nonnegative().catch(0),
        commentaire: z.string().catch(""),
      }),
    )
    .catch([]),
  pointsForts: z.array(z.string()).catch([]),
  difficultes: z.array(z.string()).catch([]),
  conseils: z.array(z.string()).catch([]),
  chapitresAReviser: z.array(z.string()).catch([]),
});

export type EpreuveIA = z.infer<typeof epreuveSchema>;
export type CorrigeIA = z.infer<typeof corrigeSchema>;
export type RapportCorrection = z.infer<typeof rapportSchema>;

export function parseEpreuve(value: unknown): EpreuveIA | null {
  const parsed = epreuveSchema.safeParse(value);
  return parsed.success ? parsed.data : null;
}

export function parseCorrige(value: unknown): CorrigeIA {
  const parsed = corrigeSchema.safeParse(value);
  return parsed.success ? parsed.data : [];
}

export function parseRapport(value: unknown): RapportCorrection | null {
  const parsed = rapportSchema.safeParse(value);
  return parsed.success ? parsed.data : null;
}

/** Gemini renvoie parfois le JSON entouré de ```json … ``` malgré le mode JSON. */
function parseJsonReply(text: string): unknown {
  const cleaned = text
    .trim()
    .replace(/^```(?:json)?\s*/i, "")
    .replace(/\s*```$/, "");
  try {
    return JSON.parse(cleaned);
  } catch {
    const start = cleaned.indexOf("{");
    const end = cleaned.lastIndexOf("}");
    if (start >= 0 && end > start) {
      try {
        return JSON.parse(cleaned.slice(start, end + 1));
      } catch {
        // Réponse tronquée ou mal formée : traité par l'appelant.
      }
    }
    return null;
  }
}

// ---------------------------------------------------------------------------
// Contexte : cours appris et épreuves de la banque
// ---------------------------------------------------------------------------

function normalize(text: string) {
  return text.normalize("NFD").replace(/[̀-ͯ]/g, "").toLowerCase();
}

/** Format officiel de l'examen visé, utilisé quand la banque ne contient pas
 *  encore d'épreuve publiée pour ce cours. */
function officialFormat(label: string): string {
  const n = normalize(label);
  if (/\b(tle|terminale|bac|baccalaureat)\b/.test(n))
    return "Baccalauréat (Terminale) : partie A « Évaluation des ressources » (exercices indépendants, environ 10 à 12 points), partie B « Évaluation des compétences » (situation-problème de la vie courante, environ 8 à 10 points). Total sur 20, durée 3 à 4 heures.";
  if (/\b(1ere|1re|premiere|probatoire)\b/.test(n))
    return "Probatoire (Première) : partie A « Évaluation des ressources » (exercices indépendants, environ 12 points), partie B « Évaluation des compétences » (situation-problème contextualisée, environ 8 points). Total sur 20, durée 2 à 3 heures.";
  if (/\b(3eme|3e|troisieme|bepc)\b/.test(n))
    return "BEPC (Troisième) : partie A « Évaluation des ressources » (activités numériques et géométriques, environ 12 points), partie B « Évaluation des compétences » (situation-problème, environ 8 points). Total sur 20, durée 2 heures.";
  return "Devoir surveillé : partie A « Évaluation des ressources » (questions de cours et exercices d'application), partie B « Évaluation des compétences » (situation-problème). Total sur 20, durée 2 heures.";
}

type ChapitreAppris = { id: string; titre: string; etat: string; lecons: string[] };

async function loadCours(supabase: Supabase, userId: string, programmeId: string) {
  const [{ data: programme }, { data: progression }] = await Promise.all([
    supabase
      .from("programmes")
      .select(
        "id, titre, description, classe_id, matieres(nom), classes(nom, niveau), chapitres(id, titre, ordre, concepts(id, titre, ordre, contenu_texte))",
      )
      .eq("id", programmeId)
      .maybeSingle(),
    supabase
      .from("progression_concepts")
      .select("concept_id")
      .eq("eleve_id", userId)
      .eq("termine", true),
  ]);
  if (!programme) throw new Error("Ce cours est introuvable ou ne vous est pas accessible.");

  const done = new Set((progression ?? []).map((p) => p.concept_id));
  const matiere = Array.isArray(programme.matieres) ? programme.matieres[0] : programme.matieres;
  const classe = Array.isArray(programme.classes) ? programme.classes[0] : programme.classes;
  const chapitres = [...(programme.chapitres ?? [])].sort((a, b) => a.ordre - b.ordre);
  return { programme, matiere, classe, chapitres, done };
}

/** Épreuves publiées par les enseignants pour ce cours ou cette classe : leur
 *  structure (durée, nombre et type de questions, barème) sert de modèle. */
async function loadBanque(
  supabase: Supabase,
  programmeId: string,
  classeId: string | null,
): Promise<string> {
  let query = supabase
    .from("examens")
    .select("id, titre, description, duree_minutes, mode_evaluation, nb_questions")
    .eq("statut", "publie")
    .order("created_at", { ascending: false })
    .limit(3);
  query = classeId
    ? query.or(`programme_id.eq.${programmeId},classe_id.eq.${classeId}`)
    : query.eq("programme_id", programmeId);
  const { data: examens } = await query;
  if (!examens || examens.length === 0) return "";

  const blocs = await Promise.all(
    examens.map(async (ex) => {
      const { data: questions } = await supabase.rpc("questions_examen", { p_examen_id: ex.id });
      const lignes = (questions ?? [])
        .slice(0, 12)
        .map((q) => `  - [${q.type}, ${q.points} pt] ${q.enonce.slice(0, 300)}`);
      return [
        `Épreuve « ${ex.titre} » (${ex.duree_minutes} min, ${ex.nb_questions} questions, mode ${ex.mode_evaluation})`,
        ex.description ? `  Description : ${ex.description.slice(0, 300)}` : "",
        ...lignes,
      ]
        .filter(Boolean)
        .join("\n");
    }),
  );
  return blocs.join("\n\n");
}

// ---------------------------------------------------------------------------
// Génération d'une épreuve
// ---------------------------------------------------------------------------

const SYSTEM_GENERATION = `Tu es Mandal IA, concepteur d'épreuves de la plateforme éducative M'ANDAL (Cameroun et Afrique francophone : BEPC, Probatoire, Baccalauréat).

Tu rédiges une épreuve d'entraînement originale pour un élève, à partir :
- des chapitres qu'il a étudiés (tu n'interroges QUE sur ces chapitres) ;
- de la structure des épreuves de la banque de son établissement quand elle est fournie (même découpage, même style de questions, même barème et même durée) ; sinon du format officiel indiqué.

RÈGLES
- Questions claires, numérotées, de difficulté progressive, avec des données numériques cohérentes et un contexte camerounais ou africain pour la situation-problème.
- Le total des points de toutes les questions fait 20.
- Formules en LaTeX : $...$ dans le texte. Pas d'autre Markdown que **gras** et les listes « - ».
- Rédige aussi le corrigé détaillé de chaque question avec le barème (répartition des points), pour la correction de la copie.

Réponds UNIQUEMENT avec un objet JSON de cette forme :
{
  "titre": "string",
  "niveau": "string (classe et examen visé)",
  "matiere": "string",
  "dureeMinutes": number,
  "consignes": "string (consignes générales, calculatrice autorisée ou non, etc.)",
  "parties": [
    { "titre": "Partie A : …", "points": number, "description": "string",
      "questions": [ { "numero": "1.a", "enonce": "string", "points": number } ] }
  ],
  "corrige": [ { "numero": "1.a", "reponse": "string (solution détaillée)", "bareme": "string" } ]
}`;

export const genererEpreuve = createServerFn({ method: "POST" })
  .middleware([requireSupabaseAuth])
  .inputValidator((data: unknown) =>
    z
      .object({
        programmeId: z.string().uuid(),
        chapitreIds: z.array(z.string().uuid()).min(1).max(30),
        precision: z.string().trim().max(500).optional(),
      })
      .parse(data),
  )
  .handler(async ({ data, context }) => {
    const { generateWithGemini } = await import("./gemini.server");
    const { programme, matiere, classe, chapitres, done } = await loadCours(
      context.supabase,
      context.userId,
      data.programmeId,
    );

    const selection = new Set(data.chapitreIds);
    const appris: ChapitreAppris[] = chapitres
      .filter((ch) => selection.has(ch.id))
      .map((ch) => {
        const concepts = [...(ch.concepts ?? [])].sort((a, b) => a.ordre - b.ordre);
        const n = concepts.filter((k) => done.has(k.id)).length;
        return {
          id: ch.id,
          titre: ch.titre,
          etat:
            n === 0
              ? "non commencé"
              : n === concepts.length
                ? "terminé"
                : `en cours (${n}/${concepts.length} leçons)`,
          lecons: concepts.map((k) => {
            const extrait = (k.contenu_texte ?? "").replace(/\s+/g, " ").slice(0, 400);
            return extrait ? `${k.titre} : ${extrait}` : k.titre;
          }),
        };
      });
    if (appris.length === 0) throw new Error("Choisissez au moins un chapitre de ce cours.");

    const niveauLabel = [programme.titre, classe?.nom, classe?.niveau].filter(Boolean).join(" ");
    const banque = await loadBanque(context.supabase, programme.id, programme.classe_id);

    const cours = appris
      .map((ch) => `## ${ch.titre} (${ch.etat})\n${ch.lecons.map((l) => `- ${l}`).join("\n")}`)
      .join("\n\n")
      .slice(0, 12000);

    const prompt = [
      `Cours : ${programme.titre}${matiere?.nom ? ` (${matiere.nom})` : ""}`,
      classe ? `Classe : ${[classe.nom, classe.niveau].filter(Boolean).join(" — ")}` : "",
      "",
      "CHAPITRES ÉTUDIÉS PAR L'ÉLÈVE",
      cours,
      "",
      banque
        ? `STRUCTURE DES ÉPREUVES DE LA BANQUE (à reproduire)\n${banque}`
        : `Aucune épreuve publiée dans la banque pour ce cours. Format officiel à suivre : ${officialFormat(niveauLabel)}`,
      data.precision ? `\nDemande particulière de l'élève : ${data.precision}` : "",
    ]
      .filter((l) => l !== undefined)
      .join("\n");

    const reply = await generateWithGemini({
      system: SYSTEM_GENERATION,
      messages: [{ role: "user", parts: [{ text: prompt }] }],
      maxOutputTokens: 16384,
      temperature: 0.7,
      responseMimeType: "application/json",
    });

    const json = parseJsonReply(reply) as Record<string, unknown> | null;
    const epreuve = parseEpreuve(json);
    if (!json || !epreuve) {
      console.error("[Mandal IA] épreuve illisible :", reply.slice(0, 500));
      throw new Error("Mandal IA n'a pas réussi à rédiger l'épreuve. Réessayez.");
    }
    const corrige = parseCorrige(json["corrige"]);

    const { data: saved, error } = await context.supabase
      .from("epreuves_ia")
      .insert({
        eleve_id: context.userId,
        programme_id: programme.id,
        titre: epreuve.titre,
        contenu: epreuve as unknown as Json,
        corrige: corrige as unknown as Json,
      })
      .select("id")
      .single();
    if (error) console.error("[Mandal IA] épreuve non enregistrée :", error.message);

    return { id: saved?.id ?? null, epreuve, sourceBanque: banque !== "" };
  });

// ---------------------------------------------------------------------------
// Correction d'une copie manuscrite (photos ou PDF)
// ---------------------------------------------------------------------------

/** Taille maximale de l'ensemble des fichiers encodés en base64 (la requête
 *  vers le serveur Vercel est limitée à 4,5 Mo). */
export const MAX_COPIE_BASE64 = 4_000_000;

const SYSTEM_CORRECTION = `Tu es Mandal IA, correcteur bienveillant mais rigoureux de la plateforme éducative M'ANDAL.

On te donne l'épreuve, son corrigé avec barème (s'il existe) et les photos ou le PDF de la copie manuscrite de l'élève.
- Lis attentivement l'écriture manuscrite, page par page. Si un passage est illisible, dis-le dans le commentaire de la question au lieu d'inventer.
- Note chaque question selon le barème : valorise la démarche même si le résultat final est faux. Une question non traitée vaut 0.
- La note finale est la somme des points obtenus, sur le total de l'épreuve (20 en général).
- Identifie précisément les difficultés rencontrées (notion mal comprise, erreur de calcul, rédaction, unités…) et donne des conseils concrets.
- Si les fichiers ne contiennent pas de copie d'élève, mets la note à 0 et explique-le dans "appreciation".
- Tutoie l'élève. Formules en LaTeX : $...$.

Réponds UNIQUEMENT avec un objet JSON de cette forme :
{
  "note": number, "sur": number, "appreciation": "string (2 phrases)",
  "questions": [ { "numero": "1.a", "points": number, "sur": number, "commentaire": "string" } ],
  "pointsForts": ["string"], "difficultes": ["string"], "conseils": ["string"],
  "chapitresAReviser": ["string (titre du chapitre du cours)"]
}`;

const fichierSchema = z.object({
  mimeType: z.string().regex(/^(image\/(jpeg|png|webp|heic|heif)|application\/pdf)$/),
  base64: z.string().min(1),
});

export const corrigerCopie = createServerFn({ method: "POST" })
  .middleware([requireSupabaseAuth])
  .inputValidator((data: unknown) =>
    z
      .object({
        epreuveId: z.string().uuid().nullable(),
        fichiers: z.array(fichierSchema).min(1).max(12),
      })
      .refine((d) => d.fichiers.reduce((n, f) => n + f.base64.length, 0) <= MAX_COPIE_BASE64, {
        message: "Copie trop volumineuse.",
      })
      .parse(data),
  )
  .handler(async ({ data, context }) => {
    const { generateWithGemini } = await import("./gemini.server");

    let sujet = "Aucune épreuve fournie : déduis le sujet de la copie elle-même.";
    let chapitres = "";
    if (data.epreuveId) {
      const { data: row } = await context.supabase
        .from("epreuves_ia")
        .select("contenu, corrige, programme_id")
        .eq("id", data.epreuveId)
        .eq("eleve_id", context.userId)
        .maybeSingle();
      if (!row) throw new Error("Épreuve introuvable.");
      const epreuve = parseEpreuve(row.contenu);
      const corrige = parseCorrige(row.corrige);
      if (epreuve) {
        sujet = [
          `ÉPREUVE : ${epreuve.titre} (${epreuve.niveau}, ${epreuve.matiere}, ${epreuve.dureeMinutes} min)`,
          ...epreuve.parties.map(
            (p) =>
              `${p.titre} (${p.points} pts)\n${p.questions.map((q) => `${q.numero}. [${q.points} pt] ${q.enonce}`).join("\n")}`,
          ),
          "",
          "CORRIGÉ ET BARÈME",
          ...corrige.map(
            (c) => `${c.numero}. ${c.reponse}${c.bareme ? ` (barème : ${c.bareme})` : ""}`,
          ),
        ].join("\n");
      }
      if (row.programme_id) {
        const { data: chs } = await context.supabase
          .from("chapitres")
          .select("titre, ordre")
          .eq("programme_id", row.programme_id)
          .order("ordre");
        chapitres = (chs ?? []).map((c) => `- ${c.titre}`).join("\n");
      }
    }

    const parts: AiPart[] = [
      {
        text: [
          sujet.slice(0, 20000),
          chapitres ? `\nCHAPITRES DU COURS (pour « chapitresAReviser »)\n${chapitres}` : "",
          `\nCOPIE DE L'ÉLÈVE : ${data.fichiers.length} fichier(s) ci-dessous, dans l'ordre des pages.`,
        ].join("\n"),
      },
      ...data.fichiers.map((f): AiPart => ({ file: { mimeType: f.mimeType, base64: f.base64 } })),
    ];

    const reply = await generateWithGemini({
      system: SYSTEM_CORRECTION,
      messages: [{ role: "user", parts }],
      maxOutputTokens: 16384,
      temperature: 0.2,
      responseMimeType: "application/json",
    });

    const rapport = parseRapport(parseJsonReply(reply));
    if (!rapport) {
      console.error("[Mandal IA] correction illisible :", reply.slice(0, 500));
      throw new Error("Mandal IA n'a pas réussi à corriger cette copie. Réessayez.");
    }

    const { error } = await context.supabase.from("corrections_ia").insert({
      eleve_id: context.userId,
      epreuve_id: data.epreuveId,
      note: rapport.note,
      sur: rapport.sur,
      rapport: rapport as unknown as Json,
      nb_pages: data.fichiers.length,
    });
    if (error) console.error("[Mandal IA] correction non enregistrée :", error.message);

    return { rapport };
  });
