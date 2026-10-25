import { useState } from "react";
import { Ctrl, PALETTE, Stat, Verdict } from "./controls";
import { Citation, Parcours, Qcm, type Etape, type Question } from "./philo-noyau";
import { Surligner, type Releve } from "./fr3-noyau";

/** Français 3ème — chapitres 5 et 6 : vocabulaire des sentiments, lecture. */

/* ------------------------------------------------------------------ */
/* 1. Relever un champ lexical                                         */
/* ------------------------------------------------------------------ */

const CHAMPS: ReadonlyArray<Releve> = [
  {
    id: "cl1",
    consigne: "Relève QUATRE mots ou expressions du champ lexical du marché.",
    combien: 4,
    bilan:
      "Un champ lexical ne contient pas que des noms. Prendre un verbe — « marchandaient » — prouve que tu l'as compris.",
    jetons: [
      { mot: "Il" },
      { mot: "était" },
      { mot: "à" },
      { mot: "peine" },
      { mot: "six" },
      { mot: "heures" },
      { mot: "et" },
      { mot: "déjà" },
      { mot: "les" },
      { mot: "étals", bon: true, pourquoi: "les tables où l'on expose la marchandise." },
      { mot: "débordaient." },
      { mot: "Les" },
      { mot: "marchandes", bon: true, pourquoi: "celles qui vendent." },
      { mot: "criaient" },
      { mot: "leurs" },
      { mot: "prix,", bon: true, pourquoi: "le prix appartient pleinement au champ du commerce." },
      { mot: "les" },
      { mot: "acheteurs", bon: true, pourquoi: "l'autre côté de l'échange." },
      { mot: "marchandaient,", bon: true, pourquoi: "un VERBE du champ lexical : discuter le prix." },
      { mot: "et" },
      { mot: "des" },
      { mot: "porteurs" },
      { mot: "se" },
      { mot: "faufilaient" },
      { mot: "entre" },
      { mot: "les" },
      { mot: "allées." },
    ],
  },
  {
    id: "cl2",
    consigne:
      "Relève TROIS éléments qui expriment l'angoisse de Mariam. Attention : le mot « angoisse » n'est pas dans le texte.",
    combien: 3,
    bilan:
      "Le champ lexical dit le thème SANS le nommer. Ici tout passe par le corps — la poitrine, les mains — et par la disproportion entre la somme et la liste.",
    jetons: [
      { mot: "Mariam" },
      { mot: "avançait" },
      { mot: "lentement." },
      { mot: "Sa" },
      {
        mot: "poitrine se serrait",
        bon: true,
        pourquoi: "le corps dit l'émotion que le texte ne nomme pas.",
      },
      { mot: "." },
      { mot: "Elle" },
      {
        mot: "n'avait que deux mille francs",
        bon: true,
        pourquoi: "la restriction « ne… que » souligne le manque.",
      },
      { mot: "dans" },
      { mot: "son" },
      { mot: "pagne," },
      { mot: "et" },
      { mot: "la" },
      {
        mot: "liste de sa mère était longue",
        bon: true,
        pourquoi: "la disproportion entre la somme et la tâche.",
      },
      { mot: "." },
      { mot: "Ses" },
      { mot: "mains" },
      { mot: "devenaient" },
      { mot: "moites." },
    ],
  },
  {
    id: "cl3",
    consigne:
      "Le tri. Relève les QUATRE mots qui appartiennent à la FAMILLE du mot « terre » — pas au champ lexical.",
    combien: 4,
    bilan:
      "La famille de mots se voit avec les yeux, par la racine. Le champ lexical se voit avec la tête, par le sens. Ne les confonds jamais : ce sont deux questions différentes du BEPC.",
    jetons: [
      { mot: "Le" },
      { mot: "paysan" },
      { mot: "retourne" },
      { mot: "le" },
      { mot: "sol" },
      { mot: "de" },
      { mot: "son" },
      { mot: "terrain", bon: true, pourquoi: "racine « terr »." },
      { mot: "." },
      { mot: "Il" },
      { mot: "cultive," },
      { mot: "sème," },
      { mot: "arrose," },
      { mot: "puis" },
      { mot: "récolte." },
      { mot: "Derrière" },
      { mot: "sa" },
      { mot: "maison," },
      { mot: "une" },
      { mot: "terrasse", bon: true, pourquoi: "racine « terr »." },
      { mot: "domine" },
      { mot: "la" },
      { mot: "vallée," },
      { mot: "et" },
      { mot: "un" },
      { mot: "souterrain", bon: true, pourquoi: "racine « terr », avec le préfixe « sous »." },
      { mot: "mène" },
      { mot: "au" },
      { mot: "champ." },
      { mot: "L'avion" },
      { mot: "va" },
      { mot: "atterrir", bon: true, pourquoi: "racine « terr » : se poser à terre." },
      { mot: "." },
    ],
  },
];

export function ChampLexical() {
  return (
    <Surligner
      consigne="Trois relevés, et le dernier est un piège : on te demande une famille de mots au milieu d'un texte plein de champ lexical."
      releves={CHAMPS}
      conclusion={
        <>
          Trois gestes, dans cet ordre. <strong>Un</strong> : retiens le thème demandé.{" "}
          <strong>Deux</strong> : relis le texte avec ce seul thème en tête, et n'oublie ni les
          verbes ni les adjectifs. <strong>Trois</strong> : recopie le nombre exact demandé, entre
          guillemets, et pas un de plus — si l'on t'en demande quatre et que tu en donnes huit, le
          correcteur ne note que les quatre premiers.
        </>
      }
    />
  );
}

/* ------------------------------------------------------------------ */
/* 2. L'échelle des sentiments                                         */
/* ------------------------------------------------------------------ */

type Echelle = {
  id: string;
  famille: string;
  mots: ReadonlyArray<string>;
  situation: string;
  juste: number;
  remarque: string;
};

const ECHELLES: ReadonlyArray<Echelle> = [
  {
    id: "e1",
    famille: "la colère",
    mots: ["agacé", "irrité", "énervé", "en colère", "furieux", "fou de rage"],
    situation: "Ton petit frère a cassé ta règle en jouant.",
    juste: 0,
    remarque:
      "Une règle cassée par accident ne justifie ni la fureur ni la rage. Employer « en colère » ici n'est pas une faute, mais c'est gaspiller : garde les mots forts pour les situations fortes, sinon il ne te restera rien à écrire quand il le faudra.",
  },
  {
    id: "e2",
    famille: "la colère",
    mots: ["agacé", "irrité", "énervé", "en colère", "furieux", "fou de rage"],
    situation:
      "Tu découvres que quelqu'un a lu ton journal intime et l'a montré à toute la classe.",
    juste: 5,
    remarque:
      "Ici le mot le plus fort est juste. C'est parce que tu as réservé « fou de rage » que tu peux l'employer maintenant sans exagérer.",
  },
  {
    id: "e3",
    famille: "la peur",
    mots: ["inquiet", "anxieux", "effrayé", "terrorisé", "paniqué"],
    situation: "Tu attends les résultats d'un examen que tu crois avoir réussi.",
    juste: 0,
    remarque:
      "Et attention : la peur de ce qui n'est pas encore arrivé a son mot propre, l'APPRÉHENSION. On ne dit pas « j'avais peur de l'examen », on dit « j'appréhendais l'examen ».",
  },
  {
    id: "e4",
    famille: "la tristesse",
    mots: ["contrarié", "peiné", "triste", "affligé", "désespéré"],
    situation: "Tu revois la case de ton enfance, vide depuis le départ de ta famille.",
    juste: 2,
    remarque:
      "Ici le français a mieux : la tristesse douce qu'on éprouve en pensant à ce qui est passé et ne reviendra pas s'appelle la NOSTALGIE. Ce mot-là se remarque dans une copie.",
  },
  {
    id: "e5",
    famille: "la joie",
    mots: ["content", "satisfait", "joyeux", "heureux", "ravi", "comblé"],
    situation: "Tu apprends que ton oncle hospitalisé est sorti sans séquelles.",
    juste: 1,
    remarque:
      "Le mot exact n'est dans aucune de ces six cases : la joie qui suit une peur écartée s'appelle le SOULAGEMENT. Trois sentiments ont ainsi un mot précis que les copies ignorent : la nostalgie, le soulagement, l'appréhension.",
  },
];

const ECHELLE_DEFAUT: Echelle = ECHELLES[0] ?? {
  id: "",
  famille: "—",
  mots: ["—"],
  situation: "—",
  juste: 0,
  remarque: "—",
};

export function NuancerSentiment() {
  const [ie, setIe] = useState(0);
  const [pos, setPos] = useState(0);
  const [montre, setMontre] = useState(false);

  const e = ECHELLES[ie] ?? ECHELLE_DEFAUT;
  const mot = e.mots[Math.min(pos, e.mots.length - 1)] ?? "—";
  const ecart = Math.abs(pos - e.juste);

  return (
    <div className="space-y-3">
      <p className="text-sm text-muted-foreground">
        Une situation t'est décrite. Place le curseur sur l'échelle d'intensité, et le mot exact
        s'affiche. La simulation te dit ensuite si tu as visé juste.
      </p>

      <div className="rounded-lg border border-border bg-background p-3">
        <p className="text-sm text-foreground">{e.situation}</p>
        <p className="mt-1 text-[11px] italic text-muted-foreground">Famille : {e.famille}</p>

        <div className="mt-3">
          <Ctrl
            label="Intensité du sentiment"
            value={pos}
            min={0}
            max={e.mots.length - 1}
            step={1}
            onChange={(v) => {
              setPos(v);
              setMontre(false);
            }}
            display={mot}
            color={PALETTE.purple}
          />
        </div>

        <div className="mt-2 flex flex-wrap gap-1">
          {e.mots.map((m, i) => (
            <span
              key={m}
              className="rounded px-1.5 py-0.5 text-[11px]"
              style={{
                backgroundColor: i === pos ? "rgba(124,58,237,0.18)" : "transparent",
                color: i === pos ? PALETTE.purple : PALETTE.slate,
                fontWeight: i === pos ? 600 : 400,
              }}
            >
              {m}
            </span>
          ))}
        </div>

        {!montre ? (
          <button
            type="button"
            onClick={() => setMontre(true)}
            className="mt-3 rounded-lg bg-primary px-3 py-1.5 text-xs font-semibold text-primary-foreground"
          >
            Vérifier mon choix
          </button>
        ) : (
          <div className="mt-3 space-y-2">
            <Verdict tone={ecart === 0 ? "ok" : ecart === 1 ? "warn" : "bad"}>
              <span className="font-semibold">
                Le mot attendu : {e.mots[e.juste] ?? "—"}.{" "}
              </span>
              {e.remarque}
            </Verdict>
            <button
              type="button"
              onClick={() => {
                setIe((i) => (i + 1) % ECHELLES.length);
                setPos(0);
                setMontre(false);
              }}
              className="rounded-lg bg-primary px-3 py-1.5 text-xs font-semibold text-primary-foreground"
            >
              Situation suivante ({ie + 1} / {ECHELLES.length})
            </button>
          </div>
        )}
      </div>

      <Citation auteur="ce que ces cinq situations apprennent">
        Il ne suffit pas de connaître les mots : il faut les doser. Un correcteur de BEPC reconnaît
        en trois lignes une copie qui dispose de son vocabulaire — et il reconnaît aussi celle qui
        met « fou de rage » partout.
      </Citation>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* 3. Montrer au lieu de dire                                          */
/* ------------------------------------------------------------------ */

const MONTRER: ReadonlyArray<Question> = [
  {
    id: "m1",
    enonce: "Remplace « Il avait peur » sans employer aucun mot de sentiment.",
    options: [
      {
        texte: "Ses mains tremblaient. Sa gorge était sèche et il n'arrivait plus à avaler.",
        bonne: true,
        retour:
          "Montré PAR LE CORPS. Le lecteur nomme le sentiment lui-même, et c'est pour cela qu'il y croit.",
      },
      {
        texte: "Il avait très peur, une peur terrible.",
        bonne: false,
        retour: "Tu as nommé le sentiment, et même deux fois. L'intensité ajoutée ne remplace pas le procédé.",
      },
      {
        texte: "Il était effrayé par ce qui l'attendait.",
        bonne: false,
        retour: "« Effrayé » est encore un mot de sentiment : tu as changé de mot, pas de méthode.",
      },
    ],
  },
  {
    id: "m2",
    enonce: "Remplace « Elle était en colère ».",
    options: [
      {
        texte:
          "Elle posa l'assiette si fort que la table en trembla, puis sortit sans refermer la porte.",
        bonne: true,
        retour:
          "Montré PAR L'ACTION. Deux gestes, et la colère est là sans qu'on l'écrive. La porte non refermée vaut un adjectif.",
      },
      {
        texte: "Elle était rouge de colère.",
        bonne: false,
        retour: "Le corps y est — « rouge » — mais tu as gardé le mot. Enlève-le et il reste « elle était rouge ».",
      },
    ],
  },
  {
    id: "m3",
    enonce: "Remplace « Il était triste » par une comparaison.",
    options: [
      {
        texte: "Il se sentait vide, comme une case abandonnée après le départ des siens.",
        bonne: true,
        retour:
          "Montré PAR LA COMPARAISON. Et l'image est ancrée : une case abandonnée dit plus, ici, qu'une image empruntée ailleurs.",
      },
      {
        texte: "Il était triste comme jamais.",
        bonne: false,
        retour: "« Comme jamais » n'est pas une comparaison, c'est un renforcement. Et le mot est resté.",
      },
    ],
  },
  {
    id: "m4",
    enonce:
      "Laquelle de ces deux phrases vaut le plus en rédaction ?",
    options: [
      {
        texte:
          "Ma grand-mère ne dit rien. Elle posa ses deux mains sur mes joues, longtemps, et je sentis qu'elles tremblaient un peu.",
        bonne: true,
        retour:
          "Elle ne contient aucun mot de sentiment, et pourtant tout y est. Le détail — « longtemps », « un peu » — fait le travail.",
      },
      {
        texte: "Ma grand-mère était très contente de me revoir.",
        bonne: false,
        retour:
          "Plus courte de quelques mots, et dix fois plus faible. « Très contente » n'apprend rien au lecteur.",
      },
    ],
  },
  {
    id: "m5",
    enonce: "Faut-il montrer TOUS les sentiments d'un récit ?",
    options: [
      {
        texte:
          "Non : on montre les sentiments importants, ceux sur lesquels le récit repose, et on nomme les secondaires pour ne pas alourdir.",
        bonne: true,
        retour:
          "Si tu montres tout, ton texte devient une devinette. Si tu nommes tout, il devient plat. Alterne, comme tu alternes l'imparfait et le passé simple.",
      },
      {
        texte: "Oui, nommer un sentiment est toujours une faute",
        bonne: false,
        retour:
          "Aucun écrivain ne s'impose cela. Le lecteur a besoin de repères rapides sur les sentiments secondaires.",
      },
    ],
  },
  {
    id: "m6",
    enonce:
      "À la question 4 du BEPC — « quels sentiments le narrateur exprime-t-il ? » — que doit contenir ta réponse ?",
    options: [
      {
        texte:
          "Le nom du sentiment ET la citation du signe qui te l'a fait trouver : « du découragement : il laissa retomber ses bras ».",
        bonne: true,
        retour:
          "Les deux ensemble valent les deux points. Nommer sans citer n'en vaut qu'un, citer sans nommer non plus.",
      },
      {
        texte: "Le nom du sentiment, c'est ce qu'on demande",
        bonne: false,
        retour:
          "La moitié des points part avec la citation manquante. Dans un texte littéraire, le mot ne sera presque jamais écrit : tu dois le déduire des signes.",
      },
      {
        texte: "Une longue citation, qui parle d'elle-même",
        bonne: false,
        retour:
          "Une citation ne parle jamais d'elle-même : c'est toi qui dois dire ce qu'elle montre.",
      },
    ],
  },
];

export function MontrerSentiment() {
  return (
    <Qcm
      consigne="Six exercices sur le procédé qui transforme une rédaction : montrer le sentiment au lieu de le nommer. Par le corps, par l'action, par la comparaison."
      questions={MONTRER}
      conclusion={
        <>
          Retiens le principe et sa limite. Le <strong>principe</strong> : les bons écrivains ne
          disent presque jamais qu'un personnage a peur, ils montrent la peur et le lecteur la
          nomme lui-même. La <strong>limite</strong> : montre les sentiments importants, nomme les
          secondaires. Et en lecture, ce même procédé te sert à la question 4 — le texte ne
          contiendra pas le mot, tu devras le déduire des signes du corps, des actions et des
          images.
        </>
      }
    />
  );
}

/* ------------------------------------------------------------------ */
/* 4. Les quatre temps de la lecture méthodique                        */
/* ------------------------------------------------------------------ */

const LECTURE: ReadonlyArray<Etape> = [
  {
    titre: "Situer",
    question:
      "Texte : « La route était longue. Il marchait depuis l'aube… Il pensait à sa mère… Il pensait au cousin… Il pensait au travail… Puis il cessa de penser, car la poussière entrait dans sa bouche. » Première question : qui parle ?",
    options: [
      {
        texte:
          "Un narrateur extérieur — il dit « il » — mais qui connaît les pensées du personnage.",
        bonne: true,
        retour:
          "Bien vu. Ce n'est pas un « je », et pourtant on entre dans sa tête : c'est une focalisation interne avec un narrateur à la troisième personne.",
      },
      {
        texte: "Le personnage lui-même, à la première personne",
        bonne: false,
        retour: "Le texte dit « il », jamais « je ». Relis la première phrase.",
      },
      {
        texte: "On ne peut pas savoir",
        bonne: false,
        retour:
          "Si : la personne employée se voit tout de suite, et c'est la première chose à regarder.",
      },
    ],
  },
  {
    titre: "Repérer",
    question: "Que repères-tu de plus frappant dans ce texte ?",
    options: [
      {
        texte:
          "La répétition de « il pensait », trois fois en tête de phrase, et l'imparfait partout sauf un passé simple à la fin.",
        bonne: true,
        retour:
          "Deux relevés justes. Cherche toujours ce qui REVIENT : ce qui revient est voulu. La répétition en tête de phrase porte d'ailleurs un nom, l'anaphore.",
      },
      {
        texte: "Il y a des mots difficiles",
        bonne: false,
        retour: "Ce n'est pas un relevé : les mots de ce texte sont tous courants.",
      },
      {
        texte: "Le texte est triste",
        bonne: false,
        retour:
          "C'est une impression, pas un relevé. Un relevé porte sur ce qui est écrit : des mots, des temps, des constructions.",
      },
    ],
  },
  {
    titre: "Interpréter",
    question:
      "Tu as repéré la triple répétition de « il pensait ». Maintenant : POURQUOI l'auteur la fait-il ?",
    options: [
      {
        texte:
          "Elle imite le ressassement de la marche, et les trois pensées suivent l'ordre du temps : la mère au passé, le cousin au présent, le travail à venir. Toute sa vie tient dans ces trois lignes.",
        bonne: true,
        retour:
          "Voilà une interprétation. Tu dis ce que le procédé PRODUIT, et tu remarques que les trois pensées sont ordonnées — ce que personne ne voit du premier coup.",
      },
      {
        texte: "Parce que le personnage pense beaucoup",
        bonne: false,
        retour:
          "Tu redis le texte avec d'autres mots. Une interprétation dit l'EFFET du procédé, pas son contenu.",
      },
      {
        texte: "C'est une figure de style appelée anaphore",
        bonne: false,
        retour:
          "Le nom est juste, et il ne suffit pas. Nommer n'est pas interpréter : il reste à dire ce que l'anaphore produit ici.",
      },
    ],
  },
  {
    titre: "Conclure",
    question: "En deux phrases : que fait ce texte, et comment ?",
    options: [
      {
        texte:
          "En quelques lignes, il donne au personnage un passé, un présent et un avenir, puis il les fait taire par la fatigue. Le lecteur comprend que ce départ coûte, avant même que la ville soit atteinte.",
        bonne: true,
        retour:
          "Une conclusion dit ce que le texte fait et comment. Celle-ci relie les deux relevés — la répétition et le passé simple final — en un seul mouvement.",
      },
      {
        texte: "Ce texte raconte un homme qui marche vers la ville.",
        bonne: false,
        retour:
          "C'est un résumé, pas une conclusion. La conclusion répond à : quel est l'intérêt de ce texte ?",
      },
      {
        texte: "Ce texte est bien écrit et émouvant.",
        bonne: false,
        retour: "Une appréciation n'est pas une conclusion d'analyse.",
      },
    ],
  },
];

export function LectureMethodique() {
  return (
    <Parcours
      consigne="Les quatre temps, un par un, sur un texte de départ vers la ville. Chaque étape doit être franchie avant la suivante."
      etapes={LECTURE}
      fin={
        <>
          Situer, repérer, interpréter, conclure. Le troisième temps est celui que les copies
          sautent, et c'est celui qui rapporte : pour chaque chose repérée, demande-toi{" "}
          <strong>pourquoi</strong>. Dire « il y a beaucoup de comparaisons » n'est pas une analyse ;
          dire « les comparaisons rapprochent la ville d'un animal, ce qui la rend menaçante » en
          est une. Et une lecture méthodique complète tient en huit lignes.
        </>
      }
    />
  );
}

/* ------------------------------------------------------------------ */
/* 5. La fiche de lecture                                              */
/* ------------------------------------------------------------------ */

const FICHE: ReadonlyArray<Question> = [
  {
    id: "fl1",
    enonce: "Case « auteur » de la fiche de « Ville cruelle ».",
    options: [
      {
        texte: "Eza Boto, premier pseudonyme d'Alexandre Biyidi Awala, plus connu sous le nom de Mongo Beti.",
        bonne: true,
        retour:
          "Les deux pseudonymes valent d'être cités, et la raison aussi : écrire contre l'administration coloniale en 1954 n'était pas sans risque pour sa famille restée au pays.",
      },
      { texte: "Mongo Beti", bonne: false, retour: "C'est le même homme, mais le roman est signé Eza Boto. Dis les deux." },
      { texte: "Banda", bonne: false, retour: "Banda est le héros du roman, pas son auteur." },
    ],
  },
  {
    id: "fl2",
    enonce: "Case « cadre » : où et quand se passe le roman ?",
    options: [
      {
        texte:
          "Le village de Bamila et la ville de Tanga, en Afrique coloniale, dans les années 1950.",
        bonne: true,
        retour:
          "Et n'oublie pas le trait essentiel : Tanga est DOUBLE — Tanga-Nord, européenne et commerçante, Tanga-Sud, africaine et laborieuse.",
      },
      { texte: "Au Cameroun, aujourd'hui", bonne: false, retour: "Le roman paraît en 1954 et décrit la période coloniale." },
    ],
  },
  {
    id: "fl3",
    enonce: "Case « résumé ». Laquelle de ces propositions convient ?",
    options: [
      {
        texte:
          "Banda, jeune paysan de Bamila, descend à Tanga vendre sa récolte de cacao pour payer une dot et soigner sa mère. Les inspecteurs saisissent et brûlent sa récolte.",
        bonne: true,
        retour:
          "Un résumé donne la situation et le problème, et s'arrête avant le dénouement. Quinze lignes suffisent.",
      },
      {
        texte:
          "Banda part à Tanga, perd sa récolte, puis à la fin il récupère de l'argent et rentre au village.",
        bonne: false,
        retour:
          "Tu racontes la fin. Un résumé de fiche de lecture n'a pas à dévoiler le dénouement dans le détail.",
      },
      {
        texte: "C'est l'histoire d'un jeune homme qui va en ville.",
        bonne: false,
        retour: "Trop vague : on ne sait ni ce qu'il veut, ni ce qui l'en empêche.",
      },
    ],
  },
  {
    id: "fl4",
    enonce: "Case « thèmes ». Lequel est un vrai thème, et non un morceau d'histoire ?",
    options: [
      {
        texte: "L'exploitation économique : Banda cultive, un autre achète à vil prix, un troisième revend.",
        bonne: true,
        retour:
          "Un thème est une idée générale, et il s'illustre par le texte. Les trois autres thèmes du roman : l'opposition village-ville, l'arbitraire administratif, la solidarité.",
      },
      {
        texte: "Les inspecteurs brûlent la récolte de Banda.",
        bonne: false,
        retour: "C'est un événement du récit, pas un thème. Le thème serait l'arbitraire administratif.",
      },
      { texte: "Banda est orphelin de père.", bonne: false, retour: "C'est un détail du personnage." },
    ],
  },
  {
    id: "fl5",
    enonce: "Case « personnage » : présente Banda selon la méthode en quatre points.",
    options: [
      {
        texte:
          "Qui il est : un jeune paysan de Bamila. Ce qu'il veut : vendre sa récolte pour la dot et les soins de sa mère. Ce qui l'en empêche : un système entier. Comment il change : sa naïveté est détruite, sa dignité non.",
        bonne: true,
        retour:
          "Les quatre points, et le dernier est le plus important. Remarque aussi la formule « un système entier » : les opposants ne sont pas des méchants mais des mécanismes.",
      },
      {
        texte: "Banda est le héros du roman. Il est courageux et honnête.",
        bonne: false,
        retour:
          "Deux adjectifs ne font pas un personnage. On ne sait ni ce qu'il veut, ni ce qui lui résiste, ni ce qu'il devient.",
      },
    ],
  },
  {
    id: "fl6",
    enonce: "Case « avis personnel ». Lequel vaut quelque chose ?",
    options: [
      {
        texte:
          "J'ai été frappé par la scène où la récolte est brûlée, parce qu'elle montre que le travail d'une année peut être anéanti par une signature.",
        bonne: true,
        retour:
          "Un avis nomme une scène précise et dit pourquoi elle a marqué. C'est la case que les élèves bâclent, et c'est la plus facile à réussir.",
      },
      { texte: "J'ai beaucoup aimé ce livre, il est très intéressant.", bonne: false, retour: "Cela ne vaut rien : aucune scène, aucune raison." },
      {
        texte: "Ce livre est un chef-d'œuvre de la littérature africaine.",
        bonne: false,
        retour:
          "Un jugement emprunté n'est pas un avis personnel. Le correcteur veut savoir ce que TOI tu as éprouvé, et pourquoi.",
      },
    ],
  },
];

export function FicheLecture() {
  return (
    <Qcm
      consigne="Six cases de la fiche de lecture de « Ville cruelle », avec à chaque fois les erreurs classiques : le résumé qui raconte la fin, le personnage réduit à deux adjectifs, le thème confondu avec un événement, et l'avis qui se contente de « j'ai aimé »."
      questions={FICHE}
      conclusion={
        <>
          La fiche complète, à refaire pour les deux autres œuvres de l'année — <em>Andromaque</em>{" "}
          au deuxième trimestre, <em>Petites gouttes de chant pour créer l'homme</em> au troisième :
          titre, auteur, date, genre, cadre, personnages en une ligne chacun, résumé en quinze
          lignes, trois thèmes, avis personnel justifié. Garde-les dans un même cahier : au
          troisième trimestre, tu les reliras toutes les trois avant l'examen.
        </>
      }
    />
  );
}

/* ------------------------------------------------------------------ */
/* 6. L'épreuve en conditions                                          */
/* ------------------------------------------------------------------ */

const EPREUVE: ReadonlyArray<Question> = [
  {
    id: "ep1",
    enonce:
      "PARTIE I, question 1 (2 pts). Texte : des paysans attendent depuis quatre heures du matin ; l'inspecteur sort à neuf heures, examine le cacao de Banda en trois gestes et dit « deuxième choix » sans le regarder. — Propose un titre et justifie.",
    options: [
      {
        texte:
          "« L'attente » — parce que le texte est construit sur une attente, le mot « attendait » revenant trois fois, et qu'elle s'achève sur une décision subie.",
        bonne: true,
        retour:
          "1 point pour le titre, 1 point pour la justification. Un titre sans justification ne vaut que la moitié : c'est l'erreur la plus fréquente à cette question.",
      },
      {
        texte: "« Le cacao »",
        bonne: false,
        retour:
          "Le titre est recevable mais tu n'as rien justifié : tu perds un point sur deux. Et il est moins juste que « L'attente », car le texte parle moins du cacao que de ce qu'on fait subir aux paysans.",
      },
      {
        texte: "« Un texte sur l'injustice coloniale »",
        bonne: false,
        retour: "Un titre n'est pas un commentaire. Il doit tenir en deux ou trois mots.",
      },
    ],
  },
  {
    id: "ep2",
    enonce: "PARTIE I, question 3 (2 pts). Comment l'inspecteur examine-t-il la récolte ?",
    options: [
      {
        texte:
          "Très rapidement et sans attention : « il en ouvrit un, prit une poignée de fèves, la laissa couler entre ses doigts » — trois gestes en une phrase, et « sans le regarder ».",
        bonne: true,
        retour:
          "1 point pour l'idée, 1 point pour la citation. Toute réponse de compréhension doit s'appuyer sur le texte.",
      },
      {
        texte: "Il l'examine mal et c'est injuste.",
        bonne: false,
        retour:
          "L'idée y est à moitié, mais rien n'est cité : la moitié des points part. Et « c'est injuste » est un jugement, pas une réponse à la question posée.",
      },
    ],
  },
  {
    id: "ep3",
    enonce:
      "PARTIE I, question 4 (2 pts). Quels sentiments Banda éprouve-t-il au quatrième paragraphe, quand il se lève pour parler ?",
    options: [
      {
        texte:
          "D'abord l'espoir et la volonté de se défendre — « Banda se leva », « il voulait expliquer » — puis l'impuissance : « Il ouvrit la bouche », et la phrase s'arrête là.",
        bonne: true,
        retour:
          "Deux sentiments nommés ET justifiés, 1 point chacun. Remarque la finesse : c'est l'interruption de la phrase qui dit l'impuissance.",
      },
      {
        texte: "Il est triste et déçu.",
        bonne: false,
        retour:
          "Deux mots vagues, aucune citation. Et « triste » manque le mouvement du paragraphe, qui va de l'espoir à l'impuissance.",
      },
    ],
  },
  {
    id: "ep4",
    enonce:
      "PARTIE I, question 5 (2 pts). Que faudrait-il changer pour que les paysans ne subissent plus cette situation ?",
    options: [
      {
        texte:
          "S'organiser en coopérative : seuls, les paysans subissent le prix qu'on leur impose ; groupés, ils peuvent négocier et contester un classement.",
        bonne: true,
        retour:
          "1 point pour la proposition, 1 point pour la justification. Il n'y a pas de bonne réponse unique — mais il y a de mauvaises copies : celles qui répondent en une ligne.",
      },
      {
        texte: "Il faudrait que le gouvernement fasse quelque chose.",
        bonne: false,
        retour: "Une ligne, aucune précision, aucune explication : un point sur deux au mieux.",
      },
      {
        texte: "Rien, c'était l'époque coloniale.",
        bonne: false,
        retour:
          "La question demande ton opinion sur ce qu'il faudrait changer. Refuser de répondre, c'est perdre les deux points.",
      },
    ],
  },
  {
    id: "ep5",
    enonce:
      "PARTIE II, question 1 (2 pts). Donne le sens du mot « récolte » tel qu'il s'emploie ici.",
    options: [
      {
        texte:
          "L'ensemble des produits agricoles ramassés à la fin d'une saison de culture : ici, le cacao que Banda a cultivé et séché pendant l'année.",
        bonne: true,
        retour:
          "Genre prochain — « l'ensemble des produits agricoles » — plus différence spécifique — « ramassés à la fin d'une saison ». C'est la construction qui rapporte.",
      },
      {
        texte: "C'est ce qu'on récolte.",
        bonne: false,
        retour:
          "Cercle vicieux : tu définis le mot par lui-même. Le correcteur le voit en une seconde.",
      },
      {
        texte: "Par exemple du cacao, du maïs ou du riz.",
        bonne: false,
        retour: "Définition par l'exemple : tu donnes des cas au lieu du concept. Un demi-point.",
      },
    ],
  },
  {
    id: "ep6",
    enonce:
      "PARTIE II, question 2 (2 pts). Relève QUATRE mots du champ lexical de l'agriculture.",
    options: [
      {
        texte: "« le cacao », « la récolte », « les fèves », « avait séché trois semaines au soleil »",
        bonne: true,
        retour:
          "Quatre, pas plus, et la dernière est une expression verbale : tu montres qu'un champ lexical ne contient pas que des noms. 0,5 point chacun.",
      },
      {
        texte: "« le cacao », « la récolte », « les fèves », « les sacs », « le soleil », « la place », « le hangar », « l'inspecteur »",
        bonne: false,
        retour:
          "On t'en demandait quatre. Le correcteur ne note que les quatre premiers — et « les sacs » passerait, mais tu as pris le risque pour rien.",
      },
      {
        texte: "« le cacao », « la place », « l'inspecteur », « l'uniforme »",
        bonne: false,
        retour:
          "Trois sur quatre sont hors du champ : la place, l'inspecteur et l'uniforme relèvent de l'administration, pas de l'agriculture.",
      },
    ],
  },
  {
    id: "ep7",
    enonce:
      "PARTIE II, question 4 (2 pts). a) Temps et mode de « attendait ». b) Réécris « Il attendait » au passé simple.",
    options: [
      {
        texte: "a) Imparfait de l'indicatif. b) « Il attendit. »",
        bonne: true,
        retour:
          "Et si tu ajoutes ce que la réécriture fait au sens — « il attendait » laisse l'attente ouverte, « il attendit » la referme —, tu gagnes le point de finesse quand la question le permet.",
      },
      {
        texte: "a) Imparfait de l'indicatif. b) « Il attendis. »",
        bonne: false,
        retour:
          "La forme est fausse : attendre est du 3e groupe, série en -i, et la 3e personne du singulier fait « attendit », avec un t.",
      },
      {
        texte: "a) Passé simple. b) « Il attendait. »",
        bonne: false,
        retour: "Tu as inverti les deux temps. « Attendait » a la terminaison -ait : c'est l'imparfait.",
      },
    ],
  },
  {
    id: "ep8",
    enonce:
      "PARTIE II, question 5 (2 pts). « Puis il se rassit sur ses sacs, parce qu'il n'y avait rien d'autre à faire. » Relève les propositions, nomme-les, donne la fonction de la subordonnée.",
    options: [
      {
        texte:
          "Principale : « Puis il se rassit sur ses sacs ». Subordonnée conjonctive circonstancielle de cause : « parce qu'il n'y avait rien d'autre à faire », complément circonstanciel de cause de « se rassit ».",
        bonne: true,
        retour:
          "Deux verbes conjugués — « se rassit » et « avait » — donc deux propositions ; « à faire » est un infinitif et ne compte pas. 0,5 point par élément.",
      },
      {
        texte: "Trois propositions, à cause de « à faire ».",
        bonne: false,
        retour: "« À faire » est un infinitif : il n'a pas de sujet et ne se conjugue pas. Il ne compte pas.",
      },
      {
        texte: "Deux propositions indépendantes coordonnées.",
        bonne: false,
        retour:
          "Ce serait la réponse si le texte disait « car ». Avec « parce que », la seconde proposition devient subordonnée. Même sens, nature opposée.",
      },
    ],
  },
];

export function EtudeDeTexteBepc() {
  const [debut] = useState(() => Date.now());
  const [ecoule, setEcoule] = useState(0);
  return (
    <div className="space-y-3">
      <div className="flex flex-wrap items-center gap-2">
        <Stat label="Épreuve" value="20 points" color={PALETTE.ink} />
        <Stat label="Partie I" value="10 pts" color={PALETTE.blue} />
        <Stat label="Partie II" value="10 pts" color={PALETTE.green} />
        <button
          type="button"
          onClick={() => setEcoule(Math.round((Date.now() - debut) / 60000))}
          className="rounded-lg border border-border px-2.5 py-1 text-[11px] text-muted-foreground hover:bg-secondary/60"
        >
          {ecoule > 0 ? `${ecoule} min écoulées` : "Voir le temps écoulé"}
        </button>
      </div>

      <Qcm
        consigne="Huit questions de l'épreuve, dans l'ordre réel : quatre de compréhension, quatre de langue. Les mauvaises réponses sont celles que les copies donnent vraiment, et chacune t'indique combien de points elle coûte."
        questions={EPREUVE}
        conclusion={
          <>
            Les quatre règles qui font la différence, et aucune ne porte sur le contenu.{" "}
            <strong>Cite le texte</strong> à chaque question de compréhension : une réponse juste
            mais sans citation perd la moitié des points. <strong>Réponds au nombre exact
            demandé</strong> : quatre mots signifie quatre. <strong>Donne la nature ET la
            fonction</strong> quand les deux sont demandées, car l'une sans l'autre ne vaut rien.{" "}
            <strong>Justifie ton opinion personnelle</strong> : la question 5 n'a pas de bonne
            réponse, mais elle a de mauvaises copies, celles qui répondent en une ligne.
          </>
        }
      />
    </div>
  );
}
