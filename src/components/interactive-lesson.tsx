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
  AffineMorceaux,
  AlgoEuclide,
  BalanceEquation,
  ComparerReels,
  CoordonneesVecteur,
  DevelopperAires,
  DiagrammesStats,
  DiviseursCommuns,
  DroiteDeuxPoints,
  EquationProduit,
  FractionIrreductible,
  FractionRationnelle,
  Polynomes,
  PuissancesRelatives,
  Radicaux,
} from "@/components/interactive/maths3-plus-widgets";
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
  AcosBsin,
  EquationIrrationnelle,
  EquationTrigo,
  InequationTrigo,
  OperationsFonctions,
  PivotGauss,
  PolynomeDegre3,
  SommeProduitRacines,
} from "@/components/interactive/maths1c-plus-algebre";
import {
  AsymptoteOblique,
  CourbesCumulatives,
  FonctionDerivee,
  LireCourbe,
  PariteePeriodicite,
  SuiteArithmetique,
  SuiteGeometrique,
  TrianglePascal,
  VariationsDerivee,
} from "@/components/interactive/maths1c-plus-analyse";
import {
  ApplicationLineaire,
  Cocyclicite,
  DroiteParametrique,
  GrapheChaines,
  LignesNiveau,
  MatriceOperations,
  PlanEquation,
  ProjeteOrthogonal,
  SymetrieOrthogonale,
  TransformationAnalytique,
} from "@/components/interactive/maths1c-plus-geometrie";
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
import {
  AcideAminePh,
  ChiraliteCarbone,
  ClasseAlcool,
  EsterificationEquilibre,
  OxydationAlcool,
} from "@/components/interactive/chimie-tle-orga";
import {
  AnalyseElementaire,
  CaracteresOrganiques,
  FormuleBrute,
  FormuleSimple,
  OrganiqueMineral,
  TestsElements,
} from "@/components/interactive/chimie1-analyse";
import {
  ChlorationMethane,
  CombustionAlcane,
  ConformationsEthane,
  Cyclanes,
  FamilleAlcanes,
  IsomeresAlcane,
  NomenclatureAlcane,
  PreparationMethane,
  ProprietesAlcanes,
} from "@/components/interactive/chimie1-alcanes";
import {
  CarbureAcetylene,
  CombustionInsature,
  DeshydratationAlcool,
  HydrogenationCatalyseur,
  IsomerieZE,
  Markovnikov,
  NomenclatureAlcene,
  PolymeresUsages,
  Polymerisation,
  ProprietesInsatures,
  StructureInsatures,
  TestDibrome,
} from "@/components/interactive/chimie1-insatures";
import {
  AromatiquesNomenclature,
  BenzeneAddition,
  BenzeneStructure,
  BenzeneSubstitution,
  ProprietesOxygenes,
  TestAldehydeCetone,
} from "@/components/interactive/chimie1-aromatiques";
import {
  CampingGaz,
  ComplexeArgiloHumique,
  DistillationPetrole,
  EngraisNpk,
  FamillesEngrais,
  GisementPetrole,
  IndiceOctane,
  RoleNpk,
} from "@/components/interactive/chimie1-petrole";
import {
  AcideMetal,
  ConstruirePile,
  CoupleRedox,
  MasseElectrodes,
  OxydantReducteur,
  PotentielsStandards,
  TestsIons,
} from "@/components/interactive/chimie1-redox-a";
import {
  AnodeSoluble,
  ApplicationsIndustrielles,
  Corrosion,
  CouplesNonMetalliques,
  DemiEquation,
  Electrolyse,
  ElectrolyseEau,
  Electronegativite,
  EquilibrerNo,
  Iodometrie,
  MaterielDosage,
  PointEquivalence,
  ReactionTotale,
  RedoxVoieSeche,
} from "@/components/interactive/chimie1-redox-b";
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
    value: "diviseurs-communs",
    label: "Diviseurs communs, PGCD et PPCM",
    description: "Lister les diviseurs et les multiples de deux nombres, et repérer les communs.",
  },
  {
    value: "algo-euclide",
    label: "Les deux algorithmes du PGCD",
    description:
      "Comparer les divisions d'Euclide et les soustractions successives, étape par étape.",
  },
  {
    value: "fraction-irreductible",
    label: "Rendre une fraction irréductible",
    description: "Simplifier par les facteurs premiers, ou d'un coup par le PGCD.",
  },
  {
    value: "radicaux",
    label: "Simplifier un radical",
    description:
      "Sortir le plus grand carré du radical, et voir la racine comme le côté d'un carré.",
  },
  {
    value: "comparer-reels",
    label: "Encadrer un nombre réel",
    description: "Serrer √2, π ou 7/3 entre deux décimaux, de l'unité au millième.",
  },
  {
    value: "puissances-relatives",
    label: "Puissances d'exposant entier relatif",
    description: "Vérifier les règles de calcul en changeant la base et les deux exposants.",
  },
  {
    value: "developper-reduire",
    label: "Développer par les aires",
    description: "Voir (ax+b)(cx+d) comme l'aire d'un rectangle découpé en quatre morceaux.",
  },
  {
    value: "polynomes",
    label: "Polynôme : degré, valeur, racine",
    description: "Régler les coefficients, calculer P(x) et chercher une racine sur la courbe.",
  },
  {
    value: "fraction-rationnelle",
    label: "Fraction rationnelle et valeur interdite",
    description: "Repérer la valeur qui annule le dénominateur et celle qui annule la fraction.",
  },
  {
    value: "balance-equation",
    label: "La balance : résoudre ax + b = c",
    description: "Équilibrer les deux plateaux pour comprendre les deux étapes de la résolution.",
  },
  {
    value: "equation-produit",
    label: "Équation produit et équation quotient",
    description: "Un produit nul, une fraction nulle : où sont les solutions, où est le piège.",
  },
  {
    value: "affine-morceaux",
    label: "Forfait téléphonique : affine par morceaux",
    description: "Partie constante puis partie croissante, sur un cas concret en FCFA.",
  },
  {
    value: "diagrammes-stats",
    label: "Trois diagrammes pour une série",
    description: "Mêmes données en bâtons, en histogramme et en secteurs circulaires.",
  },
  {
    value: "coordonnees-vecteur",
    label: "Coordonnées d'un vecteur",
    description: "Lire les coordonnées de AB, calculer sa norme et tester la colinéarité.",
  },
  {
    value: "droite-deux-points",
    label: "Droite passant par deux points",
    description: "Coefficient directeur, équation, et position par rapport à une seconde droite.",
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
  {
    value: "somme-produit-racines",
    label: "Somme, produit et factorisation",
    description: "Deviner les racines d'un trinôme sans calculer le discriminant.",
  },
  {
    value: "equation-irrationnelle",
    label: "Équation irrationnelle et solutions parasites",
    description: "Voir pourquoi élever au carré ajoute des solutions qu'il faut écarter.",
  },
  {
    value: "polynome-degre3",
    label: "Polynôme de degré 3",
    description: "Racine évidente, factorisation, puis trinôme restant.",
  },
  {
    value: "pivot-gauss",
    label: "Le pivot de Gauss, étape par étape",
    description: "Suivre l'élimination des inconnues sur un système de trois équations.",
  },
  {
    value: "equation-trigo",
    label: "Résoudre cos x = a, sin x = a, tan x = a",
    description: "Lire les solutions directement sur le cercle trigonométrique.",
  },
  {
    value: "acos-bsin",
    label: "Réduire a cos x + b sin x",
    description: "Transformer une somme de sinusoïdes en une seule, d'amplitude R.",
  },
  {
    value: "inequation-trigo",
    label: "Inéquation trigonométrique",
    description: "L'arc solution, tracé sur le cercle, avec ses deux bornes.",
  },
  {
    value: "operations-fonctions",
    label: "Somme, produit, quotient et composée",
    description:
      "Construire une nouvelle fonction à partir de deux autres, et trouver son domaine.",
  },
  {
    value: "lire-courbe",
    label: "Lire une courbe",
    description: "Image, antécédents, variations et extremums, à lire sur le graphique.",
  },
  {
    value: "parite-periodicite",
    label: "Parité, imparité, périodicité",
    description: "Reconnaître les symétries qui permettent de réduire l'étude.",
  },
  {
    value: "fonction-derivee",
    label: "La fonction dérivée à côté de sa courbe",
    description: "Voir la pente de la tangente devenir l'ordonnée de la dérivée.",
  },
  {
    value: "variations-derivee",
    label: "Signe de la dérivée et sens de variation",
    description: "Les zones de croissance et de décroissance, et les extremums.",
  },
  {
    value: "asymptote-oblique",
    label: "L'asymptote oblique",
    description: "Mesurer l'écart entre la courbe et sa droite asymptote.",
  },
  {
    value: "suite-arithmetique",
    label: "Suite arithmétique",
    description: "Des points alignés, une raison constante et la somme des termes.",
  },
  {
    value: "suite-geometrique",
    label: "Suite géométrique",
    description: "Multiplier par q à chaque rang : convergence ou explosion.",
  },
  {
    value: "courbes-cumulatives",
    label: "Courbes cumulatives et médiane",
    description: "Lire la médiane d'une série groupée à l'intersection des deux courbes.",
  },
  {
    value: "triangle-pascal",
    label: "Triangle de Pascal et binôme",
    description: "Chaque case, somme des deux du dessus, donne un coefficient du binôme.",
  },
  {
    value: "graphe-chaines",
    label: "Chaînes, cycles et connexité",
    description: "Relier des villes et tester la connexité du graphe obtenu.",
  },
  {
    value: "lignes-niveau",
    label: "Les lignes de niveau",
    description: "MA² + MB², MA/MB et le produit scalaire : trois familles de cercles.",
  },
  {
    value: "cocyclicite",
    label: "Cocyclicité et angle inscrit",
    description: "Quatre points voient-ils le même segment sous le même angle ?",
  },
  {
    value: "symetrie-orthogonale",
    label: "La symétrie orthogonale",
    description: "Le milieu sur l'axe, la perpendicularité, et l'orientation retournée.",
  },
  {
    value: "transformation-analytique",
    label: "Expressions analytiques des transformations",
    description: "Translation, rotation et homothétie, lues sur les coordonnées.",
  },
  {
    value: "matrice-operations",
    label: "Somme, produit et déterminant de matrices",
    description: "Vérifier que le produit de deux matrices n'est pas commutatif.",
  },
  {
    value: "application-lineaire",
    label: "Une application linéaire et sa matrice",
    description: "Les colonnes sont les images des vecteurs de base, le déterminant est une aire.",
  },
  {
    value: "droite-parametrique",
    label: "Droite de l'espace, en paramétrique",
    description: "Faire varier t et voir le point balayer la droite.",
  },
  {
    value: "plan-equation",
    label: "Équation cartésienne d'un plan",
    description: "Le vecteur normal, le test d'appartenance et la distance d'un point.",
  },
  {
    value: "projete-orthogonal",
    label: "Le projeté orthogonal",
    description: "Projeter un point sur un plan ou sur une droite de l'espace.",
  },
  {
    value: "organique-mineral",
    label: "Organique ou minéral ?",
    description: "Chauffer six échantillons et trier les deux familles, pièges compris.",
  },
  {
    value: "caracteres-organiques",
    label: "Les quatre caractères",
    description: "Comparer un composé organique et le sel face à quatre tests.",
  },
  {
    value: "tests-elements",
    label: "Les trois tests d'identification",
    description: "Chercher le carbone, l'hydrogène et l'azote dans un composé.",
  },
  {
    value: "analyse-elementaire",
    label: "De la combustion aux pourcentages",
    description: "Peser le CO₂ et l'eau, en déduire la composition centésimale.",
  },
  {
    value: "formule-brute",
    label: "Trouver la formule brute",
    description: "Des pourcentages et d'une masse molaire aux indices x, y et z.",
  },
  {
    value: "formule-simple",
    label: "La formule la plus simple",
    description: "Quand la masse molaire manque : le rapport et le multiplicateur k.",
  },
  {
    value: "famille-alcanes",
    label: "Les trois écritures d'une molécule",
    description: "Brute, développée, semi-développée, sur le même alcane.",
  },
  {
    value: "nomenclature-alcane",
    label: "Construire et nommer un alcane",
    description: "Déplacer la ramification et voir la numérotation basculer.",
  },
  {
    value: "isomeres-alcane",
    label: "Compter les isomères",
    description: "Les isomères de chaîne, du propane au décane.",
  },
  {
    value: "cyclanes",
    label: "Les cyclanes et leur stabilité",
    description: "L'angle du cycle, la tension, et pourquoi le cyclohexane gagne.",
  },
  {
    value: "conformations-ethane",
    label: "Faire tourner la molécule d'éthane",
    description: "La projection de Newman et la courbe d'énergie.",
  },
  {
    value: "proprietes-alcanes",
    label: "Ébullition et ramification",
    description: "La longueur de chaîne et la compacité font le point d'ébullition.",
  },
  {
    value: "combustion-alcane",
    label: "Équilibrer une combustion",
    description: "Complète ou incomplète, avec les volumes d'air et de CO₂.",
  },
  {
    value: "chloration-methane",
    label: "La chloration du méthane",
    description: "Quatre substitutions successives, et le rôle de la lumière.",
  },
  {
    value: "preparation-methane",
    label: "Préparer le méthane au laboratoire",
    description: "Le carbure d'aluminium, les impuretés et le rendement.",
  },
  {
    value: "structure-insatures",
    label: "La géométrie des insaturés",
    description: "De l'éthane à l'acétylène : angles, longueurs et rotation.",
  },
  {
    value: "nomenclature-alcene",
    label: "Nommer un alcène ou un alcyne",
    description: "La chaîne, la position de la liaison, le plus petit indice.",
  },
  {
    value: "isomerie-ze",
    label: "Reconnaître les isomères Z et E",
    description: "Changer les quatre groupes et voir si la stéréo-isomérie existe.",
  },
  {
    value: "combustion-insature",
    label: "Combustion d'un alcène ou d'un alcyne",
    description: "Retrouver les coefficients plutôt que les apprendre par cœur.",
  },
  {
    value: "hydrogenation-catalyseur",
    label: "Hydrogéner avec Pd ou avec Ni",
    description: "Le catalyseur décide : on s'arrête à l'alcène, ou on va à l'alcane.",
  },
  {
    value: "markovnikov",
    label: "La règle de Markovnikov",
    description: "Compter les hydrogènes et prévoir le produit majoritaire.",
  },
  {
    value: "test-dibrome",
    label: "Le test au dibrome",
    description: "La décoloration qui révèle une liaison multiple, et le dosage.",
  },
  {
    value: "polymerisation",
    label: "Fabriquer un polymère",
    description: "Du monomère à la macromolécule : motif, indice et masse.",
  },
  {
    value: "polymeres-usages",
    label: "Du monomère à l'objet",
    description: "Remonter d'un sachet ou d'un tuyau jusqu'au monomère.",
  },
  {
    value: "carbure-acetylene",
    label: "La lampe à carbure",
    description: "Préparer l'acétylène, mesurer le rendement, allumer le bec.",
  },
  {
    value: "deshydratation-alcool",
    label: "Hydrater, déshydrater",
    description: "Deux réactions inverses que les conditions seules départagent.",
  },
  {
    value: "benzene-structure",
    label: "Le nuage délocalisé",
    description: "Kekulé contre le noyau benzénique, et l'expérience qui tranche.",
  },
  {
    value: "aromatiques-nomenclature",
    label: "Ortho, méta, para",
    description: "Placer les groupes sur le cycle et lire le nom qui en découle.",
  },
  {
    value: "benzene-addition",
    label: "Additionner sur le benzène",
    description: "Les conditions sévères qu'exige le noyau délocalisé.",
  },
  {
    value: "benzene-substitution",
    label: "Substituer sur le benzène",
    description: "Halogénation, nitration, Friedel et Crafts, étape par étape.",
  },
  {
    value: "test-aldehyde-cetone",
    label: "Le laboratoire d'identification",
    description: "DNPH, Schiff, Fehling, Tollens : conclure en deux tests.",
  },
  {
    value: "gisement-petrole",
    label: "Explorer un gisement",
    description: "Profondeur, géothermie, durée : les trois facteurs de formation.",
  },
  {
    value: "distillation-petrole",
    label: "La colonne à plateaux",
    description: "Six coupes de volatilité croissante à partir d'un brut.",
  },
  {
    value: "indice-octane",
    label: "Améliorer un carburant",
    description: "Ramifier, cycliser, et regarder le moteur cesser de cogner.",
  },
  {
    value: "camping-gaz",
    label: "La bouteille de gaz et la cuisine",
    description: "Le CO₂, l'eau et l'air que demande une bouteille de butane.",
  },
  {
    value: "complexe-argilo-humique",
    label: "Le sol qui retient, le sol qui lessive",
    description: "Ce que le complexe argilo-humique garde, ce que la pluie emporte.",
  },
  {
    value: "role-npk",
    label: "Nourrir une plante",
    description: "Couper l'azote, le phosphore ou le potassium et voir le résultat.",
  },
  {
    value: "engrais-npk",
    label: "Calculer un apport d'engrais",
    description: "Lire l'étiquette NPK et convertir les oxydes en éléments.",
  },
  {
    value: "familles-engrais",
    label: "Choisir le bon engrais",
    description: "Culture, sol, saison et date d'épandage font le rendement.",
  },
  {
    value: "acide-metal",
    label: "Quel métal l'acide attaque-t-il ?",
    description: "Les métaux attaqués, ceux qui résistent, et le test à la bûchette.",
  },
  {
    value: "tests-ions",
    label: "Identifier un ion métallique",
    description: "La soude, l'excès de soude et l'ammoniac pour trancher.",
  },
  {
    value: "oxydant-reducteur",
    label: "Qui prend, qui donne",
    description: "Oxydation ou réduction : installer le réflexe une fois pour toutes.",
  },
  {
    value: "couple-redox",
    label: "Construire un couple",
    description: "Plonger un métal dans les ions d'un autre et voir qui réagit.",
  },
  {
    value: "construire-pile",
    label: "Construire sa propre pile",
    description: "Les pôles, la représentation conventionnelle et la f.é.m.",
  },
  {
    value: "potentiels-standards",
    label: "Lire le tableau des potentiels",
    description: "L'échelle, le gamma et le critère de totalité.",
  },
  {
    value: "masse-electrodes",
    label: "Suivre la masse des électrodes",
    description: "Ce que le pôle négatif perd, ce que le pôle positif gagne.",
  },
  {
    value: "demi-equation",
    label: "Construire une demi-équation",
    description: "Les cinq étapes, dans l'ordre, sur quatre couples d'examen.",
  },
  {
    value: "couples-non-metalliques",
    label: "L'échelle des potentiels",
    description: "Les couples d'examen, leurs demi-équations et leurs couleurs.",
  },
  {
    value: "reaction-totale",
    label: "La réaction sera-t-elle totale ?",
    description: "Le seuil de 0,34 volt, et ce qu'il reste dans le bécher.",
  },
  {
    value: "point-equivalence",
    label: "Qu'est-ce que l'équivalence ?",
    description: "Les deux réactifs qui tombent à zéro en même temps.",
  },
  {
    value: "materiel-dosage",
    label: "Monter un dosage",
    description: "La burette, la pipette jaugée et l'agitateur, bien placés.",
  },
  {
    value: "iodometrie",
    label: "L'iodométrie et l'empois d'amidon",
    description: "Mesurer l'erreur que l'indicateur coloré fait éviter.",
  },
  {
    value: "electrolyse",
    label: "Forcer une réaction",
    description: "La tension seuil, l'anode, la cathode et la surtension.",
  },
  {
    value: "electrolyse-eau",
    label: "Électrolyser l'eau",
    description: "Deux volumes de dihydrogène pour un volume de dioxygène.",
  },
  {
    value: "anode-soluble",
    label: "Affiner le cuivre",
    description: "L'anode qui se ronge, la cathode qui grossit, la boue anodique.",
  },
  {
    value: "corrosion",
    label: "Faire rouiller, ou protéger",
    description: "L'eau, l'air, le sel, et l'anode sacrifiée en zinc.",
  },
  {
    value: "electronegativite",
    label: "Qui attire les électrons ?",
    description: "Le doublet qui penche et la liaison polarisée.",
  },
  {
    value: "redox-voie-seche",
    label: "Oxydoréduction ou pas ?",
    description: "Repérer la variation de nombre d'oxydation, pièges compris.",
  },
  {
    value: "equilibrer-no",
    label: "Équilibrer par les n.o.",
    description: "Poser alpha et bêta, puis placer les coefficients.",
  },
  {
    value: "proprietes-insatures",
    label: "Gaz, liquide ou solide ?",
    description: "L'état, la densité et la solubilité d'un alcène ou d'un alcyne.",
  },
  {
    value: "proprietes-oxygenes",
    label: "Pourquoi les alcools bouillent-ils si haut ?",
    description: "Les liaisons hydrogène, et la solubilité qui s'effondre avec la chaîne.",
  },
  {
    value: "applications-industrielles",
    label: "L'oxydoréduction dans l'industrie",
    description: "Haut fourneau, aluminothermie, alumine, eau de javel et dismutation.",
  },
] as const;

export type InteractifKey = (typeof INTERACTIFS)[number]["value"];

export const INTERACTIF_SPEC_PLACEHOLDER = `{
  "widget": "cercle-trigo",
  "consigne": "Place le point M à 60°, puis vérifie que cos x = 1/2."
}`;

const WIDGETS: Record<string, typeof CercleTrigo> = {
  "somme-produit-racines": SommeProduitRacines,
  "equation-irrationnelle": EquationIrrationnelle,
  "polynome-degre3": PolynomeDegre3,
  "pivot-gauss": PivotGauss,
  "equation-trigo": EquationTrigo,
  "acos-bsin": AcosBsin,
  "inequation-trigo": InequationTrigo,
  "operations-fonctions": OperationsFonctions,
  "lire-courbe": LireCourbe,
  "parite-periodicite": PariteePeriodicite,
  "fonction-derivee": FonctionDerivee,
  "variations-derivee": VariationsDerivee,
  "asymptote-oblique": AsymptoteOblique,
  "suite-arithmetique": SuiteArithmetique,
  "suite-geometrique": SuiteGeometrique,
  "courbes-cumulatives": CourbesCumulatives,
  "triangle-pascal": TrianglePascal,
  "graphe-chaines": GrapheChaines,
  "lignes-niveau": LignesNiveau,
  cocyclicite: Cocyclicite,
  "symetrie-orthogonale": SymetrieOrthogonale,
  "transformation-analytique": TransformationAnalytique,
  "matrice-operations": MatriceOperations,
  "application-lineaire": ApplicationLineaire,
  "droite-parametrique": DroiteParametrique,
  "plan-equation": PlanEquation,
  "projete-orthogonal": ProjeteOrthogonal,
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
  "diviseurs-communs": DiviseursCommuns,
  "algo-euclide": AlgoEuclide,
  "fraction-irreductible": FractionIrreductible,
  radicaux: Radicaux,
  "comparer-reels": ComparerReels,
  "puissances-relatives": PuissancesRelatives,
  "developper-reduire": DevelopperAires,
  polynomes: Polynomes,
  "fraction-rationnelle": FractionRationnelle,
  "balance-equation": BalanceEquation,
  "equation-produit": EquationProduit,
  "affine-morceaux": AffineMorceaux,
  "diagrammes-stats": DiagrammesStats,
  "coordonnees-vecteur": CoordonneesVecteur,
  "droite-deux-points": DroiteDeuxPoints,
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
  // chimie1-analyse
  "organique-mineral": OrganiqueMineral,
  "caracteres-organiques": CaracteresOrganiques,
  "tests-elements": TestsElements,
  "analyse-elementaire": AnalyseElementaire,
  "formule-brute": FormuleBrute,
  "formule-simple": FormuleSimple,
  // chimie1-alcanes
  "famille-alcanes": FamilleAlcanes,
  "nomenclature-alcane": NomenclatureAlcane,
  "isomeres-alcane": IsomeresAlcane,
  cyclanes: Cyclanes,
  "conformations-ethane": ConformationsEthane,
  "proprietes-alcanes": ProprietesAlcanes,
  "combustion-alcane": CombustionAlcane,
  "chloration-methane": ChlorationMethane,
  "preparation-methane": PreparationMethane,
  // chimie1-insatures
  "structure-insatures": StructureInsatures,
  "nomenclature-alcene": NomenclatureAlcene,
  "isomerie-ze": IsomerieZE,
  "combustion-insature": CombustionInsature,
  "hydrogenation-catalyseur": HydrogenationCatalyseur,
  markovnikov: Markovnikov,
  "test-dibrome": TestDibrome,
  polymerisation: Polymerisation,
  "polymeres-usages": PolymeresUsages,
  "carbure-acetylene": CarbureAcetylene,
  "deshydratation-alcool": DeshydratationAlcool,
  // chimie1-aromatiques
  "benzene-structure": BenzeneStructure,
  "aromatiques-nomenclature": AromatiquesNomenclature,
  "benzene-addition": BenzeneAddition,
  "benzene-substitution": BenzeneSubstitution,
  "test-aldehyde-cetone": TestAldehydeCetone,
  // chimie1-petrole
  "gisement-petrole": GisementPetrole,
  "distillation-petrole": DistillationPetrole,
  "indice-octane": IndiceOctane,
  "camping-gaz": CampingGaz,
  "complexe-argilo-humique": ComplexeArgiloHumique,
  "role-npk": RoleNpk,
  "engrais-npk": EngraisNpk,
  "familles-engrais": FamillesEngrais,
  // chimie1-redox-a
  "acide-metal": AcideMetal,
  "tests-ions": TestsIons,
  "oxydant-reducteur": OxydantReducteur,
  "couple-redox": CoupleRedox,
  "construire-pile": ConstruirePile,
  "potentiels-standards": PotentielsStandards,
  "masse-electrodes": MasseElectrodes,
  // chimie1-redox-b
  "demi-equation": DemiEquation,
  "couples-non-metalliques": CouplesNonMetalliques,
  "reaction-totale": ReactionTotale,
  "point-equivalence": PointEquivalence,
  "materiel-dosage": MaterielDosage,
  iodometrie: Iodometrie,
  electrolyse: Electrolyse,
  "electrolyse-eau": ElectrolyseEau,
  "anode-soluble": AnodeSoluble,
  corrosion: Corrosion,
  electronegativite: Electronegativite,
  "redox-voie-seche": RedoxVoieSeche,
  "equilibrer-no": EquilibrerNo,
  "proprietes-insatures": ProprietesInsatures,
  "proprietes-oxygenes": ProprietesOxygenes,
  "applications-industrielles": ApplicationsIndustrielles,
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
