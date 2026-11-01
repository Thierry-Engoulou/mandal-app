import { useMemo, useState } from "react";
import { Ctrl, PALETTE, Stat, Verdict } from "./controls";
import {
  Citation,
  Galerie,
  JeuTri,
  Jauges,
  Qcm,
  type Auteur,
  type ItemTri,
  type Question,
} from "./philo-noyau";

/** Philosophie Terminale C et D — chapitres 8 et 9 :
 *  liberté et responsabilité, panafricanisme et développement. */

/* ------------------------------------------------------------------ */
/* 1. Déterminisme ou fatalisme ?                                      */
/* ------------------------------------------------------------------ */

const PROPOS: ReadonlyArray<ItemTri> = [
  {
    id: "f1",
    texte: "« C'était écrit : il ne pouvait pas en être autrement. »",
    bonne: "fatalisme",
    pourquoi:
      "Un destin invoqué, sans cause identifiable. Conséquence pratique : ne rien changer, puisque rien ne peut changer.",
  },
  {
    id: "f2",
    texte: "« Il a échoué parce qu'il n'a pas révisé et qu'il a mal réparti son travail. »",
    bonne: "determinisme",
    pourquoi:
      "Des causes nommées, donc modifiables. Conséquence pratique : agir sur elles, puisque les mêmes causes produisent les mêmes effets.",
  },
  {
    id: "f3",
    texte: "« J'aurais pu me taire, et j'ai choisi de parler. »",
    bonne: "libre",
    pourquoi:
      "Le témoignage de la conscience, que Descartes tient pour le mieux connu de tout : la volonté est si libre qu'elle ne peut jamais être contrainte.",
  },
  {
    id: "f4",
    texte: "« On ne change pas la nature humaine, c'est inutile d'essayer. »",
    bonne: "fatalisme",
    pourquoi:
      "Une nature invoquée comme un destin, et aussitôt la conclusion : ne rien tenter. Le fatalisme se reconnaît toujours à ce qu'il décourage l'action.",
  },
  {
    id: "f5",
    texte:
      "« Son enfance explique en grande partie sa violence, et c'est pourquoi on peut le soigner. »",
    bonne: "determinisme",
    pourquoi:
      "Le « et c'est pourquoi on peut » est la signature du déterminisme : il explique pour agir. C'est exactement la démarche du médecin.",
  },
  {
    id: "f6",
    texte: "« Les hommes se croient libres parce qu'ils ignorent les causes qui les déterminent. »",
    bonne: "determinisme",
    pourquoi:
      "Spinoza. Et il ajoute le remède, qui est encore une action : la liberté est la connaissance de la nécessité.",
  },
  {
    id: "f7",
    texte: "« Quoi que fasse Œdipe pour fuir l'oracle, il l'accomplira. »",
    bonne: "fatalisme",
    pourquoi:
      "Le modèle même du fatalisme : c'est en fuyant son destin qu'Œdipe le réalise. Agir ne change rien, et même aggrave.",
  },
  {
    id: "f8",
    texte: "« Mes pulsions inconscientes commandent mes actes bien plus que ma volonté. »",
    bonne: "determinisme",
    pourquoi:
      "Déterminisme psychique, chez Freud. Et toute la cure repose sur l'idée qu'en rendant ces causes conscientes on peut agir — ce qui serait absurde pour un fataliste.",
  },
  {
    id: "f9",
    texte: "« Tu dois, donc tu peux. »",
    bonne: "libre",
    pourquoi:
      "Kant. Si je ne pouvais pas faire autrement, le mot « devoir » n'aurait aucun sens, car on ne commande qu'à ce qui peut obéir.",
  },
  {
    id: "f10",
    texte: "« L'existence sociale détermine la conscience, et non l'inverse. »",
    bonne: "determinisme",
    pourquoi:
      "Marx. Et toute son œuvre appelle à transformer ces conditions sociales : un déterminisme n'est jamais une invitation à se résigner.",
  },
  {
    id: "f11",
    texte: "« L'homme est condamné à être libre : même refuser de choisir est un choix. »",
    bonne: "libre",
    pourquoi:
      "Sartre. L'existence précède l'essence : aucune nature donnée ne dicte la conduite, donc aucune excuse.",
  },
  {
    id: "f12",
    texte: "« À quoi bon aller chez le médecin ? Si mon heure est venue, elle est venue. »",
    bonne: "fatalisme",
    pourquoi:
      "Le cas qui résume tout le chapitre. Le déterministe va chez le médecin, parce qu'il cherche la cause pour agir sur elle. Le fataliste n'y va pas.",
  },
];

const CONSEQUENCES: ReadonlyArray<Question> = [
  {
    id: "cq1",
    enonce:
      "Un élève a échoué. Son professeur lui dit : « ton échec a des causes — un cours mal compris, trop peu de sommeil. » Que faut-il faire ?",
    options: [
      {
        texte:
          "Identifier ces causes et agir sur elles, puisque les mêmes causes produisent les mêmes effets.",
        bonne: true,
        retour:
          "Oui, et c'est le propre du déterminisme : il explique pour transformer. Le principe de la science est aussi le principe de l'action.",
      },
      {
        texte: "Accepter que cet élève n'était pas fait pour les études.",
        bonne: false,
        retour:
          "Tu viens de glisser du déterminisme au fatalisme. La même thèse de la nécessité conduit à l'action dans un cas et à la résignation dans l'autre — et c'est le glissement qui coûte le plus de points en copie.",
      },
    ],
  },
  {
    id: "cq2",
    enonce: "Pourquoi le déterminisme est-il le principe de TOUTES les sciences ?",
    options: [
      {
        texte:
          "Parce qu'une science cherche des causes, et qu'elle n'en chercherait pas si les phénomènes n'en avaient pas.",
        bonne: true,
        retour:
          "Exactement. Une science fataliste n'aurait aucune raison de chercher : si tout est écrit, rien n'est à comprendre.",
      },
      {
        texte: "Parce que les savants ne croient pas à la liberté.",
        bonne: false,
        retour:
          "Beaucoup y croient. Le déterminisme est une règle de méthode pour l'étude des phénomènes, non une doctrine sur l'âme.",
      },
    ],
  },
  {
    id: "cq3",
    enonce:
      "Quelle est la formule qui ferme le mieux une dissertation sur « l'homme est-il libre ? »",
    options: [
      {
        texte:
          "La liberté n'est pas un état mais une conquête : on ne naît pas libre, on le devient, en connaissant ce qui nous détermine.",
        bonne: true,
        retour:
          "Oui, et elle réconcilie les deux thèses sans les trahir : les déterministes ont raison contre la liberté absolue, les autres contre la liberté nulle. Spinoza : la liberté est la connaissance de la nécessité.",
      },
      {
        texte: "L'homme est libre, c'est évident puisqu'il le sent.",
        bonne: false,
        retour:
          "Spinoza répond précisément à cela : le sentiment de liberté est compatible avec l'ignorance des causes. Le sentiment ne prouve rien.",
      },
      {
        texte: "Tout est déterminé, la liberté est une illusion totale.",
        bonne: false,
        retour:
          "Cette position supprime la morale et la justice avec elle : on ne punit pas une pierre qui tombe. Les circonstances atténuantes prouvent que personne ne la tient vraiment.",
      },
    ],
  },
];

export function DeterminismeFatalisme() {
  return (
    <div className="space-y-4">
      <JeuTri
        consigne="Douze propos. Classe-les entre fatalisme, déterminisme et libre arbitre. Pour chacun, la correction te donne la conséquence pratique — et tu verras que les propos déterministes appellent toujours une action, les propos fatalistes jamais."
        categories={[
          { value: "fatalisme", label: "Fatalisme", aide: "un destin ; agir ne sert à rien" },
          {
            value: "determinisme",
            label: "Déterminisme",
            aide: "des causes identifiables ; agir est possible",
          },
          { value: "libre", label: "Libre arbitre", aide: "la volonté choisit" },
        ]}
        items={PROPOS}
        conclusion={
          <>
            Le critère unique, et il ne trompe jamais : demande-toi{" "}
            <strong>ce que le propos conseille de faire</strong>. Le déterminisme fait dépendre
            l'effet de causes identifiables et modifiables, donc il <em>fonde</em> l'action. Le
            fatalisme invoque un destin, donc il la <em>supprime</em>. Le déterministe va chez le
            médecin ; le fataliste n'y va pas.
          </>
        }
      />
      <div className="border-t border-border pt-3">
        <p className="mb-2 text-xs font-semibold text-foreground">
          Second volet — la conséquence pratique
        </p>
        <Qcm
          consigne="Trois questions pour vérifier que la distinction tient debout dans ta tête, et pas seulement sur le papier."
          questions={CONSEQUENCES}
          conclusion={
            <>
              Une copie qui écrit « tout est déterminé, donc rien ne sert d'agir » se contredit deux
              fois : elle confond déterminisme et fatalisme, et elle tire d'une thèse scientifique
              une conclusion que la science elle-même démentirait.
            </>
          }
        />
      </div>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* 2. Les causes et la marge                                           */
/* ------------------------------------------------------------------ */

type Cause = { id: string; label: string; poids: number; auteur: string; detail: string };

const CAUSES: ReadonlyArray<Cause> = [
  {
    id: "her",
    label: "Hérédité et tempérament",
    poids: 14,
    auteur: "Taine",
    detail: "L'homme serait le produit de la race, du milieu et du moment.",
  },
  {
    id: "mil",
    label: "Milieu social et classe",
    poids: 20,
    auteur: "Marx",
    detail: "Ce n'est pas la conscience qui détermine l'existence sociale, mais l'inverse.",
  },
  {
    id: "edu",
    label: "Éducation et langue reçues",
    poids: 16,
    auteur: "Durkheim",
    detail: "Les faits sociaux s'imposent à nous de l'extérieur, avant tout examen.",
  },
  {
    id: "inc",
    label: "Pulsions inconscientes",
    poids: 18,
    auteur: "Freud",
    detail: "Le moi n'est pas maître chez lui : il croit choisir, il rationalise après coup.",
  },
  {
    id: "epo",
    label: "Époque et institutions",
    poids: 12,
    auteur: "Hegel",
    detail: "Nul ne saute par-dessus son temps : les possibles d'une époque sont datés.",
  },
];

export function CausesEtMarge() {
  const [actives, setActives] = useState<Record<string, boolean>>({});
  const [connait, setConnait] = useState(false);

  const poids = CAUSES.reduce((s, c) => s + (actives[c.id] ? c.poids : 0), 0);
  const marge = Math.max(12, 100 - poids + (connait ? Math.min(22, poids * 0.3) : 0));
  const largeur = Math.round((marge / 100) * 260);

  const toutes = CAUSES.every((c) => actives[c.id]);

  return (
    <div className="space-y-3">
      <p className="text-sm text-muted-foreground">
        Un personnage et ses déterminismes. Active-les un par un et regarde la zone de ses choix
        possibles se rétrécir. Pousse-les tous : la zone ne disparaît jamais complètement.
      </p>

      <ul className="space-y-1.5">
        {CAUSES.map((c) => {
          const on = Boolean(actives[c.id]);
          return (
            <li key={c.id}>
              <button
                type="button"
                onClick={() => setActives((a) => ({ ...a, [c.id]: !a[c.id] }))}
                className={
                  on
                    ? "w-full rounded-lg border border-rose-500/40 bg-rose-500/10 px-2.5 py-1.5 text-left"
                    : "w-full rounded-lg border border-border bg-background px-2.5 py-1.5 text-left hover:bg-secondary/50"
                }
              >
                <p className="flex items-baseline justify-between gap-2 text-xs">
                  <span className="font-medium text-foreground">{c.label}</span>
                  <span className="font-mono text-[11px] text-muted-foreground">
                    {on ? `− ${c.poids}` : "inactif"}
                  </span>
                </p>
                {on ? (
                  <p className="mt-0.5 text-[11px] leading-snug text-muted-foreground">
                    <span className="font-semibold">{c.auteur} : </span>
                    {c.detail}
                  </p>
                ) : null}
              </button>
            </li>
          );
        })}
      </ul>

      <div className="rounded-lg border border-border bg-background p-3">
        <svg
          viewBox="0 0 300 92"
          width="100%"
          height="92"
          role="img"
          aria-label="Zone des choix possibles"
        >
          <rect x="18" y="18" width="264" height="40" rx="4" fill="#f1f5f9" stroke="#cbd5e1" />
          <rect
            x="20"
            y="20"
            width={Math.max(8, largeur).toFixed(0)}
            height="36"
            rx="3"
            fill={connait ? "#86efac" : "#bfdbfe"}
            stroke={connait ? "#15803d" : "#2563eb"}
            strokeWidth="1.4"
          />
          <text x="150" y="12" textAnchor="middle" fontSize="9" fill="#64748b">
            l&apos;ensemble de ce qu&apos;un homme pourrait faire
          </text>
          <text
            x={(20 + Math.max(8, largeur) / 2).toFixed(0)}
            y="43"
            textAnchor="middle"
            fontSize="10"
            fontWeight="700"
            fill={connait ? "#14532d" : "#1e3a8a"}
          >
            {Math.round(marge)} %
          </text>
          <text x="150" y="76" textAnchor="middle" fontSize="9" fill="#64748b">
            {toutes
              ? "tous les déterminismes activés — et il reste pourtant une marge"
              : "zone des choix réellement possibles"}
          </text>
          <text x="150" y="88" textAnchor="middle" fontSize="9" fontStyle="italic" fill="#475569">
            {connait
              ? "la connaissance des causes élargit la marge — Spinoza"
              : "cette marge est ce que Sartre appelle liberté"}
          </text>
        </svg>
      </div>

      <div className="grid grid-cols-2 gap-2">
        <Stat label="Poids des déterminismes" value={`${poids} points`} color={PALETTE.red} />
        <Stat label="Marge restante" value={`${Math.round(marge)} %`} color={PALETTE.green} />
      </div>

      <button
        type="button"
        onClick={() => setConnait((c) => !c)}
        className={
          connait
            ? "rounded-lg border border-border px-3 py-1.5 text-xs font-medium text-muted-foreground hover:bg-secondary/60"
            : "rounded-lg bg-primary px-3 py-1.5 text-xs font-semibold text-primary-foreground"
        }
      >
        {connait ? "Oublier à nouveau ses causes" : "Connaître ses causes"}
      </button>

      {toutes ? (
        <Verdict tone="warn">
          Tous les déterminismes sont actifs, et la zone n'est pas vide. Ce qui reste, c'est le
          choix de l'attitude — ce que <strong>Sartre</strong> appelle liberté, et ce qui lui fait
          dire qu'invoquer son éducation pour se justifier est de la <strong>mauvaise foi</strong>.
        </Verdict>
      ) : null}

      {connait ? (
        <Citation auteur="Spinoza">
          La liberté est la connaissance de la nécessité. Celui qui ignore ce qui le pousse est
          poussé ; celui qui le sait peut faire autrement — comme le médecin agit sur la cause de la
          fièvre.
        </Citation>
      ) : null}
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* 3. Le tribunal des circonstances                                    */
/* ------------------------------------------------------------------ */

type Affaire = {
  id: string;
  texte: string;
  liberte: number;
  regle: string;
};

const AFFAIRES: ReadonlyArray<Affaire> = [
  {
    id: "t1",
    texte: "Un enfant de sept ans casse la vitre du voisin en jouant.",
    liberte: 0,
    regle:
      "Pas de responsabilité pénale : l'enfant en bas âge ne discerne pas. Le droit n'impute rien à qui ne peut pas comprendre l'interdit.",
  },
  {
    id: "t2",
    texte: "Un homme remet l'argent de la caisse à un braqueur qui le menace d'une arme.",
    liberte: 5,
    regle:
      "Contrainte quasi totale : la volonté n'était pas entière. C'est l'exemple même de Rousseau — céder à la force est un acte de nécessité, non de volonté.",
  },
  {
    id: "t3",
    texte: "Une personne dont le discernement était aboli par une maladie frappe un passant.",
    liberte: 0,
    regle:
      "Irresponsabilité pénale, et soins. Le droit ne punit pas, il traite : la peine supposerait une maîtrise qui manquait.",
  },
  {
    id: "t4",
    texte: "Un conducteur ivre renverse un piéton.",
    liberte: 85,
    regle:
      "Responsabilité pleine, et même aggravée. L'ivresse n'atténue pas : c'est le fait de boire avant de conduire qui était libre, et il a été choisi.",
  },
  {
    id: "t5",
    texte: "Un jeune homme participe à un vol sous la pression insistante de son groupe.",
    liberte: 55,
    regle:
      "Circonstances atténuantes, sans disparition de la faute. La pression réduit la marge sans l'abolir : il pouvait partir.",
  },
  {
    id: "t6",
    texte: "Un père vole du lait pour son nourrisson après deux jours sans ressources.",
    liberte: 35,
    regle:
      "État de nécessité : largement atténué, parfois excusé. Le droit reconnaît qu'une liberté acculée n'est plus tout à fait une liberté.",
  },
  {
    id: "t7",
    texte:
      "Un commerçant établit de faux documents pendant deux ans, avec méthode, pour enrichir son commerce.",
    liberte: 100,
    regle:
      "Responsabilité entière. La durée et la méthode sont les marques de la pleine maîtrise : on ne prépare pas pendant deux ans ce qu'on n'a pas voulu.",
  },
  {
    id: "t8",
    texte: "Un adolescent de seize ans frappe un camarade qui venait de l'insulter publiquement.",
    liberte: 60,
    regle:
      "Minorité et provocation : deux atténuations qui se cumulent, sans effacer l'acte. Le droit module, il n'absout pas.",
  },
];

const AFFAIRE_VIDE: Affaire = { id: "", texte: "—", liberte: 0, regle: "—" };

export function TribunalCirconstances() {
  const [rang, setRang] = useState(0);
  const [mise, setMise] = useState(50);
  const [montre, setMontre] = useState(false);
  const [extreme, setExtreme] = useState<"non" | "determinisme" | "liberte">("non");

  const a = AFFAIRES[rang] ?? AFFAIRE_VIDE;
  const libEffective = extreme === "determinisme" ? 0 : extreme === "liberte" ? 100 : a.liberte;
  const peine = Math.round((libEffective / 100) * 10);
  const peineMise = Math.round((mise / 100) * 10);
  const ecart = Math.abs(mise - a.liberte);

  return (
    <div className="space-y-3">
      <p className="text-sm text-muted-foreground">
        Huit affaires. Pour chacune, fixe la part de liberté de l'auteur : la peine en découle.
        Compare ensuite ton verdict à la règle du Code, et essaie les deux boutons extrêmes.
      </p>

      <div className="rounded-lg border border-border bg-background p-3">
        <p className="text-sm leading-relaxed text-foreground">{a.texte}</p>
        <div className="mt-3">
          <Ctrl
            label="Part de liberté de l'auteur au moment de l'acte"
            value={mise}
            min={0}
            max={100}
            step={5}
            onChange={setMise}
            display={`${mise} %`}
            color={PALETTE.purple}
          />
        </div>
        <div className="mt-2 grid grid-cols-2 gap-2">
          <Stat label="Peine qui en découle" value={`${peineMise} / 10`} color={PALETTE.orange} />
          <Stat
            label="Règle du Code"
            value={montre ? `${a.liberte} % → ${peine} / 10` : "cachée"}
            color={montre ? (ecart <= 15 ? PALETTE.green : PALETTE.red) : PALETTE.slate}
          />
        </div>

        {!montre ? (
          <button
            type="button"
            onClick={() => setMontre(true)}
            className="mt-2 rounded-lg bg-primary px-3 py-1.5 text-xs font-semibold text-primary-foreground"
          >
            Comparer à la règle du Code
          </button>
        ) : (
          <div className="mt-2 space-y-2">
            <Verdict tone={ecart <= 15 ? "ok" : ecart <= 35 ? "warn" : "bad"}>
              <span className="font-semibold">
                {ecart <= 15 ? "Verdict proche. " : `Écart de ${ecart} points. `}
              </span>
              {a.regle}
            </Verdict>
            <button
              type="button"
              onClick={() => {
                setRang((r) => (r + 1) % AFFAIRES.length);
                setMontre(false);
                setMise(50);
              }}
              className="rounded-lg bg-primary px-3 py-1.5 text-xs font-semibold text-primary-foreground"
            >
              Affaire suivante ({rang + 1} / {AFFAIRES.length})
            </button>
          </div>
        )}
      </div>

      <div className="space-y-2 border-t border-border pt-3">
        <p className="text-xs font-semibold text-foreground">Les deux positions extrêmes</p>
        <div className="flex flex-wrap gap-1.5">
          {(
            [
              { v: "non", l: "le droit réel" },
              { v: "determinisme", l: "déterminisme absolu" },
              { v: "liberte", l: "liberté absolue" },
            ] as const
          ).map((o) => (
            <button
              key={o.v}
              type="button"
              onClick={() => setExtreme(o.v)}
              className={
                extreme === o.v
                  ? "rounded-lg bg-primary px-2.5 py-1 text-[11px] font-semibold text-primary-foreground"
                  : "rounded-lg border border-border px-2.5 py-1 text-[11px] text-muted-foreground hover:bg-secondary/60"
              }
            >
              {o.l}
            </button>
          ))}
        </div>
        {extreme === "determinisme" ? (
          <Verdict tone="bad">
            Toutes les peines tombent à <span className="font-mono">0 / 10</span>, pour les huit
            affaires. Si le déterminisme était absolu, toutes les circonstances seraient atténuantes
            et il ne resterait aucun coupable : on ne punit pas une pierre qui tombe. Aucune justice
            ne serait possible.
          </Verdict>
        ) : extreme === "liberte" ? (
          <Verdict tone="bad">
            Toutes les peines montent à <span className="font-mono">10 / 10</span>, y compris pour
            l'enfant de sept ans et pour l'homme menacé d'une arme. Si la liberté était absolue,
            aucune circonstance ne pourrait atténuer, et tout auteur mériterait le maximum.
          </Verdict>
        ) : (
          <Verdict tone="ok">
            Le droit réel se tient entre les deux, et il a raison : les hommes ne sont ni des
            pierres qui tombent ni des anges qui choisiraient dans le vide. Le Code pénal est{" "}
            <strong>déterministe sur les causes</strong> — il admet que l'acte s'explique — et{" "}
            <strong>libertaire sur l'imputation</strong> — il maintient que l'auteur devait
            répondre.
          </Verdict>
        )}
      </div>

      <Citation auteur="ce qu'il faut en conclure">
        Les circonstances atténuantes sont la preuve, inscrite dans le Code, que la responsabilité
        est proportionnelle à la liberté. Le droit mesure la seconde pour fixer la première — et
        c'est ce qui rend la justice possible, et difficile.
      </Citation>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* 4. Les pères du panafricanisme                                      */
/* ------------------------------------------------------------------ */

const PANAFRICAINS: ReadonlyArray<Auteur> = [
  {
    id: "blyden",
    nom: "Edward Wilmot Blyden",
    dates: "1832-1912",
    oeuvre: "Antilles, puis Libéria",
    these:
      "L'Afrique a une personnalité propre et n'a pas à devenir européenne pour valoir. L'un des tout premiers à le soutenir.",
    camp: "diaspora · culture",
  },
  {
    id: "williams",
    nom: "Henry Sylvester Williams",
    dates: "1869-1911",
    oeuvre: "première conférence panafricaine, Londres, 1900",
    these:
      "Avocat trinidadien. Il organise la rencontre qui donne au mot « panafricanisme » son acte de naissance.",
    camp: "diaspora · politique",
  },
  {
    id: "dubois",
    nom: "W. E. B. Du Bois",
    dates: "1868-1963",
    oeuvre: "les congrès panafricains, 1919 à 1945",
    these:
      "« Le problème du XXe siècle est le problème de la ligne de couleur. » Qu'on appelle le père du panafricanisme ; il finira ses jours au Ghana, invité par Nkrumah.",
    camp: "diaspora · politique",
  },
  {
    id: "garvey",
    nom: "Marcus Garvey",
    dates: "1887-1940",
    oeuvre: "Universal Negro Improvement Association",
    these:
      "« L'Afrique pour les Africains, ceux de l'intérieur comme ceux de l'extérieur. » Le retour en Afrique comme mot d'ordre.",
    camp: "diaspora · politique",
  },
  {
    id: "padmore",
    nom: "George Padmore",
    dates: "1903-1959",
    oeuvre: "conseiller de Nkrumah",
    these:
      "Trinidadien. Il fait le pont entre la diaspora et l'Afrique en voie d'indépendance : sans lui, Manchester 1945 n'aurait pas eu lieu.",
    camp: "diaspora · politique",
  },
  {
    id: "nkrumah",
    nom: "Kwame Nkrumah",
    dates: "1909-1972",
    oeuvre: "L'Afrique doit s'unir, 1963 ; Le néo-colonialisme, 1965",
    these:
      "L'union politique immédiate, et un avertissement : l'indépendance politique sans indépendance économique est une coquille vide.",
    camp: "continent · politique",
  },
  {
    id: "senghor",
    nom: "Léopold Sédar Senghor",
    dates: "1906-2001",
    oeuvre: "la négritude",
    these:
      "Le versant culturel du panafricanisme. Politiquement, il est du groupe de Monrovia : union progressive, respect des souverainetés.",
    camp: "continent · culture",
  },
  {
    id: "cesaire",
    nom: "Aimé Césaire",
    dates: "1913-2008",
    oeuvre: "Discours sur le colonialisme, 1950",
    these:
      "La négritude est « la simple reconnaissance du fait d'être noir, et l'acceptation de ce fait, de notre destin, de notre histoire et de notre culture ».",
    camp: "diaspora · culture",
  },
  {
    id: "diop",
    nom: "Cheikh Anta Diop",
    dates: "1923-1986",
    oeuvre: "Les fondements économiques et culturels d'un État fédéral d'Afrique noire, 1960",
    these:
      "La base savante du panafricanisme : aucun État africain seul n'atteint la taille critique, et la balkanisation est le premier obstacle économique du continent.",
    camp: "continent · culture",
  },
  {
    id: "sankara",
    nom: "Thomas Sankara",
    dates: "1949-1987",
    oeuvre: "Burkina Faso, 1983-1987",
    these:
      "Le panafricanisme en pratique : refus de la dette — « la dette est une reconquête de l'Afrique » —, consommation locale, autosuffisance alimentaire.",
    camp: "continent · politique",
  },
  {
    id: "nasser",
    nom: "Gamal Abdel Nasser",
    dates: "1918-1970",
    oeuvre: "groupe de Casablanca, 1961",
    these:
      "L'Égypte dans le camp unioniste, avec Nkrumah, Sékou Touré et Modibo Keïta : les États-Unis d'Afrique sans délai.",
    camp: "continent · politique",
  },
  {
    id: "houphouet",
    nom: "Félix Houphouët-Boigny",
    dates: "1905-1993",
    oeuvre: "groupe de Monrovia, 1961",
    these:
      "Avec Ahidjo, Senghor et Azikiwe : d'abord la coopération entre États souverains, l'union viendra. C'est cette voie que l'OUA retiendra en 1963.",
    camp: "continent · politique",
  },
];

const PLACEMENTS: ReadonlyArray<ItemTri> = [
  {
    id: "p1",
    texte: "Henry Sylvester Williams organise le premier congrès panafricain, à Londres en 1900.",
    bonne: "diaspora",
    pourquoi:
      "Avocat trinidadien : le mouvement naît hors du continent, et c'est le point à retenir.",
  },
  {
    id: "p2",
    texte: "Marcus Garvey lance le mot d'ordre du retour en Afrique.",
    bonne: "diaspora",
    pourquoi:
      "Jamaïcain, installé aux États-Unis. Il appelle à revenir dans un pays qu'il n'a pas quitté.",
  },
  {
    id: "p3",
    texte: "Du Bois organise les congrès de 1919 à 1945 et finira ses jours au Ghana.",
    bonne: "diaspora",
    pourquoi:
      "Sociologue américain, qu'on nomme le père du panafricanisme. Son installation au Ghana montre le trajet du mouvement.",
  },
  {
    id: "p4",
    texte: "Nkrumah publie L'Afrique doit s'unir en 1963.",
    bonne: "continent",
    pourquoi:
      "Ghana. À partir de Manchester 1945, les militants du continent prennent la direction du mouvement.",
  },
  {
    id: "p5",
    texte: "Cheikh Anta Diop démontre qu'aucun État africain seul n'atteint la taille critique.",
    bonne: "continent",
    pourquoi: "Sénégal. C'est la base savante de l'unité, et l'argument tient encore.",
  },
  {
    id: "p6",
    texte: "Sankara refuse la dette et impose la consommation locale au Burkina Faso.",
    bonne: "continent",
    pourquoi: "Le panafricanisme cessant d'être un discours de sommet pour devenir une pratique.",
  },
  {
    id: "p7",
    texte:
      "Césaire définit la négritude comme la reconnaissance et l'acceptation du fait d'être noir.",
    bonne: "diaspora",
    pourquoi:
      "Martinique. La négritude naît à Paris, entre un Martiniquais, un Sénégalais et un Guyanais : elle est d'abord une rencontre de diaspora.",
  },
  {
    id: "p8",
    texte:
      "Houphouët-Boigny et Ahidjo défendent l'union progressive au sein du groupe de Monrovia.",
    bonne: "continent",
    pourquoi:
      "Côte d'Ivoire et Cameroun. Ce sont des chefs d'État en exercice, et c'est leur voie que l'OUA retiendra.",
  },
];

export function PeresPanafricanisme() {
  return (
    <div className="space-y-4">
      <JeuTri
        consigne="Huit moments du mouvement. Pour chacun, dis d'où il part : de la diaspora ou du continent. La réponse raconte à elle seule l'histoire du panafricanisme."
        categories={[
          { value: "diaspora", label: "La diaspora", aide: "Antilles, États-Unis, Europe" },
          { value: "continent", label: "Le continent", aide: "Afrique, après 1945 surtout" },
        ]}
        items={PLACEMENTS}
        conclusion={
          <>
            Le partage est net, et sa date est <strong>1945</strong> : le congrès de Manchester.
            Avant, le panafricanisme est une pensée de la diaspora sur l'Afrique, et il réclame des
            droits. Après, il devient le programme politique des futurs États africains, et il
            réclame l'indépendance. L'idée a fait le trajet inverse de la traite : partie d'Afrique
            dans les cales, elle est revenue par les congrès.
          </>
        }
      />
      <div className="border-t border-border pt-3">
        <p className="mb-2 text-xs font-semibold text-foreground">
          Les douze figures — clique pour ouvrir la fiche
        </p>
        <Galerie auteurs={PANAFRICAINS} />
        <p className="mt-2 text-[11px] leading-snug text-muted-foreground">
          Ne confonds pas les deux versants. <strong>Senghor et Césaire</strong> sont du côté
          culturel — la négritude. <strong>Nkrumah, Nasser et Houphouët-Boigny</strong> sont du côté
          politique, et ces deux derniers dans des camps opposés. <strong>Cheikh Anta Diop</strong>{" "}
          fournit la démonstration savante que les politiques utiliseront.
        </p>
      </div>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* 5. Casablanca ou Monrovia ?                                         */
/* ------------------------------------------------------------------ */

type Levier = {
  id: string;
  label: string;
  casablanca: string;
  monrovia: string;
};

const LEVIERS: ReadonlyArray<Levier> = [
  {
    id: "monnaie",
    label: "Monnaie",
    casablanca: "une monnaie unique",
    monrovia: "les monnaies nationales",
  },
  {
    id: "armee",
    label: "Armée",
    casablanca: "un commandement unique",
    monrovia: "des armées nationales",
  },
  {
    id: "frontieres",
    label: "Frontières",
    casablanca: "redécoupées selon les peuples",
    monrovia: "intangibles, telles qu'héritées",
  },
  {
    id: "ingerence",
    label: "Affaires intérieures",
    casablanca: "droit de regard mutuel",
    monrovia: "non-ingérence absolue",
  },
  {
    id: "marche",
    label: "Économie",
    casablanca: "un marché commun immédiat",
    monrovia: "des accords bilatéraux",
  },
];

export function CasablancaMonrovia() {
  const [choix, setChoix] = useState<Record<string, "c" | "m">>({
    monnaie: "m",
    armee: "m",
    frontieres: "m",
    ingerence: "m",
    marche: "m",
  });

  const nbC = LEVIERS.filter((l) => choix[l.id] === "c").length;
  const unioniste = (nbC / LEVIERS.length) * 100;

  const integration = choix["marche"] === "c" || choix["monnaie"] === "c";
  const poids = Math.round(Math.min(100, 20 + unioniste * 0.7 + (integration ? 12 : 0)));
  const stabilite = Math.round(
    Math.min(
      100,
      Math.max(
        0,
        92 -
          (choix["frontieres"] === "c" ? 42 : 0) -
          (choix["armee"] === "c" ? 18 : 0) -
          (choix["ingerence"] === "c" ? 12 : 0),
      ),
    ),
  );
  const autonomie = Math.round(
    Math.min(
      100,
      18 +
        (choix["marche"] === "c" ? 30 : 6) +
        (choix["monnaie"] === "c" ? 26 : 4) +
        (choix["armee"] === "c" ? 10 : 2),
    ),
  );

  const nom =
    nbC === 0
      ? "l'OUA réelle de 1963"
      : nbC === LEVIERS.length
        ? "les États-Unis d'Afrique de Nkrumah"
        : nbC >= 3
          ? "un projet proche de Casablanca"
          : "un projet proche de Monrovia";

  return (
    <div className="space-y-3">
      <p className="text-sm text-muted-foreground">
        Tu es à la table d'Addis-Abeba, en 1963. Règle les cinq leviers, et regarde les trois jauges
        répondre. Commence par l'OUA réelle — tout à droite — puis essaie les États-Unis d'Afrique.
      </p>

      <ul className="space-y-1.5">
        {LEVIERS.map((l) => {
          const v = choix[l.id] ?? "m";
          return (
            <li key={l.id} className="rounded-lg border border-border bg-background p-2">
              <p className="text-[11px] font-semibold uppercase tracking-wide text-muted-foreground">
                {l.label}
              </p>
              <div className="mt-1 flex flex-wrap gap-1.5">
                {[
                  { k: "c" as const, t: l.casablanca, c: PALETTE.red },
                  { k: "m" as const, t: l.monrovia, c: PALETTE.blue },
                ].map((o) => (
                  <button
                    key={o.k}
                    type="button"
                    onClick={() => setChoix((x) => ({ ...x, [l.id]: o.k }))}
                    className={
                      v === o.k
                        ? "rounded-lg px-2.5 py-1 text-xs font-semibold text-white"
                        : "rounded-lg border border-border bg-background px-2.5 py-1 text-xs text-muted-foreground hover:bg-secondary/60"
                    }
                    style={v === o.k ? { backgroundColor: o.c } : undefined}
                  >
                    {o.t}
                  </button>
                ))}
              </div>
            </li>
          );
        })}
      </ul>

      <div className="grid grid-cols-2 gap-2">
        <Stat label="Leviers unionistes" value={`${nbC} / ${LEVIERS.length}`} color={PALETTE.red} />
        <Stat label="Ton projet" value={nom} color={PALETTE.purple} />
      </div>

      <Jauges
        jauges={[
          { label: "Poids diplomatique", valeur: poids, couleur: PALETTE.purple },
          { label: "Stabilité du continent", valeur: stabilite, couleur: PALETTE.blue },
          { label: "Autonomie économique", valeur: autonomie, couleur: PALETTE.green },
        ]}
      />

      {nbC === 0 ? (
        <Verdict tone="warn">
          C'est l'OUA de 1963, et la thèse de Monrovia l'a emporté. La <strong>stabilité</strong>{" "}
          est haute : l'intangibilité des frontières a épargné au continent les guerres de
          frontières généralisées que tout rendait possibles. L'{" "}
          <strong>autonomie économique</strong>, elle, stagne — et c'est exactement le reproche de
          Nkrumah. La non-ingérence a aussi rendu l'organisation muette devant les dictatures de ses
          propres membres, d'où le surnom de « syndicat des chefs d'État ».
        </Verdict>
      ) : nbC === LEVIERS.length ? (
        <Verdict tone="bad">
          Les États-Unis d'Afrique, tout de suite. Le <strong>poids diplomatique</strong> et l'
          <strong>autonomie</strong> montent — mais regarde la <strong>stabilité</strong>{" "}
          s'effondrer : redécouper les frontières réveille toutes les revendications à la fois. Les
          fédérations réellement tentées — la Fédération du Mali, la République arabe unie — ont
          éclaté en quelques mois.
        </Verdict>
      ) : (
        <Verdict tone="ok">
          Position intermédiaire, et c'est celle vers laquelle l'Union africaine de 2002 s'est
          déplacée : garder les frontières, abandonner la non-ingérence absolue, construire un
          marché commun. Les gradualistes ont gagné la méthode, les unionistes avaient le bon
          diagnostic.
        </Verdict>
      )}

      <Citation auteur="Nkrumah, L'Afrique doit s'unir, 1963">
        L'indépendance politique sans indépendance économique n'est qu'une façade — et c'est ce
        qu'il nommera deux ans plus tard le néo-colonialisme, dernier stade de l'impérialisme.
      </Citation>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* 6. Croissance ou développement ?                                    */
/* ------------------------------------------------------------------ */

const POSTES_BUDGET = [
  { id: "mine", label: "Extraction minière et pétrolière", prod: 1.0, apt: 0.02 },
  { id: "import", label: "Importations de produits finis", prod: 0.35, apt: 0.0 },
  { id: "ecole", label: "École et alphabétisation", prod: 0.05, apt: 1.0 },
  { id: "sante", label: "Santé", prod: 0.1, apt: 0.55 },
  { id: "routes", label: "Routes et énergie", prod: 0.4, apt: 0.4 },
  { id: "techno", label: "Formation technique et recherche", prod: 0.15, apt: 0.85 },
] as const;

export function CroissanceDeveloppement() {
  const [part, setPart] = useState<Record<string, number>>({
    mine: 40,
    import: 20,
    ecole: 10,
    sante: 10,
    routes: 15,
    techno: 5,
  });

  const total = POSTES_BUDGET.reduce((s, p) => s + (part[p.id] ?? 0), 0);

  const { production, aptitude } = useMemo(() => {
    const prodPoids = POSTES_BUDGET.reduce(
      (s, p) => s + ((part[p.id] ?? 0) / Math.max(1, total)) * p.prod,
      0,
    );
    const aptPoids = POSTES_BUDGET.reduce(
      (s, p) => s + ((part[p.id] ?? 0) / Math.max(1, total)) * p.apt,
      0,
    );
    const partMine = (part["mine"] ?? 0) / Math.max(1, total);

    const prod: number[] = [];
    const apt: number[] = [];
    for (let an = 0; an <= 20; an++) {
      // l'aptitude de la population monte lentement, puis se cumule
      const a = Math.min(100, 8 + aptPoids * an * 5.2);
      // la production suit les investissements, mais le gisement s'épuise
      const epuisement = partMine > 0.3 ? Math.max(0, 1 - Math.max(0, an - 10) / 8) : 1;
      const p = Math.min(
        100,
        10 + prodPoids * an * 4.4 * epuisement + a * 0.35 * Math.min(1, an / 10),
      );
      prod.push(p);
      apt.push(a);
    }
    return { production: prod, aptitude: apt };
  }, [part, total]);

  const prodFin = production[20] ?? 0;
  const aptFin = aptitude[20] ?? 0;
  const prodMax = Math.max(...production);

  function ligne(serie: ReadonlyArray<number>) {
    return serie
      .map((v, i) => `${(20 + i * 13).toFixed(1)},${(118 - v * 0.98).toFixed(1)}`)
      .join(" ");
  }

  const effondrement = prodMax > prodFin + 15;

  const diagnostic =
    effondrement && aptFin < 45
      ? {
          ton: "bad" as const,
          titre: "Croissance sans développement",
          note: "La production s'est envolée, puis s'est écroulée quand le gisement s'est épuisé, et le pays se retrouve où il était parti. Rien dans la population n'a été rendu apte à produire autrement : c'est ce que les économistes nomment la malédiction des matières premières.",
        }
      : aptFin >= 55 && prodFin >= 45
        ? {
            ton: "ok" as const,
            titre: "Développement au sens de Perroux",
            note: "Les deux courbes montent, et celle de la production ne redescend plus : elle est soutenue par l'aptitude de la population. « La combinaison des changements mentaux et sociaux d'une population qui la rendent apte à faire croître cumulativement et durablement son produit réel global. »",
          }
        : aptFin >= 50
          ? {
              ton: "warn" as const,
              titre: "Développement lent mais durable",
              note: "Rien ne bouge pendant dix ans, puis la courbe décolle et ne redescend plus. C'est le cas le plus instructif : un pays peut n'avoir aucune croissance pendant une décennie et se développer.",
            }
          : {
              ton: "warn" as const,
              titre: "Ni l'un ni l'autre",
              note: "Le budget est dispersé : ni rente extractive, ni investissement dans les capacités. Mets tout sur l'extraction, puis tout sur l'école, et compare les deux formes d'échec et de réussite.",
            };

  return (
    <div className="space-y-3">
      <p className="text-sm text-muted-foreground">
        Tu diriges un pays pendant vingt ans et tu répartis ton budget. Deux courbes avancent côte à
        côte : la production d'un côté, l'aptitude de la population de l'autre. Mise tout sur
        l'extraction, puis tout sur l'école, et compare.
      </p>

      <div className="space-y-2">
        {POSTES_BUDGET.map((p) => (
          <Ctrl
            key={p.id}
            label={p.label}
            value={part[p.id] ?? 0}
            min={0}
            max={100}
            step={5}
            onChange={(v) => setPart((x) => ({ ...x, [p.id]: v }))}
            display={`${Math.round(((part[p.id] ?? 0) / Math.max(1, total)) * 100)} % du budget`}
            color={p.apt > 0.5 ? PALETTE.green : p.prod > 0.5 ? PALETTE.orange : PALETTE.blue}
          />
        ))}
      </div>

      <div className="rounded-lg border border-border bg-background p-3">
        <svg
          viewBox="0 0 300 140"
          width="100%"
          height="150"
          role="img"
          aria-label="Production et aptitude sur vingt ans"
        >
          <line x1="20" y1="118" x2="288" y2="118" stroke="#334155" strokeWidth="1.2" />
          <line x1="20" y1="18" x2="20" y2="118" stroke="#334155" strokeWidth="1.2" />
          {[0, 5, 10, 15, 20].map((an) => (
            <g key={an}>
              <line
                x1={(20 + an * 13).toFixed(1)}
                y1="118"
                x2={(20 + an * 13).toFixed(1)}
                y2="121"
                stroke="#334155"
              />
              <text
                x={(20 + an * 13).toFixed(1)}
                y="131"
                textAnchor="middle"
                fontSize="8"
                fill="#64748b"
              >
                an {an}
              </text>
            </g>
          ))}
          <polyline points={ligne(production)} fill="none" stroke="#ea580c" strokeWidth="2" />
          <polyline points={ligne(aptitude)} fill="none" stroke="#16a34a" strokeWidth="2" />
          <text x="288" y="14" textAnchor="end" fontSize="8" fill="#ea580c">
            production
          </text>
          <text x="288" y="24" textAnchor="end" fontSize="8" fill="#16a34a">
            aptitude de la population
          </text>
        </svg>
      </div>

      <div className="grid grid-cols-2 gap-2 sm:grid-cols-3">
        <Stat label="Production, an 20" value={`${Math.round(prodFin)} %`} color={PALETTE.orange} />
        <Stat label="Pic de production" value={`${Math.round(prodMax)} %`} color={PALETTE.red} />
        <Stat label="Aptitude, an 20" value={`${Math.round(aptFin)} %`} color={PALETTE.green} />
      </div>

      <Verdict tone={diagnostic.ton}>
        <span className="font-semibold">{diagnostic.titre}. </span>
        {diagnostic.note}
      </Verdict>

      <Citation auteur="François Perroux">
        Le développement est la combinaison des changements mentaux et sociaux d'une population qui
        la rendent apte à faire croître cumulativement et durablement son produit réel global.
      </Citation>
      <p className="text-[11px] leading-snug text-muted-foreground">
        Pèse ces mots : <strong>changements mentaux et sociaux</strong>. La croissance est un
        chiffre, le développement une transformation. C'est pourquoi Njoh Mouelle peut écrire que le
        sous-développement est d'abord un état d'esprit — et pourquoi le développement ne s'achète
        pas.
      </p>
    </div>
  );
}
