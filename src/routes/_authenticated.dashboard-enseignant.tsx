import { createFileRoute, redirect } from "@tanstack/react-router";

export const Route = createFileRoute("/_authenticated/dashboard-enseignant")({
  beforeLoad: () => {
    throw redirect({ to: "/enseignant" });
  },
});
