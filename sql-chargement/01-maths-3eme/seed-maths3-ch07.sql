-- ============================================================================
-- MANDAL — Mathématiques 3ème : chapitre 7, Statistiques
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
  WHERE programme_id = v_programme_id AND ordre = 7;

  -- 4. sinon on le cree
  IF v_chapitre_id IS NULL THEN
    INSERT INTO public.chapitres (programme_id, titre, ordre, niveau)
    VALUES (v_programme_id, 'Statistiques', 7, 'Module 14 : Organisation et gestion des données')
    RETURNING id INTO v_chapitre_id;
    RAISE NOTICE 'Chapitre 7 cree.';
  END IF;

  -- 5. les lecons
  SELECT count(*) INTO v_deja FROM public.concepts WHERE chapitre_id = v_chapitre_id;
  IF v_deja > 0 THEN
    RAISE NOTICE 'Chapitre 7 : contient deja % lecon(s) — aucun ajout.', v_deja;
    RETURN;
  END IF;

  INSERT INTO public.concepts
    (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes) VALUES
    (v_chapitre_id, 'Regrouper des données en classes', 1, 'texte', 'Quand une série comporte beaucoup de valeurs différentes, on ne peut pas toutes les lister. On les regroupe alors par tranches, qu''on appelle des classes.

## Le vocabulaire

La population est l''ensemble étudié, par exemple les élèves d''une classe de 3ème. Le caractère est ce qu''on observe, par exemple la taille. L''effectif d''une classe est le nombre d''individus qui s''y trouvent.

Une classe s''écrit comme un intervalle, par exemple $[150\,;160[$. La borne de gauche est comprise, celle de droite ne l''est pas, pour qu''aucun élève ne soit compté deux fois.

L''amplitude d''une classe est la différence entre ses deux bornes. Ici l''amplitude vaut 10 cm. Le centre de la classe est la moyenne de ses deux bornes, soit 155 cm.

## Un exemple

Voici les tailles, en centimètres, des 40 élèves d''une 3ème de Garoua.

| Classe | Effectif | Centre |
| --- | --- | --- |
| $[140\,;150[$ | 4 | 145 |
| $[150\,;160[$ | 11 | 155 |
| $[160\,;170[$ | 15 | 165 |
| $[170\,;180[$ | 8 | 175 |
| $[180\,;190[$ | 2 | 185 |

## La classe modale

C''est la classe qui a le plus grand effectif, à condition que toutes les classes aient la même amplitude. Ici c''est $[160\,;170[$, avec 15 élèves.

## La fréquence

La fréquence d''une classe est la part qu''elle représente dans le total :

$$f = \dfrac{\text{effectif de la classe}}{\text{effectif total}}$$

Pour la classe $[160\,;170[$, la fréquence vaut $\dfrac{15}{40} = 0{,}375$, soit 37,5 %.

La somme de toutes les fréquences vaut toujours 1, c''est-à-dire 100 %.

## Exercice d''application

Avec le tableau ci-dessus, calcule la fréquence de la classe $[150\,;160[$ en pourcentage, puis donne l''amplitude et le centre de la classe $[170\,;180[$.

Correction. La fréquence vaut $\dfrac{11}{40} = 0{,}275$, soit 27,5 %. L''amplitude de $[170\,;180[$ vaut $180 - 170 = 10$, et son centre vaut $\dfrac{170 + 180}{2} = 175$.', NULL, 15),
    (v_chapitre_id, 'La moyenne d''une série groupée', 2, 'texte', 'Quand les données sont regroupées en classes, on ne connaît plus les valeurs exactes. On remplace alors chaque classe par son centre, ce qui donne une bonne approximation.

## La formule

$$\overline{x} = \dfrac{n_{1}c_{1} + n_{2}c_{2} + \ldots + n_{p}c_{p}}{n_{1} + n_{2} + \ldots + n_{p}}$$

où $n_{i}$ est l''effectif de la classe et $c_{i}$ son centre.

## Le calcul sur l''exemple

Reprenons les tailles des 40 élèves.

$$\overline{x} = \dfrac{4 \times 145 + 11 \times 155 + 15 \times 165 + 8 \times 175 + 2 \times 185}{40}$$

Calculons le numérateur : $580 + 1\,705 + 2\,475 + 1\,400 + 370 = 6\,530$.

$$\overline{x} = \dfrac{6\,530}{40} = 163{,}25$$

La taille moyenne est d''environ 163,3 cm.

## La moyenne avec les fréquences

On peut aussi écrire $\overline{x} = f_{1}c_{1} + f_{2}c_{2} + \ldots + f_{p}c_{p}$. Le résultat est le même, et ce calcul est pratique quand l''énoncé donne directement des pourcentages.

## Attention

Cette moyenne reste une valeur approchée, puisqu''on a supposé que tous les élèves d''une classe mesurent exactement le centre de leur classe. C''est une approximation acceptable, pas une valeur exacte.

## Exercice d''application

Les notes de 25 élèves se répartissent ainsi : 6 élèves dans $[0\,;5[$, 9 dans $[5\,;10[$, 7 dans $[10\,;15[$ et 3 dans $[15\,;20[$. Calcule la moyenne de la classe.

Correction. Les centres valent 2,5 ; 7,5 ; 12,5 et 17,5. Le numérateur vaut $6 \times 2{,}5 + 9 \times 7{,}5 + 7 \times 12{,}5 + 3 \times 17{,}5 = 15 + 67{,}5 + 87{,}5 + 52{,}5 = 222{,}5$. La moyenne vaut $\dfrac{222{,}5}{25} = 8{,}9$.', NULL, 15),
    (v_chapitre_id, 'Simulation : construis ta série et observe la moyenne', 3, 'interactif', '{
  "widget": "statistiques",
  "consigne": "Tire les points orange pour choisir combien d''élèves ont eu chaque note. Donne d''abord une série régulière, puis ajoute beaucoup d''élèves à la note 18 et regarde la moyenne grimper alors que la médiane bouge à peine. C''est pour cela qu''une seule très bonne note ne suffit pas à représenter une classe, et qu''on regarde aussi la médiane."
}', NULL, 10),
    (v_chapitre_id, 'Les diagrammes statistiques', 4, 'texte', 'Un tableau se lit, un diagramme se comprend d''un coup d''œil. Il faut savoir construire et lire les quatre types au programme.

## Le diagramme à bâtons

Il sert aux caractères qui prennent des valeurs isolées, comme le nombre de frères et sœurs. On trace un bâton vertical par valeur, de hauteur proportionnelle à l''effectif. Les bâtons ne se touchent pas.

## Le diagramme à bandes, ou histogramme

Il sert aux données groupées en classes. Chaque classe donne un rectangle dont la largeur représente l''amplitude et la hauteur l''effectif. Les rectangles se touchent, parce que les classes se suivent sans trou.

## Le diagramme circulaire

Le disque entier représente la totalité, soit 360 degrés. L''angle d''un secteur se calcule avec

$$\text{angle} = \dfrac{\text{effectif}}{\text{effectif total}} \times 360$$

Pour la classe $[160\,;170[$ de 15 élèves sur 40, l''angle vaut $\dfrac{15}{40} \times 360 = 135$ degrés.

Vérifie toujours que la somme de tes angles fait bien 360 degrés.

## Le diagramme semi-circulaire

Même principe, mais sur un demi-disque. On remplace alors 360 par 180 dans la formule.

Pour la même classe, l''angle vaut $\dfrac{15}{40} \times 180 = 67{,}5$ degrés.

## Exercice d''application

Sur 40 élèves, 8 se rendent à l''école à pied, 22 en moto-taxi et 10 en bus. Calcule les trois angles d''un diagramme circulaire.

Correction. À pied : $\dfrac{8}{40} \times 360 = 72$ degrés. En moto-taxi : $\dfrac{22}{40} \times 360 = 198$ degrés. En bus : $\dfrac{10}{40} \times 360 = 90$ degrés. La somme vaut $72 + 198 + 90 = 360$ degrés, le compte est bon.', NULL, 15),
    (v_chapitre_id, 'Quiz : statistiques', 5, 'quiz', '{
  "titre": "Vérifie que tu as compris",
  "questions": [
    {
      "question": "Dans la classe $[20\\,;30[$, l''amplitude et le centre valent :",
      "choix": [
        "10 et 25",
        "30 et 25",
        "10 et 50"
      ],
      "bonne": 0,
      "explication": "L''amplitude est $30 - 20 = 10$, et le centre est la moyenne des bornes, soit 25."
    },
    {
      "question": "Sur 50 élèves, 20 pratiquent le football. La fréquence vaut :",
      "choix": [
        "20 %",
        "40 %",
        "0,4 %"
      ],
      "bonne": 1,
      "explication": "$\\dfrac{20}{50} = 0{,}4$, soit 40 %."
    },
    {
      "question": "Dans un diagramme circulaire, un effectif représentant le quart du total correspond à un angle de :",
      "choix": [
        "$45$ degrés",
        "$90$ degrés",
        "$120$ degrés"
      ],
      "bonne": 1,
      "explication": "$\\dfrac{1}{4} \\times 360 = 90$ degrés."
    },
    {
      "question": "La classe modale d''une série groupée est :",
      "choix": [
        "celle du milieu",
        "celle dont l''effectif est le plus grand",
        "celle qui contient la moyenne"
      ],
      "bonne": 1,
      "explication": "C''est la classe la plus fréquente, à condition que toutes les classes aient la même amplitude."
    }
  ]
}', NULL, 5),
    (v_chapitre_id, 'Exercices d''entraînement corrigés', 6, 'texte', '## Exercice 1

On relève les salaires mensuels, en milliers de FCFA, de 60 employés d''une entreprise de Douala.

| Classe | Effectif |
| --- | --- |
| $[50\,;100[$ | 18 |
| $[100\,;150[$ | 24 |
| $[150\,;200[$ | 12 |
| $[200\,;250[$ | 6 |

a) Donne la classe modale.
b) Calcule le salaire moyen.
c) Quelle part des employés gagne moins de 150 000 FCFA ?

Correction. a) La classe modale est $[100\,;150[$, avec 24 employés. b) Les centres valent 75, 125, 175 et 225. Le numérateur vaut $18 \times 75 + 24 \times 125 + 12 \times 175 + 6 \times 225 = 1\,350 + 3\,000 + 2\,100 + 1\,350 = 7\,800$. La moyenne vaut $\dfrac{7\,800}{60} = 130$, soit 130 000 FCFA. c) Les deux premières classes totalisent $18 + 24 = 42$ employés, soit $\dfrac{42}{60} = 0{,}7$, c''est-à-dire 70 %.

## Exercice 2

Avec la série précédente, calcule les quatre angles d''un diagramme circulaire.

Correction. $\dfrac{18}{60} \times 360 = 108$ degrés, $\dfrac{24}{60} \times 360 = 144$ degrés, $\dfrac{12}{60} \times 360 = 72$ degrés et $\dfrac{6}{60} \times 360 = 36$ degrés. La somme vaut $108 + 144 + 72 + 36 = 360$ degrés.

## Exercice 3

Une série a pour moyenne 12 sur 20 élèves. On ajoute un 21e élève qui obtient 19. Quelle est la nouvelle moyenne ?

Correction. La somme des 20 premières notes vaut $12 \times 20 = 240$. La nouvelle somme vaut $240 + 19 = 259$, donc la nouvelle moyenne vaut $\dfrac{259}{21} \approx 12{,}33$.', NULL, 15),
    (v_chapitre_id, 'Activité d''intégration : l''enquête du conseil de classe', 7, 'texte', '## La situation

Le professeur principal de la 3ème B a relevé le temps de trajet quotidien, en minutes, de ses 50 élèves.

| Temps de trajet | Effectif |
| --- | --- |
| $[0\,;15[$ | 12 |
| $[15\,;30[$ | 20 |
| $[30\,;45[$ | 13 |
| $[45\,;60[$ | 5 |

Le conseil de classe veut savoir s''il faut décaler le début des cours de 7 h à 7 h 30.

1. Quelle est la classe modale ?
2. Calcule le temps de trajet moyen.
3. Quel pourcentage d''élèves met au moins 30 minutes ?
4. Calcule les angles d''un diagramme circulaire, puis rédige une recommandation pour le conseil.

## La solution

1. La classe modale est $[15\,;30[$, avec 20 élèves. C''est la tranche la plus représentée.

2. Les centres valent 7,5 ; 22,5 ; 37,5 et 52,5 minutes. Le numérateur vaut
$$12 \times 7{,}5 + 20 \times 22{,}5 + 13 \times 37{,}5 + 5 \times 52{,}5 = 90 + 450 + 487{,}5 + 262{,}5 = 1\,290$$
La moyenne vaut $\dfrac{1\,290}{50} = 25{,}8$ minutes.

3. Les élèves mettant au moins 30 minutes sont ceux des deux dernières classes, soit $13 + 5 = 18$ élèves. Cela représente $\dfrac{18}{50} = 0{,}36$, c''est-à-dire 36 %.

4. Les angles valent $\dfrac{12}{50} \times 360 = 86{,}4$ degrés, $\dfrac{20}{50} \times 360 = 144$ degrés, $\dfrac{13}{50} \times 360 = 93{,}6$ degrés et $\dfrac{5}{50} \times 360 = 36$ degrés. Leur somme fait bien 360 degrés.

Recommandation possible : plus d''un tiers des élèves passe au moins une demi-heure en trajet, et cinq d''entre eux approchent l''heure. Décaler le début des cours à 7 h 30 soulagerait réellement ces 18 élèves. En revanche, 64 % de la classe met moins de 30 minutes, donc le décalage n''est pas indispensable pour la majorité. Le conseil peut choisir un compromis, par exemple 7 h 15.

## Ce qu''il faut remarquer

Les statistiques ne décident pas à ta place. Elles donnent des nombres clairs, et c''est ensuite à l''humain de trancher. C''est exactement ce qu''on attend de toi dans une activité d''intégration : calculer juste, puis conclure avec bon sens.', NULL, 15);

  RAISE NOTICE 'Chapitre 7, Statistiques : 7 lecons ajoutees.';
END $m3$;
