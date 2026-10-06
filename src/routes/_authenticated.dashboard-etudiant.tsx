import { createFileRoute, redirect } from "@tanstack/react-router";

export const Route = createFileRoute("/_authenticated/dashboard-etudiant")({
  beforeLoad: () => {
    throw redirect({ to: "/etudiant" });
  },
});
