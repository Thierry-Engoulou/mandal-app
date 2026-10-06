import { useState } from "react";
import { createFileRoute } from "@tanstack/react-router";
import { LifeBuoy, Mail, MessageCircle, Phone } from "lucide-react";
import { toast } from "sonner";
import {
  Accordion,
  AccordionContent,
  AccordionItem,
  AccordionTrigger,
} from "@/components/ui/accordion";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Textarea } from "@/components/ui/textarea";

export const Route = createFileRoute("/_authenticated/etudiant/aide")({
  component: StudentHelpPage,
  head: () => ({
    meta: [
      { title: "Aide — MANDAL" },
      { name: "description", content: "Questions fréquentes et contact de l’équipe MANDAL." },
      { name: "robots", content: "noindex" },
    ],
  }),
});

const FAQ = [
  {
    q: "Comment rejoindre ma classe ?",
    a: "Demandez le code d’invitation à votre enseignant, puis saisissez-le depuis votre tableau de bord, section « Liez votre compte à votre école ».",
  },
  {
    q: "Comment gagner des XP ?",
    a: "Terminez des modules, réussissez les quiz et relevez les défis hebdomadaires. Chaque activité rapporte des XP qui font monter votre rang.",
  },
  {
    q: "Puis-je apprendre sans connexion internet ?",
    a: "Installez MANDAL sur votre téléphone depuis le navigateur. Les modules déjà ouverts restent consultables hors connexion.",
  },
  {
    q: "Que se passe-t-il si je quitte un examen ?",
    a: "Les examens sont surveillés : un premier changement d’onglet déclenche un avertissement, le second marque la question « Sans réponse ».",
  },
];

function StudentHelpPage() {
  const [sending, setSending] = useState(false);

  const handleSubmit = (event: React.FormEvent<HTMLFormElement>) => {
    event.preventDefault();
    setSending(true);
    setTimeout(() => {
      setSending(false);
      toast.success("Message envoyé", {
        description: "L’équipe MANDAL vous répond sous 24 heures.",
      });
      event.currentTarget?.reset?.();
    }, 700);
  };

  return (
    <div className="space-y-6">
      <div className="gradient-welcome rounded-2xl p-6 text-primary-foreground shadow-sm">
        <p className="text-sm/6 opacity-90">Support</p>
        <h1 className="font-display text-2xl font-bold tracking-tight">Aide</h1>
        <p className="mt-1 text-sm opacity-90">
          Une question ? Trouvez la réponse ici ou écrivez-nous.
        </p>
      </div>

      <div className="grid gap-4 sm:grid-cols-3">
        {[
          { icon: MessageCircle, label: "Chat", value: "Lun – Sam, 8h – 20h" },
          { icon: Mail, label: "Email", value: "aide@mandal.cm" },
          { icon: Phone, label: "Téléphone", value: "+237 6 90 00 00 00" },
        ].map((item) => (
          <div key={item.label} className="rounded-2xl bg-card p-5 shadow-sm">
            <span className="flex size-10 items-center justify-center rounded-xl bg-success/10 text-success">
              <item.icon className="size-5" />
            </span>
            <p className="mt-3 text-sm text-muted-foreground">{item.label}</p>
            <p className="font-medium text-foreground">{item.value}</p>
          </div>
        ))}
      </div>

      <div className="grid gap-6 lg:grid-cols-2">
        <div className="rounded-2xl bg-card p-6 shadow-sm">
          <h2 className="flex items-center gap-2 font-display text-lg font-semibold text-foreground">
            <LifeBuoy className="size-5 text-primary" />
            Questions fréquentes
          </h2>
          <Accordion type="single" collapsible className="mt-3">
            {FAQ.map((item) => (
              <AccordionItem key={item.q} value={item.q}>
                <AccordionTrigger className="text-left">{item.q}</AccordionTrigger>
                <AccordionContent>{item.a}</AccordionContent>
              </AccordionItem>
            ))}
          </Accordion>
        </div>

        <form onSubmit={handleSubmit} className="rounded-2xl bg-card p-6 shadow-sm">
          <h2 className="font-display text-lg font-semibold text-foreground">Écrire à l’équipe</h2>
          <p className="mt-1 text-sm text-muted-foreground">
            Décrivez votre problème, nous revenons vers vous rapidement.
          </p>
          <div className="mt-4 space-y-4">
            <div className="space-y-2">
              <Label htmlFor="help-subject">Sujet</Label>
              <Input id="help-subject" name="subject" required placeholder="Ex. Accès à ma classe" />
            </div>
            <div className="space-y-2">
              <Label htmlFor="help-message">Message</Label>
              <Textarea id="help-message" name="message" required rows={6} placeholder="Votre message…" />
            </div>
            <Button type="submit" className="w-full" disabled={sending}>
              {sending ? "Envoi…" : "Envoyer"}
            </Button>
          </div>
        </form>
      </div>
    </div>
  );
}
