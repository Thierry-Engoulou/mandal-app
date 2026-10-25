import { useState } from "react";
import { PALETTE, Stat, Verdict } from "./controls";
import {
  Citation,
  JeuTri,
  Parcours,
  Qcm,
  type Etape,
  type ItemTri,
  type Question,
} from "./philo-noyau";

/** Philosophie Terminale C et D — chapitres 10 et 11 :
 *  la science, l'existence et la mort. */

/* ------------------------------------------------------------------ */
/* 1. Opinion, croyance, science                                       */
/* ------------------------------------------------------------------ */

const ENONCES_SC: ReadonlyArray<ItemTri> = [
  {
    id: "o1",
    texte: "La Terre tourne autour du Soleil.",
    bonne: "science",
    pourquoi:
      "Rationnelle, méthodique, vérifiable. Et réfutable : on sait ce qui la démentirait — des parallaxes stellaires incompatibles, par exemple.",
  },
  {
    id: "o2",
    texte: "Le rouge porte chance aux examens.",
    bonne: "opinion",
    pourquoi:
      "Aucune raison donnée, et la croyance tient de sa répétition. On est même devant un post hoc ergo propter hoc : une réussite suivie d'une couleur n'en vient pas.",
  },
  {
    id: "o3",
    texte: "Au niveau de la mer, l'eau bout à 100 degrés Celsius.",
    bonne: "science",
    pourquoi:
      "Mesurable, reproductible, et déjà corrigée une fois par la prise en compte de l'altitude.",
  },
  {
    id: "o4",
    texte: "Dieu existe.",
    bonne: "croyance",
    pourquoi:
      "Une croyance assumée comme telle, et c'est ce qui la distingue de l'opinion : elle ne revendique pas de preuve. Kant le dit autrement — Dieu n'est pas un objet d'expérience possible, donc pas un objet de connaissance.",
  },
  {
    id: "o5",
    texte: "Les gens du Nord sont plus travailleurs que ceux du Sud.",
    bonne: "opinion",
    pourquoi:
      "Généralisation hâtive sur un groupe entier, et jamais mise à l'épreuve. C'est exactement ce que Bachelard appelle un obstacle épistémologique.",
  },
  {
    id: "o6",
    texte: "Tous les corps tombent avec la même accélération dans le vide.",
    bonne: "science",
    pourquoi:
      "L'exemple-type de Popper : on sait précisément ce qui la réfuterait, et c'est pourquoi elle est scientifique.",
  },
  {
    id: "o7",
    texte: "Tout événement de ta vie était inscrit dans ton destin.",
    bonne: "opinion",
    pourquoi:
      "Irréfutable, et c'est sa faiblesse : si tu réussis c'était écrit, si tu échoues c'était écrit aussi. Elle n'interdit rien, donc elle n'apprend rien.",
  },
  {
    id: "o8",
    texte: "Il existe une vie après la mort.",
    bonne: "croyance",
    pourquoi:
      "Hors de portée de l'expérience, et assumée comme telle par ceux qui la tiennent. La science n'a pas à en juger : ce n'est pas une question de fait.",
  },
  {
    id: "o9",
    texte: "Les vaccins rendent malade.",
    bonne: "opinion",
    pourquoi:
      "Une opinion qui se présente comme un savoir, et c'est le cas le plus dangereux. Elle s'appuie sur des coïncidences prises pour des causes.",
  },
  {
    id: "o10",
    texte: "L'eau est composée de deux atomes d'hydrogène et d'un atome d'oxygène.",
    bonne: "science",
    pourquoi: "Établie par expérimentation, et on sait la refaire.",
  },
  {
    id: "o11",
    texte: "Il est mal de torturer un innocent.",
    bonne: "valeur",
    pourquoi:
      "Attention : ce n'est ni une opinion ni une science. C'est un jugement de VALEUR, et aucune expérience ne pourra jamais l'établir ni le réfuter. Ce n'est pas une faiblesse de la science : les questions de valeur ne sont pas de son ordre.",
  },
  {
    id: "o12",
    texte: "La somme des angles d'un triangle vaut deux droits.",
    bonne: "science",
    pourquoi:
      "Science formelle : démontrée, non expérimentée. Sa vérité est une cohérence interne, et elle ne vaut d'ailleurs que dans l'espace euclidien.",
  },
  {
    id: "o13",
    texte: "La vie vaut d'être vécue.",
    bonne: "valeur",
    pourquoi:
      "Jugement de valeur, et sur le plus important. Aucune mesure ne le tranchera, et c'est pourquoi Camus en fait le seul problème philosophique vraiment sérieux.",
  },
  {
    id: "o14",
    texte: "Le mental des « primitifs » est prélogique.",
    bonne: "opinion",
    pourquoi:
      "Elle s'est présentée comme une science en 1910, et son propre auteur l'a retirée. Un énoncé scientifique n'est pas un énoncé vrai : c'est un énoncé qui s'expose au démenti — et celui-ci a été démenti.",
  },
  {
    id: "o15",
    texte: "Les faits sociaux doivent être traités « comme des choses ».",
    bonne: "science",
    pourquoi:
      "Une règle de méthode, celle de Durkheim. Elle est discutée — Weber lui oppose la compréhension du sens — et c'est la marque d'un énoncé scientifique.",
  },
];

const POPPER_TEST: ReadonlyArray<Question> = [
  {
    id: "pp1",
    enonce:
      "« Tous les corps tombent avec la même accélération dans le vide. » Qu'est-ce qui la rendrait fausse ?",
    options: [
      {
        texte: "Un corps qui, dans le vide, tomberait plus lentement qu'un autre.",
        bonne: true,
        retour:
          "Oui, et c'est précis. L'énoncé prend un risque : l'expérience peut le tuer, et c'est pour cela qu'il est scientifique.",
      },
      {
        texte: "Rien, elle est démontrée.",
        bonne: false,
        retour:
          "Aucune loi n'est définitivement démontrée, puisqu'elle porte sur des cas futurs : c'est le problème de l'induction, posé par Hume.",
      },
    ],
  },
  {
    id: "pp2",
    enonce:
      "« Tout événement de ta vie était inscrit dans ton destin. » Qu'est-ce qui la rendrait fausse ?",
    options: [
      {
        texte: "Rien. Si je réussis, c'était écrit ; si j'échoue, c'était écrit aussi.",
        bonne: true,
        retour:
          "Exactement, et tu viens d'appliquer le critère de Popper tout seul. Une théorie qui explique tout n'explique rien, parce qu'expliquer c'est exclure.",
      },
      {
        texte: "Un événement imprévu.",
        bonne: false,
        retour:
          "Le fataliste répondra qu'il était prévu par le destin, simplement pas par toi. L'énoncé se protège de tout démenti.",
      },
    ],
  },
  {
    id: "pp3",
    enonce: "Que faut-il en conclure sur la force d'une science ?",
    options: [
      {
        texte: "Elle se mesure à ce que la science INTERDIT d'observer.",
        bonne: true,
        retour:
          "Oui : plus une théorie exclut de cas possibles, plus elle dit quelque chose. Une théorie compatible avec tout ne dit rien.",
      },
      {
        texte: "Elle se mesure au nombre de faits qu'elle explique.",
        bonne: false,
        retour:
          "C'est le piège : les doctrines les plus faibles sont souvent celles qui expliquent le plus — précisément parce que rien ne peut les démentir.",
      },
    ],
  },
];

export function OpinionCroyanceScience() {
  return (
    <div className="space-y-4">
      <JeuTri
        consigne="Quinze énoncés. Classe-les — et fais attention : deux d'entre eux ne sont ni opinion, ni croyance, ni science."
        categories={[
          { value: "opinion", label: "Opinion", aide: "sans raisons, et qui se croit un savoir" },
          { value: "croyance", label: "Croyance", aide: "sans preuve, et qui l'assume" },
          { value: "science", label: "Science", aide: "rationnelle, méthodique, réfutable" },
          {
            value: "valeur",
            label: "Jugement de valeur",
            aide: "ni vrai ni faux au sens scientifique",
          },
        ]}
        items={ENONCES_SC}
        conclusion={
          <>
            Deux leçons. La première : l'<strong>opinion</strong> se croit un savoir, la{" "}
            <strong>croyance</strong> s'assume comme croyance — et c'est l'opinion, non la croyance,
            qui fait obstacle à la science. Bachelard : « l'opinion pense mal ; elle ne pense pas ».
            La seconde : les <strong>jugements de valeur</strong> ne sont pas des énoncés
            scientifiques manqués, ils sont d'un autre ordre, et aucune expérience ne les tranchera.
          </>
        }
      />
      <div className="border-t border-border pt-3">
        <p className="mb-2 text-xs font-semibold text-foreground">
          Second volet — qu'est-ce qui le rendrait faux ?
        </p>
        <Qcm
          consigne="Trois questions, et un critère que tu vas découvrir en l'appliquant avant qu'on te l'enseigne."
          questions={POPPER_TEST}
          conclusion={
            <>
              Ce critère a un nom : la <strong>falsifiabilité</strong>, et il est de{" "}
              <strong>Karl Popper</strong>. Est scientifique un énoncé dont on peut dire ce qui le
              rendrait faux. Puisque la vérification complète est impossible — il faudrait examiner
              tous les cas, y compris futurs — mais qu'une seule observation suffit à réfuter, la
              vérité scientifique est toujours <strong>provisoire</strong> : une conjecture qui a
              survécu aux tests jusqu'ici.
            </>
          }
        />
      </div>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* 2. Le laboratoire de Claude Bernard                                 */
/* ------------------------------------------------------------------ */

const ENQUETE: ReadonlyArray<Etape> = [
  {
    titre: "L'observation",
    question:
      "Fait observé : les lapins qui arrivent du marché ont une urine acide, comme les carnivores — alors qu'ils mangent de l'herbe. Que fais-tu de ce fait ?",
    options: [
      {
        texte:
          "Je le note comme surprenant : il contredit ce que je croyais savoir des herbivores.",
        bonne: true,
        retour:
          "Oui. À cette étape l'esprit est PASSIF : il constate, et il se laisse étonner. C'est l'étonnement qui lance la recherche, et c'est l'observation réelle de Claude Bernard.",
      },
      {
        texte: "Je conclus que les lapins sont en réalité carnivores.",
        bonne: false,
        retour:
          "Tu as sauté à la conclusion. Un fait ne conclut pas : il demande une hypothèse, puis une épreuve.",
      },
      {
        texte: "Je l'écarte : il doit y avoir une erreur de mesure.",
        bonne: false,
        retour:
          "C'est la tentation la plus commune, et Bernard la combat : écarter le fait qui dérange, c'est l'idée fixe en action.",
      },
    ],
  },
  {
    titre: "L'hypothèse",
    question: "Il faut maintenant une idée. Laquelle vaut la peine d'être essayée ?",
    options: [
      {
        texte:
          "Ces lapins n'ont pas mangé depuis leur transport : à jeun, ils vivent de leurs propres réserves, donc de chair — la leur.",
        bonne: true,
        retour:
          "Voilà une hypothèse : elle explique le fait, et surtout elle est TESTABLE. On peut imaginer l'expérience qui la démentirait.",
      },
      {
        texte: "L'urine des lapins est acide, parce que c'est dans leur nature.",
        bonne: false,
        retour:
          "Ce n'est pas une hypothèse, c'est le fait redit avec le mot « nature ». Rien n'est à tester, donc rien n'est expliqué.",
      },
      {
        texte: "Il doit y avoir une cause que nous ne connaîtrons jamais.",
        bonne: false,
        retour:
          "Une hypothèse qu'aucune expérience ne pourrait toucher ne sert à rien dans un laboratoire.",
      },
    ],
  },
  {
    titre: "L'expérience",
    question: "Comment éprouver l'hypothèse ?",
    options: [
      {
        texte:
          "Nourrir ces lapins d'herbe et mesurer à nouveau ; puis mettre à jeun des lapins bien nourris et mesurer encore.",
        bonne: true,
        retour:
          "Parfait : les deux sens de l'épreuve, et c'est ici que l'esprit devient ACTIF — il ne subit plus le réel, il l'interroge dans des conditions qu'il contrôle.",
      },
      {
        texte: "Observer encore d'autres lapins du marché, le plus grand nombre possible.",
        bonne: false,
        retour:
          "Tu accumules des observations sans jamais faire varier la condition suspectée. Mille lapins à jeun ne distingueront pas ton hypothèse d'une autre.",
      },
      {
        texte: "Demander à des éleveurs ce qu'ils en pensent.",
        bonne: false,
        retour:
          "Un appel à l'autorité. L'expérience de pensée des autres ne remplace pas l'expérience.",
      },
    ],
  },
  {
    titre: "Le résultat",
    question:
      "Résultat : nourris d'herbe, ils ont une urine alcaline ; mis à jeun, les lapins bien nourris ont une urine acide. Que conclus-tu ?",
    options: [
      {
        texte:
          "L'hypothèse est confirmée, et j'énonce une loi : un animal à jeun se nourrit de sa propre chair, donc son urine devient celle d'un carnivore.",
        bonne: true,
        retour:
          "Oui, et c'est la découverte réelle de Bernard. Remarque pourtant : « confirmée » ne veut pas dire « démontrée à jamais ». La loi reste une conjecture bien testée.",
      },
      {
        texte: "Je garde mon hypothèse de départ, qui était plus élégante.",
        bonne: false,
        retour:
          "C'est l'idée fixe, et Bernard l'a nommée pour la combattre : « l'expérimentateur doit douter, fuir les idées fixes ». C'est le résultat qui juge l'hypothèse, jamais l'hypothèse qui juge le résultat.",
      },
      {
        texte: "Les lapins sont décidément imprévisibles.",
        bonne: false,
        retour:
          "Tu renonces à l'explication juste au moment où elle arrivait. Le déterminisme est le principe de toute science : si les faits étaient imprévisibles, il n'y aurait rien à chercher.",
      },
    ],
  },
];

export function LaboratoireBernard() {
  return (
    <Parcours
      consigne="Une enquête réelle, celle de Claude Bernard sur l'urine des lapins. Mène-la en quatre étapes. La simulation refuse les raccourcis : si tu sautes l'hypothèse, elle te demande ce que tu cherches ; si tu interprètes l'expérience en faveur de ton idée, elle te renvoie à l'avertissement de Bernard."
      etapes={ENQUETE}
      fin={
        <>
          Les quatre étapes, et la posture de l'esprit à chacune : à l'
          <strong>observation</strong> il est passif, à l'<strong>hypothèse</strong> il invente, à
          l'<strong>expérimentation</strong> il est actif, et à la <strong>loi</strong> il reste
          prudent. Retiens la phrase qui vaut tout le reste : « l'expérimentateur doit douter, fuir
          les idées fixes ». Introduction à l'étude de la médecine expérimentale, 1865.
        </>
      }
    />
  );
}

/* ------------------------------------------------------------------ */
/* 3. Le comité d'éthique                                              */
/* ------------------------------------------------------------------ */

type Projet = {
  id: string;
  titre: string;
  detail: string;
  recommande: "oui" | "non" | "encadre";
  dixAns: string;
  refus: string;
};

const PROJETS: ReadonlyArray<Projet> = [
  {
    id: "pr1",
    titre: "Tester un vaccin prometteur sur une population non informée",
    detail:
      "Le vaccin pourrait sauver des milliers de vies. Informer les sujets ralentirait l'essai de deux ans.",
    recommande: "non",
    dixAns:
      "Autorisé, l'essai a sauvé des vies — et détruit la confiance : vingt ans plus tard, la population refuse toutes les campagnes de vaccination. Le gain immédiat a coûté plus qu'il n'a rapporté.",
    refus:
      "Refusé, l'essai a pris deux ans de plus et a été mené avec consentement. Le vaccin existe, et la confiance aussi.",
  },
  {
    id: "pr2",
    titre: "Cultiver des organes à partir de cellules du patient lui-même",
    detail: "Pour remplacer un rein défaillant, sans donneur ni rejet.",
    recommande: "oui",
    dixAns:
      "Autorisé : les listes d'attente ont fondu. Aucun tiers n'était lésé, et le consentement du patient suffisait.",
    refus:
      "Refusé : des patients sont morts en attendant un greffon. Un refus coûte aussi, et c'est le point le plus difficile de ce travail.",
  },
  {
    id: "pr3",
    titre: "Modifier un virus pour le rendre plus transmissible, afin d'anticiper sa mutation",
    detail:
      "L'objectif est défensif : préparer les vaccins avant que la nature ne produise la souche.",
    recommande: "non",
    dixAns:
      "Autorisé, le laboratoire a connu une fuite accidentelle. L'intention défensive n'a rien changé au virus : le savoir produit existe indépendamment des raisons qu'on avait de le produire.",
    refus:
      "Refusé : la souche n'a jamais existé. La préparation a été faite sur des modèles sans création de l'agent lui-même.",
  },
  {
    id: "pr4",
    titre: "Cloner un être humain",
    detail: "Pour un couple qui a perdu un enfant et souhaite le retrouver.",
    recommande: "non",
    dixAns:
      "Autorisé : l'enfant né a grandi comme le substitut d'un autre, chargé de ressembler à quelqu'un qu'il n'était pas. Il a été traité comme un moyen — exactement ce que Kant interdit.",
    refus:
      "Refusé. Le couple a reçu un accompagnement du deuil, et l'interdit protège un enfant qui n'avait pas de voix dans la décision.",
  },
  {
    id: "pr5",
    titre: "Une arme autonome qui choisit ses cibles sans décision humaine",
    detail: "Elle réduirait les pertes dans les rangs de celui qui l'emploie.",
    recommande: "non",
    dixAns:
      "Autorisé : la machine a tiré sur un convoi civil, et aucun responsable n'a pu être désigné. Sans décision humaine, il n'y a plus de responsabilité — or sans responsabilité, il n'y a plus de droit de la guerre.",
    refus: "Refusé. La décision de tuer reste imputable à quelqu'un, et peut donc être jugée.",
  },
  {
    id: "pr6",
    titre: "Séquencer le génome d'une population pour étudier une maladie héréditaire",
    detail: "Avec consentement, anonymisation, et destruction des données après l'étude.",
    recommande: "encadre",
    dixAns:
      "Autorisé sous conditions : la maladie est mieux comprise, et les garanties ont tenu. La question n'était pas s'il fallait chercher, mais à quelles conditions.",
    refus:
      "Refusé : l'étude n'a pas eu lieu, et la maladie continue. Un refus de principe là où un encadrement suffisait est un mauvais refus.",
  },
  {
    id: "pr7",
    titre: "Publier une méthode de synthèse d'un agent toxique, dans une revue scientifique",
    detail:
      "La publication est la règle de la science : un résultat non publié n'est pas vérifiable.",
    recommande: "non",
    dixAns:
      "Publié : la méthode a été reprise. La liberté de publier est une règle de la science, et la science n'est pas le seul lecteur.",
    refus:
      "Non publié intégralement : les résultats ont circulé entre laboratoires habilités. La vérifiabilité a été préservée sans diffusion générale.",
  },
  {
    id: "pr8",
    titre:
      "Une étude sur l'efficacité réelle d'une méthode d'enseignement, dans des classes volontaires",
    detail: "Avec groupe témoin, accord des parents et des enseignants.",
    recommande: "oui",
    dixAns:
      "Autorisé : on a découvert que deux méthodes très répandues ne valaient rien, et des millions d'élèves en ont bénéficié. Ne pas évaluer n'est pas neutre.",
    refus:
      "Refusé : les méthodes inefficaces sont restées en place faute d'avoir été mesurées. L'abstention protège parfois l'erreur.",
  },
];

const PROJET_VIDE: Projet = {
  id: "",
  titre: "—",
  detail: "—",
  recommande: "non",
  dixAns: "—",
  refus: "—",
};

export function ComiteEthique() {
  const [rang, setRang] = useState(0);
  const [decision, setDecision] = useState<"" | "oui" | "non">("");

  const p = PROJETS[rang] ?? PROJET_VIDE;
  const bonne =
    decision === ""
      ? null
      : p.recommande === "encadre"
        ? decision === "oui"
        : decision === p.recommande;

  return (
    <div className="space-y-3">
      <p className="text-sm text-muted-foreground">
        Huit projets de recherche arrivent sur ton bureau. Autorise ou refuse, en séparant à chaque
        fois ce qui relève du <strong>vrai</strong> — ce que la science peut établir — et ce qui
        relève du <strong>bien</strong> — ce que nous acceptons de faire. Attention : un refus coûte
        aussi.
      </p>

      <div className="rounded-lg border border-border bg-background p-3">
        <p className="text-sm font-medium leading-snug text-foreground">{p.titre}</p>
        <p className="mt-1 text-xs leading-snug text-muted-foreground">{p.detail}</p>

        <div className="mt-3 flex gap-1.5">
          {[
            { v: "oui" as const, l: "Autoriser" },
            { v: "non" as const, l: "Refuser" },
          ].map((o) => {
            const actif = decision === o.v;
            const cls = !actif
              ? "border-border bg-background text-muted-foreground hover:bg-secondary/60"
              : bonne
                ? "border-emerald-500/40 bg-emerald-500/15 text-emerald-700"
                : "border-rose-500/40 bg-rose-500/15 text-rose-700";
            return (
              <button
                key={o.v}
                type="button"
                onClick={() => setDecision(o.v)}
                className={`rounded-lg border px-3 py-1.5 text-xs font-medium ${cls}`}
              >
                {o.l}
              </button>
            );
          })}
        </div>

        {decision !== "" ? (
          <div className="mt-3 space-y-2">
            <div className="rounded-lg bg-secondary/40 px-2.5 py-2">
              <p className="text-[11px] font-semibold uppercase tracking-wide text-muted-foreground">
                Dix ans plus tard
              </p>
              <p className="mt-1 text-xs leading-relaxed text-foreground">
                {decision === "oui" ? p.dixAns : p.refus}
              </p>
            </div>
            <Verdict tone={bonne ? "ok" : "warn"}>
              {p.recommande === "encadre"
                ? "Cas à encadrer plutôt qu'à interdire : la question n'était pas s'il fallait chercher, mais à quelles conditions."
                : p.recommande === "oui"
                  ? "Le comité recommande l'autorisation : aucun tiers n'est lésé, et le refus a un coût réel."
                  : "Le comité recommande le refus : le savoir produit existerait indépendamment des bonnes raisons qu'on avait de le produire."}
            </Verdict>
            <button
              type="button"
              onClick={() => {
                setRang((r) => (r + 1) % PROJETS.length);
                setDecision("");
              }}
              className="rounded-lg bg-primary px-3 py-1.5 text-xs font-semibold text-primary-foreground"
            >
              Projet suivant ({rang + 1} / {PROJETS.length})
            </button>
          </div>
        ) : null}
      </div>

      <Citation auteur="Rabelais">Science sans conscience n'est que ruine de l'âme.</Citation>
      <p className="text-[11px] leading-snug text-muted-foreground">
        Ce que ces huit dossiers enseignent : la <strong>neutralité</strong> de la science vaut pour
        les <em>énoncés</em> et non pour les <em>pratiques</em>. Une équation n'est pas morale ; un
        protocole d'expérience sur des êtres humains l'est entièrement. Et un comité d'éthique ne
        juge pas du vrai, dont il est incompétent : il juge de ce que nous acceptons de faire.
      </p>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* 4. Essence ou existence d'abord ?                                   */
/* ------------------------------------------------------------------ */

const ETRES: ReadonlyArray<ItemTri> = [
  {
    id: "x1",
    texte: "Un couteau",
    bonne: "essence",
    pourquoi:
      "L'idée du couteau — ce qu'il doit faire — existe avant le couteau. C'est le modèle de l'artisan, et il vaut pour tout objet fabriqué.",
  },
  {
    id: "x2",
    texte: "Une table",
    bonne: "essence",
    pourquoi: "Même modèle : on sait à quoi elle servira avant de la construire.",
  },
  {
    id: "x3",
    texte: "Un pont",
    bonne: "essence",
    pourquoi: "Les plans précèdent l'ouvrage, et le définissent entièrement.",
  },
  {
    id: "x4",
    texte: "Un personnage de roman",
    bonne: "essence",
    pourquoi:
      "Cas intéressant : son essence est fixée par l'auteur, et il ne peut rien y changer. C'est pourquoi un personnage n'existe pas au sens où un homme existe.",
  },
  {
    id: "x5",
    texte: "Une pierre",
    bonne: "ni",
    pourquoi:
      "Attention : la pierre n'est pas fabriquée, donc nulle idée ne l'a précédée ; et elle ne se fait pas elle-même. Elle EST, tout entière et close, sans rapport à son propre être. Pour la philosophie contemporaine, elle n'existe pas : elle est.",
  },
  {
    id: "x6",
    texte: "Un chien",
    bonne: "ni",
    pourquoi:
      "Discutable, et c'est son intérêt. Il n'est pas fabriqué, mais il ne se choisit pas non plus : il réalise une nature. Sartre réserve l'existence à l'homme, et on peut lui objecter ce cas.",
  },
  {
    id: "x7",
    texte: "Un nouveau-né",
    bonne: "existence",
    pourquoi:
      "Il est là avant d'être quoi que ce soit. Aucune définition ne lui dit qui être : « l'homme surgit d'abord dans le monde, et se définit après ».",
  },
  {
    id: "x8",
    texte: "Un vieillard au terme de sa vie",
    bonne: "existence",
    pourquoi:
      "Son essence est maintenant presque entière — mais elle est le RÉSULTAT de ses actes, non leur point de départ. C'est exactement la thèse de Sartre : l'homme n'est rien d'autre que la somme de ce qu'il a fait.",
  },
  {
    id: "x9",
    texte: "Un élève à qui l'on répète qu'il est « nul en mathématiques »",
    bonne: "existence",
    pourquoi:
      "Le cas le plus utile. On lui assigne une essence qu'il n'a pas, et elle finira par le définir s'il y consent. Sartre appelle ce consentement la mauvaise foi.",
  },
  {
    id: "x10",
    texte: "Un homme qui dit : « je suis colérique, je n'y peux rien »",
    bonne: "existence",
    pourquoi:
      "Il se traite lui-même comme un couteau — une chose dont la fonction est fixée d'avance. Mauvaise foi : invoquer son caractère pour se justifier, c'est se faire passer pour une chose.",
  },
];

export function EssenceExistence() {
  const [sartre, setSartre] = useState(false);
  return (
    <div className="space-y-3">
      <JeuTri
        consigne="Dix objets et dix êtres. Pour chacun, dis si son essence précède son existence, l'inverse, ou si aucune des deux formules ne convient."
        categories={[
          { value: "essence", label: "L'essence d'abord", aide: "l'idée précède la chose" },
          { value: "existence", label: "L'existence d'abord", aide: "il se fait ce qu'il est" },
          { value: "ni", label: "Ni l'un ni l'autre", aide: "il EST, simplement" },
        ]}
        items={ETRES}
        conclusion={
          <>
            Tu viens de vérifier le <strong>modèle de l'artisan</strong> : pour tout objet fabriqué,
            l'idée vient avant la chose. Et tu as vu le troisième cas, que l'on oublie : la pierre
            n'a pas d'essence préalable et ne se fait pas non plus — elle est, sans rapport à son
            propre être. <em>Ex-sistere</em> signifie se tenir hors de soi : les choses sont,
            l'homme existe.
          </>
        }
      />
      <button
        type="button"
        onClick={() => setSartre((s) => !s)}
        className="rounded-lg bg-primary px-3 py-1.5 text-xs font-semibold text-primary-foreground"
      >
        {sartre ? "Masquer la question de Sartre" : "La question de Sartre"}
      </button>
      {sartre ? (
        <div className="space-y-2">
          <div className="rounded-lg border border-primary/40 bg-primary/5 p-3 text-xs leading-relaxed">
            <p className="font-semibold text-foreground">
              Qui a pensé l'idée de l'homme avant l'homme ?
            </p>
            <p className="mt-1 text-muted-foreground">
              Le modèle de l'artisan suppose un artisan. Appliqué à l'homme, il suppose donc un
              concepteur — Dieu, la nature, l'ordre du monde — qui aurait fixé d'avance ce qu'un
              homme doit être.
            </p>
            <p className="mt-2 text-muted-foreground">
              Sartre refuse cet artisan, et la conséquence tombe aussitôt :{" "}
              <strong>« il n'y a pas de nature humaine »</strong>. L'homme n'est rien d'autre que ce
              qu'il se fait, la somme de ses actes, et rien de plus.
            </p>
            <p className="mt-2 text-muted-foreground">
              D'où la liberté — aucune définition ne me précède — et l'angoisse qui va avec : je
              n'ai aucune excuse, puisque je n'ai aucune nature à invoquer.
            </p>
          </div>
          <Verdict tone="warn">
            La limite, pour l'antithèse : cette liberté est la même pour tous, alors que les
            conditions réelles ne le sont pas. Celui qui n'a jamais été à l'école et celui qui a
            fait des études ont la même liberté formelle et pas la même gamme de choix.{" "}
            <strong>Marx</strong> et <strong>Durkheim</strong> objecteraient que les conditions
            sociales ne sont pas une simple situation à interpréter : elles façonnent l'interprète.
          </Verdict>
        </div>
      ) : null}
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* 5. Cinq philosophes au chevet                                       */
/* ------------------------------------------------------------------ */

type ReponseSage = { sage: string; texte: string };

type QuestionMort = {
  id: string;
  question: string;
  attendu: string;
  reponses: ReadonlyArray<ReponseSage>;
};

const SAGES = ["Épicure", "Platon", "Spinoza", "Heidegger", "Traditions africaines"] as const;

const QUESTIONS_MORT: ReadonlyArray<QuestionMort> = [
  {
    id: "m1",
    question: "« Faut-il que j'aie peur ? »",
    attendu: "Épicure",
    reponses: [
      {
        sage: "Épicure",
        texte:
          "Non, et pour une raison serrée : tout bien et tout mal résident dans la sensation ; la mort est privation de toute sensation ; donc elle n'est ni un bien ni un mal. Elle n'est rien pour toi. Et nous ne nous rencontrerons jamais : quand elle est là, tu n'es plus ; quand tu es, elle n'est pas.",
      },
      {
        sage: "Platon",
        texte:
          "Non, car elle délivre l'âme du corps. Toute ma vie de philosophe a été un exercice de ce détachement : je n'ai pas à craindre ce que je préparais.",
      },
      {
        sage: "Spinoza",
        texte:
          "Ne te pose pas la question. La crainte est une tristesse, et la tristesse diminue ta puissance d'agir : craindre la mort, c'est mourir un peu d'avance.",
      },
      {
        sage: "Heidegger",
        texte:
          "Ni peur ni oubli : il s'agit d'assumer. La peur a un objet dans le monde ; ta mort n'en est pas un, elle est ta possibilité la plus propre.",
      },
      {
        sage: "Traditions africaines",
        texte:
          "Tu ne vas pas vers le néant mais vers les ancêtres. On ne craint pas un passage : on s'y prépare, et la communauté s'y prépare avec toi.",
      },
    ],
  },
  {
    id: "m2",
    question: "« Dois-je y penser, ou l'oublier ? »",
    attendu: "Spinoza",
    reponses: [
      {
        sage: "Spinoza",
        texte:
          "L'homme libre ne pense pas à la mort, et sa sagesse est une méditation non de la mort, mais de la vie. Éthique, livre IV.",
      },
      {
        sage: "Platon",
        texte:
          "Il faut y penser constamment : philosopher, c'est s'exercer à mourir, et Montaigne me suivra sur ce point.",
      },
      {
        sage: "Heidegger",
        texte:
          "Il faut y penser comme à TA mort, non comme au fait qu'« on meurt ». Ce « on » anonyme est une fuite : il transforme ta mort en un fait général qui ne concerne personne.",
      },
      {
        sage: "Épicure",
        texte:
          "Autant y penser une fois, bien, pour en être délivré ensuite. Mon argument une fois compris, la question est close.",
      },
      {
        sage: "Traditions africaines",
        texte:
          "On n'y pense pas seul : on l'honore en commun, par les rites et la mémoire des ancêtres.",
      },
    ],
  },
  {
    id: "m3",
    question: "« Que restera-t-il de moi ? »",
    attendu: "Traditions africaines",
    reponses: [
      {
        sage: "Traditions africaines",
        texte:
          "Tu rejoindras la communauté des ancêtres et tu continueras d'y agir : on te consultera, on t'honorera. « Ceux qui sont morts ne sont jamais partis », écrit Birago Diop. La communauté comprend les morts, les vivants, et ceux qui ne sont pas encore nés.",
      },
      {
        sage: "Épicure",
        texte: "Rien, et cela ne doit pas t'inquiéter : il n'y aura personne pour en souffrir.",
      },
      {
        sage: "Platon",
        texte: "Ton âme, délivrée du corps, et c'est le meilleur de toi.",
      },
      {
        sage: "Heidegger",
        texte:
          "La question du reste est encore une fuite : ce qui compte n'est pas ce qui subsistera, c'est ce que tu fais du temps qui te reste.",
      },
      {
        sage: "Spinoza",
        texte: "Ce que tu as compris, car comprendre augmente la part d'éternel en toi.",
      },
    ],
  },
  {
    id: "m4",
    question: "« Ma vie a-t-elle encore un sens, maintenant que je sais qu'elle finit ? »",
    attendu: "Heidegger",
    reponses: [
      {
        sage: "Heidegger",
        texte:
          "C'est maintenant seulement qu'elle en a un. Tant que tu te croyais un temps illimité, rien n'était urgent et rien n'importait vraiment. L'être-pour-la-mort est ce qui rend ton temps précieux : il te ramène à ce qui compte réellement pour toi, et sépare l'essentiel de l'accessoire.",
      },
      {
        sage: "Épicure",
        texte:
          "Elle a le sens qu'elle avait hier : la fin n'y change rien, puisqu'elle ne sera rien pour toi.",
      },
      {
        sage: "Platon",
        texte: "Son sens était de préparer ce passage : il s'accomplit.",
      },
      {
        sage: "Spinoza",
        texte:
          "Reporte ton attention sur ce qui augmente ta joie : c'est là que le sens se trouve, et non dans la limite.",
      },
      {
        sage: "Traditions africaines",
        texte:
          "Ton sens ne s'arrête pas à ton corps : tu continues dans la lignée, et ce que tu as transmis vit.",
      },
    ],
  },
  {
    id: "m5",
    question: "« J'ai peur qu'on m'oublie, et peur de ne plus voir les miens. »",
    attendu: "Traditions africaines",
    reponses: [
      {
        sage: "Traditions africaines",
        texte:
          "C'est précisément la crainte à laquelle les rites répondent : on ne t'oubliera pas, parce que t'honorer fait partie de la vie de ceux qui restent. Sankara le dit en termes laïques : on peut tuer un révolutionnaire, on ne tue pas des idées.",
      },
      {
        sage: "Épicure",
        texte:
          "Tu ne seras plus là pour souffrir de cet oubli — et je reconnais que mon argument répond mal à cette crainte, parce qu'il raisonne sur un individu séparé.",
      },
      {
        sage: "Heidegger",
        texte:
          "Personne ne peut mourir à ta place, et c'est ce que cette crainte redoute vraiment : ta mort est la seule chose absolument tienne.",
      },
      {
        sage: "Spinoza",
        texte: "Laisse cette tristesse, elle ne t'aide pas.",
      },
      {
        sage: "Platon",
        texte: "Tu les retrouveras, si l'âme est immortelle.",
      },
    ],
  },
  {
    id: "m6",
    question: "« Craindre la mort me rend-il plus libre ou moins libre ? »",
    attendu: "Platon",
    reponses: [
      {
        sage: "Platon",
        texte:
          "Celui qui s'est exercé à mourir ne craint plus rien, et devient inattaquable. Montaigne le dira mieux que moi : « qui a appris à mourir, il a désappris à servir ». C'est pourquoi les tyrans redoutent les hommes qui ne craignent pas de mourir.",
      },
      {
        sage: "Spinoza",
        texte:
          "Moins libre : la crainte est une passion triste, et toute passion triste diminue ta puissance. Voilà pourquoi je dis exactement le contraire de Montaigne.",
      },
      {
        sage: "Épicure",
        texte: "Ni l'un ni l'autre : la crainte est sans objet, donc il n'y a rien à en tirer.",
      },
      {
        sage: "Heidegger",
        texte:
          "Ce n'est pas la crainte qui libère, c'est l'assomption : elle t'arrache au « on » et te rend ton existence.",
      },
      {
        sage: "Traditions africaines",
        texte: "La liberté vient de n'être pas seul devant elle.",
      },
    ],
  },
];

const QM_VIDE: QuestionMort = { id: "", question: "—", attendu: "Épicure", reponses: [] };

export function CinqAttitudesMort() {
  const [rang, setRang] = useState(0);
  const [sage, setSage] = useState<string>("");
  const [choc, setChoc] = useState<"" | "montaigne" | "epicure">("");

  const q = QUESTIONS_MORT[rang] ?? QM_VIDE;
  const rep = q.reponses.find((r) => r.sage === sage) ?? null;

  return (
    <div className="space-y-3">
      <p className="text-sm text-muted-foreground">
        Un homme apprend qu'il va mourir et pose ses questions. Choisis qui répond : chacun répond
        selon sa thèse, dans ses propres termes. Essaie plusieurs sages sur la même question — c'est
        là que le chapitre devient clair.
      </p>

      <div className="rounded-lg border border-border bg-background p-3">
        <p className="text-sm font-medium italic leading-snug text-foreground">{q.question}</p>

        <div className="mt-2 flex flex-wrap gap-1.5">
          {SAGES.map((s) => (
            <button
              key={s}
              type="button"
              onClick={() => setSage(s)}
              className={
                sage === s
                  ? "rounded-lg bg-primary px-2.5 py-1 text-[11px] font-semibold text-primary-foreground"
                  : "rounded-lg border border-border px-2.5 py-1 text-[11px] text-muted-foreground hover:bg-secondary/60"
              }
            >
              {s}
            </button>
          ))}
        </div>

        {rep ? (
          <div className="mt-2 space-y-2">
            <div className="rounded-lg bg-secondary/40 px-2.5 py-2">
              <p className="text-[11px] font-semibold uppercase tracking-wide text-muted-foreground">
                {rep.sage} répond
              </p>
              <p className="mt-1 text-xs leading-relaxed text-foreground">{rep.texte}</p>
            </div>
            {sage === q.attendu ? (
              <Verdict tone="ok">
                C'est la réponse la plus propre à cette question : les autres l'abordent de biais,
                celle-ci la traite de front.
              </Verdict>
            ) : (
              <p className="text-[11px] italic text-muted-foreground">
                Réponse valable, mais ce n'est pas celui que cette question vise le plus
                directement. Essaie {q.attendu}.
              </p>
            )}
            <button
              type="button"
              onClick={() => {
                setRang((r) => (r + 1) % QUESTIONS_MORT.length);
                setSage("");
              }}
              className="rounded-lg bg-primary px-3 py-1.5 text-xs font-semibold text-primary-foreground"
            >
              Question suivante ({rang + 1} / {QUESTIONS_MORT.length})
            </button>
          </div>
        ) : null}
      </div>

      <div className="space-y-2 border-t border-border pt-3">
        <p className="text-xs font-semibold text-foreground">
          Les deux endroits où les réponses s'affrontent de front
        </p>
        <div className="flex flex-wrap gap-1.5">
          <button
            type="button"
            onClick={() => setChoc((c) => (c === "montaigne" ? "" : "montaigne"))}
            className={
              choc === "montaigne"
                ? "rounded-lg bg-primary px-2.5 py-1 text-[11px] font-semibold text-primary-foreground"
                : "rounded-lg border border-border px-2.5 py-1 text-[11px] text-muted-foreground hover:bg-secondary/60"
            }
          >
            Montaigne contre Spinoza
          </button>
          <button
            type="button"
            onClick={() => setChoc((c) => (c === "epicure" ? "" : "epicure"))}
            className={
              choc === "epicure"
                ? "rounded-lg bg-primary px-2.5 py-1 text-[11px] font-semibold text-primary-foreground"
                : "rounded-lg border border-border px-2.5 py-1 text-[11px] text-muted-foreground hover:bg-secondary/60"
            }
          >
            Épicure contre Heidegger
          </button>
        </div>

        {choc === "montaigne" ? (
          <div className="space-y-2">
            <Citation auteur="Montaigne, Essais">
              Philosopher, c'est apprendre à mourir. Qui a appris à mourir, il a désappris à servir.
            </Citation>
            <Citation auteur="Spinoza, Éthique IV">
              L'homme libre ne pense pas à la mort, et sa sagesse est une méditation non de la mort,
              mais de la vie.
            </Citation>
            <Verdict tone="warn">
              Opposition frontale, et excellent matériau d'antithèse : les deux cherchent la{" "}
              <strong>liberté</strong>, par des chemins exactement contraires. Montaigne dit : pense
              à la mort, tu seras libre. Spinoza : n'y pense pas, tu seras libre.
            </Verdict>
          </div>
        ) : null}

        {choc === "epicure" ? (
          <div className="space-y-2">
            <div className="rounded-lg border border-border bg-secondary/20 p-2.5 text-xs leading-relaxed">
              <p>
                <span className="font-semibold">Épicure</span> traite la mort comme un{" "}
                <strong>événement</strong> futur. Dès lors il est facile de montrer qu'il ne me
                concerne pas encore et ne me concernera jamais.
              </p>
              <p className="mt-1.5">
                <span className="font-semibold">Heidegger</span> répond que la mort n'est pas un
                événement à venir mais une <strong>structure présente</strong> de mon existence : je
                suis, dès maintenant, un être qui peut mourir, et c'est cette possibilité qui donne
                à mon temps sa limite, donc son prix.
              </p>
            </div>
            <Verdict tone="warn">
              Épicure a donc raison sur la mort comme <strong>fait</strong> et manque la mort comme{" "}
              <strong>sens</strong>. En écartant la crainte, il écarte aussi ce que la mort révèle :
              que mon temps est compté. C'est l'objection la plus profonde du chapitre, et elle vaut
              des points.
            </Verdict>
          </div>
        ) : null}
      </div>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* 6. Une vie sans fin                                                 */
/* ------------------------------------------------------------------ */

type Tache = { id: string; texte: string };

const TACHES_VIE: ReadonlyArray<Tache> = [
  { id: "v1", texte: "Apprendre le piano" },
  { id: "v2", texte: "Réconcilier deux amis qui ne se parlent plus" },
  { id: "v3", texte: "Écrire le livre que je porte depuis des années" },
  { id: "v4", texte: "Dire à quelqu'un que je l'aime" },
  { id: "v5", texte: "Aller voir ma grand-mère au village" },
  { id: "v6", texte: "Demander pardon" },
];

export function VieSansFin() {
  const [immortel, setImmortel] = useState(true);
  const [faites, setFaites] = useState<Record<string, boolean>>({});
  const [reports, setReports] = useState(0);
  const [restant, setRestant] = useState(6);

  const nbFaites = TACHES_VIE.filter((t) => faites[t.id]).length;
  const fini = nbFaites === TACHES_VIE.length;
  const epuise = !immortel && restant <= 0;

  function reinitialiser(mode: boolean) {
    setImmortel(mode);
    setFaites({});
    setReports(0);
    setRestant(6);
  }

  return (
    <div className="space-y-3">
      <p className="text-sm text-muted-foreground">
        Une liste de choses à faire, et deux conditions : le temps infini, ou le temps compté.
        Commence par l'immortalité, et reporte autant que tu veux.
      </p>

      <div className="flex flex-wrap gap-1.5">
        <button
          type="button"
          onClick={() => reinitialiser(true)}
          className={
            immortel
              ? "rounded-lg bg-primary px-3 py-1.5 text-xs font-semibold text-primary-foreground"
              : "rounded-lg border border-border px-3 py-1.5 text-xs text-muted-foreground hover:bg-secondary/60"
          }
        >
          Temps infini
        </button>
        <button
          type="button"
          onClick={() => reinitialiser(false)}
          className={
            !immortel
              ? "rounded-lg bg-primary px-3 py-1.5 text-xs font-semibold text-primary-foreground"
              : "rounded-lg border border-border px-3 py-1.5 text-xs text-muted-foreground hover:bg-secondary/60"
          }
        >
          Six occasions, et c'est tout
        </button>
      </div>

      <div className="grid grid-cols-2 gap-2">
        <Stat
          label="Temps restant"
          value={immortel ? "illimité" : `${Math.max(0, restant)} occasion(s)`}
          color={immortel ? PALETTE.slate : restant <= 2 ? PALETTE.red : PALETTE.orange}
        />
        <Stat label="Reports" value={`${reports}`} color={PALETTE.purple} />
      </div>

      <ul className="space-y-1.5">
        {TACHES_VIE.map((t) => {
          const faite = Boolean(faites[t.id]);
          return (
            <li
              key={t.id}
              className={
                faite
                  ? "rounded-lg border border-emerald-500/40 bg-emerald-500/10 p-2.5"
                  : "rounded-lg border border-border bg-background p-2.5"
              }
            >
              <p className="text-xs text-foreground">
                {faite ? "✓ " : ""}
                {t.texte}
              </p>
              {!faite && !epuise ? (
                <div className="mt-1.5 flex gap-1.5">
                  <button
                    type="button"
                    onClick={() => {
                      setFaites((f) => ({ ...f, [t.id]: true }));
                      if (!immortel) setRestant((r) => r - 1);
                    }}
                    className="rounded-lg bg-primary px-2.5 py-1 text-[11px] font-semibold text-primary-foreground"
                  >
                    Le faire maintenant
                  </button>
                  <button
                    type="button"
                    onClick={() => {
                      setReports((r) => r + 1);
                      if (!immortel) setRestant((r) => r - 1);
                    }}
                    className="rounded-lg border border-border px-2.5 py-1 text-[11px] text-muted-foreground hover:bg-secondary/60"
                  >
                    Plus tard
                  </button>
                </div>
              ) : null}
            </li>
          );
        })}
      </ul>

      {immortel && reports >= 5 ? (
        <Verdict tone="bad">
          Cinq reports, et rien ne s'est fait. Pourquoi le ferais-tu aujourd'hui ? Tu as tout le
          temps. Avec un temps infini, <strong>rien n'est jamais urgent</strong> — et rien n'est
          jamais urgent signifie que rien ne compte plus qu'autre chose.
        </Verdict>
      ) : null}

      {immortel && fini ? (
        <Verdict tone="warn">
          Tu as tout fait, et tu aurais pu ne rien faire sans conséquence. C'est le point : dans une
          vie sans fin, tes choix ne te coûtent rien, donc ils ne te définissent pas.
        </Verdict>
      ) : null}

      {!immortel && epuise ? (
        <Verdict tone={nbFaites >= 4 ? "ok" : "bad"}>
          Les occasions sont épuisées. Tu as fait {nbFaites} chose(s) sur six, et reporté {reports}{" "}
          fois. Chaque report t'a coûté une occasion — c'est cela, un temps compté : il oblige à{" "}
          <strong>choisir</strong>, et choisir, c'est donner un sens.
        </Verdict>
      ) : null}

      {!immortel && fini ? (
        <Verdict tone="ok">
          Tout fait, et sans un report. Remarque ce qui t'a conduit : le compteur. Ce n'est pas la
          mort qui a donné un sens à ces six actes, c'est elle qui a rendu la question du sens{" "}
          <strong>inévitable</strong>.
        </Verdict>
      ) : null}

      <Citation auteur="pour la synthèse">
        La mort ne <em>donne</em> pas un sens — il serait étrange qu'un néant produise du sens — et
        elle ne l'<em>ôte</em> pas non plus. Elle rend la question du sens inévitable. Un être
        immortel n'aurait jamais à se demander ce qu'il fait de son temps, puisqu'il en aurait
        toujours.
      </Citation>
      <p className="text-[11px] leading-snug text-muted-foreground">
        C'est l'argument de <strong>Heidegger</strong> en acte : l'être-pour-la-mort ne supprime pas
        l'existence, il la tend. Et <strong>Camus</strong> en tire le refus du suicide : constater
        l'absurde n'oblige pas à abdiquer, il faut imaginer Sisyphe heureux, parce qu'il a fait de
        son rocher son affaire.
      </p>
    </div>
  );
}
