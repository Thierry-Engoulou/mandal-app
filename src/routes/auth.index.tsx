import { createFileRoute, Link, useNavigate } from "@tanstack/react-router";
import { useState, useEffect } from "react";
import { supabase } from "@/integrations/supabase/client";
import { MandalLogo } from "@/components/mandal-logo";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { toast } from "sonner";
import { Lock, Eye, EyeOff, LoaderCircle } from "lucide-react";

export const Route = createFileRoute("/auth/")({
  component: AuthPage,
  head: () => ({
    meta: [
      { title: "Connexion — MANDAL" },
      { name: "description", content: "Connectez-vous à votre espace MANDAL." },
      { property: "og:title", content: "Connexion — MANDAL" },
      { property: "og:description", content: "Accédez à votre espace éducatif MANDAL." },
      { property: "og:type", content: "website" },
      { name: "twitter:card", content: "summary" },
    ],
  }),
});

function AuthPage() {
  const navigate = useNavigate();
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [showPassword, setShowPassword] = useState(false);
  const [loading, setLoading] = useState(false);
  const [googleLoading, setGoogleLoading] = useState(false);

  // Si l'utilisateur a déjà une session valide ou arrive avec des paramètres auth
  useEffect(() => {
    supabase.auth.getSession().then(({ data: { session } }) => {
      if (session?.user) {
        supabase
          .from("profiles")
          .select("role")
          .eq("id", session.user.id)
          .maybeSingle()
          .then(({ data: profile }) => {
            const role = profile?.role || "student";
            if (role === "admin" || role === "super_admin") {
              navigate({ to: "/admin", replace: true });
            } else if (role === "teacher") {
              navigate({ to: "/enseignant", replace: true });
            } else {
              navigate({ to: "/etudiant", replace: true });
            }
          });
      }
    });
  }, [navigate]);

  const handleGoogleLogin = async () => {
    try {
      setGoogleLoading(true);
      const redirectUrl = `${window.location.origin}/auth/callback`;
      const { error } = await supabase.auth.signInWithOAuth({
        provider: "google",
        options: {
          redirectTo: redirectUrl,
          queryParams: {
            access_type: "offline",
            prompt: "consent",
          },
        },
      });
      if (error) {
        setGoogleLoading(false);
        toast.error(error.message);
      }
    } catch (err: any) {
      setGoogleLoading(false);
      toast.error(err.message || "Erreur lors de la connexion Google");
    }
  };

  const handleLogin = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    const identifier = email.trim();
    const credentials = identifier.includes("@")
      ? { email: identifier, password }
      : { phone: identifier.startsWith("+") ? identifier : `+237${identifier}`, password };
    const { data, error } = await supabase.auth.signInWithPassword(credentials);
    if (error) {
      setLoading(false);
      toast.error(error.message);
      return;
    }
    const { data: profile } = await supabase
      .from("profiles")
      .select("role")
      .eq("id", data.user.id)
      .maybeSingle();
    setLoading(false);
    toast.success("Bon retour ! Content de vous revoir");
    if (profile?.role === "admin" || profile?.role === "super_admin") {
      navigate({ to: "/admin" });
    } else if (profile?.role === "teacher") {
      navigate({ to: "/enseignant" });
    } else {
      navigate({ to: "/etudiant" });
    }
  };

  return (
    <div className="flex min-h-screen flex-col items-center justify-center bg-background px-4 py-10">
      <div className="w-full max-w-[420px]">
        <Link to="/" className="mb-7 flex justify-center"><MandalLogo /></Link>
        <div className="rounded-2xl border border-border bg-card p-8 shadow-lg">
          <div className="mb-6 flex flex-col items-center text-center">
            <div className="flex h-14 w-14 items-center justify-center rounded-full bg-primary/10">
              <Lock className="h-6 w-6 text-primary" />
            </div>
            <h1 className="font-display mt-5 text-2xl font-bold text-foreground">
              Bon retour !
            </h1>
            <p className="mt-2 text-sm text-muted-foreground">
              Connectez-vous pour accéder à votre espace
            </p>
          </div>

          <Button 
            type="button" 
            variant="outline" 
            className="h-12 w-full rounded-xl border-border bg-card text-foreground font-semibold hover:bg-secondary transition flex items-center justify-center gap-2" 
            onClick={handleGoogleLogin} 
            disabled={googleLoading || loading}
          >
            {googleLoading ? (
              <LoaderCircle className="animate-spin size-5 text-primary" />
            ) : (
              <svg className="size-5" viewBox="0 0 24 24">
                <path
                  fill="#4285F4"
                  d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z"
                />
                <path
                  fill="#34A853"
                  d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z"
                />
                <path
                  fill="#FBBC05"
                  d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.06H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.94l2.85-2.22.81-.63z"
                />
                <path
                  fill="#EA4335"
                  d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.06l3.66 2.84c.87-2.6 3.3-4.52 6.16-4.52z"
                />
              </svg>
            )}
            Continuer avec Google
          </Button>

          <div className="my-5 flex items-center gap-3"><span className="h-px flex-1 bg-border" /><span className="text-xs text-muted-foreground">Ou continuez avec email / téléphone</span><span className="h-px flex-1 bg-border" /></div>

          <form onSubmit={handleLogin} className="space-y-4">
            <div className="space-y-2">
              <Label htmlFor="email">Email ou Téléphone</Label>
              <Input
                id="email"
                type="text"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
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
                  className="absolute inset-y-0 right-0 flex items-center justify-center px-3 text-muted-foreground hover:text-foreground"
                  aria-label={showPassword ? "Masquer le mot de passe" : "Afficher le mot de passe"}
                >
                  {showPassword ? <EyeOff className="h-4 w-4" /> : <Eye className="h-4 w-4" />}
                </button>
              </div>
            </div>

            <div className="flex justify-end">
              <Link
                to="/"
                className="text-sm font-medium text-primary hover:underline"
              >
                Mot de passe oublié ?
              </Link>
            </div>

            <Button
              type="submit"
              className="w-full rounded-xl py-5 text-base font-semibold"
              disabled={loading}
            >
               {loading ? <><LoaderCircle className="animate-spin" /> Connexion…</> : "Se connecter"}
            </Button>
          </form>

          <p className="mt-6 text-center text-sm text-muted-foreground">
            Pas encore de compte ?{" "}
            <Link to="/inscription" className="font-medium text-primary hover:underline">
              Créer un compte
            </Link>
          </p>
        </div>
      </div>
    </div>
  );
}
