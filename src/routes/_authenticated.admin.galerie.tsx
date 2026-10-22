import { createFileRoute } from "@tanstack/react-router";
import { useQuery, useQueryClient } from "@tanstack/react-query";
import { useState } from "react";
import { ArrowDown, ArrowUp, Eye, EyeOff, ImagePlus, LoaderCircle, Trash2 } from "lucide-react";
import { toast } from "sonner";
import {
  ajouterPhoto,
  chargerGalerie,
  importerPhotosDeDepart,
  modifierPhoto,
  PHOTOS_DE_DEPART,
  supprimerPhoto,
  urlPhoto,
  type PhotoGalerie,
} from "@/lib/galerie";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";

export const Route = createFileRoute("/_authenticated/admin/galerie")({
  component: AdminGaleriePage,
  head: () => ({
    meta: [
      { title: "Galerie photos — Administration M'Andal" },
      { name: "robots", content: "noindex" },
    ],
  }),
});

function AdminGaleriePage() {
  const queryClient = useQueryClient();
  const [fichiers, setFichiers] = useState<File[]>([]);
  const [legende, setLegende] = useState("");
  const [envoi, setEnvoi] = useState<string | null>(null);

  const {
    data = [],
    isLoading,
    error,
  } = useQuery({
    queryKey: ["galerie-photos"],
    queryFn: chargerGalerie,
    retry: false,
  });

  const rafraichir = () => void queryClient.invalidateQueries({ queryKey: ["galerie-photos"] });

  const executer = async (etiquette: string, action: () => Promise<void>, succes: string) => {
    setEnvoi(etiquette);
    try {
      await action();
      toast.success(succes);
    } catch (e) {
      toast.error(e instanceof Error ? e.message : "Opération impossible.");
    } finally {
      setEnvoi(null);
      rafraichir();
    }
  };

  const envoyer = () =>
    executer(
      "ajout",
      async () => {
        for (const [i, f] of fichiers.entries()) {
          setEnvoi(`ajout ${i + 1}/${fichiers.length}`);
          await ajouterPhoto(f, legende, f.name);
        }
        setFichiers([]);
        setLegende("");
      },
      `${fichiers.length} photo(s) ajoutée(s).`,
    );

  const deplacer = (index: number, sens: -1 | 1) => {
    const autre = data[index + sens];
    const photo = data[index];
    if (!autre || !photo) return;
    void executer(
      "ordre",
      async () => {
        // Réattribue un ordre continu à toute la liste, avec les deux photos échangées.
        const liste = [...data];
        liste[index] = autre;
        liste[index + sens] = photo;
        await Promise.all(liste.map((p, i) => modifierPhoto(p.id, { ordre: i })));
      },
      "Ordre mis à jour.",
    );
  };

  return (
    <div className="space-y-6">
      <div>
        <h1 className="font-display text-2xl font-bold text-foreground">Galerie photos</h1>
        <p className="text-sm text-muted-foreground">
          Les photos visibles défilent en bas de la page d'accueil. Elles sont stockées dans
          Supabase (bucket « galerie »).
        </p>
      </div>

      {error ? (
        <p className="rounded-2xl bg-destructive/10 p-4 text-sm text-destructive">
          Galerie indisponible : exécutez d'abord le script galerie_photos.sql dans Supabase. (
          {error.message})
        </p>
      ) : null}

      <section className="space-y-3 rounded-2xl bg-card p-5 shadow-sm">
        <h2 className="font-semibold text-foreground">Ajouter des photos</h2>
        <p className="text-xs text-muted-foreground">
          Assurez-vous d'avoir l'accord des personnes photographiées (et des parents pour les
          mineurs) avant de publier.
        </p>
        <Input
          type="file"
          accept="image/jpeg,image/png,image/webp"
          multiple
          onChange={(e) => setFichiers(Array.from(e.target.files ?? []))}
        />
        <Input
          placeholder="Légende (facultatif), ex. : Awards M'ANDAL 2026"
          value={legende}
          maxLength={200}
          onChange={(e) => setLegende(e.target.value)}
        />
        <div className="flex flex-wrap gap-3">
          <Button
            className="rounded-xl"
            disabled={fichiers.length === 0 || envoi !== null}
            onClick={() => void envoyer()}
          >
            {envoi?.startsWith("ajout") ? (
              <LoaderCircle className="mr-2 size-4 animate-spin" />
            ) : (
              <ImagePlus className="mr-2 size-4" />
            )}
            {envoi?.startsWith("ajout") ? `Envoi ${envoi.slice(6)}…` : "Envoyer"}
          </Button>
          {!isLoading && !error && data.length === 0 ? (
            <Button
              variant="outline"
              className="rounded-xl"
              disabled={envoi !== null}
              onClick={() =>
                void executer(
                  "import",
                  importerPhotosDeDepart,
                  `${PHOTOS_DE_DEPART.length} photos des Awards 2026 importées.`,
                )
              }
            >
              {envoi === "import" ? <LoaderCircle className="mr-2 size-4 animate-spin" /> : null}
              Importer les {PHOTOS_DE_DEPART.length} photos des Awards 2026
            </Button>
          ) : null}
        </div>
      </section>

      {isLoading ? (
        <p className="text-sm text-muted-foreground">Chargement…</p>
      ) : data.length === 0 && !error ? (
        <p className="rounded-2xl bg-card p-6 text-sm text-muted-foreground shadow-sm">
          Aucune photo dans Supabase : l'accueil affiche pour l'instant les{" "}
          {PHOTOS_DE_DEPART.length} photos des Awards 2026 livrées avec le site.
        </p>
      ) : (
        <ul className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
          {data.map((p, i) => (
            <CartePhoto
              key={p.id}
              photo={p}
              occupe={envoi !== null}
              premier={i === 0}
              dernier={i === data.length - 1}
              onMonter={() => deplacer(i, -1)}
              onDescendre={() => deplacer(i, 1)}
              onLegende={(l) =>
                void executer(
                  "legende",
                  () => modifierPhoto(p.id, { legende: l || null }),
                  "Légende enregistrée.",
                )
              }
              onVisible={() =>
                void executer(
                  "visible",
                  () => modifierPhoto(p.id, { visible: !p.visible }),
                  p.visible ? "Photo masquée." : "Photo affichée.",
                )
              }
              onSupprimer={() => {
                if (!window.confirm("Supprimer définitivement cette photo ?")) return;
                void executer("suppression", () => supprimerPhoto(p), "Photo supprimée.");
              }}
            />
          ))}
        </ul>
      )}
    </div>
  );
}

function CartePhoto({
  photo,
  occupe,
  premier,
  dernier,
  onMonter,
  onDescendre,
  onLegende,
  onVisible,
  onSupprimer,
}: {
  photo: PhotoGalerie;
  occupe: boolean;
  premier: boolean;
  dernier: boolean;
  onMonter: () => void;
  onDescendre: () => void;
  onLegende: (legende: string) => void;
  onVisible: () => void;
  onSupprimer: () => void;
}) {
  const [legende, setLegende] = useState(photo.legende ?? "");
  return (
    <li className="space-y-2 rounded-2xl bg-card p-3 shadow-sm">
      <img
        src={urlPhoto(photo.chemin)}
        alt={photo.legende ?? "Photo de la galerie"}
        loading="lazy"
        className={`aspect-video w-full rounded-xl object-cover ${photo.visible ? "" : "opacity-40"}`}
      />
      <Input
        value={legende}
        maxLength={200}
        placeholder="Légende"
        onChange={(e) => setLegende(e.target.value)}
        onBlur={() => legende !== (photo.legende ?? "") && onLegende(legende.trim())}
      />
      <div className="flex flex-wrap gap-1">
        <Button
          size="sm"
          variant="ghost"
          disabled={occupe || premier}
          onClick={onMonter}
          aria-label="Monter"
        >
          <ArrowUp className="size-4" />
        </Button>
        <Button
          size="sm"
          variant="ghost"
          disabled={occupe || dernier}
          onClick={onDescendre}
          aria-label="Descendre"
        >
          <ArrowDown className="size-4" />
        </Button>
        <Button size="sm" variant="ghost" disabled={occupe} onClick={onVisible}>
          {photo.visible ? <EyeOff className="mr-1 size-4" /> : <Eye className="mr-1 size-4" />}
          {photo.visible ? "Masquer" : "Afficher"}
        </Button>
        <Button
          size="sm"
          variant="ghost"
          className="ml-auto text-destructive"
          disabled={occupe}
          onClick={onSupprimer}
          aria-label="Supprimer"
        >
          <Trash2 className="size-4" />
        </Button>
      </div>
    </li>
  );
}
