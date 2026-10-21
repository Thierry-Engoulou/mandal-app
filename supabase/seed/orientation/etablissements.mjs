// Fiches « Établissements » : universités d'État, grandes écoles et études
// par région. Seuls des faits stables sont indiqués (tutelle, mode d'accès,
// domaines) ; les dates, frais et places sont renvoyés au communiqué officiel.

const VERIFIER =
  "Les filières ouvertes, les conditions d'accès et le calendrier changent : vérifie toujours le communiqué officiel de l'année (MINESUP et site de l'établissement).";

function etab({
  slug,
  titre,
  categorie,
  niveau,
  resume,
  presentation,
  formations,
  acces,
  conseil,
  debouches = [],
  mots_cles = [],
  sources,
}) {
  return {
    slug,
    titre,
    categorie,
    niveau_acces: niveau,
    resume,
    contenu: `## Présentation
${presentation}

## Ce qu'on y étudie
${formations.map((f) => `- ${f}`).join("\n")}

## Comment y entrer
${acces}

## Conseil
${conseil} ${VERIFIER}`,
    debouches,
    formations: formations.map((f) => f.replace(/\*\*/g, "").split(" : ")[0]),
    mots_cles,
    sources,
  };
}

const ETABLISSEMENTS = [
  // ------------------------------------------------------- Universités d'État
  etab({
    slug: "universite-yaounde-1",
    titre: "Université de Yaoundé I",
    categorie: "Universités d'État",
    niveau: "Bac / GCE A Level (facultés) ; concours pour les écoles",
    resume:
      "Grande université scientifique et littéraire de la capitale, avec des écoles réputées : ENSP (ingénieurs), ENS (enseignants) et FMSB (médecine).",
    presentation:
      "Située à Yaoundé (Centre), l'Université de Yaoundé I est l'héritière de la première université du pays. Elle regroupe des facultés classiques et plusieurs grandes écoles recrutant sur concours.",
    formations: [
      "**Faculté des Sciences** : mathématiques, physique, chimie, biologie, informatique, géosciences",
      "**Faculté des Arts, Lettres et Sciences Humaines** : langues, histoire, géographie, philosophie, psychologie, sociologie",
      "**FMSB** : médecine, pharmacie, odontostomatologie (concours)",
      "**ENSP / ENSPY** : écoles d'ingénieurs (concours)",
      "**ENS** : formation des professeurs de l'enseignement secondaire (concours)",
    ],
    acces:
      "Facultés : préinscription après le Bac ou le GCE A Level, selon les séries admises par filière. Écoles (ENSP, ENS, FMSB) : **concours** annoncés par le MINESUP.",
    conseil:
      "Les filières scientifiques demandent un bon niveau en maths ; prépare les concours des écoles dès la Terminale.",
    debouches: ["Ingénieur", "Médecin", "Professeur", "Chercheur", "Informaticien"],
    mots_cles: ["uy1", "yaoundé 1", "université de yaoundé", "ngoa-ekelle", "ensp", "ens", "fmsb"],
    sources: ["UY1", "ENSPY", "MINESUP"],
  }),
  etab({
    slug: "universite-yaounde-2",
    titre: "Université de Yaoundé II-Soa",
    categorie: "Universités d'État",
    niveau: "Bac / GCE A Level (facultés) ; concours pour ESSTIC et IRIC",
    resume:
      "Université du droit, de la science politique, de l'économie et de la gestion, avec deux écoles très demandées : l'ESSTIC (journalisme, communication) et l'IRIC (relations internationales).",
    presentation:
      "Son campus principal est à Soa, près de Yaoundé. Elle possède aussi des sites à Yaoundé (ESSTIC, IRIC) et des antennes dans d'autres villes.",
    formations: [
      "**Faculté des Sciences Juridiques et Politiques** : droit public, droit privé, science politique",
      "**Faculté des Sciences Économiques et de Gestion** : économie, gestion, finance",
      "**ESSTIC** : journalisme, communication des organisations, archivistique, édition (concours)",
      "**IRIC** : relations internationales, diplomatie, contentieux, marketing international (concours, niveau master)",
    ],
    acces:
      "Facultés : préinscription en ligne après le Bac ou le A Level. ESSTIC et IRIC : **concours** publiés par le MINESUP.",
    conseil:
      "Le droit et l'économie demandent beaucoup de lecture et de rédaction ; travaille ton expression écrite et l'anglais.",
    debouches: ["Juriste", "Avocat", "Économiste", "Journaliste", "Diplomate"],
    mots_cles: ["uy2", "soa", "yaoundé 2", "droit", "économie", "esstic", "iric"],
    sources: ["UNIV_YAOUNDE2", "ESSTIC", "IRIC", "MINESUP"],
  }),
  etab({
    slug: "universite-douala",
    titre: "Université de Douala",
    categorie: "Universités d'État",
    niveau: "Bac / GCE A Level (facultés) ; concours pour les écoles",
    resume:
      "Université de la capitale économique, proche des entreprises et du port : écoles d'ingénieurs (ENSPD), d'enseignement technique (ENSET), de commerce (ESSEC), IUT et médecine.",
    presentation:
      "Créée en 1993, l'Université de Douala (Littoral) a hérité de l'ESSEC et de l'ENSET. Elle est très liée au tissu industriel et commercial de Douala.",
    formations: [
      "**Facultés** : sciences, lettres et sciences humaines, sciences juridiques et politiques, sciences économiques et gestion appliquée",
      "**FMSP** : médecine et sciences pharmaceutiques (concours)",
      "**ENSPD** : école d'ingénieurs (concours)",
      "**ENSET** : professeurs de l'enseignement technique (concours)",
      "**ESSEC** : commerce, gestion, logistique (concours)",
      "**IUT de Douala** : formations technologiques courtes (concours ou dossier)",
    ],
    acces:
      "Facultés : préinscription après le Bac ou le A Level. Écoles et IUT : **concours** annoncés par le MINESUP et l'université.",
    conseil:
      "À Douala, les stages en entreprise sont plus faciles à trouver : profites-en dès la première année.",
    debouches: ["Ingénieur", "Gestionnaire", "Logisticien", "Professeur du technique", "Médecin"],
    mots_cles: ["udo", "douala", "enspd", "enset", "essec", "iut douala", "fmsp"],
    sources: ["UNIV_DOUALA", "ESSEC", "MINESUP"],
  }),
  etab({
    slug: "universite-dschang",
    titre: "Université de Dschang",
    categorie: "Universités d'État",
    niveau: "Bac / GCE A Level (facultés) ; concours pour FASA et IUT",
    resume:
      "Université bilingue de l'Ouest, référence nationale en agronomie (FASA), avec l'IUT Fotso Victor de Bandjoun et de nombreuses facultés.",
    presentation:
      "Issue d'un centre universitaire agricole fondé en 1977, l'Université de Dschang (Ouest) est devenue une université complète en 1993. Elle a des campus et annexes dans plusieurs villes.",
    formations: [
      "**FASA** : agronomie, foresterie, productions animales, agroéconomie (concours)",
      "**IUT Fotso Victor (Bandjoun)** : génie électrique, génie civil, informatique, génie mécanique…",
      "**Facultés** : sciences, lettres, droit et science politique, sciences économiques et gestion, médecine et sciences pharmaceutiques",
    ],
    acces:
      "Facultés : préinscription après le Bac ou le A Level. FASA et IUT : **concours** annoncés par le MINESUP.",
    conseil:
      "Si l'agriculture moderne et l'agrobusiness t'intéressent, la FASA est l'une des meilleures portes d'entrée du pays.",
    debouches: [
      "Ingénieur agronome",
      "Ingénieur des eaux et forêts",
      "Technicien supérieur",
      "Juriste",
    ],
    mots_cles: ["uds", "dschang", "fasa", "bandjoun", "iut fv", "agronomie", "ouest"],
    sources: ["UNIV_DSCHANG", "FASA", "MINESUP"],
  }),
  etab({
    slug: "university-of-buea",
    titre: "University of Buea",
    categorie: "Universités d'État",
    niveau: "GCE A Level / Bac (faculties) ; entrance exams for professional schools",
    resume:
      "Université d'État de tradition anglo-saxonne (Sud-Ouest), en anglais : sciences, santé, agriculture, traduction et interprétation (ASTI), technologie.",
    presentation:
      "Founded as a university centre in 1985 and chartered as a full university in the early 1990s, the University of Buea (South West Region) teaches mainly in English and offers about 80 degree programmes.",
    formations: [
      "**Faculty of Health Sciences** : medicine, nursing, medical laboratory science (concours)",
      "**ASTI** : traduction et interprétation, niveau master (concours)",
      "**College of Technology (COT)** : ingénierie et technologie",
      "**Faculties** : science, arts, social and management sciences, education, agriculture and veterinary medicine, engineering, law",
    ],
    acces:
      "Faculties: admission on the basis of the GCE A Level (or equivalent). Professional schools: **competitive entrance examinations** published by MINESUP and the university.",
    conseil:
      "Les élèves francophones peuvent y étudier s'ils maîtrisent bien l'anglais : c'est un excellent moyen de devenir parfaitement bilingue.",
    debouches: ["Doctor", "Nurse", "Translator", "Engineer", "Teacher"],
    mots_cles: ["ub", "buea", "anglophone", "english", "asti", "molyko", "health sciences"],
    sources: ["UNIV_BUEA", "MINESUP", "GCEB"],
  }),
  etab({
    slug: "universite-ngaoundere",
    titre: "Université de Ngaoundéré",
    categorie: "Universités d'État",
    niveau: "Bac / GCE A Level (facultés) ; concours pour les écoles",
    resume:
      "Grande université de l'Adamaoua, réputée pour l'agro-industrie (ENSAI) et la médecine vétérinaire (ESMV), avec un IUT et plusieurs facultés.",
    presentation:
      "Issue du Centre universitaire de Ngaoundéré (1982), elle est devenue université en 1993. Elle compte une dizaine d'établissements et plus d'une centaine de formations.",
    formations: [
      "**ENSAI** : génie des procédés, génie alimentaire, qualité, chimie industrielle (concours)",
      "**ESMV** : médecine vétérinaire (concours)",
      "**IUT de Ngaoundéré** : formations technologiques courtes",
      "**Facultés** : sciences, lettres et sciences humaines, droit et science politique, sciences économiques et gestion",
    ],
    acces:
      "Préinscription en ligne pour les facultés ; **concours** pour l'ENSAI, l'ESMV et l'IUT, annoncés par le MINESUP.",
    conseil:
      "L'ENSAI est idéale si tu veux travailler dans la transformation des produits agricoles, un secteur porteur.",
    debouches: [
      "Ingénieur agroalimentaire",
      "Vétérinaire",
      "Technicien supérieur",
      "Contrôleur qualité",
    ],
    mots_cles: ["ngaoundéré", "ngaoundere", "ensai", "esmv", "vétérinaire", "adamaoua", "dang"],
    sources: ["UNIV_NGAOUNDERE", "ENSAI", "ESMV", "MINESUP"],
  }),
  etab({
    slug: "universite-maroua",
    titre: "Université de Maroua",
    categorie: "Universités d'État",
    niveau: "Bac / GCE A Level (facultés) ; concours pour les écoles",
    resume:
      "Université de l'Extrême-Nord créée en 2008, avec une École Normale Supérieure, des formations d'ingénieurs et un institut des mines et des industries pétrolières.",
    presentation:
      "Créée par décret en 2008, l'Université de Maroua compte plusieurs établissements, dont l'ENS de Maroua, l'École Nationale Supérieure Polytechnique de Maroua, l'Institut des Mines et des Industries Pétrolières et l'Institut Supérieur du Sahel.",
    formations: [
      "**ENS de Maroua** : formation des enseignants (concours)",
      "**ENSPM** : ingénierie (concours)",
      "**Institut des Mines et des Industries Pétrolières** : mines, pétrole",
      "**Facultés** : sciences, lettres et sciences humaines, sciences économiques et gestion, sciences juridiques et politiques",
    ],
    acces: "Préinscription en ligne pour les facultés ; **concours** pour les écoles et instituts.",
    conseil: "Les concours de l'ENS de Maroua sont une voie importante pour devenir enseignant.",
    debouches: ["Enseignant", "Ingénieur", "Technicien des mines", "Cadre"],
    mots_cles: ["maroua", "extrême-nord", "ens maroua", "enspm", "mines", "pétrole"],
    sources: ["UNIV_MAROUA", "MINESUP"],
  }),
  etab({
    slug: "university-of-bamenda",
    titre: "The University of Bamenda",
    categorie: "Universités d'État",
    niveau: "GCE A Level / Bac (faculties) ; entrance exams for professional schools",
    resume:
      "Université d'État anglophone du Nord-Ouest (Bambili), créée en 2010 : technologie (COLTECH), formation des enseignants du technique (HTTTC), polytechnique (NAHPI), santé.",
    presentation:
      "Created by decree in December 2010 on the Bambili site, the University of Bamenda teaches mainly in English.",
    formations: [
      "**COLTECH** : College of Technology, ingénieurs et technologues",
      "**HTTTC** : Higher Technical Teacher Training College",
      "**NAHPI** : National Higher Polytechnic Institute",
      "**Health sciences** : nursing, midwifery, medical laboratory science (concours)",
      "**Faculties** : arts, science, economics and management, law and political science, education",
    ],
    acces:
      "Admission on the basis of the GCE A Level (or equivalent) through the online UBa portal; **competitive entrance examinations** for professional schools.",
    conseil:
      "Cette université parraine aussi des instituts privés : vérifie toujours l'agrément d'un institut qui se dit « sous tutelle ».",
    debouches: ["Engineer", "Technical teacher", "Nurse", "Lawyer"],
    mots_cles: ["uba", "bamenda", "bambili", "coltech", "htttc", "nahpi", "anglophone"],
    sources: ["UNIV_BAMENDA", "MINESUP", "GCEB"],
  }),
  etab({
    slug: "universite-bertoua",
    titre: "Université de Bertoua",
    categorie: "Universités d'État",
    niveau: "Bac / GCE A Level",
    resume:
      "Université d'État de l'Est, créée par décret en janvier 2022 à partir d'établissements déjà présents dans la région.",
    presentation:
      "Créée en 2022 avec Ebolowa et Garoua, l'Université de Bertoua a repris des écoles et annexes existantes de l'Est. Son offre de formation se développe chaque année.",
    formations: [
      "Facultés et écoles en cours de développement (sciences, lettres, droit, économie, formations professionnelles)",
      "Consulte la liste à jour des filières ouvertes dans le communiqué de préinscription",
    ],
    acces: "Préinscription après le Bac ou le A Level ; concours pour les écoles professionnelles.",
    conseil:
      "Étudier près de chez soi réduit fortement le coût des études : renseigne-toi sur les filières ouvertes à Bertoua.",
    mots_cles: ["bertoua", "est", "nouvelle université", "2022"],
    sources: ["UNIV_BERTOUA", "MINESUP", "LOI_SUP_2023"],
  }),
  etab({
    slug: "universite-ebolowa",
    titre: "Université d'Ebolowa",
    categorie: "Universités d'État",
    niveau: "Bac / GCE A Level",
    resume:
      "Université d'État du Sud, créée par décret en janvier 2022, dont l'offre de formation se met en place progressivement.",
    presentation:
      "Créée en 2022 en même temps que Bertoua et Garoua, l'Université d'Ebolowa rapproche l'enseignement supérieur des étudiants de la région du Sud.",
    formations: [
      "Facultés et écoles en cours de développement",
      "Consulte la liste à jour des filières ouvertes dans le communiqué de préinscription",
    ],
    acces: "Préinscription après le Bac ou le A Level ; concours pour les écoles professionnelles.",
    conseil: "Compare les filières d'Ebolowa avec celles de Yaoundé avant de choisir.",
    mots_cles: ["ebolowa", "sud", "nouvelle université", "2022"],
    sources: ["UNIV_EBOLOWA", "MINESUP", "LOI_SUP_2023"],
  }),
  etab({
    slug: "universite-garoua",
    titre: "Université de Garoua",
    categorie: "Universités d'État",
    niveau: "Bac / GCE A Level",
    resume:
      "Université d'État du Nord, créée par décret en janvier 2022, dont l'offre de formation se met en place progressivement.",
    presentation:
      "Créée en 2022 avec Bertoua et Ebolowa, l'Université de Garoua renforce l'offre universitaire dans la région du Nord.",
    formations: [
      "Facultés et écoles en cours de développement",
      "Consulte la liste à jour des filières ouvertes dans le communiqué de préinscription",
    ],
    acces: "Préinscription après le Bac ou le A Level ; concours pour les écoles professionnelles.",
    conseil:
      "Renseigne-toi aussi sur les formations de Ngaoundéré et de Maroua, proches de Garoua.",
    mots_cles: ["garoua", "nord", "nouvelle université", "2022"],
    sources: ["UNIV_GAROUA", "MINESUP", "LOI_SUP_2023"],
  }),
  // ------------------------------------------------------- Grandes écoles
  etab({
    slug: "ecole-enspy",
    titre: "ENSP Yaoundé (École Nationale Supérieure Polytechnique)",
    categorie: "Grandes écoles",
    niveau: "Bac C, E (et autres séries admises) / A Level sciences + concours",
    resume:
      "La plus ancienne école publique d'ingénieurs du pays (Université de Yaoundé I), avec de nombreuses spécialités et un concours très sélectif.",
    presentation:
      "L'ENSPY recrute chaque année sur concours, avec des épreuves écrites organisées dans les chefs-lieux de région. Elle publie ses communiqués sur son site et sur sa plateforme de concours.",
    formations: [
      "Génie civil, génie électrique, génie mécanique, génie industriel",
      "Génie informatique, télécommunications",
      "Autres filières ouvertes selon les années (ex. génie minier, humanités numériques)",
    ],
    acces:
      "**Concours** en 1re année (après le Bac ou le A Level) et en 3e année (après une licence ou un diplôme équivalent). Inscription en ligne, dossier puis épreuves écrites.",
    conseil:
      "Le concours porte surtout sur les maths et la physique : entraîne-toi avec les annales et chronomètre-toi.",
    debouches: [
      "Ingénieur génie civil",
      "Ingénieur informaticien",
      "Ingénieur électricien",
      "Ingénieur télécoms",
    ],
    mots_cles: ["ensp", "enspy", "polytechnique", "ingénieur", "yaoundé"],
    sources: ["ENSPY", "UY1", "MINESUP"],
  }),
  etab({
    slug: "ecole-enspd",
    titre: "ENSPD Douala (École Nationale Supérieure Polytechnique de Douala)",
    categorie: "Grandes écoles",
    niveau: "Bac C, E, F (selon spécialités) / A Level + concours",
    resume:
      "École publique d'ingénieurs de l'Université de Douala, proche des industries de la capitale économique.",
    presentation:
      "L'ENSPD forme des ingénieurs et des techniciens supérieurs dans plusieurs spécialités, en lien avec les entreprises de Douala.",
    formations: [
      "Génie civil, génie électrique, génie mécanique, génie industriel",
      "Génie informatique, télécommunications, génie des procédés (selon les années)",
    ],
    acces: "**Concours** publié par le MINESUP et l'Université de Douala.",
    conseil:
      "Présente aussi le concours de l'ENSPY et des autres écoles pour multiplier tes chances.",
    debouches: ["Ingénieur", "Chef de projet industriel"],
    mots_cles: ["enspd", "polytechnique douala", "ingénieur", "douala"],
    sources: ["UNIV_DOUALA", "MINESUP"],
  }),
  etab({
    slug: "ecole-enset-douala",
    titre: "ENSET de Douala (École Normale Supérieure d'Enseignement Technique)",
    categorie: "Grandes écoles",
    niveau: "Bac technique ou scientifique / Licence + concours",
    resume:
      "École de l'Université de Douala qui forme les professeurs des lycées techniques (industriel et commercial).",
    presentation:
      "L'ENSET forme les enseignants des disciplines techniques : génie électrique, génie mécanique, génie civil, sciences et techniques commerciales, etc.",
    formations: [
      "Professeurs de l'enseignement technique industriel",
      "Professeurs de l'enseignement technique commercial",
    ],
    acces: "**Concours** au 1er cycle (après le Bac) et au 2nd cycle (après la Licence).",
    conseil:
      "Si tu viens d'une série F ou d'une série commerciale, c'est une voie naturelle vers l'enseignement.",
    debouches: ["Professeur de lycée technique", "Formateur"],
    mots_cles: ["enset", "enseignement technique", "professeur", "douala"],
    sources: ["UNIV_DOUALA", "MINESUP", "MINESEC"],
  }),
  etab({
    slug: "ecole-ens-yaounde",
    titre: "ENS de Yaoundé (École Normale Supérieure)",
    categorie: "Grandes écoles",
    niveau: "Bac ou GCE A Level (1er cycle) / Licence (2nd cycle) + concours",
    resume:
      "École de l'Université de Yaoundé I qui forme les professeurs de l'enseignement secondaire général, dans presque toutes les disciplines.",
    presentation:
      "Le concours de l'ENS est l'une des principales voies pour devenir professeur de collège ou de lycée. L'évaluation combine en général un dossier scolaire et des épreuves écrites.",
    formations: [
      "Mathématiques, informatique, physique, chimie, sciences de la vie et de la Terre",
      "Français, anglais, langues étrangères, histoire, géographie, philosophie",
      "Conseillers d'orientation (selon les années)",
    ],
    acces:
      "**Concours** au 1er cycle (après le Bac ou le A Level) et au 2nd cycle (après la Licence), publiés par le MINESUP.",
    conseil: "Choisis la section qui correspond à la matière où tu as les meilleurs résultats.",
    debouches: ["Professeur de collège ou de lycée", "Conseiller d'orientation"],
    mots_cles: ["ens", "ens yaoundé", "professeur", "enseignant", "école normale"],
    sources: ["UY1", "MINESUP", "MINESEC"],
  }),
  etab({
    slug: "ecole-essec-douala",
    titre: "ESSEC de Douala",
    categorie: "Grandes écoles",
    niveau: "Bac (A, B, C, D, G…) / GCE A Level + concours ; Licence pour certains cycles",
    resume:
      "École publique de commerce et de gestion de l'Université de Douala : comptabilité, finance, marketing, logistique, management.",
    presentation:
      "L'ESSEC recrute sur concours, avec des centres d'examen dans plusieurs villes. Elle propose un cycle après le Bac et des cycles après la Licence.",
    formations: [
      "**ESC** (Études Supérieures de Commerce) : après le Bac ou le A Level",
      "**EPA** (Études Professionnelles Approfondies) : après la Licence",
      "Spécialités : comptabilité, finance, marketing, logistique et transport, gestion",
    ],
    acces:
      "**Concours** annoncé chaque année (formulaire, frais, dossier et inscription en ligne).",
    conseil: "Les maths et la culture économique comptent beaucoup ; entraîne-toi sur les annales.",
    debouches: ["Comptable", "Banquier", "Logisticien", "Responsable marketing"],
    mots_cles: ["essec", "commerce", "gestion", "douala", "école de commerce"],
    sources: ["ESSEC", "UNIV_DOUALA", "MINESUP"],
  }),
  etab({
    slug: "ecole-ensai",
    titre: "ENSAI de Ngaoundéré",
    categorie: "Grandes écoles",
    niveau: "Bac C, D, E, F / A Level sciences + concours",
    resume:
      "École Nationale Supérieure des Sciences Agro-Industrielles : ingénieurs et techniciens de la transformation agroalimentaire et des procédés.",
    presentation:
      "Rattachée à l'Université de Ngaoundéré, l'ENSAI forme aux métiers de l'agro-industrie, du contrôle qualité et du génie des procédés.",
    formations: [
      "Génie des procédés et génie alimentaire",
      "Qualité, hygiène et sécurité des aliments",
      "Chimie industrielle et environnement (selon les années)",
    ],
    acces: "**Concours** publié par le MINESUP.",
    conseil: "Bon niveau en chimie et en biologie indispensable.",
    debouches: ["Ingénieur agroalimentaire", "Responsable qualité", "Chef de production"],
    mots_cles: ["ensai", "agro-industrie", "agroalimentaire", "ngaoundéré", "procédés"],
    sources: ["ENSAI", "UNIV_NGAOUNDERE", "MINESUP"],
  }),
  etab({
    slug: "ecole-esmv",
    titre: "ESMV de Ngaoundéré (médecine vétérinaire)",
    categorie: "Grandes écoles",
    niveau: "Bac C ou D / A Level sciences + concours",
    resume:
      "École des Sciences et de Médecine Vétérinaire de l'Université de Ngaoundéré : la voie publique pour devenir docteur vétérinaire.",
    presentation:
      "L'ESMV forme des vétérinaires pour la santé animale, l'élevage, la sécurité sanitaire des aliments et la santé publique.",
    formations: ["Doctorat en médecine vétérinaire", "Santé animale et santé publique vétérinaire"],
    acces: "**Concours** publié par le MINESUP.",
    conseil: "SVT et chimie sont essentielles ; les stages chez les éleveurs sont très formateurs.",
    debouches: ["Vétérinaire", "Inspecteur sanitaire", "Conseiller en élevage"],
    mots_cles: ["esmv", "vétérinaire", "médecine vétérinaire", "ngaoundéré"],
    sources: ["ESMV", "UNIV_NGAOUNDERE", "MINEPIA"],
  }),
  etab({
    slug: "ecole-fasa",
    titre: "FASA de Dschang (agronomie)",
    categorie: "Grandes écoles",
    niveau: "Bac C ou D / A Level sciences + concours",
    resume:
      "Faculté d'Agronomie et des Sciences Agricoles de l'Université de Dschang : ingénieurs agronomes, forestiers et des productions animales.",
    presentation:
      "La FASA est la principale école publique d'ingénieurs agronomes du pays, avec des fermes d'application et de nombreux stages de terrain.",
    formations: [
      "Productions végétales, productions animales",
      "Foresterie, eaux et forêts",
      "Agroéconomie, génie rural, sciences du sol",
    ],
    acces: "**Concours** publié par le MINESUP.",
    conseil: "Pense dès le départ à l'agrobusiness : produire, transformer, vendre.",
    debouches: ["Ingénieur agronome", "Ingénieur des eaux et forêts", "Agro-entrepreneur"],
    mots_cles: ["fasa", "agronomie", "dschang", "ingénieur agronome", "forêt"],
    sources: ["FASA", "UNIV_DSCHANG", "MINADER"],
  }),
  etab({
    slug: "ecole-esstic",
    titre: "ESSTIC (journalisme et communication)",
    categorie: "Grandes écoles",
    niveau: "Bac / GCE A Level + concours (selon les cycles)",
    resume:
      "École de l'Université de Yaoundé II, créée en 1991 dans la continuité de l'école de journalisme de Yaoundé, qui forme journalistes, communicants, archivistes et éditeurs.",
    presentation:
      "L'ESSTIC propose des cycles de licence, master et doctorat en journalisme, communication des organisations, archivistique, bibliothéconomie et édition.",
    formations: [
      "Journalisme",
      "Communication des organisations",
      "Archivistique, bibliothéconomie, édition",
    ],
    acces: "**Concours** publié par le MINESUP.",
    conseil: "Écris, lis la presse et pratique l'oral : la culture générale est décisive.",
    debouches: ["Journaliste", "Chargé de communication", "Archiviste", "Éditeur"],
    mots_cles: ["esstic", "journalisme", "communication", "médias"],
    sources: ["ESSTIC", "UNIV_YAOUNDE2", "MINESUP"],
  }),
  etab({
    slug: "ecole-iric",
    titre: "IRIC (relations internationales)",
    categorie: "Grandes écoles",
    niveau: "Licence + concours (niveau master)",
    resume:
      "Institut des Relations Internationales du Cameroun (Université de Yaoundé II) : diplomatie, contentieux international, intégration régionale, banque et marketing internationaux.",
    presentation:
      "L'IRIC recrute sur concours après la licence. Les épreuves portent sur les relations internationales, des techniques propres à chaque filière et une épreuve de langue (anglais pour les francophones, français pour les anglophones).",
    formations: [
      "Diplomatie",
      "Contentieux international",
      "Intégration régionale et institutions communautaires",
      "Banque et finance internationales, marketing international",
      "Communication et action publique internationale",
    ],
    acces: "**Concours** publié chaque année par le MINESUP.",
    conseil: "Le bilinguisme et le suivi de l'actualité internationale sont indispensables.",
    debouches: ["Diplomate", "Fonctionnaire international", "Juriste international", "Analyste"],
    mots_cles: ["iric", "diplomatie", "relations internationales", "affaires étrangères"],
    sources: ["IRIC", "UNIV_YAOUNDE2", "MINESUP"],
  }),
  etab({
    slug: "ecole-asti",
    titre: "ASTI de Buea (traduction et interprétation)",
    categorie: "Grandes écoles",
    niveau: "Licence (toute discipline) + concours",
    resume:
      "Advanced School of Translators and Interpreters (University of Buea) : masters en traduction (écrit) et en interprétation (oral).",
    presentation:
      "L'ASTI recrute sur concours des titulaires d'une licence, quelle que soit la discipline. La division traduction a des épreuves écrites ; la division interprétation a des épreuves orales.",
    formations: [
      "Master en traduction (combinaisons anglais/français, avec allemand, espagnol ou arabe selon les années)",
      "Master en interprétation de conférence",
    ],
    acces: "**Concours** publié par le MINESUP.",
    conseil:
      "Excellente maîtrise de l'anglais et du français exigée ; une troisième langue est un atout.",
    debouches: ["Traducteur", "Interprète de conférence", "Réviseur"],
    mots_cles: ["asti", "traduction", "interprétation", "buea", "translator"],
    sources: ["UNIV_BUEA", "MINESUP"],
  }),
  etab({
    slug: "ecole-enstp",
    titre: "ENSTP (École Nationale Supérieure des Travaux Publics)",
    categorie: "Grandes écoles",
    niveau: "Bac scientifique ou technique + concours ; Licence pour certains cycles",
    resume:
      "École de Yaoundé qui forme techniciens, ingénieurs et architectes pour les routes, le bâtiment, la topographie et l'urbanisme.",
    presentation:
      "Fondée en 1970 (d'abord École Nationale de Technologie), l'ENSTP porte son nom actuel depuis 1982. Ses concours sont publiés par le MINESUP.",
    formations: [
      "Cycle technicien",
      "Cycle ingénieur : génie civil, travaux publics, topographie, génie rural…",
      "Architecture et urbanisme (selon les années)",
    ],
    acces: "**Concours** publié par le MINESUP, avec plusieurs cycles d'entrée.",
    conseil: "Bon niveau en maths et en physique ; intéresse-toi au dessin technique.",
    debouches: [
      "Ingénieur des travaux publics",
      "Géomètre-topographe",
      "Architecte",
      "Conducteur de travaux",
    ],
    mots_cles: ["enstp", "travaux publics", "génie civil", "topographie", "architecture"],
    sources: ["ENSTP", "MINESUP", "MINTP"],
  }),
  etab({
    slug: "ecole-issea",
    titre: "ISSEA (statistique et économie appliquée)",
    categorie: "Grandes écoles",
    niveau: "Bac C / Licence / Master selon le cycle + concours",
    resume:
      "Institut de la CEMAC basé à Yaoundé, qui forme statisticiens et économistes ; ses concours sont communs avec d'autres écoles africaines de statistique.",
    presentation:
      "Les concours des cycles ISE (ingénieurs statisticiens économistes) et AS (adjoints techniques) sont organisés en commun avec d'autres écoles africaines de statistique. Le cycle TSS (techniciens supérieurs) a son propre concours.",
    formations: [
      "Techniciens supérieurs de la statistique (TSS)",
      "Analystes statisticiens (AS)",
      "Ingénieurs statisticiens économistes (ISE)",
      "Licences et masters professionnels",
    ],
    acces:
      "**Concours** annoncés sur le site de l'ISSEA (inscriptions souvent closes en début d'année).",
    conseil:
      "Excellent niveau en mathématiques indispensable ; l'épreuve d'anglais compte pour certains cycles.",
    debouches: ["Statisticien", "Économiste", "Analyste de données", "Actuaire"],
    mots_cles: ["issea", "statistique", "économie", "cemac", "ise", "data"],
    sources: ["ISSEA", "INS"],
  }),
  etab({
    slug: "ecole-enam",
    titre: "ENAM (École Nationale d'Administration et de Magistrature)",
    categorie: "Grandes écoles",
    niveau: "Bac, Licence ou Master selon le cycle + concours",
    resume:
      "Grande école de la fonction publique : administrateurs civils, magistrats, inspecteurs des impôts, du trésor et des douanes, greffiers…",
    presentation:
      "L'ENAM recrute sur concours dans plusieurs divisions. Les inscriptions se font en ligne sur sa plateforme de concours.",
    formations: [
      "Administration générale",
      "Magistrature et greffes",
      "Régies financières : impôts, trésor, douanes",
      "Travail et prévoyance sociale (selon les années)",
    ],
    acces: "**Concours** directs et professionnels, inscription en ligne.",
    conseil:
      "Prépare sérieusement la culture générale et le droit ; méfie-toi de toute offre de « place payée ».",
    debouches: [
      "Administrateur civil",
      "Magistrat",
      "Inspecteur des impôts",
      "Inspecteur des douanes",
    ],
    mots_cles: ["enam", "administration", "magistrature", "fonction publique", "concours"],
    sources: ["ENAM", "ENAM_CONCOURS"],
  }),
  // ---------------------------------------------------- Étudier par région
  ...[
    [
      "centre",
      "Centre",
      "Yaoundé I et Yaoundé II-Soa",
      "UY1, ENSP, ENS, FMSB, ESSTIC, IRIC, ENSTP, ENAM, ISSEA",
      ["UY1", "UNIV_YAOUNDE2", "ENSPY"],
    ],
    [
      "littoral",
      "Littoral",
      "Douala",
      "ENSPD, ENSET, ESSEC, IUT de Douala, FMSP",
      ["UNIV_DOUALA", "ESSEC"],
    ],
    ["ouest", "Ouest", "Dschang", "FASA, IUT Fotso Victor de Bandjoun", ["UNIV_DSCHANG", "FASA"]],
    [
      "sud-ouest",
      "Sud-Ouest",
      "Buea",
      "Faculty of Health Sciences, ASTI, College of Technology",
      ["UNIV_BUEA"],
    ],
    ["nord-ouest", "Nord-Ouest", "Bamenda", "COLTECH, HTTTC, NAHPI", ["UNIV_BAMENDA"]],
    [
      "adamaoua",
      "Adamaoua",
      "Ngaoundéré",
      "ENSAI, ESMV, IUT de Ngaoundéré",
      ["UNIV_NGAOUNDERE", "ENSAI"],
    ],
    [
      "extreme-nord",
      "Extrême-Nord",
      "Maroua",
      "ENS de Maroua, ENSPM, Institut des Mines et des Industries Pétrolières",
      ["UNIV_MAROUA"],
    ],
    [
      "nord",
      "Nord",
      "Garoua (créée en 2022)",
      "nouvelle université en développement ; École de Faune de Garoua (MINFOF)",
      ["UNIV_GAROUA", "MINFOF"],
    ],
    [
      "est",
      "Est",
      "Bertoua (créée en 2022)",
      "nouvelle université en développement",
      ["UNIV_BERTOUA"],
    ],
    [
      "sud",
      "Sud",
      "Ebolowa (créée en 2022)",
      "nouvelle université en développement",
      ["UNIV_EBOLOWA"],
    ],
  ].map(([slug, region, univ, ecoles, sources]) => ({
    slug: `etudier-region-${slug}`,
    titre: `Étudier dans la région ${region === "Extrême-Nord" || region === "Ouest" || region === "Est" || region === "Adamaoua" ? "de l'" + region : "du " + region}`,
    categorie: "Étudier par région",
    niveau_acces: "Après le Bac / GCE A Level",
    resume: `Université d'État de la région : ${univ}. Écoles et instituts publics notables : ${ecoles}.`,
    contenu: `## Université d'État
- ${univ}

## Écoles et instituts publics
- ${ecoles}

## Autres possibilités
- Instituts privés d'enseignement supérieur (IPES) agréés par le MINESUP : BTS, HND, licences
- Centres de formation professionnelle agréés par le MINEFOP
- Lycées techniques et formations courtes

## Conseil
Étudier dans sa région réduit le coût du logement et du transport. Vérifie toujours l'agrément d'un établissement privé avant de payer. ${VERIFIER}`,
    debouches: [],
    formations: [univ],
    mots_cles: [
      region.toLowerCase(),
      "région",
      "étudier près de chez moi",
      "université",
      ...univ.toLowerCase().split(/[ ,]+/),
    ],
    sources: [...sources, "MINESUP", "MINEFOP"],
  })),
];

export { ETABLISSEMENTS };
