import { useQuery } from "@tanstack/react-query";
import { useState } from "react";
import { Camera } from "lucide-react";
import { Dialog, DialogContent, DialogTitle } from "@/components/ui/dialog";
import { chargerGalerie, PHOTOS_DE_DEPART, urlPhoto } from "@/lib/galerie";

type Photo = { cle: string; src: string; legende: string };

/** Bandeau de photos des événements, qui défile en continu (pause au survol). */
export function GalerieDefilante() {
  const [ouverte, setOuverte] = useState<Photo | null>(null);
  const { data } = useQuery({
    queryKey: ["galerie-photos"],
    queryFn: chargerGalerie,
    staleTime: 5 * 60 * 1000,
    retry: false,
  });

  const depuisSupabase: Photo[] = (data ?? [])
    .filter((p) => p.visible)
    .map((p) => ({ cle: p.id, src: urlPhoto(p.chemin), legende: p.legende ?? "" }));
  const photos: Photo[] = depuisSupabase.length
    ? depuisSupabase
    : PHOTOS_DE_DEPART.map((p) => ({ cle: p.src, src: p.src, legende: p.legende }));

  // La liste est dupliquée pour une boucle sans à-coup (défilement de -50 %).
  const boucle = [...photos, ...photos];

  return (
    <section
      aria-labelledby="galerie-titre"
      className="overflow-hidden border-t border-border bg-card py-10"
    >
      <div className="mx-auto mb-6 max-w-7xl px-5 lg:px-8">
        <p className="flex items-center gap-2 text-xs font-bold uppercase tracking-wider text-primary">
          <Camera className="size-4" aria-hidden="true" /> En images
        </p>
        <h2 id="galerie-titre" className="font-display text-xl font-bold text-foreground">
          Nos événements M'ANDAL
        </h2>
      </div>
      <div className="overflow-x-auto motion-safe:overflow-x-hidden">
        <ul
          className="animate-defilement flex w-max list-none gap-4 px-5"
          style={{ ["--duree-defilement" as string]: `${Math.max(30, photos.length * 8)}s` }}
        >
          {boucle.map((p, i) => (
            <li key={`${p.cle}-${i}`} aria-hidden={i >= photos.length ? true : undefined}>
              <button
                type="button"
                onClick={() => setOuverte(p)}
                tabIndex={i >= photos.length ? -1 : 0}
                className="group block overflow-hidden rounded-2xl shadow-sm focus:outline-none focus-visible:ring-2 focus-visible:ring-primary"
              >
                <img
                  src={p.src}
                  alt={p.legende || "Photo d'un événement M'ANDAL"}
                  loading="lazy"
                  className="h-48 w-auto object-cover transition duration-300 group-hover:scale-105 sm:h-60"
                />
              </button>
            </li>
          ))}
        </ul>
      </div>

      <Dialog open={ouverte !== null} onOpenChange={(o) => !o && setOuverte(null)}>
        <DialogContent className="max-w-4xl p-2 sm:p-4">
          <DialogTitle className="px-2 text-base">
            {ouverte?.legende || "Événement M'ANDAL"}
          </DialogTitle>
          {ouverte ? (
            <img
              src={ouverte.src}
              alt={ouverte.legende || "Photo d'un événement M'ANDAL"}
              className="max-h-[75vh] w-full rounded-xl object-contain"
            />
          ) : null}
        </DialogContent>
      </Dialog>
    </section>
  );
}
