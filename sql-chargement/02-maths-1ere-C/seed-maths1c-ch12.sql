-- ============================================================================
-- MANDAL — Mathématiques 1ère C : chapitre 12, Introduction à la théorie des graphes
-- Module 22 : Organisation et gestion des données
-- 6 leçons.
--
-- Autonome : ce fichier cree lui-meme la matiere, la classe, le programme et
-- le chapitre s'ils n'existent pas encore. Lancez-le seul, dans n'importe
-- quel ordre.
-- Idempotent : si le chapitre contient deja des lecons, rien n'est ajoute.
-- ============================================================================
DO $p1c$
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
  WHERE p.titre = 'Mathématiques — 1ère C';

  -- 2. sinon on le cree
  IF v_programme_id IS NULL THEN
    INSERT INTO public.matieres (nom) VALUES ('Mathématiques') ON CONFLICT (nom) DO NOTHING;
    SELECT id INTO v_matiere_id FROM public.matieres WHERE nom = 'Mathématiques';

    SELECT count(DISTINCT etablissement_id) INTO v_nb_etabs FROM public.classes;
    IF v_nb_etabs <> 1 THEN
      RAISE EXCEPTION 'Impossible de deduire l''etablissement : % etablissement(s) distinct(s) dans public.classes.', v_nb_etabs;
    END IF;
    SELECT etablissement_id INTO v_etab_id FROM public.classes LIMIT 1;

    -- la classe, quelle que soit la facon dont elle a ete ecrite
    SELECT id INTO v_classe_id FROM public.classes
    WHERE etablissement_id = v_etab_id
      AND (nom = '1ère C' OR nom ILIKE '1%re C' OR nom ILIKE 'Premi%re C')
    ORDER BY (nom = '1ère C') DESC
    LIMIT 1;

    -- si elle n'existe pas, on la cree
    IF v_classe_id IS NULL THEN
      INSERT INTO public.classes (etablissement_id, nom, niveau, filiere)
      VALUES (v_etab_id, '1ère C', 'Première', 'C')
      RETURNING id INTO v_classe_id;
      RAISE NOTICE 'Classe "1ère C" creee.';
    END IF;

    INSERT INTO public.programmes (matiere_id, classe_id, etablissement_id, titre, description)
    VALUES (v_matiere_id, v_classe_id, v_etab_id, 'Mathématiques — 1ère C',
            'Programme officiel de Mathématiques, classe de Première C (Cameroun) — 4 modules, 21 chapitres.')
    RETURNING id INTO v_programme_id;
    RAISE NOTICE 'Programme "Mathématiques — 1ère C" cree.';
  END IF;

  -- 3. le chapitre existe-t-il deja ?
  SELECT id INTO v_chapitre_id FROM public.chapitres
  WHERE programme_id = v_programme_id AND ordre = 12;

  -- 4. sinon on le cree
  IF v_chapitre_id IS NULL THEN
    INSERT INTO public.chapitres (programme_id, titre, ordre, niveau)
    VALUES (v_programme_id, 'Introduction à la théorie des graphes', 12, 'Module 22 : Organisation et gestion des données')
    RETURNING id INTO v_chapitre_id;
    RAISE NOTICE 'Chapitre 12 cree.';
  END IF;

  -- 5. les lecons
  SELECT count(*) INTO v_deja FROM public.concepts WHERE chapitre_id = v_chapitre_id;
  IF v_deja > 0 THEN
    RAISE NOTICE 'Chapitre 12 : contient deja % lecon(s) — aucun ajout.', v_deja;
    RETURN;
  END IF;

  INSERT INTO public.concepts
    (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes) VALUES
    (v_chapitre_id, 'Le vocabulaire des graphes', 1, 'texte', 'Un graphe, c''est un dessin fait de points reliés par des traits. Derrière cette simplicité se cache un outil qui sert à organiser des tournées, colorier des cartes ou planifier des travaux.

## Les mots de base

Les points s''appellent des sommets. Les traits s''appellent des arêtes.

L''ordre d''un graphe est son nombre de sommets.

Le degré d''un sommet est le nombre d''arêtes qui en partent.

Deux sommets reliés par une arête sont dits adjacents, ou voisins.

## Le théorème des poignées de main

La somme de tous les degrés vaut deux fois le nombre d''arêtes.
$$\sum \text{degrés} = 2 \times \text{nombre d''arêtes}$$

La raison est simple : chaque arête possède deux extrémités, et elle est donc comptée deux fois.

Conséquence immédiate : dans tout graphe, le nombre de sommets de degré impair est pair. Il ne peut pas y en avoir trois, par exemple.

## Les graphes particuliers

Un graphe est simple s''il n''a ni boucle ni arête double.

Un graphe est complet si tous les sommets sont reliés deux à deux. Le graphe complet d''ordre $n$ possède $C_{n}^{2} = \dfrac{n(n-1)}{2}$ arêtes.

Un graphe est connexe si on peut aller de n''importe quel sommet à n''importe quel autre en suivant les arêtes.

## La matrice d''adjacence

On numérote les sommets, puis on écrit un tableau carré où la case de la ligne $i$ et de la colonne $j$ vaut 1 si les sommets sont reliés, 0 sinon.

Cette matrice est symétrique, puisqu''une arête relie dans les deux sens. La diagonale est nulle s''il n''y a pas de boucle.

Le nombre de 1 sur une ligne donne le degré du sommet correspondant.

## Un exemple camerounais

Imagine les villes Douala, Yaoundé, Bafoussam, Bertoua et Ngaoundéré. Deux villes sont reliées s''il existe une route directe entre elles.

Si Douala est reliée à Yaoundé et à Bafoussam, son degré est 2. Si Yaoundé est reliée à Douala, Bafoussam et Bertoua, son degré est 3.

Le graphe est connexe si l''on peut rejoindre toutes les villes, quitte à passer par d''autres.

## Exercice d''application

Un graphe possède 6 sommets dont les degrés sont 1, 2, 2, 3, 3 et 3. Combien a-t-il d''arêtes ? Est-ce cohérent ?

Correction. La somme des degrés vaut $1 + 2 + 2 + 3 + 3 + 3 = 14$, donc il y a 7 arêtes.

Le nombre de sommets de degré impair vaut 4, c''est-à-dire un nombre pair. Le graphe est donc possible.', NULL, 15),
    (v_chapitre_id, 'Construis ton propre graphe', 2, 'interactif', '{
  "widget": "graphe-adjacence",
  "consigne": "Supprime des arêtes jusqu''à ce que le graphe ne soit plus connexe : un sommet passe alors en gris. Reconstruis-le ensuite de façon à n''avoir que des degrés pairs, et lis ce que t''annonce le bandeau du bas."
}', NULL, 10),
    (v_chapitre_id, 'Un graphe de villes du Cameroun', 3, 'figure', '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 600 400" width="600" height="400" font-family="system-ui, Arial" font-size="13">
<rect width="600" height="400" fill="#ffffff"/>
<text x="300" y="26" text-anchor="middle" font-weight="700" fill="#0f172a">Liaisons routières directes entre six villes</text>
<g stroke="#2563eb" stroke-width="2.6" opacity="0.75">
<line x1="120" y1="300" x2="300" y2="250"/>
<line x1="120" y1="300" x2="160" y2="150"/>
<line x1="300" y1="250" x2="160" y2="150"/>
<line x1="300" y1="250" x2="450" y2="200"/>
<line x1="160" y1="150" x2="330" y2="90"/>
<line x1="330" y1="90" x2="450" y2="200"/>
<line x1="450" y1="200" x2="500" y2="330"/>
<line x1="300" y1="250" x2="500" y2="330"/>
</g>
<g>
<circle cx="120" cy="300" r="21" fill="#16a34a"/><circle cx="300" cy="250" r="21" fill="#16a34a"/>
<circle cx="160" cy="150" r="21" fill="#16a34a"/><circle cx="330" cy="90" r="21" fill="#16a34a"/>
<circle cx="450" cy="200" r="21" fill="#16a34a"/><circle cx="500" cy="330" r="21" fill="#16a34a"/>
</g>
<g fill="#ffffff" font-weight="700" font-size="15" text-anchor="middle">
<text x="120" y="306">D</text><text x="300" y="256">Y</text><text x="160" y="156">B</text>
<text x="330" y="96">F</text><text x="450" y="206">N</text><text x="500" y="336">G</text>
</g>
<g fill="#334155" font-size="12" text-anchor="middle">
<text x="120" y="340">Douala</text><text x="300" y="290">Yaoundé</text><text x="160" y="190">Bafoussam</text>
<text x="330" y="60">Foumban</text><text x="450" y="240">Ngaoundéré</text><text x="500" y="370">Garoua</text>
</g>
<g fill="#64748b" font-size="11" text-anchor="middle">
<text x="120" y="268">degré 2</text><text x="300" y="218">degré 4</text><text x="160" y="118">degré 3</text>
<text x="330" y="122">degré 2</text><text x="450" y="170">degré 3</text><text x="500" y="352">degré 2</text>
</g>
<text x="300" y="378" text-anchor="middle" fill="#334155" font-size="12">Somme des degrés = 16 = 2 × 8 arêtes.</text>
<text x="300" y="394" text-anchor="middle" fill="#334155" font-size="12">Deux sommets de degré impair, B et N : il existe une chaîne eulérienne de B à N.</text>
</svg>', NULL, 5),
    (v_chapitre_id, 'Chaînes, cycles et connexité', 4, 'texte', 'Maintenant qu''on sait décrire un graphe, on va s''y promener.

## Chaîne et longueur

Une chaîne est une suite d''arêtes qui se suivent. Sa longueur est son nombre d''arêtes.

Une chaîne est fermée si elle revient à son point de départ. On parle alors de cycle lorsque, en plus, elle ne repasse pas deux fois par la même arête.

## Connexité

Un graphe est connexe si deux sommets quelconques sont toujours reliés par au moins une chaîne.

Sinon, il se découpe en plusieurs morceaux, appelés composantes connexes.

Pour tester la connexité à la main, pars d''un sommet, marque tous ses voisins, puis les voisins de ses voisins, et continue. Si tu finis par marquer tous les sommets, le graphe est connexe.

## Les graphes eulériens

Une chaîne eulérienne est une chaîne qui emprunte chaque arête du graphe une fois et une seule. Si elle revient à son point de départ, on parle de cycle eulérien.

Le théorème d''Euler répond exactement à la question. Un graphe connexe admet une chaîne eulérienne si et seulement si il possède zéro ou deux sommets de degré impair.

S''il y en a zéro, il y a même un cycle eulérien, et tu peux partir de n''importe où.

S''il y en a deux, la chaîne commence à l''un de ces deux sommets et se termine à l''autre.

S''il y en a plus de deux, c''est impossible.

## L''histoire des ponts de Königsberg

Au dix-huitième siècle, les habitants de cette ville cherchaient un parcours qui traverserait chacun des sept ponts une seule fois. Euler a montré que c''était impossible, parce que les quatre quartiers avaient tous un degré impair.

C''est l''acte de naissance de la théorie des graphes, à partir d''un problème de promenade.

## Les arbres

Un arbre est un graphe connexe sans cycle.

Un arbre d''ordre $n$ possède toujours exactement $n - 1$ arêtes. Si tu en retires une, il n''est plus connexe. Si tu en ajoutes une, il contient un cycle.

C''est la structure la plus économique pour relier des points : un réseau électrique qui dessert $n$ villages a besoin d''au moins $n - 1$ lignes.

## Exercice d''application

Dans le graphe des six villes, les degrés sont 2 pour Douala, 4 pour Yaoundé, 3 pour Bafoussam, 2 pour Foumban, 3 pour Ngaoundéré et 2 pour Garoua. Un camion peut-il emprunter chaque route une fois et une seule ?

Correction. Les sommets de degré impair sont Bafoussam et Ngaoundéré, soit exactement deux.

Le graphe est connexe. Il existe donc une chaîne eulérienne, mais pas de cycle. Le camion doit partir de Bafoussam et finir à Ngaoundéré, ou l''inverse. Il ne pourra pas revenir à son point de départ.', NULL, 15),
    (v_chapitre_id, 'Les graphes au service de problèmes concrets', 5, 'texte', 'Voici trois usages des graphes que tu peux rencontrer à l''examen, et qui servent vraiment dans la vie.

## La coloration et les conflits d''horaires

Colorier un graphe, c''est attribuer une couleur à chaque sommet de façon que deux sommets voisins n''aient jamais la même.

Le nombre chromatique est le plus petit nombre de couleurs qui suffit.

Imagine qu''un lycée de Yaoundé doive organiser cinq examens, et que certains élèves soient inscrits à deux examens à la fois. Chaque examen est un sommet, et une arête relie deux examens qui ont au moins un élève en commun.

Colorier le graphe, c''est répartir les examens en créneaux horaires. Deux examens reliés ne peuvent pas avoir le même créneau.

Le nombre chromatique donne alors le nombre minimal de créneaux nécessaires.

Un encadrement utile : le nombre chromatique est toujours au moins égal à la taille de la plus grande clique, c''est-à-dire du plus grand sous-graphe complet, et au plus égal au plus grand degré augmenté de 1.

## Le plus court chemin

Quand les arêtes portent des nombres, on parle de graphe pondéré. Le poids peut être une distance, un temps ou un coût.

Pour trouver le plus court chemin entre deux sommets, tu procèdes par étapes. Tu pars du sommet de départ avec la valeur 0. Tu regardes ses voisins et tu notes la distance pour les atteindre. Tu choisis le plus proche non encore traité, tu le fixes, puis tu mets à jour ses voisins.

Tu continues jusqu''à atteindre l''arrivée.

Par exemple, pour aller de Douala à Garoua, tu compares le trajet par Yaoundé et celui par Bafoussam, en additionnant les kilomètres de chaque arête, et tu gardes le plus petit total.

## Le réseau le moins cher

Pour relier des villages par un réseau électrique au coût minimal, tu cherches un arbre couvrant de poids minimal.

L''idée est de trier toutes les liaisons possibles du moins cher au plus cher, puis d''ajouter les liaisons une par une, en sautant celles qui créeraient un cycle. Tu t''arrêtes quand tous les villages sont reliés.

Avec $n$ villages, tu auras ajouté exactement $n - 1$ liaisons.

## Un exemple chiffré

Cinq villages doivent être reliés. Les coûts en millions de FCFA sont : A-B 4, A-C 7, B-C 3, B-D 8, C-D 5, C-E 9, D-E 6.

Tu tries : B-C 3, A-B 4, C-D 5, D-E 6, A-C 7, B-D 8, C-E 9.

Tu prends B-C, puis A-B, puis C-D, puis D-E. Les cinq villages sont reliés avec 4 liaisons.

Le coût total vaut $3 + 4 + 5 + 6 = 18$ millions de FCFA.

Tu as sauté A-C, B-D et C-E parce qu''elles auraient refermé un cycle sans rien relier de nouveau.

## Exercice d''application

Six matières d''examen, numérotées de 1 à 6. Les couples qui ont des élèves en commun sont 1-2, 1-3, 2-3, 3-4, 4-5, 5-6 et 4-6. Combien de créneaux au minimum ?

Correction. Les matières 1, 2 et 3 forment un triangle, donc elles ont besoin de trois couleurs différentes. Il en faut donc au moins trois.

Essayons avec trois. Donne la couleur A à 1, B à 2, C à 3. Alors 4 est voisin de 3 seulement, on lui donne A. Ensuite 5 est voisin de 4, on lui donne B. Enfin 6 est voisin de 5 et de 4, on lui donne C.

Trois couleurs suffisent, donc il faut exactement trois créneaux.', NULL, 15),
    (v_chapitre_id, 'Quiz du chapitre 12', 6, 'quiz', '{
  "titre": "Vérifie que tu as compris",
  "questions": [
    {
      "question": "La somme des degrés de tous les sommets d''un graphe vaut :",
      "choix": [
        "deux fois le nombre d''arêtes",
        "le nombre d''arêtes",
        "le nombre de sommets",
        "le carré du nombre d''arêtes"
      ],
      "bonne": 0,
      "explication": "Chaque arête a deux extrémités, elle est donc comptée dans le degré de deux sommets."
    },
    {
      "question": "Un graphe connexe admet une chaîne eulérienne lorsqu''il a :",
      "choix": [
        "zéro ou deux sommets de degré impair",
        "tous ses sommets de degré pair uniquement",
        "au moins trois sommets impairs",
        "un nombre pair de sommets"
      ],
      "bonne": 0,
      "explication": "C''est le théorème d''Euler. Avec zéro sommet impair on obtient même un cycle, qui revient au point de départ."
    },
    {
      "question": "Un arbre d''ordre n possède exactement :",
      "choix": [
        "n − 1 arêtes",
        "n arêtes",
        "n + 1 arêtes",
        "n(n − 1)/2 arêtes"
      ],
      "bonne": 0,
      "explication": "C''est la structure connexe la plus économique. Une arête de moins le coupe en deux, une de plus crée un cycle."
    },
    {
      "question": "Dans la matrice d''adjacence, le nombre de 1 sur une ligne donne :",
      "choix": [
        "le degré du sommet correspondant",
        "le nombre total d''arêtes",
        "l''ordre du graphe",
        "le nombre chromatique"
      ],
      "bonne": 0,
      "explication": "Chaque 1 de la ligne correspond à un voisin du sommet, donc à une arête qui en part."
    },
    {
      "question": "Un graphe complet d''ordre 6 possède :",
      "choix": [
        "15 arêtes",
        "6 arêtes",
        "30 arêtes",
        "12 arêtes"
      ],
      "bonne": 0,
      "explication": "Chaque paire de sommets est reliée, il y en a C(2, 6) = 6×5/2 = 15."
    },
    {
      "question": "Un graphe contient un triangle. Son nombre chromatique est au moins :",
      "choix": [
        "3",
        "2",
        "4",
        "1"
      ],
      "bonne": 0,
      "explication": "Les trois sommets du triangle sont deux à deux voisins, il leur faut donc trois couleurs différentes."
    }
  ]
}', NULL, 5);

  RAISE NOTICE 'Chapitre 12, Introduction à la théorie des graphes : 6 lecons ajoutees.';
END $p1c$;
