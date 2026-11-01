-- ============================================================================
-- MANDAL — Contrôle du programme Chimie Terminale (C, D et E)
--
-- Ne modifie RIEN. Affiche 51 lignes : 17 chapitres pour chacune des trois
-- séries.
-- La dernière colonne doit afficher OK partout.
-- ============================================================================

SELECT
  right(p.titre, 1)                                     AS "série",
  c.ordre                                               AS "n°",
  left(coalesce(c.niveau, 'SANS MODULE'), 10)           AS "module",
  left(c.titre, 38)                                     AS "chapitre",
  count(k.id)                                           AS "leçons",
  count(*) FILTER (WHERE k.type_contenu = 'texte')      AS "cours",
  count(*) FILTER (WHERE k.type_contenu = 'quiz')       AS "quiz",
  count(*) FILTER (WHERE k.type_contenu = 'interactif') AS "simu",
  CASE
    WHEN c.niveau IS NULL THEN '>>> SANS MODULE'
    WHEN count(k.id) = 0 THEN '>>> CHAPITRE VIDE'
    WHEN count(*) FILTER (WHERE k.type_contenu = 'quiz') = 0 THEN '>>> SANS QUIZ'
    ELSE 'OK'
  END                                                   AS "verdict"
FROM public.chapitres c
JOIN public.programmes p ON p.id = c.programme_id
LEFT JOIN public.concepts k ON k.chapitre_id = c.id
WHERE p.titre IN ('Chimie — Terminale C', 'Chimie — Terminale D', 'Chimie — Terminale E')
GROUP BY p.titre, c.ordre, c.niveau, c.titre
ORDER BY p.titre, c.ordre;
