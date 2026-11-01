-- ============================================================================
-- MANDAL — Contrôle de la densification des simulations, Mathématiques 1ère C
--
-- Ne modifie RIEN. À lancer après les quatre scripts
-- seed-maths1c-simulations-1 à 4.
-- Envoyez-moi une capture des trois tableaux.
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 1. Chapitre par chapitre : combien de leçons, combien de simulations ?
--    Attendu : 158 leçons au total, dont 67 simulations.
-- ----------------------------------------------------------------------------
SELECT
  c.ordre                                                                AS "chap",
  left(c.titre, 44)                                                      AS "chapitre",
  count(k.id)                                                            AS "leçons",
  count(*) FILTER (WHERE k.type_contenu IN ('interactif', 'simulation')) AS "simulations",
  count(*) FILTER (WHERE k.type_contenu = 'simulation')                  AS "dont PhET",
  count(*) FILTER (WHERE k.type_contenu = 'quiz')                        AS "quiz"
FROM public.chapitres c
JOIN public.programmes p ON p.id = c.programme_id
LEFT JOIN public.concepts k ON k.chapitre_id = c.id
WHERE p.titre = 'Mathématiques — 1ère C'
GROUP BY c.ordre, c.titre
ORDER BY c.ordre;


-- ----------------------------------------------------------------------------
-- 2. Reste-t-il une leçon de cours sans simulation juste après ?
--    Attendu : AUCUNE LIGNE. Si une ligne apparaît, dites-le-moi.
-- ----------------------------------------------------------------------------
WITH suite AS (
  SELECT
    c.ordre AS chap,
    k.ordre AS pos,
    k.titre,
    k.type_contenu,
    lead(k.type_contenu) OVER (PARTITION BY c.id ORDER BY k.ordre) AS type_suivant
  FROM public.concepts k
  JOIN public.chapitres c ON c.id = k.chapitre_id
  JOIN public.programmes p ON p.id = c.programme_id
  WHERE p.titre = 'Mathématiques — 1ère C'
)
SELECT chap AS "chap", pos AS "position", left(titre, 56) AS "leçon de cours sans simulation"
FROM suite
WHERE type_contenu = 'texte'
  AND titre NOT LIKE 'Exercices%'
  AND titre NOT LIKE 'Activité d''intégration%'
  AND (type_suivant IS NULL
       OR type_suivant NOT IN ('interactif', 'simulation', 'figure', 'graphique'))
ORDER BY chap, pos;


-- ----------------------------------------------------------------------------
-- 3. Les neuf simulations PhET et leur adresse.
--    Attendu : 7 lignes, toutes en https://phet.colorado.edu/... et en _fr.html
-- ----------------------------------------------------------------------------
SELECT
  c.ordre          AS "chap",
  left(k.titre, 50) AS "leçon",
  k.media_url       AS "adresse de la simulation"
FROM public.concepts k
JOIN public.chapitres c ON c.id = k.chapitre_id
JOIN public.programmes p ON p.id = c.programme_id
WHERE p.titre = 'Mathématiques — 1ère C'
  AND k.type_contenu = 'simulation'
ORDER BY c.ordre, k.ordre;
