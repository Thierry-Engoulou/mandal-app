// Fiches « Métiers » (réalité camerounaise). Aucun salaire ni nombre de postes :
// ces chiffres varient et deviendraient vite faux.

export function metier({
  slug,
  titre,
  categorie,
  niveau,
  resume,
  missions,
  parcours,
  qualites,
  realite,
  conseil,
  formations = [],
  mots_cles = [],
  sources,
}) {
  const liste = (items) => items.map((i) => `- ${i}`).join("\n");
  return {
    slug: `metier-${slug}`,
    titre,
    categorie,
    niveau_acces: niveau,
    resume,
    contenu: `## Le métier
${liste(missions)}

## Comment y arriver au Cameroun
${liste(parcours)}

## Qualités utiles
${liste(qualites)}

## La réalité du terrain
${realite}

## Conseil Mandal
${conseil}`,
    debouches: [],
    formations,
    mots_cles: [titre.toLowerCase(), ...mots_cles],
    sources,
  };
}

export const METIERS = [
  // ---------------------------------------------------------------- Santé
  metier({
    slug: "medecin",
    titre: "Médecin",
    categorie: "Santé",
    niveau: "Bac C ou D / A Level sciences + concours de médecine",
    resume:
      "Diagnostique et soigne les patients, en hôpital public, en clinique privée, en mission humanitaire ou en zone rurale.",
    missions: [
      "Examiner les patients, poser un diagnostic, prescrire des traitements",
      "Prévenir les maladies (vaccination, paludisme, santé maternelle)",
      "Se spécialiser éventuellement (chirurgie, pédiatrie, gynécologie…)",
    ],
    parcours: [
      "Bac C ou D, ou A Level biology, chemistry, physics",
      "Concours d'entrée en faculté de médecine (FMSB, FMSP Douala, FHS Buea…)",
      "Environ 7 ans d'études jusqu'au doctorat en médecine, puis spécialisation éventuelle",
    ],
    qualites: [
      "Excellent niveau en SVT et chimie",
      "Résistance au stress et à la fatigue",
      "Empathie et sens de l'écoute",
    ],
    realite:
      "Les besoins sont importants, surtout dans les régions éloignées des grandes villes. Les débuts se font souvent dans les hôpitaux publics de district.",
    conseil:
      "Prépare le concours avec les annales dès la Terminale et garde un plan B (paramédical, biologie) pour ne pas perdre d'année.",
    formations: ["FMSB", "FMSP Douala", "FHS Buea"],
    mots_cles: ["médecine", "docteur", "hôpital", "santé"],
    sources: ["MINESUP", "UY1", "MINSANTE"],
  }),
  metier({
    slug: "infirmier",
    titre: "Infirmier / Infirmière",
    categorie: "Santé",
    niveau: "Probatoire ou Baccalauréat / GCE + concours ou BTS/HND santé",
    resume:
      "Dispense les soins, surveille les patients et accompagne les médecins à l'hôpital, en centre de santé ou en entreprise.",
    missions: [
      "Réaliser les soins (pansements, injections, perfusions)",
      "Surveiller l'état des patients et alerter",
      "Éduquer à la santé (hygiène, paludisme, nutrition)",
    ],
    parcours: [
      "Concours des écoles publiques de formation paramédicale (MINSANTE, universités)",
      "Ou BTS/HND santé dans un institut privé agréé",
      "Environ 3 ans de formation selon le diplôme",
    ],
    qualites: ["Rigueur et propreté", "Calme en situation d'urgence", "Bienveillance"],
    realite:
      "Métier très demandé dans les hôpitaux publics, les cliniques privées et les ONG. Le travail de nuit et le week-end fait partie du métier.",
    conseil:
      "Vérifie absolument que ton école est agréée : un diplôme non reconnu ne permet ni concours ni emploi public.",
    formations: ["Écoles paramédicales MINSANTE", "BTS/HND santé"],
    mots_cles: ["infirmière", "soins", "paramédical"],
    sources: ["MINSANTE", "MINESUP"],
  }),
  metier({
    slug: "sage-femme",
    titre: "Sage-femme / Maïeuticien",
    categorie: "Santé",
    niveau: "Baccalauréat ou GCE A Level + concours",
    resume:
      "Suit les grossesses, réalise les accouchements et accompagne la mère et le nouveau-né.",
    missions: [
      "Consultations prénatales",
      "Accouchements et soins au nouveau-né",
      "Planning familial et santé de la reproduction",
    ],
    parcours: [
      "Concours des écoles de sages-femmes publiques ou filières universitaires",
      "Ou formation dans un institut privé agréé",
    ],
    qualites: ["Sang-froid", "Sens des responsabilités", "Écoute"],
    realite:
      "Profession essentielle pour réduire la mortalité maternelle ; les besoins sont forts dans les districts de santé ruraux.",
    conseil: "Les stages en maternité sont décisifs : sois présent(e) et curieux(se).",
    formations: ["Écoles de sages-femmes", "Filières santé des universités"],
    mots_cles: ["sage femme", "accouchement", "maternité", "maïeutique"],
    sources: ["MINSANTE", "MINESUP"],
  }),
  metier({
    slug: "pharmacien",
    titre: "Pharmacien",
    categorie: "Santé",
    niveau: "Bac C ou D / A Level sciences + concours",
    resume:
      "Délivre et conseille sur les médicaments, en officine, à l'hôpital, en laboratoire ou dans l'industrie.",
    missions: [
      "Vérifier les ordonnances et conseiller les patients",
      "Gérer les stocks de médicaments",
      "Lutter contre les médicaments de rue et la contrefaçon",
    ],
    parcours: [
      "Concours d'entrée en pharmacie (facultés de médecine et sciences pharmaceutiques)",
      "Plusieurs années d'études jusqu'au doctorat en pharmacie",
    ],
    qualites: ["Rigueur scientifique", "Sens du conseil", "Éthique"],
    realite:
      "L'officine demande un investissement important ; beaucoup commencent comme pharmaciens assistants, à l'hôpital ou chez les distributeurs.",
    conseil:
      "Excellente chimie et biologie indispensables ; informe-toi aussi sur la pharmacie hospitalière et l'industrie.",
    formations: ["FMSB", "FMSP Douala"],
    mots_cles: ["pharmacie", "médicaments", "officine"],
    sources: ["MINESUP", "MINSANTE"],
  }),
  metier({
    slug: "technicien-laboratoire",
    titre: "Technicien de laboratoire d'analyses médicales",
    categorie: "Santé",
    niveau: "Baccalauréat (D, C, F7) / A Level + formation paramédicale ou BTS/HND",
    resume:
      "Réalise les analyses de sang, d'urine et de prélèvements qui permettent aux médecins de poser un diagnostic.",
    missions: [
      "Prélèvements et analyses (paludisme, VIH, glycémie…)",
      "Entretien des appareils",
      "Respect strict des règles d'hygiène et de qualité",
    ],
    parcours: [
      "Écoles paramédicales publiques sur concours",
      "BTS/HND en biologie médicale dans un institut agréé",
      "Licence en biologie / sciences biomédicales",
    ],
    qualites: ["Précision", "Minutie", "Respect des protocoles"],
    realite:
      "Postes dans les hôpitaux, laboratoires privés, centres de santé et programmes de santé publique.",
    conseil: "Les séries D et F7 préparent bien à ce métier.",
    formations: ["Écoles paramédicales", "BTS/HND biologie médicale"],
    mots_cles: ["laborantin", "analyses", "biologie médicale"],
    sources: ["MINSANTE", "MINESUP"],
  }),
  metier({
    slug: "veterinaire",
    titre: "Vétérinaire / Technicien d'élevage",
    categorie: "Agriculture & environnement",
    niveau: "Bac C ou D / A Level sciences",
    resume:
      "Soigne les animaux, protège les élevages et veille à la sécurité sanitaire des aliments d'origine animale.",
    missions: [
      "Soins et vaccination des animaux",
      "Conseil aux éleveurs (bovins, volaille, porcs, poissons)",
      "Contrôle sanitaire des viandes et produits animaux",
    ],
    parcours: [
      "Études vétérinaires (École des sciences et médecine vétérinaire, Université de Ngaoundéré) sur concours",
      "Formations de techniciens d'élevage (centres MINEPIA, BTS/HND)",
    ],
    qualites: ["Amour des animaux", "Endurance", "Sens de l'observation"],
    realite:
      "L'élevage (Adamaoua, Nord, Ouest) et l'aviculture sont des secteurs importants ; beaucoup s'installent à leur compte.",
    conseil:
      "Associe compétences vétérinaires et gestion pour créer ton propre élevage ou cabinet.",
    formations: ["Université de Ngaoundéré", "Centres MINEPIA"],
    mots_cles: ["animaux", "élevage", "volaille", "bétail"],
    sources: ["MINEPIA", "UNIV_NGAOUNDERE", "MINESUP"],
  }),
  // --------------------------------------------------- BTP, industrie, énergie
  metier({
    slug: "ingenieur-genie-civil",
    titre: "Ingénieur en génie civil",
    categorie: "BTP & construction",
    niveau: "Bac C, E ou F4 / A Level sciences + école d'ingénieurs",
    resume:
      "Conçoit, calcule et dirige la construction de bâtiments, routes, ponts, barrages et réseaux.",
    missions: [
      "Concevoir et dimensionner les ouvrages",
      "Diriger les chantiers et contrôler la qualité",
      "Gérer budgets, délais et équipes",
    ],
    parcours: [
      "Concours d'entrée dans une école d'ingénieurs (ENSP Yaoundé, ENSPD Douala, ENSTP…)",
      "Environ 5 ans d'études",
      "Ou IUT/BTS génie civil puis admission parallèle",
    ],
    qualites: [
      "Solide en maths et mécanique",
      "Leadership sur le chantier",
      "Sens des responsabilités (sécurité)",
    ],
    realite:
      "Grands projets d'infrastructures (routes, ports, barrages, logements) : le secteur recrute, avec des missions parfois loin des grandes villes.",
    conseil:
      "Apprends tôt un logiciel de dessin et de calcul de structures, et fais des stages sur de vrais chantiers.",
    formations: ["ENSP Yaoundé", "ENSPD Douala", "ENSTP"],
    mots_cles: ["btp", "bâtiment", "travaux publics", "routes", "ponts", "construction"],
    sources: ["MINESUP", "UY1", "MINTP"],
  }),
  metier({
    slug: "technicien-btp",
    titre: "Technicien en bâtiment et travaux publics / Chef de chantier",
    categorie: "BTP & construction",
    niveau: "CAP, BT ou Bac F4 / BTS-HND génie civil",
    resume:
      "Organise et suit les travaux sur le chantier : implantation, coffrage, béton, maçonnerie, voirie.",
    missions: [
      "Lire les plans et implanter l'ouvrage",
      "Encadrer les ouvriers et contrôler l'avancement",
      "Commander et gérer les matériaux",
    ],
    parcours: [
      "Lycée technique (F4 bâtiment ou travaux publics)",
      "IUT ou BTS/HND génie civil",
      "Expérience de chantier",
    ],
    qualites: ["Sens pratique", "Autorité", "Rigueur sur la sécurité"],
    realite:
      "Beaucoup de travail dans la construction privée et publique ; possibilité de devenir entrepreneur du bâtiment.",
    conseil:
      "Maîtrise les métrés et les devis : c'est la base pour devenir un jour chef d'entreprise.",
    formations: ["Lycées techniques", "IUT", "BTS/HND"],
    mots_cles: ["chantier", "bâtiment", "maçonnerie", "f4", "génie civil"],
    sources: ["OBC", "MINESUP", "MINEFOP"],
  }),
  metier({
    slug: "architecte",
    titre: "Architecte",
    categorie: "BTP & construction",
    niveau: "Baccalauréat (C, D, E ou F4) + école d'architecture",
    resume:
      "Conçoit des bâtiments beaux, solides et adaptés au climat et à la culture, du plan au suivi du chantier.",
    missions: [
      "Concevoir les plans et les maquettes",
      "Respecter les règles d'urbanisme",
      "Suivre la construction",
    ],
    parcours: [
      "Écoles d'architecture (ex. filière architecture de l'Institut des Beaux-Arts de Foumban, écoles spécialisées)",
      "Plusieurs années d'études puis inscription à l'ordre professionnel",
    ],
    qualites: ["Créativité", "Sens de l'espace", "Bon niveau en dessin et en maths"],
    realite:
      "Clients privés, promoteurs, collectivités ; l'architecture adaptée au climat tropical et aux matériaux locaux est un vrai atout.",
    conseil: "Dessine beaucoup et apprends un logiciel de modélisation 3D.",
    formations: ["Institut des Beaux-Arts de Foumban", "Écoles d'architecture"],
    mots_cles: ["architecture", "plans", "urbanisme", "design"],
    sources: ["MINESUP", "UNIV_DSCHANG"],
  }),
  metier({
    slug: "geometre",
    titre: "Géomètre-topographe",
    categorie: "BTP & construction",
    niveau: "Bac C, E ou F4 + formation spécialisée",
    resume:
      "Mesure les terrains, délimite les parcelles et fournit les plans indispensables aux constructions et au foncier.",
    missions: [
      "Relevés topographiques (GPS, station totale)",
      "Bornage et plans de parcelles",
      "Implantation des ouvrages",
    ],
    parcours: ["ENSTP ou filières de topographie et de géomatique", "BTS/HND topographie"],
    qualites: ["Précision", "Goût du terrain", "Maîtrise des outils numériques"],
    realite:
      "Le foncier et la construction en font un métier recherché ; le titre de géomètre-expert est réglementé.",
    conseil: "Apprends les logiciels de SIG (systèmes d'information géographique).",
    formations: ["ENSTP", "BTS/HND topographie"],
    mots_cles: ["topographie", "foncier", "cadastre", "bornage", "sig"],
    sources: ["MINTP", "MINESUP"],
  }),
  metier({
    slug: "electricien",
    titre: "Électricien (bâtiment et industrie)",
    categorie: "Industrie & énergie",
    niveau: "CAP, BT ou Bac F3 / formation professionnelle",
    resume:
      "Installe et dépanne les installations électriques des maisons, bureaux et usines, y compris le solaire.",
    missions: [
      "Installer câblage, tableaux, prises et éclairage",
      "Dépanner et mettre en sécurité",
      "Installer des kits solaires",
    ],
    parcours: [
      "Lycée technique (F3 électrotechnique)",
      "Centres de formation professionnelle agréés",
      "BTS/HND électrotechnique",
    ],
    qualites: ["Rigueur et respect de la sécurité", "Logique", "Habileté manuelle"],
    realite:
      "Très demandé, avec beaucoup d'auto-emploi ; l'énergie solaire ouvre un marché en forte croissance.",
    conseil:
      "Ajoute le solaire photovoltaïque à tes compétences et soigne ta réputation : le bouche-à-oreille fait le chiffre d'affaires.",
    formations: ["Lycées techniques (F3)", "Centres MINEFOP", "BTS/HND"],
    mots_cles: ["électricité", "électrotechnique", "f3", "solaire", "installation"],
    sources: ["OBC", "MINEFOP"],
  }),
  metier({
    slug: "technicien-energie-solaire",
    titre: "Technicien en énergies renouvelables (solaire)",
    categorie: "Industrie & énergie",
    niveau: "CAP/BT électricité, BTS/HND ou Licence professionnelle",
    resume:
      "Dimensionne, installe et entretient des installations solaires pour les ménages, les écoles, les centres de santé et les entreprises.",
    missions: [
      "Dimensionner panneaux, batteries et onduleurs",
      "Installer et mettre en service",
      "Assurer la maintenance",
    ],
    parcours: [
      "Électrotechnique au lycée technique",
      "Formations spécialisées en énergies renouvelables (BTS/HND, licences professionnelles)",
    ],
    qualites: ["Bases solides en électricité", "Autonomie", "Sens du service client"],
    realite:
      "Les coupures d'électricité et les zones non raccordées créent une forte demande, en ville comme au village.",
    conseil:
      "Commence par de petites installations bien faites et garanties ; ta réputation sera ton meilleur argument.",
    formations: ["BTS/HND énergies renouvelables", "Licences professionnelles"],
    mots_cles: ["énergie", "solaire", "photovoltaïque", "renouvelable"],
    sources: ["MINESUP", "MINEFOP"],
  }),
  metier({
    slug: "mecanicien-auto",
    titre: "Mécanicien automobile / Technicien de maintenance",
    categorie: "Industrie & énergie",
    niveau: "CAP, BT ou formation professionnelle",
    resume: "Diagnostique et répare les véhicules (voitures, motos, engins) et les machines.",
    missions: [
      "Diagnostic des pannes",
      "Réparation et entretien",
      "Électronique automobile (diagnostic par ordinateur)",
    ],
    parcours: [
      "Lycée technique (mécanique automobile)",
      "Centres de formation professionnelle",
      "Apprentissage dans un garage sérieux",
    ],
    qualites: ["Curiosité technique", "Patience", "Honnêteté avec les clients"],
    realite:
      "Le parc de véhicules, de motos et d'engins assure du travail ; l'électronique embarquée change le métier.",
    conseil: "Forme-toi au diagnostic électronique : les garages modernes en manquent.",
    formations: ["Lycées techniques", "Centres MINEFOP"],
    mots_cles: ["mécanique", "garage", "automobile", "moto", "maintenance"],
    sources: ["MINEFOP", "OBC"],
  }),
  metier({
    slug: "frigoriste",
    titre: "Frigoriste / Technicien froid et climatisation",
    categorie: "Industrie & énergie",
    niveau: "CAP, BT ou Bac F5 / BTS",
    resume: "Installe et répare réfrigérateurs, chambres froides et climatiseurs.",
    missions: [
      "Installation de climatiseurs et chambres froides",
      "Dépannage et recharge en fluide",
      "Entretien préventif",
    ],
    parcours: [
      "Lycée technique (F5 froid et climatisation)",
      "Centres de formation professionnelle",
      "BTS/HND",
    ],
    qualites: ["Habileté technique", "Rigueur", "Sens du service"],
    realite:
      "Hôtels, supermarchés, hôpitaux, pêche et agroalimentaire ont besoin du froid : forte demande sous le climat camerounais.",
    conseil: "Les chambres froides pour l'agroalimentaire et la pêche sont un marché porteur.",
    formations: ["Lycées techniques (F5)", "Centres MINEFOP"],
    mots_cles: ["froid", "climatisation", "f5", "réfrigération"],
    sources: ["OBC", "MINEFOP"],
  }),
  metier({
    slug: "geologue",
    titre: "Géologue / Ingénieur des mines",
    categorie: "Industrie & énergie",
    niveau: "Bac C ou D + Licence/Master en géosciences ou école d'ingénieurs des mines",
    resume:
      "Étudie le sous-sol pour trouver et exploiter durablement les ressources (minerais, eau, pétrole) et prévenir les risques naturels.",
    missions: [
      "Prospection minière et hydrogéologique",
      "Études de sols pour la construction",
      "Suivi environnemental des exploitations",
    ],
    parcours: [
      "Licence et master en sciences de la Terre (facultés des sciences)",
      "Écoles d'ingénieurs des mines et de la géologie",
    ],
    qualites: ["Goût du terrain", "Esprit scientifique", "Endurance"],
    realite:
      "Le Cameroun a un potentiel minier (fer, bauxite, or, cobalt) et pétrolier ; l'eau souterraine est aussi un enjeu majeur.",
    conseil: "Associe géologie et outils numériques (SIG, télédétection).",
    formations: ["Facultés des sciences (géologie)", "Écoles des mines"],
    mots_cles: ["géologie", "mines", "pétrole", "forage", "hydrogéologie"],
    sources: ["MINESUP", "UY1"],
  }),
  // --------------------------------------------------------- Numérique
  metier({
    slug: "developpeur",
    titre: "Développeur / Ingénieur logiciel",
    categorie: "Numérique",
    niveau: "Bac TI, C ou E + BTS/HND, Licence ou école d'ingénieurs",
    resume:
      "Conçoit et programme des applications web et mobiles, des logiciels de gestion et des plateformes numériques.",
    missions: [
      "Analyser les besoins",
      "Programmer, tester, corriger",
      "Mettre en ligne et maintenir les applications",
    ],
    parcours: [
      "Licence d'informatique, IUT, BTS/HND en génie logiciel",
      "Écoles d'ingénieurs (génie informatique)",
      "Apprentissage par projets",
    ],
    qualites: ["Logique", "Persévérance", "Curiosité et autoformation"],
    realite:
      "Start-ups (Yaoundé, Douala, Buea), banques, télécoms et freelance pour l'étranger : le portfolio de projets compte autant que le diplôme.",
    conseil:
      "Construis des projets concrets (paiement mobile, gestion d'école, commerce en ligne) et publie ton code.",
    formations: ["Facultés des sciences", "IUT", "ENSP (génie informatique)", "BTS/HND"],
    mots_cles: [
      "informatique",
      "programmation",
      "développeur",
      "web",
      "mobile",
      "application",
      "code",
    ],
    sources: ["MINESUP", "MINPOSTEL"],
  }),
  metier({
    slug: "reseaux-telecoms",
    titre: "Technicien / Ingénieur réseaux et télécommunications",
    categorie: "Numérique",
    niveau: "Bac TI, C, E ou F2 + BTS/HND, IUT ou école d'ingénieurs",
    resume:
      "Installe et sécurise les réseaux informatiques, la fibre, la téléphonie mobile et Internet.",
    missions: [
      "Installer et configurer les réseaux",
      "Surveiller et dépanner",
      "Assurer la cybersécurité",
    ],
    parcours: [
      "IUT ou BTS/HND réseaux et télécoms",
      "Écoles d'ingénieurs (télécommunications)",
      "Certifications professionnelles",
    ],
    qualites: ["Méthode", "Logique", "Disponibilité pour les urgences"],
    realite:
      "Opérateurs télécoms, fournisseurs d'accès, banques, administrations : la cybersécurité est en forte demande.",
    conseil: "Les certifications reconnues (réseaux, sécurité) font la différence à l'embauche.",
    formations: ["IUT", "ENSP", "BTS/HND"],
    mots_cles: ["réseaux", "télécoms", "fibre", "cybersécurité", "internet"],
    sources: ["MINESUP", "MINPOSTEL"],
  }),
  metier({
    slug: "data-analyst",
    titre: "Analyste de données / Statisticien",
    categorie: "Numérique",
    niveau: "Bac C ou TI + Licence/Master ou ISSEA",
    resume:
      "Transforme les données en informations utiles pour décider : enquêtes, tableaux de bord, prévisions.",
    missions: [
      "Collecter et nettoyer les données",
      "Analyser et modéliser",
      "Présenter les résultats",
    ],
    parcours: [
      "ISSEA (statistique)",
      "Masters en mathématiques appliquées, informatique, économie",
      "Formations en science des données",
    ],
    qualites: ["Excellent niveau en maths", "Rigueur", "Esprit de synthèse"],
    realite:
      "INS, banques, télécoms, ONG et projets de développement recherchent ces profils encore rares.",
    conseil:
      "Apprends un outil d'analyse de données (tableur avancé puis un langage de programmation) en plus des statistiques.",
    formations: ["ISSEA", "Facultés des sciences"],
    mots_cles: ["données", "data", "statistique", "analyse", "excel", "python"],
    sources: ["ISSEA", "INS"],
  }),
  // ------------------------------------------- Enseignement, social
  metier({
    slug: "enseignant-secondaire",
    titre: "Professeur de collège ou de lycée",
    categorie: "Enseignement",
    niveau: "Bac (ENS 1er cycle) ou Licence (ENS 2nd cycle)",
    resume:
      "Enseigne une discipline aux élèves du secondaire et les accompagne vers les examens officiels.",
    missions: [
      "Préparer et donner les cours",
      "Évaluer et corriger",
      "Accompagner et orienter les élèves",
    ],
    parcours: [
      "Concours de l'ENS (enseignement général) ou de l'ENSET (enseignement technique)",
      "Recrutement public après la formation, ou enseignement privé",
    ],
    qualites: ["Maîtrise de la discipline", "Patience et pédagogie", "Autorité bienveillante"],
    realite:
      "Grand employeur public ; les affectations peuvent se faire dans toutes les régions, et les effectifs de classe sont souvent élevés.",
    conseil:
      "Commence par donner des cours de répétition : tu sauras vite si la transmission te plaît.",
    formations: ["ENS", "ENSET"],
    mots_cles: ["professeur", "enseignant", "ens", "enseignement"],
    sources: ["MINESUP", "MINESEC"],
  }),
  metier({
    slug: "instituteur",
    titre: "Instituteur / Institutrice",
    categorie: "Enseignement",
    niveau: "BEPC, Probatoire ou Baccalauréat + ENIEG / ENIET",
    resume:
      "Enseigne à l'école maternelle et primaire : lecture, écriture, calcul et éveil des enfants.",
    missions: [
      "Apprendre à lire, écrire, compter",
      "Éduquer et éveiller",
      "Suivre chaque enfant et dialoguer avec les parents",
    ],
    parcours: ["Concours d'entrée dans les Écoles Normales d'Instituteurs (ENIEG / ENIET)"],
    qualites: ["Patience", "Créativité", "Amour des enfants"],
    realite:
      "Les besoins sont importants, surtout dans les zones rurales ; l'enseignement privé recrute aussi.",
    conseil:
      "L'animation de groupes d'enfants (catéchisme, colonies, soutien scolaire) est une excellente préparation.",
    formations: ["ENIEG", "ENIET"],
    mots_cles: ["instituteur", "maîtresse", "école primaire", "maternelle", "enieg"],
    sources: ["MINESEC"],
  }),
  metier({
    slug: "conseiller-orientation",
    titre: "Conseiller d'orientation / Psychologue",
    categorie: "Social & humain",
    niveau: "Licence/Master en psychologie ou sciences de l'éducation + formation",
    resume:
      "Aide les élèves à se connaître, à choisir leur filière et à construire leur projet ; accompagne en cas de difficultés.",
    missions: [
      "Entretiens individuels et tests d'intérêts",
      "Information sur les filières et métiers",
      "Accompagnement psychologique",
    ],
    parcours: [
      "Licence puis master en psychologie ou sciences de l'éducation",
      "Concours de conseiller d'orientation (ENS) pour le public",
    ],
    qualites: ["Écoute", "Discrétion", "Connaissance du système éducatif"],
    realite:
      "Présents dans les établissements secondaires, les universités, les ONG et le secteur privé (RH).",
    conseil: "Va voir le conseiller d'orientation de ton établissement : c'est gratuit et utile.",
    formations: ["Facultés de lettres et sciences humaines", "ENS"],
    mots_cles: ["orientation", "psychologue", "conseil", "psychologie"],
    sources: ["MINESEC", "MINESUP"],
  }),
  metier({
    slug: "travailleur-social",
    titre: "Travailleur social / Animateur",
    categorie: "Social & humain",
    niveau: "Baccalauréat + formation en travail social",
    resume:
      "Accompagne les personnes et familles en difficulté : enfants vulnérables, personnes handicapées, déplacés internes.",
    missions: [
      "Écouter et orienter vers les aides",
      "Monter des dossiers d'assistance",
      "Animer des actions de prévention",
    ],
    parcours: ["Écoles et filières de travail social", "Licence en sociologie / sciences sociales"],
    qualites: ["Empathie", "Patience", "Sens de l'organisation"],
    realite:
      "Les ONG, les services sociaux publics et les organisations humanitaires emploient ces profils.",
    conseil: "Le bénévolat associatif est une très bonne porte d'entrée.",
    formations: ["Filières de travail social", "Facultés de sciences sociales"],
    mots_cles: ["social", "ong", "humanitaire", "animation"],
    sources: ["MINESUP"],
  }),
  // ------------------------------------------- Droit, administration
  metier({
    slug: "avocat",
    titre: "Avocat",
    categorie: "Droit & administration",
    niveau: "Master en droit + accès au barreau",
    resume:
      "Conseille et défend ses clients devant les tribunaux, en droit civil (francophone) ou en common law (anglophone).",
    missions: [
      "Conseiller juridiquement",
      "Plaider devant les juridictions",
      "Rédiger contrats et actes",
    ],
    parcours: [
      "Licence puis master en droit",
      "Examen d'accès au stage, stage auprès d'un avocat, puis inscription au barreau",
    ],
    qualites: ["Éloquence", "Rigueur", "Sens de la justice"],
    realite:
      "Les débuts sont souvent difficiles ; la spécialisation (affaires, travail, foncier) aide à se faire une clientèle.",
    conseil: "Maîtrise les deux systèmes juridiques camerounais et les deux langues officielles.",
    formations: ["Facultés de droit"],
    mots_cles: ["avocat", "barreau", "droit", "justice", "plaider"],
    sources: ["MINESUP", "MINJUSTICE"],
  }),
  metier({
    slug: "magistrat",
    titre: "Magistrat",
    categorie: "Droit & administration",
    niveau: "Licence en droit + concours ENAM (magistrature)",
    resume: "Juge les affaires (magistrat du siège) ou poursuit au nom de la société (parquet).",
    missions: [
      "Instruire et juger les affaires",
      "Veiller à l'application de la loi",
      "Protéger les droits des citoyens",
    ],
    parcours: [
      "Licence en droit",
      "Concours de l'ENAM, division magistrature",
      "Formation à l'ENAM puis nomination",
    ],
    qualites: ["Intégrité", "Impartialité", "Capacité de travail"],
    realite: "Les affectations se font dans les tribunaux de tout le pays.",
    conseil:
      "Prépare le concours avec sérieux (droit, culture générale) et méfie-toi des promesses de places payantes.",
    formations: ["ENAM"],
    mots_cles: ["juge", "magistrature", "tribunal", "procureur"],
    sources: ["ENAM", "ENAM_CONCOURS", "MINJUSTICE"],
  }),
  metier({
    slug: "administrateur-civil",
    titre: "Administrateur civil",
    categorie: "Droit & administration",
    niveau: "Licence + concours ENAM (administration générale)",
    resume:
      "Met en œuvre les politiques publiques dans les ministères et les circonscriptions administratives (sous-préfet, préfet…).",
    missions: [
      "Administrer et coordonner les services publics",
      "Représenter l'État sur le territoire",
      "Préparer les décisions",
    ],
    parcours: [
      "Licence (droit, science politique, économie…)",
      "Concours de l'ENAM, division administration générale",
    ],
    qualites: ["Sens de l'intérêt général", "Leadership", "Discrétion"],
    realite: "Carrière dans toute l'administration et sur tout le territoire national.",
    conseil: "Travaille la culture générale, l'actualité et les institutions camerounaises.",
    formations: ["ENAM"],
    mots_cles: ["administration", "préfet", "sous-préfet", "fonction publique", "enam"],
    sources: ["ENAM", "ENAM_CONCOURS"],
  }),
  metier({
    slug: "inspecteur-impots-douanes",
    titre: "Inspecteur des impôts, du trésor ou des douanes",
    categorie: "Droit & administration",
    niveau: "Baccalauréat (cycle B) ou Licence (cycle A) + concours ENAM (régies financières)",
    resume:
      "Collecte les recettes de l'État, contrôle les entreprises et les marchandises, lutte contre la fraude.",
    missions: [
      "Calculer et contrôler l'impôt",
      "Contrôler les marchandises aux frontières et au port",
      "Gérer les fonds publics",
    ],
    parcours: [
      "Concours de l'ENAM (division des régies financières)",
      "Formation puis affectation",
    ],
    qualites: ["Intégrité", "Rigueur en chiffres", "Fermeté"],
    realite:
      "Carrières dans les centres des impôts, les ports (Douala, Kribi), les frontières et les services du trésor.",
    conseil: "Économie, comptabilité et droit fiscal sont les matières à soigner.",
    formations: ["ENAM"],
    mots_cles: ["impôts", "douane", "trésor", "fiscalité", "régies financières"],
    sources: ["ENAM", "MINFI"],
  }),
  metier({
    slug: "diplomate",
    titre: "Diplomate",
    categorie: "Droit & administration",
    niveau: "Master (IRIC) + recrutement de la fonction publique",
    resume:
      "Représente le Cameroun à l'étranger, négocie et défend ses intérêts, protège les Camerounais de l'étranger.",
    missions: [
      "Négocier et représenter",
      "Analyser l'actualité internationale",
      "Services consulaires",
    ],
    parcours: ["Licence puis concours de l'IRIC", "Recrutement dans le corps diplomatique"],
    qualites: ["Bilinguisme parfait", "Culture générale", "Sens de la négociation"],
    realite:
      "Peu de places, beaucoup de candidats : les organisations internationales et les ONG offrent d'autres débouchés.",
    conseil: "Apprends une troisième langue et suis l'actualité internationale chaque jour.",
    formations: ["IRIC"],
    mots_cles: ["diplomatie", "ambassade", "affaires étrangères", "iric"],
    sources: ["UNIV_YAOUNDE2", "MINESUP"],
  }),
  // ------------------------------------------- Finance, commerce, entreprise
  metier({
    slug: "comptable",
    titre: "Comptable / Expert-comptable",
    categorie: "Commerce & gestion",
    niveau: "Bac commercial + BTS/HND, Licence ou parcours d'expertise comptable",
    resume:
      "Tient les comptes de l'entreprise, prépare les déclarations fiscales et les états financiers.",
    missions: [
      "Enregistrer les opérations",
      "Préparer bilans et déclarations",
      "Conseiller sur la gestion",
    ],
    parcours: [
      "Lycée technique commercial, BTS/HND comptabilité",
      "Licence/Master en comptabilité-finance",
      "Expertise comptable (diplômes et stage réglementés)",
    ],
    qualites: ["Rigueur", "Discrétion", "Aisance avec les chiffres"],
    realite:
      "Toutes les entreprises, ONG et administrations ont besoin de comptables ; le référentiel comptable régional (OHADA) est la base.",
    conseil: "Maîtrise un logiciel comptable et la fiscalité camerounaise.",
    formations: ["BTS/HND", "FSEG", "ESSEC"],
    mots_cles: ["comptabilité", "ohada", "fiscalité", "expert-comptable", "bilan"],
    sources: ["MINESUP", "OBC"],
  }),
  metier({
    slug: "banquier",
    titre: "Conseiller bancaire / Agent de microfinance",
    categorie: "Commerce & gestion",
    niveau: "Baccalauréat + BTS/HND, Licence ou Master (banque, finance)",
    resume: "Accueille et conseille les clients, ouvre les comptes, étudie les demandes de crédit.",
    missions: [
      "Conseiller les clients",
      "Étudier les dossiers de crédit",
      "Vendre les produits financiers (épargne, mobile money…)",
    ],
    parcours: ["BTS/HND banque-finance", "Licence/Master en économie, finance, gestion"],
    qualites: ["Sens commercial", "Rigueur", "Confiance"],
    realite:
      "Banques, établissements de microfinance et services de paiement mobile recrutent ; le numérique transforme le métier.",
    conseil:
      "Comprends bien le mobile money et l'inclusion financière : c'est l'avenir du secteur.",
    formations: ["BTS/HND", "FSEG", "ESSEC"],
    mots_cles: ["banque", "microfinance", "crédit", "finance", "mobile money"],
    sources: ["MINESUP"],
  }),
  metier({
    slug: "commercial",
    titre: "Commercial / Vendeur",
    categorie: "Commerce & gestion",
    niveau: "Tous niveaux (Bac commercial, BTS/HND marketing conseillés)",
    resume:
      "Fait connaître et vend les produits ou services d'une entreprise, fidélise la clientèle.",
    missions: ["Prospecter les clients", "Négocier et conclure", "Suivre la satisfaction"],
    parcours: [
      "Lycée technique commercial",
      "BTS/HND marketing ou action commerciale",
      "Écoles de commerce",
    ],
    qualites: ["Aisance relationnelle", "Persévérance", "Sens de l'objectif"],
    realite:
      "Métier très accessible et recherché (télécoms, distribution, agroalimentaire) ; la rémunération dépend souvent des résultats.",
    conseil:
      "Apprends à vendre en ligne (réseaux sociaux, WhatsApp Business) : c'est devenu indispensable.",
    formations: ["BTS/HND", "ESSEC"],
    mots_cles: ["vente", "marketing", "commerce", "négociation"],
    sources: ["MINESUP", "OBC"],
  }),
  metier({
    slug: "entrepreneur",
    titre: "Entrepreneur / Créateur d'entreprise",
    categorie: "Commerce & gestion",
    niveau: "Tous niveaux",
    resume:
      "Crée et développe sa propre activité : commerce, transformation agricole, services, numérique…",
    missions: [
      "Identifier un besoin et une solution",
      "Trouver le financement",
      "Gérer, vendre, recruter",
    ],
    parcours: [
      "Une formation dans le métier visé (technique, agricole, commerce…)",
      "Formations à la création d'entreprise",
      "Accompagnement (FNE, incubateurs, associations)",
    ],
    qualites: ["Persévérance", "Prise de risque mesurée", "Sens de la gestion"],
    realite:
      "Une grande partie des Camerounais travaille à son compte, souvent dans l'informel ; se formaliser facilite l'accès au crédit et aux marchés.",
    conseil:
      "Commence petit, tiens une comptabilité dès le premier jour et réinvestis tes bénéfices.",
    formations: ["Toutes filières", "Programmes du FNE"],
    mots_cles: ["entreprise", "auto-emploi", "business", "création", "startup"],
    sources: ["FNE", "MINEFOP"],
  }),
  metier({
    slug: "logisticien",
    titre: "Logisticien / Transitaire",
    categorie: "Commerce & gestion",
    niveau: "Baccalauréat + BTS/HND ou Licence en transport-logistique",
    resume:
      "Organise le transport, le stockage et le dédouanement des marchandises, notamment autour des ports de Douala et Kribi.",
    missions: [
      "Planifier les transports",
      "Gérer les entrepôts et stocks",
      "Préparer les formalités douanières",
    ],
    parcours: ["BTS/HND transport-logistique", "IUT, ESSEC (logistique)", "Masters spécialisés"],
    qualites: ["Organisation", "Réactivité", "Maîtrise des documents"],
    realite:
      "Le Cameroun est une porte d'entrée vers les pays voisins (Tchad, RCA) : transit et logistique offrent beaucoup d'emplois.",
    conseil: "Apprends les procédures douanières et l'anglais commercial.",
    formations: ["BTS/HND", "IUT", "ESSEC"],
    mots_cles: ["logistique", "transit", "port", "douala", "kribi", "transport"],
    sources: ["MINESUP"],
  }),
  metier({
    slug: "assistant-direction",
    titre: "Assistant(e) de direction / Secrétaire bureautique",
    categorie: "Commerce & gestion",
    niveau: "Bac (secrétariat) + BTS/HND",
    resume:
      "Organise l'agenda, le courrier, les réunions et les dossiers d'un dirigeant ou d'un service.",
    missions: [
      "Accueil et gestion des appels",
      "Rédaction et classement",
      "Organisation des réunions et déplacements",
    ],
    parcours: ["Lycée technique (secrétariat-bureautique)", "BTS/HND assistanat de direction"],
    qualites: ["Discrétion", "Organisation", "Excellente expression écrite"],
    realite:
      "Présent dans toutes les organisations ; le bilinguisme et la maîtrise de l'informatique font la différence.",
    conseil: "Sois excellent(e) en traitement de texte, tableur et en anglais.",
    formations: ["Lycées techniques", "BTS/HND"],
    mots_cles: ["secrétariat", "bureautique", "assistant", "secrétaire"],
    sources: ["OBC", "MINESUP"],
  }),
  metier({
    slug: "ressources-humaines",
    titre: "Gestionnaire des ressources humaines",
    categorie: "Commerce & gestion",
    niveau: "Licence/Master (RH, gestion, psychologie, droit)",
    resume: "Recrute, forme, gère la paie et les carrières, veille au respect du droit du travail.",
    missions: ["Recruter et intégrer", "Gérer la paie et les contrats", "Organiser la formation"],
    parcours: ["Licence/Master en gestion des RH, psychologie du travail ou droit social"],
    qualites: ["Écoute", "Discrétion", "Connaissance du Code du travail"],
    realite: "Entreprises, cabinets de recrutement, administrations, ONG.",
    conseil: "Apprends le droit du travail camerounais et un logiciel de paie.",
    formations: ["FSEG", "ESSEC", "Facultés de lettres et sciences humaines"],
    mots_cles: ["rh", "recrutement", "paie", "personnel"],
    sources: ["MINESUP"],
  }),
  // ------------------------------------------- Agriculture
  metier({
    slug: "agronome",
    titre: "Ingénieur agronome / Technicien d'agriculture",
    categorie: "Agriculture & environnement",
    niveau: "Bac C ou D + FASA ou écoles d'agriculture",
    resume:
      "Améliore les productions agricoles, conseille les producteurs et gère des exploitations ou des projets.",
    missions: [
      "Conseil technique aux producteurs",
      "Gestion d'exploitations et de projets",
      "Recherche et amélioration des cultures",
    ],
    parcours: [
      "FASA (Université de Dschang) sur concours",
      "Écoles d'agriculture du MINADER",
      "BTS/HND agriculture",
    ],
    qualites: ["Goût du terrain", "Esprit pratique", "Pédagogie avec les producteurs"],
    realite:
      "L'agriculture emploie une très grande partie des actifs ; cacao, café, banane, maïs, manioc et maraîchage offrent de nombreuses opportunités.",
    conseil: "Pense agrobusiness : production, transformation et vente.",
    formations: ["FASA", "Écoles MINADER", "BTS/HND"],
    mots_cles: ["agriculture", "agronomie", "cacao", "café", "exploitation", "fasa"],
    sources: ["MINADER", "UNIV_DSCHANG", "MINESUP"],
  }),
  metier({
    slug: "agro-entrepreneur",
    titre: "Agro-entrepreneur (aviculture, pisciculture, maraîchage)",
    categorie: "Agriculture & environnement",
    niveau: "Tous niveaux (formation agricole conseillée)",
    resume:
      "Crée une exploitation rentable : poulets, poissons, porcs, légumes, et souvent leur transformation.",
    missions: [
      "Produire (élevage, cultures)",
      "Gérer la santé des animaux et des plantes",
      "Vendre et transformer",
    ],
    parcours: [
      "Formations agricoles courtes (centres agréés, programmes publics)",
      "BTS/HND ou formation d'ingénieur pour aller plus loin",
    ],
    qualites: ["Patience", "Rigueur", "Esprit d'entreprise"],
    realite:
      "La demande alimentaire des villes est forte ; les risques (maladies, prix des intrants) se gèrent par la formation et la comptabilité.",
    conseil: "Commence par une petite unité, maîtrise-la, puis agrandis-toi.",
    formations: ["Centres MINADER / MINEPIA", "Formation professionnelle"],
    mots_cles: ["aviculture", "pisciculture", "élevage", "maraîchage", "poulets", "agrobusiness"],
    sources: ["MINADER", "MINEPIA", "FNE"],
  }),
  metier({
    slug: "ingenieur-agroalimentaire",
    titre: "Ingénieur / Technicien agroalimentaire",
    categorie: "Agriculture & environnement",
    niveau: "Bac C ou D + ENSAI, IUT ou BTS/HND",
    resume:
      "Transforme les produits agricoles (jus, farines, huiles, chocolat…) en garantissant qualité et sécurité.",
    missions: [
      "Concevoir et améliorer les procédés",
      "Contrôler la qualité et l'hygiène",
      "Gérer la production",
    ],
    parcours: ["ENSAI (Ngaoundéré) sur concours", "IUT (génie biologique), BTS/HND"],
    qualites: ["Rigueur scientifique", "Sens de l'hygiène", "Esprit d'innovation"],
    realite:
      "Transformer localement réduit les pertes et crée de la valeur : brasseries, huileries, chocolateries, PME de transformation.",
    conseil:
      "Les petites unités de transformation (fruits, manioc, soja) sont accessibles aux jeunes entrepreneurs formés.",
    formations: ["ENSAI", "IUT", "BTS/HND"],
    mots_cles: ["agroalimentaire", "transformation", "ensai", "qualité", "industrie alimentaire"],
    sources: ["UNIV_NGAOUNDERE", "MINESUP"],
  }),
  metier({
    slug: "ingenieur-forestier-environnement",
    titre: "Ingénieur forestier / Spécialiste de l'environnement",
    categorie: "Agriculture & environnement",
    niveau: "Bac C ou D + formation forestière ou master en environnement",
    resume:
      "Protège et gère durablement les forêts, la faune et l'environnement ; lutte contre le changement climatique.",
    missions: [
      "Inventaires et aménagement forestier",
      "Protection de la faune et des aires protégées",
      "Études d'impact environnemental",
    ],
    parcours: [
      "FASA (foresterie)",
      "Écoles de faune et des eaux et forêts",
      "Masters en environnement",
    ],
    qualites: ["Amour de la nature", "Endurance", "Sens de la négociation avec les communautés"],
    realite:
      "Le Cameroun possède une partie importante du massif forestier du Bassin du Congo : enjeux de conservation et d'exploitation durable.",
    conseil: "Associe terrain et outils numériques (SIG, télédétection).",
    formations: ["FASA", "Écoles des eaux et forêts"],
    mots_cles: ["forêt", "environnement", "climat", "faune", "écologie"],
    sources: ["UNIV_DSCHANG", "MINESUP"],
  }),
  // ------------------------------------------- Communication, arts
  metier({
    slug: "journaliste",
    titre: "Journaliste",
    categorie: "Communication & arts",
    niveau: "Bac + ESSTIC (concours) ou formations en journalisme",
    resume:
      "Recherche, vérifie et diffuse l'information à la radio, à la télévision, dans la presse et sur le web.",
    missions: [
      "Enquêter et vérifier les faits",
      "Rédiger, présenter, réaliser des reportages",
      "Respecter l'éthique et la déontologie",
    ],
    parcours: [
      "ESSTIC (Université de Yaoundé II) sur concours",
      "Licences de communication / journalisme",
    ],
    qualites: ["Curiosité", "Excellente expression", "Honnêteté"],
    realite:
      "Médias publics et privés, radios communautaires, web ; la lutte contre les fausses informations est un enjeu majeur.",
    conseil: "Écris et produis dès maintenant (journal scolaire, podcast, blog).",
    formations: ["ESSTIC"],
    mots_cles: ["journalisme", "médias", "radio", "télévision", "presse"],
    sources: ["UNIV_YAOUNDE2", "MINESUP"],
  }),
  metier({
    slug: "community-manager",
    titre: "Community manager / Chargé de communication digitale",
    categorie: "Communication & arts",
    niveau: "Bac + formation en communication ou marketing digital",
    resume: "Anime les réseaux sociaux d'une marque, crée du contenu et suit les performances.",
    missions: [
      "Créer des publications et vidéos",
      "Répondre à la communauté",
      "Analyser les statistiques",
    ],
    parcours: ["ESSTIC, BTS/HND communication, formations en marketing digital"],
    qualites: ["Créativité", "Réactivité", "Bonne orthographe"],
    realite:
      "Les entreprises camerounaises investissent sur les réseaux sociaux ; beaucoup de missions en freelance.",
    conseil: "Gère une page avec de vrais résultats : c'est ton meilleur CV.",
    formations: ["ESSTIC", "BTS/HND"],
    mots_cles: ["réseaux sociaux", "digital", "marketing", "communication", "facebook", "tiktok"],
    sources: ["MINESUP"],
  }),
  metier({
    slug: "graphiste",
    titre: "Graphiste / Designer",
    categorie: "Communication & arts",
    niveau: "Bac + formation en arts graphiques ou design",
    resume: "Crée logos, affiches, emballages, interfaces d'applications et identités visuelles.",
    missions: [
      "Concevoir des visuels",
      "Travailler avec les clients",
      "Maîtriser les logiciels de création",
    ],
    parcours: [
      "Institut des Beaux-Arts de Foumban, écoles de design",
      "Formations courtes et autoformation",
    ],
    qualites: ["Créativité", "Sens esthétique", "Écoute du client"],
    realite:
      "Agences, imprimeries, entreprises et freelance ; un portfolio solide est indispensable.",
    conseil:
      "Constitue un portfolio en ligne et apprends aussi le design d'interfaces (applications, sites).",
    formations: ["Institut des Beaux-Arts de Foumban", "Écoles de design"],
    mots_cles: ["design", "graphisme", "infographie", "logo", "création"],
    sources: ["UNIV_DSCHANG"],
  }),
  metier({
    slug: "traducteur",
    titre: "Traducteur / Interprète",
    categorie: "Communication & arts",
    niveau: "Licence + ASTI (concours) ou formation en traduction",
    resume:
      "Traduit des documents et interprète des échanges entre langues, en premier lieu entre le français et l'anglais.",
    missions: [
      "Traduire des textes administratifs, juridiques, techniques",
      "Interpréter en réunion ou conférence",
      "Relire et harmoniser la terminologie",
    ],
    parcours: [
      "ASTI (University of Buea) sur concours",
      "Licences et masters en langues et traduction",
    ],
    qualites: ["Maîtrise parfaite de deux langues", "Rigueur", "Culture générale"],
    realite:
      "Le bilinguisme officiel crée une demande forte dans l'administration, les entreprises et les organisations internationales.",
    conseil: "Lis chaque jour en français et en anglais, et apprends une troisième langue.",
    formations: ["ASTI", "Facultés de lettres"],
    mots_cles: ["traduction", "interprète", "bilinguisme", "anglais", "langues"],
    sources: ["UNIV_BUEA", "MINESUP"],
  }),
  metier({
    slug: "artiste-musicien",
    titre: "Artiste musicien / Producteur",
    categorie: "Communication & arts",
    niveau: "Tous niveaux (formation musicale conseillée)",
    resume:
      "Compose, interprète, enregistre et produit de la musique ; vit de la scène, du streaming et des droits.",
    missions: [
      "Créer et interpréter",
      "Enregistrer et produire",
      "Promouvoir et gérer sa carrière",
    ],
    parcours: [
      "Institut des Beaux-Arts de Foumban (musique), conservatoires et écoles privées",
      "Apprentissage auprès de professionnels",
    ],
    qualites: ["Talent et travail", "Persévérance", "Sens des affaires"],
    realite:
      "La scène musicale camerounaise est riche (makossa, bikutsi, urban) ; peu en vivent sans gestion professionnelle de leurs droits.",
    conseil:
      "Déclare tes œuvres auprès de l'organisme de gestion des droits d'auteur et apprends le marketing musical.",
    formations: ["Institut des Beaux-Arts de Foumban"],
    mots_cles: ["musique", "artiste", "chanteur", "production", "makossa", "bikutsi"],
    sources: ["UNIV_DSCHANG"],
  }),
  // ------------------------------------------- Défense, sécurité
  metier({
    slug: "officier-armee",
    titre: "Officier des forces armées",
    categorie: "Défense & sécurité",
    niveau: "Baccalauréat ou Licence + concours EMIA",
    resume:
      "Commande des unités militaires, assure la défense du territoire et participe à des missions de paix.",
    missions: [
      "Commander et former des soldats",
      "Planifier des opérations",
      "Servir dans l'armée de terre, l'air ou la marine",
    ],
    parcours: [
      "Concours de l'École Militaire Interarmées (EMIA) après le Bac ou la licence",
      "Formation militaire et académique",
    ],
    qualites: ["Aptitude physique", "Discipline", "Sens du commandement"],
    realite:
      "Carrière exigeante avec des affectations partout au Cameroun ; les recrutements sont annoncés par communiqué officiel du MINDEF.",
    conseil: "Entraîne-toi physiquement et ne paie jamais un intermédiaire pour un recrutement.",
    formations: ["EMIA"],
    mots_cles: ["armée", "militaire", "emia", "officier", "défense"],
    sources: ["MINDEF"],
  }),
  metier({
    slug: "policier",
    titre: "Policier (gardien de la paix, inspecteur, officier, commissaire)",
    categorie: "Défense & sécurité",
    niveau: "BEPC à Licence selon le grade + concours DGSN",
    resume:
      "Assure la sécurité des personnes et des biens, la circulation, les enquêtes et le maintien de l'ordre.",
    missions: [
      "Patrouilles et sécurité publique",
      "Enquêtes judiciaires",
      "Contrôles (circulation, frontières)",
    ],
    parcours: [
      "Concours de la Sûreté Nationale (DGSN) selon le diplôme",
      "Formation dans les écoles de police",
    ],
    qualites: ["Intégrité", "Sang-froid", "Condition physique"],
    realite:
      "Les concours attirent énormément de candidats ; seuls les communiqués officiels de la DGSN font foi.",
    conseil:
      "Prépare l'épreuve sportive autant que l'écrit, et méfie-toi des arnaques au recrutement.",
    formations: ["École Nationale Supérieure de Police", "Écoles de police"],
    mots_cles: ["police", "dgsn", "commissaire", "inspecteur de police", "gardien de la paix"],
    sources: ["DGSN"],
  }),
  // ------------------------------------------- Artisanat, services
  metier({
    slug: "couturier-styliste",
    titre: "Couturier / Styliste-modéliste",
    categorie: "Artisanat & services",
    niveau: "Tous niveaux (centres de formation professionnelle)",
    resume: "Conçoit et confectionne des vêtements sur mesure ou en série, du pagne au costume.",
    missions: [
      "Prendre les mesures et conseiller",
      "Couper, assembler, finir",
      "Créer des collections",
    ],
    parcours: [
      "Centres de formation professionnelle agréés (couture, stylisme)",
      "SAR/SM",
      "Apprentissage dans un atelier",
    ],
    qualites: ["Précision", "Créativité", "Respect des délais"],
    realite:
      "Forte demande pour les tenues de cérémonie et le pagne ; la mode africaine s'exporte.",
    conseil: "Montre tes créations sur les réseaux sociaux et soigne les finitions.",
    formations: ["Centres MINEFOP", "SAR/SM"],
    mots_cles: ["couture", "mode", "stylisme", "pagne", "atelier"],
    sources: ["MINEFOP"],
  }),
  metier({
    slug: "coiffeur-estheticien",
    titre: "Coiffeur / Esthéticien",
    categorie: "Artisanat & services",
    niveau: "Tous niveaux (formation professionnelle)",
    resume: "Coiffe, tresse, soigne et met en beauté ; gère souvent son propre salon.",
    missions: ["Coupes, tresses, tissages, soins", "Conseil beauté", "Gestion du salon"],
    parcours: ["Centres de formation professionnelle agréés", "Apprentissage en salon"],
    qualites: ["Habileté", "Sens du contact", "Hygiène"],
    realite:
      "Métier très répandu, idéal pour l'auto-emploi ; la qualité de l'accueil fidélise la clientèle.",
    conseil: "Forme-toi aux techniques nouvelles et tiens tes comptes.",
    formations: ["Centres MINEFOP"],
    mots_cles: ["coiffure", "esthétique", "beauté", "salon", "tresses"],
    sources: ["MINEFOP"],
  }),
  metier({
    slug: "menuisier",
    titre: "Menuisier / Ébéniste",
    categorie: "Artisanat & services",
    niveau: "CAP ou formation professionnelle",
    resume: "Fabrique et pose meubles, portes, fenêtres et charpentes en bois.",
    missions: [
      "Lire un plan, débiter et assembler",
      "Finir et poser",
      "Conseiller le client sur les essences de bois",
    ],
    parcours: [
      "Lycée technique (menuiserie)",
      "Centres de formation professionnelle",
      "Apprentissage",
    ],
    qualites: ["Habileté manuelle", "Précision", "Sens esthétique"],
    realite: "Le bois local est une richesse ; beaucoup d'artisans s'installent à leur compte.",
    conseil: "Apprends le dessin assisté par ordinateur pour proposer des modèles modernes.",
    formations: ["Lycées techniques", "Centres MINEFOP"],
    mots_cles: ["menuiserie", "bois", "meubles", "ébénisterie"],
    sources: ["MINEFOP", "OBC"],
  }),
  metier({
    slug: "plombier",
    titre: "Plombier / Installateur sanitaire",
    categorie: "Artisanat & services",
    niveau: "CAP ou formation professionnelle",
    resume: "Installe et répare les canalisations, les sanitaires, les pompes et les citernes.",
    missions: [
      "Installer les réseaux d'eau",
      "Réparer les fuites",
      "Installer pompes et chauffe-eau",
    ],
    parcours: ["Lycée technique / centres de formation professionnelle", "Apprentissage"],
    qualites: ["Sens pratique", "Rigueur", "Disponibilité"],
    realite: "La construction et les besoins en eau assurent une demande régulière.",
    conseil: "Ajoute le solaire thermique et les pompes solaires à tes compétences.",
    formations: ["Centres MINEFOP"],
    mots_cles: ["plomberie", "sanitaire", "eau", "canalisations"],
    sources: ["MINEFOP"],
  }),
  metier({
    slug: "reparateur-telephones",
    titre: "Technicien en réparation de téléphones et d'ordinateurs",
    categorie: "Artisanat & services",
    niveau: "Tous niveaux (formation technique conseillée)",
    resume: "Diagnostique et répare smartphones, ordinateurs et petits appareils électroniques.",
    missions: [
      "Diagnostic des pannes",
      "Remplacement de pièces, soudure",
      "Installation de logiciels",
    ],
    parcours: [
      "Lycée technique (électronique F2)",
      "Centres de formation professionnelle",
      "Apprentissage",
    ],
    qualites: ["Minutie", "Patience", "Honnêteté"],
    realite:
      "Très forte demande dans toutes les villes ; activité accessible avec peu d'investissement.",
    conseil: "Sois transparent sur les pièces et les prix : la confiance fait revenir les clients.",
    formations: ["Lycées techniques (F2)", "Centres MINEFOP"],
    mots_cles: ["téléphone", "réparation", "électronique", "smartphone", "ordinateur"],
    sources: ["MINEFOP", "OBC"],
  }),
  metier({
    slug: "cuisinier-hotellerie",
    titre: "Cuisinier / Professionnel de l'hôtellerie et de la restauration",
    categorie: "Tourisme & hôtellerie",
    niveau: "Tous niveaux (formation hôtelière conseillée)",
    resume:
      "Prépare les repas, gère la cuisine, l'accueil ou l'hébergement dans les restaurants et hôtels.",
    missions: [
      "Préparer les plats (cuisine camerounaise et internationale)",
      "Respecter l'hygiène",
      "Accueillir et servir",
    ],
    parcours: [
      "Écoles hôtelières, BTS/HND hôtellerie-tourisme",
      "Centres de formation professionnelle",
    ],
    qualites: ["Créativité", "Endurance", "Hygiène irréprochable"],
    realite:
      "Restaurants, hôtels, traiteurs et événements ; la cuisine camerounaise a un grand potentiel commercial.",
    conseil: "Le service traiteur pour les cérémonies est un bon démarrage en auto-emploi.",
    formations: ["Écoles hôtelières", "BTS/HND"],
    mots_cles: ["cuisine", "restaurant", "hôtel", "traiteur", "hôtellerie"],
    sources: ["MINEFOP", "MINESUP"],
  }),
  metier({
    slug: "guide-tourisme",
    titre: "Guide touristique / Agent de tourisme",
    categorie: "Tourisme & hôtellerie",
    niveau: "Baccalauréat + BTS/HND tourisme ou licence",
    resume:
      "Fait découvrir le Cameroun, « l'Afrique en miniature » : sites naturels, culturels et historiques.",
    missions: [
      "Organiser des circuits",
      "Accueillir et guider",
      "Présenter l'histoire et les cultures",
    ],
    parcours: ["BTS/HND tourisme", "Licences en tourisme, histoire, géographie, langues"],
    qualites: ["Excellente expression", "Culture générale", "Plusieurs langues"],
    realite:
      "Le pays offre mer, montagnes, savanes, forêts et chefferies ; le tourisme intérieur se développe.",
    conseil:
      "Les langues étrangères et la connaissance des cultures locales sont tes meilleurs atouts.",
    formations: ["BTS/HND", "Facultés de lettres"],
    mots_cles: ["tourisme", "guide", "voyage", "patrimoine"],
    sources: ["MINESUP"],
  }),
  metier({
    slug: "pilote-aviation",
    titre: "Pilote / Technicien de l'aviation",
    categorie: "Transport",
    niveau: "Bac C ou E (pilotes) / Bac technique (maintenance)",
    resume: "Pilote des avions ou en assure la maintenance, la sécurité et le contrôle du trafic.",
    missions: [
      "Piloter en sécurité",
      "Entretenir les aéronefs",
      "Contrôler la navigation aérienne",
    ],
    parcours: [
      "Écoles de pilotage et d'aviation (souvent à l'étranger ou régionales)",
      "Écoles de la navigation aérienne sur concours",
    ],
    qualites: ["Excellent niveau en maths et physique", "Aptitude médicale", "Anglais courant"],
    realite:
      "Formations longues et coûteuses ; les bourses et concours régionaux sont à surveiller.",
    conseil: "Travaille l'anglais : c'est la langue de l'aviation.",
    formations: ["Écoles d'aviation"],
    mots_cles: ["pilote", "avion", "aviation", "aéroport", "aéronautique"],
    sources: ["MINESUP"],
  }),
  metier({
    slug: "chercheur",
    titre: "Enseignant-chercheur / Chercheur",
    categorie: "Enseignement",
    niveau: "Doctorat",
    resume:
      "Fait avancer la connaissance (santé, agriculture, technologies…) et enseigne à l'université.",
    missions: [
      "Mener des recherches",
      "Publier et participer aux colloques",
      "Enseigner et encadrer des étudiants",
    ],
    parcours: [
      "Licence, master puis doctorat",
      "Recrutement dans les universités ou instituts de recherche",
    ],
    qualites: ["Curiosité", "Persévérance", "Rigueur scientifique"],
    realite:
      "Les universités d'État recrutent régulièrement des enseignants-chercheurs, notamment dans les nouvelles universités.",
    conseil: "Obtiens d'excellents résultats en master et maîtrise l'anglais scientifique.",
    formations: ["Universités d'État"],
    mots_cles: ["recherche", "doctorat", "université", "professeur d'université"],
    sources: ["MINESUP", "LOI_SUP_2023"],
  }),
];
