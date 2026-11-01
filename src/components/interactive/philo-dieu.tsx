import { useMemo, useState } from "react";
import { PALETTE, Stat, Verdict } from "./controls";
import { Citation, JeuTri, Qcm, type ItemTri, type Question } from "./philo-noyau";

/** Philosophie Terminale C et D — chapitres 12 et 13 :
 *  Dieu et la religion, la logique. */

/* ------------------------------------------------------------------ */
/* 1. Théisme, déisme, athéisme, agnosticisme                          */
/* ------------------------------------------------------------------ */

const POSITIONS: ReadonlyArray<ItemTri> = [
  {
    id: "q1",
    texte: "« Dieu a créé le monde, puis l'a laissé tourner selon ses lois. »",
    bonne: "deisme",
    pourquoi:
      "Un Dieu créateur qui n'intervient pas et n'exige pas de culte particulier. Voltaire est déiste, et non chrétien.",
  },
  {
    id: "q2",
    texte: "« Dieu entend mes prières et peut y répondre. »",
    bonne: "theisme",
    pourquoi: "Un Dieu personnel, qui intervient dans le monde : c'est la définition du théisme.",
  },
  {
    id: "q3",
    texte: "« Je ne peux pas savoir, et personne ne le peut. »",
    bonne: "agnosticisme",
    pourquoi:
      "Ce n'est pas un athéisme timide : c'est une thèse sur les LIMITES de la connaissance. Kant en est très proche : Dieu n'est pas un objet d'expérience possible.",
  },
  {
    id: "q4",
    texte: "« Dieu n'existe pas : l'homme l'a créé à son image. »",
    bonne: "atheisme",
    pourquoi:
      "Feuerbach, dans L'essence du christianisme. L'athéisme est une position, qui a donc à se justifier comme toute autre.",
  },
  {
    id: "q5",
    texte: "« La religion est utile à la société, même si aucun dieu n'existe. »",
    bonne: "fonction",
    pourquoi:
      "Attention : ce n'est pas une position sur l'existence de Dieu. C'est une thèse sur la FONCTION de la religion, et c'est celle de Durkheim. Les deux questions sont indépendantes.",
  },
  {
    id: "q6",
    texte:
      "« Les preuves de l'existence de Dieu échouent toutes, mais la morale nous oblige à le postuler. »",
    bonne: "agnosticisme",
    pourquoi:
      "Kant exactement : il détruit les preuves théoriques et sauve la foi comme postulat de la raison pratique. « J'ai dû supprimer le savoir pour faire place à la foi. »",
  },
  {
    id: "q7",
    texte:
      "« La religion est l'opium du peuple : elle soulage la misère au lieu de la supprimer. »",
    bonne: "fonction",
    pourquoi:
      "Marx. Il décrit un EFFET social, et son athéisme est une autre thèse. Montrer qu'une croyance console ne montre pas qu'elle est fausse.",
  },
  {
    id: "q8",
    texte: "« Un ordre aussi réglé que celui du monde suppose un ordonnateur. »",
    bonne: "theisme",
    pourquoi:
      "La preuve par le dessein, résumée par Voltaire : « je ne puis songer que cette horloge existe et n'ait point d'horloger ». Voltaire s'en sert pour un Dieu déiste, mais l'argument est le socle du théisme.",
  },
  {
    id: "q9",
    texte:
      "« La religion est la survivance de la détresse infantile : un père protecteur projeté. »",
    bonne: "fonction",
    pourquoi:
      "Freud, L'avenir d'une illusion. Encore une explication de l'origine de la croyance, non une preuve de sa fausseté.",
  },
  {
    id: "q10",
    texte:
      "« Il faut se soumettre aux autorités, car il n'y a point d'autorité qui ne vienne de Dieu. »",
    bonne: "theisme",
    pourquoi:
      "Saint Paul, et Bossuet en tirera la théorie du droit divin. Un Dieu qui institue et qui commande : théisme.",
  },
  {
    id: "q11",
    texte: "« La question n'a pas de réponse accessible, donc je m'abstiens de trancher. »",
    bonne: "agnosticisme",
    pourquoi:
      "L'abstention est ici raisonnée, non paresseuse : elle s'appuie sur une thèse sur ce qu'on peut connaître.",
  },
  {
    id: "q12",
    texte: "« Sans la justice, qu'est-ce qu'un État sinon une troupe de brigands ? »",
    bonne: "fonction",
    pourquoi:
      "Saint Augustin, et il est croyant : le piège est de classer un auteur d'après sa foi plutôt que d'après ce que l'énoncé affirme. Celui-ci porte sur l'État, pas sur Dieu.",
  },
];

export function PositionsReligieuses() {
  const [axes, setAxes] = useState(false);
  return (
    <div className="space-y-3">
      <JeuTri
        consigne="Douze affirmations. Identifie la position de celui qui parle. Attention : quatre d'entre elles ne portent pas du tout sur l'existence de Dieu."
        categories={[
          { value: "theisme", label: "Théisme", aide: "un Dieu personnel, qui intervient" },
          { value: "deisme", label: "Déisme", aide: "un Dieu créateur, qui n'intervient pas" },
          { value: "atheisme", label: "Athéisme", aide: "Dieu n'existe pas" },
          { value: "agnosticisme", label: "Agnosticisme", aide: "on ne peut pas savoir" },
          { value: "fonction", label: "Autre question", aide: "sur la fonction de la religion" },
        ]}
        items={POSITIONS}
        conclusion={
          <>
            La leçon de méthode la plus rentable du chapitre : « <strong>Dieu existe-t-il ?</strong>{" "}
            » et « <strong>la religion est-elle utile ?</strong> » sont deux questions distinctes,
            l'une métaphysique et l'autre sociologique. On peut répondre non à la première et oui à
            la seconde, comme Durkheim, ou l'inverse. Les confondre est l'erreur la plus fréquente
            en copie, et elle produit des hors-sujets entiers.
          </>
        }
      />
      <button
        type="button"
        onClick={() => setAxes((a) => !a)}
        className="rounded-lg border border-border px-3 py-1.5 text-xs font-medium text-muted-foreground hover:bg-secondary/60"
      >
        {axes ? "Masquer les deux axes" : "Placer les positions sur deux axes"}
      </button>
      {axes ? (
        <div className="space-y-2">
          <div className="overflow-x-auto">
            <table className="w-full min-w-[420px] border-collapse text-xs">
              <thead>
                <tr>
                  <th className="border border-border bg-secondary/30 px-2 py-1.5 text-left font-semibold">
                    &nbsp;
                  </th>
                  <th className="border border-border bg-secondary/30 px-2 py-1.5 font-semibold">
                    Dieu existe
                  </th>
                  <th className="border border-border bg-secondary/30 px-2 py-1.5 font-semibold">
                    Dieu n&apos;existe pas
                  </th>
                  <th className="border border-border bg-secondary/30 px-2 py-1.5 font-semibold">
                    sans réponse
                  </th>
                </tr>
              </thead>
              <tbody>
                <tr>
                  <td className="border border-border bg-secondary/30 px-2 py-1.5 font-semibold">
                    On peut le savoir
                  </td>
                  <td className="border border-border px-2 py-1.5 text-center">théisme, déisme</td>
                  <td className="border border-border px-2 py-1.5 text-center">athéisme</td>
                  <td className="border border-border px-2 py-1.5 text-center text-muted-foreground">
                    —
                  </td>
                </tr>
                <tr>
                  <td className="border border-border bg-secondary/30 px-2 py-1.5 font-semibold">
                    On ne peut pas le savoir
                  </td>
                  <td className="border border-border px-2 py-1.5 text-center">
                    fidéisme, et Kant par la raison pratique
                  </td>
                  <td className="border border-border px-2 py-1.5 text-center text-muted-foreground">
                    position rare
                  </td>
                  <td className="border border-border px-2 py-1.5 text-center">agnosticisme</td>
                </tr>
              </tbody>
            </table>
          </div>
          <Verdict tone="ok">
            Le tableau montre pourquoi l'agnosticisme n'est pas un athéisme timide : il ne répond
            pas à la même question. L'athée répond à « Dieu existe-t-il ? » ; l'agnostique répond à
            « peut-on le savoir ? ».
          </Verdict>
        </div>
      ) : null}
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* 2. Les preuves au tribunal                                          */
/* ------------------------------------------------------------------ */

const PREUVES: ReadonlyArray<Question> = [
  {
    id: "pv1",
    enonce:
      "PREUVE ONTOLOGIQUE, premier pas. « J'ai en moi l'idée d'un être souverainement parfait. » Acceptes-tu cette prémisse ?",
    options: [
      {
        texte: "Oui : j'ai bien l'idée d'un tel être, même si je ne sais pas s'il existe.",
        bonne: true,
        retour:
          "Accordé, et c'est raisonnable : avoir l'idée de quelque chose n'engage à rien sur son existence. J'ai l'idée d'une montagne d'or.",
      },
      {
        texte: "Non : je ne peux pas avoir l'idée de ce qui me dépasse.",
        bonne: false,
        retour:
          "Descartes répondrait que tu l'as pourtant, puisque tu viens d'en parler. Et il ajoute : moi qui suis imparfait, je ne pouvais pas la produire seul.",
      },
    ],
  },
  {
    id: "pv2",
    enonce:
      "Deuxième pas : « un être parfait qui n'existerait pas serait moins parfait qu'un être parfait existant ; l'existence est donc une perfection. » Le saut est-il permis ?",
    options: [
      {
        texte:
          "Non. L'existence n'est pas une qualité qui s'ajoute à un concept : dire qu'une chose existe n'enrichit pas son idée, cela pose son idée comme réalisée.",
        bonne: true,
        retour:
          "C'est l'objection de Kant, et elle est décisive. « Cent thalers réels ne contiennent rien de plus que cent thalers possibles » : si les réels contenaient une pièce de plus, ils ne seraient plus cent.",
      },
      {
        texte: "Oui : mieux vaut exister que ne pas exister, donc l'existence est une perfection.",
        bonne: false,
        retour:
          "C'est exactement ce que Kant conteste. « Mieux vaut » est un jugement de valeur ; être une perfection au sens d'un PRÉDICAT est autre chose. On ne tire jamais une existence d'une définition.",
      },
    ],
  },
  {
    id: "pv3",
    enonce: "Que conclut Kant de cette réfutation ?",
    options: [
      {
        texte:
          "Que l'existence de Dieu ne peut pas être CONNUE — non qu'elle est fausse. Dieu devient un postulat de la raison pratique.",
        bonne: true,
        retour:
          "Oui, et c'est ce qu'il faut absolument dire en copie : « j'ai dû supprimer le savoir pour faire place à la foi ». Ce qu'il retire à la science, il ne le donne pas à l'ignorance.",
      },
      {
        texte: "Que Dieu n'existe pas.",
        bonne: false,
        retour:
          "Contresens fréquent et coûteux. Kant est croyant ; il montre seulement que la raison théorique est incompétente ici.",
      },
    ],
  },
  {
    id: "pv4",
    enonce:
      "PREUVE COSMOLOGIQUE. « Tout ce qui est a une cause ; la série ne peut pas remonter à l'infini ; donc il existe une cause première. » Où le raisonnement cède-t-il ?",
    options: [
      {
        texte:
          "Sur l'arrêt de la série. Si tout a une cause, Dieu aussi ; et si Dieu peut être sans cause, pourquoi l'univers ne le pourrait-il pas ?",
        bonne: true,
        retour:
          "Oui : la règle dont on part est abandonnée exactement là où elle gênerait. On gagne un terme, on ne résout pas la question.",
      },
      {
        texte: "Sur la première prémisse : certaines choses n'ont pas de cause.",
        bonne: false,
        retour:
          "C'est une thèse physique difficile à soutenir, et elle n'est pas nécessaire : l'objection la plus économique porte sur l'arrêt de la série.",
      },
      {
        texte: "Nulle part : le raisonnement est valide.",
        bonne: false,
        retour:
          "Il est cohérent jusqu'au moment où il suspend sa propre règle. C'est ce moment-là qu'il faut viser.",
      },
    ],
  },
  {
    id: "pv5",
    enonce:
      "Leibniz en donne une version plus pure avec le principe de raison suffisante. Quelle est sa question ?",
    options: [
      {
        texte: "« Pourquoi y a-t-il quelque chose plutôt que rien ? »",
        bonne: true,
        retour:
          "Oui, et elle inquiète encore. Remarque qu'elle ne prouve rien : elle montre qu'une question demeure, ce qui n'est pas la même chose.",
      },
      {
        texte: "« Qu'est-ce que je peux savoir ? »",
        bonne: false,
        retour: "C'est l'une des trois questions de Kant, pas celle de Leibniz.",
      },
    ],
  },
  {
    id: "pv6",
    enonce:
      "PREUVE PAR LE DESSEIN. « Cette horloge ne peut pas exister sans horloger » (Voltaire). Quelle est l'objection la plus forte ?",
    options: [
      {
        texte:
          "Le problème du mal : si l'horloger est bon et tout-puissant, pourquoi l'horloge broie-t-elle les innocents ?",
        bonne: true,
        retour:
          "Oui, et Épicure l'a formulée en dilemme : s'il veut supprimer le mal et ne peut pas, il n'est pas tout-puissant ; s'il peut et ne veut pas, il n'est pas bon ; s'il peut et veut, d'où vient le mal ?",
      },
      {
        texte: "L'ordre du monde est une illusion de notre esprit.",
        bonne: false,
        retour:
          "Position défendable mais coûteuse : il faudrait expliquer pourquoi les lois physiques fonctionnent si bien.",
      },
      {
        texte: "Voltaire était déiste, pas chrétien.",
        bonne: false,
        retour: "C'est une remarque sur l'auteur, pas sur l'argument : un ad hominem déguisé.",
      },
    ],
  },
  {
    id: "pv7",
    enonce: "Comment Leibniz répond-il au problème du mal, et comment Voltaire réplique-t-il ?",
    options: [
      {
        texte:
          "Leibniz : ce monde est le meilleur des mondes possibles, et les maux particuliers concourent à un bien d'ensemble. Voltaire réplique dans Candide, après le tremblement de terre de Lisbonne.",
        bonne: true,
        retour:
          "Oui, et la réplique est féroce parce qu'elle est concrète : on ne console pas un enfant écrasé en lui disant qu'il contribue à l'harmonie du tout.",
      },
      {
        texte: "Leibniz nie l'existence du mal.",
        bonne: false,
        retour:
          "Non : il la reconnaît, et c'est pour cela qu'il doit écrire une théodicée — une justification de Dieu.",
      },
    ],
  },
  {
    id: "pv8",
    enonce: "Bilan. Qu'est-ce que cette simulation t'a appris — et que ne t'a-t-elle pas appris ?",
    options: [
      {
        texte:
          "Elle m'a montré où chaque raisonnement cède ; elle ne m'a pas dit s'il faut croire, et ce n'est pas son objet.",
        bonne: true,
        retour:
          "Exactement, et c'est ce que l'épreuve attend. Une copie de philosophie n'a pas à convertir ni à déconvertir : elle a à examiner des arguments.",
      },
      {
        texte: "Que la foi est irrationnelle.",
        bonne: false,
        retour:
          "L'échec des preuves ne montre pas cela. Kant soutient précisément l'inverse : la raison pratique a ses exigences, et Pascal parle d'un autre ordre de connaissance.",
      },
      {
        texte: "Que Dieu existe, puisqu'une question demeure.",
        bonne: false,
        retour:
          "Appel à l'ignorance : l'absence de preuve contre n'est pas une preuve pour. Le chapitre 13 nommera cette faute.",
      },
    ],
  },
];

export function PreuvesDeDieu() {
  return (
    <Qcm
      consigne="Les trois preuves classiques, présentées pas à pas. Accepte ou conteste chaque prémisse, puis affronte l'objection correspondante. La simulation ne te dira pas s'il faut croire : elle te montre où chaque raisonnement cède."
      questions={PREUVES}
      conclusion={
        <>
          Les trois preuves et leurs trois objections, à savoir par cœur. L'
          <strong>ontologique</strong> tombe sur l'argument des cent thalers : l'existence n'est pas
          un prédicat. La <strong>cosmologique</strong> tombe sur l'arrêt arbitraire de la série. La
          preuve <strong>par le dessein</strong> tombe sur le problème du mal. Et{" "}
          <strong>Kant</strong> organise tout : il détruit les preuves théoriques et sauve la foi
          comme postulat de la raison pratique. Le citer des deux côtés d'une dissertation prouve
          qu'on l'a compris.
        </>
      }
    />
  );
}

/* ------------------------------------------------------------------ */
/* 3. La même religion, deux usages                                    */
/* ------------------------------------------------------------------ */

const USAGES: ReadonlyArray<ItemTri> = [
  {
    id: "u1",
    texte:
      "Des propriétaires d'esclaves citent les Épîtres pour exiger la soumission de leurs esclaves.",
    bonne: "dominer",
    pourquoi:
      "Même texte que la ligne suivante. Retiens-le : c'est tout l'argument de la synthèse.",
  },
  {
    id: "u2",
    texte: "Des abolitionnistes citent les mêmes Épîtres pour affirmer l'égale dignité de tous.",
    bonne: "liberer",
    pourquoi:
      "Mêmes Évangiles, usage opposé. Ce qui décide n'est pas la doctrine, c'est la place qu'elle occupe dans les rapports de force.",
  },
  {
    id: "u3",
    texte:
      "L'évangélisation coloniale exige de l'Africain qu'il renie sa langue, ses noms et ses morts pour être sauvé.",
    bonne: "dominer",
    pourquoi:
      "Eboussi Boulaga, Christianisme sans fétiche, 1981. Le christianisme présenté dans les habits de la culture européenne.",
  },
  {
    id: "u4",
    texte:
      "Jean-Marc Ela propose une « théologie sous l'arbre », au ras des villages, contre une Église de cathédrales.",
    bonne: "liberer",
    pourquoi:
      "Le cri de l'homme africain, 1980. La même foi, retournée vers ceux qu'elle servait mal.",
  },
  {
    id: "u5",
    texte:
      "Bossuet fonde le droit divin des rois sur Saint Paul : se révolter, c'est offenser Dieu.",
    bonne: "dominer",
    pourquoi:
      "La thèse religieuse du pouvoir rend toute désobéissance sacrilège. C'est pour cela qu'elle a tant servi.",
  },
  {
    id: "u6",
    texte:
      "Le mouvement des droits civiques est porté par des prédicateurs et leurs congrégations.",
    bonne: "liberer",
    pourquoi:
      "La foi comme ressource d'une lutte politique. On l'oublie souvent dans les copies, et c'est un bon contre-exemple à Marx.",
  },
  {
    id: "u7",
    texte: "Les guerres de religion, l'Inquisition, les condamnations de savants.",
    bonne: "dominer",
    pourquoi: "Le fait est historique et ne se discute pas : la religion a nourri l'intolérance.",
  },
  {
    id: "u8",
    texte: "La théologie de la libération soutient les paysans sans terre en Amérique latine.",
    bonne: "liberer",
    pourquoi:
      "Le soupir de la créature opprimée devenu un cri. C'est l'objection la plus concrète à la formule de Marx.",
  },
  {
    id: "u9",
    texte:
      "Une prédication promet aux pauvres que les derniers seront les premiers — dans l'autre monde.",
    bonne: "dominer",
    pourquoi:
      "C'est précisément l'analyse de Marx : elle reporte la justice dans un au-delà et détourne la révolte de son objet terrestre.",
  },
  {
    id: "u10",
    texte:
      "Mveng nomme « pauvreté anthropologique » le fait d'avoir enlevé aux gens la valeur de ce qu'ils étaient.",
    bonne: "dominer",
    pourquoi:
      "On n'a pas seulement pris les terres : la formule est d'Engelbert Mveng, et elle vaut d'être citée telle quelle.",
  },
];

export function ReligionDeuxUsages() {
  return (
    <div className="space-y-3">
      <JeuTri
        consigne="Dix situations historiques. Dis pour chacune si la religion y a servi à libérer ou à dominer. Regarde bien les deux premières lignes."
        categories={[
          { value: "liberer", label: "À libérer", aide: "elle a porté une émancipation" },
          { value: "dominer", label: "À dominer", aide: "elle a servi un pouvoir" },
        ]}
        items={USAGES}
        conclusion={
          <>
            Les deux premières lignes citent le <strong>même texte</strong>. C'est le cœur de la
            synthèse : la même religion peut opprimer et libérer, et cela ne dépend pas de son
            contenu mais de l'usage qu'on en fait. La formule de Marx — « l'opium du peuple » — est
            donc juste comme <strong>diagnostic d'un usage</strong> et fausse comme{" "}
            <strong>définition d'une essence</strong>.
          </>
        }
      />
      <Citation auteur="la conclusion à retenir">
        La question n'est pas de savoir si la religion est nécessaire, mais <em>laquelle</em> et{" "}
        <em>pour quoi faire</em>. Eboussi Boulaga ne demande pas à l'Africain de cesser de croire :
        il lui demande de croire sans le fétiche qu'on a mis dans sa foi.
      </Citation>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* 4. Vérité et validité                                               */
/* ------------------------------------------------------------------ */

type Raisonnement = {
  id: string;
  majeure: string;
  mineure: string;
  conclusion: string;
  premissesVraies: boolean;
  valide: boolean;
  note: string;
};

const RAISONNEMENTS: ReadonlyArray<Raisonnement> = [
  {
    id: "v1",
    majeure: "Tous les hommes sont mortels.",
    mineure: "Socrate est un homme.",
    conclusion: "Donc Socrate est mortel.",
    premissesVraies: true,
    valide: true,
    note: "Le cas idéal : prémisses vraies et forme correcte. La conclusion est garantie.",
  },
  {
    id: "v2",
    majeure: "Tous les oiseaux sont rouges.",
    mineure: "Le corbeau est un oiseau.",
    conclusion: "Donc le corbeau est rouge.",
    premissesVraies: false,
    valide: true,
    note: "La forme est irréprochable — c'est exactement celle de Socrate. C'est la première prémisse qui est fausse, et la logique n'a rien à y voir.",
  },
  {
    id: "v3",
    majeure: "Tous les chats sont mortels.",
    mineure: "Socrate est mortel.",
    conclusion: "Donc Socrate est un chat.",
    premissesVraies: true,
    valide: false,
    note: "Prémisses vraies, conclusion absurde : la faute est dans la FORME. Le moyen terme « mortel » n'est pris universellement dans aucune des deux prémisses.",
  },
  {
    id: "v4",
    majeure: "Tous les métaux conduisent l'électricité.",
    mineure: "Le cuivre est un métal.",
    conclusion: "Donc le cuivre conduit l'électricité.",
    premissesVraies: true,
    valide: true,
    note: "Rien à redire. Remarque que tu n'as eu besoin d'aucune connaissance en physique pour juger la forme.",
  },
  {
    id: "v5",
    majeure: "S'il pleut, la route est mouillée.",
    mineure: "Or la route est mouillée.",
    conclusion: "Donc il a plu.",
    premissesVraies: true,
    valide: false,
    note: "Affirmation du conséquent. Un camion-citerne a pu passer. La forme valide serait le modus ponens : si A alors B ; or A ; donc B.",
  },
  {
    id: "v6",
    majeure: "S'il pleut, la route est mouillée.",
    mineure: "Or la route n'est pas mouillée.",
    conclusion: "Donc il n'a pas plu.",
    premissesVraies: true,
    valide: true,
    note: "Modus tollens, et c'est la forme même de la réfutation chez Popper : si la théorie est vraie on doit observer ceci ; on ne l'observe pas ; donc elle est fausse.",
  },
  {
    id: "v7",
    majeure: "S'il pleut, la route est mouillée.",
    mineure: "Or il ne pleut pas.",
    conclusion: "Donc la route est sèche.",
    premissesVraies: true,
    valide: false,
    note: "Négation de l'antécédent. Même camion-citerne, même erreur, symétrique de la précédente.",
  },
  {
    id: "v8",
    majeure: "Quelques élèves sont studieux.",
    mineure: "Quelques élèves sont bavards.",
    conclusion: "Donc quelques studieux sont bavards.",
    premissesVraies: true,
    valide: false,
    note: "De deux prémisses particulières, rien ne suit : les deux « quelques » peuvent désigner des élèves différents. Il faut au moins une prémisse universelle.",
  },
  {
    id: "v9",
    majeure: "Tous les hommes sont mortels.",
    mineure: "Les chats sont mortels.",
    conclusion: "Donc les chats sont mortels.",
    premissesVraies: true,
    valide: false,
    note: "La conclusion est vraie, et le raisonnement ne l'a pas établie : elle était déjà posée dans la deuxième prémisse. C'est une pétition de principe, et c'est le cas le plus déroutant du lot.",
  },
  {
    id: "v10",
    majeure: "Aucun oiseau n'est un mammifère.",
    mineure: "Aucun poisson n'est un oiseau.",
    conclusion: "Donc aucun poisson n'est un mammifère.",
    premissesVraies: true,
    valide: false,
    note: "De deux prémisses négatives, rien ne suit. La conclusion est vraie par ailleurs, mais ces deux prémisses ne l'établissent pas.",
  },
  {
    id: "v11",
    majeure: "Tous les Camerounais sont africains.",
    mineure: "Thierry est camerounais.",
    conclusion: "Donc Thierry est africain.",
    premissesVraies: true,
    valide: true,
    note: "Valide et vrai. La forme est celle de Socrate, et elle ne trompe jamais.",
  },
  {
    id: "v12",
    majeure: "Tous les Camerounais sont africains.",
    mineure: "Awa est africaine.",
    conclusion: "Donc Awa est camerounaise.",
    premissesVraies: true,
    valide: false,
    note: "Même faute que le syllogisme des chats : « africain » n'est pris universellement nulle part. La forme « tous les A sont C ; B est C ; donc B est A » est toujours invalide.",
  },
];

const RAIS_VIDE: Raisonnement = {
  id: "",
  majeure: "—",
  mineure: "—",
  conclusion: "—",
  premissesVraies: false,
  valide: false,
  note: "—",
};

export function VeriteValidite() {
  const [rang, setRang] = useState(0);
  const [rv, setRv] = useState<boolean | null>(null);
  const [rf, setRf] = useState<boolean | null>(null);
  const [score, setScore] = useState(0);
  const [vus, setVus] = useState(0);

  const r = RAISONNEMENTS[rang] ?? RAIS_VIDE;
  const complet = rv !== null && rf !== null;
  const juste = complet && rv === r.premissesVraies && rf === r.valide;

  function bouton(
    valeur: boolean,
    attendu: boolean,
    actuel: boolean | null,
    set: (v: boolean) => void,
  ) {
    const actif = actuel === valeur;
    const bon = actuel !== null && actuel === attendu;
    const cls = !actif
      ? "border-border bg-background text-muted-foreground hover:bg-secondary/60"
      : bon
        ? "border-emerald-500/40 bg-emerald-500/15 text-emerald-700"
        : "border-rose-500/40 bg-rose-500/15 text-rose-700";
    return (
      <button
        key={valeur ? "oui" : "non"}
        type="button"
        onClick={() => set(valeur)}
        className={`rounded-lg border px-2.5 py-1 text-xs font-medium ${cls}`}
      >
        {valeur ? "oui" : "non"}
      </button>
    );
  }

  return (
    <div className="space-y-3">
      <p className="text-sm text-muted-foreground">
        Douze raisonnements, et deux questions <strong>indépendantes</strong> pour chacun : les
        prémisses sont-elles vraies, et la forme est-elle valide ? Les quatre combinaisons sont
        représentées, y compris la plus déroutante — une conclusion vraie obtenue par un
        raisonnement fautif.
      </p>

      <div className="rounded-lg border border-border bg-background p-3">
        <div className="space-y-0.5 font-mono text-xs leading-relaxed text-foreground">
          <p>{r.majeure}</p>
          <p>{r.mineure}</p>
          <p className="border-t border-border pt-0.5 font-semibold">{r.conclusion}</p>
        </div>

        <div className="mt-3 grid gap-2 sm:grid-cols-2">
          <div className="space-y-1">
            <p className="text-[11px] font-medium text-muted-foreground">
              Les prémisses sont-elles vraies ?
            </p>
            <div className="flex gap-1">
              {[true, false].map((v) => bouton(v, r.premissesVraies, rv, setRv))}
            </div>
          </div>
          <div className="space-y-1">
            <p className="text-[11px] font-medium text-muted-foreground">
              La forme est-elle valide ?
            </p>
            <div className="flex gap-1">
              {[true, false].map((v) => bouton(v, r.valide, rf, setRf))}
            </div>
          </div>
        </div>

        {complet ? (
          <div className="mt-3 space-y-2">
            <Verdict tone={juste ? "ok" : "warn"}>
              <span className="font-semibold">
                {r.premissesVraies ? "Prémisses vraies" : "Prémisse fausse"} ·{" "}
                {r.valide ? "forme valide" : "forme invalide"}.{" "}
              </span>
              {r.note}
            </Verdict>
            <p className="rounded-lg bg-secondary/40 px-2.5 py-1.5 text-[11px] leading-snug text-muted-foreground">
              Ce que le correcteur verrait :{" "}
              {r.valide && r.premissesVraies
                ? "une démonstration recevable."
                : r.valide
                  ? "un raisonnement bien conduit sur une information fausse — il faut vérifier les faits, pas la logique."
                  : "une faute de raisonnement, et elle se voit même quand la conclusion est juste."}
            </p>
            <button
              type="button"
              onClick={() => {
                if (juste) setScore((s) => s + 1);
                setVus((v) => v + 1);
                setRang((x) => (x + 1) % RAISONNEMENTS.length);
                setRv(null);
                setRf(null);
              }}
              className="rounded-lg bg-primary px-3 py-1.5 text-xs font-semibold text-primary-foreground"
            >
              Suivant ({rang + 1} / {RAISONNEMENTS.length})
            </button>
          </div>
        ) : null}
      </div>

      <div className="grid grid-cols-2 gap-2">
        <Stat label="Analysés" value={`${vus}`} color={PALETTE.slate} />
        <Stat label="Doubles réponses justes" value={`${score}`} color={PALETTE.green} />
      </div>

      <Citation auteur="à retenir avant l'épreuve">
        Une bonne conclusion mal démontrée rapporte peu de points : le correcteur n'évalue pas
        seulement ce que vous concluez, il évalue <em>comment</em> vous y arrivez. C'est la démarche
        qui est notée.
      </Citation>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* 5. L'atelier du syllogisme                                          */
/* ------------------------------------------------------------------ */

type Terme = {
  cle: string;
  nomPl: string;
  nomSg: string;
  attrSg: string;
  attrPl: string;
  singulier: boolean;
};

const TERMES: ReadonlyArray<Terme> = [
  {
    cle: "homme",
    nomPl: "les hommes",
    nomSg: "homme",
    attrSg: "un homme",
    attrPl: "des hommes",
    singulier: false,
  },
  {
    cle: "mortel",
    nomPl: "les mortels",
    nomSg: "mortel",
    attrSg: "mortel",
    attrPl: "mortels",
    singulier: false,
  },
  {
    cle: "chat",
    nomPl: "les chats",
    nomSg: "chat",
    attrSg: "un chat",
    attrPl: "des chats",
    singulier: false,
  },
  {
    cle: "oiseau",
    nomPl: "les oiseaux",
    nomSg: "oiseau",
    attrSg: "un oiseau",
    attrPl: "des oiseaux",
    singulier: false,
  },
  {
    cle: "mammifere",
    nomPl: "les mammifères",
    nomSg: "mammifère",
    attrSg: "un mammifère",
    attrPl: "des mammifères",
    singulier: false,
  },
  {
    cle: "eleve",
    nomPl: "les élèves",
    nomSg: "élève",
    attrSg: "un élève",
    attrPl: "des élèves",
    singulier: false,
  },
  {
    cle: "studieux",
    nomPl: "les studieux",
    nomSg: "studieux",
    attrSg: "studieux",
    attrPl: "studieux",
    singulier: false,
  },
  {
    cle: "citoyen",
    nomPl: "les citoyens",
    nomSg: "citoyen",
    attrSg: "un citoyen",
    attrPl: "des citoyens",
    singulier: false,
  },
  {
    cle: "loi",
    nomPl: "les gens soumis à la loi",
    nomSg: "homme soumis à la loi",
    attrSg: "soumis à la loi",
    attrPl: "soumis à la loi",
    singulier: false,
  },
  {
    cle: "socrate",
    nomPl: "Socrate",
    nomSg: "Socrate",
    attrSg: "Socrate",
    attrPl: "Socrate",
    singulier: true,
  },
  {
    cle: "moineau",
    nomPl: "le moineau",
    nomSg: "moineau",
    attrSg: "un moineau",
    attrPl: "des moineaux",
    singulier: true,
  },
  {
    cle: "thierry",
    nomPl: "Thierry",
    nomSg: "Thierry",
    attrSg: "Thierry",
    attrPl: "Thierry",
    singulier: true,
  },
];

const TERME_VIDE: Terme = {
  cle: "",
  nomPl: "—",
  nomSg: "—",
  attrSg: "—",
  attrPl: "—",
  singulier: false,
};

function terme(cle: string): Terme {
  return TERMES.find((t) => t.cle === cle) ?? TERME_VIDE;
}

type Qualite = "A" | "E" | "I";
type Prop = { id: string; texte: string; q: Qualite; s: string; p: string };

const MAJEURES: ReadonlyArray<Prop> = [
  { id: "M1", texte: "Tous les hommes sont mortels.", q: "A", s: "homme", p: "mortel" },
  { id: "M2", texte: "Tous les chats sont mortels.", q: "A", s: "chat", p: "mortel" },
  { id: "M3", texte: "Aucun oiseau n'est un mammifère.", q: "E", s: "oiseau", p: "mammifere" },
  { id: "M4", texte: "Quelques élèves sont studieux.", q: "I", s: "eleve", p: "studieux" },
  { id: "M5", texte: "Tous les citoyens sont soumis à la loi.", q: "A", s: "citoyen", p: "loi" },
];

const MINEURES: ReadonlyArray<Prop> = [
  { id: "m1", texte: "Socrate est un homme.", q: "A", s: "socrate", p: "homme" },
  { id: "m2", texte: "Socrate est mortel.", q: "A", s: "socrate", p: "mortel" },
  { id: "m3", texte: "Le moineau est un oiseau.", q: "A", s: "moineau", p: "oiseau" },
  { id: "m4", texte: "Quelques élèves sont bavards.", q: "I", s: "eleve", p: "studieux" },
  { id: "m5", texte: "Thierry est un citoyen.", q: "A", s: "thierry", p: "citoyen" },
];

const PROP_VIDE: Prop = { id: "", texte: "—", q: "A", s: "", p: "" };

/** Le sujet d'une universelle est distribué ; une négative distribue aussi son prédicat. */
function distribue(prop: Prop, t: string): boolean {
  if (prop.q === "E") return prop.s === t || prop.p === t;
  if (prop.q === "A") return prop.s === t;
  return false;
}

type Analyse = {
  valide: boolean;
  conclusion: string;
  regles: ReadonlyArray<{ nom: string; ok: boolean; note: string }>;
};

function analyser(maj: Prop, min: Prop): Analyse {
  const termesMaj = [maj.s, maj.p];
  const termesMin = [min.s, min.p];
  const communs = termesMaj.filter((t) => termesMin.includes(t));
  const moyen = communs[0] ?? "";

  const regles: Array<{ nom: string; ok: boolean; note: string }> = [];

  if (communs.length !== 1) {
    regles.push({
      nom: "Trois termes, et un seul moyen terme",
      ok: false,
      note:
        communs.length === 0
          ? "Aucun terme commun aux deux prémisses : elles ne se rencontrent nulle part, donc rien ne peut en sortir."
          : "Les deux prémisses partagent leurs deux termes : il n'y a que deux termes en tout, et aucune conclusion nouvelle n'est possible.",
    });
    return { valide: false, conclusion: "Aucune conclusion ne suit.", regles };
  }
  regles.push({
    nom: "Trois termes, et un seul moyen terme",
    ok: true,
    note: `Le moyen terme est « ${terme(moyen).nomSg} » : il figure dans les deux prémisses et doit disparaître de la conclusion.`,
  });

  const grand = maj.s === moyen ? maj.p : maj.s;
  const petit = min.s === moyen ? min.p : min.s;

  const deuxNegatives = maj.q === "E" && min.q === "E";
  regles.push({
    nom: "Pas deux prémisses négatives",
    ok: !deuxNegatives,
    note: deuxNegatives
      ? "Deux négatives ne donnent jamais rien : savoir que deux ensembles sont exclus d'un troisième ne dit pas comment ils se situent l'un par rapport à l'autre."
      : "Au moins une prémisse affirmative : la règle est respectée.",
  });

  const deuxParticulieres = maj.q === "I" && min.q === "I";
  regles.push({
    nom: "Au moins une prémisse universelle",
    ok: !deuxParticulieres,
    note: deuxParticulieres
      ? "Deux « quelques » peuvent désigner des individus différents : les deux prémisses ne parlent peut-être pas des mêmes."
      : "Une prémisse au moins est universelle : la règle est respectée.",
  });

  const moyenDistribue = distribue(maj, moyen) || distribue(min, moyen);
  regles.push({
    nom: "Le moyen terme pris universellement au moins une fois",
    ok: moyenDistribue,
    note: moyenDistribue
      ? `« ${terme(moyen).nomSg} » est pris dans toute son extension au moins une fois : les deux autres termes se rencontrent bien par lui.`
      : `« ${terme(moyen).nomSg} » n'est jamais pris dans toute son extension : les deux prémisses peuvent parler de deux parties différentes du même ensemble. C'est le MOYEN TERME NON DISTRIBUÉ, la faute la plus fréquente.`,
  });

  const negative = maj.q === "E" || min.q === "E";
  const particuliere = maj.q === "I" || min.q === "I";

  // un terme distribué dans la conclusion doit l'être dans sa prémisse
  const grandDistribueConclusion = negative; // prédicat distribué seulement si négative
  const petitDistribueConclusion = !particuliere; // sujet distribué seulement si universelle
  const illiciteGrand = grandDistribueConclusion && !distribue(maj, grand);
  const illicitePetit = petitDistribueConclusion && !distribue(min, petit);
  regles.push({
    nom: "Aucun terme plus étendu dans la conclusion que dans sa prémisse",
    ok: !illiciteGrand && !illicitePetit,
    note:
      illiciteGrand || illicitePetit
        ? "Un terme est pris dans toute son extension dans la conclusion alors qu'il ne l'était pas dans sa prémisse : on conclut plus qu'on ne savait."
        : "Aucun terme n'est élargi en route.",
  });

  const valide = regles.every((r) => r.ok);

  const ts = terme(petit);
  const tp = terme(grand);
  let conclusion: string;
  if (!valide) {
    conclusion = "Aucune conclusion valide ne suit de ces deux prémisses.";
  } else if (ts.singulier) {
    conclusion = negative
      ? `Donc ${ts.nomPl} n'est pas ${tp.attrSg}.`
      : `Donc ${ts.nomPl} est ${tp.attrSg}.`;
  } else if (negative && !particuliere) {
    conclusion = `Donc aucun ${ts.nomSg} n'est ${tp.attrSg}.`;
  } else if (negative) {
    conclusion = `Donc quelques ${ts.nomPl} ne sont pas ${tp.attrPl}.`;
  } else if (particuliere) {
    conclusion = `Donc quelques ${ts.nomPl} sont ${tp.attrPl}.`;
  } else {
    conclusion = `Donc tous ${ts.nomPl} sont ${tp.attrPl}.`;
  }

  return { valide, conclusion, regles };
}

export function AtelierSyllogisme() {
  const [iMaj, setIMaj] = useState(0);
  const [iMin, setIMin] = useState(0);

  const maj = MAJEURES[iMaj] ?? PROP_VIDE;
  const min = MINEURES[iMin] ?? PROP_VIDE;
  const a = useMemo(() => analyser(maj, min), [maj, min]);

  return (
    <div className="space-y-3">
      <p className="text-sm text-muted-foreground">
        Construis tes propres syllogismes en choisissant deux prémisses, et la simulation vérifie la
        forme règle par règle. Vingt-cinq combinaisons t'attendent, dont la plupart sont invalides.
      </p>

      <div className="space-y-2">
        <div>
          <p className="mb-1 text-[11px] font-semibold uppercase tracking-wide text-muted-foreground">
            La majeure
          </p>
          <div className="flex flex-col gap-1">
            {MAJEURES.map((p, i) => (
              <button
                key={p.id}
                type="button"
                onClick={() => setIMaj(i)}
                className={
                  i === iMaj
                    ? "rounded-lg bg-primary px-2.5 py-1.5 text-left text-xs font-semibold text-primary-foreground"
                    : "rounded-lg border border-border px-2.5 py-1.5 text-left text-xs text-muted-foreground hover:bg-secondary/60"
                }
              >
                {p.texte}
              </button>
            ))}
          </div>
        </div>
        <div>
          <p className="mb-1 text-[11px] font-semibold uppercase tracking-wide text-muted-foreground">
            La mineure
          </p>
          <div className="flex flex-col gap-1">
            {MINEURES.map((p, i) => (
              <button
                key={p.id}
                type="button"
                onClick={() => setIMin(i)}
                className={
                  i === iMin
                    ? "rounded-lg bg-primary px-2.5 py-1.5 text-left text-xs font-semibold text-primary-foreground"
                    : "rounded-lg border border-border px-2.5 py-1.5 text-left text-xs text-muted-foreground hover:bg-secondary/60"
                }
              >
                {p.texte}
              </button>
            ))}
          </div>
        </div>
      </div>

      <div className="rounded-lg border border-border bg-background p-3">
        <div className="space-y-0.5 font-mono text-xs leading-relaxed text-foreground">
          <p>{maj.texte}</p>
          <p>{min.texte}</p>
          <p
            className="border-t border-border pt-0.5 font-semibold"
            style={{ color: a.valide ? PALETTE.green : PALETTE.red }}
          >
            {a.conclusion}
          </p>
        </div>
      </div>

      <ul className="space-y-1.5">
        {a.regles.map((r) => (
          <li
            key={r.nom}
            className="rounded-lg border px-2.5 py-1.5"
            style={{
              borderColor: r.ok ? "rgba(22,163,74,0.4)" : "rgba(220,38,38,0.4)",
              backgroundColor: r.ok ? "rgba(22,163,74,0.07)" : "rgba(220,38,38,0.07)",
            }}
          >
            <p className="text-xs font-medium text-foreground">
              {r.ok ? "✓ " : "✗ "}
              {r.nom}
            </p>
            <p className="mt-0.5 text-[11px] leading-snug text-muted-foreground">{r.note}</p>
          </li>
        ))}
      </ul>

      <Verdict tone={a.valide ? "ok" : "bad"}>
        {a.valide
          ? "Syllogisme valide. Attention : valide ne veut pas dire vrai — il garantit seulement que SI les prémisses sont vraies, la conclusion l'est aussi."
          : "Syllogisme invalide : au moins une règle est violée, et aucune conclusion ne suit — même si une conclusion vraie pouvait être devinée par ailleurs."}
      </Verdict>

      <p className="text-[11px] leading-snug text-muted-foreground">
        Essaie « Tous les chats sont mortels » avec « Socrate est mortel » : les deux prémisses sont
        vraies, et pourtant rien ne suit. C'est le <strong>moyen terme non distribué</strong>, et on
        le reconnaît à vue : la forme « tous les A sont C ; B est C ; donc B est A » est toujours
        invalide, quoi qu'on mette dans A, B et C.
      </p>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* 6. Le détecteur de sophismes                                        */
/* ------------------------------------------------------------------ */

const SOPHISMES: ReadonlyArray<Question> = [
  {
    id: "so1",
    enonce: "« Tout le monde le fait, donc ce n'est pas si grave. »",
    options: [
      {
        texte: "Appel à la majorité",
        bonne: true,
        retour:
          "Oui, ad populum. Tout le monde a cru la Terre immobile. Correction honnête : dire ce qui rend l'acte grave ou non, indépendamment du nombre.",
      },
      {
        texte: "Généralisation hâtive",
        bonne: false,
        retour:
          "Non : rien n'est généralisé à partir de quelques cas. C'est le nombre qui sert de preuve.",
      },
      {
        texte: "Pétition de principe",
        bonne: false,
        retour: "Non : la conclusion n'est pas supposée dans les prémisses.",
      },
    ],
  },
  {
    id: "so2",
    enonce: "« On n'a jamais prouvé le contraire, donc c'est vrai. »",
    options: [
      {
        texte: "Appel à l'ignorance",
        bonne: true,
        retour:
          "Oui : l'absence de preuve contre n'est pas une preuve pour. Correction : chercher une raison positive, ou suspendre son jugement.",
      },
      {
        texte: "Faux dilemme",
        bonne: false,
        retour: "Non : aucune alternative artificielle n'est posée.",
      },
      {
        texte: "Post hoc ergo propter hoc",
        bonne: false,
        retour: "Non : il n'est question d'aucune succession temporelle.",
      },
    ],
  },
  {
    id: "so3",
    enonce: "« Depuis qu'on a changé la loi, la criminalité a augmenté : il faut la supprimer. »",
    options: [
      {
        texte: "Post hoc ergo propter hoc",
        bonne: true,
        retour:
          "Oui : confondre la succession et la causalité. Correction : établir un mécanisme et comparer avec une région comparable où la loi n'a pas changé.",
      },
      {
        texte: "Appel à l'autorité",
        bonne: false,
        retour: "Non : personne n'est invoqué comme garant.",
      },
      {
        texte: "Homme de paille",
        bonne: false,
        retour: "Non : aucune position adverse n'est déformée.",
      },
    ],
  },
  {
    id: "so4",
    enonce: "« Tu ne peux rien dire de la corruption, ton propre oncle est fonctionnaire. »",
    options: [
      {
        texte: "Argument ad hominem",
        bonne: true,
        retour:
          "Oui : on attaque la personne au lieu de sa thèse. L'origine d'un énoncé ne décide pas de sa valeur. Correction : examiner ce qu'il affirme.",
      },
      { texte: "Appel à la majorité", bonne: false, retour: "Non : le nombre n'est pas invoqué." },
      { texte: "Équivoque", bonne: false, retour: "Non : aucun mot ne change de sens en route." },
    ],
  },
  {
    id: "so5",
    enonce: "« Ou bien tu acceptes cette réforme, ou bien tu veux la ruine du pays. »",
    options: [
      {
        texte: "Faux dilemme",
        bonne: true,
        retour:
          "Oui : deux options présentées comme exhaustives. Correction : montrer la troisième voie — amender la réforme, en différer une part, en proposer une autre.",
      },
      {
        texte: "Pente glissante",
        bonne: false,
        retour:
          "Pas tout à fait : il n'y a pas d'enchaînement de conséquences, mais une alternative forcée.",
      },
      { texte: "Pétition de principe", bonne: false, retour: "Non." },
    ],
  },
  {
    id: "so6",
    enonce:
      "« Ce livre dit vrai, car il est inspiré ; et il est inspiré, car le livre le dit lui-même. »",
    options: [
      {
        texte: "Pétition de principe",
        bonne: true,
        retour:
          "Oui, un cercle vicieux. C'est la faute la plus fréquente dans les copies de philosophie, et la plus difficile à voir dans ses propres phrases. Correction : un critère extérieur aux deux propositions.",
      },
      {
        texte: "Appel à l'autorité",
        bonne: false,
        retour:
          "Il y a de cela, mais le défaut principal est la circularité : chaque proposition s'appuie sur l'autre.",
      },
      { texte: "Appel à l'ignorance", bonne: false, retour: "Non." },
    ],
  },
  {
    id: "so7",
    enonce:
      "« Si on autorise cela, bientôt plus rien ne sera interdit et la société s'effondrera. »",
    options: [
      {
        texte: "Pente glissante",
        bonne: true,
        retour:
          "Oui : des conséquences de plus en plus graves, sans qu'aucun maillon soit établi. Correction : démontrer le premier enchaînement, ou renoncer.",
      },
      {
        texte: "Faux dilemme",
        bonne: false,
        retour: "Non : aucune alternative à deux branches n'est posée.",
      },
      {
        texte: "Généralisation hâtive",
        bonne: false,
        retour: "Non : on n'infère pas d'un cas particulier à une règle.",
      },
    ],
  },
  {
    id: "so8",
    enonce:
      "« Mon adversaire veut supprimer toute règle et livrer le pays au chaos. » (Il demandait l'allègement d'une procédure.)",
    options: [
      {
        texte: "Homme de paille",
        bonne: true,
        retour:
          "Oui : on déforme la thèse adverse pour la rendre absurde. On la reconnaît à ceci — l'adversaire ne se reconnaît pas dans ce qu'on lui prête. C'est pourquoi une bonne antithèse présente la position adverse sous sa forme la plus forte.",
      },
      {
        texte: "Ad hominem",
        bonne: false,
        retour: "Non : c'est sa thèse qu'on déforme, pas sa personne qu'on attaque.",
      },
      {
        texte: "Appel à la peur",
        bonne: false,
        retour: "Il y en a, mais le défaut premier est la déformation de la thèse.",
      },
    ],
  },
  {
    id: "so9",
    enonce:
      "« L'homme est libre ; or le prisonnier n'est pas libre ; donc le prisonnier n'est pas un homme. »",
    options: [
      {
        texte: "Équivoque",
        bonne: true,
        retour:
          "Oui : « libre » n'a pas le même sens dans les deux prémisses — liberté métaphysique d'un côté, liberté de mouvement de l'autre. C'est le principe d'identité qui est violé.",
      },
      {
        texte: "Moyen terme non distribué",
        bonne: false,
        retour:
          "La forme serait acceptable si le mot gardait son sens : la faute est dans le glissement de sens, qui crée en réalité un quatrième terme.",
      },
      { texte: "Pétition de principe", bonne: false, retour: "Non." },
    ],
  },
  {
    id: "so10",
    enonce:
      "VALIDE OU NON ? « Si cette théorie est vraie, on doit observer ce phénomène. Or on ne l'observe pas. Donc elle est fausse. »",
    options: [
      {
        texte: "Rien à signaler : c'est un modus tollens, et il est valide.",
        bonne: true,
        retour:
          "Exactement, et c'est la forme même de la réfutation chez Popper. Chercher un piège partout est aussi une faute de jugement.",
      },
      {
        texte: "Affirmation du conséquent",
        bonne: false,
        retour:
          "Non : ce serait « or on l'observe, donc elle est vraie ». Ici c'est la négation du conséquent, et elle est valide.",
      },
      {
        texte: "Pente glissante",
        bonne: false,
        retour: "Non : aucun enchaînement de conséquences.",
      },
    ],
  },
  {
    id: "so11",
    enonce:
      "VALIDE OU NON ? « Deux commerçants m'ont trompé, donc les commerçants sont malhonnêtes. »",
    options: [
      {
        texte: "Généralisation hâtive",
        bonne: true,
        retour:
          "Oui. Correction : « deux commerçants m'ont trompé », qui est une particulière et n'engage rien d'autre. Rappelle-toi le carré logique : un seul contre-exemple suffit à renverser une universelle.",
      },
      {
        texte: "Rien à signaler.",
        bonne: false,
        retour:
          "Deux cas ne constituent pas un échantillon. La conclusion est universelle, les prémisses ne le sont pas.",
      },
    ],
  },
  {
    id: "so12",
    enonce:
      "VALIDE OU NON ? « Kant soutient que l'existence n'est pas un prédicat, et voici son argument des cent thalers. »",
    options: [
      {
        texte:
          "Rien à signaler : citer un auteur AVEC son argument n'est pas un appel à l'autorité.",
        bonne: true,
        retour:
          "Oui, et la nuance est importante pour vos copies. Citer un auteur pour EXPOSER une thèse est attendu ; le sophisme commence quand la citation REMPLACE l'argument. Un nom n'est pas une preuve, un nom plus un argument en est une.",
      },
      {
        texte: "Appel à l'autorité",
        bonne: false,
        retour:
          "Non, précisément : l'argument est donné. Sans lui, ce serait un appel à l'autorité.",
      },
    ],
  },
];

export function DetecteurSophismes() {
  return (
    <Qcm
      consigne="Douze arguments tirés de débats ordinaires. Nomme la faute — et attention, trois d'entre eux n'en contiennent aucune : il faut savoir les laisser passer."
      questions={SOPHISMES}
      conclusion={
        <>
          Les trois derniers étaient le vrai test. Chercher un piège partout est aussi une faute de
          jugement : un <strong>modus tollens</strong> est valide, et citer un auteur{" "}
          <em>avec son argument</em> n'est pas un appel à l'autorité. Pour l'épreuve, retiens les
          cinq qui coûtent le plus de points, dans l'ordre : la{" "}
          <strong>pétition de principe</strong>, la <strong>généralisation hâtive</strong>, l'
          <strong>ad hominem</strong>, le <strong>post hoc ergo propter hoc</strong> et le{" "}
          <strong>faux dilemme</strong>. Et relis toujours ton antithèse en te demandant si
          l'adversaire se reconnaîtrait dans ce que tu lui fais dire.
        </>
      }
    />
  );
}
