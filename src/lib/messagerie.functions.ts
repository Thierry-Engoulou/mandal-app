import { createServerFn } from "@tanstack/react-start";
import { z } from "zod";
import type { SupabaseClient } from "@supabase/supabase-js";
import { requireSupabaseAuth } from "@/integrations/supabase/auth-middleware";
import type { Database } from "@/integrations/supabase/types";
import type { AiMessage, AiPart } from "./gemini.server";

// Demandes à Mandal IA dans les salons : quota gratuit Gemini partagé par tous.
const MAX_DEMANDES_SALON_PAR_JOUR = 20;
const MAX_FICHIERS_BYTES = 14 * 1024 * 1024;

const FORMAT = `Formules en LaTeX : $...$ dans le texte, $$...$$ seul sur une ligne. Utilise seulement « ## », « - », **gras** et les tableaux « | a | b | ». Réponds en français (en anglais si on t'écrit en anglais).`;

const SYSTEM_SALON = `Tu es Mandal IA, le répétiteur numérique de M'ANDAL, dans un salon de discussion où les élèves et les enseignants d'une même matière et d'un même niveau échangent.

- On te sollicite pour répondre au DERNIER message du salon (en t'aidant des messages précédents pour le contexte).
- Tu réponds uniquement aux questions d'éducation, de cours, d'exercices, d'examens et d'orientation. Pour tout autre sujet, rappelle poliment que le salon est réservé au travail scolaire.
- Si un enseignant a déjà répondu, appuie-toi sur sa réponse et ne la contredis pas sans l'expliquer.
- Sois clair, pédagogique et concis (200 mots maximum).
${FORMAT}`;

const SYSTEM_FIL = `Tu es Mandal IA, le répétiteur numérique de M'ANDAL. Tu réponds dans le fil privé entre un élève et l'enseignant qui a donné une épreuve, parce que l'enseignant n'est pas disponible pour le moment.

- Le sujet de l'épreuve est joint. L'élève peut poser une question sur un énoncé ou signaler une erreur possible dans le sujet.
- Si l'élève signale une erreur : vérifie honnêtement l'énoncé. Si l'erreur est réelle, dis-le, propose l'interprétation la plus raisonnable, et précise que l'enseignant confirmera. Si ce n'est pas une erreur, explique pourquoi.
- Si l'épreuve est EN COURS pour cet élève (voir état), ne donne AUCUNE réponse aux questions : clarifie seulement l'énoncé, comme le ferait un surveillant.
- Sinon, aide comme un répétiteur (méthode, pistes, correction expliquée).
- Termine en rappelant que l'enseignant verra cet échange et pourra confirmer ou corriger.
- 250 mots maximum.
${FORMAT}`;

const SYSTEM_CORRECTION = `Tu es Mandal IA, le répétiteur numérique de M'ANDAL. L'enseignant n'a pas encore corrigé la copie : tu rédiges une CORRECTION PROVISOIRE que l'enseignant vérifiera ensuite.

- Le sujet et les pages de la copie manuscrite de l'élève sont joints. Lis attentivement l'écriture ; signale les passages illisibles au lieu de deviner.
- Vérifie le raisonnement et les étapes, pas seulement les résultats. Sois honnête et bienveillant.

FORMAT (respecte ces sous-titres)
## Correction provisoire de Mandal IA
Une phrase rappelant qu'elle sera vérifiée par l'enseignant.
## Note estimée
Note sur 20 avec une phrase de justification.
## Détail par question
Ce qui est juste, ce qui est faux, et la bonne démarche.
## Tes difficultés
Liste « - ».
## À revoir
Liste « - » de notions et un exercice d'entraînement court.
${FORMAT}`;

async function getAdmin() {
  const { supabaseAdmin } = await import("@/integrations/supabase/client.server");
  return supabaseAdmin;
}

type DbClient = SupabaseClient<Database>;

// ---------------------------------------------------------------------------
// Salons de matière
// ---------------------------------------------------------------------------
export const demanderIASalon = createServerFn({ method: "POST" })
  .middleware([requireSupabaseAuth])
  .inputValidator((data: unknown) =>
    z
      .object({
        matiere: z.string().trim().min(1).max(80),
        niveau: z.string().trim().min(1).max(80),
      })
      .parse(data),
  )
  .handler(async ({ data, context }) => {
    const { generateWithGemini } = await import("./gemini.server");
    const admin = await getAdmin();

    const depuis = new Date(Date.now() - 24 * 3600 * 1000).toISOString();
    const { count } = await admin
      .from("salon_messages")
      .select("id", { count: "exact", head: true })
      .eq("demande_par", context.userId)
      .gte("created_at", depuis);
    if ((count ?? 0) >= MAX_DEMANDES_SALON_PAR_JOUR) {
      throw new Error(
        `Tu as déjà sollicité Mandal IA ${MAX_DEMANDES_SALON_PAR_JOUR} fois aujourd'hui dans les salons. Utilise la page Mandal IA ou réessaie demain.`,
      );
    }

    const { data: recents, error } = await context.supabase
      .from("salon_messages")
      .select("auteur_nom, auteur_role, contenu")
      .eq("matiere", data.matiere)
      .eq("niveau", data.niveau)
      .order("created_at", { ascending: false })
      .limit(15);
    if (error) throw new Error(error.message);
    if (!recents || recents.length === 0)
      throw new Error("Pose d'abord ta question dans le salon.");

    const conversation = recents
      .reverse()
      .map((m) => {
        const qui =
          m.auteur_role === "ia"
            ? "Mandal IA"
            : `${m.auteur_nom} (${m.auteur_role === "enseignant" ? "enseignant" : "élève"})`;
        return `${qui} : ${m.contenu}`;
      })
      .join("\n\n");

    const reponse = await generateWithGemini({
      system: `${SYSTEM_SALON}\n\nSalon : ${data.matiere} — ${data.niveau}.`,
      messages: [{ role: "user", parts: [{ text: `Messages du salon :\n\n${conversation}` }] }],
      maxOutputTokens: 2048,
    });

    const { error: insertError } = await admin.from("salon_messages").insert({
      matiere: data.matiere,
      niveau: data.niveau,
      auteur_id: null,
      auteur_nom: "Mandal IA",
      auteur_role: "ia",
      demande_par: context.userId,
      contenu: reponse,
    });
    if (insertError) throw new Error(insertError.message);
    return { ok: true };
  });

// ---------------------------------------------------------------------------
// Fils privés par épreuve
// ---------------------------------------------------------------------------
type FilContext = {
  conversation: { id: string; eleve_id: string; enseignant_id: string | null };
  epreuve: {
    id: string;
    titre: string;
    matiere: string;
    niveau: string;
    consignes: string | null;
    fichier_path: string;
  };
  composition: {
    fin_prevue_at: string;
    rendu_at: string | null;
    note: number | null;
    commentaire: string | null;
    fichiers: string[];
  } | null;
};

/** Charge le fil (la RLS garantit que l'appelant est l'élève du fil). */
async function chargerFil(db: DbClient, userId: string, conversationId: string) {
  const { data: conversation, error } = await db
    .from("conversations")
    .select("id, eleve_id, enseignant_id, epreuve_id")
    .eq("id", conversationId)
    .maybeSingle();
  if (error) throw new Error(error.message);
  if (!conversation || !conversation.epreuve_id || conversation.eleve_id !== userId) {
    throw new Error("Fil introuvable.");
  }
  const [{ data: epreuve }, { data: composition }] = await Promise.all([
    db
      .from("epreuves")
      .select("id, titre, matiere, niveau, consignes, fichier_path")
      .eq("id", conversation.epreuve_id)
      .maybeSingle(),
    db
      .from("compositions")
      .select("fin_prevue_at, rendu_at, note, commentaire, fichiers")
      .eq("epreuve_id", conversation.epreuve_id)
      .eq("eleve_id", userId)
      .maybeSingle(),
  ]);
  if (!epreuve) throw new Error("Épreuve introuvable.");
  return { conversation, epreuve, composition } satisfies FilContext;
}

async function telecharger(
  db: DbClient,
  bucket: string,
  path: string,
  budget: { total: number },
): Promise<AiPart> {
  const { data: blob, error } = await db.storage.from(bucket).download(path);
  if (error || !blob) throw new Error("Impossible de lire un des fichiers.");
  budget.total += blob.size;
  if (budget.total > MAX_FICHIERS_BYTES) throw new Error("Fichiers trop lourds pour Mandal IA.");
  const mimeType = blob.type || (path.endsWith(".pdf") ? "application/pdf" : "image/jpeg");
  return { file: { mimeType, base64: Buffer.from(await blob.arrayBuffer()).toString("base64") } };
}

function etatComposition(c: FilContext["composition"]) {
  if (!c) return "L'élève n'a pas encore commencé l'épreuve.";
  if (c.note !== null) return `Copie corrigée par l'enseignant : ${c.note}/20.`;
  const fin = new Date(c.fin_prevue_at).getTime();
  if (!c.rendu_at && Date.now() <= fin) return "ÉPREUVE EN COURS pour cet élève.";
  return "Épreuve terminée, copie rendue, pas encore corrigée par l'enseignant.";
}

async function posterReponseIA(conversationId: string, contenu: string) {
  const admin = await getAdmin();
  const { error } = await admin
    .from("messages")
    .insert({ conversation_id: conversationId, sender_id: null, auteur_ia: true, contenu });
  if (error) throw new Error(error.message);
  await admin
    .from("conversations")
    .update({ updated_at: new Date().toISOString() })
    .eq("id", conversationId);
}

/** Réponse de Mandal IA dans un fil d'épreuve. `auto` : seulement si l'enseignant
 *  s'est déclaré indisponible. */
export const repondreIAFil = createServerFn({ method: "POST" })
  .middleware([requireSupabaseAuth])
  .inputValidator((data: unknown) =>
    z.object({ conversationId: z.string().uuid(), auto: z.boolean().default(false) }).parse(data),
  )
  .handler(async ({ data, context }) => {
    const db = context.supabase;
    const fil = await chargerFil(db, context.userId, data.conversationId);

    if (data.auto) {
      const { data: dispo } = await db
        .from("enseignant_disponibilite")
        .select("disponible")
        .eq("enseignant_id", fil.conversation.enseignant_id ?? "")
        .maybeSingle();
      if (dispo?.disponible !== false) return { answered: false };
    }

    const { generateWithGemini } = await import("./gemini.server");
    const { data: historique } = await db
      .from("messages")
      .select("sender_id, auteur_ia, contenu")
      .eq("conversation_id", fil.conversation.id)
      .order("created_at", { ascending: false })
      .limit(20);

    const messages: AiMessage[] = (historique ?? []).reverse().map((m) => ({
      role: m.auteur_ia ? "assistant" : "user",
      parts: [
        {
          text: m.auteur_ia
            ? m.contenu
            : `${m.sender_id === fil.conversation.eleve_id ? "Élève" : "Enseignant"} : ${m.contenu}`,
        },
      ],
    }));
    if (messages.length === 0 || messages[messages.length - 1]!.role !== "user") {
      throw new Error("Écris d'abord ta question.");
    }

    const sujet = await telecharger(db, "epreuves", fil.epreuve.fichier_path, { total: 0 });
    messages[0] = {
      ...messages[0]!,
      parts: [
        {
          text: `Épreuve « ${fil.epreuve.titre} » (${fil.epreuve.matiere}, ${fil.epreuve.niveau}).${
            fil.epreuve.consignes ? ` Consignes : ${fil.epreuve.consignes}` : ""
          }\nÉtat : ${etatComposition(fil.composition)}\nSujet :`,
        },
        sujet,
        ...messages[0]!.parts,
      ],
    };

    const reponse = await generateWithGemini({
      system: SYSTEM_FIL,
      messages,
      maxOutputTokens: 2048,
    });
    await posterReponseIA(fil.conversation.id, reponse);
    return { answered: true };
  });

/** Correction provisoire de la copie par Mandal IA, en attendant l'enseignant. */
export const correctionProvisoireIA = createServerFn({ method: "POST" })
  .middleware([requireSupabaseAuth])
  .inputValidator((data: unknown) => z.object({ conversationId: z.string().uuid() }).parse(data))
  .handler(async ({ data, context }) => {
    const db = context.supabase;
    const fil = await chargerFil(db, context.userId, data.conversationId);
    const c = fil.composition;
    if (!c) throw new Error("Tu n'as pas composé cette épreuve.");
    if (c.note !== null) throw new Error("Ton enseignant a déjà corrigé ta copie.");
    if (!c.rendu_at && Date.now() <= new Date(c.fin_prevue_at).getTime()) {
      throw new Error("Rends d'abord ta copie.");
    }
    if (c.fichiers.length === 0) throw new Error("Ta copie ne contient aucune page.");

    const { generateWithGemini } = await import("./gemini.server");
    const budget = { total: 0 };
    const sujet = await telecharger(db, "epreuves", fil.epreuve.fichier_path, budget);
    const pages: AiPart[] = [];
    for (const p of c.fichiers) pages.push(await telecharger(db, "compositions", p, budget));

    const correction = await generateWithGemini({
      system: SYSTEM_CORRECTION,
      messages: [
        {
          role: "user",
          parts: [
            {
              text: `Épreuve « ${fil.epreuve.titre} » (${fil.epreuve.matiere}, ${fil.epreuve.niveau}). Sujet :`,
            },
            sujet,
            { text: `Copie de l'élève (${pages.length} page(s)) :` },
            ...pages,
          ],
        },
      ],
      maxOutputTokens: 8192,
      temperature: 0.2,
    });

    await posterReponseIA(fil.conversation.id, correction);
    return { ok: true };
  });
