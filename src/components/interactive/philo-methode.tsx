import { useState } from "react";
import { Ctrl, PALETTE, Stat, Verdict } from "./controls";
import {
  Citation,
  JeuTri,
  Qcm,
  RepartirPoints,
  type ItemTri,
  type Poste,
  type Question,
} from "./philo-noyau";

/** Philosophie Terminale C et D — chapitres 2 et 3 : la méthodologie de l'épreuve. */

/* ------------------------------------------------------------------ */
/* 1. Le barème de l'épreuve, et le temps                              */
/* ------------------------------------------------------------------ */

const POSTES: ReadonlyArray<Poste> = [
  {
    id: "p1",
    label: "Partie I · A1 — définir trois concepts du texte",
    points: 3,
    aide: "Un point par concept. Genre prochain plus différence spécifique : trois lignes bien faites valent trois points sûrs.",
  },
  {
    id: "p2",
    label: "Partie I · A2 — thème et problème philosophique",
    points: 2,
    aide: "Le thème est un groupe nominal, le problème une difficulté. Les confondre coûte les deux points.",
  },
  {
    id: "p3",
    label: "Partie I · A2 — thèse de l'auteur",
    points: 1,
    aide: "Une phrase, attribuée à l'auteur, et qu'on puisse contredire. Si personne ne peut s'y opposer, ce n'est pas une thèse.",
  },
  {
    id: "p4",
    label: "Partie I · A2 — structure logique du texte",
    points: 3,
    aide: "Rédigée en un seul paragraphe, avec des verbes de mouvement : il part de, il établit, il poursuit, il conclut. La répartition interne varie selon les sessions, 2+1+3 ou 2+2+2.",
  },
  {
    id: "p5",
    label: "Partie II — la thèse",
    points: 3,
    aide: "Trois arguments appuyés sur des auteurs, pas trois reformulations du même.",
  },
  {
    id: "p6",
    label: "Partie II — l'antithèse",
    points: 3,
    aide: "La position adverse sous sa forme la plus forte. Une antithèse faible fait perdre les points de la synthèse avec elle.",
  },
  {
    id: "p7",
    label: "Partie II — la synthèse",
    points: 3,
    aide: "C'est elle qui est le plus souvent sacrifiée faute de temps, et c'est elle qui sépare 5 de 8.",
  },
  {
    id: "p8",
    label: "Présentation — respect de la structure demandée",
    points: 1,
    aide: "Un point gratuit : les parties annoncées, séparées, dans l'ordre.",
  },
  {
    id: "p9",
    label: "Présentation — aspect général de la copie",
    points: 1,
    aide: "Second point gratuit : écriture lisible, pas de ratures, marges respectées.",
  },
];

export function BaremeEpreuve() {
  const [minDisser, setMinDisser] = useState(100);
  const total = 240;
  const minTexte = Math.max(0, total - minDisser - 20);

  // les 9 points de chaque partie se gagnent d'autant mieux qu'on a le temps
  const idealTexte = 100;
  const idealDisser = 110;
  const noteTexte = Math.round(9 * Math.min(1, minTexte / idealTexte) ** 0.7);
  const noteDisser = Math.round(9 * Math.min(1, minDisser / idealDisser) ** 0.7);
  const presentation = minTexte > 10 && minDisser > 20 ? 2 : 1;
  const note = noteTexte + noteDisser + presentation;

  return (
    <div className="space-y-4">
      <RepartirPoints
        consigne="Voici les neuf postes de l'épreuve de Philosophie des séries C et D. Attribue à chacun le nombre de points que tu crois être le sien, puis compare au barème officiel. Le total doit faire 20."
        postes={POSTES}
        total={20}
      />

      <div className="space-y-3 border-t border-border pt-3">
        <p className="text-xs font-semibold text-foreground">
          Second volet — quatre heures, et comment les dépenser
        </p>
        <p className="text-xs leading-snug text-muted-foreground">
          L'épreuve dure 240 minutes. Compte 20 minutes de relecture, non négociables. Fais glisser
          le temps consacré à la dissertation et regarde la note totale se recalculer : les deux
          parties valent 9 points chacune, donc sacrifier l'une pour soigner l'autre ne rapporte
          jamais.
        </p>
        <Ctrl
          label="Temps passé sur la dissertation (partie II)"
          value={minDisser}
          min={20}
          max={220}
          step={5}
          onChange={setMinDisser}
          display={`${minDisser} min`}
          color={PALETTE.purple}
        />
        <div className="grid grid-cols-2 gap-2 sm:grid-cols-4">
          <Stat label="Texte (partie I)" value={`${minTexte} min`} color={PALETTE.blue} />
          <Stat label="Relecture" value="20 min" color={PALETTE.slate} />
          <Stat label="Partie I" value={`${noteTexte} / 9`} color={PALETTE.blue} />
          <Stat label="Partie II" value={`${noteDisser} / 9`} color={PALETTE.purple} />
        </div>
        <Verdict tone={note >= 16 ? "ok" : note >= 11 ? "warn" : "bad"}>
          Note estimée : {note} / 20 (présentation : {presentation} / 2).{" "}
          {minDisser > 150
            ? "Trop de temps sur la dissertation : la partie I est bâclée et tu perds plus que tu ne gagnes."
            : minDisser < 70
              ? "La dissertation n'a pas eu le temps d'avoir une synthèse, et c'est là que les points partent."
              : "Répartition raisonnable : un peu moins de deux heures par partie, vingt minutes de relecture."}
        </Verdict>
        <Citation auteur="à retenir">
          Les deux parties pèsent exactement le même poids. Un candidat qui « adore la dissertation
          » et néglige le texte plafonne à 11 sur 20 quoi qu'il écrive.
        </Citation>
      </div>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* 2. Analyser un sujet en six cases                                   */
/* ------------------------------------------------------------------ */

const ANALYSE: ReadonlyArray<Question> = [
  {
    id: "s1",
    enonce:
      "Sujet : « Est-il légitime de penser que la raison du plus fort est toujours la meilleure ? » — Case 1 : les concepts-clés.",
    precision: "On attend les mots qu'il faut définir pour que le sujet devienne clair.",
    options: [
      {
        texte: "raison, le plus fort, la meilleure",
        bonne: true,
        retour:
          "Oui, et surtout « la meilleure », qui est ambigu : la plus efficace ou la plus juste ? C'est de cette ambiguïté que naît le sujet.",
      },
      {
        texte: "légitime, penser, toujours",
        bonne: false,
        retour:
          "Ce sont les mots de la formule rituelle du libellé, présente dans tous les sujets. Ils n'appartiennent pas au problème.",
      },
      {
        texte: "le droit, la force, la justice",
        bonne: false,
        retour:
          "Ce sont les notions du chapitre, pas les concepts du sujet. On définit les mots qui sont écrits, pas ceux qu'on a révisés.",
      },
    ],
  },
  {
    id: "s2",
    enonce: "Même sujet — Case 2 : la reformulation.",
    precision: "On redit le sujet avec ses propres mots, sans le trancher.",
    options: [
      {
        texte: "A-t-on de bonnes raisons de soutenir que la puissance suffit à fonder le droit ?",
        bonne: true,
        retour:
          "Oui : le sens est conservé, les mots ont changé, et la question reste ouverte. C'est tout ce qu'on demande.",
      },
      {
        texte: "La force ne fonde pas le droit, comme Rousseau l'a montré.",
        bonne: false,
        retour:
          "Tu as répondu au lieu de reformuler. La reformulation vient avant la réflexion, et elle ne doit rien décider.",
      },
      {
        texte: "Il s'agit du rapport entre le droit et la force.",
        bonne: false,
        retour: "C'est le thème, pas une reformulation. Une reformulation reste une question.",
      },
    ],
  },
  {
    id: "s3",
    enonce: "Même sujet — Case 3 : le présupposé.",
    precision: "Ce que le sujet tient pour acquis sans le dire.",
    options: [
      {
        texte:
          "Que la force puisse produire autre chose qu'une contrainte, à savoir une obligation.",
        bonne: true,
        retour:
          "Exactement. Et c'est ce présupposé que Rousseau attaque : céder n'est pas obéir. Repérer le présupposé, c'est déjà avoir son antithèse.",
      },
      {
        texte: "Que le plus fort existe.",
        bonne: false,
        retour:
          "Trop faible : personne ne le contesterait, donc cela ne fait pas travailler le sujet.",
      },
      {
        texte: "Que la raison du plus fort n'est pas la meilleure.",
        bonne: false,
        retour:
          "C'est la thèse opposée, pas le présupposé. Les deux cases sont voisines et différentes : le présupposé est ce que le sujet admet, la thèse opposée est ce qu'il nie.",
      },
    ],
  },
  {
    id: "s4",
    enonce: "Même sujet — Case 5 : le problème philosophique.",
    precision: "Attention au piège : le problème n'est pas le thème.",
    options: [
      {
        texte: "Le fondement du droit.",
        bonne: true,
        retour:
          "Oui. Un problème se dit en un groupe nominal court, et il nomme la difficulté, non le domaine.",
      },
      {
        texte: "La force et le droit.",
        bonne: false,
        retour:
          "C'est le thème : deux notions juxtaposées, sans difficulté énoncée. C'est l'erreur la plus fréquente de toute l'épreuve.",
      },
      {
        texte: "Rousseau a-t-il raison contre Thrasymaque ?",
        bonne: false,
        retour:
          "C'est une question d'histoire de la philosophie. Le problème est impersonnel : il tiendrait même si ces auteurs n'avaient pas existé.",
      },
    ],
  },
  {
    id: "s5",
    enonce: "Même sujet — Case 6 : la problématique.",
    precision: "Une question, et qui porte une tension.",
    options: [
      {
        texte:
          "Le droit n'est-il que la mise en forme d'un rapport de forces, ou suppose-t-il un principe que la force ne peut pas produire ?",
        bonne: true,
        retour:
          "Oui : deux branches, et chacune est défendable. C'est ce « ou bien » qui fait qu'il y aura quelque chose à écrire.",
      },
      {
        texte: "Qu'est-ce que le droit du plus fort ?",
        bonne: false,
        retour:
          "Une problématique sans tension : on y répond par une définition, et la copie s'arrête à la première page.",
      },
      {
        texte: "Pourquoi la force ne fonde-t-elle pas le droit ?",
        bonne: false,
        retour:
          "La réponse est déjà dans la question : tu as supprimé l'une des deux branches, donc l'antithèse.",
      },
    ],
  },
  {
    id: "s6",
    enonce:
      "Nouveau sujet : « Est-il légitime de penser que l'État est un mal nécessaire ? » — Quel est son présupposé ?",
    options: [
      {
        texte: "Que l'État est un mal ; le sujet ne discute que sa nécessité.",
        bonne: true,
        retour:
          "Oui, et c'est tout l'intérêt du sujet. Une bonne copie commence par contester ce qui lui a été accordé d'avance.",
      },
      {
        texte: "Que l'État existe.",
        bonne: false,
        retour: "Personne ne le conteste : un présupposé doit être discutable pour servir.",
      },
      {
        texte: "Que l'État est nécessaire.",
        bonne: false,
        retour:
          "Non : c'est justement ce que le sujet demande d'examiner. Le présupposé est ce qu'il ne demande pas.",
      },
    ],
  },
  {
    id: "s7",
    enonce:
      "Sujet : « Est-il légitime de penser que l'unité africaine est la condition du développement du continent ? » — Quel est le problème ?",
    options: [
      {
        texte: "Les conditions du développement de l'Afrique.",
        bonne: true,
        retour:
          "Oui. Et la bonne problématique sortira du mot « condition » : nécessaire, ou suffisante ?",
      },
      {
        texte: "Le panafricanisme.",
        bonne: false,
        retour:
          "C'est le thème, et même seulement l'une de ses notions. Aucune difficulté n'est énoncée.",
      },
      {
        texte: "L'Afrique doit-elle s'unir ?",
        bonne: false,
        retour:
          "C'est une problématique possible, pas un problème. Le problème se dit en un groupe nominal.",
      },
    ],
  },
  {
    id: "s8",
    enonce:
      "Sujet : « Est-il légitime de penser que la science peut tout connaître ? » — Quelle est la meilleure problématique ?",
    options: [
      {
        texte:
          "Les limites que la science rencontre ne sont-elles que provisoires, ou tiennent-elles à la nature même de sa méthode ?",
        bonne: true,
        retour:
          "Oui, et cette problématique commande déjà la synthèse : il y a des limites de fait, qui se déplacent, et des limites de domaine, qui ne se déplacent pas.",
      },
      {
        texte: "La science est-elle dangereuse ?",
        bonne: false,
        retour:
          "Hors sujet : le libellé demande ce que la science PEUT connaître, pas ce qu'elle DOIT faire. Hiroshima et le clonage serviront en synthèse, pas en thèse.",
      },
      {
        texte: "Quelles sont les limites de la science ?",
        bonne: false,
        retour:
          "Pas de tension : c'est une invitation à faire une liste, et une liste n'est pas une dissertation.",
      },
    ],
  },
];

export function AnalyserSujet() {
  return (
    <Qcm
      consigne="Huit cases à remplir sur quatre sujets de sessions récentes. Les mauvaises réponses sont les erreurs réellement commises dans les copies : le thème à la place du problème, une problématique sans tension, un présupposé que personne ne contesterait."
      questions={ANALYSE}
      conclusion={
        <>
          Les six cases dans l'ordre : concepts-clés, reformulation, présupposé, thèse opposée,
          problème, problématique. Fais-les au brouillon, toujours, et dans cet ordre : chacune
          prépare la suivante, et la problématique tombe presque d'elle-même quand les cinq
          premières sont remplies. Compte dix minutes. Elles valent les trois points de la synthèse.
        </>
      }
    />
  );
}

/* ------------------------------------------------------------------ */
/* 3. Construire le plan                                               */
/* ------------------------------------------------------------------ */

const ARGUMENTS_PLAN: ReadonlyArray<ItemTri> = [
  {
    id: "g1",
    texte: "Spinoza lie le droit naturel à la puissance : chacun a droit à ce qu'il peut.",
    bonne: "these",
    pourquoi: "Appui savant de la thèse du droit du plus fort.",
  },
  {
    id: "g2",
    texte: "Thrasymaque, dans La République : le juste est partout ce qui profite au plus fort.",
    bonne: "these",
    pourquoi: "Même camp, et l'argument est tiré des faits.",
  },
  {
    id: "g3",
    texte: "Marx : le droit positif organise en lois l'oppression d'une classe par une autre.",
    bonne: "these",
    pourquoi: "Troisième argument de la thèse : le droit sert les puissants.",
  },
  {
    id: "g4",
    texte:
      "Rousseau : céder à la force est un acte de nécessité, non de volonté ; une obligation qui disparaît avec la force n'en est pas une.",
    bonne: "antithese",
    pourquoi:
      "L'argument décisif de l'antithèse, et il est logique, non moral : l'expression « droit du plus fort » est contradictoire.",
  },
  {
    id: "g5",
    texte:
      "Montesquieu : la loi est la raison humaine en tant qu'elle gouverne tous les peuples de la terre.",
    bonne: "antithese",
    pourquoi: "Le droit se fonde sur la raison, qui est universelle.",
  },
  {
    id: "g6",
    texte: "Rousseau : l'obéissance à la loi qu'on s'est prescrite est liberté.",
    bonne: "antithese",
    pourquoi: "Le droit se fonde sur un contrat, non sur la contrainte.",
  },
  {
    id: "g7",
    texte:
      "Les deux thèses ne parlent pas de la même chose : l'une de l'origine historique des lois, l'autre de la condition de leur validité.",
    bonne: "synthese",
    pourquoi:
      "Le geste propre de la synthèse : montrer que l'opposition reposait sur un glissement.",
  },
  {
    id: "g8",
    texte:
      "Le droit a besoin de la force pour être appliqué, non pour être fondé : Weber définit l'État par le monopole de la violence LÉGITIME.",
    bonne: "synthese",
    pourquoi: "On attribue à la force son rôle exact, au lieu de l'exclure ou de tout lui donner.",
  },
  {
    id: "g9",
    texte:
      "« La meilleure » est ambigu : la raison du plus fort est souvent la plus efficace, jamais la plus juste.",
    bonne: "synthese",
    pourquoi:
      "La synthèse revient sur l'ambiguïté repérée à l'analyse du sujet. C'est ce retour qui fait les bonnes copies.",
  },
  {
    id: "g10",
    texte: "La force ne fonde pas le droit.",
    bonne: "hors",
    pourquoi:
      "Ce n'est pas un argument, c'est la conclusion de l'antithèse. Une affirmation sans raison ne se place nulle part.",
  },
  {
    id: "g11",
    texte: "Il est évident que le plus fort a toujours tort.",
    bonne: "hors",
    pourquoi:
      "« Il est évident » n'est pas un argument, et l'affirmation est trop générale pour être défendue.",
  },
  {
    id: "g12",
    texte:
      "La Fontaine : « la raison du plus fort est toujours la meilleure » — c'est le libellé lui-même.",
    bonne: "hors",
    pourquoi:
      "Citer le sujet n'est pas argumenter. En revanche, nommer sa source en introduction est bienvenu : la formule vient du Loup et l'Agneau.",
  },
];

const FORME_SUJET: ReadonlyArray<Question> = [
  {
    id: "f1",
    enonce: "Sujet : « Est-il légitime de penser que l'État est un mal nécessaire ? » Quel plan ?",
    options: [
      {
        texte: "Thèse — antithèse — synthèse",
        bonne: true,
        retour:
          "Oui : c'est un sujet-question, donc le plan en trois tâches de la deuxième partie de l'épreuve.",
      },
      {
        texte: "Explication de la pensée — limites — réinterprétation",
        bonne: false,
        retour:
          "Ce plan est réservé aux sujets-citation, qui citent un auteur. Ici aucun auteur n'est cité.",
      },
    ],
  },
  {
    id: "f2",
    enonce:
      "Sujet : « En te fondant sur ta culture philosophique, apprécie cette pensée de Rousseau : “céder à la force est un acte de nécessité, non de volonté.” »",
    options: [
      {
        texte: "I. Explication et commentaire de la pensée — II. Limites — III. Réinterprétation",
        bonne: true,
        retour:
          "Oui, et c'est exactement ce que le corrigé harmonisé national demande pour un sujet-citation. Beaucoup de candidats plaquent thèse-antithèse-synthèse et perdent des points de méthode.",
      },
      {
        texte: "Thèse — antithèse — synthèse",
        bonne: false,
        retour:
          "C'est l'erreur la plus répandue sur ce type de sujet. Une citation ne se discute pas en trois positions : on l'explique, on en montre les limites, puis on la réinterprète.",
      },
    ],
  },
  {
    id: "f3",
    enonce:
      "Tu dois écrire la transition entre thèse et antithèse sur le sujet du droit du plus fort. Laquelle transite ?",
    options: [
      {
        texte:
          "« Mais un droit qui ne tiendrait qu'à la force obligerait-il encore quand la force vient à manquer ? »",
        bonne: true,
        retour:
          "Oui : elle part de ce qui vient d'être dit et ouvre une question à laquelle la partie suivante répondra. Une transition est une question, pas une annonce.",
      },
      {
        texte: "« Nous allons maintenant voir l'antithèse. »",
        bonne: false,
        retour: "Cela annonce un mouvement sans le produire. Rien ne transite.",
      },
      {
        texte: "« Cependant, la force ne fonde pas le droit. »",
        bonne: false,
        retour:
          "Tu affirmes la partie suivante au lieu d'y conduire. La copie perd l'effet de progression, et le correcteur le voit.",
      },
      {
        texte: "« Mais d'un autre côté, il y a aussi des arguments contraires. »",
        bonne: false,
        retour: "Formule vide : elle conviendrait à n'importe quel sujet, donc à aucun.",
      },
    ],
  },
  {
    id: "f4",
    enonce: "Pourquoi une antithèse faible coûte-t-elle les points de la synthèse ?",
    options: [
      {
        texte:
          "Parce que la synthèse consiste à départager deux positions fortes : si l'une a été caricaturée, il n'y a plus rien à départager.",
        bonne: true,
        retour:
          "Exactement. Présenter l'adversaire sous sa forme la plus forte n'est pas de la générosité, c'est une nécessité technique.",
      },
      {
        texte: "Parce que le correcteur préfère les copies longues.",
        bonne: false,
        retour:
          "La longueur n'est pas un critère ; la deuxième partie est même limitée à deux pages.",
      },
      {
        texte: "Parce que l'antithèse vaut plus de points que la synthèse.",
        bonne: false,
        retour:
          "Elles valent 3 points chacune. Le problème n'est pas le barème, c'est l'enchaînement.",
      },
    ],
  },
];

export function PlanDissertation() {
  return (
    <div className="space-y-4">
      <JeuTri
        consigne="Sujet : « Est-il légitime de penser que la raison du plus fort est toujours la meilleure ? » Douze éléments en vrac. Place-les dans la thèse, l'antithèse ou la synthèse — et mets de côté ceux qui ne sont pas des arguments."
        categories={[
          { value: "these", label: "Thèse", aide: "oui, la force fonde le droit" },
          { value: "antithese", label: "Antithèse", aide: "non, elle ne le fonde pas" },
          { value: "synthese", label: "Synthèse", aide: "départager les deux" },
          { value: "hors", label: "Pas un argument", aide: "à écarter" },
        ]}
        items={ARGUMENTS_PLAN}
        conclusion={
          <>
            Remarque la structure des trois arguments de synthèse : ils ne choisissent pas un camp,
            ils montrent que les deux parlaient d'autre chose. C'est le seul mouvement qui mérite le
            nom de synthèse — une synthèse qui dit « il y a du vrai dans les deux » ne vaut pas un
            point.
          </>
        }
      />
      <div className="border-t border-border pt-3">
        <p className="mb-2 text-xs font-semibold text-foreground">
          Second volet — reconnaître la forme du libellé, et rédiger les transitions
        </p>
        <Qcm
          consigne="Deux plans existent, et c'est le libellé qui décide lequel. Puis quatre transitions, dont trois ne transitent rien."
          questions={FORME_SUJET}
          conclusion={
            <>
              Retiens la règle : <strong>sujet-question</strong> → thèse, antithèse, synthèse.{" "}
              <strong>Sujet-citation</strong> → explication de la pensée, limites, réinterprétation.
              C'est le corrigé harmonisé national qui l'établit, et c'est l'erreur de méthode la
              plus fréquente des copies.
            </>
          }
        />
      </div>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* 4. Les quatre tâches de la première partie                          */
/* ------------------------------------------------------------------ */

const TACHES: ReadonlyArray<Question> = [
  {
    id: "t1",
    enonce:
      "Texte de Bachelard : « L'opinion pense mal ; elle ne pense pas : elle traduit des besoins en connaissances. » Tâche : énoncer le THÈME.",
    options: [
      {
        texte: "L'opinion.",
        bonne: true,
        retour:
          "Oui. Le thème est un groupe nominal court : ce dont le texte parle. On n'y met ni verbe, ni difficulté.",
      },
      {
        texte: "L'opinion n'est pas une pensée.",
        bonne: false,
        retour:
          "C'est la thèse, pas le thème. Une phrase complète, attribuable à l'auteur et contestable : ce sont les marques de la thèse.",
      },
      {
        texte: "L'opinion peut-elle devenir une connaissance ?",
        bonne: false,
        retour: "C'est une problématique. Le thème n'est pas une question.",
      },
    ],
  },
  {
    id: "t2",
    enonce: "Même texte. Tâche : énoncer le PROBLÈME philosophique.",
    options: [
      {
        texte: "Le rapport de l'opinion et de la connaissance scientifique.",
        bonne: true,
        retour:
          "Oui : une difficulté, dite en un groupe nominal. Le problème nomme ce qui fait obstacle, non le domaine.",
      },
      {
        texte: "L'opinion et la science.",
        bonne: false,
        retour:
          "Deux notions juxtaposées : c'est un thème élargi, pas un problème. Aucune difficulté n'est énoncée.",
      },
      {
        texte: "Bachelard a-t-il raison ?",
        bonne: false,
        retour: "Le problème est impersonnel. Il subsisterait si Bachelard n'avait jamais écrit.",
      },
    ],
  },
  {
    id: "t3",
    enonce: "Même texte. Tâche : énoncer la THÈSE de l'auteur.",
    options: [
      {
        texte:
          "L'opinion n'est pas une connaissance imparfaite qu'on pourrait affiner : elle est d'un autre ordre, et il faut la détruire avant de construire.",
        bonne: true,
        retour:
          "Oui : une phrase, attribuée à l'auteur, et qu'on peut contredire — certains soutiennent justement que l'opinion est un premier pas.",
      },
      {
        texte: "L'auteur parle de l'opinion et de la science en deux phrases successives.",
        bonne: false,
        retour:
          "C'est de la paraphrase descriptive : tu décris le texte au lieu d'en extraire la position. Le correcteur retire les points.",
      },
      {
        texte: "L'opinion est quelque chose de très important dans la vie.",
        bonne: false,
        retour:
          "Hors sujet, et personne ne peut le contredire : une thèse que nul ne peut contester n'est pas une thèse.",
      },
    ],
  },
  {
    id: "t4",
    enonce:
      "Même texte. Tâche : dégager la STRUCTURE LOGIQUE. Quelle rédaction le correcteur attend-il ?",
    options: [
      {
        texte:
          "Un seul paragraphe avec des verbes de mouvement : l'auteur part du constat que l'opinion semble penser, il établit qu'elle ne fait que traduire des besoins, il en tire qu'elle n'est pas un premier pas, et il conclut qu'il faut la détruire.",
        bonne: true,
        retour:
          "Oui : un paragraphe, et des verbes qui montrent la marche du texte. C'est la forme demandée par les corrigés nationaux.",
      },
      {
        texte: "Une liste : 1. postulat. 2. argument. 3. conclusion.",
        bonne: false,
        retour:
          "Les étiquettes sont justes mais la forme ne l'est pas : on attend une rédaction suivie, pas un tableau. Des points partent sur la forme.",
      },
      {
        texte: "Un résumé du texte en trois phrases.",
        bonne: false,
        retour:
          "Résumer n'est pas structurer. La structure logique montre comment les idées s'appuient les unes sur les autres, pas ce qu'elles disent.",
      },
    ],
  },
  {
    id: "t5",
    enonce:
      "Second volet. Une réponse de candidat : « L'auteur soutient que la mort n'est rien pour nous, puisque tout mal est dans la sensation. » À quelle tâche répond-elle ?",
    options: [
      {
        texte: "À la thèse.",
        bonne: true,
        retour:
          "Oui : une phrase attribuée à l'auteur, contestable, et le « puisque » annonce même son premier argument.",
      },
      {
        texte: "Au thème.",
        bonne: false,
        retour: "Le thème serait « la mort », en deux mots.",
      },
      {
        texte: "À la structure logique.",
        bonne: false,
        retour:
          "Il y a bien un connecteur, mais une seule articulation ne fait pas une structure : il en faut le parcours complet.",
      },
    ],
  },
  {
    id: "t6",
    enonce:
      "Une autre réponse : « La difficulté est de savoir si l'on peut craindre ce que l'on ne rencontrera jamais. » À quelle tâche ?",
    options: [
      {
        texte: "Au problème.",
        bonne: true,
        retour:
          "Oui : une difficulté est énoncée, et c'est la marque du problème. On accepterait aussi la problématique si la phrase était interrogative.",
      },
      {
        texte: "À la thèse.",
        bonne: false,
        retour:
          "Une thèse affirme ; celle-ci interroge. On ne peut pas l'attribuer à l'auteur comme sa position.",
      },
      {
        texte: "Au thème.",
        bonne: false,
        retour: "Trop long et trop articulé pour un thème, qui est un groupe nominal.",
      },
    ],
  },
];

export function QuatreTachesTexte() {
  return (
    <Qcm
      consigne="Les quatre tâches de la première partie, puis deux réponses de candidats à identifier. Pour chaque tâche, trois réponses te sont proposées : la bonne, une paraphrase, un hors-sujet. La simulation note comme le ferait un correcteur."
      questions={TACHES}
      conclusion={
        <>
          Les quatre tâches dans l'ordre et leurs marques distinctives : le <strong>thème</strong>
          est un groupe nominal, le <strong>problème</strong> énonce une difficulté, la{" "}
          <strong>thèse</strong> est une phrase attribuée et contredisable, la{" "}
          <strong>structure logique</strong> se rédige en un paragraphe avec des verbes de
          mouvement. Confondre thème et problème est la faute la plus coûteuse de l'épreuve : elle
          fait perdre deux points d'un coup.
        </>
      }
    />
  );
}

/* ------------------------------------------------------------------ */
/* 5. Définir un concept                                               */
/* ------------------------------------------------------------------ */

const DEFINITIONS: ReadonlyArray<Question> = [
  {
    id: "d1",
    enonce: "Définis le concept de LIBERTÉ, tel que l'attendait le corrigé de la session 2021.",
    options: [
      {
        texte: "Pouvoir de se déterminer soi-même, sans y être contraint par une cause extérieure.",
        bonne: true,
        retour:
          "Oui : « pouvoir » est le genre prochain, « de se déterminer soi-même sans contrainte extérieure » est la différence spécifique. Un point sûr.",
      },
      {
        texte: "C'est le fait d'être libre.",
        bonne: false,
        retour:
          "Cercle vicieux : tu définis le mot par lui-même. Zéro, et le correcteur le voit en une seconde.",
      },
      {
        texte: "Par exemple, pouvoir choisir son métier ou sa religion.",
        bonne: false,
        retour:
          "Définition par l'exemple : tu donnes des cas au lieu du concept. Les exemples illustrent, ils ne définissent pas.",
      },
      {
        texte: "C'est une chose très précieuse pour l'homme.",
        bonne: false,
        retour:
          "Trop large : la santé et la paix le sont aussi. Un genre sans différence spécifique ne définit rien.",
      },
    ],
  },
  {
    id: "d2",
    enonce: "Définis le concept de LOI, au sens juridique.",
    options: [
      {
        texte:
          "Règle générale et obligatoire, édictée par une autorité souveraine, qui régit l'activité humaine de l'extérieur.",
        bonne: true,
        retour:
          "Oui, et c'est très proche de la définition de Lalande. Le « de l'extérieur » distingue la loi juridique de la loi morale, que je me donne moi-même.",
      },
      {
        texte: "Ce que l'État impose par la force.",
        bonne: false,
        retour:
          "La force est le moyen de l'application, pas l'essence de la loi — et cette définition donnerait raison d'avance à la thèse du droit du plus fort.",
      },
      {
        texte: "Une règle.",
        bonne: false,
        retour:
          "Le genre prochain seul, sans différence spécifique : la règle du jeu de dames est aussi une règle.",
      },
      {
        texte: "Ce qui est juste.",
        bonne: false,
        retour:
          "Contredit le texte et tout le chapitre : une loi peut être légale et injuste. Définir la loi par le juste supprime le problème.",
      },
    ],
  },
  {
    id: "d3",
    enonce: "Définis le concept de GOUVERNEMENT.",
    options: [
      {
        texte:
          "Ensemble des organes qui exercent le pouvoir exécutif dans un État, à un moment donné.",
        bonne: true,
        retour:
          "Oui, et le « à un moment donné » est ce qui le distingue de l'État, qui est permanent. Ce mot-là rapporte le point.",
      },
      {
        texte: "L'État.",
        bonne: false,
        retour:
          "Confusion que le correcteur attend et sanctionne : une élection change le gouvernement, pas l'État.",
      },
      {
        texte: "Les gens qui gouvernent.",
        bonne: false,
        retour: "Cercle vicieux déguisé : « gouvernement » défini par « gouverner ».",
      },
    ],
  },
  {
    id: "d4",
    enonce:
      "Construis une définition de CONSCIENCE au sens moral. Quel est le bon genre prochain ?",
    options: [
      {
        texte: "Faculté… (de juger de la valeur morale de nos actes)",
        bonne: true,
        retour:
          "Oui. Le genre prochain est le genre le plus proche qui contienne le concept : « faculté » convient, « chose » serait trop vaste.",
      },
      {
        texte: "Chose… (qui nous dit le bien et le mal)",
        bonne: false,
        retour:
          "« Chose » est le genre le plus éloigné possible. Un genre trop vaste rend la définition sans valeur.",
      },
      {
        texte: "Voix… (intérieure qui nous juge)",
        bonne: false,
        retour:
          "C'est une métaphore, pas un genre. Les images sont bienvenues dans le commentaire, jamais dans la définition.",
      },
    ],
  },
  {
    id: "d5",
    enonce: "On te demande de définir INCONSCIENT dans un texte de Freud. Quel piège t'attend ?",
    options: [
      {
        texte:
          "Le mot a deux sens : l'adjectif courant — qui n'a pas conscience — et le substantif freudien, instance psychique faite de représentations refoulées. Il faut donner celui du texte.",
        bonne: true,
        retour:
          "Oui : définir un concept dans un texte, c'est le définir tel que l'auteur l'emploie. Donner l'autre sens vaut zéro, même si la définition est juste en soi.",
      },
      {
        texte: "Aucun piège : l'inconscient est ce dont on n'a pas conscience.",
        bonne: false,
        retour:
          "C'est le sens courant, et il manque l'essentiel : chez Freud, l'inconscient n'est pas une absence mais une instance active, qui a ses lois.",
      },
      {
        texte: "Il faut citer les deux topiques.",
        bonne: false,
        retour:
          "Hors tâche : on te demande une définition de trois lignes, pas un exposé. Garde les topiques pour le commentaire.",
      },
    ],
  },
];

export function DefinirConcept() {
  return (
    <div className="space-y-3">
      <Qcm
        consigne="Cinq concepts, chacun avec plusieurs définitions candidates : la bonne, un cercle vicieux, une définition par l'exemple, une trop large, une qui contredit le texte. Choisis, et la simulation nomme la faute."
        questions={DEFINITIONS}
        conclusion={
          <>
            La règle unique, et elle vaut trois points de l'épreuve : une définition se construit en
            deux pièces, un <strong>genre prochain</strong> — le genre le plus proche qui contienne
            le concept — et une <strong>différence spécifique</strong> — ce qui le distingue des
            autres membres de ce genre. Trop de genre, la définition est vide ; pas de différence,
            elle ne définit rien ; le mot lui-même dans la définition, c'est un cercle.
          </>
        }
      />
      <Citation auteur="à retenir">
        Dans un exercice sur texte, on ne définit pas le concept dans l'absolu : on le définit
        <em> tel que l'auteur l'emploie</em>. Une définition juste mais étrangère au texte ne
        rapporte rien.
      </Citation>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* 6. Thème, problème, thèse : les trois repères                       */
/* ------------------------------------------------------------------ */

const REPONSES_CANDIDATS: ReadonlyArray<ItemTri> = [
  {
    id: "r1",
    texte: "« La conscience et l'inconscient. »",
    bonne: "theme",
    pourquoi: "Groupe nominal, aucune difficulté énoncée : c'est le thème.",
  },
  {
    id: "r2",
    texte: "« Le rapport du moi conscient aux forces qui le déterminent. »",
    bonne: "probleme",
    pourquoi: "Un groupe nominal, mais qui nomme une difficulté : c'est le problème.",
  },
  {
    id: "r3",
    texte: "« L'auteur soutient que le moi n'est pas maître chez lui. »",
    bonne: "these",
    pourquoi: "Phrase attribuée à l'auteur et contredisable : Alain et Sartre l'ont contredite.",
  },
  {
    id: "r4",
    texte: "« L'inconscient est un sujet très intéressant qui concerne tout le monde. »",
    bonne: "rien",
    pourquoi:
      "Ni thème, ni problème, ni thèse : un commentaire d'appréciation. Le correcteur ne peut rien en faire.",
  },
  {
    id: "r5",
    texte: "« Le droit du plus fort. »",
    bonne: "theme",
    pourquoi: "Le thème, et il est même recopié du libellé.",
  },
  {
    id: "r6",
    texte: "« Le fondement du droit. »",
    bonne: "probleme",
    pourquoi:
      "Le problème : il nomme ce qui fait difficulté — d'où le droit tire-t-il son autorité ?",
  },
  {
    id: "r7",
    texte: "« Rousseau établit que céder à la force est un acte de nécessité, non de volonté. »",
    bonne: "these",
    pourquoi: "Attribuée, précise, et contredite par Spinoza et Calliclès : une vraie thèse.",
  },
  {
    id: "r8",
    texte: "« Tout le monde est d'accord pour dire que la violence est mauvaise. »",
    bonne: "rien",
    pourquoi:
      "Une thèse que personne ne peut contredire n'en est pas une. Et « tout le monde est d'accord » est un appel à la majorité.",
  },
  {
    id: "r9",
    texte: "« L'existence et la mort. »",
    bonne: "theme",
    pourquoi: "Thème, repris du titre du chapitre.",
  },
  {
    id: "r10",
    texte: "« La possibilité de craindre ce qu'on ne rencontrera jamais. »",
    bonne: "probleme",
    pourquoi: "Une difficulté réelle, et elle commande toute la copie sur Épicure.",
  },
  {
    id: "r11",
    texte:
      "« Épicure affirme que la mort n'est rien pour nous, puisque tout bien et tout mal sont dans la sensation. »",
    bonne: "these",
    pourquoi: "Thèse avec son premier argument : c'est la meilleure forme de réponse.",
  },
  {
    id: "r12",
    texte: "« Le texte parle de la mort au début, puis de la sensation, puis il conclut. »",
    bonne: "rien",
    pourquoi:
      "C'est une description de la disposition du texte, pas de son contenu logique. Les correcteurs appellent cela de la paraphrase.",
  },
];

export function ThemeProblemeThese() {
  return (
    <div className="space-y-3">
      <JeuTri
        consigne="Douze réponses de candidats. Dis à quelle question chacune répond — le thème, le problème, la thèse — ou si elle ne répond à rien du tout."
        categories={[
          { value: "theme", label: "Thème", aide: "un groupe nominal, sans difficulté" },
          { value: "probleme", label: "Problème", aide: "un groupe nominal, mais une difficulté" },
          {
            value: "these",
            label: "Thèse",
            aide: "une phrase attribuée, et qu'on peut contredire",
          },
          { value: "rien", label: "Rien", aide: "paraphrase ou appréciation" },
        ]}
        items={REPONSES_CANDIDATS}
        conclusion={
          <>
            Les trois repères, à se répéter avant chaque épreuve. Le <strong>thème</strong> : un
            groupe nominal. Le <strong>problème</strong> : un groupe nominal aussi, mais qui nomme
            une difficulté. La <strong>thèse</strong> : une phrase, attribuée à l'auteur, et que
            quelqu'un pourrait contredire. Ce dernier test est le plus utile : si personne au monde
            ne peut s'opposer à ce que vous avez écrit, vous n'avez pas écrit une thèse.
          </>
        }
      />
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* 7. La structure logique d'un texte                                  */
/* ------------------------------------------------------------------ */

const PARAGRAPHES: ReadonlyArray<ItemTri> = [
  {
    id: "s1",
    texte: "« Tout bien et tout mal résident dans la sensation. »  —  début du texte d'Épicure",
    bonne: "postulat",
    pourquoi:
      "Posé sans être démontré, et tout le reste s'appuie dessus : c'est le postulat de départ.",
  },
  {
    id: "s2",
    texte: "« Or la mort est privation de toute sensation. »",
    bonne: "argument",
    pourquoi:
      "Le « or » introduit le deuxième élément du raisonnement. C'est l'argument qui fait fonctionner le postulat.",
  },
  {
    id: "s3",
    texte: "« Quand la mort est là, nous ne sommes plus ; quand nous sommes, elle n'est pas. »",
    bonne: "argument",
    pourquoi:
      "Second argument, indépendant du premier : celui de la rencontre impossible. Deux arguments pour une même thèse.",
  },
  {
    id: "s4",
    texte: "« Nous ne nous plaignons pas de n'avoir pas existé avant notre naissance. »",
    bonne: "exemple",
    pourquoi:
      "C'est une illustration par un cas, pas une raison : elle rend la thèse sensible sans l'établir. Confondre exemple et argument est la faute la plus coûteuse de l'exercice.",
  },
  {
    id: "s5",
    texte: "« Mais, dira-t-on, ce n'est pas la mort qu'on craint, c'est l'agonie. »",
    bonne: "objection",
    pourquoi:
      "Le « mais, dira-t-on » signale que l'auteur se fait l'objection à lui-même. Le repérer vaut des points : beaucoup de candidats l'attribuent à l'auteur comme sa propre thèse.",
  },
  {
    id: "s6",
    texte: "« La mort n'est donc rien pour nous. »",
    bonne: "conclusion",
    pourquoi: "Le « donc » ferme le raisonnement. C'est la thèse, à sa place : à la fin.",
  },
  {
    id: "s7",
    texte: "« En effet, aucune expérience ne nous donne jamais notre propre néant. »",
    bonne: "argument",
    pourquoi:
      "« En effet » annonce toujours une justification de ce qui précède. C'est un connecteur d'argument.",
  },
  {
    id: "s8",
    texte: "« Ainsi Socrate, le dernier jour, discutait-il sans trouble. »",
    bonne: "exemple",
    pourquoi:
      "Un cas particulier qui illustre. Le « ainsi » peut annoncer une conclusion ou un exemple : c'est le contenu qui tranche, pas le mot.",
  },
];

const REDACTION: ReadonlyArray<Question> = [
  {
    id: "w1",
    enonce:
      "Tu dois maintenant rédiger la structure logique. Première articulation : comment commencer ?",
    options: [
      {
        texte:
          "« L'auteur part du postulat que tout bien et tout mal résident dans la sensation… »",
        bonne: true,
        retour:
          "Oui : un verbe de mouvement — il part de — et le contenu du postulat. C'est la forme attendue.",
      },
      {
        texte: "« Dans le premier paragraphe, l'auteur dit que… »",
        bonne: false,
        retour:
          "Tu décris la disposition du texte au lieu de sa marche logique. Le correcteur appelle cela de la paraphrase.",
      },
      {
        texte: "« Le postulat : tout bien est dans la sensation. »",
        bonne: false,
        retour:
          "L'étiquette est juste, mais on attend une rédaction suivie, pas un tableau. Des points partent sur la forme.",
      },
    ],
  },
  {
    id: "w2",
    enonce: "Deuxième articulation : relier le postulat aux arguments.",
    options: [
      {
        texte:
          "« … il établit ensuite que la mort, étant privation de sensation, échappe à cette alternative, et il le confirme par l'impossibilité de la rencontrer… »",
        bonne: true,
        retour:
          "Oui : « il établit », « il le confirme ». Les deux arguments sont reliés, et leur rapport est dit.",
      },
      {
        texte: "« … puis il parle de la sensation, puis de la rencontre… »",
        bonne: false,
        retour:
          "« Puis… puis… » juxtapose sans articuler. On ne voit pas pourquoi le second argument suit le premier.",
      },
      {
        texte: "« … il donne deux arguments… »",
        bonne: false,
        retour:
          "Tu annonces leur nombre sans dire leur contenu ni leur rapport. C'est une structure vide.",
      },
    ],
  },
  {
    id: "w3",
    enonce: "Troisième articulation : l'objection que l'auteur se fait.",
    options: [
      {
        texte:
          "« … il envisage l'objection selon laquelle c'est l'agonie qu'on redoute, et l'écarte… »",
        bonne: true,
        retour:
          "Oui, et le mot « envisage » est précieux : il montre que l'objection n'est pas la thèse de l'auteur.",
      },
      {
        texte: "« … l'auteur reconnaît que c'est l'agonie qu'on redoute… »",
        bonne: false,
        retour:
          "Contresens : tu attribues à Épicure une thèse qu'il combat. C'est l'erreur que le « mais, dira-t-on » devait éviter.",
      },
    ],
  },
  {
    id: "w4",
    enonce: "Quatrième articulation : fermer.",
    options: [
      {
        texte: "« … pour conclure que la mort n'est rien pour nous. »",
        bonne: true,
        retour:
          "Oui. Le paragraphe est complet : un postulat, deux arguments, une objection écartée, une conclusion — et tout tient en une phrase longue.",
      },
      {
        texte: "« … et voilà la fin du texte. »",
        bonne: false,
        retour: "Tu décris le texte, tu ne restitues pas son raisonnement.",
      },
      {
        texte: "« … ce qui prouve qu'Épicure avait raison. »",
        bonne: false,
        retour:
          "Hors tâche : la structure logique restitue, elle n'apprécie pas. L'appréciation est pour la deuxième partie.",
      },
    ],
  },
];

export function StructureTexte() {
  const [cle, setCle] = useState(false);
  return (
    <div className="space-y-4">
      <JeuTri
        consigne="Un texte d'Épicure, découpé en huit moments. Étiquette chacun : postulat, argument, objection, exemple, conclusion. Les connecteurs sont tes indices — mais le contenu tranche, pas le mot."
        categories={[
          { value: "postulat", label: "Postulat", aide: "posé sans preuve, au départ" },
          { value: "argument", label: "Argument", aide: "une raison, souvent après or, en effet" },
          { value: "objection", label: "Objection", aide: "mais, dira-t-on" },
          { value: "exemple", label: "Exemple", aide: "un cas, qui illustre sans prouver" },
          { value: "conclusion", label: "Conclusion", aide: "donc, ainsi" },
        ]}
        items={PARAGRAPHES}
        conclusion={
          <>
            Deux pièges viennent d'être tendus. Le premier : un <strong>exemple</strong> n'est pas
            un argument — il rend sensible sans établir, et le prendre pour une preuve coûte des
            points. Le second : une <strong>objection</strong> que l'auteur se fait à lui-même n'est
            pas sa thèse, et le « mais, dira-t-on » est là pour le signaler.
          </>
        }
      />

      <button
        type="button"
        onClick={() => setCle((c) => !c)}
        className="rounded-lg border border-border px-3 py-1.5 text-xs font-medium text-muted-foreground hover:bg-secondary/60"
      >
        {cle ? "Masquer la table des connecteurs" : "Voir la table des connecteurs"}
      </button>
      {cle ? (
        <div className="grid gap-1.5 rounded-lg border border-border bg-secondary/20 p-3 text-xs sm:grid-cols-2">
          <p>
            <span className="font-semibold">en effet, car, puisque</span> → une raison arrive
          </p>
          <p>
            <span className="font-semibold">or</span> → un second élément du raisonnement
          </p>
          <p>
            <span className="font-semibold">donc, par conséquent, ainsi</span> → une conclusion
          </p>
          <p>
            <span className="font-semibold">mais, cependant, on dira que</span> → une objection
          </p>
          <p>
            <span className="font-semibold">par exemple, ainsi</span> → une illustration
          </p>
          <p>
            <span className="font-semibold">de plus, en outre</span> → un argument supplémentaire
          </p>
        </div>
      ) : null}

      <div className="border-t border-border pt-3">
        <p className="mb-2 text-xs font-semibold text-foreground">
          Second volet — rédiger le paragraphe attendu, articulation par articulation
        </p>
        <Qcm
          consigne="Quatre articulations à choisir. On attend un seul paragraphe, rédigé, avec des verbes de mouvement — il part de, il établit, il envisage, il conclut."
          questions={REDACTION}
          conclusion={
            <>
              Relis le paragraphe que tu viens de composer : « L'auteur part du postulat que…, il
              établit ensuite que…, il le confirme par…, il envisage l'objection selon laquelle…,
              pour conclure que… ». Une phrase, cinq mouvements, trois points. Apprends ce squelette
              par cœur : il convient à n'importe quel texte.
            </>
          }
        />
      </div>
    </div>
  );
}
