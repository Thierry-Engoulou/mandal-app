-- ---------------------------------------------------------------------------
-- M'Andal — Chimie, classes de Première
-- Chapitre 7 : Propriétés physiques et chimiques des alcènes et des alcynes
-- Module 1 : Chimie organique — 11 leçons
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
    WHERE programme_id = v_programme_id AND ordre = 7;

    IF v_chapitre_id IS NULL THEN
      INSERT INTO public.chapitres (programme_id, titre, ordre, niveau)
      VALUES (v_programme_id, 'Propriétés physiques et chimiques des alcènes et des alcynes', 7, 'Module 1 : Chimie organique')
      RETURNING id INTO v_chapitre_id;
      RAISE NOTICE '% : chapitre 7 créé.', v_nom;
    END IF;

    -- Les leçons. Si le chapitre en a déjà, on passe son tour sans rien toucher.
    SELECT count(*) INTO v_deja FROM public.concepts WHERE chapitre_id = v_chapitre_id;
    IF v_deja > 0 THEN
      RAISE NOTICE '% : le chapitre 7 a déjà ses % leçons, je n''y touche pas.', v_nom, v_deja;
      CONTINUE;
    END IF;

    INSERT INTO public.concepts
      (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes) VALUES
      (v_chapitre_id, 'Propriétés physiques des alcènes et des alcynes', 1, 'texte', '
Avant d''étudier ce que ces molécules font, regardons ce qu''elles sont : un gaz
ou un liquide, coloré ou non, soluble ou non. C''est ce qui décide de la façon
dont on les manipule au laboratoire.

### L''état physique

Comme chez les alcanes, il dépend de la longueur de la chaîne :

| Nombre de carbones | État à 25 °C |
| --- | --- |
| 2 à 4 | gaz |
| 5 à 15 | liquide |
| plus de 15 | solide |

L''éthylène et l''acétylène, les deux chefs de file, sont donc des **gaz**.

### La couleur et l''odeur

L''éthylène et l''acétylène sont des gaz **incolores**.

L''acétylène pur est **inodore**. L''odeur d''ail désagréable du gaz qu''on obtient
à partir du carbure du commerce ne vient pas de lui : elle vient des
**impuretés sulfurées** du carbure. C''est précisément pour cela qu''on fait
barboter le gaz dans une solution de sulfate de cuivre, comme tu le verras au
chapitre suivant.

### La solubilité

Les alcènes et les alcynes sont **peu solubles dans l''eau**, et **solubles dans
les solvants organiques** : essence, éther, benzène.

Retrouve la logique du chapitre 1 : ce sont des composés organiques, donc ils
fuient l''eau et se plaisent entre eux. Cette propriété a une conséquence
pratique immédiate — on peut **recueillir ces gaz par déplacement d''eau**, sans
qu''ils se dissolvent au passage.

### La densité

Leur densité est **inférieure à celle de l''eau** : un alcène liquide flotte.
Pour les gaz, la densité par rapport à l''air se calcule comme toujours :

$$d = \frac{M}{29}$$

Pour l''éthylène, $d = 28/29 = 0{,}97$ : il est à peine plus léger que l''air.
Pour l''acétylène, $d = 26/29 = 0{,}90$.

### Les températures d''ébullition

Elles **augmentent avec le nombre de carbones**, et **diminuent quand la
molécule se ramifie** — exactement comme chez les alcanes, et pour la même
raison : une molécule compacte offre moins de prise à ses voisines.

---

**Exercice corrigé**

*La densité de la vapeur d''un alcène vaut $d = 2{,}4$. Détermine sa formule
brute.*

**Correction.**
$$M = 29d = 29 \times 2{,}4 = 69{,}6 \approx 70 \text{ g/mol}$$
Pour un alcène, $M = 14n$, d''où
$$n = \frac{70}{14} = 5$$
La formule brute est $C_5H_{10}$. C''est un pentène — reste à trouver lequel,
et c''est l''objet de la leçon suivante.
', NULL, 20),
      (v_chapitre_id, 'Simulation : gaz, liquide ou solide ?', 2, 'interactif', '{
  "widget": "proprietes-insatures",
  "consigne": "Allonge la chaîne carbonée et regarde la molécule passer de l''état gazeux à l''état liquide, avec sa température d''ébullition et sa densité par rapport à l''air. Plonge-la ensuite dans l''eau, puis dans l''essence, pour vérifier où elle se dissout. Essaie enfin de recueillir le gaz par déplacement d''eau : tu comprendras pourquoi cette méthode marche pour les insaturés."
}', NULL, 10),
      (v_chapitre_id, 'Les combustions', 3, 'texte', '
Comme tous les hydrocarbures, les alcènes et les alcynes brûlent en présence de
dioxygène. La combustion est **complète** quand elle ne produit pas de carbone,
**incomplète** quand de la suie apparaît.

### Les deux équations à savoir écrire

Pour un alcène :

$$C_nH_{2n} + \frac{3n}{2}\,O_2 \longrightarrow n\,CO_2 + n\,H_2O$$

Pour un alcyne :

$$C_nH_{2n-2} + \frac{3n-1}{2}\,O_2 \longrightarrow n\,CO_2 + (n-1)\,H_2O$$

Ne les apprends pas par cœur : retrouve-les. Il y a $n$ carbones, donc $n$
molécules de $CO_2$. Il y a $2n$ hydrogènes chez l''alcène, donc $n$ molécules
d''eau. Ensuite tu comptes les oxygènes de droite et tu divises par deux.

### Une remarque utile

Ces combustions sont très exothermiques, comme celles des alcanes. Pourtant les
alcènes et les alcynes **ne servent pas de combustibles** industriels ou
domestiques. La raison est économique : ils sont bien trop réactifs
chimiquement, donc bien trop précieux comme matières premières. On ne brûle pas
ce qui sert à fabriquer les plastiques.

L''exception est l''acétylène, utilisé au chalumeau oxyacétylénique : sa flamme
monte à plus de 3 000 °C, ce qui permet de souder l''acier.

---

**Exercice corrigé**

*La combustion complète de 150 cm³ d''un mélange gazeux d''un alcène et de
l''alcyne ayant le même nombre de carbones donne 230 cm³ de $CO_2$ (CNTP).
Sachant que le mélange est équimolaire, trouve $n$.*

**Correction.** Soit $V$ le volume de chacun des deux gaz : $2V = 150$, donc
$V = 75$ cm³.
Chaque molécule, alcène ou alcyne, donne $n$ molécules de $CO_2$. Les volumes
étant proportionnels aux quantités de matière :
$$V_{CO_2} = n \times 75 + n \times 75 = 150\,n$$
$$150\,n = 230 \;\Longrightarrow\; n = 1{,}53$$
Ce n''est pas un entier : le mélange n''est donc pas équimolaire. L''exercice
montre qu''il faut toujours vérifier la cohérence de l''énoncé avant de conclure.
Avec $n = 2$, on aurait $V_{CO_2} = 2 \times 150 = 300$ cm³.
', NULL, 20),
      (v_chapitre_id, 'Simulation : équilibrer une combustion d''insaturé', 4, 'interactif', '{
  "widget": "combustion-insature",
  "consigne": "Choisis un alcène ou un alcyne et fais varier le nombre de carbones. L''équation-bilan s''équilibre d''elle-même et la simulation te montre le décompte atome par atome : carbone à gauche, carbone à droite, hydrogène, puis oxygène. Passe de la combustion complète à la combustion incomplète et regarde la suie apparaître dans les produits."
}', NULL, 10),
      (v_chapitre_id, 'L''hydrogénation', 5, 'texte', '
Nous entrons dans le cœur du chapitre : les **réactions d''addition**. Une
réaction d''addition est une réaction au cours de laquelle une molécule se fixe
sur une molécule insaturée. La liaison $\pi$, fragile, s''ouvre, et ses deux
extrémités accueillent chacune un morceau de la molécule qui arrive.

C''est ce qui distingue fondamentalement les insaturés des alcanes. Les alcanes,
saturés, ne font que des réactions de **substitution** : un atome en remplace
un autre. Les alcènes et les alcynes, eux, font des **additions**.

### Le cas des alcènes

L''hydrogénation d''un alcène donne l''alcane correspondant. La réaction n''a lieu
qu''en présence d''un **catalyseur** : nickel $Ni$, platine $Pt$ ou palladium
$Pd$.

$$C_nH_{2n} + H_2 \xrightarrow{\;Ni\;} C_nH_{2n+2}$$

Pour l''éthylène :

$$C_2H_4 + H_2 \xrightarrow{\;Ni\;} C_2H_6$$

### Le cas des alcynes : tout dépend du catalyseur

Un alcyne a deux liaisons $\pi$. Il peut donc fixer une molécule de dihydrogène,
ou deux. Ce qui décide, c''est le catalyseur employé.

Avec le **palladium**, catalyseur peu actif, la réaction s''arrête à l''alcène :

$$C_nH_{2n-2} + H_2 \xrightarrow{\;Pd\;} C_nH_{2n}$$

Avec le **nickel**, catalyseur plus actif, la réaction se poursuit jusqu''à
l''alcane :

$$C_nH_{2n-2} + 2\,H_2 \xrightarrow{\;Ni\;} C_nH_{2n+2}$$

Il y a donc ouverture successive des deux liaisons $\pi$.

C''est une question classique d''examen : on te donne un alcyne, un catalyseur, et
on te demande le produit. Lis bien le nom du métal avant de répondre.

---

**Exercice corrigé**

*Complète : l''hydrogénation de l''éthyne conduit à quoi, selon le catalyseur ?*

**Correction.**
Avec le palladium :
$$H-C \equiv C-H + H_2 \xrightarrow{\;Pd\;} H_2C = CH_2 \quad \text{(éthylène)}$$
Avec le nickel, la réaction continue :
$$H-C \equiv C-H + H_2 \xrightarrow{\;Ni\;} H_2C = CH_2$$
$$H_2C = CH_2 + H_2 \xrightarrow{\;Ni\;} H_3C - CH_3 \quad \text{(éthane)}$$
soit globalement $C_2H_2 + 2H_2 \longrightarrow C_2H_6$.
', NULL, 22),
      (v_chapitre_id, 'Simulation : hydrogéner avec Pd ou avec Ni', 6, 'interactif', '{
  "widget": "hydrogenation-catalyseur",
  "consigne": "Pose un alcyne dans le réacteur, choisis le catalyseur, puis envoie le dihydrogène molécule par molécule. Avec le palladium la réaction s''arrête d''elle-même sur l''alcène ; avec le nickel elle continue jusqu''à l''alcane. Compte les molécules de dihydrogène consommées dans chaque cas : tu retrouveras les coefficients de l''équation-bilan."
}', NULL, 10),
      (v_chapitre_id, 'L''hydratation et la règle de Markovnikov', 7, 'texte', '
L''**hydratation** est l''addition d''une molécule d''eau. Elle a lieu en milieu
acide, c''est-à-dire dans un milieu où l''on a versé quelques gouttes d''acide.

### Le cas simple : l''éthylène

$$CH_2 = CH_2 + H-OH \longrightarrow CH_3-CH_2-OH$$

Le produit est un **alcool**, l''éthanol, aussi appelé alcool éthylique. C''est
exactement l''alcool des boissons, et c''est l''un des procédés industriels pour
le fabriquer.

### Le cas intéressant : un alcène dissymétrique

L''éthylène est symétrique : les deux carbones de la double liaison sont
identiques, donc il n''y a qu''un seul produit possible. Mais prends le propène :

$$CH_3-CH=CH_2$$

Le groupe $-OH$ peut se fixer sur le carbone n° 1 ou sur le carbone n° 2. Deux
produits sont donc envisageables :

$$CH_3-CH_2-CH_2-OH \quad \text{le propan-1-ol}$$
$$CH_3-CH(OH)-CH_3 \quad \text{le propan-2-ol}$$

L''expérience tranche : le **propan-2-ol est largement majoritaire**.

### La règle de Markovnikov

> Au cours de l''addition d''un composé hydrogéné sur un alcène dissymétrique,
> l''atome d''hydrogène se fixe de préférence sur l''atome de carbone **le plus
> hydrogéné**.

Autrement dit : celui qui en a déjà le plus en reçoit encore. C''est une règle
contre-intuitive, retiens-la telle quelle. Une formulation populaire dit
« les riches deviennent plus riches ».

Appliquée au propène : le carbone n° 1 porte déjà deux hydrogènes, le n° 2 n''en
porte qu''un. L''hydrogène de l''eau va donc sur le n° 1, et par conséquent le
$-OH$ se retrouve sur le n° 2. D''où le propan-2-ol.

Sous forme générale :

$$R-CH=CH_2 + H-OH \longrightarrow R-CH(OH)-CH_3$$

### Le cas des alcynes : on n''obtient pas un alcool

L''hydratation d''un alcyne conduit à un **aldéhyde**, reconnaissable à son
groupe fonctionnel $-CHO$. La réaction est catalysée par les ions mercure II,
$Hg^{2+}$, à 60 °C en milieu acide.

$$H-C \equiv C-H + H_2O \xrightarrow[H^+,\,60\,°C]{\;Hg^{2+}\;} CH_3-CHO$$

Le produit s''appelle l''**éthanal**. Deux tests l''identifient : il **rosit le
réactif de Schiff**, et il donne un **précipité jaune** avec la 2,4-DNPH
(2,4-dinitrophénylhydrazine). Tu retrouveras ces deux tests au chapitre 9.

---

**Exercice corrigé**

*Comment passer du carbure de calcium à l''éthanol ?*

**Correction.** En trois étapes.
1. On hydrate le carbure de calcium pour obtenir l''acétylène :
$$CaC_2 + 2H_2O \longrightarrow C_2H_2 + Ca(OH)_2$$
2. On hydrogène l''acétylène en éthylène, avec du palladium :
$$C_2H_2 + H_2 \xrightarrow{\;Pd\;} CH_2 = CH_2$$
3. On hydrate l''éthylène en milieu acide :
$$CH_2 = CH_2 + H_2O \xrightarrow{\;H_2SO_4\;} CH_3-CH_2-OH$$
', NULL, 25),
      (v_chapitre_id, 'Simulation : la règle de Markovnikov', 8, 'interactif', '{
  "widget": "markovnikov",
  "consigne": "Choisis un alcène dissymétrique et le composé hydrogéné à additionner : eau ou chlorure d''hydrogène. La simulation compte les hydrogènes déjà présents sur chacun des deux carbones de la double liaison, puis t''indique où part le nouvel hydrogène et où part le reste. Prends ensuite un alcène symétrique : la règle n''a plus rien à départager, et un seul produit se forme."
}', NULL, 10),
      (v_chapitre_id, 'Additions de HCl et des dihalogènes', 9, 'texte', '
### Le chlorure d''hydrogène

Sur l''éthylène, à 170 °C :

$$CH_2 = CH_2 + HCl \longrightarrow CH_3-CH_2Cl$$

Sur le propène, alcène dissymétrique, deux produits sont en principe possibles :
le 1-chloropropane et le 2-chloropropane. L''expérience montre qu''on obtient
majoritairement le **2-chloropropane**, conformément à la règle de Markovnikov :
l''hydrogène se fixe sur le carbone le plus hydrogéné, donc le chlore se fixe sur
l''autre.

$$CH_3-CH=CH_2 + HCl \longrightarrow CH_3-CHCl-CH_3$$

Sur l''acétylène, en présence de chlorure de mercure à 200 °C :

$$CH \equiv CH + HCl \xrightarrow{\;HgCl_2,\,200\,°C\;} CH_2 = CHCl$$

Le produit est le **chlorure de vinyle**, matière première du PVC. Tu le
retrouveras au chapitre suivant.

### Le dichlore : la chloruration

$$CH_2 = CH_2 + Cl_2 \longrightarrow CH_2Cl-CH_2Cl$$

Le produit est le 1,2-dichloroéthane. Attention à la condition : cette réaction
se produit **exclusivement dans l''obscurité**.

Compare bien avec le chapitre 5. Sur un alcane, le dichlore faisait une
**substitution**, et il fallait **de la lumière**. Sur un alcène, il fait une
**addition**, et il faut **l''obscurité**. Deux familles, deux comportements
opposés face au même réactif : c''est une question d''examen très fréquente.

### Le dibrome : le test de la double liaison

L''eau de dibrome est une solution **orangée**. Verse-la sur un hydrocarbure :

- si l''hydrocarbure est **insaturé**, la solution se **décolore** : le dibrome
s''additionne sur la liaison multiple et disparaît ;
- si l''hydrocarbure est **saturé**, rien ne se passe : la couleur orangée
reste.

$$CH_2 = CH_2 + Br_2 \longrightarrow CH_2Br-CH_2Br$$

C''est **le** test d''identification de la double liaison, et il tombe à presque
tous les examens. Un seul réactif, un seul regard, une réponse immédiate.

Il permet aussi de **doser** : une molécule d''alcène fixe exactement une
molécule de dibrome. En pesant le dibrome fixé, on remonte à la quantité
d''alcène.

---

**Exercice corrigé**

*Une masse de 2,8 g d''un alcène peut fixer 8 g de dibrome. Donne sa formule
brute. On donne $M(Br) = 80$ g/mol.*

**Correction.** Une molécule d''alcène fixe une molécule de dibrome, donc
$$n_{alcène} = n_{Br_2} = \frac{8}{160} = 0{,}05 \text{ mol}$$
$$M_{alcène} = \frac{2{,}8}{0{,}05} = 56 \text{ g/mol}$$
Or pour un alcène, $M = 14n$, d''où
$$n = \frac{56}{14} = 4$$
La formule brute est $C_4H_8$.
', NULL, 25),
      (v_chapitre_id, 'Simulation : le test au dibrome', 10, 'interactif', '{
  "widget": "test-dibrome",
  "consigne": "Verse l''eau de dibrome, orangée, sur l''hydrocarbure de ton choix : un alcane, un alcène, un alcyne. Regarde la couleur disparaître — ou rester. Ensuite, passe en mode dosage : la simulation te laisse peser le dibrome fixé et remonter à la masse molaire de l''alcène, exactement comme dans l''exercice corrigé."
}', NULL, 10),
      (v_chapitre_id, 'Quiz du chapitre 7', 11, 'quiz', '{
  "titre": "Vérifie que tu as compris",
  "questions": [
    {
      "question": "Qu''est-ce qu''une réaction d''addition ?",
      "choix": [
        "Une réaction où un atome en remplace un autre",
        "Une réaction où une molécule se fixe sur une molécule insaturée",
        "Une réaction qui dégage de la chaleur",
        "Une réaction qui produit de l''eau"
      ],
      "bonne": 1,
      "explication": "La liaison $\\pi$ s''ouvre et ses deux extrémités accueillent chacune un morceau de la molécule qui arrive. C''est le contraire de la substitution des alcanes."
    },
    {
      "question": "On hydrogène un alcyne en présence de palladium. Qu''obtient-on ?",
      "choix": [
        "Un alcane",
        "Un alcène",
        "Un alcool",
        "Un aldéhyde"
      ],
      "bonne": 1,
      "explication": "Le palladium est un catalyseur peu actif : la réaction s''arrête après l''ouverture de la première liaison $\\pi$. Avec le nickel, elle irait jusqu''à l''alcane."
    },
    {
      "question": "Que dit la règle de Markovnikov ?",
      "choix": [
        "L''hydrogène se fixe sur le carbone le moins hydrogéné",
        "L''hydrogène se fixe sur le carbone le plus hydrogéné",
        "Le $-OH$ se fixe toujours en bout de chaîne",
        "Les deux produits se forment à parts égales"
      ],
      "bonne": 1,
      "explication": "Celui qui en a déjà le plus en reçoit encore. C''est pour cela que l''hydratation du propène donne majoritairement le propan-2-ol."
    },
    {
      "question": "L''hydratation d''un alcyne donne :",
      "choix": [
        "un alcool",
        "un aldéhyde",
        "un alcane",
        "un polymère"
      ],
      "bonne": 1,
      "explication": "Le produit porte le groupe $-CHO$. Pour l''acétylène, c''est l''éthanal, qui rosit le réactif de Schiff."
    },
    {
      "question": "On verse de l''eau de dibrome orangée sur un gaz : la couleur disparaît. Que peut-on dire du gaz ?",
      "choix": [
        "C''est un alcane",
        "Il contient une liaison multiple",
        "Il est saturé",
        "On ne peut rien dire"
      ],
      "bonne": 1,
      "explication": "Le dibrome s''additionne sur la liaison multiple et disparaît. La décoloration est le test d''identification d''une insaturation."
    },
    {
      "question": "Dans quelles conditions le dichlore s''additionne-t-il sur l''éthylène ?",
      "choix": [
        "À la lumière",
        "Dans l''obscurité",
        "À 1 000 °C",
        "En présence d''eau salée"
      ],
      "bonne": 1,
      "explication": "Attention au piège : sur un alcane, le dichlore fait une substitution à la lumière. Sur un alcène, il fait une addition, dans l''obscurité."
    },
    {
      "question": "Quelle masse de dibrome une mole d''éthylène peut-elle fixer ? On donne $M(Br) = 80$ g/mol.",
      "choix": [
        "80 g",
        "160 g",
        "320 g",
        "40 g"
      ],
      "bonne": 1,
      "explication": "Une molécule d''alcène fixe une molécule de $Br_2$, de masse molaire $2 \\times 80 = 160$ g/mol."
    }
  ]
}', NULL, 5);

    RAISE NOTICE '% : 11 leçons ajoutées au chapitre 7, Propriétés physiques et chimiques des alcènes et des alcynes.', v_nom;
  END LOOP;
END $ch1$;
