import { createFileRoute, Link } from "@tanstack/react-router";
import { ArrowLeft, CheckCircle2, ChevronDown, ChevronUp, Circle, FileText, PlayCircle } from "lucide-react";
import { useMemo, useState } from "react";
import {
  useProgrammeDetail,
  useProgression,
  useSetConceptDone,
  type ProgrammeConcept,
} from "@/lib/use-student-programmes";
import { conceptTypeLabel, geogebraEmbedUrl, youtubeEmbedUrl } from "@/lib/concept-content";
import { FunctionGraph } from "@/components/function-graph";
import { Skeleton } from "@/components/ui/skeleton";
import { Progress } from "@/components/ui/progress";
import { Checkbox } from "@/components/ui/checkbox";
import { Button } from "@/components/ui/button";

export const Route = createFileRoute("/_authenticated/etudiant/cours/$programmeId")({
  component: StudentProgrammePage,
  head: () => ({
    meta: [
      { title: "Programme — MANDAL" },
      { name: "description", content: "Suivez ce programme chapitre par chapitre." },
      { name: "robots", content: "noindex" },
    ],
  }),
});

function ConceptContent({ concept }: { concept: ProgrammeConcept }) {
  if (concept.type_contenu === "graphique") {
    return <FunctionGraph spec={concept.contenu_texte ?? "{}"} />;
  }
  if (concept.type_contenu === "simulation" && concept.media_url) {
    const embed = geogebraEmbedUrl(concept.media_url);
    return embed ? (
      <div className="overflow-hidden rounded-xl border border-border">
        <iframe src={embed} className="h-[500px] w-full" title={concept.titre} allowFullScreen />
      </div>
    ) : (
      <a
        href={concept.media_url}
        target="_blank"
        rel="noreferrer"
        className="flex items-center gap-2 rounded-xl border border-border px-4 py-3 text-sm font-medium text-primary hover:bg-secondary/60"
      >
        Ouvrir la simulation GeoGebra
      </a>
    );
  }
  if (concept.type_contenu === "video" && concept.media_url) {
    const embed = youtubeEmbedUrl(concept.media_url);
    return embed ? (
      <div className="aspect-video overflow-hidden rounded-xl">
        <iframe src={embed} className="h-full w-full" allowFullScreen title={concept.titre} />
      </div>
    ) : (
      <video src={concept.media_url} controls className="w-full rounded-xl" />
    );
  }
  if (concept.type_contenu === "pdf" && concept.media_url) {
    return (
      <a
        href={concept.media_url}
        target="_blank"
        rel="noreferrer"
        className="flex items-center gap-2 rounded-xl border border-border px-4 py-3 text-sm font-medium text-primary hover:bg-secondary/60"
      >
        <FileText className="size-4" /> Ouvrir le document PDF
      </a>
    );
  }
  return (
    <p className="whitespace-pre-wrap text-sm leading-relaxed text-foreground">
      {concept.contenu_texte || "Aucun contenu pour cette leçon."}
    </p>
  );
}

function StudentProgrammePage() {
  const { programmeId } = Route.useParams();
  const { data, isLoading, isError } = useProgrammeDetail(programmeId);
  const chapitres = data?.chapitres ?? [];
  const allConceptIds = useMemo(
    () => chapitres.flatMap((c) => c.concepts.map((k) => k.id)),
    [chapitres],
  );
  const { data: doneSet = new Set<string>() } = useProgression(allConceptIds);
  const setDone = useSetConceptDone();

  const [openChapitre, setOpenChapitre] = useState<string | null>(null);
  const [openConcept, setOpenConcept] = useState<string | null>(null);

  const totalConcepts = allConceptIds.length;
  const totalDone = allConceptIds.filter((id) => doneSet.has(id)).length;
  const pct = totalConcepts > 0 ? Math.round((totalDone / totalConcepts) * 100) : 0;

  if (isLoading) {
    return (
      <div className="space-y-4">
        <Skeleton className="h-32 rounded-2xl" />
        <Skeleton className="h-64 rounded-2xl" />
      </div>
    );
  }

  if (isError || !data?.programme) {
    return (
      <div className="rounded-2xl bg-card p-10 text-center shadow-sm">
        <p className="text-sm text-muted-foreground">Ce programme n'est pas accessible.</p>
        <Link to="/etudiant/cours" className="mt-4 inline-block text-sm font-medium text-primary">
          Retour à mes cours
        </Link>
      </div>
    );
  }

  const programme = data.programme;

  return (
    <div className="space-y-6">
      <Link
        to="/etudiant/cours"
        className="inline-flex items-center gap-2 text-sm text-muted-foreground hover:text-foreground"
      >
        <ArrowLeft className="size-4" /> Retour à mes cours
      </Link>

      <header className="gradient-welcome rounded-2xl p-6 text-primary-foreground shadow-sm">
        <p className="text-xs font-bold uppercase tracking-wide opacity-80">
          {programme.matiereNom ?? "Programme"} · {programme.classeNom ?? ""}
        </p>
        <h1 className="mt-2 font-display text-2xl font-bold">{programme.titre}</h1>
        {programme.description ? <p className="mt-2 text-sm opacity-90">{programme.description}</p> : null}
        <div className="mt-4 flex items-center gap-3">
          <Progress value={pct} className="h-2 max-w-xs bg-primary-foreground/20" />
          <span className="text-sm font-semibold">
            {totalDone}/{totalConcepts} leçons terminées · {pct}%
          </span>
        </div>
      </header>

      {chapitres.length === 0 ? (
        <div className="rounded-2xl border border-dashed border-border p-10 text-center text-sm text-muted-foreground">
          Aucun module n'a encore été publié pour ce programme.
        </div>
      ) : (
        <ul className="space-y-3">
          {chapitres.map((ch) => {
            const chapDone = ch.concepts.filter((k) => doneSet.has(k.id)).length;
            const isOpen = openChapitre === ch.id;
            return (
              <li key={ch.id} className="rounded-2xl border border-border bg-card p-4 shadow-sm">
                <button
                  onClick={() => setOpenChapitre(isOpen ? null : ch.id)}
                  className="flex w-full items-center justify-between gap-3 text-left"
                >
                  <div>
                    <p className="font-display text-base font-bold text-foreground">{ch.titre}</p>
                    <p className="text-xs text-muted-foreground">
                      {chapDone}/{ch.concepts.length} leçons · {ch.niveau ?? "—"}
                    </p>
                  </div>
                  {isOpen ? (
                    <ChevronUp className="size-5 shrink-0 text-muted-foreground" />
                  ) : (
                    <ChevronDown className="size-5 shrink-0 text-muted-foreground" />
                  )}
                </button>

                {isOpen ? (
                  <ul className="mt-4 space-y-2 border-t border-border pt-4">
                    {ch.concepts.length === 0 ? (
                      <li className="text-sm text-muted-foreground">Aucune leçon dans ce module.</li>
                    ) : (
                      ch.concepts.map((k) => {
                        const done = doneSet.has(k.id);
                        const isConceptOpen = openConcept === k.id;
                        return (
                          <li key={k.id} className="rounded-xl border border-border/70 p-3">
                            <div className="flex items-center gap-3">
                              <Checkbox
                                checked={done}
                                onCheckedChange={(checked) =>
                                  setDone.mutate({ conceptId: k.id, done: checked === true })
                                }
                                aria-label="Marquer comme terminé"
                              />
                              <button
                                onClick={() => setOpenConcept(isConceptOpen ? null : k.id)}
                                className="flex flex-1 items-center gap-2 text-left"
                              >
                                {k.type_contenu === "video" ? (
                                  <PlayCircle className="size-4 shrink-0 text-primary" />
                                ) : done ? (
                                  <CheckCircle2 className="size-4 shrink-0 text-success" />
                                ) : (
                                  <Circle className="size-4 shrink-0 text-muted-foreground" />
                                )}
                                <span className="text-sm font-medium text-foreground">{k.titre}</span>
                                <span className="ml-auto shrink-0 text-xs text-muted-foreground">
                                  {conceptTypeLabel(k.type_contenu)}
                                  {k.duree_minutes ? ` · ${k.duree_minutes} min` : ""}
                                </span>
                              </button>
                            </div>
                            {isConceptOpen ? (
                              <div className="mt-3 space-y-3 pl-7">
                                <ConceptContent concept={k} />
                                {!done ? (
                                  <Button
                                    size="sm"
                                    className="rounded-lg"
                                    disabled={setDone.isPending}
                                    onClick={() => setDone.mutate({ conceptId: k.id, done: true })}
                                  >
                                    Marquer cette leçon comme terminée
                                  </Button>
                                ) : null}
                              </div>
                            ) : null}
                          </li>
                        );
                      })
                    )}
                  </ul>
                ) : null}
              </li>
            );
          })}
        </ul>
      )}
    </div>
  );
}
