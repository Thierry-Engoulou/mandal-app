-- ---------------------------------------------------------------------------
-- M'Andal — Français, classe de 3ème
-- Chapitre 22 : Lecture méthodique et lecture suivie : la tragédie classique
-- Module 3 : La vie économique — 9 leçons
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
  WHERE programme_id = v_programme_id AND ordre = 22;

  IF v_chapitre_id IS NULL THEN
    INSERT INTO public.chapitres (programme_id, titre, ordre, niveau)
    VALUES (v_programme_id, 'Lecture méthodique et lecture suivie : la tragédie classique', 22, 'Module 3 : La vie économique')
    RETURNING id INTO v_chapitre_id;
    RAISE NOTICE 'Chapitre 22 créé.';
  END IF;

  -- Les leçons. Si le chapitre en a déjà, on passe son tour sans rien toucher.
  SELECT count(*) INTO v_deja FROM public.concepts WHERE chapitre_id = v_chapitre_id;
  IF v_deja > 0 THEN
    RAISE NOTICE 'Le chapitre 22 a déjà ses % leçons, je n''y touche pas.', v_deja;
    RETURN;
  END IF;

  INSERT INTO public.concepts
    (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes) VALUES
    (v_chapitre_id, 'La tragédie classique : des règles, et un piège qui se referme', 1, 'texte', '
Troisième trimestre de lecture suivie — mais il arrive au module 3, parce que
le programme le place ici. L''œuvre est **Andromaque**, de **Jean Racine**,
créée en 1667.

Tu as étudié au module 1 le roman africain. Nous changeons de genre, de siècle
et de pays. Et tu vas découvrir qu''une pièce écrite il y a trois cent
cinquante ans parle de choses que tu connais : l''honneur, la dette aux morts,
l''obligation de choisir entre deux malheurs.

### Qu''est-ce que la tragédie ?

C''est une pièce de théâtre qui met en scène des personnages **de haut rang** —
rois, reines, princes — pris dans un conflit qui ne peut se résoudre que par
le **malheur**.

Trois caractères la définissent.

**L''issue est fatale.** La tragédie finit par la mort, l''exil ou la folie. Dès
la première scène, le spectateur sait que cela finira mal : tout le plaisir est
de voir comment.

**Le conflit est intérieur.** Ce n''est pas d''abord un combat entre deux
personnages, c''est un combat à l''intérieur d''un personnage, partagé entre deux
devoirs.

**Le langage est noble.** On parle en **alexandrins**, en vers de douze
syllabes, et dans un vocabulaire soutenu. Personne n''y mange, n''y dort, n''y
travaille.

### Les trois unités

Le théâtre classique du XVIIe siècle français obéit à trois règles strictes,
qu''il faut connaître par cœur.

> **Unité d''ACTION** — une seule intrigue principale, sans épisode secondaire
> qui s''en détache.
>
> **Unité de TEMPS** — l''action se déroule en **vingt-quatre heures** au plus.
>
> **Unité de LIEU** — un seul décor, en général une salle de palais, où tous
> les personnages peuvent se croiser vraisemblablement.

**Pourquoi ces règles ?** Pour la **vraisemblance**. Le spectateur reste trois
heures dans une salle ; si l''action dure trois ans et traverse cinq pays, il
n''y croira pas. En resserrant, on augmente la tension.

C''est un pari : la contrainte, loin d''appauvrir, concentre. Et c''est pourquoi
les tragédies de Racine sont si denses.

### Deux autres règles

**La bienséance** : on ne montre sur scène ni la violence ni rien de choquant.
Les meurtres se déroulent en coulisses, et un personnage vient les **raconter**.
C''est le rôle du *récit*, morceau de bravoure de la tragédie.

**La vraisemblance** : rien d''impossible ou de magique. Les dieux parlent, mais
on ne les voit pas.

### La structure en cinq actes

Toute tragédie classique en compte cinq, et chacun a son rôle.

> **Acte I — l''EXPOSITION.** On apprend qui est qui, où l''on est, ce qui s''est
> passé avant, et quel est le problème. Tout doit être dit dans ce premier
> acte.
>
> **Acte II — le NŒUD.** La situation se complique, les intérêts s''opposent.
>
> **Acte III — les PÉRIPÉTIES.** Les retournements s''enchaînent ; on croit
> plusieurs fois que cela va s''arranger.
>
> **Acte IV — le point de NON-RETOUR.** Une décision irréversible est prise.
>
> **Acte V — le DÉNOUEMENT.** Le malheur arrive, et il est raconté.

### Le vocabulaire du théâtre

Il tombe à chaque session. Apprends-le.

> **une réplique** — ce que dit un personnage
> **une tirade** — une longue réplique ininterrompue
> **un monologue** — un personnage seul sur scène, qui parle à lui-même
> **un aparté** — ce qu''un personnage dit sans que les autres l''entendent
> **une stichomythie** — un échange de répliques très courtes, souvent d''un
> vers chacune ; elle marque l''affrontement
> **une didascalie** — les indications scéniques, en italique, qui ne sont pas
> prononcées
> **un confident** — personnage secondaire à qui le héros confie ses pensées,
> et qui existe pour que le spectateur les entende
> **le dénouement** — la fin, qui dénoue l''intrigue
> **le coup de théâtre** — un retournement brutal et imprévu

*Le confident mérite une remarque : Céphise, Pylade, Cléone n''existent que pour
permettre à Andromaque, Oreste et Hermione de penser à voix haute. C''est une
astuce de théâtre, et elle est très ancienne.*

---

**Exercice corrigé**

*1. Expliquer pourquoi la règle des trois unités augmente la tension
dramatique, au lieu de l''appauvrir.*

*2. Pourquoi les meurtres ne sont-ils pas montrés sur scène ? Quelle
conséquence pour l''écriture de la pièce ?*

*3. À quoi sert un confident ?*

**Correction.**

*1.* Parce qu''elle **resserre**. Si tout doit arriver en vingt-quatre heures,
dans un seul lieu, autour d''une seule intrigue, alors chaque scène compte et
rien ne peut être remis à plus tard.

Imagine la même histoire étalée sur deux ans : Andromaque pourrait réfléchir,
consulter, attendre. Les personnages auraient le temps de changer d''avis, de
se calmer, de négocier. En vingt-quatre heures, ils n''ont le temps de rien :
ils doivent décider maintenant.

*La contrainte crée l''urgence, et l''urgence crée la tragédie. C''est un principe
que tu retrouveras ailleurs : une consigne serrée oblige souvent à écrire
mieux.*

*2.* À cause de la règle de **bienséance** : on ne montre pas sur scène ce qui
choquerait le spectateur — le sang, la mort violente.

**La conséquence pour l''écriture est considérable** : puisqu''on ne peut pas
montrer, il faut **raconter**. La tragédie classique développe donc un morceau
particulier, le **récit**, où un personnage vient décrire en détail ce qui
s''est passé hors scène.

Et c''est souvent le plus beau passage de la pièce, parce que l''auteur y déploie
toutes ses ressources : il doit faire voir avec des mots ce que le spectateur
ne verra pas. L''interdiction a produit un art.

*3.* Le confident sert à **rendre audible la pensée du héros**.

Un personnage seul ne peut pas raisonner à voix haute pendant quarante vers
sans paraître fou. Mais s''il a quelqu''un à qui parler, tout devient naturel :
il explique, il hésite, il se contredit, et le spectateur suit son cheminement.

*Techniquement, c''est un procédé d''exposition et de révélation. Dans*
Andromaque*, Céphise, Pylade et Cléone n''ont presque pas de volonté propre :
elles sont là pour que leurs maîtres pensent devant nous. Quand tu étudieras
une scène, repère toujours le confident : sa présence t''indique que ce qui se
dit là est destiné au public autant qu''à lui.*
', NULL, 28),
    (v_chapitre_id, 'Figure : Andromaque, la chaîne des amours', 2, 'figure', '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 580 320" width="580" height="320">
<rect width="580" height="320" fill="#ffffff"/>
<text x="290" y="24" text-anchor="middle" font-size="14" font-weight="700" fill="#0f172a">Andromaque : la chaîne des amours impossibles</text>
<text x="290" y="42" text-anchor="middle" font-size="10" fill="#64748b">Chacun aime celui qui ne l&apos;aime pas. C&apos;est tout le ressort de la pièce.</text>

<circle cx="80" cy="110" r="36" fill="#dbeafe" stroke="#2563eb" stroke-width="2"/>
<text x="80" y="106" text-anchor="middle" font-size="11" font-weight="700" fill="#1e3a8a">Oreste</text>
<text x="80" y="120" text-anchor="middle" font-size="7.5" fill="#1e40af">ambassadeur</text>

<circle cx="222" cy="110" r="36" fill="#fce7f3" stroke="#be185d" stroke-width="2"/>
<text x="222" y="106" text-anchor="middle" font-size="11" font-weight="700" fill="#831843">Hermione</text>
<text x="222" y="120" text-anchor="middle" font-size="7.5" fill="#9d174d">promise à Pyrrhus</text>

<circle cx="364" cy="110" r="36" fill="#fef3c7" stroke="#ca8a04" stroke-width="2"/>
<text x="364" y="106" text-anchor="middle" font-size="11" font-weight="700" fill="#78350f">Pyrrhus</text>
<text x="364" y="120" text-anchor="middle" font-size="7.5" fill="#92400e">roi d&apos;Épire</text>

<circle cx="506" cy="110" r="36" fill="#dcfce7" stroke="#15803d" stroke-width="2"/>
<text x="506" y="104" text-anchor="middle" font-size="11" font-weight="700" fill="#14532d">Andromaque</text>
<text x="506" y="118" text-anchor="middle" font-size="7.5" fill="#166534">veuve d&apos;Hector</text>

<path d="M 118 110 L 182 110" fill="none" stroke="#b91c1c" stroke-width="2"/>
<polygon points="186,110 176,105 176,115" fill="#b91c1c"/>
<text x="150" y="102" text-anchor="middle" font-size="8" font-weight="700" fill="#b91c1c">aime</text>

<path d="M 260 110 L 324 110" fill="none" stroke="#b91c1c" stroke-width="2"/>
<polygon points="328,110 318,105 318,115" fill="#b91c1c"/>
<text x="292" y="102" text-anchor="middle" font-size="8" font-weight="700" fill="#b91c1c">aime</text>

<path d="M 402 110 L 466 110" fill="none" stroke="#b91c1c" stroke-width="2"/>
<polygon points="470,110 460,105 460,115" fill="#b91c1c"/>
<text x="434" y="102" text-anchor="middle" font-size="8" font-weight="700" fill="#b91c1c">aime</text>

<path d="M 506 150 C 506 190, 400 196, 400 196" fill="none" stroke="#64748b" stroke-width="1.6" stroke-dasharray="4 3"/>
<text x="470" y="186" text-anchor="middle" font-size="8" fill="#475569">aime encore</text>

<rect x="300" y="186" width="100" height="26" rx="4" fill="#f1f5f9" stroke="#64748b"/>
<text x="350" y="203" text-anchor="middle" font-size="9" font-weight="700" fill="#0f172a">Hector, mort</text>

<rect x="20" y="226" width="268" height="78" rx="6" fill="#fee2e2" stroke="#b91c1c" stroke-width="1.5"/>
<text x="154" y="246" text-anchor="middle" font-size="10" font-weight="700" fill="#7f1d1d">LE DILEMME D&apos;ANDROMAQUE</text>
<text x="36" y="264" font-size="8.5" fill="#991b1b">épouser Pyrrhus → trahir Hector</text>
<text x="36" y="278" font-size="8.5" fill="#991b1b">refuser Pyrrhus → Astyanax meurt</text>
<text x="154" y="296" text-anchor="middle" font-size="8" font-style="italic" fill="#475569">deux issues, aucune acceptable</text>

<rect x="296" y="226" width="264" height="78" rx="6" fill="#f1f5f9" stroke="#64748b" stroke-width="1.5"/>
<text x="428" y="246" text-anchor="middle" font-size="10" font-weight="700" fill="#0f172a">LES TROIS UNITÉS</text>
<text x="312" y="264" font-size="8.5" fill="#334155">ACTION — une seule intrigue</text>
<text x="312" y="278" font-size="8.5" fill="#334155">TEMPS — vingt-quatre heures</text>
<text x="312" y="292" font-size="8.5" fill="#334155">LIEU — un seul décor, ici le palais</text>
</svg>', NULL, 5),
    (v_chapitre_id, 'Simulation : la structure de la tragédie', 3, 'interactif', '{
  "widget": "structure-tragedie",
  "consigne": "Les cinq actes s''affichent vides, et tu places les scènes d''Andromaque dans le bon acte : l''arrivée d''Oreste, l''ultimatum de Pyrrhus, la décision d''Andromaque, l''ordre donné par Hermione, le récit de la mort. La simulation t''explique à chaque fois la fonction de l''acte — exposition, nœud, péripéties, non-retour, dénouement — et refuse les placements qui casseraient la logique. Un second atelier te fait vérifier les trois unités sur la pièce, heure par heure, et un troisième te fait reconnaître les neuf termes du vocabulaire du théâtre sur des extraits réels."
}', NULL, 10),
    (v_chapitre_id, 'Andromaque : quatre personnages, une chaîne, un dilemme', 4, 'texte', '
### L''arrière-plan : il faut le connaître

La pièce se déroule après la **guerre de Troie**. Les Grecs ont pris et détruit
la ville. Parmi les prisonnières emmenées en Grèce se trouve **Andromaque**,
veuve d''**Hector**, le plus grand guerrier troyen, tué par Achille. Elle a un
fils, **Astyanax**, encore enfant.

Elle est captive de **Pyrrhus**, roi d''Épire, fils d''Achille — c''est-à-dire du
meurtrier de son mari.

Voilà la situation au lever de rideau. Tout le reste en découle.

### La chaîne des amours

C''est le ressort de la pièce, et il tient en une ligne : **chacun aime celui
qui ne l''aime pas**.

> **Oreste** aime **Hermione**, qui ne l''aime pas.
> **Hermione** aime **Pyrrhus**, qui ne l''aime pas.
> **Pyrrhus** aime **Andromaque**, qui ne l''aime pas.
> **Andromaque** aime **Hector**, qui est mort.

Une chaîne à quatre maillons, et le dernier ne mène nulle part. Personne ne
peut être heureux, et ce n''est la faute de personne : c''est le **tragique** au
sens strict.

### Les quatre personnages

**ANDROMAQUE** — veuve d''Hector, mère d''Astyanax, captive.
Son devoir est double : rester fidèle à son mari mort, et sauver son fils
vivant. Elle est le personnage le plus noble de la pièce, et le seul qui ne
pense pas à son propre bonheur.

**PYRRHUS** — roi d''Épire, fils d''Achille.
Il aime Andromaque, et il est prêt à trahir les Grecs pour elle. Il est violent,
changeant, capable de menacer un enfant pour obtenir un mariage. Et il est
sincère, ce qui le rend plus inquiétant encore.

**HERMIONE** — fille d''Hélène, promise à Pyrrhus.
Elle aime Pyrrhus et elle est humiliée par lui. Sa jalousie la mène au crime.
C''est le personnage le plus moderne : son discours oscille entre l''amour et la
haine jusque dans la même réplique.

**ORESTE** — ambassadeur des Grecs, fils d''Agamemnon.
Il aime Hermione depuis toujours et il est venu chercher Astyanax. Il acceptera
de tuer pour elle, et il sombrera dans la folie. Il porte la malédiction de sa
famille.

### L''action, acte par acte

**Acte I.** Oreste arrive en Épire. Il demande à Pyrrhus de lui livrer
Astyanax, que les Grecs veulent tuer pour qu''il ne venge jamais Troie. Pyrrhus
refuse — non par générosité, mais parce que l''enfant est son seul moyen de
pression sur Andromaque.

**Acte II.** Hermione reçoit Oreste. Elle feint l''indifférence pour Pyrrhus.
Pyrrhus, irrité du refus d''Andromaque, annonce qu''il épousera finalement
Hermione et livrera l''enfant.

**Acte III.** Andromaque, désespérée, supplie Pyrrhus. Il lui pose un
ultimatum : **l''épouser, ou voir mourir son fils**. Elle demande à réfléchir et
va se recueillir sur le tombeau d''Hector.

**Acte IV.** Andromaque a trouvé une issue : elle épousera Pyrrhus pour sauver
Astyanax, puis se donnera la mort aussitôt après la cérémonie. Ainsi elle sauve
l''enfant **et** reste fidèle à Hector. Pendant ce temps, Hermione, folle de
jalousie, demande à Oreste de tuer Pyrrhus.

**Acte V.** Oreste fait tuer Pyrrhus pendant la cérémonie. Il vient l''annoncer
à Hermione, croyant avoir gagné son amour. Elle le maudit — « Qui te l''a
dit ? » — et se tue sur le corps de Pyrrhus. Oreste devient fou. Andromaque,
devenue reine, est vengée sans avoir rien fait.

*La fin est d''une ironie terrible : la seule qui n''a jamais rien voulu pour
elle-même est la seule qui survit et règne.*

### Le dilemme d''Andromaque : le cœur de la pièce

C''est ce qu''il faut comprendre pour tout comprendre.

> **Si elle épouse Pyrrhus** → son fils vit, mais elle trahit Hector, et elle
> épouse le fils de son meurtrier.
> **Si elle refuse** → elle reste fidèle à Hector, mais son fils meurt.

**Deux issues, et aucune n''est acceptable.** Ce n''est pas un choix difficile :
c''est un choix impossible. C''est la définition même du **dilemme tragique**.

Et sa solution — épouser puis mourir — est une invention admirable, parce
qu''elle respecte les deux devoirs à la fois. Elle paie le mariage du prix de sa
vie.

*Pose-toi la question : aurais-tu trouvé cette issue ? Elle n''est ni un
compromis ni une ruse : c''est un sacrifice qui honore les deux obligations. Et
c''est pourquoi Andromaque est le personnage le plus élevé de la pièce.*

---

**Exercice corrigé**

*1. Pourquoi Pyrrhus refuse-t-il de livrer Astyanax à l''acte I ? Son refus
est-il généreux ?*

*2. Expliquer en quoi la situation d''Andromaque est un dilemme, et non un
simple choix difficile.*

*3. Montrer que la fin de la pièce est ironique.*

**Correction.**

*1.* Il refuse parce que l''enfant est son **moyen de pression** sur
Andromaque. Tant qu''il le détient, il peut espérer obtenir d''elle un mariage.

Son refus n''est donc **pas généreux** : il est intéressé. Pyrrhus se donne
l''apparence d''un protecteur, et il se conduit en maître chanteur. L''acte III le
montrera sans ambiguïté, quand il posera son ultimatum.

*C''est une finesse de Racine qu''il faut relever : le même acte — refuser de
livrer un enfant à ses bourreaux — peut être noble ou ignoble selon le motif. La
tragédie classique ne juge pas les actes, elle juge les mobiles.*

*2.* Un **choix difficile** suppose qu''une des deux options soit préférable,
même de peu. On pèse, on tranche, on regrette un peu.

Un **dilemme** suppose que les deux options soient également inacceptables, et
qu''aucune ne puisse être préférée sans renier quelque chose d''essentiel.

Andromaque est tenue par deux devoirs absolus et incompatibles : **la fidélité
à son mari mort** et **la protection de son fils vivant**. Aucun des deux ne
peut céder devant l''autre, car aucun n''est négociable.

*Et c''est pourquoi sa solution est admirable : elle n''a pas choisi entre les
deux, elle a trouvé le seul moyen de les honorer tous les deux à la fois, au
prix de sa propre vie.*

*3.* La fin est ironique **parce que les résultats sont l''inverse exact des
intentions**.

> **Hermione** voulait Pyrrhus : elle le fait tuer, et meurt sur son corps.
> **Oreste** voulait Hermione : il tue pour elle, et elle le maudit avant de
> mourir ; il devient fou.
> **Pyrrhus** voulait Andromaque : il meurt le jour de ses noces avec elle.
> **Andromaque** ne voulait rien pour elle-même : elle survit, elle règne, et
> son fils vit.

*Les trois personnages qui agissent pour leur propre bonheur le perdent. La
seule qui n''agit que par devoir l''obtient sans l''avoir cherché. Racine ne le
dit nulle part — aucun personnage ne vient expliquer la leçon — mais la
construction la fait voir.*

*C''est une remarque à garder pour un commentaire : dans une tragédie réussie,
le sens n''est jamais énoncé, il est produit par la structure.*
', NULL, 28),
    (v_chapitre_id, 'Simulation : le dilemme d''Andromaque', 5, 'interactif', '{
  "widget": "dilemme-andromaque",
  "consigne": "Tu es Andromaque à l''acte III. Deux portes s''ouvrent : épouser Pyrrhus, ou refuser. Chacune déroule devant toi ses conséquences, acte par acte, et la simulation te montre ce que tu perds dans les deux cas — ton fils d''un côté, la fidélité à Hector de l''autre. Quand tu as constaté qu''aucune des deux n''est tenable, elle ouvre une troisième porte : celle que Racine a inventée. Un second atelier te fait reconstituer la chaîne des amours en plaçant les quatre personnages, puis te demande ce qui se passerait si un seul maillon était réciproque — et tu verras que la pièce entière s''effondre."
}', NULL, 10),
    (v_chapitre_id, 'Lire une scène de tragédie : la méthode', 6, 'texte', '
Dernière leçon avant le sujet. Voici comment on lit un extrait de théâtre à
l''examen, et c''est différent de la lecture d''un roman.

### Première chose : où en est-on ?

Avant de lire une ligne, situe la scène.

> **Quel acte, quelle scène ?** L''acte I est une exposition, l''acte V un
> dénouement : on n''y lit pas la même chose.
> **Qui est en scène ?** Combien de personnages, et leurs rapports.
> **Que vient-il de se passer ?** Le chapeau du sujet le dit toujours.

### Deuxième chose : qui parle, et combien

C''est le premier relevé, et il est très rentable.

**Compte les vers de chaque personnage.** Celui qui parle le plus domine la
scène — ou cherche à la dominer.

> Un personnage qui a trente vers et un autre qui en a deux : le second est
> dominé, ou il refuse l''échange.

**Repère la forme de l''échange.**

> **La TIRADE** — longue réplique ininterrompue. Le personnage expose,
> argumente, supplie. Elle marque la maîtrise, ou l''emportement.
>
> **La STICHOMYTHIE** — répliques très courtes, souvent un vers chacune, qui
> s''enchaînent vite. Elle marque **l''affrontement**, et le rythme s''accélère.
>
> **L''APARTÉ** — ce qu''un personnage dit sans être entendu des autres. Il
> révèle la vérité d''un personnage qui ment en scène.
>
> **Le MONOLOGUE** — seul en scène. Il révèle le conflit intérieur.

*Si une scène passe de la tirade à la stichomythie, l''auteur a accéléré :
signale-le, c''est une analyse.*

### Troisième chose : l''alexandrin

Un alexandrin est un vers de **douze syllabes**, coupé en deux moitiés de six
par une pause appelée **césure**.

> Je t''ai-mais in-cons-tant ‖ qu''au-rais-je fait fi-dè-le ?
> *(6 syllabes ‖ 6 syllabes)*

**Compter les syllabes** demande deux précautions.

**Le e muet se prononce à l''intérieur du vers**, devant une consonne, mais pas
à la fin.
> « une » compte deux syllabes au milieu du vers, une seule à la fin.

**La diérèse** : certains mots se prononcent en séparant deux voyelles
voisines, pour atteindre le compte.
> *passion* → pa-ssi-on, trois syllabes.

**Ce qu''il faut repérer dans un vers :**

> **la césure** — où tombe la pause ? Si elle coupe un mot ou une idée en deux,
> c''est un effet.
> **l''enjambement** — quand la phrase déborde sur le vers suivant. Il crée une
> rupture, souvent de l''émotion.
> **les rejets** — un mot isolé au début du vers suivant : il est mis en
> relief.

### Quatrième chose : le lexique du tragique

Relève les mots du **champ lexical de la fatalité** : sort, destin, dieux,
fureur, sang, flamme, malheur, crime, perte.

Et les mots du **champ lexical de la passion** : feu, flamme, charmes, soupirs,
ardeur, chaîne, fers.

*Au XVIIe siècle, ces mots ont un sens plus fort qu''aujourd''hui. « Charmes »
signifie « pouvoir magique » ; « fers » signifie « chaînes de l''amour » ;
« flamme » signifie « passion ». Un texte ancien se lit avec son vocabulaire,
pas avec le nôtre.*

### Cinquième chose : le mouvement de la scène

Une bonne analyse décrit le **mouvement** : comment la scène commence, ce qui
bascule, où elle finit.

> « La scène s''ouvre sur une supplication d''Andromaque ; elle bascule au vers
> 12 quand Pyrrhus pose son ultimatum ; elle s''achève sur un silence
> d''Andromaque, qui n''est ni un refus ni une acceptation. »

Trois temps, trois phrases. C''est le squelette de tout commentaire de théâtre.

### Le moule de réponse pour une question de théâtre

> « Cette scène est un affrontement, comme le montre la stichomythie des vers
> 14 à 20, où chaque personnage ne dispose que d''un vers. Le rythme s''accélère
> brutalement après la longue tirade de Pyrrhus (v. 1-13) : le passage de la
> tirade à la stichomythie marque le moment où la discussion devient un duel.
> Andromaque, qui n''avait pas pris la parole, conquiert ici l''égalité du temps
> de parole — mais c''est pour refuser. »

Forme repérée, vers cités, effet nommé, interprétation. Quatre mouvements.

---

**Exercice corrigé**

*Voici quatre vers d''Hermione à Oreste, à l''acte V, après qu''il a fait tuer
Pyrrhus pour elle.*

> « Pourquoi l''assassiner ? Qu''a-t-il fait ? À quel titre ?
> Qui te l''a dit ? »

*1. Compter les syllabes du premier vers.*
*2. Quelle forme prend l''échange ? Quel effet produit-elle ?*
*3. Que révèle la question « Qui te l''a dit ? » sur le personnage ?*

**Correction.**

*1.* Comptons : *Pour-quoi l''as-sa-ssi-ner* (6) *Qu''a-t-il fait À quel ti-tre*
(6). Douze syllabes : c''est un **alexandrin** régulier, avec une césure nette
après « assassiner ».

*Note que la césure tombe ici exactement entre deux questions. Elle n''interrompt
pas une idée : elle sépare deux coups.*

*2.* L''échange prend la forme d''une **série de questions brèves**, trois dans
un seul vers. Ce n''est pas tout à fait une stichomythie — Oreste ne répond
pas — mais le procédé produit le même effet : une **accélération brutale**.

L''effet est celui d''un **assaut**. Hermione ne laisse pas à Oreste le temps de
parler : chaque question en appelle une autre. Le rythme haché traduit la
fureur, et l''absence de réponse d''Oreste montre qu''il est écrasé.

*Compare avec une tirade : si Hermione avait fait trente vers d''explications,
le spectateur aurait vu une femme qui raisonne. Ici il voit une femme qui
frappe.*

*3.* La question « Qui te l''a dit ? » est l''une des plus célèbres du théâtre
français, et elle est **monstrueuse**.

Hermione a ordonné elle-même à Oreste de tuer Pyrrhus. Elle le sait. Et elle
demande qui le lui a dit.

Ce que cela révèle :

**Elle refuse sa propre responsabilité.** Au moment où l''acte est accompli, elle
ne le reconnaît plus comme le sien.

**Elle découvre qu''elle aimait Pyrrhus.** Tant qu''il vivait, elle pouvait le
haïr ; mort, elle ne peut plus. Le crime lui révèle son propre sentiment.

**Elle accable celui qui lui a obéi.** Oreste, qui a tué pour elle, devient le
coupable unique. C''est ce qui le mènera à la folie.

*Et voici pourquoi le vers est si fort : il tient en quatre mots, il ne contient
aucun mot rare, aucune image, aucun effet de style. Toute sa violence vient de
la situation. C''est cela, le théâtre : les mots les plus simples placés à
l''endroit où ils font le plus de mal.*
', NULL, 28),
    (v_chapitre_id, 'Simulation : lire une scène de tragédie', 7, 'interactif', '{
  "widget": "lire-scene-tragedie",
  "consigne": "Une scène d''Andromaque s''affiche, et la simulation te fait appliquer la méthode en cinq temps. Elle compte avec toi les vers de chaque personnage et trace l''écart en barres — qui domine, qui se tait. Elle te fait repérer le passage de la tirade à la stichomythie et t''explique ce que l''accélération produit. Elle te fait scander un alexandrin syllabe par syllabe, e muets et diérèses compris, et elle marque la césure. Enfin tu relèves les deux champs lexicaux — la fatalité et la passion — avec leur sens du XVIIe siècle, qui n''est pas le nôtre. Cinq scènes, de l''exposition au dénouement."
}', NULL, 10),
    (v_chapitre_id, 'Sujet type BEPC — Étude de texte sur une scène de théâtre, corrigé', 8, 'texte', '
Une épreuve complète, dans la forme exacte de l''examen. Compose en deux heures,
puis compare.

---

## SUJET

**Texte.** *Jean Racine,* Andromaque*, 1667, acte III, scène 7 (extrait
adapté). Pyrrhus, roi d''Épire, pose son ultimatum à Andromaque, sa captive. Il
détient Astyanax, le fils qu''elle a eu d''Hector, son mari tué pendant la guerre
de Troie.*

> **PYRRHUS**
> (1) Madame, demeurez. On peut vous rendre encore
> (2) Ce fils que vos regards semblent redemander.
> (3) Je vous le donnerai. Je veux bien vous le rendre,
> (4) Mais à quel prix, Madame, il faut enfin l''entendre.
> (5) Songez-y : je vous laisse, et je viendrai vous prendre
> (6) Pour vous mener au temple, où ce fils doit m''attendre ;
> (7) Et là vous me verrez, soumis ou furieux,
> (8) Vous couronner, Madame, ou le perdre à vos yeux.
>
> **ANDROMAQUE**
> (9) Hélas ! il mourra donc. Il n''a pour sa défense
> (10) Que les pleurs de sa mère et que son innocence.
>
> **PYRRHUS**
> (11) Allez, Madame, allez voir votre fils.
> (12) Peut-être, en le voyant, votre amour plus timide
> (13) Ne prendra pas toujours sa colère pour guide.
> (14) Je reviendrai. Pour vous je sais ce qu''il m''en coûte :
> (15) Songez bien qu''il s''agit de sa vie, et sans doute
> (16) Que ce n''est pas à moi d''en répondre aujourd''hui.

---

**PARTIE I — COMPRÉHENSION DU TEXTE (10 points)**

*1. Situez ce passage : qui sont les deux personnages, et quel lien les unit ?
(2 pts)*

*2. Quel choix Pyrrhus impose-t-il à Andromaque ? Reformulez-le avec vos
propres mots. (2 pts)*

*3. Relevez deux marques de la domination de Pyrrhus dans cette scène. (2 pts)*

*4. Expliquez le vers 10 : que dit-il de la situation d''Astyanax ? (2 pts)*

*5. Le comportement de Pyrrhus vous paraît-il celui d''un homme amoureux ?
Justifiez. (2 pts)*

**PARTIE II — CONNAISSANCE ET MANIEMENT DE LA LANGUE (10 points)**

*1. Expliquez le sens des mots « demeurez » (1) et « couronner » (8). (2 pts)*

*2. Relevez quatre mots appartenant au champ lexical de la mort ou de la
menace. (2 pts)*

*3. Donnez la nature et la fonction de « où » dans « au temple, où ce fils doit
m''attendre » (6). (2 pts)*

*4. À quel mode et à quel temps est « demeurez » (1) ? Réécrivez ce vers en
vous adressant à plusieurs personnes au présent de l''indicatif. (2 pts)*

*5. Relevez les propositions du vers 15-16, nommez-les et donnez la fonction de
la subordonnée. (2 pts)*

---

## CORRIGÉ

**PARTIE I**

**1. Situer le passage (2 pts).**

> Les deux personnages sont **Pyrrhus**, roi d''Épire et fils d''Achille, et
> **Andromaque**, veuve d''Hector et captive de Pyrrhus depuis la chute de
> Troie.
>
> Le lien qui les unit est double, et c''est ce qui fait le tragique :
> Andromaque est la **prisonnière** de Pyrrhus, mais Pyrrhus est **amoureux**
> d''elle. Il a donc sur elle un pouvoir total et aucun pouvoir du tout. Il faut
> ajouter que Pyrrhus est le fils de l''homme qui a tué Hector : l''épouser
> serait, pour Andromaque, épouser la famille du meurtrier de son mari.

*Le chapeau du sujet donnait une partie de ces éléments. La réponse complète
ajoute ce qu''il ne dit pas : le lien de Pyrrhus avec Achille, et la
contradiction du maître amoureux de sa captive.*

**2. Le choix imposé (2 pts).**

> Pyrrhus met Andromaque devant une alternative qu''il énonce au vers 8 :
> **l''épouser, ou voir mourir son fils**. Il le formule par une opposition
> brutale : « Vous couronner, Madame, ou le perdre à vos yeux » (v. 8).
>
> Reformulé : *si tu acceptes de devenir ma femme, je te fais reine et je sauve
> ton enfant ; si tu refuses, je le livre aux Grecs qui le tueront, et tu
> assisteras à sa mort.*

*Note la construction du vers 8 : deux termes séparés par « ou », avec la
couronne d''un côté et la mort de l''autre. Racine met l''alternative entière dans
un seul alexandrin — c''est le vers le plus important de la scène.*

**3. Deux marques de la domination de Pyrrhus (2 pts).** *Un point par marque,
avec sa citation.*

> **Première marque : il occupe presque tout l''espace de parole.** Pyrrhus
> prononce quatorze vers, Andromaque deux. Ce déséquilibre n''est pas un hasard
> : il montre qu''elle n''a pas la possibilité de discuter, seulement de subir.
>
> **Seconde marque : il emploie l''impératif.** « demeurez » (v. 1), « Songez-y »
> (v. 5), « Allez, Madame, allez voir votre fils » (v. 11), « Songez bien »
> (v. 15). Ce sont des ordres, et le redoublement « Allez… allez » insiste.
>
> *On peut relever une troisième marque, qui vaudrait bonus : il parle de son
> propre pouvoir au futur comme d''une certitude — « je viendrai vous prendre »
> (v. 5), « vous me verrez » (v. 7), « Je reviendrai » (v. 14). Il ne demande
> pas, il annonce.*

**4. Expliquer le vers 10 (2 pts).**

> Le vers 10 — « Que les pleurs de sa mère et que son innocence » — énumère
> tout ce dont Astyanax dispose pour se défendre : **les larmes de sa mère et
> son innocence d''enfant**.
>
> Or ces deux choses ne sont **pas des moyens de défense**. Des larmes
> n''arrêtent personne, et l''innocence est précisément ce que les Grecs veulent
> détruire — ils veulent tuer l''enfant pour qu''il ne venge jamais Troie, donc
> parce qu''il est innocent aujourd''hui et qu''il ne le restera pas.
>
> Le vers dit donc, en creux, qu''**Astyanax est sans défense**. Le mot « que »,
> répété deux fois, a une valeur restrictive : il souligne que c''est tout ce
> qu''il y a, et que c''est peu.

*La restriction par « ne… que » est le procédé central de ces deux vers, et le
signaler vaut le second point.*

**5. Pyrrhus est-il un homme amoureux ? (2 pts)**

*Question d''opinion : il n''y a pas de bonne réponse, mais il y a une bonne
manière de répondre — prendre position, justifier par le texte, nuancer.*

> Son comportement ne me paraît pas celui d''un homme amoureux, du moins pas au
> sens où nous l''entendons. Un amoureux cherche à être aimé en retour ; Pyrrhus
> cherche à être obéi. Il n''avance aucun argument pour se faire aimer : il
> menace. Et ce qu''il menace n''est pas Andromaque elle-même, mais son enfant,
> c''est-à-dire ce qu''elle a de plus vulnérable. On appelle cela un chantage, et
> le mot n''est pas trop fort.
>
> Je note cependant que Racine le montre sincère, et c''est ce qui le rend
> intéressant. Au vers 14, « Pour vous je sais ce qu''il m''en coûte » : il
> reconnaît que cette situation lui est pénible. Et aux vers 12 et 13, il
> cherche encore une issue — il espère qu''en voyant son fils, elle cédera.
> Pyrrhus n''est donc pas un simple tyran : c''est un homme qui souffre et qui,
> parce qu''il souffre, se croit autorisé à tout.
>
> C''est peut-être cela qui fait le personnage : non pas qu''il n''aime pas, mais
> qu''il aime d''un amour qui ne sait faire que du mal.

*Structure de la réponse : je prends position, je prouve par deux citations, je
nuance avec une citation contraire, je conclus. Dix lignes, deux points.*

---

**PARTIE II**

**1. Le sens des mots (2 pts).** *Un point par mot.*

> **« demeurez »** (v. 1) : du verbe *demeurer*, qui signifie ici **rester**,
> ne pas s''en aller. C''est un sens classique du XVIIe siècle ; en français
> d''aujourd''hui, *demeurer* a surtout gardé le sens d''« habiter », comme dans
> *une demeure*.
>
> **« couronner »** (v. 8) : **poser une couronne sur la tête**, donc faire
> reine. Par extension, épouser Andromaque et la faire régner avec lui. Famille
> du mot : *couronne*, *couronnement*.

*Signaler que « demeurer » a changé de sens depuis le XVIIe siècle est
exactement ce que cette question attend sur un texte ancien.*

**2. Le champ lexical de la mort ou de la menace (2 pts).** *Un demi-point par
mot.*

> **« perdre »** (v. 8), au sens de « faire mourir » — sens classique —
> **« mourra »** (v. 9) — **« défense »** (v. 9) — **« furieux »** (v. 7) —
> **« colère »** (v. 13) — **« il s''agit de sa vie »** (v. 15).

*Quatre suffisent. Attention à « pleurs » (v. 10), qui appartient au champ
lexical de la douleur, et non à celui de la mort — c''est le piège de cette
question.*

**3. Nature et fonction de « où » (2 pts).**

> **Nature** : « où » est un **pronom relatif**.
>
> **Fonction** : je lis la subordonnée seule, « où ce fils doit m''attendre ».
> Ce fils doit m''attendre **où** ? Au temple. « Où » est donc **complément
> circonstanciel de lieu du verbe « doit attendre »**.
>
> Son **antécédent** est le nom « temple », et la proposition « où ce fils doit
> m''attendre » est une **proposition subordonnée relative déterminative**,
> complément de son antécédent.

*Le geste du chapitre 9 : cacher la principale et lire la relative seule.*

**4. Mode, temps, et réécriture (2 pts).** *Un point pour l''identification, un
pour la réécriture.*

> **« demeurez »** (v. 1) est à l''**impératif présent**, deuxième personne du
> pluriel. Il s''agit ici du vouvoiement d''une seule personne, Andromaque :
> Pyrrhus s''adresse à elle avec le « vous » de politesse, usage obligatoire
> dans la tragédie classique.
>
> **Réécriture en s''adressant à plusieurs personnes, au présent de
> l''indicatif :**
>
> > Mesdames, vous demeurez.
>
> *Le passage de l''impératif à l''indicatif change tout : l''ordre devient un
> constat. C''est précisément ce que la question veut faire voir.*

**5. Les propositions des vers 15 et 16 (2 pts).**

> « Songez bien **qu**''il s''agit de sa vie, et sans doute **que** ce n''est pas à
> moi d''en répondre aujourd''hui. »

*Je compte les verbes conjugués : **songez**, **s''agit**, **est**. Trois verbes,
donc trois propositions.*

> **« Songez bien »** : proposition **principale**. Le verbe est à l''impératif.
>
> **« qu''il s''agit de sa vie »** : proposition subordonnée **conjonctive
> complétive**, introduite par la conjonction *que*. Fonction : **complément
> d''objet direct du verbe « songez »**.
>
> *Preuve par le remplacement : « songez bien à cette réalité ».*
>
> **« que ce n''est pas à moi d''en répondre aujourd''hui »** : proposition
> subordonnée **conjonctive complétive** également, coordonnée à la précédente
> par « et ». Même fonction : **complément d''objet direct du verbe « songez »**.
>
> *Les deux complétives dépendent du même verbe. C''est une coordination de
> subordonnées, et il faut le dire : beaucoup de candidats n''analysent que la
> première et perdent la moitié du point.*
>
> *Dernière remarque : « sans doute » n''est pas une proposition mais un
> **modalisateur** — tu viens de l''étudier au chapitre 21. Il marque ici une
> certitude moyenne, et il est d''ailleurs ironique dans la bouche de Pyrrhus,
> qui est seul responsable de la vie de l''enfant.*

---

**Barème récapitulatif**

> Partie I — 5 questions à 2 points = **10 points**
> Partie II — 5 questions à 2 points = **10 points**
> **Total : 20 points**

*Dans chaque question, un point pour l''idée et un point pour la justification.
Sur un texte de théâtre, la justification est presque toujours un numéro de
vers : cite-le entre parenthèses, comme tu citerais une ligne.*
', NULL, 34),
    (v_chapitre_id, 'Quiz du chapitre 22', 9, 'quiz', '{
  "titre": "Vérifie que tu as compris",
  "questions": [
    {
      "question": "Quelles sont les trois unités du théâtre classique ?",
      "choix": [
        "Début, milieu, fin",
        "Action, temps, lieu : une seule intrigue, vingt-quatre heures au plus, un seul décor",
        "Acte, scène, réplique",
        "Thèse, antithèse, synthèse"
      ],
      "bonne": 1,
      "explication": "Elles servent la vraisemblance — et elles augmentent la tension au lieu de l''appauvrir : en vingt-quatre heures, les personnages n''ont le temps de rien, ils doivent décider maintenant."
    },
    {
      "question": "Pourquoi les meurtres ne sont-ils pas montrés sur scène ?",
      "choix": [
        "Par manque de moyens",
        "À cause de la règle de bienséance — et il faut donc les RACONTER, ce qui a produit le « récit », souvent le plus beau passage de la pièce",
        "Parce que c''est trop long",
        "Parce que les acteurs refusaient"
      ],
      "bonne": 1,
      "explication": "L''interdiction a produit un art : puisqu''on ne peut pas montrer, il faut faire voir avec des mots."
    },
    {
      "question": "Quelle est la chaîne des amours dans Andromaque ?",
      "choix": [
        "Tout le monde s''aime",
        "Oreste aime Hermione, qui aime Pyrrhus, qui aime Andromaque, qui aime Hector — mort",
        "Deux couples heureux",
        "Personne n''aime personne"
      ],
      "bonne": 1,
      "explication": "Chacun aime celui qui ne l''aime pas, et le dernier maillon ne mène nulle part. Personne ne peut être heureux, et ce n''est la faute de personne : c''est le tragique au sens strict."
    },
    {
      "question": "En quoi la situation d''Andromaque est-elle un dilemme et non un choix difficile ?",
      "choix": [
        "Parce qu''elle hésite",
        "Parce que les deux issues sont également inacceptables : épouser Pyrrhus trahit Hector, refuser tue son fils — aucun des deux devoirs n''est négociable",
        "Parce qu''elle manque de temps",
        "Parce qu''elle est captive"
      ],
      "bonne": 1,
      "explication": "Et sa solution — épouser puis mourir — n''est ni un compromis ni une ruse : c''est un sacrifice qui honore les deux obligations à la fois."
    },
    {
      "question": "Qu''est-ce qu''une stichomythie, et que marque-t-elle ?",
      "choix": [
        "Une longue réplique",
        "Un échange de répliques très courtes, souvent d''un vers chacune : elle marque l''affrontement et accélère le rythme",
        "Une indication scénique",
        "Un personnage seul en scène"
      ],
      "bonne": 1,
      "explication": "Si une scène passe de la tirade à la stichomythie, l''auteur a accéléré — et le signaler est une analyse, pas un simple relevé."
    },
    {
      "question": "Combien de syllabes compte un alexandrin, et où tombe sa pause ?",
      "choix": [
        "Dix syllabes, pause au milieu",
        "Douze syllabes, coupées en deux moitiés de six par la césure",
        "Huit syllabes, sans pause",
        "Quatorze syllabes"
      ],
      "bonne": 1,
      "explication": "Et attention en comptant : le e muet se prononce à l''intérieur du vers devant une consonne, et certains mots se disent en diérèse — « passion » compte trois syllabes."
    },
    {
      "question": "En quoi la fin d''Andromaque est-elle ironique ?",
      "choix": [
        "Elle est drôle",
        "Les résultats sont l''inverse des intentions : les trois qui agissent pour leur bonheur le perdent, et la seule qui n''agit que par devoir survit et règne",
        "Elle est heureuse",
        "Elle est racontée deux fois"
      ],
      "bonne": 1,
      "explication": "Racine ne l''énonce nulle part : aucun personnage ne vient expliquer la leçon. Dans une tragédie réussie, le sens est produit par la structure."
    }
  ]
}', NULL, 5);

  RAISE NOTICE '9 leçons ajoutées au chapitre 22, Lecture méthodique et lecture suivie : la tragédie classique.';
END $fr3$;
