// Appel à l'API Google Gemini (serveur uniquement : la clé ne doit jamais
// atteindre le navigateur). Modèle configurable via GEMINI_MODEL pour pouvoir
// changer de modèle (ou passer à l'offre payante) sans toucher au code.

export type AiPart = { text: string } | { file: { mimeType: string; base64: string } };

export type AiMessage = { role: "user" | "assistant"; parts: AiPart[] };

/** Ligne ajoutée à la fin de chaque réponse de Mandal IA. */
export const SIGNATURE = "Apprendre avec sourire et rigueur avec Mandal";
const SIGNATURE_FIN = new RegExp(`\\s*(?:\\*\\*)?${SIGNATURE}(?:\\*\\*)?[.!]?\\s*$`);

/** Retire la signature (pour ne pas la renvoyer au modèle dans l'historique). */
export function sansSignature(text: string): string {
  return text.replace(SIGNATURE_FIN, "").trimEnd();
}

function signer(text: string): string {
  return `${sansSignature(text)}\n\n**${SIGNATURE}**`;
}

const API = "https://generativelanguage.googleapis.com/v1beta";
const DEFAULT_MODEL = "gemini-flash-latest";

// Codes pour lesquels on réessaie avec un autre modèle : surcharge (503),
// erreur interne (500), délai (504) ou quota gratuit du modèle épuisé (429 :
// chaque modèle a son propre quota).
const RETRYABLE = new Set([429, 500, 503, 504]);
const MAX_TENTATIVES = 5;

// Modèles « Flash » proposés à cette clé (mémorisés tant que le serveur tourne).
let discoveredModels: string[] | null = null;

/** Modèles Flash disponibles pour cette clé, du plus récent au plus ancien,
 *  puis les variantes « lite » (les noms changent souvent chez Google). */
async function discoverFlashModels(apiKey: string): Promise<string[]> {
  if (discoveredModels) return discoveredModels;
  try {
    const res = await fetch(`${API}/models?pageSize=200`, {
      headers: { "x-goog-api-key": apiKey },
    });
    if (!res.ok) return [];
    const { models = [] } = (await res.json()) as {
      models?: Array<{ name: string; supportedGenerationMethods?: string[] }>;
    };
    const names = models
      .filter((m) => m.supportedGenerationMethods?.includes("generateContent"))
      .map((m) => m.name.replace(/^models\//, ""));
    const version = (n: string) => parseFloat(n.slice("gemini-".length));
    const byVersion = (a: string, b: string) => version(b) - version(a);
    const flash = names.filter((n) => /^gemini-[\d.]+-flash$/.test(n)).sort(byVersion);
    const lite = names.filter((n) => /^gemini-[\d.]+-flash-lite$/.test(n)).sort(byVersion);
    discoveredModels = [...flash, ...lite];
    return discoveredModels;
  } catch {
    return [];
  }
}

const wait = (ms: number) => new Promise((resolve) => setTimeout(resolve, ms));

type GeminiResponse = {
  candidates?: Array<{
    content?: { parts?: Array<{ text?: string; thought?: boolean }> };
    finishReason?: string;
  }>;
  promptFeedback?: { blockReason?: string };
  error?: { message?: string; status?: string };
};

export async function generateWithGemini(options: {
  system: string;
  messages: AiMessage[];
  maxOutputTokens?: number;
  temperature?: number;
}): Promise<string> {
  const apiKey = process.env["GEMINI_API_KEY"];
  if (!apiKey)
    throw new Error("Mandal IA n'est pas encore configurée (clé GEMINI_API_KEY absente).");
  const body = JSON.stringify({
    system_instruction: { parts: [{ text: options.system }] },
    contents: options.messages.map((m) => ({
      role: m.role === "assistant" ? "model" : "user",
      parts: m.parts.map((p) =>
        "text" in p
          ? { text: m.role === "assistant" ? sansSignature(p.text) : p.text }
          : { inline_data: { mime_type: p.file.mimeType, data: p.file.base64 } },
      ),
    })),
    generationConfig: {
      temperature: options.temperature ?? 0.4,
      maxOutputTokens: options.maxOutputTokens ?? 4096,
    },
  });

  const call = (model: string) =>
    fetch(`${API}/models/${encodeURIComponent(model)}:generateContent`, {
      method: "POST",
      headers: { "Content-Type": "application/json", "x-goog-api-key": apiKey },
      body,
    });

  // Modèle préféré d'abord ; en cas de surcharge ou de quota épuisé, on bascule
  // sur les autres modèles Flash disponibles.
  const tried = new Set<string>();
  let queue = [process.env["GEMINI_MODEL"] || DEFAULT_MODEL];
  let lastStatus = 0;
  let payload: GeminiResponse | null = null;

  for (let attempt = 0; attempt < MAX_TENTATIVES; attempt++) {
    let model = queue.find((m) => !tried.has(m));
    if (!model) {
      queue = [...queue, ...(await discoverFlashModels(apiKey)), "gemini-flash-lite-latest"];
      model = queue.find((m) => !tried.has(m));
      if (!model) break;
    }
    tried.add(model);

    const res = await call(model);
    const data = (await res.json().catch(() => ({}))) as GeminiResponse;
    if (res.ok) {
      payload = data;
      break;
    }
    lastStatus = res.status;
    console.error("[Gemini]", model, res.status, data.error?.message);
    if (res.status === 400 && data.error?.message?.includes("API key"))
      throw new Error("La clé de Mandal IA est invalide. Vérifiez GEMINI_API_KEY dans Vercel.");
    if (res.status !== 404 && !RETRYABLE.has(res.status)) {
      throw new Error(`Mandal IA est momentanément indisponible (${res.status}).`);
    }
    // Surcharge passagère : courte pause avant le modèle suivant.
    if (res.status === 503 || res.status === 500) await wait(800);
  }

  if (!payload) {
    if (lastStatus === 429)
      throw new Error(
        "Mandal IA a atteint sa limite gratuite pour le moment. Réessayez dans quelques minutes.",
      );
    throw new Error(
      "Les serveurs de Mandal IA (Google Gemini) sont surchargés en ce moment. Réessayez dans une ou deux minutes.",
    );
  }

  if (payload.promptFeedback?.blockReason) {
    return signer(
      "Je ne peux pas traiter cette demande. Reformulez votre question sur vos cours ou votre orientation.",
    );
  }

  const text = (payload.candidates?.[0]?.content?.parts ?? [])
    .filter((p) => !p.thought && typeof p.text === "string")
    .map((p) => p.text)
    .join("")
    .trim();

  return signer(text || "Je n'ai pas pu formuler de réponse. Reformulez votre question.");
}
