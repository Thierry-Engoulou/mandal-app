-- ---------------------------------------------------------------------------
-- M'Andal — Français, classe de 3ème
-- Chapitre 21 : La modalisation : vocabulaire appréciatif et dépréciatif
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
  WHERE programme_id = v_programme_id AND ordre = 21;

  IF v_chapitre_id IS NULL THEN
    INSERT INTO public.chapitres (programme_id, titre, ordre, niveau)
    VALUES (v_programme_id, 'La modalisation : vocabulaire appréciatif et dépréciatif', 21, 'Module 3 : La vie économique')
    RETURNING id INTO v_chapitre_id;
    RAISE NOTICE 'Chapitre 21 créé.';
  END IF;

  -- Les leçons. Si le chapitre en a déjà, on passe son tour sans rien toucher.
  SELECT count(*) INTO v_deja FROM public.concepts WHERE chapitre_id = v_chapitre_id;
  IF v_deja > 0 THEN
    RAISE NOTICE 'Le chapitre 21 a déjà ses % leçons, je n''y touche pas.', v_deja;
    RETURN;
  END IF;

  INSERT INTO public.concepts
    (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes) VALUES
    (v_chapitre_id, 'La modalisation : les traces de celui qui écrit', 1, 'texte', '
Ce chapitre prépare la **question 2** du BEPC — relever un champ lexical ou un
réseau de mots — et surtout une question qui revient à presque chaque session :
*relevez les marques de la subjectivité de l''auteur*.

### Un texte n''est jamais neutre

Tu le sais depuis le chapitre 13 : le choix d''un mot est déjà une prise de
position. La **modalisation** est l''étude systématique de ces choix.

**Moduler, c''est marquer son degré d''adhésion à ce qu''on dit.**

Compare ces trois phrases, qui rapportent le même fait.

> Le camion ne passe plus.
> Le camion ne passe **sans doute** plus.
> **Hélas**, le camion ne passe **évidemment** plus.

La première est **objective** : elle énonce un fait, sans rien ajouter.
La deuxième marque une **incertitude** : l''auteur n''est pas sûr.
La troisième marque à la fois une **certitude** — *évidemment* — et un
**jugement** — *hélas*.

Le fait n''a pas bougé. Ce qui a changé, c''est la position de celui qui parle.

### Deux grandes familles de modalisateurs

**Les modalisateurs de CERTITUDE** disent à quel point l''auteur croit à ce
qu''il avance.

> *certitude forte* : évidemment, assurément, sans aucun doute, il est certain
> que, bien entendu
> *certitude moyenne* : sans doute, probablement, vraisemblablement
> *incertitude* : peut-être, il semble que, il paraît que, apparemment

**Les modalisateurs de JUGEMENT** disent ce que l''auteur pense de ce qu''il
rapporte.

> *approbation* : heureusement, à juste titre, fort heureusement, à raison
> *désapprobation* : hélas, malheureusement, hélas pour nous, à tort
> *surprise* : curieusement, étrangement, bizarrement

### Pourquoi c''est utile au-delà de l''examen

Parce que repérer les modalisateurs, c''est **savoir lire un journal**.

> « Le ministre **a** inauguré le pont. » → l''inauguration est un fait.
> « Le ministre **aurait** inauguré le pont. » → le journaliste n''a pas
> vérifié.
> « Le ministre a **enfin** inauguré le pont. » → il a trop attendu.
> « Le ministre a **déjà** inauguré le pont. » → c''est allé vite.

Quatre phrases, un seul fait, quatre positions du journaliste. Un lecteur qui
ne voit pas ces mots lit sans comprendre ce qu''on lui dit.

### Ce qui n''est pas un modalisateur

Attention à l''erreur fréquente : tous les adverbes ne modalisent pas.

> Il court **vite**. → *vite* décrit la manière de courir : ce n''est pas un
> modalisateur.
> Il court **probablement**. → *probablement* dit mon degré de certitude : c''en
> est un.

**Test** : si l''adverbe porte sur **le fait lui-même**, ce n''est pas un
modalisateur. S''il porte sur **ce que le locuteur en pense**, c''en est un.

---

**Exercice corrigé**

*Classer les phrases selon le degré d''adhésion de l''auteur, du plus sûr au
moins sûr, puis relever le modalisateur de chacune.*

*1. Il est possible que le camion passe demain.*
*2. Le camion passera demain.*
*3. Il ne fait aucun doute que le camion passera demain.*
*4. Le camion passera sans doute demain.*
*5. Le camion passerait demain, dit-on.*

**Correction.**

*Du plus sûr au moins sûr :*

> **3** — « il ne fait aucun doute que » : certitude affirmée, et même
> redoublée par la négation. Modalisateur : la tournure impersonnelle
> *il ne fait aucun doute que*.
>
> **2** — aucun modalisateur. La phrase énonce un fait au futur, sans
> commentaire. C''est l''énoncé **objectif**, et c''est son absence de marque qui
> le caractérise.
>
> **4** — « sans doute » : certitude moyenne. Modalisateur : l''adverbe *sans
> doute*.
>
> *Attention au piège de cette expression : « sans doute » signifie en français
> « probablement », et non « sans aucun doute ». Elle est donc moins forte
> qu''elle n''en a l''air. Pour la certitude totale, il faut dire « sans aucun
> doute ».*
>
> **1** — « il est possible que » : simple éventualité. Modalisateur : la
> tournure impersonnelle, qui commande d''ailleurs le subjonctif — tu l''as vu au
> chapitre 20.
>
> **5** — « passerait » et « dit-on » : le conditionnel de l''information non
> confirmée, doublé d''une source anonyme. C''est le degré le plus faible : non
> seulement l''auteur n''est pas sûr, mais il signale qu''il rapporte la parole
> d''un autre.

*Remarque que le modalisateur n''est pas toujours un adverbe : c''est tantôt une
tournure impersonnelle, tantôt un mode verbal, tantôt une incise. C''est tout
l''objet de la leçon suivante.*
', NULL, 26),
    (v_chapitre_id, 'Figure : les six outils de la modalisation', 2, 'figure', '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 580 330" width="580" height="330">
<rect width="580" height="330" fill="#ffffff"/>
<text x="290" y="24" text-anchor="middle" font-size="14" font-weight="700" fill="#0f172a">Les six outils de la modalisation</text>
<text x="290" y="42" text-anchor="middle" font-size="10" fill="#64748b">Ce sont les traces que l&apos;auteur laisse de lui-même dans son texte.</text>

<rect x="20" y="56" width="268" height="60" rx="6" fill="#dbeafe" stroke="#2563eb" stroke-width="1.4"/>
<text x="36" y="74" font-size="10" font-weight="700" fill="#1e3a8a">1. LES ADVERBES</text>
<text x="36" y="90" font-size="8.5" fill="#1e40af">certainement · sans doute · peut-être</text>
<text x="36" y="102" font-size="8.5" fill="#1e40af">heureusement · hélas · à juste titre</text>
<text x="36" y="113" font-size="8" font-style="italic" fill="#475569">les plus faciles à relever</text>

<rect x="296" y="56" width="264" height="60" rx="6" fill="#dcfce7" stroke="#15803d" stroke-width="1.4"/>
<text x="312" y="74" font-size="10" font-weight="700" fill="#14532d">2. LES VERBES</text>
<text x="312" y="90" font-size="8.5" fill="#166534">croire · penser · douter · sembler</text>
<text x="312" y="102" font-size="8.5" fill="#166534">devoir · pouvoir · falloir</text>
<text x="312" y="113" font-size="8" font-style="italic" fill="#475569">« il DOIT y avoir » ≠ « il y a »</text>

<rect x="20" y="124" width="268" height="60" rx="6" fill="#fef3c7" stroke="#ca8a04" stroke-width="1.4"/>
<text x="36" y="142" font-size="10" font-weight="700" fill="#78350f">3. LES MODES ET LES TEMPS</text>
<text x="36" y="158" font-size="8.5" fill="#92400e">le conditionnel de l&apos;information</text>
<text x="36" y="170" font-size="8.5" fill="#92400e">« l&apos;accident AURAIT FAIT trois blessés »</text>
<text x="36" y="181" font-size="8" font-style="italic" fill="#475569">je rapporte, je ne garantis pas</text>

<rect x="296" y="124" width="264" height="60" rx="6" fill="#fce7f3" stroke="#be185d" stroke-width="1.4"/>
<text x="312" y="142" font-size="10" font-weight="700" fill="#831843">4. LE VOCABULAIRE ÉVALUATIF</text>
<text x="312" y="158" font-size="8.5" fill="#9d174d">appréciatif : remarquable, admirable</text>
<text x="312" y="170" font-size="8.5" fill="#9d174d">dépréciatif : médiocre, lamentable</text>
<text x="312" y="181" font-size="8" font-style="italic" fill="#475569">c&apos;est la connotation du chapitre 13</text>

<rect x="20" y="192" width="268" height="60" rx="6" fill="#ede9fe" stroke="#6d28d9" stroke-width="1.4"/>
<text x="36" y="210" font-size="10" font-weight="700" fill="#4c1d95">5. LES SUFFIXES</text>
<text x="36" y="226" font-size="8.5" fill="#5b21b6">péjoratifs : -ard, -asse, -âtre</text>
<text x="36" y="238" font-size="8.5" fill="#5b21b6">chauffard · blondasse · verdâtre</text>
<text x="36" y="249" font-size="8" fill="#5b21b6">diminutifs : -et, -ette, -illon</text>

<rect x="296" y="192" width="264" height="60" rx="6" fill="#fed7aa" stroke="#ea580c" stroke-width="1.4"/>
<text x="312" y="210" font-size="10" font-weight="700" fill="#7c2d12">6. LA TYPOGRAPHIE</text>
<text x="312" y="226" font-size="8.5" fill="#9a3412">les guillemets de distance</text>
<text x="312" y="238" font-size="8.5" fill="#9a3412">l&apos;italique · le point d&apos;exclamation</text>
<text x="312" y="249" font-size="8" font-style="italic" fill="#475569">ses « réformes » = je n&apos;y crois pas</text>

<rect x="20" y="262" width="540" height="56" rx="6" fill="#1e293b"/>
<text x="290" y="282" text-anchor="middle" font-size="10" font-weight="700" fill="#ffffff">LA QUESTION DU BEPC</text>
<text x="290" y="300" text-anchor="middle" font-size="9" fill="#cbd5e1">« Relevez les marques de la subjectivité de l&apos;auteur. »</text>
<text x="290" y="313" text-anchor="middle" font-size="9" fill="#cbd5e1">Relève, cite entre guillemets, et dis ce que chaque marque révèle.</text>
</svg>', NULL, 5),
    (v_chapitre_id, 'Simulation : relever les modalisateurs', 3, 'interactif', '{
  "widget": "relever-modalisateurs",
  "consigne": "Un texte de presse s''affiche, et tu cliques sur les mots qui marquent la position de l''auteur. La simulation te prévient quand tu relèves un adverbe qui n''en est pas un — « il court vite » ne modalise rien — et elle applique le test devant toi : ce mot porte-t-il sur le fait, ou sur ce que le locuteur en pense ? Dix textes, dont six de la presse camerounaise, et un compteur te dit combien de marques tu as manquées."
}', NULL, 10),
    (v_chapitre_id, 'Les six outils, et comment les relever', 4, 'texte', '
Les modalisateurs ne sont pas tous des adverbes. Voici les six familles, dans
l''ordre où il faut les chercher au moment du relevé.

### 1. Les adverbes et locutions adverbiales

Les plus visibles, et donc ceux par lesquels on commence.

> certainement, assurément, sans doute, probablement, peut-être, apparemment,
> heureusement, malheureusement, hélas, curieusement, à juste titre, à tort,
> évidemment, naturellement, bien entendu, en vérité

### 2. Les verbes

Deux sortes.

**Les verbes d''opinion**, quand le sujet est l''auteur lui-même ou un « on »
général.
> je crois, je pense, j''estime, je doute, il me semble, on dirait

**Les verbes modaux**, qui modifient le degré de réalité du verbe qui suit.
> devoir, pouvoir, falloir, sembler, paraître
>
> « Il y a trois bacs. » → fait.
> « Il **doit** y avoir trois bacs. » → supposition.
> « Il **semble** y avoir trois bacs. » → incertitude.

*Les verbes modaux sont la famille que les élèves oublient le plus au relevé.
Pense à eux après les adverbes.*

### 3. Les modes et les temps

**Le conditionnel de l''information**, que tu connais depuis le chapitre 12.
> « L''accident **aurait fait** trois blessés. »

**Le futur de supposition.**
> « Ce **sera** sans doute le camion. » *(je suppose, je ne vois pas)*

**Le subjonctif après un verbe de doute.**
> « Je doute qu''il **vienne**. »

### 4. Le vocabulaire évaluatif

C''est la connotation du chapitre 13, vue sous l''angle de l''auteur.

**Appréciatif** — le mot valorise.
> remarquable, admirable, exemplaire, courageux, lumineux, précieux, héroïque,
> généreux

**Dépréciatif** — le mot dévalorise.
> médiocre, lamentable, dérisoire, prétentieux, douteux, bâclé, pitoyable,
> grossier

Ce sont des **adjectifs**, le plus souvent, mais aussi des noms — *un exploit*
contre *une manœuvre* — et des verbes — *il affirme* contre *il prétend*.

*Le couple « affirmer / prétendre » est le plus parlant : « il affirme que le
bac a été retiré » est neutre ; « il prétend que le bac a été retiré » dit que
je n''y crois pas.*

### 5. Les suffixes

Petits, mais très efficaces, et presque jamais relevés par les élèves.

**Les suffixes péjoratifs**
> **-ard** : chauffard, vantard, fuyard, richard
> **-asse** : blondasse, paperasse, hommasse
> **-âtre** : verdâtre, douceâtre, bellâtre
> **-aille** : valetaille, ferraille, mangeaille

**Les diminutifs**, qui minimisent et parfois méprisent
> **-et, -ette** : maisonnette, livret
> **-illon, -ille** : négrillon, brindille

> « Ils ont planté quelques **plantillons**. » → le suffixe dit que ce n''est pas
> sérieux.

### 6. La typographie et la ponctuation

**Les guillemets de distance**, les plus importants.

> « Le ministre a inauguré ses "réformes". »

Ces guillemets-là ne citent personne : ils disent *je reprends le mot des
autres, et je n''y crois pas*. C''est une marque de subjectivité très forte, et
très peu d''élèves la relèvent.

**L''italique** fait le même travail à l''écrit soigné.

**Le point d''exclamation** marque l''émotion ou l''indignation.
> « Trois bacs pour quarante mille habitants ! »

**Les points de suspension** suggèrent sans dire.
> « Et la municipalité, elle… »

### La méthode de relevé, en quatre passes

Quand l''examen demande *relevez les marques de la subjectivité*, procède dans
cet ordre. Tu ne manqueras rien.

> **Passe 1** — les adverbes. Les plus visibles.
> **Passe 2** — les adjectifs et noms évaluatifs.
> **Passe 3** — les verbes modaux et les modes verbaux.
> **Passe 4** — les suffixes et la typographie.

Et pour chaque marque relevée, **dis ce qu''elle révèle**. Un relevé sans
commentaire ne vaut que la moitié des points.

> ✗ « L''auteur emploie "hélas" et "lamentable". »
> ✓ « L''auteur emploie l''adverbe de jugement "hélas" (l. 3) et l''adjectif
> dépréciatif "lamentable" (l. 5) : il ne se contente pas de rapporter la
> situation, il la condamne. »

---

**Exercice corrigé**

*Relever toutes les marques de subjectivité de ce passage, en quatre passes, et
dire ce qu''elles révèlent.*

> « (1) Le camion de ramassage est **enfin** passé mardi, après six semaines
> d''attente. (2) Les services techniques **auraient** procédé, nous dit-on, à
> une « réorganisation » des tournées. (3) Curieusement, cette réorganisation
> n''a été annoncée nulle part. (4) Les habitants, qui ont dû ramasser
> eux-mêmes leurs ordures pendant un mois et demi, apprécieront ce bel effort
> de communication. »

**Correction.**

*Passe 1 — les adverbes.*

> **« enfin »** (l. 1) : adverbe de jugement. Il ne dit pas quand le camion est
> passé, il dit que c''était trop tard.
>
> **« curieusement »** (l. 3) : adverbe de jugement, qui signale une anomalie.
> L''auteur n''accuse pas directement : il laisse le lecteur conclure.
>
> **« nulle part »** (l. 3) : renforce le reproche par l''absolu.

*Passe 2 — le vocabulaire évaluatif.*

> **« bel effort de communication »** (l. 4) : l''adjectif « bel » est
> appréciatif, mais il est employé **ironiquement** — et c''est la marque la
> plus forte du passage. L''auteur dit le contraire de ce qu''il pense.
>
> *C''est le procédé que tu as vu au chapitre 14 : l''ironie. Elle repose ici sur
> l''écart entre « bel effort » et ce que le paragraphe vient de raconter.*

*Passe 3 — les verbes modaux et les modes.*

> **« auraient procédé »** (l. 2) : conditionnel de l''information non
> confirmée. Le journaliste rapporte sans garantir — et après ce qu''il vient
> d''écrire, le conditionnel vaut un doute.
>
> **« nous dit-on »** (l. 2) : incise qui désigne une source anonyme. Elle
> redouble le conditionnel.
>
> **« ont dû ramasser »** (l. 4) : le verbe modal *devoir*, ici au sens
> d''obligation subie. Il souligne que les habitants n''ont pas choisi.
>
> **« apprécieront »** (l. 4) : futur employé ironiquement. Personne
> n''appréciera.

*Passe 4 — la typographie.*

> **les guillemets de « réorganisation »** (l. 2) : ce sont des guillemets de
> distance. L''auteur reprend le mot de l''administration et refuse de le
> prendre à son compte. C''est la marque que les élèves relèvent le moins, et
> l''une des plus révélatrices.

*Ce que l''ensemble révèle.*

> Le passage se donne l''apparence d''un compte rendu neutre — des faits, des
> dates, une durée — mais chaque phrase porte une marque de jugement. L''auteur
> ne dit jamais « la mairie a mal fait son travail » : il le fait entendre par
> un adverbe, un conditionnel, une paire de guillemets et une ironie finale.
> C''est une critique d''autant plus efficace qu''elle paraît n''en être pas une.

*Onze marques en quatre phrases. C''est la densité ordinaire d''un article de
presse engagé, et c''est pourquoi cette question revient si souvent au BEPC.*
', NULL, 28),
    (v_chapitre_id, 'Simulation : le curseur du degré d''adhésion', 5, 'interactif', '{
  "widget": "degre-adhesion",
  "consigne": "Une phrase neutre s''affiche, et un curseur à sept crans allant de « je garantis » à « je rapporte sans y croire ». À chaque position, la simulation réécrit la phrase avec le modalisateur correspondant — il est certain que, sans aucun doute, sans doute, peut-être, il semble que, le conditionnel, dit-on — et te montre ce que le lecteur comprend. Un atelier inverse te donne une phrase modalisée et te demande de placer le curseur. Le piège de « sans doute », qui veut dire « probablement » et non « sans aucun doute », y occupe trois exercices."
}', NULL, 10),
    (v_chapitre_id, 'Appréciatif et dépréciatif : le relevé qui rapporte', 6, 'texte', '
Dernière leçon, et c''est le relevé que l''examen demande le plus souvent sous la
forme : *relevez les termes appréciatifs et dépréciatifs du texte*, ou
*relevez le champ lexical du jugement*. Deux points.

### La définition, et la nuance avec la connotation

Au chapitre 13, tu as vu la **connotation** : ce qu''un mot traîne avec lui.

Ici, nous parlons des mots dont la connotation est **tout le sens**. Un terme
**appréciatif** ou **dépréciatif** ne décrit pas : il juge.

> *une maison* → descriptif
> *une demeure* → appréciatif
> *une bicoque* → dépréciatif

Les trois désignent la même chose. Seuls les deux derniers portent un jugement.

### Les listes, par nature de mot

**Les adjectifs** — les plus nombreux, et les plus faciles à relever.

> *appréciatifs* : remarquable, admirable, exemplaire, brillant, courageux,
> généreux, précieux, héroïque, lumineux, solide, honnête
>
> *dépréciatifs* : médiocre, lamentable, dérisoire, pitoyable, bâclé,
> prétentieux, douteux, grossier, mesquin, obscur, creux

**Les noms** — souvent oubliés au relevé.

> *appréciatifs* : un exploit, une réussite, une prouesse, un chef-d''œuvre,
> une avancée, un modèle
>
> *dépréciatifs* : une manœuvre, un fiasco, un gâchis, un simulacre, une
> mascarade, un prétexte

**Les verbes** — presque jamais relevés, et pourtant décisifs.

> *appréciatifs* : réussir, accomplir, défendre, bâtir, honorer, assumer
>
> *dépréciatifs* : bâcler, prétendre, s''entêter, manœuvrer, gaspiller,
> esquiver

> « Il **affirme** que les travaux sont finis. » → neutre
> « Il **prétend** que les travaux sont finis. » → je n''y crois pas

**Les adverbes** — vus à la leçon précédente.

### Le piège de l''ironie

Un terme appréciatif employé ironiquement devient dépréciatif. C''est ce que tu
as vu dans l''exercice précédent avec « bel effort de communication ».

**Comment le repérer ?** Par l''**écart** entre le mot et ce que le texte
raconte. Si l''auteur loue ce qu''il vient de critiquer, il est ironique.

> « Six semaines sans ramassage. Quelle efficacité remarquable. »

*Au relevé, signale-le : « l''adjectif appréciatif "remarquable" est employé
ironiquement, et vaut donc un jugement dépréciatif. » C''est la remarque qui
sépare une réponse à un point d''une réponse à deux points.*

### Les gradations

Comme au chapitre 13, les mots ont une intensité, et un bon relevé la signale.

> *dépréciatif léger* : discutable, inégal, perfectible
> *dépréciatif moyen* : médiocre, insuffisant, décevant
> *dépréciatif fort* : lamentable, désastreux, scandaleux, indigne

Un auteur qui monte progressivement l''échelle construit son indignation.
Repérer cette montée est une analyse, pas un simple relevé — et cela se
remarque.

### Le moule de réponse

> « L''auteur emploie un vocabulaire nettement dépréciatif pour parler de la
> municipalité : les adjectifs "dérisoire" (l. 4) et "lamentable" (l. 9), le
> nom "simulacre" (l. 7) et le verbe "prétend" (l. 11). On note en outre que
> l''intensité monte au fil du texte : "discutable" au premier paragraphe,
> "scandaleux" au dernier. À l''inverse, les habitants sont décrits par des
> termes appréciatifs — "courageux" (l. 5), "solidaires" (l. 12) — ce qui
> oppose nettement deux camps. »

Nature des mots, citations avec les lignes, gradation, opposition des deux
camps. Quatre éléments, deux points.

---

**Exercice corrigé**

*Relever les termes appréciatifs et dépréciatifs, les classer par nature, et
commenter.*

> « (1) Les jeunes du quartier ont accompli, en trois samedis, ce que la
> commune n''avait pas su faire en six mois. (2) Leur travail, modeste mais
> solide, a dégagé quatre cents mètres de caniveaux. (3) Pendant ce temps, les
> services techniques multipliaient les communiqués et les promesses creuses.
> (4) Le dernier en date, un simulacre de calendrier sans la moindre date
> précise, prétend annoncer une « reprise prochaine » des tournées. (5) On
> admirera la cohérence. »

**Correction.**

*Les termes APPRÉCIATIFS — tous appliqués aux jeunes.*

> **verbe** : « ont accompli » (l. 1) — accomplir suppose une tâche menée à son
> terme, et il valorise.
> **adjectifs** : « modeste » (l. 2), qui est ici un éloge de la mesure, et
> « solide » (l. 2).
> **le chiffre** « quatre cents mètres » (l. 2) n''est pas un terme appréciatif
> en soi, mais il fonctionne comme tel par contraste : c''est du concret, opposé
> aux « communiqués ».

*Les termes DÉPRÉCIATIFS — tous appliqués à la commune.*

> **noun** : « simulacre » (l. 4) — le mot le plus fort du texte : il dit que la
> chose n''a que l''apparence.
> **adjectif** : « creuses » (l. 3), appliqué aux promesses.
> **verbes** : « multipliaient » (l. 3), qui suggère la quantité sans la
> qualité ; et surtout « prétend » (l. 4), qui marque que l''auteur ne croit pas
> à l''annonce.
> **la négation** « n''avait pas su faire » (l. 1) — l''auteur ne dit pas « n''a
> pas fait » mais « n''a pas **su** faire », ce qui ajoute l''incompétence à
> l''inaction.
> **les guillemets** de « reprise prochaine » (l. 4) : guillemets de distance.
> **« sans la moindre date précise »** (l. 4) : la tournure négative renforcée
> est une marque de jugement.

*Le piège de la dernière phrase.*

> **« On admirera la cohérence »** (l. 5) : le verbe « admirer » est
> appréciatif, et il est employé **ironiquement**. Après ce qui précède,
> personne n''admirera rien. Au relevé, il faut le signaler : c''est un terme
> appréciatif de forme, dépréciatif de sens.
>
> *Note aussi le futur « admirera », qui est un futur ironique — le même
> procédé que « les habitants apprécieront » dans l''exercice précédent.*

*Le commentaire d''ensemble.*

> Le texte oppose systématiquement deux camps par le vocabulaire : aux jeunes,
> les verbes d''action et les adjectifs de solidité ; à la commune, les noms de
> l''apparence — « communiqués », « promesses », « simulacre » — et les verbes
> de la parole vaine. L''auteur ne dit jamais que la commune a mal travaillé :
> il lui donne un vocabulaire de mots et aux habitants un vocabulaire d''actes,
> et le lecteur conclut tout seul.

*C''est exactement la remarque qui fait la différence : ne pas seulement
relever, mais montrer que le relevé dessine une opposition.*
', NULL, 28),
    (v_chapitre_id, 'Simulation : appréciatif, dépréciatif, neutre', 7, 'interactif', '{
  "widget": "appreciatif-depreciatif",
  "consigne": "Un texte s''affiche, et tu classes chaque mot chargé dans trois colonnes. La simulation construit à mesure un tableau à deux camps — ce que l''auteur valorise, ce qu''il dévalorise — et le texte se colore. Elle repère aussi les ironies : quand tu classes « remarquable » comme appréciatif alors que le contexte le retourne, elle te montre l''écart. Dix textes, dont quatre de presse camerounaise, et un exercice final où tu dois dire, en deux phrases, ce que l''opposition des deux vocabulaires révèle."
}', NULL, 10),
    (v_chapitre_id, 'Quiz du chapitre 21', 8, 'quiz', '{
  "titre": "Vérifie que tu as compris",
  "questions": [
    {
      "question": "Qu''est-ce que la modalisation ?",
      "choix": [
        "Un temps verbal",
        "Les marques par lesquelles l''auteur montre son degré d''adhésion à ce qu''il dit, et son jugement",
        "Un type de phrase",
        "Une figure de style"
      ],
      "bonne": 1,
      "explication": "« Le camion ne passe plus », « le camion ne passe sans doute plus », « hélas, le camion ne passe évidemment plus » : le fait ne bouge pas, la position de celui qui parle change."
    },
    {
      "question": "« Il court vite » : « vite » est-il un modalisateur ?",
      "choix": [
        "Oui, c''est un adverbe",
        "Non : il porte sur le FAIT lui-même, pas sur ce que le locuteur en pense — « il court probablement » en serait un",
        "Oui, toujours",
        "Cela dépend du verbe"
      ],
      "bonne": 1,
      "explication": "C''est le test : si l''adverbe porte sur le fait, ce n''est pas un modalisateur ; s''il porte sur l''adhésion du locuteur, c''en est un."
    },
    {
      "question": "Que signifie exactement « sans doute » en français ?",
      "choix": [
        "Avec certitude absolue",
        "Probablement — c''est une certitude MOYENNE, moins forte qu''elle n''en a l''air ; pour la certitude totale, il faut « sans aucun doute »",
        "Peut-être",
        "Jamais"
      ],
      "bonne": 1,
      "explication": "C''est le piège de l''expression, et il tombe souvent. Elle paraît affirmer et elle nuance."
    },
    {
      "question": "À quoi servent les guillemets dans « ses « réformes » » ?",
      "choix": [
        "À citer quelqu''un",
        "Ce sont des guillemets de DISTANCE : l''auteur reprend le mot des autres et refuse de le prendre à son compte",
        "À souligner",
        "À poser une question"
      ],
      "bonne": 1,
      "explication": "C''est une marque de subjectivité très forte, et c''est celle que les élèves relèvent le moins."
    },
    {
      "question": "Quelle différence entre « il affirme que » et « il prétend que » ?",
      "choix": [
        "Aucune",
        "« Affirme » est neutre ; « prétend » dit que l''auteur n''y croit pas — c''est un verbe dépréciatif",
        "« Prétend » est plus poli",
        "« Affirme » est plus fort"
      ],
      "bonne": 1,
      "explication": "Les verbes évaluatifs sont presque jamais relevés par les élèves, et pourtant ils sont décisifs."
    },
    {
      "question": "Dans quel ordre faut-il relever les marques de subjectivité ?",
      "choix": [
        "Au hasard",
        "Quatre passes : les adverbes, puis les adjectifs et noms évaluatifs, puis les verbes modaux et les modes, puis les suffixes et la typographie",
        "Du début à la fin",
        "Les adjectifs seulement"
      ],
      "bonne": 1,
      "explication": "En procédant dans cet ordre, tu ne manques rien. Et pour chaque marque relevée, dis ce qu''elle révèle : un relevé sans commentaire ne vaut que la moitié des points."
    },
    {
      "question": "« Six semaines sans ramassage. Quelle efficacité remarquable. » Que vaut « remarquable » ?",
      "choix": [
        "Un terme appréciatif",
        "Un terme appréciatif de forme mais dépréciatif de sens : il est employé ironiquement, et il faut le signaler au relevé",
        "Un terme neutre",
        "Un modalisateur de certitude"
      ],
      "bonne": 1,
      "explication": "On le repère à l''écart entre le mot et ce que le texte raconte. C''est la remarque qui sépare une réponse à un point d''une réponse à deux points."
    }
  ]
}', NULL, 5);

  RAISE NOTICE '8 leçons ajoutées au chapitre 21, La modalisation : vocabulaire appréciatif et dépréciatif.';
END $fr3$;
