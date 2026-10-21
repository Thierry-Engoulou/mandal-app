import { useState } from "react";
import { Camera, FileUp, LoaderCircle, Send, X } from "lucide-react";
import { toast } from "sonner";
import {
  CLASSES,
  MATIERES_BANQUE,
  META_VIDE,
  SERIES,
  SOURCE_PAR_TYPE,
  TYPES_EXAMEN,
  deposerEpreuve,
  devinerDepuisNom,
  metaIncomplete,
  titreAuto,
  type MetaEpreuve,
} from "@/lib/banque";
import { PickFileButton } from "@/components/pick-file-button";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";

const selectClass = "w-full rounded-xl border border-border bg-background px-3 py-2.5 text-sm";
const ACCEPT = "application/pdf,image/jpeg,image/png,image/webp";

/** Champs descriptifs d'une épreuve. */
export function ChampsEpreuve({
  meta,
  onChange,
  compact,
}: {
  meta: MetaEpreuve;
  onChange: (m: MetaEpreuve) => void;
  compact?: boolean;
}) {
  const set = (patch: Partial<MetaEpreuve>) => {
    const suivant = { ...meta, ...patch };
    // Titre recalculé tant qu'il n'a pas été personnalisé.
    if (!("titre" in patch) && (meta.titre === "" || meta.titre === titreAuto(meta))) {
      suivant.titre = titreAuto(suivant);
    }
    if (
      "type_examen" in patch &&
      (!meta.source || meta.source === SOURCE_PAR_TYPE[meta.type_examen])
    ) {
      suivant.source = SOURCE_PAR_TYPE[suivant.type_examen] ?? "";
    }
    onChange(suivant);
  };
  const grid = compact ? "grid gap-2 sm:grid-cols-3 lg:grid-cols-6" : "grid gap-3 sm:grid-cols-2";

  return (
    <div className="space-y-3">
      <div className={grid}>
        <Champ label="Examen" compact={compact}>
          <select
            className={selectClass}
            value={meta.type_examen}
            onChange={(e) => set({ type_examen: e.target.value })}
          >
            <option value="">Choisir…</option>
            {TYPES_EXAMEN.map((t) => (
              <option key={t}>{t}</option>
            ))}
          </select>
        </Champ>
        <Champ label="Matière" compact={compact}>
          <select
            className={selectClass}
            value={meta.matiere}
            onChange={(e) => set({ matiere: e.target.value })}
          >
            <option value="">Choisir…</option>
            {MATIERES_BANQUE.map((m) => (
              <option key={m}>{m}</option>
            ))}
          </select>
        </Champ>
        <Champ label="Classe" compact={compact}>
          <select
            className={selectClass}
            value={meta.classe}
            onChange={(e) => set({ classe: e.target.value })}
          >
            <option value="">Choisir…</option>
            {CLASSES.map((c) => (
              <option key={c}>{c}</option>
            ))}
          </select>
        </Champ>
        <Champ label="Série (facultatif)" compact={compact}>
          <Input
            list="banque-series"
            value={meta.serie}
            onChange={(e) => set({ serie: e.target.value.slice(0, 20) })}
            placeholder="A, C, D, TI…"
          />
        </Champ>
        <Champ label="Année" compact={compact}>
          <Input
            inputMode="numeric"
            value={meta.annee}
            onChange={(e) => set({ annee: e.target.value.replace(/\D/g, "").slice(0, 4) })}
            placeholder="2023"
          />
        </Champ>
        <Champ label="Session (facultatif)" compact={compact}>
          <Input
            value={meta.session}
            onChange={(e) => set({ session: e.target.value.slice(0, 60) })}
            placeholder="Juin, 1re séquence…"
          />
        </Champ>
      </div>
      <datalist id="banque-series">
        {SERIES.map((s) => (
          <option key={s} value={s} />
        ))}
      </datalist>
      {!compact ? (
        <>
          <Champ label="Titre">
            <Input
              value={meta.titre}
              onChange={(e) => set({ titre: e.target.value.slice(0, 200) })}
            />
          </Champ>
          <Champ label="Source (origine du sujet)">
            <Input
              value={meta.source}
              onChange={(e) => set({ source: e.target.value.slice(0, 160) })}
              placeholder="Office du Baccalauréat du Cameroun, Lycée de…, GCE Board…"
            />
          </Champ>
          <Champ label="Remarque (facultatif)">
            <Input
              value={meta.description}
              onChange={(e) => set({ description: e.target.value.slice(0, 300) })}
              placeholder="Ex. : sujet de remplacement, épreuve pratique…"
            />
          </Champ>
        </>
      ) : null}
    </div>
  );
}

function Champ({
  label,
  children,
  compact,
}: {
  label: string;
  children: React.ReactNode;
  compact?: boolean | undefined;
}) {
  return (
    <div className="space-y-1">
      <Label className={compact ? "text-xs" : undefined}>{label}</Label>
      {children}
    </div>
  );
}

function ListeFichiers({
  fichiers,
  onRetirer,
}: {
  fichiers: File[];
  onRetirer: (i: number) => void;
}) {
  if (!fichiers.length) return null;
  return (
    <ul className="space-y-1 text-sm">
      {fichiers.map((f, i) => (
        <li
          key={`${f.name}-${i}`}
          className="flex items-center gap-2 rounded-lg bg-secondary px-3 py-1.5"
        >
          <span className="min-w-0 flex-1 truncate">
            {fichiers.length > 1 ? `Page ${i + 1} — ` : ""}
            {f.name}
          </span>
          <span className="text-xs text-muted-foreground">
            {(f.size / 1024 / 1024).toFixed(1)} Mo
          </span>
          <button type="button" onClick={() => onRetirer(i)} aria-label={`Retirer ${f.name}`}>
            <X className="size-4" />
          </button>
        </li>
      ))}
    </ul>
  );
}

/** Formulaire de dépôt d'une épreuve (PDF ou photos) avec corrigé facultatif. */
export function DepotEpreuveForm({
  userId,
  publier,
  onDepose,
}: {
  userId: string;
  publier: boolean;
  onDepose?: () => void;
}) {
  const [sujet, setSujet] = useState<File[]>([]);
  const [corrige, setCorrige] = useState<File[]>([]);
  const [meta, setMeta] = useState<MetaEpreuve>(META_VIDE);
  const [envoi, setEnvoi] = useState(false);

  const ajouterSujet = (files: FileList | null) => {
    if (!files?.length) return;
    const liste = [...sujet, ...Array.from(files)];
    setSujet(liste);
    // Pré-remplit les informations d'après le nom du premier fichier.
    if (!meta.type_examen && !meta.matiere) {
      const devine = devinerDepuisNom(liste[0]!.name);
      if (devine.type_examen || devine.matiere) setMeta(devine);
    }
  };

  const probleme = sujet.length === 0 ? "Choisis le fichier du sujet" : metaIncomplete(meta);

  const envoyer = async () => {
    if (probleme) {
      toast.error(probleme);
      return;
    }
    setEnvoi(true);
    try {
      await deposerEpreuve({ userId, sujet, corrige, meta, publier });
      toast.success(
        publier
          ? "Épreuve publiée dans la banque."
          : "Épreuve envoyée : elle sera publiée après validation.",
      );
      setSujet([]);
      setCorrige([]);
      setMeta(META_VIDE);
      onDepose?.();
    } catch (e) {
      toast.error(e instanceof Error ? e.message : "Dépôt impossible.");
    } finally {
      setEnvoi(false);
    }
  };

  return (
    <div className="space-y-5 rounded-2xl bg-card p-5 shadow-sm">
      <div className="space-y-2">
        <p className="text-sm font-semibold text-foreground">1. Le sujet</p>
        <p className="text-xs text-muted-foreground">
          Un PDF, ou une ou plusieurs photos (une par page, dans l'ordre) : elles seront regroupées
          en un seul PDF.
        </p>
        <div className="flex flex-wrap gap-2">
          <PickFileButton
            icon={<FileUp className="size-4" />}
            label="Choisir des fichiers"
            accept={ACCEPT}
            multiple
            onFiles={ajouterSujet}
            disabled={envoi}
          />
          <PickFileButton
            icon={<Camera className="size-4" />}
            label="Prendre une photo"
            accept="image/*"
            capture
            onFiles={ajouterSujet}
            disabled={envoi}
          />
        </div>
        <ListeFichiers
          fichiers={sujet}
          onRetirer={(i) => setSujet(sujet.filter((_, j) => j !== i))}
        />
      </div>

      <div className="space-y-2">
        <p className="text-sm font-semibold text-foreground">2. Le corrigé (facultatif)</p>
        <PickFileButton
          icon={<FileUp className="size-4" />}
          label="Ajouter le corrigé"
          accept={ACCEPT}
          multiple
          onFiles={(files) => files?.length && setCorrige([...corrige, ...Array.from(files)])}
          disabled={envoi}
        />
        <ListeFichiers
          fichiers={corrige}
          onRetirer={(i) => setCorrige(corrige.filter((_, j) => j !== i))}
        />
      </div>

      <div className="space-y-2">
        <p className="text-sm font-semibold text-foreground">3. Les informations</p>
        <ChampsEpreuve meta={meta} onChange={setMeta} />
      </div>

      <div className="flex flex-wrap items-center gap-3">
        <Button className="rounded-xl" onClick={() => void envoyer()} disabled={envoi}>
          {envoi ? <LoaderCircle className="size-4 animate-spin" /> : <Send className="size-4" />}
          {publier ? "Publier dans la banque" : "Envoyer pour validation"}
        </Button>
        {probleme && sujet.length > 0 ? (
          <span className="text-xs text-muted-foreground">{probleme}</span>
        ) : null}
      </div>
    </div>
  );
}
