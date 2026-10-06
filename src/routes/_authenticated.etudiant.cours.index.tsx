import { createFileRoute } from "@tanstack/react-router";
import { StudentCoursesIndexPage } from "./_authenticated.etudiant.cours";

export const Route = createFileRoute("/_authenticated/etudiant/cours/")({
  component: StudentCoursesIndexPage,
  head: () => ({
    meta: [
      { title: "Mes cours — MANDAL" },
      { name: "description", content: "Retrouvez tous vos programmes et suivez votre progression." },
      { name: "robots", content: "noindex" },
    ],
  }),
});