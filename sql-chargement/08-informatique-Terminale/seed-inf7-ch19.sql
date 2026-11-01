-- ---------------------------------------------------------------------------
-- M'Andal — Informatique, classes de Terminale
-- Chapitre 19 : Les structures de contrôle
-- Module 3 : Algorithme et programmation — 8 leçons
--
-- Ce fichier remplit les deux séries d'un coup : la Terminale C et la
-- Terminale D. Il n'a besoin de rien d'autre pour tourner. Si la matière, les
-- classes, les programmes ou le chapitre n'existent pas encore, il les crée
-- lui-même au passage.
--
-- Lancez-le quand vous voulez, dans l'ordre que vous voulez, et autant de fois
-- que vous voulez : quand le chapitre a déjà ses leçons, le script s'en rend
-- compte et n'ajoute rien.
-- ---------------------------------------------------------------------------
DO $inf7$
DECLARE
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
  -- La matière Chimie : on ne la crée qu'une fois pour toutes.
  INSERT INTO public.matieres (nom) VALUES ('Informatique') ON CONFLICT (nom) DO NOTHING;
  SELECT id INTO v_matiere_id FROM public.matieres WHERE nom = 'Informatique';

  -- L'établissement, on le retrouve à partir des classes déjà en base.
  SELECT count(DISTINCT etablissement_id) INTO v_nb_etabs FROM public.classes;
  IF v_nb_etabs <> 1 THEN
    RAISE EXCEPTION 'Je ne sais pas à quel établissement rattacher ces classes : j''en trouve % dans la table des classes, et il m''en faudrait exactement un.', v_nb_etabs;
  END IF;
  SELECT etablissement_id INTO v_etab_id FROM public.classes LIMIT 1;

  -- On refait le même travail trois fois : pour la 1ère C, puis la D, puis la E.
  FOR v_i IN 1..2 LOOP
    v_lettre := v_lettres[v_i];
    v_nom := 'Terminale ' || v_lettre;

    -- Le programme de Chimie de cette série existe-t-il déjà ?
    SELECT p.id INTO v_programme_id FROM public.programmes p
    WHERE p.titre = 'Informatique — ' || v_nom;

    -- Non : on le crée, et la classe avec si besoin.
    IF v_programme_id IS NULL THEN
      -- La classe a pu être écrite de plusieurs façons : Terminale C, Tle C, TC.
      SELECT id INTO v_classe_id FROM public.classes
      WHERE etablissement_id = v_etab_id
        AND (nom = v_nom OR nom ILIKE 'T%le ' || v_lettre OR nom ILIKE 'Terminale ' || v_lettre)
      ORDER BY (nom = v_nom) DESC
      LIMIT 1;

      IF v_classe_id IS NULL THEN
        INSERT INTO public.classes (etablissement_id, nom, niveau, filiere)
        VALUES (v_etab_id, v_nom, 'Terminale', v_lettre)
        RETURNING id INTO v_classe_id;
        RAISE NOTICE 'La classe % n''existait pas : je viens de la créer.', v_nom;
      END IF;

      INSERT INTO public.programmes (matiere_id, classe_id, etablissement_id, titre, description)
      VALUES (v_matiere_id, v_classe_id, v_etab_id, 'Informatique — ' || v_nom,
              'Programme officiel d''Informatique, classe de Terminale ' || v_lettre ||
              ' (Cameroun) — 3 modules, 25 chapitres.')
      RETURNING id INTO v_programme_id;
      RAISE NOTICE 'Programme d''Informatique de la % : créé.', v_nom;
    END IF;

    -- Le chapitre lui-même.
    SELECT id INTO v_chapitre_id FROM public.chapitres
    WHERE programme_id = v_programme_id AND ordre = 19;

    IF v_chapitre_id IS NULL THEN
      INSERT INTO public.chapitres (programme_id, titre, ordre, niveau)
      VALUES (v_programme_id, 'Les structures de contrôle', 19, 'Module 3 : Algorithme et programmation')
      RETURNING id INTO v_chapitre_id;
      RAISE NOTICE '% : chapitre 19 créé.', v_nom;
    END IF;

    -- Les leçons. Si le chapitre en a déjà, on passe son tour sans rien toucher.
    SELECT count(*) INTO v_deja FROM public.concepts WHERE chapitre_id = v_chapitre_id;
    IF v_deja > 0 THEN
      RAISE NOTICE '% : le chapitre 19 a déjà ses % leçons, je n''y touche pas.', v_nom, v_deja;
      CONTINUE;
    END IF;

    INSERT INTO public.concepts
      (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes) VALUES
      (v_chapitre_id, 'L''algorithme et ses trois familles de structures', 1, 'texte', '
Dernier module du programme, et celui qui vaut **6 points** à l''épreuve.

### Rappel : l''algorithme

Un **algorithme** est une **suite finie et ordonnée d''instructions** permettant
de résoudre un problème donné.

Il s''écrit en **LDA**, le langage de description d''algorithme, et se compose de
trois parties : l''**en-tête**, les **déclarations**, et le **corps** entre
`Début` et `Fin`.

```
Algorithme : Admission

Variable
    moy : réel ;

Début
    lire(moy)
    Si moy >= 10 alors
        écrire("Admis")
    Sinon
        écrire("Ajourné")
    Finsi
Fin
```

### Ce qu''est une structure de contrôle

Une **structure de contrôle** est une construction qui **décide de l''ordre dans
lequel les instructions sont exécutées**.

Sans elle, un algorithme exécuterait ses lignes de haut en bas, toujours toutes,
toujours une fois. Les structures de contrôle permettent d''en **sauter**
certaines, ou d''en **répéter** d''autres.

### Les trois familles

**La structure séquentielle.** Les instructions s''exécutent **l''une après
l''autre, dans l''ordre d''écriture**, toutes et une seule fois. C''est le
comportement par défaut.

**Les structures alternatives**, ou conditionnelles. Elles **choisissent** entre
plusieurs chemins selon une condition. Un seul chemin est exécuté.

En LDA : `Si … alors … Sinon … Finsi` et `Selon … FinSelon`.

**Les structures répétitives**, ou itératives, ou boucles. Elles **répètent** un
bloc d''instructions.

En LDA : `TantQue … FinTantQue`, `Répéter … Jusqu''à`, et `Pour … FinPour`.

### La question d''examen

« **Nommer deux structures de contrôle utilisables** » est tombée au
Baccalauréat 2024 pour un point. La réponse la plus sûre cite une alternative
et une répétitive : **`Si … alors … Sinon`** et **`TantQue … faire`**.

Si l''on demande les **familles**, on répond : **séquentielle, alternative et
répétitive**.

---

**Exercice corrigé**

*Définir le terme « algorithme », puis nommer deux structures de contrôle
utilisables pour décider si un élève est admis, sachant qu''il faut au moins 10
de moyenne.*

**Correction.**

Un **algorithme** est une **suite finie et ordonnée d''instructions** permettant
de résoudre un problème donné.

*Deux structures de contrôle utilisables ici :*

la structure **alternative `Si … alors … Sinon … Finsi`**, qui choisit entre
« Admis » et « Ajourné » selon que la moyenne atteint 10 ou non ;

la structure **répétitive `TantQue … faire`**, si l''on veut traiter plusieurs
élèves à la suite sans réécrire le test à chaque fois.

*L''algorithme attendu :*

```
Algorithme : Admission

Variable
    moy : réel ;

Début
    écrire("Entrez la moyenne :")
    lire(moy)
    Si moy >= 10 alors
        écrire("Admis")
    Sinon
        écrire("Refusé")
    Finsi
Fin
```

*Ces trois questions forment l''exercice 1 de la partie III du Baccalauréat
2024, noté sur 3 points.*
', NULL, 26),
      (v_chapitre_id, 'Figure : les trois familles de structures de contrôle', 2, 'figure', '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 560 240" width="560" height="240">
<rect width="560" height="240" fill="#ffffff"/>
<text x="280" y="22" text-anchor="middle" font-size="14" font-weight="700" fill="#0f172a">Les trois familles de structures de contrôle</text>

<text x="92" y="48" text-anchor="middle" font-size="11" font-weight="700" fill="#2563eb">SÉQUENTIELLE</text>
<rect x="46" y="60" width="92" height="24" rx="3" fill="#dbeafe" stroke="#2563eb" stroke-width="1.4"/>
<text x="92" y="76" text-anchor="middle" font-size="9" fill="#1e3a8a">lire(x)</text>
<line x1="92" y1="84" x2="92" y2="98" stroke="#334155" stroke-width="1.6"/>
<polygon points="92,104 87,94 97,94" fill="#334155"/>
<rect x="46" y="104" width="92" height="24" rx="3" fill="#dbeafe" stroke="#2563eb" stroke-width="1.4"/>
<text x="92" y="120" text-anchor="middle" font-size="9" fill="#1e3a8a">y ← x * 2</text>
<line x1="92" y1="128" x2="92" y2="142" stroke="#334155" stroke-width="1.6"/>
<polygon points="92,148 87,138 97,138" fill="#334155"/>
<rect x="46" y="148" width="92" height="24" rx="3" fill="#dbeafe" stroke="#2563eb" stroke-width="1.4"/>
<text x="92" y="164" text-anchor="middle" font-size="9" fill="#1e3a8a">écrire(y)</text>
<text x="92" y="200" text-anchor="middle" font-size="9" fill="#64748b">une instruction</text>
<text x="92" y="214" text-anchor="middle" font-size="9" fill="#64748b">après l&apos;autre</text>

<text x="280" y="48" text-anchor="middle" font-size="11" font-weight="700" fill="#15803d">ALTERNATIVE</text>
<polygon points="280,60 334,86 280,112 226,86" fill="#dcfce7" stroke="#15803d" stroke-width="1.4"/>
<text x="280" y="90" text-anchor="middle" font-size="9" fill="#14532d">x &gt;= 10 ?</text>
<line x1="226" y1="86" x2="196" y2="86" stroke="#334155" stroke-width="1.4"/>
<line x1="196" y1="86" x2="196" y2="130" stroke="#334155" stroke-width="1.4"/>
<line x1="334" y1="86" x2="364" y2="86" stroke="#334155" stroke-width="1.4"/>
<line x1="364" y1="86" x2="364" y2="130" stroke="#334155" stroke-width="1.4"/>
<text x="210" y="80" font-size="8" fill="#b91c1c">non</text>
<text x="340" y="80" font-size="8" fill="#15803d">oui</text>
<rect x="156" y="130" width="80" height="24" rx="3" fill="#fee2e2" stroke="#b91c1c" stroke-width="1.2"/>
<text x="196" y="146" text-anchor="middle" font-size="9" fill="#7f1d1d">Ajourné</text>
<rect x="324" y="130" width="80" height="24" rx="3" fill="#dcfce7" stroke="#15803d" stroke-width="1.2"/>
<text x="364" y="146" text-anchor="middle" font-size="9" fill="#14532d">Admis</text>
<text x="280" y="200" text-anchor="middle" font-size="9" fill="#64748b">un chemin</text>
<text x="280" y="214" text-anchor="middle" font-size="9" fill="#64748b">ou l&apos;autre</text>

<text x="468" y="48" text-anchor="middle" font-size="11" font-weight="700" fill="#ca8a04">RÉPÉTITIVE</text>
<polygon points="468,60 516,84 468,108 420,84" fill="#fef3c7" stroke="#ca8a04" stroke-width="1.4"/>
<text x="468" y="88" text-anchor="middle" font-size="9" fill="#78350f">i &lt;= 5 ?</text>
<rect x="422" y="128" width="92" height="24" rx="3" fill="#fef3c7" stroke="#ca8a04" stroke-width="1.4"/>
<text x="468" y="144" text-anchor="middle" font-size="9" fill="#78350f">i ← i + 1</text>
<line x1="468" y1="108" x2="468" y2="122" stroke="#334155" stroke-width="1.4"/>
<polygon points="468,128 463,118 473,118" fill="#334155"/>
<path d="M 514 140 L 540 140 L 540 84 L 516 84" fill="none" stroke="#ca8a04" stroke-width="1.6"/>
<polygon points="516,84 526,79 526,89" fill="#ca8a04"/>
<line x1="420" y1="84" x2="396" y2="84" stroke="#334155" stroke-width="1.4"/>
<text x="400" y="78" font-size="8" fill="#b91c1c">non</text>
<text x="468" y="200" text-anchor="middle" font-size="9" fill="#64748b">on recommence</text>
<text x="468" y="214" text-anchor="middle" font-size="9" fill="#64748b">tant qu&apos;il faut</text>
</svg>', NULL, 5),
      (v_chapitre_id, 'Simulation : reconnaître la famille', 3, 'interactif', '{
  "widget": "familles-structures",
  "consigne": "Douze fragments d''algorithme défilent, et tu dois dire de quelle famille relève chacun : séquentielle, alternative ou répétitive. La simulation dessine ensuite l''organigramme du fragment — la flèche droite de la séquence, le losange de l''alternative, la boucle de retour de la répétitive — et suit le chemin d''exécution avec une valeur que tu choisis."
}', NULL, 10),
      (v_chapitre_id, 'Les structures alternatives', 4, 'texte', '
### Si … alors … Finsi

```
Si condition alors
    instructions
Finsi
```

Si la condition est **vraie**, le bloc s''exécute. Si elle est **fausse**, on
saute directement après le `Finsi` — et **rien** ne se passe.

### Si … alors … Sinon … Finsi

```
Si condition alors
    instructions si vrai
Sinon
    instructions si faux
Finsi
```

**Un seul des deux blocs s''exécute**, jamais les deux.

### Les Si imbriqués

Pour traiter plus de deux cas, on place un `Si` dans le `Sinon` du précédent.

```
Si moy >= 16 alors
    écrire("Très bien")
Sinon
    Si moy >= 14 alors
        écrire("Bien")
    Sinon
        Si moy >= 12 alors
            écrire("Assez bien")
        Sinon
            Si moy >= 10 alors
                écrire("Passable")
            Sinon
                écrire("Ajourné")
            Finsi
        Finsi
    Finsi
Finsi
```

**Autant de `Finsi` que de `Si`** : c''est la vérification à faire avant de
rendre.

**Et l''ordre est capital.** Il faut aller **du plus exigeant au moins
exigeant**. Si l''on testait `moy >= 10` en premier, un élève à 18 obtiendrait
« Passable », parce que le premier test qui réussit l''emporte.

C''est l''erreur la plus fréquente du module. **Teste toujours ton algorithme de
mentions avec la meilleure note possible.**

### Selon … FinSelon

Quand on compare **une même variable** à des **valeurs précises et
énumérables**, le `Selon` est plus lisible.

```
Selon jour faire
    1 : écrire("Lundi")
    2 : écrire("Mardi")
    3 : écrire("Mercredi")
    Autre : écrire("Numéro invalide")
FinSelon
```

**Il ne convient pas aux intervalles.** On ne peut pas écrire
`Selon moy faire 10..12 : …`. Les mentions exigent donc des `Si` imbriqués.

**La clause `Autre` est obligatoire en pratique** : sans elle, une valeur non
prévue ne produit rien du tout.

### Les conditions composées

On combine avec **`et`**, **`ou`**, **`non`**.

```
Si (moy >= 10) et (absences < 5) alors
```

**`et`** exige les deux, **`ou`** se contente d''une seule. Mets des
**parenthèses** dès que tu mélanges les deux.

---

**Exercice corrigé**

*Écrire un algorithme qui lit trois notes, calcule la moyenne, et affiche la
mention correspondante.*

**Correction.**

```
Algorithme : Mention

Variable
    n1, n2, n3, moy : réel ;

Début
    écrire("Entrez les trois notes :")
    lire(n1, n2, n3)
    moy ← (n1 + n2 + n3) / 3

    Si moy >= 16 alors
        écrire("Très bien")
    Sinon
        Si moy >= 14 alors
            écrire("Bien")
        Sinon
            Si moy >= 12 alors
                écrire("Assez bien")
            Sinon
                Si moy >= 10 alors
                    écrire("Passable")
                Sinon
                    écrire("Ajourné")
                Finsi
            Finsi
        Finsi
    Finsi
Fin
```

*Vérification avec la meilleure note.* Avec trois notes de 18, la moyenne vaut
18. Le premier test `18 >= 16` réussit : l''algorithme affiche « Très bien ». Si
l''ordre avait été inversé, il aurait affiché « Passable ».

*Compte les `Finsi`* : il y en a **quatre**, autant que de `Si`.
', NULL, 28),
      (v_chapitre_id, 'Simulation : dérouler une alternative', 5, 'interactif', '{
  "widget": "alternatives-lda",
  "consigne": "L''algorithme des mentions s''affiche avec ses quatre Si imbriqués, et tu peux réordonner les tests à la souris. Entre une note et regarde le chemin s''allumer, test par test, jusqu''à celui qui réussit. Mets le test de 10 en premier, entre 18, et vois l''excellent élève repartir avec « Passable ». Un second volet compare le même problème écrit en Si imbriqués et en Selon, et te montre pourquoi le Selon est impossible ici."
}', NULL, 10),
      (v_chapitre_id, 'Les structures répétitives', 6, 'texte', '
### TantQue … faire … FinTantQue

```
TantQue condition faire
    instructions
FinTantQue
```

La condition est **testée au début**, et le bloc se répète **tant qu''elle est
vraie**.

**Trois ingrédients obligatoires**, et en oublier un est l''erreur numéro un :

l''**initialisation** avant la boucle ;
la **condition** ;
la **progression** dans le bloc, qui rapproche de la sortie.

```
i ← 1
TantQue i <= 5 faire
    écrire(i)
    i ← i + 1
FinTantQue
```

Sans la ligne `i ← i + 1`, `i` reste à 1 pour toujours : c''est la **boucle
infinie**.

Et si la condition est fausse dès le départ, le bloc **ne s''exécute pas une
seule fois**.

### Répéter … Jusqu''à

```
Répéter
    instructions
Jusqu''à condition
```

Deux différences avec le `TantQue`, et ce sont elles qu''on demande en examen :

la condition est **testée à la fin**, donc le bloc s''exécute **toujours au moins
une fois** ;

on **sort quand la condition devient vraie** — alors qu''on **reste** tant que
celle du `TantQue` est vraie. Les deux conditions sont donc **opposées**.

```
i ← 1
Répéter
    écrire(i)
    i ← i + 1
Jusqu''à i > 5
```

Son terrain naturel : le **contrôle de saisie**, puisqu''on ne peut pas vérifier
une valeur qu''on n''a pas encore lue.

```
Répéter
    écrire("Entrez une note entre 0 et 20 :")
    lire(note)
Jusqu''à (note >= 0) et (note <= 20)
```

### Pour … faire … FinPour

```
Pour i de debut à fin faire
    instructions
FinPour
```

Quand on connaît **le nombre de tours à l''avance**. Le **compteur est géré
automatiquement** : initialisé, augmenté de 1 à chaque tour, et la boucle
s''arrête après la valeur finale.

Conséquence : une boucle `Pour` **ne peut pas être infinie**. En contrepartie,
on ne **modifie jamais** le compteur à l''intérieur du bloc.

### La variable drapeau

C''est une notion du programme de Terminale, et elle est tombée au Baccalauréat
2023.

Une **variable drapeau** est une variable **booléenne** qui **mémorise qu''un
évènement s''est produit** pendant une boucle.

```
trouve ← faux
i ← 1
TantQue (i <= N) et (trouve = faux) faire
    Si tab[i] = x alors
        trouve ← vrai
    Sinon
        i ← i + 1
    Finsi
FinTantQue
```

Elle sert ici à **sortir de la boucle dès qu''on a trouvé**, sans parcourir le
reste. On la reconnaît à trois signes : elle est **booléenne**, elle est
**initialisée à faux avant la boucle**, et elle **apparaît dans la condition**
de la boucle.

### Le tableau de comparaison

| | Test | Tours au minimum | On sort quand |
| --- | --- | --- | --- |
| **TantQue** | au début | **0** | la condition devient **fausse** |
| **Répéter** | à la fin | **1** | la condition devient **vraie** |
| **Pour** | compteur automatique | 0 | le compteur dépasse la fin |

---

**Exercice corrigé**

*Dans l''algorithme ci-dessous, identifier la variable drapeau, puis remplacer la
boucle TantQue par une boucle Répéter … Jusqu''à.*

```
lire(x)
trouve ← faux
i ← 1
TantQue (i <= N) et (trouve = faux) faire
    Si numero[i] = x alors
        trouve ← vrai
    Sinon
        i ← i + 1
    Finsi
FinTantQue
```

**Correction.**

*La variable drapeau est `trouve`.* C''est un **booléen**, **initialisé à faux**
avant la boucle, qui **mémorise** qu''on a trouvé la valeur et **apparaît dans la
condition** de sortie.

*La version avec Répéter … Jusqu''à :*

```
lire(x)
trouve ← faux
i ← 1
Répéter
    Si numero[i] = x alors
        trouve ← vrai
    Sinon
        i ← i + 1
    Finsi
Jusqu''à (i > N) ou (trouve = vrai)
```

*Les deux transformations à faire, et à justifier en copie.*

La **condition est inversée** : on restait tant que `(i <= N) et (trouve =
faux)`, on sort quand `(i > N) ou (trouve = vrai)`. Le « et » devient « ou », et
chaque comparaison est inversée.

Le **`Sinon` doit incrémenter `i`**, sinon la boucle ne progresse plus et tourne
indéfiniment. Plusieurs corrigés en circulation l''oublient.

*Attention aussi au cas où le tableau est vide : le `Répéter` ferait un tour
quand même et lirait `numero[1]`, qui n''existe pas. Le `TantQue` d''origine, lui,
ne faisait aucun tour.*

*Cet exercice est celui du Baccalauréat 2023, partie III, noté sur 3 points.*
', NULL, 32),
      (v_chapitre_id, 'Simulation : les trois boucles côte à côte', 7, 'interactif', '{
  "widget": "repetitives-lda",
  "consigne": "Les trois boucles tournent en parallèle sur la même donnée, avec leur compteur et leur condition affichés. Rends la condition fausse dès le départ : le TantQue ne fait aucun tour, le Répéter en fait un, et tu vois la différence essentielle en une seconde. Supprime la ligne de progression du TantQue et la simulation détecte la boucle infinie au centième tour. Un dernier volet suit une variable drapeau passer de faux à vrai au milieu d''une recherche."
}', NULL, 10),
      (v_chapitre_id, 'Quiz du chapitre 19', 8, 'quiz', '{
  "titre": "Vérifie que tu as compris",
  "questions": [
    {
      "question": "Quelles sont les trois familles de structures de contrôle ?",
      "choix": [
        "Si, TantQue et Pour",
        "Séquentielle, alternative et répétitive",
        "Début, corps et fin",
        "Lecture, traitement et écriture"
      ],
      "bonne": 1,
      "explication": "La séquentielle exécute dans l''ordre, l''alternative choisit un chemin, la répétitive recommence."
    },
    {
      "question": "Combien de Finsi faut-il pour quatre Si imbriqués ?",
      "choix": [
        "Un seul",
        "Deux",
        "Quatre",
        "Aucun"
      ],
      "bonne": 2,
      "explication": "Autant de Finsi que de Si : c''est la vérification à faire avant de rendre sa copie."
    },
    {
      "question": "Pourquoi faut-il tester les mentions de la plus haute à la plus basse ?",
      "choix": [
        "Pour aller plus vite",
        "Parce que le premier test qui réussit l''emporte : en commençant par 10, un élève à 18 obtiendrait « Passable »",
        "C''est une convention d''écriture",
        "Pour économiser des Finsi"
      ],
      "bonne": 1,
      "explication": "C''est l''erreur la plus fréquente du module. Teste toujours avec la MEILLEURE note possible."
    },
    {
      "question": "Quels sont les trois ingrédients obligatoires d''un TantQue ?",
      "choix": [
        "Début, milieu, fin",
        "L''initialisation, la condition et la progression",
        "Le compteur, le test et le FinTantQue",
        "lire, traiter, écrire"
      ],
      "bonne": 1,
      "explication": "Sans progression, la condition reste vraie pour toujours : c''est la boucle infinie."
    },
    {
      "question": "Quelle différence essentielle entre TantQue et Répéter ?",
      "choix": [
        "Aucune",
        "Le TantQue teste au début et peut ne faire aucun tour ; le Répéter teste à la fin et en fait toujours au moins un",
        "Le Répéter est plus rapide",
        "Le TantQue ne marche qu''avec des entiers"
      ],
      "bonne": 1,
      "explication": "Et leurs conditions sont opposées : on reste tant que celle du TantQue est vraie, on sort quand celle du Répéter le devient."
    },
    {
      "question": "Qu''est-ce qu''une variable drapeau ?",
      "choix": [
        "Le compteur d''une boucle Pour",
        "Une variable booléenne qui mémorise qu''un évènement s''est produit pendant une boucle",
        "Une constante",
        "Un tableau de booléens"
      ],
      "bonne": 1,
      "explication": "On la reconnaît à trois signes : booléenne, initialisée à faux avant la boucle, et présente dans la condition de sortie."
    },
    {
      "question": "Pour quelle tâche la boucle Répéter est-elle la plus adaptée ?",
      "choix": [
        "Afficher les dix premiers entiers",
        "Contrôler une saisie jusqu''à obtenir une valeur valide",
        "Parcourir un tableau de taille connue",
        "Calculer une somme"
      ],
      "bonne": 1,
      "explication": "On ne peut pas vérifier une valeur qu''on n''a pas encore lue : il faut donc au moins un tour, et c''est exactement ce que garantit le Répéter."
    }
  ]
}', NULL, 5);

    RAISE NOTICE '% : 8 leçons ajoutées au chapitre 19, Les structures de contrôle.', v_nom;
  END LOOP;
END $inf7$;
