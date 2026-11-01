import { useState } from "react";
import { PALETTE, Choice, Ctrl, Verdict } from "./controls";
import { Citation } from "./philo-noyau";

/** Français 3ème — chapitres 23 et 24 : hiérarchiser, transition, oral. */

/* ------------------------------------------------------------------ */
/* 1. Hiérarchiser ses arguments                                       */
/* ------------------------------------------------------------------ */

type ArgumentNote = {
  id: string;
  texte: string;
  /** Les quatre critères, de 0 à 3. */
  refutable: number;
  proche: number;
  retournable: number;
  valeur: number;
  /** Rang attendu : 0 = à éliminer, 1 à 4 = position. */
  rang: number;
  note: string;
};

type SujetHier = {
  id: string;
  enonce: string;
  args: ReadonlyArray<ArgumentNote>;
  conclusion: string;
  piege?: string;
};

const SUJETS_HIER: ReadonlyArray<SujetHier> = [
  {
    id: "sh1",
    enonce: "Faut-il interdire la vente de sachets plastiques au marché ?",
    args: [
      {
        id: "a1",
        texte: "Les sachets sont laids et sales quand ils traînent.",
        refutable: 0,
        proche: 1,
        retournable: 0,
        valeur: 0,
        rang: 0,
        note: "Argument d'opinion pure, impossible à prouver et facile à retourner. À côté d'un enfant noyé, la laideur ne pèse rien : le garder affaiblirait l'ensemble.",
      },
      {
        id: "a2",
        texte: "Les pays voisins les ont déjà interdits.",
        refutable: 1,
        proche: 0,
        retournable: 1,
        valeur: 0,
        rang: 1,
        note: "Appel à l'autorité, logiquement faible — mais utile en ouverture : il montre que la mesure est réalisable, ce qui répond par avance à l'objection « c'est impossible ».",
      },
      {
        id: "a3",
        texte: "Un sac plastique met quatre cents ans à disparaître.",
        refutable: 3,
        proche: 1,
        retournable: 2,
        valeur: 1,
        rang: 2,
        note: "Fait vérifiable, donc difficile à réfuter. Mais il reste abstrait : quatre cents ans, personne ne les voit.",
      },
      {
        id: "a4",
        texte: "Le bétail qui avale des sachets meurt, et c'est une perte pour les éleveurs.",
        refutable: 3,
        proche: 2,
        retournable: 2,
        valeur: 2,
        rang: 3,
        note: "Une victime concrète et un préjudice chiffrable. Il touche un groupe identifiable.",
      },
      {
        id: "a5",
        texte:
          "Les sachets bouchent les caniveaux et aggravent les inondations de septembre dans les quartiers bas.",
        refutable: 3,
        proche: 3,
        retournable: 3,
        valeur: 3,
        rang: 4,
        note: "Le plus fort : vérifiable, proche du lecteur — son quartier, sa saison des pluies — et il engage une valeur, la sécurité des habitants.",
      },
    ],
    conclusion:
      "« Il ne s'agit plus d'esthétique ni même d'écologie : il s'agit de savoir si nos quartiers seront sous l'eau en septembre prochain. »",
  },
  {
    id: "sh2",
    enonce: "Les élèves doivent-ils ramasser eux-mêmes les ordures de leur quartier ?",
    args: [
      {
        id: "b1",
        texte: "C'est fatigant le samedi matin.",
        refutable: 0,
        proche: 2,
        retournable: 0,
        valeur: 0,
        rang: 0,
        note: "Argument de confort, qui ne convaincra personne et décrédibilise les autres. Un adulte répondra « le travail est fatigant ».",
      },
      {
        id: "b2",
        texte: "D'autres quartiers ont essayé sans succès.",
        refutable: 1,
        proche: 1,
        retournable: 1,
        valeur: 0,
        rang: 1,
        note: "Faible logiquement : un échec ailleurs ne prouve rien ici. Mais il ouvre utilement en rappelant que la bonne volonté ne suffit pas.",
      },
      {
        id: "b3",
        texte: "Le ramassage est un service public, financé par les taxes déjà versées.",
        refutable: 3,
        proche: 2,
        retournable: 2,
        valeur: 2,
        rang: 2,
        note: "Un principe vérifiable, difficile à contester. Mais il reste juridique.",
      },
      {
        id: "b4",
        texte:
          "Un samedi matin passé à curer un caniveau est un samedi retiré à un travail ou à une révision.",
        refutable: 2,
        proche: 3,
        retournable: 2,
        valeur: 2,
        rang: 3,
        note: "Il touche la vie quotidienne de l'élève, et il introduit l'inégalité.",
      },
      {
        id: "b5",
        texte:
          "Si les habitants compensent chaque défaillance, la commune n'a plus aucune raison de la corriger.",
        refutable: 3,
        proche: 3,
        retournable: 3,
        valeur: 3,
        rang: 4,
        note: "Le plus fort : il retourne l'argument adverse, il engage une valeur — la responsabilité publique — et il porte la conclusion.",
      },
    ],
    conclusion: "« Ramasser soi-même ne soulage pas la commune : cela la dispense d'agir. »",
  },
  {
    id: "sh3",
    enonce: "Faut-il enseigner dans la langue maternelle les premières années ?",
    args: [
      {
        id: "c1",
        texte: "C'est plus joli d'entendre les enfants parler leur langue.",
        refutable: 0,
        proche: 1,
        retournable: 0,
        valeur: 0,
        rang: 0,
        note: "Jugement esthétique : il n'a aucune force dans un débat de politique éducative.",
      },
      {
        id: "c2",
        texte: "Plusieurs pays africains l'ont expérimenté.",
        refutable: 1,
        proche: 0,
        retournable: 1,
        valeur: 0,
        rang: 1,
        note: "Appel à l'autorité, utile pour établir la faisabilité.",
      },
      {
        id: "c3",
        texte:
          "La langue maternelle préserve un patrimoine culturel que l'école a longtemps combattu.",
        refutable: 2,
        proche: 2,
        retournable: 2,
        valeur: 3,
        rang: 2,
        note: "Il engage une valeur forte, mais il est facile de lui opposer l'intérêt pratique.",
      },
      {
        id: "c4",
        texte:
          "Un enfant qui apprend à lire dans une langue qu'il ne parle pas apprend deux choses à la fois.",
        refutable: 3,
        proche: 2,
        retournable: 2,
        valeur: 2,
        rang: 3,
        note: "Argument pédagogique solide, et vérifiable.",
      },
      {
        id: "c5",
        texte:
          "Les résultats en lecture au cours préparatoire sont meilleurs dans les classes pilotes bilingues.",
        refutable: 3,
        proche: 3,
        retournable: 3,
        valeur: 2,
        rang: 4,
        note: "Le plus fort : un fait mesuré, qui touche directement ce que les parents attendent de l'école.",
      },
    ],
    conclusion:
      "« Il ne s'agit pas de choisir une langue contre une autre, mais de savoir dans laquelle un enfant de six ans apprend à lire. »",
  },
];

const SUJET_HIER_VIDE: SujetHier = { id: "", enonce: "—", args: [], conclusion: "—" };

export function HierarchiserArguments() {
  const [i, setI] = useState(0);
  const [elimine, setElimine] = useState<string | null>(null);
  const [ordre, setOrdre] = useState<ReadonlyArray<string>>([]);
  const [montre, setMontre] = useState(false);
  const [inverse, setInverse] = useState(false);

  const s = SUJETS_HIER[i] ?? SUJET_HIER_VIDE;
  const aEliminer = s.args.find((a) => a.rang === 0);
  const elimineJuste = elimine === (aEliminer?.id ?? "");
  const restants = s.args.filter((a) => a.id !== elimine);
  const ordreJuste =
    ordre.length === restants.length &&
    ordre.every((id, k) => {
      const a = s.args.find((x) => x.id === id);
      return a !== undefined && a.rang === k + 1;
    });

  const affiche = inverse ? [...ordre].reverse() : ordre;

  function suivant() {
    setI((n) => (n + 1) % SUJETS_HIER.length);
    setElimine(null);
    setOrdre([]);
    setMontre(false);
    setInverse(false);
  }

  return (
    <div className="space-y-3">
      <p className="text-sm text-muted-foreground">
        D'abord éliminer, ensuite classer. Mieux vaut trois arguments solides que cinq dont deux
        sont discutables.
      </p>

      <div className="rounded-lg border border-border bg-background p-3">
        <p className="text-sm font-semibold text-foreground">{s.enonce}</p>

        <p className="mt-3 text-[11px] font-semibold text-muted-foreground">
          1. QUEL ARGUMENT FAUT-IL ÉLIMINER ?
        </p>
        <div className="mt-1 space-y-1.5">
          {s.args.map((a) => {
            const horsJeu = elimine === a.id;
            const rang = ordre.indexOf(a.id);
            return (
              <button
                key={a.id}
                type="button"
                onClick={() => {
                  if (elimine === null) {
                    setElimine(a.id);
                    return;
                  }
                  if (a.id === elimine) return;
                  setOrdre((o) => (o.includes(a.id) ? o.filter((x) => x !== a.id) : [...o, a.id]));
                }}
                className="block w-full rounded-md border px-2.5 py-1.5 text-left text-xs"
                style={{
                  opacity: horsJeu ? 0.45 : 1,
                  textDecoration: horsJeu ? "line-through" : "none",
                  borderColor: rang >= 0 ? PALETTE.blue : "rgba(100,116,139,0.3)",
                  backgroundColor: rang >= 0 ? "rgba(37,99,235,0.08)" : "transparent",
                }}
              >
                {rang >= 0 ? (
                  <span className="mr-1.5 font-semibold" style={{ color: PALETTE.blue }}>
                    {["I.", "II.", "III.", "IV."][rang] ?? `${rang + 1}.`}
                  </span>
                ) : null}
                {a.texte}
              </button>
            );
          })}
        </div>

        {elimine !== null ? (
          <div className="mt-2">
            <Verdict tone={elimineJuste ? "ok" : "bad"}>
              <span className="font-semibold">
                L'argument à éliminer : « {aEliminer?.texte ?? ""} ».{" "}
              </span>
              {aEliminer?.note ?? ""}
            </Verdict>
            <p className="mt-2 text-[11px] font-semibold text-muted-foreground">
              2. CLASSE LES AUTRES, DU PLUS FAIBLE AU PLUS FORT
            </p>
          </div>
        ) : null}

        {ordre.length === restants.length && restants.length > 0 ? (
          <div className="mt-2 space-y-2">
            <Verdict tone={ordreJuste ? "ok" : "warn"}>
              <span className="font-semibold">
                {ordreJuste ? "L'ordre monte en puissance. " : "L'ordre attendu diffère. "}
              </span>
              {ordreJuste
                ? "Le lecteur garde en mémoire ce qu'il a lu en dernier, et ton meilleur argument porte la conclusion."
                : "Ta meilleure raison n'est pas en dernier : elle sera oubliée."}
            </Verdict>

            <div className="flex flex-wrap gap-2">
              <button
                type="button"
                onClick={() => setMontre(true)}
                className="rounded-lg border border-border px-3 py-1.5 text-xs font-semibold text-foreground"
              >
                Voir les notes sur les quatre critères
              </button>
              <button
                type="button"
                onClick={() => setInverse((x) => !x)}
                className="rounded-lg border border-border px-3 py-1.5 text-xs font-semibold text-foreground"
              >
                {inverse ? "Remettre dans l'ordre croissant" : "Essayer l'ordre inverse"}
              </button>
              <button
                type="button"
                onClick={suivant}
                className="rounded-lg bg-primary px-3 py-1.5 text-xs font-semibold text-primary-foreground"
              >
                Sujet suivant ({i + 1} / {SUJETS_HIER.length})
              </button>
            </div>

            {inverse ? (
              <div
                className="rounded-md px-2.5 py-2"
                style={{ backgroundColor: "rgba(185,28,28,0.08)" }}
              >
                <p className="text-[11px] font-semibold" style={{ color: PALETTE.red }}>
                  Le même devoir, arguments descendants
                </p>
                {affiche.map((id, k) => {
                  const a = s.args.find((x) => x.id === id);
                  return (
                    <p key={id} className="mt-0.5 text-[11px] text-foreground">
                      <span className="font-semibold">{["I.", "II.", "III.", "IV."][k] ?? ""}</span>{" "}
                      {a?.texte ?? ""}
                    </p>
                  );
                })}
                <p className="mt-1.5 text-[11px] italic text-muted-foreground">
                  Lis-le dans cet ordre : le texte paraît s'essouffler, et il finit sur sa raison la
                  plus faible. C'est exactement l'impression qu'un correcteur reçoit.
                </p>
              </div>
            ) : null}

            {montre ? (
              <div className="space-y-1.5">
                {restants.map((a) => (
                  <div key={`n-${a.id}`} className="rounded-md border border-border/60 p-2.5">
                    <p className="text-xs font-semibold text-foreground">{a.texte}</p>
                    <div className="mt-1.5 space-y-1">
                      {(
                        [
                          { l: "difficile à réfuter", v: a.refutable },
                          { l: "proche du lecteur", v: a.proche },
                          { l: "difficile à retourner", v: a.retournable },
                          { l: "engage une valeur", v: a.valeur },
                        ] as const
                      ).map((c) => (
                        <div key={c.l} className="flex items-center gap-2">
                          <span className="w-36 text-[10px] text-muted-foreground">{c.l}</span>
                          <div className="h-2 flex-1 overflow-hidden rounded bg-muted">
                            <div
                              className="h-full rounded"
                              style={{
                                width: `${(c.v / 3) * 100}%`,
                                backgroundColor: PALETTE.blue,
                              }}
                            />
                          </div>
                        </div>
                      ))}
                    </div>
                    <p className="mt-1 text-[11px] text-muted-foreground">{a.note}</p>
                  </div>
                ))}
                <p
                  className="rounded-md px-2 py-1.5 text-[11px]"
                  style={{ backgroundColor: "rgba(21,128,61,0.10)", color: "#14532d" }}
                >
                  <span className="font-semibold">
                    La conclusion que porte le dernier argument.{" "}
                  </span>
                  {s.conclusion}
                </p>
              </div>
            ) : null}
          </div>
        ) : null}
      </div>

      <Citation auteur="le classement ne change pas un seul argument">
        Et pourtant il double la force du texte. C'est le travail le moins visible du brouillon, et
        l'un des plus rentables.
      </Citation>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* 2. Rédiger la transition                                            */
/* ------------------------------------------------------------------ */

type CoupleParties = {
  id: string;
  sujet: string;
  partieA: string;
  partieB: string;
  synthese: boolean;
  modele: string;
  analyse: string;
};

const TRANSITIONS: ReadonlyArray<CoupleParties> = [
  {
    id: "tr1",
    sujet: "Faut-il interdire les motos-taxis en centre-ville ?",
    partieA: "I. Oui : elles causent des accidents, et circulent sans casque ni assurance.",
    partieB:
      "II. Non : elles font vivre des milliers de jeunes et desservent les quartiers sans bus.",
    synthese: false,
    modele:
      "Le danger est donc réel, et les chiffres ne se discutent pas. Mais une interdiction ne se juge pas seulement à ce qu'elle supprime : elle se juge aussi à ce qu'elle laisse derrière elle. Il faut donc regarder qui vit de ces motos, et qui les prend.",
    analyse:
      "Le premier temps concède la force de la partie I, ce qui évite de paraître revenir sur ce qu'on vient d'écrire. Le deuxième introduit un critère nouveau. Le troisième annonce précisément les deux arguments du II.",
  },
  {
    id: "tr2",
    sujet: "Faut-il interdire les motos-taxis en centre-ville ?",
    partieA:
      "II. Non : elles font vivre des milliers de jeunes et desservent les quartiers sans bus.",
    partieB:
      "III. La vraie question est l'absence de transport public : encadrer avant d'interdire.",
    synthese: true,
    modele:
      "Les deux positions semblent donc également fondées, et c'est bien ce qui rend la question difficile. En réalité, elles partagent un présupposé que ni l'une ni l'autre n'interroge : toutes deux admettent que le choix se pose entre la moto et rien. C'est ce présupposé qu'il faut examiner.",
    analyse:
      "Cette transition ouvre la synthèse, et elle est plus ambitieuse. Elle ne départage pas les deux parties — ce serait prendre parti trop tôt — mais elle nomme ce qu'elles ont EN COMMUN sans le voir. Et c'est ce point commun qui sera déplacé en partie III.",
  },
  {
    id: "tr3",
    sujet: "Les habitants doivent-ils ramasser eux-mêmes leurs ordures ?",
    partieA: "I. Oui : le quartier devient propre tout de suite, et l'effort crée le respect.",
    partieB: "II. Non : le service est déjà payé, et le faire soi-même dispense la commune d'agir.",
    synthese: false,
    modele:
      "Ces initiatives nettoient donc les rues, et personne ne le conteste. Mais elles ne disent rien de ce qui les a rendues nécessaires. C'est de ce côté qu'il faut maintenant chercher.",
    analyse:
      "Trois phrases, deux fois plus courtes que le modèle précédent, et aussi efficaces. Une transition n'a pas besoin d'être longue : elle a besoin d'avoir ses trois temps.",
  },
  {
    id: "tr4",
    sujet: "L'école doit-elle commencer dans la langue maternelle ?",
    partieA: "I. Oui : l'enfant comprend mieux, et le patrimoine est préservé.",
    partieB: "II. Non : deux cents langues, et les langues officielles ouvrent sur le pays.",
    synthese: false,
    modele:
      "L'avantage pédagogique des premières années est donc établi. Reste que cet avantage se paie, et qu'on n'a encore rien dit du coût ni du nombre. Il faut maintenant regarder ce que l'application supposerait.",
    analyse:
      "Le mot « reste que » est un excellent connecteur de limite : plus discret que « mais », plus honnête que « cependant ».",
  },
  {
    id: "tr5",
    sujet: "L'école doit-elle commencer dans la langue maternelle ?",
    partieA: "II. Non : deux cents langues, et les langues officielles ouvrent sur le pays.",
    partieB: "III. La question n'est pas quelle langue, mais à quel moment.",
    synthese: true,
    modele:
      "Chacune des deux positions paraît donc imparable dans son ordre. En réalité, elles posent toutes deux la même question — quelle langue choisir — comme s'il fallait choisir une fois pour toutes. C'est cette simultanéité qu'il faut interroger.",
    analyse:
      "Le déplacement porte ici sur le TEMPS : de « laquelle » à « quand ». C'est un déplacement très sûr, parce qu'il ne contredit aucune des deux parties.",
  },
  {
    id: "tr6",
    sujet: "Le reboisement camerounais échoue-t-il faute de suivi ?",
    partieA: "I. Les campagnes comptent les plants distribués, jamais les arbres vivants.",
    partieB: "II. Aucun responsable n'est désigné pour les trois premières saisons.",
    synthese: false,
    modele:
      "On ne mesure donc pas ce qu'il faudrait mesurer. Mais un mauvais indicateur ne suffit pas à expliquer un taux de survie de dix pour cent : encore faut-il savoir qui aurait dû agir entre la plantation et la photographie. C'est la seconde question.",
    analyse:
      "Dans un plan thématique, les transitions existent aussi — et elles enchaînent les arguments au lieu d'opposer des parties. Le mouvement est le même : acquis, limite, annonce.",
  },
  {
    id: "tr7",
    sujet: "Faut-il interdire le téléphone dans l'établissement ?",
    partieA: "I. Oui : triche et attention dispersée.",
    partieB: "II. Non : c'est le seul lien avec la famille, et parfois le seul dictionnaire.",
    synthese: false,
    modele:
      "Les perturbations en classe sont donc avérées. Toutefois, interdire un objet revient à interdire tous ses usages, et nous n'avons parlé que d'un seul. Il faut examiner les autres.",
    analyse:
      "Le deuxième temps énonce un principe général — interdire un objet, c'est interdire tous ses usages — qui vaut bien au-delà de ce sujet. Une transition peut ainsi élever le débat.",
  },
  {
    id: "tr8",
    sujet: "Faut-il interdire le téléphone dans l'établissement ?",
    partieA: "II. Non : c'est le seul lien avec la famille, et parfois le seul dictionnaire.",
    partieB: "III. Interdire en classe, autoriser à la récréation.",
    synthese: true,
    modele:
      "Les deux camps ont donc chacun raison sur un usage différent. En réalité, ils discutent de l'objet alors que le problème est le moment : nul n'a proposé de distinguer la classe de la cour. C'est cette distinction qu'il faut faire.",
    analyse:
      "Le déplacement porte sur le LIEU et le MOMENT, et il désarme les deux objections d'un coup. C'est le signe d'une synthèse réussie : elle ne sacrifie ni l'une ni l'autre partie.",
  },
  {
    id: "tr9",
    sujet: "Les réseaux sociaux éloignent-ils les jeunes de leur famille ?",
    partieA: "I. Le temps d'écran est du temps retiré à la conversation familiale.",
    partieB: "II. Les réseaux créent une vie sociale parallèle que la famille ignore.",
    synthese: false,
    modele:
      "Le temps perdu est donc mesurable. Mais compter des heures ne dit rien de ce qui se passe pendant ces heures-là. Il faut regarder ce que l'adolescent y fait, et ce que sa famille en sait.",
    analyse:
      "La limite nommée ici est une limite de MÉTHODE : le premier argument mesure, le second va chercher le contenu. C'est une progression, et elle se voit.",
  },
  {
    id: "tr10",
    sujet: "Un témoignage suffit-il à prouver quelque chose ?",
    partieA: "I. Il est incontestable : personne ne peut nier ce qu'on a vécu.",
    partieB: "II. Il est unique : un seul cas ne prouve pas une règle.",
    synthese: false,
    modele:
      "Sa force tient donc à ce que nul ne peut le contredire. Mais ce qui le rend incontestable le rend aussi isolé : on ne réfute pas une expérience, et on ne la généralise pas davantage. C'est cette limite qu'il faut mesurer.",
    analyse:
      "Le deuxième temps retourne l'argument de la première partie : sa force EST sa faiblesse. C'est le mouvement de transition le plus élégant, quand le sujet le permet.",
  },
  {
    id: "tr11",
    sujet: "Faut-il interdire les sacs plastiques ?",
    partieA: "I. Oui : caniveaux bouchés, bétail mort, quatre cents ans de dégradation.",
    partieB: "II. Non : l'interdiction frappe d'abord les petits commerçants.",
    synthese: false,
    modele:
      "Les dégâts sont donc établis, et de plusieurs ordres. Mais une mesure juste dans son principe peut être injuste dans son application, selon qui la supporte. Il faut donc voir sur qui elle pèserait.",
    analyse:
      "Le deuxième temps énonce un principe — juste dans son principe, injuste dans son application — qui annonce exactement le contenu du II.",
  },
  {
    id: "tr12",
    sujet: "Faut-il interdire les sacs plastiques ?",
    partieA: "II. Non : l'interdiction frappe d'abord les petits commerçants.",
    partieB: "III. Interdire la production et l'importation, non la détention.",
    synthese: true,
    modele:
      "L'opposition paraît donc insoluble : d'un côté la ville inondée, de l'autre le vendeur ruiné. En réalité, les deux positions discutent du même bout de la chaîne — celui qui tient le sachet — sans s'interroger sur celui qui le fabrique. C'est l'autre bout qu'il faut regarder.",
    analyse:
      "Le déplacement porte sur le MAILLON de la chaîne, et il règle l'objection du II : si l'on tarit la source, le petit commerçant n'a plus rien à se reprocher.",
  },
];

const TRANSITION_VIDE: CoupleParties = {
  id: "",
  sujet: "—",
  partieA: "—",
  partieB: "—",
  synthese: false,
  modele: "—",
  analyse: "—",
};

export function RedigerTransition() {
  const [i, setI] = useState(0);
  const [saisie, setSaisie] = useState("");
  const [montre, setMontre] = useState(false);

  const t = TRANSITIONS[i] ?? TRANSITION_VIDE;

  const rappel =
    /\b(nous avons vu|il apparaît|ce (premier )?point|ainsi|donc|est donc|paraî|semble)/i.test(
      saisie,
    );
  const limite = /\b(mais|cependant|toutefois|reste que|pourtant|néanmoins|en réalité|or)\b/i.test(
    saisie,
  );
  const annonce =
    /\b(il faut|il convient|nous en venons|reste à savoir|c'est ce qu|examiner|regarder|chercher)/i.test(
      saisie,
    );
  const resume = rappel && !limite && !annonce;

  return (
    <div className="space-y-3">
      <p className="text-sm text-muted-foreground">
        Trois temps : rappeler ce qu'on vient d'établir, montrer ce que cela laisse sans réponse,
        annoncer ce qui suit.
      </p>

      <div className="rounded-lg border border-border bg-background p-3">
        <p className="text-xs font-semibold text-foreground">{t.sujet}</p>

        <div
          className="mt-2 rounded-md px-2.5 py-2"
          style={{ backgroundColor: "rgba(37,99,235,0.08)" }}
        >
          <p className="text-xs text-foreground">{t.partieA}</p>
        </div>

        <p className="mt-2 text-[11px] font-semibold text-muted-foreground">
          ↓ TA TRANSITION {t.synthese ? "— elle ouvre la synthèse, c'est la plus importante" : ""}
        </p>
        <textarea
          value={saisie}
          onChange={(e) => setSaisie(e.target.value)}
          rows={4}
          className="mt-1 w-full rounded-md border border-border bg-background px-2.5 py-1.5 text-sm text-foreground"
          placeholder={
            t.synthese
              ? "« Les deux positions semblent… En réalité, elles partagent un présupposé… C'est ce présupposé qu'il faut examiner. »"
              : "« Nous avons vu que… Mais… Il faut donc examiner… »"
          }
        />

        <div
          className="mt-2 rounded-md px-2.5 py-2"
          style={{ backgroundColor: "rgba(21,128,61,0.08)" }}
        >
          <p className="text-xs text-foreground">{t.partieB}</p>
        </div>

        <div className="mt-2 flex flex-wrap gap-1.5 text-[11px]">
          {(
            [
              { l: "1. le rappel", ok: rappel },
              { l: "2. la limite", ok: limite },
              { l: "3. l'annonce", ok: annonce },
            ] as const
          ).map((c) => (
            <span
              key={c.l}
              className="rounded px-2 py-0.5"
              style={{
                backgroundColor: c.ok ? "rgba(21,128,61,0.12)" : "rgba(100,116,139,0.12)",
                color: c.ok ? "#14532d" : PALETTE.slate,
              }}
            >
              {c.ok ? "✓ " : "· "}
              {c.l}
            </span>
          ))}
        </div>

        {resume ? (
          <div className="mt-2">
            <Verdict tone="bad">
              <span className="font-semibold">C'est un résumé, pas une transition. </span>
              Tu rappelles la partie précédente, mais tu ne montres aucune limite et tu n'annonces
              rien. « Passons à la deuxième partie » n'est pas une annonce : c'est une formalité.
            </Verdict>
          </div>
        ) : null}

        <div className="mt-2 flex flex-wrap gap-2">
          <button
            type="button"
            onClick={() => setMontre(true)}
            className="rounded-lg border border-border px-3 py-1.5 text-xs font-semibold text-foreground"
          >
            Voir un modèle
          </button>
          <button
            type="button"
            onClick={() => {
              setI((n) => (n + 1) % TRANSITIONS.length);
              setSaisie("");
              setMontre(false);
            }}
            className="rounded-lg bg-primary px-3 py-1.5 text-xs font-semibold text-primary-foreground"
          >
            Couple suivant ({i + 1} / {TRANSITIONS.length})
          </button>
        </div>

        {montre ? (
          <div className="mt-2 space-y-1.5">
            <Verdict tone="ok">
              <span className="font-semibold">Un modèle possible. </span>
              {t.modele}
            </Verdict>
            <p className="text-[11px] italic text-muted-foreground">{t.analyse}</p>
          </div>
        ) : null}
      </div>

      <Citation auteur="écris tes transitions au brouillon, avant de rédiger les parties">
        Si tu n'arrives pas à les écrire, c'est que ton plan ne tient pas — et il vaut mieux s'en
        apercevoir à ce moment-là.
      </Citation>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* 3. Bâtir le paragraphe argumentatif                                 */
/* ------------------------------------------------------------------ */

type SujetPara = {
  id: string;
  these: string;
  consigne: string;
  modele: { arg: string; exp: string; ex: string; concl: string };
  /** Mots de la thèse dont la mini-conclusion devrait reprendre au moins un. */
  motsCles: ReadonlyArray<string>;
};

const SUJETS_PARA: ReadonlyArray<SujetPara> = [
  {
    id: "sp1",
    these: "Le ramassage des ordures incombe à la commune, non aux habitants.",
    consigne: "Rédige le premier paragraphe.",
    modele: {
      arg: "D'abord, le ramassage des ordures est un service public, et non un service rendu.",
      exp: "Les habitants d'un quartier versent des taxes dont une part finance précisément la collecte ; lorsqu'ils la font eux-mêmes, ils paient deux fois, une fois en argent et une fois en temps, et personne ne leur rembourse la première.",
      ex: "Le bac de notre carrefour a été retiré en janvier dernier ; il n'a jamais été remplacé, et ma mère a écrit deux fois à la mairie sans recevoir de réponse.",
      concl: "Ramasser soi-même n'est donc pas de la citoyenneté : c'est une double peine.",
    },
    motsCles: ["commune", "ramassage", "ordures", "habitants", "citoyenneté"],
  },
  {
    id: "sp2",
    these: "Il faut interdire la production des sachets plastiques, non leur détention.",
    consigne: "Rédige le paragraphe qui porte sur les petits commerçants.",
    modele: {
      arg: "Ensuite, interdire la détention frappe le dernier maillon de la chaîne, c'est-à-dire le plus faible.",
      exp: "Celui qui vend trois tomates sur un trottoir n'a ni le capital pour acheter des emballages en papier ni le pouvoir de refuser ce que le grossiste lui livre ; sanctionner son sachet revient à le punir d'un choix qu'il n'a pas fait.",
      ex: "Au marché de Mokolo, un paquet de cent sachets coûte deux cents francs quand les sacs en papier équivalents en coûtent six cents.",
      concl:
        "Une mesure juste dans son principe devient donc injuste dès qu'on la fait porter au mauvais bout de la chaîne.",
    },
    motsCles: ["interdire", "production", "détention", "chaîne", "mesure"],
  },
  {
    id: "sp3",
    these: "Le reboisement échoue faute de suivi, non faute de plants.",
    consigne: "Rédige le paragraphe sur le mode de paiement.",
    modele: {
      arg: "Enfin, la prime est versée le jour de la plantation, ce qui récompense le geste et non le résultat.",
      exp: "Un planteur payé à la mise en terre n'a aucune raison de revenir arroser trois saisons durant ; le système lui demande des trous, et il fournit des trous.",
      ex: "À Ngaoundéré, une association verse la prime trois ans après et seulement pour les arbres vivants : sur mille deux cents plants distribués en 2019, neuf cents étaient debout en 2022, contre dix pour cent dans les campagnes nationales.",
      concl: "Ce n'est donc pas la volonté qui manque au reboisement, mais la date du versement.",
    },
    motsCles: ["reboisement", "suivi", "plants", "arbres", "versement"],
  },
  {
    id: "sp4",
    these: "La distance nuit à la scolarité des élèves des villages.",
    consigne: "Rédige un paragraphe appuyé sur un témoignage.",
    modele: {
      arg: "D'abord, l'élève qui marche deux heures arrive en classe déjà épuisé.",
      exp: "L'attention d'un adolescent se joue dans la première heure de cours ; or c'est précisément l'heure où celui qui est parti à cinq heures lutte contre le sommeil et contre ses pieds.",
      ex: "Je l'ai fait pendant trois ans. Je partais à cinq heures et j'arrivais la tête vide, les pieds brûlants ; le professeur croyait que je n'écoutais pas, et il m'a placé au fond de la classe.",
      concl: "C'est ainsi que la distance fait échouer des élèves que l'on croit paresseux.",
    },
    motsCles: ["distance", "scolarité", "élèves", "village", "classe"],
  },
];

const SUJET_PARA_VIDE: SujetPara = {
  id: "",
  these: "—",
  consigne: "—",
  modele: { arg: "—", exp: "—", ex: "—", concl: "—" },
  motsCles: [],
};

type CasseParagraphe = {
  id: string;
  texte: string;
  defaut: string;
  reparation: string;
};

const A_REPARER: ReadonlyArray<CasseParagraphe> = [
  {
    id: "rp1",
    texte:
      "Il faut dire aussi que les jeunes qui ramassent les ordures c'est bien mais que ça pose problème parce que la mairie devrait le faire et aussi parce que ça coûte du temps aux gens qui travaillent. Dans mon quartier il y a eu des problèmes. C'est vraiment pas normal.",
    defaut:
      "DEUX IDÉES dans un seul paragraphe — la mairie devrait le faire, et cela coûte du temps —, pas d'argument en tête, pas d'explication, un exemple vide, et une mini-conclusion qui n'est qu'un jugement. Sans compter le registre familier : « c'est pas normal ».",
    reparation: "Il faut le couper en DEUX paragraphes, et développer chacun.",
  },
  {
    id: "rp2",
    texte:
      "Les sachets plastiques polluent beaucoup. C'est un gros problème pour l'environnement. Il faudrait vraiment faire quelque chose. Tout le monde le sait.",
    defaut:
      "AUCUN EXEMPLE. Quatre phrases d'idées générales, sans un seul fait concret — ni lieu, ni date, ni chiffre. C'est la copie la plus fréquente du BEPC, et elle plafonne.",
    reparation:
      "Garder l'argument, ajouter une explication qui dit POURQUOI, et surtout un exemple situé et chiffré.",
  },
  {
    id: "rp3",
    texte:
      "À Douala en septembre dernier, les services ont retiré douze tonnes de sachets des caniveaux de Bonabéri. Les sachets bouchent les caniveaux. Il faut donc agir.",
    defaut:
      "L'ORDRE est inversé : l'exemple arrive en tête, l'argument après. Le lecteur reçoit un fait sans savoir ce qu'il prouve, et doit faire le lien lui-même.",
    reparation:
      "Mettre l'argument en tête — « les sachets bouchent les caniveaux » — puis l'explication, puis l'exemple.",
  },
  {
    id: "rp4",
    texte:
      "D'abord, le ramassage est un service public. Les habitants paient des taxes. Le bac a été retiré en janvier.",
    defaut:
      "TROP COURT, et sans mini-conclusion. Les trois éléments y sont — argument, explication, exemple — mais chacun tient en une phrase sèche, et rien ne rattache le paragraphe à la thèse.",
    reparation:
      "Développer l'explication en deux ou trois phrases, et ajouter une dernière phrase qui reprend un mot de la thèse.",
  },
  {
    id: "rp5",
    texte:
      "Les motos-taxis sont dangereuses et elles polluent, mais en même temps elles font vivre beaucoup de jeunes, donc c'est compliqué, et puis il y a aussi le problème des bus qui ne passent pas dans les quartiers.",
    defaut:
      "TROIS IDÉES empilées dans une seule phrase, reliées par « mais », « donc » et « et puis ». Aucune n'est développée, et le paragraphe finit sur « c'est compliqué ».",
    reparation:
      "Choisir UNE idée pour ce paragraphe, et garder les deux autres pour la suite du devoir.",
  },
  {
    id: "rp6",
    texte:
      "Enfin, le téléphone est utile aux élèves. Par exemple, mon cousin l'utilise beaucoup. C'est donc un bon outil pour tout le monde.",
    defaut:
      "L'EXEMPLE est vide — « mon cousin l'utilise beaucoup » ne situe rien, ne date rien, ne chiffre rien — et la mini-conclusion généralise abusivement à partir d'un seul cas.",
    reparation:
      "Donner un usage précis et vérifiable, et resserrer la conclusion sur ce que l'exemple prouve réellement.",
  },
];

const CASSE_VIDE: CasseParagraphe = { id: "", texte: "—", defaut: "—", reparation: "—" };

export function ParagrapheArgumentatif() {
  const [atelier, setAtelier] = useState<"batir" | "reparer">("batir");
  const [i, setI] = useState(0);
  const [etape, setEtape] = useState(0);
  const [cases, setCases] = useState({ arg: "", exp: "", ex: "", concl: "" });
  const [montre, setMontre] = useState(false);
  const [ir, setIr] = useState(0);
  const [vuDefaut, setVuDefaut] = useState(false);

  const s = SUJETS_PARA[i] ?? SUJET_PARA_VIDE;
  const r = A_REPARER[ir] ?? CASSE_VIDE;

  const argOk =
    cases.arg.trim().length > 20 && cases.arg.split(/[.!?]/).filter((x) => x.trim()).length <= 2;
  const expOk = cases.exp.trim().split(/\s+/).length >= 20;
  const exOk = /\d/.test(cases.ex) || /\b(à |au |en |depuis )[A-ZÉÀ]/.test(cases.ex);
  const conclOk = s.motsCles.some((m) => cases.concl.toLowerCase().includes(m.toLowerCase()));

  const etapes = [
    {
      cle: "arg" as const,
      nom: "1. L'ARGUMENT",
      aide: "Une phrase, en tête. Général, abstrait. Commence par un connecteur : d'abord, de plus, enfin.",
      ok: argOk,
      raison:
        "Un argument tient en une phrase, et il reste général. S'il en fait trois, c'est que tu as déjà commencé l'explication.",
    },
    {
      cle: "exp" as const,
      nom: "2. L'EXPLICATION",
      aide: "Deux ou trois phrases : POURQUOI c'est vrai. C'est ce que les élèves sautent.",
      ok: expOk,
      raison:
        "Trop court. Il faut deux ou trois phrases pour dire pourquoi l'argument est vrai — sinon le lecteur ne voit pas le raisonnement.",
    },
    {
      cle: "ex" as const,
      nom: "3. L'EXEMPLE",
      aide: "Un fait situé, daté, chiffré. C'est ce que les élèves oublient.",
      ok: exOk,
      raison:
        "Je ne trouve ni lieu, ni date, ni chiffre. Un exemple sans l'un des trois n'est pas un exemple : c'est une généralité de plus.",
    },
    {
      cle: "concl" as const,
      nom: "4. LA MINI-CONCLUSION",
      aide: "Une phrase qui rattache à la thèse. C'est ce que personne n'écrit.",
      ok: conclOk,
      raison: `Ta conclusion ne reprend aucun mot de la thèse. Essaie d'y placer l'un de ceux-ci : ${s.motsCles.join(", ")}.`,
    },
  ];
  const e = etapes[etape] ?? etapes[0];

  function suivant() {
    setI((n) => (n + 1) % SUJETS_PARA.length);
    setEtape(0);
    setCases({ arg: "", exp: "", ex: "", concl: "" });
    setMontre(false);
  }

  return (
    <div className="space-y-3">
      <div>
        <Choice<"batir" | "reparer">
          label="Atelier"
          value={atelier}
          options={[
            { value: "batir", label: "bâtir un paragraphe" },
            { value: "reparer", label: "réparer un paragraphe" },
          ]}
          onChange={setAtelier}
        />
      </div>

      {atelier === "batir" ? (
        <div className="rounded-lg border border-border bg-background p-3">
          <p className="text-[11px] text-muted-foreground">Ta thèse</p>
          <p className="text-sm font-semibold text-foreground">{s.these}</p>
          <p className="mt-1 text-[11px] text-muted-foreground">{s.consigne}</p>

          <div className="mt-3 flex flex-wrap gap-1.5">
            {etapes.map((x, k) => (
              <span
                key={x.cle}
                className="rounded px-2 py-0.5 text-[11px]"
                style={{
                  backgroundColor:
                    k < etape
                      ? "rgba(21,128,61,0.12)"
                      : k === etape
                        ? "rgba(37,99,235,0.14)"
                        : "rgba(100,116,139,0.10)",
                  color: k < etape ? "#14532d" : k === etape ? PALETTE.blue : PALETTE.slate,
                  fontWeight: k === etape ? 700 : 400,
                }}
              >
                {x.nom}
              </span>
            ))}
          </div>

          <p className="mt-2 text-[11px] text-muted-foreground">{e?.aide ?? ""}</p>
          <textarea
            value={cases[e?.cle ?? "arg"]}
            onChange={(ev) => setCases((c) => ({ ...c, [e?.cle ?? "arg"]: ev.target.value }))}
            rows={e?.cle === "exp" ? 4 : 3}
            className="mt-1 w-full rounded-md border border-border bg-background px-2.5 py-1.5 text-sm text-foreground"
          />

          {cases[e?.cle ?? "arg"].trim().length > 0 && e?.ok === false ? (
            <div className="mt-2">
              <Verdict tone="warn">
                <span className="font-semibold">Pas encore. </span>
                {e.raison}
              </Verdict>
            </div>
          ) : null}

          <div className="mt-2 flex flex-wrap gap-2">
            {etape < 3 ? (
              <button
                type="button"
                disabled={e?.ok !== true}
                onClick={() => setEtape((n) => n + 1)}
                className="rounded-lg bg-primary px-3 py-1.5 text-xs font-semibold text-primary-foreground"
                style={{ opacity: e?.ok === true ? 1 : 0.4 }}
              >
                Temps suivant
              </button>
            ) : (
              <button
                type="button"
                onClick={() => setMontre(true)}
                className="rounded-lg bg-primary px-3 py-1.5 text-xs font-semibold text-primary-foreground"
              >
                Voir mon paragraphe et le modèle
              </button>
            )}
            <button
              type="button"
              onClick={suivant}
              className="rounded-lg border border-border px-3 py-1.5 text-xs font-semibold text-foreground"
            >
              Sujet suivant ({i + 1} / {SUJETS_PARA.length})
            </button>
          </div>

          {montre ? (
            <div className="mt-3 grid gap-2 sm:grid-cols-2">
              <div
                className="rounded-md px-2.5 py-2"
                style={{ backgroundColor: "rgba(37,99,235,0.08)" }}
              >
                <p className="text-[11px] font-semibold" style={{ color: PALETTE.blue }}>
                  ton paragraphe
                </p>
                <p className="mt-1 text-xs text-foreground">
                  {cases.arg} {cases.exp} {cases.ex} {cases.concl}
                </p>
              </div>
              <div
                className="rounded-md px-2.5 py-2"
                style={{ backgroundColor: "rgba(21,128,61,0.08)" }}
              >
                <p className="text-[11px] font-semibold" style={{ color: PALETTE.green }}>
                  un modèle possible
                </p>
                <p className="mt-1 text-xs text-foreground">
                  {s.modele.arg} {s.modele.exp} {s.modele.ex} {s.modele.concl}
                </p>
              </div>
            </div>
          ) : null}
        </div>
      ) : (
        <div className="rounded-lg border border-border bg-background p-3">
          <p className="text-[11px] font-semibold text-muted-foreground">PARAGRAPHE À RÉPARER</p>
          <p className="mt-1 text-sm italic text-foreground">« {r.texte} »</p>

          {!vuDefaut ? (
            <button
              type="button"
              onClick={() => setVuDefaut(true)}
              className="mt-3 rounded-lg border border-border px-3 py-1.5 text-xs font-semibold text-foreground"
            >
              Qu'est-ce qui ne va pas ?
            </button>
          ) : (
            <div className="mt-3 space-y-2">
              <Verdict tone="bad">
                <span className="font-semibold">Le défaut. </span>
                {r.defaut}
              </Verdict>
              <Verdict tone="ok">
                <span className="font-semibold">La réparation. </span>
                {r.reparation}
              </Verdict>
            </div>
          )}

          <button
            type="button"
            onClick={() => {
              setIr((n) => (n + 1) % A_REPARER.length);
              setVuDefaut(false);
            }}
            className="mt-3 rounded-lg bg-primary px-3 py-1.5 text-xs font-semibold text-primary-foreground"
          >
            Paragraphe suivant ({ir + 1} / {A_REPARER.length})
          </button>
        </div>
      )}

      <Citation auteur="si tu ne devais retenir qu'une chose">
        Écris la dernière phrase de chaque paragraphe en la rattachant à ta thèse. Cinq secondes, et
        ta copie change de niveau — parce que le lecteur a l'impression que chaque paragraphe fait
        AVANCER la démonstration, au lieu de s'ajouter aux précédents.
      </Citation>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* 4. L'échelle de l'engagement                                        */
/* ------------------------------------------------------------------ */

const ENGAGEMENTS: ReadonlyArray<{ formule: string; force: number }> = [
  { formule: "Il me semble que…", force: 0 },
  { formule: "Je crois que…", force: 1 },
  { formule: "Je pense que…", force: 2 },
  { formule: "Je suis convaincu que…", force: 3 },
  { formule: "Il est évident que…", force: 4 },
];

type SituationEngagement = {
  id: string;
  ceQueJeSais: string;
  nature: "fait vérifié" | "impression" | "rumeur";
  affirmation: string;
  juste: number;
  reactionTrop: string;
  reactionPeu: string;
  reactionJuste: string;
};

const SITUATIONS_ENG: ReadonlyArray<SituationEngagement> = [
  {
    id: "se1",
    ceQueJeSais: "J'ai vu moi-même le bac disparaître en janvier.",
    nature: "fait vérifié",
    affirmation: "le bac a été retiré en janvier",
    juste: 4,
    reactionTrop: "—",
    reactionPeu:
      "Tu l'as vu de tes yeux : pourquoi hésiter ? Un engagement trop faible sur un fait vérifié donne l'impression que tu doutes de toi, et ton interlocuteur doutera aussi.",
    reactionJuste: "Tu as un fait, tu l'affirmes. C'est exactement l'usage de l'engagement fort.",
  },
  {
    id: "se2",
    ceQueJeSais:
      "Il me semble que le camion passe moins souvent qu'avant, mais je n'ai rien compté.",
    nature: "impression",
    affirmation: "le camion passe moins souvent",
    juste: 0,
    reactionTrop:
      "Tu présentes une impression comme une certitude. Si quelqu'un a compté les passages et te contredit, tu perds toute ta crédibilité — y compris sur ce que tu sais vraiment.",
    reactionPeu: "—",
    reactionJuste:
      "Tu dis ce que tu sais, et tu dis que tu n'as pas vérifié. Un interlocuteur pardonne une erreur ; il ne pardonne pas qu'on lui ait présenté une supposition comme une certitude.",
  },
  {
    id: "se3",
    ceQueJeSais: "Quelqu'un m'a dit que l'argent de la cotisation avait disparu.",
    nature: "rumeur",
    affirmation: "la cotisation a été détournée",
    juste: 0,
    reactionTrop:
      "C'est une accusation grave fondée sur un ouï-dire. Jamais. Transforme-la en demande : « je voudrais qu'on nous explique l'écart entre la somme et les travaux ».",
    reactionPeu: "—",
    reactionJuste:
      "Et même à ce niveau, mieux vaut encore ne pas accuser : constate l'écart, et demande une explication. Une accusation se nie ; une demande d'explication est difficile à refuser.",
  },
  {
    id: "se4",
    ceQueJeSais:
      "Les chiffres du service technique donnent six bacs pour quarante mille habitants.",
    nature: "fait vérifié",
    affirmation: "le quartier est sous-équipé",
    juste: 3,
    reactionTrop:
      "« Il est évident que » est de trop : les chiffres parlent, inutile d'en rajouter. Cite-les plutôt.",
    reactionPeu: "Tu as un chiffre officiel. Engage-toi.",
    reactionJuste:
      "Engagement fort, appuyé sur un chiffre. C'est la combinaison la plus solide d'un débat.",
  },
  {
    id: "se5",
    ceQueJeSais: "J'ai l'impression que les gens n'ont pas compris le projet.",
    nature: "impression",
    affirmation: "le projet n'a pas été compris",
    juste: 1,
    reactionTrop:
      "Tu juges les gens sans preuve. Et le reproche se retourne : peut-être est-ce la présentation qui a manqué de clarté.",
    reactionPeu: "—",
    reactionJuste:
      "« Je crois que » convient à une impression fondée sur de l'observation. Et déplace le reproche : « je me demande si la manière dont on l'a présenté n'y est pas pour quelque chose ».",
  },
  {
    id: "se6",
    ceQueJeSais: "J'ai compté : neuf cents arbres sur mille deux cents étaient debout.",
    nature: "fait vérifié",
    affirmation: "la méthode de Ngaoundéré marche",
    juste: 3,
    reactionTrop:
      "« Évident » est excessif : un seul cas ne prouve pas une méthode générale. Dis plutôt « je suis convaincu », et cite ton chiffre.",
    reactionPeu: "Tu as compté toi-même. Tu peux t'engager.",
    reactionJuste: "Engagement fort sur un chiffre vérifié, sans généraliser abusivement.",
  },
];

const SITUATION_ENG_VIDE: SituationEngagement = {
  id: "",
  ceQueJeSais: "—",
  nature: "impression",
  affirmation: "—",
  juste: 0,
  reactionTrop: "—",
  reactionPeu: "—",
  reactionJuste: "—",
};

type PhraseRegistre = {
  id: string;
  familier: string;
  soigne: string;
  marques: ReadonlyArray<string>;
};

const REGISTRES: ReadonlyArray<PhraseRegistre> = [
  {
    id: "rg1",
    familier: "C'est pas vrai, les gens ils disent n'importe quoi.",
    soigne: "Ce n'est pas exact, et je crois que ce qu'on rapporte est inexact.",
    marques: ["négation incomplète : « c'est pas »", "sujet redoublé : « les gens ils »"],
  },
  {
    id: "rg2",
    familier: "Tu viens quand ? On sait pas trop.",
    soigne: "Quand viens-tu ? Nous ne le savons pas encore.",
    marques: ["interrogation sans inversion", "négation incomplète : « on sait pas »"],
  },
  {
    id: "rg3",
    familier: "Franchement c'est nul leur truc, ça marchera jamais.",
    soigne:
      "Ce projet me paraît fragile, et je doute qu'il tienne : il ne prévoit aucun financement après la première année.",
    marques: [
      "registre familier : « nul », « truc »",
      "négation incomplète : « marchera jamais »",
      "engagement maximal sans fondement",
    ],
  },
  {
    id: "rg4",
    familier: "Les commerçants ils comprennent rien à ce qu'on leur explique.",
    soigne:
      "Je crois que le message n'a pas été compris, et je me demande si la manière dont il a été présenté n'y est pas pour quelque chose.",
    marques: [
      "sujet redoublé",
      "négation incomplète : « comprennent rien »",
      "jugement global non fondé",
    ],
  },
  {
    id: "rg5",
    familier: "Bah je sais pas trop, enfin peut-être, euh, voilà.",
    soigne:
      "Je n'ai pas d'avis arrêté. Ce qui me retient, c'est que nous n'avons pas de chiffres sur le coût ; si on me les donne, je pourrai me prononcer.",
    marques: [
      "tics : bah, enfin, euh, voilà",
      "négation incomplète",
      "absence totale d'engagement",
    ],
  },
  {
    id: "rg6",
    familier: "Y a rien qui marche dans ce quartier, c'est pas la peine.",
    soigne:
      "Plusieurs projets ont échoué ici. J'aimerais savoir lesquels, pour comprendre ce qui a manqué.",
    marques: ["« y a » pour « il y a »", "négation incomplète", "généralisation décourageante"],
  },
];

const REGISTRE_VIDE: PhraseRegistre = { id: "", familier: "—", soigne: "—", marques: [] };

export function ExprimerOpinion() {
  const [atelier, setAtelier] = useState<"engagement" | "registre">("engagement");
  const [i, setI] = useState(0);
  const [niveau, setNiveau] = useState(2);
  const [valide, setValide] = useState(false);
  const [ir, setIr] = useState(0);
  const [montre, setMontre] = useState(false);

  const s = SITUATIONS_ENG[i] ?? SITUATION_ENG_VIDE;
  const r = REGISTRES[ir] ?? REGISTRE_VIDE;
  const ecart = niveau - s.juste;

  return (
    <div className="space-y-3">
      <div>
        <Choice<"engagement" | "registre">
          label="Atelier"
          value={atelier}
          options={[
            { value: "engagement", label: "l'échelle de l'engagement" },
            { value: "registre", label: "le registre courant soigné" },
          ]}
          onChange={setAtelier}
        />
      </div>

      {atelier === "engagement" ? (
        <div className="rounded-lg border border-border bg-background p-3">
          <p className="text-[11px] font-semibold text-muted-foreground">CE QUE TU SAIS VRAIMENT</p>
          <p className="text-sm text-foreground">{s.ceQueJeSais}</p>
          <p className="mt-0.5 text-[11px]" style={{ color: PALETTE.orange }}>
            nature : {s.nature}
          </p>

          <div className="mt-3">
            <Ctrl
              label="Ton engagement"
              value={niveau}
              min={0}
              max={ENGAGEMENTS.length - 1}
              step={1}
              onChange={(v) => {
                setNiveau(Math.round(v));
                setValide(false);
              }}
              display={ENGAGEMENTS[niveau]?.formule ?? "—"}
              color={PALETTE.purple}
            />
          </div>

          <p className="mt-2 text-base italic text-foreground">
            {ENGAGEMENTS[niveau]?.formule.replace("…", "")} {s.affirmation}.
          </p>

          {!valide ? (
            <button
              type="button"
              onClick={() => setValide(true)}
              className="mt-3 rounded-lg bg-primary px-3 py-1.5 text-xs font-semibold text-primary-foreground"
            >
              Comment ton interlocuteur le reçoit
            </button>
          ) : (
            <div className="mt-3 space-y-2">
              <Verdict tone={ecart === 0 ? "ok" : Math.abs(ecart) === 1 ? "warn" : "bad"}>
                <span className="font-semibold">
                  L'engagement juste : « {ENGAGEMENTS[s.juste]?.formule ?? ""} ».{" "}
                </span>
                {ecart > 1 ? s.reactionTrop : ecart < -1 ? s.reactionPeu : s.reactionJuste}
              </Verdict>
              <button
                type="button"
                onClick={() => {
                  setI((n) => (n + 1) % SITUATIONS_ENG.length);
                  setNiveau(2);
                  setValide(false);
                }}
                className="rounded-lg bg-primary px-3 py-1.5 text-xs font-semibold text-primary-foreground"
              >
                Situation suivante ({i + 1} / {SITUATIONS_ENG.length})
              </button>
            </div>
          )}
        </div>
      ) : (
        <div className="rounded-lg border border-border bg-background p-3">
          <p className="text-[11px] font-semibold text-muted-foreground">EN REGISTRE FAMILIER</p>
          <p className="text-sm italic text-foreground">« {r.familier} »</p>

          <div className="mt-2 flex flex-wrap gap-1.5">
            {r.marques.map((m) => (
              <span
                key={m}
                className="rounded px-2 py-0.5 text-[11px]"
                style={{ backgroundColor: "rgba(185,28,28,0.12)", color: "#7f1d1d" }}
              >
                {m}
              </span>
            ))}
          </div>

          {!montre ? (
            <button
              type="button"
              onClick={() => setMontre(true)}
              className="mt-3 rounded-lg border border-border px-3 py-1.5 text-xs font-semibold text-foreground"
            >
              Voir la version en registre courant soigné
            </button>
          ) : (
            <div className="mt-3">
              <Verdict tone="ok">
                <span className="font-semibold">En registre courant soigné. </span>
                {r.soigne}
              </Verdict>
            </div>
          )}

          <button
            type="button"
            onClick={() => {
              setIr((n) => (n + 1) % REGISTRES.length);
              setMontre(false);
            }}
            className="mt-2 rounded-lg bg-primary px-3 py-1.5 text-xs font-semibold text-primary-foreground"
          >
            Phrase suivante ({ir + 1} / {REGISTRES.length})
          </button>

          <p
            className="mt-3 rounded-md px-2 py-1.5 text-[11px]"
            style={{ backgroundColor: "rgba(202,138,4,0.12)", color: "#78350f" }}
          >
            <span className="font-semibold">Les trois marques à surveiller. </span>
            La négation incomplète — « c'est pas » → « ce n'est pas ». Le sujet redoublé — « les
            gens ils disent » → « les gens disent ». L'interrogation sans inversion — « tu viens
            quand ? » → « quand viens-tu ? ». Aucune ne demande de vocabulaire nouveau.
          </p>
        </div>
      )}

      <Citation auteur="celui qui sait dire ce qu'il ignore est cru sur ce qu'il affirme">
        C'est la règle qui gouverne tout ce chapitre. Un interlocuteur pardonne une erreur ; il ne
        pardonne pas qu'on lui ait présenté une supposition comme une certitude.
      </Citation>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* 5. La console du stand                                              */
/* ------------------------------------------------------------------ */

type ProjetStand = {
  id: string;
  titre: string;
  troisChoses: ReadonlyArray<{ texte: string; bon: boolean; pourquoi: string }>;
  modeles: { accroche: string; probleme: string; solution: string; demande: string };
};

const PROJETS: ReadonlyArray<ProjetStand> = [
  {
    id: "pj1",
    titre: "Un composteur de quartier pour réduire les ordures",
    troisChoses: [
      {
        texte: "La moitié du poids de nos poubelles est constituée d'épluchures.",
        bon: true,
        pourquoi: "UN chiffre, simple et surprenant. C'est ce qui reste.",
      },
      {
        texte: "Le bac qui déborde, à côté du composteur qui tient dans un coin de cour.",
        bon: true,
        pourquoi: "UNE image, qui se comprend sans légende.",
      },
      {
        texte: "Le visiteur aura pris une poignée de compost dans la main.",
        bon: true,
        pourquoi: "UN geste. Ce qu'on a touché, on s'en souvient.",
      },
      {
        texte: "Le composteur mesure un mètre sur un mètre et coûte quinze mille francs.",
        bon: false,
        pourquoi:
          "Deux informations techniques : utiles pendant la présentation, mais personne ne les retient.",
      },
      {
        texte: "L'histoire du projet depuis sa création.",
        bon: false,
        pourquoi: "Cela n'intéresse que ceux qui l'ont fait.",
      },
      {
        texte: "Les noms des membres de l'association.",
        bon: false,
        pourquoi: "Le visiteur ne retiendra aucun nom.",
      },
    ],
    modeles: {
      accroche:
        "Bonjour. Vous savez ce qu'il y a dans votre poubelle ? … La moitié, c'est des épluchures. De l'eau et des légumes. On paie pour transporter de l'eau.",
      probleme:
        "Le camion passe une fois par semaine chez nous, quand il passe. Le bac déborde au bout de trois jours, et ce qui déborde finit dans le caniveau. En septembre, le caniveau bouché nous met les pieds dans l'eau. Or sur ce qui déborde, la moitié n'avait rien à faire là.",
      solution:
        "Voilà le composteur. C'est un bac en bois d'un mètre sur un mètre. On y met les épluchures, les feuilles, un peu de terre, et on remue une fois par semaine. Au bout de trois mois, ça donne ça — prenez, ça ne sent rien, ça sent la terre. Celui qu'on a installé derrière l'école reçoit les déchets de douze familles ; depuis janvier, leur bac ne déborde plus.",
      demande:
        "Nous cherchons cinq familles de plus pour en installer un deuxième au carrefour. Si ça vous dit, écrivez votre nom et votre maison sur cette feuille ; je passerai samedi. Et si vous préférez voir avant de décider, venez derrière l'école un matin, n'importe lequel.",
    },
  },
  {
    id: "pj2",
    titre: "Un point d'eau supplémentaire pour le secteur",
    troisChoses: [
      {
        texte: "Quatre cents maisons, un seul robinet, deux heures d'eau par jour.",
        bon: true,
        pourquoi: "Trois chiffres qui tiennent en une phrase, et qui disent tout.",
      },
      {
        texte: "Le bidon de vingt litres posé sur la table du stand.",
        bon: true,
        pourquoi: "Un objet qu'on peut soulever — et qui pèse vingt kilos.",
      },
      {
        texte: "Le visiteur aura essayé de porter le bidon sur dix pas.",
        bon: true,
        pourquoi: "Le geste qui transforme un chiffre en expérience.",
      },
      {
        texte: "Le détail du devis du plombier.",
        bon: false,
        pourquoi: "Information de dossier, pas de stand.",
      },
      {
        texte: "La carte du réseau d'eau de la commune.",
        bon: false,
        pourquoi: "Trop complexe à lire debout, en vingt secondes.",
      },
      {
        texte: "Le règlement du comité de quartier.",
        bon: false,
        pourquoi: "Personne ne lira un règlement sur un stand.",
      },
    ],
    modeles: {
      accroche:
        "Soulevez ce bidon, s'il vous plaît. … Vingt kilos. Ma tante en porte deux, sur six cents mètres, tous les matins.",
      probleme:
        "Notre secteur compte quatre cents maisons et un seul robinet public, qui coule de cinq à sept heures du matin. La file commence à quatre heures. Quatre heures passées dans une file ne figurent sur aucun budget, et c'est pourquoi personne ne les compte.",
      solution:
        "Nous demandons une seconde borne-fontaine au carrefour nord. Voici le plan : la conduite passe déjà à quarante mètres. Le comité a réuni la moitié de la somme l'an dernier ; voici le reçu.",
      demande:
        "Il nous manque cent cinquante signatures pour que le dossier soit recevable. La feuille est là. Et si vous connaissez quelqu'un à la délégation de l'eau, dites-le-nous.",
    },
  },
  {
    id: "pj3",
    titre: "Un atelier de réparation de vélos à l'école",
    troisChoses: [
      {
        texte: "Vingt-trois élèves viennent à vélo ; onze ont un frein qui ne marche pas.",
        bon: true,
        pourquoi: "Un chiffre précis et inquiétant, obtenu en comptant.",
      },
      {
        texte: "Le vélo réparé, exposé à côté de celui qui ne l'est pas.",
        bon: true,
        pourquoi: "Une comparaison visible en une seconde.",
      },
      {
        texte: "Le visiteur aura serré un frein lui-même, avec la clé.",
        bon: true,
        pourquoi: "Le geste, encore : on retient ce qu'on a fait.",
      },
      {
        texte: "La liste complète des outils de l'atelier.",
        bon: false,
        pourquoi: "Détail d'intendance.",
      },
      {
        texte: "Les horaires d'ouverture prévus.",
        bon: false,
        pourquoi:
          "Utile, mais à mettre sur un papier à emporter, pas dans les trois choses à retenir.",
      },
      {
        texte: "Le nom du professeur qui encadre.",
        bon: false,
        pourquoi: "Personne ne le retiendra.",
      },
    ],
    modeles: {
      accroche:
        "Essayez ce frein. … Il ne serre pas. C'est celui d'un vélo qui fait six kilomètres par jour sur la nationale.",
      probleme:
        "Vingt-trois élèves viennent à vélo. Nous avons vérifié tous les freins en deux récréations : onze ne tenaient pas. Aucun de ces élèves n'a d'argent pour aller chez le réparateur.",
      solution:
        "L'atelier ouvre le mercredi après-midi. Deux élèves formés, une caisse d'outils, et on apprend au propriétaire à le faire lui-même — c'est la seule façon que ça tienne. Voilà un vélo réparé mardi ; prenez la clé, serrez le frein vous-même.",
      demande:
        "Nous cherchons des outils : clés plates, démonte-pneus, rustines. Si vous en avez qui dorment, apportez-les mercredi. La boîte est là.",
    },
  },
];

const PROJET_VIDE: ProjetStand = {
  id: "",
  titre: "—",
  troisChoses: [],
  modeles: { accroche: "—", probleme: "—", solution: "—", demande: "—" },
};

export function PresenterStand() {
  const [i, setI] = useState(0);
  const [choisies, setChoisies] = useState<ReadonlyArray<number>>([]);
  const [valideTrois, setValideTrois] = useState(false);
  const [blocs, setBlocs] = useState({ accroche: "", probleme: "", solution: "", demande: "" });
  const [modeles, setModeles] = useState(false);
  const [affiche, setAffiche] = useState("");

  const p = PROJETS[i] ?? PROJET_VIDE;
  const bonnes = p.troisChoses.filter((c, k) => c.bon && choisies.includes(k)).length;

  function jauge(texte: string) {
    let v = 20;
    if (/\d/.test(texte)) v += 30;
    if (/\?/.test(texte)) v += 20;
    if (/\b(prenez|tenez|essayez|soulevez|regardez|touchez|voilà|voici)\b/i.test(texte)) v += 30;
    if (texte.split(/\s+/).length > 120) v -= 30;
    return Math.max(0, Math.min(100, v));
  }

  const motsAffiche = affiche.trim().length === 0 ? 0 : affiche.trim().split(/\s+/).length;

  return (
    <div className="space-y-3">
      <p className="text-sm text-muted-foreground">
        On commence par la fin : quelles trois choses le visiteur doit-il emporter ? Les quatre
        temps n'ouvrent qu'après.
      </p>

      <div className="rounded-lg border border-border bg-background p-3">
        <p className="text-sm font-semibold text-foreground">{p.titre}</p>

        <p className="mt-3 text-[11px] font-semibold text-muted-foreground">
          CHOISIS LES TROIS CHOSES À FAIRE RETENIR
        </p>
        <div className="mt-1 space-y-1.5">
          {p.troisChoses.map((c, k) => (
            <button
              key={c.texte.slice(0, 20)}
              type="button"
              onClick={() =>
                setChoisies((x) => (x.includes(k) ? x.filter((y) => y !== k) : [...x, k]))
              }
              className="block w-full rounded-md border px-2.5 py-1.5 text-left text-xs"
              style={{
                borderColor: choisies.includes(k)
                  ? valideTrois
                    ? c.bon
                      ? PALETTE.green
                      : PALETTE.red
                    : PALETTE.blue
                  : "rgba(100,116,139,0.3)",
                backgroundColor: choisies.includes(k)
                  ? valideTrois
                    ? c.bon
                      ? "rgba(21,128,61,0.10)"
                      : "rgba(185,28,28,0.10)"
                    : "rgba(37,99,235,0.08)"
                  : "transparent",
              }}
            >
              {c.texte}
              {valideTrois && choisies.includes(k) ? (
                <span className="mt-0.5 block text-[10px] text-muted-foreground">{c.pourquoi}</span>
              ) : null}
            </button>
          ))}
        </div>

        {!valideTrois ? (
          <button
            type="button"
            disabled={choisies.length !== 3}
            onClick={() => setValideTrois(true)}
            className="mt-2 rounded-lg bg-primary px-3 py-1.5 text-xs font-semibold text-primary-foreground"
            style={{ opacity: choisies.length === 3 ? 1 : 0.4 }}
          >
            {choisies.length === 3
              ? "Valider mes trois choses"
              : `Choisis-en exactement trois (${choisies.length} / 3)`}
          </button>
        ) : (
          <div className="mt-2">
            <Verdict tone={bonnes === 3 ? "ok" : bonnes === 2 ? "warn" : "bad"}>
              <span className="font-semibold">{bonnes} / 3 bien choisies. </span>
              Ce qui reste d'une présentation de stand : un chiffre, une image, et ce que tu as fait
              faire au visiteur. Tout le reste s'oublie.
            </Verdict>
          </div>
        )}
      </div>

      {valideTrois ? (
        <div className="rounded-lg border border-border bg-background p-3">
          <p className="text-[11px] font-semibold text-muted-foreground">
            LES QUATRE TEMPS, EN TROIS MINUTES
          </p>
          <div className="mt-2 space-y-2">
            {(
              [
                {
                  cle: "accroche" as const,
                  label: "0 — 20 s · L'ACCROCHE",
                  aide: "un chiffre, un objet tendu, ou une question",
                },
                {
                  cle: "probleme" as const,
                  label: "20 s — 1 min · LE PROBLÈME",
                  aide: "à quoi ça sert, et pour qui",
                },
                {
                  cle: "solution" as const,
                  label: "1 — 2 min 30 · LA SOLUTION",
                  aide: "on montre, on fait toucher, on prouve",
                },
                {
                  cle: "demande" as const,
                  label: "2 min 30 — 3 · LA DEMANDE",
                  aide: "ce que tu veux du visiteur — le temps que tout le monde oublie",
                },
              ] as const
            ).map((b) => {
              const v = jauge(blocs[b.cle]);
              return (
                <div key={b.cle}>
                  <p className="text-[11px] font-semibold text-foreground">{b.label}</p>
                  <p className="text-[10px] text-muted-foreground">{b.aide}</p>
                  <textarea
                    value={blocs[b.cle]}
                    onChange={(e) => setBlocs((x) => ({ ...x, [b.cle]: e.target.value }))}
                    rows={3}
                    className="mt-0.5 w-full rounded-md border border-border bg-background px-2.5 py-1.5 text-sm text-foreground"
                  />
                  {blocs[b.cle].trim().length > 0 ? (
                    <div className="mt-1 flex items-center gap-2">
                      <span className="w-24 text-[10px] text-muted-foreground">attention</span>
                      <div className="h-2 flex-1 overflow-hidden rounded bg-muted">
                        <div
                          className="h-full rounded"
                          style={{
                            width: `${v}%`,
                            backgroundColor:
                              v >= 60 ? PALETTE.green : v >= 40 ? PALETTE.orange : PALETTE.red,
                          }}
                        />
                      </div>
                      <span className="text-[10px] text-muted-foreground">
                        {v >= 60 ? "il reste" : v >= 40 ? "il écoute" : "il s'en va"}
                      </span>
                    </div>
                  ) : null}
                  {modeles ? (
                    <p className="mt-0.5 text-[10px] italic text-muted-foreground">
                      modèle : {p.modeles[b.cle]}
                    </p>
                  ) : null}
                </div>
              );
            })}
          </div>

          <div className="mt-3">
            <p className="text-[11px] font-semibold text-foreground">
              L'affiche — sept mots, pas un de plus
            </p>
            <input
              value={affiche}
              onChange={(e) => setAffiche(e.target.value)}
              className="mt-1 w-full rounded-md border px-2.5 py-1.5 text-sm text-foreground"
              style={{
                borderColor: motsAffiche > 7 ? PALETTE.red : "rgba(100,116,139,0.3)",
              }}
            />
            <p
              className="mt-1 text-[11px]"
              style={{ color: motsAffiche > 7 ? PALETTE.red : PALETTE.slate }}
            >
              {motsAffiche} mot{motsAffiche > 1 ? "s" : ""}
              {motsAffiche > 7
                ? " — trop. Une affiche couverte de texte ne se lit jamais debout : si tu as besoin de plus, c'est qu'elle fait ton travail à ta place."
                : ""}
            </p>
            {motsAffiche > 0 && motsAffiche <= 7 ? (
              <div
                className="mt-2 rounded-md px-3 py-6 text-center"
                style={{ backgroundColor: "rgba(100,116,139,0.08)" }}
              >
                <p className="text-lg font-bold text-foreground">{affiche}</p>
                <p className="mt-1 text-[10px] text-muted-foreground">
                  vu de trois mètres, c'est tout ce qui passe
                </p>
              </div>
            ) : null}
          </div>

          <div className="mt-3 flex flex-wrap gap-2">
            <button
              type="button"
              onClick={() => setModeles((m) => !m)}
              className="rounded-lg border border-border px-3 py-1.5 text-xs font-semibold text-foreground"
            >
              {modeles ? "Masquer les modèles" : "Voir les modèles"}
            </button>
            <button
              type="button"
              onClick={() => {
                setI((n) => (n + 1) % PROJETS.length);
                setChoisies([]);
                setValideTrois(false);
                setBlocs({ accroche: "", probleme: "", solution: "", demande: "" });
                setModeles(false);
                setAffiche("");
              }}
              className="rounded-lg bg-primary px-3 py-1.5 text-xs font-semibold text-primary-foreground"
            >
              Projet suivant ({i + 1} / {PROJETS.length})
            </button>
          </div>
        </div>
      ) : null}

      <Citation auteur="une présentation sans demande est un coup d'épée dans l'eau">
        On présente, on remercie, et le visiteur repart sans savoir quoi faire. Dis-lui ce que tu
        attends de lui — précisément — et offre-lui une seconde porte de sortie s'il hésite.
      </Citation>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* 6. La salle de questions                                            */
/* ------------------------------------------------------------------ */

type QuestionPublic = {
  id: string;
  question: string;
  genre: "simple" | "attendue" | "agressive" | "horssujet" | "dejaposee" | "jenesaispas";
  reformulation: string;
  modele: string;
  commentaire: string;
};

const QUESTIONS_PUBLIC: ReadonlyArray<QuestionPublic> = [
  {
    id: "qp1",
    question: "Et ça coûte combien ?",
    genre: "simple",
    reformulation: "Si je comprends bien, vous demandez le coût de fabrication du bac ?",
    modele:
      "Environ quinze mille francs pour le bac. C'est le bois et les clous ; la main-d'œuvre, c'est nous. Celui de l'école nous a coûté douze mille parce qu'on a récupéré des planches. Est-ce que cela répond à votre question ?",
    commentaire:
      "Réponse courte d'abord — « quinze mille francs » — puis le développement. Celui qui développe avant de répondre donne l'impression d'éviter la question.",
  },
  {
    id: "qp2",
    question: "Ça va attirer les rats, non ?",
    genre: "attendue",
    reformulation: "Vous vous demandez si le compost attire les nuisibles ?",
    modele:
      "C'est la question qu'on nous pose à chaque fois, et c'est normal. Non, à condition de n'y mettre ni viande ni poisson — ce sont eux qui attirent les rats. Épluchures, feuilles, coquilles d'œuf : ça ne les intéresse pas. Celui de l'école tourne depuis janvier, vous pouvez aller voir.",
    commentaire:
      "C'est l'objection principale : elle doit être préparée. Le « c'est normal » désamorce — la personne ne se sent pas sotte d'avoir posé la question, et elle écoute la réponse.",
  },
  {
    id: "qp3",
    question: "De toute façon, ici, rien ne marche jamais.",
    genre: "agressive",
    reformulation: "Vous pensez à des projets précis qui ont échoué ici ? Lesquels ?",
    modele:
      "Vous pensez à des projets précis qui ont échoué ici ? Lesquels ? … Je comprends. Ce que nous faisons différemment, c'est que le bac appartient aux douze familles qui s'en servent, et qu'il n'y a pas d'argent extérieur à gérer. C'est peut-être ce qui a manqué aux autres.",
    commentaire:
      "Ne te défends pas et ne réponds pas à l'agressivité : cherche la question dans la phrase. Tu transformes une attaque en information utile — et c'est souvent ce que la personne voulait : être entendue sur ce qui l'a déçue.",
  },
  {
    id: "qp4",
    question: "Est-ce que le bois va tenir sous la pluie ?",
    genre: "jenesaispas",
    reformulation: "Vous demandez combien de temps le bac durera dehors ?",
    modele:
      "Je ne sais pas. Je peux demander au menuisier qui a fait le premier et vous le dire samedi, si vous repassez. Ce que je sais, c'est que celui de l'école est dehors depuis janvier, qu'il a pris toute la saison des pluies, et qu'il n'a pas bougé.",
    commentaire:
      "Trois temps : on le dit, on propose, on donne ce qu'on a. Cette réponse vaut mieux qu'une réponse inventée qui serait juste — celui qui t'écoute retiendra que tu n'inventes pas, et il croira tout le reste.",
  },
  {
    id: "qp5",
    question: "Et le problème de l'eau dans le quartier, vous en faites quoi ?",
    genre: "horssujet",
    reformulation: "Vous parlez de l'accès à l'eau, qui est un autre sujet ?",
    modele:
      "Ça, c'est un autre problème, et il est réel — le comité s'en occupe de son côté. Pour ce qui nous occupe ici, le compost ne demande pas d'eau : c'est même son avantage.",
    commentaire:
      "Réponds brièvement, reconnais que la question est légitime, puis ramène. Ne balaie jamais : la personne a posé la question parce qu'elle lui tient à cœur.",
  },
  {
    id: "qp6",
    question: "Mais ça sent pas mauvais quand même ?",
    genre: "dejaposee",
    reformulation: "Vous revenez sur l'odeur ?",
    modele:
      "Oui — et je vais le dire d'une autre façon, parce que je n'ai peut-être pas été clair. Ce qui sent, c'est la viande et le manque d'air. Ici, il n'y a ni l'une ni l'autre : on ne met que du végétal, et on remue. Tenez, sentez vous-même.",
    commentaire:
      "Ne fais jamais remarquer que tu viens de répondre. « Je viens de le dire » perd la salle ; « je n'ai peut-être pas été clair » la gagne entièrement.",
  },
  {
    id: "qp7",
    question: "Qui paie, au juste ?",
    genre: "attendue",
    reformulation: "Vous voulez savoir d'où vient l'argent ?",
    modele:
      "Les douze familles ont mis mille francs chacune, et l'école a donné les planches. Il n'y a pas de subvention, et c'est volontaire : un projet qui dépend d'un financement extérieur s'arrête quand le financement s'arrête.",
    commentaire:
      "« Qui paie » est, avec « ça sent mauvais », la question qui vient toujours. Fais la liste des trois questions que tu redoutes, et prépare les trois réponses : ce sont celles-là qui viendront.",
  },
  {
    id: "qp8",
    question: "Vous êtes de quelle association, exactement ?",
    genre: "simple",
    reformulation: "Vous demandez qui porte le projet ?",
    modele:
      "Nous sommes quatre élèves du lycée et deux parents du quartier. Il n'y a pas d'association déclarée : c'est un groupe de voisins. Est-ce que cela vous pose un problème ?",
    commentaire:
      "Une question d'identité se répond court et franchement. Et la question finale — « est-ce que cela vous pose un problème ? » — montre que tu ne crains pas la réponse.",
  },
  {
    id: "qp9",
    question: "Combien de temps avant d'avoir du compost utilisable ?",
    genre: "simple",
    reformulation: "Vous demandez le délai avant la première récolte de compost ?",
    modele:
      "Trois mois en saison des pluies, quatre à cinq en saison sèche. Celui de l'école a été rempli en janvier, et on a sorti le premier compost fin avril.",
    commentaire:
      "Deux chiffres et une date. Une bonne réponse courte est souvent une réponse datée.",
  },
  {
    id: "qp10",
    question: "Est-ce que la mairie est au courant ?",
    genre: "jenesaispas",
    reformulation: "Vous demandez si le projet a été déclaré à la commune ?",
    modele:
      "Je ne sais pas si le dossier est remonté jusqu'au service technique. Je peux me renseigner et vous le dire. Ce que je sais, c'est que nous avons déposé une lettre au bureau du quartier en février, et que nous avons le récépissé.",
    commentaire:
      "Deuxième question sans réponse, et la même méthode. Ne jamais inventer : celui qui pose la question connaît souvent la réponse — c'est même parfois pour cela qu'il la pose.",
  },
];

const QUESTION_PUBLIC_VIDE: QuestionPublic = {
  id: "",
  question: "—",
  genre: "simple",
  reformulation: "—",
  modele: "—",
  commentaire: "—",
};

const NOM_GENRE: Record<QuestionPublic["genre"], string> = {
  simple: "question simple",
  attendue: "l'objection attendue",
  agressive: "question agressive",
  horssujet: "question hors sujet",
  dejaposee: "question déjà posée",
  jenesaispas: "tu ne sais pas",
};

export function RepondreQuestions() {
  const [i, setI] = useState(0);
  const [geste, setGeste] = useState(0);
  const [saisie, setSaisie] = useState("");
  const [montre, setMontre] = useState(false);
  const [redoutees, setRedoutees] = useState(["", "", ""]);

  const q = QUESTIONS_PUBLIC[i] ?? QUESTION_PUBLIC_VIDE;

  const attaquePersonne =
    /\btu (es|n'y connais|parles comme|ne comprends)\b|\bvous (n'y connaissez|ne comprenez)\b/i.test(
      saisie,
    );
  const invente =
    q.genre === "jenesaispas" && saisie.length > 20 && !/je ne sais pas|je l'ignore/i.test(saisie);
  const court = saisie.trim().split(/\s+/).length <= 60;

  return (
    <div className="space-y-3">
      <p className="text-sm text-muted-foreground">
        Une présentation peut être apprise. Une réponse ne peut pas — et c'est à tes réponses qu'on
        jugera si tu maîtrises ton sujet.
      </p>

      <div className="rounded-lg border border-border bg-background p-3">
        <p className="text-base italic text-foreground">« {q.question} »</p>
        {geste >= 1 ? (
          <p className="mt-1 text-[11px]" style={{ color: PALETTE.orange }}>
            {NOM_GENRE[q.genre]}
          </p>
        ) : null}

        {geste === 0 ? (
          <div className="mt-3 space-y-2">
            <p className="text-[11px] text-muted-foreground">
              GESTE 1 — écouter jusqu'au bout. La tentation est de répondre dès qu'on a compris le
              début : tu répondrais à une autre question, et cela se voit.
            </p>
            <button
              type="button"
              onClick={() => setGeste(1)}
              className="rounded-lg bg-primary px-3 py-1.5 text-xs font-semibold text-primary-foreground"
            >
              J'ai écouté jusqu'au bout
            </button>
          </div>
        ) : null}

        {geste === 1 ? (
          <div className="mt-3 space-y-2">
            <p className="text-[11px] text-muted-foreground">
              GESTE 2 — reformuler. Cela te donne trois secondes, montre que tu as écouté, et évite
              de répondre à côté.
            </p>
            <p
              className="rounded-md px-2 py-1.5 text-sm italic"
              style={{ backgroundColor: "rgba(37,99,235,0.08)", color: PALETTE.slate }}
            >
              « {q.reformulation} »
            </p>
            <button
              type="button"
              onClick={() => setGeste(2)}
              className="rounded-lg bg-primary px-3 py-1.5 text-xs font-semibold text-primary-foreground"
            >
              Passer à la réponse
            </button>
          </div>
        ) : null}

        {geste >= 2 ? (
          <div className="mt-3 space-y-2">
            <p className="text-[11px] text-muted-foreground">
              GESTE 3 — répondre court, puis développer. GESTE 4 — vérifier : « est-ce que cela
              répond à votre question ? »
            </p>
            <textarea
              value={saisie}
              onChange={(e) => setSaisie(e.target.value)}
              rows={4}
              className="w-full rounded-md border border-border bg-background px-2.5 py-1.5 text-sm text-foreground"
              placeholder="Ta réponse"
            />

            {saisie.trim().length > 10 ? (
              <div className="flex flex-wrap gap-1.5 text-[11px]">
                <span
                  className="rounded px-2 py-0.5"
                  style={{
                    backgroundColor: court ? "rgba(21,128,61,0.12)" : "rgba(185,28,28,0.12)",
                    color: court ? "#14532d" : "#7f1d1d",
                  }}
                >
                  {court
                    ? "longueur tenue"
                    : "trop long — une réponse de trois minutes à une question de dix secondes épuise tout le monde"}
                </span>
                {attaquePersonne ? (
                  <span
                    className="rounded px-2 py-0.5"
                    style={{ backgroundColor: "rgba(185,28,28,0.12)", color: "#7f1d1d" }}
                  >
                    tu réponds à la personne, pas à la question
                  </span>
                ) : null}
                {invente ? (
                  <span
                    className="rounded px-2 py-0.5"
                    style={{ backgroundColor: "rgba(185,28,28,0.12)", color: "#7f1d1d" }}
                  >
                    tu inventes une réponse — ici, tu ne sais pas
                  </span>
                ) : null}
              </div>
            ) : null}

            <div className="flex flex-wrap gap-2">
              <button
                type="button"
                onClick={() => setMontre(true)}
                className="rounded-lg border border-border px-3 py-1.5 text-xs font-semibold text-foreground"
              >
                Voir une réponse possible
              </button>
              <button
                type="button"
                onClick={() => {
                  setI((n) => (n + 1) % QUESTIONS_PUBLIC.length);
                  setGeste(0);
                  setSaisie("");
                  setMontre(false);
                }}
                className="rounded-lg bg-primary px-3 py-1.5 text-xs font-semibold text-primary-foreground"
              >
                Question suivante ({i + 1} / {QUESTIONS_PUBLIC.length})
              </button>
            </div>

            {montre ? (
              <div className="space-y-1.5">
                <Verdict tone="ok">
                  <span className="font-semibold">Une réponse possible. </span>
                  {q.modele}
                </Verdict>
                <p className="text-[11px] italic text-muted-foreground">{q.commentaire}</p>
              </div>
            ) : null}
          </div>
        ) : null}
      </div>

      <div className="rounded-lg border border-border bg-background p-3">
        <p className="text-xs font-semibold text-foreground">
          Les trois questions que tu redoutes sur ton projet
        </p>
        <p className="mt-0.5 text-[11px] text-muted-foreground">
          Écris-les, et prépare les trois réponses. Ce sont celles qui viendront.
        </p>
        {redoutees.map((r, k) => (
          <input
            key={`rd${k}`}
            value={r}
            onChange={(e) => setRedoutees((x) => x.map((y, j) => (j === k ? e.target.value : y)))}
            placeholder={`question redoutée ${k + 1}`}
            className="mt-1.5 w-full rounded-md border border-border bg-background px-2.5 py-1.5 text-sm text-foreground"
          />
        ))}
        {redoutees.every((r) => r.trim().length > 5) ? (
          <div className="mt-2">
            <Verdict tone="ok">
              <span className="font-semibold">Les voilà nommées. </span>
              Il y a toujours une question qu'on redoute, et c'est celle de l'objection principale.
              Si tu présentes un composteur, quelqu'un demandera si ça sent mauvais. Si tu présentes
              un projet, quelqu'un demandera qui paie.
            </Verdict>
          </div>
        ) : null}
      </div>

      <Citation auteur="ce qu'il ne faut jamais faire">
        Couper celui qui pose la question. Répondre à la personne au lieu de répondre à la question.
        S'énerver — celui qui s'énerve a perdu, même s'il a raison. Et parler trop longtemps.
      </Citation>
    </div>
  );
}
