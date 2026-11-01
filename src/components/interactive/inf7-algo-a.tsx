import { useState } from "react";
import { Choice, Ctrl, PALETTE, Panel, Stat, Verdict } from "./controls";
import { Cases, Code } from "./inf7-noyau";

/** Informatique Terminale C et D — chapitre 19 : les structures de contrôle. */

/* ------------------------------------------------------------------ */
/* Chapitre 19 — Reconnaître la famille                                */
/* ------------------------------------------------------------------ */

const FRAGMENTS = [
  {
    code: ["lire(x)", "y ← x * 2", "écrire(y)"],
    famille: "seq",
    mot: "Trois instructions, exécutées dans l'ordre, toutes et une seule fois.",
    trace: (x: number) => [`x ← ${x}`, `y ← ${x * 2}`, `affiche ${x * 2}`],
  },
  {
    code: ["Si x >= 10 alors", "    écrire(« Admis »)", "Finsi"],
    famille: "alt",
    mot: "Un seul chemin, et il peut ne rien se passer du tout si la condition est fausse.",
    trace: (x: number) => [
      `x = ${x}`,
      x >= 10 ? "condition vraie → affiche Admis" : "condition fausse → rien",
    ],
  },
  {
    code: [
      "Si x >= 10 alors",
      "    écrire(« Admis »)",
      "Sinon",
      "    écrire(« Ajourné »)",
      "Finsi",
    ],
    famille: "alt",
    mot: "Un des deux blocs s'exécute, jamais les deux.",
    trace: (x: number) => [`x = ${x}`, x >= 10 ? "affiche Admis" : "affiche Ajourné"],
  },
  {
    code: ["i ← 1", "TantQue i <= 5 faire", "    écrire(i)", "    i ← i + 1", "FinTantQue"],
    famille: "rep",
    mot: "Le bloc se répète tant que la condition est vraie : c'est une boucle.",
    trace: () => ["i ← 1", "affiche 1, 2, 3, 4, 5", "i vaut 6, on sort"],
  },
  {
    code: ["Pour i de 1 à n faire", "    somme ← somme + t[i]", "FinPour"],
    famille: "rep",
    mot: "Le compteur est géré automatiquement, mais c'est bien une répétition.",
    trace: (x: number) => [`n = ${x}`, `${x} tours`, "somme accumulée"],
  },
  {
    code: ["Répéter", "    lire(note)", "Jusqu'à (note >= 0) et (note <= 20)"],
    famille: "rep",
    mot: "Répétitive aussi, mais testée à la fin : elle fait toujours au moins un tour.",
    trace: () => ["au moins une saisie", "on sort quand la note est valide"],
  },
  {
    code: [
      "Selon jour faire",
      "    1 : écrire(« Lundi »)",
      "    2 : écrire(« Mardi »)",
      "    Autre : écrire(« ? »)",
      "FinSelon",
    ],
    famille: "alt",
    mot: "Le Selon est une alternative : il choisit UN chemin parmi plusieurs.",
    trace: (x: number) => [
      `jour = ${x}`,
      x === 1 ? "affiche Lundi" : x === 2 ? "affiche Mardi" : "affiche ?",
    ],
  },
  {
    code: ["somme ← 0", "moyenne ← 0", "n ← 0"],
    famille: "seq",
    mot: "Trois initialisations à la suite : séquence pure.",
    trace: () => ["somme ← 0", "moyenne ← 0", "n ← 0"],
  },
  {
    code: [
      "Si moy >= 16 alors",
      "    écrire(« TB »)",
      "Sinon",
      "    Si moy >= 14 alors",
      "        écrire(« B »)",
      "    Finsi",
      "Finsi",
    ],
    famille: "alt",
    mot: "Des alternatives imbriquées : cela reste de l'alternative.",
    trace: (x: number) => [`moy = ${x}`, x >= 16 ? "affiche TB" : x >= 14 ? "affiche B" : "rien"],
  },
  {
    code: [
      "Pour i de 1 à 3 faire",
      "    Pour j de 1 à 3 faire",
      "        écrire(i, j)",
      "    FinPour",
      "FinPour",
    ],
    famille: "rep",
    mot: "Deux boucles imbriquées : neuf affichages. Répétitive.",
    trace: () => ["3 × 3 = 9 affichages"],
  },
  {
    code: ["trouve ← faux", "i ← 1"],
    famille: "seq",
    mot: "Deux affectations : séquence. Ce sont les initialisations d'une recherche, mais la boucle n'est pas encore là.",
    trace: () => ["trouve ← faux", "i ← 1"],
  },
  {
    code: [
      "TantQue (i <= n) et (trouve = faux) faire",
      "    Si t[i] = x alors",
      "        trouve ← vrai",
      "    Sinon",
      "        i ← i + 1",
      "    Finsi",
      "FinTantQue",
    ],
    famille: "rep",
    mot: "Une répétitive qui contient une alternative. On classe toujours d'après la structure la PLUS EXTÉRIEURE.",
    trace: () => ["la boucle tourne", "jusqu'à trouver ou épuiser le tableau"],
  },
] as const;

const FAMILLES = [
  { value: "seq", label: "Séquentielle" },
  { value: "alt", label: "Alternative" },
  { value: "rep", label: "Répétitive" },
] as const;

export function FamillesStructures() {
  const [k, setK] = useState(0);
  const [rep, setRep] = useState<string | null>(null);
  const [x, setX] = useState(12);

  const f = FRAGMENTS[k] ?? FRAGMENTS[0];
  const juste = rep === f.famille;

  return (
    <div className="space-y-3">
      <p className="text-[11px] text-muted-foreground">
        Fragment {k + 1} sur {FRAGMENTS.length}
      </p>

      <Code lignes={f.code} />

      <Choice<string>
        label="De quelle famille relève ce fragment ?"
        value={rep ?? ""}
        options={FAMILLES.map((x2) => ({ value: x2.value, label: x2.label }))}
        onChange={setRep}
      />

      {rep === null ? (
        <Verdict tone="warn">
          Trois questions : les instructions s&apos;exécutent-elles toutes dans l&apos;ordre
          (séquentielle) ? y a-t-il un choix entre des chemins (alternative) ? un bloc revient-il en
          arrière (répétitive) ?
        </Verdict>
      ) : juste ? (
        <Verdict tone="ok">Exact. {f.mot}</Verdict>
      ) : (
        <Verdict tone="bad">
          Non, c&apos;est {FAMILLES.find((y) => y.value === f.famille)?.label.toLowerCase() ?? ""}.{" "}
          {f.mot}
        </Verdict>
      )}

      {/* L'organigramme */}
      <OrganigrammeFamille famille={f.famille} />

      <div className="space-y-2 border-t border-border pt-3">
        <Ctrl
          label="Valeur d'essai"
          value={x}
          min={0}
          max={20}
          step={1}
          onChange={setX}
          display={`${x}`}
        />
        <div className="space-y-0.5 rounded-lg border border-border bg-background p-2.5">
          <p className="text-xs font-semibold">Chemin d&apos;exécution</p>
          {f.trace(x).map((l, i) => (
            <p key={`${i}-${l}`} className="font-mono text-[11px] text-muted-foreground">
              {i + 1}. {l}
            </p>
          ))}
        </div>
      </div>

      <div className="flex gap-2">
        <button
          type="button"
          onClick={() => {
            setK((v) => (v + FRAGMENTS.length - 1) % FRAGMENTS.length);
            setRep(null);
          }}
          className="rounded-lg border border-border bg-background px-3 py-1.5 text-xs font-medium text-muted-foreground hover:bg-secondary/60"
        >
          Précédent
        </button>
        <button
          type="button"
          onClick={() => {
            setK((v) => (v + 1) % FRAGMENTS.length);
            setRep(null);
          }}
          className="rounded-lg bg-primary px-3 py-1.5 text-xs font-semibold text-primary-foreground"
        >
          Fragment suivant
        </button>
      </div>
    </div>
  );
}

function OrganigrammeFamille({ famille }: { famille: string }) {
  if (famille === "seq") {
    return (
      <svg
        viewBox="0 0 300 150"
        width="100%"
        className="rounded-lg border border-border bg-background"
      >
        <rect
          x={100}
          y={14}
          width={100}
          height={26}
          rx={3}
          fill="#dbeafe"
          stroke="#2563eb"
          strokeWidth={1.5}
        />
        <text x={150} y={31} textAnchor="middle" fontSize={10} fill="#1e3a8a">
          instruction 1
        </text>
        <line x1={150} y1={40} x2={150} y2={56} stroke="#334155" strokeWidth={1.6} />
        <polygon points="150,62 145,52 155,52" fill="#334155" />
        <rect
          x={100}
          y={62}
          width={100}
          height={26}
          rx={3}
          fill="#dbeafe"
          stroke="#2563eb"
          strokeWidth={1.5}
        />
        <text x={150} y={79} textAnchor="middle" fontSize={10} fill="#1e3a8a">
          instruction 2
        </text>
        <line x1={150} y1={88} x2={150} y2={104} stroke="#334155" strokeWidth={1.6} />
        <polygon points="150,110 145,100 155,100" fill="#334155" />
        <rect
          x={100}
          y={110}
          width={100}
          height={26}
          rx={3}
          fill="#dbeafe"
          stroke="#2563eb"
          strokeWidth={1.5}
        />
        <text x={150} y={127} textAnchor="middle" fontSize={10} fill="#1e3a8a">
          instruction 3
        </text>
      </svg>
    );
  }
  if (famille === "alt") {
    return (
      <svg
        viewBox="0 0 320 160"
        width="100%"
        className="rounded-lg border border-border bg-background"
      >
        <polygon
          points="160,14 220,46 160,78 100,46"
          fill="#dcfce7"
          stroke="#15803d"
          strokeWidth={1.6}
        />
        <text x={160} y={50} textAnchor="middle" fontSize={10} fill="#14532d">
          condition ?
        </text>
        <line x1={100} y1={46} x2={60} y2={46} stroke="#334155" strokeWidth={1.4} />
        <line x1={60} y1={46} x2={60} y2={100} stroke="#334155" strokeWidth={1.4} />
        <line x1={220} y1={46} x2={260} y2={46} stroke="#334155" strokeWidth={1.4} />
        <line x1={260} y1={46} x2={260} y2={100} stroke="#334155" strokeWidth={1.4} />
        <text x={70} y={40} fontSize={9} fill="#b91c1c">
          non
        </text>
        <text x={230} y={40} fontSize={9} fill="#15803d">
          oui
        </text>
        <rect
          x={20}
          y={100}
          width={80}
          height={26}
          rx={3}
          fill="#fee2e2"
          stroke="#b91c1c"
          strokeWidth={1.4}
        />
        <text x={60} y={117} textAnchor="middle" fontSize={10} fill="#7f1d1d">
          bloc sinon
        </text>
        <rect
          x={220}
          y={100}
          width={80}
          height={26}
          rx={3}
          fill="#dcfce7"
          stroke="#15803d"
          strokeWidth={1.4}
        />
        <text x={260} y={117} textAnchor="middle" fontSize={10} fill="#14532d">
          bloc alors
        </text>
        <line x1={60} y1={126} x2={60} y2={146} stroke="#334155" strokeWidth={1.4} />
        <line x1={260} y1={126} x2={260} y2={146} stroke="#334155" strokeWidth={1.4} />
        <line x1={60} y1={146} x2={260} y2={146} stroke="#334155" strokeWidth={1.4} />
        <text x={160} y={158} textAnchor="middle" fontSize={9} fill="#64748b">
          les deux chemins se rejoignent
        </text>
      </svg>
    );
  }
  return (
    <svg
      viewBox="0 0 320 160"
      width="100%"
      className="rounded-lg border border-border bg-background"
    >
      <polygon
        points="160,14 216,44 160,74 104,44"
        fill="#fef3c7"
        stroke="#ca8a04"
        strokeWidth={1.6}
      />
      <text x={160} y={48} textAnchor="middle" fontSize={10} fill="#78350f">
        condition ?
      </text>
      <line x1={160} y1={74} x2={160} y2={92} stroke="#334155" strokeWidth={1.6} />
      <polygon points="160,98 155,88 165,88" fill="#334155" />
      <rect
        x={110}
        y={98}
        width={100}
        height={26}
        rx={3}
        fill="#fef3c7"
        stroke="#ca8a04"
        strokeWidth={1.5}
      />
      <text x={160} y={115} textAnchor="middle" fontSize={10} fill="#78350f">
        corps de boucle
      </text>
      <path
        d="M 210 111 L 268 111 L 268 44 L 216 44"
        fill="none"
        stroke="#ca8a04"
        strokeWidth={1.8}
      />
      <polygon points="216,44 226,39 226,49" fill="#ca8a04" />
      <text x={276} y={80} fontSize={9} fill="#ca8a04">
        retour
      </text>
      <line x1={104} y1={44} x2={60} y2={44} stroke="#334155" strokeWidth={1.4} />
      <text x={66} y={38} fontSize={9} fill="#b91c1c">
        non
      </text>
      <text x={160} y={150} textAnchor="middle" fontSize={9} fill="#64748b">
        la flèche de retour est la signature d&apos;une répétitive
      </text>
    </svg>
  );
}

/* ------------------------------------------------------------------ */
/* Chapitre 19 — Les Si imbriqués des mentions                         */
/* ------------------------------------------------------------------ */

type Test = { seuil: number; mention: string };

const ORDRE_BON: Test[] = [
  { seuil: 16, mention: "Très bien" },
  { seuil: 14, mention: "Bien" },
  { seuil: 12, mention: "Assez bien" },
  { seuil: 10, mention: "Passable" },
];

export function AlternativesLda() {
  const [tests, setTests] = useState<Test[]>(ORDRE_BON);
  const [note, setNote] = useState(18);
  const [volet, setVolet] = useState<"si" | "selon">("si");

  const premierVrai = tests.findIndex((t) => note >= t.seuil);
  const mention = premierVrai >= 0 ? (tests[premierVrai]?.mention ?? "") : "Ajourné";
  const attendue = ORDRE_BON.find((t) => note >= t.seuil)?.mention ?? "Ajourné";
  const faux = mention !== attendue;

  const monter = (i: number) => {
    if (i === 0) return;
    const t = [...tests];
    const a = t[i];
    const b = t[i - 1];
    if (!a || !b) return;
    t[i - 1] = a;
    t[i] = b;
    setTests(t);
  };

  return (
    <div className="space-y-3">
      <Choice<"si" | "selon">
        label="Écriture"
        value={volet}
        options={[
          { value: "si", label: "Si imbriqués" },
          { value: "selon", label: "Selon" },
        ]}
        onChange={setVolet}
      />

      {volet === "si" ? (
        <>
          <Ctrl
            label="Note saisie"
            value={note}
            min={0}
            max={20}
            step={0.5}
            onChange={setNote}
            display={note.toLocaleString("fr-FR")}
          />

          <div className="space-y-1">
            <p className="text-xs font-medium text-muted-foreground">
              Réordonne les tests avec les flèches
            </p>
            {tests.map((t, i) => {
              const atteint = i <= premierVrai || premierVrai < 0;
              const gagnant = i === premierVrai;
              return (
                <div
                  key={t.mention}
                  className={
                    gagnant
                      ? "flex items-center gap-2 rounded-lg border-2 border-emerald-500 bg-emerald-500/10 px-2.5 py-1.5"
                      : atteint
                        ? "flex items-center gap-2 rounded-lg border border-amber-500/40 bg-amber-500/5 px-2.5 py-1.5"
                        : "flex items-center gap-2 rounded-lg border border-border bg-background px-2.5 py-1.5 opacity-50"
                  }
                >
                  <button
                    type="button"
                    onClick={() => monter(i)}
                    disabled={i === 0}
                    className="text-xs text-muted-foreground disabled:opacity-30"
                  >
                    ▲
                  </button>
                  <span className="flex-1 font-mono text-[11px]">
                    Si moy &gt;= {t.seuil} alors écrire(« {t.mention} »)
                  </span>
                  <span
                    className="font-mono text-[10px] font-semibold"
                    style={{
                      color: gagnant ? PALETTE.green : atteint ? PALETTE.orange : PALETTE.slate,
                    }}
                  >
                    {!atteint ? "jamais atteint" : note >= t.seuil ? "VRAI" : "faux"}
                  </span>
                </div>
              );
            })}
            <div className="rounded-lg border border-border bg-background px-2.5 py-1.5">
              <span className="font-mono text-[11px]">Sinon écrire(« Ajourné »)</span>
            </div>
          </div>

          <Panel>
            <Stat
              label="Mention affichée"
              value={mention}
              color={faux ? PALETTE.red : PALETTE.green}
            />
            <Stat label="Mention correcte" value={attendue} />
          </Panel>

          {faux ? (
            <Verdict tone="bad">
              L&apos;algorithme affiche « {mention} » pour une note de{" "}
              {note.toLocaleString("fr-FR")}, alors qu&apos;il faudrait « {attendue} ». La raison
              est dans l&apos;ordre : <strong>le premier test qui réussit l&apos;emporte</strong>,
              et les suivants ne sont jamais atteints. Il faut aller{" "}
              <strong>du plus exigeant au moins exigeant</strong>. Remets 16 en premier.
            </Verdict>
          ) : note >= 10 ? (
            <Verdict tone="ok">
              Ordre correct : {mention}. Maintenant fais remonter le test de 10 tout en haut, laisse
              la note à 18, et regarde ce que devient un excellent élève.
            </Verdict>
          ) : (
            <Verdict tone="warn">
              Aucun test ne réussit : on tombe dans le dernier Sinon. Monte la note au-dessus de 10
              pour voir la cascade fonctionner.
            </Verdict>
          )}
        </>
      ) : (
        <div className="space-y-2">
          <Code
            lignes={[
              "Selon moy faire",
              "    10..12 : écrire(« Passable »)   ← impossible",
              "    12..14 : écrire(« Assez bien »)  ← impossible",
              "    Autre  : écrire(« Ajourné »)",
              "FinSelon",
            ]}
            eclairee={1}
            tonEclairee="bad"
          />
          <Verdict tone="bad">
            Le <strong>Selon</strong> ne compare une variable qu&apos;à des{" "}
            <strong>valeurs précises</strong> : 1, 2, 3, ou &apos;A&apos;, &apos;B&apos;. Il
            n&apos;accepte <strong>aucun intervalle</strong>. Et une moyenne est un nombre réel :
            13,5 n&apos;est égal à aucune valeur énumérable.
          </Verdict>
          <Code
            lignes={[
              "Selon jour faire",
              "    1 : écrire(« Lundi »)",
              "    2 : écrire(« Mardi »)",
              "    3 : écrire(« Mercredi »)",
              "    Autre : écrire(« Numéro invalide »)",
              "FinSelon",
            ]}
          />
          <Verdict tone="ok">
            Là, le Selon est le bon choix : une variable <strong>entière</strong> comparée à des{" "}
            <strong>valeurs énumérables</strong>, et c&apos;est bien plus lisible que sept Si
            imbriqués. La question à se poser : <strong>valeurs précises ou intervalles ?</strong>
          </Verdict>
        </div>
      )}
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Chapitre 19 — Les trois boucles côte à côte                         */
/* ------------------------------------------------------------------ */

export function RepetitivesLda() {
  const [debut, setDebut] = useState(1);
  const [fin, setFin] = useState(5);
  const [progression, setProgression] = useState(true);
  const [volet, setVolet] = useState<"boucles" | "drapeau">("boucles");
  const [pasDrapeau, setPasDrapeau] = useState(0);

  // TantQue : test au début.
  const toursTantQue = progression ? Math.max(0, fin - debut + 1) : 100;
  // Répéter : test à la fin, donc au moins un tour.
  const toursRepeter = progression ? Math.max(1, fin - debut + 1) : 100;
  // Pour : le compteur est géré, pas d'infini possible.
  const toursPour = Math.max(0, fin - debut + 1);

  const TAB = [4, 9, 7, 15, 2];
  const CIBLE = 15;
  const PAS_DRAPEAU = [
    { i: 0, trouve: false, note: "trouve ← faux, i ← 1. Rien n'a encore été examiné." },
    { i: 1, trouve: false, note: "t[1] = 4, différent de 15. Le drapeau reste faux, i passe à 2." },
    { i: 2, trouve: false, note: "t[2] = 9, différent. i passe à 3." },
    { i: 3, trouve: false, note: "t[3] = 7, différent. i passe à 4." },
    {
      i: 4,
      trouve: true,
      note: "t[4] = 15 : trouvé ! Le drapeau passe à VRAI, et i NE BOUGE PAS.",
    },
    {
      i: 4,
      trouve: true,
      note: "Test de la boucle : (4 <= 5) est vrai, mais (trouve = faux) est maintenant faux. On sort, et i vaut 4 — la bonne position.",
    },
  ];
  const PD_DEFAUT = { i: 0, trouve: false, note: "" };
  const pd = PAS_DRAPEAU[pasDrapeau] ?? PD_DEFAUT;

  return (
    <div className="space-y-3">
      <Choice<"boucles" | "drapeau">
        label="Volet"
        value={volet}
        options={[
          { value: "boucles", label: "Les trois boucles" },
          { value: "drapeau", label: "La variable drapeau" },
        ]}
        onChange={setVolet}
      />

      {volet === "boucles" ? (
        <>
          <Ctrl
            label="Valeur de départ (i ←)"
            value={debut}
            min={1}
            max={10}
            step={1}
            onChange={setDebut}
            display={`${debut}`}
          />
          <Ctrl
            label="Borne de la condition (i <= …)"
            value={fin}
            min={0}
            max={10}
            step={1}
            onChange={setFin}
            display={`${fin}`}
          />
          <Choice<"oui" | "non">
            label="La ligne de progression i ← i + 1"
            value={progression ? "oui" : "non"}
            options={[
              { value: "oui", label: "Présente" },
              { value: "non", label: "Supprimée" },
            ]}
            onChange={(v) => setProgression(v === "oui")}
          />

          <div className="grid gap-2 sm:grid-cols-3">
            <BoucleVue
              titre="TantQue"
              lignes={[
                `i ← ${debut}`,
                `TantQue i <= ${fin} faire`,
                "    écrire(i)",
                progression ? "    i ← i + 1" : "    (pas de progression)",
                "FinTantQue",
              ]}
              tours={toursTantQue}
              infini={!progression}
            />
            <BoucleVue
              titre="Répéter"
              lignes={[
                `i ← ${debut}`,
                "Répéter",
                "    écrire(i)",
                progression ? "    i ← i + 1" : "    (pas de progression)",
                `Jusqu'à i > ${fin}`,
              ]}
              tours={toursRepeter}
              infini={!progression}
            />
            <BoucleVue
              titre="Pour"
              lignes={[`Pour i de ${debut} à ${fin} faire`, "    écrire(i)", "FinPour"]}
              tours={toursPour}
              infini={false}
            />
          </div>

          {!progression ? (
            <Verdict tone="bad">
              Boucle infinie détectée au centième tour sur le TantQue et le Répéter : la condition
              ne peut plus devenir fausse, puisque rien ne fait avancer{" "}
              <span className="font-mono">i</span>. Le <strong>Pour</strong>, lui, s&apos;en sort —
              son compteur est géré par la structure elle-même, et c&apos;est pour cela qu&apos;une
              boucle Pour ne peut jamais être infinie.
            </Verdict>
          ) : debut > fin ? (
            <Verdict tone="ok">
              Condition fausse dès le départ, et voilà la différence essentielle en une seconde :{" "}
              <strong>le TantQue fait 0 tour</strong>, <strong>le Répéter en fait 1</strong>.
              C&apos;est la conséquence directe du moment du test — au début pour l&apos;un, à la
              fin pour l&apos;autre.
            </Verdict>
          ) : (
            <Verdict tone="warn">
              Les trois font le même nombre de tours. Mets maintenant la valeur de départ{" "}
              <strong>au-dessus</strong> de la borne, pour rendre la condition fausse dès le début.
            </Verdict>
          )}
        </>
      ) : (
        <div className="space-y-3">
          <Code
            lignes={[
              "trouve ← faux",
              "i ← 1",
              "TantQue (i <= 5) et (trouve = faux) faire",
              "    Si t[i] = 15 alors",
              "        trouve ← vrai",
              "    Sinon",
              "        i ← i + 1",
              "    Finsi",
              "FinTantQue",
            ]}
            eclairee={pasDrapeau === 0 ? 0 : pd.trouve && pasDrapeau === 4 ? 4 : 6}
          />

          <Cases
            valeurs={TAB}
            base={1}
            courant={pd.i}
            marquees={Array.from({ length: Math.max(0, pd.i - 1) }, (_, j) => j + 1)}
            legende={`On cherche la valeur ${CIBLE}.`}
          />

          <Panel>
            <Stat label="i" value={pd.i === 0 ? "1" : String(pd.i)} color={PALETTE.blue} />
            <Stat
              label="trouve"
              value={pd.trouve ? "vrai" : "faux"}
              color={pd.trouve ? PALETTE.green : PALETTE.slate}
            />
          </Panel>

          <Verdict tone={pd.trouve ? "ok" : "warn"}>{pd.note}</Verdict>

          <div className="flex gap-2">
            <button
              type="button"
              onClick={() => setPasDrapeau((v) => Math.max(0, v - 1))}
              className="rounded-lg border border-border bg-background px-3 py-1.5 text-xs font-medium text-muted-foreground hover:bg-secondary/60"
            >
              Étape précédente
            </button>
            <button
              type="button"
              onClick={() => setPasDrapeau((v) => Math.min(PAS_DRAPEAU.length - 1, v + 1))}
              className="rounded-lg bg-primary px-3 py-1.5 text-xs font-semibold text-primary-foreground"
            >
              Étape suivante
            </button>
          </div>

          {pasDrapeau === PAS_DRAPEAU.length - 1 ? (
            <Verdict tone="ok">
              Les trois signes d&apos;une variable drapeau, à citer en examen : elle est{" "}
              <strong>booléenne</strong>, elle est{" "}
              <strong>initialisée à faux avant la boucle</strong>, et elle{" "}
              <strong>figure dans la condition</strong> de sortie. Son rôle : mémoriser qu&apos;un
              évènement s&apos;est produit, pour sortir dès qu&apos;il l&apos;est.
            </Verdict>
          ) : null}
        </div>
      )}
    </div>
  );
}

function BoucleVue({
  titre,
  lignes,
  tours,
  infini,
}: {
  titre: string;
  lignes: ReadonlyArray<string>;
  tours: number;
  infini: boolean;
}) {
  return (
    <div className="space-y-1">
      <p className="text-xs font-semibold">{titre}</p>
      <pre className="overflow-x-auto rounded-lg bg-slate-900 p-2 font-mono text-[9px] leading-snug text-slate-300">
        {lignes.join("\n")}
      </pre>
      <p
        className="text-[11px] font-semibold"
        style={{ color: infini ? PALETTE.red : tours === 0 ? PALETTE.orange : PALETTE.green }}
      >
        {infini ? "boucle infinie" : `${tours} tour${tours > 1 ? "s" : ""}`}
      </p>
    </div>
  );
}
