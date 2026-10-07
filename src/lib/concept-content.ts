/** Types de contenu possibles pour une leçon (concept). */
export const CONCEPT_TYPES = [
  { value: "texte", label: "Texte enrichi" },
  { value: "video", label: "Vidéo (YouTube ou fichier)" },
  { value: "pdf", label: "PDF téléchargeable" },
  { value: "quiz", label: "Quiz" },
  { value: "graphique", label: "Graphique de fonction (tracé auto)" },
  { value: "simulation", label: "Simulation interactive (GeoGebra)" },
] as const;

export type ConceptType = (typeof CONCEPT_TYPES)[number]["value"];

export function conceptTypeLabel(value: string | null | undefined) {
  return CONCEPT_TYPES.find((t) => t.value === value)?.label ?? "Texte enrichi";
}

/** Bucket de stockage à utiliser selon le type de leçon. */
export function bucketForType(type: ConceptType) {
  if (type === "video") return "mediatheque-videos";
  return "mediatheque-documents";
}

/** Transforme un lien YouTube en URL d'intégration. Renvoie null si ce n'est pas YouTube. */
export function youtubeEmbedUrl(url: string): string | null {
  const match = url.match(
    /(?:youtube\.com\/(?:watch\?v=|embed\/|shorts\/)|youtu\.be\/)([A-Za-z0-9_-]{6,})/,
  );
  return match ? `https://www.youtube.com/embed/${match[1]}` : null;
}

/**
 * Transforme un lien de matériel GeoGebra (ex: geogebra.org/m/abcDEF12,
 * ou geogebra.org/classic/abcDEF12) en URL d'intégration iframe.
 * Renvoie null si ce n'est pas un lien GeoGebra reconnu.
 */
export function geogebraEmbedUrl(url: string): string | null {
  const match = url.match(
    /geogebra\.org\/(?:m|classic|material|graphing|calculator|geometry|3d)(?:\/show)?\/([A-Za-z0-9]{6,})/,
  );
  if (!match) return null;
  const id = match[1];
  return `https://www.geogebra.org/material/iframe/id/${id}/width/700/height/500/border/888888/sfsb/true/smb/false/stb/false/stbh/false/ai/false/asb/false/sri/true/rc/false/ld/false/sdz/true/ctl/false`;
}

/** Exemple de spec pour une leçon "graphique", à titre de placeholder dans l'éditeur. */
export const GRAPHIQUE_SPEC_PLACEHOLDER = `{
  "functions": [
    { "expr": "x^2 - 2*x - 1", "label": "f(x) = x² - 2x - 1", "color": "#2563eb" }
  ],
  "domain": [-5, 5],
  "points": [ { "x": 1, "y": -2, "label": "min" } ]
}`;
