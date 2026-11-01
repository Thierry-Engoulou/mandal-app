-- ---------------------------------------------------------------------------
-- M'Andal — Informatique, classes de Première
-- Chapitre 13 : Les bases du HTML
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
    WHERE programme_id = v_programme_id AND ordre = 13;

    IF v_chapitre_id IS NULL THEN
      INSERT INTO public.chapitres (programme_id, titre, ordre, niveau)
      VALUES (v_programme_id, 'Les bases du HTML', 13, 'Module 2 : Algorithmique et programmation')
      RETURNING id INTO v_chapitre_id;
      RAISE NOTICE '% : chapitre 13 créé.', v_nom;
    END IF;

    -- Les leçons. Si le chapitre en a déjà, on passe son tour sans rien toucher.
    SELECT count(*) INTO v_deja FROM public.concepts WHERE chapitre_id = v_chapitre_id;
    IF v_deja > 0 THEN
      RAISE NOTICE '% : le chapitre 13 a déjà ses % leçons, je n''y touche pas.', v_nom, v_deja;
      CONTINUE;
    END IF;

    INSERT INTO public.concepts
      (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes) VALUES
      (v_chapitre_id, 'Qu''est-ce que le HTML ?', 1, 'texte', '
Nous savons écrire des algorithmes. Nous allons maintenant fabriquer des pages
web — et c''est un tout autre genre de travail.

### Trois mots à ne pas confondre

**Internet** est le **réseau** mondial d''ordinateurs reliés entre eux.

Le **web** — ou *World Wide Web*, abrégé **www** — est **l''un des services** qui
circulent sur Internet : celui des pages liées entre elles. Le courriel et le
transfert de fichiers sont d''autres services d''Internet.

Le **navigateur** est le **logiciel** qui affiche les pages web : Chrome,
Firefox, Edge, Opera.

Internet n''est donc pas le web, et le web n''est pas le navigateur.

### Le HTML

**HTML** signifie *HyperText Markup Language*, soit **langage de balisage
hypertexte**.

Déplions le sigle, car chaque morceau renseigne.

**Langage de balisage** : on ne programme pas, on **marque** le texte pour dire
ce qu''il est. « Ceci est un titre », « ceci est un paragraphe ».

**Hypertexte** : le texte contient des **liens** qui mènent à d''autres pages.
C''est l''invention qui a fait le web.

Conséquence capitale : **le HTML n''est pas un langage de programmation.** Il n''a
ni variables, ni boucles, ni tests. On ne peut pas calculer en HTML. C''est une
question de cours, et elle tombe.

### La balise

Une **balise** est un mot-clé encadré par les signes `<` et `>`.

La plupart vont **par paire** : une balise d''ouverture et une de fermeture, qui
porte une barre oblique.

```
<p>Ceci est un paragraphe.</p>
<h1>Ceci est un grand titre</h1>
```

Quelques-unes sont **orphelines** : elles n''ont rien à encadrer, donc pas de
fermeture.

```
<br>
<hr>
<img src="photo.jpg" alt="Ma photo">
```

### L''attribut

Un **attribut** précise une balise. Il s''écrit **dans la balise d''ouverture**,
sous la forme `nom="valeur"`.

```
<img src="photo.jpg" alt="Ma photo" width="300">
```

Ici `src`, `alt` et `width` sont trois attributs de la balise `img`. Les
guillemets autour de la valeur sont la bonne habitude : prends-la tout de suite.

### Avec quoi on écrit du HTML

Un simple **éditeur de texte** suffit : le Bloc-notes, Notepad++, Sublime Text,
VS Code. On enregistre le fichier avec l''extension **`.html`**, et on l''ouvre
avec un navigateur.

Surtout, **pas de Word**. Word ajoute sa propre mise en forme et n''enregistre
pas du texte brut.

---

**Exercice corrigé**

*Le HTML est-il un langage de programmation ? Justifier.*

**Correction.** **Non.** Le HTML est un **langage de balisage**.

Un langage de programmation permet de décrire des traitements : déclarer des
variables, faire des calculs, prendre des décisions avec des tests, répéter avec
des boucles. Le HTML ne sait rien faire de tout cela.

Son rôle est uniquement de **décrire la structure et le contenu** d''un document :
voici un titre, voici un paragraphe, voici une image, voici un lien. Le
navigateur lit cette description et l''affiche.

Pour calculer dans une page web, il faut un vrai langage de programmation, par
exemple JavaScript côté navigateur, ou PHP côté serveur.
', NULL, 25),
      (v_chapitre_id, 'Figure : le squelette d''une page HTML', 2, 'figure', '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 540 320" width="540" height="320">
<rect width="540" height="320" fill="#ffffff"/>
<text x="270" y="22" text-anchor="middle" font-size="14" font-weight="700" fill="#0f172a">Le squelette d&apos;une page HTML, et ce que le visiteur en voit</text>

<rect x="24" y="38" width="248" height="266" rx="8" fill="#f8fafc" stroke="#94a3b8" stroke-width="1.6"/>
<text x="38" y="60" font-size="12" font-family="monospace" fill="#be185d">&lt;html&gt;</text>
<rect x="44" y="68" width="216" height="76" rx="5" fill="#fce7f3" stroke="#be185d" stroke-width="1.4"/>
<text x="56" y="86" font-size="12" font-family="monospace" fill="#9d174d">&lt;head&gt;</text>
<text x="70" y="104" font-size="11" font-family="monospace" fill="#9d174d">&lt;title&gt;M&apos;Andal&lt;/title&gt;</text>
<text x="70" y="121" font-size="11" font-family="monospace" fill="#9d174d">&lt;meta charset=&quot;utf-8&quot;&gt;</text>
<text x="56" y="138" font-size="12" font-family="monospace" fill="#9d174d">&lt;/head&gt;</text>

<rect x="44" y="152" width="216" height="118" rx="5" fill="#dcfce7" stroke="#15803d" stroke-width="1.4"/>
<text x="56" y="170" font-size="12" font-family="monospace" fill="#14532d">&lt;body&gt;</text>
<text x="70" y="190" font-size="11" font-family="monospace" fill="#14532d">&lt;h1&gt;Bienvenue&lt;/h1&gt;</text>
<text x="70" y="208" font-size="11" font-family="monospace" fill="#14532d">&lt;p&gt;Ma première</text>
<text x="70" y="224" font-size="11" font-family="monospace" fill="#14532d">page.&lt;/p&gt;</text>
<text x="56" y="250" font-size="12" font-family="monospace" fill="#14532d">&lt;/body&gt;</text>
<text x="38" y="290" font-size="12" font-family="monospace" fill="#be185d">&lt;/html&gt;</text>

<rect x="300" y="38" width="216" height="266" rx="8" fill="#ffffff" stroke="#334155" stroke-width="1.8"/>
<rect x="300" y="38" width="216" height="26" rx="8" fill="#334155"/>
<rect x="300" y="52" width="216" height="12" fill="#334155"/>
<circle cx="314" cy="51" r="4" fill="#f87171"/><circle cx="328" cy="51" r="4" fill="#fbbf24"/><circle cx="342" cy="51" r="4" fill="#4ade80"/>
<text x="366" y="55" font-size="10" fill="#e2e8f0">M&apos;Andal</text>
<text x="300" y="80" font-size="9" fill="#be185d">↑ le titre de l&apos;onglet vient du head</text>

<text x="318" y="126" font-size="20" font-weight="700" fill="#0f172a">Bienvenue</text>
<text x="318" y="156" font-size="12" fill="#334155">Ma première page.</text>
<text x="318" y="296" font-size="9" fill="#15803d">↑ tout le contenu visible vient du body</text>
</svg>', NULL, 5),
      (v_chapitre_id, 'Simulation : ton premier éditeur HTML', 3, 'interactif', '{
  "widget": "editeur-html",
  "consigne": "Un éditeur à gauche, le rendu du navigateur à droite, qui se met à jour à chaque lettre que tu tapes. Écris tes premières balises et vois-les prendre effet immédiatement. Oublie volontairement une balise de fermeture : la simulation surligne l''endroit du problème et te montre le dégât sur l''affichage, exactement comme un vrai navigateur."
}', NULL, 10),
      (v_chapitre_id, 'La structure d''une page', 4, 'texte', '
Toute page HTML a la même ossature. On l''apprend une fois, on la réécrit
toujours.

```
<!DOCTYPE html>
<html>
  <head>
    <meta charset="utf-8">
    <title>Ma première page</title>
  </head>
  <body>
    <h1>Bienvenue</h1>
    <p>Ceci est ma première page web.</p>
  </body>
</html>
```

### Ligne par ligne

**`<!DOCTYPE html>`** annonce au navigateur qu''il s''agit d''une page HTML
moderne. Elle est toujours la première ligne, et elle n''a pas de fermeture.

**`<html>`** est la balise **racine** : tout le reste est à l''intérieur.

**`<head>`** est l''**en-tête**. Elle contient les informations **sur** la page,
et son contenu **ne s''affiche pas** dans la fenêtre.

**`<title>`** donne le titre qui apparaît dans l''**onglet** du navigateur et
dans les résultats des moteurs de recherche.

**`<meta charset="utf-8">`** déclare le **jeu de caractères**. Sans elle, les
accents français s''affichent en symboles bizarres — un problème que tu
rencontreras forcément.

**`<body>`** est le **corps**. Tout ce que le visiteur voit est là : titres,
paragraphes, images, liens, tableaux.

### La règle d''or : l''imbrication

Les balises s''ouvrent et se ferment **comme des parenthèses**. La dernière
ouverte est la première fermée.

```
<p>Un mot <strong>important</strong> dans la phrase.</p>
```

Correct : `strong` est ouverte et fermée **à l''intérieur** de `p`.

```
<p>Un mot <strong>important</p></strong>
```

Faux : les balises se croisent. Le navigateur essaiera de rattraper, mais le
résultat sera imprévisible.

### Les commentaires et l''indentation

```
<!-- Ceci est un commentaire, invisible pour le visiteur -->
```

Et l''**indentation** — décaler chaque niveau d''imbrication — n''a aucun effet sur
l''affichage, mais elle rend la page relisible et t''évite les balises oubliées.

---

**Exercice corrigé**

*Écrire le code HTML complet d''une page dont l''onglet affiche « M''Andal », et
qui contient un titre « Informatique » et un paragraphe de présentation.*

**Correction.**

```
<!DOCTYPE html>
<html>
  <head>
    <meta charset="utf-8">
    <title>M''Andal</title>
  </head>
  <body>
    <h1>Informatique</h1>
    <p>Cours d''informatique des classes de Première A, C et D.</p>
  </body>
</html>
```

Les quatre points sur lesquels on te note.

Le `<!DOCTYPE html>` en première ligne.

Le texte de l''onglet est bien dans `<title>`, donc dans le `<head>` — l''y mettre
dans le `<body>` est l''erreur la plus courante.

Le `<meta charset="utf-8">` est indispensable, sinon « Informatique » passerait,
mais « Première » et l''apostrophe de « d''informatique » s''afficheraient mal.

Le contenu visible est dans `<body>`, et chaque balise ouverte est fermée.
', NULL, 25),
      (v_chapitre_id, 'Simulation : construire le squelette', 5, 'interactif', '{
  "widget": "structure-page",
  "consigne": "Les six balises du squelette te sont données en désordre : DOCTYPE, html, head, title, body, meta. Emboîte-les correctement. La simulation refuse les imbrications impossibles — le title dans le body, le head après le body — en t''expliquant chaque refus, puis t''ajoute un contenu à placer du bon côté de la frontière entre ce qui se voit et ce qui ne se voit pas."
}', NULL, 10),
      (v_chapitre_id, 'Quiz du chapitre 13', 6, 'quiz', '{
  "titre": "Vérifie que tu as compris",
  "questions": [
    {
      "question": "Que signifie le sigle HTML ?",
      "choix": [
        "High Text Modern Language",
        "HyperText Markup Language",
        "Home Tool Markup Language",
        "HyperText Machine Language"
      ],
      "bonne": 1,
      "explication": "Langage de balisage hypertexte : on marque le texte pour dire ce qu''il est, et ce texte contient des liens vers d''autres pages."
    },
    {
      "question": "Le HTML est-il un langage de programmation ?",
      "choix": [
        "Oui",
        "Non, c''est un langage de balisage : il n''a ni variables, ni boucles, ni tests",
        "Oui, mais seulement avec le CSS",
        "Oui, c''est un langage de bas niveau"
      ],
      "bonne": 1,
      "explication": "Son rôle est de décrire la structure et le contenu d''un document. Pour calculer dans une page, il faut JavaScript ou PHP."
    },
    {
      "question": "Quelle différence entre Internet et le web ?",
      "choix": [
        "Aucune",
        "Internet est le réseau mondial ; le web est l''un des services qui y circulent, celui des pages liées",
        "Le web est plus ancien",
        "Internet est un navigateur"
      ],
      "bonne": 1,
      "explication": "Le courriel et le transfert de fichiers sont d''autres services d''Internet. Et le navigateur, lui, n''est que le logiciel qui affiche les pages."
    },
    {
      "question": "Quelle balise contient tout ce que le visiteur voit à l''écran ?",
      "choix": [
        "head",
        "title",
        "body",
        "html"
      ],
      "bonne": 2,
      "explication": "Le head contient les informations SUR la page et ne s''affiche pas ; le body contient tout le contenu visible."
    },
    {
      "question": "À quoi sert la balise meta charset=\\u0022utf-8\\u0022 ?",
      "choix": [
        "À donner le titre de l''onglet",
        "À déclarer le jeu de caractères, sans quoi les accents s''affichent mal",
        "À relier la feuille de style",
        "À créer un lien"
      ],
      "bonne": 1,
      "explication": "Sans elle, « Première » et les apostrophes s''affichent en symboles bizarres. C''est un problème que tout débutant rencontre."
    },
    {
      "question": "Laquelle de ces balises est orpheline, c''est-à-dire sans fermeture ?",
      "choix": [
        "p",
        "h1",
        "br",
        "body"
      ],
      "bonne": 2,
      "explication": "br — comme hr et img — n''a rien à encadrer, donc rien à fermer. Les autres encadrent un contenu et vont par paire."
    },
    {
      "question": "L''écriture <p>Un mot <strong>important</p></strong> est :",
      "choix": [
        "correcte",
        "fausse : les balises se croisent au lieu de s''imbriquer",
        "correcte mais déconseillée",
        "correcte seulement en HTML5"
      ],
      "bonne": 1,
      "explication": "Les balises se ferment comme des parenthèses : la dernière ouverte est la première fermée. Il fallait écrire important</strong></p>."
    }
  ]
}', NULL, 5);

    RAISE NOTICE '% : 6 leçons ajoutées au chapitre 13, Les bases du HTML.', v_nom;
  END LOOP;
END $inf1$;
