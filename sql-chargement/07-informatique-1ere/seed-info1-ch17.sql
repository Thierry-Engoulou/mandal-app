-- ---------------------------------------------------------------------------
-- M'Andal — Informatique, classes de Première
-- Chapitre 17 : Les feuilles de style CSS
-- Module 2 : Algorithmique et programmation — 8 leçons
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
    WHERE programme_id = v_programme_id AND ordre = 17;

    IF v_chapitre_id IS NULL THEN
      INSERT INTO public.chapitres (programme_id, titre, ordre, niveau)
      VALUES (v_programme_id, 'Les feuilles de style CSS', 17, 'Module 2 : Algorithmique et programmation')
      RETURNING id INTO v_chapitre_id;
      RAISE NOTICE '% : chapitre 17 créé.', v_nom;
    END IF;

    -- Les leçons. Si le chapitre en a déjà, on passe son tour sans rien toucher.
    SELECT count(*) INTO v_deja FROM public.concepts WHERE chapitre_id = v_chapitre_id;
    IF v_deja > 0 THEN
      RAISE NOTICE '% : le chapitre 17 a déjà ses % leçons, je n''y touche pas.', v_nom, v_deja;
      CONTINUE;
    END IF;

    INSERT INTO public.concepts
      (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes) VALUES
      (v_chapitre_id, 'Qu''est-ce que le CSS ?', 1, 'texte', '
Nos pages sont correctes mais grises. Le CSS va les habiller.

### La séparation des rôles

**CSS** signifie *Cascading Style Sheets*, **feuilles de style en cascade**.

Le partage est net, et c''est le fondement du chapitre :

**Le HTML dit ce qu''il y a.** Un titre, un paragraphe, un tableau.

**Le CSS dit à quoi cela ressemble.** Rouge, centré, en Arial, avec une bordure.

Pourquoi séparer ? Parce qu''une seule feuille de style peut habiller **cent
pages**. Change une ligne, les cent pages changent. Si la couleur était écrite
dans chaque page, il faudrait les reprendre une par une.

### La syntaxe d''une règle

```
h1 {
    color: red;
    text-align: center;
}
```

Trois parties, et un vocabulaire à savoir nommer.

**Le sélecteur** — `h1` — désigne **qui** est visé.

**La propriété** — `color` — désigne **quoi** est changé.

**La valeur** — `red` — désigne **comment**.

La ponctuation : des **accolades** autour du bloc, **deux-points** entre la
propriété et la valeur, **point-virgule** à la fin de chaque déclaration.

L''oubli d''un point-virgule est la panne la plus fréquente d''un débutant : la
déclaration suivante est avalée, et on cherche longtemps.

### Les sélecteurs

```
p { ... }              toutes les balises p
h1, h2 { ... }         toutes les h1 ET toutes les h2
.important { ... }     tous les éléments de classe "important"
#menu { ... }          l''unique élément d''identifiant "menu"
div p { ... }          les p situés à l''intérieur d''un div
```

Les deux à bien distinguer :

Le **point** désigne une **classe**, posée en HTML par `class="important"`. Une
classe peut servir **autant de fois qu''on veut** dans la page.

Le **dièse** désigne un **identifiant**, posé par `id="menu"`. Un identifiant
doit être **unique** dans la page.

```
<p class="important">Ce paragraphe compte.</p>
<p class="important">Celui-ci aussi.</p>
<div id="menu">Un seul menu.</div>
```

### Le commentaire

```
/* Ceci est un commentaire CSS */
```

Il ne s''écrit pas comme en HTML. Ne les confonds pas.

---

**Exercice corrigé**

*Écrire les règles CSS mettant tous les titres de niveau 1 en bleu et centrés,
et les paragraphes de classe « avertissement » en rouge et en gras.*

**Correction.**

```
h1 {
    color: blue;
    text-align: center;
}

p.avertissement {
    color: red;
    font-weight: bold;
}
```

Deux explications.

Pour les titres, le sélecteur est simplement `h1` : la règle s''applique à **tous**
les `h1` de toutes les pages liées à cette feuille.

Pour les paragraphes, `p.avertissement` signifie « les `p` qui portent la classe
`avertissement` ». On pourrait écrire `.avertissement` tout court, mais la règle
s''appliquerait alors à n''importe quel élément portant cette classe, y compris un
`div` ou un `h2` — l''énoncé parle de paragraphes, donc on précise.

Et en HTML, il faut poser la classe : `<p class="avertissement">…</p>`. Une règle
CSS qui vise une classe absente du HTML ne fait rien, et c''est une erreur
courante.
', NULL, 25),
      (v_chapitre_id, 'Figure : la syntaxe d''une règle CSS', 2, 'figure', '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 540 250" width="540" height="250">
<rect width="540" height="250" fill="#ffffff"/>
<text x="270" y="22" text-anchor="middle" font-size="14" font-weight="700" fill="#0f172a">La syntaxe d&apos;une règle CSS</text>

<text x="60" y="80" font-size="22" font-family="monospace" fill="#be185d">h1</text>
<text x="104" y="80" font-size="22" font-family="monospace" fill="#334155">{</text>
<text x="136" y="80" font-size="20" font-family="monospace" fill="#2563eb">color</text>
<text x="212" y="80" font-size="20" font-family="monospace" fill="#334155">:</text>
<text x="232" y="80" font-size="20" font-family="monospace" fill="#15803d">red</text>
<text x="282" y="80" font-size="20" font-family="monospace" fill="#334155">;</text>
<text x="302" y="80" font-size="22" font-family="monospace" fill="#334155">}</text>

<line x1="72" y1="92" x2="72" y2="124" stroke="#be185d" stroke-width="1.6"/>
<text x="72" y="140" text-anchor="middle" font-size="11" font-weight="700" fill="#be185d">le sélecteur</text>
<text x="72" y="155" text-anchor="middle" font-size="9" fill="#9d174d">QUI est visé</text>

<line x1="168" y1="92" x2="168" y2="166" stroke="#2563eb" stroke-width="1.6"/>
<text x="168" y="182" text-anchor="middle" font-size="11" font-weight="700" fill="#2563eb">la propriété</text>
<text x="168" y="197" text-anchor="middle" font-size="9" fill="#1e40af">QUOI est changé</text>

<line x1="252" y1="92" x2="252" y2="124" stroke="#15803d" stroke-width="1.6"/>
<text x="252" y="140" text-anchor="middle" font-size="11" font-weight="700" fill="#15803d">la valeur</text>
<text x="252" y="155" text-anchor="middle" font-size="9" fill="#166534">COMMENT</text>

<rect x="340" y="46" width="176" height="52" rx="6" fill="#fef3c7" stroke="#ca8a04" stroke-width="1.4"/>
<text x="428" y="66" text-anchor="middle" font-size="10" font-weight="700" fill="#78350f">Deux-points entre la</text>
<text x="428" y="80" text-anchor="middle" font-size="10" font-weight="700" fill="#78350f">propriété et la valeur,</text>
<text x="428" y="92" text-anchor="middle" font-size="10" fill="#92400e">point-virgule à la fin.</text>

<rect x="60" y="212" width="420" height="28" rx="6" fill="#eff6ff" stroke="#2563eb" stroke-width="1.2"/>
<text x="270" y="230" text-anchor="middle" font-size="11" fill="#1e3a8a">Le HTML dit ce qu&apos;il y a. Le CSS dit à quoi cela ressemble.</text>
</svg>', NULL, 5),
      (v_chapitre_id, 'Simulation : la syntaxe CSS', 3, 'interactif', '{
  "widget": "syntaxe-css",
  "consigne": "Un éditeur CSS à gauche, une page HTML à droite qui se restyle en direct. Écris des règles, change de sélecteur, et vois exactement quels éléments sont touchés — ils se surlignent au survol. Retire un point-virgule et la simulation te montre la déclaration suivante avalée, puis compare une classe et un identifiant sur trois éléments à la fois."
}', NULL, 10),
      (v_chapitre_id, 'Les trois façons de placer du CSS', 4, 'texte', '
Il y a trois endroits où écrire du style, et on te demande de les comparer.

### En ligne, dans la balise

```
<p style="color: red;">Ce paragraphe est rouge.</p>
```

Le style est dans l''attribut `style` de la balise. Il ne concerne que **cette
balise**.

*Pratique* pour un essai rapide. *Mauvais* pour tout le reste : il faut le
répéter sur chaque balise, et on perd la séparation du contenu et de la
présentation.

### Interne, dans le head

```
<head>
  <style>
    h1 { color: blue; }
    p  { font-size: 14px; }
  </style>
</head>
```

La balise `<style>` se place **dans le `head`**. Les règles valent pour **toute
la page**, et pour elle seule.

*Bien* pour une page unique. *Insuffisant* dès qu''il y a plusieurs pages : il
faudrait recopier le bloc partout.

### Externe, dans un fichier séparé

Un fichier `style.css` qui ne contient **que du CSS**, sans aucune balise HTML :

```
h1 { color: blue; }
p  { font-size: 14px; }
```

Et dans le `head` de **chaque** page :

```
<link rel="stylesheet" href="style.css">
```

C''est la **meilleure** méthode, et celle à citer quand on te demande laquelle
choisir. Un seul fichier habille tout le site ; une correction se fait une fois
et profite à toutes les pages ; le navigateur garde le fichier en mémoire, donc
les pages suivantes se chargent plus vite.

### La cascade

Si trois règles visent le même élément, laquelle gagne ? C''est le mot
« cascade » du sigle.

**En ligne** l''emporte sur **interne**, qui l''emporte sur **externe**.

Autrement dit, **le plus proche de l''élément gagne**.

```
<!-- style.css -->      p { color: blue; }
<!-- dans le head -->   p { color: green; }
<!-- dans la balise -->  <p style="color: red;">…</p>
```

Le paragraphe sera **rouge**.

Et à égalité de provenance, **la dernière règle écrite** l''emporte. C''est
pourquoi un débutant croit souvent que « le CSS ne marche pas » : sa règle est
simplement écrasée par une autre, plus proche ou plus tardive.

---

**Exercice corrigé**

*Citer les trois façons de placer du CSS dans une page, et dire laquelle est
préférable pour un site de plusieurs pages, en justifiant.*

**Correction.** Les trois façons sont le **CSS en ligne**, dans l''attribut
`style` d''une balise ; le **CSS interne**, dans une balise `<style>` placée dans
le `head` ; et le **CSS externe**, dans un fichier `.css` séparé relié par
`<link rel="stylesheet" href="…">`.

Pour un site de plusieurs pages, c''est le **CSS externe** qu''il faut choisir,
pour trois raisons.

**Une seule source.** Le même fichier habille toutes les pages, donc le site est
cohérent.

**Une seule correction.** Changer la couleur des titres de tout le site demande
une ligne, au lieu d''une modification dans chaque page.

**Un chargement plus rapide.** Le navigateur télécharge le fichier une fois et
le garde en mémoire pour les pages suivantes.

À l''inverse, le CSS en ligne obligerait à répéter le style sur chaque balise,
et le CSS interne à recopier le bloc `<style>` dans chaque page.
', NULL, 25),
      (v_chapitre_id, 'Simulation : la cascade', 5, 'interactif', '{
  "widget": "placements-css",
  "consigne": "La même page reçoit trois règles contradictoires, une en ligne, une interne et une externe. Active-les et désactive-les à volonté, et vois la couleur du paragraphe changer selon celle qui gagne. La simulation affiche à chaque fois l''ordre de priorité et barre les règles écrasées — c''est la réponse au fameux « mon CSS ne marche pas »."
}', NULL, 10),
      (v_chapitre_id, 'Les propriétés usuelles', 6, 'texte', '
Voici celles qu''on demande. Elles suffisent à habiller une page entière.

### Le texte

| Propriété | Ce qu''elle règle | Exemple |
| --- | --- | --- |
| `color` | la couleur du texte | `color: red;` |
| `font-family` | la police | `font-family: Arial, sans-serif;` |
| `font-size` | la taille | `font-size: 16px;` |
| `font-weight` | l''épaisseur | `font-weight: bold;` |
| `font-style` | l''italique | `font-style: italic;` |
| `text-align` | l''alignement | `text-align: center;` |
| `text-decoration` | le soulignement | `text-decoration: none;` |
| `line-height` | l''interligne | `line-height: 1.6;` |

Dans `font-family`, on écrit **plusieurs polices séparées par des virgules** : si
la première manque sur la machine du visiteur, le navigateur passe à la
suivante. On termine toujours par une famille générique, `sans-serif` ou `serif`.

Et `text-decoration: none;` est la règle qui **enlève le souligné des liens** —
l''une des plus utilisées du web.

### Les couleurs

Trois écritures, toutes acceptées :

```
color: red;                  le nom anglais
color: #ff0000;              le code hexadécimal
color: rgb(255, 0, 0);       les trois composantes rouge, vert, bleu
```

Les trois ci-dessus donnent exactement le même rouge. L''hexadécimal est le plus
répandu : `#000000` est le noir, `#ffffff` le blanc.

### Le fond et les bordures

```
background-color: #f0f0f0;
border: 2px solid black;
border-radius: 8px;
```

La propriété `border` demande **trois valeurs dans l''ordre** : l''épaisseur, le
style — `solid`, `dashed`, `dotted` — et la couleur.

### Les espaces : la distinction à comprendre

C''est le point sur lequel tout le monde se trompe, et il tombe en examen.

**`padding`** est l''espace **intérieur**, entre le bord de l''élément et son
contenu.

**`margin`** est l''espace **extérieur**, entre l''élément et ses voisins.

```
padding: 10px;
margin: 20px;
```

Tu reconnais le `cellpadding` et le `cellspacing` des tableaux : c''est la même
idée, généralisée à tous les éléments.

Pour s''en souvenir : le *padding* est le **rembourrage** d''une veste, à
l''intérieur ; la *marge* d''un cahier est à l''extérieur du texte.

### Les dimensions

```
width: 300px;
height: 200px;
width: 80%;
```

Un pourcentage se rapporte à l''élément **conteneur**, ce qui rend la page
souple : `width: 80%` occupe 80 % de la largeur disponible, quelle que soit la
taille de l''écran.

---

**Exercice corrigé**

*Écrire une feuille de style externe qui donne à la page un fond gris très
clair, met le texte en Arial, affiche les titres de niveau 1 en bleu foncé et
centrés, et présente les paragraphes de classe « encadre » dans un cadre noir
avec du blanc autour du texte.*

**Correction.** Dans un fichier `style.css` :

```
/* Toute la page */
body {
    background-color: #f5f5f5;
    font-family: Arial, Helvetica, sans-serif;
    line-height: 1.6;
}

/* Les grands titres */
h1 {
    color: #003366;
    text-align: center;
}

/* Les paragraphes encadrés */
p.encadre {
    border: 2px solid black;
    padding: 12px;
    margin: 16px 0;
    background-color: white;
}
```

Et dans le `head` de chaque page :

```
<link rel="stylesheet" href="style.css">
```

Les décisions à justifier.

Le fond et la police sont posés sur **`body`**, et non répétés sur chaque
élément : ils se transmettent à tout ce qu''il contient. C''est ce qu''on appelle
l''héritage, et cela évite beaucoup de lignes.

Le **`padding: 12px`** met le blanc **à l''intérieur** du cadre, comme demandé —
« du blanc autour du texte ». Avec `margin`, l''espace se serait trouvé à
l''extérieur du cadre, et le texte collerait à la bordure. C''est précisément la
distinction de la leçon.

Le `margin: 16px 0` donne 16 pixels en haut et en bas, zéro à gauche et à
droite : quand on donne deux valeurs, la première vaut pour le haut et le bas, la
seconde pour les côtés.
', NULL, 28),
      (v_chapitre_id, 'Simulation : habiller une page', 7, 'interactif', '{
  "widget": "feuille-style",
  "consigne": "Une page brute et une vingtaine de curseurs : couleur, police, taille, alignement, bordure, padding, margin, largeur. Règle-les et vois la page se transformer, avec le code CSS correspondant qui s''écrit tout seul à côté. Les zones de padding et de margin sont coloriées différemment autour de l''élément, ce qui est le moyen le plus rapide de ne plus jamais les confondre."
}', NULL, 10),
      (v_chapitre_id, 'Quiz du chapitre 17', 8, 'quiz', '{
  "titre": "Vérifie que tu as compris",
  "questions": [
    {
      "question": "Que signifie le sigle CSS ?",
      "choix": [
        "Computer Style System",
        "Cascading Style Sheets",
        "Creative Style Sheets",
        "Common Style Syntax"
      ],
      "bonne": 1,
      "explication": "Feuilles de style en cascade. Le HTML dit ce qu''il y a, le CSS dit à quoi cela ressemble."
    },
    {
      "question": "Dans la règle h1 { color: red; }, comment s''appelle h1 ?",
      "choix": [
        "La propriété",
        "La valeur",
        "Le sélecteur",
        "La déclaration"
      ],
      "bonne": 2,
      "explication": "Le sélecteur dit QUI est visé, la propriété color dit QUOI est changé, la valeur red dit COMMENT."
    },
    {
      "question": "Quelle est la différence entre un sélecteur de classe et un sélecteur d''identifiant ?",
      "choix": [
        "Aucune",
        "La classe s''écrit avec un point et peut servir plusieurs fois ; l''identifiant s''écrit avec un dièse et doit être unique dans la page",
        "La classe s''écrit avec un dièse",
        "L''identifiant ne marche qu''en CSS externe"
      ],
      "bonne": 1,
      "explication": "Point pour une classe réutilisable, dièse pour un identifiant unique. Et la règle ne fait rien si la classe n''est pas posée dans le HTML."
    },
    {
      "question": "Quelles sont les trois façons de placer du CSS ?",
      "choix": [
        "En ligne, interne et externe",
        "En haut, au milieu et en bas",
        "Simple, double et triple",
        "Local, global et distant"
      ],
      "bonne": 0,
      "explication": "En ligne dans l''attribut style, interne dans une balise style du head, externe dans un fichier .css relié par link."
    },
    {
      "question": "Pour un site de plusieurs pages, quelle méthode faut-il préférer ?",
      "choix": [
        "Le CSS en ligne",
        "Le CSS interne",
        "Le CSS externe",
        "Peu importe"
      ],
      "bonne": 2,
      "explication": "Une seule source pour tout le site, une seule correction à faire, et le navigateur garde le fichier en mémoire pour les pages suivantes."
    },
    {
      "question": "Trois règles visent le même paragraphe, une en ligne, une interne, une externe. Laquelle gagne ?",
      "choix": [
        "L''externe",
        "L''interne",
        "Celle en ligne, car la plus proche de l''élément l''emporte",
        "La première écrite"
      ],
      "bonne": 2,
      "explication": "C''est la cascade : en ligne bat interne, qui bat externe. Et à provenance égale, la dernière règle écrite gagne."
    },
    {
      "question": "Quelle est la différence entre padding et margin ?",
      "choix": [
        "Aucune",
        "padding est l''espace intérieur, entre le bord et le contenu ; margin est l''espace extérieur, entre l''élément et ses voisins",
        "padding concerne le texte, margin les images",
        "margin est l''épaisseur de la bordure"
      ],
      "bonne": 1,
      "explication": "Le padding est le rembourrage d''une veste, à l''intérieur ; la marge d''un cahier est à l''extérieur du texte. C''est la même idée que cellpadding et cellspacing."
    }
  ]
}', NULL, 5);

    RAISE NOTICE '% : 8 leçons ajoutées au chapitre 17, Les feuilles de style CSS.', v_nom;
  END LOOP;
END $inf1$;
