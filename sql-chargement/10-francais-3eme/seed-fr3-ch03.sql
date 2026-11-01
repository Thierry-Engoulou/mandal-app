-- ---------------------------------------------------------------------------
-- M'Andal — Français, classe de 3ème
-- Chapitre 3 : Les accords complexes du sujet
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
  WHERE programme_id = v_programme_id AND ordre = 3;

  IF v_chapitre_id IS NULL THEN
    INSERT INTO public.chapitres (programme_id, titre, ordre, niveau)
    VALUES (v_programme_id, 'Les accords complexes du sujet', 3, 'Module 1 : La vie familiale et socioculturelle')
    RETURNING id INTO v_chapitre_id;
    RAISE NOTICE 'Chapitre 3 créé.';
  END IF;

  -- Les leçons. Si le chapitre en a déjà, on passe son tour sans rien toucher.
  SELECT count(*) INTO v_deja FROM public.concepts WHERE chapitre_id = v_chapitre_id;
  IF v_deja > 0 THEN
    RAISE NOTICE 'Le chapitre 3 a déjà ses % leçons, je n''y touche pas.', v_deja;
    RETURN;
  END IF;

  INSERT INTO public.concepts
    (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes) VALUES
    (v_chapitre_id, 'Retrouver le sujet, même quand il se cache', 1, 'texte', '
L''accord du verbe avec son sujet, tu le connais depuis la sixième. Alors
pourquoi en refaire un chapitre en troisième ?

Parce qu''en troisième, les phrases s''allongent, et que le sujet ne se tient plus
sagement devant le verbe. Il passe derrière, il s''éloigne, il se cache derrière
d''autres mots. La règle ne change pas ; c''est le **repérage** qui devient
difficile.

### La seule question à poser

Devant chaque verbe, pose la question :

> **Qui est-ce qui ?** (ou : qu''est-ce qui ?)

La réponse est le sujet. Toujours. Sans exception.

> Les enfants jouent dans la cour.
> Qui est-ce qui joue ? **Les enfants**. Pluriel, donc *jouent*.

Cela paraît simple sur cet exemple. Garde la question en tête : elle va résister
à tous les pièges qui suivent.

### Le sujet inversé

Dans certains cas, le sujet se place **après** le verbe. Il reste le sujet, et il
commande toujours l''accord.

**Dans une question avec inversion :**

> Que **pensent** *les villageois* de ce projet ?

Qui est-ce qui pense ? *Les villageois*, pluriel. Donc *pensent*.

**Après certains compléments placés en tête de phrase :**

> Dans la cour **jouent** *les enfants du quartier*.

Qui est-ce qui joue ? *Les enfants*, pluriel. Donc *jouent*.

**Dans une incise, quand on rapporte des paroles :**

> « Je rentre demain », **annonça** *mon frère*.

Qui est-ce qui annonça ? *Mon frère*, singulier. Donc *annonça*.

**Après certains adverbes en tête de phrase**, comme *ainsi*, *peut-être*,
*sans doute*, *à peine* :

> Ainsi **s''achèvent** *les récoltes*.

### Le sujet éloigné

C''est le cas le plus dangereux, parce que l''œil se fie au mot le plus proche du
verbe. Trois écrans se glissent couramment entre le sujet et son verbe.

**Un pronom complément.**

> Les mangues, le marchand **les** *vend* au bord de la route.

Le mot juste avant le verbe est *les*, pluriel. Mais *les* n''est pas le sujet,
c''est un complément d''objet direct. Qui est-ce qui vend ? *Le marchand*,
singulier. Donc **vend**.

**Un complément du nom.**

> Le panier de mangues *pèse* cinq kilos.

Le mot juste avant est *mangues*, pluriel. Mais qui est-ce qui pèse ? *Le
panier*, singulier. Donc **pèse**.

**Une proposition relative.**

> Les élèves que le professeur interroge *répondent* poliment.

Le mot juste avant est *interroge*, et avant lui *le professeur*, singulier. Mais
qui est-ce qui répond ? *Les élèves*, pluriel. Donc **répondent**.

Dans les trois cas, le remède est le même, et il n''y en a pas d''autre : pose la
question.

---

**Exercice corrigé**

*Accorder correctement les verbes entre parenthèses, en justifiant chaque
accord.*

*1. Dans la cour (jouer, présent) les enfants des voisins.*
*2. Le bruit des motos me (réveiller, présent) chaque matin.*
*3. Les cahiers que mon frère (acheter, passé composé) (coûter, passé composé)
cher.*
*4. « Nous partons », (déclarer, passé simple) les voyageurs.*

**Correction.**

*1.* Qui est-ce qui joue ? *Les enfants des voisins*. C''est un sujet **inversé**,
placé après le verbe parce que le complément « dans la cour » ouvre la phrase.
Le noyau du groupe sujet est *les enfants*, pluriel.

> Dans la cour **jouent** les enfants des voisins.

*2.* Qui est-ce qui réveille ? *Le bruit*, singulier. Attention : *me* est un
complément, et *des motos* complète le nom *bruit*. Ni l''un ni l''autre ne
commande l''accord.

> Le bruit des motos me **réveille** chaque matin.

*3.* Deux verbes, donc deux accords à chercher séparément.

Pour *acheter* : qui est-ce qui a acheté ? *Mon frère*, singulier → **a acheté**.
Pour *coûter* : qui est-ce qui a coûté cher ? *Les cahiers*, pluriel → **ont
coûté**.

> Les cahiers que mon frère **a achetés ont coûté** cher.

*Remarque le participe passé « achetés », avec un s : avec l''auxiliaire avoir, il
s''accorde avec le complément d''objet direct quand celui-ci est placé avant. Ici
le complément est « que », qui remplace « les cahiers ». C''est une règle que tu
reverras au module 4.*

*4.* Qui est-ce qui déclare ? *Les voyageurs*, pluriel. C''est une **incise**, donc
le sujet est inversé.

> « Nous partons », **déclarèrent** les voyageurs.
', NULL, 24),
    (v_chapitre_id, 'Figure : les trois écrans entre le sujet et le verbe', 2, 'figure', '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 580 290" width="580" height="290">
<rect width="580" height="290" fill="#ffffff"/>
<text x="290" y="24" text-anchor="middle" font-size="14" font-weight="700" fill="#0f172a">Les trois écrans qui font rater l&apos;accord</text>
<text x="290" y="42" text-anchor="middle" font-size="10" fill="#64748b">Un mot s&apos;installe entre le sujet et le verbe, et la main écrit l&apos;accord de ce mot-là.</text>

<rect x="20" y="56" width="540" height="64" rx="6" fill="#fee2e2" stroke="#b91c1c" stroke-width="1.5"/>
<text x="34" y="74" font-size="10" font-weight="700" fill="#7f1d1d">ÉCRAN 1 — un pronom complément</text>
<text x="34" y="94" font-size="11" fill="#991b1b">Les mangues, le marchand <tspan font-weight="700">les</tspan> <tspan font-weight="700" fill="#b91c1c">vend</tspan> au bord de la route.</text>
<text x="34" y="112" font-size="9" fill="#7f1d1d">« les » est complément, pas sujet. Qui vend ? Le marchand. Donc : vend.</text>

<rect x="20" y="130" width="540" height="64" rx="6" fill="#fef3c7" stroke="#ca8a04" stroke-width="1.5"/>
<text x="34" y="148" font-size="10" font-weight="700" fill="#78350f">ÉCRAN 2 — un complément du nom</text>
<text x="34" y="168" font-size="11" fill="#92400e">Le panier de mangues <tspan font-weight="700" fill="#ca8a04">pèse</tspan> cinq kilos.</text>
<text x="34" y="186" font-size="9" fill="#78350f">Qui pèse ? Le panier, singulier. « de mangues » complète le nom, il ne commande rien.</text>

<rect x="20" y="204" width="540" height="72" rx="6" fill="#dbeafe" stroke="#2563eb" stroke-width="1.5"/>
<text x="34" y="222" font-size="10" font-weight="700" fill="#1e3a8a">ÉCRAN 3 — une subordonnée relative</text>
<text x="34" y="242" font-size="11" fill="#1e40af">Les élèves que le professeur interroge <tspan font-weight="700" fill="#2563eb">répondent</tspan> poliment.</text>
<text x="34" y="260" font-size="9" fill="#1e3a8a">Qui répond ? Les élèves, pluriel. « le professeur » est le sujet de « interroge », pas de « répondent ».</text>
<text x="34" y="272" font-size="9" font-style="italic" fill="#7f1d1d">Le remède est toujours le même : poser la question « qui est-ce qui ? » devant le verbe.</text>
</svg>', NULL, 5),
    (v_chapitre_id, 'Simulation : qui est-ce qui ?', 3, 'interactif', '{
  "widget": "trouver-le-sujet",
  "consigne": "Quinze phrases où le sujet se cache. Tu cliques sur le mot ou le groupe que tu crois être le sujet, et la simulation pose à ta place la question « qui est-ce qui ? » devant le verbe, puis te montre si ta réponse y répond. Les quatre cas du sujet inversé y sont — la question, le complément en tête, l''incise, l''adverbe — et les trois écrans aussi. Le compteur te dira combien de fois tu t''es laissé prendre par le mot le plus proche du verbe."
}', NULL, 10),
    (v_chapitre_id, 'Les noms collectifs et le pronom relatif « qui »', 4, 'texte', '
Restent les deux cas où même un bon élève hésite. Ce sont eux que le programme
appelle les « accords complexes », et ce sont eux que l''examinateur choisit.

### Le nom collectif

Un **nom collectif** est un nom singulier qui désigne un ensemble : *la foule*,
*la majorité*, *la plupart*, *un groupe*, *une bande*, *un tas*, *une dizaine*,
*un grand nombre*.

Quand il est suivi d''un complément au pluriel, le verbe peut s''accorder de deux
façons, et **les deux sont correctes**. Ce qui décide, c''est le sens que tu veux
donner.

> Une foule de curieux **se pressait** devant le portail.

Ici j''accorde avec *foule* : je vois l''ensemble comme un bloc, une masse
compacte.

> Une foule de curieux **se pressaient** devant le portail.

Ici j''accorde avec *curieux* : je vois les individus, chacun poussant de son
côté.

Rassure-toi : au BEPC, on ne te piégera pas sur ce cas, justement parce que les
deux accords se défendent. Mais deux expressions font exception et imposent le
pluriel.

**« La plupart de » veut toujours le pluriel :**

> La plupart des élèves **sont** arrivés en retard.

**« Un grand nombre de », « beaucoup de », « peu de » aussi :**

> Beaucoup de candidats **ont** échoué.

Et une dernière, qui fait l''inverse : quand le collectif est précédé de
**l''article défini**, l''accord se fait avec lui, au singulier.

> **Le** groupe de danseurs **est** entré sur la scène.

Compare avec « **Un** groupe de danseurs **sont** entrés », où le pluriel passe
aussi. L''article *le* désigne un groupe précis, identifié, donc un bloc.

### Le pronom relatif « qui »

Voici la règle la plus rentable du chapitre, parce qu''elle est mal connue et
qu''elle tombe souvent.

**Le pronom relatif *qui* est toujours sujet du verbe de la relative. Et il
prend la personne et le nombre de son antécédent.**

L''antécédent est le mot que *qui* remplace, celui qui le précède
immédiatement.

> Les élèves **qui** *travaillent* réussissent.

*Qui* remplace *les élèves*, pluriel, donc *travaillent*.

Jusque-là, c''est naturel. Mais regarde ce cas :

> C''est moi **qui** *ai* raison.

*Qui* remplace *moi*, première personne du singulier. Le verbe se met donc à la
première personne : **ai**, et non *a*. On entend souvent « c''est moi qui a
raison » : c''est une faute.

> C''est **nous** qui **avons** gagné.
> C''est **toi** qui **as** oublié le cahier.
> C''est **vous** qui **êtes** en retard.

La règle est simple à retenir : **cherche l''antécédent, et conjugue comme si tu
l''avais pour sujet.**

Un dernier piège, celui de l''expression *un des… qui* :

> C''est un des élèves **qui ont** réussi.

Qui a réussi ? Pas un seul élève : **les élèves** qui ont réussi, et il est l''un
d''eux. L''antécédent est donc *élèves*, pluriel.

---

**Exercice corrigé**

*Accorder les verbes et justifier.*

*1. La plupart des commerçants (fermer, présent) à dix-huit heures.*
*2. C''est toi qui (avoir, présent) les clés.*
*3. Le groupe de femmes qui (vendre, présent) le poisson (arriver, présent) tôt.*
*4. Une bande d''enfants (courir, imparfait) derrière le car.*

**Correction.**

*1.* « La plupart de » impose le pluriel, quelle que soit l''envie qu''on a
d''accorder avec *plupart*, qui est pourtant singulier. C''est une exception à
apprendre telle quelle.

> La plupart des commerçants **ferment** à dix-huit heures.

*2.* L''antécédent de *qui* est *toi*, deuxième personne du singulier. Le verbe se
conjugue donc à la deuxième personne.

> C''est toi qui **as** les clés.

*« C''est toi qui a les clés » est la faute attendue : on accorde avec le « qui »
comme s''il était une troisième personne. Il n''en est pas une : il prend la
personne de son antécédent.*

*3.* Deux verbes, deux accords.

Pour *vendre* : le sujet est *qui*, dont l''antécédent est *femmes*, pluriel →
**vendent**.

Pour *arriver* : qui est-ce qui arrive ? *Le groupe*, et il est précédé de
l''article défini *le*, donc singulier → **arrive**. La relative « qui vendent le
poisson » est un écran : elle ne commande rien.

> Le groupe de femmes qui **vendent** le poisson **arrive** tôt.

*C''est l''exercice complet du chapitre : un écran relatif, un nom collectif, et
deux accords opposés dans la même phrase.*

*4.* *Une bande d''enfants* est un collectif précédé d''un article indéfini : les
deux accords se défendent. Avec le singulier, je vois la bande comme un bloc ;
avec le pluriel, je vois les enfants un par un.

> Une bande d''enfants **courait** derrière le car. *(le groupe comme un tout)*
> Une bande d''enfants **couraient** derrière le car. *(les enfants un par un)*

*Les deux sont justes. En copie, choisis-en un et n''hésite pas : c''est
l''hésitation visible — une rature, un s ajouté puis barré — qui coûte le point
de présentation.*
', NULL, 24),
    (v_chapitre_id, 'Simulation : collectifs et pronoms relatifs', 5, 'interactif', '{
  "widget": "accord-collectif",
  "consigne": "Deux ateliers. Dans le premier, un nom collectif te met devant le choix : singulier ou pluriel ? Tu décides, et la simulation te montre l''image que ton accord donne — le bloc compact, ou les individus un par un — puis te signale les trois expressions qui n''offrent aucun choix. Dans le second, c''est le pronom relatif « qui » : tu dois d''abord surligner son antécédent, et la conjugaison se verrouille sur la personne que tu as désignée. Essaie « c''est moi qui » et tu verras la faute que tout le monde commet."
}', NULL, 10),
    (v_chapitre_id, 'Dix phrases pour s''entraîner avant l''examen', 6, 'texte', '
Cette leçon ne contient aucune règle nouvelle. Elle contient dix phrases, et
toutes sont construites sur le modèle de celles que le BEPC propose. Lis la
phrase, choisis, puis vérifie.

### Ce que l''examen fait de cette leçon

L''accord du sujet n''a pas de question qui lui soit réservée. Il se paie
autrement, et c''est pire : il se paie **partout**.

Dans la **deuxième partie**, à la question 3, on te demande la nature et la
fonction de mots soulignés, et il faut savoir reconnaître un sujet inversé.

Dans la **question 4**, on te fait réécrire une phrase à un autre temps, et
l''accord doit suivre.

Et surtout, dans l''épreuve d''**expression écrite**, chaque accord manqué est une
faute de langue, et la correction linguistique est l''un des trois critères de
notation. Une copie pleine d''idées mais fautive sur les accords perd plus de
points qu''une copie moyenne et correcte.

### Les dix phrases

Voici les formes exactes qui reviennent.

**1.** Le panier de mangues *(peser)* cinq kilos. → **pèse**, le sujet est
*panier*.

**2.** Les livres que j''ai achetés *(coûter)* cher. → **coûtent**, le sujet est
*les livres*, l''écran est la relative.

**3.** Dans la cour *(jouer)* les enfants. → **jouent**, sujet inversé.

**4.** La plupart des candidats *(réussir)*. → **réussissent**, exception
imposée.

**5.** C''est moi qui *(avoir)* raison. → **ai**, l''antécédent est *moi*.

**6.** Le groupe de danseurs *(entrer)* sur scène. → **entre**, article défini
devant le collectif.

**7.** « Je reviens », *(dire)* ma mère. → **dit**, incise à sujet inversé.

**8.** Les mangues, le marchand les *(vendre)*. → **vend**, le sujet est *le
marchand*, *les* est complément.

**9.** C''est un des élèves qui *(avoir)* réussi. → **ont**, l''antécédent est
*élèves*.

**10.** Beaucoup de voyageurs *(attendre)* depuis l''aube. → **attendent**,
exception imposée.

### Le réflexe à installer

Avant chaque verbe que tu écris, un quart de seconde, pose la question.

> *Qui est-ce qui ?*

Ce n''est pas une méthode d''élève lent : c''est ce que font les correcteurs
eux-mêmes quand ils doutent. Au bout de quelques semaines, la question se pose
toute seule et tu ne la remarques plus.

---

**Exercice corrigé**

*Le texte suivant contient cinq fautes d''accord du verbe avec son sujet. Les
trouver, les corriger, et justifier chacune.*

> *Le car que les voyageurs attendent depuis l''aube arrivent enfin. Sur la place
> se pressent la foule des porteurs. La plupart des passagers descend avec leurs
> bagages. « Nous sommes en retard », annoncent le chauffeur. C''est moi qui a
> réservé les places, dit un vieil homme.*

**Correction.**

*Faute 1 : « arrivent ».* Qui est-ce qui arrive ? *Le car*, singulier. L''écran
est la relative « que les voyageurs attendent », dont le sujet est *les
voyageurs*. Correction : **arrive**.

*Faute 2 : « se pressent ».* Qui est-ce qui se presse ? *La foule des porteurs*.
Le sujet est inversé, et le collectif *la foule* est précédé de l''article défini
*la*. Correction : **se presse**. On accepterait le pluriel avec un article
indéfini, mais pas ici.

*Faute 3 : « descend ».* « La plupart de » impose le pluriel. Correction :
**descendent**. Remarque d''ailleurs que la phrase elle-même le trahit : elle dit
« avec **leurs** bagages », au pluriel.

*Faute 4 : « annoncent ».* Qui est-ce qui annonce ? *Le chauffeur*, singulier.
C''est une incise à sujet inversé. Correction : **annonce**.

*Faute 5 : « a réservé ».* L''antécédent de *qui* est *moi*, première personne du
singulier. Correction : **ai réservé**.

*Le texte corrigé :*

> *Le car que les voyageurs attendent depuis l''aube arrive enfin. Sur la place se
> presse la foule des porteurs. La plupart des passagers descendent avec leurs
> bagages. « Nous sommes en retard », annonce le chauffeur. C''est moi qui ai
> réservé les places, dit un vieil homme.*

*Cinq fautes, et cinq causes différentes : l''écran relatif, le collectif avec
article défini, l''exception « la plupart », l''incise, et l''antécédent du pronom
relatif. Ce sont exactement les cinq cas du chapitre.*
', NULL, 22),
    (v_chapitre_id, 'Simulation : la chasse aux fautes d''accord', 7, 'interactif', '{
  "widget": "chasse-accords",
  "consigne": "Un texte s''affiche, truffé de fautes d''accord. Tu cliques sur chaque verbe que tu crois mal accordé, et la simulation pose la question « qui est-ce qui ? » pour trancher avec toi, puis nomme la cause de la faute : écran relatif, collectif, sujet inversé, pronom complément, antécédent de « qui ». Attention, elle a glissé des verbes parfaitement accordés au milieu : cliquer dessus te coûte un point, comme en correction réelle. Cinq textes t''attendent, de plus en plus denses."
}', NULL, 10),
    (v_chapitre_id, 'Quiz du chapitre 3', 8, 'quiz', '{
  "titre": "Vérifie que tu as compris",
  "questions": [
    {
      "question": "Quelle question permet de trouver le sujet à coup sûr ?",
      "choix": [
        "Quoi ?",
        "Qui est-ce qui ? (ou qu''est-ce qui ?) posée devant le verbe",
        "Où ?",
        "Comment ?"
      ],
      "bonne": 1,
      "explication": "Elle résiste à tous les pièges : sujet inversé, sujet éloigné, écran relatif. C''est ce que font les correcteurs eux-mêmes quand ils doutent."
    },
    {
      "question": "« Les mangues, le marchand les vend. » Pourquoi « vend » et non « vendent » ?",
      "choix": [
        "Parce que « mangues » est loin",
        "Parce que « les » est un complément d''objet, pas le sujet : qui est-ce qui vend ? le marchand, singulier",
        "Parce que c''est un collectif",
        "Parce que le verbe est au présent"
      ],
      "bonne": 1,
      "explication": "C''est l''écran du pronom complément. L''œil se fie au mot le plus proche du verbe, et se trompe."
    },
    {
      "question": "Dans « Dans la cour jouent les enfants », où est le sujet ?",
      "choix": [
        "« Dans la cour »",
        "« les enfants », placé après le verbe : c''est un sujet inversé",
        "Il n''y a pas de sujet",
        "« jouent »"
      ],
      "bonne": 1,
      "explication": "Le sujet s''inverse après un complément en tête, dans une question, dans une incise, et après des adverbes comme ainsi ou peut-être."
    },
    {
      "question": "« La plupart des élèves … arrivés en retard. » Quel accord ?",
      "choix": [
        "est, car « la plupart » est singulier",
        "sont : « la plupart de » impose toujours le pluriel",
        "Les deux se valent",
        "Cela dépend du nombre d''élèves"
      ],
      "bonne": 1,
      "explication": "Même chose pour « beaucoup de », « un grand nombre de » et « peu de ». Ce sont des exceptions à apprendre telles quelles."
    },
    {
      "question": "Avec un nom collectif comme « une foule de curieux », quel accord est correct ?",
      "choix": [
        "Seulement le singulier",
        "Les deux : le singulier voit l''ensemble comme un bloc, le pluriel voit les individus",
        "Seulement le pluriel",
        "Aucun des deux"
      ],
      "bonne": 1,
      "explication": "Mais avec l''article défini — LE groupe de danseurs — l''accord se fait au singulier : l''article désigne un groupe précis, donc un bloc."
    },
    {
      "question": "« C''est moi qui … raison. » Pourquoi « ai » et non « a » ?",
      "choix": [
        "Par habitude",
        "Parce que « qui » prend la personne et le nombre de son antécédent, ici « moi », première personne du singulier",
        "Parce que « c''est » est au présent",
        "Parce que « raison » est féminin"
      ],
      "bonne": 1,
      "explication": "C''est nous qui AVONS gagné, c''est toi qui AS oublié, c''est vous qui ÊTES en retard. Cherche l''antécédent et conjugue comme si tu l''avais pour sujet."
    },
    {
      "question": "« C''est un des élèves qui … réussi. » Quel accord, et pourquoi ?",
      "choix": [
        "a, car il n''y en a qu''un",
        "ont : l''antécédent de « qui » est « élèves », car ce sont les élèves qui ont réussi, et il est l''un d''eux",
        "Les deux se valent",
        "est, car on emploie être"
      ],
      "bonne": 1,
      "explication": "Le piège de « un des… qui ». Cherche qui a réellement fait l''action : pas un seul élève, mais ceux qui ont réussi."
    }
  ]
}', NULL, 5);

  RAISE NOTICE '8 leçons ajoutées au chapitre 3, Les accords complexes du sujet.';
END $fr3$;
