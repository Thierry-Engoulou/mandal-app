import { createFileRoute } from "@tanstack/react-router";
import { useQueryClient } from "@tanstack/react-query";
import { Library } from "lucide-react";
import { useProfile } from "@/lib/use-profile";
import { DepotEpreuveForm } from "@/components/banque/depot-form";
import { MesDepots } from "@/components/banque/mes-depots";

export const Route = createFileRoute("/_authenticated/enseignant/banque")({
  component: TeacherBanquePage,
  head: () => ({
    meta: [
      { title: "Banque d'épreuves — Espace enseignant M'Andal" },
      { name: "robots", content: "noindex" },
    ],
  }),
});

function TeacherBanquePage() {
  const { data: profile } = useProfile();
  const queryClient = useQueryClient();
  const admin = profile?.role === "admin" || profile?.role === "super_admin";

  return (
    <div className="space-y-6">
      <header className="rounded-2xl bg-card p-6 shadow-sm">
        <Library className="mb-2 size-6 text-primary" />
        <h1 className="font-display text-2xl font-bold tracking-tight">Banque d'épreuves</h1>
        <p className="mt-1 max-w-2xl text-sm text-muted-foreground">
          Partage tes épreuves (devoirs, séquences, examens blancs, sujets officiels) avec tous les
          élèves. Elles sont publiées après vérification par l'équipe M'ANDAL. Indique toujours la
          source du sujet.
        </p>
      </header>

      {profile ? (
        <>
          <DepotEpreuveForm
            userId={profile.id}
            publier={admin}
            onDepose={() => void queryClient.invalidateQueries({ queryKey: ["banque-mes-depots"] })}
          />
          <section className="space-y-3">
            <h2 className="font-display text-lg font-bold">Mes épreuves déposées</h2>
            <MesDepots userId={profile.id} />
          </section>
        </>
      ) : null}
    </div>
  );
}
