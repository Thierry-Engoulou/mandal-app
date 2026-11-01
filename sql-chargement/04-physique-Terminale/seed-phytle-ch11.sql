-- ============================================================================
-- MANDAL — Physique Terminale : chapitre 11, Les condensateurs
-- Module 3 : Électricité, évolutions temporelles des circuits électriques
-- 4 leçons.
--
-- Ce fichier remplit LES DEUX CLASSES a la fois : Terminale C et Terminale D.
-- Autonome : il cree lui-meme la matiere, les classes, les programmes et le
-- chapitre s'ils n'existent pas encore. Lancez-le seul, dans n'importe quel
-- ordre.
-- Idempotent : si le chapitre contient deja des lecons, rien n'est ajoute.
-- ============================================================================
DO $ptc$
DECLARE
  v_noms text[] := ARRAY['Terminale C', 'Terminale D'];
  v_lettres text[] := ARRAY['C', 'D'];
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
  INSERT INTO public.matieres (nom) VALUES ('Physique') ON CONFLICT (nom) DO NOTHING;
  SELECT id INTO v_matiere_id FROM public.matieres WHERE nom = 'Physique';

  -- l'etablissement, deduit de la table des classes
  SELECT count(DISTINCT etablissement_id) INTO v_nb_etabs FROM public.classes;
  IF v_nb_etabs <> 1 THEN
    RAISE EXCEPTION 'Impossible de deduire l''etablissement : % etablissement(s) distinct(s) dans public.classes.', v_nb_etabs;
  END IF;
  SELECT etablissement_id INTO v_etab_id FROM public.classes LIMIT 1;

  -- on refait le meme travail pour la Terminale C puis pour la Terminale D
  FOR v_i IN 1..2 LOOP
    v_nom := v_noms[v_i];
    v_lettre := v_lettres[v_i];

    -- 1. le programme existe-t-il deja ?
    SELECT p.id INTO v_programme_id FROM public.programmes p
    WHERE p.titre = 'Physique — ' || v_nom;

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
      VALUES (v_matiere_id, v_classe_id, v_etab_id, 'Physique — ' || v_nom,
              'Programme officiel de Physique, classe de Terminale ' || v_lettre ||
              ' (Cameroun) — 4 modules, 22 chapitres.')
      RETURNING id INTO v_programme_id;
      RAISE NOTICE 'Programme "Physique — %" cree.', v_nom;
    END IF;

    -- 3. le chapitre existe-t-il deja ?
    SELECT id INTO v_chapitre_id FROM public.chapitres
    WHERE programme_id = v_programme_id AND ordre = 11;

    -- 4. sinon on le cree
    IF v_chapitre_id IS NULL THEN
      INSERT INTO public.chapitres (programme_id, titre, ordre, niveau)
      VALUES (v_programme_id, 'Les condensateurs', 11, 'Module 3 : Électricité, évolutions temporelles des circuits électriques')
      RETURNING id INTO v_chapitre_id;
      RAISE NOTICE '% : chapitre 11 cree.', v_nom;
    END IF;

    -- 5. les lecons
    SELECT count(*) INTO v_deja FROM public.concepts WHERE chapitre_id = v_chapitre_id;
    IF v_deja > 0 THEN
      RAISE NOTICE '% : chapitre 11 contient deja % lecon(s) — aucun ajout.', v_nom, v_deja;
      CONTINUE;
    END IF;

    INSERT INTO public.concepts
      (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes) VALUES
      (v_chapitre_id, 'Le condensateur et sa capacité', 1, 'texte', 'Un condensateur est un composant qui stocke des charges électriques. On le retrouve dans tous les appareils électroniques, du téléphone au poste de radio.

## De quoi il est fait

Un condensateur est formé de deux plaques conductrices, appelées **armatures**, séparées par un isolant appelé **diélectrique**. Cet isolant peut être de l''air, du papier, de la céramique ou un film plastique.

Les deux armatures ne se touchent jamais. Aucun courant ne traverse donc le condensateur en régime permanent.

Son symbole est deux traits parallèles, et il n''a pas de sens de branchement sauf pour les condensateurs électrochimiques, qui sont polarisés.

## La charge et la décharge

Branche un condensateur à un générateur à travers une résistance. Le générateur arrache des électrons à une armature et les pousse sur l''autre. Une armature se charge $+q$, l''autre $-q$.

Attention, la charge **totale** du condensateur reste nulle. Quand on parle de la charge $q$, on désigne toujours celle de l''armature positive.

Pendant ce transfert, un courant circule dans les fils, mais jamais à travers l''isolant. Ce courant s''arrête dès que le condensateur est chargé.

Si tu relies ensuite les deux armatures par une résistance, les charges reviennent : c''est la décharge, et le courant circule en sens inverse.

## La capacité

L''expérience montre que la charge est proportionnelle à la tension entre les armatures :
$$q = C\,u$$

Le coefficient $C$ est la **capacité** du condensateur. Son unité est le farad, symbole F.

Le farad est une unité énorme. Les condensateurs courants se comptent en microfarads ($1\ \mu\text{F} = 10^{-6}$ F), en nanofarads ($10^{-9}$ F) ou en picofarads ($10^{-12}$ F).

## La relation entre courant et tension

Le courant est le débit de charges, donc $i = \dfrac{dq}{dt}$. En dérivant $q = Cu$,
$$i = C\,\dfrac{du}{dt}$$

Cette relation est fondamentale. Elle dit que le courant n''existe que si la tension **varie**. En régime continu établi, $\dfrac{du}{dt} = 0$ et le courant est nul : le condensateur se comporte comme un interrupteur ouvert.

Elle dit aussi qu''un courant fini impose une tension **continue**. La tension aux bornes d''un condensateur ne peut jamais sauter brutalement. C''est une propriété qu''on utilise sans arrêt pour écrire les conditions initiales.

## Le condensateur plan

Pour deux armatures planes de surface $S$ en regard, séparées par une épaisseur $e$ de diélectrique,
$$C = \dfrac{\varepsilon\,S}{e} = \dfrac{\varepsilon_{0}\,\varepsilon_{r}\,S}{e}$$

La permittivité du vide vaut $\varepsilon_{0} = 8{,}85 \times 10^{-12}$ F/m, et $\varepsilon_{r}$ est la permittivité relative du diélectrique, un nombre sans dimension valant $1$ pour l''air, environ $5$ pour le mica et jusqu''à plusieurs milliers pour certaines céramiques.

Pour avoir une grande capacité, il faut donc de grandes armatures très rapprochées, avec un bon diélectrique. C''est pourquoi les condensateurs réels sont faits de longs rubans enroulés.

## Exercice d''application

Un condensateur plan a des armatures carrées de $10$ cm de côté séparées par $0{,}10$ mm d''air. Calcule sa capacité, puis la charge accumulée sous $12$ V.

Correction. La surface vaut $S = 0{,}10 \times 0{,}10 = 1{,}0 \times 10^{-2}$ m², et l''épaisseur $e = 1{,}0 \times 10^{-4}$ m.

Avec $\varepsilon_{r} = 1$ pour l''air,
$$C = \dfrac{8{,}85 \times 10^{-12} \times 1{,}0 \times 10^{-2}}{1{,}0 \times 10^{-4}} = 8{,}85 \times 10^{-10}\ \text{F}$$

Soit environ $0{,}89$ nF. Remarque comme c''est peu, pour des armatures de la taille d''une main.

La charge vaut
$$q = Cu = 8{,}85 \times 10^{-10} \times 12 \approx 1{,}1 \times 10^{-8}\ \text{C}$$

soit environ $11$ nanocoulombs.', NULL, 15),
      (v_chapitre_id, 'Énergie, associations et limites d''emploi', 2, 'texte', 'Un condensateur chargé contient de l''énergie, qu''il peut restituer très vite. C''est cette propriété qui le rend si utile, et parfois dangereux.

## L''énergie emmagasinée

L''énergie stockée par un condensateur portant la charge $q$ sous la tension $u$ vaut
$$W = \dfrac{1}{2}\,C\,u^{2} = \dfrac{1}{2}\,\dfrac{q^{2}}{C} = \dfrac{1}{2}\,q\,u$$

Les trois écritures sont équivalentes, choisis celle qui correspond aux données de l''exercice.

Cette énergie est stockée dans le **champ électrique** qui règne entre les armatures, pas dans les charges elles-mêmes.

Ce qui fait la force du condensateur, ce n''est pas la quantité d''énergie, souvent modeste, mais la **vitesse** à laquelle il peut la rendre. Un flash d''appareil photo vide son condensateur en un millième de seconde, ce qui donne une puissance instantanée énorme.

Attention, un gros condensateur reste chargé longtemps après l''extinction d''un appareil. Dans un téléviseur ou une alimentation, cela peut être mortel. On ne touche jamais les bornes sans l''avoir déchargé.

## La tension de service et la tension de rupture

Si la tension devient trop grande, le champ électrique dans l''isolant dépasse sa limite et une étincelle traverse le diélectrique. C''est le **claquage**, et il détruit le condensateur.

La **tension de rupture** $U_{r}$ est celle qui provoque le claquage. La **tension de service** $U_{s}$ est la tension maximale d''utilisation garantie par le constructeur, toujours nettement inférieure à $U_{r}$.

Sur le boîtier d''un condensateur, tu lis toujours deux nombres : sa capacité et sa tension de service. Ne dépasse jamais la seconde.

## La fuite

Aucun isolant n''est parfait. Un très faible courant traverse toujours le diélectrique, ce qui fait que le condensateur se décharge lentement tout seul. On modélise cela par une grande résistance en parallèle, dite résistance de fuite.

## L''association en parallèle

Deux condensateurs en parallèle ont la même tension à leurs bornes, et les charges s''ajoutent. Donc
$$C_{\text{éq}} = C_{1} + C_{2}$$

Mettre en parallèle, c''est comme élargir les armatures. La capacité augmente.

## L''association en série

Deux condensateurs en série portent la même charge, et les tensions s''ajoutent. Donc
$$\dfrac{1}{C_{\text{éq}}} = \dfrac{1}{C_{1}} + \dfrac{1}{C_{2}}$$

La capacité équivalente est plus petite que la plus petite des deux. En revanche, la tension se répartit, donc l''association supporte une tension plus élevée.

Retiens bien que c''est l''**inverse** des résistances. Pour les résistances, la série s''additionne. Pour les condensateurs, c''est le parallèle.

## Les applications

Le condensateur sert à **lisser** une tension après redressement, dans toutes les alimentations.

Il sert à **stocker** puis libérer brutalement de l''énergie, dans un flash ou un défibrillateur.

Il sert à **filtrer**, en laissant passer les signaux variables et en bloquant le continu.

Il sert à **temporiser**, car associé à une résistance il introduit un retard bien défini.

Il sert enfin dans les **oscillateurs**, associé à une bobine, comme tu le verras au chapitre suivant.

## Exercice d''application

On associe $C_{1} = 4{,}0\ \mu$F et $C_{2} = 6{,}0\ \mu$F. Calcule la capacité équivalente en parallèle puis en série. Dans le cas du parallèle sous $50$ V, calcule l''énergie totale stockée.

Correction. En parallèle,
$$C_{\text{éq}} = 4{,}0 + 6{,}0 = 10{,}0\ \mu\text{F}$$

En série,
$$\dfrac{1}{C_{\text{éq}}} = \dfrac{1}{4{,}0} + \dfrac{1}{6{,}0} = \dfrac{3 + 2}{12} = \dfrac{5}{12}$$

donc $C_{\text{éq}} = \dfrac{12}{5} = 2{,}4\ \mu$F. C''est bien inférieur à $4{,}0\ \mu$F.

L''énergie de l''association parallèle sous $50$ V vaut
$$W = \dfrac{1}{2}C_{\text{éq}}u^{2} = 0{,}5 \times 10{,}0 \times 10^{-6} \times 50^{2} = 0{,}5 \times 10^{-5} \times 2500 = 1{,}25 \times 10^{-2}\ \text{J}$$

soit environ $12{,}5$ millijoules. Peu d''énergie, mais libérée en une microseconde cela ferait $12{,}5$ kilowatts.', NULL, 15),
      (v_chapitre_id, 'Charge et décharge d''un condensateur', 3, 'interactif', '{
  "widget": "condensateur-charge",
  "consigne": "Lance la charge puis la décharge, et change la résistance et la capacité. Repère sur la courbe le temps au bout duquel la tension atteint 63 % de sa valeur finale. Compare-le au produit $RC$ : que remarques-tu ?"
}', NULL, 10),
      (v_chapitre_id, 'Quiz du chapitre 11', 4, 'quiz', '{
  "titre": "Vérifie que tu as compris",
  "questions": [
    {
      "question": "Un condensateur est branché à une pile depuis longtemps. Quel courant le traverse ?",
      "choix": [
        "Un courant constant non nul",
        "Aucun courant",
        "Un courant qui augmente",
        "Un courant alternatif"
      ],
      "bonne": 1,
      "explication": "Le courant vaut $i = C\\,du/dt$. En régime permanent la tension ne varie plus, donc $du/dt = 0$ et le courant est nul. Le condensateur se comporte alors comme un interrupteur ouvert."
    },
    {
      "question": "On double la tension aux bornes d''un condensateur. Que devient l''énergie stockée ?",
      "choix": [
        "Elle double",
        "Elle est multipliée par 4",
        "Elle reste la même",
        "Elle est divisée par 2"
      ],
      "bonne": 1,
      "explication": "L''énergie vaut $W = \\frac{1}{2}Cu^2$, elle varie comme le carré de la tension. En doublant $u$, on multiplie l''énergie par 4."
    },
    {
      "question": "Comment calcule-t-on la capacité équivalente de deux condensateurs en parallèle ?",
      "choix": [
        "En additionnant les capacités",
        "En additionnant les inverses des capacités",
        "En multipliant les capacités",
        "En prenant la plus petite"
      ],
      "bonne": 0,
      "explication": "En parallèle, les capacités s''additionnent : $C_{eq} = C_1 + C_2$. C''est l''inverse de ce qui se passe pour les résistances, où ce sont les valeurs en série qui s''additionnent."
    },
    {
      "question": "Que se passe-t-il si on dépasse la tension de rupture d''un condensateur ?",
      "choix": [
        "Il se charge plus vite",
        "Sa capacité augmente",
        "L''isolant claque et le condensateur est détruit",
        "Il se décharge tout seul"
      ],
      "bonne": 2,
      "explication": "Au-delà de la tension de rupture, le champ électrique est trop intense pour le diélectrique. Une étincelle le traverse, il est percé, et le condensateur est définitivement hors d''usage."
    },
    {
      "question": "Pourquoi la tension aux bornes d''un condensateur ne peut-elle pas varier brutalement ?",
      "choix": [
        "Parce que la charge est toujours nulle",
        "Parce qu''il faudrait un courant infini",
        "Parce que l''isolant l''empêche",
        "Parce que la capacité varie"
      ],
      "bonne": 1,
      "explication": "Comme $i = C\\,du/dt$, un saut de tension donnerait une dérivée infinie, donc un courant infini, ce qui est physiquement impossible. La tension d''un condensateur est donc toujours une fonction continue du temps."
    }
  ]
}', NULL, 5);

    RAISE NOTICE '% : chapitre 11, Les condensateurs — 4 lecons ajoutees.', v_nom;
  END LOOP;
END $ptc$;
