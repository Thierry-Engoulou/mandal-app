import { useState } from "react";
import { Board, Choice, Ctrl, PALETTE, Panel, Stat, Verdict } from "./controls";
import { RenduHtml } from "./info1-html";

/** Informatique 1ère A, C et D — chapitres 16 et 17 : formulaires et feuilles de style. */

function clamp(v: number, lo: number, hi: number) {
  return Math.max(lo, Math.min(hi, v));
}

/* ------------------------------------------------------------------ */
/* Chapitre 16 — get ou post ?                                         */
/* ------------------------------------------------------------------ */

export function FormulaireHtml() {
  const [methode, setMethode] = useState<"get" | "post">("get");
  const [avecName, setAvecName] = useState(true);
  const [dansForm, setDansForm] = useState(true);
  const [envoye, setEnvoye] = useState(false);

  const champs: ReadonlyArray<{ nom: string; valeur: string; name: boolean; dedans: boolean }> = [
    { nom: "Nom d'utilisateur", valeur: "thierry", name: true, dedans: true },
    { nom: "Mot de passe", valeur: "secret123", name: avecName, dedans: true },
    { nom: "Classe", valeur: "1ereC", name: true, dedans: dansForm },
  ];

  const transmis = champs.filter((c) => c.name && c.dedans);
  const url =
    methode === "get"
      ? `https://mandal.cm/connexion.php?${transmis
          .map((c, k) => `${["nom", "mdp", "classe"][k] ?? "champ"}=${c.valeur}`)
          .join("&")}`
      : "https://mandal.cm/connexion.php";

  const W = 440;
  const H = 150;

  return (
    <div className="space-y-3">
      <Choice<"get" | "post">
        label="Méthode d'envoi"
        value={methode}
        options={[
          { value: "get", label: "method=get" },
          { value: "post", label: "method=post" },
        ]}
        onChange={(v) => {
          setMethode(v);
          setEnvoye(false);
        }}
      />

      <Panel>
        <Choice<"oui" | "non">
          label="Le champ mot de passe a-t-il un name ?"
          value={avecName ? "oui" : "non"}
          options={[
            { value: "oui", label: "Oui" },
            { value: "non", label: "Non" },
          ]}
          onChange={(v) => {
            setAvecName(v === "oui");
            setEnvoye(false);
          }}
        />
        <Choice<"oui" | "non">
          label="Le champ classe est-il dans le form ?"
          value={dansForm ? "oui" : "non"}
          options={[
            { value: "oui", label: "Dedans" },
            { value: "non", label: "Dehors" },
          ]}
          onChange={(v) => {
            setDansForm(v === "oui");
            setEnvoye(false);
          }}
        />
      </Panel>

      <Board width={W} height={H}>
        <rect width={W} height={H} fill="#ffffff" />

        <rect x={14} y={14} width={412} height={30} rx={6} fill="#0f172a" />
        <text x={26} y={33} fontSize={9} fontFamily="monospace" fill="#e2e8f0">
          {envoye
            ? url.slice(0, 68) + (url.length > 68 ? "…" : "")
            : "la barre d'adresse du navigateur"}
        </text>

        <text x={14} y={66} fontSize={10} fontWeight={700} fill={PALETTE.ink}>
          Ce qui arrive réellement à connexion.php
        </text>
        {envoye ? (
          transmis.length === 0 ? (
            <text x={14} y={90} fontSize={11} fontWeight={700} fill="#b91c1c">
              rien du tout
            </text>
          ) : (
            transmis.map((c, k) => (
              <text
                key={c.nom}
                x={20}
                y={88 + k * 18}
                fontSize={11}
                fontFamily="monospace"
                fill="#15803d"
              >
                {["nom", "mdp", "classe"][k] ?? "champ"} = {c.valeur}
              </text>
            ))
          )
        ) : (
          <text x={14} y={90} fontSize={10} fill={PALETTE.slate}>
            clique sur Envoyer
          </text>
        )}

        {envoye && methode === "get" ? (
          <text x={14} y={H - 10} fontSize={10} fontWeight={700} fill="#b91c1c">
            le mot de passe s&apos;étale en clair dans l&apos;adresse
          </text>
        ) : envoye ? (
          <text x={14} y={H - 10} fontSize={10} fontWeight={700} fill="#15803d">
            l&apos;adresse reste propre : les données voyagent dans le corps de la requête
          </text>
        ) : null}
      </Board>

      <button
        type="button"
        onClick={() => setEnvoye(true)}
        className="rounded-lg bg-primary px-3 py-1.5 text-xs font-semibold text-primary-foreground"
      >
        Envoyer le formulaire
      </button>

      <Panel>
        <Stat label="Champs remplis" value={`${champs.length}`} />
        <Stat
          label="Champs reçus par le serveur"
          value={`${transmis.length}`}
          color={transmis.length === champs.length ? PALETTE.green : PALETTE.red}
        />
      </Panel>

      {!avecName ? (
        <Verdict tone="bad">
          Le mot de passe a bien été tapé, il a bien été envoyé avec le reste… et il est perdu,
          parce que le programme ne sait pas sous quel nom le retrouver. C&apos;est une erreur{" "}
          <strong>silencieuse</strong>, et donc redoutable : un champ sans <code>name</code> ne sert
          à rien.
        </Verdict>
      ) : !dansForm ? (
        <Verdict tone="bad">
          Le champ classe est posé <strong>hors</strong> du form. Il s&apos;affiche, le visiteur le
          remplit, et sa valeur n&apos;arrive jamais. Tous les champs doivent être à
          l&apos;intérieur du <code>form</code>.
        </Verdict>
      ) : methode === "get" ? (
        <Verdict tone="bad">
          Regarde la barre d&apos;adresse : le mot de passe y figure en clair. Il serait lisible par
          quiconque regarde l&apos;écran, conservé dans l&apos;historique du navigateur, et
          enregistré dans les journaux des serveurs traversés. Passe en <code>post</code>.
        </Verdict>
      ) : (
        <Verdict tone="ok">
          Avec <code>post</code>, les données voyagent dans le corps de la requête et
          n&apos;appa­raissent pas dans l&apos;adresse. Un mot de passe passe toujours en post.
          Précision honnête : post cache les données, il ne les chiffre pas — pour une vraie
          protection, il faut aussi que le site soit en https.
        </Verdict>
      )}
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Chapitre 16 — Les types de champs                                   */
/* ------------------------------------------------------------------ */

export function ChampsInput() {
  const [memeName, setMemeName] = useState(true);
  const [coches, setCoches] = useState<string[]>([]);

  const series = ["A", "C", "D"];

  const cocher = (s: string) => {
    if (memeName) setCoches([s]);
    else setCoches((v) => (v.includes(s) ? v.filter((x) => x !== s) : [...v, s]));
  };

  const source = `<p>Nom : <input type="text" name="nom" required></p>
<p>Mot de passe : <input type="password" name="mdp"></p>
<p>Série :
  <input type="radio" name="${memeName ? "serie" : "serieA"}" value="A"> A
  <input type="radio" name="${memeName ? "serie" : "serieC"}" value="C"> C
  <input type="radio" name="${memeName ? "serie" : "serieD"}" value="D"> D
</p>
<p><input type="checkbox" name="reglement"> J'accepte le règlement</p>
<p><input type="submit" value="M'inscrire">
   <input type="reset" value="Effacer"></p>`;

  return (
    <div className="space-y-3">
      <div className="space-y-1">
        <p className="text-xs font-medium text-muted-foreground">
          Le formulaire tel qu&apos;il s&apos;affiche
        </p>
        <RenduHtml source={source} />
      </div>

      <div className="rounded-lg border border-border bg-background p-3 space-y-2">
        <p className="text-xs font-semibold">Les boutons radio de la série, à l&apos;essai</p>
        <Choice<"meme" | "differents">
          label="Attribut name des trois boutons"
          value={memeName ? "meme" : "differents"}
          options={[
            { value: "meme", label: 'Le même : name="serie"' },
            { value: "differents", label: "Trois name différents" },
          ]}
          onChange={(v) => {
            setMemeName(v === "meme");
            setCoches([]);
          }}
        />
        <div className="flex flex-wrap gap-1.5">
          {series.map((s) => (
            <button
              key={s}
              type="button"
              onClick={() => cocher(s)}
              className={
                coches.includes(s)
                  ? "rounded-lg bg-primary px-3 py-1.5 text-xs font-semibold text-primary-foreground"
                  : "rounded-lg border border-border bg-background px-3 py-1.5 text-xs font-medium hover:bg-secondary/60"
              }
            >
              {coches.includes(s) ? "◉" : "○"} 1ère {s}
            </button>
          ))}
        </div>
        {memeName ? (
          <Verdict tone="ok">
            Les trois boutons portent le même <code>name</code>, donc ils s&apos;excluent : cocher
            l&apos;un décoche l&apos;autre. C&apos;est exactement ce qu&apos;on veut pour une série,
            puisqu&apos;un élève n&apos;en a qu&apos;une.
          </Verdict>
        ) : (
          <Verdict tone="bad">
            Avec trois <code>name</code> différents, les boutons ne forment plus un groupe : tu peux
            cocher les trois séries à la fois. C&apos;est l&apos;erreur de débutant la plus
            fréquente — et c&apos;est le <code>name</code> identique qui regroupe, pas le type.
          </Verdict>
        )}
      </div>

      <pre className="overflow-x-auto rounded-lg border border-border bg-secondary/30 p-2.5 font-mono text-[11px] leading-relaxed">
        {source}
      </pre>

      <Panel>
        <Stat
          label="Séries cochées"
          value={`${coches.length}`}
          color={coches.length > 1 ? PALETTE.red : PALETTE.green}
        />
        <Stat label="Comportement" value={memeName ? "un seul choix" : "choix multiples"} />
      </Panel>

      <div className="rounded-lg border border-border bg-background p-3 space-y-1">
        <p className="text-xs font-semibold">Radio contre checkbox, en une phrase</p>
        <p className="text-[11px] text-muted-foreground">
          <strong>Radio</strong> : un seul choix dans le groupe, et les champs du groupe partagent
          le même <code>name</code> — une série, un niveau. <strong>Checkbox</strong> : chaque case
          est indépendante, on peut en cocher plusieurs ou aucune — des options, une condition
          acceptée. Un radio seul serait d&apos;ailleurs impossible à décocher, ce qui le rend
          inadapté à un « j&apos;accepte ».
        </p>
      </div>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Chapitre 16 — Assembler un formulaire complet                       */
/* ------------------------------------------------------------------ */

type PieceId = "nom" | "classe" | "mdp" | "presentation" | "submit";

const PIECES: ReadonlyArray<{
  id: PieceId;
  label: string;
  html: string;
  name: string;
  valeur: string;
  requis: boolean;
}> = [
  {
    id: "nom",
    label: "Champ texte « Nom et prénom »",
    html: '  <p>\n    <label for="nom">Nom et prénom :</label>\n    <input type="text" id="nom" name="nom" required>\n  </p>',
    name: "nom",
    valeur: "Thierry Engoulou",
    requis: true,
  },
  {
    id: "classe",
    label: "Liste déroulante « Classe »",
    html: '  <p>\n    <label for="classe">Classe :</label>\n    <select id="classe" name="classe">\n      <option value="1A">1ère A</option>\n      <option value="1C">1ère C</option>\n      <option value="1D">1ère D</option>\n    </select>\n  </p>',
    name: "classe",
    valeur: "1A",
    requis: true,
  },
  {
    id: "mdp",
    label: "Champ mot de passe",
    html: '  <p>\n    <label for="mdp">Mot de passe :</label>\n    <input type="password" id="mdp" name="mdp" required>\n  </p>',
    name: "mdp",
    valeur: "••••••••",
    requis: true,
  },
  {
    id: "presentation",
    label: "Zone de texte « Un mot sur vous »",
    html: '  <textarea name="presentation" rows="3" cols="34"></textarea>',
    name: "presentation",
    valeur: "(vide)",
    requis: false,
  },
  {
    id: "submit",
    label: "Bouton d'envoi",
    html: '  <p><input type="submit" value="M\'inscrire"></p>',
    name: "",
    valeur: "",
    requis: true,
  },
];

export function FormulaireComplet() {
  const [posees, setPosees] = useState<PieceId[]>([]);
  const [dehors, setDehors] = useState<PieceId[]>([]);
  const [envoye, setEnvoye] = useState(false);

  const dedans = PIECES.filter((p) => posees.includes(p.id) && !dehors.includes(p.id));
  const source = `<form action="inscription.php" method="post">\n  <fieldset>\n    <legend>Inscription à M'Andal</legend>\n${dedans
    .map((p) => p.html)
    .join("\n")}\n  </fieldset>\n</form>${PIECES.filter((p) => dehors.includes(p.id))
    .map((p) => "\n" + p.html)
    .join("")}`;

  const recus = dedans.filter((p) => p.name !== "");
  const manqueSubmit = !posees.includes("submit") || dehors.includes("submit");
  const manquants = PIECES.filter((p) => p.requis && !posees.includes(p.id));

  const bascule = (id: PieceId) => {
    setEnvoye(false);
    if (!posees.includes(id)) {
      setPosees([...posees, id]);
      return;
    }
    if (!dehors.includes(id)) {
      setDehors([...dehors, id]);
      return;
    }
    setPosees(posees.filter((x) => x !== id));
    setDehors(dehors.filter((x) => x !== id));
  };

  const etat = (id: PieceId) =>
    !posees.includes(id) ? "absent" : dehors.includes(id) ? "dehors" : "dedans";

  return (
    <div className="space-y-3">
      <div className="space-y-1.5">
        <p className="text-xs font-medium text-muted-foreground">
          Clique pour poser une pièce dans le form, reclique pour la sortir du form, reclique pour
          la retirer
        </p>
        <div className="flex flex-wrap gap-1.5">
          {PIECES.map((p) => {
            const e = etat(p.id);
            return (
              <button
                key={p.id}
                type="button"
                onClick={() => bascule(p.id)}
                className={
                  e === "dedans"
                    ? "rounded-lg bg-primary px-2.5 py-1.5 text-[11px] font-semibold text-primary-foreground"
                    : e === "dehors"
                      ? "rounded-lg border border-rose-500/50 bg-rose-500/10 px-2.5 py-1.5 text-[11px] font-medium text-rose-700"
                      : "rounded-lg border border-border bg-background px-2.5 py-1.5 text-[11px] font-medium hover:bg-secondary/60"
                }
              >
                {p.label}
                {e === "dehors" ? " — hors du form" : ""}
              </button>
            );
          })}
        </div>
      </div>

      <RenduHtml source={source} />

      <pre className="overflow-x-auto rounded-lg border border-border bg-secondary/30 p-2.5 font-mono text-[11px] leading-relaxed">
        {source}
      </pre>

      <button
        type="button"
        onClick={() => setEnvoye(true)}
        disabled={manqueSubmit}
        className={
          manqueSubmit
            ? "rounded-lg border border-border bg-secondary/40 px-3 py-1.5 text-xs text-muted-foreground/50"
            : "rounded-lg bg-primary px-3 py-1.5 text-xs font-semibold text-primary-foreground"
        }
      >
        Envoyer à inscription.php
      </button>

      {envoye ? (
        <div className="rounded-lg border border-border bg-slate-900 p-3 space-y-1">
          <p className="font-mono text-[11px] text-slate-400">reçu côté serveur :</p>
          {recus.length === 0 ? (
            <p className="font-mono text-[11px] text-rose-400">aucune donnée</p>
          ) : (
            recus.map((p) => (
              <p key={p.id} className="font-mono text-[11px] text-emerald-400">
                {p.name} = {p.valeur}
              </p>
            ))
          )}
          {dehors.length > 0 ? (
            <p className="font-mono text-[11px] text-rose-400">
              {dehors.length} champ(s) posé(s) hors du form : jamais transmis
            </p>
          ) : null}
        </div>
      ) : null}

      <Panel>
        <Stat label="Pièces dans le form" value={`${dedans.length}`} />
        <Stat
          label="Hors du form"
          value={`${dehors.length}`}
          color={dehors.length > 0 ? PALETTE.red : PALETTE.green}
        />
      </Panel>

      {manquants.length > 0 ? (
        <Verdict tone="warn">
          Il manque encore : {manquants.map((p) => p.label.toLowerCase()).join(", ")}. Sans bouton
          d&apos;envoi, le visiteur ne peut rien transmettre.
        </Verdict>
      ) : dehors.length > 0 ? (
        <Verdict tone="bad">
          Les pièces en rouge sont hors du <code>form</code> : elles s&apos;affichent, le visiteur
          les remplit, et leurs valeurs n&apos;arrivent jamais à inscription.php. Rentre-les.
        </Verdict>
      ) : (
        <Verdict tone="ok">
          Formulaire complet. Remarque la différence entre les deux attributs que chaque champ porte
          : le <code>name</code> parle au <strong>serveur</strong> — c&apos;est l&apos;étiquette
          d&apos;arrivée — et l&apos;<code>id</code> parle à la <strong>page</strong>, c&apos;est la
          cible du <code>label</code>. Ils portent souvent le même mot, mais ils ne servent pas à la
          même chose.
        </Verdict>
      )}
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Chapitre 17 — La syntaxe CSS                                        */
/* ------------------------------------------------------------------ */

type Selecteur = "h1" | "p" | "classe" | "id" | "tous";

export function SyntaxeCss() {
  const [sel, setSel] = useState<Selecteur>("h1");
  const [couleur, setCouleur] = useState("#2563eb");
  const [taille, setTaille] = useState(16);
  const [centre, setCentre] = useState(false);
  const [pointVirgule, setPointVirgule] = useState(true);

  const texteSel =
    sel === "h1"
      ? "h1"
      : sel === "p"
        ? "p"
        : sel === "classe"
          ? ".important"
          : sel === "id"
            ? "#menu"
            : "*";

  const vise = (quoi: "h1" | "p" | "pImportant" | "divMenu") => {
    if (sel === "tous") return true;
    if (sel === "h1") return quoi === "h1";
    if (sel === "p") return quoi === "p" || quoi === "pImportant";
    if (sel === "classe") return quoi === "pImportant";
    return quoi === "divMenu";
  };

  // sans point-virgule, la déclaration suivante est avalée
  const tailleActive = pointVirgule ? taille : 16;
  const centreActif = pointVirgule ? centre : false;

  const style = (quoi: "h1" | "p" | "pImportant" | "divMenu") =>
    vise(quoi)
      ? {
          color: couleur,
          fontSize: quoi === "h1" ? tailleActive + 6 : tailleActive,
          textAlign: (centreActif ? "center" : "left") as "center" | "left",
        }
      : { fontSize: quoi === "h1" ? 22 : 13 };

  const code = `${texteSel} {
    color: ${couleur}${pointVirgule ? ";" : ""}
    font-size: ${taille}px;
    text-align: ${centre ? "center" : "left"};
}`;

  return (
    <div className="space-y-3">
      <Choice<Selecteur>
        label="Sélecteur — QUI est visé"
        value={sel}
        options={[
          { value: "h1", label: "h1" },
          { value: "p", label: "p" },
          { value: "classe", label: ".important" },
          { value: "id", label: "#menu" },
          { value: "tous", label: "*" },
        ]}
        onChange={setSel}
      />

      <Panel>
        <Choice<string>
          label="color — la valeur"
          value={couleur}
          options={[
            { value: "#2563eb", label: "bleu" },
            { value: "#dc2626", label: "rouge" },
            { value: "#15803d", label: "vert" },
            { value: "#0f172a", label: "noir" },
          ]}
          onChange={setCouleur}
        />
        <Ctrl
          label="font-size"
          value={taille}
          min={10}
          max={28}
          step={1}
          onChange={setTaille}
          display={`${taille} px`}
        />
      </Panel>

      <div className="flex flex-wrap gap-1.5">
        <button
          type="button"
          onClick={() => setCentre(!centre)}
          className={
            centre
              ? "rounded-lg bg-primary px-3 py-1.5 text-xs font-semibold text-primary-foreground"
              : "rounded-lg border border-border bg-background px-3 py-1.5 text-xs font-medium hover:bg-secondary/60"
          }
        >
          text-align: center
        </button>
        <button
          type="button"
          onClick={() => setPointVirgule(!pointVirgule)}
          className={
            pointVirgule
              ? "rounded-lg border border-border bg-background px-3 py-1.5 text-xs font-medium hover:bg-secondary/60"
              : "rounded-lg bg-rose-600 px-3 py-1.5 text-xs font-semibold text-white"
          }
        >
          {pointVirgule ? "Retirer le point-virgule après color" : "Remettre le point-virgule"}
        </button>
      </div>

      <pre className="overflow-x-auto rounded-lg border border-border bg-secondary/30 p-2.5 font-mono text-[11px] leading-relaxed">
        {code}
      </pre>

      <div className="space-y-2 rounded-lg border border-border bg-white p-3">
        <h1 style={style("h1")} className="font-bold">
          Informatique {vise("h1") ? "← visé" : ""}
        </h1>
        <p style={style("p")}>Un paragraphe ordinaire {vise("p") ? "← visé" : ""}</p>
        <p style={style("pImportant")}>
          Un paragraphe de classe « important » {vise("pImportant") ? "← visé" : ""}
        </p>
        <div style={style("divMenu")}>
          Le div d&apos;identifiant « menu » {vise("divMenu") ? "← visé" : ""}
        </div>
      </div>

      <Panel>
        <Stat
          label="Éléments visés"
          value={`${(["h1", "p", "pImportant", "divMenu"] as const).filter(vise).length} / 4`}
          color={PALETTE.blue}
        />
        <Stat
          label="Règle valide"
          value={pointVirgule ? "oui" : "non"}
          color={pointVirgule ? PALETTE.green : PALETTE.red}
        />
      </Panel>

      {!pointVirgule ? (
        <Verdict tone="bad">
          Sans le point-virgule après <code>color</code>, la déclaration suivante est{" "}
          <strong>avalée</strong> : regarde, la taille et l&apos;alignement n&apos;ont plus
          d&apos;effet. C&apos;est la panne la plus fréquente d&apos;un débutant, et on la cherche
          longtemps parce que rien ne signale l&apos;erreur.
        </Verdict>
      ) : sel === "classe" ? (
        <Verdict tone="ok">
          Le <strong>point</strong> désigne une classe, posée en HTML par{" "}
          <code>class=&quot;important&quot;</code>, et elle peut servir autant de fois qu&apos;on
          veut dans la page.
        </Verdict>
      ) : sel === "id" ? (
        <Verdict tone="ok">
          Le <strong>dièse</strong> désigne un identifiant, posé par{" "}
          <code>id=&quot;menu&quot;</code>, et il doit être <strong>unique</strong> dans la page.
          C&apos;est toute la différence avec la classe.
        </Verdict>
      ) : (
        <Verdict tone="ok">
          Trois parties à savoir nommer : le <strong>sélecteur</strong> dit qui est visé, la{" "}
          <strong>propriété</strong> dit quoi est changé, la <strong>valeur</strong> dit comment.
          Accolades autour du bloc, deux-points entre la propriété et la valeur, point-virgule à la
          fin de chaque déclaration.
        </Verdict>
      )}
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Chapitre 17 — La cascade                                            */
/* ------------------------------------------------------------------ */

export function PlacementsCss() {
  const [externe, setExterne] = useState(true);
  const [interne, setInterne] = useState(true);
  const [enLigne, setEnLigne] = useState(true);

  const gagnant = enLigne ? "en ligne" : interne ? "interne" : externe ? "externe" : "aucune";
  const couleur = enLigne ? "#dc2626" : interne ? "#15803d" : externe ? "#2563eb" : "#0f172a";

  const W = 440;
  const H = 180;

  const regles: ReadonlyArray<{
    nom: string;
    actif: boolean;
    gagne: boolean;
    code: string;
    couleur: string;
    priorite: string;
  }> = [
    {
      nom: "CSS externe — style.css",
      actif: externe,
      gagne: gagnant === "externe",
      code: "p { color: blue; }",
      couleur: "#2563eb",
      priorite: "la plus faible",
    },
    {
      nom: "CSS interne — <style> dans le head",
      actif: interne,
      gagne: gagnant === "interne",
      code: "p { color: green; }",
      couleur: "#15803d",
      priorite: "intermédiaire",
    },
    {
      nom: "CSS en ligne — attribut style",
      actif: enLigne,
      gagne: gagnant === "en ligne",
      code: '<p style="color: red;">',
      couleur: "#dc2626",
      priorite: "la plus forte",
    },
  ];

  return (
    <div className="space-y-3">
      <div className="flex flex-wrap gap-1.5">
        <button
          type="button"
          onClick={() => setExterne(!externe)}
          className={
            externe
              ? "rounded-lg bg-blue-600 px-3 py-1.5 text-xs font-semibold text-white"
              : "rounded-lg border border-border bg-background px-3 py-1.5 text-xs font-medium hover:bg-secondary/60"
          }
        >
          CSS externe
        </button>
        <button
          type="button"
          onClick={() => setInterne(!interne)}
          className={
            interne
              ? "rounded-lg bg-emerald-600 px-3 py-1.5 text-xs font-semibold text-white"
              : "rounded-lg border border-border bg-background px-3 py-1.5 text-xs font-medium hover:bg-secondary/60"
          }
        >
          CSS interne
        </button>
        <button
          type="button"
          onClick={() => setEnLigne(!enLigne)}
          className={
            enLigne
              ? "rounded-lg bg-rose-600 px-3 py-1.5 text-xs font-semibold text-white"
              : "rounded-lg border border-border bg-background px-3 py-1.5 text-xs font-medium hover:bg-secondary/60"
          }
        >
          CSS en ligne
        </button>
      </div>

      <Board width={W} height={H}>
        <rect width={W} height={H} fill="#ffffff" />
        {regles.map((r, k) => (
          <g key={r.nom} opacity={r.actif ? 1 : 0.28}>
            <rect
              x={14}
              y={16 + k * 44}
              width={412}
              height={36}
              rx={5}
              fill={r.gagne ? "#fef3c7" : "#f8fafc"}
              stroke={r.gagne ? "#ca8a04" : "#e2e8f0"}
              strokeWidth={r.gagne ? 2 : 1}
            />
            <text x={24} y={32 + k * 44} fontSize={10} fontWeight={700} fill={r.couleur}>
              {r.nom} — priorité {r.priorite}
            </text>
            <text
              x={24}
              y={46 + k * 44}
              fontSize={10}
              fontFamily="monospace"
              fill={r.actif && !r.gagne ? "#94a3b8" : r.couleur}
              textDecoration={r.actif && !r.gagne ? "line-through" : undefined}
            >
              {r.code}
            </text>
            <text
              x={416}
              y={40 + k * 44}
              textAnchor="end"
              fontSize={9}
              fontWeight={700}
              fill={r.gagne ? "#b45309" : "#94a3b8"}
            >
              {!r.actif ? "désactivée" : r.gagne ? "GAGNE" : "écrasée"}
            </text>
          </g>
        ))}

        <text x={14} y={168} fontSize={13} fontWeight={700} fill={couleur}>
          Le paragraphe s&apos;affiche en{" "}
          {gagnant === "aucune"
            ? "noir, la couleur par défaut"
            : gagnant === "en ligne"
              ? "rouge"
              : gagnant === "interne"
                ? "vert"
                : "bleu"}
        </text>
      </Board>

      <Panel>
        <Stat label="Règles actives" value={`${regles.filter((r) => r.actif).length} / 3`} />
        <Stat label="Celle qui gagne" value={gagnant} color={couleur} />
      </Panel>

      <Verdict tone={gagnant === "aucune" ? "warn" : "ok"}>
        {gagnant === "aucune"
          ? "Aucune règle active : le paragraphe prend la couleur par défaut du navigateur."
          : `C'est la règle ${gagnant} qui gagne, parce que la plus proche de l'élément l'emporte : en ligne bat interne, qui bat externe. Et à provenance égale, la dernière règle écrite gagne. Voilà la réponse au fameux « mon CSS ne marche pas » : la règle n'est pas ignorée, elle est écrasée.`}
      </Verdict>

      <div className="rounded-lg border border-border bg-background p-3 space-y-1">
        <p className="text-xs font-semibold">
          Et laquelle choisir pour un site de plusieurs pages ?
        </p>
        <p className="text-[11px] text-muted-foreground">
          Le <strong>CSS externe</strong>, pour trois raisons : une seule source habille tout le
          site, une seule correction suffit pour toutes les pages, et le navigateur garde le fichier
          en mémoire, donc les pages suivantes se chargent plus vite. C&apos;est la réponse attendue
          en examen.
        </p>
      </div>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Chapitre 17 — Habiller une page                                     */
/* ------------------------------------------------------------------ */

export function FeuilleStyle() {
  const [fond, setFond] = useState("#f5f5f5");
  const [police, setPolice] = useState("Arial, Helvetica, sans-serif");
  const [taille, setTaille] = useState(13);
  const [interligne, setInterligne] = useState(1.6);
  const [couleurTitre, setCouleurTitre] = useState("#003366");
  const [centreTitre, setCentreTitre] = useState(true);
  const [bordure, setBordure] = useState(2);
  const [padding, setPadding] = useState(12);
  const [marge, setMarge] = useState(16);
  const [montreBoite, setMontreBoite] = useState(true);

  const pad = clamp(Math.round(padding), 0, 40);
  const mar = clamp(Math.round(marge), 0, 40);

  const code = `body {
    background-color: ${fond};
    font-family: ${police};
    font-size: ${taille}px;
    line-height: ${interligne};
}

h1 {
    color: ${couleurTitre};
    text-align: ${centreTitre ? "center" : "left"};
}

p.encadre {
    border: ${bordure}px solid black;
    padding: ${pad}px;
    margin: ${mar}px 0;
    background-color: white;
}`;

  return (
    <div className="space-y-3">
      <Panel>
        <Choice<string>
          label="background-color du body"
          value={fond}
          options={[
            { value: "#f5f5f5", label: "gris clair" },
            { value: "#ffffff", label: "blanc" },
            { value: "#eff6ff", label: "bleu pâle" },
            { value: "#fef9c3", label: "jaune pâle" },
          ]}
          onChange={setFond}
        />
        <Choice<string>
          label="font-family"
          value={police}
          options={[
            { value: "Arial, Helvetica, sans-serif", label: "Arial" },
            { value: "Georgia, serif", label: "Georgia" },
            { value: "monospace", label: "monospace" },
          ]}
          onChange={setPolice}
        />
      </Panel>

      <Panel>
        <Ctrl
          label="font-size"
          value={taille}
          min={10}
          max={22}
          step={1}
          onChange={setTaille}
          display={`${taille} px`}
        />
        <Ctrl
          label="line-height"
          value={interligne}
          min={1}
          max={2.4}
          step={0.1}
          onChange={setInterligne}
          display={`${interligne.toFixed(1)}`}
        />
      </Panel>

      <Panel>
        <Ctrl
          label="border du paragraphe"
          value={bordure}
          min={0}
          max={8}
          step={1}
          onChange={setBordure}
          display={`${bordure} px`}
        />
        <Choice<string>
          label="color du titre"
          value={couleurTitre}
          options={[
            { value: "#003366", label: "bleu foncé" },
            { value: "#7f1d1d", label: "bordeaux" },
            { value: "#14532d", label: "vert foncé" },
          ]}
          onChange={setCouleurTitre}
        />
      </Panel>

      <Panel>
        <Ctrl
          label="padding — l'espace DEDANS"
          value={pad}
          min={0}
          max={40}
          step={2}
          onChange={setPadding}
          display={`${pad} px`}
          color={PALETTE.green}
        />
        <Ctrl
          label="margin — l'espace DEHORS"
          value={mar}
          min={0}
          max={40}
          step={2}
          onChange={setMarge}
          display={`${mar} px`}
          color={PALETTE.orange}
        />
      </Panel>

      <div className="flex flex-wrap gap-1.5">
        <button
          type="button"
          onClick={() => setCentreTitre(!centreTitre)}
          className={
            centreTitre
              ? "rounded-lg bg-primary px-3 py-1.5 text-xs font-semibold text-primary-foreground"
              : "rounded-lg border border-border bg-background px-3 py-1.5 text-xs font-medium hover:bg-secondary/60"
          }
        >
          titre centré
        </button>
        <button
          type="button"
          onClick={() => setMontreBoite(!montreBoite)}
          className={
            montreBoite
              ? "rounded-lg bg-primary px-3 py-1.5 text-xs font-semibold text-primary-foreground"
              : "rounded-lg border border-border bg-background px-3 py-1.5 text-xs font-medium hover:bg-secondary/60"
          }
        >
          colorier padding et margin
        </button>
      </div>

      <div
        className="rounded-lg border border-border p-0"
        style={{ background: fond, fontFamily: police, fontSize: taille, lineHeight: interligne }}
      >
        <div style={{ padding: 10 }}>
          <h1
            style={{
              color: couleurTitre,
              textAlign: centreTitre ? "center" : "left",
              fontSize: taille + 8,
              fontWeight: 700,
              margin: "4px 0 8px",
            }}
          >
            Informatique
          </h1>

          <div style={{ background: montreBoite ? "#fed7aa" : "transparent", padding: mar }}>
            <div
              style={{
                border: `${bordure}px solid black`,
                background: montreBoite ? "#bbf7d0" : "white",
                padding: pad,
              }}
            >
              <p style={{ background: "white", margin: 0 }}>
                Un paragraphe de classe « encadre ». Le padding met du blanc à l&apos;intérieur du
                cadre ; la marge écarte le cadre de ses voisins.
              </p>
            </div>
          </div>

          <p style={{ margin: "8px 0 4px", color: "#0f172a" }}>
            Un paragraphe ordinaire, qui hérite du body sa police, sa taille et son interligne.
          </p>
        </div>
      </div>

      {montreBoite ? (
        <p className="text-[11px] text-muted-foreground">
          En <span className="font-semibold text-emerald-700">vert</span>, le padding : il est{" "}
          <strong>à l&apos;intérieur</strong> de la bordure noire. En{" "}
          <span className="font-semibold text-orange-700">orange</span>, la margin : elle est{" "}
          <strong>à l&apos;extérieur</strong>. C&apos;est la distinction qui tombe en examen, et la
          même idée que cellpadding et cellspacing dans les tableaux.
        </p>
      ) : null}

      <pre className="overflow-x-auto rounded-lg border border-border bg-secondary/30 p-2.5 font-mono text-[11px] leading-relaxed">
        {code}
      </pre>

      <Panel>
        <Stat label="padding" value={`${pad} px — dedans`} color={PALETTE.green} />
        <Stat label="margin" value={`${mar} px — dehors`} color={PALETTE.orange} />
      </Panel>

      <Verdict tone="ok">
        Le fond et la police sont posés une seule fois sur <code>body</code> et se transmettent à
        tout ce qu&apos;il contient : c&apos;est l&apos;héritage, et il économise beaucoup de
        lignes. Mets maintenant le padding à 0 : le texte viendra coller à la bordure, et tu verras
        pourquoi ce n&apos;est pas la margin qu&apos;il fallait.
      </Verdict>
    </div>
  );
}
