-- ---------------------------------------------------------------------------
-- M'Andal — Chimie, classes de Première
-- Chapitre 6 : Les alcènes et les alcynes : structure et nomenclature
-- Module 1 : Chimie organique — 9 leçons
--
-- Ce fichier remplit les trois séries d'un coup : la 1ère C, la 1ère D et la
-- 1ère E. Il n'a besoin de rien d'autre pour tourner. Si la matière, les
-- classes, les programmes ou le chapitre n'existent pas encore, il les crée
-- lui-même au passage.
--
-- Lancez-le quand vous voulez, dans l'ordre que vous voulez, et autant de fois
-- que vous voulez : quand le chapitre a déjà ses leçons, le script s'en rend
-- compte et n'ajoute rien.
-- ---------------------------------------------------------------------------
DO $ch1$
DECLARE
  v_lettres text[] := ARRAY['C', 'D', 'E'];
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
  INSERT INTO public.matieres (nom) VALUES ('Chimie') ON CONFLICT (nom) DO NOTHING;
  SELECT id INTO v_matiere_id FROM public.matieres WHERE nom = 'Chimie';

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
    WHERE p.titre = 'Chimie — ' || v_nom;

    -- Non : on le crée, et la classe avec si besoin.
    IF v_programme_id IS NULL THEN
      -- La classe a pu être écrite de plusieurs façons : 1ère C, 1ere C, Première C.
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
      VALUES (v_matiere_id, v_classe_id, v_etab_id, 'Chimie — ' || v_nom,
              'Programme officiel de Chimie, classe de Première ' || v_lettre ||
              ' (Cameroun) — 3 modules, 19 chapitres.')
      RETURNING id INTO v_programme_id;
      RAISE NOTICE 'Programme de Chimie de la % : créé.', v_nom;
    END IF;

    -- Le chapitre lui-même.
    SELECT id INTO v_chapitre_id FROM public.chapitres
    WHERE programme_id = v_programme_id AND ordre = 6;

    IF v_chapitre_id IS NULL THEN
      INSERT INTO public.chapitres (programme_id, titre, ordre, niveau)
      VALUES (v_programme_id, 'Les alcènes et les alcynes : structure et nomenclature', 6, 'Module 1 : Chimie organique')
      RETURNING id INTO v_chapitre_id;
      RAISE NOTICE '% : chapitre 6 créé.', v_nom;
    END IF;

    -- Les leçons. Si le chapitre en a déjà, on passe son tour sans rien toucher.
    SELECT count(*) INTO v_deja FROM public.concepts WHERE chapitre_id = v_chapitre_id;
    IF v_deja > 0 THEN
      RAISE NOTICE '% : le chapitre 6 a déjà ses % leçons, je n''y touche pas.', v_nom, v_deja;
      CONTINUE;
    END IF;

    INSERT INTO public.concepts
      (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes) VALUES
      (v_chapitre_id, 'Deux familles insaturées', 1, 'texte', '
Jusqu''ici tous les hydrocarbures que tu as rencontrés étaient **saturés** :
chaque carbone portait le maximum d''hydrogènes possible. Nous allons maintenant
enlever des hydrogènes. La molécule devient **insaturée**, et tout change : sa
forme, sa rigidité, et surtout sa réactivité.

### L''éthylène, le plus simple des alcènes

Sa formule brute est $C_2H_4$. Entre les deux carbones il n''y a plus une, mais
**deux** liaisons : c''est une **double liaison**, encore appelée liaison
éthylénique. Elle n''est pas faite de deux liaisons identiques :

- une liaison $\sigma$ (sigma), **solide**, difficile à rompre ;
- une liaison $\pi$ (pi), **fragile**, facile à rompre.

Retiens bien cette dissymétrie : c''est la liaison $\pi$ qui se casse dans
presque toutes les réactions du chapitre suivant. C''est le point faible de la
molécule, et donc son point d''entrée.

Sa formule semi-développée s''écrit $CH_2 = CH_2$.

Chaque carbone n''a que **trois** voisins : on dit qu''il est **trigonal**. Les
quatre atomes d''hydrogène et les deux carbones sont tous dans un même plan : la
molécule est **plane**. Tous les angles valent **120°**.

$$d(C-H) = 110 \text{ pm} \qquad d(C=C) = 134 \text{ pm}$$

avec $1 \text{ pm} = 10^{-12}$ m.

**Conséquence capitale.** La double liaison **bloque la rotation** autour de
l''axe $C=C$. Dans l''éthane, les deux $CH_3$ tournaient librement l''un par
rapport à l''autre ; ici, rien ne tourne. La molécule est rigide. Tu verras
tout à l''heure que c''est précisément ce blocage qui crée l''isomérie Z/E.

### L''acétylène, le plus simple des alcynes

Sa formule brute est $C_2H_2$. Entre les deux carbones il y a cette fois
**trois** liaisons covalentes : une $\sigma$ et deux $\pi$. L''ensemble forme une
**triple liaison**, dite liaison acétylénique.

Sa formule semi-développée s''écrit $CH \equiv CH$.

Chaque carbone n''a plus que **deux** voisins : il est **digonal**. Les centres
des quatre atomes sont sur une même ligne droite : la molécule est
**linéaire**, l''angle vaut 180°.

$$d(C-H) = 110 \text{ pm} \qquad d(C \equiv C) = 120 \text{ pm}$$

La triple liaison est **plus courte** que la double. Rapproche les trois
valeurs et la règle apparaît toute seule : 154 pm pour $C-C$, 134 pm pour
$C=C$, 120 pm pour $C \equiv C$. Plus il y a de liaisons entre deux carbones,
plus ils sont serrés l''un contre l''autre. La longueur $C-H$, elle, ne bouge
pas.

---

**Exercice corrigé**

*Un élève affirme : « dans l''acétylène, les carbones sont digonaux et la
molécule est rectilinéaire. » A-t-il raison ?*

**Correction.** Oui, sur les deux points.
Les quatre atomes de la molécule sont alignés : la molécule est bien
rectilinéaire. Et chaque atome de carbone n''a que deux voisins — un hydrogène
et l''autre carbone — ce qui est exactement la définition d''un carbone digonal.
', NULL, 22),
      (v_chapitre_id, 'Figure : éthylène et acétylène, deux géométries', 2, 'figure', '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 540 270" width="540" height="270">
<rect width="540" height="270" fill="#ffffff"/>
<text x="270" y="22" text-anchor="middle" font-size="14" font-weight="700" fill="#0f172a">Deux géométries, deux familles</text>

<g transform="translate(140,120)">
  <text x="0" y="-74" text-anchor="middle" font-size="12" font-weight="700" fill="#2563eb">ÉTHYLÈNE C&#8322;H&#8324;</text>
  <line x1="-32" y1="-4" x2="32" y2="-4" stroke="#0f172a" stroke-width="2.4"/>
  <line x1="-32" y1="4" x2="32" y2="4" stroke="#0f172a" stroke-width="2.4"/>
  <line x1="-32" y1="0" x2="-72" y2="-28" stroke="#0f172a" stroke-width="2"/>
  <line x1="-32" y1="0" x2="-72" y2="28" stroke="#0f172a" stroke-width="2"/>
  <line x1="32" y1="0" x2="72" y2="-28" stroke="#0f172a" stroke-width="2"/>
  <line x1="32" y1="0" x2="72" y2="28" stroke="#0f172a" stroke-width="2"/>
  <circle cx="-32" cy="0" r="15" fill="#334155"/>
  <text x="-32" y="5" text-anchor="middle" font-size="12" font-weight="700" fill="#ffffff">C</text>
  <circle cx="32" cy="0" r="15" fill="#334155"/>
  <text x="32" y="5" text-anchor="middle" font-size="12" font-weight="700" fill="#ffffff">C</text>
  <circle cx="-72" cy="-28" r="11" fill="#e2e8f0" stroke="#64748b" stroke-width="1.3"/>
  <text x="-72" y="-24" text-anchor="middle" font-size="10" fill="#0f172a">H</text>
  <circle cx="-72" cy="28" r="11" fill="#e2e8f0" stroke="#64748b" stroke-width="1.3"/>
  <text x="-72" y="32" text-anchor="middle" font-size="10" fill="#0f172a">H</text>
  <circle cx="72" cy="-28" r="11" fill="#e2e8f0" stroke="#64748b" stroke-width="1.3"/>
  <text x="72" y="-24" text-anchor="middle" font-size="10" fill="#0f172a">H</text>
  <circle cx="72" cy="28" r="11" fill="#e2e8f0" stroke="#64748b" stroke-width="1.3"/>
  <text x="72" y="32" text-anchor="middle" font-size="10" fill="#0f172a">H</text>
  <path d="M-52 -20 a26 26 0 0 0 0 40" fill="none" stroke="#2563eb" stroke-width="1.4"/>
  <text x="-76" y="4" text-anchor="middle" font-size="11" font-weight="700" fill="#2563eb">120°</text>
  <text x="0" y="-30" text-anchor="middle" font-size="10" fill="#64748b">C=C : 134 pm</text>
  <text x="0" y="62" text-anchor="middle" font-size="11" font-weight="700" fill="#2563eb">carbone trigonal</text>
  <text x="0" y="78" text-anchor="middle" font-size="11" fill="#334155">molécule PLANE</text>
  <text x="0" y="94" text-anchor="middle" font-size="10" fill="#64748b">pas de rotation possible</text>
</g>

<line x1="275" y1="46" x2="275" y2="232" stroke="#cbd5e1" stroke-width="1.5" stroke-dasharray="4 4"/>

<g transform="translate(405,120)">
  <text x="0" y="-74" text-anchor="middle" font-size="12" font-weight="700" fill="#16a34a">ACÉTYLÈNE C&#8322;H&#8322;</text>
  <line x1="-28" y1="-6" x2="28" y2="-6" stroke="#0f172a" stroke-width="2.2"/>
  <line x1="-28" y1="0" x2="28" y2="0" stroke="#0f172a" stroke-width="2.2"/>
  <line x1="-28" y1="6" x2="28" y2="6" stroke="#0f172a" stroke-width="2.2"/>
  <line x1="-28" y1="0" x2="-82" y2="0" stroke="#0f172a" stroke-width="2"/>
  <line x1="28" y1="0" x2="82" y2="0" stroke="#0f172a" stroke-width="2"/>
  <circle cx="-28" cy="0" r="15" fill="#334155"/>
  <text x="-28" y="5" text-anchor="middle" font-size="12" font-weight="700" fill="#ffffff">C</text>
  <circle cx="28" cy="0" r="15" fill="#334155"/>
  <text x="28" y="5" text-anchor="middle" font-size="12" font-weight="700" fill="#ffffff">C</text>
  <circle cx="-82" cy="0" r="11" fill="#e2e8f0" stroke="#64748b" stroke-width="1.3"/>
  <text x="-82" y="4" text-anchor="middle" font-size="10" fill="#0f172a">H</text>
  <circle cx="82" cy="0" r="11" fill="#e2e8f0" stroke="#64748b" stroke-width="1.3"/>
  <text x="82" y="4" text-anchor="middle" font-size="10" fill="#0f172a">H</text>
  <text x="0" y="-30" text-anchor="middle" font-size="10" fill="#64748b">C&#8801;C : 120 pm</text>
  <text x="-50" y="26" text-anchor="middle" font-size="11" font-weight="700" fill="#16a34a">180°</text>
  <text x="0" y="62" text-anchor="middle" font-size="11" font-weight="700" fill="#16a34a">carbone digonal</text>
  <text x="0" y="78" text-anchor="middle" font-size="11" fill="#334155">molécule LINÉAIRE</text>
  <text x="0" y="94" text-anchor="middle" font-size="10" fill="#64748b">les 4 atomes alignés</text>
</g>

<text x="270" y="252" text-anchor="middle" font-size="10" fill="#64748b">la liaison C&#8801;C est plus courte que C=C, elle-même plus courte que C&#8211;C (154 pm) &#8212; plus il y a de liaisons, plus c&apos;est court</text>
</svg>', NULL, 5),
      (v_chapitre_id, 'Simulation : la géométrie des insaturés', 3, 'interactif', '{
  "widget": "structure-insatures",
  "consigne": "Passe de l''éthane à l''éthylène puis à l''acétylène et regarde la molécule se transformer : l''angle qui va de 109,5° à 120° puis à 180°, la liaison carbone-carbone qui raccourcit, les hydrogènes qui disparaissent deux par deux. Essaie de faire tourner la molécule autour de la liaison centrale : tu ne pourras le faire que sur l''éthane."
}', NULL, 10),
      (v_chapitre_id, 'Formule générale et nomenclature', 4, 'texte', '
### Les définitions

Un **alcène** est un hydrocarbure à chaîne ouverte dont la molécule contient
une double liaison $C=C$.

$$C_nH_{2n} \qquad \text{avec } n \geqslant 2$$

Un **alcyne** est un hydrocarbure à chaîne ouverte dont la molécule contient
une triple liaison $C \equiv C$.

$$C_nH_{2n-2} \qquad \text{avec } n \geqslant 2$$

**Deux pièges d''examen à connaître.**

La formule $C_nH_{2n}$ est aussi celle des **cyclanes**, que tu as vus au
chapitre 4. Un corps de formule $C_5H_{10}$ peut donc être un alcène *ou* un
cyclopentane. La différence : le cyclane a une chaîne fermée.

La formule $C_nH_{2n-2}$ est aussi celle des **diènes**, hydrocarbures à chaîne
ouverte possédant **deux** doubles liaisons. Un corps de formule $C_4H_6$ peut
être le but-1-yne, le but-2-yne, ou le butadiène.

### Les quatre règles pour nommer

Le nom d''un alcène se termine par **-ène**, celui d''un alcyne par **-yne**. La
méthode est la même dans les deux cas :

1. **Chercher la chaîne principale** : la plus longue chaîne carbonée *qui
contient la liaison multiple*. Attention, ce n''est pas forcément la plus longue
chaîne de la molécule.
2. **Numéroter** les carbones de façon à donner le **plus petit indice** au
premier carbone de la liaison multiple. Cette règle passe avant celle des
ramifications.
3. **Indiquer la position** de la liaison multiple par cet indice, placé juste
avant le suffixe.
4. **Nommer les substituants** par ordre alphabétique, avec leur indice.

### Un exemple déroulé

$$^4CH_3 - {}^3CH_2 - {}^2CH = {}^1CH_2$$

Quatre carbones dans la chaîne : racine *but-*. La double liaison part du
carbone n° 1 : indice 1. Nom : **but-1-ène**.

Si on avait numéroté dans l''autre sens, la double liaison serait partie du
carbone 3. On garde 1, qui est plus petit.

---

**Exercice corrigé**

*Nomme le composé* $CH_3-CH(CH_3)-C \equiv C-CH(CH_3)-CH_3$.

**Correction.**
*Chaîne principale.* Six carbones alignés en passant par la triple liaison :
racine *hex-*, suffixe *-yne*.
*Numérotation.* Dans les deux sens, la triple liaison part du carbone 3. On
départage avec les ramifications : deux méthyles en 2 et en 5, dans les deux
sens également.
*Nom.* **2,5-diméthylhex-3-yne**.
', NULL, 25),
      (v_chapitre_id, 'Simulation : nommer un alcène ou un alcyne', 5, 'interactif', '{
  "widget": "nomenclature-alcene",
  "consigne": "Choisis la longueur de la chaîne, place la liaison double ou triple où tu veux, ajoute des ramifications. Le nom systématique se construit sous tes yeux, règle par règle. Fais glisser la liaison multiple d''un carbone vers la droite et observe la numérotation basculer d''un bout à l''autre : c''est la règle du plus petit indice qui s''applique."
}', NULL, 10),
      (v_chapitre_id, 'Les trois isoméries', 6, 'texte', '
Souviens-toi : des **isomères** sont des corps différents qui ont la même
formule brute. Chez les alcanes, il n''y en avait qu''une sorte. Chez les
alcènes, il y en a trois, et c''est la source la plus fréquente d''erreurs aux
épreuves.

### 1. L''isomérie de position

La double liaison n''est pas au même endroit sur la chaîne.

$$CH_3-CH_2-CH=CH_2 \quad \text{but-1-ène}$$
$$CH_3-CH=CH-CH_3 \quad \text{but-2-ène}$$

Même formule brute $C_4H_8$, même squelette, double liaison déplacée.

### 2. L''isomérie de chaîne

Le squelette carboné lui-même change de forme.

$$CH_3-CH_2-CH=CH_2 \quad \text{but-1-ène}$$
$$CH_2=C(CH_3)-CH_3 \quad \text{2-méthylpropène}$$

Même formule brute $C_4H_8$, chaîne linéaire d''un côté, ramifiée de l''autre.

### 3. L''isomérie de configuration, dite Z/E

C''est la nouvelle, et c''est une conséquence directe du blocage de la rotation.
Puisque la double liaison empêche les deux carbones de tourner l''un par rapport
à l''autre, les groupes qu''ils portent restent figés de part et d''autre du plan.
Il y a donc deux façons de les disposer.

Pour le but-2-ène :

- si les deux $CH_3$ sont **du même côté**, c''est le **(Z)-but-2-ène**. Z vient
de l''allemand *zusammen*, qui veut dire « ensemble ».
- s''ils sont **de part et d''autre**, c''est le **(E)-but-2-ène**. E vient de
*entgegen*, « opposé ».

On appelle aussi ces deux corps des **stéréo-isomères**, ou isomères de
configuration. L''ancienne appellation était l''isomérie *cis/trans*.

**Deux avertissements.**

Ces deux corps ont des **propriétés différentes** : températures d''ébullition,
stabilité, réactivité. Ce ne sont pas deux dessins de la même chose.

Un alcène ne présente l''isomérie Z/E que si **chacun** des deux carbones de la
double liaison porte **deux groupes différents**. Le 2-méthylbut-2-ène
$CH_3-C(CH_3)=CH-CH_3$ n''en présente pas : le carbone n° 2 porte deux méthyles
identiques, donc les retourner ne change rien.

**Les alcynes, eux, n''ont pas d''isomérie Z/E.** Ils présentent des isoméries de
position et de chaîne, mais la triple liaison est linéaire : il n''y a aucun
« côté ».

---

**Exercice corrigé**

*Parmi ces trois alcènes, lequel présente l''isomérie Z/E ?*
*a) 2,3-diméthylbut-2-ène   b) hex-2-ène   c) 3-méthylpent-1-ène*

**Correction.**
a) Les deux carbones de la double liaison portent chacun deux méthyles
identiques : **non**.
b) $CH_3-CH=CH-CH_2-CH_2-CH_3$. Le premier carbone porte $H$ et $CH_3$, le
second porte $H$ et $C_3H_7$ : tous différents. **Oui**.
c) $CH_2=CH-\ldots$ : le carbone n° 1 porte deux hydrogènes identiques :
**non**.

Seul le **b)** présente l''isomérie Z/E.
', NULL, 25),
      (v_chapitre_id, 'Figure : (Z)-but-2-ène et (E)-but-2-ène', 7, 'figure', '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 540 250" width="540" height="250">
<rect width="540" height="250" fill="#ffffff"/>
<text x="270" y="22" text-anchor="middle" font-size="14" font-weight="700" fill="#0f172a">Deux corps différents pour une même formule : le but-2-ène</text>

<g transform="translate(140,120)">
  <line x1="-26" y1="-4" x2="26" y2="-4" stroke="#0f172a" stroke-width="2.4"/>
  <line x1="-26" y1="4" x2="26" y2="4" stroke="#0f172a" stroke-width="2.4"/>
  <line x1="-26" y1="0" x2="-64" y2="-30" stroke="#dc2626" stroke-width="2.4"/>
  <line x1="-26" y1="0" x2="-64" y2="30" stroke="#0f172a" stroke-width="2"/>
  <line x1="26" y1="0" x2="64" y2="-30" stroke="#dc2626" stroke-width="2.4"/>
  <line x1="26" y1="0" x2="64" y2="30" stroke="#0f172a" stroke-width="2"/>
  <circle cx="-26" cy="0" r="13" fill="#334155"/>
  <text x="-26" y="4" text-anchor="middle" font-size="11" font-weight="700" fill="#ffffff">C</text>
  <circle cx="26" cy="0" r="13" fill="#334155"/>
  <text x="26" y="4" text-anchor="middle" font-size="11" font-weight="700" fill="#ffffff">C</text>
  <text x="-76" y="-30" text-anchor="middle" font-size="11" font-weight="700" fill="#dc2626">CH&#8323;</text>
  <text x="76" y="-30" text-anchor="middle" font-size="11" font-weight="700" fill="#dc2626">CH&#8323;</text>
  <text x="-72" y="40" text-anchor="middle" font-size="11" fill="#0f172a">H</text>
  <text x="72" y="40" text-anchor="middle" font-size="11" fill="#0f172a">H</text>
  <rect x="-92" y="-54" width="184" height="34" fill="none" stroke="#dc2626" stroke-width="1.3" stroke-dasharray="5 4" rx="6"/>
  <text x="0" y="72" text-anchor="middle" font-size="13" font-weight="700" fill="#dc2626">(Z)-but-2-ène</text>
  <text x="0" y="90" text-anchor="middle" font-size="11" fill="#334155">les deux CH&#8323; du MÊME côté</text>
  <text x="0" y="106" text-anchor="middle" font-size="10" fill="#64748b">zusammen = ensemble</text>
</g>

<line x1="275" y1="46" x2="275" y2="212" stroke="#cbd5e1" stroke-width="1.5" stroke-dasharray="4 4"/>

<g transform="translate(405,120)">
  <line x1="-26" y1="-4" x2="26" y2="-4" stroke="#0f172a" stroke-width="2.4"/>
  <line x1="-26" y1="4" x2="26" y2="4" stroke="#0f172a" stroke-width="2.4"/>
  <line x1="-26" y1="0" x2="-64" y2="-30" stroke="#dc2626" stroke-width="2.4"/>
  <line x1="-26" y1="0" x2="-64" y2="30" stroke="#0f172a" stroke-width="2"/>
  <line x1="26" y1="0" x2="64" y2="-30" stroke="#0f172a" stroke-width="2"/>
  <line x1="26" y1="0" x2="64" y2="30" stroke="#dc2626" stroke-width="2.4"/>
  <circle cx="-26" cy="0" r="13" fill="#334155"/>
  <text x="-26" y="4" text-anchor="middle" font-size="11" font-weight="700" fill="#ffffff">C</text>
  <circle cx="26" cy="0" r="13" fill="#334155"/>
  <text x="26" y="4" text-anchor="middle" font-size="11" font-weight="700" fill="#ffffff">C</text>
  <text x="-76" y="-30" text-anchor="middle" font-size="11" font-weight="700" fill="#dc2626">CH&#8323;</text>
  <text x="72" y="-30" text-anchor="middle" font-size="11" fill="#0f172a">H</text>
  <text x="-72" y="40" text-anchor="middle" font-size="11" fill="#0f172a">H</text>
  <text x="78" y="40" text-anchor="middle" font-size="11" font-weight="700" fill="#dc2626">CH&#8323;</text>
  <text x="0" y="72" text-anchor="middle" font-size="13" font-weight="700" fill="#16a34a">(E)-but-2-ène</text>
  <text x="0" y="90" text-anchor="middle" font-size="11" fill="#334155">les deux CH&#8323; de part et d&apos;autre</text>
  <text x="0" y="106" text-anchor="middle" font-size="10" fill="#64748b">entgegen = opposé</text>
</g>

<text x="270" y="236" text-anchor="middle" font-size="10" fill="#64748b">on ne peut pas passer de l&apos;un à l&apos;autre sans casser la double liaison : ce sont bien deux corps distincts</text>
</svg>', NULL, 5),
      (v_chapitre_id, 'Simulation : reconnaître les isomères Z et E', 8, 'interactif', '{
  "widget": "isomerie-ze",
  "consigne": "Change les quatre groupes accrochés à la double liaison, puis essaie de faire basculer l''un des carbones. La simulation te dit à chaque fois si l''isomérie Z/E existe, et pourquoi. Mets deux groupes identiques sur le même carbone : tu verras le verdict passer à « pas de stéréo-isomérie », parce qu''un retournement redonne exactement la même molécule."
}', NULL, 10),
      (v_chapitre_id, 'Quiz du chapitre 6', 9, 'quiz', '{
  "titre": "Vérifie que tu as compris",
  "questions": [
    {
      "question": "Quelle est la formule générale des alcènes ?",
      "choix": [
        "$C_nH_{2n+2}$",
        "$C_nH_{2n}$",
        "$C_nH_{2n-2}$",
        "$C_nH_{n}$"
      ],
      "bonne": 1,
      "explication": "On perd deux hydrogènes par rapport à l''alcane de même nombre de carbones, à cause de la double liaison."
    },
    {
      "question": "Dans la double liaison $C=C$, laquelle des deux liaisons se casse le plus facilement ?",
      "choix": [
        "La liaison $\\sigma$",
        "La liaison $\\pi$",
        "Les deux également",
        "Aucune des deux"
      ],
      "bonne": 1,
      "explication": "La liaison $\\pi$ est fragile. C''est elle qui s''ouvre dans toutes les réactions d''addition du chapitre suivant."
    },
    {
      "question": "Combien vaut l''angle entre deux liaisons dans la molécule d''éthylène ?",
      "choix": [
        "109,5°",
        "120°",
        "180°",
        "90°"
      ],
      "bonne": 1,
      "explication": "Le carbone n''a que trois voisins : il est trigonal, et les trois directions se répartissent à 120° dans un plan."
    },
    {
      "question": "La molécule d''acétylène est dite :",
      "choix": [
        "plane",
        "tétraédrique",
        "linéaire",
        "cyclique"
      ],
      "bonne": 2,
      "explication": "Les centres des quatre atomes sont sur une même droite. Chaque carbone, qui n''a que deux voisins, est digonal."
    },
    {
      "question": "Un corps a pour formule brute $C_5H_{10}$. Que peut-on en conclure ?",
      "choix": [
        "C''est forcément un alcène",
        "C''est forcément un cyclane",
        "C''est un alcène ou un cyclane",
        "C''est un alcyne"
      ],
      "bonne": 2,
      "explication": "$C_nH_{2n}$ est la formule générale des alcènes mais aussi celle des cyclanes, dont la chaîne est fermée."
    },
    {
      "question": "Pourquoi les alcynes ne présentent-ils pas d''isomérie Z/E ?",
      "choix": [
        "Parce qu''ils sont trop réactifs",
        "Parce que la triple liaison est linéaire, donc il n''y a pas de côtés",
        "Parce qu''ils sont trop petits",
        "Parce que la rotation est libre"
      ],
      "bonne": 1,
      "explication": "Pour qu''il y ait un isomère Z et un isomère E, il faut un plan avec deux côtés. La géométrie linéaire de la triple liaison l''interdit."
    },
    {
      "question": "Le 2-méthylbut-2-ène $CH_3-C(CH_3)=CH-CH_3$ présente-t-il des stéréo-isomères ?",
      "choix": [
        "Oui, deux",
        "Non, car un des carbones de la double liaison porte deux groupes identiques",
        "Oui, trois",
        "Non, car c''est un alcyne"
      ],
      "bonne": 1,
      "explication": "Le carbone n° 2 porte deux groupes méthyle. Les permuter redonne la même molécule : il n''y a donc qu''un seul corps."
    }
  ]
}', NULL, 5);

    RAISE NOTICE '% : 9 leçons ajoutées au chapitre 6, Les alcènes et les alcynes : structure et nomenclature.', v_nom;
  END LOOP;
END $ch1$;
