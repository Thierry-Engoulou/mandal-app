import { createServerFn } from "@tanstack/react-start";
import { z } from "zod";
import { requireSupabaseAuth } from "@/integrations/supabase/auth-middleware";
import type { AiPart } from "./gemini.server";

// Gemini accepte ~20 Mo par requête (fichiers encodés en base64, +33 %).
const MAX_TOTAL_BYTES = 14 * 1024 * 1024;

const SYSTEM = `Tu es Mandal IA, assistant de correction pour les enseignants de la plateforme M'ANDAL (Cameroun et Afrique ; BEPC, Probatoire, Baccalauréat, GCE).

L'enseignant te transmet le sujet d'une épreuve (PDF ou images) et la copie manuscrite d'un élève (photos ou scan). Prépare une PROPOSITION de correction que l'enseignant validera.

RÈGLES
- Lis attentivement l'écriture manuscrite ; signale précisément les passages illisibles ou les pages qui semblent manquer.
- Suis le barème du sujet s'il est indiqué ; sinon propose un barème raisonnable et dis-le.
- Vérifie le raisonnement, les étapes, les unités et la rédaction, pas seulement les résultats.
- Reste factuel et prudent : c'est l'enseignant qui décide de la note finale.

FORMAT (respecte ces sous-titres)
## Note proposée
Note sur 20 et justification en une phrase.
## Détail par question
| Question | Points obtenus / barème | Remarque |
## Erreurs et difficultés
Liste « - ».
## Commentaire pour l'élève
Deux ou trois phrases bienveillantes que l'enseignant peut reprendre.

Formules en LaTeX : $...$ ou $$...$$ seul sur une ligne. Utilise seulement « ## », « - », **gras** et les tableaux.`;

/** Pré-correction d'une copie par Mandal IA, réservée à l'enseignant auteur de l'épreuve. */
export const preCorrigerComposition = createServerFn({ method: "POST" })
  .middleware([requireSupabaseAuth])
  .inputValidator((data: unknown) => z.object({ compositionId: z.string().uuid() }).parse(data))
  .handler(async ({ data, context }) => {
    const { generateWithGemini } = await import("./gemini.server");
    const db = context.supabase;

    // La RLS ne renvoie la composition qu'à l'élève ou à l'enseignant de l'épreuve.
    const { data: composition, error } = await db
      .from("compositions")
      .select(
        "id, eleve_id, fichiers, epreuves(enseignant_id, titre, matiere, niveau, consignes, fichier_path)",
      )
      .eq("id", data.compositionId)
      .maybeSingle();
    if (error) throw new Error(error.message);
    const epreuve = Array.isArray(composition?.epreuves)
      ? composition?.epreuves[0]
      : composition?.epreuves;
    if (!composition || !epreuve || composition.eleve_id === context.userId) {
      throw new Error("Copie introuvable.");
    }
    if (composition.fichiers.length === 0) {
      throw new Error("L'élève n'a envoyé aucune page.");
    }

    let total = 0;
    const download = async (bucket: string, path: string): Promise<AiPart> => {
      const { data: blob, error: dlError } = await db.storage.from(bucket).download(path);
      if (dlError || !blob) throw new Error("Impossible de lire un des fichiers.");
      total += blob.size;
      if (total > MAX_TOTAL_BYTES)
        throw new Error("Sujet et copie trop lourds pour une correction automatique.");
      const mimeType = blob.type || (path.endsWith(".pdf") ? "application/pdf" : "image/jpeg");
      return {
        file: { mimeType, base64: Buffer.from(await blob.arrayBuffer()).toString("base64") },
      };
    };

    const sujet = await download("epreuves", epreuve.fichier_path);
    const pages: AiPart[] = [];
    for (const p of composition.fichiers) pages.push(await download("compositions", p));

    const texte = await generateWithGemini({
      system: SYSTEM,
      messages: [
        {
          role: "user",
          parts: [
            {
              text: `Épreuve « ${epreuve.titre} » — ${epreuve.matiere}, niveau ${epreuve.niveau}.${
                epreuve.consignes ? `\nConsignes : ${epreuve.consignes}` : ""
              }\nVoici le sujet :`,
            },
            sujet,
            { text: `Voici la copie de l'élève (${pages.length} page(s)) :` },
            ...pages,
          ],
        },
      ],
      maxOutputTokens: 8192,
      temperature: 0.2,
    });

    const { error: saveError } = await db.rpc("enregistrer_correction_ia", {
      p_composition_id: composition.id,
      p_texte: texte,
    });
    if (saveError) throw new Error(saveError.message);
    return { texte };
  });
