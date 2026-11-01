/** Un SGBD miniature pour les simulations d'Informatique de Terminale.
 *  Il accepte le SQL du programme camerounais, et surtout il refuse les
 *  requêtes fautives avec le message qu'un vrai moteur donnerait. */

export type Val = string | number | null;
export type Ligne = Record<string, Val>;

export type Col = {
  nom: string;
  type: string;
  pk?: boolean;
  notNull?: boolean;
  fk?: { table: string; col: string };
  /** Règle de validation, par exemple une note entre 0 et 20. */
  check?: { min?: number; max?: number; texte: string };
};

export type Table = { nom: string; cols: Col[]; lignes: Ligne[] };
export type Base = Table[];

export type Resultat = {
  base: Base;
  ok: boolean;
  message: string;
  /** Pour un SELECT. */
  sortie?: { cols: string[]; lignes: Ligne[]; sources: number[] };
  /** Nombre de lignes qu'un UPDATE ou un DELETE sans WHERE toucherait. */
  avertissement?: string;
};

function copier(base: Base): Base {
  return base.map((t) => ({
    nom: t.nom,
    cols: t.cols.map((c) => ({ ...c })),
    lignes: t.lignes.map((l) => ({ ...l })),
  }));
}

function trouver(base: Base, nom: string): Table | undefined {
  return base.find((t) => t.nom.toUpperCase() === nom.toUpperCase());
}

/** Découpe une liste séparée par des virgules, en respectant les parenthèses. */
function decouperVirgules(s: string): string[] {
  const out: string[] = [];
  let p = 0;
  let cur = "";
  let dansChaine = false;
  for (const c of s) {
    if (c === "'") dansChaine = !dansChaine;
    if (!dansChaine) {
      if (c === "(") p++;
      if (c === ")") p--;
      if (c === "," && p === 0) {
        out.push(cur.trim());
        cur = "";
        continue;
      }
    }
    cur += c;
  }
  if (cur.trim() !== "") out.push(cur.trim());
  return out;
}

function litteral(s: string): Val {
  const t = s.trim();
  if (/^null$/i.test(t)) return null;
  if (/^'.*'$/s.test(t)) return t.slice(1, -1).replace(/''/g, "'");
  const n = Number(t.replace(",", "."));
  if (!Number.isNaN(n) && t !== "") return n;
  return t;
}

/* ------------------------------------------------------------------ */
/* Évaluation d'une condition WHERE                                    */
/* ------------------------------------------------------------------ */

type Ctx = Record<string, Val>;

function valeurDe(expr: string, ctx: Ctx): Val {
  const t = expr.trim();
  const sansTable = t.includes(".") ? (t.split(".")[1] ?? t) : t;
  const cle = Object.keys(ctx).find(
    (k) => k.toUpperCase() === t.toUpperCase() || k.toUpperCase() === sansTable.toUpperCase(),
  );
  if (cle !== undefined) return ctx[cle] ?? null;
  return litteral(t);
}

function comparer(a: Val, op: string, b: Val): boolean {
  if (a === null || b === null) return false;
  if (typeof a === "number" && typeof b === "number") {
    if (op === "=") return a === b;
    if (op === "<>" || op === "!=") return a !== b;
    if (op === "<") return a < b;
    if (op === ">") return a > b;
    if (op === "<=") return a <= b;
    return a >= b;
  }
  const x = String(a).toUpperCase();
  const y = String(b).toUpperCase();
  if (op === "=") return x === y;
  if (op === "<>" || op === "!=") return x !== y;
  if (op === "<") return x < y;
  if (op === ">") return x > y;
  if (op === "<=") return x <= y;
  return x >= y;
}

function commeLike(v: Val, motif: string): boolean {
  if (v === null) return false;
  const m = motif
    .replace(/[.*+?^${}()|[\]\\]/g, "\\$&")
    .replace(/%/g, ".*")
    .replace(/_/g, ".");
  return new RegExp(`^${m}$`, "i").test(String(v));
}

/** Analyse récursive : OR < AND < NOT < comparaison. */
export function evaluerCondition(cond: string, ctx: Ctx): boolean {
  const s = cond.trim();
  if (s === "") return true;

  // OR au niveau le plus haut
  const morceaux = (texte: string, mot: string): string[] | null => {
    let p = 0;
    let dansChaine = false;
    const parts: string[] = [];
    let cur = "";
    let i = 0;
    while (i < texte.length) {
      const c = texte[i] ?? "";
      if (c === "'") dansChaine = !dansChaine;
      if (!dansChaine) {
        if (c === "(") p++;
        if (c === ")") p--;
        if (p === 0) {
          const suite = texte.slice(i).toUpperCase();
          if (suite.startsWith(` ${mot} `)) {
            parts.push(cur);
            cur = "";
            i += mot.length + 2;
            continue;
          }
        }
      }
      cur += c;
      i++;
    }
    if (parts.length === 0) return null;
    parts.push(cur);
    return parts;
  };

  const ou = morceaux(s, "OR");
  if (ou) return ou.some((x) => evaluerCondition(x, ctx));
  const et = morceaux(s, "AND");
  if (et) return et.every((x) => evaluerCondition(x, ctx));

  if (/^\(.*\)$/s.test(s)) {
    // ne retirer les parenthèses que si elles encadrent toute l'expression
    let p = 0;
    let global = true;
    for (let i = 0; i < s.length; i++) {
      if (s[i] === "(") p++;
      if (s[i] === ")") p--;
      if (p === 0 && i < s.length - 1) {
        global = false;
        break;
      }
    }
    if (global) return evaluerCondition(s.slice(1, -1), ctx);
  }

  if (/^NOT\s+/i.test(s)) return !evaluerCondition(s.replace(/^NOT\s+/i, ""), ctx);

  let m = /^(.+?)\s+IS\s+NOT\s+NULL$/i.exec(s);
  if (m) return valeurDe(m[1] ?? "", ctx) !== null;
  m = /^(.+?)\s+IS\s+NULL$/i.exec(s);
  if (m) return valeurDe(m[1] ?? "", ctx) === null;

  m = /^(.+?)\s+BETWEEN\s+(.+?)\s+AND\s+(.+)$/i.exec(s);
  if (m) {
    const v = valeurDe(m[1] ?? "", ctx);
    const a = valeurDe(m[2] ?? "", ctx);
    const b = valeurDe(m[3] ?? "", ctx);
    return comparer(v, ">=", a) && comparer(v, "<=", b);
  }

  m = /^(.+?)\s+NOT\s+IN\s*\((.+)\)$/i.exec(s);
  if (m) {
    const v = valeurDe(m[1] ?? "", ctx);
    return !decouperVirgules(m[2] ?? "").some((x) => comparer(v, "=", litteral(x)));
  }
  m = /^(.+?)\s+IN\s*\((.+)\)$/i.exec(s);
  if (m) {
    const v = valeurDe(m[1] ?? "", ctx);
    return decouperVirgules(m[2] ?? "").some((x) => comparer(v, "=", litteral(x)));
  }

  m = /^(.+?)\s+NOT\s+LIKE\s+'(.*)'$/i.exec(s);
  if (m) return !commeLike(valeurDe(m[1] ?? "", ctx), m[2] ?? "");
  m = /^(.+?)\s+LIKE\s+'(.*)'$/i.exec(s);
  if (m) return commeLike(valeurDe(m[1] ?? "", ctx), m[2] ?? "");

  m = /^(.+?)\s*(<>|!=|<=|>=|=|<|>)\s*(.+)$/.exec(s);
  if (m) {
    return comparer(valeurDe(m[1] ?? "", ctx), m[2] ?? "=", valeurDe(m[3] ?? "", ctx));
  }

  return false;
}

/* ------------------------------------------------------------------ */
/* Contrôle des contraintes avant écriture                             */
/* ------------------------------------------------------------------ */

function verifier(base: Base, t: Table, ligne: Ligne, ignorer?: Ligne): string | null {
  for (const c of t.cols) {
    const v = ligne[c.nom] ?? null;

    if ((c.pk || c.notNull) && (v === null || v === "")) {
      return c.pk
        ? `ERREUR 1048 — la colonne « ${c.nom} » est clé primaire : elle ne peut pas être vide.`
        : `ERREUR 1048 — la colonne « ${c.nom} » est déclarée NOT NULL : elle ne peut pas être vide.`;
    }

    if (c.pk && v !== null) {
      const double = t.lignes.some((l) => l !== ignorer && String(l[c.nom]) === String(v));
      if (double) {
        return `ERREUR 1062 — doublon « ${String(v)} » pour la clé primaire ${c.nom}. Une clé primaire est unique.`;
      }
    }

    if (c.fk && v !== null && v !== "") {
      const cible = trouver(base, c.fk.table);
      if (!cible) {
        return `ERREUR 1452 — la table référencée ${c.fk.table} n'existe pas.`;
      }
      const existe = cible.lignes.some((l) => String(l[c.fk?.col ?? ""]) === String(v));
      if (!existe) {
        return `ERREUR 1452 — contrainte de clé étrangère : la valeur ${String(v)} de ${c.nom} n'existe pas dans ${c.fk.table}(${c.fk.col}).`;
      }
    }

    if (c.check && typeof v === "number") {
      if (
        (c.check.min !== undefined && v < c.check.min) ||
        (c.check.max !== undefined && v > c.check.max)
      ) {
        return `ERREUR 3819 — règle de validation violée sur ${c.nom} : ${c.check.texte}`;
      }
    }

    if (/^(INT|NUMBER|DECIMAL|FLOAT)/i.test(c.type) && v !== null && v !== "") {
      if (typeof v === "string" && Number.isNaN(Number(v.replace(",", ".")))) {
        return `ERREUR 1366 — valeur « ${v} » incorrecte pour la colonne ${c.nom} de type ${c.type}.`;
      }
    }
  }
  return null;
}

/* ------------------------------------------------------------------ */
/* Exécution d'une requête                                             */
/* ------------------------------------------------------------------ */

export function executer(base0: Base, sqlBrut: string, confirme = false): Resultat {
  const base = copier(base0);
  const sql = sqlBrut.trim().replace(/;\s*$/, "").replace(/\s+/g, " ");

  if (sql === "") return { base, ok: false, message: "Requête vide." };

  if (
    !/;\s*$/.test(sqlBrut.trim()) &&
    /^(CREATE|INSERT|UPDATE|DELETE|DROP|ALTER|SELECT)/i.test(sql)
  ) {
    // Le point-virgule manquant n'est pas une faute dans toutes les interfaces :
    // on le signale sans refuser la requête.
  }

  /* ---- CREATE TABLE ---- */
  let m = /^CREATE TABLE (?:IF NOT EXISTS )?(\w+)\s*\((.*)\)$/is.exec(sql);
  if (m) {
    const nom = m[1] ?? "";
    if (trouver(base, nom)) {
      return { base, ok: false, message: `ERREUR 1050 — la table ${nom} existe déjà.` };
    }
    const defs = decouperVirgules(m[2] ?? "");
    if (defs.some((d) => d === "")) {
      return {
        base,
        ok: false,
        message:
          "Erreur de syntaxe : une virgule n'est suivie de rien. C'est la virgule de trop après la dernière colonne — la faute la plus fréquente du CREATE TABLE.",
      };
    }
    const cols: Col[] = [];
    let pkDeclaree: string[] = [];
    const fks: { col: string; table: string; cible: string }[] = [];

    for (const d of defs) {
      const pk = /^PRIMARY KEY\s*\((.+)\)$/i.exec(d);
      if (pk) {
        pkDeclaree = decouperVirgules(pk[1] ?? "").map((x) => x.trim());
        continue;
      }
      const fk = /^FOREIGN KEY\s*\((\w+)\)\s*REFERENCES\s+(\w+)\s*\((\w+)\)$/i.exec(d);
      if (fk) {
        fks.push({ col: fk[1] ?? "", table: fk[2] ?? "", cible: fk[3] ?? "" });
        continue;
      }
      const cm = /^(\w+)\s+([A-Za-z]+(?:\s*\(\s*\d+(?:\s*,\s*\d+)?\s*\))?)(.*)$/i.exec(d);
      if (!cm) {
        return { base, ok: false, message: `Erreur de syntaxe près de « ${d} ».` };
      }
      const reste = (cm[3] ?? "").toUpperCase();
      const col: Col = { nom: cm[1] ?? "", type: (cm[2] ?? "").replace(/\s+/g, "") };
      if (reste.includes("PRIMARY KEY")) col.pk = true;
      if (reste.includes("NOT NULL")) col.notNull = true;
      const ref = /REFERENCES\s+(\w+)\s*\((\w+)\)/i.exec(cm[3] ?? "");
      if (ref) col.fk = { table: ref[1] ?? "", col: ref[2] ?? "" };
      cols.push(col);
    }

    for (const p of pkDeclaree) {
      const c = cols.find((x) => x.nom.toUpperCase() === p.toUpperCase());
      if (!c) {
        return {
          base,
          ok: false,
          message: `ERREUR 1072 — la colonne ${p} de la clé primaire n'existe pas dans la table.`,
        };
      }
      c.pk = true;
    }
    for (const f of fks) {
      const c = cols.find((x) => x.nom.toUpperCase() === f.col.toUpperCase());
      if (!c) {
        return { base, ok: false, message: `ERREUR 1072 — la colonne ${f.col} n'existe pas.` };
      }
      if (!trouver(base, f.table)) {
        return {
          base,
          ok: false,
          message: `ERREUR 1824 — la table ${f.table} n'existe pas encore. Une table référencée doit être créée AVANT celle qui la référence.`,
        };
      }
      c.fk = { table: f.table, col: f.cible };
    }

    if (!cols.some((c) => c.pk)) {
      return {
        base,
        ok: false,
        message:
          "Table refusée : aucune clé primaire. Elle serait techniquement créée par MySQL, mais le programme et le correcteur l'exigent — sans clé primaire, rien n'empêche les doublons.",
      };
    }

    base.push({ nom, cols, lignes: [] });
    return { base, ok: true, message: `Table ${nom} créée, ${cols.length} colonnes.` };
  }

  /* ---- DROP TABLE ---- */
  m = /^DROP TABLE (?:IF EXISTS )?(\w+)$/i.exec(sql);
  if (m) {
    const nom = m[1] ?? "";
    const t = trouver(base, nom);
    if (!t) return { base, ok: false, message: `ERREUR 1051 — table ${nom} inconnue.` };
    const dependante = base.find(
      (x) => x !== t && x.cols.some((c) => c.fk && c.fk.table.toUpperCase() === nom.toUpperCase()),
    );
    if (dependante) {
      return {
        base,
        ok: false,
        message: `ERREUR 3730 — impossible de supprimer ${nom} : la table ${dependante.nom} la référence par une clé étrangère. Supprime d'abord ${dependante.nom}, ou sa contrainte.`,
      };
    }
    return {
      base: base.filter((x) => x !== t),
      ok: true,
      message: `Table ${nom} supprimée — structure et données. Rien ne se récupère.`,
    };
  }

  /* ---- ALTER TABLE ---- */
  m = /^ALTER TABLE (\w+) ADD(?: COLUMN)? (\w+) ([A-Za-z]+(?:\s*\(\s*\d+\s*\))?)(.*)$/i.exec(sql);
  if (m) {
    const t = trouver(base, m[1] ?? "");
    if (!t) return { base, ok: false, message: `ERREUR 1146 — table ${m[1]} inconnue.` };
    const nomCol = m[2] ?? "";
    if (t.cols.some((c) => c.nom.toUpperCase() === nomCol.toUpperCase())) {
      return { base, ok: false, message: `ERREUR 1060 — la colonne ${nomCol} existe déjà.` };
    }
    t.cols.push({ nom: nomCol, type: (m[3] ?? "").replace(/\s+/g, "") });
    t.lignes.forEach((l) => {
      l[nomCol] = null;
    });
    return {
      base,
      ok: true,
      message: `Colonne ${nomCol} ajoutée à ${t.nom}. Les ${t.lignes.length} lignes existantes la reçoivent à NULL — ALTER touche la STRUCTURE, pas les données.`,
    };
  }

  m = /^ALTER TABLE (\w+) DROP(?: COLUMN)? (\w+)$/i.exec(sql);
  if (m) {
    const t = trouver(base, m[1] ?? "");
    if (!t) return { base, ok: false, message: `ERREUR 1146 — table ${m[1]} inconnue.` };
    const nomCol = m[2] ?? "";
    const c = t.cols.find((x) => x.nom.toUpperCase() === nomCol.toUpperCase());
    if (!c) return { base, ok: false, message: `ERREUR 1091 — colonne ${nomCol} inconnue.` };
    if (c.pk) {
      return {
        base,
        ok: false,
        message: `Impossible : ${nomCol} est la clé primaire de ${t.nom}.`,
      };
    }
    t.cols = t.cols.filter((x) => x !== c);
    t.lignes.forEach((l) => {
      delete l[nomCol];
    });
    return {
      base,
      ok: true,
      message: `Colonne ${nomCol} supprimée de ${t.nom}, avec son contenu.`,
    };
  }

  m = /^ALTER TABLE (\w+) MODIFY(?: COLUMN)? (\w+) ([A-Za-z]+(?:\s*\(\s*\d+\s*\))?)$/i.exec(sql);
  if (m) {
    const t = trouver(base, m[1] ?? "");
    if (!t) return { base, ok: false, message: `ERREUR 1146 — table ${m[1]} inconnue.` };
    const c = t.cols.find((x) => x.nom.toUpperCase() === (m?.[2] ?? "").toUpperCase());
    if (!c) return { base, ok: false, message: `ERREUR 1054 — colonne ${m[2]} inconnue.` };
    c.type = (m[3] ?? "").replace(/\s+/g, "");
    return { base, ok: true, message: `Type de ${c.nom} changé en ${c.type}.` };
  }

  /* ---- INSERT ---- */
  m = /^INSERT INTO (\w+)\s*(?:\(([^)]*)\))?\s*VALUES\s*\((.*)\)$/is.exec(sql);
  if (m) {
    const t = trouver(base, m[1] ?? "");
    if (!t) return { base, ok: false, message: `ERREUR 1146 — la table ${m[1]} n'existe pas.` };
    const nomsCols = m[2] ? decouperVirgules(m[2]).map((x) => x.trim()) : t.cols.map((c) => c.nom);
    const valeurs = decouperVirgules(m[3] ?? "");

    if (nomsCols.length !== valeurs.length) {
      return {
        base,
        ok: false,
        message: `ERREUR 1136 — ${valeurs.length} valeur(s) pour ${nomsCols.length} colonne(s). Le nombre de valeurs doit correspondre exactement, et dans le même ordre.`,
      };
    }

    const ligne: Ligne = {};
    for (let i = 0; i < nomsCols.length; i++) {
      const nc = nomsCols[i] ?? "";
      const col = t.cols.find((c) => c.nom.toUpperCase() === nc.toUpperCase());
      if (!col) {
        return {
          base,
          ok: false,
          message: `ERREUR 1054 — colonne « ${nc} » inconnue dans ${t.nom}.`,
        };
      }
      const brut = (valeurs[i] ?? "").trim();
      // Un texte sans apostrophes est la faute classique.
      if (
        /^(VARCHAR|CHAR|TEXT|DATE)/i.test(col.type) &&
        !/^'.*'$/s.test(brut) &&
        !/^null$/i.test(brut) &&
        Number.isNaN(Number(brut))
      ) {
        return {
          base,
          ok: false,
          message: `ERREUR 1054 — « ${brut} » est pris pour un nom de colonne. Une valeur texte s'écrit entre apostrophes : '${brut}'.`,
        };
      }
      if (/^\d+\s+\d+/.test(brut)) {
        return {
          base,
          ok: false,
          message: `Erreur de syntaxe près de « ${brut} » : un nombre ne contient pas d'espace. Écris 250000 et non 250 000.`,
        };
      }
      ligne[col.nom] = litteral(brut);
    }
    for (const c of t.cols) {
      if (!(c.nom in ligne)) ligne[c.nom] = null;
    }

    const err = verifier(base, t, ligne);
    if (err) return { base, ok: false, message: err };

    t.lignes.push(ligne);
    return { base, ok: true, message: "1 ligne insérée." };
  }

  /* ---- UPDATE ---- */
  m = /^UPDATE (\w+) SET (.+?)(?: WHERE (.+))?$/is.exec(sql);
  if (m) {
    const t = trouver(base, m[1] ?? "");
    if (!t) return { base, ok: false, message: `ERREUR 1146 — table ${m[1]} inconnue.` };
    const cond = m[3] ?? "";
    const cibles = t.lignes.filter((l) => evaluerCondition(cond, l));

    if (cond === "" && !confirme) {
      return {
        base: base0,
        ok: false,
        message: `Attention : cet UPDATE n'a pas de clause WHERE. Il modifierait les ${t.lignes.length} lignes de ${t.nom}, et c'est irréversible. Confirme si c'est bien ce que tu veux.`,
        avertissement: `${t.lignes.length} lignes seraient modifiées`,
      };
    }

    const affectations = decouperVirgules(m[2] ?? "");
    for (const l of cibles) {
      const copie = { ...l };
      for (const a of affectations) {
        const am = /^(\w+)\s*=\s*(.+)$/s.exec(a.trim());
        if (!am) return { base, ok: false, message: `Erreur de syntaxe près de « ${a} ».` };
        const col = t.cols.find((c) => c.nom.toUpperCase() === (am[1] ?? "").toUpperCase());
        if (!col) return { base, ok: false, message: `ERREUR 1054 — colonne ${am[1]} inconnue.` };
        const expr = (am[2] ?? "").trim();
        const calc = /^(\w+)\s*([+\-*/])\s*(.+)$/.exec(expr);
        if (calc && t.cols.some((c) => c.nom.toUpperCase() === (calc[1] ?? "").toUpperCase())) {
          const a1 = Number(copie[calc[1] ?? ""] ?? 0);
          const a2 = Number(litteral(calc[3] ?? "0"));
          const op = calc[2] ?? "+";
          copie[col.nom] =
            op === "+"
              ? a1 + a2
              : op === "-"
                ? a1 - a2
                : op === "*"
                  ? a1 * a2
                  : a2 === 0
                    ? 0
                    : a1 / a2;
        } else {
          copie[col.nom] = litteral(expr);
        }
      }
      const err = verifier(base, t, copie, l);
      if (err) return { base: base0, ok: false, message: err };
      Object.assign(l, copie);
    }
    return {
      base,
      ok: true,
      message: `${cibles.length} ligne(s) modifiée(s).${cond === "" ? " Toute la table a changé — c'est le danger d'un UPDATE sans WHERE." : ""}`,
    };
  }

  /* ---- DELETE ---- */
  m = /^DELETE FROM (\w+)(?: WHERE (.+))?$/is.exec(sql);
  if (m) {
    const t = trouver(base, m[1] ?? "");
    if (!t) return { base, ok: false, message: `ERREUR 1146 — table ${m[1]} inconnue.` };
    const cond = m[2] ?? "";
    const cibles = t.lignes.filter((l) => evaluerCondition(cond, l));

    if (cond === "" && !confirme) {
      return {
        base: base0,
        ok: false,
        message: `Attention : ce DELETE n'a pas de clause WHERE. Il viderait les ${t.lignes.length} lignes de ${t.nom}, en laissant la table — structure et colonnes — en place. Confirme si c'est bien ce que tu veux.`,
        avertissement: `${t.lignes.length} lignes seraient supprimées`,
      };
    }

    // Une ligne référencée par une clé étrangère ne peut pas partir.
    for (const l of cibles) {
      const pk = t.cols.find((c) => c.pk);
      if (!pk) continue;
      const bloquante = base.find(
        (x) =>
          x !== t &&
          x.cols.some(
            (c) =>
              c.fk &&
              c.fk.table.toUpperCase() === t.nom.toUpperCase() &&
              x.lignes.some((ll) => String(ll[c.nom]) === String(l[pk.nom])),
          ),
      );
      if (bloquante) {
        return {
          base: base0,
          ok: false,
          message: `ERREUR 1451 — la ligne ${String(l[pk.nom])} est référencée par la table ${bloquante.nom}. La supprimer laisserait des lignes pointant vers le vide : c'est l'intégrité référentielle qui refuse.`,
        };
      }
    }

    t.lignes = t.lignes.filter((l) => !cibles.includes(l));
    return {
      base,
      ok: true,
      message: `${cibles.length} ligne(s) supprimée(s). La table ${t.nom} existe toujours${t.lignes.length === 0 ? ", mais elle est vide" : ""}.`,
    };
  }

  /* ---- SELECT ---- */
  m = /^SELECT (DISTINCT )?(.+?) FROM (.+?)(?: WHERE (.+?))?(?: ORDER BY (.+?))?$/is.exec(sql);
  if (m) {
    const distinct = Boolean(m[1]);
    const champs = decouperVirgules(m[2] ?? "").map((x) => x.trim());
    const tablesDemandees = decouperVirgules(m[3] ?? "").map((x) => x.trim().split(/\s+/)[0] ?? "");
    const cond = m[4] ?? "";
    const tri = m[5] ?? "";

    const tabs: Table[] = [];
    for (const n of tablesDemandees) {
      const t = trouver(base, n);
      if (!t) return { base, ok: false, message: `ERREUR 1146 — la table ${n} n'existe pas.` };
      tabs.push(t);
    }

    // produit cartésien puis filtrage
    let lignes: Ligne[] = [{}];
    for (const t of tabs) {
      const suivant: Ligne[] = [];
      for (const partielle of lignes) {
        for (const l of t.lignes) {
          const fusion: Ligne = { ...partielle };
          for (const c of t.cols) {
            fusion[c.nom] = l[c.nom] ?? null;
            fusion[`${t.nom}.${c.nom}`] = l[c.nom] ?? null;
          }
          suivant.push(fusion);
        }
      }
      lignes = suivant;
    }
    const avantFiltre = lignes.length;
    lignes = lignes.filter((l) => evaluerCondition(cond, l));

    const toutes = champs.length === 1 && champs[0] === "*";
    const cols = toutes
      ? tabs.flatMap((t) => t.cols.map((c) => c.nom))
      : champs.map((c) => (c.includes(".") ? (c.split(".")[1] ?? c) : c));

    for (const c of cols) {
      const existe = tabs.some((t) => t.cols.some((x) => x.nom.toUpperCase() === c.toUpperCase()));
      if (!existe) {
        return { base, ok: false, message: `ERREUR 1054 — colonne « ${c} » inconnue.` };
      }
    }

    let sortieLignes = lignes.map((l) => {
      const o: Ligne = {};
      for (const c of cols) {
        const cle = Object.keys(l).find((k) => k.toUpperCase() === c.toUpperCase());
        o[c] = cle ? (l[cle] ?? null) : null;
      }
      return o;
    });

    if (distinct) {
      const vus = new Set<string>();
      sortieLignes = sortieLignes.filter((l) => {
        const k = JSON.stringify(l);
        if (vus.has(k)) return false;
        vus.add(k);
        return true;
      });
    }

    if (tri !== "") {
      const tm = /^(\w+(?:\.\w+)?)(?:\s+(ASC|DESC))?$/i.exec(tri.trim());
      if (tm) {
        const c = (tm[1] ?? "").includes(".") ? ((tm[1] ?? "").split(".")[1] ?? "") : (tm[1] ?? "");
        const desc = (tm[2] ?? "ASC").toUpperCase() === "DESC";
        sortieLignes = [...sortieLignes].sort((a, b) => {
          const x = a[c];
          const y = b[c];
          if (x === null || y === null) return 0;
          const r =
            typeof x === "number" && typeof y === "number"
              ? x - y
              : String(x).localeCompare(String(y), "fr");
          return desc ? -r : r;
        });
      }
    }

    const res: Resultat = {
      base,
      ok: true,
      message: `${sortieLignes.length} ligne(s) retournée(s).`,
      sortie: { cols, lignes: sortieLignes, sources: tabs.map((t) => t.lignes.length) },
    };
    if (tabs.length > 1 && cond === "") {
      res.avertissement = `Produit cartésien : ${tabs.map((t) => t.lignes.length).join(" × ")} = ${avantFiltre} lignes. Il manque la condition de jointure.`;
    }
    return res;
  }

  if (/^GRANT|^REVOKE/i.test(sql)) {
    return {
      base,
      ok: true,
      message:
        "Droits modifiés. (GRANT et REVOKE appartiennent au LCD, le langage de contrôle de données.)",
    };
  }

  return {
    base,
    ok: false,
    message:
      "Requête non reconnue. Le moteur comprend CREATE TABLE, ALTER TABLE, DROP TABLE, INSERT, UPDATE, DELETE, SELECT, GRANT et REVOKE.",
  };
}

/* ------------------------------------------------------------------ */
/* Affichage d'une table du moteur                                     */
/* ------------------------------------------------------------------ */

export function VueTable({
  table,
  eclairees = [],
  onClicCol,
  onClicLigne,
  titre,
}: {
  table: Table;
  /** Index des lignes à surligner. */
  eclairees?: ReadonlyArray<number>;
  onClicCol?: ((col: Col) => void) | undefined;
  onClicLigne?: ((i: number) => void) | undefined;
  titre?: string | undefined;
}) {
  return (
    <div className="space-y-1">
      <p className="text-xs font-semibold">
        {titre ?? table.nom}
        <span className="ml-2 font-normal text-muted-foreground">
          {table.lignes.length} ligne{table.lignes.length > 1 ? "s" : ""}
        </span>
      </p>
      <div className="overflow-x-auto">
        <table className="w-full border-collapse text-[11px]">
          <thead>
            <tr>
              {table.cols.map((c) => (
                <th
                  key={c.nom}
                  onClick={onClicCol ? () => onClicCol(c) : undefined}
                  className={`border border-border px-2 py-1 font-mono ${
                    c.pk
                      ? "bg-blue-500/20 font-bold underline"
                      : c.fk
                        ? "bg-amber-500/20 font-bold italic"
                        : "bg-secondary/40"
                  } ${onClicCol ? "cursor-pointer" : ""}`}
                  title={c.type}
                >
                  {c.pk ? "🔑 " : c.fk ? "↗ " : ""}
                  {c.nom}
                </th>
              ))}
            </tr>
          </thead>
          <tbody>
            {table.lignes.length === 0 ? (
              <tr>
                <td
                  colSpan={Math.max(1, table.cols.length)}
                  className="border border-border px-2 py-2 text-center text-muted-foreground"
                >
                  (table vide)
                </td>
              </tr>
            ) : (
              table.lignes.map((l, i) => (
                <tr
                  key={`${i}-${Object.values(l).join("|")}`}
                  onClick={onClicLigne ? () => onClicLigne(i) : undefined}
                  className={`${eclairees.includes(i) ? "bg-amber-400/25" : ""} ${
                    onClicLigne ? "cursor-pointer" : ""
                  }`}
                >
                  {table.cols.map((c) => (
                    <td key={c.nom} className="border border-border px-2 py-1 font-mono">
                      {l[c.nom] === null || l[c.nom] === undefined ? (
                        <span className="text-muted-foreground">NULL</span>
                      ) : (
                        String(l[c.nom])
                      )}
                    </td>
                  ))}
                </tr>
              ))
            )}
          </tbody>
        </table>
      </div>
    </div>
  );
}
