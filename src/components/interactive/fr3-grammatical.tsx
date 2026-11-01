import { useState } from "react";
import { PALETTE, Choice, Verdict } from "./controls";
import { Citation } from "./philo-noyau";

/** Français 3ème — chapitres 19 et 20 : homophones grammaticaux, subjonctif. */

/* ------------------------------------------------------------------ */
/* 1. Le test de chaque couple                                         */
/* ------------------------------------------------------------------ */

type Couple = {
  id: string;
  nom: string;
  test: string;
  formes: ReadonlyArray<{ forme: string; nature: string }>;
  phrases: ReadonlyArray<{ avant: string; apres: string; bon: string; pourquoi: string }>;
};

const COUPLES: ReadonlyArray<Couple> = [
  {
    id: "cp1",
    nom: "a / à",
    test: "Je remplace par AVAIT. Si la phrase tient, c'est le verbe « a ».",
    formes: [
      { forme: "a", nature: "verbe avoir, 3e personne" },
      { forme: "à", nature: "préposition" },
    ],
    phrases: [
      {
        avant: "Mon oncle",
        apres: "décidé de partir.",
        bon: "a",
        pourquoi: "« Mon oncle avait décidé » ✓ : c'est le verbe.",
      },
      {
        avant: "Il va",
        apres: "Douala demain.",
        bon: "à",
        pourquoi: "« Il va avait Douala » ✗ : c'est la préposition, avec son accent.",
      },
      {
        avant: "Elle n'",
        apres: "rien dit.",
        bon: "a",
        pourquoi: "« Elle n'avait rien dit » ✓.",
      },
      {
        avant: "Nous jouons",
        apres: "la balle.",
        bon: "à",
        pourquoi: "« Nous jouons avait la balle » ✗.",
      },
    ],
  },
  {
    id: "cp2",
    nom: "on / ont / on n'",
    test: "Je remplace ON par IL, et ONT par AVAIENT. Et si la phrase est négative, j'écoute le « n' ».",
    formes: [
      { forme: "on", nature: "pronom indéfini sujet" },
      { forme: "ont", nature: "verbe avoir, 3e personne du pluriel" },
      { forme: "on n'", nature: "pronom + négation élidée" },
    ],
    phrases: [
      {
        avant: "",
        apres: "part demain matin.",
        bon: "on",
        pourquoi: "« Il part demain » ✓.",
      },
      {
        avant: "Ils",
        apres: "fini avant nous.",
        bon: "ont",
        pourquoi: "« Ils avaient fini » ✓.",
      },
      {
        avant: "",
        apres: "a rien compris.",
        bon: "on n'",
        pourquoi:
          "Il y a « rien », donc une négation. « Il n'a rien compris » : le « n' » s'entend très bien dès qu'on remplace « on » par « il ».",
      },
      {
        avant: "",
        apres: "est jamais sûr de rien.",
        bon: "on n'",
        pourquoi: "« Jamais » annonce la négation. « Il n'est jamais sûr » ✓.",
      },
    ],
  },
  {
    id: "cp3",
    nom: "son / sont",
    test: "Je remplace SONT par ÉTAIENT, et SON par MON.",
    formes: [
      { forme: "son", nature: "déterminant possessif" },
      { forme: "sont", nature: "verbe être, 3e personne du pluriel" },
    ],
    phrases: [
      {
        avant: "Ils",
        apres: "rentrés tard.",
        bon: "sont",
        pourquoi: "« Ils étaient rentrés » ✓.",
      },
      {
        avant: "",
        apres: "cahier est neuf.",
        bon: "son",
        pourquoi: "« Mon cahier est neuf » ✓.",
      },
    ],
  },
  {
    id: "cp4",
    nom: "ce / se",
    test: "SE est toujours collé à un verbe, et se remplace par ME. S'il n'y a pas de verbe juste derrière, c'est CE.",
    formes: [
      { forme: "ce", nature: "déterminant ou pronom démonstratif" },
      { forme: "se", nature: "pronom réfléchi, devant un verbe" },
    ],
    phrases: [
      {
        avant: "Il",
        apres: "lave avant de partir.",
        bon: "se",
        pourquoi: "« Je me lave » ✓ : pronom réfléchi.",
      },
      {
        avant: "",
        apres: "cahier est à moi.",
        bon: "ce",
        pourquoi: "Il y a un nom derrière, pas un verbe. « Mon cahier » ✓.",
      },
      {
        avant: "",
        apres: "qui m'étonne, c'est le silence.",
        bon: "ce",
        pourquoi: "Il n'y a pas de verbe juste derrière mais le pronom relatif « qui ». Donc CE.",
      },
    ],
  },
  {
    id: "cp5",
    nom: "c'est / s'est",
    test: "S'EST se remplace par JE ME SUIS. C'EST se remplace par CELA EST.",
    formes: [
      { forme: "c'est", nature: "pronom démonstratif + être" },
      { forme: "s'est", nature: "pronom réfléchi + être" },
    ],
    phrases: [
      {
        avant: "Il",
        apres: "levé à cinq heures.",
        bon: "s'est",
        pourquoi: "« Je me suis levé » ✓.",
      },
      {
        avant: "",
        apres: "vrai, je l'ai vu.",
        bon: "c'est",
        pourquoi: "« Cela est vrai » ✓.",
      },
      {
        avant: "",
        apres: "normal de se tromper.",
        bon: "c'est",
        pourquoi: "« Cela est normal » ✓. Et « je me suis normal » n'a aucun sens.",
      },
    ],
  },
  {
    id: "cp6",
    nom: "ces / ses",
    test: "SES se remplace par LES SIENS. CES accepte qu'on ajoute -LÀ.",
    formes: [
      { forme: "ces", nature: "déterminant démonstratif pluriel" },
      { forme: "ses", nature: "déterminant possessif pluriel" },
    ],
    phrases: [
      {
        avant: "J'ai rangé",
        apres: "affaires, celles de mon frère.",
        bon: "ses",
        pourquoi: "« Les siennes » ✓ : elles appartiennent à quelqu'un.",
      },
      {
        avant: "Regarde",
        apres: "maisons, au bout de la rue.",
        bon: "ces",
        pourquoi: "« Ces maisons-LÀ » ✓ : on les montre.",
      },
    ],
  },
  {
    id: "cp7",
    nom: "leur / leurs",
    test: "Devant un VERBE, je remplace par LUI : c'est alors un pronom, et il est invariable.",
    formes: [
      { forme: "leur", nature: "pronom invariable devant un verbe, ou déterminant singulier" },
      { forme: "leurs", nature: "déterminant pluriel, devant un nom" },
    ],
    phrases: [
      {
        avant: "Je",
        apres: "ai dit la vérité.",
        bon: "leur",
        pourquoi:
          "« Je lui ai dit » ✓ : pronom, donc JAMAIS de s. « Je leurs ai dit » est la faute la plus répandue du français écrit.",
      },
      {
        avant: "Ils ont oublié",
        apres: "cahiers à la maison.",
        bon: "leurs",
        pourquoi: "Devant un nom pluriel : « ses cahiers » ✓, donc accord.",
      },
      {
        avant: "Chacun a pris",
        apres: "sac.",
        bon: "leur",
        pourquoi: "Un sac chacun : déterminant au singulier. « Son sac » ✓.",
      },
    ],
  },
  {
    id: "cp8",
    nom: "quel / qu'elle",
    test: "Je remplace par QU'IL. Si cela fonctionne, c'est « qu'elle » en deux mots.",
    formes: [
      { forme: "quel", nature: "adjectif interrogatif ou exclamatif, il s'accorde" },
      { forme: "qu'elle", nature: "conjonction que + pronom elle" },
    ],
    phrases: [
      {
        avant: "Je crois",
        apres: "viendra demain.",
        bon: "qu'elle",
        pourquoi: "« Je crois qu'il viendra » ✓.",
      },
      {
        avant: "",
        apres: "heure est-il ?",
        bon: "quel",
        pourquoi:
          "« Qu'il heure est-il » ✗. Et l'adjectif s'accorde : « heure » est féminin, donc « quelle ».",
      },
    ],
  },
  {
    id: "cp9",
    nom: "peu / peut / peux",
    test: "PEUT et PEUX se remplacent par POUVAIT et POUVAIS. PEU se remplace par BEAUCOUP.",
    formes: [
      { forme: "peu", nature: "adverbe de quantité" },
      { forme: "peut", nature: "verbe pouvoir, 3e personne" },
      { forme: "peux", nature: "verbe pouvoir, 1re ou 2e personne" },
    ],
    phrases: [
      {
        avant: "Il",
        apres: "venir samedi.",
        bon: "peut",
        pourquoi: "« Il pouvait venir » ✓.",
      },
      {
        avant: "Il mange très",
        apres: "le matin.",
        bon: "peu",
        pourquoi: "« Il mange beaucoup » ✓.",
      },
      {
        avant: "Je",
        apres: "t'aider si tu veux.",
        bon: "peux",
        pourquoi: "« Je pouvais t'aider » ✓, et la première personne prend un x.",
      },
    ],
  },
  {
    id: "cp10",
    nom: "la / l'a / là",
    test: "L'A se remplace par L'AVAIT. LÀ se remplace par ICI. LA se remplace par UNE.",
    formes: [
      { forme: "la", nature: "déterminant ou pronom" },
      { forme: "l'a", nature: "pronom + verbe avoir" },
      { forme: "là", nature: "adverbe de lieu" },
    ],
    phrases: [
      {
        avant: "",
        apres: "porte est fermée.",
        bon: "la",
        pourquoi: "« Une porte est fermée » ✓.",
      },
      {
        avant: "Il",
        apres: "vue ce matin.",
        bon: "l'a",
        pourquoi: "« Il l'avait vue » ✓.",
      },
      {
        avant: "Pose-le",
        apres: ", sur la table.",
        bon: "là",
        pourquoi: "« Pose-le ici » ✓.",
      },
    ],
  },
  {
    id: "cp11",
    nom: "est / et",
    test: "EST se remplace par ÉTAIT. ET se remplace par ET PUIS.",
    formes: [
      { forme: "est", nature: "verbe être, 3e personne" },
      { forme: "et", nature: "conjonction de coordination" },
    ],
    phrases: [
      {
        avant: "Il",
        apres: "malade depuis hier.",
        bon: "est",
        pourquoi: "« Il était malade » ✓.",
      },
      {
        avant: "Le riz",
        apres: "le poisson.",
        bon: "et",
        pourquoi: "« Le riz et puis le poisson » ✓.",
      },
    ],
  },
  {
    id: "cp12",
    nom: "notre / nôtre",
    test: "S'il y a « le », « la » ou « les » juste devant, il faut l'accent circonflexe.",
    formes: [
      { forme: "notre", nature: "déterminant possessif, devant un nom" },
      { forme: "nôtre", nature: "pronom possessif, précédé de l'article" },
    ],
    phrases: [
      {
        avant: "",
        apres: "maison est au bout du chemin.",
        bon: "notre",
        pourquoi: "Devant un nom, sans accent.",
      },
      {
        avant: "Cette maison est la",
        apres: ".",
        bon: "nôtre",
        pourquoi: "Précédé de « la » : pronom, donc accent circonflexe.",
      },
    ],
  },
  {
    id: "cp13",
    nom: "quand / quant / qu'en",
    test: "Je remplace par LORSQUE. Si cela tient, c'est QUAND.",
    formes: [
      { forme: "quand", nature: "conjonction de temps" },
      { forme: "quant", nature: "dans « quant à », au sens de « en ce qui concerne »" },
      { forme: "qu'en", nature: "contraction de « que en »" },
    ],
    phrases: [
      {
        avant: "",
        apres: "la cloche sonne, tout le monde sort.",
        bon: "quand",
        pourquoi: "« Lorsque la cloche sonne » ✓.",
      },
      {
        avant: "",
        apres: "à moi, je reste.",
        bon: "quant",
        pourquoi: "« Lorsque à moi » ✗. Le sens est « en ce qui me concerne » : « quant à ».",
      },
      {
        avant: "",
        apres: "penses-tu ?",
        bon: "qu'en",
        pourquoi:
          "Contraction de « que en » : qu'en penses-tu, c'est-à-dire que penses-tu de cela.",
      },
    ],
  },
];

const COUPLE_VIDE: Couple = { id: "", nom: "—", test: "—", formes: [], phrases: [] };

export function TestsHomophonesGram() {
  const [i, setI] = useState(0);
  const [j, setJ] = useState(0);
  const [aide, setAide] = useState(true);
  const [rep, setRep] = useState<string | null>(null);
  const [scores, setScores] = useState<Record<string, { bons: number; total: number }>>({});

  const c = COUPLES[i] ?? COUPLE_VIDE;
  const ph = c.phrases[j] ?? { avant: "—", apres: "", bon: "", pourquoi: "—" };
  const options = c.formes.map((f) => f.forme);

  function repondre(v: string) {
    setRep(v);
    setScores((s) => {
      const prev = s[c.nom] ?? { bons: 0, total: 0 };
      return {
        ...s,
        [c.nom]: {
          bons: prev.bons + (v === ph.bon && !aide ? 1 : 0),
          total: prev.total + (aide ? 0 : 1),
        },
      };
    });
  }

  function suivant() {
    setRep(null);
    if (j < c.phrases.length - 1) {
      setJ((n) => n + 1);
      if (j === 0) setAide(false);
    } else {
      setI((n) => (n + 1) % COUPLES.length);
      setJ(0);
      setAide(true);
    }
  }

  const liste = (Object.entries(scores) as ReadonlyArray<[string, { bons: number; total: number }]>)
    .filter(([, v]) => v.total > 0 && v.bons < v.total)
    .map(([k]) => k);

  return (
    <div className="space-y-3">
      <p className="text-sm text-muted-foreground">
        On ne retient pas des règles : on retient des remplacements. Le test t'est donné sur la
        première phrase, puis il disparaît.
      </p>

      <div className="rounded-lg border border-border bg-background p-3">
        <p className="text-center text-lg font-semibold" style={{ color: PALETTE.purple }}>
          {c.nom}
        </p>

        {aide ? (
          <p
            className="mt-2 rounded-md px-2.5 py-2 text-xs"
            style={{ backgroundColor: "rgba(202,138,4,0.12)", color: "#78350f" }}
          >
            <span className="font-semibold">Le test. </span>
            {c.test}
          </p>
        ) : (
          <p className="mt-2 text-center text-[11px] italic text-muted-foreground">
            À toi d'appliquer le test, seul.
          </p>
        )}

        <div className="mt-2 flex flex-wrap gap-1.5">
          {c.formes.map((f) => (
            <span
              key={f.forme}
              className="rounded px-2 py-0.5 text-[11px]"
              style={{ backgroundColor: "rgba(100,116,139,0.10)", color: PALETTE.slate }}
            >
              <span className="font-semibold">{f.forme}</span> — {f.nature}
            </span>
          ))}
        </div>

        <p className="mt-3 text-base text-foreground">
          {ph.avant}{" "}
          <span
            className="rounded px-2 py-0.5 font-semibold"
            style={{
              backgroundColor: rep ? "rgba(37,99,235,0.14)" : "rgba(100,116,139,0.14)",
              color: rep ? PALETTE.blue : PALETTE.slate,
            }}
          >
            {rep ?? "……"}
          </span>{" "}
          {ph.apres}
        </p>

        <div className="mt-3 flex flex-wrap gap-1.5">
          {options.map((o) => (
            <button
              key={o}
              type="button"
              disabled={rep !== null}
              onClick={() => repondre(o)}
              className="rounded-md border px-3 py-1.5 text-sm"
              style={{
                borderColor: rep !== null && o === ph.bon ? PALETTE.green : "rgba(100,116,139,0.3)",
                backgroundColor:
                  rep !== null && o === ph.bon
                    ? "rgba(21,128,61,0.10)"
                    : rep === o
                      ? "rgba(185,28,28,0.10)"
                      : "transparent",
              }}
            >
              {o}
            </button>
          ))}
        </div>

        {rep !== null ? (
          <div className="mt-3 space-y-2">
            <Verdict tone={rep === ph.bon ? "ok" : "bad"}>
              <span className="font-semibold">« {ph.bon} ». </span>
              {ph.pourquoi}
            </Verdict>
            <button
              type="button"
              onClick={suivant}
              className="rounded-lg bg-primary px-3 py-1.5 text-xs font-semibold text-primary-foreground"
            >
              {j < c.phrases.length - 1
                ? `Phrase suivante (${j + 1} / ${c.phrases.length})`
                : `Couple suivant (${i + 1} / ${COUPLES.length})`}
            </button>
          </div>
        ) : null}
      </div>

      {liste.length > 0 ? (
        <p
          className="rounded-md px-2.5 py-2 text-[11px]"
          style={{ backgroundColor: "rgba(185,28,28,0.10)", color: "#7f1d1d" }}
        >
          <span className="font-semibold">Ta liste personnelle. </span>
          Les couples qui te résistent : {liste.join(", ")}. Ce sont ceux-là qu'il faudra relire la
          veille de l'examen, et non les treize.
        </p>
      ) : null}

      <Citation auteur="pourquoi ces fautes coûtent si cher">
        Parce qu'elles sont très visibles — un correcteur voit « il va a Douala » avant d'avoir lu
        la phrase — et parce que les mots concernés sont parmi les plus courants du français. Tu les
        écris des dizaines de fois par copie.
      </Citation>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* 2. Le « a » et le « on n' »                                         */
/* ------------------------------------------------------------------ */

const MOTS_NEGATION = ["rien", "jamais", "plus", "personne", "aucun", "aucune", "guère", "nul"];

type PhraseAOn = {
  id: string;
  famille: "a" | "on";
  jetons: ReadonlyArray<string>;
  /** Index du jeton à compléter. */
  trou: number;
  options: ReadonlyArray<string>;
  bon: string;
  /** La phrase réécrite pour le test. */
  test: string;
  pourquoi: string;
};

const PHRASES_AON: ReadonlyArray<PhraseAOn> = [
  {
    id: "ao1",
    famille: "a",
    jetons: ["Mon", "frère", "…", "décidé", "de", "partir."],
    trou: 2,
    options: ["a", "à"],
    bon: "a",
    test: "Mon frère AVAIT décidé de partir.",
    pourquoi: "Le remplacement par « avait » fonctionne : c'est le verbe avoir.",
  },
  {
    id: "ao2",
    famille: "a",
    jetons: ["Il", "est", "parti", "…", "Yaoundé", "hier."],
    trou: 3,
    options: ["a", "à"],
    bon: "à",
    test: "Il est parti AVAIT Yaoundé hier.",
    pourquoi: "Le remplacement ne veut rien dire : c'est la préposition, avec son accent.",
  },
  {
    id: "ao3",
    famille: "a",
    jetons: ["Elle", "n'", "…", "rien", "voulu", "entendre."],
    trou: 2,
    options: ["a", "à"],
    bon: "a",
    test: "Elle n'AVAIT rien voulu entendre.",
    pourquoi: "Verbe avoir. Et note le « n' » qui est déjà là : la phrase est négative.",
  },
  {
    id: "ao4",
    famille: "a",
    jetons: ["Ce", "sac", "appartient", "…", "ma", "mère."],
    trou: 3,
    options: ["a", "à"],
    bon: "à",
    test: "Ce sac appartient AVAIT ma mère.",
    pourquoi: "Préposition : « appartenir à ».",
  },
  {
    id: "ao5",
    famille: "a",
    jetons: ["Il", "m'", "…", "dit", "de", "revenir."],
    trou: 2,
    options: ["a", "à"],
    bon: "a",
    test: "Il m'AVAIT dit de revenir.",
    pourquoi: "Verbe avoir, et le pronom « me » s'élide devant lui : « m'a ».",
  },
  {
    id: "ao6",
    famille: "a",
    jetons: ["Nous", "jouons", "…", "la", "balle", "le", "soir."],
    trou: 2,
    options: ["a", "à"],
    bon: "à",
    test: "Nous jouons AVAIT la balle.",
    pourquoi: "Préposition : « jouer à ».",
  },
  {
    id: "ao7",
    famille: "a",
    jetons: ["Le", "camion", "…", "cessé", "de", "passer."],
    trou: 2,
    options: ["a", "à"],
    bon: "a",
    test: "Le camion AVAIT cessé de passer.",
    pourquoi: "Verbe avoir.",
  },
  {
    id: "ao8",
    famille: "a",
    jetons: ["Il", "pense", "…", "son", "examen", "jour", "et", "nuit."],
    trou: 2,
    options: ["a", "à"],
    bon: "à",
    test: "Il pense AVAIT son examen.",
    pourquoi: "Préposition : « penser à ».",
  },
  {
    id: "ao9",
    famille: "on",
    jetons: ["…", "part", "demain", "matin."],
    trou: 0,
    options: ["on", "ont", "on n'"],
    bon: "on",
    test: "IL part demain matin.",
    pourquoi: "Phrase affirmative, aucun mot de négation : pas de « n' ».",
  },
  {
    id: "ao10",
    famille: "on",
    jetons: ["Ils", "…", "fini", "avant", "nous."],
    trou: 1,
    options: ["on", "ont", "on n'"],
    bon: "ont",
    test: "Ils AVAIENT fini avant nous.",
    pourquoi: "Verbe avoir au pluriel, après le sujet « ils ».",
  },
  {
    id: "ao11",
    famille: "on",
    jetons: ["…", "a", "rien", "compris", "à", "son", "explication."],
    trou: 0,
    options: ["on", "ont", "on n'"],
    bon: "on n'",
    test: "IL N'a rien compris.",
    pourquoi:
      "« Rien » annonce la négation. En remplaçant « on » par « il », le « n' » s'entend très bien — et il faut donc l'écrire.",
  },
  {
    id: "ao12",
    famille: "on",
    jetons: ["…", "est", "jamais", "sûr", "de", "rien."],
    trou: 0,
    options: ["on", "ont", "on n'"],
    bon: "on n'",
    test: "IL N'est jamais sûr de rien.",
    pourquoi: "« Jamais » annonce la négation.",
  },
  {
    id: "ao13",
    famille: "on",
    jetons: ["…", "a", "tout", "vu", "depuis", "la", "fenêtre."],
    trou: 0,
    options: ["on", "ont", "on n'"],
    bon: "on",
    test: "IL a tout vu.",
    pourquoi:
      "Phrase affirmative : « tout vu », et non « rien vu ». Aucune négation, donc pas de « n' ».",
  },
  {
    id: "ao14",
    famille: "on",
    jetons: ["…", "y", "comprend", "plus", "rien."],
    trou: 0,
    options: ["on", "ont", "on n'"],
    bon: "on n'",
    test: "IL N'y comprend plus rien.",
    pourquoi: "Deux mots de négation ici : « plus » et « rien ».",
  },
  {
    id: "ao15",
    famille: "on",
    jetons: ["Les", "habitants", "…", "écrit", "deux", "fois", "à", "la", "mairie."],
    trou: 2,
    options: ["on", "ont", "on n'"],
    bon: "ont",
    test: "Les habitants AVAIENT écrit deux fois.",
    pourquoi: "Sujet pluriel, verbe avoir.",
  },
  {
    id: "ao16",
    famille: "on",
    jetons: ["…", "aurait", "jamais", "cru", "ça."],
    trou: 0,
    options: ["on", "ont", "on n'"],
    bon: "on n'",
    test: "IL N'aurait jamais cru ça.",
    pourquoi: "« Jamais » : négation. Et le verbe est au conditionnel passé.",
  },
  {
    id: "ao17",
    famille: "on",
    jetons: ["…", "a", "aucune", "raison", "de", "s'inquiéter."],
    trou: 0,
    options: ["on", "ont", "on n'"],
    bon: "on n'",
    test: "IL N'a aucune raison de s'inquiéter.",
    pourquoi:
      "« Aucune » est un mot de négation, et beaucoup l'oublient parce qu'il ne ressemble pas à « ne… pas ».",
  },
  {
    id: "ao18",
    famille: "on",
    jetons: ["…", "nous", "a", "prévenus", "trop", "tard."],
    trou: 0,
    options: ["on", "ont", "on n'"],
    bon: "on",
    test: "IL nous a prévenus trop tard.",
    pourquoi: "Affirmative : aucun mot de négation.",
  },
  {
    id: "ao19",
    famille: "on",
    jetons: ["Mes", "voisins", "…", "déménagé", "en", "janvier."],
    trou: 2,
    options: ["on", "ont", "on n'"],
    bon: "ont",
    test: "Mes voisins AVAIENT déménagé.",
    pourquoi: "Sujet pluriel.",
  },
  {
    id: "ao20",
    famille: "on",
    jetons: ["…", "en", "parle", "guère", "dans", "le", "quartier."],
    trou: 0,
    options: ["on", "ont", "on n'"],
    bon: "on n'",
    test: "IL N'en parle guère.",
    pourquoi: "« Guère » est un mot de négation, le plus discret de tous.",
  },
  {
    id: "ao21",
    famille: "a",
    jetons: ["Il", "y", "…", "six", "bacs", "pour", "tout", "le", "quartier."],
    trou: 2,
    options: ["a", "à"],
    bon: "a",
    test: "Il y AVAIT six bacs.",
    pourquoi: "Verbe avoir, dans la tournure « il y a ».",
  },
  {
    id: "ao22",
    famille: "a",
    jetons: ["Elle", "a", "réussi", "…", "convaincre", "la", "mairie."],
    trou: 3,
    options: ["a", "à"],
    bon: "à",
    test: "Elle a réussi AVAIT convaincre.",
    pourquoi: "Préposition devant un infinitif : « réussir à ».",
  },
  {
    id: "ao23",
    famille: "on",
    jetons: ["…", "a", "beau", "écrire", ",", "personne", "ne", "répond."],
    trou: 0,
    options: ["on", "ont", "on n'"],
    bon: "on",
    test: "IL a beau écrire.",
    pourquoi:
      "PIÈGE : il y a bien « personne » dans la phrase, mais il appartient à la SECONDE proposition, pas à celle du « on ». La négation ne porte pas sur « a beau écrire ».",
  },
  {
    id: "ao24",
    famille: "on",
    jetons: ["…", "avait", "plus", "de", "bac", "depuis", "janvier."],
    trou: 0,
    options: ["on", "ont", "on n'"],
    bon: "on n'",
    test: "IL N'avait plus de bac.",
    pourquoi: "« Plus » : négation.",
  },
];

const PHRASE_AON_VIDE: PhraseAOn = {
  id: "",
  famille: "a",
  jetons: [],
  trou: 0,
  options: [],
  bon: "",
  test: "—",
  pourquoi: "—",
};

export function AOuA() {
  const [i, setI] = useState(0);
  const [rep, setRep] = useState<string | null>(null);
  const [testFait, setTestFait] = useState(false);

  const p = PHRASES_AON[i] ?? PHRASE_AON_VIDE;
  const negations = p.jetons.filter((j) => MOTS_NEGATION.includes(j.toLowerCase()));

  return (
    <div className="space-y-3">
      <p className="text-sm text-muted-foreground">
        Les deux couples qui coûtent le plus. Les mots qui annoncent une négation sont surlignés en
        rouge : dès que l'un d'eux suit « on », cherche le « n' ».
      </p>

      <div className="rounded-lg border border-border bg-background p-3">
        <p className="text-base text-foreground">
          {p.jetons.map((j, k) => {
            if (k === p.trou) {
              return (
                <span
                  key={`${p.id}-${k}`}
                  className="mx-1 rounded px-2 py-0.5 font-semibold"
                  style={{
                    backgroundColor: rep ? "rgba(37,99,235,0.14)" : "rgba(100,116,139,0.14)",
                    color: rep ? PALETTE.blue : PALETTE.slate,
                  }}
                >
                  {rep ?? "……"}
                </span>
              );
            }
            const neg = MOTS_NEGATION.includes(j.toLowerCase());
            return (
              <span key={`${p.id}-${k}`}>
                <span
                  style={{
                    backgroundColor: neg ? "rgba(185,28,28,0.16)" : "transparent",
                    color: neg ? PALETTE.red : "inherit",
                    fontWeight: neg ? 700 : 400,
                    borderRadius: 3,
                    padding: neg ? "0 3px" : 0,
                  }}
                >
                  {j}
                </span>{" "}
              </span>
            );
          })}
        </p>

        {p.famille === "on" ? (
          <p className="mt-2 text-[11px] text-muted-foreground">
            {negations.length > 0
              ? `Mots de négation repérés : ${negations.join(", ")}.`
              : "Aucun mot de négation dans cette phrase."}
          </p>
        ) : null}

        {!testFait ? (
          <button
            type="button"
            onClick={() => setTestFait(true)}
            className="mt-2 rounded-lg border border-border px-3 py-1.5 text-xs font-semibold text-foreground"
          >
            {p.famille === "a" ? "Réécrire avec « avait »" : "Remplacer « on » par « il »"}
          </button>
        ) : (
          <p
            className="mt-2 rounded-md px-2 py-1.5 text-sm"
            style={{ backgroundColor: "rgba(202,138,4,0.12)", color: "#78350f" }}
          >
            {p.test}
          </p>
        )}

        <div className="mt-3 flex flex-wrap gap-1.5">
          {p.options.map((o) => (
            <button
              key={o}
              type="button"
              disabled={rep !== null}
              onClick={() => setRep(o)}
              className="rounded-md border px-3 py-1.5 text-sm"
              style={{
                borderColor: rep !== null && o === p.bon ? PALETTE.green : "rgba(100,116,139,0.3)",
                backgroundColor:
                  rep !== null && o === p.bon
                    ? "rgba(21,128,61,0.10)"
                    : rep === o
                      ? "rgba(185,28,28,0.10)"
                      : "transparent",
              }}
            >
              {o}
            </button>
          ))}
        </div>

        {rep !== null ? (
          <div className="mt-3 space-y-2">
            <Verdict tone={rep === p.bon ? "ok" : "bad"}>
              <span className="font-semibold">« {p.bon} ». </span>
              {p.pourquoi}
            </Verdict>
            <button
              type="button"
              onClick={() => {
                setI((n) => (n + 1) % PHRASES_AON.length);
                setRep(null);
                setTestFait(false);
              }}
              className="rounded-lg bg-primary px-3 py-1.5 text-xs font-semibold text-primary-foreground"
            >
              Phrase suivante ({i + 1} / {PHRASES_AON.length})
            </button>
          </div>
        ) : null}
      </div>

      <Citation auteur="le « n' » que personne n'entend">
        Il ne s'entend pas à l'oral, et c'est pourquoi on l'oublie. Mais remplace « on » par « il »
        et tu l'entendras aussitôt : « il n'a rien vu ». Huit des vingt-quatre phrases de cet
        exercice en avaient besoin.
      </Citation>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* 3. La dictée grammaticale                                           */
/* ------------------------------------------------------------------ */

type MotGram = {
  ecrit: string;
  correct: string;
  test: string;
  explication: string;
  /** Vrai quand les deux formes sont grammaticalement possibles. */
  ambigu?: boolean;
};

type TexteGram = {
  id: string;
  titre: string;
  source?: string;
  avant: string;
  mots: ReadonlyArray<MotGram>;
  liaisons: ReadonlyArray<string>;
};

const TEXTES_GRAM: ReadonlyArray<TexteGram> = [
  {
    id: "tg1",
    titre: "Le départ de l'oncle",
    avant: "Mon oncle",
    mots: [
      {
        ecrit: "a",
        correct: "a",
        test: "« Mon oncle AVAIT décidé » ✓",
        explication: "Correct : verbe avoir.",
      },
      {
        ecrit: "a",
        correct: "à",
        test: "« partir AVAIT Garoua » ✗",
        explication: "Préposition, avec accent.",
      },
      {
        ecrit: "ses",
        correct: "ses",
        test: "« les siennes » ✓",
        explication: "Correct : ce sont les affaires de l'oncle.",
      },
    ],
    liaisons: [" décidé de partir ", " Garoua. Il a emporté ", " affaires dans un seul sac."],
  },
  {
    id: "tg2",
    titre: "Au conseil de quartier",
    avant: "Les habitants",
    mots: [
      {
        ecrit: "on",
        correct: "ont",
        test: "« les habitants AVAIENT écrit » ✓",
        explication: "Sujet pluriel : c'est le verbe avoir, « ont ».",
      },
      {
        ecrit: "leurs",
        correct: "leur",
        test: "« la mairie ne LUI a pas répondu » ✓",
        explication: "Devant un VERBE, c'est un pronom invariable. Jamais de s.",
      },
      {
        ecrit: "se",
        correct: "ce",
        test: "Y a-t-il un verbe juste derrière ?",
        explication: "Non, il y a le pronom relatif « qui ». Donc CE.",
      },
    ],
    liaisons: [
      " écrit deux fois, et la mairie ne ",
      " a pas répondu. ",
      " qui les étonne, c'est le silence.",
    ],
  },
  {
    id: "tg3",
    titre: "La saison des pluies",
    avant: "",
    mots: [
      {
        ecrit: "On",
        correct: "On n'",
        test: "« IL N'a jamais vu ça » ✓",
        explication: "« Jamais » annonce la négation : il faut le « n' ».",
      },
      {
        ecrit: "sont",
        correct: "sont",
        test: "« les caniveaux ÉTAIENT bouchés » ✓",
        explication: "Correct : verbe être au pluriel.",
      },
      {
        ecrit: "ces",
        correct: "ses",
        test: "Appartiennent-ils à quelqu'un, ou les montre-t-on ?",
        explication:
          "Il s'agit des sacs du commerçant : possessif, « ses ». « Ces sacs-là » n'aurait pas de sens ici.",
      },
    ],
    liaisons: [
      " a jamais vu ça : les caniveaux ",
      " bouchés, et le commerçant a perdu tous ",
      " sacs.",
    ],
  },
  {
    id: "tg4",
    titre: "Au stand du marché",
    source: "d'après un sujet de BEPC",
    avant: "",
    mots: [
      {
        ecrit: "Ses",
        correct: "C'est",
        test: "« CELA EST une bonne idée » ✓",
        explication: "« C'est », pronom démonstratif + être.",
      },
      {
        ecrit: "c'est",
        correct: "s'est",
        test: "« JE ME SUIS installé » ✓",
        explication: "Pronom réfléchi + être.",
      },
      {
        ecrit: "quel",
        correct: "qu'elle",
        test: "« je crois QU'IL viendra » ✓",
        explication: "Que + elle, en deux mots.",
      },
      {
        ecrit: "peu",
        correct: "peut",
        test: "« il POUVAIT revenir » ✓",
        explication: "Verbe pouvoir.",
      },
    ],
    liaisons: [
      " une bonne idée. Le vendeur ",
      " installé au coin, et je crois ",
      " reviendra demain si elle ",
      " .",
    ],
  },
  {
    id: "tg5",
    titre: "La lettre au maire",
    source: "d'après un sujet de BEPC",
    avant: "Monsieur le Maire,",
    mots: [
      {
        ecrit: "quand",
        correct: "Quant",
        test: "« LORSQUE à nous » ✗",
        explication: "Le sens est « en ce qui nous concerne » : « quant à », avec un t.",
      },
      {
        ecrit: "notre",
        correct: "notre",
        test: "Y a-t-il « le », « la » ou « les » devant ?",
        explication: "Non, et il y a un nom derrière : déterminant, sans accent.",
      },
      {
        ecrit: "la",
        correct: "là",
        test: "« il est ICI depuis janvier » ✓",
        explication: "Adverbe de lieu, avec accent grave.",
      },
      {
        ecrit: "ont",
        correct: "on n'",
        test: "« IL N'a plus rien demandé » ✓",
        explication: "« Plus » et « rien » : double négation. Et le sujet n'est pas pluriel.",
      },
    ],
    liaisons: [
      " ",
      " à nous, ",
      " quartier attend un bac depuis janvier. Le trou est ",
      ", devant l'école. Depuis six mois, ",
      " a plus rien demandé, parce que personne ne répond.",
    ],
  },
  {
    id: "tg6",
    titre: "Les tarifs du marché — le cas insoluble",
    avant: "Les commerçants",
    mots: [
      {
        ecrit: "se",
        correct: "se",
        test: "Y a-t-il un verbe juste derrière ? « sont réunis » ✓",
        explication: "Correct : pronom réfléchi devant un verbe.",
      },
      {
        ecrit: "ces",
        correct: "leurs",
        test: "Aucun test ne tranche ici.",
        explication:
          "LE CAS INSOLUBLE. « Ces tarifs » et « leurs tarifs » sont tous deux corrects, et ne disent pas la même chose : « ces » montre des tarifs dont on vient de parler, « leurs » désigne les tarifs des commerçants eux-mêmes. Le texte parle des commerçants, donc « leurs ». Les tests tranchent entre les formes ; ils ne pensent pas à ta place.",
        ambigu: true,
      },
      {
        ecrit: "quel",
        correct: "Quelle",
        test: "« QU'IL que soit la décision » ✗",
        explication: "Adjectif, accordé avec « décision », féminin singulier.",
      },
    ],
    liaisons: [
      " sont réunis hier pour revoir ",
      " tarifs. ",
      " que soit la décision, ils l'appliqueront lundi.",
    ],
  },
  {
    id: "tg7",
    titre: "Après l'inondation",
    avant: "",
    mots: [
      {
        ecrit: "Ont",
        correct: "On",
        test: "« IL a tout perdu » ✓",
        explication: "Pronom sujet, et la phrase est affirmative.",
      },
      {
        ecrit: "l'a",
        correct: "l'a",
        test: "« il L'AVAIT vue monter » ✓",
        explication: "Correct : pronom + verbe avoir.",
      },
      {
        ecrit: "est",
        correct: "et",
        test: "« les matelas ET PUIS les cahiers » ✓",
        explication: "Conjonction de coordination.",
      },
      {
        ecrit: "sont",
        correct: "son",
        test: "« MON uniforme » ✓",
        explication: "Déterminant possessif devant un nom singulier.",
      },
    ],
    liaisons: [
      " a tout perdu cette nuit-là. Mon frère ",
      " vue monter jusqu'au mur. Les matelas ",
      " les cahiers ont été jetés, et ma sœur a perdu ",
      " uniforme.",
    ],
  },
  {
    id: "tg8",
    titre: "Le composteur",
    avant: "Les jeunes",
    mots: [
      {
        ecrit: "on",
        correct: "ont",
        test: "« ils AVAIENT installé » ✓",
        explication: "Sujet pluriel.",
      },
      {
        ecrit: "leur",
        correct: "leur",
        test: "« je LUI ai montré » ✓",
        explication: "Correct : pronom invariable devant un verbe.",
      },
      {
        ecrit: "ses",
        correct: "ces",
        test: "« ces épluchures-LÀ » ✓",
        explication: "On montre les épluchures du bac : démonstratif.",
      },
      {
        ecrit: "peux",
        correct: "peut",
        test: "« on POUVAIT » ✓, et le sujet est « on »",
        explication: "Troisième personne du singulier : « peut », avec un t.",
      },
      {
        ecrit: "a",
        correct: "à",
        test: "« servir AVAIT quelque chose » ✗",
        explication: "Préposition.",
      },
    ],
    liaisons: [
      " ",
      " installé le bac derrière l'école. On ",
      " a montré comment faire : ",
      " épluchures qu'on jetait, on ",
      " les faire servir ",
      " quelque chose.",
    ],
  },
];

const TEXTE_GRAM_VIDE: TexteGram = { id: "", titre: "—", avant: "", mots: [], liaisons: [] };

export function DicteeGrammaticale() {
  const [i, setI] = useState(0);
  const [ouvert, setOuvert] = useState<number | null>(null);
  const [juges, setJuges] = useState<Record<number, "garde" | "corrige">>({});
  const [testVu, setTestVu] = useState<ReadonlyArray<number>>([]);

  const t = TEXTES_GRAM[i] ?? TEXTE_GRAM_VIDE;
  const traites = Object.keys(juges).length;
  const bons = t.mots.filter((m, k) => {
    const r = juges[k];
    if (r === undefined) return false;
    return (r === "corrige") === (m.ecrit !== m.correct);
  }).length;
  const fautes = t.mots.filter((m) => m.ecrit !== m.correct).length;

  return (
    <div className="space-y-3">
      <p className="text-sm text-muted-foreground">
        Clique sur un mot pour que la simulation applique le test devant toi, puis juge : tu le
        gardes, ou tu le corriges.
      </p>

      <div className="rounded-lg border border-border bg-background p-3">
        <p className="text-xs font-semibold text-foreground">
          {t.titre}
          {t.source ? (
            <span className="ml-1 font-normal text-muted-foreground">({t.source})</span>
          ) : null}
        </p>

        <p className="mt-2 text-base leading-8 text-foreground">
          {t.avant}
          {t.mots.map((m, k) => {
            const r = juges[k];
            const faux = m.ecrit !== m.correct;
            const affiche = r === "corrige" ? m.correct : m.ecrit;
            const couleur =
              r === undefined
                ? "rgba(202,138,4,0.18)"
                : (r === "corrige") === faux
                  ? "rgba(21,128,61,0.16)"
                  : "rgba(185,28,28,0.14)";
            return (
              <span key={`${t.id}-${k}`}>
                <button
                  type="button"
                  onClick={() => setOuvert(ouvert === k ? null : k)}
                  className="rounded px-1 font-semibold"
                  style={{ backgroundColor: couleur, color: PALETTE.slate }}
                >
                  {affiche}
                </button>
                {t.liaisons[k] ?? " "}
              </span>
            );
          })}
        </p>

        {ouvert !== null && t.mots[ouvert] !== undefined ? (
          <div className="mt-3 rounded-md border border-border/60 p-2.5">
            <p className="text-xs font-semibold text-foreground">
              « {t.mots[ouvert]?.ecrit ?? ""} »
            </p>

            {!testVu.includes(ouvert) ? (
              <button
                type="button"
                onClick={() => setTestVu((v) => [...v, ouvert])}
                className="mt-1.5 rounded-lg border border-border px-3 py-1.5 text-xs font-semibold text-foreground"
              >
                Appliquer le test
              </button>
            ) : (
              <p
                className="mt-1.5 rounded-md px-2 py-1.5 text-xs"
                style={{ backgroundColor: "rgba(202,138,4,0.12)", color: "#78350f" }}
              >
                {t.mots[ouvert]?.test ?? ""}
              </p>
            )}

            <div className="mt-2 flex gap-2">
              <button
                type="button"
                onClick={() => setJuges((j) => ({ ...j, [ouvert]: "garde" }))}
                className="rounded-lg border border-border px-3 py-1.5 text-xs font-semibold text-foreground"
              >
                Je le garde
              </button>
              <button
                type="button"
                onClick={() => setJuges((j) => ({ ...j, [ouvert]: "corrige" }))}
                className="rounded-lg bg-primary px-3 py-1.5 text-xs font-semibold text-primary-foreground"
              >
                Je le corrige
              </button>
            </div>

            {juges[ouvert] !== undefined ? (
              <div className="mt-2">
                <Verdict
                  tone={
                    t.mots[ouvert]?.ambigu === true
                      ? "warn"
                      : (juges[ouvert] === "corrige") ===
                          ((t.mots[ouvert]?.ecrit ?? "") !== (t.mots[ouvert]?.correct ?? ""))
                        ? "ok"
                        : "bad"
                  }
                >
                  <span className="font-semibold">
                    La forme attendue : « {t.mots[ouvert]?.correct ?? ""} ».{" "}
                  </span>
                  {t.mots[ouvert]?.explication ?? ""}
                </Verdict>
              </div>
            ) : null}
          </div>
        ) : null}

        <p className="mt-3 text-[11px] text-muted-foreground">
          {traites} / {t.mots.length} mots jugés
          {traites > 0
            ? ` — ${bons} jugement${bons > 1 ? "s" : ""} exact${bons > 1 ? "s" : ""}`
            : ""}
          {traites === t.mots.length
            ? `. Ce texte contenait ${fautes} faute${fautes > 1 ? "s" : ""}.`
            : "."}
        </p>

        <button
          type="button"
          onClick={() => {
            setI((n) => (n + 1) % TEXTES_GRAM.length);
            setJuges({});
            setOuvert(null);
            setTestVu([]);
          }}
          className="mt-2 rounded-lg bg-primary px-3 py-1.5 text-xs font-semibold text-primary-foreground"
        >
          Texte suivant ({i + 1} / {TEXTES_GRAM.length})
        </button>
      </div>

      <Citation auteur="un cas qu'aucun test ne tranche">
        Au sixième texte, « ces tarifs » et « leurs tarifs » sont tous deux corrects, et ne disent
        pas la même chose. Les tests tranchent entre les formes ; ils ne pensent pas à ta place.
        C'est la leçon la plus utile du chapitre.
      </Citation>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* 4. Fabriquer le subjonctif                                          */
/* ------------------------------------------------------------------ */

type VerbeSubj = {
  id: string;
  infinitif: string;
  groupe: string;
  troisiemePluriel: string;
  radical: string;
  formes: ReadonlyArray<string>;
  irregulier: boolean;
  note?: string;
};

const PERSONNES_SUBJ = ["que je", "que tu", "qu'il", "que nous", "que vous", "qu'ils"] as const;

const VERBES_SUBJ: ReadonlyArray<VerbeSubj> = [
  {
    id: "v1",
    infinitif: "chanter",
    groupe: "1er groupe",
    troisiemePluriel: "chantent",
    radical: "chant",
    formes: ["chante", "chantes", "chante", "chantions", "chantiez", "chantent"],
    irregulier: false,
  },
  {
    id: "v2",
    infinitif: "travailler",
    groupe: "1er groupe en -iller",
    troisiemePluriel: "travaillent",
    radical: "travaill",
    formes: ["travaille", "travailles", "travaille", "travaillions", "travailliez", "travaillent"],
    irregulier: false,
    note: "Le i de la terminaison se cache derrière le son du radical. À l'écrit il est obligatoire.",
  },
  {
    id: "v3",
    infinitif: "étudier",
    groupe: "1er groupe en -ier",
    troisiemePluriel: "étudient",
    radical: "étudi",
    formes: ["étudie", "étudies", "étudie", "étudiions", "étudiiez", "étudient"],
    irregulier: false,
    note: "Deux i de suite à nous et vous : celui du radical et celui de la terminaison. C'est correct, et c'est laid. Ose l'écrire.",
  },
  {
    id: "v4",
    infinitif: "payer",
    groupe: "1er groupe en -yer",
    troisiemePluriel: "paient",
    radical: "pai",
    formes: ["paie", "paies", "paie", "payions", "payiez", "paient"],
    irregulier: false,
    note: "Le y revient à nous et vous, suivi du i de la terminaison : « que nous payions ».",
  },
  {
    id: "v5",
    infinitif: "gagner",
    groupe: "1er groupe en -gner",
    troisiemePluriel: "gagnent",
    radical: "gagn",
    formes: ["gagne", "gagnes", "gagne", "gagnions", "gagniez", "gagnent"],
    irregulier: false,
    note: "À l'oral, « nous gagnons » et « nous gagnions » se distinguent à peine.",
  },
  {
    id: "v6",
    infinitif: "finir",
    groupe: "2e groupe",
    troisiemePluriel: "finissent",
    radical: "finiss",
    formes: ["finisse", "finisses", "finisse", "finissions", "finissiez", "finissent"],
    irregulier: false,
  },
  {
    id: "v7",
    infinitif: "partir",
    groupe: "3e groupe",
    troisiemePluriel: "partent",
    radical: "part",
    formes: ["parte", "partes", "parte", "partions", "partiez", "partent"],
    irregulier: false,
  },
  {
    id: "v8",
    infinitif: "prendre",
    groupe: "3e groupe",
    troisiemePluriel: "prennent",
    radical: "prenn",
    formes: ["prenne", "prennes", "prenne", "prenions", "preniez", "prennent"],
    irregulier: false,
    note: "Attention : le radical change à nous et vous — « que nous prenions », avec un seul n.",
  },
  {
    id: "v9",
    infinitif: "écrire",
    groupe: "3e groupe",
    troisiemePluriel: "écrivent",
    radical: "écriv",
    formes: ["écrive", "écrives", "écrive", "écrivions", "écriviez", "écrivent"],
    irregulier: false,
    note: "La méthode a fonctionné sans qu'on ait besoin de savoir à quel groupe le verbe appartient.",
  },
  {
    id: "v10",
    infinitif: "être",
    groupe: "irrégulier",
    troisiemePluriel: "sont",
    radical: "—",
    formes: ["sois", "sois", "soit", "soyons", "soyez", "soient"],
    irregulier: true,
    note: "Aucune méthode ne le donne. Il faut l'apprendre.",
  },
  {
    id: "v11",
    infinitif: "avoir",
    groupe: "irrégulier",
    troisiemePluriel: "ont",
    radical: "—",
    formes: ["aie", "aies", "ait", "ayons", "ayez", "aient"],
    irregulier: true,
    note: "« Qu'il ait », avec un t qu'on n'entend pas. « Bien qu'il ait compris » est une des orthographes les plus ratées du français.",
  },
  {
    id: "v12",
    infinitif: "aller",
    groupe: "irrégulier",
    troisiemePluriel: "vont",
    radical: "—",
    formes: ["aille", "ailles", "aille", "allions", "alliez", "aillent"],
    irregulier: true,
    note: "Irrégulier au singulier, régulier au pluriel : « que nous allions ».",
  },
  {
    id: "v13",
    infinitif: "faire",
    groupe: "irrégulier",
    troisiemePluriel: "font",
    radical: "—",
    formes: ["fasse", "fasses", "fasse", "fassions", "fassiez", "fassent"],
    irregulier: true,
    note: "C'est le verbe du test de l'oreille : « il faut que je fasse » sonne juste, et il te dira quoi faire des verbes du premier groupe.",
  },
  {
    id: "v14",
    infinitif: "pouvoir",
    groupe: "irrégulier",
    troisiemePluriel: "peuvent",
    radical: "—",
    formes: ["puisse", "puisses", "puisse", "puissions", "puissiez", "puissent"],
    irregulier: true,
  },
  {
    id: "v15",
    infinitif: "savoir",
    groupe: "irrégulier",
    troisiemePluriel: "savent",
    radical: "—",
    formes: ["sache", "saches", "sache", "sachions", "sachiez", "sachent"],
    irregulier: true,
  },
  {
    id: "v16",
    infinitif: "vouloir",
    groupe: "irrégulier",
    troisiemePluriel: "veulent",
    radical: "—",
    formes: ["veuille", "veuilles", "veuille", "voulions", "vouliez", "veuillent"],
    irregulier: true,
    note: "Deux radicaux : veuill- au singulier, voul- à nous et vous.",
  },
];

const VERBE_SUBJ_VIDE: VerbeSubj = {
  id: "",
  infinitif: "—",
  groupe: "—",
  troisiemePluriel: "",
  radical: "—",
  formes: ["", "", "", "", "", ""],
  irregulier: false,
};

export function FormerSubjonctif() {
  const [atelier, setAtelier] = useState<"reguliers" | "irreguliers">("reguliers");
  const [i, setI] = useState(0);
  const [geste, setGeste] = useState(1);
  const [pluriel, setPluriel] = useState("");
  const [cases, setCases] = useState<ReadonlyArray<string>>(["", "", "", "", "", ""]);
  const [verifie, setVerifie] = useState(false);

  const liste = VERBES_SUBJ.filter((v) =>
    atelier === "irreguliers" ? v.irregulier : !v.irregulier,
  );
  const v = liste[i % Math.max(1, liste.length)] ?? VERBE_SUBJ_VIDE;

  const plurielJuste = pluriel.trim().toLowerCase() === v.troisiemePluriel.toLowerCase();
  const justes = cases.filter(
    (c, k) => c.trim().toLowerCase() === (v.formes[k] ?? "").toLowerCase(),
  ).length;

  function suivant() {
    setI((n) => (n + 1) % Math.max(1, liste.length));
    setGeste(atelier === "irreguliers" ? 3 : 1);
    setPluriel("");
    setCases(["", "", "", "", "", ""]);
    setVerifie(false);
  }

  return (
    <div className="space-y-3">
      <div>
        <Choice<"reguliers" | "irreguliers">
          label="Atelier"
          value={atelier}
          options={[
            { value: "reguliers", label: "les trois gestes" },
            { value: "irreguliers", label: "les sept irréguliers" },
          ]}
          onChange={(x) => {
            setAtelier(x);
            setI(0);
            setGeste(x === "irreguliers" ? 3 : 1);
            setPluriel("");
            setCases(["", "", "", "", "", ""]);
            setVerifie(false);
          }}
        />
      </div>

      <div className="rounded-lg border border-border bg-background p-3">
        <p className="text-center text-lg font-semibold" style={{ color: PALETTE.purple }}>
          {v.infinitif}
        </p>
        <p className="text-center text-[11px] text-muted-foreground">{v.groupe}</p>

        {atelier === "reguliers" ? (
          <>
            <div
              className="mt-3 rounded-md px-2.5 py-2"
              style={{ backgroundColor: geste === 1 ? "rgba(37,99,235,0.10)" : "transparent" }}
            >
              <p className="text-[11px] font-semibold" style={{ color: PALETTE.blue }}>
                GESTE 1 — la 3e personne du pluriel du présent de l'indicatif
              </p>
              <div className="mt-1 flex flex-wrap items-center gap-2">
                <span className="text-sm text-muted-foreground">ils</span>
                <input
                  value={pluriel}
                  onChange={(e) => setPluriel(e.target.value)}
                  disabled={geste > 1}
                  className="rounded-md border border-border bg-background px-2.5 py-1 text-sm text-foreground"
                />
                {geste === 1 ? (
                  <button
                    type="button"
                    onClick={() => {
                      if (plurielJuste) setGeste(2);
                    }}
                    className="rounded-lg bg-primary px-3 py-1 text-xs font-semibold text-primary-foreground"
                  >
                    Vérifier
                  </button>
                ) : null}
              </div>
              {geste === 1 && pluriel.length > 2 && !plurielJuste ? (
                <p className="mt-1 text-[11px]" style={{ color: PALETTE.red }}>
                  Ce n'est pas la forme attendue. Conjugue « {v.infinitif} » au présent de
                  l'indicatif, troisième personne du pluriel.
                </p>
              ) : null}
            </div>

            {geste >= 2 ? (
              <div
                className="mt-2 rounded-md px-2.5 py-2"
                style={{ backgroundColor: geste === 2 ? "rgba(21,128,61,0.10)" : "transparent" }}
              >
                <p className="text-[11px] font-semibold" style={{ color: PALETTE.green }}>
                  GESTE 2 — je retire -ent
                </p>
                <p className="mt-1 text-sm text-foreground">
                  ils <span className="font-semibold">{v.radical}</span>
                  <span style={{ textDecoration: "line-through", color: PALETTE.red }}>ent</span> →
                  radical{" "}
                  <span className="font-semibold" style={{ color: PALETTE.green }}>
                    {v.radical}-
                  </span>
                </p>
                {geste === 2 ? (
                  <button
                    type="button"
                    onClick={() => setGeste(3)}
                    className="mt-1.5 rounded-lg bg-primary px-3 py-1 text-xs font-semibold text-primary-foreground"
                  >
                    Passer aux terminaisons
                  </button>
                ) : null}
              </div>
            ) : null}
          </>
        ) : (
          <p
            className="mt-3 rounded-md px-2.5 py-2 text-xs"
            style={{ backgroundColor: "rgba(185,28,28,0.10)", color: "#7f1d1d" }}
          >
            Aucune méthode ne donne ce verbe. Les trois gestes ne fonctionnent pas : il faut
            l'apprendre par cœur. Écris les six formes de mémoire.
          </p>
        )}

        {geste >= 3 ? (
          <div className="mt-3">
            <p className="text-[11px] font-semibold" style={{ color: PALETTE.orange }}>
              {atelier === "reguliers"
                ? "GESTE 3 — j'ajoute -e, -es, -e, -ions, -iez, -ent"
                : "Les six formes"}
            </p>
            <div className="mt-1.5 grid gap-1.5 sm:grid-cols-2">
              {PERSONNES_SUBJ.map((p, k) => {
                const attendue = v.formes[k] ?? "";
                const ok = cases[k]?.trim().toLowerCase() === attendue.toLowerCase();
                return (
                  <div key={p} className="flex items-center gap-2">
                    <span className="w-20 text-[11px] text-muted-foreground">{p}</span>
                    <input
                      value={cases[k] ?? ""}
                      onChange={(e) =>
                        setCases((c) => c.map((x, j) => (j === k ? e.target.value : x)))
                      }
                      className="min-w-0 flex-1 rounded-md border px-2 py-1 text-sm text-foreground"
                      style={{
                        borderColor: verifie
                          ? ok
                            ? PALETTE.green
                            : PALETTE.red
                          : "rgba(100,116,139,0.3)",
                        backgroundColor: verifie && ok ? "rgba(21,128,61,0.08)" : "transparent",
                      }}
                    />
                  </div>
                );
              })}
            </div>

            <div className="mt-2 flex flex-wrap gap-2">
              <button
                type="button"
                onClick={() => setVerifie(true)}
                className="rounded-lg bg-primary px-3 py-1.5 text-xs font-semibold text-primary-foreground"
              >
                Vérifier les six formes
              </button>
              <button
                type="button"
                onClick={suivant}
                className="rounded-lg border border-border px-3 py-1.5 text-xs font-semibold text-foreground"
              >
                Verbe suivant ({(i % Math.max(1, liste.length)) + 1} / {liste.length})
              </button>
            </div>

            {verifie ? (
              <div className="mt-2 space-y-1.5">
                <Verdict tone={justes === 6 ? "ok" : justes >= 4 ? "warn" : "bad"}>
                  <span className="font-semibold">{justes} / 6 formes exactes. </span>
                  {PERSONNES_SUBJ.map((p, k) => `${p} ${v.formes[k] ?? ""}`).join(", ")}.
                </Verdict>
                {v.note !== undefined ? (
                  <p
                    className="rounded-md px-2 py-1.5 text-[11px]"
                    style={{ backgroundColor: "rgba(202,138,4,0.12)", color: "#78350f" }}
                  >
                    {v.note}
                  </p>
                ) : null}
              </div>
            ) : null}
          </div>
        ) : null}
      </div>

      <Citation auteur="la méthode vaut pour tous les verbes">
        Prendre la troisième personne du pluriel, retirer -ent, ajouter les terminaisons. Elle
        fonctionne sans qu'on ait besoin de savoir à quel groupe le verbe appartient. Sept verbes
        seulement lui échappent, et ceux-là s'apprennent.
      </Citation>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* 5. Subjonctif ou indicatif au premier groupe                        */
/* ------------------------------------------------------------------ */

type CoupleSubj = {
  id: string;
  verbe: string;
  personne: "nous" | "vous";
  indicatif: { phrase: string; forme: string };
  subjonctif: { phrase: string; forme: string; declencheur: string };
  famille: string;
  testFaire: string;
};

const COUPLES_SUBJ: ReadonlyArray<CoupleSubj> = [
  {
    id: "cs1",
    verbe: "étudier",
    personne: "nous",
    indicatif: { phrase: "Nous … cette leçon depuis deux heures.", forme: "étudions" },
    subjonctif: {
      phrase: "Il faut que nous … cette leçon avant demain.",
      forme: "étudiions",
      declencheur: "il faut que",
    },
    famille: "verbes en -ier : deux i à nous et vous",
    testFaire: "Il faut que nous FASSIONS — le subjonctif s'entend.",
  },
  {
    id: "cs2",
    verbe: "travailler",
    personne: "vous",
    indicatif: { phrase: "Vous … beaucoup, et cela se voit.", forme: "travaillez" },
    subjonctif: {
      phrase: "Bien que vous … beaucoup, le résultat ne suit pas.",
      forme: "travailliez",
      declencheur: "bien que",
    },
    famille: "verbes en -iller : le i se cache derrière le son",
    testFaire: "Bien que vous FASSIEZ — le subjonctif s'entend.",
  },
  {
    id: "cs3",
    verbe: "gagner",
    personne: "nous",
    indicatif: { phrase: "Nous … notre vie honnêtement.", forme: "gagnons" },
    subjonctif: {
      phrase: "Pour que nous … notre vie, il faut un marché.",
      forme: "gagnions",
      declencheur: "pour que",
    },
    famille: "verbes en -gner : à l'oral, la différence s'entend à peine",
    testFaire: "Pour que nous FASSIONS — subjonctif.",
  },
  {
    id: "cs4",
    verbe: "payer",
    personne: "nous",
    indicatif: { phrase: "Nous … déjà des taxes pour ce service.", forme: "payons" },
    subjonctif: {
      phrase: "Il est anormal que nous … deux fois.",
      forme: "payions",
      declencheur: "il est anormal que",
    },
    famille: "verbes en -yer : le y revient devant le i",
    testFaire: "Il est anormal que nous FASSIONS — subjonctif.",
  },
  {
    id: "cs5",
    verbe: "ramasser",
    personne: "nous",
    indicatif: { phrase: "Nous … les ordures tous les samedis.", forme: "ramassons" },
    subjonctif: {
      phrase: "La mairie souhaite que nous … les ordures nous-mêmes.",
      forme: "ramassions",
      declencheur: "souhaiter que",
    },
    famille: "1er groupe ordinaire",
    testFaire: "La mairie souhaite que nous FASSIONS — subjonctif.",
  },
  {
    id: "cs6",
    verbe: "crier",
    personne: "vous",
    indicatif: { phrase: "Vous … trop fort pour être entendus.", forme: "criez" },
    subjonctif: {
      phrase: "J'aimerais que vous … moins fort.",
      forme: "criiez",
      declencheur: "aimer que",
    },
    famille: "verbes en -ier : deux i",
    testFaire: "J'aimerais que vous FASSIEZ — subjonctif.",
  },
  {
    id: "cs7",
    verbe: "oublier",
    personne: "nous",
    indicatif: { phrase: "Nous … toujours quelque chose au marché.", forme: "oublions" },
    subjonctif: {
      phrase: "De peur que nous … la liste, écris-la.",
      forme: "oubliions",
      declencheur: "de peur que",
    },
    famille: "verbes en -ier : deux i",
    testFaire: "De peur que nous FASSIONS — subjonctif.",
  },
  {
    id: "cs8",
    verbe: "surveiller",
    personne: "vous",
    indicatif: { phrase: "Vous … le composteur chaque semaine.", forme: "surveillez" },
    subjonctif: {
      phrase: "Il vaut mieux que vous … le composteur.",
      forme: "surveilliez",
      declencheur: "il vaut mieux que",
    },
    famille: "verbes en -eiller",
    testFaire: "Il vaut mieux que vous FASSIEZ — subjonctif.",
  },
  {
    id: "cs9",
    verbe: "essayer",
    personne: "nous",
    indicatif: { phrase: "Nous … depuis six mois, sans résultat.", forme: "essayons" },
    subjonctif: {
      phrase: "Avant que nous … autre chose, écoutons-le.",
      forme: "essayions",
      declencheur: "avant que",
    },
    famille: "verbes en -yer",
    testFaire: "Avant que nous FASSIONS — subjonctif.",
  },
  {
    id: "cs10",
    verbe: "expliquer",
    personne: "vous",
    indicatif: { phrase: "Vous … toujours très clairement.", forme: "expliquez" },
    subjonctif: {
      phrase: "Je ne crois pas que vous … assez clairement.",
      forme: "expliquiez",
      declencheur: "ne pas croire que",
    },
    famille: "1er groupe ordinaire",
    testFaire: "Je ne crois pas que vous FASSIEZ — subjonctif.",
  },
  {
    id: "cs11",
    verbe: "planter",
    personne: "nous",
    indicatif: { phrase: "Nous … quarante manguiers chaque année.", forme: "plantons" },
    subjonctif: {
      phrase: "À condition que nous … et que nous arrosions.",
      forme: "plantions",
      declencheur: "à condition que",
    },
    famille: "1er groupe ordinaire",
    testFaire: "À condition que nous FASSIONS — subjonctif.",
  },
];

const COUPLE_SUBJ_VIDE: CoupleSubj = {
  id: "",
  verbe: "—",
  personne: "nous",
  indicatif: { phrase: "—", forme: "" },
  subjonctif: { phrase: "—", forme: "", declencheur: "—" },
  famille: "—",
  testFaire: "—",
};

export function SubjonctifOuIndicatif1g() {
  const [i, setI] = useState(0);
  const [a, setA] = useState("");
  const [b, setB] = useState("");
  const [verifie, setVerifie] = useState(false);
  const [testVu, setTestVu] = useState(false);

  const c = COUPLES_SUBJ[i] ?? COUPLE_SUBJ_VIDE;
  const aOk = a.trim().toLowerCase() === c.indicatif.forme.toLowerCase();
  const bOk = b.trim().toLowerCase() === c.subjonctif.forme.toLowerCase();

  return (
    <div className="space-y-3">
      <p className="text-sm text-muted-foreground">
        Le même verbe, la même personne, deux phrases. Une seule porte le i — et c'est la seule
        marque visible du subjonctif au premier groupe.
      </p>

      <div className="rounded-lg border border-border bg-background p-3">
        <p className="text-center text-sm font-semibold" style={{ color: PALETTE.purple }}>
          {c.verbe} — {c.personne}
        </p>
        <p className="text-center text-[11px] text-muted-foreground">{c.famille}</p>

        <div className="mt-3 space-y-2">
          <div className="rounded-md border border-border/60 p-2.5">
            <p className="text-sm text-foreground">{c.indicatif.phrase}</p>
            <p className="mt-0.5 text-[11px] text-muted-foreground">
              Aucun déclencheur : phrase ordinaire.
            </p>
            <input
              value={a}
              onChange={(e) => setA(e.target.value)}
              placeholder="la forme"
              className="mt-1.5 w-full rounded-md border px-2.5 py-1.5 text-sm text-foreground"
              style={{
                borderColor: verifie
                  ? aOk
                    ? PALETTE.green
                    : PALETTE.red
                  : "rgba(100,116,139,0.3)",
              }}
            />
          </div>

          <div className="rounded-md border border-border/60 p-2.5">
            <p className="text-sm text-foreground">{c.subjonctif.phrase}</p>
            <p className="mt-0.5 text-[11px]" style={{ color: PALETTE.orange }}>
              Déclencheur : « {c.subjonctif.declencheur} »
            </p>
            <input
              value={b}
              onChange={(e) => setB(e.target.value)}
              placeholder="la forme"
              className="mt-1.5 w-full rounded-md border px-2.5 py-1.5 text-sm text-foreground"
              style={{
                borderColor: verifie
                  ? bOk
                    ? PALETTE.green
                    : PALETTE.red
                  : "rgba(100,116,139,0.3)",
              }}
            />
          </div>
        </div>

        <div className="mt-2 flex flex-wrap gap-2">
          <button
            type="button"
            onClick={() => setVerifie(true)}
            className="rounded-lg bg-primary px-3 py-1.5 text-xs font-semibold text-primary-foreground"
          >
            Vérifier
          </button>
          <button
            type="button"
            onClick={() => setTestVu((t) => !t)}
            className="rounded-lg border border-border px-3 py-1.5 text-xs font-semibold text-foreground"
          >
            Le test du « faire »
          </button>
        </div>

        {testVu ? (
          <p
            className="mt-2 rounded-md px-2 py-1.5 text-xs"
            style={{ backgroundColor: "rgba(202,138,4,0.12)", color: "#78350f" }}
          >
            {c.testFaire} Si le subjonctif s'entend avec « faire », il en faut un au premier groupe
            aussi — même quand on ne l'entend pas.
          </p>
        ) : null}

        {verifie ? (
          <div className="mt-2 space-y-2">
            <Verdict tone={aOk && bOk ? "ok" : "bad"}>
              <span className="font-semibold">
                Indicatif : {c.indicatif.forme}. Subjonctif : {c.subjonctif.forme}.{" "}
              </span>
              {c.indicatif.forme === c.subjonctif.forme
                ? "Les deux formes sont identiques : seul le contexte permet de nommer le mode."
                : `La différence tient à un i — et elle ne s'entend presque pas à l'oral.`}
            </Verdict>
            <button
              type="button"
              onClick={() => {
                setI((n) => (n + 1) % COUPLES_SUBJ.length);
                setA("");
                setB("");
                setVerifie(false);
                setTestVu(false);
              }}
              className="rounded-lg bg-primary px-3 py-1.5 text-xs font-semibold text-primary-foreground"
            >
              Couple suivant ({i + 1} / {COUPLES_SUBJ.length})
            </button>
          </div>
        ) : null}
      </div>

      <Citation auteur="au premier groupe, la forme ne dit rien">
        Quatre formes sur six sont identiques aux deux modes. Si l'examen te demande le mode de «
        que tu chantes », c'est le déclencheur qui te donne la réponse, et rien d'autre.
      </Citation>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* 6. Les sept déclencheurs                                            */
/* ------------------------------------------------------------------ */

type Declencheur = {
  id: string;
  avant: string;
  apres: string;
  mot: string;
  categorie: string;
  mode: "indicatif" | "subjonctif";
  forme: string;
  infinitif: string;
  note: string;
  faux?: boolean;
};

const DECLENCHEURS: ReadonlyArray<Declencheur> = [
  {
    id: "d1",
    avant: "Je veux qu'il",
    apres: " demain.",
    mot: "je veux que",
    categorie: "verbe de volonté",
    mode: "subjonctif",
    forme: "vienne",
    infinitif: "venir",
    note: "Volonté : le fait est souhaité, pas réalisé.",
  },
  {
    id: "d2",
    avant: "Je crains qu'il ne",
    apres: " trop tard.",
    mot: "je crains que",
    categorie: "verbe de sentiment",
    mode: "subjonctif",
    forme: "soit",
    infinitif: "être",
    note: "Sentiment : subjonctif. Et le « ne » est explétif, il ne nie rien.",
  },
  {
    id: "d3",
    avant: "J'espère qu'il",
    apres: " demain.",
    mot: "j'espère que",
    categorie: "l'EXCEPTION",
    mode: "indicatif",
    forme: "viendra",
    infinitif: "venir",
    note: "Malgré son sens de sentiment, « espérer » commande l'INDICATIF. C'est l'exception à connaître, et elle tombe souvent.",
    faux: true,
  },
  {
    id: "d4",
    avant: "Je pense qu'il",
    apres: " raison.",
    mot: "je pense que",
    categorie: "verbe d'opinion, affirmatif",
    mode: "indicatif",
    forme: "a",
    infinitif: "avoir",
    note: "Affirmatif : le fait est présenté comme réel.",
    faux: true,
  },
  {
    id: "d5",
    avant: "Je ne pense pas qu'il",
    apres: " raison.",
    mot: "je ne pense pas que",
    categorie: "verbe d'opinion, négatif",
    mode: "subjonctif",
    forme: "ait",
    infinitif: "avoir",
    note: "En niant, on retire au fait son caractère certain. Et note le t de « ait », qu'on n'entend pas.",
  },
  {
    id: "d6",
    avant: "Il faut que tu",
    apres: " maintenant.",
    mot: "il faut que",
    categorie: "tournure impersonnelle",
    mode: "subjonctif",
    forme: "partes",
    infinitif: "partir",
    note: "La construction la plus fréquente du français, et celle où la faute se voit le plus.",
  },
  {
    id: "d7",
    avant: "Il est certain que nous",
    apres: " en retard.",
    mot: "il est certain que",
    categorie: "tournure impersonnelle qui AFFIRME",
    mode: "indicatif",
    forme: "arrivons",
    infinitif: "arriver",
    note: "Toutes les tournures impersonnelles ne commandent pas le subjonctif : celles qui affirment gardent l'indicatif.",
    faux: true,
  },
  {
    id: "d8",
    avant: "Il est possible que nous",
    apres: " en retard.",
    mot: "il est possible que",
    categorie: "tournure impersonnelle de l'éventualité",
    mode: "subjonctif",
    forme: "arrivions",
    infinitif: "arriver",
    note: "Le couple à retenir avec la phrase précédente : deux tournures voisines, deux modes opposés, et c'est le sens qui décide.",
  },
  {
    id: "d9",
    avant: "Pour que tu ne m'",
    apres: " pas, je pars tôt.",
    mot: "pour que",
    categorie: "conjonction de but",
    mode: "subjonctif",
    forme: "attendes",
    infinitif: "attendre",
    note: "Le but est toujours au subjonctif, sans exception.",
  },
  {
    id: "d10",
    avant: "Parce qu'il",
    apres: ", nous sommes restés.",
    mot: "parce que",
    categorie: "conjonction de cause",
    mode: "indicatif",
    forme: "pleuvait",
    infinitif: "pleuvoir",
    note: "La cause est un fait établi : indicatif, toujours. Beaucoup y mettent le subjonctif par contagion de « bien que ».",
    faux: true,
  },
  {
    id: "d11",
    avant: "Bien qu'il",
    apres: " compris, il recommence.",
    mot: "bien que",
    categorie: "conjonction d'opposition",
    mode: "subjonctif",
    forme: "ait",
    infinitif: "avoir",
    note: "« Bien qu'il a compris » est une faute, et elle s'entend partout.",
  },
  {
    id: "d12",
    avant: "Même s'il",
    apres: " compris, il recommence.",
    mot: "même si",
    categorie: "conjonction d'opposition avec « si »",
    mode: "indicatif",
    forme: "a",
    infinitif: "avoir",
    note: "Même sens que « bien que », mode opposé — parce que la locution contient « si ».",
    faux: true,
  },
  {
    id: "d13",
    avant: "Avant que tu ne",
    apres: ", préviens-moi.",
    mot: "avant que",
    categorie: "conjonction de temps, antériorité",
    mode: "subjonctif",
    forme: "partes",
    infinitif: "partir",
    note: "Antériorité : le fait n'a pas eu lieu. Subjonctif.",
  },
  {
    id: "d14",
    avant: "Après qu'il",
    apres: ", la salle s'est tue.",
    mot: "après que",
    categorie: "conjonction de temps, postériorité",
    mode: "indicatif",
    forme: "a parlé",
    infinitif: "parler",
    note: "Le fait est accompli. « Après qu'il ait parlé » est si courant à l'oral que beaucoup la croient correcte : le BEPC la sanctionne encore.",
    faux: true,
  },
  {
    id: "d15",
    avant: "Qu'il",
    apres: " en retard ne m'étonne pas.",
    mot: "complétive en tête",
    categorie: "complétive sujet",
    mode: "subjonctif",
    forme: "soit",
    infinitif: "être",
    note: "Une complétive placée en tête se met toujours au subjonctif, quel que soit le verbe de la principale.",
  },
  {
    id: "d16",
    avant: "C'est le plus beau chant que je",
    apres: ".",
    mot: "le plus beau… que",
    categorie: "superlatif",
    mode: "subjonctif",
    forme: "connaisse",
    infinitif: "connaître",
    note: "Le septième déclencheur, peu connu, et il distingue une bonne copie. Les mots qui l'annoncent : le seul, le premier, le dernier, le meilleur, le pire.",
  },
  {
    id: "d17",
    avant: "Il n'y a personne qui",
    apres: " l'aider.",
    mot: "personne qui",
    categorie: "terme restrictif",
    mode: "subjonctif",
    forme: "puisse",
    infinitif: "pouvoir",
    note: "Rien, personne, aucun : les termes restrictifs appellent le subjonctif dans la relative qui suit.",
  },
  {
    id: "d18",
    avant: "Si tu",
    apres: " demain, nous irons au marché.",
    mot: "si de condition",
    categorie: "le « si » de condition",
    mode: "indicatif",
    forme: "viens",
    infinitif: "venir",
    note: "Ni subjonctif, ni conditionnel : indicatif. Les si n'aiment pas les ré.",
    faux: true,
  },
  {
    id: "d19",
    avant: "Il est évident qu'il",
    apres: " raison.",
    mot: "il est évident que",
    categorie: "tournure impersonnelle qui AFFIRME",
    mode: "indicatif",
    forme: "a",
    infinitif: "avoir",
    note: "Comme « il est certain que » et « il paraît que » : ces tournures affirment, donc indicatif.",
    faux: true,
  },
  {
    id: "d20",
    avant: "Il vaut mieux que nous",
    apres: " ici.",
    mot: "il vaut mieux que",
    categorie: "tournure impersonnelle du conseil",
    mode: "subjonctif",
    forme: "restions",
    infinitif: "rester",
    note: "Le conseil n'est pas un fait : subjonctif.",
  },
  {
    id: "d21",
    avant: "Je doute que tu",
    apres: " du premier coup.",
    mot: "je doute que",
    categorie: "verbe d'incertitude",
    mode: "subjonctif",
    forme: "réussisses",
    infinitif: "réussir",
    note: "Le doute appelle le subjonctif, comme les verbes de sentiment.",
  },
  {
    id: "d22",
    avant: "Il exige que tout le monde",
    apres: " à six heures.",
    mot: "il exige que",
    categorie: "verbe de volonté",
    mode: "subjonctif",
    forme: "soit",
    infinitif: "être",
    note: "Volonté.",
  },
  {
    id: "d23",
    avant: "Je constate que le camion ne",
    apres: " plus.",
    mot: "je constate que",
    categorie: "verbe de perception",
    mode: "indicatif",
    forme: "passe",
    infinitif: "passer",
    note: "Perception : on perçoit ce qui est. Indicatif.",
    faux: true,
  },
  {
    id: "d24",
    avant: "Jusqu'à ce que le car",
    apres: " plein, nous attendrons.",
    mot: "jusqu'à ce que",
    categorie: "conjonction de temps, limite",
    mode: "subjonctif",
    forme: "soit",
    infinitif: "être",
    note: "Limite non encore atteinte : subjonctif.",
  },
  {
    id: "d25",
    avant: "C'est la seule chose qui",
    apres: " la peine.",
    mot: "la seule… qui",
    categorie: "terme restrictif",
    mode: "subjonctif",
    forme: "vaille",
    infinitif: "valoir",
    note: "Superlatif et restriction : subjonctif.",
  },
  {
    id: "d26",
    avant: "Je sais que tu",
    apres: " raison.",
    mot: "je sais que",
    categorie: "verbe de connaissance",
    mode: "indicatif",
    forme: "as",
    infinitif: "avoir",
    note: "Connaissance à la forme affirmative : indicatif.",
    faux: true,
  },
  {
    id: "d27",
    avant: "Je suis heureux qu'elle",
    apres: " son examen.",
    mot: "je suis heureux que",
    categorie: "sentiment",
    mode: "subjonctif",
    forme: "réussisse",
    infinitif: "réussir",
    note: "Sentiment : subjonctif.",
  },
  {
    id: "d28",
    avant: "Que tu",
    apres: " me ferait plaisir.",
    mot: "complétive en tête",
    categorie: "complétive sujet",
    mode: "subjonctif",
    forme: "réussisses",
    infinitif: "réussir",
    note: "Complétive sujet : subjonctif, toujours.",
  },
];

const DECLENCHEUR_VIDE: Declencheur = {
  id: "",
  avant: "—",
  apres: "",
  mot: "—",
  categorie: "—",
  mode: "indicatif",
  forme: "",
  infinitif: "—",
  note: "—",
};

export function DeclencheursSubjonctif() {
  const [i, setI] = useState(0);
  const [mode, setMode] = useState<"indicatif" | "subjonctif" | null>(null);
  const [saisie, setSaisie] = useState("");
  const [valide, setValide] = useState(false);

  const d = DECLENCHEURS[i] ?? DECLENCHEUR_VIDE;
  const modeJuste = mode === d.mode;
  const formeJuste = saisie.trim().toLowerCase() === d.forme.toLowerCase();

  return (
    <div className="space-y-3">
      <p className="text-sm text-muted-foreground">
        Le mot qui commande s'affiche d'abord. Les sept déclencheurs du cours sont là, et les six
        faux déclencheurs aussi.
      </p>

      <div className="rounded-lg border border-border bg-background p-3">
        <div
          className="rounded-md px-2.5 py-2"
          style={{
            backgroundColor: d.faux === true ? "rgba(185,28,28,0.08)" : "rgba(124,58,237,0.08)",
          }}
        >
          <p
            className="text-sm font-semibold"
            style={{ color: d.faux === true ? PALETTE.red : PALETTE.purple }}
          >
            « {d.mot} »
          </p>
          <p className="mt-0.5 text-[11px] text-muted-foreground">
            {d.categorie}
            {d.faux === true ? " — attention, ce n'en est pas un" : ""}
          </p>
        </div>

        <p className="mt-3 text-base text-foreground">
          {d.avant}{" "}
          <span
            className="rounded px-2 py-0.5 font-semibold"
            style={{
              backgroundColor: valide ? "rgba(21,128,61,0.12)" : "rgba(100,116,139,0.14)",
              color: valide ? PALETTE.green : PALETTE.slate,
            }}
          >
            {valide ? d.forme : "……"}
          </span>
          {d.apres}
        </p>
        <p className="mt-1 text-[11px] text-muted-foreground">
          verbe : <span className="font-semibold">{d.infinitif}</span>
        </p>

        <div className="mt-3">
          <Choice<"indicatif" | "subjonctif" | "">
            label="Le mode"
            value={mode ?? ""}
            options={[
              { value: "indicatif", label: "indicatif" },
              { value: "subjonctif", label: "subjonctif" },
            ]}
            onChange={(v) => {
              if (v !== "") setMode(v);
            }}
          />
        </div>

        {mode !== null ? (
          <div className="mt-3 space-y-2">
            <Verdict tone={modeJuste ? "ok" : "bad"}>
              <span className="font-semibold">
                {modeJuste ? "Bon mode. " : `Il fallait le ${d.mode}. `}
              </span>
              {d.note}
            </Verdict>

            <div className="flex flex-wrap items-center gap-2">
              <input
                value={saisie}
                onChange={(e) => setSaisie(e.target.value)}
                placeholder="écris la forme"
                className="rounded-md border border-border bg-background px-2.5 py-1.5 text-sm text-foreground"
              />
              <button
                type="button"
                onClick={() => setValide(true)}
                className="rounded-lg bg-primary px-3 py-1.5 text-xs font-semibold text-primary-foreground"
              >
                Vérifier
              </button>
            </div>

            {valide ? (
              <div className="space-y-2">
                <Verdict tone={formeJuste ? "ok" : "warn"}>
                  <span className="font-semibold">
                    {formeJuste ? "Forme exacte. " : `La forme attendue : « ${d.forme} ». `}
                  </span>
                  {d.avant} {d.forme}
                  {d.apres}
                </Verdict>
                <button
                  type="button"
                  onClick={() => {
                    setI((n) => (n + 1) % DECLENCHEURS.length);
                    setMode(null);
                    setSaisie("");
                    setValide(false);
                  }}
                  className="rounded-lg bg-primary px-3 py-1.5 text-xs font-semibold text-primary-foreground"
                >
                  Déclencheur suivant ({i + 1} / {DECLENCHEURS.length})
                </button>
              </div>
            ) : null}
          </div>
        ) : null}
      </div>

      <Citation auteur="quatre couples montés l'un contre l'autre">
        « Il est certain que » contre « il est possible que ». « J'espère que » contre « je doute
        que ». « Bien que » contre « même si ». « Avant que » contre « après que ». Dans chaque
        couple, un seul mot change — et le mode avec lui.
      </Citation>
    </div>
  );
}
