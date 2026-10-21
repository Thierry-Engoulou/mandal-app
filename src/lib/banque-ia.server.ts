// Quand l'élève demande un sujet ou une épreuve, propose à Mandal IA les
// épreuves correspondantes de la banque (publiées).
import type { SupabaseClient } from "@supabase/supabase-js";
import type { Database } from "@/integrations/supabase/types";
import { devinerDepuisNom } from "./banque-constantes";

const DEMANDE_EPREUVE =
  /\b(sujets?|epreuves?|annales?|past ?papers?|anciens? sujets?|exercices? d'examen|bac|baccalaureat|bepc|probatoire|gce|o ?level|a ?level|concours|examens? blancs?)\b/;

/** Liste (texte) des épreuves de la banque utiles à la question, ou "". */
export async function epreuvesPourQuestion(
  supabase: SupabaseClient<Database>,
  question: string,
): Promise<string> {
  const texte = question.toLowerCase().normalize("NFD").replace(/[̀-ͯ]/g, "");
  if (!DEMANDE_EPREUVE.test(texte)) return "";

  const meta = devinerDepuisNom(question);
  const filtres = {
    ...(meta.type_examen ? { p_type: meta.type_examen } : {}),
    ...(meta.matiere ? { p_matiere: meta.matiere } : {}),
    ...(meta.annee ? { p_annee: Number(meta.annee) } : {}),
  };
  if (Object.keys(filtres).length === 0) return "";

  let { data } = await supabase.rpc("rechercher_banque_epreuves", { ...filtres, p_limite: 5 });
  // Pas d'épreuve cette année-là : on propose les autres années.
  if (!data?.length && "p_annee" in filtres) {
    const { p_annee: _annee, ...sansAnnee } = filtres;
    ({ data } = await supabase.rpc("rechercher_banque_epreuves", { ...sansAnnee, p_limite: 5 }));
  }
  if (!data?.length) return "";

  return data
    .map(
      (e) =>
        `- ${e.titre} (${[e.classe, e.serie && `série ${e.serie}`, e.source].filter(Boolean).join(", ")})${
          e.corrige_path ? " — avec corrigé" : ""
        }`,
    )
    .join("\n");
}

export const CONSIGNES_BANQUE = `ÉPREUVES DE LA BANQUE M'ANDAL
- Si l'élève demande un sujet, une épreuve ou des annales, cite d'abord les épreuves de la liste ci-dessous (titres exacts) et dis-lui qu'il peut les télécharger gratuitement dans la « Banque d'épreuves » de M'ANDAL (menu de son espace ou page /banque-epreuves), puis propose de corriger sa copie avec « Corriger ma copie ».
- N'invente jamais d'épreuve qui ne figure pas dans la liste.`;
