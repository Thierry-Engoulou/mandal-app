import { useState } from "react";
import { CheckCircle2, FileUp, LoaderCircle, Send, Trash2, TriangleAlert } from "lucide-react";
import { toast } from "sonner";
import { deposerEpreuve, devinerDepuisNom, metaIncomplete, type MetaEpreuve } from "@/lib/banque";
import { ChampsEpreuve } from "@/components/banque/depot-form";
import { PickFileButton } from "@/components/pick-file-button";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { cn } from "@/lib/utils";

type Ligne = {
  id: string;
  fichier: File;
  meta: MetaEpreuve;
  etat: "pret" | "envoi" | "ok" | "erreur";
  erreur?: string | undefined;
};

/** Import de nombreuses épreuves d'un coup : une épreuve par fichier, informations
 *  devinées d'après le nom du fichier puis corrigeables ligne par ligne. */
export function ImportMasse({ userId, onTermine }: { userId: string; onTermine?: () => void }) {
  const [lignes, setLignes] = useState<Ligne[]>([]);
  const [commun, setCommun] = useState<Pick<MetaEpreuve, "source" | "session">>({
    source: "",
    session: "",
  });
  const [enCours, setEnCours] = useState(false);

  const ajouter = (files: FileList | null) => {
    if (!files?.length) return;
    setLignes((l) => [
      ...l,
      ...Array.from(files).map((fichier) => ({
        id: crypto.randomUUID(),
        fichier,
        meta: devinerDepuisNom(fichier.name),
        etat: "pret" as const,
      })),
    ]);
  };

  const maj = (id: string, patch: Partial<Ligne>) =>
    setLignes((l) => l.map((x) => (x.id === id ? { ...x, ...patch } : x)));

  const aEnvoyer = lignes.filter((l) => l.etat === "pret" || l.etat === "erreur");
  const incompletes = aEnvoyer.filter((l) => metaIncomplete(l.meta)).length;

  const toutPublier = async () => {
    setEnCours(true);
    let ok = 0;
    for (const ligne of aEnvoyer) {
      const meta = {
        ...ligne.meta,
        source: ligne.meta.source || commun.source,
        session: ligne.meta.session || commun.session,
      };
      const probleme = metaIncomplete(meta);
      if (probleme) {
        maj(ligne.id, { etat: "erreur", erreur: probleme });
        continue;
      }
      maj(ligne.id, { etat: "envoi", erreur: undefined });
      try {
        await deposerEpreuve({ userId, sujet: [ligne.fichier], meta, publier: true });
        maj(ligne.id, { etat: "ok" });
        ok++;
      } catch (e) {
        maj(ligne.id, { etat: "erreur", erreur: e instanceof Error ? e.message : "Échec" });
      }
    }
    setEnCours(false);
    if (ok) {
      toast.success(`${ok} épreuve${ok > 1 ? "s" : ""} publiée${ok > 1 ? "s" : ""}.`);
      onTermine?.();
    }
  };

  return (
    <div className="space-y-4">
      <div className="space-y-3 rounded-2xl bg-card p-5 text-sm shadow-sm">
        <p className="font-semibold text-foreground">Comment ça marche</p>
        <ol className="list-decimal space-y-1 pl-5 text-muted-foreground">
          <li>Choisis tous tes fichiers d'un coup (PDF ou photos) : une épreuve par fichier.</li>
          <li>
            Les informations sont devinées d'après le nom du fichier, par exemple{" "}
            <code className="rounded bg-secondary px-1">BAC_D_2023_Maths.pdf</code> ou{" "}
            <code className="rounded bg-secondary px-1">GCE_OL_2021_Chemistry.pdf</code>.
          </li>
          <li>Vérifie et complète chaque ligne, puis clique sur « Tout publier ».</li>
        </ol>
        <p className="text-xs text-muted-foreground">
          Pour une épreuve en plusieurs photos, utilise plutôt l'onglet « Ajouter une épreuve ».
        </p>
        <div className="flex flex-wrap items-center gap-2">
          <PickFileButton
            icon={<FileUp className="size-4" />}
            label="Choisir les fichiers"
            accept="application/pdf,image/jpeg,image/png,image/webp"
            multiple
            onFiles={ajouter}
            disabled={enCours}
          />
          {lignes.length ? (
            <Button
              variant="ghost"
              size="sm"
              className="rounded-xl"
              disabled={enCours}
              onClick={() => setLignes((l) => l.filter((x) => x.etat !== "ok"))}
            >
              Retirer les lignes publiées
            </Button>
          ) : null}
        </div>
      </div>

      {lignes.length ? (
        <>
          <div className="grid gap-3 rounded-2xl bg-card p-4 shadow-sm sm:grid-cols-2">
            <div className="space-y-1">
              <p className="text-xs font-semibold text-muted-foreground">
                Source pour toutes les lignes (si vide)
              </p>
              <Input
                value={commun.source}
                onChange={(e) => setCommun({ ...commun, source: e.target.value })}
                placeholder="Ex. : Lycée Leclerc de Yaoundé"
              />
            </div>
            <div className="space-y-1">
              <p className="text-xs font-semibold text-muted-foreground">
                Session pour toutes les lignes (si vide)
              </p>
              <Input
                value={commun.session}
                onChange={(e) => setCommun({ ...commun, session: e.target.value })}
                placeholder="Ex. : Juin"
              />
            </div>
          </div>

          <div className="space-y-3">
            {lignes.map((l) => {
              const probleme = metaIncomplete(l.meta);
              return (
                <div
                  key={l.id}
                  className={cn(
                    "space-y-3 rounded-2xl bg-card p-4 shadow-sm",
                    l.etat === "ok" && "opacity-60",
                    l.etat === "erreur" && "ring-1 ring-destructive",
                  )}
                >
                  <div className="flex items-center gap-2 text-sm">
                    {l.etat === "ok" ? (
                      <CheckCircle2 className="size-4 text-success" />
                    ) : l.etat === "envoi" ? (
                      <LoaderCircle className="size-4 animate-spin" />
                    ) : probleme || l.etat === "erreur" ? (
                      <TriangleAlert className="size-4 text-warning" />
                    ) : null}
                    <span className="min-w-0 flex-1 truncate font-medium">{l.fichier.name}</span>
                    <span className="text-xs text-muted-foreground">
                      {(l.fichier.size / 1024 / 1024).toFixed(1)} Mo
                    </span>
                    <button
                      type="button"
                      disabled={enCours || l.etat === "envoi"}
                      onClick={() => setLignes((x) => x.filter((y) => y.id !== l.id))}
                      aria-label="Retirer"
                    >
                      <Trash2 className="size-4 text-muted-foreground" />
                    </button>
                  </div>
                  {l.etat !== "ok" ? (
                    <>
                      <Input
                        value={l.meta.titre}
                        onChange={(e) => maj(l.id, { meta: { ...l.meta, titre: e.target.value } })}
                        placeholder="Titre"
                      />
                      <ChampsEpreuve
                        compact
                        meta={l.meta}
                        onChange={(meta) => maj(l.id, { meta, etat: "pret", erreur: undefined })}
                      />
                    </>
                  ) : null}
                  {l.erreur || (probleme && l.etat !== "ok") ? (
                    <p className="text-xs text-destructive">{l.erreur ?? probleme}</p>
                  ) : null}
                </div>
              );
            })}
          </div>

          <div className="sticky bottom-4 flex flex-wrap items-center gap-3 rounded-2xl bg-card p-4 shadow-lg">
            <Button
              className="rounded-xl"
              disabled={enCours || aEnvoyer.length === 0}
              onClick={() => void toutPublier()}
            >
              {enCours ? (
                <LoaderCircle className="size-4 animate-spin" />
              ) : (
                <Send className="size-4" />
              )}
              Tout publier ({aEnvoyer.length - incompletes})
            </Button>
            {incompletes ? (
              <span className="text-xs text-muted-foreground">
                {incompletes} ligne{incompletes > 1 ? "s" : ""} incomplète
                {incompletes > 1 ? "s" : ""} (ignorée
                {incompletes > 1 ? "s" : ""})
              </span>
            ) : null}
          </div>
        </>
      ) : null}
    </div>
  );
}
