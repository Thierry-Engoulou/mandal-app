import { createFileRoute } from "@tanstack/react-router";
import { useQuery } from "@tanstack/react-query";
import { useState } from "react";
import { FileText, Music, Video, Download } from "lucide-react";
import { toast } from "sonner";
import { supabase } from "@/integrations/supabase/client";
import { Skeleton } from "@/components/ui/skeleton";
import { Input } from "@/components/ui/input";

export const Route = createFileRoute("/_authenticated/etudiant/mediatheque")({
  component: MediathequePage,
  head: () => ({
    meta: [
      { title: "Médiathèque — MANDAL" },
      { name: "description", content: "Vidéos, audios et documents pédagogiques MANDAL." },
      { name: "robots", content: "noindex" },
    ],
  }),
});

const BUCKET: Record<string, string> = {
  video: "mediatheque-videos",
  audio: "mediatheque-audio",
  document: "mediatheque-documents",
};

const ICON: Record<string, typeof Video> = { video: Video, audio: Music, document: FileText };

function MediathequePage() {
  const [search, setSearch] = useState("");

  const { data, isLoading } = useQuery({
    queryKey: ["mediatheque"],
    queryFn: async () => {
      const { data, error } = await supabase
        .from("ressources_mediatheque")
        .select("id, titre, description, type, url_storage, xp_valeur, matieres(nom)")
        .eq("statut_validation", "approuve")
        .order("created_at", { ascending: false });
      if (error) throw new Error(error.message);
      return data ?? [];
    },
  });

  const open = async (type: string, path: string) => {
    const bucket = BUCKET[type] ?? "mediatheque-documents";
    const { data, error } = await supabase.storage.from(bucket).createSignedUrl(path, 3600);
    if (error || !data) {
      toast.error("Ce fichier n'est pas accessible pour le moment.");
      return;
    }
    window.open(data.signedUrl, "_blank", "noopener");
  };

  const filtered = (data ?? []).filter((r) =>
    r.titre.toLowerCase().includes(search.trim().toLowerCase()),
  );

  return (
    <div className="space-y-6">
      <header className="gradient-welcome rounded-2xl p-6 text-primary-foreground shadow-sm">
        <h1 className="font-display text-2xl font-bold tracking-tight">Médiathèque</h1>
        <p className="mt-1 text-sm opacity-90">
          Vidéos, enregistrements audio et documents validés par vos enseignants.
        </p>
      </header>

      <Input
        value={search}
        onChange={(e) => setSearch(e.target.value)}
        placeholder="Rechercher une ressource"
        className="max-w-md rounded-xl"
      />

      {isLoading ? (
        <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
          {[0, 1, 2].map((i) => (
            <Skeleton key={i} className="h-36 rounded-2xl" />
          ))}
        </div>
      ) : filtered.length === 0 ? (
        <div className="rounded-2xl bg-card p-10 text-center shadow-sm">
          <p className="text-sm text-muted-foreground">Aucune ressource disponible pour l'instant.</p>
        </div>
      ) : (
        <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
          {filtered.map((r) => {
            const Icon = ICON[r.type] ?? FileText;
            return (
              <article key={r.id} className="flex flex-col rounded-2xl bg-card p-5 shadow-sm">
                <span className="flex size-11 items-center justify-center rounded-xl bg-primary/10 text-primary">
                  <Icon className="size-5" />
                </span>
                <h2 className="mt-4 font-display text-base font-semibold text-foreground">{r.titre}</h2>
                {r.description ? (
                  <p className="mt-1 line-clamp-2 text-sm text-muted-foreground">{r.description}</p>
                ) : null}
                <p className="mt-2 text-xs text-muted-foreground">
                  {(r as { matieres?: { nom?: string } }).matieres?.nom ?? "Général"} · +{r.xp_valeur} XP
                </p>
                <button
                  onClick={() => open(r.type, r.url_storage)}
                  className="mt-4 inline-flex items-center gap-2 self-start rounded-xl bg-primary px-4 py-2 text-sm font-semibold text-primary-foreground"
                >
                  <Download className="size-4" /> Ouvrir
                </button>
              </article>
            );
          })}
        </div>
      )}
    </div>
  );
}
