-- ---------------------------------------------------------------------------
-- M'Andal — Français, classe de 3ème
-- Chapitre 1 : Les types de phrases et les constituants de la phrase
-- Module 1 : La vie familiale et socioculturelle — 8 leçons
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
  WHERE programme_id = v_programme_id AND ordre = 1;

  IF v_chapitre_id IS NULL THEN
    INSERT INTO public.chapitres (programme_id, titre, ordre, niveau)
    VALUES (v_programme_id, 'Les types de phrases et les constituants de la phrase', 1, 'Module 1 : La vie familiale et socioculturelle')
    RETURNING id INTO v_chapitre_id;
    RAISE NOTICE 'Chapitre 1 créé.';
  END IF;

  -- Les leçons. Si le chapitre en a déjà, on passe son tour sans rien toucher.
  SELECT count(*) INTO v_deja FROM public.concepts WHERE chapitre_id = v_chapitre_id;
  IF v_deja > 0 THEN
    RAISE NOTICE 'Le chapitre 1 a déjà ses % leçons, je n''y touche pas.', v_deja;
    RETURN;
  END IF;

  INSERT INTO public.concepts
    (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes) VALUES
    (v_chapitre_id, 'Les quatre types de phrases', 1, 'texte', '
Commençons par une chose qui rapporte des points tout de suite : au BEPC, on te
demande régulièrement de reconnaître ou de transformer un type de phrase. C''est
une question de deux points, et elle se gagne en trente secondes quand on sait.

### Une phrase a un type, et un seul

**Le type déclaratif.** La phrase dit quelque chose, elle constate, elle
raconte. Elle se termine par un point.

> Le car de Douala arrive à huit heures.

**Le type interrogatif.** La phrase pose une question. Elle se termine par un
point d''interrogation.

> Le car de Douala arrive-t-il à huit heures ?

**Le type injonctif.** La phrase donne un ordre, un conseil ou une interdiction.
On l''appelle aussi impératif. Elle se termine par un point ou un point
d''exclamation.

> Prends le car de huit heures.

**Le type exclamatif.** La phrase exprime un sentiment — la joie, la surprise,
la colère, le regret. Elle se termine par un point d''exclamation.

> Comme ce car est en retard !

### Les trois manières de poser une question

C''est le point qu''on te demandera le plus souvent, parce qu''il change selon le
niveau de langue.

**L''intonation seule**, à l''oral et dans la langue familière :

> Tu viens au marché ?

**Est-ce que**, dans la langue courante :

> Est-ce que tu viens au marché ?

**L''inversion du sujet**, dans la langue soutenue, celle qu''on attend de toi à
l''écrit :

> Viens-tu au marché ?

Retiens bien : les trois posent la même question, mais seule la troisième est
vraiment correcte dans une copie.

### Le piège de la ponctuation

La ponctuation aide, mais elle ne décide pas. Une phrase peut porter un point
d''exclamation sans être exclamative :

> Sors d''ici !

C''est un ordre, donc une phrase **injonctive**, malgré le point d''exclamation.
Pour trancher, ne regarde pas le signe : demande-toi **ce que fait la phrase**.
Elle informe, elle interroge, elle ordonne, ou elle s''émeut.

---

**Exercice corrigé**

*Donner le type de chacune de ces phrases, et justifier.*

*1. Que la saison des pluies est longue cette année !*
*2. N''oublie pas d''arroser le jardin.*
*3. Depuis quand attends-tu le car ?*
*4. Mon oncle habite à Bafoussam depuis douze ans.*

**Correction.**

*1. Type exclamatif.* La phrase exprime un sentiment — ici la lassitude — et
elle commence par « que », un des mots de l''exclamation, avec « comme » et
« quel ». Elle n''informe de rien de nouveau : chacun sait que la saison dure.

*2. Type injonctif.* Elle donne un conseil, et son verbe est à l''impératif, sans
sujet exprimé. Remarque le point final : un ordre n''a pas besoin de point
d''exclamation pour être un ordre.

*3. Type interrogatif.* Elle pose une question, et elle le fait par inversion du
sujet — « attends-tu » —, donc dans la langue soutenue. Le point d''interrogation
confirme.

*4. Type déclaratif.* Elle informe, simplement. C''est le type le plus fréquent,
et c''est celui des textes que tu auras à étudier.
', NULL, 20),
    (v_chapitre_id, 'Figure : les quatre types et les trois formes', 2, 'figure', '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 580 300" width="580" height="300">
<rect width="580" height="300" fill="#ffffff"/>
<text x="290" y="24" text-anchor="middle" font-size="14" font-weight="700" fill="#0f172a">Les quatre types de phrases</text>
<text x="290" y="42" text-anchor="middle" font-size="10" fill="#64748b">Une phrase a un type, et un seul. Elle a ensuite plusieurs formes à la fois.</text>

<rect x="18" y="56" width="128" height="104" rx="6" fill="#dbeafe" stroke="#2563eb" stroke-width="1.6"/>
<text x="82" y="78" text-anchor="middle" font-size="11" font-weight="700" fill="#1e3a8a">DÉCLARATIF</text>
<text x="82" y="94" text-anchor="middle" font-size="8" fill="#1e40af">il dit quelque chose</text>
<line x1="30" y1="102" x2="134" y2="102" stroke="#93c5fd"/>
<text x="82" y="120" text-anchor="middle" font-size="9" fill="#1e40af">Awa rentre du marché.</text>
<text x="82" y="142" text-anchor="middle" font-size="18" font-weight="700" fill="#2563eb">.</text>

<rect x="154" y="56" width="128" height="104" rx="6" fill="#fef3c7" stroke="#ca8a04" stroke-width="1.6"/>
<text x="218" y="78" text-anchor="middle" font-size="11" font-weight="700" fill="#78350f">INTERROGATIF</text>
<text x="218" y="94" text-anchor="middle" font-size="8" fill="#92400e">il demande</text>
<line x1="166" y1="102" x2="270" y2="102" stroke="#fde047"/>
<text x="218" y="120" text-anchor="middle" font-size="9" fill="#92400e">Awa rentre-t-elle ?</text>
<text x="218" y="144" text-anchor="middle" font-size="18" font-weight="700" fill="#ca8a04">?</text>

<rect x="290" y="56" width="128" height="104" rx="6" fill="#dcfce7" stroke="#15803d" stroke-width="1.6"/>
<text x="354" y="78" text-anchor="middle" font-size="11" font-weight="700" fill="#14532d">INJONCTIF</text>
<text x="354" y="94" text-anchor="middle" font-size="8" fill="#166534">il ordonne, il conseille</text>
<line x1="302" y1="102" x2="406" y2="102" stroke="#86efac"/>
<text x="354" y="120" text-anchor="middle" font-size="9" fill="#166534">Rentre du marché.</text>
<text x="354" y="142" text-anchor="middle" font-size="12" font-weight="700" fill="#15803d">. ou !</text>

<rect x="426" y="56" width="128" height="104" rx="6" fill="#fce7f3" stroke="#be185d" stroke-width="1.6"/>
<text x="490" y="78" text-anchor="middle" font-size="11" font-weight="700" fill="#831843">EXCLAMATIF</text>
<text x="490" y="94" text-anchor="middle" font-size="8" fill="#9d174d">il montre un sentiment</text>
<line x1="438" y1="102" x2="542" y2="102" stroke="#f9a8d4"/>
<text x="490" y="120" text-anchor="middle" font-size="9" fill="#9d174d">Comme elle est tard !</text>
<text x="490" y="144" text-anchor="middle" font-size="18" font-weight="700" fill="#be185d">!</text>

<rect x="60" y="178" width="460" height="104" rx="6" fill="#f8fafc" stroke="#94a3b8" stroke-width="1.4"/>
<text x="290" y="198" text-anchor="middle" font-size="11" font-weight="700" fill="#0f172a">Et par-dessus le type, les formes</text>
<line x1="80" y1="206" x2="500" y2="206" stroke="#cbd5e1"/>
<text x="80" y="224" font-size="9" fill="#334155">affirmative ou négative</text>
<text x="330" y="224" font-size="9" fill="#64748b">Awa rentre. / Awa ne rentre pas.</text>
<text x="80" y="242" font-size="9" fill="#334155">active ou passive</text>
<text x="330" y="242" font-size="9" fill="#64748b">Awa porte le sac. / Le sac est porté par Awa.</text>
<text x="80" y="260" font-size="9" fill="#334155">neutre ou emphatique</text>
<text x="330" y="260" font-size="9" fill="#64748b">Awa rentre. / C&apos;est Awa qui rentre.</text>
<text x="290" y="277" text-anchor="middle" font-size="9" font-style="italic" fill="#7f1d1d">Une même phrase peut être déclarative, négative, passive et emphatique à la fois.</text>
</svg>', NULL, 5),
    (v_chapitre_id, 'Simulation : reconnaître le type d''une phrase', 3, 'interactif', '{
  "widget": "types-de-phrases",
  "consigne": "Seize phrases défilent, ancrées dans ton quotidien — le marché de Mokolo, le car de Douala, la pluie de juillet — et tu dois donner le type de chacune. La simulation te cache d''abord la ponctuation finale, pour t''obliger à chercher ce que fait la phrase au lieu de regarder le signe. Elle te la révèle ensuite, et te montre les trois cas où la ponctuation ment : un ordre avec un point d''exclamation, une question sans point d''interrogation, et une exclamation qui n''en a pas l''air."
}', NULL, 10),
    (v_chapitre_id, 'Les formes de la phrase', 4, 'texte', '
Le type, tu viens de le voir, est unique. Les **formes**, elles, se cumulent :
une même phrase peut être négative, passive et emphatique à la fois.

### Affirmative ou négative

La forme négative se construit avec **deux mots**, et c''est l''erreur la plus
fréquente de toutes les copies : on en oublie un.

> Awa vient au marché. → Awa **ne** vient **pas** au marché.

Le premier mot est presque toujours *ne*. Le second varie : *pas*, *plus*,
*jamais*, *rien*, *personne*, *aucun*, *nulle part*.

À l''oral, on dit « Awa vient pas ». À l''écrit, c''est une faute. Écris toujours
le *ne*.

Attention aussi à ce piège : *ne… que* n''est **pas** une négation, c''est une
restriction.

> Je **n''**ai **que** mille francs. *(= j''ai seulement mille francs)*

La phrase est affirmative.

### Active ou passive

À la forme active, le sujet **fait** l''action. À la forme passive, il la
**subit**.

> Les élèves nettoient la cour. *(active)*
> La cour est nettoyée par les élèves. *(passive)*

Pour passer de l''une à l''autre, trois gestes :

Le complément d''objet direct devient sujet. Le verbe se met à l''auxiliaire
*être* **au même temps que le verbe actif**. L''ancien sujet devient complément
d''agent, introduit par *par* ou *de*.

Ce « au même temps » est le point que les correcteurs guettent. *Nettoient* est
au présent, donc *est nettoyée* est au présent. Si tu écris *a été nettoyée*, tu
as changé le temps, et la question est perdue.

Et retiens ceci : seul un verbe qui a un complément d''objet **direct** peut se
mettre au passif. « Je pense à toi » n''a pas de passif.

### Neutre ou emphatique

La forme emphatique met un mot en valeur. Deux procédés à connaître.

**L''encadrement** par *c''est… qui* ou *c''est… que* :

> Awa vient au marché. → **C''est** Awa **qui** vient au marché.

**Le détachement**, avec une virgule et un pronom qui reprend :

> Awa, elle vient au marché.

C''est utile dans une rédaction : quand tu veux insister sur un mot, tu as
maintenant deux outils propres, au lieu de le souligner ou de l''écrire en
majuscules.

---

**Exercice corrigé**

*Mettre à la forme passive, sans changer le temps : « Le maire inaugurera le
nouveau marché. »*
*Puis mettre à la forme emphatique le mot « maire ».*

**Correction.**

*La forme passive.*

Je repère d''abord le complément d''objet direct : « le nouveau marché ». Il
devient sujet.

Je repère le temps du verbe actif : *inaugurera*, futur simple de l''indicatif.
L''auxiliaire *être* devra donc être au futur simple : *sera*.

L''ancien sujet, « le maire », devient complément d''agent avec *par*.

> **Le nouveau marché sera inauguré par le maire.**

Vérifions l''accord du participe passé : avec l''auxiliaire *être*, il s''accorde
avec le sujet. « Le nouveau marché » est masculin singulier, donc *inauguré*,
sans e ni s. C''est juste.

*La forme emphatique.*

> **C''est le maire qui inaugurera le nouveau marché.**

On encadre par *c''est… qui* parce que « le maire » est sujet. Si on voulait
mettre en valeur un complément, on emploierait *c''est… que* : « C''est le nouveau
marché **que** le maire inaugurera. »

*Note bien la différence : qui pour le sujet, que pour le complément. Une faute
à cet endroit se voit immédiatement.*
', NULL, 22),
    (v_chapitre_id, 'Simulation : transformer une phrase', 5, 'interactif', '{
  "widget": "formes-de-phrase",
  "consigne": "Un atelier de transformation. Une phrase s''affiche, et tu choisis la transformation demandée : la mettre au négatif, au passif, à la forme emphatique, ou revenir en arrière. La simulation vérifie les trois pièges à chaque fois : le « ne » oublié, le temps de l''auxiliaire qui ne doit pas changer au passif, et le « qui » mis à la place du « que ». Essaie de passer au passif un verbe qui n''a pas de complément d''objet direct : elle refuse, et elle t''explique pourquoi."
}', NULL, 10),
    (v_chapitre_id, 'Les constituants obligatoires et les constituants facultatifs', 6, 'texte', '
Voici la notion qui tient tout le chapitre, et elle est plus utile qu''elle n''en
a l''air : elle va te servir à repérer les compléments, donc à répondre aux
questions de fonction du BEPC.

### Ce dont une phrase ne peut pas se passer

Une phrase verbale a besoin de deux choses, et de deux seulement :

**Le sujet** — de qui ou de quoi on parle.
**Le prédicat** — ce qu''on en dit, c''est-à-dire le verbe et ce qui s''y rattache
obligatoirement.

> Les élèves nettoient la cour.

Le sujet est « les élèves ». Le prédicat est « nettoient la cour ». Et dans ce
prédicat, « la cour » est **obligatoire** : *les élèves nettoient* tout seul ne
veut rien dire de complet.

### Le test qui décide : supprimer, puis déplacer

Tu n''as pas à deviner. Deux tests suffisent, et ils ne trompent jamais.

**Le test de suppression.** J''enlève le groupe. Si la phrase reste correcte, le
groupe était **facultatif**. Si elle devient boiteuse, il était **obligatoire**.

**Le test de déplacement.** Je déplace le groupe en tête de phrase. S''il accepte
de bouger, il est **facultatif**. S''il refuse, il est obligatoire.

Prenons une phrase complète :

> Ce matin, les élèves nettoient la cour avec soin.

*Ce matin* : je le supprime, « les élèves nettoient la cour avec soin » tient. Je
le déplace, il bouge. Donc **facultatif** : c''est un complément circonstanciel de
temps.

*La cour* : je le supprime, « les élèves nettoient » boite. Je le déplace, « la
cour, les élèves nettoient » ne se dit pas. Donc **obligatoire** : c''est le
complément d''objet direct.

*Avec soin* : je le supprime, la phrase tient. Je le déplace, il bouge. Donc
**facultatif** : complément circonstanciel de manière.

### Pourquoi cela compte pour l''examen

Parce que la question 3 de la deuxième partie du BEPC demande presque toujours
la **nature et la fonction** de mots soulignés, et que ces deux tests te donnent
la fonction sans que tu aies à réciter quoi que ce soit.

Un groupe supprimable et déplaçable est un **complément circonstanciel**, et il
ne reste qu''à dire lequel : temps, lieu, manière, cause, but, moyen.

Un groupe non supprimable placé juste après le verbe sans préposition est un
**complément d''objet direct**.

Le même avec une préposition — *à*, *de* — est un **complément d''objet
indirect**.

---

**Exercice corrigé**

*Dans la phrase suivante, séparer les constituants obligatoires des constituants
facultatifs, en appliquant les deux tests. Donner ensuite la fonction de chacun.*

> *Depuis la rentrée, mon petit frère apporte son goûter au collège chaque
> matin.*

**Correction.**

*Premier groupe : « Depuis la rentrée ».* Je le supprime : « Mon petit frère
apporte son goûter au collège chaque matin » tient debout. Je le déplace : il
peut aller en fin de phrase. Il est donc **facultatif**, et c''est un
**complément circonstanciel de temps**.

*Deuxième groupe : « mon petit frère ».* Je le supprime : « apporte son goûter au
collège » n''a plus personne pour agir. Il est **obligatoire**, et c''est le
**sujet**.

*Troisième groupe : « apporte ».* C''est le verbe, noyau du prédicat, donc
obligatoire par définition.

*Quatrième groupe : « son goûter ».* Je le supprime : « mon petit frère apporte »
boite — on attend ce qu''il apporte. Je le déplace : impossible. Il est
**obligatoire**, placé après le verbe sans préposition : c''est le **complément
d''objet direct**.

*Cinquième groupe : « au collège ».* Je le supprime : la phrase tient. Je le
déplace : « Au collège, mon petit frère apporte son goûter » se dit très bien.
Il est **facultatif** : **complément circonstanciel de lieu**.

*Sixième groupe : « chaque matin ».* Supprimable, déplaçable : **facultatif**, et
c''est un second **complément circonstanciel de temps**.

*Bilan : deux constituants obligatoires — le sujet et le prédicat, qui contient
le verbe et son complément d''objet direct — et trois compléments
circonstanciels, qu''on pourrait tous retirer sans que la phrase cesse d''être une
phrase.*
', NULL, 24),
    (v_chapitre_id, 'Simulation : l''atelier des deux tests', 7, 'interactif', '{
  "widget": "constituants-phrase",
  "consigne": "Une phrase s''affiche, découpée en groupes de mots cliquables. Pour chaque groupe, tu lances le test de suppression puis le test de déplacement, et tu vois le résultat devant toi : la phrase se réécrit sans le groupe, ou avec le groupe déplacé en tête, et la simulation te dit si elle tient encore. Tu conclus toi-même, obligatoire ou facultatif, puis tu donnes la fonction. Douze phrases, et les six compléments circonstanciels au programme y passent tous."
}', NULL, 10),
    (v_chapitre_id, 'Quiz du chapitre 1', 8, 'quiz', '{
  "titre": "Vérifie que tu as compris",
  "questions": [
    {
      "question": "Combien de types une phrase peut-elle avoir à la fois ?",
      "choix": [
        "Autant qu''on veut",
        "Un seul, mais elle peut cumuler plusieurs formes",
        "Deux au maximum",
        "Cela dépend de la ponctuation"
      ],
      "bonne": 1,
      "explication": "Une phrase est déclarative OU interrogative OU injonctive OU exclamative. Mais elle peut être en même temps négative, passive et emphatique : ce sont des formes."
    },
    {
      "question": "« Sors d''ici ! » — quel est le type de cette phrase ?",
      "choix": [
        "Exclamatif, à cause du point d''exclamation",
        "Injonctif : elle donne un ordre, et la ponctuation ne décide pas du type",
        "Déclaratif",
        "Interrogatif"
      ],
      "bonne": 1,
      "explication": "Ne regarde pas le signe, demande-toi ce que FAIT la phrase : elle informe, elle interroge, elle ordonne, ou elle s''émeut."
    },
    {
      "question": "Quelle est la manière soutenue de poser une question ?",
      "choix": [
        "L''intonation seule : « Tu viens ? »",
        "L''inversion du sujet : « Viens-tu ? »",
        "Est-ce que tu viens ?",
        "Les trois se valent"
      ],
      "bonne": 1,
      "explication": "Les trois posent la même question, mais seule l''inversion du sujet est vraiment correcte dans une copie."
    },
    {
      "question": "« Je n''ai que mille francs. » Cette phrase est-elle négative ?",
      "choix": [
        "Oui, il y a « ne »",
        "Non : ne… que est une restriction, pas une négation. La phrase est affirmative",
        "Oui, car il manque de l''argent",
        "On ne peut pas savoir"
      ],
      "bonne": 1,
      "explication": "« Ne… que » signifie « seulement ». La phrase affirme qu''on a mille francs, elle ne nie rien."
    },
    {
      "question": "Au passif, à quel temps met-on l''auxiliaire être ?",
      "choix": [
        "Toujours au présent",
        "Au même temps que le verbe actif de départ",
        "Toujours au passé composé",
        "Au futur"
      ],
      "bonne": 1,
      "explication": "« Le maire inaugurera » est au futur, donc « sera inauguré ». Écrire « a été inauguré » change le temps, et la question est perdue."
    },
    {
      "question": "Dans la forme emphatique, quand emploie-t-on « c''est… que » plutôt que « c''est… qui » ?",
      "choix": [
        "Au hasard",
        "« Qui » pour mettre en valeur le sujet, « que » pour un complément",
        "« Que » est toujours faux",
        "« Qui » s''emploie au pluriel"
      ],
      "bonne": 1,
      "explication": "C''est le maire QUI inaugurera (sujet). C''est le marché QUE le maire inaugurera (complément). Une faute à cet endroit se voit immédiatement."
    },
    {
      "question": "Quels sont les deux tests qui permettent de trouver une fonction sans rien réciter ?",
      "choix": [
        "Lire à voix haute et compter les mots",
        "La suppression et le déplacement",
        "Chercher le verbe et compter les syllabes",
        "Remplacer par un pronom"
      ],
      "bonne": 1,
      "explication": "Supprimable et déplaçable : complément circonstanciel. Non supprimable, après le verbe et sans préposition : complément d''objet direct."
    }
  ]
}', NULL, 5);

  RAISE NOTICE '8 leçons ajoutées au chapitre 1, Les types de phrases et les constituants de la phrase.';
END $fr3$;
