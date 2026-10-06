export function PagePlaceholder({ title }: { title: string }) {
  return (
    <div className="space-y-6">
      <h1 className="font-display text-2xl font-bold tracking-tight text-foreground">{title}</h1>
      <div className="rounded-2xl bg-card p-10 text-center shadow-sm">
        <p className="text-sm text-muted-foreground">Contenu de la page</p>
      </div>
    </div>
  );
}
