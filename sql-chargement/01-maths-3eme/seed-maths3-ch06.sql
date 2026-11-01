-- ============================================================================
-- MANDAL — Mathématiques 3ème : chapitre 6, Applications linéaires et applications affines
-- 7 leçons.
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
  WHERE programme_id = v_programme_id AND ordre = 6;

  -- 4. sinon on le cree
  IF v_chapitre_id IS NULL THEN
    INSERT INTO public.chapitres (programme_id, titre, ordre, niveau)
    VALUES (v_programme_id, 'Applications linéaires et applications affines', 6, 'Module 14 : Organisation et gestion des données')
    RETURNING id INTO v_chapitre_id;
    RAISE NOTICE 'Chapitre 6 cree.';
  END IF;

  -- 5. les lecons
  SELECT count(*) INTO v_deja FROM public.concepts WHERE chapitre_id = v_chapitre_id;
  IF v_deja > 0 THEN
    RAISE NOTICE 'Chapitre 6 : contient deja % lecon(s) — aucun ajout.', v_deja;
    RETURN;
  END IF;

  INSERT INTO public.concepts
    (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes) VALUES
    (v_chapitre_id, 'Les applications linéaires', 1, 'texte', 'Au marché, 1 kg de tomates coûte 800 FCFA. Pour 2 kg tu payes 1 600 FCFA, pour 5 kg tu payes 4 000 FCFA. Le prix est proportionnel à la masse : c''est une application linéaire.

## Définition

Une application linéaire est une application $f$ définie sur $\mathbb{R}$ par $f(x) = ax$, où $a$ est un réel fixé appelé coefficient de l''application.

Pour les tomates, $f(x) = 800x$ où $x$ est la masse en kilogrammes.

## Comment la reconnaître

Une application linéaire traduit toujours une situation de proportionnalité. Elle a trois marques reconnaissables.

Son image de zéro est nulle : $f(0) = 0$. Si tu n''achètes rien, tu ne payes rien.

Elle conserve les multiples : $f(3x) = 3f(x)$. Si tu prends trois fois plus, tu payes trois fois plus.

Sa représentation graphique est une droite qui passe par l''origine du repère.

## Déterminer le coefficient

Si tu connais une image, tu obtiens $a$ par une division : $a = \dfrac{f(x)}{x}$.

Un taxi-moto demande 1 500 FCFA pour 6 km. Si le prix est proportionnel à la distance, alors $a = \dfrac{1\,500}{6} = 250$. Le prix vaut donc $f(x) = 250x$, soit 250 FCFA le kilomètre.

## Image et antécédent

L''image de 4 par $f$ est $f(4) = 250 \times 4 = 1\,000$.

Chercher l''antécédent de 3 000, c''est résoudre $250x = 3\,000$, ce qui donne $x = 12$. Avec 3 000 FCFA tu parcours 12 km.

## Exercice d''application

Soit $f$ linéaire telle que $f(5) = 35$. Détermine $f$, puis calcule $f(-2)$ et l''antécédent de 84.

Correction. On a $a = \dfrac{35}{5} = 7$, donc $f(x) = 7x$. Ensuite $f(-2) = -14$. Enfin $7x = 84$ donne $x = 12$.', NULL, 15),
    (v_chapitre_id, 'Les applications affines', 2, 'texte', 'Change la situation : le taxi-moto demande maintenant 300 FCFA de prise en charge, puis 250 FCFA par kilomètre. Le prix n''est plus proportionnel, mais il reste très simple à écrire.

## Définition

Une application affine est une application $f$ définie sur $\mathbb{R}$ par $f(x) = ax + b$, où $a$ et $b$ sont des réels fixés.

Le nombre $a$ s''appelle le coefficient directeur, le nombre $b$ l''ordonnée à l''origine.

Pour le taxi-moto, $f(x) = 250x + 300$.

## Lien avec les applications linéaires

Une application linéaire est une application affine particulière, celle où $b = 0$. Autrement dit, toute application linéaire est affine, mais une application affine n''est linéaire que si sa droite passe par l''origine.

## Représentation graphique

La représentation graphique d''une application affine est une droite. Elle coupe l''axe des ordonnées au point d''ordonnée $b$.

Le coefficient $a$ indique la pente : quand $x$ augmente de 1, $f(x)$ augmente de $a$. Si $a$ est positif l''application est croissante, si $a$ est négatif elle est décroissante, et si $a$ est nul elle est constante.

## Déterminer une application affine à partir de deux points

Connaissant $f(x_{1}) = y_{1}$ et $f(x_{2}) = y_{2}$, on calcule d''abord

$$a = \dfrac{y_{2} - y_{1}}{x_{2} - x_{1}}$$

puis on trouve $b$ en remplaçant dans l''une des deux égalités.

Exemple : $f(2) = 11$ et $f(5) = 23$. On a $a = \dfrac{23 - 11}{5 - 2} = \dfrac{12}{3} = 4$. Puis $f(2) = 11$ donne $4 \times 2 + b = 11$, donc $b = 3$. Ainsi $f(x) = 4x + 3$.

## Exercice d''application

Une application affine vérifie $f(0) = -2$ et $f(4) = 10$. Détermine son expression, puis l''antécédent de 1.

Correction. Comme $f(0) = b$, on a directement $b = -2$. Ensuite $a = \dfrac{10 - (-2)}{4 - 0} = 3$. Donc $f(x) = 3x - 2$. Pour l''antécédent de 1, on résout $3x - 2 = 1$, donc $x = 1$.', NULL, 15),
    (v_chapitre_id, 'Simulation : linéaire ou affine ?', 3, 'interactif', '{
  "widget": "application-affine",
  "consigne": "Mets $b$ à zéro : la droite passe par l''origine et l''application est linéaire. Déplace le point rouge et vérifie que doubler $x$ double bien $f(x)$. Remets $b$ à 2 : la droite se décale vers le haut, l''application devient affine, et doubler $x$ ne double plus l''image. Rends enfin $a$ négatif et observe la droite descendre."
}', NULL, 10),
    (v_chapitre_id, 'Les applications affines par intervalles', 4, 'texte', 'Certains tarifs changent de règle en cours de route. L''application n''a alors pas la même expression partout : elle est affine par intervalles.

## De quoi s''agit-il

Une application est affine par intervalles lorsque son expression change selon l''intervalle auquel appartient $x$, tout en restant affine sur chaque morceau.

## Un exemple de facture d''électricité

Une compagnie facture l''électricité ainsi : 50 FCFA le kilowattheure pour les 100 premiers kWh, puis 85 FCFA au-delà.

Pour $0 \leq x \leq 100$, la facture vaut $f(x) = 50x$.

Pour $x > 100$, les 100 premiers kWh coûtent $50 \times 100 = 5\,000$ FCFA, et le reste, qui vaut $x - 100$ kWh, coûte $85(x - 100)$. Donc
$$f(x) = 5\,000 + 85(x - 100) = 85x - 3\,500$$

## Calculer une facture

Pour 80 kWh, on est dans le premier morceau : $f(80) = 50 \times 80 = 4\,000$ FCFA.

Pour 250 kWh, on est dans le second : $f(250) = 85 \times 250 - 3\,500 = 21\,250 - 3\,500 = 17\,750$ FCFA.

## La représentation graphique

C''est une ligne brisée. Chaque morceau est un segment de droite, et les morceaux se rejoignent aux bornes des intervalles. Ici la cassure se trouve en $x = 100$, où la facture vaut 5 000 FCFA selon les deux expressions. C''est normal : le tarif change, mais la facture ne saute pas brusquement.

## Exercice d''application

Avec le tarif ci-dessus, combien paye un ménage qui consomme 160 kWh ? Et quelle consommation correspond à une facture de 10 000 FCFA ?

Correction. Pour 160 kWh, $f(160) = 85 \times 160 - 3\,500 = 13\,600 - 3\,500 = 10\,100$ FCFA. Pour la facture de 10 000 FCFA, elle dépasse 5 000, donc on est dans le second morceau : $85x - 3\,500 = 10\,000$ donne $85x = 13\,500$, soit $x \approx 158{,}8$ kWh.', NULL, 15),
    (v_chapitre_id, 'Quiz : applications linéaires et affines', 5, 'quiz', '{
  "titre": "Vérifie que tu as compris",
  "questions": [
    {
      "question": "Parmi ces applications, laquelle est linéaire ?",
      "choix": [
        "$f(x) = 3x + 1$",
        "$f(x) = -5x$",
        "$f(x) = x^{2}$"
      ],
      "bonne": 1,
      "explication": "Une application linéaire s''écrit $ax$ sans terme constant. $3x+1$ est affine, et $x^{2}$ n''est ni l''une ni l''autre."
    },
    {
      "question": "Pour $f(x) = -2x + 7$, que vaut $f(3)$ ?",
      "choix": [
        "$1$",
        "$13$",
        "$-1$"
      ],
      "bonne": 0,
      "explication": "$f(3) = -2 \\times 3 + 7 = -6 + 7 = 1$."
    },
    {
      "question": "Une application affine vérifie $f(1) = 5$ et $f(4) = 14$. Son coefficient directeur vaut :",
      "choix": [
        "$9$",
        "$3$",
        "$\\dfrac{1}{3}$"
      ],
      "bonne": 1,
      "explication": "$a = \\dfrac{14 - 5}{4 - 1} = \\dfrac{9}{3} = 3$."
    },
    {
      "question": "La droite représentant $f(x) = 4x - 6$ coupe l''axe des ordonnées au point d''ordonnée :",
      "choix": [
        "$4$",
        "$-6$",
        "$6$"
      ],
      "bonne": 1,
      "explication": "L''ordonnée à l''origine est $b$, c''est-à-dire $f(0) = -6$."
    }
  ]
}', NULL, 5),
    (v_chapitre_id, 'Exercices d''entraînement corrigés', 6, 'texte', '## Exercice 1

Soit $f$ linéaire avec $f(7) = -21$. Donne son expression, puis l''antécédent de 15.

Correction. $a = \dfrac{-21}{7} = -3$, donc $f(x) = -3x$. Ensuite $-3x = 15$ donne $x = -5$.

## Exercice 2

Détermine l''application affine $g$ telle que $g(-1) = 8$ et $g(3) = -4$.

Correction. $a = \dfrac{-4 - 8}{3 - (-1)} = \dfrac{-12}{4} = -3$. Puis $g(-1) = 8$ donne $3 + b = 8$, donc $b = 5$. Ainsi $g(x) = -3x + 5$.

## Exercice 3

Une application affine $h$ est croissante et vérifie $h(0) = -1$. Que peux-tu dire de son coefficient directeur ?

Correction. Comme $h(0) = b$, on a $b = -1$. Une application affine est croissante quand son coefficient directeur est strictement positif, donc $a > 0$.

## Exercice 4

Un plombier de Yaoundé facture 5 000 FCFA de déplacement puis 3 000 FCFA par heure de travail.

a) Exprime le prix $P(t)$ en fonction du nombre d''heures $t$.
b) Combien coûte une intervention de 4 heures ?
c) Une facture s''élève à 26 000 FCFA. Combien d''heures a-t-il travaillé ?

Correction. a) $P(t) = 3\,000t + 5\,000$. b) $P(4) = 12\,000 + 5\,000 = 17\,000$ FCFA. c) On résout $3\,000t + 5\,000 = 26\,000$, donc $3\,000t = 21\,000$ et $t = 7$ heures.', NULL, 15),
    (v_chapitre_id, 'Activité d''intégration : choisir son forfait téléphonique', 7, 'texte', '## La situation

Deux opérateurs proposent un forfait internet à Douala.

Le premier facture 500 FCFA par gigaoctet, sans abonnement.

Le second demande 4 000 FCFA d''abonnement mensuel, puis 250 FCFA par gigaoctet.

1. Exprime le coût mensuel de chaque offre en fonction du nombre $x$ de gigaoctets consommés, et dis pour chacune si l''application est linéaire ou affine.
2. Calcule le coût des deux offres pour 10 Go, puis pour 30 Go.
3. Pour quelle consommation les deux offres coûtent-elles la même chose ?
4. Ton frère consomme environ 25 Go par mois. Conseille-lui une offre, en justifiant.

## La solution

1. Première offre : $f(x) = 500x$. Il n''y a pas de terme constant, donc l''application est linéaire. Seconde offre : $g(x) = 250x + 4\,000$. Le terme constant 4 000 la rend affine mais pas linéaire.

2. Pour 10 Go : $f(10) = 5\,000$ FCFA et $g(10) = 2\,500 + 4\,000 = 6\,500$ FCFA. La première est moins chère.

Pour 30 Go : $f(30) = 15\,000$ FCFA et $g(30) = 7\,500 + 4\,000 = 11\,500$ FCFA. Cette fois la seconde est moins chère.

3. On cherche $x$ tel que $f(x) = g(x)$ :
$$500x = 250x + 4\,000$$
$$250x = 4\,000$$
$$x = 16$$
À 16 Go, les deux offres coûtent exactement 8 000 FCFA.

4. Ton frère consomme 25 Go, c''est-à-dire plus que 16 Go. Il doit donc prendre la seconde offre. Elle lui coûtera $g(25) = 6\,250 + 4\,000 = 10\,250$ FCFA, contre $f(25) = 12\,500$ FCFA pour l''autre. Il économise 2 250 FCFA par mois.

## Ce qu''il faut remarquer

Le point d''égalité à 16 Go partage la décision en deux. En dessous, l''offre sans abonnement gagne. Au-dessus, l''abonnement est rentabilisé. Tu retrouveras exactement ce raisonnement avec les droites du chapitre 15.', NULL, 15);

  RAISE NOTICE 'Chapitre 6, Applications linéaires et applications affines : 7 lecons ajoutees.';
END $m3$;
