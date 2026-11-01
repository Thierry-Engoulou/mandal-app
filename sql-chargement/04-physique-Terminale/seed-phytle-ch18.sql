-- ============================================================================
-- MANDAL — Physique Terminale : chapitre 18, L''effet Doppler
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
    WHERE programme_id = v_programme_id AND ordre = 18;

    -- 4. sinon on le cree
    IF v_chapitre_id IS NULL THEN
      INSERT INTO public.chapitres (programme_id, titre, ordre, niveau)
      VALUES (v_programme_id, 'L''effet Doppler', 18, 'Module 4 : Ondes, matière et transformations nucléaires')
      RETURNING id INTO v_chapitre_id;
      RAISE NOTICE '% : chapitre 18 cree.', v_nom;
    END IF;

    -- 5. les lecons
    SELECT count(*) INTO v_deja FROM public.concepts WHERE chapitre_id = v_chapitre_id;
    IF v_deja > 0 THEN
      RAISE NOTICE '% : chapitre 18 contient deja % lecon(s) — aucun ajout.', v_nom, v_deja;
      CONTINUE;
    END IF;

    INSERT INTO public.concepts
      (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes) VALUES
      (v_chapitre_id, 'L''effet Doppler', 1, 'texte', 'Une ambulance passe devant toi. Tant qu''elle approche, sa sirène est aiguë. Dès qu''elle t''a dépassé, elle devient grave. La sirène n''a pourtant pas changé.

## L''explication

Quand la source s''approche, elle court après les ondes qu''elle émet. Chaque crête est émise un peu plus près de toi que la précédente, donc les crêtes arrivent **plus serrées**. La longueur d''onde reçue diminue, donc la fréquence reçue augmente : le son est plus aigu.

Quand la source s''éloigne, c''est l''inverse. Les crêtes s''espacent, la longueur d''onde augmente, la fréquence baisse : le son est plus grave.

C''est l''**effet Doppler**, et il concerne toutes les ondes, sonores comme lumineuses.

## Les formules

Soit $N$ la fréquence émise par la source, $v$ la célérité de l''onde dans le milieu et $v_{S}$ la vitesse de la source.

Si la source **s''approche** d''un observateur immobile,
$$N'' = N\,\dfrac{v}{v - v_{S}}$$

Le dénominateur est plus petit que $v$, donc $N'' > N$. La fréquence perçue est plus élevée.

Si la source **s''éloigne**,
$$N'' = N\,\dfrac{v}{v + v_{S}}$$

et cette fois $N'' < N$.

Si c''est l''observateur qui bouge à la vitesse $v_{O}$ vers une source immobile,
$$N'' = N\,\dfrac{v + v_{O}}{v}$$

et s''il s''en éloigne,
$$N'' = N\,\dfrac{v - v_{O}}{v}$$

Tu n''as pas besoin de retenir les quatre. Retiens le principe : rapprochement veut dire fréquence plus grande, éloignement veut dire fréquence plus petite. Tu places ensuite le signe de façon à obtenir ce résultat.

## Quand la source va plus vite que l''onde

Si $v_{S} > v$, la source dépasse ses propres ondes. Les fronts d''onde s''accumulent sur un cône, et il se forme une onde de choc.

C''est le **bang supersonique** entendu au passage d''un avion de chasse. Le même phénomène produit la vague en V derrière un bateau rapide.

## Les applications

Le **radar de contrôle routier** envoie une onde vers le véhicule, qui la renvoie. L''onde subit deux fois l''effet Doppler, à l''aller et au retour. La mesure du décalage de fréquence donne directement la vitesse.

Le **radar météorologique** repère de la même façon le déplacement des masses nuageuses et la vitesse du vent.

En **médecine**, l''échographie Doppler mesure la vitesse du sang dans les artères, ce qui permet de détecter un rétrécissement.

En **astronomie**, c''est l''outil le plus précieux. La lumière des galaxies lointaines est décalée vers le rouge, c''est-à-dire vers les grandes longueurs d''onde. On appelle cela le **redshift**, et il prouve que ces galaxies s''éloignent de nous. C''est l''un des arguments les plus forts en faveur de l''expansion de l''univers.

Le **GPS** doit lui aussi tenir compte de l''effet Doppler, puisque les satellites se déplacent rapidement par rapport au récepteur.

## Exercice d''application

Une ambulance roule à $90$ km/h, sirène émettant à $800$ Hz. Calcule la fréquence entendue par un piéton immobile quand elle s''approche, puis quand elle s''éloigne. On prend $v_{\text{son}} = 340$ m/s.

Correction. Convertissons la vitesse : $90$ km/h $= \dfrac{90}{3{,}6} = 25$ m/s.

Quand l''ambulance s''approche,
$$N'' = 800 \times \dfrac{340}{340 - 25} = 800 \times \dfrac{340}{315} = 800 \times 1{,}079 \approx 864\ \text{Hz}$$

Quand elle s''éloigne,
$$N'' = 800 \times \dfrac{340}{340 + 25} = 800 \times \dfrac{340}{365} = 800 \times 0{,}9315 \approx 745\ \text{Hz}$$

L''écart total atteint donc $864 - 745 = 119$ Hz, ce qui correspond à peu près à deux tons en musique. C''est largement perceptible, d''où la netteté de l''effet au passage du véhicule.', NULL, 15),
      (v_chapitre_id, 'Les applications de l''effet Doppler', 2, 'texte', 'Ce petit décalage de fréquence est devenu l''un des outils de mesure les plus utilisés au monde. Voici comment il travaille, domaine par domaine.

## Le radar de contrôle routier

Le radar émet une onde de fréquence $N$ vers le véhicule. Celui-ci la reçoit décalée, puis la renvoie en se déplaçant, ce qui la décale une seconde fois.

Le décalage total vaut donc, pour $v \ll c$,
$$\Delta N = \dfrac{2\,v\,N}{c}$$

Le facteur $2$ vient de ce double décalage. En mesurant $\Delta N$, l''appareil remonte directement à la vitesse
$$v = \dfrac{c\,\Delta N}{2N}$$

Le radar doit être placé face au véhicule. S''il forme un angle $\theta$ avec la trajectoire, seule la composante de la vitesse dans sa direction est mesurée, et la formule devient $\Delta N = \dfrac{2vN\cos\theta}{c}$. C''est pourquoi un radar mal orienté sous-estime toujours la vitesse.

## Le radar météorologique

Le même principe appliqué aux gouttes de pluie donne la vitesse des masses d''air. On repère ainsi la formation des orages et on suit les fronts.

Pour le Cameroun, où la saison des pluies est brutale, ces radars sont précieux pour prévenir les inondations.

## L''échographie Doppler

En médecine, une sonde envoie des ultrasons vers un vaisseau sanguin. Les globules rouges en mouvement les renvoient avec un décalage.

Le médecin obtient ainsi la vitesse du sang, et détecte un rétrécissement ou un caillot sans aucune intervention. L''appareil traduit souvent le décalage en son audible, d''où le bruit caractéristique du cœur du fœtus lors d''une échographie.

## L''astronomie et l''expansion de l''univers

C''est l''application la plus spectaculaire. La lumière des galaxies porte les raies caractéristiques des éléments, notamment celles de l''hydrogène.

Quand on compare ces raies à celles mesurées au laboratoire, on constate qu''elles sont décalées vers les grandes longueurs d''onde. C''est le **redshift**, ou décalage vers le rouge.

Hubble a montré en 1929 que ce décalage est d''autant plus grand que la galaxie est lointaine. Autrement dit, plus une galaxie est loin, plus elle s''éloigne vite. C''est la preuve que l''univers est en **expansion**.

C''est aussi par effet Doppler qu''on détecte beaucoup d''exoplanètes. Une planète qui tourne autour d''une étoile la fait légèrement osciller, et cette oscillation se lit dans le décalage périodique de ses raies.

## Le GPS

Les satellites GPS filent à près de $14\,000$ km/h. Le signal qu''ils émettent arrive donc décalé, et ce décalage varie selon la position du récepteur.

Loin d''être un défaut, ce décalage est exploité : il améliore la précision du calcul de position et permet au récepteur de mesurer sa propre vitesse.

## Exercice d''application

Un radar routier émet à $N = 24{,}0$ GHz. Il mesure un décalage de $\Delta N = 2\,400$ Hz sur un véhicule qui s''approche. Calcule sa vitesse. On donne $c = 3{,}00 \times 10^{8}$ m/s.

Correction. On part de la formule du double décalage :
$$v = \dfrac{c\,\Delta N}{2N} = \dfrac{3{,}00 \times 10^{8} \times 2400}{2 \times 24{,}0 \times 10^{9}}$$

Le numérateur vaut $7{,}2 \times 10^{11}$ et le dénominateur $4{,}8 \times 10^{10}$.

Donc
$$v = \dfrac{7{,}2 \times 10^{11}}{4{,}8 \times 10^{10}} = 15\ \text{m/s}$$

soit $15 \times 3{,}6 = 54$ km/h.

Le véhicule roulait donc à $54$ km/h. S''il était en agglomération limitée à $50$, l''automobiliste recevra son avis, même si la marge technique de $5$ km/h le sauvera peut-être.', NULL, 15),
      (v_chapitre_id, 'Entends l''effet Doppler', 3, 'interactif', '{
  "widget": "effet-doppler",
  "consigne": "Fais avancer la source et observe les fronts d''onde se resserrer devant elle et s''écarter derrière. Augmente la vitesse jusqu''à dépasser celle de l''onde : tu verras apparaître le cône de choc. Lis les fréquences perçues de chaque côté."
}', NULL, 10),
      (v_chapitre_id, 'Quiz du chapitre 18', 4, 'quiz', '{
  "titre": "Vérifie que tu as compris",
  "questions": [
    {
      "question": "Une source sonore s''approche de vous. Que percevez-vous ?",
      "choix": [
        "Un son plus grave",
        "Un son plus aigu",
        "Le même son",
        "Un son plus fort seulement"
      ],
      "bonne": 1,
      "explication": "En s''approchant, la source rattrape ses propres ondes. Les crêtes arrivent plus serrées, donc la fréquence perçue augmente et le son paraît plus aigu."
    },
    {
      "question": "La lumière d''une galaxie lointaine est décalée vers le rouge. Que peut-on en conclure ?",
      "choix": [
        "Elle se rapproche de nous",
        "Elle s''éloigne de nous",
        "Elle est très chaude",
        "Elle est immobile"
      ],
      "bonne": 1,
      "explication": "Le rouge correspond aux grandes longueurs d''onde, donc aux faibles fréquences. Une baisse de fréquence signifie un éloignement. Ce redshift est un argument majeur en faveur de l''expansion de l''univers."
    },
    {
      "question": "Que se passe-t-il quand la source va plus vite que l''onde qu''elle émet ?",
      "choix": [
        "L''onde disparaît",
        "Il se forme une onde de choc en cône",
        "La fréquence devient nulle",
        "L''onde change de direction"
      ],
      "bonne": 1,
      "explication": "La source dépasse ses propres fronts d''onde, qui s''accumulent sur un cône. C''est le bang supersonique des avions de chasse, et la vague en V derrière un bateau rapide."
    },
    {
      "question": "Pourquoi l''onde d''un radar routier subit-elle deux fois l''effet Doppler ?",
      "choix": [
        "Parce que le radar émet deux ondes",
        "Parce qu''elle est décalée à l''aller vers la voiture puis au retour vers le radar",
        "Parce qu''elle traverse l''air deux fois",
        "Parce que la voiture freine"
      ],
      "bonne": 1,
      "explication": "La voiture reçoit une onde décalée, puis la réémet en se déplaçant, ce qui la décale une seconde fois. Le décalage total est donc doublé, ce qui rend la mesure plus sensible."
    }
  ]
}', NULL, 5);

    RAISE NOTICE '% : chapitre 18, L''effet Doppler — 4 lecons ajoutees.', v_nom;
  END LOOP;
END $ptc$;
