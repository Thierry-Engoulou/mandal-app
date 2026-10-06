import { createFileRoute, Link } from "@tanstack/react-router";
import { useState } from "react";
import { useServerFn } from "@tanstack/react-start";
import { submitStudentApplication } from "@/lib/site-content.functions";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Textarea } from "@/components/ui/textarea";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { toast } from "sonner";

const PILLARS = [
  { value: "education", label: "Éducation" },
  { value: "citoyennete", label: "Citoyenneté" },
  { value: "identite_culture", label: "Identité & Culture" },
  { value: "orientation", label: "Orientation" },
  { value: "developpement", label: "Développement" },
  { value: "entrepreneuriat", label: "Entrepreneuriat" },
  { value: "sante_bien_etre", label: "Santé & Bien-être" },
  { value: "culture_generale", label: "Culture générale" },
];

const LEVELS = ["Collège", "Lycée", "Université", "Formation professionnelle", "Autre"];

export const Route = createFileRoute("/demande-inscription")({
  component: StudentApplicationPage,
  head: () => ({
    meta: [
      { title: "Demande d'inscription étudiants — M'Andal" },
      {
        name: "description",
        content:
          "Déposez votre demande d'inscription étudiante à M'Andal : formation, olympiades et modules des 8 piliers de l'excellence.",
      },
      { property: "og:title", content: "Demande d'inscription étudiants — M'Andal" },
      {
        property: "og:description",
        content: "Rejoignez la communauté M'Andal : envoyez votre demande d'inscription à l'équipe.",
      },
      { property: "og:type", content: "website" },
      { name: "twitter:card", content: "summary" },
    ],
  }),
});

function StudentApplicationPage() {
  const submit = useServerFn(submitStudentApplication);
  const [loading, setLoading] = useState(false);
  const [sent, setSent] = useState(false);
  const [form, setForm] = useState({
    full_name: "",
    email: "",
    phone: "",
    country: "",
    city: "",
    school: "",
    school_level: "Lycée",
    pillar_interest: "education",
    motivation: "",
  });

  const set = (key: keyof typeof form) => (value: string) =>
    setForm((f) => ({ ...f, [key]: value }));

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    try {
      await submit({ data: form });
      setSent(true);
      toast.success("Demande envoyée à l'équipe M'Andal.");
    } catch (error) {
      toast.error(error instanceof Error ? error.message : "Erreur lors de l'envoi.");
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="min-h-screen bg-background text-foreground">
      <header className="border-b border-border">
        <div className="mx-auto flex max-w-4xl items-center justify-between px-6 py-4">
          <Link to="/" className="font-display text-xl font-extrabold tracking-tighter">
            M'ANDAL
          </Link>
          <Link to="/courses" className="text-sm font-medium hover:text-primary transition-colors">
            Modules
          </Link>
        </div>
      </header>

      <main className="mx-auto max-w-3xl px-6 py-16">
        <span className="font-mono text-xs uppercase tracking-[0.3em] text-primary">
          Rejoindre M'Andal
        </span>
        <h1 className="mt-4 font-display text-4xl font-extrabold tracking-tighter">
          Demande d'inscription étudiants
        </h1>
        <p className="mt-4 text-muted-foreground">
          Remplissez ce formulaire : votre demande est transmise à l'équipe M'Andal, qui vous
          recontacte par e-mail.
        </p>

        {sent ? (
          <div className="mt-10 border border-border bg-card p-10 text-center">
            <h2 className="font-display text-2xl font-bold">Demande bien reçue</h2>
            <p className="mt-3 text-muted-foreground">
              Merci {form.full_name.split(" ")[0]} ! L'équipe M'Andal étudie votre demande et vous
              répondra à l'adresse {form.email}.
            </p>
            <div className="mt-8 flex justify-center gap-4">
              <Button asChild>
                <Link to="/courses">Découvrir les modules</Link>
              </Button>
              <Button asChild variant="outline">
                <Link to="/">Retour à l'accueil</Link>
              </Button>
            </div>
          </div>
        ) : (
          <form onSubmit={handleSubmit} className="mt-10 space-y-6">
            <div className="grid gap-4 sm:grid-cols-2">
              <div className="space-y-2">
                <Label htmlFor="full_name">Nom complet</Label>
                <Input
                  id="full_name"
                  required
                  value={form.full_name}
                  onChange={(e) => set("full_name")(e.target.value)}
                />
              </div>
              <div className="space-y-2">
                <Label htmlFor="email">E-mail</Label>
                <Input
                  id="email"
                  type="email"
                  required
                  value={form.email}
                  onChange={(e) => set("email")(e.target.value)}
                />
              </div>
              <div className="space-y-2">
                <Label htmlFor="phone">Téléphone (optionnel)</Label>
                <Input id="phone" value={form.phone} onChange={(e) => set("phone")(e.target.value)} />
              </div>
              <div className="space-y-2">
                <Label htmlFor="country">Pays</Label>
                <Input
                  id="country"
                  required
                  value={form.country}
                  onChange={(e) => set("country")(e.target.value)}
                />
              </div>
              <div className="space-y-2">
                <Label htmlFor="city">Ville (optionnel)</Label>
                <Input id="city" value={form.city} onChange={(e) => set("city")(e.target.value)} />
              </div>
              <div className="space-y-2">
                <Label htmlFor="school">Établissement (optionnel)</Label>
                <Input id="school" value={form.school} onChange={(e) => set("school")(e.target.value)} />
              </div>
              <div className="space-y-2">
                <Label>Niveau scolaire</Label>
                <Select value={form.school_level} onValueChange={set("school_level")}>
                  <SelectTrigger>
                    <SelectValue />
                  </SelectTrigger>
                  <SelectContent>
                    {LEVELS.map((l) => (
                      <SelectItem key={l} value={l}>
                        {l}
                      </SelectItem>
                    ))}
                  </SelectContent>
                </Select>
              </div>
              <div className="space-y-2">
                <Label>Pilier d'intérêt</Label>
                <Select value={form.pillar_interest} onValueChange={set("pillar_interest")}>
                  <SelectTrigger>
                    <SelectValue />
                  </SelectTrigger>
                  <SelectContent>
                    {PILLARS.map((p) => (
                      <SelectItem key={p.value} value={p.value}>
                        {p.label}
                      </SelectItem>
                    ))}
                  </SelectContent>
                </Select>
              </div>
            </div>

            <div className="space-y-2">
              <Label htmlFor="motivation">Motivation</Label>
              <Textarea
                id="motivation"
                required
                rows={6}
                minLength={20}
                placeholder="Pourquoi souhaitez-vous rejoindre M'Andal ? (20 caractères minimum)"
                value={form.motivation}
                onChange={(e) => set("motivation")(e.target.value)}
              />
            </div>

            <Button type="submit" disabled={loading} size="lg">
              {loading ? "Envoi…" : "Envoyer ma demande"}
            </Button>
          </form>
        )}
      </main>
    </div>
  );
}
