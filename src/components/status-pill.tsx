import { cn } from "@/lib/utils";

export function StatusPill({ status }: { status: "active" | "finished" }) {
  return (
    <span
      className={cn(
        "rounded-full px-2.5 py-1 text-xs font-semibold",
        status === "active" ? "bg-success/10 text-success" : "bg-secondary text-muted-foreground",
      )}
    >
      {status === "active" ? "En cours" : "Terminée"}
    </span>
  );
}
