import { createFileRoute } from "@tanstack/react-router";
import { PagePlaceholder } from "@/components/page-placeholder";

export const Route = createFileRoute("/_authenticated/etudiant/orientation/filieres")({
  component: StudentTracksPage,
  head: () => ({
    meta: [
      { title: "Filières — M'Andal" },
      { name: "description", content: "Filières sur la plateforme M'Andal." },
      { name: "robots", content: "noindex" },
    ],
  }),
});

function StudentTracksPage() {
  return <PagePlaceholder title="Filières" />;
}
