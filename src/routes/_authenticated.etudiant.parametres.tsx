import { createFileRoute } from "@tanstack/react-router";
import { PagePlaceholder } from "@/components/page-placeholder";

export const Route = createFileRoute("/_authenticated/etudiant/parametres")({
  component: StudentSettingsPage,
  head: () => ({
    meta: [
      { title: "Paramètres — M'Andal" },
      { name: "description", content: "Paramètres sur la plateforme M'Andal." },
      { name: "robots", content: "noindex" },
    ],
  }),
});

function StudentSettingsPage() {
  return <PagePlaceholder title="Paramètres" />;
}
