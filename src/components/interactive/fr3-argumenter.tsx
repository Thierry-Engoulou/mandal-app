import { useState } from "react";
import { PALETTE, Choice, Ctrl, Verdict } from "./controls";
import { Citation, JeuTri, Parcours, type Etape, type ItemTri } from "./philo-noyau";

/** Français 3ème — chapitres 13 et 14 : connotation et texte argumentatif. */

/* ------------------------------------------------------------------ */
/* 1. Dénotation ou connotation                                        */
/* ------------------------------------------------------------------ */

type Valeur = "meliorative" | "neutre" | "pejorative";

type MotCharge = {
  id: string;
  phrase: string;
  mot: string;
  denotation: string;
  valeur: Valeur;
  /** Les images que le mot réveille ; celles à cocher sont marquées. */
  images: ReadonlyArray<{ texte: string; bon: boolean }>;
  commentaire: string;
  culture?: string;
};

const ETIQUETTE_VALEUR: Record<Valeur, string> = {
  meliorative: "méliorative",
  neutre: "neutre",
  pejorative: "péjorative",
};

const MOTS_CHARGES: ReadonlyArray<MotCharge> = [
  {
    id: "mc1",
    phrase: "Méfie-toi de lui, c'est un vrai serpent.",
    mot: "serpent",
    denotation: "Reptile sans pattes, au corps allongé.",
    valeur: "pejorative",
    images: [
      { texte: "la traîtrise", bon: true },
      { texte: "la ruse", bon: true },
      { texte: "le danger caché", bon: true },
      { texte: "la rapidité", bon: false },
      { texte: "la générosité", bon: false },
    ],
    commentaire:
      "Je n'ai pas voulu dire que cet homme est un reptile. J'ai employé la connotation, et tout le monde m'a compris.",
  },
  {
    id: "mc2",
    phrase: "Il habite une bicoque au bout du chemin.",
    mot: "bicoque",
    denotation: "Bâtiment destiné à l'habitation.",
    valeur: "pejorative",
    images: [
      { texte: "la petitesse", bon: true },
      { texte: "la vétusté", bon: true },
      { texte: "la pauvreté", bon: true },
      { texte: "la noblesse", bon: false },
      { texte: "le confort", bon: false },
    ],
    commentaire:
      "Même dénotation que « maison » et « demeure ». Le fait est identique ; le mépris est dans le mot.",
  },
  {
    id: "mc3",
    phrase: "La demeure du notable domine la vallée.",
    mot: "demeure",
    denotation: "Bâtiment destiné à l'habitation.",
    valeur: "meliorative",
    images: [
      { texte: "la grandeur", bon: true },
      { texte: "l'ancienneté", bon: true },
      { texte: "le prestige", bon: true },
      { texte: "la saleté", bon: false },
      { texte: "l'urgence", bon: false },
    ],
    commentaire: "On parle de la demeure d'un notable ; jamais de la demeure d'un sans-abri.",
  },
  {
    id: "mc4",
    phrase: "Il est économe, et sa famille s'en porte mieux.",
    mot: "économe",
    denotation: "Qui dépense peu d'argent.",
    valeur: "meliorative",
    images: [
      { texte: "la prévoyance", bon: true },
      { texte: "le bon sens", bon: true },
      { texte: "l'avidité", bon: false },
      { texte: "la mesquinerie", bon: false },
    ],
    commentaire:
      "Même comportement que « avare » et « pingre », et jugement opposé. Remarque qu'il n'y a pas de terme vraiment neutre dans cette série : la langue n'offre pas toujours les trois cases.",
  },
  {
    id: "mc5",
    phrase: "Une odeur montait du marché.",
    mot: "odeur",
    denotation: "Ce que l'on perçoit par l'odorat.",
    valeur: "neutre",
    images: [
      { texte: "aucun jugement", bon: true },
      { texte: "une simple description", bon: true },
      { texte: "le dégoût", bon: false },
      { texte: "le plaisir", bon: false },
    ],
    commentaire:
      "Écrire « une odeur montait du marché » est une description. Écrire « une puanteur » est déjà un reproche adressé à la municipalité, et le fait rapporté est le même.",
  },
  {
    id: "mc6",
    phrase: "L'entreprise a entrepris le saccage de la forêt.",
    mot: "saccage",
    denotation: "Action de couper des arbres sur une surface donnée.",
    valeur: "pejorative",
    images: [
      { texte: "la violence", bon: true },
      { texte: "le pillage", bon: true },
      { texte: "l'irréparable", bon: true },
      { texte: "l'organisation", bon: false },
      { texte: "l'emploi", bon: false },
    ],
    commentaire:
      "C'est le mot de l'association. Le technicien écrirait « abattage », l'entreprise « exploitation ». Trois mots, une seule réalité, trois opinions.",
  },
  {
    id: "mc7",
    phrase: "Le chef portait les insignes de la panthère.",
    mot: "panthère",
    denotation: "Grand félin tacheté d'Afrique et d'Asie.",
    valeur: "meliorative",
    images: [
      { texte: "le pouvoir", bon: true },
      { texte: "la royauté", bon: true },
      { texte: "la beauté dangereuse", bon: true },
      { texte: "la lâcheté", bon: false },
    ],
    commentaire: "Un mot ne voyage jamais seul : il emporte la culture de ceux qui l'emploient.",
    culture:
      "En Europe, « panthère » connote surtout la beauté dangereuse. Au Cameroun, il connote aussi le pouvoir et la chefferie — pensez aux insignes traditionnels de l'Ouest.",
  },
  {
    id: "mc8",
    phrase: "Le vieux du quartier a tranché le différend.",
    mot: "vieux",
    denotation: "Personne d'un âge avancé.",
    valeur: "meliorative",
    images: [
      { texte: "le savoir", bon: true },
      { texte: "l'autorité reconnue", bon: true },
      { texte: "l'usure", bon: false },
      { texte: "l'inutilité", bon: false },
    ],
    commentaire: "Ici le mot valorise, et un lecteur européen pourrait s'y tromper.",
    culture:
      "« Vieux » connote l'usure en français de France. Dans beaucoup de nos langues et dans l'usage camerounais, « le vieux » désigne celui qui sait, et le mot est respectueux.",
  },
  {
    id: "mc9",
    phrase: "Les habitants vivent dans un quartier précaire.",
    mot: "précaire",
    denotation: "Dont la situation matérielle n'est pas assurée.",
    valeur: "neutre",
    images: [
      { texte: "un constat administratif", bon: true },
      { texte: "la fragilité, sans mépris", bon: true },
      { texte: "la saleté", bon: false },
      { texte: "la fierté", bon: false },
    ],
    commentaire:
      "Compare avec « bidonville », nettement péjoratif, et « quartier populaire », plutôt mélioratif. Trois mots pour les mêmes rues.",
  },
  {
    id: "mc10",
    phrase: "Le patrimoine forestier du département est menacé.",
    mot: "patrimoine",
    denotation: "Ensemble des biens transmis par les générations précédentes.",
    valeur: "meliorative",
    images: [
      { texte: "l'héritage", bon: true },
      { texte: "ce qu'on doit transmettre", bon: true },
      { texte: "la richesse à préserver", bon: true },
      { texte: "la marchandise", bon: false },
    ],
    commentaire:
      "Nommer la forêt « patrimoine » plutôt que « ressource » a déjà choisi un camp : on exploite une ressource, on protège un patrimoine.",
  },
  {
    id: "mc11",
    phrase: "La commune a lancé un vaste plan d'assainissement.",
    mot: "assainissement",
    denotation: "Ensemble des travaux d'évacuation des eaux usées et des déchets.",
    valeur: "neutre",
    images: [
      { texte: "un terme technique", bon: true },
      { texte: "un vocabulaire d'ingénieur", bon: true },
      { texte: "l'indignation", bon: false },
      { texte: "l'émerveillement", bon: false },
    ],
    commentaire:
      "Le vocabulaire technique passe pour neutre, et c'est précisément ce qui le rend utile à celui qui veut éviter le débat.",
  },
  {
    id: "mc12",
    phrase: "On assiste à une véritable hémorragie de nos forêts.",
    mot: "hémorragie",
    denotation: "Écoulement de sang hors des vaisseaux.",
    valeur: "pejorative",
    images: [
      { texte: "l'urgence vitale", bon: true },
      { texte: "le corps blessé", bon: true },
      { texte: "l'irréversible", bon: true },
      { texte: "la croissance", bon: false },
    ],
    commentaire:
      "C'est une métaphore médicale, et les métaphores sont les mots les plus efficaces de l'argumentation : elles font voir, et ce qui se voit convainc mieux que ce qui se démontre.",
  },
  {
    id: "mc13",
    phrase: "Un attroupement s'est formé devant la mairie.",
    mot: "attroupement",
    denotation: "Réunion de personnes dans un lieu public.",
    valeur: "pejorative",
    images: [
      { texte: "le désordre", bon: true },
      { texte: "la menace possible", bon: true },
      { texte: "le droit d'expression", bon: false },
      { texte: "l'organisation", bon: false },
    ],
    commentaire:
      "« Manifestation » serait neutre, « rassemblement » plutôt mélioratif. Le choix du mot indique déjà si le journal est du côté de la foule ou du côté de la préfecture.",
  },
  {
    id: "mc14",
    phrase: "Il est d'une fermeté remarquable dans ses décisions.",
    mot: "fermeté",
    denotation: "Caractère de celui qui ne change pas d'avis.",
    valeur: "meliorative",
    images: [
      { texte: "le courage", bon: true },
      { texte: "la constance", bon: true },
      { texte: "l'obstination bornée", bon: false },
    ],
    commentaire:
      "Si je dis de toi que tu es ferme, je te félicite ; si je dis que tu es entêté, je te critique. Le comportement est le même.",
  },
  {
    id: "mc15",
    phrase: "Son entêtement a coûté cher à tout le village.",
    mot: "entêtement",
    denotation: "Caractère de celui qui ne change pas d'avis.",
    valeur: "pejorative",
    images: [
      { texte: "le refus d'écouter", bon: true },
      { texte: "l'aveuglement", bon: true },
      { texte: "le courage", bon: false },
      { texte: "la sagesse", bon: false },
    ],
    commentaire:
      "Même dénotation que « fermeté », exactement. Seul le jugement change — et il est tout entier dans le mot choisi.",
  },
  {
    id: "mc16",
    phrase: "La constance de son effort a fini par payer.",
    mot: "constance",
    denotation: "Caractère de celui qui ne change pas d'avis.",
    valeur: "neutre",
    images: [
      { texte: "la durée", bon: true },
      { texte: "la régularité, sans jugement", bon: true },
      { texte: "l'héroïsme", bon: false },
      { texte: "la bêtise", bon: false },
    ],
    commentaire:
      "Voilà la case neutre de la série. Fermeté, entêtement, constance : trois mots, un seul comportement, trois jugements.",
  },
];

const MOT_CHARGE_VIDE: MotCharge = {
  id: "",
  phrase: "—",
  mot: "—",
  denotation: "—",
  valeur: "neutre",
  images: [],
  commentaire: "—",
};

export function DenoteConnote() {
  const [i, setI] = useState(0);
  const [dicoOuvert, setDicoOuvert] = useState(false);
  const [coches, setCoches] = useState<ReadonlyArray<number>>([]);
  const [valeur, setValeur] = useState<Valeur | null>(null);

  const m = MOTS_CHARGES[i] ?? MOT_CHARGE_VIDE;
  const justes = m.images.filter((im, k) => im.bon && coches.includes(k)).length;
  const fausses = m.images.filter((im, k) => !im.bon && coches.includes(k)).length;
  const attendues = m.images.filter((im) => im.bon).length;

  return (
    <div className="space-y-3">
      <p className="text-sm text-muted-foreground">
        Un mot en relief. Ouvre d'abord le dictionnaire pour sa dénotation, puis coche les images
        qu'il réveille, puis range sa connotation.
      </p>

      <div className="rounded-lg border border-border bg-background p-3">
        <p className="text-base text-foreground">
          {m.phrase.split(m.mot)[0]}
          <span
            className="rounded px-1.5 py-0.5 font-semibold"
            style={{ backgroundColor: "rgba(202,138,4,0.18)", color: "#78350f" }}
          >
            {m.mot}
          </span>
          {m.phrase.split(m.mot)[1] ?? ""}
        </p>

        {!dicoOuvert ? (
          <button
            type="button"
            onClick={() => setDicoOuvert(true)}
            className="mt-3 rounded-lg border border-border px-3 py-1.5 text-xs font-semibold text-foreground"
          >
            Ouvrir le dictionnaire
          </button>
        ) : (
          <div
            className="mt-3 rounded-md px-2.5 py-2"
            style={{ backgroundColor: "rgba(100,116,139,0.10)" }}
          >
            <p className="text-[11px] font-semibold text-muted-foreground">
              DÉNOTATION — le sens que personne ne conteste
            </p>
            <p className="mt-0.5 text-sm text-foreground">{m.denotation}</p>
          </div>
        )}

        <p className="mt-3 text-[11px] font-semibold text-muted-foreground">
          CONNOTATION — coche les images que ce mot réveille
        </p>
        <div className="mt-1 flex flex-wrap gap-1.5">
          {m.images.map((im, k) => {
            const actif = coches.includes(k);
            return (
              <button
                key={im.texte}
                type="button"
                onClick={() =>
                  setCoches((c) => (c.includes(k) ? c.filter((x) => x !== k) : [...c, k]))
                }
                className="rounded-md border px-2.5 py-1 text-xs"
                style={{
                  borderColor: actif ? PALETTE.purple : "rgba(100,116,139,0.3)",
                  backgroundColor: actif ? "rgba(124,58,237,0.10)" : "transparent",
                }}
              >
                {im.texte}
              </button>
            );
          })}
        </div>

        <div className="mt-3">
          <Choice<Valeur | "">
            label="Sa connotation est…"
            value={valeur ?? ""}
            options={[
              { value: "meliorative", label: "méliorative" },
              { value: "neutre", label: "neutre" },
              { value: "pejorative", label: "péjorative" },
            ]}
            onChange={(v) => {
              if (v !== "") setValeur(v);
            }}
          />
        </div>

        {valeur !== null ? (
          <div className="mt-3 space-y-2">
            <Verdict tone={valeur === m.valeur ? "ok" : "bad"}>
              <span className="font-semibold">Connotation {ETIQUETTE_VALEUR[m.valeur]}. </span>
              {m.commentaire}
            </Verdict>
            <p className="text-[11px] text-muted-foreground">
              Images justes cochées : {justes} / {attendues}
              {fausses > 0 ? ` — et ${fausses} qui n'appartiennent pas à ce mot.` : "."}
            </p>
            {m.culture ? (
              <p
                className="rounded-md px-2 py-1.5 text-xs"
                style={{ backgroundColor: "rgba(202,138,4,0.12)", color: "#78350f" }}
              >
                <span className="font-semibold">Connotation propre à notre culture. </span>
                {m.culture}
              </p>
            ) : null}
            <button
              type="button"
              onClick={() => {
                setI((n) => (n + 1) % MOTS_CHARGES.length);
                setDicoOuvert(false);
                setCoches([]);
                setValeur(null);
              }}
              className="rounded-lg bg-primary px-3 py-1.5 text-xs font-semibold text-primary-foreground"
            >
              Mot suivant ({i + 1} / {MOTS_CHARGES.length})
            </button>
          </div>
        ) : null}
      </div>

      <Citation auteur="fermeté, entêtement, constance">
        Trois mots, un seul comportement, trois jugements. Le fait ne change pas d'un mot à l'autre
        ; ce qui change, c'est ce que le mot dit de celui qui l'emploie.
      </Citation>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* 2. L'échelle de l'intensité                                         */
/* ------------------------------------------------------------------ */

type SituationEchelle = {
  id: string;
  texte: string;
  gravite: number;
  juste: number;
  remarque: string;
};

const ECHELLE_COLERE = [
  "contrarié",
  "agacé",
  "irrité",
  "en colère",
  "furieux",
  "fou de rage",
] as const;

const SITUATIONS: ReadonlyArray<SituationEchelle> = [
  {
    id: "e1",
    texte: "Ton stylo tombe en panne au milieu d'un devoir.",
    gravite: 1,
    juste: 1,
    remarque:
      "Un stylo. Si tu écris déjà « furieux », que te restera-t-il pour les situations suivantes ?",
  },
  {
    id: "e2",
    texte: "On te bouscule dans un taxi bondé, sans un mot d'excuse.",
    gravite: 2,
    juste: 2,
    remarque: "Une impolitesse ordinaire : « irrité » est à sa juste place.",
  },
  {
    id: "e3",
    texte: "Tu découvres que ton cahier de leçons a été perdu par un camarade.",
    gravite: 3,
    juste: 3,
    remarque: "Une vraie perte, et quelqu'un en est responsable : « en colère » convient.",
  },
  {
    id: "e4",
    texte: "Le camion d'ordures n'est pas passé depuis six semaines dans ton quartier.",
    gravite: 4,
    juste: 4,
    remarque:
      "Une négligence répétée qui touche tout le monde : « furieux » est justifié, et il porte parce que tu ne l'as pas usé avant.",
  },
  {
    id: "e5",
    texte: "Un enfant du quartier se noie dans un caniveau que personne n'a jamais curé.",
    gravite: 5,
    juste: 5,
    remarque:
      "Voilà le dernier degré. Si tu l'avais employé pour le stylo, tu n'aurais plus rien à écrire ici — et c'est exactement ce qui arrive dans beaucoup de copies.",
  },
];

const SITUATION_DEFAUT: SituationEchelle = {
  id: "",
  texte: "—",
  gravite: 0,
  juste: 0,
  remarque: "—",
};

type FigureStyle = {
  id: string;
  expression: string;
  type: "euphemisme" | "hyperbole";
  direct: string;
  intention: string;
};

const FIGURES: ReadonlyArray<FigureStyle> = [
  {
    id: "g1",
    expression: "les personnes à mobilité réduite",
    type: "euphemisme",
    direct: "les handicapés, les infirmes",
    intention: "Euphémisme de délicatesse : l'intention est le respect.",
  },
  {
    id: "g2",
    expression: "je t'ai appelé mille fois",
    type: "hyperbole",
    direct: "plusieurs fois",
    intention: "Personne n'a appelé mille fois. L'hyperbole affaiblit celui qui en abuse.",
  },
  {
    id: "g3",
    expression: "un plan social",
    type: "euphemisme",
    direct: "des licenciements",
    intention:
      "Euphémisme de masque : l'expression fait entendre une aide sociale alors qu'il s'agit de renvoyer des employés. C'est l'usage qu'il faut savoir démonter.",
  },
  {
    id: "g4",
    expression: "c'est un cauchemar, ce devoir",
    type: "hyperbole",
    direct: "c'est difficile",
    intention: "Hyperbole de conversation, si courante qu'on ne l'entend plus.",
  },
  {
    id: "g5",
    expression: "il nous a quittés",
    type: "euphemisme",
    direct: "il est mort",
    intention: "Euphémisme de délicatesse, employé par respect pour la famille.",
  },
  {
    id: "g6",
    expression: "une frappe chirurgicale",
    type: "euphemisme",
    direct: "un bombardement",
    intention:
      "Euphémisme de masque, et le plus efficace de tous : le mot « chirurgicale » emprunte à la médecine son image de précision et de soin.",
  },
  {
    id: "g7",
    expression: "un travail titanesque",
    type: "hyperbole",
    direct: "un travail long",
    intention: "Trois heures de ménage ne sont pas l'œuvre des Titans.",
  },
  {
    id: "g8",
    expression: "un demandeur d'emploi",
    type: "euphemisme",
    direct: "un chômeur",
    intention:
      "Euphémisme administratif : il déplace le regard de la situation subie vers la démarche entreprise.",
  },
];

const FIGURE_DEFAUT: FigureStyle = {
  id: "",
  expression: "—",
  type: "euphemisme",
  direct: "—",
  intention: "—",
};

export function EchelleConnotation() {
  const [atelier, setAtelier] = useState<"echelle" | "figures">("echelle");
  const [is, setIs] = useState(0);
  const [pos, setPos] = useState(0);
  const [montre, setMontre] = useState(false);
  const [choisis, setChoisis] = useState<ReadonlyArray<number>>([]);
  const [ig, setIg] = useState(0);
  const [repG, setRepG] = useState<"euphemisme" | "hyperbole" | null>(null);

  const s = SITUATIONS[is] ?? SITUATION_DEFAUT;
  const mot = ECHELLE_COLERE[Math.min(pos, ECHELLE_COLERE.length - 1)] ?? "—";
  const g = FIGURES[ig] ?? FIGURE_DEFAUT;

  const trop = choisis.filter((c, k) => {
    const prochaine = SITUATIONS[k + 1];
    return prochaine !== undefined && c >= 5;
  }).length;

  return (
    <div className="space-y-3">
      <div>
        <Choice<"echelle" | "figures">
          label="Atelier"
          value={atelier}
          options={[
            { value: "echelle", label: "l'échelle de l'intensité" },
            { value: "figures", label: "euphémisme et hyperbole" },
          ]}
          onChange={setAtelier}
        />
      </div>

      {atelier === "echelle" ? (
        <div className="rounded-lg border border-border bg-background p-3">
          <p className="text-sm text-foreground">{s.texte}</p>

          <div className="mt-3">
            <Ctrl
              label="Le mot que tu emploierais"
              value={pos}
              min={0}
              max={ECHELLE_COLERE.length - 1}
              step={1}
              onChange={(v) => {
                setPos(Math.round(v));
                setMontre(false);
              }}
              display={mot}
              color={PALETTE.orange}
            />
          </div>

          <p className="mt-2 text-sm italic text-foreground">« J'étais {mot}. »</p>

          <div className="mt-2 flex flex-wrap gap-1">
            {ECHELLE_COLERE.map((m, k) => (
              <span
                key={m}
                className="rounded px-1.5 py-0.5 text-[11px]"
                style={{
                  backgroundColor: k === pos ? "rgba(234,88,12,0.18)" : "transparent",
                  color: k === pos ? PALETTE.orange : PALETTE.slate,
                  fontWeight: k === pos ? 600 : 400,
                }}
              >
                {m}
              </span>
            ))}
          </div>

          {!montre ? (
            <button
              type="button"
              onClick={() => {
                setMontre(true);
                setChoisis((c) => [...c, pos]);
              }}
              className="mt-3 rounded-lg bg-primary px-3 py-1.5 text-xs font-semibold text-primary-foreground"
            >
              Valider ce mot
            </button>
          ) : (
            <div className="mt-3 space-y-2">
              <Verdict
                tone={
                  Math.abs(pos - s.juste) === 0
                    ? "ok"
                    : Math.abs(pos - s.juste) === 1
                      ? "warn"
                      : "bad"
                }
              >
                <span className="font-semibold">
                  Le mot attendu : {ECHELLE_COLERE[s.juste] ?? "—"}.{" "}
                </span>
                {s.remarque}
              </Verdict>

              {is < SITUATIONS.length - 1 ? (
                <>
                  <p className="text-[11px] italic text-muted-foreground">
                    La situation suivante est plus grave. Que te reste-t-il comme mot ?
                  </p>
                  <button
                    type="button"
                    onClick={() => {
                      setIs((n) => n + 1);
                      setPos(0);
                      setMontre(false);
                    }}
                    className="rounded-lg bg-primary px-3 py-1.5 text-xs font-semibold text-primary-foreground"
                  >
                    Situation suivante ({is + 1} / {SITUATIONS.length})
                  </button>
                </>
              ) : (
                <div className="space-y-2">
                  <p className="text-xs font-semibold text-foreground">Ta courbe</p>
                  <div className="flex items-end gap-1.5">
                    {choisis.map((c, k) => (
                      <div key={`b${k}`} className="flex flex-col items-center gap-1">
                        <div
                          className="w-7 rounded-t"
                          style={{
                            height: `${8 + c * 11}px`,
                            backgroundColor:
                              (SITUATIONS[k]?.juste ?? 0) === c ? PALETTE.green : PALETTE.orange,
                          }}
                        />
                        <span className="text-[10px] text-muted-foreground">{k + 1}</span>
                      </div>
                    ))}
                  </div>
                  <Verdict tone={trop > 0 ? "bad" : "ok"}>
                    {trop > 0
                      ? "Tu as employé le mot le plus fort avant la fin. Il ne te restait plus rien pour la situation la plus grave : c'est exactement le piège de la surenchère."
                      : "Ta courbe monte. C'est ainsi qu'on écrit : l'échelle est un capital, on la monte, on ne commence pas par le haut."}
                  </Verdict>
                  <button
                    type="button"
                    onClick={() => {
                      setIs(0);
                      setPos(0);
                      setMontre(false);
                      setChoisis([]);
                    }}
                    className="rounded-lg border border-border px-3 py-1.5 text-xs font-semibold text-foreground"
                  >
                    Recommencer la série
                  </button>
                </div>
              )}
            </div>
          )}
        </div>
      ) : (
        <div className="rounded-lg border border-border bg-background p-3">
          <p className="text-base italic text-foreground">« {g.expression} »</p>

          <div className="mt-3">
            <Choice<"euphemisme" | "hyperbole" | "">
              label="Ce procédé est…"
              value={repG ?? ""}
              options={[
                { value: "euphemisme", label: "un euphémisme (il atténue)" },
                { value: "hyperbole", label: "une hyperbole (elle exagère)" },
              ]}
              onChange={(v) => {
                if (v !== "") setRepG(v);
              }}
            />
          </div>

          {repG !== null ? (
            <div className="mt-3 space-y-2">
              <Verdict tone={repG === g.type ? "ok" : "bad"}>
                <span className="font-semibold">
                  {g.type === "euphemisme" ? "Euphémisme" : "Hyperbole"} — le terme direct serait «{" "}
                  {g.direct} ».{" "}
                </span>
                {g.intention}
              </Verdict>
              <button
                type="button"
                onClick={() => {
                  setIg((n) => (n + 1) % FIGURES.length);
                  setRepG(null);
                }}
                className="rounded-lg bg-primary px-3 py-1.5 text-xs font-semibold text-primary-foreground"
              >
                Expression suivante ({ig + 1} / {FIGURES.length})
              </button>
            </div>
          ) : null}
        </div>
      )}

      <Citation auteur="pourquoi un correcteur repère une copie en trois lignes">
        Celle qui emploie « furieux », « catastrophique » et « extraordinaire » à chaque paragraphe
        se voit tout de suite, et pas en bien. Celle qui règle l'intensité — un mot faible ici, un
        mot fort là où il faut — donne l'impression d'un élève qui maîtrise sa langue. C'est souvent
        ce qui sépare le douze du quinze.
      </Citation>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* 3. Réécrire dans l'autre camp                                       */
/* ------------------------------------------------------------------ */

type MotBascule = {
  pro: string;
  neutre: string;
  contra: string;
  note: string;
};

type TexteBascule = {
  id: string;
  titre: string;
  source?: string;
  /** Les morceaux fixes, un de plus que les mots. */
  fixes: ReadonlyArray<string>;
  mots: ReadonlyArray<MotBascule>;
  tait: string;
};

const TEXTES_BASCULE: ReadonlyArray<TexteBascule> = [
  {
    id: "b1",
    titre: "La concession forestière",
    fixes: [
      "La société a entrepris ",
      " de la concession forestière. Les opérations, menées selon un plan ",
      ", permettront ",
      " de trois cents emplois.",
    ],
    mots: [
      {
        pro: "l'exploitation rationnelle",
        neutre: "l'abattage",
        contra: "le saccage",
        note: "« Rationnelle » oppose la raison au désordre : c'est un mot de progrès.",
      },
      {
        pro: "approuvé par l'administration",
        neutre: "d'aménagement",
        contra: "que personne n'a jamais vu",
        note: "« Approuvé » invoque l'autorité ; l'opposant, lui, met en doute son existence.",
      },
      {
        pro: "la création",
        neutre: "l'ouverture",
        contra: "la précarisation",
        note: "Même nombre d'emplois, trois jugements sur leur qualité.",
      },
    ],
    tait: "Regarde ce que la version favorable ne nomme PAS : ni les arbres, ni les villageois, ni les champs. Ce qu'un texte tait est aussi révélateur que ce qu'il dit.",
  },
  {
    id: "b2",
    titre: "Le ramassage des ordures",
    fixes: [
      "Des jeunes du quartier ont ",
      " les caniveaux. Cette ",
      " a permis ",
      " de la rue avant la saison des pluies.",
    ],
    mots: [
      {
        pro: "spontanément dégagé",
        neutre: "nettoyé",
        contra: "été contraints de dégager",
        note: "« Spontanément » fait un mérite de ce que « contraints » présente comme une injustice.",
      },
      {
        pro: "belle initiative citoyenne",
        neutre: "opération",
        contra: "corvée imposée par l'inaction de la commune",
        note: "Le même acte, selon qu'on félicite les habitants ou qu'on accuse la mairie.",
      },
      {
        pro: "l'assainissement",
        neutre: "le dégagement",
        contra: "d'éviter de justesse l'inondation",
        note: "Le troisième choix ajoute le danger évité, et accuse sans nommer personne.",
      },
    ],
    tait: "La version favorable ne dit nulle part pourquoi les caniveaux étaient bouchés. L'omission fait le travail à elle seule.",
  },
  {
    id: "b3",
    titre: "Le nouveau marché",
    source: "d'après la presse camerounaise",
    fixes: [
      "La commune a procédé à ",
      " des vendeurs installés sur le trottoir. ",
      " a été accueilli par ",
      " des commerçants concernés.",
    ],
    mots: [
      {
        pro: "la réorganisation",
        neutre: "au déplacement",
        contra: "l'expulsion",
        note: "Trois mots pour la même opération de police.",
      },
      {
        pro: "Ce réaménagement",
        neutre: "Cette décision",
        contra: "Cette mesure brutale",
        note: "L'adjectif seul suffit à faire basculer la phrase.",
      },
      {
        pro: "la compréhension",
        neutre: "les réactions",
        contra: "la colère",
        note: "Le mot choisi décide de ce que les commerçants ont ressenti.",
      },
    ],
    tait: "Aucune des trois versions ne dit où les vendeurs sont allés. C'est pourtant la seule question qui compte pour eux.",
  },
  {
    id: "b4",
    titre: "La campagne de reboisement",
    fixes: [
      "Le ministère a annoncé ",
      " de deux millions de plants. ",
      " sera suivie d'",
      " des sites concernés.",
    ],
    mots: [
      {
        pro: "la mise en terre",
        neutre: "la distribution",
        contra: "la dispersion sans suivi",
        note: "« Mise en terre » suggère un geste achevé ; « sans suivi » annonce l'échec.",
      },
      {
        pro: "Cette vaste opération",
        neutre: "Cette campagne",
        contra: "Cette cérémonie",
        note: "« Cérémonie » réduit l'action à sa photographie : c'est l'ironie du chapitre 14.",
      },
      {
        pro: "un entretien régulier",
        neutre: "une évaluation",
        contra: "un silence de trois ans",
        note: "Le troisième choix transforme une promesse en reproche anticipé.",
      },
    ],
    tait: "Aucune version ne donne le taux de survie à cinq ans. C'est précisément le chiffre que personne ne compte.",
  },
  {
    id: "b5",
    titre: "Les motos-taxis",
    fixes: [
      "Le conseil municipal étudie ",
      " des motos-taxis en centre-ville. ",
      " concerne ",
      " de jeunes conducteurs.",
    ],
    mots: [
      {
        pro: "l'encadrement",
        neutre: "la réglementation",
        contra: "l'interdiction pure et simple",
        note: "Entre « encadrer » et « interdire », il y a toute la distance d'un débat.",
      },
      {
        pro: "Cette mise en ordre",
        neutre: "Ce projet",
        contra: "Cette menace",
        note: "Le même texte de loi, vu de la mairie ou vu du guidon.",
      },
      {
        pro: "quelques centaines",
        neutre: "plusieurs milliers",
        contra: "des milliers de familles",
        note: "Le chiffre se choisit lui aussi : on peut compter les conducteurs ou compter les familles.",
      },
    ],
    tait: "Aucune version ne mentionne l'absence de transport public dans les quartiers périphériques — l'argument qui déplacerait tout le débat.",
  },
  {
    id: "b6",
    titre: "Les sacs plastiques",
    source: "d'après la presse camerounaise",
    fixes: ["L'État a décidé ", " des sachets. ", " vise ", " de nos villes."],
    mots: [
      {
        pro: "l'interdiction salutaire",
        neutre: "l'interdiction",
        contra: "la prohibition brutale",
        note: "Un seul adjectif, et le lecteur sait à qui il a affaire.",
      },
      {
        pro: "Cette mesure de salubrité",
        neutre: "Cette mesure",
        contra: "Cette décision prise sans concertation",
        note: "On ne conteste pas le fait, on conteste la manière.",
      },
      {
        pro: "l'assainissement durable",
        neutre: "le nettoyage",
        contra: "à punir les petits commerçants",
        note: "Le troisième choix change l'objectif de la loi : il lui prête une intention.",
      },
    ],
    tait: "Aucune version ne parle des importateurs. Interdire la détention ou interdire la production ne vise pas les mêmes personnes.",
  },
];

const TEXTE_BASCULE_VIDE: TexteBascule = {
  id: "",
  titre: "—",
  fixes: ["—"],
  mots: [],
  tait: "—",
};

type Camp = "pro" | "neutre" | "contra";

export function MotChoisi() {
  const [i, setI] = useState(0);
  const [camps, setCamps] = useState<Record<number, Camp>>({});
  const [ouvert, setOuvert] = useState<number | null>(null);
  const [compare, setCompare] = useState(false);

  const t = TEXTES_BASCULE[i] ?? TEXTE_BASCULE_VIDE;

  function rendre(camp: Camp) {
    return t.fixes
      .map((f, k) => {
        const m = t.mots[k];
        if (m === undefined) return f;
        return `${f}${m[camp]}`;
      })
      .join("");
  }

  const changes = t.mots.filter((_, k) => (camps[k] ?? "pro") !== "pro").length;

  return (
    <div className="space-y-3">
      <p className="text-sm text-muted-foreground">
        Chaque mot chargé est cliquable. Fais-le basculer d'un camp à l'autre et regarde le texte se
        réécrire : pas un seul fait ne change.
      </p>

      <div className="rounded-lg border border-border bg-background p-3">
        <p className="text-xs font-semibold text-foreground">
          {t.titre}
          {t.source ? (
            <span className="ml-1 font-normal text-muted-foreground">({t.source})</span>
          ) : null}
        </p>

        <p className="mt-2 text-base leading-7 text-foreground">
          {t.fixes.map((f, k) => {
            const m = t.mots[k];
            const camp = camps[k] ?? "pro";
            return (
              <span key={`${t.id}-${k}`}>
                {f}
                {m ? (
                  <button
                    type="button"
                    onClick={() => setOuvert(ouvert === k ? null : k)}
                    className="rounded px-1 font-semibold"
                    style={{
                      backgroundColor:
                        camp === "pro"
                          ? "rgba(21,128,61,0.14)"
                          : camp === "neutre"
                            ? "rgba(100,116,139,0.14)"
                            : "rgba(185,28,28,0.14)",
                      color: PALETTE.slate,
                    }}
                  >
                    {m[camp]}
                  </button>
                ) : null}
              </span>
            );
          })}
        </p>

        {ouvert !== null && t.mots[ouvert] ? (
          <div className="mt-3 rounded-md border border-border/60 p-2.5">
            <Choice<Camp>
              label="Ce mot, vu de…"
              value={camps[ouvert] ?? "pro"}
              options={[
                { value: "pro", label: "celui qui défend" },
                { value: "neutre", label: "le technicien" },
                { value: "contra", label: "celui qui dénonce" },
              ]}
              onChange={(v) => setCamps((c) => ({ ...c, [ouvert]: v }))}
            />
            <p className="mt-2 text-xs text-muted-foreground">{t.mots[ouvert]?.note ?? ""}</p>
          </div>
        ) : null}

        <div className="mt-3 flex flex-wrap gap-2">
          <button
            type="button"
            onClick={() => {
              const tous: Record<number, Camp> = {};
              t.mots.forEach((_, k) => {
                tous[k] = "contra";
              });
              setCamps(tous);
            }}
            className="rounded-lg border border-border px-3 py-1.5 text-xs font-semibold text-foreground"
          >
            Tout faire basculer
          </button>
          <button
            type="button"
            onClick={() => setCompare((c) => !c)}
            className="rounded-lg border border-border px-3 py-1.5 text-xs font-semibold text-foreground"
          >
            {compare ? "Masquer la comparaison" : "Comparer les deux versions"}
          </button>
          <button
            type="button"
            onClick={() => {
              setI((n) => (n + 1) % TEXTES_BASCULE.length);
              setCamps({});
              setOuvert(null);
              setCompare(false);
            }}
            className="rounded-lg bg-primary px-3 py-1.5 text-xs font-semibold text-primary-foreground"
          >
            Texte suivant ({i + 1} / {TEXTES_BASCULE.length})
          </button>
        </div>

        {compare ? (
          <div className="mt-3 grid gap-2 sm:grid-cols-2">
            <div
              className="rounded-md px-2.5 py-2"
              style={{ backgroundColor: "rgba(21,128,61,0.08)" }}
            >
              <p className="text-[11px] font-semibold" style={{ color: PALETTE.green }}>
                la version de celui qui défend
              </p>
              <p className="mt-1 text-xs text-foreground">{rendre("pro")}</p>
            </div>
            <div
              className="rounded-md px-2.5 py-2"
              style={{ backgroundColor: "rgba(185,28,28,0.08)" }}
            >
              <p className="text-[11px] font-semibold" style={{ color: PALETTE.red }}>
                la version de celui qui dénonce
              </p>
              <p className="mt-1 text-xs text-foreground">{rendre("contra")}</p>
            </div>
          </div>
        ) : null}

        <p className="mt-3 text-[11px] text-muted-foreground">
          Mots changés : {changes} sur {t.mots.length}. Pas un seul fait n'a bougé.
        </p>

        <p
          className="mt-2 rounded-md px-2 py-1.5 text-xs"
          style={{ backgroundColor: "rgba(202,138,4,0.12)", color: "#78350f" }}
        >
          <span className="font-semibold">Ce que le texte tait. </span>
          {t.tait}
        </p>
      </div>

      <Citation auteur="et aucune des deux versions ne ment exactement">
        C'est précisément ce que ce chapitre t'apprend à voir. Avant de lire un texte argumentatif,
        regarde quels mots l'auteur a choisis : il a déjà pris parti, et il l'a fait avant son
        premier argument.
      </Citation>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* 4. Trier thèse, arguments et exemples                               */
/* ------------------------------------------------------------------ */

const MORCEAUX: ReadonlyArray<ItemTri> = [
  {
    id: "ta1",
    texte: "Il faut interdire les sacs plastiques.",
    bonne: "these",
    pourquoi: "C'est l'opinion que l'auteur veut faire admettre. Une seule par texte, en général.",
  },
  {
    id: "ta2",
    texte: "Ils mettent des siècles à se dégrader.",
    bonne: "argument",
    pourquoi:
      "Général, abstrait, vrai partout : aucune date, aucun lieu, aucun nom propre. C'est un argument.",
  },
  {
    id: "ta3",
    texte:
      "À Douala, lors des inondations de septembre, les services ont retiré douze tonnes de sachets des caniveaux de Bonabéri.",
    bonne: "exemple",
    pourquoi:
      "Une ville, un mois, un chiffre, un quartier. Dès qu'apparaissent un nom propre, une date ou un chiffre, tu es devant un exemple.",
  },
  {
    id: "ta4",
    texte: "Le reboisement camerounais échoue faute de suivi.",
    bonne: "these",
    pourquoi: "L'opinion défendue par tout le texte, et vers laquelle il tend.",
  },
  {
    id: "ta5",
    texte: "Planter ne suffit pas : il faut arroser pendant trois saisons.",
    bonne: "argument",
    pourquoi: "Une vérité générale sur le reboisement, valable partout.",
  },
  {
    id: "ta6",
    texte:
      "Sur mille deux cents plants distribués à Ngaoundéré en 2019, neuf cents étaient debout en 2022.",
    bonne: "exemple",
    pourquoi: "Ville, dates, chiffres : l'exemple est complet.",
  },
  {
    id: "ta7",
    texte: "Le ramassage des ordures est un service public financé par l'impôt.",
    bonne: "argument",
    pourquoi: "Un principe général, qui vaut pour toutes les communes.",
  },
  {
    id: "ta8",
    texte: "Le bac de notre carrefour a été retiré en janvier et jamais remplacé.",
    bonne: "exemple",
    pourquoi: "Un lieu, un mois, un fait vérifiable.",
  },
  {
    id: "ta9",
    texte: "La responsabilité des ordures incombe d'abord à la commune.",
    bonne: "these",
    pourquoi:
      "C'est la position de l'auteur. Attention : une thèse n'est pas toujours annoncée par « je pense que » ; il faut souvent la reconstituer.",
  },
  {
    id: "ta10",
    texte: "Un sac plastique met quatre cents ans à disparaître.",
    bonne: "argument",
    pourquoi:
      "Il y a bien un chiffre, et pourtant c'est un argument : la donnée est générale, vraie partout, et n'est rattachée à aucun lieu ni à aucune date.",
  },
  {
    id: "ta11",
    texte: "Celui que tu as jeté hier sera encore là quand ton arrière-petit-fils naîtra.",
    bonne: "exemple",
    pourquoi:
      "Le piège du cours : la phrase est concrète, mais elle ne rapporte aucun fait réel. C'est un exemple FICTIF, une illustration — et c'est un procédé de persuasion, pas de preuve.",
  },
  {
    id: "ta12",
    texte: "Interdire sans proposer de solution de remplacement frappe les plus pauvres.",
    bonne: "argument",
    pourquoi: "Un raisonnement général sur l'effet des interdictions.",
  },
  {
    id: "ta13",
    texte:
      "Une association de Bonabéri tient un registre de ses sorties et l'envoie chaque trimestre à la mairie.",
    bonne: "exemple",
    pourquoi: "Un quartier, une pratique précise, une périodicité. C'est un exemple.",
  },
  {
    id: "ta14",
    texte: "L'école doit commencer dans la langue que l'enfant comprend.",
    bonne: "these",
    pourquoi: "Une opinion à défendre, formulable en une phrase.",
  },
  {
    id: "ta15",
    texte: "Un enfant apprend plus vite dans la langue qu'il parle à la maison.",
    bonne: "argument",
    pourquoi: "Un principe pédagogique général.",
  },
  {
    id: "ta16",
    texte: "Le Cameroun compte plus de deux cents langues nationales.",
    bonne: "exemple",
    pourquoi:
      "Un pays nommé et un chiffre : c'est un fait particulier, mobilisé pour appuyer un raisonnement.",
  },
];

export function TrierArgumentation() {
  return (
    <JeuTri
      consigne="Range chaque morceau dans son panier. Le test : un argument est général, un exemple est particulier — et dès qu'un nom propre, une date ou un chiffre apparaît, tu es presque toujours devant un exemple."
      categories={[
        { value: "these", label: "thèse", aide: "l'opinion que l'auteur veut faire admettre" },
        { value: "argument", label: "argument", aide: "une raison, générale et abstraite" },
        { value: "exemple", label: "exemple", aide: "un cas précis, daté, situé, chiffré" },
      ]}
      items={MORCEAUX}
      conclusion={
        <Citation auteur="l'erreur numéro un de l'épreuve">
          Confondre argument et exemple coûte des points à chaque session. Et il y avait deux pièges
          dans cette série : un argument qui contient un chiffre général, et un exemple qui n'est
          pas réel mais imaginé. Si tu les as repérés, la question 3 du BEPC ne te prendra plus
          trente secondes.
        </Citation>
      }
    />
  );
}

/* ------------------------------------------------------------------ */
/* 5. Nommer les procédés                                              */
/* ------------------------------------------------------------------ */

type Procede =
  | "concession"
  | "question"
  | "analogie"
  | "absurde"
  | "autorite"
  | "ironie"
  | "exemple";

const NOM_PROCEDE: Record<Procede, string> = {
  concession: "concession",
  question: "question rhétorique",
  analogie: "analogie ou métaphore",
  absurde: "raisonnement par l'absurde",
  autorite: "appel à l'autorité",
  ironie: "ironie",
  exemple: "exemple",
};

type PassageProcede = {
  id: string;
  passage: string;
  bon: Procede;
  signal: string;
  effet: string;
};

const PASSAGES: ReadonlyArray<PassageProcede> = [
  {
    id: "p1",
    passage:
      "Certes, le pays a besoin de devises, et le bois en rapporte ; mais faut-il vendre la maison pour payer le repas ?",
    bon: "concession",
    signal: "Le mot « certes », suivi d'un « mais ».",
    effet:
      "L'auteur reconnaît un point à l'adversaire avant de le réfuter. Le lecteur se sent entendu et baisse sa garde — c'est le procédé que les élèves n'emploient jamais et qui rapporte le plus.",
  },
  {
    id: "p2",
    passage: "Faut-il vendre la maison pour payer le repas ?",
    bon: "question",
    signal: "Un point d'interrogation, mais aucune réponse attendue.",
    effet:
      "L'auteur impose sa réponse en faisant croire au lecteur qu'il décide lui-même. Et il y glisse une comparaison qui rend l'absurdité sensible en six mots.",
  },
  {
    id: "p3",
    passage:
      "Un pays sans forêt est un corps sans poumon : il respire encore un moment, puis il s'arrête.",
    bon: "analogie",
    signal: "Un rapprochement entre deux réalités différentes, ici prolongé.",
    effet:
      "L'auteur ne se contente pas du rapprochement : il le file. C'est le procédé le plus visuel de l'argumentation, et ce qui se voit convainc mieux que ce qui se démontre.",
  },
  {
    id: "p4",
    passage:
      "Admettons que nous continuions au rythme actuel. En 2050, il ne restera que des souches.",
    bon: "absurde",
    signal: "« Admettons que », suivi d'une conséquence intenable.",
    effet: "L'auteur suppose le contraire de ce qu'il souhaite, et montre où cela mène.",
  },
  {
    id: "p5",
    passage: "Selon les services des eaux et forêts, le rythme actuel est insoutenable.",
    bon: "autorite",
    signal: "Une source invoquée pour emporter l'adhésion.",
    effet:
      "Procédé logiquement faible : qu'une institution ait dit une chose n'en fait pas une vérité. Note aussi que la source est nommée sans être vérifiable — un lecteur averti le remarque.",
  },
  {
    id: "p6",
    passage: "Quelle belle réussite nous laisserons à nos enfants.",
    bon: "ironie",
    signal: "L'écart entre « belle réussite » et ce qui précède — des souches.",
    effet:
      "L'auteur dit le contraire de ce qu'il pense. Procédé dangereux : si le lecteur le prend au premier degré, tout s'effondre. Il demande un signal.",
  },
  {
    id: "p7",
    passage:
      "À Ngaoundéré, neuf cents plants sur mille deux cents étaient encore debout trois ans après.",
    bon: "exemple",
    signal: "Une ville, des chiffres, une durée.",
    effet: "Il ancre l'argument dans le réel, et c'est ce qui le rend difficile à contester.",
  },
  {
    id: "p8",
    passage:
      "Il est vrai que l'interdiction gênera les petits commerçants. Toutefois, peut-on leur demander de payer la facture des inondations ?",
    bon: "concession",
    signal: "« Il est vrai que », suivi de « toutefois ».",
    effet:
      "Même mécanique que « certes… mais », avec d'autres mots. Un texte qui ne concède jamais paraît aveugle.",
  },
  {
    id: "p9",
    passage: "Faut-il attendre qu'un enfant se noie dans un caniveau bouché pour agir ?",
    bon: "question",
    signal: "Une question dont la réponse est imposée, et bouleversante.",
    effet:
      "L'auteur choisit l'image la plus forte possible. C'est de la persuasion — il s'adresse aux sentiments, non à la raison.",
  },
  {
    id: "p10",
    passage: "Nos villes étouffent.",
    bon: "analogie",
    signal: "La ville reçoit un corps et une respiration.",
    effet:
      "Métaphore d'ouverture. Convaincre aurait consisté à aligner les chiffres des services techniques ; persuader consiste à faire étouffer le lecteur avec la ville.",
  },
  {
    id: "p11",
    passage:
      "Supposons que personne ne ramasse plus rien. Dans six mois, la ville serait un marécage.",
    bon: "absurde",
    signal: "« Supposons que », suivi d'une conséquence inacceptable.",
    effet: "L'hypothèse est poussée jusqu'à son terme pour rendre la thèse inévitable.",
  },
  {
    id: "p12",
    passage: "Comme le disait Nelson Mandela, l'éducation est l'arme la plus puissante.",
    bon: "autorite",
    signal: "Une citation d'une figure respectée.",
    effet:
      "Sache le repérer, et sache t'en méfier : l'autorité de celui qui parle ne remplace pas la preuve.",
  },
  {
    id: "p13",
    passage: "Bravo à la commune, dont le camion passe si régulièrement — une fois par mois.",
    bon: "ironie",
    signal: "Le « si régulièrement » démenti par le tiret qui suit.",
    effet:
      "Le signal est dans la contradiction interne de la phrase. Sans ce tiret, le lecteur pourrait s'y tromper.",
  },
  {
    id: "p14",
    passage: "Une ville sans caniveaux est un corps sans veines.",
    bon: "analogie",
    signal: "Comparaison entre la ville et le corps.",
    effet: "Elle éclaire la première réalité par la seconde, mieux connue du lecteur.",
  },
];

const PASSAGE_VIDE: PassageProcede = {
  id: "",
  passage: "—",
  bon: "concession",
  signal: "—",
  effet: "—",
};

type SujetConcession = {
  id: string;
  these: string;
  objection: string;
  modele: string;
};

const CONCESSIONS: ReadonlyArray<SujetConcession> = [
  {
    id: "co1",
    these: "Il faut interdire les sacs plastiques.",
    objection: "Les petits commerçants n'ont pas les moyens d'acheter des emballages en papier.",
    modele:
      "Certes, l'interdiction frappera d'abord les petits commerçants, qui n'ont pas les moyens d'acheter des emballages en papier. Mais faut-il préférer un marché bon marché à une ville vivable ?",
  },
  {
    id: "co2",
    these: "Les réseaux sociaux éloignent les jeunes de leur famille.",
    objection: "Certains adolescents partagent en famille ce qu'ils découvrent en ligne.",
    modele:
      "Certes, un adolescent peut aussi partager en famille ce qu'il découvre en ligne, et quelques-uns le font. Mais ces échanges-là durent cinq minutes, quand l'écran en occupe trois heures.",
  },
  {
    id: "co3",
    these: "L'école doit commencer dans la langue maternelle.",
    objection: "Le pays compte plus de deux cents langues : c'est matériellement impossible.",
    modele:
      "Il est vrai que notre pays compte plus de deux cents langues, et qu'on ne saurait imprimer des manuels dans chacune. Toutefois, enseigner dans les quelques langues véhiculaires d'une région n'exige ni deux cents manuels ni deux cents programmes.",
  },
  {
    id: "co4",
    these: "Il faut interdire les motos-taxis en centre-ville.",
    objection: "Elles font vivre des milliers de jeunes.",
    modele:
      "On ne peut nier que les motos-taxis font vivre des milliers de jeunes, et qu'une interdiction les priverait de leur revenu du jour au lendemain. Mais faut-il attendre que les accidents les privent de leur santé ?",
  },
  {
    id: "co5",
    these: "Les habitants doivent écrire à la commune plutôt que ramasser eux-mêmes.",
    objection: "On ne peut pas laisser pourrir les rues en attendant une réponse.",
    modele:
      "Certes, on ne peut pas demander à des habitants de laisser pourrir leurs rues pour faire la preuve d'un manquement ; ce serait punir les enfants du quartier pour forcer la main d'une mairie. Mais rien n'empêche de ramasser ET d'écrire, en joignant à la lettre la liste de ce qu'on a fait à sa place.",
  },
];

const CONCESSION_VIDE: SujetConcession = {
  id: "",
  these: "—",
  objection: "—",
  modele: "—",
};

export function ProcederArgumentation() {
  const [atelier, setAtelier] = useState<"nommer" | "construire">("nommer");
  const [i, setI] = useState(0);
  const [rep, setRep] = useState<Procede | null>(null);
  const [ic, setIc] = useState(0);
  const [saisie, setSaisie] = useState("");
  const [montreModele, setMontreModele] = useState(false);

  const p = PASSAGES[i] ?? PASSAGE_VIDE;
  const c = CONCESSIONS[ic] ?? CONCESSION_VIDE;

  const aCertes = /\b(certes|il est vrai que|on ne peut nier)/i.test(saisie);
  const aMais = /\b(mais|toutefois|cependant|néanmoins|pourtant)/i.test(saisie);

  return (
    <div className="space-y-3">
      <div>
        <Choice<"nommer" | "construire">
          label="Atelier"
          value={atelier}
          options={[
            { value: "nommer", label: "nommer les procédés" },
            { value: "construire", label: "construire une concession" },
          ]}
          onChange={setAtelier}
        />
      </div>

      {atelier === "nommer" ? (
        <div className="rounded-lg border border-border bg-background p-3">
          <p className="text-base italic text-foreground">« {p.passage} »</p>

          <div className="mt-3 flex flex-wrap gap-1.5">
            {(Object.keys(NOM_PROCEDE) as ReadonlyArray<Procede>).map((k) => (
              <button
                key={k}
                type="button"
                disabled={rep !== null}
                onClick={() => setRep(k)}
                className="rounded-md border px-2.5 py-1 text-xs"
                style={{
                  borderColor:
                    rep !== null && k === p.bon ? PALETTE.green : "rgba(100,116,139,0.3)",
                  backgroundColor:
                    rep !== null && k === p.bon
                      ? "rgba(21,128,61,0.10)"
                      : rep === k
                        ? "rgba(185,28,28,0.10)"
                        : "transparent",
                }}
              >
                {NOM_PROCEDE[k]}
              </button>
            ))}
          </div>

          {rep !== null ? (
            <div className="mt-3 space-y-2">
              <Verdict tone={rep === p.bon ? "ok" : "bad"}>
                <span className="font-semibold">
                  {NOM_PROCEDE[p.bon]} — le signal : {p.signal}{" "}
                </span>
                {p.effet}
              </Verdict>
              <button
                type="button"
                onClick={() => {
                  setI((n) => (n + 1) % PASSAGES.length);
                  setRep(null);
                }}
                className="rounded-lg bg-primary px-3 py-1.5 text-xs font-semibold text-primary-foreground"
              >
                Passage suivant ({i + 1} / {PASSAGES.length})
              </button>
            </div>
          ) : null}
        </div>
      ) : (
        <div className="rounded-lg border border-border bg-background p-3">
          <p className="text-xs font-semibold text-foreground">Ta thèse</p>
          <p className="text-sm text-foreground">{c.these}</p>
          <p className="mt-2 text-xs font-semibold text-foreground">L'objection de l'adversaire</p>
          <p className="text-sm text-foreground">{c.objection}</p>

          <p className="mt-3 text-[11px] text-muted-foreground">
            Écris la concession : reconnais l'objection, puis réfute-la. Moule : certes… mais.
          </p>
          <textarea
            value={saisie}
            onChange={(e) => setSaisie(e.target.value)}
            rows={4}
            className="mt-1 w-full rounded-md border border-border bg-background px-2.5 py-1.5 text-sm text-foreground"
            placeholder="Certes, … Mais …"
          />

          <div className="mt-2 flex flex-wrap gap-2 text-[11px]">
            <span
              className="rounded px-2 py-0.5"
              style={{
                backgroundColor: aCertes ? "rgba(21,128,61,0.12)" : "rgba(100,116,139,0.12)",
                color: aCertes ? PALETTE.green : PALETTE.slate,
              }}
            >
              {aCertes ? "la reconnaissance y est" : "il manque le « certes »"}
            </span>
            <span
              className="rounded px-2 py-0.5"
              style={{
                backgroundColor: aMais ? "rgba(21,128,61,0.12)" : "rgba(100,116,139,0.12)",
                color: aMais ? PALETTE.green : PALETTE.slate,
              }}
            >
              {aMais ? "la réfutation y est" : "il manque le « mais »"}
            </span>
          </div>

          <div className="mt-2 flex flex-wrap gap-2">
            <button
              type="button"
              onClick={() => setMontreModele(true)}
              className="rounded-lg border border-border px-3 py-1.5 text-xs font-semibold text-foreground"
            >
              Voir un modèle
            </button>
            <button
              type="button"
              onClick={() => {
                setIc((n) => (n + 1) % CONCESSIONS.length);
                setSaisie("");
                setMontreModele(false);
              }}
              className="rounded-lg bg-primary px-3 py-1.5 text-xs font-semibold text-primary-foreground"
            >
              Sujet suivant ({ic + 1} / {CONCESSIONS.length})
            </button>
          </div>

          {montreModele ? (
            <div className="mt-2">
              <Verdict tone="ok">
                <span className="font-semibold">Un modèle possible. </span>
                {c.modele}
              </Verdict>
            </div>
          ) : null}
        </div>
      )}

      <Citation auteur="si tu n'en retiens qu'un">
        Place une concession dans ta rédaction de BEPC, une seule, au début de ton troisième
        paragraphe. Le correcteur la verra, et elle lui dira que tu as pensé à l'objection avant
        qu'il n'ait eu le temps de la formuler.
      </Citation>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* 6. La lecture en cinq étapes                                        */
/* ------------------------------------------------------------------ */

const ETAPES_LECTURE: ReadonlyArray<Etape> = [
  {
    titre: "Étape 1 — Le paratexte, avant d'avoir lu une ligne",
    question:
      "Tu as sous les yeux : « Jean-Baptiste Mbarga, La ville et ses déchets, Le Quotidien de Yaoundé, 12 mars 2023 ». Que t'apprend cet encadré ?",
    options: [
      {
        texte:
          "Un article de presse signé, récent, destiné à un lectorat urbain camerounais — et l'auteur n'est pas un fonctionnaire.",
        bonne: true,
        retour:
          "Exactement. Et retiens ceci : « à qui ce texte s'adresse-t-il ? » est une question d'examen, et c'est la source qui y répond.",
      },
      {
        texte: "Rien d'utile : seul le texte compte.",
        bonne: false,
        retour:
          "Un texte tiré d'un journal militant ne se lit pas comme un rapport administratif, et un texte de 1960 ne parle pas du même pays qu'un texte de 2023.",
      },
      {
        texte: "Que le texte est un récit.",
        bonne: false,
        retour:
          "Rien dans le paratexte ne l'indique. Un article de presse est le plus souvent argumentatif.",
      },
    ],
  },
  {
    titre: "Étape 2 — Première lecture, sans stylo",
    question:
      "Tu viens de lire le texte une fois. L'auteur y affirme que les habitants n'ont nulle part où jeter, que le ramassage est déjà payé par l'impôt, et il réclame que le camion passe. Quelle est la thèse ?",
    options: [
      {
        texte: "La responsabilité des ordures incombe d'abord à la commune, et non aux habitants.",
        bonne: true,
        retour:
          "C'est cela, et tu as pu la formuler en une phrase : c'est le signe que la première lecture a fait son travail.",
      },
      {
        texte: "Les habitants sont sales.",
        bonne: false,
        retour: "C'est l'accusation que l'auteur conteste, dès sa deuxième phrase.",
      },
      {
        texte: "Le texte parle de l'environnement.",
        bonne: false,
        retour:
          "C'est le thème, pas la thèse — et formulé trop largement. Un correcteur n'accorde que la moitié du point pour une réponse de ce genre.",
      },
    ],
  },
  {
    titre: "Étape 3 — Deuxième lecture, le stylo à la main",
    question: "Tu annotes. Que cherches-tu en priorité ?",
    options: [
      {
        texte:
          "Les connecteurs logiques, les mots chargés, les marques de l'énonciation, les procédés.",
        bonne: true,
        retour:
          "Les quatre, et dans cet ordre. Les connecteurs dessinent le plan, et le plan est la moitié de l'analyse.",
      },
      {
        texte: "Les mots que je ne comprends pas.",
        bonne: false,
        retour:
          "Utile, mais secondaire : la question 1 de la partie II portera peut-être sur l'un d'eux, et le contexte suffira souvent à le deviner.",
      },
      {
        texte: "Les fautes d'orthographe du texte.",
        bonne: false,
        retour: "Le texte d'examen est relu. Ce n'est pas lui qu'on te demande de corriger.",
      },
    ],
  },
  {
    titre: "Étape 4 — Reconstituer le plan au brouillon",
    question:
      "Le texte enchaîne : « D'abord », puis un chiffre — six bacs pour quarante mille habitants —, puis « Ensuite », puis « Certes… Mais », puis « En somme ». Que vaut ce relevé ?",
    options: [
      {
        texte:
          "Il donne le plan complet : deux arguments, un exemple chiffré, une concession réfutée, une conclusion.",
        bonne: true,
        retour:
          "Cinq lignes de brouillon, et tu peux répondre à presque toutes les questions. C'est le meilleur quart d'heure de l'épreuve.",
      },
      {
        texte: "Rien : ce sont de simples mots de liaison.",
        bonne: false,
        retour:
          "Ce sont les paragraphes du texte, rendus visibles. Les relever est le geste le plus rentable de l'exercice, parce qu'ils se voient.",
      },
      {
        texte: "Il prouve que le texte est narratif.",
        bonne: false,
        retour:
          "« Certes… mais » et « en somme » n'appartiennent pas au récit : ce sont des connecteurs d'argumentation.",
      },
    ],
  },
  {
    titre: "Étape 5 — Répondre, avec les citations",
    question:
      "On te demande quel argument l'auteur oppose à ceux qui accusent les habitants. Laquelle de ces réponses vaut les deux points ?",
    options: [
      {
        texte:
          "« L'auteur répond que les habitants n'ont nulle part où jeter. Il le prouve par un chiffre : la commune a installé six bacs pour quarante mille habitants, et le camion passe une fois par semaine “quand il passe” (l. 4). La restriction finale souligne que même ce service minimal n'est pas assuré. »",
        bonne: true,
        retour:
          "Elle donne l'idée, elle cite entre guillemets avec la ligne, et elle commente un détail de la citation. C'est le modèle à reproduire.",
      },
      {
        texte: "« L'auteur pense que c'est la faute de la commune. »",
        bonne: false,
        retour:
          "L'idée est juste et vaut un point. L'autre point est perdu, faute de citation — et cela à chaque question, à chaque session.",
      },
      {
        texte: "L'élève recopie les trois premières lignes du texte.",
        bonne: false,
        retour:
          "Recopier n'est pas citer. Une citation est courte, entre guillemets, et choisie pour ce qu'elle prouve.",
      },
    ],
  },
];

export function LectureArgumentative() {
  return (
    <Parcours
      consigne="Les cinq étapes de l'épreuve, dans l'ordre. Elles conviennent à n'importe quel texte argumentatif, et elles tiennent en vingt minutes."
      etapes={ETAPES_LECTURE}
      fin={
        <Citation auteur="le barème qui explique tout">
          Un point pour l'idée, un point pour la citation. C'est la règle qui explique pourquoi un
          élève qui a parfaitement compris peut n'avoir que la moitié de la note — à chaque
          question, à chaque session.
        </Citation>
      }
    />
  );
}
