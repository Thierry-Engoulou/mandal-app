import { useState } from "react";
import { Choice, Ctrl, PALETTE, Stat, Verdict } from "./controls";
import { Citation, JeuTri, Jauges, Qcm, type ItemTri, type Question } from "./philo-noyau";

/** Philosophie Terminale C et D — chapitres 6 et 7 :
 *  droit et justice, l'État et le pouvoir. */

/* ------------------------------------------------------------------ */
/* 1. Légal ou légitime ? Le tableau à quatre cases                    */
/* ------------------------------------------------------------------ */

type Cas = {
  id: string;
  texte: string;
  legal: boolean;
  legitime: boolean;
  pourquoi: string;
};

const CAS: ReadonlyArray<Cas> = [
  {
    id: "l1",
    texte:
      "Une loi régulièrement votée prive une catégorie de citoyens du droit de propriété en raison de leur origine.",
    legal: true,
    legitime: false,
    pourquoi:
      "La case la plus importante du tableau. Légale, parce que votée dans les formes ; illégitime, parce qu'elle traite inégalement des êtres égaux en dignité. C'est l'existence de cette case qui rend le mot « injustice » possible.",
  },
  {
    id: "l2",
    texte:
      "Un homme refuse d'appliquer cette loi et cache ceux qu'elle vise, au risque de la prison.",
    legal: false,
    legitime: true,
    pourquoi:
      "La diagonale inverse : illégal et légitime. Sans droit naturel, cet acte serait indéfendable — on ne pourrait lui opposer que la loi, qu'il viole.",
  },
  {
    id: "l3",
    texte: "Un père vole du pain pour nourrir son enfant qui n'a pas mangé depuis deux jours.",
    legal: false,
    legitime: true,
    pourquoi:
      "Le droit lui-même l'admet à demi : c'est l'état de nécessité, que les tribunaux reconnaissent comme cause d'atténuation. La légitimité perçue influe sur la peine.",
  },
  {
    id: "l4",
    texte: "Un commerçant paie l'impôt fixé par la loi de finances votée par l'Assemblée.",
    legal: true,
    legitime: true,
    pourquoi:
      "Le cas ordinaire, et le plus fréquent : les deux coïncident. C'est pourquoi on les confond si facilement.",
  },
  {
    id: "l5",
    texte: "Un groupe armé prélève une taxe sur les commerçants d'un quartier qu'il contrôle.",
    legal: false,
    legitime: false,
    pourquoi:
      "Ni l'un ni l'autre. Et c'est exactement la question de Saint Augustin : sans la justice, qu'est-ce qu'un État sinon « une troupe de brigands » ? Ici, la troupe n'a même pas la forme de la loi.",
  },
  {
    id: "l6",
    texte: "Des ouvriers font grève alors qu'une loi d'exception vient d'interdire toute grève.",
    legal: false,
    legitime: true,
    pourquoi:
      "Illégal au moment des faits, légitime au nom d'un droit que la loi d'exception suspendait. Beaucoup de droits acquis ont commencé ainsi.",
  },
  {
    id: "l7",
    texte: "Un chef d'État prolonge son mandat par une révision constitutionnelle régulière.",
    legal: true,
    legitime: false,
    pourquoi:
      "Cas discuté, et il faut le traiter avec prudence : la forme est respectée, et la question de la légitimité porte sur l'esprit des institutions. C'est précisément ce genre de cas qui montre que le légal ne suffit pas à clore un débat.",
  },
  {
    id: "l8",
    texte: "Un policier arrête un voleur pris sur le fait.",
    legal: true,
    legitime: true,
    pourquoi:
      "Les deux, et remarquez ce qui le distingue du cas 5 : le policier et le groupe armé usent tous deux de la contrainte, mais l'un détient le monopole de la violence légitime, au sens de Weber.",
  },
  {
    id: "l9",
    texte: "Un citoyen refuse de payer un impôt qu'il juge trop élevé.",
    legal: false,
    legitime: false,
    pourquoi:
      "Le piège du tableau. Trouver une loi injuste ne suffit pas à rendre sa violation légitime : il faudrait qu'elle viole un droit fondamental, et non qu'elle déplaise. Sinon chacun choisit les lois qui lui conviennent.",
  },
  {
    id: "l10",
    texte: "L'esclavage, dans un pays où il est inscrit au Code, en 1750.",
    legal: true,
    legitime: false,
    pourquoi:
      "L'exemple décisif de tout le chapitre. Parfaitement légal pendant des siècles, et déclaré injuste — au nom de quoi ? De rien qui fût écrit dans ce Code. Il a fallu un critère extérieur à la loi.",
  },
  {
    id: "l11",
    texte: "Un juge applique les circonstances atténuantes prévues par le Code.",
    legal: true,
    legitime: true,
    pourquoi:
      "Les deux. Et cela prouve quelque chose : le droit positif a lui-même intégré une exigence de justice, en modulant la peine selon la liberté réelle de l'auteur.",
  },
  {
    id: "l12",
    texte: "Une loi accorde le droit de vote aux femmes.",
    legal: true,
    legitime: true,
    pourquoi:
      "Les deux aujourd'hui. Mais notez la direction du mouvement : cette loi a été réclamée comme légitime avant d'être légale. C'est ainsi que le droit positif se corrige.",
  },
];

const CAS_VIDE: Cas = { id: "", texte: "—", legal: false, legitime: false, pourquoi: "—" };

function DeuxAxes({
  legal,
  legitime,
  repLegal,
  repLegitime,
  setLegal,
  setLegitime,
}: {
  legal: boolean;
  legitime: boolean;
  repLegal: boolean | null;
  repLegitime: boolean | null;
  setLegal: (v: boolean) => void;
  setLegitime: (v: boolean) => void;
}) {
  const axes: ReadonlyArray<{
    label: string;
    attendu: boolean;
    rep: boolean | null;
    set: (v: boolean) => void;
  }> = [
    { label: "Est-ce légal ?", attendu: legal, rep: repLegal, set: setLegal },
    { label: "Est-ce légitime ?", attendu: legitime, rep: repLegitime, set: setLegitime },
  ];
  return (
    <div className="grid gap-2 sm:grid-cols-2">
      {axes.map((a) => {
        const bon = a.rep !== null && a.rep === a.attendu;
        return (
          <div key={a.label} className="space-y-1">
            <p className="text-[11px] font-medium text-muted-foreground">{a.label}</p>
            <div className="flex gap-1">
              {[true, false].map((v) => {
                const actif = a.rep === v;
                const cls = !actif
                  ? "border-border bg-background text-muted-foreground hover:bg-secondary/60"
                  : bon
                    ? "border-emerald-500/40 bg-emerald-500/15 text-emerald-700"
                    : "border-rose-500/40 bg-rose-500/15 text-rose-700";
                return (
                  <button
                    key={v ? "oui" : "non"}
                    type="button"
                    onClick={() => a.set(v)}
                    className={`rounded-lg border px-2.5 py-1 text-xs font-medium ${cls}`}
                  >
                    {v ? "oui" : "non"}
                  </button>
                );
              })}
            </div>
          </div>
        );
      })}
    </div>
  );
}

export function LegalLegitime() {
  const [rang, setRang] = useState(0);
  const [rl, setRl] = useState<boolean | null>(null);
  const [rg, setRg] = useState<boolean | null>(null);
  const [grille, setGrille] = useState<Record<string, boolean>>({});

  const c = CAS[rang] ?? CAS_VIDE;
  const complet = rl !== null && rg !== null;
  const juste = complet && rl === c.legal && rg === c.legitime;

  const cellule = (l: boolean, g: boolean) => CAS.filter((x) => x.legal === l && x.legitime === g);
  const remplies = (l: boolean, g: boolean) => cellule(l, g).filter((x) => grille[x.id]).length;

  return (
    <div className="space-y-3">
      <p className="text-sm text-muted-foreground">
        Douze situations, et deux questions indépendantes pour chacune : est-ce légal, est-ce
        légitime ? Les quatre cases du tableau existent vraiment, y compris les deux diagonales — et
        c'est de leur existence que dépend tout le chapitre.
      </p>

      <div className="rounded-lg border border-border bg-background p-3">
        <p className="text-sm leading-relaxed text-foreground">{c.texte}</p>
        <div className="mt-3">
          <DeuxAxes
            legal={c.legal}
            legitime={c.legitime}
            repLegal={rl}
            repLegitime={rg}
            setLegal={setRl}
            setLegitime={setRg}
          />
        </div>
        {complet ? (
          <div className="mt-3 space-y-2">
            <Verdict tone={juste ? "ok" : "warn"}>
              <span className="font-semibold">
                {c.legal ? "légal" : "illégal"} et {c.legitime ? "légitime" : "illégitime"}.{" "}
              </span>
              {c.pourquoi}
            </Verdict>
            <div className="flex items-center gap-2">
              <button
                type="button"
                onClick={() => {
                  setGrille((g) => ({ ...g, [c.id]: true }));
                  setRang((r) => (r + 1) % CAS.length);
                  setRl(null);
                  setRg(null);
                }}
                className="rounded-lg bg-primary px-3 py-1.5 text-xs font-semibold text-primary-foreground"
              >
                Situation suivante
              </button>
              <span className="text-[11px] text-muted-foreground">
                {rang + 1} / {CAS.length}
              </span>
            </div>
          </div>
        ) : null}
      </div>

      <div>
        <p className="mb-1.5 text-xs font-semibold text-foreground">Le tableau se remplit</p>
        <div className="grid grid-cols-2 gap-2">
          {[
            { l: true, g: true, nom: "Légal et légitime", ton: PALETTE.green },
            { l: true, g: false, nom: "Légal et injuste", ton: PALETTE.red },
            { l: false, g: true, nom: "Illégal et légitime", ton: PALETTE.orange },
            { l: false, g: false, nom: "Ni l'un ni l'autre", ton: PALETTE.slate },
          ].map((k) => (
            <div
              key={k.nom}
              className="rounded-lg border border-border bg-secondary/20 px-2.5 py-2"
            >
              <p className="text-[11px] font-semibold" style={{ color: k.ton }}>
                {k.nom}
              </p>
              <p className="font-mono text-xs text-muted-foreground">
                {remplies(k.l, k.g)} / {cellule(k.l, k.g).length} trouvée(s)
              </p>
            </div>
          ))}
        </div>
      </div>

      <Citation auteur="ce qu'il faut en conclure">
        Les deux diagonales ne sont pas des curiosités : ce sont elles qui rendent la critique des
        lois possible. Si le légal et le légitime coïncidaient toujours, la phrase « cette loi est
        injuste » n'aurait aucun sens, et aucune loi n'aurait jamais pu être réformée.
      </Citation>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* 2. Le droit du plus fort, et sa réfutation                          */
/* ------------------------------------------------------------------ */

type Loi = { titre: string; profite: "a" | "b" | "tous" };

export function DroitPlusFort() {
  const [forceA, setForceA] = useState(80);
  const [renverse, setRenverse] = useState(false);

  const forceB = 100 - forceA;
  const dominant = forceA >= forceB ? "A" : "B";

  const lois: ReadonlyArray<Loi> =
    forceA >= 65
      ? [
          { titre: "Les terres appartiennent à ceux qui les détiennent déjà.", profite: "a" },
          {
            titre: "Les contrats de travail sont libres : chacun accepte ce qu'il veut.",
            profite: "a",
          },
          {
            titre: "Toute réunion de plus de dix personnes est soumise à autorisation.",
            profite: "a",
          },
          { titre: "Le vol est puni, quel que soit le motif.", profite: "a" },
        ]
      : forceA <= 35
        ? [
            { titre: "Les terres sont redistribuées à ceux qui les cultivent.", profite: "b" },
            { titre: "Un salaire minimum est fixé par la loi.", profite: "b" },
            { titre: "Le droit de réunion et de grève est garanti.", profite: "b" },
            { titre: "L'accaparement des terres est puni.", profite: "b" },
          ]
        : [
            { titre: "Les terres font l'objet d'un partage négocié.", profite: "tous" },
            {
              titre: "Les salaires sont fixés par convention entre les deux groupes.",
              profite: "tous",
            },
            {
              titre: "Le droit de réunion est garanti, sous réserve d'ordre public.",
              profite: "tous",
            },
            {
              titre: "Le vol est puni, avec circonstances atténuantes pour nécessité.",
              profite: "tous",
            },
          ];

  return (
    <div className="space-y-3">
      <p className="text-sm text-muted-foreground">
        Une société, deux groupes, et des lois. Déplace le rapport de forces et regarde les lois se
        réécrire d'elles-mêmes : c'est la thèse de Thrasymaque, et elle fonctionne. La question de
        Rousseau viendra ensuite.
      </p>

      <Ctrl
        label="Force du groupe A (propriétaires)"
        value={forceA}
        min={0}
        max={100}
        step={5}
        onChange={(v) => {
          setForceA(v);
          setRenverse(false);
        }}
        display={`${forceA} contre ${forceB}`}
        color={PALETTE.purple}
      />

      <div className="grid grid-cols-2 gap-2">
        <Stat label="Groupe A" value={`${forceA} %`} color={PALETTE.purple} />
        <Stat label="Groupe B (travailleurs)" value={`${forceB} %`} color={PALETTE.blue} />
      </div>

      <div className="rounded-lg border border-border bg-background p-3">
        <p className="text-[11px] font-semibold uppercase tracking-wide text-muted-foreground">
          Les lois en vigueur
        </p>
        <ul className="mt-1.5 space-y-1">
          {lois.map((l) => (
            <li key={l.titre} className="text-xs leading-snug">
              <span
                className="mr-1.5 inline-block h-1.5 w-1.5 rounded-full align-middle"
                style={{
                  backgroundColor:
                    l.profite === "a"
                      ? PALETTE.purple
                      : l.profite === "b"
                        ? PALETTE.blue
                        : PALETTE.green,
                }}
              />
              {l.titre}
            </li>
          ))}
        </ul>
        <p className="mt-2 text-[11px] italic text-muted-foreground">
          {forceA >= 65 || forceA <= 35
            ? `Les quatre lois profitent au groupe ${dominant}, qui est le plus fort. « Le juste est partout ce qui profite au plus fort » — Thrasymaque, dans La République.`
            : "Forces équilibrées : les lois deviennent des compromis. Remarque qu'aucune des deux thèses du cours ne prévoyait ce cas."}
        </p>
      </div>

      <Verdict tone="warn">
        La thèse descriptive est vérifiée : les lois suivent la force. Mais une question reste, et
        c'est celle de Rousseau.
      </Verdict>

      <button
        type="button"
        onClick={() => setRenverse((r) => !r)}
        className="rounded-lg bg-primary px-3 py-1.5 text-xs font-semibold text-primary-foreground"
      >
        {renverse
          ? "Masquer la question de Rousseau"
          : "Le groupe dominé devient le plus fort. Et alors ?"}
      </button>

      {renverse ? (
        <div className="space-y-2">
          <div className="rounded-lg border border-primary/40 bg-primary/5 p-3 text-xs leading-relaxed">
            <p className="font-semibold text-foreground">La question</p>
            <p className="mt-1 text-muted-foreground">
              Les anciennes lois, écrites par l'ancien dominant, obligent-elles encore ceux qui sont
              devenus les plus forts ?
            </p>
            <p className="mt-2 font-semibold text-foreground">La réponse de la thèse adverse</p>
            <p className="mt-1 text-muted-foreground">
              Non : si c'est la force qui faisait le droit, le droit change dès que la force change
              de camp. Il n'y a donc plus aucun <strong>devoir</strong> d'obéir, seulement une{" "}
              <strong>nécessité</strong> de céder tant qu'on est faible.
            </p>
            <p className="mt-2 font-semibold text-foreground">La conséquence</p>
            <p className="mt-1 text-muted-foreground">
              Un droit qui s'évanouit dès qu'on peut désobéir impunément n'était pas un droit :
              c'était une contrainte momentanée. L'expression « droit du plus fort » est donc{" "}
              <strong>contradictoire</strong>.
            </p>
          </div>
          <Citation auteur="Rousseau, Du contrat social, livre I">
            Céder à la force est un acte de nécessité, non de volonté ; c'est tout au plus un acte
            de prudence.
          </Citation>
          <Verdict tone="ok">
            Retiens que la réfutation est <strong>logique</strong> et non morale. Rousseau ne dit
            pas qu'il est laid d'obéir au plus fort : il montre que si c'est un droit, il oblige
            même quand la force manque, et que si c'est la force, il n'oblige pas du tout.
          </Verdict>
        </div>
      ) : null}
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* 3. Un droit perfectible                                             */
/* ------------------------------------------------------------------ */

const ABOLITIONS: ReadonlyArray<Question> = [
  {
    id: "ab1",
    enonce:
      "L'esclavage a été parfaitement légal pendant des siècles, inscrit dans les Codes. Au nom de quoi a-t-il pu être déclaré injuste ?",
    options: [
      {
        texte:
          "Au nom d'un principe extérieur à ces Codes : l'égale dignité des hommes, c'est-à-dire le droit naturel.",
        bonne: true,
        retour:
          "Oui, et c'est le mécanisme qui va se répéter huit fois. La loi n'a jamais pu se corriger avec ses propres ressources.",
      },
      {
        texte: "Au nom d'une autre loi déjà existante.",
        bonne: false,
        retour:
          "Il n'y en avait pas : c'est tout le problème. Si la seule mesure du juste était la loi en vigueur, l'esclavage légal aurait été juste par définition.",
      },
      {
        texte: "Parce que c'était devenu inutile économiquement.",
        bonne: false,
        retour:
          "L'argument économique a joué historiquement, et il ne fonde rien : si l'esclavage redevenait rentable, il redeviendrait juste. Ce n'est pas un critère moral.",
      },
    ],
  },
  {
    id: "ab2",
    enonce: "L'interdiction du vote des femmes était légale. Au nom de quoi a-t-elle été abolie ?",
    options: [
      {
        texte: "Au nom de l'égalité des citoyens, principe que la loi proclamait sans l'appliquer.",
        bonne: true,
        retour:
          "Oui, et c'est un cas intéressant : le critère était déjà écrit dans les principes, mais démenti dans les textes d'application. La contradiction interne a été l'arme.",
      },
      {
        texte: "Parce que les femmes sont devenues plus instruites.",
        bonne: false,
        retour:
          "C'est accepter la prémisse adverse — que le droit de vote se mériterait par l'instruction. Le raisonnement se retournerait contre bien des électeurs.",
      },
    ],
  },
  {
    id: "ab3",
    enonce:
      "Le travail des enfants de huit ans dans les mines était légal au XIXe siècle. Au nom de quoi a-t-il été interdit ?",
    options: [
      {
        texte:
          "Au nom de la dignité et de la protection due à qui ne peut pas se défendre — un principe que le contrat de travail, pourtant librement signé, ne donnait pas.",
        bonne: true,
        retour:
          "Oui. Et notez le point : le contrat était formellement libre. C'est l'argument de Lacordaire — entre le fort et le faible, c'est la liberté qui opprime et la loi qui affranchit.",
      },
      {
        texte: "Parce que les machines ont rendu les enfants inutiles.",
        bonne: false,
        retour: "Même faille que l'argument économique : il ne fonde aucun droit.",
      },
    ],
  },
  {
    id: "ab4",
    enonce:
      "Les lois raciales du XXe siècle étaient votées par des parlements. Que prouve leur condamnation ultérieure ?",
    options: [
      {
        texte:
          "Qu'une loi régulièrement adoptée peut être criminelle, et qu'il existe donc un critère au-dessus de la procédure.",
        bonne: true,
        retour:
          "Oui, et c'est la difficulté majeure du positivisme juridique strict : réduire le droit au droit positif rend très difficile de condamner une législation inique autrement qu'au nom de ses préférences.",
      },
      {
        texte: "Que les parlements de l'époque étaient illégitimes.",
        bonne: false,
        retour:
          "Dans plusieurs cas, ils avaient été élus. Déplacer le problème sur la légitimité du législateur ne supprime pas la question : il faut encore un critère pour juger la loi elle-même.",
      },
    ],
  },
  {
    id: "ab5",
    enonce: "Qu'ont en commun les huit abolitions que tu viens de parcourir ?",
    options: [
      {
        texte:
          "Chaque fois, c'est un principe extérieur à la loi en vigueur qui a servi à la corriger.",
        bonne: true,
        retour:
          "C'est le mécanisme, et il est toujours le même. Voilà pourquoi le droit naturel n'est pas une rêverie : sans lui, aucune réforme n'aurait de fondement.",
      },
      {
        texte: "Chaque fois, un gouvernement nouveau est arrivé au pouvoir.",
        bonne: false,
        retour: "Parfois, et ce n'est pas la question : on demande au nom de QUOI, non par qui.",
      },
    ],
  },
  {
    id: "ab6",
    enonce:
      "Dernière question, et elle est gênante : s'il n'existait aucun droit naturel, qu'est-ce qui aurait permis ces abolitions ?",
    options: [
      {
        texte:
          "Rien de plus que des rapports de force, qui pourraient donc se renverser à nouveau sans qu'on puisse rien y objecter.",
        bonne: true,
        retour:
          "Oui, et c'est la réponse honnête. Celui qui réduit le droit au droit positif gagne en rigueur et perd le moyen de dire qu'un retour en arrière serait injuste.",
      },
      {
        texte: "Le progrès de l'histoire, qui va toujours vers le mieux.",
        bonne: false,
        retour:
          "Affirmation gratuite, et démentie par les faits : le XXe siècle a vu des reculs légaux massifs. Le progrès n'est pas un argument, c'est un espoir.",
      },
      {
        texte: "La conscience morale de chacun.",
        bonne: false,
        retour:
          "Elle a joué, mais si elle ne vise aucun principe commun, elle ne permet pas de dire que l'esclavagiste se trompait : elle dit seulement qu'on ne s'accorde pas.",
      },
    ],
  },
];

export function DroitPerfectible() {
  return (
    <Qcm
      consigne="Six lois qui ont réellement existé, et qui étaient parfaitement légales. Pour chacune, dis au nom de quoi elle a pu être abolie. Le même mécanisme va se répéter sous tes yeux."
      questions={ABOLITIONS}
      conclusion={
        <>
          Le droit n'est ni juste ni injuste par nature : il est <strong>perfectible</strong>. Son
          histoire est celle d'un écart entre ce qui est et ce qui devrait être — et c'est cet écart
          qui le rend à la fois critiquable et améliorable. Un droit parfait n'aurait pas besoin de
          juristes ; un droit sans aucune justice ne pourrait pas être réformé, faute de critère.
        </>
      }
    />
  );
}

/* ------------------------------------------------------------------ */
/* 4. État, gouvernement, nation, pouvoir                              */
/* ------------------------------------------------------------------ */

const NOTIONS_ETAT: ReadonlyArray<ItemTri> = [
  {
    id: "e1",
    texte: "Il signe les traités internationaux.",
    bonne: "etat",
    pourquoi: "La personne morale souveraine, et elle seule, engage le pays sur la scène mondiale.",
  },
  {
    id: "e2",
    texte: "Il a été renversé par les urnes le mois dernier.",
    bonne: "gouvernement",
    pourquoi: "On change de gouvernement par une élection ; l'État, lui, n'a pas bougé.",
  },
  {
    id: "e3",
    texte: "Elle partage une langue, une histoire et le sentiment d'un destin commun.",
    bonne: "nation",
    pourquoi:
      "La nation est une communauté humaine, pas une institution. Un État peut contenir plusieurs nations, et une nation s'étendre sur plusieurs États.",
  },
  {
    id: "e4",
    texte: "Il demeure quand le ministre tombe.",
    bonne: "etat",
    pourquoi:
      "La permanence est le trait distinctif de l'État. C'est pour cela qu'on dit « coup d'État » : l'expression désigne la prise du gouvernement, pas la disparition de l'État.",
  },
  {
    id: "e5",
    texte: "Capacité de se faire obéir, qu'elle repose sur la force, l'autorité ou la persuasion.",
    bonne: "pouvoir",
    pourquoi: "Le pouvoir est une relation, pas une institution : il s'exerce, il ne se signe pas.",
  },
  {
    id: "e6",
    texte: "Il détient le monopole de la violence physique légitime sur un territoire.",
    bonne: "etat",
    pourquoi: "La définition de Max Weber, mot pour mot.",
  },
  {
    id: "e7",
    texte: "Il est composé d'un Premier ministre et de ses ministres.",
    bonne: "gouvernement",
    pourquoi: "L'organe exécutif, et lui seul.",
  },
  {
    id: "e8",
    texte: "Elle peut exister sans territoire propre, dispersée dans plusieurs pays.",
    bonne: "nation",
    pourquoi:
      "C'est le cas de plusieurs nations dans l'histoire. Un État sans territoire est impossible ; une nation sans territoire ne l'est pas.",
  },
  {
    id: "e9",
    texte: "Il se compose d'un territoire, d'une population et d'une souveraineté.",
    bonne: "etat",
    pourquoi: "Les trois éléments constitutifs, au sens géopolitique du mot.",
  },
  {
    id: "e10",
    texte: "Un enseignant l'exerce sur sa classe, un père sur ses enfants.",
    bonne: "pouvoir",
    pourquoi:
      "Le pouvoir n'est pas réservé à la politique : il y a du pouvoir partout où quelqu'un se fait obéir.",
  },
  {
    id: "e11",
    texte: "Il démissionne, et l'administration continue de fonctionner le lendemain.",
    bonne: "gouvernement",
    pourquoi:
      "Cette continuité est la preuve concrète de la distinction : l'administration appartient à l'État, pas au gouvernement.",
  },
  {
    id: "e12",
    texte: "Il est suprême à l'intérieur et indépendant à l'extérieur.",
    bonne: "etat",
    pourquoi: "C'est la définition de la souveraineté, caractère propre du pouvoir d'État.",
  },
  {
    id: "e13",
    texte: "Un coup d'État le renverse.",
    bonne: "gouvernement",
    pourquoi:
      "Le cas qui piège tout le monde. Malgré son nom, un coup d'État renverse le gouvernement : si l'État disparaissait, il n'y aurait plus rien à prendre.",
  },
  {
    id: "e14",
    texte: "Althusser en distingue les appareils répressifs et les appareils idéologiques.",
    bonne: "etat",
    pourquoi:
      "Les deux séries d'instruments par lesquels l'État se maintient : l'armée et la police d'une part, l'école et les médias de l'autre.",
  },
  {
    id: "e15",
    texte:
      "Max Weber en distingue trois formes de légitimité : traditionnelle, charismatique, légale.",
    bonne: "pouvoir",
    pourquoi:
      "La typologie porte sur ce qui fait obéir, donc sur le pouvoir. Le citer rapporte des points, parce que peu de copies le connaissent.",
  },
];

export function NotionsEtat() {
  return (
    <JeuTri
      consigne="Quinze énoncés. Désigne pour chacun ce dont il s'agit. Un cas au moins piège presque tout le monde — cherche-le."
      categories={[
        { value: "etat", label: "L'État", aide: "personne morale souveraine, permanente" },
        { value: "gouvernement", label: "Le gouvernement", aide: "l'organe exécutif, temporaire" },
        { value: "nation", label: "La nation", aide: "une communauté humaine" },
        { value: "pouvoir", label: "Le pouvoir", aide: "une capacité de se faire obéir" },
      ]}
      items={NOTIONS_ETAT}
      conclusion={
        <>
          Le cas piégé était le coup d'État : malgré son nom, il renverse le{" "}
          <strong>gouvernement</strong>. Retiens la règle qui tranche tous les autres : l'État est{" "}
          <strong>permanent</strong>, le gouvernement est <strong>temporaire</strong>, la nation est
          une <strong>communauté</strong> et non une institution, et le pouvoir est une{" "}
          <strong>relation</strong> qui existe aussi hors de la politique.
        </>
      }
    />
  );
}

/* ------------------------------------------------------------------ */
/* 5. Les trois contrats                                               */
/* ------------------------------------------------------------------ */

type Contrat = {
  id: "hobbes" | "locke" | "rousseau";
  nature: string;
  natureDetail: string;
  contrat: string;
  contratDetail: string;
  etat: string;
  etatDetail: string;
  revolte: string;
  revolteTon: "ok" | "warn" | "bad";
  oeuvre: string;
  crainte: string;
};

const CONTRATS: ReadonlyArray<Contrat> = [
  {
    id: "hobbes",
    nature: "Une guerre de tous contre tous",
    natureDetail:
      "Chacun ayant droit à tout, nul n'est en sûreté. La vie y est « solitaire, misérable, dangereuse, animale et brève ». Homo homini lupus : l'homme est un loup pour l'homme.",
    contrat: "Un abandon",
    contratDetail:
      "Chacun abandonne son droit de se gouverner lui-même au profit d'un homme ou d'une assemblée, à condition que tous en fassent autant. Ce qui est donné n'est plus à moi.",
    etat: "Un souverain absolu",
    etatDetail:
      "Le souverain n'est pas partie au contrat : il n'a donc rien promis, et on ne peut rien lui reprocher. Son pouvoir ne connaît pas de limite interne.",
    revolte:
      "Illégitime, et toujours. Se révolter, c'est rompre le pacte et ramener la guerre — même contre un tyran, car la pire tyrannie vaut encore mieux que l'état de nature.",
    revolteTon: "bad",
    oeuvre: "Le Léviathan, 1651",
    crainte: "Hobbes a vécu la guerre civile anglaise : il craint le désordre.",
  },
  {
    id: "locke",
    nature: "Des droits réels, mais mal garantis",
    natureDetail:
      "Les hommes y ont déjà la vie, la liberté et la propriété. Ce n'est pas une guerre : simplement, chacun étant juge en sa propre cause, personne ne garantit ces droits.",
    contrat: "Un dépôt",
    contratDetail:
      "Chacun confie la garantie de droits qu'il CONSERVE. Ce qui est déposé reste à moi — et c'est toute la différence avec Hobbes.",
    etat: "Un pouvoir limité",
    etatDetail:
      "Le pouvoir a reçu une mission : garantir des droits qui lui préexistent. Il est donc borné par l'objet même de son mandat.",
    revolte:
      "Légitime quand le pouvoir viole les droits qu'il devait protéger : il trahit alors le dépôt et perd sa légitimité. C'est de cette thèse que se réclameront les révolutions anglaise, américaine et française.",
    revolteTon: "ok",
    oeuvre: "Traité du gouvernement civil, 1690",
    crainte: "Locke a vu l'absolutisme : il craint la tyrannie.",
  },
  {
    id: "rousseau",
    nature: "Un homme naturellement bon",
    natureDetail:
      "L'homme y vit sans malice ; c'est la propriété et la comparaison sociale qui l'ont corrompu. L'état de nature n'est pas un fait historique mais une hypothèse de méthode.",
    contrat: "Une association",
    contratDetail:
      "Chacun se donne à tous, donc à personne en particulier. De cette aliénation totale naît la volonté générale, et chacun retrouve en droits ce qu'il a cédé.",
    etat: "La souveraineté du peuple",
    etatDetail:
      "L'État n'est rien d'autre que le peuple assemblé. Obéir à la loi, c'est obéir à soi-même : « l'obéissance à la loi qu'on s'est prescrite est liberté ».",
    revolte:
      "La question se déplace : il n'y a pas à se révolter contre un souverain qu'on est soi-même. En revanche, un gouvernement qui trahit la volonté générale n'est plus légitime, et le peuple reprend ce qu'il n'avait fait que déléguer.",
    revolteTon: "warn",
    oeuvre: "Du contrat social, 1762",
    crainte: "Rousseau voit la société inégalitaire de son temps : il craint la corruption.",
  },
];

const CONTRAT_DEFAUT: Contrat = CONTRATS[0] ?? {
  id: "hobbes",
  nature: "—",
  natureDetail: "—",
  contrat: "—",
  contratDetail: "—",
  etat: "—",
  etatDetail: "—",
  revolte: "—",
  revolteTon: "warn",
  oeuvre: "—",
  crainte: "—",
};

export function TroisContrats() {
  const [qui, setQui] = useState<"hobbes" | "locke" | "rousseau">("hobbes");
  const [cas, setCas] = useState(false);

  const c = CONTRATS.find((x) => x.id === qui) ?? CONTRAT_DEFAUT;

  return (
    <div className="space-y-3">
      <p className="text-sm text-muted-foreground">
        Choisis un état de nature, et la simulation construit l'État qui en découle : son étendue,
        ses limites, et le droit de révolte qui en résulte. Le droit de résistance ne se discute pas
        en lui-même : il découle du contrat qu'on a signé.
      </p>

      <Choice<"hobbes" | "locke" | "rousseau">
        label="L'état de nature, au départ"
        value={qui}
        options={[
          { value: "hobbes", label: "Guerre de tous contre tous" },
          { value: "locke", label: "Droits mal garantis" },
          { value: "rousseau", label: "Bonté naturelle" },
        ]}
        onChange={(v) => {
          setQui(v);
          setCas(false);
        }}
      />

      <div className="space-y-2">
        {[
          {
            etape: "1. L'état de nature",
            titre: c.nature,
            detail: c.natureDetail,
            ton: PALETTE.orange,
          },
          { etape: "2. Le contrat", titre: c.contrat, detail: c.contratDetail, ton: PALETTE.blue },
          { etape: "3. L'État obtenu", titre: c.etat, detail: c.etatDetail, ton: PALETTE.purple },
        ].map((b) => (
          <div key={b.etape} className="rounded-lg border border-border bg-background p-2.5">
            <p
              className="text-[11px] font-semibold uppercase tracking-wide"
              style={{ color: b.ton }}
            >
              {b.etape}
            </p>
            <p className="text-sm font-medium text-foreground">{b.titre}</p>
            <p className="mt-1 text-xs leading-snug text-muted-foreground">{b.detail}</p>
          </div>
        ))}
      </div>

      <button
        type="button"
        onClick={() => setCas((v) => !v)}
        className="rounded-lg bg-primary px-3 py-1.5 text-xs font-semibold text-primary-foreground"
      >
        {cas
          ? "Masquer le cas limite"
          : "Cas limite : le gouvernement viole les droits qu'il devait protéger"}
      </button>

      {cas ? (
        <div className="space-y-2">
          <Verdict tone={c.revolteTon}>
            <span className="font-semibold">La révolte ? </span>
            {c.revolte}
          </Verdict>
          <div className="rounded-lg border border-border bg-secondary/20 p-2.5 text-[11px] leading-snug text-muted-foreground">
            <p>
              <span className="font-semibold text-foreground">{c.oeuvre}.</span> {c.crainte}
            </p>
            <p className="mt-1">
              Essaie les deux autres : la même situation reçoit trois réponses opposées, et la
              différence vient uniquement de ce qu'on a cédé au départ. Chez Hobbes on a{" "}
              <strong>donné</strong>, chez Locke on a <strong>déposé</strong> — ce qui est donné
              n'est plus à moi, ce qui est déposé le reste.
            </p>
          </div>
        </div>
      ) : null}
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* 6. Quel État ?                                                      */
/* ------------------------------------------------------------------ */

export function QuelEtat() {
  const [police, setPolice] = useState(50);
  const [services, setServices] = useState(50);
  const [separation, setSeparation] = useState(50);
  const [presse, setPresse] = useState(50);

  const contrepouvoirs = (separation + presse) / 2;

  const securite = Math.round(Math.min(100, 12 + police * 0.68 + services * 0.22));
  const liberteReelle = Math.round(
    Math.min(
      100,
      Math.max(
        0,
        10 +
          services * 0.3 +
          contrepouvoirs * 0.5 +
          Math.min(police, 55) * 0.3 -
          Math.max(0, police - 55) * 0.55,
      ),
    ),
  );
  const tyrannie = Math.round(
    Math.min(100, Math.max(0, 10 + police * 0.75 - contrepouvoirs * 0.55)),
  );

  const etiquette =
    police < 18 && services < 25
      ? {
          nom: "Presque pas d'État",
          note: "L'anarchie que Locke et Hobbes voulaient tous deux éviter : le faible n'a que la liberté que le fort lui laisse.",
          ton: "bad" as const,
        }
      : tyrannie >= 55
        ? {
            nom: "Le Léviathan de Hobbes",
            note: "La sécurité achetée au prix de la liberté, et sans contre-pouvoir pour arrêter le souverain.",
            ton: "bad" as const,
          }
        : contrepouvoirs >= 60 && police >= 30 && services >= 35
          ? {
              nom: "Le gouvernement limité de Locke",
              note: "Un pouvoir qui protège et qu'on peut arrêter. C'est la réponse du cours, et elle demande les quatre réglages à la fois.",
              ton: "ok" as const,
            }
          : presse < 25 && separation < 25
            ? {
                nom: "Le cimetière de Bakounine",
                note: "« Un vaste cimetière où viennent s'enterrer toutes les manifestations de la vie individuelle. »",
                ton: "bad" as const,
              }
            : {
                nom: "Un État intermédiaire",
                note: "Rien n'est catastrophique et rien n'est résolu. Pousse la séparation des pouvoirs et regarde ce qui se passe.",
                ton: "warn" as const,
              };

  return (
    <div className="space-y-3">
      <p className="text-sm text-muted-foreground">
        Construis un État en réglant quatre curseurs, et regarde les trois jauges répondre. Essaie
        de supprimer complètement l'État, puis de tout lui donner : les deux extrêmes font chuter la
        même jauge.
      </p>

      <div className="grid gap-3 sm:grid-cols-2">
        <Ctrl
          label="Force de la police et de l'armée"
          value={police}
          min={0}
          max={100}
          step={5}
          onChange={setPolice}
          display={`${police} %`}
          color={PALETTE.red}
        />
        <Ctrl
          label="Étendue des services publics"
          value={services}
          min={0}
          max={100}
          step={5}
          onChange={setServices}
          display={`${services} %`}
          color={PALETTE.green}
        />
        <Ctrl
          label="Séparation des pouvoirs"
          value={separation}
          min={0}
          max={100}
          step={5}
          onChange={setSeparation}
          display={`${separation} %`}
          color={PALETTE.blue}
        />
        <Ctrl
          label="Liberté de la presse"
          value={presse}
          min={0}
          max={100}
          step={5}
          onChange={setPresse}
          display={`${presse} %`}
          color={PALETTE.purple}
        />
      </div>

      <Jauges
        jauges={[
          { label: "Sécurité", valeur: securite, couleur: PALETTE.blue },
          { label: "Liberté réelle des citoyens", valeur: liberteReelle, couleur: PALETTE.green },
          { label: "Risque de tyrannie", valeur: tyrannie, couleur: PALETTE.red },
        ]}
      />

      <Verdict tone={etiquette.ton}>
        <span className="font-semibold">{etiquette.nom}. </span>
        {etiquette.note}
      </Verdict>

      <div className="grid grid-cols-2 gap-2">
        <Stat
          label="Contre-pouvoirs"
          value={`${Math.round(contrepouvoirs)} %`}
          color={PALETTE.blue}
        />
        <Stat
          label="Force sans contrôle"
          value={`${Math.max(0, Math.round(police - contrepouvoirs))} points`}
          color={PALETTE.red}
        />
      </div>

      <Citation auteur="Montesquieu, De l'esprit des lois">
        Pour qu'on ne puisse abuser du pouvoir, il faut que, par la disposition des choses, le
        pouvoir arrête le pouvoir.
      </Citation>
      <p className="text-[11px] leading-snug text-muted-foreground">
        Ce que le réglage t'apprend : la seule manière d'avoir à la fois la sécurité et la liberté
        est de monter la police <em>et</em> les contre-pouvoirs. C'est pourquoi la question « l'État
        est-il un bien ou un mal ? » est mal posée : un État n'est pas une essence, c'est une
        institution — la vraie question est <strong>lequel</strong>.
      </p>
    </div>
  );
}
