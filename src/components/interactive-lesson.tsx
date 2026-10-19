import { MathText } from "@/components/math-text";
import {
  Barycentre,
  CercleTrigo,
  DeriveeTangente,
  SecondDegre,
  Statistiques,
  Suites,
  Transformations,
  Vecteurs,
} from "@/components/interactive/maths-widgets";
import {
  AnglesInscrits,
  ApplicationAffine,
  IdentitesRemarquables,
  Intervalles,
  PgcdCarreaux,
  PolygonesReguliers,
  RacineCarree,
  SectionPyramide,
  SystemeEquations,
  Thales,
  TrigoRectangle,
} from "@/components/interactive/maths3-widgets";

/**
 * Leçons de type "interactif" : des simulations que l'élève manipule directement
 * dans le site, sans dépendre d'un site extérieur ni d'une bonne connexion.
 * Le contenu de la leçon est un petit JSON : { "widget": "...", "consigne": "..." }.
 */

export const INTERACTIFS = [
  {
    value: "cercle-trigo",
    label: "Cercle trigonométrique",
    description: "Déplacer M sur le cercle et lire cos, sin et tan en direct.",
  },
  {
    value: "second-degre",
    label: "Parabole et discriminant",
    description: "Régler a, b, c et voir Δ, les racines et le sommet changer.",
  },
  {
    value: "derivee-tangente",
    label: "De la sécante à la tangente",
    description: "Faire tendre h vers 0 et voir apparaître le nombre dérivé.",
  },
  {
    value: "vecteurs",
    label: "Vecteurs : somme et produit scalaire",
    description: "Tirer deux vecteurs, lire la somme, la norme et l'angle.",
  },
  {
    value: "barycentre",
    label: "Barycentre de trois points",
    description: "Changer les poids α, β, γ et suivre le point G.",
  },
  {
    value: "suites",
    label: "Suites arithmétiques et géométriques",
    description: "Comparer les deux types de suites terme par terme.",
  },
  {
    value: "statistiques",
    label: "Série statistique à construire",
    description: "Modifier les effectifs et observer moyenne, médiane et écart-type.",
  },
  {
    value: "transformations",
    label: "Translation, rotation, homothétie",
    description: "Transformer une figure et comparer avec l'originale.",
  },
  {
    value: "pgcd-carreaux",
    label: "PGCD : carreler une pièce",
    description: "Algorithme d'Euclide et plus grand carreau possible, sans aucune coupe.",
  },
  {
    value: "racine-carree",
    label: "Racine carrée : le côté d'un carré",
    description: "Voir la racine carrée comme une longueur, et l'encadrer entre deux entiers.",
  },
  {
    value: "intervalles",
    label: "Intervalles de ℝ",
    description: "Crochets ouverts ou fermés, et test d'appartenance sur la droite graduée.",
  },
  {
    value: "identites-remarquables",
    label: "Identités remarquables par les aires",
    description: "Comprendre (a+b)², (a−b)² et (a−b)(a+b) en découpant un carré.",
  },
  {
    value: "application-affine",
    label: "Application linéaire et affine",
    description: "Régler a et b, lire une image et un antécédent sur la droite.",
  },
  {
    value: "systeme-equations",
    label: "Système de deux équations",
    description: "Deux droites : point d'intersection, parallèles ou confondues.",
  },
  {
    value: "thales",
    label: "Propriété de Thalès",
    description: "Déplacer la parallèle et voir les trois rapports rester égaux.",
  },
  {
    value: "trigo-rectangle",
    label: "Trigonométrie dans le triangle rectangle",
    description: "Cosinus, sinus et tangente d'un angle aigu, avec les côtés nommés.",
  },
  {
    value: "angles-inscrits",
    label: "Angles inscrits et angle au centre",
    description: "Déplacer M sur le cercle : l'angle inscrit ne bouge pas.",
  },
  {
    value: "polygones-reguliers",
    label: "Polygones réguliers",
    description: "De 3 à 12 côtés : angle au centre, apothème, périmètre et aire.",
  },
  {
    value: "section-pyramide",
    label: "Section d'une pyramide ou d'un cône",
    description: "Coupe parallèle à la base : les rapports k, k² et k³.",
  },
] as const;

export type InteractifKey = (typeof INTERACTIFS)[number]["value"];

export const INTERACTIF_SPEC_PLACEHOLDER = `{
  "widget": "cercle-trigo",
  "consigne": "Place le point M à 60°, puis vérifie que cos x = 1/2."
}`;

const WIDGETS: Record<string, typeof CercleTrigo> = {
  "cercle-trigo": CercleTrigo,
  "second-degre": SecondDegre,
  "derivee-tangente": DeriveeTangente,
  vecteurs: Vecteurs,
  barycentre: Barycentre,
  suites: Suites,
  statistiques: Statistiques,
  transformations: Transformations,
  "pgcd-carreaux": PgcdCarreaux,
  "racine-carree": RacineCarree,
  intervalles: Intervalles,
  "identites-remarquables": IdentitesRemarquables,
  "application-affine": ApplicationAffine,
  "systeme-equations": SystemeEquations,
  thales: Thales,
  "trigo-rectangle": TrigoRectangle,
  "angles-inscrits": AnglesInscrits,
  "polygones-reguliers": PolygonesReguliers,
  "section-pyramide": SectionPyramide,
};

type Spec = { widget?: string; consigne?: string };

/** Affiche la simulation décrite par le JSON de la leçon. */
export function InteractiveLesson({ spec }: { spec: string }) {
  let parsed: Spec | null = null;
  const brut = (spec ?? "").trim();

  if (brut.startsWith("{")) {
    try {
      parsed = JSON.parse(brut) as Spec;
    } catch {
      parsed = null;
    }
  } else if (brut.length > 0 && brut.length < 40) {
    // tolère un simple nom de simulation, sans JSON
    parsed = { widget: brut };
  }

  const key = parsed?.widget ?? "";
  const Widget = WIDGETS[key];

  if (!Widget) {
    return (
      <div className="space-y-2">
        <p className="rounded-xl border border-destructive/30 bg-destructive/5 px-3 py-2 text-sm text-destructive">
          Cette simulation n'est pas reconnue{key ? ` (« ${key} »)` : ""}.
        </p>
        <p className="text-xs text-muted-foreground">
          Simulations disponibles : {INTERACTIFS.map((i) => i.value).join(", ")}.
        </p>
      </div>
    );
  }

  return (
    <div className="space-y-3">
      {parsed?.consigne ? (
        <div className="rounded-xl border border-primary/25 bg-primary/5 px-3 py-2">
          <p className="mb-0.5 text-[11px] font-semibold uppercase tracking-wide text-primary">
            À toi de jouer
          </p>
          <MathText text={parsed.consigne} className="text-sm leading-relaxed text-foreground" />
        </div>
      ) : null}
      <Widget />
    </div>
  );
}
