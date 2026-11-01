-- ============================================================================
-- MANDAL — Mathématiques 3ème : chapitre 8, Thalès dans le triangle
-- 7 leçons.
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
  WHERE programme_id = v_programme_id AND ordre = 8;

  -- 4. sinon on le cree
  IF v_chapitre_id IS NULL THEN
    INSERT INTO public.chapitres (programme_id, titre, ordre, niveau)
    VALUES (v_programme_id, 'Thalès dans le triangle', 8, 'Module 15 : Configurations et transformations élémentaires du plan')
    RETURNING id INTO v_chapitre_id;
    RAISE NOTICE 'Chapitre 8 cree.';
  END IF;

  -- 5. les lecons
  SELECT count(*) INTO v_deja FROM public.concepts WHERE chapitre_id = v_chapitre_id;
  IF v_deja > 0 THEN
    RAISE NOTICE 'Chapitre 8 : contient deja % lecon(s) — aucun ajout.', v_deja;
    RETURN;
  END IF;

  INSERT INTO public.concepts
    (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes) VALUES
    (v_chapitre_id, 'La propriété directe de Thalès', 1, 'texte', 'Comment mesurer la hauteur d''un manguier sans y grimper ? Thalès a trouvé la réponse il y a plus de deux mille ans, et sa propriété te servira toute ta scolarité.

## L''énoncé

Soit un triangle $ABC$. Soit $M$ un point de la droite $(AB)$ et $N$ un point de la droite $(AC)$. Si les droites $(MN)$ et $(BC)$ sont parallèles, alors

$$\dfrac{AM}{AB} = \dfrac{AN}{AC} = \dfrac{MN}{BC}$$

Les trois rapports sont égaux. On dit que les longueurs sont proportionnelles.

## Comment écrire les rapports sans se tromper

Range toujours les lettres dans le même ordre : sommet commun en premier, puis le point de la petite figure, et au dénominateur le point de la grande figure. Le sommet commun, ici $A$, apparaît dans tous les rapports.

## Un calcul complet

Dans un triangle $ABC$, $M$ appartient à $[AB]$ et $N$ à $[AC]$, avec $(MN)$ parallèle à $(BC)$. On donne $AM = 4$ cm, $AB = 10$ cm et $AC = 15$ cm. Calcule $AN$.

On écrit l''égalité utile :
$$\dfrac{AM}{AB} = \dfrac{AN}{AC} \qquad \text{donc} \qquad \dfrac{4}{10} = \dfrac{AN}{15}$$

On applique le produit en croix : $10 \times AN = 4 \times 15 = 60$, donc $AN = 6$ cm.

## Mesurer le manguier

Plante un bâton de 1 m à côté de l''arbre, en plein soleil. Le bâton projette une ombre de 1,60 m, l''arbre une ombre de 12 m. Les rayons du soleil sont parallèles, donc Thalès s''applique :

$$\dfrac{\text{hauteur de l''arbre}}{\text{hauteur du bâton}} = \dfrac{\text{ombre de l''arbre}}{\text{ombre du bâton}}$$

$$\dfrac{h}{1} = \dfrac{12}{1{,}60} = 7{,}5$$

Le manguier mesure 7,5 m.

## Exercice d''application

Dans un triangle $ABC$ avec $(MN)$ parallèle à $(BC)$, on a $AM = 3$, $MB = 2$ et $BC = 10$. Calcule $MN$.

Correction. D''abord $AB = AM + MB = 5$. Ensuite $\dfrac{MN}{BC} = \dfrac{AM}{AB} = \dfrac{3}{5}$, donc $MN = \dfrac{3 \times 10}{5} = 6$.', NULL, 15),
    (v_chapitre_id, 'Figure : les deux configurations de Thalès', 2, 'figure', '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 640 290" width="640" height="290" font-family="Arial, sans-serif" font-size="13"><rect width="640" height="290" fill="#ffffff"/>
<text x="320" y="20" text-anchor="middle" font-size="15" font-weight="bold">Les deux configurations de Thales</text>
<text x="150" y="42" text-anchor="middle" font-size="13" font-weight="bold" fill="#2563eb">Configuration en triangle</text>
<polygon points="150,60 40,250 260,250" fill="#eff6ff" stroke="#111827" stroke-width="2"/>
<line x1="95" y1="155" x2="205" y2="155" stroke="#dc2626" stroke-width="3"/>
<circle cx="150" cy="60" r="4" fill="#111827"/><text x="150" y="54" text-anchor="middle" font-weight="bold">A</text>
<circle cx="40" cy="250" r="4" fill="#111827"/><text x="30" y="266" font-weight="bold">B</text>
<circle cx="260" cy="250" r="4" fill="#111827"/><text x="266" y="266" font-weight="bold">C</text>
<circle cx="95" cy="155" r="4" fill="#dc2626"/><text x="78" y="152" font-weight="bold" fill="#dc2626">M</text>
<circle cx="205" cy="155" r="4" fill="#dc2626"/><text x="212" y="152" font-weight="bold" fill="#dc2626">N</text>
<text x="150" y="282" text-anchor="middle" font-size="12">(MN) est parallele a (BC)</text>
<line x1="320" y1="40" x2="320" y2="282" stroke="#cbd5e1" stroke-width="1" stroke-dasharray="6 5"/>
<text x="480" y="42" text-anchor="middle" font-size="13" font-weight="bold" fill="#7c3aed">Configuration en papillon</text>
<polygon points="480,155 390,70 570,70" fill="#f5f3ff" stroke="#111827" stroke-width="2"/>
<polygon points="480,155 390,240 570,240" fill="#faf5ff" stroke="#111827" stroke-width="2"/>
<line x1="390" y1="70" x2="570" y2="70" stroke="#2563eb" stroke-width="3"/>
<line x1="390" y1="240" x2="570" y2="240" stroke="#dc2626" stroke-width="3"/>
<circle cx="480" cy="155" r="4" fill="#111827"/><text x="486" y="160" font-weight="bold">A</text>
<circle cx="390" cy="70" r="4" fill="#2563eb"/><text x="376" y="64" font-weight="bold" fill="#2563eb">B</text>
<circle cx="570" cy="70" r="4" fill="#2563eb"/><text x="576" y="64" font-weight="bold" fill="#2563eb">C</text>
<circle cx="390" cy="240" r="4" fill="#dc2626"/><text x="374" y="256" font-weight="bold" fill="#dc2626">M</text>
<circle cx="570" cy="240" r="4" fill="#dc2626"/><text x="576" y="256" font-weight="bold" fill="#dc2626">N</text>
<text x="480" y="282" text-anchor="middle" font-size="12">A est entre B et M, (MN) parallele a (BC)</text>
</svg>', NULL, 5),
    (v_chapitre_id, 'Simulation : les trois rapports de Thalès', 3, 'interactif', '{
  "widget": "thales",
  "consigne": "Déplace le point $M$ le long de $[AB]$ et lis les trois rapports : ils restent toujours égaux. Place $M$ au milieu de $[AB]$ : les trois rapports valent $0{,}5$, donc $MN$ fait exactement la moitié de $BC$. Déforme ensuite le triangle en tirant $B$ et $C$, et vérifie que l''égalité tient quelle que soit la forme du triangle."
}', NULL, 10),
    (v_chapitre_id, 'La réciproque de la propriété de Thalès', 4, 'texte', 'La propriété directe sert à calculer des longueurs. La réciproque, elle, sert à démontrer que deux droites sont parallèles.

## L''énoncé

Soit un triangle $ABC$, un point $M$ de la droite $(AB)$ et un point $N$ de la droite $(AC)$.

Si les points $A$, $M$, $B$ d''une part et $A$, $N$, $C$ d''autre part sont alignés dans le même ordre, et si

$$\dfrac{AM}{AB} = \dfrac{AN}{AC}$$

alors les droites $(MN)$ et $(BC)$ sont parallèles.

Les deux conditions comptent. L''égalité des rapports seule ne suffit pas : il faut aussi que l''ordre des points soit le même sur les deux droites.

## Comment rédiger

Tu calcules les deux rapports séparément, puis tu compares. Si les résultats sont égaux et que l''ordre est respecté, tu conclus au parallélisme. S''ils sont différents, tu conclus que les droites ne sont pas parallèles.

## Un exemple où c''est parallèle

Dans un triangle $ABC$, $AM = 3$, $AB = 7{,}5$, $AN = 4$ et $AC = 10$, avec $M$ entre $A$ et $B$, et $N$ entre $A$ et $C$.

$$\dfrac{AM}{AB} = \dfrac{3}{7{,}5} = 0{,}4 \qquad \dfrac{AN}{AC} = \dfrac{4}{10} = 0{,}4$$

Les rapports sont égaux et l''ordre est le même, donc $(MN)$ et $(BC)$ sont parallèles.

## Un exemple où ce n''est pas parallèle

Avec $AM = 3$, $AB = 8$, $AN = 4$ et $AC = 10$ :

$$\dfrac{3}{8} = 0{,}375 \qquad \dfrac{4}{10} = 0{,}4$$

Les rapports diffèrent, donc $(MN)$ et $(BC)$ ne sont pas parallèles.

## Exercice d''application

$A$, $M$, $B$ sont alignés dans cet ordre avec $AM = 2{,}4$ et $AB = 6$. $A$, $N$, $C$ sont alignés dans cet ordre avec $AN = 3{,}2$ et $AC = 8$. Les droites $(MN)$ et $(BC)$ sont-elles parallèles ?

Correction. $\dfrac{2{,}4}{6} = 0{,}4$ et $\dfrac{3{,}2}{8} = 0{,}4$. Les rapports sont égaux et les points sont alignés dans le même ordre, donc $(MN)$ et $(BC)$ sont bien parallèles.', NULL, 15),
    (v_chapitre_id, 'Quiz : Thalès', 5, 'quiz', '{
  "titre": "Vérifie que tu as compris",
  "questions": [
    {
      "question": "Dans un triangle $ABC$ avec $(MN)$ parallèle à $(BC)$, $M$ sur $[AB]$ et $N$ sur $[AC]$, on a toujours :",
      "choix": [
        "$\\dfrac{AM}{AB} = \\dfrac{AN}{AC}$",
        "$\\dfrac{AM}{MB} = \\dfrac{AC}{AN}$",
        "$AM \\times AN = AB \\times AC$"
      ],
      "bonne": 0,
      "explication": "Les rapports se forment toujours à partir du sommet commun $A$, petit sur grand."
    },
    {
      "question": "$AM = 2$, $AB = 6$, $AC = 9$ et $(MN)$ est parallèle à $(BC)$. Alors $AN$ vaut :",
      "choix": [
        "$3$",
        "$4$",
        "$4{,}5$"
      ],
      "bonne": 0,
      "explication": "$\\dfrac{2}{6} = \\dfrac{AN}{9}$, donc $6 \\times AN = 18$ et $AN = 3$."
    },
    {
      "question": "Pour démontrer que deux droites sont parallèles, on utilise :",
      "choix": [
        "la propriété directe de Thalès",
        "la réciproque de Thalès",
        "le théorème de Pythagore"
      ],
      "bonne": 1,
      "explication": "La propriété directe calcule des longueurs quand on sait déjà que c''est parallèle. La réciproque fait l''inverse."
    },
    {
      "question": "Un piquet de 2 m donne une ombre de 3 m. Au même moment, un mur donne une ombre de 12 m. Le mur mesure :",
      "choix": [
        "$8$ m",
        "$18$ m",
        "$6$ m"
      ],
      "bonne": 0,
      "explication": "$\\dfrac{h}{2} = \\dfrac{12}{3} = 4$, donc $h = 8$ m."
    }
  ]
}', NULL, 5),
    (v_chapitre_id, 'Exercices d''entraînement corrigés', 6, 'texte', '## Exercice 1

Dans un triangle $ABC$, $M$ est sur $[AB]$ et $N$ sur $[AC]$ avec $(MN)$ parallèle à $(BC)$. On donne $AM = 5$ cm, $MB = 3$ cm et $MN = 4$ cm. Calcule $BC$.

Correction. $AB = 5 + 3 = 8$ cm. Thalès donne $\dfrac{MN}{BC} = \dfrac{AM}{AB} = \dfrac{5}{8}$. Donc $BC = \dfrac{4 \times 8}{5} = 6{,}4$ cm.

## Exercice 2

Mêmes notations, avec $AN = 4{,}2$ cm, $NC = 2{,}8$ cm et $AB = 10$ cm. Calcule $AM$.

Correction. $AC = 4{,}2 + 2{,}8 = 7$ cm. Thalès donne $\dfrac{AM}{10} = \dfrac{4{,}2}{7} = 0{,}6$, donc $AM = 6$ cm.

## Exercice 3

$A$, $M$, $B$ sont alignés dans cet ordre, ainsi que $A$, $N$, $C$. On donne $AM = 4$, $AB = 9$, $AN = 5$ et $AC = 11$. Les droites $(MN)$ et $(BC)$ sont-elles parallèles ?

Correction. $\dfrac{4}{9} \approx 0{,}444$ et $\dfrac{5}{11} \approx 0{,}455$. Les rapports sont différents, donc les droites ne sont pas parallèles.

## Exercice 4

Un arpenteur veut mesurer la largeur d''un marigot à Ebolowa. Sur la rive, il plante les points suivants : $A$ est sur sa rive, $B$ est un arbre sur l''autre rive, et il dispose $M$ et $N$ de sorte que $(MN)$ soit parallèle à la largeur cherchée. Il mesure $AM = 6$ m, $AB = 24$ m et $MN = 5$ m. Quelle est la largeur du marigot ?

Correction. Thalès donne $\dfrac{MN}{\text{largeur}} = \dfrac{AM}{AB} = \dfrac{6}{24} = 0{,}25$. Donc la largeur vaut $\dfrac{5}{0{,}25} = 20$ m.', NULL, 15),
    (v_chapitre_id, 'Activité d''intégration : la hauteur du château d''eau', 7, 'texte', '## La situation

Le château d''eau du quartier mesure une hauteur inconnue. Ange, élève de 3ème, veut la déterminer sans monter dessus.

Elle plante verticalement un bâton de 1,20 m à 18 m du pied du château d''eau. Elle se recule, s''accroupit et se place de façon à voir le sommet du bâton aligné avec le sommet du château d''eau. Son œil est alors au sol, à 2,40 m du pied du bâton.

1. Fais un schéma de la situation et repère la configuration de Thalès.
2. Calcule la hauteur du château d''eau.
3. Ange recommence avec un bâton de 1,50 m. À quelle distance du bâton devra-t-elle placer son œil pour voir le même alignement ?

## La solution

1. L''œil d''Ange, le sommet du bâton et le sommet du château d''eau sont alignés. Le bâton et le château d''eau sont tous deux verticaux, donc parallèles entre eux. En appelant $O$ la position de l''œil, $B$ le pied du bâton et $C$ le pied du château d''eau, on obtient une configuration en triangle de sommet $O$, où le bâton joue le rôle du petit segment et le château d''eau celui du grand.

2. La distance de l''œil au pied du bâton vaut 2,40 m. La distance de l''œil au pied du château d''eau vaut $2{,}40 + 18 = 20{,}40$ m. Thalès donne

$$\dfrac{1{,}20}{h} = \dfrac{2{,}40}{20{,}40}$$

Par produit en croix, $2{,}40 \times h = 1{,}20 \times 20{,}40 = 24{,}48$, donc $h = \dfrac{24{,}48}{2{,}40} = 10{,}2$ m.

Le château d''eau mesure 10,20 m.

3. Appelons $d$ la nouvelle distance de l''œil au pied du bâton. La distance au château d''eau vaut alors $d + 18$. Thalès donne

$$\dfrac{1{,}50}{10{,}2} = \dfrac{d}{d + 18}$$

Par produit en croix, $1{,}50(d + 18) = 10{,}2d$, soit $1{,}5d + 27 = 10{,}2d$, donc $8{,}7d = 27$ et $d \approx 3{,}10$ m.

Avec un bâton plus grand, elle doit se placer un peu plus loin, ce qui est logique.

## Ce qu''il faut remarquer

Cette méthode, appelée visée, ne demande qu''un bâton et un décamètre. C''est exactement ce que faisaient les arpenteurs avant les appareils modernes, et c''est ce qu''on attend de toi au BEPC : reconnaître la configuration, poser l''égalité, faire le produit en croix.', NULL, 15);

  RAISE NOTICE 'Chapitre 8, Thalès dans le triangle : 7 lecons ajoutees.';
END $m3$;
