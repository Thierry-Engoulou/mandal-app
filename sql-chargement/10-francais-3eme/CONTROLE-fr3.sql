-- ---------------------------------------------------------------------------
-- M'Andal — Français, classe de 3ème
-- Le contrôle à lancer après chaque module chargé.
--
-- Ce fichier s'adapte : il affiche ce qui est en base au moment où vous le
-- lancez. Vous pouvez donc le relancer après chaque livraison, et voir le
-- programme se remplir module après module.
--
-- Il affiche six tableaux. Pour chacun, le commentaire juste au-dessus vous
-- dit ce que vous devez voir.
-- ---------------------------------------------------------------------------


-- TABLEAU 1 — Le programme vu de haut
--
-- Une seule ligne, puisqu'il n'y a qu'une classe. Les chiffres grandissent à
-- chaque module chargé :
--
--   après le module 1    8 chapitres,  66 leçons, 24 simulations,  8 quiz
--   après le module 2   16 chapitres, …
--   programme complet   40 chapitres

SELECT p.titre                                               AS programme,
       count(DISTINCT ch.id)                                 AS chapitres,
       count(c.id)                                           AS lecons,
       count(*) FILTER (WHERE c.type_contenu = 'interactif') AS simulations,
       count(*) FILTER (WHERE c.type_contenu = 'quiz')       AS quiz,
       count(*) FILTER (WHERE c.type_contenu = 'figure')     AS figures,
       sum(c.duree_minutes) / 60                             AS heures
FROM public.programmes p
JOIN public.chapitres ch ON ch.programme_id = p.id
JOIN public.concepts  c  ON c.chapitre_id   = ch.id
WHERE p.titre = 'Français — 3ème'
GROUP BY p.titre;


-- TABLEAU 2 — Les modules chargés
--
-- Une ligne par module livré, dans l'ordre du programme officiel, et chacun
-- doit compter 8 chapitres :
--
--   Module 1 : La vie familiale et socioculturelle
--   Module 2 : Citoyenneté et environnement
--   Module 3 : La vie économique
--   Module 4 : Bien-être et santé
--   Module 5 : Médias et communication

SELECT ch.niveau             AS module,
       count(DISTINCT ch.id) AS chapitres,
       count(c.id)           AS lecons,
       sum(c.duree_minutes) / 60 AS heures
FROM public.programmes p
JOIN public.chapitres ch ON ch.programme_id = p.id
JOIN public.concepts  c  ON c.chapitre_id   = ch.id
WHERE p.titre = 'Français — 3ème'
GROUP BY ch.niveau
ORDER BY ch.niveau;


-- TABLEAU 3 — Le détail, chapitre par chapitre
--
-- Une ligne par chapitre, dans l'ordre. Chaque chapitre compte en général
-- 3 leçons de cours, 3 simulations, 1 figure et 1 quiz, soit 8 leçons.
-- Les chapitres qui portent un sujet type BEPC en comptent une de plus.

SELECT ch.ordre                                              AS n,
       ch.titre                                              AS chapitre,
       count(c.id)                                           AS lecons,
       count(*) FILTER (WHERE c.type_contenu = 'texte')      AS textes,
       count(*) FILTER (WHERE c.type_contenu = 'interactif') AS simulations,
       count(*) FILTER (WHERE c.type_contenu = 'figure')     AS figures
FROM public.programmes p
JOIN public.chapitres ch ON ch.programme_id = p.id
JOIN public.concepts  c  ON c.chapitre_id   = ch.id
WHERE p.titre = 'Français — 3ème'
GROUP BY ch.ordre, ch.titre
ORDER BY ch.ordre;


-- TABLEAU 4 — Les leçons de cours restées sans simulation
--
-- Ce tableau doit être VIDE. C'est le plus important des six.
-- Les sujets type BEPC sont exclus du compte : ils n'ont pas de simulation,
-- et c'est voulu.

SELECT ch.ordre AS n,
       ch.titre AS chapitre,
       count(*) FILTER (WHERE c.type_contenu = 'texte'
                        AND c.titre NOT LIKE 'Sujet type BEPC%') AS lecons_de_cours,
       count(*) FILTER (WHERE c.type_contenu = 'interactif')     AS simulations
FROM public.programmes p
JOIN public.chapitres ch ON ch.programme_id = p.id
JOIN public.concepts  c  ON c.chapitre_id   = ch.id
WHERE p.titre = 'Français — 3ème'
GROUP BY ch.ordre, ch.titre
HAVING count(*) FILTER (WHERE c.type_contenu = 'texte'
                        AND c.titre NOT LIKE 'Sujet type BEPC%')
     > count(*) FILTER (WHERE c.type_contenu = 'interactif')
ORDER BY ch.ordre;


-- TABLEAU 5 — La liste des simulations
--
-- Une ligne par simulation, avec le chapitre où elle se trouve. Servez-vous-en
-- pour vérifier qu'une simulation s'affiche bien sur le site avant de la
-- montrer en classe.

SELECT ch.ordre                              AS n,
       ch.titre                              AS chapitre,
       (c.contenu_texte::jsonb) ->> 'widget' AS simulation,
       c.titre                               AS lecon
FROM public.programmes p
JOIN public.chapitres ch ON ch.programme_id = p.id
JOIN public.concepts  c  ON c.chapitre_id   = ch.id
WHERE p.titre = 'Français — 3ème'
  AND c.type_contenu = 'interactif'
ORDER BY ch.ordre, c.ordre;


-- TABLEAU 6 — Les chapitres qui ne finiraient pas par leur quiz
--
-- Ce tableau doit être VIDE lui aussi.
-- La convention du site est que le quiz ferme toujours le chapitre : s'il
-- apparaît ici, c'est que l'ordre des leçons a été dérangé.

SELECT ch.ordre AS n,
       ch.titre AS chapitre,
       (SELECT c2.type_contenu
          FROM public.concepts c2
         WHERE c2.chapitre_id = ch.id
         ORDER BY c2.ordre DESC
         LIMIT 1) AS derniere_lecon
FROM public.programmes p
JOIN public.chapitres ch ON ch.programme_id = p.id
WHERE p.titre = 'Français — 3ème'
  AND (SELECT c2.type_contenu
         FROM public.concepts c2
        WHERE c2.chapitre_id = ch.id
        ORDER BY c2.ordre DESC
        LIMIT 1) <> 'quiz'
ORDER BY ch.ordre;
