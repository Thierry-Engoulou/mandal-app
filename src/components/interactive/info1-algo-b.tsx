import { useState } from "react";
import { Board, Choice, Ctrl, PALETTE, Panel, Stat, Verdict, fmt } from "./controls";
import { JeuClassement } from "./info1-jeux";

/** Informatique 1ère A, C et D — chapitres 10 et 11 : alternatives, répétitives, tableaux. */

function clamp(v: number, lo: number, hi: number) {
  return Math.max(lo, Math.min(hi, v));
}

/* ------------------------------------------------------------------ */
/* Chapitre 10 — Suivre le chemin d'un Si                              */
/* ------------------------------------------------------------------ */

type Op = "ge" | "gt" | "le" | "eq" | "ne";

const OPS: ReadonlyArray<{ value: Op; label: string; signe: string }> = [
  { value: "ge", label: "≥", signe: ">=" },
  { value: "gt", label: ">", signe: ">" },
  { value: "le", label: "≤", signe: "<=" },
  { value: "eq", label: "=", signe: "=" },
  { value: "ne", label: "≠", signe: "<>" },
];

const OP_DEFAUT = OPS[0] ?? { value: "ge" as Op, label: "≥", signe: ">=" };

export function SiAlorsSinon() {
  const [valeur, setValeur] = useState(10);
  const [seuil, setSeuil] = useState(10);
  const [op, setOp] = useState<Op>("ge");
  const [avecSinon, setAvecSinon] = useState(true);

  const o = OPS.find((q) => q.value === op) ?? OP_DEFAUT;
  const vrai =
    op === "ge"
      ? valeur >= seuil
      : op === "gt"
        ? valeur > seuil
        : op === "le"
          ? valeur <= seuil
          : op === "eq"
            ? valeur === seuil
            : valeur !== seuil;

  const limite = valeur === seuil;
  const affiche = vrai ? "Admis" : avecSinon ? "Ajourné" : "rien du tout";

  const W = 440;
  const H = 180;
  const actif = (branche: boolean) => (branche === vrai ? 1 : 0.22);

  return (
    <div className="space-y-3">
      <Panel>
        <Ctrl
          label="Moyenne de l'élève"
          value={valeur}
          min={0}
          max={20}
          step={0.5}
          onChange={setValeur}
          display={fmt(valeur, 1)}
        />
        <Ctrl
          label="Seuil de la condition"
          value={seuil}
          min={0}
          max={20}
          step={0.5}
          onChange={setSeuil}
          display={fmt(seuil, 1)}
          color={PALETTE.orange}
        />
      </Panel>

      <Choice<Op>
        label="Opérateur de comparaison"
        value={op}
        options={OPS.map((q) => ({ value: q.value, label: q.label }))}
        onChange={setOp}
      />

      <Choice<"avec" | "sans">
        label="Forme du Si"
        value={avecSinon ? "avec" : "sans"}
        options={[
          { value: "avec", label: "Avec Sinon" },
          { value: "sans", label: "Sans Sinon" },
        ]}
        onChange={(v) => setAvecSinon(v === "avec")}
      />

      <Board width={W} height={H}>
        <rect width={W} height={H} fill="#ffffff" />

        <rect x={14} y={14} width={412} height={24} rx={4} fill="#fef3c7" />
        <text x={22} y={30} fontSize={11} fontFamily="monospace" fontWeight={700} fill="#78350f">
          Si moyenne {o.signe} {fmt(seuil, 1)} alors
        </text>
        <text x={330} y={30} fontSize={10} fontWeight={700} fill={vrai ? "#15803d" : "#b91c1c"}>
          {vrai ? "VRAI" : "FAUX"}
        </text>

        <g opacity={actif(true)}>
          <rect x={38} y={46} width={388} height={24} rx={4} fill="#dcfce7" />
          <text x={50} y={62} fontSize={11} fontFamily="monospace" fill="#14532d">
            écrire(&quot;Admis&quot;)
          </text>
        </g>

        {avecSinon ? (
          <>
            <text
              x={22}
              y={94}
              fontSize={11}
              fontFamily="monospace"
              fontWeight={700}
              fill="#78350f"
            >
              Sinon
            </text>
            <g opacity={actif(false)}>
              <rect x={38} y={102} width={388} height={24} rx={4} fill="#fee2e2" />
              <text x={50} y={118} fontSize={11} fontFamily="monospace" fill="#7f1d1d">
                écrire(&quot;Ajourné&quot;)
              </text>
            </g>
            <text
              x={22}
              y={148}
              fontSize={11}
              fontFamily="monospace"
              fontWeight={700}
              fill="#78350f"
            >
              Finsi
            </text>
          </>
        ) : (
          <text x={22} y={94} fontSize={11} fontFamily="monospace" fontWeight={700} fill="#78350f">
            Finsi
          </text>
        )}

        <text x={22} y={H - 10} fontSize={11} fontWeight={700} fill={PALETTE.ink}>
          À l&apos;écran : {affiche}
        </text>
      </Board>

      <Panel>
        <Stat
          label="Condition"
          value={vrai ? "vraie" : "fausse"}
          color={vrai ? PALETTE.green : PALETTE.red}
        />
        <Stat label="Affichage" value={affiche} color={PALETTE.purple} />
      </Panel>

      {limite ? (
        <Verdict tone="warn">
          Tu es exactement sur le cas limite : la moyenne vaut le seuil. Avec ≥ la condition est
          vraie, avec &gt; elle devient fausse et l&apos;élève change de branche. Bascule
          l&apos;opérateur et regarde : c&apos;est précisément là que se jouent les erreurs
          d&apos;examen, et c&apos;est pour cela qu&apos;il faut toujours tester l&apos;égalité.
        </Verdict>
      ) : !avecSinon && !vrai ? (
        <Verdict tone="bad">
          Sans Sinon et avec une condition fausse, l&apos;algorithme n&apos;affiche rien du tout. Ce
          n&apos;est pas une erreur : c&apos;est exactement ce qu&apos;on lui a demandé.
        </Verdict>
      ) : (
        <Verdict tone="ok">
          Un seul des deux blocs s&apos;exécute, jamais les deux. Approche maintenant la moyenne du
          seuil pour voir le cas limite.
        </Verdict>
      )}
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Chapitre 10 — Les mentions, et le piège de l'ordre                  */
/* ------------------------------------------------------------------ */

const MENTIONS: ReadonlyArray<{ seuil: number; nom: string }> = [
  { seuil: 16, nom: "Très bien" },
  { seuil: 14, nom: "Bien" },
  { seuil: 12, nom: "Assez bien" },
  { seuil: 10, nom: "Passable" },
];

export function ConditionsComposees() {
  const [ordre, setOrdre] = useState<number[]>([0, 1, 2, 3]);
  const [note, setNote] = useState(18);

  const tests = ordre
    .map((k) => MENTIONS[k])
    .filter((m): m is { seuil: number; nom: string } => m !== undefined);
  const indexGagnant = tests.findIndex((m) => note >= m.seuil);
  const gagnant = indexGagnant >= 0 ? tests[indexGagnant] : undefined;
  const attendu = MENTIONS.find((m) => note >= m.seuil);
  const correct =
    (gagnant === undefined && attendu === undefined) ||
    (gagnant !== undefined && attendu !== undefined && gagnant.nom === attendu.nom);
  const ordreCroissant = ordre.every((v, k) => (k === 0 ? true : (ordre[k - 1] ?? 0) < v));

  const monter = (pos: number) => {
    if (pos === 0) return;
    const s = [...ordre];
    const a = s[pos - 1];
    const b = s[pos];
    if (a === undefined || b === undefined) return;
    s[pos - 1] = b;
    s[pos] = a;
    setOrdre(s);
  };

  const W = 440;
  const H = 40 + tests.length * 32;

  return (
    <div className="space-y-3">
      <Ctrl
        label="Note de l'élève"
        value={note}
        min={0}
        max={20}
        step={0.5}
        onChange={setNote}
        display={fmt(note, 1)}
      />

      <Board width={W} height={H}>
        <rect width={W} height={H} fill="#ffffff" />
        <text x={14} y={20} fontSize={10} fill={PALETTE.slate}>
          Les tests sont évalués de haut en bas ; le premier qui réussit l&apos;emporte.
        </text>
        {tests.map((m, k) => {
          const atteint = note >= m.seuil;
          const gagne = k === indexGagnant;
          return (
            <g key={m.nom}>
              <rect
                x={14}
                y={30 + k * 32}
                width={412}
                height={26}
                rx={4}
                fill={gagne ? "#dcfce7" : atteint ? "#f1f5f9" : "#ffffff"}
                stroke={gagne ? "#15803d" : "#e2e8f0"}
                strokeWidth={gagne ? 2 : 1}
              />
              <text
                x={24}
                y={47 + k * 32}
                fontSize={11}
                fontFamily="monospace"
                fill={gagne ? "#14532d" : atteint ? "#334155" : "#94a3b8"}
              >
                Si note &gt;= {m.seuil} alors écrire(&quot;{m.nom}&quot;)
              </text>
              <text
                x={416}
                y={47 + k * 32}
                textAnchor="end"
                fontSize={10}
                fontWeight={700}
                fill={gagne ? "#15803d" : atteint ? "#64748b" : "#cbd5e1"}
              >
                {gagne ? "← retenu" : atteint ? "vrai" : "faux"}
              </text>
            </g>
          );
        })}
      </Board>

      <div className="space-y-1.5">
        <p className="text-xs font-medium text-muted-foreground">
          Réordonne les tests — chaque bouton remonte sa ligne d&apos;un cran
        </p>
        <div className="flex flex-wrap gap-1.5">
          {tests.map((m, k) => (
            <button
              key={m.nom}
              type="button"
              onClick={() => monter(k)}
              disabled={k === 0}
              className={
                k === 0
                  ? "rounded-lg border border-border bg-secondary/40 px-2.5 py-1.5 text-[11px] text-muted-foreground/50"
                  : "rounded-lg border border-border bg-background px-2.5 py-1.5 text-[11px] font-medium hover:bg-secondary/60"
              }
            >
              ↑ {m.seuil}
            </button>
          ))}
          <button
            type="button"
            onClick={() => setOrdre([0, 1, 2, 3])}
            className="rounded-lg bg-primary px-2.5 py-1.5 text-[11px] font-semibold text-primary-foreground"
          >
            Remettre dans le bon ordre
          </button>
        </div>
      </div>

      <Panel>
        <Stat
          label="Mention affichée"
          value={gagnant ? gagnant.nom : "Ajourné"}
          color={correct ? PALETTE.green : PALETTE.red}
        />
        <Stat label="Mention attendue" value={attendu ? attendu.nom : "Ajourné"} />
      </Panel>

      {!correct && gagnant ? (
        <Verdict tone="bad">
          Avec cette note de {fmt(note, 1)}, l&apos;algorithme affiche « {gagnant.nom} » alors
          qu&apos;il devrait afficher « {attendu ? attendu.nom : "Ajourné"} ». Le test de{" "}
          {gagnant.seuil} a réussi trop tôt : il est placé avant des tests plus exigeants, et le
          premier test qui réussit l&apos;emporte. Il faut aller du plus exigeant au moins exigeant.
        </Verdict>
      ) : ordreCroissant ? (
        <Verdict tone="ok">
          L&apos;ordre est correct, du plus exigeant au moins exigeant. Mets maintenant le test de
          10 en premier et entre la note 18 : tu verras un excellent élève repartir avec « Passable
          ».
        </Verdict>
      ) : (
        <Verdict tone="warn">
          L&apos;ordre n&apos;est pas décroissant, mais cette note-là ne le révèle pas. Essaie une
          note plus élevée : c&apos;est toujours avec la <strong>meilleure</strong> note qu&apos;on
          attrape ce défaut.
        </Verdict>
      )}
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Chapitre 10 — Selon ou Si imbriqués ?                               */
/* ------------------------------------------------------------------ */

export function SelonCas() {
  return (
    <JeuClassement
      libelleChoix="Quelle structure choisir ?"
      aide="Une seule question tranche : compare-t-on la variable à des valeurs précises et énumérables, ou à des intervalles ?"
      options={[
        { value: "selon", label: "Selon" },
        { value: "si", label: "Si imbriqués" },
      ]}
      cas={[
        {
          enonce: "Afficher le nom du jour à partir de son numéro, de 1 à 7.",
          bonne: "selon",
          pourquoi:
            "Sept valeurs précises et énumérables. En Si imbriqués il faudrait sept niveaux et sept Finsi.",
        },
        {
          enonce: "Afficher la mention d'un élève selon sa moyenne.",
          bonne: "si",
          pourquoi:
            "Ce sont des intervalles — de 16 à 20, de 14 à 16 — et on ne peut pas écrire un intervalle dans un Selon.",
        },
        {
          enonce: "Donner la dominante d'une série : A, C ou D.",
          bonne: "selon",
          pourquoi: "Trois caractères précis : c'est exactement le terrain du Selon.",
        },
        {
          enonce: "Dire si une personne est mineure, majeure ou retraitée selon son âge.",
          bonne: "si",
          pourquoi: "Encore des intervalles : moins de 18, de 18 à 60, plus de 60.",
        },
        {
          enonce: "Afficher le libellé d'un code d'erreur : 404, 500, 403.",
          bonne: "selon",
          pourquoi: "Des valeurs isolées, sans ordre et sans intervalle.",
        },
        {
          enonce: "Classer une température en « glacial », « frais », « doux » ou « chaud ».",
          bonne: "si",
          pourquoi: "Des tranches de températures, donc des comparaisons, donc des Si imbriqués.",
        },
        {
          enonce: "Afficher le nom du mois à partir de son numéro.",
          bonne: "selon",
          pourquoi: "Douze valeurs précises. Et n'oublie pas la clause Autre pour le numéro 13.",
        },
        {
          enonce: "Appliquer une remise de 5 %, 10 % ou 15 % selon le montant de l'achat.",
          bonne: "si",
          pourquoi:
            "La remise dépend de tranches de montants, pas de montants précis : les Si imbriqués sont obligatoires.",
        },
      ]}
    />
  );
}

/* ------------------------------------------------------------------ */
/* Chapitre 11 — La boucle TantQue                                     */
/* ------------------------------------------------------------------ */

export function BoucleTantque() {
  const [depart, setDepart] = useState(1);
  const [seuil, setSeuil] = useState(5);
  const [pas, setPas] = useState(1);

  // exécution réelle, plafonnée à 100 tours
  const valeurs: number[] = [];
  let i = depart;
  let tours = 0;
  while (i <= seuil && tours < 100) {
    valeurs.push(i);
    i += pas;
    tours += 1;
  }
  const infinie = tours >= 100 && i <= seuil;
  const aucun = tours === 0;

  const W = 440;
  const H = 180;

  return (
    <div className="space-y-3">
      <Panel>
        <Ctrl
          label="Initialisation : i ←"
          value={depart}
          min={-5}
          max={20}
          step={1}
          onChange={setDepart}
          display={`${depart}`}
        />
        <Ctrl
          label="Condition : i <="
          value={seuil}
          min={-5}
          max={30}
          step={1}
          onChange={setSeuil}
          display={`${seuil}`}
          color={PALETTE.orange}
        />
      </Panel>

      <Ctrl
        label="Progression : i ← i +"
        value={pas}
        min={-2}
        max={5}
        step={1}
        onChange={setPas}
        display={pas === 0 ? "0 — rien ne bouge" : `${pas}`}
        color={pas <= 0 ? PALETTE.red : PALETTE.green}
      />

      <Board width={W} height={H}>
        <rect width={W} height={H} fill="#ffffff" />

        <text x={16} y={24} fontSize={11} fontFamily="monospace" fill="#0f172a">
          i ← {depart}
        </text>
        <text x={16} y={44} fontSize={11} fontFamily="monospace" fontWeight={700} fill="#2563eb">
          TantQue i &lt;= {seuil} faire
        </text>
        <text x={32} y={64} fontSize={11} fontFamily="monospace" fill="#0f172a">
          écrire(i)
        </text>
        <text
          x={32}
          y={84}
          fontSize={11}
          fontFamily="monospace"
          fill={pas <= 0 ? "#b91c1c" : "#15803d"}
          fontWeight={pas <= 0 ? 700 : 400}
        >
          i ← i + {pas}
        </text>
        <text x={16} y={104} fontSize={11} fontFamily="monospace" fontWeight={700} fill="#2563eb">
          FinTantQue
        </text>

        <text x={16} y={132} fontSize={10} fill={PALETTE.slate}>
          Ce que la boucle affiche :
        </text>
        {infinie ? (
          <text x={16} y={154} fontSize={12} fontFamily="monospace" fontWeight={700} fill="#b91c1c">
            {valeurs.slice(0, 12).join("  ")} … sans fin
          </text>
        ) : aucun ? (
          <text x={16} y={154} fontSize={12} fontWeight={700} fill="#b45309">
            rien — le bloc n&apos;est pas exécuté une seule fois
          </text>
        ) : (
          <text x={16} y={154} fontSize={12} fontFamily="monospace" fontWeight={700} fill="#15803d">
            {valeurs.slice(0, 18).join("  ")}
            {valeurs.length > 18 ? " …" : ""}
          </text>
        )}
        <text x={16} y={172} fontSize={10} fill={PALETTE.slate}>
          {infinie ? "arrêt forcé au centième tour" : `${valeurs.length} tour(s)`}
        </text>
      </Board>

      <Panel>
        <Stat
          label="Nombre de tours"
          value={infinie ? "∞" : `${valeurs.length}`}
          color={infinie ? PALETTE.red : PALETTE.ink}
        />
        <Stat label="Valeur finale de i" value={infinie ? "ne sort jamais" : `${i}`} />
      </Panel>

      {infinie ? (
        <Verdict tone="bad">
          Boucle infinie.{" "}
          {pas === 0
            ? "La progression vaut 0 : i reste à sa valeur de départ, la condition reste vraie, et on ne sort jamais."
            : "La progression éloigne i de la sortie au lieu de l'en rapprocher."}{" "}
          Avant de rendre une boucle, pose-toi toujours la question : qu&apos;est-ce qui, dans le
          bloc, rapproche de la sortie ? Si tu ne trouves pas, la boucle est infinie.
        </Verdict>
      ) : aucun ? (
        <Verdict tone="warn">
          La condition est fausse dès le départ, donc le bloc ne s&apos;exécute pas une seule fois.
          C&apos;est normal, et c&apos;est même l&apos;intérêt du TantQue : il vérifie{" "}
          <strong>avant</strong> d&apos;agir. Le Répéter, lui, ferait un tour quand même.
        </Verdict>
      ) : (
        <Verdict tone="ok">
          {valeurs.length} tours, puis i vaut {i} et la condition devient fausse. Mets maintenant la
          progression à 0 : tu verras la boucle infinie.
        </Verdict>
      )}
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Chapitre 11 — La boucle Pour, et le choix de la boucle              */
/* ------------------------------------------------------------------ */

export function BouclePour() {
  const [d, setD] = useState(1);
  const [f, setF] = useState(5);
  const [pas, setPas] = useState(1);

  const valeurs: number[] = [];
  if (pas > 0) {
    for (let k = d; k <= f && valeurs.length < 60; k += pas) valeurs.push(k);
  } else if (pas < 0) {
    for (let k = d; k >= f && valeurs.length < 60; k += pas) valeurs.push(k);
  }
  const aucun = valeurs.length === 0;
  const descend = d > f;

  const W = 440;
  const H = 160;

  return (
    <div className="space-y-3">
      <Panel>
        <Ctrl label="de" value={d} min={-10} max={30} step={1} onChange={setD} display={`${d}`} />
        <Ctrl
          label="à"
          value={f}
          min={-10}
          max={30}
          step={1}
          onChange={setF}
          display={`${f}`}
          color={PALETTE.orange}
        />
      </Panel>

      <Ctrl
        label="pas"
        value={pas}
        min={-5}
        max={5}
        step={1}
        onChange={setPas}
        display={pas === 0 ? "0 — interdit" : `${pas}`}
        color={pas === 0 ? PALETTE.red : PALETTE.green}
      />

      <Board width={W} height={H}>
        <rect width={W} height={H} fill="#ffffff" />

        <text x={16} y={28} fontSize={12} fontFamily="monospace" fontWeight={700} fill="#2563eb">
          Pour i de {d} à {f}
          {pas !== 1 ? ` pas ${pas}` : ""} faire
        </text>
        <text x={32} y={50} fontSize={12} fontFamily="monospace" fill="#0f172a">
          écrire(i)
        </text>
        <text x={16} y={72} fontSize={12} fontFamily="monospace" fontWeight={700} fill="#2563eb">
          FinPour
        </text>

        <text x={16} y={102} fontSize={10} fill={PALETTE.slate}>
          Valeurs prises par le compteur :
        </text>
        {aucun ? (
          <text x={16} y={126} fontSize={12} fontWeight={700} fill="#b45309">
            aucune — la boucle ne tourne pas
          </text>
        ) : (
          <text x={16} y={126} fontSize={12} fontFamily="monospace" fontWeight={700} fill="#15803d">
            {valeurs.slice(0, 16).join("  ")}
            {valeurs.length > 16 ? " …" : ""}
          </text>
        )}
        <text x={16} y={148} fontSize={10} fill={PALETTE.slate}>
          {valeurs.length} tour(s) — le compteur est géré tout seul, la boucle ne peut pas être
          infinie
        </text>
      </Board>

      <Panel>
        <Stat
          label="Nombre de tours"
          value={`${valeurs.length}`}
          color={aucun ? PALETTE.red : PALETTE.green}
        />
        <Stat
          label="Somme des valeurs"
          value={`${valeurs.reduce((s, v) => s + v, 0)}`}
          color={PALETTE.purple}
        />
      </Panel>

      {pas === 0 ? (
        <Verdict tone="bad">
          Un pas nul n&apos;a pas de sens : le compteur n&apos;avancerait jamais. En LDA on ne
          l&apos;écrit pas, et la boucle ne tourne pas du tout.
        </Verdict>
      ) : descend && pas > 0 ? (
        <Verdict tone="bad">
          Le début ({d}) est déjà au-delà de la fin ({f}) et le pas est positif : zéro tour. Pour
          descendre, il faut un <strong>pas négatif</strong> — essaie pas −1.
        </Verdict>
      ) : (
        <Verdict tone="ok">
          {valeurs.length} tours, et tu n&apos;as écrit ni initialisation ni progression :
          c&apos;est la boucle Pour qui s&apos;en charge. Souviens-toi de la contrepartie : on ne
          modifie <strong>jamais</strong> le compteur à l&apos;intérieur du bloc.
        </Verdict>
      )}
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Chapitre 11 — TantQue et Répéter côte à côte                        */
/* ------------------------------------------------------------------ */

export function ComparerBoucles() {
  const [depart, setDepart] = useState(1);
  const [seuil, setSeuil] = useState(5);

  const tq: number[] = [];
  let a = depart;
  while (a <= seuil && tq.length < 40) {
    tq.push(a);
    a += 1;
  }

  const rp: number[] = [];
  let b = depart;
  do {
    rp.push(b);
    b += 1;
  } while (b <= seuil && rp.length < 40);

  const ecart = rp.length - tq.length;

  const W = 440;
  const H = 200;

  return (
    <div className="space-y-3">
      <Panel>
        <Ctrl
          label="Valeur de départ"
          value={depart}
          min={-3}
          max={12}
          step={1}
          onChange={setDepart}
          display={`${depart}`}
        />
        <Ctrl
          label="Seuil"
          value={seuil}
          min={-3}
          max={12}
          step={1}
          onChange={setSeuil}
          display={`${seuil}`}
          color={PALETTE.orange}
        />
      </Panel>

      <Board width={W} height={H}>
        <rect width={W} height={H} fill="#ffffff" />
        <line x1={220} y1={10} x2={220} y2={H - 10} stroke="#cbd5e1" strokeWidth={1.2} />

        <text x={14} y={24} fontSize={11} fontWeight={700} fill="#2563eb">
          TantQue — test au début
        </text>
        <text x={14} y={46} fontSize={10} fontFamily="monospace" fill="#0f172a">
          i ← {depart}
        </text>
        <text x={14} y={62} fontSize={10} fontFamily="monospace" fontWeight={700} fill="#2563eb">
          TantQue i &lt;= {seuil} faire
        </text>
        <text x={26} y={78} fontSize={10} fontFamily="monospace" fill="#0f172a">
          écrire(i) ; i ← i + 1
        </text>
        <text x={14} y={94} fontSize={10} fontFamily="monospace" fontWeight={700} fill="#2563eb">
          FinTantQue
        </text>
        <text x={14} y={128} fontSize={10} fill={PALETTE.slate}>
          affiche :
        </text>
        <text
          x={14}
          y={148}
          fontSize={11}
          fontFamily="monospace"
          fontWeight={700}
          fill={tq.length === 0 ? "#b45309" : "#15803d"}
        >
          {tq.length === 0 ? "rien" : tq.join(" ")}
        </text>
        <text x={14} y={172} fontSize={11} fontWeight={700} fill="#0f172a">
          {tq.length} tour(s)
        </text>

        <text x={232} y={24} fontSize={11} fontWeight={700} fill="#ea580c">
          Répéter — test à la fin
        </text>
        <text x={232} y={46} fontSize={10} fontFamily="monospace" fill="#0f172a">
          i ← {depart}
        </text>
        <text x={232} y={62} fontSize={10} fontFamily="monospace" fontWeight={700} fill="#ea580c">
          Répéter
        </text>
        <text x={244} y={78} fontSize={10} fontFamily="monospace" fill="#0f172a">
          écrire(i) ; i ← i + 1
        </text>
        <text x={232} y={94} fontSize={10} fontFamily="monospace" fontWeight={700} fill="#ea580c">
          Jusqu&apos;à i &gt; {seuil}
        </text>
        <text x={232} y={128} fontSize={10} fill={PALETTE.slate}>
          affiche :
        </text>
        <text x={232} y={148} fontSize={11} fontFamily="monospace" fontWeight={700} fill="#15803d">
          {rp.join(" ")}
        </text>
        <text x={232} y={172} fontSize={11} fontWeight={700} fill="#0f172a">
          {rp.length} tour(s)
        </text>

        <text x={220} y={H - 2} textAnchor="middle" fontSize={9} fill={PALETTE.slate}>
          i &lt;= {seuil} d&apos;un côté, i &gt; {seuil} de l&apos;autre : les conditions sont
          opposées
        </text>
      </Board>

      <Panel>
        <Stat label="TantQue" value={`${tq.length} tour(s)`} color={PALETTE.blue} />
        <Stat label="Répéter" value={`${rp.length} tour(s)`} color={PALETTE.orange} />
      </Panel>

      {tq.length === 0 ? (
        <Verdict tone="ok">
          Voilà la différence essentielle, en une image : la condition est fausse dès le départ,
          donc le TantQue ne fait <strong>aucun</strong> tour, tandis que le Répéter en fait{" "}
          <strong>un</strong> — il teste à la fin, donc il a déjà agi. C&apos;est pour cela que le
          Répéter est la boucle du contrôle de saisie : on ne peut pas vérifier une note qu&apos;on
          n&apos;a pas encore lue.
        </Verdict>
      ) : ecart === 0 ? (
        <Verdict tone="warn">
          Mêmes résultats, et c&apos;est le cas le plus fréquent. Pour voir la vraie différence,
          rends la condition fausse dès le départ : mets le départ au-dessus du seuil.
        </Verdict>
      ) : (
        <Verdict tone="warn">
          Les deux boucles divergent de {ecart} tour. Regarde bien les conditions : elles sont
          opposées, parce qu&apos;on <em>reste</em> tant que celle du TantQue est vraie, et
          qu&apos;on <em>sort</em> quand celle du Répéter devient vraie.
        </Verdict>
      )}
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Chapitre 11 — Parcourir un tableau                                  */
/* ------------------------------------------------------------------ */

const NOTES_DEPART = [12, 9, 15.5, 7, 18, 11, 4, 13.5, 16, 10];

export function Tableaux() {
  const [notes, setNotes] = useState<number[]>(NOTES_DEPART);
  const [debut, setDebut] = useState(1);
  const [fin, setFin] = useState(10);
  const [pos, setPos] = useState(0);

  const n = notes.length;
  const dep = clamp(Math.round(debut), 0, n + 1);
  const arr = clamp(Math.round(fin), 0, n + 1);
  const indices: number[] = [];
  for (let k = dep; k <= arr; k += 1) indices.push(k);

  const avance = clamp(pos, 0, indices.length);
  const lus = indices.slice(0, avance);
  const hors = lus.filter((k) => k < 1 || k > n);
  const valides = lus.filter((k) => k >= 1 && k <= n);

  let somme = 0;
  let compte = 0;
  let max = -Infinity;
  for (const k of valides) {
    const v = notes[k - 1];
    if (v === undefined) continue;
    somme += v;
    if (v >= 10) compte += 1;
    if (v > max) max = v;
  }
  const moyenne = valides.length > 0 ? somme / valides.length : 0;
  const courant = indices[avance];

  const W = 440;
  const H = 130;
  const larg = 40;

  return (
    <div className="space-y-3">
      <Board width={W} height={H}>
        <rect width={W} height={H} fill="#ffffff" />
        <text x={14} y={20} fontSize={10} fill={PALETTE.slate}>
          notes : tableau[1..{n}] de réel
        </text>

        {notes.map((v, k) => {
          const idx = k + 1;
          const lu = lus.includes(idx);
          const actuel = courant === idx;
          const x = 14 + k * larg;
          return (
            <g key={k}>
              <rect
                x={x}
                y={32}
                width={larg - 4}
                height={40}
                rx={4}
                fill={actuel ? "#fef3c7" : lu ? "#dbeafe" : "#f8fafc"}
                stroke={actuel ? "#ca8a04" : lu ? "#2563eb" : "#cbd5e1"}
                strokeWidth={actuel ? 2.4 : 1.2}
              />
              <text
                x={x + (larg - 4) / 2}
                y={57}
                textAnchor="middle"
                fontSize={11}
                fontFamily="monospace"
                fontWeight={700}
                fill={actuel ? "#78350f" : "#0f172a"}
              >
                {fmt(v, 1)}
              </text>
              <text
                x={x + (larg - 4) / 2}
                y={86}
                textAnchor="middle"
                fontSize={9}
                fill={PALETTE.slate}
              >
                [{idx}]
              </text>
            </g>
          );
        })}

        <text x={14} y={110} fontSize={10} fill={PALETTE.slate}>
          Pour i de {dep} à {arr} faire … FinPour
        </text>
        <text
          x={14}
          y={124}
          fontSize={10}
          fontWeight={700}
          fill={hors.length > 0 ? "#b91c1c" : PALETTE.slate}
        >
          {courant === undefined
            ? "parcours terminé"
            : courant < 1 || courant > n
              ? `i = ${courant} : cette case n'existe pas`
              : `i = ${courant} : on lit notes[${courant}]`}
        </text>
      </Board>

      <Panel>
        <Ctrl
          label="Indice de départ"
          value={dep}
          min={0}
          max={n + 1}
          step={1}
          onChange={setDebut}
          display={`${dep}`}
        />
        <Ctrl
          label="Indice d'arrivée"
          value={arr}
          min={0}
          max={n + 1}
          step={1}
          onChange={setFin}
          display={`${arr}`}
          color={PALETTE.orange}
        />
      </Panel>

      <Ctrl
        label="Avancer dans le parcours"
        value={avance}
        min={0}
        max={indices.length}
        step={1}
        onChange={setPos}
        display={`${avance} / ${indices.length}`}
        color={PALETTE.purple}
      />

      <Panel>
        <Stat label="somme" value={fmt(somme, 1)} />
        <Stat
          label="moyenne"
          value={valides.length > 0 ? fmt(moyenne, 2) : "—"}
          color={PALETTE.blue}
        />
        <Stat label="nb ≥ 10" value={`${compte}`} color={PALETTE.green} />
        <Stat
          label="maximum"
          value={Number.isFinite(max) ? fmt(max, 1) : "—"}
          color={PALETTE.orange}
        />
      </Panel>

      <div className="flex flex-wrap gap-2">
        <button
          type="button"
          onClick={() => setPos(Math.min(indices.length, avance + 1))}
          className="rounded-lg bg-primary px-3 py-1.5 text-xs font-semibold text-primary-foreground"
        >
          Un tour de plus
        </button>
        <button
          type="button"
          onClick={() => setPos(0)}
          className="rounded-lg border border-border bg-background px-3 py-1.5 text-xs font-medium text-muted-foreground hover:bg-secondary/60"
        >
          Recommencer le parcours
        </button>
        <button
          type="button"
          onClick={() =>
            setNotes(notes.map((v, k) => clamp(Math.round((v * 7 + k * 5 + 3) % 21), 0, 20)))
          }
          className="rounded-lg border border-border bg-background px-3 py-1.5 text-xs font-medium hover:bg-secondary/60"
        >
          Changer les notes
        </button>
      </div>

      {hors.length > 0 ? (
        <Verdict tone="bad">
          Le parcours est sorti des bornes : l&apos;indice {hors.join(" puis ")} n&apos;existe pas
          dans un tableau[1..{n}]. Dans un vrai programme, cette lecture donne une valeur
          imprévisible ou arrête l&apos;exécution — et ni la somme ni la moyenne ne veulent plus
          rien dire. Remets les bornes à 1 et {n}.
        </Verdict>
      ) : avance === indices.length && valides.length > 0 ? (
        <Verdict tone="ok">
          Parcours terminé. Remarque qu&apos;un <strong>seul</strong> passage a suffi pour la somme,
          le comptage et le maximum : c&apos;est le réflexe à prendre sur toutes les questions de
          tableau, plutôt que d&apos;écrire trois boucles.
        </Verdict>
      ) : (
        <Verdict tone="warn">
          Le schéma à connaître par cœur : initialiser les compteurs, parcourir en accumulant,
          exploiter à la fin. Somme, moyenne, comptage, maximum et recherche en sortent tous.
        </Verdict>
      )}
    </div>
  );
}
