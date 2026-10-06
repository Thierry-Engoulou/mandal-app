import { createFileRoute, Outlet } from "@tanstack/react-router";
import { TeacherShell } from "@/components/teacher-shell";

export const Route = createFileRoute("/_authenticated/enseignant")({
  component: TeacherLayout,
});

function TeacherLayout() {
  return (
    <TeacherShell>
      <Outlet />
    </TeacherShell>
  );
}
