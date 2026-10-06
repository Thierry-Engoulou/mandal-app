import { createFileRoute } from "@tanstack/react-router";
import { PagePlaceholder } from "@/components/page-placeholder";

export const Route = createFileRoute("/_authenticated/etudiant/orientation/metiers")({
  component: StudentCareersPage,
  head: () => ({
    meta: [
      { title: "Métiers — M'Andal" },
      { name: "description", content: "Métiers sur la plateforme M'Andal." },
      { name: "robots", content: "noindex" },
    ],
  }),
});

function StudentCareersPage() {
  return <PagePlaceholder title="Métiers" />;
}
