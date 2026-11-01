-- ============================================================================
-- MANDAL — Chimie Terminale : chapitre 15, Nombres d''oxydation et voie sèche
-- Module 4 : Oxydoréduction
-- 3 leçons.
--
-- Ce fichier remplit LES TROIS CLASSES a la fois : Terminale C, D et E.
-- Autonome : il cree lui-meme la matiere, les classes, les programmes et le
-- chapitre s'ils n'existent pas encore. Lancez-le seul, dans n'importe quel
-- ordre.
-- Idempotent : si le chapitre contient deja des lecons, rien n'est ajoute.
-- ============================================================================
DO $chi$
DECLARE
  v_lettres text[] := ARRAY['C', 'D', 'E'];
  v_i int;
  v_nom text;
  v_lettre text;
  v_matiere_id uuid;
  v_classe_id uuid;
  v_etab_id uuid;
  v_programme_id uuid;
  v_chapitre_id uuid;
  v_nb_etabs int;
  v_deja int;
BEGIN
  -- la matiere, une seule fois
  INSERT INTO public.matieres (nom) VALUES ('Chimie') ON CONFLICT (nom) DO NOTHING;
  SELECT id INTO v_matiere_id FROM public.matieres WHERE nom = 'Chimie';

  -- l'etablissement, deduit de la table des classes
  SELECT count(DISTINCT etablissement_id) INTO v_nb_etabs FROM public.classes;
  IF v_nb_etabs <> 1 THEN
    RAISE EXCEPTION 'Impossible de deduire l''etablissement : % etablissement(s) distinct(s) dans public.classes.', v_nb_etabs;
  END IF;
  SELECT etablissement_id INTO v_etab_id FROM public.classes LIMIT 1;

  -- on refait le meme travail pour la Terminale C, puis la D, puis la E
  FOR v_i IN 1..3 LOOP
    v_lettre := v_lettres[v_i];
    v_nom := 'Terminale ' || v_lettre;

    -- 1. le programme existe-t-il deja ?
    SELECT p.id INTO v_programme_id FROM public.programmes p
    WHERE p.titre = 'Chimie — ' || v_nom;

    -- 2. sinon on le cree
    IF v_programme_id IS NULL THEN
      -- la classe, quelle que soit la facon dont elle a ete ecrite
      SELECT id INTO v_classe_id FROM public.classes
      WHERE etablissement_id = v_etab_id
        AND (nom = v_nom OR nom ILIKE 'T%le ' || v_lettre)
      ORDER BY (nom = v_nom) DESC
      LIMIT 1;

      -- si elle n'existe pas, on la cree
      IF v_classe_id IS NULL THEN
        INSERT INTO public.classes (etablissement_id, nom, niveau, filiere)
        VALUES (v_etab_id, v_nom, 'Terminale', v_lettre)
        RETURNING id INTO v_classe_id;
        RAISE NOTICE 'Classe "%" creee.', v_nom;
      END IF;

      INSERT INTO public.programmes (matiere_id, classe_id, etablissement_id, titre, description)
      VALUES (v_matiere_id, v_classe_id, v_etab_id, 'Chimie — ' || v_nom,
              'Programme officiel de Chimie, classe de Terminale ' || v_lettre ||
              ' (Cameroun) — 4 modules, 17 chapitres.')
      RETURNING id INTO v_programme_id;
      RAISE NOTICE 'Programme "Chimie — %" cree.', v_nom;
    END IF;

    -- 3. le chapitre existe-t-il deja ?
    SELECT id INTO v_chapitre_id FROM public.chapitres
    WHERE programme_id = v_programme_id AND ordre = 15;

    -- 4. sinon on le cree
    IF v_chapitre_id IS NULL THEN
      INSERT INTO public.chapitres (programme_id, titre, ordre, niveau)
      VALUES (v_programme_id, 'Nombres d''oxydation et voie sèche', 15, 'Module 4 : Oxydoréduction')
      RETURNING id INTO v_chapitre_id;
      RAISE NOTICE '% : chapitre 15 cree.', v_nom;
    END IF;

    -- 5. les lecons
    SELECT count(*) INTO v_deja FROM public.concepts WHERE chapitre_id = v_chapitre_id;
    IF v_deja > 0 THEN
      RAISE NOTICE '% : chapitre 15 contient deja % lecon(s) — aucun ajout.', v_nom, v_deja;
      CONTINUE;
    END IF;

    INSERT INTO public.concepts
      (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes) VALUES
      (v_chapitre_id, 'Le nombre d''oxydation', 1, 'texte', 'Pour les composés moléculaires, la notion d''électrons cédés devient floue : dans $\text{H}_{2}\text{O}$, personne n''a vraiment donné d''électron à personne. Le nombre d''oxydation résout ce problème.

## L''idée

Le **nombre d''oxydation**, noté $n.o.$ et écrit en chiffres romains, est la charge **fictive** qu''aurait un atome si toutes les liaisons de la molécule étaient ioniques, les électrons allant entièrement à l''atome le plus électronégatif.

C''est une convention de comptage, pas une charge réelle. Mais elle marche partout, y compris là où la notion d''ion n''a pas de sens.

## Les six règles de calcul

Un **corps simple** a toujours un $n.o.$ nul. Ainsi $\text{Fe}$, $\text{O}_{2}$, $\text{H}_{2}$, $\text{Cl}_{2}$ ont tous un $n.o.$ de $0$.

Un **ion monoatomique** a un $n.o.$ égal à sa charge. Ainsi $\text{Na}^{+}$ vaut $+\text{I}$, $\text{Cl}^{-}$ vaut $-\text{I}$, $\text{Fe}^{3+}$ vaut $+\text{III}$.

L''**hydrogène** vaut $+\text{I}$ dans ses composés, sauf dans les hydrures métalliques où il vaut $-\text{I}$.

L''**oxygène** vaut $-\text{II}$, sauf dans les peroxydes comme $\text{H}_{2}\text{O}_{2}$ où il vaut $-\text{I}$.

Dans une **molécule neutre**, la somme des $n.o.$ est nulle.

Dans un **ion polyatomique**, la somme des $n.o.$ vaut la charge de l''ion.

Ces deux dernières règles sont celles qu''on utilise pour calculer un $n.o.$ inconnu.

## Deux exemples de calcul

Cherchons le $n.o.$ du manganèse dans $\text{MnO}_{4}^{-}$. Les quatre oxygènes apportent $4 \times (-2) = -8$. La somme doit valoir $-1$, la charge de l''ion. Donc
$$x + (-8) = -1 \qquad \text{d''où} \qquad x = +7$$

Le manganèse est au degré $+\text{VII}$, son maximum.

Cherchons celui du chrome dans $\text{Cr}_{2}\text{O}_{7}^{2-}$. Les sept oxygènes apportent $-14$, et il y a **deux** chromes. Donc
$$2x - 14 = -2 \qquad \text{d''où} \qquad 2x = 12 \quad \text{et} \quad x = +6$$

Chaque chrome est au degré $+\text{VI}$.

## Le critère d''oxydoréduction

Voici tout l''intérêt de l''outil.

Une **oxydation** est une **augmentation** du nombre d''oxydation.

Une **réduction** est une **diminution** du nombre d''oxydation.

Une réaction est une réaction d''oxydoréduction **si et seulement si** au moins un élément change de nombre d''oxydation.

Ce critère est infaillible, et il marche même sans eau, sans ions, sans solution.

## Reconnaître une réaction rédox

Teste la combustion du méthane :
$$\text{CH}_{4} + 2\,\text{O}_{2} \longrightarrow \text{CO}_{2} + 2\,\text{H}_{2}\text{O}$$

Dans $\text{CH}_{4}$, l''hydrogène vaut $+\text{I}$, donc le carbone vaut $-\text{IV}$. Dans $\text{CO}_{2}$, l''oxygène vaut $-\text{II}$, donc le carbone vaut $+\text{IV}$.

Le carbone passe de $-\text{IV}$ à $+\text{IV}$ : il est **oxydé**. L''oxygène passe de $0$ à $-\text{II}$ : il est **réduit**. C''est bien une réaction d''oxydoréduction.

Teste maintenant la neutralisation :
$$\text{HCl} + \text{NaOH} \longrightarrow \text{NaCl} + \text{H}_{2}\text{O}$$

Le chlore reste à $-\text{I}$, le sodium à $+\text{I}$, l''hydrogène à $+\text{I}$, l''oxygène à $-\text{II}$. Aucun changement : ce n''est **pas** une réaction rédox, mais une réaction acide-base.

## Les réactions par voie sèche

Beaucoup de réactions rédox importantes se font sans solvant, à haute température. Le nombre d''oxydation est alors le seul outil utilisable.

La **métallurgie** du fer en est l''exemple industriel majeur :
$$\text{Fe}_{2}\text{O}_{3} + 3\,\text{CO} \longrightarrow 2\,\text{Fe} + 3\,\text{CO}_{2}$$

Le fer passe de $+\text{III}$ à $0$, il est réduit. Le carbone passe de $+\text{II}$ à $+\text{IV}$, il est oxydé.

La **thermite**, utilisée pour souder les rails, est du même genre :
$$2\,\text{Al} + \text{Fe}_{2}\text{O}_{3} \longrightarrow \text{Al}_{2}\text{O}_{3} + 2\,\text{Fe}$$

Elle dégage tellement de chaleur que le fer formé est liquide.

## Exercice d''application

Détermine le nombre d''oxydation du soufre dans $\text{H}_{2}\text{S}$, dans $\text{SO}_{2}$ et dans $\text{H}_{2}\text{SO}_{4}$. La réaction $2\,\text{H}_{2}\text{S} + \text{SO}_{2} \longrightarrow 3\,\text{S} + 2\,\text{H}_{2}\text{O}$ est-elle une réaction d''oxydoréduction ?

Correction. Dans $\text{H}_{2}\text{S}$, les deux hydrogènes apportent $+2$ et la molécule est neutre, donc
$$x + 2 = 0 \qquad \text{d''où} \qquad x = -\text{II}$$

Dans $\text{SO}_{2}$, les deux oxygènes apportent $-4$, donc
$$x - 4 = 0 \qquad \text{d''où} \qquad x = +\text{IV}$$

Dans $\text{H}_{2}\text{SO}_{4}$, les deux hydrogènes apportent $+2$ et les quatre oxygènes $-8$, donc
$$2 + x - 8 = 0 \qquad \text{d''où} \qquad x = +\text{VI}$$

Pour la réaction, regardons le soufre de chaque côté. Dans $\text{H}_{2}\text{S}$ il vaut $-\text{II}$, dans $\text{SO}_{2}$ il vaut $+\text{IV}$, et dans le soufre solide $\text{S}$, corps simple, il vaut $0$.

Le soufre de $\text{H}_{2}\text{S}$ passe de $-\text{II}$ à $0$ : il est **oxydé**. Celui de $\text{SO}_{2}$ passe de $+\text{IV}$ à $0$ : il est **réduit**.

C''est donc bien une réaction d''oxydoréduction, et même un cas particulier intéressant : le même élément, le soufre, joue à la fois l''oxydant et le réducteur. On appelle cela une **médiamutation**.

Remarque pratique : cette réaction se produit autour des volcans, et c''est elle qui dépose le soufre jaune sur leurs flancs.', NULL, 15),
      (v_chapitre_id, 'Calcule un nombre d''oxydation', 2, 'interactif', '{
  "widget": "nombre-oxydation",
  "consigne": "Choisis une espèce chimique et laisse la machine détailler le calcul du nombre d''oxydation. Compare le manganèse dans $\\text{MnO}_4^-$ et dans $\\text{Mn}^{2+}$. Teste ensuite une réaction : change-t-elle un nombre d''oxydation ? Si non, ce n''est pas une réaction rédox."
}', NULL, 10),
      (v_chapitre_id, 'Quiz du chapitre 15', 3, 'quiz', '{
  "titre": "Vérifie que tu as compris",
  "questions": [
    {
      "question": "Quel est le nombre d''oxydation du chrome dans $\\text{Cr}_2\\text{O}_7^{2-}$ ?",
      "choix": [
        "+III",
        "+VI",
        "+VII",
        "−II"
      ],
      "bonne": 1,
      "explication": "Les sept oxygènes apportent $-14$ et la charge totale vaut $-2$, donc $2x - 14 = -2$, d''où $x = +6$. Attention à ne pas oublier qu''il y a deux atomes de chrome."
    },
    {
      "question": "Que vaut le nombre d''oxydation d''un corps simple comme $\\text{O}_2$ ou $\\text{Fe}$ ?",
      "choix": [
        "+I",
        "−II",
        "0",
        "Cela dépend"
      ],
      "bonne": 2,
      "explication": "Dans un corps simple, tous les atomes sont identiques, donc aucun n''attire les électrons plus que l''autre. Le nombre d''oxydation est nul par convention."
    },
    {
      "question": "Une oxydation correspond à :",
      "choix": [
        "une diminution du nombre d''oxydation",
        "une augmentation du nombre d''oxydation",
        "un nombre d''oxydation nul",
        "un gain de protons"
      ],
      "bonne": 1,
      "explication": "Oxyder, c''est perdre des électrons, donc devenir plus positif. Le nombre d''oxydation augmente. La réduction fait l''inverse."
    },
    {
      "question": "La réaction $\\text{HCl} + \\text{NaOH} \\rightarrow \\text{NaCl} + \\text{H}_2\\text{O}$ est-elle une réaction rédox ?",
      "choix": [
        "Oui",
        "Non, aucun nombre d''oxydation ne change",
        "Oui, l''hydrogène change",
        "Seulement à chaud"
      ],
      "bonne": 1,
      "explication": "Le chlore reste à −I, le sodium à +I, l''hydrogène à +I et l''oxygène à −II de part et d''autre. Sans changement de nombre d''oxydation, il n''y a pas d''oxydoréduction : c''est une réaction acide-base."
    },
    {
      "question": "Dans la réaction $\\text{Fe}_2\\text{O}_3 + 3\\text{CO} \\rightarrow 2\\text{Fe} + 3\\text{CO}_2$, que subit le fer ?",
      "choix": [
        "Il est oxydé",
        "Il est réduit",
        "Il ne change pas",
        "Il devient un ion"
      ],
      "bonne": 1,
      "explication": "Le fer passe du degré +III dans l''oxyde au degré 0 dans le métal. Son nombre d''oxydation diminue, donc il est réduit. C''est le principe du haut fourneau."
    }
  ]
}', NULL, 5);

    RAISE NOTICE '% : chapitre 15, Nombres d''oxydation et voie sèche — 3 lecons ajoutees.', v_nom;
  END LOOP;
END $chi$;
