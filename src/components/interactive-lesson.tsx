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
  ChampElectrique,
  ChampGravitation,
  DeviationElectrique,
  EquationDimensions,
  ForceLaplace,
  JustesseFidelite,
  LoisNewton,
  PenduleElastique,
  PenduleSimple,
  SatelliteOrbite,
  TirProjectile,
  VecteurFresnel,
} from "@/components/interactive/physique-tle-meca";
import {
  CapteurCaracteristique,
  CircuitRlc,
  CondensateurCharge,
  DecroissanceRadioactive,
  DiffusionCompton,
  EffetDoppler,
  FentesYoung,
  InterferencesOndes,
  NiveauxHydrogene,
  OndeProgressive,
  Photoelectrique,
  ResonanceRlc,
} from "@/components/interactive/physique-tle-ondes";

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
    value: "justesse-fidelite",
    label: "Justesse et fidélité d'un appareil",
    description: "Un tir sur cible : erreurs systématiques et erreurs aléatoires séparées.",
  },
  {
    value: "equation-dimensions",
    label: "Équations aux dimensions",
    description: "Tester l'homogénéité d'une relation, terme par terme.",
  },
  {
    value: "champ-gravitation",
    label: "Champ de gravitation",
    description: "Le vecteur champ autour d'une planète, et la loi en 1/r².",
  },
  {
    value: "champ-electrique",
    label: "Champ électrique de deux charges",
    description: "Lignes de champ, sonde mobile, et recherche du point où E est nul.",
  },
  {
    value: "force-laplace",
    label: "Force de Laplace",
    description: "F = B·I·ℓ·sin α, avec le sens donné par la règle des trois doigts.",
  },
  {
    value: "lois-newton",
    label: "Plan incliné et lois de Newton",
    description: "Bilan des forces, seuil de glissement et accélération g·sin α.",
  },
  {
    value: "tir-projectile",
    label: "Tir d'un projectile",
    description: "Parabole, flèche, portée, et l'angle de 45° qui porte le plus loin.",
  },
  {
    value: "deviation-electrique",
    label: "Déviation d'un électron",
    description: "Parabole entre les plaques, droite après, et condition de sortie.",
  },
  {
    value: "satellite-orbite",
    label: "Satellite en orbite",
    description: "Vitesse, période, orbite géostationnaire et troisième loi de Kepler.",
  },
  {
    value: "vecteur-fresnel",
    label: "Vecteurs de Fresnel",
    description: "Addition de deux sinusoïdes transformée en addition de vecteurs.",
  },
  {
    value: "pendule-elastique",
    label: "Pendule élastique",
    description: "Masse et ressort : période, isochronisme et échange des énergies.",
  },
  {
    value: "pendule-simple",
    label: "Pendule simple",
    description: "T = 2π√(ℓ/g), et la limite de l'approximation des petites oscillations.",
  },
  {
    value: "condensateur-charge",
    label: "Charge et décharge d'un condensateur",
    description: "Exponentielle, constante de temps RC, les 63 % et les 37 %.",
  },
  {
    value: "circuit-rlc",
    label: "Oscillations libres d'un circuit RLC",
    description: "Formule de Thomson, amortissement et passage au régime critique.",
  },
  {
    value: "resonance-rlc",
    label: "Résonance d'un circuit RLC",
    description: "Courbe d'intensité, impédance, déphasage et facteur de qualité.",
  },
  {
    value: "capteur-caracteristique",
    label: "Caractéristique d'un capteur",
    description: "Thermistance, photorésistance, Pt100 : linéaire ou non, et seuil de bascule.",
  },
  {
    value: "onde-progressive",
    label: "Onde progressive sur une corde",
    description: "λ = v/N, points en phase et en opposition de phase.",
  },
  {
    value: "interferences-ondes",
    label: "Interférences de deux sources",
    description: "Hyperboles, différence de marche, lignes ventrales et nodales.",
  },
  {
    value: "fentes-young",
    label: "Fentes de Young",
    description: "Franges, interfrange i = λD/a, et la frange centrale blanche.",
  },
  {
    value: "effet-doppler",
    label: "Effet Doppler",
    description: "Fronts d'onde serrés devant, écartés derrière, et le mur du son.",
  },
  {
    value: "niveaux-hydrogene",
    label: "Niveaux d'énergie de l'hydrogène",
    description: "Transitions, énergie du photon, séries de Lyman et de Balmer.",
  },
  {
    value: "photoelectrique",
    label: "Effet photoélectrique",
    description:
      "Seuil, travail d'extraction, et le rôle respectif de la couleur et de l'intensité.",
  },
  {
    value: "diffusion-compton",
    label: "Diffusion Compton",
    description: "Choc photon-électron, décalage Δλ et dépendance à l'angle.",
  },
  {
    value: "decroissance-radioactive",
    label: "Décroissance radioactive",
    description: "Courbe exponentielle, demi-vie, et un échantillon de 100 noyaux.",
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
  "justesse-fidelite": JustesseFidelite,
  "equation-dimensions": EquationDimensions,
  "champ-gravitation": ChampGravitation,
  "champ-electrique": ChampElectrique,
  "force-laplace": ForceLaplace,
  "lois-newton": LoisNewton,
  "tir-projectile": TirProjectile,
  "deviation-electrique": DeviationElectrique,
  "satellite-orbite": SatelliteOrbite,
  "vecteur-fresnel": VecteurFresnel,
  "pendule-elastique": PenduleElastique,
  "pendule-simple": PenduleSimple,
  "condensateur-charge": CondensateurCharge,
  "circuit-rlc": CircuitRlc,
  "resonance-rlc": ResonanceRlc,
  "capteur-caracteristique": CapteurCaracteristique,
  "onde-progressive": OndeProgressive,
  "interferences-ondes": InterferencesOndes,
  "fentes-young": FentesYoung,
  "effet-doppler": EffetDoppler,
  "niveaux-hydrogene": NiveauxHydrogene,
  photoelectrique: Photoelectrique,
  "diffusion-compton": DiffusionCompton,
  "decroissance-radioactive": DecroissanceRadioactive,
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
