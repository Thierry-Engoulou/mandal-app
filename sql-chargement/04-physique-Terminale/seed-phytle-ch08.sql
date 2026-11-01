-- ============================================================================
-- MANDAL — Physique Terminale : chapitre 8, Mouvements circulaires uniformes et satellites
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
    WHERE programme_id = v_programme_id AND ordre = 8;

    -- 4. sinon on le cree
    IF v_chapitre_id IS NULL THEN
      INSERT INTO public.chapitres (programme_id, titre, ordre, niveau)
      VALUES (v_programme_id, 'Mouvements circulaires uniformes et satellites', 8, 'Module 2 : Mouvements et interactions, évolutions temporelles des systèmes mécaniques')
      RETURNING id INTO v_chapitre_id;
      RAISE NOTICE '% : chapitre 8 cree.', v_nom;
    END IF;

    -- 5. les lecons
    SELECT count(*) INTO v_deja FROM public.concepts WHERE chapitre_id = v_chapitre_id;
    IF v_deja > 0 THEN
      RAISE NOTICE '% : chapitre 8 contient deja % lecon(s) — aucun ajout.', v_nom, v_deja;
      CONTINUE;
    END IF;

    INSERT INTO public.concepts
      (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes) VALUES
      (v_chapitre_id, 'Le mouvement circulaire uniforme', 1, 'texte', 'Une pierre au bout d''une ficelle qu''on fait tourner avance à vitesse constante, et pourtant elle accélère. Ce paradoxe apparent est au cœur de ce chapitre.

## Les caractéristiques

Un point décrit un cercle de rayon $R$ à vitesse constante $v$.

La **vitesse angulaire** $\omega$ est liée à la vitesse linéaire par
$$v = R\,\omega$$

La **période** $T$ est la durée d''un tour, et la **fréquence** $N$ est le nombre de tours par seconde.
$$T = \dfrac{2\pi}{\omega} = \dfrac{2\pi R}{v} \qquad N = \dfrac{1}{T}$$

## L''accélération centripète

La vitesse est constante en valeur, mais sa **direction** change sans arrêt. Il y a donc bien une accélération.

Dans la base de Frenet, la composante tangentielle $\dfrac{dv}{dt}$ est nulle puisque $v$ est constante. Il ne reste que la composante normale :
$$\vec{a} = \dfrac{v^{2}}{R}\,\vec{u}_{N}$$

Cette accélération est dirigée vers le **centre** du cercle, d''où son nom d''accélération centripète. Sa valeur vaut
$$a = \dfrac{v^{2}}{R} = R\,\omega^{2}$$

## La force centripète

D''après la deuxième loi de Newton, la somme des forces doit elle aussi être dirigée vers le centre, et valoir
$$\sum \vec{F} = m\,\dfrac{v^{2}}{R}\,\vec{u}_{N}$$

Attention, la force centripète n''est pas une force supplémentaire qu''on ajoute au bilan. C''est le **résultat** du bilan des forces réelles. Pour la pierre au bout de la ficelle, c''est la tension du fil. Pour la Lune, c''est la gravitation. Pour une voiture en virage, c''est le frottement des pneus.

Quant à la « force centrifuge » qui te pousse vers l''extérieur en virage, elle n''existe pas dans un référentiel galiléen. C''est ton inertie qui veut continuer tout droit.

## Le pendule conique

Une bille suspendue à un fil de longueur $L$ décrit un cercle horizontal, le fil faisant un angle $\theta$ avec la verticale.

Deux forces agissent : le poids $\vec{P}$ et la tension $\vec{T}$.

Sur la verticale, rien ne bouge, donc $T\cos\theta = mg$.

Sur l''horizontale, la résultante est centripète, donc $T\sin\theta = \dfrac{mv^{2}}{r}$ avec $r = L\sin\theta$.

En divisant membre à membre,
$$\tan\theta = \dfrac{v^{2}}{g\,r}$$

et on en tire la période
$$T_{\text{p}} = 2\pi\sqrt{\dfrac{L\cos\theta}{g}}$$

## Le véhicule dans un virage

Sur une route plane, c''est le frottement latéral $f$ qui fournit la force centripète :
$$f = \dfrac{mv^{2}}{R}$$

Comme le frottement ne peut pas dépasser $f_{\max} = \mu mg$, il existe une vitesse limite
$$v_{\max} = \sqrt{\mu\,g\,R}$$

au-delà de laquelle le véhicule dérape. Elle ne dépend pas de la masse, mais elle dépend du rayon du virage et de l''état de la route. C''est pourquoi on ralentit dans un virage serré, et encore plus quand il pleut.

Sur une route **relevée** d''un angle $\beta$, c''est la composante horizontale de la réaction qui aide, et la vitesse idéale, sans aucun frottement, vaut
$$v = \sqrt{g\,R\,\tan\beta}$$

## Exercice d''application

Un taxi aborde un virage de rayon $R = 50$ m sur une route plane. Le coefficient de frottement vaut $\mu = 0{,}80$ sur route sèche et $0{,}35$ sur route mouillée. Calcule la vitesse maximale dans les deux cas. On prend $g = 10$ m/s².

Correction. Sur route sèche,
$$v_{\max} = \sqrt{0{,}80 \times 10 \times 50} = \sqrt{400} = 20\ \text{m/s}$$
soit $72$ km/h.

Sur route mouillée,
$$v_{\max} = \sqrt{0{,}35 \times 10 \times 50} = \sqrt{175} \approx 13{,}2\ \text{m/s}$$
soit environ $48$ km/h.

La vitesse limite chute de $24$ km/h dès qu''il pleut. Et comme la masse n''intervient pas, un taxi chargé ou vide dérape à la même vitesse.', NULL, 15),
      (v_chapitre_id, 'Satellites et lois de Kepler', 2, 'texte', 'Un satellite ne tombe pas, dit-on. En réalité il tombe en permanence, mais il avance assez vite pour que la Terre se dérobe sous lui à la même cadence.

## Le mouvement circulaire d''un satellite

Soit un satellite de masse $m$ en orbite circulaire de rayon $r$ autour de la Terre, de masse $M_{T}$. Le rayon $r$ se compte depuis le **centre** de la Terre, donc $r = R_{T} + h$.

La seule force est la gravitation, et elle est centripète. On écrit donc
$$\mathcal{G}_{0}\,\dfrac{M_{T}\,m}{r^{2}} = m\,\dfrac{v^{2}}{r}$$

La masse du satellite se simplifie, ce qui est remarquable : un gros satellite et un petit, à la même altitude, vont à la même vitesse.

On en tire la **vitesse orbitale**
$$v = \sqrt{\dfrac{\mathcal{G}_{0}\,M_{T}}{r}}$$

Plus le satellite est haut, plus il va lentement. C''est contre-intuitif, mais c''est ainsi.

## La période de révolution

La période vaut $T = \dfrac{2\pi r}{v}$. En remplaçant $v$,
$$T = 2\pi\sqrt{\dfrac{r^{3}}{\mathcal{G}_{0}\,M_{T}}}$$

En élevant au carré, on obtient la **troisième loi de Kepler** :
$$\dfrac{T^{2}}{r^{3}} = \dfrac{4\pi^{2}}{\mathcal{G}_{0}\,M_{T}} = \text{constante}$$

Cette constante ne dépend que de l''astre central. Elle est la même pour tous les satellites de la Terre, et une autre pour toutes les planètes du Soleil.

## Les trois lois de Kepler

**Première loi.** Chaque planète décrit une ellipse dont le Soleil occupe l''un des foyers. Le cercle est un cas particulier d''ellipse.

**Deuxième loi**, dite loi des aires. Le segment qui joint le Soleil à la planète balaie des aires égales pendant des durées égales. Conséquence : la planète va plus vite quand elle est proche du Soleil.

**Troisième loi.** Le rapport $\dfrac{T^{2}}{a^{3}}$ est le même pour toutes les planètes, où $a$ est le demi-grand axe.

## Le satellite géostationnaire

Un satellite est **géostationnaire** quand il reste à la verticale du même point du sol. C''est ce qu''il faut pour la télévision et les télécommunications : l''antenne parabolique ne bouge jamais.

Trois conditions sont nécessaires. Sa période doit être égale à celle de la rotation de la Terre, soit $T = 23\ \text{h}\ 56\ \text{min} = 86\,164$ s. Il doit tourner dans le même sens que la Terre. Et son orbite doit être dans le **plan équatorial**.

Cette dernière condition est souvent oubliée. Un satellite qui passerait au-dessus de Yaoundé en gardant la même période ne pourrait pas rester fixe, car son orbite croiserait l''équateur.

En appliquant la troisième loi, on trouve $r \approx 42\,200$ km, soit une altitude d''environ $35\,800$ km.

## La vitesse de libération

Pour échapper définitivement à l''attraction terrestre, il faut partir avec une vitesse au moins égale à
$$v_{\text{lib}} = \sqrt{\dfrac{2\,\mathcal{G}_{0}\,M_{T}}{R_{T}}}$$

Pour la Terre, elle vaut environ $11{,}2$ km/s.

## Exercice d''application

Calcule l''altitude d''un satellite géostationnaire. On donne $\mathcal{G}_{0} = 6{,}67 \times 10^{-11}$, $M_{T} = 5{,}97 \times 10^{24}$ kg, $R_{T} = 6\,380$ km et $T = 86\,164$ s.

Correction. On part de $T^{2} = \dfrac{4\pi^{2}r^{3}}{\mathcal{G}_{0}M_{T}}$, d''où
$$r^{3} = \dfrac{\mathcal{G}_{0}\,M_{T}\,T^{2}}{4\pi^{2}}$$

Le produit $\mathcal{G}_{0}M_{T}$ vaut $6{,}67 \times 10^{-11} \times 5{,}97 \times 10^{24} = 3{,}982 \times 10^{14}$.

Le carré de la période vaut $(86\,164)^{2} = 7{,}424 \times 10^{9}$.

Le numérateur vaut donc $3{,}982 \times 10^{14} \times 7{,}424 \times 10^{9} = 2{,}956 \times 10^{24}$.

On divise par $4\pi^{2} = 39{,}48$, ce qui donne $r^{3} = 7{,}488 \times 10^{22}$ m³.

La racine cubique donne $r = 4{,}22 \times 10^{7}$ m, soit $42\,200$ km.

L''altitude vaut donc $h = r - R_{T} = 42\,200 - 6\,380 \approx 35\,800$ km.

C''est bien l''altitude à laquelle se trouvent tous les satellites de télévision qui desservent le Cameroun.', NULL, 15),
      (v_chapitre_id, 'Mets un satellite en orbite', 3, 'interactif', '{
  "widget": "satellite-orbite",
  "consigne": "Change l''altitude du satellite et observe sa vitesse et sa période. Trouve l''altitude pour laquelle la période vaut 24 heures : tu obtiens l''orbite géostationnaire. Vérifie ensuite que le rapport $T^{2}/r^{3}$ reste constant quelle que soit l''altitude."
}', NULL, 10),
      (v_chapitre_id, 'Quiz du chapitre 8', 4, 'quiz', '{
  "titre": "Vérifie que tu as compris",
  "questions": [
    {
      "question": "Un satellite décrit un cercle à vitesse constante. Son accélération est-elle nulle ?",
      "choix": [
        "Oui, puisque la vitesse est constante",
        "Non, elle est dirigée vers le centre",
        "Non, elle est tangente à la trajectoire",
        "Cela dépend de son altitude"
      ],
      "bonne": 1,
      "explication": "La valeur de la vitesse ne change pas, mais sa direction change en permanence. L''accélération, non nulle, est entièrement centripète et vaut $v^2/R$."
    },
    {
      "question": "Deux satellites de masses très différentes sont à la même altitude. Que peut-on dire de leurs vitesses ?",
      "choix": [
        "Le plus lourd va plus vite",
        "Le plus léger va plus vite",
        "Ils ont la même vitesse",
        "Cela dépend de leur forme"
      ],
      "bonne": 2,
      "explication": "En écrivant la deuxième loi de Newton, la masse du satellite se simplifie des deux côtés. La vitesse $v = \\sqrt{\\mathcal{G}_0 M_T/r}$ ne dépend que de la masse de la Terre et du rayon de l''orbite."
    },
    {
      "question": "Quelle condition n''est PAS nécessaire pour qu''un satellite soit géostationnaire ?",
      "choix": [
        "Être dans le plan équatorial",
        "Avoir une période de 24 h environ",
        "Tourner dans le sens de rotation de la Terre",
        "Avoir une masse supérieure à une tonne"
      ],
      "bonne": 3,
      "explication": "La masse du satellite n''intervient nulle part dans les équations du mouvement orbital. Les trois autres conditions, elles, sont indispensables, et l''orbite équatoriale est celle qu''on oublie le plus souvent."
    },
    {
      "question": "On double le rayon d''une orbite circulaire. Que devient la vitesse du satellite ?",
      "choix": [
        "Elle double",
        "Elle est divisée par 2",
        "Elle est divisée par $\\sqrt{2}$",
        "Elle ne change pas"
      ],
      "bonne": 2,
      "explication": "La vitesse vaut $v = \\sqrt{\\mathcal{G}_0 M_T / r}$, donc elle varie en $1/\\sqrt{r}$. Doubler $r$ divise la vitesse par $\\sqrt{2}$, soit environ 1,41. Plus un satellite est haut, plus il va lentement."
    },
    {
      "question": "Une voiture dérape dans un virage. La vitesse limite dépend-elle de sa masse ?",
      "choix": [
        "Oui, une voiture lourde dérape plus tôt",
        "Oui, une voiture lourde dérape plus tard",
        "Non, la masse se simplifie",
        "Seulement sur route mouillée"
      ],
      "bonne": 2,
      "explication": "On écrit $\\mu m g = m v^2/R$, et la masse se simplifie. La vitesse limite $v = \\sqrt{\\mu g R}$ ne dépend que du coefficient de frottement et du rayon du virage."
    }
  ]
}', NULL, 5);

    RAISE NOTICE '% : chapitre 8, Mouvements circulaires uniformes et satellites — 4 lecons ajoutees.', v_nom;
  END LOOP;
END $ptc$;
