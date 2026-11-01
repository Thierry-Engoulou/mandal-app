-- ============================================================================
-- MANDAL — Contrôle du programme Physique 1ère D après la mise à jour
--
-- Ne modifie RIEN. Affiche 17 lignes, une par chapitre, avec son module.
-- Tout doit être OK dans la dernière colonne.
-- ============================================================================

SELECT
  c.ordre                                               AS "n°",
  left(coalesce(c.niveau, 'SANS MODULE'), 11)           AS "module",
  left(c.titre, 44)                                     AS "chapitre",
  count(k.id)                                           AS "leçons",
  count(*) FILTER (WHERE k.type_contenu = 'quiz')       AS "quiz",
  count(*) FILTER (WHERE k.type_contenu = 'interactif') AS "simu",
  count(*) FILTER (WHERE k.type_contenu = 'figure')     AS "figures",
  CASE
    WHEN c.niveau IS NULL THEN '>>> SANS MODULE'
    WHEN count(*) FILTER (WHERE k.type_contenu = 'quiz') = 0 THEN '>>> SANS QUIZ'
    ELSE 'OK'
  END                                                   AS "verdict"
FROM public.chapitres c
JOIN public.programmes p ON p.id = c.programme_id
LEFT JOIN public.concepts k ON k.chapitre_id = c.id
WHERE p.titre = 'Physique — 1ère D'
GROUP BY c.ordre, c.niveau, c.titre
ORDER BY c.ordre;
