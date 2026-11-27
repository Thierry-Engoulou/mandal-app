import { useCallback, useEffect, useRef, useState } from "react";
import { ChevronLeft, ChevronRight } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Dialog, DialogContent, DialogTitle } from "@/components/ui/dialog";
import { cn } from "@/lib/utils";

// Le texte de chaque affiche est repris en clair : lisible par les moteurs de
// recherche et les lecteurs d'écran, et affiché sous le carrousel.
const announcements = [
  {
    src: "/images/annonces/back-to-school.jpeg",
    alt: "Affiche Back to School, acte 3 — JVEPI Centre",
    titre: "Back to School, acte 3",
    texte:
      "Et si vous souteniez nos actions à l'occasion du Back to School, acte 3 ? Soutenez nos actions par Orange Money (code marchand 852647) ou MTN MoMo (code marchand 404352), identifiant : JVEPI Association. Infos : (+237) 689 115 208. Avec JVEPI, la Fondation Mackenzie et M'Andal.",
  },
  {
    src: "/images/annonces/prepaconcours.jpeg",
    alt: "Affiche M'Andal'PrépaConcours : programme d'accompagnement des talents",
    titre: "M'Andal'PrépaConcours : programme d'accompagnement des talents",
    texte:
      "50 jeunes talents scolaires, ruraux et urbains, à l'honneur. Critères de sélection : au moins 14/20 aux olympiades ; moyenne annuelle d'au moins 14/20 dans les matières de base ; ou baccalauréat avec au moins 14/20 de moyenne dans les matières de base ; bonne recommandation (assiduité) de l'établissement. Récompenses : un quitus M'Andal'PrépaConcours (ENSPD, ENSPY, FMS), un accompagnement pour constituer les dossiers, une carte d'accès libre d'un an aux formations en leadership et développement personnel. Olympiades le 6 mars 2026 à 12 h ; liste des présélectionnés publiée le 13 mars 2026 ; 30 établissements présélectionnés. Gratuit. Contact : +237 694 17 15 69 / 670 71 32 59, contact@jvepi-mandal.org.",
  },
  {
    src: "/images/annonces/awards-2026.jpeg",
    alt: "Affiche Awards M'Andal 2026, 1re édition",
    titre: "Awards M'Andal 2026 — 1re édition",
    texte:
      "Save the date : Awards M'Andal 2026, 1re édition, le 26 septembre 2026 à 12 h, à Deïdo. Contact : (+237) 690 50 41 28. Avec JVEPI Centre, JVEPI, la Fondation Mackenzie et The Okwelians.",
  },
] as const;

export function AnnouncementsCarousel() {
  const [activeIndex, setActiveIndex] = useState(0);
  const [lightboxOpen, setLightboxOpen] = useState(false);
  const touchStart = useRef<number | null>(null);
  const activeAnnouncement = announcements[activeIndex] ?? announcements[0];

  const show = useCallback((index: number) => {
    setActiveIndex((index + announcements.length) % announcements.length);
  }, []);

  const previous = useCallback(() => show(activeIndex - 1), [activeIndex, show]);
  const next = useCallback(() => show(activeIndex + 1), [activeIndex, show]);

  useEffect(() => {
    if (lightboxOpen) return;
    const timer = window.setInterval(next, 6000);
    return () => window.clearInterval(timer);
  }, [lightboxOpen, next]);

  const handleTouchEnd = (event: React.TouchEvent<HTMLDivElement>) => {
    const start = touchStart.current;
    const end = event.changedTouches[0]?.clientX;
    touchStart.current = null;
    if (start === null || end === undefined || Math.abs(start - end) < 45) return;
    if (start > end) next();
    else previous();
  };

  return (
    <section
      id="evenements"
      aria-labelledby="announcements-title"
      className="bg-background px-5 py-10 lg:px-8 lg:py-14"
    >
      <div className="mx-auto max-w-7xl">
        <div className="mb-6 flex items-end justify-between gap-4">
          <div>
            <p className="text-sm font-bold uppercase text-primary">À la une</p>
            <h2
              id="announcements-title"
              className="mt-2 font-display text-3xl font-bold sm:text-4xl"
            >
              Annonces
            </h2>
          </div>
          <p className="hidden text-sm text-muted-foreground sm:block">
            Touchez une annonce pour l’agrandir
          </p>
        </div>

        <div
          className="group relative overflow-hidden rounded-2xl border border-border bg-card shadow-lg"
          onTouchStart={(event) => {
            touchStart.current = event.touches[0]?.clientX ?? null;
          }}
          onTouchEnd={handleTouchEnd}
        >
          <div
            className="flex transition-transform duration-700 ease-out-expo motion-reduce:transition-none"
            style={{ transform: `translateX(-${activeIndex * 100}%)` }}
          >
            {announcements.map((announcement, index) => (
              <button
                key={announcement.src}
                type="button"
                className="flex min-w-full cursor-zoom-in items-center justify-center bg-secondary/40 p-2 sm:p-5"
                onClick={() => {
                  setActiveIndex(index);
                  setLightboxOpen(true);
                }}
                aria-label={`Agrandir : ${announcement.alt}`}
                tabIndex={index === activeIndex ? 0 : -1}
              >
                <img
                  src={announcement.src}
                  alt={announcement.alt}
                  className="h-auto max-h-[72vh] w-full object-contain"
                  loading={index === 0 ? "eager" : "lazy"}
                  draggable={false}
                />
              </button>
            ))}
          </div>

          <Button
            type="button"
            variant="secondary"
            size="icon"
            onClick={previous}
            aria-label="Annonce précédente"
            className="absolute left-3 top-1/2 -translate-y-1/2 rounded-full shadow-md sm:left-5"
          >
            <ChevronLeft />
          </Button>
          <Button
            type="button"
            variant="secondary"
            size="icon"
            onClick={next}
            aria-label="Annonce suivante"
            className="absolute right-3 top-1/2 -translate-y-1/2 rounded-full shadow-md sm:right-5"
          >
            <ChevronRight />
          </Button>

          <div className="absolute bottom-4 left-1/2 flex -translate-x-1/2 gap-2 rounded-full bg-card/90 px-3 py-2 shadow-sm">
            {announcements.map((announcement, index) => (
              <button
                key={announcement.src}
                type="button"
                onClick={() => show(index)}
                className={cn(
                  "size-2.5 rounded-full transition-colors",
                  index === activeIndex ? "bg-primary" : "bg-muted hover:bg-muted-foreground",
                )}
                aria-label={`Afficher l’annonce ${index + 1}`}
                aria-current={index === activeIndex ? "true" : undefined}
              />
            ))}
          </div>
        </div>

        <div
          className="mt-4 rounded-2xl border border-border bg-card p-4 text-sm"
          aria-live="polite"
        >
          <p className="font-semibold text-foreground">{activeAnnouncement.titre}</p>
          <p className="mt-1 text-muted-foreground">{activeAnnouncement.texte}</p>
        </div>
      </div>

      <Dialog open={lightboxOpen} onOpenChange={setLightboxOpen}>
        <DialogContent className="max-h-[94vh] max-w-[94vw] border-0 bg-card p-2 shadow-2xl sm:rounded-xl">
          <DialogTitle className="sr-only">{activeAnnouncement.alt}</DialogTitle>
          <img
            src={activeAnnouncement.src}
            alt={activeAnnouncement.alt}
            className="max-h-[90vh] w-full object-contain"
          />
        </DialogContent>
      </Dialog>
    </section>
  );
}
