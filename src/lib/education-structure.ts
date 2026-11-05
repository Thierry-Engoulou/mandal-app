// Structure de l'offre « Éducation » : enseignement général, enseignement
// technique (industriel et commercial), anciens sujets d'examens nationaux et
// concours des grandes écoles. Les chapitres détaillés viennent des programmes
// déjà rédigés ; les autres matières sont annoncées sans chapitres.

export type Matiere = {
  matiere: string;
  icon?: string;
  description?: string | undefined;
  chapitres: string[];
};

export type Parcours = {
  id: string;
  nom: string;
  sousTitre: string;
  /** Classes ou années concernées (ex. « 2nde, 1ère, Tle »). */
  badge?: string;
  /** Spécialités (sigles) de la filière, pour l'enseignement technique. */
  specialites?: string[] | undefined;
  type: "scolaire" | "technique" | "concours";
  /** Valeur pré-remplie du niveau dans le formulaire d'inscription. */
  niveauInscription: string;
  matieres: Matiere[];
};

export type Section = { titre: string; sousTitre?: string; parcours: Parcours[] };

const CHAPITRES: Record<string, { description: string; chapitres: string[] }> = {
  "3ème|Mathématiques": {
    description:
      "Fondamentaux d'arithmétique, géométrie plane, calcul algébrique et entraînement intensif aux annales du BEPC.",
    chapitres: [
      "Chapitre 01 : Calcul numérique, puissances et racines carrées",
      "Chapitre 02 : Théorème de Thalès et réciproque dans le plan",
      "Chapitre 03 : Trigonométrie dans le triangle rectangle (Cos, Sin, Tan)",
      "Chapitre 04 : Calcul littéral, factorisation et identités remarquables",
      "Chapitre 05 : Équations et inéquations du premier degré à une inconnue",
      "Chapitre 06 : Statistiques, effectifs cumulés et diagrammes circulaires",
      "Chapitre 07 : Géométrie dans l'espace : cônes, pyramides, cylindres et sphères",
    ],
  },
  "3ème|Physique-Chimie": {
    description:
      "Expériences guidées, circuits électriques, réactions chimiques fondamentales et corrigés types BEPC.",
    chapitres: [
      "Chapitre 01 : Masse volumique, densité et poussée d'Archimède",
      "Chapitre 02 : Courant électrique alternatif, tension sinusoïdale et puissance",
      "Chapitre 03 : Solutions aqueuses, ions, pH et réactions acido-basiques",
      "Chapitre 04 : Combustion des métaux et des hydrocarbures (alcanes)",
      "Chapitre 05 : Optique : lentilles minces convergentes et formation des images",
    ],
  },
  "3ème|Français": {
    description:
      "Maîtrise de la langue française, analyse de texte littéraire et rédaction d'examen officiel.",
    chapitres: [
      "Chapitre 01 : Grammaire, accords complexes et propositions subordonnées",
      "Chapitre 02 : Compréhension de texte et analyse littéraire méthodique",
      "Chapitre 03 : Expression écrite, argumentation et rédaction de récits",
      "Chapitre 04 : Vocabulaire, figures de style et orthographe lexicale",
    ],
  },
  "3ème|SVT": {
    description:
      "Fonctionnement du corps humain, hygiène de vie, défenses immunitaires et écologie.",
    chapitres: [
      "Chapitre 01 : Nutrition humaine, digestion et équilibre alimentaire",
      "Chapitre 02 : Système nerveux, organes des sens et réflexes",
      "Chapitre 03 : Micro-organismes et système immunitaire de l'organisme",
      "Chapitre 04 : Préservation de l'environnement et gestion des écosystèmes",
    ],
  },
  "1ère-sci|Mathématiques": {
    description:
      "Programme complet officiel du Probatoire Cameroun avec fiches de synthèse, exercices types et démonstrations pas à pas.",
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
  },
  "1ère-sci|SVT": {
    description:
      "Génétique, immunologie, géologie et physiologie humaine selon le programme officiel.",
    chapitres: [
      "Chapitre 01 : Génétique mendélienne, transmission des caractères et croisements",
      "Chapitre 02 : Tectonique des plaques et dynamique interne de la Terre",
      "Chapitre 03 : Système immunitaire : anticorps, lymphocytes et réponse immunitaire",
      "Chapitre 04 : Respiration cellulaire et production d'énergie biochimique (ATP)",
      "Chapitre 05 : Reproduction humaine et régulation hormonale",
      "Chapitre 06 : Écologie, flux d'énergie et conservation de la biodiversité",
    ],
  },
  "1ère|Français": {
    description: "Préparation complète à l'épreuve écrite et orale de français du Probatoire.",
    chapitres: [
      "Chapitre 01 : Méthodologie rigoureuse de la dissertation littéraire",
      "Chapitre 02 : Commentaire composé, analyse stylistique et axes d'étude",
      "Chapitre 03 : Les grands courants littéraires et auteurs africains majeurs",
      "Chapitre 04 : Stylistique, figures de rhétorique et maîtrise de la langue",
    ],
  },
  "1ère|Informatique": {
    description:
      "Notions d'algorithmique, logique de programmation et technologies de l'information.",
    chapitres: [
      "Chapitre 01 : Algorithmique : structures conditionnelles et itératives",
      "Chapitre 02 : Initiation à la programmation en langage Python",
      "Chapitre 03 : Réseaux informatiques, adressage IP et protocoles Internet",
      "Chapitre 04 : Sécurité numérique et traitement automatisé des données",
    ],
  },
  "Tle-sci|Mathématiques": {
    description:
      "Préparation d'excellence au Baccalauréat avec théorèmes fondamentaux, démonstrations et annales corrigées pas à pas.",
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
  },
  "Tle-sci|SVT": {
    description:
      "Programme officiel de SVT Terminale D : génétique approfondie, neurosciences et géodynamique.",
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
  },
  "Tle|Philosophie": {
    description:
      "Notions philosophiques majeures, méthodologie de la dissertation philosophique et étude de textes d'auteurs.",
    chapitres: [
      "Chapitre 01 : La conscience, l'inconscient et le sujet",
      "Chapitre 02 : La vérité, la science et les enjeux de la technique",
      "Chapitre 03 : L'État, la justice, le droit et la liberté politique",
      "Chapitre 04 : Philosophie africaine contemporaine, traditions et modernité",
    ],
  },
  "Tle|Informatique": {
    description:
      "Bases de données relationnelles, développement web et sécurité des réseaux informatiques.",
    chapitres: [
      "Chapitre 01 : Bases de données relationnelles et requêtes SQL avancées",
      "Chapitre 02 : Programmation orientée objet (POO) en Python",
      "Chapitre 03 : Développement web fullstack (HTML5, CSS3, JavaScript)",
      "Chapitre 04 : Cybersécurité, cryptographie et administration réseau",
    ],
  },
};

const PREPARATIONS: Record<string, Matiere[]> = {
  "prepa-enspd": [
    {
      matiere: "Prépa Concours ENSPD : Mathématiques de Concours",
      description:
        "Entraînement de haut niveau axé sur la rapidité, l'exactitude des calculs et les astuces de résolution d'épreuves de polytechnique.",
      chapitres: [
        "Module 01 : Algèbre générale, calcul matriciel et systèmes linéaires",
        "Module 02 : Analyse de haut niveau : intégrales impropres, développements limités et séries",
        "Module 03 : Équations différentielles appliquées aux sciences de l'ingénieur",
        "Module 04 : Géométrie analytique 3D, produits scalaire / vectoriel et surfaces",
        "Module 05 : Dénombrement accéléré et calcul des probabilités de concours",
        "Module 06 : Annales corrigées pas à pas des 10 dernières sessions ENSPD",
      ],
      icon: "📐",
    },
    {
      matiere: "Prépa Concours ENSPD : Physique & Chimie d'Ingénierie",
      description:
        "Méthodologie de résolution rapide des épreuves de sciences physiques avec barèmes officiels.",
      chapitres: [
        "Module 01 : Mécanique du solide, dynamique newtonienne et moments d'inertie",
        "Module 02 : Électromagnétisme, induction et régimes transitoires RLC",
        "Module 03 : Thermodynamique industrielle, cycles de Carnot et bilans énergétiques",
        "Module 04 : Optique ondulatoire : interférences, diffraction et réseaux",
        "Module 05 : Chimie des solutions aqueuses, équilibres chimiques et thermochimie",
        "Module 06 : Annales corrigées de physique-chimie du concours ENSPD",
      ],
      icon: "⚛️",
    },
    {
      matiere: "Prépa Concours ENSPD : Épreuves Blanches & QCM Éliminatoires",
      description:
        "Simulations réelles dans les conditions exactes d'examen pour maximiser vos chances de réussite.",
      chapitres: [
        "Module 01 : Épreuve blanche n°1 en temps réel (Maths & Physique - 3h)",
        "Module 02 : Épreuve blanche n°2 avec correction vidéo détaillée",
        "Module 03 : Techniques de gestion du stress, du temps et élimination des pièges classiques",
      ],
      icon: "⚡",
    },
  ],
  "prepa-iut": [
    {
      matiere: "Prépa Concours IUT : Physique & Sciences Industrielles",
      description:
        "Préparation ciblée pour réussir l'entrée en filières technologiques et génie appliqué.",
      chapitres: [
        "Module 01 : Mécanique appliquée, statique et cinématique industrielle",
        "Module 02 : Électricité générale, conversion d'énergie et lois fondamentales",
        "Module 03 : Mesures physiques, métrologie et capteurs industriels",
        "Module 04 : Corrigés types des épreuves antérieures du concours IUT",
      ],
      icon: "⚙️",
    },
    {
      matiere: "Prépa Concours IUT : Mathématiques Pratiques & Logique",
      description:
        "Renforcement méthodique axé sur la logique, la rapidité d'exécution et les calculs sans calculatrice.",
      chapitres: [
        "Module 01 : Calcul vectoriel, géométrie pratique et trigonométrie",
        "Module 02 : Étude de fonctions numériques, approximations et modélisation",
        "Module 03 : Statistiques appliquées, probabilités et raisonnement logique",
        "Module 04 : Épreuves types et annales corrigées du concours IUT",
      ],
      icon: "📐",
    },
    {
      matiere: "Prépa Concours IUT : Sciences Appliquées & Dessin Technique",
      description:
        "Culture technique et industrielle pour faire la différence lors des épreuves de sélection.",
      chapitres: [
        "Module 01 : Notions fondamentales de dessin industriel et projections orthogonales",
        "Module 02 : Électronique fondamentale : diodes, transistors et portes logiques",
        "Module 03 : Matériaux industriels et procédés de fabrication",
      ],
      icon: "🔧",
    },
  ],
};

const ICONES: Record<string, string> = {
  Mathématiques: "📐",
  Informatique: "💻",
  Français: "📖",
  Anglais: "🇬🇧",
  SVT: "🧬",
  "Physique-Chimie": "⚗️",
  Physique: "⚛️",
  Chimie: "🧪",
  Philosophie: "🤔",
};

/** Matières d'une classe ; `cle` choisit les chapitres déjà rédigés. */
function matieres(noms: string[], cles: string[] = []): Matiere[] {
  return noms.map((nom) => {
    const cle = cles.map((c) => `${c}|${nom}`).find((c) => CHAPITRES[c]);
    const detail = cle ? CHAPITRES[cle] : undefined;
    return {
      matiere: nom,
      icon: ICONES[nom] ?? "📚",
      description: detail?.description,
      chapitres: detail?.chapitres ?? [],
    };
  });
}

/** Matières d'une filière technique (liste fournie en texte). */
function matieresTechniques(liste: string): Matiere[] {
  return liste
    .split(",")
    .map((m) => m.trim())
    .filter(Boolean)
    .map((m) => ({
      matiere: m.charAt(0).toUpperCase() + m.slice(1),
      icon: m.toLowerCase().startsWith("math") ? "📐" : "🛠️",
      chapitres: [],
    }));
}

const PREMIER_CYCLE_BASE = ["Mathématiques", "Informatique", "Français", "Anglais", "SVT"];
const SECOND_CYCLE_SCIENTIFIQUE = [
  "Mathématiques",
  "Informatique",
  "Physique",
  "Chimie",
  "SVT",
  "Philosophie",
  "Français",
  "Anglais",
];
const SECOND_CYCLE_LITTERAIRE = [
  "Mathématiques",
  "Informatique",
  "Philosophie",
  "Français",
  "Anglais",
];

function scolaire(
  id: string,
  nom: string,
  sousTitre: string,
  niveauInscription: string,
  liste: Matiere[],
): Parcours {
  return { id, nom, sousTitre, type: "scolaire", niveauInscription, matieres: liste };
}

// ------------------------------------------------------------- A. Général
export const ENSEIGNEMENT_GENERAL: Section[] = [
  {
    titre: "1er cycle",
    sousTitre: "6ème, 5ème, 4ème, 3ème",
    parcours: [
      scolaire(
        "6e",
        "6ème",
        "Premier cycle — classe de Sixième",
        "bepc",
        matieres(PREMIER_CYCLE_BASE),
      ),
      scolaire(
        "5e",
        "5ème",
        "Premier cycle — classe de Cinquième",
        "bepc",
        matieres(PREMIER_CYCLE_BASE),
      ),
      scolaire(
        "4e",
        "4ème",
        "Premier cycle — classe de Quatrième",
        "bepc",
        matieres(PREMIER_CYCLE_BASE),
      ),
      scolaire(
        "3e",
        "3ème",
        "Premier cycle — classe de Troisième (BEPC)",
        "bepc",
        matieres(
          ["Mathématiques", "Informatique", "Physique-Chimie", "Français", "Anglais", "SVT"],
          ["3ème"],
        ),
      ),
    ],
  },
  {
    titre: "2nd cycle",
    sousTitre: "2nde, 1ère, Terminale",
    parcours: [
      scolaire(
        "2nde-c-ti",
        "2nde C & TI",
        "Seconde scientifique",
        "probatoire",
        matieres(SECOND_CYCLE_SCIENTIFIQUE),
      ),
      scolaire(
        "2nde-a",
        "2nde A",
        "Seconde littéraire",
        "probatoire",
        matieres(SECOND_CYCLE_LITTERAIRE),
      ),
      scolaire(
        "1ere-cdti",
        "1ère C, D & TI",
        "Première scientifique (Probatoire)",
        "probatoire",
        matieres(SECOND_CYCLE_SCIENTIFIQUE, ["1ère-sci", "1ère"]),
      ),
      scolaire(
        "1ere-a",
        "1ère A",
        "Première littéraire (Probatoire)",
        "probatoire",
        matieres(SECOND_CYCLE_LITTERAIRE, ["1ère"]),
      ),
      scolaire(
        "tle-cdti",
        "Tle C, D & TI",
        "Terminale scientifique (Baccalauréat)",
        "bac",
        matieres(SECOND_CYCLE_SCIENTIFIQUE, ["Tle-sci", "Tle"]),
      ),
      scolaire(
        "tle-a",
        "Tle A",
        "Terminale littéraire (Baccalauréat)",
        "bac",
        matieres(SECOND_CYCLE_LITTERAIRE, ["Tle"]),
      ),
    ],
  },
];

// ----------------------------------------------------------- B. Technique
function filiere(
  id: string,
  nom: string,
  cycle: "1er cycle" | "2nd cycle",
  specialites: string,
  liste: string,
): Parcours {
  return {
    id,
    nom,
    sousTitre: cycle === "1er cycle" ? "1ère, 2ème et 3ème année" : "2nde, 1ère et Terminale",
    badge: cycle,
    specialites: specialites ? specialites.split(",").map((s) => s.trim()) : undefined,
    type: "technique",
    niveauInscription: cycle === "1er cycle" ? "bepc" : "probatoire",
    matieres: matieresTechniques(liste),
  };
}

export const TECHNIQUE_INDUSTRIEL: Section[] = [
  {
    titre: "1er cycle",
    sousTitre: "1ère, 2ème, 3ème année",
    parcours: [
      filiere(
        "ti1-genie-mecanique",
        "Génie mécanique",
        "1er cycle",
        "AJUST, MEFA, MARE, MAIN, MAEL, CAPA, RECA, COOM, MEFE, AFSCI",
        "Mathématiques, dessin technique, électricité automobile, dessin industriel, matériaux, maintenance",
      ),
      filiere(
        "ti1-genie-electrique",
        "Génie électrique",
        "1er cycle",
        "ELEQ, ELBA, ELAU, ELME, ELNI, FRCL",
        "Mathématiques, électricité générale, mesures, maintenance, automatisme, thermodynamique",
      ),
      filiere(
        "ti1-chimie",
        "Chimie",
        "1er cycle",
        "AICI (aide chimiste industriel), AICB (aide chimiste biologiste)",
        "Mathématiques, chimie professionnelle",
      ),
      filiere(
        "ti1-genie-civil-bois",
        "Génie civil & Bois",
        "1er cycle",
        "MACO, DEBA, CARR, INSA, MENU, CERAM",
        "Mathématiques, matériaux, topographie, construction, dessin bâtiment",
      ),
      filiere(
        "ti1-agriculture",
        "Agriculture",
        "1er cycle",
        "PA, PA-PPO, PA-PV, PV, PV-PC",
        "Mathématiques, biologie, agronomie, élevage, production végétale",
      ),
      filiere(
        "ti1-arts-modes",
        "Arts & modes",
        "1er cycle",
        "COME, ESCO, DECOR, PEINT, SCULP",
        "Mathématiques, couture, technologie textile, coiffure, esthétique, hygiène",
      ),
    ],
  },
  {
    titre: "2nd cycle",
    sousTitre: "2nde, 1ère, Terminale",
    parcours: [
      filiere(
        "ti2-genie-mecanique",
        "Génie mécanique",
        "2nd cycle",
        "F1, E, CM, MA, MEM, MF/CM, CMA-MVT, CMA-MVPL, BIJO",
        "Mathématiques, physique, mécanique, technologie, résistance des matériaux, maintenance industrielle",
      ),
      filiere(
        "ti2-genie-electrique",
        "Génie électrique",
        "2nd cycle",
        "F2, F3, F5, MAV, MISE, MEHB",
        "Mathématiques, mesures, électrotechnique, froid industriel, thermodynamique, maintenance",
      ),
      filiere(
        "ti2-chimie-biomedical",
        "Chimie & Biomédical",
        "2nd cycle",
        "CI, F6-BIPE, F6-COPH, F7, F8",
        "Mathématiques, sciences sanitaires et sociales, microbiologie, techniques de laboratoire, hygiène",
      ),
      filiere(
        "ti2-genie-civil",
        "Génie civil",
        "2nd cycle",
        "F4BA, F4BE, B4TP, GTTO, IS, CERAM",
        "Mathématiques, résistance des matériaux, technologie de construction, topographie, géotechnique",
      ),
      filiere(
        "ti2-genie-bois",
        "Génie bois",
        "2nd cycle",
        "MEB, IB",
        "Mathématiques, technologie du bois, dessin mobilier, transformation, fabrication",
      ),
      filiere(
        "ti2-forets",
        "Forêts",
        "2nd cycle",
        "EF, TGF",
        "Mathématiques, exploitation forestière, gestion forestière, sylviculture",
      ),
      filiere(
        "ti2-agriculture",
        "Agriculture",
        "2nd cycle",
        "PA, PA-AQ, PA-PM, PA-PP, PV, PV-PCLGC, PV-PCP, PV-PMF, PV-PS, MEA",
        "Agronomie, zootechnie, biologie, techniques de production",
      ),
      filiere(
        "ti2-agro-industrie",
        "Agro-industrie",
        "2nd cycle",
        "TC-PA, TP",
        "Mathématiques, transformation agroalimentaire, conservation, contrôle qualité",
      ),
      filiere(
        "ti2-arts-habillement",
        "Arts & habillement",
        "2nd cycle",
        "IH (industrie de l'habillement), BP CF (couture flou), PEINT (peinture)",
        "Mathématiques, couture",
      ),
    ],
  },
];

export const TECHNIQUE_COMMERCIAL: Section[] = [
  {
    titre: "1er cycle",
    sousTitre: "1ère, 2ème, 3ème année",
    parcours: [
      filiere(
        "tc1-sebu",
        "SEBU — Secrétariat bureautique",
        "1er cycle",
        "",
        "Mathématiques, saisie de texte, bureautique, correspondance administrative, classement",
      ),
      filiere(
        "tc1-seme",
        "SEME — Secrétariat médical",
        "1er cycle",
        "",
        "Mathématiques, secrétariat médical, terminologie médicale, bureautique, accueil",
      ),
      filiere(
        "tc1-escom",
        "ESCOM — Employé des services comptables",
        "1er cycle",
        "",
        "Mathématiques, comptabilité générale, calcul commercial, documents comptables",
      ),
      filiere(
        "tc1-esfi",
        "ESFI — Employé des services financiers",
        "1er cycle",
        "",
        "Mathématiques, calcul financier, opérations financières, comptabilité, économie",
      ),
      filiere(
        "tc1-esf",
        "ESF — Économie sociale et familiale",
        "1er cycle",
        "",
        "Mathématiques, économie familiale, nutrition, hygiène, gestion domestique",
      ),
      filiere(
        "tc1-vente",
        "VENTE — Vente",
        "1er cycle",
        "",
        "Mathématiques, techniques de vente, calcul commercial, gestion des stocks, marketing",
      ),
      filiere(
        "tc1-re",
        "RE — Restauration",
        "1er cycle",
        "",
        "Mathématiques, restauration, techniques des services, hygiène alimentaire",
      ),
      filiere(
        "tc1-sh",
        "SH — Service hôtelier",
        "1er cycle",
        "",
        "Mathématiques, accueil, service hôtelier, communication professionnelle",
      ),
    ],
  },
  {
    titre: "2nd cycle",
    sousTitre: "2nde, 1ère, Terminale",
    parcours: [
      filiere(
        "tc2-aca",
        "ACA — Action et communication administratives",
        "2nd cycle",
        "",
        "Mathématiques, communication administrative, secrétariat, bureautique, organisation administrative, droit",
      ),
      filiere(
        "tc2-acc",
        "ACC — Action et communication commerciales",
        "2nd cycle",
        "",
        "Mathématiques, marketing, action commerciale, techniques de vente, économie, gestion commerciale",
      ),
      filiere(
        "tc2-cg",
        "CG — Comptabilité et gestion",
        "2nd cycle",
        "",
        "Mathématiques, comptabilité générale, comptabilité analytique, mathématiques financières, économie, droit",
      ),
      filiere(
        "tc2-fig",
        "FIG — Fiscalité et informatique de gestion",
        "2nd cycle",
        "",
        "Mathématiques, fiscalité, comptabilité, informatique de gestion, mathématiques financières",
      ),
      filiere(
        "tc2-ses",
        "SES — Sciences économiques et sociales",
        "2nd cycle",
        "",
        "Mathématiques, économie générale, sciences sociales, statistiques, droit",
      ),
      filiere(
        "tc2-esf",
        "ESF — Économie sociale et familiale",
        "2nd cycle",
        "",
        "Mathématiques, nutrition, hygiène, économie familiale, gestion, sciences sociales",
      ),
      filiere(
        "tc2-ho-he",
        "HO/HE — Hôtellerie / Hébergement",
        "2nd cycle",
        "",
        "Mathématiques, gestion hôtelière, accueil, hébergement, comptabilité hôtelière",
      ),
      filiere(
        "tc2-to-aat-av",
        "TO/AAT/AV — Tourisme / Accueil et animation touristique / Agence de voyage",
        "2nd cycle",
        "",
        "Mathématiques, géographie touristique, techniques touristiques, communication, gestion des voyages",
      ),
      filiere(
        "tc2-bpa-cu",
        "BPA/CU — Boulangerie-pâtisserie / Cuisine",
        "2nd cycle",
        "",
        "Mathématiques, technologie de boulangerie-pâtisserie, travaux pratiques de boulangerie, travaux pratiques de pâtisserie",
      ),
    ],
  },
];

// ------------------------------------------------ Anciens sujets d'examens
export const ANNEES_SUJETS = [2026, 2025, 2024, 2023, 2022, 2021, 2020] as const;

/** Lien vers la banque d'épreuves : type d'examen et mot-clé (série, filière…). */
export type LienSujets = { libelle: string; type: string; q?: string };

export const EXAMENS_GENERAL: { examen: string; liens: LienSujets[] }[] = [
  { examen: "BEPC", liens: [{ libelle: "BEPC", type: "BEPC" }] },
  {
    examen: "Probatoire",
    liens: ["A", "C", "D", "TI"].map((s) => ({ libelle: `Série ${s}`, type: "Probatoire", q: s })),
  },
  {
    examen: "Baccalauréat",
    liens: ["A", "C", "D", "TI"].map((s) => ({
      libelle: `Série ${s}`,
      type: "Baccalauréat",
      q: s,
    })),
  },
];

export const EXAMENS_TECHNIQUE: { examen: string; liens: LienSujets[] }[] = [
  {
    examen: "CAP",
    liens: [
      { libelle: "Industriel", type: "CAP", q: "industriel" },
      { libelle: "STT", type: "CAP", q: "STT" },
    ],
  },
  {
    examen: "Probatoire",
    liens: [
      { libelle: "Industriel", type: "Probatoire", q: "industriel" },
      { libelle: "STT", type: "Probatoire", q: "STT" },
    ],
  },
  {
    examen: "Baccalauréat",
    liens: [
      { libelle: "Industriel", type: "Baccalauréat", q: "industriel" },
      { libelle: "STT", type: "Baccalauréat", q: "STT" },
    ],
  },
];

// ------------------------------------------------------ Concours d'entrée
export type Concours = {
  sigle: string;
  nom: string;
  categorie: string;
  /** Mot-clé de recherche dans la banque d'épreuves. */
  q: string;
  /** Parcours de préparation (chapitres) quand il existe. */
  preparation?: string;
  /** Mentions et filières (IUT). */
  filieres?: { mention: string; liste: string[] }[];
};

export const CONCOURS: Concours[] = [
  {
    sigle: "ENSPY",
    nom: "École Nationale Supérieure Polytechnique de Yaoundé (Université de Yaoundé I)",
    categorie: "Polytechnique",
    q: "ENSPY",
  },
  {
    sigle: "ENSPD",
    nom: "École Nationale Supérieure Polytechnique de Douala (Université de Douala)",
    categorie: "Polytechnique",
    q: "ENSPD",
    preparation: "enspd",
  },
  {
    sigle: "ENSPM",
    nom: "École Nationale Supérieure Polytechnique de Maroua (Université de Maroua)",
    categorie: "Polytechnique",
    q: "ENSPM",
  },
  {
    sigle: "ENSPY-ESEKA",
    nom: "École Nationale Supérieure Polytechnique de Yaoundé — site d'Ilanga/Éséka (Université de Yaoundé I), cycle des ingénieurs, filière Sciences et Technologies",
    categorie: "Polytechnique",
    q: "Eseka",
  },
  {
    sigle: "Médecine",
    nom: "Médecine générale — concours d'entrée en faculté de médecine (FMSB et facultés de médecine)",
    categorie: "Santé",
    q: "medecine",
  },
  {
    sigle: "ESTLC",
    nom: "École Supérieure de Transport, de Logistique et de Commerce — Ambam (Université d'Ebolowa)",
    categorie: "Grandes écoles",
    q: "ESTLC",
  },
  {
    sigle: "ENSTMO",
    nom: "École Nationale Supérieure des Sciences et Techniques Maritimes et Océaniques — Kribi (Université d'Ebolowa)",
    categorie: "Grandes écoles",
    q: "ENSTMO",
  },
  {
    sigle: "ESSUT",
    nom: "École Supérieure des Sciences de l'Urbanisme et du Tourisme — Abong-Mbang (Université de Bertoua)",
    categorie: "Grandes écoles",
    q: "ESSUT",
  },
  {
    sigle: "EGEM",
    nom: "École de Géologie et d'Exploitation Minière — Meiganga (Université de Ngaoundéré)",
    categorie: "Grandes écoles",
    q: "EGEM",
  },
  {
    sigle: "IUT",
    nom: "Institut Universitaire de Technologie de Douala",
    categorie: "Instituts de technologie",
    q: "IUT",
    preparation: "iut",
    filieres: [
      {
        mention: "MTI — Technologies industrielles",
        liste: [
          "GIM — Génie industriel et maintenance",
          "GMP — Génie mécanique et productique",
          "GTE — Génie thermique et énergie",
          "GME — Génie métallurgique",
          "GMI — Génie des mines",
          "GC — Génie civil",
          "MET — Météorologie",
          "Travaux publics (site d'Édéa)",
        ],
      },
      {
        mention: "MTIN — Technologies de l'information et du numérique",
        liste: [
          "GI — Génie informatique",
          "GEII — Génie électrique et informatique industrielle",
          "GRT — Génie des réseaux et télécommunications",
          "GBM — Génie biomédical",
        ],
      },
      {
        mention: "MTT — Technologies du tertiaire",
        liste: [
          "GAPMO — Gestion appliquée aux petites et moyennes organisations",
          "GLT — Génie logistique et transport",
          "OGA — Organisation et gestion administrative",
          "HT — Hôtellerie et tourisme (site d'Édéa)",
        ],
      },
    ],
  },
];

/** Parcours de préparation aux concours (chapitres détaillés). */
export const PREPARATIONS_CONCOURS: Parcours[] = [
  {
    id: "enspd",
    nom: "Préparation au concours ENSPD",
    sousTitre: "École Nationale Supérieure Polytechnique de Douala",
    type: "concours",
    niveauInscription: "enspd",
    matieres: PREPARATIONS["prepa-enspd"] ?? [],
  },
  {
    id: "iut",
    nom: "Préparation au concours IUT",
    sousTitre: "Institut Universitaire de Technologie",
    type: "concours",
    niveauInscription: "iut",
    matieres: PREPARATIONS["prepa-iut"] ?? [],
  },
];

/** Tous les parcours ouvrables par `?niveau=`. */
export const TOUS_LES_PARCOURS: Parcours[] = [
  ...ENSEIGNEMENT_GENERAL,
  ...TECHNIQUE_INDUSTRIEL,
  ...TECHNIQUE_COMMERCIAL,
]
  .flatMap((s) => s.parcours)
  .concat(PREPARATIONS_CONCOURS);
