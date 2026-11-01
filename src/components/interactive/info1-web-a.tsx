import { useState } from "react";
import { Board, Choice, Ctrl, PALETTE, Panel, Stat, Verdict } from "./controls";
import { RenduHtml, analyserHtml } from "./info1-html";

/** Informatique 1ère A, C et D — chapitres 13 à 15 : HTML, texte, images, liens, listes, tableaux. */

function clamp(v: number, lo: number, hi: number) {
  return Math.max(lo, Math.min(hi, v));
}

/* ------------------------------------------------------------------ */
/* Chapitre 13 — L'éditeur HTML                                        */
/* ------------------------------------------------------------------ */

const EXEMPLES: ReadonlyArray<{ label: string; code: string }> = [
  {
    label: "Première page",
    code: "<h1>Bienvenue</h1>\n<p>Ceci est ma première page web.</p>\n<p>Elle contient du <strong>gras</strong> et de l'<em>italique</em>.</p>",
  },
  {
    label: "Balise oubliée",
    code: "<h1>Bienvenue\n<p>Le titre n'a jamais été fermé. Regarde ce que cela donne.</p>",
  },
  {
    label: "Balises croisées",
    code: "<p>Un mot <strong>important</p></strong>",
  },
  {
    label: "Espaces multiples",
    code: "<p>Bonjour      tout\nle        monde</p>",
  },
];

const EXEMPLE_DEFAUT = EXEMPLES[0] ?? { label: "", code: "" };

export function EditeurHtml() {
  const [src, setSrc] = useState(EXEMPLE_DEFAUT.code);

  const { erreurs } = analyserHtml(src);

  return (
    <div className="space-y-3">
      <Choice<string>
        label="Charger un exemple"
        value=""
        options={EXEMPLES.map((e) => ({ value: e.label, label: e.label }))}
        onChange={(v) => {
          const e = EXEMPLES.find((q) => q.label === v);
          if (e) setSrc(e.code);
        }}
      />

      <div className="space-y-1">
        <p className="text-xs font-medium text-muted-foreground">Ton code HTML</p>
        <textarea
          value={src}
          onChange={(e) => setSrc(e.target.value)}
          rows={7}
          spellCheck={false}
          className="w-full rounded-lg border border-border bg-secondary/20 p-2.5 font-mono text-[11px] leading-relaxed"
        />
      </div>

      <div className="space-y-1">
        <p className="text-xs font-medium text-muted-foreground">Ce que le navigateur affiche</p>
        <RenduHtml source={src} />
      </div>

      <Panel>
        <Stat label="Caractères" value={`${src.length}`} />
        <Stat
          label="Problèmes détectés"
          value={`${erreurs.length}`}
          color={erreurs.length === 0 ? PALETTE.green : PALETTE.red}
        />
      </Panel>

      {erreurs.length === 0 ? (
        <Verdict tone="ok">
          Aucun problème d&apos;imbrication. Essaie maintenant de supprimer une balise de fermeture,
          ou de croiser deux balises : tu verras le rendu partir de travers, exactement comme dans
          un vrai navigateur.
        </Verdict>
      ) : (
        <div className="space-y-1.5">
          {erreurs.map((e, k) => (
            <Verdict key={k} tone="bad">
              {e.message}
            </Verdict>
          ))}
        </div>
      )}
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Chapitre 13 — Construire le squelette                               */
/* ------------------------------------------------------------------ */

type Emplacement = "dehors" | "head" | "body";

const A_PLACER: ReadonlyArray<{ id: string; etiquette: string; bon: Emplacement; note: string }> = [
  {
    id: "doctype",
    etiquette: "<!DOCTYPE html>",
    bon: "dehors",
    note: "Toujours la première ligne, avant même <html>. Elle annonce une page HTML moderne.",
  },
  {
    id: "title",
    etiquette: "<title>M'Andal</title>",
    bon: "head",
    note: "Le titre de l'onglet. Le mettre dans le body est l'erreur la plus courante.",
  },
  {
    id: "meta",
    etiquette: '<meta charset="utf-8">',
    bon: "head",
    note: "Sans elle, « Première » et les apostrophes s'affichent en symboles bizarres.",
  },
  {
    id: "h1",
    etiquette: "<h1>Informatique</h1>",
    bon: "body",
    note: "Un titre visible, donc dans le corps de la page.",
  },
  {
    id: "p",
    etiquette: "<p>Cours de Première.</p>",
    bon: "body",
    note: "Tout ce que le visiteur lit est dans le body.",
  },
  {
    id: "img",
    etiquette: '<img src="logo.png" alt="Logo">',
    bon: "body",
    note: "Une image se voit : elle est donc dans le corps.",
  },
];

export function StructurePage() {
  const [pose, setPose] = useState<Record<string, Emplacement>>({});

  const bons = A_PLACER.filter((a) => pose[a.id] === a.bon).length;
  const complet = A_PLACER.every((a) => pose[a.id] !== undefined);
  const tout = complet && bons === A_PLACER.length;

  const dans = (e: Emplacement) => A_PLACER.filter((a) => pose[a.id] === e);

  const W = 440;
  const H = 240;

  return (
    <div className="space-y-3">
      <Board width={W} height={H}>
        <rect width={W} height={H} fill="#ffffff" />

        <rect
          x={14}
          y={14}
          width={412}
          height={30}
          rx={4}
          fill="#f8fafc"
          stroke="#94a3b8"
          strokeWidth={1.2}
          strokeDasharray="4 3"
        />
        <text x={24} y={33} fontSize={10} fontWeight={700} fill="#64748b">
          avant &lt;html&gt; — {dans("dehors").length} élément(s)
        </text>

        <rect
          x={14}
          y={52}
          width={412}
          height={176}
          rx={6}
          fill="#fdf2f8"
          stroke="#be185d"
          strokeWidth={1.6}
        />
        <text x={24} y={70} fontSize={10} fontFamily="monospace" fontWeight={700} fill="#9d174d">
          &lt;html&gt;
        </text>

        <rect
          x={30}
          y={78}
          width={380}
          height={62}
          rx={4}
          fill="#fce7f3"
          stroke="#be185d"
          strokeWidth={1.2}
        />
        <text x={40} y={94} fontSize={10} fontFamily="monospace" fontWeight={700} fill="#9d174d">
          &lt;head&gt; — invisible
        </text>
        {dans("head").map((a, k) => (
          <text
            key={a.id}
            y={110 + k * 14}
            x={52}
            fontSize={9}
            fontFamily="monospace"
            fill="#9d174d"
          >
            {a.etiquette}
          </text>
        ))}

        <rect
          x={30}
          y={148}
          width={380}
          height={62}
          rx={4}
          fill="#dcfce7"
          stroke="#15803d"
          strokeWidth={1.2}
        />
        <text x={40} y={164} fontSize={10} fontFamily="monospace" fontWeight={700} fill="#14532d">
          &lt;body&gt; — ce que le visiteur voit
        </text>
        {dans("body").map((a, k) => (
          <text
            key={a.id}
            y={180 + k * 13}
            x={52}
            fontSize={9}
            fontFamily="monospace"
            fill="#14532d"
          >
            {a.etiquette}
          </text>
        ))}

        <text x={24} y={224} fontSize={10} fontFamily="monospace" fontWeight={700} fill="#9d174d">
          &lt;/html&gt;
        </text>
      </Board>

      <div className="space-y-2">
        {A_PLACER.map((a) => {
          const r = pose[a.id];
          const ok = r === a.bon;
          return (
            <div
              key={a.id}
              className={
                r === undefined
                  ? "rounded-lg border border-border bg-background p-2.5 space-y-1.5"
                  : ok
                    ? "rounded-lg border border-emerald-500/40 bg-emerald-500/5 p-2.5 space-y-1.5"
                    : "rounded-lg border border-rose-500/40 bg-rose-500/5 p-2.5 space-y-1.5"
              }
            >
              <p className="font-mono text-[11px] font-semibold">{a.etiquette}</p>
              <Choice<Emplacement>
                value={r ?? "body"}
                options={[
                  { value: "dehors", label: "Avant <html>" },
                  { value: "head", label: "Dans <head>" },
                  { value: "body", label: "Dans <body>" },
                ]}
                onChange={(v) => setPose({ ...pose, [a.id]: v })}
              />
              {r !== undefined ? (
                <p
                  className={ok ? "text-[11px] text-muted-foreground" : "text-[11px] text-rose-700"}
                >
                  {a.note}
                </p>
              ) : null}
            </div>
          );
        })}
      </div>

      <Panel>
        <Stat label="Placés" value={`${Object.keys(pose).length} / ${A_PLACER.length}`} />
        <Stat label="Bien placés" value={`${bons}`} color={PALETTE.green} />
      </Panel>

      {tout ? (
        <Verdict tone="ok">
          Le squelette est juste. La frontière à retenir : le <code>head</code> contient les
          informations <em>sur</em> la page et ne s&apos;affiche pas ; le <code>body</code> contient
          tout ce que le visiteur voit.
        </Verdict>
      ) : (
        <Verdict tone="warn">
          Pose-toi une seule question pour chaque ligne : le visiteur la voit-il dans la fenêtre ?
          Si oui, elle va dans le body. Sinon, dans le head — sauf le DOCTYPE, qui précède tout.
        </Verdict>
      )}
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Chapitre 14 — Les balises de texte                                  */
/* ------------------------------------------------------------------ */

const TAGS_TEXTE = ["h1", "h2", "h3", "p", "strong", "em"] as const;
type TagTexte = (typeof TAGS_TEXTE)[number];

const MORCEAUX: ReadonlyArray<{ texte: string; bon: TagTexte; note: string }> = [
  {
    texte: "Module d'algorithmique",
    bon: "h1",
    note: "C'est le sujet de la page : un seul h1, et c'est lui.",
  },
  {
    texte: "Les notions de base",
    bon: "h2",
    note: "Une grande section de la page : niveau 2.",
  },
  {
    texte: "Un algorithme est une suite finie et ordonnée d'instructions.",
    bon: "p",
    note: "Du texte courant : un paragraphe.",
  },
  {
    texte: "algorithme",
    bon: "strong",
    note: "Le mot-clé défini : il est important, donc strong, qui porte ce sens.",
  },
  {
    texte: "Les structures de contrôle",
    bon: "h2",
    note: "Une autre section de même importance que la précédente : encore un h2.",
  },
  {
    texte: "alternatives",
    bon: "em",
    note: "Un terme technique qu'on souligne par la voix en lisant : em.",
  },
];

export function BalisesTexte() {
  const [rep, setRep] = useState<Record<number, TagTexte>>({});
  const [espaces, setEspaces] = useState(false);

  const bons = MORCEAUX.filter((m, k) => rep[k] === m.bon).length;
  const complet = MORCEAUX.every((_, k) => rep[k] !== undefined);

  const source = MORCEAUX.map((m, k) => {
    const t = rep[k];
    if (t === undefined) return m.texte;
    return `<${t}>${m.texte}</${t}>`;
  }).join("\n");

  const sourceEspaces = "<p>Bonjour      tout\nle        monde</p>";

  return (
    <div className="space-y-3">
      <div className="space-y-2">
        {MORCEAUX.map((m, k) => {
          const r = rep[k];
          const ok = r === m.bon;
          return (
            <div
              key={k}
              className={
                r === undefined
                  ? "rounded-lg border border-border bg-background p-2.5 space-y-1.5"
                  : ok
                    ? "rounded-lg border border-emerald-500/40 bg-emerald-500/5 p-2.5 space-y-1.5"
                    : "rounded-lg border border-rose-500/40 bg-rose-500/5 p-2.5 space-y-1.5"
              }
            >
              <p className="text-xs">{m.texte}</p>
              <Choice<TagTexte>
                value={r ?? "p"}
                options={TAGS_TEXTE.map((t) => ({ value: t, label: `<${t}>` }))}
                onChange={(v) => setRep({ ...rep, [k]: v })}
              />
              {r !== undefined && !ok ? (
                <p className="text-[11px] text-rose-700">
                  C&apos;est &lt;{m.bon}&gt; : {m.note}
                </p>
              ) : null}
              {r !== undefined && ok ? (
                <p className="text-[11px] text-muted-foreground">{m.note}</p>
              ) : null}
            </div>
          );
        })}
      </div>

      <div className="space-y-1">
        <p className="text-xs font-medium text-muted-foreground">Ton code</p>
        <pre className="overflow-x-auto rounded-lg border border-border bg-secondary/30 p-2.5 font-mono text-[11px] leading-relaxed">
          {source}
        </pre>
      </div>

      <div className="space-y-1">
        <p className="text-xs font-medium text-muted-foreground">Le rendu</p>
        <RenduHtml source={source} />
      </div>

      <Panel>
        <Stat label="Bien balisés" value={`${bons} / ${MORCEAUX.length}`} color={PALETTE.green} />
        <Stat
          label="Un seul h1 ?"
          value={MORCEAUX.filter((_, k) => rep[k] === "h1").length === 1 ? "oui" : "non"}
        />
      </Panel>

      {complet && bons === MORCEAUX.length ? (
        <Verdict tone="ok">
          Tout est juste. Retiens surtout pourquoi on préfère <code>strong</code> et <code>em</code>{" "}
          à <code>b</code> et <code>i</code> : même rendu à l&apos;écran, mais seuls les premiers
          portent un sens, que les logiciels de lecture pour aveugles savent transmettre.
        </Verdict>
      ) : (
        <Verdict tone="warn">
          Les titres servent à donner une hiérarchie, pas une taille : si h2 te paraît trop gros, on
          le réduit en CSS, on ne passe pas à h4.
        </Verdict>
      )}

      <button
        type="button"
        onClick={() => setEspaces(!espaces)}
        className={
          espaces
            ? "rounded-lg bg-primary px-3 py-1.5 text-xs font-semibold text-primary-foreground"
            : "rounded-lg border border-border bg-background px-3 py-1.5 text-xs font-medium text-muted-foreground hover:bg-secondary/60"
        }
      >
        {espaces ? "Cacher la surprise des espaces" : "La surprise des espaces multiples"}
      </button>

      {espaces ? (
        <div className="space-y-2">
          <pre className="overflow-x-auto rounded-lg border border-border bg-secondary/30 p-2.5 font-mono text-[11px]">
            {sourceEspaces}
          </pre>
          <RenduHtml source={sourceEspaces} />
          <Verdict tone="warn">
            Le HTML ignore les espaces multiples et les retours à la ligne de ton fichier. Pour
            aérer une page, il faut des balises — &lt;p&gt; ou &lt;br&gt; — et non des touches
            Entrée.
          </Verdict>
        </div>
      ) : null}
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Chapitre 14 — Insérer une image                                     */
/* ------------------------------------------------------------------ */

const ARBO: ReadonlyArray<{ chemin: string; label: string }> = [
  { chemin: "eleves.jpg", label: "le dossier de la page" },
  { chemin: "images/eleves.jpg", label: "le sous-dossier images" },
  { chemin: "images/Eleves.JPG", label: "le sous-dossier images, autre casse" },
  { chemin: "../eleves.jpg", label: "le dossier parent" },
  { chemin: "/images/eleves.jpg", label: "la racine du site" },
];

// l'image existe réellement à cet endroit, et nulle part ailleurs
const VRAI_CHEMIN = "images/eleves.jpg";

export function BaliseImage() {
  const [chemin, setChemin] = useState("eleves.jpg");
  const [largeur, setLargeur] = useState(300);
  const [hauteur, setHauteur] = useState(0);
  const [alt, setAlt] = useState<"vide" | "pauvre" | "bon">("bon");

  const trouve = chemin === VRAI_CHEMIN;
  const casse = chemin.toLowerCase() === VRAI_CHEMIN.toLowerCase() && !trouve;
  const racine = chemin.startsWith("/");

  const texteAlt =
    alt === "vide" ? "" : alt === "pauvre" ? "image" : "Élèves de Première C en salle informatique";

  const ratio = 2 / 3;
  const hauteurAuto = Math.round(largeur * ratio);
  const hReelle = hauteur === 0 ? hauteurAuto : hauteur;
  const deforme = hauteur !== 0 && Math.abs(hReelle - hauteurAuto) > 12;

  const code = `<img src="${chemin}"\n     alt="${texteAlt}"\n     width="${largeur}"${hauteur === 0 ? "" : `\n     height="${hauteur}"`}>`;

  const W = 440;
  const affL = Math.min(largeur, 300) * 0.9;
  const affH = (affL / largeur) * hReelle;
  const H = Math.round(Math.max(126, Math.min(trouve ? affH : 80, 150) + 46));

  return (
    <div className="space-y-3">
      <div className="rounded-lg border border-border bg-background p-3 space-y-1">
        <p className="text-xs font-semibold">Où se trouve réellement le fichier</p>
        <pre className="font-mono text-[11px] leading-relaxed text-muted-foreground">
          {`mon-site/
├── page.html        ← ta page
├── images/
│   └── eleves.jpg   ← l'image, ici et nulle part ailleurs
└── css/`}
        </pre>
      </div>

      <Choice<string>
        label="Chemin écrit dans src"
        value={chemin}
        options={ARBO.map((a) => ({ value: a.chemin, label: a.chemin }))}
        onChange={setChemin}
      />

      <Panel>
        <Ctrl
          label="width"
          value={largeur}
          min={60}
          max={600}
          step={10}
          onChange={setLargeur}
          display={`${largeur} px`}
        />
        <Ctrl
          label="height"
          value={hauteur}
          min={0}
          max={500}
          step={10}
          onChange={setHauteur}
          display={hauteur === 0 ? "non donné" : `${hauteur} px`}
          color={deforme ? PALETTE.red : PALETTE.green}
        />
      </Panel>

      <Choice<"vide" | "pauvre" | "bon">
        label="Texte de remplacement"
        value={alt}
        options={[
          { value: "vide", label: "alt absent" },
          { value: "pauvre", label: 'alt="image"' },
          { value: "bon", label: "alt descriptif" },
        ]}
        onChange={setAlt}
      />

      <Board width={W} height={H}>
        <rect width={W} height={H} fill="#ffffff" />
        {trouve ? (
          <>
            <rect
              x={(W - affL) / 2}
              y={(H - Math.min(affH, 150)) / 2}
              width={affL}
              height={Math.min(affH, 150)}
              rx={3}
              fill="#bfdbfe"
              stroke="#2563eb"
              strokeWidth={1.4}
            />
            <text x={W / 2} y={H / 2} textAnchor="middle" fontSize={11} fill="#1e3a8a">
              {deforme ? "l'image, déformée" : "l'image s'affiche"}
            </text>
            <text x={W / 2} y={H - 10} textAnchor="middle" fontSize={9} fill={PALETTE.slate}>
              {largeur} × {hReelle} px
            </text>
          </>
        ) : (
          <>
            <rect
              x={(W - affL) / 2}
              y={(H - 80) / 2}
              width={affL}
              height={80}
              rx={3}
              fill="#f1f5f9"
              stroke="#94a3b8"
              strokeWidth={1.4}
              strokeDasharray="5 4"
            />
            <text
              x={W / 2}
              y={H / 2 - 4}
              textAnchor="middle"
              fontSize={11}
              fontWeight={700}
              fill="#b91c1c"
            >
              {texteAlt === "" ? "(aucun texte de remplacement)" : texteAlt}
            </text>
            <text x={W / 2} y={H / 2 + 14} textAnchor="middle" fontSize={9} fill={PALETTE.slate}>
              le fichier n&apos;est pas à cet endroit
            </text>
          </>
        )}
      </Board>

      <pre className="overflow-x-auto rounded-lg border border-border bg-secondary/30 p-2.5 font-mono text-[11px] leading-relaxed">
        {code}
      </pre>

      <Panel>
        <Stat
          label="Image trouvée"
          value={trouve ? "oui" : "non"}
          color={trouve ? PALETTE.green : PALETTE.red}
        />
        <Stat
          label="Proportions"
          value={deforme ? "déformée" : "respectées"}
          color={deforme ? PALETTE.red : PALETTE.green}
        />
      </Panel>

      {!trouve && casse ? (
        <Verdict tone="bad">
          Le chemin est bon mais la casse ne l&apos;est pas : sur le web, <code>Eleves.JPG</code> et{" "}
          <code>eleves.jpg</code> sont deux noms différents. Prends l&apos;habitude de tout nommer
          en minuscules, sans espaces ni accents.
        </Verdict>
      ) : !trouve && racine ? (
        <Verdict tone="bad">
          La barre oblique initiale part de la <strong>racine du site</strong>, pas du dossier de ta
          page. Ce n&apos;est pas la même chose : enlève-la.
        </Verdict>
      ) : !trouve ? (
        <Verdict tone="bad">
          L&apos;image n&apos;est pas là. Un chemin faux est la première cause d&apos;image qui ne
          s&apos;affiche pas — et c&apos;est justement dans ce cas que l&apos;attribut{" "}
          <code>alt</code> rend service.
        </Verdict>
      ) : deforme ? (
        <Verdict tone="bad">
          L&apos;image est déformée : tu as donné les deux dimensions, et elles ne respectent pas
          ses proportions. Remets height à « non donné » — le navigateur calculera la hauteur tout
          seul.
        </Verdict>
      ) : (
        <Verdict tone="ok">
          L&apos;image s&apos;affiche, proportions respectées, avec un <code>alt</code> descriptif.
          {alt !== "bon"
            ? " Mets maintenant un alt vraiment descriptif : « image » n'apprend rien à un visiteur aveugle, et rien non plus quand le fichier manque."
            : ""}
        </Verdict>
      )}
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Chapitre 14 — Fabriquer des liens                                   */
/* ------------------------------------------------------------------ */

type Besoin = { titre: string; bon: string; candidats: ReadonlyArray<string>; note: string };

const BESOINS: ReadonlyArray<Besoin> = [
  {
    titre: "Un lien vers la page exercices.html, rangée dans le même dossier.",
    bon: "exercices.html",
    candidats: ["exercices.html", "https://exercices.html", "/exercices.html", "#exercices"],
    note: "Juste le nom du fichier : ni https://, ni barre oblique initiale — celle-ci partirait de la racine du site.",
  },
  {
    titre: "Un lien vers le site externe www.mandal.cm.",
    bon: "https://www.mandal.cm",
    candidats: ["www.mandal.cm", "https://www.mandal.cm", "/www.mandal.cm", "mailto:www.mandal.cm"],
    note: "Le https:// est obligatoire. Sans lui, le navigateur chercherait un fichier nommé www.mandal.cm dans ton dossier.",
  },
  {
    titre: "Un lien vers la section de cette même page qui porte id=« corrige ».",
    bon: "#corrige",
    candidats: ["corrige", "#corrige", "corrige.html", "https://#corrige"],
    note: "Le dièse est indispensable, et la destination doit bien porter id=« corrige » quelque part dans la page.",
  },
  {
    titre: "Un lien qui ouvre la messagerie vers prof@mandal.cm.",
    bon: "mailto:prof@mandal.cm",
    candidats: [
      "prof@mandal.cm",
      "mailto:prof@mandal.cm",
      "mailto://prof@mandal.cm",
      "mail:prof@mandal.cm",
    ],
    note: "mailto: est collé à l'adresse, sans espace et sans barres obliques.",
  },
];

const BESOIN_DEFAUT: Besoin = { titre: "", bon: "", candidats: [], note: "" };

export function BaliseLien() {
  const [i, setI] = useState(0);
  const [rep, setRep] = useState<Record<number, string>>({});
  const [nouvelOnglet, setNouvelOnglet] = useState(false);

  const b = BESOINS[i] ?? BESOIN_DEFAUT;
  const r = rep[i];
  const juste = r === b.bon;
  const bons = BESOINS.filter((q, k) => rep[k] === q.bon).length;

  const code =
    r === undefined
      ? '<a href="…">Le texte cliquable</a>'
      : `<a href="${r}"${nouvelOnglet ? ' target="_blank"' : ""}>Le texte cliquable</a>`;

  return (
    <div className="space-y-3">
      <div className="rounded-lg border border-border bg-secondary/30 px-3 py-2.5">
        <p className="text-[11px] text-muted-foreground">
          Lien {i + 1} sur {BESOINS.length}
        </p>
        <p className="text-sm font-medium">{b.titre}</p>
      </div>

      <Choice<string>
        label="Valeur de href"
        value={r ?? ""}
        options={b.candidats.map((c) => ({ value: c, label: c }))}
        onChange={(v) => setRep({ ...rep, [i]: v })}
      />

      <pre className="overflow-x-auto rounded-lg border border-border bg-secondary/30 p-2.5 font-mono text-[11px]">
        {code}
      </pre>

      {r !== undefined ? <RenduHtml source={code} /> : null}

      <Panel>
        <Stat label="Liens corrects" value={`${bons} / ${BESOINS.length}`} color={PALETTE.green} />
        <Stat
          label="Ce lien"
          value={r === undefined ? "à faire" : juste ? "correct" : "faux"}
          color={juste ? PALETTE.green : PALETTE.red}
        />
      </Panel>

      {r === undefined ? (
        <Verdict tone="warn">
          Le texte entre les deux balises est ce que le visiteur voit et clique ; l&apos;adresse est
          dans <code>href</code> et n&apos;est jamais visible.
        </Verdict>
      ) : juste ? (
        <Verdict tone="ok">Exact. {b.note}</Verdict>
      ) : (
        <Verdict tone="bad">
          Non : il fallait <code>{b.bon}</code>. {b.note}
        </Verdict>
      )}

      <button
        type="button"
        onClick={() => setNouvelOnglet(!nouvelOnglet)}
        className={
          nouvelOnglet
            ? "rounded-lg bg-primary px-3 py-1.5 text-xs font-semibold text-primary-foreground"
            : "rounded-lg border border-border bg-background px-3 py-1.5 text-xs font-medium text-muted-foreground hover:bg-secondary/60"
        }
      >
        {nouvelOnglet ? 'Retirer target="_blank"' : 'Ajouter target="_blank"'}
      </button>

      {nouvelOnglet ? (
        <Verdict tone="warn">
          Le lien s&apos;ouvrira dans un nouvel onglet. C&apos;est le bon réflexe pour les liens{" "}
          <strong>externes</strong>, afin que le visiteur ne perde pas ta page — et inutile, voire
          agaçant, pour les liens internes à ton propre site.
        </Verdict>
      ) : null}

      <button
        type="button"
        onClick={() => setI((v) => (v + 1) % BESOINS.length)}
        className="rounded-lg bg-primary px-3 py-1.5 text-xs font-semibold text-primary-foreground"
      >
        Lien suivant
      </button>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Chapitre 15 — Construire des listes                                 */
/* ------------------------------------------------------------------ */

type GenreListe = "ul" | "ol" | "dl";

const ENUMERATIONS: ReadonlyArray<{
  titre: string;
  items: ReadonlyArray<string>;
  bon: GenreListe;
  note: string;
}> = [
  {
    titre: "Le sommaire des trois modules du programme",
    items: [
      "Maintenance informatique",
      "Algorithmique et programmation",
      "Infographie et multimédia",
    ],
    bon: "ul",
    note: "L'ordre des modules n'impose rien : des puces suffisent.",
  },
  {
    titre: "Les étapes du démontage d'une unité centrale",
    items: [
      "Éteindre la machine",
      "Débrancher le câble",
      "Ouvrir le boîtier",
      "Mettre le bracelet antistatique",
    ],
    bon: "ol",
    note: "L'ordre est capital — mettre le bracelet après avoir touché les composants ne sert à rien. Et les numéros sont ajoutés par le navigateur.",
  },
  {
    titre: "Un glossaire : RAM, POST",
    items: ["RAM", "POST"],
    bon: "dl",
    note: "Un terme, sa définition : c'est exactement la liste de définitions.",
  },
];

const ENUM_DEFAUT = ENUMERATIONS[0] ?? { titre: "", items: [], bon: "ul" as GenreListe, note: "" };

const DEFINITIONS: Record<string, string> = {
  RAM: "Mémoire vive, volatile, qui perd son contenu hors tension.",
  POST: "Séquence de tests des composants au démarrage.",
};

export function ListesHtml() {
  const [i, setI] = useState(0);
  const [genre, setGenre] = useState<GenreListe>("ul");
  const [sousListe, setSousListe] = useState<"dedans" | "dehors">("dedans");

  const e = ENUMERATIONS[i] ?? ENUM_DEFAUT;
  const juste = genre === e.bon;

  const source =
    genre === "dl"
      ? `<dl>\n${e.items.map((it) => `  <dt>${it}</dt>\n  <dd>${DEFINITIONS[it] ?? "sa définition"}</dd>`).join("\n")}\n</dl>`
      : `<${genre}>\n${e.items.map((it) => `  <li>${it}</li>`).join("\n")}\n</${genre}>`;

  const sourceImbrique =
    sousListe === "dedans"
      ? `<ol>\n  <li>Les virus et les antivirus\n    <ul>\n      <li>Les virus</li>\n      <li>Les antivirus</li>\n    </ul>\n  </li>\n  <li>Optimiser un ordinateur</li>\n</ol>`
      : `<ol>\n  <li>Les virus et les antivirus</li>\n    <ul>\n      <li>Les virus</li>\n      <li>Les antivirus</li>\n    </ul>\n  <li>Optimiser un ordinateur</li>\n</ol>`;

  return (
    <div className="space-y-3">
      <div className="rounded-lg border border-border bg-secondary/30 px-3 py-2.5">
        <p className="text-[11px] text-muted-foreground">
          Énumération {i + 1} sur {ENUMERATIONS.length}
        </p>
        <p className="text-sm font-medium">{e.titre}</p>
        <p className="mt-1 text-xs text-muted-foreground">{e.items.join(" · ")}</p>
      </div>

      <Choice<GenreListe>
        label="Quelle liste ?"
        value={genre}
        options={[
          { value: "ul", label: "<ul> à puces" },
          { value: "ol", label: "<ol> numérotée" },
          { value: "dl", label: "<dl> définitions" },
        ]}
        onChange={setGenre}
      />

      <pre className="overflow-x-auto rounded-lg border border-border bg-secondary/30 p-2.5 font-mono text-[11px] leading-relaxed">
        {source}
      </pre>

      <RenduHtml source={source} />

      {juste ? (
        <Verdict tone="ok">Bon choix. {e.note}</Verdict>
      ) : (
        <Verdict tone="bad">
          Ici il faut une liste <code>&lt;{e.bon}&gt;</code>. {e.note}
        </Verdict>
      )}

      <button
        type="button"
        onClick={() => setI((v) => (v + 1) % ENUMERATIONS.length)}
        className="rounded-lg bg-primary px-3 py-1.5 text-xs font-semibold text-primary-foreground"
      >
        Énumération suivante
      </button>

      <div className="rounded-lg border border-border bg-background p-3 space-y-2">
        <p className="text-xs font-semibold">Où placer une sous-liste ?</p>
        <Choice<"dedans" | "dehors">
          value={sousListe}
          options={[
            { value: "dedans", label: "Dans le <li>" },
            { value: "dehors", label: "Entre deux <li>" },
          ]}
          onChange={setSousListe}
        />
        <pre className="overflow-x-auto rounded-lg border border-border bg-secondary/30 p-2.5 font-mono text-[11px] leading-relaxed">
          {sourceImbrique}
        </pre>
        <RenduHtml source={sourceImbrique} />
        {sousListe === "dedans" ? (
          <Verdict tone="ok">
            La sous-liste est <strong>dans</strong> le li, qui ne se ferme qu&apos;après elle. «
            Optimiser un ordinateur » porte bien le numéro 2, à la suite du 1.
          </Verdict>
        ) : (
          <Verdict tone="bad">
            Le li s&apos;est fermé trop tôt, et la sous-liste se retrouve posée directement dans le
            ol — ce qui est interdit : un ul ou un ol ne contient que des li. Regarde la
            numérotation de la suite, elle ne tient plus.
          </Verdict>
        )}
      </div>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Chapitre 15 — Construire un tableau                                 */
/* ------------------------------------------------------------------ */

const ENTETES = ["Matière", "Note", "Coefficient", "Appréciation"];
const DONNEES = [
  ["Informatique", "16", "2", "Très bien"],
  ["Mathématiques", "13", "5", "Bien"],
  ["Physique", "11,5", "4", "Assez bien"],
  ["Français", "14", "3", "Bien"],
];

export function TableauxHtml() {
  const [lignes, setLignes] = useState(3);
  const [colonnes, setColonnes] = useState(3);
  const [bord, setBord] = useState(1);
  const [pad, setPad] = useState(6);
  const [esp, setEsp] = useState(2);
  const [total, setTotal] = useState(false);

  const nl = clamp(Math.round(lignes), 1, 4);
  const nc = clamp(Math.round(colonnes), 1, 4);

  const entete = `  <tr>\n${ENTETES.slice(0, nc)
    .map((h) => `    <th>${h}</th>`)
    .join("\n")}\n  </tr>`;
  const corps = DONNEES.slice(0, nl)
    .map(
      (r) =>
        `  <tr>\n${r
          .slice(0, nc)
          .map((c) => `    <td>${c}</td>`)
          .join("\n")}\n  </tr>`,
    )
    .join("\n");
  const pied = total
    ? `  <tr>\n    <td colspan="${nc}">Moyenne générale : 13,83</td>\n  </tr>`
    : "";

  const source = `<table border="${bord}" cellpadding="${pad}" cellspacing="${esp}">\n  <caption>Mes notes du premier trimestre</caption>\n${entete}\n${corps}${total ? "\n" + pied : ""}\n</table>`;

  const cellules = nc * (nl + 1) + (total ? 1 : 0);

  return (
    <div className="space-y-3">
      <Panel>
        <Ctrl
          label="Lignes de données"
          value={nl}
          min={1}
          max={4}
          step={1}
          onChange={setLignes}
          display={`${nl}`}
        />
        <Ctrl
          label="Colonnes"
          value={nc}
          min={1}
          max={4}
          step={1}
          onChange={setColonnes}
          display={`${nc}`}
          color={PALETTE.orange}
        />
      </Panel>

      <Panel>
        <Ctrl
          label="border"
          value={bord}
          min={0}
          max={6}
          step={1}
          onChange={setBord}
          display={`${bord} px`}
        />
        <Ctrl
          label="cellpadding — l'espace DEDANS"
          value={pad}
          min={0}
          max={20}
          step={1}
          onChange={setPad}
          display={`${pad} px`}
          color={PALETTE.green}
        />
      </Panel>

      <Ctrl
        label="cellspacing — l'espace ENTRE les cellules"
        value={esp}
        min={0}
        max={20}
        step={1}
        onChange={setEsp}
        display={`${esp} px`}
        color={PALETTE.purple}
      />

      <div
        className="rounded-lg border border-border bg-white p-3 text-slate-900"
        style={{ ["--pad" as string]: `${pad}px` }}
      >
        <table
          style={{
            borderCollapse: "separate",
            borderSpacing: esp,
            border: bord > 0 ? `${bord}px solid #334155` : "none",
            fontSize: 12,
          }}
        >
          <caption style={{ captionSide: "top", fontWeight: 700, fontSize: 12, paddingBottom: 4 }}>
            Mes notes du premier trimestre
          </caption>
          <tbody>
            <tr>
              {ENTETES.slice(0, nc).map((h) => (
                <th
                  key={h}
                  style={{
                    border: bord > 0 ? `${bord}px solid #94a3b8` : "1px solid #e2e8f0",
                    padding: pad,
                    background: "#f1f5f9",
                  }}
                >
                  {h}
                </th>
              ))}
            </tr>
            {DONNEES.slice(0, nl).map((r, k) => (
              <tr key={k}>
                {r.slice(0, nc).map((c, j) => (
                  <td
                    key={j}
                    style={{
                      border: bord > 0 ? `${bord}px solid #94a3b8` : "1px solid #e2e8f0",
                      padding: pad,
                    }}
                  >
                    {c}
                  </td>
                ))}
              </tr>
            ))}
            {total ? (
              <tr>
                <td
                  colSpan={nc}
                  style={{
                    border: bord > 0 ? `${bord}px solid #94a3b8` : "1px solid #e2e8f0",
                    padding: pad,
                    fontWeight: 700,
                  }}
                >
                  Moyenne générale : 13,83
                </td>
              </tr>
            ) : null}
          </tbody>
        </table>
      </div>

      <button
        type="button"
        onClick={() => setTotal(!total)}
        className={
          total
            ? "rounded-lg bg-primary px-3 py-1.5 text-xs font-semibold text-primary-foreground"
            : "rounded-lg border border-border bg-background px-3 py-1.5 text-xs font-medium text-muted-foreground hover:bg-secondary/60"
        }
      >
        {total ? "Retirer la ligne de total" : `Ajouter une ligne de total avec colspan="${nc}"`}
      </button>

      <pre className="overflow-x-auto rounded-lg border border-border bg-secondary/30 p-2.5 font-mono text-[11px] leading-relaxed">
        {source}
      </pre>

      <Panel>
        <Stat label="Balises tr" value={`${nl + 1 + (total ? 1 : 0)}`} />
        <Stat label="Cellules" value={`${cellules}`} color={PALETTE.blue} />
      </Panel>

      {total ? (
        <Verdict tone="ok">
          La dernière ligne ne contient plus qu&apos;<strong>une seule</strong> cellule, étendue sur{" "}
          {nc} colonnes par <code>colspan=&quot;{nc}&quot;</code>. Change le nombre de colonnes : le
          colspan suit, parce qu&apos;il doit toujours valoir le nombre de colonnes du tableau.
        </Verdict>
      ) : bord === 0 ? (
        <Verdict tone="warn">
          Avec <code>border=&quot;0&quot;</code> le tableau n&apos;a plus de cadre et devient
          difficile à lire. Monte la bordure, puis compare <code>cellpadding</code>, qui gonfle
          l&apos;intérieur de chaque cellule, et <code>cellspacing</code>, qui écarte les cellules
          entre elles.
        </Verdict>
      ) : (
        <Verdict tone="ok">
          {nl + 1} lignes de {nc} cellules, soit {nc * (nl + 1)} cellules — compte toujours ligne
          par ligne. Et retiens que les cellules vivent toujours dans un <code>tr</code>, jamais
          directement dans le <code>table</code>.
        </Verdict>
      )}
    </div>
  );
}
