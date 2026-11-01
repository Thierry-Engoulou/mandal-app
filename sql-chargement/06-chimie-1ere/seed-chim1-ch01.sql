-- ---------------------------------------------------------------------------
-- M'Andal — Chimie, classes de Première
-- Chapitre 1 : Introduction : analyser un composé organique
-- Module 1 : Chimie organique — 10 leçons
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
    WHERE programme_id = v_programme_id AND ordre = 1;

    IF v_chapitre_id IS NULL THEN
      INSERT INTO public.chapitres (programme_id, titre, ordre, niveau)
      VALUES (v_programme_id, 'Introduction : analyser un composé organique', 1, 'Module 1 : Chimie organique')
      RETURNING id INTO v_chapitre_id;
      RAISE NOTICE '% : chapitre 1 créé.', v_nom;
    END IF;

    -- Les leçons. Si le chapitre en a déjà, on passe son tour sans rien toucher.
    SELECT count(*) INTO v_deja FROM public.concepts WHERE chapitre_id = v_chapitre_id;
    IF v_deja > 0 THEN
      RAISE NOTICE '% : le chapitre 1 a déjà ses % leçons, je n''y touche pas.', v_nom, v_deja;
      CONTINUE;
    END IF;

    INSERT INTO public.concepts
      (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes) VALUES
      (v_chapitre_id, 'Qu''est-ce que la chimie organique ?', 1, 'texte', '
Regarde autour de toi pendant dix secondes. Le sachet d''eau que tu tiens, le
stylo avec lequel tu écris, le savon dans la salle de bain, l''essence du
moto-taxi, la canne à sucre que tu as mâchée hier : tous ces corps ont un point
commun, ils contiennent du **carbone**.

La **chimie organique** est la partie de la chimie qui étudie les composés
contenant l''élément carbone. L''autre partie, qui étudie les composés tirés de
la matière inerte, s''appelle la chimie minérale ou chimie inorganique.

### Pourquoi « organique » ?

Au départ, on pensait que ces composés ne pouvaient venir que des organismes
vivants, animaux ou végétaux. D''où le nom. On sait aujourd''hui qu''on peut les
fabriquer au laboratoire, et c''est même ce qui rend cette chimie si importante :
elle permet de synthétiser des corps utiles que la nature produit trop
lentement ou en trop petite quantité.

### Deux familles d''exemples

Les composés organiques **naturels** : le sucre de la canne à sucre, le lait, le
butane de ta bouteille de gaz, le pétrole de Limbé, l''huile de palme.

Les composés organiques **artificiels** : les matières plastiques des bassines,
le coton des tissus, les insecticides des champs, les médicaments du dispensaire.

### Attention à un piège

Tout composé organique contient du carbone, mais **tout composé contenant du
carbone n''est pas organique**. Les oxydes de carbone $CO$ et $CO_2$, les
carbonates comme $CaCO_3$, les cyanures comme $CN^-$ et les carbures métalliques
comme $CaC_2$ contiennent du carbone et restent pourtant de la chimie minérale.
C''est une question que les correcteurs aiment poser au probatoire.

### Un mot de vocabulaire à retenir dès maintenant

On appelle **hydrocarbure** tout composé qui ne contient **que** du carbone et de
l''hydrogène. Sa formule générale s''écrit $C_xH_y$, avec $x$ et $y$ entiers non
nuls. Le méthane $CH_4$, le butane $C_4H_{10}$ et l''acétylène $C_2H_2$ sont des
hydrocarbures ; l''éthanol $C_2H_6O$, qui contient de l''oxygène, n''en est pas un.

---

**Exercice corrigé**

*Parmi les corps suivants, lesquels sont organiques ? Lesquels sont des
hydrocarbures ?*
$CH_4$ — $CaCO_3$ — $C_2H_5OH$ — $CO_2$ — $C_6H_6$ — $CH_3COOH$

**Correction.**
Organiques : $CH_4$, $C_2H_5OH$, $C_6H_6$ et $CH_3COOH$, car tous contiennent du
carbone engagé dans des liaisons covalentes avec l''hydrogène.
Non organiques : $CaCO_3$ et $CO_2$, qui font exception à la règle comme on vient
de le voir.
Hydrocarbures : seulement $CH_4$ et $C_6H_6$. L''éthanol et l''acide éthanoïque
contiennent de l''oxygène, ils sont organiques mais ne sont pas des hydrocarbures.
', NULL, 18),
      (v_chapitre_id, 'Simulation : organique ou minéral ?', 2, 'interactif', '{
  "widget": "organique-mineral",
  "consigne": "Un bac te présente des échantillons : du sucre, du sel, de l''huile de palme, du calcaire, de l''essence, de l''eau. Chauffe-les un par un et regarde lesquels noircissent puis brûlent. La simulation affiche ensuite la formule de chacun et te laisse trier toi-même les deux familles. Tu découvriras au passage les deux intrus classiques, le dioxyde de carbone et les carbonates, qui contiennent du carbone sans être organiques."
}', NULL, 10),
      (v_chapitre_id, 'Les quatre caractères des composés organiques', 3, 'texte', '
Avant même de faire la moindre analyse, quatre propriétés physico-chimiques
permettent de deviner qu''on a affaire à un composé organique.

### 1. Ce sont des composés moléculaires

Leurs atomes sont liés par des **liaisons covalentes**, pas par des liaisons
ioniques. Il n''y a donc ni ions ni réseau cristallin ionique : le sucre fondu ne
conduit pas le courant, contrairement au sel fondu.

### 2. Ils sont en général peu solubles dans l''eau

Verse de l''huile dans un verre d''eau : elle flotte et ne se mélange pas. En
revanche, ils se dissolvent bien dans les solvants organiques comme l''essence ou
l''acétone. C''est pourquoi on nettoie une tache de graisse à l''essence et non à
l''eau.

### 3. Ils ont une faible stabilité thermique

Ils se décomposent quand on les chauffe. Cette décomposition par la chaleur
porte un nom qu''il faut connaître : la **pyrolyse**. C''est aussi la raison pour
laquelle ils sont, pour la plupart, de **bons combustibles** : le bois, le
charbon, l''essence, le gaz butane.

### 4. Leurs réactions sont lentes et souvent réversibles

Une réaction minérale entre ions est quasi instantanée : verse du nitrate
d''argent dans du chlorure de sodium, le précipité blanc apparaît aussitôt. Une
réaction organique, elle, demande des heures, parfois des jours, et elle
s''arrête souvent avant d''être complète. Tu retrouveras cette idée en Terminale
avec la cinétique chimique.

---

**Exercice corrigé**

*On dispose de deux poudres blanches, l''une de sel de cuisine $NaCl$, l''autre de
sucre $C_{12}H_{22}O_{11}$. Propose deux expériences simples pour les
distinguer sans les goûter.*

**Correction.**
*Première expérience, le chauffage.* On chauffe un peu de chaque poudre dans une
cuillère. Le sucre noircit, fond puis dégage une odeur de caramel brûlé : c''est
la pyrolyse, signe d''un composé organique. Le sel, lui, ne change pas d''aspect
aux températures atteintes par une flamme ordinaire.

*Seconde expérience, la conductivité.* On dissout chaque poudre dans l''eau et
l''on plonge les électrodes d''un testeur. La solution de sel conduit le courant,
parce qu''elle contient les ions $Na^+$ et $Cl^-$. La solution de sucre ne le
conduit pas : les molécules de sucre restent entières et ne libèrent aucun ion.
', NULL, 15),
      (v_chapitre_id, 'Simulation : les quatre caractères', 4, 'interactif', '{
  "widget": "caracteres-organiques",
  "consigne": "Mets un composé organique à l''épreuve : chauffe-le et il se décompose bien avant qu''un composé minéral ne bronche ; mets-le dans l''eau puis dans l''essence et regarde où il se dissout ; branche l''ohmmètre et constate qu''il ne conduit pas. Compare chaque fois avec le sel de cuisine, posé dans l''autre bécher : c''est le contraste qui fixe les quatre caractères dans la mémoire."
}', NULL, 10),
      (v_chapitre_id, 'Figure : les trois tests d''identification des éléments', 5, 'figure', '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 560 250" width="560" height="250">
<rect width="560" height="250" fill="#ffffff"/>
<text x="280" y="22" text-anchor="middle" font-size="14" font-weight="700" fill="#0f172a">Les trois tests qui révèlent les éléments d&apos;un composé organique</text>

<g>
<rect x="18" y="44" width="168" height="186" rx="8" fill="#eff6ff" stroke="#2563eb" stroke-width="1.6"/>
<text x="102" y="66" text-anchor="middle" font-size="12" font-weight="700" fill="#2563eb">CARBONE</text>
<path d="M78 92 l24 -26 l24 26 z" fill="#f59e0b"/>
<rect x="86" y="92" width="32" height="30" fill="#cbd5e1"/>
<text x="102" y="112" text-anchor="middle" font-size="9" fill="#0f172a">échantillon</text>
<path d="M60 150 q42 -18 84 0" fill="none" stroke="#64748b" stroke-width="1.6"/>
<ellipse cx="102" cy="168" rx="42" ry="16" fill="#e0f2fe" stroke="#0369a1" stroke-width="1.4"/>
<text x="102" y="172" text-anchor="middle" font-size="9" fill="#0369a1">eau de chaux</text>
<text x="102" y="200" text-anchor="middle" font-size="10" fill="#0f172a">elle se trouble</text>
<text x="102" y="216" text-anchor="middle" font-size="10" font-weight="700" fill="#16a34a">→ CO₂, donc carbone</text>
</g>

<g>
<rect x="196" y="44" width="168" height="186" rx="8" fill="#f0fdf4" stroke="#16a34a" stroke-width="1.6"/>
<text x="280" y="66" text-anchor="middle" font-size="12" font-weight="700" fill="#16a34a">HYDROGÈNE</text>
<rect x="244" y="86" width="72" height="26" rx="4" fill="#cbd5e1"/>
<text x="280" y="103" text-anchor="middle" font-size="9" fill="#0f172a">composé + CuO</text>
<path d="M280 118 l0 24" stroke="#64748b" stroke-width="1.6"/>
<polygon points="280,148 275,138 285,138" fill="#64748b"/>
<rect x="238" y="152" width="84" height="26" rx="4" fill="#ffffff" stroke="#64748b" stroke-width="1.4"/>
<text x="280" y="169" text-anchor="middle" font-size="9" fill="#0f172a">CuSO₄ anhydre</text>
<text x="280" y="200" text-anchor="middle" font-size="10" fill="#0f172a">il bleuit</text>
<text x="280" y="216" text-anchor="middle" font-size="10" font-weight="700" fill="#16a34a">→ H₂O, donc hydrogène</text>
</g>

<g>
<rect x="374" y="44" width="168" height="186" rx="8" fill="#fef3c7" stroke="#b45309" stroke-width="1.6"/>
<text x="458" y="66" text-anchor="middle" font-size="12" font-weight="700" fill="#b45309">AZOTE</text>
<rect x="422" y="86" width="72" height="26" rx="4" fill="#cbd5e1"/>
<text x="458" y="103" text-anchor="middle" font-size="9" fill="#0f172a">composé + chaux sodée</text>
<path d="M458 118 l0 24" stroke="#64748b" stroke-width="1.6"/>
<polygon points="458,148 453,138 463,138" fill="#64748b"/>
<rect x="416" y="152" width="84" height="26" rx="4" fill="#ffffff" stroke="#64748b" stroke-width="1.4"/>
<text x="458" y="169" text-anchor="middle" font-size="9" fill="#0f172a">réactif de Nessler</text>
<text x="458" y="200" text-anchor="middle" font-size="10" fill="#0f172a">il vire au marron</text>
<text x="458" y="216" text-anchor="middle" font-size="10" font-weight="700" fill="#b45309">→ NH₃, donc azote</text>
</g>
</svg>', NULL, 5),
      (v_chapitre_id, 'Rechercher le carbone, l''hydrogène et l''azote', 6, 'texte', '
L''**analyse qualitative** répond à une seule question : quels éléments ce
composé contient-il ? On ne cherche pas encore combien il y en a, seulement
lesquels. Trois tests suffisent pour les trois éléments les plus fréquents.

### Le carbone : la combustion

On fait brûler la substance.

Si la combustion est **incomplète**, faute de dioxygène, la flamme est **jaune et
fuligineuse**. En plaçant une soucoupe sèche au-dessus, elle se couvre d''un dépôt
noir pulvérulent : c''est le carbone lui-même.

Si la combustion est **complète**, la flamme est **bleu pâle**. On recouvre alors
la flamme d''un verre dont les parois sont mouillées d''eau de chaux : l''eau de
chaux **se trouble**. Ce trouble signe la présence de dioxyde de carbone, donc de
carbone dans le composé de départ.

### L''hydrogène : le sulfate de cuivre anhydre

On mélange la substance à de l''oxyde de cuivre $CuO$, puis on chauffe. Si le
composé contient de l''hydrogène, celui-ci est oxydé en eau. La vapeur d''eau
produite est dirigée sur du **sulfate de cuivre anhydre**, une poudre blanche,
qui **bleuit** aussitôt. Ce bleuissement est la preuve.

### L''azote : le réactif de Nessler

On chauffe la substance avec de la **chaux sodée**, un mélange de chaux et de
soude, dans un tube à essais. S''il se dégage un gaz qui fait **virer au marron**
le réactif de Nessler, ce gaz est l''ammoniac $NH_3$, et le composé contenait donc
de l''azote. C''est exactement ce qu''on observe avec l''urée.

### Et l''oxygène ?

On ne le cherche pas directement. Il n''existe pas de test simple. On déduira sa
présence par différence, au moment de l''analyse quantitative. Retiens-le :
**l''oxygène ne se dose jamais directement**.

---

**Exercice corrigé**

*Bouba chauffe un échantillon d''urée avec de la chaux sodée. Un gaz se dégage et
fait virer au marron le réactif de Nessler. Il brûle ensuite un autre
échantillon : l''eau de chaux se trouble, et du sulfate de cuivre anhydre placé
sur le trajet des vapeurs bleuit. Quels éléments l''urée contient-elle à coup
sûr ?*

**Correction.**
Le virage au marron du réactif de Nessler prouve un dégagement d''ammoniac, donc
la présence d''**azote**.
Le trouble de l''eau de chaux prouve la formation de dioxyde de carbone, donc la
présence de **carbone**.
Le bleuissement du sulfate de cuivre anhydre prouve la formation d''eau, donc la
présence d''**hydrogène**.
L''urée contient donc à coup sûr C, H et N. Rien dans ces expériences ne permet
de conclure sur l''oxygène : il faudra l''analyse quantitative. La formule réelle
de l''urée est d''ailleurs $CO(NH_2)_2$, et elle contient bien de l''oxygène.
', NULL, 20),
      (v_chapitre_id, 'Simulation : les trois tests d''identification', 7, 'interactif', '{
  "widget": "tests-elements",
  "consigne": "Choisis un composé, lance les trois tests et observe le résultat de chacun. Cherche ensuite un composé qui contient de l''oxygène : tu verras qu''aucun des trois tests ne le détecte, et c''est bien le problème que l''analyse quantitative devra résoudre."
}', NULL, 10),
      (v_chapitre_id, 'L''analyse quantitative : du gaz recueilli aux pourcentages', 8, 'texte', '
On sait maintenant **quels** éléments sont présents. L''**analyse quantitative**
répond à la question suivante : en quelle proportion ?

### Le principe de la manipulation

On sèche soigneusement le composé pour chasser toute l''eau qu''il pourrait
retenir, on le **pèse** — soit une masse $m$ — puis on l''oxyde complètement. Trois
produits sont alors recueillis séparément.

Le carbone devient du dioxyde de carbone $CO_2$, absorbé par une masse connue de
**potasse**. La potasse s''alourdit exactement de la masse de $CO_2$ formée.

L''hydrogène devient de l''eau $H_2O$, absorbée par de l''**acide sulfurique** ou de
la ponce sulfurique. Le tube s''alourdit de la masse d''eau formée.

L''azote devient du diazote $N_2$, dont on mesure le **volume** dans les conditions
de l''expérience.

L''oxygène, lui, ne se dose pas. On l''obtient à la fin, par différence.

### La formule du pourcentage de carbone

Dans une mole de $CO_2$, de masse $M_{CO_2} = 44$ g/mol, il y a une mole de
carbone, de masse $M_C = 12$ g/mol. Les masses se partagent donc dans le même
rapport :

$$\frac{m_C}{m_{CO_2}} = \frac{M_C}{M_{CO_2}} = \frac{12}{44} = \frac{3}{11}$$

D''où la masse de carbone contenue dans la prise d''essai, puis son pourcentage :

$$m_C = \frac{3}{11}\,m_{CO_2} \qquad \text{et} \qquad \%C = \frac{3}{11}\times\frac{m_{CO_2}}{m}\times 100$$

### La formule du pourcentage d''hydrogène

Même raisonnement avec l''eau. Dans une mole d''eau, de masse 18 g/mol, il y a deux
moles d''hydrogène, soit 2 g :

$$\frac{m_H}{m_{H_2O}} = \frac{2}{18} = \frac{1}{9}
\qquad \text{d''où} \qquad \%H = \frac{1}{9}\times\frac{m_{H_2O}}{m}\times 100$$

### Et l''oxygène, enfin

$$\%O = 100 - \%C - \%H - \%N$$

Ces trois formules sont à connaître par cœur. Les fractions $\frac{3}{11}$ et
$\frac{1}{9}$ reviennent dans presque tous les exercices de probatoire.

---

**Exercice corrigé**

*La combustion complète de 0,850 g d''un composé organique azoté produit 1,660 g
de dioxyde de carbone et 1,150 g d''eau. Par ailleurs, le traitement de 0,850 g de
ce composé fournit 0,321 g d''ammoniac. Détermine les pourcentages massiques de
carbone, d''hydrogène et d''azote, puis dis si le composé contient de l''oxygène.*

**Correction.**

*Carbone.*
$$\%C = \frac{3}{11}\times\frac{1{,}660}{0{,}850}\times 100 = \frac{3\times 166{,}0}{11\times 0{,}850} \approx 53{,}3\,\%$$

*Hydrogène.*
$$\%H = \frac{1}{9}\times\frac{1{,}150}{0{,}850}\times 100 \approx 15{,}0\,\%$$

*Azote.* Dans une mole d''ammoniac $NH_3$, de masse 17 g/mol, il y a 14 g d''azote :
$$m_N = \frac{14}{17}\times 0{,}321 \approx 0{,}264\ \text{g}
\qquad \%N = \frac{0{,}264}{0{,}850}\times 100 \approx 31{,}1\,\%$$

*Oxygène.*
$$\%O = 100 - 53{,}3 - 15{,}0 - 31{,}1 = 0{,}6\,\%$$

Ce reste est inférieur à l''incertitude des pesées : on conclut que le composé
**ne contient pas d''oxygène**. Retiens ce réflexe, car il revient souvent : un
pourcentage résiduel de moins de 1 % se lit comme un zéro, pas comme une trace.
', NULL, 25),
      (v_chapitre_id, 'Simulation : de la combustion aux pourcentages', 9, 'interactif', '{
  "widget": "analyse-elementaire",
  "consigne": "Règle la masse de l''échantillon, puis les masses de dioxyde de carbone et d''eau recueillies. Les pourcentages se calculent sous tes yeux. Cherche une combinaison qui donne un pourcentage d''oxygène nul : tu viens de trouver un hydrocarbure."
}', NULL, 10),
      (v_chapitre_id, 'Quiz du chapitre 1', 10, 'quiz', '{
  "titre": "Vérifie que tu as compris",
  "questions": [
    {
      "question": "Lequel de ces composés n''est PAS organique ?",
      "choix": [
        "$CH_4$",
        "$C_2H_5OH$",
        "$CaCO_3$",
        "$CH_3COOH$"
      ],
      "bonne": 2,
      "explication": "Les carbonates font exception : ils contiennent du carbone mais relèvent de la chimie minérale, au même titre que $CO$, $CO_2$ et les cyanures."
    },
    {
      "question": "On brûle un composé et l''eau de chaux placée au-dessus se trouble. Qu''est-ce que cela prouve ?",
      "choix": [
        "Le composé contient de l''hydrogène",
        "Le composé contient du carbone",
        "Le composé contient de l''azote",
        "Le composé contient de l''oxygène"
      ],
      "bonne": 1,
      "explication": "Le trouble de l''eau de chaux signe le dioxyde de carbone, donc la présence de carbone dans le composé de départ."
    },
    {
      "question": "Que devient une poudre de sulfate de cuivre anhydre en présence de vapeur d''eau ?",
      "choix": [
        "Elle noircit",
        "Elle bleuit",
        "Elle vire au marron",
        "Elle ne change pas"
      ],
      "bonne": 1,
      "explication": "Le sulfate de cuivre anhydre est blanc et bleuit en s''hydratant. C''est le test de l''élément hydrogène."
    },
    {
      "question": "Pourquoi ne cherche-t-on jamais l''oxygène directement ?",
      "choix": [
        "Parce qu''il est trop rare",
        "Parce qu''il n''existe pas de test simple, on le déduit par différence",
        "Parce qu''il s''évapore",
        "Parce qu''il n''est jamais présent"
      ],
      "bonne": 1,
      "explication": "Aucun réactif simple ne révèle l''oxygène d''un composé organique. On calcule son pourcentage en retranchant de 100 ceux des autres éléments."
    },
    {
      "question": "La combustion de 1,00 g d''un composé donne 2,20 g de dioxyde de carbone. Quel est le pourcentage de carbone ?",
      "choix": [
        "22 %",
        "44 %",
        "60 %",
        "ature 73 %"
      ],
      "bonne": 2,
      "explication": "$\\%C = \\frac{3}{11}\\times\\frac{2{,}20}{1{,}00}\\times 100 = \\frac{3\\times 220}{11} = 60\\,\\%$."
    },
    {
      "question": "Comment s''appelle la décomposition d''un composé organique sous l''effet de la chaleur ?",
      "choix": [
        "L''hydrolyse",
        "L''électrolyse",
        "La pyrolyse",
        "La combustion"
      ],
      "bonne": 2,
      "explication": "La pyrolyse est la décomposition thermique. Elle découle de la faible stabilité thermique des composés organiques."
    }
  ]
}', NULL, 5);

    RAISE NOTICE '% : 10 leçons ajoutées au chapitre 1, Introduction : analyser un composé organique.', v_nom;
  END LOOP;
END $ch1$;
