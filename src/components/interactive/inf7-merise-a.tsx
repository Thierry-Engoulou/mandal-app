import { useState } from "react";
import { Choice, PALETTE, Panel, Stat, Verdict } from "./controls";
import { JeuClassement } from "./info1-jeux";

/** Informatique Terminale C et D — chapitres 12 et 13 : conception et MCD. */

/* ------------------------------------------------------------------ */
/* Chapitre 12 — Décomposer une organisation                           */
/* ------------------------------------------------------------------ */

const ORGANISATIONS = [
  {
    id: "lycee",
    titre: "Un lycée de Yaoundé",
    texte:
      "Chaque élève porte un matricule, un nom et une date de naissance. Il est inscrit dans une classe, qui a un code et un niveau. Un professeur, identifié par son matricule, enseigne plusieurs matières dans plusieurs classes, avec un nombre d'heures par semaine pour chaque affectation.",
    mots: [
      { mot: "élève", bonne: "entite" },
      { mot: "matricule", bonne: "propriete" },
      { mot: "date de naissance", bonne: "propriete" },
      { mot: "est inscrit dans", bonne: "relation" },
      { mot: "classe", bonne: "entite" },
      { mot: "niveau", bonne: "propriete" },
      { mot: "professeur", bonne: "entite" },
      { mot: "enseigne", bonne: "relation" },
      { mot: "nombre d'heures par semaine", bonne: "proprelation" },
    ],
    bon: "ELEVE, CLASSE, PROFESSEUR, MATIERE comme entités ; « est inscrit dans » et « enseigne » comme associations ; le nombre d'heures porté par l'association ENSEIGNE, puisqu'il ne dépend ni du seul professeur ni de la seule classe.",
    bancal:
      "Une seule entité ELEVE avec des colonnes classe1, classe2, matiere1, matiere2… On y perd l'unicité, on ne sait plus combien de colonnes prévoir, et toute recherche devient impossible.",
  },
  {
    id: "pharma",
    titre: "Une pharmacie de quartier",
    texte:
      "Chaque médicament a une référence, un nom et un prix unitaire. Un fournisseur, identifié par un code, livre plusieurs médicaments, et chaque livraison porte une date et une quantité livrée. Un client peut acheter plusieurs médicaments.",
    mots: [
      { mot: "médicament", bonne: "entite" },
      { mot: "référence", bonne: "propriete" },
      { mot: "prix unitaire", bonne: "propriete" },
      { mot: "fournisseur", bonne: "entite" },
      { mot: "livre", bonne: "relation" },
      { mot: "quantité livrée", bonne: "proprelation" },
      { mot: "date de livraison", bonne: "proprelation" },
      { mot: "client", bonne: "entite" },
      { mot: "achète", bonne: "relation" },
    ],
    bon: "MEDICAMENT, FOURNISSEUR, CLIENT comme entités ; LIVRER et ACHETER comme associations ; la date et la quantité portées par LIVRER, puisqu'elles ne prennent sens qu'au croisement d'un fournisseur et d'un médicament.",
    bancal:
      "Mettre la quantité livrée dans MEDICAMENT. Un médicament livré par trois fournisseurs à trois dates différentes aurait alors trois quantités dans une seule case.",
  },
  {
    id: "loc",
    titre: "Une agence de location de véhicules à Douala",
    texte:
      "Chaque véhicule a une immatriculation, une marque et un tarif journalier. Un client a un numéro de permis, un nom et un téléphone. Un client loue un véhicule à partir d'une date, pour un nombre de jours donné.",
    mots: [
      { mot: "véhicule", bonne: "entite" },
      { mot: "immatriculation", bonne: "propriete" },
      { mot: "tarif journalier", bonne: "propriete" },
      { mot: "client", bonne: "entite" },
      { mot: "numéro de permis", bonne: "propriete" },
      { mot: "loue", bonne: "relation" },
      { mot: "date de début", bonne: "proprelation" },
      { mot: "nombre de jours", bonne: "proprelation" },
    ],
    bon: "VEHICULE et CLIENT comme entités ; LOUER comme association ; la date et la durée portées par LOUER. Le montant total ne figure nulle part : il se calcule, tarif journalier × nombre de jours.",
    bancal:
      "Créer une entité LOCATION sans identifiant propre, ou stocker le montant total. Un montant stocké finit par contredire le tarif le jour où celui-ci change.",
  },
] as const;

const COLONNES = [
  { value: "entite", label: "Entité" },
  { value: "propriete", label: "Propriété d'entité" },
  { value: "relation", label: "Relation" },
  { value: "proprelation", label: "Propriété de relation" },
] as const;

export function DecomposerSysteme() {
  const [k, setK] = useState(0);
  const [place, setPlace] = useState<Record<string, string>>({});
  const [compare, setCompare] = useState(false);

  const o = ORGANISATIONS[k] ?? ORGANISATIONS[0];
  const bons = o.mots.filter((m) => place[m.mot] === m.bonne).length;

  return (
    <div className="space-y-3">
      <div className="flex flex-wrap gap-1.5">
        {ORGANISATIONS.map((x, i) => (
          <button
            key={x.id}
            type="button"
            onClick={() => {
              setK(i);
              setPlace({});
              setCompare(false);
            }}
            className={
              i === k
                ? "rounded-lg bg-primary px-2.5 py-1.5 text-xs font-semibold text-primary-foreground"
                : "rounded-lg border border-border bg-background px-2.5 py-1.5 text-xs font-medium text-muted-foreground hover:bg-secondary/60"
            }
          >
            {x.titre}
          </button>
        ))}
      </div>

      <div className="rounded-lg border border-border bg-secondary/30 px-3 py-2.5">
        <p className="text-xs leading-relaxed">{o.texte}</p>
      </div>

      <div className="space-y-2">
        {o.mots.map((m) => {
          const p = place[m.mot];
          const juste = p === m.bonne;
          return (
            <div key={m.mot} className="space-y-1">
              <p className="text-xs font-medium">
                « <span className="font-semibold">{m.mot}</span> »
              </p>
              <div className="flex flex-wrap gap-1">
                {COLONNES.map((c) => {
                  const actif = p === c.value;
                  const cls = !actif
                    ? "border-border bg-background text-muted-foreground hover:bg-secondary/60"
                    : juste
                      ? "border-emerald-500/50 bg-emerald-500/10 text-emerald-700"
                      : "border-rose-500/50 bg-rose-500/10 text-rose-700";
                  return (
                    <button
                      key={c.value}
                      type="button"
                      onClick={() => setPlace({ ...place, [m.mot]: c.value })}
                      className={`rounded-lg border px-2 py-1 text-[11px] font-medium ${cls}`}
                    >
                      {c.label}
                    </button>
                  );
                })}
              </div>
            </div>
          );
        })}
      </div>

      <Panel>
        <Stat label="Bien placés" value={`${bons} / ${o.mots.length}`} />
        <Stat
          label="Le repère"
          value="nom = entité, verbe = relation"
          color={bons === o.mots.length ? PALETTE.green : PALETTE.ink}
        />
      </Panel>

      {bons === o.mots.length ? (
        <Verdict tone="ok">
          Décomposition complète. Deux repères à garder : un <strong>nom</strong> désigne une entité
          ou une propriété, un <strong>verbe</strong> désigne une relation. Et une donnée qui ne
          prend sens <strong>qu&apos;au croisement de deux entités</strong> — une quantité livrée,
          un nombre d&apos;heures — est une propriété de la relation, pas de l&apos;une des deux
          entités.
        </Verdict>
      ) : (
        <Verdict tone="warn">
          Pour chaque mot, demande-toi : est-ce une chose dont je veux conserver plusieurs
          exemplaires — une entité ? un renseignement sur cette chose — une propriété ? un lien
          entre deux choses — une relation ? ou un renseignement sur le lien lui-même ?
        </Verdict>
      )}

      <button
        type="button"
        onClick={() => setCompare((v) => !v)}
        className="rounded-lg border border-border bg-background px-3 py-1.5 text-xs font-medium text-muted-foreground hover:bg-secondary/60"
      >
        {compare ? "Masquer" : "Comparer deux décompositions du même système"}
      </button>

      {compare ? (
        <div className="grid gap-2 sm:grid-cols-2">
          <div className="rounded-lg border-2 border-emerald-500/50 bg-emerald-500/5 p-2.5">
            <p className="text-xs font-semibold text-emerald-700">La décomposition qui tient</p>
            <p className="mt-1 text-[11px] text-muted-foreground">{o.bon}</p>
          </div>
          <div className="rounded-lg border-2 border-rose-500/50 bg-rose-500/5 p-2.5">
            <p className="text-xs font-semibold text-rose-700">La décomposition bancale</p>
            <p className="mt-1 text-[11px] text-muted-foreground">{o.bancal}</p>
          </div>
        </div>
      ) : null}
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Chapitre 12 — Les trois niveaux de MERISE                           */
/* ------------------------------------------------------------------ */

const MODELES = [
  { niveau: "Conceptuel", donnees: "MCD", traitements: "MCT", question: "QUOI" },
  {
    niveau: "Organisationnel / logique",
    donnees: "MLD",
    traitements: "MOT",
    question: "QUI, OÙ, QUAND",
  },
  { niveau: "Physique", donnees: "MPD", traitements: "MOpT", question: "COMMENT" },
] as const;

export function NiveauxMerise() {
  return (
    <div className="space-y-3">
      <JeuClassement
        aide="La question qui tranche : « quoi ? » pour le conceptuel, « qui, où, quand ? » pour le logique, « comment, avec quel outil ? » pour le physique."
        libelleChoix="Niveau MERISE"
        options={[
          { value: "cpt", label: "Conceptuel" },
          { value: "log", label: "Logique" },
          { value: "phy", label: "Physique" },
        ]}
        cas={[
          {
            enonce: "« Un élève appartient à une seule classe. »",
            bonne: "cpt",
            pourquoi:
              "C'est une règle de gestion : elle dit ce qui est vrai dans l'organisation, indépendamment de tout outil. Niveau conceptuel.",
          },
          {
            enonce: "« Quel est l'identifiant d'un élève ? »",
            bonne: "cpt",
            pourquoi:
              "Choisir l'identifiant est un acte conceptuel : on décide ce qui distingue deux élèves dans le réel.",
          },
          {
            enonce: "« La saisie des notes se fera au secrétariat, le lundi matin. »",
            bonne: "log",
            pourquoi:
              "Qui fait quoi, où et quand : c'est exactement le niveau organisationnel, celui du MOT.",
          },
          {
            enonce: "« On utilisera MySQL. »",
            bonne: "phy",
            pourquoi: "Le choix du SGBD est un choix physique : il répond à « avec quel outil ».",
          },
          {
            enonce: "« La table ELEVE aura une colonne NumClasse qui référence CLASSE. »",
            bonne: "log",
            pourquoi:
              "Tables, colonnes, clés étrangères : c'est le MLD, la traduction du MCD en structure relationnelle.",
          },
          {
            enonce: "« On posera un index sur la colonne Nom pour accélérer les recherches. »",
            bonne: "phy",
            pourquoi:
              "Un index est une optimisation du stockage : rien de conceptuel, tout de physique.",
          },
          {
            enonce: "« Un professeur peut enseigner plusieurs matières. »",
            bonne: "cpt",
            pourquoi: "Encore une règle de gestion, qui fixera une cardinalité dans le MCD.",
          },
          {
            enonce: "« Le champ Matricule sera un VARCHAR(10). »",
            bonne: "phy",
            pourquoi:
              "Le type et la taille exacts dépendent du SGBD : c'est du MPD. Au niveau logique, on disait seulement « une chaîne de caractères ».",
          },
          {
            enonce: "« Le bulletin sera édité par le censeur à la fin de chaque trimestre. »",
            bonne: "log",
            pourquoi: "Qui, quand : organisationnel.",
          },
          {
            enonce: "« Deux élèves ne peuvent pas porter le même matricule. »",
            bonne: "cpt",
            pourquoi:
              "C'est la définition même d'un identifiant, et donc du conceptuel. Sa mise en œuvre par une contrainte PRIMARY KEY, elle, sera physique.",
          },
          {
            enonce: "« La base sera sauvegardée chaque nuit sur un disque externe. »",
            bonne: "phy",
            pourquoi: "Une décision d'exploitation, liée au matériel : physique.",
          },
          {
            enonce: "« L'association ENSEIGNER portera le nombre d'heures. »",
            bonne: "cpt",
            pourquoi:
              "Décider qu'une propriété appartient à l'association relève du MCD, donc du conceptuel.",
          },
        ]}
      />

      <div className="overflow-x-auto">
        <table className="w-full border-collapse text-xs">
          <thead>
            <tr>
              <th className="border border-border bg-secondary/40 px-2 py-1 text-left font-medium">
                Niveau
              </th>
              <th className="border border-border bg-secondary/40 px-2 py-1 font-medium">
                Données
              </th>
              <th className="border border-border bg-secondary/40 px-2 py-1 font-medium">
                Traitements
              </th>
              <th className="border border-border bg-secondary/40 px-2 py-1 font-medium">
                La question
              </th>
            </tr>
          </thead>
          <tbody>
            {MODELES.map((m) => (
              <tr key={m.niveau}>
                <td className="border border-border px-2 py-1 font-medium">{m.niveau}</td>
                <td className="border border-border px-2 py-1 text-center font-mono font-semibold">
                  {m.donnees}
                </td>
                <td className="border border-border px-2 py-1 text-center font-mono font-semibold">
                  {m.traitements}
                </td>
                <td className="border border-border px-2 py-1 text-center font-semibold">
                  {m.question}
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
      <p className="text-[11px] text-muted-foreground">
        Six modèles, trois niveaux, deux colonnes : les <strong>données</strong> d&apos;un côté, les{" "}
        <strong>traitements</strong> de l&apos;autre. C&apos;est le tableau à savoir redessiner de
        mémoire.
      </p>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Chapitre 12 — Surligner les règles de gestion                       */
/* ------------------------------------------------------------------ */

const ENONCE_RG = [
  {
    id: "rg1",
    texte:
      "RG1 : Un élève est identifié par un matricule unique, et possède un nom, un prénom et une date de naissance.",
    mots: [
      { m: "élève", r: "entite" },
      { m: "matricule", r: "identifiant" },
      { m: "unique", r: "identifiant" },
      { m: "nom", r: "propriete" },
      { m: "prénom", r: "propriete" },
      { m: "date de naissance", r: "propriete" },
    ],
  },
  {
    id: "rg2",
    texte:
      "RG2 : Une classe est identifiée par un code, et porte un libellé et un effectif maximal.",
    mots: [
      { m: "classe", r: "entite" },
      { m: "code", r: "identifiant" },
      { m: "libellé", r: "propriete" },
      { m: "effectif maximal", r: "propriete" },
    ],
  },
  {
    id: "rg3",
    texte:
      "RG3 : Un élève est inscrit dans une seule classe. Une classe accueille plusieurs élèves.",
    mots: [
      { m: "est inscrit dans", r: "association" },
      { m: "une seule", r: "cardinalite" },
      { m: "plusieurs", r: "cardinalite" },
    ],
  },
  {
    id: "rg4",
    texte:
      "RG4 : Un élève participe à plusieurs sorties, et une sortie reçoit plusieurs élèves. On note pour chaque participation le montant versé.",
    mots: [
      { m: "sortie", r: "entite" },
      { m: "participe", r: "association" },
      { m: "plusieurs", r: "cardinalite" },
      { m: "montant versé", r: "proprietassoc" },
    ],
  },
] as const;

const ROLES = [
  { value: "entite", label: "Entité", couleur: "#2563eb" },
  { value: "propriete", label: "Propriété", couleur: "#15803d" },
  { value: "identifiant", label: "Identifiant", couleur: "#b91c1c" },
  { value: "association", label: "Association", couleur: "#ca8a04" },
  { value: "cardinalite", label: "Cardinalité", couleur: "#7c3aed" },
  { value: "proprietassoc", label: "Propriété d'association", couleur: "#0891b2" },
] as const;

export function ReglesGestion() {
  const [role, setRole] = useState<string>("entite");
  const [marque, setMarque] = useState<Record<string, string>>({});

  const tous = ENONCE_RG.flatMap((r) => r.mots.map((m) => ({ ...m, rg: r.id })));
  const bons = tous.filter((x) => marque[`${x.rg}-${x.m}`] === x.r).length;

  const entites = tous.filter((x) => x.r === "entite" && marque[`${x.rg}-${x.m}`] === "entite");
  const props = tous.filter((x) => x.r === "propriete" && marque[`${x.rg}-${x.m}`] === "propriete");
  const ids = tous.filter(
    (x) => x.r === "identifiant" && marque[`${x.rg}-${x.m}`] === "identifiant",
  );
  const assos = tous.filter(
    (x) => x.r === "association" && marque[`${x.rg}-${x.m}`] === "association",
  );

  const complet = bons === tous.length;

  return (
    <div className="space-y-3">
      <Choice<string>
        label="Surligneur"
        value={role}
        options={ROLES.map((r) => ({ value: r.value, label: r.label }))}
        onChange={setRole}
      />

      <div className="space-y-2">
        {ENONCE_RG.map((r) => (
          <div key={r.id} className="rounded-lg border border-border bg-background p-2.5">
            <p className="mb-1.5 text-[11px] leading-relaxed text-muted-foreground">{r.texte}</p>
            <div className="flex flex-wrap gap-1">
              {r.mots.map((m) => {
                const cle = `${r.id}-${m.m}`;
                const pose = marque[cle];
                const juste = pose === m.r;
                const col = ROLES.find((x) => x.value === pose)?.couleur;
                return (
                  <button
                    key={cle}
                    type="button"
                    onClick={() => setMarque({ ...marque, [cle]: role })}
                    className="rounded border px-1.5 py-0.5 text-[11px] font-medium"
                    style={
                      pose
                        ? {
                            borderColor: col,
                            background: `${col}22`,
                            color: juste ? col : "#b91c1c",
                            textDecoration: juste ? "none" : "line-through",
                          }
                        : undefined
                    }
                  >
                    {m.m}
                  </button>
                );
              })}
            </div>
          </div>
        ))}
      </div>

      <Panel>
        <Stat label="Mots bien qualifiés" value={`${bons} / ${tous.length}`} />
        <Stat label="Entités repérées" value={`${entites.length}`} color={PALETTE.blue} />
      </Panel>

      <div className="space-y-1 rounded-lg border border-border bg-background p-3">
        <p className="text-xs font-semibold">Ce que tes surlignages construisent</p>
        <p className="text-[11px] text-muted-foreground">
          <span className="font-semibold text-foreground">Entités : </span>
          {entites.length > 0 ? entites.map((x) => x.m.toUpperCase()).join(", ") : "—"}
        </p>
        <p className="text-[11px] text-muted-foreground">
          <span className="font-semibold text-foreground">Identifiants : </span>
          {ids.length > 0 ? ids.map((x) => x.m).join(", ") : "—"}
        </p>
        <p className="text-[11px] text-muted-foreground">
          <span className="font-semibold text-foreground">Propriétés : </span>
          {props.length > 0 ? props.map((x) => x.m).join(", ") : "—"}
        </p>
        <p className="text-[11px] text-muted-foreground">
          <span className="font-semibold text-foreground">Associations : </span>
          {assos.length > 0 ? assos.map((x) => x.m).join(", ") : "—"}
        </p>
      </div>

      {complet ? (
        <>
          <Verdict tone="ok">
            Tout est repéré. Voilà la méthode à appliquer sur n&apos;importe quel énoncé : les{" "}
            <strong>noms</strong> deviennent des entités ou des propriétés, les{" "}
            <strong>verbes</strong> des associations, le mot <strong>« unique »</strong> désigne
            l&apos;identifiant, et les mots <strong>« un seul »</strong> ou{" "}
            <strong>« plusieurs »</strong> donnent les cardinalités.
          </Verdict>
          <div className="rounded-lg border border-border bg-secondary/20 p-3">
            <p className="mb-1 text-xs font-semibold">Le MCD que ces quatre règles imposent</p>
            <pre className="overflow-x-auto font-mono text-[10px] leading-relaxed text-muted-foreground">
              {`ELEVE                       CLASSE
  Matricule (id)              Code (id)
  Nom                         Libelle
  Prenom                      EffectifMax
  DateNaissance

  ELEVE (1,1) ── INSCRIRE ── (1,n) CLASSE

SORTIE
  CodeSortie (id)
  Libelle
  DateSortie

  ELEVE (0,n) ── PARTICIPER ── (1,n) SORTIE
                      MontantVerse`}
            </pre>
            <p className="mt-1.5 text-[11px] text-muted-foreground">
              Remarque les deux formes : INSCRIRE est en <strong>(1,1) / (1,n)</strong> et sa clé
              migrera, PARTICIPER est en <strong>plusieurs à plusieurs</strong> et donnera une table
              à part, qui portera le montant versé.
            </p>
          </div>
        </>
      ) : (
        <Verdict tone="warn">
          Choisis un surligneur, puis clique les mots qui lui correspondent. Les mots barrés sont
          ceux que tu as mal qualifiés : reprends-les avec le bon surligneur.
        </Verdict>
      )}
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Chapitre 13 — Construire une entité                                */
/* ------------------------------------------------------------------ */

const SUJETS_ENTITE = [
  {
    id: "eleve",
    enonce:
      "Le lycée veut conserver, pour chaque élève, de quoi l'identifier sans ambiguïté, son état civil et son adresse.",
    nomBon: "ELEVE",
    noms: ["ELEVE", "ELEVES", "Les élèves", "eleve_table"],
    props: [
      { p: "Matricule", bonne: true, id: true, note: "Unique et stable : l'identifiant idéal." },
      { p: "Nom", bonne: true, id: false, note: "Une propriété, jamais un identifiant." },
      { p: "Prenom", bonne: true, id: false, note: "" },
      { p: "DateNaissance", bonne: true, id: false, note: "" },
      {
        p: "Adresse complète (quartier, rue, ville)",
        bonne: false,
        id: false,
        note: "Non atomique : trois informations dans une case. Il faut Quartier, Rue et Ville séparément — sans quoi on ne pourra jamais chercher tous les élèves d'une ville.",
      },
      {
        p: "Age",
        bonne: false,
        id: false,
        note: "Calculable depuis la date de naissance, et faux dès le lendemain de l'anniversaire. On ne stocke jamais ce qui se calcule.",
      },
      {
        p: "NomDuProfesseurPrincipal",
        bonne: false,
        id: false,
        note: "Cela appartient à une autre entité. Le lien se fera par une association, pas par une colonne recopiée.",
      },
    ],
  },
  {
    id: "article",
    enonce:
      "Une quincaillerie veut gérer ses articles : les reconnaître, les nommer, connaître leur prix et leur stock.",
    nomBon: "ARTICLE",
    noms: ["ARTICLE", "ARTICLES", "Stock", "art"],
    props: [
      {
        p: "Reference",
        bonne: true,
        id: true,
        note: "Code unique attribué par la maison : parfait identifiant.",
      },
      { p: "Designation", bonne: true, id: false, note: "" },
      { p: "PrixUnitaire", bonne: true, id: false, note: "" },
      { p: "QuantiteStock", bonne: true, id: false, note: "" },
      {
        p: "ValeurDuStock",
        bonne: false,
        id: false,
        note: "Prix unitaire × quantité : calculable. La stocker, c'est se condamner à deux chiffres qui finiront par se contredire.",
      },
      {
        p: "NomEtAdresseDuFournisseur",
        bonne: false,
        id: false,
        note: "Non atomique, et appartenant à une autre entité : deux défauts d'un coup.",
      },
    ],
  },
] as const;

export function EntitePropriete() {
  const [k, setK] = useState(0);
  const [nom, setNom] = useState<string | null>(null);
  const [choisies, setChoisies] = useState<string[]>([]);
  const [identifiant, setIdentifiant] = useState<string | null>(null);
  const [valide, setValide] = useState(false);

  const s = SUJETS_ENTITE[k] ?? SUJETS_ENTITE[0];
  const idAttendu = s.props.find((p) => p.id)?.p ?? "";

  const mauvaises = choisies.filter((c) => !s.props.find((p) => p.p === c)?.bonne);
  const manquantes = s.props.filter((p) => p.bonne && !choisies.includes(p.p));
  const nomOk = nom === s.nomBon;
  const idOk = identifiant === idAttendu;
  const parfait = nomOk && idOk && mauvaises.length === 0 && manquantes.length === 0;

  return (
    <div className="space-y-3">
      <div className="flex flex-wrap gap-1.5">
        {SUJETS_ENTITE.map((x, i) => (
          <button
            key={x.id}
            type="button"
            onClick={() => {
              setK(i);
              setNom(null);
              setChoisies([]);
              setIdentifiant(null);
              setValide(false);
            }}
            className={
              i === k
                ? "rounded-lg bg-primary px-2.5 py-1.5 text-xs font-semibold text-primary-foreground"
                : "rounded-lg border border-border bg-background px-2.5 py-1.5 text-xs font-medium text-muted-foreground hover:bg-secondary/60"
            }
          >
            {x.nomBon}
          </button>
        ))}
      </div>

      <div className="rounded-lg border border-border bg-secondary/30 px-3 py-2.5">
        <p className="text-xs">{s.enonce}</p>
      </div>

      <Choice<string>
        label="1. Nomme l'entité"
        value={nom ?? ""}
        options={s.noms.map((n) => ({ value: n, label: n }))}
        onChange={setNom}
      />
      {nom !== null && !nomOk ? (
        <p className="text-[11px] text-rose-600">
          Par convention, une entité se nomme au <strong>singulier</strong>, en{" "}
          <strong>majuscules</strong>, sans article et sans abréviation obscure : {s.nomBon}.
        </p>
      ) : null}

      <div className="space-y-1">
        <p className="text-xs font-medium text-muted-foreground">2. Choisis ses propriétés</p>
        <div className="grid gap-1.5 sm:grid-cols-2">
          {s.props.map((p) => {
            const actif = choisies.includes(p.p);
            const cls = !valide
              ? actif
                ? "border-primary bg-primary/10 text-foreground"
                : "border-border bg-background text-muted-foreground"
              : p.bonne
                ? "border-emerald-500/50 bg-emerald-500/10 text-emerald-700"
                : actif
                  ? "border-rose-500/50 bg-rose-500/10 text-rose-700"
                  : "border-border bg-background text-muted-foreground";
            return (
              <button
                key={p.p}
                type="button"
                onClick={() =>
                  setChoisies((v) => (v.includes(p.p) ? v.filter((x) => x !== p.p) : [...v, p.p]))
                }
                className={`rounded-lg border px-2 py-1.5 text-left text-[11px] font-medium ${cls}`}
              >
                {p.p}
              </button>
            );
          })}
        </div>
      </div>

      <Choice<string>
        label="3. Désigne l'identifiant"
        value={identifiant ?? ""}
        options={choisies.map((c) => ({ value: c, label: c }))}
        onChange={setIdentifiant}
      />

      <button
        type="button"
        onClick={() => setValide(true)}
        className="rounded-lg bg-primary px-3 py-1.5 text-xs font-semibold text-primary-foreground"
      >
        Valider l&apos;entité
      </button>

      {!valide ? (
        <Verdict tone="warn">
          Trois étapes : le nom, les propriétés, l&apos;identifiant. Méfie-toi des propriétés qui
          contiennent plusieurs informations, et de celles qui se calculent.
        </Verdict>
      ) : identifiant === null ? (
        <Verdict tone="bad">
          Entité refusée : <strong>aucun identifiant désigné</strong>. Une entité sans identifiant
          n&apos;est pas une entité — rien ne permettrait de distinguer deux occurrences, et la clé
          primaire de la future table n&apos;existerait pas.
        </Verdict>
      ) : identifiant === "Nom" ? (
        <div className="space-y-2">
          <Verdict tone="bad">
            Le <strong>nom</strong> ne peut pas être un identifiant. Regarde ces deux élèves :
          </Verdict>
          <div className="overflow-x-auto">
            <table className="w-full border-collapse text-[11px]">
              <thead>
                <tr>
                  <th className="border border-border bg-secondary/40 px-2 py-1">Nom</th>
                  <th className="border border-border bg-secondary/40 px-2 py-1">Prénom</th>
                  <th className="border border-border bg-secondary/40 px-2 py-1">Né le</th>
                </tr>
              </thead>
              <tbody>
                <tr>
                  <td className="border border-border px-2 py-1 font-mono">MBIDA</td>
                  <td className="border border-border px-2 py-1">Jean</td>
                  <td className="border border-border px-2 py-1">12/03/2007</td>
                </tr>
                <tr>
                  <td className="border border-border px-2 py-1 font-mono">MBIDA</td>
                  <td className="border border-border px-2 py-1">Jean</td>
                  <td className="border border-border px-2 py-1">04/09/2008</td>
                </tr>
              </tbody>
            </table>
          </div>
          <p className="text-[11px] text-muted-foreground">
            Deux élèves différents, même nom et même prénom. C&apos;est fréquent, et c&apos;est
            pourquoi tout établissement attribue un <strong>matricule</strong>.
          </p>
        </div>
      ) : parfait ? (
        <Verdict tone="ok">
          Entité correcte : nom au singulier en majuscules, propriétés <strong>atomiques</strong> et{" "}
          <strong>non calculables</strong>, et un identifiant <strong>unique et stable</strong>. Tu
          peux la dessiner dans un MCD.
        </Verdict>
      ) : (
        <div className="space-y-1.5">
          {mauvaises.length > 0 ? (
            <div className="space-y-1 rounded-lg border border-rose-500/40 bg-rose-500/5 p-2.5">
              {mauvaises.map((mm) => (
                <p key={mm} className="text-[11px] text-rose-700">
                  <span className="font-semibold">{mm} — </span>
                  {s.props.find((p) => p.p === mm)?.note ?? ""}
                </p>
              ))}
            </div>
          ) : null}
          {manquantes.length > 0 ? (
            <Verdict tone="warn">Il manque {manquantes.map((p) => p.p).join(", ")}.</Verdict>
          ) : null}
          {!idOk && identifiant !== null && identifiant !== "Nom" ? (
            <Verdict tone="bad">
              {identifiant} ne peut pas identifier une occurrence de façon sûre. L&apos;identifiant
              attendu est <strong>{idAttendu}</strong>.
            </Verdict>
          ) : null}
        </div>
      )}
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Chapitre 13 — Les cardinalités                                      */
/* ------------------------------------------------------------------ */

const COUPLES = ["(0,1)", "(1,1)", "(0,n)", "(1,n)"] as const;

const CAS_CARD = [
  {
    id: "c1",
    e1: "ELEVE",
    e2: "CLASSE",
    asso: "EST INSCRIT DANS",
    q1: "Un élève est-il inscrit dans au moins une classe ? Et dans combien au maximum ?",
    q2: "Une classe accueille-t-elle au moins un élève ? Et combien au maximum ?",
    c1: "(1,1)",
    c2: "(1,n)",
    sens: "Côté ELEVE, (1,1) : tout élève est inscrit, et dans une seule classe. Côté CLASSE, (1,n) : une classe existante a au moins un élève, et peut en avoir beaucoup.",
    migration:
      "Un côté en (1,1) : la clé de CLASSE migrera dans la table ELEVE. Pas de table d'association.",
  },
  {
    id: "c2",
    e1: "ELEVE",
    e2: "SORTIE",
    asso: "PARTICIPER",
    q1: "Un élève participe-t-il forcément à une sortie ? À combien au maximum ?",
    q2: "Une sortie reçoit-elle au moins un élève ? Combien au maximum ?",
    c1: "(0,n)",
    c2: "(1,n)",
    sens: "Côté ELEVE, (0,n) : un élève peut ne participer à aucune sortie, ou à plusieurs. Côté SORTIE, (1,n) : une sortie organisée a au moins un participant.",
    migration:
      "Les deux maximums sont à n : c'est une association plusieurs à plusieurs. Elle donnera une table PARTICIPER avec une clé primaire composée des deux clés.",
  },
  {
    id: "c3",
    e1: "PROFESSEUR",
    e2: "CLASSE",
    asso: "EST PROFESSEUR PRINCIPAL DE",
    q1: "Un professeur est-il principal d'au moins une classe ? De combien au maximum ?",
    q2: "Une classe a-t-elle au moins un professeur principal ? Combien au maximum ?",
    c1: "(0,1)",
    c2: "(1,1)",
    sens: "Côté PROFESSEUR, (0,1) : beaucoup de professeurs ne sont principaux de personne, et aucun ne l'est de deux classes. Côté CLASSE, (1,1) : chaque classe en a un, et un seul.",
    migration:
      "Un à un : la clé migre du côté obligatoire vers le côté optionnel. On met le matricule du professeur dans CLASSE, et non l'inverse — sinon la colonne serait vide pour presque tous les professeurs.",
  },
] as const;

export function Cardinalites() {
  const [k, setK] = useState(0);
  const [r1, setR1] = useState<string | null>(null);
  const [r2, setR2] = useState<string | null>(null);

  const c = CAS_CARD[k] ?? CAS_CARD[0];
  const ok1 = r1 === c.c1;
  const ok2 = r2 === c.c2;
  const complet = ok1 && ok2;

  const occurrences = (card: string | null, cote: string) => {
    if (card === null) return "";
    if (card === "(1,1)")
      return `Chaque ${cote} est lié à exactement un partenaire. Ni zéro, ni deux.`;
    if (card === "(0,1)") return `Un ${cote} peut n'être lié à personne, mais jamais à deux.`;
    if (card === "(1,n)")
      return `Chaque ${cote} est lié à au moins un partenaire, parfois beaucoup.`;
    return `Un ${cote} peut n'être lié à personne, ou à plusieurs.`;
  };

  return (
    <div className="space-y-3">
      <div className="flex flex-wrap gap-1.5">
        {CAS_CARD.map((x, i) => (
          <button
            key={x.id}
            type="button"
            onClick={() => {
              setK(i);
              setR1(null);
              setR2(null);
            }}
            className={
              i === k
                ? "rounded-lg bg-primary px-2.5 py-1.5 text-xs font-semibold text-primary-foreground"
                : "rounded-lg border border-border bg-background px-2.5 py-1.5 text-xs font-medium text-muted-foreground hover:bg-secondary/60"
            }
          >
            {x.asso}
          </button>
        ))}
      </div>

      {/* Le MCD */}
      <div className="flex flex-wrap items-center justify-center gap-2 rounded-lg border border-border bg-background p-3">
        <div className="rounded-lg border-2 border-blue-500 bg-blue-500/10 px-3 py-2 text-center">
          <p className="text-xs font-bold">{c.e1}</p>
        </div>
        <span
          className="font-mono text-xs font-bold"
          style={{ color: r1 === null ? PALETTE.slate : ok1 ? PALETTE.green : PALETTE.red }}
        >
          {r1 ?? "( , )"}
        </span>
        <span className="text-muted-foreground">—</span>
        <div className="rounded-lg border-2 border-amber-500 bg-amber-500/10 px-3 py-2 text-center">
          <p className="text-[11px] font-bold">{c.asso}</p>
        </div>
        <span className="text-muted-foreground">—</span>
        <span
          className="font-mono text-xs font-bold"
          style={{ color: r2 === null ? PALETTE.slate : ok2 ? PALETTE.green : PALETTE.red }}
        >
          {r2 ?? "( , )"}
        </span>
        <div className="rounded-lg border-2 border-blue-500 bg-blue-500/10 px-3 py-2 text-center">
          <p className="text-xs font-bold">{c.e2}</p>
        </div>
      </div>

      <div className="space-y-2">
        <div className="space-y-1">
          <p className="text-[11px] text-muted-foreground">{c.q1}</p>
          <Choice<string>
            label={`Cardinalité côté ${c.e1}`}
            value={r1 ?? ""}
            options={COUPLES.map((x) => ({ value: x, label: x }))}
            onChange={setR1}
          />
          {r1 ? <p className="text-[11px] text-muted-foreground">{occurrences(r1, c.e1)}</p> : null}
        </div>
        <div className="space-y-1">
          <p className="text-[11px] text-muted-foreground">{c.q2}</p>
          <Choice<string>
            label={`Cardinalité côté ${c.e2}`}
            value={r2 ?? ""}
            options={COUPLES.map((x) => ({ value: x, label: x }))}
            onChange={setR2}
          />
          {r2 ? <p className="text-[11px] text-muted-foreground">{occurrences(r2, c.e2)}</p> : null}
        </div>
      </div>

      <Panel>
        <Stat label="Couples autorisés" value="(0,1) (1,1) (0,n) (1,n)" />
        <Stat
          label="Les deux côtés"
          value={complet ? "justes" : `${(ok1 ? 1 : 0) + (ok2 ? 1 : 0)} / 2`}
          color={complet ? PALETTE.green : PALETTE.ink}
        />
      </Panel>

      {r1 === null || r2 === null ? (
        <Verdict tone="warn">
          Deux questions, toujours dans le même ordre. <strong>Le minimum</strong> : est-ce
          obligatoire — 1 — ou facultatif — 0 ? <strong>Le maximum</strong> : un seul — 1 — ou
          plusieurs — n ? Il n&apos;existe que quatre couples, et ni (n,1) ni (n,n) n&apos;en font
          partie.
        </Verdict>
      ) : complet ? (
        <>
          <Verdict tone="ok">{c.sens}</Verdict>
          <div className="rounded-lg border border-border bg-secondary/20 p-2.5">
            <p className="text-xs font-semibold">Ce que cela donnera au MLD</p>
            <p className="mt-0.5 text-[11px] text-muted-foreground">{c.migration}</p>
          </div>
        </>
      ) : (
        <Verdict tone="bad">
          Pas encore. Attendu : {c.c1} côté {c.e1} et {c.c2} côté {c.e2}. {c.sens}
        </Verdict>
      )}
    </div>
  );
}
