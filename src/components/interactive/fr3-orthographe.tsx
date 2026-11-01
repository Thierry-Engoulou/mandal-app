import { useState } from "react";
import { PALETTE, Choice, Ctrl, Verdict } from "./controls";
import { Citation, JeuTri, type ItemTri } from "./philo-noyau";
import { Transformer, type Transformation } from "./fr3-noyau";

/** Français 3ème — chapitres 11 et 12 : homophones lexicaux et conditionnel. */

/* ------------------------------------------------------------------ */
/* 1. Le mot qui convient                                              */
/* ------------------------------------------------------------------ */

type NatureMot = "nom" | "adjectif" | "verbe" | "preposition" | "adverbe";

const NATURES: ReadonlyArray<{ value: NatureMot; label: string }> = [
  { value: "nom", label: "nom" },
  { value: "adjectif", label: "adjectif" },
  { value: "verbe", label: "verbe" },
  { value: "preposition", label: "préposition" },
  { value: "adverbe", label: "adverbe" },
];

type Candidat = { mot: string; nature: NatureMot; famille: string };

type TrouHomophone = {
  id: string;
  avant: string;
  apres: string;
  candidats: ReadonlyArray<Candidat>;
  bon: string;
  nature: NatureMot;
  pourquoi: string;
};

const TROUS: ReadonlyArray<TrouHomophone> = [
  {
    id: "h1",
    avant: "Nous marchions",
    apres: "le marché quand la pluie a commencé.",
    candidats: [
      { mot: "ver", nature: "nom", famille: "vermine, vermisseau" },
      { mot: "verre", nature: "nom", famille: "verrier, verrerie" },
      { mot: "vert", nature: "adjectif", famille: "verdir, verdure" },
      { mot: "vers", nature: "preposition", famille: "versification" },
    ],
    bon: "vers",
    nature: "preposition",
    pourquoi:
      "Le mot introduit un groupe nominal et marque une direction : c'est une préposition, et seul « vers » en est une.",
  },
  {
    id: "h2",
    avant: "Cette mangue n'est pas mûre, elle est encore",
    apres: ".",
    candidats: [
      { mot: "ver", nature: "nom", famille: "vermine" },
      { mot: "verre", nature: "nom", famille: "verrier" },
      { mot: "verte", nature: "adjectif", famille: "verdir, verdure" },
      { mot: "vers", nature: "preposition", famille: "versifier" },
    ],
    bon: "verte",
    nature: "adjectif",
    pourquoi:
      "Le mot suit « elle est » et s'accorde avec « mangue », féminin. C'est un adjectif, et la famille le confirme : la mangue VERDIT.",
  },
  {
    id: "h3",
    avant: "Un",
    apres: "de terre est sorti après l'averse.",
    candidats: [
      { mot: "ver", nature: "nom", famille: "vermine, vermisseau" },
      { mot: "verre", nature: "nom", famille: "verrerie" },
      { mot: "vert", nature: "adjectif", famille: "verdure" },
      { mot: "vers", nature: "preposition", famille: "versification" },
    ],
    bon: "ver",
    nature: "nom",
    pourquoi:
      "Un article, donc un nom ; et il s'agit de l'animal. La famille le confirme : vermine, vermisseau — un seul r, pas de d, pas de s.",
  },
  {
    id: "h4",
    avant: "Le",
    apres: "d'eau qui traverse le village déborde chaque saison.",
    candidats: [
      { mot: "cour", nature: "nom", famille: "courtisan, courette" },
      { mot: "cours", nature: "nom", famille: "parcours, concours" },
      { mot: "court", nature: "adjectif", famille: "courte, raccourcir" },
    ],
    bon: "cours",
    nature: "nom",
    pourquoi:
      "L'article « le » est masculin, et la famille donne PARCOURS, CONCOURS. « La cour » est l'espace d'une école ; « court » est l'adjectif ou le verbe courir.",
  },
  {
    id: "h5",
    avant: "Les élèves jouent dans la",
    apres: "pendant la récréation.",
    candidats: [
      { mot: "cour", nature: "nom", famille: "courtisan, courette" },
      { mot: "cours", nature: "nom", famille: "parcours" },
      { mot: "court", nature: "verbe", famille: "courir" },
    ],
    bon: "cour",
    nature: "nom",
    pourquoi: "L'article « la » est féminin : c'est la cour de l'école. Famille : courette.",
  },
  {
    id: "h6",
    avant: "Il",
    apres: "la fatigue monter dans ses jambes.",
    candidats: [
      { mot: "sang", nature: "nom", famille: "sanguin, saigner" },
      { mot: "cent", nature: "adjectif", famille: "centaine, centime" },
      { mot: "sans", nature: "preposition", famille: "aucune" },
      { mot: "sent", nature: "verbe", famille: "sentir, sensation" },
    ],
    bon: "sent",
    nature: "verbe",
    pourquoi:
      "Test du changement de temps : « il SENTAIT la fatigue » fonctionne. C'est donc un verbe, et le seul verbe de la série.",
  },
  {
    id: "h7",
    avant: "Il est parti",
    apres: "nous prévenir.",
    candidats: [
      { mot: "sang", nature: "nom", famille: "sanguin" },
      { mot: "cent", nature: "adjectif", famille: "centaine" },
      { mot: "sans", nature: "preposition", famille: "aucune" },
      { mot: "sent", nature: "verbe", famille: "sentir" },
    ],
    bon: "sans",
    nature: "preposition",
    pourquoi:
      "Test du changement de temps : « il est parti SENTAIT nous prévenir » ne veut rien dire. Ce n'est donc pas un verbe. Le mot introduit ici un infinitif : c'est la préposition.",
  },
  {
    id: "h8",
    avant: "Ma",
    apres: "prépare le repas depuis ce matin.",
    candidats: [
      { mot: "mer", nature: "nom", famille: "maritime, marin" },
      { mot: "mère", nature: "nom", famille: "maternel, maternité" },
      { mot: "maire", nature: "nom", famille: "mairie, municipal" },
    ],
    bon: "mère",
    nature: "nom",
    pourquoi:
      "Les trois sont des noms : c'est donc la famille qui tranche, et seule MATERNEL convient au sens.",
  },
  {
    id: "h9",
    avant: "Le",
    apres: "a inauguré le nouveau marché.",
    candidats: [
      { mot: "mer", nature: "nom", famille: "maritime" },
      { mot: "mère", nature: "nom", famille: "maternel" },
      { mot: "maire", nature: "nom", famille: "mairie" },
    ],
    bon: "maire",
    nature: "nom",
    pourquoi: "L'article « le » est masculin, et la famille donne MAIRIE.",
  },
  {
    id: "h10",
    avant: "Récite-moi les quatre premiers",
    apres: "de ce poème.",
    candidats: [
      { mot: "vers", nature: "nom", famille: "versification, versifier" },
      { mot: "verre", nature: "nom", famille: "verrerie" },
      { mot: "verts", nature: "adjectif", famille: "verdir" },
    ],
    bon: "vers",
    nature: "nom",
    pourquoi:
      "Un déterminant, donc un nom, et il s'agit de lignes de poème. Famille : versification. Note que « vers » ne change pas au pluriel.",
  },
  {
    id: "h11",
    avant: "Ce",
    apres: "africain se raconte le soir, autour du feu.",
    candidats: [
      { mot: "conte", nature: "nom", famille: "conter, raconter" },
      { mot: "compte", nature: "nom", famille: "compter, comptable" },
      { mot: "comte", nature: "nom", famille: "comté, comtesse" },
    ],
    bon: "conte",
    nature: "nom",
    pourquoi: "Famille : conter, raconter. Le compte est bancaire, le comte est noble.",
  },
  {
    id: "h12",
    avant: "Je",
    apres: "sur toi pour fermer la boutique.",
    candidats: [
      { mot: "conte", nature: "verbe", famille: "conter" },
      { mot: "compte", nature: "verbe", famille: "compter, comptable" },
      { mot: "comte", nature: "nom", famille: "comté" },
    ],
    bon: "compte",
    nature: "verbe",
    pourquoi:
      "Test du temps : « je COMPTAIS sur toi » fonctionne. C'est un verbe, et « compter sur » est sa construction.",
  },
  {
    id: "h13",
    avant: "La",
    apres: "ferrée traverse le quartier depuis dix ans.",
    candidats: [
      { mot: "voie", nature: "nom", famille: "voyage, convoi" },
      { mot: "voix", nature: "nom", famille: "vocal, vocalise" },
      { mot: "vois", nature: "verbe", famille: "voir" },
    ],
    bon: "voie",
    nature: "nom",
    pourquoi: "Famille : convoi, voyage. La voix est vocale ; « vois » est le verbe voir.",
  },
  {
    id: "h14",
    avant: "Sa",
    apres: "porte loin, même sans micro.",
    candidats: [
      { mot: "voie", nature: "nom", famille: "convoi" },
      { mot: "voix", nature: "nom", famille: "vocal, vocalise" },
      { mot: "vois", nature: "verbe", famille: "voir" },
    ],
    bon: "voix",
    nature: "nom",
    pourquoi: "Famille : vocal, vocalise.",
  },
  {
    id: "h15",
    avant: "Le",
    apres: "sort son filet avant le lever du jour.",
    candidats: [
      { mot: "pêcheur", nature: "nom", famille: "pêche, pêcher le poisson" },
      { mot: "pécheur", nature: "nom", famille: "péché, pécher" },
    ],
    bon: "pêcheur",
    nature: "nom",
    pourquoi:
      "Il sort un filet : c'est celui qui pêche, avec un accent CIRCONFLEXE. Un accent aigu, et on passe de la pirogue à l'église.",
  },
  {
    id: "h16",
    avant: "Il est",
    apres: "venir avant midi, mais rien n'est sûr.",
    candidats: [
      { mot: "censé", nature: "adjectif", famille: "censeur, recensement" },
      { mot: "sensé", nature: "adjectif", famille: "sens, bon sens" },
    ],
    bon: "censé",
    nature: "adjectif",
    pourquoi:
      "Le sens est « on le suppose ». Famille : censeur, recensement. « Sensé » voudrait dire « plein de bon sens », ce qui n'a pas de sens ici.",
  },
  {
    id: "h17",
    avant: "Payer une",
    apres: "au commissariat n'a rien d'agréable.",
    candidats: [
      { mot: "amende", nature: "nom", famille: "amender, amendement" },
      { mot: "amande", nature: "nom", famille: "amandier" },
    ],
    bon: "amende",
    nature: "nom",
    pourquoi: "On ne paie pas un fruit au commissariat. L'amende est la sanction, avec un e.",
  },
  {
    id: "h18",
    avant: "Dans la",
    apres: "actuelle, les prix montent partout.",
    candidats: [
      { mot: "conjecture", nature: "nom", famille: "conjecturer, supposer" },
      { mot: "conjoncture", nature: "nom", famille: "jonction, conjoindre" },
    ],
    bon: "conjoncture",
    nature: "nom",
    pourquoi:
      "La conjoncture est la situation du moment ; la conjecture est une supposition. Ce sont des paronymes, et la confusion est très répandue dans la presse.",
  },
  {
    id: "h19",
    avant: "Ma",
    apres: "est solide, et rien ne l'ébranlera.",
    candidats: [
      { mot: "foi", nature: "nom", famille: "fidèle, confiance" },
      { mot: "foie", nature: "nom", famille: "hépatique" },
      { mot: "fois", nature: "nom", famille: "autrefois, parfois" },
    ],
    bon: "foi",
    nature: "nom",
    pourquoi:
      "Le déterminant « ma » est féminin, or « le foie » est masculin : l'article seul suffisait à alerter. La foi est la croyance.",
  },
  {
    id: "h20",
    avant: "La boue a laissé des",
    apres: "sur tout le mur.",
    candidats: [
      { mot: "taches", nature: "nom", famille: "tacher, tacheté" },
      { mot: "tâches", nature: "nom", famille: "tâcher de, besogne" },
    ],
    bon: "taches",
    nature: "nom",
    pourquoi:
      "Il s'agit de salissures, pas de travaux : pas d'accent. L'accent circonflexe est le chapeau de celui qui travaille.",
  },
];

const TROU_VIDE: TrouHomophone = {
  id: "",
  avant: "—",
  apres: "—",
  candidats: [],
  bon: "",
  nature: "nom",
  pourquoi: "—",
};

export function HomophoneContexte() {
  const [i, setI] = useState(0);
  const [nature, setNature] = useState<NatureMot | null>(null);
  const [mot, setMot] = useState<string | null>(null);

  const t = TROUS[i] ?? TROU_VIDE;
  const natureJuste = nature === t.nature;
  const motJuste = mot === t.bon;
  const restants = nature === null ? t.candidats : t.candidats.filter((c) => c.nature === nature);

  return (
    <div className="space-y-3">
      <p className="text-sm text-muted-foreground">
        L'oreille ne peut rien : les candidats se prononcent de la même façon. Commence par dire
        quelle NATURE le trou attend, et la moitié des candidats s'éliminent d'eux-mêmes.
      </p>

      <div className="rounded-lg border border-border bg-background p-3">
        <p className="text-base text-foreground">
          {t.avant}{" "}
          <span
            className="rounded px-2 py-0.5 font-semibold"
            style={{
              backgroundColor: mot ? "rgba(37,99,235,0.14)" : "rgba(100,116,139,0.14)",
              color: mot ? PALETTE.blue : PALETTE.slate,
            }}
          >
            {mot ?? "……"}
          </span>{" "}
          {t.apres}
        </p>

        <div className="mt-3">
          <Choice<NatureMot | "">
            label="1. Quelle nature le trou attend-il ?"
            value={nature ?? ""}
            options={NATURES}
            onChange={(v) => {
              if (v === "") return;
              setNature(v);
              setMot(null);
            }}
          />
        </div>

        {nature !== null ? (
          <div className="mt-3">
            <Verdict tone={natureJuste ? "ok" : "warn"}>
              <span className="font-semibold">
                {natureJuste
                  ? "Bonne nature. "
                  : `Le trou attend plutôt un ${NATURES.find((n) => n.value === t.nature)?.label ?? "mot"}. `}
              </span>
              {natureJuste
                ? "Regarde ce qu'il reste de candidats : la nature en a déjà écarté une partie."
                : "Avec la nature que tu as choisie, tu risques d'éliminer le bon mot. Réessaie."}
            </Verdict>

            <p className="mt-2 text-[11px] text-muted-foreground">
              2. Les candidats compatibles avec cette nature :
            </p>
            <div className="mt-1 flex flex-wrap gap-1.5">
              {t.candidats.map((c) => {
                const compatible = restants.some((r) => r.mot === c.mot);
                return (
                  <button
                    key={c.mot}
                    type="button"
                    disabled={!compatible}
                    onClick={() => setMot(c.mot)}
                    className="rounded-md border px-2.5 py-1 text-xs"
                    style={{
                      opacity: compatible ? 1 : 0.3,
                      borderColor: mot === c.mot ? PALETTE.blue : "rgba(100,116,139,0.3)",
                      backgroundColor: mot === c.mot ? "rgba(37,99,235,0.10)" : "transparent",
                    }}
                  >
                    {c.mot}
                    <span className="ml-1.5 text-[10px] text-muted-foreground">({c.famille})</span>
                  </button>
                );
              })}
            </div>
          </div>
        ) : null}

        {mot !== null ? (
          <div className="mt-3 space-y-2">
            <Verdict tone={motJuste ? "ok" : "bad"}>
              <span className="font-semibold">
                {motJuste ? "C'est le mot. " : `Le mot attendu est « ${t.bon} ». `}
              </span>
              {t.pourquoi}
            </Verdict>
            <button
              type="button"
              onClick={() => {
                setI((n) => (n + 1) % TROUS.length);
                setNature(null);
                setMot(null);
              }}
              className="rounded-lg bg-primary px-3 py-1.5 text-xs font-semibold text-primary-foreground"
            >
              Phrase suivante ({i + 1} / {TROUS.length})
            </button>
          </div>
        ) : null}
      </div>

      <Citation auteur="à aucun moment tu n'as écouté la phrase">
        Les candidats sonnent tous pareil. C'est la nature du mot qui a trié, et la famille qui a
        confirmé. Ces deux gestes, faits dans cet ordre, règlent la quasi-totalité des homophones du
        français.
      </Citation>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* 2. Remonter à la famille                                            */
/* ------------------------------------------------------------------ */

const FAMILLES_MOTS: ReadonlyArray<Transformation> = [
  {
    id: "f1",
    consigne:
      "Le mot « vert » cache un D qu'on n'entend pas. Écris un mot de la même famille où ce D se prononce.",
    depart: "ver… (la couleur)",
    attendues: ["verdir", "verdure", "verdâtre", "verdoyant", "verdoyer"],
    explication:
      "VERDIR, VERDURE, VERDÂTRE. Le d muet de « vert » se réveille dans sa famille — et il prouve du même coup que ce n'est ni « verre », ni « vers », ni « ver ».",
    aide: "Pense à ce que fait une plante au début de la saison des pluies.",
  },
  {
    id: "f2",
    consigne: "Le mot « verre » a deux R. Trouve un mot de sa famille où on les entend bien.",
    depart: "ver… (le récipient)",
    attendues: ["verrier", "verrerie", "verrière", "verre à vitre"],
    explication:
      "VERRIER, VERRERIE, VERRIÈRE. Le double r s'entend, et il distingue le récipient de l'animal.",
  },
  {
    id: "f3",
    consigne: "« Le cours d'eau » prend un S. Quel mot de la famille le fait entendre ?",
    depart: "cour… (qui coule)",
    attendues: ["parcours", "concours", "discours", "recours", "courir"],
    explication:
      "PARCOURS, CONCOURS, DISCOURS. Tous gardent le s, et tous disent l'idée d'un chemin que l'on suit.",
    indices: [
      {
        quand: /courette|courtisan/i,
        message:
          "Attention, courette et courtisan sont la famille de LA COUR — l'espace d'une école ou d'un palais, pas le cours d'eau.",
      },
    ],
  },
  {
    id: "f4",
    consigne: "Le mot « sang » cache un G. Trouve un mot où il se prononce.",
    depart: "san… (rouge)",
    attendues: ["sanguin", "sanguinaire", "exsangue", "saigner", "sanglant"],
    explication: "SANGUIN, SANGLANT, SANGUINAIRE. Le g muet se réveille.",
  },
  {
    id: "f5",
    consigne: "« Le dessein » (le projet) prend EIN. Quel verbe de la famille le confirme ?",
    depart: "dess…",
    attendues: ["désigner", "dessein de", "projeter"],
    explication:
      "DÉSIGNER, qui vient du même latin. Le DESSIN, lui, est de la famille de DESSINER. Deux mots, deux familles, deux orthographes.",
    aide: "Pense au verbe qui signifie « indiquer, montrer du doigt ».",
  },
  {
    id: "f6",
    consigne: "Le mot « temps » cache un P. Trouve un mot de la famille.",
    depart: "tem… (la durée)",
    attendues: ["temporel", "temporaire", "contemporain", "temporiser"],
    explication:
      "TEMPOREL, TEMPORAIRE, CONTEMPORAIN. Le p se prononce, et il écarte « tant » et « tend ».",
  },
  {
    id: "f7",
    consigne: "« Le respect » cache un T. Trouve le verbe de sa famille.",
    depart: "respec…",
    attendues: ["respecter", "respectueux", "respectable"],
    explication: "RESPECTER, RESPECTUEUX. Le t se réveille devant la voyelle.",
  },
  {
    id: "f8",
    consigne: "« Un tapis » cache un S. Quel verbe le fait entendre ?",
    depart: "tapi…",
    attendues: ["tapisser", "tapisserie", "tapissier"],
    explication: "TAPISSER, TAPISSERIE. La lettre muette se réveille dans la famille.",
  },
  {
    id: "f9",
    consigne: "« Le bavard » cache un D. Trouve un mot de sa famille.",
    depart: "bavar…",
    attendues: ["bavarder", "bavardage", "bavarde"],
    explication:
      "BAVARDER, BAVARDAGE, ou simplement le féminin BAVARDE. Le féminin est d'ailleurs le test le plus rapide pour les adjectifs.",
  },
  {
    id: "f10",
    consigne: "« Le galop » cache un P. Quel verbe de la famille le fait entendre ?",
    depart: "galo…",
    attendues: ["galoper", "galopade", "galopant"],
    explication: "GALOPER, GALOPADE.",
  },
  {
    id: "f11",
    consigne: "« Le maire » de la ville. Quel mot de sa famille confirme l'orthographe ?",
    depart: "m…re (de la ville)",
    attendues: ["mairie", "municipal"],
    explication:
      "MAIRIE. Et c'est le seul test : « mer », « mère » et « maire » sont tous trois des noms, donc la nature ne suffit pas.",
  },
  {
    id: "f12",
    consigne: "« La voix ». Quel adjectif de sa famille fait entendre le C caché ?",
    depart: "voi… (celle qui chante)",
    attendues: ["vocal", "vocale", "vocalise", "vocalique"],
    explication:
      "VOCAL, VOCALISE. Le x de « voix » est l'héritier d'un c latin — et c'est pourquoi il ne s'écrit pas comme « la voie », de la famille de CONVOI.",
  },
  {
    id: "f13",
    consigne: "« Le poing » cache un G. Trouve un mot de sa famille.",
    depart: "poin… (la main fermée)",
    attendues: ["poignet", "poignée", "empoigner", "poignard"],
    explication:
      "POIGNET, POIGNÉE, EMPOIGNER. Le g se réveille, et il écarte « le point » de la ponctuation.",
  },
  {
    id: "f14",
    consigne: "« Un candidat » cache un T. Trouve le féminin ou un mot de la famille.",
    depart: "candida…",
    attendues: ["candidate", "candidature", "candidater"],
    explication:
      "CANDIDATE, CANDIDATURE. Pour un nom qui a un féminin, le féminin est le test le plus court.",
  },
  {
    id: "f15",
    consigne: "« Le marchand » cache un D. Trouve un mot de sa famille.",
    depart: "marchan…",
    attendues: ["marchande", "marchandise", "marchander"],
    explication:
      "MARCHANDE, MARCHANDISE, MARCHANDER. Attention à ne pas confondre avec le participe « marchant », de « marcher ».",
  },
  {
    id: "f16",
    consigne: "« Un refus » cache un S. Quel verbe le fait entendre ?",
    depart: "refu…",
    attendues: ["refuser", "refusé"],
    explication: "REFUSER.",
  },
  {
    id: "f17",
    consigne: "« Le flanc » de la colline cache un C. Trouve un mot de sa famille.",
    depart: "flan… (le côté)",
    attendues: ["flanquer", "efflanqué", "flanquement"],
    explication:
      "FLANQUER, EFFLANQUÉ. Et cela écarte « le flan », qui est un gâteau et n'a pas de c.",
  },
  {
    id: "f18",
    consigne: "« Un champ » de maïs cache un P. Trouve un mot de sa famille.",
    depart: "cham…",
    attendues: ["champêtre", "champignon", "champagne"],
    explication:
      "CHAMPÊTRE. Le p se réveille, et il distingue le champ du « chant » que l'on chante — lequel donne CHANTER.",
  },
];

export function FamilleDeMots() {
  return (
    <Transformer
      consigne="Un mot cache une lettre muette. Trouve un mot de la même famille où cette lettre se prononce : c'est la méthode des grands orthographiens, et elle marche presque toujours."
      items={FAMILLES_MOTS}
      conclusion={
        <Citation auteur="la liste à garder">
          Note les mots qui t'ont résisté : ce sont les tiens, et ce sont ceux qu'il faudra relire
          la veille de l'examen. Pour un adjectif, essaie d'abord le féminin — « bavard, bavarde » —
          c'est le test le plus court de tous.
        </Citation>
      }
    />
  );
}

/* ------------------------------------------------------------------ */
/* 3. La dictée corrigée                                               */
/* ------------------------------------------------------------------ */

type MotDicte = {
  ecrit: string;
  correct: string;
  test: string;
  explication: string;
};

type TexteDicte = {
  id: string;
  titre: string;
  /** Les morceaux de texte non modifiables. */
  avant: string;
  mots: ReadonlyArray<MotDicte>;
  /** Un morceau de texte après chaque mot. */
  liaisons: ReadonlyArray<string>;
  source?: string;
};

const DICTEES: ReadonlyArray<TexteDicte> = [
  {
    id: "d1",
    titre: "Saison des pluies",
    avant: "Dès",
    mots: [
      {
        ecrit: "qu'en",
        correct: "quand",
        test: "Remplace par « lorsque » : « lorsque arrive la saison » tient debout.",
        explication:
          "C'est le « quand » du temps. « Qu'en » serait la contraction de « que en », qui n'a aucun sens ici.",
      },
      {
        ecrit: "court",
        correct: "cours",
        test: "Famille : parcours, concours.",
        explication:
          "Le cours d'eau est celui qui coule. « Court » est l'adjectif ou le verbe courir.",
      },
      {
        ecrit: "tâches",
        correct: "taches",
        test: "S'agit-il de travaux ou de salissures ?",
        explication:
          "Des salissures sur un mur : pas d'accent. L'accent circonflexe est le chapeau de celui qui travaille.",
      },
    ],
    liaisons: [
      " arrive la saison des pluies, le ",
      " d'eau déborde et la boue laisse des ",
      " sur les murs des maisons basses.",
    ],
  },
  {
    id: "d2",
    titre: "Lettre au maire",
    avant: "Monsieur le",
    mots: [
      {
        ecrit: "Maire",
        correct: "Maire",
        test: "Famille : mairie.",
        explication: "Correct. C'est bien l'élu de la commune.",
      },
      {
        ecrit: "sencés",
        correct: "censés",
        test: "Le sens est « on nous suppose devoir payer ».",
        explication:
          "Famille de CENSEUR, de RECENSEMENT. « Sensé » voudrait dire « plein de bon sens ».",
      },
      {
        ecrit: "amande",
        correct: "amende",
        test: "On ne paie pas un fruit au commissariat.",
        explication: "L'amende est la sanction, avec un e.",
      },
      {
        ecrit: "sensé",
        correct: "sensé",
        test: "Le sens est « plein de bon sens ».",
        explication:
          "Correct, et c'est la finesse du texte : « censés » et « sensé » voisinent à six mots d'écart et s'écrivent différemment.",
      },
    ],
    liaisons: [
      ", nous sommes ",
      " de payer une ",
      " si nous jetons nos ordures, ce qui est ",
      " ; mais la municipalité, elle, ne fait rien.",
    ],
  },
  {
    id: "d3",
    titre: "Le départ",
    avant: "",
    mots: [
      {
        ecrit: "Quand",
        correct: "Quant",
        test: "Remplace par « lorsque » : « lorsque à nous » ne veut rien dire.",
        explication: "Le sens est « en ce qui nous concerne » : c'est « quant à », avec un t.",
      },
      {
        ecrit: "plutôt",
        correct: "plus tôt",
        test: "Remplace par « plus tard » : la phrase tient parfaitement.",
        explication: "Donc deux mots. En un mot, « plutôt » signifie « de préférence ».",
      },
      {
        ecrit: "foie",
        correct: "foi",
        test: "Le déterminant « ma » est féminin, or « le foie » est masculin.",
        explication:
          "La foi est la croyance ; le foie est l'organe. L'article seul devait alerter.",
      },
    ],
    liaisons: [
      " à nous, nous partons ",
      " que d'habitude pour arriver au marché avant l'averse. J'ai confiance : ma ",
      " est solide.",
    ],
  },
  {
    id: "d4",
    titre: "Au bord de l'eau",
    avant: "Le",
    mots: [
      {
        ecrit: "pécheur",
        correct: "pêcheur",
        test: "Sort-il un filet ou demande-t-il pardon ?",
        explication:
          "Accent circonflexe pour celui qui pêche le poisson ; accent aigu pour le péché.",
      },
      {
        ecrit: "sent",
        correct: "sent",
        test: "Changement de temps : « il SENTAIT le vent » fonctionne.",
        explication: "Correct : c'est bien le verbe sentir.",
      },
      {
        ecrit: "sans",
        correct: "sans",
        test: "Changement de temps : « sentait rien dire » ne veut rien dire.",
        explication: "Correct : c'est la préposition.",
      },
      {
        ecrit: "verre",
        correct: "vers",
        test: "Le mot introduit un groupe nominal : c'est une préposition.",
        explication:
          "Seul « vers » est une préposition. « Verre » est un nom, famille de verrerie.",
      },
    ],
    liaisons: [" ", " le vent tourner et, ", " rien dire, il pousse sa pirogue ", " le large."],
  },
  {
    id: "d5",
    titre: "Au marché, d'après un sujet de BEPC",
    avant: "Ma mère",
    mots: [
      {
        ecrit: "conte",
        correct: "compte",
        test: "Changement de temps : « elle COMPTAIT ses billets » fonctionne.",
        explication: "C'est un verbe, donc « compte ». Le conte est le récit, famille de raconter.",
      },
      {
        ecrit: "sang",
        correct: "cent",
        test: "Il s'agit d'un nombre.",
        explication: "Famille : centaine, centime. Le sang est rouge, famille de sanguin.",
      },
      {
        ecrit: "voix",
        correct: "voie",
        test: "Famille : convoi, voyage.",
        explication: "La voie est le chemin ; la voix est vocale.",
      },
      {
        ecrit: "tant",
        correct: "temps",
        test: "Famille : temporel, temporaire.",
        explication: "Le p muet se réveille dans la famille. « Tant » marque la quantité.",
      },
    ],
    liaisons: [
      " ",
      " ses pièces : il lui manque ",
      " francs. Nous reprenons la ",
      " du retour, et le ",
      " s'assombrit déjà.",
    ],
    source: "forme d'un sujet de BEPC",
  },
  {
    id: "d6",
    titre: "Devant l'école, d'après un sujet de BEPC",
    avant: "Les élèves jouent dans la",
    mots: [
      {
        ecrit: "cours",
        correct: "cour",
        test: "L'article « la » est féminin.",
        explication: "La cour de l'école, famille de courette. Le cours d'eau est masculin.",
      },
      {
        ecrit: "quant",
        correct: "quand",
        test: "Remplace par « lorsque » : « lorsque la cloche sonne » tient.",
        explication: "C'est le « quand » du temps.",
      },
      {
        ecrit: "ver",
        correct: "vers",
        test: "Le mot introduit un groupe nominal.",
        explication: "Préposition de direction. Le ver est l'animal, famille de vermine.",
      },
      {
        ecrit: "tâche",
        correct: "tâche",
        test: "S'agit-il d'un travail ?",
        explication: "Correct : c'est bien la besogne du surveillant, avec son accent.",
      },
      {
        ecrit: "censé",
        correct: "sensé",
        test: "Le sens est « plein de bon sens ».",
        explication:
          "Famille de SENS. « Censé » voudrait dire « supposé », ce qui ne convient pas à un règlement qu'on approuve.",
      },
    ],
    liaisons: [
      " ",
      " la cloche sonne, ils se dirigent ",
      " les classes. La ",
      " du surveillant est de compter les rangs, et ce règlement paraît ",
      " à tout le monde.",
    ],
    source: "forme d'un sujet de BEPC",
  },
];

const DICTEE_VIDE: TexteDicte = {
  id: "",
  titre: "—",
  avant: "",
  mots: [],
  liaisons: [],
};

export function DicteeHomophones() {
  const [i, setI] = useState(0);
  const [ouvert, setOuvert] = useState<number | null>(null);
  const [juges, setJuges] = useState<Record<number, "garde" | "corrige">>({});

  const d = DICTEES[i] ?? DICTEE_VIDE;

  function juger(k: number, v: "garde" | "corrige") {
    setJuges((j) => ({ ...j, [k]: v }));
  }

  const bilan = d.mots.map((m, k) => {
    const faux = m.ecrit !== m.correct;
    const rep = juges[k];
    if (rep === undefined) return null;
    return (rep === "corrige") === faux;
  });
  const traites = bilan.filter((b) => b !== null).length;
  const bons = bilan.filter((b) => b === true).length;
  const fautes = d.mots.filter((m) => m.ecrit !== m.correct).length;

  return (
    <div className="space-y-3">
      <p className="text-sm text-muted-foreground">
        Un texte, ses homophones surlignés. Pour chacun, dis s'il est juste ou s'il faut le corriger
        — et clique dessus pour que la simulation te propose le test qui convient.
      </p>

      <div className="rounded-lg border border-border bg-background p-3">
        <p className="text-xs font-semibold text-foreground">
          {d.titre}
          {d.source ? (
            <span className="ml-1 font-normal text-muted-foreground">({d.source})</span>
          ) : null}
        </p>

        <p className="mt-2 text-base leading-7 text-foreground">
          {d.avant}
          {d.mots.map((m, k) => {
            const rep = juges[k];
            const faux = m.ecrit !== m.correct;
            const affiche = rep === "corrige" ? m.correct : m.ecrit;
            const couleur =
              rep === undefined
                ? "rgba(202,138,4,0.18)"
                : (rep === "corrige") === faux
                  ? "rgba(21,128,61,0.16)"
                  : "rgba(185,28,28,0.14)";
            return (
              <span key={`${d.id}-${k}`}>
                <button
                  type="button"
                  onClick={() => setOuvert(ouvert === k ? null : k)}
                  className="rounded px-1 font-semibold"
                  style={{ backgroundColor: couleur, color: PALETTE.slate }}
                >
                  {affiche}
                </button>
                {d.liaisons[k] ?? " "}
              </span>
            );
          })}
        </p>

        {ouvert !== null && d.mots[ouvert] ? (
          <div className="mt-3 rounded-md border border-border/60 p-2.5">
            <p className="text-xs font-semibold text-foreground">
              « {d.mots[ouvert]?.ecrit ?? ""} » — le test
            </p>
            <p className="mt-1 text-xs text-muted-foreground">{d.mots[ouvert]?.test ?? ""}</p>
            <div className="mt-2 flex gap-2">
              <button
                type="button"
                onClick={() => juger(ouvert, "garde")}
                className="rounded-lg border border-border px-3 py-1.5 text-xs font-semibold text-foreground"
              >
                Je le garde
              </button>
              <button
                type="button"
                onClick={() => juger(ouvert, "corrige")}
                className="rounded-lg bg-primary px-3 py-1.5 text-xs font-semibold text-primary-foreground"
              >
                Je le corrige
              </button>
            </div>
            {juges[ouvert] !== undefined ? (
              <div className="mt-2">
                <Verdict
                  tone={
                    (juges[ouvert] === "corrige") ===
                    ((d.mots[ouvert]?.ecrit ?? "") !== (d.mots[ouvert]?.correct ?? ""))
                      ? "ok"
                      : "bad"
                  }
                >
                  <span className="font-semibold">
                    La forme juste : « {d.mots[ouvert]?.correct ?? ""} ».{" "}
                  </span>
                  {d.mots[ouvert]?.explication ?? ""}
                </Verdict>
              </div>
            ) : null}
          </div>
        ) : null}

        <p className="mt-3 text-[11px] text-muted-foreground">
          {traites} / {d.mots.length} mots jugés
          {traites > 0
            ? ` — ${bons} jugement${bons > 1 ? "s" : ""} exact${bons > 1 ? "s" : ""}`
            : ""}
          {traites === d.mots.length
            ? `. Ce texte contenait ${fautes} faute${fautes > 1 ? "s" : ""}.`
            : "."}
        </p>

        <button
          type="button"
          onClick={() => {
            setI((n) => (n + 1) % DICTEES.length);
            setJuges({});
            setOuvert(null);
          }}
          className="mt-2 rounded-lg bg-primary px-3 py-1.5 text-xs font-semibold text-primary-foreground"
        >
          Texte suivant ({i + 1} / {DICTEES.length})
        </button>
      </div>

      <Citation auteur="la proportion d'une vraie copie">
        Environ une faute sur deux mots à risque : c'est ce que trouve un correcteur dans une copie
        moyenne. Et chacune se corrigeait par un test de trois secondes. Tes cinq dernières minutes
        de relecture valent donc cent tests — fais-les.
      </Citation>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* 4. Futur ou conditionnel                                            */
/* ------------------------------------------------------------------ */

type PhraseFC = {
  id: string;
  avant: string;
  apres: string;
  radical: string;
  futur: boolean;
  /** Ce que donne le test du « il ». */
  testIl: string;
  pourquoi: string;
};

const PHRASES_FC: ReadonlyArray<PhraseFC> = [
  {
    id: "fc1",
    avant: "Demain, je",
    apres: "à six heures.",
    radical: "partir",
    futur: true,
    testIl: "Demain, IL PARTIRA à six heures.",
    pourquoi: "On entend un « a » net : c'est le futur. J'écris donc « je partirai ».",
  },
  {
    id: "fc2",
    avant: "Si j'avais le temps, je",
    apres: "à pied.",
    radical: "partir",
    futur: false,
    testIl: "Si j'avais le temps, IL PARTIRAIT à pied.",
    pourquoi:
      "On entend un « è » : c'est le conditionnel. Et la phrase le confirmait : « si » suivi d'un imparfait.",
  },
  {
    id: "fc3",
    avant: "Je",
    apres: "vous parler un instant.",
    radical: "vouloir",
    futur: false,
    testIl: "IL VOUDRAIT vous parler un instant.",
    pourquoi:
      "Conditionnel de politesse : « je voudrais » est plus courtois que « je veux ». Radical irrégulier : voudr-.",
  },
  {
    id: "fc4",
    avant: "Je",
    apres: "le résultat demain.",
    radical: "savoir",
    futur: true,
    testIl: "IL SAURA le résultat demain.",
    pourquoi: "Futur. Le mot « demain » le confirmait. Radical irrégulier : saur-.",
  },
  {
    id: "fc5",
    avant: "Avec un peu de chance, je",
    apres: "arriver avant la nuit.",
    radical: "pouvoir",
    futur: false,
    testIl: "IL POURRAIT arriver avant la nuit.",
    pourquoi:
      "« Avec un peu de chance » exprime une éventualité : conditionnel. Et note les deux r de « pourrais ».",
  },
  {
    id: "fc6",
    avant: "Quand il reviendra, je lui",
    apres: "tout.",
    radical: "dire",
    futur: true,
    testIl: "IL LUI DIRA tout.",
    pourquoi: "Futur, commandé par « quand il reviendra » qui est lui-même au futur.",
  },
  {
    id: "fc7",
    avant: "À ta place, je",
    apres: "le car de midi.",
    radical: "prendre",
    futur: false,
    testIl: "À ta place, IL PRENDRAIT le car de midi.",
    pourquoi: "« À ta place » pose une condition implicite : conditionnel.",
  },
  {
    id: "fc8",
    avant: "L'an prochain, je",
    apres: "en Terminale.",
    radical: "être",
    futur: true,
    testIl: "IL SERA en Terminale.",
    pourquoi: "Futur. Radical irrégulier : ser-.",
  },
  {
    id: "fc9",
    avant: "Si on me le demandait, je",
    apres: "non.",
    radical: "répondre",
    futur: false,
    testIl: "IL RÉPONDRAIT non.",
    pourquoi: "Conditionnel : « si » + imparfait dans la subordonnée.",
  },
  {
    id: "fc10",
    avant: "Je t'",
    apres: "dès mon arrivée.",
    radical: "appeler",
    futur: true,
    testIl: "IL T'APPELLERA dès son arrivée.",
    pourquoi: "Futur. Et note le double l du radical : appell-.",
  },
  {
    id: "fc11",
    avant: "Je",
    apres: "bien savoir qui a dit cela.",
    radical: "aimer",
    futur: false,
    testIl: "IL AIMERAIT bien savoir qui a dit cela.",
    pourquoi: "Conditionnel d'atténuation : « j'aimerais » est plus poli que « je veux ».",
  },
  {
    id: "fc12",
    avant: "Je",
    apres: "ce travail avant samedi.",
    radical: "finir",
    futur: true,
    testIl: "IL FINIRA ce travail avant samedi.",
    pourquoi: "Futur, et le complément de temps le confirme.",
  },
  {
    id: "fc13",
    avant: "Au cas où il pleuvrait, je",
    apres: "à la maison.",
    radical: "rester",
    futur: false,
    testIl: "IL RESTERAIT à la maison.",
    pourquoi:
      "« Au cas où » appelle régulièrement le conditionnel, dans la subordonnée comme dans la principale.",
  },
  {
    id: "fc14",
    avant: "Je",
    apres: "le voir samedi, c'est décidé.",
    radical: "aller",
    futur: true,
    testIl: "IL IRA le voir samedi.",
    pourquoi: "Futur. Radical irrégulier : ir-. Et « c'est décidé » écarte toute hypothèse.",
  },
  {
    id: "fc15",
    avant: "Si j'étais toi, je",
    apres: "cette offre.",
    radical: "accepter",
    futur: false,
    testIl: "IL ACCEPTERAIT cette offre.",
    pourquoi: "Conditionnel, commandé par « si j'étais » à l'imparfait.",
  },
  {
    id: "fc16",
    avant: "Je",
    apres: "sans doute ce livre un jour.",
    radical: "lire",
    futur: true,
    testIl: "IL LIRA sans doute ce livre un jour.",
    pourquoi:
      "Futur. « Sans doute » exprime une probabilité, pas une condition : il n'impose pas le conditionnel.",
  },
  {
    id: "fc17",
    avant: "Je",
    apres: "volontiers, mais je n'ai pas le temps.",
    radical: "venir",
    futur: false,
    testIl: "IL VIENDRAIT volontiers, mais il n'a pas le temps.",
    pourquoi:
      "Conditionnel : la seconde partie de la phrase dit pourquoi le fait ne se produira pas. Radical irrégulier : viendr-.",
  },
  {
    id: "fc18",
    avant: "Dès que j'aurai fini, je te",
    apres: ".",
    radical: "prévenir",
    futur: true,
    testIl: "IL TE PRÉVIENDRA.",
    pourquoi: "Futur, commandé par « dès que j'aurai fini », futur antérieur.",
  },
  {
    id: "fc19",
    avant: "Je",
    apres: "qu'on me réponde avant la fin du mois.",
    radical: "souhaiter",
    futur: false,
    testIl: "IL SOUHAITERAIT qu'on lui réponde.",
    pourquoi: "Conditionnel d'atténuation, très fréquent dans les lettres administratives.",
  },
  {
    id: "fc20",
    avant: "L'année prochaine, je",
    apres: "le BEPC.",
    radical: "passer",
    futur: true,
    testIl: "IL PASSERA le BEPC.",
    pourquoi: "Futur, et le complément de temps l'annonce.",
  },
];

const PHRASE_FC_VIDE: PhraseFC = {
  id: "",
  avant: "—",
  apres: "—",
  radical: "—",
  futur: true,
  testIl: "—",
  pourquoi: "—",
};

export function FuturOuConditionnel() {
  const [i, setI] = useState(0);
  const [choix, setChoix] = useState<"ai" | "ais" | null>(null);
  const [testFait, setTestFait] = useState(false);
  const [sansTest, setSansTest] = useState(0);

  const p = PHRASES_FC[i] ?? PHRASE_FC_VIDE;
  const juste = choix === (p.futur ? "ai" : "ais");

  function repondre(v: "ai" | "ais") {
    setChoix(v);
    if (!testFait) setSansTest((n) => n + 1);
  }

  return (
    <div className="space-y-3">
      <p className="text-sm text-muted-foreground">
        À la première personne du singulier, le futur et le conditionnel ne diffèrent que par un S.
        Fais le test avant de répondre : remplace « je » par « il ».
      </p>

      <div className="rounded-lg border border-border bg-background p-3">
        <p className="text-base text-foreground">
          {p.avant}{" "}
          <span
            className="rounded px-2 py-0.5 font-semibold"
            style={{
              backgroundColor: choix ? "rgba(37,99,235,0.14)" : "rgba(100,116,139,0.14)",
              color: choix ? PALETTE.blue : PALETTE.slate,
            }}
          >
            {p.radical} + {choix ?? "…"}
          </span>{" "}
          {p.apres}
        </p>

        {!testFait ? (
          <button
            type="button"
            onClick={() => setTestFait(true)}
            className="mt-3 rounded-lg border border-border px-3 py-1.5 text-xs font-semibold text-foreground"
          >
            Remplacer « je » par « il »
          </button>
        ) : (
          <p
            className="mt-3 rounded-md px-2 py-1.5 text-sm"
            style={{ backgroundColor: "rgba(202,138,4,0.12)", color: "#78350f" }}
          >
            {p.testIl}
          </p>
        )}

        <div className="mt-3">
          <Choice<"ai" | "ais" | "">
            label="La terminaison"
            value={choix ?? ""}
            options={[
              { value: "ai", label: "-ai (futur)" },
              { value: "ais", label: "-ais (conditionnel)" },
            ]}
            onChange={(v) => {
              if (v !== "") repondre(v);
            }}
          />
        </div>

        {choix !== null ? (
          <div className="mt-3 space-y-2">
            <Verdict tone={juste ? "ok" : "bad"}>
              <span className="font-semibold">
                {juste
                  ? `C'est cela : ${p.futur ? "futur" : "conditionnel"}. `
                  : `Il fallait le ${p.futur ? "futur, en -ai" : "conditionnel, en -ais"}. `}
              </span>
              {p.pourquoi}
            </Verdict>
            {!testFait ? (
              <p className="text-[11px] italic text-muted-foreground">
                Tu as répondu sans faire le test. Même juste, la réponse ne vaut rien tant que le
                geste n'est pas installé.
              </p>
            ) : null}
            <button
              type="button"
              onClick={() => {
                setI((n) => (n + 1) % PHRASES_FC.length);
                setChoix(null);
                setTestFait(false);
              }}
              className="rounded-lg bg-primary px-3 py-1.5 text-xs font-semibold text-primary-foreground"
            >
              Phrase suivante ({i + 1} / {PHRASES_FC.length})
            </button>
          </div>
        ) : null}
      </div>

      {sansTest > 0 ? (
        <p className="text-[11px] text-muted-foreground">
          Réponses données sans le test : {sansTest}. Trois secondes de test évitent la faute la
          plus fréquente de tout le français écrit — chez les élèves comme chez les adultes.
        </p>
      ) : null}

      <Citation auteur="une lettre, et deux temps différents">
        « Je prendrai » dit que le fait aura lieu. « Je prendrais » dit qu'il dépend d'une
        condition. Entre les deux, un S que l'oreille n'entend pas et que le correcteur voit
        aussitôt.
      </Citation>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* 5. Les valeurs du conditionnel passé                                */
/* ------------------------------------------------------------------ */

const VALEURS: ReadonlyArray<ItemTri> = [
  {
    id: "vc1",
    texte: "Tu aurais pu m'attendre cinq minutes.",
    bonne: "reproche",
    pourquoi:
      "Deuxième personne, et le verbe « pouvoir ». Le reproche passe presque toujours par « devoir » ou « pouvoir » au conditionnel passé.",
  },
  {
    id: "vc2",
    texte: "Le feu aurait détruit trois boutiques du marché.",
    bonne: "information",
    pourquoi:
      "Formulation de journaliste : il rapporte sans garantir. Si le fait était établi, il écrirait « le feu A DÉTRUIT ».",
  },
  {
    id: "vc3",
    texte: "J'aurais tellement voulu voir ce match.",
    bonne: "regret",
    pourquoi:
      "Première personne, et l'adverbe « tellement » qui renforce. On sait en creux qu'il n'a pas vu le match.",
  },
  {
    id: "vc4",
    texte: "Si le car était parti à l'heure, nous serions déjà arrivés.",
    bonne: "irreel",
    pourquoi:
      "« Si » + plus-que-parfait, puis conditionnel passé. La phrase affirme en creux que le car n'est pas parti à l'heure et que nous ne sommes pas arrivés.",
  },
  {
    id: "vc5",
    texte: "Vous auriez dû prévenir la mairie plus tôt.",
    bonne: "reproche",
    pourquoi: "Deuxième personne et verbe « devoir » : le reproche est complet.",
  },
  {
    id: "vc6",
    texte: "Le ministre serait arrivé hier soir à Yaoundé.",
    bonne: "information",
    pourquoi:
      "Le journaliste n'a pas vérifié l'arrivée. Le passage du passé composé au conditionnel marque la frontière entre ce qui est vérifié et ce qui ne l'est pas.",
  },
  {
    id: "vc7",
    texte: "Nous aurions aimé assister à la cérémonie.",
    bonne: "regret",
    pourquoi:
      "Première personne du pluriel, verbe « aimer » : regret d'un fait qui n'a pas eu lieu.",
  },
  {
    id: "vc8",
    texte: "Avec un peu plus de temps, nous aurions terminé le mur.",
    bonne: "irreel",
    pourquoi:
      "L'hypothèse est portée par « avec un peu plus de temps », qui remplace ici la subordonnée en « si ». Le mur n'est pas terminé.",
  },
  {
    id: "vc9",
    texte: "Tu aurais pu me le dire avant que je parte.",
    bonne: "reproche",
    pourquoi: "Deuxième personne, verbe « pouvoir », et un grief précis.",
  },
  {
    id: "vc10",
    texte: "Selon les riverains, l'eau serait montée jusqu'aux fenêtres.",
    bonne: "information",
    pourquoi:
      "« Selon les riverains » signale la source non vérifiée, et le conditionnel la confirme. Les deux marques vont ensemble.",
  },
  {
    id: "vc11",
    texte: "J'aurais dû écouter ma mère.",
    bonne: "regret",
    pourquoi:
      "Piège : le verbe « devoir » est là, mais la personne est la PREMIÈRE. On ne se fait pas un reproche, on exprime un regret. C'est la personne qui tranche.",
  },
  {
    id: "vc12",
    texte: "Si j'avais su, je ne serais pas venu.",
    bonne: "irreel",
    pourquoi:
      "La phrase la plus connue du français, et elle dit deux choses en creux : je n'ai pas su, et je suis venu.",
  },
  {
    id: "vc13",
    texte: "L'accident aurait fait trois blessés légers.",
    bonne: "information",
    pourquoi: "Bulletin d'information : le bilan n'est pas confirmé.",
  },
  {
    id: "vc14",
    texte: "Il aurait fallu partir une heure plus tôt.",
    bonne: "regret",
    pourquoi:
      "Forme impersonnelle, donc personne n'est visé : ce n'est pas un reproche adressé, mais le constat d'une occasion manquée.",
  },
  {
    id: "vc15",
    texte: "Vous auriez pu faire attention, maintenant tout est à refaire.",
    bonne: "reproche",
    pourquoi: "Deuxième personne, « pouvoir », et la conséquence énoncée aggrave le grief.",
  },
  {
    id: "vc16",
    texte: "Sans ton aide, je n'y serais jamais arrivé.",
    bonne: "irreel",
    pourquoi:
      "« Sans ton aide » porte l'hypothèse sans employer « si ». Et la phrase affirme en creux que l'aide a bien eu lieu, et qu'on y est arrivé.",
  },
];

export function ValeursConditionnel() {
  return (
    <JeuTri
      consigne="Classe chaque phrase selon la valeur de son conditionnel. L'indice est souvent dans la personne du verbe, ou dans le choix de « devoir » et « pouvoir »."
      categories={[
        { value: "regret", label: "regret", aide: "je parle de ce que J'aurais voulu faire" },
        {
          value: "reproche",
          label: "reproche",
          aide: "je dis à l'autre ce qu'IL aurait dû faire",
        },
        {
          value: "irreel",
          label: "irréel du passé",
          aide: "j'imagine ce qui serait arrivé autrement",
        },
        {
          value: "information",
          label: "information non confirmée",
          aide: "je rapporte sans garantir",
        },
      ]}
      items={VALEURS}
      conclusion={
        <Citation auteur="une nuance à connaître pour lire la presse">
          Quand vous entendez un conditionnel dans un bulletin d'information, le journaliste vous
          avertit qu'il n'a pas vérifié. C'est un usage professionnel, précis et honnête — et le
          jour où il écrira « l'accident A FAIT trois blessés », c'est qu'il aura vérifié.
        </Citation>
      }
    />
  );
}

/* ------------------------------------------------------------------ */
/* 6. Le système hypothétique                                          */
/* ------------------------------------------------------------------ */

type Systeme = {
  nom: string;
  si: string;
  principale: string;
  exemple: string;
  creux: string;
};

const SYSTEMES: ReadonlyArray<Systeme> = [
  {
    nom: "le possible",
    si: "présent",
    principale: "futur simple",
    exemple: "Si tu viens demain, nous irons au marché.",
    creux: "Rien n'est tranché : le fait est possible, et peut-être même probable.",
  },
  {
    nom: "l'irréel du présent",
    si: "imparfait",
    principale: "conditionnel présent",
    exemple: "Si j'avais de l'argent, je partirais en vacances.",
    creux: "La phrase dit en creux : je n'ai pas d'argent, et je ne pars pas.",
  },
  {
    nom: "l'irréel du passé",
    si: "plus-que-parfait",
    principale: "conditionnel passé",
    exemple: "Si j'avais eu de l'argent, je serais parti en vacances.",
    creux:
      "La phrase dit en creux : je n'ai pas eu d'argent, je ne suis pas parti, et il est trop tard.",
  },
];

const SYSTEME_DEFAUT: Systeme = {
  nom: "—",
  si: "—",
  principale: "—",
  exemple: "—",
  creux: "—",
};

type ExoSi = {
  id: string;
  consigne: string;
  phrase: string;
  attendu: string;
  systeme: string;
  piege: boolean;
  explication: string;
};

const EXOS_SI: ReadonlyArray<ExoSi> = [
  {
    id: "s1",
    consigne: "Corrige la faute.",
    phrase: "Si j'aurais su, je ne serais pas venu.",
    attendu: "Si j'avais su, je ne serais pas venu.",
    systeme: "irréel du passé",
    piege: false,
    explication:
      "Faute lourde : après « si » de condition, jamais de conditionnel. Les si n'aiment pas les ré.",
  },
  {
    id: "s2",
    consigne: "Complète : si tu (venir) demain, nous (aller) au marché.",
    phrase: "Si tu … demain, nous … au marché.",
    attendu: "Si tu viens demain, nous irons au marché.",
    systeme: "le possible",
    piege: false,
    explication: "Rien n'indique que le fait soit improbable : si + présent → futur simple.",
  },
  {
    id: "s3",
    consigne: "Complète, sachant qu'il est trop tard.",
    phrase: "Si nous … plus tôt, nous … l'embouteillage.",
    attendu: "Si nous étions partis plus tôt, nous aurions évité l'embouteillage.",
    systeme: "irréel du passé",
    piege: false,
    explication:
      "Si + plus-que-parfait → conditionnel passé. Et la phrase affirme en creux que nous ne sommes pas partis plus tôt.",
  },
  {
    id: "s4",
    consigne: "Complète. Attention : ce « si » n'est peut-être pas une condition.",
    phrase: "Je me demande si tu … d'accord.",
    attendu: "Je me demande si tu serais d'accord.",
    systeme: "interrogation indirecte",
    piege: true,
    explication:
      "Test : remplace par « oui ou non ». « Je me demande oui ou non tu es d'accord » a du sens : c'est une interrogation indirecte, et le conditionnel y est autorisé.",
  },
  {
    id: "s5",
    consigne: "Complète : si j'(avoir) le temps, je t'(aider).",
    phrase: "Si j'… le temps, je t'… .",
    attendu: "Si j'avais le temps, je t'aiderais.",
    systeme: "irréel du présent",
    piege: false,
    explication: "Si + imparfait → conditionnel présent. En creux : je n'ai pas le temps.",
  },
  {
    id: "s6",
    consigne: "Corrige la faute.",
    phrase: "Si je serais riche, j'achèterais une maison.",
    attendu: "Si j'étais riche, j'achèterais une maison.",
    systeme: "irréel du présent",
    piege: false,
    explication:
      "Même faute lourde. Le conditionnel appartient à la principale, jamais à la subordonnée en « si ».",
  },
  {
    id: "s7",
    consigne: "Complète : s'il (pleuvoir) demain, le match (être) reporté.",
    phrase: "S'il … demain, le match … reporté.",
    attendu: "S'il pleut demain, le match sera reporté.",
    systeme: "le possible",
    piege: false,
    explication: "Une éventualité ordinaire : si + présent → futur.",
  },
  {
    id: "s8",
    consigne: "Complète. Attention au type de « si ».",
    phrase: "Dis-moi si tu … venir avec nous.",
    attendu: "Dis-moi si tu pourrais venir avec nous.",
    systeme: "interrogation indirecte",
    piege: true,
    explication:
      "Test : « dis-moi oui ou non tu peux venir » a du sens. Interrogation indirecte, conditionnel autorisé — et il apporte ici la nuance de politesse.",
  },
  {
    id: "s9",
    consigne: "Complète, en sachant que la chose n'a pas eu lieu.",
    phrase: "Si la mairie … le bac, le quartier … propre.",
    attendu: "Si la mairie avait remplacé le bac, le quartier serait resté propre.",
    systeme: "irréel du passé",
    piege: false,
    explication: "Si + plus-que-parfait → conditionnel passé. Le bac n'a pas été remplacé.",
  },
  {
    id: "s10",
    consigne: "Corrige la faute.",
    phrase: "Si tu aurais écouté, tu aurais compris.",
    attendu: "Si tu avais écouté, tu aurais compris.",
    systeme: "irréel du passé",
    piege: false,
    explication: "La faute porte sur la subordonnée. La principale, elle, était correcte.",
  },
  {
    id: "s11",
    consigne: "Complète : si vous (arroser) les plants, ils (survivre).",
    phrase: "Si vous … les plants, ils … .",
    attendu: "Si vous arrosez les plants, ils survivront.",
    systeme: "le possible",
    piege: false,
    explication: "Un conseil pour l'avenir : si + présent → futur.",
  },
  {
    id: "s12",
    consigne: "Complète. Attention au type de « si ».",
    phrase: "Il ignore si le camion … demain.",
    attendu: "Il ignore si le camion passera demain.",
    systeme: "interrogation indirecte",
    piege: true,
    explication:
      "Interrogation indirecte — « il ignore oui ou non le camion passera » — donc le futur y est permis, alors qu'après un « si » de condition il serait impossible.",
  },
  {
    id: "s13",
    consigne: "Complète : si j'(être) toi, j'(accepter).",
    phrase: "Si j'… toi, j'… .",
    attendu: "Si j'étais toi, j'accepterais.",
    systeme: "irréel du présent",
    piege: false,
    explication: "La formule du conseil. En creux : je ne suis pas toi.",
  },
  {
    id: "s14",
    consigne: "Remplace « si » par une autre tournure d'hypothèse.",
    phrase: "Si il venait, préviens-moi.",
    attendu: "Au cas où il viendrait, préviens-moi.",
    systeme: "autre tournure",
    piege: true,
    explication:
      "« Au cas où » appelle régulièrement le conditionnel — c'est la seule tournure d'hypothèse qui le fasse. Note aussi l'élision : on écrit « s'il », jamais « si il ».",
  },
  {
    id: "s15",
    consigne: "Complète, en sachant que la chose est impossible aujourd'hui.",
    phrase: "Si le village … une route, les récoltes … au marché.",
    attendu: "Si le village avait une route, les récoltes arriveraient au marché.",
    systeme: "irréel du présent",
    piege: false,
    explication: "Si + imparfait → conditionnel présent. En creux : il n'y a pas de route.",
  },
  {
    id: "s16",
    consigne: "Corrige la faute, puis nomme le système.",
    phrase: "Si nous aurions planté en juin, les arbres seraient vivants.",
    attendu: "Si nous avions planté en juin, les arbres seraient vivants.",
    systeme: "irréel du passé",
    piege: false,
    explication:
      "Petite subtilité : la principale est au conditionnel PRÉSENT parce que la conséquence vaut encore aujourd'hui. Le système reste celui de l'irréel du passé.",
  },
  {
    id: "s17",
    consigne: "Complète : si tu (vouloir), je t'(accompagner).",
    phrase: "Si tu …, je t'… .",
    attendu: "Si tu veux, je t'accompagne.",
    systeme: "le possible",
    piege: true,
    explication:
      "Variante du premier système : avec « si » + présent, la principale peut être au présent quand l'action est immédiate. « Je t'accompagnerai » est également correct.",
  },
  {
    id: "s18",
    consigne: "Complète : si elle (prévenir) à temps, nous (pouvoir) agir.",
    phrase: "Si elle … à temps, nous … agir.",
    attendu: "Si elle avait prévenu à temps, nous aurions pu agir.",
    systeme: "irréel du passé",
    piege: false,
    explication: "Si + plus-que-parfait → conditionnel passé. Elle n'a pas prévenu.",
  },
];

const EXO_SI_VIDE: ExoSi = {
  id: "",
  consigne: "—",
  phrase: "—",
  attendu: "—",
  systeme: "—",
  piege: false,
  explication: "—",
};

export function SystemeHypothetique() {
  const [degre, setDegre] = useState(0);
  const [i, setI] = useState(0);
  const [saisie, setSaisie] = useState("");
  const [montre, setMontre] = useState(false);
  const [refus, setRefus] = useState(false);

  const s = SYSTEMES[degre] ?? SYSTEME_DEFAUT;
  const e = EXOS_SI[i] ?? EXO_SI_VIDE;

  function verifier() {
    if (
      /\bsi\s+j'aurai|si\s+j'aurais|si\s+je\s+serais|si\s+tu\s+aurais|si\s+nous\s+aurions/i.test(
        saisie,
      )
    ) {
      setRefus(true);
      return;
    }
    setRefus(false);
    setMontre(true);
  }

  return (
    <div className="space-y-3">
      <p className="text-sm text-muted-foreground">
        D'abord l'atelier : règle le degré de réalité, et les deux temps de la phrase se fixent
        d'eux-mêmes. Ensuite, dix-huit phrases à corriger ou à compléter.
      </p>

      <div className="rounded-lg border border-border bg-background p-3">
        <Ctrl
          label="Degré de réalité"
          value={degre}
          min={0}
          max={2}
          step={1}
          onChange={(v) => setDegre(Math.round(v))}
          display={s.nom}
          color={PALETTE.purple}
        />

        <div className="mt-3 grid gap-2 sm:grid-cols-2">
          <div
            className="rounded-md px-2.5 py-2"
            style={{ backgroundColor: "rgba(37,99,235,0.08)" }}
          >
            <p className="text-[11px] font-semibold" style={{ color: PALETTE.blue }}>
              dans la subordonnée en « si »
            </p>
            <p className="text-sm font-semibold text-foreground">{s.si}</p>
          </div>
          <div
            className="rounded-md px-2.5 py-2"
            style={{ backgroundColor: "rgba(21,128,61,0.08)" }}
          >
            <p className="text-[11px] font-semibold" style={{ color: PALETTE.green }}>
              dans la principale
            </p>
            <p className="text-sm font-semibold text-foreground">{s.principale}</p>
          </div>
        </div>

        <p className="mt-2 text-sm italic text-foreground">{s.exemple}</p>
        <p className="mt-1 text-xs text-muted-foreground">{s.creux}</p>
      </div>

      <div className="rounded-lg border border-border bg-background p-3">
        <p className="text-xs font-semibold text-foreground">
          Phrase {i + 1} / {EXOS_SI.length} — {e.consigne}
        </p>
        <p className="mt-1 text-base text-foreground">{e.phrase}</p>
        {e.piege ? (
          <p className="mt-1 text-[11px] italic" style={{ color: PALETTE.orange }}>
            Vérifie d'abord la nature du « si » : condition, ou interrogation indirecte ?
          </p>
        ) : null}

        <div className="mt-2 flex flex-wrap items-center gap-2">
          <input
            value={saisie}
            onChange={(ev) => {
              setSaisie(ev.target.value);
              setRefus(false);
            }}
            placeholder="écris la phrase complète"
            className="min-w-0 flex-1 rounded-md border border-border bg-background px-2.5 py-1.5 text-sm text-foreground"
          />
          <button
            type="button"
            onClick={verifier}
            className="rounded-lg bg-primary px-3 py-1.5 text-xs font-semibold text-primary-foreground"
          >
            Vérifier
          </button>
        </div>

        {refus ? (
          <div className="mt-2">
            <Verdict tone="bad">
              <span className="font-semibold">Je refuse cette phrase. </span>
              Tu as écrit un conditionnel juste après « si ». C'est la faute que ce chapitre existe
              pour supprimer : les si n'aiment pas les ré. Mets la subordonnée à l'imparfait ou au
              plus-que-parfait, et garde le conditionnel pour la principale.
            </Verdict>
          </div>
        ) : null}

        {montre ? (
          <div className="mt-2 space-y-2">
            <Verdict tone="ok">
              <span className="font-semibold">La phrase attendue : </span>
              {e.attendu}
            </Verdict>
            <p className="text-xs text-muted-foreground">
              <span className="font-semibold">Système : {e.systeme}. </span>
              {e.explication}
            </p>
            <button
              type="button"
              onClick={() => {
                setI((n) => (n + 1) % EXOS_SI.length);
                setSaisie("");
                setMontre(false);
                setRefus(false);
              }}
              className="rounded-lg bg-primary px-3 py-1.5 text-xs font-semibold text-primary-foreground"
            >
              Phrase suivante
            </button>
          </div>
        ) : null}
      </div>

      <Citation auteur="trois lignes à savoir par cœur">
        Si + présent → futur. Si + imparfait → conditionnel présent. Si + plus-que-parfait →
        conditionnel passé. Elles couvrent tout ce que le français sait dire sur l'hypothèse, et la
        seule exception est le « si » d'interrogation indirecte, qu'on reconnaît en le remplaçant
        par « oui ou non ».
      </Citation>
    </div>
  );
}
