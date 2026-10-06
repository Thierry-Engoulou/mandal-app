import { createFileRoute, Link, useNavigate } from "@tanstack/react-router";
import { useQuery } from "@tanstack/react-query";
import { useState, useEffect } from "react";
import { z } from "zod";
import {
  GraduationCap,
  BookOpen,
  Award,
  CheckCircle2,
  Binary,
  ArrowRight,
  ArrowLeft,
  Sparkles,
  Layers,
  ChevronRight,
  PlayCircle,
  FileText,
  Lock,
  Search,
  Check,
  Building2,
  Cpu,
  Atom,
  Calculator,
  Compass,
  FileCheck2,
  HelpCircle,
  Flame,
} from "lucide-react";
import { MandalLogo } from "@/components/mandal-logo";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { AuthRequiredModal } from "@/components/auth-required-modal";
import { supabase } from "@/integrations/supabase/client";
import { cn } from "@/lib/utils";

const educationSearchSchema = z.object({
  niveau: z.string().optional(),
});

export const Route = createFileRoute("/education")({
  validateSearch: (search) => educationSearchSchema.parse(search),
  head: () => ({
    meta: [
      { title: "Éducation : Niveaux scolaires & Concours — M'ANDAL" },
      {
        name: "description",
        content:
          "Le parcours de l'élève, du BEPC aux grands concours d'entrée (ENSPD, IUT, ENS, Baccalauréat).",
      },
    ],
  }),
  component: EducationPage,
});

type OptionId =
  | "bepc"
  | "probatoire"
  | "bac"
  | "alevel"
  | "enst"
  | "universite"
  | "enspd"
  | "iut";

interface SubjectItem {
  matiere: string;
  code?: string;
  icon?: string;
  chapitres: string[];
  description: string;
}

interface LevelOption {
  id: OptionId;
  name: string;
  subtitle: string;
  badge?: string;
  type: "scolaire" | "concours";
  keywords: string[];
  color: string;
  defaultSubjects: SubjectItem[];
}

const LEVEL_OPTIONS: LevelOption[] = [
  {
    id: "bepc",
    name: "BEPC (3ème · Premier cycle)",
    subtitle: "Premier cycle secondaire & Brevet d'Études du Premier Cycle",
    badge: "Examen Officiel 3ème",
    type: "scolaire",
    color: "emerald",
    keywords: ["bepc", "3eme", "troisieme", "premier cycle"],
    defaultSubjects: [
      {
        matiere: "Mathématiques — 3ème & BEPC",
        icon: "📐",
        chapitres: [
          "Chapitre 01 : Calcul numérique, puissances et racines carrées",
          "Chapitre 02 : Théorème de Thalès et réciproque dans le plan",
          "Chapitre 03 : Trigonométrie dans le triangle rectangle (Cos, Sin, Tan)",
          "Chapitre 04 : Calcul littéral, factorisation et identités remarquables",
          "Chapitre 05 : Équations et inéquations du premier degré à une inconnue",
          "Chapitre 06 : Statistiques, effectifs cumulés et diagrammes circulaires",
          "Chapitre 07 : Géométrie dans l'espace : cônes, pyramides, cylindres et sphères",
        ],
        description: "Fondamentaux d'arithmétique, géométrie plane, calcul algébrique et entraînement intensif aux annales du BEPC.",
      },
      {
        matiere: "Sciences Physiques & Chimie — 3ème",
        icon: "⚡",
        chapitres: [
          "Chapitre 01 : Masse volumique, densité et poussée d'Archimède",
          "Chapitre 02 : Courant électrique alternatif, tension sinusoïdale et puissance",
          "Chapitre 03 : Solutions aqueuses, ions, pH et réactions acido-basiques",
          "Chapitre 04 : Combustion des métaux et des hydrocarbures (alcanes)",
          "Chapitre 05 : Optique : lentilles minces convergentes et formation des images",
        ],
        description: "Expériences guidées, circuits électriques, réactions chimiques fondamentales et corrigés types BEPC.",
      },
      {
        matiere: "Français & Expression — 3ème",
        icon: "✍️",
        chapitres: [
          "Chapitre 01 : Grammaire, accords complexes et propositions subordonnées",
          "Chapitre 02 : Compréhension de texte et analyse littéraire méthodique",
          "Chapitre 03 : Expression écrite, argumentation et rédaction de récits",
          "Chapitre 04 : Vocabulaire, figures de style et orthographe lexicale",
        ],
        description: "Maîtrise de la langue française, analyse de texte littéraire et rédaction d'examen officiel.",
      },
      {
        matiere: "Sciences de la Vie et de la Terre (SVT) — 3ème",
        icon: "🧬",
        chapitres: [
          "Chapitre 01 : Nutrition humaine, digestion et équilibre alimentaire",
          "Chapitre 02 : Système nerveux, organes des sens et réflexes",
          "Chapitre 03 : Micro-organismes et système immunitaire de l'organisme",
          "Chapitre 04 : Préservation de l'environnement et gestion des écosystèmes",
        ],
        description: "Fonctionnement du corps humain, hygiène de vie, défenses immunitaires et écologie.",
      },
    ],
  },
  {
    id: "probatoire",
    name: "Probatoire (Séries A · C · D · TI)",
    subtitle: "Enseignement secondaire 2nd cycle — Classes de Première (1ère D, 1ère C, 1ère A, 1ère TI)",
    badge: "Examen Probatoire National",
    type: "scolaire",
    color: "emerald",
    keywords: ["probatoire", "premiere", "1ere", "1ere d", "1ere c", "1ere ti"],
    defaultSubjects: [
      {
        matiere: "Mathématiques — 1ère D & C (15 Chapitres)",
        icon: "📐",
        chapitres: [
          "Chapitre 01 : Équations, inéquations et systèmes linéaires à 2 et 3 inconnues",
          "Chapitre 02 : Polynômes du second degré, discriminant et factorisation",
          "Chapitre 03 : Trigonométrie, formules d'addition, duplication et équations circulaires",
          "Chapitre 04 : Angles orientés et cercles trigonométriques",
          "Chapitre 05 : Barycentres de points pondérés dans le plan et l'espace",
          "Chapitre 06 : Produit scalaire, orthogonalité et applications métriques",
          "Chapitre 07 : Limites de fonctions numériques, continuité et asymptotes",
          "Chapitre 08 : Dérivation, calcul de dérivées, tangentes et sens de variation",
          "Chapitre 09 : Étude et représentations graphiques de fonctions rationnelles",
          "Chapitre 10 : Suites arithmétiques et suites géométriques (terme général et sommes)",
          "Chapitre 11 : Dénombrement, arrangements, permutations et combinaisons",
          "Chapitre 12 : Initiation au calcul des probabilités et événements",
          "Chapitre 13 : Géométrie analytique de l'espace, repérage et équations cartésiennes",
          "Chapitre 14 : Transformations du plan (Homothéties, translations et rotations)",
          "Chapitre 15 : Statistiques à une et deux variables et ajustement linéaire",
        ],
        description: "Programme complet officiel du Probatoire Cameroun avec fiches de synthèse, exercices types et démonstrations pas à pas.",
      },
      {
        matiere: "Physique-Chimie — 1ère C & D",
        icon: "⚛️",
        chapitres: [
          "Chapitre 01 : Cinématique : vecteur position, vecteur vitesse et accélération",
          "Chapitre 02 : Dynamique du point matériel et lois fondamentales du mouvement",
          "Chapitre 03 : Travail, puissance mécanique et énergie cinétique / potentielle",
          "Chapitre 04 : Calorimétrie, échanges thermiques et changements d'état physique",
          "Chapitre 05 : Champ électrostatique, force de Coulomb et différence de potentiel",
          "Chapitre 06 : Lois du courant continu, dipôles et circuits électriques",
          "Chapitre 07 : Optique géométrique : lentilles minces, miroirs et instruments d'optique",
          "Chapitre 08 : Chimie organique : hydrocarbures, alcanes, alcools et composés carbonylés",
        ],
        description: "Cours approfondis, modélisations graphiques, expériences de laboratoire et annales officielles du Probatoire.",
      },
      {
        matiere: "Sciences de la Vie et de la Terre (SVT) — 1ère D",
        icon: "🔬",
        chapitres: [
          "Chapitre 01 : Génétique mendélienne, transmission des caractères et croisements",
          "Chapitre 02 : Tectonique des plaques et dynamique interne de la Terre",
          "Chapitre 03 : Système immunitaire : anticorps, lymphocytes et réponse immunitaire",
          "Chapitre 04 : Respiration cellulaire et production d'énergie biochimique (ATP)",
          "Chapitre 05 : Reproduction humaine et régulation hormonale",
          "Chapitre 06 : Écologie, flux d'énergie et conservation de la biodiversité",
        ],
        description: "Génétique, immunologie, géologie et physiologie humaine selon le programme officiel.",
      },
      {
        matiere: "Français & Littérature — Première",
        icon: "📚",
        chapitres: [
          "Chapitre 01 : Méthodologie rigoureuse de la dissertation littéraire",
          "Chapitre 02 : Commentaire composé, analyse stylistique et axes d'étude",
          "Chapitre 03 : Les grands courants littéraires et auteurs africains majeurs",
          "Chapitre 04 : Stylistique, figures de rhétorique et maîtrise de la langue",
        ],
        description: "Préparation complète à l'épreuve écrite et orale de français du Probatoire.",
      },
      {
        matiere: "Informatique & Algorithmique — Première",
        icon: "💻",
        chapitres: [
          "Chapitre 01 : Algorithmique : structures conditionnelles et itératives",
          "Chapitre 02 : Initiation à la programmation en langage Python",
          "Chapitre 03 : Réseaux informatiques, adressage IP et protocoles Internet",
          "Chapitre 04 : Sécurité numérique et traitement automatisé des données",
        ],
        description: "Notions d'algorithmique, logique de programmation et technologies de l'information.",
      },
    ],
  },
  {
    id: "bac",
    name: "Baccalauréat (Séries A · C · D · TI)",
    subtitle: "Classes de Terminale (Terminale C, Terminale D, Terminale A, Terminale TI)",
    badge: "Diplôme de Fin d'Études Secondaires",
    type: "scolaire",
    color: "emerald",
    keywords: ["bac", "baccalaureat", "terminale", "tle c", "tle d", "tle a"],
    defaultSubjects: [
      {
        matiere: "Mathématiques — Terminale C & D (12 Chapitres)",
        icon: "📐",
        chapitres: [
          "Chapitre 01 : Nombres complexes, forme trigonométrique et géométrie",
          "Chapitre 02 : Fonctions exponentielles et équations associées",
          "Chapitre 03 : Fonctions logarithmes népériens et décimaux",
          "Chapitre 04 : Calcul intégral, primitives et calcul d'aires / volumes",
          "Chapitre 05 : Équations différentielles linéaires du 1er et 2nd ordre",
          "Chapitre 06 : Suites numériques, récurrence, convergence et limites",
          "Chapitre 07 : Probabilités conditionnelles, variables aléatoires et lois de probabilité",
          "Chapitre 08 : Géométrie vectorielle dans l'espace, produit vectoriel et équations de plans",
          "Chapitre 09 : Matrices carrées, calcul matriciel et systèmes linéaires",
          "Chapitre 10 : Arithmétique : divisibilité, PGCD, PPCM et congruences (Série C)",
          "Chapitre 11 : Coniques : ellipses, hyperboles et paraboles (Série C)",
          "Chapitre 12 : Statistiques à deux variables et droites de régression linéaire",
        ],
        description: "Préparation d'excellence au Baccalauréat avec théorèmes fondamentaux, démonstrations et annales corrigées pas à pas.",
      },
      {
        matiere: "Physique-Chimie — Terminale C & D",
        icon: "⚛️",
        chapitres: [
          "Chapitre 01 : Mouvement d'une particule chargée dans des champs électrique et magnétique",
          "Chapitre 02 : Oscillations mécaniques libres et amorties (pendules)",
          "Chapitre 03 : Circuits électriques RLC, résonance et oscillations forcées",
          "Chapitre 04 : Ondes mécaniques progressives et phénomènes de diffraction / interférences",
          "Chapitre 05 : Physique nucléaire : radioactivité alpha/bêta/gamma et réactions de fission/fusion",
          "Chapitre 06 : Cinétique chimique : vitesse de réaction et facteurs cinétiques",
          "Chapitre 07 : Réactions acido-basiques en solution aqueuse, pH et titrages",
          "Chapitre 08 : Chimie organique : estérification, saponification et polymères",
          "Chapitre 09 : Spectrophotométrie et suivi cinétique de réactions",
          "Chapitre 10 : Effet photoélectrique et dualité onde-corpuscule de la lumière",
        ],
        description: "Programme complet de physique et chimie de Terminale avec modélisations numériques et protocoles expérimentaux.",
      },
      {
        matiere: "Sciences de la Vie et de la Terre (SVT) — Terminale D",
        icon: "🧬",
        chapitres: [
          "Chapitre 01 : Brassage génétique, méiose et diversité des génomes",
          "Chapitre 02 : Neurophysiologie : potentiel d'action, synapse et transmission nerveuse",
          "Chapitre 03 : Régulation de la glycémie et diabètes",
          "Chapitre 04 : Régulation de la pression artérielle",
          "Chapitre 05 : Immunologie avancée : mécanismes de reconnaissance du soi et du non-soi",
          "Chapitre 06 : Évolution des espèces et hominisation",
          "Chapitre 07 : Géodynamique interne et formation des chaînes de montagnes",
          "Chapitre 08 : Gestion des ressources énergétiques et géologiques",
        ],
        description: "Programme officiel de SVT Terminale D : génétique approfondie, neurosciences et géodynamique.",
      },
      {
        matiere: "Philosophie — Terminale",
        icon: "🏛️",
        chapitres: [
          "Chapitre 01 : La conscience, l'inconscient et le sujet",
          "Chapitre 02 : La vérité, la science et les enjeux de la technique",
          "Chapitre 03 : L'État, la justice, le droit et la liberté politique",
          "Chapitre 04 : Philosophie africaine contemporaine, traditions et modernité",
        ],
        description: "Notions philosophiques majeures, méthodologie de la dissertation philosophique et étude de textes d'auteurs.",
      },
      {
        matiere: "Informatique — Terminale TI",
        icon: "💾",
        chapitres: [
          "Chapitre 01 : Bases de données relationnelles et requêtes SQL avancées",
          "Chapitre 02 : Programmation orientée objet (POO) en Python",
          "Chapitre 03 : Développement web fullstack (HTML5, CSS3, JavaScript)",
          "Chapitre 04 : Cybersécurité, cryptographie et administration réseau",
        ],
        description: "Bases de données relationnelles, développement web et sécurité des réseaux informatiques.",
      },
    ],
  },
  {
    id: "alevel",
    name: "Advanced Level (GCE A-Level)",
    subtitle: "Cameroon GCE Board — Lower & Upper Sixth Forms (Sciences & Arts)",
    badge: "General Certificate of Education",
    type: "scolaire",
    color: "emerald",
    keywords: ["alevel", "gce", "anglophone", "sixth form", "lower sixth", "upper sixth"],
    defaultSubjects: [
      {
        matiere: "Pure Mathematics & Further Maths (A-Level)",
        icon: "📐",
        chapitres: [
          "Unit 01 : Advanced Algebraic Structures & Polynomials",
          "Unit 02 : Trigonometric Identities, Inverse Functions & Calculus",
          "Unit 03 : Differentiation, Integration Techniques & Differential Equations",
          "Unit 04 : Vectors in 3D & Vector Equations of Lines and Planes",
          "Unit 05 : Numerical Methods, Newton-Raphson & Trapezium Rule",
          "Unit 06 : Complex Numbers, De Moivre's Theorem & Loci in Argand Diagrams",
          "Unit 07 : Sequences, Series, Maclaurin & Taylor Expansions",
          "Unit 08 : Probability Distributions (Binomial, Normal & Poisson)",
        ],
        description: "Full GCE A-Level syllabus covering Pure Mathematics, Statistics, and Further Mechanics.",
      },
      {
        matiere: "Physics & Chemistry (GCE A-Level)",
        icon: "⚛️",
        chapitres: [
          "Unit 01 : Advanced Mechanics, Circular Motion & Gravitational Fields",
          "Unit 02 : Oscillations, Wave Optics & Doppler Effect",
          "Unit 03 : Thermal Physics, Ideal Gases & Thermodynamics",
          "Unit 04 : Electric & Magnetic Fields, Electromagnetic Induction & Alternating Current",
          "Unit 05 : Quantum Physics, Photoelectric Effect & Atomic Models",
          "Unit 06 : Physical Chemistry: Energetics, Kinetics & Chemical Equilibria",
          "Unit 07 : Inorganic Chemistry: Periodicity & Transition Elements",
          "Unit 08 : Organic Chemistry: Reaction Mechanisms & Spectroscopy (NMR, IR)",
        ],
        description: "Theoretical mastery and practical laboratory question-solving for top grades in GCE A-Level.",
      },
      {
        matiere: "English Literature & General Paper",
        icon: "📖",
        chapitres: [
          "Unit 01 : Critical Essay Writing & Argumentation Techniques",
          "Unit 02 : Drama Analysis : Shakespearean & African Plays",
          "Unit 03 : Poetry Analysis : Metre, Rhyme & Thematic Exploration",
          "Unit 04 : Contemporary Global Issues, Ethics & African Renaissance",
        ],
        description: "Comprehensive preparation for GCE Literature in English and General Paper papers.",
      },
    ],
  },
  {
    id: "enst",
    name: "ENS Technique (Professeurs Techniques)",
    subtitle: "École Normale Supérieure d'Enseignement Technique (ENSET)",
    badge: "Formation des Formateurs & Ingénieurs",
    type: "scolaire",
    color: "emerald",
    keywords: ["enst", "enset", "professeur", "technique", "formateur"],
    defaultSubjects: [
      {
        matiere: "Sciences de l'Ingénieur & Génie Mécanique / Électrique",
        icon: "⚙️",
        chapitres: [
          "Module 01 : Résistance des Matériaux (RDM) et calculs de structures",
          "Module 02 : Électrotechnique industrielle et machines électriques (moteurs, transformateurs)",
          "Module 03 : Automates programmables industriels et commande numérique",
          "Module 04 : Dessin industriel assisté par ordinateur (CAO / DAO)",
          "Module 05 : Thermodynamique appliquée et machines thermiques",
          "Module 06 : Électronique de puissance et traitement du signal",
        ],
        description: "Modules avancés en génie mécanique, génie électrique et sciences industrielles pour formateurs d'élite.",
      },
      {
        matiere: "Pédagogie Appliquée & Didactique Technique",
        icon: "🎓",
        chapitres: [
          "Module 01 : Didactique générale et conception de séquences pédagogiques techniques",
          "Module 02 : Gestion d'ateliers et de laboratoires d'expérimentation",
          "Module 03 : Évaluation des compétences et barèmes normatifs",
          "Module 04 : Intégration des TICE dans l'enseignement technique",
        ],
        description: "Méthodologie d'enseignement, transmission des savoirs pratiques et gestion de classe technique.",
      },
    ],
  },
  {
    id: "universite",
    name: "Université (Licence · Master · Doctorat)",
    subtitle: "Enseignement Supérieur Universitaire (Sciences fondamentales, Ingénierie & Humanités)",
    badge: "Cycle LMD Universitaire",
    type: "scolaire",
    color: "emerald",
    keywords: ["universite", "faculte", "licence", "master", "doctorat", "lmd"],
    defaultSubjects: [
      {
        matiere: "Mathématiques Universitaires (Licence 1 - 2 - 3)",
        icon: "📐",
        chapitres: [
          "Module 01 : Analyse réelle et complexe (Topologie, Séries de Fourier)",
          "Module 02 : Algèbre linéaire et réduction des endomorphismes (Diagonalisation, Jordan)",
          "Module 03 : Calcul différentiel et équations aux dérivées partielles (EDP)",
          "Module 04 : Probabilités approfondies et processus stochastiques",
          "Module 05 : Géométrie différentielle et calcul tensoriel",
          "Module 06 : Analyse numérique matricielle et optimisation",
        ],
        description: "Parcours mathématique universitaire rigoureux pour facultés de sciences et écoles d'ingénieurs.",
      },
      {
        matiere: "Physique Fondamentale & Sciences de la Matière",
        icon: "⚛️",
        chapitres: [
          "Module 01 : Mécanique analytique (Formalismes de Lagrange et d'Hamilton)",
          "Module 02 : Électromagnétisme dans les milieux continus et équations de Maxwell",
          "Module 03 : Physique quantique fondamentale (Équation de Schrödinger, opérateurs)",
          "Module 04 : Thermodynamique statistique et physique des solides",
          "Module 05 : Relativité restreinte et relativité générale",
        ],
        description: "Sciences physiques théoriques et appliquées de niveau supérieur.",
      },
      {
        matiere: "Informatique & Génie Logiciel Universitaire",
        icon: "💻",
        chapitres: [
          "Module 01 : Algorithmique avancée, théorie des graphes et complexité NP",
          "Module 02 : Architecture des systèmes d'exploitation et programmation système C/C++",
          "Module 03 : Conception orientée objet, design patterns et architecture logicielle",
          "Module 04 : Systèmes distribués, cloud computing et micro-services",
        ],
        description: "Formation avancée en conception informatique et génie logiciel.",
      },
    ],
  },
  {
    id: "enspd",
    name: "Concours ENSPD (Polytechnique Douala)",
    subtitle: "École Nationale Supérieure Polytechnique de Douala — Préparation intensive",
    badge: "Grande École d'Ingénieurs",
    type: "concours",
    color: "amber",
    keywords: ["enspd", "polytechnique", "douala", "concours enspd", "ingenieur"],
    defaultSubjects: [
      {
        matiere: "Prépa Concours ENSPD : Mathématiques de Concours",
        icon: "📐",
        chapitres: [
          "Module 01 : Algèbre générale, calcul matriciel et systèmes linéaires",
          "Module 02 : Analyse de haut niveau : intégrales impropres, développements limités et séries",
          "Module 03 : Équations différentielles appliquées aux sciences de l'ingénieur",
          "Module 04 : Géométrie analytique 3D, produits scalaire / vectoriel et surfaces",
          "Module 05 : Dénombrement accéléré et calcul des probabilités de concours",
          "Module 06 : Annales corrigées pas à pas des 10 dernières sessions ENSPD",
        ],
        description: "Entraînement de haut niveau axé sur la rapidité, l'exactitude des calculs et les astuces de résolution d'épreuves de polytechnique.",
      },
      {
        matiere: "Prépa Concours ENSPD : Physique & Chimie d'Ingénierie",
        icon: "⚛️",
        chapitres: [
          "Module 01 : Mécanique du solide, dynamique newtonienne et moments d'inertie",
          "Module 02 : Électromagnétisme, induction et régimes transitoires RLC",
          "Module 03 : Thermodynamique industrielle, cycles de Carnot et bilans énergétiques",
          "Module 04 : Optique ondulatoire : interférences, diffraction et réseaux",
          "Module 05 : Chimie des solutions aqueuses, équilibres chimiques et thermochimie",
          "Module 06 : Annales corrigées de physique-chimie du concours ENSPD",
        ],
        description: "Méthodologie de résolution rapide des épreuves de sciences physiques avec barèmes officiels.",
      },
      {
        matiere: "Prépa Concours ENSPD : Épreuves Blanches & QCM Éliminatoires",
        icon: "⚡",
        chapitres: [
          "Module 01 : Épreuve blanche n°1 en temps réel (Maths & Physique - 3h)",
          "Module 02 : Épreuve blanche n°2 avec correction vidéo détaillée",
          "Module 03 : Techniques de gestion du stress, du temps et élimination des pièges classiques",
        ],
        description: "Simulations réelles dans les conditions exactes d'examen pour maximiser vos chances de réussite.",
      },
    ],
  },
  {
    id: "iut",
    name: "Concours IUT (Instituts Universitaires de Technologie)",
    subtitle: "Filières technologiques & industrielles (Génie Mécanique, Électrique, Informatique)",
    badge: "Concours Technologique Universitaire",
    type: "concours",
    color: "amber",
    keywords: ["iut", "technologique", "industriel", "concours iut", "douala", "bandjoun"],
    defaultSubjects: [
      {
        matiere: "Prépa Concours IUT : Physique & Sciences Industrielles",
        icon: "⚙️",
        chapitres: [
          "Module 01 : Mécanique appliquée, statique et cinématique industrielle",
          "Module 02 : Électricité générale, conversion d'énergie et lois fondamentales",
          "Module 03 : Mesures physiques, métrologie et capteurs industriels",
          "Module 04 : Corrigés types des épreuves antérieures du concours IUT",
        ],
        description: "Préparation ciblée pour réussir l'entrée en filières technologiques et génie appliqué.",
      },
      {
        matiere: "Prépa Concours IUT : Mathématiques Pratiques & Logique",
        icon: "📐",
        chapitres: [
          "Module 01 : Calcul vectoriel, géométrie pratique et trigonométrie",
          "Module 02 : Étude de fonctions numériques, approximations et modélisation",
          "Module 03 : Statistiques appliquées, probabilités et raisonnement logique",
          "Module 04 : Épreuves types et annales corrigées du concours IUT",
        ],
        description: "Renforcement méthodique axé sur la logique, la rapidité d'exécution et les calculs sans calculatrice.",
      },
      {
        matiere: "Prépa Concours IUT : Sciences Appliquées & Dessin Technique",
        icon: "🔧",
        chapitres: [
          "Module 01 : Notions fondamentales de dessin industriel et projections orthogonales",
          "Module 02 : Électronique fondamentale : diodes, transistors et portes logiques",
          "Module 03 : Matériaux industriels et procédés de fabrication",
        ],
        description: "Culture technique et industrielle pour faire la différence lors des épreuves de sélection.",
      },
    ],
  },
];

export function EducationPage() {
  const navigate = useNavigate();
  const searchParams = Route.useSearch();
  const [userSession, setUserSession] = useState<{ id: string } | null>(null);
  const [authModalOpen, setAuthModalOpen] = useState(false);
  const [modalCourseTitle, setModalCourseTitle] = useState("Mathématiques 1ère");
  const [modalLevelId, setModalLevelId] = useState("probatoire");
  const [searchQuery, setSearchQuery] = useState("");

  // Niveau actif basé sur le search param de l'URL
  const activeLevelId = searchParams.niveau as OptionId | undefined;
  const activeLevel = LEVEL_OPTIONS.find((opt) => opt.id === activeLevelId) || null;

  useEffect(() => {
    supabase.auth.getSession().then(({ data }) => {
      if (data.session?.user) {
        setUserSession({ id: data.session.user.id });
      }
    });
  }, []);

  const handleSelectLevel = (levelId: OptionId) => {
    navigate({
      to: "/education",
      search: { niveau: levelId },
    });
    window.scrollTo({ top: 0, behavior: "smooth" });
  };

  const handleBackToLevels = () => {
    navigate({
      to: "/education",
      search: { niveau: undefined },
    });
    window.scrollTo({ top: 0, behavior: "smooth" });
  };

  const handleOpenCourse = (title: string, levelId: string) => {
    if (userSession) {
      window.location.href = "/etudiant/cours";
    } else {
      setModalCourseTitle(title);
      setModalLevelId(levelId);
      setAuthModalOpen(true);
    }
  };

  // Filtrage des matières si recherche
  const filteredSubjects = activeLevel
    ? activeLevel.defaultSubjects.filter((s) => {
        if (!searchQuery.trim()) return true;
        const q = searchQuery.toLowerCase();
        return (
          s.matiere.toLowerCase().includes(q) ||
          s.description.toLowerCase().includes(q) ||
          s.chapitres.some((c) => c.toLowerCase().includes(q))
        );
      })
    : [];

  const totalChapters = activeLevel
    ? activeLevel.defaultSubjects.reduce((acc, sub) => acc + sub.chapitres.length, 0)
    : 0;

  return (
    <div className="min-h-screen bg-slate-950 text-white selection:bg-emerald-500 selection:text-slate-950">
      {/* Modal d'inscription requise */}
      <AuthRequiredModal
        isOpen={authModalOpen}
        onClose={() => setAuthModalOpen(false)}
        title={modalCourseTitle}
        levelId={modalLevelId}
        category="education"
      />

      {/* Header Sticky */}
      <header className="sticky top-0 z-50 border-b border-slate-800/80 bg-slate-950/90 backdrop-blur-md">
        <div className="mx-auto flex h-18 max-w-7xl items-center justify-between px-5 lg:px-8">
          <Link to="/" className="flex items-center gap-3">
            <MandalLogo />
          </Link>
          <nav className="hidden items-center gap-6 md:flex">
            <Link to="/" className="inline-flex items-center gap-1.5 text-sm font-semibold text-slate-300 hover:text-emerald-400 transition-colors">
              <span>🏠</span> Accueil
            </Link>
            <Link to="/education" className="inline-flex items-center gap-1.5 text-sm font-bold text-emerald-400">
              <span>📚</span> Éducation
            </Link>
            <Link to="/citoyennete" className="inline-flex items-center gap-1.5 text-sm font-semibold text-slate-300 hover:text-blue-400 transition-colors">
              <span>⚖️</span> Citoyenneté
            </Link>
            <Link to="/culture" className="inline-flex items-center gap-1.5 text-sm font-semibold text-slate-300 hover:text-amber-400 transition-colors">
              <span>🌍</span> Culture
            </Link>
          </nav>
          <div className="flex items-center gap-3">
            {userSession ? (
              <Button asChild className="rounded-full bg-emerald-600 font-semibold text-white hover:bg-emerald-500 shadow-lg shadow-emerald-950">
                <Link to="/etudiant">Mon Tableau de bord</Link>
              </Button>
            ) : (
              <>
                <Button asChild variant="ghost" className="text-slate-200 hover:bg-slate-800">
                  <Link to="/auth">Connexion</Link>
                </Button>
                <Button asChild className="rounded-full bg-emerald-600 font-semibold text-white hover:bg-emerald-500 shadow-lg shadow-emerald-950">
                  <Link to="/inscription">Inscription</Link>
                </Button>
              </>
            )}
          </div>
        </div>
      </header>

      <main className="py-8 sm:py-12 lg:py-16">
        <div className="mx-auto max-w-7xl px-5 lg:px-8">
          {/* ========================================================= */}
          {/* CAS 1 : UNE OPTION / NIVEAU EST SÉLECTIONNÉ DANS L'URL   */}
          {/* PAGE DÉDIÉE DU NIVEAU AVEC TOUS LES COURS DU NIVEAU       */}
          {/* ========================================================= */}
          {activeLevel ? (
            <div className="space-y-8 animate-in fade-in slide-in-from-bottom-3 duration-300">
              {/* Fil d'ariane & Bouton Retour */}
              <div className="flex flex-wrap items-center justify-between gap-4">
                <button
                  type="button"
                  onClick={handleBackToLevels}
                  className="inline-flex items-center gap-2 rounded-full border border-slate-700 bg-slate-900/80 px-4 py-2 text-xs font-bold text-slate-200 transition hover:border-emerald-500 hover:bg-slate-800 hover:text-emerald-400 cursor-pointer shadow-sm"
                >
                  <ArrowLeft className="size-4" /> ← Choisir un autre niveau ou concours
                </button>

                <div className="flex items-center gap-2 text-xs font-medium text-slate-400">
                  <Link to="/" className="hover:text-white">Accueil</Link>
                  <span>/</span>
                  <Link to="/education" search={{ niveau: undefined }} className="hover:text-white">Éducation</Link>
                  <span>/</span>
                  <span className="font-bold text-emerald-400">{activeLevel.name}</span>
                </div>
              </div>

              {/* Bannière Header du Niveau Dédié */}
              <div className={cn(
                "relative overflow-hidden rounded-3xl border p-8 sm:p-12 shadow-2xl",
                activeLevel.type === "concours"
                  ? "border-amber-500/30 bg-gradient-to-br from-amber-950/60 via-slate-900 to-slate-950 shadow-amber-950/40"
                  : "border-emerald-500/30 bg-gradient-to-br from-emerald-950/70 via-slate-900 to-slate-950 shadow-emerald-950/40"
              )}>
                <div className="flex flex-wrap items-center gap-2.5">
                  <span className={cn(
                    "rounded-full px-3.5 py-1 text-xs font-black uppercase tracking-wider",
                    activeLevel.type === "concours"
                      ? "bg-amber-500/20 text-amber-300 border border-amber-500/40"
                      : "bg-emerald-500/20 text-emerald-300 border border-emerald-500/40"
                  )}>
                    {activeLevel.type === "concours" ? "🏆 Concours d'Entrée" : "🎓 Niveau Scolaire"}
                  </span>
                  {activeLevel.badge && (
                    <span className="rounded-full bg-slate-800 border border-slate-700 px-3 py-1 text-xs font-medium text-slate-300">
                      {activeLevel.badge}
                    </span>
                  )}
                </div>

                <h1 className="mt-4 font-display text-3xl font-black text-white sm:text-4xl lg:text-5xl tracking-tight">
                  {activeLevel.name}
                </h1>
                <p className="mt-3 text-lg font-medium text-emerald-300 sm:text-xl">
                  {activeLevel.subtitle}
                </p>
                <p className="mt-3 max-w-3xl text-sm text-slate-300 leading-relaxed">
                  Accédez à tous les programmes officiels, chapitres pas à pas, fiches mémo de formules, quiz d'auto-évaluation et exercices corrigés enregistrés pour ce niveau.
                </p>

                {/* Statistiques Rapides */}
                <div className="mt-8 flex flex-wrap items-center gap-4 sm:gap-6 border-t border-slate-800/80 pt-6">
                  <div className="flex items-center gap-2 rounded-xl bg-slate-900/80 px-4 py-2 border border-slate-800">
                    <BookOpen className="size-4 text-emerald-400" />
                    <span className="text-xs font-bold text-white">{activeLevel.defaultSubjects.length} Matières complètes</span>
                  </div>
                  <div className="flex items-center gap-2 rounded-xl bg-slate-900/80 px-4 py-2 border border-slate-800">
                    <CheckCircle2 className="size-4 text-blue-400" />
                    <span className="text-xs font-bold text-white">{totalChapters} Chapitres détaillés</span>
                  </div>
                  <div className="flex items-center gap-2 rounded-xl bg-slate-900/80 px-4 py-2 border border-slate-800">
                    <Sparkles className="size-4 text-amber-400" />
                    <span className="text-xs font-bold text-white">Quiz &amp; Simulations GeoGebra</span>
                  </div>
                </div>
              </div>

              {/* BANNIÈRE D'AVERTISSEMENT : INSCRIPTION OBLIGATOIRE POUR ACCÉDER AUX COURS */}
              <div className="rounded-2xl border border-amber-500/40 bg-gradient-to-r from-amber-950/40 via-slate-900 to-amber-950/30 p-5 sm:p-6 flex flex-col sm:flex-row sm:items-center justify-between gap-4 shadow-lg">
                <div className="flex items-start sm:items-center gap-3.5">
                  <div className="flex size-11 shrink-0 items-center justify-center rounded-xl bg-amber-500/20 text-amber-400 border border-amber-500/40">
                    <Lock className="size-5" />
                  </div>
                  <div>
                    <h3 className="font-display text-sm sm:text-base font-bold text-white">
                      Inscription obligatoire pour débloquer l'intégralité des cours
                    </h3>
                    <p className="text-xs text-slate-300 mt-0.5">
                      Consultez la liste des matières et chapitres ci-dessous. Pour ouvrir une leçon, lancer un quiz ou télécharger les fiches, créez votre compte gratuit.
                    </p>
                  </div>
                </div>

                <div className="flex shrink-0 items-center gap-2.5">
                  {userSession ? (
                    <Button
                      asChild
                      className="rounded-xl bg-emerald-600 font-bold text-white hover:bg-emerald-500"
                    >
                      <Link to="/etudiant/cours">Ouvrir dans mon espace</Link>
                    </Button>
                  ) : (
                    <Button
                      asChild
                      className="rounded-xl bg-gradient-to-r from-emerald-600 to-teal-600 font-bold text-white hover:from-emerald-500 hover:to-teal-500 shadow-md shadow-emerald-950 cursor-pointer"
                    >
                      <Link to="/inscription" search={{ level: activeLevel.id }}>
                        Créer mon compte (Gratuit)
                      </Link>
                    </Button>
                  )}
                </div>
              </div>

              {/* Barre de recherche dans les cours */}
              <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4 border-b border-slate-800 pb-4">
                <div>
                  <h2 className="font-display text-2xl font-bold text-white flex items-center gap-2">
                    <BookOpen className="size-6 text-emerald-400" />
                    Tous les cours &amp; Matières de {activeLevel.name}
                  </h2>
                  <p className="text-xs text-slate-400 mt-1">
                    Cliquez sur un chapitre pour ouvrir la leçon (nécessite un compte).
                  </p>
                </div>

                <div className="relative w-full sm:w-72">
                  <Search className="absolute left-3 top-1/2 -translate-y-1/2 size-4 text-slate-400" />
                  <Input
                    placeholder="Filtrer par chapitre ou matière..."
                    value={searchQuery}
                    onChange={(e) => setSearchQuery(e.target.value)}
                    className="pl-9 bg-slate-900 border-slate-700 text-xs rounded-xl focus:border-emerald-500"
                  />
                </div>
              </div>

              {/* LISTE DES MATIÈRES & CHAPITRES DU NIVEAU */}
              <div className="grid grid-cols-1 gap-6 lg:grid-cols-2">
                {filteredSubjects.map((sub, idx) => (
                  <div
                    key={idx}
                    className="flex flex-col justify-between rounded-3xl border border-slate-800 bg-slate-900/90 p-6 sm:p-8 shadow-xl transition-all duration-200 hover:border-emerald-500/50 hover:bg-slate-900"
                  >
                    <div>
                      <div className="flex items-start justify-between gap-3">
                        <div className="flex items-center gap-2.5">
                          <span className="text-2xl">{sub.icon || "📚"}</span>
                          <h3 className="font-display text-lg font-bold text-white">
                            {sub.matiere}
                          </h3>
                        </div>
                        <span className="shrink-0 rounded-full bg-emerald-500/10 border border-emerald-500/30 px-2.5 py-1 text-[11px] font-bold text-emerald-300">
                          {sub.chapitres.length} chapitres
                        </span>
                      </div>

                      <p className="mt-3 text-xs leading-relaxed text-slate-300">
                        {sub.description}
                      </p>

                      {/* Liste exhaustive des chapitres */}
                      <div className="mt-6 space-y-2">
                        <div className="flex items-center justify-between text-[11px] font-bold uppercase tracking-wider text-slate-400">
                          <span>Programme détaillé par chapitre :</span>
                          <span className="text-emerald-400 font-semibold">Cliquer pour ouvrir</span>
                        </div>

                        <div className="space-y-1.5 max-h-[360px] overflow-y-auto pr-1">
                          {sub.chapitres.map((chap, cIdx) => (
                            <button
                              key={cIdx}
                              type="button"
                              onClick={() => handleOpenCourse(`${sub.matiere} — ${chap}`, activeLevel.id)}
                              className="w-full flex items-center justify-between gap-2.5 rounded-xl border border-slate-800/80 bg-slate-950/70 px-3.5 py-2.5 text-left text-xs text-slate-300 transition hover:border-emerald-500/50 hover:bg-slate-950 hover:text-white cursor-pointer group"
                            >
                              <div className="flex items-center gap-2.5 min-w-0">
                                <span className="flex size-5 shrink-0 items-center justify-center rounded-full bg-emerald-500/15 text-[10px] font-bold text-emerald-300 group-hover:bg-emerald-500 group-hover:text-slate-950 transition-colors">
                                  {cIdx + 1}
                                </span>
                                <span className="truncate">{chap}</span>
                              </div>
                              <span className="shrink-0 flex items-center gap-1 text-[11px] font-semibold text-emerald-400 opacity-80 group-hover:opacity-100">
                                <Lock className="size-3 text-amber-400" /> Ouvrir
                              </span>
                            </button>
                          ))}
                        </div>
                      </div>
                    </div>

                    {/* Bouton d'action du bas de la carte */}
                    <div className="mt-6 pt-5 border-t border-slate-800 flex flex-wrap items-center justify-between gap-3">
                      <div className="flex items-center gap-2 text-[11px] text-slate-400">
                        <Sparkles className="size-3.5 text-amber-400" />
                        <span>Fiches mémo · Quiz chronométrés</span>
                      </div>
                      <Button
                        onClick={() => handleOpenCourse(`Programme complet ${sub.matiere}`, activeLevel.id)}
                        className="bg-emerald-600 font-bold text-white hover:bg-emerald-500 shadow-md cursor-pointer"
                        size="sm"
                      >
                        {userSession ? "Accéder à la matière" : "Ouvrir ce cours"}
                        <ArrowRight className="ml-1.5 size-3.5" />
                      </Button>
                    </div>
                  </div>
                ))}
              </div>

              {/* OUTILS PÉDAGOGIQUES ASSOCIÉS À CE NIVEAU */}
              <div className="mt-12 rounded-3xl border border-slate-800 bg-slate-900/90 p-8 sm:p-10 shadow-2xl">
                <div className="flex items-center gap-2 text-xs font-bold uppercase tracking-wider text-emerald-400">
                  <Binary className="size-4" /> Outils Pédagogiques inclus
                </div>
                <h3 className="mt-2 font-display text-xl sm:text-2xl font-bold text-white">
                  Tout le matériel d'apprentissage pour réussir {activeLevel.name}
                </h3>

                <div className="mt-6 grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-4">
                  <div
                    onClick={() => handleOpenCourse(`Fiches de synthèse Maths & Physique (${activeLevel.name})`, activeLevel.id)}
                    className="p-5 rounded-2xl border border-slate-800 bg-slate-950 hover:border-emerald-500/50 cursor-pointer transition"
                  >
                    <BookOpen className="size-6 text-emerald-400" />
                    <h4 className="mt-3 font-bold text-sm text-white">Fiches de Synthèse</h4>
                    <p className="mt-1 text-xs text-slate-400">Résumés de cours et formulaires téléchargeables.</p>
                  </div>

                  <div
                    onClick={() => handleOpenCourse(`Quiz & Épreuves interactives (${activeLevel.name})`, activeLevel.id)}
                    className="p-5 rounded-2xl border border-slate-800 bg-slate-950 hover:border-blue-500/50 cursor-pointer transition"
                  >
                    <Sparkles className="size-6 text-blue-400" />
                    <h4 className="mt-3 font-bold text-sm text-white">Quiz &amp; Auto-évaluation</h4>
                    <p className="mt-1 text-xs text-slate-400">Tests interactifs corrigés avec scores.</p>
                  </div>

                  <div
                    onClick={() => handleOpenCourse(`Annales et Corrigés officiels (${activeLevel.name})`, activeLevel.id)}
                    className="p-5 rounded-2xl border border-slate-800 bg-slate-950 hover:border-amber-500/50 cursor-pointer transition"
                  >
                    <Award className="size-6 text-amber-400" />
                    <h4 className="mt-3 font-bold text-sm text-white">Annales Corrigées</h4>
                    <p className="mt-1 text-xs text-slate-400">Épreuves des sessions antérieures décortiquées.</p>
                  </div>

                  <div
                    onClick={() => handleOpenCourse(`Laboratoire GeoGebra & Simulations (${activeLevel.name})`, activeLevel.id)}
                    className="p-5 rounded-2xl border border-slate-800 bg-slate-950 hover:border-teal-500/50 cursor-pointer transition"
                  >
                    <Cpu className="size-6 text-teal-400" />
                    <h4 className="mt-3 font-bold text-sm text-white">Simulations Virtuelles</h4>
                    <p className="mt-1 text-xs text-slate-400">GeoGebra et manipulations 2D/3D en ligne.</p>
                  </div>
                </div>
              </div>

              {/* BANNIÈRE D'APPEL À L'ACTION FINALE */}
              <div className="rounded-3xl border border-emerald-500/30 bg-gradient-to-r from-emerald-950/80 via-slate-900 to-slate-950 p-8 sm:p-12 text-center shadow-2xl">
                <h3 className="font-display text-2xl sm:text-3xl font-bold text-white">
                  Prêt à commencer vos cours de {activeLevel.name} ?
                </h3>
                <p className="mt-2 max-w-2xl mx-auto text-sm text-slate-300">
                  Rejoignez la communauté M'ANDAL gratuitement et accédez à tous vos cours, exercices et simulations dès aujourd'hui.
                </p>
                <div className="mt-6 flex flex-wrap justify-center items-center gap-3">
                  <Button
                    asChild
                    size="lg"
                    className="rounded-full bg-emerald-600 px-8 font-bold text-white hover:bg-emerald-500 shadow-xl shadow-emerald-950"
                  >
                    <Link to="/inscription" search={{ level: activeLevel.id }}>
                      Créer mon compte gratuit
                    </Link>
                  </Button>
                  <Button
                    type="button"
                    variant="outline"
                    onClick={handleBackToLevels}
                    className="rounded-full border-slate-700 bg-slate-900/80 text-slate-300 hover:bg-slate-800"
                  >
                    ← Choisir un autre niveau
                  </Button>
                </div>
              </div>
            </div>
          ) : (
            /* ========================================================= */
            /* CAS 2 : ACCUEIL ÉDUCATION (LISTE DES NIVEAUX & CONCOURS)  */
            /* ========================================================= */
            <div className="space-y-12">
              <Link
                to="/"
                className="inline-flex items-center gap-2 text-xs font-semibold text-slate-400 transition hover:text-emerald-400"
              >
                <ArrowLeft className="size-4" /> Retour à l'accueil
              </Link>

              {/* Page Banner Header */}
              <div className="rounded-3xl border border-emerald-500/30 bg-gradient-to-br from-emerald-950/70 via-slate-900 to-slate-950 p-8 sm:p-12 shadow-2xl">
                <div className="inline-flex items-center gap-2 rounded-full border border-emerald-500/40 bg-emerald-500/15 px-4 py-1.5 text-xs font-bold uppercase tracking-wider text-emerald-300">
                  <GraduationCap className="size-4" /> Volet 01 · Éducation
                </div>
                <h1 className="mt-4 font-display text-3xl font-black text-white sm:text-5xl lg:text-6xl tracking-tight">
                  Éducation : Niveaux scolaires &amp; Concours
                </h1>
                <p className="mt-3 text-xl font-medium text-emerald-300 sm:text-2xl">
                  Le parcours de l'élève, du BEPC aux grands concours d'entrée
                </p>
                <p className="mt-4 max-w-3xl text-sm text-slate-300 sm:text-base leading-relaxed">
                  Maîtrise des fondamentaux académiques (Maths, Physique, SVT, etc.) et préparation méthodique aux grands examens et concours nationaux.
                </p>
              </div>

              {/* SECTION : SÉLECTIONNEZ VOTRE NIVEAU (OUVRE LA PAGE DÉDIÉE) */}
              <div>
                <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-3 border-b border-slate-800 pb-4">
                  <div>
                    <span className="text-xs font-bold uppercase tracking-wider text-emerald-400">
                      Étape 1 : Choisissez votre niveau ou concours
                    </span>
                    <h2 className="font-display text-2xl sm:text-3xl font-bold text-white mt-1">
                      Cliquez sur une option pour ouvrir tous ses cours
                    </h2>
                  </div>
                  <span className="text-xs font-medium text-slate-400">
                    Connecté à la base de données <span className="font-bold text-emerald-400">Supabase M'Andal</span>
                  </span>
                </div>

                {/* Grille des 8 Options Cliquables */}
                <div className="mt-8 grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-4">
                  {LEVEL_OPTIONS.map((opt) => {
                    const isConcours = opt.type === "concours";
                    const count = opt.defaultSubjects.length;
                    const chapCount = opt.defaultSubjects.reduce((a, b) => a + b.chapitres.length, 0);

                    return (
                      <div
                        key={opt.id}
                        onClick={() => handleSelectLevel(opt.id)}
                        className={cn(
                          "group relative flex flex-col justify-between rounded-3xl border p-6 text-left transition-all duration-300 cursor-pointer hover:-translate-y-1 shadow-lg",
                          isConcours
                            ? "border-amber-500/30 bg-gradient-to-b from-slate-900 to-amber-950/20 hover:border-amber-400 hover:shadow-amber-950/40"
                            : "border-slate-800 bg-gradient-to-b from-slate-900 to-slate-950 hover:border-emerald-400 hover:shadow-emerald-950/40"
                        )}
                      >
                        <div>
                          <div className="flex items-center justify-between">
                            <span className={cn(
                              "text-xs font-bold uppercase px-2.5 py-0.5 rounded-full",
                              isConcours
                                ? "bg-amber-500/20 text-amber-300 border border-amber-500/40"
                                : "bg-emerald-500/20 text-emerald-300 border border-emerald-500/40"
                            )}>
                              {isConcours ? "🏆 Concours" : "🎓 Scolaire"}
                            </span>
                            <span className="text-xs text-slate-400 font-semibold">
                              {chapCount} chapitres
                            </span>
                          </div>

                          <h3 className="mt-4 font-display text-lg font-bold text-white group-hover:text-emerald-300 transition-colors">
                            {opt.name}
                          </h3>
                          <p className="mt-2 text-xs text-slate-400 leading-relaxed">
                            {opt.subtitle}
                          </p>
                        </div>

                        <div className="mt-6 pt-4 border-t border-slate-800/80 flex items-center justify-between text-xs font-bold text-emerald-400">
                          <span>Voir les {count} matières</span>
                          <span className="flex size-7 items-center justify-center rounded-full bg-emerald-500/15 group-hover:bg-emerald-500 group-hover:text-slate-950 transition-colors">
                            <ArrowRight className="size-4" />
                          </span>
                        </div>
                      </div>
                    );
                  })}
                </div>
              </div>

              {/* OUTILS PÉDAGOGIQUES & CONTENUS DE COURS (MATHS & PHYSIQUE) */}
              <div className="mt-16 rounded-3xl border border-slate-800 bg-slate-900/90 p-8 sm:p-12 shadow-2xl">
                <div className="max-w-2xl">
                  <div className="inline-flex items-center gap-2 rounded-lg bg-emerald-500/10 px-3 py-1 text-xs font-bold uppercase tracking-wider text-emerald-400">
                    <Binary className="size-4" /> Pédagogie d'Excellence
                  </div>
                  <h2 className="mt-3 font-display text-2xl sm:text-3xl font-bold text-white">
                    Outils pédagogiques &amp; Contenus de cours (Maths &amp; Physique)
                  </h2>
                  <p className="mt-2 text-sm text-slate-300">
                    Un environnement complet conçu pour rendre l'apprentissage clair, rigoureux et stimulant.
                  </p>
                </div>

                <div className="mt-8 grid grid-cols-1 gap-5 md:grid-cols-2 lg:grid-cols-3">
                  <div
                    onClick={() => handleSelectLevel("probatoire")}
                    className="group cursor-pointer rounded-2xl border border-slate-800 bg-slate-950 p-6 shadow-sm transition hover:border-emerald-500/50 hover:bg-slate-900/60"
                  >
                    <div className="flex size-10 items-center justify-center rounded-xl bg-emerald-500/20 text-emerald-400 group-hover:scale-110 transition-transform">
                      <BookOpen className="size-5" />
                    </div>
                    <h3 className="mt-4 font-display text-base font-bold text-white group-hover:text-emerald-300">
                      Cours de Mathématiques &amp; Physique
                    </h3>
                    <p className="mt-2 text-xs leading-relaxed text-slate-300">
                      Syllabus complet, fiches de synthèse, formules clés et démonstrations pas à pas.
                    </p>
                    <span className="mt-4 inline-flex items-center gap-1 text-[11px] font-semibold text-emerald-400">
                      Consulter les fiches <ArrowRight className="size-3" />
                    </span>
                  </div>

                  <div
                    onClick={() => handleSelectLevel("probatoire")}
                    className="group cursor-pointer rounded-2xl border border-slate-800 bg-slate-950 p-6 shadow-sm transition hover:border-blue-500/50 hover:bg-slate-900/60"
                  >
                    <div className="flex size-10 items-center justify-center rounded-xl bg-blue-500/20 text-blue-400 group-hover:scale-110 transition-transform">
                      <Sparkles className="size-5" />
                    </div>
                    <h3 className="mt-4 font-display text-base font-bold text-white group-hover:text-blue-300">
                      Épreuves &amp; Quiz interactifs
                    </h3>
                    <p className="mt-2 text-xs leading-relaxed text-slate-300">
                      Entraînements chronométrés et tests d'auto-évaluation par chapitre avec barème officiel.
                    </p>
                    <span className="mt-4 inline-flex items-center gap-1 text-[11px] font-semibold text-blue-400">
                      Lancer un entraînement <ArrowRight className="size-3" />
                    </span>
                  </div>

                  <div
                    onClick={() => handleSelectLevel("bac")}
                    className="group cursor-pointer rounded-2xl border border-slate-800 bg-slate-950 p-6 shadow-sm transition hover:border-teal-500/50 hover:bg-slate-900/60"
                  >
                    <div className="flex size-10 items-center justify-center rounded-xl bg-teal-500/20 text-teal-400 group-hover:scale-110 transition-transform">
                      <CheckCircle2 className="size-5" />
                    </div>
                    <h3 className="mt-4 font-display text-base font-bold text-white group-hover:text-teal-300">
                      Correction d'épreuves pas à pas
                    </h3>
                    <p className="mt-2 text-xs leading-relaxed text-slate-300">
                      Corrigés détaillés, pièges fréquents et barèmes officiels des sessions antérieures.
                    </p>
                    <span className="mt-4 inline-flex items-center gap-1 text-[11px] font-semibold text-teal-400">
                      Voir les annales corrigées <ArrowRight className="size-3" />
                    </span>
                  </div>

                  <div
                    onClick={() => handleSelectLevel("bac")}
                    className="group cursor-pointer rounded-2xl border border-slate-800 bg-slate-950 p-6 shadow-sm transition hover:border-amber-500/50 hover:bg-slate-900/60"
                  >
                    <div className="flex size-10 items-center justify-center rounded-xl bg-amber-500/20 text-amber-400 group-hover:scale-110 transition-transform">
                      <Award className="size-5" />
                    </div>
                    <h3 className="mt-4 font-display text-base font-bold text-white group-hover:text-amber-300">
                      Épreuves de bourse d'excellence
                    </h3>
                    <p className="mt-2 text-xs leading-relaxed text-slate-300">
                      Sujets de sélection pour les programmes de financement, parrainage et bourses d'études.
                    </p>
                    <span className="mt-4 inline-flex items-center gap-1 text-[11px] font-semibold text-amber-400">
                      Accéder aux sujets de bourse <ArrowRight className="size-3" />
                    </span>
                  </div>

                  <div
                    onClick={() => handleSelectLevel("probatoire")}
                    className="group cursor-pointer rounded-2xl border border-slate-800 bg-slate-950 p-6 shadow-sm md:col-span-2 lg:col-span-2 transition hover:border-emerald-500/50 hover:bg-slate-900/60"
                  >
                    <div className="flex size-10 items-center justify-center rounded-xl bg-emerald-500/20 text-emerald-400 group-hover:scale-110 transition-transform">
                      <Cpu className="size-5" />
                    </div>
                    <h3 className="mt-4 font-display text-base font-bold text-white group-hover:text-emerald-300">
                      Simulation virtuelle &amp; GeoGebra
                    </h3>
                    <p className="mt-2 text-xs leading-relaxed text-slate-300">
                      Visualisations graphiques interactives de fonctions mathématiques, simulations d'expériences de physique et manipulation directe de figures en 2D/3D.
                    </p>
                    <span className="mt-4 inline-flex items-center gap-1 text-[11px] font-semibold text-emerald-400">
                      Ouvrir le laboratoire virtuel <ArrowRight className="size-3" />
                    </span>
                  </div>
                </div>
              </div>

              {/* PRÉSENTATION DES CONCOURS D'ENTRÉE (ENSPD & IUT) */}
              <div className="mt-16 rounded-3xl border border-slate-800 bg-slate-900/90 p-8 sm:p-12 shadow-2xl">
                <div className="max-w-2xl">
                  <div className="inline-flex items-center gap-2 rounded-lg bg-amber-500/10 px-3 py-1 text-xs font-bold uppercase tracking-wider text-amber-400">
                    <Award className="size-4" /> Grandes Écoles
                  </div>
                  <h2 className="mt-3 font-display text-2xl sm:text-3xl font-bold text-white">
                    CONCOURS D'ENTRÉE
                  </h2>
                  <p className="mt-2 text-sm text-slate-300">
                    Préparation aux grandes écoles d'ingénieurs et technologiques du Cameroun.
                  </p>
                </div>

                <div className="mt-8 grid grid-cols-1 gap-8 md:grid-cols-2">
                  {/* ENSPD */}
                  <div className="rounded-2xl border border-slate-800 bg-slate-950 p-6 sm:p-8 flex flex-col justify-between">
                    <div>
                      <div className="flex items-center justify-between">
                        <h3 className="font-display text-xl font-bold text-white">ENSPD</h3>
                        <span className="rounded-full bg-emerald-500/20 px-3 py-1 text-xs font-bold text-emerald-300">
                          Polytechnique Douala
                        </span>
                      </div>
                      <ul className="mt-6 space-y-3.5 text-sm text-slate-300">
                        <li className="flex items-start gap-3">
                          <CheckCircle2 className="size-4 text-emerald-400 shrink-0 mt-0.5" />
                          <span><strong>Présentation de l'école</strong> &amp; débouchés d'ingénierie</span>
                        </li>
                        <li className="flex items-start gap-3">
                          <CheckCircle2 className="size-4 text-emerald-400 shrink-0 mt-0.5" />
                          <span><strong>Concours d'entrée</strong> (après Bac, Probatoire, BEPC/CAP, autre)</span>
                        </li>
                        <li className="flex items-start gap-3">
                          <CheckCircle2 className="size-4 text-emerald-400 shrink-0 mt-0.5" />
                          <span><strong>Cours de renforcement</strong> (Maths, Physique-Chimie)</span>
                        </li>
                        <li className="flex items-start gap-3">
                          <CheckCircle2 className="size-4 text-emerald-400 shrink-0 mt-0.5" />
                          <span><strong>Correction d'épreuves</strong> et annales corrigées</span>
                        </li>
                      </ul>
                    </div>

                    <div className="mt-8 pt-4 border-t border-slate-800">
                      <Button
                        type="button"
                        onClick={() => handleSelectLevel("enspd")}
                        className="w-full bg-emerald-600 font-bold text-white hover:bg-emerald-500 cursor-pointer"
                      >
                        Ouvrir la page Prépa ENSPD →
                      </Button>
                    </div>
                  </div>

                  {/* IUT */}
                  <div className="rounded-2xl border border-slate-800 bg-slate-950 p-6 sm:p-8 flex flex-col justify-between">
                    <div>
                      <div className="flex items-center justify-between">
                        <h3 className="font-display text-xl font-bold text-white">IUT</h3>
                        <span className="rounded-full bg-blue-500/20 px-3 py-1 text-xs font-bold text-blue-300">
                          Filières Technologiques
                        </span>
                      </div>
                      <ul className="mt-6 space-y-3.5 text-sm text-slate-300">
                        <li className="flex items-start gap-3">
                          <CheckCircle2 className="size-4 text-blue-400 shrink-0 mt-0.5" />
                          <span><strong>Présentation de l'IUT</strong> et des filières d'avenir</span>
                        </li>
                        <li className="flex items-start gap-3">
                          <CheckCircle2 className="size-4 text-blue-400 shrink-0 mt-0.5" />
                          <span><strong>Filière technologique</strong> &amp; industrielle</span>
                        </li>
                        <li className="flex items-start gap-3">
                          <CheckCircle2 className="size-4 text-blue-400 shrink-0 mt-0.5" />
                          <span><strong>Physique appliquée</strong> &amp; sciences de l'ingénieur</span>
                        </li>
                        <li className="flex items-start gap-3">
                          <CheckCircle2 className="size-4 text-blue-400 shrink-0 mt-0.5" />
                          <span><strong>Spécialités</strong>, métiers et passerelles</span>
                        </li>
                      </ul>
                    </div>

                    <div className="mt-8 pt-4 border-t border-slate-800">
                      <Button
                        type="button"
                        onClick={() => handleSelectLevel("iut")}
                        className="w-full bg-blue-600 font-bold text-white hover:bg-blue-500 cursor-pointer"
                      >
                        Ouvrir la page Prépa IUT →
                      </Button>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          )}
        </div>
      </main>
    </div>
  );
}
