import { createFileRoute, Link } from "@tanstack/react-router";
import { useQuery, useQueryClient } from "@tanstack/react-query";
import { useEffect, useRef, useState } from "react";
import {
  AlarmClock,
  ArrowLeft,
  Camera,
  CheckCircle2,
  ExternalLink,
  FileText,
  ImagePlus,
  LoaderCircle,
  Play,
  Send,
  X,
} from "lucide-react";
import { toast } from "sonner";
import { supabase } from "@/integrations/supabase/client";
import { useProfile } from "@/lib/use-profile";
import { compressImage } from "@/lib/compress-image";
import {
  COMPOSITIONS_BUCKET,
  DELAI_NUMERISATION_MS,
  EPREUVES_BUCKET,
  compositionStatus,
  formatDateTime,
  formatDuree,
  signedUrl,
} from "@/lib/epreuves";
import { Button } from "@/components/ui/button";
import { Skeleton } from "@/components/ui/skeleton";
import { PickFileButton } from "@/components/pick-file-button";
import { cn } from "@/lib/utils";

export const Route = createFileRoute("/_authenticated/etudiant/epreuves/$epreuveId")({
  component: ComposerPage,
  head: () => ({
    meta: [{ title: "Composer une épreuve — M'Andal" }, { name: "robots", content: "noindex" }],
  }),
});

type Composition = {
  id: string;
  debut_at: string;
  fin_prevue_at: string;
  rendu_at: string | null;
  rendu_auto: boolean;
  fichiers: string[];
  note: number | null;
  commentaire: string | null;
};

/** Rappels (en minutes avant la fin) pour photographier / scanner sa copie. */
const RAPPELS = [30, 10, 5, 1];

function useNow(intervalMs = 1000) {
  const [now, setNow] = useState(() => Date.now());
  useEffect(() => {
    const id = setInterval(() => setNow(Date.now()), intervalMs);
    return () => clearInterval(id);
  }, [intervalMs]);
  return now;
}

function formatRemaining(ms: number) {
  const total = Math.max(0, Math.floor(ms / 1000));
  const h = Math.floor(total / 3600);
  const m = Math.floor((total % 3600) / 60);
  const s = total % 60;
  const mm = String(m).padStart(2, "0");
  const ss = String(s).padStart(2, "0");
  return h > 0 ? `${h}:${mm}:${ss}` : `${mm}:${ss}`;
}

function alerter(message: string) {
  toast.warning(message, { duration: 15000 });
  try {
    navigator.vibrate?.([300, 150, 300]);
    if ("Notification" in window && Notification.permission === "granted") {
      new Notification("M'Andal — épreuve en cours", { body: message });
    }
  } catch {
    // notifications indisponibles : le message à l'écran suffit
  }
}

function extensionOf(file: File) {
  if (file.type === "application/pdf") return "pdf";
  const fromName = file.name.split(".").pop()?.toLowerCase();
  return fromName && fromName.length <= 5 ? fromName : "jpg";
}

function ComposerPage() {
  const { epreuveId } = Route.useParams();
  const { data: profile } = useProfile();
  const queryClient = useQueryClient();
  const now = useNow();
  const [starting, setStarting] = useState(false);
  const [uploading, setUploading] = useState(0);
  const [rendering, setRendering] = useState(false);
  const autoRenduRef = useRef(false);
  const rappelsFaitsRef = useRef<Set<number> | null>(null);

  const { data: epreuve, isLoading } = useQuery({
    queryKey: ["epreuve", epreuveId],
    queryFn: async () => {
      const { data, error } = await supabase
        .from("epreuves")
        .select(
          "id, titre, matiere, niveau, duree_minutes, consignes, fichier_path, date_debut, date_fin, statut",
        )
        .eq("id", epreuveId)
        .maybeSingle();
      if (error) throw new Error(error.message);
      return data;
    },
  });

  const compositionKey = ["ma-composition", epreuveId, profile?.id];
  const { data: composition } = useQuery({
    enabled: !!profile,
    queryKey: compositionKey,
    queryFn: async (): Promise<Composition | null> => {
      const { data, error } = await supabase
        .from("compositions")
        .select("id, debut_at, fin_prevue_at, rendu_at, rendu_auto, fichiers, note, commentaire")
        .eq("epreuve_id", epreuveId)
        .eq("eleve_id", profile!.id)
        .maybeSingle();
      if (error) throw new Error(error.message);
      return data;
    },
  });

  const setComposition = (c: Composition | null) => queryClient.setQueryData(compositionKey, c);

  const status = composition ? compositionStatus(composition, now) : null;
  const ouverte = status === "en_cours" || status === "numerisation";
  const fin = composition ? new Date(composition.fin_prevue_at).getTime() : 0;
  const remaining = fin - now;
  const remainingNumerisation = fin + DELAI_NUMERISATION_MS - now;

  const { data: sujetUrl } = useQuery({
    enabled: !!epreuve && !!composition,
    queryKey: ["sujet-url", epreuve?.fichier_path],
    queryFn: () => signedUrl(EPREUVES_BUCKET, epreuve!.fichier_path),
    staleTime: 50 * 60 * 1000,
  });

  const { data: pageUrls = {} } = useQuery({
    enabled: (composition?.fichiers.length ?? 0) > 0,
    queryKey: ["pages-urls", composition?.fichiers],
    queryFn: async () => {
      const { data, error } = await supabase.storage
        .from(COMPOSITIONS_BUCKET)
        .createSignedUrls(composition!.fichiers, 3600);
      if (error) throw new Error(error.message);
      return Object.fromEntries(
        (data ?? []).map((d) => [d.path ?? "", d.signedUrl ?? undefined] as const),
      ) as Record<string, string | undefined>;
    },
    staleTime: 50 * 60 * 1000,
  });

  // Rappels pour photographier / scanner la copie avant la fin.
  useEffect(() => {
    if (status !== "en_cours") return;
    const minutes = remaining / 60000;
    if (rappelsFaitsRef.current === null) {
      // Au chargement : on ne rejoue pas les rappels déjà dépassés.
      rappelsFaitsRef.current = new Set(RAPPELS.filter((r) => minutes <= r));
      return;
    }
    for (const r of RAPPELS) {
      if (minutes <= r && !rappelsFaitsRef.current.has(r)) {
        rappelsFaitsRef.current.add(r);
        alerter(
          r === 1
            ? "Il reste 1 minute ! Photographie ou scanne tes pages et envoie-les."
            : `Il reste ${r} minutes : pense à photographier ou scanner ce que tu as déjà fait et à l'envoyer.`,
        );
        break;
      }
    }
  }, [status, remaining]);

  // Fin du chronomètre puis fin du délai de numérisation.
  const finSignaleeRef = useRef(false);
  useEffect(() => {
    if (status === "numerisation" && !finSignaleeRef.current) {
      finSignaleeRef.current = true;
      alerter("Temps écoulé ! Tu as 15 minutes pour envoyer les photos de ce que tu as fait.");
    }
    if (
      composition &&
      !composition.rendu_at &&
      status === "transmise_auto" &&
      !autoRenduRef.current
    ) {
      autoRenduRef.current = true;
      void supabase
        .rpc("rendre_composition", { p_composition_id: composition.id })
        .then(({ data }) => data && setComposition({ ...composition, ...data }));
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [status, composition]);

  const start = async () => {
    if (
      !confirm(
        `Le chronomètre (${formatDuree(epreuve!.duree_minutes)}) démarre dès maintenant et ne peut pas être mis en pause. Commencer ?`,
      )
    )
      return;
    setStarting(true);
    try {
      if ("Notification" in window && Notification.permission === "default") {
        void Notification.requestPermission();
      }
      const { data, error } = await supabase.rpc("commencer_composition", {
        p_epreuve_id: epreuveId,
      });
      if (error) throw new Error(error.message);
      setComposition({ ...data, commentaire: data.commentaire ?? null });
    } catch (err) {
      toast.error(err instanceof Error ? err.message : "Impossible de commencer.");
    } finally {
      setStarting(false);
    }
  };

  const addPages = async (list: FileList | null) => {
    if (!list || !composition || !profile) return;
    const files = Array.from(list).filter(
      (f) => f.type.startsWith("image/") || f.type === "application/pdf",
    );
    if (files.length < list.length) toast.error("Seules les photos et les PDF sont acceptés.");
    setUploading((n) => n + files.length);
    let fichiers = composition.fichiers;
    for (const [i, file] of files.entries()) {
      try {
        const ready = await compressImage(file);
        const path = `${epreuveId}/${profile.id}/${Date.now()}-${i + 1}.${extensionOf(ready)}`;
        const { error: upError } = await supabase.storage
          .from(COMPOSITIONS_BUCKET)
          .upload(path, ready, ready.type ? { contentType: ready.type } : {});
        if (upError) throw new Error(upError.message);
        const { data, error } = await supabase.rpc("ajouter_page_composition", {
          p_composition_id: composition.id,
          p_path: path,
        });
        if (error) throw new Error(error.message);
        fichiers = data ?? fichiers;
        setComposition({ ...composition, fichiers });
      } catch (err) {
        toast.error(
          `Page « ${file.name} » non envoyée : ${err instanceof Error ? err.message : "erreur"}`,
        );
      } finally {
        setUploading((n) => n - 1);
      }
    }
    toast.success("Pages envoyées à ton enseignant.");
  };

  const removePage = async (path: string) => {
    if (!composition || !confirm("Retirer cette page ?")) return;
    const { data, error } = await supabase.rpc("retirer_page_composition", {
      p_composition_id: composition.id,
      p_path: path,
    });
    if (error) {
      toast.error(error.message);
      return;
    }
    await supabase.storage.from(COMPOSITIONS_BUCKET).remove([path]);
    setComposition({ ...composition, fichiers: data ?? [] });
  };

  const rendre = async () => {
    if (!composition) return;
    const msg =
      composition.fichiers.length === 0
        ? "Tu n'as envoyé aucune page. Rendre quand même une copie vide ?"
        : `Rendre ta copie (${composition.fichiers.length} page(s)) ? Tu ne pourras plus la modifier.`;
    if (!confirm(msg)) return;
    setRendering(true);
    const { data, error } = await supabase.rpc("rendre_composition", {
      p_composition_id: composition.id,
    });
    setRendering(false);
    if (error) {
      toast.error(error.message);
      return;
    }
    setComposition({ ...composition, ...data });
    await queryClient.invalidateQueries({ queryKey: ["etudiant-epreuves"] });
    toast.success("Copie rendue : ton enseignant l'a reçue.");
  };

  if (isLoading) return <Skeleton className="h-64 rounded-2xl" />;
  if (!epreuve) {
    return (
      <div className="rounded-2xl bg-card p-8 text-center text-sm text-muted-foreground">
        Épreuve introuvable.
      </div>
    );
  }

  const isPdf = epreuve.fichier_path.toLowerCase().endsWith(".pdf");

  return (
    <div className="space-y-5">
      <Link
        to="/etudiant/epreuves"
        className="inline-flex items-center gap-1 text-sm text-muted-foreground hover:text-foreground"
      >
        <ArrowLeft className="size-4" /> Épreuves
      </Link>

      <header className="rounded-2xl bg-card p-5 shadow-sm">
        <p className="text-xs font-bold uppercase tracking-wide text-primary">
          {epreuve.matiere} · {epreuve.niveau} · {formatDuree(epreuve.duree_minutes)}
        </p>
        <h1 className="font-display text-2xl font-bold text-foreground">{epreuve.titre}</h1>
        {epreuve.consignes ? (
          <p className="mt-2 whitespace-pre-wrap text-sm text-foreground">{epreuve.consignes}</p>
        ) : null}
      </header>

      {/* Avant de commencer */}
      {!composition ? (
        <section className="space-y-3 rounded-2xl bg-card p-5 shadow-sm">
          <h2 className="font-display text-lg font-bold text-foreground">Avant de commencer</h2>
          <ul className="list-disc space-y-1 pl-5 text-sm text-foreground">
            <li>Prépare des feuilles, un stylo et ton téléphone (pour photographier tes pages).</li>
            <li>
              Le sujet s'affiche quand tu commences ; tu as {formatDuree(epreuve.duree_minutes)}
              {epreuve.date_fin
                ? ` (au plus tard jusqu'au ${formatDateTime(epreuve.date_fin)})`
                : ""}
              .
            </li>
            <li>
              Envoie tes pages au fur et à mesure : chaque page envoyée est immédiatement transmise
              à ton enseignant.
            </li>
            <li>
              Tu recevras des rappels à 30, 10 et 5 minutes de la fin. Après la fin, tu as encore 15
              minutes pour envoyer les photos de ce que tu as fait.
            </li>
          </ul>
          {epreuve.date_debut && new Date(epreuve.date_debut).getTime() > now ? (
            <p className="text-sm font-semibold text-muted-foreground">
              Ouverture le {formatDateTime(epreuve.date_debut)}.
            </p>
          ) : epreuve.date_fin && new Date(epreuve.date_fin).getTime() <= now ? (
            <p className="text-sm font-semibold text-muted-foreground">
              Cette épreuve est clôturée.
            </p>
          ) : (
            <Button onClick={start} disabled={starting} className="h-12 rounded-xl px-6 text-base">
              {starting ? <LoaderCircle className="animate-spin" /> : <Play className="size-4" />}
              Commencer l'épreuve
            </Button>
          )}
        </section>
      ) : null}

      {/* Chronomètre */}
      {composition && ouverte ? (
        <div
          className={cn(
            "sticky top-2 z-10 flex flex-wrap items-center justify-between gap-3 rounded-2xl p-4 shadow-md",
            status === "numerisation"
              ? "bg-destructive text-white"
              : remaining <= 30 * 60000
                ? "bg-amber-500 text-white"
                : "bg-primary text-primary-foreground",
          )}
        >
          <div className="flex items-center gap-2">
            <AlarmClock className="size-5" />
            <span className="font-display text-2xl font-bold tabular-nums">
              {formatRemaining(status === "numerisation" ? remainingNumerisation : remaining)}
            </span>
          </div>
          <p className="text-sm font-semibold">
            {status === "numerisation"
              ? "Temps écoulé : envoie vite les photos de tes pages !"
              : remaining <= 30 * 60000
                ? "Moins de 30 min : photographie ou scanne ce que tu as fait et envoie-le."
                : "Temps restant"}
          </p>
        </div>
      ) : null}

      {/* Sujet */}
      {composition && sujetUrl ? (
        <section className="space-y-2 rounded-2xl bg-card p-4 shadow-sm">
          <div className="flex items-center justify-between gap-2">
            <h2 className="font-display text-lg font-bold text-foreground">Sujet</h2>
            <Button asChild variant="outline" size="sm" className="rounded-xl">
              <a href={sujetUrl} target="_blank" rel="noreferrer">
                <ExternalLink className="size-4" /> Ouvrir en grand
              </a>
            </Button>
          </div>
          {isPdf ? (
            <iframe
              src={sujetUrl}
              title={`Sujet : ${epreuve.titre}`}
              className="h-[70vh] w-full rounded-xl border border-border"
            />
          ) : (
            <img src={sujetUrl} alt={`Sujet : ${epreuve.titre}`} className="w-full rounded-xl" />
          )}
        </section>
      ) : null}

      {/* Copie */}
      {composition ? (
        <section className="space-y-3 rounded-2xl bg-card p-4 shadow-sm">
          <h2 className="font-display text-lg font-bold text-foreground">
            Ma copie ({composition.fichiers.length} page{composition.fichiers.length > 1 ? "s" : ""}
            )
          </h2>
          {ouverte ? (
            <div className="flex flex-wrap gap-2">
              <PickFileButton
                icon={<Camera className="size-4" />}
                label="Photographier une page"
                accept="image/*"
                capture
                onFiles={addPages}
                disabled={composition.fichiers.length >= 20}
              />
              <PickFileButton
                icon={<ImagePlus className="size-4" />}
                label="Ajouter photos / PDF"
                accept="image/*,application/pdf"
                multiple
                onFiles={addPages}
                disabled={composition.fichiers.length >= 20}
              />
              {uploading > 0 ? (
                <span className="flex items-center gap-1 text-sm text-muted-foreground">
                  <LoaderCircle className="size-4 animate-spin" /> Envoi de {uploading} page(s)…
                </span>
              ) : null}
            </div>
          ) : null}

          {composition.fichiers.length > 0 ? (
            <ul className="flex flex-wrap gap-2">
              {composition.fichiers.map((path, i) => {
                const url = pageUrls[path];
                const pdf = path.endsWith(".pdf");
                return (
                  <li
                    key={path}
                    className="relative flex w-28 flex-col items-center gap-1 rounded-xl border border-border bg-background p-2"
                  >
                    <a href={url} target="_blank" rel="noreferrer" className="block w-full">
                      {url && !pdf ? (
                        <img
                          src={url}
                          alt={`Page ${i + 1}`}
                          className="h-28 w-full rounded-lg object-cover"
                        />
                      ) : (
                        <div className="flex h-28 w-full items-center justify-center rounded-lg bg-secondary">
                          <FileText className="size-8 text-muted-foreground" />
                        </div>
                      )}
                    </a>
                    <span className="text-[11px] text-muted-foreground">Page {i + 1}</span>
                    {ouverte ? (
                      <button
                        type="button"
                        onClick={() => removePage(path)}
                        aria-label={`Retirer la page ${i + 1}`}
                        className="absolute -right-2 -top-2 flex size-6 items-center justify-center rounded-full bg-destructive text-white shadow"
                      >
                        <X className="size-3.5" />
                      </button>
                    ) : null}
                  </li>
                );
              })}
            </ul>
          ) : (
            <p className="text-sm text-muted-foreground">Aucune page envoyée pour l'instant.</p>
          )}

          {ouverte ? (
            <Button onClick={rendre} disabled={rendering || uploading > 0} className="rounded-xl">
              {rendering ? <LoaderCircle className="animate-spin" /> : <Send className="size-4" />}
              Rendre ma copie
            </Button>
          ) : (
            <div className="rounded-xl bg-secondary/50 p-4 text-sm text-foreground">
              <p className="flex items-center gap-2 font-semibold">
                <CheckCircle2 className="size-4 text-primary" />
                {composition.rendu_auto || status === "transmise_auto"
                  ? "Temps écoulé : tes pages envoyées ont été transmises à ton enseignant."
                  : "Copie rendue : ton enseignant l'a reçue."}
              </p>
              {composition.note !== null ? (
                <p className="mt-2 text-base font-bold">Note : {composition.note}/20</p>
              ) : (
                <p className="mt-1 text-muted-foreground">En attente de correction.</p>
              )}
              {composition.commentaire ? (
                <p className="mt-1 whitespace-pre-wrap">
                  Commentaire de l'enseignant : {composition.commentaire}
                </p>
              ) : null}
            </div>
          )}
        </section>
      ) : null}
    </div>
  );
}
