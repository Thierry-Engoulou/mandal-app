-- ---------------------------------------------------------------------------
-- M'Andal — Français, classe de 3ème
-- Chapitre 10 : La proposition subordonnée complétive
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
  WHERE programme_id = v_programme_id AND ordre = 10;

  IF v_chapitre_id IS NULL THEN
    INSERT INTO public.chapitres (programme_id, titre, ordre, niveau)
    VALUES (v_programme_id, 'La proposition subordonnée complétive', 10, 'Module 2 : Citoyenneté et environnement')
    RETURNING id INTO v_chapitre_id;
    RAISE NOTICE 'Chapitre 10 créé.';
  END IF;

  -- Les leçons. Si le chapitre en a déjà, on passe son tour sans rien toucher.
  SELECT count(*) INTO v_deja FROM public.concepts WHERE chapitre_id = v_chapitre_id;
  IF v_deja > 0 THEN
    RAISE NOTICE 'Le chapitre 10 a déjà ses % leçons, je n''y touche pas.', v_deja;
    RETURN;
  END IF;

  INSERT INTO public.concepts
    (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes) VALUES
    (v_chapitre_id, 'La complétive : elle complète un verbe', 1, 'texte', '
Deuxième des trois subordonnées du programme. Celle-ci est plus simple que la
relative, à une difficulté près — et c''est justement cette difficulté que
l''examen choisit.

### Définition

La **proposition subordonnée complétive** est introduite par la conjonction
**que**, et elle **complète un verbe**.

> Je sais **que le car est complet**.

Elle répond à la question *je sais quoi ?*. Elle occupe donc, dans la phrase, la
place d''un complément d''objet direct.

### Comparez avec un groupe nominal

C''est le meilleur moyen de la reconnaître : la complétive peut être remplacée
par un simple nom.

> Je sais **que le car est complet**. → Je sais **cette nouvelle**.
> J''espère **qu''il viendra**. → J''espère **sa venue**.
> Je crains **qu''il ne soit trop tard**. → Je crains **un retard**.

Si tu peux remplacer la subordonnée par un nom à la même place, c''est une
complétive.

### Les verbes qui l''appellent

Tous les verbes n''en acceptent pas. Ceux qui la réclament se rangent en
familles, et les connaître t''aidera au moment du subjonctif.

**Les verbes de déclaration** : dire, affirmer, annoncer, répondre, expliquer,
raconter.

**Les verbes d''opinion et de connaissance** : penser, croire, savoir, estimer,
juger, trouver.

**Les verbes de perception** : voir, entendre, sentir, remarquer, constater.

**Les verbes de volonté** : vouloir, souhaiter, ordonner, exiger, demander,
interdire.

**Les verbes de sentiment** : craindre, regretter, se réjouir, s''étonner,
être heureux, être triste.

Retiens bien ces cinq familles. Les trois premières commandent l''indicatif,
les deux dernières le subjonctif — nous y venons à la troisième leçon.

### Sa fonction

Elle est presque toujours **complément d''objet direct** du verbe de la
principale.

> Je sais **que le car est complet**.
> Nature : proposition subordonnée conjonctive complétive.
> Fonction : complément d''objet direct du verbe « sais ».

Deux cas particuliers, que tu rencontreras :

**Sujet**, quand elle est placée en tête.

> **Qu''il soit en retard** ne m''étonne pas.
> *(qu''est-ce qui ne m''étonne pas ? qu''il soit en retard → sujet)*

**Complément du nom ou de l''adjectif**, après certains mots.

> J''ai l''impression **qu''il ment**. *(complément du nom « impression »)*
> Je suis certain **qu''il viendra**. *(complément de l''adjectif « certain »)*

---

**Exercice corrigé**

*Relever la complétive, donner sa nature et sa fonction, et prouver que c''en est
une en la remplaçant par un nom.*

*1. Le professeur a annoncé que le contrôle était reporté.*
*2. Qu''il réussisse me ferait plaisir.*
*3. J''ai la certitude qu''il dit vrai.*

**Correction.**

*1.* La subordonnée est **« que le contrôle était reporté »**.

*Nature* : proposition subordonnée conjonctive complétive, introduite par la
conjonction *que*.

*Fonction* : le professeur a annoncé **quoi** ? Que le contrôle était reporté.
C''est donc un **complément d''objet direct du verbe « a annoncé »**.

*La preuve par le nom* : « Le professeur a annoncé **le report du contrôle**. »
La subordonnée se remplace par un groupe nominal à la même place : c''est bien
une complétive.

*2.* La subordonnée est **« Qu''il réussisse »**.

*Nature* : proposition subordonnée conjonctive complétive.

*Fonction* : **qu''est-ce qui** me ferait plaisir ? Qu''il réussisse. Elle est
donc **sujet du verbe « ferait »**. C''est le cas particulier de la complétive
placée en tête.

*La preuve par le nom* : « **Sa réussite** me ferait plaisir. »

*Remarque le verbe au subjonctif, « réussisse ». Nous verrons pourquoi à la
troisième leçon : la complétive sujet se met toujours au subjonctif.*

*3.* La subordonnée est **« qu''il dit vrai »**.

*Nature* : proposition subordonnée conjonctive complétive.

*Fonction* : attention, ce n''est pas un complément d''objet direct. Le verbe de
la principale est « ai », et on n''a pas « quelque chose que l''on a dit ». La
subordonnée complète le **nom** « certitude » : j''ai la certitude **de quoi** ?
Elle est donc **complément du nom « certitude »**.

*La preuve par le nom* : « J''ai la certitude **de sa sincérité**. »

*C''est le piège de l''exercice : le mot complété n''est pas toujours le verbe. Pose
la question au mot qui précède immédiatement le « que ».*
', NULL, 26),
    (v_chapitre_id, 'Figure : relative ou complétive, le même « que »', 2, 'figure', '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 580 270" width="580" height="270">
<rect width="580" height="270" fill="#ffffff"/>
<text x="290" y="24" text-anchor="middle" font-size="14" font-weight="700" fill="#0f172a">Le même mot « que », deux subordonnées différentes</text>
<text x="290" y="42" text-anchor="middle" font-size="10" fill="#64748b">Une seule question tranche : « que » remplace-t-il un nom écrit juste avant ?</text>

<rect x="20" y="58" width="262" height="196" rx="6" fill="#dbeafe" stroke="#2563eb" stroke-width="1.6"/>
<text x="151" y="80" text-anchor="middle" font-size="12" font-weight="700" fill="#1e3a8a">RELATIVE</text>
<line x1="34" y1="90" x2="268" y2="90" stroke="#93c5fd"/>
<text x="34" y="110" font-size="10" fill="#1e40af">Je lis le livre</text>
<text x="124" y="110" font-size="10" font-weight="700" fill="#2563eb">que</text>
<text x="152" y="110" font-size="10" fill="#1e40af">tu m&apos;as prêté.</text>
<text x="34" y="134" font-size="9" fill="#1e3a8a">« que » remplace « le livre »</text>
<text x="34" y="150" font-size="9" fill="#1e3a8a">→ il a un ANTÉCÉDENT</text>
<text x="34" y="172" font-size="9" fill="#1e3a8a">« que » est complément d&apos;objet</text>
<text x="34" y="184" font-size="9" fill="#1e3a8a">direct de « as prêté »</text>
<line x1="60" y1="198" x2="242" y2="198" stroke="#bfdbfe"/>
<text x="151" y="218" text-anchor="middle" font-size="9" font-weight="700" fill="#1e3a8a">Elle complète un NOM</text>
<text x="151" y="236" text-anchor="middle" font-size="8" font-style="italic" fill="#475569">on peut la supprimer :</text>
<text x="151" y="248" text-anchor="middle" font-size="8" font-style="italic" fill="#475569">« Je lis le livre » tient</text>

<rect x="298" y="58" width="262" height="196" rx="6" fill="#dcfce7" stroke="#15803d" stroke-width="1.6"/>
<text x="429" y="80" text-anchor="middle" font-size="12" font-weight="700" fill="#14532d">COMPLÉTIVE</text>
<line x1="312" y1="90" x2="546" y2="90" stroke="#86efac"/>
<text x="312" y="110" font-size="10" fill="#166534">Je sais</text>
<text x="362" y="110" font-size="10" font-weight="700" fill="#15803d">que</text>
<text x="390" y="110" font-size="10" fill="#166534">tu as raison.</text>
<text x="312" y="134" font-size="9" fill="#14532d">« que » ne remplace rien</text>
<text x="312" y="150" font-size="9" fill="#14532d">→ il n&apos;a PAS d&apos;antécédent</text>
<text x="312" y="172" font-size="9" fill="#14532d">« que » n&apos;a aucune fonction :</text>
<text x="312" y="184" font-size="9" fill="#14532d">c&apos;est un simple outil de liaison</text>
<line x1="338" y1="198" x2="520" y2="198" stroke="#bbf7d0"/>
<text x="429" y="218" text-anchor="middle" font-size="9" font-weight="700" fill="#14532d">Elle complète un VERBE</text>
<text x="429" y="236" text-anchor="middle" font-size="8" font-style="italic" fill="#475569">on ne peut pas la supprimer :</text>
<text x="429" y="248" text-anchor="middle" font-size="8" font-style="italic" fill="#475569">« Je sais » attend la suite</text>
</svg>', NULL, 5),
    (v_chapitre_id, 'Simulation : la complétive et sa fonction', 3, 'interactif', '{
  "widget": "completive-cod",
  "consigne": "Une phrase s''affiche, et tu surlignes la complétive, puis tu donnes sa fonction. La simulation te fait d''abord passer le test du remplacement : elle te propose des groupes nominaux et tu choisis celui qui pourrait prendre la place de la subordonnée — c''est la preuve qu''il s''agit bien d''une complétive. Quatorze phrases, dont quatre où la fonction n''est pas complément d''objet direct : deux sujets, un complément du nom, un complément de l''adjectif."
}', NULL, 10),
    (v_chapitre_id, 'Relative ou complétive ? Le même mot, deux natures', 4, 'texte', '
Voici la difficulté annoncée, et c''est elle que l''examen choisit. Le mot *que*
introduit les deux subordonnées. Comment les distinguer ?

### Une seule question tranche

> **« Que » remplace-t-il un nom écrit juste avant ?**

Si oui, c''est un **pronom relatif**, et la subordonnée est une **relative**.
Si non, c''est une **conjonction**, et la subordonnée est une **complétive**.

Comparons.

> Je lis le livre **que tu m''as prêté**.

*Que* remplace *le livre* : tu m''as prêté **le livre**. Il a donc un
antécédent. C''est un **pronom relatif**, et la subordonnée est **relative**.

> Je sais **que tu as raison**.

*Que* ne remplace rien du tout. Essaie : « je sais ... tu as raison ». Il n''y a
pas de nom avant lui qu''il reprendrait. C''est une **conjonction de
subordination**, et la subordonnée est **complétive**.

### Trois différences qui en découlent

**Le « que » a-t-il une fonction ?**

Dans la relative, oui : il est sujet, complément d''objet direct, et il faut la
donner.

Dans la complétive, non. Il n''est qu''un outil de liaison, et c''est exactement
ce qu''il faut répondre si on te le demande : *« que » est une conjonction de
subordination, il n''a pas de fonction*.

**Que complète la subordonnée ?**

La relative complète un **nom**. La complétive complète un **verbe**.

**Peut-on la supprimer ?**

La relative, souvent oui : « Je lis le livre » tient debout.
La complétive, non : « Je sais » reste suspendu, on attend la suite.

### Le tableau à retenir

Pose-toi les quatre questions dans l''ordre, et tu ne te tromperas plus.

> 1. Y a-t-il un nom juste avant le « que » qu''il pourrait remplacer ?
> 2. Le « que » a-t-il une fonction dans sa proposition ?
> 3. La subordonnée complète-t-elle un nom ou un verbe ?
> 4. Peut-on la supprimer sans casser la phrase ?
>
> Quatre oui du premier type → relative.
> Quatre non → complétive.

### Attention au faux ami

Il existe un troisième « que », que tu dois écarter : celui des **comparaisons**
et de certaines locutions.

> Il est plus grand **que** son frère. *(comparaison, pas de subordonnée)*
> Il travaille **si** bien **qu''**il réussira. *(locution « si… que », qui
> introduit une circonstancielle de conséquence)*
> **Bien que** ce soit difficile, il insiste. *(locution « bien que »,
> circonstancielle d''opposition)*

Dans ces trois cas, le « que » ne fonctionne pas seul : il appartient à une
locution, et la subordonnée est **circonstancielle**. Tu les étudieras au
module 3.

---

**Exercice corrigé**

*Pour chaque phrase, dire si la subordonnée est relative ou complétive, et
justifier en quatre points.*

*1. Le conseil que tu m''as donné était bon.*
*2. Le conseil que tu viennes m''a surpris.*
*3. J''ai entendu que la route était coupée.*
*4. J''ai entendu le bruit que faisait la moto.*

**Correction.**

*1.* **Relative.**

*Y a-t-il un nom juste avant ?* Oui, « le conseil ». *Le « que » le
remplace-t-il ?* Oui : tu m''as donné **le conseil**. *A-t-il une fonction ?*
Oui, complément d''objet direct de « as donné ». *Peut-on supprimer ?* Oui :
« Le conseil était bon » tient debout.

*2.* **Complétive.** Et c''est le piège de l''exercice, car la phrase commence
comme la précédente.

*Y a-t-il un nom juste avant ?* Oui, « le conseil ». *Mais le « que » le
remplace-t-il ?* **Non.** Essaie : « tu viennes le conseil » n''a aucun sens. Le
« que » ne reprend rien. *A-t-il une fonction ?* Non. *Que complète la
subordonnée ?* Le nom « conseil », mais sans le remplacer : elle en dit le
contenu. C''est une **complétive complément du nom « conseil »**.

*La preuve par le nom : « Ta venue m''a surpris. »*

*Retiens ce couple de phrases : il montre que le mot placé avant le « que » ne
suffit pas. Il faut vérifier que le « que » le REMPLACE.*

*3.* **Complétive.**

*Y a-t-il un nom juste avant ?* Non, il y a le verbe « ai entendu ». *Le
« que » remplace-t-il quelque chose ?* Non. *Que complète la subordonnée ?*
Le verbe « ai entendu ». *Peut-on supprimer ?* Non : « J''ai entendu » reste
suspendu.

*Fonction : complément d''objet direct de « ai entendu ».*

*4.* **Relative.**

*Y a-t-il un nom juste avant ?* Oui, « le bruit ». *Le « que » le
remplace-t-il ?* Oui : la moto faisait **le bruit**. *A-t-il une fonction ?*
Oui, complément d''objet direct de « faisait ». *Peut-on supprimer ?* Oui :
« J''ai entendu le bruit » tient.

*Les phrases 3 et 4 commencent toutes deux par « J''ai entendu que ». Seule
l''analyse les sépare, et c''est exactement ce que le correcteur veut voir.*
', NULL, 28),
    (v_chapitre_id, 'Simulation : trier les « que »', 5, 'interactif', '{
  "widget": "que-relatif-ou-completive",
  "consigne": "Vingt phrases, toutes avec un « que », et trois cases : relative, complétive, ni l''une ni l''autre. Pour chacune, la simulation te fait passer le test décisif — elle essaie de remplacer le « que » par le nom qui précède, et tu vois tout de suite si la phrase obtenue a un sens. Les faux amis sont dans le lot : le « que » de la comparaison, celui de « si… que », celui de « bien que ». Et deux phrases presque identiques y sont glissées, l''une relative, l''autre complétive."
}', NULL, 10),
    (v_chapitre_id, 'Indicatif ou subjonctif dans la complétive', 6, 'texte', '
Dernière leçon du chapitre, et elle est utile bien au-delà de l''examen : c''est
une faute que font beaucoup d''adultes.

### La règle tient aux cinq familles

Tu les as vues à la première leçon. Le mode du verbe de la complétive dépend du
**verbe de la principale**.

**Verbes de déclaration, d''opinion, de connaissance, de perception → INDICATIF.**

Ces verbes présentent le fait comme **réel**.

> Je sais **qu''il vient**. *(indicatif)*
> Il affirme **qu''elle a raison**. *(indicatif)*
> Je vois **qu''il pleut**. *(indicatif)*
> Je pense **qu''il réussira**. *(indicatif)*

**Verbes de volonté et de sentiment → SUBJONCTIF.**

Ces verbes présentent le fait comme **souhaité, craint, voulu** : il n''est pas
donné comme réel.

> Je veux **qu''il vienne**. *(subjonctif)*
> Il exige **qu''elle parte**. *(subjonctif)*
> Je crains **qu''il ne soit trop tard**. *(subjonctif)*
> Je suis heureux **qu''elle réussisse**. *(subjonctif)*

Compare les deux premiers exemples de chaque série : *qu''il **vient*** et
*qu''il **vienne***. Le fait est le même ; ce qui change, c''est la manière dont
le verbe principal le présente.

### Le cas qui fait trébucher tout le monde

**Les verbes d''opinion à la forme négative ou interrogative passent au
subjonctif.**

> Je pense **qu''il viendra**. *(affirmatif → indicatif)*
> Je ne pense pas **qu''il vienne**. *(négatif → subjonctif)*
> Penses-tu **qu''il vienne** ? *(interrogatif → subjonctif)*

La raison est logique : en niant ou en interrogeant, on retire au fait son
caractère certain.

### Un verbe à ne jamais oublier

**Après « espérer », on emploie l''indicatif**, bien que ce soit un verbe de
sentiment. C''est une exception, et elle tombe souvent.

> J''espère **qu''il viendra**. *(et non « qu''il vienne »)*

### Former le subjonctif présent

Tu l''étudieras en détail au module 3, pour les verbes du premier groupe. Pour
l''instant, retiens la fabrication générale.

On part de la **troisième personne du pluriel du présent de l''indicatif**, on
retire la terminaison *-ent*, et on ajoute : *-e, -es, -e, -ions, -iez, -ent*.

> finir → ils **finiss**ent → que je finisse, que tu finisses, qu''il finisse,
> que nous finissions, que vous finissiez, qu''ils finissent

Les irréguliers à savoir par cœur :

> être → que je **sois**, que tu sois, qu''il soit, que nous soyons
> avoir → que j''**aie**, que tu aies, qu''il ait, que nous ayons
> aller → que j''**aille**, que nous allions
> faire → que je **fasse**
> pouvoir → que je **puisse**
> savoir → que je **sache**
> vouloir → que je **veuille**

### La faute à éviter absolument

> « Il faut que je **sois** à l''heure. » *(et non « que je suis »)*
> « Bien qu''il **ait** compris. » *(et non « qu''il a »)*
> « Avant que tu **partes**. » *(et non « que tu pars »)*

*Il faut que* commande toujours le subjonctif. C''est la construction la plus
fréquente du français, et c''est celle où la faute se voit le plus.

---

**Exercice corrigé**

*Mettre le verbe entre parenthèses au mode et au temps qui conviennent, et
justifier.*

*1. Je crois qu''il (être) en retard.*
*2. Je ne crois pas qu''il (être) en retard.*
*3. Ma mère veut que je (faire) mes devoirs avant la nuit.*
*4. J''espère que tu (pouvoir) venir.*
*5. Il faut que nous (aller) au marché avant midi.*

**Correction.**

*1.* « Croire » est un verbe d''opinion à la forme **affirmative** : il présente
le fait comme réel. Donc **indicatif**.

> Je crois qu''il **est** en retard.

*2.* Le même verbe, mais à la forme **négative**. En niant, je retire au fait
son caractère certain. Donc **subjonctif**.

> Je ne crois pas qu''il **soit** en retard.

*Les phrases 1 et 2 sont le couple à retenir : même verbe, deux modes, et c''est
la négation qui décide.*

*3.* « Vouloir » est un verbe de **volonté** : le fait est souhaité, pas réel.
Donc **subjonctif**. Le subjonctif de *faire* est irrégulier.

> Ma mère veut que je **fasse** mes devoirs avant la nuit.

*4.* « Espérer » est l''**exception** : malgré son sens de sentiment, il commande
l''**indicatif**. Et le temps est le futur, puisqu''on espère pour plus tard.

> J''espère que tu **pourras** venir.

*Si tu écris « que tu puisses venir », c''est la faute attendue — et elle est
extrêmement répandue.*

*5.* « Il faut que » commande toujours le **subjonctif**. Celui d''*aller* est
irrégulier au singulier mais régulier au pluriel : *que nous allions*.

> Il faut que nous **allions** au marché avant midi.

*Un dernier conseil, qui t''évitera bien des fautes à l''écrit : quand tu doutes,
remplace mentalement ton verbe par « faire » ou par « être », dont le subjonctif
s''entend très bien. « Il faut que je sois » sonne juste, « il faut que je suis »
sonne faux. Si l''oreille tranche pour « faire » ou « être », elle a tranché pour
tous les autres.*
', NULL, 28),
    (v_chapitre_id, 'Simulation : indicatif ou subjonctif ?', 7, 'interactif', '{
  "widget": "indicatif-ou-subjonctif",
  "consigne": "Une phrase à trou s''affiche, et la simulation te montre d''abord le verbe de la principale en le rangeant dans sa famille — déclaration, opinion, perception, volonté, sentiment — car c''est lui qui décide. Tu choisis ensuite le mode, puis tu écris la forme. Dix-huit phrases, et les trois pièges du cours y sont : le verbe d''opinion qui passe au subjonctif dès qu''on le nie, l''exception « espérer » qui garde l''indicatif, et le « il faut que » que tout le monde écorche. Un bouton te souffle l''astuce de l''oreille : remplace par « être » et écoute."
}', NULL, 10),
    (v_chapitre_id, 'Quiz du chapitre 10', 8, 'quiz', '{
  "titre": "Vérifie que tu as compris",
  "questions": [
    {
      "question": "Qu''est-ce qu''une proposition subordonnée complétive ?",
      "choix": [
        "Une proposition introduite par un pronom relatif",
        "Une proposition introduite par la conjonction « que » et qui complète un VERBE",
        "Une proposition qui complète un nom",
        "Une proposition indépendante"
      ],
      "bonne": 1,
      "explication": "La relative complète un nom, la complétive complète un verbe. Et la complétive peut se remplacer par un groupe nominal : « je sais cette nouvelle »."
    },
    {
      "question": "Quelle question permet de distinguer un « que » relatif d''un « que » conjonction ?",
      "choix": [
        "Est-il au début de la phrase ?",
        "Remplace-t-il un nom écrit juste avant ? Si oui c''est un pronom relatif, sinon une conjonction",
        "Est-il suivi d''un verbe ?",
        "Y a-t-il une virgule ?"
      ],
      "bonne": 1,
      "explication": "« Je lis le livre que tu m''as prêté » : tu m''as prêté LE LIVRE, donc relatif. « Je sais que tu as raison » : le « que » ne remplace rien, donc conjonction."
    },
    {
      "question": "Le « que » d''une complétive a-t-il une fonction ?",
      "choix": [
        "Oui, il est complément d''objet direct",
        "Non : c''est une conjonction de subordination, un simple outil de liaison",
        "Oui, il est sujet",
        "Cela dépend de la phrase"
      ],
      "bonne": 1,
      "explication": "C''est exactement ce qu''il faut répondre si on te le demande. Dans la relative au contraire, le pronom a toujours une fonction à donner."
    },
    {
      "question": "Après un verbe de volonté comme « vouloir » ou « exiger », quel mode ?",
      "choix": [
        "L''indicatif",
        "Le subjonctif, car le fait est souhaité et non donné comme réel",
        "Le conditionnel",
        "L''impératif"
      ],
      "bonne": 1,
      "explication": "« Je sais qu''il VIENT » mais « je veux qu''il VIENNE ». Le fait est le même ; ce qui change, c''est la manière dont le verbe principal le présente."
    },
    {
      "question": "« Je pense qu''il viendra » devient, à la forme négative…",
      "choix": [
        "Je ne pense pas qu''il viendra",
        "Je ne pense pas qu''il vienne : les verbes d''opinion passent au subjonctif à la forme négative ou interrogative",
        "Je ne pense pas qu''il venait",
        "La phrase ne change pas"
      ],
      "bonne": 1,
      "explication": "La raison est logique : en niant ou en interrogeant, on retire au fait son caractère certain."
    },
    {
      "question": "Quel mode après « espérer » ?",
      "choix": [
        "Le subjonctif, car c''est un sentiment",
        "L''indicatif : c''est une exception, et elle tombe souvent",
        "Le conditionnel",
        "Les deux se valent"
      ],
      "bonne": 1,
      "explication": "« J''espère qu''il VIENDRA », et non « qu''il vienne ». C''est l''une des fautes les plus répandues du français écrit."
    },
    {
      "question": "Quelle astuce permet de trancher quand on doute du mode ?",
      "choix": [
        "Compter les syllabes",
        "Remplacer le verbe par « être » ou « faire », dont le subjonctif s''entend très bien : « il faut que je sois » sonne juste, « que je suis » sonne faux",
        "Mettre au pluriel",
        "Changer de verbe"
      ],
      "bonne": 1,
      "explication": "Si l''oreille tranche pour « être » ou « faire », elle a tranché pour tous les autres verbes de la même construction."
    }
  ]
}', NULL, 5);

  RAISE NOTICE '8 leçons ajoutées au chapitre 10, La proposition subordonnée complétive.';
END $fr3$;
