-- ---------------------------------------------------------------------------
-- M'Andal — Informatique, classes de Première
-- Chapitre 14 : Les balises usuelles : texte, images et liens
-- Module 2 : Algorithmique et programmation — 7 leçons
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
    WHERE programme_id = v_programme_id AND ordre = 14;

    IF v_chapitre_id IS NULL THEN
      INSERT INTO public.chapitres (programme_id, titre, ordre, niveau)
      VALUES (v_programme_id, 'Les balises usuelles : texte, images et liens', 14, 'Module 2 : Algorithmique et programmation')
      RETURNING id INTO v_chapitre_id;
      RAISE NOTICE '% : chapitre 14 créé.', v_nom;
    END IF;

    -- Les leçons. Si le chapitre en a déjà, on passe son tour sans rien toucher.
    SELECT count(*) INTO v_deja FROM public.concepts WHERE chapitre_id = v_chapitre_id;
    IF v_deja > 0 THEN
      RAISE NOTICE '% : le chapitre 14 a déjà ses % leçons, je n''y touche pas.', v_nom, v_deja;
      CONTINUE;
    END IF;

    INSERT INTO public.concepts
      (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes) VALUES
      (v_chapitre_id, 'Mettre en forme le texte', 1, 'texte', '
Nous avons le squelette. Remplissons-le.

### Les titres

Six niveaux, de `h1` à `h6`.

```
<h1>Titre principal</h1>
<h2>Sous-titre</h2>
<h3>Sous-sous-titre</h3>
```

Le navigateur les affiche de plus en plus petits, mais **ce n''est pas le point**.
Les titres servent à donner une **hiérarchie** : `h1` pour le sujet de la page,
`h2` pour ses grandes sections, et ainsi de suite.

On ne choisit donc **jamais** un niveau de titre pour sa taille. Si `h2` est trop
gros, on le réduit en CSS — on ne passe pas à `h4`.

Et on met **un seul `h1`** par page : c''est le sujet, il n''y en a qu''un.

### Les paragraphes et les sauts

```
<p>Premier paragraphe.</p>
<p>Deuxième paragraphe.</p>
```

`<br>` force un **retour à la ligne** sans créer de nouveau paragraphe. Utile
pour une adresse ou un poème.

`<hr>` trace une **ligne horizontale** de séparation.

Les deux sont orphelines.

### Une chose qui surprend tous les débutants

Le HTML **ignore les espaces multiples et les retours à la ligne** de ton
fichier. Ceci :

```
<p>Bonjour      tout
le        monde</p>
```

s''affiche `Bonjour tout le monde`, sur une seule ligne. Pour aérer, il faut des
balises — `<p>` ou `<br>` — pas des touches Entrée.

### La mise en valeur

| Balise | Effet | Sens |
| --- | --- | --- |
| `<strong>` | gras | ce texte est **important** |
| `<em>` | italique | ce texte est **accentué** |
| `<b>` | gras | aucun : juste du gras |
| `<i>` | italique | aucun : juste de l''italique |
| `<u>` | souligné | aucun |

On préfère `strong` et `em`, car ils portent un **sens** que les logiciels de
lecture pour aveugles savent transmettre. `b` et `i` ne sont que de la
décoration.

Et un conseil : évite `<u>`. Sur le web, le souligné veut dire « lien
cliquable », et souligner du texte ordinaire trompe le visiteur.

---

**Exercice corrigé**

*Écrire le code HTML du corps d''une page présentant le module d''algorithmique,
avec un titre principal, deux sous-titres et un paragraphe sous chacun, le mot
« algorithme » étant mis en valeur.*

**Correction.**

```
<body>
  <h1>Module d''algorithmique</h1>

  <h2>Les notions de base</h2>
  <p>Un <strong>algorithme</strong> est une suite finie et ordonnée
  d''instructions permettant de résoudre un problème.</p>

  <hr>

  <h2>Les structures de contrôle</h2>
  <p>On distingue les structures <em>alternatives</em> et les structures
  <em>répétitives</em>.</p>
</body>
```

Les choix à justifier : un seul `h1`, car il n''y a qu''un sujet ; deux `h2` de
même niveau, car les deux sections sont de même importance ; `strong` pour le
mot-clé défini, car il est important, et `em` pour les deux termes techniques,
qu''on souligne par la voix en les lisant.

Le retour à la ligne au milieu du premier paragraphe n''a aucun effet sur
l''affichage : il ne sert qu''à rendre le code lisible.
', NULL, 25),
      (v_chapitre_id, 'Simulation : les balises de texte', 2, 'interactif', '{
  "widget": "balises-texte",
  "consigne": "Un texte brut t''est donné sans aucune balise, et une barre d''outils te propose h1 à h6, p, br, hr, strong et em. Balise le texte et compare ton rendu au modèle attendu. La simulation te montre aussi ce que fait vraiment le navigateur avec tes espaces multiples et tes retours à la ligne — la surprise classique du débutant."
}', NULL, 10),
      (v_chapitre_id, 'Les images', 3, 'texte', '
### La balise

```
<img src="photo.jpg" alt="Portrait de Thierry">
```

`img` est **orpheline** : l''image n''encadre aucun texte, donc il n''y a pas de
`</img>`.

### Les attributs

**`src`** — pour *source* — donne le **chemin du fichier**. Il est
**obligatoire** : sans lui, il n''y a rien à afficher.

**`alt`** — pour *alternative* — donne le **texte de remplacement**, affiché si
l''image ne charge pas, et lu à voix haute par les logiciels pour aveugles. Il
est **obligatoire** lui aussi, et c''est celui que les élèves oublient.

**`width`** et **`height`** donnent la **largeur** et la **hauteur** en pixels.

```
<img src="images/logo.png" alt="Logo M''Andal" width="200" height="80">
```

Un conseil : ne donne **qu''une seule** des deux dimensions. Le navigateur
calcule l''autre et l''image garde ses proportions. En donnant les deux au hasard,
tu la déformes.

### Les chemins

`src="photo.jpg"` — l''image est dans le **même dossier** que la page.

`src="images/photo.jpg"` — dans le **sous-dossier** `images`.

`src="../photo.jpg"` — dans le **dossier parent**, un niveau au-dessus.

`src="https://exemple.cm/photo.jpg"` — sur **un autre site**.

Un chemin faux est la première cause d''image qui ne s''affiche pas. Et attention :
sur le web, `Photo.JPG` et `photo.jpg` sont **deux noms différents**. Prends
l''habitude de tout nommer en minuscules, sans espaces ni accents.

### Les formats

| Format | Son terrain |
| --- | --- |
| **JPEG** (`.jpg`) | les photographies ; compression forte, mais avec perte de qualité |
| **PNG** (`.png`) | les logos et les dessins ; accepte la transparence, sans perte |
| **GIF** (`.gif`) | les petites animations ; seulement 256 couleurs |
| **SVG** (`.svg`) | les dessins vectoriels ; s''agrandit sans jamais pixeliser |

Nous reviendrons sur tout cela au module d''infographie, où ces formats sont
étudiés pour eux-mêmes.

---

**Exercice corrigé**

*Insérer dans une page l''image `eleves.jpg`, rangée dans un sous-dossier
`images`, large de 400 pixels, avec un texte de remplacement convenable.*

**Correction.**

```
<img src="images/eleves.jpg" alt="Élèves de Première C en salle informatique"
     width="400">
```

Trois remarques qui valent les points.

Le chemin `images/eleves.jpg` suit le sous-dossier sans barre oblique au début :
`/images/eleves.jpg` partirait de la racine du site, ce qui n''est pas la même
chose.

Le `alt` **décrit** l''image. Écrire `alt="image"` ou `alt="photo"` ne sert à
rien : un visiteur aveugle n''apprend rien, et si le fichier manque, le lecteur
non plus.

Seule la largeur est donnée. La hauteur se calcule toute seule et l''image reste
proportionnée.
', NULL, 25),
      (v_chapitre_id, 'Simulation : insérer une image', 4, 'interactif', '{
  "widget": "balise-image",
  "consigne": "Une arborescence de dossiers s''affiche à gauche, avec des images rangées à différents endroits. Écris le chemin dans l''attribut src et vois si l''image apparaît ou si tu obtiens le texte alternatif. La simulation te fait essayer le dossier parent, un nom mal capitalisé et une seule dimension contre les deux, pour que tu voies la déformation de tes propres yeux."
}', NULL, 10),
      (v_chapitre_id, 'Les liens', 5, 'texte', '
C''est le cœur du web : ce qui relie les pages entre elles.

### La balise

```
<a href="page2.html">Aller à la page 2</a>
```

`a` vient de *anchor*, ancre. `href` vient de *hypertext reference*.

Le texte **entre les deux balises** est ce que le visiteur voit et clique.
L''adresse est dans `href` et n''est jamais visible.

### Les quatre sortes de liens

**Le lien interne au site** — vers une autre page du même site :

```
<a href="cours.html">Les cours</a>
<a href="modules/info.html">Informatique</a>
```

**Le lien externe** — vers un autre site. L''adresse est complète :

```
<a href="https://www.minesec.gov.cm">Site du MINESEC</a>
```

**L''ancre** — vers un endroit **précis de la page**. Deux temps : on marque la
destination avec un `id`, puis on y renvoie avec un `#`.

```
<h2 id="quiz">Le quiz</h2>
...
<a href="#quiz">Aller directement au quiz</a>
```

C''est très utile sur une longue page de cours.

**Le lien de courriel** — il ouvre le logiciel de messagerie :

```
<a href="mailto:contact@mandal.cm">Nous écrire</a>
```

### Ouvrir dans un nouvel onglet

```
<a href="https://www.minesec.gov.cm" target="_blank">Site du MINESEC</a>
```

L''attribut `target="_blank"` ouvre le lien dans un **nouvel onglet**. C''est le
bon réflexe pour les liens **externes** : le visiteur ne perd pas ta page.

### Une image cliquable

Un lien peut encadrer autre chose que du texte, par exemple une image :

```
<a href="accueil.html">
  <img src="logo.png" alt="Retour à l''accueil">
</a>
```

C''est ainsi que fonctionne le logo de presque tous les sites.

---

**Exercice corrigé**

*Écrire les liens suivants : vers la page `exercices.html` du même dossier ;
vers le site `www.mandal.cm` dans un nouvel onglet ; vers la section d''une même
page portant l''identifiant `corrige` ; et vers l''adresse `prof@mandal.cm`.*

**Correction.**

```
<a href="exercices.html">Les exercices</a>

<a href="https://www.mandal.cm" target="_blank">Le site M''Andal</a>

<a href="#corrige">Voir le corrigé</a>

<a href="mailto:prof@mandal.cm">Écrire au professeur</a>
```

Les quatre pièges correspondants.

Pour la page du même dossier, **pas** de `https://` ni de barre oblique
initiale : juste le nom du fichier.

Pour le site externe, le `https://` est **obligatoire**. Écrire
`href="www.mandal.cm"` ferait chercher au navigateur un fichier nommé
`www.mandal.cm` dans ton dossier.

Pour l''ancre, le **dièse** est indispensable, et la destination doit porter
`id="corrige"` quelque part dans la page, sinon le lien ne mène nulle part.

Pour le courriel, `mailto:` est **collé** à l''adresse, sans espace, et sans
barres obliques.
', NULL, 25),
      (v_chapitre_id, 'Simulation : fabriquer des liens', 6, 'interactif', '{
  "widget": "balise-lien",
  "consigne": "Un petit site de trois pages t''est donné, et tu dois les relier : un lien interne, un lien externe, une ancre vers le bas d''une longue page, un lien de courriel. Chaque lien est cliquable dans la simulation, donc une erreur se voit tout de suite. Les quatre fautes classiques sont guettées : le https oublié sur un lien externe, le dièse oublié sur une ancre, la barre oblique en trop et l''espace après mailto."
}', NULL, 10),
      (v_chapitre_id, 'Quiz du chapitre 14', 7, 'quiz', '{
  "titre": "Vérifie que tu as compris",
  "questions": [
    {
      "question": "Combien de niveaux de titres existe-t-il en HTML ?",
      "choix": [
        "Trois",
        "Six, de h1 à h6",
        "Dix",
        "Autant qu''on veut"
      ],
      "bonne": 1,
      "explication": "Et ils servent à donner une hiérarchie, pas une taille : si h2 est trop gros, on le réduit en CSS, on ne passe pas à h4."
    },
    {
      "question": "Que devient <p>Bonjour      tout le monde</p> avec ses nombreux espaces ?",
      "choix": [
        "Les espaces sont conservés",
        "Le navigateur les réduit à un seul espace",
        "La page affiche une erreur",
        "Le texte est coupé"
      ],
      "bonne": 1,
      "explication": "Le HTML ignore les espaces multiples et les retours à la ligne. Pour aérer, il faut des balises p ou br, pas des touches Entrée."
    },
    {
      "question": "Pourquoi préférer strong à b ?",
      "choix": [
        "strong affiche un gras plus épais",
        "strong porte un sens que les logiciels de lecture pour aveugles transmettent, b n''est que de la décoration",
        "b est interdit",
        "strong est plus court à écrire"
      ],
      "bonne": 1,
      "explication": "Même rendu visuel, mais seul strong dit que le texte est important. Même raisonnement entre em et i."
    },
    {
      "question": "Quels sont les deux attributs obligatoires de la balise img ?",
      "choix": [
        "width et height",
        "src et alt",
        "src et width",
        "alt et title"
      ],
      "bonne": 1,
      "explication": "src donne le chemin du fichier, alt le texte de remplacement. C''est alt que les élèves oublient, alors qu''il sert aux aveugles et aux images manquantes."
    },
    {
      "question": "Que signifie le chemin src=\\u0022../photo.jpg\\u0022 ?",
      "choix": [
        "L''image est dans le même dossier",
        "L''image est dans un sous-dossier",
        "L''image est dans le dossier parent, un niveau au-dessus",
        "L''image est sur un autre site"
      ],
      "bonne": 2,
      "explication": "Les deux points remontent d''un niveau. Un chemin faux est la première cause d''image qui ne s''affiche pas."
    },
    {
      "question": "Quel attribut de la balise a contient l''adresse de destination ?",
      "choix": [
        "src",
        "href",
        "link",
        "target"
      ],
      "bonne": 1,
      "explication": "href, pour hypertext reference. Le texte entre les deux balises est ce que le visiteur voit ; l''adresse, elle, n''est jamais visible."
    },
    {
      "question": "Comment crée-t-on un lien vers une section de la même page ?",
      "choix": [
        "Avec href et le nom du fichier",
        "En donnant un id à la destination et en écrivant href avec un dièse devant",
        "Avec target=_blank",
        "Avec mailto:"
      ],
      "bonne": 1,
      "explication": "Deux temps : id=\\u0022quiz\\u0022 sur la destination, puis href=\\u0022#quiz\\u0022 sur le lien. Sans le dièse, le navigateur chercherait un fichier."
    }
  ]
}', NULL, 5);

    RAISE NOTICE '% : 7 leçons ajoutées au chapitre 14, Les balises usuelles : texte, images et liens.', v_nom;
  END LOOP;
END $inf1$;
