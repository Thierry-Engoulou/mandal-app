-- ============================================================================
-- MANDAL — Physique Terminale : chapitre 6, Les lois de Newton sur le mouvement
-- Module 2 : Mouvements et interactions, évolutions temporelles des systèmes mécaniques
-- 5 leçons.
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
    WHERE programme_id = v_programme_id AND ordre = 6;

    -- 4. sinon on le cree
    IF v_chapitre_id IS NULL THEN
      INSERT INTO public.chapitres (programme_id, titre, ordre, niveau)
      VALUES (v_programme_id, 'Les lois de Newton sur le mouvement', 6, 'Module 2 : Mouvements et interactions, évolutions temporelles des systèmes mécaniques')
      RETURNING id INTO v_chapitre_id;
      RAISE NOTICE '% : chapitre 6 cree.', v_nom;
    END IF;

    -- 5. les lecons
    SELECT count(*) INTO v_deja FROM public.concepts WHERE chapitre_id = v_chapitre_id;
    IF v_deja > 0 THEN
      RAISE NOTICE '% : chapitre 6 contient deja % lecon(s) — aucun ajout.', v_nom, v_deja;
      CONTINUE;
    END IF;

    INSERT INTO public.concepts
      (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes) VALUES
      (v_chapitre_id, 'Référentiels, repères et système', 1, 'texte', 'Avant d''écrire la moindre loi de la mécanique, tu dois dire par rapport à quoi tu observes le mouvement. Sans cette précision, parler de mouvement n''a aucun sens.

## Le mouvement est relatif

Tu es assis dans un car qui roule de Douala à Yaoundé. Par rapport au car, tu es immobile. Par rapport à la route, tu avances à $80$ km/h. Les deux affirmations sont vraies en même temps.

Un **référentiel** est le solide par rapport auquel on étudie le mouvement, auquel on associe une horloge pour repérer les dates.

## Les trois référentiels du programme

Le **référentiel terrestre** est lié au sol. C''est celui de tous les mouvements de la vie courante : une voiture, un ballon, un pendule.

Le **référentiel géocentrique** a son origine au centre de la Terre, et ses axes pointent vers trois étoiles lointaines. Il ne tourne donc pas avec la Terre. C''est le référentiel des satellites et de la Lune.

Le **référentiel héliocentrique** a son origine au centre du Soleil, avec des axes dirigés vers des étoiles lointaines. C''est celui du mouvement des planètes.

## Les référentiels galiléens

Un référentiel est **galiléen** quand le principe d''inertie y est vérifié. Ce sont les seuls dans lesquels on a le droit d''appliquer les lois de Newton telles quelles.

Le référentiel héliocentrique est galiléen avec une excellente approximation. Le géocentrique l''est pour des durées courtes devant l''année. Le terrestre l''est pour des expériences qui durent peu devant une journée, ce qui couvre tout ce que tu feras en classe.

Un car qui freine ou qui prend un virage n''est pas galiléen. C''est pourquoi tu es projeté vers l''avant au freinage, sans qu''aucune force ne te pousse réellement.

## Le repère

Au référentiel on associe un **repère** d''espace, par exemple $(O, \vec{i}, \vec{j}, \vec{k})$, et une origine des dates.

La position d''un point $M$ est donnée par le vecteur position
$$\overrightarrow{OM} = x\,\vec{i} + y\,\vec{j} + z\,\vec{k}$$

## Système, forces intérieures et extérieures

Le **système** est l''objet dont tu étudies le mouvement. Tu dois toujours le définir clairement, et l''entourer sur ton schéma.

Les **forces intérieures** s''exercent entre deux parties du système. D''après la troisième loi de Newton, elles s''annulent deux à deux et ne jouent aucun rôle dans le mouvement d''ensemble.

Les **forces extérieures** sont exercées par ce qui n''appartient pas au système. Ce sont elles, et elles seules, qui figurent dans les lois de Newton.

Changer la frontière du système change la liste des forces. Si tu prends deux wagons attelés comme un seul système, la tension de l''attelage est intérieure et disparaît. Si tu prends un seul wagon, elle devient extérieure et il faut l''écrire.

## Exercice d''application

Un élève pousse une caisse sur le sol. Choisis le système, le référentiel, et fais l''inventaire des forces extérieures.

Correction. Le système est la caisse seule. Le référentiel est terrestre, supposé galiléen.

Les forces extérieures sont le poids $\vec{P}$, vertical vers le bas, appliqué au centre d''inertie. La réaction normale du sol $\vec{R}_{N}$, perpendiculaire au sol et dirigée vers le haut. La force de frottement $\vec{f}$, parallèle au sol et opposée au mouvement. Enfin la force $\vec{F}$ exercée par l''élève.

La force que la caisse exerce en retour sur l''élève n''apparaît pas, parce que l''élève ne fait pas partie du système.', NULL, 15),
      (v_chapitre_id, 'Les trois lois de Newton', 2, 'texte', 'Trois énoncés suffisent à décrire tous les mouvements de la mécanique classique. Tu dois les connaître par cœur et savoir lequel utiliser.

## Première loi : le principe d''inertie

Dans un référentiel galiléen, si la somme des forces extérieures appliquées à un solide est nulle, alors son centre d''inertie est soit immobile, soit animé d''un mouvement rectiligne uniforme. Et réciproquement.
$$\sum \vec{F}_{\text{ext}} = \vec{0} \iff \vec{v}_{G} = \overrightarrow{\text{constante}}$$

Retiens bien le sens profond. Il ne faut aucune force pour **continuer** à avancer en ligne droite à vitesse constante. Il en faut une pour **changer** quelque chose.

## Deuxième loi : le théorème du centre d''inertie

Dans un référentiel galiléen, la somme des forces extérieures appliquées à un solide est égale au produit de sa masse par l''accélération de son centre d''inertie.
$$\sum \vec{F}_{\text{ext}} = m\,\vec{a}_{G}$$

C''est la loi la plus utilisée de toute la mécanique. Elle dit que la force ne crée pas la vitesse, mais la **variation** de vitesse.

Comme c''est une relation vectorielle, on la projette sur les axes pour obtenir des équations scalaires. Le choix des axes est stratégique : prends-en un dans la direction du mouvement, cela simplifie beaucoup les calculs.

## Troisième loi : le principe des actions réciproques

Si un corps $A$ exerce sur un corps $B$ une force $\vec{F}_{A/B}$, alors $B$ exerce sur $A$ une force
$$\vec{F}_{B/A} = -\vec{F}_{A/B}$$

Les deux forces ont même droite d''action, même valeur, et des sens opposés. Elles sont toujours simultanées.

Le point crucial, c''est qu''elles s''appliquent à **deux corps différents**. Elles ne se compensent donc jamais. C''est l''erreur la plus fréquente des élèves : on ne peut pas dire qu''un cheval ne peut pas tirer une charrette sous prétexte que la charrette tire autant en retour, puisque les deux forces ne s''appliquent pas au même objet.

## La méthode de résolution, en cinq étapes

Tu définis le système. Tu choisis le référentiel et tu le déclares galiléen. Tu fais le bilan des forces extérieures, avec un schéma. Tu écris la deuxième loi de Newton sous forme vectorielle. Tu projettes sur des axes bien choisis et tu résous.

Ne saute jamais le schéma. La moitié des erreurs vient d''une force oubliée ou mal orientée.

## Exercice d''application

Un bloc de masse $m = 5{,}0$ kg glisse sans frottement sur un plan incliné de $\alpha = 30°$ par rapport à l''horizontale. Détermine son accélération. On prend $g = 9{,}8$ N/kg.

Correction. Le système est le bloc, le référentiel est terrestre galiléen.

Les forces extérieures sont le poids $\vec{P}$ et la réaction normale $\vec{R}$, perpendiculaire au plan puisqu''il n''y a pas de frottement.

La deuxième loi donne $\vec{P} + \vec{R} = m\vec{a}$.

Choisissons un axe $Ox$ dirigé le long du plan vers le bas, et un axe $Oy$ perpendiculaire au plan.

Sur $Ox$ : le poids a pour composante $P\sin\alpha = mg\sin\alpha$, et la réaction a une composante nulle puisqu''elle est perpendiculaire. Donc
$$mg\sin\alpha = ma_{x} \qquad \text{d''où} \qquad a_{x} = g\sin\alpha$$

Numériquement, $a_{x} = 9{,}8 \times \sin 30° = 9{,}8 \times 0{,}5 = 4{,}9$ m/s².

Sur $Oy$ : $R - mg\cos\alpha = 0$, donc $R = mg\cos\alpha = 5{,}0 \times 9{,}8 \times \cos 30° \approx 42{,}4$ N.

Remarque un résultat important. L''accélération $g\sin\alpha$ ne contient pas la masse. Un bloc de $5$ kg et un bloc de $50$ kg descendent exactement de la même façon, tant qu''il n''y a pas de frottement.', NULL, 15),
      (v_chapitre_id, 'Dynamique du solide en rotation', 3, 'texte', 'Jusqu''ici tu as traité des objets comme des points. Mais une poulie qui tourne, une porte qui pivote ou une roue ne peuvent pas être réduites à un point. Il faut une deuxième loi de Newton adaptée à la rotation.

## Les paramètres du mouvement de rotation

Un solide qui tourne autour d''un axe fixe est repéré par son **abscisse angulaire** $\theta$, en radians.

Sa **vitesse angulaire** est $\omega = \dfrac{d\theta}{dt}$, en rad/s.

Son **accélération angulaire** est $\ddot{\theta} = \dfrac{d\omega}{dt}$, en rad/s².

Un point situé à la distance $r$ de l''axe a une vitesse linéaire $v = r\omega$.

## Le moment d''une force

Une force ne fait tourner un solide que si elle a un bras de levier. Le **moment** de la force $\vec{F}$ par rapport à l''axe $\Delta$ vaut
$$\mathcal{M}_{\Delta}(\vec{F}) = \pm F \times d$$
où $d$ est la distance de l''axe à la droite d''action de la force, et le signe dépend du sens de rotation qu''elle tend à produire.

Une force dont la droite d''action coupe l''axe a un moment nul. C''est pourquoi on pousse une porte loin des gonds et jamais près d''eux.

## Le moment d''inertie

Le moment d''inertie $J_{\Delta}$ mesure la résistance du solide à la mise en rotation. Il joue le rôle que la masse joue en translation. Son unité est le kg·m².

Il ne dépend pas seulement de la masse, mais aussi de la façon dont elle est répartie autour de l''axe. Plus la masse est loin de l''axe, plus $J$ est grand.

Pour une masse ponctuelle $m$ à la distance $r$ : $J = mr^{2}$.

Pour un cerceau ou un cylindre creux de rayon $R$ : $J = mR^{2}$.

Pour un disque ou un cylindre plein de rayon $R$ : $J = \dfrac{1}{2}mR^{2}$.

Pour une sphère pleine de rayon $R$ : $J = \dfrac{2}{5}mR^{2}$.

Pour une tige de longueur $L$ tournant autour de son milieu : $J = \dfrac{1}{12}mL^{2}$.

## La relation fondamentale de la dynamique en rotation

Dans un référentiel galiléen, pour un solide en rotation autour d''un axe fixe $\Delta$,
$$\sum \mathcal{M}_{\Delta}(\vec{F}_{\text{ext}}) = J_{\Delta}\,\ddot{\theta}$$

Compare avec $\sum \vec{F} = m\vec{a}$. La somme des moments remplace la somme des forces, le moment d''inertie remplace la masse, et l''accélération angulaire remplace l''accélération. C''est la même loi, transposée.

## Le théorème de Huygens

Si tu connais le moment d''inertie $J_{G}$ par rapport à un axe passant par le centre d''inertie, tu obtiens celui par rapport à un axe parallèle situé à la distance $d$ :
$$J_{\Delta} = J_{G} + m\,d^{2}$$

Ce théorème évite de refaire un calcul pénible à chaque changement d''axe.

## Exercice d''application

Une poulie en forme de disque homogène de masse $M = 0{,}40$ kg et de rayon $R = 10$ cm peut tourner sans frottement autour de son axe. On enroule un fil sur sa gorge et on y suspend une masse $m = 0{,}20$ kg. Détermine l''accélération de la masse. On prend $g = 9{,}8$ N/kg.

Correction. Pour la masse suspendue, la deuxième loi de Newton projetée sur la verticale descendante donne
$$mg - T = ma$$

Pour la poulie, la seule force qui a un moment est la tension du fil, de bras de levier $R$. La relation fondamentale en rotation donne
$$T \times R = J\,\ddot{\theta} \qquad \text{avec} \qquad J = \dfrac{1}{2}MR^{2}$$

Le fil ne glisse pas, donc $a = R\ddot{\theta}$, soit $\ddot{\theta} = \dfrac{a}{R}$.

En remplaçant, $TR = \dfrac{1}{2}MR^{2} \times \dfrac{a}{R} = \dfrac{1}{2}MRa$, donc $T = \dfrac{1}{2}Ma$.

On reporte dans la première équation : $mg - \dfrac{1}{2}Ma = ma$, d''où
$$a = \dfrac{mg}{m + \dfrac{M}{2}}$$

Numériquement, $a = \dfrac{0{,}20 \times 9{,}8}{0{,}20 + 0{,}20} = \dfrac{1{,}96}{0{,}40} = 4{,}9$ m/s².

La masse tombe deux fois moins vite qu''en chute libre, parce qu''elle doit en plus mettre la poulie en rotation.', NULL, 15),
      (v_chapitre_id, 'Bilan des forces sur un plan incliné', 4, 'interactif', '{
  "widget": "lois-newton",
  "consigne": "Change l''angle du plan, la masse et le coefficient de frottement, et regarde les vecteurs forces se redessiner. Trouve l''angle à partir duquel le bloc se met à glisser. Vérifie ensuite que l''accélération vaut bien $g\\sin\\alpha$ quand tu supprimes les frottements."
}', NULL, 10),
      (v_chapitre_id, 'Quiz du chapitre 6', 5, 'quiz', '{
  "titre": "Vérifie que tu as compris",
  "questions": [
    {
      "question": "Un objet se déplace en ligne droite à vitesse constante. Que peut-on dire des forces qui s''exercent sur lui ?",
      "choix": [
        "Aucune force ne s''exerce sur lui",
        "Leur somme vectorielle est nulle",
        "Une seule force s''exerce, dans le sens du mouvement",
        "Leur somme est constante et non nulle"
      ],
      "bonne": 1,
      "explication": "C''est le principe d''inertie. Des forces peuvent très bien s''exercer, mais elles se compensent exactement. Une caisse tirée à vitesse constante subit bien une traction, compensée par les frottements."
    },
    {
      "question": "Un bloc glisse sans frottement sur un plan incliné de 30°. De quoi dépend son accélération ?",
      "choix": [
        "De sa masse uniquement",
        "De l''angle uniquement",
        "De sa masse et de l''angle",
        "De rien, elle vaut toujours $g$"
      ],
      "bonne": 1,
      "explication": "La projection donne $a = g\\sin\\alpha$. La masse se simplifie, elle n''intervient pas. Un bloc léger et un bloc lourd descendent de la même façon, exactement comme en chute libre."
    },
    {
      "question": "Pourquoi les forces de la troisième loi de Newton ne se compensent-elles jamais ?",
      "choix": [
        "Parce qu''elles n''ont pas la même valeur",
        "Parce qu''elles s''appliquent à deux corps différents",
        "Parce qu''elles n''ont pas la même direction",
        "Parce que l''une est plus rapide que l''autre"
      ],
      "bonne": 1,
      "explication": "Elles ont bien la même valeur et des sens opposés, mais l''une s''applique à $A$ et l''autre à $B$. Pour les compenser il faudrait qu''elles agissent sur le même système, ce qui n''est jamais le cas."
    },
    {
      "question": "Deux disques ont la même masse, mais l''un a un rayon deux fois plus grand. Lequel est le plus difficile à mettre en rotation ?",
      "choix": [
        "Le petit",
        "Le grand, son moment d''inertie est 4 fois plus grand",
        "Le grand, son moment d''inertie est 2 fois plus grand",
        "Ils sont identiques puisque la masse est la même"
      ],
      "bonne": 1,
      "explication": "Pour un disque, $J = \\frac{1}{2}MR^2$. Doubler le rayon multiplie $R^2$ par 4, donc le moment d''inertie par 4. La répartition de la masse compte autant que la masse elle-même."
    },
    {
      "question": "Dans quel référentiel étudie-t-on le mouvement d''un satellite autour de la Terre ?",
      "choix": [
        "Le référentiel terrestre",
        "Le référentiel géocentrique",
        "Le référentiel héliocentrique",
        "Le référentiel du satellite"
      ],
      "bonne": 1,
      "explication": "Le référentiel géocentrique a son origine au centre de la Terre et des axes pointant vers des étoiles lointaines, donc il ne tourne pas avec la Terre. C''est celui qui convient aux satellites et à la Lune."
    }
  ]
}', NULL, 5);

    RAISE NOTICE '% : chapitre 6, Les lois de Newton sur le mouvement — 5 lecons ajoutees.', v_nom;
  END LOOP;
END $ptc$;
