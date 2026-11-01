-- ============================================================================
-- MANDAL — Mathématiques 3ème : chapitre 11, Polygones réguliers
-- 6 leçons.
--
-- Autonome : ce fichier cree lui-meme le programme et le chapitre s'ils
-- n'existent pas encore. Vous pouvez le lancer seul, dans n'importe quel ordre.
-- Idempotent : si le chapitre contient deja des lecons, rien n'est ajoute.
-- ============================================================================
DO $m3$
DECLARE
  v_matiere_id uuid;
  v_classe_id uuid;
  v_etab_id uuid;
  v_programme_id uuid;
  v_chapitre_id uuid;
  v_nb_etabs int;
  v_deja int;
BEGIN
  -- 1. le programme existe-t-il deja ?
  SELECT p.id INTO v_programme_id FROM public.programmes p
  WHERE p.titre = 'Mathématiques — 3ème';

  -- 2. sinon on le cree
  IF v_programme_id IS NULL THEN
    INSERT INTO public.matieres (nom) VALUES ('Mathématiques') ON CONFLICT (nom) DO NOTHING;
    SELECT id INTO v_matiere_id FROM public.matieres WHERE nom = 'Mathématiques';

    SELECT count(DISTINCT etablissement_id) INTO v_nb_etabs FROM public.classes;
    IF v_nb_etabs <> 1 THEN
      RAISE EXCEPTION 'Impossible de deduire l''etablissement : % etablissement(s) distinct(s) dans public.classes.', v_nb_etabs;
    END IF;
    SELECT etablissement_id INTO v_etab_id FROM public.classes LIMIT 1;

    SELECT id INTO v_classe_id FROM public.classes
    WHERE nom = '3ème' AND etablissement_id = v_etab_id LIMIT 1;
    IF v_classe_id IS NULL THEN
      RAISE EXCEPTION 'Classe "3ème" introuvable dans public.classes.';
    END IF;

    INSERT INTO public.programmes (matiere_id, classe_id, etablissement_id, titre, description)
    VALUES (v_matiere_id, v_classe_id, v_etab_id, 'Mathématiques — 3ème',
            'Programme de Mathématiques, classe de 3ème (BEPC) — 4 modules, 16 chapitres.')
    RETURNING id INTO v_programme_id;
    RAISE NOTICE 'Programme "Mathématiques — 3ème" cree.';
  END IF;

  -- 3. le chapitre existe-t-il deja ?
  SELECT id INTO v_chapitre_id FROM public.chapitres
  WHERE programme_id = v_programme_id AND ordre = 11;

  -- 4. sinon on le cree
  IF v_chapitre_id IS NULL THEN
    INSERT INTO public.chapitres (programme_id, titre, ordre, niveau)
    VALUES (v_programme_id, 'Polygones réguliers', 11, 'Module 15 : Configurations et transformations élémentaires du plan')
    RETURNING id INTO v_chapitre_id;
    RAISE NOTICE 'Chapitre 11 cree.';
  END IF;

  -- 5. les lecons
  SELECT count(*) INTO v_deja FROM public.concepts WHERE chapitre_id = v_chapitre_id;
  IF v_deja > 0 THEN
    RAISE NOTICE 'Chapitre 11 : contient deja % lecon(s) — aucun ajout.', v_deja;
    RETURN;
  END IF;

  INSERT INTO public.concepts
    (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes) VALUES
    (v_chapitre_id, 'Qu''est-ce qu''un polygone régulier ?', 1, 'texte', 'Les carreaux au sol, les écrous de boulon, les panneaux de signalisation, les ballons : les polygones réguliers sont partout. Ils ont une définition très simple.

## Définition

Un polygone est régulier lorsque tous ses côtés ont la même longueur et tous ses angles la même mesure.

Un polygone régulier à $n$ côtés est toujours inscriptible dans un cercle, appelé cercle circonscrit, dont le centre $O$ est aussi le centre du polygone.

## Les angles

L''angle au centre est l''angle sous lequel on voit un côté depuis le centre. Comme les $n$ côtés se partagent le tour complet,

$$\text{angle au centre} = \dfrac{360°}{n}$$

L''angle intérieur est l''angle formé par deux côtés consécutifs. Il vaut

$$\text{angle intérieur} = \dfrac{(n-2) \times 180°}{n}$$

## Quelques valeurs à connaître

Pour le triangle équilatéral, $n = 3$ : angle au centre 120°, angle intérieur 60°.

Pour le carré, $n = 4$ : angle au centre 90°, angle intérieur 90°.

Pour le pentagone régulier, $n = 5$ : angle au centre 72°, angle intérieur 108°.

Pour l''hexagone régulier, $n = 6$ : angle au centre 60°, angle intérieur 120°.

Pour l''octogone régulier, $n = 8$ : angle au centre 45°, angle intérieur 135°.

## Une remarque sur l''hexagone

Avec un angle au centre de 60° et deux rayons égaux, chacun des six triangles de l''hexagone régulier est équilatéral. Le côté de l''hexagone est donc égal au rayon du cercle. C''est pour cela qu''on construit facilement un hexagone régulier au compas, en reportant six fois le rayon sur le cercle.

## Exercice d''application

Calcule l''angle au centre et l''angle intérieur d''un décagone régulier, qui a 10 côtés.

Correction. L''angle au centre vaut $\dfrac{360}{10} = 36°$. L''angle intérieur vaut $\dfrac{(10-2) \times 180}{10} = \dfrac{1\,440}{10} = 144°$.', NULL, 15),
    (v_chapitre_id, 'Construire et mesurer un polygone régulier', 2, 'texte', 'Pour construire, tu pars du cercle. Pour mesurer, tu pars du triangle élémentaire.

## La construction au rapporteur

Trace un cercle de centre $O$ et de rayon $R$. Place un premier point $A$ sur le cercle. Depuis $O$, reporte l''angle au centre $\dfrac{360°}{n}$ pour obtenir le point suivant, et recommence $n$ fois. Il ne reste qu''à relier les points.

Pour l''hexagone, inutile de rapporteur : reporte simplement six fois le rayon au compas.

## L''apothème

L''apothème est la distance du centre au milieu d''un côté. C''est aussi la hauteur du triangle élémentaire formé par le centre et un côté.

Le triangle $OAB$ formé par le centre et un côté est isocèle. En le coupant en deux par l''apothème, on obtient un triangle rectangle d''angle $\dfrac{180°}{n}$ au centre, de côté opposé $\dfrac{c}{2}$ et d''hypoténuse $R$.

La trigonométrie donne alors

$$c = 2R \sin\left(\dfrac{180°}{n}\right) \qquad \text{et} \qquad a = R \cos\left(\dfrac{180°}{n}\right)$$

où $c$ est le côté et $a$ l''apothème.

## L''aire

Le polygone se découpe en $n$ triangles identiques, chacun d''aire $\dfrac{c \times a}{2}$. L''aire totale vaut donc

$$\mathcal{A} = \dfrac{n \times c \times a}{2} = \dfrac{P \times a}{2}$$

où $P = n \times c$ est le périmètre. Retiens cette formule simple : périmètre multiplié par l''apothème, divisé par deux.

## Un exemple

Un hexagone régulier est inscrit dans un cercle de rayon 4 cm. Son côté vaut 4 cm, comme on l''a vu. Son apothème vaut $a = 4 \times \cos 30° \approx 4 \times 0{,}866 = 3{,}46$ cm. Son périmètre vaut $6 \times 4 = 24$ cm. Son aire vaut donc $\dfrac{24 \times 3{,}46}{2} \approx 41{,}5$ cm².

## Exercice d''application

Un carré est inscrit dans un cercle de rayon 5 cm. Calcule son côté, son apothème et son aire.

Correction. Le côté vaut $c = 2 \times 5 \times \sin 45° \approx 10 \times 0{,}707 = 7{,}07$ cm. L''apothème vaut $a = 5 \times \cos 45° \approx 3{,}54$ cm. Le périmètre vaut $4 \times 7{,}07 = 28{,}28$ cm, donc l''aire vaut $\dfrac{28{,}28 \times 3{,}54}{2} \approx 50$ cm². On peut vérifier autrement : l''aire du carré vaut $c^{2} = 7{,}07^{2} \approx 50$ cm².', NULL, 15),
    (v_chapitre_id, 'Simulation : de 3 à 12 côtés', 3, 'interactif', '{
  "widget": "polygones-reguliers",
  "consigne": "Commence avec $n = 3$ et lis l''angle au centre, 120°. Monte à 6 : l''angle au centre tombe à 60°, et tu vois que le côté rouge devient égal au rayon, ce qui explique la construction de l''hexagone au compas. Continue jusqu''à 12 et regarde le polygone se coller au cercle. Compare à chaque fois le périmètre affiché avec la circonférence du cercle, qui vaut environ $6{,}28 \\times R$."
}', NULL, 10),
    (v_chapitre_id, 'Quiz : polygones réguliers', 4, 'quiz', '{
  "titre": "Vérifie que tu as compris",
  "questions": [
    {
      "question": "L''angle au centre d''un pentagone régulier mesure :",
      "choix": [
        "$60°$",
        "$72°$",
        "$108°$"
      ],
      "bonne": 1,
      "explication": "$\\dfrac{360}{5} = 72°$. C''est 108° qui est l''angle intérieur."
    },
    {
      "question": "Dans un hexagone régulier inscrit dans un cercle de rayon $R$, le côté vaut :",
      "choix": [
        "$R$",
        "$2R$",
        "$R\\sqrt{2}$"
      ],
      "bonne": 0,
      "explication": "Chacun des six triangles est équilatéral, donc le côté est égal au rayon."
    },
    {
      "question": "L''aire d''un polygone régulier se calcule par :",
      "choix": [
        "périmètre fois apothème",
        "périmètre fois apothème divisé par 2",
        "côté au carré"
      ],
      "bonne": 1,
      "explication": "On découpe le polygone en triangles, ce qui donne $\\mathcal{A} = \\dfrac{P \\times a}{2}$."
    },
    {
      "question": "L''angle intérieur d''un octogone régulier mesure :",
      "choix": [
        "$45°$",
        "$135°$",
        "$120°$"
      ],
      "bonne": 1,
      "explication": "$\\dfrac{(8-2) \\times 180}{8} = \\dfrac{1\\,080}{8} = 135°$."
    }
  ]
}', NULL, 5),
    (v_chapitre_id, 'Exercices d''entraînement corrigés', 5, 'texte', '## Exercice 1

Un polygone régulier a un angle au centre de 24°. Combien a-t-il de côtés ? Quel est son angle intérieur ?

Correction. De $\dfrac{360}{n} = 24$ on tire $n = \dfrac{360}{24} = 15$ côtés. L''angle intérieur vaut $\dfrac{(15-2) \times 180}{15} = \dfrac{2\,340}{15} = 156°$.

## Exercice 2

Un triangle équilatéral est inscrit dans un cercle de rayon 6 cm. Calcule son côté et son aire.

Correction. Le côté vaut $c = 2 \times 6 \times \sin 60° \approx 12 \times 0{,}866 = 10{,}39$ cm. L''apothème vaut $a = 6 \times \cos 60° = 3$ cm. Le périmètre vaut $3 \times 10{,}39 = 31{,}18$ cm, donc l''aire vaut $\dfrac{31{,}18 \times 3}{2} \approx 46{,}8$ cm².

## Exercice 3

Un écrou a la forme d''un hexagone régulier de 12 mm de côté. Calcule son aire.

Correction. Pour un hexagone, le rayon égale le côté, soit 12 mm. L''apothème vaut $12 \times \cos 30° \approx 10{,}39$ mm. Le périmètre vaut $6 \times 12 = 72$ mm. L''aire vaut $\dfrac{72 \times 10{,}39}{2} \approx 374$ mm².

## Exercice 4

On veut carreler une terrasse avec des dalles en forme de polygone régulier, sans laisser de trou. Explique pourquoi le pentagone régulier ne convient pas, alors que l''hexagone convient.

Correction. Autour d''un point, les angles doivent totaliser exactement 360°. Pour l''hexagone, l''angle intérieur vaut 120° et $3 \times 120 = 360$, donc trois dalles se rejoignent parfaitement. Pour le pentagone, l''angle intérieur vaut 108°, et $3 \times 108 = 324$ tandis que $4 \times 108 = 432$. Aucun nombre entier de dalles ne donne 360°, il resterait donc des trous.', NULL, 15),
    (v_chapitre_id, 'Activité d''intégration : le kiosque du marché', 6, 'texte', '## La situation

La commune de Foumban veut construire un kiosque de marché en forme d''octogone régulier, inscrit dans un cercle de 3 m de rayon.

Le sol sera carrelé, à 6 500 FCFA le mètre carré. Le tour sera entouré d''une petite murette, à 12 000 FCFA le mètre.

1. Calcule la longueur d''un côté de l''octogone, arrondie au centimètre.
2. Calcule l''apothème, puis l''aire du kiosque.
3. Donne le coût du carrelage et celui de la murette.
4. Un conseiller propose un hexagone régulier dans le même cercle, en disant que ce sera moins cher. A-t-il raison ? De combien ?

## La solution

1. Pour un octogone, $n = 8$ et $\dfrac{180}{8} = 22{,}5$. Le côté vaut
$$c = 2 \times 3 \times \sin 22{,}5° \approx 6 \times 0{,}3827 = 2{,}30 \text{ m}$$

2. L''apothème vaut $a = 3 \times \cos 22{,}5° \approx 3 \times 0{,}9239 = 2{,}77$ m. Le périmètre vaut $8 \times 2{,}30 = 18{,}40$ m. L''aire vaut donc
$$\mathcal{A} = \dfrac{18{,}40 \times 2{,}77}{2} \approx 25{,}48 \text{ m}^{2}$$

3. Le carrelage coûte $25{,}48 \times 6\,500 \approx 165\,620$ FCFA. La murette coûte $18{,}40 \times 12\,000 = 220\,800$ FCFA. Le total s''élève à environ 386 420 FCFA.

4. Pour l''hexagone dans le même cercle, le côté vaut 3 m, le périmètre 18 m et l''apothème $3 \times \cos 30° \approx 2{,}60$ m. L''aire vaut $\dfrac{18 \times 2{,}60}{2} = 23{,}40$ m². Le carrelage coûterait $23{,}40 \times 6\,500 = 152\,100$ FCFA et la murette $18 \times 12\,000 = 216\,000$ FCFA, soit 368 100 FCFA au total.

Le conseiller a raison, l''hexagone coûte environ 18 320 FCFA de moins. Mais il faut dire aussi ce qu''on perd : la surface utile tombe de 25,5 à 23,4 m², soit environ 2 m² de marchandise en moins. À la commune de décider ce qui compte le plus.

## Ce qu''il faut remarquer

Dans le même cercle, plus le polygone a de côtés, plus son aire se rapproche de celle du disque, qui vaut ici $\pi \times 3^{2} \approx 28{,}3$ m². L''octogone en récupère déjà 90 %, l''hexagone seulement 83 %.', NULL, 15);

  RAISE NOTICE 'Chapitre 11, Polygones réguliers : 6 lecons ajoutees.';
END $m3$;
