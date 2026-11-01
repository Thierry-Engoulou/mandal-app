-- ============================================================================
-- MANDAL — Physique Terminale : chapitre 3, Forces et champs gravitationnels
-- Module 2 : Mouvements et interactions, évolutions temporelles des systèmes mécaniques
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
    WHERE programme_id = v_programme_id AND ordre = 3;

    -- 4. sinon on le cree
    IF v_chapitre_id IS NULL THEN
      INSERT INTO public.chapitres (programme_id, titre, ordre, niveau)
      VALUES (v_programme_id, 'Forces et champs gravitationnels', 3, 'Module 2 : Mouvements et interactions, évolutions temporelles des systèmes mécaniques')
      RETURNING id INTO v_chapitre_id;
      RAISE NOTICE '% : chapitre 3 cree.', v_nom;
    END IF;

    -- 5. les lecons
    SELECT count(*) INTO v_deja FROM public.concepts WHERE chapitre_id = v_chapitre_id;
    IF v_deja > 0 THEN
      RAISE NOTICE '% : chapitre 3 contient deja % lecon(s) — aucun ajout.', v_nom, v_deja;
      CONTINUE;
    END IF;

    INSERT INTO public.concepts
      (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes) VALUES
      (v_chapitre_id, 'La loi d''attraction universelle', 1, 'texte', 'Deux corps qui ont une masse s''attirent. Toujours. Que ce soit la Terre et la Lune, ou toi et ta chaise. Newton a trouvé la loi qui donne cette force en 1687, et elle n''a pas bougé depuis.

## L''énoncé

Deux corps ponctuels $A$ et $B$, de masses $m_{A}$ et $m_{B}$, séparés d''une distance $r$, s''attirent avec une force de valeur
$$F = \mathcal{G}\,\dfrac{m_{A}\,m_{B}}{r^{2}}$$

La constante $\mathcal{G}$ est la constante de gravitation universelle. Elle vaut
$$\mathcal{G} = 6{,}67 \times 10^{-11}\ \text{N}\cdot\text{m}^{2}\cdot\text{kg}^{-2}$$

Elle est la même partout dans l''univers, d''où le mot universelle.

## Pourquoi on ne sent pas cette force entre objets courants

Regarde la valeur de $\mathcal{G}$. Elle est minuscule. Prends deux personnes de $70$ kg assises à $1$ m l''une de l''autre. La force vaut
$$F = 6{,}67 \times 10^{-11} \times \dfrac{70 \times 70}{1^{2}} \approx 3{,}3 \times 10^{-7}\ \text{N}$$

C''est moins que le poids d''un grain de sable. Voilà pourquoi tu ne te sens pas attiré par ton voisin de table.

La gravitation ne devient sensible que lorsqu''une des deux masses est énorme, comme celle d''une planète.

## L''écriture vectorielle

La force est dirigée selon la droite qui joint les deux corps, et elle est toujours attractive.

Si $\vec{u}_{AB}$ est le vecteur unitaire qui va de $A$ vers $B$, la force exercée par $A$ sur $B$ s''écrit
$$\vec{F}_{A/B} = -\mathcal{G}\,\dfrac{m_{A}\,m_{B}}{r^{2}}\,\vec{u}_{AB}$$

Le signe moins traduit l''attraction : la force sur $B$ pointe vers $A$, donc dans le sens opposé à $\vec{u}_{AB}$.

D''après la troisième loi de Newton, $\vec{F}_{B/A} = -\vec{F}_{A/B}$. Les deux forces ont la même valeur, même si les masses sont très différentes. La Terre attire la pomme exactement autant que la pomme attire la Terre.

## Le cas des corps à répartition sphérique

La loi est écrite pour des corps ponctuels. Heureusement, on démontre qu''un corps dont la masse est répartie de façon sphérique se comporte, vu de l''extérieur, comme si toute sa masse était concentrée en son centre.

C''est ce qui permet d''appliquer la formule à la Terre et à la Lune, en prenant pour $r$ la distance entre leurs centres, et non entre leurs surfaces. C''est une erreur classique à l''examen.

## Exercice d''application

La Terre a une masse $M_{T} = 5{,}97 \times 10^{24}$ kg et un rayon $R_{T} = 6{,}38 \times 10^{6}$ m. Calcule la force qu''elle exerce sur un élève de $60$ kg debout à sa surface. Compare au poids que tu calculerais avec $P = mg$ et $g = 9{,}8$ N/kg.

Correction. L''élève est à la surface, donc la distance au centre de la Terre vaut $R_{T}$.
$$F = 6{,}67 \times 10^{-11} \times \dfrac{5{,}97 \times 10^{24} \times 60}{(6{,}38 \times 10^{6})^{2}}$$

Le numérateur vaut $6{,}67 \times 10^{-11} \times 3{,}582 \times 10^{26} = 2{,}389 \times 10^{16}$.

Le dénominateur vaut $(6{,}38 \times 10^{6})^{2} = 4{,}07 \times 10^{13}$.

Donc $F = \dfrac{2{,}389 \times 10^{16}}{4{,}07 \times 10^{13}} \approx 587$ N.

Avec $P = mg$, on trouve $60 \times 9{,}8 = 588$ N.

Les deux résultats sont les mêmes. C''est normal, le poids n''est rien d''autre que la force de gravitation exercée par la Terre, à la rotation de la Terre près.', NULL, 15),
      (v_chapitre_id, 'Le champ de gravitation', 2, 'texte', 'Dire que la Terre attire la Lune à travers $384\,000$ km de vide pose une question gênante : comment la force se transmet-elle ? La notion de champ répond à cette question.

## L''idée du champ

On arrête de penser que la Terre agit directement sur la Lune. On dit plutôt que la Terre modifie l''espace autour d''elle, et que la Lune réagit à l''espace là où elle se trouve.

Cette propriété de l''espace, c''est le **champ de gravitation**.

## La définition

En un point $M$ de l''espace, le champ de gravitation $\vec{\mathcal{G}}$ créé par un corps de masse $M_{A}$ est tel que la force subie par un corps de masse $m$ placé en $M$ vaut
$$\vec{F} = m\,\vec{\mathcal{G}}$$

Autrement dit, le champ est la force par unité de masse.
$$\vec{\mathcal{G}} = \dfrac{\vec{F}}{m}$$

Son unité est le newton par kilogramme, noté N/kg. On peut aussi l''exprimer en m/s², puisque c''est dimensionnellement une accélération.

## L''expression du champ

En combinant avec la loi de Newton, le champ créé à la distance $r$ par une masse $M_{A}$ vaut
$$\mathcal{G} = \dfrac{\mathcal{G}_{0}\,M_{A}}{r^{2}}$$
où $\mathcal{G}_{0} = 6{,}67 \times 10^{-11}$ est la constante de gravitation.

Remarque un point essentiel. Le champ ne dépend que de la masse qui le crée et de la distance. Il ne dépend pas de la masse qu''on y place. C''est une propriété de l''espace, pas de l''objet qu''on y met.

## Les lignes de champ

Une **ligne de champ** est une courbe tangente en chacun de ses points au vecteur champ.

Pour un corps sphérique isolé, les lignes de champ sont des droites qui convergent vers le centre du corps. On dit que le champ est **radial** et **centripète**.

Là où les lignes se resserrent, le champ est intense. Là où elles s''écartent, il est faible. C''est pour cela que le champ diminue quand on s''éloigne.

## Le champ de gravitation terrestre

À l''altitude $h$ au-dessus du sol, la distance au centre vaut $R_{T} + h$, donc
$$\mathcal{G}(h) = \dfrac{\mathcal{G}_{0}\,M_{T}}{(R_{T} + h)^{2}}$$

Au sol, $h = 0$ et on retrouve $\mathcal{G}_{0}M_{T}/R_{T}^{2} \approx 9{,}8$ N/kg.

On peut écrire une relation pratique entre les deux :
$$\mathcal{G}(h) = \mathcal{G}_{\text{sol}}\,\dfrac{R_{T}^{2}}{(R_{T} + h)^{2}}$$

## Champ de pesanteur et champ de gravitation

Dans la vie courante on parle du champ de pesanteur $\vec{g}$, celui qui donne le poids $\vec{P} = m\vec{g}$.

Il est presque égal au champ de gravitation, mais pas tout à fait. La Terre tourne sur elle-même, et cette rotation retranche une petite contribution centrifuge. L''écart est d''environ $0{,}3\%$ à l''équateur et nul aux pôles.

En Terminale, sauf mention contraire, on confond les deux et on écrit $g = 9{,}8$ N/kg.

## Exercice d''application

Un satellite évolue à $h = 800$ km d''altitude. Calcule le champ de gravitation à cette altitude. On donne $g_{\text{sol}} = 9{,}8$ N/kg et $R_{T} = 6\,380$ km.

Correction. On applique la relation
$$\mathcal{G}(h) = g_{\text{sol}}\,\dfrac{R_{T}^{2}}{(R_{T} + h)^{2}} = 9{,}8 \times \dfrac{6380^{2}}{(6380 + 800)^{2}}$$

Le rapport vaut $\left(\dfrac{6380}{7180}\right)^{2} = (0{,}8886)^{2} = 0{,}7896$.

Donc $\mathcal{G}(800\ \text{km}) = 9{,}8 \times 0{,}7896 \approx 7{,}7$ N/kg.

Le champ a baissé de $21\%$ seulement, alors que le satellite est à $800$ km. On comprend pourquoi les astronautes en orbite ne sont pas du tout hors de portée de la gravité terrestre. S''ils flottent, c''est parce qu''ils sont en chute libre permanente, pas parce que le champ aurait disparu.', NULL, 15),
      (v_chapitre_id, 'Promène une masse dans un champ de gravitation', 3, 'interactif', '{
  "widget": "champ-gravitation",
  "consigne": "Déplace la petite masse autour de la planète et observe le vecteur champ. Change la masse de la planète. À quelle distance faut-il aller pour que le champ soit divisé par 4 ? Vérifie que ta réponse est cohérente avec le $r^{2}$ de la formule."
}', NULL, 10),
      (v_chapitre_id, 'Quiz du chapitre 3', 4, 'quiz', '{
  "titre": "Vérifie que tu as compris",
  "questions": [
    {
      "question": "On double la distance entre deux corps. Que devient la force de gravitation entre eux ?",
      "choix": [
        "Elle est divisée par 2",
        "Elle est divisée par 4",
        "Elle est multipliée par 2",
        "Elle ne change pas"
      ],
      "bonne": 1,
      "explication": "La force varie en $1/r^2$. Si $r$ double, le dénominateur est multiplié par $2^2 = 4$, donc la force est divisée par 4. C''est la loi en carré inverse."
    },
    {
      "question": "La Terre attire la Lune. Que peut-on dire de la force exercée par la Lune sur la Terre ?",
      "choix": [
        "Elle est beaucoup plus faible car la Lune est plus légère",
        "Elle a exactement la même valeur et le sens opposé",
        "Elle est nulle",
        "Elle est plus grande car la Terre est plus massive"
      ],
      "bonne": 1,
      "explication": "C''est la troisième loi de Newton, celle des actions réciproques. Les deux forces ont toujours la même valeur, quelles que soient les masses. Ce qui diffère, c''est l''effet : à force égale, le corps le plus léger est bien plus accéléré."
    },
    {
      "question": "De quoi dépend le champ de gravitation créé en un point par une planète ?",
      "choix": [
        "De la masse de la planète et de la masse de l''objet qu''on y place",
        "De la masse de la planète et de la distance seulement",
        "De la distance seulement",
        "De la masse de l''objet qu''on y place seulement"
      ],
      "bonne": 1,
      "explication": "Le champ est une propriété de l''espace créée par la planète. Il vaut $\\mathcal{G}_0 M/r^2$ et ne contient pas la masse de l''objet test. C''est la force, elle, qui dépend de cette masse, par $\\vec{F} = m\\vec{\\mathcal{G}}$."
    },
    {
      "question": "Pour calculer le champ de gravitation à la surface de la Terre, quelle distance faut-il prendre ?",
      "choix": [
        "Zéro, puisqu''on est à la surface",
        "Le rayon de la Terre",
        "Le diamètre de la Terre",
        "L''altitude de l''observateur au-dessus du sol"
      ],
      "bonne": 1,
      "explication": "Un corps sphérique se comporte comme si toute sa masse était au centre. Depuis la surface, la distance au centre vaut donc le rayon terrestre, soit environ 6 380 km. Prendre zéro donnerait une division par zéro."
    },
    {
      "question": "Un astronaute flotte dans la Station spatiale, à 400 km d''altitude. Pourquoi ?",
      "choix": [
        "Parce que le champ de gravitation y est nul",
        "Parce qu''il est en chute libre permanente avec la station",
        "Parce qu''il est trop loin de la Terre",
        "Parce que la rotation de la Terre le compense"
      ],
      "bonne": 1,
      "explication": "À 400 km, le champ vaut encore environ 8,7 N/kg, soit près de 90 % de sa valeur au sol. L''astronaute et la station tombent ensemble vers la Terre en permanence, et c''est cette chute commune qui donne la sensation d''apesanteur."
    }
  ]
}', NULL, 5);

    RAISE NOTICE '% : chapitre 3, Forces et champs gravitationnels — 4 lecons ajoutees.', v_nom;
  END LOOP;
END $ptc$;
