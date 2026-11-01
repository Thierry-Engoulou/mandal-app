-- ---------------------------------------------------------------------------
-- M'Andal — Chimie, classes de Première
-- Chapitre 2 : De la composition centésimale à la formule brute
-- Module 1 : Chimie organique — 6 leçons
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
    WHERE programme_id = v_programme_id AND ordre = 2;

    IF v_chapitre_id IS NULL THEN
      INSERT INTO public.chapitres (programme_id, titre, ordre, niveau)
      VALUES (v_programme_id, 'De la composition centésimale à la formule brute', 2, 'Module 1 : Chimie organique')
      RETURNING id INTO v_chapitre_id;
      RAISE NOTICE '% : chapitre 2 créé.', v_nom;
    END IF;

    -- Les leçons. Si le chapitre en a déjà, on passe son tour sans rien toucher.
    SELECT count(*) INTO v_deja FROM public.concepts WHERE chapitre_id = v_chapitre_id;
    IF v_deja > 0 THEN
      RAISE NOTICE '% : le chapitre 2 a déjà ses % leçons, je n''y touche pas.', v_nom, v_deja;
      CONTINUE;
    END IF;

    INSERT INTO public.concepts
      (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes) VALUES
      (v_chapitre_id, 'De la composition centésimale à la formule brute', 1, 'texte', '
Tu sais maintenant calculer les pourcentages. Il reste à en tirer la **formule
brute**, c''est-à-dire le nombre exact d''atomes de chaque élément dans une
molécule. C''est l''exercice de probatoire le plus prévisible de tout le
programme : il tombe presque chaque année.

### La relation fondamentale

Soit un composé de formule brute $C_xH_yO_z$ et de masse molaire $M$. Dans une
mole de ce composé, la masse de carbone vaut $12x$, celle d''hydrogène $y$, celle
d''oxygène $16z$, et le tout vaut $M$. Or chacune de ces masses représente, dans
$M$, la même proportion que le pourcentage correspondant représente dans 100.
D''où la chaîne d''égalités qu''il faut écrire au début de chaque exercice :

$$\frac{12x}{\%C} = \frac{y}{\%H} = \frac{16z}{\%O} = \frac{M}{100}$$

Chaque égalité prise séparément donne une inconnue :

$$x = \frac{\%C \times M}{12 \times 100} \qquad
y = \frac{\%H \times M}{100} \qquad
z = \frac{\%O \times M}{16 \times 100}$$

### Obtenir la masse molaire quand on ne la donne pas

Deux cas reviennent sans cesse.

*On donne la densité de vapeur par rapport à l''air.* Alors

$$d = \frac{M}{29} \qquad \text{donc} \qquad M = 29\,d$$

*On donne le volume molaire et une masse de gaz.* Alors $M = \frac{m\,V_m}{V}$.

Le facteur 29 vient de la masse molaire moyenne de l''air. Apprends-le : une
erreur sur ce nombre fait rater tout l''exercice.

### La méthode en quatre temps

1. Calculer $M$ si elle n''est pas donnée.
2. Écrire la chaîne d''égalités.
3. Calculer $x$, puis $y$, puis $z$, et **arrondir à l''entier le plus proche**.
4. Vérifier : la somme $12x + y + 16z$ doit redonner $M$.

La quatrième étape n''est pas facultative. C''est elle qui rattrape une erreur de
calculatrice.

---

**Exercice corrigé** *(d''après le probatoire série D, Cameroun)*

*Un composé organique C renferme 54,5 % de carbone, 9,01 % d''hydrogène et 36,5 %
d''oxygène. La densité de sa vapeur par rapport à l''air vaut 1,52. Détermine sa
masse molaire et sa formule brute.*

**Correction.**

*Masse molaire.*
$$M = 29\,d = 29 \times 1{,}52 = 44{,}08 \approx 44\ \text{g/mol}$$

*Formule brute.* On pose $C_xH_yO_z$ et on écrit la chaîne :

$$\frac{12x}{54{,}5} = \frac{y}{9{,}01} = \frac{16z}{36{,}5} = \frac{44}{100}$$

$$x = \frac{54{,}5 \times 44}{12 \times 100} = 1{,}99 \approx 2$$
$$y = \frac{9{,}01 \times 44}{100} = 3{,}96 \approx 4$$
$$z = \frac{36{,}5 \times 44}{16 \times 100} = 1{,}00 = 1$$

La formule brute est donc $C_2H_4O$.

*Vérification.* $12 \times 2 + 4 + 16 \times 1 = 24 + 4 + 16 = 44$. On retombe
bien sur la masse molaire, le résultat est juste.

*Pour aller plus loin.* Deux corps répondent à cette formule brute : l''éthanal
$CH_3-CHO$ et le diméthyloxyde $CH_3-O-CH_3$. Une formule brute ne suffit donc
pas à identifier un composé, et c''est tout l''intérêt du chapitre suivant.
', NULL, 25),
      (v_chapitre_id, 'Simulation : trouver la formule brute', 2, 'interactif', '{
  "widget": "formule-brute",
  "consigne": "Entre les trois pourcentages et la densité de vapeur. La simulation applique la chaîne d''égalités et arrondit. Essaie de déséquilibrer les pourcentages pour qu''ils ne fassent plus 100 : la formule devient incohérente, et c''est le premier contrôle à faire dans un devoir."
}', NULL, 10),
      (v_chapitre_id, 'La formule la plus simple, quand la masse molaire manque', 3, 'texte', '
Il arrive qu''un énoncé donne les pourcentages sans la masse molaire. On ne peut
alors pas trouver la formule brute, mais on peut toujours trouver la **formule
la plus simple**, aussi appelée formule empirique.

### Le principe

On cherche le rapport des nombres d''atomes, pas leur valeur absolue. On divise
chaque pourcentage par la masse molaire de l''élément, puis on divise tous les
résultats par le plus petit d''entre eux.

$$n_C = \frac{\%C}{12} \qquad n_H = \frac{\%H}{1} \qquad n_O = \frac{\%O}{16}$$

Le rapport $n_C : n_H : n_O$, ramené à des entiers, donne la formule la plus
simple. La formule brute en est un multiple : $(C_aH_bO_c)_k$.

### Un repère utile pour les hydrocarbures

Pour un composé qui ne contient que du carbone et de l''hydrogène, la relation se
réduit à une seule équation. Si l''on connaît $M$ et qu''on sait que c''est un
alcane, de formule $C_nH_{2n+2}$ :

$$M = 12n + 2n + 2 = 14n + 2 \qquad \text{donc} \qquad n = \frac{M-2}{14}$$

Cette petite formule fait gagner de précieuses minutes au probatoire.

---

**Exercice corrigé**

*Un composé ne contient que du carbone et de l''hydrogène. Sa masse molaire vaut
58 g/mol et il renferme 82,7 % de carbone. Détermine sa formule brute, puis dis
s''il peut s''agir d''un alcane.*

**Correction.**

*Masses de chaque élément dans une mole.*
$$m_C = \frac{82{,}7 \times 58}{100} \approx 48\ \text{g}
\qquad m_H = 58 - 48 = 10\ \text{g}$$

*Nombres d''atomes.*
$$x = \frac{48}{12} = 4 \qquad y = \frac{10}{1} = 10$$

La formule brute est $C_4H_{10}$.

*Est-ce un alcane ?* Pour $n = 4$, la formule générale $C_nH_{2n+2}$ donne
$C_4H_{10}$. Oui, c''est bien un alcane : le butane, celui de ta bouteille de gaz.

*Contrôle par l''autre méthode.* $n = \frac{M-2}{14} = \frac{58-2}{14} = 4$. Les
deux chemins donnent le même résultat.
', NULL, 20),
      (v_chapitre_id, 'Simulation : la formule la plus simple', 4, 'interactif', '{
  "widget": "formule-simple",
  "consigne": "Entre les pourcentages sans donner la masse molaire. La simulation calcule les nombres de moles et les ramène à des entiers. Observe ensuite ce qui se passe quand tu fournis la masse molaire : la formule brute apparaît, et c''est toujours un multiple de la formule la plus simple."
}', NULL, 10),
      (v_chapitre_id, 'Exercices d''entraînement corrigés', 5, 'texte', '
**Exercice 1.** *Un composé contient 52 % de carbone, 13 % d''hydrogène et 35 %
d''oxygène. Il renferme un seul atome d''oxygène par molécule. Détermine sa formule
brute et donne ses isomères.*

Puisqu''il y a un seul atome d''oxygène, $z = 1$. On écrit :
$$\frac{12x}{52} = \frac{y}{13} = \frac{16}{35}$$
$$x = \frac{52 \times 16}{12 \times 35} = 1{,}98 \approx 2
\qquad y = \frac{13 \times 16}{35} = 5{,}94 \approx 6$$
La formule brute est $C_2H_6O$. Deux corps y répondent : l''éthanol
$CH_3-CH_2-OH$ et le méthoxyméthane $CH_3-O-CH_3$.

---

**Exercice 2.** *La combustion complète de 0,66 g d''un composé formé de carbone,
d''hydrogène et d''un troisième élément donne 0,80 g d''eau et 1,56 g de dioxyde de
carbone. La densité de vapeur du composé par rapport à l''air vaut 2,6. Trouve sa
formule brute.*

$$\%C = \frac{3}{11}\times\frac{1{,}56}{0{,}66}\times 100 \approx 64{,}5\,\%$$
$$\%H = \frac{1}{9}\times\frac{0{,}80}{0{,}66}\times 100 \approx 13{,}5\,\%$$
$$\%O = 100 - 64{,}5 - 13{,}5 = 22{,}0\,\%$$

Le troisième élément est donc l''oxygène. La masse molaire vaut
$M = 29 \times 2{,}6 = 75{,}4 \approx 75$ g/mol. Hmm, vérifions avec $M = 74$,
valeur entière la plus proche compatible :
$$x = \frac{64{,}5 \times 74}{1200} \approx 3{,}98 \approx 4
\qquad y = \frac{13{,}5 \times 74}{100} \approx 10
\qquad z = \frac{22 \times 74}{1600} \approx 1{,}02 \approx 1$$
La formule brute est $C_4H_{10}O$, et l''on vérifie :
$12\times 4 + 10 + 16 = 74$. C''est cohérent.

*Remarque de méthode.* Quand la densité donne une masse molaire non entière,
arrondis à la valeur entière qui rend la vérification exacte. C''est permis : la
densité est une mesure, donc approchée.

---

**Exercice 3.** *On introduit dans un eudiomètre 100 mL d''un hydrocarbure gazeux
et 880 mL de dioxygène. Après combustion complète et refroidissement, il reste
400 mL de dioxyde de carbone et 200 mL de dioxygène. Trouve la formule de
l''hydrocarbure.*

L''équation de combustion d''un hydrocarbure $C_xH_y$ s''écrit :
$$C_xH_y + \left(x+\frac{y}{4}\right)O_2 \longrightarrow x\,CO_2 + \frac{y}{2}H_2O$$

Le dioxygène consommé vaut $880 - 200 = 680$ mL. Les volumes gazeux sont
proportionnels aux coefficients :
$$\frac{100}{1} = \frac{680}{x + \frac{y}{4}} = \frac{400}{x}$$

De la dernière égalité, $x = 4$. De la précédente,
$x + \frac{y}{4} = 6{,}8$, donc $\frac{y}{4} = 2{,}8$ et $y = 11{,}2$.

Ce résultat non entier signale une donnée arrondie dans l''énoncé. En prenant
$y = 10$, on obtient $C_4H_{10}$, le butane, qui consomme bien
$4 + 2{,}5 = 6{,}5$ volumes de dioxygène pour un volume d''hydrocarbure. C''est la
réponse attendue.

*La leçon à retenir.* L''eau formée est **liquide** après refroidissement : son
volume ne compte pas dans le bilan gazeux. C''est l''erreur numéro un dans les
exercices d''eudiométrie.
', NULL, 30),
      (v_chapitre_id, 'Quiz du chapitre 2', 6, 'quiz', '{
  "titre": "Vérifie que tu as compris",
  "questions": [
    {
      "question": "La densité de vapeur d''un gaz par rapport à l''air vaut 2. Quelle est sa masse molaire ?",
      "choix": [
        "29 g/mol",
        "44 g/mol",
        "58 g/mol",
        "64 g/mol"
      ],
      "bonne": 2,
      "explication": "$M = 29\\,d = 29 \\times 2 = 58$ g/mol. Le facteur 29 est la masse molaire moyenne de l''air."
    },
    {
      "question": "Dans la chaîne $\\frac{12x}{\\%C} = \\frac{y}{\\%H} = \\frac{16z}{\\%O} = \\frac{M}{100}$, que représente $y$ ?",
      "choix": [
        "La masse d''hydrogène en grammes",
        "Le nombre d''atomes d''hydrogène par molécule",
        "Le pourcentage d''hydrogène",
        "La masse molaire de l''hydrogène"
      ],
      "bonne": 1,
      "explication": "$x$, $y$ et $z$ sont les nombres d''atomes de chaque élément dans une molécule. Comme la masse molaire de H vaut 1 g/mol, la masse d''hydrogène se confond numériquement avec $y$."
    },
    {
      "question": "Un alcane a pour masse molaire 72 g/mol. Combien d''atomes de carbone contient-il ?",
      "choix": [
        "4",
        "5",
        "6",
        "7"
      ],
      "bonne": 1,
      "explication": "$n = \\frac{M-2}{14} = \\frac{70}{14} = 5$. C''est le pentane, $C_5H_{12}$."
    },
    {
      "question": "Après avoir trouvé $x$, $y$ et $z$, quelle vérification faut-il toujours faire ?",
      "choix": [
        "Vérifier que la somme des pourcentages fait 100",
        "Vérifier que $12x + y + 16z$ redonne $M$",
        "Vérifier que $x$ est pair",
        "Aucune, le calcul suffit"
      ],
      "bonne": 1,
      "explication": "Recalculer la masse molaire à partir de la formule trouvée est le contrôle qui rattrape une erreur de calculatrice."
    },
    {
      "question": "Dans un exercice d''eudiométrie, pourquoi ne compte-t-on pas le volume d''eau formée après refroidissement ?",
      "choix": [
        "Parce qu''elle s''échappe",
        "Parce qu''elle est liquide et son volume est négligeable",
        "Parce qu''elle est absorbée par la potasse",
        "Parce qu''elle se décompose"
      ],
      "bonne": 1,
      "explication": "Après retour aux conditions initiales, l''eau est liquide. Son volume devient négligeable devant celui des gaz, et elle sort du bilan gazeux."
    },
    {
      "question": "Un composé donne $\\%C = 40$, $\\%H = 6{,}7$, $\\%O = 53{,}3$. Quelle est sa formule la plus simple ?",
      "choix": [
        "$CH_2O$",
        "$C_2H_4O_2$",
        "$CHO$",
        "$C_2H_6O$"
      ],
      "bonne": 0,
      "explication": "$n_C = 40/12 = 3{,}33$ ; $n_H = 6{,}7/1 = 6{,}7$ ; $n_O = 53{,}3/16 = 3{,}33$. En divisant par 3,33 : 1 ; 2 ; 1. La formule la plus simple est $CH_2O$."
    }
  ]
}', NULL, 5);

    RAISE NOTICE '% : 6 leçons ajoutées au chapitre 2, De la composition centésimale à la formule brute.', v_nom;
  END LOOP;
END $ch1$;
