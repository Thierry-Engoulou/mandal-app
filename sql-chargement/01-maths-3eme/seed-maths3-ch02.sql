-- ============================================================================
-- MANDAL — Mathématiques 3ème : chapitre 2, Nombres réels
-- 13 leçons.
--
-- Autonome : ce fichier cree lui-meme le programme et le chapitre s'ils
-- n'existent pas encore. Vous pouvez le lancer seul, dans n'importe quel ordre.
-- Idempotent : si le chapitre contient deja des lecons, rien n'est ajoute.
-- ============================================================================
DO $m3$
DECLARE
  v_matiere_id uuid;
  v_classe_id uuid;
  v_etab_id uuid;
  v_programme_id uuid;
  v_chapitre_id uuid;
  v_nb_etabs int;
  v_deja int;
BEGIN
  -- 1. le programme existe-t-il deja ?
  SELECT p.id INTO v_programme_id FROM public.programmes p
  WHERE p.titre = 'Mathématiques — 3ème';

  -- 2. sinon on le cree
  IF v_programme_id IS NULL THEN
    INSERT INTO public.matieres (nom) VALUES ('Mathématiques') ON CONFLICT (nom) DO NOTHING;
    SELECT id INTO v_matiere_id FROM public.matieres WHERE nom = 'Mathématiques';

    SELECT count(DISTINCT etablissement_id) INTO v_nb_etabs FROM public.classes;
    IF v_nb_etabs <> 1 THEN
      RAISE EXCEPTION 'Impossible de deduire l''etablissement : % etablissement(s) distinct(s) dans public.classes.', v_nb_etabs;
    END IF;
    SELECT etablissement_id INTO v_etab_id FROM public.classes LIMIT 1;

    SELECT id INTO v_classe_id FROM public.classes
    WHERE nom = '3ème' AND etablissement_id = v_etab_id LIMIT 1;
    IF v_classe_id IS NULL THEN
      RAISE EXCEPTION 'Classe "3ème" introuvable dans public.classes.';
    END IF;

    INSERT INTO public.programmes (matiere_id, classe_id, etablissement_id, titre, description)
    VALUES (v_matiere_id, v_classe_id, v_etab_id, 'Mathématiques — 3ème',
            'Programme de Mathématiques, classe de 3ème (BEPC) — 4 modules, 16 chapitres.')
    RETURNING id INTO v_programme_id;
    RAISE NOTICE 'Programme "Mathématiques — 3ème" cree.';
  END IF;

  -- 3. le chapitre existe-t-il deja ?
  SELECT id INTO v_chapitre_id FROM public.chapitres
  WHERE programme_id = v_programme_id AND ordre = 2;

  -- 4. sinon on le cree
  IF v_chapitre_id IS NULL THEN
    INSERT INTO public.chapitres (programme_id, titre, ordre, niveau)
    VALUES (v_programme_id, 'Nombres réels', 2, 'Module 13 : Relations et opérations fondamentales dans l''ensemble des nombres réels')
    RETURNING id INTO v_chapitre_id;
    RAISE NOTICE 'Chapitre 2 cree.';
  END IF;

  -- 5. les lecons
  SELECT count(*) INTO v_deja FROM public.concepts WHERE chapitre_id = v_chapitre_id;
  IF v_deja > 0 THEN
    RAISE NOTICE 'Chapitre 2 : contient deja % lecon(s) — aucun ajout.', v_deja;
    RETURN;
  END IF;

  INSERT INTO public.concepts
    (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes) VALUES
    (v_chapitre_id, 'La racine carrée d''un nombre réel', 1, 'texte', 'Un menuisier de Bafoussam doit découper une plaque carrée de 50 cm² de surface. Quelle longueur doit faire le côté ? Tu cherches un nombre qui, multiplié par lui-même, donne 50. C''est exactement ce qu''on appelle une racine carrée.

## Définition

Soit $a$ un nombre réel positif. La racine carrée de $a$, notée $\sqrt{a}$, est l''unique nombre positif dont le carré vaut $a$.

Autrement dit $\sqrt{a} \geq 0$ et $(\sqrt{a})^{2} = a$.

Attention, $\sqrt{a}$ n''existe que si $a \geq 0$. L''expression $\sqrt{-9}$ n''a aucun sens en 3ème.

## Les carrés parfaits

Certains nombres tombent juste. Ce sont les carrés parfaits, et tu dois les connaître par cœur :

$\sqrt{0} = 0$, $\sqrt{1} = 1$, $\sqrt{4} = 2$, $\sqrt{9} = 3$, $\sqrt{16} = 4$, $\sqrt{25} = 5$, $\sqrt{36} = 6$, $\sqrt{49} = 7$, $\sqrt{64} = 8$, $\sqrt{81} = 9$, $\sqrt{100} = 10$, $\sqrt{121} = 11$, $\sqrt{144} = 12$.

Pour 50, aucun entier ne convient : $7^{2} = 49$ et $8^{2} = 64$. Le côté de la plaque mesure donc entre 7 et 8 cm, environ 7,07 cm.

## Une formule à ne pas confondre

Pour tout réel $a$, on a $\sqrt{a^{2}} = |a|$, c''est-à-dire la distance de $a$ à zéro.

Si $a$ est positif, $\sqrt{a^{2}} = a$. Par exemple $\sqrt{5^{2}} = 5$.

Si $a$ est négatif, $\sqrt{a^{2}} = -a$. Par exemple $\sqrt{(-5)^{2}} = \sqrt{25} = 5$, et non $-5$. Une racine carrée n''est jamais négative.

## Exercice d''application

Calcule $\sqrt{169}$, $\sqrt{0{,}04}$ et $\sqrt{(-7)^{2}}$.

Correction. $\sqrt{169} = 13$ car $13^{2} = 169$. Ensuite $\sqrt{0{,}04} = 0{,}2$ car $0{,}2^{2} = 0{,}04$. Enfin $\sqrt{(-7)^{2}} = \sqrt{49} = 7$.', NULL, 15),
    (v_chapitre_id, 'Simulation : la racine carrée est une longueur', 2, 'interactif', '{
  "widget": "racine-carree",
  "consigne": "Règle l''aire sur 16 : le carré bleu a un côté de 4, et tu lis $\\sqrt{16} = 4$. Passe maintenant à 20 : plus aucun entier ne convient, le côté tombe entre 4 et 5. Les deux traits verts te montrent cet encadrement. Cherche toutes les aires pour lesquelles le côté est un nombre entier : tu retrouveras la liste des carrés parfaits."
}', NULL, 10),
    (v_chapitre_id, 'Les propriétés des radicaux', 3, 'texte', 'Il y a trois règles à connaître, et une erreur classique à éviter absolument.

## Produit et quotient

Pour tous réels positifs $a$ et $b$ :

$$\sqrt{a \times b} = \sqrt{a} \times \sqrt{b}$$

Et si en plus $b$ n''est pas nul :

$$\sqrt{\dfrac{a}{b}} = \dfrac{\sqrt{a}}{\sqrt{b}}$$

## L''erreur à ne jamais faire

La racine carrée ne traverse pas une addition. En général

$$\sqrt{a + b} \neq \sqrt{a} + \sqrt{b}$$

Vérifie-le : $\sqrt{9 + 16} = \sqrt{25} = 5$, alors que $\sqrt{9} + \sqrt{16} = 3 + 4 = 7$. Ce n''est pas du tout pareil.

## Simplifier une racine

La règle du produit sert surtout à sortir un carré parfait de sous la racine. Tu cherches le plus grand carré parfait qui divise le nombre.

$$\sqrt{50} = \sqrt{25 \times 2} = \sqrt{25} \times \sqrt{2} = 5\sqrt{2}$$

$$\sqrt{72} = \sqrt{36 \times 2} = 6\sqrt{2}$$

$$\sqrt{98} = \sqrt{49 \times 2} = 7\sqrt{2}$$

La plaque du menuisier a donc un côté de $5\sqrt{2}$ cm exactement, soit environ 7,07 cm.

## Exercice d''application

Écris $\sqrt{45}$, $\sqrt{200}$ et $\sqrt{\dfrac{49}{16}}$ le plus simplement possible.

Correction. $\sqrt{45} = \sqrt{9 \times 5} = 3\sqrt{5}$. Ensuite $\sqrt{200} = \sqrt{100 \times 2} = 10\sqrt{2}$. Enfin $\sqrt{\dfrac{49}{16}} = \dfrac{\sqrt{49}}{\sqrt{16}} = \dfrac{7}{4}$.', NULL, 15),
    (v_chapitre_id, 'Opérations avec les radicaux', 4, 'texte', 'Maintenant que tu sais simplifier, tu peux additionner et diviser proprement.

## Additionner des radicaux

On ne peut regrouper que des radicaux identiques, exactement comme on regroupe $3x + 5x = 8x$.

$$3\sqrt{2} + 5\sqrt{2} = 8\sqrt{2}$$

En revanche $3\sqrt{2} + 5\sqrt{3}$ ne se simplifie pas : les radicaux sont différents.

Le piège, c''est quand ils semblent différents mais ne le sont pas. Simplifie d''abord :

$$\sqrt{8} + \sqrt{18} = 2\sqrt{2} + 3\sqrt{2} = 5\sqrt{2}$$

## Rendre rationnel un dénominateur

Un résultat ne se laisse pas avec une racine au dénominateur. Tu multiplies le haut et le bas par cette racine.

$$\dfrac{1}{\sqrt{3}} = \dfrac{1 \times \sqrt{3}}{\sqrt{3} \times \sqrt{3}} = \dfrac{\sqrt{3}}{3}$$

$$\dfrac{6}{\sqrt{2}} = \dfrac{6\sqrt{2}}{2} = 3\sqrt{2}$$

Quand le dénominateur est une somme, tu multiplies par l''expression conjuguée, celle où le signe du milieu change. L''identité $(a-b)(a+b) = a^{2} - b^{2}$ fait alors disparaître la racine.

$$\dfrac{1}{\sqrt{5} - \sqrt{3}} = \dfrac{\sqrt{5} + \sqrt{3}}{(\sqrt{5} - \sqrt{3})(\sqrt{5} + \sqrt{3})} = \dfrac{\sqrt{5} + \sqrt{3}}{5 - 3} = \dfrac{\sqrt{5} + \sqrt{3}}{2}$$

## Exercice d''application

Calcule $A = \sqrt{12} + \sqrt{27} - \sqrt{3}$ et $B = \dfrac{10}{\sqrt{5}}$.

Correction. $\sqrt{12} = 2\sqrt{3}$ et $\sqrt{27} = 3\sqrt{3}$, donc $A = 2\sqrt{3} + 3\sqrt{3} - \sqrt{3} = 4\sqrt{3}$. Pour $B$, on écrit $B = \dfrac{10\sqrt{5}}{5} = 2\sqrt{5}$.', NULL, 15),
    (v_chapitre_id, 'Quiz : racines carrées et radicaux', 5, 'quiz', '{
  "titre": "Vérifie que tu as compris",
  "questions": [
    {
      "question": "Que vaut $\\sqrt{(-6)^{2}}$ ?",
      "choix": [
        "$-6$",
        "$6$",
        "$36$"
      ],
      "bonne": 1,
      "explication": "D''abord $(-6)^{2} = 36$, puis $\\sqrt{36} = 6$. Une racine carrée est toujours positive."
    },
    {
      "question": "La forme la plus simple de $\\sqrt{75}$ est :",
      "choix": [
        "$5\\sqrt{3}$",
        "$3\\sqrt{5}$",
        "$25\\sqrt{3}$"
      ],
      "bonne": 0,
      "explication": "$75 = 25 \\times 3$, donc $\\sqrt{75} = \\sqrt{25} \\times \\sqrt{3} = 5\\sqrt{3}$."
    },
    {
      "question": "$\\sqrt{16 + 9}$ est égal à :",
      "choix": [
        "$7$",
        "$5$",
        "$25$"
      ],
      "bonne": 1,
      "explication": "On calcule d''abord la somme : $16 + 9 = 25$, puis $\\sqrt{25} = 5$. La racine ne se répartit pas sur une addition."
    },
    {
      "question": "$\\dfrac{4}{\\sqrt{2}}$ s''écrit aussi :",
      "choix": [
        "$2\\sqrt{2}$",
        "$4\\sqrt{2}$",
        "$\\sqrt{2}$"
      ],
      "bonne": 0,
      "explication": "On multiplie haut et bas par $\\sqrt{2}$ : $\\dfrac{4\\sqrt{2}}{2} = 2\\sqrt{2}$."
    }
  ]
}', NULL, 5),
    (v_chapitre_id, 'Comparer deux nombres réels', 6, 'texte', 'Pour savoir lequel de deux nombres est le plus grand, la méthode la plus sûre est toujours la même : tu étudies le signe de leur différence.

## La méthode de la différence

Si $a - b > 0$ alors $a > b$. Si $a - b < 0$ alors $a < b$. Et si $a - b = 0$ les deux nombres sont égaux.

Compare $\dfrac{3}{4}$ et $\dfrac{5}{7}$. La différence vaut $\dfrac{3}{4} - \dfrac{5}{7} = \dfrac{21 - 20}{28} = \dfrac{1}{28}$, qui est positif. Donc $\dfrac{3}{4} > \dfrac{5}{7}$.

## Comparer des racines carrées

La fonction racine carrée respecte l''ordre. Pour $a$ et $b$ positifs, $a < b$ équivaut à $\sqrt{a} < \sqrt{b}$.

Donc $\sqrt{7} < \sqrt{11}$, sans aucun calcul, puisque $7 < 11$.

Pour comparer $3\sqrt{2}$ et $2\sqrt{5}$, fais rentrer le nombre sous la racine en l''élevant au carré : $3\sqrt{2} = \sqrt{9 \times 2} = \sqrt{18}$ et $2\sqrt{5} = \sqrt{4 \times 5} = \sqrt{20}$. Comme $18 < 20$, on conclut $3\sqrt{2} < 2\sqrt{5}$.

## Attention au nombre négatif

Multiplier les deux membres d''une inégalité par un nombre négatif renverse le sens. De $2 < 5$ on déduit $-2 > -5$. Garde ce réflexe, il te servira dans tout le chapitre sur les inéquations.

## Exercice d''application

Range dans l''ordre croissant : $4$, $\sqrt{17}$, $3\sqrt{2}$.

Correction. On écrit tout sous forme de racine : $4 = \sqrt{16}$, puis $3\sqrt{2} = \sqrt{18}$. Comme $16 < 17 < 18$, l''ordre croissant est $4 < \sqrt{17} < 3\sqrt{2}$.', NULL, 15),
    (v_chapitre_id, 'Les intervalles de ℝ', 7, 'texte', 'Quand une grandeur peut prendre toutes les valeurs entre deux bornes, on ne peut pas les énumérer : il y en a une infinité. On utilise alors un intervalle.

## Lire les crochets

Le crochet tourné vers l''intérieur veut dire que la borne est comprise, le crochet tourné vers l''extérieur veut dire qu''elle est exclue.

$[a\,;b]$ est l''ensemble des réels $x$ tels que $a \leq x \leq b$. Les deux bornes sont comprises, on dit que l''intervalle est fermé.

$]a\,;b[$ est l''ensemble des réels $x$ tels que $a < x < b$. Aucune borne n''est comprise, l''intervalle est ouvert.

$[a\,;b[$ correspond à $a \leq x < b$, et $]a\,;b]$ à $a < x \leq b$.

On utilise aussi l''infini, qui n''est jamais compris : $[a\,;+\infty[$ désigne les $x \geq a$, et $]-\infty\,;b]$ désigne les $x \leq b$.

## Un exemple concret

Un taxi de Douala accepte les courses dont le prix est d''au moins 500 FCFA et de moins de 2 000 FCFA. L''ensemble des prix acceptés est l''intervalle $[500\,;2\,000[$. Le prix 500 convient, le prix 2 000 ne convient pas.

## Réunion et intersection

L''intersection $\cap$ rassemble ce qui est dans les deux intervalles à la fois. La réunion $\cup$ rassemble ce qui est dans l''un ou dans l''autre.

$[1\,;6] \cap [4\,;9] = [4\,;6]$, et $[1\,;6] \cup [4\,;9] = [1\,;9]$.

## Exercice d''application

Écris sous forme d''intervalle l''ensemble des réels $x$ tels que $-3 < x \leq 7$, puis donne $]-3\,;7] \cap [0\,;+\infty[$.

Correction. Le premier ensemble est $]-3\,;7]$. Pour l''intersection, on garde les nombres à la fois supérieurs à $-3$ et positifs ou nuls, et inférieurs ou égaux à 7 : c''est $[0\,;7]$.', NULL, 15),
    (v_chapitre_id, 'Simulation : crochets ouverts et crochets fermés', 8, 'interactif', '{
  "widget": "intervalles",
  "consigne": "Place la borne $a$ sur $-2$ et la borne $b$ sur $3$. Choisis le crochet fermé à gauche et ouvert à droite : tu obtiens $[-2\\,;3[$. Amène maintenant le point vert exactement sur $-2$, puis exactement sur $3$, et regarde la réponse changer. Recommence en inversant les crochets : tu verras que seul le type de crochet décide si la borne appartient ou non à l''intervalle."
}', NULL, 10),
    (v_chapitre_id, 'Encadrer un nombre réel', 9, 'texte', 'Encadrer, c''est coincer un nombre entre deux valeurs connues. C''est utile dès qu''un nombre ne s''écrit pas exactement, comme $\sqrt{2}$ ou $\pi$.

## Encadrement et amplitude

Encadrer $x$, c''est écrire $a \leq x \leq b$. La différence $b - a$ s''appelle l''amplitude de l''encadrement. Plus l''amplitude est petite, plus l''encadrement est précis.

Pour $\sqrt{17}$ : comme $16 < 17 < 25$, on a d''abord $4 < \sqrt{17} < 5$, avec une amplitude de 1. En affinant, $4{,}1^{2} = 16{,}81$ et $4{,}2^{2} = 17{,}64$, donc $4{,}1 < \sqrt{17} < 4{,}2$, avec une amplitude de 0,1.

## Valeur approchée

Dans l''encadrement $4{,}1 < \sqrt{17} < 4{,}2$, le nombre 4,1 est une valeur approchée par défaut à 0,1 près, et 4,2 une valeur approchée par excès à 0,1 près.

## Encadrer une somme et un produit

Si $a \leq x \leq b$ et $c \leq y \leq d$, alors $a + c \leq x + y \leq b + d$. On additionne les bornes entre elles.

Pour une différence, il faut croiser : $a - d \leq x - y \leq b - c$. C''est une erreur fréquente, fais attention.

Pour un produit de nombres positifs, on multiplie les bornes entre elles : $ac \leq xy \leq bd$.

## Un exemple du marché

Un sac de riz pèse entre 24,8 kg et 25,2 kg. Un sac de haricots pèse entre 9,7 kg et 10,3 kg. La masse totale est donc comprise entre $24{,}8 + 9{,}7 = 34{,}5$ kg et $25{,}2 + 10{,}3 = 35{,}5$ kg.

## Exercice d''application

On sait que $2{,}2 < \sqrt{5} < 2{,}3$ et $1{,}7 < \sqrt{3} < 1{,}8$. Encadre $\sqrt{5} + \sqrt{3}$ puis $\sqrt{5} - \sqrt{3}$.

Correction. Pour la somme, $2{,}2 + 1{,}7 < \sqrt{5} + \sqrt{3} < 2{,}3 + 1{,}8$, soit $3{,}9 < \sqrt{5} + \sqrt{3} < 4{,}1$. Pour la différence, on croise : $2{,}2 - 1{,}8 < \sqrt{5} - \sqrt{3} < 2{,}3 - 1{,}7$, soit $0{,}4 < \sqrt{5} - \sqrt{3} < 0{,}6$.', NULL, 15),
    (v_chapitre_id, 'Les puissances à exposant entier relatif', 10, 'texte', 'Tu connais déjà $2^{3} = 8$. Il reste à comprendre ce que veut dire un exposant négatif.

## Définition

Pour un réel $a$ non nul et un entier naturel $n$ :

$$a^{-n} = \dfrac{1}{a^{n}} \qquad \text{et} \qquad a^{0} = 1$$

Par exemple $10^{-3} = \dfrac{1}{10^{3}} = \dfrac{1}{1\,000} = 0{,}001$, et $5^{-1} = \dfrac{1}{5} = 0{,}2$.

## Les règles de calcul

Elles sont les mêmes que pour les exposants positifs. Pour $a$ et $b$ non nuls, $m$ et $n$ entiers relatifs :

$$a^{m} \times a^{n} = a^{m+n} \qquad \dfrac{a^{m}}{a^{n}} = a^{m-n} \qquad (a^{m})^{n} = a^{m \times n}$$

$$(a \times b)^{n} = a^{n} \times b^{n} \qquad \left(\dfrac{a}{b}\right)^{n} = \dfrac{a^{n}}{b^{n}}$$

Exemple : $2^{5} \times 2^{-3} = 2^{2} = 4$, et $\dfrac{10^{7}}{10^{4}} = 10^{3} = 1\,000$.

## L''écriture scientifique

Tout nombre décimal non nul s''écrit $a \times 10^{n}$ avec $1 \leq |a| < 10$ et $n$ entier relatif. C''est l''écriture scientifique, très pratique pour les très grands et les très petits nombres.

La population du Cameroun, environ 28 000 000 d''habitants, s''écrit $2{,}8 \times 10^{7}$ habitants. Le diamètre d''un globule rouge, 0,000 007 m, s''écrit $7 \times 10^{-6}$ m.

## Exercice d''application

Donne l''écriture scientifique de $A = 45\,000$ et de $B = 0{,}000\,32$, puis calcule $A \times B$.

Correction. $A = 4{,}5 \times 10^{4}$ et $B = 3{,}2 \times 10^{-4}$. Le produit vaut $A \times B = 4{,}5 \times 3{,}2 \times 10^{4-4} = 14{,}4 \times 10^{0} = 14{,}4$, soit $1{,}44 \times 10^{1}$ en écriture scientifique.', NULL, 15),
    (v_chapitre_id, 'Quiz : intervalles, encadrements et puissances', 11, 'quiz', '{
  "titre": "Vérifie que tu as compris",
  "questions": [
    {
      "question": "L''ensemble des réels $x$ tels que $x \\geq -4$ s''écrit :",
      "choix": [
        "$]-\\infty\\,;-4]$",
        "$[-4\\,;+\\infty[$",
        "$]-4\\,;+\\infty]$"
      ],
      "bonne": 1,
      "explication": "La borne $-4$ est comprise, donc crochet fermé sur $-4$, et l''infini n''est jamais compris, donc crochet ouvert."
    },
    {
      "question": "$[2\\,;8] \\cap [5\\,;12]$ vaut :",
      "choix": [
        "$[2\\,;12]$",
        "$[5\\,;8]$",
        "$[2\\,;5]$"
      ],
      "bonne": 1,
      "explication": "L''intersection garde les nombres présents dans les deux intervalles à la fois : entre 5 et 8."
    },
    {
      "question": "Sachant que $3 < x < 4$ et $1 < y < 2$, on peut affirmer que :",
      "choix": [
        "$2 < x - y < 2$",
        "$1 < x - y < 3$",
        "$4 < x - y < 6$"
      ],
      "bonne": 1,
      "explication": "Pour une différence, on croise les bornes : $3 - 2 < x - y < 4 - 1$, soit $1 < x - y < 3$."
    },
    {
      "question": "$3^{-2}$ est égal à :",
      "choix": [
        "$-9$",
        "$\\dfrac{1}{9}$",
        "$-\\dfrac{1}{6}$"
      ],
      "bonne": 1,
      "explication": "Un exposant négatif donne l''inverse : $3^{-2} = \\dfrac{1}{3^{2}} = \\dfrac{1}{9}$. Le résultat reste positif."
    },
    {
      "question": "L''écriture scientifique de $0{,}00056$ est :",
      "choix": [
        "$5{,}6 \\times 10^{-4}$",
        "$56 \\times 10^{-5}$",
        "$5{,}6 \\times 10^{4}$"
      ],
      "bonne": 0,
      "explication": "Il faut un seul chiffre non nul avant la virgule. On déplace la virgule de 4 rangs vers la droite, donc l''exposant est $-4$."
    }
  ]
}', NULL, 5),
    (v_chapitre_id, 'Exercices d''entraînement corrigés', 12, 'texte', 'Cherche d''abord seul, la correction vient après.

## Exercice 1

Écris le plus simplement possible : $A = \sqrt{18} - \sqrt{8} + \sqrt{32}$.

Correction. $\sqrt{18} = 3\sqrt{2}$, $\sqrt{8} = 2\sqrt{2}$ et $\sqrt{32} = 4\sqrt{2}$. Donc $A = 3\sqrt{2} - 2\sqrt{2} + 4\sqrt{2} = 5\sqrt{2}$.

## Exercice 2

Rends rationnel le dénominateur de $B = \dfrac{3}{2 - \sqrt{3}}$.

Correction. On multiplie par l''expression conjuguée $2 + \sqrt{3}$ :
$$B = \dfrac{3(2 + \sqrt{3})}{(2 - \sqrt{3})(2 + \sqrt{3})} = \dfrac{3(2 + \sqrt{3})}{4 - 3} = 3(2 + \sqrt{3}) = 6 + 3\sqrt{3}$$

## Exercice 3

Compare $\sqrt{50}$ et $7$, puis $5\sqrt{3}$ et $3\sqrt{5}$.

Correction. $7 = \sqrt{49}$ et $49 < 50$, donc $7 < \sqrt{50}$. Ensuite $5\sqrt{3} = \sqrt{75}$ et $3\sqrt{5} = \sqrt{45}$. Comme $45 < 75$, on a $3\sqrt{5} < 5\sqrt{3}$.

## Exercice 4

Donne l''intervalle solution, puis son amplitude, de l''ensemble des réels $x$ vérifiant $-1 \leq x < 6$.

Correction. C''est l''intervalle $[-1\,;6[$. Son amplitude vaut $6 - (-1) = 7$.

## Exercice 5

Calcule $C = \dfrac{2^{5} \times 10^{-3}}{2^{3} \times 10^{-5}}$.

Correction. On traite séparément les deux bases : $\dfrac{2^{5}}{2^{3}} = 2^{2} = 4$ et $\dfrac{10^{-3}}{10^{-5}} = 10^{-3+5} = 10^{2} = 100$. Donc $C = 4 \times 100 = 400$.', NULL, 15),
    (v_chapitre_id, 'Activité d''intégration : la cour de l''école', 13, 'texte', '## La situation

Le directeur de l''école publique de Nkolbisson veut faire bétonner une cour carrée dont l''aire est de 288 m².

Le maçon facture le béton 3 500 FCFA le mètre carré. Pour la bordure, il faut une cordelette qui fera tout le tour de la cour, vendue en rouleaux de 10 m.

1. Donne la longueur exacte du côté de la cour, sous la forme $a\sqrt{b}$ avec $b$ le plus petit possible.
2. Encadre cette longueur entre deux entiers consécutifs, puis donne une valeur approchée à 0,1 m près.
3. Combien de rouleaux de cordelette faut-il acheter ?
4. Quel est le coût du béton ?

## La solution

1. Le côté $c$ vérifie $c^{2} = 288$, donc $c = \sqrt{288}$. Or $288 = 144 \times 2$, donc $c = \sqrt{144} \times \sqrt{2} = 12\sqrt{2}$ m.

2. Comme $1{,}41 < \sqrt{2} < 1{,}42$, on multiplie par 12 : $16{,}92 < 12\sqrt{2} < 17{,}04$. Le côté est donc compris entre 16 et 17 m, et vaut environ 17,0 m à 0,1 m près.

3. Le périmètre vaut $4 \times 12\sqrt{2} = 48\sqrt{2}$, soit environ $48 \times 1{,}414 = 67{,}9$ m. Avec des rouleaux de 10 m, il faut 7 rouleaux, parce que 6 rouleaux ne donnent que 60 m, ce qui est insuffisant.

4. Le béton couvre 288 m² et coûte 3 500 FCFA le mètre carré, soit $288 \times 3\,500 = 1\,008\,000$ FCFA.

## Ce qu''il faut remarquer

À la question 3, il ne faut surtout pas arrondir vers le bas. Dès qu''il manque un seul mètre de cordelette, la bordure n''est pas finie. Dans une situation réelle, on arrondit toujours au rouleau supérieur.', NULL, 15);

  RAISE NOTICE 'Chapitre 2, Nombres réels : 13 lecons ajoutees.';
END $m3$;
