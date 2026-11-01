-- ============================================================================
-- MANDAL — Physique Terminale : chapitre 1, Rappels sur les incertitudes
-- Module 1 : Mesures et incertitudes
-- 6 leçons.
--
-- Ce fichier remplit LES DEUX CLASSES a la fois : Terminale C et Terminale D.
-- Autonome : il cree lui-meme la matiere, les classes, les programmes et le
-- chapitre s'ils n'existent pas encore. Lancez-le seul, dans n'importe quel
-- ordre.
-- Idempotent : si le chapitre contient deja des lecons, rien n'est ajoute.
-- ============================================================================
DO $ptc$
DECLARE
  v_noms text[] := ARRAY['Terminale C', 'Terminale D'];
  v_lettres text[] := ARRAY['C', 'D'];
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
  -- la matiere, une seule fois
  INSERT INTO public.matieres (nom) VALUES ('Physique') ON CONFLICT (nom) DO NOTHING;
  SELECT id INTO v_matiere_id FROM public.matieres WHERE nom = 'Physique';

  -- l'etablissement, deduit de la table des classes
  SELECT count(DISTINCT etablissement_id) INTO v_nb_etabs FROM public.classes;
  IF v_nb_etabs <> 1 THEN
    RAISE EXCEPTION 'Impossible de deduire l''etablissement : % etablissement(s) distinct(s) dans public.classes.', v_nb_etabs;
  END IF;
  SELECT etablissement_id INTO v_etab_id FROM public.classes LIMIT 1;

  -- on refait le meme travail pour la Terminale C puis pour la Terminale D
  FOR v_i IN 1..2 LOOP
    v_nom := v_noms[v_i];
    v_lettre := v_lettres[v_i];

    -- 1. le programme existe-t-il deja ?
    SELECT p.id INTO v_programme_id FROM public.programmes p
    WHERE p.titre = 'Physique — ' || v_nom;

    -- 2. sinon on le cree
    IF v_programme_id IS NULL THEN
      -- la classe, quelle que soit la facon dont elle a ete ecrite
      SELECT id INTO v_classe_id FROM public.classes
      WHERE etablissement_id = v_etab_id
        AND (nom = v_nom OR nom ILIKE 'T%le ' || v_lettre)
      ORDER BY (nom = v_nom) DESC
      LIMIT 1;

      -- si elle n'existe pas, on la cree
      IF v_classe_id IS NULL THEN
        INSERT INTO public.classes (etablissement_id, nom, niveau, filiere)
        VALUES (v_etab_id, v_nom, 'Terminale', v_lettre)
        RETURNING id INTO v_classe_id;
        RAISE NOTICE 'Classe "%" creee.', v_nom;
      END IF;

      INSERT INTO public.programmes (matiere_id, classe_id, etablissement_id, titre, description)
      VALUES (v_matiere_id, v_classe_id, v_etab_id, 'Physique — ' || v_nom,
              'Programme officiel de Physique, classe de Terminale ' || v_lettre ||
              ' (Cameroun) — 4 modules, 22 chapitres.')
      RETURNING id INTO v_programme_id;
      RAISE NOTICE 'Programme "Physique — %" cree.', v_nom;
    END IF;

    -- 3. le chapitre existe-t-il deja ?
    SELECT id INTO v_chapitre_id FROM public.chapitres
    WHERE programme_id = v_programme_id AND ordre = 1;

    -- 4. sinon on le cree
    IF v_chapitre_id IS NULL THEN
      INSERT INTO public.chapitres (programme_id, titre, ordre, niveau)
      VALUES (v_programme_id, 'Rappels sur les incertitudes', 1, 'Module 1 : Mesures et incertitudes')
      RETURNING id INTO v_chapitre_id;
      RAISE NOTICE '% : chapitre 1 cree.', v_nom;
    END IF;

    -- 5. les lecons
    SELECT count(*) INTO v_deja FROM public.concepts WHERE chapitre_id = v_chapitre_id;
    IF v_deja > 0 THEN
      RAISE NOTICE '% : chapitre 1 contient deja % lecon(s) — aucun ajout.', v_nom, v_deja;
      CONTINUE;
    END IF;

    INSERT INTO public.concepts
      (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes) VALUES
      (v_chapitre_id, 'Mesurer, c''est toujours approcher', 1, 'texte', 'Quand tu mesures la longueur d''une table avec un mètre ruban, tu ne trouves jamais la vraie longueur. Tu trouves une valeur proche. C''est vrai pour toutes les mesures, même celles faites avec les meilleurs appareils du monde.

La **métrologie** est la science de la mesure. Elle ne s''intéresse pas seulement au résultat, mais aussi à la confiance qu''on peut lui accorder.

## Le vocabulaire à connaître

Le **mesurage** est l''ensemble des opérations qui te permettent de trouver la valeur d''une grandeur. En Terminale on dit mesurage plutôt que mesure, parce que le mot mesure désigne plutôt le résultat.

Le **mesurande** est la grandeur que tu cherches à mesurer. Si tu pèses un sac de riz, le mesurande est la masse du sac.

La **valeur mesurée** est ce que l''appareil t''affiche.

La **valeur vraie** est ce que tu trouverais si le mesurage était parfait. Personne ne la connaît jamais exactement.

L''**erreur de mesure** est l''écart entre la valeur mesurée et la valeur vraie.
$$e = x_{\text{mesurée}} - x_{\text{vraie}}$$

## Pourquoi la valeur vraie reste inaccessible

Prends une balance au marché de Mokolo. Le vendeur pose ton poisson, la balance affiche $1{,}2$ kg. Est-ce exactement $1{,}2$ kg ? Non. La balance a une graduation tous les $20$ g, donc elle ne peut pas distinguer $1{,}19$ kg de $1{,}21$ kg. En plus, le plateau n''est peut-être pas parfaitement réglé à zéro.

Tu ne connaîtras donc jamais l''erreur $e$, puisque tu ne connais pas la valeur vraie. Ce que tu peux faire, c''est estimer un intervalle dans lequel la valeur vraie se trouve très probablement. Cet intervalle, c''est l''**incertitude**.

## Exercice d''application

Un élève mesure l''épaisseur d''une feuille de papier. Il empile $500$ feuilles identiques, mesure la pile avec une règle graduée au millimètre et trouve $48$ mm. Quelle épaisseur annonce-t-il pour une feuille ? Pourquoi a-t-il empilé les feuilles au lieu d''en mesurer une seule ?

Correction. L''épaisseur d''une feuille vaut $\dfrac{48}{500} = 0{,}096$ mm.

Il a empilé les feuilles parce qu''une seule feuille mesure moins d''un dixième de millimètre. La règle, graduée au millimètre, est incapable de voir une telle épaisseur. En empilant, il rend la grandeur mesurable, et il divise aussi l''incertitude par $500$. C''est une méthode qu''on retrouve partout en physique.', NULL, 15),
      (v_chapitre_id, 'Les qualités d''un appareil de mesure', 2, 'texte', 'Deux appareils qui mesurent la même chose ne se valent pas forcément. Pour les comparer, on regarde cinq ou six qualités. Tu dois savoir les nommer et les distinguer, c''est un classique de l''examen.

## L''étendue de mesurage

C''est le domaine dans lequel l''appareil sait travailler. Il est défini par une valeur minimale et une valeur maximale, qu''on appelle les **portées**.

Une balance de cuisine a une étendue de $0$ à $5$ kg. Si tu poses un sac de ciment de $50$ kg dessus, tu ne mesures rien, tu casses la balance.

## La justesse

Un appareil est **juste** quand il ne se trompe pas toujours dans le même sens. Autrement dit, il est libre d''erreurs systématiques.

Une balance qui affiche $100$ g alors que le plateau est vide n''est pas juste. Toutes ses mesures seront trop grandes de $100$ g.

## La fidélité

Un appareil est **fidèle** quand il redonne la même valeur si tu refais la même mesure. Ses erreurs aléatoires sont faibles.

Attention, un appareil peut être fidèle et faux en même temps. La balance déréglée de tout à l''heure affiche toujours $100$ g de trop. Elle est donc très fidèle, et pourtant elle ment.

## L''exactitude

Un appareil est **exact**, ou précis, quand il est à la fois juste et fidèle. C''est ce qu''on recherche.

## La sensibilité

C''est la plus petite variation que l''appareil arrive à détecter. On la définit comme le rapport entre la variation de la réponse et la variation du signal d''entrée.
$$s = \dfrac{\Delta r}{\Delta x}$$

Un ampèremètre dont l''aiguille se déplace de $3$ divisions quand le courant augmente de $1$ mA a une sensibilité de $3$ divisions par milliampère.

## La résolution

C''est la plus petite variation de la grandeur mesurée qui change l''affichage. Sur un multimètre numérique qui affiche $12{,}34$ V, la résolution vaut $0{,}01$ V.

## Exercice d''application

Trois élèves pèsent la même masse marquée de $200{,}0$ g, chacun cinq fois, avec une balance différente.

La balance A donne $198{,}1$ puis $202{,}4$ puis $199{,}0$ puis $201{,}5$ puis $200{,}2$ g.

La balance B donne $205{,}1$ puis $205{,}0$ puis $205{,}2$ puis $205{,}1$ puis $205{,}0$ g.

La balance C donne $200{,}1$ puis $199{,}9$ puis $200{,}0$ puis $200{,}1$ puis $199{,}9$ g.

Pour chaque balance, dis si elle est juste, fidèle, les deux, ou aucune des deux.

Correction. La balance A tourne bien autour de $200$ g, donc elle est juste, mais ses valeurs sont très dispersées, donc elle n''est pas fidèle.

La balance B donne toujours à peu près la même chose, donc elle est fidèle, mais elle affiche $5$ g de trop à chaque fois, donc elle n''est pas juste. Elle a une erreur systématique.

La balance C est groupée autour de la bonne valeur. Elle est juste et fidèle, donc exacte. C''est la meilleure des trois.', NULL, 15),
      (v_chapitre_id, 'Vise la cible : juste ou fidèle ?', 3, 'interactif', '{
  "widget": "justesse-fidelite",
  "consigne": "Chaque point est une mesure, et le centre de la cible est la valeur vraie. Change la justesse et la fidélité, et regarde comment le nuage de points se déplace. Trouve le réglage qui donne un appareil fidèle mais pas juste, puis celui qui donne un appareil exact."
}', NULL, 10),
      (v_chapitre_id, 'Erreurs systématiques et erreurs aléatoires', 4, 'texte', 'Toutes les erreurs ne se ressemblent pas. On les range en deux familles, et on ne les combat pas de la même façon.

## L''erreur systématique

Elle se répète à l''identique à chaque mesure. Elle pousse toujours le résultat du même côté, soit trop haut, soit trop bas.

Elle vient en général d''un appareil mal réglé, d''un zéro décalé, d''un étalonnage périmé, ou d''une méthode mal choisie. Un chronomètre qui démarre un dixième de seconde trop tard ajoute toujours le même retard.

La bonne nouvelle, c''est qu''on peut la corriger. Tu règles le zéro, tu étalonnes l''appareil avec une référence connue, ou tu retranches le décalage du résultat.

La mauvaise nouvelle, c''est que refaire la mesure cent fois ne sert à rien. Tu obtiendras cent fois la même erreur.

## L''erreur aléatoire

Elle change de valeur et de signe à chaque mesure, sans qu''on puisse la prévoir.

Elle vient des petites fluctuations de l''expérimentateur et du milieu. Ta main qui tremble sur le chronomètre, la température qui bouge, le courant d''air sur la balance, ta façon de lire une aiguille sous un angle légèrement différent.

Cette erreur-là, tu ne peux pas la supprimer. Mais tu peux la réduire, et c''est tout l''intérêt de refaire la mesure plusieurs fois. En prenant la moyenne de $n$ mesures, l''erreur aléatoire est divisée par $\sqrt{n}$.

## L''erreur de parallaxe, le piège classique

Quand tu lis une aiguille sur un cadran, place ton œil juste en face. Si tu regardes de biais, tu lis une valeur décalée. C''est l''erreur de parallaxe.

C''est une erreur systématique si tu te places toujours du même côté, et aléatoire si ta position change à chaque lecture. Les bons appareils ont un miroir derrière l''aiguille : tu es bien placé quand l''aiguille cache son reflet.

## Exercice d''application

Un élève mesure la période d''un pendule au chronomètre. Il trouve $1{,}42$ puis $1{,}38$ puis $1{,}45$ puis $1{,}40$ puis $1{,}41$ s. Un capteur électronique donne $1{,}27$ s.

Quelle est la moyenne des mesures de l''élève ? Quel type d''erreur explique la dispersion de ses cinq valeurs ? Quel type d''erreur explique l''écart avec le capteur ? Que lui conseilles-tu ?

Correction. La moyenne vaut $\dfrac{1{,}42 + 1{,}38 + 1{,}45 + 1{,}40 + 1{,}41}{5} = \dfrac{7{,}06}{5} = 1{,}412$ s.

La dispersion des cinq valeurs vient des erreurs aléatoires, c''est-à-dire du temps de réaction de l''élève qui varie d''un essai à l''autre.

L''écart de $0{,}14$ s avec le capteur est trop grand et toujours dans le même sens. C''est une erreur systématique : l''élève déclenche en retard au départ et à l''arrivée, ou bien il compte une oscillation de travers.

Conseil : mesurer la durée de dix oscillations puis diviser par dix. Le temps de réaction est alors divisé par dix lui aussi.', NULL, 15),
      (v_chapitre_id, 'Calculer une incertitude et écrire le résultat', 5, 'texte', 'Un résultat de mesure sans incertitude ne vaut rien. En Terminale, tu dois toujours écrire ton résultat sous la forme
$$x = (x_{\text{moy}} \pm \Delta x) \ \text{unité}$$

Cela veut dire que la valeur vraie se trouve très probablement entre $x_{\text{moy}} - \Delta x$ et $x_{\text{moy}} + \Delta x$.

## Incertitude absolue et incertitude relative

L''**incertitude absolue** $\Delta x$ a la même unité que la grandeur. L''**incertitude relative** est le rapport
$$\dfrac{\Delta x}{x_{\text{moy}}}$$
et on l''exprime souvent en pourcentage. C''est elle qui dit si la mesure est bonne ou non.

Une erreur de $1$ cm sur la longueur d''un stylo est catastrophique. La même erreur de $1$ cm sur la distance Yaoundé-Douala est ridicule. L''incertitude absolue est la même, l''incertitude relative est très différente.

## L''incertitude de type A, quand on répète la mesure

Tu fais $n$ mesures. Tu calcules d''abord la moyenne
$$x_{\text{moy}} = \dfrac{1}{n}\sum_{i=1}^{n} x_{i}$$
puis l''écart-type expérimental
$$\sigma = \sqrt{\dfrac{1}{n-1}\sum_{i=1}^{n}(x_{i} - x_{\text{moy}})^{2}}$$

L''incertitude-type sur la moyenne vaut alors
$$u(x) = \dfrac{\sigma}{\sqrt{n}}$$

Regarde bien le $\sqrt{n}$ au dénominateur. Pour diviser ton incertitude par deux, il faut quatre fois plus de mesures.

## L''incertitude de type B, quand on ne mesure qu''une fois

Là, tu te fies à l''appareil. Si le constructeur annonce une tolérance $a$, ou si la graduation vaut $a$, on prend
$$u(x) = \dfrac{a}{\sqrt{3}}$$

Pour une règle graduée au millimètre, $a = 1$ mm et $u = \dfrac{1}{\sqrt{3}} \approx 0{,}58$ mm.

## Composer les incertitudes

Si tu calcules une grandeur à partir de plusieurs mesures, les incertitudes se combinent.

Pour une somme ou une différence, $z = x + y$ ou $z = x - y$, ce sont les incertitudes **absolues** qui s''ajoutent :
$$u(z) = \sqrt{u(x)^{2} + u(y)^{2}}$$

Pour un produit ou un quotient, $z = xy$ ou $z = \dfrac{x}{y}$, ce sont les incertitudes **relatives** qui s''ajoutent :
$$\dfrac{u(z)}{z} = \sqrt{\left(\dfrac{u(x)}{x}\right)^{2} + \left(\dfrac{u(y)}{y}\right)^{2}}$$

Et si une grandeur est élevée à la puissance $n$, son incertitude relative est multipliée par $n$.

## Comment écrire le résultat

L''incertitude s''écrit avec un seul chiffre significatif, deux au maximum. Et la valeur s''arrête au même rang que l''incertitude.

Si tu trouves $x_{\text{moy}} = 12{,}3847$ m et $\Delta x = 0{,}0231$ m, tu écris $x = (12{,}38 \pm 0{,}02)$ m. Écrire $12{,}3847$ avec une incertitude de $0{,}02$ n''a aucun sens, les derniers chiffres ne veulent rien dire.

## Exercice d''application

Pour trouver l''aire d''une plaque rectangulaire, un élève mesure $L = 25{,}0$ cm avec $u(L) = 0{,}1$ cm et $\ell = 12{,}0$ cm avec $u(\ell) = 0{,}1$ cm. Calcule l''aire et son incertitude, puis écris le résultat correctement.

Correction. L''aire vaut $S = L \times \ell = 25{,}0 \times 12{,}0 = 300$ cm².

C''est un produit, donc on ajoute les incertitudes relatives. On a $\dfrac{u(L)}{L} = \dfrac{0{,}1}{25{,}0} = 0{,}0040$ et $\dfrac{u(\ell)}{\ell} = \dfrac{0{,}1}{12{,}0} = 0{,}0083$.

Donc $\dfrac{u(S)}{S} = \sqrt{0{,}0040^{2} + 0{,}0083^{2}} = \sqrt{0{,}000016 + 0{,}0000689} = \sqrt{0{,}0000849} \approx 0{,}0092$.

D''où $u(S) = 0{,}0092 \times 300 \approx 2{,}8$ cm², qu''on arrondit à $3$ cm².

Le résultat s''écrit $S = (300 \pm 3)$ cm², soit une incertitude relative d''environ $1\%$.

Remarque au passage : c''est la petite longueur $\ell$ qui pèse le plus, parce que son incertitude relative est la plus grande. Si tu veux améliorer la mesure, c''est elle qu''il faut soigner.', NULL, 15),
      (v_chapitre_id, 'Quiz du chapitre 1', 6, 'quiz', '{
  "titre": "Vérifie que tu as compris",
  "questions": [
    {
      "question": "Une balance affiche 50 g alors que son plateau est vide. Toutes les pesées seront faussées de la même façon. De quel type d''erreur s''agit-il ?",
      "choix": [
        "Une erreur aléatoire",
        "Une erreur systématique",
        "Une erreur de parallaxe",
        "Une erreur de résolution"
      ],
      "bonne": 1,
      "explication": "L''erreur se répète à l''identique et pousse toujours dans le même sens. C''est la définition de l''erreur systématique. Refaire la pesée cent fois n''y changerait rien, il faut régler le zéro."
    },
    {
      "question": "Un appareil donne cinq fois de suite 205,1 g pour une masse vraie de 200,0 g. Que peut-on dire de lui ?",
      "choix": [
        "Il est juste mais pas fidèle",
        "Il est fidèle mais pas juste",
        "Il est exact",
        "Il n''est ni juste ni fidèle"
      ],
      "bonne": 1,
      "explication": "Il redonne toujours la même valeur, donc il est fidèle. Mais cette valeur est décalée de 5 g par rapport à la valeur vraie, donc il n''est pas juste. Fidélité et justesse sont deux qualités indépendantes."
    },
    {
      "question": "On passe de 4 à 16 mesures répétées. Par combien l''incertitude de type A est-elle divisée ?",
      "choix": [
        "Par 2",
        "Par 4",
        "Par 12",
        "Par 16"
      ],
      "bonne": 0,
      "explication": "L''incertitude vaut $u = \\sigma/\\sqrt{n}$. En passant de $n = 4$ à $n = 16$, le dénominateur passe de 2 à 4, donc l''incertitude est divisée par 2 seulement. Il faut quadrupler le nombre de mesures pour gagner un facteur 2."
    },
    {
      "question": "On calcule une vitesse $v = d/t$. Comment se combinent les incertitudes ?",
      "choix": [
        "On additionne les incertitudes absolues",
        "On additionne les incertitudes relatives au carré, puis on prend la racine",
        "On prend la plus grande des deux",
        "On multiplie les incertitudes absolues"
      ],
      "bonne": 1,
      "explication": "Pour un quotient, ce sont les incertitudes relatives qui se composent : $u(v)/v = \\sqrt{(u(d)/d)^2 + (u(t)/t)^2}$. Les incertitudes absolues ne s''ajoutent que pour une somme ou une différence."
    },
    {
      "question": "Un élève trouve $L = 8{,}4371$ m avec une incertitude de $0{,}05$ m. Comment doit-il écrire son résultat ?",
      "choix": [
        "$L = (8{,}4371 \\pm 0{,}05)$ m",
        "$L = (8{,}44 \\pm 0{,}05)$ m",
        "$L = (8{,}4 \\pm 0{,}05)$ m",
        "$L = (8 \\pm 0{,}05)$ m"
      ],
      "bonne": 1,
      "explication": "La valeur doit s''arrêter au même rang que l''incertitude, ici le centième. Donc $8{,}4371$ devient $8{,}44$. Garder quatre décimales avec une incertitude de 5 centimètres n''aurait aucun sens."
    },
    {
      "question": "Pourquoi mesure-t-on la durée de 10 oscillations d''un pendule plutôt qu''une seule ?",
      "choix": [
        "Parce que le pendule est plus régulier au bout de 10 oscillations",
        "Pour diviser par 10 l''erreur due au temps de réaction",
        "Parce que la période change avec le temps",
        "Pour augmenter la sensibilité du chronomètre"
      ],
      "bonne": 1,
      "explication": "Le temps de réaction au déclenchement est le même qu''on mesure une ou dix oscillations. En divisant la durée totale par 10, on divise aussi cette erreur par 10. L''astuce ne change rien au pendule, elle améliore la mesure."
    }
  ]
}', NULL, 5);

    RAISE NOTICE '% : chapitre 1, Rappels sur les incertitudes — 6 lecons ajoutees.', v_nom;
  END LOOP;
END $ptc$;
