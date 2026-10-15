import { createFileRoute } from "@tanstack/react-router";
import { useState } from "react";
import { GraduationCap, HelpCircle, Route as RouteIcon } from "lucide-react";
import { FichesExplorer } from "@/components/orientation/fiches-explorer";
import { TabButton } from "@/components/messagerie/tab-button";

export const Route = createFileRoute("/_authenticated/etudiant/orientation/filieres")({
  component: StudentTracksPage,
  head: () => ({
    meta: [
      { title: "Filières — M'Andal" },
      {
        name: "description",
        content: "Séries, filières, concours et écoles au Cameroun, avec leurs références.",
      },
      { name: "robots", content: "noindex" },
    ],
  }),
});

function StudentTracksPage() {
  const [onglet, setOnglet] = useState<"filiere" | "faq">("filiere");
  return (
    <div className="space-y-6">
      <header className="gradient-progress rounded-2xl p-6 text-primary-foreground shadow-sm">
        <GraduationCap className="mb-2 size-6" />
        <h1 className="font-display text-2xl font-bold tracking-tight">Filières</h1>
        <p className="mt-1 max-w-2xl text-sm opacity-90">
          Séries du secondaire, université, grandes écoles, BTS/HND et formation professionnelle au
          Cameroun : à quoi elles mènent, comment y accéder, et où vérifier.
        </p>
      </header>
      <div className="flex gap-2">
        <TabButton
          active={onglet === "filiere"}
          onClick={() => setOnglet("filiere")}
          icon={<RouteIcon className="size-4" />}
          label="Filières"
        />
        <TabButton
          active={onglet === "faq"}
          onClick={() => setOnglet("faq")}
          icon={<HelpCircle className="size-4" />}
          label="Questions fréquentes"
        />
      </div>
      {onglet === "filiere" ? (
        <FichesExplorer
          key="filiere"
          type="filiere"
          placeholder="Ex. : série D, médecine, ENS, BTS, GCE A Level…"
        />
      ) : (
        <FichesExplorer
          key="faq"
          type="faq"
          placeholder="Ex. : résultats du bac, bourse, concours de police…"
        />
      )}
    </div>
  );
}
