-- ---------------------------------------------------------------------------
-- M'Andal — Français, classe de 3ème
-- Chapitre 20 : Le présent du subjonctif des verbes du 1er groupe
-- Module 3 : La vie économique — 8 leçons
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
  WHERE programme_id = v_programme_id AND ordre = 20;

  IF v_chapitre_id IS NULL THEN
    INSERT INTO public.chapitres (programme_id, titre, ordre, niveau)
    VALUES (v_programme_id, 'Le présent du subjonctif des verbes du 1er groupe', 20, 'Module 3 : La vie économique')
    RETURNING id INTO v_chapitre_id;
    RAISE NOTICE 'Chapitre 20 créé.';
  END IF;

  -- Les leçons. Si le chapitre en a déjà, on passe son tour sans rien toucher.
  SELECT count(*) INTO v_deja FROM public.concepts WHERE chapitre_id = v_chapitre_id;
  IF v_deja > 0 THEN
    RAISE NOTICE 'Le chapitre 20 a déjà ses % leçons, je n''y touche pas.', v_deja;
    RETURN;
  END IF;

  INSERT INTO public.concepts
    (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes) VALUES
    (v_chapitre_id, 'Former le subjonctif présent', 1, 'texte', '
Tu as rencontré le subjonctif trois fois déjà : au chapitre 10 avec la
complétive, au chapitre 12 avec le « si », au chapitre 17 avec les
circonstancielles. Il est temps de le fabriquer proprement.

Ce chapitre prépare la **question 4** du BEPC — identifier le temps et le mode
d''un verbe —, et le programme le centre sur le **premier groupe**, celui des
verbes en *-er*.

### Qu''est-ce qu''un mode ?

Un **mode** est la manière dont le verbe présente l''action.

> L''**indicatif** la présente comme **réelle** : *il vient*.
> Le **subjonctif** la présente comme **envisagée** — voulue, crainte,
> attendue, redoutée : *qu''il vienne*.
> Le **conditionnel** la présente comme **soumise à une condition** : *il
> viendrait*.
> L''**impératif** la présente comme un **ordre** : *viens*.

Le subjonctif n''est donc pas un temps mais un mode, et il a lui aussi ses
temps : présent, passé, et deux autres qu''on n''emploie plus guère.

### La fabrication, en trois gestes

Elle vaut pour **tous les verbes**, et c''est ce qui la rend précieuse.

> **Geste 1** — Je prends la **troisième personne du pluriel du présent de
> l''indicatif**.
> **Geste 2** — Je retire la terminaison **-ent**. Ce qui reste est le radical.
> **Geste 3** — J''ajoute les terminaisons du subjonctif : **-e, -es, -e, -ions,
> -iez, -ent**.

Voyons sur un verbe du premier groupe.

> *chanter* → ils **chant**ent → radical **chant-**
> que je chant**e**, que tu chant**es**, qu''il chant**e**,
> que nous chant**ions**, que vous chant**iez**, qu''ils chant**ent**

Et sur un verbe d''un autre groupe, pour vérifier que la méthode tient.

> *finir* → ils **finiss**ent → radical **finiss-**
> que je finiss**e**, que nous finiss**ions**
>
> *partir* → ils **part**ent → radical **part-**
> que je part**e**, que nous part**ions**
>
> *prendre* → ils **prenn**ent → radical **prenn-**
> que je prenn**e**, que nous prenn**ions**

### Les terminaisons, à savoir par cœur

> **-e, -es, -e, -ions, -iez, -ent**

Remarque qu''elles ressemblent à celles du premier groupe au présent de
l''indicatif — sauf à *nous* et *vous*, où apparaît un **i**. Garde cela en
tête : c''est tout le chapitre.

### Les irréguliers, qu''aucune méthode ne donne

Sept verbes ne suivent pas la fabrication. Il faut les apprendre.

> **être** → que je **sois**, que tu sois, qu''il soit, que nous **soyons**,
> que vous soyez, qu''ils soient
> **avoir** → que j''**aie**, que tu aies, qu''il **ait**, que nous **ayons**,
> que vous ayez, qu''ils aient
> **aller** → que j''**aille**, que nous **allions**
> **faire** → que je **fasse**, que nous fassions
> **pouvoir** → que je **puisse**, que nous puissions
> **savoir** → que je **sache**, que nous sachions
> **vouloir** → que je **veuille**, que nous **voulions**

*Note la forme « qu''il ait », sans t final à l''oreille mais avec un t à
l''écrit. « Bien qu''il ait compris » est une des orthographes les plus ratées du
français.*

### Le subjonctif passé, en une ligne

Il se forme comme tous les temps composés : **auxiliaire au subjonctif présent
+ participe passé**.

> que j''**aie** fini — qu''il **soit** parti — que nous **ayons** compris

Et il exprime un fait **antérieur** à celui de la principale.

> Je doute qu''il **soit parti**. *(il est peut-être déjà parti)*
> Je doute qu''il **parte**. *(il partira peut-être)*

---

**Exercice corrigé**

*Conjuguer au subjonctif présent, en montrant les trois gestes.*

*1. travailler, à toutes les personnes.*
*2. écrire, aux six personnes.*
*3. Compléter : il faut que nous (aller) au marché et que vous (être) à
l''heure.*

**Correction.**

*1. travailler.*

> *Geste 1* : ils **travaillent**.
> *Geste 2* : je retire -ent → radical **travaill-**.
> *Geste 3* : j''ajoute les terminaisons.

> que je travaill**e**, que tu travaill**es**, qu''il travaill**e**,
> que nous travaill**ions**, que vous travaill**iez**, qu''ils travaill**ent**

*Regarde « que nous travaillions » : il y a deux i de suite — celui du radical
et celui de la terminaison. C''est correct, et c''est le piège d''orthographe du
premier groupe en -iller, -ier, -gner.*

*2. écrire.*

> *Geste 1* : ils **écrivent**.
> *Geste 2* : radical **écriv-**.

> que j''écriv**e**, que tu écriv**es**, qu''il écriv**e**,
> que nous écriv**ions**, que vous écriv**iez**, qu''ils écriv**ent**

*La méthode a fonctionné sur un verbe du troisième groupe sans que j''aie eu
besoin de savoir à quel groupe il appartient. C''est l''intérêt des trois
gestes.*

*3.*

« Il faut que » commande toujours le subjonctif — tu le sais depuis le
chapitre 10.

*aller* est irrégulier au singulier, mais régulier au pluriel : *que nous
allions*.
*être* est irrégulier partout : *que vous soyez*.

> Il faut que nous **allions** au marché et que vous **soyez** à l''heure.

*Faute attendue sur la première : « il faut que nous allons » — c''est
l''indicatif, et il est très fréquent à l''oral.*
', NULL, 26),
    (v_chapitre_id, 'Figure : la fabrication, et le piège du 1er groupe', 2, 'figure', '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 580 300" width="580" height="300">
<rect width="580" height="300" fill="#ffffff"/>
<text x="290" y="24" text-anchor="middle" font-size="14" font-weight="700" fill="#0f172a">Le subjonctif présent du 1er groupe : une fabrication, un piège</text>

<rect x="20" y="40" width="540" height="56" rx="6" fill="#f8fafc" stroke="#94a3b8"/>
<text x="290" y="58" text-anchor="middle" font-size="10" font-weight="700" fill="#0f172a">LA FABRICATION</text>
<text x="40" y="78" font-size="10" fill="#334155">je prends la 3e personne du PLURIEL du présent de l&apos;indicatif</text>
<text x="40" y="92" font-size="10" fill="#334155">ils chant</text>
<text x="100" y="92" font-size="10" font-weight="700" fill="#b91c1c">ent</text>
<text x="136" y="92" font-size="10" fill="#334155">→ je retire -ent → radical</text>
<text x="300" y="92" font-size="10" font-weight="700" fill="#15803d">chant-</text>
<text x="356" y="92" font-size="10" fill="#334155">→ j&apos;ajoute e, es, e, ions, iez, ent</text>

<rect x="20" y="106" width="264" height="104" rx="6" fill="#dbeafe" stroke="#2563eb" stroke-width="1.5"/>
<text x="152" y="126" text-anchor="middle" font-size="11" font-weight="700" fill="#1e3a8a">INDICATIF PRÉSENT</text>
<text x="40" y="146" font-size="10" fill="#1e40af">je chante</text>
<text x="170" y="146" font-size="10" fill="#1e40af">nous chant</text>
<text x="246" y="146" font-size="10" font-weight="700" fill="#b91c1c">ons</text>
<text x="40" y="164" font-size="10" fill="#1e40af">tu chantes</text>
<text x="170" y="164" font-size="10" fill="#1e40af">vous chant</text>
<text x="246" y="164" font-size="10" font-weight="700" fill="#b91c1c">ez</text>
<text x="40" y="182" font-size="10" fill="#1e40af">il chante</text>
<text x="170" y="182" font-size="10" fill="#1e40af">ils chantent</text>
<text x="152" y="202" text-anchor="middle" font-size="9" font-style="italic" fill="#1e3a8a">le fait est donné comme réel</text>

<rect x="296" y="106" width="264" height="104" rx="6" fill="#dcfce7" stroke="#15803d" stroke-width="1.5"/>
<text x="428" y="126" text-anchor="middle" font-size="11" font-weight="700" fill="#14532d">SUBJONCTIF PRÉSENT</text>
<text x="316" y="146" font-size="10" fill="#166534">que je chante</text>
<text x="444" y="146" font-size="10" fill="#166534">que nous chant</text>
<text x="536" y="146" font-size="10" font-weight="700" fill="#15803d">ions</text>
<text x="316" y="164" font-size="10" fill="#166534">que tu chantes</text>
<text x="444" y="164" font-size="10" fill="#166534">que vous chant</text>
<text x="536" y="164" font-size="10" font-weight="700" fill="#15803d">iez</text>
<text x="316" y="182" font-size="10" fill="#166534">qu&apos;il chante</text>
<text x="444" y="182" font-size="10" fill="#166534">qu&apos;ils chantent</text>
<text x="428" y="202" text-anchor="middle" font-size="9" font-style="italic" fill="#14532d">le fait est voulu, craint, attendu</text>

<rect x="20" y="222" width="540" height="64" rx="6" fill="#fef3c7" stroke="#ca8a04" stroke-width="1.6"/>
<text x="290" y="242" text-anchor="middle" font-size="11" font-weight="700" fill="#78350f">LE PIÈGE DU PREMIER GROUPE</text>
<text x="48" y="262" font-size="9" fill="#92400e">Quatre formes sur six sont IDENTIQUES aux deux modes. Seuls « nous » et « vous » diffèrent.</text>
<text x="48" y="278" font-size="9" fill="#92400e">nous chantONS / que nous chantIONS  ·  vous chantEZ / que vous chantIEZ  ← le I qui trahit tout</text>
</svg>', NULL, 5),
    (v_chapitre_id, 'Simulation : fabriquer le subjonctif', 3, 'interactif', '{
  "widget": "former-subjonctif",
  "consigne": "Un verbe s''affiche, et la simulation te fait exécuter les trois gestes dans l''ordre : tu écris la troisième personne du pluriel du présent, elle coupe le -ent devant toi, puis tu remplis les six cases. Elle refuse de passer au geste suivant tant que le précédent n''est pas juste. Trente verbes, des quatre groupes, et les sept irréguliers y sont isolés dans un atelier à part — ceux-là, aucune méthode ne les donne, et il faut les apprendre."
}', NULL, 10),
    (v_chapitre_id, 'Le piège du premier groupe : quatre formes identiques sur six', 4, 'texte', '
Voici pourquoi le programme consacre un chapitre entier au premier groupe
alors que la fabrication est la même pour tous.

### Le problème

Pour un verbe en *-er*, le subjonctif présent et l''indicatif présent sont
**identiques à quatre personnes sur six**.

> *indicatif* : je chante, tu chantes, il chante, nous chant**ons**, vous
> chant**ez**, ils chantent
> *subjonctif* : que je chante, que tu chantes, qu''il chante, que nous
> chant**ions**, que vous chant**iez**, qu''ils chantent

Mets-les côte à côte : *chante, chantes, chante, chantent* sont les mêmes. Seuls
**nous** et **vous** diffèrent.

### La conséquence pour toi

**Première conséquence : tu ne peux pas « entendre » le subjonctif du premier
groupe au singulier.** Il faut le reconnaître par le **déclencheur** — la
conjonction ou le verbe qui le commande.

> Il faut que je **travaille**. → subjonctif, parce que « il faut que ».
> Je **travaille** tous les jours. → indicatif.

La forme est la même ; seul le contexte décide de son nom. Et c''est exactement
ce que la question 4 du BEPC demande : *à quel mode et à quel temps est ce
verbe ?*

**Seconde conséquence : à nous et vous, la faute s''entend et se voit.**

> ✗ Il faut que nous **travaillons**. → c''est l''indicatif
> ✓ Il faut que nous **travaillions**.

> ✗ Bien que vous **parlez** fort. → c''est l''indicatif
> ✓ Bien que vous **parliez** fort.

**Ce i est la seule marque visible du subjonctif au premier groupe.** Il faut
donc le surveiller comme le lait sur le feu.

### Les trois cas d''orthographe délicate

**Les verbes en -ier** : *crier, oublier, étudier, remercier.*
Le radical finit déjà par i, donc il y a **deux i** à nous et vous.

> que nous **criions**, que vous **criiez**
> que nous **oubliions**, que vous **oubliiez**
> que nous **étudiions**, que vous **étudiiez**

*C''est correct, et c''est laid. Beaucoup d''élèves n''osent pas l''écrire. Ose : la
règle ne souffre aucune exception.*

**Les verbes en -yer** : *payer, envoyer, essayer.*
Le y se change en i devant un e muet, et il reste y devant nous et vous… mais
suivi du i de la terminaison.

> que je **paie**, que nous **payions**, que vous **payiez**

**Les verbes en -gner, -iller, -eiller** : *gagner, travailler, surveiller.*
Le radical finit par un son qui masque le i.

> que nous **gagnions**, que nous **travaillions**, que vous **surveilliez**

*À l''oral, « nous gagnons » et « nous gagnions » se distinguent à peine. À
l''écrit, le i est obligatoire.*

### Le test de remplacement

Voici l''astuce qui règle tout, et elle vient du chapitre 10.

**Remplace ton verbe du premier groupe par un verbe du troisième groupe dont le
subjonctif s''entend.** *Faire*, *prendre* et *être* sont parfaits.

> « Il faut que nous travaill?ons. »
> → « Il faut que nous **fassions**. » — le subjonctif s''entend très bien.
> → donc le premier groupe doit aussi être au subjonctif : **travaillions**.

> « Nous travaillons depuis ce matin. »
> → « Nous **faisons** depuis ce matin. » — indicatif.
> → donc **travaillons**, sans i.

Trois secondes, et la faute est évitée.

---

**Exercice corrigé**

*Écrire le verbe au mode et au temps qui conviennent, puis nommer ce mode.*

*1. Il faut que nous (étudier) cette leçon avant demain.*
*2. Nous (étudier) cette leçon depuis deux heures.*
*3. Bien que vous (travailler) beaucoup, le résultat ne suit pas.*
*4. Vous (travailler) beaucoup, et cela se voit.*
*5. Je souhaite que tu (chanter) à la fête.*

**Correction.**

*1.* « Il faut que » commande le subjonctif. Le verbe est en **-ier**, donc deux
i.

> Il faut que nous **étudiions** cette leçon avant demain.
> *Mode : subjonctif présent.*

*Test de contrôle : « il faut que nous fassions » — le subjonctif s''entend,
donc il en faut un ici aussi.*

*2.* Aucun déclencheur : c''est une phrase ordinaire. **Indicatif**, et un seul
i — celui du radical.

> Nous **étudions** cette leçon depuis deux heures.
> *Mode : indicatif présent.*

*Les phrases 1 et 2 emploient le même verbe à la même personne, et s''écrivent
différemment. C''est le couple à retenir du chapitre.*

*3.* « Bien que » commande le subjonctif. Le verbe est en **-iller**.

> Bien que vous **travailliez** beaucoup, le résultat ne suit pas.
> *Mode : subjonctif présent.*

*4.* Aucun déclencheur : **indicatif**.

> Vous **travaillez** beaucoup, et cela se voit.
> *Mode : indicatif présent.*

*5.* « Souhaiter » est un verbe de volonté : subjonctif. Mais attention, le
sujet est **tu**, deuxième personne du singulier — et à cette personne, le
subjonctif du premier groupe est identique à l''indicatif.

> Je souhaite que tu **chantes** à la fête.
> *Mode : subjonctif présent.*

*La forme est « chantes », exactement comme l''indicatif. Si l''examen te demande
le mode, c''est le déclencheur « je souhaite que » qui te donne la réponse, et
rien d''autre. C''est tout le propos de cette leçon : au premier groupe, la forme
ne dit rien ; seul le contexte parle.*
', NULL, 28),
    (v_chapitre_id, 'Simulation : subjonctif ou indicatif au premier groupe', 5, 'interactif', '{
  "widget": "subjonctif-ou-indicatif-1g",
  "consigne": "Deux phrases s''affichent côte à côte avec le même verbe à la même personne — « nous étudions » et « il faut que nous étudiions » — et tu dois dire laquelle porte le i. La simulation te montre d''abord le déclencheur, puis applique le test de remplacement par « faire » pour te faire entendre la différence que le premier groupe cache. Vingt-deux couples, avec les trois familles d''orthographe délicate : les verbes en -ier qui prennent deux i, ceux en -yer, et ceux en -gner et -iller où le i disparaît à l''oreille."
}', NULL, 10),
    (v_chapitre_id, 'Les déclencheurs : quand le subjonctif est obligatoire', 6, 'texte', '
Dernière leçon, et c''est la récapitulation de tout ce que tu as vu depuis le
chapitre 10. Voici la liste complète des contextes qui imposent le subjonctif.

Au premier groupe, où la forme ne dit rien, **c''est cette liste qui te permet
de nommer le mode**. Apprends-la.

### 1. Les verbes de VOLONTÉ

> vouloir, souhaiter, désirer, exiger, ordonner, demander, interdire,
> permettre, défendre, préférer, attendre
>
> Je veux qu''il **vienne**. Ma mère exige que je **rentre** tôt.

### 2. Les verbes de SENTIMENT

> craindre, redouter, regretter, se réjouir, s''étonner, être content, être
> triste, avoir peur, être heureux
>
> Je crains qu''il ne **soit** trop tard. Je suis content que tu **viennes**.

*Exception à ne jamais oublier : **espérer** commande l''indicatif.*
> J''espère qu''il **viendra**.

### 3. Les verbes d''OPINION à la forme négative ou interrogative

> Je pense qu''il **vient**. *(affirmatif → indicatif)*
> Je ne pense pas qu''il **vienne**. *(négatif → subjonctif)*
> Penses-tu qu''il **vienne** ? *(interrogatif → subjonctif)*

### 4. Les tournures impersonnelles

> il faut que, il est nécessaire que, il est important que, il est possible
> que, il vaut mieux que, il est dommage que, il semble que
>
> Il faut que tu **partes**. Il vaut mieux que nous **restions**.

*Mais attention : « il est certain que », « il est évident que », « il paraît
que » commandent l''**indicatif**, parce qu''ils affirment.*

### 5. Les conjonctions, revues du chapitre 17

**Le but, toutes** : pour que, afin que, de peur que, de crainte que.
**L''opposition** : bien que, quoique, encore que, sans que.
**Le temps de l''antériorité** : avant que, jusqu''à ce que, en attendant que.
**La condition, sauf « si »** : à condition que, pourvu que, à moins que.

### 6. La complétive placée en tête

> **Qu''il soit** en retard ne m''étonne pas.
> **Que tu réussisses** me ferait plaisir.

Une complétive sujet se met toujours au subjonctif, quel que soit le verbe de
la principale.

### 7. Après un superlatif ou un terme restrictif

> C''est le meilleur livre que je **connaisse**.
> Il n''y a personne qui **puisse** l''aider.
> C''est la seule chose qui **vaille** la peine.

*Ce cas-là est fin, et il distingue une bonne copie. Les mots qui le
déclenchent : le seul, le premier, le dernier, le meilleur, le pire, rien,
personne, aucun.*

### Ce qui ne déclenche PAS le subjonctif

Je les liste parce que ce sont les erreurs par contagion, très fréquentes chez
l''élève qui vient d''apprendre la règle.

> **parce que** → indicatif *(la cause est un fait)*
> **après que** → indicatif *(le fait est accompli)*
> **même si** → indicatif
> **espérer** → indicatif
> **il est certain / évident / sûr que** → indicatif
> **si** de condition → ni subjonctif, ni conditionnel : indicatif

### Le moule de réponse pour la question 4

On te demandera : *à quel mode et à quel temps est le verbe souligné ?*

> « Le verbe "travaillions" est au **subjonctif présent**. Il est commandé par
> la locution "il faut que", qui exprime la nécessité, et il se reconnaît au
> **i** de la terminaison : à l''indicatif, on aurait "nous travaillons". »

Mode, temps, déclencheur, marque visible. Quatre éléments, deux points.

---

**Exercice corrigé**

*Dire si le verbe est à l''indicatif ou au subjonctif, et nommer le déclencheur
quand il y en a un.*

*1. J''espère que tu réussis ton examen.*
*2. Je doute que tu réussisses ton examen.*
*3. Il est certain que nous arrivons en retard.*
*4. Il est possible que nous arrivions en retard.*
*5. C''est le plus beau chant que je connaisse.*
*6. Après qu''il a parlé, la salle s''est tue.*

**Correction.**

*1.* **Indicatif.** Déclencheur : aucun — et c''est justement l''exception.
« Espérer » est un verbe de sentiment, mais il commande l''indicatif. La forme
« réussis » est celle de l''indicatif présent.

*2.* **Subjonctif.** Déclencheur : « douter », verbe qui exprime l''incertitude,
proche des verbes de sentiment. La forme est « réussisses » — et ici, par
chance, elle se distingue de l''indicatif « tu réussis ».

*Compare les deux phrases : même verbe, même personne, et deux formes
différentes. C''est que « réussir » est du deuxième groupe, et que son subjonctif
s''entend. Au premier groupe, les deux formes seraient identiques.*

*3.* **Indicatif.** Déclencheur : « il est certain que » affirme la réalité du
fait. Les tournures impersonnelles ne commandent pas toutes le subjonctif :
celles qui **affirment** gardent l''indicatif.

*4.* **Subjonctif.** Déclencheur : « il est possible que » présente le fait
comme une éventualité, non comme un fait.

*Les phrases 3 et 4 sont le second couple à retenir : deux tournures
impersonnelles voisines, deux modes opposés, et c''est le sens de la tournure
qui décide.*

*5.* **Subjonctif.** Déclencheur : le **superlatif** « le plus beau ». C''est le
septième cas de la liste, et il est peu connu : après *le seul*, *le premier*,
*le meilleur*, *le plus beau*, la relative se met au subjonctif.

*La forme « connaisse » le montre, puisqu''elle diffère de l''indicatif « je
connais ».*

*6.* **Indicatif.** Déclencheur : « après que », qui parle d''un fait accompli.

*« Après qu''il ait parlé » est la faute attendue, et elle est devenue si
courante à l''oral que beaucoup la croient correcte. Le BEPC la sanctionne
encore.*
', NULL, 26),
    (v_chapitre_id, 'Simulation : les sept déclencheurs', 7, 'interactif', '{
  "widget": "declencheurs-subjonctif",
  "consigne": "Une phrase s''affiche avec son verbe en blanc, et la simulation te montre d''abord le mot qui commande — verbe de volonté, tournure impersonnelle, conjonction, superlatif — puis te demande le mode avant la forme. Les sept cas du cours y sont, et les six faux déclencheurs aussi : parce que, après que, même si, espérer, il est certain que, et le « si » de condition. Vingt-huit phrases, et quatre couples montés l''un contre l''autre — « il est certain que » contre « il est possible que », « j''espère que » contre « je doute que »."
}', NULL, 10),
    (v_chapitre_id, 'Quiz du chapitre 20', 8, 'quiz', '{
  "titre": "Vérifie que tu as compris",
  "questions": [
    {
      "question": "Comment fabrique-t-on le subjonctif présent de n''importe quel verbe ?",
      "choix": [
        "Avec l''infinitif",
        "On prend la 3e personne du pluriel du présent de l''indicatif, on retire -ent, et on ajoute -e, -es, -e, -ions, -iez, -ent",
        "Avec le radical du futur",
        "Avec l''auxiliaire avoir"
      ],
      "bonne": 1,
      "explication": "« ils finissent » → finiss- → que je finisse. La méthode fonctionne sans même savoir à quel groupe le verbe appartient."
    },
    {
      "question": "Pourquoi le programme consacre-t-il un chapitre au subjonctif du 1er groupe ?",
      "choix": [
        "Parce qu''il est plus difficile à fabriquer",
        "Parce qu''il est identique à l''indicatif à quatre personnes sur six : seuls « nous » et « vous » diffèrent, par un i",
        "Parce qu''il est irrégulier",
        "Parce qu''il est rare"
      ],
      "bonne": 1,
      "explication": "« je chante », « tu chantes », « il chante », « ils chantent » sont les mêmes aux deux modes. Ce i de « nous chantions » est la seule marque visible."
    },
    {
      "question": "« Il faut que nous travaillons » ou « travaillions » ?",
      "choix": [
        "travaillons",
        "travaillions : « il faut que » commande le subjonctif, et à « nous » le i est obligatoire",
        "les deux se valent",
        "cela dépend du sens"
      ],
      "bonne": 1,
      "explication": "Test de contrôle : remplace par « faire » — « il faut que nous fassions » : le subjonctif s''entend, donc il en faut un au premier groupe aussi."
    },
    {
      "question": "Comment s''écrit le subjonctif de « étudier » à la 1re personne du pluriel ?",
      "choix": [
        "que nous étudions",
        "que nous étudiions, avec deux i : celui du radical et celui de la terminaison",
        "que nous étudierions",
        "que nous étudiassions"
      ],
      "bonne": 1,
      "explication": "C''est correct, et c''est laid. Beaucoup d''élèves n''osent pas l''écrire. Même chose pour crier, oublier, remercier."
    },
    {
      "question": "Au premier groupe, comment nomme-t-on le mode d''une forme comme « que tu chantes » ?",
      "choix": [
        "À l''oreille",
        "Par le DÉCLENCHEUR : la forme est identique à l''indicatif, seul le contexte — « je souhaite que » — donne la réponse",
        "Par la terminaison",
        "Par le sujet"
      ],
      "bonne": 1,
      "explication": "C''est tout le propos du chapitre : au premier groupe, la forme ne dit rien ; seul le contexte parle. Et c''est exactement ce que la question 4 du BEPC demande."
    },
    {
      "question": "Quelle tournure impersonnelle NE commande PAS le subjonctif ?",
      "choix": [
        "Il faut que",
        "Il est certain que — les tournures qui AFFIRMENT gardent l''indicatif",
        "Il est possible que",
        "Il vaut mieux que"
      ],
      "bonne": 1,
      "explication": "« Il est certain que nous arrivons » contre « il est possible que nous arrivions » : deux tournures voisines, deux modes opposés, et c''est le sens qui décide."
    },
    {
      "question": "« C''est le plus beau chant que je … » — quel mode, et pourquoi ?",
      "choix": [
        "L''indicatif",
        "Le subjonctif (« connaisse »), déclenché par le superlatif : après le seul, le premier, le meilleur, le plus beau, la relative s''y met",
        "Le conditionnel",
        "L''impératif"
      ],
      "bonne": 1,
      "explication": "C''est le septième déclencheur, peu connu, et il distingue une bonne copie. Les mots qui l''annoncent : le seul, le premier, le dernier, le meilleur, le pire, rien, personne, aucun."
    }
  ]
}', NULL, 5);

  RAISE NOTICE '8 leçons ajoutées au chapitre 20, Le présent du subjonctif des verbes du 1er groupe.';
END $fr3$;
