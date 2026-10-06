import { createFileRoute, Link, useNavigate } from "@tanstack/react-router";
import { useState, useEffect } from "react";
import { useServerFn } from "@tanstack/react-start";
import { z } from "zod";
import { supabase } from "@/integrations/supabase/client";
import { createProfile } from "@/lib/profiles.functions";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { toast } from "sonner";
import { UserPlus, Eye, EyeOff, GraduationCap, BookOpen } from "lucide-react";
import { cn } from "@/lib/utils";

const signupSearchSchema = z.object({
  level: z.string().optional(),
});

export const Route = createFileRoute("/inscription")({
  validateSearch: (search) => signupSearchSchema.parse(search),
  component: SignupPage,
  head: () => ({
    meta: [
      { title: "Créer un compte — M'Andal" },
      {
        name: "description",
        content: "Créez votre compte M'Andal et rejoignez la plateforme en quelques secondes.",
      },
      { property: "og:title", content: "Créer un compte — M'Andal" },
      { property: "og:description", content: "Rejoignez la plateforme en quelques secondes." },
      { property: "og:type", content: "website" },
      { name: "twitter:card", content: "summary" },
    ],
  }),
});

function SignupPage() {
  const navigate = useNavigate();
  const searchParams = Route.useSearch();
  const createProfileFn = useServerFn(createProfile);
  const [fullName, setFullName] = useState("");
  const [identifier, setIdentifier] = useState("");
  const [password, setPassword] = useState("");
  const [confirmPassword, setConfirmPassword] = useState("");
  const [role, setRole] = useState<"student" | "teacher">("student");
  const [selectedClassId, setSelectedClassId] = useState<string>(searchParams.level || "probatoire");
  const [dbClasses, setDbClasses] = useState<Array<{ id: string; nom: string; niveau?: string | null }>>([]);
  const [showPassword, setShowPassword] = useState(false);
  const [showConfirm, setShowConfirm] = useState(false);
  const [loading, setLoading] = useState(false);
  const [created, setCreated] = useState(false);

  // Charger les classes depuis la base Supabase
  useEffect(() => {
    supabase.from("classes").select("id, nom, niveau, filiere").then(({ data }) => {
      if (data && data.length > 0) {
        setDbClasses(data);
      }
    });
  }, []);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (password !== confirmPassword) {
      toast.error("Les mots de passe ne correspondent pas.");
      return;
    }
    if (password.length < 8) {
      toast.error("Le mot de passe doit contenir au moins 8 caractères.");
      return;
    }

    const value = identifier.trim();
    const isEmail = value.includes("@");
    if (!isEmail) {
      toast.error("Merci d'utiliser une adresse e-mail pour créer votre compte.");
      return;
    }

    setLoading(true);
    const { data, error } = await supabase.auth.signUp({
      email: value,
      password,
      options: {
        data: {
          full_name: fullName,
          role,
          classe_id: role === "student" ? selectedClassId : undefined,
        },
        emailRedirectTo: `${window.location.origin}/auth/callback`,
      },
    });

    if (error) {
      setLoading(false);
      toast.error(error.message);
      return;
    }

    if (data.user) {
      try {
        await createProfileFn({ data: { userId: data.user.id, fullName, role } });
        // Si c'est une classe de Supabase (UUID), inscrire l'élève dans class_membres
        if (role === "student" && selectedClassId.length > 10) {
          await supabase.from("class_membres").insert({
            eleve_id: data.user.id,
            class_id: selectedClassId,
          });
        }
      } catch (profileError) {
        console.error("Profile creation error:", profileError);
      }
    }

    setLoading(false);
    toast.success("Compte créé avec succès ! Vos cours sont prêts.");

    if (data.session) {
      navigate({ to: role === "teacher" ? "/enseignant" : "/etudiant/cours" });
      return;
    }
    setCreated(true);
  };

  return (
    <div className="flex min-h-screen items-center justify-center bg-background px-4 py-12">
      <div className="w-full max-w-[500px]">
        <div className="rounded-2xl bg-card p-6 sm:p-8 shadow-sm border border-border">
          <div className="mb-6 flex flex-col items-center text-center">
            <div className="flex h-14 w-14 items-center justify-center rounded-full bg-primary/10">
              <UserPlus className="h-6 w-6 text-primary" />
            </div>
            <h1 className="font-display mt-5 text-2xl font-bold text-foreground">
              Créer un compte M'Andal
            </h1>
            <p className="mt-2 text-sm text-muted-foreground">
              Accédez directement aux cours de votre classe enregistrés dans la base de données
            </p>
          </div>

          {created ? (
            <div className="rounded-xl bg-success/10 p-6 text-center">
              <h2 className="font-display text-lg font-semibold text-success">
                Compte créé avec succès !
              </h2>
              <p className="mt-2 text-sm text-muted-foreground">
                Un e-mail de confirmation a été envoyé à <strong>{identifier}</strong>. Activez
                votre compte puis connectez-vous pour retrouver l'intégralité des cours de votre classe.
              </p>
              <Button asChild className="mt-6 w-full rounded-xl">
                <Link to="/auth">Se connecter</Link>
              </Button>
            </div>
          ) : (
            <form onSubmit={handleSubmit} className="space-y-4">
              <div className="space-y-2">
                <Label htmlFor="fullName">Nom complet</Label>
                <Input
                  id="fullName"
                  value={fullName}
                  onChange={(e) => setFullName(e.target.value)}
                  required
                  placeholder="Jean Dupont"
                  className="rounded-xl"
                />
              </div>

              <div className="space-y-2">
                <Label htmlFor="identifier">Email ou Téléphone</Label>
                <Input
                  id="identifier"
                  value={identifier}
                  onChange={(e) => setIdentifier(e.target.value)}
                  required
                  placeholder="email@exemple.com ou 6XXXXXXXX"
                  className="rounded-xl"
                />
              </div>

              <div className="space-y-2">
                <Label htmlFor="password">Mot de passe</Label>
                <div className="relative">
                  <Input
                    id="password"
                    type={showPassword ? "text" : "password"}
                    value={password}
                    onChange={(e) => setPassword(e.target.value)}
                    required
                    placeholder="••••••••"
                    className="rounded-xl pr-10"
                  />
                  <button
                    type="button"
                    onClick={() => setShowPassword((v) => !v)}
                    className="absolute inset-y-0 right-0 flex items-center px-3 text-muted-foreground hover:text-foreground"
                    aria-label={showPassword ? "Masquer le mot de passe" : "Afficher le mot de passe"}
                  >
                    {showPassword ? <EyeOff className="h-4 w-4" /> : <Eye className="h-4 w-4" />}
                  </button>
                </div>
              </div>

              <div className="space-y-2">
                <Label htmlFor="confirmPassword">Confirmer le mot de passe</Label>
                <div className="relative">
                  <Input
                    id="confirmPassword"
                    type={showConfirm ? "text" : "password"}
                    value={confirmPassword}
                    onChange={(e) => setConfirmPassword(e.target.value)}
                    required
                    placeholder="••••••••"
                    className="rounded-xl pr-10"
                  />
                  <button
                    type="button"
                    onClick={() => setShowConfirm((v) => !v)}
                    className="absolute inset-y-0 right-0 flex items-center px-3 text-muted-foreground hover:text-foreground"
                    aria-label={showConfirm ? "Masquer le mot de passe" : "Afficher le mot de passe"}
                  >
                    {showConfirm ? <EyeOff className="h-4 w-4" /> : <Eye className="h-4 w-4" />}
                  </button>
                </div>
              </div>

              <div className="space-y-2">
                <Label>Je suis</Label>
                <div className="grid grid-cols-2 gap-3">
                  <button
                    type="button"
                    onClick={() => setRole("student")}
                    aria-pressed={role === "student"}
                    className={cn(
                      "flex items-center justify-center gap-2 rounded-xl border px-4 py-3 text-sm font-medium transition-colors",
                      role === "student"
                        ? "border-primary bg-primary/10 text-primary font-bold"
                        : "border-border bg-card text-muted-foreground hover:bg-secondary",
                    )}
                  >
                    <GraduationCap className="h-4 w-4" />
                    Étudiant / Élève
                  </button>
                  <button
                    type="button"
                    onClick={() => setRole("teacher")}
                    aria-pressed={role === "teacher"}
                    className={cn(
                      "flex items-center justify-center gap-2 rounded-xl border px-4 py-3 text-sm font-medium transition-colors",
                      role === "teacher"
                        ? "border-primary bg-primary/10 text-primary font-bold"
                        : "border-border bg-card text-muted-foreground hover:bg-secondary",
                    )}
                  >
                    <BookOpen className="h-4 w-4" />
                    Enseignant
                  </button>
                </div>
              </div>

              {/* Sélecteur de Classe / Niveau pour l'élève */}
              {role === "student" && (
                <div className="space-y-2 rounded-xl border border-primary/20 bg-primary/5 p-4">
                  <Label htmlFor="classeSelect" className="text-xs font-bold uppercase tracking-wider text-primary">
                    🎓 Choisissez votre Classe ou Concours
                  </Label>
                  <select
                    id="classeSelect"
                    value={selectedClassId}
                    onChange={(e) => setSelectedClassId(e.target.value)}
                    className="w-full rounded-xl border border-border bg-background px-3 py-2.5 text-sm font-semibold text-foreground focus:outline-none focus:ring-2 focus:ring-primary"
                  >
                    <optgroup label="Niveaux Scolaires">
                      <option value="probatoire">Probatoire (1ère · Séries A, C, D, TI)</option>
                      <option value="bac">Baccalauréat (Terminale · Séries A, C, D)</option>
                      <option value="bepc">BEPC (3ème · Premier cycle)</option>
                      <option value="alevel">Advanced Level (Section anglophone)</option>
                      <option value="ens">ENS Technique</option>
                      <option value="universite">Université (Licence · Master)</option>
                    </optgroup>
                    <optgroup label="Grands Concours">
                      <option value="enspd">Concours ENSPD (Polytechnique Douala)</option>
                      <option value="iut">Concours IUT (Filières Technologiques)</option>
                    </optgroup>
                    {dbClasses.length > 0 && (
                      <optgroup label="Classes de l'établissement">
                        {dbClasses.map((c) => (
                          <option key={c.id} value={c.id}>
                            {c.nom} {c.niveau ? `(${c.niveau})` : ""}
                          </option>
                        ))}
                      </optgroup>
                    )}
                  </select>
                </div>
              )}

              <Button
                type="submit"
                className="w-full rounded-xl py-5 text-base font-semibold"
                disabled={loading}
              >
                {loading ? "Création en cours…" : "Créer mon compte & Accéder aux cours"}
              </Button>

              <p className="text-center text-sm text-muted-foreground">
                Déjà un compte ?{" "}
                <Link to="/auth" className="font-medium text-primary hover:underline">
                  Se connecter
                </Link>
              </p>
            </form>
          )}
        </div>
      </div>
    </div>
  );
}
