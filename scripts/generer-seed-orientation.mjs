// Génère la migration de contenu de la base d'orientation à partir des fiches
// de supabase/seed/orientation.
// Usage : node scripts/generer-seed-orientation.mjs [--parts <dossier>]
// --parts écrit aussi des fichiers SQL de ~30 Ko à coller un par un dans
// l'éditeur SQL de Supabase (qui tronque les scripts trop longs).
import { mkdirSync, writeFileSync } from "node:fs";
import { SOURCES } from "../supabase/seed/orientation/sources.mjs";
import { FILIERES } from "../supabase/seed/orientation/filieres.mjs";
import { METIERS } from "../supabase/seed/orientation/metiers.mjs";
import { FAQ } from "../supabase/seed/orientation/faq.mjs";
import { FAQ_2 } from "../supabase/seed/orientation/faq-2.mjs";
import { METIERS_2 } from "../supabase/seed/orientation/metiers-2.mjs";
import { ETABLISSEMENTS } from "../supabase/seed/orientation/etablissements.mjs";

const SORTIE = "supabase/migrations/20261015160000_seed_orientation.sql";

const lit = (v) => (v == null ? "NULL" : `'${String(v).replace(/'/g, "''")}'`);
const tab = (a) => `ARRAY[${(a ?? []).map(lit).join(", ")}]::text[]`;

const FILIERES_TOUTES = [...FILIERES, ...ETABLISSEMENTS];
const METIERS_TOUS = [...METIERS, ...METIERS_2];
const FAQ_TOUTES = [...FAQ, ...FAQ_2];

const fiches = [
  ...FILIERES_TOUTES.map((f) => ({ ...f, type: "filiere" })),
  ...METIERS_TOUS.map((f) => ({ ...f, type: "metier" })),
  ...FAQ_TOUTES.map((f) => ({ ...f, type: "faq" })),
];

const slugs = new Set();
const lignes = fiches.map((f) => {
  if (slugs.has(f.slug)) throw new Error(`Slug en double : ${f.slug}`);
  slugs.add(f.slug);
  for (const champ of ["slug", "titre", "categorie", "resume", "contenu"]) {
    if (!f[champ]) throw new Error(`${f.slug} : champ « ${champ} » manquant`);
  }
  if (!f.sources?.length) throw new Error(`${f.slug} : aucune référence`);
  const sources = f.sources.map((cle) => {
    const s = SOURCES[cle];
    if (!s) throw new Error(`${f.slug} : source inconnue « ${cle} »`);
    return s.url ? { titre: s.titre, url: s.url } : { titre: s.titre };
  });
  return `(${[
    lit(f.slug),
    lit(f.type),
    lit(f.titre),
    lit(f.categorie),
    lit(f.niveau_acces),
    lit(f.resume),
    lit(f.contenu),
    tab(f.debouches),
    tab(f.formations),
    tab(f.mots_cles),
    `${lit(JSON.stringify(sources))}::jsonb`,
  ].join(", ")})`;
});

const INSERT = `INSERT INTO public.orientation_fiches
  (slug, type, titre, categorie, niveau_acces, resume, contenu, debouches, formations, mots_cles, sources)
VALUES
`;
const CONFLIT = `
ON CONFLICT (slug) DO UPDATE SET
  type = EXCLUDED.type,
  titre = EXCLUDED.titre,
  categorie = EXCLUDED.categorie,
  niveau_acces = EXCLUDED.niveau_acces,
  resume = EXCLUDED.resume,
  contenu = EXCLUDED.contenu,
  debouches = EXCLUDED.debouches,
  formations = EXCLUDED.formations,
  mots_cles = EXCLUDED.mots_cles,
  sources = EXCLUDED.sources,
  mis_a_jour = current_date;
`;

const sql = `-- ============================================================================
-- Contenu de la base d'orientation : ${FILIERES_TOUTES.length} filières et établissements, ${METIERS_TOUS.length} métiers, ${FAQ_TOUTES.length} questions fréquentes.
-- FICHIER GÉNÉRÉ par scripts/generer-seed-orientation.mjs — ne pas modifier à la main.
-- Ré-exécutable : les fiches existantes (même slug) sont mises à jour.
-- ============================================================================

${INSERT}${lignes.join(",\n")}${CONFLIT}`;

writeFileSync(SORTIE, sql);
console.log(`${SORTIE} : ${fiches.length} fiches`);

const iParts = process.argv.indexOf("--parts");
if (iParts !== -1) {
  const dossier = process.argv[iParts + 1];
  if (!dossier) throw new Error("--parts : dossier manquant");
  mkdirSync(dossier, { recursive: true });
  const parts = [];
  let courant = [];
  let taille = 0;
  for (const l of lignes) {
    if (courant.length && taille + l.length > 30000) {
      parts.push(courant);
      courant = [];
      taille = 0;
    }
    courant.push(l);
    taille += l.length;
  }
  parts.push(courant);
  parts.forEach((p, i) => {
    const nom = `${dossier}/fiches_${String(i + 1).padStart(2, "0")}.sql`;
    writeFileSync(
      nom,
      `-- Partie ${i + 1}/${parts.length} : ${p.length} fiches\n${INSERT}${p.join(",\n")}${CONFLIT}`,
    );
  });
  console.log(`${parts.length} parties écrites dans ${dossier}`);
}
