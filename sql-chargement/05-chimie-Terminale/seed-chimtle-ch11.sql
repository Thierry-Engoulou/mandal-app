-- ============================================================================
-- MANDAL — Chimie Terminale : chapitre 11, La vitesse des réactions chimiques
-- Module 3 : Cinétique chimique
-- 4 leçons.
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
    WHERE programme_id = v_programme_id AND ordre = 11;

    -- 4. sinon on le cree
    IF v_chapitre_id IS NULL THEN
      INSERT INTO public.chapitres (programme_id, titre, ordre, niveau)
      VALUES (v_programme_id, 'La vitesse des réactions chimiques', 11, 'Module 3 : Cinétique chimique')
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
      (v_chapitre_id, 'Réactions rapides, lentes et très lentes', 1, 'texte', 'Jusqu''ici tu as écrit des équations sans te demander combien de temps la réaction mettait. La cinétique chimique répond précisément à cette question.

## Trois familles

Une réaction est **rapide** quand elle semble terminée dès qu''on mélange les réactifs, en moins d''une seconde. On ne voit pas d''état intermédiaire.

Les réactions acide-base en font partie, comme la neutralisation de la soude par l''acide chlorhydrique. Les précipitations aussi : verse du nitrate d''argent sur du chlorure de sodium, le précipité blanc apparaît instantanément.

Une réaction est **lente** quand son évolution s''observe à l''œil nu, sur des minutes ou des heures. On peut suivre l''avancement, mesurer, tracer une courbe. Ce sont celles qui nous intéressent.

L''estérification, l''oxydation d''un alcool par le permanganate, l''attaque d''un métal par un acide dilué appartiennent à cette famille.

Une réaction est **très lente** quand elle met des mois ou des années. La rouille, le rancissement d''une huile, le vieillissement du caoutchouc.

## Attention à ne pas confondre

Une réaction **totale** n''est pas forcément **rapide**, et une réaction **rapide** n''est pas forcément **totale**. Ce sont deux notions indépendantes.

La thermodynamique dit **jusqu''où** va la réaction. La cinétique dit **en combien de temps** elle y arrive.

L''estérification en est le bon exemple : elle est à la fois lente et limitée. Ajouter un catalyseur la rend rapide, mais toujours limitée au même rendement.

## Comment suivre une réaction lente

Il faut mesurer une grandeur qui change au cours du temps.

Par **dosage**, en prélevant régulièrement un échantillon qu''on titre. C''est précis mais cela consomme le mélange.

Par **conductimétrie**, si les ions présents changent au cours de la réaction.

Par **pH-métrie**, si la réaction consomme ou produit des ions oxonium.

Par **mesure de volume gazeux**, si un gaz se dégage.

Par **spectrophotométrie**, en suivant la couleur, par exemple la décoloration du permanganate.

## La trempe

Voici une technique à connaître. Quand on prélève un échantillon pour le doser, la réaction continue pendant qu''on le titre, ce qui fausse la mesure.

Pour l''arrêter net, on **trempe** l''échantillon : on le verse dans un grand volume d''eau glacée.

Le refroidissement brutal ralentit énormément la réaction, et la dilution écarte les réactifs les uns des autres. On fige ainsi la composition à l''instant du prélèvement.

## Exercice d''application

On veut suivre la réaction entre le zinc en poudre et une solution d''acide chlorhydrique, qui dégage du dihydrogène. Propose une méthode de suivi, et dis si cette réaction est rapide, lente ou très lente.

Correction. La réaction s''écrit
$$\text{Zn} + 2\,\text{H}_{3}\text{O}^{+} \longrightarrow \text{Zn}^{2+} + \text{H}_{2} + 2\,\text{H}_{2}\text{O}$$

Elle dégage un gaz, donc la méthode la plus simple est la **mesure du volume de dihydrogène** recueilli en fonction du temps, par déplacement d''eau dans une éprouvette renversée.

On pourrait aussi suivre la **pH-métrie**, puisque les ions oxonium sont consommés, ou peser le ballon, dont la masse diminue à mesure que le gaz s''échappe.

Avec de l''acide dilué, cette réaction est **lente** : l''effervescence dure plusieurs minutes, ce qui permet de relever des points et de tracer une courbe.

Remarque qu''avec de l''acide concentré et du zinc en poudre fine, elle deviendrait rapide. La même réaction peut donc changer de famille selon les conditions, et c''est tout l''objet du chapitre suivant.', NULL, 15),
      (v_chapitre_id, 'Définir et mesurer une vitesse de réaction', 2, 'texte', 'Dire qu''une réaction est lente ne suffit pas. Il faut un nombre, et ce nombre se lit sur une courbe.

## La vitesse de formation d''un produit

La **vitesse volumique de formation** d''un produit $P$ est l''augmentation de sa concentration par unité de temps :
$$v = \dfrac{d[P]}{dt}$$

Elle s''exprime en $\text{mol}\cdot\text{L}^{-1}\cdot\text{s}^{-1}$.

Si l''on travaille en quantité de matière plutôt qu''en concentration, on parle de vitesse de formation tout court, $v = \dfrac{dn_{P}}{dt}$, en $\text{mol}\cdot\text{s}^{-1}$.

## La vitesse de disparition d''un réactif

Pour un réactif $R$, la concentration **diminue**, donc la dérivée est négative. Comme une vitesse doit être positive, on met un signe moins :
$$v = -\dfrac{d[R]}{dt}$$

C''est l''erreur de signe la plus fréquente, surveille-la.

## Le lien avec les coefficients

Pour une réaction $a\,\text{A} + b\,\text{B} \longrightarrow c\,\text{C}$, les vitesses des différentes espèces ne sont pas égales, mais proportionnelles aux coefficients :
$$\dfrac{1}{a}\left(-\dfrac{d[\text{A}]}{dt}\right) = \dfrac{1}{b}\left(-\dfrac{d[\text{B}]}{dt}\right) = \dfrac{1}{c}\,\dfrac{d[\text{C}]}{dt}$$

Si une réaction consomme deux moles de $\text{A}$ pour produire une mole de $\text{C}$, alors $\text{A}$ disparaît deux fois plus vite que $\text{C}$ n''apparaît.

## La méthode des tangentes

C''est la technique à maîtriser, et elle tombe à chaque examen.

La vitesse à un instant $t$ est le **coefficient directeur de la tangente** à la courbe en ce point.

Tu traces la tangente à la courbe au point considéré, le plus soigneusement possible. Tu choisis deux points **éloignés** sur cette tangente, pour réduire l''imprécision. Tu lis leurs coordonnées et tu calcules
$$v = \dfrac{y_{2} - y_{1}}{t_{2} - t_{1}}$$

Sans oublier les unités, et le signe moins s''il s''agit d''un réactif.

## L''évolution de la vitesse

Regarde n''importe quelle courbe d''avancement : elle est raide au début, puis s''aplatit.

La vitesse est donc **maximale à l''instant initial**, et elle **diminue** continuellement.

La raison est simple : les réactifs se raréfient, les chocs efficaces deviennent moins fréquents. Quand la courbe devient horizontale, la vitesse est nulle et la réaction est terminée, ou bien l''équilibre est atteint.

## Le temps de demi-réaction

Le **temps de demi-réaction** $t_{1/2}$ est la durée au bout de laquelle la réaction a parcouru la moitié de son évolution.

Si la réaction est totale, c''est le temps où la moitié du réactif limitant a été consommée.

C''est un bon indicateur de rapidité : plus $t_{1/2}$ est court, plus la réaction est rapide. On s''en sert pour comparer deux expériences, par exemple à deux températures différentes.

## Exercice d''application

On suit la formation d''un ester. À $t = 0$ la concentration est nulle, et on relève les valeurs suivantes.

À $t = 10$ h, $[\text{E}] = 0{,}25\ \text{mol}\cdot\text{L}^{-1}$. À $t = 20$ h, $0{,}40$. À $t = 40$ h, $0{,}56$. À $t = 80$ h, $0{,}65$. À $t = 160$ h, $0{,}67$.

La concentration finale est de $0{,}67\ \text{mol}\cdot\text{L}^{-1}$. Détermine le temps de demi-réaction et estime la vitesse moyenne sur les dix premières heures.

Correction. La réaction est limitée, et sa valeur finale est $0{,}67\ \text{mol}\cdot\text{L}^{-1}$. La demi-réaction correspond donc à
$$\dfrac{0{,}67}{2} = 0{,}335\ \text{mol}\cdot\text{L}^{-1}$$

En regardant le tableau, cette valeur est atteinte entre $t = 10$ h, où l''on a $0{,}25$, et $t = 20$ h, où l''on a $0{,}40$.

Par interpolation linéaire entre ces deux points :
$$t_{1/2} \approx 10 + 10 \times \dfrac{0{,}335 - 0{,}25}{0{,}40 - 0{,}25} = 10 + 10 \times \dfrac{0{,}085}{0{,}15} \approx 15{,}7\ \text{h}$$

Le temps de demi-réaction vaut donc environ **16 heures**.

La vitesse moyenne sur les dix premières heures vaut
$$v_{\text{moy}} = \dfrac{0{,}25 - 0}{10 - 0} = 2{,}5 \times 10^{-2}\ \text{mol}\cdot\text{L}^{-1}\cdot\text{h}^{-1}$$

Compare avec la vitesse moyenne entre $80$ et $160$ h :
$$v_{\text{moy}} = \dfrac{0{,}67 - 0{,}65}{80} = 2{,}5 \times 10^{-4}\ \text{mol}\cdot\text{L}^{-1}\cdot\text{h}^{-1}$$

La réaction est donc devenue **cent fois plus lente**. C''est exactement ce que montre l''aplatissement de la courbe.', NULL, 15),
      (v_chapitre_id, 'Mesure une vitesse à la tangente', 3, 'interactif', '{
  "widget": "vitesse-reaction",
  "consigne": "Déplace le point de lecture sur la courbe et regarde la tangente suivre. Lis la vitesse à l''instant choisi. Compare la vitesse à t = 0 et à la fin : de combien a-t-elle chuté ? Place ensuite le temps de demi-réaction."
}', NULL, 10),
      (v_chapitre_id, 'Quiz du chapitre 11', 4, 'quiz', '{
  "titre": "Vérifie que tu as compris",
  "questions": [
    {
      "question": "Comment définit-on la vitesse de disparition d''un réactif ?",
      "choix": [
        "$v = \\dfrac{d[R]}{dt}$",
        "$v = -\\dfrac{d[R]}{dt}$",
        "$v = [R] \\times t$",
        "$v = \\dfrac{[R]}{t}$"
      ],
      "bonne": 1,
      "explication": "La concentration d''un réactif diminue, donc sa dérivée est négative. Le signe moins rend la vitesse positive, comme toute vitesse doit l''être."
    },
    {
      "question": "Comment lit-on la vitesse à un instant donné sur une courbe de concentration ?",
      "choix": [
        "En lisant l''ordonnée",
        "En traçant la tangente et en calculant son coefficient directeur",
        "En divisant par le temps total",
        "En mesurant l''aire sous la courbe"
      ],
      "bonne": 1,
      "explication": "La vitesse instantanée est la dérivée, donc le coefficient directeur de la tangente au point considéré. On choisit deux points éloignés sur la tangente pour limiter l''imprécision de lecture."
    },
    {
      "question": "À quel moment la vitesse d''une réaction est-elle maximale ?",
      "choix": [
        "À la fin",
        "Au milieu",
        "À l''instant initial",
        "Elle est constante"
      ],
      "bonne": 2,
      "explication": "Au départ les réactifs sont les plus concentrés, donc les chocs efficaces les plus fréquents. Ensuite les réactifs se raréfient et la vitesse diminue sans cesse."
    },
    {
      "question": "Une réaction rapide est-elle forcément totale ?",
      "choix": [
        "Oui, toujours",
        "Non, les deux notions sont indépendantes",
        "Seulement en solution aqueuse",
        "Seulement à chaud"
      ],
      "bonne": 1,
      "explication": "La cinétique dit en combien de temps on arrive à l''état final, la thermodynamique dit où se trouve cet état final. L''estérification catalysée est rapide et pourtant limitée à 67 %."
    },
    {
      "question": "À quoi sert la trempe lors d''un suivi cinétique ?",
      "choix": [
        "À accélérer la réaction",
        "À figer la composition de l''échantillon prélevé",
        "À mesurer la température",
        "À dissoudre le catalyseur"
      ],
      "bonne": 1,
      "explication": "On verse le prélèvement dans de l''eau glacée. Le froid ralentit la réaction et la dilution écarte les réactifs, ce qui bloque l''évolution pendant qu''on fait le dosage."
    }
  ]
}', NULL, 5);

    RAISE NOTICE '% : chapitre 11, La vitesse des réactions chimiques — 4 lecons ajoutees.', v_nom;
  END LOOP;
END $chi$;
