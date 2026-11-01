-- ---------------------------------------------------------------------------
-- M'Andal — Chimie, classes de Première
-- Chapitre 5 : Propriétés chimiques et préparation des alcanes
-- Module 1 : Chimie organique — 7 leçons
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
    WHERE programme_id = v_programme_id AND ordre = 5;

    IF v_chapitre_id IS NULL THEN
      INSERT INTO public.chapitres (programme_id, titre, ordre, niveau)
      VALUES (v_programme_id, 'Propriétés chimiques et préparation des alcanes', 5, 'Module 1 : Chimie organique')
      RETURNING id INTO v_chapitre_id;
      RAISE NOTICE '% : chapitre 5 créé.', v_nom;
    END IF;

    -- Les leçons. Si le chapitre en a déjà, on passe son tour sans rien toucher.
    SELECT count(*) INTO v_deja FROM public.concepts WHERE chapitre_id = v_chapitre_id;
    IF v_deja > 0 THEN
      RAISE NOTICE '% : le chapitre 5 a déjà ses % leçons, je n''y touche pas.', v_nom, v_deja;
      CONTINUE;
    END IF;

    INSERT INTO public.concepts
      (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes) VALUES
      (v_chapitre_id, 'La combustion des alcanes', 1, 'texte', '
Les alcanes sont avant tout des **combustibles** : c''est leur usage principal et
la raison pour laquelle on les extrait du sol. Leur combustion est la réaction la
plus importante de ce chapitre.

### Le cas du méthane

La combustion complète du méthane donne une flamme bleu pâle, très chaude :

$$CH_4 + 2\,O_2 \longrightarrow CO_2 + 2\,H_2O$$

La réaction est **exothermique** : une mole de méthane libère environ 890 kJ.
C''est ce qui justifie l''emploi du gaz dans les cuisinières et les chauffe-eau.

### Le cas général, avec du dioxygène en excès

Quand le dioxygène est en quantité suffisante, la combustion est **complète** et
ne donne que du dioxyde de carbone et de l''eau :

$$C_nH_{2n+2} + \frac{3n+1}{2}\,O_2 \longrightarrow n\,CO_2 + (n+1)\,H_2O$$

Vérifie le coefficient du dioxygène en comptant les oxygènes du membre de
droite : $2n + (n+1) = 3n+1$ atomes, soit $\frac{3n+1}{2}$ molécules. Tu peux
toujours le reconstruire, inutile de l''apprendre par cœur.

### Quand le dioxygène manque

Si le dioxygène est **en défaut**, la combustion est **incomplète**. Le carbone
n''est plus entièrement oxydé : il se dépose sous forme de suie.

$$C_nH_{2n+2} + \frac{n+1}{2}\,O_2 \longrightarrow n\,C + (n+1)\,H_2O$$

C''est ce que tu observes avec une lampe à pétrole mal réglée : flamme jaune,
fumée noire, dépôt de suie sur le verre. Entre les deux extrêmes, la combustion
peut aussi produire du **monoxyde de carbone** $CO$, un gaz inodore et mortel.
C''est la raison pour laquelle on n''utilise jamais un brasero dans une pièce
fermée.

---

**Exercice corrigé**

*La combustion complète d''un alcane gazeux produit un volume de dioxyde de
carbone égal à cinq fois celui de l''alcane, les volumes étant mesurés dans les
mêmes conditions. 1) Quel est cet alcane ? 2) Écris l''équation de sa combustion.*

**Correction.**
1) Dans l''équation générale, une mole d''alcane donne $n$ moles de $CO_2$. Les
volumes gazeux étant proportionnels aux quantités de matière dans les mêmes
conditions :
$$\frac{V_{CO_2}}{V_{C_nH_{2n+2}}} = n = 5$$
L''alcane est donc le **pentane**, $C_5H_{12}$.

2) Avec $n = 5$, le coefficient du dioxygène vaut $\frac{3\times 5 + 1}{2} = 8$ :
$$C_5H_{12} + 8\,O_2 \longrightarrow 5\,CO_2 + 6\,H_2O$$
', NULL, 25),
      (v_chapitre_id, 'Simulation : équilibrer et doser une combustion', 2, 'interactif', '{
  "widget": "combustion-alcane",
  "consigne": "Choisis l''alcane, puis lis l''équation équilibrée et les volumes mis en jeu. Réduis ensuite le dioxygène disponible : la combustion devient incomplète et la suie apparaît. C''est exactement ce qui se passe dans une lampe mal réglée."
}', NULL, 10),
      (v_chapitre_id, 'La réaction de substitution : la chloration du méthane', 3, 'texte', '
Les alcanes sont des corps **peu réactifs** : saturés, sans charge, ils ne
subissent pas d''addition. Leur seule réaction caractéristique, en dehors de la
combustion, est la **substitution** : un atome d''hydrogène est remplacé par un
autre atome, le plus souvent un halogène.

### L''expérience

On mélange, à volumes égaux, du dichlore et du méthane dans une éprouvette
retournée sur une cuve d''**eau salée**. Pourquoi salée ? Parce que le chlore ne
s''y dissout pas, alors qu''il se dissoudrait dans l''eau pure et fausserait
l''expérience.

**Dans l''obscurité, rien ne se passe.** C''est le point essentiel.

**À la lumière**, on observe peu à peu quatre choses :
- l''eau salée monte dans l''éprouvette ;
- la couleur jaune-vert du mélange disparaît ;
- des gouttelettes huileuses se forment sur les parois ;
- un papier pH placé dans la cuve **rougit**.

### L''interprétation

La disparition de la couleur montre que le dichlore est consommé. La montée de
l''eau montre que le nombre de molécules de gaz diminue. Le papier qui rougit
révèle un acide : c''est l''acide chlorhydrique, né de la dissolution du chlorure
d''hydrogène $HCl$ formé.

Comme la réaction exige la lumière, on dit que c''est une **réaction
photochimique**.

### Les quatre étapes

La substitution ne s''arrête pas au premier hydrogène : elle se poursuit tant
qu''il reste du chlore.

$$CH_4 + Cl_2 \longrightarrow CH_3Cl + HCl$$
$$CH_3Cl + Cl_2 \longrightarrow CH_2Cl_2 + HCl$$
$$CH_2Cl_2 + Cl_2 \longrightarrow CHCl_3 + HCl$$
$$CHCl_3 + Cl_2 \longrightarrow CCl_4 + HCl$$

On recueille donc un mélange de quatre dérivés chlorés.

### À quoi servent-ils

| Composé | Nom courant | Usage |
| --- | --- | --- |
| $CH_3Cl$ | chlorométhane | synthèse des résines, solvant |
| $CH_2Cl_2$ | dichlorométhane | solvant des pressings |
| $CHCl_3$ | chloroforme | anesthésique |
| $CCl_4$ | tétrachlorométhane | solvant, fabrication des fréons |

### Le cas général

$$C_nH_{2n+2} + x\,Cl_2 \longrightarrow C_nH_{2n+2-x}Cl_x + x\,HCl$$

Chaque chlore entré fait sortir un hydrogène et libère une molécule de $HCl$.

---

**Exercice corrigé** *(d''après le probatoire série C, Cameroun)*

*Un hydrocarbure de formule $C_nH_{2n+2}$ a une masse molaire de 30 g/mol.
1) Donne sa formule brute. 2) On remplace $x$ atomes d''hydrogène par $x$ atomes
de chlore ; le dérivé chloré a une masse molaire de 99 g/mol. Calcule $x$ et
nomme les isomères possibles. On donne $Cl = 35{,}5$ g/mol.*

**Correction.**
1) $M = 14n + 2 = 30$, donc $n = 2$. La formule brute est $C_2H_6$, l''éthane.

2) Le dérivé a pour formule $C_2H_{6-x}Cl_x$. Sa masse molaire vaut :
$$M'' = 24 + (6-x) + 35{,}5x = 99$$
$$30 + 34{,}5x = 99 \;\Longrightarrow\; x = \frac{69}{34{,}5} = 2$$

La formule est $C_2H_4Cl_2$. Deux isomères y répondent :
$$CH_2Cl-CH_2Cl \quad \text{le 1,2-dichloroéthane}$$
$$CHCl_2-CH_3 \quad \text{le 1,1-dichloroéthane}$$
', NULL, 28),
      (v_chapitre_id, 'Simulation : la chloration du méthane, étape par étape', 4, 'interactif', '{
  "widget": "chloration-methane",
  "consigne": "Éteins la lumière : rien ne se produit. Rallume-la et ajoute du dichlore, molécule par molécule. Les quatre dérivés apparaissent dans l''ordre, et une molécule de chlorure d''hydrogène se forme à chaque étape."
}', NULL, 10),
      (v_chapitre_id, 'Préparer le méthane au laboratoire', 5, 'texte', '
Au laboratoire, on ne va pas chercher le méthane dans un gisement : on le
fabrique, à partir du **carbure d''aluminium**.

### Le montage et la réaction

On place du carbure d''aluminium $Al_4C_3$, une poudre jaunâtre, dans un flacon.
On y verse progressivement de l''eau mélangée à une très faible quantité d''acide
chlorhydrique. Le gaz qui se dégage est recueilli par déplacement d''eau.

$$Al_4C_3 + 12\,H_2O \longrightarrow 4\,Al(OH)_3 + 3\,CH_4$$

Vérifie l''équilibrage : 4 aluminiums de chaque côté, 3 carbones, 24 hydrogènes et
12 oxygènes. Tout y est.

### Pour accélérer la réaction

Il suffit de placer le flacon dans de l''**eau tiède**. Comme toute réaction
chimique, celle-ci est plus rapide à température élevée. C''est une question
souvent posée en fin d''exercice.

### Le rendement

Les exercices demandent presque toujours de comparer le volume obtenu au volume
théorique. Le **rendement** se calcule ainsi :

$$r = \frac{\text{volume réellement recueilli}}{\text{volume théorique}}\times 100$$

Un rendement inférieur à 100 % s''explique par des impuretés dans le carbure, par
des fuites, ou par une réaction incomplète.

---

**Exercice corrigé**

*On traite 18 g de carbure d''aluminium par un excès d''eau.
1) Quel volume de méthane peut-on théoriquement obtenir ?
2) On recueille en réalité 3,6 L. Quel est le rendement ?
3) Quel pourcentage d''impuretés le carbure contenait-il ?
On donne $V_m = 22{,}4$ L/mol ; $Al = 27$ ; $C = 12$ g/mol.*

**Correction.**

1) Masse molaire du carbure :
$$M(Al_4C_3) = 4 \times 27 + 3 \times 12 = 108 + 36 = 144\ \text{g/mol}$$
Quantité de matière :
$$n = \frac{18}{144} = 0{,}125\ \text{mol}$$
L''équation montre qu''une mole de carbure donne **trois** moles de méthane :
$$n(CH_4) = 3 \times 0{,}125 = 0{,}375\ \text{mol}$$
$$V = n\,V_m = 0{,}375 \times 22{,}4 = 8{,}4\ \text{L}$$

2) Rendement :
$$r = \frac{3{,}6}{8{,}4}\times 100 \approx 42{,}9\,\%$$

3) Si l''on attribue toute la perte aux impuretés, la masse de carbure réellement
pur vaut $0{,}429 \times 18 \approx 7{,}7$ g. Le pourcentage d''impuretés est donc
d''environ $100 - 42{,}9 = 57{,}1\,\%$.

*Remarque.* Ce raisonnement suppose que la réaction est totale et sans fuite. En
pratique, une partie de la perte vient aussi du montage : c''est pourquoi
l''énoncé demande de « déduire » le pourcentage, et non de l''affirmer.
', NULL, 28),
      (v_chapitre_id, 'Simulation : préparer le méthane au laboratoire', 6, 'interactif', '{
  "widget": "preparation-methane",
  "consigne": "Pose le carbure d''aluminium dans le flacon et verse l''eau : le méthane se dégage et tu le recueilles par déplacement d''eau. Fais varier la masse de carbure et relève le volume de gaz obtenu, puis compare avec le volume attendu par le calcul. Ajoute un taux d''impuretés et place le flacon dans l''eau tiède pour voir ce que chaque paramètre change au rendement."
}', NULL, 10),
      (v_chapitre_id, 'Quiz du chapitre 5', 7, 'quiz', '{
  "titre": "Vérifie que tu as compris",
  "questions": [
    {
      "question": "Quel est le coefficient du dioxygène dans la combustion complète de $C_nH_{2n+2}$ ?",
      "choix": [
        "$n+1$",
        "$\\frac{3n+1}{2}$",
        "$2n$",
        "$\\frac{n+1}{2}$"
      ],
      "bonne": 1,
      "explication": "Le membre de droite contient $2n + (n+1) = 3n+1$ atomes d''oxygène, soit $\\frac{3n+1}{2}$ molécules de dioxygène."
    },
    {
      "question": "Que produit la combustion incomplète d''un alcane ?",
      "choix": [
        "Uniquement du dioxyde de carbone",
        "Du carbone et de l''eau",
        "De l''hydrogène",
        "Rien du tout"
      ],
      "bonne": 1,
      "explication": "Faute de dioxygène, le carbone n''est pas entièrement oxydé et se dépose en suie. Du monoxyde de carbone peut aussi se former, ce qui rend la combustion dangereuse en espace clos."
    },
    {
      "question": "Pourquoi la chloration du méthane ne se produit-elle pas dans l''obscurité ?",
      "choix": [
        "Parce qu''il fait trop froid",
        "Parce que c''est une réaction photochimique qui exige la lumière",
        "Parce que le chlore se dissout",
        "Parce que le méthane est trop stable"
      ],
      "bonne": 1,
      "explication": "La lumière est nécessaire pour amorcer la réaction. C''est la définition même d''une réaction photochimique."
    },
    {
      "question": "Pourquoi utilise-t-on de l''eau salée et non de l''eau pure dans l''expérience de chloration ?",
      "choix": [
        "Pour conduire le courant",
        "Parce que le chlore ne se dissout pas dans l''eau salée",
        "Pour colorer la solution",
        "Pour chauffer le mélange"
      ],
      "bonne": 1,
      "explication": "Dans l''eau pure, le dichlore se dissoudrait et l''on ne pourrait plus suivre sa disparition par la couleur."
    },
    {
      "question": "Combien de dérivés chlorés obtient-on en chlorant le méthane jusqu''au bout ?",
      "choix": [
        "1",
        "2",
        "3",
        "4"
      ],
      "bonne": 3,
      "explication": "Les quatre hydrogènes sont substitués l''un après l''autre : $CH_3Cl$, $CH_2Cl_2$, $CHCl_3$ et $CCl_4$."
    },
    {
      "question": "Quelle est l''équation de préparation du méthane au laboratoire ?",
      "choix": [
        "$CaC_2 + 2H_2O \\rightarrow C_2H_2 + Ca(OH)_2$",
        "$Al_4C_3 + 12H_2O \\rightarrow 4Al(OH)_3 + 3CH_4$",
        "$CH_3COONa + NaOH \\rightarrow CH_4 + Na_2CO_3$",
        "$C + 2H_2 \\rightarrow CH_4$"
      ],
      "bonne": 1,
      "explication": "C''est l''hydrolyse du carbure d''aluminium. La première équation proposée est celle de l''acétylène, que tu verras au chapitre 8."
    }
  ]
}', NULL, 5);

    RAISE NOTICE '% : 7 leçons ajoutées au chapitre 5, Propriétés chimiques et préparation des alcanes.', v_nom;
  END LOOP;
END $ch1$;
