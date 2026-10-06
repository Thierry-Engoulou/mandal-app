import { createFileRoute, Outlet } from "@tanstack/react-router";
import { StudentShell } from "@/components/student-shell";

export const Route = createFileRoute("/_authenticated/etudiant")({
  component: StudentLayout,
});

function StudentLayout() {
  return (
    <StudentShell>
      <Outlet />
    </StudentShell>
  );
}
