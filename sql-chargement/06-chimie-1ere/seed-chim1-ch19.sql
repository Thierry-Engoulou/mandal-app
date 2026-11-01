-- ---------------------------------------------------------------------------
-- M'Andal — Chimie, classes de Première
-- Chapitre 19 : Oxydoréduction par voie sèche et nombres d'oxydation
-- Module 3 : Oxydoréduction — 12 leçons
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
    WHERE programme_id = v_programme_id AND ordre = 19;

    IF v_chapitre_id IS NULL THEN
      INSERT INTO public.chapitres (programme_id, titre, ordre, niveau)
      VALUES (v_programme_id, 'Oxydoréduction par voie sèche et nombres d''oxydation', 19, 'Module 3 : Oxydoréduction')
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
      (v_chapitre_id, 'La voie sèche et l''électronégativité', 1, 'texte', '
Tout ce module s''est déroulé en solution aqueuse. Mais beaucoup de réactions
importantes — la réduction du minerai de fer dans un haut fourneau, la
combustion du charbon — se produisent sans la moindre goutte d''eau.

### La définition

Une réaction chimique est dite **par voie sèche** lorsqu''elle se déroule en
**l''absence d''eau ou de tout autre solvant**.

### Une différence de fond

Dans une réaction en solution, on suit des électrons qui passent réellement
d''une espèce à l''autre. Par voie sèche, ce transfert n''existe pas vraiment :
il n''y a pas d''ions libres pour les porter. Ce qui se déplace, ce sont les
**doublets d''électrons des liaisons**, qui se rapprochent d''un atome ou
s''en éloignent.

Il nous faut donc un nouvel outil, qui mesure ce déplacement sans parler de
transfert : ce sera le **nombre d''oxydation**. Mais d''abord, deux notions
préalables.

### L''électronégativité

L''**électronégativité** d''un élément est l''**aptitude de cet élément à
conserver ses électrons de valence ou à attirer les électrons de valence d''un
autre élément**.

Où se trouvent les plus électronégatifs ? **En haut et à droite** du tableau de
classification périodique.

Où se trouvent les plus électropositifs ? **En bas et à gauche**.

Les valeurs vont de **4 pour le fluor**, le plus électronégatif de tous, à
**0,8 pour le césium**. L''électronégativité des gaz rares est **nulle** :
ils ne forment pas de liaisons.

### La liaison polarisée

Une **liaison polarisée** est une liaison covalente **dissymétrique** dans
laquelle les électrons sont déplacés vers l''atome le **plus électronégatif**.

Prends le chlorure d''hydrogène $HCl$. Le chlore est plus à droite que
l''hydrogène dans le tableau, donc plus électronégatif. Les électrons de la
liaison sont attirés plus fortement par le chlore que par l''hydrogène : la
répartition des charges n''est pas symétrique, la liaison est polarisée.

C''est exactement ce déplacement que le nombre d''oxydation va chiffrer.

---

**Exercice corrigé**

*Compare les électronégativités du chlore et de l''hydrogène. La liaison dans la
molécule $HCl$ est-elle polarisée ?*

**Correction.** Le chlore étant **plus à droite** que l''hydrogène dans le
tableau de classification périodique, son électronégativité est **plus grande**
que celle de l''hydrogène.
La liaison covalente de la molécule $HCl$ est donc **polarisée** : les
électrons de la liaison sont plus attirés par le chlore que par l''hydrogène, et
la répartition des charges n''est pas symétrique.
', NULL, 22),
      (v_chapitre_id, 'Simulation : qui attire les électrons ?', 2, 'interactif', '{
  "widget": "electronegativite",
  "consigne": "Choisis deux éléments dans le tableau périodique et forme une liaison entre eux. Le doublet d''électrons se déplace sous tes yeux, d''autant plus franchement que l''écart d''électronégativité est grand. Avec deux atomes identiques il reste au milieu : la liaison n''est pas polarisée. Avec le fluor et le césium, aux deux extrémités de l''échelle, il bascule complètement."
}', NULL, 10),
      (v_chapitre_id, 'Le nombre d''oxydation : les règles', 3, 'texte', '
### La définition

Dans une espèce chimique donnée, le **nombre d''oxydation** d''un élément
chimique est un **nombre entier noté en chiffre romain** qui caractérise le
**degré d''oxydation** de cet élément.

On le note $n.o.$ et on l''écrit toujours en **chiffres romains** : $+II$,
$-I$, $+VI$. Ne l''écris jamais en chiffres arabes, c''est compté comme une
faute.

### Les cinq règles

**1.** Le nombre d''oxydation d''un élément dans un **corps simple** est **nul**.

$$n.o.(Fe \text{ dans } Fe) = 0 \qquad n.o.(O \text{ dans } O_2) = 0 \qquad n.o.(Cl \text{ dans } Cl_2) = 0$$

**2.** Le nombre d''oxydation d''un **ion monoatomique** est égal à sa **charge**.

$$n.o.(Cu \text{ dans } Cu^{2+}) = +II \qquad n.o.(Cl \text{ dans } Cl^-) = -I$$

Retiens : le n.o. d''un **anion est négatif**, celui d''un **cation est
positif**.

**3.** La somme des nombres d''oxydation des éléments d''une **molécule neutre**
est **nulle**.

**4.** La somme des nombres d''oxydation des éléments d''un **ion polyatomique**
est égale à la **charge** de cet ion.

**5.** Dans leurs composés :

$$n.o.(H) = +I \qquad n.o.(O) = -II$$

Ce sont les deux valeurs qui te permettent de calculer toutes les autres.

### La méthode

Pour trouver le n.o. d''un élément inconnu, on écrit la règle 3 ou 4 sous forme
d''équation et on résout.

**Exemple 1 — l''azote dans $NH_3$.**
$$n.o.(N) + 3\,n.o.(H) = 0$$
$$n.o.(N) = -3 \times (+I) = -III$$

**Exemple 2 — l''azote dans $HNO_3$.**
$$n.o.(H) + n.o.(N) + 3\,n.o.(O) = 0$$
$$n.o.(N) = -(+I) - 3(-II) = -1 + 6 = +V$$

**Exemple 3 — le soufre dans l''ion $SO_4^{2-}$.** Attention, ici la somme
vaut $-II$, pas zéro :
$$n.o.(S) + 4\,n.o.(O) = -II$$
$$n.o.(S) = -II - 4(-II) = -2 + 8 = +VI$$

**Exemple 4 — le manganèse dans $MnO_4^-$.**
$$n.o.(Mn) + 4(-II) = -I \;\Longrightarrow\; n.o.(Mn) = -1 + 8 = +VII$$

---

**Exercice corrigé**

*Détermine le nombre d''oxydation du soufre dans $Na_2S_2O_3$, le thiosulfate
de sodium.*

**Correction.** La molécule est neutre, donc la somme est nulle. Il y a **deux**
atomes de soufre :
$$2\,n.o.(Na) + 2\,n.o.(S) + 3\,n.o.(O) = 0$$
$$n.o.(S) = \frac{-2\,n.o.(Na) - 3\,n.o.(O)}{2} = \frac{-2(+I) - 3(-II)}{2} = \frac{-2+6}{2}$$
$$n.o.(S) = +II$$
', NULL, 28),
      (v_chapitre_id, 'Simulation : calculer un nombre d''oxydation', 4, 'interactif', '{
  "widget": "nombre-oxydation",
  "consigne": "Tape une formule chimique, ou choisis-en une dans la liste, et la simulation pose l''équation à ta place : elle place les n.o. connus de l''hydrogène et de l''oxygène, puis te laisse résoudre pour l''élément qui reste. Essaie des cas pièges — un ion polyatomique dont la somme n''est pas nulle, ou une molécule qui contient deux atomes du même élément."
}', NULL, 10),
      (v_chapitre_id, 'Reconnaître une oxydoréduction par voie sèche', 5, 'texte', '
### Le critère unique

> Une réaction est une **oxydoréduction** s''il y a **variation du nombre
> d''oxydation** d''au moins un élément.

S''il n''y a aucune variation, ce n''est **pas** une oxydoréduction, quelle que
soit l''allure de l''équation.

### Les deux conséquences

> **Oxydation** : le nombre d''oxydation **augmente**.
>
> **Réduction** : le nombre d''oxydation **diminue**.

Et donc :

> Le **réducteur** est l''espèce dont le n.o. **augmente** — elle est oxydée.
>
> L''**oxydant** est l''espèce dont le n.o. **diminue** — elle est réduite.

C''est cohérent avec tout ce que tu sais : perdre des électrons, c''est devenir
plus positif, donc voir son n.o. monter.

### La méthode, en trois gestes

1. Écrire le n.o. de chaque élément sous chaque formule, à gauche et à droite.
2. Repérer ceux qui ont changé.
3. Conclure : celui qui monte est le réducteur, celui qui descend est
l''oxydant.

### Trois exemples travaillés

**a)** $2H_2 + O_2 \longrightarrow 2H_2O$

$$\underbrace{H_2}_{0} \quad \underbrace{O_2}_{0} \quad \longrightarrow \quad \underbrace{H_2O}_{+I \;;\; -II}$$

L''hydrogène passe de 0 à $+I$ : il **augmente**, c''est le réducteur.
L''oxygène passe de 0 à $-II$ : il **diminue**, c''est l''oxydant.
C''est bien une oxydoréduction.

**b)** $Al_2O_3 \longrightarrow 2Al^{3+} + 3O^{2-}$

À gauche, $n.o.(Al) = +III$ et $n.o.(O) = -II$. À droite, $n.o.(Al) = +III$ et
$n.o.(O) = -II$.
**Aucune variation** : ce n''est **pas** une oxydoréduction. C''est une simple
dissociation.

**c)** $2CuO + C \longrightarrow CO_2 + 2Cu$

$$\underbrace{Cu}_{+II} \quad \underbrace{C}_{0} \quad \longrightarrow \quad \underbrace{C}_{+IV} \quad \underbrace{Cu}_{0}$$

Le cuivre passe de $+II$ à 0 : il **diminue**, c''est l''**oxydant**.
Le carbone passe de 0 à $+IV$ : il **augmente**, c''est le **réducteur**.

---

**Exercice corrigé**

*Ces réactions sont-elles des oxydoréductions ? Si oui, donne l''oxydant et le
réducteur.*
*a) $ZnO + 2HCl \rightarrow ZnCl_2 + H_2O$*
*b) $H_2S + Cl_2 \rightarrow 2HCl + S$*

**Correction.**

**a)** À gauche : $n.o.(Zn) = +II$, $n.o.(O) = -II$, $n.o.(H) = +I$,
$n.o.(Cl) = -I$.
À droite : $n.o.(Zn) = +II$, $n.o.(Cl) = -I$, $n.o.(H) = +I$,
$n.o.(O) = -II$.
Aucune variation : ce n''est **pas** une oxydoréduction.

**b)** À gauche : $n.o.(S) = -II$ dans $H_2S$, $n.o.(Cl) = 0$ dans $Cl_2$.
À droite : $n.o.(Cl) = -I$ dans $HCl$, $n.o.(S) = 0$ dans $S$.
Le soufre passe de $-II$ à 0 : il augmente, c''est le **réducteur**.
Le chlore passe de 0 à $-I$ : il diminue, c''est l''**oxydant**.
C''est bien une oxydoréduction.
', NULL, 25),
      (v_chapitre_id, 'Simulation : oxydoréduction ou pas ?', 6, 'interactif', '{
  "widget": "redox-voie-seche",
  "consigne": "Une équation s''affiche et la simulation écrit les nombres d''oxydation sous chaque formule. À toi de repérer ceux qui ont changé et de désigner l''oxydant et le réducteur. Certaines équations sont des pièges : elles ont l''air de réactions violentes mais aucun n.o. ne bouge. Enchaîne les cas, c''est un réflexe qui s''acquiert en une dizaine d''essais."
}', NULL, 10),
      (v_chapitre_id, 'Équilibrer avec les nombres d''oxydation', 7, 'texte', '
Voici la raison pour laquelle on a introduit tout cet outillage : équilibrer en
quelques lignes des équations qu''on ne saurait pas équilibrer autrement.

### Le principe

Les électrons déplacés d''un côté sont exactement ceux qui arrivent de l''autre.
Donc, en comptant les variations de nombre d''oxydation affectées de leurs
coefficients, on doit trouver zéro :

$$\boxed{\;\alpha \cdot \Delta n.o.(1) + \beta \cdot \Delta n.o.(2) = 0\;}$$

où $\alpha$ et $\beta$ sont les coefficients cherchés.

### La méthode

1. Écrire les n.o. de chaque élément, à gauche et à droite.
2. Calculer les variations $\Delta n.o.$ pour les deux éléments qui changent.
3. Poser l''équation $\alpha \Delta n.o.(1) + \beta \Delta n.o.(2) = 0$ et en
tirer le rapport $\alpha/\beta$.
4. Placer ces coefficients, puis finir l''équilibrage sur les éléments qui n''ont
pas changé.

### Premier exemple

$$H_2 + O_2 \longrightarrow H_2O$$

$$n.o.(H) : 0 \rightarrow +I \;\Longrightarrow\; \Delta n.o.(H) = +I$$
$$n.o.(O) : 0 \rightarrow -II \;\Longrightarrow\; \Delta n.o.(O) = -II$$

$$\alpha(+I) + \beta(-II) = 0 \;\Longrightarrow\; \alpha = 2, \; \beta = 1$$

$$\boxed{\;2H_2 + O_2 \longrightarrow 2H_2O\;}$$

### Deuxième exemple

$$Fe_2O_3 + CO \longrightarrow Fe + CO_2$$

$$n.o.(Fe) : +III \rightarrow 0 \;\Longrightarrow\; \Delta n.o.(Fe) = -III$$
$$n.o.(C) : +II \rightarrow +IV \;\Longrightarrow\; \Delta n.o.(C) = +II$$

Attention : il y a **deux** atomes de fer dans $Fe_2O_3$. L''équation devient

$$2\alpha(-III) + \beta(+II) = 0 \;\Longrightarrow\; \alpha = 1, \; \beta = 3$$

$$\boxed{\;Fe_2O_3 + 3CO \longrightarrow 2Fe + 3CO_2\;}$$

Vérifie : 2 fers, 6 oxygènes à gauche ($3 + 3$), 6 à droite. C''est juste.

### Troisième exemple

$$HNO_3 + C \longrightarrow CO_2 + NO_2 + H_2O$$

$$n.o.(N) : +V \rightarrow +IV \;\Longrightarrow\; \Delta n.o.(N) = -I$$
$$n.o.(C) : 0 \rightarrow +IV \;\Longrightarrow\; \Delta n.o.(C) = +IV$$

$$\alpha(-I) + \beta(+IV) = 0 \;\Longrightarrow\; \alpha = 4, \; \beta = 1$$

$$4HNO_3 + C \longrightarrow CO_2 + 4NO_2 + ?\,H_2O$$

Il reste 4 hydrogènes à gauche, donc $2H_2O$ à droite.

$$\boxed{\;4HNO_3 + C \longrightarrow CO_2 + 4NO_2 + 2H_2O\;}$$

---

**Exercice corrigé**

*Équilibre $C + H_2SO_4 \rightarrow CO_2 + SO_2 + H_2O$ à l''aide des nombres
d''oxydation.*

**Correction.**
$$n.o.(S) \text{ dans } H_2SO_4 : 2(+I) + n.o.(S) + 4(-II) = 0 \;\Longrightarrow\; n.o.(S) = +VI$$
$$n.o.(S) \text{ dans } SO_2 : +IV \;\Longrightarrow\; \Delta n.o.(S) = -II$$
$$n.o.(C) : 0 \rightarrow +IV \;\Longrightarrow\; \Delta n.o.(C) = +IV$$
$$\alpha(+IV) + \beta(-II) = 0 \;\Longrightarrow\; \alpha = 1, \; \beta = 2$$
$$C + 2H_2SO_4 \longrightarrow CO_2 + 2SO_2 + ?\,H_2O$$
Il reste 4 hydrogènes à gauche, donc $2H_2O$.
$$\boxed{\;C + 2H_2SO_4 \longrightarrow CO_2 + 2SO_2 + 2H_2O\;}$$
Vérification des oxygènes : 8 à gauche, $2 + 4 + 2 = 8$ à droite.
', NULL, 28),
      (v_chapitre_id, 'Simulation : équilibrer par les n.o.', 8, 'interactif', '{
  "widget": "equilibrer-no",
  "consigne": "Une équation non équilibrée s''affiche. La simulation calcule les nombres d''oxydation, tu repères les variations, tu poses l''équation des alpha et bêta, et les coefficients se placent. Elle vérifie ensuite avec toi le décompte des atomes qui n''ont pas changé. Compare au temps qu''il t''aurait fallu pour équilibrer à tâtons : c''est là que cette méthode prend tout son sens."
}', NULL, 10),
      (v_chapitre_id, 'Applications industrielles de l''oxydoréduction', 9, 'texte', '
Tout ce que tu as appris dans ce module sert, tous les jours, dans l''industrie.
Voici les quatre applications que le programme demande de connaître.

### 1. La métallurgie : arracher le métal à son minerai

Dans la nature, les métaux ne sont presque jamais à l''état pur : ils sont
**oxydés**, sous forme d''oxydes ou de sulfures. Les obtenir, c''est donc les
**réduire**.

Dans le **haut fourneau**, le monoxyde de carbone réduit le minerai de fer :

$$Fe_2O_3 + 3\,CO \longrightarrow 2\,Fe + 3\,CO_2$$

$$n.o.(Fe) : +III \rightarrow 0 \qquad n.o.(C) : +II \rightarrow +IV$$

Le fer est réduit, le carbone est oxydé. Le réducteur, ici, c''est le monoxyde
de carbone, et il est fabriqué sur place à partir du coke.

### 2. L''aluminothermie : la soudure des rails

L''aluminium est un réducteur si puissant qu''il arrache l''oxygène aux autres
oxydes. La réaction est si exothermique que le fer produit est **liquide** :

$$2\,Al + Fe_2O_3 \longrightarrow Al_2O_3 + 2\,Fe$$

C''est ainsi qu''on soude les rails de chemin de fer, sur place, sans four.

Et l''aluminium lui-même ? On ne peut le réduire avec aucun réducteur chimique,
justement parce qu''il est le plus fort. On l''obtient donc par **électrolyse de
l''alumine** $Al_2O_3$ fondue : l''électricité fait ce qu''aucun réactif ne peut
faire.

$$\text{cathode :} \quad Al^{3+} + 3e^- \longrightarrow Al$$

C''est pour cela que la production d''aluminium consomme tant d''électricité — et
pourquoi les usines d''aluminium s''installent près des barrages, comme à Édéa.

### 3. L''eau de javel

$$Cl_2 + 2\,HO^- \longrightarrow ClO^- + Cl^- + H_2O$$

Regarde les nombres d''oxydation du chlore : il passe de 0 à $+I$ dans $ClO^-$
**et** de 0 à $-I$ dans $Cl^-$. Le même élément est à la fois oxydé et réduit :
cette réaction s''appelle une **dismutation**.

Le **degré chlorométrique** (°Chl) d''une eau de javel est le volume de dichlore
gazeux, mesuré dans les conditions normales, utilisé pour préparer **un litre**
de solution.

### 4. Les piles, l''affinage et la protection

Tu les as déjà vus : la **pile** transforme l''énergie chimique en énergie
électrique ; l''**électrolyse à anode soluble** affine le cuivre des câbles et
dépose le chrome ou l''or sur les objets ; l''**anode sacrifiée** en zinc protège
les coques des navires.

---

**Exercice corrigé**

*Quel volume de dichlore faut-il pour préparer 250 mL d''eau de javel à
48 °Chl ? Quelle est alors la concentration en ions hypochlorite $ClO^-$ ?*
*On prend $V_m = 22{,}4$ L/mol.*

**Correction.**
Par définition, 48 °Chl signifie 48 L de dichlore par litre de solution. Pour
250 mL :
$$V_{Cl_2} = 48 \times 0{,}250 = 12 \text{ L}$$
$$n_{Cl_2} = \frac{12}{22{,}4} = 0{,}536 \text{ mol}$$
D''après l''équation, une mole de dichlore donne une mole d''ions hypochlorite :
$$[ClO^-] = \frac{0{,}536}{0{,}250} = 2{,}14 \text{ mol/L}$$
', NULL, 25),
      (v_chapitre_id, 'Simulation : l''oxydoréduction dans l''industrie', 10, 'interactif', '{
  "widget": "applications-industrielles",
  "consigne": "Choisis un procédé — haut fourneau, aluminothermie, électrolyse de l''alumine, eau de javel — et la simulation écrit son équation, place les nombres d''oxydation sous chaque élément et désigne l''oxydant et le réducteur. Sur l''eau de javel, tu verras le même atome de chlore monter et descendre à la fois : c''est une dismutation. Règle ensuite le degré chlorométrique et calcule le volume de dichlore nécessaire."
}', NULL, 10),
      (v_chapitre_id, 'Sujet type Probatoire corrigé — fin du module 3', 11, 'texte', '
Voici l''exercice d''oxydoréduction et d''engrais du **Probatoire C et D, session
2012, Cameroun**. Cherche-le entièrement avant de lire la correction.

---

### Énoncé

**1. Oxydoréduction**

**1.1.** Définir : oxydoréduction ; couple oxydant-réducteur.

**1.2.** En utilisant les nombres d''oxydation, équilibrer l''équation-bilan
suivante :
$$H_2SO_4 + C \longrightarrow CO_2 + SO_2 + H_2O$$

**1.3.** On réalise une pile $P_1$ avec les couples $Au^{3+}/Au$ et
$Cu^{2+}/Cu$, dont les potentiels standard sont respectivement
$E°(Au^{3+}/Au) = 1{,}50$ V et $E°(Cu^{2+}/Cu) = 0{,}34$ V.
Préciser les pôles de la pile $P_1$, faire sa représentation conventionnelle,
écrire les équations aux électrodes, en déduire l''équation-bilan, puis calculer
la force électromotrice $E_1$.

**1.4.** On réalise une seconde pile $P_2$ avec les couples $Zn^{2+}/Zn$ et
$Cu^{2+}/Cu$, le potentiel standard du couple du zinc étant
$E°(Zn^{2+}/Zn) = -0{,}76$ V.
Déterminer $E_2$, puis la polarité et la force électromotrice $E$ de la pile
$P$ obtenue par association en série de $P_1$ et $P_2$.

**2. Engrais**

**2.1.** Qu''est-ce que le complexe argilo-humique ?

**2.2.** L''étiquette d''un sac d''engrais porte l''inscription **NPK : 15 – 11 –
20**. Que signifient ces trois nombres ? Quel rôle joue chacun des éléments
fertilisants ? On considère un échantillon de 2,5 kg de cet engrais :
déterminer les masses d''azote et de phosphore qu''il contient.

*Données : $M(O) = 16$ ; $M(N) = 14$ ; $M(P) = 31$ ; $M(K) = 39{,}1$ g/mol.*

---

### Correction

**1.1. Définitions.**
L''**oxydoréduction** est une réaction de transfert d''électrons au cours de
laquelle il se produit simultanément l''oxydation du réducteur et la réduction
de l''oxydant.
Un **couple oxydant-réducteur** est l''ensemble formé par un oxydant et son
réducteur conjugué, reliés par la demi-équation $Ox + ne^- \rightleftharpoons
Red$.

**1.2. Équilibrage par les nombres d''oxydation.**
$$n.o.(S) : +VI \rightarrow +IV \;\Longrightarrow\; \Delta n.o.(S) = -II$$
$$n.o.(C) : 0 \rightarrow +IV \;\Longrightarrow\; \Delta n.o.(C) = +IV$$
$$\alpha(+IV) + \beta(-II) = 0 \;\Longrightarrow\; \alpha = 1, \; \beta = 2$$
$$\boxed{\;C + 2H_2SO_4 \longrightarrow CO_2 + 2SO_2 + 2H_2O\;}$$

**1.3. La pile $P_1$.**
Le couple de l''or a le potentiel le plus élevé : l''**or est le pôle positif**,
le cuivre le pôle négatif.
$$\ominus \; Cu \;|\; Cu^{2+} \;||\; Au^{3+} \;|\; Au \; \oplus$$
$$\text{pôle négatif :} \quad Cu \longrightarrow Cu^{2+} + 2e^- \qquad (\times 3)$$
$$\text{pôle positif :} \quad Au^{3+} + 3e^- \longrightarrow Au \qquad (\times 2)$$
$$\boxed{\;3Cu + 2Au^{3+} \longrightarrow 3Cu^{2+} + 2Au\;}$$
$$E_1 = 1{,}50 - 0{,}34 = 1{,}16 \text{ V}$$

**1.4. La pile $P_2$ et l''association.**
$$E_2 = E°(Cu^{2+}/Cu) - E°(Zn^{2+}/Zn) = 0{,}34 - (-0{,}76) = 1{,}10 \text{ V}$$
En série, les forces électromotrices s''ajoutent :
$$E = E_1 + E_2 = 1{,}16 + 1{,}10 = 2{,}26 \text{ V}$$
Le pôle positif de l''ensemble est l''**or**, le pôle négatif est le **zinc**.
On retrouve bien, directement :
$$E = E°(Au^{3+}/Au) - E°(Zn^{2+}/Zn) = 1{,}50 - (-0{,}76) = 2{,}26 \text{ V}$$
et l''équation-bilan de $P$ est
$$3Zn + 2Au^{3+} \longrightarrow 3Zn^{2+} + 2Au$$

**2.1. Le complexe argilo-humique.**
C''est l''ensemble formé dans le sol par l''association de l''argile et de l''humus.
Il retient les éléments fertilisants et les restitue progressivement aux
plantes, et il assure la stabilité de la structure du sol.

**2.2. L''engrais.**
*Signification.* Pour 100 kg d''engrais : 15 kg d''azote N, 11 kg d''oxyde de
phosphore $P_2O_5$, 20 kg d''oxyde de potassium $K_2O$.
*Rôles.* L''azote assure la croissance et donne un feuillage vert. Le phosphore
facilite les échanges énergétiques et favorise la floraison et la
fructification. Le potassium active la photosynthèse et augmente la résistance
des plantes.
*Masse d''azote.*
$$m_N = 15 \times \frac{2{,}5}{100} = 0{,}375 \text{ kg}$$
*Masse de phosphore.*
$$M_{P_2O_5} = 2 \times 31 + 5 \times 16 = 142 \text{ g/mol}$$
$$m_P = \frac{2M_P}{M_{P_2O_5}} \times 11 \times \frac{2{,}5}{100} = 0{,}436 \times 11 \times 0{,}025 = 0{,}12 \text{ kg}$$

---

**Tu as fini le programme de Chimie de Première.** Reprends ce sujet dans une
semaine, sans la correction, et chronomètre-toi. C''est le meilleur test de ce
que tu as réellement retenu.
', NULL, 40),
      (v_chapitre_id, 'Quiz du chapitre 19', 12, 'quiz', '{
  "titre": "Vérifie que tu as compris",
  "questions": [
    {
      "question": "Qu''est-ce qu''une réaction par voie sèche ?",
      "choix": [
        "Une réaction qui dégage de la chaleur",
        "Une réaction qui se déroule en l''absence d''eau ou de tout autre solvant",
        "Une réaction entre deux solides",
        "Une réaction lente"
      ],
      "bonne": 1,
      "explication": "Ce sont par exemple les réactions d''un haut fourneau ou d''une combustion. Il n''y a pas d''ions libres pour transporter les électrons."
    },
    {
      "question": "Où se trouvent les éléments les plus électronégatifs dans le tableau périodique ?",
      "choix": [
        "En bas et à gauche",
        "En haut et à droite",
        "Au centre",
        "Dans la dernière colonne"
      ],
      "bonne": 1,
      "explication": "Le fluor, en haut à droite, est le plus électronégatif avec 4. Le césium, en bas à gauche, est le plus électropositif avec 0,8."
    },
    {
      "question": "Comment note-t-on un nombre d''oxydation ?",
      "choix": [
        "En chiffres arabes",
        "En chiffres romains",
        "En lettres",
        "Avec un symbole grec"
      ],
      "bonne": 1,
      "explication": "On écrit $+II$, $-I$, $+VI$. L''écrire en chiffres arabes est compté comme une faute."
    },
    {
      "question": "Quel est le nombre d''oxydation du soufre dans l''ion $SO_4^{2-}$ ?",
      "choix": [
        "$+IV$",
        "$+VI$",
        "$-II$",
        "0"
      ],
      "bonne": 1,
      "explication": "$n.o.(S) + 4(-II) = -II$, donc $n.o.(S) = -2 + 8 = +VI$. Attention : la somme vaut la charge de l''ion, pas zéro."
    },
    {
      "question": "À quoi reconnaît-on une oxydoréduction par voie sèche ?",
      "choix": [
        "À un dégagement gazeux",
        "À la variation du nombre d''oxydation d''au moins un élément",
        "À un changement de couleur",
        "À la présence d''eau"
      ],
      "bonne": 1,
      "explication": "S''il n''y a aucune variation, ce n''est pas une oxydoréduction, quelle que soit l''allure de l''équation."
    },
    {
      "question": "Dans une oxydoréduction, le nombre d''oxydation du réducteur :",
      "choix": [
        "diminue",
        "augmente",
        "ne change pas",
        "devient nul"
      ],
      "bonne": 1,
      "explication": "Le réducteur est oxydé : il perd des électrons, donc il devient plus positif. C''est l''oxydant dont le n.o. diminue."
    },
    {
      "question": "Comment équilibre-t-on une équation à l''aide des nombres d''oxydation ?",
      "choix": [
        "En égalisant les masses",
        "En posant $\\alpha \\Delta n.o.(1) + \\beta \\Delta n.o.(2) = 0$",
        "En comptant les atomes seulement",
        "Au hasard"
      ],
      "bonne": 1,
      "explication": "Les électrons perdus sont exactement ceux qui sont gagnés : la somme pondérée des variations est donc nulle."
    }
  ]
}', NULL, 5);

    RAISE NOTICE '% : 12 leçons ajoutées au chapitre 19, Oxydoréduction par voie sèche et nombres d''oxydation.', v_nom;
  END LOOP;
END $ch1$;
