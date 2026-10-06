import { useCallback, useEffect, useRef, useState } from "react";
import { ChevronLeft, ChevronRight } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Dialog, DialogContent, DialogTitle } from "@/components/ui/dialog";
import { cn } from "@/lib/utils";

const announcements = [
  {
    src: "/images/annonces/back-to-school.jpeg",
    alt: "Annonce Back to School, acte 3",
  },
  {
    src: "/images/annonces/prepaconcours.jpeg",
    alt: "Annonce de préparation aux concours",
  },
  {
    src: "/images/annonces/awards-2026.jpeg",
    alt: "Annonce Awards 2026",
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
    <section id="evenements" aria-labelledby="announcements-title" className="bg-background px-5 py-10 lg:px-8 lg:py-14">
      <div className="mx-auto max-w-7xl">
        <div className="mb-6 flex items-end justify-between gap-4">
          <div>
            <p className="text-sm font-bold uppercase text-primary">À la une</p>
            <h2 id="announcements-title" className="mt-2 font-display text-3xl font-bold sm:text-4xl">
              Annonces
            </h2>
          </div>
          <p className="hidden text-sm text-muted-foreground sm:block">Touchez une annonce pour l’agrandir</p>
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