-- ---------------------------------------------------------------------------
-- M'Andal — Informatique, classes de Première
-- Chapitre 16 : Les formulaires
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
    WHERE programme_id = v_programme_id AND ordre = 16;

    IF v_chapitre_id IS NULL THEN
      INSERT INTO public.chapitres (programme_id, titre, ordre, niveau)
      VALUES (v_programme_id, 'Les formulaires', 16, 'Module 2 : Algorithmique et programmation')
      RETURNING id INTO v_chapitre_id;
      RAISE NOTICE '% : chapitre 16 créé.', v_nom;
    END IF;

    -- Les leçons. Si le chapitre en a déjà, on passe son tour sans rien toucher.
    SELECT count(*) INTO v_deja FROM public.concepts WHERE chapitre_id = v_chapitre_id;
    IF v_deja > 0 THEN
      RAISE NOTICE '% : le chapitre 16 a déjà ses % leçons, je n''y touche pas.', v_nom, v_deja;
      CONTINUE;
    END IF;

    INSERT INTO public.concepts
      (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes) VALUES
      (v_chapitre_id, 'À quoi sert un formulaire', 1, 'texte', '
Jusqu''ici nos pages **montraient** des choses. Un formulaire permet au visiteur
de **donner** une information : s''inscrire, répondre à un quiz, envoyer un
message.

### La balise form

```
<form action="traitement.php" method="post">
  ... les champs ...
  <input type="submit" value="Envoyer">
</form>
```

Tous les champs doivent être **à l''intérieur** du `form`. Un champ placé dehors
s''affiche, mais son contenu n''est **jamais envoyé** — c''est une erreur silencieuse
et donc redoutable.

### Les deux attributs

**`action`** donne l''**adresse du programme** qui va recevoir et traiter les
données. Rappelle-toi : le HTML ne sait pas calculer. Il **collecte**, il
n''enregistre rien. C''est un programme — en PHP, en Python — qui reçoit et
traite.

**`method`** dit **comment** les données voyagent. Deux valeurs possibles, et la
comparaison est une question d''examen.

| | `get` | `post` |
| --- | --- | --- |
| où vont les données | dans l''**adresse**, visibles dans la barre | dans le **corps** de la requête, invisibles |
| quantité | limitée | sans limite pratique |
| peut-on mettre la page en favori | oui, l''adresse contient tout | non |
| à utiliser pour | une **recherche** | un **envoi**, une inscription, un mot de passe |

La règle pratique : **`get` pour lire, `post` pour écrire**. Un mot de passe
passe toujours en `post` — sinon il s''afficherait en clair dans la barre
d''adresse, et resterait dans l''historique du navigateur.

### L''attribut qui compte le plus

Chaque champ doit porter un **`name`**. C''est l''**étiquette** sous laquelle sa
valeur arrivera au programme.

```
<input type="text" name="nom">
```

Sans `name`, le champ est rempli par le visiteur, envoyé avec le reste… et
**perdu**, parce que le programme ne sait pas sous quel nom le retrouver.
Retiens-le : **un champ sans `name` ne sert à rien.**

---

**Exercice corrigé**

*Un formulaire de connexion demande un nom d''utilisateur et un mot de passe.
Quelle méthode d''envoi faut-il choisir, et pourquoi ?*

**Correction.** La méthode **`post`**.

Avec `get`, les données sont placées dans l''**adresse** de la page. Le mot de
passe apparaîtrait donc en clair dans la barre du navigateur, sous une forme du
genre `connexion.php?nom=thierry&mdp=secret123`.

Trois conséquences : il serait **lisible** par quiconque regarde l''écran, il
serait **conservé** dans l''historique du navigateur, et il serait **enregistré**
dans les journaux de tous les serveurs traversés.

Avec `post`, les données voyagent dans le corps de la requête, invisibles dans
l''adresse. C''est la méthode obligatoire pour tout envoi de données
confidentielles.

*Précision honnête : `post` cache les données de l''adresse, il ne les chiffre
pas. Pour une vraie protection, il faut en plus que le site soit en `https`.*
', NULL, 25),
      (v_chapitre_id, 'Simulation : get ou post ?', 2, 'interactif', '{
  "widget": "formulaire-html",
  "consigne": "Un même formulaire est envoyé deux fois, en get puis en post, et la simulation te montre la barre d''adresse dans les deux cas : d''un côté le mot de passe s''étale en clair, de l''autre l''adresse reste propre. Tu peux ensuite retirer l''attribut name d''un champ, renvoyer, et constater que sa valeur n''arrive jamais de l''autre côté."
}', NULL, 10),
      (v_chapitre_id, 'Les champs de saisie', 3, 'texte', '
La balise `input` fait presque tout le travail. Elle est **orpheline**, et c''est
son attribut `type` qui décide de ce qu''elle devient.

### Les principaux types

```
<input type="text" name="nom">
```
Une ligne de texte : nom, ville, matière.

```
<input type="password" name="mdp">
```
Comme `text`, mais les caractères s''affichent en points.

```
<input type="radio" name="serie" value="C"> 1ère C
<input type="radio" name="serie" value="D"> 1ère D
```
Des **boutons radio** : un **seul choix** parmi plusieurs. Pour qu''ils
s''excluent, ils doivent porter **le même `name`** — c''est ce qui les regroupe.
Donne-leur des `name` différents et le visiteur pourra tout cocher.

```
<input type="checkbox" name="option1" value="oui"> J''accepte
```
Une **case à cocher** : chacune est indépendante, on peut en cocher plusieurs ou
aucune.

```
<input type="submit" value="Envoyer">
```
Le **bouton d''envoi**. Son `value` est le texte écrit sur le bouton.

```
<input type="reset" value="Effacer">
```
Le bouton qui **vide** le formulaire.

```
<input type="file" name="devoir">
```
Un sélecteur de **fichier**, pour envoyer un document.

```
<input type="hidden" name="classe" value="1ereC">
```
Un champ **invisible** : le visiteur ne le voit pas, mais sa valeur est envoyée.

### Radio contre checkbox

C''est la comparaison la plus demandée du chapitre.

**Radio** : un seul choix possible dans le groupe. Une série, un sexe, un
niveau. Les champs d''un groupe partagent le même `name`.

**Checkbox** : plusieurs choix possibles, chacun indépendant. Des matières
optionnelles, des conditions acceptées. Chaque case a son propre `name`.

### Quelques attributs utiles

`value` donne la valeur **envoyée** — ou, sur un bouton, le texte affiché.
`placeholder` affiche un exemple grisé **dans** le champ, qui disparaît à la
saisie.
`required` rend le champ **obligatoire** : le navigateur refuse l''envoi s''il est
vide.
`checked` présélectionne un bouton radio ou une case.
`maxlength` limite le nombre de caractères.

---

**Exercice corrigé**

*Écrire les champs d''un formulaire d''inscription demandant le nom, un mot de
passe, la série (A, C ou D — un seul choix) et l''acceptation du règlement.*

**Correction.**

```
<p>
  Nom :
  <input type="text" name="nom" required>
</p>

<p>
  Mot de passe :
  <input type="password" name="mdp" required>
</p>

<p>
  Série :
  <input type="radio" name="serie" value="A"> A
  <input type="radio" name="serie" value="C" checked> C
  <input type="radio" name="serie" value="D"> D
</p>

<p>
  <input type="checkbox" name="reglement" value="accepte" required>
  J''accepte le règlement
</p>

<input type="submit" value="M''inscrire">
```

Les points décisifs.

Le mot de passe est en `type="password"`, pas en `text`.

Les trois boutons radio portent **le même `name="serie"`** mais des `value`
**différentes**. C''est exactement l''inverse de ce que font les débutants, qui
leur donnent trois `name` différents — et se retrouvent avec trois boutons
cochables en même temps.

Le règlement est une `checkbox`, parce qu''il n''y a qu''une seule chose à accepter
et qu''on peut la refuser. Un radio seul serait impossible à décocher.

Et chaque champ a son `name`, sans quoi sa valeur serait perdue.
', NULL, 28),
      (v_chapitre_id, 'Simulation : les types de champs', 4, 'interactif', '{
  "widget": "champs-input",
  "consigne": "Tous les types d''input te sont donnés à essayer dans un formulaire vivant, avec le code à côté. Donne trois name différents à trois boutons radio et coche-les tous les trois : la simulation te montre le défaut, puis le corrige sous tes yeux en leur rendant le même name. Un panneau affiche en permanence ce qui serait réellement envoyé au serveur."
}', NULL, 10),
      (v_chapitre_id, 'Les listes déroulantes, les zones de texte et les étiquettes', 5, 'texte', '
### La liste déroulante

```
<select name="classe">
  <option value="1A">1ère A</option>
  <option value="1C" selected>1ère C</option>
  <option value="1D">1ère D</option>
</select>
```

`select` ouvre la liste, chaque `option` est un choix. L''attribut `value` donne
ce qui sera **envoyé** ; le texte entre les balises est ce que le visiteur
**lit**. `selected` présélectionne une option.

Quand les choix sont nombreux — une liste de régions, de matières — le `select`
est plus propre que vingt boutons radio.

### La zone de texte

```
<textarea name="message" rows="5" cols="40">
</textarea>
```

Pour un texte **sur plusieurs lignes** : un message, un commentaire.

Attention, `textarea` n''est **pas** orpheline : elle a une balise de fermeture,
et ce qui se trouve entre les deux est le texte initial. Laisse-les donc collées
si tu veux une zone vide.

### L''étiquette

```
<label for="nom">Votre nom :</label>
<input type="text" id="nom" name="nom">
```

Le `for` du `label` reprend l''`id` du champ. Cela crée un lien entre les deux :
cliquer sur l''étiquette place le curseur dans le champ, et les logiciels pour
aveugles savent annoncer de quoi il s''agit.

C''est la bonne manière d''écrire un formulaire, et elle ne coûte presque rien.

### Le regroupement

```
<fieldset>
  <legend>Informations personnelles</legend>
  ... les champs ...
</fieldset>
```

`fieldset` **encadre** un groupe de champs, `legend` lui donne un **titre**
inscrit sur le cadre. Dans un long formulaire, cela sépare visuellement les
parties.

---

**Exercice corrigé**

*Écrire un formulaire complet d''inscription à la plateforme M''Andal,
correctement regroupé et étiqueté, qui envoie ses données à `inscription.php`.*

**Correction.**

```
<form action="inscription.php" method="post">

  <fieldset>
    <legend>Identité</legend>

    <p>
      <label for="nom">Nom et prénom :</label>
      <input type="text" id="nom" name="nom" required>
    </p>

    <p>
      <label for="classe">Classe :</label>
      <select id="classe" name="classe">
        <option value="1A">1ère A</option>
        <option value="1C">1ère C</option>
        <option value="1D">1ère D</option>
      </select>
    </p>
  </fieldset>

  <fieldset>
    <legend>Compte</legend>

    <p>
      <label for="mdp">Mot de passe :</label>
      <input type="password" id="mdp" name="mdp" required>
    </p>
  </fieldset>

  <fieldset>
    <legend>Un mot sur vous</legend>
    <textarea name="presentation" rows="4" cols="40"></textarea>
  </fieldset>

  <p>
    <input type="submit" value="M''inscrire">
    <input type="reset" value="Effacer">
  </p>

</form>
```

Reprenons les décisions.

La méthode est `post`, puisqu''il y a un mot de passe et qu''il s''agit d''un envoi.

Chaque champ a un `name` — l''étiquette d''arrivée — et un `id` — la cible du
`label`. Les deux peuvent porter le même mot, et c''est l''usage, mais ils ne
servent pas à la même chose : le `name` parle au serveur, l''`id` parle à la
page.

Un `select` pour la classe, parce que les trois séries sont une liste fermée.

Un `textarea` pour la présentation, parce que c''est un texte libre sur plusieurs
lignes.

Trois `fieldset` pour séparer les parties du formulaire.

Et le tout **à l''intérieur** du `form` : c''est la condition pour que quoi que ce
soit arrive à `inscription.php`.
', NULL, 30),
      (v_chapitre_id, 'Simulation : assembler un formulaire complet', 6, 'interactif', '{
  "widget": "formulaire-complet",
  "consigne": "Un formulaire d''inscription à assembler pièce par pièce, en tirant les champs depuis une palette. Un bouton Envoyer simule la réception côté serveur et affiche le couple nom-valeur de chaque donnée reçue, avec un avertissement pour tout champ sans name ou posé hors du form. Les labels se testent en cliquant dessus : si le for ne correspond pas à l''id, rien ne se passe."
}', NULL, 10),
      (v_chapitre_id, 'Quiz du chapitre 16', 7, 'quiz', '{
  "titre": "Vérifie que tu as compris",
  "questions": [
    {
      "question": "À quoi sert l''attribut action de la balise form ?",
      "choix": [
        "À choisir la méthode d''envoi",
        "À donner l''adresse du programme qui recevra et traitera les données",
        "À valider les champs",
        "À nommer le formulaire"
      ],
      "bonne": 1,
      "explication": "Le HTML collecte mais ne traite rien : c''est un programme en PHP ou Python, à l''adresse indiquée par action, qui reçoit les données."
    },
    {
      "question": "Quelle est la différence essentielle entre get et post ?",
      "choix": [
        "Aucune",
        "get place les données dans l''adresse, où elles sont visibles ; post les place dans le corps de la requête, invisibles",
        "get est plus rapide",
        "post ne fonctionne qu''en HTTPS"
      ],
      "bonne": 1,
      "explication": "La règle pratique : get pour lire, post pour écrire. Un mot de passe passe toujours en post, sinon il s''afficherait dans la barre d''adresse."
    },
    {
      "question": "Que se passe-t-il si un champ n''a pas d''attribut name ?",
      "choix": [
        "Il ne s''affiche pas",
        "Il s''affiche et se remplit, mais sa valeur n''arrive jamais au programme",
        "Le formulaire refuse de s''envoyer",
        "Rien, name est facultatif"
      ],
      "bonne": 1,
      "explication": "C''est une erreur silencieuse, et donc redoutable. Le name est l''étiquette sous laquelle la valeur arrive : sans elle, elle est perdue."
    },
    {
      "question": "Comment faire pour que des boutons radio s''excluent mutuellement ?",
      "choix": [
        "Leur donner des name différents",
        "Leur donner le même name",
        "Leur donner le même value",
        "Ajouter required à chacun"
      ],
      "bonne": 1,
      "explication": "C''est le name identique qui les regroupe. Avec trois name différents, le visiteur pourrait cocher les trois en même temps."
    },
    {
      "question": "Quand utilise-t-on une checkbox plutôt qu''un bouton radio ?",
      "choix": [
        "Quand il n''y a qu''un seul choix possible",
        "Quand plusieurs choix indépendants sont possibles, ou qu''une seule chose peut être acceptée ou refusée",
        "Quand la liste est longue",
        "Quand le champ est obligatoire"
      ],
      "bonne": 1,
      "explication": "Chaque case est indépendante. Un radio seul serait d''ailleurs impossible à décocher, ce qui le rend inadapté à une case « j''accepte »."
    },
    {
      "question": "Quelle balise crée une zone de texte sur plusieurs lignes ?",
      "choix": [
        "input type=text",
        "textarea",
        "select",
        "input type=multiline"
      ],
      "bonne": 1,
      "explication": "Et attention : textarea n''est pas orpheline. Elle a une balise de fermeture, et ce qui se trouve entre les deux est son texte initial."
    },
    {
      "question": "À quoi servent label et son attribut for ?",
      "choix": [
        "À nommer le formulaire",
        "À lier une étiquette à un champ, via l''id de celui-ci, pour le confort et l''accessibilité",
        "À valider la saisie",
        "À regrouper les champs"
      ],
      "bonne": 1,
      "explication": "Cliquer sur l''étiquette place le curseur dans le champ, et les logiciels pour aveugles savent annoncer de quoi il s''agit."
    }
  ]
}', NULL, 5);

    RAISE NOTICE '% : 7 leçons ajoutées au chapitre 16, Les formulaires.', v_nom;
  END LOOP;
END $inf1$;
