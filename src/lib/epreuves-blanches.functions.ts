import { createServerFn } from "@tanstack/react-start";
import { z } from "zod";
import { requireSupabaseAuth } from "@/integrations/supabase/auth-middleware";
import type { AiPart } from "./gemini.server";

// Modèles d'épreuves envoyés à l'IA : 2 au plus, ~10 Mo au total.
const MAX_MODELES = 2;
const MAX_MODELES_BYTES = 10 * 1024 * 1024;

const SYSTEM = `Tu es Mandal IA, le répétiteur numérique de M'ANDAL (Cameroun et Afrique ; BEPC, Probatoire, Baccalauréat, GCE, concours).

Tu rédiges une ÉPREUVE BLANCHE ORIGINALE pour entraîner un élève.

STRUCTURE
- Si des « épreuves modèles » de la banque M'ANDAL sont jointes : reproduis fidèlement leur STRUCTURE (en-tête, nombre de parties et d'exercices, répartition des points, types de questions, longueur, niveau de difficulté, style de rédaction). N'en recopie JAMAIS le contenu : invente des énoncés nouveaux.
- Sinon : suis la structure officielle camerounaise du niveau (approche par les compétences) : « Partie A : Évaluation des ressources » (savoirs et savoir-faire, exercices indépendants) puis « Partie B : Évaluation des compétences » (une situation-problème contextualisée avec des tâches), total sur 20 points.
- Le barème de chaque exercice et de chaque question est indiqué ; le total fait 20 points. La longueur est adaptée à la durée demandée.

CONTENU
- Porte en priorité sur les chapitres que l'élève a terminés ou commencés (voir « Profil de l'élève ») ; si aucun cours n'est indiqué, couvre le programme du niveau.
- Données numériques réalistes, contextes africains / camerounais pour les situations-problèmes.
- Vérifie que chaque question est faisable et que les résultats tombent juste.
- Ne donne PAS les solutions ni d'indices.

FORMAT (le site affiche ce format)
- Première ligne : « ## » + titre de l'épreuve.
- Puis une ligne « **Matière** : … · **Niveau** : … · **Durée** : … » et, si utile, une ligne de consignes.
- Chaque partie : « ## Partie … (x points) » ; chaque exercice en **gras** avec son barème ; questions numérotées « 1. », « 2. », sous-questions « a) », « b) ».
- Formules en LaTeX : $...$ dans le texte, $$...$$ seul sur une ligne. Tableaux de valeurs avec « | a | b | ». Pas d'autre syntaxe Markdown.`;

export const genererEpreuveBlanche = createServerFn({ method: "POST" })
  .middleware([requireSupabaseAuth])
  .inputValidator((data: unknown) =>
    z
      .object({
        matiere: z.string().trim().min(1).max(80),
        niveau: z.string().trim().min(1).max(80),
        dureeMinutes: z.number().int().min(30).max(300),
        theme: z.string().trim().max(500).optional(),
      })
      .parse(data),
  )
  .handler(async ({ data, context }) => {
    const { verifierQuotaIA } = await import("./quota-ia.server");
    await verifierQuotaIA(context.supabase, "epreuves_generees", context.userId);
    const { generateWithGemini } = await import("./gemini.server");
    const { buildStudentContext } = await import("./student-context.server");
    const db = context.supabase;

    // Modèles : épreuves de la banque d'épreuves (annales publiées) et épreuves
    // déposées par les enseignants, de la même matière et du même niveau.
    const { CLASSES_PAR_NIVEAU, BANQUE_BUCKET } = await import("./banque-constantes");
    const classes = CLASSES_PAR_NIVEAU[data.niveau] ?? [];
    const [{ data: annales }, { data: deposees }] = await Promise.all([
      classes.length
        ? db
            .from("banque_epreuves")
            .select("titre, fichier_path")
            .eq("statut", "publiee")
            .eq("matiere", data.matiere)
            .in("classe", classes)
            .order("annee", { ascending: false, nullsFirst: false })
            .limit(MAX_MODELES)
        : Promise.resolve({ data: [] as { titre: string; fichier_path: string }[] }),
      db
        .from("epreuves")
        .select("titre, fichier_path")
        .eq("statut", "publiee")
        .eq("niveau", data.niveau)
        .eq("matiere", data.matiere)
        .order("created_at", { ascending: false })
        .limit(MAX_MODELES),
    ]);
    const modeles = [
      ...(annales ?? []).map((m) => ({ ...m, bucket: BANQUE_BUCKET })),
      ...(deposees ?? []).map((m) => ({ ...m, bucket: "epreuves" })),
    ].slice(0, MAX_MODELES);

    const parts: AiPart[] = [];
    let total = 0;
    for (const m of modeles) {
      const { data: blob } = await db.storage.from(m.bucket).download(m.fichier_path);
      if (!blob || total + blob.size > MAX_MODELES_BYTES) continue;
      total += blob.size;
      const mimeType =
        blob.type || (m.fichier_path.endsWith(".pdf") ? "application/pdf" : "image/jpeg");
      parts.push({ text: `Épreuve modèle « ${m.titre} » :` });
      parts.push({
        file: { mimeType, base64: Buffer.from(await blob.arrayBuffer()).toString("base64") },
      });
    }
    const nbModeles = parts.length / 2;

    const studentContext = await buildStudentContext(db, context.userId);
    const demande = [
      `Rédige une épreuve blanche de ${data.matiere}, niveau ${data.niveau}, durée ${data.dureeMinutes} minutes.`,
      data.theme ? `L'élève souhaite insister sur : ${data.theme}.` : null,
      nbModeles > 0
        ? `${nbModeles} épreuve(s) modèle(s) de la banque M'ANDAL sont jointes : reprends leur structure.`
        : "Aucune épreuve modèle n'est disponible : suis la structure officielle du niveau.",
    ]
      .filter(Boolean)
      .join("\n");

    const contenu = await generateWithGemini({
      system: `${SYSTEM}\n\nPROFIL DE L'ÉLÈVE (cours suivis sur M'ANDAL)\n${studentContext || "Aucune information de cours disponible."}`,
      messages: [{ role: "user", parts: [{ text: demande }, ...parts] }],
      maxOutputTokens: 8192,
      temperature: 0.7,
    });

    const { data: row, error } = await db
      .from("epreuves_generees")
      .insert({
        eleve_id: context.userId,
        matiere: data.matiere,
        niveau: data.niveau,
        duree_minutes: data.dureeMinutes,
        contenu,
        modeles_utilises: nbModeles,
      })
      .select("id")
      .single();
    if (error) throw new Error(error.message);

    return { id: row.id, contenu, modelesUtilises: nbModeles };
  });
