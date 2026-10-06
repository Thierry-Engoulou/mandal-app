import { createFileRoute, useNavigate, Link } from "@tanstack/react-router";
import { useRef, useState } from "react";
import { useServerFn } from "@tanstack/react-start";
import { createCourse } from "@/lib/courses.functions";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Textarea } from "@/components/ui/textarea";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { Switch } from "@/components/ui/switch";
import { toast } from "sonner";
import { Upload } from "lucide-react";
import { ACCEPTED_IMPORT_TYPES, extractTextFromFile, titleFromFileName } from "@/lib/document-text";

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

const LEVELS = [
  { value: "debutant", label: "Débutant" },
  { value: "intermediaire", label: "Intermédiaire" },
  { value: "avance", label: "Avancé" },
];

export const Route = createFileRoute("/_authenticated/courses/new")({
  component: NewCoursePage,
  head: () => ({
    meta: [
      { title: "Nouveau module — M'Andal" },
      { name: "description", content: "Créez un nouveau module de cours M'Andal." },
    ],
  }),
});

function NewCoursePage() {
  const navigate = useNavigate();
  const create = useServerFn(createCourse);
  const [title, setTitle] = useState("");
  const [content, setContent] = useState("");
  const [pillar, setPillar] = useState("education");
  const [level, setLevel] = useState("debutant");
  const [isPublished, setIsPublished] = useState(true);
  const [loading, setLoading] = useState(false);
  const [importing, setImporting] = useState(false);
  const [importedName, setImportedName] = useState<string | null>(null);
  const fileInputRef = useRef<HTMLInputElement>(null);

  const handleFile = async (file: File) => {
    setImporting(true);
    try {
      const text = await extractTextFromFile(file);
      if (!text) {
        toast.error("Aucun texte n'a pu être extrait de ce fichier.");
        return;
      }
      setContent((current) => (current.trim() ? `${current.trim()}\n\n${text}` : text));
      setTitle((current) => current || titleFromFileName(file.name));
      setImportedName(file.name);
      toast.success(`Contenu importé depuis ${file.name}.`);
    } catch (error) {
      toast.error(error instanceof Error ? error.message : "Import impossible.");
    } finally {
      setImporting(false);
      if (fileInputRef.current) fileInputRef.current.value = "";
    }
  };


  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    try {
      const { id } = await create({
        data: { title, content, pillar, level, is_published: isPublished },
      });
      toast.success("Module créé avec succès.");
      navigate({ to: "/courses/$courseId", params: { courseId: id } });
    } catch (error) {
      toast.error(error instanceof Error ? error.message : "Erreur lors de la création.");
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="min-h-screen bg-background">
      <header className="border-b">
        <div className="mx-auto flex max-w-3xl items-center justify-between px-6 py-4">
          <Link to="/" className="font-display text-xl font-bold tracking-tight">
            M'ANDAL
          </Link>
          <Button asChild variant="ghost" size="sm">
            <Link to="/courses">Retour aux modules</Link>
          </Button>
        </div>
      </header>

      <main className="mx-auto max-w-3xl px-6 py-12">
        <h1 className="font-display text-3xl font-bold tracking-tight text-foreground">
          Nouveau module
        </h1>
        <p className="mt-2 text-muted-foreground">
          Rédigez un module de cours structuré pour les apprenants M'Andal, ou importez un document
          existant.
        </p>

        <div className="mt-8 rounded-lg border border-dashed p-6">
          <div className="flex flex-col gap-3 sm:flex-row sm:items-center sm:justify-between">
            <div>
              <p className="font-medium text-foreground">Importer un document</p>
              <p className="text-sm text-muted-foreground">
                {importedName
                  ? `Dernier fichier importé : ${importedName}`
                  : "Formats acceptés : .txt, .md, .docx, .pdf"}
              </p>
            </div>
            <Button
              type="button"
              variant="outline"
              disabled={importing}
              onClick={() => fileInputRef.current?.click()}
            >
              <Upload className="mr-2 h-4 w-4" />
              {importing ? "Extraction…" : "Choisir un fichier"}
            </Button>
          </div>
          <input
            ref={fileInputRef}
            type="file"
            accept={ACCEPTED_IMPORT_TYPES}
            className="sr-only"
            onChange={(e) => {
              const file = e.target.files?.[0];
              if (file) void handleFile(file);
            }}
          />
        </div>

        <form onSubmit={handleSubmit} className="mt-8 space-y-6">
          <div className="space-y-2">
            <Label htmlFor="title">Titre du module</Label>
            <Input
              id="title"
              value={title}
              onChange={(e) => setTitle(e.target.value)}
              required
              placeholder="Ex. : Les fondamentaux de la citoyenneté"
            />
          </div>

          <div className="grid gap-4 sm:grid-cols-2">
            <div className="space-y-2">
              <Label>Pilier</Label>
              <Select value={pillar} onValueChange={setPillar}>
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
            <div className="space-y-2">
              <Label>Niveau</Label>
              <Select value={level} onValueChange={setLevel}>
                <SelectTrigger>
                  <SelectValue />
                </SelectTrigger>
                <SelectContent>
                  {LEVELS.map((l) => (
                    <SelectItem key={l.value} value={l.value}>
                      {l.label}
                    </SelectItem>
                  ))}
                </SelectContent>
              </Select>
            </div>
          </div>

          <div className="space-y-2">
            <Label htmlFor="content">Contenu</Label>
            <Textarea
              id="content"
              value={content}
              onChange={(e) => setContent(e.target.value)}
              required
              rows={12}
              placeholder="Rédigez le contenu du module ici…"
            />
          </div>

          <div className="flex items-center gap-3">
            <Switch id="published" checked={isPublished} onCheckedChange={setIsPublished} />
            <Label htmlFor="published" className="cursor-pointer">
              Publier immédiatement
            </Label>
          </div>

          <div className="flex gap-4">
            <Button type="submit" disabled={loading}>
              {loading ? "Création…" : "Créer le module"}
            </Button>
            <Button asChild variant="outline" type="button">
              <Link to="/courses">Annuler</Link>
            </Button>
          </div>
        </form>
      </main>
    </div>
  );
}
