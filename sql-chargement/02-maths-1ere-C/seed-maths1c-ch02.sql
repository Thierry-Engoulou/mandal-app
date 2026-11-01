-- ============================================================================
-- MANDAL — Mathématiques 1ère C : chapitre 2, Systèmes d''équations à deux ou trois inconnues
-- Module 21 : Relations et opérations fondamentales dans l'ensemble des nombres réels
-- 5 leçons.
--
-- Autonome : ce fichier cree lui-meme la matiere, la classe, le programme et
-- le chapitre s'ils n'existent pas encore. Lancez-le seul, dans n'importe
-- quel ordre.
-- Idempotent : si le chapitre contient deja des lecons, rien n'est ajoute.
-- ============================================================================
DO $p1c$
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
  WHERE p.titre = 'Mathématiques — 1ère C';

  -- 2. sinon on le cree
  IF v_programme_id IS NULL THEN
    INSERT INTO public.matieres (nom) VALUES ('Mathématiques') ON CONFLICT (nom) DO NOTHING;
    SELECT id INTO v_matiere_id FROM public.matieres WHERE nom = 'Mathématiques';

    SELECT count(DISTINCT etablissement_id) INTO v_nb_etabs FROM public.classes;
    IF v_nb_etabs <> 1 THEN
      RAISE EXCEPTION 'Impossible de deduire l''etablissement : % etablissement(s) distinct(s) dans public.classes.', v_nb_etabs;
    END IF;
    SELECT etablissement_id INTO v_etab_id FROM public.classes LIMIT 1;

    -- la classe, quelle que soit la facon dont elle a ete ecrite
    SELECT id INTO v_classe_id FROM public.classes
    WHERE etablissement_id = v_etab_id
      AND (nom = '1ère C' OR nom ILIKE '1%re C' OR nom ILIKE 'Premi%re C')
    ORDER BY (nom = '1ère C') DESC
    LIMIT 1;

    -- si elle n'existe pas, on la cree
    IF v_classe_id IS NULL THEN
      INSERT INTO public.classes (etablissement_id, nom, niveau, filiere)
      VALUES (v_etab_id, '1ère C', 'Première', 'C')
      RETURNING id INTO v_classe_id;
      RAISE NOTICE 'Classe "1ère C" creee.';
    END IF;

    INSERT INTO public.programmes (matiere_id, classe_id, etablissement_id, titre, description)
    VALUES (v_matiere_id, v_classe_id, v_etab_id, 'Mathématiques — 1ère C',
            'Programme officiel de Mathématiques, classe de Première C (Cameroun) — 4 modules, 21 chapitres.')
    RETURNING id INTO v_programme_id;
    RAISE NOTICE 'Programme "Mathématiques — 1ère C" cree.';
  END IF;

  -- 3. le chapitre existe-t-il deja ?
  SELECT id INTO v_chapitre_id FROM public.chapitres
  WHERE programme_id = v_programme_id AND ordre = 2;

  -- 4. sinon on le cree
  IF v_chapitre_id IS NULL THEN
    INSERT INTO public.chapitres (programme_id, titre, ordre, niveau)
    VALUES (v_programme_id, 'Systèmes d''équations à deux ou trois inconnues', 2, 'Module 21 : Relations et opérations fondamentales dans l''ensemble des nombres réels')
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
    (v_chapitre_id, 'Systèmes linéaires à deux inconnues', 1, 'texte', 'Un système linéaire à deux inconnues, c''est deux équations du premier degré qu''il faut satisfaire en même temps.

$$\begin{cases} ax + by = c \\ a''x + b''y = c'' \end{cases}$$

Tu connais déjà la substitution et la combinaison depuis la 3ème. En Première on ajoute un outil qui va droit au but : le déterminant.

## Le déterminant du système

On pose
$$\det = ab'' - a''b$$

Si $\det \neq 0$, le système a exactement une solution. Les deux droites se coupent en un point.

Si $\det = 0$, soit le système n''a aucune solution, soit il en a une infinité. Les deux droites sont alors parallèles, distinctes ou confondues.

## Les formules de Cramer

Quand $\det \neq 0$,
$$x = \dfrac{cb'' - c''b}{ab'' - a''b} \qquad y = \dfrac{ac'' - a''c}{ab'' - a''b}$$

Résolvons
$$\begin{cases} 3x + 2y = 16 \\ 5x - 4y = 1 \end{cases}$$

Le déterminant vaut $3 \times (-4) - 5 \times 2 = -12 - 10 = -22$. Il n''est pas nul, il y a une solution unique.

$$x = \dfrac{16 \times (-4) - 1 \times 2}{-22} = \dfrac{-66}{-22} = 3$$
$$y = \dfrac{3 \times 1 - 5 \times 16}{-22} = \dfrac{-77}{-22} = 3{,}5$$

Vérifie dans la première équation : $3 \times 3 + 2 \times 3{,}5 = 9 + 7 = 16$. C''est juste.

## Quand le déterminant est nul

Prenons
$$\begin{cases} 2x - 3y = 5 \\ 4x - 6y = 10 \end{cases}$$

Le déterminant vaut $2 \times (-6) - 4 \times (-3) = -12 + 12 = 0$. La deuxième équation est exactement le double de la première, elles disent la même chose. Il y a une infinité de solutions, tous les couples de la droite $2x - 3y = 5$.

Si la deuxième équation avait été $4x - 6y = 7$, elle aurait contredit la première et il n''y aurait eu aucune solution.

## Exercice d''application

Résous
$$\begin{cases} x + 4y = 22 \\ 3x - 2y = 10 \end{cases}$$

Correction. Le déterminant vaut $1 \times (-2) - 3 \times 4 = -14$. Puis $x = \dfrac{22 \times (-2) - 10 \times 4}{-14} = \dfrac{-84}{-14} = 6$ et $y = \dfrac{1 \times 10 - 3 \times 22}{-14} = \dfrac{-56}{-14} = 4$. Donc $S = \{(6\,;4)\}$.', NULL, 15),
    (v_chapitre_id, 'Deux droites, un point d''intersection', 2, 'interactif', '{
  "widget": "systeme-equations",
  "consigne": "Règle les deux équations. Trouve une situation où les droites sont parallèles : que se passe-t-il pour le nombre de solutions ? Et quand elles sont confondues ?"
}', NULL, 10),
    (v_chapitre_id, 'Systèmes à trois inconnues et pivot de Gauss', 3, 'texte', 'Avec trois inconnues, la méthode qui marche à tous les coups s''appelle le pivot de Gauss. L''idée est simple : faire disparaître les inconnues une par une, jusqu''à obtenir un système en escalier.

## La méthode

Tu gardes la première équation. Tu l''utilises pour éliminer $x$ dans les deux autres. Puis tu gardes la deuxième équation obtenue et tu l''utilises pour éliminer $y$ dans la dernière. Il ne reste alors qu''une équation à une inconnue.

## Un exemple complet

$$\begin{cases} x + y + z = 6 \\ 2x - y + 3z = 9 \\ x + 2y - z = 2 \end{cases}$$

Première étape, on élimine $x$ dans les lignes 2 et 3.

$L_{2} - 2L_{1}$ donne $2x - y + 3z - 2x - 2y - 2z = 9 - 12$, c''est-à-dire
$$-3y + z = -3$$

$L_{3} - L_{1}$ donne $x + 2y - z - x - y - z = 2 - 6$, c''est-à-dire
$$y - 2z = -4$$

Deuxième étape, on élimine $y$. De la dernière ligne, $y = 2z - 4$. On reporte dans l''autre :
$$-3(2z - 4) + z = -3$$
$$-6z + 12 + z = -3$$
$$-5z = -15 \quad \text{donc} \quad z = 3$$

Troisième étape, on remonte. Avec $z = 3$, on trouve $y = 2 \times 3 - 4 = 2$, puis $x = 6 - 2 - 3 = 1$.

## La vérification, toujours

Remplace dans les trois équations de départ.

Ligne 1 : $1 + 2 + 3 = 6$. Ligne 2 : $2 - 2 + 9 = 9$. Ligne 3 : $1 + 4 - 3 = 2$.

Les trois sont satisfaites, donc $S = \{(1\,;2\,;3)\}$.

Ne saute jamais cette étape. Une erreur de signe dans le pivot est très facile à faire, et la vérification la repère en dix secondes.

## Les deux autres cas

Si à la fin tu obtiens quelque chose comme $0 = 5$, le système n''a aucune solution. Les équations se contredisent.

Si tu obtiens $0 = 0$, c''est qu''une équation était inutile. Le système a une infinité de solutions, et tu les exprimes en fonction d''une inconnue laissée libre.

## Exercice d''application

Résous
$$\begin{cases} x + y + z = 12 \\ x - y + 2z = 9 \\ 2x + y - z = 5 \end{cases}$$

Correction. $L_{2} - L_{1}$ donne $-2y + z = -3$. $L_{3} - 2L_{1}$ donne $-y - 3z = -19$.

De la première, $z = 2y - 3$. En reportant dans la seconde, $-y - 3(2y - 3) = -19$, soit $-7y + 9 = -19$, donc $y = 4$.

Alors $z = 5$ et $x = 12 - 4 - 5 = 3$.

Vérification : $3 + 4 + 5 = 12$, puis $3 - 4 + 10 = 9$, puis $6 + 4 - 5 = 5$. Donc $S = \{(3\,;4\,;5)\}$.', NULL, 15),
    (v_chapitre_id, 'TP : résoudre des problèmes concrets', 4, 'texte', 'Les systèmes servent dès qu''un problème comporte plusieurs quantités inconnues liées entre elles.

## Au marché de Mokolo

Une femme achète 3 régimes de bananes et 2 sacs de manioc pour 11 500 FCFA. Sa voisine achète 5 régimes et 4 sacs pour 20 500 FCFA. Quel est le prix d''un régime et celui d''un sac ?

Soit $b$ le prix d''un régime et $m$ le prix d''un sac, en FCFA.

$$\begin{cases} 3b + 2m = 11\,500 \\ 5b + 4m = 20\,500 \end{cases}$$

Le déterminant vaut $3 \times 4 - 5 \times 2 = 2$.

$$b = \dfrac{11\,500 \times 4 - 20\,500 \times 2}{2} = \dfrac{46\,000 - 41\,000}{2} = 2\,500$$
$$m = \dfrac{3 \times 20\,500 - 5 \times 11\,500}{2} = \dfrac{61\,500 - 57\,500}{2} = 2\,000$$

Un régime coûte 2 500 FCFA et un sac 2 000 FCFA. Vérification : $3 \times 2\,500 + 2 \times 2\,000 = 11\,500$. C''est bon.

## Trois types de billets

Un transporteur de Yaoundé a vendu 100 billets pour 265 000 FCFA. Les billets coûtent 2 000, 3 000 ou 5 000 FCFA. Il a vendu deux fois plus de billets à 3 000 qu''à 5 000. Combien de billets de chaque sorte ?

Soient $x$, $y$ et $z$ les nombres de billets à 2 000, 3 000 et 5 000 FCFA.

$$\begin{cases} x + y + z = 100 \\ 2\,000x + 3\,000y + 5\,000z = 265\,000 \\ y = 2z \end{cases}$$

La troisième équation permet de tout exprimer avec $z$. On remplace $y$ par $2z$ :

$$x + 3z = 100 \qquad \text{et} \qquad 2x + 6z + 5z = 265$$

en divisant la deuxième par 1 000. Donc $2x + 11z = 265$.

De la première, $x = 100 - 3z$. En reportant, $200 - 6z + 11z = 265$, donc $5z = 65$ et $z = 13$.

Alors $y = 26$ et $x = 100 - 39 = 61$.

Vérification : $61 + 26 + 13 = 100$, et $61 \times 2 + 26 \times 3 + 13 \times 5 = 122 + 78 + 65 = 265$ milliers de FCFA. Tout concorde.

## Un mélange

Un commerçant veut préparer 50 kilos d''un mélange de riz à 900 FCFA le kilo, à partir d''un riz à 700 FCFA et d''un riz à 1 200 FCFA. Combien de kilos de chaque ?

Soient $p$ et $q$ les masses des deux riz.

$$\begin{cases} p + q = 50 \\ 700p + 1\,200q = 900 \times 50 = 45\,000 \end{cases}$$

De la première, $p = 50 - q$. En reportant, $35\,000 - 700q + 1\,200q = 45\,000$, donc $500q = 10\,000$ et $q = 20$.

Il faut 30 kilos de riz à 700 FCFA et 20 kilos de riz à 1 200 FCFA.

## La bonne habitude

Dans chaque problème, nomme les inconnues avec leur unité, écris une équation par information de l''énoncé, résous, puis reviens au texte pour vérifier que les nombres trouvés sont possibles. Un nombre de billets doit être un entier positif.', NULL, 15),
    (v_chapitre_id, 'Quiz du chapitre 2', 5, 'quiz', '{
  "titre": "Vérifie que tu as compris",
  "questions": [
    {
      "question": "Le système 2x + 3y = 7 et 4x + 6y = 14 a :",
      "choix": [
        "une infinité de solutions",
        "une solution unique",
        "aucune solution",
        "exactement deux solutions"
      ],
      "bonne": 0,
      "explication": "Le déterminant vaut 2×6 − 4×3 = 0, et la deuxième équation est le double de la première. Les deux droites sont confondues."
    },
    {
      "question": "Le déterminant du système ax + by = c et a''x + b''y = c'' vaut :",
      "choix": [
        "ab'' − a''b",
        "ab + a''b''",
        "ac'' − a''c",
        "bb'' − aa''"
      ],
      "bonne": 0,
      "explication": "C''est ab'' − a''b. S''il n''est pas nul, le système admet un couple solution et un seul."
    },
    {
      "question": "Dans le pivot de Gauss, que fait-on en premier ?",
      "choix": [
        "on élimine une inconnue dans les autres équations",
        "on multiplie tout par le déterminant",
        "on résout la dernière équation",
        "on additionne les trois équations"
      ],
      "bonne": 0,
      "explication": "On choisit une équation pivot et on s''en sert pour faire disparaître une inconnue dans toutes les autres, jusqu''à obtenir un système en escalier."
    },
    {
      "question": "3 régimes et 2 sacs coûtent 11 500 FCFA, 5 régimes et 4 sacs coûtent 20 500 FCFA. Un régime coûte :",
      "choix": [
        "2 500 FCFA",
        "2 000 FCFA",
        "3 000 FCFA",
        "1 500 FCFA"
      ],
      "bonne": 0,
      "explication": "Le déterminant vaut 2, et la formule de Cramer donne b = (11 500×4 − 20 500×2)/2 = 2 500."
    },
    {
      "question": "Si le déterminant d''un système 2×2 est nul, alors :",
      "choix": [
        "il y a zéro ou une infinité de solutions",
        "il y a toujours une infinité de solutions",
        "il y a toujours zéro solution",
        "il y a une solution unique"
      ],
      "bonne": 0,
      "explication": "Les droites sont parallèles. Si elles sont distinctes il n''y a aucune solution, si elles sont confondues il y en a une infinité."
    }
  ]
}', NULL, 5);

  RAISE NOTICE 'Chapitre 2, Systèmes d''équations à deux ou trois inconnues : 5 lecons ajoutees.';
END $p1c$;
