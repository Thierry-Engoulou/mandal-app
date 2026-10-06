import { cn } from "@/lib/utils";

const MAP: Record<string, { label: string; className: string }> = {
  approuve: { label: "Approuvé", className: "bg-success/10 text-success" },
  en_attente: { label: "En attente", className: "bg-warning/15 text-warning" },
  rejete: { label: "Refusé", className: "bg-destructive/10 text-destructive" },
  brouillon: { label: "Brouillon", className: "bg-secondary text-muted-foreground" },
  publie: { label: "Publié", className: "bg-success/10 text-success" },
  clos: { label: "Clos", className: "bg-violet/10 text-violet" },
  accepte: { label: "Accepté", className: "bg-success/10 text-success" },
  ouverte: { label: "Ouverte", className: "bg-primary/10 text-primary" },
};

export function TeacherStatusBadge({ status }: { status: string }) {
  const item = MAP[status] ?? { label: status, className: "bg-secondary text-muted-foreground" };
  return (
    <span className={cn("rounded-full px-2.5 py-1 text-xs font-semibold", item.className)}>
      {item.label}
    </span>
  );
}
