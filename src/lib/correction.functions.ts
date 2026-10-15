import { createServerFn } from "@tanstack/react-start";
import { z } from "zod";
import { requireSupabaseAuth } from "@/integrations/supabase/auth-middleware";
import type { AiPart } from "./gemini.server";

export const COPIES_BUCKET = "copies-eleves";

// Gemini accepte ~20 Mo par requête (fichiers encodés en base64, +33 %).
const MAX_TOTAL_BYTES = 14 * 1024 * 1024;

const SYSTEM = `Tu es Mandal IA, le répétiteur numérique de la plateforme éducative M'ANDAL (Cameroun et Afrique ; BEPC, Probatoire, Baccalauréat, GCE, concours).

Un élève t'envoie les photos ou le scan de sa copie (et parfois le sujet). Tu la corriges comme un enseignant bienveillant mais exigeant.

RÈGLES
- Lis attentivement l'écriture manuscrite. Si une partie est illisible ou coupée, dis-le précisément et demande une meilleure photo de cette partie plutôt que de deviner.
- Si le sujet n'est pas fourni, déduis-le de la copie et dis-le.
- Si les fichiers ne sont pas un travail scolaire, réponds seulement : « Je ne peux corriger que des copies de devoirs, d'exercices ou d'examens. »
- Ne te contente pas de la réponse finale : vérifie le raisonnement, les étapes, les unités, la rédaction.
- Sois honnête : ne félicite pas un travail faux, mais encourage toujours.
- Fais le lien avec les cours de l'élève (voir « Profil de l'élève ») pour indiquer quoi revoir.

FORMAT DE LA RÉPONSE (respecte ces sous-titres, dans cet ordre)
## Note estimée
Une note sur 20 avec une phrase de justification (ou « non notable » si la copie est trop incomplète ou illisible).
## Correction détaillée
Question par question : ce qui est juste, ce qui est faux, et la bonne démarche avec les calculs.
## Tes difficultés
Liste « - » des difficultés observées (notions mal maîtrisées, erreurs de calcul, rédaction, méthode, temps…).
## À revoir
Liste « - » des leçons ou chapitres précis à retravailler, et un exercice d'entraînement court.
## Conseil
Une ou deux phrases pour progresser.

Formules en LaTeX : $...$ dans le texte, $$...$$ seul sur une ligne. Utilise seulement « ## », « - », **gras** et les tableaux « | a | b | ». Réponds en français (en anglais si la copie est en anglais).`;

const pathSchema = z.string().min(1).max(300);

export const corrigerCopie = createServerFn({ method: "POST" })
  .middleware([requireSupabaseAuth])
  .inputValidator((data: unknown) =>
    z
      .object({
        matiere: z.string().trim().max(80).optional(),
        sujetTexte: z.string().trim().max(4000).optional(),
        copies: z.array(pathSchema).min(1).max(8),
        sujets: z.array(pathSchema).max(4).default([]),
      })
      .parse(data),
  )
  .handler(async ({ data, context }) => {
    const { generateWithGemini } = await import("./gemini.server");
    const { buildStudentContext } = await import("./student-context.server");

    // Chaque élève ne peut envoyer que ses propres fichiers (dossier = son id).
    const allPaths = [...data.sujets, ...data.copies];
    if (allPaths.some((p) => !p.startsWith(`${context.userId}/`) || p.includes(".."))) {
      throw new Error("Fichier non autorisé.");
    }

    let total = 0;
    const download = async (path: string): Promise<AiPart> => {
      const { data: blob, error } = await context.supabase.storage
        .from(COPIES_BUCKET)
        .download(path);
      if (error || !blob) throw new Error("Impossible de lire un des fichiers envoyés.");
      total += blob.size;
      if (total > MAX_TOTAL_BYTES)
        throw new Error(
          "Fichiers trop lourds : envoyez moins de pages ou des photos plus légères.",
        );
      const mimeType = blob.type || (path.endsWith(".pdf") ? "application/pdf" : "image/jpeg");
      const base64 = Buffer.from(await blob.arrayBuffer()).toString("base64");
      return { file: { mimeType, base64 } };
    };

    const sujetParts: AiPart[] = [];
    for (const p of data.sujets) sujetParts.push(await download(p));
    const copieParts: AiPart[] = [];
    for (const p of data.copies) copieParts.push(await download(p));

    const intro = [
      data.matiere ? `Matière : ${data.matiere}.` : null,
      data.sujetTexte ? `Énoncé donné par l'élève :\n${data.sujetTexte}` : null,
      sujetParts.length > 0 ? "Voici le sujet :" : "Le sujet n'est pas fourni en fichier.",
    ]
      .filter(Boolean)
      .join("\n");

    const studentContext = await buildStudentContext(context.supabase, context.userId);
    const correction = await generateWithGemini({
      system: `${SYSTEM}\n\nPROFIL DE L'ÉLÈVE (cours suivis sur M'ANDAL)\n${studentContext || "Aucune information de cours disponible."}`,
      messages: [
        {
          role: "user",
          parts: [
            { text: intro },
            ...sujetParts,
            { text: `Voici ma copie (${copieParts.length} page(s)). Corrige-la.` },
            ...copieParts,
          ],
        },
      ],
      maxOutputTokens: 8192,
      temperature: 0.2,
    });

    const { data: row, error } = await context.supabase
      .from("corrections_ia")
      .insert({
        eleve_id: context.userId,
        matiere: data.matiere || null,
        sujet_texte: data.sujetTexte || null,
        fichiers_copie: data.copies,
        fichiers_sujet: data.sujets,
        correction,
      })
      .select("id")
      .single();
    if (error) console.error("[Correction IA] non enregistrée :", error.message);

    return { id: row?.id ?? null, correction };
  });
