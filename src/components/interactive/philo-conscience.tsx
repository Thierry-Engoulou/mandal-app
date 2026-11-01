import { useState } from "react";
import { Choice, Ctrl, PALETTE, Stat, Verdict } from "./controls";
import {
  Citation,
  JeuTri,
  Jauges,
  Parcours,
  Qcm,
  type Etape,
  type ItemTri,
  type Question,
} from "./philo-noyau";

/** Philosophie Terminale C et D — chapitres 4 et 5 :
 *  la conscience et l'inconscient, autrui et la morale. */

/* ------------------------------------------------------------------ */
/* 1. Conscience psychologique, conscience morale, inconscient         */
/* ------------------------------------------------------------------ */

const SITUATIONS: ReadonlyArray<ItemTri> = [
  {
    id: "n1",
    texte: "Je sais que je suis en train de lire, et que c'est moi qui lis.",
    bonne: "psy",
    pourquoi:
      "Conscience psychologique : la présence de l'esprit à lui-même et à ce qu'il fait. Elle constate, elle ne juge pas.",
  },
  {
    id: "n2",
    texte: "Après avoir menti à mon père, quelque chose en moi me reproche de l'avoir fait.",
    bonne: "morale",
    pourquoi:
      "Conscience morale : elle juge la valeur de l'acte. Rousseau l'appelle « instinct divin » et « juge infaillible du bien et du mal ».",
  },
  {
    id: "n3",
    texte: "En plein exposé, je voulais dire « ouvrir la séance » et j'ai dit « clore la séance ».",
    bonne: "inconscient",
    pourquoi:
      "Un lapsus. Pour Freud, ce n'est pas un hasard : un désir que je ne m'avoue pas — en finir avec cet exposé — a trouvé la parole.",
  },
  {
    id: "n4",
    texte: "Je conduis depuis vingt minutes et je ne me rappelle rien du trajet.",
    bonne: "psy",
    pourquoi:
      "Attention au piège : c'est l'automatisme, et il relève de l'inconscient au sens COURANT — ce dont on n'a pas conscience. Rien n'y est refoulé, donc rien de freudien. On le classe comme un bas degré de conscience psychologique.",
  },
  {
    id: "n5",
    texte: "J'oublie systématiquement le nom d'un collègue que je n'aime pas.",
    bonne: "inconscient",
    pourquoi:
      "Oubli motivé. Freud montre que l'oubli sélectif obéit à une intention que le sujet ignore : c'est l'inconscient au sens fort, comme instance active.",
  },
  {
    id: "n6",
    texte: "Je rêve que je passe un examen sans avoir révisé, et je me réveille soulagé.",
    bonne: "inconscient",
    pourquoi:
      "Le rêve est pour Freud « la voie royale » vers l'inconscient : un désir y accède à une satisfaction déguisée.",
  },
  {
    id: "n7",
    texte: "Je sens que je rougis, et je sais pourquoi.",
    bonne: "psy",
    pourquoi:
      "Conscience psychologique immédiate, doublée d'une réflexion. Elle porte sur un fait, pas sur une valeur.",
  },
  {
    id: "n8",
    texte: "Socrate préfère mourir plutôt que de renier ce qu'il tient pour vrai.",
    bonne: "morale",
    pourquoi:
      "Conscience morale à son plus haut : elle ne compare pas des avantages, elle juge. C'est la différence avec un calcul.",
  },
  {
    id: "n9",
    texte: "Je me vois agir et je me demande qui je suis.",
    bonne: "psy",
    pourquoi:
      "Conscience réfléchie : l'esprit se prend lui-même pour objet. Elle est le fondement du cogito cartésien.",
  },
  {
    id: "n10",
    texte: "Je veux sincèrement arrêter de fumer, et je continue sans comprendre pourquoi.",
    bonne: "inconscient",
    pourquoi:
      "C'est l'argument central de Freud : si ma volonté consciente suffisait, l'écart serait impossible. L'écart prouve qu'autre chose décide.",
  },
  {
    id: "n11",
    texte: "Un enfant de quatre ans prend un fruit, voit le regard de sa mère, et le repose.",
    bonne: "morale",
    pourquoi:
      "La conscience morale en train de se former — chez Freud, par intériorisation de l'interdit : c'est la naissance du surmoi.",
  },
  {
    id: "n12",
    texte:
      "Je crois avoir choisi ce métier librement, et je découvre que c'était celui de mon père.",
    bonne: "inconscient",
    pourquoi:
      "Le cas qui fait les bons sujets : ma décision avait des raisons que je ne connaissais pas. Spinoza dirait la même chose sans Freud — on se croit libre faute de connaître les causes.",
  },
];

export function NotionsConscience() {
  return (
    <div className="space-y-3">
      <JeuTri
        consigne="Douze situations. Range-les entre conscience psychologique, conscience morale et inconscient. Deux cas au moins se défendent autrement qu'attendu, et ce sont eux qui font les bons sujets de dissertation."
        categories={[
          { value: "psy", label: "Conscience psychologique", aide: "elle constate" },
          { value: "morale", label: "Conscience morale", aide: "elle juge" },
          { value: "inconscient", label: "Inconscient", aide: "au sens freudien : actif, refoulé" },
        ]}
        items={SITUATIONS}
        conclusion={
          <>
            Le critère qui tranche entre les deux consciences : la psychologique{" "}
            <strong>constate</strong> un fait, la morale <strong>juge</strong> une valeur. Et le
            critère qui tranche entre les deux sens d'« inconscient » : le sens courant désigne une
            simple absence — l'automatisme, le sommeil —, le sens freudien désigne une instance{" "}
            <strong>active</strong>, qui veut quelque chose et agit contre ma volonté déclarée.
          </>
        }
      />
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* 2. Mener le doute cartésien jusqu'au cogito                         */
/* ------------------------------------------------------------------ */

const DOUTE: ReadonlyArray<Etape> = [
  {
    titre: "Les sens",
    question:
      "Première certitude : « ce bâton plongé dans l'eau est brisé, je le vois. » Quel argument l'élimine ?",
    options: [
      {
        texte:
          "Les sens me trompent parfois ; or ce qui m'a trompé une fois peut me tromper toujours.",
        bonne: true,
        retour:
          "Oui, et notez la rigueur : Descartes ne dit pas que les sens trompent toujours, il dit qu'il suffit qu'ils puissent tromper pour qu'on ne puisse plus s'y fier sans examen.",
      },
      {
        texte: "Peut-être que je rêve.",
        bonne: false,
        retour:
          "L'argument du rêve viendra, mais il est trop puissant pour cette étape : il vise l'existence du monde entier, pas une illusion particulière. Chaque argument à son rang.",
      },
      {
        texte: "La science a montré que la lumière se réfracte.",
        bonne: false,
        retour:
          "C'est une explication, pas un doute. Descartes ne cherche pas la cause de l'illusion, il cherche s'il peut encore se fier au témoignage des sens.",
      },
    ],
  },
  {
    titre: "Le calcul",
    question:
      "Deuxième certitude : « deux et trois font cinq, je ne peux pas me tromper là-dessus. » Quel argument l'ébranle ?",
    options: [
      {
        texte:
          "Il m'est arrivé de me tromper en calculant ; rien ne garantit que je ne me trompe pas même quand je crois voir clairement.",
        bonne: true,
        retour:
          "Oui : l'erreur de raisonnement. Et c'est plus grave que l'illusion des sens, parce qu'ici la faculté qui doute est celle-là même qui est suspectée.",
      },
      {
        texte: "Les mathématiques sont une convention humaine.",
        bonne: false,
        retour:
          "Ce serait une thèse sur la nature des mathématiques. Descartes raisonne autrement : il part d'un fait d'expérience, qu'on se trompe en calculant.",
      },
      {
        texte: "Les sens me trompent.",
        bonne: false,
        retour:
          "Le calcul ne passe pas par les sens : l'argument précédent ne l'atteint pas. Il faut en changer.",
      },
    ],
  },
  {
    titre: "Le corps",
    question:
      "Troisième certitude : « j'ai un corps, je suis assis ici, en train d'écrire. » Quel argument l'élimine ?",
    options: [
      {
        texte:
          "Le rêve : il m'est arrivé de rêver que j'étais assis à écrire, et rien dans le rêve ne me prévenait que je rêvais.",
        bonne: true,
        retour:
          "Oui. L'argument est redoutable parce qu'il ne porte pas sur un détail : s'il n'y a aucun signe qui distingue le rêve de la veille, l'existence de mon corps devient douteuse.",
      },
      {
        texte: "Mon corps change avec le temps, donc il n'est pas le même.",
        bonne: false,
        retour: "Cela met en doute son identité, non son existence. Descartes veut plus radical.",
      },
      {
        texte: "L'erreur de calcul.",
        bonne: false,
        retour: "Sans rapport : l'existence de mon corps n'est pas le résultat d'un calcul.",
      },
    ],
  },
  {
    titre: "Les vérités",
    question:
      "Quatrième certitude : « même si je rêve, les vérités de la géométrie restent vraies. » Quel argument reste ?",
    options: [
      {
        texte:
          "L'hypothèse d'un malin génie, assez puissant et assez rusé pour me faire tenir pour évident ce qui est faux.",
        bonne: true,
        retour:
          "Oui, et c'est la pointe du doute. Le malin génie n'est pas une croyance de Descartes : c'est un instrument, forgé pour pousser le doute au-delà de ce que le rêve atteint.",
      },
      {
        texte: "Les vérités mathématiques pourraient changer.",
        bonne: false,
        retour:
          "Affirmation gratuite : rien ne l'appuie. Descartes ne doute jamais sans raison, c'est ce qui distingue son doute du scepticisme.",
      },
      {
        texte: "Je rêve peut-être.",
        bonne: false,
        retour:
          "Le rêve laisse les vérités mathématiques intactes : c'est précisément pourquoi il faut un argument plus fort.",
      },
    ],
  },
  {
    titre: "Ce qui résiste",
    question: "Tout est tombé : les sens, le calcul, le corps, les vérités. Que reste-t-il ?",
    options: [
      {
        texte:
          "Que je doute. Et si je doute, je pense ; et si je pense, je suis. Même trompé, il faut que je sois pour être trompé.",
        bonne: true,
        retour:
          "Oui : le cogito. Et voyez l'élégance — plus le malin génie est puissant, plus il me faut exister pour être sa victime. Le doute se retourne en certitude.",
      },
      {
        texte: "Rien. Le doute est total, il faut s'arrêter là.",
        bonne: false,
        retour:
          "C'est la position du sceptique, et Descartes la refuse. Son doute est méthodique : il doute POUR trouver, pas pour s'installer dans le doute.",
      },
      {
        texte: "Il reste Dieu, qui ne peut pas me tromper.",
        bonne: false,
        retour:
          "Trop tôt : à ce stade, l'existence de Dieu est elle-même en doute, et c'est le cogito qui servira ensuite à l'établir. L'ordre des raisons compte.",
      },
    ],
  },
];

export function DouteCartesien() {
  const [nier, setNier] = useState(false);
  return (
    <div className="space-y-3">
      <Parcours
        consigne="Mène le doute toi-même, dans l'ordre de Descartes. À chaque étape, une certitude et plusieurs arguments : un seul convient, et les autres te disent pourquoi ils ne conviennent pas encore."
        etapes={DOUTE}
        fin={
          <>
            Le chemin que tu viens de parcourir est celui des Méditations métaphysiques : illusion
            des sens, erreur de raisonnement, rêve, malin génie, puis le cogito. Retiens surtout
            l'ordre : chaque argument est plus puissant que le précédent, et c'est pourquoi il faut
            les quatre.
          </>
        }
      />
      <button
        type="button"
        onClick={() => setNier((n) => !n)}
        className="rounded-lg border border-border px-3 py-1.5 text-xs font-medium text-muted-foreground hover:bg-secondary/60"
      >
        {nier ? "Masquer l'épreuve finale" : "Essaie de nier le cogito"}
      </button>
      {nier ? (
        <div className="space-y-2">
          <div className="rounded-lg border border-primary/40 bg-primary/5 p-3 text-xs leading-relaxed">
            <p className="font-semibold text-foreground">« Je n'existe pas. »</p>
            <p className="mt-1 text-muted-foreground">
              Qui vient de l'affirmer ? Pour nier mon existence, il faut que je la nie — donc que je
              pense, donc que je sois. La proposition se détruit en étant énoncée.
            </p>
            <p className="mt-1 text-muted-foreground">
              C'est ce qu'on appelle une <strong>contradiction performative</strong> : non pas une
              phrase fausse, mais une phrase que l'acte de la dire réfute.
            </p>
          </div>
          <Citation auteur="Descartes, Méditations métaphysiques">
            Il faut enfin conclure, et tenir pour constant que cette proposition — je suis, j'existe
            — est nécessairement vraie toutes les fois que je la prononce ou que je la conçois en
            mon esprit.
          </Citation>
          <Verdict tone="warn">
            Une limite à connaître pour l'antithèse : le cogito établit qu'il y a de la pensée, non
            qu'il y a un « moi » substantiel. Nietzsche et Kant ont tous deux reproché à Descartes
            d'avoir ajouté un sujet là où il n'y avait qu'un acte.
          </Verdict>
        </div>
      ) : null}
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* 3. Les deux topiques de Freud                                       */
/* ------------------------------------------------------------------ */

const TOPIQUES: ReadonlyArray<ItemTri> = [
  {
    id: "tp1",
    texte: "Le conscient — ce dont je m'aperçois à l'instant.",
    bonne: "t1",
    pourquoi: "Première topique, qui décrit des LIEUX psychiques selon leur accès à la conscience.",
  },
  {
    id: "tp2",
    texte: "Le préconscient — ce dont je ne m'aperçois pas, mais que je peux rappeler à volonté.",
    bonne: "t1",
    pourquoi:
      "Première topique. C'est la pièce que les copies oublient le plus souvent, et elle est décisive : elle montre que tout ce qui n'est pas conscient n'est pas refoulé.",
  },
  {
    id: "tp3",
    texte: "L'inconscient — ce qui a été refoulé et ne revient pas sur commande.",
    bonne: "t1",
    pourquoi: "Première topique, et son objet propre.",
  },
  {
    id: "tp4",
    texte: "Le ça — le réservoir des pulsions, qui ne connaît que le plaisir.",
    bonne: "t2",
    pourquoi:
      "Seconde topique, qui décrit des INSTANCES selon leur fonction, et non plus des lieux.",
  },
  {
    id: "tp5",
    texte: "Le moi — qui compose avec le réel et arbitre les conflits.",
    bonne: "t2",
    pourquoi: "Seconde topique. Freud dit qu'il est « serviteur de trois maîtres ».",
  },
  {
    id: "tp6",
    texte: "Le surmoi — les interdits intériorisés, qui jugent et punissent.",
    bonne: "t2",
    pourquoi:
      "Seconde topique. Il se forme par intériorisation des interdits parentaux : c'est la version freudienne de la conscience morale.",
  },
];

const INSTANCES: ReadonlyArray<Question> = [
  {
    id: "i1",
    enonce: "Un enfant tend la main vers un fruit qui n'est pas à lui. Quelle instance parle ?",
    options: [
      {
        texte: "Le ça",
        bonne: true,
        retour: "Oui : le désir pur, sans égard pour l'interdit ni pour le réel.",
      },
      {
        texte: "Le moi",
        bonne: false,
        retour: "Le moi n'est pas encore intervenu : rien n'a été arbitré.",
      },
      {
        texte: "Le surmoi",
        bonne: false,
        retour: "Le surmoi interdit ; ici rien n'interdit encore.",
      },
    ],
  },
  {
    id: "i2",
    enonce: "Il croise le regard de sa mère et repose le fruit. Quelle instance a parlé ?",
    options: [
      {
        texte: "Le surmoi",
        bonne: true,
        retour:
          "Oui, et il est en train de se former : l'interdit est encore extérieur — ce regard — et deviendra intérieur.",
      },
      { texte: "Le ça", bonne: false, retour: "Le ça voulait le fruit ; il vient d'être arrêté." },
      {
        texte: "Le préconscient",
        bonne: false,
        retour:
          "Erreur de topique : préconscient appartient à la première, surmoi à la seconde. Ne les mélangez pas dans une même phrase.",
      },
    ],
  },
  {
    id: "i3",
    enonce:
      "Devant son professeur, un élève dit « au revoir madame » à un homme. Que s'est-il passé ?",
    options: [
      {
        texte:
          "Un lapsus : une représentation refoulée a forcé le passage. Pour Freud, rien n'est fortuit dans la vie psychique.",
        bonne: true,
        retour:
          "Oui, et c'est l'argument du quotidien : Freud ne fonde pas l'inconscient sur des cas rares, mais sur les lapsus, les oublis et les rêves de tout le monde.",
      },
      {
        texte: "Rien, c'est une étourderie sans signification.",
        bonne: false,
        retour:
          "C'est l'objection d'Alain, et elle est recevable en antithèse. Mais la question demandait l'explication freudienne.",
      },
    ],
  },
  {
    id: "i4",
    enonce: "Pourquoi la seconde topique ne remplace-t-elle pas la première ?",
    options: [
      {
        texte:
          "Parce qu'elles ne décrivent pas la même chose : la première classe les contenus selon leur accès à la conscience, la seconde classe des instances selon leur fonction. Elles se superposent.",
        bonne: true,
        retour:
          "Exactement. Le moi est en partie conscient et en partie inconscient ; le surmoi aussi. Si l'une remplaçait l'autre, ces phrases n'auraient aucun sens.",
      },
      {
        texte: "Parce que Freud a changé d'avis et préférait la première.",
        bonne: false,
        retour: "Il a élaboré la seconde en 1923 sans abandonner la première. Les deux servent.",
      },
      {
        texte: "Parce que la seconde est fausse.",
        bonne: false,
        retour:
          "Ce n'est pas la question posée. Et si vous voulez contester Freud, il y a mieux : l'objection de Popper sur l'irréfutabilité.",
      },
    ],
  },
  {
    id: "i5",
    enonce:
      "Quelle objection Popper adresse-t-il à la psychanalyse, et pourquoi est-elle la plus forte ?",
    options: [
      {
        texte:
          "Qu'elle n'est pas falsifiable : quoi que fasse le patient, la théorie trouve une explication, et rien ne pourrait la démentir.",
        bonne: true,
        retour:
          "Oui, et c'est l'objection à citer. Elle ne dit pas que Freud a tort : elle dit que sa théorie n'est pas scientifique au sens où une théorie peut être réfutée.",
      },
      {
        texte: "Que l'inconscient n'existe pas.",
        bonne: false,
        retour:
          "Trop brutal, et indémontrable. Popper est plus fin : il attaque la forme de la théorie, pas son objet.",
      },
      {
        texte: "Que Freud était médecin et non philosophe.",
        bonne: false,
        retour:
          "Argument ad hominem : vous attaquez la personne au lieu de la thèse. Cela coûte des points.",
      },
    ],
  },
];

export function TopiquesFreud() {
  return (
    <div className="space-y-4">
      <JeuTri
        consigne="Six éléments, deux topiques. Place chacun dans la bonne — et surtout, ne les mélange jamais dans une même phrase de copie : c'est l'erreur que les correcteurs repèrent immédiatement."
        categories={[
          {
            value: "t1",
            label: "Première topique (1900)",
            aide: "des lieux : conscient, préconscient, inconscient",
          },
          { value: "t2", label: "Seconde topique (1923)", aide: "des instances : ça, moi, surmoi" },
        ]}
        items={TOPIQUES}
        conclusion={
          <>
            La première topique classe les contenus selon leur{" "}
            <strong>accès à la conscience</strong>; la seconde classe des instances selon leur{" "}
            <strong>fonction</strong>. Elles ne se remplacent pas : elles se superposent, et c'est
            pour cela que le moi peut être en partie inconscient.
          </>
        }
      />
      <div className="border-t border-border pt-3">
        <p className="mb-2 text-xs font-semibold text-foreground">Second volet — qui a parlé ?</p>
        <Qcm
          consigne="Cinq conduites et questions. Dis quelle instance agit, puis affronte les deux objections au programme."
          questions={INSTANCES}
          conclusion={
            <>
              Pour l'antithèse, deux objections valent mieux que dix : <strong>Alain</strong>, pour
              qui l'inconscient est une mythologie qui nous déresponsabilise, et{" "}
              <strong>Popper</strong>, pour qui une théorie que rien ne peut démentir sort de la
              science. <strong>Sartre</strong> ajoute la plus mordante : l'inconscient serait une
              mauvaise foi commode, puisqu'il permet de ne jamais répondre de soi.
            </>
          }
        />
      </div>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* 4. Connaître autrui : les trois voies et leur limite                */
/* ------------------------------------------------------------------ */

const AUTRUI: ReadonlyArray<Question> = [
  {
    id: "au1",
    enonce:
      "Un camarade entre dans la classe en silence et s'assoit au fond. Que fais-tu de ce signe ?",
    options: [
      {
        texte:
          "Je sens tout de suite qu'il va mal — je n'ai besoin d'aucun raisonnement pour cela.",
        bonne: true,
        retour:
          "C'est la voie de l'INTUITION, défendue par Bergson : une saisie immédiate, sans détour par le calcul. Elle est rapide, et elle est parfois juste.",
      },
      {
        texte: "Je ne peux rien en dire, les autres sont des énigmes closes.",
        bonne: false,
        retour:
          "C'est la position la plus extrême, et elle est intenable : nous vivons en société, donc nous nous comprenons un peu. Reste à savoir comment.",
      },
    ],
  },
  {
    id: "au2",
    enonce:
      "Il reste silencieux tout le cours. Tu raisonnes : « quand je me tais ainsi, c'est que j'ai de la peine ; donc il a de la peine. » Quelle voie ?",
    options: [
      {
        texte: "L'analogie : je transporte en lui ce que je sais de moi.",
        bonne: true,
        retour:
          "Oui, et c'est la voie que décrit Malebranche. Elle est raisonnée, communicable, et elle porte en elle sa propre faiblesse.",
      },
      {
        texte: "Le dialogue.",
        bonne: false,
        retour: "Tu ne lui as rien demandé : tu as raisonné seul, à partir de toi.",
      },
      {
        texte: "L'intuition.",
        bonne: false,
        retour:
          "Non : il y a un raisonnement explicite, avec une prémisse sur toi et une conclusion sur lui. L'intuition ne passe pas par là.",
      },
    ],
  },
  {
    id: "au3",
    enonce:
      "Tu apprends qu'il se taisait parce qu'il préparait une surprise. Qu'est-ce que l'analogie a manqué ?",
    options: [
      {
        texte:
          "Elle suppose qu'autrui soit comme moi. Dès qu'il diffère, elle le manque — et elle le manque d'autant plus sûrement qu'elle semble marcher.",
        bonne: true,
        retour:
          "Exactement, et c'est là que tout le chapitre se joue. L'analogie ne me fait pas connaître autrui : elle me renvoie mon propre portrait sous son nom.",
      },
      {
        texte: "Rien : elle était juste, c'est lui qui est bizarre.",
        bonne: false,
        retour:
          "C'est le réflexe à éviter. Juger autrui bizarre parce qu'il ne me ressemble pas, c'est se prendre pour la mesure de l'humanité.",
      },
      {
        texte: "Elle a manqué de preuves.",
        bonne: false,
        retour:
          "Le problème n'est pas la quantité d'indices : c'est le principe même du transfert de moi à lui.",
      },
    ],
  },
  {
    id: "au4",
    enonce: "Que reste-t-il alors comme voie d'accès ?",
    options: [
      {
        texte:
          "Le dialogue : lui demander. C'est la seule voie où autrui intervient en personne au lieu d'être deviné.",
        bonne: true,
        retour:
          "Oui. Merleau-Ponty insiste : autrui n'est pas un objet derrière son corps, il se donne dans sa conduite et dans sa parole. Et Gabriel Marcel parle d'une relation de « je » à « tu », non de « je » à « il ».",
      },
      {
        texte: "L'introspection, mieux conduite.",
        bonne: false,
        retour:
          "Mieux m'observer moi-même ne m'apprendra jamais rien de ce qu'il a de différent de moi.",
      },
    ],
  },
  {
    id: "au5",
    enonce: "Sartre soutient pourtant que même le dialogue ne suffit pas. Quel est son argument ?",
    options: [
      {
        texte:
          "Que le regard d'autrui me fige en objet : sous son regard, je deviens ce qu'il voit, et je perds la liberté de me définir moi-même.",
        bonne: true,
        retour:
          "Oui : « l'enfer, c'est les autres », dans Huis clos, ne veut pas dire que les autres sont méchants, mais qu'ils me donnent un dehors que je ne contrôle pas.",
      },
      {
        texte: "Que les mots sont trop imprécis.",
        bonne: false,
        retour:
          "Ce serait un problème de langage. L'objection de Sartre est ontologique : elle porte sur ce que le regard fait à mon être.",
      },
      {
        texte: "Que personne ne dit la vérité.",
        bonne: false,
        retour: "Trop faible, et ce n'est pas de la philosophie : c'est de la défiance.",
      },
    ],
  },
  {
    id: "au6",
    enonce: "Hegel donne pourtant au regard d'autrui un rôle positif. Lequel ?",
    options: [
      {
        texte:
          "La reconnaissance : je n'ai conscience de ma propre valeur que si un autre me la reconnaît. Autrui n'est pas seulement une menace, il est la condition de ma conscience de moi.",
        bonne: true,
        retour:
          "Oui, et c'est le matériau de la synthèse : le même regard qui me fige chez Sartre me constitue chez Hegel. Tout dépend de ce qu'on en fait.",
      },
      {
        texte: "Il surveille ma conduite et m'empêche de mal agir.",
        bonne: false,
        retour:
          "C'est un rôle moral et extérieur. Hegel dit beaucoup plus : sans autrui, je n'aurais pas même conscience de moi.",
      },
    ],
  },
];

export function ConnaitreAutrui() {
  return (
    <Qcm
      consigne="Un camarade entre en silence. Tu formules des hypothèses, la simulation nomme la voie que tu as employée, puis te montre ce qu'il pensait réellement. Elle te met enfin devant quelqu'un qui ne réagit pas comme toi : c'est là que tout le chapitre se joue."
      questions={AUTRUI}
      conclusion={
        <>
          Les trois voies, avec leur force et leur faille. L'<strong>intuition</strong> est rapide
          et inverifiable. L'<strong>analogie</strong> est raisonnée mais me renvoie mon propre
          portrait. Le <strong>dialogue</strong> est la seule voie où autrui parle, et il reste
          exposé au mensonge et au malentendu. Aucune ne donne une connaissance certaine : autrui
          n'est pas un objet qu'on connaît, c'est quelqu'un qu'on rencontre — et c'est pourquoi
          Gabriel Marcel distingue le « tu » du « il ».
        </>
      }
    />
  );
}

/* ------------------------------------------------------------------ */
/* 5. L'état de nature : Hobbes ou Rousseau ?                          */
/* ------------------------------------------------------------------ */

export function EtatDeNature() {
  const [vivres, setVivres] = useState(70);
  const [densite, setDensite] = useState(30);
  const [autorite, setAutorite] = useState<"non" | "faible" | "forte">("non");

  const rarete = 100 - vivres;
  const pressionAutorite = autorite === "forte" ? 45 : autorite === "faible" ? 20 : 0;

  // conflit : la rareté et la promiscuité le nourrissent, l'autorité le contient
  const conflit = Math.round(
    Math.max(0, Math.min(100, rarete * 0.55 + densite * 0.45 - pressionAutorite)),
  );
  const cooperation = Math.round(Math.max(0, Math.min(100, 100 - conflit * 0.85)));
  const liberte = Math.round(
    Math.max(0, Math.min(100, 95 - pressionAutorite * 1.5 - conflit * 0.35)),
  );

  const camp = conflit >= 55 ? "hobbes" : conflit <= 30 ? "rousseau" : "entre";

  return (
    <div className="space-y-3">
      <p className="text-sm text-muted-foreground">
        Une île, quelques naufragés. Règle les ressources, la promiscuité et la présence d'une
        autorité, et regarde le groupe basculer. Les deux philosophes ne décrivent peut-être pas
        deux natures humaines, mais deux situations.
      </p>

      <div className="grid gap-3 sm:grid-cols-2">
        <Ctrl
          label="Abondance des vivres"
          value={vivres}
          min={0}
          max={100}
          step={5}
          onChange={setVivres}
          display={`${vivres} %`}
          color={PALETTE.green}
        />
        <Ctrl
          label="Promiscuité (naufragés sur peu d'espace)"
          value={densite}
          min={0}
          max={100}
          step={5}
          onChange={setDensite}
          display={`${densite} %`}
          color={PALETTE.orange}
        />
      </div>
      <Choice<"non" | "faible" | "forte">
        label="Une autorité commune ?"
        value={autorite}
        options={[
          { value: "non", label: "aucune" },
          { value: "faible", label: "un conseil sans force" },
          { value: "forte", label: "un souverain armé" },
        ]}
        onChange={setAutorite}
      />

      <Jauges
        jauges={[
          { label: "Conflits", valeur: conflit, couleur: PALETTE.red },
          { label: "Coopération spontanée", valeur: cooperation, couleur: PALETTE.green },
          { label: "Liberté effective de chacun", valeur: liberte, couleur: PALETTE.blue },
        ]}
      />

      <div className="grid grid-cols-2 gap-2 sm:grid-cols-3">
        <Stat label="Rareté" value={`${rarete} %`} color={PALETTE.orange} />
        <Stat
          label="Autorité"
          value={autorite === "non" ? "aucune" : autorite === "faible" ? "faible" : "forte"}
          color={PALETTE.purple}
        />
        <Stat
          label="Qui a raison ici"
          value={camp === "hobbes" ? "Hobbes" : camp === "rousseau" ? "Rousseau" : "les deux"}
          color={
            camp === "hobbes" ? PALETTE.red : camp === "rousseau" ? PALETTE.green : PALETTE.slate
          }
        />
      </div>

      {camp === "hobbes" ? (
        <Verdict tone="bad">
          Guerre de tous contre tous. Avec une seule source d'eau et trop de monde autour,{" "}
          <strong>Hobbes</strong> a raison : chacun ayant droit à tout, la vie devient « solitaire,
          misérable, dangereuse, animale et brève ». Remarque ce que fait le souverain armé : il
          fait tomber les conflits et il fait tomber la liberté avec eux. C'est exactement le marché
          du Léviathan.
        </Verdict>
      ) : camp === "rousseau" ? (
        <Verdict tone="ok">
          Avec des vivres en abondance et de l'espace, <strong>Rousseau</strong> a raison : les
          naufragés s'évitent, s'aident à l'occasion, et nul n'a de raison d'attaquer. L'homme n'est
          pas mauvais ici — et pourtant c'est le même homme que tout à l'heure.
        </Verdict>
      ) : (
        <Verdict tone="warn">
          Zone intermédiaire : les deux descriptions tiennent à la fois, et c'est le point le plus
          intéressant du réglage. Pousse un seul curseur et tu feras basculer le groupe dans un camp
          ou dans l'autre — sans avoir changé la nature de personne.
        </Verdict>
      )}

      <Citation auteur="pour la synthèse">
        Ni Hobbes ni Rousseau n'a observé un état de nature : tous deux construisent une hypothèse
        pour fonder une politique. Hobbes, qui a vécu la guerre civile anglaise, craint le désordre.
        Rousseau, qui voit la société de son temps, craint la corruption. Chacun bâtit l'homme dont
        sa politique a besoin — et c'est ce renversement qui fait une bonne troisième partie.
      </Citation>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* 6. L'impératif catégorique à l'épreuve                              */
/* ------------------------------------------------------------------ */

type Maxime = {
  id: string;
  texte: string;
  universel: string;
  survit: boolean;
  verdict: string;
  utilitaire: string;
};

const MAXIMES: ReadonlyArray<Maxime> = [
  {
    id: "m1",
    texte: "« Je peux mentir quand cela m'arrange. »",
    universel:
      "Tout le monde mentirait dès que cela l'arrange. Plus personne ne croirait personne. Il n'y aurait plus de parole à laquelle se fier — donc plus de mensonge possible, puisque mentir suppose qu'on soit cru.",
    survit: false,
    verdict:
      "La maxime se détruit en s'universalisant. Elle n'a pas besoin d'être condamnée du dehors : elle supprime la condition de son propre succès.",
    utilitaire:
      "Le calcul des conséquences donnerait parfois le même résultat, parfois l'inverse : un mensonge discret qui ne nuit à personne passerait le test utilitariste, et échoue au test kantien.",
  },
  {
    id: "m2",
    texte: "« Je peux emprunter en promettant de rendre, sans avoir l'intention de rendre. »",
    universel:
      "Tout le monde promettrait sans intention de tenir. Plus personne ne prêterait. La promesse elle-même perdrait son sens.",
    survit: false,
    verdict:
      "C'est l'exemple de Kant lui-même, dans les Fondements de la métaphysique des mœurs. La fausse promesse universalisée abolit la promesse.",
    utilitaire:
      "L'utilitariste objecterait : et si l'emprunt sauvait une vie et que le prêteur est riche ? Kant répond que l'acte serait alors bon par ses suites, non par son principe — et qu'on ne peut pas fonder une morale sur des suites qu'on ne maîtrise pas.",
  },
  {
    id: "m3",
    texte: "« Je peux tricher à l'examen si personne ne voit. »",
    universel:
      "Tout le monde tricherait quand personne ne voit. Les notes ne mesureraient plus rien, les diplômes ne vaudraient plus rien, et tricher n'aurait plus d'intérêt.",
    survit: false,
    verdict:
      "Même mécanisme : la maxime a besoin que les autres jouent honnêtement. Elle se nourrit de ce qu'elle détruit, et c'est à cela qu'on reconnaît une injustice.",
    utilitaire:
      "Le calcul utilitariste hésite : un tricheur isolé ne nuit presque à personne. C'est pourquoi le test kantien est plus sûr — il juge le principe, pas le cas.",
  },
  {
    id: "m4",
    texte: "« Je peux tenir mes promesses. »",
    universel:
      "Tout le monde tiendrait ses promesses. La promesse en sortirait renforcée, et rien ne s'effondrerait.",
    survit: true,
    verdict:
      "La maxime survit : elle peut être voulue comme loi universelle. C'est ce que signifie « agis de telle sorte que la maxime de ton action puisse être érigée en loi universelle ».",
    utilitaire:
      "Les deux morales se rejoignent ici, et c'est le cas facile. Les désaccords commencent dès que les conséquences et le principe divergent.",
  },
  {
    id: "m5",
    texte: "« Je peux ne jamais aider personne. »",
    universel:
      "Personne n'aiderait personne. Le monde tiendrait — logiquement, rien ne s'effondre — mais je ne peux pas vouloir y vivre, car j'aurai moi-même besoin d'aide.",
    survit: false,
    verdict:
      "Cas plus subtil, et Kant le distingue : ici la maxime n'est pas contradictoire, elle est seulement impossible à vouloir. Kant appelle les premiers des devoirs stricts et ceux-ci des devoirs larges.",
    utilitaire:
      "L'utilitarisme condamne sans hésiter : le total de souffrance augmenterait. Les deux morales concordent, par des chemins différents.",
  },
  {
    id: "m6",
    texte: "« Je peux mentir à un assassin qui me demande où se cache sa victime. »",
    universel:
      "Tout le monde mentirait aux assassins. La parole resterait fiable entre honnêtes gens — mais Kant, lui, répond que le devoir de vérité ne souffre aucune exception, car dès qu'on en admet une, chacun décidera des siennes.",
    survit: false,
    verdict:
      "Le cas célèbre, et il est embarrassant. Kant maintient l'interdiction du mensonge et affirme qu'on n'est pas responsable des suites quand on a dit le vrai.",
    utilitaire:
      "C'est ici que Benjamin Constant a objecté à Kant, et presque tout le monde lui donne raison : une morale qui livre un innocent pour sauver un principe s'est trompée de principe quelque part.",
  },
];

const MAXIME_VIDE: Maxime = {
  id: "",
  texte: "—",
  universel: "—",
  survit: false,
  verdict: "—",
  utilitaire: "—",
};

export function ImperatifCategorique() {
  const [rang, setRang] = useState(0);
  const [etape, setEtape] = useState<0 | 1 | 2>(0);

  const m = MAXIMES[rang] ?? MAXIME_VIDE;

  return (
    <div className="space-y-3">
      <p className="text-sm text-muted-foreground">
        Choisis une maxime, puis universalise-la : la simulation fait agir tout le monde ainsi et te
        montre si la règle survit ou se détruit. Un second temps oppose le calcul des conséquences
        au test kantien sur le même cas.
      </p>

      <div className="flex flex-wrap gap-1.5">
        {MAXIMES.map((x, i) => (
          <button
            key={x.id}
            type="button"
            onClick={() => {
              setRang(i);
              setEtape(0);
            }}
            className={
              i === rang
                ? "rounded-lg bg-primary px-2.5 py-1 text-[11px] font-semibold text-primary-foreground"
                : "rounded-lg border border-border px-2.5 py-1 text-[11px] text-muted-foreground hover:bg-secondary/60"
            }
          >
            Maxime {i + 1}
          </button>
        ))}
      </div>

      <div className="rounded-lg border border-border bg-background p-3">
        <p className="text-sm font-medium leading-snug text-foreground">{m.texte}</p>

        {etape === 0 ? (
          <button
            type="button"
            onClick={() => setEtape(1)}
            className="mt-3 rounded-lg bg-primary px-3 py-1.5 text-xs font-semibold text-primary-foreground"
          >
            Universaliser : et si tout le monde faisait ainsi ?
          </button>
        ) : (
          <div className="mt-3 space-y-2">
            <p className="rounded-lg bg-secondary/40 px-2.5 py-2 text-xs leading-relaxed text-muted-foreground">
              {m.universel}
            </p>
            <Verdict tone={m.survit ? "ok" : "bad"}>
              {m.survit ? "La maxime survit. " : "La maxime se détruit. "}
              {m.verdict}
            </Verdict>
            {etape === 1 ? (
              <button
                type="button"
                onClick={() => setEtape(2)}
                className="rounded-lg border border-border px-3 py-1.5 text-xs font-medium text-muted-foreground hover:bg-secondary/60"
              >
                Et que dirait le calcul des conséquences ?
              </button>
            ) : (
              <div className="rounded-lg border border-primary/40 bg-primary/5 p-2.5">
                <p className="text-[11px] font-semibold uppercase tracking-wide text-muted-foreground">
                  Le test utilitariste
                </p>
                <p className="mt-1 text-xs leading-relaxed text-foreground">{m.utilitaire}</p>
              </div>
            )}
          </div>
        )}
      </div>

      <Citation auteur="Kant, Fondements de la métaphysique des mœurs">
        Agis de telle sorte que la maxime de ton action puisse être érigée en loi universelle de la
        nature.
      </Citation>
      <p className="text-[11px] leading-snug text-muted-foreground">
        Pour l'antithèse, garde la maxime 6 en réserve : <strong>Benjamin Constant</strong> a
        objecté à Kant qu'on ne peut pas livrer un innocent au nom de la véracité, et Kant a répondu
        par écrit en maintenant sa position. C'est l'un des rares endroits où un grand philosophe
        paraît avoir tort à presque tout le monde — et c'est un excellent matériau de copie.
      </p>
    </div>
  );
}
