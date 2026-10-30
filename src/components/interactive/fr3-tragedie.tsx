import { useState } from "react";
import { PALETTE, Choice, Ctrl, Verdict } from "./controls";
import { Citation, JeuTri, Parcours, type Etape, type ItemTri } from "./philo-noyau";
import { Surligner, type Releve } from "./fr3-noyau";

/** Français 3ème — chapitres 21 et 22 : modalisation, tragédie classique. */

/* ------------------------------------------------------------------ */
/* 1. Relever les modalisateurs                                        */
/* ------------------------------------------------------------------ */

const RELEVES_MODAL: ReadonlyArray<Releve> = [
  {
    id: "rm1",
    consigne:
      "Relève les marques de la subjectivité de l'auteur. Attention : tous les adverbes ne modalisent pas.",
    jetons: [
      { mot: "Le" },
      { mot: "camion" },
      { mot: "est" },
      {
        mot: "enfin",
        bon: true,
        pourquoi: "Adverbe de jugement : il ne dit pas quand, il dit que c'était trop tard.",
      },
      { mot: "passé" },
      { mot: "mardi," },
      { mot: "après" },
      { mot: "six" },
      { mot: "semaines" },
      { mot: "d'attente." },
      { mot: "Il" },
      { mot: "roulait" },
      {
        mot: "vite",
        pourquoi:
          "Piège : « vite » porte sur le FAIT — la manière de rouler — et non sur l'adhésion du locuteur. Ce n'est pas un modalisateur.",
      },
      { mot: "et" },
      { mot: "n'a" },
      { mot: "pas" },
      { mot: "ralenti." },
    ],
    combien: 0,
    bilan:
      "Un seul modalisateur. Le test : si l'adverbe porte sur le fait, ce n'en est pas un ; s'il porte sur ce que le locuteur en pense, c'en est un.",
  },
  {
    id: "rm2",
    consigne: "Relève les modalisateurs de certitude et d'incertitude.",
    jetons: [
      { mot: "Les" },
      { mot: "services" },
      {
        mot: "auraient",
        bon: true,
        pourquoi:
          "Conditionnel de l'information non confirmée : le journaliste rapporte sans garantir.",
      },
      { mot: "procédé," },
      { mot: "nous" },
      {
        mot: "dit-on,",
        bon: true,
        pourquoi: "Incise qui désigne une source anonyme. Elle redouble le conditionnel.",
      },
      { mot: "à" },
      { mot: "une" },
      { mot: "réorganisation" },
      { mot: "des" },
      { mot: "tournées." },
    ],
    combien: 0,
    bilan:
      "Le conditionnel est le modalisateur le plus employé par la presse, et le plus honnête : il dit « je rapporte, je ne garantis pas ».",
  },
  {
    id: "rm3",
    consigne: "Relève les marques de jugement.",
    jetons: [
      {
        mot: "Curieusement,",
        bon: true,
        pourquoi: "Adverbe de jugement, qui signale une anomalie sans accuser directement.",
      },
      { mot: "cette" },
      { mot: "réorganisation" },
      { mot: "n'a" },
      { mot: "été" },
      { mot: "annoncée" },
      { mot: "nulle", bon: true, pourquoi: "« Nulle part » renforce le reproche par l'absolu." },
      { mot: "part." },
    ],
    combien: 0,
    bilan:
      "L'auteur n'accuse personne : il laisse le lecteur conclure. C'est souvent plus efficace qu'une accusation directe.",
  },
  {
    id: "rm4",
    consigne: "Relève les verbes modaux — ceux que les élèves oublient le plus.",
    jetons: [
      { mot: "Il" },
      {
        mot: "doit",
        bon: true,
        pourquoi: "Verbe modal : « il doit y avoir » n'est pas « il y a ». C'est une supposition.",
      },
      { mot: "y" },
      { mot: "avoir" },
      { mot: "six" },
      { mot: "bacs," },
      { mot: "mais" },
      { mot: "il" },
      { mot: "semble", bon: true, pourquoi: "Verbe modal d'incertitude." },
      { mot: "que" },
      { mot: "deux" },
      { mot: "aient" },
      { mot: "disparu." },
    ],
    combien: 0,
    bilan:
      "Les verbes modaux — devoir, pouvoir, falloir, sembler, paraître — sont la famille la plus oubliée au relevé. Pense à eux après les adverbes.",
  },
  {
    id: "rm5",
    consigne: "Relève le vocabulaire évaluatif.",
    jetons: [
      { mot: "Les" },
      { mot: "habitants" },
      { mot: "ont" },
      {
        mot: "accompli",
        bon: true,
        pourquoi: "Verbe appréciatif : accomplir suppose une tâche menée à son terme.",
      },
      { mot: "un" },
      { mot: "travail" },
      { mot: "modeste", bon: true, pourquoi: "Adjectif appréciatif : ici, éloge de la mesure." },
      { mot: "mais" },
      { mot: "solide,", bon: true, pourquoi: "Adjectif appréciatif." },
      { mot: "quand" },
      { mot: "la" },
      { mot: "commune" },
      {
        mot: "multipliait",
        bon: true,
        pourquoi: "Verbe dépréciatif : il suggère la quantité sans la qualité.",
      },
      { mot: "les" },
      { mot: "promesses" },
      { mot: "creuses.", bon: true, pourquoi: "Adjectif dépréciatif." },
    ],
    combien: 0,
    bilan:
      "Le texte oppose deux camps par le vocabulaire : aux habitants les verbes d'action, à la commune les noms de l'apparence.",
  },
  {
    id: "rm6",
    consigne: "Relève les marques typographiques de subjectivité.",
    jetons: [
      { mot: "Le" },
      { mot: "dernier" },
      { mot: "communiqué" },
      { mot: "annonce" },
      { mot: "une" },
      {
        mot: "«",
        bon: true,
        pourquoi:
          "Guillemets de distance : l'auteur reprend le mot de l'administration et refuse de le prendre à son compte.",
      },
      { mot: "reprise" },
      { mot: "prochaine" },
      { mot: "»", bon: true, pourquoi: "Le guillemet fermant, qui clôt la mise à distance." },
      { mot: "des" },
      { mot: "tournées" },
      {
        mot: "!",
        bon: true,
        pourquoi: "Point d'exclamation : marque d'indignation, ici ironique.",
      },
    ],
    combien: 0,
    bilan:
      "Les guillemets de distance ne citent personne : ils disent « je n'y crois pas ». C'est la marque que les élèves relèvent le moins, et l'une des plus révélatrices.",
  },
  {
    id: "rm7",
    consigne: "Relève les suffixes porteurs de jugement.",
    jetons: [
      { mot: "Un" },
      { mot: "chauffard", bon: true, pourquoi: "Suffixe péjoratif -ard." },
      { mot: "a" },
      { mot: "renversé" },
      { mot: "les" },
      { mot: "quelques" },
      {
        mot: "plantillons",
        bon: true,
        pourquoi: "Diminutif -illon : il minimise, et dit que ce n'est pas sérieux.",
      },
      { mot: "mis" },
      { mot: "en" },
      { mot: "terre" },
      { mot: "le" },
      { mot: "mois" },
      { mot: "dernier." },
    ],
    combien: 0,
    bilan:
      "Les suffixes péjoratifs — -ard, -asse, -âtre, -aille — et les diminutifs sont petits, très efficaces, et presque jamais relevés par les élèves.",
  },
  {
    id: "rm8",
    consigne:
      "Relève TOUTES les marques, en quatre passes : adverbes, vocabulaire, modes, typographie.",
    jetons: [
      { mot: "Les" },
      { mot: "habitants," },
      { mot: "qui" },
      { mot: "ont" },
      {
        mot: "dû",
        bon: true,
        pourquoi: "Verbe modal « devoir » au sens d'obligation subie : ils n'ont pas choisi.",
      },
      { mot: "ramasser" },
      { mot: "eux-mêmes" },
      { mot: "leurs" },
      { mot: "ordures," },
      {
        mot: "apprécieront",
        bon: true,
        pourquoi: "Futur employé ironiquement : personne n'appréciera.",
      },
      { mot: "sans" },
      {
        mot: "doute",
        bon: true,
        pourquoi:
          "« Sans doute » est un modalisateur de certitude MOYENNE : il signifie « probablement ».",
      },
      { mot: "ce" },
      {
        mot: "bel",
        bon: true,
        pourquoi:
          "Adjectif appréciatif employé ironiquement, donc dépréciatif de sens. C'est la marque la plus forte du passage.",
      },
      { mot: "effort" },
      { mot: "de" },
      { mot: "communication." },
    ],
    combien: 0,
    bilan:
      "Quatre marques en une phrase. L'auteur ne dit jamais « la mairie a mal fait son travail » : il le fait entendre. C'est une critique d'autant plus efficace qu'elle paraît n'en être pas une.",
  },
  {
    id: "rm9",
    consigne:
      "Relève les modalisateurs. Deux pièges : un adverbe qui ne modalise pas, un verbe ordinaire.",
    jetons: [
      { mot: "Heureusement,", bon: true, pourquoi: "Adverbe de jugement : l'auteur approuve." },
      { mot: "le" },
      { mot: "pont" },
      { mot: "a" },
      { mot: "tenu." },
      { mot: "L'eau" },
      { mot: "montait" },
      {
        mot: "lentement",
        pourquoi:
          "Piège : « lentement » décrit la manière dont l'eau montait. Ce n'est pas un modalisateur.",
      },
      { mot: "et" },
      { mot: "les" },
      { mot: "habitants" },
      { mot: "surveillaient", pourquoi: "Piège : verbe d'action ordinaire, sans valeur modale." },
      { mot: "les" },
      { mot: "berges." },
    ],
    combien: 0,
    bilan:
      "Un seul modalisateur sur quatorze mots. Un relevé qui en trouve cinq est un relevé qui n'a pas appliqué le test.",
  },
  {
    id: "rm10",
    consigne: "Relève tout ce qui marque la position de l'auteur.",
    jetons: [
      { mot: "Il" },
      { mot: "est" },
      { mot: "évidemment", bon: true, pourquoi: "Modalisateur de certitude forte." },
      { mot: "trop" },
      { mot: "tard," },
      { mot: "et" },
      { mot: "hélas", bon: true, pourquoi: "Modalisateur de jugement : désapprobation." },
      { mot: "personne" },
      { mot: "ne" },
      { mot: "semble", bon: true, pourquoi: "Verbe modal d'incertitude." },
      { mot: "s'en" },
      { mot: "soucier." },
    ],
    combien: 0,
    bilan:
      "Certitude, jugement, incertitude : trois familles différentes en une phrase. Procède en quatre passes et tu ne manqueras rien.",
  },
];

export function RelevierModalisateurs() {
  return (
    <Surligner
      consigne="Clique sur les mots qui marquent la position de l'auteur. Le test : ce mot porte-t-il sur le fait, ou sur ce que le locuteur en pense ?"
      releves={RELEVES_MODAL}
      conclusion={
        <Citation auteur="la méthode de relevé, en quatre passes">
          Les adverbes, puis les adjectifs et noms évaluatifs, puis les verbes modaux et les modes,
          puis les suffixes et la typographie. Et pour chaque marque, dis ce qu'elle révèle : un
          relevé sans commentaire ne vaut que la moitié des points.
        </Citation>
      }
    />
  );
}

/* ------------------------------------------------------------------ */
/* 2. Le curseur du degré d'adhésion                                   */
/* ------------------------------------------------------------------ */

const DEGRES: ReadonlyArray<{ outil: string; recu: string; note: string }> = [
  {
    outil: "Il est certain que",
    recu: "Je garantis. Si je me trompe, on me le reprochera.",
    note: "Certitude maximale. À réserver aux faits qu'on a vérifiés soi-même.",
  },
  {
    outil: "Sans aucun doute,",
    recu: "Je suis très sûr, mais je n'ai pas tout vérifié.",
    note: "Certitude forte. Attention à ne pas la confondre avec « sans doute ».",
  },
  {
    outil: "Sans doute,",
    recu: "C'est probable, mais je peux me tromper.",
    note: "PIÈGE : « sans doute » signifie « probablement ». Elle paraît affirmer et elle nuance. Pour la certitude totale, il faut « sans aucun doute ».",
  },
  {
    outil: "Peut-être",
    recu: "Je n'en sais rien, j'avance une hypothèse.",
    note: "Incertitude affichée.",
  },
  {
    outil: "Il semble que",
    recu: "Les apparences le suggèrent, mais rien n'est établi.",
    note: "Verbe modal d'incertitude. Il commande le subjonctif.",
  },
  {
    outil: "aurait (conditionnel)",
    recu: "Je rapporte ce qu'on m'a dit, je ne garantis rien.",
    note: "Le conditionnel de l'information. C'est l'outil des journalistes honnêtes.",
  },
  {
    outil: "dit-on, selon certains",
    recu: "Ce n'est pas moi qui l'affirme, et je ne sais pas qui.",
    note: "Le degré le plus faible : non seulement l'auteur n'est pas sûr, mais il signale qu'il rapporte la parole d'un autre, anonyme.",
  },
];

const DEGRE_DEFAUT = { outil: "—", recu: "—", note: "—" };

type FaitBase = {
  id: string;
  phrase: string;
  /** Version avec le modalisateur inséré, par degré. */
  rendu: ReadonlyArray<string>;
};

const FAITS: ReadonlyArray<FaitBase> = [
  {
    id: "fb1",
    phrase: "Le camion passera demain.",
    rendu: [
      "Il est certain que le camion passera demain.",
      "Sans aucun doute, le camion passera demain.",
      "Le camion passera sans doute demain.",
      "Le camion passera peut-être demain.",
      "Il semble que le camion passe demain.",
      "Le camion passerait demain.",
      "Le camion passerait demain, dit-on.",
    ],
  },
  {
    id: "fb2",
    phrase: "Le bac a été retiré en janvier.",
    rendu: [
      "Il est certain que le bac a été retiré en janvier.",
      "Sans aucun doute, le bac a été retiré en janvier.",
      "Le bac a sans doute été retiré en janvier.",
      "Le bac a peut-être été retiré en janvier.",
      "Il semble que le bac ait été retiré en janvier.",
      "Le bac aurait été retiré en janvier.",
      "Le bac aurait été retiré en janvier, selon les riverains.",
    ],
  },
  {
    id: "fb3",
    phrase: "Trois boutiques ont brûlé au marché.",
    rendu: [
      "Il est certain que trois boutiques ont brûlé au marché.",
      "Sans aucun doute, trois boutiques ont brûlé au marché.",
      "Trois boutiques ont sans doute brûlé au marché.",
      "Trois boutiques ont peut-être brûlé au marché.",
      "Il semble que trois boutiques aient brûlé au marché.",
      "Le feu aurait détruit trois boutiques du marché.",
      "Le feu aurait détruit trois boutiques, dit-on.",
    ],
  },
  {
    id: "fb4",
    phrase: "Les travaux commenceront en mars.",
    rendu: [
      "Il est certain que les travaux commenceront en mars.",
      "Sans aucun doute, les travaux commenceront en mars.",
      "Les travaux commenceront sans doute en mars.",
      "Les travaux commenceront peut-être en mars.",
      "Il semble que les travaux commencent en mars.",
      "Les travaux commenceraient en mars.",
      "Les travaux commenceraient en mars, selon la mairie.",
    ],
  },
];

const FAIT_DEFAUT: FaitBase = { id: "", phrase: "—", rendu: [] };

type DevinerDegre = {
  id: string;
  phrase: string;
  degre: number;
  piege?: string;
};

const DEVINER: ReadonlyArray<DevinerDegre> = [
  {
    id: "dd1",
    phrase: "Le camion passera sans doute demain.",
    degre: 2,
    piege: "« Sans doute » n'est PAS la certitude. Elle signifie « probablement ».",
  },
  { id: "dd2", phrase: "Il est certain que le bac a disparu.", degre: 0 },
  { id: "dd3", phrase: "L'accident aurait fait trois blessés.", degre: 5 },
  {
    id: "dd4",
    phrase: "Sans aucun doute, le pont est en danger.",
    degre: 1,
    piege: "Celle-ci est bien la certitude forte : « sans AUCUN doute ».",
  },
  { id: "dd5", phrase: "Il semble que la décision soit prise.", degre: 4 },
  { id: "dd6", phrase: "Selon certains, la route rouvrira lundi.", degre: 6 },
  { id: "dd7", phrase: "Le marché rouvrira peut-être samedi.", degre: 3 },
  { id: "dd8", phrase: "Les travaux auraient été suspendus, dit-on.", degre: 6 },
  {
    id: "dd9",
    phrase: "Le ministre a sans doute signé l'arrêté.",
    degre: 2,
    piege: "Troisième rencontre avec le piège : « sans doute » = probablement.",
  },
  { id: "dd10", phrase: "Il est évident que personne n'a vérifié.", degre: 0 },
];

const DEVINER_DEFAUT: DevinerDegre = { id: "", phrase: "—", degre: 0 };

export function DegreAdhesion() {
  const [atelier, setAtelier] = useState<"regler" | "deviner">("regler");
  const [degre, setDegre] = useState(0);
  const [iF, setIF] = useState(0);
  const [iD, setID] = useState(0);
  const [choix, setChoix] = useState<number | null>(null);

  const d = DEGRES[degre] ?? DEGRE_DEFAUT;
  const f = FAITS[iF] ?? FAIT_DEFAUT;
  const dev = DEVINER[iD] ?? DEVINER_DEFAUT;

  return (
    <div className="space-y-3">
      <div>
        <Choice<"regler" | "deviner">
          label="Atelier"
          value={atelier}
          options={[
            { value: "regler", label: "régler le curseur" },
            { value: "deviner", label: "retrouver le degré" },
          ]}
          onChange={setAtelier}
        />
      </div>

      {atelier === "regler" ? (
        <div className="rounded-lg border border-border bg-background p-3">
          <p className="text-[11px] text-muted-foreground">Le fait, sans aucune marque :</p>
          <p className="text-sm font-semibold text-foreground">{f.phrase}</p>

          <div className="mt-3">
            <Ctrl
              label="Degré d'adhésion"
              value={degre}
              min={0}
              max={DEGRES.length - 1}
              step={1}
              onChange={(v) => setDegre(Math.round(v))}
              display={d.outil}
              color={PALETTE.purple}
            />
          </div>

          <p className="mt-3 text-base italic text-foreground">{f.rendu[degre] ?? f.phrase}</p>

          <div
            className="mt-2 rounded-md px-2.5 py-2"
            style={{ backgroundColor: "rgba(37,99,235,0.08)" }}
          >
            <p className="text-[11px] font-semibold" style={{ color: PALETTE.blue }}>
              Ce que le lecteur comprend
            </p>
            <p className="mt-0.5 text-xs text-foreground">{d.recu}</p>
          </div>
          <p className="mt-1.5 text-[11px] text-muted-foreground">{d.note}</p>

          <button
            type="button"
            onClick={() => {
              setIF((n) => (n + 1) % FAITS.length);
              setDegre(0);
            }}
            className="mt-3 rounded-lg bg-primary px-3 py-1.5 text-xs font-semibold text-primary-foreground"
          >
            Fait suivant ({iF + 1} / {FAITS.length})
          </button>
        </div>
      ) : (
        <div className="rounded-lg border border-border bg-background p-3">
          <p className="text-base text-foreground">{dev.phrase}</p>
          <p className="mt-1 text-[11px] text-muted-foreground">
            Place le curseur sur le degré d'adhésion de l'auteur.
          </p>

          <div className="mt-2">
            <Ctrl
              label="Ton estimation"
              value={choix ?? 0}
              min={0}
              max={DEGRES.length - 1}
              step={1}
              onChange={(v) => setChoix(Math.round(v))}
              display={DEGRES[choix ?? 0]?.outil ?? "—"}
              color={PALETTE.orange}
            />
          </div>

          {choix !== null ? (
            <div className="mt-3 space-y-2">
              <Verdict
                tone={
                  choix === dev.degre ? "ok" : Math.abs(choix - dev.degre) === 1 ? "warn" : "bad"
                }
              >
                <span className="font-semibold">
                  Le degré attendu : « {DEGRES[dev.degre]?.outil ?? ""} ».{" "}
                </span>
                {DEGRES[dev.degre]?.recu ?? ""}
              </Verdict>
              {dev.piege !== undefined ? (
                <p
                  className="rounded-md px-2 py-1.5 text-[11px]"
                  style={{ backgroundColor: "rgba(202,138,4,0.12)", color: "#78350f" }}
                >
                  {dev.piege}
                </p>
              ) : null}
              <button
                type="button"
                onClick={() => {
                  setID((n) => (n + 1) % DEVINER.length);
                  setChoix(null);
                }}
                className="rounded-lg bg-primary px-3 py-1.5 text-xs font-semibold text-primary-foreground"
              >
                Phrase suivante ({iD + 1} / {DEVINER.length})
              </button>
            </div>
          ) : null}
        </div>
      )}

      <Citation auteur="savoir lire un journal">
        « Le ministre a inauguré le pont » est un fait. « Le ministre aurait inauguré le pont » dit
        que le journaliste n'a pas vérifié. « Le ministre a enfin inauguré » dit qu'il a trop
        attendu. Un lecteur qui ne voit pas ces mots lit sans comprendre ce qu'on lui dit.
      </Citation>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* 3. Appréciatif, dépréciatif, neutre                                 */
/* ------------------------------------------------------------------ */

const MOTS_EVAL: ReadonlyArray<ItemTri> = [
  {
    id: "me1",
    texte: "une demeure",
    bonne: "appreciatif",
    pourquoi:
      "Grandeur, noblesse, ancienneté. On parle de la demeure d'un notable, jamais d'une case.",
  },
  {
    id: "me2",
    texte: "une bicoque",
    bonne: "depreciatif",
    pourquoi: "Petitesse, vétusté, pauvreté. Le mot méprise.",
  },
  {
    id: "me3",
    texte: "une maison",
    bonne: "neutre",
    pourquoi: "Le terme ordinaire, celui du dictionnaire et de l'état civil.",
  },
  {
    id: "me4",
    texte: "un exploit",
    bonne: "appreciatif",
    pourquoi: "Nom appréciatif. Les noms sont souvent oubliés au relevé.",
  },
  {
    id: "me5",
    texte: "une manœuvre",
    bonne: "depreciatif",
    pourquoi: "Nom dépréciatif : il prête une intention cachée.",
  },
  {
    id: "me6",
    texte: "une opération",
    bonne: "neutre",
    pourquoi: "Terme technique et descriptif.",
  },
  { id: "me7", texte: "il affirme", bonne: "neutre", pourquoi: "Verbe de déclaration neutre." },
  {
    id: "me8",
    texte: "il prétend",
    bonne: "depreciatif",
    pourquoi:
      "Le verbe dit que l'auteur n'y croit pas. C'est le couple le plus parlant du chapitre.",
  },
  {
    id: "me9",
    texte: "bâclé",
    bonne: "depreciatif",
    pourquoi: "Adjectif dépréciatif : travail mal fait et vite fait.",
  },
  {
    id: "me10",
    texte: "exemplaire",
    bonne: "appreciatif",
    pourquoi: "Adjectif appréciatif fort : qui mérite d'être imité.",
  },
  {
    id: "me11",
    texte: "un simulacre",
    bonne: "depreciatif",
    pourquoi: "Le mot le plus fort de la série : il dit que la chose n'a que l'apparence.",
  },
  {
    id: "me12",
    texte: "un chauffard",
    bonne: "depreciatif",
    pourquoi: "Suffixe péjoratif -ard, greffé sur « chauffeur ».",
  },
  {
    id: "me13",
    texte: "verdâtre",
    bonne: "depreciatif",
    pourquoi: "Suffixe péjoratif -âtre : un vert sale, approximatif.",
  },
  {
    id: "me14",
    texte: "assainissement",
    bonne: "neutre",
    pourquoi:
      "Vocabulaire technique d'ingénieur. Il passe pour neutre, et c'est ce qui le rend utile à qui veut éviter le débat.",
  },
  {
    id: "me15",
    texte: "un saccage",
    bonne: "depreciatif",
    pourquoi: "Violence, destruction, irréparable.",
  },
  {
    id: "me16",
    texte: "le patrimoine",
    bonne: "appreciatif",
    pourquoi: "Nommer la forêt « patrimoine » plutôt que « ressource » a déjà choisi un camp.",
  },
  {
    id: "me17",
    texte: "des immondices",
    bonne: "depreciatif",
    pourquoi: "Plus fort que « déchets » ou « ordures » : le mot dégoûte.",
  },
  {
    id: "me18",
    texte: "solidaires",
    bonne: "appreciatif",
    pourquoi: "Adjectif appréciatif, qui engage une valeur.",
  },
  {
    id: "me19",
    texte: "quelques plantillons",
    bonne: "depreciatif",
    pourquoi: "Le diminutif -illon minimise et dit que ce n'est pas sérieux.",
  },
  {
    id: "me20",
    texte: "des promesses creuses",
    bonne: "depreciatif",
    pourquoi: "L'adjectif « creuses » vide le nom de son contenu.",
  },
  {
    id: "me21",
    texte: "« Quelle efficacité remarquable », après six semaines sans ramassage",
    bonne: "depreciatif",
    pourquoi:
      "PIÈGE : l'adjectif est appréciatif de FORME, mais employé ironiquement — donc dépréciatif de SENS. On le repère à l'écart entre le mot et ce que le texte raconte.",
  },
  { id: "me22", texte: "une décision", bonne: "neutre", pourquoi: "Terme descriptif." },
  {
    id: "me23",
    texte: "il a accompli",
    bonne: "appreciatif",
    pourquoi: "Accomplir suppose une tâche menée à son terme.",
  },
  {
    id: "me24",
    texte: "il s'est entêté",
    bonne: "depreciatif",
    pourquoi: "Même comportement que « faire preuve de fermeté », jugement opposé.",
  },
];

export function AppreciatifDepreciatif() {
  return (
    <JeuTri
      consigne="Range chaque mot selon le jugement qu'il porte. Attention au piège de l'ironie : un terme appréciatif employé ironiquement devient dépréciatif."
      categories={[
        { value: "appreciatif", label: "appréciatif", aide: "le mot valorise" },
        { value: "neutre", label: "neutre", aide: "le mot décrit sans juger" },
        { value: "depreciatif", label: "dépréciatif", aide: "le mot dévalorise" },
      ]}
      items={MOTS_EVAL}
      conclusion={
        <Citation auteur="ne pas seulement relever, mais montrer ce que le relevé dessine">
          Dans un texte, les termes appréciatifs vont presque toujours à un camp et les dépréciatifs
          à l'autre. Le signaler — « l'auteur donne à la commune un vocabulaire de mots et aux
          habitants un vocabulaire d'actes » — est ce qui sépare une réponse à un point d'une
          réponse à deux points.
        </Citation>
      }
    />
  );
}

/* ------------------------------------------------------------------ */
/* 4. La structure de la tragédie                                      */
/* ------------------------------------------------------------------ */

type SceneTrag = {
  id: string;
  texte: string;
  acte: number;
};

const SCENES: ReadonlyArray<SceneTrag> = [
  { id: "s1", texte: "Oreste arrive en Épire et réclame Astyanax au nom des Grecs.", acte: 1 },
  {
    id: "s2",
    texte: "Pyrrhus refuse de livrer l'enfant — mais c'est son moyen de pression.",
    acte: 1,
  },
  { id: "s3", texte: "Hermione reçoit Oreste et feint l'indifférence pour Pyrrhus.", acte: 2 },
  {
    id: "s4",
    texte: "Pyrrhus, irrité du refus d'Andromaque, annonce qu'il épousera Hermione.",
    acte: 2,
  },
  { id: "s5", texte: "Andromaque supplie Pyrrhus d'épargner son fils.", acte: 3 },
  { id: "s6", texte: "Pyrrhus pose son ultimatum : l'épouser, ou voir mourir Astyanax.", acte: 3 },
  { id: "s7", texte: "Andromaque décide d'épouser Pyrrhus puis de se donner la mort.", acte: 4 },
  { id: "s8", texte: "Hermione, folle de jalousie, demande à Oreste de tuer Pyrrhus.", acte: 4 },
  { id: "s9", texte: "Oreste vient annoncer la mort de Pyrrhus ; Hermione le maudit.", acte: 5 },
  { id: "s10", texte: "Le récit de la mort de Pyrrhus, tué pendant la cérémonie.", acte: 5 },
];

const ACTES: ReadonlyArray<{ n: number; nom: string; role: string }> = [
  {
    n: 1,
    nom: "Acte I",
    role: "L'EXPOSITION — qui est qui, où l'on est, ce qui s'est passé avant, et quel est le problème. Tout doit être dit ici.",
  },
  { n: 2, nom: "Acte II", role: "LE NŒUD — la situation se complique, les intérêts s'opposent." },
  {
    n: 3,
    nom: "Acte III",
    role: "LES PÉRIPÉTIES — les retournements s'enchaînent ; on croit plusieurs fois que cela va s'arranger.",
  },
  { n: 4, nom: "Acte IV", role: "LE POINT DE NON-RETOUR — une décision irréversible est prise." },
  { n: 5, nom: "Acte V", role: "LE DÉNOUEMENT — le malheur arrive, et il est raconté." },
];

const UNITES: ReadonlyArray<{ nom: string; regle: string; dansLaPiece: string }> = [
  {
    nom: "Unité d'ACTION",
    regle: "Une seule intrigue principale, sans épisode secondaire qui s'en détache.",
    dansLaPiece:
      "Tout tourne autour d'une seule question : Andromaque épousera-t-elle Pyrrhus ? Les quatre destins en dépendent.",
  },
  {
    nom: "Unité de TEMPS",
    regle: "L'action se déroule en vingt-quatre heures au plus.",
    dansLaPiece:
      "Tout se joue en une journée : Oreste arrive le matin, Pyrrhus meurt le soir aux noces. C'est cette compression qui crée l'urgence.",
  },
  {
    nom: "Unité de LIEU",
    regle: "Un seul décor, où tous les personnages peuvent se croiser vraisemblablement.",
    dansLaPiece:
      "Une salle du palais de Pyrrhus, en Épire. Tous y passent, et même le meurtre se produit ailleurs — au temple, hors scène.",
  },
];

const VOCABULAIRE: ReadonlyArray<{ terme: string; def: string; exemple: string }> = [
  { terme: "une réplique", def: "ce que dit un personnage", exemple: "— Qui te l'a dit ?" },
  {
    terme: "une tirade",
    def: "une longue réplique ininterrompue",
    exemple: "Les quatorze vers de Pyrrhus posant son ultimatum.",
  },
  {
    terme: "un monologue",
    def: "un personnage seul en scène, qui parle à lui-même",
    exemple: "Il révèle le conflit intérieur.",
  },
  {
    terme: "un aparté",
    def: "ce qu'un personnage dit sans que les autres l'entendent",
    exemple: "Il révèle la vérité d'un personnage qui ment en scène.",
  },
  {
    terme: "une stichomythie",
    def: "un échange de répliques très courtes, souvent d'un vers chacune",
    exemple: "Elle marque l'affrontement, et le rythme s'accélère.",
  },
  {
    terme: "une didascalie",
    def: "les indications scéniques, qui ne sont pas prononcées",
    exemple: "« Elle sort. »",
  },
  {
    terme: "un confident",
    def: "personnage secondaire à qui le héros confie ses pensées",
    exemple: "Céphise, Pylade, Cléone : ils existent pour que leurs maîtres pensent devant nous.",
  },
  { terme: "le dénouement", def: "la fin, qui dénoue l'intrigue", exemple: "Acte V." },
  {
    terme: "un coup de théâtre",
    def: "un retournement brutal et imprévu",
    exemple: "« Qui te l'a dit ? »",
  },
];

const SCENE_VIDE: SceneTrag = { id: "", texte: "—", acte: 1 };

export function StructureTragedie() {
  const [atelier, setAtelier] = useState<"actes" | "unites" | "vocabulaire">("actes");
  const [i, setI] = useState(0);
  const [places, setPlaces] = useState<Record<string, number>>({});
  const [alerte, setAlerte] = useState<string | null>(null);
  const [iu, setIu] = useState(0);
  const [iv, setIv] = useState(0);
  const [repV, setRepV] = useState<string | null>(null);

  const s = SCENES[i] ?? SCENE_VIDE;
  const u = UNITES[iu] ?? UNITES[0];
  const v = VOCABULAIRE[iv] ?? VOCABULAIRE[0];

  function placer(acte: number) {
    if (acte > s.acte + 1) {
      setAlerte(
        `Trop loin. L'acte ${acte} est celui ${ACTES[acte - 1]?.role.split(" — ")[0]?.toLowerCase() ?? ""}, et cette scène n'y a pas sa place : la logique du récit se casserait.`,
      );
      return;
    }
    setAlerte(null);
    setPlaces((p) => ({ ...p, [s.id]: acte }));
  }

  const justes = SCENES.filter((sc) => places[sc.id] === sc.acte).length;

  return (
    <div className="space-y-3">
      <div>
        <Choice<"actes" | "unites" | "vocabulaire">
          label="Atelier"
          value={atelier}
          options={[
            { value: "actes", label: "les cinq actes" },
            { value: "unites", label: "les trois unités" },
            { value: "vocabulaire", label: "le vocabulaire du théâtre" },
          ]}
          onChange={setAtelier}
        />
      </div>

      {atelier === "actes" ? (
        <div className="rounded-lg border border-border bg-background p-3">
          <p className="text-sm text-foreground">{s.texte}</p>

          <div className="mt-3 space-y-1.5">
            {ACTES.map((a) => (
              <button
                key={a.n}
                type="button"
                onClick={() => placer(a.n)}
                className="block w-full rounded-md border px-2.5 py-1.5 text-left text-xs"
                style={{
                  borderColor:
                    places[s.id] === a.n
                      ? a.n === s.acte
                        ? PALETTE.green
                        : PALETTE.red
                      : "rgba(100,116,139,0.3)",
                  backgroundColor:
                    places[s.id] === a.n
                      ? a.n === s.acte
                        ? "rgba(21,128,61,0.10)"
                        : "rgba(185,28,28,0.10)"
                      : "transparent",
                }}
              >
                <span className="font-semibold">{a.nom}</span>
                <span className="ml-2 text-muted-foreground">{a.role}</span>
              </button>
            ))}
          </div>

          {alerte !== null ? (
            <div className="mt-2">
              <Verdict tone="bad">
                <span className="font-semibold">Placement refusé. </span>
                {alerte}
              </Verdict>
            </div>
          ) : null}

          {places[s.id] !== undefined ? (
            <div className="mt-2 space-y-2">
              <Verdict tone={places[s.id] === s.acte ? "ok" : "warn"}>
                <span className="font-semibold">Acte {s.acte}. </span>
                {ACTES[s.acte - 1]?.role ?? ""}
              </Verdict>
              <button
                type="button"
                onClick={() => {
                  setI((n) => (n + 1) % SCENES.length);
                  setAlerte(null);
                }}
                className="rounded-lg bg-primary px-3 py-1.5 text-xs font-semibold text-primary-foreground"
              >
                Scène suivante ({i + 1} / {SCENES.length})
              </button>
            </div>
          ) : null}

          <p className="mt-2 text-[11px] text-muted-foreground">
            {justes} / {SCENES.length} scènes bien placées.
          </p>
        </div>
      ) : null}

      {atelier === "unites" ? (
        <div className="rounded-lg border border-border bg-background p-3">
          <p className="text-sm font-semibold" style={{ color: PALETTE.blue }}>
            {u?.nom ?? "—"}
          </p>
          <p className="mt-1 text-xs text-muted-foreground">{u?.regle ?? ""}</p>
          <div
            className="mt-2 rounded-md px-2.5 py-2"
            style={{ backgroundColor: "rgba(21,128,61,0.08)" }}
          >
            <p className="text-[11px] font-semibold" style={{ color: PALETTE.green }}>
              Dans Andromaque
            </p>
            <p className="mt-0.5 text-xs text-foreground">{u?.dansLaPiece ?? ""}</p>
          </div>
          <button
            type="button"
            onClick={() => setIu((n) => (n + 1) % UNITES.length)}
            className="mt-3 rounded-lg bg-primary px-3 py-1.5 text-xs font-semibold text-primary-foreground"
          >
            Unité suivante ({iu + 1} / {UNITES.length})
          </button>
          <p
            className="mt-3 rounded-md px-2 py-1.5 text-[11px]"
            style={{ backgroundColor: "rgba(202,138,4,0.12)", color: "#78350f" }}
          >
            <span className="font-semibold">Pourquoi ces règles ? </span>
            Pour la vraisemblance — et parce qu'elles resserrent. En vingt-quatre heures, les
            personnages n'ont le temps de rien : ils doivent décider maintenant. La contrainte crée
            l'urgence, et l'urgence crée la tragédie.
          </p>
        </div>
      ) : null}

      {atelier === "vocabulaire" ? (
        <div className="rounded-lg border border-border bg-background p-3">
          <p className="text-sm text-foreground">{v?.def ?? "—"}</p>
          <p className="mt-1 text-[11px] italic text-muted-foreground">{v?.exemple ?? ""}</p>

          <div className="mt-3 flex flex-wrap gap-1.5">
            {VOCABULAIRE.map((x) => (
              <button
                key={x.terme}
                type="button"
                disabled={repV !== null}
                onClick={() => setRepV(x.terme)}
                className="rounded-md border px-2.5 py-1 text-xs"
                style={{
                  borderColor:
                    repV !== null && x.terme === v?.terme ? PALETTE.green : "rgba(100,116,139,0.3)",
                  backgroundColor:
                    repV !== null && x.terme === v?.terme
                      ? "rgba(21,128,61,0.10)"
                      : repV === x.terme
                        ? "rgba(185,28,28,0.10)"
                        : "transparent",
                }}
              >
                {x.terme}
              </button>
            ))}
          </div>

          {repV !== null ? (
            <button
              type="button"
              onClick={() => {
                setIv((n) => (n + 1) % VOCABULAIRE.length);
                setRepV(null);
              }}
              className="mt-3 rounded-lg bg-primary px-3 py-1.5 text-xs font-semibold text-primary-foreground"
            >
              Terme suivant ({iv + 1} / {VOCABULAIRE.length})
            </button>
          ) : null}
        </div>
      ) : null}

      <Citation auteur="l'interdiction a produit un art">
        La bienséance interdit de montrer la mort sur scène. Il a donc fallu la raconter — et le «
        récit » est devenu le plus beau morceau de la tragédie classique, celui où l'auteur fait
        voir avec des mots ce que le spectateur ne verra pas.
      </Citation>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* 5. Le dilemme d'Andromaque                                          */
/* ------------------------------------------------------------------ */

type Porte = {
  id: string;
  titre: string;
  consequences: ReadonlyArray<{ acte: string; texte: string }>;
  perte: string;
};

const PORTES: ReadonlyArray<Porte> = [
  {
    id: "p1",
    titre: "Épouser Pyrrhus",
    consequences: [
      {
        acte: "Immédiatement",
        texte: "Astyanax est sauvé : Pyrrhus tient parole et protège l'enfant.",
      },
      {
        acte: "Le jour même",
        texte: "Andromaque devient reine d'Épire, et épouse le fils d'Achille.",
      },
      {
        acte: "Pour toujours",
        texte: "Elle a épousé la famille du meurtrier d'Hector. Son mari mort est trahi.",
      },
    ],
    perte: "LA FIDÉLITÉ À HECTOR — un devoir absolu, et non négociable.",
  },
  {
    id: "p2",
    titre: "Refuser Pyrrhus",
    consequences: [
      { acte: "Immédiatement", texte: "Elle reste fidèle à la mémoire d'Hector, devant tous." },
      { acte: "Le jour même", texte: "Pyrrhus livre Astyanax aux Grecs, qui veulent sa mort." },
      {
        acte: "Pour toujours",
        texte: "Son fils meurt sous ses yeux, et la lignée d'Hector s'éteint avec lui.",
      },
    ],
    perte: "LA VIE DE SON FILS — un devoir absolu, et non négociable.",
  },
];

const PORTE_VIDE: Porte = { id: "", titre: "—", consequences: [], perte: "—" };

type Maillon = { id: string; nom: string; aime: string };

const MAILLONS: ReadonlyArray<Maillon> = [
  { id: "m1", nom: "Oreste", aime: "Hermione" },
  { id: "m2", nom: "Hermione", aime: "Pyrrhus" },
  { id: "m3", nom: "Pyrrhus", aime: "Andromaque" },
  { id: "m4", nom: "Andromaque", aime: "Hector, mort" },
];

export function DilemmeAndromaque() {
  const [atelier, setAtelier] = useState<"dilemme" | "chaine">("dilemme");
  const [ouvertes, setOuvertes] = useState<ReadonlyArray<string>>([]);
  const [troisieme, setTroisieme] = useState(false);
  const [ordre, setOrdre] = useState<ReadonlyArray<string>>([]);
  const [casse, setCasse] = useState<string | null>(null);

  const lesDeux = ouvertes.length === 2;
  const chaineJuste = ordre.length === 4 && ordre.every((id, k) => id === (MAILLONS[k]?.id ?? ""));

  return (
    <div className="space-y-3">
      <div>
        <Choice<"dilemme" | "chaine">
          label="Atelier"
          value={atelier}
          options={[
            { value: "dilemme", label: "les deux portes" },
            { value: "chaine", label: "la chaîne des amours" },
          ]}
          onChange={setAtelier}
        />
      </div>

      {atelier === "dilemme" ? (
        <div className="rounded-lg border border-border bg-background p-3">
          <p className="text-sm text-foreground">
            Tu es Andromaque, acte III. Pyrrhus vient de poser son ultimatum. Ouvre les deux portes,
            et regarde où chacune mène.
          </p>

          <div className="mt-3 grid gap-2 sm:grid-cols-2">
            {PORTES.map((p) => {
              const ouvert = ouvertes.includes(p.id);
              return (
                <div
                  key={p.id}
                  className="rounded-md border p-2.5"
                  style={{
                    borderColor: ouvert ? PALETTE.red : "rgba(100,116,139,0.3)",
                    backgroundColor: ouvert ? "rgba(185,28,28,0.06)" : "transparent",
                  }}
                >
                  <p className="text-sm font-semibold text-foreground">{p.titre}</p>
                  {!ouvert ? (
                    <button
                      type="button"
                      onClick={() => setOuvertes((o) => [...o, p.id])}
                      className="mt-2 rounded-lg border border-border px-3 py-1.5 text-xs font-semibold text-foreground"
                    >
                      Ouvrir cette porte
                    </button>
                  ) : (
                    <div className="mt-2 space-y-1.5">
                      {p.consequences.map((c) => (
                        <p key={c.acte} className="text-[11px]">
                          <span className="font-semibold" style={{ color: PALETTE.slate }}>
                            {c.acte} —
                          </span>{" "}
                          <span className="text-muted-foreground">{c.texte}</span>
                        </p>
                      ))}
                      <p
                        className="mt-1.5 rounded px-2 py-1 text-[11px] font-semibold"
                        style={{ backgroundColor: "rgba(185,28,28,0.12)", color: "#7f1d1d" }}
                      >
                        CE QUE TU PERDS : {p.perte}
                      </p>
                    </div>
                  )}
                </div>
              );
            })}
          </div>

          {lesDeux && !troisieme ? (
            <div className="mt-3 space-y-2">
              <Verdict tone="bad">
                <span className="font-semibold">Aucune des deux n'est tenable. </span>
                Ce n'est pas un choix difficile : c'est un choix impossible. Deux devoirs absolus et
                incompatibles, dont aucun ne peut céder devant l'autre. C'est la définition même du
                dilemme tragique.
              </Verdict>
              <button
                type="button"
                onClick={() => setTroisieme(true)}
                className="rounded-lg bg-primary px-3 py-1.5 text-xs font-semibold text-primary-foreground"
              >
                Ouvrir la troisième porte — celle que Racine a inventée
              </button>
            </div>
          ) : null}

          {troisieme ? (
            <div
              className="mt-3 rounded-md px-2.5 py-2"
              style={{ backgroundColor: "rgba(21,128,61,0.08)" }}
            >
              <p className="text-sm font-semibold" style={{ color: PALETTE.green }}>
                Épouser Pyrrhus, puis se donner la mort aussitôt après la cérémonie.
              </p>
              <div className="mt-2 space-y-1.5 text-[11px] text-muted-foreground">
                <p>
                  <span className="font-semibold">Le mariage a lieu</span> — donc Pyrrhus est
                  engagé, et Astyanax est sauvé.
                </p>
                <p>
                  <span className="font-semibold">La mort suit immédiatement</span> — donc le
                  mariage n'est jamais consommé, et Hector n'est pas trahi.
                </p>
                <p>
                  <span className="font-semibold">Les deux devoirs sont honorés</span>, au prix de
                  sa propre vie.
                </p>
              </div>
              <p className="mt-2 text-[11px] italic text-foreground">
                Ce n'est ni un compromis ni une ruse : c'est un sacrifice qui honore les deux
                obligations à la fois. Et c'est pourquoi Andromaque est le personnage le plus élevé
                de la pièce — la seule qui ne pense pas à son propre bonheur, et la seule qui survit
                et règne.
              </p>
              <button
                type="button"
                onClick={() => {
                  setOuvertes([]);
                  setTroisieme(false);
                }}
                className="mt-2 rounded-lg border border-border px-3 py-1.5 text-xs font-semibold text-foreground"
              >
                Recommencer
              </button>
            </div>
          ) : null}
        </div>
      ) : (
        <div className="rounded-lg border border-border bg-background p-3">
          <p className="text-sm text-muted-foreground">
            Place les quatre personnages dans l'ordre de la chaîne : chacun aime celui qui ne l'aime
            pas.
          </p>

          <div className="mt-2 flex flex-wrap gap-1.5">
            {MAILLONS.map((m) => {
              const rang = ordre.indexOf(m.id);
              return (
                <button
                  key={m.id}
                  type="button"
                  onClick={() =>
                    setOrdre((o) => (o.includes(m.id) ? o.filter((x) => x !== m.id) : [...o, m.id]))
                  }
                  className="rounded-md border px-2.5 py-1.5 text-xs"
                  style={{
                    borderColor: rang >= 0 ? PALETTE.blue : "rgba(100,116,139,0.3)",
                    backgroundColor: rang >= 0 ? "rgba(37,99,235,0.08)" : "transparent",
                  }}
                >
                  {rang >= 0 ? (
                    <span className="mr-1 font-semibold" style={{ color: PALETTE.blue }}>
                      {rang + 1}.
                    </span>
                  ) : null}
                  {m.nom}
                </button>
              );
            })}
          </div>

          {ordre.length === 4 ? (
            <div className="mt-3 space-y-2">
              <Verdict tone={chaineJuste ? "ok" : "bad"}>
                <span className="font-semibold">La chaîne. </span>
                Oreste aime Hermione, qui aime Pyrrhus, qui aime Andromaque, qui aime Hector — mort.
                Quatre maillons, et le dernier ne mène nulle part.
              </Verdict>

              <p className="text-[11px] text-muted-foreground">
                Et maintenant, casse un maillon : que se passerait-il si cet amour-là était
                réciproque ?
              </p>
              <div className="flex flex-wrap gap-1.5">
                {MAILLONS.map((m) => (
                  <button
                    key={`c-${m.id}`}
                    type="button"
                    onClick={() => setCasse(m.id)}
                    className="rounded-md border px-2.5 py-1 text-[11px]"
                    style={{
                      borderColor: casse === m.id ? PALETTE.orange : "rgba(100,116,139,0.3)",
                      backgroundColor: casse === m.id ? "rgba(234,88,12,0.10)" : "transparent",
                    }}
                  >
                    {m.nom} → {m.aime}
                  </button>
                ))}
              </div>

              {casse !== null ? (
                <Verdict tone="warn">
                  <span className="font-semibold">La pièce s'effondre. </span>
                  {casse === "m1"
                    ? "Si Hermione aimait Oreste, elle ne demanderait pas la mort de Pyrrhus : il n'y aurait ni meurtre, ni folie, ni suicide. Trois morts évitées."
                    : casse === "m2"
                      ? "Si Pyrrhus aimait Hermione, il l'épouserait comme prévu et livrerait Astyanax : Andromaque n'aurait plus de dilemme, seulement un deuil."
                      : casse === "m3"
                        ? "Si Andromaque aimait Pyrrhus, il n'y aurait ni chantage, ni ultimatum, ni sacrifice. Le mariage aurait lieu à l'acte I."
                        : "Si Hector était vivant, Andromaque ne serait pas captive, et rien de tout cela n'aurait commencé. C'est le maillon mort qui tient toute la chaîne."}
                </Verdict>
              ) : null}
            </div>
          ) : null}
        </div>
      )}

      <Citation auteur="personne ne peut être heureux, et ce n'est la faute de personne">
        C'est le tragique au sens strict. Ce n'est pas qu'un méchant empêche le bonheur : c'est que
        la situation elle-même l'interdit, et qu'aucun des quatre n'y peut rien.
      </Citation>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* 6. Lire une scène de tragédie                                       */
/* ------------------------------------------------------------------ */

const ETAPES_SCENE: ReadonlyArray<Etape> = [
  {
    titre: "Temps 1 — Où en est-on ?",
    question:
      "Tu lis : « Andromaque, acte III, scène 7. Pyrrhus détient Astyanax et pose son ultimatum. » Que t'apprend ce chapeau ?",
    options: [
      {
        texte:
          "Acte III : nous sommes dans les péripéties, donc au moment où l'on croit encore que cela peut s'arranger. Et le rapport de force est posé : Pyrrhus détient l'enfant.",
        bonne: true,
        retour:
          "L'acte I est une exposition, l'acte V un dénouement : on n'y lit pas la même chose. Situer la scène avant de la lire est le premier geste.",
      },
      {
        texte: "Rien d'utile, il faut lire le texte.",
        bonne: false,
        retour:
          "Le chapeau te donne l'acte, les personnages et la situation. C'est le paratexte, et il répond souvent à une question d'examen à lui seul.",
      },
      {
        texte: "Que la scène est le dénouement.",
        bonne: false,
        retour: "Le dénouement est l'acte V. Nous sommes au III.",
      },
    ],
  },
  {
    titre: "Temps 2 — Qui parle, et combien ?",
    question: "Pyrrhus prononce quatorze vers, Andromaque deux. Que révèle ce déséquilibre ?",
    options: [
      {
        texte:
          "Il montre qu'Andromaque n'a pas la possibilité de discuter, seulement de subir. Le temps de parole est un rapport de force.",
        bonne: true,
        retour:
          "Compter les vers de chaque personnage est le premier relevé, et il est très rentable. Celui qui parle le plus domine la scène, ou cherche à la dominer.",
      },
      {
        texte: "Que Pyrrhus est plus bavard, sans plus.",
        bonne: false,
        retour:
          "Dans une tragédie, rien n'est « sans plus » : le nombre de vers est une décision de l'auteur.",
      },
      {
        texte: "Qu'Andromaque n'a rien à dire.",
        bonne: false,
        retour:
          "Au contraire : ses deux vers sont le cœur de la scène. Le silence relatif est une forme de résistance.",
      },
    ],
  },
  {
    titre: "Temps 3 — La forme de l'échange",
    question:
      "Après la longue tirade de Pyrrhus, l'échange passe à des répliques d'un vers chacune. Comment nomme-t-on cela, et qu'est-ce que cela produit ?",
    options: [
      {
        texte:
          "Une stichomythie : le rythme s'accélère brutalement, et la discussion devient un duel.",
        bonne: true,
        retour:
          "Si une scène passe de la tirade à la stichomythie, l'auteur a accéléré. Le signaler est une analyse, pas un simple relevé.",
      },
      {
        texte: "Un monologue, puis un dialogue.",
        bonne: false,
        retour:
          "Un monologue suppose un personnage SEUL en scène. Pyrrhus parle à Andromaque : c'est une tirade.",
      },
      {
        texte: "Un aparté.",
        bonne: false,
        retour: "L'aparté est ce qu'un personnage dit sans que les autres l'entendent.",
      },
    ],
  },
  {
    titre: "Temps 4 — Scander un alexandrin",
    question:
      "« Vous couronner, Madame, ou le perdre à vos yeux. » Combien de syllabes, et où tombe la césure ?",
    options: [
      {
        texte: "Douze syllabes, césure après « Madame » — six et six.",
        bonne: true,
        retour:
          "Vous-cou-ron-ner-Ma-dame (6) ‖ ou-le-per-dre-à-vos-yeux (6, avec « perdre » en deux syllabes et le e muet final non compté). La césure sépare les deux branches de l'alternative : couronner d'un côté, perdre de l'autre.",
      },
      {
        texte: "Dix syllabes, sans césure.",
        bonne: false,
        retour: "Un alexandrin compte douze syllabes, coupées par une césure médiane.",
      },
      {
        texte: "Quatorze syllabes.",
        bonne: false,
        retour:
          "Attention au e muet : il se prononce à l'intérieur du vers devant une consonne, mais pas à la fin.",
      },
    ],
  },
  {
    titre: "Temps 5 — Les champs lexicaux, avec leur sens du XVIIe siècle",
    question: "Dans la tragédie classique, que signifie le mot « flamme » ? Et « fers » ?",
    options: [
      {
        texte:
          "« Flamme » signifie la passion amoureuse ; « fers » signifie les chaînes de l'amour.",
        bonne: true,
        retour:
          "Un texte ancien se lit avec son vocabulaire, pas avec le nôtre. De même, « charmes » signifie « pouvoir magique » — ce qui est bien plus fort que « séduction ».",
      },
      {
        texte: "Le feu, et les barreaux d'une prison.",
        bonne: false,
        retour:
          "C'est le sens propre, et il fait contresens ici. Le vocabulaire galant du XVIIe siècle a ses codes.",
      },
      {
        texte: "Ces mots n'apparaissent pas dans la tragédie.",
        bonne: false,
        retour: "Ils y sont partout : ce sont les mots mêmes de la passion racinienne.",
      },
    ],
  },
  {
    titre: "Temps 6 — Le mouvement de la scène",
    question: "Comment décrit-on le mouvement d'une scène, en trois temps ?",
    options: [
      {
        texte:
          "Comment elle commence, ce qui bascule, où elle finit. Par exemple : elle s'ouvre sur une supplication, bascule à l'ultimatum, s'achève sur un silence.",
        bonne: true,
        retour:
          "Trois temps, trois phrases. C'est le squelette de tout commentaire de théâtre, et il se prépare au brouillon en deux minutes.",
      },
      {
        texte: "En résumant l'intrigue de la pièce entière.",
        bonne: false,
        retour: "La question porte sur la scène, pas sur la pièce.",
      },
      {
        texte: "En comptant les répliques.",
        bonne: false,
        retour:
          "C'est le temps 2, et il ne suffit pas : il faut dire ce qui change au cours de la scène.",
      },
    ],
  },
  {
    titre: "Temps 7 — Le moule de réponse",
    question: "Quels éléments doit contenir une réponse complète sur une scène de théâtre ?",
    options: [
      {
        texte:
          "La forme repérée, les vers cités avec leur numéro, l'effet nommé, et l'interprétation.",
        bonne: true,
        retour:
          "Quatre mouvements. Et sur un texte de théâtre, la justification est presque toujours un numéro de vers : cite-le entre parenthèses, comme tu citerais une ligne.",
      },
      {
        texte: "Un résumé du passage.",
        bonne: false,
        retour: "Résumer n'est pas analyser, et cela ne vaut aucun point.",
      },
      {
        texte: "Son avis personnel sur la pièce.",
        bonne: false,
        retour:
          "Il n'est demandé qu'à la dernière question de la partie I, et il doit alors être justifié par le texte.",
      },
    ],
  },
];

export function LireSceneTragedie() {
  return (
    <Parcours
      consigne="La méthode de lecture d'une scène de théâtre, en sept temps. Elle convient à n'importe quel extrait, et elle est différente de la lecture d'un roman."
      etapes={ETAPES_SCENE}
      fin={
        <Citation auteur="« Qui te l'a dit ? »">
          Quatre mots, aucun mot rare, aucune image, aucun effet de style. Toute la violence du vers
          vient de la situation : Hermione a ordonné elle-même ce meurtre, et elle demande qui le
          lui a dit. C'est cela, le théâtre — les mots les plus simples placés à l'endroit où ils
          font le plus de mal.
        </Citation>
      }
    />
  );
}
