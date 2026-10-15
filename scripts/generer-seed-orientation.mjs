// Génère la migration de contenu de la base d'orientation à partir des fiches
// de supabase/seed/orientation. Usage : node scripts/generer-seed-orientation.mjs
import { writeFileSync } from "node:fs";
import { SOURCES } from "../supabase/seed/orientation/sources.mjs";
import { FILIERES } from "../supabase/seed/orientation/filieres.mjs";
import { METIERS } from "../supabase/seed/orientation/metiers.mjs";
import { FAQ } from "../supabase/seed/orientation/faq.mjs";

const SORTIE = "supabase/migrations/20261015160000_seed_orientation.sql";

const lit = (v) => (v == null ? "NULL" : `'${String(v).replace(/'/g, "''")}'`);
const tab = (a) => `ARRAY[${(a ?? []).map(lit).join(", ")}]::text[]`;

const fiches = [
  ...FILIERES.map((f) => ({ ...f, type: "filiere" })),
  ...METIERS.map((f) => ({ ...f, type: "metier" })),
  ...FAQ.map((f) => ({ ...f, type: "faq" })),
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

const sql = `-- ============================================================================
-- Contenu de la base d'orientation : ${FILIERES.length} filières, ${METIERS.length} métiers, ${FAQ.length} questions fréquentes.
-- FICHIER GÉNÉRÉ par scripts/generer-seed-orientation.mjs — ne pas modifier à la main.
-- Ré-exécutable : les fiches existantes (même slug) sont mises à jour.
-- ============================================================================

INSERT INTO public.orientation_fiches
  (slug, type, titre, categorie, niveau_acces, resume, contenu, debouches, formations, mots_cles, sources)
VALUES
${lignes.join(",\n")}
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

writeFileSync(SORTIE, sql);
console.log(`${SORTIE} : ${fiches.length} fiches`);
