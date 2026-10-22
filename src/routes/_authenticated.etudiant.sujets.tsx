import { createFileRoute, Link } from "@tanstack/react-router";
import { avecGardeMajorite } from "@/components/garde-majorite";
import { useQuery, useQueryClient } from "@tanstack/react-query";
import { useServerFn } from "@tanstack/react-start";
import { useEffect, useRef, useState } from "react";
import {
  AlarmClock,
  ChevronDown,
  LoaderCircle,
  Printer,
  ScanLine,
  Sparkles,
  Square,
  Timer,
  Trash2,
} from "lucide-react";
import { toast } from "sonner";
import { supabase } from "@/integrations/supabase/client";
import { useProfile } from "@/lib/use-profile";
import { genererEpreuveBlanche } from "@/lib/epreuves-blanches.functions";
import { MATIERES, NIVEAUX, formatDuree } from "@/lib/epreuves";
import { Button } from "@/components/ui/button";
import { Label } from "@/components/ui/label";
import { MathText } from "@/components/math-text";
import { cn } from "@/lib/utils";

export const Route = createFileRoute("/_authenticated/etudiant/sujets")({
  component: avecGardeMajorite(EpreuvesBlanchesPage),
  head: () => ({
    meta: [
      { title: "Épreuves blanches Mandal IA — M'ANDAL" },
      {
        name: "description",
        content:
          "Mandal IA rédige des épreuves blanches sur le modèle des épreuves de la banque M'ANDAL et de tes cours.",
      },
      { name: "robots", content: "noindex" },
    ],
  }),
});

const DUREES = [60, 90, 120, 180, 240];
const selectClass = "w-full rounded-xl border border-border bg-background px-3 py-2.5 text-sm";

type Generated = {
  id: string;
  matiere: string;
  niveau: string;
  duree_minutes: number;
  contenu: string;
  modeles_utilises: number;
  created_at: string;
};

function EpreuvesBlanchesPage() {
  const { data: profile } = useProfile();
  const queryClient = useQueryClient();
  const generer = useServerFn(genererEpreuveBlanche);
  const [matiere, setMatiere] = useState(MATIERES[0]!);
  const [niveau, setNiveau] = useState<string>(NIVEAUX[5]);
  const [duree, setDuree] = useState(120);
  const [theme, setTheme] = useState("");
  const [busy, setBusy] = useState(false);
  const [current, setCurrent] = useState<Generated | null>(null);
  const currentRef = useRef<HTMLDivElement>(null);

  const { data: history = [] } = useQuery({
    enabled: !!profile,
    queryKey: ["epreuves-generees", profile?.id],
    queryFn: async (): Promise<Generated[]> => {
      const { data, error } = await supabase
        .from("epreuves_generees")
        .select("id, matiere, niveau, duree_minutes, contenu, modeles_utilises, created_at")
        .eq("eleve_id", profile!.id)
        .order("created_at", { ascending: false })
        .limit(20);
      if (error) throw new Error(error.message);
      return data ?? [];
    },
  });

  useEffect(() => {
    if (current) currentRef.current?.scrollIntoView({ behavior: "smooth", block: "start" });
  }, [current]);

  const submit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (busy) return;
    setBusy(true);
    try {
      const res = await generer({
        data: {
          matiere,
          niveau,
          dureeMinutes: duree,
          ...(theme.trim() ? { theme: theme.trim() } : {}),
        },
      });
      setCurrent({
        id: res.id,
        matiere,
        niveau,
        duree_minutes: duree,
        contenu: res.contenu,
        modeles_utilises: res.modelesUtilises,
        created_at: new Date().toISOString(),
      });
      await queryClient.invalidateQueries({ queryKey: ["epreuves-generees"] });
    } catch (err) {
      toast.error(err instanceof Error ? err.message : "La génération a échoué.");
    } finally {
      setBusy(false);
    }
  };

  const remove = async (id: string) => {
    if (!confirm("Supprimer cette épreuve blanche ?")) return;
    const { error } = await supabase.from("epreuves_generees").delete().eq("id", id);
    if (error) {
      toast.error(error.message);
      return;
    }
    if (current?.id === id) setCurrent(null);
    await queryClient.invalidateQueries({ queryKey: ["epreuves-generees"] });
  };

  return (
    <div className="space-y-6">
      <header className="gradient-progress rounded-2xl p-6 text-primary-foreground shadow-sm print:hidden">
        <Sparkles className="mb-2 size-6" />
        <h1 className="font-display text-2xl font-bold tracking-tight">
          Épreuves blanches Mandal IA
        </h1>
        <p className="mt-1 max-w-2xl text-sm opacity-90">
          Mandal IA rédige une épreuve inédite sur le modèle des épreuves déposées par les
          enseignants dans la banque M'ANDAL et sur les chapitres que tu as étudiés. Compose sur
          papier, chronomètre en main, puis fais corriger ta copie.
        </p>
      </header>

      <form
        onSubmit={submit}
        className="grid gap-4 rounded-2xl bg-card p-5 shadow-sm md:grid-cols-2 print:hidden"
      >
        <div className="space-y-2">
          <Label htmlFor="g-matiere">Matière</Label>
          <select
            id="g-matiere"
            value={matiere}
            onChange={(e) => setMatiere(e.target.value)}
            className={selectClass}
          >
            {MATIERES.filter((m) => m !== "Autre").map((m) => (
              <option key={m}>{m}</option>
            ))}
          </select>
        </div>
        <div className="space-y-2">
          <Label htmlFor="g-niveau">Niveau</Label>
          <select
            id="g-niveau"
            value={niveau}
            onChange={(e) => setNiveau(e.target.value)}
            className={selectClass}
          >
            {NIVEAUX.map((n) => (
              <option key={n}>{n}</option>
            ))}
          </select>
        </div>
        <div className="space-y-2">
          <Label htmlFor="g-duree">Durée</Label>
          <select
            id="g-duree"
            value={duree}
            onChange={(e) => setDuree(Number(e.target.value))}
            className={selectClass}
          >
            {DUREES.map((d) => (
              <option key={d} value={d}>
                {formatDuree(d)}
              </option>
            ))}
          </select>
        </div>
        <div className="space-y-2">
          <Label htmlFor="g-theme">Insister sur (facultatif)</Label>
          <input
            id="g-theme"
            value={theme}
            onChange={(e) => setTheme(e.target.value)}
            maxLength={500}
            placeholder="Ex. : fonctions logarithmes, suites"
            className={selectClass}
          />
        </div>
        <Button type="submit" disabled={busy} className="h-12 rounded-xl text-base md:col-span-2">
          {busy ? (
            <>
              <LoaderCircle className="animate-spin" /> Mandal IA rédige ton épreuve… (jusqu'à une
              minute)
            </>
          ) : (
            <>
              <Sparkles className="size-4" /> Générer mon épreuve blanche
            </>
          )}
        </Button>
      </form>

      {current ? (
        <div ref={currentRef}>
          <EpreuveView epreuve={current} />
        </div>
      ) : null}

      {history.length > 0 ? (
        <section className="space-y-3 print:hidden">
          <h2 className="font-display text-lg font-bold text-foreground">Mes épreuves blanches</h2>
          {history.map((h) => (
            <HistoryItem
              key={h.id}
              epreuve={h}
              onOpen={() => setCurrent(h)}
              onDelete={() => remove(h.id)}
            />
          ))}
        </section>
      ) : null}
    </div>
  );
}

function EpreuveView({ epreuve }: { epreuve: Generated }) {
  return (
    <section className="space-y-4 rounded-2xl border border-primary/30 bg-card p-5 shadow-sm print:border-0 print:shadow-none">
      <div className="flex flex-wrap items-center justify-between gap-2 print:hidden">
        <p className="text-xs text-muted-foreground">
          {epreuve.modeles_utilises > 0
            ? `Structure calquée sur ${epreuve.modeles_utilises} épreuve(s) de la banque M'ANDAL.`
            : "Aucune épreuve de ce niveau dans la banque : structure officielle du niveau."}
        </p>
        <Button variant="outline" size="sm" className="rounded-xl" onClick={() => window.print()}>
          <Printer className="size-4" /> Imprimer
        </Button>
      </div>
      <Chrono epreuveId={epreuve.id} dureeMinutes={epreuve.duree_minutes} />
      <MathText text={epreuve.contenu} className="text-sm leading-relaxed text-foreground" />
      <div className="rounded-xl bg-secondary/50 p-4 print:hidden">
        <p className="text-sm text-foreground">
          Tu as terminé ? Photographie ta copie : Mandal IA la corrige avec ce sujet, te donne une
          note estimée et t'explique tes difficultés.
        </p>
        <Button asChild className="mt-3 rounded-xl">
          <Link to="/etudiant/correction" search={{ epreuve: epreuve.id }}>
            <ScanLine className="size-4" /> Faire corriger ma copie
          </Link>
        </Button>
      </div>
    </section>
  );
}

/** Chronomètre facultatif (local au navigateur) pour composer dans les conditions de l'examen. */
function Chrono({ epreuveId, dureeMinutes }: { epreuveId: string; dureeMinutes: number }) {
  const key = `mandal.blanche.${epreuveId}`;
  const [startedAt, setStartedAt] = useState<number | null>(() => {
    try {
      const v = localStorage.getItem(key);
      return v ? Number(v) : null;
    } catch {
      return null;
    }
  });
  const [now, setNow] = useState(() => Date.now());
  const alertsRef = useRef<Set<number>>(new Set());

  useEffect(() => {
    if (!startedAt) return;
    const id = setInterval(() => setNow(Date.now()), 1000);
    return () => clearInterval(id);
  }, [startedAt]);

  const remaining = startedAt ? startedAt + dureeMinutes * 60000 - now : dureeMinutes * 60000;

  useEffect(() => {
    if (!startedAt) return;
    for (const m of [30, 5, 0]) {
      if (remaining <= m * 60000 && !alertsRef.current.has(m)) {
        alertsRef.current.add(m);
        if (remaining > (m - 1) * 60000) {
          toast.warning(
            m === 0
              ? "Temps écoulé ! Pose ton stylo et fais corriger ta copie."
              : `Il reste ${m} minutes.`,
          );
        }
      }
    }
  }, [remaining, startedAt]);

  const start = () => {
    const t = Date.now();
    alertsRef.current = new Set();
    setStartedAt(t);
    setNow(t);
    try {
      localStorage.setItem(key, String(t));
    } catch {
      // stockage indisponible : le chrono marche quand même pendant la session
    }
  };
  const stop = () => {
    setStartedAt(null);
    try {
      localStorage.removeItem(key);
    } catch {
      // rien à nettoyer
    }
  };

  const total = Math.max(0, Math.floor(remaining / 1000));
  const label = `${Math.floor(total / 3600)}:${String(Math.floor((total % 3600) / 60)).padStart(2, "0")}:${String(total % 60).padStart(2, "0")}`;

  return (
    <div
      className={cn(
        "flex flex-wrap items-center justify-between gap-3 rounded-xl p-3 print:hidden",
        !startedAt
          ? "bg-secondary/60"
          : remaining <= 0
            ? "bg-destructive text-white"
            : remaining <= 30 * 60000
              ? "bg-amber-500 text-white"
              : "bg-primary text-primary-foreground",
      )}
    >
      <span className="flex items-center gap-2 font-display text-xl font-bold tabular-nums">
        <AlarmClock className="size-5" /> {remaining <= 0 && startedAt ? "Temps écoulé" : label}
      </span>
      {startedAt ? (
        <Button size="sm" variant="secondary" className="rounded-xl" onClick={stop}>
          <Square className="size-4" /> Arrêter
        </Button>
      ) : (
        <Button size="sm" className="rounded-xl" onClick={start}>
          <Timer className="size-4" /> Démarrer le chrono ({formatDuree(dureeMinutes)})
        </Button>
      )}
    </div>
  );
}

function HistoryItem({
  epreuve,
  onOpen,
  onDelete,
}: {
  epreuve: Generated;
  onOpen: () => void;
  onDelete: () => void;
}) {
  const titre = /^##\s*(.+)$/m.exec(epreuve.contenu)?.[1]?.trim();
  return (
    <div className="flex items-center gap-3 rounded-2xl bg-card p-4 shadow-sm">
      <button
        type="button"
        onClick={onOpen}
        className="flex min-w-0 flex-1 items-center gap-3 text-left"
      >
        <ChevronDown className="size-4 shrink-0 -rotate-90" />
        <div className="min-w-0">
          <p className="truncate text-sm font-semibold text-foreground">
            {titre || `${epreuve.matiere} — ${epreuve.niveau}`}
          </p>
          <p className="truncate text-xs text-muted-foreground">
            {epreuve.matiere} · {epreuve.niveau} · {formatDuree(epreuve.duree_minutes)} ·{" "}
            {new Date(epreuve.created_at).toLocaleDateString("fr-FR")}
          </p>
        </div>
      </button>
      <Button variant="ghost" size="icon" onClick={onDelete} aria-label="Supprimer">
        <Trash2 className="size-4" />
      </Button>
    </div>
  );
}
