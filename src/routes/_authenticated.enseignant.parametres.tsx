import { createFileRoute } from "@tanstack/react-router";
import { useQuery, useQueryClient } from "@tanstack/react-query";
import { useEffect, useState } from "react";
import { Loader2, Upload, UserRound } from "lucide-react";
import { toast } from "sonner";
import { supabase } from "@/integrations/supabase/client";
import { useProfile } from "@/lib/use-profile";
import { useSelectedSchool, useTeacherValidation } from "@/lib/use-teacher";
import { TeacherStatusBadge } from "@/components/teacher-status-badge";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";

export const Route = createFileRoute("/_authenticated/enseignant/parametres")({
  component: TeacherSettingsPage,
  head: () => ({
    meta: [
      { title: "Paramètres — M'Andal" },
      { name: "description", content: "Paramètres sur la plateforme M'Andal." },
      { name: "robots", content: "noindex" },
    ],
  }),
});

function TeacherSettingsPage() {
  const { data: profile } = useProfile();
  const queryClient = useQueryClient();
  const { school, schoolId } = useSelectedSchool();
  const { data: validation } = useTeacherValidation(schoolId);

  const [prenom, setPrenom] = useState("");
  const [nom, setNom] = useState("");
  const [saving, setSaving] = useState(false);
  const [uploading, setUploading] = useState(false);

  useEffect(() => {
    if (!profile) return;
    setPrenom(profile.prenom ?? "");
    setNom(profile.nom ?? "");
  }, [profile]);

  const { data: avatarUrl } = useQuery({
    enabled: !!profile?.avatar_url,
    queryKey: ["avatar", profile?.id, profile?.avatar_url],
    queryFn: async () => {
      const path = profile!.avatar_url!;
      if (path.startsWith("http")) return path;
      const { data } = await supabase.storage.from("avatars").createSignedUrl(path, 60 * 60);
      return data?.signedUrl ?? null;
    },
  });

  const save = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!profile) return;
    setSaving(true);
    const full = [prenom, nom].filter(Boolean).join(" ").trim();
    const { error } = await supabase
      .from("profiles")
      .update({ prenom: prenom || null, nom: nom || null, full_name: full || null })
      .eq("id", profile.id);
    setSaving(false);
    if (error) {
      toast.error(error.message);
      return;
    }
    toast.success("Profil mis à jour");
    await queryClient.invalidateQueries({ queryKey: ["mon-profil"] });
  };

  const uploadAvatar = async (file: File) => {
    if (!profile) return;
    setUploading(true);
    const ext = file.name.split(".").pop()?.toLowerCase() ?? "jpg";
    const path = `${profile.id}/avatar-${Date.now()}.${ext}`;
    const { error: upErr } = await supabase.storage
      .from("avatars")
      .upload(path, file, { upsert: true });
    if (upErr) {
      setUploading(false);
      toast.error(upErr.message);
      return;
    }
    const { error } = await supabase
      .from("profiles")
      .update({ avatar_url: path })
      .eq("id", profile.id);
    setUploading(false);
    if (error) {
      toast.error(error.message);
      return;
    }
    toast.success("Photo mise à jour");
    await queryClient.invalidateQueries({ queryKey: ["mon-profil"] });
  };

  return (
    <div className="space-y-6">
      <h1 className="font-display text-2xl font-bold tracking-tight text-foreground">Paramètres</h1>

      <section className="rounded-2xl bg-card p-6 shadow-sm">
        <h2 className="font-display text-lg font-bold text-foreground">Mon profil</h2>
        <div className="mt-5 flex flex-wrap items-center gap-5">
          {avatarUrl ? (
            <img src={avatarUrl} alt="Avatar" className="size-20 rounded-full object-cover" />
          ) : (
            <div className="flex size-20 items-center justify-center rounded-full bg-violet/10 text-violet">
              <UserRound className="size-8" />
            </div>
          )}
          <label className="inline-flex cursor-pointer items-center gap-2 rounded-xl border border-input px-4 py-2 text-sm font-medium hover:bg-secondary">
            {uploading ? (
              <Loader2 className="size-4 animate-spin" />
            ) : (
              <Upload className="size-4" />
            )}
            Changer la photo
            <input
              type="file"
              accept="image/*"
              className="hidden"
              disabled={uploading}
              onChange={(e) => {
                const f = e.target.files?.[0];
                if (f) void uploadAvatar(f);
                e.target.value = "";
              }}
            />
          </label>
        </div>

        <form onSubmit={save} className="mt-6 grid gap-4 sm:grid-cols-2">
          <div className="space-y-2">
            <Label htmlFor="prenom">Prénom</Label>
            <Input
              id="prenom"
              value={prenom}
              onChange={(e) => setPrenom(e.target.value)}
              className="rounded-xl"
            />
          </div>
          <div className="space-y-2">
            <Label htmlFor="nom">Nom</Label>
            <Input
              id="nom"
              value={nom}
              onChange={(e) => setNom(e.target.value)}
              className="rounded-xl"
            />
          </div>
          <div className="sm:col-span-2">
            <Button
              type="submit"
              disabled={saving}
              className="rounded-xl bg-success text-success-foreground hover:bg-success/90"
            >
              {saving ? "Enregistrement…" : "Enregistrer"}
            </Button>
          </div>
        </form>
      </section>

      <section className="rounded-2xl bg-card p-6 shadow-sm">
        <div className="flex flex-wrap items-center justify-between gap-3">
          <h2 className="font-display text-lg font-bold text-foreground">Validation du compte</h2>
          <TeacherStatusBadge status={validation?.statut ?? "en_attente"} />
        </div>
        <p className="mt-2 text-sm text-muted-foreground">
          {school ? `Établissement : ${school.nom}.` : "Aucun établissement assigné."}{" "}
          {validation?.statut === "approuve"
            ? "Votre compte est approuvé par le chef d'établissement."
            : "Seul votre chef d'établissement peut modifier ce statut."}
        </p>
      </section>
    </div>
  );
}
