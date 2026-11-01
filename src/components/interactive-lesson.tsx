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
import {
  BusOrdinateur,
  CaracteristiquesCpu,
  ComposantsUc,
  CouchesSysteme,
  DemarrageBios,
  SchemaFonctionnel,
  UnitesMesure,
} from "@/components/interactive/info1-materiel";
import {
  ArbreMaintenance,
  BoiteOutils,
  Defragmentation,
  DiagnosticPanne,
  MachineInfectee,
  MaintenanceLogicielle,
  NettoyageDisque,
  Partitionnement,
  ProtectionElectrique,
  ScanAntivirus,
  TypesMaintenance,
  TypesVirus,
} from "@/components/interactive/info1-maintenance";
import {
  AnalyseProbleme,
  ChoixTypes,
  Operateurs,
  PartiesAlgorithme,
  TraceVariables,
} from "@/components/interactive/info1-algo-a";
import {
  BouclePour,
  BoucleTantque,
  ComparerBoucles,
  ConditionsComposees,
  SelonCas,
  SiAlorsSinon,
  Tableaux,
} from "@/components/interactive/info1-algo-b";
import {
  FonctionProcedure,
  ProcedureParametres,
  Recursivite,
} from "@/components/interactive/info1-algo-c";
import {
  BaliseImage,
  BaliseLien,
  BalisesTexte,
  EditeurHtml,
  ListesHtml,
  StructurePage,
  TableauxHtml,
} from "@/components/interactive/info1-web-a";
import {
  ChampsInput,
  FeuilleStyle,
  FormulaireComplet,
  FormulaireHtml,
  PlacementsCss,
  SyntaxeCss,
} from "@/components/interactive/info1-web-b";
import {
  FormatsImage,
  InterfacePhotoshop,
  MatricielleVectorielle,
  Photomontage,
  PixelsDefinition,
  RetoucheImage,
  SonNumerique,
  VideoNumerique,
} from "@/components/interactive/info1-infographie";
import {
  CarteMere,
  FichePeripherique,
  FicheTechnique,
  PilotePeripherique,
  TypesLogiciels,
  TypesSystemes,
} from "@/components/interactive/inf7-materiel-a";
import {
  BlocAlimentation,
  CausesMaterielles,
  DiagnosticDysfonctionnement,
  DimensionnerOnduleur,
  EquipementsProtection,
  RisquesPoste,
  RolesOnduleur,
} from "@/components/interactive/inf7-materiel-b";
import {
  BulletinNotes,
  ClasseurFeuille,
  FonctionsTableur,
  MiseEnFormeCellule,
  ReferencesCellules,
  ZoneImpression,
} from "@/components/interactive/inf7-tableur";
import {
  ArchitecturesReseau,
  EtendueReseaux,
  InternetIntranetExtranet,
  PourquoiReseau,
  TopologiesLogiques,
  TopologiesPhysiques,
} from "@/components/interactive/inf7-reseau-a";
import {
  AdresseIp,
  CablesReseau,
  ClassesAdresses,
  EquipementsReseau,
  ProtocolesInternet,
  SupportsTransmission,
} from "@/components/interactive/inf7-reseau-b";
import { CarteReseau, CommandesReseau, MonterReseau } from "@/components/interactive/inf7-reseau-c";
import {
  Cardinalites,
  DecomposerSysteme,
  EntitePropriete,
  NiveauxMerise,
  ReglesGestion,
} from "@/components/interactive/inf7-merise-a";
import { ClesTables, NormaliserMcd, PassageMcdMld } from "@/components/interactive/inf7-merise-b";
import { FonctionsSgbd, ModelesBd, StructureTable } from "@/components/interactive/inf7-sgbd";
import {
  AlterDrop,
  CreateTable,
  InsertUpdateDelete,
  OperateursSql,
  RequeteSelect,
  SousLangagesSql,
} from "@/components/interactive/inf7-sql";
import {
  CreerTableAccess,
  FeuilleDonneesAccess,
  InterfaceAccess,
} from "@/components/interactive/inf7-access";
import {
  AlternativesLda,
  FamillesStructures,
  RepetitivesLda,
} from "@/components/interactive/inf7-algo-a";
import {
  CinqStructures,
  Enregistrement,
  ParcoursTableau,
  RechercheMax,
  RechercheSequentielle,
  StructureTableau,
  TraceExecution,
} from "@/components/interactive/inf7-algo-b";
import {
  ConstantesC,
  InstallerIde,
  LangagesProgrammation,
  PrintfScanf,
  StructureProgrammeC,
  VariablesC,
} from "@/components/interactive/inf7-c-a";
import {
  BouclesC,
  ErreursC,
  IfElseC,
  RechercheC,
  SwitchC,
  TableauC,
} from "@/components/interactive/inf7-c-b";
import {
  CourantsPhiloAfricaine,
  DistinguerPhilosophie,
  FrisePhiloAfricaine,
  TheseAuteurAfricaine,
} from "@/components/interactive/philo-afrique";
import {
  AnalyserSujet,
  BaremeEpreuve,
  DefinirConcept,
  PlanDissertation,
  QuatreTachesTexte,
  StructureTexte,
  ThemeProblemeThese,
} from "@/components/interactive/philo-methode";
import {
  ConnaitreAutrui,
  DouteCartesien,
  EtatDeNature,
  ImperatifCategorique,
  NotionsConscience,
  TopiquesFreud,
} from "@/components/interactive/philo-conscience";
import {
  DroitPerfectible,
  DroitPlusFort,
  LegalLegitime,
  NotionsEtat,
  QuelEtat,
  TroisContrats,
} from "@/components/interactive/philo-droit";
import {
  CasablancaMonrovia,
  CausesEtMarge,
  CroissanceDeveloppement,
  DeterminismeFatalisme,
  PeresPanafricanisme,
  TribunalCirconstances,
} from "@/components/interactive/philo-liberte";
import {
  CinqAttitudesMort,
  ComiteEthique,
  EssenceExistence,
  LaboratoireBernard,
  OpinionCroyanceScience,
  VieSansFin,
} from "@/components/interactive/philo-science";
import {
  CompterPropositions,
  ConstituantsPhrase,
  FormesDePhrase,
  JuxtapositionCoordination,
  PropositionsBepc,
  TypesDePhrases,
} from "@/components/interactive/fr3-phrase";
import {
  AccordCollectif,
  ChasseAccords,
  ImparfaitPasseSimple,
  PasseSimple,
  TempsIndicatif,
  TrouverLeSujet,
} from "@/components/interactive/fr3-accords";
import {
  ChampLexical,
  EtudeDeTexteBepc,
  FicheLecture,
  LectureMethodique,
  MontrerSentiment,
  NuancerSentiment,
} from "@/components/interactive/fr3-lecture";
import {
  CompteRenduFilm,
  PointDeVue,
  RaconterOral,
  SchemaActanciel,
  SchemaNarratif,
  VoixEtCorps,
} from "@/components/interactive/fr3-expression";
import {
  CompletiveCod,
  FonctionDuRelatif,
  IndicatifOuSubjonctif,
  PronomRelatif,
  QueRelatifOuCompletive,
  RelativeDeterminative,
} from "@/components/interactive/fr3-subordonnees";
import {
  DicteeHomophones,
  FamilleDeMots,
  FuturOuConditionnel,
  HomophoneContexte,
  SystemeHypothetique,
  ValeursConditionnel,
} from "@/components/interactive/fr3-orthographe";
import {
  DenoteConnote,
  EchelleConnotation,
  LectureArgumentative,
  MotChoisi,
  ProcederArgumentation,
  TrierArgumentation,
} from "@/components/interactive/fr3-argumenter";
import {
  ContredirePoliment,
  DebatRegle,
  InterventionOrale,
  PlanDialectique,
  RedactionArgumentee,
  TemoignageArgument,
} from "@/components/interactive/fr3-debat";
import {
  DirectIndirect,
  FormesDiscours,
  ModeCirconstancielle,
  NommerCirconstancielle,
  PonctuerDialogue,
  QuestionCinqBepc,
} from "@/components/interactive/fr3-circonstancielles";
import {
  AOuA,
  DeclencheursSubjonctif,
  DicteeGrammaticale,
  FormerSubjonctif,
  SubjonctifOuIndicatif1g,
  TestsHomophonesGram,
} from "@/components/interactive/fr3-grammatical";
import {
  AppreciatifDepreciatif,
  DegreAdhesion,
  DilemmeAndromaque,
  LireSceneTragedie,
  RelevierModalisateurs,
  StructureTragedie,
} from "@/components/interactive/fr3-tragedie";
import {
  ExprimerOpinion,
  HierarchiserArguments,
  ParagrapheArgumentatif,
  PresenterStand,
  RedigerTransition,
  RepondreQuestions,
} from "@/components/interactive/fr3-argumenter2";
import {
  AtelierSyllogisme,
  DetecteurSophismes,
  PositionsReligieuses,
  PreuvesDeDieu,
  ReligionDeuxUsages,
  VeriteValidite,
} from "@/components/interactive/philo-dieu";

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
  // informatique 1ere — materiel
  {
    value: "schema-fonctionnel",
    label: "Ranger les périphériques",
    description: "Entrée, sortie ou stockage : dans quel sens va l'information ?",
  },
  {
    value: "unites-mesure",
    label: "À chaque composant son unité",
    description: "Hertz, octet, pouce, ppp — et pourquoi 500 Go n'en font que 465.",
  },
  {
    value: "composants-uc",
    label: "Ouvrir l'unité centrale",
    description: "Chaque composant, son rôle, et ce qui se passe quand on le retire.",
  },
  {
    value: "caracteristiques-cpu",
    label: "Régler un processeur",
    description: "Fréquence, jeu d'instruction, mémoire : qui freine vraiment la machine ?",
  },
  {
    value: "couches-systeme",
    label: "Les quatre couches",
    description: "Une demande qui descend jusqu'au matériel, puis remonte.",
  },
  {
    value: "bus-ordinateur",
    label: "Les trois bus",
    description: "Adresses, données, contrôle : coupe l'un des trois et vois ce qui manque.",
  },
  {
    value: "demarrage-bios",
    label: "Le démarrage étape par étape",
    description: "Le BIOS, la séquence POST, et les bips quand un composant manque.",
  },
  // informatique 1ere — maintenance
  {
    value: "types-maintenance",
    label: "Corrective ou préventive ?",
    description: "Classer des situations réelles selon le moment de l'intervention.",
  },
  {
    value: "arbre-maintenance",
    label: "L'arbre de la maintenance",
    description: "Placer les cinq branches, conditionnelle et prévisionnelle comprises.",
  },
  {
    value: "maintenance-logicielle",
    label: "Corrective, évolutive ou adaptative",
    description: "Dix tickets à classer, et la question qui tranche à chaque fois.",
  },
  {
    value: "protection-electrique",
    label: "Protéger une salle informatique",
    description: "Régulateur, parasurtenseur, onduleur face à trois incidents.",
  },
  {
    value: "diagnostic-panne",
    label: "Diagnostiquer une panne",
    description: "Six machines, et le moins de vérifications possible.",
  },
  {
    value: "boite-outils",
    label: "La boîte à outils",
    description: "Remplir sa sacoche avant de partir en intervention.",
  },
  {
    value: "types-virus",
    label: "Reconnaître les types de virus",
    description: "Ver, cheval de Troie, bombe logique, macrovirus, logiciel espion.",
  },
  {
    value: "machine-infectee",
    label: "La machine est-elle infectée ?",
    description: "Virus ou autre cause : refuser de conclure trop vite.",
  },
  {
    value: "scan-antivirus",
    label: "Analyser et nettoyer",
    description: "Réparer, supprimer, quarantaine ou ignorer — et les faux positifs.",
  },
  {
    value: "defragmentation",
    label: "Défragmenter un disque",
    description: "Les fichiers se morcellent, la tête de lecture saute, le temps monte.",
  },
  {
    value: "partitionnement",
    label: "Partitionner un disque",
    description: "Et pourquoi une partition n'est pas une sauvegarde.",
  },
  {
    value: "nettoyage-disque",
    label: "Rendre sa vitesse à une machine",
    description: "Espace libéré, programmes au démarrage, temps de démarrage.",
  },
  // informatique 1ere — algo-a
  {
    value: "parties-algorithme",
    label: "Reconstituer un algorithme",
    description: "En-tête, déclarations, corps : remettre les lignes dans l'ordre.",
  },
  {
    value: "analyse-probleme",
    label: "Analyser un problème",
    description: "Entrées, traitement, sorties — avant d'écrire la moindre ligne.",
  },
  {
    value: "choix-types",
    label: "Choisir le bon type",
    description: "Entier, réel, caractère, chaîne, booléen, et les deux pièges.",
  },
  {
    value: "trace-variables",
    label: "Dérouler un algorithme",
    description: "Le tableau de trace, ligne par ligne, et l'échange avec ou sans temp.",
  },
  {
    value: "operateurs",
    label: "div, mod et les opérateurs logiques",
    description: "La division posée, le test de parité, et les tables de vérité.",
  },
  // informatique 1ere — algo-b
  {
    value: "si-alors-sinon",
    label: "Suivre le chemin d'un Si",
    description: "La branche qui s'allume, et le cas limite de l'égalité.",
  },
  {
    value: "conditions-composees",
    label: "Les mentions, et le piège de l'ordre",
    description: "Réordonner les tests et voir un 18 repartir avec « Passable ».",
  },
  {
    value: "selon-cas",
    label: "Selon ou Si imbriqués ?",
    description: "Valeurs énumérables ou intervalles : la question qui tranche.",
  },
  {
    value: "boucle-tantque",
    label: "La boucle TantQue",
    description: "Initialisation, condition, progression — et la boucle infinie.",
  },
  {
    value: "boucle-pour",
    label: "La boucle Pour",
    description: "Début, fin, pas, et pourquoi elle ne peut pas être infinie.",
  },
  {
    value: "comparer-boucles",
    label: "TantQue et Répéter côte à côte",
    description: "Test au début ou à la fin : zéro tour contre un tour.",
  },
  {
    value: "tableaux",
    label: "Parcourir un tableau",
    description: "Somme, comptage, maximum en un seul passage — et les bornes.",
  },
  // informatique 1ere — algo-c
  {
    value: "fonction-procedure",
    label: "Procédure ou fonction ?",
    description: "Le résultat se récupère-t-il dans une variable ?",
  },
  {
    value: "procedure-parametres",
    label: "Passer des paramètres",
    description: "Formels et effectifs, l'ordre, les types, les variables locales.",
  },
  {
    value: "recursivite",
    label: "La récursivité en action",
    description: "La pile des appels, le cas de base, et ce qui arrive sans lui.",
  },
  // informatique 1ere — web-a
  {
    value: "editeur-html",
    label: "Ton premier éditeur HTML",
    description: "Tu tapes, le navigateur affiche, et les fautes sont signalées.",
  },
  {
    value: "structure-page",
    label: "Construire le squelette",
    description: "Ce qui va dans le head, ce qui va dans le body.",
  },
  {
    value: "balises-texte",
    label: "Les balises de texte",
    description: "Titres, paragraphes, strong et em — et la surprise des espaces.",
  },
  {
    value: "balise-image",
    label: "Insérer une image",
    description: "Le chemin, la casse, le alt, et la déformation.",
  },
  {
    value: "balise-lien",
    label: "Fabriquer des liens",
    description: "Interne, externe, ancre, mailto, et les quatre fautes classiques.",
  },
  {
    value: "listes-html",
    label: "Construire des listes",
    description: "ul, ol, dl, et l'imbrication qui casse la numérotation.",
  },
  {
    value: "tableaux-html",
    label: "Construire un tableau",
    description: "tr, th, td, colspan, et cellpadding contre cellspacing.",
  },
  // informatique 1ere — web-b
  {
    value: "formulaire-html",
    label: "get ou post ?",
    description: "Le mot de passe dans la barre d'adresse, et le champ sans name.",
  },
  {
    value: "champs-input",
    label: "Les types de champs",
    description: "Radio contre checkbox, et le name qui regroupe.",
  },
  {
    value: "formulaire-complet",
    label: "Assembler un formulaire",
    description: "Ce qui arrive au serveur, et ce qui reste en route.",
  },
  {
    value: "syntaxe-css",
    label: "La syntaxe CSS",
    description: "Sélecteur, propriété, valeur — et le point-virgule oublié.",
  },
  {
    value: "placements-css",
    label: "La cascade",
    description: "En ligne, interne, externe : laquelle gagne, et pourquoi.",
  },
  {
    value: "feuille-style",
    label: "Habiller une page",
    description: "Couleurs, police, bordure, et padding contre margin, coloriés.",
  },
  // informatique 1ere — infographie
  {
    value: "pixels-definition",
    label: "Définition, résolution et poids",
    description: "La même image imprimée à 72 puis à 300 points par pouce.",
  },
  {
    value: "matricielle-vectorielle",
    label: "Agrandir les deux sortes d'images",
    description: "Le zoom jusqu'à 1600 % : les pixels contre la formule.",
  },
  {
    value: "formats-image",
    label: "Choisir le bon format",
    description: "Huit situations, et un JPEG réenregistré dix fois.",
  },
  {
    value: "interface-photoshop",
    label: "L'interface d'un logiciel de retouche",
    description: "Les cinq parties, et la barre d'options qui change d'outil en outil.",
  },
  {
    value: "retouche-image",
    label: "Retoucher une photographie",
    description: "Luminosité, contraste, recadrage, calques — puis l'aplatissement.",
  },
  {
    value: "photomontage",
    label: "Réussir ou rater un photomontage",
    description: "Les cinq étapes, et un mode détective pour repérer les trucages.",
  },
  {
    value: "son-numerique",
    label: "Numériser un son",
    description: "Échantillonner, quantifier, et le calcul du poids.",
  },
  {
    value: "video-numerique",
    label: "Les réglages d'une vidéo",
    description: "Définition, cadence, compression, puis codec contre conteneur.",
  },
  // inf7-materiel-a
  {
    value: "types-systemes",
    label: "Types de systèmes informatiques",
    description:
      "Classer douze situations entre système personnel, d'organisation et de contrôle-commande.",
  },
  {
    value: "fiche-peripherique",
    label: "Fiche d'un périphérique",
    description:
      "Lire les caractéristiques d'un écran et comparer matricielle, jet d'encre et laser.",
  },
  {
    value: "types-logiciels",
    label: "Catégories de logiciels",
    description:
      "Ranger dix logiciels entre base, application standard, progiciel, spécifique et procédure.",
  },
  {
    value: "carte-mere",
    label: "Dans le boîtier",
    description:
      "Cliquer chaque composant pour son rôle et ses unités, et comparer ATX, microATX et ITX.",
  },
  {
    value: "pilote-peripherique",
    label: "Périphérique qui ne répond pas",
    description: "Mener les vérifications dans l'ordre et lire le gestionnaire de périphériques.",
  },
  {
    value: "fiche-technique",
    label: "Lire une fiche technique",
    description:
      "Décoder chaque ligne d'une fiche de revendeur et choisir la machine selon l'usage.",
  },
  // inf7-materiel-b
  {
    value: "causes-materielles",
    label: "Symptôme et cause matérielle",
    description:
      "Huit machines, huit symptômes, et le thermomètre du processeur qui monte avec la poussière.",
  },
  {
    value: "diagnostic-dysfonctionnement",
    label: "Matériel ou logiciel ?",
    description: "Trancher dix pannes grâce au test de la séquence de démarrage.",
  },
  {
    value: "risques-poste",
    label: "Sécuriser une salle",
    description:
      "Choisir ses mesures dans un budget, puis faire passer une année scolaire sur la salle.",
  },
  {
    value: "bloc-alimentation",
    label: "Le bloc d'alimentation",
    description:
      "Suivre les trois tensions continues et voir la machine redémarrer quand le bloc est trop juste.",
  },
  {
    value: "equipements-protection",
    label: "Régulateur, parasurtenseur, onduleur",
    description: "Douze combinaisons d'équipement et d'épreuve : un seul appareil passe les trois.",
  },
  {
    value: "dimensionner-onduleur",
    label: "Dimensionner un onduleur",
    description:
      "Additionner les consommations, convertir en VA, et voir l'imprimante laser faire disjoncter.",
  },
  {
    value: "roles-onduleur",
    label: "Ce qu'un onduleur protège",
    description: "Cocher les trois fonctions réelles d'un onduleur, et seulement celles-là.",
  },
  // inf7-tableur
  {
    value: "classeur-feuille",
    label: "Cellule, plage et feuilles",
    description:
      "Désigner une cellule, une plage, et comparer la même référence dans trois feuilles.",
  },
  {
    value: "mise-en-forme-cellule",
    label: "Mettre en forme un bulletin",
    description:
      "Bordures, fusion, orientation, retour à la ligne — avec l'aperçu avant impression.",
  },
  {
    value: "zone-impression",
    label: "Zone d'impression et protection",
    description:
      "Définir la zone, régler l'échelle, puis protéger la feuille et essayer d'écraser une formule.",
  },
  {
    value: "references-cellules",
    label: "Références et recopie",
    description:
      "Tirer la poignée de recopie, figer avec le dollar, et relier trois feuilles à un bilan.",
  },
  {
    value: "fonctions-tableur",
    label: "Les sept fonctions du programme",
    description: "Composer ses formules et voir SOMME.SI décomposé ligne par ligne.",
  },
  {
    value: "bulletin-notes",
    label: "Construire un bulletin",
    description:
      "Écrire chaque formule du bulletin et éviter les deux fautes que le correcteur cherche.",
  },
  // inf7-reseau-a
  {
    value: "pourquoi-reseau",
    label: "Pourquoi un réseau",
    description: "Relier huit postes isolés et chiffrer ce que le réseau fait économiser en un an.",
  },
  {
    value: "etendue-reseaux",
    label: "PAN, LAN, MAN, WAN",
    description:
      "Nommer le type de réseau de dix situations, et placer chacune sur une règle d'échelle.",
  },
  {
    value: "internet-intranet-extranet",
    label: "Internet, intranet, extranet",
    description:
      "Placer chaque ressource dans sa zone, puis faire frapper chaque visiteur à la porte.",
  },
  {
    value: "topologies-physiques",
    label: "Bus, étoile, anneau",
    description: "Construire les trois topologies, couper un câble, et voir ce qui tombe.",
  },
  {
    value: "topologies-logiques",
    label: "Ethernet contre le jeton",
    description:
      "Provoquer une collision, suivre le jeton, et voir la courbe s'inverser avec la charge.",
  },
  {
    value: "architectures-reseau",
    label: "Poste à poste ou client-serveur",
    description: "Suivre une requête, ajouter des postes, puis faire tomber le serveur.",
  },
  // inf7-reseau-b
  {
    value: "supports-transmission",
    label: "Choisir le support",
    description: "Six locaux, six contraintes : paire torsadée, coaxial, fibre ou Wi-Fi.",
  },
  {
    value: "cables-reseau",
    label: "Les câbles à l'épreuve",
    description:
      "Allonger la distance, ajouter des perturbations, et ouvrir la coupe de chaque câble.",
  },
  {
    value: "equipements-reseau",
    label: "Placer les équipements",
    description: "Hub ou switch au centre, routeur en sortie, et compter les trames qui circulent.",
  },
  {
    value: "protocoles-internet",
    label: "Quel protocole pour quelle action",
    description: "Désigner le protocole, puis faire descendre le message dans la pile TCP/IP.",
  },
  {
    value: "adresse-ip",
    label: "Composer une adresse IP",
    description:
      "Séparer partie réseau et partie hôte, et dire si deux machines se parlent directement.",
  },
  {
    value: "classes-adresses",
    label: "Les classes d'adresses",
    description:
      "Lire le premier octet sur une règle graduée, puis déduire masque, réseau et diffusion.",
  },
  // inf7-reseau-c
  {
    value: "carte-reseau",
    label: "Configurer la carte réseau",
    description: "Remplir les quatre champs TCP/IPv4 et introduire les trois erreurs classiques.",
  },
  {
    value: "monter-reseau",
    label: "Monter un réseau de trois postes",
    description: "Câbler, adresser, tester — et voir refuser les plans d'adressage impossibles.",
  },
  {
    value: "commandes-reseau",
    label: "ipconfig et ping",
    description:
      "Six machines en panne, et la chaîne de diagnostic du 127.0.0.1 jusqu'au nom de domaine.",
  },
  // inf7-merise-a
  {
    value: "decomposer-systeme",
    label: "Décomposer une organisation",
    description:
      "Extraire entités, propriétés et relations d'un énoncé, et comparer deux décompositions.",
  },
  {
    value: "niveaux-merise",
    label: "Les trois niveaux de MERISE",
    description: "Classer douze décisions de projet entre conceptuel, logique et physique.",
  },
  {
    value: "regles-gestion",
    label: "Surligner les règles de gestion",
    description: "Qualifier chaque mot d'un énoncé, et voir le MCD que les règles imposent.",
  },
  {
    value: "entite-propriete",
    label: "Construire une entité",
    description: "Nommer, choisir des propriétés atomiques, et désigner un identifiant qui tient.",
  },
  {
    value: "cardinalites",
    label: "Poser les cardinalités",
    description: "Les deux questions dans l'ordre, et ce que chaque couple autorise réellement.",
  },
  // inf7-merise-b
  {
    value: "cles-tables",
    label: "Clé primaire, clé étrangère",
    description: "Désigner les clés, puis voir la base refuser les insertions fautives.",
  },
  {
    value: "passage-mcd-mld",
    label: "Du MCD au MLD",
    description:
      "Choisir la règle, faire migrer la clé, et voir une table d'association apparaître.",
  },
  {
    value: "normaliser-mcd",
    label: "Normaliser un MCD",
    description: "Six MCD, six défauts, et le dégât concret que chacun aurait causé.",
  },
  // inf7-sgbd
  {
    value: "modeles-bd",
    label: "Fichiers séparés ou base de données",
    description: "Changer une adresse et voir trois fichiers sur quatre garder l'ancienne.",
  },
  {
    value: "fonctions-sgbd",
    label: "Les fonctions d'un SGBD",
    description: "Ranger dix opérations, et voir le moteur et l'interface travailler séparément.",
  },
  {
    value: "structure-table",
    label: "Anatomie d'une table",
    description: "Nommer champs, enregistrements et clés, puis provoquer chaque contrainte.",
  },
  // inf7-sql
  {
    value: "sous-langages-sql",
    label: "LDD, LMD, LCD",
    description: "Classer douze commandes, avec les pièges ALTER/UPDATE et DELETE/DROP.",
  },
  {
    value: "create-table",
    label: "Écrire un CREATE TABLE",
    description: "Un vrai éditeur SQL qui guette les quatre fautes classiques.",
  },
  {
    value: "alter-drop",
    label: "ALTER, DELETE, DROP",
    description: "Voir ce que chaque commande change, et ce qu'un vrai SGBD ne rendra jamais.",
  },
  {
    value: "insert-update-delete",
    label: "INSERT, UPDATE, DELETE",
    description: "Remplir une table, et être prévenu avant un UPDATE sans clause WHERE.",
  },
  {
    value: "requete-select",
    label: "Écrire des SELECT",
    description:
      "Interroger une base de lycée, et voir le produit cartésien exploser sans jointure.",
  },
  {
    value: "operateurs-sql",
    label: "Construire une condition",
    description: "Comparaisons, AND, OR, BETWEEN, IN, LIKE, IS NULL — et les deux pièges.",
  },
  // inf7-access
  {
    value: "interface-access",
    label: "L'interface d'Access",
    description: "Nommer chaque partie de la fenêtre et ouvrir les cinq familles d'objets.",
  },
  {
    value: "creer-table-access",
    label: "Créer une table sous Access",
    description: "Construire la table en mode Création, puis saisir en mode Feuille de données.",
  },
  {
    value: "feuille-donnees-access",
    label: "La feuille de données",
    description: "Trier, filtrer, lire le SQL qu'Access écrit, et provoquer les quatre refus.",
  },
  // inf7-algo-a
  {
    value: "familles-structures",
    label: "Reconnaître la famille",
    description: "Douze fragments à classer, avec leur organigramme et leur chemin d'exécution.",
  },
  {
    value: "alternatives-lda",
    label: "Dérouler une alternative",
    description:
      "Réordonner les tests des mentions et voir un élève à 18 repartir avec « Passable ».",
  },
  {
    value: "repetitives-lda",
    label: "Les trois boucles",
    description: "TantQue, Répéter et Pour en parallèle, boucle infinie et variable drapeau.",
  },
  // inf7-algo-b
  {
    value: "cinq-structures",
    label: "Les cinq structures de données",
    description: "Tableau, liste, pile et file côte à côte : le LIFO et le FIFO en action.",
  },
  {
    value: "structure-tableau",
    label: "Manipuler un tableau",
    description: "Déclarer, remplir, déborder, puis passer au tableau à deux dimensions.",
  },
  {
    value: "enregistrement",
    label: "Construire un enregistrement",
    description: "Définir un type champ par champ, et voir pourquoi un tableau n'y suffit pas.",
  },
  {
    value: "parcours-tableau",
    label: "Parcourir un tableau",
    description: "Initialiser, accumuler, exploiter — et voir ce que donne un accumulateur oublié.",
  },
  {
    value: "recherche-sequentielle",
    label: "La recherche séquentielle",
    description: "Avancer case par case, suivre le drapeau, et déplacer l'incrémentation.",
  },
  {
    value: "recherche-max",
    label: "Chercher le maximum",
    description: "Initialiser par tab[1] ou par 0, et voir l'algorithme rater un maximum négatif.",
  },
  {
    value: "trace-execution",
    label: "Remplir une trace d'exécution",
    description:
      "Remplir le tableau de trace ligne par ligne, du meilleur cas à la recherche vaine.",
  },
  // inf7-c-a
  {
    value: "langages-programmation",
    label: "Du source à l'exécution",
    description: "Le même programme en quatre langages, et le compilateur contre l'interpréteur.",
  },
  {
    value: "installer-ide",
    label: "Installer un IDE",
    description: "L'installation de Code::Blocks écran par écran, avec le « no compiler found ».",
  },
  {
    value: "structure-programme-c",
    label: "Assembler un programme C",
    description:
      "Remettre les cinq parties dans l'ordre et provoquer les trois erreurs fréquentes.",
  },
  {
    value: "variables-c",
    label: "Déclarer des variables en C",
    description: "Les règles de nommage, la mémoire, et le piège de la division entière.",
  },
  {
    value: "constantes-c",
    label: "Constantes et adresses",
    description: "#define contre const, et ce que scanf fait du & — ou sans lui.",
  },
  {
    value: "printf-scanf",
    label: "printf et scanf",
    description: "Composer un format, choisir ses arguments, et voir l'affichage absurde.",
  },
  // inf7-c-b
  {
    value: "if-else-c",
    label: "if, else if en C",
    description: "Évaluer une condition, puis remplacer == par = et mettre un ; après le if.",
  },
  {
    value: "switch-c",
    label: "Le switch",
    description: "Retirer les break un par un, et voir pourquoi les mentions exigent des else if.",
  },
  {
    value: "boucles-c",
    label: "Traduire les boucles en C",
    description:
      "Construire la traduction morceau par morceau, sans oublier d'inverser le Répéter.",
  },
  {
    value: "tableau-c",
    label: "Le tableau en C",
    description: "Le décalage des indices, la case oubliée, la case fantôme et le débordement.",
  },
  {
    value: "recherche-c",
    label: "La recherche séquentielle en C",
    description: "LDA et C en parallèle, avec les trois erreurs de traduction une par une.",
  },
  {
    value: "erreurs-c",
    label: "Le chasseur d'erreurs",
    description: "Cliquer la ligne fautive, nommer sa famille, la corriger, et relancer.",
  },
  // philo-afrique
  {
    value: "distinguer-philosophie",
    label: "Proverbe, sagesse ou philosophie ?",
    description: "Les trois critères appliqués à douze énoncés, de Ptahhotep à Njoh Mouelle.",
  },
  {
    value: "these-auteur-africaine",
    label: "Attribuer une thèse à son auteur",
    description: "Six thèses sans leur nom, et les fiches des huit auteurs du chapitre.",
  },
  {
    value: "frise-philo-africaine",
    label: "La frise de la philosophie africaine",
    description: "Onze philosophes à remettre dans l'ordre, puis Thalès sur la même frise.",
  },
  {
    value: "courants-philo-africaine",
    label: "Les trois courants, et la querelle jouée",
    description: "Ethnophilosophie, critique, troisième voie — puis répondre aux objections.",
  },
  // philo-methode
  {
    value: "bareme-epreuve",
    label: "Le barème de l'épreuve, et le temps",
    description: "Répartir les 20 points, puis les 240 minutes entre les deux parties.",
  },
  {
    value: "analyser-sujet",
    label: "Analyser un sujet en six cases",
    description: "Concepts, reformulation, présupposé, thèse opposée, problème, problématique.",
  },
  {
    value: "plan-dissertation",
    label: "Construire le plan",
    description:
      "Placer douze arguments, reconnaître la forme du libellé, rédiger les transitions.",
  },
  {
    value: "quatre-taches-texte",
    label: "Les quatre tâches de la partie I",
    description:
      "Thème, problème, thèse, structure logique — et les paraphrases qui coûtent des points.",
  },
  {
    value: "definir-concept",
    label: "Définir un concept",
    description: "Genre prochain et différence spécifique, contre le cercle vicieux et l'exemple.",
  },
  {
    value: "theme-probleme-these",
    label: "Thème, problème, thèse",
    description: "Douze réponses de candidats à classer, dont quatre qui ne répondent à rien.",
  },
  {
    value: "structure-texte",
    label: "La structure logique d'un texte",
    description: "Postulat, arguments, objection, exemple, conclusion — puis le paragraphe rédigé.",
  },
  // philo-conscience
  {
    value: "notions-conscience",
    label: "Conscience psychologique, morale, inconscient",
    description: "Douze situations, et les deux sens du mot inconscient.",
  },
  {
    value: "doute-cartesien",
    label: "Mener le doute cartésien",
    description: "Les sens, le calcul, le corps, le malin génie — puis essayer de nier le cogito.",
  },
  {
    value: "topiques-freud",
    label: "Les deux topiques de Freud",
    description: "Placer les éléments, dire quelle instance parle, affronter Alain et Popper.",
  },
  {
    value: "connaitre-autrui",
    label: "Connaître autrui",
    description: "Intuition, analogie, dialogue — et la limite que Sartre et Hegel discutent.",
  },
  {
    value: "etat-de-nature",
    label: "L'état de nature : Hobbes ou Rousseau ?",
    description: "Régler les vivres, la promiscuité et l'autorité, et voir le groupe basculer.",
  },
  {
    value: "imperatif-categorique",
    label: "L'impératif catégorique à l'épreuve",
    description: "Universaliser six maximes, puis les comparer au calcul utilitariste.",
  },
  // philo-droit
  {
    value: "legal-legitime",
    label: "Légal ou légitime ?",
    description: "Douze situations sur deux axes, et les quatre cases du tableau se remplissent.",
  },
  {
    value: "droit-plus-fort",
    label: "Le droit du plus fort",
    description:
      "Déplacer le rapport de forces, voir les lois se réécrire, puis la question de Rousseau.",
  },
  {
    value: "droit-perfectible",
    label: "Un droit perfectible",
    description: "Six lois abolies, et toujours au nom d'un principe extérieur à la loi.",
  },
  {
    value: "notions-etat",
    label: "État, gouvernement, nation, pouvoir",
    description: "Quinze énoncés, dont le coup d'État qui piège presque tout le monde.",
  },
  {
    value: "trois-contrats",
    label: "Les trois contrats",
    description: "Hobbes, Locke, Rousseau : un état de nature, un contrat, un droit de révolte.",
  },
  {
    value: "quel-etat",
    label: "Quel État ?",
    description: "Quatre curseurs, trois jauges, et le verdict nomme le penseur correspondant.",
  },
  // philo-liberte
  {
    value: "determinisme-fatalisme",
    label: "Déterminisme ou fatalisme ?",
    description: "Douze propos à classer, et la conséquence pratique de chacun.",
  },
  {
    value: "causes-et-marge",
    label: "Les causes et la marge",
    description: "Activer cinq déterminismes, voir la zone des choix se rétrécir sans disparaître.",
  },
  {
    value: "tribunal-circonstances",
    label: "Le tribunal des circonstances",
    description:
      "Fixer la part de liberté de huit auteurs, et essayer les deux positions extrêmes.",
  },
  {
    value: "peres-panafricanisme",
    label: "Les pères du panafricanisme",
    description: "Diaspora ou continent, et les douze figures avec leurs ouvrages.",
  },
  {
    value: "casablanca-monrovia",
    label: "Casablanca ou Monrovia ?",
    description: "Cinq leviers à régler à la table d'Addis-Abeba, en 1963.",
  },
  {
    value: "croissance-developpement",
    label: "Croissance ou développement ?",
    description: "Répartir un budget sur vingt ans, et regarder les deux courbes diverger.",
  },
  // philo-science
  {
    value: "opinion-croyance-science",
    label: "Opinion, croyance ou science ?",
    description: "Quinze énoncés, et le critère de Popper découvert en l'appliquant.",
  },
  {
    value: "laboratoire-bernard",
    label: "Le laboratoire de Claude Bernard",
    description: "L'enquête réelle sur l'urine des lapins, en quatre étapes, sans raccourci.",
  },
  {
    value: "comite-ethique",
    label: "Le comité d'éthique",
    description: "Huit projets à autoriser ou refuser, et ce qu'ils donnent dix ans plus tard.",
  },
  {
    value: "essence-existence",
    label: "Essence ou existence d'abord ?",
    description: "Le modèle de l'artisan, puis la question que Sartre lui oppose.",
  },
  {
    value: "cinq-attitudes-mort",
    label: "Cinq philosophes au chevet",
    description: "Épicure, Platon, Spinoza, Heidegger et les traditions africaines répondent.",
  },
  {
    value: "vie-sans-fin",
    label: "Une vie sans fin",
    description: "Une liste de choses à faire, avec un temps infini puis un temps compté.",
  },
  // philo-dieu
  {
    value: "positions-religieuses",
    label: "Théisme, déisme, athéisme, agnosticisme",
    description: "Douze affirmations, dont quatre qui ne portent pas sur l'existence de Dieu.",
  },
  {
    value: "preuves-de-dieu",
    label: "Les preuves au tribunal",
    description: "Les trois preuves pas à pas, et l'endroit exact où chacune cède.",
  },
  {
    value: "religion-deux-usages",
    label: "La même religion, deux usages",
    description: "Dix situations historiques, et deux lignes qui citent le même texte.",
  },
  {
    value: "verite-validite",
    label: "Vrai, valide, ou ni l'un ni l'autre",
    description: "Douze raisonnements et deux questions indépendantes pour chacun.",
  },
  {
    value: "atelier-syllogisme",
    label: "L'atelier du syllogisme",
    description: "Vingt-cinq combinaisons, vérifiées règle par règle.",
  },
  {
    value: "detecteur-sophismes",
    label: "Le détecteur de sophismes",
    description: "Douze arguments à juger, dont trois qu'il faut savoir laisser passer.",
  },
  // fr3-phrase
  {
    value: "types-de-phrases",
    label: "Reconnaître le type d'une phrase",
    description: "Douze phrases sans leur ponctuation, et trois pièges où le signe ment.",
  },
  {
    value: "formes-de-phrase",
    label: "Transformer une phrase",
    description:
      "Négative, passive, emphatique : l'atelier surveille le « ne » oublié et le temps de l'auxiliaire.",
  },
  {
    value: "constituants-phrase",
    label: "L'atelier des deux tests",
    description: "Supprimer, déplacer, conclure : obligatoire ou facultatif, puis la fonction.",
  },
  {
    value: "compter-propositions",
    label: "Compter les propositions",
    description: "Cliquer les verbes conjugués, avec l'infinitif et le participe en embuscade.",
  },
  {
    value: "juxtaposition-coordination",
    label: "Juxtaposées ou coordonnées ?",
    description: "Les sept conjonctions, et le piège de « car » contre « parce que ».",
  },
  {
    value: "propositions-bepc",
    label: "La question 5 du BEPC",
    description: "Relever, nommer, donner la fonction — la méthode en trois gestes.",
  },
  // fr3-accords
  {
    value: "trouver-le-sujet",
    label: "Qui est-ce qui ?",
    description: "Le sujet inversé et les trois écrans qui font rater l'accord.",
  },
  {
    value: "accord-collectif",
    label: "Collectifs et pronoms relatifs",
    description: "« La plupart de », l'article défini, et l'antécédent de « qui ».",
  },
  {
    value: "chasse-accords",
    label: "La chasse aux fautes d'accord",
    description: "Trois textes fautifs, avec des verbes corrects glissés au milieu.",
  },
  {
    value: "temps-indicatif",
    label: "L'atelier des temps composés",
    description: "Trois pièces à assembler : l'auxiliaire, son temps, le participe passé.",
  },
  {
    value: "passe-simple",
    label: "Le passé simple",
    description: "Huit tableaux à remplir, ceux qui tombent à la question 4 du BEPC.",
  },
  {
    value: "imparfait-passe-simple",
    label: "Installer le décor, puis l'événement",
    description: "Le texte se colore en arrière-plan et premier plan.",
  },
  // fr3-lecture
  {
    value: "champ-lexical",
    label: "La question 2 du BEPC",
    description: "Relever un champ lexical, et le distinguer d'une famille de mots.",
  },
  {
    value: "nuancer-sentiment",
    label: "L'échelle des sentiments",
    description: "D'agacé à fou de rage : viser le mot exact, et garder les mots forts.",
  },
  {
    value: "montrer-sentiment",
    label: "Montrer au lieu de dire",
    description: "Par le corps, par l'action, par la comparaison.",
  },
  {
    value: "lecture-methodique",
    label: "Les quatre temps de la lecture",
    description: "Situer, repérer, interpréter, conclure — et l'étape que les copies sautent.",
  },
  {
    value: "fiche-lecture",
    label: "La fiche de lecture",
    description: "Six cases sur « Ville cruelle », avec les erreurs classiques.",
  },
  {
    value: "etude-de-texte-bepc",
    label: "L'épreuve d'étude de texte",
    description: "Huit questions notées au barème officiel, compréhension et langue.",
  },
  // fr3-expression
  {
    value: "schema-narratif",
    label: "Bâtir le schéma avant d'écrire",
    description: "Cinq étapes, et les proportions que les correcteurs guettent.",
  },
  {
    value: "schema-actanciel",
    label: "Remplir les six cases",
    description: "Sujet, objet, destinateur, destinataire, adjuvants, opposants.",
  },
  {
    value: "point-de-vue",
    label: "La même scène, trois points de vue",
    description: "Externe, interne, omnisciente — et la rupture à débusquer.",
  },
  {
    value: "raconter-oral",
    label: "L'atelier de l'accroche",
    description: "Entrer dans l'histoire, situer, annoncer, conclure.",
  },
  {
    value: "compte-rendu-film",
    label: "Préparer le compte rendu",
    description: "Cinq moments, cinq minutes, et la fin qu'on ne raconte pas.",
  },
  {
    value: "voix-et-corps",
    label: "La console de l'orateur",
    description: "Volume, débit, articulation, intonation, posture et silence.",
  },
  // fr3-subordonnees
  {
    value: "pronom-relatif",
    label: "Choisir le pronom relatif",
    description: "Seize phrases, et la phrase refaite qui fait apparaître la préposition.",
  },
  {
    value: "relative-determinative",
    label: "La virgule qui change tout",
    description: "Avec ou sans virgules : certains, ou tous. Et trois phrases de règlement.",
  },
  {
    value: "fonction-du-relatif",
    label: "Nature et fonction, question par question",
    description: "On cache la principale, on lit la relative seule, on recolle les morceaux.",
  },
  {
    value: "completive-cod",
    label: "La complétive et sa fonction",
    description: "Le test du remplacement par un groupe nominal, et les quatre fonctions rares.",
  },
  {
    value: "que-relatif-ou-completive",
    label: "Trier les « que »",
    description: "Vingt phrases, trois paniers, et les faux amis de la comparaison.",
  },
  {
    value: "indicatif-ou-subjonctif",
    label: "Indicatif ou subjonctif ?",
    description: "La famille du verbe principal décide, et l'oreille tranche par « être ».",
  },
  // fr3-orthographe
  {
    value: "homophone-contexte",
    label: "Le mot qui convient",
    description: "La nature d'abord, la famille ensuite : l'oreille ne sert à rien.",
  },
  {
    value: "famille-de-mots",
    label: "Remonter à la famille",
    description: "Verdir réveille le d de vert, verrier les deux r de verre.",
  },
  {
    value: "dictee-homophones",
    label: "La dictée corrigée",
    description: "Six textes, leurs homophones surlignés, et le test qui convient à chacun.",
  },
  {
    value: "futur-ou-conditionnel",
    label: "Futur ou conditionnel ?",
    description: "Vingt phrases, et le test du « il » qui sépare prendra de prendrait.",
  },
  {
    value: "valeurs-conditionnel",
    label: "La valeur du conditionnel",
    description: "Regret, reproche, irréel du passé, information non confirmée.",
  },
  {
    value: "systeme-hypothetique",
    label: "Le système hypothétique",
    description: "Trois systèmes, dix-huit phrases, et le « si j'aurais » refusé.",
  },
  // fr3-argumenter
  {
    value: "denote-connote",
    label: "Dénotation ou connotation ?",
    description: "Le dictionnaire, puis les images — dont celles propres à notre culture.",
  },
  {
    value: "echelle-connotation",
    label: "L'échelle de l'intensité",
    description: "Cinq situations de gravité croissante, et le piège de la surenchère.",
  },
  {
    value: "mot-choisi",
    label: "Réécrire dans l'autre camp",
    description: "Six textes qui basculent sans qu'un seul fait change.",
  },
  {
    value: "trier-argumentation",
    label: "Thèse, arguments et exemples",
    description: "Le général et le particulier, avec un exemple fictif pour piège.",
  },
  {
    value: "proceder-argumentation",
    label: "Nommer les procédés",
    description: "Concession, question rhétorique, analogie, absurde, autorité, ironie.",
  },
  {
    value: "lecture-argumentative",
    label: "La lecture en cinq étapes",
    description: "Du paratexte à la réponse citée, dans l'ordre de l'épreuve.",
  },
  // fr3-debat
  {
    value: "temoignage-argument",
    label: "Du récit à l'argument",
    description: "Préciser, élaguer, conclure au présent : trois passes sur un témoignage.",
  },
  {
    value: "plan-dialectique",
    label: "Construire son plan",
    description: "Le verbe de la consigne, l'ordre des arguments, la synthèse qui déplace.",
  },
  {
    value: "redaction-argumentee",
    label: "Composer et se faire corriger",
    description: "Brouillon imposé, panneau du correcteur, et les cinq fautes qui coûtent.",
  },
  {
    value: "intervention-orale",
    label: "Construire son intervention",
    description: "Quatre blocs, deux minutes, les silences — et le traqueur de tics.",
  },
  {
    value: "contredire-poliment",
    label: "Remonter l'échelle",
    description: "Vingt répliques, l'attaque de la personne et l'homme de paille.",
  },
  {
    value: "debat-regle",
    label: "Le débat réglé",
    description: "Modérateur : temps de parole, reprises, conclusion sans donner son avis.",
  },
  // fr3-circonstancielles
  {
    value: "nommer-circonstancielle",
    label: "Nommer la circonstancielle",
    description: "Les sept sens, la conjonction qui les annonce, et le test du déplacement.",
  },
  {
    value: "mode-circonstancielle",
    label: "Indicatif ou subjonctif après la conjonction",
    description: "Fait accompli ou non réalisé : toute la règle tient à cette question.",
  },
  {
    value: "question-cinq-bepc",
    label: "La question 5, en entier",
    description: "Cinq gestes imposés, et les faux verbes refusés un par un.",
  },
  {
    value: "ponctuer-dialogue",
    label: "Ponctuer un dialogue",
    description: "Deux-points, guillemets, tirets, virgules d'incise — et les verbes de parole.",
  },
  {
    value: "direct-indirect",
    label: "Du direct à l'indirect",
    description: "Quatre changements dans l'ordre, et le piège de l'introducteur au présent.",
  },
  {
    value: "formes-discours",
    label: "Les quatre formes du même épisode",
    description: "Direct, indirect, indirect libre, narrativisé — et ce que chacune fait au récit.",
  },
  // fr3-grammatical
  {
    value: "tests-homophones-gram",
    label: "Le test de chaque couple",
    description: "Treize couples, treize remplacements, et ta liste personnelle à la fin.",
  },
  {
    value: "a-ou-a",
    label: "Le « a » et le « on n' »",
    description: "Les mots de négation surlignés, et le « n' » qu'on entend enfin.",
  },
  {
    value: "dictee-grammaticale",
    label: "La dictée grammaticale",
    description: "Huit textes, le test appliqué devant toi, et un cas que rien ne tranche.",
  },
  {
    value: "former-subjonctif",
    label: "Fabriquer le subjonctif",
    description: "Les trois gestes imposés, et les sept irréguliers à part.",
  },
  {
    value: "subjonctif-ou-indicatif-1g",
    label: "Subjonctif ou indicatif au 1er groupe",
    description: "Le même verbe, la même personne, et un i qui change tout.",
  },
  {
    value: "declencheurs-subjonctif",
    label: "Les sept déclencheurs",
    description: "Vingt-huit phrases, et les six faux déclencheurs montés contre les vrais.",
  },
  // fr3-tragedie
  {
    value: "relever-modalisateurs",
    label: "Relever les modalisateurs",
    description: "Dix textes, et les adverbes qui n'en sont pas.",
  },
  {
    value: "degre-adhesion",
    label: "Le curseur du degré d'adhésion",
    description: "Sept crans, de « je garantis » à « je rapporte sans y croire ».",
  },
  {
    value: "appreciatif-depreciatif",
    label: "Appréciatif, dépréciatif, neutre",
    description: "Vingt-quatre mots à ranger, dont une ironie qui retourne le jugement.",
  },
  {
    value: "structure-tragedie",
    label: "La structure de la tragédie",
    description: "Les cinq actes, les trois unités, et les neuf termes du théâtre.",
  },
  {
    value: "dilemme-andromaque",
    label: "Le dilemme d'Andromaque",
    description: "Deux portes, aucune tenable — puis la troisième, que Racine a inventée.",
  },
  {
    value: "lire-scene-tragedie",
    label: "Lire une scène de tragédie",
    description: "Sept temps, de la situation de la scène au moule de réponse.",
  },
  // fr3-argumenter2
  {
    value: "hierarchiser-arguments",
    label: "Hiérarchiser ses arguments",
    description: "Éliminer d'abord, classer ensuite — et entendre l'ordre inverse.",
  },
  {
    value: "rediger-transition",
    label: "Rédiger la transition",
    description: "Trois temps vérifiés, et le piège du résumé déguisé.",
  },
  {
    value: "paragraphe-argumentatif",
    label: "Bâtir le paragraphe",
    description: "Argument, explication, exemple, mini-conclusion — et six à réparer.",
  },
  {
    value: "exprimer-opinion",
    label: "L'échelle de l'engagement",
    description: "Adapter ce qu'on affirme à ce qu'on sait, et quitter le registre familier.",
  },
  {
    value: "presenter-stand",
    label: "La console du stand",
    description: "Les trois choses à faire retenir, les quatre temps, et l'affiche de sept mots.",
  },
  {
    value: "repondre-questions",
    label: "La salle de questions",
    description: "Quatre gestes imposés, et dix questions dont deux sans réponse.",
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
  // info1-materiel
  "schema-fonctionnel": SchemaFonctionnel,
  "unites-mesure": UnitesMesure,
  "composants-uc": ComposantsUc,
  "caracteristiques-cpu": CaracteristiquesCpu,
  "couches-systeme": CouchesSysteme,
  "bus-ordinateur": BusOrdinateur,
  "demarrage-bios": DemarrageBios,
  // info1-maintenance
  "types-maintenance": TypesMaintenance,
  "arbre-maintenance": ArbreMaintenance,
  "maintenance-logicielle": MaintenanceLogicielle,
  "protection-electrique": ProtectionElectrique,
  "diagnostic-panne": DiagnosticPanne,
  "boite-outils": BoiteOutils,
  "types-virus": TypesVirus,
  "machine-infectee": MachineInfectee,
  "scan-antivirus": ScanAntivirus,
  defragmentation: Defragmentation,
  partitionnement: Partitionnement,
  "nettoyage-disque": NettoyageDisque,
  // info1-algo-a
  "parties-algorithme": PartiesAlgorithme,
  "analyse-probleme": AnalyseProbleme,
  "choix-types": ChoixTypes,
  "trace-variables": TraceVariables,
  operateurs: Operateurs,
  // info1-algo-b
  "si-alors-sinon": SiAlorsSinon,
  "conditions-composees": ConditionsComposees,
  "selon-cas": SelonCas,
  "boucle-tantque": BoucleTantque,
  "boucle-pour": BouclePour,
  "comparer-boucles": ComparerBoucles,
  tableaux: Tableaux,
  // info1-algo-c
  "fonction-procedure": FonctionProcedure,
  "procedure-parametres": ProcedureParametres,
  recursivite: Recursivite,
  // info1-web-a
  "editeur-html": EditeurHtml,
  "structure-page": StructurePage,
  "balises-texte": BalisesTexte,
  "balise-image": BaliseImage,
  "balise-lien": BaliseLien,
  "listes-html": ListesHtml,
  "tableaux-html": TableauxHtml,
  // info1-web-b
  "formulaire-html": FormulaireHtml,
  "champs-input": ChampsInput,
  "formulaire-complet": FormulaireComplet,
  "syntaxe-css": SyntaxeCss,
  "placements-css": PlacementsCss,
  "feuille-style": FeuilleStyle,
  // info1-infographie
  "pixels-definition": PixelsDefinition,
  "matricielle-vectorielle": MatricielleVectorielle,
  "formats-image": FormatsImage,
  "interface-photoshop": InterfacePhotoshop,
  "retouche-image": RetoucheImage,
  photomontage: Photomontage,
  "son-numerique": SonNumerique,
  "video-numerique": VideoNumerique,
  // inf7-materiel-a
  "types-systemes": TypesSystemes,
  "fiche-peripherique": FichePeripherique,
  "types-logiciels": TypesLogiciels,
  "carte-mere": CarteMere,
  "pilote-peripherique": PilotePeripherique,
  "fiche-technique": FicheTechnique,
  // inf7-materiel-b
  "causes-materielles": CausesMaterielles,
  "diagnostic-dysfonctionnement": DiagnosticDysfonctionnement,
  "risques-poste": RisquesPoste,
  "bloc-alimentation": BlocAlimentation,
  "equipements-protection": EquipementsProtection,
  "dimensionner-onduleur": DimensionnerOnduleur,
  "roles-onduleur": RolesOnduleur,
  // inf7-tableur
  "classeur-feuille": ClasseurFeuille,
  "mise-en-forme-cellule": MiseEnFormeCellule,
  "zone-impression": ZoneImpression,
  "references-cellules": ReferencesCellules,
  "fonctions-tableur": FonctionsTableur,
  "bulletin-notes": BulletinNotes,
  // inf7-reseau-a
  "pourquoi-reseau": PourquoiReseau,
  "etendue-reseaux": EtendueReseaux,
  "internet-intranet-extranet": InternetIntranetExtranet,
  "topologies-physiques": TopologiesPhysiques,
  "topologies-logiques": TopologiesLogiques,
  "architectures-reseau": ArchitecturesReseau,
  // inf7-reseau-b
  "supports-transmission": SupportsTransmission,
  "cables-reseau": CablesReseau,
  "equipements-reseau": EquipementsReseau,
  "protocoles-internet": ProtocolesInternet,
  "adresse-ip": AdresseIp,
  "classes-adresses": ClassesAdresses,
  // inf7-reseau-c
  "carte-reseau": CarteReseau,
  "monter-reseau": MonterReseau,
  "commandes-reseau": CommandesReseau,
  // inf7-merise-a
  "decomposer-systeme": DecomposerSysteme,
  "niveaux-merise": NiveauxMerise,
  "regles-gestion": ReglesGestion,
  "entite-propriete": EntitePropriete,
  cardinalites: Cardinalites,
  // inf7-merise-b
  "cles-tables": ClesTables,
  "passage-mcd-mld": PassageMcdMld,
  "normaliser-mcd": NormaliserMcd,
  // inf7-sgbd
  "modeles-bd": ModelesBd,
  "fonctions-sgbd": FonctionsSgbd,
  "structure-table": StructureTable,
  // inf7-sql
  "sous-langages-sql": SousLangagesSql,
  "create-table": CreateTable,
  "alter-drop": AlterDrop,
  "insert-update-delete": InsertUpdateDelete,
  "requete-select": RequeteSelect,
  "operateurs-sql": OperateursSql,
  // inf7-access
  "interface-access": InterfaceAccess,
  "creer-table-access": CreerTableAccess,
  "feuille-donnees-access": FeuilleDonneesAccess,
  // inf7-algo-a
  "familles-structures": FamillesStructures,
  "alternatives-lda": AlternativesLda,
  "repetitives-lda": RepetitivesLda,
  // inf7-algo-b
  "cinq-structures": CinqStructures,
  "structure-tableau": StructureTableau,
  enregistrement: Enregistrement,
  "parcours-tableau": ParcoursTableau,
  "recherche-sequentielle": RechercheSequentielle,
  "recherche-max": RechercheMax,
  "trace-execution": TraceExecution,
  // inf7-c-a
  "langages-programmation": LangagesProgrammation,
  "installer-ide": InstallerIde,
  "structure-programme-c": StructureProgrammeC,
  "variables-c": VariablesC,
  "constantes-c": ConstantesC,
  "printf-scanf": PrintfScanf,
  // inf7-c-b
  "if-else-c": IfElseC,
  "switch-c": SwitchC,
  "boucles-c": BouclesC,
  "tableau-c": TableauC,
  "recherche-c": RechercheC,
  "erreurs-c": ErreursC,
  // philo-afrique
  "distinguer-philosophie": DistinguerPhilosophie,
  "these-auteur-africaine": TheseAuteurAfricaine,
  "frise-philo-africaine": FrisePhiloAfricaine,
  "courants-philo-africaine": CourantsPhiloAfricaine,
  // philo-methode
  "bareme-epreuve": BaremeEpreuve,
  "analyser-sujet": AnalyserSujet,
  "plan-dissertation": PlanDissertation,
  "quatre-taches-texte": QuatreTachesTexte,
  "definir-concept": DefinirConcept,
  "theme-probleme-these": ThemeProblemeThese,
  "structure-texte": StructureTexte,
  // philo-conscience
  "notions-conscience": NotionsConscience,
  "doute-cartesien": DouteCartesien,
  "topiques-freud": TopiquesFreud,
  "connaitre-autrui": ConnaitreAutrui,
  "etat-de-nature": EtatDeNature,
  "imperatif-categorique": ImperatifCategorique,
  // philo-droit
  "legal-legitime": LegalLegitime,
  "droit-plus-fort": DroitPlusFort,
  "droit-perfectible": DroitPerfectible,
  "notions-etat": NotionsEtat,
  "trois-contrats": TroisContrats,
  "quel-etat": QuelEtat,
  // philo-liberte
  "determinisme-fatalisme": DeterminismeFatalisme,
  "causes-et-marge": CausesEtMarge,
  "tribunal-circonstances": TribunalCirconstances,
  "peres-panafricanisme": PeresPanafricanisme,
  "casablanca-monrovia": CasablancaMonrovia,
  "croissance-developpement": CroissanceDeveloppement,
  // philo-science
  "opinion-croyance-science": OpinionCroyanceScience,
  "laboratoire-bernard": LaboratoireBernard,
  "comite-ethique": ComiteEthique,
  "essence-existence": EssenceExistence,
  "cinq-attitudes-mort": CinqAttitudesMort,
  "vie-sans-fin": VieSansFin,
  // philo-dieu
  "positions-religieuses": PositionsReligieuses,
  "preuves-de-dieu": PreuvesDeDieu,
  "religion-deux-usages": ReligionDeuxUsages,
  "verite-validite": VeriteValidite,
  "atelier-syllogisme": AtelierSyllogisme,
  "detecteur-sophismes": DetecteurSophismes,
  // fr3-phrase
  "types-de-phrases": TypesDePhrases,
  "formes-de-phrase": FormesDePhrase,
  "constituants-phrase": ConstituantsPhrase,
  "compter-propositions": CompterPropositions,
  "juxtaposition-coordination": JuxtapositionCoordination,
  "propositions-bepc": PropositionsBepc,
  // fr3-accords
  "trouver-le-sujet": TrouverLeSujet,
  "accord-collectif": AccordCollectif,
  "chasse-accords": ChasseAccords,
  "temps-indicatif": TempsIndicatif,
  "passe-simple": PasseSimple,
  "imparfait-passe-simple": ImparfaitPasseSimple,
  // fr3-lecture
  "champ-lexical": ChampLexical,
  "nuancer-sentiment": NuancerSentiment,
  "montrer-sentiment": MontrerSentiment,
  "lecture-methodique": LectureMethodique,
  "fiche-lecture": FicheLecture,
  "etude-de-texte-bepc": EtudeDeTexteBepc,
  // fr3-expression
  "schema-narratif": SchemaNarratif,
  "schema-actanciel": SchemaActanciel,
  "point-de-vue": PointDeVue,
  "raconter-oral": RaconterOral,
  "compte-rendu-film": CompteRenduFilm,
  "voix-et-corps": VoixEtCorps,
  // fr3-subordonnees
  "pronom-relatif": PronomRelatif,
  "relative-determinative": RelativeDeterminative,
  "fonction-du-relatif": FonctionDuRelatif,
  "completive-cod": CompletiveCod,
  "que-relatif-ou-completive": QueRelatifOuCompletive,
  "indicatif-ou-subjonctif": IndicatifOuSubjonctif,
  // fr3-orthographe
  "homophone-contexte": HomophoneContexte,
  "famille-de-mots": FamilleDeMots,
  "dictee-homophones": DicteeHomophones,
  "futur-ou-conditionnel": FuturOuConditionnel,
  "valeurs-conditionnel": ValeursConditionnel,
  "systeme-hypothetique": SystemeHypothetique,
  // fr3-argumenter
  "denote-connote": DenoteConnote,
  "echelle-connotation": EchelleConnotation,
  "mot-choisi": MotChoisi,
  "trier-argumentation": TrierArgumentation,
  "proceder-argumentation": ProcederArgumentation,
  "lecture-argumentative": LectureArgumentative,
  // fr3-debat
  "temoignage-argument": TemoignageArgument,
  "plan-dialectique": PlanDialectique,
  "redaction-argumentee": RedactionArgumentee,
  "intervention-orale": InterventionOrale,
  "contredire-poliment": ContredirePoliment,
  "debat-regle": DebatRegle,
  // fr3-circonstancielles
  "nommer-circonstancielle": NommerCirconstancielle,
  "mode-circonstancielle": ModeCirconstancielle,
  "question-cinq-bepc": QuestionCinqBepc,
  "ponctuer-dialogue": PonctuerDialogue,
  "direct-indirect": DirectIndirect,
  "formes-discours": FormesDiscours,
  // fr3-grammatical
  "tests-homophones-gram": TestsHomophonesGram,
  "a-ou-a": AOuA,
  "dictee-grammaticale": DicteeGrammaticale,
  "former-subjonctif": FormerSubjonctif,
  "subjonctif-ou-indicatif-1g": SubjonctifOuIndicatif1g,
  "declencheurs-subjonctif": DeclencheursSubjonctif,
  // fr3-tragedie
  "relever-modalisateurs": RelevierModalisateurs,
  "degre-adhesion": DegreAdhesion,
  "appreciatif-depreciatif": AppreciatifDepreciatif,
  "structure-tragedie": StructureTragedie,
  "dilemme-andromaque": DilemmeAndromaque,
  "lire-scene-tragedie": LireSceneTragedie,
  // fr3-argumenter2
  "hierarchiser-arguments": HierarchiserArguments,
  "rediger-transition": RedigerTransition,
  "paragraphe-argumentatif": ParagrapheArgumentatif,
  "exprimer-opinion": ExprimerOpinion,
  "presenter-stand": PresenterStand,
  "repondre-questions": RepondreQuestions,
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
