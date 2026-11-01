-- ============================================================================
-- MANDAL — Physique Terminale : chapitre 16, Superposition d''ondes mécaniques
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
    WHERE programme_id = v_programme_id AND ordre = 16;

    -- 4. sinon on le cree
    IF v_chapitre_id IS NULL THEN
      INSERT INTO public.chapitres (programme_id, titre, ordre, niveau)
      VALUES (v_programme_id, 'Superposition d''ondes mécaniques', 16, 'Module 4 : Ondes, matière et transformations nucléaires')
      RETURNING id INTO v_chapitre_id;
      RAISE NOTICE '% : chapitre 16 cree.', v_nom;
    END IF;

    -- 5. les lecons
    SELECT count(*) INTO v_deja FROM public.concepts WHERE chapitre_id = v_chapitre_id;
    IF v_deja > 0 THEN
      RAISE NOTICE '% : chapitre 16 contient deja % lecon(s) — aucun ajout.', v_nom, v_deja;
      CONTINUE;
    END IF;

    INSERT INTO public.concepts
      (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes) VALUES
      (v_chapitre_id, 'Les interférences mécaniques', 1, 'texte', 'Fais tomber deux gouttes régulièrement à la surface d''une cuve à ondes. Les deux séries de rides se croisent, et une figure étonnante apparaît : des zones où l''eau s''agite beaucoup, et d''autres où elle reste parfaitement calme.

## Le dispositif et la condition

Deux pointes $S_{1}$ et $S_{2}$ frappent la surface de l''eau à la même fréquence. Les ondes qu''elles émettent se superposent dans toute la cuve.

Pour que la figure d''interférence soit stable et observable, les deux sources doivent être **cohérentes**, c''est-à-dire avoir la même fréquence et un déphasage constant dans le temps. En pratique, on les attache à un même vibreur.

Si les sources n''étaient pas cohérentes, la figure changerait sans arrêt et l''œil ne verrait qu''un brouillage uniforme.

## La différence de marche

Considère un point $M$ de la surface, situé à la distance $d_{1}$ de $S_{1}$ et $d_{2}$ de $S_{2}$.

La **différence de marche** est
$$\delta = d_{2} - d_{1}$$

C''est elle qui décide de tout, car elle fixe le déphasage entre les deux ondes arrivant en $M$ :
$$\Delta\varphi = \dfrac{2\pi\,\delta}{\lambda}$$

## Les deux conditions à retenir

Les interférences sont **constructives** quand les deux ondes arrivent en phase. Elles s''additionnent, l''amplitude est maximale et vaut le double. Cela se produit quand
$$\delta = k\,\lambda \qquad \text{avec } k \text{ entier}$$

Les points concernés forment les **lignes ventrales**, où l''eau vibre fortement.

Les interférences sont **destructives** quand les deux ondes arrivent en opposition de phase. Elles s''annulent, et si les amplitudes sont égales l''eau reste immobile. Cela se produit quand
$$\delta = \left(k + \dfrac{1}{2}\right)\lambda$$

Les points concernés forment les **lignes nodales**, où l''eau est au repos.

Remarque le paradoxe apparent. En additionnant deux ondes, on peut obtenir le calme complet. L''énergie n''a pas disparu, elle a simplement été redistribuée vers les lignes ventrales.

## La forme des lignes

L''ensemble des points tels que $d_{2} - d_{1}$ soit constant est, en géométrie, une **hyperbole** de foyers $S_{1}$ et $S_{2}$.

La figure d''interférence est donc une famille d''hyperboles. La médiatrice de $S_{1}S_{2}$, pour laquelle $\delta = 0$, est une ligne ventrale, et c''est toujours la ligne centrale de la figure.

## Le nombre de lignes

Comme $|\delta|$ ne peut pas dépasser la distance $a = S_{1}S_{2}$, le nombre de lignes est limité. On trouve le nombre de lignes ventrales en cherchant combien d''entiers $k$ vérifient
$$|k| \leq \dfrac{a}{\lambda}$$

## Exercice d''application

Deux pointes distantes de $a = 4{,}0$ cm vibrent en phase à $25$ Hz à la surface de l''eau, où la célérité vaut $0{,}20$ m/s. Calcule la longueur d''onde. Un point $M$ est tel que $d_{1} = 5{,}6$ cm et $d_{2} = 7{,}2$ cm. Que s''y passe-t-il ? Combien y a-t-il de lignes ventrales ?

Correction. La longueur d''onde vaut
$$\lambda = \dfrac{v}{N} = \dfrac{0{,}20}{25} = 8{,}0 \times 10^{-3}\ \text{m} = 0{,}80\ \text{cm}$$

La différence de marche en $M$ vaut
$$\delta = 7{,}2 - 5{,}6 = 1{,}6\ \text{cm}$$

Le rapport vaut $\dfrac{\delta}{\lambda} = \dfrac{1{,}6}{0{,}80} = 2$, qui est un entier.

Les interférences sont donc **constructives** en $M$ : ce point se trouve sur une ligne ventrale et vibre avec une amplitude maximale.

Pour le nombre de lignes ventrales, on cherche les entiers $k$ tels que $|k| \leq \dfrac{a}{\lambda} = \dfrac{4{,}0}{0{,}80} = 5$.

Les valeurs possibles sont $k = -5, -4, -3, -2, -1, 0, 1, 2, 3, 4, 5$, soit **11 lignes ventrales** au total, dont la médiatrice qui correspond à $k = 0$.', NULL, 15),
      (v_chapitre_id, 'Les ondes stationnaires', 2, 'texte', 'Pince une corde de guitare : elle vibre en formant des fuseaux immobiles. L''onde ne semble plus se déplacer. C''est un cas particulier d''interférence, entre une onde et son propre écho.

## L''origine du phénomène

Envoie une onde le long d''une corde dont l''extrémité est fixée à un mur. L''onde se réfléchit et revient en sens inverse.

L''onde incidente et l''onde réfléchie, de même fréquence et de même amplitude mais de sens contraires, se superposent. Le résultat est une **onde stationnaire**.

## L''aspect de la corde

La corde se découpe en **fuseaux** séparés par des points immobiles.

Les **nœuds** sont les points qui ne bougent jamais. Les deux ondes y arrivent systématiquement en opposition de phase.

Les **ventres** sont les points qui vibrent avec l''amplitude maximale, égale au double de celle de chaque onde.

La distance entre deux nœuds consécutifs vaut
$$d = \dfrac{\lambda}{2}$$

C''est également la distance entre deux ventres. Entre un nœud et le ventre voisin, il y a $\dfrac{\lambda}{4}$.

Observe bien : la longueur du fuseau est la demi-longueur d''onde, pas la longueur d''onde. C''est une erreur très fréquente.

## Pourquoi on dit stationnaire

Dans une onde progressive, les crêtes avancent. Dans une onde stationnaire, elles n''avancent pas : chaque point oscille sur place avec sa propre amplitude, fixée par sa position.

Il n''y a donc pas de propagation d''énergie le long de la corde. L''énergie reste piégée entre les nœuds.

## La condition de résonance d''une corde fixée aux deux bouts

Pour une corde de longueur $L$ fixée à ses deux extrémités, les deux bouts doivent être des nœuds. La corde ne peut donc contenir qu''un nombre entier de fuseaux :
$$L = n\,\dfrac{\lambda}{2} \qquad \text{avec } n \text{ entier non nul}$$

Les longueurs d''onde possibles sont donc
$$\lambda_{n} = \dfrac{2L}{n}$$

et les fréquences correspondantes
$$N_{n} = \dfrac{v}{\lambda_{n}} = n\,\dfrac{v}{2L}$$

Seules ces fréquences particulières donnent une onde stationnaire stable. Ce sont les **modes propres** de la corde.

Le mode $n = 1$ est le **fondamental**, et les suivants sont les **harmoniques**. Les fréquences possibles sont toutes des multiples entiers du fondamental, et c''est précisément ce qui rend une corde musicale agréable à l''oreille.

## L''application aux instruments

Une corde de guitare donne une note dont la fréquence fondamentale vaut
$$N_{1} = \dfrac{v}{2L} = \dfrac{1}{2L}\sqrt{\dfrac{F}{\mu}}$$

Tu vois les trois façons de changer la note. Tu raccourcis la corde en posant un doigt sur une frette, ce qui monte le son. Tu tends davantage la corde avec la clé, ce qui monte aussi. Ou tu choisis une corde plus épaisse, donc plus lourde, ce qui descend le son.

Le même raisonnement s''applique aux tuyaux sonores, aux flûtes et au balafon.

## Exercice d''application

Une corde de $60$ cm fixée à ses deux extrémités vibre avec une célérité de $120$ m/s. Calcule la fréquence fondamentale et celle du troisième harmonique. Combien de nœuds compte-t-on au troisième harmonique ?

Correction. La fréquence fondamentale vaut
$$N_{1} = \dfrac{v}{2L} = \dfrac{120}{2 \times 0{,}60} = \dfrac{120}{1{,}20} = 100\ \text{Hz}$$

Le troisième harmonique correspond à $n = 3$, donc
$$N_{3} = 3 \times 100 = 300\ \text{Hz}$$

Au mode $n = 3$, la corde contient trois fuseaux. Chaque fuseau est bordé de deux nœuds, et les nœuds intérieurs sont partagés. On compte donc $n + 1 = 4$ nœuds au total, dont les deux extrémités fixes.

Le nombre de ventres, lui, vaut $n = 3$.', NULL, 15),
      (v_chapitre_id, 'Croise deux sources et vois les franges', 3, 'interactif', '{
  "widget": "interferences-ondes",
  "consigne": "Écarte ou rapproche les deux sources, change la fréquence, et regarde la figure d''interférence se transformer. Déplace la sonde jusqu''à trouver un point parfaitement calme, puis lis sa différence de marche. Est-elle bien un multiple impair de la demi-longueur d''onde ?"
}', NULL, 10),
      (v_chapitre_id, 'Quiz du chapitre 16', 4, 'quiz', '{
  "titre": "Vérifie que tu as compris",
  "questions": [
    {
      "question": "En un point, la différence de marche vaut exactement $3\\lambda$. Que s''y passe-t-il ?",
      "choix": [
        "Interférences destructives",
        "Interférences constructives",
        "Rien de particulier",
        "L''amplitude est divisée par deux"
      ],
      "bonne": 1,
      "explication": "La différence de marche est un multiple entier de la longueur d''onde, donc les deux ondes arrivent en phase et s''additionnent. L''amplitude est maximale, c''est une ligne ventrale."
    },
    {
      "question": "Que doivent avoir en commun deux sources pour donner des interférences observables ?",
      "choix": [
        "La même amplitude uniquement",
        "La même fréquence et un déphasage constant",
        "La même couleur uniquement",
        "Des positions symétriques"
      ],
      "bonne": 1,
      "explication": "C''est la condition de cohérence. Sans elle, le déphasage changerait sans cesse et la figure se brouillerait trop vite pour être observée."
    },
    {
      "question": "Quelle est la distance entre deux nœuds consécutifs d''une onde stationnaire ?",
      "choix": [
        "$\\lambda$",
        "$\\lambda/2$",
        "$\\lambda/4$",
        "$2\\lambda$"
      ],
      "bonne": 1,
      "explication": "La longueur d''un fuseau vaut une demi-longueur d''onde. C''est l''erreur classique de croire qu''un fuseau mesure $\\lambda$ entier."
    },
    {
      "question": "Une corde de 50 cm fixée aux deux bouts, avec une célérité de 100 m/s. Quelle est sa fréquence fondamentale ?",
      "choix": [
        "50 Hz",
        "100 Hz",
        "200 Hz",
        "400 Hz"
      ],
      "bonne": 1,
      "explication": "On applique $N_1 = v/(2L) = 100/(2 \\times 0{,}50) = 100/1{,}0 = 100$ Hz. Les harmoniques seront 200 Hz, 300 Hz, et ainsi de suite."
    },
    {
      "question": "Comment faire monter la note d''une corde de guitare ?",
      "choix": [
        "En la détendant",
        "En la raccourcissant",
        "En prenant une corde plus épaisse",
        "En la frappant plus fort"
      ],
      "bonne": 1,
      "explication": "La fréquence vaut $N_1 = \\frac{1}{2L}\\sqrt{F/\\mu}$. Raccourcir la corde diminue $L$ et augmente donc $N_1$. Frapper plus fort ne change que l''amplitude, donc le volume, pas la hauteur du son."
    }
  ]
}', NULL, 5);

    RAISE NOTICE '% : chapitre 16, Superposition d''ondes mécaniques — 4 lecons ajoutees.', v_nom;
  END LOOP;
END $ptc$;
