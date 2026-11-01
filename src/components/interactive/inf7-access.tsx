import { useState } from "react";
import { Choice, PALETTE, Panel, Stat, Verdict } from "./controls";

/** Informatique Terminale C et D — chapitre 18 : MS Access. */

/* ------------------------------------------------------------------ */
/* Chapitre 18 — L'interface d'Access                                 */
/* ------------------------------------------------------------------ */

const PARTIES = [
  {
    id: "ruban",
    label: "Le ruban",
    role: "La bande d'onglets en haut — Fichier, Accueil, Créer, Données externes, Outils de base de données. C'est là que se trouvent toutes les commandes.",
  },
  {
    id: "volet",
    label: "Le volet de navigation",
    role: "La colonne de gauche. Elle liste TOUS les objets de la base, rangés par famille. C'est le sommaire de la base de données.",
  },
  {
    id: "zone",
    label: "La zone de travail",
    role: "Le grand espace central, à onglets. C'est là que s'ouvrent les tables, les requêtes, les formulaires et les états.",
  },
  {
    id: "affichage",
    label: "Le bouton Affichage",
    role: "En haut à gauche de l'onglet Accueil. Il bascule entre le mode Création, qui règle la STRUCTURE, et le mode Feuille de données, qui règle le CONTENU.",
  },
  {
    id: "proprietes",
    label: "Le volet des propriétés",
    role: "En bas de la fenêtre, en mode Création. Il affiche les propriétés du champ sélectionné : taille, format, valeur par défaut, règle de validation, indexé.",
  },
] as const;

const OBJETS = [
  {
    id: "tables",
    label: "Tables",
    role: "Elles contiennent les données. Ce sont les seuls objets indispensables : tous les autres en dépendent.",
    exemple: "ELEVE, CLASSE, MATIERE, NOTE",
  },
  {
    id: "requetes",
    label: "Requêtes",
    role: "Elles interrogent, filtrent et calculent. Access les écrit en SQL, même quand on les construit à la souris.",
    exemple: "« Les élèves de Terminale C ayant la moyenne »",
  },
  {
    id: "formulaires",
    label: "Formulaires",
    role: "Ils servent à SAISIR confortablement, un enregistrement à la fois, avec des contrôles et des listes de choix.",
    exemple: "Une fiche d'inscription d'élève",
  },
  {
    id: "etats",
    label: "États",
    role: "Ils servent à IMPRIMER : mise en page, regroupements, totaux, numérotation des pages.",
    exemple: "Les bulletins trimestriels",
  },
  {
    id: "macros",
    label: "Macros",
    role: "Elles automatisent des suites d'actions sans écrire de programme : ouvrir un formulaire, lancer une requête, imprimer un état.",
    exemple: "« À l'ouverture de la base, afficher le menu »",
  },
] as const;

export function InterfaceAccess() {
  const [partie, setPartie] = useState<string | null>(null);
  const [objet, setObjet] = useState<string>("tables");
  const [mode, setMode] = useState<"creation" | "donnees">("donnees");

  const pa = PARTIES.find((x) => x.id === partie);
  const ob = OBJETS.find((x) => x.id === objet) ?? OBJETS[0];

  return (
    <div className="space-y-3">
      {/* La fenêtre d'Access */}
      <div className="overflow-hidden rounded-lg border-2 border-slate-400">
        <button
          type="button"
          onClick={() => setPartie("ruban")}
          className={`block w-full border-b border-slate-300 px-2 py-1.5 text-left ${
            partie === "ruban" ? "bg-primary/20" : "bg-secondary/60"
          }`}
        >
          <p className="text-[10px] font-semibold">
            Fichier · Accueil · Créer · Données externes · Outils de base de données
          </p>
        </button>

        <div className="flex">
          <button
            type="button"
            onClick={() => setPartie("volet")}
            className={`w-28 shrink-0 border-r border-slate-300 p-1.5 text-left ${
              partie === "volet" ? "bg-primary/20" : "bg-secondary/30"
            }`}
          >
            <p className="mb-1 text-[9px] font-semibold uppercase text-muted-foreground">
              Tous les objets
            </p>
            {OBJETS.map((o) => (
              <p
                key={o.id}
                className={
                  o.id === objet
                    ? "text-[10px] font-semibold text-primary"
                    : "text-[10px] text-muted-foreground"
                }
              >
                {o.label}
              </p>
            ))}
          </button>

          <button
            type="button"
            onClick={() => setPartie("zone")}
            className={`min-h-[110px] flex-1 p-2 text-left ${
              partie === "zone" ? "bg-primary/20" : "bg-background"
            }`}
          >
            <p className="mb-1 text-[10px] font-semibold">
              {ob.label} — {mode === "creation" ? "mode Création" : "mode Feuille de données"}
            </p>
            {mode === "donnees" ? (
              <table className="border-collapse text-[10px]">
                <thead>
                  <tr>
                    <th className="border border-slate-300 bg-secondary/50 px-1.5">Matricule</th>
                    <th className="border border-slate-300 bg-secondary/50 px-1.5">Nom</th>
                    <th className="border border-slate-300 bg-secondary/50 px-1.5">Moyenne</th>
                  </tr>
                </thead>
                <tbody>
                  <tr>
                    <td className="border border-slate-300 px-1.5 font-mono">E101</td>
                    <td className="border border-slate-300 px-1.5">MBIDA</td>
                    <td className="border border-slate-300 px-1.5 font-mono">13,5</td>
                  </tr>
                </tbody>
              </table>
            ) : (
              <table className="border-collapse text-[10px]">
                <thead>
                  <tr>
                    <th className="border border-slate-300 bg-secondary/50 px-1.5">Nom du champ</th>
                    <th className="border border-slate-300 bg-secondary/50 px-1.5">
                      Type de données
                    </th>
                  </tr>
                </thead>
                <tbody>
                  <tr>
                    <td className="border border-slate-300 px-1.5 font-mono">🔑 Matricule</td>
                    <td className="border border-slate-300 px-1.5">Texte court</td>
                  </tr>
                  <tr>
                    <td className="border border-slate-300 px-1.5 font-mono">Moyenne</td>
                    <td className="border border-slate-300 px-1.5">Numérique</td>
                  </tr>
                </tbody>
              </table>
            )}
          </button>
        </div>

        {mode === "creation" ? (
          <button
            type="button"
            onClick={() => setPartie("proprietes")}
            className={`block w-full border-t border-slate-300 px-2 py-1.5 text-left ${
              partie === "proprietes" ? "bg-primary/20" : "bg-secondary/30"
            }`}
          >
            <p className="text-[9px] font-semibold uppercase text-muted-foreground">
              Propriétés du champ
            </p>
            <p className="font-mono text-[9px] text-muted-foreground">
              Taille du champ : 10 · Null interdit : Oui · Indexé : Oui, sans doublon
            </p>
          </button>
        ) : null}
      </div>

      <div className="flex flex-wrap gap-1.5">
        {OBJETS.map((o) => (
          <button
            key={o.id}
            type="button"
            onClick={() => setObjet(o.id)}
            className={
              o.id === objet
                ? "rounded-lg bg-primary px-2.5 py-1.5 text-xs font-semibold text-primary-foreground"
                : "rounded-lg border border-border bg-background px-2.5 py-1.5 text-xs font-medium text-muted-foreground hover:bg-secondary/60"
            }
          >
            {o.label}
          </button>
        ))}
      </div>

      <button
        type="button"
        onClick={() => {
          setMode((v) => (v === "creation" ? "donnees" : "creation"));
          setPartie("affichage");
        }}
        className="rounded-lg bg-primary px-3 py-1.5 text-xs font-semibold text-primary-foreground"
      >
        Affichage — basculer en mode {mode === "creation" ? "Feuille de données" : "Création"}
      </button>

      <div className="rounded-lg border border-border bg-background p-2.5">
        <p className="text-xs font-semibold">{ob.label}</p>
        <p className="mt-0.5 text-[11px] text-muted-foreground">{ob.role}</p>
        <p className="mt-0.5 font-mono text-[10px] text-muted-foreground">
          Par exemple : {ob.exemple}
        </p>
      </div>

      {pa ? (
        <Verdict tone="ok">
          <span className="font-semibold">{pa.label} — </span>
          {pa.role}
        </Verdict>
      ) : (
        <Verdict tone="warn">
          Clique sur chaque partie de la fenêtre pour la nommer : le ruban en haut, le volet de
          navigation à gauche, la zone de travail au centre.
        </Verdict>
      )}

      <div className="rounded-lg border border-border bg-secondary/20 p-2.5 text-[11px] text-muted-foreground">
        La distinction à retenir pour l&apos;examen : le <strong>mode Création</strong> règle la{" "}
        <strong>structure</strong> — quels champs, de quel type, avec quelles propriétés — et le{" "}
        <strong>mode Feuille de données</strong> règle le <strong>contenu</strong>. On ne peut pas
        changer un type de champ en mode Feuille de données, et on ne peut pas saisir un élève en
        mode Création.
      </div>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Chapitre 18 — Créer la table ELEVE en mode Création                 */
/* ------------------------------------------------------------------ */

const TYPES_ACCESS = [
  "Texte court",
  "Texte long",
  "Numérique",
  "Date/Heure",
  "Monétaire",
  "NuméroAuto",
  "Oui/Non",
] as const;

const CHAMPS_ATTENDUS = [
  {
    nom: "Matricule",
    type: "Texte court",
    pk: true,
    description: "Identifiant de l'élève, attribué par l'établissement",
    note: "Texte court et non Numérique : un matricule comme E101 contient une lettre, et on ne fait aucun calcul avec.",
  },
  {
    nom: "Nom",
    type: "Texte court",
    pk: false,
    description: "Nom de famille",
    note: "",
  },
  {
    nom: "DateNaissance",
    type: "Date/Heure",
    pk: false,
    description: "Date de naissance",
    note: "Date/Heure et non Texte court : sans quoi on ne pourra ni trier par âge ni calculer une durée.",
  },
  {
    nom: "Moyenne",
    type: "Numérique",
    pk: false,
    description: "Moyenne générale sur 20",
    note: "Numérique, avec une règle de validation entre 0 et 20.",
  },
] as const;

export function CreerTableAccess() {
  const [champs, setChamps] = useState<{ nom: string; type: string }[]>([]);
  const [nouveau, setNouveau] = useState("");
  const [type, setType] = useState<string>("Texte court");
  const [pk, setPk] = useState<string | null>(null);
  const [validation, setValidation] = useState(false);
  const [mode, setMode] = useState<"creation" | "donnees">("creation");
  const [lignes, setLignes] = useState<{ Matricule: string; Moyenne: number }[]>([]);
  const [mat, setMat] = useState("");
  const [moy, setMoy] = useState(12);
  const [refus, setRefus] = useState<string | null>(null);

  const ajouter = () => {
    if (nouveau.trim() === "") return;
    setChamps((c) => [...c, { nom: nouveau.trim(), type }]);
    setNouveau("");
  };

  const justes = champs.filter((c) => {
    const a = CHAMPS_ATTENDUS.find((x) => x.nom.toLowerCase() === c.nom.toLowerCase());
    return a && a.type === c.type;
  }).length;

  const mauvais = champs.filter((c) => {
    const a = CHAMPS_ATTENDUS.find((x) => x.nom.toLowerCase() === c.nom.toLowerCase());
    return a && a.type !== c.type;
  });

  const structureOk = justes === CHAMPS_ATTENDUS.length && pk === "Matricule";

  const saisir = () => {
    setRefus(null);
    if (mat.trim() === "") {
      setRefus(
        "« L'index, la clé primaire ou la relation ne peut contenir de valeur Null. » La clé primaire est obligatoire : c'est la propriété « Null interdit : Oui » qui s'y oppose.",
      );
      return;
    }
    if (lignes.some((l) => l.Matricule.toUpperCase() === mat.trim().toUpperCase())) {
      setRefus(
        "« Les modifications demandées n'ont pas abouti car elles créeraient des doublons dans l'index, la clé primaire ou la relation. » C'est la propriété « Indexé : Oui, sans doublon » de la clé primaire.",
      );
      return;
    }
    if (validation && (moy < 0 || moy > 20)) {
      setRefus(
        "« Un ou plusieurs enregistrements n'ont pas pu être collés en raison d'une violation de la règle de validation. » C'est la propriété « Valide si » du champ Moyenne qui refuse : >=0 Et <=20.",
      );
      return;
    }
    setLignes((l) => [...l, { Matricule: mat.trim(), Moyenne: moy }]);
    setMat("");
  };

  return (
    <div className="space-y-3">
      <div className="flex flex-wrap gap-1.5">
        <button
          type="button"
          onClick={() => setMode("creation")}
          className={
            mode === "creation"
              ? "rounded-lg bg-primary px-2.5 py-1.5 text-xs font-semibold text-primary-foreground"
              : "rounded-lg border border-border bg-background px-2.5 py-1.5 text-xs font-medium text-muted-foreground"
          }
        >
          Mode Création
        </button>
        <button
          type="button"
          onClick={() => setMode("donnees")}
          className={
            mode === "donnees"
              ? "rounded-lg bg-primary px-2.5 py-1.5 text-xs font-semibold text-primary-foreground"
              : "rounded-lg border border-border bg-background px-2.5 py-1.5 text-xs font-medium text-muted-foreground"
          }
        >
          Mode Feuille de données
        </button>
      </div>

      {mode === "creation" ? (
        <>
          <div className="overflow-x-auto rounded-lg border-2 border-slate-400">
            <table className="w-full border-collapse text-[11px]">
              <thead>
                <tr>
                  <th className="border border-slate-300 bg-secondary/60 px-2 py-1 text-left">
                    Nom du champ
                  </th>
                  <th className="border border-slate-300 bg-secondary/60 px-2 py-1 text-left">
                    Type de données
                  </th>
                  <th className="border border-slate-300 bg-secondary/60 px-2 py-1 text-left">
                    Description
                  </th>
                </tr>
              </thead>
              <tbody>
                {champs.map((c, i) => {
                  const a = CHAMPS_ATTENDUS.find(
                    (x) => x.nom.toLowerCase() === c.nom.toLowerCase(),
                  );
                  const bon = a && a.type === c.type;
                  return (
                    <tr key={`${i}-${c.nom}`}>
                      <td className="border border-slate-300 px-2 py-1 font-mono">
                        <button type="button" onClick={() => setPk(c.nom)} className="mr-1">
                          {pk === c.nom ? "🔑" : "○"}
                        </button>
                        {c.nom}
                      </td>
                      <td
                        className="border border-slate-300 px-2 py-1"
                        style={{ color: a ? (bon ? PALETTE.green : PALETTE.red) : undefined }}
                      >
                        {c.type}
                      </td>
                      <td className="border border-slate-300 px-2 py-1 text-muted-foreground">
                        {a?.description ?? ""}
                      </td>
                    </tr>
                  );
                })}
                {champs.length === 0 ? (
                  <tr>
                    <td
                      colSpan={3}
                      className="border border-slate-300 px-2 py-2 text-center text-muted-foreground"
                    >
                      (aucun champ)
                    </td>
                  </tr>
                ) : null}
              </tbody>
            </table>
          </div>

          <div className="flex flex-wrap gap-2">
            <input
              value={nouveau}
              onChange={(e) => setNouveau(e.target.value)}
              placeholder="nom du champ"
              className="flex-1 rounded-lg border border-border bg-background px-2.5 py-1.5 font-mono text-xs"
            />
            <button
              type="button"
              onClick={ajouter}
              className="rounded-lg bg-primary px-3 py-1.5 text-xs font-semibold text-primary-foreground"
            >
              Ajouter
            </button>
          </div>
          <Choice<string>
            label="Type de données"
            value={type}
            options={TYPES_ACCESS.map((t) => ({ value: t, label: t }))}
            onChange={setType}
          />

          <div className="flex flex-wrap gap-1.5">
            {CHAMPS_ATTENDUS.map((a) => (
              <button
                key={a.nom}
                type="button"
                onClick={() => {
                  setNouveau(a.nom);
                  setType(a.type);
                }}
                className="rounded border border-border bg-background px-1.5 py-0.5 font-mono text-[10px] text-muted-foreground hover:bg-secondary/60"
              >
                {a.nom}
              </button>
            ))}
          </div>

          <div className="rounded-lg border border-border bg-secondary/30 p-2.5">
            <p className="text-[9px] font-semibold uppercase text-muted-foreground">
              Propriétés du champ Moyenne
            </p>
            <button
              type="button"
              onClick={() => setValidation((v) => !v)}
              className={
                validation
                  ? "mt-1 rounded border border-emerald-500/50 bg-emerald-500/10 px-2 py-0.5 font-mono text-[10px] text-emerald-700"
                  : "mt-1 rounded border border-border bg-background px-2 py-0.5 font-mono text-[10px] text-muted-foreground"
              }
            >
              Valide si : {validation ? ">=0 Et <=20" : "(vide)"}
            </button>
            {validation ? (
              <p className="mt-1 font-mono text-[10px] text-muted-foreground">
                Message si erreur : « La moyenne doit être comprise entre 0 et 20. »
              </p>
            ) : null}
          </div>

          <Panel>
            <Stat label="Champs corrects" value={`${justes} / ${CHAMPS_ATTENDUS.length}`} />
            <Stat
              label="Clé primaire"
              value={pk ?? "aucune"}
              color={pk === "Matricule" ? PALETTE.green : PALETTE.red}
            />
          </Panel>

          {mauvais.length > 0 ? (
            <div className="space-y-1 rounded-lg border border-rose-500/40 bg-rose-500/5 p-2.5">
              {mauvais.map((c) => {
                const a = CHAMPS_ATTENDUS.find((x) => x.nom.toLowerCase() === c.nom.toLowerCase());
                return (
                  <p key={c.nom} className="text-[11px] text-rose-700">
                    <span className="font-semibold">
                      {c.nom} devrait être « {a?.type} » —{" "}
                    </span>
                    {a?.note}
                  </p>
                );
              })}
            </div>
          ) : null}

          {structureOk ? (
            <Verdict tone="ok">
              Structure complète : quatre champs des bons types, et la clé primaire sur Matricule.
              {validation
                ? " La règle de validation est posée sur Moyenne. Passe en mode Feuille de données et essaie d'y saisir 25."
                : " Pose maintenant la règle de validation sur Moyenne, puis passe en mode Feuille de données."}
            </Verdict>
          ) : pk === null && champs.length > 0 ? (
            <Verdict tone="warn">
              Aucune clé primaire. Clique le rond devant un nom de champ pour la poser — Access
              t&apos;en réclamera une à l&apos;enregistrement.
            </Verdict>
          ) : (
            <Verdict tone="warn">
              Ajoute les quatre champs, en choisissant bien le type : c&apos;est lui qui décide de
              ce qu&apos;on pourra calculer, trier et vérifier.
            </Verdict>
          )}
        </>
      ) : (
        <>
          <div className="overflow-x-auto rounded-lg border-2 border-slate-400">
            <table className="w-full border-collapse text-[11px]">
              <thead>
                <tr>
                  <th className="w-6 border border-slate-300 bg-secondary/60" />
                  <th className="border border-slate-300 bg-secondary/60 px-2 py-1">Matricule</th>
                  <th className="border border-slate-300 bg-secondary/60 px-2 py-1">Moyenne</th>
                </tr>
              </thead>
              <tbody>
                {lignes.map((l) => (
                  <tr key={l.Matricule}>
                    <td className="border border-slate-300 bg-secondary/30 px-1 text-center text-[9px]">
                      ▸
                    </td>
                    <td className="border border-slate-300 px-2 py-1 font-mono">{l.Matricule}</td>
                    <td className="border border-slate-300 px-2 py-1 text-right font-mono">
                      {l.Moyenne.toLocaleString("fr-FR")}
                    </td>
                  </tr>
                ))}
                <tr>
                  <td className="border border-slate-300 bg-secondary/30 px-1 text-center text-[9px]">
                    ✱
                  </td>
                  <td className="border border-slate-300 px-1 py-0.5">
                    <input
                      value={mat}
                      onChange={(e) => setMat(e.target.value)}
                      placeholder="(nouveau)"
                      className="w-full bg-transparent font-mono text-[11px] outline-none"
                    />
                  </td>
                  <td className="border border-slate-300 px-1 py-0.5">
                    <input
                      type="number"
                      value={moy}
                      onChange={(e) => setMoy(Number(e.target.value))}
                      className="w-full bg-transparent text-right font-mono text-[11px] outline-none"
                    />
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
          <p className="text-[10px] text-muted-foreground">
            L&apos;astérisque ✱ marque la ligne vierge, toujours présente en bas. Le triangle ▸
            marque la ligne courante ; il devient un crayon ✎ dès qu&apos;on modifie.
          </p>

          <button
            type="button"
            onClick={saisir}
            className="rounded-lg bg-primary px-3 py-1.5 text-xs font-semibold text-primary-foreground"
          >
            Valider l&apos;enregistrement
          </button>

          {refus ? (
            <Verdict tone="bad">{refus}</Verdict>
          ) : lignes.length > 0 ? (
            <Verdict tone="ok">
              {lignes.length} enregistrement{lignes.length > 1 ? "s" : ""} saisi
              {lignes.length > 1 ? "s" : ""}. Essaie maintenant de ressaisir un matricule déjà
              présent, puis d&apos;en laisser un vide, puis une moyenne de 25 :{" "}
              {validation
                ? "les trois seront refusées, chacune par une propriété différente."
                : "les deux premières seront refusées. La moyenne de 25 passera, parce que tu n'as pas posé la règle de validation en mode Création."}
            </Verdict>
          ) : (
            <Verdict tone="warn">
              Saisis un matricule et une moyenne, puis valide. La feuille de données règle le{" "}
              <strong>contenu</strong> ; ce que tu as réglé en mode Création décide de ce
              qu&apos;elle accepte.
            </Verdict>
          )}
        </>
      )}
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Chapitre 18 — La feuille de données : tri, filtre, et le SQL dessous */
/* ------------------------------------------------------------------ */

const ELEVES_ACCESS = [
  { Matricule: "E101", Nom: "MBIDA", Classe: "Terminale C", Moyenne: 13.5 },
  { Matricule: "E102", Nom: "NGONO", Classe: "Terminale D", Moyenne: 15.25 },
  { Matricule: "E103", Nom: "FOUDA", Classe: "Terminale C", Moyenne: 9.75 },
  { Matricule: "E104", Nom: "ATEBA", Classe: "Terminale D", Moyenne: 11 },
  { Matricule: "E105", Nom: "BIYA", Classe: "Terminale C", Moyenne: 17 },
];

const REFUS = [
  {
    id: "doublon",
    label: "Saisir un matricule déjà présent",
    msg: "« Les modifications demandées n'ont pas abouti car elles créeraient des doublons dans l'index, la clé primaire ou la relation. »",
    quoi: "La propriété « Indexé : Oui, sans doublon » de la clé primaire.",
  },
  {
    id: "vide",
    label: "Laisser la clé primaire vide",
    msg: "« L'index, la clé primaire ou la relation ne peut contenir de valeur Null. »",
    quoi: "La propriété « Null interdit : Oui », posée automatiquement par Access sur toute clé primaire.",
  },
  {
    id: "type",
    label: "Taper « douze » dans un champ Numérique",
    msg: "« La valeur que vous avez entrée ne correspond pas au type de données ou au format du champ. »",
    quoi: "Le type de données du champ, choisi en mode Création. C'est lui qui filtre, pas la feuille de données.",
  },
  {
    id: "valid",
    label: "Saisir une moyenne de 25",
    msg: "« La moyenne doit être comprise entre 0 et 20. »",
    quoi: "La règle de validation « Valide si : >=0 Et <=20 », avec son message personnalisé. Remarque que le message est celui que TU as écrit : c'est l'intérêt de la propriété « Message si erreur ».",
  },
] as const;

export function FeuilleDonneesAccess() {
  const [tri, setTri] = useState<{ col: string; desc: boolean } | null>(null);
  const [filtre, setFiltre] = useState<string | null>(null);
  const [refus, setRefus] = useState<string | null>(null);

  let vue = [...ELEVES_ACCESS];
  if (filtre === "tc") vue = vue.filter((e) => e.Classe === "Terminale C");
  if (filtre === "moy") vue = vue.filter((e) => e.Moyenne >= 10);
  if (tri) {
    const c = tri.col;
    vue.sort((a, b) => {
      const x = a[c as keyof typeof a];
      const y = b[c as keyof typeof b];
      const r =
        typeof x === "number" && typeof y === "number"
          ? x - y
          : String(x).localeCompare(String(y), "fr");
      return tri.desc ? -r : r;
    });
  }

  const sql = `SELECT Matricule, Nom, Classe, Moyenne\nFROM ELEVE${
    filtre === "tc"
      ? "\nWHERE Classe = 'Terminale C'"
      : filtre === "moy"
        ? "\nWHERE Moyenne >= 10"
        : ""
  }${tri ? `\nORDER BY ${tri.col} ${tri.desc ? "DESC" : "ASC"}` : ""};`;

  const r = REFUS.find((x) => x.id === refus);

  return (
    <div className="space-y-3">
      <div className="overflow-x-auto rounded-lg border-2 border-slate-400">
        <table className="w-full border-collapse text-[11px]">
          <thead>
            <tr>
              <th className="w-6 border border-slate-300 bg-secondary/60" />
              {["Matricule", "Nom", "Classe", "Moyenne"].map((c) => (
                <th
                  key={c}
                  onClick={() =>
                    setTri((t) =>
                      t && t.col === c ? { col: c, desc: !t.desc } : { col: c, desc: false },
                    )
                  }
                  className="cursor-pointer border border-slate-300 bg-secondary/60 px-2 py-1 hover:bg-secondary"
                >
                  {c}
                  {tri?.col === c ? (tri.desc ? " ▼" : " ▲") : " ⇅"}
                </th>
              ))}
            </tr>
          </thead>
          <tbody>
            {vue.map((e) => (
              <tr key={e.Matricule}>
                <td className="border border-slate-300 bg-secondary/30 px-1 text-center text-[9px]">
                  ▸
                </td>
                <td className="border border-slate-300 px-2 py-1 font-mono">{e.Matricule}</td>
                <td className="border border-slate-300 px-2 py-1">{e.Nom}</td>
                <td className="border border-slate-300 px-2 py-1">{e.Classe}</td>
                <td className="border border-slate-300 px-2 py-1 text-right font-mono">
                  {e.Moyenne.toLocaleString("fr-FR")}
                </td>
              </tr>
            ))}
            <tr>
              <td className="border border-slate-300 bg-secondary/30 px-1 text-center text-[9px]">
                ✱
              </td>
              <td className="border border-slate-300 px-2 py-1 text-muted-foreground" colSpan={4}>
                (nouveau)
              </td>
            </tr>
          </tbody>
        </table>
      </div>

      <div className="flex flex-wrap gap-1.5">
        <button
          type="button"
          onClick={() => setFiltre(filtre === "tc" ? null : "tc")}
          className={
            filtre === "tc"
              ? "rounded-lg bg-primary px-2.5 py-1.5 text-xs font-semibold text-primary-foreground"
              : "rounded-lg border border-border bg-background px-2.5 py-1.5 text-xs font-medium text-muted-foreground hover:bg-secondary/60"
          }
        >
          Filtrer : Terminale C
        </button>
        <button
          type="button"
          onClick={() => setFiltre(filtre === "moy" ? null : "moy")}
          className={
            filtre === "moy"
              ? "rounded-lg bg-primary px-2.5 py-1.5 text-xs font-semibold text-primary-foreground"
              : "rounded-lg border border-border bg-background px-2.5 py-1.5 text-xs font-medium text-muted-foreground hover:bg-secondary/60"
          }
        >
          Filtrer : moyenne ≥ 10
        </button>
        <button
          type="button"
          onClick={() => {
            setTri(null);
            setFiltre(null);
          }}
          className="rounded-lg border border-border bg-background px-2.5 py-1.5 text-xs font-medium text-muted-foreground hover:bg-secondary/60"
        >
          Tout effacer
        </button>
      </div>

      <div className="rounded-lg bg-slate-900 p-3">
        <p className="mb-1 text-[10px] uppercase tracking-wide text-slate-500">
          La requête SQL qu&apos;Access vient d&apos;écrire pour toi
        </p>
        <pre className="font-mono text-[11px] text-emerald-400">{sql}</pre>
      </div>

      <Panel>
        <Stat label="Lignes affichées" value={`${vue.length} / ${ELEVES_ACCESS.length}`} />
        <Stat
          label="Tri actif"
          value={tri ? `${tri.col} ${tri.desc ? "DESC" : "ASC"}` : "aucun"}
          color={PALETTE.blue}
        />
      </Panel>

      <Verdict tone="ok">
        Clique les en-têtes pour trier, les boutons pour filtrer : Access traduit chacune de tes
        actions en SQL, et c&apos;est exactement le SQL du chapitre précédent. Trier, c&apos;est{" "}
        <strong>ORDER BY</strong> ; filtrer, c&apos;est <strong>WHERE</strong>. Access ne fait que
        te l&apos;écrire à la souris.
      </Verdict>

      <div className="space-y-1.5 border-t border-border pt-3">
        <p className="text-xs font-medium text-muted-foreground">
          Provoque volontairement les quatre refus
        </p>
        <div className="flex flex-wrap gap-1.5">
          {REFUS.map((x) => (
            <button
              key={x.id}
              type="button"
              onClick={() => setRefus(x.id)}
              className={
                refus === x.id
                  ? "rounded-lg bg-rose-600 px-2.5 py-1.5 text-[11px] font-semibold text-white"
                  : "rounded-lg border border-border bg-background px-2.5 py-1.5 text-[11px] font-medium text-muted-foreground hover:bg-secondary/60"
              }
            >
              {x.label}
            </button>
          ))}
        </div>
        {r ? (
          <div className="space-y-1.5">
            <div className="rounded-lg border-2 border-slate-400 bg-secondary/40 p-2.5">
              <p className="text-[11px] font-semibold">Microsoft Access</p>
              <p className="mt-1 text-[11px]">{r.msg}</p>
              <p className="mt-1.5 text-right text-[10px] text-muted-foreground">[ OK ]</p>
            </div>
            <Verdict tone="bad">
              <span className="font-semibold">Ce qui refuse : </span>
              {r.quoi}
            </Verdict>
          </div>
        ) : (
          <Verdict tone="warn">
            Les quatre refus viennent de quatre propriétés différentes, toutes réglées en{" "}
            <strong>mode Création</strong>. C&apos;est la leçon du chapitre : la feuille de données
            n&apos;accepte que ce que la structure autorise.
          </Verdict>
        )}
      </div>
    </div>
  );
}
