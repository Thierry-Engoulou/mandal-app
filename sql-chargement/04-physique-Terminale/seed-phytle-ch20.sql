-- ============================================================================
-- MANDAL — Physique Terminale : chapitre 20, L''effet photoélectrique
-- Module 4 : Ondes, matière et transformations nucléaires
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
    WHERE programme_id = v_programme_id AND ordre = 20;

    -- 4. sinon on le cree
    IF v_chapitre_id IS NULL THEN
      INSERT INTO public.chapitres (programme_id, titre, ordre, niveau)
      VALUES (v_programme_id, 'L''effet photoélectrique', 20, 'Module 4 : Ondes, matière et transformations nucléaires')
      RETURNING id INTO v_chapitre_id;
      RAISE NOTICE '% : chapitre 20 cree.', v_nom;
    END IF;

    -- 5. les lecons
    SELECT count(*) INTO v_deja FROM public.concepts WHERE chapitre_id = v_chapitre_id;
    IF v_deja > 0 THEN
      RAISE NOTICE '% : chapitre 20 contient deja % lecon(s) — aucun ajout.', v_nom, v_deja;
      CONTINUE;
    END IF;

    INSERT INTO public.concepts
      (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes) VALUES
      (v_chapitre_id, 'L''expérience et les faits troublants', 1, 'texte', 'Éclaire une plaque de zinc fraîchement polie avec une lampe à ultraviolets, et elle perd sa charge négative. Éclaire-la avec une lumière rouge très intense, et il ne se passe rien. Ce comportement a mis la physique classique en échec.

## L''expérience de Hertz

On relie une plaque de zinc à un électroscope et on charge l''ensemble négativement : les feuilles de l''électroscope s''écartent.

En éclairant la plaque avec de la lumière ultraviolette, les feuilles retombent. La plaque a perdu ses électrons.

Si on charge l''électroscope **positivement**, l''éclairement ne change rien. C''est bien que la lumière arrache des électrons, et que ceux-ci sont retenus quand la plaque est positive.

On appelle **effet photoélectrique** cette extraction d''électrons d''un métal sous l''effet de la lumière.

## Les quatre faits observés

**Premier fait.** L''effet n''existe que si la fréquence de la lumière dépasse une valeur $\nu_{0}$, appelée **fréquence seuil**, propre à chaque métal. En dessous, rien ne se produit, même avec une lumière très intense.

**Deuxième fait.** L''effet est **instantané**, en moins d''un milliardième de seconde, même avec une lumière très faible.

**Troisième fait.** Le nombre d''électrons arrachés par seconde est proportionnel à l''**intensité** lumineuse.

**Quatrième fait.** L''énergie cinétique maximale des électrons ne dépend **pas** de l''intensité, mais seulement de la **fréquence**.

## Pourquoi la physique classique échoue

Si la lumière était une simple onde, son énergie serait répartie continûment et proportionnelle à son intensité.

Une lumière rouge très intense devrait alors finir par arracher des électrons, quitte à mettre du temps. Or elle n''y parvient jamais.

Une lumière faible devrait mettre longtemps à accumuler assez d''énergie. Or l''effet est immédiat.

Et l''énergie des électrons devrait dépendre de l''intensité, pas de la couleur. C''est l''inverse qu''on observe.

Les quatre faits contredisent donc le modèle ondulatoire.

## L''hypothèse d''Einstein

En 1905, Einstein propose une idée radicale. La lumière est faite de grains d''énergie, les **photons**, chacun portant l''énergie
$$E = h\,\nu = \dfrac{h\,c}{\lambda}$$

L''extraction se fait alors par un choc individuel : **un photon pour un électron**. Tout devient clair.

Il faut un photon assez énergétique, donc une fréquence suffisante, d''où le seuil. Le choc est immédiat, d''où l''instantanéité. Plus il y a de photons, plus il y a d''électrons arrachés, d''où le rôle de l''intensité. Et l''énergie de l''électron vient du photon, donc de la fréquence, pas du nombre de photons.

Cette explication a valu à Einstein le prix Nobel de 1921, et non la relativité comme on le croit souvent.

## La relation d''Einstein

Le **travail d''extraction** $W_{0}$ est l''énergie minimale pour arracher un électron au métal. Il vaut
$$W_{0} = h\,\nu_{0} = \dfrac{h\,c}{\lambda_{0}}$$
où $\lambda_{0}$ est la longueur d''onde seuil.

Le reste de l''énergie du photon devient de l''énergie cinétique :
$$h\,\nu = W_{0} + E_{c\max} \qquad \text{donc} \qquad E_{c\max} = h\,\nu - W_{0}$$

C''est une simple conservation de l''énergie. Si $h\nu < W_{0}$, aucun électron ne sort.

Attention au sens du seuil. L''effet se produit si $\nu > \nu_{0}$, ce qui s''écrit aussi $\lambda < \lambda_{0}$. Pour les longueurs d''onde, c''est **inférieur**. C''est un piège classique.

## La dualité onde-corpuscule

La lumière diffracte et interfère, ce qui est un comportement d''onde. Elle arrache des électrons un par un, ce qui est un comportement de particule.

Elle n''est ni tout à fait l''un ni tout à fait l''autre. Selon l''expérience, c''est l''un ou l''autre aspect qui se manifeste. On appelle cela la **dualité onde-corpuscule**, et c''est l''un des fondements de la physique moderne.

## Exercice d''application

Le césium a un travail d''extraction $W_{0} = 1{,}9$ eV. Calcule sa longueur d''onde seuil. Puis calcule l''énergie cinétique maximale des électrons émis sous une lumière de $400$ nm. On donne $h = 6{,}63 \times 10^{-34}$ J·s et $c = 3{,}00 \times 10^{8}$ m/s.

Correction. Convertissons le travail d''extraction :
$$W_{0} = 1{,}9 \times 1{,}6 \times 10^{-19} = 3{,}04 \times 10^{-19}\ \text{J}$$

La longueur d''onde seuil vaut
$$\lambda_{0} = \dfrac{h\,c}{W_{0}} = \dfrac{6{,}63 \times 10^{-34} \times 3{,}00 \times 10^{8}}{3{,}04 \times 10^{-19}} = \dfrac{1{,}989 \times 10^{-25}}{3{,}04 \times 10^{-19}}$$

soit $\lambda_{0} \approx 6{,}5 \times 10^{-7}$ m, c''est-à-dire $650$ nm. Le césium réagit donc même à la lumière rouge, ce qui en fait un excellent matériau pour les cellules photoélectriques.

Pour $\lambda = 400$ nm, l''énergie du photon vaut
$$E = \dfrac{1{,}989 \times 10^{-25}}{400 \times 10^{-9}} = 4{,}97 \times 10^{-19}\ \text{J}$$

L''énergie cinétique maximale vaut donc
$$E_{c\max} = 4{,}97 \times 10^{-19} - 3{,}04 \times 10^{-19} = 1{,}93 \times 10^{-19}\ \text{J}$$

soit, en électronvolts, $\dfrac{1{,}93 \times 10^{-19}}{1{,}6 \times 10^{-19}} \approx 1{,}2$ eV.', NULL, 15),
      (v_chapitre_id, 'La cellule photoélectrique et son rendement', 2, 'texte', 'Pour étudier l''effet photoélectrique quantitativement, on enferme le métal dans une ampoule vide munie d''une seconde électrode. On obtient une cellule photoélectrique, et sa caractéristique révèle tout.

## Le dispositif

Dans une ampoule où l''on a fait le vide, une **cathode** recouverte du métal à étudier fait face à une **anode** collectrice.

On éclaire la cathode, les électrons arrachés traversent le vide, atteignent l''anode, et un courant apparaît dans le circuit extérieur. On le mesure avec un microampèremètre.

Un générateur réglable permet d''appliquer entre les deux électrodes une tension $U_{AC}$ positive ou négative.

## L''influence de la tension

Quand $U_{AC}$ est **positive**, l''anode attire les électrons. Le courant augmente d''abord, puis se stabilise : tous les électrons émis sont collectés. C''est le **courant de saturation** $I_{s}$.

Quand $U_{AC}$ est **négative**, l''anode repousse les électrons. Seuls les plus rapides parviennent encore à l''atteindre. Le courant diminue.

Pour une tension suffisamment négative, plus aucun électron n''arrive. C''est la **tension d''arrêt** $U_{0}$, et elle vérifie
$$e\,U_{0} = E_{c\max} = h\nu - W_{0}$$

Cette relation est remarquable. Elle permet de mesurer l''énergie cinétique maximale des électrons avec un simple voltmètre.

## Ce que montre la caractéristique

En traçant $U_{0}$ en fonction de la fréquence $\nu$, on obtient une **droite**
$$U_{0} = \dfrac{h}{e}\,\nu - \dfrac{W_{0}}{e}$$

Sa pente vaut $\dfrac{h}{e}$, ce qui donne une mesure directe de la constante de Planck. C''est ainsi que Millikan l''a déterminée en 1916, confirmant la théorie d''Einstein qu''il cherchait pourtant à réfuter.

Son intersection avec l''axe des fréquences donne la fréquence seuil $\nu_{0}$, et donc le travail d''extraction.

Fait essentiel : cette droite a la **même pente** pour tous les métaux. Seule son ordonnée à l''origine change, puisque seul $W_{0}$ dépend du métal.

## L''influence de l''intensité lumineuse

Si l''on double l''intensité sans changer la couleur, le courant de saturation **double**, car il y a deux fois plus de photons donc deux fois plus d''électrons.

Mais la tension d''arrêt ne change **pas**, car l''énergie de chaque électron reste la même.

Ces deux observations, prises ensemble, constituent la vérification expérimentale la plus nette de l''hypothèse du photon.

## Le rendement quantique

Tous les photons n''arrachent pas un électron. Beaucoup sont réfléchis, ou absorbés sans effet.

Le **rendement quantique** est le rapport
$$\rho = \dfrac{\text{nombre d''électrons émis}}{\text{nombre de photons reçus}}$$

Il dépasse rarement quelques pour cent pour les cellules courantes.

Si la cellule reçoit une puissance lumineuse $P$ à la longueur d''onde $\lambda$, le nombre de photons reçus par seconde vaut
$$n = \dfrac{P}{h\nu} = \dfrac{P\,\lambda}{h\,c}$$

et le courant de saturation vaut $I_{s} = \rho\,n\,e$.

## Exercice d''application

Une cellule au potassium, de travail d''extraction $W_{0} = 2{,}25$ eV, est éclairée par une lumière de $400$ nm délivrant une puissance de $1{,}0$ mW. Calcule la tension d''arrêt. Puis, sachant que le courant de saturation vaut $16\ \mu$A, calcule le rendement quantique.

Correction. L''énergie du photon vaut
$$E = \dfrac{hc}{\lambda} = \dfrac{1{,}989 \times 10^{-25}}{400 \times 10^{-9}} = 4{,}97 \times 10^{-19}\ \text{J}$$

soit, en électronvolts, $\dfrac{4{,}97 \times 10^{-19}}{1{,}6 \times 10^{-19}} = 3{,}11$ eV.

L''énergie cinétique maximale vaut $3{,}11 - 2{,}25 = 0{,}86$ eV, donc la tension d''arrêt vaut
$$U_{0} = 0{,}86\ \text{V}$$

Le nombre de photons reçus par seconde vaut
$$n = \dfrac{P}{E} = \dfrac{1{,}0 \times 10^{-3}}{4{,}97 \times 10^{-19}} \approx 2{,}01 \times 10^{15}\ \text{photons/s}$$

Le nombre d''électrons émis par seconde vaut
$$n_{e} = \dfrac{I_{s}}{e} = \dfrac{16 \times 10^{-6}}{1{,}6 \times 10^{-19}} = 1{,}0 \times 10^{14}\ \text{électrons/s}$$

Le rendement quantique vaut donc
$$\rho = \dfrac{1{,}0 \times 10^{14}}{2{,}01 \times 10^{15}} \approx 0{,}050$$

soit environ $5\%$. Vingt photons sont nécessaires en moyenne pour arracher un seul électron.', NULL, 15),
      (v_chapitre_id, 'Arrache des électrons avec la lumière', 3, 'interactif', '{
  "widget": "photoelectrique",
  "consigne": "Choisis un métal, règle la longueur d''onde et l''intensité du faisceau. Trouve la longueur d''onde seuil au-delà de laquelle plus rien ne sort. Augmente ensuite l''intensité sans changer la couleur : le nombre d''électrons change-t-il ? Et leur énergie ?"
}', NULL, 10),
      (v_chapitre_id, 'Quiz du chapitre 20', 4, 'quiz', '{
  "titre": "Vérifie que tu as compris",
  "questions": [
    {
      "question": "Une lumière rouge très intense n''arrache aucun électron d''une plaque de zinc. Pourquoi ?",
      "choix": [
        "Elle n''est pas assez intense",
        "Sa fréquence est inférieure à la fréquence seuil du zinc",
        "Le zinc est un mauvais conducteur",
        "Il faut attendre plus longtemps"
      ],
      "bonne": 1,
      "explication": "L''extraction se fait photon par photon. Si chaque photon rouge porte moins que le travail d''extraction, augmenter leur nombre ne sert à rien : il y a plus de chocs, mais aucun n''est assez énergétique."
    },
    {
      "question": "On double l''intensité lumineuse sans changer la couleur. Que devient l''énergie cinétique des électrons ?",
      "choix": [
        "Elle double",
        "Elle ne change pas",
        "Elle est divisée par deux",
        "Elle devient nulle"
      ],
      "bonne": 1,
      "explication": "L''énergie de chaque électron vient d''un seul photon, donc elle ne dépend que de la fréquence. Doubler l''intensité double le nombre de photons, donc le nombre d''électrons, mais pas leur énergie individuelle."
    },
    {
      "question": "Quelle condition sur la longueur d''onde permet l''effet photoélectrique ?",
      "choix": [
        "$\\lambda > \\lambda_0$",
        "$\\lambda < \\lambda_0$",
        "$\\lambda = \\lambda_0$ exactement",
        "Aucune condition"
      ],
      "bonne": 1,
      "explication": "Il faut $\\nu > \\nu_0$ pour que le photon soit assez énergétique. Comme $\\lambda = c/\\nu$, cela correspond à $\\lambda < \\lambda_0$. L''inégalité change de sens quand on passe de la fréquence à la longueur d''onde."
    },
    {
      "question": "Que vaut l''énergie d''un photon de fréquence $\\nu$ ?",
      "choix": [
        "$h/\\nu$",
        "$h\\nu$",
        "$hc\\nu$",
        "$\\nu/h$"
      ],
      "bonne": 1,
      "explication": "La relation de Planck-Einstein s''écrit $E = h\\nu = hc/\\lambda$, avec $h = 6{,}63 \\times 10^{-34}$ J·s. L''énergie est proportionnelle à la fréquence, donc inversement proportionnelle à la longueur d''onde."
    },
    {
      "question": "Que montre l''effet photoélectrique sur la nature de la lumière ?",
      "choix": [
        "Qu''elle est uniquement une onde",
        "Qu''elle possède aussi un aspect corpusculaire",
        "Qu''elle n''a pas d''énergie",
        "Qu''elle se propage dans le vide"
      ],
      "bonne": 1,
      "explication": "La diffraction et les interférences prouvent l''aspect ondulatoire, l''effet photoélectrique prouve l''aspect corpusculaire. C''est la dualité onde-corpuscule, l''un des fondements de la physique quantique."
    }
  ]
}', NULL, 5);

    RAISE NOTICE '% : chapitre 20, L''effet photoélectrique — 4 lecons ajoutees.', v_nom;
  END LOOP;
END $ptc$;
