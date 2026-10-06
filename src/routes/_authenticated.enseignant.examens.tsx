import { createFileRoute } from "@tanstack/react-router";
import { useQuery, useQueryClient } from "@tanstack/react-query";
import { useState } from "react";
import {
  Plus,
  Pencil,
  Trash2,
  Lock,
  Unlock,
  HelpCircle,
  Clock,
  BookOpen,
  FileQuestion,
  CheckCircle2,
  Sparkles,
} from "lucide-react";
import { toast } from "sonner";
import { supabase } from "@/integrations/supabase/client";
import { useProfile } from "@/lib/use-profile";
import { useTeacherClasses, useSelectedSchool } from "@/lib/use-teacher";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Textarea } from "@/components/ui/textarea";
import { Badge } from "@/components/ui/badge";
import { Card, CardContent, CardDescription, CardFooter, CardHeader, CardTitle } from "@/components/ui/card";
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import { Switch } from "@/components/ui/switch";
import { RadioGroup, RadioGroupItem } from "@/components/ui/radio-group";

export const Route = createFileRoute("/_authenticated/enseignant/examens")({
  component: TeacherExamsPage,
  head: () => ({
    meta: [
      { title: "Gestion des Quiz & Examens — M'Andal" },
      { name: "description", content: "Créez et gérez les évaluations et quiz de vos chapitres." },
      { name: "robots", content: "noindex" },
    ],
  }),
});

export type ExamenRow = {
  id: string;
  titre: string;
  description: string | null;
  duree_minutes: number;
  nb_questions: number;
  statut: string;
  deverrouille_si: string;
  chapitre_id: string | null;
  programme_id: string | null;
  classe_id: string | null;
  etablissement_id: string | null;
  created_at: string;
  chapitres?: { id: string; titre: string; programme_id: string } | null;
  classes?: { id: string; nom: string } | null;
};

export type QuestionRow = {
  id: string;
  examen_id: string;
  enonce: string;
  options: string[];
  reponse_correcte: string | null;
  points: number;
  ordre: number;
  type: string;
};

function TeacherExamsPage() {
  const { data: profile } = useProfile();
  const { schoolId } = useSelectedSchool();
  const { data: teacherClasses = [] } = useTeacherClasses(schoolId);
  const queryClient = useQueryClient();

  const [examDialog, setExamDialog] = useState<boolean>(false);
  const [editingExam, setEditingExam] = useState<ExamenRow | null>(null);

  const [questionsDialog, setQuestionsDialog] = useState<ExamenRow | null>(null);

  // Form states for Exam Dialog
  const [examForm, setExamForm] = useState({
    titre: "",
    description: "",
    duree_minutes: 15,
    statut: "publie",
    deverrouille_si: "toujours",
    classe_id: "",
    programme_id: "",
    chapitre_id: "",
  });

  // Form states for Question Dialog
  const [questionForm, setQuestionForm] = useState({
    enonce: "",
    options: ["", "", "", ""],
    reponse_correcte: "0",
    points: 1,
  });
  const [savingQuestion, setSavingQuestion] = useState(false);

  // 1. Fetch Teacher's Exams
  const { data: examens = [], isLoading } = useQuery({
    enabled: !!profile,
    queryKey: ["teacher-examens", profile?.id, schoolId],
    queryFn: async (): Promise<ExamenRow[]> => {
      const { data, error } = await supabase
        .from("examens")
        .select(`
          *,
          chapitres:chapitre_id(id, titre, programme_id),
          classes:classe_id(id, nom)
        `)
        .eq("created_by", profile!.id)
        .order("created_at", { ascending: false });

      if (error) throw new Error(error.message);
      return (data ?? []).map((row) => ({
        ...row,
        chapitres: Array.isArray(row.chapitres) ? row.chapitres[0] ?? null : row.chapitres,
        classes: Array.isArray(row.classes) ? row.classes[0] ?? null : row.classes,
      })) as ExamenRow[];
    },
  });

  // 2. Fetch Programmes based on selected class in form
  const { data: programmes = [] } = useQuery({
    enabled: !!examForm.classe_id,
    queryKey: ["programmes-for-class", examForm.classe_id],
    queryFn: async () => {
      const { data, error } = await supabase
        .from("programmes")
        .select("id, titre")
        .eq("classe_id", examForm.classe_id)
        .order("titre");
      if (error) throw new Error(error.message);
      return data ?? [];
    },
  });

  // 3. Fetch Chapitres based on selected programme in form
  const { data: chapitres = [] } = useQuery({
    enabled: !!examForm.programme_id,
    queryKey: ["chapitres-for-programme", examForm.programme_id],
    queryFn: async () => {
      const { data, error } = await supabase
        .from("chapitres")
        .select("id, titre, ordre")
        .eq("programme_id", examForm.programme_id)
        .order("ordre");
      if (error) throw new Error(error.message);
      return data ?? [];
    },
  });

  // 4. Fetch Questions for active Questions Dialog
  const { data: questions = [], refetch: refetchQuestions } = useQuery({
    enabled: !!questionsDialog,
    queryKey: ["questions-for-exam", questionsDialog?.id],
    queryFn: async (): Promise<QuestionRow[]> => {
      const { data, error } = await supabase
        .from("questions")
        .select("*")
        .eq("examen_id", questionsDialog!.id)
        .order("ordre");
      if (error) throw new Error(error.message);
      return (data ?? []).map((q) => ({
        ...q,
        options: Array.isArray(q.options) ? (q.options as string[]) : [],
      }));
    },
  });

  // Handlers for Exam Modal
  const openCreateDialog = () => {
    setEditingExam(null);
    setExamForm({
      titre: "",
      description: "",
      duree_minutes: 15,
      statut: "publie",
      deverrouille_si: "toujours",
      classe_id: teacherClasses[0]?.id ?? "",
      programme_id: "",
      chapitre_id: "",
    });
    setExamDialog(true);
  };

  const openEditDialog = (exam: ExamenRow) => {
    setEditingExam(exam);
    setExamForm({
      titre: exam.titre,
      description: exam.description ?? "",
      duree_minutes: exam.duree_minutes,
      statut: exam.statut,
      deverrouille_si: exam.deverrouille_si || "toujours",
      classe_id: exam.classe_id ?? "",
      programme_id: exam.programme_id ?? "",
      chapitre_id: exam.chapitre_id ?? "",
    });
    setExamDialog(true);
  };

  const handleSaveExam = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!examForm.titre.trim()) {
      toast.error("Veuillez saisir un titre pour le quiz.");
      return;
    }

    try {
      const payload = {
        titre: examForm.titre.trim(),
        description: examForm.description.trim() || null,
        duree_minutes: Number(examForm.duree_minutes) || 15,
        statut: examForm.statut,
        deverrouille_si: examForm.deverrouille_si,
        classe_id: examForm.classe_id || null,
        programme_id: examForm.programme_id || null,
        chapitre_id: examForm.chapitre_id || null,
        etablissement_id: schoolId,
        created_by: profile?.id,
      };

      if (editingExam) {
        const { error } = await supabase
          .from("examens")
          .update(payload)
          .eq("id", editingExam.id);
        if (error) throw error;
        toast.success("Quiz mis à jour avec succès.");
      } else {
        const { error } = await supabase.from("examens").insert({
          ...payload,
          mode_evaluation: "qcm",
          nb_questions: 0,
        });
        if (error) throw error;
        toast.success("Nouveau quiz créé.");
      }

      setExamDialog(false);
      queryClient.invalidateQueries({ queryKey: ["teacher-examens"] });
    } catch (err: unknown) {
      const errorMsg = err instanceof Error ? err.message : "Erreur inconnue";
      toast.error(`Erreur : ${errorMsg}`);
    }
  };

  const handleDeleteExam = async (id: string) => {
    if (!confirm("Voulez-vous vraiment supprimer ce quiz et ses questions ?")) return;
    try {
      const { error } = await supabase.from("examens").delete().eq("id", id);
      if (error) throw error;
      toast.success("Quiz supprimé.");
      queryClient.invalidateQueries({ queryKey: ["teacher-examens"] });
    } catch (err: unknown) {
      const errorMsg = err instanceof Error ? err.message : "Erreur inconnue";
      toast.error(`Impossible de supprimer : ${errorMsg}`);
    }
  };

  // Handlers for Question Modal
  const handleAddQuestion = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!questionsDialog) return;
    if (!questionForm.enonce.trim()) {
      toast.error("Veuillez saisir l'énoncé de la question.");
      return;
    }
    const cleanOptions = questionForm.options.map((o) => o.trim()).filter(Boolean);
    if (cleanOptions.length < 2) {
      toast.error("Veuillez fournir au moins 2 options de réponse.");
      return;
    }

    setSavingQuestion(true);
    try {
      const nextOrdre = questions.length + 1;
      const selectedOptionText = questionForm.options[parseInt(questionForm.reponse_correcte, 10)] || cleanOptions[0];

      const { error } = await supabase.from("questions").insert({
        examen_id: questionsDialog.id,
        enonce: questionForm.enonce.trim(),
        options: cleanOptions,
        reponse_correcte: selectedOptionText,
        points: questionForm.points,
        ordre: nextOrdre,
        type: "qcm",
      });

      if (error) throw error;

      // Update question counter on examen
      await supabase
        .from("examens")
        .update({ nb_questions: questions.length + 1 })
        .eq("id", questionsDialog.id);

      toast.success("Question ajoutée.");
      setQuestionForm({
        enonce: "",
        options: ["", "", "", ""],
        reponse_correcte: "0",
        points: 1,
      });
      refetchQuestions();
      queryClient.invalidateQueries({ queryKey: ["teacher-examens"] });
    } catch (err: unknown) {
      const errorMsg = err instanceof Error ? err.message : "Erreur inconnue";
      toast.error(`Erreur : ${errorMsg}`);
    } finally {
      setSavingQuestion(false);
    }
  };

  const handleDeleteQuestion = async (questionId: string) => {
    if (!questionsDialog) return;
    try {
      const { error } = await supabase.from("questions").delete().eq("id", questionId);
      if (error) throw error;

      const newCount = Math.max(0, questions.length - 1);
      await supabase
        .from("examens")
        .update({ nb_questions: newCount })
        .eq("id", questionsDialog.id);

      toast.success("Question supprimée.");
      refetchQuestions();
      queryClient.invalidateQueries({ queryKey: ["teacher-examens"] });
    } catch (err: unknown) {
      const errorMsg = err instanceof Error ? err.message : "Erreur inconnue";
      toast.error(`Erreur : ${errorMsg}`);
    }
  };

  return (
    <div className="container mx-auto p-4 md:p-6 space-y-6 max-w-6xl">
      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4 border-b pb-4">
        <div>
          <h1 className="text-2xl md:text-3xl font-bold tracking-tight text-foreground flex items-center gap-2">
            <FileQuestion className="h-7 w-7 text-primary" />
            Gestion des Quiz & Examens
          </h1>
          <p className="text-muted-foreground text-sm mt-1">
            Créez des quiz par chapitre, associez des conditions de déverrouillage et gérez vos questions.
          </p>
        </div>
        <Button onClick={openCreateDialog} className="gap-2 self-start sm:self-auto">
          <Plus className="h-4 w-4" />
          Nouveau Quiz
        </Button>
      </div>

      {/* List of Exams */}
      {isLoading ? (
        <div className="py-12 text-center text-muted-foreground">Chargement de vos quiz...</div>
      ) : examens.length === 0 ? (
        <Card className="border-dashed p-8 text-center space-y-4">
          <div className="mx-auto w-12 h-12 rounded-full bg-primary/10 flex items-center justify-center text-primary">
            <Sparkles className="h-6 w-6" />
          </div>
          <div>
            <h3 className="font-semibold text-lg">Aucun quiz créé pour le moment</h3>
            <p className="text-muted-foreground text-sm">
              Commencez par créer votre premier quiz et associez-le à un chapitre pour évaluer vos élèves.
            </p>
          </div>
          <Button onClick={openCreateDialog} variant="outline" className="gap-2">
            <Plus className="h-4 w-4" />
            Créer un Quiz
          </Button>
        </Card>
      ) : (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
          {examens.map((exam) => (
            <Card key={exam.id} className="flex flex-col justify-between hover:shadow-md transition-shadow">
              <CardHeader className="pb-3">
                <div className="flex items-start justify-between gap-2">
                  <Badge variant={exam.statut === "publie" ? "default" : "secondary"}>
                    {exam.statut === "publie" ? "Publié" : "Brouillon"}
                  </Badge>

                  {/* Lock condition badge */}
                  {exam.deverrouille_si === "tous_concepts_termines" ? (
                    <Badge variant="outline" className="border-amber-500/50 text-amber-600 bg-amber-50 text-xs flex items-center gap-1">
                      <Lock className="h-3 w-3" /> Verrouillé (cours requis)
                    </Badge>
                  ) : (
                    <Badge variant="outline" className="border-emerald-500/50 text-emerald-600 bg-emerald-50 text-xs flex items-center gap-1">
                      <Unlock className="h-3 w-3" /> Toujours ouvert
                    </Badge>
                  )}
                </div>
                <CardTitle className="text-lg font-semibold mt-2 line-clamp-1">
                  {exam.titre}
                </CardTitle>
                {exam.description && (
                  <CardDescription className="line-clamp-2 text-xs">
                    {exam.description}
                  </CardDescription>
                )}
              </CardHeader>

              <CardContent className="space-y-2 text-xs text-muted-foreground pb-4">
                {exam.chapitres?.titre && (
                  <div className="flex items-center gap-1.5 text-foreground font-medium">
                    <BookOpen className="h-3.5 w-3.5 text-primary shrink-0" />
                    <span className="truncate">Chapitre : {exam.chapitres.titre}</span>
                  </div>
                )}
                {exam.classes?.nom && (
                  <div className="flex items-center gap-1.5">
                    <span className="font-medium">Classe :</span> {exam.classes.nom}
                  </div>
                )}
                <div className="flex items-center gap-4 pt-1">
                  <div className="flex items-center gap-1">
                    <Clock className="h-3.5 w-3.5" />
                    <span>{exam.duree_minutes} min</span>
                  </div>
                  <div className="flex items-center gap-1">
                    <HelpCircle className="h-3.5 w-3.5" />
                    <span>{exam.nb_questions} question{exam.nb_questions > 1 ? "s" : ""}</span>
                  </div>
                </div>
              </CardContent>

              <CardFooter className="pt-2 border-t flex items-center justify-between gap-2">
                <Button
                  size="sm"
                  variant="outline"
                  className="w-full text-xs gap-1"
                  onClick={() => setQuestionsDialog(exam)}
                >
                  <FileQuestion className="h-3.5 w-3.5 text-primary" />
                  Questions ({exam.nb_questions})
                </Button>
                <Button
                  size="icon"
                  variant="ghost"
                  className="h-8 w-8 shrink-0"
                  onClick={() => openEditDialog(exam)}
                >
                  <Pencil className="h-3.5 w-3.5" />
                </Button>
                <Button
                  size="icon"
                  variant="ghost"
                  className="h-8 w-8 text-destructive shrink-0 hover:text-destructive hover:bg-destructive/10"
                  onClick={() => handleDeleteExam(exam.id)}
                >
                  <Trash2 className="h-3.5 w-3.5" />
                </Button>
              </CardFooter>
            </Card>
          ))}
        </div>
      )}

      {/* DIALOG 1: Create / Edit Exam Metadata */}
      <Dialog open={examDialog} onOpenChange={setExamDialog}>
        <DialogContent className="sm:max-w-[540px]">
          <form onSubmit={handleSaveExam}>
            <DialogHeader>
              <DialogTitle>
                {editingExam ? "Modifier le Quiz" : "Créer un Nouveau Quiz"}
              </DialogTitle>
              <DialogDescription>
                Renseignez le titre, la durée et les conditions d'accès de votre évaluation.
              </DialogDescription>
            </DialogHeader>

            <div className="grid gap-4 py-4">
              <div className="space-y-1.5">
                <Label htmlFor="titre">Titre du Quiz *</Label>
                <Input
                  id="titre"
                  placeholder="ex: Quiz sur les Équations du 2nd degré"
                  value={examForm.titre}
                  onChange={(e) => setExamForm({ ...examForm, titre: e.target.value })}
                  required
                />
              </div>

              <div className="space-y-1.5">
                <Label htmlFor="description">Description (Optionnel)</Label>
                <Textarea
                  id="description"
                  placeholder="Informations ou conseils pour les élèves..."
                  rows={2}
                  value={examForm.description}
                  onChange={(e) => setExamForm({ ...examForm, description: e.target.value })}
                />
              </div>

              <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                <div className="space-y-1.5">
                  <Label>Classe</Label>
                  <Select
                    value={examForm.classe_id}
                    onValueChange={(val) =>
                      setExamForm({ ...examForm, classe_id: val, programme_id: "", chapitre_id: "" })
                    }
                  >
                    <SelectTrigger>
                      <SelectValue placeholder="Sélectionner une classe" />
                    </SelectTrigger>
                    <SelectContent>
                      {teacherClasses.map((c) => (
                        <SelectItem key={c.id} value={c.id}>
                          {c.nom}
                        </SelectItem>
                      ))}
                    </SelectContent>
                  </Select>
                </div>

                <div className="space-y-1.5">
                  <Label>Programme</Label>
                  <Select
                    disabled={!examForm.classe_id || programmes.length === 0}
                    value={examForm.programme_id}
                    onValueChange={(val) =>
                      setExamForm({ ...examForm, programme_id: val, chapitre_id: "" })
                    }
                  >
                    <SelectTrigger>
                      <SelectValue placeholder={!examForm.classe_id ? "Choisir classe d'abord" : "Sélectionner programme"} />
                    </SelectTrigger>
                    <SelectContent>
                      {programmes.map((p) => (
                        <SelectItem key={p.id} value={p.id}>
                          {p.titre}
                        </SelectItem>
                      ))}
                    </SelectContent>
                  </Select>
                </div>
              </div>

              <div className="space-y-1.5">
                <Label>Chapitre lié (pour le verrouillage par leçons)</Label>
                <Select
                  disabled={!examForm.programme_id || chapitres.length === 0}
                  value={examForm.chapitre_id}
                  onValueChange={(val) => setExamForm({ ...examForm, chapitre_id: val })}
                >
                  <SelectTrigger>
                    <SelectValue placeholder={!examForm.programme_id ? "Choisir programme d'abord" : "Sélectionner un chapitre"} />
                  </SelectTrigger>
                  <SelectContent>
                    {chapitres.map((ch) => (
                      <SelectItem key={ch.id} value={ch.id}>
                        {ch.ordre}. {ch.titre}
                      </SelectItem>
                    ))}
                  </SelectContent>
                </Select>
              </div>

              {/* Unlock Condition Switch */}
              <div className="rounded-lg border p-3 space-y-2 bg-muted/30">
                <div className="flex items-center justify-between">
                  <div className="space-y-0.5">
                    <Label className="text-sm font-semibold flex items-center gap-1.5">
                      <Lock className="h-4 w-4 text-amber-600" />
                      Condition de Déverrouillage ÉLÈVE
                    </Label>
                    <p className="text-xs text-muted-foreground">
                      {examForm.deverrouille_si === "tous_concepts_termines"
                        ? "L'élève doit avoir terminé TOUS les concepts/leçons du chapitre pour passer ce quiz."
                        : "Le quiz est immédiatement ouvert à tous les élèves."}
                    </p>
                  </div>
                  <Switch
                    checked={examForm.deverrouille_si === "tous_concepts_termines"}
                    onCheckedChange={(checked) =>
                      setExamForm({
                        ...examForm,
                        deverrouille_si: checked ? "tous_concepts_termines" : "toujours",
                      })
                    }
                  />
                </div>
              </div>

              <div className="grid grid-cols-2 gap-4">
                <div className="space-y-1.5">
                  <Label htmlFor="duree">Durée (minutes)</Label>
                  <Input
                    id="duree"
                    type="number"
                    min={1}
                    value={examForm.duree_minutes}
                    onChange={(e) =>
                      setExamForm({ ...examForm, duree_minutes: parseInt(e.target.value, 10) || 15 })
                    }
                  />
                </div>

                <div className="space-y-1.5">
                  <Label>Statut</Label>
                  <Select
                    value={examForm.statut}
                    onValueChange={(val) => setExamForm({ ...examForm, statut: val })}
                  >
                    <SelectTrigger>
                      <SelectValue />
                    </SelectTrigger>
                    <SelectContent>
                      <SelectItem value="publie">Publié</SelectItem>
                      <SelectItem value="brouillon">Brouillon</SelectItem>
                    </SelectContent>
                  </Select>
                </div>
              </div>
            </div>

            <DialogFooter>
              <Button type="button" variant="outline" onClick={() => setExamDialog(false)}>
                Annuler
              </Button>
              <Button type="submit">
                {editingExam ? "Enregistrer les modifications" : "Créer le Quiz"}
              </Button>
            </DialogFooter>
          </form>
        </DialogContent>
      </Dialog>

      {/* DIALOG 2: Manage Questions */}
      <Dialog open={!!questionsDialog} onOpenChange={(open) => !open && setQuestionsDialog(null)}>
        <DialogContent className="sm:max-w-[700px] max-h-[85vh] flex flex-col">
          <DialogHeader>
            <DialogTitle className="flex items-center gap-2">
              <FileQuestion className="h-5 w-5 text-primary" />
              Questions : {questionsDialog?.titre}
            </DialogTitle>
            <DialogDescription>
              Ajoutez des questions QCM et choisissez la bonne réponse.
            </DialogDescription>
          </DialogHeader>

          <div className="flex-1 overflow-y-auto space-y-6 pr-1 py-2">
            {/* List of existing questions */}
            <div className="space-y-3">
              <h4 className="text-xs font-semibold uppercase tracking-wider text-muted-foreground">
                Questions actuelles ({questions.length})
              </h4>
              {questions.length === 0 ? (
                <p className="text-xs text-muted-foreground italic bg-muted/40 p-3 rounded text-center">
                  Aucune question enregistrée. Utilisez le formulaire ci-dessous pour en ajouter une.
                </p>
              ) : (
                <div className="space-y-2">
                  {questions.map((q, idx) => (
                    <div key={q.id} className="border rounded-md p-3 bg-card space-y-2 text-xs">
                      <div className="flex items-start justify-between gap-2">
                        <span className="font-semibold text-sm text-foreground">
                          Q{idx + 1}. {q.enonce}
                        </span>
                        <div className="flex items-center gap-2">
                          <Badge variant="outline" className="text-[10px]">
                            {q.points} pt{q.points > 1 ? "s" : ""}
                          </Badge>
                          <Button
                            size="icon"
                            variant="ghost"
                            className="h-6 w-6 text-destructive hover:bg-destructive/10"
                            onClick={() => handleDeleteQuestion(q.id)}
                          >
                            <Trash2 className="h-3.5 w-3.5" />
                          </Button>
                        </div>
                      </div>

                      <div className="grid grid-cols-2 gap-1.5 pl-2 border-l-2 border-primary/30">
                        {q.options.map((opt, oIdx) => (
                          <div
                            key={oIdx}
                            className={`flex items-center gap-1.5 p-1 rounded ${
                              opt === q.reponse_correcte
                                ? "bg-emerald-50 text-emerald-700 font-medium border border-emerald-300"
                                : "text-muted-foreground"
                            }`}
                          >
                            {opt === q.reponse_correcte && <CheckCircle2 className="h-3 w-3 shrink-0" />}
                            <span>{String.fromCharCode(65 + oIdx)}. {opt}</span>
                          </div>
                        ))}
                      </div>
                    </div>
                  ))}
                </div>
              )}
            </div>

            {/* Add Question Form */}
            <form onSubmit={handleAddQuestion} className="border-t pt-4 space-y-3">
              <h4 className="text-xs font-semibold uppercase tracking-wider text-primary flex items-center gap-1.5">
                <Plus className="h-4 w-4" /> Ajouter une nouvelle question (QCM)
              </h4>

              <div className="space-y-1">
                <Label htmlFor="enonce" className="text-xs">Énoncé de la question *</Label>
                <Input
                  id="enonce"
                  placeholder="ex: Quelle est la solution de l'équation x² - 4 = 0 ?"
                  value={questionForm.enonce}
                  onChange={(e) => setQuestionForm({ ...questionForm, enonce: e.target.value })}
                  required
                />
              </div>

              <div className="space-y-2">
                <Label className="text-xs">Options de réponses (Sélectionnez la bonne réponse) *</Label>
                <RadioGroup
                  value={questionForm.reponse_correcte}
                  onValueChange={(val) => setQuestionForm({ ...questionForm, reponse_correcte: val })}
                  className="space-y-2"
                >
                  {questionForm.options.map((opt, i) => (
                    <div key={i} className="flex items-center gap-2">
                      <RadioGroupItem value={i.toString()} id={`opt-${i}`} />
                      <Label htmlFor={`opt-${i}`} className="font-mono text-xs w-5 text-muted-foreground">
                        {String.fromCharCode(65 + i)}
                      </Label>
                      <Input
                        placeholder={`Option ${String.fromCharCode(65 + i)}`}
                        value={opt}
                        onChange={(e) => {
                          const updated = [...questionForm.options];
                          updated[i] = e.target.value;
                          setQuestionForm({ ...questionForm, options: updated });
                        }}
                        className="text-xs h-8"
                      />
                    </div>
                  ))}
                </RadioGroup>
              </div>

              <div className="flex items-center justify-between pt-2">
                <div className="flex items-center gap-2">
                  <Label htmlFor="points" className="text-xs">Points :</Label>
                  <Input
                    id="points"
                    type="number"
                    min={1}
                    value={questionForm.points}
                    onChange={(e) =>
                      setQuestionForm({ ...questionForm, points: parseInt(e.target.value, 10) || 1 })
                    }
                    className="w-16 h-8 text-xs"
                  />
                </div>
                <Button type="submit" size="sm" disabled={savingQuestion}>
                  {savingQuestion ? "Ajout..." : "Ajouter la Question"}
                </Button>
              </div>
            </form>
          </div>

          <DialogFooter className="pt-2 border-t">
            <Button variant="outline" onClick={() => setQuestionsDialog(null)}>
              Fermer
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </div>
  );
}
