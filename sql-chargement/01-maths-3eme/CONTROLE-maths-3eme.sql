-- ============================================================================
-- MANDAL — Contrôle du programme Mathématiques 3ème
--
-- Ne modifie RIEN. Affiche un tableau de 16 lignes, une par chapitre.
-- Tout doit être OK dans la dernière colonne.
-- ============================================================================

SELECT
  c.ordre                                  AS "n°",
  left(c.titre, 46)                        AS "chapitre",
  count(k.id)                              AS "leçons",
  count(*) FILTER (WHERE k.type_contenu = 'texte')      AS "cours",
  count(*) FILTER (WHERE k.type_contenu = 'interactif') AS "simu",
  count(*) FILTER (WHERE k.type_contenu = 'quiz')       AS "quiz",
  CASE WHEN count(k.id) > 0 THEN 'OK' ELSE '>>> VIDE' END AS "verdict"
FROM public.chapitres c
JOIN public.programmes p ON p.id = c.programme_id
LEFT JOIN public.concepts k ON k.chapitre_id = c.id
WHERE p.titre = 'Mathématiques — 3ème'
GROUP BY c.ordre, c.titre
ORDER BY c.ordre;
