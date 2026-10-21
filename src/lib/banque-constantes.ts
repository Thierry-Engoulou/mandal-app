// Constantes et analyse des informations d'une épreuve (sans dépendance :
// utilisables dans le navigateur comme sur le serveur).

export const BANQUE_BUCKET = "banque-epreuves";
export const TAILLE_MAX = 25 * 1024 * 1024;

export const TYPES_EXAMEN = [
  "BEPC",
  "CAP",
  "Probatoire",
  "Baccalauréat",
  "Brevet de technicien (BT)",
  "GCE O Level",
  "GCE A Level",
  "Concours",
  "Examen blanc / Mock",
  "Séquence / Devoir",
  "Autre",
] as const;

export const CLASSES = [
  "6ème",
  "5ème",
  "4ème",
  "3ème",
  "2nde",
  "1ère",
  "Terminale",
  "Form 1",
  "Form 2",
  "Form 3",
  "Form 4",
  "Form 5",
  "Lower Sixth",
  "Upper Sixth",
  "Supérieur / Concours",
] as const;

export const MATIERES_BANQUE = [
  "Mathématiques",
  "Physique",
  "Chimie",
  "PCT (Physique-Chimie-Technologie)",
  "SVT",
  "Français",
  "Anglais",
  "Histoire-Géographie",
  "ECM (Éducation civique)",
  "Philosophie",
  "Informatique",
  "Économie",
  "Comptabilité",
  "Allemand",
  "Espagnol",
  "Littérature",
  "Biology",
  "Chemistry",
  "Physics",
  "Further Mathematics",
  "English Language",
  "Literature in English",
  "Geography",
  "History",
  "Economics",
  "Computer Science",
  "Culture générale",
  "Autre",
] as const;

export const SERIES = [
  "A",
  "A1",
  "A2",
  "A3",
  "A4",
  "A5",
  "C",
  "D",
  "E",
  "TI",
  "F1",
  "F2",
  "F3",
  "F4",
  "F5",
  "F7",
  "F8",
  "G1",
  "G2",
  "G3",
  "Arts",
  "Science",
  "Commercial",
] as const;

/** Classe correspondant au niveau des épreuves blanches (lib/epreuves NIVEAUX). */
export const CLASSES_PAR_NIVEAU: Record<string, string[]> = {
  "6ème": ["6ème", "Form 1"],
  "5ème": ["5ème", "Form 2"],
  "4ème": ["4ème", "Form 3"],
  "3ème / BEPC": ["3ème", "Form 4"],
  "2nde": ["2nde"],
  "1ère / Probatoire": ["1ère"],
  "Terminale / Baccalauréat": ["Terminale"],
  "GCE O Level": ["Form 5"],
  "GCE A Level": ["Lower Sixth", "Upper Sixth"],
  Concours: ["Supérieur / Concours"],
};

const CLASSE_PAR_TYPE: Partial<Record<string, string>> = {
  BEPC: "3ème",
  CAP: "3ème",
  Probatoire: "1ère",
  Baccalauréat: "Terminale",
  "Brevet de technicien (BT)": "Terminale",
  "GCE O Level": "Form 5",
  "GCE A Level": "Upper Sixth",
  Concours: "Supérieur / Concours",
};

export const SOURCE_PAR_TYPE: Partial<Record<string, string>> = {
  BEPC: "MINESEC — examens officiels",
  CAP: "MINESEC — examens officiels",
  Probatoire: "MINESEC — examens officiels",
  Baccalauréat: "Office du Baccalauréat du Cameroun (OBC)",
  "Brevet de technicien (BT)": "Office du Baccalauréat du Cameroun (OBC)",
  "GCE O Level": "Cameroon GCE Board",
  "GCE A Level": "Cameroon GCE Board",
};

export type MetaEpreuve = {
  titre: string;
  matiere: string;
  classe: string;
  serie: string;
  type_examen: string;
  annee: string;
  session: string;
  source: string;
  description: string;
};

export const META_VIDE: MetaEpreuve = {
  titre: "",
  matiere: "",
  classe: "",
  serie: "",
  type_examen: "",
  annee: "",
  session: "",
  source: "",
  description: "",
};

/** Titre lisible à partir des informations : « Baccalauréat D 2023 — Mathématiques ». */
export function titreAuto(
  m: Pick<MetaEpreuve, "type_examen" | "serie" | "annee" | "matiere" | "classe">,
) {
  const examen =
    m.type_examen === "Séquence / Devoir"
      ? [m.classe ? `Devoir de ${m.classe}` : "Devoir", m.annee]
      : [m.type_examen, m.serie, m.annee];
  return [examen.filter(Boolean).join(" "), m.matiere].filter(Boolean).join(" — ");
}

export const sansAccents = (t: string) => t.normalize("NFD").replace(/[̀-ͯ]/g, "");

const MOTS_MATIERE: Array<[RegExp, string]> = [
  [/\b(further ?math|fmath)/, "Further Mathematics"],
  [/\b(maths?|mathematiques?|mathematics)\b/, "Mathématiques"],
  [/\bpct\b/, "PCT (Physique-Chimie-Technologie)"],
  [/\b(physique|phys)\b/, "Physique"],
  [/\bphysics\b/, "Physics"],
  [/\bchimie\b/, "Chimie"],
  [/\bchemistry\b/, "Chemistry"],
  [/\b(svt|svteeh|biologie)\b/, "SVT"],
  [/\bbiology\b/, "Biology"],
  [/\b(francais|french)\b/, "Français"],
  [/\b(english ?language)\b/, "English Language"],
  [/\b(anglais|english)\b/, "Anglais"],
  [/\b(histoire|geographie|hist|geo)\b/, "Histoire-Géographie"],
  [/\b(ecm|civique)\b/, "ECM (Éducation civique)"],
  [/\b(philo|philosophie)\b/, "Philosophie"],
  [/\b(informatique|info)\b/, "Informatique"],
  [/\bcomputer\b/, "Computer Science"],
  [/\b(economie|eco)\b/, "Économie"],
  [/\beconomics\b/, "Economics"],
  [/\b(compta|comptabilite)\b/, "Comptabilité"],
  [/\ballemand\b/, "Allemand"],
  [/\bespagnol\b/, "Espagnol"],
];

const MOTS_CLASSE: Array<[RegExp, string]> = [
  [/\b(6e|6eme|sixieme)\b/, "6ème"],
  [/\b(5e|5eme|cinquieme)\b/, "5ème"],
  [/\b(4e|4eme|quatrieme)\b/, "4ème"],
  [/\b(3e|3eme|troisieme)\b/, "3ème"],
  [/\b(2nde|seconde|2nd)\b/, "2nde"],
  [/\b(1ere|premiere|1re)\b/, "1ère"],
  [/\b(tle|terminale|tale)\b/, "Terminale"],
  [/\bform ?([1-5])\b/, "Form $1"],
  [/\b(lower ?sixth|lsix)\b/, "Lower Sixth"],
  [/\b(upper ?sixth|usix)\b/, "Upper Sixth"],
];

const MOTS_TYPE: Array<[RegExp, string]> = [
  [/\b(gce ?a ?l(evel)?|a ?level|al)\b/, "GCE A Level"],
  [/\b(gce ?o ?l(evel)?|o ?level|ol)\b/, "GCE O Level"],
  [/\b(bac|baccalaureat)\b/, "Baccalauréat"],
  [/\b(proba|probatoire)\b/, "Probatoire"],
  [/\bbepc\b/, "BEPC"],
  [/\bcap\b/, "CAP"],
  [/\bconcours\b/, "Concours"],
  [/\b(mock|blanc)\b/, "Examen blanc / Mock"],
  [/\b(sequence|seq|devoir)\b/, "Séquence / Devoir"],
];

/** Devine les informations d'une épreuve à partir du nom de son fichier
 *  (ex. « BAC_D_2023_Maths.pdf », « Probatoire C 2019 physique.jpg »). */
export function devinerDepuisNom(nomFichier: string): MetaEpreuve {
  const base = nomFichier.replace(/\.[a-z0-9]+$/i, "");
  const texte = sansAccents(base.toLowerCase()).replace(/[_\-.]+/g, " ");
  const jetons = base.replace(/[_\-.]+/g, " ").split(/\s+/);

  const type = MOTS_TYPE.find(([re]) => re.test(texte))?.[1] ?? "";
  const matiere = MOTS_MATIERE.find(([re]) => re.test(texte))?.[1] ?? "";
  const annee = texte.match(/\b(19[6-9]\d|20\d\d)\b/)?.[1] ?? "";
  const serieJeton =
    type === "Baccalauréat" || type === "Probatoire" || type === "Brevet de technicien (BT)"
      ? jetons.find((j) => (SERIES as readonly string[]).includes(j.toUpperCase()) && j.length <= 2)
      : undefined;
  const serie = serieJeton ? serieJeton.toUpperCase() : "";
  let classe = "";
  for (const [re, valeur] of MOTS_CLASSE) {
    const m = texte.match(re);
    if (m) {
      classe = valeur.replace("$1", m[1] ?? "");
      break;
    }
  }
  classe ||= CLASSE_PAR_TYPE[type] ?? "";
  const meta: MetaEpreuve = {
    ...META_VIDE,
    matiere,
    type_examen: type,
    annee,
    serie,
    classe,
    source: SOURCE_PAR_TYPE[type] ?? "",
  };
  meta.titre = matiere && type ? titreAuto(meta) : base.replace(/[_]+/g, " ").trim();
  return meta;
}

/** Problème bloquant pour publier, ou null si tout est rempli. */
export function metaIncomplete(m: MetaEpreuve): string | null {
  if (m.titre.trim().length < 3) return "Titre manquant";
  if (!m.matiere) return "Matière manquante";
  if (!m.classe) return "Classe manquante";
  if (!m.type_examen) return "Type d'examen manquant";
  if (m.annee && !/^(19[6-9]\d|20\d\d)$/.test(m.annee)) return "Année invalide";
  return null;
}
