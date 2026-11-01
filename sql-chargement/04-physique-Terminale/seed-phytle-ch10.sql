-- ============================================================================
-- MANDAL — Physique Terminale : chapitre 10, Les oscillateurs mécaniques
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
    WHERE programme_id = v_programme_id AND ordre = 10;

    -- 4. sinon on le cree
    IF v_chapitre_id IS NULL THEN
      INSERT INTO public.chapitres (programme_id, titre, ordre, niveau)
      VALUES (v_programme_id, 'Les oscillateurs mécaniques', 10, 'Module 2 : Mouvements et interactions, évolutions temporelles des systèmes mécaniques')
      RETURNING id INTO v_chapitre_id;
      RAISE NOTICE '% : chapitre 10 cree.', v_nom;
    END IF;

    -- 5. les lecons
    SELECT count(*) INTO v_deja FROM public.concepts WHERE chapitre_id = v_chapitre_id;
    IF v_deja > 0 THEN
      RAISE NOTICE '% : chapitre 10 contient deja % lecon(s) — aucun ajout.', v_nom, v_deja;
      CONTINUE;
    END IF;

    INSERT INTO public.concepts
      (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes) VALUES
      (v_chapitre_id, 'Le pendule élastique', 1, 'texte', 'Une masse accrochée à un ressort qu''on écarte puis qu''on lâche oscille indéfiniment, du moins en l''absence de frottement. C''est l''oscillateur le plus simple, et celui qu''il faut maîtriser en premier.

## Le dispositif horizontal

Un solide de masse $m$ glisse sans frottement sur un plan horizontal, accroché à un ressort de raideur $k$. Au repos, le ressort n''est ni tendu ni comprimé, et on place l''origine en ce point.

Quand le solide est à l''abscisse $x$, le ressort exerce la force de rappel
$$\vec{F} = -k\,x\,\vec{i}$$

Le signe moins est essentiel : la force ramène toujours le solide vers l''équilibre.

## L''équation différentielle

La deuxième loi de Newton projetée sur $Ox$ donne, le poids et la réaction se compensant,
$$-kx = m\ddot{x}$$

soit
$$\ddot{x} + \dfrac{k}{m}\,x = 0$$

On reconnaît la forme $\ddot{x} + \omega^{2}x = 0$ avec
$$\omega_{0} = \sqrt{\dfrac{k}{m}}$$

La solution est donc $x(t) = X_{m}\cos(\omega_{0}t + \varphi)$, et la **période propre** vaut
$$T_{0} = 2\pi\sqrt{\dfrac{m}{k}}$$

Observe bien ce résultat. La période ne dépend pas de l''amplitude. Qu''on écarte le solide de $2$ cm ou de $10$ cm, il met le même temps à faire un aller-retour. On dit que l''oscillateur est **isochrone**.

En revanche une masse plus lourde oscille plus lentement, et un ressort plus raide fait osciller plus vite.

## Le pendule élastique vertical

Suspends maintenant la masse à un ressort vertical. Au repos, le ressort s''allonge d''une longueur $x_{0}$ telle que
$$k\,x_{0} = mg \qquad \text{donc} \qquad x_{0} = \dfrac{mg}{k}$$

Si tu prends l''origine à cette **nouvelle position d''équilibre**, le calcul refait à l''identique donne exactement la même équation différentielle, et donc la même période
$$T_{0} = 2\pi\sqrt{\dfrac{m}{k}}$$

C''est un résultat important : le poids ne change pas la période, il déplace seulement la position d''équilibre. Prendre l''origine au bon endroit fait disparaître $g$ des calculs.

## L''étude énergétique

L''énergie potentielle élastique vaut $E_{pe} = \dfrac{1}{2}kx^{2}$ et l''énergie cinétique $E_{c} = \dfrac{1}{2}mv^{2}$.

En l''absence de frottement, l''énergie mécanique se conserve :
$$E_{m} = \dfrac{1}{2}kx^{2} + \dfrac{1}{2}mv^{2} = \text{constante} = \dfrac{1}{2}kX_{m}^{2}$$

Aux extrémités, la vitesse est nulle et toute l''énergie est potentielle. Au passage par l''équilibre, l''élongation est nulle et toute l''énergie est cinétique. Entre les deux, il y a échange permanent.

Cette conservation donne la vitesse en tout point :
$$v = \pm\,\omega_{0}\sqrt{X_{m}^{2} - x^{2}}$$

et au passage à l''équilibre, $v_{\max} = \omega_{0}X_{m}$.

## Association de ressorts

Deux ressorts en **parallèle**, qui tirent ensemble, se remplacent par un ressort unique de raideur
$$k_{\text{éq}} = k_{1} + k_{2}$$

Deux ressorts en **série**, bout à bout, donnent
$$\dfrac{1}{k_{\text{éq}}} = \dfrac{1}{k_{1}} + \dfrac{1}{k_{2}}$$

Retiens que c''est l''inverse de ce qu''on a pour les résistances électriques.

## Exercice d''application

Un solide de masse $m = 200$ g est accroché à un ressort de raideur $k = 50$ N/m. On l''écarte de $5{,}0$ cm et on le lâche sans vitesse. Calcule la période, la vitesse maximale et l''énergie mécanique.

Correction. La période vaut
$$T_{0} = 2\pi\sqrt{\dfrac{0{,}200}{50}} = 2\pi\sqrt{0{,}0040} = 2\pi \times 0{,}0632 \approx 0{,}40\ \text{s}$$

La pulsation vaut $\omega_{0} = \sqrt{\dfrac{50}{0{,}200}} = \sqrt{250} \approx 15{,}8$ rad/s.

La vitesse maximale vaut
$$v_{\max} = \omega_{0}X_{m} = 15{,}8 \times 0{,}050 \approx 0{,}79\ \text{m/s}$$

L''énergie mécanique vaut
$$E_{m} = \dfrac{1}{2}kX_{m}^{2} = 0{,}5 \times 50 \times (0{,}050)^{2} = 0{,}0625\ \text{J}$$

Vérifions avec l''énergie cinétique maximale : $\dfrac{1}{2}mv_{\max}^{2} = 0{,}5 \times 0{,}200 \times 0{,}79^{2} \approx 0{,}0624$ J. Les deux valeurs concordent, l''énergie est bien conservée.', NULL, 15),
      (v_chapitre_id, 'Fais osciller un pendule élastique', 2, 'interactif', '{
  "widget": "pendule-elastique",
  "consigne": "Change la masse, la raideur du ressort et l''amplitude de départ. Vérifie que la période ne dépend pas de l''amplitude. Puis trouve ce qu''il faut faire pour diviser la période par deux : multiplier la raideur par combien ?"
}', NULL, 10),
      (v_chapitre_id, 'Le pendule simple et le pendule de torsion', 3, 'texte', 'Après le ressort, voici les deux autres oscillateurs du programme. Le raisonnement est identique, seule la force de rappel change.

## Le pendule simple

Un pendule simple est une petite masse $m$ suspendue à un fil inextensible de longueur $\ell$ et de masse négligeable.

Écarté d''un angle $\theta$, il subit son poids et la tension du fil. En projetant sur la tangente à la trajectoire, seule la composante tangentielle du poids agit :
$$-mg\sin\theta = m\,\ell\,\ddot{\theta}$$

soit
$$\ddot{\theta} + \dfrac{g}{\ell}\sin\theta = 0$$

Cette équation n''est pas celle d''un mouvement sinusoïdal, à cause du $\sin\theta$.

## L''approximation des petites oscillations

Si l''angle reste petit, disons inférieur à environ $10°$, on peut écrire $\sin\theta \approx \theta$ avec $\theta$ en radians. L''équation devient alors
$$\ddot{\theta} + \dfrac{g}{\ell}\,\theta = 0$$

C''est la forme attendue, avec $\omega_{0} = \sqrt{\dfrac{g}{\ell}}$, donc
$$T_{0} = 2\pi\sqrt{\dfrac{\ell}{g}}$$

Trois remarques s''imposent. La période ne dépend pas de la masse, ce qui surprend toujours. Elle ne dépend pas non plus de l''amplitude, mais seulement tant que l''angle reste petit. Et elle dépend de $g$, ce qui permet de mesurer le champ de pesanteur avec un simple fil et une bille.

## Le pendule pesant

Un pendule pesant est un solide quelconque qui oscille autour d''un axe horizontal ne passant pas par son centre d''inertie.

La relation fondamentale de la dynamique en rotation donne, pour de petites oscillations,
$$T_{0} = 2\pi\sqrt{\dfrac{J_{\Delta}}{m\,g\,d}}$$
où $J_{\Delta}$ est le moment d''inertie par rapport à l''axe et $d$ la distance de l''axe au centre d''inertie.

Le pendule simple en est le cas particulier où $J = m\ell^{2}$ et $d = \ell$.

## Le pendule de torsion

Un disque est suspendu à un fil métallique vertical. Quand on le tourne d''un angle $\theta$, le fil exerce un couple de rappel
$$\mathcal{M} = -C\,\theta$$
où $C$ est la **constante de torsion** du fil, en N·m/rad.

La relation fondamentale en rotation donne $-C\theta = J\ddot{\theta}$, soit
$$\ddot{\theta} + \dfrac{C}{J}\,\theta = 0$$

d''où
$$T_{0} = 2\pi\sqrt{\dfrac{J}{C}}$$

Ici la gravité n''intervient pas du tout. Un pendule de torsion fonctionnerait aussi bien dans l''espace. C''est d''ailleurs le principe de la balance de Cavendish, qui a permis de mesurer la constante de gravitation.

## Le tableau de correspondance

Les quatre oscillateurs suivent la même logique. Il y a toujours une grandeur d''inertie et une grandeur de rappel, et la période vaut $2\pi$ fois la racine de leur rapport.

Pour le pendule élastique, l''inertie est $m$ et le rappel est $k$.

Pour le pendule simple, c''est $\ell$ et $g$.

Pour le pendule pesant, c''est $J$ et $mgd$.

Pour le pendule de torsion, c''est $J$ et $C$.

Si tu retiens cette structure, tu n''as plus qu''une formule à mémoriser au lieu de quatre.

## Exercice d''application

Un pendule simple de longueur $\ell = 1{,}0$ m oscille à Yaoundé. Calcule sa période avec $g = 9{,}78$ N/kg. De combien faut-il rallonger le fil pour que la période passe à $2{,}5$ s ?

Correction. La période initiale vaut
$$T_{0} = 2\pi\sqrt{\dfrac{1{,}0}{9{,}78}} = 2\pi\sqrt{0{,}1023} = 2\pi \times 0{,}3198 \approx 2{,}01\ \text{s}$$

Pour obtenir $T = 2{,}5$ s, on inverse la formule :
$$\ell = \dfrac{g\,T^{2}}{4\pi^{2}} = \dfrac{9{,}78 \times 6{,}25}{39{,}48} = \dfrac{61{,}13}{39{,}48} \approx 1{,}55\ \text{m}$$

Il faut donc rallonger le fil de $1{,}55 - 1{,}0 = 0{,}55$ m, soit $55$ cm.

Remarque que pour multiplier la période par $1{,}24$, il a fallu multiplier la longueur par $1{,}55$, c''est-à-dire par le carré. La période varie comme la racine de la longueur.', NULL, 15),
      (v_chapitre_id, 'Compare trois pendules', 4, 'interactif', '{
  "widget": "pendule-simple",
  "consigne": "Fais osciller un pendule simple et change sa longueur, sa masse et son angle de départ. Vérifie que la masse ne change rien à la période. Puis augmente l''angle au-delà de 20° : l''approximation des petites oscillations tient-elle encore ?"
}', NULL, 10),
      (v_chapitre_id, 'Amortissement et résonance', 5, 'texte', 'Dans la réalité, un pendule finit toujours par s''arrêter. Les frottements dissipent son énergie. Pour entretenir le mouvement, il faut lui fournir de l''énergie de l''extérieur, et là un phénomène spectaculaire peut apparaître.

## Les oscillations amorties

Avec frottement, l''amplitude décroît au fil du temps. On distingue deux types d''amortissement.

L''**amortissement par frottement solide**, par exemple un stylet qui frotte sur du papier. La force de frottement est constante en valeur, et l''amplitude décroît **linéairement**. Les sommets successifs sont alignés sur une droite.

L''**amortissement par frottement visqueux**, par exemple un pendule dans l''eau ou dans l''huile. La force est proportionnelle à la vitesse, $\vec{f} = -\lambda\vec{v}$, et l''amplitude décroît de façon **exponentielle**. Les sommets suivent une courbe en $e^{-t/\tau}$.

## Les trois régimes

Si l''amortissement est **faible**, le système oscille en perdant peu à peu son amplitude. C''est le régime **pseudo-périodique**, et la durée entre deux passages dans le même sens s''appelle la pseudo-période.

Si l''amortissement est **fort**, le système revient à l''équilibre sans jamais osciller. C''est le régime **apériodique**.

Entre les deux, il existe un amortissement particulier pour lequel le retour à l''équilibre est le plus rapide possible sans oscillation. C''est le régime **critique**. C''est celui qu''on recherche pour les amortisseurs d''une voiture ou l''aiguille d''un appareil de mesure.

## Les oscillations forcées

Pour entretenir les oscillations, on relie l''oscillateur à un **excitateur** qui lui impose une fréquence $N$.

Après un régime transitoire, le système oscille à la fréquence de l''excitateur, et non à sa propre fréquence. C''est un point important. L''oscillateur, appelé **résonateur**, subit la loi de l''excitateur.

Ce qui dépend du résonateur, c''est l''**amplitude** de sa réponse et son **déphasage** avec l''excitateur.

## La résonance

Quand la fréquence de l''excitateur approche la fréquence propre $N_{0}$ du résonateur, l''amplitude devient très grande. C''est la **résonance**.

Plus l''amortissement est faible, plus le pic de résonance est haut et étroit. On dit que la résonance est **aiguë**. Avec un fort amortissement, le pic s''aplatit et s''élargit : la résonance est **floue**.

Dans le cas idéal sans frottement, l''amplitude deviendrait infinie. Dans la réalité, c''est la rupture.

## La résonance dans la vie courante

Elle est parfois recherchée. Une balançoire qu''on pousse au bon rythme monte très haut avec peu d''effort. Les instruments de musique utilisent la résonance de leur caisse pour amplifier le son.

Elle est parfois redoutée. On fait rompre le pas à une troupe de soldats qui traverse un pont, pour éviter que leur cadence ne coïncide avec la fréquence propre de l''ouvrage. Le pont de Tacoma, aux États-Unis, s''est effondré en 1940 sous l''effet du vent.

## Exercice d''application

Un pendule élastique de masse $m = 0{,}50$ kg et de raideur $k = 200$ N/m est soumis à un excitateur de fréquence réglable. À quelle fréquence observera-t-on la résonance ? Que se passe-t-il si on plonge le système dans l''huile ?

Correction. La fréquence propre vaut
$$N_{0} = \dfrac{1}{2\pi}\sqrt{\dfrac{k}{m}} = \dfrac{1}{2\pi}\sqrt{\dfrac{200}{0{,}50}} = \dfrac{\sqrt{400}}{2\pi} = \dfrac{20}{6{,}28} \approx 3{,}2\ \text{Hz}$$

La résonance apparaîtra donc autour de $3{,}2$ Hz.

Dans l''huile, l''amortissement augmente beaucoup. La fréquence de résonance reste à peu près la même, en réalité elle baisse légèrement, mais surtout le pic s''aplatit nettement. L''amplitude maximale sera bien plus faible, et la résonance sera floue au lieu d''être aiguë.', NULL, 15),
      (v_chapitre_id, 'Quiz du chapitre 10', 6, 'quiz', '{
  "titre": "Vérifie que tu as compris",
  "questions": [
    {
      "question": "On double l''amplitude de départ d''un pendule élastique. Que devient sa période ?",
      "choix": [
        "Elle double",
        "Elle est divisée par 2",
        "Elle ne change pas",
        "Elle est multipliée par $\\sqrt{2}$"
      ],
      "bonne": 2,
      "explication": "La période vaut $T_0 = 2\\pi\\sqrt{m/k}$, elle ne contient pas l''amplitude. L''oscillateur est isochrone : quelle que soit l''amplitude de départ, un aller-retour dure toujours le même temps."
    },
    {
      "question": "On quadruple la masse accrochée à un ressort. Que devient la période ?",
      "choix": [
        "Elle est multipliée par 4",
        "Elle est multipliée par 2",
        "Elle est divisée par 2",
        "Elle ne change pas"
      ],
      "bonne": 1,
      "explication": "La période varie comme $\\sqrt{m}$. Quadrupler la masse multiplie la racine par 2, donc la période double."
    },
    {
      "question": "De quoi dépend la période d''un pendule simple aux petites oscillations ?",
      "choix": [
        "De la masse et de la longueur",
        "De la longueur et de $g$",
        "De la masse seulement",
        "De l''amplitude seulement"
      ],
      "bonne": 1,
      "explication": "La période vaut $T_0 = 2\\pi\\sqrt{\\ell/g}$. La masse se simplifie dans le calcul et n''intervient pas, ce qui permet d''utiliser un pendule pour mesurer $g$."
    },
    {
      "question": "Quel régime d''amortissement ramène le système à l''équilibre le plus rapidement sans oscillation ?",
      "choix": [
        "Le régime pseudo-périodique",
        "Le régime critique",
        "Le régime apériodique fort",
        "Le régime forcé"
      ],
      "bonne": 1,
      "explication": "Le régime critique est exactement à la frontière entre oscillation et non-oscillation. C''est celui qu''on règle sur les amortisseurs de voiture et les aiguilles d''appareils de mesure."
    },
    {
      "question": "Un oscillateur est soumis à un excitateur. À quelle fréquence oscille-t-il en régime permanent ?",
      "choix": [
        "À sa fréquence propre",
        "À la fréquence de l''excitateur",
        "À la moyenne des deux",
        "Il n''oscille pas"
      ],
      "bonne": 1,
      "explication": "En régime forcé permanent, le résonateur oscille toujours à la fréquence imposée par l''excitateur. Ce qui dépend de sa fréquence propre, c''est l''amplitude de sa réponse, maximale à la résonance."
    },
    {
      "question": "Pourquoi fait-on rompre le pas aux soldats qui traversent un pont ?",
      "choix": [
        "Pour aller plus vite",
        "Pour éviter que leur cadence coïncide avec la fréquence propre du pont",
        "Pour répartir le poids",
        "Pour faire moins de bruit"
      ],
      "bonne": 1,
      "explication": "Si la cadence des pas approche la fréquence propre du pont, il y a résonance et l''amplitude des oscillations peut devenir destructrice. En rompant le pas, on évite toute excitation régulière."
    }
  ]
}', NULL, 5);

    RAISE NOTICE '% : chapitre 10, Les oscillateurs mécaniques — 6 lecons ajoutees.', v_nom;
  END LOOP;
END $ptc$;
