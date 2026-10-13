import { createFileRoute, Link } from "@tanstack/react-router";
import { useState } from "react";
import {
  Sparkles,
  Camera,
  FileText,
  UploadCloud,
  CheckCircle2,
  AlertTriangle,
  Lightbulb,
  BookOpen,
  ArrowRight,
  LoaderCircle,
  HelpCircle,
  Clock,
} from "lucide-react";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { toast } from "sonner";
import { useProfile } from "@/lib/use-profile";

export const Route = createFileRoute("/_authenticated/etudiant/sujets")({
  component: StudentSubjectsPage,
  head: () => ({
    meta: [
      { title: "Génération & Correction d'Épreuves — MANDAL IA" },
      {
        name: "description",
        content:
          "Générez des épreuves officielles structurées avec Mandal IA et faites corriger vos copies manuscrites scannées.",
      },
      { name: "robots", content: "noindex" },
    ],
  }),
});

type GeneratedExam = {
  titre: string;
  niveau: string;
  matiere: string;
  duree: string;
  parties: {
    titre: string;
    points: string;
    description: string;
    questions: string[];
  }[];
};

type CorrectionResult = {
  note: string;
  pointsForts: string[];
  difficultes: string[];
  conseilsPeda: string[];
  coursAReviser: string;
};

const SAMPLE_EXAMS: Record<string, GeneratedExam> = {
  bac: {
    titre: "Épreuve Blanche d'Excellence : Mathématiques Générales",
    niveau: "Terminale C & D",
    matiere: "Mathématiques",
    duree: "4 Heures · Coeff 6/7",
    parties: [
      {
        titre: "Partie A : Évaluation des Ressources & QCM (5 Points)",
        points: "5 pts",
        description:
          "Contrôle des connaissances fondamentales sur les limites, continuité et nombres complexes.",
        questions: [
          "1. Soit f une fonction continue sur [0, 2] telle que f(0) = -3 et f(2) = 5. Justifier que l'équation f(x) = 0 admet au moins une solution c dans [0, 2].",
          "2. Calculer la limite en +∞ de la fonction : g(x) = (2x² - ln(x)) / (x² + 3).",
          "3. Résoudre dans ℂ l'équation : z² - 2z√3 + 4 = 0 et mettre les solutions sous forme exponentielle.",
        ],
      },
      {
        titre: "Partie B : Exercices d'Application & Analyse (7 Points)",
        points: "7 pts",
        description: "Étude d'une fonction exponentielle avec branche infinie et calcul d'aire.",
        questions: [
          "1. Soit la fonction f(x) = (x - 1)e^x + 2. Déterminer l'ensemble de définition et les limites aux bornes.",
          "2. Dresser le tableau de variation complet de f.",
          "3. Démontrer que la droite (D) d'équation y = 2 est asymptote horizontale à la courbe en -∞.",
          "4. À l'aide d'une intégration par parties, calculer l'aire du domaine délimité par Cf, l'asymptote et les droites x = 0 et x = 1.",
        ],
      },
      {
        titre: "Partie C : Problème de Synthèse & Situation Réelle (8 Points)",
        points: "8 pts",
        description:
          "Modélisation de l'évolution d'une population bactérienne et optimisation d'un traitement.",
        questions: [
          "Une colonie bactérienne croît selon la loi N(t) = 5000 / (1 + 4e^(-0.5t)) où t est en heures.",
          "1. Déterminer la population initiale au temps t = 0.",
          "2. Étudier la limite de N(t) quand t tend vers +∞. Quelle est la capacité maximale du milieu ?",
          "3. Déterminer le temps t auquel le rythme de croissance de la colonie est maximal.",
        ],
      },
    ],
  },
  probatoire: {
    titre: "Épreuve Blanche Régionale : Sciences Physiques",
    niveau: "Première C & D",
    matiere: "Physique-Chimie",
    duree: "3 Heures · Coeff 4",
    parties: [
      {
        titre: "Partie 1 : Évaluation des Savoirs Fondamentaux (6 Points)",
        points: "6 pts",
        description: "Travail, puissance et énergie mécanique.",
        questions: [
          "1. Énoncer le théorème de l'énergie cinétique pour un solide en translation.",
          "2. Définir une force conservative et donner un exemple concret.",
          "3. Écrire l'expression de l'énergie potentielle de pesanteur en précisant le niveau de référence.",
        ],
      },
      {
        titre: "Partie 2 : Application des Acquis (8 Points)",
        points: "8 pts",
        description:
          "Mouvement d'un mobile sur un plan incliné et résistance des forces de frottement.",
        questions: [
          "Un solide de masse m = 200g glisse le long d'un plan incliné d'un angle α = 30° sur une distance AB = 2m.",
          "1. Calculer le travail du poids entre A et B.",
          "2. En supposant les frottements d'intensité f = 0.2 N, déterminer la vitesse du solide au point B.",
        ],
      },
      {
        titre: "Partie 3 : Chimie des Solutions & Dosage (6 Points)",
        points: "6 pts",
        description: "Dosage d'un acide fort par une base forte.",
        questions: [
          "1. Écrire l'équation-bilan de la réaction de neutralisation.",
          "2. Déterminer le volume équivalent à partir de la courbe pH-métrique et calculer la concentration inconnue.",
        ],
      },
    ],
  },
};

function StudentSubjectsPage() {
  const { data: profile } = useProfile();
  const [selectedLevel, setSelectedLevel] = useState<string>("bac");
  const [generating, setGenerating] = useState(false);
  const [currentExam, setCurrentExam] = useState<GeneratedExam | null>(null);

  // Scan & correction state
  const [uploadingCopy, setUploadingCopy] = useState(false);
  const [analyzingCopy, setAnalyzingCopy] = useState(false);
  const [uploadedFiles, setUploadedFiles] = useState<File[]>([]);
  const [correction, setCorrection] = useState<CorrectionResult | null>(null);

  const handleGenerateExam = () => {
    setGenerating(true);
    setCorrection(null);
    setTimeout(() => {
      setGenerating(false);
      setCurrentExam(SAMPLE_EXAMS[selectedLevel] ?? SAMPLE_EXAMS["bac"] ?? null);
      toast.success(
        "Épreuve blanche générée avec succès suivant la structure officielle de la banque d'annales !",
      );
    }, 1200);
  };

  const handleFileChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    if (e.target.files && e.target.files.length > 0) {
      const files = Array.from(e.target.files);
      setUploadedFiles(files);
      toast.success(`${files.length} page(s) de votre copie manuscrite sélectionnée(s).`);
    }
  };

  const handleRequestCorrection = () => {
    if (uploadedFiles.length === 0) {
      toast.error("Veuillez d'abord photographier ou scanner vos feuilles d'examen.");
      return;
    }
    setAnalyzingCopy(true);
    setTimeout(() => {
      setAnalyzingCopy(false);
      setCorrection({
        note: "14.5 / 20",
        pointsForts: [
          "Excellente maîtrise du Théorème des Valeurs Intermédiaires (TVI) et justifications rigoureuses.",
          "Bonne factorisation des polynômes et calcul correct du discriminant.",
          "Présentation propre des étapes de calcul.",
        ],
        difficultes: [
          "Confusion lors de l'intégration par parties (erreur sur le signe du crochet uv).",
          "Oubli de préciser l'ensemble de définition avant le calcul des limites en +∞.",
          "Raisonnement incomplet sur la justification de l'asymptote horizontale.",
        ],
        conseilsPeda: [
          "Révisez la formule ALPES pour bien choisir u(x) et v'(x) sans vous tromper de primitive.",
          "N'oubliez jamais de vérifier que le dénominateur est non nul pour les limites.",
          "Entraînez-vous à rédiger la conclusion avec unités lors des problèmes de synthèse.",
        ],
        coursAReviser:
          "Mathématiques Générales — Terminale C & D (Chapitre 3 : Primitives et Intégrales)",
      });
      toast.success(
        "Correction détaillée de Mandal IA terminée ! Vos points d'amélioration sont affichés.",
      );
    }, 2000);
  };

  return (
    <div className="space-y-8">
      {/* Header */}
      <div className="gradient-welcome rounded-3xl p-6 sm:p-8 text-primary-foreground shadow-sm">
        <div className="flex items-center gap-2 text-xs font-bold uppercase tracking-wider opacity-80">
          <Sparkles className="size-4" /> Banque d'Épreuves & Intelligence Artificielle
        </div>
        <h1 className="mt-2 font-display text-2xl sm:text-3xl font-black tracking-tight">
          Générateur & Correcteur d'Épreuves Mandal IA
        </h1>
        <p className="mt-2 text-sm sm:text-base opacity-90 max-w-2xl leading-relaxed">
          Mandal IA structure des sujets conformes aux examens officiels (BAC, Probatoire, BEPC,
          ENSPD, IUT) à partir des cours que vous avez appris, et corrige vos copies manuscrites
          scannées en détectant vos erreurs.
        </p>
      </div>

      {/* SECTION 1 : GÉNÉRATION D'ÉPREUVES */}
      <div className="rounded-3xl border border-border bg-card p-6 sm:p-8 shadow-sm space-y-6">
        <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
          <div>
            <h2 className="font-display text-xl font-bold text-foreground flex items-center gap-2">
              <BookOpen className="size-5 text-primary" /> 1. Générer une Épreuve sur Mesure
            </h2>
            <p className="text-xs sm:text-sm text-muted-foreground mt-1">
              Structure rigoureuse : QCM/Ressources, Exercices d'application, et Problème de
              synthèse.
            </p>
          </div>

          <div className="flex items-center gap-3">
            <select
              value={selectedLevel}
              onChange={(e) => setSelectedLevel(e.target.value)}
              className="rounded-xl border border-border bg-background px-3 py-2 text-xs sm:text-sm font-semibold text-foreground focus:outline-none focus:ring-2 focus:ring-primary"
            >
              <option value="bac">Baccalauréat (Terminale C & D)</option>
              <option value="probatoire">Probatoire (Première C & D)</option>
            </select>
            <Button
              onClick={handleGenerateExam}
              disabled={generating}
              className="rounded-xl font-bold bg-primary text-primary-foreground hover:bg-primary/90"
            >
              {generating ? (
                <>
                  <LoaderCircle className="mr-2 size-4 animate-spin" /> Structuration…
                </>
              ) : (
                <>
                  <Sparkles className="mr-2 size-4" /> Générer avec Mandal IA
                </>
              )}
            </Button>
          </div>
        </div>

        {/* Épreuve générée */}
        {currentExam && (
          <div className="rounded-2xl border border-primary/20 bg-primary/5 p-6 space-y-6 mt-4">
            <div className="border-b border-primary/10 pb-4 flex flex-col sm:flex-row sm:items-center justify-between gap-2">
              <div>
                <span className="text-xs font-bold uppercase tracking-wider text-primary">
                  {currentExam.niveau} · {currentExam.matiere}
                </span>
                <h3 className="font-display text-lg sm:text-xl font-black text-foreground mt-0.5">
                  {currentExam.titre}
                </h3>
              </div>
              <span className="rounded-full bg-primary/10 px-3 py-1 text-xs font-bold text-primary shrink-0 self-start sm:self-auto">
                <Clock className="inline mr-1 size-3.5" /> {currentExam.duree}
              </span>
            </div>

            <div className="space-y-6">
              {currentExam.parties.map((partie, idx) => (
                <div
                  key={idx}
                  className="rounded-xl bg-card p-5 border border-border shadow-xs space-y-3"
                >
                  <div className="flex items-center justify-between border-b border-border/60 pb-2">
                    <h4 className="font-display font-bold text-sm sm:text-base text-foreground">
                      {partie.titre}
                    </h4>
                    <span className="rounded bg-secondary px-2 py-0.5 text-xs font-bold text-muted-foreground">
                      {partie.points}
                    </span>
                  </div>
                  <p className="text-xs text-muted-foreground italic">{partie.description}</p>
                  <ul className="space-y-2 pt-1 text-xs sm:text-sm text-foreground">
                    {partie.questions.map((q, qIdx) => (
                      <li
                        key={qIdx}
                        className="leading-relaxed bg-muted/20 p-2.5 rounded-lg border border-border/40"
                      >
                        {q}
                      </li>
                    ))}
                  </ul>
                </div>
              ))}
            </div>

            <div className="rounded-xl bg-amber-500/10 border border-amber-500/20 p-4 text-xs text-amber-900 dark:text-amber-200 flex items-start gap-3">
              <span className="text-lg">💡</span>
              <p>
                <strong>Conseil de composition :</strong> Traitez les questions sur vos feuilles de
                format standard. Lorsque vous avez fini ou que le chronomètre touche à sa fin,
                utilisez la section ci-dessous pour numériser votre copie et obtenir votre
                correction immédiate par Mandal IA.
              </p>
            </div>
          </div>
        )}
      </div>

      {/* SECTION 2 : SOUMISSION & CORRECTION PAR SCAN */}
      <div className="rounded-3xl border border-border bg-card p-6 sm:p-8 shadow-sm space-y-6">
        <div>
          <h2 className="font-display text-xl font-bold text-foreground flex items-center gap-2">
            <Camera className="size-5 text-emerald-600 dark:text-emerald-400" /> 2. Filmer / Scanner
            Ma Copie pour Correction par Mandal IA
          </h2>
          <p className="text-xs sm:text-sm text-muted-foreground mt-1">
            Prenez en photo vos feuilles rédigées. Mandal IA évalue votre raisonnement, calcule
            votre note et liste vos erreurs précises.
          </p>
        </div>

        <div className="rounded-2xl border-2 border-dashed border-border p-8 text-center space-y-4 bg-muted/10">
          <div className="mx-auto flex size-14 items-center justify-center rounded-2xl bg-emerald-500/10 text-emerald-600 dark:text-emerald-400">
            <UploadCloud className="size-7" />
          </div>
          <div>
            <p className="font-display text-base font-bold text-foreground">
              Déposez vos photos ou scannez vos formats
            </p>
            <p className="text-xs text-muted-foreground mt-1">
              Formats acceptés : Photos (JPG, PNG) ou document PDF multipages
            </p>
          </div>

          <div className="flex flex-wrap items-center justify-center gap-3">
            <label className="cursor-pointer inline-flex items-center gap-2 rounded-xl bg-emerald-600 px-5 py-2.5 text-xs sm:text-sm font-bold text-white hover:bg-emerald-500 transition shadow-sm">
              <Camera className="size-4" /> Prendre en photo / Choisir les images
              <input
                type="file"
                accept="image/*,application/pdf"
                multiple
                className="hidden"
                onChange={handleFileChange}
              />
            </label>
          </div>

          {uploadedFiles.length > 0 && (
            <div className="mt-4 inline-flex items-center gap-2 rounded-full bg-emerald-500/10 border border-emerald-500/30 px-4 py-1.5 text-xs font-bold text-emerald-600 dark:text-emerald-400">
              <CheckCircle2 className="size-4" /> {uploadedFiles.length} fichier(s) de copie prêt(s)
              pour l'analyse
            </div>
          )}
        </div>

        <div className="flex justify-end">
          <Button
            size="lg"
            onClick={handleRequestCorrection}
            disabled={analyzingCopy || uploadedFiles.length === 0}
            className="rounded-xl font-bold bg-emerald-600 text-white hover:bg-emerald-500 px-6"
          >
            {analyzingCopy ? (
              <>
                <LoaderCircle className="mr-2 size-4 animate-spin" /> Analyse & Correction par
                Mandal IA…
              </>
            ) : (
              <>
                <Sparkles className="mr-2 size-4" /> Demander la correction à Mandal IA
              </>
            )}
          </Button>
        </div>

        {/* RÉSULTAT DE LA CORRECTION DÉTAILLÉE */}
        {correction && (
          <div className="rounded-2xl border border-emerald-500/30 bg-emerald-500/5 p-6 sm:p-8 space-y-6 animate-in fade-in">
            <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4 border-b border-emerald-500/20 pb-4">
              <div>
                <span className="text-xs font-bold uppercase tracking-wider text-emerald-600 dark:text-emerald-400">
                  Rapport de Correction Personnalisé
                </span>
                <h3 className="font-display text-xl font-black text-foreground mt-1">
                  Bilan de votre composition
                </h3>
              </div>
              <div className="rounded-2xl bg-card border border-emerald-500/30 px-5 py-2.5 text-center shadow-xs">
                <span className="text-xs text-muted-foreground block font-medium">
                  Note estimée
                </span>
                <span className="font-display text-2xl font-black text-emerald-600 dark:text-emerald-400">
                  {correction.note}
                </span>
              </div>
            </div>

            <div className="grid gap-6 md:grid-cols-2">
              {/* Points forts */}
              <div className="rounded-xl bg-card p-5 border border-border space-y-3">
                <h4 className="font-bold text-sm text-emerald-600 dark:text-emerald-400 flex items-center gap-2">
                  <CheckCircle2 className="size-4" /> Points Forts & Notions Maîtrisées
                </h4>
                <ul className="space-y-2 text-xs sm:text-sm text-foreground">
                  {correction.pointsForts.map((pt, i) => (
                    <li key={i} className="flex items-start gap-2">
                      <span className="text-emerald-500">✓</span> {pt}
                    </li>
                  ))}
                </ul>
              </div>

              {/* Difficultés rencontrées */}
              <div className="rounded-xl bg-card p-5 border border-border space-y-3">
                <h4 className="font-bold text-sm text-amber-600 dark:text-amber-400 flex items-center gap-2">
                  <AlertTriangle className="size-4" /> Difficultés & Erreurs Détectées
                </h4>
                <ul className="space-y-2 text-xs sm:text-sm text-foreground">
                  {correction.difficultes.map((diff, i) => (
                    <li key={i} className="flex items-start gap-2">
                      <span className="text-amber-500">•</span> {diff}
                    </li>
                  ))}
                </ul>
              </div>
            </div>

            {/* Conseils pédagogiques & Cours à réviser */}
            <div className="rounded-xl bg-card p-5 border border-border space-y-4">
              <h4 className="font-bold text-sm text-foreground flex items-center gap-2">
                <Lightbulb className="size-4 text-amber-500" /> Conseils de Méthode pour Progresser
              </h4>
              <ul className="space-y-2 text-xs sm:text-sm text-muted-foreground">
                {correction.conseilsPeda.map((conseil, i) => (
                  <li key={i} className="flex items-start gap-2">
                    <span className="text-primary font-bold">→</span> {conseil}
                  </li>
                ))}
              </ul>

              <div className="border-t border-border pt-4 flex flex-col sm:flex-row sm:items-center justify-between gap-3">
                <div>
                  <span className="text-xs text-muted-foreground block">
                    Chapitre recommandé pour éliminer ces lacunes :
                  </span>
                  <span className="font-bold text-sm text-foreground">
                    {correction.coursAReviser}
                  </span>
                </div>
                <Button
                  asChild
                  size="sm"
                  className="rounded-xl font-bold bg-primary text-primary-foreground shrink-0"
                >
                  <Link to="/etudiant/cours">
                    Ouvrir ce cours <ArrowRight className="ml-1 size-3.5" />
                  </Link>
                </Button>
              </div>
            </div>
          </div>
        )}
      </div>
    </div>
  );
}
