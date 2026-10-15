// Fiches « Filières » (réalité camerounaise). Les dates, frais et nombres de
// places changent chaque année : les fiches renvoient toujours au communiqué
// officiel plutôt que de donner des chiffres qui deviendraient faux.

const VERIFIER =
  "Les conditions exactes (diplômes admis, âge, frais, dates, nombre de places) changent chaque année : vérifie toujours le communiqué officiel du concours.";

export const FILIERES = [
  // ---------------------------------------------------------------------------
  // Secondaire général (sous-système francophone)
  // ---------------------------------------------------------------------------
  {
    slug: "systeme-educatif-camerounais",
    titre: "Le système éducatif camerounais en un coup d'œil",
    categorie: "Repères",
    niveau_acces: "Tous niveaux",
    resume:
      "Deux sous-systèmes (francophone et anglophone), un enseignement général et un enseignement technique, puis l'enseignement supérieur (système LMD) et la formation professionnelle.",
    contenu: `## Deux sous-systèmes
Le Cameroun a un sous-système **francophone** et un sous-système **anglophone**, organisés par la loi d'orientation de l'éducation de 1998.
- **Francophone** : premier cycle (6e à 3e, BEPC ou CAP au technique), puis second cycle (2nde à Terminale, Probatoire puis Baccalauréat).
- **Anglophone** : Form 1 à Form 5 (GCE Ordinary Level), puis Lower Sixth et Upper Sixth (GCE Advanced Level).

## Qui organise les examens ?
- Le **MINESEC** pour le BEPC, le CAP et le Probatoire.
- L'**Office du Baccalauréat du Cameroun (OBC)** pour le Baccalauréat, le Brevet de technicien (BT) et d'autres brevets.
- Le **GCE Board** pour le GCE O Level et le A Level.

## Après le secondaire
- **Universités d'État** : 11 depuis 2022, avec la création de Bertoua, Ebolowa et Garoua. Leurs facultés suivent le système **LMD** : Licence en 3 ans, Master en 2 ans, Doctorat.
- **Grandes écoles** recrutant sur concours : écoles d'ingénieurs, ENS, ENAM, écoles de santé, etc.
- **Instituts privés d'enseignement supérieur (IPES)** : BTS et HND en 2 ans, avec un examen national organisé par le MINESUP.
- **Formation professionnelle** sous la tutelle du MINEFOP, pour apprendre un métier rapidement.`,
    debouches: [],
    formations: [
      "BEPC / CAP",
      "Probatoire",
      "Baccalauréat / BT",
      "GCE O Level / A Level",
      "Licence, Master, Doctorat",
      "BTS / HND",
    ],
    mots_cles: [
      "système éducatif",
      "cycle",
      "francophone",
      "anglophone",
      "LMD",
      "examens officiels",
      "orientation",
    ],
    sources: [
      "LOI_EDUCATION_1998",
      "LOI_SUP_2023",
      "DECRET_MINESEC_2012",
      "MINESEC",
      "OBC",
      "GCEB",
      "MINESUP",
    ],
  },
  {
    slug: "choisir-sa-serie-en-seconde",
    titre: "Choisir sa série après la 3e (2nde C, A, TI ou enseignement technique)",
    categorie: "Secondaire général (francophone)",
    niveau_acces: "Fin de 3e (BEPC)",
    resume:
      "Le choix de la série en 2nde engage la suite : scientifique (C, D, E, TI), littéraire (A) ou technique (industriel, commercial). Il doit partir de tes résultats, de tes goûts et du métier visé.",
    contenu: `## Les grandes familles
- **Scientifique** : 2nde C, qui mène en 1ère aux séries C, D ou E, ou à la série TI (technologies de l'information) dans les établissements qui la proposent.
- **Littéraire** : 2nde A, qui mène à la série A et à ses options de langues.
- **Technique** : lycées techniques, avec les séries industrielles (F1 à F8…) ou les séries commerciales et tertiaires.

## Comment décider
- Regarde tes **notes de 4e et 3e** en mathématiques, sciences physiques, SVT, français et langues.
- Pars du **métier visé** : médecine et agronomie demandent C ou D ; ingénierie demande C, E ou F ; le droit et le journalisme acceptent A et C.
- Les séries scientifiques ouvrent plus de portes, mais une série A choisie par goût et bien réussie vaut mieux qu'une série C subie.
- Parle au **conseiller d'orientation** de ton établissement et à tes enseignants.

## Bon à savoir
Les passerelles existent (redoublement réorienté, changement d'établissement), mais elles sont plus faciles au début du second cycle.`,
    debouches: ["Séries C, D, E, TI", "Série A", "Baccalauréat technique (F, commercial)"],
    formations: ["Lycées d'enseignement général", "Lycées techniques"],
    mots_cles: ["seconde", "2nde", "série", "choisir", "BEPC", "après la troisième", "orientation"],
    sources: ["MINESEC", "CONSEILLER"],
  },
  {
    slug: "serie-c",
    titre: "Série C (Mathématiques et Sciences physiques)",
    categorie: "Secondaire général (francophone)",
    niveau_acces: "2nde C",
    resume:
      "La série la plus orientée vers les mathématiques et la physique-chimie. Elle ouvre toutes les écoles d'ingénieurs et la plupart des filières scientifiques.",
    contenu: `## Contenu
Les **mathématiques** et les **sciences physiques** y ont les plus forts coefficients. La SVT, le français, la philosophie et les langues restent présentes.

## Pour qui ?
Pour l'élève à l'aise en calcul et en raisonnement, qui aime résoudre des problèmes.

## Ce qu'elle ouvre
- **Écoles d'ingénieurs** sur concours : Polytechnique de Yaoundé (ENSP), ENSPD Douala, ENSTP, ENSAI, IUT, etc.
- Facultés des sciences : mathématiques, physique, informatique.
- Médecine, pharmacie et agronomie : la série C y est admise comme la série D.
- Statistique (ISSEA), économie, enseignement des sciences (ENS, ENSET).

## Conseil
Travaille l'**analyse** (fonctions, suites, intégrales) et la **mécanique**, très présentes aux concours d'ingénieurs.`,
    debouches: ["Ingénieur", "Statisticien", "Médecin", "Enseignant de sciences", "Informaticien"],
    formations: ["ENSP Yaoundé", "ENSPD Douala", "ENSTP", "ISSEA", "Facultés des sciences", "FMSB"],
    mots_cles: ["bac c", "série c", "maths", "physique", "scientifique", "ingénieur"],
    sources: ["OBC", "MINESUP", "UY1"],
  },
  {
    slug: "serie-d",
    titre: "Série D (Mathématiques et Sciences de la vie et de la Terre)",
    categorie: "Secondaire général (francophone)",
    niveau_acces: "2nde C",
    resume:
      "Série scientifique où la SVT a un poids important. C'est la voie naturelle vers la médecine, la pharmacie, l'agronomie, la biologie et les métiers de la santé.",
    contenu: `## Contenu
Mathématiques, **SVT** et sciences physiques forment le cœur de la série, avec le français, la philosophie et les langues.

## Ce qu'elle ouvre
- **Médecine, pharmacie et chirurgie dentaire** sur concours : FMSB (Yaoundé I), FMSP (Douala), Faculty of Health Sciences (Buea) et autres facultés de médecine.
- **Agronomie** : FASA (Dschang), et les **agro-industries** à l'ENSAI (Ngaoundéré).
- Écoles **paramédicales** : infirmiers, sages-femmes, techniciens de laboratoire.
- Facultés des sciences (biologie, biochimie, géologie), ENS (SVT), vétérinaire.

## Conseil
Les concours de médecine sont très sélectifs. Vise un très bon niveau en **SVT, chimie et physique** et prépare-toi tôt avec les annales.`,
    debouches: ["Médecin", "Pharmacien", "Infirmier", "Agronome", "Biologiste", "Vétérinaire"],
    formations: [
      "FMSB",
      "FMSP Douala",
      "FHS Buea",
      "FASA Dschang",
      "ENSAI",
      "Écoles paramédicales",
    ],
    mots_cles: ["bac d", "série d", "svt", "médecine", "santé", "biologie", "agronomie"],
    sources: ["OBC", "MINESUP", "UY1", "UNIV_DSCHANG", "UNIV_BUEA", "UNIV_DOUALA"],
  },
  {
    slug: "serie-e",
    titre: "Série E (Mathématiques et Techniques)",
    categorie: "Secondaire général (francophone)",
    niveau_acces: "2nde C",
    resume:
      "Série scientifique tournée vers les sciences et techniques industrielles. Elle prépare très bien aux écoles d'ingénieurs et aux IUT.",
    contenu: `## Contenu
Mathématiques et sciences physiques à forts coefficients, plus des enseignements de **technologie** : construction, dessin technique, mécanique.

## Ce qu'elle ouvre
- **Écoles d'ingénieurs** : génie mécanique, génie civil, génie électrique, génie industriel.
- **IUT** et ENSET, pour devenir professeur de l'enseignement technique.
- Licences scientifiques et technologiques.

## Bon à savoir
La série E n'existe que dans certains établissements : renseigne-toi auprès de ton lycée ou de la délégation régionale du MINESEC.`,
    debouches: [
      "Ingénieur mécanicien",
      "Ingénieur génie civil",
      "Technicien supérieur",
      "Professeur de l'enseignement technique",
    ],
    formations: ["ENSP", "ENSPD", "ENSTP", "IUT", "ENSET"],
    mots_cles: ["bac e", "série e", "technique", "mécanique", "ingénieur"],
    sources: ["OBC", "MINESEC", "MINESUP"],
  },
  {
    slug: "serie-ti",
    titre: "Série TI (Technologies de l'Information)",
    categorie: "Secondaire général (francophone)",
    niveau_acces: "2nde C ou 2nde TI selon l'établissement",
    resume:
      "Série scientifique centrée sur l'informatique : algorithmique, programmation et réseaux, avec des mathématiques solides. Elle prépare aux études d'informatique et du numérique.",
    contenu: `## Contenu
Mathématiques, **informatique** (algorithmique, programmation, bases de données, réseaux) et sciences physiques.

## Ce qu'elle ouvre
- Licences et écoles d'**informatique** et de **génie logiciel**.
- IUT (génie informatique, réseaux et télécoms), BTS/HND en informatique.
- Concours d'ingénieurs qui l'admettent : vérifie la liste des diplômes acceptés dans chaque communiqué.

## Conseil
Programme en dehors des cours : petits projets, sites web, applications. Les entreprises du numérique regardent ce que tu sais **faire**.`,
    debouches: [
      "Développeur",
      "Administrateur réseaux",
      "Analyste de données",
      "Technicien informatique",
    ],
    formations: [
      "Facultés des sciences (informatique)",
      "IUT",
      "ENSP (génie informatique)",
      "BTS/HND informatique",
    ],
    mots_cles: [
      "bac ti",
      "série ti",
      "informatique",
      "programmation",
      "numérique",
      "technologies de l'information",
    ],
    sources: ["OBC", "MINESEC", "MINESUP"],
  },
  {
    slug: "serie-a",
    titre: "Série A (Lettres, Langues et Philosophie)",
    categorie: "Secondaire général (francophone)",
    niveau_acces: "2nde A",
    resume:
      "Série littéraire : français, philosophie, histoire-géographie et langues vivantes. Elle mène au droit, au journalisme, aux langues, à l'enseignement et à l'administration.",
    contenu: `## Contenu
Le **français**, la **philosophie**, l'histoire-géographie et les **langues** (anglais et une autre langue selon l'option) dominent, avec des mathématiques.

## Ce qu'elle ouvre
- **Droit** et science politique, **lettres**, langues, histoire, géographie, sociologie.
- **Journalisme et communication** (ESSTIC, sur concours).
- **Enseignement** (ENS, filières littéraires), **traduction et interprétation**.
- Administration, après une licence (ENAM cycle A, IRIC pour la diplomatie).

## Conseil
Au Cameroun, pays bilingue, **une très bonne maîtrise de l'anglais** est un vrai atout. Lis beaucoup et entraîne-toi à la dissertation.`,
    debouches: [
      "Avocat",
      "Journaliste",
      "Enseignant de lettres",
      "Traducteur",
      "Diplomate",
      "Administrateur civil",
    ],
    formations: ["Facultés de droit", "Facultés des lettres", "ESSTIC", "ENS", "ENAM", "IRIC"],
    mots_cles: ["bac a", "série a", "littéraire", "lettres", "philosophie", "langues", "droit"],
    sources: ["OBC", "MINESUP", "UNIV_YAOUNDE2", "ENAM"],
  },
  // ---------------------------------------------------------------------------
  // Secondaire technique
  // ---------------------------------------------------------------------------
  {
    slug: "enseignement-technique-industriel",
    titre: "Enseignement technique industriel (séries F)",
    categorie: "Secondaire technique",
    niveau_acces: "CAP ou 2nde technique",
    resume:
      "Les lycées techniques préparent aux métiers de l'industrie : fabrication mécanique (F1), électronique (F2), électrotechnique (F3), génie civil (F4), froid et climatisation (F5), génie chimique (F6), sciences biologiques et médico-sanitaires (F7), santé et social (F8).",
    contenu: `## Les spécialités les plus courantes
- **F1** : fabrication mécanique.
- **F2** : électronique.
- **F3** : électrotechnique.
- **F4** : génie civil, avec les options bâtiment, travaux publics et bureau d'études.
- **F5** : froid et climatisation.
- **F6** : génie chimique.
- **F7** : sciences biologiques.
- **F8** : sciences médico-sociales.

## Les diplômes
- **CAP** à la fin du premier cycle technique.
- **Probatoire** et **Baccalauréat de technicien**, ou **Brevet de technicien (BT)**, au second cycle.

## Ce qu'elle ouvre
- Un **emploi qualifié rapide** : technicien, chef de chantier, électricien, frigoriste.
- **IUT**, **BTS/HND**, ENSET, certaines **écoles d'ingénieurs** sur concours, et l'**auto-emploi**, très recherché au Cameroun.

## Conseil
Les stages en entreprise comptent beaucoup : profite de chaque période de stage pour te faire connaître.`,
    debouches: [
      "Technicien BTP",
      "Électricien",
      "Électronicien",
      "Frigoriste",
      "Mécanicien",
      "Chef de chantier",
    ],
    formations: ["Lycées techniques", "IUT", "ENSET", "BTS/HND", "ENSTP"],
    mots_cles: [
      "technique",
      "série f",
      "f1",
      "f2",
      "f3",
      "f4",
      "f5",
      "génie civil",
      "électrotechnique",
      "cap",
      "bt",
    ],
    sources: ["OBC", "MINESEC"],
  },
  {
    slug: "enseignement-technique-commercial",
    titre: "Enseignement technique commercial et tertiaire",
    categorie: "Secondaire technique",
    niveau_acces: "CAP ou 2nde technique commerciale",
    resume:
      "Les séries commerciales et tertiaires forment à la comptabilité et à la gestion, au commerce et à la vente, au secrétariat et à la bureautique.",
    contenu: `## Les spécialités
- **Comptabilité et gestion**.
- **Action commerciale et vente**.
- **Secrétariat et bureautique**.
- Selon les établissements : banque, assurance, transport-logistique.

Les appellations historiques sont G1, G2 et G3. Les intitulés évoluent avec les réformes : vérifie-les auprès de ton lycée ou du MINESEC.

## Ce qu'elle ouvre
- Un **emploi** dans les PME, les commerces, les banques et les administrations.
- **BTS/HND** (comptabilité, banque, marketing, logistique), **ESSEC**, IUT, facultés de sciences économiques et de gestion.
- La **création d'entreprise** : les bases de gestion sont un atout réel.

## Conseil
Maîtrise un **logiciel de comptabilité** et le **tableur** : c'est ce que demandent d'abord les employeurs.`,
    debouches: [
      "Comptable",
      "Commercial",
      "Assistant de direction",
      "Agent de banque",
      "Gestionnaire de stock",
    ],
    formations: ["Lycées techniques commerciaux", "BTS/HND", "ESSEC Douala", "IUT", "FSEG"],
    mots_cles: [
      "commercial",
      "comptabilité",
      "gestion",
      "secrétariat",
      "série g",
      "g1",
      "g2",
      "g3",
      "tertiaire",
    ],
    sources: ["OBC", "MINESEC"],
  },
  // ---------------------------------------------------------------------------
  // Sous-système anglophone
  // ---------------------------------------------------------------------------
  {
    slug: "gce-o-level",
    titre: "GCE Ordinary Level (O Level)",
    categorie: "Sous-système anglophone",
    niveau_acces: "Form 5",
    resume:
      "Examen de fin de Form 5 organisé par le Cameroon GCE Board. Le nombre et le choix des matières réussies conditionnent l'entrée en Lower Sixth.",
    contenu: `## Principe
L'élève compose plusieurs **subjects** : English language, mathematics, sciences, humanities, commercial or technical subjects. Chaque matière réussie compte.

## Pourquoi c'est important
- L'entrée en **Lower Sixth**, dans la bonne combinaison (sciences, arts, commercial), dépend des matières réussies et de leurs notes.
- De nombreux concours et formations demandent un **minimum de matières réussies**, souvent avec l'anglais et les mathématiques.

## Conseil
Choisis tes subjects en pensant à ta future combinaison au A Level : pour la médecine, il faut biology, chemistry et physics.`,
    debouches: ["GCE A Level", "Technical / commercial training", "Professional schools"],
    formations: ["Secondary and high schools (anglophone subsystem)"],
    mots_cles: ["gce", "o level", "ordinary level", "form 5", "anglophone", "subjects"],
    sources: ["GCEB", "MINESEC"],
  },
  {
    slug: "gce-a-level",
    titre: "GCE Advanced Level (A Level)",
    categorie: "Sous-système anglophone",
    niveau_acces: "Upper Sixth",
    resume:
      "Examen de fin de Upper Sixth, équivalent du Baccalauréat. La combinaison de matières (science, arts, commercial) détermine les études possibles.",
    contenu: `## Combinaisons fréquentes
- **Sciences** : mathematics, physics, chemistry ou biology. Elles mènent à l'ingénierie, à la médecine, à l'agronomie et à l'informatique.
- **Arts** : literature, history, geography, languages, economics. Elles mènent au droit, au journalisme et aux langues.
- **Commercial** : accounting, economics, business mathematics. Elles mènent à la gestion, à la banque et à la comptabilité.

## Ce qu'il ouvre
Les universités d'État comme Buea et Bamenda, et toutes les grandes écoles bilingues. Les concours publient des versions françaises et anglaises, avec des conditions précises en nombre de papers et de points.

## Conseil
Vérifie dans chaque communiqué de concours le **nombre de papers** et les **subjects exigés**.`,
    debouches: ["Engineering", "Medicine", "Law", "Business", "Teaching"],
    formations: ["University of Buea", "University of Bamenda", "Grandes écoles (bilingual)"],
    mots_cles: [
      "gce",
      "a level",
      "advanced level",
      "upper sixth",
      "anglophone",
      "combination",
      "papers",
    ],
    sources: ["GCEB", "MINESUP", "UNIV_BUEA", "UNIV_BAMENDA"],
  },
  // ---------------------------------------------------------------------------
  // Enseignement supérieur : universités
  // ---------------------------------------------------------------------------
  {
    slug: "universites-etat-lmd",
    titre: "Universités d'État et système LMD",
    categorie: "Enseignement supérieur",
    niveau_acces: "Baccalauréat ou GCE A Level",
    resume:
      "Le Cameroun compte 11 universités d'État. Leurs facultés accueillent les bacheliers sur dossier ; leurs grandes écoles recrutent sur concours. Diplômes : Licence (3 ans), Master (2 ans), Doctorat.",
    contenu: `## Les universités d'État
Yaoundé I, Yaoundé II (Soa), Douala, Dschang, Buea, Ngaoundéré, Maroua et Bamenda, auxquelles s'ajoutent depuis 2022 **Bertoua, Ebolowa et Garoua**.

## Facultés et grandes écoles
- **Facultés** (sciences, lettres, droit, économie…) : inscription généralement sur étude de dossier après le Bac ou le A Level.
- **Grandes écoles et instituts** des universités (ENSP, ENS, FMSB, ESSTIC, IUT…) : **concours**, souvent très sélectifs.

## Le système LMD
- **Licence** en 3 ans, **Master** en 2 ans, **Doctorat** en 3 ans environ.
- Les enseignements sont organisés en **unités d'enseignement (UE)** capitalisables, comptées en **crédits**.

## Conseil
Consulte le **site du MINESUP** et ceux des universités pour les calendriers d'inscription et la liste des concours.`,
    debouches: [],
    formations: ["Licence", "Master", "Doctorat"],
    mots_cles: ["université", "faculté", "lmd", "licence", "master", "doctorat", "inscription"],
    sources: ["MINESUP", "LOI_SUP_2023", "UY1"],
  },
  {
    slug: "faculte-des-sciences",
    titre:
      "Faculté des sciences (mathématiques, physique, chimie, biologie, informatique, géologie)",
    categorie: "Enseignement supérieur",
    niveau_acces: "Bac C, D, E, TI ou A Level sciences",
    resume:
      "Licences et masters scientifiques dans toutes les universités d'État. Une voie solide vers l'enseignement, la recherche, l'informatique, les mines et l'environnement, et une passerelle vers les concours après la licence.",
    contenu: `## Parcours
Licences en **mathématiques, physique, chimie, biologie, biochimie, informatique, sciences de la Terre (géologie)**, puis masters professionnels ou de recherche.

## Débouchés au Cameroun
- **Enseignement**, via le concours de l'ENS après la licence.
- **Informatique** et numérique.
- **Mines, pétrole et environnement** pour les géosciences.
- **Laboratoires** : santé, agroalimentaire, contrôle qualité.
- **Recherche**, avec le doctorat.

## Conseil
La licence ouvre aussi des **concours de niveau Licence** : ENS deuxième cycle, ENAM cycle A, ISSEA, certaines écoles d'ingénieurs en admission parallèle.`,
    debouches: [
      "Enseignant",
      "Chercheur",
      "Géologue",
      "Informaticien",
      "Technicien de laboratoire",
    ],
    formations: ["Facultés des sciences des universités d'État"],
    mots_cles: [
      "faculté des sciences",
      "licence",
      "maths",
      "physique",
      "chimie",
      "biologie",
      "informatique",
      "géologie",
    ],
    sources: ["MINESUP", "UY1"],
  },
  {
    slug: "droit-science-politique",
    titre: "Droit et science politique",
    categorie: "Enseignement supérieur",
    niveau_acces: "Baccalauréat (toutes séries) ou A Level",
    resume:
      "Licences en droit privé, droit public, science politique, en français ou en anglais (common law). Elles mènent au barreau, à la magistrature (ENAM), à l'administration, aux banques et aux entreprises.",
    contenu: `## Parcours
Licence puis master en **droit privé, droit public, droit des affaires, science politique**. Le **bijuridisme**, entre droit civil et common law, est une particularité camerounaise.

## Débouchés
- **Avocat**, après le master et l'accès au barreau.
- **Magistrat**, par le concours de l'ENAM, section magistrature.
- **Huissier, notaire**, juriste d'entreprise, administrateur, diplomate (IRIC), forces de l'ordre (officiers de police).

## Conseil
Lis beaucoup, entraîne-toi à l'écrit et à l'oral, et apprends le **vocabulaire juridique dans les deux langues officielles**.`,
    debouches: ["Avocat", "Magistrat", "Juriste d'entreprise", "Huissier", "Notaire", "Diplomate"],
    formations: [
      "Facultés de sciences juridiques et politiques (Yaoundé II, Douala, Dschang, Buea…)",
      "ENAM",
      "IRIC",
    ],
    mots_cles: [
      "droit",
      "juriste",
      "avocat",
      "magistrat",
      "science politique",
      "common law",
      "faculté de droit",
    ],
    sources: ["MINESUP", "UNIV_YAOUNDE2", "ENAM", "MINJUSTICE"],
  },
  {
    slug: "sciences-economiques-gestion",
    titre: "Sciences économiques et gestion",
    categorie: "Enseignement supérieur",
    niveau_acces: "Baccalauréat ou A Level",
    resume:
      "Licences et masters en économie, gestion, finance, comptabilité, marketing. Débouchés dans les banques, les entreprises, les administrations financières et la création d'entreprise.",
    contenu: `## Où étudier
- **Facultés de sciences économiques et de gestion** (FSEG) des universités d'État.
- **ESSEC Douala**, sur concours, pour la gestion et le commerce.
- **ISSEA**, sur concours, pour la statistique et l'économie appliquée.
- **BTS/HND** en comptabilité, banque ou marketing dans les instituts privés.

## Débouchés
Banques, microfinance, assurances, entreprises, cabinets comptables, régies financières (impôts, douanes, trésor) par l'ENAM, et création d'entreprise.

## Conseil
Les **mathématiques** comptent en économie : n'abandonne pas les maths si tu vises la finance ou la statistique.`,
    debouches: [
      "Économiste",
      "Comptable",
      "Banquier",
      "Contrôleur de gestion",
      "Inspecteur des impôts",
    ],
    formations: ["FSEG", "ESSEC Douala", "ISSEA", "BTS/HND", "ENAM (régies financières)"],
    mots_cles: ["économie", "gestion", "finance", "comptabilité", "fseg", "essec", "banque"],
    sources: ["MINESUP", "UNIV_DOUALA", "ISSEA", "ENAM"],
  },
  {
    slug: "lettres-langues-sciences-humaines",
    titre: "Lettres, langues et sciences humaines",
    categorie: "Enseignement supérieur",
    niveau_acces: "Baccalauréat ou A Level",
    resume:
      "Lettres modernes, langues (anglais, allemand, espagnol, chinois…), histoire, géographie, sociologie, psychologie, philosophie. Vers l'enseignement, la traduction, le tourisme, la culture et la communication.",
    contenu: `## Parcours
Licences et masters en **lettres, langues étrangères, langues et cultures camerounaises, histoire, géographie, sociologie, psychologie, philosophie**.

## Débouchés
- **Enseignement**, par le concours de l'ENS.
- **Traduction et interprétation** : le bilinguisme anglais-français est très demandé.
- **Tourisme**, **culture** et patrimoine.
- **Communication**, ONG, ressources humaines (psychologie, sociologie), conseil d'orientation.

## Conseil
Ajoute une **compétence pratique** à ton diplôme (informatique, langue rare, gestion de projet) pour te démarquer sur le marché de l'emploi.`,
    debouches: [
      "Enseignant",
      "Traducteur",
      "Guide touristique",
      "Psychologue",
      "Chargé de communication",
    ],
    formations: ["Facultés des lettres et sciences humaines", "ENS", "ASTI (Buea, traduction)"],
    mots_cles: [
      "lettres",
      "langues",
      "histoire",
      "géographie",
      "sociologie",
      "psychologie",
      "philosophie",
      "traduction",
    ],
    sources: ["MINESUP", "UNIV_BUEA"],
  },
  // ---------------------------------------------------------------------------
  // Grandes écoles et concours
  // ---------------------------------------------------------------------------
  {
    slug: "ecoles-ingenieurs",
    titre: "Écoles d'ingénieurs (ENSP Yaoundé, ENSPD Douala, ENSPM Maroua, ENSTP…)",
    categorie: "Grandes écoles",
    niveau_acces: "Bac C, D, E, F, TI ou A Level sciences (selon l'école)",
    resume:
      "Les écoles d'ingénieurs publiques recrutent sur concours très sélectif après le Bac (formation en 5 ans) et parfois en admission parallèle après une licence. Spécialités : génie civil, électrique, mécanique, informatique, télécoms, industriel, chimique…",
    contenu: `## Les principales écoles publiques
- **École Nationale Supérieure Polytechnique de Yaoundé** (Université de Yaoundé I).
- **ENSPD Douala** (Université de Douala).
- **ENSP de Maroua** (Université de Maroua).
- **ENSTP**, pour les travaux publics.
- **ENSAI** (Ngaoundéré), pour les agro-industries.
- Les **IUT**, pour les techniciens supérieurs.

## Le concours
Les épreuves portent surtout sur les **mathématiques**, la **physique-chimie** et parfois la culture générale ou le français.

## Conseil
Entraîne-toi sur les **annales** des concours et travaille la vitesse. Les places sont limitées : présente plusieurs concours la même année.

${VERIFIER}`,
    debouches: [
      "Ingénieur génie civil",
      "Ingénieur électricien",
      "Ingénieur informaticien",
      "Ingénieur télécoms",
      "Ingénieur mécanicien",
    ],
    formations: ["ENSP Yaoundé", "ENSPD Douala", "ENSPM Maroua", "ENSTP", "ENSAI"],
    mots_cles: ["ingénieur", "polytechnique", "enspy", "enspd", "enstp", "concours", "génie"],
    sources: ["MINESUP", "UY1", "UNIV_DOUALA", "UNIV_MAROUA", "MINTP"],
  },
  {
    slug: "iut",
    titre: "Instituts Universitaires de Technologie (IUT)",
    categorie: "Grandes écoles",
    niveau_acces: "Bac scientifique, technique ou commercial, ou A Level",
    resume:
      "Les IUT (Douala, Fotso Victor de Bandjoun, Ngaoundéré) forment des techniciens supérieurs en 2 à 3 ans (DUT, licence technologique), avec une possibilité de poursuite en école d'ingénieurs.",
    contenu: `## Spécialités fréquentes
Génie civil, génie électrique, génie mécanique, génie informatique, réseaux et télécoms, maintenance industrielle, gestion, commerce, logistique, génie biologique.

## Atouts
- Une formation **courte et pratique**, avec des stages.
- Une **insertion rapide**.
- Une possibilité de **poursuite d'études**, en licence professionnelle ou en école d'ingénieurs, sur concours.

${VERIFIER}`,
    debouches: [
      "Technicien supérieur",
      "Chef d'équipe",
      "Technicien de maintenance",
      "Assistant de gestion",
    ],
    formations: ["IUT de Douala", "IUT Fotso Victor de Bandjoun", "IUT de Ngaoundéré"],
    mots_cles: [
      "iut",
      "dut",
      "technicien supérieur",
      "licence technologique",
      "bandjoun",
      "douala",
    ],
    sources: ["MINESUP", "UNIV_DOUALA", "UNIV_DSCHANG", "UNIV_NGAOUNDERE"],
  },
  {
    slug: "medecine-pharmacie",
    titre: "Médecine, pharmacie et chirurgie dentaire",
    categorie: "Santé",
    niveau_acces: "Bac C ou D, ou A Level sciences (biology, chemistry, physics)",
    resume:
      "Les facultés de médecine publiques (FMSB Yaoundé I, FMSP Douala, Faculty of Health Sciences de Buea et autres) recrutent sur concours très sélectif. La formation de médecin généraliste dure environ 7 ans.",
    contenu: `## Où se former
- **FMSB** (Faculté de Médecine et des Sciences Biomédicales, Université de Yaoundé I).
- **FMSP** (Université de Douala).
- **Faculty of Health Sciences** (University of Buea).
- D'autres facultés de médecine publiques et des établissements privés agréés.

## Le concours
Les épreuves portent surtout sur la **biologie**, la **chimie**, la **physique** et parfois la culture générale. Il y a beaucoup de candidats pour peu de places.

## La réalité
Les études sont **longues et exigeantes**. Les besoins sont réels, surtout dans les **zones rurales**. Après le doctorat, les spécialisations (chirurgie, pédiatrie, gynécologie…) passent par d'autres concours.

## Conseil
Si tu échoues au concours, l'**option paramédicale** (infirmier, sage-femme, technicien de laboratoire) ou la **biologie** sont de bonnes voies de rebond.

${VERIFIER}`,
    debouches: [
      "Médecin généraliste",
      "Médecin spécialiste",
      "Pharmacien",
      "Chirurgien-dentiste",
      "Chercheur biomédical",
    ],
    formations: ["FMSB (Yaoundé I)", "FMSP (Douala)", "FHS (Buea)"],
    mots_cles: [
      "médecine",
      "médecin",
      "pharmacie",
      "dentiste",
      "fmsb",
      "concours médecine",
      "santé",
    ],
    sources: ["MINESUP", "UY1", "UNIV_DOUALA", "UNIV_BUEA", "MINSANTE"],
  },
  {
    slug: "formations-paramedicales",
    titre: "Formations paramédicales (infirmier, sage-femme, technicien de laboratoire…)",
    categorie: "Santé",
    niveau_acces: "Probatoire, Baccalauréat ou GCE selon la formation",
    resume:
      "Les écoles publiques de formation du MINSANTE et des universités, ainsi que les instituts privés agréés (BTS/HND santé), forment infirmiers, sages-femmes, techniciens de laboratoire, d'imagerie, de pharmacie, kinésithérapeutes.",
    contenu: `## Les métiers
- Infirmier diplômé d'État.
- Sage-femme ou maïeuticien.
- Technicien de laboratoire, technicien en imagerie médicale.
- Préparateur en pharmacie.
- Kinésithérapeute.
- Aide-soignant.

## Où se former
- **Écoles publiques**, sur concours : écoles du MINSANTE, filières des universités.
- **Instituts privés agréés**, en **BTS/HND santé**. Vérifie toujours que l'institut est **agréé** et que la filière est autorisée.

## Réalité
Les besoins sont forts dans les hôpitaux, les centres de santé, les cliniques privées et les ONG, notamment hors des grandes villes.

${VERIFIER}`,
    debouches: [
      "Infirmier",
      "Sage-femme",
      "Technicien de laboratoire",
      "Technicien d'imagerie",
      "Kinésithérapeute",
    ],
    formations: [
      "Écoles du MINSANTE",
      "Universités (filières santé)",
      "BTS/HND santé (instituts agréés)",
    ],
    mots_cles: [
      "infirmier",
      "sage-femme",
      "paramédical",
      "laboratoire",
      "santé",
      "aide-soignant",
      "kiné",
    ],
    sources: ["MINSANTE", "MINESUP"],
  },
  {
    slug: "agronomie-agro-industrie",
    titre: "Agronomie, agro-industrie, élevage et forêt",
    categorie: "Agriculture & environnement",
    niveau_acces: "Bac C ou D, ou A Level sciences",
    resume:
      "La FASA (Université de Dschang) forme des ingénieurs agronomes et forestiers ; l'ENSAI (Ngaoundéré) des ingénieurs des industries agroalimentaires. L'agriculture reste un grand secteur d'emploi et d'entrepreneuriat au Cameroun.",
    contenu: `## Où se former
- **FASA** (Faculté d'Agronomie et des Sciences Agricoles, Université de Dschang), sur concours : agronomie, productions animales, forêt, économie rurale.
- **ENSAI** (Ngaoundéré) : agro-industries et transformation alimentaire.
- Écoles et centres sous tutelle du MINADER et du MINEPIA, pour les techniciens d'agriculture et d'élevage.
- **IUT** (génie biologique) et **BTS/HND** en agriculture.

## Débouchés
- **Agrobusiness** et création d'exploitation (cacao, café, maïs, cultures maraîchères, aviculture, pisciculture).
- Agro-industries, conseil agricole, projets de développement, administration (MINADER, MINEPIA).

## Conseil
L'agriculture moderne est un **vrai métier d'entrepreneur** : gestion, irrigation, transformation et commercialisation font la différence.

${VERIFIER}`,
    debouches: [
      "Ingénieur agronome",
      "Technicien agricole",
      "Agro-entrepreneur",
      "Ingénieur agroalimentaire",
      "Ingénieur forestier",
    ],
    formations: [
      "FASA Dschang",
      "ENSAI Ngaoundéré",
      "Écoles MINADER / MINEPIA",
      "BTS/HND agriculture",
    ],
    mots_cles: [
      "agronomie",
      "agriculture",
      "fasa",
      "ensai",
      "élevage",
      "forêt",
      "agro-industrie",
      "agrobusiness",
    ],
    sources: ["MINESUP", "UNIV_DSCHANG", "UNIV_NGAOUNDERE", "MINADER", "MINEPIA"],
  },
  {
    slug: "ens-enseignement",
    titre: "Devenir enseignant : ENS, ENSET, ENIEG / ENIET",
    categorie: "Enseignement",
    niveau_acces:
      "Bac / A Level (ENS 1er cycle), Licence (ENS 2nd cycle), BEPC à Bac (ENIEG/ENIET)",
    resume:
      "Les Écoles Normales Supérieures forment les professeurs du secondaire général (ENS) et technique (ENSET) ; les ENIEG et ENIET forment les instituteurs. Accès sur concours.",
    contenu: `## Les écoles
- **ENS** (Yaoundé, Maroua, Bambili, et d'autres créées récemment) : professeurs de lycées et de collèges, toutes disciplines.
- **ENSET** (Douala, Bambili, Kumba, Ebolowa…) : professeurs de l'**enseignement technique**.
- **ENIEG / ENIET** : **instituteurs** de l'enseignement général et technique, pour le primaire et la maternelle.

## Les cycles
- **Premier cycle** après le Bac ou le A Level : diplôme de professeur des collèges.
- **Second cycle** après la licence : diplôme de professeur des lycées.

## Réalité
L'enseignement est un **grand employeur public**. Les affectations peuvent se faire **partout sur le territoire**.

${VERIFIER}`,
    debouches: [
      "Professeur de lycée",
      "Professeur de collège",
      "Professeur de l'enseignement technique",
      "Instituteur",
      "Conseiller d'orientation",
    ],
    formations: ["ENS Yaoundé", "ENS Maroua", "ENSET Douala", "ENIEG / ENIET"],
    mots_cles: [
      "enseignant",
      "professeur",
      "ens",
      "enset",
      "enieg",
      "eniet",
      "instituteur",
      "concours",
    ],
    sources: ["MINESUP", "UY1", "UNIV_DOUALA", "UNIV_MAROUA", "MINESEC"],
  },
  {
    slug: "enam-administration",
    titre: "ENAM : administration, magistrature et régies financières",
    categorie: "Administration & diplomatie",
    niveau_acces: "Cycle B : Baccalauréat ; cycle A : Licence (selon la division)",
    resume:
      "L'École Nationale d'Administration et de Magistrature forme administrateurs civils, magistrats, inspecteurs des impôts, du trésor et des douanes. Concours en ligne sur concours.enam.cm.",
    contenu: `## Les divisions
- **Administration générale** : administrateurs civils.
- **Magistrature** et greffes.
- **Régies financières** : impôts, trésor, douanes.

## Les cycles
- **Cycle A**, accessible avec une licence selon la division.
- **Cycle B**, accessible avec le baccalauréat.

## Le concours
L'inscription se fait **en ligne** sur la plateforme officielle de l'ENAM. On prépare un dossier, notamment avec un casier judiciaire récent. Les épreuves portent sur la culture générale, le droit, l'économie ou les finances selon la division.

## Attention
Méfie-toi des intermédiaires qui promettent des places contre de l'argent : **le recrutement se fait uniquement par concours**.

${VERIFIER}`,
    debouches: [
      "Administrateur civil",
      "Magistrat",
      "Inspecteur des impôts",
      "Inspecteur du trésor",
      "Inspecteur des douanes",
    ],
    formations: ["ENAM (Yaoundé)"],
    mots_cles: [
      "enam",
      "administration",
      "magistrature",
      "impôts",
      "douanes",
      "trésor",
      "fonction publique",
      "concours",
    ],
    sources: ["ENAM", "ENAM_CONCOURS", "MINFI"],
  },
  {
    slug: "iric-diplomatie",
    titre: "Relations internationales et diplomatie (IRIC)",
    categorie: "Administration & diplomatie",
    niveau_acces: "Licence (concours d'entrée en master)",
    resume:
      "L'Institut des Relations Internationales du Cameroun (Université de Yaoundé II) forme aux relations internationales, à la diplomatie, au contentieux international et à la communication internationale.",
    contenu: `## Accès
Concours après une **licence**, le plus souvent en droit, science politique, économie, histoire ou langues.

## Débouchés
Diplomatie, via les concours de la fonction publique, organisations internationales et régionales (Union africaine, CEMAC, agences de l'ONU), ONG, entreprises internationales, journalisme international.

## Conseil
Le **bilinguisme parfait** et une **troisième langue** sont de vrais atouts.

${VERIFIER}`,
    debouches: [
      "Diplomate",
      "Chargé de relations internationales",
      "Fonctionnaire international",
      "Consultant",
    ],
    formations: ["IRIC (Université de Yaoundé II)"],
    mots_cles: [
      "iric",
      "diplomatie",
      "relations internationales",
      "diplomate",
      "onu",
      "affaires étrangères",
    ],
    sources: ["MINESUP", "UNIV_YAOUNDE2"],
  },
  {
    slug: "esstic-journalisme-communication",
    titre: "Journalisme et communication (ESSTIC)",
    categorie: "Communication & arts",
    niveau_acces: "Baccalauréat ou A Level (concours)",
    resume:
      "L'École Supérieure des Sciences et Techniques de l'Information et de la Communication (Université de Yaoundé II) forme journalistes, communicateurs, publicitaires, éditeurs et documentalistes.",
    contenu: `## Filières
- **Journalisme** : presse écrite, radio, télévision, web.
- **Communication** des organisations, **publicité**.
- **Édition**, **documentation et archives**.

## Débouchés
Médias publics et privés, services de communication des ministères et des entreprises, agences, ONG, communication numérique (community management).

## Conseil
Lance-toi dès maintenant : **blog, radio scolaire, journal du lycée**, pages sur les réseaux sociaux. Un portfolio compte autant que le diplôme.

${VERIFIER}`,
    debouches: [
      "Journaliste",
      "Chargé de communication",
      "Community manager",
      "Publicitaire",
      "Documentaliste",
    ],
    formations: ["ESSTIC (Yaoundé II)", "Licences de communication", "BTS/HND communication"],
    mots_cles: [
      "journalisme",
      "journaliste",
      "communication",
      "esstic",
      "médias",
      "publicité",
      "community manager",
    ],
    sources: ["MINESUP", "UNIV_YAOUNDE2"],
  },
  {
    slug: "issea-statistique",
    titre: "Statistique et économie appliquée (ISSEA)",
    categorie: "Grandes écoles",
    niveau_acces:
      "Bac scientifique (cycles techniciens) ou Licence (cycles ingénieurs), selon le cycle",
    resume:
      "L'ISSEA (Yaoundé), institut de la CEMAC, forme des statisticiens et économistes. Ce sont des profils rares et demandés : INS, banques, assurances, organisations internationales.",
    contenu: `## Formations
Plusieurs cycles, de technicien supérieur de la statistique à ingénieur statisticien-économiste. Le recrutement se fait sur **concours communs** à plusieurs écoles africaines de statistique.

## Débouchés
- **Institut National de la Statistique** et services statistiques des ministères.
- Banques, assurances, télécoms.
- Bureaux d'études, organisations internationales, **science des données**.

## Conseil
Il faut un **excellent niveau en mathématiques** (probabilités, analyse) et de la rigueur.

${VERIFIER}`,
    debouches: ["Statisticien", "Économiste", "Data analyst", "Actuaire"],
    formations: ["ISSEA (Yaoundé)"],
    mots_cles: ["issea", "statistique", "statisticien", "économie appliquée", "data", "actuariat"],
    sources: ["ISSEA", "INS"],
  },
  {
    slug: "essec-gestion",
    titre: "Commerce et gestion (ESSEC Douala et écoles de commerce)",
    categorie: "Commerce & gestion",
    niveau_acces: "Baccalauréat ou A Level (concours)",
    resume:
      "L'ESSEC (Université de Douala) et les écoles de commerce forment aux métiers de la gestion, du marketing, de la finance, de la logistique et des ressources humaines.",
    contenu: `## Formations
Gestion des entreprises, comptabilité et finance, marketing et commerce, logistique et transport, ressources humaines.

## Débouchés
- Entreprises de Douala, la **capitale économique**.
- Le port, les banques, les télécoms, la grande distribution.
- La création d'entreprise.

## Alternatives
Les FSEG des universités, les **BTS/HND** en gestion et commerce dans les instituts privés agréés.

${VERIFIER}`,
    debouches: [
      "Gestionnaire",
      "Responsable marketing",
      "Logisticien",
      "Contrôleur de gestion",
      "Responsable RH",
    ],
    formations: ["ESSEC (Université de Douala)", "FSEG", "BTS/HND gestion"],
    mots_cles: [
      "essec",
      "école de commerce",
      "gestion",
      "marketing",
      "logistique",
      "ressources humaines",
      "douala",
    ],
    sources: ["MINESUP", "UNIV_DOUALA"],
  },
  {
    slug: "bts-hnd",
    titre: "BTS et HND (instituts privés d'enseignement supérieur)",
    categorie: "Enseignement supérieur",
    niveau_acces: "Baccalauréat, BT ou GCE A Level",
    resume:
      "Le BTS (francophone) et le HND (anglophone) se préparent en 2 ans dans des instituts privés d'enseignement supérieur (IPES) agréés ; l'examen national est organisé par le MINESUP.",
    contenu: `## Principe
- Formation **professionnelle courte**, en 2 ans.
- Domaines variés : informatique, comptabilité, banque, marketing, logistique, santé, génie civil, électrotechnique, tourisme…
- L'**examen national** de BTS et de HND est organisé chaque année par le **MINESUP**.

## Avant de t'inscrire
- Vérifie que l'institut est **agréé** et que **la filière est autorisée**. Le MINESUP publie des listes et des classements des établissements.
- Renseigne-toi sur les **stages** et le **taux de réussite** à l'examen national.

## Après
Emploi direct, licence professionnelle, ou concours d'admission parallèle dans certaines écoles.`,
    debouches: [
      "Technicien supérieur",
      "Assistant comptable",
      "Technicien informatique",
      "Agent commercial",
    ],
    formations: ["Instituts privés d'enseignement supérieur (IPES) agréés"],
    mots_cles: [
      "bts",
      "hnd",
      "higher national diploma",
      "institut privé",
      "ipes",
      "deux ans",
      "minesup",
    ],
    sources: ["MINESUP"],
  },
  {
    slug: "formation-professionnelle",
    titre: "Formation professionnelle (centres agréés, SAR/SM, apprentissage)",
    categorie: "Formation professionnelle",
    niveau_acces: "Tous niveaux (souvent dès le CEP ou le BEPC)",
    resume:
      "Les centres de formation professionnelle publics et privés agréés (tutelle MINEFOP) forment rapidement aux métiers : couture, coiffure, menuiserie, mécanique, électricité, froid, maçonnerie, informatique, hôtellerie…",
    contenu: `## Pour qui ?
Pour les jeunes qui veulent **apprendre un métier rapidement**, après le CEP, le BEPC ou le Probatoire, ou qui veulent **se reconvertir**.

## Les structures
- **Centres de formation professionnelle** publics et privés **agréés**.
- **Sections artisanales rurales et sections ménagères (SAR/SM)**.
- **Apprentissage** chez un artisan ou en entreprise.

## Réalité
Beaucoup de jeunes Camerounais vivent d'un **métier technique** et de l'**auto-emploi**. Une bonne qualification permet de se lancer avec peu de moyens, puis de grandir.

## Conseil
Choisis un centre **agréé par le MINEFOP**. Renseigne-toi sur les **bourses de formation** et sur l'accompagnement du **FNE** pour l'emploi et le financement de projets.`,
    debouches: ["Couturier", "Coiffeur", "Menuisier", "Électricien", "Mécanicien", "Cuisinier"],
    formations: ["Centres de formation professionnelle agréés", "SAR/SM", "Apprentissage"],
    mots_cles: [
      "formation professionnelle",
      "métier",
      "centre de formation",
      "minefop",
      "apprentissage",
      "sar sm",
      "auto-emploi",
    ],
    sources: ["MINEFOP", "FNE"],
  },
  {
    slug: "defense-securite",
    titre: "Défense et sécurité (EMIA, armée, police, gendarmerie)",
    categorie: "Défense & sécurité",
    niveau_acces: "Selon le corps : BEPC, Probatoire, Baccalauréat ou Licence",
    resume:
      "L'École Militaire Interarmées (EMIA) forme les officiers ; les recrutements de soldats, sous-officiers, gendarmes et policiers se font par concours annuels du MINDEF et de la DGSN.",
    contenu: `## Les voies
- **EMIA** (Yaoundé) : officiers des armées, sur concours après le Bac ou la licence.
- **Armée et gendarmerie** : recrutements de militaires du rang et de sous-officiers.
- **Police** (DGSN) : concours de gardien de la paix, d'inspecteur, d'officier, de commissaire, selon le diplôme.
- **Sapeurs-pompiers**.

## Ce qu'on attend de toi
Aptitude physique et médicale, discipline, casier judiciaire vierge, limites d'âge.

## Attention
Les **arnaques aux faux recrutements** sont fréquentes : les inscriptions et les résultats sont publiés par les **communiqués officiels** du MINDEF et de la DGSN. On ne paie **jamais** un intermédiaire.

${VERIFIER}`,
    debouches: ["Officier", "Sous-officier", "Gendarme", "Policier", "Sapeur-pompier"],
    formations: [
      "EMIA",
      "Écoles de la gendarmerie et de l'armée",
      "École Nationale Supérieure de Police",
    ],
    mots_cles: [
      "armée",
      "emia",
      "militaire",
      "police",
      "gendarmerie",
      "dgsn",
      "mindef",
      "sapeur-pompier",
    ],
    sources: ["MINDEF", "DGSN"],
  },
  {
    slug: "beaux-arts-culture",
    titre: "Arts, culture, design et métiers créatifs",
    categorie: "Communication & arts",
    niveau_acces: "Selon la formation (souvent Baccalauréat)",
    resume:
      "Beaux-arts, architecture, design, audiovisuel, musique : l'Institut des Beaux-Arts de Foumban (Université de Dschang), les filières d'arts des universités, des écoles privées et l'apprentissage auprès de professionnels.",
    contenu: `## Formations
- **Institut des Beaux-Arts de Foumban** (Université de Dschang) : arts plastiques, architecture et arts du patrimoine, cinéma et audiovisuel, musique.
- Filières **arts du spectacle** et **cinéma** de certaines universités.
- Écoles privées de **design graphique**, de **mode** et d'**audiovisuel**.

## Réalité
Les métiers créatifs demandent un **portfolio** et un **réseau**. Beaucoup combinent leur art avec le **numérique** : graphisme, vidéo, réseaux sociaux.

## Conseil
Crée et publie régulièrement, participe aux **festivals et concours**, et apprends à **vendre ton travail**.`,
    debouches: [
      "Graphiste",
      "Architecte",
      "Réalisateur",
      "Musicien",
      "Styliste",
      "Artiste plasticien",
    ],
    formations: [
      "Institut des Beaux-Arts de Foumban",
      "Filières arts des universités",
      "Écoles privées",
    ],
    mots_cles: [
      "arts",
      "beaux-arts",
      "foumban",
      "design",
      "musique",
      "cinéma",
      "audiovisuel",
      "mode",
      "architecture",
    ],
    sources: ["MINESUP", "UNIV_DSCHANG"],
  },
  {
    slug: "traduction-interpretation",
    titre: "Traduction et interprétation (ASTI Buea)",
    categorie: "Communication & arts",
    niveau_acces: "Licence (concours d'entrée)",
    resume:
      "Le Cameroun, pays bilingue, a besoin de traducteurs et d'interprètes. L'Advanced School of Translators and Interpreters (ASTI, University of Buea) en forme sur concours après la licence.",
    contenu: `## Accès
Concours après une **licence**, avec un excellent niveau en **anglais et en français**, et souvent une autre langue.

## Débouchés
Services de traduction de l'administration, organisations internationales, entreprises, médias, traducteur et interprète indépendant, enseignement des langues.

## Conseil
Lis et écris **chaque jour dans les deux langues officielles**. Une troisième langue, comme l'espagnol, l'allemand, le chinois ou l'arabe, multiplie tes chances.`,
    debouches: [
      "Traducteur",
      "Interprète de conférence",
      "Rédacteur bilingue",
      "Enseignant de langues",
    ],
    formations: ["ASTI (University of Buea)", "Facultés de lettres (langues)"],
    mots_cles: ["traduction", "traducteur", "interprète", "asti", "bilinguisme", "langues", "buea"],
    sources: ["MINESUP", "UNIV_BUEA"],
  },
];
