-- ============================================================================
-- MANDAL — Physique Terminale : chapitre 5, Forces et champs magnétiques
-- Module 2 : Mouvements et interactions, évolutions temporelles des systèmes mécaniques
-- 6 leçons.
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
    WHERE programme_id = v_programme_id AND ordre = 5;

    -- 4. sinon on le cree
    IF v_chapitre_id IS NULL THEN
      INSERT INTO public.chapitres (programme_id, titre, ordre, niveau)
      VALUES (v_programme_id, 'Forces et champs magnétiques', 5, 'Module 2 : Mouvements et interactions, évolutions temporelles des systèmes mécaniques')
      RETURNING id INTO v_chapitre_id;
      RAISE NOTICE '% : chapitre 5 cree.', v_nom;
    END IF;

    -- 5. les lecons
    SELECT count(*) INTO v_deja FROM public.concepts WHERE chapitre_id = v_chapitre_id;
    IF v_deja > 0 THEN
      RAISE NOTICE '% : chapitre 5 contient deja % lecon(s) — aucun ajout.', v_nom, v_deja;
      CONTINUE;
    END IF;

    INSERT INTO public.concepts
      (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes) VALUES
      (v_chapitre_id, 'Le champ magnétique', 1, 'texte', 'Approche une boussole d''un aimant droit : l''aiguille tourne et s''oriente. Il se passe quelque chose dans l''espace autour de l''aimant, même si on ne voit rien. Ce quelque chose, c''est le champ magnétique.

## Les sources de champ magnétique

Un champ magnétique est créé par deux choses, et deux seulement.

Les **aimants**, qu''ils soient naturels comme la magnétite, ou fabriqués.

Les **courants électriques**. Un fil parcouru par un courant crée un champ magnétique autour de lui. C''est Œrsted qui l''a découvert en 1820, en remarquant qu''une boussole déviait près d''un fil conducteur.

En réalité ces deux sources n''en font qu''une, car le magnétisme d''un aimant vient des courants microscopiques créés par les électrons dans ses atomes.

## Les caractéristiques du vecteur champ magnétique

Le champ magnétique est un vecteur, noté $\vec{B}$.

Sa **direction** est celle que prend l''axe d''une petite boussole placée en ce point.

Son **sens** est celui qui va du sud vers le nord de cette aiguille, c''est-à-dire le sens indiqué par la pointe de l''aiguille.

Sa **valeur** se mesure en teslas, symbole T. Le tesla est une grande unité : le champ magnétique terrestre vaut environ $5 \times 10^{-5}$ T, un aimant de haut-parleur environ $0{,}1$ T, et un appareil d''IRM d''hôpital entre $1$ et $3$ T.

On mesure $B$ avec un teslamètre, muni d''une sonde à effet Hall.

## Les lignes de champ et le spectre magnétique

Comme pour les autres champs, une ligne de champ est tangente en chacun de ses points au vecteur $\vec{B}$.

Si tu saupoudres de la limaille de fer sur une feuille posée sur un aimant, les grains s''alignent le long des lignes de champ. La figure obtenue s''appelle le **spectre magnétique**.

Par convention, les lignes de champ sortent par le pôle nord de l''aimant et rentrent par le pôle sud. À l''intérieur de l''aimant, elles vont du sud vers le nord, et elles se referment donc sur elles-mêmes. C''est une différence avec le champ électrique, dont les lignes partent des charges positives et s''arrêtent sur les négatives.

## Les pôles et leur interaction

Tout aimant possède deux pôles, un nord et un sud. On ne peut pas les séparer. Si tu casses un aimant en deux, tu obtiens deux aimants complets, chacun avec son nord et son sud. Il n''existe pas de pôle magnétique isolé.

Deux pôles de même nom se repoussent, deux pôles de noms contraires s''attirent. Comme pour les charges électriques.

## Le champ magnétique terrestre

La Terre se comporte comme un gigantesque aimant. Son champ est faible mais il suffit à orienter une boussole.

Attention au piège de vocabulaire. L''aiguille d''une boussole pointe vers le nord géographique, donc d''après la règle précédente, c''est un pôle **sud** magnétique qui se trouve près du nord géographique.

Au Cameroun, le champ terrestre fait un petit angle avec l''horizontale, appelé inclinaison, et un petit angle avec le nord géographique, appelé déclinaison.

## Exercice d''application

On place une petite boussole près d''un fil vertical parcouru par un courant. Avant de fermer le circuit, l''aiguille indique le nord. On ferme le circuit et l''aiguille tourne de $45°$. Que peut-on en déduire sur la valeur du champ créé par le fil ? On donne $B_{\text{terre}} = 2{,}0 \times 10^{-5}$ T pour la composante horizontale.

Correction. L''aiguille s''oriente selon le champ **total**, somme du champ terrestre et du champ du fil.

Le champ créé par le fil est perpendiculaire au champ terrestre horizontal, comme le montre l''expérience d''Œrsted.

Les deux champs étant perpendiculaires, l''angle $\alpha$ de déviation vérifie
$$\tan\alpha = \dfrac{B_{\text{fil}}}{B_{\text{terre}}}$$

Avec $\alpha = 45°$, on a $\tan 45° = 1$, donc $B_{\text{fil}} = B_{\text{terre}} = 2{,}0 \times 10^{-5}$ T.

Les deux champs ont la même valeur. C''est d''ailleurs la méthode utilisée pour mesurer un champ magnétique faible avec une simple boussole.', NULL, 15),
      (v_chapitre_id, 'Le spectre magnétique d''un aimant droit', 2, 'figure', '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 520 300" width="520" height="300">
  <rect width="520" height="300" fill="#ffffff"/>
  <text x="260" y="26" font-family="Georgia, serif" font-size="16" text-anchor="middle" fill="#1f2937">Spectre magnétique d''un aimant droit</text>
  <rect x="200" y="135" width="60" height="30" fill="#dc2626"/>
  <rect x="260" y="135" width="60" height="30" fill="#1d4ed8"/>
  <text x="230" y="156" font-family="Georgia, serif" font-size="16" text-anchor="middle" fill="#ffffff">N</text>
  <text x="290" y="156" font-family="Georgia, serif" font-size="16" text-anchor="middle" fill="#ffffff">S</text>
  <g fill="none" stroke="#374151" stroke-width="1.6">
    <path d="M200 142 C 140 100, 140 60, 260 60 C 380 60, 380 100, 320 142"/>
    <path d="M200 148 C 120 120, 120 40, 260 40 C 400 40, 400 120, 320 148"/>
    <path d="M200 158 C 140 200, 140 240, 260 240 C 380 240, 380 200, 320 158"/>
    <path d="M200 152 C 120 180, 120 260, 260 260 C 400 260, 400 180, 320 152"/>
    <path d="M196 150 L 90 150"/>
    <path d="M324 150 L 430 150"/>
  </g>
  <g fill="#374151">
    <polygon points="258,57 268,60 258,63"/>
    <polygon points="258,37 268,40 258,43"/>
    <polygon points="252,237 262,240 252,243"/>
    <polygon points="252,257 262,260 252,263"/>
    <polygon points="140,147 130,150 140,153"/>
    <polygon points="390,147 380,150 390,153"/>
  </g>
  <text x="260" y="286" font-family="Georgia, serif" font-size="13" text-anchor="middle" fill="#4b5563">Les lignes sortent du pôle nord et entrent par le pôle sud.</text>
</svg>', NULL, 5),
      (v_chapitre_id, 'La force de Laplace', 3, 'texte', 'Place un fil conducteur dans un champ magnétique et fais-y passer un courant. Le fil bouge. Cette force qui apparaît s''appelle la force de Laplace, et c''est elle qui fait tourner tous les moteurs électriques du monde.

## La mise en évidence

Prends deux rails horizontaux reliés à un générateur, et pose dessus une tige conductrice mobile. Place l''ensemble entre les branches d''un aimant en U, de sorte que le champ $\vec{B}$ soit vertical.

Dès que le courant passe, la tige se met à rouler le long des rails. Si tu inverses le sens du courant, elle part dans l''autre sens. Si tu retournes l''aimant, elle change aussi de sens.

## La loi de Laplace

Un élément de conducteur de longueur $\ell$, parcouru par un courant d''intensité $I$ et placé dans un champ $\vec{B}$, subit la force
$$\vec{F} = I\,\vec{\ell} \wedge \vec{B}$$

Le vecteur $\vec{\ell}$ a pour longueur celle de la partie du conducteur qui baigne dans le champ, et il est orienté dans le sens du courant.

La valeur de la force vaut
$$F = B\,I\,\ell\,\sin\alpha$$
où $\alpha$ est l''angle entre $\vec{\ell}$ et $\vec{B}$.

## Les cas particuliers à retenir

Si le fil est **perpendiculaire** au champ, alors $\alpha = 90°$ et $\sin\alpha = 1$. La force est maximale et vaut simplement
$$F = B\,I\,\ell$$

Si le fil est **parallèle** au champ, alors $\alpha = 0$ et $\sin\alpha = 0$. La force est nulle. Un fil placé dans le sens du champ ne subit rien.

## La direction et le sens

La force de Laplace est toujours **perpendiculaire au plan** formé par le fil et le champ.

Pour trouver son sens, utilise la règle des trois doigts de la main droite. Le pouce indique le courant $I$, l''index indique le champ $\vec{B}$, et le majeur donne alors la force $\vec{F}$. Les trois doigts doivent être tendus perpendiculairement entre eux.

Tu peux aussi utiliser la règle de la main droite : les doigts pointent dans le sens de $I$, tu les rabats vers $\vec{B}$, et le pouce donne $\vec{F}$.

## Les applications

Le **moteur électrique** est l''application reine. Un cadre parcouru par un courant est placé dans un champ magnétique. Les forces de Laplace sur les deux côtés du cadre sont opposées, ce qui crée un couple qui fait tourner le cadre.

Le **haut-parleur** fonctionne de la même façon. Une bobine solidaire de la membrane est placée dans l''entrefer d''un aimant. Le courant du signal audio la fait vibrer, et la membrane pousse l''air.

Le **rail électromagnétique**, les galvanomètres à cadre mobile, les disjoncteurs magnétiques utilisent tous cette force.

## Exercice d''application

Une tige de cuivre de $12$ cm de long, parcourue par un courant de $3{,}0$ A, est placée perpendiculairement à un champ magnétique de $0{,}25$ T. Calcule la force de Laplace. Que devient cette force si on incline la tige à $30°$ du champ ?

Correction. Pour la position perpendiculaire,
$$F = B\,I\,\ell = 0{,}25 \times 3{,}0 \times 0{,}12 = 0{,}090\ \text{N}$$

Soit $90$ mN, ce qui est faible mais largement suffisant pour faire bouger une tige légère.

Pour la tige inclinée à $30°$,
$$F = B\,I\,\ell\,\sin 30° = 0{,}090 \times 0{,}5 = 0{,}045\ \text{N}$$

La force est divisée par deux. Elle serait nulle si la tige était placée exactement dans la direction du champ.', NULL, 15),
      (v_chapitre_id, 'Oriente la force de Laplace', 4, 'interactif', '{
  "widget": "force-laplace",
  "consigne": "Change le sens du courant et la direction du champ, puis regarde où pointe la force. Vérifie la règle des trois doigts de la main droite sur plusieurs configurations. Trouve la position du fil pour laquelle la force devient nulle."
}', NULL, 10),
      (v_chapitre_id, 'La force de Lorentz', 5, 'texte', 'La force de Laplace s''applique à un fil. Mais un courant, ce sont des charges en mouvement. Chaque charge subit donc individuellement une force : c''est la force de Lorentz.

## L''expression

Une particule de charge $q$ animée de la vitesse $\vec{v}$ dans un champ magnétique $\vec{B}$ subit
$$\vec{F} = q\,\vec{v} \wedge \vec{B}$$

Sa valeur vaut
$$F = |q|\,v\,B\,\sin\alpha$$
où $\alpha$ est l''angle entre $\vec{v}$ et $\vec{B}$.

## Les trois propriétés essentielles

Première propriété, la force est nulle si la particule est immobile. Un champ magnétique n''agit que sur des charges **en mouvement**. C''est une différence fondamentale avec le champ électrique, qui agit même sur une charge au repos.

Deuxième propriété, la force est nulle si $\vec{v}$ est **parallèle** à $\vec{B}$. Une particule lancée le long des lignes de champ les suit sans être déviée.

Troisième propriété, et c''est la plus importante, la force est toujours **perpendiculaire à la vitesse**. Donc son travail est nul.
$$W(\vec{F}) = 0$$

Conséquence directe : un champ magnétique ne peut pas modifier l''énergie cinétique d''une particule. Il ne peut pas l''accélérer ni la ralentir. Il ne peut que la **dévier**.

Retiens bien cette différence. Pour accélérer une particule, il faut un champ électrique. Pour la courber, un champ magnétique.

## Le mouvement circulaire uniforme

Si une particule entre perpendiculairement dans un champ magnétique uniforme, la force de Lorentz, toujours perpendiculaire à la vitesse et de valeur constante $|q|vB$, joue le rôle de force centripète.

La trajectoire est alors un **cercle** parcouru à vitesse constante. Le rayon s''obtient en écrivant que la force de Lorentz est la force centripète :
$$|q|\,v\,B = \dfrac{m\,v^{2}}{R} \qquad \text{d''où} \qquad R = \dfrac{m\,v}{|q|\,B}$$

Une particule lourde ou rapide décrit un grand cercle. Un champ intense resserre la trajectoire.

La période de révolution vaut
$$T = \dfrac{2\pi m}{|q|\,B}$$
et, chose remarquable, elle ne dépend pas de la vitesse. C''est le principe du cyclotron.

## Le lien avec la force de Laplace

Dans un fil de section $S$ et de longueur $\ell$ contenant $n$ porteurs de charge par unité de volume, chacun de charge $q$ et de vitesse $v$, le courant vaut $I = nqvS$.

La somme des forces de Lorentz sur tous les porteurs du tronçon redonne exactement $F = BI\ell$. La force de Laplace n''est donc que la version macroscopique de la force de Lorentz.

## Exercice d''application

Un proton de masse $m = 1{,}67 \times 10^{-27}$ kg et de charge $e = 1{,}6 \times 10^{-19}$ C entre à la vitesse $v = 2{,}0 \times 10^{6}$ m/s perpendiculairement à un champ magnétique uniforme $B = 0{,}50$ T. Calcule le rayon de sa trajectoire, puis sa période.

Correction. Le rayon vaut
$$R = \dfrac{m\,v}{e\,B} = \dfrac{1{,}67 \times 10^{-27} \times 2{,}0 \times 10^{6}}{1{,}6 \times 10^{-19} \times 0{,}50}$$

Le numérateur vaut $3{,}34 \times 10^{-21}$ et le dénominateur $8{,}0 \times 10^{-20}$.

Donc $R = \dfrac{3{,}34 \times 10^{-21}}{8{,}0 \times 10^{-20}} \approx 4{,}2 \times 10^{-2}$ m, soit environ $4{,}2$ cm.

La période vaut
$$T = \dfrac{2\pi m}{e\,B} = \dfrac{2\pi \times 1{,}67 \times 10^{-27}}{8{,}0 \times 10^{-20}} = \dfrac{1{,}049 \times 10^{-26}}{8{,}0 \times 10^{-20}} \approx 1{,}3 \times 10^{-7}\ \text{s}$$

Le proton fait donc environ sept millions de tours par seconde, sur un cercle de quatre centimètres de rayon.', NULL, 15),
      (v_chapitre_id, 'Quiz du chapitre 5', 6, 'quiz', '{
  "titre": "Vérifie que tu as compris",
  "questions": [
    {
      "question": "Un fil est placé parallèlement aux lignes d''un champ magnétique et parcouru par un courant. Que vaut la force de Laplace ?",
      "choix": [
        "Elle est maximale",
        "Elle est nulle",
        "Elle vaut $BI\\ell/2$",
        "Elle dépend de la longueur seulement"
      ],
      "bonne": 1,
      "explication": "La force vaut $F = BI\\ell\\sin\\alpha$. Si le fil est parallèle au champ, $\\alpha = 0$, donc $\\sin\\alpha = 0$ et la force est nulle. Elle est maximale quand le fil est perpendiculaire au champ."
    },
    {
      "question": "Pourquoi un champ magnétique ne peut-il pas accélérer une particule chargée ?",
      "choix": [
        "Parce que la force est trop faible",
        "Parce que la force est perpendiculaire à la vitesse, donc son travail est nul",
        "Parce que la particule perd sa charge",
        "Parce que la force est toujours opposée à la vitesse"
      ],
      "bonne": 1,
      "explication": "La force de Lorentz est toujours perpendiculaire à $\\vec{v}$, donc son travail est nul et l''énergie cinétique reste constante. Le champ magnétique dévie la particule sans jamais changer sa vitesse en valeur."
    },
    {
      "question": "Une particule chargée est immobile dans un champ magnétique. Que subit-elle ?",
      "choix": [
        "Une force dans le sens du champ",
        "Une force perpendiculaire au champ",
        "Aucune force magnétique",
        "Une force qui la met en rotation"
      ],
      "bonne": 2,
      "explication": "La force de Lorentz vaut $q\\vec{v} \\wedge \\vec{B}$. Si $\\vec{v} = \\vec{0}$, la force est nulle. Le champ magnétique n''agit que sur des charges en mouvement, contrairement au champ électrique."
    },
    {
      "question": "On double la vitesse d''un proton entrant perpendiculairement dans un champ magnétique. Que devient le rayon de sa trajectoire ?",
      "choix": [
        "Il est divisé par 2",
        "Il reste le même",
        "Il est doublé",
        "Il est multiplié par 4"
      ],
      "bonne": 2,
      "explication": "Le rayon vaut $R = mv/(qB)$, il est donc proportionnel à la vitesse. En doublant $v$, on double $R$. En revanche la période $T = 2\\pi m/(qB)$ ne change pas, ce qui est le principe du cyclotron."
    },
    {
      "question": "Que se passe-t-il si on casse un aimant droit en deux morceaux ?",
      "choix": [
        "On obtient un pôle nord isolé et un pôle sud isolé",
        "On obtient deux aimants complets, chacun avec un nord et un sud",
        "Les deux morceaux perdent leur aimantation",
        "Un seul des deux morceaux reste aimanté"
      ],
      "bonne": 1,
      "explication": "Il n''existe pas de pôle magnétique isolé. Chaque morceau reconstitue immédiatement ses deux pôles. C''est une différence majeure avec les charges électriques, qu''on peut séparer."
    }
  ]
}', NULL, 5);

    RAISE NOTICE '% : chapitre 5, Forces et champs magnétiques — 6 lecons ajoutees.', v_nom;
  END LOOP;
END $ptc$;
