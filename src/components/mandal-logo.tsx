import { cn } from "@/lib/utils";

export function MandalLogo({ className, compact = false }: { className?: string; compact?: boolean }) {
  return (
    <div className={cn("flex items-center", className)} aria-label="M'Andal">
      <img
        src="/images/logo-mandal.jpeg"
        alt="M'Andal — Maho Andal"
        className={cn("h-11 w-auto object-contain", compact ? "max-w-28" : "max-w-40")}
      />
    </div>
  );
}