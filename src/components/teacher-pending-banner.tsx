import { ShieldAlert } from "lucide-react";

export function TeacherPendingBanner({
  statut,
}: {
  statut?: "en_attente" | "approuve" | "rejete" | undefined;
}) {
  if (!statut || statut === "approuve") return null;

  const rejected = statut === "rejete";
  return (
    <div
      className={`flex items-start gap-3 rounded-2xl border p-4 text-sm shadow-sm ${
        rejected
          ? "border-destructive/30 bg-destructive/10 text-destructive"
          : "border-warning/40 bg-warning/10 text-foreground"
      }`}
    >
      <ShieldAlert className="mt-0.5 size-5 shrink-0" />
      <div>
        <p className="font-semibold">
          {rejected
            ? "Votre compte enseignant a été refusé"
            : "Compte en attente de validation par votre chef d'établissement"}
        </p>
        <p className="mt-1 opacity-90">
          Vous gardez un accès complet à votre espace en attendant. La validation servira
          uniquement à confirmer votre rattachement à l'établissement.
        </p>
      </div>
    </div>
  );
}
