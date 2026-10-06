import { createFileRoute } from "@tanstack/react-router";
import { PagePlaceholder } from "@/components/page-placeholder";

export const Route = createFileRoute("/_authenticated/etudiant/historique")({
  component: StudentHistoryPage,
  head: () => ({
    meta: [
      { title: "Historique — M'Andal" },
      { name: "description", content: "Historique sur la plateforme M'Andal." },
      { name: "robots", content: "noindex" },
    ],
  }),
});

function StudentHistoryPage() {
  return <PagePlaceholder title="Historique" />;
}
