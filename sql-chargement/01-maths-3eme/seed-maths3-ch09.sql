-- ============================================================================
-- MANDAL — Mathématiques 3ème : chapitre 9, Trigonométrie dans le triangle rectangle
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
  WHERE programme_id = v_programme_id AND ordre = 9;

  -- 4. sinon on le cree
  IF v_chapitre_id IS NULL THEN
    INSERT INTO public.chapitres (programme_id, titre, ordre, niveau)
    VALUES (v_programme_id, 'Trigonométrie dans le triangle rectangle', 9, 'Module 15 : Configurations et transformations élémentaires du plan')
    RETURNING id INTO v_chapitre_id;
    RAISE NOTICE 'Chapitre 9 cree.';
  END IF;

  -- 5. les lecons
  SELECT count(*) INTO v_deja FROM public.concepts WHERE chapitre_id = v_chapitre_id;
  IF v_deja > 0 THEN
    RAISE NOTICE 'Chapitre 9 : contient deja % lecon(s) — aucun ajout.', v_deja;
    RETURN;
  END IF;

  INSERT INTO public.concepts
    (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes) VALUES
    (v_chapitre_id, 'Cosinus, sinus et tangente d''un angle aigu', 1, 'texte', 'Dans un triangle rectangle, les longueurs des côtés et la mesure des angles sont liées. Trois rapports suffisent à tout faire, et il faut d''abord savoir nommer les côtés.

## Nommer les côtés

Place-toi sur l''angle aigu que tu étudies, appelons-le $\widehat{A}$.

L''hypoténuse est le côté opposé à l''angle droit. C''est toujours le plus long, et il ne change jamais de nom.

Le côté adjacent à $\widehat{A}$ est celui qui touche l''angle $\widehat{A}$ sans être l''hypoténuse.

Le côté opposé à $\widehat{A}$ est celui qui ne touche pas $\widehat{A}$.

Attention, adjacent et opposé changent de place selon l''angle que tu regardes. L''hypoténuse, elle, reste la même.

## Les trois rapports

$$\cos \widehat{A} = \dfrac{\text{côté adjacent}}{\text{hypoténuse}} \qquad \sin \widehat{A} = \dfrac{\text{côté opposé}}{\text{hypoténuse}} \qquad \tan \widehat{A} = \dfrac{\text{côté opposé}}{\text{côté adjacent}}$$

Pour les retenir, apprends les trois mots CAH, SOH, TOA. Cosinus Adjacent Hypoténuse, Sinus Opposé Hypoténuse, Tangente Opposé Adjacent.

## Deux propriétés utiles

Pour tout angle aigu, $0 < \cos \widehat{A} < 1$ et $0 < \sin \widehat{A} < 1$. C''est normal : l''hypoténuse étant le plus long côté, le rapport est toujours inférieur à 1. Si tu trouves un cosinus supérieur à 1, tu as inversé la fraction.

De plus $\cos^{2} \widehat{A} + \sin^{2} \widehat{A} = 1$ et $\tan \widehat{A} = \dfrac{\sin \widehat{A}}{\cos \widehat{A}}$.

## Exercice d''application

Dans un triangle $ABC$ rectangle en $B$, on a $AB = 3$ cm, $BC = 4$ cm et $AC = 5$ cm. Donne $\cos \widehat{A}$, $\sin \widehat{A}$ et $\tan \widehat{A}$.

Correction. L''hypoténuse est $AC = 5$. Pour l''angle $\widehat{A}$, l''adjacent est $AB = 3$ et l''opposé est $BC = 4$. Donc $\cos \widehat{A} = \dfrac{3}{5} = 0{,}6$, $\sin \widehat{A} = \dfrac{4}{5} = 0{,}8$ et $\tan \widehat{A} = \dfrac{4}{3} \approx 1{,}33$.', NULL, 15),
    (v_chapitre_id, 'Simulation : les trois rapports du triangle rectangle', 2, 'interactif', '{
  "widget": "trigo-rectangle",
  "consigne": "Règle l''angle sur 30° et l''hypoténuse sur 10. Lis les trois longueurs et vérifie à la main que $\\cos 30° = \\dfrac{\\text{adjacent}}{10}$. Fais maintenant grandir l''angle jusqu''à 60° : le côté opposé grandit, l''adjacent rétrécit, donc le sinus augmente et le cosinus diminue. Vérifie enfin que $\\cos^{2} + \\sin^{2}$ affiche toujours 1, quel que soit l''angle."
}', NULL, 10),
    (v_chapitre_id, 'Utiliser la trigonométrie pour calculer', 3, 'texte', 'Avec ta calculatrice en mode degré, les trois rapports te permettent de trouver une longueur manquante ou un angle manquant.

## Trouver une longueur

Choisis le rapport qui relie ce que tu connais à ce que tu cherches.

Une échelle de 5 m est appuyée contre un mur et fait un angle de 70° avec le sol. À quelle hauteur touche-t-elle le mur ?

La hauteur est le côté opposé à l''angle de 70°, et l''échelle est l''hypoténuse. C''est donc le sinus :

$$\sin 70° = \dfrac{h}{5} \qquad \text{donc} \qquad h = 5 \times \sin 70° \approx 5 \times 0{,}940 = 4{,}70 \text{ m}$$

## Trouver un angle

Quand tu connais deux côtés, tu calcules le rapport puis tu utilises la touche inverse de ta calculatrice, notée $\cos^{-1}$, $\sin^{-1}$ ou $\tan^{-1}$.

Une route monte de 80 m de dénivelé sur une distance horizontale de 600 m. Quel est l''angle de la pente ?

Le dénivelé est l''opposé et la distance horizontale est l''adjacent, donc on utilise la tangente :

$$\tan \alpha = \dfrac{80}{600} \approx 0{,}1333$$

Avec la touche $\tan^{-1}$, on trouve $\alpha \approx 7{,}6°$.

## Vérifier la cohérence

Un angle aigu est toujours compris entre 0 et 90 degrés. Si ta calculatrice affiche une erreur, c''est souvent que tu as divisé à l''envers, ou que ta calculatrice est en radians. Vérifie que $\cos 60°$ donne bien 0,5.

## Exercice d''application

Dans un triangle $MNP$ rectangle en $N$, on a $MN = 7$ cm et l''angle $\widehat{M} = 40°$. Calcule $NP$ puis $MP$.

Correction. Pour l''angle $\widehat{M}$, l''adjacent est $MN = 7$ et l''opposé est $NP$. Donc $\tan 40° = \dfrac{NP}{7}$, soit $NP = 7 \times \tan 40° \approx 7 \times 0{,}839 = 5{,}87$ cm. Ensuite $\cos 40° = \dfrac{7}{MP}$, donc $MP = \dfrac{7}{\cos 40°} \approx \dfrac{7}{0{,}766} = 9{,}14$ cm.', NULL, 15),
    (v_chapitre_id, 'Quiz : trigonométrie', 4, 'quiz', '{
  "titre": "Vérifie que tu as compris",
  "questions": [
    {
      "question": "Dans un triangle rectangle, le cosinus d''un angle aigu est égal à :",
      "choix": [
        "opposé sur hypoténuse",
        "adjacent sur hypoténuse",
        "opposé sur adjacent"
      ],
      "bonne": 1,
      "explication": "CAH : Cosinus, Adjacent, Hypoténuse."
    },
    {
      "question": "Un élève trouve $\\cos \\widehat{A} = 1{,}4$. Que peux-tu dire ?",
      "choix": [
        "c''est possible",
        "c''est forcément une erreur",
        "cela dépend du triangle"
      ],
      "bonne": 1,
      "explication": "L''hypoténuse est le plus long côté, donc le rapport est toujours strictement inférieur à 1."
    },
    {
      "question": "Dans un triangle rectangle en $B$ avec $AB = 6$ et $AC = 10$, $\\cos \\widehat{A}$ vaut :",
      "choix": [
        "$0{,}6$",
        "$0{,}8$",
        "$1{,}67$"
      ],
      "bonne": 0,
      "explication": "$AC$ est l''hypoténuse et $AB$ l''adjacent à $\\widehat{A}$, donc $\\cos \\widehat{A} = \\dfrac{6}{10} = 0{,}6$."
    },
    {
      "question": "On connaît l''opposé et l''adjacent et on cherche l''angle. On utilise :",
      "choix": [
        "le sinus",
        "le cosinus",
        "la tangente"
      ],
      "bonne": 2,
      "explication": "TOA : la tangente relie l''opposé et l''adjacent, sans faire intervenir l''hypoténuse."
    }
  ]
}', NULL, 5),
    (v_chapitre_id, 'Exercices d''entraînement corrigés', 5, 'texte', '## Exercice 1

Dans un triangle $RST$ rectangle en $S$, $RS = 8$ cm et $ST = 15$ cm. Calcule $RT$, puis l''angle $\widehat{R}$ arrondi au degré.

Correction. Par Pythagore, $RT^{2} = 8^{2} + 15^{2} = 64 + 225 = 289$, donc $RT = 17$ cm. Pour l''angle $\widehat{R}$, l''opposé est $ST = 15$ et l''adjacent est $RS = 8$, donc $\tan \widehat{R} = \dfrac{15}{8} = 1{,}875$, et $\widehat{R} \approx 62°$.

## Exercice 2

Un toit forme un angle de 25° avec l''horizontale. Sa base horizontale mesure 4 m. Quelle est la hauteur du toit ?

Correction. La hauteur est l''opposé et la base l''adjacent, donc $\tan 25° = \dfrac{h}{4}$, soit $h = 4 \times \tan 25° \approx 4 \times 0{,}466 = 1{,}87$ m.

## Exercice 3

Dans un triangle rectangle, un angle aigu mesure 35°. Que vaut l''autre angle aigu ? Que remarques-tu entre le sinus de l''un et le cosinus de l''autre ?

Correction. La somme des angles d''un triangle vaut 180°, donc les deux angles aigus font ensemble 90°. L''autre angle mesure 55°. On constate que $\sin 35° = \cos 55° \approx 0{,}574$ : le sinus d''un angle est égal au cosinus de son complémentaire.

## Exercice 4

Du haut d''un immeuble de 30 m, on voit le pied d''un arbre sous un angle de 40° par rapport à l''horizontale. À quelle distance de l''immeuble se trouve l''arbre ?

Correction. La hauteur de 30 m est l''opposé de l''angle de 40°, et la distance cherchée est l''adjacent. Donc $\tan 40° = \dfrac{30}{d}$, soit $d = \dfrac{30}{\tan 40°} \approx \dfrac{30}{0{,}839} = 35{,}8$ m.', NULL, 15),
    (v_chapitre_id, 'Activité d''intégration : la rampe d''accès du dispensaire', 6, 'texte', '## La situation

Le dispensaire de Mbouda doit construire une rampe pour les fauteuils roulants. La porte d''entrée se trouve à 90 cm au-dessus du sol.

La norme impose que la rampe fasse un angle d''au plus 5° avec l''horizontale, pour qu''un fauteuil puisse la monter sans danger.

Le trottoir devant le dispensaire ne mesure que 9 m de profondeur.

1. Quelle longueur horizontale faudrait-il pour une rampe à exactement 5° ?
2. La rampe peut-elle tenir sur le trottoir ?
3. Si on impose une longueur horizontale de 9 m, quel angle fait la rampe ? Respecte-t-on la norme ?
4. Quelle sera alors la longueur de la rampe elle-même ?

## La solution

1. La hauteur de 90 cm, soit 0,90 m, est le côté opposé à l''angle de 5°. La longueur horizontale $d$ est le côté adjacent. Donc

$$\tan 5° = \dfrac{0{,}90}{d} \qquad \text{donc} \qquad d = \dfrac{0{,}90}{\tan 5°} \approx \dfrac{0{,}90}{0{,}0875} = 10{,}29 \text{ m}$$

Il faudrait environ 10,30 m.

2. Le trottoir ne fait que 9 m, donc la rampe droite à 5° ne tient pas. Il faudra soit un virage, soit un palier, soit accepter une pente plus forte.

3. Avec 9 m d''horizontale :

$$\tan \alpha = \dfrac{0{,}90}{9} = 0{,}1$$

La touche $\tan^{-1}$ donne $\alpha \approx 5{,}7°$. C''est supérieur à 5°, donc la norme n''est pas respectée.

4. La rampe est l''hypoténuse. On utilise le sinus :

$$\sin 5{,}7° = \dfrac{0{,}90}{L} \qquad \text{donc} \qquad L = \dfrac{0{,}90}{0{,}0993} \approx 9{,}06 \text{ m}$$

On peut aussi passer par Pythagore : $L = \sqrt{9^{2} + 0{,}90^{2}} = \sqrt{81{,}81} \approx 9{,}04$ m. Les deux résultats concordent, le petit écart vient des arrondis.

## Ce qu''il faut remarquer

La rampe mesure à peine plus que sa projection horizontale, parce que la pente est très faible. Retiens aussi la conclusion pratique : la norme n''est pas respectée, il faut donc faire un virage à 90° avec un palier, ce qui est la solution habituelle quand la place manque.', NULL, 15);

  RAISE NOTICE 'Chapitre 9, Trigonométrie dans le triangle rectangle : 6 lecons ajoutees.';
END $m3$;
