import { useState } from "react";
import { PALETTE, Choice, Verdict } from "./controls";
import { Citation, JeuTri, Qcm, type ItemTri, type Question } from "./philo-noyau";

/** Français 3ème — chapitres 9 et 10 : la relative et la complétive. */

/* ------------------------------------------------------------------ */
/* 1. Choisir le pronom relatif                                        */
/* ------------------------------------------------------------------ */

type PronomCle = "qui" | "que" | "dont" | "ou" | "lequel";

type PhraseRelative = {
  id: string;
  avant: string;
  apres: string;
  bon: PronomCle;
  /** La phrase refaite sans le pronom, qui fait apparaître la construction. */
  refaite: string;
  pourquoi: string;
};

const PRONOMS: ReadonlyArray<{ value: PronomCle; label: string }> = [
  { value: "qui", label: "qui" },
  { value: "que", label: "que" },
  { value: "dont", label: "dont" },
  { value: "ou", label: "où" },
  { value: "lequel", label: "lequel" },
];

const ETIQUETTE: Record<PronomCle, string> = {
  qui: "qui",
  que: "que",
  dont: "dont",
  ou: "où",
  lequel: "lequel",
};

const PHRASES_REL: ReadonlyArray<PhraseRelative> = [
  {
    id: "r1",
    avant: "Le car",
    apres: "arrive vient de Douala.",
    bon: "qui",
    refaite: "Le car arrive. → le car est SUJET de « arrive ».",
    pourquoi: "Sujet du verbe de la relative, donc QUI. C'est le cas le plus fréquent.",
  },
  {
    id: "r2",
    avant: "Le livre",
    apres: "tu m'as prêté est passionnant.",
    bon: "que",
    refaite: "Tu m'as prêté le livre. → aucune préposition, complément d'objet direct.",
    pourquoi:
      "Tu as prêté QUOI ? Le livre. Complément d'objet direct, donc QUE. Et surveille le participe : « prêté » reste invariable ici parce que le complément est « que », masculin singulier.",
  },
  {
    id: "r3",
    avant: "Le film",
    apres: "je t'ai parlé passe ce soir.",
    bon: "dont",
    refaite: "Je t'ai parlé DE ce film. → la préposition « de » apparaît.",
    pourquoi:
      "Dès que la phrase refaite fait apparaître « de », le pronom est DONT. C'est le test mécanique du cours, et il règle l'erreur la plus répandue du français écrit.",
  },
  {
    id: "r4",
    avant: "La ville",
    apres: "je suis né est loin d'ici.",
    bon: "ou",
    refaite: "Je suis né DANS cette ville. → un lieu.",
    pourquoi: "Lieu ou temps, donc OÙ. Avec l'accent : « ou » sans accent est une conjonction.",
  },
  {
    id: "r5",
    avant: "L'outil avec",
    apres: "il travaille est cassé.",
    bon: "lequel",
    refaite: "Il travaille AVEC cet outil. → une préposition est déjà écrite.",
    pourquoi:
      "Après une préposition autre que « de », on emploie LEQUEL, accordé avec l'antécédent. « Outil » est masculin singulier.",
  },
  {
    id: "r6",
    avant: "Les mangues",
    apres: "le marchand vend viennent de Nkongsamba.",
    bon: "que",
    refaite: "Le marchand vend les mangues. → complément d'objet direct.",
    pourquoi:
      "QUE. Et note que le verbe « vend » reste au singulier : son sujet est « le marchand », pas « les mangues ».",
  },
  {
    id: "r7",
    avant: "Mon voisin,",
    apres: "le fils étudie à Yaoundé, est enseignant.",
    bon: "dont",
    refaite: "Le fils DE mon voisin. → « de » porte sur le nom « fils ».",
    pourquoi:
      "DONT, et sa fonction est complément du NOM « fils », pas complément d'objet indirect. C'est la fonction la moins connue du « dont », et celle qui rapporte le plus.",
  },
  {
    id: "r8",
    avant: "Le jour",
    apres: "il est parti, il pleuvait.",
    bon: "ou",
    refaite: "Il est parti CE JOUR-LÀ. → un moment.",
    pourquoi:
      "OÙ sert aussi pour le temps, et beaucoup d'élèves l'ignorent. « Le jour que » est une tournure populaire qu'il faut éviter à l'écrit.",
  },
  {
    id: "r9",
    avant: "La raison pour",
    apres: "je pars ne te regarde pas.",
    bon: "lequel",
    refaite: "Je pars POUR cette raison. → préposition « pour ».",
    pourquoi:
      "LEQUEL s'accorde : « raison » est féminin singulier, donc on écrit « pour laquelle ». La simulation accepte la forme de base ; dans ta copie, accorde.",
  },
  {
    id: "r10",
    avant: "L'élève",
    apres: "travaille réussit.",
    bon: "qui",
    refaite: "L'élève travaille. → sujet.",
    pourquoi:
      "QUI. Et retiens l'accord : le verbe de la relative prend la personne de l'antécédent. « C'est moi qui AI raison », parce que « qui » remplace « moi ».",
  },
  {
    id: "r11",
    avant: "Le problème",
    apres: "nous souffrons est connu.",
    bon: "dont",
    refaite: "Nous souffrons DE ce problème. → « de » apparaît.",
    pourquoi:
      "DONT. Le verbe « souffrir » se construit avec « de », et c'est la construction du verbe qui décide, jamais l'oreille.",
  },
  {
    id: "r12",
    avant: "Le marché",
    apres: "nous allons ouvre à six heures.",
    bon: "ou",
    refaite: "Nous allons AU marché. → un lieu.",
    pourquoi: "OÙ. On pourrait écrire « auquel nous allons », correct mais lourd.",
  },
  {
    id: "r13",
    avant: "Les amis",
    apres: "j'invite viendront demain.",
    bon: "que",
    refaite: "J'invite les amis. → complément d'objet direct.",
    pourquoi:
      "QUE. Piège fréquent : beaucoup écrivent « qui » parce qu'il s'agit de personnes. La fonction décide, pas la nature de l'antécédent.",
  },
  {
    id: "r14",
    avant: "Le stylo avec",
    apres: "j'écris ne marche plus.",
    bon: "lequel",
    refaite: "J'écris AVEC ce stylo. → préposition.",
    pourquoi: "LEQUEL, masculin singulier.",
  },
  {
    id: "r15",
    avant: "L'homme",
    apres: "tu vois là-bas est mon oncle.",
    bon: "que",
    refaite: "Tu vois cet homme. → complément d'objet direct.",
    pourquoi:
      "QUE. Même piège que la phrase 13 : il s'agit d'une personne, et pourtant ce n'est pas « qui ».",
  },
  {
    id: "r16",
    avant: "L'association",
    apres: "le travail est connu reçoit une aide.",
    bon: "dont",
    refaite: "Le travail DE cette association. → complément du nom.",
    pourquoi:
      "DONT, complément du nom « travail ». Si tu as écrit « que », relis la phrase refaite : « le travail de » ne peut pas devenir « que ».",
  },
];

const PHRASE_REL_VIDE: PhraseRelative = {
  id: "",
  avant: "—",
  apres: "—",
  bon: "qui",
  refaite: "—",
  pourquoi: "—",
};

export function PronomRelatif() {
  const [i, setI] = useState(0);
  const [choix, setChoix] = useState<PronomCle | null>(null);
  const [testFait, setTestFait] = useState(false);
  const [erreurs, setErreurs] = useState<Record<string, number>>({});

  const p = PHRASES_REL[i] ?? PHRASE_REL_VIDE;
  const juste = choix === p.bon;

  function repondre(v: PronomCle) {
    setChoix(v);
    if (v !== p.bon) {
      setErreurs((e) => ({ ...e, [p.bon]: (e[p.bon] ?? 0) + 1 }));
    }
  }

  const classement: Array<[string, number]> = Object.entries(erreurs);
  classement.sort((a, b) => b[1] - a[1]);
  const pire = classement[0];

  return (
    <div className="space-y-3">
      <p className="text-sm text-muted-foreground">
        Place le bon pronom relatif. Avant de choisir, fais le test : refais la phrase sans le
        pronom et regarde quelle préposition apparaît.
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
            {choix ? ETIQUETTE[choix] : "……"}
          </span>{" "}
          {p.apres}
        </p>

        {!testFait ? (
          <button
            type="button"
            onClick={() => setTestFait(true)}
            className="mt-3 rounded-lg border border-border px-3 py-1.5 text-xs font-semibold text-foreground"
          >
            Refaire la phrase sans le pronom
          </button>
        ) : (
          <p
            className="mt-3 rounded-md px-2 py-1.5 text-xs"
            style={{ backgroundColor: "rgba(202,138,4,0.12)", color: "#78350f" }}
          >
            {p.refaite}
          </p>
        )}

        <div className="mt-3">
          <Choice<PronomCle | "">
            label="Le pronom qui convient"
            value={choix ?? ""}
            options={PRONOMS}
            onChange={(v) => {
              if (v !== "") repondre(v);
            }}
          />
        </div>

        {choix ? (
          <div className="mt-3 space-y-2">
            <Verdict tone={juste ? "ok" : "bad"}>
              <span className="font-semibold">
                {juste ? "C'est cela. " : `Le pronom attendu est « ${ETIQUETTE[p.bon]} ». `}
              </span>
              {p.pourquoi}
            </Verdict>
            {!testFait ? (
              <p className="text-[11px] italic text-muted-foreground">
                Tu as répondu sans faire le test. Tu as peut-être raison ; tu ne sais pas encore
                pourquoi.
              </p>
            ) : null}
            <button
              type="button"
              onClick={() => {
                setI((n) => (n + 1) % PHRASES_REL.length);
                setChoix(null);
                setTestFait(false);
              }}
              className="rounded-lg bg-primary px-3 py-1.5 text-xs font-semibold text-primary-foreground"
            >
              Phrase suivante ({i + 1} / {PHRASES_REL.length})
            </button>
          </div>
        ) : null}
      </div>

      {pire ? (
        <p className="text-[11px] text-muted-foreground">
          Le pronom qui te résiste le plus pour l'instant :{" "}
          <span className="font-semibold">{ETIQUETTE[pire[0] as PronomCle]}</span> ({pire[1]} erreur
          {pire[1] > 1 ? "s" : ""}). Chez la plupart des élèves, c'est « dont ».
        </p>
      ) : null}

      <Citation auteur="ce que ces seize phrases apprennent">
        On ne choisit jamais le pronom relatif au hasard, ni à l'oreille : c'est la fonction qu'il
        doit occuper dans sa propre proposition qui l'impose. Refais la phrase, regarde la
        préposition, et le pronom se désigne lui-même.
      </Citation>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* 2. La virgule qui change le sens                                    */
/* ------------------------------------------------------------------ */

type PaireVirgule = {
  id: string;
  debut: string;
  relative: string;
  fin: string;
  /** Ce que dit la phrase sans virgules. */
  sansSens: string;
  /** Ce que dit la phrase avec virgules. */
  avecSens: string;
  /** Combien d'individus sont concernés, pour le petit schéma. */
  sansCombien: number;
  total: number;
  enjeu?: string;
};

const PAIRES: ReadonlyArray<PaireVirgule> = [
  {
    id: "v1",
    debut: "Les élèves",
    relative: "qui ont révisé",
    fin: "ont réussi.",
    sansSens: "Parmi tous les élèves, SEULS ceux qui ont révisé ont réussi. Les autres ont échoué.",
    avecSens: "TOUS les élèves ont révisé, et tous ont réussi. La relative ne fait qu'expliquer.",
    sansCombien: 4,
    total: 10,
  },
  {
    id: "v2",
    debut: "Mes frères",
    relative: "qui habitent Douala",
    fin: "viendront.",
    sansSens: "J'ai plusieurs frères ; seuls ceux de Douala viendront.",
    avecSens: "J'ai des frères, ils habitent tous Douala, et ils viendront tous.",
    sansCombien: 2,
    total: 5,
  },
  {
    id: "v3",
    debut: "Les commerçants",
    relative: "qui ouvrent à six heures",
    fin: "font les meilleures affaires.",
    sansSens: "Seuls les matinaux font les meilleures affaires. Les autres non.",
    avecSens: "Tous les commerçants ouvrent à six heures, et tous font les meilleures affaires.",
    sansCombien: 3,
    total: 10,
  },
  {
    id: "v4",
    debut: "Mon oncle",
    relative: "qui vit à Bafoussam",
    fin: "m'a écrit.",
    sansSens: "J'ai plusieurs oncles, et c'est celui de Bafoussam qui a écrit.",
    avecSens: "Je n'ai qu'un seul oncle ; j'ajoute au passage qu'il vit à Bafoussam.",
    sansCombien: 1,
    total: 3,
  },
  {
    id: "v5",
    debut: "Les candidats",
    relative: "qui auront la moyenne",
    fin: "seront convoqués à l'oral.",
    sansSens:
      "Seuls ceux qui ont la moyenne passent l'oral. C'est une règle de sélection, et elle est claire.",
    avecSens:
      "Tous les candidats ont la moyenne — et tous passent l'oral. Le règlement ne sélectionne plus personne.",
    sansCombien: 4,
    total: 10,
    enjeu:
      "Enjeu réel : c'est une phrase de règlement d'examen. Les deux virgules suppriment la sélection.",
  },
  {
    id: "v6",
    debut: "Les locataires",
    relative: "qui n'ont pas payé",
    fin: "recevront un avis.",
    sansSens: "Seuls les mauvais payeurs reçoivent l'avis.",
    avecSens: "Tous les locataires sont en retard, et tous reçoivent l'avis.",
    sansCombien: 2,
    total: 8,
    enjeu:
      "Enjeu réel : c'est une clause de contrat. Un propriétaire qui ponctue mal accuse tout l'immeuble.",
  },
  {
    id: "v7",
    debut: "Les copies",
    relative: "qui dépassent deux pages",
    fin: "seront refusées.",
    sansSens: "Seules les copies trop longues sont refusées.",
    avecSens: "Toutes les copies dépassent deux pages, et toutes sont refusées.",
    sansCombien: 3,
    total: 9,
    enjeu: "Enjeu réel : c'est une consigne d'examen. Mal ponctuée, elle recale tout le monde.",
  },
  {
    id: "v8",
    debut: "Les habitants",
    relative: "qui trient leurs déchets",
    fin: "paieront moins.",
    sansSens: "Seuls ceux qui trient paient moins : c'est une incitation.",
    avecSens: "Tous les habitants trient, donc tous paient moins : il n'y a plus d'incitation.",
    sansCombien: 4,
    total: 10,
  },
  {
    id: "v9",
    debut: "Les enseignants",
    relative: "qui ont suivi la formation",
    fin: "encadreront l'examen.",
    sansSens: "Seuls les enseignants formés encadrent.",
    avecSens: "Tous les enseignants ont été formés, et tous encadrent.",
    sansCombien: 3,
    total: 8,
  },
  {
    id: "v10",
    debut: "Ma sœur",
    relative: "qui habite Garoua",
    fin: "arrive demain.",
    sansSens: "J'ai plusieurs sœurs, et c'est celle de Garoua qui arrive.",
    avecSens: "Je n'ai qu'une sœur ; je précise au passage où elle habite.",
    sansCombien: 1,
    total: 3,
  },
  {
    id: "v11",
    debut: "Les villages",
    relative: "que la route dessert",
    fin: "se sont développés.",
    sansSens: "Seuls les villages desservis se sont développés ; les autres, non.",
    avecSens: "Tous les villages sont desservis, et tous se sont développés.",
    sansCombien: 4,
    total: 11,
  },
  {
    id: "v12",
    debut: "Les plants",
    relative: "qui ont été arrosés",
    fin: "ont survécu.",
    sansSens: "Seuls les plants arrosés ont survécu. C'est l'argument du reboisement.",
    avecSens: "Tous les plants ont été arrosés, et tous ont survécu.",
    sansCombien: 5,
    total: 12,
  },
];

const PAIRE_VIDE: PaireVirgule = {
  id: "",
  debut: "—",
  relative: "—",
  fin: "—",
  sansSens: "—",
  avecSens: "—",
  sansCombien: 0,
  total: 0,
};

export function RelativeDeterminative() {
  const [i, setI] = useState(0);
  const [virgules, setVirgules] = useState(false);

  const p = PAIRES[i] ?? PAIRE_VIDE;
  const concernes = virgules ? p.total : p.sansCombien;

  return (
    <div className="space-y-3">
      <p className="text-sm text-muted-foreground">
        La même phrase, avec et sans virgules. Clique sur les deux boutons et regarde le groupe
        concerné changer.
      </p>

      <div className="rounded-lg border border-border bg-background p-3">
        <p className="text-base text-foreground">
          {p.debut}
          <span style={{ color: virgules ? PALETTE.red : "transparent", fontWeight: 700 }}>
            ,
          </span>{" "}
          <span
            className="rounded px-1.5 py-0.5"
            style={{ backgroundColor: "rgba(37,99,235,0.12)", color: PALETTE.blue }}
          >
            {p.relative}
          </span>
          <span style={{ color: virgules ? PALETTE.red : "transparent", fontWeight: 700 }}>,</span>{" "}
          {p.fin}
        </p>

        <div className="mt-3">
          <Choice<"sans" | "avec">
            label="Ponctuation"
            value={virgules ? "avec" : "sans"}
            options={[
              { value: "sans", label: "sans virgules" },
              { value: "avec", label: "avec virgules" },
            ]}
            onChange={(v) => setVirgules(v === "avec")}
          />
        </div>

        <div className="mt-3 flex flex-wrap gap-1">
          {Array.from({ length: p.total }, (_, k) => (
            <span
              key={`p${k}`}
              className="inline-block h-4 w-4 rounded-full"
              style={{
                backgroundColor: k < concernes ? PALETTE.blue : "rgba(100,116,139,0.22)",
              }}
            />
          ))}
          <span className="ml-2 text-[11px] text-muted-foreground">
            {concernes} concerné{concernes > 1 ? "s" : ""} sur {p.total}
          </span>
        </div>

        <div className="mt-3">
          <Verdict tone={virgules ? "warn" : "ok"}>
            <span className="font-semibold">
              {virgules ? "Relative explicative. " : "Relative déterminative. "}
            </span>
            {virgules ? p.avecSens : p.sansSens}
          </Verdict>
        </div>

        {p.enjeu ? (
          <p
            className="mt-2 rounded-md px-2 py-1.5 text-xs"
            style={{ backgroundColor: "rgba(185,28,28,0.10)", color: "#7f1d1d" }}
          >
            {p.enjeu}
          </p>
        ) : null}

        <button
          type="button"
          onClick={() => {
            setI((n) => (n + 1) % PAIRES.length);
            setVirgules(false);
          }}
          className="mt-3 rounded-lg bg-primary px-3 py-1.5 text-xs font-semibold text-primary-foreground"
        >
          Phrase suivante ({i + 1} / {PAIRES.length})
        </button>
      </div>

      <Citation auteur="pourquoi cette virgule n'est pas un ornement">
        Sans virgule, certains ; avec virgules, tous. Dans un texte de loi, dans un contrat, dans
        une consigne d'examen, cette virgule-là a des conséquences réelles — et trois des douze
        phrases que tu viens de lire sont de vraies phrases de règlement.
      </Citation>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* 3. Nature et fonction : l'exercice de l'examen                      */
/* ------------------------------------------------------------------ */

type AnalyseRel = {
  id: string;
  /** La phrase découpée : avant la relative, la relative, après. */
  avant: string;
  relative: string;
  apres: string;
  fonctionPronom: string;
  fonctionsFausses: ReadonlyArray<string>;
  nature: string;
  antecedent: string;
  principale: string;
  /** Une principale amputée que l'élève est tenté d'écrire. */
  pieges: ReadonlyArray<string>;
  commentaire: string;
};

const ANALYSES: ReadonlyArray<AnalyseRel> = [
  {
    id: "a1",
    avant: "Le commerçant",
    relative: "qui vend le poisson",
    apres: "a fermé plus tôt.",
    fonctionPronom: "sujet de « vend »",
    fonctionsFausses: ["complément d'objet direct de « vend »", "complément du nom « poisson »"],
    nature: "relative déterminative",
    antecedent: "commerçant",
    principale: "Le commerçant a fermé plus tôt.",
    pieges: ["a fermé plus tôt.", "Le commerçant."],
    commentaire:
      "La relative coupe la principale en deux. Pour la relever, il faut recoller les morceaux — et c'est l'oubli qui coûte le plus à cette question.",
  },
  {
    id: "a2",
    avant: "Les mangues",
    relative: "que le marchand vend",
    apres: "viennent de Nkongsamba.",
    fonctionPronom: "complément d'objet direct de « vend »",
    fonctionsFausses: ["sujet de « vend »", "complément circonstanciel de lieu"],
    nature: "relative déterminative",
    antecedent: "mangues",
    principale: "Les mangues viennent de Nkongsamba.",
    pieges: ["viennent de Nkongsamba.", "Les mangues."],
    commentaire:
      "Le marchand vend QUOI ? Que. Complément d'objet direct. Le sujet de « vend » est « le marchand », qui est écrit juste là.",
  },
  {
    id: "a3",
    avant: "Mon voisin,",
    relative: "dont le fils étudie à Yaoundé,",
    apres: "est enseignant.",
    fonctionPronom: "complément du nom « fils »",
    fonctionsFausses: ["complément d'objet indirect de « étudie »", "sujet de « étudie »"],
    nature: "relative explicative",
    antecedent: "voisin",
    principale: "Mon voisin est enseignant.",
    pieges: ["est enseignant.", "Mon voisin."],
    commentaire:
      "Le « de » porte ici sur un NOM — le fils DE mon voisin — et non sur un verbe. La plupart des copies écrivent « complément d'objet indirect » par réflexe, et perdent le point.",
  },
  {
    id: "a4",
    avant: "Le film",
    relative: "dont je t'ai parlé",
    apres: "passe ce soir.",
    fonctionPronom: "complément d'objet indirect de « ai parlé »",
    fonctionsFausses: ["complément du nom", "complément d'objet direct de « ai parlé »"],
    nature: "relative déterminative",
    antecedent: "film",
    principale: "Le film passe ce soir.",
    pieges: ["passe ce soir."],
    commentaire:
      "Ici, au contraire de la phrase précédente, le « de » porte sur le VERBE : parler DE quelque chose. D'où le complément d'objet indirect.",
  },
  {
    id: "a5",
    avant: "La ville",
    relative: "où je suis né",
    apres: "est loin d'ici.",
    fonctionPronom: "complément circonstanciel de lieu de « suis né »",
    fonctionsFausses: ["sujet de « suis né »", "complément d'objet direct"],
    nature: "relative déterminative",
    antecedent: "ville",
    principale: "La ville est loin d'ici.",
    pieges: ["est loin d'ici."],
    commentaire:
      "Je suis né OÙ ? Dans cette ville. C'est un complément circonstanciel, et il faut préciser « de lieu » pour avoir tout le point.",
  },
  {
    id: "a6",
    avant: "Les élèves",
    relative: "qui travaillent",
    apres: "réussissent.",
    fonctionPronom: "sujet de « travaillent »",
    fonctionsFausses: ["complément d'objet direct", "attribut du sujet"],
    nature: "relative déterminative",
    antecedent: "élèves",
    principale: "Les élèves réussissent.",
    pieges: ["réussissent."],
    commentaire:
      "Et l'accord vient de là : « qui » remplace « les élèves », donc le verbe se met au pluriel. De même, « c'est moi qui AI raison ».",
  },
  {
    id: "a7",
    avant: "L'association,",
    relative: "dont le travail est connu,",
    apres: "a reçu une aide.",
    fonctionPronom: "complément du nom « travail »",
    fonctionsFausses: ["complément d'objet indirect", "complément circonstanciel"],
    nature: "relative explicative",
    antecedent: "association",
    principale: "L'association a reçu une aide.",
    pieges: ["a reçu une aide."],
    commentaire:
      "Les deux virgules rendent la relative explicative : l'association est déjà identifiée, la relative ne fait qu'ajouter un renseignement.",
  },
  {
    id: "a8",
    avant: "L'outil avec",
    relative: "lequel il travaille",
    apres: "est cassé.",
    fonctionPronom: "complément circonstanciel de moyen de « travaille »",
    fonctionsFausses: ["complément d'objet direct", "sujet de « travaille »"],
    nature: "relative déterminative",
    antecedent: "outil",
    principale: "L'outil est cassé.",
    pieges: ["est cassé."],
    commentaire:
      "Il travaille AVEC QUOI ? Avec lequel. C'est un moyen, et la préposition « avec » le disait déjà.",
  },
  {
    id: "a9",
    avant: "Le jour",
    relative: "où il est parti,",
    apres: "il pleuvait.",
    fonctionPronom: "complément circonstanciel de temps de « est parti »",
    fonctionsFausses: ["complément circonstanciel de lieu", "sujet de « est parti »"],
    nature: "relative déterminative",
    antecedent: "jour",
    principale: "Il pleuvait.",
    pieges: ["Le jour il pleuvait."],
    commentaire:
      "Attention : « où » ne marque pas toujours le lieu. Ici l'antécédent est « le jour », donc le complément est de TEMPS. Et la principale, cette fois, n'est pas coupée.",
  },
  {
    id: "a10",
    avant: "Les habitants",
    relative: "que la mairie a prévenus",
    apres: "ont déménagé.",
    fonctionPronom: "complément d'objet direct de « a prévenus »",
    fonctionsFausses: ["sujet de « a prévenus »", "complément du nom « mairie »"],
    nature: "relative déterminative",
    antecedent: "habitants",
    principale: "Les habitants ont déménagé.",
    pieges: ["ont déménagé."],
    commentaire:
      "Et regarde le participe : « prévenus », avec un s. Le complément d'objet direct — « que », qui remplace « les habitants » — est placé AVANT le verbe, donc le participe s'accorde.",
  },
  {
    id: "a11",
    avant: "La raison pour",
    relative: "laquelle je pars",
    apres: "ne te regarde pas.",
    fonctionPronom: "complément circonstanciel de cause de « pars »",
    fonctionsFausses: ["complément d'objet direct", "complément du nom « raison »"],
    nature: "relative déterminative",
    antecedent: "raison",
    principale: "La raison ne te regarde pas.",
    pieges: ["ne te regarde pas."],
    commentaire:
      "Note l'accord du pronom : « raison » est féminin singulier, donc « laquelle ». Un « lequel » ici coûterait le demi-point.",
  },
  {
    id: "a12",
    avant: "Le problème",
    relative: "dont nous souffrons",
    apres: "est connu de tous.",
    fonctionPronom: "complément d'objet indirect de « souffrons »",
    fonctionsFausses: ["complément du nom", "sujet de « souffrons »"],
    nature: "relative déterminative",
    antecedent: "problème",
    principale: "Le problème est connu de tous.",
    pieges: ["est connu de tous."],
    commentaire:
      "Souffrir DE quelque chose : le « de » porte sur le verbe, donc complément d'objet indirect. Compare avec la phrase 3, où il portait sur un nom.",
  },
  {
    id: "a13",
    avant: "Les candidats",
    relative: "qui auront la moyenne",
    apres: "seront convoqués.",
    fonctionPronom: "sujet de « auront »",
    fonctionsFausses: ["complément d'objet direct de « auront »", "attribut"],
    nature: "relative déterminative",
    antecedent: "candidats",
    principale: "Les candidats seront convoqués.",
    pieges: ["seront convoqués."],
    commentaire:
      "Déterminative, sans virgule : la relative sélectionne. C'est exactement ce qu'un règlement veut dire, et les virgules le lui feraient dire le contraire.",
  },
  {
    id: "a14",
    avant: "Le car,",
    relative: "que nous attendions depuis deux heures,",
    apres: "est enfin arrivé.",
    fonctionPronom: "complément d'objet direct de « attendions »",
    fonctionsFausses: ["sujet de « attendions »", "complément circonstanciel de temps"],
    nature: "relative explicative",
    antecedent: "car",
    principale: "Le car est enfin arrivé.",
    pieges: ["est enfin arrivé.", "Le car."],
    commentaire:
      "Explicative : le car est déjà identifié, la relative ajoute un détail. Et « depuis deux heures » appartient à la relative, pas à la principale — c'est le piège de cette phrase.",
  },
];

const ANALYSE_VIDE: AnalyseRel = {
  id: "",
  avant: "—",
  relative: "—",
  apres: "—",
  fonctionPronom: "—",
  fonctionsFausses: [],
  nature: "—",
  antecedent: "—",
  principale: "—",
  pieges: [],
  commentaire: "—",
};

function melanger(bonne: string, fausses: ReadonlyArray<string>, graine: number) {
  const tout = [bonne, ...fausses];
  const place = (graine * 7 + 1) % tout.length;
  const sorti = tout.splice(place, 1);
  const tete = sorti[0] ?? bonne;
  return [tete, ...tout];
}

export function FonctionDuRelatif() {
  const [i, setI] = useState(0);
  const [etape, setEtape] = useState(0);
  const [cacher, setCacher] = useState(false);
  const [score, setScore] = useState(0);
  const [rep, setRep] = useState<string | null>(null);

  const a = ANALYSES[i] ?? ANALYSE_VIDE;

  const optionsFonction = melanger(a.fonctionPronom, a.fonctionsFausses, i);
  const optionsNature = melanger(
    a.nature,
    a.nature.includes("explicative")
      ? ["relative déterminative", "conjonctive complétive"]
      : ["relative explicative", "conjonctive complétive"],
    i + 1,
  );
  const optionsPrincipale = melanger(a.principale, a.pieges, i + 2);

  const enonces: ReadonlyArray<{
    question: string;
    options: ReadonlyArray<string>;
    bonne: string;
  }> = [
    {
      question: "Quelle est la fonction du pronom relatif ?",
      options: optionsFonction,
      bonne: a.fonctionPronom,
    },
    {
      question: "Quelle est la nature exacte de la proposition ?",
      options: optionsNature.map((o) => `proposition subordonnée ${o}`),
      bonne: `proposition subordonnée ${a.nature}`,
    },
    {
      question: "Relève la proposition principale.",
      options: optionsPrincipale,
      bonne: a.principale,
    },
  ];

  const q = enonces[etape] ?? enonces[0];
  const courante = q ?? { question: "—", options: [], bonne: "" };

  function choisir(v: string) {
    setRep(v);
    if (v === courante.bonne) setScore((s) => s + 1);
  }

  return (
    <div className="space-y-3">
      <p className="text-sm text-muted-foreground">
        L'exercice de l'examen, en trois questions notées au demi-point. Commence par cacher la
        principale : lire la relative seule est le geste que personne ne fait et qui règle tout.
      </p>

      <div className="rounded-lg border border-border bg-background p-3">
        <p className="text-base text-foreground">
          <span style={{ opacity: cacher ? 0.18 : 1 }}>{a.avant}</span>{" "}
          <span
            className="rounded px-1.5 py-0.5"
            style={{ backgroundColor: "rgba(37,99,235,0.14)", color: PALETTE.blue }}
          >
            {a.relative}
          </span>{" "}
          <span style={{ opacity: cacher ? 0.18 : 1 }}>{a.apres}</span>
        </p>
        <p className="mt-1 text-[11px] text-muted-foreground">
          Antécédent : <span className="font-semibold">{a.antecedent}</span>
        </p>

        <button
          type="button"
          onClick={() => setCacher((c) => !c)}
          className="mt-2 rounded-lg border border-border px-3 py-1.5 text-xs font-semibold text-foreground"
        >
          {cacher ? "Remontrer la principale" : "Cacher la principale"}
        </button>

        <div className="mt-3 rounded-md border border-border/60 p-2.5">
          <p className="text-xs font-semibold text-foreground">
            Question {etape + 1} / 3 — {courante.question}
          </p>
          <div className="mt-2 space-y-1.5">
            {courante.options.map((o) => {
              const choisi = rep === o;
              const estBonne = o === courante.bonne;
              const montrer = rep !== null;
              return (
                <button
                  key={o}
                  type="button"
                  disabled={rep !== null}
                  onClick={() => choisir(o)}
                  className="block w-full rounded-md border px-2.5 py-1.5 text-left text-xs"
                  style={{
                    borderColor: montrer && estBonne ? PALETTE.green : "rgba(100,116,139,0.3)",
                    backgroundColor:
                      montrer && estBonne
                        ? "rgba(21,128,61,0.10)"
                        : choisi
                          ? "rgba(185,28,28,0.10)"
                          : "transparent",
                  }}
                >
                  {o}
                </button>
              );
            })}
          </div>

          {rep !== null ? (
            <div className="mt-2 space-y-2">
              {etape === 2 && rep !== courante.bonne ? (
                <Verdict tone="bad">
                  <span className="font-semibold">Principale amputée. </span>
                  {a.commentaire}
                </Verdict>
              ) : null}
              {etape < 2 ? (
                <button
                  type="button"
                  onClick={() => {
                    setEtape((e) => e + 1);
                    setRep(null);
                  }}
                  className="rounded-lg bg-primary px-3 py-1.5 text-xs font-semibold text-primary-foreground"
                >
                  Question suivante
                </button>
              ) : (
                <div className="space-y-2">
                  <Verdict tone="ok">
                    <span className="font-semibold">La réponse complète attendue. </span>« Le pronom
                    est un pronom relatif, {a.fonctionPronom}, ayant pour antécédent «{" "}
                    {a.antecedent} ». La proposition « {a.relative.replace(/,$/, "")} » est une
                    proposition subordonnée {a.nature}, complément de son antécédent. La proposition
                    principale est « {a.principale} ». »
                  </Verdict>
                  <p className="text-[11px] italic text-muted-foreground">{a.commentaire}</p>
                  <button
                    type="button"
                    onClick={() => {
                      setI((n) => (n + 1) % ANALYSES.length);
                      setEtape(0);
                      setRep(null);
                      setCacher(false);
                    }}
                    className="rounded-lg bg-primary px-3 py-1.5 text-xs font-semibold text-primary-foreground"
                  >
                    Phrase suivante ({i + 1} / {ANALYSES.length})
                  </button>
                </div>
              )}
            </div>
          ) : null}
        </div>

        <p className="mt-2 text-[11px] text-muted-foreground">
          Points obtenus : {(score * 0.5).toFixed(1).replace(".", ",")}
        </p>
      </div>

      <Citation auteur="le moule à retenir pour l'examen">
        Quatre phrases, et tout y est : la nature du pronom, sa fonction, son antécédent, la nature
        et la fonction de la proposition, puis la principale recollée. Apprends ce moule ; il te
        servira à chaque session.
      </Citation>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* 4. La complétive et sa fonction                                     */
/* ------------------------------------------------------------------ */

const COMPLETIVES: ReadonlyArray<Question> = [
  {
    id: "c1",
    enonce:
      "« Je sais que le car est complet. » Quel groupe nominal pourrait remplacer la subordonnée, et quelle est donc sa fonction ?",
    options: [
      {
        texte: "« Je sais cette nouvelle » → complément d'objet direct de « sais »",
        bonne: true,
        retour:
          "Le test du remplacement est la preuve qu'il s'agit d'une complétive : elle occupe la place d'un groupe nominal complément d'objet direct.",
      },
      {
        texte: "« Je sais vite » → complément circonstanciel de manière",
        bonne: false,
        retour:
          "« Vite » est un adverbe, pas un groupe nominal, et il ne répond pas à « je sais quoi ? ».",
      },
      {
        texte: "Aucun groupe nominal ne peut la remplacer",
        bonne: false,
        retour:
          "Si aucun nom ne peut prendre sa place, ce n'est pas une complétive. Ici « cette nouvelle » convient parfaitement.",
      },
    ],
  },
  {
    id: "c2",
    enonce:
      "« Le professeur a annoncé que le contrôle était reporté. » Fonction de la subordonnée ?",
    options: [
      {
        texte: "Complément d'objet direct de « a annoncé »",
        bonne: true,
        retour:
          "Le professeur a annoncé QUOI ? Et la preuve par le nom : « il a annoncé le report du contrôle ».",
      },
      {
        texte: "Complément du nom « professeur »",
        bonne: false,
        retour:
          "Le mot complété n'est pas « professeur » mais le verbe « a annoncé ». Pose la question au mot qui précède immédiatement le « que ».",
      },
      {
        texte: "Sujet de « a annoncé »",
        bonne: false,
        retour: "Le sujet est écrit : « le professeur ».",
      },
    ],
  },
  {
    id: "c3",
    enonce: "« Qu'il soit en retard ne m'étonne pas. » Fonction de la subordonnée ?",
    options: [
      {
        texte: "Sujet du verbe « étonne »",
        bonne: true,
        retour:
          "QU'EST-CE QUI ne m'étonne pas ? Qu'il soit en retard. C'est le cas particulier de la complétive placée en tête. Et note le subjonctif : la complétive sujet s'y met toujours.",
      },
      {
        texte: "Complément d'objet direct de « étonne »",
        bonne: false,
        retour:
          "Le complément d'objet est « me ». La subordonnée, elle, est en tête : elle est sujet.",
      },
      {
        texte: "Complément circonstanciel de cause",
        bonne: false,
        retour:
          "Elle n'est introduite par aucune locution de cause. Supprime-la : il ne reste plus de sujet au verbe, ce qui prouve qu'elle en tenait lieu.",
      },
    ],
  },
  {
    id: "c4",
    enonce: "« J'ai la certitude qu'il dit vrai. » Fonction de la subordonnée ?",
    options: [
      {
        texte: "Complément du nom « certitude »",
        bonne: true,
        retour:
          "C'est le piège de l'exercice. Le verbe est « ai », et on n'a pas « quelque chose qu'on a dit » : la subordonnée complète le NOM. La preuve : « j'ai la certitude de sa sincérité ».",
      },
      {
        texte: "Complément d'objet direct de « ai »",
        bonne: false,
        retour:
          "Le complément d'objet direct de « ai » est « la certitude ». La subordonnée, elle, complète ce nom.",
      },
      {
        texte: "Sujet de « dit »",
        bonne: false,
        retour: "Le sujet de « dit » est « il », à l'intérieur même de la subordonnée.",
      },
    ],
  },
  {
    id: "c5",
    enonce: "« Je suis certain qu'il viendra. » Fonction de la subordonnée ?",
    options: [
      {
        texte: "Complément de l'adjectif « certain »",
        bonne: true,
        retour:
          "Le mot complété est l'adjectif attribut. La preuve par le nom : « je suis certain de sa venue ».",
      },
      {
        texte: "Complément d'objet direct de « suis »",
        bonne: false,
        retour:
          "« Être » est un verbe d'état : il n'a pas de complément d'objet, mais un attribut.",
      },
      {
        texte: "Attribut du sujet",
        bonne: false,
        retour: "L'attribut est « certain ». La subordonnée complète cet attribut.",
      },
    ],
  },
  {
    id: "c6",
    enonce: "« Qu'il réussisse me ferait plaisir. » Quel groupe nominal la remplacerait ?",
    options: [
      {
        texte: "« Sa réussite me ferait plaisir » → la subordonnée est sujet",
        bonne: true,
        retour: "Le remplacement par un nom est la preuve, et il montre du même coup la fonction.",
      },
      {
        texte: "« Me faire plaisir » → elle est complément",
        bonne: false,
        retour: "Ce n'est pas un groupe nominal mais un infinitif, et il ne prend pas sa place.",
      },
      {
        texte: "Aucun",
        bonne: false,
        retour: "« Sa réussite » convient exactement, à la même place.",
      },
    ],
  },
  {
    id: "c7",
    enonce: "« J'espère que tu pourras venir. » Fonction de la subordonnée ?",
    options: [
      {
        texte: "Complément d'objet direct de « espère »",
        bonne: true,
        retour:
          "J'espère QUOI ? Et retiens le mode : « espérer » commande l'INDICATIF, c'est l'exception du cours.",
      },
      {
        texte: "Complément circonstanciel de but",
        bonne: false,
        retour: "Elle n'est pas introduite par « pour que » ou « afin que ».",
      },
      {
        texte: "Sujet",
        bonne: false,
        retour: "Le sujet est « j' ». La subordonnée suit le verbe.",
      },
    ],
  },
  {
    id: "c8",
    enonce: "« Il faut que tu sois à l'heure. » Fonction de la subordonnée ?",
    options: [
      {
        texte: "Sujet réel du verbe impersonnel « faut »",
        bonne: true,
        retour:
          "« Il » est un sujet apparent, sans contenu ; la subordonnée est le sujet réel. C'est une analyse fine, et elle est attendue en troisième.",
      },
      {
        texte: "Complément d'objet direct de « faut »",
        bonne: false,
        retour:
          "« Falloir » est un verbe impersonnel : il n'a pas de complément d'objet, mais un sujet réel.",
      },
      {
        texte: "Complément du nom",
        bonne: false,
        retour: "Il n'y a aucun nom avant le « que ».",
      },
    ],
  },
  {
    id: "c9",
    enonce: "« J'ai l'impression qu'il ment. » Que complète la subordonnée ?",
    options: [
      {
        texte: "Le nom « impression »",
        bonne: true,
        retour: "La preuve par le nom : « j'ai l'impression de sa mauvaise foi ».",
      },
      {
        texte: "Le verbe « ai »",
        bonne: false,
        retour:
          "Le complément d'objet direct de « ai » est « l'impression ». Pose toujours la question au mot qui précède immédiatement le « que ».",
      },
      {
        texte: "Le verbe « ment »",
        bonne: false,
        retour:
          "« Ment » est à l'intérieur de la subordonnée : il ne peut pas être complété par elle.",
      },
    ],
  },
  {
    id: "c10",
    enonce: "« Il craint que la pluie ne retarde le car. » Fonction de la subordonnée ?",
    options: [
      {
        texte: "Complément d'objet direct de « craint »",
        bonne: true,
        retour:
          "Il craint QUOI ? Et note le « ne » explétif, qui n'est pas une négation : « que la pluie ne retarde » signifie bien qu'on craint qu'elle retarde.",
      },
      {
        texte: "Complément circonstanciel de cause",
        bonne: false,
        retour: "Aucune locution de cause n'introduit la subordonnée.",
      },
      {
        texte: "Sujet",
        bonne: false,
        retour: "Le sujet est « il ».",
      },
    ],
  },
  {
    id: "c11",
    enonce:
      "« Je vois que tu as compris. » À quelle famille appartient le verbe de la principale ?",
    options: [
      {
        texte: "Verbe de perception → indicatif dans la complétive",
        bonne: true,
        retour:
          "Les verbes de perception présentent le fait comme réel, donc indicatif. Comme les verbes de déclaration, d'opinion et de connaissance.",
      },
      {
        texte: "Verbe de volonté → subjonctif",
        bonne: false,
        retour:
          "« Voir » n'exprime aucune volonté. On dirait « je vois que tu AS », et non « que tu AIES ».",
      },
      {
        texte: "Verbe de sentiment → subjonctif",
        bonne: false,
        retour: "« Voir » n'exprime pas un sentiment mais une perception.",
      },
    ],
  },
  {
    id: "c12",
    enonce: "« Il exige que tout le monde parte. » Pourquoi le subjonctif ?",
    options: [
      {
        texte: "« Exiger » est un verbe de volonté : le fait est voulu, pas donné comme réel",
        bonne: true,
        retour:
          "Volonté et sentiment appellent le subjonctif ; déclaration, opinion, connaissance et perception appellent l'indicatif.",
      },
      {
        texte: "Parce que la subordonnée est en deuxième position",
        bonne: false,
        retour: "La place n'y est pour rien : c'est le verbe de la principale qui décide.",
      },
      {
        texte: "Parce que le verbe « partir » est du troisième groupe",
        bonne: false,
        retour: "Le groupe du verbe ne décide jamais du mode.",
      },
    ],
  },
  {
    id: "c13",
    enonce: "« Ta venue m'a surpris. » Transformée en complétive, que devient-elle ?",
    options: [
      {
        texte: "« Que tu viennes m'a surpris » → complétive sujet, au subjonctif",
        bonne: true,
        retour:
          "Le chemin inverse du test de remplacement : si un nom peut devenir une complétive, c'est bien que les deux occupent la même fonction.",
      },
      {
        texte: "« Que tu viens m'a surpris »",
        bonne: false,
        retour: "La complétive sujet se met toujours au subjonctif : « que tu viennes ».",
      },
      {
        texte: "« Tu es venu et cela m'a surpris »",
        bonne: false,
        retour: "C'est une coordination de deux indépendantes, pas une complétive.",
      },
    ],
  },
  {
    id: "c14",
    enonce: "« Le conseil que tu viennes m'a surpris. » Que complète la subordonnée ?",
    options: [
      {
        texte: "Le nom « conseil » : c'est une complétive complément du nom",
        bonne: true,
        retour:
          "Le piège du cours. Il y a bien un nom avant le « que », mais le « que » ne le REMPLACE pas — « tu viennes le conseil » n'a aucun sens. Ce n'est donc pas une relative.",
      },
      {
        texte: "Rien : c'est une relative",
        bonne: false,
        retour:
          "Pour une relative, il faudrait que « que » remplace « le conseil ». Essaie : la phrase obtenue n'a pas de sens.",
      },
      {
        texte: "Le verbe « a surpris »",
        bonne: false,
        retour:
          "Le sujet de « a surpris » est « le conseil », et c'est ce nom que la subordonnée développe.",
      },
    ],
  },
];

export function CompletiveCod() {
  return (
    <Qcm
      consigne="Pour chaque phrase, trouve la fonction de la complétive. Quand tu hésites, passe par le test du remplacement : un groupe nominal peut-il prendre sa place ?"
      questions={COMPLETIVES}
      conclusion={
        <Citation auteur="ce que ces quatorze phrases apprennent">
          La complétive est presque toujours complément d'objet direct — mais pas toujours. Quatre
          des phrases que tu viens de traiter avaient une autre fonction : deux sujets, un
          complément du nom, un complément de l'adjectif. Pose la question au mot qui précède
          immédiatement le « que », et jamais au premier verbe venu.
        </Citation>
      }
    />
  );
}

/* ------------------------------------------------------------------ */
/* 5. Trier les « que »                                                */
/* ------------------------------------------------------------------ */

const LES_QUE: ReadonlyArray<ItemTri> = [
  {
    id: "q1",
    texte: "Je lis le livre que tu m'as prêté.",
    bonne: "relative",
    pourquoi:
      "« Que » remplace « le livre » : tu m'as prêté LE LIVRE. Il a un antécédent et une fonction — complément d'objet direct de « as prêté ».",
  },
  {
    id: "q2",
    texte: "Je sais que tu as raison.",
    bonne: "completive",
    pourquoi:
      "« Que » ne remplace rien. C'est une conjonction de subordination, sans fonction, et la subordonnée complète le verbe « sais ».",
  },
  {
    id: "q3",
    texte: "Il est plus grand que son frère.",
    bonne: "autre",
    pourquoi:
      "C'est le « que » de la COMPARAISON. Il n'introduit aucune subordonnée : il n'y a pas de verbe conjugué derrière lui.",
  },
  {
    id: "q4",
    texte: "Le conseil que tu m'as donné était bon.",
    bonne: "relative",
    pourquoi: "Tu m'as donné LE CONSEIL. Le « que » remplace le nom qui précède.",
  },
  {
    id: "q5",
    texte: "Le conseil que tu viennes m'a surpris.",
    bonne: "completive",
    pourquoi:
      "Même début que la précédente, et pourtant tout change : « tu viennes le conseil » n'a aucun sens, donc le « que » ne remplace rien. C'est le couple de phrases à retenir.",
  },
  {
    id: "q6",
    texte: "Il travaille si bien qu'il réussira.",
    bonne: "autre",
    pourquoi:
      "Locution « si… que », qui introduit une subordonnée circonstancielle de CONSÉQUENCE. Le « que » n'y fonctionne pas seul.",
  },
  {
    id: "q7",
    texte: "J'ai entendu que la route était coupée.",
    bonne: "completive",
    pourquoi:
      "Aucun nom avant le « que » : il y a le verbe « ai entendu ». Et « j'ai entendu » reste suspendu sans la suite.",
  },
  {
    id: "q8",
    texte: "J'ai entendu le bruit que faisait la moto.",
    bonne: "relative",
    pourquoi:
      "La moto faisait LE BRUIT. Les phrases 7 et 8 commencent toutes deux par « j'ai entendu que » : seule l'analyse les sépare.",
  },
  {
    id: "q9",
    texte: "Bien que ce soit difficile, il insiste.",
    bonne: "autre",
    pourquoi: "Locution « bien que », qui introduit une circonstancielle d'OPPOSITION.",
  },
  {
    id: "q10",
    texte: "Les mangues que le marchand vend sont mûres.",
    bonne: "relative",
    pourquoi: "Le marchand vend LES MANGUES. Antécédent présent, fonction présente.",
  },
  {
    id: "q11",
    texte: "Il faut que tu partes maintenant.",
    bonne: "completive",
    pourquoi:
      "« Il faut » est impersonnel, et la subordonnée en est le sujet réel. Le « que » ne remplace rien.",
  },
  {
    id: "q12",
    texte: "Il court plus vite que je ne le croyais.",
    bonne: "autre",
    pourquoi:
      "Comparaison, avec « plus… que ». Le « ne » est explétif, il ne nie rien — un piège fréquent.",
  },
  {
    id: "q13",
    texte: "La maison que mon grand-père a construite est encore debout.",
    bonne: "relative",
    pourquoi:
      "Mon grand-père a construit LA MAISON. Et note le participe accordé, « construite », parce que le complément d'objet direct précède.",
  },
  {
    id: "q14",
    texte: "J'ai l'impression qu'il ment.",
    bonne: "completive",
    pourquoi:
      "Il y a un nom avant — « l'impression » — mais le « que » ne le remplace pas : « il ment l'impression » n'a pas de sens. Complétive complément du nom.",
  },
  {
    id: "q15",
    texte: "Je ne pars pas sans que tu me préviennes.",
    bonne: "autre",
    pourquoi: "Locution « sans que », circonstancielle, suivie du subjonctif.",
  },
  {
    id: "q16",
    texte: "Le jour que tu as choisi me convient.",
    bonne: "relative",
    pourquoi:
      "Tu as choisi LE JOUR. Attention : « le jour que » est ici correct parce que « que » est complément d'objet direct ; c'est « le jour que je suis arrivé » qui serait fautif, et qui demande « où ».",
  },
  {
    id: "q17",
    texte: "Il affirme que les travaux commenceront en mars.",
    bonne: "completive",
    pourquoi: "Verbe de déclaration, complétive complément d'objet direct, indicatif.",
  },
  {
    id: "q18",
    texte: "L'association que la mairie a aidée tient un registre.",
    bonne: "relative",
    pourquoi: "La mairie a aidé L'ASSOCIATION. Participe accordé au féminin, « aidée ».",
  },
  {
    id: "q19",
    texte: "Je crains qu'il ne soit trop tard.",
    bonne: "completive",
    pourquoi:
      "Verbe de sentiment, donc subjonctif, et « ne » explétif. La subordonnée est complément d'objet direct de « crains ».",
  },
  {
    id: "q20",
    texte: "Que de monde sur ce marché !",
    bonne: "autre",
    pourquoi:
      "C'est le « que » EXCLAMATIF, celui que tu as rencontré au chapitre 1. Aucune subordonnée : il n'y a même pas de verbe conjugué.",
  },
];

export function QueRelatifOuCompletive() {
  return (
    <div className="space-y-3">
      <JeuTri
        consigne="Vingt phrases, toutes avec un « que ». Pose-toi la seule question qui tranche : le « que » remplace-t-il un nom écrit juste avant ?"
        categories={[
          { value: "relative", label: "relative", aide: "le « que » remplace le nom qui précède" },
          {
            value: "completive",
            label: "complétive",
            aide: "le « que » ne remplace rien, il relie seulement",
          },
          {
            value: "autre",
            label: "ni l'une ni l'autre",
            aide: "comparaison, locution, exclamation",
          },
        ]}
        items={LES_QUE}
        conclusion={
          <Citation auteur="les deux phrases à garder en mémoire">
            « Le conseil que tu m'as donné » et « le conseil que tu viennes ». Même début, même mot,
            et deux natures opposées. Elles montrent que le nom placé avant le « que » ne suffit pas
            : il faut vérifier que le « que » le REMPLACE.
          </Citation>
        }
      />
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* 6. Indicatif ou subjonctif                                          */
/* ------------------------------------------------------------------ */

type Famille = "declaration" | "opinion" | "perception" | "volonte" | "sentiment";

const FAMILLES: Record<Famille, { nom: string; mode: "indicatif" | "subjonctif"; note: string }> = {
  declaration: {
    nom: "déclaration",
    mode: "indicatif",
    note: "dire, affirmer, annoncer, répondre, expliquer — le fait est présenté comme réel.",
  },
  opinion: {
    nom: "opinion et connaissance",
    mode: "indicatif",
    note: "penser, croire, savoir, estimer, juger — mais le subjonctif revient à la forme négative ou interrogative.",
  },
  perception: {
    nom: "perception",
    mode: "indicatif",
    note: "voir, entendre, sentir, remarquer, constater — on perçoit ce qui est.",
  },
  volonte: {
    nom: "volonté",
    mode: "subjonctif",
    note: "vouloir, exiger, ordonner, souhaiter, interdire — le fait est voulu, pas réalisé.",
  },
  sentiment: {
    nom: "sentiment",
    mode: "subjonctif",
    note: "craindre, regretter, se réjouir, s'étonner — sauf « espérer », qui garde l'indicatif.",
  },
};

type PhraseMode = {
  id: string;
  avant: string;
  apres: string;
  verbePrincipal: string;
  famille: Famille;
  mode: "indicatif" | "subjonctif";
  forme: string;
  infinitif: string;
  remarque: string;
};

const PHRASES_MODE: ReadonlyArray<PhraseMode> = [
  {
    id: "m1",
    avant: "Je crois qu'il",
    apres: "en retard.",
    verbePrincipal: "crois",
    famille: "opinion",
    mode: "indicatif",
    forme: "est",
    infinitif: "être",
    remarque: "Verbe d'opinion à la forme affirmative : le fait est présenté comme réel.",
  },
  {
    id: "m2",
    avant: "Je ne crois pas qu'il",
    apres: "en retard.",
    verbePrincipal: "ne crois pas",
    famille: "opinion",
    mode: "subjonctif",
    forme: "soit",
    infinitif: "être",
    remarque:
      "Le même verbe, mais nié. En niant, on retire au fait son caractère certain : subjonctif. C'est le couple à retenir avec la phrase précédente.",
  },
  {
    id: "m3",
    avant: "Ma mère veut que je",
    apres: "mes devoirs.",
    verbePrincipal: "veut",
    famille: "volonte",
    mode: "subjonctif",
    forme: "fasse",
    infinitif: "faire",
    remarque: "Volonté, et subjonctif irrégulier : que je fasse, que nous fassions.",
  },
  {
    id: "m4",
    avant: "J'espère que tu",
    apres: "venir.",
    verbePrincipal: "espère",
    famille: "sentiment",
    mode: "indicatif",
    forme: "pourras",
    infinitif: "pouvoir",
    remarque:
      "L'EXCEPTION du cours. Malgré son sens de sentiment, « espérer » commande l'indicatif — et le futur, puisqu'on espère pour plus tard. « Que tu puisses » est la faute attendue.",
  },
  {
    id: "m5",
    avant: "Il faut que nous",
    apres: "au marché avant midi.",
    verbePrincipal: "il faut",
    famille: "volonte",
    mode: "subjonctif",
    forme: "allions",
    infinitif: "aller",
    remarque:
      "« Il faut que » commande toujours le subjonctif. C'est la construction la plus fréquente du français, et celle où la faute se voit le plus.",
  },
  {
    id: "m6",
    avant: "Penses-tu qu'il",
    apres: "à l'heure ?",
    verbePrincipal: "penses-tu",
    famille: "opinion",
    mode: "subjonctif",
    forme: "soit",
    infinitif: "être",
    remarque:
      "Forme interrogative : même effet que la négation. « Je pense qu'il EST » mais « penses-tu qu'il SOIT ».",
  },
  {
    id: "m7",
    avant: "Je vois qu'il",
    apres: "à pleuvoir.",
    verbePrincipal: "vois",
    famille: "perception",
    mode: "indicatif",
    forme: "commence",
    infinitif: "commencer",
    remarque: "Perception : on perçoit ce qui est réellement.",
  },
  {
    id: "m8",
    avant: "Il exige que tout le monde",
    apres: "avant six heures.",
    verbePrincipal: "exige",
    famille: "volonte",
    mode: "subjonctif",
    forme: "parte",
    infinitif: "partir",
    remarque: "Volonté. Fabrication : ils partent → que je parte.",
  },
  {
    id: "m9",
    avant: "Je suis heureux qu'elle",
    apres: "son examen.",
    verbePrincipal: "suis heureux",
    famille: "sentiment",
    mode: "subjonctif",
    forme: "réussisse",
    infinitif: "réussir",
    remarque: "Sentiment. Fabrication : ils réussissent → que je réussisse.",
  },
  {
    id: "m10",
    avant: "Il affirme que les travaux",
    apres: "en mars.",
    verbePrincipal: "affirme",
    famille: "declaration",
    mode: "indicatif",
    forme: "commenceront",
    infinitif: "commencer",
    remarque: "Déclaration : le fait est rapporté comme réel, et il est à venir, donc au futur.",
  },
  {
    id: "m11",
    avant: "Je crains qu'il ne",
    apres: "trop tard.",
    verbePrincipal: "crains",
    famille: "sentiment",
    mode: "subjonctif",
    forme: "soit",
    infinitif: "être",
    remarque:
      "Sentiment, donc subjonctif. Et le « ne » est explétif : il ne nie rien, on craint bien qu'il soit trop tard.",
  },
  {
    id: "m12",
    avant: "Je sais que tu",
    apres: "raison.",
    verbePrincipal: "sais",
    famille: "opinion",
    mode: "indicatif",
    forme: "as",
    infinitif: "avoir",
    remarque: "Connaissance à la forme affirmative : indicatif.",
  },
  {
    id: "m13",
    avant: "Bien qu'il",
    apres: "compris, il recommence.",
    verbePrincipal: "bien que",
    famille: "volonte",
    mode: "subjonctif",
    forme: "ait",
    infinitif: "avoir",
    remarque:
      "« Bien que » appelle toujours le subjonctif. « Bien qu'il A compris » est une faute très répandue à l'oral comme à l'écrit.",
  },
  {
    id: "m14",
    avant: "Il regrette que nous",
    apres: "si tôt.",
    verbePrincipal: "regrette",
    famille: "sentiment",
    mode: "subjonctif",
    forme: "partions",
    infinitif: "partir",
    remarque: "Sentiment. À la première personne du pluriel, la terminaison est -ions.",
  },
  {
    id: "m15",
    avant: "Avant que tu ne",
    apres: ", préviens-moi.",
    verbePrincipal: "avant que",
    famille: "volonte",
    mode: "subjonctif",
    forme: "partes",
    infinitif: "partir",
    remarque:
      "« Avant que » appelle le subjonctif, « après que » l'indicatif. C'est un piège d'examen.",
  },
  {
    id: "m16",
    avant: "Il répond qu'il ne",
    apres: "rien de cette affaire.",
    verbePrincipal: "répond",
    famille: "declaration",
    mode: "indicatif",
    forme: "sait",
    infinitif: "savoir",
    remarque:
      "Attention : c'est la SUBORDONNÉE qui est niée, pas la principale. La négation ne change le mode que lorsqu'elle porte sur le verbe principal.",
  },
  {
    id: "m17",
    avant: "Nous souhaitons que la commune",
    apres: "le bac.",
    verbePrincipal: "souhaitons",
    famille: "volonte",
    mode: "subjonctif",
    forme: "remplace",
    infinitif: "remplacer",
    remarque:
      "Volonté. Et au premier groupe, le subjonctif se confond avec le présent de l'indicatif à cette personne : seule l'analyse permet de le nommer.",
  },
  {
    id: "m18",
    avant: "Je constate que le camion ne",
    apres: "plus.",
    verbePrincipal: "constate",
    famille: "perception",
    mode: "indicatif",
    forme: "passe",
    infinitif: "passer",
    remarque: "Perception, indicatif. Même remarque que pour la phrase précédente sur la forme.",
  },
];

const PHRASE_MODE_VIDE: PhraseMode = {
  id: "",
  avant: "—",
  apres: "—",
  verbePrincipal: "—",
  famille: "opinion",
  mode: "indicatif",
  forme: "",
  infinitif: "—",
  remarque: "—",
};

export function IndicatifOuSubjonctif() {
  const [i, setI] = useState(0);
  const [mode, setMode] = useState<"indicatif" | "subjonctif" | null>(null);
  const [saisie, setSaisie] = useState("");
  const [valide, setValide] = useState(false);
  const [astuce, setAstuce] = useState(false);

  const p = PHRASES_MODE[i] ?? PHRASE_MODE_VIDE;
  const f = FAMILLES[p.famille];
  const modeJuste = mode === p.mode;
  const formeJuste = saisie.trim().toLowerCase() === p.forme.toLowerCase();

  function suivante() {
    setI((n) => (n + 1) % PHRASES_MODE.length);
    setMode(null);
    setSaisie("");
    setValide(false);
    setAstuce(false);
  }

  return (
    <div className="space-y-3">
      <p className="text-sm text-muted-foreground">
        Le verbe de la principale décide du mode. Regarde d'abord sa famille, choisis ensuite, écris
        enfin la forme.
      </p>

      <div className="rounded-lg border border-border bg-background p-3">
        <p className="text-base text-foreground">
          {p.avant}{" "}
          <span
            className="rounded px-2 py-0.5 font-semibold"
            style={{
              backgroundColor: valide ? "rgba(21,128,61,0.12)" : "rgba(100,116,139,0.14)",
              color: valide ? PALETTE.green : PALETTE.slate,
            }}
          >
            {valide ? p.forme : "……"}
          </span>{" "}
          {p.apres}
        </p>
        <p className="mt-1 text-[11px] text-muted-foreground">
          verbe à employer : <span className="font-semibold">{p.infinitif}</span>
        </p>

        <div
          className="mt-3 rounded-md px-2.5 py-2"
          style={{ backgroundColor: "rgba(37,99,235,0.08)" }}
        >
          <p className="text-xs font-semibold" style={{ color: PALETTE.blue }}>
            Verbe de la principale : « {p.verbePrincipal} » → famille {f.nom}
          </p>
          <p className="mt-0.5 text-[11px] text-muted-foreground">{f.note}</p>
        </div>

        <div className="mt-3">
          <Choice<"indicatif" | "subjonctif" | "">
            label="Le mode de la subordonnée"
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
                {modeJuste ? "Bon mode. " : `Le mode attendu est le ${p.mode}. `}
              </span>
              {p.remarque}
            </Verdict>

            <div className="flex flex-wrap items-center gap-2">
              <input
                value={saisie}
                onChange={(e) => setSaisie(e.target.value)}
                placeholder="écris la forme du verbe"
                className="rounded-md border border-border bg-background px-2.5 py-1.5 text-sm text-foreground"
              />
              <button
                type="button"
                onClick={() => setValide(true)}
                className="rounded-lg bg-primary px-3 py-1.5 text-xs font-semibold text-primary-foreground"
              >
                Vérifier
              </button>
              <button
                type="button"
                onClick={() => setAstuce((a) => !a)}
                className="rounded-lg border border-border px-3 py-1.5 text-xs font-semibold text-foreground"
              >
                L'astuce de l'oreille
              </button>
            </div>

            {astuce ? (
              <p
                className="rounded-md px-2 py-1.5 text-xs"
                style={{ backgroundColor: "rgba(202,138,4,0.12)", color: "#78350f" }}
              >
                Remplace mentalement ton verbe par « être » ou « faire », dont le subjonctif
                s'entend très bien. « Il faut que je sois » sonne juste, « il faut que je suis »
                sonne faux. Si l'oreille tranche pour « être », elle a tranché pour tous les autres.
              </p>
            ) : null}

            {valide ? (
              <div className="space-y-2">
                <Verdict tone={formeJuste ? "ok" : "warn"}>
                  <span className="font-semibold">
                    {formeJuste ? "Forme exacte. " : `La forme attendue : « ${p.forme} ». `}
                  </span>
                  {p.avant} {p.forme} {p.apres}
                </Verdict>
                <button
                  type="button"
                  onClick={suivante}
                  className="rounded-lg bg-primary px-3 py-1.5 text-xs font-semibold text-primary-foreground"
                >
                  Phrase suivante ({i + 1} / {PHRASES_MODE.length})
                </button>
              </div>
            ) : null}
          </div>
        ) : null}
      </div>

      <Citation auteur="les trois pièges du chapitre">
        Le verbe d'opinion qui passe au subjonctif dès qu'on le nie ou qu'on l'interroge ;
        l'exception « espérer », qui garde l'indicatif ; et le « il faut que » que tout le monde
        écorche. Les dix-huit phrases que tu viens de traiter les contiennent toutes les trois.
      </Citation>
    </div>
  );
}
