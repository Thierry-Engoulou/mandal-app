-- ============================================================================
-- MANDAL — Mathématiques 3ème : chapitre 4, Équations et inéquations du premier degré à une inconnue dans ℝ
-- 10 leçons.
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
  WHERE programme_id = v_programme_id AND ordre = 4;

  -- 4. sinon on le cree
  IF v_chapitre_id IS NULL THEN
    INSERT INTO public.chapitres (programme_id, titre, ordre, niveau)
    VALUES (v_programme_id, 'Équations et inéquations du premier degré à une inconnue dans ℝ', 4, 'Module 13 : Relations et opérations fondamentales dans l''ensemble des nombres réels')
    RETURNING id INTO v_chapitre_id;
    RAISE NOTICE 'Chapitre 4 cree.';
  END IF;

  -- 5. les lecons
  SELECT count(*) INTO v_deja FROM public.concepts WHERE chapitre_id = v_chapitre_id;
  IF v_deja > 0 THEN
    RAISE NOTICE 'Chapitre 4 : contient deja % lecon(s) — aucun ajout.', v_deja;
    RETURN;
  END IF;

  INSERT INTO public.concepts
    (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes) VALUES
    (v_chapitre_id, 'Résoudre une équation du premier degré', 1, 'texte', 'Une équation, c''est une égalité qui contient une inconnue. La résoudre, c''est trouver toutes les valeurs de l''inconnue qui rendent l''égalité vraie.

## Les deux règles

Tu peux ajouter ou retirer le même nombre aux deux membres, l''égalité reste vraie.

Tu peux multiplier ou diviser les deux membres par un même nombre non nul, l''égalité reste vraie.

Ces deux règles suffisent pour tout résoudre.

## La méthode

Regroupe les termes en $x$ d''un côté, les nombres de l''autre, réduis, puis divise.

Résolvons $5x - 3 = 2x + 9$.

1. On retire $2x$ des deux côtés : $3x - 3 = 9$.
2. On ajoute 3 des deux côtés : $3x = 12$.
3. On divise par 3 : $x = 4$.

Vérification : à gauche $5 \times 4 - 3 = 17$, à droite $2 \times 4 + 9 = 17$. L''égalité est vraie, la solution est bien 4.

On écrit $S = \{4\}$, où $S$ désigne l''ensemble des solutions.

## Les cas particuliers

Parfois tous les $x$ disparaissent. Si tu obtiens une égalité vraie comme $7 = 7$, tous les réels conviennent et $S = \mathbb{R}$. Si tu obtiens une égalité fausse comme $5 = 8$, aucune valeur ne convient et $S = \varnothing$, l''ensemble vide.

## Exercice d''application

Résous $4(x - 2) = 3x + 1$.

Correction. On développe : $4x - 8 = 3x + 1$. On retire $3x$ : $x - 8 = 1$. On ajoute 8 : $x = 9$. Donc $S = \{9\}$.', NULL, 15),
    (v_chapitre_id, 'Équations produit et équations quotient', 2, 'texte', 'Certaines équations contiennent des $x^{2}$. Elles se résolvent quand même en 3ème, à condition de savoir factoriser.

## L''équation produit

Un produit de facteurs est nul si et seulement si l''un au moins des facteurs est nul.

$$A \times B = 0 \iff A = 0 \text{ ou } B = 0$$

Résolvons $(2x - 6)(x + 5) = 0$. Il suffit que l''un des facteurs soit nul.

Soit $2x - 6 = 0$, donc $x = 3$. Soit $x + 5 = 0$, donc $x = -5$. Les solutions sont $S = \{-5\,;3\}$.

## Quand il faut d''abord factoriser

L''équation $x^{2} - 9 = 0$ ne ressemble pas à un produit, mais $x^{2} - 9 = (x-3)(x+3)$. Donc $S = \{-3\,;3\}$.

L''équation $4x^{2} - 12x = 0$ se factorise en $4x(x - 3) = 0$, donc $S = \{0\,;3\}$. Ne divise surtout pas par $x$, tu perdrais la solution 0.

## L''équation quotient

Un quotient est nul quand son numérateur est nul, à condition que le dénominateur ne le soit pas.

$$\dfrac{A}{B} = 0 \iff A = 0 \text{ et } B \neq 0$$

Résolvons $\dfrac{x - 4}{x + 2} = 0$. La valeur interdite est $-2$. Le numérateur s''annule pour $x = 4$, qui n''est pas interdit. Donc $S = \{4\}$.

## Exercice d''application

Résous $(3x + 1)(x - 7) = 0$ puis $x^{2} - 5x = 0$.

Correction. Pour la première, $3x + 1 = 0$ donne $x = -\dfrac{1}{3}$, et $x - 7 = 0$ donne $x = 7$. Donc $S = \left\{-\dfrac{1}{3}\,;7\right\}$. Pour la seconde, on factorise $x(x-5) = 0$, donc $S = \{0\,;5\}$.', NULL, 15),
    (v_chapitre_id, 'Mettre un problème en équation', 3, 'texte', 'C''est l''étape qui fait peur, et pourtant elle suit toujours le même plan en quatre temps.

## La méthode en quatre temps

D''abord tu choisis l''inconnue et tu dis clairement ce qu''elle représente, avec son unité. Ensuite tu traduis l''énoncé en une équation. Puis tu résous. Enfin tu reviens au problème pour répondre par une phrase, et tu vérifies que la réponse a du sens.

## Un exemple complet

Un commerçant de Bertoua achète des sacs de ciment. S''il en achète 12, il lui reste 3 000 FCFA. S''il en achète 15, il lui manque 9 000 FCFA. Quel est le prix d''un sac, et combien d''argent a-t-il ?

Appelons $p$ le prix d''un sac, en FCFA. La somme dont il dispose s''écrit de deux façons :
$$12p + 3\,000 \qquad \text{et} \qquad 15p - 9\,000$$

C''est le même argent, donc
$$12p + 3\,000 = 15p - 9\,000$$

On résout : $3\,000 + 9\,000 = 15p - 12p$, donc $12\,000 = 3p$, donc $p = 4\,000$.

Un sac coûte 4 000 FCFA. Le commerçant dispose de $12 \times 4\,000 + 3\,000 = 51\,000$ FCFA. Vérification avec l''autre expression : $15 \times 4\,000 - 9\,000 = 60\,000 - 9\,000 = 51\,000$. C''est cohérent.

## Un deuxième exemple

La somme de trois nombres entiers consécutifs vaut 342. Quels sont ces nombres ?

Appelons $n$ le plus petit. Les trois nombres sont $n$, $n+1$ et $n+2$. Leur somme vaut $3n + 3 = 342$, donc $3n = 339$ et $n = 113$. Les trois nombres sont 113, 114 et 115.

## Exercice d''application

Le périmètre d''un rectangle vaut 46 m. Sa longueur dépasse sa largeur de 7 m. Trouve ses dimensions.

Correction. Appelons $\ell$ la largeur en mètres. La longueur vaut $\ell + 7$. Le périmètre s''écrit $2(\ell + \ell + 7) = 46$, donc $2(2\ell + 7) = 46$, donc $4\ell + 14 = 46$, donc $4\ell = 32$ et $\ell = 8$. La largeur fait 8 m et la longueur 15 m. Vérification : $2 \times (8 + 15) = 46$.', NULL, 15),
    (v_chapitre_id, 'Quiz : équations', 4, 'quiz', '{
  "titre": "Vérifie que tu as compris",
  "questions": [
    {
      "question": "La solution de $3x + 7 = 1$ est :",
      "choix": [
        "$x = 2$",
        "$x = -2$",
        "$x = \\dfrac{8}{3}$"
      ],
      "bonne": 1,
      "explication": "On retire 7 : $3x = -6$, puis on divise par 3 : $x = -2$."
    },
    {
      "question": "L''équation $(x - 5)(2x + 8) = 0$ a pour solutions :",
      "choix": [
        "$5$ et $-4$",
        "$5$ et $4$",
        "$-5$ et $4$"
      ],
      "bonne": 0,
      "explication": "Soit $x - 5 = 0$ donc $x = 5$, soit $2x + 8 = 0$ donc $x = -4$."
    },
    {
      "question": "Pour résoudre $x^{2} = 7x$, la bonne démarche est :",
      "choix": [
        "diviser les deux membres par $x$",
        "factoriser en $x(x-7) = 0$",
        "prendre la racine carrée"
      ],
      "bonne": 1,
      "explication": "Diviser par $x$ ferait perdre la solution $x = 0$. En factorisant on trouve les deux solutions, 0 et 7."
    },
    {
      "question": "On obtient $0x = 5$ à la fin d''une résolution. Alors :",
      "choix": [
        "$x = 5$",
        "$x = 0$",
        "il n''y a aucune solution"
      ],
      "bonne": 2,
      "explication": "Aucun nombre multiplié par 0 ne donne 5. L''ensemble des solutions est vide."
    }
  ]
}', NULL, 5),
    (v_chapitre_id, 'Résoudre une inéquation du premier degré', 5, 'texte', 'Une inéquation ressemble à une équation, mais avec un signe d''inégalité. Les règles sont presque les mêmes, avec un piège unique mais redoutable.

## Les règles

Tu peux ajouter ou retirer le même nombre aux deux membres, le sens de l''inégalité ne change pas.

Tu peux multiplier ou diviser les deux membres par un nombre strictement positif, le sens ne change pas.

Mais si tu multiplies ou divises par un nombre strictement négatif, le sens de l''inégalité s''inverse. C''est la seule différence avec les équations, et c''est là que presque toutes les erreurs se produisent.

Vérifie-le avec des nombres : $2 < 5$ est vrai. En multipliant par $-1$, on obtient $-2$ et $-5$, et c''est bien $-2 > -5$.

## Un exemple sans piège

Résolvons $3x - 4 \leq 11$.

On ajoute 4 : $3x \leq 15$. On divise par 3, qui est positif : $x \leq 5$. L''ensemble des solutions est $S = \,]-\infty\,;5]$.

## Un exemple avec le piège

Résolvons $-2x + 1 > 7$.

On retire 1 : $-2x > 6$. On divise par $-2$, qui est négatif, donc on retourne le signe : $x < -3$. L''ensemble des solutions est $S = \,]-\infty\,;-3[$.

Si tu avais gardé le signe, tu aurais écrit $x > -3$, ce qui est faux. Teste avec $x = 0$ : $-2 \times 0 + 1 = 1$, et 1 n''est pas supérieur à 7. Donc 0 n''est pas solution, ce qui confirme $x < -3$.

## Exercice d''application

Résous $5 - 3x \geq 2x - 10$ et donne l''ensemble des solutions sous forme d''intervalle.

Correction. On regroupe : $5 + 10 \geq 2x + 3x$, donc $15 \geq 5x$, donc $3 \geq x$, c''est-à-dire $x \leq 3$. L''ensemble des solutions est $S = \,]-\infty\,;3]$.', NULL, 15),
    (v_chapitre_id, 'Simulation : lire un ensemble de solutions', 6, 'interactif', '{
  "widget": "intervalles",
  "consigne": "Tu viens de résoudre $3x - 4 \\leq 11$ et d''obtenir $x \\leq 5$. Place la borne $b$ sur 5, choisis le crochet fermé à droite, et pousse la borne $a$ tout à gauche : tu visualises $]-\\infty\\,;5]$. Teste ensuite $x = 5$, puis $x = 5{,}5$. Recommence avec une inégalité stricte en ouvrant le crochet : la borne 5 cesse d''appartenir à l''ensemble."
}', NULL, 10),
    (v_chapitre_id, 'Problèmes menant à une inéquation', 7, 'texte', 'Dès qu''un énoncé contient les mots au plus, au moins, ne pas dépasser ou à partir de, c''est une inéquation qui se cache derrière.

## Les mots qui traduisent

Au plus, ne pas dépasser, au maximum se traduisent par $\leq$. Au moins, au minimum, à partir de se traduisent par $\geq$. Strictement inférieur à, moins de se traduisent par $<$.

## Un exemple

Un taxi de Yaoundé demande 500 FCFA de prise en charge, puis 150 FCFA par kilomètre. Avec 3 500 FCFA en poche, quelle distance maximale peux-tu parcourir ?

Appelons $d$ la distance en kilomètres. Le prix de la course vaut $500 + 150d$, et il ne doit pas dépasser 3 500.

$$500 + 150d \leq 3\,500$$
$$150d \leq 3\,000$$
$$d \leq 20$$

Tu peux parcourir au plus 20 km.

## Un exemple avec une moyenne

Paul a obtenu 8 et 12 aux deux premiers devoirs de mathématiques. Quelle note doit-il avoir au troisième pour que sa moyenne atteigne au moins 11 ?

Appelons $n$ la troisième note. La moyenne vaut $\dfrac{8 + 12 + n}{3}$, et elle doit être au moins égale à 11.

$$\dfrac{20 + n}{3} \geq 11$$
$$20 + n \geq 33$$
$$n \geq 13$$

Il lui faut au moins 13 sur 20.

## Exercice d''application

Un vendeur de beignets gagne 25 FCFA par beignet vendu, mais paie 2 000 FCFA de place au marché chaque jour. Combien doit-il en vendre pour que sa journée soit bénéficiaire ?

Correction. Appelons $b$ le nombre de beignets. Le bénéfice vaut $25b - 2\,000$, et il doit être strictement positif. On résout $25b - 2\,000 > 0$, donc $25b > 2\,000$, donc $b > 80$. Il doit vendre au moins 81 beignets, car un nombre de beignets est entier.', NULL, 15),
    (v_chapitre_id, 'Quiz : inéquations', 8, 'quiz', '{
  "titre": "Vérifie que tu as compris",
  "questions": [
    {
      "question": "On divise les deux membres de $-3x < 12$ par $-3$. On obtient :",
      "choix": [
        "$x < -4$",
        "$x > -4$",
        "$x > 4$"
      ],
      "bonne": 1,
      "explication": "Diviser par un nombre négatif retourne le sens de l''inégalité : $x > -4$."
    },
    {
      "question": "L''ensemble des solutions de $x + 2 \\geq 6$ est :",
      "choix": [
        "$[4\\,;+\\infty[$",
        "$]-\\infty\\,;4]$",
        "$]4\\,;+\\infty[$"
      ],
      "bonne": 0,
      "explication": "On trouve $x \\geq 4$. La borne 4 est comprise, donc crochet fermé."
    },
    {
      "question": "« Le prix ne doit pas dépasser 5 000 FCFA » se traduit par :",
      "choix": [
        "$p < 5\\,000$",
        "$p \\leq 5\\,000$",
        "$p \\geq 5\\,000$"
      ],
      "bonne": 1,
      "explication": "Ne pas dépasser autorise la valeur 5 000 elle-même, d''où le symbole inférieur ou égal."
    },
    {
      "question": "Un élève écrit : de $-2x \\geq 10$ je tire $x \\geq -5$. Son erreur est :",
      "choix": [
        "il a mal divisé",
        "il a oublié de retourner l''inégalité",
        "il n''y a pas d''erreur"
      ],
      "bonne": 1,
      "explication": "En divisant par $-2$, le sens s''inverse. La bonne réponse est $x \\leq -5$."
    }
  ]
}', NULL, 5),
    (v_chapitre_id, 'Exercices d''entraînement corrigés', 9, 'texte', '## Exercice 1

Résous $7x - 5 = 3(x + 1)$.

Correction. On développe : $7x - 5 = 3x + 3$. On regroupe : $4x = 8$, donc $x = 2$ et $S = \{2\}$.

## Exercice 2

Résous $(x + 3)(4 - x) = 0$.

Correction. Soit $x + 3 = 0$ donc $x = -3$, soit $4 - x = 0$ donc $x = 4$. Donc $S = \{-3\,;4\}$.

## Exercice 3

Résous $9x^{2} - 16 = 0$.

Correction. On factorise : $(3x-4)(3x+4) = 0$. Donc $x = \dfrac{4}{3}$ ou $x = -\dfrac{4}{3}$, et $S = \left\{-\dfrac{4}{3}\,;\dfrac{4}{3}\right\}$.

## Exercice 4

Résous l''inéquation $4 - 5x > 2x + 18$ et donne la réponse sous forme d''intervalle.

Correction. On regroupe : $4 - 18 > 2x + 5x$, donc $-14 > 7x$, donc $-2 > x$, c''est-à-dire $x < -2$. Donc $S = \,]-\infty\,;-2[$.

## Exercice 5

Résous $\dfrac{2x - 6}{x + 1} = 0$.

Correction. La valeur interdite est $-1$. Le numérateur s''annule pour $x = 3$, qui est autorisé. Donc $S = \{3\}$.

## Exercice 6

Un père a 42 ans, son fils 12 ans. Dans combien d''années l''âge du père sera-t-il exactement le double de celui du fils ?

Correction. Appelons $n$ le nombre d''années. Dans $n$ ans, le père aura $42 + n$ et le fils $12 + n$. On résout $42 + n = 2(12 + n)$, soit $42 + n = 24 + 2n$, donc $n = 18$. Dans 18 ans le père aura 60 ans et le fils 30 ans.', NULL, 15),
    (v_chapitre_id, 'Activité d''intégration : le transport du maïs', 10, 'texte', '## La situation

Un commerçant de Ngaoundéré veut transporter son maïs vers Yaoundé. Deux transporteurs lui font une offre.

Le premier demande 80 000 FCFA au départ, plus 1 200 FCFA par sac.

Le second ne demande rien au départ, mais 2 000 FCFA par sac.

1. Exprime le prix payé à chaque transporteur en fonction du nombre $n$ de sacs.
2. Pour combien de sacs les deux offres coûtent-elles exactement pareil ?
3. À partir de combien de sacs le premier transporteur devient-il plus avantageux ?
4. Le commerçant a 150 sacs. Quel transporteur doit-il choisir, et combien économise-t-il ?

## La solution

1. Le premier coûte $P_{1}(n) = 80\,000 + 1\,200n$ francs. Le second coûte $P_{2}(n) = 2\,000n$ francs.

2. Les deux offres sont égales quand
$$80\,000 + 1\,200n = 2\,000n$$
$$80\,000 = 800n$$
$$n = 100$$
Pour 100 sacs, les deux transporteurs demandent la même somme, soit 200 000 FCFA.

3. Le premier est plus avantageux quand $P_{1}(n) < P_{2}(n)$, c''est-à-dire
$$80\,000 + 1\,200n < 2\,000n$$
$$80\,000 < 800n$$
$$n > 100$$
À partir de 101 sacs, le premier transporteur revient moins cher.

4. Avec 150 sacs, qui est bien supérieur à 100, il faut choisir le premier. Il paiera $80\,000 + 1\,200 \times 150 = 80\,000 + 180\,000 = 260\,000$ FCFA, contre $2\,000 \times 150 = 300\,000$ FCFA chez le second. Il économise 40 000 FCFA.

## Ce qu''il faut remarquer

Le forfait de départ du premier transporteur est un handicap pour les petites quantités, mais son prix au sac plus bas finit par l''emporter. C''est une situation très courante : abonnement contre paiement à l''unité, forfait téléphonique, location de matériel. L''inéquation te dit exactement où se trouve le point de bascule.', NULL, 15);

  RAISE NOTICE 'Chapitre 4, Équations et inéquations du premier degré à une inconnue dans ℝ : 10 lecons ajoutees.';
END $m3$;
