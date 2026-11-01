-- ---------------------------------------------------------------------------
-- M'Andal — Informatique, classes de Première
-- Chapitre 10 : Les structures alternatives
-- Module 2 : Algorithmique et programmation — 7 leçons
--
-- Ce fichier remplit les trois séries d'un coup : la 1ère A, la 1ère C et la
-- 1ère D. Il n'a besoin de rien d'autre pour tourner. Si la matière, les
-- classes, les programmes ou le chapitre n'existent pas encore, il les crée
-- lui-même au passage.
--
-- Lancez-le quand vous voulez, dans l'ordre que vous voulez, et autant de fois
-- que vous voulez : quand le chapitre a déjà ses leçons, le script s'en rend
-- compte et n'ajoute rien.
-- ---------------------------------------------------------------------------
DO $inf1$
DECLARE
  v_lettres text[] := ARRAY['A', 'C', 'D'];
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
  FOR v_i IN 1..3 LOOP
    v_lettre := v_lettres[v_i];
    v_nom := '1ère ' || v_lettre;

    -- Le programme de Chimie de cette série existe-t-il déjà ?
    SELECT p.id INTO v_programme_id FROM public.programmes p
    WHERE p.titre = 'Informatique — ' || v_nom;

    -- Non : on le crée, et la classe avec si besoin.
    IF v_programme_id IS NULL THEN
      -- La classe a pu être écrite de plusieurs façons : 1ère A, 1ere A, Première A.
      SELECT id INTO v_classe_id FROM public.classes
      WHERE etablissement_id = v_etab_id
        AND (nom = v_nom OR nom ILIKE '1%re ' || v_lettre OR nom ILIKE 'Premi%re ' || v_lettre)
      ORDER BY (nom = v_nom) DESC
      LIMIT 1;

      IF v_classe_id IS NULL THEN
        INSERT INTO public.classes (etablissement_id, nom, niveau, filiere)
        VALUES (v_etab_id, v_nom, 'Première', v_lettre)
        RETURNING id INTO v_classe_id;
        RAISE NOTICE 'La classe % n''existait pas : je viens de la créer.', v_nom;
      END IF;

      INSERT INTO public.programmes (matiere_id, classe_id, etablissement_id, titre, description)
      VALUES (v_matiere_id, v_classe_id, v_etab_id, 'Informatique — ' || v_nom,
              'Programme officiel d''Informatique, classe de Première ' || v_lettre ||
              ' (Cameroun) — 3 modules, 20 chapitres.')
      RETURNING id INTO v_programme_id;
      RAISE NOTICE 'Programme d''Informatique de la % : créé.', v_nom;
    END IF;

    -- Le chapitre lui-même.
    SELECT id INTO v_chapitre_id FROM public.chapitres
    WHERE programme_id = v_programme_id AND ordre = 10;

    IF v_chapitre_id IS NULL THEN
      INSERT INTO public.chapitres (programme_id, titre, ordre, niveau)
      VALUES (v_programme_id, 'Les structures alternatives', 10, 'Module 2 : Algorithmique et programmation')
      RETURNING id INTO v_chapitre_id;
      RAISE NOTICE '% : chapitre 10 créé.', v_nom;
    END IF;

    -- Les leçons. Si le chapitre en a déjà, on passe son tour sans rien toucher.
    SELECT count(*) INTO v_deja FROM public.concepts WHERE chapitre_id = v_chapitre_id;
    IF v_deja > 0 THEN
      RAISE NOTICE '% : le chapitre 10 a déjà ses % leçons, je n''y touche pas.', v_nom, v_deja;
      CONTINUE;
    END IF;

    INSERT INTO public.concepts
      (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes) VALUES
      (v_chapitre_id, 'Si… alors… Sinon… Finsi', 1, 'texte', '
Jusqu''ici nos algorithmes exécutaient toutes leurs lignes, toujours dans le même
ordre. La **structure alternative** permet enfin de **choisir**.

### La forme simple

```
Si condition alors
    instructions
Finsi
```

Si la condition est vraie, les instructions s''exécutent. Si elle est fausse, on
saute directement après le `Finsi`.

```
Si moyenne >= 10 alors
    écrire("Admis")
Finsi
```

Avec une moyenne de 8, cet algorithme n''affiche **rien du tout**. Ce n''est pas
une erreur, c''est exactement ce qu''on lui a demandé.

### La forme complète

```
Si condition alors
    instructions si vrai
Sinon
    instructions si faux
Finsi
```

```
Si moyenne >= 10 alors
    écrire("Admis")
Sinon
    écrire("Ajourné")
Finsi
```

Maintenant, il y a toujours un affichage. Un seul des deux blocs s''exécute,
**jamais les deux**.

### Les trois règles qui coûtent des points

**Le `Finsi` est obligatoire.** Il ferme la structure, comme une parenthèse. Un
`Si` sans `Finsi` est une faute, même si le reste est juste.

**La condition est un booléen.** `Si x alors` n''a de sens que si `x` est
déclarée booléenne. Sinon, il faut écrire une comparaison : `Si x > 0 alors`.

**L''indentation n''est pas une décoration.** Décaler les instructions de
l''intérieur rend la structure lisible et t''évite d''oublier un `Finsi`. Les
correcteurs y sont attentifs.

---

**Exercice corrigé**

*Écrire un algorithme qui lit un nombre et affiche sa valeur absolue.*

**Correction.** La valeur absolue d''un nombre est ce nombre s''il est positif, et
son opposé s''il est négatif.

```
Algorithme : ValeurAbsolue

Variable
    x, va : réel ;

Début
    écrire("Entrez un nombre :")
    lire(x)
    Si x >= 0 alors
        va ← x
    Sinon
        va ← -x
    Finsi
    écrire("Valeur absolue : ", va)
Fin
```

Deux vérifications. Avec `x = 5` : la condition est vraie, `va` vaut 5. Avec
`x = -3` : la condition est fausse, `va ← -(-3)`, donc 3.

Et le cas limite, celui qu''on oublie : avec `x = 0`, la condition `0 >= 0` est
vraie, donc `va ← 0`. Correct. Si j''avais écrit `x > 0`, le zéro serait parti
dans le `Sinon`, et `va ← -0`, ce qui donne encore 0 — correct par chance. Mais
l''habitude de tester le cas limite doit rester : neuf fois sur dix, il révèle
une vraie erreur.
', NULL, 25),
      (v_chapitre_id, 'Simulation : suivre le chemin d''un Si', 2, 'interactif', '{
  "widget": "si-alors-sinon",
  "consigne": "Écris une condition, donne une valeur à la variable, et regarde le chemin s''allumer dans l''algorithme : la branche prise en vert, la branche ignorée en gris. La simulation insiste sur les cas limites — l''égalité exacte, le zéro, la valeur négative — et te propose de remplacer >= par > pour voir basculer le cas limite d''une branche à l''autre."
}', NULL, 10),
      (v_chapitre_id, 'Les conditions composées et les Si imbriqués', 3, 'texte', '
### Les conditions composées

Quand une décision dépend de plusieurs critères, on combine avec `et`, `ou`,
`non`.

```
Si (moyenne >= 10) et (absences < 5) alors
    écrire("Admis")
Sinon
    écrire("Cas examiné par le conseil")
Finsi
```

Attention à ne pas écrire une condition **impossible**. `Si (x > 10) et (x < 5)`
ne sera jamais vraie : aucun nombre n''est à la fois plus grand que 10 et plus
petit que 5. Tu voulais sans doute `ou`.

Et à l''inverse, `Si (x > 5) ou (x > 10)` est toujours équivalente à `x > 5` : la
seconde partie n''ajoute rien.

### Les Si imbriqués

Un `Si` peut contenir un autre `Si`. C''est ainsi qu''on traite plus de deux cas.

*Afficher la mention d''un élève selon sa moyenne.*

```
Si moyenne >= 16 alors
    écrire("Très bien")
Sinon
    Si moyenne >= 14 alors
        écrire("Bien")
    Sinon
        Si moyenne >= 12 alors
            écrire("Assez bien")
        Sinon
            Si moyenne >= 10 alors
                écrire("Passable")
            Sinon
                écrire("Ajourné")
            Finsi
        Finsi
    Finsi
Finsi
```

Compte les `Finsi` : il y en a **quatre**, autant que de `Si`. C''est la
vérification à faire systématiquement.

**L''ordre des tests est capital.** Il faut aller du plus exigeant au moins
exigeant. Si tu commençais par `Si moyenne >= 10 alors écrire("Passable")`, un
élève à 18 obtiendrait « Passable », parce que 18 est bien supérieur à 10 et
que le premier test qui réussit l''emporte.

C''est l''erreur la plus fréquente de tout le module. Teste toujours ton
algorithme de mentions avec la **meilleure** note possible.

### Pourquoi on n''a pas besoin de répéter la borne basse

Dans la branche `Sinon` du premier test, on **sait déjà** que `moyenne < 16`.
Inutile donc d''écrire `Si (moyenne >= 14) et (moyenne < 16)` : la seconde
condition est garantie par l''endroit où l''on se trouve. C''est toute l''économie
des `Si` imbriqués.

---

**Exercice corrigé**

*Écrire un algorithme qui lit trois nombres et affiche le plus grand.*

**Correction.**

```
Algorithme : PlusGrandDeTrois

Variable
    a, b, c, max : réel ;

Début
    écrire("Entrez trois nombres :")
    lire(a, b, c)
    max ← a
    Si b > max alors
        max ← b
    Finsi
    Si c > max alors
        max ← c
    Finsi
    écrire("Le plus grand est : ", max)
Fin
```

La méthode mérite d''être comprise plutôt qu''apprise : on **suppose** que le
premier est le plus grand, puis on **corrige** si l''on trouve mieux. Trois
nombres, deux comparaisons.

L''avantage est qu''elle se généralise. Avec dix nombres, on ne multiplierait pas
les `Si` imbriqués : on garderait ce même schéma dans une boucle, que nous
verrons au chapitre suivant.

Déroulons avec `a = 4`, `b = 9`, `c = 2` : `max ← 4`, puis `9 > 4` donc
`max ← 9`, puis `2 > 9` est faux donc on ne touche à rien. L''algorithme affiche
9.
', NULL, 28),
      (v_chapitre_id, 'Simulation : les mentions, et le piège de l''ordre', 4, 'interactif', '{
  "widget": "conditions-composees",
  "consigne": "L''algorithme des mentions t''est donné avec ses quatre Si imbriqués, et tu peux réordonner les tests à la souris. Mets le test de 10 en premier, entre la note 18, et regarde l''élève excellent repartir avec « Passable » : la simulation surligne le test qui a réussi trop tôt. Un volet voisin te fait évaluer des conditions composées et signale celles qui ne peuvent jamais être vraies."
}', NULL, 10),
      (v_chapitre_id, 'La structure à choix multiples', 5, 'texte', '
Quand on compare **une même variable** à une **liste de valeurs précises**, les
`Si` imbriqués deviennent lourds. Le LDA offre alors une structure plus claire.

### La forme

```
Selon variable faire
    valeur1 : instructions
    valeur2 : instructions
    valeur3 : instructions
    Autre : instructions
FinSelon
```

### Un exemple

*Afficher le nom du jour à partir de son numéro.*

```
Selon n faire
    1 : écrire("Lundi")
    2 : écrire("Mardi")
    3 : écrire("Mercredi")
    4 : écrire("Jeudi")
    5 : écrire("Vendredi")
    6 : écrire("Samedi")
    7 : écrire("Dimanche")
    Autre : écrire("Numéro invalide")
FinSelon
```

Compare avec ce qu''il aurait fallu écrire en `Si` imbriqués : sept niveaux
d''imbrication et sept `Finsi`. Le `Selon` dit la même chose en lisant une seule
fois la variable.

### Quand l''utiliser, et quand ne pas l''utiliser

Le `Selon` convient quand on teste l''**égalité** d''une variable à des valeurs
**énumérables** : un numéro de jour, une lettre de série, un code.

Il ne convient **pas** pour des **intervalles**. On ne peut pas écrire
`Selon moyenne faire  10..12 : …`. Les mentions de la leçon précédente exigent
donc des `Si` imbriqués.

Le `Autre` — qu''on écrit parfois `Sinon` ou `Défaut` — attrape toutes les
valeurs non prévues. L''oublier est une faute d''examen classique : que se
passe-t-il si l''utilisateur tape 9 ?

---

**Exercice corrigé**

*Écrire un algorithme qui lit la lettre de la série d''un élève de Première (A,
C ou D) et affiche sa matière dominante.*

**Correction.**

```
Algorithme : SerieDominante

Variable
    serie : caractère ;

Début
    écrire("Entrez la série (A, C ou D) :")
    lire(serie)
    Selon serie faire
        ''A'' : écrire("Dominante : Lettres et Philosophie")
        ''C'' : écrire("Dominante : Mathématiques et Sciences Physiques")
        ''D'' : écrire("Dominante : Sciences de la Vie et de la Terre")
        Autre : écrire("Série inconnue")
    FinSelon
Fin
```

Trois remarques sur la correction.

La variable est déclarée **caractère** et non chaîne, car il s''agit d''un seul
signe. Les valeurs sont donc entre **apostrophes** et non entre guillemets.

Le `Autre` est indispensable. Sans lui, un élève tapant « E » ou « c » n''aurait
aucune réponse.

D''ailleurs, les majuscules et les minuscules sont deux caractères différents.
Un algorithme robuste testerait `''A''` et `''a''` — en LDA on écrit alors
`''A'', ''a'' : …` sur la même ligne.
', NULL, 25),
      (v_chapitre_id, 'Simulation : Selon ou Si imbriqués ?', 6, 'interactif', '{
  "widget": "selon-cas",
  "consigne": "Huit problèmes te sont posés, et tu choisis pour chacun la structure la plus adaptée : un numéro de jour, un intervalle de moyennes, une lettre de série, un âge. La simulation écrit alors les deux versions côte à côte pour que tu voies laquelle est lisible, et refuse le Selon quand il s''agit d''intervalles en t''expliquant pourquoi c''est impossible."
}', NULL, 10),
      (v_chapitre_id, 'Quiz du chapitre 10', 7, 'quiz', '{
  "titre": "Vérifie que tu as compris",
  "questions": [
    {
      "question": "Que fait Si moyenne >= 10 alors écrire(« Admis ») Finsi quand la moyenne vaut 8 ?",
      "choix": [
        "Il affiche « Ajourné »",
        "Il n''affiche rien du tout",
        "Il affiche « Admis »",
        "Il provoque une erreur"
      ],
      "bonne": 1,
      "explication": "Sans Sinon, la branche fausse ne fait rien. Ce n''est pas une erreur : c''est exactement ce qu''on a demandé."
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
      "explication": "Autant de Finsi que de Si : c''est la vérification à faire systématiquement avant de rendre sa copie."
    },
    {
      "question": "Dans un algorithme de mentions, pourquoi faut-il tester les moyennes de la plus haute à la plus basse ?",
      "choix": [
        "Pour aller plus vite",
        "Parce que le premier test qui réussit l''emporte : en commençant par 10, un élève à 18 obtiendrait « Passable »",
        "C''est une convention d''écriture",
        "Pour économiser des Finsi"
      ],
      "bonne": 1,
      "explication": "C''est l''erreur la plus fréquente du module. Teste toujours ton algorithme de mentions avec la MEILLEURE note possible."
    },
    {
      "question": "La condition Si (x > 10) et (x < 5) est :",
      "choix": [
        "vraie pour x = 7",
        "jamais vraie, aucun nombre ne vérifie les deux",
        "vraie pour x = 12",
        "toujours vraie"
      ],
      "bonne": 1,
      "explication": "Aucun nombre n''est à la fois plus grand que 10 et plus petit que 5. L''auteur voulait sans doute écrire ou."
    },
    {
      "question": "Dans la branche Sinon d''un test moyenne >= 16, que sait-on déjà ?",
      "choix": [
        "Rien de particulier",
        "Que la moyenne est strictement inférieure à 16",
        "Que la moyenne vaut 14",
        "Que la moyenne est supérieure à 16"
      ],
      "bonne": 1,
      "explication": "C''est toute l''économie des Si imbriqués : inutile de réécrire la borne haute, l''endroit où l''on se trouve la garantit."
    },
    {
      "question": "Pour quel type de test la structure Selon convient-elle ?",
      "choix": [
        "Des intervalles de valeurs",
        "L''égalité d''une variable à des valeurs précises et énumérables",
        "Des conditions composées avec et et ou",
        "Des boucles"
      ],
      "bonne": 1,
      "explication": "Un numéro de jour, une lettre de série, un code. Pour des intervalles comme les mentions, il faut des Si imbriqués."
    },
    {
      "question": "À quoi sert la clause Autre d''un Selon ?",
      "choix": [
        "À fermer la structure",
        "À traiter toutes les valeurs non prévues par les autres cas",
        "À déclarer la variable",
        "À répéter le premier cas"
      ],
      "bonne": 1,
      "explication": "L''oublier est une faute d''examen classique : que se passe-t-il si l''utilisateur tape une valeur à laquelle vous n''avez pas pensé ?"
    }
  ]
}', NULL, 5);

    RAISE NOTICE '% : 7 leçons ajoutées au chapitre 10, Les structures alternatives.', v_nom;
  END LOOP;
END $inf1$;
