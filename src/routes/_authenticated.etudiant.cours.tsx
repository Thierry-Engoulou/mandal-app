import { createFileRoute, Link, Outlet } from "@tanstack/react-router";
import {
  ChevronRight,
  GraduationCap,
  Search,
  BookOpen,
  Atom,
  Calculator,
  Compass,
  CheckCircle2,
  Sparkles,
  Layers,
  Filter,
} from "lucide-react";
import { useMemo, useState } from "react";
import {
  useStudentProgrammes,
  useAllClasses,
  useJoinClass,
  type ProgrammeSummary,
} from "@/lib/use-student-programmes";
import { Input } from "@/components/ui/input";
import { Progress } from "@/components/ui/progress";
import { Button } from "@/components/ui/button";
import { toast } from "sonner";

export const Route = createFileRoute("/_authenticated/etudiant/cours")({
  component: () => <Outlet />,
});

const DEFAULT_COURSES_BY_LEVEL: Record<string, ProgrammeSummary[]> = {
  bac: [
    {
      id: "curated-bac-maths",
      titre: "Mathématiques Générales — Terminale C & D",
      description: "Analyse réelle, limites & continuité, dérivabilité, primitives & intégrales, fonctions exponentielles et logarithmiques, suites numériques, nombres complexes, probabilités et dénombrement.",
      matiereNom: "Mathématiques",
      classeNom: "Baccalauréat (Séries C & D)",
      totalConcepts: 24,
      conceptsTermines: 0,
    },
    {
      id: "curated-bac-physique",
      titre: "Physique Générale — Terminale C, D & TI",
      description: "Cinématique et dynamique newtonienne, mouvement dans un champ uniforme, oscillateurs mécaniques, circuits RLC en régime sinusoïdal forcé, résonance, optique ondulatoire et interférences.",
      matiereNom: "Physique-Chimie",
      classeNom: "Baccalauréat (Séries C & D)",
      totalConcepts: 18,
      conceptsTermines: 0,
    },
    {
      id: "curated-bac-chimie",
      titre: "Chimie des Solutions & Synthèse Organique",
      description: "Acides et bases en solution aqueuse, pH-métrie, cinétique chimique, estérification, composés aromatiques et alcools.",
      matiereNom: "Physique-Chimie",
      classeNom: "Baccalauréat (Séries C & D)",
      totalConcepts: 12,
      conceptsTermines: 0,
    },
    {
      id: "curated-bac-svt",
      titre: "Sciences de la Vie et de la Terre — Terminale D",
      description: "Génétique mendélienne, transmission des caractères héréditaires, régulation de la glycémie, système immunitaire et neurophysiologie.",
      matiereNom: "SVT",
      classeNom: "Baccalauréat Série D",
      totalConcepts: 14,
      conceptsTermines: 0,
    },
  ],
  probatoire: [
    {
      id: "curated-prob-maths",
      titre: "Mathématiques Générales — Première C & D",
      description: "Polynômes du second degré, barycentres, produit scalaire, trigonométrie, dérivation et études de fonctions rationnelles.",
      matiereNom: "Mathématiques",
      classeNom: "Probatoire (Séries C & D)",
      totalConcepts: 16,
      conceptsTermines: 0,
    },
    {
      id: "curated-prob-physique",
      titre: "Physique Appliquée — Première C & D",
      description: "Travail et puissance mécanique, énergie cinétique et potentielle, calorimétrie, champ électrostatique et loi d'Ohm.",
      matiereNom: "Physique-Chimie",
      classeNom: "Probatoire (Séries C & D)",
      totalConcepts: 14,
      conceptsTermines: 0,
    },
  ],
  bepc: [
    {
      id: "curated-bepc-maths",
      titre: "Mathématiques — Classe de 3ème / BEPC",
      description: "Calcul numérique, théorème de Thalès, trigonométrie dans le triangle rectangle, équations et inéquations du premier degré, géométrie dans l'espace.",
      matiereNom: "Mathématiques",
      classeNom: "BEPC (3ème)",
      totalConcepts: 12,
      conceptsTermines: 0,
    },
    {
      id: "curated-bepc-pc",
      titre: "Sciences Physiques & Chimie — 3ème",
      description: "Le courant électrique continu, la masse volumique, les solutions acides et basiques, la combustion des métaux et des hydrocarbures.",
      matiereNom: "Physique-Chimie",
      classeNom: "BEPC (3ème)",
      totalConcepts: 10,
      conceptsTermines: 0,
    },
  ],
  enspd: [
    {
      id: "curated-enspd-meca",
      titre: "Mécanique du Point & Systèmes Matériels (Concours ENSPD)",
      description: "Cinématique en coordonnées cylindriques et sphériques, théorèmes de l'énergie cinétique, oscillateur harmonique amorti, moments cinétiques et forces centrales.",
      matiereNom: "Physique-Chimie",
      classeNom: "Concours ENSPD (Polytechnique)",
      totalConcepts: 15,
      conceptsTermines: 0,
    },
    {
      id: "curated-enspd-maths",
      titre: "Algèbre Linéaire & Analyse Avancée (Concours ENSPD)",
      description: "Espaces vectoriels, matrices et déterminants, diagonalisation, développements limités, équations différentielles linéaires d'ordre 2.",
      matiereNom: "Mathématiques",
      classeNom: "Concours ENSPD (Polytechnique)",
      totalConcepts: 16,
      conceptsTermines: 0,
    },
  ],
  iut: [
    {
      id: "curated-iut-elec",
      titre: "Électrotechnique, RLC & Circuits Diode (Concours IUT)",
      description: "Régimes transitoires du premier et second ordre, quadripôles, filtrage passif, diodes et redressement, puissances active et réactive en alternatif.",
      matiereNom: "Physique-Chimie",
      classeNom: "Concours IUT Douala & Bandjoun",
      totalConcepts: 14,
      conceptsTermines: 0,
    },
    {
      id: "curated-iut-maths",
      titre: "Mathématiques Appliquées & Calcul Matriciel (IUT)",
      description: "Calcul intégral et différentiel appliqué aux sciences de l'ingénieur, calcul matriciel et systèmes linéaires.",
      matiereNom: "Mathématiques",
      classeNom: "Concours IUT",
      totalConcepts: 12,
      conceptsTermines: 0,
    },
  ],
};

export function StudentCoursesIndexPage() {
  const [selectedClassId, setSelectedClassId] = useState<string>("all");
  const { data: dbClasses = [] } = useAllClasses();
  const { data: rawProgrammes = [], isLoading, isError } = useStudentProgrammes(
    selectedClassId === "all" ? null : selectedClassId,
  );
  const joinClassMutation = useJoinClass();
  const [search, setSearch] = useState("");

  // Combiner les cours de Supabase et le catalogue correspondant à la classe sélectionnée
  const programmes = useMemo(() => {
    if (rawProgrammes.length > 0) return rawProgrammes;

    // Si la table de programmes Supabase n'a pas encore de cours spécifiques pour cette classe, on charge le syllabus correspondant
    const levelKey =
      selectedClassId === "all"
        ? "bac"
        : selectedClassId.includes("bepc")
        ? "bepc"
        : selectedClassId.includes("prob")
        ? "probatoire"
        : selectedClassId.includes("enspd")
        ? "enspd"
        : selectedClassId.includes("iut")
        ? "iut"
        : "bac";

    return DEFAULT_COURSES_BY_LEVEL[levelKey] || DEFAULT_COURSES_BY_LEVEL.bac;
  }, [rawProgrammes, selectedClassId]);

  const filtered = useMemo(() => {
    const q = search.trim().toLowerCase();
    if (!q) return programmes;
    return programmes.filter(
      (p) =>
        p.titre.toLowerCase().includes(q) ||
        (p.matiereNom ?? "").toLowerCase().includes(q) ||
        (p.classeNom ?? "").toLowerCase().includes(q) ||
        (p.description ?? "").toLowerCase().includes(q),
    );
  }, [programmes, search]);

  const handleJoinClass = async (classId: string) => {
    try {
      await joinClassMutation.mutateAsync(classId);
      toast.success("Vous êtes désormais inscrit à cette classe ! Vos cours sont synchronisés.");
    } catch (err: unknown) {
      const msg = err instanceof Error ? err.message : "Erreur lors de l'inscription à la classe";
      toast.error(msg);
    }
  };

  return (
    <div className="space-y-6">
      {/* Header avec sélecteur de classe */}
      <header className="gradient-welcome rounded-2xl p-6 text-primary-foreground shadow-sm md:p-8">
        <div className="flex flex-col md:flex-row md:items-center md:justify-between gap-4">
          <div>
            <p className="text-xs font-bold uppercase tracking-wide opacity-80">Espace Pédagogique M'Andal</p>
            <h1 className="mt-1 font-display text-2xl font-bold md:text-3xl">
              📚 Vos cours &amp; Programmes de classe
            </h1>
            <p className="mt-2 max-w-2xl text-sm opacity-90">
              Tous les cours, fiches de synthèse, exercices et simulations enregistrés dans la base de données pour votre classe.
            </p>
          </div>

          <div className="shrink-0 bg-background/10 backdrop-blur-md p-3 rounded-xl border border-white/20">
            <label className="block text-xs font-bold uppercase tracking-wider text-primary-foreground/90 mb-1.5">
              Classe / Niveau actif
            </label>
            <select
              value={selectedClassId}
              onChange={(e) => setSelectedClassId(e.target.value)}
              className="rounded-lg bg-card px-3 py-2 text-sm font-bold text-foreground shadow-sm focus:outline-none focus:ring-2 focus:ring-primary"
            >
              <option value="all">🌐 Tous les cours disponibles</option>
              <optgroup label="Niveaux Scolaires">
                <option value="bac">Baccalauréat (Séries A · C · D)</option>
                <option value="probatoire">Probatoire (Séries A · C · D · TI)</option>
                <option value="bepc">BEPC (3ème · Premier cycle)</option>
              </optgroup>
              <optgroup label="Grands Concours">
                <option value="enspd">Concours ENSPD (Polytechnique Douala)</option>
                <option value="iut">Concours IUT (Filières Technologiques)</option>
              </optgroup>
              {dbClasses.length > 0 && (
                <optgroup label="Classes enregistrées dans Supabase">
                  {dbClasses.map((c) => (
                    <option key={c.id} value={c.id}>
                      {c.nom} {c.niveau ? `(${c.niveau})` : ""}
                    </option>
                  ))}
                </optgroup>
              )}
            </select>
          </div>
        </div>
      </header>

      {/* Barre d'outils et recherche */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div className="relative flex-1 max-w-md">
          <Search className="absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground" />
          <Input
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            placeholder="Rechercher un cours, une matière (Maths, Physique...)"
            className="rounded-xl pl-9 bg-card"
            aria-label="Rechercher un programme"
          />
        </div>

        {selectedClassId.length > 10 && (
          <Button
            variant="outline"
            size="sm"
            onClick={() => handleJoinClass(selectedClassId)}
            disabled={joinClassMutation.isPending}
            className="rounded-xl border-primary text-primary hover:bg-primary/10 font-bold"
          >
            <CheckCircle2 className="mr-1.5 size-4" />
            {joinClassMutation.isPending ? "Synchronisation…" : "Définir comme ma classe"}
          </Button>
        )}
      </div>

      {/* Raccourcis pédagogiques rapides */}
      <div className="grid grid-cols-2 sm:grid-cols-4 gap-3">
        <div className="flex items-center gap-3 rounded-xl border border-emerald-500/20 bg-emerald-500/5 p-3">
          <span className="flex size-9 items-center justify-center rounded-lg bg-emerald-500/10 text-emerald-600 dark:text-emerald-400">
            <Calculator className="size-5" />
          </span>
          <div>
            <p className="text-xs font-bold text-foreground">Mathématiques</p>
            <p className="text-[11px] text-muted-foreground">Analyse &amp; Algèbre</p>
          </div>
        </div>

        <div className="flex items-center gap-3 rounded-xl border border-teal-500/20 bg-teal-500/5 p-3">
          <span className="flex size-9 items-center justify-center rounded-lg bg-teal-500/10 text-teal-600 dark:text-teal-400">
            <Atom className="size-5" />
          </span>
          <div>
            <p className="text-xs font-bold text-foreground">Physique-Chimie</p>
            <p className="text-[11px] text-muted-foreground">Mécanique &amp; RLC</p>
          </div>
        </div>

        <div className="flex items-center gap-3 rounded-xl border border-blue-500/20 bg-blue-500/5 p-3">
          <span className="flex size-9 items-center justify-center rounded-lg bg-blue-500/10 text-blue-600 dark:text-blue-400">
            <Compass className="size-5" />
          </span>
          <div>
            <p className="text-xs font-bold text-foreground">Simulations</p>
            <p className="text-[11px] text-muted-foreground">GeoGebra interactif</p>
          </div>
        </div>

        <div className="flex items-center gap-3 rounded-xl border border-amber-500/20 bg-amber-500/5 p-3">
          <span className="flex size-9 items-center justify-center rounded-lg bg-amber-500/10 text-amber-600 dark:text-amber-400">
            <BookOpen className="size-5" />
          </span>
          <div>
            <p className="text-xs font-bold text-foreground">Épreuves &amp; Quiz</p>
            <p className="text-[11px] text-muted-foreground">Annales corrigées</p>
          </div>
        </div>
      </div>

      {/* Liste des cours & programmes */}
      {isLoading ? (
        <div className="space-y-3">
          {[0, 1, 2, 3].map((i) => (
            <div key={i} className="h-28 animate-pulse rounded-2xl bg-card shadow-sm" />
          ))}
        </div>
      ) : isError ? (
        <div className="rounded-2xl border border-destructive/30 bg-card p-8 text-center">
          <p className="text-sm text-muted-foreground">
            Impossible de charger les programmes de la base de données. Réessayez dans un instant.
          </p>
        </div>
      ) : filtered.length === 0 ? (
        <div className="rounded-2xl border border-dashed border-border p-10 text-center">
          <p className="font-display text-lg font-bold">Aucun cours trouvé</p>
          <p className="mt-2 text-sm text-muted-foreground">
            Aucun programme ne correspond à votre filtre de classe ou à votre recherche.
          </p>
        </div>
      ) : (
        <div className="space-y-3">
          <div className="flex items-center justify-between text-xs text-muted-foreground px-1">
            <span>
              <strong>{filtered.length} cours</strong> disponibles pour cette sélection
            </span>
            <span className="flex items-center gap-1">
              <Sparkles className="size-3.5 text-primary" /> Synchronisé avec Supabase
            </span>
          </div>

          <ul className="space-y-3">
            {filtered.map((p) => {
              const pct = p.totalConcepts > 0 ? Math.round((p.conceptsTermines / p.totalConcepts) * 100) : 0;
              const isCurated = p.id.startsWith("curated-");

              return (
                <li key={p.id}>
                  <Link
                    to={isCurated ? "/education" : "/etudiant/cours/$programmeId"}
                    params={isCurated ? {} : { programmeId: p.id }}
                    className="flex flex-col sm:flex-row sm:items-center justify-between gap-4 rounded-2xl bg-card p-5 sm:p-6 shadow-sm border border-border/80 transition-all hover:border-primary/50 hover:shadow-md hover:bg-secondary/40"
                  >
                    <div className="flex items-start gap-4 min-w-0 flex-1">
                      <span className="flex size-12 shrink-0 items-center justify-center rounded-xl bg-primary/10 text-primary mt-0.5">
                        <GraduationCap className="size-6" />
                      </span>
                      <div className="min-w-0 flex-1">
                        <div className="flex flex-wrap items-center gap-2">
                          <p className="font-display text-base sm:text-lg font-bold text-foreground">{p.titre}</p>
                        </div>
                        {p.description && (
                          <p className="mt-1 text-xs sm:text-sm text-muted-foreground line-clamp-2 leading-relaxed">
                            {p.description}
                          </p>
                        )}
                        <div className="mt-2.5 flex flex-wrap items-center gap-2">
                          {p.matiereNom ? (
                            <span className="rounded-full bg-primary/10 px-2.5 py-0.5 text-xs font-bold text-primary">
                              {p.matiereNom}
                            </span>
                          ) : null}
                          {p.classeNom ? (
                            <span className="rounded-full bg-secondary px-2.5 py-0.5 text-xs font-semibold text-muted-foreground">
                              {p.classeNom}
                            </span>
                          ) : null}
                          <span className="rounded-full bg-secondary px-2.5 py-0.5 text-xs font-medium text-muted-foreground">
                            {p.totalConcepts} leçons / chapitres
                          </span>
                        </div>
                      </div>
                    </div>

                    <div className="flex items-center justify-between sm:justify-end gap-4 shrink-0 sm:border-l sm:border-border sm:pl-5">
                      <div className="text-left sm:text-right">
                        <span className="text-xs font-semibold text-muted-foreground block">Progression</span>
                        <div className="mt-1 flex items-center gap-2">
                          <Progress value={pct} className="h-2 w-24" />
                          <span className="text-xs font-bold text-foreground">{pct}%</span>
                        </div>
                      </div>

                      <Button size="sm" className="rounded-xl gap-1.5 font-bold shrink-0">
                        <span>{p.conceptsTermines > 0 ? "Continuer" : "Accéder au cours"}</span>
                        <ChevronRight className="size-4" />
                      </Button>
                    </div>
                  </Link>
                </li>
              );
            })}
          </ul>
        </div>
      )}
    </div>
  );
}

