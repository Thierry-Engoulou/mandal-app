import { useState } from "react";
import { PALETTE, Verdict } from "./controls";
import { Citation, Qcm, type Question } from "./philo-noyau";
import {
  Conjuguer,
  Surligner,
  TexteColore,
  type Conjugaison,
  type Releve,
  type Segment,
} from "./fr3-noyau";

/** Français 3ème — chapitres 3 et 4 : accords du sujet, temps de l'indicatif. */

/* ------------------------------------------------------------------ */
/* 1. Qui est-ce qui ?                                                 */
/* ------------------------------------------------------------------ */

const SUJETS: ReadonlyArray<Releve> = [
  {
    id: "s1",
    consigne: "Clique sur le sujet du verbe « jouent ».",
    combien: 2,
    bilan: "Sujet INVERSÉ : il se place après le verbe parce que le complément ouvre la phrase.",
    jetons: [
      { mot: "Dans" },
      { mot: "la" },
      { mot: "cour" },
      { mot: "jouent", cliquable: false },
      { mot: "les", bon: true, pourquoi: "qui est-ce qui joue ? les enfants, pluriel." },
      { mot: "enfants", bon: true, pourquoi: "noyau du groupe sujet." },
      { mot: "du" },
      { mot: "quartier." },
    ],
  },
  {
    id: "s2",
    consigne: "Clique sur le sujet du verbe « réveille ».",
    combien: 2,
    bilan:
      "Écran du complément du nom : « des motos » est juste avant le verbe, mais ce n'est pas lui qui réveille.",
    jetons: [
      { mot: "Le", bon: true, pourquoi: "qui est-ce qui réveille ? le bruit, singulier." },
      { mot: "bruit", bon: true, pourquoi: "noyau du groupe sujet." },
      { mot: "des" },
      { mot: "motos" },
      { mot: "me" },
      { mot: "réveille", cliquable: false },
      { mot: "chaque" },
      { mot: "matin." },
    ],
  },
  {
    id: "s3",
    consigne: "Clique sur le sujet du verbe « vend ».",
    combien: 2,
    bilan:
      "Écran du pronom complément : « les » est juste avant le verbe, mais c'est un complément d'objet direct.",
    jetons: [
      { mot: "Les" },
      { mot: "mangues," },
      { mot: "le", bon: true, pourquoi: "qui est-ce qui vend ? le marchand, singulier." },
      { mot: "marchand", bon: true, pourquoi: "noyau du groupe sujet." },
      { mot: "les" },
      { mot: "vend", cliquable: false },
      { mot: "au" },
      { mot: "bord" },
      { mot: "de" },
      { mot: "la" },
      { mot: "route." },
    ],
  },
  {
    id: "s4",
    consigne: "Clique sur le sujet du verbe « répondent ».",
    combien: 2,
    bilan:
      "Écran de la relative : « le professeur » est le sujet de « interroge », pas de « répondent ».",
    jetons: [
      { mot: "Les", bon: true, pourquoi: "qui est-ce qui répond ? les élèves, pluriel." },
      { mot: "élèves", bon: true, pourquoi: "noyau du groupe sujet." },
      { mot: "que" },
      { mot: "le" },
      { mot: "professeur" },
      { mot: "interroge" },
      { mot: "répondent", cliquable: false },
      { mot: "poliment." },
    ],
  },
  {
    id: "s5",
    consigne: "Clique sur le sujet du verbe « déclarèrent ».",
    combien: 2,
    bilan: "Incise : le sujet est inversé quand on rapporte des paroles.",
    jetons: [
      { mot: "«" },
      { mot: "Nous" },
      { mot: "partons" },
      { mot: "»," },
      { mot: "déclarèrent", cliquable: false },
      { mot: "les", bon: true, pourquoi: "qui est-ce qui déclare ? les voyageurs, pluriel." },
      { mot: "voyageurs.", bon: true, pourquoi: "noyau du groupe sujet, placé après le verbe." },
    ],
  },
  {
    id: "s6",
    consigne: "Clique sur le sujet du verbe « s'achèvent ».",
    combien: 2,
    bilan:
      "Après un adverbe en tête — ainsi, peut-être, sans doute, à peine — le sujet s'inverse souvent.",
    jetons: [
      { mot: "Ainsi" },
      { mot: "s'achèvent", cliquable: false },
      { mot: "les", bon: true, pourquoi: "qui est-ce qui s'achève ? les récoltes, pluriel." },
      { mot: "récoltes", bon: true, pourquoi: "noyau du groupe sujet." },
      { mot: "de" },
      { mot: "la" },
      { mot: "saison." },
    ],
  },
];

export function TrouverLeSujet() {
  return (
    <Surligner
      consigne="Six phrases où le sujet se cache. Clique les deux mots du groupe sujet. La simulation pose à ta place la question « qui est-ce qui ? » et te montre si ta réponse y répond."
      releves={SUJETS}
      conclusion={
        <>
          Tu viens de rencontrer les quatre cas du <strong>sujet inversé</strong> — après un
          complément en tête, dans une incise, après un adverbe — et les trois{" "}
          <strong>écrans</strong> qui se glissent entre le sujet et son verbe : le pronom
          complément, le complément du nom, la proposition relative. Dans tous les cas, le remède
          est le même et il n'y en a pas d'autre : pose la question.
        </>
      }
    />
  );
}

/* ------------------------------------------------------------------ */
/* 2. Collectifs et pronoms relatifs                                   */
/* ------------------------------------------------------------------ */

const COLLECTIFS: ReadonlyArray<Question> = [
  {
    id: "k1",
    enonce: "« Une foule de curieux … devant le portail. » Quel accord ?",
    options: [
      {
        texte: "Les deux se défendent : « se pressait » voit l'ensemble comme un bloc, « se pressaient » voit les individus.",
        bonne: true,
        retour:
          "C'est le sens que tu veux donner qui décide. Au BEPC on ne te piégera pas là-dessus, justement parce que les deux passent.",
      },
      { texte: "Seulement le singulier", bonne: false, retour: "Le pluriel est correct si l'on voit les individus pousser chacun de son côté." },
      { texte: "Seulement le pluriel", bonne: false, retour: "Le singulier est correct si l'on voit la masse compacte." },
    ],
  },
  {
    id: "k2",
    enonce: "« La plupart des élèves … arrivés en retard. »",
    options: [
      {
        texte: "sont — « la plupart de » impose toujours le pluriel",
        bonne: true,
        retour:
          "C'est une exception à apprendre telle quelle, malgré l'envie d'accorder avec « plupart », qui est pourtant singulier.",
      },
      {
        texte: "est, car « la plupart » est au singulier",
        bonne: false,
        retour:
          "L'apparence est trompeuse. « La plupart de », « beaucoup de », « un grand nombre de » et « peu de » veulent le pluriel.",
      },
    ],
  },
  {
    id: "k3",
    enonce: "« Le groupe de danseurs … sur la scène. »",
    options: [
      {
        texte: "est entré — l'article défini « le » désigne un groupe précis, donc un bloc",
        bonne: true,
        retour:
          "Compare avec « UN groupe de danseurs sont entrés », où le pluriel passe aussi. C'est l'article qui change tout.",
      },
      {
        texte: "sont entrés, car les danseurs sont plusieurs",
        bonne: false,
        retour:
          "Avec l'article DÉFINI devant le collectif, l'accord se fait au singulier. Avec l'indéfini, les deux passent.",
      },
    ],
  },
  {
    id: "k4",
    enonce: "« C'est moi qui … raison. »",
    options: [
      {
        texte: "ai — le pronom relatif « qui » prend la personne de son antécédent, ici « moi »",
        bonne: true,
        retour:
          "C'est nous qui AVONS gagné, c'est toi qui AS oublié, c'est vous qui ÊTES en retard. Cherche l'antécédent et conjugue comme si tu l'avais pour sujet.",
      },
      {
        texte: "a, car « qui » est une troisième personne",
        bonne: false,
        retour:
          "C'est la faute attendue, et on l'entend partout. « Qui » n'est pas une troisième personne : il prend celle de son antécédent.",
      },
    ],
  },
  {
    id: "k5",
    enonce: "« C'est un des élèves qui … réussi. »",
    options: [
      {
        texte: "ont — l'antécédent est « élèves » : ce sont les élèves qui ont réussi, et il est l'un d'eux",
        bonne: true,
        retour:
          "Le piège de « un des… qui ». Demande-toi qui a réellement fait l'action : pas un seul élève, mais ceux qui ont réussi.",
      },
      {
        texte: "a, puisqu'il n'y en a qu'un",
        bonne: false,
        retour:
          "Relis la phrase : il fait partie d'un ensemble, celui des élèves qui ont réussi. C'est cet ensemble que « qui » reprend.",
      },
    ],
  },
  {
    id: "k6",
    enonce:
      "« Le groupe de femmes qui … le poisson … tôt. » Deux verbes, deux accords. Lequel est juste ?",
    options: [
      {
        texte: "qui vendent le poisson arrive tôt",
        bonne: true,
        retour:
          "Deux accords opposés dans la même phrase. « Vendent » s'accorde avec l'antécédent « femmes » ; « arrive » s'accorde avec « le groupe », précédé de l'article défini. La relative est un écran : elle ne commande rien.",
      },
      {
        texte: "qui vend le poisson arrivent tôt",
        bonne: false,
        retour:
          "Tu as inversé les deux. L'antécédent de « qui » est « femmes », et le sujet de « arrive » est « le groupe ».",
      },
      {
        texte: "qui vendent le poisson arrivent tôt",
        bonne: false,
        retour:
          "Le premier accord est juste. Mais qui arrive ? Le groupe, précédé de l'article défini « le » : singulier.",
      },
    ],
  },
  {
    id: "k7",
    enonce: "« Beaucoup de candidats … échoué cette année. »",
    options: [
      {
        texte: "ont",
        bonne: true,
        retour:
          "Comme « la plupart de ». Ces expressions de quantité imposent le pluriel, quelle que soit leur apparence.",
      },
      { texte: "a", bonne: false, retour: "« Beaucoup de » veut le pluriel. C'est une exception à retenir." },
    ],
  },
];

export function AccordCollectif() {
  return (
    <Qcm
      consigne="Les deux cas où même un bon élève hésite : le nom collectif, et le pronom relatif « qui ». Sept questions, dont celle qui cumule les deux dans la même phrase."
      questions={COLLECTIFS}
      conclusion={
        <>
          Pour les <strong>collectifs</strong>, les deux accords se défendent en général — sauf avec
          l'article défini, qui impose le singulier, et sauf « la plupart de », « beaucoup de », « un
          grand nombre de », « peu de », qui imposent le pluriel. Pour le pronom relatif{" "}
          <strong>qui</strong>, une seule règle : il prend la personne et le nombre de son
          antécédent. Cherche l'antécédent, et conjugue comme si tu l'avais pour sujet.
        </>
      }
    />
  );
}

/* ------------------------------------------------------------------ */
/* 3. La chasse aux fautes d'accord                                    */
/* ------------------------------------------------------------------ */

const CHASSES: ReadonlyArray<Releve> = [
  {
    id: "h1",
    consigne:
      "Clique sur chaque verbe MAL accordé. Attention : certains sont corrects, et cliquer dessus coûte un point.",
    combien: 3,
    bilan: "Trois fautes : un écran relatif, un collectif avec article défini, une incise.",
    jetons: [
      { mot: "Le" },
      { mot: "car" },
      { mot: "que" },
      { mot: "les" },
      { mot: "voyageurs" },
      { mot: "attendent", pourquoi: "Correct : le sujet est « les voyageurs », pluriel." },
      { mot: "depuis" },
      { mot: "l'aube" },
      {
        mot: "arrivent",
        bon: true,
        pourquoi: "FAUTE. Qui est-ce qui arrive ? Le car, singulier. Écran relatif → arrive.",
      },
      { mot: "enfin." },
      { mot: "Sur" },
      { mot: "la" },
      { mot: "place" },
      {
        mot: "se pressent",
        bon: true,
        pourquoi:
          "FAUTE. Le sujet inversé est « la foule », collectif précédé de l'article défini → se presse.",
      },
      { mot: "la" },
      { mot: "foule" },
      { mot: "des" },
      { mot: "porteurs." },
      { mot: "«" },
      { mot: "Nous" },
      { mot: "sommes", pourquoi: "Correct : le sujet est « nous »." },
      { mot: "en" },
      { mot: "retard" },
      { mot: "»," },
      {
        mot: "annoncent",
        bon: true,
        pourquoi: "FAUTE. Incise à sujet inversé : le chauffeur, singulier → annonce.",
      },
      { mot: "le" },
      { mot: "chauffeur." },
    ],
  },
  {
    id: "h2",
    consigne: "Même exercice. Deux fautes cette fois.",
    combien: 2,
    bilan: "Une exception de quantité, et un antécédent de « qui » mal repéré.",
    jetons: [
      { mot: "La" },
      { mot: "plupart" },
      { mot: "des" },
      { mot: "passagers" },
      {
        mot: "descend",
        bon: true,
        pourquoi: "FAUTE. « La plupart de » impose le pluriel → descendent.",
      },
      { mot: "avec" },
      { mot: "leurs" },
      { mot: "bagages." },
      { mot: "C'est" },
      { mot: "moi" },
      { mot: "qui" },
      {
        mot: "a réservé",
        bon: true,
        pourquoi: "FAUTE. L'antécédent de « qui » est « moi », 1re personne → ai réservé.",
      },
      { mot: "les" },
      { mot: "places," },
      { mot: "dit", pourquoi: "Correct : incise, le sujet inversé « un vieil homme » est singulier." },
      { mot: "un" },
      { mot: "vieil" },
      { mot: "homme." },
    ],
  },
  {
    id: "h3",
    consigne: "Dernier texte, plus dense. Trois fautes.",
    combien: 3,
    bilan:
      "Écran du pronom complément, écran du complément du nom, et le piège de « un des… qui ».",
    jetons: [
      { mot: "Les" },
      { mot: "cahiers," },
      { mot: "le" },
      { mot: "libraire" },
      { mot: "les" },
      {
        mot: "rangent",
        bon: true,
        pourquoi: "FAUTE. « les » est complément. Qui range ? Le libraire → range.",
      },
      { mot: "sur" },
      { mot: "l'étagère." },
      { mot: "Le" },
      { mot: "prix" },
      { mot: "des" },
      { mot: "manuels" },
      {
        mot: "augmentent",
        bon: true,
        pourquoi: "FAUTE. Qui augmente ? Le prix, singulier → augmente.",
      },
      { mot: "chaque" },
      { mot: "rentrée." },
      { mot: "C'est" },
      { mot: "un" },
      { mot: "des" },
      { mot: "libraires" },
      { mot: "qui" },
      {
        mot: "accepte",
        bon: true,
        pourquoi:
          "FAUTE. L'antécédent est « libraires » : ce sont les libraires qui acceptent → acceptent.",
      },
      { mot: "le" },
      { mot: "paiement" },
      { mot: "en" },
      { mot: "plusieurs" },
      { mot: "fois." },
    ],
  },
];

export function ChasseAccords() {
  return (
    <Surligner
      consigne="Trois textes truffés de fautes d'accord. Clique les verbes mal accordés — et seulement eux : des verbes parfaitement corrects sont glissés au milieu, comme en correction réelle."
      releves={CHASSES}
      conclusion={
        <>
          Avant chaque verbe que tu écris, un quart de seconde, pose la question :{" "}
          <em>qui est-ce qui ?</em> Ce n'est pas une méthode d'élève lent, c'est ce que font les
          correcteurs eux-mêmes quand ils doutent. L'accord du sujet n'a pas de question réservée au
          BEPC : il se paie partout, et surtout dans l'épreuve d'expression écrite, où la correction
          linguistique est l'un des trois critères de notation.
        </>
      }
    />
  );
}

/* ------------------------------------------------------------------ */
/* 4. L'atelier des temps composés                                     */
/* ------------------------------------------------------------------ */

type VerbeFiche = {
  id: string;
  infinitif: string;
  auxiliaire: "avoir" | "être";
  participe: string;
  pourquoi: string;
  composes: Record<string, string>;
};

const VERBES: ReadonlyArray<VerbeFiche> = [
  {
    id: "chanter",
    infinitif: "chanter",
    auxiliaire: "avoir",
    participe: "chanté",
    pourquoi: "Verbe ordinaire du 1er groupe : auxiliaire AVOIR, et le participe ne s'accorde pas avec le sujet.",
    composes: {
      present: "j'ai chanté",
      imparfait: "j'avais chanté",
      "passe-simple": "j'eus chanté",
      futur: "j'aurai chanté",
    },
  },
  {
    id: "partir",
    infinitif: "partir",
    auxiliaire: "être",
    participe: "parti",
    pourquoi:
      "Verbe de mouvement : auxiliaire ÊTRE. Le participe s'accorde donc avec le sujet — je suis partie, si le sujet est féminin.",
    composes: {
      present: "je suis parti",
      imparfait: "j'étais parti",
      "passe-simple": "je fus parti",
      futur: "je serai parti",
    },
  },
  {
    id: "se lever",
    infinitif: "se lever",
    auxiliaire: "être",
    participe: "levé",
    pourquoi: "Verbe PRONOMINAL : toujours l'auxiliaire être, comme tous les verbes en « se ».",
    composes: {
      present: "je me suis levé",
      imparfait: "je m'étais levé",
      "passe-simple": "je me fus levé",
      futur: "je me serai levé",
    },
  },
  {
    id: "prendre",
    infinitif: "prendre",
    auxiliaire: "avoir",
    participe: "pris",
    pourquoi: "3e groupe, auxiliaire avoir. Participe irrégulier en -is, à connaître.",
    composes: {
      present: "j'ai pris",
      imparfait: "j'avais pris",
      "passe-simple": "j'eus pris",
      futur: "j'aurai pris",
    },
  },
  {
    id: "venir",
    infinitif: "venir",
    auxiliaire: "être",
    participe: "venu",
    pourquoi: "Verbe de mouvement de la liste : auxiliaire être, accord avec le sujet.",
    composes: {
      present: "je suis venu",
      imparfait: "j'étais venu",
      "passe-simple": "je fus venu",
      futur: "je serai venu",
    },
  },
  {
    id: "finir",
    infinitif: "finir",
    auxiliaire: "avoir",
    participe: "fini",
    pourquoi: "2e groupe régulier, auxiliaire avoir.",
    composes: {
      present: "j'ai fini",
      imparfait: "j'avais fini",
      "passe-simple": "j'eus fini",
      futur: "j'aurai fini",
    },
  },
];

const TEMPS_SIMPLES = [
  { cle: "present", label: "Présent", compose: "Passé composé", aux: "au présent" },
  { cle: "imparfait", label: "Imparfait", compose: "Plus-que-parfait", aux: "à l'imparfait" },
  { cle: "passe-simple", label: "Passé simple", compose: "Passé antérieur", aux: "au passé simple" },
  { cle: "futur", label: "Futur simple", compose: "Futur antérieur", aux: "au futur" },
] as const;

const VERBE_DEFAUT: VerbeFiche = VERBES[0] ?? {
  id: "",
  infinitif: "—",
  auxiliaire: "avoir",
  participe: "—",
  pourquoi: "—",
  composes: {},
};

export function TempsIndicatif() {
  const [iv, setIv] = useState(0);
  const [it, setIt] = useState(0);
  const [aux, setAux] = useState<"" | "avoir" | "être">("");

  const v = VERBES[iv] ?? VERBE_DEFAUT;
  const t = TEMPS_SIMPLES[it] ?? TEMPS_SIMPLES[0];
  const bonAux = aux !== "" && aux === v.auxiliaire;
  const forme = v.composes[t.cle] ?? "—";

  return (
    <div className="space-y-3">
      <p className="text-sm text-muted-foreground">
        Choisis un verbe et un temps simple, puis construis toi-même le temps composé. Première
        pièce : l'auxiliaire.
      </p>

      <div className="space-y-2">
        <div className="flex flex-wrap gap-1.5">
          {VERBES.map((x, i) => (
            <button
              key={x.id}
              type="button"
              onClick={() => {
                setIv(i);
                setAux("");
              }}
              className={
                i === iv
                  ? "rounded-lg bg-primary px-2.5 py-1 text-xs font-semibold text-primary-foreground"
                  : "rounded-lg border border-border px-2.5 py-1 text-xs text-muted-foreground hover:bg-secondary/60"
              }
            >
              {x.infinitif}
            </button>
          ))}
        </div>
        <div className="flex flex-wrap gap-1.5">
          {TEMPS_SIMPLES.map((x, i) => (
            <button
              key={x.cle}
              type="button"
              onClick={() => setIt(i)}
              className={
                i === it
                  ? "rounded-lg bg-secondary px-2.5 py-1 text-xs font-semibold text-foreground"
                  : "rounded-lg border border-border px-2.5 py-1 text-xs text-muted-foreground hover:bg-secondary/60"
              }
            >
              {x.label}
            </button>
          ))}
        </div>
      </div>

      <div className="rounded-lg border border-border bg-background p-3">
        <p className="text-xs text-muted-foreground">
          <span className="font-semibold text-foreground">{v.infinitif}</span> — temps simple :{" "}
          {t.label} → temps composé à construire :{" "}
          <span className="font-semibold text-foreground">{t.compose}</span>
        </p>

        <p className="mt-3 text-[11px] font-medium text-muted-foreground">
          Pièce 1 — quel auxiliaire ?
        </p>
        <div className="mt-1 flex gap-1.5">
          {(["avoir", "être"] as const).map((a) => {
            const pris = aux === a;
            const cls = !pris
              ? "border-border bg-background text-muted-foreground hover:bg-secondary/60"
              : bonAux
                ? "border-emerald-500/40 bg-emerald-500/15 text-emerald-700"
                : "border-rose-500/40 bg-rose-500/15 text-rose-700";
            return (
              <button
                key={a}
                type="button"
                onClick={() => setAux(a)}
                className={`rounded-lg border px-3 py-1.5 text-xs font-medium ${cls}`}
              >
                {a}
              </button>
            );
          })}
        </div>

        {aux !== "" ? (
          <div className="mt-3 space-y-2">
            <Verdict tone={bonAux ? "ok" : "bad"}>
              <span className="font-semibold">Auxiliaire {v.auxiliaire}. </span>
              {v.pourquoi}
            </Verdict>
            <div className="rounded-lg bg-secondary/40 px-2.5 py-2">
              <p className="text-[11px] text-muted-foreground">
                Pièce 2 — l'auxiliaire se met <strong>{t.aux}</strong>, comme le temps simple de
                départ. Pièce 3 — on ajoute le participe passé{" "}
                <strong>{v.participe}</strong>.
              </p>
              <p className="mt-1.5 font-mono text-sm font-semibold" style={{ color: PALETTE.green }}>
                {forme}
              </p>
            </div>
          </div>
        ) : null}
      </div>

      <Citation auteur="la règle qui tient tout">
        Chaque temps composé se forme avec l'auxiliaire conjugué au temps simple correspondant,
        suivi du participe passé. Tu n'as donc pas huit temps à apprendre, mais quatre, plus une
        règle de fabrication.
      </Citation>
      <p className="text-[11px] leading-snug text-muted-foreground">
        Les verbes qui prennent <strong>être</strong> : tous les pronominaux, plus la liste des
        verbes de mouvement ou de changement d'état — aller, venir, arriver, partir, entrer, sortir,
        monter, descendre, naître, mourir, rester, tomber, devenir, passer. Avec être, le participe
        s'accorde avec le sujet ; avec avoir, il ne s'accorde pas avec lui.
      </p>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* 5. Le passé simple                                                  */
/* ------------------------------------------------------------------ */

const TABLEAUX_PS: ReadonlyArray<Conjugaison> = [
  {
    id: "p1",
    verbe: "chanter",
    temps: "passé simple de l'indicatif",
    groupe: "1er groupe — série en -ai : -ai, -as, -a, -âmes, -âtes, -èrent",
    formes: ["chantai", "chantas", "chanta", "chantâmes", "chantâtes", "chantèrent"],
    piege:
      "Deux pièges du 1er groupe : « je chantai » sans s — avec un s, ce serait l'imparfait — et « ils chantèrent » avec un accent grave.",
  },
  {
    id: "p2",
    verbe: "finir",
    temps: "passé simple de l'indicatif",
    groupe: "2e groupe — série en -i : -is, -is, -it, -îmes, -îtes, -irent",
    formes: ["finis", "finis", "finit", "finîmes", "finîtes", "finirent"],
    piege: "Les accents circonflexes des deux personnes du pluriel sont obligatoires.",
  },
  {
    id: "p3",
    verbe: "venir",
    temps: "passé simple de l'indicatif",
    groupe: "3e groupe — série particulière en -in",
    formes: ["vins", "vins", "vint", "vînmes", "vîntes", "vinrent"],
    piege:
      "Venir et tenir sont les SEULS à faire -ins, -ins, -int, -înmes, -întes, -inrent. On écrit « ils vinrent », jamais « vindrent » ni « venirent ».",
  },
  {
    id: "p4",
    verbe: "pouvoir",
    temps: "passé simple de l'indicatif",
    groupe: "3e groupe — série en -u : -us, -us, -ut, -ûmes, -ûtes, -urent",
    formes: ["pus", "pus", "put", "pûmes", "pûtes", "purent"],
    piege: "Même série pour vouloir, savoir, croire, lire, courir, devoir et vivre.",
  },
  {
    id: "p5",
    verbe: "être",
    temps: "passé simple de l'indicatif",
    groupe: "auxiliaire — à savoir par cœur",
    formes: ["fus", "fus", "fut", "fûmes", "fûtes", "furent"],
    piege: "« Il fut » sans t supplémentaire, et « ils furent » sans accent.",
  },
  {
    id: "p6",
    verbe: "avoir",
    temps: "passé simple de l'indicatif",
    groupe: "auxiliaire — à savoir par cœur",
    formes: ["eus", "eus", "eut", "eûmes", "eûtes", "eurent"],
    piege: "Ces formes se prononcent « u », ce qui explique les fautes d'orthographe. Écris-les souvent.",
  },
  {
    id: "p7",
    verbe: "prendre",
    temps: "passé simple de l'indicatif",
    groupe: "3e groupe — série en -i",
    formes: ["pris", "pris", "prit", "prîmes", "prîtes", "prirent"],
    piege: "Même modèle pour mettre — je mis, il mit, ils mirent — et pour dire, faire, voir.",
  },
  {
    id: "p8",
    verbe: "descendre",
    temps: "passé simple de l'indicatif",
    groupe: "3e groupe — série en -i",
    formes: [
      "descendis",
      "descendis",
      "descendit",
      "descendîmes",
      "descendîtes",
      "descendirent",
    ],
    piege: "Le verbe du texte d'entraînement du cours : « les voyageurs descendirent un par un ».",
  },
];

export function PasseSimple() {
  return (
    <Conjuguer
      consigne="Huit tableaux à remplir, et ce sont ceux qui tombent. La simulation te donne le groupe et la série de terminaisons avant que tu commences : il ne te reste qu'à appliquer."
      tableaux={TABLEAUX_PS}
      conclusion={
        <>
          Trois séries, et c'est tout : <strong>-ai</strong> pour le 1er groupe,{" "}
          <strong>-i</strong> pour le 2e et une partie du 3e, <strong>-u</strong> pour le reste du
          3e. Plus <strong>venir</strong> et <strong>tenir</strong>, seuls de leur espèce. Et les
          deux pièges de la question 4 du BEPC : le « s » qui transforme « je chantai » en « je
          chantais », et l'accent grave de « ils chantèrent ».
        </>
      }
    />
  );
}

/* ------------------------------------------------------------------ */
/* 6. Imparfait ou passé simple ?                                      */
/* ------------------------------------------------------------------ */

type Trou = {
  avant: string;
  infinitif: string;
  imparfait: string;
  passeSimple: string;
  bon: "imparfait" | "passe";
  pourquoi: string;
};

type Recit = { id: string; titre: string; trous: ReadonlyArray<Trou>; fin: string };

const RECITS: ReadonlyArray<Recit> = [
  {
    id: "r1",
    titre: "Le soir dans la concession",
    trous: [
      {
        avant: "Le soleil ",
        infinitif: "se coucher",
        imparfait: "se couchait",
        passeSimple: "se coucha",
        bon: "imparfait",
        pourquoi: "Description du décor, action qui dure : imparfait.",
      },
      {
        avant: " derrière les collines. Dans la concession, ma grand-mère ",
        infinitif: "préparer",
        imparfait: "préparait",
        passeSimple: "prépara",
        bon: "imparfait",
        pourquoi:
          "Le texte dit « comme chaque soir » : c'est une habitude, donc l'imparfait de répétition. Le détail du texte te donne la réponse.",
      },
      {
        avant: " le repas comme chaque soir ; le feu ",
        infinitif: "crépiter",
        imparfait: "crépitait",
        passeSimple: "crépita",
        bon: "imparfait",
        pourquoi: "Décor sonore qui dure : imparfait de description.",
      },
      {
        avant: " doucement. Tout à coup, un cri ",
        infinitif: "déchirer",
        imparfait: "déchirait",
        passeSimple: "déchira",
        bon: "passe",
        pourquoi:
          "« Tout à coup » annonce la rupture. Action brève et soudaine qui fait basculer le récit : passé simple.",
      },
      {
        avant: " le silence. Ma grand-mère ",
        infinitif: "se lever",
        imparfait: "se levait",
        passeSimple: "se leva",
        bon: "passe",
        pourquoi: "Première des trois actions successives du premier plan.",
      },
      {
        avant: ", ",
        infinitif: "sortir",
        imparfait: "sortait",
        passeSimple: "sortit",
        bon: "passe",
        pourquoi: "Deuxième action, brève, qui suit la précédente comme un pas suit un pas.",
      },
      {
        avant: " et ",
        infinitif: "courir",
        imparfait: "courait",
        passeSimple: "courut",
        bon: "passe",
        pourquoi:
          "Troisième action. Et attention à la forme : courir suit la série en -u, comme pouvoir — « courut », pas « courit ».",
      },
    ],
    fin: " vers la route.",
  },
  {
    id: "r2",
    titre: "Le marché avant l'orage",
    trous: [
      {
        avant: "Il ",
        infinitif: "faire",
        imparfait: "faisait",
        passeSimple: "fit",
        bon: "imparfait",
        pourquoi: "Décor : la chaleur dure depuis le matin.",
      },
      {
        avant: " lourd depuis le matin et les marchandes ",
        infinitif: "ranger",
        imparfait: "rangeaient",
        passeSimple: "rangèrent",
        bon: "imparfait",
        pourquoi:
          "Action en cours au moment où l'événement va survenir : imparfait de durée. Note le « e » de « rangeaient », qui garde le son doux du g.",
      },
      {
        avant: " déjà leurs étals quand la pluie ",
        infinitif: "tomber",
        imparfait: "tombait",
        passeSimple: "tomba",
        bon: "passe",
        pourquoi:
          "La construction imparfait + QUAND + passé simple : la longue action est coupée net par la brève. C'est la plus utile du récit.",
      },
      {
        avant: ". En un instant, la place ",
        infinitif: "se vider",
        imparfait: "se vidait",
        passeSimple: "se vida",
        bon: "passe",
        pourquoi: "« En un instant » : action brève et achevée.",
      },
    ],
    fin: ".",
  },
];

const RECIT_DEFAUT: Recit = RECITS[0] ?? { id: "", titre: "—", trous: [], fin: "" };

export function ImparfaitPasseSimple() {
  const [ir, setIr] = useState(0);
  const [choix, setChoix] = useState<Record<number, "imparfait" | "passe">>({});

  const r = RECITS[ir] ?? RECIT_DEFAUT;
  const repondus = r.trous.filter((_, i) => choix[i]).length;
  const justes = r.trous.filter((t, i) => choix[i] === t.bon).length;
  const fini = repondus === r.trous.length && r.trous.length > 0;

  const segments: Segment[] = [];
  r.trous.forEach((t, i) => {
    segments.push({ texte: t.avant });
    const c = choix[i];
    if (!c) {
      segments.push({ texte: `(${t.infinitif})`, couleur: "rgba(100,116,139,0.18)" });
    } else {
      segments.push({
        texte: c === "imparfait" ? t.imparfait : t.passeSimple,
        couleur:
          c === "imparfait" ? "rgba(37,99,235,0.22)" : "rgba(234,88,12,0.22)",
      });
    }
  });
  segments.push({ texte: r.fin });

  const tousImparfait = fini && r.trous.every((_, i) => choix[i] === "imparfait");
  const tousPasse = fini && r.trous.every((_, i) => choix[i] === "passe");

  return (
    <div className="space-y-3">
      <p className="text-sm text-muted-foreground">
        Choisis pour chaque verbe entre l'imparfait et le passé simple. Le texte se colore en deux
        teintes, et tu vois d'un coup d'œil la forme de ton récit.
      </p>

      <div className="flex flex-wrap gap-1.5">
        {RECITS.map((x, i) => (
          <button
            key={x.id}
            type="button"
            onClick={() => {
              setIr(i);
              setChoix({});
            }}
            className={
              i === ir
                ? "rounded-lg bg-primary px-2.5 py-1 text-xs font-semibold text-primary-foreground"
                : "rounded-lg border border-border px-2.5 py-1 text-xs text-muted-foreground hover:bg-secondary/60"
            }
          >
            {x.titre}
          </button>
        ))}
      </div>

      <TexteColore
        segments={segments}
        legende={[
          { label: "arrière-plan (imparfait)", couleur: "rgba(37,99,235,0.45)" },
          { label: "premier plan (passé simple)", couleur: "rgba(234,88,12,0.45)" },
        ]}
      />

      <ul className="space-y-1.5">
        {r.trous.map((t, i) => {
          const c = choix[i];
          const bon = c === t.bon;
          return (
            <li key={`${t.infinitif}-${i}`} className="rounded-lg border border-border bg-background p-2">
              <div className="flex flex-wrap items-center gap-2">
                <span className="text-xs font-medium text-foreground">{t.infinitif}</span>
                {(["imparfait", "passe"] as const).map((k) => {
                  const pris = c === k;
                  const cls = !pris
                    ? "border-border bg-background text-muted-foreground hover:bg-secondary/60"
                    : bon
                      ? "border-emerald-500/40 bg-emerald-500/15 text-emerald-700"
                      : "border-rose-500/40 bg-rose-500/15 text-rose-700";
                  return (
                    <button
                      key={k}
                      type="button"
                      onClick={() => setChoix((x) => ({ ...x, [i]: k }))}
                      className={`rounded-lg border px-2.5 py-1 text-xs font-medium ${cls}`}
                    >
                      {k === "imparfait" ? t.imparfait : t.passeSimple}
                    </button>
                  );
                })}
              </div>
              {c ? (
                <p
                  className="mt-1 text-[11px] leading-snug"
                  style={{ color: bon ? PALETTE.green : PALETTE.red }}
                >
                  {t.pourquoi}
                </p>
              ) : null}
            </li>
          );
        })}
      </ul>

      {fini ? (
        <Verdict tone={justes === r.trous.length ? "ok" : "warn"}>
          {justes} choix juste(s) sur {r.trous.length}.{" "}
          {tousPasse
            ? "Tout au passé simple : ton texte est devenu une liste d'actions, sans décor ni respiration."
            : tousImparfait
              ? "Tout à l'imparfait : rien n'avance, le récit reste installé et ne bascule jamais."
              : "Regarde la couleur du texte : l'arrière-plan installe, le premier plan découpe. C'est la forme d'un récit qui fonctionne."}
        </Verdict>
      ) : null}

      <Citation auteur="à écrire dans ta copie">
        L'auteur emploie l'imparfait pour décrire le décor et les habitudes, et le passé simple pour
        les actions qui font avancer le récit. Cette phrase, apprise par cœur, vaut deux points à la
        question sur les temps.
      </Citation>
    </div>
  );
}
