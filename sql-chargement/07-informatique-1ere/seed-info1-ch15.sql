-- ---------------------------------------------------------------------------
-- M'Andal — Informatique, classes de Première
-- Chapitre 15 : Les listes et les tableaux
-- Module 2 : Algorithmique et programmation — 6 leçons
--
-- Ce fichier remplit les trois séries d'un coup : la 1ère A, la 1ère C et la
-- 1ère D. Il n'a besoin de rien d'autre pour tourner. Si la matière, les
-- classes, les programmes ou le chapitre n'existent pas encore, il les crée
-- lui-même au passage.
--
-- Lancez-le quand vous voulez, dans l'ordre que vous voulez, et autant de fois
-- que vous voulez : quand le chapitre a déjà ses leçons, le script s'en rend
-- compte et n'ajoute rien.
-- ---------------------------------------------------------------------------
DO $inf1$
DECLARE
  v_lettres text[] := ARRAY['A', 'C', 'D'];
  v_i int;
  v_nom text;
  v_lettre text;
  v_matiere_id uuid;
  v_classe_id uuid;
  v_etab_id uuid;
  v_programme_id uuid;
  v_chapitre_id uuid;
  v_nb_etabs int;
  v_deja int;
BEGIN
  -- La matière Chimie : on ne la crée qu'une fois pour toutes.
  INSERT INTO public.matieres (nom) VALUES ('Informatique') ON CONFLICT (nom) DO NOTHING;
  SELECT id INTO v_matiere_id FROM public.matieres WHERE nom = 'Informatique';

  -- L'établissement, on le retrouve à partir des classes déjà en base.
  SELECT count(DISTINCT etablissement_id) INTO v_nb_etabs FROM public.classes;
  IF v_nb_etabs <> 1 THEN
    RAISE EXCEPTION 'Je ne sais pas à quel établissement rattacher ces classes : j''en trouve % dans la table des classes, et il m''en faudrait exactement un.', v_nb_etabs;
  END IF;
  SELECT etablissement_id INTO v_etab_id FROM public.classes LIMIT 1;

  -- On refait le même travail trois fois : pour la 1ère C, puis la D, puis la E.
  FOR v_i IN 1..3 LOOP
    v_lettre := v_lettres[v_i];
    v_nom := '1ère ' || v_lettre;

    -- Le programme de Chimie de cette série existe-t-il déjà ?
    SELECT p.id INTO v_programme_id FROM public.programmes p
    WHERE p.titre = 'Informatique — ' || v_nom;

    -- Non : on le crée, et la classe avec si besoin.
    IF v_programme_id IS NULL THEN
      -- La classe a pu être écrite de plusieurs façons : 1ère A, 1ere A, Première A.
      SELECT id INTO v_classe_id FROM public.classes
      WHERE etablissement_id = v_etab_id
        AND (nom = v_nom OR nom ILIKE '1%re ' || v_lettre OR nom ILIKE 'Premi%re ' || v_lettre)
      ORDER BY (nom = v_nom) DESC
      LIMIT 1;

      IF v_classe_id IS NULL THEN
        INSERT INTO public.classes (etablissement_id, nom, niveau, filiere)
        VALUES (v_etab_id, v_nom, 'Première', v_lettre)
        RETURNING id INTO v_classe_id;
        RAISE NOTICE 'La classe % n''existait pas : je viens de la créer.', v_nom;
      END IF;

      INSERT INTO public.programmes (matiere_id, classe_id, etablissement_id, titre, description)
      VALUES (v_matiere_id, v_classe_id, v_etab_id, 'Informatique — ' || v_nom,
              'Programme officiel d''Informatique, classe de Première ' || v_lettre ||
              ' (Cameroun) — 3 modules, 20 chapitres.')
      RETURNING id INTO v_programme_id;
      RAISE NOTICE 'Programme d''Informatique de la % : créé.', v_nom;
    END IF;

    -- Le chapitre lui-même.
    SELECT id INTO v_chapitre_id FROM public.chapitres
    WHERE programme_id = v_programme_id AND ordre = 15;

    IF v_chapitre_id IS NULL THEN
      INSERT INTO public.chapitres (programme_id, titre, ordre, niveau)
      VALUES (v_programme_id, 'Les listes et les tableaux', 15, 'Module 2 : Algorithmique et programmation')
      RETURNING id INTO v_chapitre_id;
      RAISE NOTICE '% : chapitre 15 créé.', v_nom;
    END IF;

    -- Les leçons. Si le chapitre en a déjà, on passe son tour sans rien toucher.
    SELECT count(*) INTO v_deja FROM public.concepts WHERE chapitre_id = v_chapitre_id;
    IF v_deja > 0 THEN
      RAISE NOTICE '% : le chapitre 15 a déjà ses % leçons, je n''y touche pas.', v_nom, v_deja;
      CONTINUE;
    END IF;

    INSERT INTO public.concepts
      (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes) VALUES
      (v_chapitre_id, 'Les listes', 1, 'texte', '
Dès qu''on énumère, on utilise une liste. Il y en a trois sortes.

### La liste non ordonnée

L''ordre n''a pas d''importance : le navigateur met des **puces**.

```
<ul>
  <li>Maintenance informatique</li>
  <li>Algorithmique et programmation</li>
  <li>Infographie et multimédia</li>
</ul>
```

`ul` pour *unordered list*, `li` pour *list item*.

### La liste ordonnée

L''ordre compte : le navigateur **numérote** tout seul.

```
<ol>
  <li>Éteindre la machine</li>
  <li>Débrancher le câble d''alimentation</li>
  <li>Ouvrir le boîtier</li>
  <li>Mettre le bracelet antistatique</li>
</ol>
```

`ol` pour *ordered list*. Tu n''écris **pas** les numéros : ils sont ajoutés par
le navigateur. C''est tout l''intérêt — si tu intercales une étape, la
renumérotation est automatique.

### La liste de définitions

Pour un glossaire : un terme, sa définition.

```
<dl>
  <dt>RAM</dt>
  <dd>Mémoire vive, volatile, qui perd son contenu hors tension.</dd>

  <dt>POST</dt>
  <dd>Séquence de tests des composants au démarrage.</dd>
</dl>
```

`dl` pour *definition list*, `dt` pour *definition term*, `dd` pour *definition
description*.

### La règle unique

**Dans un `ul` ou un `ol`, il n''y a que des `li`.** Pas de texte posé
directement, pas de `p`. Si tu veux un paragraphe, mets-le **dans** un `li`.

### Les listes imbriquées

Une liste peut vivre **à l''intérieur d''un `li`** — et non entre deux `li`.

```
<ul>
  <li>Module 2 : Algorithmique
    <ol>
      <li>Les notions de base</li>
      <li>Les variables</li>
      <li>Les structures alternatives</li>
    </ol>
  </li>
  <li>Module 3 : Infographie</li>
</ul>
```

Observe bien où se ferme le premier `</li>` : **après** la sous-liste. C''est la
faute d''imbrication la plus fréquente de tout le chapitre.

---

**Exercice corrigé**

*Écrire en HTML la table des matières du module de maintenance : un titre, puis
la liste numérotée de ses sept chapitres, le chapitre 6 ayant deux sous-points
non numérotés, « Les virus » et « Les antivirus ».*

**Correction.**

```
<h2>Module 1 : Maintenance informatique</h2>

<ol>
  <li>Le fonctionnement d''un ordinateur</li>
  <li>Les composants de l''unité centrale</li>
  <li>Le système d''exploitation, les bus et les pilotes</li>
  <li>Introduction à la maintenance</li>
  <li>Les pannes matérielles et logicielles</li>
  <li>Les virus et les antivirus
    <ul>
      <li>Les virus</li>
      <li>Les antivirus</li>
    </ul>
  </li>
  <li>Optimiser un ordinateur</li>
</ol>
```

Les points notés : `ol` à l''extérieur, car les chapitres sont numérotés ; `ul` à
l''intérieur, car les deux sous-points ne le sont pas ; la sous-liste **dans** le
sixième `li`, dont la fermeture vient après ; et aucun numéro écrit à la main.

Vérification : le navigateur numérotera bien de 1 à 7, et « Optimiser un
ordinateur » portera le numéro 7 — et non 1, ce qui arriverait si la sous-liste
avait fermé le `li` trop tôt.
', NULL, 25),
      (v_chapitre_id, 'Simulation : construire des listes', 2, 'interactif', '{
  "widget": "listes-html",
  "consigne": "Trois énumérations te sont données en texte brut : un sommaire de module, une suite d''étapes de démontage et un glossaire. Choisis ul, ol ou dl pour chacune et balise-les. La simulation affiche le rendu à côté et t''oppose les deux imbrications possibles d''une sous-liste, pour que tu voies la numérotation se casser quand le li ferme trop tôt."
}', NULL, 10),
      (v_chapitre_id, 'Les tableaux', 3, 'texte', '
### Les quatre balises de base

```
<table border="1">
  <caption>Mes notes du premier trimestre</caption>
  <tr>
    <th>Matière</th>
    <th>Note</th>
  </tr>
  <tr>
    <td>Informatique</td>
    <td>16</td>
  </tr>
  <tr>
    <td>Mathématiques</td>
    <td>13</td>
  </tr>
</table>
```

**`table`** ouvre et ferme le tableau.

**`caption`** donne son **titre**, affiché au-dessus. Elle se place juste après
`<table>`.

**`tr`** — *table row* — est une **ligne**.

**`th`** — *table header* — est une cellule d''**en-tête**. Le navigateur
l''affiche en gras et centrée.

**`td`** — *table data* — est une cellule **ordinaire**.

La règle à ne pas perdre : **les cellules vivent toujours dans un `tr`**, jamais
directement dans le `table`. Un tableau se construit **ligne par ligne**, et
dans chaque ligne, cellule par cellule.

### Compter les cellules

Un tableau de 3 lignes et 4 colonnes contient **3 `tr`**, et **4 cellules dans
chacun**, soit 12 cellules. On te demande souvent de compter : fais-le toujours
ligne par ligne.

### Les attributs de présentation

| Attribut | Effet |
| --- | --- |
| `border` | épaisseur du cadre, en pixels |
| `width` | largeur du tableau, en pixels ou en pourcentage |
| `cellpadding` | espace **à l''intérieur** des cellules, entre le bord et le texte |
| `cellspacing` | espace **entre** les cellules |
| `frame` | quels bords extérieurs tracer |
| `rules` | quels traits intérieurs tracer |
| `summary` | résumé du tableau pour les lecteurs d''écran |

Ne confonds pas les deux voisins : **`cellpadding`** gonfle l''intérieur de
chaque cellule, **`cellspacing`** écarte les cellules entre elles. C''est une
question d''examen.

Aujourd''hui, tout cela se fait plutôt en CSS. Mais ces attributs sont au
programme et sont demandés, donc apprends-les.

### Fusionner des cellules

**`colspan`** étend une cellule sur plusieurs **colonnes**, **`rowspan`** sur
plusieurs **lignes**.

```
<tr>
  <th colspan="2">Premier trimestre</th>
</tr>
```

Cette cellule occupe la largeur de deux colonnes. Conséquence à ne pas oublier :
cette ligne ne contient plus qu''**une seule** cellule au lieu de deux.

### Les trois sections

```
<thead> ... </thead>   l''en-tête du tableau
<tbody> ... </tbody>   le corps, les données
<tfoot> ... </tfoot>   le pied, les totaux
```

Elles regroupent les lignes et permettent, par exemple, de répéter l''en-tête sur
chaque page à l''impression.

---

**Exercice corrigé**

*Construire un tableau à bordure présentant trois élèves avec leur classe et
leur moyenne, titré « Résultats », et dont la dernière ligne affiche la moyenne
générale sur toute la largeur.*

**Correction.**

```
<table border="1" cellpadding="6">
  <caption>Résultats</caption>

  <thead>
    <tr>
      <th>Nom</th>
      <th>Classe</th>
      <th>Moyenne</th>
    </tr>
  </thead>

  <tbody>
    <tr><td>Thierry</td><td>1ère C</td><td>14,5</td></tr>
    <tr><td>Aïssatou</td><td>1ère D</td><td>15,2</td></tr>
    <tr><td>Bertrand</td><td>1ère A</td><td>11,8</td></tr>
  </tbody>

  <tfoot>
    <tr>
      <td colspan="3">Moyenne générale : 13,83</td>
    </tr>
  </tfoot>
</table>
```

Deux choses sur lesquelles on te note.

Le `colspan="3"` de la dernière ligne, parce que le tableau a **trois**
colonnes : c''est bien 3, pas 2. Et du coup cette ligne ne contient qu''**une**
cellule.

Le `cellpadding="6"` n''est pas demandé, mais sans un peu d''espace intérieur le
texte colle aux bordures et le tableau est illisible.

Vérification du total : $(14{,}5 + 15{,}2 + 11{,}8) / 3 = 41{,}5 / 3 \approx
13{,}83$.
', NULL, 28),
      (v_chapitre_id, 'Figure : les balises d''un tableau et son rendu', 4, 'figure', '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 540 290" width="540" height="290">
<rect width="540" height="290" fill="#ffffff"/>
<text x="270" y="22" text-anchor="middle" font-size="14" font-weight="700" fill="#0f172a">Les balises d&apos;un tableau, et le tableau obtenu</text>

<text x="24" y="52" font-size="11" font-family="monospace" fill="#1e3a8a">&lt;table border=&quot;1&quot;&gt;</text>
<text x="38" y="70" font-size="11" font-family="monospace" fill="#be185d">&lt;caption&gt;Mes notes&lt;/caption&gt;</text>
<text x="38" y="88" font-size="11" font-family="monospace" fill="#15803d">&lt;tr&gt;</text>
<text x="52" y="106" font-size="11" font-family="monospace" fill="#b45309">&lt;th&gt;Matière&lt;/th&gt;</text>
<text x="52" y="124" font-size="11" font-family="monospace" fill="#b45309">&lt;th&gt;Note&lt;/th&gt;</text>
<text x="38" y="142" font-size="11" font-family="monospace" fill="#15803d">&lt;/tr&gt;</text>
<text x="38" y="160" font-size="11" font-family="monospace" fill="#15803d">&lt;tr&gt;</text>
<text x="52" y="178" font-size="11" font-family="monospace" fill="#0f766e">&lt;td&gt;Info&lt;/td&gt;</text>
<text x="52" y="196" font-size="11" font-family="monospace" fill="#0f766e">&lt;td&gt;16&lt;/td&gt;</text>
<text x="38" y="214" font-size="11" font-family="monospace" fill="#15803d">&lt;/tr&gt;</text>
<text x="24" y="232" font-size="11" font-family="monospace" fill="#1e3a8a">&lt;/table&gt;</text>

<text x="300" y="64" font-size="12" font-weight="700" fill="#be185d">Mes notes</text>
<rect x="300" y="76" width="110" height="30" fill="#fed7aa" stroke="#334155" stroke-width="1.4"/>
<rect x="410" y="76" width="80" height="30" fill="#fed7aa" stroke="#334155" stroke-width="1.4"/>
<text x="355" y="96" text-anchor="middle" font-size="12" font-weight="700" fill="#7c2d12">Matière</text>
<text x="450" y="96" text-anchor="middle" font-size="12" font-weight="700" fill="#7c2d12">Note</text>
<rect x="300" y="106" width="110" height="30" fill="#ccfbf1" stroke="#334155" stroke-width="1.4"/>
<rect x="410" y="106" width="80" height="30" fill="#ccfbf1" stroke="#334155" stroke-width="1.4"/>
<text x="355" y="126" text-anchor="middle" font-size="12" fill="#134e4a">Info</text>
<text x="450" y="126" text-anchor="middle" font-size="12" fill="#134e4a">16</text>

<rect x="300" y="160" width="216" height="104" rx="6" fill="#f1f5f9" stroke="#94a3b8" stroke-width="1.2"/>
<text x="314" y="180" font-size="10" font-weight="700" fill="#0f172a">La règle à retenir</text>
<text x="314" y="198" font-size="10" fill="#15803d">tr = une LIGNE</text>
<text x="314" y="214" font-size="10" fill="#b45309">th = une cellule d&apos;EN-TÊTE</text>
<text x="314" y="230" font-size="10" fill="#0f766e">td = une cellule ORDINAIRE</text>
<text x="314" y="250" font-size="10" fill="#64748b">Les cellules vivent toujours</text>
<text x="314" y="262" font-size="10" fill="#64748b">dans un tr, jamais seules.</text>
</svg>', NULL, 5),
      (v_chapitre_id, 'Simulation : construire un tableau', 5, 'interactif', '{
  "widget": "tableaux-html",
  "consigne": "Choisis le nombre de lignes et de colonnes, remplis les cellules, et vois le code et le rendu se construire ensemble. Les curseurs de border, cellpadding et cellspacing agissent en direct, ce qui est le seul moyen de ne plus confondre les deux derniers. Un bouton fusionne des cellules avec colspan et rowspan, et la simulation te signale quand le compte de cellules d''une ligne ne tombe plus juste."
}', NULL, 10),
      (v_chapitre_id, 'Quiz du chapitre 15', 6, 'quiz', '{
  "titre": "Vérifie que tu as compris",
  "questions": [
    {
      "question": "Quelle balise crée une liste numérotée ?",
      "choix": [
        "ul",
        "ol",
        "dl",
        "li"
      ],
      "bonne": 1,
      "explication": "ol pour ordered list. Et on n''écrit pas les numéros : le navigateur les ajoute, ce qui rend la renumérotation automatique."
    },
    {
      "question": "Que peut-on placer directement dans un ul ?",
      "choix": [
        "Du texte",
        "Des balises p",
        "Uniquement des li",
        "N''importe quelle balise"
      ],
      "bonne": 2,
      "explication": "Rien d''autre que des li. Si vous voulez un paragraphe dans une liste, placez-le À L''INTÉRIEUR d''un li."
    },
    {
      "question": "Où doit-on placer une sous-liste dans une liste imbriquée ?",
      "choix": [
        "Entre deux li",
        "À l''intérieur du li auquel elle se rattache",
        "Avant le ul",
        "Après le ul de fermeture"
      ],
      "bonne": 1,
      "explication": "Et le li ne se ferme qu''APRÈS la sous-liste. C''est la faute d''imbrication la plus fréquente, et elle casse la numérotation de la suite."
    },
    {
      "question": "Dans un tableau, que représente la balise tr ?",
      "choix": [
        "Une colonne",
        "Une ligne",
        "Une cellule",
        "Le titre du tableau"
      ],
      "bonne": 1,
      "explication": "tr pour table row. Un tableau se construit ligne par ligne, et dans chaque ligne, cellule par cellule."
    },
    {
      "question": "Quelle est la différence entre th et td ?",
      "choix": [
        "Aucune",
        "th est une cellule d''en-tête, affichée en gras et centrée ; td est une cellule ordinaire",
        "th est pour les lignes, td pour les colonnes",
        "th est obligatoire, td facultative"
      ],
      "bonne": 1,
      "explication": "th pour table header, td pour table data. Les deux doivent se trouver à l''intérieur d''un tr."
    },
    {
      "question": "Quelle est la différence entre cellpadding et cellspacing ?",
      "choix": [
        "Aucune",
        "cellpadding est l''espace à l''intérieur des cellules, cellspacing l''espace entre les cellules",
        "cellpadding concerne les lignes, cellspacing les colonnes",
        "cellspacing est l''épaisseur de la bordure"
      ],
      "bonne": 1,
      "explication": "padding gonfle l''intérieur de chaque cellule, spacing écarte les cellules entre elles. C''est une question d''examen classique."
    },
    {
      "question": "Dans un tableau de trois colonnes, une cellule qui occupe toute la largeur s''écrit :",
      "choix": [
        "rowspan=\\u00223\\u0022",
        "colspan=\\u00223\\u0022",
        "width=\\u00223\\u0022",
        "colspan=\\u00222\\u0022"
      ],
      "bonne": 1,
      "explication": "colspan étend sur plusieurs COLONNES, rowspan sur plusieurs LIGNES. Et cette ligne ne contient alors plus qu''une seule cellule."
    }
  ]
}', NULL, 5);

    RAISE NOTICE '% : 6 leçons ajoutées au chapitre 15, Les listes et les tableaux.', v_nom;
  END LOOP;
END $inf1$;
