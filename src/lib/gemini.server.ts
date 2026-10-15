// Appel à l'API Google Gemini (serveur uniquement : la clé ne doit jamais
// atteindre le navigateur). Modèle configurable via GEMINI_MODEL pour pouvoir
// changer de modèle (ou passer à l'offre payante) sans toucher au code.

export type AiPart = { text: string } | { file: { mimeType: string; base64: string } };

export type AiMessage = { role: "user" | "assistant"; parts: AiPart[] };

const API = "https://generativelanguage.googleapis.com/v1beta";
const DEFAULT_MODEL = "gemini-flash-latest";

// Modèle retenu après découverte automatique (mémorisé tant que le serveur tourne).
let discoveredModel: string | null = null;

/** Si le modèle demandé n'existe pas (les noms changent souvent chez Google),
 *  choisit le modèle « Flash » le plus récent proposé à cette clé. */
async function discoverFlashModel(apiKey: string): Promise<string | null> {
  const res = await fetch(`${API}/models?pageSize=200`, { headers: { "x-goog-api-key": apiKey } });
  if (!res.ok) return null;
  const { models = [] } = (await res.json()) as {
    models?: Array<{ name: string; supportedGenerationMethods?: string[] }>;
  };
  const candidates = models
    .filter((m) => m.supportedGenerationMethods?.includes("generateContent"))
    .map((m) => m.name.replace(/^models\//, ""))
    .filter((n) => /^gemini-[\d.]+-flash$/.test(n))
    .sort((a, b) => parseFloat(b.slice(7)) - parseFloat(a.slice(7)));
  return candidates[0] ?? null;
}

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
          ? { text: p.text }
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

  let res = await call(process.env["GEMINI_MODEL"] || discoveredModel || DEFAULT_MODEL);
  if (res.status === 404) {
    discoveredModel = await discoverFlashModel(apiKey);
    if (discoveredModel) res = await call(discoveredModel);
  }

  const payload = (await res.json().catch(() => ({}))) as GeminiResponse;

  if (!res.ok) {
    console.error("[Gemini]", res.status, payload.error?.message);
    if (res.status === 429)
      throw new Error("Mandal IA est très sollicitée en ce moment. Réessayez dans une minute.");
    if (res.status === 400 && payload.error?.message?.includes("API key"))
      throw new Error("La clé de Mandal IA est invalide. Vérifiez GEMINI_API_KEY dans Vercel.");
    throw new Error(`Mandal IA est momentanément indisponible (${res.status}).`);
  }

  if (payload.promptFeedback?.blockReason) {
    return "Je ne peux pas traiter cette demande. Reformulez votre question sur vos cours ou votre orientation.";
  }

  const text = (payload.candidates?.[0]?.content?.parts ?? [])
    .filter((p) => !p.thought && typeof p.text === "string")
    .map((p) => p.text)
    .join("")
    .trim();

  return text || "Je n'ai pas pu formuler de réponse. Reformulez votre question.";
}
