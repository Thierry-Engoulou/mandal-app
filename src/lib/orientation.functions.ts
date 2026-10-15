import { createServerFn } from "@tanstack/react-start";
import { z } from "zod";
import { requireSupabaseAuth } from "@/integrations/supabase/auth-middleware";
import type { AiMessage } from "./gemini.server";

const SYSTEM = `Tu es Mandal IA, le conseiller d'orientation scolaire et académique de la plateforme M'ANDAL (systèmes éducatifs francophones et anglophones, Cameroun et Afrique).

DIRECTIVES STRICTES DE PÉRIMÈTRE :
1. Tu réponds UNIQUEMENT et EXCLUSIVEMENT aux questions liées à l'ÉDUCATION, aux SYSTÈMES ÉDUCATIFS (secondaire, université, grandes écoles) et à l'ORIENTATION SCOLAIRE ET PROFESSIONNELLE (séries A, C, D, TI, filières universitaires, débouchés, concours ENSPD, IUT, ENS, FASA, médecine, etc.).
2. Si l'utilisateur te pose une question hors du cadre éducatif ou de l'orientation scolaire (par exemple : politique partisane, divertissement hors sujet, potins, jeux d'argent, sujets non académiques), tu DOIS REFUSER COURTOISEMENT de répondre avec le message type suivant :
"Je suis Mandal IA, votre conseiller dédié exclusivement à l'éducation, aux cours et à l'orientation scolaire. Je ne peux répondre qu'aux questions relatives à votre parcours académique, vos filières ou vos examens."
3. Réponds dans la langue de l'élève (français par défaut, anglais s'il écrit en anglais), de façon claire, bienveillante, précise et structurée (puces courtes, étapes d'admission claires, matières clés requises). Maximum 300 mots, sources comprises.
4. Tiens compte de la réalité camerounaise : sous-systèmes francophone et anglophone, examens (BEPC, CAP, Probatoire, Baccalauréat, GCE), universités d'État, grandes écoles, BTS/HND, formation professionnelle, emploi local.

FORMAT : sous-titres « ## Titre », listes « - élément » et **gras** uniquement.`;

export const askOrientationAdvisor = createServerFn({ method: "POST" })
  .middleware([requireSupabaseAuth])
  .inputValidator((data: unknown) => z.object({ message: z.string().min(1).max(2000) }).parse(data))
  .handler(async ({ data, context }) => {
    const { generateWithGemini } = await import("./gemini.server");
    const { fichesPourQuestion, CONSIGNES_SOURCES } = await import("./orientation-fiches.server");

    const { data: history } = await context.supabase
      .from("orientation_messages")
      .select("role, contenu")
      .eq("eleve_id", context.userId)
      .order("created_at", { ascending: false })
      .limit(30);
    const fiches = await fichesPourQuestion(context.supabase, data.message, 5);

    const messages: AiMessage[] = [
      ...(history ?? []).reverse().map((m): AiMessage => ({
        role: m.role === "assistant" ? "assistant" : "user",
        parts: [{ text: m.contenu }],
      })),
      { role: "user", parts: [{ text: data.message }] },
    ];

    const reply = await generateWithGemini({
      system: `${SYSTEM}\n\n${CONSIGNES_SOURCES}\n\nFICHES DE LA BASE M'ANDAL\n${
        fiches ||
        "Aucune fiche ne correspond : cite seulement les institutions officielles compétentes."
      }`,
      messages,
      maxOutputTokens: 2048,
    });

    await context.supabase.from("orientation_messages").insert([
      { eleve_id: context.userId, role: "user", contenu: data.message },
      { eleve_id: context.userId, role: "assistant", contenu: reply },
    ]);

    return { reply };
  });
