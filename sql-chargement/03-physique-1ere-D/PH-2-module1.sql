-- ============================================================================
-- MANDAL — Physique 1ère D : etape 2 sur 5, module 1, mesures et incertitudes
-- Ajoute les lecons, les quiz et les simulations de ce module.
-- A lancer APRES PH-1-structure.sql.
-- Idempotent : relancez-le autant de fois que vous voulez.
-- ============================================================================

-- ---------------------------------------------------------------------------
-- Chapitre manquant : Mesure des grandeurs physique et chimique
-- ---------------------------------------------------------------------------
DO $ph$
DECLARE
  v_prog uuid;
  v_ordre int;
BEGIN
  SELECT id INTO v_prog FROM public.programmes WHERE titre = 'Physique — 1ère D';
  IF v_prog IS NULL THEN
    RAISE EXCEPTION 'Programme "Physique — 1ère D" introuvable.';
  END IF;

  IF NOT EXISTS (SELECT 1 FROM public.chapitres WHERE programme_id = v_prog AND titre = 'Mesure des grandeurs physique et chimique') THEN
    SELECT coalesce(max(ordre), 0) + 1 INTO v_ordre FROM public.chapitres WHERE programme_id = v_prog;
    INSERT INTO public.chapitres (programme_id, titre, ordre, niveau)
    VALUES (v_prog, 'Mesure des grandeurs physique et chimique', v_ordre, 'Module 1 : Mesures et incertitudes');
    RAISE NOTICE 'Chapitre "Mesure des grandeurs physique et chimique" cree.';
  END IF;
END $ph$;

-- ---------------------------------------------------------------------------
-- Chapitre manquant : Contraintes d''une loi
-- ---------------------------------------------------------------------------
DO $ph$
DECLARE
  v_prog uuid;
  v_ordre int;
BEGIN
  SELECT id INTO v_prog FROM public.programmes WHERE titre = 'Physique — 1ère D';
  IF v_prog IS NULL THEN
    RAISE EXCEPTION 'Programme "Physique — 1ère D" introuvable.';
  END IF;

  IF NOT EXISTS (SELECT 1 FROM public.chapitres WHERE programme_id = v_prog AND titre = 'Contraintes d''une loi') THEN
    SELECT coalesce(max(ordre), 0) + 1 INTO v_ordre FROM public.chapitres WHERE programme_id = v_prog;
    INSERT INTO public.chapitres (programme_id, titre, ordre, niveau)
    VALUES (v_prog, 'Contraintes d''une loi', v_ordre, 'Module 1 : Mesures et incertitudes');
    RAISE NOTICE 'Chapitre "Contraintes d''une loi" cree.';
  END IF;
END $ph$;

-- ---------------------------------------------------------------------------
-- Mesure des grandeurs physique et chimique
-- ---------------------------------------------------------------------------
DO $ph$
DECLARE
  r record;
  v_chap uuid;
  v_ordre int;
  v_ajout int := 0;
BEGIN
  SELECT c.id INTO v_chap FROM public.chapitres c
  JOIN public.programmes p ON p.id = c.programme_id
  WHERE p.titre = 'Physique — 1ère D' AND c.titre = 'Mesure des grandeurs physique et chimique';

  IF v_chap IS NULL THEN
    RAISE NOTICE 'Chapitre "Mesure des grandeurs physique et chimique" introuvable — ignore.';
    RETURN;
  END IF;

  FOR r IN SELECT * FROM (VALUES
    ('Les instruments de mesure et leurs unités', 'texte', 'Mesurer, c''est comparer une grandeur à une unité. Avant de calculer quoi que ce soit, il faut savoir quel appareil prendre et dans quelle unité on écrit le résultat.

## Ce qu''on appelle une grandeur physique

Une grandeur physique est un élément mesurable qui décrit sans ambiguïté une partie d''un phénomène. La masse, la longueur, la température, l''intensité d''un courant sont des grandeurs physiques. La beauté d''un paysage n''en est pas une.

Un instrument de mesure est tout dispositif qui sert à mesurer une grandeur physique ou chimique. La grandeur qu''il mesure s''appelle le mesurande.

## Les instruments à connaître

La balance mesure une masse, en kilogrammes de symbole kg en physique, en grammes de symbole g en chimie. Le mètre ruban mesure une longueur, en mètres de symbole m. Le chronomètre mesure une durée, en secondes de symbole s.

Le thermomètre mesure une température, en degrés Celsius de symbole °C ou en kelvins de symbole K, avec la relation $T(\mathrm{K}) = T(°\mathrm{C}) + 273$.

L''ampèremètre mesure une intensité en ampères de symbole A, et se branche en série. Le voltmètre mesure une tension en volts de symbole V, et se branche en dérivation. L''ohmmètre mesure une résistance en ohms de symbole $\Omega$. Le multimètre réunit les trois dans un seul boîtier, c''est l''appareil le plus courant au laboratoire.

Le wattmètre mesure une puissance en watts de symbole W. Le fréquencemètre mesure une fréquence en hertz de symbole Hz. Le pH-mètre donne le pH d''une solution, qui est un nombre sans unité. Le conductimètre mesure la conductivité d''une solution.

## Choisir le bon instrument

Pour peser un sac de riz au marché, une balance de ménagère suffit. Pour peser 2 g de sel pour une expérience de chimie, il faut une balance de précision. Le choix dépend de la grandeur à mesurer, de son ordre de grandeur, et de la précision dont tu as besoin. C''est l''objet de la leçon suivante.

## Exercice d''application

Quel instrument et quelle unité utilises-tu pour mesurer la tension aux bornes d''une pile, puis la durée d''une chute ?

Correction. Pour la tension, un voltmètre branché en dérivation aux bornes de la pile, et le résultat s''écrit en volts. Pour la durée, un chronomètre, et le résultat s''écrit en secondes.', NULL, 15),
    ('Les qualités d''un instrument de mesure', 'texte', 'Deux appareils peuvent mesurer la même grandeur sans se valoir. La métrologie, c''est la science qui compare leurs qualités.

## L''étendue de mesure

C''est le domaine dans lequel l''appareil sait travailler, défini par une valeur minimale et une valeur maximale, appelées portées. Un voltmètre d''étendue 1 V à 10 V ne mesurera correctement ni 0,2 V ni 50 V.

## La résolution

C''est la plus petite variation que l''appareil arrive à afficher. Elle s''exprime souvent en points, c''est-à-dire le nombre de valeurs différentes affichables.

Un multimètre de 2 000 points réglé sur le calibre 2 V affiche toutes les valeurs de 0,000 V à 1,999 V. Sa résolution vaut donc 1 mV.

## La sensibilité

C''est le rapport entre la variation de l''indication donnée et la variation de la grandeur mesurée :

$$S = \dfrac{\Delta A}{\Delta G}$$

Un appareil est d''autant plus sensible qu''une petite variation de la grandeur provoque un grand changement de l''affichage. Sur une caractéristique, la sensibilité est la pente de la courbe de graduation.

## Justesse, fidélité, exactitude

Un appareil est juste quand ses indications sont en moyenne proches de la valeur vraie, sans erreur systématique.

Il est fidèle quand il donne presque toujours la même indication si on refait la même mesure, c''est-à-dire que la dispersion est faible.

Il est exact quand il est à la fois juste et fidèle. L''exactitude ne se chiffre pas, c''est une appréciation globale.

Pour bien retenir : une balance mal tarée qui ajoute toujours 100 g est fidèle mais pas juste. Une balance qui saute entre 1,9 kg et 2,1 kg autour de la vraie valeur 2 kg est juste en moyenne mais pas fidèle.

## Exercice d''application

Un thermomètre indique 38,2 °C, 38,1 °C puis 38,2 °C pour un corps qui est en réalité à 37,0 °C. Est-il fidèle ? Est-il juste ?

Correction. Les trois mesures sont très proches entre elles, donc l''appareil est fidèle. Mais elles sont toutes décalées d''environ 1,2 °C par rapport à la valeur vraie, donc il n''est pas juste. Il n''est donc pas exact.', NULL, 15),
    ('Présenter correctement un résultat de mesure', 'texte', 'Un résultat mal écrit est un résultat faux, même quand le calcul est bon. Trois règles suffisent.

## La notation scientifique

Tout nombre décimal non nul s''écrit $a \times 10^{n}$, avec $1 \leq |a| < 10$ et $n$ entier relatif.

La distance Douala-Yaoundé, environ 230 000 m, s''écrit $2{,}30 \times 10^{5}$ m. Le diamètre d''un cheveu, 0,000 07 m, s''écrit $7 \times 10^{-5}$ m.

## Les préfixes usuels

Tu dois connaître : nano $n$ pour $10^{-9}$, micro $\mu$ pour $10^{-6}$, milli $m$ pour $10^{-3}$, centi $c$ pour $10^{-2}$, kilo $k$ pour $10^{3}$, méga $M$ pour $10^{6}$, giga $G$ pour $10^{9}$.

Ainsi 2,5 kV valent $2{,}5 \times 10^{3}$ V, et 470 $\mu$F valent $470 \times 10^{-6}$ F, soit $4{,}7 \times 10^{-4}$ F.

## Les chiffres significatifs

Ce sont les chiffres qui portent une information réelle. On compte à partir du premier chiffre non nul, de gauche à droite.

Le nombre 0,004 50 possède 3 chiffres significatifs, les zéros de gauche ne comptent pas. Le nombre 1 230 en possède 4. Le nombre $2{,}30 \times 10^{5}$ en possède 3 : le zéro final compte, puisqu''il a été écrit exprès.

Deux règles pour les calculs. Pour un produit ou un quotient, le résultat garde autant de chiffres significatifs que la donnée qui en a le moins. Pour une somme ou une différence, le résultat garde autant de décimales que la donnée qui en a le moins.

Si tu mesures une longueur de 12,4 cm et une largeur de 3,2 cm, l''aire vaut $12{,}4 \times 3{,}2 = 39{,}68$ cm² à la calculatrice. Mais 3,2 n''a que 2 chiffres significatifs, donc tu écris 40 cm², ou mieux $4{,}0 \times 10^{1}$ cm².

## L''arrondi

Si le chiffre qui suit est inférieur à 5, on garde le chiffre. S''il est supérieur ou égal à 5, on ajoute 1. Ainsi 3,14159 arrondi à 3 chiffres significatifs donne 3,14, et 2,567 arrondi à 3 chiffres significatifs donne 2,57.

## Exercice d''application

Écris $0{,}0000342$ en notation scientifique, donne son nombre de chiffres significatifs, puis calcule $0{,}0000342 \times 1\,200$ avec le bon nombre de chiffres.

Correction. On écrit $3{,}42 \times 10^{-5}$, qui possède 3 chiffres significatifs. Le produit vaut $3{,}42 \times 10^{-5} \times 1{,}200 \times 10^{3} = 4{,}104 \times 10^{-2}$. Comme la donnée la moins précise a 3 chiffres significatifs, on écrit $4{,}10 \times 10^{-2}$.', NULL, 15),
    ('Quiz : mesurer et présenter un résultat', 'quiz', '{
  "titre": "Vérifie que tu as compris",
  "questions": [
    {
      "question": "Pour mesurer l''intensité d''un courant, on branche :",
      "choix": [
        "un voltmètre en dérivation",
        "un ampèremètre en série",
        "un ohmmètre en série"
      ],
      "bonne": 1,
      "explication": "L''ampèremètre se place en série, car tout le courant doit le traverser. Le voltmètre, lui, se branche en dérivation."
    },
    {
      "question": "Une balance indique toujours 100 g de plus que la valeur vraie. Elle est :",
      "choix": [
        "juste mais pas fidèle",
        "fidèle mais pas juste",
        "exacte"
      ],
      "bonne": 1,
      "explication": "Elle répète toujours la même indication, donc elle est fidèle. Mais elle est décalée de la valeur vraie, donc elle n''est pas juste, et donc pas exacte."
    },
    {
      "question": "Combien de chiffres significatifs compte le nombre $0{,}00710$ ?",
      "choix": [
        "2",
        "3",
        "5"
      ],
      "bonne": 1,
      "explication": "Les zéros de gauche ne comptent pas. On compte 7, 1 et 0, soit 3 chiffres significatifs. Le zéro final compte, car il a été écrit volontairement."
    },
    {
      "question": "$12{,}4 \\times 3{,}2$ doit s''écrire :",
      "choix": [
        "$39{,}68$",
        "$39{,}7$",
        "$40$"
      ],
      "bonne": 2,
      "explication": "La donnée la moins précise, 3,2, n''a que 2 chiffres significatifs. Le résultat doit donc en avoir 2 aussi, soit 40, ou $4{,}0 \\times 10^{1}$."
    },
    {
      "question": "$2{,}5$ kV valent :",
      "choix": [
        "$2\\,500$ V",
        "$0{,}0025$ V",
        "$25$ V"
      ],
      "bonne": 0,
      "explication": "Le préfixe kilo vaut $10^{3}$, donc $2{,}5 \\times 10^{3} = 2\\,500$ V."
    }
  ]
}', NULL, 5),
    ('Exercices d''entraînement corrigés', 'texte', '## Exercice 1

Un multimètre de 2 000 points est réglé sur le calibre 20 V. Quelle est sa résolution ?

Correction. Sur 2 000 points pour une étendue de 20 V, la résolution vaut $\dfrac{20}{2\,000} = 0{,}01$ V, soit 10 mV.

## Exercice 2

Convertis en unités du système international : 45 mA, 2,2 k$\Omega$, 330 $\mu$F, 12 cm.

Correction. $45$ mA $= 45 \times 10^{-3} = 4{,}5 \times 10^{-2}$ A. Ensuite $2{,}2$ k$\Omega$ $= 2{,}2 \times 10^{3} = 2\,200\ \Omega$. Puis $330\ \mu$F $= 330 \times 10^{-6} = 3{,}30 \times 10^{-4}$ F. Enfin $12$ cm $= 0{,}12$ m.

## Exercice 3

On mesure les côtés d''un rectangle : $L = 24{,}5$ cm et $\ell = 11{,}0$ cm. Donne le périmètre et l''aire avec le bon nombre de chiffres.

Correction. Le périmètre vaut $2 \times (24{,}5 + 11{,}0) = 71{,}0$ cm. Pour une somme on garde le nombre de décimales le plus faible, soit 1 décimale, donc 71,0 cm. L''aire vaut $24{,}5 \times 11{,}0 = 269{,}5$ cm². Les deux données ont 3 chiffres significatifs, donc on écrit 270 cm², soit $2{,}70 \times 10^{2}$ cm².

## Exercice 4

Un élève écrit : la masse du sachet vaut 0,250 00 kg. Sa balance affiche trois chiffres après la virgule en kilogrammes. Son écriture est-elle correcte ?

Correction. Non. La balance donne au mieux 0,250 kg, soit 3 décimales. Écrire 0,250 00 kg laisse croire à une précision de 5 décimales que l''appareil ne possède pas. Annoncer plus de chiffres que l''appareil n''en donne est une faute.', NULL, 15)
  ) AS t(titre, typ, contenu, media, duree) LOOP
    IF NOT EXISTS (SELECT 1 FROM public.concepts WHERE chapitre_id = v_chap AND titre = r.titre) THEN
      SELECT coalesce(max(ordre), 0) + 1 INTO v_ordre FROM public.concepts WHERE chapitre_id = v_chap;
      INSERT INTO public.concepts
        (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes)
      VALUES (v_chap, r.titre, v_ordre, r.typ, r.contenu, r.media, r.duree);
      v_ajout := v_ajout + 1;
    END IF;
  END LOOP;
  RAISE NOTICE 'Mesure des grandeurs physique et chimique : % lecon(s) ajoutee(s).', v_ajout;
END $ph$;

-- ---------------------------------------------------------------------------
-- Incertitude de mesure
-- ---------------------------------------------------------------------------
DO $ph$
DECLARE
  r record;
  v_chap uuid;
  v_ordre int;
  v_ajout int := 0;
BEGIN
  SELECT c.id INTO v_chap FROM public.chapitres c
  JOIN public.programmes p ON p.id = c.programme_id
  WHERE p.titre = 'Physique — 1ère D' AND c.titre = 'Incertitude de mesure';

  IF v_chap IS NULL THEN
    RAISE NOTICE 'Chapitre "Incertitude de mesure" introuvable — ignore.';
    RETURN;
  END IF;

  FOR r IN SELECT * FROM (VALUES
    ('Simulation : lire un résultat avec son incertitude', 'interactif', '{
  "widget": "incertitude-mesure",
  "consigne": "Règle la valeur mesurée sur 12,40 cm et l''incertitude sur 0,05 cm. La bande bleue montre l''intervalle dans lequel se trouve la valeur vraie. Augmente maintenant l''incertitude à 0,50 cm et regarde l''incertitude relative passer au-dessus de 4 %. Retiens la règle : plus l''incertitude relative est grande, moins tu as le droit d''écrire de chiffres après la virgule."
}', NULL, 10),
    ('Quiz : incertitude de mesure', 'quiz', '{
  "titre": "Vérifie que tu as compris",
  "questions": [
    {
      "question": "On écrit $\\ell = 12{,}4 \\pm 0{,}2$ cm. La valeur vraie se trouve :",
      "choix": [
        "exactement à 12,4 cm",
        "entre 12,2 et 12,6 cm",
        "entre 12,4 et 12,6 cm"
      ],
      "bonne": 1,
      "explication": "L''incertitude s''applique des deux côtés : de $12{,}4 - 0{,}2$ à $12{,}4 + 0{,}2$."
    },
    {
      "question": "L''incertitude relative se calcule par :",
      "choix": [
        "$\\Delta m \\times m$",
        "$\\dfrac{\\Delta m}{m}$",
        "$\\dfrac{m}{\\Delta m}$"
      ],
      "bonne": 1,
      "explication": "C''est le rapport de l''incertitude absolue à la valeur mesurée. On l''exprime souvent en pourcentage."
    },
    {
      "question": "Une mesure de $250$ g avec $\\Delta m = 5$ g a une incertitude relative de :",
      "choix": [
        "$2$ %",
        "$5$ %",
        "$0{,}2$ %"
      ],
      "bonne": 0,
      "explication": "$\\dfrac{5}{250} = 0{,}02$, soit 2 %."
    },
    {
      "question": "Entre deux mesures de la même grandeur, la plus précise est celle qui a :",
      "choix": [
        "la plus petite incertitude relative",
        "la plus grande valeur",
        "le plus de chiffres affichés"
      ],
      "bonne": 0,
      "explication": "C''est l''incertitude relative qui compare les précisions, pas le nombre de chiffres affichés à l''écran."
    }
  ]
}', NULL, 5)
  ) AS t(titre, typ, contenu, media, duree) LOOP
    IF NOT EXISTS (SELECT 1 FROM public.concepts WHERE chapitre_id = v_chap AND titre = r.titre) THEN
      SELECT coalesce(max(ordre), 0) + 1 INTO v_ordre FROM public.concepts WHERE chapitre_id = v_chap;
      INSERT INTO public.concepts
        (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes)
      VALUES (v_chap, r.titre, v_ordre, r.typ, r.contenu, r.media, r.duree);
      v_ajout := v_ajout + 1;
    END IF;
  END LOOP;
  RAISE NOTICE 'Incertitude de mesure : % lecon(s) ajoutee(s).', v_ajout;
END $ph$;

-- ---------------------------------------------------------------------------
-- Exemples de modèles utilisés en physique et en chimie
-- ---------------------------------------------------------------------------
DO $ph$
DECLARE
  r record;
  v_chap uuid;
  v_ordre int;
  v_ajout int := 0;
BEGIN
  SELECT c.id INTO v_chap FROM public.chapitres c
  JOIN public.programmes p ON p.id = c.programme_id
  WHERE p.titre = 'Physique — 1ère D' AND c.titre = 'Exemples de modèles utilisés en physique et en chimie';

  IF v_chap IS NULL THEN
    RAISE NOTICE 'Chapitre "Exemples de modèles utilisés en physique et en chimie" introuvable — ignore.';
    RETURN;
  END IF;

  FOR r IN SELECT * FROM (VALUES
    ('Quiz : modèles et lois', 'quiz', '{
  "titre": "Vérifie que tu as compris",
  "questions": [
    {
      "question": "Un modèle en physique, c''est :",
      "choix": [
        "une représentation simplifiée valable dans certaines conditions",
        "une vérité absolue",
        "un dessin de l''expérience"
      ],
      "bonne": 0,
      "explication": "Un modèle simplifie la réalité pour la rendre calculable. Il a toujours un domaine de validité."
    },
    {
      "question": "Pour vérifier qu''une loi du type $y = ax$ convient à des mesures, on trace :",
      "choix": [
        "$y$ en fonction de $x$ et on regarde si c''est une droite passant par l''origine",
        "la moyenne des $y$",
        "le plus grand $y$"
      ],
      "bonne": 0,
      "explication": "Une proportionnalité donne une droite passant par l''origine. Si les points s''alignent, le modèle convient."
    },
    {
      "question": "Les points expérimentaux ne tombent jamais exactement sur la droite. C''est :",
      "choix": [
        "une erreur de l''élève",
        "normal, à cause des incertitudes de mesure",
        "la preuve que la loi est fausse"
      ],
      "bonne": 1,
      "explication": "Toute mesure est entachée d''incertitude. On trace la droite qui passe au mieux parmi les points."
    },
    {
      "question": "Dans $PV = nRT$, la température doit être exprimée en :",
      "choix": [
        "degrés Celsius",
        "kelvins",
        "au choix"
      ],
      "bonne": 1,
      "explication": "Les lois des gaz exigent la température absolue, en kelvins, avec $T(\\mathrm{K}) = T(°\\mathrm{C}) + 273$."
    }
  ]
}', NULL, 5)
  ) AS t(titre, typ, contenu, media, duree) LOOP
    IF NOT EXISTS (SELECT 1 FROM public.concepts WHERE chapitre_id = v_chap AND titre = r.titre) THEN
      SELECT coalesce(max(ordre), 0) + 1 INTO v_ordre FROM public.concepts WHERE chapitre_id = v_chap;
      INSERT INTO public.concepts
        (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes)
      VALUES (v_chap, r.titre, v_ordre, r.typ, r.contenu, r.media, r.duree);
      v_ajout := v_ajout + 1;
    END IF;
  END LOOP;
  RAISE NOTICE 'Exemples de modèles utilisés en physique et en chimie : % lecon(s) ajoutee(s).', v_ajout;
END $ph$;

-- ---------------------------------------------------------------------------
-- Contraintes d''une loi
-- ---------------------------------------------------------------------------
DO $ph$
DECLARE
  r record;
  v_chap uuid;
  v_ordre int;
  v_ajout int := 0;
BEGIN
  SELECT c.id INTO v_chap FROM public.chapitres c
  JOIN public.programmes p ON p.id = c.programme_id
  WHERE p.titre = 'Physique — 1ère D' AND c.titre = 'Contraintes d''une loi';

  IF v_chap IS NULL THEN
    RAISE NOTICE 'Chapitre "Contraintes d''une loi" introuvable — ignore.';
    RETURN;
  END IF;

  FOR r IN SELECT * FROM (VALUES
    ('Qu''est-ce que la contrainte d''une loi ?', 'texte', 'Toute loi physique a un domaine où elle marche, et un domaine où elle cesse de marcher. Savoir où s''arrête une loi est aussi important que savoir l''appliquer.

## La contrainte au sens mécanique

Quand un solide subit des forces extérieures, il apparaît à l''intérieur de la matière des efforts de cohésion qui s''opposent à la déformation. Ces efforts internes s''appellent des contraintes.

Prends une barre de section constante $S$, attachée à un bout. Tu tires sur l''autre bout avec une force $F$. La contrainte normale vaut

$$\sigma = \dfrac{F}{S}$$

La force $F$ s''exprime en newtons, la surface $S$ en mètres carrés, et la contrainte $\sigma$ en pascals de symbole Pa, exactement comme une pression.

Si la force est dirigée vers l''extérieur, on parle de traction, ou extension. Si elle est dirigée vers l''intérieur, on parle de compression.

## Un calcul concret

Un tabouret de masse 2,5 kg repose sur le sol par quatre pieds de 6 cm² de section chacun. Une personne de 57,5 kg monte dessus. Quelle pression sur le sol, avec $g = 10$ N/kg ?

La masse totale vaut $M = 2{,}5 + 57{,}5 = 60$ kg, donc le poids vaut $P = 600$ N. La surface totale vaut $4 \times 6 = 24$ cm², soit $24 \times 10^{-4}$ m².

$$\sigma = \dfrac{600}{24 \times 10^{-4}} = 2{,}5 \times 10^{5}\ \mathrm{Pa}$$

## La contrainte au sens du modèle

Dans ce chapitre, le mot contrainte a aussi un second sens, celui de limite de validité. Une loi physique n''est valable que dans certaines conditions, et c''est cela qu''on appelle la contrainte de la loi. Les trois leçons suivantes étudient les contraintes de trois lois que tu connais déjà.

## Exercice d''application

Un câble de section $2{,}0$ mm² supporte une charge de 400 N. Calcule la contrainte en pascals.

Correction. La section vaut $2{,}0$ mm² $= 2{,}0 \times 10^{-6}$ m². Donc $\sigma = \dfrac{400}{2{,}0 \times 10^{-6}} = 2{,}0 \times 10^{8}$ Pa, soit 200 MPa.', NULL, 15),
    ('La contrainte élastique : loi de Hooke et module de Young', 'texte', 'C''est la contrainte la plus parlante, parce qu''on la voit à l''œil nu : au-delà d''une certaine force, le ressort ne revient plus.

## La loi de Hooke pour un ressort

Tant que la déformation reste faible, l''allongement d''un ressort est proportionnel à la force appliquée :

$$F = k \cdot \Delta x$$

où $k$ est la raideur du ressort, en newtons par mètre, et $\Delta x = x - x_{0}$ l''allongement en mètres.

Le graphe de $F$ en fonction de $\Delta x$ est alors une droite passant par l''origine, et sa pente vaut $k$.

L''énergie emmagasinée dans le ressort vaut $E = \dfrac{1}{2}k(\Delta x)^{2}$.

## La contrainte : la limite élastique

La proportionnalité ne dure pas. Au-delà d''une certaine valeur, appelée limite élastique, le graphe cesse d''être une droite. Le ressort se déforme alors de façon permanente : il ne reprend plus sa longueur initiale quand on lâche. On parle de déformation plastique, puis de rupture.

Voilà la contrainte de la loi de Hooke : elle n''est valable que dans le domaine élastique. Un élève qui applique $F = k\Delta x$ à un ressort trop tendu obtient un résultat faux, même si son calcul est juste.

## Le module de Young

Pour un matériau plutôt que pour un ressort, on écrit la même idée autrement. On définit la déformation unitaire $\varepsilon = \dfrac{\Delta \ell}{\ell_{0}}$, qui est sans unité, et on relie la contrainte à la déformation par

$$\sigma = E \cdot \varepsilon$$

Le coefficient $E$ s''appelle le module de Young, et s''exprime en pascals. Il caractérise la rigidité du matériau : plus $E$ est grand, plus le matériau résiste à la déformation. L''acier a un module de Young d''environ $2 \times 10^{11}$ Pa, le bois d''environ $10^{10}$ Pa, le caoutchouc d''environ $10^{7}$ Pa.

## Exercice d''application

Un ressort de raideur $k = 25$ N/m s''allonge de 8 cm. Quelle force a-t-on appliquée ? Quelle énergie est emmagasinée ?

Correction. L''allongement vaut $0{,}08$ m, donc $F = 25 \times 0{,}08 = 2{,}0$ N. L''énergie vaut $E = \dfrac{1}{2} \times 25 \times 0{,}08^{2} = 0{,}5 \times 25 \times 0{,}0064 = 0{,}080$ J.', NULL, 15),
    ('Simulation : jusqu''où la loi de Hooke tient-elle ?', 'interactif', '{
  "widget": "loi-hooke",
  "consigne": "Règle la raideur sur 20 N/m et augmente la force doucement. Tant que le point orange reste sur la partie bleue du graphe, l''allongement est proportionnel à la force et tu peux appliquer $F = k\\Delta x$. Dépasse maintenant le trait rouge : le graphe se courbe, la loi ne s''applique plus, et le ressort restera déformé. C''est exactement ce qu''on appelle la contrainte de cette loi."
}', NULL, 10),
    ('Les contraintes de la loi d''Ohm et de la loi des gaz parfaits', 'texte', 'Deux autres lois que tu utilises sans y penser, et qui ont elles aussi leurs limites.

## La contrainte sur la loi d''Ohm

La loi d''Ohm s''écrit $U = R \cdot I$ pour un conducteur ohmique. La caractéristique $U = f(I)$ est alors une droite passant par l''origine, de pente $R$.

Cette loi suppose deux choses. D''abord que le dipôle est bien un conducteur ohmique : une diode, une lampe à filament ou un générateur ne la vérifient pas, leur caractéristique n''est pas une droite.

Ensuite que la température reste à peu près constante. Or le passage du courant chauffe le conducteur par effet Joule, et la résistance d''un métal augmente avec la température. Si tu fais passer un courant trop fort, $R$ n''est plus constante et la caractéristique se courbe.

C''est pour cela qu''un filament d''ampoule présente une résistance bien plus faible à froid qu''allumé.

## La contrainte sur la loi des gaz parfaits

La loi s''écrit $PV = nRT$, avec $P$ en pascals, $V$ en mètres cubes, $n$ en moles, $T$ en kelvins et $R \approx 8{,}31$ J/(mol·K).

Le modèle du gaz parfait suppose que les molécules sont ponctuelles et qu''elles n''ont aucune interaction entre elles, sauf lors des chocs.

Ces hypothèses tiennent tant que la pression reste faible et la température assez élevée. À forte pression, les molécules sont serrées et leur volume propre n''est plus négligeable. À basse température, les forces d''attraction deviennent importantes et le gaz finit par se liquéfier. Dans ces deux cas, la loi donne des résultats faux.

## Ce qu''il faut retenir

Une loi physique est un modèle, pas une vérité absolue. Avant d''appliquer une formule, demande-toi toujours si tu es bien dans son domaine de validité. C''est la marque d''un bon physicien.

## Exercice d''application

On mesure la caractéristique d''une lampe et on trouve une courbe qui s''incurve vers le haut quand $I$ augmente. Peut-on parler de résistance ?

Correction. On ne peut pas parler d''une résistance unique, car la caractéristique n''est pas une droite : le rapport $\dfrac{U}{I}$ change avec le point de fonctionnement. La lampe n''est pas un conducteur ohmique, parce que son filament s''échauffe et que sa résistance augmente avec la température.', NULL, 15),
    ('Quiz : les contraintes d''une loi', 'quiz', '{
  "titre": "Vérifie que tu as compris",
  "questions": [
    {
      "question": "La contrainte normale $\\sigma$ se calcule par :",
      "choix": [
        "$\\sigma = F \\times S$",
        "$\\sigma = \\dfrac{F}{S}$",
        "$\\sigma = \\dfrac{S}{F}$"
      ],
      "bonne": 1,
      "explication": "C''est une force divisée par une surface, donc elle a la dimension d''une pression et s''exprime en pascals."
    },
    {
      "question": "La loi de Hooke $F = k\\Delta x$ n''est valable que :",
      "choix": [
        "dans le domaine élastique",
        "pour les ressorts en acier",
        "quand la force est verticale"
      ],
      "bonne": 0,
      "explication": "Au-delà de la limite élastique, le graphe n''est plus une droite et le ressort reste déformé."
    },
    {
      "question": "Un matériau à grand module de Young est :",
      "choix": [
        "très souple",
        "très rigide",
        "très léger"
      ],
      "bonne": 1,
      "explication": "$\\sigma = E\\varepsilon$ : à contrainte égale, un grand $E$ donne une petite déformation. L''acier est rigide, le caoutchouc ne l''est pas."
    },
    {
      "question": "La caractéristique d''une lampe à filament n''est pas une droite parce que :",
      "choix": [
        "le courant est alternatif",
        "la résistance change avec la température",
        "la tension est trop faible"
      ],
      "bonne": 1,
      "explication": "L''effet Joule chauffe le filament, et la résistance d''un métal augmente avec la température. La loi d''Ohm suppose au contraire une résistance constante."
    },
    {
      "question": "La loi des gaz parfaits devient fausse :",
      "choix": [
        "à faible pression",
        "à forte pression et basse température",
        "pour l''air seulement"
      ],
      "bonne": 1,
      "explication": "À forte pression les molécules ne sont plus ponctuelles, et à basse température leurs interactions ne sont plus négligeables."
    }
  ]
}', NULL, 5),
    ('Exercices d''entraînement corrigés', 'texte', '## Exercice 1

Un pilier de béton de section carrée de 30 cm de côté supporte une charge de 180 kN. Calcule la contrainte.

Correction. La section vaut $0{,}30 \times 0{,}30 = 0{,}09$ m². La contrainte vaut $\sigma = \dfrac{180 \times 10^{3}}{0{,}09} = 2{,}0 \times 10^{6}$ Pa, soit 2,0 MPa.

## Exercice 2

Un ressort s''allonge de 4,0 cm sous 1,2 N, puis de 8,0 cm sous 2,4 N, puis de 15 cm sous 3,0 N. Jusqu''où la loi de Hooke est-elle vérifiée ?

Correction. Pour les deux premières mesures, $k = \dfrac{1{,}2}{0{,}040} = 30$ N/m et $k = \dfrac{2{,}4}{0{,}080} = 30$ N/m : la loi est vérifiée. Pour la troisième, $k = \dfrac{3{,}0}{0{,}15} = 20$ N/m, ce qui est différent. La limite élastique a donc été dépassée entre 2,4 N et 3,0 N.

## Exercice 3

Un fil d''acier de 2,0 m de long et de section $1{,}0$ mm² s''allonge de 1,0 mm sous une force de 100 N. Calcule le module de Young de l''acier.

Correction. La contrainte vaut $\sigma = \dfrac{100}{1{,}0 \times 10^{-6}} = 1{,}0 \times 10^{8}$ Pa. La déformation vaut $\varepsilon = \dfrac{1{,}0 \times 10^{-3}}{2{,}0} = 5{,}0 \times 10^{-4}$. Donc $E = \dfrac{\sigma}{\varepsilon} = \dfrac{1{,}0 \times 10^{8}}{5{,}0 \times 10^{-4}} = 2{,}0 \times 10^{11}$ Pa.

## Exercice 4

Cite une situation où la loi d''Ohm ne s''applique pas, et explique pourquoi.

Correction. Une diode, par exemple. Sa caractéristique n''est pas une droite : elle ne laisse presque rien passer en dessous d''une tension seuil, puis le courant augmente très vite. Le rapport $\dfrac{U}{I}$ n''est donc pas constant, et parler d''une résistance unique n''aurait pas de sens.', NULL, 15)
  ) AS t(titre, typ, contenu, media, duree) LOOP
    IF NOT EXISTS (SELECT 1 FROM public.concepts WHERE chapitre_id = v_chap AND titre = r.titre) THEN
      SELECT coalesce(max(ordre), 0) + 1 INTO v_ordre FROM public.concepts WHERE chapitre_id = v_chap;
      INSERT INTO public.concepts
        (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes)
      VALUES (v_chap, r.titre, v_ordre, r.typ, r.contenu, r.media, r.duree);
      v_ajout := v_ajout + 1;
    END IF;
  END LOOP;
  RAISE NOTICE 'Contraintes d''une loi : % lecon(s) ajoutee(s).', v_ajout;
END $ph$;
