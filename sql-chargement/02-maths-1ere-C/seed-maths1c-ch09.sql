-- ============================================================================
-- MANDAL — Mathématiques 1ère C : chapitre 9, Suites numériques
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
  WHERE programme_id = v_programme_id AND ordre = 9;

  -- 4. sinon on le cree
  IF v_chapitre_id IS NULL THEN
    INSERT INTO public.chapitres (programme_id, titre, ordre, niveau)
    VALUES (v_programme_id, 'Suites numériques', 9, 'Module 21 : Relations et opérations fondamentales dans l''ensemble des nombres réels')
    RETURNING id INTO v_chapitre_id;
    RAISE NOTICE 'Chapitre 9 cree.';
  END IF;

  -- 5. les lecons
  SELECT count(*) INTO v_deja FROM public.concepts WHERE chapitre_id = v_chapitre_id;
  IF v_deja > 0 THEN
    RAISE NOTICE 'Chapitre 9 : contient deja % lecon(s) — aucun ajout.', v_deja;
    RETURN;
  END IF;

  INSERT INTO public.concepts
    (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes) VALUES
    (v_chapitre_id, 'Généralités sur les suites', 1, 'texte', 'Une suite, c''est une liste infinie de nombres rangés dans l''ordre. Le premier, le deuxième, le troisième, et ainsi de suite.

## Les notations

On note $(u_{n})$ la suite, et $u_{n}$ son terme de rang $n$. Le rang commence souvent à 0, parfois à 1. Lis bien l''énoncé.

## Les deux façons de définir une suite

La forme explicite donne $u_{n}$ directement en fonction de $n$.

Par exemple $u_{n} = 3n + 2$. Tu calcules $u_{50}$ immédiatement : $3 \times 50 + 2 = 152$.

La forme récurrente donne le premier terme et une relation entre deux termes consécutifs.

Par exemple $u_{0} = 1$ et $u_{n+1} = 2u_{n} + 3$. Pour avoir $u_{50}$, il faut calculer tous les termes précédents, un par un.

## Le sens de variation

$(u_{n})$ est croissante si $u_{n+1} \geq u_{n}$ pour tout $n$.

La méthode la plus sûre est d''étudier le signe de $u_{n+1} - u_{n}$.

Pour $u_{n} = n^{2} - 4n$ :
$$u_{n+1} - u_{n} = (n+1)^{2} - 4(n+1) - n^{2} + 4n = 2n + 1 - 4 = 2n - 3$$

Cette différence est négative pour $n \leq 1$ et positive pour $n \geq 2$. La suite décroît puis croît.

Quand tous les termes sont strictement positifs, tu peux aussi comparer $\dfrac{u_{n+1}}{u_{n}}$ à 1.

## Suite majorée, minorée, bornée

$(u_{n})$ est majorée par $M$ si $u_{n} \leq M$ pour tout $n$. Elle est minorée par $m$ si $u_{n} \geq m$ pour tout $n$. Elle est bornée si elle est les deux à la fois.

Pour $u_{n} = \dfrac{n}{n+1}$, tous les termes sont positifs et strictement inférieurs à 1. La suite est donc bornée par 0 et 1.

## Représenter une suite

Sur un axe, tu places les points $u_{0}$, $u_{1}$, $u_{2}$ et tu observes vers quoi ils se dirigent.

Dans un repère, tu places les points de coordonnées $(n\,;u_{n})$. Ce sont des points isolés, pas une courbe continue.

## Exercice d''application

Soit $u_{n} = \dfrac{2n + 1}{n + 3}$. Étudie le sens de variation et montre que la suite est majorée par 2.

Correction. On écrit $u_{n} = \dfrac{2(n+3) - 5}{n+3} = 2 - \dfrac{5}{n+3}$.

Quand $n$ augmente, $n + 3$ augmente, donc $\dfrac{5}{n+3}$ diminue, donc $u_{n}$ augmente. La suite est croissante.

De plus $\dfrac{5}{n+3} > 0$, donc $u_{n} < 2$ pour tout $n$. La suite est majorée par 2.', NULL, 15),
    (v_chapitre_id, 'Comparer les deux grandes familles de suites', 2, 'interactif', '{
  "widget": "suites",
  "consigne": "Mets la même valeur de départ aux deux suites. Fais grandir la raison géométrique au-delà de 1 et regarde l''écart se creuser. Au bout de combien de termes la suite géométrique dépasse-t-elle l''arithmétique ?"
}', NULL, 10),
    (v_chapitre_id, 'Les suites arithmétiques', 3, 'texte', 'Une suite arithmétique, c''est une suite où l''on ajoute toujours le même nombre pour passer d''un terme au suivant.

## La définition

$(u_{n})$ est arithmétique de raison $r$ si
$$u_{n+1} = u_{n} + r \quad \text{pour tout } n$$

Autrement dit, la différence $u_{n+1} - u_{n}$ est constante et vaut $r$.

## Le terme général

$$u_{n} = u_{0} + nr \qquad \text{ou, si on part du rang 1,} \qquad u_{n} = u_{1} + (n-1)r$$

De façon générale, pour deux rangs $n$ et $p$ :
$$u_{n} = u_{p} + (n - p)r$$

## Le sens de variation

Il ne dépend que du signe de $r$. Si $r > 0$ la suite est croissante, si $r < 0$ elle est décroissante, si $r = 0$ elle est constante.

## La somme des termes

$$S = \text{nombre de termes} \times \dfrac{\text{premier} + \text{dernier}}{2}$$

En particulier
$$1 + 2 + 3 + \dots + n = \dfrac{n(n+1)}{2}$$

C''est l''astuce qu''aurait trouvée Gauss à neuf ans : on apparie le premier avec le dernier, le deuxième avec l''avant-dernier, et chaque paire a la même somme.

## Un exemple concret

Un artisan de Garoua produit 40 tabourets le premier mois, puis 6 de plus chaque mois.

Sa production au mois $n$ est $u_{n} = 40 + 6(n - 1)$, en comptant le premier mois comme le rang 1.

Au douzième mois, il produit $40 + 6 \times 11 = 106$ tabourets.

Sur l''année entière, il produit
$$S = 12 \times \dfrac{40 + 106}{2} = 12 \times 73 = 876 \text{ tabourets}$$

## Exercice d''application

Une suite arithmétique vérifie $u_{3} = 17$ et $u_{10} = 52$. Trouve la raison et le premier terme, puis calcule $u_{0} + u_{1} + \dots + u_{20}$.

Correction. De $u_{10} = u_{3} + 7r$, on tire $52 = 17 + 7r$, donc $r = 5$.

Puis $u_{0} = u_{3} - 3r = 17 - 15 = 2$.

Le terme $u_{20} = 2 + 20 \times 5 = 102$. La somme compte 21 termes :
$$S = 21 \times \dfrac{2 + 102}{2} = 21 \times 52 = 1\,092$$', NULL, 15),
    (v_chapitre_id, 'Les suites géométriques', 4, 'texte', 'Cette fois, on multiplie toujours par le même nombre pour passer d''un terme au suivant.

## La définition

$(u_{n})$ est géométrique de raison $q$ si
$$u_{n+1} = q \times u_{n} \quad \text{pour tout } n$$

## Le terme général

$$u_{n} = u_{0} \times q^{n} \qquad \text{ou} \qquad u_{n} = u_{p} \times q^{\,n-p}$$

## Le comportement

Avec $u_{0} > 0$ : si $q > 1$ la suite croît et explose vers $+\infty$, si $0 < q < 1$ elle décroît vers 0, si $q = 1$ elle est constante.

Si $q$ est négatif, les termes changent de signe à chaque fois. La suite est dite alternée.

La croissance géométrique est beaucoup plus rapide que la croissance arithmétique. C''est pour cela qu''on parle de croissance exponentielle.

## La somme des termes

$$S = \text{premier terme} \times \dfrac{1 - q^{\,\text{nombre de termes}}}{1 - q} \qquad \text{pour } q \neq 1$$

Par exemple
$$1 + q + q^{2} + \dots + q^{n} = \dfrac{1 - q^{n+1}}{1 - q}$$

## Un exemple concret : la tontine

Une femme de Bertoua place 100 000 FCFA dans une tontine qui rapporte 8 % par an, intérêts composés.

Chaque année le capital est multiplié par 1,08. La suite des capitaux est géométrique de raison 1,08.

Au bout de $n$ années, elle possède $C_{n} = 100\,000 \times 1{,}08^{n}$.

Au bout de 10 ans, $C_{10} = 100\,000 \times 1{,}08^{10} \approx 215\,892$ FCFA. Son argent a plus que doublé.

Compare avec un placement simple à 8 000 FCFA d''intérêt par an : au bout de 10 ans elle n''aurait que 180 000 FCFA. L''écart de 36 000 FCFA vient des intérêts qui produisent eux-mêmes des intérêts.

## Un autre exemple : la dépréciation

Une moto achetée 600 000 FCFA perd 15 % de sa valeur chaque année. Sa valeur est multipliée par 0,85 chaque année.

Au bout de 4 ans, elle vaut $600\,000 \times 0{,}85^{4} \approx 313\,204$ FCFA.

## Exercice d''application

Une suite géométrique de raison 3 vérifie $u_{2} = 45$. Calcule $u_{0}$, puis la somme $u_{0} + u_{1} + \dots + u_{6}$.

Correction. De $u_{2} = u_{0} \times 9 = 45$, on tire $u_{0} = 5$.

La somme compte 7 termes :
$$S = 5 \times \dfrac{1 - 3^{7}}{1 - 3} = 5 \times \dfrac{1 - 2\,187}{-2} = 5 \times 1\,093 = 5\,465$$', NULL, 15),
    (v_chapitre_id, 'Quiz du chapitre 9', 5, 'quiz', '{
  "titre": "Vérifie que tu as compris",
  "questions": [
    {
      "question": "Une suite arithmétique de premier terme u₀ et de raison r a pour terme général :",
      "choix": [
        "uₙ = u₀ + nr",
        "uₙ = u₀ × rⁿ",
        "uₙ = u₀ + r",
        "uₙ = n × r"
      ],
      "bonne": 0,
      "explication": "On ajoute r à chaque étape, donc après n étapes on a ajouté nr au premier terme."
    },
    {
      "question": "La somme 1 + 2 + 3 + ... + 100 vaut :",
      "choix": [
        "5 050",
        "10 000",
        "5 000",
        "101"
      ],
      "bonne": 0,
      "explication": "On applique la formule n(n+1)/2 = 100 × 101 / 2 = 5 050."
    },
    {
      "question": "Une suite géométrique de raison 0,5 et de premier terme positif :",
      "choix": [
        "décroît et se rapproche de 0",
        "croît vers l''infini",
        "est constante",
        "alterne de signe"
      ],
      "bonne": 0,
      "explication": "Quand la raison est comprise strictement entre 0 et 1, chaque terme est plus petit que le précédent et la suite tend vers 0."
    },
    {
      "question": "Un capital de 100 000 FCFA placé à 8 % par an pendant 3 ans donne :",
      "choix": [
        "100 000 × 1,08³",
        "100 000 × 3 × 0,08",
        "100 000 + 8 × 3",
        "100 000 × 0,08³"
      ],
      "bonne": 0,
      "explication": "Avec des intérêts composés, le capital est multiplié par 1,08 chaque année, donc par 1,08³ au bout de trois ans."
    },
    {
      "question": "Pour étudier le sens de variation d''une suite, la méthode la plus sûre est :",
      "choix": [
        "étudier le signe de uₙ₊₁ − uₙ",
        "calculer les dix premiers termes",
        "regarder le signe de uₙ",
        "calculer la limite"
      ],
      "bonne": 0,
      "explication": "Le signe de la différence entre deux termes consécutifs donne directement le sens de variation, pour toutes les suites."
    },
    {
      "question": "Si u₃ = 17 et u₁₀ = 52 dans une suite arithmétique, la raison vaut :",
      "choix": [
        "5",
        "7",
        "35",
        "3,5"
      ],
      "bonne": 0,
      "explication": "Entre les rangs 3 et 10 il y a 7 pas, et l''écart vaut 52 − 17 = 35. Donc r = 35/7 = 5."
    }
  ]
}', NULL, 5);

  RAISE NOTICE 'Chapitre 9, Suites numériques : 5 lecons ajoutees.';
END $p1c$;
