import { useState } from "react";
import { PALETTE, Verdict } from "./controls";
import {
  Citation,
  Galerie,
  JeuTri,
  MettreEnOrdre,
  Qcm,
  type Auteur,
  type ElementOrdre,
  type ItemTri,
  type Question,
} from "./philo-noyau";

/** Philosophie Terminale C et D — chapitre 1 : la philosophie africaine. */

/* ------------------------------------------------------------------ */
/* 1. Proverbe, sagesse, philosophie : les trois critères              */
/* ------------------------------------------------------------------ */

type Enonce = {
  id: string;
  texte: string;
  source: string;
  auteur: boolean;
  argument: boolean;
  refutable: boolean;
  verdict: string;
};

const ENONCES: ReadonlyArray<Enonce> = [
  {
    id: "e1",
    texte: "« La main qui donne est toujours au-dessus de celle qui reçoit. »",
    source: "proverbe bamiléké",
    auteur: false,
    argument: false,
    refutable: true,
    verdict:
      "Une sagesse, et une vraie. Mais personne ne la signe et personne ne l'argumente : on la transmet. Elle vaut une thèse sans être une philosophie.",
  },
  {
    id: "e2",
    texte:
      "« Ne sois pas orgueilleux de ton savoir, prends conseil de l'ignorant comme du savant. »",
    source: "Ptahhotep, Maximes, Égypte, environ 2400 avant notre ère",
    auteur: true,
    argument: true,
    refutable: true,
    verdict:
      "Les trois critères passent : un auteur nommé, une raison donnée — l'art n'a pas de limite atteinte —, et une thèse qu'on peut discuter. C'est le texte que les africanistes opposent à l'idée d'une Afrique sans écriture philosophique.",
  },
  {
    id: "e3",
    texte: "« Je pense, donc je suis. »",
    source: "Descartes, Discours de la méthode, 1637",
    auteur: true,
    argument: true,
    refutable: true,
    verdict:
      "Philosophie au sens plein : un auteur, une démonstration qui précède la formule, et des objections réelles — on lui a reproché de conclure à une substance là où il n'y avait qu'un acte.",
  },
  {
    id: "e4",
    texte: "« Au commencement, Dieu créa le ciel et la terre. »",
    source: "Genèse 1,1",
    auteur: false,
    argument: false,
    refutable: false,
    verdict:
      "Un énoncé religieux. Il ne se donne pas comme discutable mais comme révélé, et c'est pourquoi il n'entre pas dans le même genre : la foi n'a pas à se démontrer, la philosophie si.",
  },
  {
    id: "e5",
    texte:
      "« L'Afrique n'a pas d'histoire : elle est restée fermée, enfoncée dans l'esprit de la nature. »",
    source: "Hegel, Leçons sur la philosophie de l'histoire",
    auteur: true,
    argument: true,
    refutable: true,
    verdict:
      "C'est bien de la philosophie, et c'est précisément pour cela qu'on peut la réfuter — ce que Cheikh Anta Diop a fait avec des documents. Un énoncé philosophique n'est pas un énoncé vrai : c'est un énoncé qu'on peut attaquer avec des raisons.",
  },
  {
    id: "e6",
    texte:
      "« Il faut que l'Africain cesse de se définir par ce que les autres ont dit de lui, et se pense à partir de ses propres tâches. »",
    source: "Marcien Towa, Essai sur la problématique philosophique dans l'Afrique actuelle, 1971",
    auteur: true,
    argument: true,
    refutable: true,
    verdict:
      "Philosophie. Towa argumente, et on lui a objecté qu'il acceptait du même coup les critères occidentaux de la philosophie. La discussion est ouverte : c'est le signe.",
  },
  {
    id: "e7",
    texte: "« Quand on dort sur la natte des autres, c'est comme si on dormait par terre. »",
    source: "proverbe cité par Joseph Ki-Zerbo",
    auteur: false,
    argument: false,
    refutable: true,
    verdict:
      "Deux critères sur trois seulement, et c'est l'un des cas intéressants : Ki-Zerbo le cite comme argument dans une démonstration. Le proverbe devient alors une prémisse philosophique, sans cesser d'être un proverbe.",
  },
  {
    id: "e8",
    texte: "« Chez le Bantou, l'être est force, et la force est être. »",
    source: "Placide Tempels, La Philosophie bantoue, 1945",
    auteur: true,
    argument: true,
    refutable: true,
    verdict:
      "Un auteur, une argumentation. Mais Hountondji objecte que Tempels parle au nom d'un peuple entier sans qu'aucun Bantou l'ait écrit : la thèse serait une philosophie SUR les Africains, non DES Africains.",
  },
  {
    id: "e9",
    texte: "« Le mental des primitifs est prélogique : il ne craint pas la contradiction. »",
    source: "Lucien Lévy-Bruhl, Les fonctions mentales dans les sociétés inférieures, 1910",
    auteur: true,
    argument: true,
    refutable: true,
    verdict:
      "Réfutable, et réfutée — par son propre auteur. Lévy-Bruhl est revenu sur cette thèse dans ses Carnets, à la fin de sa vie. C'est le modèle de l'honnêteté philosophique.",
  },
  {
    id: "e10",
    texte: "« Respecte les anciens, car ils savent. »",
    source: "sagesse transmise, sans source identifiée",
    auteur: false,
    argument: false,
    refutable: true,
    verdict:
      "Sagesse. Remarquez qu'elle contredit Ptahhotep, qui demandait de prendre conseil de l'ignorant comme du savant : deux sagesses peuvent se contredire sans que personne n'arbitre, et c'est là que la philosophie devient nécessaire.",
  },
  {
    id: "e11",
    texte:
      "« Enquête sur l'existence de Dieu par la raison, sans t'appuyer sur l'autorité d'aucun livre. »",
    source: "Zera Yacob, Hatata, Éthiopie, 1667",
    auteur: true,
    argument: true,
    refutable: true,
    verdict:
      "Philosophie, et écrite en Afrique treize ans après les Méditations de Descartes. Zera Yacob soumet les religions de son temps à l'examen de la raison seule : c'est le geste philosophique à l'état pur.",
  },
  {
    id: "e12",
    texte:
      "« Il faut passer de la médiocrité à l'excellence : le développement est d'abord mental. »",
    source: "Ebénézer Njoh Mouelle, De la médiocrité à l'excellence, 1970",
    auteur: true,
    argument: true,
    refutable: true,
    verdict:
      "Philosophie camerounaise, et au programme. On lui objecte qu'elle fait porter aux individus ce qui relève des structures — l'objection est bonne, et c'est ainsi qu'une thèse vit.",
  },
];

const ENONCE_VIDE: Enonce = {
  id: "",
  texte: "—",
  source: "—",
  auteur: false,
  argument: false,
  refutable: false,
  verdict: "—",
};

function Critere({
  label,
  attendu,
  choisi,
  onChange,
}: {
  label: string;
  attendu: boolean;
  choisi: boolean | null;
  onChange: (v: boolean) => void;
}) {
  const bon = choisi !== null && choisi === attendu;
  return (
    <div className="space-y-1">
      <p className="text-[11px] font-medium text-muted-foreground">{label}</p>
      <div className="flex gap-1">
        {[true, false].map((v) => {
          const actif = choisi === v;
          const cls = !actif
            ? "border-border bg-background text-muted-foreground hover:bg-secondary/60"
            : bon
              ? "border-emerald-500/40 bg-emerald-500/15 text-emerald-700"
              : "border-rose-500/40 bg-rose-500/15 text-rose-700";
          return (
            <button
              key={v ? "oui" : "non"}
              type="button"
              onClick={() => onChange(v)}
              className={`rounded-lg border px-2.5 py-1 text-xs font-medium ${cls}`}
            >
              {v ? "oui" : "non"}
            </button>
          );
        })}
      </div>
    </div>
  );
}

export function DistinguerPhilosophie() {
  const [rang, setRang] = useState(0);
  const [rep, setRep] = useState<{ a: boolean | null; g: boolean | null; r: boolean | null }>({
    a: null,
    g: null,
    r: null,
  });

  const e = ENONCES[rang] ?? ENONCE_VIDE;
  const complet = rep.a !== null && rep.g !== null && rep.r !== null;
  const tout = complet && rep.a === e.auteur && rep.g === e.argument && rep.r === e.refutable;
  const nb = [e.auteur, e.argument, e.refutable].filter(Boolean).length;

  return (
    <div className="space-y-3">
      <p className="text-sm text-muted-foreground">
        Pour chaque énoncé, applique les trois critères du cours. Un énoncé philosophique a un
        auteur identifiable, il donne ses raisons, et il peut être contredit. Attention : « peut
        être contredit » ne veut pas dire « est faux ».
      </p>

      <div className="rounded-lg border border-border bg-background p-3">
        <p className="text-sm leading-relaxed text-foreground">{e.texte}</p>
        <p className="mt-1 text-[11px] italic text-muted-foreground">{e.source}</p>

        <div className="mt-3 grid gap-2 sm:grid-cols-3">
          <Critere
            label="Un auteur identifiable ?"
            attendu={e.auteur}
            choisi={rep.a}
            onChange={(v) => setRep((r) => ({ ...r, a: v }))}
          />
          <Critere
            label="Des raisons données ?"
            attendu={e.argument}
            choisi={rep.g}
            onChange={(v) => setRep((r) => ({ ...r, g: v }))}
          />
          <Critere
            label="Peut-on le contredire ?"
            attendu={e.refutable}
            choisi={rep.r}
            onChange={(v) => setRep((r) => ({ ...r, r: v }))}
          />
        </div>

        {complet ? (
          <div className="mt-3 space-y-2">
            <p
              className="font-mono text-xs font-semibold"
              style={{
                color: nb === 3 ? PALETTE.green : nb === 2 ? PALETTE.orange : PALETTE.slate,
              }}
            >
              {nb} critère(s) sur 3 →{" "}
              {nb === 3 ? "philosophie" : nb === 2 ? "cas discuté" : "sagesse ou foi"}
            </p>
            <Verdict tone={tout ? "ok" : "warn"}>{e.verdict}</Verdict>
            <div className="flex gap-2">
              <button
                type="button"
                onClick={() => {
                  setRang((r) => (r + 1) % ENONCES.length);
                  setRep({ a: null, g: null, r: null });
                }}
                className="rounded-lg bg-primary px-3 py-1.5 text-xs font-semibold text-primary-foreground"
              >
                Énoncé suivant
              </button>
              <span className="self-center text-[11px] text-muted-foreground">
                {rang + 1} / {ENONCES.length}
              </span>
            </div>
          </div>
        ) : null}
      </div>

      <p className="text-[11px] leading-snug text-muted-foreground">
        Les énoncés à deux critères sur trois sont les plus instructifs : c'est là que la querelle
        de l'ethnophilosophie a commencé. Un proverbe porte une thèse sans la signer ni la démontrer
        ; dès qu'un auteur s'en sert comme prémisse, il entre dans la philosophie.
      </p>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* 2. Attribuer une thèse à son auteur                                 */
/* ------------------------------------------------------------------ */

const AUTEURS_CH1: ReadonlyArray<Auteur> = [
  {
    id: "hegel",
    nom: "Hegel",
    dates: "1770-1831",
    oeuvre: "Leçons sur la philosophie de l'histoire",
    these:
      "L'Afrique noire serait hors de l'histoire universelle, enfoncée dans la nature et sans conscience de soi. Thèse ethnocentriste, réfutée par les documents que Cheikh Anta Diop a produits.",
    camp: "ethnocentrisme",
  },
  {
    id: "levy",
    nom: "Lucien Lévy-Bruhl",
    dates: "1857-1939",
    oeuvre: "Les fonctions mentales dans les sociétés inférieures, 1910",
    these:
      "Le « mental primitif » serait prélogique et indifférent à la contradiction. Il est revenu sur cette thèse dans ses Carnets, à la fin de sa vie : la mention de ce reniement vaut des points.",
    camp: "ethnocentrisme",
  },
  {
    id: "diop",
    nom: "Cheikh Anta Diop",
    dates: "1923-1986",
    oeuvre: "Nations nègres et culture, 1954",
    these:
      "L'Égypte pharaonique est une civilisation nègre, et l'Afrique noire possède une unité culturelle. La philosophie grecque a reçu de l'Égypte plus qu'elle ne l'a dit.",
    camp: "africanisme",
  },
  {
    id: "tempels",
    nom: "Placide Tempels",
    dates: "1906-1977",
    oeuvre: "La Philosophie bantoue, 1945",
    these:
      "Les Bantous auraient une ontologie implicite de la force vitale : être, c'est être une force. Acte fondateur de l'ethnophilosophie — et sa principale faiblesse, car l'auteur est un missionnaire belge.",
    camp: "ethnophilosophie",
  },
  {
    id: "kagame",
    nom: "Alexis Kagame",
    dates: "1912-1981",
    oeuvre: "La Philosophie bantu-rwandaise de l'Être, 1956",
    these:
      "La structure de la langue bantoue porte une métaphysique : les classes nominales distinguent des catégories d'être. L'ethnophilosophie reprise par un Africain, et avec de la linguistique.",
    camp: "ethnophilosophie",
  },
  {
    id: "towa",
    nom: "Marcien Towa",
    dates: "1931-2014",
    oeuvre: "Essai sur la problématique philosophique dans l'Afrique actuelle, 1971",
    these:
      "L'ethnophilosophie enferme l'Africain dans son passé. Il faut une philosophie critique, qui pense les tâches du présent — quitte à rompre avec la tradition.",
    camp: "critique",
  },
  {
    id: "hountondji",
    nom: "Paulin Hountondji",
    dates: "né en 1942",
    oeuvre: "Sur la « philosophie africaine », 1976",
    these:
      "Il n'y a de philosophie que par textes écrits et signés, discutables un par un. Une « vision du monde » collective et anonyme n'est pas une philosophie : l'ethnophilosophie est une illusion.",
    camp: "critique",
  },
  {
    id: "eboussi",
    nom: "Fabien Eboussi Boulaga",
    dates: "1934-2018",
    oeuvre: "La crise du Muntu, 1977",
    these:
      "Les deux camps se trompent de question. Au lieu de prouver que l'Afrique a une philosophie, il faut philosopher sur la situation réelle de l'Africain d'aujourd'hui.",
    camp: "troisième voie",
  },
];

const ATTRIBUTIONS: ReadonlyArray<Question> = [
  {
    id: "a1",
    enonce:
      "« L'Afrique est restée fermée sur elle-même, enfoncée dans l'esprit de la nature, et c'est pourquoi elle n'a pas d'histoire. »",
    options: [
      {
        texte: "Hegel",
        bonne: true,
        retour:
          "Oui, dans les Leçons sur la philosophie de l'histoire. C'est la formulation la plus citée de la thèse ethnocentriste.",
      },
      {
        texte: "Lévy-Bruhl",
        bonne: false,
        retour:
          "Non. Lévy-Bruhl parle du « mental prélogique », pas de l'absence d'histoire — et il est anthropologue, pas philosophe de l'histoire.",
      },
      {
        texte: "Tempels",
        bonne: false,
        retour:
          "Non : Tempels affirme au contraire que les Bantous ont une philosophie. Il est du camp adverse, même si on lui reproche autre chose.",
      },
      {
        texte: "Towa",
        bonne: false,
        retour: "Impossible : Towa est camerounais et consacre son œuvre à réfuter cette idée.",
      },
    ],
    suite: "Cheikh Anta Diop a opposé à cette thèse des sources écrites et des datations.",
  },
  {
    id: "a2",
    enonce:
      "« Chez le Bantou, l'être est force et la force est être. Toute sa sagesse repose sur cette ontologie. »",
    options: [
      {
        texte: "Placide Tempels",
        bonne: true,
        retour: "Oui, La Philosophie bantoue, 1945. C'est l'acte fondateur de l'ethnophilosophie.",
      },
      {
        texte: "Alexis Kagame",
        bonne: false,
        retour:
          "Pas loin : Kagame prolonge Tempels, mais sa démonstration passe par les classes nominales de la langue, non par la force vitale.",
      },
      {
        texte: "Hountondji",
        bonne: false,
        retour:
          "Non, c'est exactement ce que Hountondji refuse : une philosophie attribuée à un peuple entier sans qu'aucun de ses membres l'ait écrite.",
      },
      {
        texte: "Eboussi Boulaga",
        bonne: false,
        retour: "Non : Eboussi Boulaga renvoie les deux camps à une autre question.",
      },
    ],
    suite:
      "Le reproche décisif : l'auteur est un missionnaire belge, et aucun Bantou n'a signé cette philosophie.",
  },
  {
    id: "a3",
    enonce:
      "« Il n'y a de philosophie que par textes écrits, signés, et discutables un par un. Une vision du monde collective et anonyme n'en est pas une. »",
    options: [
      {
        texte: "Paulin Hountondji",
        bonne: true,
        retour:
          "Oui, Sur la « philosophie africaine », 1976. C'est la critique la plus serrée de l'ethnophilosophie.",
      },
      {
        texte: "Marcien Towa",
        bonne: false,
        retour:
          "Towa critique aussi l'ethnophilosophie, mais son argument est politique : elle enferme l'Africain dans son passé. Celui-ci est un critère formel de ce qu'est une philosophie.",
      },
      {
        texte: "Kagame",
        bonne: false,
        retour: "Non : Kagame est du camp que cette phrase attaque.",
      },
      {
        texte: "Hegel",
        bonne: false,
        retour:
          "Non, et attention au contresens : Hountondji n'est pas ethnocentriste. Il refuse l'ethnophilosophie pour défendre une philosophie africaine d'auteurs.",
      },
    ],
    suite:
      "À retenir pour les dissertations : Towa et Hountondji sont dans le même camp par deux chemins différents.",
  },
  {
    id: "a4",
    enonce:
      "« Le mental des primitifs est prélogique : il ne craint pas la contradiction comme le nôtre. »",
    options: [
      {
        texte: "Lucien Lévy-Bruhl",
        bonne: true,
        retour:
          "Oui, 1910. Et l'essentiel est ailleurs : il s'est rétracté dans ses Carnets, publiés après sa mort. Le signaler montre que vous avez lu plus que le manuel.",
      },
      {
        texte: "Hegel",
        bonne: false,
        retour:
          "Non. Hegel écrit un demi-siècle plus tôt et parle d'histoire, pas de fonctionnement mental.",
      },
      {
        texte: "Heidegger",
        bonne: false,
        retour:
          "Non. Heidegger soutient que la philosophie est grecque par essence — autre thèse, autre argument.",
      },
      {
        texte: "Tempels",
        bonne: false,
        retour:
          "Non, l'inverse : Tempels cherche à montrer la cohérence logique de la pensée bantoue.",
      },
    ],
  },
  {
    id: "a5",
    enonce:
      "« L'Égypte pharaonique est une civilisation nègre, et l'Afrique noire possède une unité culturelle qu'on peut établir par documents. »",
    options: [
      {
        texte: "Cheikh Anta Diop",
        bonne: true,
        retour:
          "Oui, Nations nègres et culture, 1954. Sa force est d'avoir répondu à Hegel sur le terrain des preuves, et non des principes.",
      },
      {
        texte: "Towa",
        bonne: false,
        retour:
          "Non. Towa se méfie de ce retour au passé glorieux : il y voit une consolation qui dispense d'agir.",
      },
      {
        texte: "Senghor",
        bonne: false,
        retour:
          "Senghor est proche par le projet, mais sa négritude est une thèse culturelle et poétique ; Diop travaille en historien et en linguiste.",
      },
      {
        texte: "Kagame",
        bonne: false,
        retour: "Non : Kagame travaille sur la langue bantoue, pas sur l'Égypte.",
      },
    ],
  },
  {
    id: "a6",
    enonce:
      "« Cessons de demander si l'Afrique a une philosophie. Philosophons sur la situation réelle de l'Africain d'aujourd'hui. »",
    options: [
      {
        texte: "Fabien Eboussi Boulaga",
        bonne: true,
        retour:
          "Oui, La crise du Muntu, 1977. C'est la troisième voie, et c'est la position la plus solide pour conclure une dissertation.",
      },
      {
        texte: "Hountondji",
        bonne: false,
        retour:
          "Hountondji reste dans la question de la définition. Eboussi Boulaga la déclare mal posée : ce n'est pas le même geste.",
      },
      {
        texte: "Njoh Mouelle",
        bonne: false,
        retour:
          "Njoh Mouelle est proche, mais son objet est le passage de la médiocrité à l'excellence, c'est-à-dire le développement.",
      },
      {
        texte: "Tempels",
        bonne: false,
        retour: "Non : Tempels est au cœur de la querelle que cette phrase veut dépasser.",
      },
    ],
  },
];

export function TheseAuteurAfricaine() {
  return (
    <div className="space-y-4">
      <Qcm
        consigne="Six thèses te sont servies sans le nom de leur auteur. Attribue-les. Chaque erreur t'explique pourquoi la thèse ne peut pas être de celui que tu as désigné — et c'est souvent plus instructif que la bonne réponse."
        questions={ATTRIBUTIONS}
        conclusion={
          <>
            Une thèse sans auteur ne vaut presque rien en dissertation. Le correcteur attend le nom,
            l'ouvrage et si possible la date : c'est ce qui distingue une copie qui a lu d'une copie
            qui résume. Les fiches ci-dessous sont à apprendre.
          </>
        }
      />
      <div>
        <p className="mb-2 text-xs font-semibold text-foreground">
          Les huit auteurs du chapitre — clique pour ouvrir la fiche
        </p>
        <Galerie auteurs={AUTEURS_CH1} />
      </div>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* 3. La frise, de Ptahhotep à aujourd'hui                             */
/* ------------------------------------------------------------------ */

const FRISE: ReadonlyArray<ElementOrdre> = [
  {
    id: "ptah",
    texte: "Ptahhotep — Maximes (Égypte, env. 2400 av. notre ère)",
    rang: 1,
    pourquoi: "C'est le plus ancien texte de sagesse argumentée que nous possédions.",
  },
  {
    id: "baba",
    texte: "Ahmed Baba — Tombouctou, logique et droit (1556-1627)",
    rang: 2,
    pourquoi: "Savant de l'empire songhaï, auteur de dizaines d'ouvrages, dont sur la logique.",
  },
  {
    id: "yacob",
    texte: "Zera Yacob — Hatata (Éthiopie, 1667)",
    rang: 3,
    pourquoi: "Treize ans après les Méditations de Descartes, et avec le même geste de doute.",
  },
  {
    id: "amo",
    texte: "Anton Wilhelm Amo — enseigne la philosophie en Allemagne (1703-1759)",
    rang: 4,
    pourquoi: "Né au Ghana, docteur à Wittenberg, il enseigne à Halle et à Iéna.",
  },
  {
    id: "tempels",
    texte: "Placide Tempels — La Philosophie bantoue (1945)",
    rang: 5,
    pourquoi: "L'acte de naissance de l'ethnophilosophie, et de la querelle qui suit.",
  },
  {
    id: "diop",
    texte: "Cheikh Anta Diop — Nations nègres et culture (1954)",
    rang: 6,
    pourquoi: "La réponse documentée à Hegel.",
  },
  {
    id: "kagame",
    texte: "Alexis Kagame — La Philosophie bantu-rwandaise de l'Être (1956)",
    rang: 7,
    pourquoi: "L'ethnophilosophie reprise par un Africain, avec les outils de la linguistique.",
  },
  {
    id: "njoh",
    texte: "Njoh Mouelle — De la médiocrité à l'excellence (1970)",
    rang: 8,
    pourquoi: "Un an avant Towa, et sur un tout autre terrain : celui du développement.",
  },
  {
    id: "towa",
    texte: "Marcien Towa — Essai sur la problématique philosophique (1971)",
    rang: 9,
    pourquoi: "La critique politique de l'ethnophilosophie.",
  },
  {
    id: "hount",
    texte: "Paulin Hountondji — Sur la « philosophie africaine » (1976)",
    rang: 10,
    pourquoi: "La critique formelle, cinq ans après Towa.",
  },
  {
    id: "eboussi",
    texte: "Eboussi Boulaga — La crise du Muntu (1977)",
    rang: 11,
    pourquoi: "La troisième voie, un an après Hountondji.",
  },
];

export function FrisePhiloAfricaine() {
  const [thales, setThales] = useState(false);
  return (
    <div className="space-y-3">
      <MettreEnOrdre
        consigne="Onze philosophes africains ou de l'Afrique, à remettre dans l'ordre chronologique. Clique-les du plus ancien au plus récent. Chaque erreur t'indique la place exacte et pourquoi."
        elements={FRISE}
        conclusion={
          <>
            La philosophie en Afrique ne commence pas en 1945 : elle commence avec des textes
            écrits, et la querelle de l'ethnophilosophie n'en occupe que les trente dernières
            années.
          </>
        }
      />
      <button
        type="button"
        onClick={() => setThales((t) => !t)}
        className="rounded-lg border border-border px-3 py-1.5 text-xs font-medium text-muted-foreground hover:bg-secondary/60"
      >
        {thales ? "Masquer Thalès" : "Placer Thalès de Milet sur la même frise"}
      </button>
      {thales ? (
        <div className="space-y-2">
          <div className="rounded-lg border border-primary/40 bg-primary/5 p-3">
            <p className="text-xs leading-relaxed text-foreground">
              <span className="font-semibold">Thalès de Milet</span>, qu'on appelle le premier
              philosophe, vit vers <span className="font-mono">600 avant notre ère</span>. Ptahhotep
              écrit vers <span className="font-mono">2400 avant notre ère</span>. L'écart est de{" "}
              <span className="font-semibold">dix-huit siècles</span>.
            </p>
          </div>
          <Citation auteur="à retenir">
            Cet écart ne prouve pas à lui seul que Ptahhotep fait de la philosophie : la question
            reste de savoir s'il argumente ou s'il transmet. Mais il interdit de dire que la pensée
            écrite a commencé en Grèce, et c'est déjà beaucoup.
          </Citation>
        </div>
      ) : null}
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* 4. Les trois courants, puis la querelle jouée                       */
/* ------------------------------------------------------------------ */

const COURANTS: ReadonlyArray<ItemTri> = [
  {
    id: "c1",
    texte: "Tempels, La Philosophie bantoue (1945) : l'être est force.",
    bonne: "ethno",
    pourquoi: "Une philosophie attribuée à un peuple entier, sans auteur africain qui la signe.",
  },
  {
    id: "c2",
    texte:
      "Kagame, La Philosophie bantu-rwandaise de l'Être (1956) : la langue porte les catégories.",
    bonne: "ethno",
    pourquoi:
      "Même démarche que Tempels, avec un auteur africain et de la linguistique : le camp reste le même.",
  },
  {
    id: "c3",
    texte:
      "Towa, Essai sur la problématique philosophique (1971) : l'ethnophilosophie enferme l'Africain dans son passé.",
    bonne: "critique",
    pourquoi:
      "Argument politique : la célébration de la tradition dispense de penser les tâches du présent.",
  },
  {
    id: "c4",
    texte:
      "Hountondji, Sur la « philosophie africaine » (1976) : il n'y a de philosophie que par textes signés.",
    bonne: "critique",
    pourquoi:
      "Argument formel : une vision du monde anonyme et collective n'est pas une philosophie.",
  },
  {
    id: "c5",
    texte: "Eboussi Boulaga, La crise du Muntu (1977) : la question elle-même est mal posée.",
    bonne: "troisieme",
    pourquoi:
      "Ni prouver que l'Afrique a une philosophie, ni le nier : philosopher sur la situation réelle.",
  },
  {
    id: "c6",
    texte:
      "Njoh Mouelle, De la médiocrité à l'excellence (1970) : le développement est d'abord mental.",
    bonne: "troisieme",
    pourquoi:
      "Il sort de la querelle en changeant d'objet : non plus l'identité, mais l'exigence d'excellence.",
  },
  {
    id: "c7",
    texte: "« Les Africains ont une sagesse collective qu'il faut recueillir et formuler. »",
    bonne: "ethno",
    pourquoi: "C'est la définition même du programme ethnophilosophique.",
  },
  {
    id: "c8",
    texte: "« Une philosophie se discute article par article, ou elle n'est pas une philosophie. »",
    bonne: "critique",
    pourquoi: "Le critère de Hountondji, repris mot pour mot.",
  },
];

const QUERELLE: ReadonlyArray<Question> = [
  {
    id: "q1",
    enonce:
      "Tu défends l'ethnophilosophie. Hountondji t'objecte : « aucun Bantou n'a écrit cette philosophie, c'est un Belge qui l'a formulée. » Que réponds-tu ?",
    options: [
      {
        texte:
          "Kagame, qui est rwandais, a repris la même démarche avec les outils de la linguistique : l'objection vise un auteur, pas la thèse.",
        bonne: true,
        retour:
          "C'est la bonne réponse, et elle est réelle : Kagame a précisément été la réponse de l'ethnophilosophie à ce reproche.",
      },
      {
        texte: "Hountondji est un Occidentalisé qui ne comprend plus l'Afrique.",
        bonne: false,
        retour:
          "C'est un argument ad hominem : tu attaques la personne au lieu de sa thèse. En copie, cela coûte des points et ne convainc personne.",
      },
      {
        texte: "Tout le monde sait que les Bantous pensent ainsi.",
        bonne: false,
        retour:
          "Appel à la majorité, et il manque le point : l'objection porte justement sur le fait que personne ne l'a écrit.",
      },
    ],
  },
  {
    id: "q2",
    enonce:
      "Tu défends maintenant Hountondji. On t'objecte : « ton critère du texte écrit est celui de l'Occident ; tu juges l'Afrique avec la règle de ses colonisateurs. » Que réponds-tu ?",
    options: [
      {
        texte:
          "Le critère ne porte pas sur l'origine mais sur la discutabilité : Zera Yacob, Ahmed Baba et Amo l'ont satisfait en Afrique et avant la colonisation.",
        bonne: true,
        retour:
          "Exactement. La réponse déplace l'objection : ce n'est pas une règle importée, puisque des Africains l'ont remplie avant qu'elle ne soit imposée.",
      },
      {
        texte: "L'Occident a raison, il faut s'aligner sur ses critères.",
        bonne: false,
        retour:
          "Tu concèdes l'objection au lieu d'y répondre, et tu donnes raison à Towa contre toi-même.",
      },
      {
        texte: "La tradition orale ne vaut rien.",
        bonne: false,
        retour:
          "Hountondji ne dit pas cela : il dit que la tradition orale n'est pas de la philosophie, ce qui ne la dévalue pas. Tu caricatures ta propre thèse.",
      },
    ],
  },
  {
    id: "q3",
    enonce: "Eboussi Boulaga entre dans le débat. Quelle est sa manière de le dépasser ?",
    options: [
      {
        texte:
          "Il montre que les deux camps acceptent la même question — l'Afrique a-t-elle une philosophie ? — et que cette question est posée par le regard colonial.",
        bonne: true,
        retour:
          "Oui, et c'est le mouvement d'une vraie synthèse : non pas trancher entre les deux, mais montrer ce qu'ils ont en commun sans le voir.",
      },
      {
        texte: "Il donne raison à Tempels contre Hountondji.",
        bonne: false,
        retour: "Non : il refuse les deux positions, et c'est ce qui en fait une troisième voie.",
      },
      {
        texte: "Il propose de compter les ouvrages de chaque camp.",
        bonne: false,
        retour: "Une querelle philosophique ne se tranche pas au nombre de pages.",
      },
    ],
  },
];

export function CourantsPhiloAfricaine() {
  return (
    <div className="space-y-4">
      <JeuTri
        consigne="Range chaque auteur, ouvrage ou thèse dans son courant. La simulation refusera de mettre Towa et Tempels dans la même colonne, et elle te dira pourquoi."
        categories={[
          { value: "ethno", label: "Ethnophilosophie", aide: "Tempels, Kagame" },
          { value: "critique", label: "Critique", aide: "Towa, Hountondji" },
          { value: "troisieme", label: "Troisième voie", aide: "Eboussi Boulaga, Njoh Mouelle" },
        ]}
        items={COURANTS}
        conclusion={
          <>
            Retiens que Towa et Hountondji aboutissent au même camp par deux chemins différents :
            l'un pour des raisons politiques, l'autre pour des raisons formelles. Le signaler en
            copie montre que vous ne récitez pas une liste.
          </>
        }
      />
      <div className="border-t border-border pt-3">
        <p className="mb-2 text-xs font-semibold text-foreground">
          Second volet — la querelle jouée
        </p>
        <Qcm
          consigne="Tu choisis un camp, la simulation te sert l'objection adverse, et tu dois y répondre. C'est exactement le mouvement d'une dissertation : présenter la thèse, encaisser l'objection, répondre sans caricaturer."
          questions={QUERELLE}
          conclusion={
            <>
              Note ce qui vient d'arriver : les mauvaises réponses n'étaient pas des erreurs de
              connaissance, c'étaient des fautes de raisonnement — attaque personnelle, appel à la
              majorité, caricature de sa propre thèse. Le chapitre 13 les nommera une par une.
            </>
          }
        />
      </div>
    </div>
  );
}
