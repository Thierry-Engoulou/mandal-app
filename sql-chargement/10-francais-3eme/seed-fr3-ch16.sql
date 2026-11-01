-- ---------------------------------------------------------------------------
-- M'Andal — Français, classe de 3ème
-- Chapitre 16 : Défendre un point de vue, contredire, s'opposer
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
  WHERE programme_id = v_programme_id AND ordre = 16;

  IF v_chapitre_id IS NULL THEN
    INSERT INTO public.chapitres (programme_id, titre, ordre, niveau)
    VALUES (v_programme_id, 'Défendre un point de vue, contredire, s''opposer', 16, 'Module 2 : Citoyenneté et environnement')
    RETURNING id INTO v_chapitre_id;
    RAISE NOTICE 'Chapitre 16 créé.';
  END IF;

  -- Les leçons. Si le chapitre en a déjà, on passe son tour sans rien toucher.
  SELECT count(*) INTO v_deja FROM public.concepts WHERE chapitre_id = v_chapitre_id;
  IF v_deja > 0 THEN
    RAISE NOTICE 'Le chapitre 16 a déjà ses % leçons, je n''y touche pas.', v_deja;
    RETURN;
  END IF;

  INSERT INTO public.concepts
    (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes) VALUES
    (v_chapitre_id, 'Défendre un point de vue à l''oral', 1, 'texte', '
Dernier chapitre du module, et c''est celui de l''**expression orale**. Il compte,
même s''il ne se note pas au BEPC : tu auras à défendre une opinion devant
d''autres toute ta vie, en classe, au travail, dans une réunion de quartier.

### L''oral n''est pas de l''écrit lu

C''est la première chose à comprendre. Un texte écrit se relit ; une parole ne
se rattrape pas. L''auditeur ne peut pas revenir en arrière.

Il en découle trois différences.

**Les phrases sont plus courtes.** À l''écrit, une phrase de trois lignes passe.
À l''oral, l''auditeur se perd au bout de deux propositions.

**Le plan est annoncé.** À l''écrit, le lecteur voit les paragraphes. À l''oral,
il ne voit rien : il faut lui dire où tu en es.

> « Je vais dire trois choses. La première… »
> « J''en viens à mon second point. »
> « Pour terminer… »

Ces phrases paraissent lourdes à l''écrit. À l''oral, elles sont indispensables :
ce sont tes paragraphes.

**La répétition est permise.** À l''écrit, répéter est une faute. À l''oral,
répéter l''idée principale deux ou trois fois est ce qui la fait retenir.

### La structure d''une intervention

Quatre temps, et ils tiennent en deux minutes.

**1. L''accroche** — une phrase qui pose le problème et retient l''attention. Un
fait, un chiffre, une question.

> « Dans notre quartier, le camion de la commune passe une fois par mois. »

**2. La position** — ce que tu défends, en une phrase, tout de suite.

> « Je pense que nous devons écrire à la mairie plutôt que de ramasser
> nous-mêmes. »

Ne garde jamais ta position pour la fin. L''auditeur doit savoir dès la
quinzième seconde où tu vas ; sinon il écoute sans savoir quoi écouter.

**3. Les arguments** — deux, trois au maximum, annoncés et séparés.

> « Et je dis cela pour deux raisons. D''abord… Ensuite… »

**4. La chute** — une phrase qui conclut et qui reste. C''est elle qu''on
retiendra, alors prépare-la.

> « Nous pouvons nettoyer la rue. Nous ne pouvons pas nettoyer la rue chaque
> mois pendant dix ans. »

### Ce qui se joue dans la voix

Le contenu ne fait pas tout. Quatre réglages, et ils s''apprennent.

**Le débit.** Presque tout le monde parle trop vite quand il est intimidé.
Ralentis : ce qui te paraît lent de l''intérieur paraît posé de l''extérieur.

**Le volume.** Parle pour la personne la plus éloignée de la salle, pas pour
celle du premier rang.

**Le regard.** Balaie l''auditoire. Celui qui fixe ses notes n''est pas écouté,
même s''il a raison.

**Le silence.** C''est le plus difficile et le plus efficace. Deux secondes de
silence avant de commencer, et une après ta phrase la plus importante. De
l''intérieur, ces deux secondes paraissent une éternité ; de l''extérieur, elles
passent inaperçues — ou plutôt, elles donnent du poids.

Tu as déjà rencontré ce réglage au chapitre 8, avec la console de l''orateur.
Il vaut pour toutes les prises de parole de ta vie.

### Ce qu''il faut supprimer

**Les tics de langue** : « euh », « voilà », « en fait », « du coup »,
« quoi ». On ne les entend pas chez soi ; on les compte chez les autres.

**Les excuses d''entrée** : « je ne suis pas très bon pour parler », « je n''ai
pas eu le temps de préparer ». Elles ne te protègent pas, elles préviennent
l''auditoire qu''il peut t''écouter distraitement.

**Les formules creuses** : « comme chacun sait », « il est évident que ». Si
c''était évident, tu n''aurais pas besoin de le dire.

---

**Exercice corrigé**

*Voici une intervention improvisée, transcrite telle quelle. La critiquer, puis
la réécrire en deux minutes de parole.*

> « Euh, bonjour, alors moi je voulais dire que du coup, le problème des
> ordures, enfin voilà, c''est compliqué quoi. Parce que en fait il y a des gens
> qui jettent et d''autres qui ramassent, et donc euh, c''est pas normal quoi.
> Moi je pense qu''il faudrait que, enfin, que les gens ils fassent attention.
> Voilà. C''est tout ce que je voulais dire. Merci. »

**Correction.**

*Ce qui ne va pas.*

**Aucune position claire.** « Il faudrait que les gens fassent attention » n''est
pas une position : c''est un souhait. On ne sait pas ce que l''orateur propose.

**Aucun argument.** Pas une raison, pas un fait, pas un chiffre.

**Les tics envahissent.** J''ai compté : quatre « euh », trois « voilà », deux
« du coup », deux « quoi », deux « enfin », deux « en fait ». Quinze mots vides
sur une intervention de soixante mots. Un quart.

**La conclusion s''excuse.** « C''est tout ce que je voulais dire » annule ce qui
précède, et « merci » n''est pas une chute.

**Et une faute de langue orale** : « que les gens ils fassent attention » — le
pronom « ils » redouble le sujet « les gens ». C''est du registre familier ; à
l''oral soigné, on dit « que les gens fassent attention ».

*La réécriture, en deux minutes de parole.*

> « Dans notre quartier, le camion de la commune passe une fois par mois.
>
> *(silence de deux secondes)*
>
> Je pense que nous devons écrire à la mairie, et non ramasser nous-mêmes. Et
> je dis cela pour deux raisons.
>
> D''abord, parce que nous avons déjà payé pour ce service. Nos parents paient
> des taxes, et le ramassage des ordures en fait partie. Le faire nous-mêmes,
> c''est payer deux fois.
>
> Ensuite — et c''est le plus important — parce que si nous le faisons, personne
> ne remarquera jamais que le camion ne passe pas. Le bac qu''on a retiré de
> notre carrefour en janvier n''a jamais été remplacé. Pourquoi l''aurait-on
> remplacé ? Le quartier s''était organisé sans lui.
>
> *(silence)*
>
> Nous pouvons nettoyer la rue. Nous ne pouvons pas nettoyer la rue chaque mois
> pendant dix ans. »

*Compare. Le second texte est à peine plus long, et il n''emploie aucun mot
savant. Mais il a une accroche factuelle, une position donnée en quinze
secondes, deux arguments annoncés et séparés, un exemple concret — le bac de
janvier —, et une chute préparée.*

*Et il ne contient pas un seul « euh ». Non parce que l''orateur n''hésite jamais,
mais parce qu''il a appris à remplacer l''hésitation par un silence. C''est le même
temps, et ce n''est pas le même effet.*
', NULL, 26),
    (v_chapitre_id, 'Figure : l''échelle de l''opposition courtoise', 2, 'figure', '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 580 280" width="580" height="280">
<rect width="580" height="280" fill="#ffffff"/>
<text x="290" y="24" text-anchor="middle" font-size="14" font-weight="700" fill="#0f172a">Contredire sans blesser : l&apos;échelle de l&apos;opposition</text>
<text x="290" y="42" text-anchor="middle" font-size="10" fill="#64748b">Le même désaccord, du plus courtois au plus brutal.</text>

<line x1="60" y1="70" x2="60" y2="246" stroke="#cbd5e1" stroke-width="2"/>
<polygon points="60,64 55,76 65,76" fill="#15803d"/>
<polygon points="60,252 55,240 65,240" fill="#b91c1c"/>

<rect x="80" y="62" width="480" height="30" rx="4" fill="#dcfce7" stroke="#15803d"/>
<text x="96" y="81" font-size="9" fill="#14532d">« Je comprends ton point de vue, et pourtant il me semble que… »</text>
<text x="548" y="81" text-anchor="end" font-size="8" font-weight="700" fill="#15803d">courtois</text>

<rect x="80" y="98" width="480" height="30" rx="4" fill="#dcfce7" stroke="#4ade80"/>
<text x="96" y="117" font-size="9" fill="#166534">« Tu as raison sur un point, mais je ne te suis pas sur… »</text>

<rect x="80" y="134" width="480" height="30" rx="4" fill="#f1f5f9" stroke="#64748b"/>
<text x="96" y="153" font-size="9" fill="#334155">« Je ne suis pas d&apos;accord, et voici pourquoi. »</text>
<text x="548" y="153" text-anchor="end" font-size="8" font-weight="700" fill="#475569">neutre</text>

<rect x="80" y="170" width="480" height="30" rx="4" fill="#fed7aa" stroke="#ea580c"/>
<text x="96" y="189" font-size="9" fill="#9a3412">« C&apos;est faux. »</text>

<rect x="80" y="206" width="480" height="30" rx="4" fill="#fee2e2" stroke="#b91c1c"/>
<text x="96" y="225" font-size="9" fill="#7f1d1d">« N&apos;importe quoi. Tu n&apos;y connais rien. »</text>
<text x="548" y="225" text-anchor="end" font-size="8" font-weight="700" fill="#b91c1c">blessant</text>

<rect x="80" y="246" width="480" height="26" rx="4" fill="#fef3c7" stroke="#ca8a04" stroke-width="1.4"/>
<text x="320" y="264" text-anchor="middle" font-size="9" font-weight="700" fill="#78350f">Plus bas on descend, moins on a de chances d&apos;être écouté.</text>
</svg>', NULL, 5),
    (v_chapitre_id, 'Simulation : construire son intervention', 3, 'interactif', '{
  "widget": "intervention-orale",
  "consigne": "Un sujet de débat s''affiche, et tu montes ton intervention en quatre blocs : accroche, position, arguments, chute. La simulation chronomètre ce que ta parole durerait et te prévient quand tu dépasses deux minutes. Elle traque aussi les tics — tu peux coller un texte et elle compte les « euh », les « du coup », les « voilà », puis te montre la proportion de mots vides. Dix sujets de citoyenneté, et un atelier final sur le silence : tu places deux pauses dans ton texte et elle te fait entendre la différence."
}', NULL, 10),
    (v_chapitre_id, 'Contredire sans blesser', 4, 'texte', '
Voici la compétence la plus utile du chapitre, et celle qui manque le plus,
chez les élèves comme chez les adultes.

### Pourquoi c''est difficile

Parce que dans un débat, deux choses se mélangent : l''**idée** et la
**personne**. Celui qui entend « tu as tort » entend souvent « tu es bête ».

Tout l''art consiste à séparer les deux. On attaque l''idée, jamais celui qui la
porte.

> ✗ « Tu n''y connais rien. »
> ✓ « Je crois que cet argument ne tient pas, et voici pourquoi. »

La première phrase ferme la discussion. La seconde l''ouvre.

### L''échelle de l''opposition

Comme pour les sentiments au chapitre 13, il y a une échelle, et il faut savoir
où l''on se place.

> **« Je comprends ton point de vue, et pourtant il me semble que… »**
> le plus courtois : je reconnais avant de m''opposer
>
> **« Tu as raison sur un point, mais je ne te suis pas sur… »**
> courtois, et précis : je distingue ce que j''accepte de ce que je refuse
>
> **« Je ne suis pas d''accord, et voici pourquoi. »**
> neutre, direct, parfaitement acceptable
>
> **« C''est faux. »**
> brutal : j''ai peut-être raison, mais je ne serai pas écouté
>
> **« N''importe quoi. Tu n''y connais rien. »**
> blessant : la discussion est finie, et j''ai perdu même si j''avais raison

**Règle à retenir : plus on descend l''échelle, moins on a de chances d''être
écouté.** Ce n''est pas une question de politesse mais d''efficacité. Celui qu''on
humilie ne change jamais d''avis : il se défend.

### Les formules à connaître

Apprends-en quelques-unes par cœur. Elles te sortiront d''embarras.

**Pour reconnaître avant de contredire :**
> « Je te rejoins sur… mais… »
> « C''est vrai dans ce cas précis ; en revanche… »
> « Il y a du vrai là-dedans, seulement… »

**Pour nuancer sans affronter :**
> « Ce n''est pas si simple, parce que… »
> « Tout dépend de ce qu''on entend par… »
> « Je le verrais autrement : … »

**Pour demander une preuve, sans accuser :**
> « Sur quoi t''appuies-tu pour dire cela ? »
> « As-tu un exemple ? »

C''est la formule la plus puissante du débat, et la plus courtoise. Elle ne nie
rien ; elle demande. Et bien souvent, l''autre découvre lui-même qu''il n''a pas
d''exemple.

**Pour reformuler avant de répondre :**
> « Si je comprends bien, tu dis que… C''est bien cela ? »

Celle-ci vaut de l''or. Elle oblige à écouter vraiment, elle montre le respect,
et elle évite de combattre une position que l''autre n''a jamais défendue.

### L''homme de paille : l''erreur à ne pas commettre

C''est le nom d''un défaut de raisonnement très répandu. Il consiste à
**déformer la position de l''adversaire** pour la réfuter plus facilement.

> *Il dit* : « Je pense qu''il faut encadrer les motos-taxis. »
> *Tu réponds* : « Donc tu veux mettre tous les jeunes au chômage ! »

Ce n''est pas ce qu''il a dit. Tu as construit une position caricaturale — un
homme de paille — et tu l''as abattue. C''est facile, et cela ne convainc personne
d''honnête.

Le remède est la reformulation : avant de répondre, dis ce que l''autre a dit,
et demande-lui si c''est bien cela.

### Et quand c''est toi qui as tort ?

Cela arrivera, et c''est une excellente nouvelle.

> « Tu as raison, je n''avais pas pensé à cela. »

Cette phrase te coûte dix secondes et te rapporte beaucoup : elle montre que tu
discutes pour comprendre, pas pour gagner. Dans un débat scolaire comme dans une
réunion, celui qui sait la dire est écouté davantage, pas moins.

---

**Exercice corrigé**

*Réécrire ces quatre répliques en remontant l''échelle de l''opposition, sans
changer l''idée.*

*1. « C''est complètement faux, les motos ne polluent pas plus que les voitures. »*
*2. « Tu dis ça parce que tu n''habites pas le quartier. »*
*3. « N''importe quoi, il n''y a jamais eu d''inondation à cet endroit. »*
*4. « Donc d''après toi il faut laisser mourir les commerçants. »*

**Correction.**

*1.* L''idée est bonne — comparer la pollution des motos et des voitures — mais
« complètement faux » ferme la porte.

> « Je ne suis pas sûr de te suivre sur ce point. À nombre de trajets égal, une
> moto consomme moins qu''une voiture ; sur quoi t''appuies-tu pour dire le
> contraire ? »

*Note que j''ai ajouté une demande de preuve. Elle est plus forte qu''une
contradiction, parce qu''elle oblige l''autre à chercher, et qu''elle ne l''humilie
pas.*

*2.* Celle-ci ne s''attaque pas à l''idée mais à **la personne** : c''est l''erreur
de principe du débat. Que l''orateur habite ou non le quartier ne rend son
argument ni vrai ni faux.

> « C''est peut-être différent vu du quartier. Je peux te dire ce qu''on y
> observe, et tu me diras si cela change quelque chose à ton raisonnement. »

*J''ai gardé l''idée utile — l''expérience du quartier apporte quelque chose — en
la transformant en apport plutôt qu''en disqualification.*

*3.* « N''importe quoi » est le dernier barreau de l''échelle. Et l''affirmation
qui suit est vérifiable : c''est donc un cas où la demande de précision est
imparable.

> « Là je crois que nous n''avons pas les mêmes souvenirs. Moi je me rappelle
> septembre 2022 ; de quelle période parles-tu ? »

*4.* C''est un **homme de paille** : l''interlocuteur n''a jamais dit qu''il fallait
laisser mourir les commerçants. Le remède est la reformulation.

> « Si je comprends bien, tu proposes d''interdire les sacs plastiques même
> lorsque les petits commerçants n''ont pas d''autre solution. C''est bien cela ?
> Parce que si c''est cela, c''est ce point-là qui me gêne. »

*Observe ce que fait cette réplique : elle demande confirmation, elle désigne
précisément le point de désaccord, et elle laisse à l''autre la possibilité de
dire « non, ce n''est pas ce que je voulais dire ». Dans la moitié des cas, le
désaccord se dissout à cet instant — parce qu''il venait d''un malentendu.*
', NULL, 26),
    (v_chapitre_id, 'Simulation : remonter l''échelle', 5, 'interactif', '{
  "widget": "contredire-poliment",
  "consigne": "Une réplique brutale s''affiche, et tu dois la réécrire en gardant l''idée. La simulation place ta version sur l''échelle à cinq barreaux et te dit ce qu''elle coûte ou rapporte en chances d''être écouté. Elle repère aussi les deux fautes de principe : l''attaque de la personne, et l''homme de paille — et dans ce dernier cas, elle te montre côte à côte ce que l''autre a dit et ce que tu lui as fait dire. Vingt répliques, et un atelier final où tu dois dire « tu as raison, je n''y avais pas pensé » au bon moment."
}', NULL, 10),
    (v_chapitre_id, 'Le débat réglé : écouter autant que parler', 6, 'texte', '
Dernière leçon de l''année sur l''oral. Nous passons de l''intervention solitaire
au **débat**, c''est-à-dire à plusieurs.

### Pourquoi des règles ?

Parce que sans règles, un débat se gagne à la voix la plus forte, et celui qui a
raison se tait. Les règles ne sont pas une formalité scolaire : elles servent à
ce que le meilleur argument l''emporte, et non le plus bruyant.

### Les rôles

Un débat réglé compte quatre rôles. En classe, on peut les tenir à tour de rôle
d''une séance à l''autre.

**Le modérateur** distribue la parole, surveille le temps, et ne donne jamais
son avis. C''est le rôle le plus difficile, et le plus formateur.

**Les intervenants** défendent une position. On les répartit parfois sur une
position qui n''est pas la leur — exercice excellent, et nous y revenons.

**Le secrétaire** note les arguments échangés, pas les noms. À la fin, il lit ce
qui a été dit.

**Le public** écoute et pose des questions à la fin.

### Les règles de parole

Quatre, et elles suffisent.

**1. On demande la parole, on ne la prend pas.** Lever la main, attendre.

**2. Le temps est égal.** Deux minutes par intervention, et le modérateur le
tient. C''est ce qui empêche les bavards d''occuper le terrain.

**3. On ne coupe jamais.** Si tu as une objection, note-la. Elle sera meilleure
dans trois minutes que criée maintenant.

**4. On reformule avant de répondre.** « Si je comprends bien, tu dis que… »
C''est la règle qui change tout : elle oblige à écouter.

### Écouter est un travail

Voici ce que personne ne dit aux élèves : dans un débat, **la plupart des gens
n''écoutent pas, ils attendent leur tour**. Ils préparent leur phrase pendant que
l''autre parle, et ils répondent à ce qu''ils avaient prévu d''entendre.

Comment faire autrement ? Trois gestes.

**Note l''argument de l''autre en trois mots** pendant qu''il parle. Cela t''occupe
les mains et te force à comprendre avant de juger.

**Repère le point exact du désaccord.** Souvent, vous êtes d''accord sur neuf
dixièmes, et le débat porte sur un détail. Le nommer fait gagner dix minutes.

**Cherche ce qu''il y a de vrai dans ce qu''il dit.** Il y en a presque toujours
quelque chose. Le trouver, et le dire, est ce qui te donnera le plus d''autorité
dans la salle.

### L''exercice de la position inverse

C''est le plus utile de tous, et je te conseille de le pratiquer en classe.

**On tire au sort la position que l''on devra défendre, y compris celle à
laquelle on ne croit pas.**

Pourquoi ? Pour trois raisons.

Cela oblige à **chercher les meilleurs arguments de l''adversaire**, et non sa
caricature. On découvre alors souvent qu''ils sont plus solides qu''on ne croyait.

Cela apprend à **séparer l''argument de la croyance**. Un bon argument reste bon
même s''il sert une cause que je n''aime pas.

Et cela rend **modeste**. Celui qui a défendu avec conviction une position pour
en changer à la séance suivante comprend quelque chose d''important sur la force
des mots.

### Clore un débat

Un débat ne se termine pas quand tout le monde est d''accord — cela n''arrive
presque jamais — mais quand on sait **exactement sur quoi on n''est pas
d''accord**.

Le modérateur, ou le secrétaire, conclut ainsi :

> « Nous sommes d''accord sur le fait que les ordures ne sont pas ramassées assez
> souvent, et sur le fait que la commune en a la charge. Le désaccord porte sur
> un seul point : faut-il ramasser soi-même en attendant, ou s''y refuser pour
> obliger la commune à agir ? C''est là-dessus qu''il faudrait continuer. »

C''est un bon débat. Personne n''a changé d''avis, et tout le monde a avancé.

---

**Exercice corrigé**

*Lire cette transcription de débat et relever les manquements aux règles, puis
rédiger la conclusion que le modérateur aurait dû prononcer.*

> **A** — Il faut interdire les motos-taxis en centre-ville, elles causent trop
> d''accidents.
> **B** — *(coupant)* Et les milliers de jeunes qui en vivent, tu y penses ?
> **A** — Donc pour toi la vie des gens ne compte pas.
> **B** — N''importe quoi. Tu parles comme quelqu''un qui a une voiture.
> **C** — Moi je voudrais dire que dans mon quartier il n''y a pas de bus.
> **A** — *(coupant)* On n''est pas là pour parler de ton quartier.
> **Modérateur** — Moi je pense que B a raison.

**Correction.**

*Les manquements.*

**B coupe A.** Règle 3 enfreinte. L''objection de B était bonne ; elle aurait été
meilleure attendue.

**A construit un homme de paille.** « Donc pour toi la vie des gens ne compte
pas » : B n''a jamais dit cela. Il a dit que des jeunes vivent de cette activité.

**B attaque la personne.** « Tu parles comme quelqu''un qui a une voiture » : que
A ait une voiture ne rend son argument ni vrai ni faux. Et « n''importe quoi »
est le dernier barreau de l''échelle.

**A coupe C, et disqualifie son apport.** Or l''intervention de C était la plus
utile du débat : elle introduisait le vrai problème, l''absence de transport
public. A l''a écartée parce qu''elle venait d''un cas particulier, alors qu''un cas
particulier est précisément un exemple.

**Le modérateur donne son avis.** C''est la faute la plus grave, parce qu''elle
ruine le rôle. Un modérateur qui prend parti ne peut plus distribuer la parole
équitablement, et plus personne ne lui fait confiance.

*La conclusion que le modérateur aurait dû prononcer.*

> « Faisons le point. Vous êtes d''accord sur deux choses : les motos-taxis
> causent des accidents, et elles font vivre beaucoup de jeunes. Personne n''a
> contesté ni l''un ni l''autre.
>
> Le désaccord porte sur ce qu''il faut en conclure. A considère que le danger
> justifie l''interdiction ; B considère que l''interdiction priverait des
> familles de leur revenu sans rien proposer à la place.
>
> Et C a introduit un élément que nous n''avons pas traité : s''il n''y a pas de
> bus dans les quartiers périphériques, interdire les motos revient à y
> supprimer le transport. C''est peut-être là que le débat devrait reprendre la
> prochaine fois : non pas « faut-il interdire », mais « que faut-il mettre à la
> place, et dans quel ordre ». »

*Observe ce que fait cette conclusion. Elle nomme les accords, elle nomme
précisément le désaccord, elle repêche l''intervention qu''on avait écartée, et
elle propose la question suivante. Elle ne dit à aucun moment qui a raison.*

*C''est exactement ce qu''on attend d''un modérateur — et, plus tard, de celui qui
dirige une réunion.*
', NULL, 26),
    (v_chapitre_id, 'Simulation : le débat réglé', 7, 'interactif', '{
  "widget": "debat-regle",
  "consigne": "Tu tiens le rôle de modérateur d''un débat animé, avec un chronomètre par intervenant et un bouton pour distribuer la parole. Les intervenants se coupent, attaquent la personne, construisent des hommes de paille — et tu dois les reprendre au bon moment, ni trop tôt ni trop tard. Un compteur de temps de parole te montre en direct si l''un occupe le terrain. À la fin, tu rédiges la conclusion, et la simulation vérifie qu''elle nomme les accords, qu''elle nomme le désaccord exact, et qu''elle ne dit pas qui a raison. Cinq débats sur des sujets de citoyenneté, et un mode « position inverse » où le sujet qu''on te confie n''est pas celui que tu aurais choisi."
}', NULL, 10),
    (v_chapitre_id, 'Quiz du chapitre 16', 8, 'quiz', '{
  "titre": "Vérifie que tu as compris",
  "questions": [
    {
      "question": "Pourquoi faut-il annoncer son plan à l''oral, alors qu''on ne le fait pas à l''écrit ?",
      "choix": [
        "Par politesse",
        "Parce que l''auditeur ne voit pas les paragraphes et ne peut pas revenir en arrière : « je vais dire trois choses » tient lieu de paragraphe",
        "Pour gagner du temps",
        "Ce n''est pas nécessaire"
      ],
      "bonne": 1,
      "explication": "Ces formules paraissent lourdes à l''écrit. À l''oral, elles sont indispensables. De même, la répétition, faute à l''écrit, fait retenir à l''oral."
    },
    {
      "question": "À quel moment faut-il donner sa position dans une intervention orale ?",
      "choix": [
        "À la fin, pour ménager l''effet",
        "Tout de suite, dans les quinze premières secondes : sinon l''auditeur écoute sans savoir quoi écouter",
        "Au milieu",
        "On ne la donne pas"
      ],
      "bonne": 1,
      "explication": "La structure est : accroche, position, deux ou trois arguments annoncés, chute préparée. Jamais la position à la fin."
    },
    {
      "question": "Quel est l''effet de deux secondes de silence avant de commencer ?",
      "choix": [
        "On passe pour hésitant",
        "De l''intérieur elles paraissent une éternité ; de l''extérieur elles passent inaperçues, ou donnent du poids",
        "Le public part",
        "Aucun"
      ],
      "bonne": 1,
      "explication": "C''est le réglage le plus difficile et le plus efficace. Et apprendre à remplacer l''hésitation par un silence supprime les « euh » : même temps, effet opposé."
    },
    {
      "question": "Pourquoi ne faut-il pas descendre au bas de l''échelle de l''opposition ?",
      "choix": [
        "Par politesse seulement",
        "Par efficacité : celui qu''on humilie ne change jamais d''avis, il se défend — on a raison et on n''est pas écouté",
        "Parce que c''est interdit",
        "Pour ne pas perdre de temps"
      ],
      "bonne": 1,
      "explication": "« C''est faux » et « n''importe quoi » ferment la discussion. « Je crois que cet argument ne tient pas, et voici pourquoi » l''ouvre."
    },
    {
      "question": "Qu''est-ce qu''un « homme de paille » ?",
      "choix": [
        "Un argument faible",
        "Une déformation de la position de l''adversaire, qu''on caricature pour la réfuter plus facilement",
        "Un témoignage inventé",
        "Un orateur timide"
      ],
      "bonne": 1,
      "explication": "« Je pense qu''il faut encadrer les motos » / « Donc tu veux mettre tous les jeunes au chômage ». Le remède est la reformulation avant de répondre."
    },
    {
      "question": "Quelle est la formule la plus puissante et la plus courtoise du débat ?",
      "choix": [
        "« Tu as tort »",
        "« Sur quoi t''appuies-tu pour dire cela ? » — elle ne nie rien, elle demande, et souvent l''autre découvre qu''il n''a pas d''exemple",
        "« Je ne suis pas d''accord »",
        "« Passons »"
      ],
      "bonne": 1,
      "explication": "À égalité avec la reformulation : « si je comprends bien, tu dis que… c''est bien cela ? ». Dans la moitié des cas, le désaccord se dissout à cet instant."
    },
    {
      "question": "Quand un débat est-il réussi ?",
      "choix": [
        "Quand tout le monde est d''accord",
        "Quand on sait exactement sur quoi on n''est pas d''accord : personne n''a changé d''avis, et tout le monde a avancé",
        "Quand le plus fort a gagné",
        "Quand il est court"
      ],
      "bonne": 1,
      "explication": "Le modérateur conclut en nommant les accords, puis le point exact du désaccord — et il ne dit jamais qui a raison. C''est ce qu''on attend plus tard de celui qui dirige une réunion."
    }
  ]
}', NULL, 5);

  RAISE NOTICE '8 leçons ajoutées au chapitre 16, Défendre un point de vue, contredire, s''opposer.';
END $fr3$;
