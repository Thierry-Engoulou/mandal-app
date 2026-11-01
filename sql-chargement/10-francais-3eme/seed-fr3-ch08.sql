-- ---------------------------------------------------------------------------
-- M'Andal — Français, classe de 3ème
-- Chapitre 8 : Raconter une expérience et rendre compte d'un film
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
  WHERE programme_id = v_programme_id AND ordre = 8;

  IF v_chapitre_id IS NULL THEN
    INSERT INTO public.chapitres (programme_id, titre, ordre, niveau)
    VALUES (v_programme_id, 'Raconter une expérience et rendre compte d''un film', 8, 'Module 1 : La vie familiale et socioculturelle')
    RETURNING id INTO v_chapitre_id;
    RAISE NOTICE 'Chapitre 8 créé.';
  END IF;

  -- Les leçons. Si le chapitre en a déjà, on passe son tour sans rien toucher.
  SELECT count(*) INTO v_deja FROM public.concepts WHERE chapitre_id = v_chapitre_id;
  IF v_deja > 0 THEN
    RAISE NOTICE 'Le chapitre 8 a déjà ses % leçons, je n''y touche pas.', v_deja;
    RETURN;
  END IF;

  INSERT INTO public.concepts
    (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes) VALUES
    (v_chapitre_id, 'Raconter une expérience personnelle à l''oral', 1, 'texte', '
L''oral est noté. Il l''est en classe, il l''est dans l''examen oral de certains
établissements, et surtout il te servira toute ta vie. Pourtant personne ne
l''apprend vraiment, et c''est dommage, car il s''apprend vite.

### Ce qui change entre l''écrit et l''oral

À l''écrit, le lecteur peut relire. À l''oral, l''auditeur n''entend qu''une fois.
Tout découle de là.

**Les phrases doivent être plus courtes.** Une phrase de cinq lignes se lit ; à
l''oral, elle se perd.

**La structure doit être annoncée.** À l''écrit, le lecteur voit les paragraphes.
À l''oral, il faut le lui dire : « d''abord », « ensuite », « et c''est alors
que… ».

**Les répétitions ne sont pas interdites.** Reprendre un mot clé aide l''auditeur
à suivre. À l''écrit, on l''éviterait.

### La structure d''un récit oral

Quatre temps, et ils tiennent en deux minutes.

**L''accroche.** Une phrase qui donne envie, et qui situe. Ne commence jamais par
« Alors, je vais vous raconter une histoire qui m''est arrivée ». Commence par
l''histoire.

> Il y a deux ans, j''ai passé une nuit entière enfermé dans la cour de l''école.

**La situation.** Où, quand, qui. Trois phrases, pas plus.

**Le récit.** Les actions, dans l''ordre, avec les mots de liaison qui guident :
*d''abord*, *puis*, *c''est alors que*, *finalement*.

**La chute.** Une phrase qui ferme, et qui dit pourquoi tu as raconté cela.
C''est ce qu''on retient.

### Les cinq tics qui gâchent un oral

Ils sont faciles à nommer, et donc faciles à corriger.

**Le « euh ».** Il vient quand on cherche ses mots. Le remède n''est pas de parler
plus vite, c''est de **se taire** : un silence d''une seconde passe inaperçu, un
« euh » s''entend.

**Le « voilà » à chaque fin de phrase.** Il ne veut rien dire et s''installe sans
qu''on s''en aperçoive.

**Le « en fait ».** Même chose.

**Le débit trop rapide.** C''est le signe du trac, et il rend inaudible. Respire
avant de commencer, et fais une pause après chaque phrase importante.

**Le regard au sol ou au plafond.** Regarde ton auditoire. Pas une personne
fixement — c''est gênant pour elle — mais le groupe, en balayant.

### La règle des trois lenteurs

Quand tu es ému ou pressé, applique mécaniquement :

**Parle plus lentement** que tu n''en as envie.
**Fais des pauses plus longues** que tu ne crois nécessaire.
**Articule plus** que d''ordinaire.

Ce qui te paraîtra exagéré de l''intérieur paraîtra juste de l''extérieur. Tous
les orateurs le disent.

---

**Exercice corrigé**

*Transformer ce début d''exposé oral, qui est maladroit, et dire ce qui a été
corrigé.*

> *« Alors euh, bonjour, donc je vais vous parler aujourd''hui d''une expérience
> personnelle que j''ai vécue il y a assez longtemps maintenant, enfin il y a
> deux ans à peu près, et c''était pendant les vacances, en fait c''était pas
> vraiment les vacances, c''était juste après les examens, voilà, et donc je
> voulais vous raconter comment je me suis retrouvé, enfin comment ça s''est
> passé… »*

**Correction.**

> *« Il y a deux ans, juste après les examens, j''ai passé une nuit entière
> enfermé dans la cour de mon école.*
>
> *C''était un vendredi. J''étais resté pour finir de ranger la bibliothèque avec
> deux camarades. Ils sont partis avant moi.*
>
> *Je vais vous raconter d''abord comment je me suis retrouvé seul, ensuite ce que
> j''ai fait pendant cette nuit, et enfin ce que j''en ai gardé. »*

*Ce qui a été corrigé, point par point.*

**Les tics ont disparu** : plus de « euh », plus de « en fait », plus de
« voilà », plus de « donc ». À eux seuls ils occupaient un quart du texte de
départ.

**L''annonce molle a été supprimée.** « Je vais vous parler d''une expérience
personnelle » n''apprend rien : tout le monde a compris que c''est un exposé. La
nouvelle version commence par l''événement lui-même, et l''auditoire est pris dès
la première phrase.

**Les hésitations sur la date ont été tranchées.** « Assez longtemps, enfin deux
ans à peu près » devient « il y a deux ans ». À l''oral, l''approximation affichée
fait douter de tout le reste. Décide, et dis.

**Les phrases ont été raccourcies.** Le texte de départ était une seule phrase
de dix lignes. Le nouveau en compte six, dont aucune ne dépasse deux lignes.

**Le plan est annoncé à la fin de l''introduction**, en trois temps. L''auditeur
sait désormais où on l''emmène, et il peut suivre.

*Une remarque pour finir : le texte corrigé est deux fois plus court et dit deux
fois plus de choses. C''est le signe d''un oral préparé. Et préparer un oral ne
veut pas dire l''écrire mot à mot pour le lire : cela veut dire noter sur une
fiche l''accroche, les trois étapes et la chute, puis parler.*
', NULL, 26),
    (v_chapitre_id, 'Figure : le compte rendu oral en cinq moments', 2, 'figure', '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 580 300" width="580" height="300">
<rect width="580" height="300" fill="#ffffff"/>
<text x="290" y="24" text-anchor="middle" font-size="14" font-weight="700" fill="#0f172a">Le compte rendu oral : cinq moments, cinq minutes</text>

<rect x="20" y="42" width="540" height="34" rx="5" fill="#ede9fe" stroke="#7c3aed" stroke-width="1.4"/>
<text x="32" y="63" font-size="10" font-weight="700" fill="#5b21b6">1. FICHE TECHNIQUE</text>
<text x="200" y="63" font-size="9" fill="#6d28d9">titre · réalisateur · année · pays · genre · durée</text>
<text x="548" y="63" text-anchor="end" font-size="9" font-weight="700" fill="#5b21b6">30 s</text>

<rect x="20" y="82" width="540" height="34" rx="5" fill="#dbeafe" stroke="#2563eb" stroke-width="1.4"/>
<text x="32" y="103" font-size="10" font-weight="700" fill="#1e3a8a">2. LE SUJET</text>
<text x="200" y="103" font-size="9" fill="#1e40af">la situation, le problème — et on s&apos;arrête avant la fin</text>
<text x="548" y="103" text-anchor="end" font-size="9" font-weight="700" fill="#1e3a8a">1 min</text>

<rect x="20" y="122" width="540" height="34" rx="5" fill="#dcfce7" stroke="#15803d" stroke-width="1.4"/>
<text x="32" y="143" font-size="10" font-weight="700" fill="#14532d">3. CE QUE LE FILM MONTRE</text>
<text x="240" y="143" font-size="9" fill="#166534">les thèmes, le milieu, ce qu&apos;il dit de la société</text>
<text x="548" y="143" text-anchor="end" font-size="9" font-weight="700" fill="#14532d">1 min</text>

<rect x="20" y="162" width="540" height="34" rx="5" fill="#fef3c7" stroke="#ca8a04" stroke-width="1.4"/>
<text x="32" y="183" font-size="10" font-weight="700" fill="#78350f">4. COMMENT IL LE MONTRE</text>
<text x="240" y="183" font-size="9" fill="#92400e">images · musique · rythme · jeu · langue employée</text>
<text x="548" y="183" text-anchor="end" font-size="9" font-weight="700" fill="#78350f">1 min</text>

<rect x="20" y="202" width="540" height="34" rx="5" fill="#fce7f3" stroke="#be185d" stroke-width="1.4"/>
<text x="32" y="223" font-size="10" font-weight="700" fill="#831843">5. TON AVIS, JUSTIFIÉ</text>
<text x="240" y="223" font-size="9" fill="#9d174d">deux « plus » précis, et une réserve honnête</text>
<text x="548" y="223" text-anchor="end" font-size="9" font-weight="700" fill="#831843">1 min</text>

<rect x="20" y="248" width="540" height="44" rx="5" fill="#fee2e2" stroke="#b91c1c" stroke-width="1.4"/>
<text x="32" y="266" font-size="10" font-weight="700" fill="#7f1d1d">LES CINQ TICS QUI GÂCHENT TOUT</text>
<text x="32" y="284" font-size="9" fill="#991b1b">« euh » · « voilà » · « en fait » · le débit trop rapide · le regard au sol</text>
<text x="548" y="284" text-anchor="end" font-size="9" font-style="italic" fill="#7f1d1d">le remède au « euh » : se taire</text>
</svg>', NULL, 5),
    (v_chapitre_id, 'Simulation : l''atelier de l''accroche', 3, 'interactif', '{
  "widget": "raconter-oral",
  "consigne": "On te donne une expérience à raconter, et six accroches possibles : celle qui annonce qu''on va raconter, celle qui s''excuse, celle qui hésite sur la date, et trois qui entrent directement dans l''histoire. Tu choisis, et la simulation te montre la réaction d''un auditoire — l''attention monte ou décroche. Tu construis ensuite le reste : la situation en trois phrases, l''annonce du plan, puis la chute. Un dernier volet te fait chasser les cinq tics dans un exposé transcrit, et compte combien de secondes ils t''ont fait perdre."
}', NULL, 10),
    (v_chapitre_id, 'Le compte rendu oral d''un film', 4, 'texte', '
Le programme te demande explicitement de savoir rendre compte oralement d''un
film que tu as vu. C''est un exercice précis, avec une méthode, et il revient
chaque année.

### Ce qu''un compte rendu n''est pas

Ce n''est pas un **résumé complet**. Si tu racontes tout, y compris la fin, ton
auditoire n''a plus aucune raison de voir le film, et tu as manqué ton but.

Ce n''est pas non plus un **avis seul**. « C''était bien, j''ai aimé » n''apprend
rien à personne.

Un compte rendu **informe** et **donne envie**, dans cet ordre.

### Les cinq moments

**1. La fiche technique.** Le titre, le réalisateur, l''année, le pays, le genre,
la durée. Quatre phrases maximum. C''est l''état civil du film.

> *Quartier Mozart*, de Jean-Pierre Bekolo, Cameroun, 1992. Une comédie d''un peu
> plus d''une heure, tournée à Yaoundé.

**2. Le sujet, sans la fin.** De quoi parle le film ? Présente la situation de
départ et le problème, et **arrête-toi avant le dénouement**.

Une formule utile : « Le film raconte comment… » Elle t''oblige à dire le
mouvement sans dire l''issue.

**3. Ce que le film montre.** Les thèmes, le milieu représenté, ce que le film
dit de la société. C''est la partie qui distingue un compte rendu d''un bavardage.

**4. Comment il le montre.** Deux ou trois remarques sur la manière : les
images, la musique, le rythme, le jeu des acteurs, la langue employée. Tu n''as
pas besoin d''être spécialiste ; tu as besoin d''avoir remarqué quelque chose.

**5. Ton avis, justifié.** Pas « j''ai aimé », mais « j''ai aimé **parce que** ».
Et aie le courage d''une réserve : un compte rendu entièrement élogieux est moins
crédible qu''un compte rendu nuancé.

### Le vocabulaire du cinéma, en avant-goût

Tu l''étudieras au module 5, mais quelques mots te serviront dès maintenant, et
ils se remarquent.

Le **réalisateur** fait le film ; le **producteur** le finance. Ne les confonds
pas.

Un **plan** est un morceau de film tourné sans couper. Une **séquence** est un
ensemble de plans qui forment une scène.

Un **gros plan** montre un visage ; un **plan d''ensemble** montre le décor et
les personnages dedans.

La **bande originale** est la musique composée pour le film.

Le **scénario** est l''histoire écrite avant le tournage ; les **dialogues** en
sont les paroles.

### Durée et support

Un compte rendu oral se tient en **trois à cinq minutes**. Au-delà, l''attention
tombe.

Prépare une **fiche**, pas un texte. Sur la fiche : les cinq moments, chacun en
trois mots, plus les noms propres et les dates, qui sont les seules choses qu''on
oublie vraiment.

Ne lis jamais. Un compte rendu lu s''entend dès la troisième phrase, et il ennuie.

---

**Exercice corrigé**

*Rédiger la fiche de préparation d''un compte rendu oral, pour un film que tu as
vu. On prendra ici un film comme exemple de méthode.*

**Correction.**

*Voici à quoi doit ressembler la fiche. Remarque qu''elle ne contient aucune
phrase rédigée, sauf l''accroche et la chute.*

> **ACCROCHE** *(la seule phrase écrite en entier)*
> « Un film où l''on rit beaucoup et qui, pourtant, parle des rapports entre les
> hommes et les femmes dans un quartier de Yaoundé. »
>
> **1. FICHE TECHNIQUE**
> Quartier Mozart — Jean-Pierre Bekolo — Cameroun — 1992 — comédie — 80 min
>
> **2. LE SUJET (sans la fin)**
> jeune fille / vœu / se transformer en homme / découvre le quartier autrement
> → m''arrêter là
>
> **3. CE QUE LE FILM MONTRE**
> les rapports hommes-femmes · la vie d''un quartier populaire · l''argent et la
> séduction · la parole des femmes entre elles
>
> **4. COMMENT**
> le mélange des langues — français, anglais, camfranglais · les personnages
> qui parlent à la caméra · le rythme rapide, beaucoup de plans courts · la
> musique omniprésente
>
> **5. AVIS**
> + l''inventivité de la langue, on entend parler comme dans la rue
> + les personnages féminins qui ont leur propre point de vue
> − le rythme peut dérouter, on perd parfois le fil
>
> **CHUTE** *(écrite en entier)*
> « C''est un film qui ne ressemble à aucun autre, et c''est pour cela qu''il faut
> le voir, même si on n''aime pas tout. »

*Pourquoi cette fiche fonctionne.*

**Elle tient sur une demi-page.** Tu peux la voir d''un coup d''œil sans la lire.

**Seules l''accroche et la chute sont rédigées.** Ce sont les deux moments où
l''on doit être précis, et les deux moments où le trac fait le plus de dégâts.
Les avoir écrits te donne un départ sûr et une arrivée sûre.

**Les noms propres et la date sont notés.** Ce sont eux qu''on oublie.

**Le point 2 porte la mention « m''arrêter là ».** C''est une note à soi-même, et
elle est utile : dans l''élan, on raconte la fin sans le vouloir.

**L''avis comporte une réserve.** Les deux « plus » sont précis — la langue, les
personnages féminins — et le « moins » est honnête. Un auditoire croit un avis
nuancé ; il se méfie d''un avis unanime.
', NULL, 26),
    (v_chapitre_id, 'Simulation : préparer le compte rendu', 5, 'interactif', '{
  "widget": "compte-rendu-film",
  "consigne": "Tu construis la fiche d''un compte rendu en cinq moments, et la simulation joue l''auditoire. Elle t''arrête quand tu racontes la fin, elle te demande « pourquoi ? » quand tu dis seulement « j''ai aimé », et elle te signale si tu as passé plus d''une minute sur la fiche technique. Un chronomètre tourne : au-delà de cinq minutes, l''attention de l''auditoire chute à vue d''œil. Le second volet te fait distinguer, dans vingt phrases, ce qui relève du résumé, de l''analyse et de l''avis — c''est le tri que les élèves ratent le plus."
}', NULL, 10),
    (v_chapitre_id, 'La voix, le corps, et le trac', 6, 'texte', '
Tu peux avoir le meilleur contenu du monde : si personne ne t''entend, il ne
servira à rien. Cette leçon porte sur ce qui, à l''oral, se joue avant les mots.

### Les quatre réglages de la voix

**Le volume.** Parle pour la personne la plus éloignée de la salle, pas pour
celle du premier rang. Si tu t''adresses au fond, tout le monde t''entend ; si tu
t''adresses au premier rang, la moitié de la salle décroche.

**Le débit.** Trop rapide, on ne suit pas ; trop lent, on s''endort. Le bon repère
est simple : tu dois pouvoir respirer normalement en parlant. Si tu manques
d''air, tu vas trop vite.

**L''articulation.** Ouvre la bouche. C''est bête, et c''est le conseil qui change
le plus de choses : la plupart des oraux inaudibles le sont par des lèvres qui
ne bougent pas assez.

**L''intonation.** Une voix qui ne monte ni ne descend endort. Monte à la
question, descends à la fin d''une affirmation, et marque ce qui compte en
ralentissant dessus.

### Le silence est un outil

Les élèves ont peur du silence et le remplissent de « euh ». C''est l''inverse
qu''il faut faire.

**Avant de commencer.** Place-toi, regarde ton auditoire, respire une fois. Deux
secondes de silence, et tout le monde se tait pour t''écouter. Si tu commences en
marchant, personne n''est prêt.

**Après une phrase importante.** Une pause d''une seconde dit à l''auditoire :
retenez celle-là.

**Quand tu cherches un mot.** Tais-toi. Le silence passe pour de la réflexion,
le « euh » pour de l''embarras.

### Le corps

**Les pieds.** Reste stable, les deux pieds au sol, légèrement écartés. Se
balancer d''un pied sur l''autre fatigue ceux qui regardent.

**Les mains.** Elles doivent être visibles et libres. Pas dans les poches, pas
croisées dans le dos, pas accrochées à une feuille qu''on froisse. Si tu ne sais
qu''en faire, tiens ta fiche d''une main et laisse l''autre libre.

**Le regard.** Balaie la salle. Trois ou quatre secondes par zone. Ne fixe
personne, et ne regarde ni tes notes ni le plafond.

### Le trac

Il ne disparaît pas, et il ne doit pas disparaître : un peu de trac rend plus
vif. Ce qu''on peut faire, c''est l''empêcher de nuire.

**Il est le plus fort juste avant**, et il tombe après les premières phrases. Le
sachant, prépare ton accroche par cœur : tu passeras le pire moment en terrain
sûr.

**Il se voit moins que tu ne crois.** Les mains qui tremblent, le cœur qui bat,
la gorge serrée : tout cela est énorme de l''intérieur et presque invisible de
l''extérieur.

**Il se combat par la respiration.** Trois respirations lentes avant de
commencer, en soufflant plus longtemps qu''en inspirant. Cela suffit à faire
baisser le rythme cardiaque.

**Et il se combat par la préparation.** Celui qui connaît ses cinq points n''a
rien à craindre : même s''il perd ses mots, il sait où il va.

---

**Exercice corrigé**

*Un camarade prépare un compte rendu oral. Voici ce qu''on observe pendant son
passage. Indique pour chaque observation ce qu''il faudrait corriger, et comment.*

*1. Il commence à parler en se dirigeant encore vers le tableau.*
*2. Il tient sa feuille à deux mains, à hauteur du visage, et lit.*
*3. On l''entend bien au premier rang, pas au fond.*
*4. Il dit « voilà » dix-sept fois en quatre minutes.*
*5. Quand il cherche un mot, il dit « euh » pendant trois secondes.*
*6. Il regarde le professeur, et uniquement le professeur.*

**Correction.**

*1.* Il commence avant que l''auditoire soit prêt, et ses premières phrases sont
perdues. **Correction :** se placer, s''arrêter, regarder la salle, respirer une
fois, puis commencer. Deux secondes de silence installent l''attention mieux que
n''importe quelle formule.

*2.* Deux fautes en une. La feuille à hauteur du visage **coupe le son** — la
voix part dans le papier — et **cache le regard**. Et lire s''entend toujours.
**Correction :** une fiche, pas un texte, tenue d''une seule main, à hauteur de
la taille. L''autre main reste libre.

*3.* Le volume est réglé sur le premier rang. **Correction :** choisir mentalement
la personne la plus éloignée et lui parler. Tout le reste de la salle entendra.

*4.* Un tic de fin de phrase, installé sans qu''il s''en aperçoive. **Correction :**
on ne supprime pas un tic en y pensant pendant qu''on parle, c''est impossible. On
le supprime en s''enregistrant une fois, en comptant les occurrences, et en
répétant deux ou trois fois : la conscience du tic suffit presque toujours à le
faire tomber.

*5.* Le « euh » de recherche. **Correction :** le remplacer par un silence. Trois
secondes de silence passent pour de la réflexion ; trois secondes de « euh »
passent pour de l''embarras. C''est exactement la même durée.

*6.* Le regard unique, et il est compréhensible — c''est le professeur qui note.
Mais cela exclut toute la classe et met le professeur mal à l''aise.
**Correction :** découper la salle en trois zones et donner trois ou quatre
secondes à chacune, en tournant.

*Le bilan vaut d''être dit : aucune de ces six corrections ne porte sur le
contenu. L''exposé de ce camarade était peut-être excellent. C''est tout l''enjeu
de cette leçon.*
', NULL, 24),
    (v_chapitre_id, 'Simulation : la console de l''orateur', 7, 'interactif', '{
  "widget": "voix-et-corps",
  "consigne": "Quatre curseurs — volume, débit, articulation, intonation — et un auditoire qui réagit devant toi. Monte le débit : les visages du fond décrochent. Baisse le volume : le dernier rang s''éteint. La simulation te montre la proportion de la salle qui suit encore, et te signale le réglage fautif. Tu règles ensuite la posture — les pieds, les mains, le regard, la hauteur de la fiche — et tu vois l''effet de chaque choix. Un dernier volet chronomètre le silence : tu découvres que deux secondes avant de commencer paraissent une éternité de l''intérieur et passent inaperçues de l''extérieur."
}', NULL, 10),
    (v_chapitre_id, 'Quiz du chapitre 8', 8, 'quiz', '{
  "titre": "Vérifie que tu as compris",
  "questions": [
    {
      "question": "Pourquoi les phrases doivent-elles être plus courtes à l''oral qu''à l''écrit ?",
      "choix": [
        "Par politesse",
        "Parce que l''auditeur n''entend qu''une fois, alors que le lecteur peut relire",
        "Pour gagner du temps",
        "Ce n''est pas vrai"
      ],
      "bonne": 1,
      "explication": "Tout découle de là : il faut aussi annoncer la structure à voix haute, et les répétitions d''un mot clé deviennent utiles au lieu d''être une faute."
    },
    {
      "question": "Par quoi ne faut-il jamais commencer un exposé ?",
      "choix": [
        "Par une question",
        "Par « je vais vous parler de… » : tout le monde a compris que c''est un exposé",
        "Par une date",
        "Par le nom de l''auteur"
      ],
      "bonne": 1,
      "explication": "Commence par l''histoire elle-même. « Il y a deux ans, j''ai passé une nuit enfermé dans la cour de l''école » prend l''auditoire dès la première phrase."
    },
    {
      "question": "Que faire quand on cherche un mot au milieu d''une phrase ?",
      "choix": [
        "Dire « euh » pour garder la parole",
        "Se taire : un silence d''une seconde passe inaperçu, un « euh » s''entend",
        "Parler plus vite",
        "Recommencer la phrase"
      ],
      "bonne": 1,
      "explication": "La durée est exactement la même. Le silence passe pour de la réflexion, le « euh » pour de l''embarras."
    },
    {
      "question": "Dans un compte rendu de film, jusqu''où faut-il raconter ?",
      "choix": [
        "Jusqu''à la fin, c''est plus clair",
        "Jusqu''au problème, en s''arrêtant avant le dénouement",
        "Seulement le titre",
        "Il ne faut rien raconter"
      ],
      "bonne": 1,
      "explication": "Un compte rendu informe ET donne envie. Si tu racontes la fin, ton auditoire n''a plus aucune raison de voir le film."
    },
    {
      "question": "Quelle différence entre le réalisateur et le producteur ?",
      "choix": [
        "Aucune",
        "Le réalisateur fait le film, le producteur le finance",
        "Le producteur écrit le scénario",
        "Le réalisateur joue dedans"
      ],
      "bonne": 1,
      "explication": "Et un plan est un morceau tourné sans couper, tandis qu''une séquence est un ensemble de plans formant une scène."
    },
    {
      "question": "Sur qui faut-il régler le volume de sa voix ?",
      "choix": [
        "Sur le premier rang",
        "Sur la personne la plus éloignée de la salle : alors tout le monde entend",
        "Sur le professeur",
        "Sur soi-même"
      ],
      "bonne": 1,
      "explication": "Si tu t''adresses au premier rang, la moitié de la salle décroche. Et ouvre la bouche : la plupart des oraux inaudibles le sont par des lèvres qui ne bougent pas."
    },
    {
      "question": "Comment faire tomber un tic de langage comme « voilà » ou « en fait » ?",
      "choix": [
        "Y penser pendant qu''on parle",
        "S''enregistrer une fois et compter les occurrences : la conscience du tic suffit presque toujours à le faire tomber",
        "Parler moins",
        "Écrire son texte en entier"
      ],
      "bonne": 1,
      "explication": "On ne supprime pas un tic en y pensant pendant qu''on parle, c''est impossible : l''attention est déjà prise par le contenu."
    }
  ]
}', NULL, 5);

  RAISE NOTICE '8 leçons ajoutées au chapitre 8, Raconter une expérience et rendre compte d''un film.';
END $fr3$;
