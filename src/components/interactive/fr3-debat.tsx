import { useState } from "react";
import { PALETTE, Choice, Ctrl, Verdict } from "./controls";
import { Citation } from "./philo-noyau";

/** Français 3ème — chapitres 15 et 16 : expression écrite et orale. */

/* ------------------------------------------------------------------ */
/* 1. Du récit à l'argument                                            */
/* ------------------------------------------------------------------ */

type Flou = {
  mot: string;
  demande: string;
  exemples: ReadonlyArray<string>;
};

type Temoignage = {
  id: string;
  titre: string;
  brut: string;
  flous: ReadonlyArray<Flou>;
  /** Les jugements répétés à supprimer. */
  jugements: ReadonlyArray<string>;
  conclusionAttendue: string;
  reecriture: string;
};

const TEMOIGNAGES: ReadonlyArray<Temoignage> = [
  {
    id: "t1",
    titre: "Les ordures du quartier",
    brut: "Dans mon quartier il y a des problèmes avec les ordures depuis longtemps. C'est vraiment catastrophique et les gens ne savent plus quoi faire. Ma mère dit toujours que ce n'est pas normal. Moi aussi je trouve que c'est pas normal. Il faudrait que ça change parce que c'est devenu invivable et personne ne fait rien du tout.",
    flous: [
      {
        mot: "des problèmes",
        demande: "Quel fait précis ? Un objet, une date.",
        exemples: [
          "le bac à ordures a été retiré en janvier",
          "le camion ne passe plus depuis six semaines",
        ],
      },
      {
        mot: "depuis longtemps",
        demande: "Depuis quand exactement ?",
        exemples: ["depuis janvier dernier", "depuis la fin de la saison sèche"],
      },
      {
        mot: "les gens",
        demande: "Qui ? Où ? À quelle distance ?",
        exemples: [
          "les habitants déposent leurs sacs au pied du poteau électrique, à trente mètres de chez nous",
          "les voisins les entassent devant l'école",
        ],
      },
      {
        mot: "personne ne fait rien",
        demande: "Quel fait vérifiable le prouve ?",
        exemples: [
          "ma mère a écrit deux fois à la mairie et n'a jamais reçu de réponse",
          "le bac n'a jamais été remplacé",
        ],
      },
    ],
    jugements: ["catastrophique", "pas normal", "invivable"],
    conclusionAttendue:
      "Un quartier n'est pas sale parce que ses habitants le veulent. Il le devient quand on retire un bac et qu'on oublie de le remettre.",
    reecriture:
      "Le bac à ordures de notre carrefour a été retiré en janvier dernier, et il n'a jamais été remplacé. Depuis, les habitants déposent leurs sacs au pied du poteau électrique, à trente mètres de chez nous. En saison des pluies, l'eau emporte le tas jusque dans la cour de l'école voisine ; les enfants jouent autour. Ma mère a écrit deux fois à la mairie. Elle n'a jamais reçu de réponse.\n\nUn quartier n'est pas sale parce que ses habitants le veulent. Il le devient quand on retire un bac et qu'on oublie de le remettre.",
  },
  {
    id: "t2",
    titre: "La route de l'école",
    brut: "C'était très dur d'aller à l'école. Je marchais beaucoup et j'étais fatigué. Les professeurs ne comprenaient pas. C'était horrible et vraiment pas juste.",
    flous: [
      {
        mot: "très dur",
        demande: "Une heure, une distance.",
        exemples: ["je partais à cinq heures", "deux heures de marche, matin et soir"],
      },
      {
        mot: "j'étais fatigué",
        demande: "Une sensation physique précise.",
        exemples: [
          "j'arrivais la tête vide et les pieds brûlants",
          "je m'endormais au premier cours",
        ],
      },
      {
        mot: "ne comprenaient pas",
        demande: "Qu'ont-ils dit ou fait, exactement ?",
        exemples: [
          "le professeur croyait que je n'écoutais pas",
          "on m'a mis au fond de la classe",
        ],
      },
    ],
    jugements: ["horrible", "pas juste"],
    conclusionAttendue: "C'est ainsi que l'on perd des élèves sans jamais savoir pourquoi.",
    reecriture:
      "Je l'ai fait pendant trois ans. Je partais à cinq heures et j'arrivais en classe la tête vide, les pieds brûlants. Le professeur croyait que je n'écoutais pas ; il m'a placé au fond de la classe, où j'entendais encore moins.\n\nC'est ainsi que l'on perd des élèves sans jamais savoir pourquoi.",
  },
  {
    id: "t3",
    titre: "L'inondation de septembre",
    brut: "Chez nous l'eau monte chaque année et c'est une catastrophe terrible. Tout le monde perd des choses. C'est à cause de la pluie et c'est affreux.",
    flous: [
      {
        mot: "l'eau monte",
        demande: "Jusqu'où ? Pendant combien de temps ?",
        exemples: [
          "l'eau est montée jusqu'au troisième bloc du mur, et elle est restée quatre jours",
          "elle atteint le rebord des fenêtres",
        ],
      },
      {
        mot: "perd des choses",
        demande: "Quels objets, à quel prix ?",
        exemples: [
          "ma sœur a perdu ses cahiers de l'année et son uniforme",
          "les matelas ont été jetés",
        ],
      },
      {
        mot: "à cause de la pluie",
        demande: "Est-ce bien la cause ? Qu'as-tu vu dans le caniveau ?",
        exemples: [
          "le caniveau était bouché par les sachets, et l'eau ne pouvait plus descendre",
          "la rigole n'a pas été curée depuis deux ans",
        ],
      },
    ],
    jugements: ["catastrophe terrible", "affreux"],
    conclusionAttendue:
      "On accuse la pluie chaque année, et chaque année le caniveau n'a pas été curé.",
    reecriture:
      "En septembre dernier, l'eau est montée jusqu'au troisième bloc du mur et elle est restée quatre jours. Ma sœur a perdu ses cahiers de l'année et son uniforme ; nous avons jeté deux matelas. Quand l'eau s'est retirée, j'ai regardé la rigole : elle était pleine de sachets jusqu'au bord, et elle n'avait pas été curée depuis deux ans.\n\nOn accuse la pluie chaque année, et chaque année le caniveau n'a pas été curé.",
  },
  {
    id: "t4",
    titre: "Le plant de manguier",
    brut: "On a planté des arbres à l'école un jour et après ils sont morts. C'est dommage et ça ne sert à rien du tout.",
    flous: [
      {
        mot: "un jour",
        demande: "Quand, et dans quelles circonstances ?",
        exemples: [
          "un matin de juin, pour la journée de l'arbre, avec des photographes",
          "le jour de la fête de la jeunesse",
        ],
      },
      {
        mot: "ils sont morts",
        demande: "Combien, et au bout de combien de temps ?",
        exemples: [
          "sur les quarante plants, il en restait six à la rentrée suivante",
          "tous étaient secs avant la fin des vacances",
        ],
      },
      {
        mot: "ça ne sert à rien",
        demande: "Qu'est-ce qui a manqué, précisément ?",
        exemples: [
          "personne n'était chargé de les arroser pendant les vacances",
          "les chèvres sont passées par le trou de la clôture",
        ],
      },
    ],
    jugements: ["dommage", "ne sert à rien"],
    conclusionAttendue:
      "Planter prend une matinée ; faire pousser prend trois saisons, et c'est la seule chose que personne n'organise.",
    reecriture:
      "Un matin de juin, pour la journée de l'arbre, nous avons planté quarante manguiers dans la cour, devant les photographes. À la rentrée suivante, il en restait six. Personne n'avait été chargé de les arroser pendant les vacances, et les chèvres entraient par le trou de la clôture.\n\nPlanter prend une matinée ; faire pousser prend trois saisons, et c'est la seule chose que personne n'organise.",
  },
  {
    id: "t5",
    titre: "Le car de six heures",
    brut: "Les transports sont nuls chez nous. On attend tout le temps et c'est pénible. Les chauffeurs font n'importe quoi.",
    flous: [
      {
        mot: "on attend tout le temps",
        demande: "Combien de temps, un jour précis ?",
        exemples: [
          "mardi dernier, j'ai attendu une heure quarante au carrefour",
          "le car de six heures est parti à huit heures dix",
        ],
      },
      {
        mot: "c'est pénible",
        demande: "Quelle conséquence réelle ?",
        exemples: [
          "je suis arrivé après la fermeture du portail et j'ai manqué le contrôle",
          "ma mère a perdu sa place au marché",
        ],
      },
      {
        mot: "font n'importe quoi",
        demande: "Quel fait as-tu observé ?",
        exemples: [
          "le car ne part pas avant d'être plein, même avec une heure de retard",
          "on nous a fait descendre à mi-chemin",
        ],
      },
    ],
    jugements: ["nuls", "pénible", "n'importe quoi"],
    conclusionAttendue:
      "Ce n'est pas le chauffeur qui décide de partir en retard : c'est un car à moitié vide qui ne rembourse pas son carburant.",
    reecriture:
      "Mardi dernier, j'ai attendu une heure quarante au carrefour. Le car de six heures est parti à huit heures dix, quand les dernières places ont été prises. Je suis arrivé après la fermeture du portail et j'ai manqué le contrôle de mathématiques.\n\nCe n'est pas le chauffeur qui décide de partir en retard : c'est un car à moitié vide qui ne rembourse pas son carburant.",
  },
  {
    id: "t6",
    titre: "Le robinet du quartier",
    brut: "L'eau est un gros problème ici. Les femmes souffrent beaucoup et c'est scandaleux. Il n'y a rien qui marche.",
    flous: [
      {
        mot: "un gros problème",
        demande: "Un fait mesurable : combien de points d'eau, pour combien de personnes ?",
        exemples: [
          "un seul robinet public pour les quatre cents maisons du secteur",
          "l'eau coule deux heures par jour, entre cinq et sept heures",
        ],
      },
      {
        mot: "les femmes souffrent",
        demande: "Que font-elles concrètement, et combien de temps ?",
        exemples: [
          "ma tante se lève à quatre heures pour prendre son tour dans la file",
          "elles portent deux bidons sur six cents mètres",
        ],
      },
      {
        mot: "rien qui marche",
        demande: "Qu'a-t-on tenté, et avec quel résultat ?",
        exemples: [
          "le comité de quartier a réuni une cotisation l'an dernier ; le second robinet n'a jamais été posé",
          "la borne-fontaine est en panne depuis février",
        ],
      },
    ],
    jugements: ["gros problème", "scandaleux", "rien qui marche"],
    conclusionAttendue:
      "Quatre heures passées dans une file ne figurent sur aucun budget, et c'est pourquoi personne ne les compte.",
    reecriture:
      "Notre secteur compte quatre cents maisons et un seul robinet public, qui coule de cinq à sept heures du matin. Ma tante se lève à quatre heures pour prendre son tour et rapporte deux bidons sur six cents mètres. L'an dernier, le comité de quartier a réuni une cotisation pour un second robinet ; il n'a jamais été posé.\n\nQuatre heures passées dans une file ne figurent sur aucun budget, et c'est pourquoi personne ne les compte.",
  },
];

const TEMOIGNAGE_VIDE: Temoignage = {
  id: "",
  titre: "—",
  brut: "—",
  flous: [],
  jugements: [],
  conclusionAttendue: "—",
  reecriture: "—",
};

export function TemoignageArgument() {
  const [i, setI] = useState(0);
  const [passe, setPasse] = useState(0);
  const [remplaces, setRemplaces] = useState<Record<number, string>>({});
  const [supprimes, setSupprimes] = useState<ReadonlyArray<number>>([]);
  const [conclusion, setConclusion] = useState("");
  const [montre, setMontre] = useState(false);

  const t = TEMOIGNAGES[i] ?? TEMOIGNAGE_VIDE;
  const details = Object.keys(remplaces).length;
  const assezDeDetails = details >= Math.min(3, t.flous.length);
  const auPresent = /\b(est|sont|devient|deviennent|perd|compte|prend|n'est|ne sert)\b/i.test(
    conclusion,
  );

  function suivant() {
    setI((n) => (n + 1) % TEMOIGNAGES.length);
    setPasse(0);
    setRemplaces({});
    setSupprimes([]);
    setConclusion("");
    setMontre(false);
  }

  return (
    <div className="space-y-3">
      <p className="text-sm text-muted-foreground">
        Un témoignage vague, et trois passes pour le rendre utilisable : des détails concrets, les
        jugements en moins, une conclusion au présent.
      </p>

      <div className="rounded-lg border border-border bg-background p-3">
        <p className="text-xs font-semibold text-foreground">{t.titre}</p>
        <p className="mt-1 text-sm italic text-muted-foreground">« {t.brut} »</p>

        <div className="mt-3">
          <Choice<"p0" | "p1" | "p2">
            label="Passe"
            value={passe === 0 ? "p0" : passe === 1 ? "p1" : "p2"}
            options={[
              { value: "p0", label: "1. préciser" },
              { value: "p1", label: "2. élaguer" },
              { value: "p2", label: "3. conclure" },
            ]}
            onChange={(v) => setPasse(v === "p0" ? 0 : v === "p1" ? 1 : 2)}
          />
        </div>

        {passe === 0 ? (
          <div className="mt-3 space-y-2">
            <p className="text-[11px] text-muted-foreground">
              Chaque mot flou attend un détail concret : une heure, une distance, un objet, un fait
              vérifiable.
            </p>
            {t.flous.map((f, k) => (
              <div key={f.mot} className="rounded-md border border-border/60 p-2.5">
                <p className="text-xs">
                  <span className="font-semibold" style={{ color: PALETTE.red }}>
                    « {f.mot} »
                  </span>
                  <span className="ml-1 text-muted-foreground">— {f.demande}</span>
                </p>
                <div className="mt-1.5 flex flex-wrap gap-1.5">
                  {f.exemples.map((ex) => (
                    <button
                      key={ex}
                      type="button"
                      onClick={() => setRemplaces((r) => ({ ...r, [k]: ex }))}
                      className="rounded-md border px-2 py-1 text-[11px] text-left"
                      style={{
                        borderColor: remplaces[k] === ex ? PALETTE.green : "rgba(100,116,139,0.3)",
                        backgroundColor:
                          remplaces[k] === ex ? "rgba(21,128,61,0.10)" : "transparent",
                      }}
                    >
                      {ex}
                    </button>
                  ))}
                </div>
              </div>
            ))}
            <p
              className="rounded-md px-2 py-1.5 text-[11px]"
              style={{
                backgroundColor: assezDeDetails ? "rgba(21,128,61,0.12)" : "rgba(202,138,4,0.12)",
                color: assezDeDetails ? "#14532d" : "#78350f",
              }}
            >
              Détails concrets placés : {details}.{" "}
              {assezDeDetails
                ? "C'est assez pour qu'un lecteur voie la scène. Passe à la seconde passe."
                : "Il en faut au moins trois : écrire un témoignage, ce n'est pas ressentir plus fort, c'est regarder plus précisément."}
            </p>
          </div>
        ) : null}

        {passe === 1 ? (
          <div className="mt-3 space-y-2">
            <p className="text-[11px] text-muted-foreground">
              Clique sur les jugements répétés pour les retirer. Ce sont des opinions, pas un
              témoignage — et l'hyperbole affaiblit au lieu de renforcer.
            </p>
            <div className="flex flex-wrap gap-1.5">
              {t.jugements.map((j, k) => {
                const off = supprimes.includes(k);
                return (
                  <button
                    key={j}
                    type="button"
                    onClick={() =>
                      setSupprimes((s) => (s.includes(k) ? s.filter((x) => x !== k) : [...s, k]))
                    }
                    className="rounded-md border px-2.5 py-1 text-xs"
                    style={{
                      borderColor: off ? "rgba(100,116,139,0.3)" : PALETTE.red,
                      backgroundColor: off ? "transparent" : "rgba(185,28,28,0.10)",
                      textDecoration: off ? "line-through" : "none",
                      opacity: off ? 0.5 : 1,
                    }}
                  >
                    {j}
                  </button>
                );
              })}
            </div>
            <p className="text-[11px] text-muted-foreground">
              {supprimes.length} / {t.jugements.length} retirés.
              {supprimes.length === t.jugements.length
                ? " Le témoignage ne juge plus : il montre, et le lecteur juge lui-même."
                : ""}
            </p>
          </div>
        ) : null}

        {passe === 2 ? (
          <div className="mt-3 space-y-2">
            <p className="text-[11px] text-muted-foreground">
              Une dernière phrase, au présent, qui dit ce que le récit prouve. Sans elle, tu as
              raconté une anecdote.
            </p>
            <textarea
              value={conclusion}
              onChange={(e) => setConclusion(e.target.value)}
              rows={3}
              className="w-full rounded-md border border-border bg-background px-2.5 py-1.5 text-sm text-foreground"
              placeholder="Au présent : « C'est ainsi que… », « Un quartier n'est pas… »"
            />
            <p
              className="rounded-md px-2 py-1.5 text-[11px]"
              style={{
                backgroundColor: auPresent ? "rgba(21,128,61,0.12)" : "rgba(202,138,4,0.12)",
                color: auPresent ? "#14532d" : "#78350f",
              }}
            >
              {auPresent
                ? "Ta conclusion est au présent : elle vaut encore, et c'est ce qui transforme le récit en argument."
                : "Le récit se dit au passé composé et à l'imparfait ; la conclusion, elle, se dit au présent."}
            </p>
            <div className="flex flex-wrap gap-2">
              <button
                type="button"
                onClick={() => setMontre(true)}
                className="rounded-lg border border-border px-3 py-1.5 text-xs font-semibold text-foreground"
              >
                Voir la réécriture complète
              </button>
              <button
                type="button"
                onClick={suivant}
                className="rounded-lg bg-primary px-3 py-1.5 text-xs font-semibold text-primary-foreground"
              >
                Témoignage suivant ({i + 1} / {TEMOIGNAGES.length})
              </button>
            </div>
          </div>
        ) : null}

        {montre ? (
          <div className="mt-3 grid gap-2 sm:grid-cols-2">
            <div
              className="rounded-md px-2.5 py-2"
              style={{ backgroundColor: "rgba(185,28,28,0.08)" }}
            >
              <p className="text-[11px] font-semibold" style={{ color: PALETTE.red }}>
                l'original
              </p>
              <p className="mt-1 text-xs text-foreground">{t.brut}</p>
            </div>
            <div
              className="rounded-md px-2.5 py-2"
              style={{ backgroundColor: "rgba(21,128,61,0.08)" }}
            >
              <p className="text-[11px] font-semibold" style={{ color: PALETTE.green }}>
                la réécriture
              </p>
              {t.reecriture.split("\n\n").map((par) => (
                <p key={par.slice(0, 20)} className="mt-1 text-xs text-foreground">
                  {par}
                </p>
              ))}
            </div>
          </div>
        ) : null}
      </div>

      <Citation auteur="aucun mot plus savant que dans l'original">
        La réécriture n'emploie pas un vocabulaire plus riche. Elle a une date, un lieu, une
        distance, un fait vérifiable — et deux phrases au présent qui disent ce que le récit prouve.
        C'est tout l'écart entre une plainte et un argument.
      </Citation>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* 2. Construire son plan                                              */
/* ------------------------------------------------------------------ */

type TypePlan = "thematique" | "dialectique";

type SujetPlan = {
  id: string;
  enonce: string;
  verbe: string;
  plan: TypePlan;
  /** Arguments à ranger, avec leur force de 1 à 3. */
  arguments: ReadonlyArray<{ texte: string; force: number }>;
  syntheses?: ReadonlyArray<{ texte: string; bonne: boolean; retour: string }>;
};

const SUJETS_PLAN: ReadonlyArray<SujetPlan> = [
  {
    id: "sp1",
    enonce: "« Les réseaux sociaux éloignent les jeunes de leur famille. » Défendez cette opinion.",
    verbe: "Défendez",
    plan: "thematique",
    arguments: [
      {
        texte: "Le temps passé devant l'écran est du temps retiré à la conversation familiale.",
        force: 1,
      },
      {
        texte:
          "Les réseaux créent une vie sociale parallèle que la famille ne connaît pas, et dont elle ne peut plus parler.",
        force: 2,
      },
      {
        texte:
          "Ils installent une hiérarchie nouvelle : le jeune sait des choses que ses aînés ignorent, et l'autorité familiale s'en trouve fragilisée.",
        force: 3,
      },
    ],
  },
  {
    id: "sp2",
    enonce: "« L'école doit se faire dans la langue maternelle. » Qu'en pensez-vous ?",
    verbe: "Qu'en pensez-vous",
    plan: "dialectique",
    arguments: [
      {
        texte:
          "L'enseignement en langue maternelle facilite les apprentissages des premières années.",
        force: 1,
      },
      {
        texte: "Il préserve un patrimoine culturel que l'école a longtemps combattu.",
        force: 2,
      },
      {
        texte:
          "Mais le pays compte plus de deux cents langues, et le français et l'anglais ouvrent sur le pays entier.",
        force: 3,
      },
    ],
    syntheses: [
      {
        texte:
          "La question n'est pas « quelle langue », mais « à quel moment » : les premières années en langue maternelle pour comprendre, puis le passage progressif aux langues officielles pour poursuivre.",
        bonne: true,
        retour:
          "Voilà une synthèse. Elle ne choisit pas entre les deux langues : elle change la question en passant de « laquelle » à « quand ». C'est le mouvement caractéristique d'une synthèse réussie.",
      },
      {
        texte:
          "Nous avons vu que certains défendent la langue maternelle et que d'autres préfèrent les langues officielles. Les deux points de vue ont leurs raisons.",
        bonne: false,
        retour:
          "C'est un résumé déguisé, le premier piège. Tu n'as rien dit que les deux parties précédentes ne disaient déjà, et tu n'auras rien.",
      },
      {
        texte:
          "Chacun a ses raisons, et il faut respecter toutes les opinions. L'essentiel est de trouver un équilibre.",
        bonne: false,
        retour:
          "C'est le refus de trancher, le second piège — et la phrase la plus faible qu'on puisse écrire dans une copie.",
      },
    ],
  },
  {
    id: "sp3",
    enonce:
      "« Certains pensent qu'il faut interdire les sacs plastiques ; d'autres estiment que c'est pénaliser les petits commerçants. » Discutez.",
    verbe: "Discutez",
    plan: "dialectique",
    arguments: [
      { texte: "Les sachets bouchent les caniveaux et aggravent les inondations.", force: 1 },
      {
        texte: "Un sac plastique met quatre cents ans à disparaître, et le bétail en meurt.",
        force: 2,
      },
      {
        texte:
          "Mais l'interdiction frappe d'abord les petits commerçants, et le contrôle s'exerce sur eux plutôt que sur les importateurs.",
        force: 3,
      },
    ],
    syntheses: [
      {
        texte:
          "Interdire la production et l'importation plutôt que la détention : on tarit la source au lieu de sanctionner le dernier maillon. Avec un délai et une filière de remplacement, l'objection tombe.",
        bonne: true,
        retour:
          "Encore un déplacement : on ne discute plus « interdire ou non », mais « interdire à quel bout de la chaîne ». La synthèse ne cherche pas le milieu entre deux opinions, elle cherche l'angle que ni l'une ni l'autre n'avait vu.",
      },
      {
        texte:
          "Il faut donc interdire les sacs plastiques tout en aidant les commerçants, car les deux arguments sont valables.",
        bonne: false,
        retour:
          "C'est la synthèse molle : elle additionne les deux parties sans rien déplacer, et elle ne dit ni qui interdit, ni comment on aide.",
      },
      {
        texte:
          "En conclusion, cette question est très complexe et mérite une réflexion approfondie.",
        bonne: false,
        retour: "Tu annonces une réflexion au moment où tu devais la livrer. Zéro.",
      },
    ],
  },
  {
    id: "sp4",
    enonce: "« Il faut interdire les motos-taxis en centre-ville. » Discutez cette opinion.",
    verbe: "Discutez",
    plan: "dialectique",
    arguments: [
      { texte: "Les motos-taxis causent une part importante des accidents urbains.", force: 1 },
      {
        texte: "Elles circulent souvent sans casque, sans assurance et sans immatriculation.",
        force: 2,
      },
      {
        texte:
          "Mais elles font vivre des milliers de jeunes et desservent les quartiers où les bus ne vont pas.",
        force: 3,
      },
    ],
    syntheses: [
      {
        texte:
          "Le vrai problème n'est pas la moto, c'est l'absence de transport public dans les quartiers périphériques. Les encadrer — casque, immatriculation, zones réservées — traiterait le danger sans supprimer le revenu ; l'interdiction ne viendrait qu'en dernier, et seulement là où une autre solution existe.",
        bonne: true,
        retour:
          "Elle prend position — encadrer plutôt qu'interdire — et elle dit À QUELLE CONDITION l'autre solution deviendrait acceptable. C'est cela, dépasser.",
      },
      {
        texte:
          "Les deux points de vue se valent, il faut trouver un équilibre entre sécurité et emploi.",
        bonne: false,
        retour: "Le refus de trancher, mot pour mot. C'est l'exemple même de ce qu'il faut éviter.",
      },
      {
        texte:
          "Nous avons d'abord vu les dangers, puis les avantages. Il apparaît donc que la question est délicate.",
        bonne: false,
        retour: "Un résumé, suivi d'un constat de difficulté. Aucune position n'est prise.",
      },
    ],
  },
  {
    id: "sp5",
    enonce: "« Le reboisement camerounais échoue faute de suivi. » Montrez-le.",
    verbe: "Montrez",
    plan: "thematique",
    arguments: [
      {
        texte: "Les campagnes mesurent les plants distribués, jamais les arbres vivants.",
        force: 1,
      },
      {
        texte:
          "Aucun responsable n'est désigné pour arroser et protéger le plant pendant les trois premières saisons.",
        force: 2,
      },
      {
        texte:
          "La prime est versée le jour de la plantation, ce qui récompense le geste et non le résultat.",
        force: 3,
      },
    ],
  },
  {
    id: "sp6",
    enonce:
      "« Les habitants d'un quartier doivent-ils ramasser eux-mêmes leurs ordures ? » Qu'en pensez-vous ?",
    verbe: "Qu'en pensez-vous",
    plan: "dialectique",
    arguments: [
      {
        texte: "Un caniveau dégagé évacue, et le quartier devient propre tout de suite.",
        force: 1,
      },
      { texte: "Celui qui a ramassé ne jette plus : l'effort crée le respect.", force: 2 },
      {
        texte:
          "Mais le ramassage est un service public déjà payé par l'impôt, et le faire soi-même dispense la commune de le corriger.",
        force: 3,
      },
    ],
    syntheses: [
      {
        texte:
          "La vraie question n'est pas de savoir s'il faut ramasser, mais ce que l'on fait de ce ramassage : une collecte menée en silence excuse l'inaction, une collecte comptée, affichée et adressée à la mairie l'accuse.",
        bonne: true,
        retour:
          "Le déplacement est net : de « faut-il ramasser » à « que fait-on du ramassage ». Et elle tranche — documenté et adressé, le geste devient une pression.",
      },
      {
        texte:
          "Il faut à la fois ramasser et attendre la commune, car les deux attitudes ont du bon.",
        bonne: false,
        retour: "Une addition, pas une synthèse : elle ne déplace rien et ne décide rien.",
      },
      {
        texte: "Chacun fait comme il peut, et c'est respectable.",
        bonne: false,
        retour: "Le refus de trancher, dans sa forme la plus courte.",
      },
    ],
  },
  {
    id: "sp7",
    enonce: "« La lecture est inutile à l'heure d'internet. » Réfutez cette opinion.",
    verbe: "Réfutez",
    plan: "thematique",
    arguments: [
      { texte: "Internet donne des informations ; un livre donne une pensée suivie.", force: 1 },
      {
        texte:
          "Lire un texte long entraîne une attention que l'écran, fait d'interruptions, désapprend.",
        force: 2,
      },
      {
        texte:
          "Celui qui ne lit que des textes courts ne sait plus écrire des textes longs — et c'est exactement ce que le BEPC demande.",
        force: 3,
      },
    ],
  },
  {
    id: "sp8",
    enonce: "« Le travail des enfants est parfois nécessaire aux familles. » Discutez.",
    verbe: "Discutez",
    plan: "dialectique",
    arguments: [
      {
        texte: "Dans certaines familles, le revenu de l'enfant comble un manque immédiat.",
        force: 1,
      },
      {
        texte: "Un apprentissage précoce transmet un métier que l'école n'enseigne pas.",
        force: 2,
      },
      {
        texte:
          "Mais l'enfant qui travaille quitte l'école, et il condamne ses propres enfants au même choix.",
        force: 3,
      },
    ],
    syntheses: [
      {
        texte:
          "La question n'est pas de juger les familles mais de regarder ce qui les contraint : tant que la scolarité coûte plus qu'elle ne rapporte à court terme, aucune interdiction ne suffira. Rendre l'école gratuite et nourrir les élèves coûte moins qu'une génération perdue.",
        bonne: true,
        retour:
          "Elle refuse le faux débat — pour ou contre — et nomme la cause économique, puis elle tranche sur la mesure à prendre.",
      },
      {
        texte: "Il faut interdire le travail des enfants tout en comprenant les familles pauvres.",
        bonne: false,
        retour: "Une addition de bons sentiments : rien n'est déplacé, rien n'est décidé.",
      },
      {
        texte: "Les avis divergent, et chaque situation est particulière.",
        bonne: false,
        retour: "Le refus de trancher.",
      },
    ],
  },
  {
    id: "sp9",
    enonce: "« Il faut rendre le sport obligatoire au BEPC. » Défendez cette opinion.",
    verbe: "Défendez",
    plan: "thematique",
    arguments: [
      {
        texte:
          "Une épreuve notée est la seule chose qui fait tenir un horaire dans un établissement.",
        force: 1,
      },
      {
        texte: "L'exercice régulier améliore l'attention en classe et réduit l'absentéisme.",
        force: 2,
      },
      {
        texte:
          "Et une note de sport donne à des élèves en difficulté scolaire une réussite à défendre, ce qui les retient à l'école.",
        force: 3,
      },
    ],
  },
  {
    id: "sp10",
    enonce: "« Faut-il interdire les téléphones dans les établissements ? » Discutez.",
    verbe: "Discutez",
    plan: "dialectique",
    arguments: [
      { texte: "Le téléphone fragmente l'attention et facilite la triche.", force: 1 },
      {
        texte: "Il expose les élèves à des conflits que l'établissement ne peut pas arbitrer.",
        force: 2,
      },
      {
        texte:
          "Mais c'est aussi le seul moyen de joindre un parent, et le seul dictionnaire de beaucoup d'élèves.",
        force: 3,
      },
    ],
    syntheses: [
      {
        texte:
          "Le choix n'est pas entre interdire et autoriser, mais entre interdire partout et interdire en classe : un téléphone rangé pendant les cours et disponible à la récréation règle la triche sans couper l'élève de sa famille.",
        bonne: true,
        retour:
          "Le déplacement porte sur le lieu et le moment, et il désarme les deux objections d'un coup.",
      },
      {
        texte: "Il faut un usage raisonnable et responsable du téléphone.",
        bonne: false,
        retour:
          "Une formule creuse : qui décide de ce qui est raisonnable, et avec quelle règle ? Rien n'est tranché.",
      },
      {
        texte: "Les deux camps ont des arguments valables, comme nous venons de le voir.",
        bonne: false,
        retour: "Un résumé déguisé en conclusion.",
      },
    ],
  },
];

const SUJET_PLAN_VIDE: SujetPlan = {
  id: "",
  enonce: "—",
  verbe: "—",
  plan: "thematique",
  arguments: [],
};

export function PlanDialectique() {
  const [i, setI] = useState(0);
  const [verbeVu, setVerbeVu] = useState(false);
  const [planChoisi, setPlanChoisi] = useState<TypePlan | null>(null);
  const [ordre, setOrdre] = useState<ReadonlyArray<number>>([]);
  const [synthese, setSynthese] = useState<number | null>(null);

  const s = SUJETS_PLAN[i] ?? SUJET_PLAN_VIDE;
  const planJuste = planChoisi === s.plan;

  const ordreComplet = ordre.length === s.arguments.length;
  const ordreJuste =
    ordreComplet &&
    ordre.every((idx, rang) => {
      const a = s.arguments[idx];
      return a !== undefined && a.force === rang + 1;
    });

  function suivant() {
    setI((n) => (n + 1) % SUJETS_PLAN.length);
    setVerbeVu(false);
    setPlanChoisi(null);
    setOrdre([]);
    setSynthese(null);
  }

  return (
    <div className="space-y-3">
      <p className="text-sm text-muted-foreground">
        Avant tout, le verbe de la consigne : c'est lui qui décide du plan. Un élève qui discute
        quand on lui demandait de défendre perd la moitié de sa note, même s'il écrit bien.
      </p>

      <div className="rounded-lg border border-border bg-background p-3">
        <p className="text-sm text-foreground">
          {verbeVu ? (
            <>
              {s.enonce.split(s.verbe)[0]}
              <span
                className="rounded px-1.5 py-0.5 font-semibold"
                style={{ backgroundColor: "rgba(202,138,4,0.20)", color: "#78350f" }}
              >
                {s.verbe}
              </span>
              {s.enonce.split(s.verbe)[1] ?? ""}
            </>
          ) : (
            s.enonce
          )}
        </p>

        {!verbeVu ? (
          <button
            type="button"
            onClick={() => setVerbeVu(true)}
            className="mt-3 rounded-lg border border-border px-3 py-1.5 text-xs font-semibold text-foreground"
          >
            Souligner le verbe de la consigne
          </button>
        ) : (
          <div className="mt-3">
            <Choice<TypePlan | "">
              label="Le plan que ce verbe impose"
              value={planChoisi ?? ""}
              options={[
                { value: "thematique", label: "thématique (trois arguments du même côté)" },
                { value: "dialectique", label: "dialectique (thèse, antithèse, synthèse)" },
              ]}
              onChange={(v) => {
                if (v !== "") setPlanChoisi(v);
              }}
            />
          </div>
        )}

        {planChoisi !== null ? (
          <div className="mt-3 space-y-2">
            <Verdict tone={planJuste ? "ok" : "bad"}>
              <span className="font-semibold">
                {planJuste
                  ? `Bon plan : le ${s.plan === "thematique" ? "thématique" : "dialectique"}. `
                  : `« ${s.verbe} » impose le plan ${s.plan === "thematique" ? "thématique" : "dialectique"}. `}
              </span>
              {planJuste
                ? s.plan === "thematique"
                  ? "Tu es d'un seul côté : trois arguments qui vont tous dans le même sens."
                  : "Tu dois examiner les deux côtés, puis prendre position dans une troisième partie."
                : "Ce choix-là t'aurait coûté la moitié des points d'idées, quelle que soit la qualité de ta langue. Relis toujours la consigne deux fois."}
            </Verdict>

            <p className="text-[11px] text-muted-foreground">
              Range les arguments du plus faible au plus fort : le lecteur garde en mémoire ce qu'il
              a lu en dernier.
            </p>
            <div className="space-y-1.5">
              {s.arguments.map((a, k) => {
                const rang = ordre.indexOf(k);
                return (
                  <button
                    key={a.texte.slice(0, 24)}
                    type="button"
                    onClick={() =>
                      setOrdre((o) => (o.includes(k) ? o.filter((x) => x !== k) : [...o, k]))
                    }
                    className="block w-full rounded-md border px-2.5 py-1.5 text-left text-xs"
                    style={{
                      borderColor: rang >= 0 ? PALETTE.blue : "rgba(100,116,139,0.3)",
                      backgroundColor: rang >= 0 ? "rgba(37,99,235,0.08)" : "transparent",
                    }}
                  >
                    {rang >= 0 ? (
                      <span className="mr-1.5 font-semibold" style={{ color: PALETTE.blue }}>
                        {rang === 0 ? "I." : rang === 1 ? "II." : "III."}
                      </span>
                    ) : null}
                    {a.texte}
                  </button>
                );
              })}
            </div>

            {ordreComplet ? (
              <Verdict tone={ordreJuste ? "ok" : "warn"}>
                <span className="font-semibold">
                  {ordreJuste
                    ? "L'ordre monte en puissance. "
                    : "L'ordre attendu va du plus faible au plus fort. "}
                </span>
                {ordreJuste
                  ? "Garde ta meilleure raison pour la fin, et place une concession au début du troisième paragraphe."
                  : "Ta meilleure raison est maintenant au milieu, où le lecteur l'oubliera. Reclasse-la en dernier."}
              </Verdict>
            ) : null}

            {s.syntheses !== undefined && ordreComplet ? (
              <div className="rounded-md border border-border/60 p-2.5">
                <p className="text-xs font-semibold text-foreground">
                  Trois synthèses possibles. Deux sont des pièges — trouve celle qui déplace la
                  question.
                </p>
                <div className="mt-1.5 space-y-1.5">
                  {s.syntheses.map((sy, k) => (
                    <button
                      key={sy.texte.slice(0, 24)}
                      type="button"
                      disabled={synthese !== null}
                      onClick={() => setSynthese(k)}
                      className="block w-full rounded-md border px-2.5 py-1.5 text-left text-xs"
                      style={{
                        borderColor:
                          synthese !== null && sy.bonne ? PALETTE.green : "rgba(100,116,139,0.3)",
                        backgroundColor:
                          synthese !== null && sy.bonne
                            ? "rgba(21,128,61,0.10)"
                            : synthese === k
                              ? "rgba(185,28,28,0.10)"
                              : "transparent",
                      }}
                    >
                      {sy.texte}
                    </button>
                  ))}
                </div>
                {synthese !== null ? (
                  <div className="mt-2">
                    <Verdict tone={s.syntheses[synthese]?.bonne ? "ok" : "bad"}>
                      {s.syntheses[synthese]?.retour ?? ""}
                    </Verdict>
                  </div>
                ) : null}
              </div>
            ) : null}

            <button
              type="button"
              onClick={suivant}
              className="rounded-lg bg-primary px-3 py-1.5 text-xs font-semibold text-primary-foreground"
            >
              Sujet suivant ({i + 1} / {SUJETS_PLAN.length})
            </button>
          </div>
        ) : null}
      </div>

      <Citation auteur="ce qu'une synthèse n'est pas">
        Ce n'est pas un résumé des deux parties, et ce n'est pas un refus de trancher. Une synthèse
        tranche, en disant à quelle condition — et elle cherche l'angle que ni la thèse ni
        l'antithèse n'avait vu.
      </Citation>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* 3. Composer et se faire corriger                                    */
/* ------------------------------------------------------------------ */

type SujetRedaction = {
  id: string;
  enonce: string;
  consigne: string;
  plan: TypePlan;
  problemeModele: string;
};

const SUJETS_REDACTION: ReadonlyArray<SujetRedaction> = [
  {
    id: "r1",
    enonce:
      "« Dans certains quartiers, des jeunes se sont organisés pour ramasser eux-mêmes les ordures, faute de voir passer le camion de la commune. Certains y voient un bel exemple de citoyenneté ; d'autres estiment que c'est décharger l'État de ses devoirs. »",
    consigne: "Qu'en pensez-vous ? Une trentaine de lignes, arguments et exemples.",
    plan: "dialectique",
    problemeModele: "L'initiative citoyenne supplée-t-elle l'État, ou l'excuse-t-elle ?",
  },
  {
    id: "r2",
    enonce: "« Il faut interdire les sacs plastiques sur tout le territoire. »",
    consigne: "Discutez cette opinion en une trentaine de lignes.",
    plan: "dialectique",
    problemeModele:
      "Faut-il interdire l'objet, ou s'en prendre à ceux qui le produisent et l'importent ?",
  },
  {
    id: "r3",
    enonce:
      "« Les campagnes nationales de reboisement annoncent des millions de plants, mais personne ne compte les arbres vivants cinq ans après. »",
    consigne: "Montrez que le suivi importe plus que la plantation. Une trentaine de lignes.",
    plan: "thematique",
    problemeModele: "Pourquoi mesure-t-on les trous plutôt que les arbres ?",
  },
  {
    id: "r4",
    enonce: "« L'école doit commencer dans la langue que l'enfant parle à la maison. »",
    consigne: "Qu'en pensez-vous ? Une trentaine de lignes.",
    plan: "dialectique",
    problemeModele: "La question est-elle celle de la langue, ou celle du moment ?",
  },
  {
    id: "r5",
    enonce:
      "« Un élève qui marche deux heures pour venir en classe n'apprendra jamais comme les autres. »",
    consigne: "Défendez cette opinion, en vous appuyant sur votre expérience. Trente lignes.",
    plan: "thematique",
    problemeModele: "Ce que la distance retire à l'élève avant même le premier cours.",
  },
  {
    id: "r6",
    enonce: "« Faut-il interdire les motos-taxis dans les centres-villes ? »",
    consigne: "Discutez. Une trentaine de lignes.",
    plan: "dialectique",
    problemeModele: "Interdire la moto, ou remplacer ce qu'elle remplace ?",
  },
  {
    id: "r7",
    enonce:
      "« Les réseaux sociaux ont fait des jeunes d'aujourd'hui une génération mieux informée que celle de leurs parents. »",
    consigne: "Qu'en pensez-vous ? Une trentaine de lignes.",
    plan: "dialectique",
    problemeModele: "Être informé, est-ce recevoir des nouvelles ou savoir les vérifier ?",
  },
  {
    id: "r8",
    enonce: "« Le quartier est responsable de sa propre propreté. »",
    consigne: "Réfutez cette opinion. Une trentaine de lignes.",
    plan: "thematique",
    problemeModele: "Peut-on rendre un quartier responsable d'un service qu'il a déjà payé ?",
  },
];

const SUJET_REDACTION_VIDE: SujetRedaction = {
  id: "",
  enonce: "—",
  consigne: "—",
  plan: "thematique",
  problemeModele: "—",
};

const FAUTES_COUTEUSES: ReadonlyArray<{ id: string; titre: string; detail: string }> = [
  {
    id: "f1",
    titre: "Ne pas lire la consigne",
    detail:
      "« Qu'en pensez-vous » demandait les deux positions. Un élève qui n'en défend qu'une perd la moitié des points d'idées, même brillamment.",
  },
  {
    id: "f2",
    titre: "Des arguments sans exemples",
    detail:
      "Trois paragraphes d'idées générales, sans un seul fait concret. C'est la copie la plus fréquente, et elle plafonne.",
  },
  {
    id: "f3",
    titre: "Une synthèse qui refuse de trancher",
    detail: "« Il faut trouver un équilibre », « chacun a ses raisons » : zéro.",
  },
  {
    id: "f4",
    titre: "Une introduction qui recopie le sujet",
    detail: "L'introduction doit REFORMULER le problème en une question, pas le répéter.",
  },
  {
    id: "f5",
    titre: "L'oubli de la relecture",
    detail:
      "Les cinq dernières minutes chassent les accords de participe, les « si j'aurais », les homophones. Un test de trois secondes par faute, cinq minutes, cent tests.",
  },
];

export function RedactionArgumentee() {
  const [i, setI] = useState(0);
  const [etape, setEtape] = useState<"brouillon" | "redaction" | "note">("brouillon");
  const [verbeSouligne, setVerbeSouligne] = useState(false);
  const [probleme, setProbleme] = useState("");
  const [argum, setArgum] = useState<ReadonlyArray<{ arg: string; ex: string }>>([
    { arg: "", ex: "" },
    { arg: "", ex: "" },
    { arg: "", ex: "" },
  ]);
  const [copie, setCopie] = useState("");

  const s = SUJETS_REDACTION[i] ?? SUJET_REDACTION_VIDE;

  const problemePose = probleme.trim().length > 15 && probleme.includes("?");
  const paires = argum.filter((a) => a.arg.trim().length > 10 && a.ex.trim().length > 10).length;
  const brouillonPret = verbeSouligne && problemePose && paires >= 2;

  const lignes = copie.split("\n").filter((l) => l.trim().length > 0).length;
  const mots = copie.trim().length === 0 ? 0 : copie.trim().split(/\s+/).length;
  const aIntro = /\?/.test(copie.slice(0, 500));
  const aConnecteurs =
    (/\b(d'abord|ensuite|enfin|de plus|par ailleurs)/i.test(copie) ? 1 : 0) +
    (/\b(cependant|toutefois|mais|en revanche)/i.test(copie) ? 1 : 0) +
    (/\b(donc|ainsi|c'est pourquoi|par conséquent|en somme)/i.test(copie) ? 1 : 0);
  const aConcession = /\b(certes|il est vrai que|on ne peut nier)/i.test(copie);
  const aExemple = /\b(à |en |selon |par exemple)/i.test(copie) && /\d/.test(copie);
  const aSynthese = /\b(en réalité|le vrai problème|à bien y regarder|la vraie question)/i.test(
    copie,
  );
  const aRefus =
    /\b(équilibre|chacun a ses raisons|respecter toutes les opinions|très complexe)/i.test(copie);

  const criteres: ReadonlyArray<{ label: string; ok: boolean; note: string }> = [
    {
      label: "une introduction qui pose une question",
      ok: aIntro,
      note: "L'introduction reformule le problème sous forme interrogative, elle ne recopie pas le sujet.",
    },
    {
      label: "des connecteurs qui montrent le plan",
      ok: aConnecteurs >= 2,
      note: "Le correcteur doit voir ton plan sans le chercher : d'abord, de plus, cependant, en somme.",
    },
    {
      label: "une concession",
      ok: aConcession,
      note: "Un seul « certes… mais », au début du troisième paragraphe, et le correcteur le verra.",
    },
    {
      label: "un exemple concret et chiffré",
      ok: aExemple,
      note: "Un lieu, une date, un chiffre. C'est la faute la plus fréquente de toutes les copies.",
    },
    {
      label:
        s.plan === "dialectique"
          ? "une synthèse qui déplace la question"
          : "une montée en puissance",
      ok: s.plan === "dialectique" ? aSynthese && !aRefus : aConnecteurs >= 2,
      note:
        s.plan === "dialectique"
          ? "« En réalité », « le vrai problème est ailleurs » : la synthèse tranche, elle ne cherche pas le milieu."
          : "Garde ton argument le plus fort pour le dernier paragraphe.",
    },
    {
      label: "une longueur tenue (autour de trente lignes)",
      ok: mots >= 150,
      note: "Une copie de soixante lignes n'est pas mieux notée : elle est moins bien tenue.",
    },
  ];

  const acquis = criteres.filter((c) => c.ok).length;
  const commises = [
    !verbeSouligne ? FAUTES_COUTEUSES[0] : null,
    !aExemple ? FAUTES_COUTEUSES[1] : null,
    aRefus ? FAUTES_COUTEUSES[2] : null,
    !aIntro ? FAUTES_COUTEUSES[3] : null,
  ].filter((f): f is { id: string; titre: string; detail: string } => f !== null);

  function suivant() {
    setI((n) => (n + 1) % SUJETS_REDACTION.length);
    setEtape("brouillon");
    setVerbeSouligne(false);
    setProbleme("");
    setArgum([
      { arg: "", ex: "" },
      { arg: "", ex: "" },
      { arg: "", ex: "" },
    ]);
    setCopie("");
  }

  return (
    <div className="space-y-3">
      <p className="text-sm text-muted-foreground">
        L'épreuve en conditions. Le brouillon d'abord — dix minutes, et elles sont décisives —, la
        rédaction ensuite, la note enfin, sur les trois critères officiels.
      </p>

      <div className="rounded-lg border border-border bg-background p-3">
        <p className="text-sm text-foreground">{s.enonce}</p>
        <p className="mt-1 text-xs font-semibold text-foreground">{s.consigne}</p>

        <div className="mt-3">
          <Choice<"brouillon" | "redaction" | "note">
            label="Étape"
            value={etape}
            options={[
              { value: "brouillon", label: "1. brouillon" },
              { value: "redaction", label: "2. rédaction" },
              { value: "note", label: "3. note" },
            ]}
            onChange={(v) => {
              if (v === "redaction" && !brouillonPret) return;
              setEtape(v);
            }}
          />
        </div>

        {etape === "brouillon" ? (
          <div className="mt-3 space-y-2">
            <button
              type="button"
              onClick={() => setVerbeSouligne(true)}
              className="rounded-lg border px-3 py-1.5 text-xs font-semibold"
              style={{
                borderColor: verbeSouligne ? PALETTE.green : "rgba(100,116,139,0.4)",
                color: verbeSouligne ? PALETTE.green : PALETTE.slate,
              }}
            >
              {verbeSouligne
                ? `fait — la consigne impose le plan ${s.plan === "thematique" ? "thématique" : "dialectique"}`
                : "1. Souligner le verbe de la consigne"}
            </button>

            <div>
              <p className="text-[11px] text-muted-foreground">
                2. Reformule le problème en une question. C'est elle qui ira dans l'introduction.
              </p>
              <input
                value={probleme}
                onChange={(e) => setProbleme(e.target.value)}
                placeholder="une question, pas une redite du sujet"
                className="mt-1 w-full rounded-md border border-border bg-background px-2.5 py-1.5 text-sm text-foreground"
              />
              {probleme.length > 0 && !problemePose ? (
                <p className="mt-0.5 text-[11px]" style={{ color: PALETTE.orange }}>
                  Une question se termine par un point d'interrogation, et elle reformule — elle ne
                  recopie pas.
                </p>
              ) : null}
            </div>

            <div>
              <p className="text-[11px] text-muted-foreground">
                3. Deux arguments au moins, chacun avec son exemple concret. C'est ici que se gagne
                la note.
              </p>
              {argum.map((a, k) => (
                <div key={`arg${k}`} className="mt-1.5 grid gap-1.5 sm:grid-cols-2">
                  <input
                    value={a.arg}
                    onChange={(e) =>
                      setArgum((list) =>
                        list.map((x, j) => (j === k ? { arg: e.target.value, ex: x.ex } : x)),
                      )
                    }
                    placeholder={`argument ${k + 1} — général`}
                    className="rounded-md border border-border bg-background px-2.5 py-1.5 text-xs text-foreground"
                  />
                  <input
                    value={a.ex}
                    onChange={(e) =>
                      setArgum((list) =>
                        list.map((x, j) => (j === k ? { arg: x.arg, ex: e.target.value } : x)),
                      )
                    }
                    placeholder={`exemple ${k + 1} — lieu, date, chiffre`}
                    className="rounded-md border border-border bg-background px-2.5 py-1.5 text-xs text-foreground"
                  />
                </div>
              ))}
            </div>

            <Verdict tone={brouillonPret ? "ok" : "warn"}>
              <span className="font-semibold">
                {brouillonPret
                  ? "Le brouillon tient. La page de rédaction est ouverte. "
                  : "Le brouillon n'est pas prêt. "}
              </span>
              {brouillonPret
                ? "Tu sais ce que tu vas écrire, et dans quel ordre. C'est le meilleur quart d'heure de l'épreuve."
                : `Il manque : ${[
                    !verbeSouligne ? "le verbe souligné" : null,
                    !problemePose ? "la question reformulée" : null,
                    paires < 2 ? "deux couples argument + exemple" : null,
                  ]
                    .filter((x) => x !== null)
                    .join(", ")}.`}
            </Verdict>

            {brouillonPret ? (
              <p className="text-[11px] italic text-muted-foreground">
                Pour mémoire, un problème possible : {s.problemeModele}
              </p>
            ) : null}
          </div>
        ) : null}

        {etape === "redaction" ? (
          <div className="mt-3 grid gap-3 sm:grid-cols-[2fr_1fr]">
            <textarea
              value={copie}
              onChange={(e) => setCopie(e.target.value)}
              rows={14}
              className="w-full rounded-md border border-border bg-background px-2.5 py-1.5 text-sm text-foreground"
              placeholder="Introduction, puis les parties, puis la conclusion. Un exemple concret dans chaque paragraphe."
            />
            <div className="space-y-1.5">
              <p className="text-[11px] font-semibold text-muted-foreground">
                CE QUE LE CORRECTEUR CHERCHE
              </p>
              {criteres.map((c) => (
                <p
                  key={c.label}
                  className="rounded px-2 py-1 text-[11px]"
                  style={{
                    backgroundColor: c.ok ? "rgba(21,128,61,0.12)" : "rgba(100,116,139,0.10)",
                    color: c.ok ? "#14532d" : PALETTE.slate,
                  }}
                >
                  {c.ok ? "✓ " : "· "}
                  {c.label}
                </p>
              ))}
              {aRefus ? (
                <p
                  className="rounded px-2 py-1 text-[11px]"
                  style={{ backgroundColor: "rgba(185,28,28,0.12)", color: "#7f1d1d" }}
                >
                  Attention : tu as écrit une formule de refus de trancher. Le correcteur la lit
                  comme une absence de position.
                </p>
              ) : null}
              <p className="text-[11px] text-muted-foreground">
                {lignes} ligne{lignes > 1 ? "s" : ""}, {mots} mots.
              </p>
            </div>
          </div>
        ) : null}

        {etape === "note" ? (
          <div className="mt-3 space-y-2">
            <p className="text-xs font-semibold text-foreground">
              Les trois critères du corrigé harmonisé national
            </p>
            {[
              {
                nom: "pertinence des idées",
                ok: aExemple && paires >= 2,
                detail:
                  "Les arguments répondent-ils au sujet, et sont-ils illustrés par un fait concret ?",
              },
              {
                nom: "cohérence de l'organisation",
                ok: aIntro && aConnecteurs >= 2,
                detail:
                  "Introduction, parties distinctes, conclusion — et des connecteurs qui les rendent visibles.",
              },
              {
                nom: "correction linguistique",
                ok: mots >= 150,
                detail:
                  "Orthographe, conjugaison, syntaxe, ponctuation, richesse du vocabulaire. Elle se joue dans les cinq dernières minutes.",
              },
            ].map((c) => (
              <Verdict key={c.nom} tone={c.ok ? "ok" : "warn"}>
                <span className="font-semibold">{c.nom}. </span>
                {c.detail}
              </Verdict>
            ))}

            <p className="text-[11px] text-muted-foreground">
              Critères techniques atteints : {acquis} / {criteres.length}. Je n'ai pas le barème
              chiffré officiel de cette épreuve, seulement ses trois critères : si ton établissement
              possède un barème détaillé, demande-le à ton professeur.
            </p>

            <p className="mt-2 text-xs font-semibold text-foreground">
              Les cinq fautes qui coûtent le plus
            </p>
            {FAUTES_COUTEUSES.map((f) => {
              const commise = commises.some((c) => c.id === f.id);
              return (
                <p
                  key={f.id}
                  className="rounded-md px-2 py-1.5 text-[11px]"
                  style={{
                    backgroundColor: commise ? "rgba(185,28,28,0.12)" : "rgba(100,116,139,0.08)",
                    color: commise ? "#7f1d1d" : PALETTE.slate,
                  }}
                >
                  <span className="font-semibold">{f.titre}. </span>
                  {f.detail}
                  {commise ? " ← tu l'as commise sur cette copie." : ""}
                </p>
              );
            })}

            <button
              type="button"
              onClick={suivant}
              className="rounded-lg bg-primary px-3 py-1.5 text-xs font-semibold text-primary-foreground"
            >
              Sujet suivant ({i + 1} / {SUJETS_REDACTION.length})
            </button>
          </div>
        ) : null}
      </div>

      <Citation auteur="le brouillon n'est pas du temps perdu">
        Dix minutes de brouillon donnent un plan, une question et quatre couples argument-exemple.
        Sans lui, on écrit trente lignes en cherchant quoi dire — et cela se lit.
      </Citation>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* 4. Construire son intervention                                      */
/* ------------------------------------------------------------------ */

const TICS: ReadonlyArray<string> = [
  "euh",
  "voilà",
  "en fait",
  "du coup",
  "quoi",
  "enfin",
  "genre",
  "bah",
];

type SujetOral = {
  id: string;
  enonce: string;
  accrocheModele: string;
  positionModele: string;
  chuteModele: string;
};

const SUJETS_ORAL: ReadonlyArray<SujetOral> = [
  {
    id: "o1",
    enonce: "Le ramassage des ordures dans votre quartier.",
    accrocheModele: "Dans notre quartier, le camion de la commune passe une fois par mois.",
    positionModele:
      "Je pense que nous devons écrire à la mairie plutôt que de ramasser nous-mêmes.",
    chuteModele:
      "Nous pouvons nettoyer la rue. Nous ne pouvons pas nettoyer la rue chaque mois pendant dix ans.",
  },
  {
    id: "o2",
    enonce: "L'interdiction des sacs plastiques.",
    accrocheModele:
      "Il y a douze tonnes de sachets dans les caniveaux de Bonabéri. On les a pesés.",
    positionModele:
      "Je pense qu'il faut interdire la production et l'importation, pas la détention.",
    chuteModele: "On ne vide pas une baignoire en épongeant le sol. On ferme le robinet.",
  },
  {
    id: "o3",
    enonce: "Le reboisement et son suivi.",
    accrocheModele:
      "L'an dernier, nous avons planté quarante manguiers dans la cour. Il en reste six.",
    positionModele:
      "Je pense qu'il faut payer l'arbre vivant à trois ans, et non le plant mis en terre.",
    chuteModele: "Cessons de compter les trous. Comptons les arbres.",
  },
  {
    id: "o4",
    enonce: "Les motos-taxis en centre-ville.",
    accrocheModele: "Dans mon quartier, il n'y a pas de bus. Il n'y en a jamais eu.",
    positionModele: "Je pense qu'il faut encadrer les motos avant d'envisager de les interdire.",
    chuteModele:
      "Interdire la moto sans mettre un bus à la place, ce n'est pas supprimer un danger : c'est supprimer un déplacement.",
  },
  {
    id: "o5",
    enonce: "Le téléphone dans l'établissement.",
    accrocheModele:
      "Pour beaucoup d'élèves de ma classe, le téléphone est le seul dictionnaire de la maison.",
    positionModele: "Je pense qu'il faut l'interdire en classe, et l'autoriser à la récréation.",
    chuteModele: "Le problème n'est pas l'objet, c'est le moment. Et un moment, cela se décide.",
  },
  {
    id: "o6",
    enonce: "L'eau au robinet du quartier.",
    accrocheModele:
      "Quatre cents maisons, un robinet, deux heures d'eau par jour. Ce sont les chiffres de notre secteur.",
    positionModele:
      "Je pense que le comité de quartier doit demander des comptes sur la cotisation de l'an dernier.",
    chuteModele:
      "Quatre heures passées dans une file ne figurent sur aucun budget. C'est pourquoi personne ne les compte.",
  },
  {
    id: "o7",
    enonce: "La propreté du marché.",
    accrocheModele:
      "Le marché ouvre à cinq heures. Le ramassage, lui, est prévu à midi, quand tout est vendu.",
    positionModele: "Je pense qu'il faut déplacer l'horaire de collecte, pas blâmer les vendeuses.",
    chuteModele:
      "On ne nettoie pas un marché après la vente. On le nettoie avant l'ouverture, ou pas du tout.",
  },
  {
    id: "o8",
    enonce: "La route de l'école.",
    accrocheModele: "Treize élèves de ma classe marchent plus d'une heure, matin et soir.",
    positionModele:
      "Je pense que l'établissement doit décaler l'heure du premier cours d'une demi-heure.",
    chuteModele:
      "On ne rattrape pas deux heures de marche avec de la bonne volonté. On les rattrape avec une demi-heure.",
  },
  {
    id: "o9",
    enonce: "Les inondations de septembre.",
    accrocheModele: "Chaque année, on accuse la pluie. Chaque année, le caniveau n'a pas été curé.",
    positionModele:
      "Je pense qu'il faut un curage avant la saison, et une date écrite, pas une promesse.",
    chuteModele: "La pluie tombe en septembre depuis toujours. Le curage, lui, est une décision.",
  },
  {
    id: "o10",
    enonce: "Le travail des élèves pendant les vacances.",
    accrocheModele:
      "Sept élèves de ma classe ont travaillé au marché pendant les grandes vacances.",
    positionModele:
      "Je pense qu'il ne faut pas les juger, mais regarder ce que l'école leur coûte.",
    chuteModele:
      "On ne choisit pas entre l'école et le repas. On subit ce choix — et c'est à nous de le supprimer.",
  },
];

const SUJET_ORAL_VIDE: SujetOral = {
  id: "",
  enonce: "—",
  accrocheModele: "—",
  positionModele: "—",
  chuteModele: "—",
};

export function InterventionOrale() {
  const [i, setI] = useState(0);
  const [blocs, setBlocs] = useState({ accroche: "", position: "", arguments: "", chute: "" });
  const [silences, setSilences] = useState(0);
  const [modeles, setModeles] = useState(false);
  const [aTraquer, setATraquer] = useState("");

  const s = SUJETS_ORAL[i] ?? SUJET_ORAL_VIDE;

  const texte = `${blocs.accroche} ${blocs.position} ${blocs.arguments} ${blocs.chute}`.trim();
  const mots = texte.length === 0 ? 0 : texte.split(/\s+/).length;
  /* Un orateur posé dit environ 140 mots par minute, silences compris. */
  const secondes = Math.round((mots / 140) * 60) + silences * 2;

  const aTexte = aTraquer.trim().length > 0 ? aTraquer : texte;
  const motsTraques = aTexte.length === 0 ? 0 : aTexte.trim().split(/\s+/).length;
  const comptes = TICS.map((t) => ({
    tic: t,
    n: (aTexte.toLowerCase().match(new RegExp(`\\b${t}\\b`, "g")) ?? []).length,
  })).filter((c) => c.n > 0);
  const totalTics = comptes.reduce((a, c) => a + c.n, 0);
  const part = motsTraques > 0 ? Math.round((totalTics / motsTraques) * 100) : 0;

  const positionTot = blocs.accroche.split(/\s+/).length <= 30;

  return (
    <div className="space-y-3">
      <p className="text-sm text-muted-foreground">
        Quatre blocs, deux minutes. Et la position se donne dans les quinze premières secondes :
        sinon l'auditeur écoute sans savoir quoi écouter.
      </p>

      <div className="rounded-lg border border-border bg-background p-3">
        <p className="text-sm font-semibold text-foreground">{s.enonce}</p>

        <div className="mt-3 space-y-2">
          {(
            [
              {
                cle: "accroche" as const,
                label: "1. L'accroche — un fait, un chiffre, une question",
                modele: s.accrocheModele,
              },
              {
                cle: "position" as const,
                label: "2. La position — ce que tu défends, en une phrase",
                modele: s.positionModele,
              },
              {
                cle: "arguments" as const,
                label: "3. Les arguments — deux, annoncés et séparés",
                modele: "Et je dis cela pour deux raisons. D'abord… Ensuite…",
              },
              {
                cle: "chute" as const,
                label: "4. La chute — la phrase qui reste",
                modele: s.chuteModele,
              },
            ] as const
          ).map((b) => (
            <div key={b.cle}>
              <p className="text-[11px] font-semibold text-muted-foreground">{b.label}</p>
              <textarea
                value={blocs[b.cle]}
                onChange={(e) => setBlocs((x) => ({ ...x, [b.cle]: e.target.value }))}
                rows={b.cle === "arguments" ? 4 : 2}
                className="mt-0.5 w-full rounded-md border border-border bg-background px-2.5 py-1.5 text-sm text-foreground"
              />
              {modeles ? (
                <p className="mt-0.5 text-[11px] italic text-muted-foreground">
                  modèle : {b.modele}
                </p>
              ) : null}
            </div>
          ))}
        </div>

        <div className="mt-3">
          <Ctrl
            label="Silences placés dans ton texte"
            value={silences}
            min={0}
            max={4}
            step={1}
            onChange={(v) => setSilences(Math.round(v))}
            display={`${silences} pause${silences > 1 ? "s" : ""} de deux secondes`}
            color={PALETTE.purple}
          />
        </div>

        <div className="mt-3 flex flex-wrap gap-2 text-[11px]">
          {mots > 0 ? (
            <span
              className="rounded px-2 py-0.5"
              style={{
                backgroundColor: secondes <= 130 ? "rgba(21,128,61,0.12)" : "rgba(185,28,28,0.12)",
                color: secondes <= 130 ? "#14532d" : "#7f1d1d",
              }}
            >
              durée estimée : {Math.floor(secondes / 60)} min {secondes % 60} s
              {secondes > 130 ? " — tu dépasses les deux minutes" : ""}
            </span>
          ) : null}
          <span
            className="rounded px-2 py-0.5"
            style={{
              backgroundColor: positionTot ? "rgba(21,128,61,0.12)" : "rgba(202,138,4,0.12)",
              color: positionTot ? "#14532d" : "#78350f",
            }}
          >
            {positionTot
              ? "la position arrive assez tôt"
              : "ton accroche est longue : la position arrivera trop tard"}
          </span>
          {silences > 0 ? (
            <span
              className="rounded px-2 py-0.5"
              style={{ backgroundColor: "rgba(124,58,237,0.12)", color: "#4c1d95" }}
            >
              deux secondes de silence paraissent une éternité de l'intérieur, et passent inaperçues
              de l'extérieur
            </span>
          ) : null}
        </div>

        <button
          type="button"
          onClick={() => setModeles((m) => !m)}
          className="mt-3 rounded-lg border border-border px-3 py-1.5 text-xs font-semibold text-foreground"
        >
          {modeles ? "Masquer les modèles" : "Voir des modèles"}
        </button>
      </div>

      <div className="rounded-lg border border-border bg-background p-3">
        <p className="text-xs font-semibold text-foreground">Le traqueur de tics</p>
        <p className="mt-0.5 text-[11px] text-muted-foreground">
          Colle ici une transcription de ta parole, ou laisse vide pour analyser ton intervention
          ci-dessus. On ne les entend pas chez soi ; on les compte chez les autres.
        </p>
        <textarea
          value={aTraquer}
          onChange={(e) => setATraquer(e.target.value)}
          rows={3}
          className="mt-1 w-full rounded-md border border-border bg-background px-2.5 py-1.5 text-sm text-foreground"
          placeholder="euh, bonjour, alors moi je voulais dire que du coup…"
        />
        {motsTraques > 0 ? (
          <div className="mt-2 space-y-1.5">
            <div className="flex flex-wrap gap-1.5">
              {comptes.length > 0 ? (
                comptes.map((c) => (
                  <span
                    key={c.tic}
                    className="rounded px-2 py-0.5 text-[11px]"
                    style={{ backgroundColor: "rgba(185,28,28,0.12)", color: "#7f1d1d" }}
                  >
                    {c.tic} × {c.n}
                  </span>
                ))
              ) : (
                <span
                  className="rounded px-2 py-0.5 text-[11px]"
                  style={{ backgroundColor: "rgba(21,128,61,0.12)", color: "#14532d" }}
                >
                  aucun tic repéré
                </span>
              )}
            </div>
            <Verdict tone={part === 0 ? "ok" : part < 8 ? "warn" : "bad"}>
              <span className="font-semibold">
                {totalTics} mot{totalTics > 1 ? "s" : ""} vide{totalTics > 1 ? "s" : ""} sur{" "}
                {motsTraques}, soit {part} %.{" "}
              </span>
              {part >= 15
                ? "Un quart de mots vides : c'est la proportion d'une intervention improvisée. Remplace chaque hésitation par un silence — c'est le même temps, et ce n'est pas le même effet."
                : part > 0
                  ? "C'est tenable, mais chaque tic retiré rend la phrase suivante plus nette."
                  : "Non parce qu'on n'hésite jamais, mais parce qu'on a appris à remplacer l'hésitation par un silence."}
            </Verdict>
          </div>
        ) : null}

        <button
          type="button"
          onClick={() => {
            setI((n) => (n + 1) % SUJETS_ORAL.length);
            setBlocs({ accroche: "", position: "", arguments: "", chute: "" });
            setSilences(0);
            setATraquer("");
            setModeles(false);
          }}
          className="mt-2 rounded-lg bg-primary px-3 py-1.5 text-xs font-semibold text-primary-foreground"
        >
          Sujet suivant ({i + 1} / {SUJETS_ORAL.length})
        </button>
      </div>

      <Citation auteur="ce qu'il faut supprimer, et qu'on n'ose pas">
        Les excuses d'entrée — « je ne suis pas très bon pour parler », « je n'ai pas eu le temps de
        préparer ». Elles ne te protègent pas : elles préviennent l'auditoire qu'il peut t'écouter
        distraitement.
      </Citation>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* 5. Remonter l'échelle de l'opposition                               */
/* ------------------------------------------------------------------ */

type Replique = {
  id: string;
  brute: string;
  /** 0 = courtois, 4 = blessant. */
  niveau: number;
  faute: "aucune" | "personne" | "paille";
  idee: string;
  /** Ce que l'autre avait réellement dit, pour l'homme de paille. */
  ditReel?: string;
  ditPrete?: string;
  modele: string;
  commentaire: string;
};

const ECHELLE_OPPOSITION: ReadonlyArray<string> = [
  "« Je comprends ton point de vue, et pourtant il me semble que… »",
  "« Tu as raison sur un point, mais je ne te suis pas sur… »",
  "« Je ne suis pas d'accord, et voici pourquoi. »",
  "« C'est faux. »",
  "« N'importe quoi. Tu n'y connais rien. »",
];

const REPLIQUES: ReadonlyArray<Replique> = [
  {
    id: "rp1",
    brute: "C'est complètement faux, les motos ne polluent pas plus que les voitures.",
    niveau: 3,
    faute: "aucune",
    idee: "Comparer la pollution des motos et des voitures.",
    modele:
      "Je ne suis pas sûr de te suivre sur ce point. À nombre de trajets égal, une moto consomme moins qu'une voiture ; sur quoi t'appuies-tu pour dire le contraire ?",
    commentaire:
      "L'idée était bonne ; « complètement faux » fermait la porte. Et la demande de preuve est plus forte qu'une contradiction : elle oblige l'autre à chercher sans l'humilier.",
  },
  {
    id: "rp2",
    brute: "Tu dis ça parce que tu n'habites pas le quartier.",
    niveau: 4,
    faute: "personne",
    idee: "L'expérience du quartier apporte quelque chose au débat.",
    modele:
      "C'est peut-être différent vu du quartier. Je peux te dire ce qu'on y observe, et tu me diras si cela change quelque chose à ton raisonnement.",
    commentaire:
      "La réplique brute ne s'attaquait pas à l'idée mais à la personne : que l'orateur habite ou non le quartier ne rend son argument ni vrai ni faux. L'idée utile a été gardée, et transformée en apport.",
  },
  {
    id: "rp3",
    brute: "N'importe quoi, il n'y a jamais eu d'inondation à cet endroit.",
    niveau: 4,
    faute: "aucune",
    idee: "Les souvenirs des deux interlocuteurs divergent.",
    modele:
      "Là je crois que nous n'avons pas les mêmes souvenirs. Moi je me rappelle septembre 2022 ; de quelle période parles-tu ?",
    commentaire:
      "L'affirmation était vérifiable : c'est le cas où la demande de précision est imparable. Inutile d'y ajouter « n'importe quoi ».",
  },
  {
    id: "rp4",
    brute: "Donc d'après toi il faut laisser mourir les commerçants.",
    niveau: 4,
    faute: "paille",
    idee: "L'interdiction a un coût pour les petits commerçants.",
    ditReel: "Il faut interdire les sacs plastiques.",
    ditPrete: "Il faut laisser mourir les commerçants.",
    modele:
      "Si je comprends bien, tu proposes d'interdire les sacs plastiques même lorsque les petits commerçants n'ont pas d'autre solution. C'est bien cela ? Parce que si c'est cela, c'est ce point-là qui me gêne.",
    commentaire:
      "Homme de paille. La réplique corrigée demande confirmation, désigne précisément le point de désaccord, et laisse à l'autre la possibilité de dire « non, ce n'est pas ce que je voulais dire ». Dans la moitié des cas, le désaccord se dissout à cet instant.",
  },
  {
    id: "rp5",
    brute: "Tu n'as rien compris au problème.",
    niveau: 4,
    faute: "personne",
    idee: "Le problème a été mal posé.",
    modele:
      "Je crois que nous ne parlons pas du même problème. Toi tu parles du ramassage, moi je parle de la collecte en amont. Reprenons d'abord ce point.",
    commentaire:
      "« Tu n'as rien compris » attaque la personne. La version corrigée transforme l'accusation en malentendu à lever — et c'en est souvent un.",
  },
  {
    id: "rp6",
    brute: "Donc tu veux qu'on ne fasse rien du tout.",
    niveau: 4,
    faute: "paille",
    idee: "L'autre propose d'attendre l'action de la commune.",
    ditReel: "Je pense qu'il faut écrire à la mairie plutôt que de ramasser nous-mêmes.",
    ditPrete: "Il ne faut rien faire du tout.",
    modele:
      "Si je te suis, tu préfères écrire à la mairie plutôt que ramasser nous-mêmes. Ce n'est donc pas « ne rien faire », c'est faire autre chose. Mais j'ai une objection sur le délai.",
    commentaire:
      "Écrire une lettre n'est pas ne rien faire. Le reformuler le dit sans qu'on ait besoin de le reprocher.",
  },
  {
    id: "rp7",
    brute: "C'est n'importe quoi, les chiffres sont faux.",
    niveau: 4,
    faute: "aucune",
    idee: "Les chiffres avancés méritent vérification.",
    modele:
      "Ces chiffres me surprennent. D'où viennent-ils ? Si c'est le rapport communal, j'aimerais le lire, parce que ceux de l'association donnent autre chose.",
    commentaire:
      "La demande de source est la formule la plus puissante et la plus courtoise du débat. Elle ne nie rien ; elle demande. Et bien souvent, l'autre découvre lui-même qu'il n'a pas de source.",
  },
  {
    id: "rp8",
    brute: "Tu parles comme quelqu'un qui n'a jamais travaillé.",
    niveau: 4,
    faute: "personne",
    idee: "La réalité du travail manque à l'argument.",
    modele:
      "Ton raisonnement tient si l'on peut choisir ses horaires. Pour quelqu'un qui part à cinq heures, est-ce encore vrai ?",
    commentaire:
      "On a retiré la personne et gardé la condition. L'objection est devenue plus forte, pas plus faible.",
  },
  {
    id: "rp9",
    brute: "Tout le monde sait que c'est la faute de la mairie.",
    niveau: 3,
    faute: "aucune",
    idee: "La responsabilité de la mairie est engagée.",
    modele:
      "Je crois la mairie responsable, et voici sur quoi je m'appuie : le bac a été retiré en janvier et n'a jamais été remplacé.",
    commentaire:
      "« Tout le monde sait » est une formule creuse : si c'était évident, tu n'aurais pas besoin de le dire. Remplace-la par un fait.",
  },
  {
    id: "rp10",
    brute: "Arrête, ça ne sert à rien de discuter avec toi.",
    niveau: 4,
    faute: "personne",
    idee: "La discussion tourne en rond.",
    modele:
      "Nous tournons en rond sur ce point. Je propose qu'on note notre désaccord et qu'on avance sur le reste : sur quoi sommes-nous d'accord ?",
    commentaire:
      "Clore une impasse n'oblige pas à disqualifier l'interlocuteur. Nommer l'impasse et chercher l'accord fait avancer le débat.",
  },
  {
    id: "rp11",
    brute: "Évidemment que j'ai raison, c'est logique.",
    niveau: 3,
    faute: "aucune",
    idee: "L'argument paraît aller de soi à celui qui le porte.",
    modele:
      "Cela me paraît découler de ce qui précède, mais dis-moi si l'enchaînement te semble tenir : si le bac manque, alors les sacs vont ailleurs.",
    commentaire:
      "« C'est logique » n'est pas un argument : c'est une affirmation sur son propre argument. Montre l'enchaînement, et laisse l'autre le juger.",
  },
  {
    id: "rp12",
    brute: "Donc selon toi les jeunes sont tous des délinquants.",
    niveau: 4,
    faute: "paille",
    idee: "Une partie des conducteurs ne respecte pas les règles.",
    ditReel: "Beaucoup de motos circulent sans casque et sans assurance.",
    ditPrete: "Tous les jeunes sont des délinquants.",
    modele:
      "Tu dis que beaucoup circulent sans casque ni assurance : est-ce que tu penses que c'est la majorité, ou une partie ? Parce que la mesure à prendre n'est pas la même.",
    commentaire:
      "De « beaucoup » à « tous », il y a un homme de paille. Et la question posée est utile : la proportion décide de la mesure.",
  },
  {
    id: "rp13",
    brute: "C'est faux, point final.",
    niveau: 3,
    faute: "aucune",
    idee: "Le désaccord porte sur un fait.",
    modele:
      "Je ne suis pas d'accord, et voici pourquoi : les chiffres du service technique donnent six bacs pour quarante mille habitants.",
    commentaire:
      "« Je ne suis pas d'accord, et voici pourquoi » est le barreau neutre de l'échelle, et il est parfaitement acceptable. C'est « point final » qui ferme.",
  },
  {
    id: "rp14",
    brute: "Tu te contredis depuis le début.",
    niveau: 4,
    faute: "personne",
    idee: "Deux affirmations de l'autre semblent incompatibles.",
    modele:
      "Il y a deux choses que je n'arrive pas à faire tenir ensemble : tu dis que la commune doit agir, et que les habitants doivent ramasser. Comment les concilies-tu ?",
    commentaire:
      "On a remplacé l'accusation par la contradiction précise. L'autre peut alors répondre — ou reconnaître, ce qui arrive.",
  },
  {
    id: "rp15",
    brute: "Je ne vois pas comment tu peux croire une chose pareille.",
    niveau: 4,
    faute: "personne",
    idee: "La position de l'autre paraît infondée.",
    modele:
      "J'ai du mal à voir sur quoi repose cette position. Qu'est-ce qui te la fait tenir ? Si c'est un fait que j'ignore, je veux bien l'entendre.",
    commentaire:
      "La version brute juge la personne qui croit ; la version corrigée interroge ce qui fonde la croyance. C'est la même objection, et elle devient recevable.",
  },
  {
    id: "rp16",
    brute: "Bien sûr, monsieur sait tout mieux que tout le monde.",
    niveau: 4,
    faute: "personne",
    idee: "L'autre paraît ne pas écouter les objections.",
    modele:
      "J'ai l'impression que mes objections n'ont pas été prises en compte. Peux-tu me dire ce que tu réponds à la première ?",
    commentaire:
      "L'ironie contre une personne est une attaque déguisée. Demander une réponse à l'objection obtient exactement ce qu'on voulait.",
  },
  {
    id: "rp17",
    brute: "Tu as raison, je n'avais pas pensé à cela.",
    niveau: 0,
    faute: "aucune",
    idee: "Reconnaître une objection juste.",
    modele: "Tu as raison, je n'avais pas pensé à cela. Je reprends donc mon second argument.",
    commentaire:
      "Celle-ci n'avait pas besoin d'être corrigée. Elle coûte dix secondes et rapporte beaucoup : elle montre qu'on discute pour comprendre, pas pour gagner. Dans un débat scolaire comme dans une réunion, celui qui sait la dire est écouté davantage, pas moins.",
  },
  {
    id: "rp18",
    brute: "Donc tu es contre le développement du pays.",
    niveau: 4,
    faute: "paille",
    idee: "L'exploitation forestière a des effets sur les riverains.",
    ditReel: "L'exploitation de cette forêt se fait au mépris des villageois.",
    ditPrete: "Il ne faut pas développer le pays.",
    modele:
      "Tu critiques la façon dont cette concession est exploitée, pas l'idée d'exploiter. C'est bien cela ? Alors la question est : quelles conditions mettrais-tu ?",
    commentaire:
      "Critiquer une manière de faire n'est pas s'opposer à ce qu'on fait. L'homme de paille élargit l'objection pour la rendre absurde.",
  },
  {
    id: "rp19",
    brute: "On a déjà essayé, ça n'a jamais marché.",
    niveau: 2,
    faute: "aucune",
    idee: "Les tentatives passées ont échoué.",
    modele:
      "On a déjà essayé, et cela n'a pas marché. Mais sais-tu pourquoi cela a échoué ? Si c'est faute de suivi, ce n'est pas la mesure qui était mauvaise.",
    commentaire:
      "La réplique de départ est déjà acceptable : elle est neutre et factuelle. Y ajouter la question du « pourquoi » la rend utile au lieu de bloquer.",
  },
  {
    id: "rp20",
    brute: "C'est toi qui ne comprends rien aux chiffres.",
    niveau: 4,
    faute: "personne",
    idee: "Un chiffre a été mal interprété.",
    modele:
      "Je crois qu'on lit ce chiffre différemment. Neuf cents sur mille deux cents, c'est soixante-quinze pour cent de survie, pas soixante-quinze pour cent de pertes. On est d'accord sur le chiffre, pas sur sa lecture.",
    commentaire:
      "La correction porte sur la lecture du chiffre, pas sur l'intelligence de l'interlocuteur. Et elle nomme l'accord avant le désaccord.",
  },
];

const REPLIQUE_VIDE: Replique = {
  id: "",
  brute: "—",
  niveau: 2,
  faute: "aucune",
  idee: "—",
  modele: "—",
  commentaire: "—",
};

export function ContredirePoliment() {
  const [i, setI] = useState(0);
  const [saisie, setSaisie] = useState("");
  const [montre, setMontre] = useState(false);

  const r = REPLIQUES[i] ?? REPLIQUE_VIDE;

  const courtois = /\b(je comprends|tu as raison|il y a du vrai|je te rejoins|c'est vrai)/i.test(
    saisie,
  );
  const demande = /\?/.test(saisie);
  const reformule = /\b(si je comprends bien|si je te suis|tu dis que|tu proposes)/i.test(saisie);
  const brutal = /\b(n'importe quoi|c'est faux|tu n'y connais rien|arrête|point final)/i.test(
    saisie,
  );
  const attaquePersonne = /\btu (es|parles comme|n'as rien|te contredis|ne comprends)\b/i.test(
    saisie,
  );

  const niveauEstime = brutal
    ? 4
    : attaquePersonne
      ? 4
      : courtois || reformule
        ? 0
        : demande
          ? 1
          : 2;
  const gain = r.niveau - niveauEstime;

  return (
    <div className="space-y-3">
      <p className="text-sm text-muted-foreground">
        Réécris la réplique en gardant l'idée. On attaque l'idée, jamais celui qui la porte.
      </p>

      <div className="rounded-lg border border-border bg-background p-3">
        <p className="text-[11px] font-semibold text-muted-foreground">L'ÉCHELLE</p>
        <div className="mt-1 space-y-0.5">
          {ECHELLE_OPPOSITION.map((e, k) => (
            <p
              key={e}
              className="rounded px-2 py-1 text-[11px]"
              style={{
                backgroundColor:
                  k === r.niveau
                    ? "rgba(185,28,28,0.14)"
                    : k === niveauEstime && saisie.length > 10
                      ? "rgba(21,128,61,0.14)"
                      : "transparent",
                color: k <= 1 ? PALETTE.green : k === 2 ? PALETTE.slate : PALETTE.red,
              }}
            >
              {e}
              {k === r.niveau ? "  ← la réplique de départ" : ""}
              {k === niveauEstime && saisie.length > 10 ? "  ← ta version" : ""}
            </p>
          ))}
        </div>

        <p className="mt-3 text-base italic text-foreground">« {r.brute} »</p>
        <p className="mt-1 text-[11px] text-muted-foreground">L'idée à conserver : {r.idee}</p>

        {r.faute === "paille" && r.ditReel !== undefined ? (
          <div className="mt-2 grid gap-2 sm:grid-cols-2">
            <div
              className="rounded-md px-2.5 py-2"
              style={{ backgroundColor: "rgba(37,99,235,0.08)" }}
            >
              <p className="text-[11px] font-semibold" style={{ color: PALETTE.blue }}>
                ce que l'autre a dit
              </p>
              <p className="mt-0.5 text-xs text-foreground">{r.ditReel}</p>
            </div>
            <div
              className="rounded-md px-2.5 py-2"
              style={{ backgroundColor: "rgba(185,28,28,0.08)" }}
            >
              <p className="text-[11px] font-semibold" style={{ color: PALETTE.red }}>
                ce qu'on lui fait dire
              </p>
              <p className="mt-0.5 text-xs text-foreground">{r.ditPrete ?? ""}</p>
            </div>
          </div>
        ) : null}

        {r.faute === "personne" ? (
          <p
            className="mt-2 rounded-md px-2 py-1.5 text-[11px]"
            style={{ backgroundColor: "rgba(185,28,28,0.10)", color: "#7f1d1d" }}
          >
            Faute de principe : cette réplique s'attaque à la personne, pas à l'idée. Que l'autre
            habite ici ou là, ait travaillé ou non, ne rend son argument ni vrai ni faux.
          </p>
        ) : null}

        <textarea
          value={saisie}
          onChange={(e) => setSaisie(e.target.value)}
          rows={3}
          className="mt-3 w-full rounded-md border border-border bg-background px-2.5 py-1.5 text-sm text-foreground"
          placeholder="Ta version, même idée, plus haut sur l'échelle"
        />

        {saisie.trim().length > 10 ? (
          <Verdict tone={gain >= 2 ? "ok" : gain >= 1 ? "warn" : "bad"}>
            <span className="font-semibold">
              {gain >= 2
                ? `Tu as remonté l'échelle de ${gain} barreaux. `
                : gain >= 1
                  ? "Tu as remonté d'un barreau. "
                  : "Ta version reste au même niveau, ou descend. "}
            </span>
            {reformule
              ? "Et tu as reformulé avant de répondre : c'est le geste qui vaut de l'or, parce qu'il évite de combattre une position que l'autre n'a jamais défendue."
              : demande
                ? "Tu as posé une question : « sur quoi t'appuies-tu ? » ne nie rien, et c'est ce qui la rend imparable."
                : attaquePersonne
                  ? "Attention : ta version s'adresse encore à la personne. Retire le « tu » accusateur et garde la condition."
                  : "Ajoute une demande de preuve ou une reformulation : ce sont les deux formules les plus efficaces du débat."}
          </Verdict>
        ) : null}

        <div className="mt-2 flex flex-wrap gap-2">
          <button
            type="button"
            onClick={() => setMontre(true)}
            className="rounded-lg border border-border px-3 py-1.5 text-xs font-semibold text-foreground"
          >
            Voir une version possible
          </button>
          <button
            type="button"
            onClick={() => {
              setI((n) => (n + 1) % REPLIQUES.length);
              setSaisie("");
              setMontre(false);
            }}
            className="rounded-lg bg-primary px-3 py-1.5 text-xs font-semibold text-primary-foreground"
          >
            Réplique suivante ({i + 1} / {REPLIQUES.length})
          </button>
        </div>

        {montre ? (
          <div className="mt-2 space-y-1.5">
            <Verdict tone="ok">
              <span className="font-semibold">Une version possible. </span>
              {r.modele}
            </Verdict>
            <p className="text-[11px] italic text-muted-foreground">{r.commentaire}</p>
          </div>
        ) : null}
      </div>

      <Citation auteur="pourquoi c'est une question d'efficacité, pas de politesse">
        Celui qu'on humilie ne change jamais d'avis : il se défend. Plus on descend l'échelle, moins
        on a de chances d'être écouté — et l'on peut parfaitement avoir raison, et avoir perdu.
      </Citation>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* 6. Le débat réglé                                                   */
/* ------------------------------------------------------------------ */

type Tour = {
  qui: string;
  propos: string;
  /** La faute commise, s'il y en a une. */
  faute: "aucune" | "coupe" | "personne" | "paille" | "modere";
  reprise: string;
  /** Secondes de parole consommées. */
  duree: number;
};

type Debat = {
  id: string;
  sujet: string;
  tours: ReadonlyArray<Tour>;
  accords: ReadonlyArray<string>;
  desaccord: string;
  repeche: string;
  suite: string;
};

const NOM_FAUTE: Record<Tour["faute"], string> = {
  aucune: "rien à reprendre",
  coupe: "il coupe la parole",
  personne: "il attaque la personne",
  paille: "il construit un homme de paille",
  modere: "le modérateur donne son avis",
};

const DEBATS: ReadonlyArray<Debat> = [
  {
    id: "db1",
    sujet: "Faut-il interdire les motos-taxis en centre-ville ?",
    tours: [
      {
        qui: "A",
        propos:
          "Il faut interdire les motos-taxis en centre-ville, elles causent trop d'accidents.",
        faute: "aucune",
        reprise: "Rien à reprendre : une position, une raison. C'est une intervention correcte.",
        duree: 25,
      },
      {
        qui: "B",
        propos: "Et les milliers de jeunes qui en vivent, tu y penses ?",
        faute: "coupe",
        reprise:
          "B a coupé A. L'objection était bonne ; elle aurait été meilleure attendue. Rappelle la règle 3, sans la lui reprocher longuement.",
        duree: 10,
      },
      {
        qui: "A",
        propos: "Donc pour toi la vie des gens ne compte pas.",
        faute: "paille",
        reprise:
          "Homme de paille : B n'a jamais dit cela. Il a dit que des jeunes vivent de cette activité. Demande à A de reformuler ce que B a réellement dit.",
        duree: 8,
      },
      {
        qui: "B",
        propos: "N'importe quoi. Tu parles comme quelqu'un qui a une voiture.",
        faute: "personne",
        reprise:
          "Deux fautes d'un coup : « n'importe quoi » est le dernier barreau de l'échelle, et « tu parles comme quelqu'un qui a une voiture » attaque la personne. Que A ait une voiture ne rend son argument ni vrai ni faux.",
        duree: 12,
      },
      {
        qui: "C",
        propos: "Moi je voudrais dire que dans mon quartier il n'y a pas de bus.",
        faute: "aucune",
        reprise:
          "C'est l'intervention la plus utile du débat : elle introduit le vrai problème, l'absence de transport public. Protège-la.",
        duree: 15,
      },
      {
        qui: "A",
        propos: "On n'est pas là pour parler de ton quartier.",
        faute: "coupe",
        reprise:
          "A coupe C et disqualifie son apport, au motif qu'il vient d'un cas particulier — alors qu'un cas particulier est précisément un exemple. Redonne la parole à C.",
        duree: 7,
      },
      {
        qui: "Modérateur",
        propos: "Moi je pense que B a raison.",
        faute: "modere",
        reprise:
          "La faute la plus grave, parce qu'elle ruine le rôle. Un modérateur qui prend parti ne peut plus distribuer la parole équitablement, et plus personne ne lui fait confiance.",
        duree: 6,
      },
    ],
    accords: ["les motos-taxis causent des accidents", "elles font vivre beaucoup de jeunes"],
    desaccord:
      "A considère que le danger justifie l'interdiction ; B considère qu'elle priverait des familles de leur revenu sans rien proposer à la place.",
    repeche:
      "C a introduit un élément qui n'a pas été traité : s'il n'y a pas de bus dans les quartiers périphériques, interdire les motos revient à y supprimer le transport.",
    suite:
      "Non pas « faut-il interdire », mais « que faut-il mettre à la place, et dans quel ordre ».",
  },
  {
    id: "db2",
    sujet: "Les habitants doivent-ils ramasser eux-mêmes leurs ordures ?",
    tours: [
      {
        qui: "A",
        propos:
          "Les jeunes qui nettoient les caniveaux font un travail que la commune devrait faire, et ils ont raison de le faire.",
        faute: "aucune",
        reprise: "Position et raison. Correct.",
        duree: 22,
      },
      {
        qui: "B",
        propos: "Donc tu trouves normal que la mairie ne fasse rien ?",
        faute: "paille",
        reprise:
          "A n'a pas dit que c'était normal : il a dit que les jeunes avaient raison d'agir. Demande une reformulation.",
        duree: 9,
      },
      {
        qui: "A",
        propos:
          "Je n'ai pas dit cela. J'ai dit qu'en attendant, il faut bien que quelqu'un le fasse.",
        faute: "aucune",
        reprise:
          "A corrige calmement sans attaquer. C'est exactement la bonne réaction à un homme de paille.",
        duree: 12,
      },
      {
        qui: "B",
        propos:
          "Alors on paie deux fois : une fois en taxes, une fois en sueur. Et le bac retiré en janvier ne sera jamais remplacé.",
        faute: "aucune",
        reprise: "Un argument et un exemple daté. C'est la meilleure intervention du débat.",
        duree: 18,
      },
      {
        qui: "C",
        propos: "On ne va pas laisser pourrir les rues pour prouver que la mairie a tort.",
        faute: "aucune",
        reprise: "C'est une concession adressée à B, et elle est juste. Le débat avance.",
        duree: 11,
      },
      {
        qui: "A",
        propos: "Voilà, c'est ce que je dis depuis le début, tu ne m'écoutes pas.",
        faute: "personne",
        reprise:
          "« Tu ne m'écoutes pas » s'adresse à la personne. A pouvait dire : « c'est le point que je défendais », et s'arrêter là.",
        duree: 8,
      },
      {
        qui: "Modérateur",
        propos: "Bon, de toute façon tout le monde sait que c'est la faute de la mairie.",
        faute: "modere",
        reprise:
          "Le modérateur prend parti, et il emploie en plus une formule creuse — « tout le monde sait ». Deux fautes.",
        duree: 7,
      },
    ],
    accords: [
      "le ramassage des ordures incombe à la commune",
      "on ne peut pas laisser les rues en l'état pour faire la preuve d'un manquement",
    ],
    desaccord:
      "A pense qu'il faut ramasser en attendant ; B pense que ramasser dispense la commune d'agir.",
    repeche:
      "C a posé la limite que les deux acceptaient sans le dire : on ne punit pas le quartier pour forcer la main d'une mairie.",
    suite:
      "Non pas « ramasser ou non », mais « que fait-on du ramassage » — le compter, l'afficher, l'adresser.",
  },
  {
    id: "db3",
    sujet: "Faut-il enseigner dans la langue maternelle les premières années ?",
    tours: [
      {
        qui: "A",
        propos:
          "Un enfant qui apprend à lire dans une langue qu'il ne parle pas apprend deux choses à la fois, et rate les deux.",
        faute: "aucune",
        reprise: "Un argument clair et bien formulé.",
        duree: 20,
      },
      {
        qui: "B",
        propos: "Mais on ne va pas imprimer des manuels dans deux cents langues !",
        faute: "coupe",
        reprise:
          "L'objection est excellente — et elle a coupé A au milieu. Note-la, et rends la parole à A d'abord.",
        duree: 10,
      },
      {
        qui: "A",
        propos: "Tu caricatures, personne n'a parlé de deux cents manuels.",
        faute: "aucune",
        reprise:
          "A a raison sur le fond, mais « tu caricatures » reste un reproche. « Je n'ai pas dit deux cents, j'ai dit les langues véhiculaires » aurait suffi.",
        duree: 9,
      },
      {
        qui: "C",
        propos:
          "Dans mon village, les enfants parlent tous la même langue. Dans la ville voisine, il y en a cinq.",
        faute: "aucune",
        reprise:
          "Un exemple précis, qui montre que la réponse n'est pas la même partout. Intervention très utile.",
        duree: 16,
      },
      {
        qui: "B",
        propos: "Donc tu es contre le français.",
        faute: "paille",
        reprise:
          "C n'a rien dit du français : il a dit que la situation varie selon les lieux. Homme de paille.",
        duree: 6,
      },
      {
        qui: "A",
        propos:
          "Je propose qu'on sépare deux questions : quelle langue, et à quel moment de la scolarité.",
        faute: "aucune",
        reprise:
          "C'est un déplacement de la question, et c'est ce qui débloque un débat enlisé. Appuie-le.",
        duree: 14,
      },
      {
        qui: "Modérateur",
        propos: "C'est exactement ce que je pensais depuis le début.",
        faute: "modere",
        reprise:
          "Même si l'idée est bonne, le modérateur n'a pas à dire ce qu'il pense. Il peut en revanche dire : « ce déplacement me paraît structurer le débat, poursuivons sur ce point ».",
        duree: 5,
      },
    ],
    accords: [
      "un enfant comprend mieux dans la langue qu'il parle",
      "on ne peut pas produire des manuels dans toutes les langues du pays",
    ],
    desaccord:
      "A veut commencer en langue maternelle ; B craint l'impossibilité matérielle et l'enfermement local.",
    repeche:
      "C a montré que la réponse dépend du lieu : un village d'une seule langue et une ville de cinq ne se traitent pas de la même façon.",
    suite: "Non pas « quelle langue », mais « à quel moment, et selon quelle carte linguistique ».",
  },
  {
    id: "db4",
    sujet: "Le téléphone doit-il être interdit dans l'établissement ?",
    tours: [
      {
        qui: "A",
        propos: "Il faut l'interdire : on triche, et personne ne suit plus le cours.",
        faute: "aucune",
        reprise: "Position et deux raisons. Correct, même si les exemples manquent.",
        duree: 16,
      },
      {
        qui: "B",
        propos: "Et comment je joins ma mère si le car ne vient pas ?",
        faute: "aucune",
        reprise: "Une objection sous forme de cas concret : c'est un exemple, et il porte.",
        duree: 9,
      },
      {
        qui: "A",
        propos: "Tu trouveras bien un moyen, comme avant.",
        faute: "personne",
        reprise:
          "Ce n'est pas un argument, c'est un congé donné à l'objection. Demande à A de répondre sur le fond.",
        duree: 7,
      },
      {
        qui: "C",
        propos: "Chez moi il n'y a pas de dictionnaire. Le téléphone, c'est le seul que j'aie.",
        faute: "aucune",
        reprise: "Un second exemple, d'un autre ordre. Le débat se complique utilement.",
        duree: 13,
      },
      {
        qui: "B",
        propos: "Donc A veut qu'on reste ignorants.",
        faute: "paille",
        reprise:
          "A veut interdire un objet en classe, ce qui n'est pas vouloir l'ignorance. Homme de paille.",
        duree: 6,
      },
      {
        qui: "A",
        propos:
          "Je retire ce que j'ai dit à B : la question du car est réelle, je n'y avais pas pensé.",
        faute: "aucune",
        reprise:
          "Voilà la phrase qui vaut de l'or. Elle coûte dix secondes et elle donne à A plus d'autorité qu'aucun de ses arguments.",
        duree: 11,
      },
      {
        qui: "Modérateur",
        propos: "Franchement, A a été le plus convaincant.",
        faute: "modere",
        reprise: "Le modérateur n'attribue pas de vainqueur. Jamais.",
        duree: 5,
      },
    ],
    accords: [
      "le téléphone en classe facilite la triche et disperse l'attention",
      "il est pour certains élèves le seul lien avec leur famille et le seul dictionnaire",
    ],
    desaccord:
      "A veut l'interdire dans l'établissement ; B et C craignent d'être coupés de l'essentiel.",
    repeche:
      "C a introduit un usage auquel personne n'avait pensé : le téléphone comme unique ouvrage de référence à la maison.",
    suite: "Non pas « interdire ou autoriser », mais « interdire où et quand ».",
  },
  {
    id: "db5",
    sujet: "Les campagnes de reboisement servent-elles à quelque chose ?",
    tours: [
      {
        qui: "A",
        propos: "Elles servent : elles font parler du problème, et il faut bien qu'on en parle.",
        faute: "aucune",
        reprise: "C'est une concession anticipée, et c'est habile. Correct.",
        duree: 15,
      },
      {
        qui: "B",
        propos:
          "Parler ne fait pas pousser. Sur quarante plants mis en terre dans ma cour, il en restait six.",
        faute: "aucune",
        reprise: "Un argument et un exemple chiffré. Très bonne intervention.",
        duree: 17,
      },
      {
        qui: "A",
        propos: "Ton école n'a pas fait son travail, voilà tout.",
        faute: "personne",
        reprise:
          "A déplace la faute sur l'interlocuteur plutôt que de répondre au chiffre. Ramène-le au chiffre.",
        duree: 8,
      },
      {
        qui: "C",
        propos:
          "À Ngaoundéré, une association verse la prime trois ans après, et seulement pour les arbres vivants. Trois sur quatre ont survécu.",
        faute: "aucune",
        reprise:
          "Un contre-exemple qui ne contredit personne et qui fait avancer tout le monde : il montre ce qui change le résultat.",
        duree: 19,
      },
      {
        qui: "A",
        propos: "Donc tu veux supprimer les campagnes nationales.",
        faute: "paille",
        reprise:
          "C a décrit une méthode de paiement, pas demandé une suppression. Homme de paille.",
        duree: 6,
      },
      {
        qui: "B",
        propos:
          "Si je comprends bien, C dit que c'est la date du versement qui change tout. C'est cela ?",
        faute: "aucune",
        reprise:
          "Une reformulation, posée en question. C'est le geste qui sauve un débat, et il vient d'un intervenant, pas du modérateur.",
        duree: 10,
      },
      {
        qui: "Modérateur",
        propos: "Oui, et c'est bien ce qu'il faut faire partout.",
        faute: "modere",
        reprise:
          "Le modérateur conclut à la place des intervenants. Il pouvait dire : « c'est bien cela, C ? » et rendre la parole.",
        duree: 6,
      },
    ],
    accords: [
      "les campagnes attirent l'attention sur le reboisement",
      "le nombre de plants mis en terre ne mesure pas le nombre d'arbres vivants",
    ],
    desaccord:
      "A pense que la campagne vaut par ce qu'elle fait savoir ; B pense qu'elle ne vaut que par ce qu'elle fait pousser.",
    repeche:
      "C a nommé le mécanisme concret : la prime versée trois ans après, et seulement pour les arbres vivants.",
    suite: "Non pas « campagne ou pas », mais « quand verse-t-on, et pour quoi exactement ».",
  },
];

const DEBAT_VIDE: Debat = {
  id: "",
  sujet: "—",
  tours: [],
  accords: [],
  desaccord: "—",
  repeche: "—",
  suite: "—",
};

export function DebatRegle() {
  const [i, setI] = useState(0);
  const [positionInverse, setPositionInverse] = useState(false);
  const [rang, setRang] = useState(0);
  const [jugements, setJugements] = useState<Record<number, Tour["faute"]>>({});
  const [conclusion, setConclusion] = useState("");
  const [verifie, setVerifie] = useState(false);

  const d = DEBATS[i] ?? DEBAT_VIDE;
  const tour = d.tours[rang];
  const fini = rang >= d.tours.length;

  const temps: Record<string, number> = {};
  d.tours.slice(0, rang).forEach((t) => {
    temps[t.qui] = (temps[t.qui] ?? 0) + t.duree;
  });
  const maxTemps = Math.max(1, ...Object.values(temps));

  const nommeAccords = d.accords.every((a) => {
    const cle = a.split(" ").slice(0, 2).join(" ").toLowerCase();
    return conclusion.toLowerCase().includes(cle.slice(0, 8));
  });
  const nommeDesaccord = /\b(désaccord|ne sommes pas d'accord|porte sur|diverge)/i.test(conclusion);
  const diteQuiARaison = /\b(a raison|a tort|le plus convaincant|je pense que|à mon avis)/i.test(
    conclusion,
  );

  function suivant() {
    setI((n) => (n + 1) % DEBATS.length);
    setRang(0);
    setJugements({});
    setConclusion("");
    setVerifie(false);
  }

  return (
    <div className="space-y-3">
      <p className="text-sm text-muted-foreground">
        Tu es le modérateur. Tu distribues la parole, tu reprends les manquements — ni trop tôt ni
        trop tard — et tu ne donnes jamais ton avis.
      </p>

      <div className="rounded-lg border border-border bg-background p-3">
        <p className="text-sm font-semibold text-foreground">{d.sujet}</p>

        <div className="mt-2">
          <Choice<"normal" | "inverse">
            label="Mode"
            value={positionInverse ? "inverse" : "normal"}
            options={[
              { value: "normal", label: "débat ordinaire" },
              { value: "inverse", label: "position inverse" },
            ]}
            onChange={(v) => setPositionInverse(v === "inverse")}
          />
        </div>

        {positionInverse ? (
          <p
            className="mt-2 rounded-md px-2 py-1.5 text-[11px]"
            style={{ backgroundColor: "rgba(124,58,237,0.10)", color: "#4c1d95" }}
          >
            Mode position inverse : tu devras, à la fin, défendre la position que tu n'aurais pas
            choisie. Cela oblige à chercher les meilleurs arguments de l'adversaire et non sa
            caricature — et cela rend modeste.
          </p>
        ) : null}

        {Object.keys(temps).length > 0 ? (
          <div className="mt-3">
            <p className="text-[11px] font-semibold text-muted-foreground">
              TEMPS DE PAROLE — le tien doit rester à zéro
            </p>
            <div className="mt-1 space-y-1">
              {Object.entries(temps).map(([qui, t]) => (
                <div key={qui} className="flex items-center gap-2">
                  <span className="w-20 text-[11px] text-muted-foreground">{qui}</span>
                  <div className="h-2.5 flex-1 overflow-hidden rounded bg-muted">
                    <div
                      className="h-full rounded"
                      style={{
                        width: `${(t / maxTemps) * 100}%`,
                        backgroundColor:
                          qui === "Modérateur"
                            ? PALETTE.red
                            : t === maxTemps
                              ? PALETTE.orange
                              : PALETTE.blue,
                      }}
                    />
                  </div>
                  <span className="w-12 text-right text-[11px] text-muted-foreground">{t} s</span>
                </div>
              ))}
            </div>
          </div>
        ) : null}

        {!fini && tour !== undefined ? (
          <div className="mt-3 rounded-md border border-border/60 p-2.5">
            <p className="text-xs">
              <span className="font-semibold text-foreground">{tour.qui} — </span>
              <span className="italic text-foreground">« {tour.propos} »</span>
            </p>
            <p className="mt-1.5 text-[11px] text-muted-foreground">
              Que reprends-tu, en tant que modérateur ?
            </p>
            <div className="mt-1 flex flex-wrap gap-1.5">
              {(Object.keys(NOM_FAUTE) as ReadonlyArray<Tour["faute"]>).map((f) => (
                <button
                  key={f}
                  type="button"
                  disabled={jugements[rang] !== undefined}
                  onClick={() => setJugements((j) => ({ ...j, [rang]: f }))}
                  className="rounded-md border px-2.5 py-1 text-[11px]"
                  style={{
                    borderColor:
                      jugements[rang] !== undefined && f === tour.faute
                        ? PALETTE.green
                        : "rgba(100,116,139,0.3)",
                    backgroundColor:
                      jugements[rang] !== undefined && f === tour.faute
                        ? "rgba(21,128,61,0.10)"
                        : jugements[rang] === f
                          ? "rgba(185,28,28,0.10)"
                          : "transparent",
                  }}
                >
                  {NOM_FAUTE[f]}
                </button>
              ))}
            </div>

            {jugements[rang] !== undefined ? (
              <div className="mt-2 space-y-2">
                <Verdict tone={jugements[rang] === tour.faute ? "ok" : "bad"}>
                  <span className="font-semibold">{NOM_FAUTE[tour.faute]}. </span>
                  {tour.reprise}
                </Verdict>
                <button
                  type="button"
                  onClick={() => setRang((r) => r + 1)}
                  className="rounded-lg bg-primary px-3 py-1.5 text-xs font-semibold text-primary-foreground"
                >
                  Tour suivant ({rang + 1} / {d.tours.length})
                </button>
              </div>
            ) : null}
          </div>
        ) : null}

        {fini ? (
          <div className="mt-3 space-y-2">
            <p className="text-xs font-semibold text-foreground">
              À toi de conclure. Nomme les accords, puis le désaccord exact — et ne dis pas qui a
              raison.
            </p>
            <textarea
              value={conclusion}
              onChange={(e) => setConclusion(e.target.value)}
              rows={5}
              className="w-full rounded-md border border-border bg-background px-2.5 py-1.5 text-sm text-foreground"
              placeholder="« Faisons le point. Vous êtes d'accord sur… Le désaccord porte sur… »"
            />
            <div className="flex flex-wrap gap-2">
              <button
                type="button"
                onClick={() => setVerifie(true)}
                className="rounded-lg bg-primary px-3 py-1.5 text-xs font-semibold text-primary-foreground"
              >
                Vérifier ma conclusion
              </button>
              <button
                type="button"
                onClick={suivant}
                className="rounded-lg border border-border px-3 py-1.5 text-xs font-semibold text-foreground"
              >
                Débat suivant ({i + 1} / {DEBATS.length})
              </button>
            </div>

            {verifie ? (
              <div className="space-y-1.5">
                <Verdict tone={nommeAccords ? "ok" : "warn"}>
                  <span className="font-semibold">Les accords. </span>
                  {nommeAccords
                    ? "Tu les as nommés, et c'est par là qu'on commence : cela montre à chacun qu'on l'a écouté."
                    : `Il fallait nommer ce sur quoi personne n'a contesté : ${d.accords.join(" ; ")}.`}
                </Verdict>
                <Verdict tone={nommeDesaccord ? "ok" : "warn"}>
                  <span className="font-semibold">Le désaccord exact. </span>
                  {nommeDesaccord
                    ? `C'est cela qu'il faut nommer : ${d.desaccord}`
                    : `Un débat est réussi quand on sait exactement sur quoi on n'est pas d'accord : ${d.desaccord}`}
                </Verdict>
                <Verdict tone={diteQuiARaison ? "bad" : "ok"}>
                  <span className="font-semibold">La neutralité. </span>
                  {diteQuiARaison
                    ? "Tu as dit ce que tu pensais, ou qui avait raison. C'est la faute la plus grave du modérateur, parce qu'elle ruine le rôle : plus personne ne te fera confiance pour distribuer la parole."
                    : "Tu n'as dit à aucun moment qui avait raison. C'est exactement ce qu'on attend d'un modérateur — et, plus tard, de celui qui dirige une réunion."}
                </Verdict>
                <p
                  className="rounded-md px-2 py-1.5 text-[11px]"
                  style={{ backgroundColor: "rgba(202,138,4,0.12)", color: "#78350f" }}
                >
                  <span className="font-semibold">L'intervention à repêcher. </span>
                  {d.repeche} Et la question suivante serait : {d.suite}
                </p>
                {positionInverse ? (
                  <p
                    className="rounded-md px-2 py-1.5 text-[11px]"
                    style={{ backgroundColor: "rgba(124,58,237,0.10)", color: "#4c1d95" }}
                  >
                    <span className="font-semibold">Mode position inverse. </span>
                    Rédige maintenant, en trois phrases, le meilleur argument du camp que tu
                    n'aurais pas choisi. Celui qui a défendu avec conviction une position pour en
                    changer à la séance suivante comprend quelque chose d'important sur la force des
                    mots.
                  </p>
                ) : null}
              </div>
            ) : null}
          </div>
        ) : null}
      </div>

      <Citation auteur="quand un débat est-il réussi ?">
        Pas quand tout le monde est d'accord — cela n'arrive presque jamais — mais quand on sait
        exactement sur quoi on ne l'est pas. Personne n'a changé d'avis, et tout le monde a avancé.
      </Citation>
    </div>
  );
}
