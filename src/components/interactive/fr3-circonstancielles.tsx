import { useState } from "react";
import { PALETTE, Choice, Verdict } from "./controls";
import { Citation, Qcm, type Question } from "./philo-noyau";

/** Français 3ème — chapitres 17 et 18 : circonstancielles et discours rapporté. */

/* ------------------------------------------------------------------ */
/* 1. Nommer la circonstancielle                                       */
/* ------------------------------------------------------------------ */

type SensCirc =
  | "temps"
  | "cause"
  | "consequence"
  | "but"
  | "opposition"
  | "condition"
  | "comparaison"
  | "autre";

const SENS: ReadonlyArray<{ value: SensCirc; label: string; question: string }> = [
  { value: "temps", label: "temps", question: "quand ?" },
  { value: "cause", label: "cause", question: "pourquoi ?" },
  { value: "consequence", label: "conséquence", question: "avec quel effet ?" },
  { value: "but", label: "but", question: "dans quelle intention ?" },
  { value: "opposition", label: "opposition", question: "malgré quoi ?" },
  { value: "condition", label: "condition", question: "à quelle condition ?" },
  { value: "comparaison", label: "comparaison", question: "comme quoi ?" },
  { value: "autre", label: "ce n'est pas une circonstancielle", question: "—" },
];

type PhraseCirc = {
  id: string;
  avant: string;
  subordonnee: string;
  apres: string;
  conjonction: string;
  sens: SensCirc;
  /** La phrase avec la subordonnée déplacée en tête, ou null si impossible. */
  deplacee: string | null;
  pourquoi: string;
};

const PHRASES_CIRC: ReadonlyArray<PhraseCirc> = [
  {
    id: "c1",
    avant: "Je rentrerai",
    subordonnee: "quand la pluie aura cessé",
    apres: ".",
    conjonction: "quand",
    sens: "temps",
    deplacee: "Quand la pluie aura cessé, je rentrerai.",
    pourquoi: "« Quand » marque le moment. Je rentrerai QUAND ? Circonstancielle de temps.",
  },
  {
    id: "c2",
    avant: "Le marché a fermé",
    subordonnee: "parce que la pluie a commencé",
    apres: ".",
    conjonction: "parce que",
    sens: "cause",
    deplacee: "Parce que la pluie a commencé, le marché a fermé.",
    pourquoi:
      "« Parce que » apporte une cause nouvelle. Note la nuance : « puisque » rappellerait une cause que l'interlocuteur connaît déjà.",
  },
  {
    id: "c3",
    avant: "Il a tellement plu",
    subordonnee: "que le pont a cédé",
    apres: ".",
    conjonction: "tellement… que",
    sens: "consequence",
    deplacee: null,
    pourquoi:
      "La locution est coupée en deux : « tellement » est dans la principale, « que » ouvre la subordonnée. Le déplacement est donc impossible, et cela ne change rien à la nature.",
  },
  {
    id: "c4",
    avant: "Je pars tôt",
    subordonnee: "pour que tu ne m'attendes pas",
    apres: ".",
    conjonction: "pour que",
    sens: "but",
    deplacee: "Pour que tu ne m'attendes pas, je pars tôt.",
    pourquoi:
      "« Pour que » marque l'intention. Et il commande le subjonctif, sans exception : l'intention n'est pas un fait accompli.",
  },
  {
    id: "c5",
    avant: "",
    subordonnee: "Bien qu'il pleuve",
    apres: ", le marché reste ouvert.",
    conjonction: "bien que",
    sens: "opposition",
    deplacee: "Le marché reste ouvert bien qu'il pleuve.",
    pourquoi:
      "« Bien que » marque l'opposition, et commande le subjonctif — d'où « pleuve » et non « pleut ».",
  },
  {
    id: "c6",
    avant: "",
    subordonnee: "Si tu viens demain",
    apres: ", nous irons au marché.",
    conjonction: "si",
    sens: "condition",
    deplacee: "Nous irons au marché si tu viens demain.",
    pourquoi:
      "Premier système hypothétique : si + présent → futur. Et jamais de conditionnel après « si ».",
  },
  {
    id: "c7",
    avant: "Il travaille",
    subordonnee: "comme son père travaillait",
    apres: ".",
    conjonction: "comme",
    sens: "comparaison",
    deplacee: "Comme son père travaillait, il travaille.",
    pourquoi:
      "Attention : « comme » peut aussi marquer la cause, au sens de « puisque ». C'est le SENS qui décide, pas le mot.",
  },
  {
    id: "c8",
    avant: "",
    subordonnee: "Comme la route était coupée",
    apres: ", le chauffeur a fait demi-tour.",
    conjonction: "comme",
    sens: "cause",
    deplacee: "Le chauffeur a fait demi-tour, comme la route était coupée.",
    pourquoi:
      "Même conjonction que la phrase précédente, et sens différent : ici « comme » signifie « puisque ». Le couple est à retenir.",
  },
  {
    id: "c9",
    avant: "Je t'écris",
    subordonnee: "avant que tu partes",
    apres: ".",
    conjonction: "avant que",
    sens: "temps",
    deplacee: "Avant que tu partes, je t'écris.",
    pourquoi:
      "Temps, et subjonctif obligatoire : le départ n'a pas eu lieu. À comparer avec « après que », qui demande l'indicatif.",
  },
  {
    id: "c10",
    avant: "Je t'ai écrit",
    subordonnee: "après que tu es parti",
    apres: ".",
    conjonction: "après que",
    sens: "temps",
    deplacee: "Après que tu es parti, je t'ai écrit.",
    pourquoi:
      "Indicatif, parce que le fait est accompli. « Après qu'il soit parti » est une faute, très courante à l'oral.",
  },
  {
    id: "c11",
    avant: "Range les sacs",
    subordonnee: "de peur que la pluie ne les abîme",
    apres: ".",
    conjonction: "de peur que",
    sens: "but",
    deplacee: "De peur que la pluie ne les abîme, range les sacs.",
    pourquoi:
      "C'est un but négatif : on agit pour éviter. Subjonctif, et « ne » explétif qui ne nie rien.",
  },
  {
    id: "c12",
    avant: "Le car est parti",
    subordonnee: "sans que personne nous prévienne",
    apres: ".",
    conjonction: "sans que",
    sens: "opposition",
    deplacee: "Sans que personne nous prévienne, le car est parti.",
    pourquoi: "« Sans que » marque l'opposition, et appelle le subjonctif.",
  },
  {
    id: "c13",
    avant: "Nous irons au marché",
    subordonnee: "à condition qu'il fasse beau",
    apres: ".",
    conjonction: "à condition que",
    sens: "condition",
    deplacee: "À condition qu'il fasse beau, nous irons au marché.",
    pourquoi:
      "Condition, et subjonctif — contrairement au « si » de condition, qui prend l'indicatif.",
  },
  {
    id: "c14",
    avant: "Il a couru",
    subordonnee: "si bien qu'il ne pouvait plus parler",
    apres: ".",
    conjonction: "si bien que",
    sens: "consequence",
    deplacee: null,
    pourquoi:
      "Conséquence réelle, donc indicatif. Si la même locution exprimait une intention — « range-le de sorte qu'on le trouve » — elle prendrait le subjonctif.",
  },
  {
    id: "c15",
    avant: "Le commerçant",
    subordonnee: "qui vend le poisson",
    apres: "a fermé plus tôt.",
    conjonction: "qui",
    sens: "autre",
    deplacee: null,
    pourquoi:
      "PIÈGE : « qui » est un pronom relatif, pas une conjonction. C'est une relative, elle complète le nom « commerçant », et elle ne se déplace pas.",
  },
  {
    id: "c16",
    avant: "Je sais",
    subordonnee: "que le car est complet",
    apres: ".",
    conjonction: "que",
    sens: "autre",
    deplacee: null,
    pourquoi:
      "PIÈGE : « que » seul, après un verbe de connaissance, ouvre une complétive. Elle complète le verbe « sais », et elle ne se déplace pas.",
  },
  {
    id: "c17",
    avant: "",
    subordonnee: "Dès que j'arriverai",
    apres: ", je préviendrai ma mère.",
    conjonction: "dès que",
    sens: "temps",
    deplacee: "Je préviendrai ma mère dès que j'arriverai.",
    pourquoi: "Temps, avec une idée d'immédiateté. Indicatif futur dans les deux propositions.",
  },
  {
    id: "c18",
    avant: "Il insiste",
    subordonnee: "quoique ce soit difficile",
    apres: ".",
    conjonction: "quoique",
    sens: "opposition",
    deplacee: "Quoique ce soit difficile, il insiste.",
    pourquoi:
      "« Quoique » en un mot est synonyme de « bien que ». À ne pas confondre avec « quoi que » en deux mots, qui signifie « quelle que soit la chose que ».",
  },
  {
    id: "c19",
    avant: "Nous avons attendu",
    subordonnee: "jusqu'à ce que le car soit plein",
    apres: ".",
    conjonction: "jusqu'à ce que",
    sens: "temps",
    deplacee: "Jusqu'à ce que le car soit plein, nous avons attendu.",
    pourquoi: "Temps, avec subjonctif : la locution exprime une limite non encore atteinte.",
  },
  {
    id: "c20",
    avant: "Il gagne moins",
    subordonnee: "que son frère ne gagnait",
    apres: ".",
    conjonction: "moins… que",
    sens: "comparaison",
    deplacee: null,
    pourquoi:
      "Comparaison, locution coupée en deux. Le « ne » est explétif : « que son frère ne gagnait » ne nie rien.",
  },
  {
    id: "c21",
    avant: "Je viendrai",
    subordonnee: "à moins qu'il ne pleuve",
    apres: ".",
    conjonction: "à moins que",
    sens: "condition",
    deplacee: "À moins qu'il ne pleuve, je viendrai.",
    pourquoi: "Condition négative : je viendrai, sauf si. Subjonctif, et « ne » explétif.",
  },
  {
    id: "c22",
    avant: "La maison",
    subordonnee: "dont je t'ai parlé",
    apres: "est à vendre.",
    conjonction: "dont",
    sens: "autre",
    deplacee: null,
    pourquoi:
      "PIÈGE : pronom relatif. La subordonnée complète le nom « maison », et le « dont » a une fonction — complément d'objet indirect de « ai parlé ».",
  },
  {
    id: "c23",
    avant: "Il a réussi",
    subordonnee: "même s'il était malade",
    apres: ".",
    conjonction: "même si",
    sens: "opposition",
    deplacee: "Même s'il était malade, il a réussi.",
    pourquoi:
      "Opposition, mais INDICATIF — parce que la locution contient « si ». Même sens que « bien que », mode opposé.",
  },
  {
    id: "c24",
    avant: "Préviens-moi",
    subordonnee: "au cas où il ne viendrait pas",
    apres: ".",
    conjonction: "au cas où",
    sens: "condition",
    deplacee: "Au cas où il ne viendrait pas, préviens-moi.",
    pourquoi:
      "Condition, et c'est la seule locution d'hypothèse qui appelle régulièrement le CONDITIONNEL.",
  },
];

const PHRASE_CIRC_VIDE: PhraseCirc = {
  id: "",
  avant: "—",
  subordonnee: "—",
  apres: "",
  conjonction: "—",
  sens: "temps",
  deplacee: null,
  pourquoi: "—",
};

export function NommerCirconstancielle() {
  const [i, setI] = useState(0);
  const [rep, setRep] = useState<SensCirc | null>(null);
  const [deplace, setDeplace] = useState(false);

  const p = PHRASES_CIRC[i] ?? PHRASE_CIRC_VIDE;
  const attendu = SENS.find((s) => s.value === p.sens);

  return (
    <div className="space-y-3">
      <p className="text-sm text-muted-foreground">
        La conjonction porte tout le sens. Lis-la, pose la question qu'elle appelle, puis nomme.
      </p>

      <div className="rounded-lg border border-border bg-background p-3">
        <p className="text-base text-foreground">
          {deplace && p.deplacee !== null ? (
            p.deplacee
          ) : (
            <>
              {p.avant}{" "}
              <span
                className="rounded px-1.5 py-0.5"
                style={{ backgroundColor: "rgba(37,99,235,0.12)", color: PALETTE.blue }}
              >
                {p.subordonnee}
              </span>
              {p.apres}
            </>
          )}
        </p>

        <p className="mt-2 text-[11px] text-muted-foreground">
          Conjonction :{" "}
          <span
            className="rounded px-1.5 py-0.5 font-semibold"
            style={{ backgroundColor: "rgba(202,138,4,0.18)", color: "#78350f" }}
          >
            {p.conjonction}
          </span>
        </p>

        <button
          type="button"
          onClick={() => setDeplace((d) => !d)}
          className="mt-2 rounded-lg border border-border px-3 py-1.5 text-xs font-semibold text-foreground"
        >
          {deplace ? "Remettre en place" : "Déplacer la subordonnée"}
        </button>

        {deplace ? (
          <p
            className="mt-2 rounded-md px-2 py-1.5 text-[11px]"
            style={{
              backgroundColor:
                p.deplacee !== null ? "rgba(21,128,61,0.12)" : "rgba(185,28,28,0.10)",
              color: p.deplacee !== null ? "#14532d" : "#7f1d1d",
            }}
          >
            {p.deplacee !== null
              ? "La phrase tient : c'est bien une circonstancielle, elle complète la phrase entière."
              : p.sens === "autre"
                ? "Le déplacement est impossible : relative et complétive ne se déplacent jamais. Ce n'en est donc pas une."
                : "Le déplacement est impossible ici parce que la locution est coupée en deux — mais la nature ne change pas."}
          </p>
        ) : null}

        <div className="mt-3 flex flex-wrap gap-1.5">
          {SENS.map((s) => (
            <button
              key={s.value}
              type="button"
              disabled={rep !== null}
              onClick={() => setRep(s.value)}
              className="rounded-md border px-2.5 py-1 text-xs"
              style={{
                borderColor:
                  rep !== null && s.value === p.sens ? PALETTE.green : "rgba(100,116,139,0.3)",
                backgroundColor:
                  rep !== null && s.value === p.sens
                    ? "rgba(21,128,61,0.10)"
                    : rep === s.value
                      ? "rgba(185,28,28,0.10)"
                      : "transparent",
              }}
            >
              {s.label}
              {s.question !== "—" ? (
                <span className="ml-1 text-[10px] text-muted-foreground">{s.question}</span>
              ) : null}
            </button>
          ))}
        </div>

        {rep !== null ? (
          <div className="mt-3 space-y-2">
            <Verdict tone={rep === p.sens ? "ok" : "bad"}>
              <span className="font-semibold">
                {p.sens === "autre"
                  ? "Ce n'est pas une circonstancielle. "
                  : `Circonstancielle de ${attendu?.label ?? ""}. `}
              </span>
              {p.pourquoi}
            </Verdict>
            <button
              type="button"
              onClick={() => {
                setI((n) => (n + 1) % PHRASES_CIRC.length);
                setRep(null);
                setDeplace(false);
              }}
              className="rounded-lg bg-primary px-3 py-1.5 text-xs font-semibold text-primary-foreground"
            >
              Phrase suivante ({i + 1} / {PHRASES_CIRC.length})
            </button>
          </div>
        ) : null}
      </div>

      <Citation auteur="apprends les conjonctions, tu connaîtras les circonstancielles">
        C'est un travail de liste, et il se fait en une soirée. Mais attention au piège de « comme
        », qui marque tantôt la comparaison, tantôt la cause : c'est le sens qui décide, pas le mot.
      </Citation>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* 2. Indicatif ou subjonctif après la conjonction                     */
/* ------------------------------------------------------------------ */

type ConjMode = {
  id: string;
  conjonction: string;
  accompli: boolean;
  mode: "indicatif" | "subjonctif";
  avant: string;
  apres: string;
  infinitif: string;
  forme: string;
  remarque: string;
  couple?: string;
};

const CONJ_MODES: ReadonlyArray<ConjMode> = [
  {
    id: "k1",
    conjonction: "avant que",
    accompli: false,
    mode: "subjonctif",
    avant: "Je t'écris avant que tu",
    apres: ".",
    infinitif: "partir",
    forme: "partes",
    remarque: "Le départ n'a pas eu lieu au moment dont on parle : fait non réalisé, subjonctif.",
    couple: "après que",
  },
  {
    id: "k2",
    conjonction: "après que",
    accompli: true,
    mode: "indicatif",
    avant: "Je t'ai écrit après que tu",
    apres: ".",
    infinitif: "partir",
    forme: "es parti",
    remarque:
      "Le fait est accompli : indicatif. « Après qu'il soit parti » est une faute, devenue si courante à l'oral que beaucoup la croient correcte.",
    couple: "avant que",
  },
  {
    id: "k3",
    conjonction: "bien que",
    accompli: false,
    mode: "subjonctif",
    avant: "Bien qu'il",
    apres: ", le marché reste ouvert.",
    infinitif: "pleuvoir",
    forme: "pleuve",
    remarque: "Opposition : le fait est posé pour être écarté. Subjonctif.",
    couple: "même si",
  },
  {
    id: "k4",
    conjonction: "même si",
    accompli: true,
    mode: "indicatif",
    avant: "Même s'il",
    apres: ", le marché reste ouvert.",
    infinitif: "pleuvoir",
    forme: "pleut",
    remarque:
      "Même sens que « bien que », mode opposé — parce que la locution contient « si ». Mets les deux phrases côte à côte dans ton cahier.",
    couple: "bien que",
  },
  {
    id: "k5",
    conjonction: "pour que",
    accompli: false,
    mode: "subjonctif",
    avant: "Range les sacs pour que personne ne les",
    apres: ".",
    infinitif: "voir",
    forme: "voie",
    remarque:
      "Le but est toujours au subjonctif : l'intention n'est jamais un fait accompli. Et attention à l'orthographe de « voie ».",
    couple: "parce que",
  },
  {
    id: "k6",
    conjonction: "parce que",
    accompli: true,
    mode: "indicatif",
    avant: "Nous avons fermé parce que la pluie",
    apres: " trop fort.",
    infinitif: "tomber",
    forme: "tombait",
    remarque:
      "La cause est un fait établi : indicatif, toujours. Beaucoup y mettent le subjonctif par contagion de « bien que ».",
    couple: "pour que",
  },
  {
    id: "k7",
    conjonction: "si bien que",
    accompli: true,
    mode: "indicatif",
    avant: "Il a plu, si bien que le pont",
    apres: ".",
    infinitif: "céder",
    forme: "a cédé",
    remarque: "Conséquence réelle, constatée : indicatif.",
    couple: "de sorte que",
  },
  {
    id: "k8",
    conjonction: "de sorte que",
    accompli: false,
    mode: "subjonctif",
    avant: "Range-le de sorte qu'on le",
    apres: " facilement.",
    infinitif: "trouver",
    forme: "trouve",
    remarque:
      "La même locution qu'à la phrase précédente, mais ici elle exprime un BUT, pas un effet constaté. Le raisonnement reste le même : fait accompli ou pas.",
    couple: "si bien que",
  },
  {
    id: "k9",
    conjonction: "jusqu'à ce que",
    accompli: false,
    mode: "subjonctif",
    avant: "Nous attendrons jusqu'à ce que le car",
    apres: " plein.",
    infinitif: "être",
    forme: "soit",
    remarque: "Limite non encore atteinte : subjonctif.",
  },
  {
    id: "k10",
    conjonction: "depuis que",
    accompli: true,
    mode: "indicatif",
    avant: "Depuis que le bac",
    apres: ", les ordures s'entassent.",
    infinitif: "disparaître",
    forme: "a disparu",
    remarque: "Temps, fait accompli : indicatif.",
  },
  {
    id: "k11",
    conjonction: "à condition que",
    accompli: false,
    mode: "subjonctif",
    avant: "J'irai à condition qu'il",
    apres: " beau.",
    infinitif: "faire",
    forme: "fasse",
    remarque:
      "Toutes les locutions de condition appellent le subjonctif, sauf « si » — qui prend l'indicatif.",
  },
  {
    id: "k12",
    conjonction: "si",
    accompli: true,
    mode: "indicatif",
    avant: "Si tu",
    apres: " demain, nous irons au marché.",
    infinitif: "venir",
    forme: "viens",
    remarque:
      "« Si » est l'exception de la condition : indicatif présent, et jamais de conditionnel. Les si n'aiment pas les ré.",
  },
  {
    id: "k13",
    conjonction: "sans que",
    accompli: false,
    mode: "subjonctif",
    avant: "Il est sorti sans que personne le",
    apres: ".",
    infinitif: "voir",
    forme: "voie",
    remarque: "Opposition : subjonctif.",
  },
  {
    id: "k14",
    conjonction: "tandis que",
    accompli: true,
    mode: "indicatif",
    avant: "Il travaillait tandis que les autres",
    apres: ".",
    infinitif: "dormir",
    forme: "dormaient",
    remarque:
      "« Tandis que » marque ici la simultanéité, parfois l'opposition — et dans les deux cas l'indicatif.",
  },
  {
    id: "k15",
    conjonction: "de peur que",
    accompli: false,
    mode: "subjonctif",
    avant: "Il se tait de peur qu'on ne le",
    apres: ".",
    infinitif: "entendre",
    forme: "entende",
    remarque: "But négatif : subjonctif, et « ne » explétif qui ne nie rien.",
  },
  {
    id: "k16",
    conjonction: "puisque",
    accompli: true,
    mode: "indicatif",
    avant: "Puisque tu",
    apres: " là, aide-moi.",
    infinitif: "être",
    forme: "es",
    remarque:
      "Cause connue de l'interlocuteur : indicatif. C'est la nuance avec « parce que », qui apporte une cause nouvelle.",
  },
  {
    id: "k17",
    conjonction: "en attendant que",
    accompli: false,
    mode: "subjonctif",
    avant: "Restons ici en attendant que la pluie",
    apres: ".",
    infinitif: "cesser",
    forme: "cesse",
    remarque: "Antériorité : subjonctif, comme « avant que » et « jusqu'à ce que ».",
  },
  {
    id: "k18",
    conjonction: "dès que",
    accompli: true,
    mode: "indicatif",
    avant: "Je te préviendrai dès que j'",
    apres: ".",
    infinitif: "arriver",
    forme: "arriverai",
    remarque:
      "Temps, indicatif — et au futur, parce que la principale est au futur. Ne mets pas de subjonctif ici.",
  },
  {
    id: "k19",
    conjonction: "pourvu que",
    accompli: false,
    mode: "subjonctif",
    avant: "Tout ira bien pourvu que nous",
    apres: " à l'heure.",
    infinitif: "partir",
    forme: "partions",
    remarque: "Condition : subjonctif. Et à « nous », la terminaison est -ions.",
  },
  {
    id: "k20",
    conjonction: "alors que",
    accompli: true,
    mode: "indicatif",
    avant: "Il se plaint alors qu'il",
    apres: " tout obtenu.",
    infinitif: "avoir",
    forme: "a",
    remarque:
      "Opposition, mais indicatif. Toutes les conjonctions d'opposition ne se valent pas : « bien que » et « quoique » prennent le subjonctif, « alors que » et « même si » l'indicatif.",
  },
];

const CONJ_MODE_VIDE: ConjMode = {
  id: "",
  conjonction: "—",
  accompli: true,
  mode: "indicatif",
  avant: "—",
  apres: "",
  infinitif: "—",
  forme: "",
  remarque: "—",
};

export function ModeCirconstancielle() {
  const [i, setI] = useState(0);
  const [fait, setFait] = useState<"accompli" | "non" | null>(null);
  const [mode, setMode] = useState<"indicatif" | "subjonctif" | null>(null);
  const [saisie, setSaisie] = useState("");
  const [valide, setValide] = useState(false);
  const [astuce, setAstuce] = useState(false);

  const c = CONJ_MODES[i] ?? CONJ_MODE_VIDE;
  const faitJuste = fait === (c.accompli ? "accompli" : "non");
  const modeJuste = mode === c.mode;
  const formeJuste = saisie.trim().toLowerCase() === c.forme.toLowerCase();

  return (
    <div className="space-y-3">
      <p className="text-sm text-muted-foreground">
        Toute la règle tient à une question : la conjonction présente-t-elle un fait accompli, ou un
        fait non réalisé ? Réponds d'abord à celle-là.
      </p>

      <div className="rounded-lg border border-border bg-background p-3">
        <p className="text-center text-lg font-semibold" style={{ color: PALETTE.orange }}>
          {c.conjonction}
        </p>
        {c.couple ? (
          <p className="mt-0.5 text-center text-[11px] text-muted-foreground">
            à comparer avec « {c.couple} »
          </p>
        ) : null}

        <div className="mt-3">
          <Choice<"accompli" | "non" | "">
            label="Cette conjonction présente un fait…"
            value={fait ?? ""}
            options={[
              { value: "accompli", label: "accompli, réel" },
              { value: "non", label: "non réalisé — voulu, craint, attendu" },
            ]}
            onChange={(v) => {
              if (v !== "") setFait(v);
            }}
          />
        </div>

        {fait !== null ? (
          <div className="mt-2">
            <Verdict tone={faitJuste ? "ok" : "warn"}>
              <span className="font-semibold">
                {c.accompli ? "Fait accompli. " : "Fait non réalisé. "}
              </span>
              {c.accompli
                ? "Les conjonctions qui présentent un fait réel commandent l'indicatif."
                : "Les conjonctions qui présentent un fait non réalisé commandent le subjonctif."}
            </Verdict>
          </div>
        ) : null}

        {fait !== null ? (
          <>
            <p className="mt-3 text-base text-foreground">
              {c.avant}{" "}
              <span
                className="rounded px-2 py-0.5 font-semibold"
                style={{
                  backgroundColor: valide ? "rgba(21,128,61,0.12)" : "rgba(100,116,139,0.14)",
                  color: valide ? PALETTE.green : PALETTE.slate,
                }}
              >
                {valide ? c.forme : "……"}
              </span>
              {c.apres}
            </p>
            <p className="mt-1 text-[11px] text-muted-foreground">
              verbe : <span className="font-semibold">{c.infinitif}</span>
            </p>

            <div className="mt-2">
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
          </>
        ) : null}

        {mode !== null ? (
          <div className="mt-3 space-y-2">
            <Verdict tone={modeJuste ? "ok" : "bad"}>
              <span className="font-semibold">
                {modeJuste ? "Bon mode. " : `Il fallait le ${c.mode}. `}
              </span>
              {c.remarque}
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
                Remplace ton verbe par « être » ou « faire ». « Bien qu'il soit là » sonne juste, «
                bien qu'il est là » sonne faux. « Après qu'il est parti » sonne juste à l'oreille
                exercée, même si tout le monde dit le contraire.
              </p>
            ) : null}

            {valide ? (
              <div className="space-y-2">
                <Verdict tone={formeJuste ? "ok" : "warn"}>
                  <span className="font-semibold">
                    {formeJuste ? "Forme exacte. " : `La forme attendue : « ${c.forme} ». `}
                  </span>
                  {c.avant} {c.forme}
                  {c.apres}
                </Verdict>
                <button
                  type="button"
                  onClick={() => {
                    setI((n) => (n + 1) % CONJ_MODES.length);
                    setFait(null);
                    setMode(null);
                    setSaisie("");
                    setValide(false);
                    setAstuce(false);
                  }}
                  className="rounded-lg bg-primary px-3 py-1.5 text-xs font-semibold text-primary-foreground"
                >
                  Conjonction suivante ({i + 1} / {CONJ_MODES.length})
                </button>
              </div>
            ) : null}
          </div>
        ) : null}
      </div>

      <Citation auteur="quatre couples montés l'un contre l'autre">
        Avant que contre après que. Bien que contre même si. Pour que contre parce que. Si bien que
        contre de sorte que. Ils se ressemblent, ils sont voisins dans le dictionnaire, et ils
        demandent des modes opposés — parce que l'un parle d'un fait accompli et l'autre non.
      </Citation>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* 3. La question 5 du BEPC, en entier                                 */
/* ------------------------------------------------------------------ */

type Jeton5 = {
  mot: string;
  /** "conj" = verbe conjugué, "faux" = faux verbe, "autre" = mot ordinaire */
  role: "conj" | "faux" | "autre";
  /** Pour un faux verbe, pourquoi il ne compte pas. */
  pourquoi?: string;
};

type Prop = {
  texte: string;
  nature: string;
  fonction: string;
};

type Phrase5 = {
  id: string;
  jetons: ReadonlyArray<Jeton5>;
  propositions: ReadonlyArray<Prop>;
  commentaire: string;
};

const PHRASES_5: ReadonlyArray<Phrase5> = [
  {
    id: "b1",
    jetons: [
      { mot: "Comme", role: "autre" },
      { mot: "la", role: "autre" },
      { mot: "route", role: "autre" },
      { mot: "était", role: "conj" },
      {
        mot: "coupée,",
        role: "faux",
        pourquoi:
          "Participe passé employé comme adjectif, après l'auxiliaire : il fait partie du verbe « était coupée », déjà compté.",
      },
      { mot: "le", role: "autre" },
      { mot: "chauffeur", role: "autre" },
      { mot: "a pris", role: "conj" },
      { mot: "le", role: "autre" },
      { mot: "chemin", role: "autre" },
      { mot: "qui", role: "autre" },
      { mot: "longe", role: "conj" },
      { mot: "la", role: "autre" },
      { mot: "rivière.", role: "autre" },
    ],
    propositions: [
      {
        texte: "Comme la route était coupée",
        nature: "proposition subordonnée circonstancielle de cause",
        fonction: "complément circonstanciel de cause de la principale",
      },
      {
        texte: "le chauffeur a pris le chemin",
        nature: "proposition principale",
        fonction: "—",
      },
      {
        texte: "qui longe la rivière",
        nature: "proposition subordonnée relative déterminative",
        fonction: "complément de l'antécédent « chemin »",
      },
    ],
    commentaire:
      "« Comme » peut aussi introduire une comparaison. Ici il signifie « puisque » : c'est le sens qui décide, pas le mot.",
  },
  {
    id: "b2",
    jetons: [
      { mot: "Je", role: "autre" },
      { mot: "crois", role: "conj" },
      { mot: "que", role: "autre" },
      { mot: "nous", role: "autre" },
      { mot: "arriverons", role: "conj" },
      { mot: "avant", role: "autre" },
      { mot: "la", role: "autre" },
      { mot: "nuit,", role: "autre" },
      { mot: "bien", role: "autre" },
      { mot: "que", role: "autre" },
      { mot: "le", role: "autre" },
      { mot: "car", role: "autre" },
      { mot: "soit parti", role: "conj" },
      { mot: "en", role: "autre" },
      { mot: "retard.", role: "autre" },
    ],
    propositions: [
      { texte: "Je crois", nature: "proposition principale", fonction: "—" },
      {
        texte: "que nous arriverons avant la nuit",
        nature: "proposition subordonnée conjonctive complétive",
        fonction: "complément d'objet direct du verbe « crois »",
      },
      {
        texte: "bien que le car soit parti en retard",
        nature: "proposition subordonnée circonstancielle d'opposition",
        fonction: "complément circonstanciel d'opposition",
      },
    ],
    commentaire:
      "« Avant la nuit » n'est PAS une proposition : il n'y a pas de verbe conjugué, c'est un groupe nominal complément circonstanciel. Beaucoup de candidats en comptent quatre à cause de ce « avant ».",
  },
  {
    id: "b3",
    jetons: [
      { mot: "Chaque", role: "autre" },
      { mot: "famille", role: "autre" },
      { mot: "reçoit", role: "conj" },
      { mot: "cinq", role: "autre" },
      { mot: "plants", role: "autre" },
      { mot: "et", role: "autre" },
      { mot: "une", role: "autre" },
      { mot: "somme", role: "autre" },
      { mot: "modeste,", role: "autre" },
      {
        mot: "versée",
        role: "faux",
        pourquoi:
          "Participe passé employé comme adjectif, épithète de « somme ». Il n'est pas conjugué : il ne forme pas de proposition.",
      },
      { mot: "non", role: "autre" },
      { mot: "pas", role: "autre" },
      { mot: "le", role: "autre" },
      { mot: "jour", role: "autre" },
      { mot: "de", role: "autre" },
      { mot: "la", role: "autre" },
      { mot: "plantation,", role: "autre" },
      { mot: "mais", role: "autre" },
      { mot: "trois", role: "autre" },
      { mot: "ans", role: "autre" },
      { mot: "plus", role: "autre" },
      { mot: "tard.", role: "autre" },
    ],
    propositions: [
      {
        texte:
          "Chaque famille reçoit cinq plants et une somme modeste, versée non pas le jour de la plantation, mais trois ans plus tard.",
        nature: "proposition indépendante — la phrase est SIMPLE",
        fonction: "—",
      },
    ],
    commentaire:
      "Le piège classique. La phrase est longue, elle a des virgules partout, elle semble complexe — et elle ne contient qu'un seul verbe conjugué. Beaucoup de candidats y inventent une subordonnée qui n'existe pas.",
  },
  {
    id: "b4",
    jetons: [
      { mot: "Je", role: "autre" },
      { mot: "sais", role: "conj" },
      { mot: "qu'il", role: "autre" },
      { mot: "viendra", role: "conj" },
      { mot: "quand", role: "autre" },
      { mot: "il", role: "autre" },
      { mot: "pourra.", role: "conj" },
    ],
    propositions: [
      { texte: "Je sais", nature: "proposition principale", fonction: "—" },
      {
        texte: "qu'il viendra",
        nature: "proposition subordonnée conjonctive complétive",
        fonction: "complément d'objet direct du verbe « sais »",
      },
      {
        texte: "quand il pourra",
        nature: "proposition subordonnée circonstancielle de temps",
        fonction: "complément circonstanciel de temps de la COMPLÉTIVE, non de la principale",
      },
    ],
    commentaire:
      "Phrase courte, trois propositions. Et une finesse : la circonstancielle dépend de la complétive, pas de la principale. On dit qu'elle est enchâssée au second degré — si tu le signales, le correcteur le remarque.",
  },
  {
    id: "b5",
    jetons: [
      { mot: "Les", role: "autre" },
      { mot: "habitants,", role: "autre" },
      {
        mot: "ayant",
        role: "faux",
        pourquoi:
          "Participe présent : il n'est pas conjugué à un mode personnel, il ne forme pas de proposition au sens de l'analyse scolaire.",
      },
      { mot: "attendu", role: "autre" },
      { mot: "six", role: "autre" },
      { mot: "semaines,", role: "autre" },
      { mot: "ont décidé", role: "conj" },
      { mot: "d'", role: "autre" },
      {
        mot: "agir",
        role: "faux",
        pourquoi: "Infinitif : il ne compte pas. « Décider d'agir » est un seul groupe verbal.",
      },
      { mot: "eux-mêmes.", role: "autre" },
    ],
    propositions: [
      {
        texte: "Les habitants, ayant attendu six semaines, ont décidé d'agir eux-mêmes.",
        nature: "proposition indépendante — la phrase est SIMPLE",
        fonction: "—",
      },
    ],
    commentaire:
      "Deux faux verbes dans la même phrase : un participe présent et un infinitif. Seul un verbe conjugué à un mode personnel crée une proposition.",
  },
  {
    id: "b6",
    jetons: [
      { mot: "Si", role: "autre" },
      { mot: "la", role: "autre" },
      { mot: "mairie", role: "autre" },
      { mot: "avait remplacé", role: "conj" },
      { mot: "le", role: "autre" },
      { mot: "bac,", role: "autre" },
      { mot: "les", role: "autre" },
      { mot: "ordures", role: "autre" },
      { mot: "que", role: "autre" },
      { mot: "nous", role: "autre" },
      { mot: "ramassons", role: "conj" },
      { mot: "ne", role: "autre" },
      { mot: "seraient", role: "conj" },
      { mot: "pas", role: "autre" },
      { mot: "là.", role: "autre" },
    ],
    propositions: [
      {
        texte: "Si la mairie avait remplacé le bac",
        nature: "proposition subordonnée circonstancielle de condition",
        fonction: "complément circonstanciel de condition",
      },
      {
        texte: "les ordures ne seraient pas là",
        nature: "proposition principale",
        fonction: "—",
      },
      {
        texte: "que nous ramassons",
        nature: "proposition subordonnée relative déterminative",
        fonction: "complément de l'antécédent « ordures »",
      },
    ],
    commentaire:
      "La relative coupe la principale en deux : il faut recoller les morceaux. Et note le système hypothétique : si + plus-que-parfait → conditionnel.",
  },
  {
    id: "b7",
    jetons: [
      { mot: "Il", role: "autre" },
      { mot: "faut", role: "conj" },
      { mot: "que", role: "autre" },
      { mot: "nous", role: "autre" },
      { mot: "partions", role: "conj" },
      { mot: "avant", role: "autre" },
      { mot: "que", role: "autre" },
      { mot: "la", role: "autre" },
      { mot: "pluie", role: "autre" },
      { mot: "ne", role: "autre" },
      { mot: "commence.", role: "conj" },
    ],
    propositions: [
      { texte: "Il faut", nature: "proposition principale, à verbe impersonnel", fonction: "—" },
      {
        texte: "que nous partions",
        nature: "proposition subordonnée conjonctive complétive",
        fonction: "sujet réel du verbe impersonnel « faut »",
      },
      {
        texte: "avant que la pluie ne commence",
        nature: "proposition subordonnée circonstancielle de temps",
        fonction: "complément circonstanciel de temps",
      },
    ],
    commentaire:
      "« Il » est un sujet apparent, sans contenu : la complétive est le sujet réel. C'est une analyse fine, et elle est attendue en troisième. Et le « ne » d'« avant que » est explétif : il ne nie rien.",
  },
  {
    id: "b8",
    jetons: [
      { mot: "Le", role: "autre" },
      { mot: "commerçant", role: "autre" },
      { mot: "dont", role: "autre" },
      { mot: "je", role: "autre" },
      { mot: "t'", role: "autre" },
      { mot: "ai parlé", role: "conj" },
      { mot: "a fermé", role: "conj" },
      { mot: "parce", role: "autre" },
      { mot: "qu'il", role: "autre" },
      { mot: "pleuvait.", role: "conj" },
    ],
    propositions: [
      { texte: "Le commerçant a fermé", nature: "proposition principale", fonction: "—" },
      {
        texte: "dont je t'ai parlé",
        nature: "proposition subordonnée relative déterminative",
        fonction: "complément de l'antécédent « commerçant »",
      },
      {
        texte: "parce qu'il pleuvait",
        nature: "proposition subordonnée circonstancielle de cause",
        fonction: "complément circonstanciel de cause",
      },
    ],
    commentaire:
      "Les trois subordonnées du programme ne sont pas toutes là, mais les deux qui y sont se distinguent nettement : la relative complète un nom, la circonstancielle complète la phrase.",
  },
];

const PHRASE_5_VIDE: Phrase5 = { id: "", jetons: [], propositions: [], commentaire: "—" };

export function QuestionCinqBepc() {
  const [i, setI] = useState(0);
  const [geste, setGeste] = useState(1);
  const [entoures, setEntoures] = useState<ReadonlyArray<number>>([]);
  const [alerte, setAlerte] = useState<string | null>(null);
  const [montre, setMontre] = useState(false);

  const p = PHRASES_5[i] ?? PHRASE_5_VIDE;
  const vrais = p.jetons.map((j, k) => (j.role === "conj" ? k : -1)).filter((k) => k >= 0);
  const tousTrouves = vrais.every((k) => entoures.includes(k)) && entoures.length === vrais.length;

  function cliquer(k: number) {
    const j = p.jetons[k];
    if (j === undefined) return;
    if (j.role === "faux") {
      setAlerte(j.pourquoi ?? "Ce n'est pas un verbe conjugué.");
      return;
    }
    if (j.role === "autre") {
      setAlerte("Ce mot n'est pas un verbe.");
      return;
    }
    setAlerte(null);
    setEntoures((e) => (e.includes(k) ? e.filter((x) => x !== k) : [...e, k]));
  }

  function suivante() {
    setI((n) => (n + 1) % PHRASES_5.length);
    setGeste(1);
    setEntoures([]);
    setAlerte(null);
    setMontre(false);
  }

  return (
    <div className="space-y-3">
      <p className="text-sm text-muted-foreground">
        Les cinq gestes de l'épreuve, dans l'ordre. Commence par entourer les verbes conjugués — et
        rien d'autre.
      </p>

      <div className="rounded-lg border border-border bg-background p-3">
        <p className="text-[11px] font-semibold text-muted-foreground">
          GESTE {geste} —{" "}
          {geste === 1
            ? "entourer les verbes conjugués"
            : geste === 2
              ? "repérer les mots subordonnants"
              : "nommer et donner la fonction"}
        </p>

        <p className="mt-2 text-base leading-8 text-foreground">
          {p.jetons.map((j, k) => (
            <button
              key={`${p.id}-${k}`}
              type="button"
              onClick={() => cliquer(k)}
              className="rounded px-1"
              style={{
                backgroundColor: entoures.includes(k) ? "rgba(37,99,235,0.18)" : "transparent",
                fontWeight: entoures.includes(k) ? 700 : 400,
                color: entoures.includes(k) ? PALETTE.blue : "inherit",
              }}
            >
              {j.mot}
            </button>
          ))}
        </p>

        {alerte !== null ? (
          <div className="mt-2">
            <Verdict tone="bad">
              <span className="font-semibold">Je refuse ce mot. </span>
              {alerte}
            </Verdict>
          </div>
        ) : null}

        <p className="mt-2 text-[11px] text-muted-foreground">
          Verbes conjugués entourés : {entoures.length}
          {tousTrouves ? ` — donc ${vrais.length} proposition${vrais.length > 1 ? "s" : ""}.` : "."}
        </p>

        {tousTrouves && geste === 1 ? (
          <button
            type="button"
            onClick={() => setGeste(2)}
            className="mt-2 rounded-lg bg-primary px-3 py-1.5 text-xs font-semibold text-primary-foreground"
          >
            {vrais.length === 1
              ? "Un seul verbe : la phrase est simple. Voir la correction"
              : "Passer au découpage"}
          </button>
        ) : null}

        {geste >= 2 ? (
          <div className="mt-3 space-y-2">
            {!montre ? (
              <button
                type="button"
                onClick={() => setMontre(true)}
                className="rounded-lg bg-primary px-3 py-1.5 text-xs font-semibold text-primary-foreground"
              >
                Voir le découpage, la nature et la fonction
              </button>
            ) : (
              <div className="space-y-1.5">
                {p.propositions.map((pr) => (
                  <div
                    key={pr.texte.slice(0, 24)}
                    className="rounded-md border border-border/60 p-2.5"
                  >
                    <p className="text-sm italic text-foreground">« {pr.texte} »</p>
                    <p className="mt-1 text-[11px]">
                      <span className="font-semibold" style={{ color: PALETTE.blue }}>
                        Nature :
                      </span>{" "}
                      {pr.nature}
                    </p>
                    {pr.fonction !== "—" ? (
                      <p className="text-[11px]">
                        <span className="font-semibold" style={{ color: PALETTE.green }}>
                          Fonction :
                        </span>{" "}
                        {pr.fonction}
                      </p>
                    ) : null}
                  </div>
                ))}
                <p
                  className="rounded-md px-2 py-1.5 text-[11px]"
                  style={{ backgroundColor: "rgba(202,138,4,0.12)", color: "#78350f" }}
                >
                  {p.commentaire}
                </p>
                <button
                  type="button"
                  onClick={suivante}
                  className="rounded-lg bg-primary px-3 py-1.5 text-xs font-semibold text-primary-foreground"
                >
                  Phrase suivante ({i + 1} / {PHRASES_5.length})
                </button>
              </div>
            )}
          </div>
        ) : null}
      </div>

      <Citation auteur="compte les verbes, et rien d'autre">
        Une phrase longue pleine de virgules peut n'avoir qu'un seul verbe conjugué, et être simple.
        Une phrase de sept mots peut en avoir trois. Les participes, les infinitifs et les
        participes présents ne comptent jamais.
      </Citation>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* 4. Ponctuer un dialogue                                             */
/* ------------------------------------------------------------------ */

type Signe = "deuxpoints" | "guillemets" | "tiret" | "virgule" | "interro" | "rien";

const NOM_SIGNE: Record<Signe, string> = {
  deuxpoints: "deux-points",
  guillemets: "guillemets",
  tiret: "tiret",
  virgule: "virgule",
  interro: "point d'interrogation",
  rien: "rien",
};

type TrouPonct = {
  avant: string;
  bon: Signe;
  apres: string;
  pourquoi: string;
};

type DialoguePonct = {
  id: string;
  titre: string;
  source?: string;
  trous: ReadonlyArray<TrouPonct>;
  verbesRepetes: number;
  propositionsVerbes: ReadonlyArray<{ a: string; b: string; note: string }>;
};

const DIALOGUES: ReadonlyArray<DialoguePonct> = [
  {
    id: "dg1",
    titre: "Au départ du car",
    trous: [
      {
        avant: "Le chauffeur annonça",
        bon: "deuxpoints",
        apres: " « Le car ne partira pas avant une heure. »",
        pourquoi:
          "Les deux-points annoncent la parole rapportée au discours direct, et les guillemets l'encadrent.",
      },
      {
        avant: "",
        bon: "tiret",
        apres: " Mais vous aviez annoncé six heures ! protesta un passager.",
        pourquoi:
          "Le tiret marque chaque changement d'interlocuteur dans un dialogue, et il dispense de répéter les guillemets.",
      },
      {
        avant: "— Je ne pars pas à moitié vide",
        bon: "virgule",
        apres: " répondit le chauffeur.",
        pourquoi:
          "La virgule précède toujours l'incise. Sans elle, la phrase ne tient pas. Et note l'inversion du sujet : « répondit le chauffeur ».",
      },
      {
        avant: "— Alors remboursez-nous",
        bon: "virgule",
        apres: " lança le passager.",
        pourquoi: "Même règle : virgule avant l'incise.",
      },
    ],
    verbesRepetes: 4,
    propositionsVerbes: [
      {
        a: "a dit",
        b: "annonça",
        note: "Neutre, mais plus précis : il s'agit d'une information publique.",
      },
      { a: "a dit", b: "protesta", note: "Ajoute l'intention : le passager conteste." },
      { a: "a dit", b: "répondit", note: "Marque la place dans l'échange." },
      { a: "a dit", b: "lança", note: "Ajoute la brusquerie, et le sous-entendu d'un défi." },
    ],
  },
  {
    id: "dg2",
    titre: "Devant le bac à ordures",
    trous: [
      {
        avant: "Ma mère demanda",
        bon: "deuxpoints",
        apres: " « Depuis quand le bac a-t-il disparu ? »",
        pourquoi: "Deux-points, puis guillemets.",
      },
      {
        avant: "« Depuis janvier",
        bon: "virgule",
        apres: " » répondit le voisin.",
        pourquoi: "Virgule à l'intérieur des guillemets, avant l'incise.",
      },
      {
        avant: "— Et personne n'a écrit à la mairie",
        bon: "interro",
        apres: "",
        pourquoi:
          "Le point d'interrogation reste à l'intérieur de la parole qu'il concerne, avant l'incise s'il y en a une.",
      },
    ],
    verbesRepetes: 2,
    propositionsVerbes: [
      {
        a: "dit",
        b: "demanda",
        note: "Le verbe doit correspondre au type de phrase : ici une question.",
      },
      { a: "dit", b: "soupira", note: "Ajoute la lassitude, et transforme la scène." },
    ],
  },
  {
    id: "dg3",
    titre: "Au stand du composteur",
    source: "d'après un sujet de BEPC",
    trous: [
      {
        avant: "« Ça ne sent pas mauvais",
        bon: "interro",
        apres: " » demanda la visiteuse.",
        pourquoi: "Point d'interrogation à l'intérieur des guillemets.",
      },
      {
        avant: "— Non",
        bon: "virgule",
        apres: " expliqua l'élève, parce qu'on n'y met ni viande ni poisson.",
        pourquoi:
          "Virgule avant l'incise, et l'incise peut couper la réplique en deux — on remet alors une virgule après.",
      },
      {
        avant: "— Vous permettez que j'en prenne",
        bon: "interro",
        apres: "",
        pourquoi: "Question, donc point d'interrogation.",
      },
    ],
    verbesRepetes: 2,
    propositionsVerbes: [
      { a: "dit", b: "expliqua", note: "Ajoute une intention pédagogique." },
      { a: "dit", b: "s'étonna", note: "Transforme la question en surprise." },
    ],
  },
];

const DIALOGUE_VIDE: DialoguePonct = {
  id: "",
  titre: "—",
  trous: [],
  verbesRepetes: 0,
  propositionsVerbes: [],
};

export function PonctuerDialogue() {
  const [i, setI] = useState(0);
  const [atelier, setAtelier] = useState<"ponctuer" | "verbes">("ponctuer");
  const [reps, setReps] = useState<Record<number, Signe>>({});
  const [ouvert, setOuvert] = useState<number | null>(null);

  const d = DIALOGUES[i] ?? DIALOGUE_VIDE;
  const justes = d.trous.filter((t, k) => reps[k] === t.bon).length;

  return (
    <div className="space-y-3">
      <div>
        <Choice<"ponctuer" | "verbes">
          label="Atelier"
          value={atelier}
          options={[
            { value: "ponctuer", label: "poser la ponctuation" },
            { value: "verbes", label: "varier les verbes de parole" },
          ]}
          onChange={setAtelier}
        />
      </div>

      {atelier === "ponctuer" ? (
        <div className="rounded-lg border border-border bg-background p-3">
          <p className="text-xs font-semibold text-foreground">
            {d.titre}
            {d.source ? (
              <span className="ml-1 font-normal text-muted-foreground">({d.source})</span>
            ) : null}
          </p>

          <div className="mt-2 space-y-2">
            {d.trous.map((t, k) => (
              <div key={`${d.id}-${k}`} className="rounded-md border border-border/60 p-2.5">
                <p className="text-sm text-foreground">
                  {t.avant}
                  <button
                    type="button"
                    onClick={() => setOuvert(ouvert === k ? null : k)}
                    className="mx-1 rounded px-1.5 py-0.5 font-semibold"
                    style={{
                      backgroundColor:
                        reps[k] === undefined
                          ? "rgba(100,116,139,0.16)"
                          : reps[k] === t.bon
                            ? "rgba(21,128,61,0.16)"
                            : "rgba(185,28,28,0.14)",
                      color: PALETTE.slate,
                    }}
                  >
                    {reps[k] === undefined ? "?" : NOM_SIGNE[reps[k] ?? "rien"]}
                  </button>
                  {t.apres}
                </p>

                {ouvert === k ? (
                  <div className="mt-2">
                    <div className="flex flex-wrap gap-1.5">
                      {(Object.keys(NOM_SIGNE) as ReadonlyArray<Signe>).map((s) => (
                        <button
                          key={s}
                          type="button"
                          onClick={() => setReps((r) => ({ ...r, [k]: s }))}
                          className="rounded-md border px-2 py-1 text-[11px]"
                          style={{
                            borderColor: reps[k] === s ? PALETTE.blue : "rgba(100,116,139,0.3)",
                            backgroundColor: reps[k] === s ? "rgba(37,99,235,0.10)" : "transparent",
                          }}
                        >
                          {NOM_SIGNE[s]}
                        </button>
                      ))}
                    </div>
                    {reps[k] !== undefined ? (
                      <div className="mt-2">
                        <Verdict tone={reps[k] === t.bon ? "ok" : "bad"}>
                          <span className="font-semibold">{NOM_SIGNE[t.bon]}. </span>
                          {t.pourquoi}
                        </Verdict>
                      </div>
                    ) : null}
                  </div>
                ) : null}
              </div>
            ))}
          </div>

          <p className="mt-2 text-[11px] text-muted-foreground">
            {justes} / {d.trous.length} signes justes.
          </p>

          <button
            type="button"
            onClick={() => {
              setI((n) => (n + 1) % DIALOGUES.length);
              setReps({});
              setOuvert(null);
            }}
            className="mt-2 rounded-lg bg-primary px-3 py-1.5 text-xs font-semibold text-primary-foreground"
          >
            Dialogue suivant ({i + 1} / {DIALOGUES.length})
          </button>
        </div>
      ) : (
        <div className="rounded-lg border border-border bg-background p-3">
          <p className="text-xs font-semibold text-foreground">
            {d.titre} — ce dialogue employait {d.verbesRepetes} fois le même verbe de parole
          </p>
          <div className="mt-2 space-y-1.5">
            {d.propositionsVerbes.map((v) => (
              <div key={v.b} className="rounded-md border border-border/60 p-2.5">
                <p className="text-sm">
                  <span style={{ color: PALETTE.red, textDecoration: "line-through" }}>{v.a}</span>
                  <span className="mx-2 text-muted-foreground">→</span>
                  <span className="font-semibold" style={{ color: PALETTE.green }}>
                    {v.b}
                  </span>
                </p>
                <p className="mt-0.5 text-[11px] text-muted-foreground">{v.note}</p>
              </div>
            ))}
          </div>
          <div
            className="mt-3 rounded-md px-2.5 py-2 text-[11px]"
            style={{ backgroundColor: "rgba(100,116,139,0.10)" }}
          >
            <p className="font-semibold text-foreground">La réserve de verbes de parole</p>
            <p className="mt-1 text-muted-foreground">
              <span className="font-semibold">neutres</span> : dire, déclarer, répondre, ajouter,
              reprendre. <span className="font-semibold">avec un volume</span> : murmurer,
              chuchoter, crier, hurler, souffler.{" "}
              <span className="font-semibold">avec une intention</span> : expliquer, objecter,
              protester, avouer, promettre, menacer, supplier.{" "}
              <span className="font-semibold">avec un sentiment</span> : soupirer, s'exclamer,
              grommeler, s'étonner.
            </p>
          </div>
        </div>
      )}

      <Citation auteur="le verbe introducteur fait la moitié du travail">
        « Je viendrai », promit-il. « Je viendrai », grommela-t-il. Le même énoncé, et deux scènes
        différentes. Une copie où tout le monde « dit » est une copie pauvre.
      </Citation>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* 5. Du direct à l'indirect                                           */
/* ------------------------------------------------------------------ */

type EtapeDI = {
  nom: string;
  texte: string;
  /** Les mots qui viennent de changer. */
  changes: ReadonlyArray<string>;
  note: string;
};

type PhraseDI = {
  id: string;
  type: "declaration" | "totale" | "partielle" | "ordre";
  introducteurPresent: boolean;
  direct: string;
  etapes: ReadonlyArray<EtapeDI>;
  final: string;
};

const NOM_TYPE: Record<PhraseDI["type"], string> = {
  declaration: "déclaration → « que »",
  totale: "question totale → « si »",
  partielle: "question partielle → le mot interrogatif reste",
  ordre: "ordre → « de » + infinitif",
};

const PHRASES_DI: ReadonlyArray<PhraseDI> = [
  {
    id: "di1",
    type: "declaration",
    introducteurPresent: false,
    direct: "Il m'a dit : « Je t'attendrai ici jusqu'à demain. »",
    etapes: [
      {
        nom: "1. ponctuation et subordonnant",
        texte: "Il m'a dit que je t'attendrai ici jusqu'à demain.",
        changes: ["que"],
        note: "Les deux-points et les guillemets disparaissent, remplacés par la conjonction « que ».",
      },
      {
        nom: "2. pronoms et possessifs",
        texte: "Il m'a dit qu'il m'attendrait ici jusqu'à demain.",
        changes: ["il", "m'"],
        note: "« Je » devient « il », « t' » devient « m' » : celui qui parle n'est plus le même.",
      },
      {
        nom: "3. temps",
        texte: "Il m'a dit qu'il m'attendrait ici jusqu'à demain.",
        changes: ["attendrait"],
        note: "L'introducteur est au passé, donc concordance : futur « attendrai » → conditionnel « attendrait ».",
      },
      {
        nom: "4. temps et lieu",
        texte: "Il m'a dit qu'il m'attendrait là jusqu'au lendemain.",
        changes: ["là", "le lendemain"],
        note: "« Ici » → « là », « demain » → « le lendemain ».",
      },
    ],
    final: "Il m'a dit qu'il m'attendrait là jusqu'au lendemain.",
  },
  {
    id: "di2",
    type: "totale",
    introducteurPresent: false,
    direct: "Elle m'a demandé : « As-tu fini ton devoir ? »",
    etapes: [
      {
        nom: "1. ponctuation et subordonnant",
        texte: "Elle m'a demandé si as-tu fini ton devoir.",
        changes: ["si"],
        note: "Question TOTALE — elle appelle oui ou non — donc le subordonnant est « si ». Et le point d'interrogation disparaît : une question rapportée n'est plus une question.",
      },
      {
        nom: "2. pronoms et ordre",
        texte: "Elle m'a demandé si j'avais fini mon devoir.",
        changes: ["j'", "mon"],
        note: "L'inversion du sujet disparaît aussi : on revient à l'ordre sujet-verbe.",
      },
      {
        nom: "3. temps",
        texte: "Elle m'a demandé si j'avais fini mon devoir.",
        changes: ["avais fini"],
        note: "Passé composé « as fini » → plus-que-parfait « avais fini ».",
      },
      {
        nom: "4. temps et lieu",
        texte: "Elle m'a demandé si j'avais fini mon devoir.",
        changes: [],
        note: "Rien à changer : aucun indicateur de temps ou de lieu dans cette phrase.",
      },
    ],
    final: "Elle m'a demandé si j'avais fini mon devoir.",
  },
  {
    id: "di3",
    type: "partielle",
    introducteurPresent: false,
    direct: "Le professeur nous a demandé : « Qu'est-ce que vous avez compris ? »",
    etapes: [
      {
        nom: "1. ponctuation et subordonnant",
        texte: "Le professeur nous a demandé ce que vous avez compris.",
        changes: ["ce que"],
        note: "Cas particulier : « qu'est-ce que » devient « CE QUE », et « qu'est-ce qui » devient « ce qui ». « Il a demandé qu'est-ce que » est une faute lourde.",
      },
      {
        nom: "2. pronoms",
        texte: "Le professeur nous a demandé ce que nous avions compris.",
        changes: ["nous"],
        note: "« Vous » devient « nous », puisque c'est nous qui rapportons.",
      },
      {
        nom: "3. temps",
        texte: "Le professeur nous a demandé ce que nous avions compris.",
        changes: ["avions compris"],
        note: "Passé composé → plus-que-parfait.",
      },
      {
        nom: "4. temps et lieu",
        texte: "Le professeur nous a demandé ce que nous avions compris.",
        changes: [],
        note: "Rien à changer.",
      },
    ],
    final: "Le professeur nous a demandé ce que nous avions compris.",
  },
  {
    id: "di4",
    type: "ordre",
    introducteurPresent: false,
    direct: "Ma mère m'a dit : « Ne rentre pas trop tard ! »",
    etapes: [
      {
        nom: "1. ponctuation et subordonnant",
        texte: "Ma mère m'a dit de ne rentre pas trop tard.",
        changes: ["de"],
        note: "Un ORDRE se rapporte par « de » + infinitif. C'est le seul cas où la subordonnée disparaît. Et le point d'exclamation s'en va : l'ordre a perdu son intonation.",
      },
      {
        nom: "2. le verbe à l'infinitif",
        texte: "Ma mère m'a dit de ne pas rentrer trop tard.",
        changes: ["ne pas rentrer"],
        note: "La négation se place en BLOC devant l'infinitif : « de ne pas rentrer », et non « de ne rentrer pas ».",
      },
      {
        nom: "3. temps",
        texte: "Ma mère m'a dit de ne pas rentrer trop tard.",
        changes: [],
        note: "Un infinitif n'a pas de temps à accorder : l'étape ne s'applique pas.",
      },
      {
        nom: "4. temps et lieu",
        texte: "Ma mère m'a dit de ne pas rentrer trop tard.",
        changes: [],
        note: "Rien à changer.",
      },
    ],
    final: "Ma mère m'a dit de ne pas rentrer trop tard.",
  },
  {
    id: "di5",
    type: "declaration",
    introducteurPresent: true,
    direct: "Il dit : « Je partirai demain. »",
    etapes: [
      {
        nom: "1. ponctuation et subordonnant",
        texte: "Il dit que je partirai demain.",
        changes: ["que"],
        note: "Comme toujours.",
      },
      {
        nom: "2. pronoms",
        texte: "Il dit qu'il partira demain.",
        changes: ["il"],
        note: "« Je » devient « il ».",
      },
      {
        nom: "3. temps",
        texte: "Il dit qu'il partira demain.",
        changes: [],
        note: "L'INTRODUCTEUR EST AU PRÉSENT : rien ne bouge dans les temps. Je saute cette étape, et c'est le piège qui sauve la moitié des points.",
      },
      {
        nom: "4. temps et lieu",
        texte: "Il dit qu'il partira demain.",
        changes: [],
        note: "Rien non plus : « demain » reste « demain ». Regarde toujours le verbe introducteur avant de toucher aux temps.",
      },
    ],
    final: "Il dit qu'il partira demain.",
  },
  {
    id: "di6",
    type: "partielle",
    introducteurPresent: false,
    direct: "Il m'a demandé : « Quand pars-tu ? »",
    etapes: [
      {
        nom: "1. ponctuation et subordonnant",
        texte: "Il m'a demandé quand pars-tu.",
        changes: ["quand"],
        note: "Question PARTIELLE avec un mot interrogatif : ce mot reste tel quel.",
      },
      {
        nom: "2. pronoms et ordre",
        texte: "Il m'a demandé quand je pars.",
        changes: ["je"],
        note: "L'inversion disparaît.",
      },
      {
        nom: "3. temps",
        texte: "Il m'a demandé quand je partais.",
        changes: ["partais"],
        note: "Présent → imparfait.",
      },
      {
        nom: "4. temps et lieu",
        texte: "Il m'a demandé quand je partais.",
        changes: [],
        note: "Rien à changer.",
      },
    ],
    final: "Il m'a demandé quand je partais.",
  },
];

const PHRASE_DI_VIDE: PhraseDI = {
  id: "",
  type: "declaration",
  introducteurPresent: false,
  direct: "—",
  etapes: [],
  final: "—",
};

export function DirectIndirect() {
  const [i, setI] = useState(0);
  const [etape, setEtape] = useState(-1);

  const p = PHRASES_DI[i] ?? PHRASE_DI_VIDE;
  const e = etape >= 0 ? p.etapes[etape] : undefined;

  return (
    <div className="space-y-3">
      <p className="text-sm text-muted-foreground">
        Quatre changements, dans l'ordre. Avant le troisième, regarde le verbe introducteur : c'est
        lui qui commande.
      </p>

      <div className="rounded-lg border border-border bg-background p-3">
        <p className="text-[11px] font-semibold" style={{ color: PALETTE.purple }}>
          {NOM_TYPE[p.type]}
          {p.introducteurPresent ? " · introducteur au PRÉSENT" : " · introducteur au passé"}
        </p>

        <p className="mt-2 text-base text-foreground">{etape < 0 ? p.direct : (e?.texte ?? "")}</p>

        {e !== undefined ? (
          <>
            <div className="mt-2 flex flex-wrap gap-1.5">
              {e.changes.length > 0 ? (
                e.changes.map((m) => (
                  <span
                    key={m}
                    className="rounded px-2 py-0.5 text-[11px] font-semibold"
                    style={{ backgroundColor: "rgba(21,128,61,0.14)", color: "#14532d" }}
                  >
                    {m}
                  </span>
                ))
              ) : (
                <span
                  className="rounded px-2 py-0.5 text-[11px]"
                  style={{ backgroundColor: "rgba(100,116,139,0.14)", color: PALETTE.slate }}
                >
                  rien ne change à cette étape
                </span>
              )}
            </div>
            <div className="mt-2">
              <Verdict tone={e.changes.length > 0 ? "ok" : "warn"}>
                <span className="font-semibold">{e.nom}. </span>
                {e.note}
              </Verdict>
            </div>
          </>
        ) : null}

        <div className="mt-3 flex flex-wrap gap-2">
          {etape < p.etapes.length - 1 ? (
            <button
              type="button"
              onClick={() => setEtape((n) => n + 1)}
              className="rounded-lg bg-primary px-3 py-1.5 text-xs font-semibold text-primary-foreground"
            >
              {etape < 0 ? "Commencer la transformation" : "Changement suivant"}
            </button>
          ) : (
            <>
              <span
                className="rounded px-2.5 py-1.5 text-xs font-semibold"
                style={{ backgroundColor: "rgba(21,128,61,0.12)", color: "#14532d" }}
              >
                {p.final}
              </span>
              <button
                type="button"
                onClick={() => {
                  setI((n) => (n + 1) % PHRASES_DI.length);
                  setEtape(-1);
                }}
                className="rounded-lg bg-primary px-3 py-1.5 text-xs font-semibold text-primary-foreground"
              >
                Phrase suivante ({i + 1} / {PHRASES_DI.length})
              </button>
            </>
          )}
        </div>
      </div>

      <Citation auteur="regarde le verbe introducteur avant de toucher aux temps">
        « Il a dit qu'il viendrait le lendemain » mais « il dit qu'il viendra demain ». Beaucoup
        d'élèves appliquent la concordance partout, et perdent la moitié des points de la question.
      </Citation>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* 6. Les quatre formes du même épisode                                */
/* ------------------------------------------------------------------ */

type FormeDiscours = "direct" | "indirect" | "libre" | "narrativise";

const NOM_FORME: Record<FormeDiscours, string> = {
  direct: "direct",
  indirect: "indirect",
  libre: "indirect libre",
  narrativise: "narrativisé",
};

type Episode = {
  id: string;
  titre: string;
  versions: Record<FormeDiscours, string>;
  /** Longueur relative et distance au personnage, de 0 à 100. */
  mesures: Record<FormeDiscours, { longueur: number; distance: number }>;
};

const EPISODES: ReadonlyArray<Episode> = [
  {
    id: "ep1",
    titre: "Le car qui ne part pas",
    versions: {
      direct:
        "— Vous aviez dit six heures ! cria le passager.\n— Je ne pars pas à moitié vide, répondit le chauffeur.",
      indirect:
        "Le passager rappela au chauffeur qu'il avait annoncé six heures, et celui-ci répondit qu'il ne partirait pas à moitié vide.",
      libre:
        "Six heures, il avait dit six heures. Et maintenant on attendait que le car se remplisse. Combien de temps encore ?",
      narrativise: "Le passager protesta ; le chauffeur refusa de partir.",
    },
    mesures: {
      direct: { longueur: 85, distance: 15 },
      indirect: { longueur: 60, distance: 70 },
      libre: { longueur: 70, distance: 5 },
      narrativise: { longueur: 20, distance: 90 },
    },
  },
  {
    id: "ep2",
    titre: "L'aveu",
    versions: {
      direct: "Il baissa les yeux. « C'est moi qui ai perdu le cahier », dit-il enfin.",
      indirect: "Il baissa les yeux et avoua enfin que c'était lui qui avait perdu le cahier.",
      libre:
        "Il baissa les yeux. C'était lui. Il le savait depuis trois jours et il n'avait rien dit. Comment le dire maintenant ?",
      narrativise: "Il finit par avouer.",
    },
    mesures: {
      direct: { longueur: 70, distance: 20 },
      indirect: { longueur: 55, distance: 65 },
      libre: { longueur: 80, distance: 5 },
      narrativise: { longueur: 10, distance: 95 },
    },
  },
  {
    id: "ep3",
    titre: "L'annonce du résultat",
    versions: {
      direct: "« Tu es reçue », murmura sa mère en pliant la lettre.",
      indirect: "Sa mère lui annonça, en pliant la lettre, qu'elle était reçue.",
      libre:
        "Elle était reçue. Reçue. Sa mère pliait la lettre lentement, comme si le papier pouvait se déchirer.",
      narrativise: "Sa mère lui annonça le résultat.",
    },
    mesures: {
      direct: { longueur: 60, distance: 20 },
      indirect: { longueur: 55, distance: 65 },
      libre: { longueur: 75, distance: 5 },
      narrativise: { longueur: 15, distance: 90 },
    },
  },
  {
    id: "ep4",
    titre: "La dispute du marché",
    versions: {
      direct:
        "— Ce prix-là, je ne le paierai pas.\n— Alors allez voir ailleurs, madame.\n— Comptez sur moi.",
      indirect:
        "La cliente déclara qu'elle ne paierait pas ce prix ; la vendeuse lui conseilla d'aller voir ailleurs, et elle répondit qu'elle n'y manquerait pas.",
      libre:
        "Ce prix-là, non. Elle irait ailleurs, voilà tout. Et tant pis si elle devait traverser tout le marché.",
      narrativise: "Elles se disputèrent sur le prix, et la cliente s'en alla.",
    },
    mesures: {
      direct: { longueur: 90, distance: 15 },
      indirect: { longueur: 65, distance: 70 },
      libre: { longueur: 65, distance: 5 },
      narrativise: { longueur: 25, distance: 90 },
    },
  },
];

const EPISODE_VIDE: Episode = {
  id: "",
  titre: "—",
  versions: { direct: "—", indirect: "—", libre: "—", narrativise: "—" },
  mesures: {
    direct: { longueur: 0, distance: 0 },
    indirect: { longueur: 0, distance: 0 },
    libre: { longueur: 0, distance: 0 },
    narrativise: { longueur: 0, distance: 0 },
  },
};

const IDENTIFIER: ReadonlyArray<Question> = [
  {
    id: "fd1",
    enonce: "« Le chauffeur refusa de partir avant d'avoir rempli son car. » Quelle forme ?",
    options: [
      {
        texte: "Narrativisé",
        bonne: true,
        retour:
          "Les paroles sont résumées en un verbe, « refusa », sans qu'aucun mot du chauffeur ne soit rapporté. Effet : l'accélération.",
      },
      { texte: "Indirect", bonne: false, retour: "Il n'y a aucune subordonnée en « que »." },
      { texte: "Indirect libre", bonne: false, retour: "Aucune trace de la parole elle-même." },
    ],
  },
  {
    id: "fd2",
    enonce: "« — Vous aviez dit six heures ! cria le passager. » Quelle forme ?",
    options: [
      {
        texte: "Direct",
        bonne: true,
        retour:
          "Quatre marques : le tiret, les mots exacts, le point d'exclamation à l'intérieur de la parole, et l'incise avec inversion du sujet.",
      },
      { texte: "Indirect libre", bonne: false, retour: "L'incise et le tiret l'excluent." },
      { texte: "Narrativisé", bonne: false, retour: "Les paroles sont rapportées, pas résumées." },
    ],
  },
  {
    id: "fd3",
    enonce:
      "« Il regarda sa montre. Sept heures passées. Il n'arriverait jamais à temps. Et le professeur fermait la porte à la minute, tout le monde le savait. » Quelle forme ?",
    options: [
      {
        texte: "Indirect libre",
        bonne: true,
        retour:
          "Ni guillemets, ni subordonnée, ni verbe introducteur. Troisième personne et conditionnel — les temps de l'indirect — mais la phrase nominale « Sept heures passées » et le « tout le monde le savait » viennent du personnage. Effet : la distance disparaît.",
      },
      { texte: "Narrativisé", bonne: false, retour: "Rien n'est résumé : nous suivons la pensée." },
      {
        texte: "Indirect",
        bonne: false,
        retour: "Il n'y a aucun « que », aucun verbe introducteur.",
      },
    ],
  },
  {
    id: "fd4",
    enonce:
      "« Il expliqua au passager qu'il ne partirait pas à moitié vide, et que c'était ainsi depuis toujours. » Quelle forme ?",
    options: [
      {
        texte: "Indirect",
        bonne: true,
        retour:
          "Verbe introducteur « expliqua », subordonnées en « que », troisième personne, concordance des temps. Effet : la mise à distance — le contenu est précis, mais on n'entend plus la voix.",
      },
      { texte: "Direct", bonne: false, retour: "Aucun guillemet, aucun tiret." },
      {
        texte: "Indirect libre",
        bonne: false,
        retour: "Le verbe introducteur et les « que » l'excluent.",
      },
    ],
  },
  {
    id: "fd5",
    enonce: "« Elle refusa. » Quelle forme, et quel effet ?",
    options: [
      {
        texte: "Narrativisé — il accélère et passe sur ce qui ne compte pas",
        bonne: true,
        retour:
          "Deux mots pour un échange qui a pu durer dix minutes. C'est l'outil de l'accélération du récit.",
      },
      { texte: "Direct", bonne: false, retour: "Aucune parole n'est rapportée." },
      {
        texte: "Indirect libre",
        bonne: false,
        retour: "Aucune pensée n'est donnée de l'intérieur.",
      },
    ],
  },
  {
    id: "fd6",
    enonce: "« La pluie, encore. Est-ce que cela ne finirait jamais ? » Qui pose cette question ?",
    options: [
      {
        texte: "Le personnage, dans sa tête : c'est du discours indirect libre",
        bonne: true,
        retour:
          "Une question au milieu d'un récit à la troisième personne, sans guillemets : c'est la marque la plus sûre de l'indirect libre.",
      },
      {
        texte: "Le narrateur",
        bonne: false,
        retour: "Un narrateur ne s'interroge pas ainsi sur la météo du personnage.",
      },
      { texte: "Le lecteur", bonne: false, retour: "Le texte ne s'adresse pas au lecteur." },
    ],
  },
  {
    id: "fd7",
    enonce: "Pourquoi les romanciers emploient-ils l'indirect libre ?",
    options: [
      {
        texte:
          "Parce qu'il supprime la distance avec le personnage sans casser le récit — et parce qu'il est ambigu : on ne sait pas toujours si c'est le narrateur qui juge ou le personnage qui pense",
        bonne: true,
        retour: "Cette ambiguïté est sa force, et un auteur ironique s'en sert beaucoup.",
      },
      {
        texte: "Parce qu'il est plus court",
        bonne: false,
        retour: "Il ne l'est pas nécessairement.",
      },
      {
        texte: "Parce qu'il évite les fautes de ponctuation",
        bonne: false,
        retour: "Ce n'est pas une raison littéraire.",
      },
    ],
  },
  {
    id: "fd8",
    enonce: "Que faut-il faire dans une rédaction ?",
    options: [
      {
        texte:
          "Alterner les quatre formes : le direct au moment important, l'indirect pour les échanges utiles, l'indirect libre pour l'intériorité, le narrativisé pour accélérer",
        bonne: true,
        retour:
          "Une rédaction qui n'emploie qu'une seule forme est plate, quelle que soit celle qu'elle a choisie.",
      },
      {
        texte: "Tout mettre au discours direct, c'est plus vivant",
        bonne: false,
        retour: "Si tout est au direct, rien ne ressort.",
      },
      {
        texte: "Éviter les dialogues",
        bonne: false,
        retour: "Ils sont au contraire ce qui met le lecteur dans la scène.",
      },
    ],
  },
  {
    id: "fd9",
    enonce:
      "« Ce prix-là, non. Elle irait ailleurs, voilà tout. » À quoi reconnaît-on la forme employée ?",
    options: [
      {
        texte:
          "Indirect libre : troisième personne et conditionnel, mais vocabulaire et rythme de la parole — « voilà tout » n'est pas du narrateur",
        bonne: true,
        retour:
          "C'est le critère décisif : un vocabulaire qui n'est pas celui du narrateur mais du personnage.",
      },
      {
        texte: "Direct, parce qu'on entend la voix",
        bonne: false,
        retour: "Il n'y a ni guillemets ni tirets.",
      },
      { texte: "Narrativisé", bonne: false, retour: "Rien n'est résumé." },
    ],
  },
  {
    id: "fd10",
    enonce: "Au BEPC, on demande la forme ET l'effet. Quel moule de réponse employer ?",
    options: [
      {
        texte:
          "Nature du procédé, citation avec la ligne, caractérisation technique, effet produit",
        bonne: true,
        retour:
          "Quatre mouvements, deux points. Le « effet produit » est ce que les élèves oublient, et c'est la moitié de la note.",
      },
      {
        texte: "Juste nommer la forme",
        bonne: false,
        retour: "Cela ne vaut qu'un point sur deux.",
      },
      { texte: "Recopier le passage", bonne: false, retour: "Recopier n'est pas citer." },
    ],
  },
];

export function FormesDiscours() {
  const [atelier, setAtelier] = useState<"reecrire" | "identifier">("reecrire");
  const [i, setI] = useState(0);
  const [forme, setForme] = useState<FormeDiscours>("direct");

  const ep = EPISODES[i] ?? EPISODE_VIDE;
  const m = ep.mesures[forme];

  return (
    <div className="space-y-3">
      <div>
        <Choice<"reecrire" | "identifier">
          label="Atelier"
          value={atelier}
          options={[
            { value: "reecrire", label: "le même épisode, quatre formes" },
            { value: "identifier", label: "identifier et nommer l'effet" },
          ]}
          onChange={setAtelier}
        />
      </div>

      {atelier === "reecrire" ? (
        <div className="rounded-lg border border-border bg-background p-3">
          <p className="text-xs font-semibold text-foreground">{ep.titre}</p>

          <div className="mt-2 flex flex-wrap gap-1.5">
            {(Object.keys(NOM_FORME) as ReadonlyArray<FormeDiscours>).map((f) => (
              <button
                key={f}
                type="button"
                onClick={() => setForme(f)}
                className="rounded-md border px-2.5 py-1 text-xs"
                style={{
                  borderColor: forme === f ? PALETTE.blue : "rgba(100,116,139,0.3)",
                  backgroundColor: forme === f ? "rgba(37,99,235,0.10)" : "transparent",
                }}
              >
                {NOM_FORME[f]}
              </button>
            ))}
          </div>

          <div className="mt-3 rounded-md border border-border/60 p-2.5">
            {ep.versions[forme].split("\n").map((l) => (
              <p key={l.slice(0, 20)} className="text-sm text-foreground">
                {l}
              </p>
            ))}
          </div>

          <div className="mt-3 space-y-2">
            {(
              [
                { label: "temps de lecture", v: m.longueur, c: PALETTE.blue },
                { label: "distance au personnage", v: m.distance, c: PALETTE.orange },
              ] as const
            ).map((g) => (
              <div key={g.label} className="flex items-center gap-2">
                <span className="w-40 text-[11px] text-muted-foreground">{g.label}</span>
                <div className="h-2.5 flex-1 overflow-hidden rounded bg-muted">
                  <div
                    className="h-full rounded"
                    style={{ width: `${g.v}%`, backgroundColor: g.c }}
                  />
                </div>
              </div>
            ))}
          </div>

          <p className="mt-2 text-[11px] text-muted-foreground">
            {forme === "direct"
              ? "Le direct ralentit et met dans la scène : à employer au moment important — la dispute, l'aveu, la décision."
              : forme === "indirect"
                ? "L'indirect met à distance tout en restant précis : pour les échanges utiles mais sans relief."
                : forme === "libre"
                  ? "L'indirect libre supprime la distance : nous ne lisons pas que le personnage pense, nous pensons avec lui."
                  : "Le narrativisé accélère : on passe sur ce qui ne compte pas."}
          </p>

          <button
            type="button"
            onClick={() => {
              setI((n) => (n + 1) % EPISODES.length);
              setForme("direct");
            }}
            className="mt-3 rounded-lg bg-primary px-3 py-1.5 text-xs font-semibold text-primary-foreground"
          >
            Épisode suivant ({i + 1} / {EPISODES.length})
          </button>
        </div>
      ) : (
        <Qcm
          consigne="Identifie la forme, et nomme l'effet. L'indirect libre est le plus représenté, parce que c'est celui que personne ne reconnaît."
          questions={IDENTIFIER}
          conclusion={
            <Citation auteur="les quatre formes racontent le même épisode">
              Un car qui ne part pas, raconté quatre fois. L'auteur choisit chaque fois selon ce
              qu'il veut faire ressentir — et c'est exactement le choix que tu auras à faire dans ta
              rédaction.
            </Citation>
          }
        />
      )}

      {atelier === "reecrire" ? (
        <Citation auteur="un récit réussi les alterne">
          Si tout ton récit est au discours direct, rien ne ressort. Garde-le pour les moments qui
          comptent, et rapporte le reste autrement.
        </Citation>
      ) : null}
    </div>
  );
}
