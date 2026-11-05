// Contenu de M'Andal'Sup : universités d'État par région, leurs grandes écoles
// (avec le sigle développé), concours nationaux et bourses à l'étranger.
// Présentations reprises des fiches d'orientation ; un lien n'est donné que pour
// une adresse officielle vérifiée, sinon le site de l'université.

export type Ecole = { sigle: string; nom: string; precision: string | null; lien: string | null };
export type Universite = {
  region: string;
  nom: string;
  presentation: string;
  site: string | null;
  ecoles: Ecole[];
};

export const UNIVERSITES: Universite[] = [
  {
    region: "Littoral",
    nom: "Université de Douala",
    presentation:
      "Créée en 1993, l'Université de Douala (Littoral) a hérité de l'ESSEC et de l'ENSET. Elle est très liée au tissu industriel et commercial de Douala.",
    site: "https://www.univ-douala.cm",
    ecoles: [
      {
        sigle: "ENSET",
        nom: "École Normale Supérieure d'Enseignement Technique",
        precision: "1ère et 3e années du premier cycle, second cycle",
        lien: null,
      },
      {
        sigle: "ESSEC",
        nom: "École Supérieure des Sciences Économiques et Commerciales",
        precision: "formation initiale et Études Professionnelles Approfondies",
        lien: "https://essec-douala.cm",
      },
      {
        sigle: "IUT",
        nom: "Institut Universitaire de Technologie",
        precision: "formation initiale, alternance et licence de technologie",
        lien: null,
      },
      {
        sigle: "ENSPD",
        nom: "École Nationale Supérieure Polytechnique de Douala",
        precision: "formation initiale et régime spécial",
        lien: null,
      },
      {
        sigle: "IBA",
        nom: "Institut des Beaux-Arts",
        precision: "1ère, 3e et 4e années",
        lien: null,
      },
      {
        sigle: "ENSAHV",
        nom: "École Nationale Supérieure d'Agronomie, d'Halieutique et de Médecine Vétérinaire",
        precision: "1ère et 4e années",
        lien: null,
      },
    ],
  },
  {
    region: "Centre",
    nom: "Université de Yaoundé I",
    presentation:
      "Située à Yaoundé (Centre), l'Université de Yaoundé I est l'héritière de la première université du pays. Elle regroupe des facultés classiques et plusieurs grandes écoles recrutant sur concours.",
    site: "http://www.uy1.uninet.cm",
    ecoles: [
      {
        sigle: "ENS",
        nom: "École Normale Supérieure",
        precision: "premier et second cycles, classes scientifiques spéciales",
        lien: null,
      },
      {
        sigle: "ENSPY",
        nom: "École Nationale Supérieure Polytechnique de Yaoundé",
        precision: "1ère et 3e années",
        lien: "https://polytechnique.cm",
      },
      {
        sigle: "FALSH",
        nom: "Faculté des Arts, Lettres et Sciences Humaines",
        precision: "cycle de licence professionnelle en tourisme",
        lien: null,
      },
      {
        sigle: "IUT Bois",
        nom: "Institut Universitaire de Technologie du Bois de Mbalmayo",
        precision: null,
        lien: null,
      },
      {
        sigle: "CESSI",
        nom: "Centre d'Enseignements Supérieurs en Soins Infirmiers",
        precision: null,
        lien: null,
      },
      {
        sigle: "FMSB",
        nom: "Faculté de Médecine et des Sciences Biomédicales",
        precision: null,
        lien: null,
      },
    ],
  },
  {
    region: "Centre",
    nom: "Université de Yaoundé II (Soa)",
    presentation:
      "Son campus principal est à Soa, près de Yaoundé. Elle possède aussi des sites à Yaoundé (ESSTIC, IRIC) et des antennes dans d'autres villes.",
    site: "https://site.univ-yaounde2.org",
    ecoles: [
      {
        sigle: "ESSTIC",
        nom: "École Supérieure des Sciences et Techniques de l'Information et de la Communication",
        precision: null,
        lien: null,
      },
      {
        sigle: "IRIC",
        nom: "Institut des Relations Internationales du Cameroun",
        precision:
          "Banque-Monnaie-Finance internationales, Contentieux international, Communication et action publique internationales, Intégration régionale et management des institutions communautaires, Marketing international, Diplomatie, Coopération internationale, action humanitaire et développement durable, Diversité culturelle, développement, paix et sécurité",
        lien: null,
      },
      {
        sigle: "IFORD",
        nom: "Institut de Formation et de Recherche Démographiques",
        precision: null,
        lien: null,
      },
    ],
  },
  {
    region: "Est",
    nom: "Université de Bertoua",
    presentation:
      "Créée en 2022 avec Ebolowa et Garoua, l'Université de Bertoua a repris des écoles et annexes existantes de l'Est. Son offre de formation se développe chaque année.",
    site: null,
    ecoles: [
      {
        sigle: "ENS",
        nom: "École Normale Supérieure",
        precision: "premier et second cycles",
        lien: null,
      },
      {
        sigle: "ISABEE",
        nom: "Institut Supérieur d'Agriculture, du Bois, de l'Eau et de l'Environnement",
        precision: "Bélabo, antenne à Yokadouma",
        lien: "https://isabeeb.cm",
      },
      {
        sigle: "ESSUT",
        nom: "École Supérieure des Sciences de l'Urbanisme et du Tourisme",
        precision: "Abong-Mbang",
        lien: "https://essut-ube.cm",
      },
      {
        sigle: "ESTM",
        nom: "École Supérieure de Transformation des Mines et des Ressources Énergétiques",
        precision: "Batouri",
        lien: "https://estm-ube.cm",
      },
    ],
  },
  {
    region: "Sud",
    nom: "Université d'Ebolowa",
    presentation:
      "Créée en 2022 en même temps que Bertoua et Garoua, l'Université d'Ebolowa rapproche l'enseignement supérieur des étudiants de la région du Sud.",
    site: null,
    ecoles: [
      {
        sigle: "ENSET",
        nom: "École Normale Supérieure d'Enseignement Technique",
        precision: "premier et second cycles",
        lien: null,
      },
      {
        sigle: "ISABEE",
        nom: "Institut Supérieur d'Agriculture, du Bois, de l'Eau et de l'Environnement",
        precision: "Ebolowa",
        lien: "https://www.isabeee.cm",
      },
      {
        sigle: "ENSTMO",
        nom: "École Nationale Supérieure des Sciences et Techniques Maritimes et Océaniques",
        precision: "Kribi",
        lien: "https://enstmo-ueb.cm",
      },
      {
        sigle: "ESTLC",
        nom: "École Supérieure de Transport, de Logistique et de Commerce",
        precision: "Ambam, cursus d'ingénieur",
        lien: "https://estlc.unv-ebolowa.cm",
      },
      {
        sigle: "FS",
        nom: "Faculté des Sciences",
        precision:
          "licence en sciences économiques appliquées à l'agriculture ; sciences biomédicales et médico-sanitaires ; master en sciences biomédicales et médico-sanitaires",
        lien: null,
      },
    ],
  },
  {
    region: "Extrême-Nord",
    nom: "Université de Maroua",
    presentation:
      "Créée par décret en 2008, l'Université de Maroua compte plusieurs établissements, dont l'ENS de Maroua, l'École Nationale Supérieure Polytechnique de Maroua, l'Institut des Mines et des Industries Pétrolières et l'Institut Supérieur du Sahel.",
    site: "http://www.univ-maroua.cm",
    ecoles: [
      {
        sigle: "ENS",
        nom: "École Normale Supérieure",
        precision: "premier et second cycles",
        lien: null,
      },
      {
        sigle: "ENSPM",
        nom: "École Nationale Supérieure Polytechnique de Maroua",
        precision: "1ère et 3e années",
        lien: null,
      },
      {
        sigle: "ENSMIP",
        nom: "École Nationale Supérieure des Mines et des Industries Pétrolières",
        precision: "Kaélé",
        lien: "http://www.ensmip.univ-maroua.cm",
      },
    ],
  },
  {
    region: "Nord",
    nom: "Université de Garoua",
    presentation:
      "Créée en 2022 avec Bertoua et Ebolowa, l'Université de Garoua renforce l'offre universitaire dans la région du Nord.",
    site: null,
    ecoles: [
      {
        sigle: "ESSEC",
        nom: "École Supérieure des Sciences Économiques et Commerciales",
        precision: null,
        lien: null,
      },
      {
        sigle: "FMSB",
        nom: "Faculté de Médecine et des Sciences Biomédicales de Garoua",
        precision: null,
        lien: null,
      },
      {
        sigle: "IBAI",
        nom: "Institut des Beaux-Arts et de l'Innovation",
        precision: null,
        lien: null,
      },
    ],
  },
  {
    region: "Adamaoua",
    nom: "Université de Ngaoundéré",
    presentation:
      "Issue du Centre universitaire de Ngaoundéré (1982), elle est devenue université en 1993. Elle compte une dizaine d'établissements et plus d'une centaine de formations.",
    site: "https://www.univ-ndere.cm",
    ecoles: [
      {
        sigle: "ESMV",
        nom: "École des Sciences et de Médecine Vétérinaire",
        precision: "filière Docteurs en médecine vétérinaire",
        lien: "https://esmv.univ-ndere.cm",
      },
      {
        sigle: "IUT",
        nom: "Institut Universitaire de Technologie",
        precision: "formation initiale et cursus du BTS",
        lien: null,
      },
      {
        sigle: "ENSAI",
        nom: "École Nationale Supérieure des Sciences Agro-Industrielles",
        precision: null,
        lien: "https://ensai.univ-ndere.cm",
      },
      {
        sigle: "EGEM",
        nom: "École de Géologie et d'Exploitation Minière",
        precision: "cycle ingénieur — Meiganga",
        lien: "https://egem-ndere.com",
      },
      {
        sigle: "Sciences biomédicales",
        nom: "Filières Sciences biomédicales",
        precision: null,
        lien: null,
      },
      {
        sigle: "EGCIM",
        nom: "École de Génie Chimique et des Industries Minérales",
        precision: null,
        lien: "https://egcim-univ-ndere.cm",
      },
    ],
  },
  {
    region: "Ouest",
    nom: "Université de Dschang",
    presentation:
      "Issue d'un centre universitaire agricole fondé en 1977, l'Université de Dschang (Ouest) est devenue une université complète en 1993. Elle a des campus et annexes dans plusieurs villes.",
    site: "https://www.univ-dschang.org",
    ecoles: [
      {
        sigle: "CRESA",
        nom: "Centre Régional d'Enseignement Spécialisé en Agriculture Forêt-Bois",
        precision: "Nkolbisson, Yaoundé",
        lien: null,
      },
      {
        sigle: "IBAF",
        nom: "Institut des Beaux-Arts de Foumban",
        precision: "1ère année",
        lien: null,
      },
      {
        sigle: "FASA",
        nom: "Faculté d'Agronomie et des Sciences Agricoles",
        precision: "cycle des ingénieurs",
        lien: "https://www.univ-dschang.org/fasa/",
      },
      {
        sigle: "Sciences biomédicales",
        nom: "Filières Sciences biomédicales",
        precision: null,
        lien: null,
      },
      {
        sigle: "IUT-FV",
        nom: "IUT Fotso Victor de Bandjoun",
        precision: "1ère année et cursus BTS formation permanente",
        lien: null,
      },
    ],
  },
  {
    region: "Nord-Ouest",
    nom: "Université de Bamenda",
    presentation:
      "Created by decree in December 2010 on the Bambili site, the University of Bamenda teaches mainly in English.",
    site: "https://uniba.cm",
    ecoles: [
      {
        sigle: "HTTC",
        nom: "Higher Teacher Training College de Bambili",
        precision: "premier et second cycles",
        lien: null,
      },
      {
        sigle: "HTTTC",
        nom: "Higher Technical Teacher Training College de Bambili",
        precision: "premier et second cycles",
        lien: null,
      },
      {
        sigle: "FHS",
        nom: "Faculté des sciences de la santé",
        precision: "sciences infirmières et laboratoire médical",
        lien: null,
      },
      {
        sigle: "HICM",
        nom: "Higher Institute of Commerce and Management",
        precision: null,
        lien: null,
      },
      {
        sigle: "COLTECH",
        nom: "College of Technology",
        precision: null,
        lien: null,
      },
      {
        sigle: "HITL",
        nom: "Higher Institute of Transport and Logistics",
        precision: null,
        lien: null,
      },
      {
        sigle: "NHPI",
        nom: "National Higher Polytechnic Institute",
        precision: null,
        lien: null,
      },
    ],
  },
  {
    region: "Sud-Ouest",
    nom: "Université de Buea",
    presentation:
      "Founded as a university centre in 1985 and chartered as a full university in the early 1990s, the University of Buea (South West Region) teaches mainly in English and offers about 80 degree programmes.",
    site: "https://www.ubuea.cm",
    ecoles: [
      {
        sigle: "FET",
        nom: "Faculty of Engineering and Technology",
        precision: null,
        lien: null,
      },
      {
        sigle: "COT",
        nom: "College of Technology",
        precision: null,
        lien: null,
      },
      {
        sigle: "HTTTC",
        nom: "Higher Technical Teacher Training College de Kumba",
        precision: null,
        lien: null,
      },
      {
        sigle: "FHS",
        nom: "Faculty of Health Sciences",
        precision: null,
        lien: null,
      },
    ],
  },
];

export const CONCOURS_NATIONAUX: { tutelle: string; contenu: string }[] = [
  {
    tutelle: "MINESUP",
    contenu:
      "Examen national de synthèse clinique et thérapeutique ; examen national d'aptitude à la formation médicale, pharmaceutique et odontostomatologique ; examen national de spécialisation (internat).",
  },
  {
    tutelle: "MINESUP / MINTP",
    contenu:
      "École Nationale Supérieure des Travaux Publics (ENSTP) : techniciens supérieurs, ingénieurs en génie civil, génie de l'environnement, génie rural, topographie et cadastre, urbanisme et architecture.",
  },
  {
    tutelle: "MINESUP / MINPOSTEL",
    contenu:
      "Ingénieurs des travaux, inspecteurs, contrôleurs, techniciens et administrateurs des postes et télécommunications.",
  },
  {
    tutelle: "MINESUP / MINEPIA",
    contenu: "Limbe Nautical Arts and Fisheries Institute (LINAFI).",
  },
];

export const BOURSES: {
  pays: string;
  drapeau: string;
  programmes: { nom: string; lien: string }[];
}[] = [
  {
    pays: "France",
    drapeau: "🇫🇷",
    programmes: [
      {
        nom: "Campus France Cameroun (bourses du gouvernement français)",
        lien: "https://www.cameroun.campusfrance.org",
      },
      {
        nom: "Bourses d'excellence Eiffel (master, doctorat)",
        lien: "https://www.campusfrance.org/fr/eiffel",
      },
    ],
  },
  {
    pays: "Australie",
    drapeau: "🇦🇺",
    programmes: [
      {
        nom: "Australia Awards",
        lien: "https://www.dfat.gov.au/people-to-people/australia-awards",
      },
    ],
  },
  {
    pays: "Luxembourg",
    drapeau: "🇱🇺",
    programmes: [
      {
        nom: "Université du Luxembourg (bourses Guillaume Dupaix et autres aides)",
        lien: "https://www.uni.lu",
      },
    ],
  },
  {
    pays: "Canada",
    drapeau: "🇨🇦",
    programmes: [
      {
        nom: "ÉduCanada — bourses du gouvernement du Canada",
        lien: "https://www.educanada.ca/scholarships-bourses/index.aspx?lang=fra",
      },
    ],
  },
  {
    pays: "Espagne",
    drapeau: "🇪🇸",
    programmes: [
      { nom: "Bourses MAEC-AECID (coopération espagnole)", lien: "https://www.aecid.gob.es" },
    ],
  },
  {
    pays: "Allemagne",
    drapeau: "🇩🇪",
    programmes: [
      { nom: "DAAD — Office allemand d'échanges universitaires", lien: "https://www.daad.de" },
    ],
  },
  {
    pays: "États-Unis",
    drapeau: "🇺🇸",
    programmes: [
      {
        nom: "Programme Fulbright (étudiants étrangers)",
        lien: "https://foreign.fulbrightonline.org",
      },
      { nom: "EducationUSA (orientation officielle)", lien: "https://educationusa.state.gov" },
    ],
  },
  {
    pays: "Belgique",
    drapeau: "🇧🇪",
    programmes: [
      { nom: "ARES — bourses de coopération (Wallonie-Bruxelles)", lien: "https://www.ares-ac.be" },
      { nom: "VLIR-UOS — bourses (Flandre)", lien: "https://www.vliruos.be" },
    ],
  },
  {
    pays: "Royaume-Uni",
    drapeau: "🇬🇧",
    programmes: [
      { nom: "Bourses Chevening", lien: "https://www.chevening.org" },
      { nom: "Commonwealth Scholarships", lien: "https://cscuk.fcdo.gov.uk" },
    ],
  },
];
