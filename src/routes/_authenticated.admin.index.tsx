import { createFileRoute, Link } from "@tanstack/react-router";
import { useQuery } from "@tanstack/react-query";
import { useServerFn } from "@tanstack/react-start";
import { useMemo, useState } from "react";
import {
  AlertTriangle,
  ArrowUpRight,
  CheckCircle2,
  Download,
  Eye,
  FileSpreadsheet,
  GraduationCap,
  Library,
  Lock,
  Mail,
  RefreshCw,
  School,
  ShieldCheck,
  TrendingUp,
  UserCog,
  Users,
} from "lucide-react";
import { toast } from "sonner";
import { listAdminInvitations, listEtablissements } from "@/lib/admin.functions";
import { supabase } from "@/integrations/supabase/client";
import { chargerStatistiques, libellePage, type StatistiquesSite } from "@/lib/site-analytics";
import { Button } from "@/components/ui/button";
import { Skeleton } from "@/components/ui/skeleton";

export const Route = createFileRoute("/_authenticated/admin/")({
  component: AdminDashboardPage,
  head: () => ({
    meta: [
      { title: "Tableau de Bord Administrateur — MANDAL" },
      {
        name: "description",
        content: "Statistiques réelles et pilotage sécurisé de la plateforme M'ANDAL.",
      },
      { name: "robots", content: "noindex, nofollow" },
    ],
  }),
});

const ROLES: Record<string, string> = {
  student: "Élève",
  teacher: "Enseignant",
  chef_etablissement: "Chef d'établissement",
  admin: "Administrateur",
  super_admin: "Super admin",
};
const STATUTS: Record<string, string> = {
  en_attente: "En attente",
  approuve: "Approuvé",
  rejete: "Rejeté",
};

function decrireAction(action: string, details: Record<string, unknown>): string {
  const ancien = String(details["ancien"] ?? "");
  const nouveau = String(details["nouveau"] ?? "");
  switch (action) {
    case "role":
      return `Rôle : ${ROLES[ancien] ?? ancien} → ${ROLES[nouveau] ?? nouveau}`;
    case "statut":
      return `Statut du compte : ${STATUTS[ancien] ?? ancien} → ${STATUTS[nouveau] ?? nouveau}`;
    case "acces_refuse":
      return `Accès à l'administration refusé (${String(details["page"] ?? "")})`;
    case "epreuve_publiee":
      return "Épreuve publiée";
    case "epreuve_rejetee":
      return `Épreuve refusée${details["motif"] ? ` : ${String(details["motif"])}` : ""}`;
    case "epreuve_en_attente":
      return "Épreuve remise en validation";
    case "epreuve_supprimee":
      return "Épreuve supprimée";
    default:
      return action;
  }
}

const fmt = (n: number | undefined) => (n ?? 0).toLocaleString("fr-FR");
const dateCourte = (iso: string) =>
  new Date(iso).toLocaleDateString("fr-FR", { day: "numeric", month: "short" });

function AdminDashboardPage() {
  const invitationsFn = useServerFn(listAdminInvitations);
  const etabsFn = useServerFn(listEtablissements);
  const [lastRefreshed, setLastRefreshed] = useState<Date>(new Date());

  const { data, isLoading, refetch, isFetching } = useQuery({
    queryKey: ["admin-dashboard-stats"],
    queryFn: async () => {
      const [profils, invitations, etablissements, stats, journal] = await Promise.all([
        supabase.from("profiles").select("id, role, niveau, statut_validation, created_at"),
        invitationsFn().catch(() => []),
        etabsFn().catch(() => []),
        chargerStatistiques(),
        supabase.rpc("journal_admin_recent", { p_limite: 20 }),
      ]);
      if (profils.error) console.warn("Lecture des profils :", profils.error.message);
      return {
        profils: profils.data ?? [],
        invitations,
        etablissements,
        stats,
        journal: journal.data ?? [],
      };
    },
    refetchInterval: 60000,
  });

  const s: StatistiquesSite | null = data?.stats ?? null;
  const profils = useMemo(() => data?.profils ?? [], [data?.profils]);
  const eleves = profils.filter((p) => p.role === "student");
  const enseignants = profils.filter((p) => p.role === "teacher");
  const enseignantsEnAttente = enseignants.filter((p) => p.statut_validation === "en_attente");
  const inscritsSemaine = eleves.filter(
    (p) => Date.now() - new Date(p.created_at).getTime() < 7 * 86400000,
  ).length;

  // Répartition réelle par niveau déclaré (« Débutant » = valeur par défaut).
  const parNiveau = useMemo(() => {
    const compte = new Map<string, number>();
    for (const p of profils.filter((x) => x.role === "student")) {
      const n = (p.niveau ?? "").trim();
      const cle = !n || n === "Débutant" ? "Non renseigné" : n;
      compte.set(cle, (compte.get(cle) ?? 0) + 1);
    }
    return [...compte.entries()].sort((a, b) => b[1] - a[1]);
  }, [profils]);

  const maxJour = Math.max(1, ...(s?.par_jour ?? []).map((j) => j.visiteurs));

  const handleRefresh = async () => {
    await refetch();
    setLastRefreshed(new Date());
    toast.success("Statistiques actualisées.");
  };

  const handleExportStats = () => {
    if (!data) return;
    const lignes = [
      ["CATEGORIE", "INDICATEUR", "VALEUR"],
      ["Fréquentation", "Visiteurs uniques (total)", s?.visiteurs_total ?? 0],
      ["Fréquentation", "Visiteurs aujourd'hui", s?.visiteurs_aujourdhui ?? 0],
      ["Fréquentation", "Visiteurs sur 7 jours", s?.visiteurs_semaine ?? 0],
      ["Fréquentation", "Pages vues (uniques par jour)", s?.pages_vues ?? 0],
      ["Banque", "Téléchargements (total)", s?.telechargements_total ?? 0],
      ["Banque", "Épreuves publiées", s?.epreuves_publiees ?? 0],
      ["Utilisateurs", "Élèves inscrits", eleves.length],
      ["Utilisateurs", "Enseignants", enseignants.length],
      ["Utilisateurs", "Établissements", data.etablissements.length],
      ...parNiveau.map(([n, c]) => ["Élèves par niveau", n, c]),
      ...(s?.par_jour ?? []).map((j) => ["Visiteurs par jour", j.jour, j.visiteurs]),
    ];
    const csv = lignes
      .map((l) => l.map((v) => `"${String(v).replace(/"/g, '""')}"`).join(","))
      .join("\n");
    const url = URL.createObjectURL(new Blob(["﻿" + csv], { type: "text/csv;charset=utf-8;" }));
    const link = document.createElement("a");
    link.href = url;
    link.download = `mandal_statistiques_${new Date().toISOString().slice(0, 10)}.csv`;
    link.click();
    URL.revokeObjectURL(url);
  };

  return (
    <div className="space-y-8 animate-in fade-in duration-300">
      {/* En-tête */}
      <div className="rounded-3xl border border-slate-800 bg-gradient-to-r from-slate-900 via-slate-950 to-slate-900 p-6 sm:p-8 shadow-xl">
        <div className="flex flex-col gap-6 lg:flex-row lg:items-center lg:justify-between">
          <div>
            <span className="inline-flex items-center gap-1.5 rounded-full border border-emerald-500/30 bg-emerald-500/15 px-3 py-1 text-xs font-bold text-emerald-400">
              <ShieldCheck className="size-3.5" /> Espace administrateur
            </span>
            <h1 className="mt-3 font-display text-2xl font-black tracking-tight text-white sm:text-3xl lg:text-4xl">
              Tableau de bord M'ANDAL
            </h1>
            <p className="mt-1 max-w-2xl text-sm text-slate-300">
              Chiffres réels issus de la base Supabase : fréquentation anonyme, téléchargements de
              la banque d'épreuves, inscriptions.
            </p>
          </div>
          <div className="flex flex-wrap items-center gap-3">
            <Button
              variant="outline"
              size="sm"
              onClick={() => void handleRefresh()}
              disabled={isFetching}
              className="rounded-xl border-slate-700 bg-slate-900/80 text-xs font-bold text-slate-200 hover:bg-slate-800"
            >
              <RefreshCw
                className={`mr-2 size-3.5 ${isFetching ? "animate-spin text-emerald-400" : ""}`}
              />
              Actualiser
            </Button>
            <Button
              size="sm"
              onClick={handleExportStats}
              className="rounded-xl bg-emerald-600 text-xs font-bold text-white hover:bg-emerald-500"
            >
              <FileSpreadsheet className="mr-2 size-4" /> Exporter (CSV)
            </Button>
          </div>
        </div>
        <div className="mt-6 flex flex-wrap items-center justify-between gap-3 border-t border-slate-800/80 pt-4 text-xs text-slate-400">
          <span>
            {s?.depuis
              ? `Mesure de la fréquentation depuis le ${new Date(s.depuis).toLocaleDateString("fr-FR")}`
              : "La mesure de fréquentation démarre avec les premières visites."}
          </span>
          <span>Dernière actualisation : {lastRefreshed.toLocaleTimeString("fr-FR")}</span>
        </div>
        {!isLoading && !s ? (
          <p className="mt-4 rounded-xl border border-amber-500/30 bg-amber-500/10 p-3 text-xs text-amber-300">
            Statistiques indisponibles : exécutez la migration « statistiques_roles_journal » dans
            Supabase.
          </p>
        ) : null}
      </div>

      {/* Indicateurs */}
      <div className="grid grid-cols-1 gap-5 sm:grid-cols-2 lg:grid-cols-4">
        <Kpi
          titre="Visiteurs uniques"
          icone={<Eye className="size-5" />}
          couleur="emerald"
          valeur={isLoading ? null : fmt(s?.visiteurs_total)}
          sousTitre="Navigateurs distincts (anonymes)"
          gauche={`${fmt(s?.visiteurs_aujourdhui)} aujourd'hui`}
          droite={`${fmt(s?.visiteurs_semaine)} sur 7 jours`}
        />
        <Kpi
          titre="Téléchargements"
          icone={<Download className="size-5" />}
          couleur="blue"
          valeur={isLoading ? null : fmt(s?.telechargements_total)}
          sousTitre="Épreuves et corrigés de la banque"
          gauche={`${fmt(s?.telechargements_aujourdhui)} aujourd'hui`}
          droite={`${fmt(s?.epreuves_publiees)} épreuves publiées`}
        />
        <Kpi
          titre="Élèves inscrits"
          icone={<GraduationCap className="size-5" />}
          couleur="amber"
          valeur={isLoading ? null : fmt(eleves.length)}
          sousTitre="Comptes élèves dans la base"
          gauche={`+${inscritsSemaine} sur 7 jours`}
          droite={`${fmt(profils.length)} comptes au total`}
        />
        <Kpi
          titre="Réseau éducatif"
          icone={<School className="size-5" />}
          couleur="purple"
          valeur={isLoading ? null : `${enseignants.length} / ${data?.etablissements.length ?? 0}`}
          sousTitre="Enseignants / Établissements"
          gauche={`${enseignantsEnAttente.length} enseignant(s) à valider`}
          droite={`${data?.invitations.length ?? 0} invitation(s)`}
        />
      </div>

      {/* Fréquentation sur 14 jours */}
      <Bloc
        titre="Visiteurs par jour (14 derniers jours)"
        icone={<TrendingUp className="size-5 text-emerald-400" />}
      >
        {s && s.par_jour.some((j) => j.visiteurs > 0) ? (
          <div className="flex h-40 items-end gap-1.5">
            {s.par_jour.map((j) => (
              <div
                key={j.jour}
                className="flex flex-1 flex-col items-center gap-1"
                title={`${dateCourte(j.jour)} : ${j.visiteurs} visiteur(s), ${j.telechargements} téléchargement(s)`}
              >
                <span className="text-[10px] font-bold text-slate-300">{j.visiteurs || ""}</span>
                <div
                  className="w-full rounded-t-md bg-gradient-to-t from-emerald-600 to-teal-400"
                  style={{
                    height: `${Math.max((j.visiteurs / maxJour) * 100, j.visiteurs ? 6 : 1)}%`,
                  }}
                />
                <span className="text-[9px] text-slate-500">{dateCourte(j.jour)}</span>
              </div>
            ))}
          </div>
        ) : (
          <Vide>
            Pas encore de visites enregistrées : les chiffres apparaîtront au fil des visites.
          </Vide>
        )}
      </Bloc>

      <div className="grid grid-cols-1 gap-6 lg:grid-cols-2">
        <Bloc
          titre="Épreuves les plus téléchargées"
          icone={<Download className="size-5 text-blue-400" />}
        >
          {s?.top_epreuves.length ? (
            <ol className="space-y-3">
              {s.top_epreuves.map((e, i) => (
                <li
                  key={e.titre}
                  className="flex items-center justify-between gap-3 rounded-2xl border border-slate-800/80 bg-slate-950 p-4"
                >
                  <div className="flex min-w-0 items-center gap-3">
                    <span className="flex size-7 shrink-0 items-center justify-center rounded-xl bg-blue-500/15 text-xs font-bold text-blue-400">
                      #{i + 1}
                    </span>
                    <div className="min-w-0">
                      <p className="truncate text-xs font-bold text-white">{e.titre}</p>
                      <span className="text-[10px] text-slate-400">{e.type_examen}</span>
                    </div>
                  </div>
                  <span className="shrink-0 font-display text-sm font-black text-blue-400">
                    {fmt(e.telechargements)}
                  </span>
                </li>
              ))}
            </ol>
          ) : (
            <Vide>
              Aucun téléchargement pour le moment.{" "}
              <Link to="/admin/banque" className="text-emerald-400 hover:underline">
                Ajouter des épreuves
              </Link>
            </Vide>
          )}
        </Bloc>

        <Bloc titre="Pages les plus visitées" icone={<Eye className="size-5 text-emerald-400" />}>
          {s?.top_pages.length ? (
            <div className="space-y-4">
              {s.top_pages.map((p) => (
                <div key={p.page} className="space-y-1.5">
                  <div className="flex items-center justify-between gap-2 text-xs">
                    <span className="truncate font-medium text-slate-300">
                      {libellePage(p.page)}
                    </span>
                    <span className="shrink-0 font-bold text-emerald-400">
                      {fmt(p.visiteurs)} visiteurs
                    </span>
                  </div>
                  <div className="h-2 w-full overflow-hidden rounded-full bg-slate-800">
                    <div
                      className="h-full rounded-full bg-gradient-to-r from-emerald-500 to-teal-400"
                      style={{
                        width: `${Math.round((p.visiteurs / Math.max(s.top_pages[0]!.visiteurs, 1)) * 100)}%`,
                      }}
                    />
                  </div>
                </div>
              ))}
            </div>
          ) : (
            <Vide>Pas encore de visites enregistrées.</Vide>
          )}
        </Bloc>
      </div>

      <Bloc
        titre="Élèves par niveau déclaré"
        icone={<Users className="size-5 text-amber-400" />}
        droite={
          <span className="rounded-full bg-slate-800 px-3 py-1 text-xs font-bold text-slate-300">
            Total : {eleves.length}
          </span>
        }
      >
        {parNiveau.length ? (
          <div className="grid grid-cols-1 gap-3 sm:grid-cols-2 lg:grid-cols-3">
            {parNiveau.map(([niveau, nb]) => (
              <div
                key={niveau}
                className="rounded-2xl border border-slate-800/80 bg-slate-950/70 p-4"
              >
                <div className="flex items-center justify-between">
                  <span className="text-sm font-bold text-white">{niveau}</span>
                  <span className="font-display text-lg font-black text-amber-400">{nb}</span>
                </div>
                <div className="mt-2 h-1.5 overflow-hidden rounded-full bg-slate-800">
                  <div
                    className="h-full rounded-full bg-amber-500"
                    style={{ width: `${Math.round((nb / eleves.length) * 100)}%` }}
                  />
                </div>
              </div>
            ))}
          </div>
        ) : (
          <Vide>Aucun élève inscrit pour le moment.</Vide>
        )}
        <p className="mt-4 text-[11px] text-slate-500">
          « Non renseigné » : l'élève n'a pas encore indiqué sa classe dans son profil.
        </p>
      </Bloc>

      <Bloc titre="Journal d'administration" icone={<Lock className="size-5 text-amber-400" />}>
        {data?.journal.length ? (
          <ul className="space-y-2.5">
            {data.journal.map((j, i) => {
              const details = (j.details ?? {}) as Record<string, unknown>;
              const refus = j.action === "acces_refuse" || j.action === "epreuve_rejetee";
              return (
                <li
                  key={`${j.created_at}-${i}`}
                  className="flex flex-wrap items-center justify-between gap-3 rounded-2xl border border-slate-800/80 bg-slate-950 px-4 py-3 text-xs"
                >
                  <div className="flex min-w-0 items-center gap-3">
                    {refus ? (
                      <AlertTriangle className="size-4 shrink-0 text-red-400" />
                    ) : (
                      <CheckCircle2 className="size-4 shrink-0 text-emerald-400" />
                    )}
                    <span className="text-slate-300">
                      <strong className="text-white">{j.acteur_nom}</strong> —{" "}
                      {decrireAction(j.action, details)}
                      {j.cible_nom ? (
                        <span className="text-slate-400"> · {j.cible_nom}</span>
                      ) : null}
                    </span>
                  </div>
                  <span className="shrink-0 text-[11px] text-slate-500">
                    {new Date(j.created_at).toLocaleString("fr-FR", {
                      dateStyle: "short",
                      timeStyle: "short",
                    })}
                  </span>
                </li>
              );
            })}
          </ul>
        ) : (
          <Vide>
            Aucun événement pour le moment. Les changements de rôle, les validations d'épreuves et
            les accès refusés apparaîtront ici.
          </Vide>
        )}
      </Bloc>

      <div className="grid grid-cols-1 gap-5 sm:grid-cols-3">
        <Raccourci
          to="/admin/utilisateurs"
          icone={<UserCog className="size-6" />}
          titre="Utilisateurs & rôles"
        >
          Valider les enseignants, nommer les administrateurs, rattacher aux établissements.
        </Raccourci>
        <Raccourci
          to="/admin/banque"
          icone={<Library className="size-6" />}
          titre="Banque d'épreuves"
        >
          {s?.epreuves_en_attente ? `${s.epreuves_en_attente} épreuve(s) à valider. ` : ""}
          Ajouter, importer et valider les épreuves.
        </Raccourci>
        <Raccourci
          to="/admin/demandes"
          icone={<Mail className="size-6" />}
          titre="Demandes d'inscription"
        >
          Consulter les candidatures d'élèves.
        </Raccourci>
      </div>
    </div>
  );
}

const COULEURS = {
  emerald: "bg-emerald-500/15 text-emerald-400 hover:border-emerald-500/50",
  blue: "bg-blue-500/15 text-blue-400 hover:border-blue-500/50",
  amber: "bg-amber-500/15 text-amber-400 hover:border-amber-500/50",
  purple: "bg-purple-500/15 text-purple-400 hover:border-purple-500/50",
} as const;

function Kpi(props: {
  titre: string;
  icone: React.ReactNode;
  couleur: keyof typeof COULEURS;
  valeur: string | null;
  sousTitre: string;
  gauche: string;
  droite: string;
}) {
  const [fond, texte] = COULEURS[props.couleur].split(" ");
  return (
    <div className="rounded-3xl border border-slate-800 bg-slate-900/90 p-6 shadow-xl">
      <div className="flex items-center justify-between">
        <span className="text-xs font-bold uppercase tracking-wider text-slate-400">
          {props.titre}
        </span>
        <div className={`flex size-10 items-center justify-center rounded-2xl ${fond} ${texte}`}>
          {props.icone}
        </div>
      </div>
      <div className="mt-4">
        <div className="font-display text-3xl font-black text-white sm:text-4xl">
          {props.valeur === null ? <Skeleton className="h-10 w-24" /> : props.valeur}
        </div>
        <p className="mt-1 text-xs font-medium text-slate-400">{props.sousTitre}</p>
      </div>
      <div className="mt-4 flex items-center justify-between gap-2 border-t border-slate-800 pt-4 text-xs">
        <span className={`font-bold ${texte}`}>{props.gauche}</span>
        <span className="text-right text-slate-400">{props.droite}</span>
      </div>
    </div>
  );
}

function Bloc({
  titre,
  icone,
  droite,
  children,
}: {
  titre: string;
  icone: React.ReactNode;
  droite?: React.ReactNode;
  children: React.ReactNode;
}) {
  return (
    <section className="rounded-3xl border border-slate-800 bg-slate-900/90 p-6 shadow-xl sm:p-8">
      <div className="mb-6 flex items-center justify-between gap-3 border-b border-slate-800 pb-4">
        <div className="flex items-center gap-2">
          {icone}
          <h2 className="font-display text-lg font-bold text-white">{titre}</h2>
        </div>
        {droite}
      </div>
      {children}
    </section>
  );
}

function Vide({ children }: { children: React.ReactNode }) {
  return (
    <p className="rounded-2xl border border-dashed border-slate-800 p-6 text-center text-xs text-slate-400">
      {children}
    </p>
  );
}

function Raccourci({
  to,
  icone,
  titre,
  children,
}: {
  to: "/admin/utilisateurs" | "/admin/banque" | "/admin/demandes";
  icone: React.ReactNode;
  titre: string;
  children: React.ReactNode;
}) {
  return (
    <Link
      to={to}
      className="group rounded-3xl border border-slate-800 bg-slate-900/90 p-6 shadow-xl transition hover:border-emerald-500/50"
    >
      <div className="flex items-center justify-between">
        <div className="flex size-12 items-center justify-center rounded-2xl bg-emerald-500/15 text-emerald-400">
          {icone}
        </div>
        <ArrowUpRight className="size-5 text-slate-500 transition-colors group-hover:text-emerald-400" />
      </div>
      <h3 className="mt-4 font-display text-lg font-bold text-white">{titre}</h3>
      <p className="mt-2 text-xs leading-relaxed text-slate-300">{children}</p>
    </Link>
  );
}
