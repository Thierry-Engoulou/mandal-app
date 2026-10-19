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
import {
  ArcsCapables,
  CubeOrthogonalite,
  DenombrementArbre,
  DistanceDroite,
  EspaceVectoriel,
  GrapheAdjacence,
  LimitesAsymptotes,
  MatriceTransformation,
  RepereEspace,
  SphereSection,
  StatsClasses,
  TangentesCercle,
} from "@/components/interactive/maths1c-widgets";
import {
  EnergieElectrique,
  EnergieMecanique,
  IncertitudeMesure,
  LentilleMince,
  LoiHooke,
  OeilReduit,
  PointFonctionnement,
  QuantiteChaleur,
  TravailForce,
} from "@/components/interactive/physique-widgets";
import {
  AcideAminePh,
  ChiraliteCarbone,
  ClasseAlcool,
  EsterificationEquilibre,
  OxydationAlcool,
} from "@/components/interactive/chimie-tle-orga";
import {
  AcideFortFaible,
  CinetiqueEsterification,
  CourbeDosage,
  DosageRedox,
  EchellePh,
  EchellePka,
  FacteursCinetiques,
  NombreOxydation,
  PileDaniell,
  RedoxMetal,
  RegleGamma,
  VitesseReaction,
} from "@/components/interactive/chimie-tle-solutions";

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
  {
    value: "denombrement-arbre",
    label: "Dénombrement : l'arbre de choix",
    description: "p-uplets, arrangements et combinaisons, avec toutes les listes affichées.",
  },
  {
    value: "graphe-adjacence",
    label: "Graphes : sommets, arêtes et matrice",
    description: "Créer des arêtes, lire les degrés, tester la connexité et la chaîne eulérienne.",
  },
  {
    value: "stats-classes",
    label: "Série statistique regroupée en classes",
    description: "Histogramme, effectifs cumulés, médiane lue graphiquement, quartiles.",
  },
  {
    value: "limites-asymptotes",
    label: "Limites et asymptotes",
    description: "Fonction homographique : asymptote verticale, horizontale et limites.",
  },
  {
    value: "arcs-capables",
    label: "Arcs capables",
    description: "L'ensemble des points qui voient un segment sous un angle donné.",
  },
  {
    value: "matrice-transformation",
    label: "Matrice 2×2 et application linéaire",
    description: "Image d'une figure, images de i et j, déterminant et aire.",
  },
  {
    value: "espace-vectoriel",
    label: "Combinaison linéaire, famille libre ou liée",
    description: "Régler α et β, voir le plan engendré ou la droite d'une famille liée.",
  },
  {
    value: "distance-droite",
    label: "Distance d'un point à une droite",
    description: "Vecteur normal, projeté orthogonal et formule de la distance.",
  },
  {
    value: "tangentes-cercle",
    label: "Tangentes à un cercle issues d'un point",
    description: "Deux tangentes, une seule ou aucune, et la longueur √(OP² − R²).",
  },
  {
    value: "cube-orthogonalite",
    label: "Orthogonalité dans l'espace",
    description: "Sur un cube : droites orthogonales, droite perpendiculaire à un plan.",
  },
  {
    value: "repere-espace",
    label: "Repère de l'espace",
    description: "Placer un point par ses trois coordonnées et calculer OM.",
  },
  {
    value: "sphere-section",
    label: "Sphère coupée par un plan",
    description: "Section sécante, tangente ou vide, et le rayon r = √(R² − d²).",
  },
  {
    value: "incertitude-mesure",
    label: "Incertitude sur une mesure",
    description: "Encadrement d'une mesure, incertitude absolue et relative.",
  },
  {
    value: "loi-hooke",
    label: "Loi de Hooke et limite élastique",
    description: "Allongement d'un ressort, et ce qui se passe quand le modèle ne tient plus.",
  },
  {
    value: "travail-force",
    label: "Travail d'une force",
    description: "W = F·d·cos α : force motrice, résistante ou de travail nul.",
  },
  {
    value: "energie-mecanique",
    label: "Énergie mécanique sur une piste",
    description: "Conversion cinétique et potentielle, avec ou sans frottement.",
  },
  {
    value: "quantite-chaleur",
    label: "Chaleur et changements d'état",
    description: "Courbe de chauffage de l'eau, de la glace à la vapeur.",
  },
  {
    value: "lentille-mince",
    label: "Lentille mince",
    description: "Tracé des rayons, position et nature de l'image, grandissement.",
  },
  {
    value: "oeil-reduit",
    label: "L'œil réduit et l'accommodation",
    description: "Œil normal, myope ou hypermétrope, et image sur la rétine.",
  },
  {
    value: "point-fonctionnement",
    label: "Générateur, récepteur, point de fonctionnement",
    description: "Croisement des deux caractéristiques, rendement et pertes.",
  },
  {
    value: "energie-electrique",
    label: "Énergie consommée et facture",
    description: "Du watt au kilowattheure, puis au coût en FCFA.",
  },
  {
    value: "classe-alcool",
    label: "Classe d'un alcool",
    description: "Compter les voisins carbonés : primaire, secondaire ou tertiaire.",
  },
  {
    value: "oxydation-alcool",
    label: "Oxydation ménagée d'un alcool",
    description: "Produit obtenu selon la classe, et tests 2,4-DNPH, Tollens, papier pH.",
  },
  {
    value: "esterification-equilibre",
    label: "Équilibre d'estérification",
    description: "Rendements de 67, 60 et 5 %, et ce qui déplace vraiment l'équilibre.",
  },
  {
    value: "acide-amine-ph",
    label: "Les trois formes d'un acide α-aminé",
    description: "Cation, zwitterion, anion, et le point isoélectrique.",
  },
  {
    value: "chiralite-carbone",
    label: "Chiralité d'un carbone",
    description: "Quatre groupes différents, énantiomères et image dans un miroir.",
  },
  {
    value: "echelle-pka",
    label: "Échelle des pKa",
    description: "Comparer la force des acides et des bases sur un même axe.",
  },
  {
    value: "regle-gamma",
    label: "Règle du gamma",
    description: "Prévoir la réaction entre deux couples et calculer sa constante.",
  },
  {
    value: "echelle-ph",
    label: "Échelle des pH du quotidien",
    description: "Du jus de citron à la soude, avec les concentrations correspondantes.",
  },
  {
    value: "acide-fort-faible",
    label: "Acide fort et acide faible",
    description: "pH en fonction de la concentration, et taux d'ionisation.",
  },
  {
    value: "courbe-dosage",
    label: "Courbe de dosage acido-basique",
    description: "Saut de pH, équivalence, demi-équivalence et choix de l'indicateur.",
  },
  {
    value: "vitesse-reaction",
    label: "Vitesse et méthode des tangentes",
    description: "Lire une vitesse instantanée et placer le temps de demi-réaction.",
  },
  {
    value: "facteurs-cinetiques",
    label: "Les facteurs cinétiques",
    description:
      "Température, concentration, catalyseur, surface : la pente change, pas le palier.",
  },
  {
    value: "cinetique-esterification",
    label: "Cinétique de l'estérification",
    description: "Estérification et hydrolyse aboutissent au même équilibre.",
  },
  {
    value: "redox-metal",
    label: "Réactivité des métaux",
    description: "Quel métal déplace quel ion, et pourquoi, d'après les potentiels.",
  },
  {
    value: "nombre-oxydation",
    label: "Nombre d'oxydation",
    description: "Calcul détaillé, puis oxydation ou réduction selon la variation.",
  },
  {
    value: "pile-daniell",
    label: "Pile et force électromotrice",
    description: "Pôles, sens des électrons, f.é.m. et rôle du pont salin.",
  },
  {
    value: "dosage-redox",
    label: "Dosage d'oxydoréduction",
    description: "Permanganate et fer II, avec le coefficient 5 à ne pas oublier.",
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
  "denombrement-arbre": DenombrementArbre,
  "graphe-adjacence": GrapheAdjacence,
  "stats-classes": StatsClasses,
  "limites-asymptotes": LimitesAsymptotes,
  "arcs-capables": ArcsCapables,
  "matrice-transformation": MatriceTransformation,
  "espace-vectoriel": EspaceVectoriel,
  "distance-droite": DistanceDroite,
  "tangentes-cercle": TangentesCercle,
  "cube-orthogonalite": CubeOrthogonalite,
  "repere-espace": RepereEspace,
  "sphere-section": SphereSection,
  "incertitude-mesure": IncertitudeMesure,
  "loi-hooke": LoiHooke,
  "travail-force": TravailForce,
  "energie-mecanique": EnergieMecanique,
  "quantite-chaleur": QuantiteChaleur,
  "lentille-mince": LentilleMince,
  "oeil-reduit": OeilReduit,
  "point-fonctionnement": PointFonctionnement,
  "energie-electrique": EnergieElectrique,
  "classe-alcool": ClasseAlcool,
  "oxydation-alcool": OxydationAlcool,
  "esterification-equilibre": EsterificationEquilibre,
  "acide-amine-ph": AcideAminePh,
  "chiralite-carbone": ChiraliteCarbone,
  "echelle-pka": EchellePka,
  "regle-gamma": RegleGamma,
  "echelle-ph": EchellePh,
  "acide-fort-faible": AcideFortFaible,
  "courbe-dosage": CourbeDosage,
  "vitesse-reaction": VitesseReaction,
  "facteurs-cinetiques": FacteursCinetiques,
  "cinetique-esterification": CinetiqueEsterification,
  "redox-metal": RedoxMetal,
  "nombre-oxydation": NombreOxydation,
  "pile-daniell": PileDaniell,
  "dosage-redox": DosageRedox,
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
