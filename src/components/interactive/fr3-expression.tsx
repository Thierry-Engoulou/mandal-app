import { useState } from "react";
import { Ctrl, PALETTE, Stat, Verdict } from "./controls";
import { Citation, Jauges, Qcm, type Question } from "./philo-noyau";

/** Français 3ème — chapitres 7 et 8 : expression écrite et expression orale. */

/* ------------------------------------------------------------------ */
/* 1. Bâtir le schéma narratif                                         */
/* ------------------------------------------------------------------ */

type Etape5 = {
  cle: string;
  nom: string;
  part: number;
  options: ReadonlyArray<{ texte: string; bon: boolean; retour: string }>;
};

const ETAPES5: ReadonlyArray<Etape5> = [
  {
    cle: "initiale",
    nom: "1. Situation initiale",
    part: 13,
    options: [
      {
        texte: "Depuis trois ans, mon oncle tenait une échoppe de réparation au carrefour.",
        bon: true,
        retour:
          "Imparfait, un équilibre qui dure, et une information qui servira plus tard : il est connu dans le quartier.",
      },
      {
        texte:
          "Mon oncle tenait une échoppe depuis trois ans. Il était né à Bafia, avait étudié à Yaoundé, puis travaillé six ans chez un cousin avant de s'installer. Sa femme vendait du poisson. Ils avaient quatre enfants, dont deux au lycée…",
        bon: false,
        retour:
          "Beaucoup trop long. La situation initiale doit tenir dans un huitième du devoir : ici tu auras consommé ta place avant que l'histoire commence.",
      },
      {
        texte: "Un orage emporta la tôle du toit de mon oncle.",
        bon: false,
        retour:
          "C'est déjà l'élément perturbateur. Sans situation initiale, le lecteur ne sait pas ce qui est détruit, et la perte ne lui fait rien.",
      },
    ],
  },
  {
    cle: "perturbateur",
    nom: "2. Élément perturbateur",
    part: 7,
    options: [
      {
        texte: "Un soir de juillet, un orage emporta la tôle de son toit et noya son matériel.",
        bon: true,
        retour:
          "Les deux marques y sont : le complément de temps en tête — « un soir de juillet » — et le passage au passé simple.",
      },
      {
        texte: "Les affaires allaient plutôt bien cette année-là.",
        bon: false,
        retour: "Rien ne rompt l'équilibre : l'histoire n'a toujours pas commencé.",
      },
      {
        texte: "Un soir, il y eut un orage, mais il n'eut aucune conséquence.",
        bon: false,
        retour:
          "Un événement sans conséquence n'est pas un élément perturbateur. Il faut que quelque chose bascule.",
      },
    ],
  },
  {
    cle: "peripeties",
    nom: "3. Péripéties",
    part: 60,
    options: [
      {
        texte:
          "Il sécha les appareils au soleil ; la plupart ne repartirent pas. Il alla voir un prêteur, qui demanda un intérêt impossible. Il pensa fermer.",
        bon: true,
        retour:
          "Trois obstacles de nature différente, et ils MONTENT : l'échec technique, puis l'échec financier, puis le découragement. Le récit touche le fond avant de remonter.",
      },
      {
        texte: "Il chercha une solution pendant plusieurs jours.",
        bon: false,
        retour:
          "Une seule phrase vague pour la partie qui devrait occuper plus de la moitié du devoir. On ne voit aucun obstacle précis.",
      },
      {
        texte: "Heureusement, un ami riche lui donna aussitôt l'argent nécessaire.",
        bon: false,
        retour:
          "Tu as supprimé les péripéties. Plus l'opposant est faible, plus le récit est fade : un héros qui réussit sans difficulté n'intéresse personne.",
      },
    ],
  },
  {
    cle: "denouement",
    nom: "4. Dénouement",
    part: 13,
    options: [
      {
        texte:
          "Trois de ses clients, apprenant la nouvelle, lui avancèrent chacun une petite somme, sans intérêt. En trois semaines, l'échoppe rouvrit.",
        bon: true,
        retour:
          "L'aide était préparée par la situation initiale — « il connaissait tout le monde ». C'est la différence entre un dénouement et un coup de chance.",
      },
      {
        texte: "Heureusement, tout s'arrangea.",
        bon: false,
        retour:
          "C'est la formule que les correcteurs voient le plus, et celle qui coûte le plus. Rien n'est raconté : on ne sait ni qui a aidé ni comment.",
      },
      {
        texte: "Un inconnu passa et lui donna cent mille francs.",
        bon: false,
        retour:
          "Un sauveur qui tombe du ciel ne sauve rien. Place dans ta situation initiale l'élément qui rendra ton dénouement possible.",
      },
    ],
  },
  {
    cle: "finale",
    nom: "5. Situation finale",
    part: 7,
    options: [
      {
        texte:
          "Mon oncle travaille toujours au même carrefour. Mais il a pris l'habitude, quand un client est en difficulté, de réparer d'abord et de se faire payer ensuite.",
        bon: true,
        retour:
          "En apparence rien n'a changé : même oncle, même carrefour. Le changement est INTÉRIEUR, et c'est le plus fort : ayant reçu, il donne.",
      },
      {
        texte: "Mon oncle tenait toujours son échoppe au carrefour, comme avant.",
        bon: false,
        retour:
          "Identique à la situation initiale : il ne s'est donc rien passé, et ton récit tourne en rond. C'est la faute que la figure du cours signale en rouge.",
      },
      {
        texte: "Cette histoire montre qu'il faut toujours s'entraider dans la vie.",
        bon: false,
        retour:
          "Une morale plaquée. Montre le changement par un fait — « il répare d'abord et se fait payer ensuite » — et le lecteur tirera la leçon tout seul.",
      },
    ],
  },
];

const E5_VIDE: Etape5 = { cle: "", nom: "—", part: 0, options: [] };

export function SchemaNarratif() {
  const [rang, setRang] = useState(0);
  const [choisi, setChoisi] = useState<number | null>(null);
  const [faits, setFaits] = useState<string[]>([]);

  const e = ETAPES5[rang] ?? E5_VIDE;
  const o = choisi === null ? null : (e.options[choisi] ?? null);
  const fini = rang >= ETAPES5.length;

  if (fini) {
    return (
      <div className="space-y-3">
        <Verdict tone="ok">Les cinq étapes sont posées.</Verdict>
        <div>
          <p className="mb-1.5 text-xs font-semibold text-foreground">
            Les proportions pour une rédaction de trente lignes
          </p>
          <Jauges
            jauges={ETAPES5.map((x) => ({
              label: x.nom,
              valeur: x.part,
              couleur:
                x.cle === "peripeties"
                  ? PALETTE.green
                  : x.cle === "perturbateur"
                    ? PALETTE.orange
                    : PALETTE.blue,
              ...(x.cle === "peripeties"
                ? { note: "Plus de la moitié du devoir : c'est là qu'est ton récit." }
                : {}),
            }))}
          />
        </div>
        <Citation auteur="à faire au brouillon, avant d'écrire">
          Cinq lignes, cinq minutes, et tu ne te retrouveras pas à court de place avec un
          dénouement expédié en « heureusement tout s'arrangea ».
        </Citation>
        <button
          type="button"
          onClick={() => {
            setRang(0);
            setChoisi(null);
            setFaits([]);
          }}
          className="rounded-lg border border-border px-3 py-1.5 text-xs font-medium text-muted-foreground hover:bg-secondary/60"
        >
          Recommencer
        </button>
      </div>
    );
  }

  return (
    <div className="space-y-3">
      <p className="text-sm text-muted-foreground">
        Un sujet : l'échoppe de ton oncle, détruite par un orage. Construis le schéma au brouillon,
        étape par étape. Chaque mauvais choix te dit ce qu'il coûterait en copie.
      </p>

      <div className="flex flex-wrap gap-1.5">
        {ETAPES5.map((x, i) => (
          <span
            key={x.cle}
            className={
              i < rang
                ? "rounded-full bg-emerald-500/15 px-2.5 py-0.5 text-[11px] font-medium text-emerald-700"
                : i === rang
                  ? "rounded-full bg-primary px-2.5 py-0.5 text-[11px] font-semibold text-primary-foreground"
                  : "rounded-full border border-border px-2.5 py-0.5 text-[11px] text-muted-foreground"
            }
          >
            {x.nom}
          </span>
        ))}
      </div>

      {faits.length > 0 ? (
        <div className="rounded-lg border border-border bg-secondary/20 p-2.5">
          {faits.map((f, i) => (
            <p key={i} className="text-xs leading-relaxed text-muted-foreground">
              {f}
            </p>
          ))}
        </div>
      ) : null}

      <div className="rounded-lg border border-border bg-background p-3">
        <p className="text-[11px] font-semibold uppercase tracking-wide text-muted-foreground">
          {e.nom}
        </p>
        <ul className="mt-2 space-y-1.5">
          {e.options.map((x, i) => {
            const actif = choisi === i;
            const cls = !actif
              ? "border-border bg-background hover:bg-secondary/60"
              : x.bon
                ? "border-emerald-500/40 bg-emerald-500/10"
                : "border-rose-500/40 bg-rose-500/10";
            return (
              <li key={x.texte.slice(0, 24)}>
                <button
                  type="button"
                  onClick={() => setChoisi(i)}
                  className={`w-full rounded-lg border px-2.5 py-1.5 text-left text-xs leading-snug ${cls}`}
                >
                  {x.texte}
                </button>
              </li>
            );
          })}
        </ul>
        {o ? (
          <div className="mt-2 space-y-2">
            <p
              className="text-xs leading-snug"
              style={{ color: o.bon ? PALETTE.green : PALETTE.red }}
            >
              {o.retour}
            </p>
            {o.bon ? (
              <button
                type="button"
                onClick={() => {
                  setFaits((f) => [...f, o.texte]);
                  setRang((r) => r + 1);
                  setChoisi(null);
                }}
                className="rounded-lg bg-primary px-3 py-1.5 text-xs font-semibold text-primary-foreground"
              >
                Étape suivante
              </button>
            ) : null}
          </div>
        ) : null}
      </div>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* 2. Les six cases du schéma actanciel                                */
/* ------------------------------------------------------------------ */

const ACTANTS: ReadonlyArray<Question> = [
  {
    id: "a1",
    enonce: "« Ville cruelle ». Qui est le SUJET du schéma actanciel ?",
    options: [
      { texte: "Banda", bonne: true, retour: "Celui qui veut quelque chose et qui agit. C'est en général le héros." },
      { texte: "L'inspecteur", bonne: false, retour: "Il fait obstacle : c'est un opposant, pas le sujet." },
      { texte: "La ville de Tanga", bonne: false, retour: "Elle n'agit pas pour obtenir quelque chose : elle résiste." },
    ],
  },
  {
    id: "a2",
    enonce: "Quel est l'OBJET de sa quête ?",
    options: [
      {
        texte: "Vendre sa récolte de cacao pour obtenir de l'argent.",
        bonne: true,
        retour:
          "Précis et vérifiable : à chaque page, on peut dire s'il s'en rapproche ou s'en éloigne. C'est la marque d'un bon objet.",
      },
      {
        texte: "Le bonheur",
        bonne: false,
        retour:
          "Trop vague. Si tu n'arrives pas à nommer un objet concret, ton récit n'a pas encore d'histoire.",
      },
      { texte: "Sa mère", bonne: false, retour: "Sa mère est une destinataire, pas l'objet de la quête." },
    ],
  },
  {
    id: "a3",
    enonce: "Qu'est-ce qui le met en route — le DESTINATEUR ?",
    options: [
      {
        texte: "Sa mère malade et le mariage qu'il veut conclure.",
        bonne: true,
        retour:
          "Le destinateur n'est pas forcément une personne qui donne un ordre : un devoir, un besoin, une promesse jouent le même rôle.",
      },
      { texte: "L'inspecteur", bonne: false, retour: "Il arrive après, et il s'oppose." },
    ],
  },
  {
    id: "a4",
    enonce: "Quels sont les OPPOSANTS, et que remarques-tu ?",
    options: [
      {
        texte:
          "L'inspecteur, l'administration coloniale, le système des prix, la ville elle-même : ce sont surtout des MÉCANISMES, pas des méchants.",
        bonne: true,
        retour:
          "C'est ce qui fait la force du roman, et le dire en copie montre qu'on a compris autre chose qu'une histoire. Banda n'a ni adversaire à combattre ni faute à réparer : il a un mécanisme, et le mécanisme ne discute pas.",
      },
      {
        texte: "L'inspecteur, qui est un homme méchant.",
        bonne: false,
        retour:
          "Le texte ne dit nulle part qu'il est méchant : il fait son travail sans regarder. C'est précisément ce qui est terrible.",
      },
      { texte: "Il n'y a pas d'opposant", bonne: false, retour: "Sans opposant, il n'y aurait pas de roman." },
    ],
  },
  {
    id: "a5",
    enonce: "Un actant peut-il être autre chose qu'une personne ?",
    options: [
      {
        texte:
          "Oui : un actant est un RÔLE. La pauvreté, la peur, une administration, un objet peuvent le tenir.",
        bonne: true,
        retour:
          "C'est ce qui rend le schéma utile. Si tu ne cherches que des gens, tu manques les opposants les plus intéressants.",
      },
      { texte: "Non, il faut des personnages", bonne: false, retour: "Alors « Ville cruelle » n'aurait presque pas d'opposants." },
    ],
  },
  {
    id: "a6",
    enonce: "Quelle est la règle d'or du schéma actanciel pour tes propres rédactions ?",
    options: [
      {
        texte: "Plus l'opposant est fort, meilleur est le récit.",
        bonne: true,
        retour:
          "Un héros qui réussit sans difficulté n'intéresse personne. Et si tu n'arrives à nommer ni l'objet ni l'opposant, ne commence pas à écrire : remplis d'abord les six cases.",
      },
      { texte: "Il faut le plus d'adjuvants possible", bonne: false, retour: "L'inverse : trop d'aide tue le récit." },
    ],
  },
];

export function SchemaActanciel() {
  return (
    <Qcm
      consigne="Les six rôles, appliqués à « Ville cruelle ». Un actant n'est pas forcément une personne : c'est un rôle dans l'histoire."
      questions={ACTANTS}
      conclusion={
        <>
          Les six cases : <strong>sujet</strong> (qui agit), <strong>objet</strong> (ce qu'il veut),{" "}
          <strong>destinateur</strong> (ce qui le met en route), <strong>destinataire</strong> (qui
          en profitera), <strong>adjuvants</strong> (ce qui aide), <strong>opposants</strong> (ce
          qui résiste). Avant d'écrire une rédaction, remplis-les. Si l'objet reste vague ou si
          l'opposant est trop faible, ton récit n'a pas encore d'histoire.
        </>
      }
    />
  );
}

/* ------------------------------------------------------------------ */
/* 3. La même scène, trois points de vue                               */
/* ------------------------------------------------------------------ */

type Vue = {
  cle: "externe" | "interne" | "omniscient";
  nom: string;
  texte: string;
  saitLecteur: number;
  saitPersonnage: number;
  effet: string;
};

const VUES: ReadonlyArray<Vue> = [
  {
    cle: "externe",
    nom: "Focalisation externe",
    texte:
      "La femme s'arrêta devant la porte de la classe. Elle regarda sa montre, puis la porte, puis sa montre encore. Elle fit trois pas en arrière, s'adossa au mur et attendit.",
    saitLecteur: 30,
    saitPersonnage: 100,
    effet:
      "Le narrateur est une caméra : on voit, on entend, et rien de plus. Les gestes restent inexpliqués, et c'est voulu. Effet : le mystère et la tension. C'est le point de vue des débuts de romans policiers.",
  },
  {
    cle: "interne",
    nom: "Focalisation interne",
    texte:
      "Elle s'arrêta devant la porte. Il était onze heures vingt : le cours ne finirait pas avant midi. Entrer maintenant, c'était faire se retourner trente élèves. Elle recula de trois pas, s'adossa au mur et décida d'attendre. Quarante minutes. Elle aurait pu téléphoner avant de venir.",
    saitLecteur: 100,
    saitPersonnage: 100,
    effet:
      "On entre dans la tête d'UN SEUL personnage. Les mêmes gestes reçoivent une explication : elle calcule, elle recule par égard. Effet : l'identification. Et attention, ce n'est pas lié au « je » : on est en focalisation interne avec « elle ».",
  },
  {
    cle: "omniscient",
    nom: "Focalisation omnisciente",
    texte:
      "Elle s'arrêta devant la porte, calculant qu'il restait quarante minutes de cours. Derrière le battant, le professeur l'avait entendue et espérait qu'elle entrerait, car il cherchait depuis un quart d'heure un prétexte pour écourter sa leçon. Au fond de la classe, un élève avait reconnu le pas de sa mère. Aucun des trois ne se doutait de ce que les deux autres pensaient.",
    saitLecteur: 100,
    saitPersonnage: 45,
    effet:
      "Le narrateur sait tout : toutes les têtes, le passé, l'ailleurs. Effet : l'ironie. Trois personnes à deux mètres les unes des autres, chacune empêchée par une idée fausse — et seul le lecteur voit le malentendu complet.",
  },
];

const RUPTURES: ReadonlyArray<Question> = [
  {
    id: "rp1",
    enonce:
      "Un récit est mené en focalisation interne sur Awa. Quelle phrase rompt le point de vue ?",
    precision:
      "« Awa descendit du car. Elle reconnut l'odeur de la terre mouillée et se mit à marcher plus vite. Pendant ce temps, sa grand-mère pensait qu'elle était bien imprudente. Awa poussa la porte. »",
    options: [
      {
        texte: "« Pendant ce temps, sa grand-mère pensait qu'elle était bien imprudente. »",
        bonne: true,
        retour:
          "On vient de sortir de la tête d'Awa sans prévenir. C'est la maladresse la plus sanctionnée en rédaction, et elle est difficile à voir quand on est l'auteur.",
      },
      {
        texte: "« Elle reconnut l'odeur de la terre mouillée »",
        bonne: false,
        retour: "C'est une sensation d'Awa : on reste dans sa tête.",
      },
      { texte: "« Awa poussa la porte. »", bonne: false, retour: "Un geste d'Awa, vu depuis Awa. Rien ne rompt." },
    ],
  },
  {
    id: "rp2",
    enonce: "Comment éviter cette faute dans ta propre rédaction ?",
    options: [
      {
        texte:
          "Choisir le point de vue au brouillon, le noter, et s'y tenir jusqu'au bout.",
        bonne: true,
        retour:
          "Une ligne au brouillon — « focalisation interne sur Awa » — et tu te relis en cherchant toute phrase qui dit ce qu'un autre pense.",
      },
      { texte: "Écrire à la première personne", bonne: false, retour: "Le « je » aide, mais on peut aussi rompre avec lui — en racontant ce qu'un autre pense sans l'avoir appris." },
    ],
  },
];

const VUE_DEFAUT: Vue = VUES[0] ?? {
  cle: "externe",
  nom: "—",
  texte: "—",
  saitLecteur: 0,
  saitPersonnage: 0,
  effet: "—",
};

export function PointDeVue() {
  const [cle, setCle] = useState<"externe" | "interne" | "omniscient">("externe");
  const v = VUES.find((x) => x.cle === cle) ?? VUE_DEFAUT;

  return (
    <div className="space-y-4">
      <div className="space-y-3">
        <p className="text-sm text-muted-foreground">
          La même scène — une femme s'arrête devant une porte de classe et recule de trois pas —
          racontée de trois façons. Change la focalisation et regarde ce que le lecteur sait.
        </p>

        <div className="flex flex-wrap gap-1.5">
          {VUES.map((x) => (
            <button
              key={x.cle}
              type="button"
              onClick={() => setCle(x.cle)}
              className={
                cle === x.cle
                  ? "rounded-lg bg-primary px-2.5 py-1 text-xs font-semibold text-primary-foreground"
                  : "rounded-lg border border-border px-2.5 py-1 text-xs text-muted-foreground hover:bg-secondary/60"
              }
            >
              {x.nom}
            </button>
          ))}
        </div>

        <p className="rounded-lg border border-border bg-background p-3 text-sm leading-relaxed text-foreground">
          {v.texte}
        </p>

        <Jauges
          jauges={[
            { label: "Ce que sait le LECTEUR", valeur: v.saitLecteur, couleur: PALETTE.blue },
            { label: "Ce que savent les PERSONNAGES", valeur: v.saitPersonnage, couleur: PALETTE.orange },
          ]}
        />

        <Verdict tone="ok">{v.effet}</Verdict>

        <div className="grid grid-cols-3 gap-2">
          <Stat label="Têtes visitées" value={cle === "externe" ? "aucune" : cle === "interne" ? "une" : "plusieurs"} color={PALETTE.purple} />
          <Stat
            label="Le lecteur en sait"
            value={cle === "externe" ? "moins" : cle === "interne" ? "autant" : "plus"}
            color={PALETTE.blue}
          />
          <Stat label="Le geste de reculer" value={cle === "externe" ? "mystère" : cle === "interne" ? "délicatesse" : "erreur"} color={PALETTE.green} />
        </div>

        <Citation auteur="le repère qui ne trompe pas">
          Pour trouver le point de vue d'un texte, une seule question : dans combien de têtes
          entre-t-on ? Aucune, externe. Une seule, interne. Plusieurs, omnisciente. Et la
          focalisation interne n'est pas liée au « je » : ce qui compte n'est pas le pronom.
        </Citation>
      </div>

      <div className="border-t border-border pt-3">
        <p className="mb-2 text-xs font-semibold text-foreground">
          Mode correcteur — trouver la rupture de point de vue
        </p>
        <Qcm
          consigne="Un texte avec une rupture cachée au milieu. Trouve la phrase qui sort de la tête du personnage sans prévenir."
          questions={RUPTURES}
          conclusion={
            <>
              Changer de point de vue au milieu d'un récit sans raison est une maladresse que les
              correcteurs sanctionnent, et elle se glisse facilement : on sait ce que tous nos
              personnages pensent, puisqu'on les a inventés. Note ton choix au brouillon, et relis
              en cherchant toute phrase qui dit ce qu'un autre pense.
            </>
          }
        />
      </div>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* 4. L'atelier de l'accroche                                          */
/* ------------------------------------------------------------------ */

const ORAL: ReadonlyArray<Question> = [
  {
    id: "o1",
    enonce: "Tu dois raconter une nuit passée enfermé dans la cour de l'école. Quelle accroche ?",
    options: [
      {
        texte: "Il y a deux ans, j'ai passé une nuit entière enfermé dans la cour de mon école.",
        bonne: true,
        retour:
          "L'auditoire est pris dès la première phrase. Une accroche entre dans l'histoire : elle ne l'annonce pas.",
      },
      {
        texte:
          "Alors euh, bonjour, donc je vais vous parler aujourd'hui d'une expérience personnelle que j'ai vécue il y a assez longtemps…",
        bonne: false,
        retour:
          "Trois fautes en une phrase : les tics, l'annonce molle — tout le monde a compris que c'est un exposé — et l'approximation sur la date, qui fait douter de tout le reste.",
      },
      {
        texte: "Je ne sais pas si mon histoire va vous intéresser, mais je vais essayer.",
        bonne: false,
        retour:
          "Ne t'excuse jamais au début. Tu viens de dire à l'auditoire qu'il peut décrocher sans rien perdre.",
      },
    ],
  },
  {
    id: "o2",
    enonce: "Après l'accroche, que viennent faire les trois phrases suivantes ?",
    options: [
      {
        texte: "Situer : où, quand, qui. Trois phrases, pas plus.",
        bonne: true,
        retour:
          "« C'était un vendredi. J'étais resté pour ranger la bibliothèque avec deux camarades. Ils sont partis avant moi. » Tout est posé.",
      },
      { texte: "Raconter la fin pour donner envie", bonne: false, retour: "Donner la fin au début supprime toute raison d'écouter." },
      { texte: "Remercier l'auditoire", bonne: false, retour: "Les remerciements vont à la fin, s'ils vont quelque part." },
    ],
  },
  {
    id: "o3",
    enonce: "Pourquoi annoncer son plan à l'oral, alors qu'on ne le fait pas dans un récit écrit ?",
    options: [
      {
        texte:
          "Parce que l'auditeur ne voit pas les paragraphes : il faut lui dire où on l'emmène pour qu'il puisse suivre.",
        bonne: true,
        retour:
          "« Je vais vous raconter d'abord comment je me suis retrouvé seul, ensuite ce que j'ai fait, et enfin ce que j'en ai gardé. »",
      },
      { texte: "Pour faire plus long", bonne: false, retour: "Un plan annoncé fait au contraire gagner du temps." },
    ],
  },
  {
    id: "o4",
    enonce: "Que dit-on de la ponctuation du récit oral par rapport à l'écrit ?",
    options: [
      {
        texte:
          "Les phrases doivent être plus courtes, et les répétitions d'un mot clé deviennent utiles au lieu d'être une faute.",
        bonne: true,
        retour:
          "Tout découle du fait que l'auditeur n'entend qu'une fois, alors que le lecteur peut relire.",
      },
      { texte: "Rien ne change", bonne: false, retour: "Une phrase de cinq lignes se lit ; à l'oral, elle se perd." },
    ],
  },
  {
    id: "o5",
    enonce: "Quelle chute choisir pour fermer ?",
    options: [
      {
        texte: "Une phrase qui dit pourquoi tu as raconté cela. C'est ce qu'on retient.",
        bonne: true,
        retour:
          "Comme la situation finale d'un récit écrit : ce qui a changé. Et écris-la en entier sur ta fiche, car c'est le second moment où le trac fait des dégâts.",
      },
      { texte: "« Voilà, c'est tout, merci. »", bonne: false, retour: "L'auditoire se souviendra de cette phrase-là, et de rien d'autre." },
      { texte: "Un résumé de ce qu'on vient de dire", bonne: false, retour: "On vient de l'entendre. Le résumé final est une perte de temps." },
    ],
  },
  {
    id: "o6",
    enonce:
      "Préparer un oral, est-ce l'écrire mot à mot ?",
    options: [
      {
        texte:
          "Non : on note sur une fiche l'accroche et la chute en entier, et le reste en trois mots par étape. Puis on parle.",
        bonne: true,
        retour:
          "Un exposé lu s'entend dès la troisième phrase, et il ennuie. Mais l'accroche et la chute écrites te donnent un départ sûr et une arrivée sûre.",
      },
      { texte: "Oui, c'est plus prudent", bonne: false, retour: "C'est plus prudent et c'est raté : on perd le regard, l'intonation et l'auditoire." },
    ],
  },
];

export function RaconterOral() {
  return (
    <Qcm
      consigne="Six choix pour construire un récit oral : l'accroche, la situation, le plan annoncé, la longueur des phrases, la chute, et la préparation."
      questions={ORAL}
      conclusion={
        <>
          Quatre temps, deux minutes : une <strong>accroche</strong> qui entre dans l'histoire,
          une <strong>situation</strong> en trois phrases, le <strong>récit</strong> guidé par des
          mots de liaison, une <strong>chute</strong> qui dit pourquoi tu as raconté cela. Et les
          cinq tics à faire tomber : « euh », « voilà », « en fait », le débit trop rapide, le
          regard au sol.
        </>
      }
    />
  );
}

/* ------------------------------------------------------------------ */
/* 5. Préparer le compte rendu de film                                 */
/* ------------------------------------------------------------------ */

const CR: ReadonlyArray<Question> = [
  {
    id: "cr1",
    enonce: "Premier moment : la fiche technique. Que contient-elle, et en combien de temps ?",
    options: [
      {
        texte: "Titre, réalisateur, année, pays, genre, durée — en quatre phrases, trente secondes.",
        bonne: true,
        retour: "C'est l'état civil du film. Au-delà de trente secondes, tu perds l'auditoire avant d'avoir commencé.",
      },
      {
        texte: "Toute l'histoire du cinéma du pays concerné",
        bonne: false,
        retour: "Hors sujet, et tu auras consommé la moitié de ton temps.",
      },
    ],
  },
  {
    id: "cr2",
    enonce: "Deuxième moment : le sujet. Jusqu'où raconter ?",
    options: [
      {
        texte: "Jusqu'au problème, en s'arrêtant avant le dénouement. La formule « le film raconte comment… » y oblige.",
        bonne: true,
        retour:
          "Un compte rendu informe ET donne envie. Si tu racontes la fin, ton auditoire n'a plus aucune raison de voir le film.",
      },
      { texte: "Tout, fin comprise, c'est plus clair", bonne: false, retour: "Tu viens de supprimer la raison d'écouter la suite." },
      { texte: "Rien, pour ne rien dévoiler", bonne: false, retour: "Alors personne ne saura de quoi parle le film." },
    ],
  },
  {
    id: "cr3",
    enonce:
      "Trie ces trois phrases : laquelle relève de l'ANALYSE, et non du résumé ni de l'avis ?",
    options: [
      {
        texte:
          "Le film montre les rapports entre les hommes et les femmes dans un quartier populaire de Yaoundé.",
        bonne: true,
        retour:
          "C'est le thème : ce que le film dit de la société. C'est la partie qui distingue un compte rendu d'un bavardage.",
      },
      {
        texte: "Une jeune fille fait un vœu et se transforme en homme.",
        bonne: false,
        retour: "C'est du résumé : tu racontes ce qui se passe.",
      },
      { texte: "J'ai trouvé ce film très drôle.", bonne: false, retour: "C'est l'avis, et il viendra en cinquième position." },
    ],
  },
  {
    id: "cr4",
    enonce:
      "Quatrième moment : comment le film montre. Faut-il être spécialiste ?",
    options: [
      {
        texte:
          "Non : il faut avoir remarqué quelque chose. Les images, la musique, le rythme, le jeu, la langue employée — deux ou trois remarques suffisent.",
        bonne: true,
        retour:
          "« Les personnages parlent à la caméra », « le mélange du français, de l'anglais et du camfranglais » : voilà des remarques à la portée de tous, et elles se remarquent.",
      },
      { texte: "Oui, il faut connaître la technique du cinéma", bonne: false, retour: "Quelques mots suffisent, et tu les apprendras au module 5." },
    ],
  },
  {
    id: "cr5",
    enonce: "Cinquième moment : l'avis. Lequel est le plus crédible ?",
    options: [
      {
        texte:
          "Deux points forts précis — l'inventivité de la langue, les personnages féminins — et une réserve honnête sur le rythme.",
        bonne: true,
        retour:
          "Un auditoire croit un avis nuancé et se méfie d'un avis unanime. La réserve te rend crédible sur les éloges.",
      },
      { texte: "« Tout est parfait dans ce film. »", bonne: false, retour: "Personne ne te croira, et tu n'auras rien appris à personne." },
      { texte: "« J'ai aimé. »", bonne: false, retour: "Pas « j'ai aimé », mais « j'ai aimé PARCE QUE »." },
    ],
  },
  {
    id: "cr6",
    enonce: "Sur ta fiche de préparation, que faut-il écrire EN ENTIER ?",
    options: [
      {
        texte: "L'accroche et la chute, plus les noms propres et les dates.",
        bonne: true,
        retour:
          "Les deux moments où l'on doit être précis, et les deux où le trac fait le plus de dégâts. Les noms propres et les dates sont les seules choses qu'on oublie vraiment.",
      },
      { texte: "Tout le texte, pour ne rien oublier", bonne: false, retour: "Un compte rendu lu s'entend dès la troisième phrase." },
      { texte: "Rien, il faut improviser", bonne: false, retour: "L'improvisation complète produit des « euh » et des oublis de noms." },
    ],
  },
];

export function CompteRenduFilm() {
  return (
    <Qcm
      consigne="Les cinq moments du compte rendu, dans l'ordre, avec à chaque fois l'erreur que les élèves commettent. Un compte rendu tient en trois à cinq minutes."
      questions={CR}
      conclusion={
        <>
          Fiche technique, sujet sans la fin, ce que le film montre, comment il le montre, et ton
          avis justifié. Prépare une <strong>fiche</strong>, pas un texte : les cinq moments en
          trois mots chacun, l'accroche et la chute rédigées, et les noms propres notés. Et garde en
          tête la différence qui se remarque : le <strong>réalisateur</strong> fait le film, le{" "}
          <strong>producteur</strong> le finance.
        </>
      }
    />
  );
}

/* ------------------------------------------------------------------ */
/* 6. La console de l'orateur                                          */
/* ------------------------------------------------------------------ */

export function VoixEtCorps() {
  const [volume, setVolume] = useState(50);
  const [debit, setDebit] = useState(50);
  const [articulation, setArticulation] = useState(50);
  const [intonation, setIntonation] = useState(50);
  const [posture, setPosture] = useState<Record<string, boolean>>({});
  const [silence, setSilence] = useState(0);

  // audibilité : le volume et l'articulation portent la voix
  const audible = Math.round(Math.min(100, volume * 0.62 + articulation * 0.45));
  // compréhension : un débit trop rapide détruit tout, un débit trop lent endort
  const ecartDebit = Math.abs(debit - 42);
  const compris = Math.round(
    Math.min(100, Math.max(0, audible * 0.6 + 40 - ecartDebit * 0.9)),
  );
  // attention : l'intonation et la posture la tiennent
  const bonusPosture =
    (posture["pieds"] ? 8 : 0) +
    (posture["mains"] ? 8 : 0) +
    (posture["regard"] ? 14 : 0) +
    (posture["fiche"] ? 10 : 0);
  const attention = Math.round(
    Math.min(100, Math.max(0, 18 + intonation * 0.42 + bonusPosture - Math.max(0, debit - 60) * 0.7)),
  );

  const diagnostic =
    volume < 30
      ? "Le dernier rang ne t'entend pas. Choisis mentalement la personne la plus éloignée et parle pour elle : tout le reste de la salle entendra."
      : debit > 70
        ? "Trop rapide. C'est le signe du trac, et il rend inaudible. Respire avant de commencer, et fais une pause après chaque phrase importante."
        : debit < 22
          ? "Trop lent : l'auditoire s'endort. Le bon repère est de pouvoir respirer normalement en parlant."
          : articulation < 35
            ? "Ouvre la bouche. C'est bête, et c'est le conseil qui change le plus de choses : la plupart des oraux inaudibles le sont par des lèvres qui ne bougent pas assez."
            : intonation < 30
              ? "Voix plate. Monte à la question, descends à la fin d'une affirmation, et ralentis sur ce qui compte."
              : attention < 55
                ? "La voix est bonne, mais le corps ne suit pas. Règle la posture ci-dessous."
                : "Réglage juste. Tu es audible, compris, et l'auditoire suit.";

  return (
    <div className="space-y-3">
      <p className="text-sm text-muted-foreground">
        Quatre curseurs et un auditoire qui réagit. Monte le débit : les visages du fond décrochent.
        Baisse le volume : le dernier rang s'éteint.
      </p>

      <div className="grid gap-3 sm:grid-cols-2">
        <Ctrl label="Volume" value={volume} min={0} max={100} step={5} onChange={setVolume} display={`${volume} %`} color={PALETTE.blue} />
        <Ctrl label="Débit" value={debit} min={0} max={100} step={5} onChange={setDebit} display={`${debit} %`} color={PALETTE.orange} />
        <Ctrl label="Articulation" value={articulation} min={0} max={100} step={5} onChange={setArticulation} display={`${articulation} %`} color={PALETTE.green} />
        <Ctrl label="Intonation" value={intonation} min={0} max={100} step={5} onChange={setIntonation} display={`${intonation} %`} color={PALETTE.purple} />
      </div>

      <Jauges
        jauges={[
          { label: "Salle qui t'entend", valeur: audible, couleur: PALETTE.blue },
          { label: "Salle qui te comprend", valeur: compris, couleur: PALETTE.green },
          { label: "Salle qui t'écoute encore", valeur: attention, couleur: PALETTE.purple },
        ]}
      />

      <Verdict tone={attention >= 70 && compris >= 70 ? "ok" : attention >= 45 ? "warn" : "bad"}>
        {diagnostic}
      </Verdict>

      <div>
        <p className="mb-1.5 text-xs font-semibold text-foreground">La posture</p>
        <div className="grid gap-1.5 sm:grid-cols-2">
          {[
            { cle: "pieds", label: "Les deux pieds au sol, sans se balancer" },
            { cle: "mains", label: "Les mains visibles et libres" },
            { cle: "regard", label: "Balayer la salle, trois à quatre secondes par zone" },
            { cle: "fiche", label: "Une fiche à une main, à hauteur de la taille" },
          ].map((p) => {
            const on = Boolean(posture[p.cle]);
            return (
              <button
                key={p.cle}
                type="button"
                onClick={() => setPosture((x) => ({ ...x, [p.cle]: !x[p.cle] }))}
                className={
                  on
                    ? "rounded-lg border border-emerald-500/40 bg-emerald-500/10 px-2.5 py-1.5 text-left text-xs text-foreground"
                    : "rounded-lg border border-border bg-background px-2.5 py-1.5 text-left text-xs text-muted-foreground hover:bg-secondary/50"
                }
              >
                {on ? "✓ " : "○ "}
                {p.label}
              </button>
            );
          })}
        </div>
      </div>

      <div className="space-y-2 border-t border-border pt-3">
        <p className="text-xs font-semibold text-foreground">Le silence avant de commencer</p>
        <Ctrl
          label="Secondes de silence, après s'être placé"
          value={silence}
          min={0}
          max={6}
          step={1}
          onChange={setSilence}
          display={`${silence} s`}
          color={PALETTE.slate}
        />
        <Verdict tone={silence >= 2 && silence <= 4 ? "ok" : "warn"}>
          {silence === 0
            ? "Tu commences en marchant : personne n'est prêt, et tes premières phrases sont perdues."
            : silence === 1
              ? "Un peu court. Deux secondes suffisent à faire taire la salle."
              : silence <= 4
                ? "C'est le bon réglage. Deux à quatre secondes paraissent une éternité de l'intérieur et passent inaperçues de l'extérieur — c'est tout le paradoxe du silence."
                : "Au-delà de cinq secondes, la salle se demande si tu as oublié ton texte."}
        </Verdict>
      </div>

      <Citation auteur="la règle des trois lenteurs">
        Quand tu es ému ou pressé, applique mécaniquement : parle plus lentement que tu n'en as
        envie, fais des pauses plus longues que tu ne crois nécessaire, articule plus que
        d'ordinaire. Ce qui te paraîtra exagéré de l'intérieur paraîtra juste de l'extérieur.
      </Citation>
    </div>
  );
}
