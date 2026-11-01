-- ---------------------------------------------------------------------------
-- M'Andal — Informatique, classes de Première
-- Chapitre 19 : Retouche, trucage et logiciels d'infographie
-- Module 3 : Infographie et multimédia — 7 leçons
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
    WHERE programme_id = v_programme_id AND ordre = 19;

    IF v_chapitre_id IS NULL THEN
      INSERT INTO public.chapitres (programme_id, titre, ordre, niveau)
      VALUES (v_programme_id, 'Retouche, trucage et logiciels d''infographie', 19, 'Module 3 : Infographie et multimédia')
      RETURNING id INTO v_chapitre_id;
      RAISE NOTICE '% : chapitre 19 créé.', v_nom;
    END IF;

    -- Les leçons. Si le chapitre en a déjà, on passe son tour sans rien toucher.
    SELECT count(*) INTO v_deja FROM public.concepts WHERE chapitre_id = v_chapitre_id;
    IF v_deja > 0 THEN
      RAISE NOTICE '% : le chapitre 19 a déjà ses % leçons, je n''y touche pas.', v_nom, v_deja;
      CONTINUE;
    END IF;

    INSERT INTO public.concepts
      (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes) VALUES
      (v_chapitre_id, 'Les logiciels d''infographie', 1, 'texte', '
### Ce qu''est l''infographie

L''**infographie** est l''ensemble des techniques de **création et de traitement
d''images par ordinateur**.

Le mot vient de « informatique » et « graphique ». On y range le dessin, la
retouche de photographies, la mise en page, la création de logos et
d''illustrations.

### Deux familles de logiciels, pour deux sortes d''images

Puisqu''il y a deux façons de représenter une image, il y a deux familles de
logiciels — et c''est le chapitre précédent qui le commande.

| Famille | Logiciels | Pour quoi |
| --- | --- | --- |
| **matriciel** | Photoshop, GIMP, Paint, Paint.NET | retoucher des **photographies** |
| **vectoriel** | Illustrator, Inkscape, CorelDRAW | créer des **logos**, des plans, des illustrations |

Dans chaque ligne, le premier est payant et le deuxième est **libre et
gratuit** : **GIMP** est l''alternative à Photoshop, **Inkscape** celle
d''Illustrator. C''est une information utile dans un établissement camerounais, où
les licences coûtent cher.

On ajoute souvent une troisième famille, la **mise en page** — InDesign,
Publisher, Scribus — pour les affiches, les journaux et les livres.

### L''interface de Photoshop

Le programme demande de connaître les **cinq parties** de l''interface d''un
logiciel de retouche. Prenons Photoshop, qui sert de référence.

**1. La barre de menus**, en haut : Fichier, Édition, Image, Calque, Filtre.
C''est là que se trouvent toutes les commandes.

**2. La barre d''options**, juste en dessous : elle **change selon l''outil
choisi**. Avec le pinceau, elle propose la taille et l''opacité ; avec la
sélection, le mode d''addition.

**3. La boîte à outils**, en colonne sur le côté : sélection, lasso, pinceau,
gomme, texte, pot de peinture, zoom.

**4. La zone de travail**, au centre : l''image elle-même.

**5. Les palettes** — ou fenêtres flottantes — sur le côté : la palette des
calques, celle des couleurs, celle de l''historique.

La plus importante est la **palette des calques**. Nous y venons tout de suite.

---

**Exercice corrigé**

*Citer deux logiciels de traitement d''images matricielles et deux logiciels de
dessin vectoriel, en précisant à chaque fois lequel est gratuit.*

**Correction.**

*Matriciels* : **Adobe Photoshop**, qui est payant, et **GIMP**, qui est libre
et gratuit. On peut aussi citer Paint, livré avec Windows.

*Vectoriels* : **Adobe Illustrator**, payant, et **Inkscape**, libre et gratuit.
On peut aussi citer CorelDRAW, payant.

Et la justification du classement, car c''est elle qu''on attend : les logiciels
matriciels travaillent sur des **grilles de pixels**, ce qui convient aux
photographies ; les logiciels vectoriels travaillent sur des **formes décrites
par des formules**, ce qui convient aux logos et aux dessins qui doivent
s''agrandir.
', NULL, 25),
      (v_chapitre_id, 'Simulation : l''interface d''un logiciel de retouche', 2, 'interactif', '{
  "widget": "interface-photoshop",
  "consigne": "L''interface d''un logiciel de retouche s''affiche, et tu dois nommer ses cinq parties en les cliquant. Chaque bonne réponse déplie ce qu''on y trouve. Choisis ensuite différents outils dans la boîte et regarde la barre d''options changer sous tes yeux : c''est la façon la plus sûre de comprendre pourquoi elle est comptée comme une partie à elle seule."
}', NULL, 10),
      (v_chapitre_id, 'Les opérations de retouche', 3, 'texte', '
Voici les opérations qu''on te demande de connaître et de savoir nommer.

### Le recadrage

**Recadrer** — *crop* — c''est **couper** les bords d''une image pour n''en garder
qu''une partie.

Attention : le recadrage **réduit la définition**, puisqu''on jette des pixels.
Recadrer fortement une petite photo donne une image inutilisable en impression.

### La luminosité et le contraste

La **luminosité** éclaircit ou assombrit **tous** les pixels.

Le **contraste** écarte les clairs des sombres : il rend l''image plus franche,
ou plus douce.

On y ajoute la **saturation**, qui règle l''intensité des couleurs — jusqu''au noir
et blanc quand on la descend à zéro.

### La sélection et le détourage

**Sélectionner**, c''est délimiter une zone pour ne travailler **que** sur elle.
Les outils : le rectangle, le lasso pour les contours libres, et la **baguette
magique**, qui sélectionne d''un clic tous les pixels de couleur voisine.

**Détourer**, c''est isoler un sujet de son arrière-plan, pour le placer
ailleurs. C''est l''opération de base du photomontage, et la plus délicate : les
cheveux et les contours flous sont le cauchemar du retoucheur.

### Les calques

C''est la notion la plus importante du chapitre.

Un **calque** — *layer* — est une **couche transparente** empilée sur les
autres. Chaque élément de l''image vit sur son propre calque, et l''image finale
est ce qu''on voit en regardant la pile par le dessus.

Pense aux feuilles de papier calque qu''on superpose.

L''intérêt est considérable : on peut **déplacer, modifier ou supprimer un
élément sans toucher aux autres**. Sans calques, poser un texte sur une
photographie détruirait les pixels situés dessous ; avec un calque de texte, la
photographie reste intacte en dessous.

Chaque calque a son **opacité**, de 0 à 100 %, et peut être masqué d''un clic.

### Les filtres

Un **filtre** applique un traitement automatique à toute l''image ou à la
sélection : flou, netteté, relief, effet artistique.

Le plus utile en pratique est le **flou gaussien**, et son contraire, le
**renforcement de la netteté**.

### Les transformations

**Redimensionner**, **faire tourner**, **retourner** en miroir,
**incliner**. Dans un redimensionnement, il faut **conserver les proportions**
sous peine de déformer les visages — on verrouille le rapport largeur-hauteur.

---

**Exercice corrigé**

*Vous devez placer le nom d''un élève sur sa photographie de bulletin, et pouvoir
le corriger plus tard en cas de faute de frappe. Comment procédez-vous, et
pourquoi ?*

**Correction.** En plaçant le texte sur un **calque de texte distinct**, au-dessus
du calque de la photographie, et en enregistrant le fichier dans un format qui
**conserve les calques** — le PSD de Photoshop, ou le XCF de GIMP.

Pourquoi. Si l''on écrivait le texte directement sur la photographie, les pixels
du nom **remplaceraient** ceux de l''image. Une correction ultérieure obligerait
à effacer le texte — et donc à reconstituer la portion de photographie cachée
dessous, ce qui est souvent impossible.

Avec un calque de texte, le nom reste un **objet modifiable** : on double-clique
dessus et on le retape, et la photographie en dessous n''a jamais été touchée.

La version à diffuser, elle, sera exportée en JPEG ou en PNG — formats qui, eux,
**aplatissent** les calques en une seule image. Le fichier PSD d''origine est
conservé à côté : c''est la source, le JPEG n''est qu''une copie.
', NULL, 28),
      (v_chapitre_id, 'Simulation : retoucher une photographie', 4, 'interactif', '{
  "widget": "retouche-image",
  "consigne": "Une photographie t''est confiée avec les vrais réglages : luminosité, contraste, saturation, netteté, et un cadre de recadrage à déplacer. La définition restante s''affiche pendant que tu recadres, pour que tu voies les pixels disparaître. Un panneau de calques te laisse empiler un texte et un logo, changer leur opacité, les masquer — puis aplatir l''image et constater que tu ne peux plus rien modifier."
}', NULL, 10),
      (v_chapitre_id, 'Le trucage, le photomontage et l''éthique', 5, 'texte', '
### Le photomontage

Un **photomontage** est une image obtenue en **assemblant plusieurs images**,
ou des parties d''images.

La méthode est toujours la même, et c''est un enchaînement de ce que nous venons
de voir :

1. **détourer** le sujet à déplacer ;
2. le poser sur un **calque** au-dessus de l''image d''accueil ;
3. **redimensionner** et faire tourner pour que l''échelle soit crédible ;
4. harmoniser la **luminosité** et les **couleurs** entre les deux sources ;
5. soigner les **ombres**, qui trahissent presque tous les montages ratés.

C''est l''étape 4 que les débutants sautent, et c''est pourquoi leurs montages se
repèrent au premier regard : le sujet découpé est éclairé par la gauche quand
la scène d''accueil est éclairée par la droite.

### Le trucage

Le **trucage** est la modification d''une image pour **faire croire à quelque
chose qui n''a pas eu lieu**. On enlève une personne d''une photographie, on en
ajoute une, on change un décor, on efface une trace.

Techniquement, c''est le même travail que le photomontage. Ce qui change, c''est
l''**intention** : le photomontage assume d''être une image composée, le trucage
cherche à se faire prendre pour un document authentique.

### La question éthique, qui est au programme

Une image numérique est **modifiable sans trace**. Il n''y a pas de négatif à
confronter, pas de grain du papier à examiner. Cela a deux conséquences
sérieuses.

**L''image n''est plus une preuve en soi.** Avant d''y croire, il faut se demander
**d''où** elle vient et **qui** la diffuse. Une photographie qui circule sur les
réseaux sans source identifiable ne vaut rien comme information — et c''est vrai
pour toutes les images, y compris celles qui confirment ce que nous pensons
déjà.

**Modifier une image a des limites juridiques et morales.** Retoucher la
luminosité d''un portrait est anodin. Mais faire dire ou faire à quelqu''un, en
image, ce qu''il n''a pas dit ni fait peut constituer une **diffamation** ; et
utiliser la photographie d''une personne sans son accord porte atteinte à son
**droit à l''image**.

Il y a enfin le **droit d''auteur** : une image trouvée sur Internet appartient à
quelqu''un. On ne la réutilise pas librement, même en la retouchant. Pour un
devoir ou un site d''établissement, on cherche des images **libres de droits**,
et on **cite** l''auteur quand la licence le demande.

---

**Exercice corrigé**

*Un camarade retire une personne d''une photographie de classe avec Photoshop et
publie l''image sur les réseaux sociaux. Que peut-on dire de cet acte, sur le
plan technique et sur le plan moral ?*

**Correction.**

*Sur le plan technique*, il s''agit d''un **trucage** par retouche. L''opération
consiste à sélectionner la personne, à la supprimer, puis à reconstituer
l''arrière-plan masqué — à l''outil tampon ou au remplissage d''après le contenu.
Bien faite, elle ne laisse **aucune trace visible**, ce qui est précisément le
problème.

*Sur le plan moral et juridique*, l''acte est condamnable à trois titres.

Il **falsifie un document** : la photographie prétend montrer la classe, et elle
la montre incomplète. Toute personne qui la regarde est trompée.

Il porte atteinte à la **dignité** de la personne effacée, qui se voit niée dans
un document collectif. L''effet sur un élève de son âge n''est pas anodin.

Il peut relever du **droit à l''image** de tous les élèves photographiés, dont
l''accord n''a probablement pas été demandé pour une diffusion publique.

La bonne conduite : ne pas publier, et si l''image circule déjà, demander son
retrait. Et la leçon générale : **savoir faire quelque chose techniquement ne
rend pas légitime de le faire.**
', NULL, 28),
      (v_chapitre_id, 'Simulation : réussir ou rater un photomontage', 6, 'interactif', '{
  "widget": "photomontage",
  "consigne": "Deux images te sont données, un sujet et un décor, et les cinq étapes du montage sont à ta main : détourage, échelle, rotation, harmonisation des couleurs, ombre portée. Saute une étape et la simulation note ton montage en te pointant ce qui le trahit — l''éclairage qui vient du mauvais côté, l''ombre manquante, l''échelle invraisemblable. Un mode « détective » te propose ensuite de repérer les trucages dans six images."
}', NULL, 10),
      (v_chapitre_id, 'Quiz du chapitre 19', 7, 'quiz', '{
  "titre": "Vérifie que tu as compris",
  "questions": [
    {
      "question": "Qu''est-ce que l''infographie ?",
      "choix": [
        "La fabrication d''ordinateurs",
        "L''ensemble des techniques de création et de traitement d''images par ordinateur",
        "L''impression de documents",
        "La programmation de sites web"
      ],
      "bonne": 1,
      "explication": "Le mot vient de informatique et graphique. On y range le dessin, la retouche photographique, la mise en page et la création de logos."
    },
    {
      "question": "Quel logiciel libre et gratuit remplace Photoshop ?",
      "choix": [
        "Illustrator",
        "GIMP",
        "Inkscape",
        "CorelDRAW"
      ],
      "bonne": 1,
      "explication": "GIMP est l''alternative gratuite pour le matriciel ; Inkscape est celle d''Illustrator pour le vectoriel."
    },
    {
      "question": "Quelles sont les cinq parties de l''interface d''un logiciel de retouche ?",
      "choix": [
        "Menus, options, boîte à outils, zone de travail, palettes",
        "Fichier, Édition, Image, Calque, Filtre",
        "Entrée, traitement, sortie, calques, filtres",
        "Haut, bas, gauche, droite, centre"
      ],
      "bonne": 0,
      "explication": "La barre d''options est bien comptée à part, parce qu''elle change selon l''outil sélectionné."
    },
    {
      "question": "Qu''est-ce qu''un calque ?",
      "choix": [
        "Un filtre automatique",
        "Une couche transparente empilée sur les autres, qui porte un élément de l''image",
        "Une sélection rectangulaire",
        "Un format de fichier"
      ],
      "bonne": 1,
      "explication": "Comme des feuilles de papier calque superposées. On peut déplacer, modifier ou supprimer un élément sans toucher aux autres."
    },
    {
      "question": "Pourquoi le recadrage réduit-il la qualité d''une image ?",
      "choix": [
        "Il la compresse",
        "Il jette des pixels, donc il diminue la définition",
        "Il change sa résolution en ppp",
        "Il la convertit en JPEG"
      ],
      "bonne": 1,
      "explication": "Recadrer fortement une petite photo donne une image inutilisable en impression : les pixels coupés ne reviennent pas."
    },
    {
      "question": "Quelle étape du photomontage les débutants oublient-ils le plus souvent ?",
      "choix": [
        "Le détourage",
        "L''harmonisation de la luminosité et des couleurs entre les deux sources",
        "Le redimensionnement",
        "L''enregistrement"
      ],
      "bonne": 1,
      "explication": "C''est pourquoi leurs montages se repèrent au premier regard : le sujet découpé est éclairé d''un côté, la scène d''accueil de l''autre."
    },
    {
      "question": "Quelle est la différence entre un photomontage et un trucage ?",
      "choix": [
        "Aucune, c''est la même technique",
        "La technique est la même ; ce qui change est l''intention — le trucage cherche à se faire prendre pour un document authentique",
        "Le trucage est réservé à la vidéo",
        "Le photomontage est illégal"
      ],
      "bonne": 1,
      "explication": "Et comme une image numérique se modifie sans laisser de trace, elle n''est plus une preuve en soi : il faut toujours se demander d''où elle vient."
    }
  ]
}', NULL, 5);

    RAISE NOTICE '% : 7 leçons ajoutées au chapitre 19, Retouche, trucage et logiciels d''infographie.', v_nom;
  END LOOP;
END $inf1$;
