-- ---------------------------------------------------------------------------
-- M'Andal — Informatique, classes de Première A, C et D
-- Le contrôle à lancer une fois les 20 chapitres chargés.
--
-- Il affiche six tableaux. Pour chacun, le commentaire juste au-dessus vous dit
-- ce que vous devez voir. Si ce que vous lisez ne correspond pas, quelque chose
-- s'est mal passé et il faut m'en parler.
-- ---------------------------------------------------------------------------


-- TABLEAU 1 — Les trois séries vues de haut
--
-- Vous devez voir trois lignes, une par série, avec les mêmes chiffres partout :
-- 20 chapitres, 143 leçons, 55 simulations, 20 quiz, 12 figures.
-- Si une série a moins de chapitres que les autres, c'est qu'un script n'a pas
-- été lancé jusqu'au bout.

SELECT p.titre                        AS programme,
       count(DISTINCT ch.id)          AS chapitres,
       count(c.id)                    AS lecons,
       count(*) FILTER (WHERE c.type_contenu = 'interactif') AS simulations,
       count(*) FILTER (WHERE c.type_contenu = 'quiz')       AS quiz,
       count(*) FILTER (WHERE c.type_contenu = 'figure')     AS figures
FROM public.programmes p
JOIN public.chapitres ch ON ch.programme_id = p.id
JOIN public.concepts  c  ON c.chapitre_id   = ch.id
WHERE p.titre LIKE 'Informatique — 1ère%'
GROUP BY p.titre
ORDER BY p.titre;


-- TABLEAU 2 — Les trois modules
--
-- Trois lignes, dans cet ordre :
--   Module 1 : Maintenance informatique          7 chapitres, 49 leçons
--   Module 2 : Algorithmique et programmation   10 chapitres, 72 leçons
--   Module 3 : Infographie et multimédia         3 chapitres, 22 leçons

SELECT ch.niveau                      AS module,
       count(*)                       AS chapitres,
       sum(n.lecons)                  AS lecons
FROM public.chapitres ch
JOIN public.programmes p ON p.id = ch.programme_id
JOIN LATERAL (SELECT count(*) AS lecons FROM public.concepts c
              WHERE c.chapitre_id = ch.id) n ON true
WHERE p.titre = 'Informatique — 1ère A'
GROUP BY ch.niveau
ORDER BY min(ch.ordre);


-- TABLEAU 3 — Le détail, chapitre par chapitre, pour la 1ère A
--
-- Vingt lignes, numérotées de 1 à 20. Si vous additionnez la colonne « lecons »,
-- vous devez tomber sur 143. Un chapitre qui manque à l'appel, c'est un fichier
-- oublié : son numéro vous dit lequel.

SELECT ch.ordre                       AS n,
       ch.niveau                      AS module,
       ch.titre                       AS chapitre,
       count(c.id)                    AS lecons,
       count(*) FILTER (WHERE c.type_contenu = 'interactif') AS simulations
FROM public.chapitres ch
JOIN public.programmes p ON p.id = ch.programme_id
JOIN public.concepts  c  ON c.chapitre_id = ch.id
WHERE p.titre = 'Informatique — 1ère A'
GROUP BY ch.ordre, ch.niveau, ch.titre
ORDER BY ch.ordre;


-- TABLEAU 4 — Y a-t-il une leçon de cours sans simulation ?
--
-- Celui-ci doit rester VIDE. Chaque ligne qui apparaîtrait serait une leçon que
-- l'élève lirait sans rien avoir à manipuler derrière.
--
-- Les trois sujets type Probatoire sont écartés du contrôle : ils n'ont pas
-- vocation à porter une simulation, ils en sont l'aboutissement.

WITH lec AS (
  SELECT ch.ordre AS n, ch.titre AS chapitre, c.titre, c.type_contenu,
         lead(c.type_contenu) OVER (PARTITION BY ch.id ORDER BY c.ordre) AS suivant
  FROM public.chapitres ch
  JOIN public.programmes p ON p.id = ch.programme_id
  JOIN public.concepts  c  ON c.chapitre_id = ch.id
  WHERE p.titre = 'Informatique — 1ère A'
)
SELECT n, chapitre, titre
FROM lec
WHERE type_contenu = 'texte'
  AND titre NOT LIKE 'Sujet type Probatoire%'
  AND titre NOT LIKE 'Exercices%'
  AND coalesce(suivant, '') NOT IN ('interactif', 'figure');


-- TABLEAU 5 — La liste des 55 simulations
--
-- Cinquante-cinq lignes. La colonne « widget » donne le nom du composant que le
-- site doit savoir afficher. S'il en manque un dans l'application, l'élève lira
-- « Cette simulation n'est pas reconnue » à la place du dessin — c'est le signe
-- que le site n'a pas été redéployé avant le chargement du SQL.
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
WHERE p.titre = 'Informatique — 1ère A' AND c.type_contenu = 'interactif'
ORDER BY ch.ordre, c.ordre;


-- TABLEAU 6 — Un chapitre qui ne finirait pas par son quiz ?
--
-- Vide lui aussi. Dans tout le programme, le quiz ferme le chapitre : c'est la
-- convention de l'application, et l'élève s'attend à la retrouver partout.

WITH der AS (
  SELECT ch.ordre AS n, ch.titre,
         (SELECT c.type_contenu FROM public.concepts c
          WHERE c.chapitre_id = ch.id ORDER BY c.ordre DESC LIMIT 1) AS dernier
  FROM public.chapitres ch
  JOIN public.programmes p ON p.id = ch.programme_id
  WHERE p.titre LIKE 'Informatique — 1ère%'
)
SELECT n, titre, dernier FROM der WHERE dernier <> 'quiz';
