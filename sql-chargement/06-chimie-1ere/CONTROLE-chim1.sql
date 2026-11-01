-- ---------------------------------------------------------------------------
-- M'Andal — Chimie, classes de Première C, D et E
-- Le contrôle à lancer une fois les 19 chapitres chargés.
--
-- Il affiche cinq tableaux. Pour chacun, le commentaire juste au-dessus vous
-- dit ce que vous devez voir. Si ce que vous lisez ne correspond pas, quelque
-- chose s'est mal passé et il faut m'en parler.
-- ---------------------------------------------------------------------------


-- TABLEAU 1 — Les trois séries vues de haut
--
-- Vous devez voir trois lignes, une par série, avec les mêmes chiffres
-- partout : 19 chapitres, 177 leçons, 69 simulations, 19 quiz, 16 figures.
-- Si une série a moins de chapitres que les autres, c'est qu'un script n'a
-- pas été lancé jusqu'au bout.

SELECT p.titre                        AS programme,
       count(DISTINCT ch.id)          AS chapitres,
       count(c.id)                    AS lecons,
       count(*) FILTER (WHERE c.type_contenu = 'interactif') AS simulations,
       count(*) FILTER (WHERE c.type_contenu = 'quiz')       AS quiz,
       count(*) FILTER (WHERE c.type_contenu = 'figure')     AS figures
FROM public.programmes p
JOIN public.chapitres ch ON ch.programme_id = p.id
JOIN public.concepts  c  ON c.chapitre_id   = ch.id
WHERE p.titre LIKE 'Chimie — 1ère%'
GROUP BY p.titre
ORDER BY p.titre;


-- TABLEAU 2 — Le détail, chapitre par chapitre, pour la 1ère C
--
-- Dix-neuf lignes, numérotées de 1 à 19, groupées en trois modules.
-- Si vous additionnez la colonne « lecons », vous devez tomber sur 177.
-- Un chapitre qui manque à l'appel, c'est un fichier oublié : son numéro
-- vous dit lequel.

SELECT ch.ordre                       AS n,
       ch.niveau                      AS module,
       ch.titre                       AS chapitre,
       count(c.id)                    AS lecons,
       count(*) FILTER (WHERE c.type_contenu = 'interactif') AS simulations
FROM public.chapitres ch
JOIN public.programmes p ON p.id = ch.programme_id
JOIN public.concepts  c  ON c.chapitre_id = ch.id
WHERE p.titre = 'Chimie — 1ère C'
GROUP BY ch.ordre, ch.niveau, ch.titre
ORDER BY ch.ordre;


-- TABLEAU 3 — Y a-t-il une leçon de cours sans simulation ?
--
-- Celui-ci doit rester VIDE. Chaque ligne qui apparaîtrait serait une leçon
-- que l'élève lirait sans rien avoir à manipuler derrière.
--
-- Les leçons d'exercices corrigés et les sujets type Probatoire sont écartés
-- du contrôle : ils n'ont pas vocation à porter une simulation, ils en sont
-- l'aboutissement.

WITH lec AS (
  SELECT ch.ordre AS n, ch.titre AS chapitre, c.titre, c.ordre AS pos, c.type_contenu,
         lead(c.type_contenu) OVER (PARTITION BY ch.id ORDER BY c.ordre) AS suivant
  FROM public.chapitres ch
  JOIN public.programmes p ON p.id = ch.programme_id
  JOIN public.concepts  c  ON c.chapitre_id = ch.id
  WHERE p.titre = 'Chimie — 1ère C'
)
SELECT n, chapitre, titre
FROM lec
WHERE type_contenu = 'texte'
  AND titre NOT LIKE 'Sujet type Probatoire%'
  AND titre NOT LIKE 'Exercices%'
  AND coalesce(suivant, '') NOT IN ('interactif', 'figure');


-- TABLEAU 4 — La liste des 69 simulations
--
-- Soixante-neuf lignes. La colonne « widget » donne le nom du composant que
-- le site doit savoir afficher. S'il en manque un dans l'application, l'élève
-- lira « Cette simulation n'est pas reconnue » à la place du dessin — c'est
-- le signe que le site n'a pas été redéployé avant le chargement du SQL.
--
-- La dernière colonne mesure la longueur de la consigne. Elle est là pour
-- repérer une consigne tronquée : aucune ne devrait descendre sous 120.

SELECT ch.ordre AS n,
       c.titre,
       (c.contenu_texte::json ->> 'widget') AS widget,
       length(c.contenu_texte::json ->> 'consigne') AS longueur_consigne
FROM public.chapitres ch
JOIN public.programmes p ON p.id = ch.programme_id
JOIN public.concepts  c  ON c.chapitre_id = ch.id
WHERE p.titre = 'Chimie — 1ère C' AND c.type_contenu = 'interactif'
ORDER BY ch.ordre, c.ordre;


-- TABLEAU 5 — Un chapitre qui ne finirait pas par son quiz ?
--
-- Vide lui aussi. Dans tout le programme, le quiz ferme le chapitre : c'est
-- la convention de l'application, et l'élève s'attend à la retrouver partout.

WITH der AS (
  SELECT ch.ordre AS n, ch.titre,
         (SELECT c.type_contenu FROM public.concepts c
          WHERE c.chapitre_id = ch.id ORDER BY c.ordre DESC LIMIT 1) AS dernier
  FROM public.chapitres ch
  JOIN public.programmes p ON p.id = ch.programme_id
  WHERE p.titre LIKE 'Chimie — 1ère%'
)
SELECT n, titre, dernier FROM der WHERE dernier <> 'quiz';
