-- ---------------------------------------------------------------------------
-- M'Andal — Philosophie, classes de Terminale C et D
-- Le contrôle à lancer une fois les treize chapitres chargés.
--
-- Il affiche six tableaux. Pour chacun, le commentaire juste au-dessus vous dit
-- ce que vous devez voir. Si ce que vous lisez ne correspond pas, quelque chose
-- s'est mal passé pendant le chargement, et il faut m'en parler.
-- ---------------------------------------------------------------------------


-- TABLEAU 1 — Les deux séries vues de haut
--
-- Vous devez voir deux lignes, une par série, avec exactement les mêmes
-- chiffres sur les deux : 13 chapitres, 121 leçons, 41 simulations, 13 quiz,
-- 13 figures.
-- Si une série a moins de chapitres que l'autre, c'est qu'un script s'est
-- arrêté en route et qu'il faut le relancer.

SELECT p.titre                                              AS programme,
       count(DISTINCT ch.id)                                AS chapitres,
       count(c.id)                                          AS lecons,
       count(*) FILTER (WHERE c.type_contenu = 'interactif') AS simulations,
       count(*) FILTER (WHERE c.type_contenu = 'quiz')       AS quiz,
       count(*) FILTER (WHERE c.type_contenu = 'figure')     AS figures
FROM public.programmes p
JOIN public.chapitres ch ON ch.programme_id = p.id
JOIN public.concepts  c  ON c.chapitre_id   = ch.id
WHERE p.titre LIKE 'Philosophie — Terminale%'
GROUP BY p.titre
ORDER BY p.titre;


-- TABLEAU 2 — Le module
--
-- Une seule ligne, et c'est normal : le programme officiel de Philosophie des
-- Terminales C et D ne comporte qu'un module, contrairement aux programmes
-- scientifiques.
--   Module 1 : La philosophie      13 chapitres, 242 leçons pour les deux séries

SELECT ch.niveau             AS module,
       count(DISTINCT ch.titre) AS chapitres,
       count(c.id)           AS lecons_les_deux_series
FROM public.programmes p
JOIN public.chapitres ch ON ch.programme_id = p.id
JOIN public.concepts  c  ON c.chapitre_id   = ch.id
WHERE p.titre LIKE 'Philosophie — Terminale%'
GROUP BY ch.niveau
ORDER BY ch.niveau;


-- TABLEAU 3 — Le détail des treize chapitres, pour la Terminale C
--
-- Treize lignes, dans l'ordre exact du programme officiel que vous m'avez
-- envoyé, et le total des leçons doit faire 121.
-- Les trois premiers chapitres ont huit questions de quiz au lieu de sept :
-- ce sont ceux de méthodologie, et j'ai préféré y ajouter une question.

SELECT ch.ordre                                              AS n,
       ch.titre                                              AS chapitre,
       count(c.id)                                           AS lecons,
       count(*) FILTER (WHERE c.type_contenu = 'texte')      AS textes,
       count(*) FILTER (WHERE c.type_contenu = 'interactif') AS simulations,
       count(*) FILTER (WHERE c.type_contenu = 'figure')     AS figures
FROM public.programmes p
JOIN public.chapitres ch ON ch.programme_id = p.id
JOIN public.concepts  c  ON c.chapitre_id   = ch.id
WHERE p.titre = 'Philosophie — Terminale C'
GROUP BY ch.ordre, ch.titre
ORDER BY ch.ordre;


-- TABLEAU 4 — Les leçons de cours restées sans simulation
--
-- Ce tableau doit être VIDE. C'est le plus important des six.
-- Il cherche les chapitres où le nombre de leçons de cours dépasse le nombre
-- de simulations. Les sujets type Baccalauréat sont exclus du compte : ils
-- n'ont pas de simulation, et c'est voulu.

SELECT ch.ordre AS n,
       ch.titre AS chapitre,
       count(*) FILTER (WHERE c.type_contenu = 'texte'
                        AND c.titre NOT LIKE 'Sujet type Baccalaur%') AS lecons_de_cours,
       count(*) FILTER (WHERE c.type_contenu = 'interactif')          AS simulations
FROM public.programmes p
JOIN public.chapitres ch ON ch.programme_id = p.id
JOIN public.concepts  c  ON c.chapitre_id   = ch.id
WHERE p.titre = 'Philosophie — Terminale C'
GROUP BY ch.ordre, ch.titre
HAVING count(*) FILTER (WHERE c.type_contenu = 'texte'
                        AND c.titre NOT LIKE 'Sujet type Baccalaur%')
     > count(*) FILTER (WHERE c.type_contenu = 'interactif')
ORDER BY ch.ordre;


-- TABLEAU 5 — La liste des quarante et une simulations
--
-- Quarante et une lignes, une par simulation, avec le chapitre où elle se
-- trouve. Servez-vous-en pour vérifier qu'une simulation s'affiche bien sur le
-- site avant de la montrer en classe.

SELECT ch.ordre                                       AS n,
       ch.titre                                       AS chapitre,
       (c.contenu_texte::jsonb) ->> 'widget'          AS simulation,
       c.titre                                        AS lecon
FROM public.programmes p
JOIN public.chapitres ch ON ch.programme_id = p.id
JOIN public.concepts  c  ON c.chapitre_id   = ch.id
WHERE p.titre = 'Philosophie — Terminale C'
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
WHERE p.titre LIKE 'Philosophie — Terminale%'
  AND (SELECT c2.type_contenu
         FROM public.concepts c2
        WHERE c2.chapitre_id = ch.id
        ORDER BY c2.ordre DESC
        LIMIT 1) <> 'quiz'
ORDER BY ch.ordre;
