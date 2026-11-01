-- ---------------------------------------------------------------------------
-- M'Andal — Français, classe de 3ème
-- Chapitre 9 : La proposition subordonnée relative
-- Module 2 : Citoyenneté et environnement — 8 leçons
--
-- Ce fichier n'a besoin de rien d'autre pour tourner. Si la matière, la classe,
-- le programme ou le chapitre n'existent pas encore, il les crée lui-même au
-- passage.
--
-- Lancez-le quand vous voulez, dans l'ordre que vous voulez, et autant de fois
-- que vous voulez : quand le chapitre a déjà ses leçons, le script s'en rend
-- compte et n'ajoute rien.
-- ---------------------------------------------------------------------------
DO $fr3$
DECLARE
  v_matiere_id uuid;
  v_classe_id uuid;
  v_etab_id uuid;
  v_programme_id uuid;
  v_chapitre_id uuid;
  v_nb_etabs int;
  v_deja int;
BEGIN
  -- La matière Français : on ne la crée qu'une fois pour toutes.
  INSERT INTO public.matieres (nom) VALUES ('Français') ON CONFLICT (nom) DO NOTHING;
  SELECT id INTO v_matiere_id FROM public.matieres WHERE nom = 'Français';

  -- L'établissement, on le retrouve à partir des classes déjà en base.
  SELECT count(DISTINCT etablissement_id) INTO v_nb_etabs FROM public.classes;
  IF v_nb_etabs <> 1 THEN
    RAISE EXCEPTION 'Je ne sais pas à quel établissement rattacher cette classe : j''en trouve % dans la table des classes, et il m''en faudrait exactement un.', v_nb_etabs;
  END IF;
  SELECT etablissement_id INTO v_etab_id FROM public.classes LIMIT 1;

  -- Le programme de Français de la 3ème existe-t-il déjà ?
  SELECT p.id INTO v_programme_id FROM public.programmes p
  WHERE p.titre = 'Français — 3ème';

  -- Non : on le crée, et la classe avec si besoin.
  IF v_programme_id IS NULL THEN
    -- La classe a pu être écrite de plusieurs façons : 3ème, 3e, Troisième.
    SELECT id INTO v_classe_id FROM public.classes
    WHERE etablissement_id = v_etab_id
      AND (nom = '3ème' OR nom ILIKE '3%me' OR nom ILIKE 'Troisi%me' OR nom = '3e')
    ORDER BY (nom = '3ème') DESC
    LIMIT 1;

    IF v_classe_id IS NULL THEN
      INSERT INTO public.classes (etablissement_id, nom, niveau, filiere)
      VALUES (v_etab_id, '3ème', '3ème', NULL)
      RETURNING id INTO v_classe_id;
      RAISE NOTICE 'La classe de 3ème n''existait pas : je viens de la créer.';
    END IF;

    INSERT INTO public.programmes (matiere_id, classe_id, etablissement_id, titre, description)
    VALUES (v_matiere_id, v_classe_id, v_etab_id, 'Français — 3ème',
            'Programme officiel de Français 1ère langue, classe de 3ème (MINESEC, Cameroun) — 5 modules, 40 chapitres.')
    RETURNING id INTO v_programme_id;
    RAISE NOTICE 'Programme de Français de la 3ème : créé.';
  END IF;

  -- Le chapitre lui-même.
  SELECT id INTO v_chapitre_id FROM public.chapitres
  WHERE programme_id = v_programme_id AND ordre = 9;

  IF v_chapitre_id IS NULL THEN
    INSERT INTO public.chapitres (programme_id, titre, ordre, niveau)
    VALUES (v_programme_id, 'La proposition subordonnée relative', 9, 'Module 2 : Citoyenneté et environnement')
    RETURNING id INTO v_chapitre_id;
    RAISE NOTICE 'Chapitre 9 créé.';
  END IF;

  -- Les leçons. Si le chapitre en a déjà, on passe son tour sans rien toucher.
  SELECT count(*) INTO v_deja FROM public.concepts WHERE chapitre_id = v_chapitre_id;
  IF v_deja > 0 THEN
    RAISE NOTICE 'Le chapitre 9 a déjà ses % leçons, je n''y touche pas.', v_deja;
    RETURN;
  END IF;

  INSERT INTO public.concepts
    (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes) VALUES
    (v_chapitre_id, 'Le pronom relatif et son antécédent', 1, 'texte', '
Tu as vu au chapitre 2 qu''une phrase complexe contient une principale et une
subordonnée. Nous entrons maintenant dans le détail des trois subordonnées du
programme, et nous commençons par la plus fréquente de toutes : la
**relative**.

### Définition

La **proposition subordonnée relative** est introduite par un **pronom
relatif** — *qui, que, dont, où, lequel* — et elle **complète un nom**.

> Le commerçant **qui vend le poisson** a fermé plus tôt.

Elle complète le nom « commerçant » : elle dit lequel, parmi tous les
commerçants.

### Le pronom relatif joue deux rôles à la fois

C''est ce qui le rend difficile, et c''est ce qu''il faut comprendre une bonne
fois.

**Premier rôle : il remplace un nom.** Ce nom s''appelle l''**antécédent**, et il
le précède immédiatement. Dans notre phrase, *qui* remplace *le commerçant*.

C''est de là que vient la règle d''accord que tu connais déjà : le verbe de la
relative s''accorde avec l''antécédent, puisque c''est lui que le pronom
reprend.

> Les élèves **qui travaillent** réussissent. *(qui = les élèves, pluriel)*
> C''est moi **qui ai** raison. *(qui = moi, première personne)*

**Second rôle : il occupe une fonction dans la relative.** *Qui* est sujet de
*vend*. Et c''est cette fonction-là que le BEPC te demande à la question 3.

### La fonction décide du pronom

On ne choisit jamais le pronom relatif au hasard : c''est la fonction qu''il doit
occuper qui l''impose.

**QUI** quand le pronom est **sujet**.

> Le car **qui** arrive vient de Douala. *(qui arrive → qui est sujet)*

**QUE** quand il est **complément d''objet direct**.

> Le livre **que** tu m''as prêté est passionnant. *(tu as prêté quoi ? que)*

**DONT** quand le complément se construit avec **de**.

> Le film **dont** je t''ai parlé passe ce soir. *(je t''ai parlé **de** ce film)*

**OÙ** pour le **lieu** ou le **temps**.

> La ville **où** je suis né. Le jour **où** il est parti.

**LEQUEL, auquel, duquel** après une **préposition** autre que *de*.

> Le stylo **avec lequel** j''écris. La raison **pour laquelle** je pars.

### Le test qui ne trompe jamais

Tu hésites entre *que* et *dont* ? Refais la phrase sans le pronom et regarde
si la préposition *de* apparaît.

> Le film **dont** je t''ai parlé. → Je t''ai parlé **de** ce film. → **dont**.
> Le film **que** j''ai vu. → J''ai vu ce film. → pas de *de* → **que**.

C''est mécanique, et cela règle l''erreur la plus répandue du français écrit.

---

**Exercice corrigé**

*Compléter par le pronom relatif qui convient, et justifier à chaque fois.*

*1. Voici la maison … mon grand-père a construite.*
*2. Voici la maison … se trouve au bout du chemin.*
*3. Voici la maison … je t''ai parlé.*
*4. Voici la maison … je suis né.*
*5. Voici l''outil avec … il travaille.*

**Correction.**

*1.* Je refais la phrase : mon grand-père a construit **quoi** ? La maison.
C''est un complément d''objet direct, donc **que**.

> Voici la maison **que** mon grand-père a construite.

*Note au passage l''accord du participe : « construite », avec un e, parce que
le complément d''objet direct — « que », qui remplace « la maison » — est placé
avant le verbe. C''est la règle du module 4, et elle se joue ici.*

*2.* **Qui** est-ce qui se trouve au bout du chemin ? La maison. C''est un
sujet, donc **qui**.

> Voici la maison **qui** se trouve au bout du chemin.

*3.* Je refais : je t''ai parlé **de** cette maison. La préposition *de*
apparaît, donc **dont**.

> Voici la maison **dont** je t''ai parlé.

*4.* La maison est ici un **lieu** : je suis né **dans** cette maison. Donc
**où**.

> Voici la maison **où** je suis né.

*5.* Une préposition est déjà écrite, *avec*. Après une préposition autre que
*de*, on emploie **lequel**, accordé avec l''antécédent. « L''outil » est
masculin singulier, donc **lequel**.

> Voici l''outil avec **lequel** il travaille.

*Les cinq phrases ont le même début et cinq pronoms différents. Ce n''est pas
une coquetterie de grammairien : à chaque fois, c''est la fonction du pronom
dans sa propre proposition qui a décidé.*
', NULL, 26),
    (v_chapitre_id, 'Figure : les deux rôles du pronom relatif', 2, 'figure', '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 580 290" width="580" height="290">
<rect width="580" height="290" fill="#ffffff"/>
<text x="290" y="24" text-anchor="middle" font-size="14" font-weight="700" fill="#0f172a">Le pronom relatif : deux rôles à la fois</text>
<text x="290" y="42" text-anchor="middle" font-size="10" fill="#64748b">Il remplace un nom, et il occupe une fonction dans sa propre proposition.</text>

<rect x="28" y="60" width="524" height="52" rx="6" fill="#f8fafc" stroke="#94a3b8"/>
<text x="46" y="92" font-size="13" fill="#0f172a">Le commerçant</text>
<text x="146" y="92" font-size="13" font-weight="700" fill="#2563eb">qui</text>
<text x="176" y="92" font-size="13" fill="#0f172a">vend le poisson a fermé plus tôt.</text>
<path d="M 152 78 C 152 66, 100 66, 100 78" fill="none" stroke="#2563eb" stroke-width="1.6"/>
<polygon points="100,82 96,74 104,74" fill="#2563eb"/>
<text x="126" y="62" text-anchor="middle" font-size="8" fill="#2563eb">antécédent</text>

<rect x="28" y="124" width="256" height="70" rx="6" fill="#dbeafe" stroke="#2563eb" stroke-width="1.5"/>
<text x="156" y="144" text-anchor="middle" font-size="10" font-weight="700" fill="#1e3a8a">RÔLE 1 — il remplace un nom</text>
<text x="42" y="164" font-size="9" fill="#1e40af">« qui » remplace « le commerçant »</text>
<text x="42" y="180" font-size="9" fill="#1e40af">→ il en prend le genre, le nombre,</text>
<text x="42" y="190" font-size="9" fill="#1e40af">   et la personne</text>

<rect x="296" y="124" width="256" height="70" rx="6" fill="#dcfce7" stroke="#15803d" stroke-width="1.5"/>
<text x="424" y="144" text-anchor="middle" font-size="10" font-weight="700" fill="#14532d">RÔLE 2 — il a une fonction</text>
<text x="310" y="164" font-size="9" fill="#166534">« qui » est SUJET de « vend »</text>
<text x="310" y="180" font-size="9" fill="#166534">→ c&apos;est cette fonction que le BEPC</text>
<text x="310" y="190" font-size="9" fill="#166534">   demande à la question 3</text>

<rect x="28" y="206" width="524" height="72" rx="6" fill="#fef3c7" stroke="#ca8a04" stroke-width="1.5"/>
<text x="290" y="226" text-anchor="middle" font-size="10" font-weight="700" fill="#78350f">LA FONCTION DÉCIDE DU PRONOM</text>
<text x="44" y="246" font-size="9" fill="#92400e">sujet → QUI</text>
<text x="190" y="246" font-size="9" fill="#92400e">complément d&apos;objet direct → QUE</text>
<text x="400" y="246" font-size="9" fill="#92400e">complément avec « de » → DONT</text>
<text x="44" y="264" font-size="9" fill="#92400e">lieu ou temps → OÙ</text>
<text x="190" y="264" font-size="9" fill="#92400e">après une préposition → LEQUEL</text>
<text x="400" y="264" font-size="9" font-style="italic" fill="#7f1d1d">jamais au hasard</text>
</svg>', NULL, 5),
    (v_chapitre_id, 'Simulation : choisir le pronom relatif', 3, 'interactif', '{
  "widget": "pronom-relatif",
  "consigne": "Une phrase s''affiche avec un trou, et tu dois placer le bon pronom. Avant de te corriger, la simulation refait la phrase à ta place sans le pronom — « je t''ai parlé DE ce film » — et tu vois apparaître la préposition qui décide. Seize phrases, et les cinq pronoms du programme y passent. Un compteur te dit lequel te résiste : chez la plupart des élèves, c''est le « dont »."
}', NULL, 10),
    (v_chapitre_id, 'Relative déterminative ou explicative : la virgule change le sens', 4, 'texte', '
Voici une finesse que peu d''élèves connaissent, et qui se remarque aussitôt
dans une copie. Selon qu''on met ou non une virgule, la relative ne dit pas du
tout la même chose.

### Sans virgule : la relative détermine

Elle sert à **identifier** de qui ou de quoi on parle. On ne peut pas la
supprimer sans perdre l''information essentielle.

> Les élèves **qui ont révisé** ont réussi.

Cette phrase dit : parmi tous les élèves, **seuls** ceux qui ont révisé ont
réussi. Les autres ont échoué.

On l''appelle **déterminative**, ou restrictive, parce qu''elle restreint : elle
découpe un sous-groupe.

### Avec virgules : la relative explique

Elle ajoute un renseignement, mais elle n''identifie personne. On peut la
supprimer sans changer le sens principal.

> Les élèves, **qui ont révisé**, ont réussi.

Cette phrase dit tout autre chose : **tous** les élèves ont révisé, et **tous**
ont réussi. La relative ne fait qu''expliquer pourquoi.

On l''appelle **explicative**, ou appositive.

### Comparez, et mesurez l''écart

> Mes frères **qui habitent Douala** viendront.
> → J''ai plusieurs frères ; seuls ceux de Douala viendront.

> Mes frères, **qui habitent Douala**, viendront.
> → J''ai des frères, ils habitent tous Douala, et ils viendront tous.

Deux virgules, et le nombre de frères qui viennent change.

C''est pourquoi la ponctuation n''est pas un ornement. Dans un texte de loi, dans
un contrat, dans un règlement intérieur, cette virgule-là a des conséquences
réelles.

### Le test de suppression

Tu le connais déjà, il vient du chapitre 1.

**Supprime la relative.** Si la phrase perd son information essentielle, la
relative était **déterminative**, et il ne faut pas de virgule. Si la phrase
garde son sens, la relative était **explicative**, et il faut les virgules.

> Les élèves ont réussi. → vrai dans le second cas, faux dans le premier.

---

**Exercice corrigé**

*Dire ce que signifie chaque phrase, et expliquer ce que la virgule change.*

*1. Les commerçants qui ouvrent à six heures font les meilleures affaires.*
*2. Les commerçants, qui ouvrent à six heures, font les meilleures affaires.*

*Puis ponctuer correctement la phrase 3 selon le sens indiqué.*

*3. Mon oncle … qui vit à Bafoussam … m''a écrit. (sens : je n''ai qu''un seul
oncle)*

**Correction.**

*1. Sans virgule, relative déterminative.* La phrase dit que parmi tous les
commerçants, **seuls** ceux qui ouvrent à six heures font les meilleures
affaires. Les autres n''en font pas autant. La relative découpe un sous-groupe,
et on ne peut pas la retirer : « Les commerçants font les meilleures affaires »
dirait tout autre chose.

*2. Avec virgules, relative explicative.* La phrase dit que **tous** les
commerçants ouvrent à six heures, et que **tous** font les meilleures affaires.
La relative explique pourquoi, elle n''identifie personne. Supprimons-la : « Les
commerçants font les meilleures affaires » garde le même sens.

*La différence en une ligne : sans virgule, certains ; avec virgules, tous.*

*3.* Le sens indiqué est que je n''ai **qu''un seul** oncle. Il n''y a donc
personne à distinguer, rien à restreindre : la relative ne sert qu''à ajouter un
renseignement sur lui. Elle est **explicative**, et il faut les deux virgules.

> Mon oncle, **qui vit à Bafoussam**, m''a écrit.

*Si j''avais écrit « Mon oncle qui vit à Bafoussam m''a écrit », sans virgule, le
lecteur comprendrait aussitôt que j''ai plusieurs oncles et que je parle de
celui de Bafoussam. Le lecteur ne devine pas : il lit la ponctuation.*

*Et retiens le piège de l''examen : on te demandera parfois « quelle est la
nature de cette proposition ? ». La réponse complète est « proposition
subordonnée relative explicative », ou « déterminative ». Ajouter l''adjectif
montre que tu as vu la virgule.*
', NULL, 26),
    (v_chapitre_id, 'Simulation : la virgule qui change tout', 5, 'interactif', '{
  "widget": "relative-determinative",
  "consigne": "Une phrase s''affiche avec sa relative, et deux boutons : avec virgules, sans virgules. À chaque clic, un petit schéma te montre le groupe concerné — tous les élèves, ou seulement une partie — et le sens de la phrase se réécrit devant toi. Douze phrases, dont trois où le changement de sens a des conséquences réelles : un règlement, une consigne d''examen, une clause de contrat. Tu comprendras pourquoi cette virgule n''est pas un ornement."
}', NULL, 10),
    (v_chapitre_id, 'Donner la nature et la fonction : ce que l''examen demande', 6, 'texte', '
Nous arrivons au geste noté. À la **question 3** ou à la **question 5** du BEPC,
on te demandera la nature et la fonction d''un pronom relatif, ou de la
proposition entière. Voici comment répondre sans jamais hésiter.

### Pour le PRONOM relatif

**Sa nature** : c''est un **pronom relatif**. Toujours. Il n''y a rien à
chercher.

**Sa fonction** : elle se trouve dans la **subordonnée**, pas dans la
principale. Cache la principale, lis la relative seule, et pose les questions
habituelles.

> Le commerçant **qui vend le poisson** a fermé.
> Je lis la relative seule : « qui vend le poisson ». Qui est-ce qui vend ?
> *Qui*. Donc **sujet de « vend »**.

> Le livre **que tu m''as prêté** est passionnant.
> Je lis : « que tu m''as prêté ». Tu as prêté quoi ? *Que*. Donc **complément
> d''objet direct de « as prêté »**.

> Le film **dont je t''ai parlé** passe ce soir.
> Je lis : « dont je t''ai parlé ». Je t''ai parlé de quoi ? *Dont*. Donc
> **complément d''objet indirect de « ai parlé »**.

> La ville **où je suis né** est loin.
> Je lis : « où je suis né ». Je suis né où ? *Où*. Donc **complément
> circonstanciel de lieu de « suis né »**.

Quatre phrases, quatre fonctions différentes, et la même méthode à chaque fois.

### Pour la PROPOSITION entière

**Sa nature** : **proposition subordonnée relative**, et tu ajoutes
*déterminative* ou *explicative* selon la virgule.

**Sa fonction** : elle complète son **antécédent**. On dit qu''elle est
**complément de l''antécédent**, ou **épithète** de ce nom.

> Le commerçant **qui vend le poisson** a fermé.
> Nature : proposition subordonnée relative déterminative.
> Fonction : complément de l''antécédent « commerçant ».

### Le piège de la relative enchâssée

Tu l''as rencontré au chapitre 2 : la relative coupe souvent la principale en
deux. Pour relever la principale, il faut **recoller les morceaux**.

> Le commerçant qui vend le poisson a fermé plus tôt.
> Principale : « Le commerçant a fermé plus tôt. »

Oublier de recoller est l''erreur qui coûte le plus à cette question.

### Un modèle de réponse complète

Voici ce que vaut deux points sur deux, mot pour mot :

> « Dans cette phrase, « qui » est un pronom relatif, sujet du verbe « vend ».
> Il a pour antécédent le nom « commerçant ». La proposition « qui vend le
> poisson » est une proposition subordonnée relative déterminative, complément
> de son antécédent. La proposition principale est « Le commerçant a fermé plus
> tôt ». »

Quatre phrases, et tout y est. Apprends ce moule : il te servira à chaque
session.

---

**Exercice corrigé**

*Pour chaque phrase, donner la nature et la fonction du pronom relatif, puis la
nature et la fonction de la proposition, puis relever la principale.*

*1. Les mangues que le marchand vend viennent de Nkongsamba.*
*2. Mon voisin, dont le fils étudie à Yaoundé, est enseignant.*

**Correction.**

*Phrase 1.*

**Le pronom.** « Que » est un **pronom relatif**. Je lis la relative seule :
« que le marchand vend ». Le marchand vend **quoi** ? *Que*. Il est donc
**complément d''objet direct du verbe « vend »**. Son antécédent est le nom
« mangues ».

**La proposition.** « que le marchand vend » est une **proposition subordonnée
relative déterminative** — il n''y a pas de virgule, et elle sert bien à
identifier de quelles mangues on parle. Sa fonction : **complément de
l''antécédent « mangues »**.

**La principale.** Elle est coupée en deux par la relative. Je recolle :
**« Les mangues viennent de Nkongsamba. »**

*Phrase 2.*

**Le pronom.** « Dont » est un **pronom relatif**. Je lis la relative seule :
« dont le fils étudie à Yaoundé ». Je rétablis la construction : le fils **de**
mon voisin. La préposition *de* confirme le choix du pronom. Sa fonction est
**complément du nom « fils »**. Son antécédent est « voisin ».

*C''est la fonction la moins connue du « dont », et celle qui rapporte le plus :
la plupart des copies écrivent « complément d''objet indirect » par réflexe,
alors que le « de » porte ici sur un nom, pas sur un verbe.*

**La proposition.** « dont le fils étudie à Yaoundé » est une **proposition
subordonnée relative explicative** — les deux virgules le disent, et elle
n''identifie personne puisque « mon voisin » est déjà identifié. Sa fonction :
**complément de l''antécédent « voisin »**.

**La principale.** Je recolle : **« Mon voisin est enseignant. »**
', NULL, 26),
    (v_chapitre_id, 'Simulation : nature et fonction, question par question', 7, 'interactif', '{
  "widget": "fonction-du-relatif",
  "consigne": "L''exercice de l''examen. Une phrase s''affiche, et la simulation cache la principale pour te laisser lire la relative seule : c''est le geste que personne ne fait et qui règle tout. Tu donnes la fonction du pronom, puis la nature et la fonction de la proposition, puis tu relèves la principale — et elle te refuse une principale amputée quand la relative l''avait coupée en deux. Quatorze phrases, notées au demi-point comme au BEPC."
}', NULL, 10),
    (v_chapitre_id, 'Quiz du chapitre 9', 8, 'quiz', '{
  "titre": "Vérifie que tu as compris",
  "questions": [
    {
      "question": "Qu''est-ce qu''une proposition subordonnée relative ?",
      "choix": [
        "Une proposition introduite par « que »",
        "Une proposition introduite par un pronom relatif et qui complète un NOM",
        "Une proposition qui complète un verbe",
        "Une proposition indépendante"
      ],
      "bonne": 1,
      "explication": "Les pronoms relatifs : qui, que, dont, où, lequel. Celle qui complète un verbe est la complétive, et tu la verras au chapitre suivant."
    },
    {
      "question": "Quels sont les deux rôles du pronom relatif ?",
      "choix": [
        "Il relie et il sépare",
        "Il remplace un nom — son antécédent — et il occupe une fonction dans sa propre proposition",
        "Il remplace un verbe et un nom",
        "Il n''a qu''un seul rôle"
      ],
      "bonne": 1,
      "explication": "Du premier rôle vient l''accord : « c''est moi QUI AI raison », car « qui » prend la personne de son antécédent. Du second vient la question du BEPC."
    },
    {
      "question": "« Le film … je t''ai parlé. » Quel pronom, et comment le savoir ?",
      "choix": [
        "que",
        "dont, car en refaisant la phrase on obtient « je t''ai parlé DE ce film »",
        "qui",
        "où"
      ],
      "bonne": 1,
      "explication": "Le test est mécanique : refais la phrase sans le pronom et regarde si « de » apparaît. S''il apparaît, c''est « dont »."
    },
    {
      "question": "Quelle différence entre « Les élèves qui ont révisé ont réussi » et « Les élèves, qui ont révisé, ont réussi » ?",
      "choix": [
        "Aucune, la virgule est décorative",
        "Sans virgule, seuls certains élèves ont réussi ; avec virgules, tous ont révisé et tous ont réussi",
        "La seconde est fausse",
        "La première est au pluriel"
      ],
      "bonne": 1,
      "explication": "Sans virgule la relative est déterminative : elle restreint. Avec virgules elle est explicative : elle ajoute un renseignement sans identifier personne."
    },
    {
      "question": "Comment trouver la fonction d''un pronom relatif ?",
      "choix": [
        "En regardant la principale",
        "En cachant la principale et en lisant la relative seule, puis en posant les questions habituelles",
        "En comptant les mots",
        "En regardant l''antécédent"
      ],
      "bonne": 1,
      "explication": "« que le marchand vend » : le marchand vend quoi ? QUE. Donc complément d''objet direct de « vend ». C''est le geste que personne ne fait et qui règle tout."
    },
    {
      "question": "Quelle est la fonction de la proposition relative elle-même ?",
      "choix": [
        "Sujet",
        "Complément de son antécédent",
        "Complément d''objet direct",
        "Elle n''en a pas"
      ],
      "bonne": 1,
      "explication": "Elle complète le nom qui la précède. On dit aussi qu''elle est épithète de ce nom."
    },
    {
      "question": "Dans « Mon voisin, dont le fils étudie à Yaoundé, est enseignant », quelle est la fonction de « dont » ?",
      "choix": [
        "Complément d''objet indirect",
        "Complément du nom « fils » : le « de » porte sur un nom, pas sur un verbe",
        "Sujet",
        "Complément circonstanciel"
      ],
      "bonne": 1,
      "explication": "C''est la fonction la moins connue du « dont », et celle qui rapporte le plus : la plupart des copies écrivent « complément d''objet indirect » par réflexe."
    }
  ]
}', NULL, 5);

  RAISE NOTICE '8 leçons ajoutées au chapitre 9, La proposition subordonnée relative.';
END $fr3$;
