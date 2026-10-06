export function ChefNoSchool() {
  return (
    <div className="rounded-2xl bg-card p-6 shadow-sm">
      <h2 className="font-display text-lg font-semibold text-foreground">
        Aucun établissement rattaché
      </h2>
      <p className="mt-2 text-sm text-muted-foreground">
        Votre compte n'est encore rattaché à aucun établissement. Contactez l'administration de la
        plateforme pour finaliser votre rattachement.
      </p>
    </div>
  );
}
