-- ============================================================================
-- MANDAL — Contrôle du programme Mathématiques 1ère C
--
-- Ne modifie RIEN. Affiche 21 lignes, une par chapitre.
-- La dernière colonne doit afficher OK partout.
-- ============================================================================

SELECT
  c.ordre                                               AS "n°",
  left(coalesce(c.niveau, 'SANS MODULE'), 11)           AS "module",
  left(c.titre, 42)                                     AS "chapitre",
  count(k.id)                                           AS "leçons",
  count(*) FILTER (WHERE k.type_contenu = 'texte')      AS "cours",
  count(*) FILTER (WHERE k.type_contenu = 'quiz')       AS "quiz",
  count(*) FILTER (WHERE k.type_contenu = 'interactif') AS "simu",
  count(*) FILTER (WHERE k.type_contenu = 'figure')     AS "figures",
  count(*) FILTER (WHERE k.type_contenu = 'graphique')  AS "courbes",
  CASE
    WHEN c.niveau IS NULL THEN '>>> SANS MODULE'
    WHEN count(k.id) = 0 THEN '>>> CHAPITRE VIDE'
    WHEN count(*) FILTER (WHERE k.type_contenu = 'quiz') = 0 THEN '>>> SANS QUIZ'
    ELSE 'OK'
  END                                                   AS "verdict"
FROM public.chapitres c
JOIN public.programmes p ON p.id = c.programme_id
LEFT JOIN public.concepts k ON k.chapitre_id = c.id
WHERE p.titre = 'Mathématiques — 1ère C'
GROUP BY c.ordre, c.niveau, c.titre
ORDER BY c.ordre;
