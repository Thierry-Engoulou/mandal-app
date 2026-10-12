import { createServerFn } from "@tanstack/react-start";
import { z } from "zod";
import { requireSupabaseAuth } from "@/integrations/supabase/auth-middleware";

const SYSTEM = `Tu es Mandal IA, le conseiller d'orientation scolaire et académique de la plateforme M'ANDAL (systèmes éducatifs francophones et anglophones, Cameroun et Afrique).

DIRECTIVES STRICTES DE PÉRIMÈTRE :
1. Tu réponds UNIQUEMENT et EXCLUSIVEMENT aux questions liées à l'ÉDUCATION, aux SYSTÈMES ÉDUCATIFS (secondaire, université, grandes écoles) et à l'ORIENTATION SCOLAIRE ET PROFESSIONNELLE (séries A, C, D, TI, filières universitaires, débouchés, concours ENSPD, IUT, ENS, FASA, médecine, etc.).
2. Si l'utilisateur te pose une question hors du cadre éducatif ou de l'orientation scolaire (par exemple : politique partisane, divertissement hors sujet, potins, jeux d'argent, sujets non académiques), tu DOIS REFUSER COURTOISEMENT de répondre avec le message type suivant :
"Je suis Mandal IA, votre conseiller dédié exclusivement à l'éducation, aux cours et à l'orientation scolaire. Je ne peux répondre qu'aux questions relatives à votre parcours académique, vos filières ou vos examens."
3. Réponds toujours en français clair, bienveillant, précis et structuré (puces courtes, étapes d'admission claires, matières clés requises). Maximum 250 mots.`;

type GwMessage = { role: "user" | "assistant"; content: string };

function extractText(payload: unknown): string {
  const p = payload as {
    output_text?: string;
    output?: Array<{ content?: Array<{ text?: string; type?: string }> }>;
  };
  if (typeof p.output_text === "string" && p.output_text.trim()) return p.output_text;
  const parts = p.output?.flatMap((o) => o.content ?? []) ?? [];
  const text = parts
    .map((c) => (typeof c.text === "string" ? c.text : ""))
    .join("")
    .trim();
  return text || "Je n'ai pas pu formuler de réponse. Reformulez votre question.";
}

export const askOrientationAdvisor = createServerFn({ method: "POST" })
  .middleware([requireSupabaseAuth])
  .inputValidator((data: unknown) => z.object({ message: z.string().min(1).max(2000) }).parse(data))
  .handler(async ({ data, context }) => {
    const apiKey = process.env["LOVABLE_API_KEY"];
    if (!apiKey) throw new Error("Le conseiller IA n'est pas configuré.");

    const { data: history } = await context.supabase
      .from("orientation_messages")
      .select("role, contenu")
      .eq("eleve_id", context.userId)
      .order("created_at", { ascending: true })
      .limit(30);

    const messages: GwMessage[] = [
      ...((history ?? []).map((m) => ({
        role: m.role === "assistant" ? "assistant" : "user",
        content: m.contenu,
      })) as GwMessage[]),
      { role: "user", content: data.message },
    ];

    const res = await fetch("https://ai.gateway.lovable.dev/v1/responses", {
      method: "POST",
      headers: { "Content-Type": "application/json", Authorization: `Bearer ${apiKey}` },
      body: JSON.stringify({
        model: "openai/gpt-6-astra",
        instructions: SYSTEM,
        input: messages,
        reasoning: { effort: "low" },
      }),
    });

    if (!res.ok) {
      const detail = await res.text();
      if (res.status === 429) throw new Error("Trop de demandes au conseiller, réessayez dans un instant.");
      if (res.status === 402) throw new Error("Crédits IA épuisés pour cet espace.");
      throw new Error(`Le conseiller IA est indisponible (${res.status}). ${detail.slice(0, 200)}`);
    }

    const reply = extractText(await res.json());

    await context.supabase.from("orientation_messages").insert([
      { eleve_id: context.userId, role: "user", contenu: data.message },
      { eleve_id: context.userId, role: "assistant", contenu: reply },
    ]);

    return { reply };
  });
