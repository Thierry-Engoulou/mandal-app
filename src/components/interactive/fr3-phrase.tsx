import { useState } from "react";
import { PALETTE, Verdict } from "./controls";
import { Citation, JeuTri, Qcm, type ItemTri, type Question } from "./philo-noyau";
import { Surligner, Transformer, type Releve, type Transformation } from "./fr3-noyau";

/** Français 3ème — chapitres 1 et 2 : la phrase. */

/* ------------------------------------------------------------------ */
/* 1. Reconnaître le type d'une phrase                                 */
/* ------------------------------------------------------------------ */

const PHRASES_TYPE: ReadonlyArray<ItemTri> = [
  {
    id: "t1",
    texte: "Le car de Douala arrive à huit heures",
    bonne: "declaratif",
    pourquoi: "Elle informe, simplement. Ponctuation finale : un point.",
  },
  {
    id: "t2",
    texte: "Viens-tu au marché avec moi",
    bonne: "interrogatif",
    pourquoi:
      "Elle pose une question, et par inversion du sujet — la forme soutenue, celle qu'on attend à l'écrit. Ponctuation : un point d'interrogation.",
  },
  {
    id: "t3",
    texte: "Sors d'ici",
    bonne: "injonctif",
    pourquoi:
      "C'est un ordre, et c'est un piège : la phrase porte un point d'exclamation, mais elle reste injonctive. Ne regarde pas le signe, regarde ce que fait la phrase.",
  },
  {
    id: "t4",
    texte: "Comme cette saison des pluies est longue",
    bonne: "exclamatif",
    pourquoi:
      "Elle exprime un sentiment, et elle commence par « comme », l'un des trois mots de l'exclamation avec « que » et « quel ».",
  },
  {
    id: "t5",
    texte: "N'oublie pas d'arroser le jardin",
    bonne: "injonctif",
    pourquoi:
      "Un conseil, verbe à l'impératif, pas de sujet exprimé. Et la ponctuation finale est un simple point : un ordre n'a pas besoin de point d'exclamation.",
  },
  {
    id: "t6",
    texte: "Tu viens au marché",
    bonne: "interrogatif",
    pourquoi:
      "Second piège : à l'écrit sans son point d'interrogation, rien ne la distingue d'une déclarative. C'est l'intonation seule qui interroge, et c'est la forme familière.",
  },
  {
    id: "t7",
    texte: "Mon oncle habite à Bafoussam depuis douze ans",
    bonne: "declaratif",
    pourquoi: "Elle constate un fait. C'est le type le plus fréquent, celui des textes à étudier.",
  },
  {
    id: "t8",
    texte: "Quel désordre dans cette cour",
    bonne: "exclamatif",
    pourquoi: "« Quel » introduit l'exclamation. Elle ne demande rien et n'ordonne rien : elle s'émeut.",
  },
  {
    id: "t9",
    texte: "Est-ce que le marché ferme à dix-huit heures",
    bonne: "interrogatif",
    pourquoi:
      "La forme courante, avec « est-ce que ». Les trois formes posent la même question, mais seule l'inversion est vraiment soutenue.",
  },
  {
    id: "t10",
    texte: "Rangez vos cahiers et sortez en silence",
    bonne: "injonctif",
    pourquoi: "Deux ordres coordonnés, deux impératifs. Le type ne change pas pour autant.",
  },
  {
    id: "t11",
    texte: "Il pleut depuis ce matin",
    bonne: "declaratif",
    pourquoi:
      "Troisième piège : prononcée avec dépit, elle paraît exclamative. Mais le type se juge sur la construction, pas sur le ton qu'on imagine.",
  },
  {
    id: "t12",
    texte: "Que la route est longue",
    bonne: "exclamatif",
    pourquoi:
      "« Que » en tête, suivi d'une phrase complète : c'est l'exclamation. Attention à ne pas confondre avec « Que veux-tu ? », où « que » interroge.",
  },
];

export function TypesDePhrases() {
  return (
    <JeuTri
      consigne="Douze phrases, sans leur ponctuation finale. C'est voulu : tu dois chercher ce que FAIT la phrase au lieu de regarder le signe. La correction te révèle ensuite la ponctuation, et trois d'entre elles mentent."
      categories={[
        { value: "declaratif", label: "Déclaratif", aide: "elle informe" },
        { value: "interrogatif", label: "Interrogatif", aide: "elle demande" },
        { value: "injonctif", label: "Injonctif", aide: "elle ordonne ou conseille" },
        { value: "exclamatif", label: "Exclamatif", aide: "elle exprime un sentiment" },
      ]}
      items={PHRASES_TYPE}
      conclusion={
        <>
          Une phrase a un type, <strong>et un seul</strong>. Elle cumule ensuite plusieurs formes —
          négative, passive, emphatique — mais cela ne change pas son type. Et retiens les trois
          pièges rencontrés : un ordre peut porter un point d'exclamation, une question peut n'avoir
          que l'intonation, et une déclarative peut se dire sur un ton dépité sans devenir
          exclamative.
        </>
      }
    />
  );
}

/* ------------------------------------------------------------------ */
/* 2. Transformer une phrase                                           */
/* ------------------------------------------------------------------ */

const TRANSFOS: ReadonlyArray<Transformation> = [
  {
    id: "f1",
    consigne: "Mets cette phrase à la forme négative.",
    depart: "Awa vient au marché.",
    attendues: ["Awa ne vient pas au marché", "awa ne vient pas au marché."],
    explication:
      "La négation s'écrit avec DEUX mots : « ne » et « pas ». À l'oral on dit « Awa vient pas », à l'écrit c'est une faute.",
    indices: [
      {
        quand: /^(?!.*\bne\b).*\bpas\b/i,
        message:
          "Tu as écrit « pas » mais tu as oublié « ne ». C'est l'erreur la plus fréquente de toutes les copies : la négation se construit avec deux mots.",
      },
    ],
  },
  {
    id: "f2",
    consigne: "Mets cette phrase à la forme négative, en employant « jamais ».",
    depart: "Il arrive à l'heure.",
    attendues: ["Il n'arrive jamais à l'heure", "il n'arrive jamais à l'heure."],
    explication:
      "Le second mot de la négation varie : pas, plus, jamais, rien, personne, aucun, nulle part. Le premier reste « ne », qui s'élide ici en « n' » devant la voyelle.",
    indices: [
      {
        quand: /\bne arrive\b/i,
        message: "« ne » s'élide devant une voyelle : on écrit « n'arrive », avec une apostrophe.",
      },
    ],
  },
  {
    id: "f3",
    consigne: "Mets cette phrase à la forme passive, sans changer le temps.",
    depart: "Les élèves nettoient la cour.",
    attendues: [
      "La cour est nettoyée par les élèves",
      "la cour est nettoyée par les élèves.",
    ],
    explication:
      "Trois gestes : le complément d'objet direct devient sujet, le verbe prend l'auxiliaire être AU MÊME TEMPS, et l'ancien sujet devient complément d'agent avec « par ». « Nettoient » est au présent, donc « est nettoyée ».",
    indices: [
      {
        quand: /a été nettoyée|fut nettoyée|sera nettoyée/i,
        message:
          "Tu as changé le temps. « Nettoient » est au présent, donc l'auxiliaire être doit être au présent : « est nettoyée ». C'est le point que les correcteurs guettent.",
      },
      {
        quand: /est nettoyé\b/i,
        message:
          "Il manque l'accord. Avec l'auxiliaire être, le participe s'accorde avec le sujet : « la cour » est féminin, donc « nettoyée ».",
      },
    ],
  },
  {
    id: "f4",
    consigne: "Mets cette phrase à la forme passive, sans changer le temps.",
    depart: "Le maire inaugurera le nouveau marché.",
    attendues: [
      "Le nouveau marché sera inauguré par le maire",
      "le nouveau marché sera inauguré par le maire.",
    ],
    explication:
      "« Inaugurera » est au futur simple, donc l'auxiliaire être se met au futur : « sera ». Et « le nouveau marché » étant masculin singulier, le participe reste « inauguré », sans e ni s.",
    indices: [
      {
        quand: /est inauguré|a été inauguré/i,
        message:
          "Le temps a changé. Le verbe de départ est au futur — « inaugurera » — donc il faut « sera inauguré ».",
      },
    ],
  },
  {
    id: "f5",
    consigne: "Mets le mot « Awa » en valeur, par la forme emphatique.",
    depart: "Awa vient au marché.",
    attendues: [
      "C'est Awa qui vient au marché",
      "c'est awa qui vient au marché.",
      "C'est Awa qui vient au marché.",
    ],
    explication:
      "On encadre par « c'est… qui » parce qu'Awa est SUJET. Pour un complément, ce serait « c'est… que ».",
    indices: [
      {
        quand: /c'est awa que/i,
        message:
          "« Qui » pour le sujet, « que » pour le complément. Awa fait l'action, donc elle est sujet : « c'est Awa qui vient ».",
      },
    ],
  },
  {
    id: "f6",
    consigne: "Mets « le nouveau marché » en valeur, par la forme emphatique.",
    depart: "Le maire inaugurera le nouveau marché.",
    attendues: [
      "C'est le nouveau marché que le maire inaugurera",
      "c'est le nouveau marché que le maire inaugurera.",
    ],
    explication:
      "Cette fois le mot mis en valeur est complément d'objet direct, donc « c'est… que ». Une faute à cet endroit se voit immédiatement.",
    indices: [
      {
        quand: /que le maire inaugurera le/i,
        message:
          "Tu as gardé le complément à sa place. Dans la forme emphatique, le mot mis en valeur passe en tête, entre « c'est » et « que ».",
      },
      {
        quand: /marché qui le maire/i,
        message: "« Qui » est pour le sujet. Ici le marché est complément : il faut « que ».",
      },
    ],
  },
  {
    id: "f7",
    consigne:
      "Essaie de mettre cette phrase à la forme passive. Si c'est impossible, écris « impossible » et retiens pourquoi.",
    depart: "Je pense à mon frère.",
    attendues: ["impossible", "c'est impossible", "impossible : pas de cod"],
    explication:
      "Seul un verbe qui a un complément d'objet DIRECT peut se mettre au passif. « À mon frère » est un complément d'objet indirect : il n'y a rien à faire passer en position de sujet.",
    aide:
      "Cherche le complément d'objet direct de « penser ». Il n'y en a pas : « à mon frère » est indirect, à cause de la préposition « à ».",
  },
  {
    id: "f8",
    consigne: "Mets cette phrase à la forme négative ET à la forme emphatique sur « mon frère ».",
    depart: "Mon frère a pris le car.",
    attendues: [
      "Ce n'est pas mon frère qui a pris le car",
      "ce n'est pas mon frère qui a pris le car.",
    ],
    explication:
      "Les formes se cumulent : la phrase est maintenant déclarative, négative et emphatique en même temps. Le type, lui, n'a pas bougé.",
    aide:
      "Commence par l'emphase — « c'est mon frère qui a pris le car » — puis nie le présentatif : « ce n'est pas… ».",
  },
];

export function FormesDePhrase() {
  return (
    <Transformer
      consigne="L'atelier de transformation. Une phrase, une consigne, et ta réécriture. La simulation surveille les trois pièges : le « ne » oublié, le temps de l'auxiliaire qui change au passif, et le « qui » mis pour « que »."
      items={TRANSFOS}
      conclusion={
        <>
          Les trois formes se cumulent, et elles ne changent jamais le type de la phrase. Retiens
          les trois règles qui rapportent : la négation s'écrit en <strong>deux mots</strong> ; au
          passif, l'auxiliaire être se met <strong>au même temps</strong> que le verbe actif ; et
          dans l'emphase, <strong>qui</strong> pour le sujet, <strong>que</strong> pour le
          complément. Enfin, un verbe sans complément d'objet direct n'a pas de passif.
        </>
      }
    />
  );
}

/* ------------------------------------------------------------------ */
/* 3. Les deux tests : suppression et déplacement                      */
/* ------------------------------------------------------------------ */

type Groupe = {
  mots: string;
  obligatoire: boolean;
  fonction: string;
  suppression: string;
  deplacement: string;
};

type PhraseTest = { id: string; groupes: ReadonlyArray<Groupe> };

const PHRASES_TEST: ReadonlyArray<PhraseTest> = [
  {
    id: "c1",
    groupes: [
      {
        mots: "Ce matin",
        obligatoire: false,
        fonction: "complément circonstanciel de temps",
        suppression: "Les élèves nettoient la cour avec soin. — la phrase tient.",
        deplacement: "Les élèves nettoient la cour avec soin ce matin. — il bouge.",
      },
      {
        mots: "les élèves",
        obligatoire: true,
        fonction: "sujet",
        suppression: "Ce matin, nettoient la cour avec soin. — plus personne pour agir.",
        deplacement: "Impossible de le déplacer sans casser la phrase.",
      },
      {
        mots: "nettoient",
        obligatoire: true,
        fonction: "verbe, noyau du prédicat",
        suppression: "Ce matin, les élèves la cour avec soin. — il n'y a plus d'action.",
        deplacement: "Le verbe ne se déplace pas librement.",
      },
      {
        mots: "la cour",
        obligatoire: true,
        fonction: "complément d'objet direct",
        suppression: "Ce matin, les élèves nettoient avec soin. — on attend ce qu'ils nettoient.",
        deplacement: "La cour, les élèves nettoient avec soin. — cela ne se dit pas.",
      },
      {
        mots: "avec soin",
        obligatoire: false,
        fonction: "complément circonstanciel de manière",
        suppression: "Ce matin, les élèves nettoient la cour. — la phrase tient.",
        deplacement: "Avec soin, les élèves nettoient la cour ce matin. — il bouge.",
      },
    ],
  },
  {
    id: "c2",
    groupes: [
      {
        mots: "Depuis la rentrée",
        obligatoire: false,
        fonction: "complément circonstanciel de temps",
        suppression: "Mon petit frère apporte son goûter au collège. — tient.",
        deplacement: "Mon petit frère apporte son goûter au collège depuis la rentrée. — bouge.",
      },
      {
        mots: "mon petit frère",
        obligatoire: true,
        fonction: "sujet",
        suppression: "Depuis la rentrée, apporte son goûter au collège. — personne n'agit.",
        deplacement: "Impossible.",
      },
      {
        mots: "apporte",
        obligatoire: true,
        fonction: "verbe, noyau du prédicat",
        suppression: "Il n'y a plus d'action.",
        deplacement: "Impossible.",
      },
      {
        mots: "son goûter",
        obligatoire: true,
        fonction: "complément d'objet direct",
        suppression: "Mon petit frère apporte au collège. — on attend ce qu'il apporte.",
        deplacement: "Impossible.",
      },
      {
        mots: "au collège",
        obligatoire: false,
        fonction: "complément circonstanciel de lieu",
        suppression: "Mon petit frère apporte son goûter. — tient.",
        deplacement: "Au collège, mon petit frère apporte son goûter. — bouge très bien.",
      },
    ],
  },
  {
    id: "c3",
    groupes: [
      {
        mots: "Hier soir",
        obligatoire: false,
        fonction: "complément circonstanciel de temps",
        suppression: "Ma mère a préparé du koki pour la fête. — tient.",
        deplacement: "Ma mère a préparé du koki pour la fête hier soir. — bouge.",
      },
      {
        mots: "ma mère",
        obligatoire: true,
        fonction: "sujet",
        suppression: "Hier soir, a préparé du koki. — personne n'agit.",
        deplacement: "Impossible.",
      },
      {
        mots: "a préparé",
        obligatoire: true,
        fonction: "verbe au passé composé, noyau du prédicat",
        suppression: "Plus d'action.",
        deplacement: "Impossible.",
      },
      {
        mots: "du koki",
        obligatoire: true,
        fonction: "complément d'objet direct",
        suppression: "Hier soir, ma mère a préparé pour la fête. — on attend quoi.",
        deplacement: "Impossible.",
      },
      {
        mots: "pour la fête",
        obligatoire: false,
        fonction: "complément circonstanciel de but",
        suppression: "Hier soir, ma mère a préparé du koki. — tient.",
        deplacement: "Pour la fête, ma mère a préparé du koki hier soir. — bouge.",
      },
    ],
  },
];

const PT_VIDE: PhraseTest = { id: "", groupes: [] };
const GROUPE_VIDE: Groupe = {
  mots: "—",
  obligatoire: false,
  fonction: "—",
  suppression: "—",
  deplacement: "—",
};

export function ConstituantsPhrase() {
  const [rang, setRang] = useState(0);
  const [actif, setActif] = useState(0);
  const [teste, setTeste] = useState<{ s: boolean; d: boolean }>({ s: false, d: false });
  const [verdict, setVerdict] = useState<boolean | null>(null);

  const p = PHRASES_TEST[rang] ?? PT_VIDE;
  const g = p.groupes[actif] ?? GROUPE_VIDE;
  const bon = verdict !== null && verdict === g.obligatoire;

  return (
    <div className="space-y-3">
      <p className="text-sm text-muted-foreground">
        Une phrase découpée en groupes. Clique un groupe, lance les deux tests, puis conclus :
        obligatoire ou facultatif ? La fonction s'affiche ensuite.
      </p>

      <div className="rounded-lg border border-border bg-background p-3">
        <p className="flex flex-wrap gap-1.5">
          {p.groupes.map((x, i) => (
            <button
              key={x.mots}
              type="button"
              onClick={() => {
                setActif(i);
                setTeste({ s: false, d: false });
                setVerdict(null);
              }}
              className={
                i === actif
                  ? "rounded-lg bg-primary px-2 py-1 text-sm font-semibold text-primary-foreground"
                  : "rounded-lg border border-border px-2 py-1 text-sm text-foreground hover:bg-secondary/60"
              }
            >
              {x.mots}
            </button>
          ))}
        </p>
      </div>

      <div className="grid gap-2 sm:grid-cols-2">
        <button
          type="button"
          onClick={() => setTeste((t) => ({ ...t, s: true }))}
          className="rounded-lg border border-border px-3 py-2 text-left text-xs hover:bg-secondary/50"
        >
          <span className="font-semibold text-foreground">Test de suppression</span>
          <br />
          <span className="text-muted-foreground">
            {teste.s ? g.suppression : "j'enlève le groupe, et je regarde"}
          </span>
        </button>
        <button
          type="button"
          onClick={() => setTeste((t) => ({ ...t, d: true }))}
          className="rounded-lg border border-border px-3 py-2 text-left text-xs hover:bg-secondary/50"
        >
          <span className="font-semibold text-foreground">Test de déplacement</span>
          <br />
          <span className="text-muted-foreground">
            {teste.d ? g.deplacement : "je le mets en tête de phrase"}
          </span>
        </button>
      </div>

      {teste.s && teste.d ? (
        <div className="space-y-2">
          <p className="text-xs font-medium text-muted-foreground">
            Alors, ce groupe est-il obligatoire ou facultatif ?
          </p>
          <div className="flex gap-1.5">
            {[true, false].map((v) => {
              const pris = verdict === v;
              const cls = !pris
                ? "border-border bg-background text-muted-foreground hover:bg-secondary/60"
                : bon
                  ? "border-emerald-500/40 bg-emerald-500/15 text-emerald-700"
                  : "border-rose-500/40 bg-rose-500/15 text-rose-700";
              return (
                <button
                  key={v ? "o" : "f"}
                  type="button"
                  onClick={() => setVerdict(v)}
                  className={`rounded-lg border px-3 py-1.5 text-xs font-medium ${cls}`}
                >
                  {v ? "obligatoire" : "facultatif"}
                </button>
              );
            })}
          </div>
          {verdict !== null ? (
            <Verdict tone={bon ? "ok" : "bad"}>
              <span className="font-semibold">
                {g.obligatoire ? "Obligatoire" : "Facultatif"} — fonction : {g.fonction}.{" "}
              </span>
              {g.obligatoire
                ? "Non supprimable, non déplaçable."
                : "Supprimable et déplaçable : c'est la signature du complément circonstanciel, et il ne reste qu'à dire lequel."}
            </Verdict>
          ) : null}
        </div>
      ) : null}

      <div className="flex items-center gap-2">
        <button
          type="button"
          onClick={() => {
            setRang((r) => (r + 1) % PHRASES_TEST.length);
            setActif(0);
            setTeste({ s: false, d: false });
            setVerdict(null);
          }}
          className="rounded-lg border border-border px-3 py-1.5 text-xs font-medium text-muted-foreground hover:bg-secondary/60"
        >
          Phrase suivante
        </button>
        <span className="text-[11px] text-muted-foreground">
          {rang + 1} / {PHRASES_TEST.length}
        </span>
      </div>

      <Citation auteur="pourquoi cela rapporte">
        La question 3 de la deuxième partie du BEPC demande la nature et la fonction de mots
        soulignés. Ces deux tests te donnent la fonction sans que tu aies à réciter quoi que ce
        soit : supprimable et déplaçable, c'est un complément circonstanciel ; non supprimable,
        juste après le verbe et sans préposition, c'est un complément d'objet direct.
      </Citation>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* 4. Compter les propositions                                         */
/* ------------------------------------------------------------------ */

const RELEVES_VERBES: ReadonlyArray<Releve> = [
  {
    id: "v1",
    consigne: "Clique sur tous les verbes CONJUGUÉS. Une proposition par verbe conjugué.",
    combien: 0,
    bilan:
      "Un seul verbe conjugué : une proposition, donc une phrase simple. « Dans la cour » n'a pas de verbe, ce n'est pas une proposition.",
    jetons: [
      { mot: "Mon" },
      { mot: "père" },
      { mot: "répare", bon: true, pourquoi: "verbe conjugué au présent, 3e personne du singulier." },
      { mot: "la" },
      { mot: "moto" },
      { mot: "dans" },
      { mot: "la" },
      { mot: "cour." },
    ],
  },
  {
    id: "v2",
    consigne: "Clique sur tous les verbes conjugués.",
    combien: 0,
    bilan: "Deux verbes conjugués, donc deux propositions. La phrase n'est pas simple.",
    jetons: [
      { mot: "Ma" },
      { mot: "mère" },
      { mot: "prépare", bon: true, pourquoi: "conjugué au présent." },
      { mot: "le" },
      { mot: "repas" },
      { mot: "pendant" },
      { mot: "que" },
      { mot: "mon" },
      { mot: "père" },
      { mot: "répare", bon: true, pourquoi: "conjugué au présent, dans la subordonnée." },
      { mot: "la" },
      { mot: "moto." },
    ],
  },
  {
    id: "v3",
    consigne: "Attention au piège. Clique uniquement sur les verbes CONJUGUÉS.",
    combien: 0,
    bilan:
      "Une seule proposition, donc une phrase simple — malgré ses deux verbes et sa longueur. C'est le piège le plus courant de l'exercice.",
    jetons: [
      { mot: "Mon" },
      { mot: "père" },
      { mot: "a", bon: true, pourquoi: "auxiliaire conjugué : « a décidé » est au passé composé." },
      { mot: "décidé" },
      { mot: "de" },
      {
        mot: "réparer",
        pourquoi: "C'est un INFINITIF. Il ne compte pas : il n'a pas de sujet et ne se conjugue pas.",
      },
      { mot: "la" },
      { mot: "moto" },
      { mot: "lui-même." },
    ],
  },
  {
    id: "v4",
    consigne: "Encore un piège, d'un autre genre.",
    combien: 0,
    bilan:
      "Deux propositions. « Ayant terminé » est un participe, il ne compte pas — pas plus qu'un infinitif.",
    jetons: [
      {
        mot: "Ayant",
        pourquoi: "« Ayant terminé » est un participe passé composé, pas un verbe conjugué.",
      },
      { mot: "terminé" },
      { mot: "ses" },
      { mot: "devoirs," },
      { mot: "ma" },
      { mot: "sœur" },
      { mot: "aide", bon: true, pourquoi: "conjugué au présent." },
      { mot: "ma" },
      { mot: "mère" },
      { mot: "et" },
      { mot: "prépare", bon: true, pourquoi: "conjugué au présent, second verbe." },
      { mot: "le" },
      { mot: "feu." },
    ],
  },
  {
    id: "v5",
    consigne: "Une phrase longue. Combien de propositions ?",
    combien: 0,
    bilan:
      "Une seule, et pourtant la phrase fait deux lignes. La longueur ne dit rien du nombre de propositions : compte les verbes conjugués, et seulement eux.",
    jetons: [
      { mot: "Le" },
      { mot: "vieux" },
      { mot: "commerçant" },
      { mot: "du" },
      { mot: "marché" },
      { mot: "central," },
      { mot: "connu" },
      { mot: "de" },
      { mot: "tous" },
      { mot: "pour" },
      { mot: "sa" },
      { mot: "patience," },
      {
        mot: "acceptait",
        bon: true,
        pourquoi: "seul verbe conjugué, à l'imparfait.",
      },
      { mot: "de" },
      { mot: "vendre", pourquoi: "infinitif : il ne compte pas." },
      { mot: "à" },
      { mot: "crédit." },
    ],
  },
  {
    id: "v6",
    consigne: "Dernière phrase, avec trois propositions à trouver.",
    combien: 0,
    bilan: "Trois verbes conjugués, trois propositions. Tu es prêt pour la leçon suivante.",
    jetons: [
      { mot: "Le" },
      { mot: "car" },
      { mot: "arrive,", bon: true, pourquoi: "conjugué au présent." },
      { mot: "les" },
      { mot: "voyageurs" },
      { mot: "descendent", bon: true, pourquoi: "conjugué au présent." },
      { mot: "et" },
      { mot: "les" },
      { mot: "porteurs" },
      { mot: "se" },
      { mot: "précipitent.", bon: true, pourquoi: "conjugué au présent, verbe pronominal." },
    ],
  },
];

export function CompterPropositions() {
  return (
    <Surligner
      consigne="Clique sur chaque verbe que tu repères, et la simulation te dira s'il est conjugué. Les six phrases contiennent tous les pièges du BEPC : l'infinitif, le participe, et la phrase très longue qui n'a qu'une seule proposition."
      releves={RELEVES_VERBES}
      conclusion={
        <>
          La règle ne souffre aucune exception : <strong>autant de verbes conjugués, autant de
          propositions</strong>. Un infinitif ou un participe ne compte pas, parce qu'il n'a pas de
          sujet et ne se met pas à un temps. Prends l'habitude de te demander, pour chaque verbe :
          celui-là, il est conjugué ?
        </>
      }
    />
  );
}

/* ------------------------------------------------------------------ */
/* 5. Juxtaposées ou coordonnées ?                                     */
/* ------------------------------------------------------------------ */

const LIENS: ReadonlyArray<Question> = [
  {
    id: "j1",
    enonce: "« Le car arrive, les voyageurs descendent. » Comment les propositions sont-elles reliées ?",
    options: [
      {
        texte: "Par juxtaposition : une simple virgule, aucun mot de liaison.",
        bonne: true,
        retour:
          "Oui. La juxtaposition se fait par une virgule, un point-virgule ou deux points — jamais par un mot.",
      },
      {
        texte: "Par coordination",
        bonne: false,
        retour: "La coordination suppose une conjonction ou un adverbe de liaison. Ici il n'y a qu'une virgule.",
      },
      {
        texte: "Par subordination",
        bonne: false,
        retour: "Il n'y a aucun subordonnant. Les deux propositions tiennent debout séparément.",
      },
    ],
  },
  {
    id: "j2",
    enonce: "Quelles sont les sept conjonctions de coordination ?",
    options: [
      {
        texte: "Mais, ou, et, donc, or, ni, car",
        bonne: true,
        retour:
          "On les retient avec « Mais où est donc Ornicar ? », qui les contient toutes dans l'ordre.",
      },
      {
        texte: "Puis, ensuite, alors, enfin, cependant, pourtant, aussi",
        bonne: false,
        retour:
          "Ce sont des adverbes de liaison. Ils font le même travail de coordination, mais ce ne sont pas les sept conjonctions.",
      },
      {
        texte: "Quand, si, que, qui, dont, où, parce que",
        bonne: false,
        retour: "Ce sont des subordonnants : ils rendent la seconde proposition dépendante.",
      },
    ],
  },
  {
    id: "j3",
    enonce:
      "« Les commerçants ouvrent dès six heures ; les clients arrivent plus tard, car le soleil est encore doux. » Combien de propositions, et comment sont-elles reliées ?",
    options: [
      {
        texte:
          "Trois propositions : les deux premières juxtaposées par un point-virgule, les deux dernières coordonnées par « car ».",
        bonne: true,
        retour:
          "Exactement. Trois verbes conjugués — ouvrent, arrivent, est — donc trois propositions, et deux procédés différents dans la même phrase.",
      },
      {
        texte: "Deux propositions coordonnées",
        bonne: false,
        retour: "Compte les verbes conjugués : ouvrent, arrivent, est. Il y en a trois.",
      },
      {
        texte: "Trois propositions, dont une subordonnée",
        bonne: false,
        retour:
          "« Car » est une conjonction de COORDINATION. Aucune proposition ne dépend d'une autre ici.",
      },
    ],
  },
  {
    id: "j4",
    enonce:
      "Comment prouver que des propositions sont bien indépendantes ?",
    options: [
      {
        texte: "En essayant de les séparer en deux phrases : si les deux tiennent debout, elles sont indépendantes.",
        bonne: true,
        retour:
          "C'est le test clé du chapitre. « Le car arrive. Les voyageurs ne descendent pas. » Les deux phrases tiennent.",
      },
      {
        texte: "En comptant leurs mots",
        bonne: false,
        retour: "La longueur n'a aucun rapport avec la dépendance.",
      },
      {
        texte: "En cherchant une virgule",
        bonne: false,
        retour:
          "Une subordonnée aussi peut être séparée par une virgule : « Dès que le car arrive, les voyageurs descendent. »",
      },
    ],
  },
  {
    id: "j5",
    enonce:
      "LE PIÈGE. « Je rentre car il pleut » et « Je rentre parce qu'il pleut » : même sens. Même nature ?",
    options: [
      {
        texte:
          "Non. « Car » coordonne, donc deux indépendantes et une phrase composée. « Parce que » subordonne, donc une principale, une subordonnée, et une phrase complexe.",
        bonne: true,
        retour:
          "C'est la nature du mot de liaison qui décide, jamais le sens. Faire cette remarque en copie rapporte des points, car presque personne ne la fait.",
      },
      {
        texte: "Oui, puisque le sens est le même",
        bonne: false,
        retour:
          "Le sens ne décide de rien en grammaire. Teste la séparation : « Parce qu'il pleut » tout seul ne tient pas, « Car il pleut » non plus d'ailleurs — mais « car » relie deux propositions qui, elles, tiennent chacune.",
      },
    ],
  },
  {
    id: "j6",
    enonce:
      "« Le car arrive, puis les voyageurs descendent. » Quel est le procédé ?",
    options: [
      {
        texte: "La coordination, par l'adverbe de liaison « puis ».",
        bonne: true,
        retour:
          "Les adverbes de liaison — puis, ensuite, cependant, pourtant, alors, enfin — coordonnent au même titre que les sept conjonctions.",
      },
      {
        texte: "La juxtaposition, à cause de la virgule",
        bonne: false,
        retour:
          "La virgule est là, mais le mot « puis » relie aussi. Quand il y a un mot de liaison, c'est une coordination.",
      },
      {
        texte: "La subordination",
        bonne: false,
        retour: "« Puis » n'est pas un subordonnant : les deux propositions restent à égalité.",
      },
    ],
  },
];

export function JuxtapositionCoordination() {
  return (
    <Qcm
      consigne="Six questions sur la phrase composée, et le piège qui tombe le plus souvent : « car » et « parce que » ont presque le même sens et des natures opposées."
      questions={LIENS}
      conclusion={
        <>
          Dans une phrase composée, les propositions sont <strong>à égalité</strong>. Elles sont
          soit <strong>juxtaposées</strong> — par une virgule, un point-virgule ou deux points —
          soit <strong>coordonnées</strong> — par l'une des sept conjonctions, ou par un adverbe de
          liaison. Le test qui tranche est toujours le même : essaie de les séparer en deux
          phrases.
        </>
      }
    />
  );
}

/* ------------------------------------------------------------------ */
/* 6. La question 5 du BEPC                                            */
/* ------------------------------------------------------------------ */

const Q5: ReadonlyArray<Question> = [
  {
    id: "b1",
    enonce:
      "« Quand un Blanc est ruiné, la banque peut lui avancer de l'argent. » Premier geste : combien de propositions ?",
    precision: "Session 2024, question réellement posée.",
    options: [
      {
        texte: "Deux : « est ruiné » et « peut » sont deux verbes conjugués.",
        bonne: true,
        retour: "Oui. Le premier geste est toujours de compter les verbes conjugués.",
      },
      { texte: "Une seule", bonne: false, retour: "Il y a deux verbes conjugués : « est » et « peut »." },
      {
        texte: "Trois",
        bonne: false,
        retour: "« avancer » est un infinitif, il ne compte pas.",
      },
    ],
  },
  {
    id: "b2",
    enonce: "Deuxième geste : relève la proposition PRINCIPALE.",
    options: [
      {
        texte: "« la banque peut lui avancer de l'argent »",
        bonne: true,
        retour:
          "C'est celle qui tient debout toute seule. Le corrigé officiel donne exactement cette réponse.",
      },
      {
        texte: "« Quand un Blanc est ruiné »",
        bonne: false,
        retour:
          "Celle-ci commence par un subordonnant et ne tient pas seule : c'est la subordonnée.",
      },
      {
        texte: "« la banque peut »",
        bonne: false,
        retour: "Une proposition se relève en entier, avec ses compléments.",
      },
    ],
  },
  {
    id: "b3",
    enonce: "Troisième geste : nomme la subordonnée et donne sa fonction.",
    options: [
      {
        texte: "Subordonnée conjonctive circonstancielle de temps, complément circonstanciel de temps de « peut ».",
        bonne: true,
        retour:
          "Le subordonnant « quand » marque le temps. Nature et fonction : il faut les deux pour les points.",
      },
      {
        texte: "Subordonnée relative",
        bonne: false,
        retour:
          "Une relative est introduite par qui, que, dont, où et complète un nom. Ici le subordonnant est « quand ».",
      },
      {
        texte: "Subordonnée circonstancielle de cause",
        bonne: false,
        retour: "« Quand » marque le temps, pas la cause. La cause serait « parce que », « puisque ».",
      },
    ],
  },
  {
    id: "b4",
    enonce:
      "« Le commerçant qui vend le poisson a fermé plus tôt. » Relève la principale.",
    options: [
      {
        texte: "« Le commerçant a fermé plus tôt »",
        bonne: true,
        retour:
          "Il fallait recoller les deux morceaux. La subordonnée est ENCHÂSSÉE : elle coupe la principale en deux.",
      },
      {
        texte: "« a fermé plus tôt »",
        bonne: false,
        retour:
          "Tu as oublié le sujet. La principale est coupée par la relative, il faut recoller : « Le commerçant a fermé plus tôt ».",
      },
      {
        texte: "« Le commerçant »",
        bonne: false,
        retour: "Ce n'est pas une proposition : il n'y a pas de verbe conjugué.",
      },
    ],
  },
  {
    id: "b5",
    enonce: "Dans la même phrase, nomme la subordonnée et donne sa fonction.",
    options: [
      {
        texte:
          "Subordonnée relative, complément de l'antécédent « commerçant ». Le pronom « qui » y est sujet de « vend ».",
        bonne: true,
        retour:
          "Parfait. Ajouter que « qui » est sujet de « vend » montre que tu as compris le fonctionnement, pas seulement l'étiquette.",
      },
      {
        texte: "Subordonnée complétive, complément d'objet direct",
        bonne: false,
        retour:
          "La complétive est introduite par « que » et complète un VERBE. Ici le subordonnant est « qui » et il complète un NOM.",
      },
    ],
  },
  {
    id: "b6",
    enonce:
      "« Le marché ferme à dix-huit heures, car les commerçants rentrent chez eux. » Nature de la phrase ?",
    options: [
      {
        texte: "Phrase composée : deux indépendantes coordonnées par « car ».",
        bonne: true,
        retour:
          "Le test de séparation le prouve : les deux phrases tiennent debout séparément.",
      },
      {
        texte: "Phrase complexe avec une subordonnée de cause",
        bonne: false,
        retour:
          "C'est le piège. « Car » COORDONNE. Si le sujet avait écrit « parce que », la réponse serait l'inverse.",
      },
    ],
  },
  {
    id: "b7",
    enonce:
      "Même phrase, mais avec « parce que » à la place de « car ». Nature de la phrase ?",
    options: [
      {
        texte:
          "Phrase complexe : principale « Le marché ferme à dix-huit heures », subordonnée circonstancielle de cause.",
        bonne: true,
        retour:
          "Même sens, nature opposée. C'est l'observation qui distingue une bonne copie d'une copie moyenne.",
      },
      {
        texte: "Phrase composée, puisque le sens n'a pas changé",
        bonne: false,
        retour:
          "Le sens ne décide jamais de la nature. « Parce que » est un subordonnant : la seconde proposition devient dépendante.",
      },
    ],
  },
  {
    id: "b8",
    enonce:
      "« Je sais que le car est complet. » Quelle est la nature de la subordonnée ?",
    options: [
      {
        texte: "Subordonnée complétive, complément d'objet direct de « sais ».",
        bonne: true,
        retour:
          "Elle complète un VERBE, et elle répond à la question « je sais quoi ? ». C'est la marque de la complétive.",
      },
      {
        texte: "Subordonnée relative",
        bonne: false,
        retour:
          "Le « que » de la relative a un antécédent, un nom qu'il remplace. Ici « que » n'en a pas : il introduit simplement ce que je sais.",
      },
      {
        texte: "Subordonnée circonstancielle",
        bonne: false,
        retour:
          "Une circonstancielle se supprime sans casser la phrase. Essaie : « Je sais » tout seul attend encore quelque chose.",
      },
    ],
  },
];

export function PropositionsBepc() {
  return (
    <Qcm
      consigne="L'exercice de l'examen, geste par geste : compter les verbes conjugués, relever la principale, nommer la subordonnée et donner sa fonction. Huit questions, dont trois tirées de sessions réelles."
      questions={Q5}
      conclusion={
        <>
          La méthode en trois gestes, à refaire dans cet ordre à chaque fois. <strong>Un</strong> :
          compter les verbes conjugués, en écartant les infinitifs et les participes.{" "}
          <strong>Deux</strong> : relever la principale, en recollant ses morceaux si une
          subordonnée l'a coupée en deux. <strong>Trois</strong> : nommer la subordonnée d'après son
          subordonnant, et donner sa fonction. Et garde en tête le piège de « car » contre « parce
          que » : même sens, natures opposées.
        </>
      }
    />
  );
}
