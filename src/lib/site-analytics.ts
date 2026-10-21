/**
 * Statistiques réelles du site, enregistrées dans Supabase (table
 * site_evenements) via des fonctions dédiées. Anonymes : le navigateur tire un
 * identifiant aléatoire, aucune donnée personnelle n'est envoyée. Un visiteur
 * compte une fois par page et par jour (dédoublonnage côté base).
 */
import { supabase } from "@/integrations/supabase/client";

const CLE_VISITEUR = "mandal_visiteur_v1";
let visiteurMemoire: string | null = null;
const dejaEnvoyees = new Set<string>();

/** Identifiant anonyme et persistant du navigateur (aléatoire). */
export function identifiantVisiteur(): string {
  if (visiteurMemoire) return visiteurMemoire;
  try {
    const existant = localStorage.getItem(CLE_VISITEUR);
    if (existant && /^[0-9a-f-]{36}$/i.test(existant)) {
      visiteurMemoire = existant;
      return existant;
    }
    const nouveau = crypto.randomUUID();
    localStorage.setItem(CLE_VISITEUR, nouveau);
    visiteurMemoire = nouveau;
  } catch {
    // Navigation privée ou stockage bloqué : identifiant valable pour la session.
    visiteurMemoire = crypto.randomUUID();
  }
  return visiteurMemoire;
}

/** Chemin regroupé : les identifiants (/courses/<uuid>) deviennent « :id ». */
export function pageNormalisee(pathname: string): string {
  const p = pathname
    .replace(/\/[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}/gi, "/:id")
    .replace(/\/+$/, "");
  return p || "/";
}

/** Enregistre la visite d'une page (une fois par page et par session). */
export function enregistrerVisite(pathname: string): void {
  if (typeof window === "undefined") return;
  const page = pageNormalisee(pathname);
  if (page.startsWith("/admin") || dejaEnvoyees.has(page)) return;
  dejaEnvoyees.add(page);
  void supabase
    .rpc("enregistrer_visite", { p_visiteur: identifiantVisiteur(), p_page: page })
    .then(({ error }) => {
      if (error) console.debug("[Statistiques] visite non enregistrée :", error.message);
    });
}

/** Signale une tentative d'accès à l'administration sans les droits. */
export function signalerAccesRefuse(page: string): void {
  void supabase.rpc("signaler_acces_refuse", { p_page: page }).then(({ error }) => {
    if (error) console.debug("[Sécurité] signalement non enregistré :", error.message);
  });
}

export type StatistiquesSite = {
  depuis: string | null;
  visiteurs_total: number;
  visiteurs_aujourdhui: number;
  visiteurs_semaine: number;
  pages_vues: number;
  telechargements_total: number;
  telechargements_aujourdhui: number;
  telechargeurs_total: number;
  epreuves_publiees: number;
  epreuves_en_attente: number;
  top_epreuves: { titre: string; type_examen: string; telechargements: number }[];
  top_pages: { page: string; vues: number; visiteurs: number }[];
  par_jour: { jour: string; visiteurs: number; telechargements: number }[];
};

/** Synthèse pour le tableau de bord (administrateurs). */
export async function chargerStatistiques(): Promise<StatistiquesSite | null> {
  const { data, error } = await supabase.rpc("statistiques_site");
  if (error) {
    console.warn("[Statistiques]", error.message);
    return null;
  }
  return data as unknown as StatistiquesSite;
}

/** Libellé lisible d'une page du site. */
export function libellePage(page: string): string {
  const noms: Record<string, string> = {
    "/": "Accueil",
    "/education": "Éducation",
    "/citoyennete": "Citoyenneté",
    "/culture": "Culture",
    "/a-propos": "À propos",
    "/banque-epreuves": "Banque d'épreuves (publique)",
    "/inscription": "Inscription",
    "/auth": "Connexion",
    "/courses": "Catalogue des cours",
    "/courses/:id": "Page d'un cours",
    "/etudiant": "Espace élève — accueil",
    "/etudiant/mandal-ia": "Mandal IA",
    "/etudiant/banque": "Banque d'épreuves (élève)",
    "/etudiant/cours": "Mes cours",
    "/etudiant/correction": "Corriger ma copie",
    "/etudiant/sujets": "Épreuves blanches IA",
    "/etudiant/orientation/conseiller": "Orientation — Conseiller IA",
    "/etudiant/orientation/filieres": "Orientation — Filières",
    "/etudiant/orientation/metiers": "Orientation — Métiers",
  };
  return noms[page] ?? page;
}
