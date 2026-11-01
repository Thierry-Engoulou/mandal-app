-- ---------------------------------------------------------------------------
-- M'Andal — Philosophie, classes de Terminale
-- Chapitre 1 : La philosophie africaine
-- Module 1 : La philosophie — 11 leçons
--
-- Ce fichier remplit les deux séries d'un coup : la Terminale C et la
-- Terminale D. Il n'a besoin de rien d'autre pour tourner. Si la matière, les
-- classes, les programmes ou le chapitre n'existent pas encore, il les crée
-- lui-même au passage.
--
-- Lancez-le quand vous voulez, dans l'ordre que vous voulez, et autant de fois
-- que vous voulez : quand le chapitre a déjà ses leçons, le script s'en rend
-- compte et n'ajoute rien.
-- ---------------------------------------------------------------------------
DO $philo$
DECLARE
  v_lettres text[] := ARRAY['C', 'D'];
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
  -- La matière Philosophie : on ne la crée qu'une fois pour toutes.
  INSERT INTO public.matieres (nom) VALUES ('Philosophie') ON CONFLICT (nom) DO NOTHING;
  SELECT id INTO v_matiere_id FROM public.matieres WHERE nom = 'Philosophie';

  -- L'établissement, on le retrouve à partir des classes déjà en base.
  SELECT count(DISTINCT etablissement_id) INTO v_nb_etabs FROM public.classes;
  IF v_nb_etabs <> 1 THEN
    RAISE EXCEPTION 'Je ne sais pas à quel établissement rattacher ces classes : j''en trouve % dans la table des classes, et il m''en faudrait exactement un.', v_nb_etabs;
  END IF;
  SELECT etablissement_id INTO v_etab_id FROM public.classes LIMIT 1;

  -- On refait le même travail deux fois : pour la Terminale C, puis pour la D.
  FOR v_i IN 1..2 LOOP
    v_lettre := v_lettres[v_i];
    v_nom := 'Terminale ' || v_lettre;

    -- Le programme de Philosophie de cette série existe-t-il déjà ?
    SELECT p.id INTO v_programme_id FROM public.programmes p
    WHERE p.titre = 'Philosophie — ' || v_nom;

    -- Non : on le crée, et la classe avec si besoin.
    IF v_programme_id IS NULL THEN
      -- La classe a pu être écrite de plusieurs façons : Terminale C, Tle C, TC.
      SELECT id INTO v_classe_id FROM public.classes
      WHERE etablissement_id = v_etab_id
        AND (nom = v_nom OR nom ILIKE 'T%le ' || v_lettre OR nom ILIKE 'Terminale ' || v_lettre)
      ORDER BY (nom = v_nom) DESC
      LIMIT 1;

      IF v_classe_id IS NULL THEN
        INSERT INTO public.classes (etablissement_id, nom, niveau, filiere)
        VALUES (v_etab_id, v_nom, 'Terminale', v_lettre)
        RETURNING id INTO v_classe_id;
        RAISE NOTICE 'La classe % n''existait pas : je viens de la créer.', v_nom;
      END IF;

      INSERT INTO public.programmes (matiere_id, classe_id, etablissement_id, titre, description)
      VALUES (v_matiere_id, v_classe_id, v_etab_id, 'Philosophie — ' || v_nom,
              'Programme officiel de Philosophie, classe de Terminale ' || v_lettre ||
              ' (Cameroun) — 1 module, 13 chapitres.')
      RETURNING id INTO v_programme_id;
      RAISE NOTICE 'Programme de Philosophie de la % : créé.', v_nom;
    END IF;

    -- Le chapitre lui-même.
    SELECT id INTO v_chapitre_id FROM public.chapitres
    WHERE programme_id = v_programme_id AND ordre = 1;

    IF v_chapitre_id IS NULL THEN
      INSERT INTO public.chapitres (programme_id, titre, ordre, niveau)
      VALUES (v_programme_id, 'La philosophie africaine', 1, 'Module 1 : La philosophie')
      RETURNING id INTO v_chapitre_id;
      RAISE NOTICE '% : chapitre 1 créé.', v_nom;
    END IF;

    -- Les leçons. Si le chapitre en a déjà, on passe son tour sans rien toucher.
    SELECT count(*) INTO v_deja FROM public.concepts WHERE chapitre_id = v_chapitre_id;
    IF v_deja > 0 THEN
      RAISE NOTICE '% : le chapitre 1 a déjà ses % leçons, je n''y touche pas.', v_nom, v_deja;
      CONTINUE;
    END IF;

    INSERT INTO public.concepts
      (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes) VALUES
      (v_chapitre_id, 'De quoi parle-t-on quand on demande s''il existe une philosophie africaine ?', 1, 'texte', '
Une année de philosophie s''ouvre, au Cameroun, sur une question qui ne se pose
nulle part ailleurs dans les mêmes termes : **l''Afrique a-t-elle une
philosophie ?**

Elle peut sembler offensante. Elle l''est. Mais elle a été posée, sérieusement,
par des philosophes européens respectés, et c''est en y répondant que la
philosophie africaine contemporaine est née. Commençons donc par comprendre ce
qui est demandé.

### Les trois mots du problème

**La philosophie.** Du grec *philo*, aimer, et *sophia*, la sagesse : l''amour
de la sagesse. Mais la définition qui fait problème ici est plus étroite : la
philosophie est un **discours rationnel, critique et argumenté** sur les
questions fondamentales de l''existence. Trois caractères, et il faut les
retenir, car toute la querelle tient à eux.

Elle est **rationnelle** : elle procède par raisons, non par révélation ni par
autorité.

Elle est **critique** : elle examine ses propres fondements et n''épargne aucune
croyance, pas même les siennes.

Elle est **argumentée** : elle est portée par un sujet qui soutient une thèse
et accepte d''en répondre.

**La sagesse.** Un ensemble de maximes, de proverbes, de règles de vie
transmises par une communauté. Elle dit comment vivre, mais elle ne se discute
pas : elle s''hérite.

**La vision du monde.** La manière dont un peuple se représente l''univers, la
mort, les ancêtres, la force. Elle est collective, implicite, et personne n''en
est l''auteur.

### Où est le problème

Si la philosophie est le discours rationnel, critique et argumenté d''un
**sujet**, alors une sagesse collective et anonyme n''est pas une philosophie,
si profonde soit-elle. Et si l''on appelle « philosophie africaine » l''ensemble
des proverbes bantous, on a peut-être élargi le mot jusqu''à le vider.

Mais si l''on refuse ce nom à l''Afrique **par principe**, en réservant la
philosophie à la Grèce et à ses héritiers, on ne fait plus de la philosophie :
on fait de l''idéologie.

C''est entre ces deux écueils que se joue tout le chapitre.

### Pourquoi cette question est politique

Elle n''est pas née dans une salle de cours. Elle est née sous la colonisation,
et elle a servi.

Si les Africains ne pensent pas, ils doivent être pensés par d''autres. La
négation de la philosophie africaine a fourni à la domination coloniale sa
justification la plus commode : on ne colonise pas un peuple, on **éduque** un
enfant.

C''est pourquoi les philosophes africains du XXe siècle ont considéré que
répondre à cette question n''était pas un exercice d''école, mais un acte de
libération.

---

**Exercice corrigé**

*Distinguer, en justifiant, ce qui relève de la sagesse et ce qui relève de la
philosophie dans les deux énoncés suivants :*

*a) « Le vieillard assis voit plus loin que le jeune homme debout. »*

*b) « Je pense, donc je suis. »*

**Correction.**

*a)* C''est un **proverbe**, donc une **sagesse**. Trois signes le montrent.

Il est **anonyme** : nul ne le signe, il appartient à la communauté qui le
transmet. Il est **affirmé sans preuve** : il énonce un rapport entre l''âge et
la clairvoyance sans l''établir. Et il **ne se discute pas** : on le cite pour
clore une discussion, non pour l''ouvrir.

*b)* C''est une **proposition philosophique**. Elle est **signée** — Descartes,
dans le *Discours de la méthode* —, elle est le **résultat d''un raisonnement**
— le doute méthodique a tout emporté sauf l''existence de celui qui doute —, et
elle est **discutable** : des philosophes l''ont contestée, et Descartes savait
qu''ils le feraient.

*Ce qui sépare les deux n''est donc ni la profondeur ni l''origine
géographique : c''est la présence d''un auteur, d''un argument et d''une
possibilité de réfutation.*
', NULL, 26),
      (v_chapitre_id, 'Simulation : sagesse, croyance ou philosophie ?', 2, 'interactif', '{
  "widget": "distinguer-philosophie",
  "consigne": "Douze énoncés défilent — un proverbe camerounais, une maxime de Ptahhotep, un verset, une thèse de Descartes, une formule de Towa — et tu dois dire de quoi il s''agit. La simulation applique à chaque fois les trois critères du cours : y a-t-il un auteur, y a-t-il un argument, l''énoncé peut-il être réfuté ? Tu verras que certains proverbes passent deux critères sur trois, et c''est précisément là que la querelle commence."
}', NULL, 10),
      (v_chapitre_id, 'La thèse ethnocentriste : l''Afrique serait étrangère à la philosophie', 3, 'texte', '
Première thèse du débat, et la plus ancienne. Elle soutient que l''Afrique n''a
pas produit de philosophie, et qu''elle ne le pouvait pas.

### Premier argument : l''Africain serait dépourvu de raison

C''est la forme la plus brutale, et elle vient de philosophes majeurs.

**Hegel**, dans ses *Leçons sur la philosophie de l''histoire*, décrit l''Afrique
noire comme le lieu de « l''homme naturel dans toute sa sauvagerie », et la
place **hors de l''histoire** — c''est-à-dire hors du mouvement par lequel
l''esprit prend conscience de lui-même.

**Lucien Lévy-Bruhl**, dans *Les Fonctions mentales dans les sociétés
inférieures* (1910), forge la notion de **mentalité prélogique** : les
« primitifs » penseraient par participation mystique plutôt que par principe de
non-contradiction.

*À signaler, parce que c''est honnête et que cela fait partie du dossier :
Lévy-Bruhl a lui-même abandonné cette thèse à la fin de sa vie, dans ses*
Carnets *publiés après sa mort. Il y reconnaît que la mentalité prélogique
n''existe pas et que tous les hommes pensent selon la même logique.*

### Deuxième argument : l''Europe aurait le monopole de la philosophie

Ici l''argument n''est plus racial mais historique. La philosophie serait un
évènement grec, et seuls les héritiers de la Grèce pourraient philosopher.

**Martin Heidegger** le formule ainsi : « la philosophie est grecque dans son
être propre ». Et il ajoute que l''expression « philosophie occidentale » est
une **tautologie** — un pléonasme —, puisqu''il n''y en a pas d''autre.

### Troisième argument : l''absence de science prouverait l''absence de philosophie

La science serait née de la philosophie. L''Afrique n''ayant pas développé de
science au sens moderne, elle n''aurait donc pas eu de philosophie.

### Ce qu''il faut voir dans ces trois arguments

Le premier est un **préjugé racial**, et il tombe dès qu''on l''énonce
clairement.

Le deuxième est plus sérieux : il repose sur une définition. Mais une
définition n''est pas une preuve. Dire que la philosophie est grecque par
essence, c''est décider par avance de la réponse à la question posée.

Le troisième confond **antériorité** et **cause**. Que la science soit née
après la philosophie en Grèce ne prouve pas qu''il n''y ait de philosophie que là
où naît une science.

---

**Exercice corrigé**

*« La philosophie est grecque dans son être propre » (Heidegger). Montrer que
cette affirmation, prise comme argument contre l''existence d''une philosophie
africaine, commet une pétition de principe.*

**Correction.**

*Rappel du vice logique.* Une **pétition de principe** consiste à poser dans
les prémisses ce que l''on prétend démontrer dans la conclusion. Le raisonnement
tourne en rond.

*Application.* La question posée est : existe-t-il une philosophie hors de la
Grèce et de ses héritiers ? Heidegger répond en **définissant** la philosophie
comme grecque par essence. Mais cette définition est exactement ce qu''il
fallait établir.

Le raisonnement revient à dire : « la philosophie est grecque ; or la pensée
africaine n''est pas grecque ; donc la pensée africaine n''est pas de la
philosophie ». La conclusion est contenue dans la première prémisse, et aucune
observation ne vient l''étayer.

*La réfutation.* Pour que l''argument tienne, il faudrait montrer que les
caractères qui font la philosophie — la rationalité, la critique,
l''argumentation — sont **introuvables** hors de la Grèce. C''est une question de
fait, et c''est précisément ce que la thèse adverse va entreprendre de montrer.

*Note pour la copie : nommer le vice logique rapporte toujours des points. On
dira « pétition de principe », ou « cercle vicieux », et on l''explique en une
phrase.*
', NULL, 28),
      (v_chapitre_id, 'Simulation : qui soutient quoi ?', 4, 'interactif', '{
  "widget": "these-auteur-africaine",
  "consigne": "Des thèses défilent, dépouillées du nom de leur auteur, et tu dois les attribuer : Hegel, Lévy-Bruhl, Heidegger, Cheikh Anta Diop, Tempels, Towa, Hountondji, Eboussi Boulaga. Chaque bonne attribution t''ouvre la fiche de l''auteur — son pays, son ouvrage, sa position exacte — et chaque erreur t''explique pourquoi la thèse ne peut pas être de celui que tu as désigné. C''est l''exercice qui rapporte le plus en dissertation : une thèse sans auteur ne vaut presque rien."
}', NULL, 10),
      (v_chapitre_id, 'La thèse africaniste : l''Afrique est apte à philosopher', 5, 'texte', '
Deuxième thèse. Elle soutient que la philosophie n''est le monopole de personne,
et que l''Afrique a pensé.

### Premier argument : la raison est universelle

Si la philosophie est l''exercice de la raison, et si la raison appartient à
tout homme, alors aucun peuple n''en est exclu.

**Descartes** ouvre le *Discours de la méthode* par cette phrase : « Le bon
sens est la chose du monde la mieux partagée. » Il ne parlait pas de l''Afrique,
et c''est ce qui rend la citation forte : l''universalité de la raison est posée
par la tradition européenne elle-même.

**Aristote** définit l''homme comme un **animal raisonnable**. Ou bien les
Africains sont des hommes, et ils sont raisonnables ; ou bien on leur refuse la
raison, et il faut alors leur refuser l''humanité — ce que personne n''ose plus
soutenir.

### Deuxième argument : l''Afrique est le berceau de la philosophie

C''est la thèse de **Cheikh Anta Diop**, l''historien sénégalais, dans *Nations
nègres et culture* (1954) et *Antériorité des civilisations nègres* (1967).

L''Égypte pharaonique est une civilisation africaine. Or les premiers penseurs
grecs y ont séjourné et s''y sont formés : la tradition rapporte le voyage de
Pythagore, de Démocrite et de Platon en Égypte.

Et la chronologie est éloquente : les **Maximes de Ptahhotep**, vizir égyptien,
datent d''environ 2400 avant notre ère. Thalès de Milet, que l''on présente comme
le premier philosophe, vit au VIe siècle avant notre ère. **Dix-huit siècles**
séparent les deux.

*Cette thèse est discutée, et il faut le dire en copie : des historiens
contestent l''ampleur de l''emprunt grec à l''Égypte. Mais l''antériorité
chronologique, elle, n''est pas contestable.*

### Troisième argument : il existe une histoire de la philosophie en Afrique

L''argument le plus solide, parce qu''il procède par faits.

**Dans l''Antiquité**, **Ptahhotep** et ses *Maximes*, en Égypte.

**Au Moyen Âge**, **Ahmed Baba** (1556-1627), savant de Tombouctou, auteur de
dizaines d''ouvrages ; et en Éthiopie **Zera Yacob**, qui écrit en 1667 son
*Hatata*, un traité où il soumet toutes les religions à l''examen de la raison —
à la même époque que Descartes, et sans le connaître. Son disciple **Walda
Heywat** poursuit son œuvre.

**À l''époque moderne**, **Anton Wilhelm Amo**, né vers 1703 sur la Côte-de-l''Or,
l''actuel Ghana, emmené enfant en Allemagne, docteur en philosophie à Wittenberg
en 1734, puis professeur à Halle et à Iéna.

**À l''époque contemporaine**, les noms que vous travaillerez cette année :
**Marcien Towa**, **Ebénézer Njoh Mouelle**, **Fabien Eboussi Boulaga**,
**Hubert Mono Ndjana** et **Nsame Mbongo** — tous camerounais — et le béninois
**Paulin Hountondji**.

### La force de cet argument

Les deux premiers arguments répondent par le droit : l''Afrique **peut**
philosopher. Le troisième répond par le fait : elle **l''a fait**, et voici les
noms, les titres et les dates.

En dissertation, c''est celui-là qu''il faut développer, parce qu''un fait ne se
réfute pas par une définition.

---

**Exercice corrigé**

*Citer trois philosophes africains appartenant à trois époques différentes, et
montrer en quoi leur existence répond à la thèse ethnocentriste.*

**Correction.**

*Trois philosophes, trois époques.*

**Ptahhotep**, vizir égyptien, auteur des *Maximes* vers 2400 avant notre ère :
l''Antiquité.

**Zera Yacob**, Éthiopien, auteur du *Hatata* en 1667 : l''époque classique.

**Marcien Towa**, Camerounais, auteur de l''*Essai sur la problématique
philosophique dans l''Afrique actuelle* en 1971 : l''époque contemporaine.

*En quoi cela répond à la thèse ethnocentriste.*

La thèse ethnocentriste est une **thèse de fait** déguisée en thèse de droit :
elle affirme qu''il n''y a pas eu de philosophie en Afrique. Or une thèse de fait
se réfute par un **contre-exemple**, et il suffit d''un seul.

Le cas de **Zera Yacob** est le plus décisif. Son *Hatata* est un texte écrit,
signé, argumenté, où l''auteur soumet au tribunal de sa raison les croyances de
sa propre société, y compris sa religion. Il répond donc aux trois critères de
la définition : rationnel, critique, argumenté.

Et il ne doit rien à l''Europe : écrit en 1667 par un homme qui n''avait lu ni
Descartes ni Bacon, il montre que la démarche critique peut naître ailleurs
qu''en Grèce, et deux fois plutôt qu''une.
', NULL, 30),
      (v_chapitre_id, 'Figure : la frise de la philosophie africaine', 6, 'figure', '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 580 300" width="580" height="300">
<rect width="580" height="300" fill="#ffffff"/>
<text x="290" y="24" text-anchor="middle" font-size="14" font-weight="700" fill="#0f172a">Une histoire de la philosophie en Afrique</text>
<text x="290" y="42" text-anchor="middle" font-size="10" fill="#64748b">De l&apos;Égypte pharaonique aux universités camerounaises</text>

<line x1="40" y1="150" x2="548" y2="150" stroke="#334155" stroke-width="2.5"/>
<polygon points="556,150 544,144 544,156" fill="#334155"/>

<g font-size="9" fill="#64748b" text-anchor="middle">
<text x="70" y="172">−2400</text>
<text x="170" y="172">−600</text>
<text x="265" y="172">1600</text>
<text x="360" y="172">1734</text>
<text x="450" y="172">1945</text>
<text x="530" y="172">aujourd&apos;hui</text>
</g>
<g stroke="#94a3b8" stroke-width="1.2">
<line x1="70" y1="144" x2="70" y2="156"/>
<line x1="170" y1="144" x2="170" y2="156"/>
<line x1="265" y1="144" x2="265" y2="156"/>
<line x1="360" y1="144" x2="360" y2="156"/>
<line x1="450" y1="144" x2="450" y2="156"/>
</g>

<g>
<line x1="70" y1="144" x2="70" y2="108" stroke="#2563eb" stroke-width="1.4"/>
<rect x="24" y="78" width="92" height="30" rx="4" fill="#dbeafe" stroke="#2563eb" stroke-width="1.4"/>
<text x="70" y="91" text-anchor="middle" font-size="9" font-weight="700" fill="#1e3a8a">Ptahhotep</text>
<text x="70" y="102" text-anchor="middle" font-size="8" fill="#1e40af">Maximes, Égypte</text>
</g>

<g>
<line x1="170" y1="156" x2="170" y2="196" stroke="#64748b" stroke-width="1.4" stroke-dasharray="3 3"/>
<rect x="124" y="196" width="94" height="30" rx="4" fill="#f1f5f9" stroke="#94a3b8" stroke-width="1.2"/>
<text x="171" y="209" text-anchor="middle" font-size="9" font-weight="700" fill="#475569">Thalès, Grèce</text>
<text x="171" y="220" text-anchor="middle" font-size="8" fill="#64748b">« naissance » admise</text>
</g>

<g>
<line x1="265" y1="144" x2="265" y2="108" stroke="#15803d" stroke-width="1.4"/>
<rect x="216" y="70" width="98" height="38" rx="4" fill="#dcfce7" stroke="#15803d" stroke-width="1.4"/>
<text x="265" y="83" text-anchor="middle" font-size="9" font-weight="700" fill="#14532d">Zera Yacob</text>
<text x="265" y="94" text-anchor="middle" font-size="8" fill="#166534">Hatata, Éthiopie</text>
<text x="265" y="104" text-anchor="middle" font-size="8" fill="#166534">Ahmed Baba, Tombouctou</text>
</g>

<g>
<line x1="360" y1="156" x2="360" y2="196" stroke="#ca8a04" stroke-width="1.4"/>
<rect x="312" y="196" width="98" height="30" rx="4" fill="#fef3c7" stroke="#ca8a04" stroke-width="1.4"/>
<text x="361" y="209" text-anchor="middle" font-size="9" font-weight="700" fill="#78350f">Anton W. Amo</text>
<text x="361" y="220" text-anchor="middle" font-size="8" fill="#92400e">Halle et Iéna</text>
</g>

<g>
<line x1="450" y1="144" x2="450" y2="104" stroke="#b91c1c" stroke-width="1.4"/>
<rect x="400" y="66" width="102" height="38" rx="4" fill="#fee2e2" stroke="#b91c1c" stroke-width="1.4"/>
<text x="451" y="79" text-anchor="middle" font-size="9" font-weight="700" fill="#7f1d1d">Tempels, Kagame</text>
<text x="451" y="90" text-anchor="middle" font-size="8" fill="#991b1b">l&apos;ethnophilosophie</text>
<text x="451" y="100" text-anchor="middle" font-size="8" fill="#991b1b">et la querelle</text>
</g>

<g>
<line x1="516" y1="156" x2="516" y2="196" stroke="#7c3aed" stroke-width="1.4"/>
<rect x="452" y="196" width="112" height="48" rx="4" fill="#ede9fe" stroke="#7c3aed" stroke-width="1.4"/>
<text x="508" y="209" text-anchor="middle" font-size="9" font-weight="700" fill="#4c1d95">Towa, Hountondji</text>
<text x="508" y="220" text-anchor="middle" font-size="8" fill="#5b21b6">Eboussi Boulaga</text>
<text x="508" y="230" text-anchor="middle" font-size="8" fill="#5b21b6">Njoh Mouelle</text>
<text x="508" y="240" text-anchor="middle" font-size="8" fill="#5b21b6">Mono Ndjana</text>
</g>

<text x="290" y="272" text-anchor="middle" font-size="10" fill="#334155">Entre les Maximes de Ptahhotep et Thalès, il y a près de dix-huit siècles.</text>
<text x="290" y="288" text-anchor="middle" font-size="10" font-weight="700" fill="#0f172a">C&apos;est l&apos;argument que Cheikh Anta Diop oppose à l&apos;idée d&apos;un « miracle grec ».</text>
</svg>', NULL, 5),
      (v_chapitre_id, 'Simulation : la frise des philosophes africains', 7, 'interactif', '{
  "widget": "frise-philo-africaine",
  "consigne": "Une frise vide s''étend de l''Égypte pharaonique à aujourd''hui, et une liste de philosophes attend d''y être placée. Pose chacun à sa date : Ptahhotep, Ahmed Baba, Zera Yacob, Amo, Tempels, Kagame, Towa, Hountondji, Eboussi Boulaga, Njoh Mouelle. Chaque nom bien placé affiche son pays, son ouvrage et sa thèse en une phrase. La simulation fait ensuite apparaître Thalès sur la même frise, et tu mesures toi-même l''écart avec Ptahhotep."
}', NULL, 10),
      (v_chapitre_id, 'La querelle de l''ethnophilosophie', 8, 'texte', '
Nous arrivons au cœur du chapitre. Une fois admis que l''Afrique peut penser,
une seconde question se lève, et elle divise les philosophes africains entre
eux : **où faut-il chercher cette philosophie ?**

### Le point de départ : Tempels

En 1945, le missionnaire belge **Placide Tempels** publie *La Philosophie
bantoue*. Il y soutient que les peuples bantous possèdent une **ontologie**
cohérente, organisée autour d''une notion centrale : la **force vitale**. Chez
eux, être, c''est être force ; et toute l''organisation du monde, des ancêtres
aux vivants, s''explique par les rapports entre ces forces.

Le livre fait l''effet d''une bombe. Pour la première fois, un Européen affirme
que les Africains ont une philosophie.

### Le prolongement : Kagame

Le prêtre rwandais **Alexis Kagame** reprend la démarche dans *La Philosophie
bantu-rwandaise de l''Être* (1956), mais avec un outil nouveau : la **langue**.
Il montre que le kinyarwanda organise tout le réel en quatre catégories —
*muntu*, l''être doué d''intelligence ; *kintu*, la chose ; *hantu*, le lieu et
le temps ; *kuntu*, la modalité. Il y voit l''équivalent bantou des catégories
d''Aristote.

### La critique : Towa et Hountondji

C''est ici que la querelle éclate, et elle vient des Africains eux-mêmes.

**Marcien Towa**, le philosophe camerounais, publie en 1971 son *Essai sur la
problématique philosophique dans l''Afrique actuelle*. Sa critique tient en
trois coups.

**Premier coup : la méthode est viciée.** Tempels et ses successeurs ne
cherchent pas une philosophie, ils **veulent** en trouver une. Le résultat est
acquis avant l''enquête, et il ne tient qu''à un déplacement de vocabulaire : on
appelle « ontologie » ce qu''on appelait « coutume ».

**Deuxième coup : il n''y a pas de sujet.** Une philosophie suppose quelqu''un
qui la soutienne et qui en réponde. Une vision du monde collective et anonyme
n''a personne à qui l''on puisse demander des comptes. Or la discussion est la
vie même de la philosophie.

**Troisième coup, et c''est le plus profond : la vraie philosophie commence par
la remise en question de l''héritage.** Chercher sa philosophie dans sa
tradition, c''est faire exactement le contraire de philosopher. Towa l''écrit :
la philosophie commence par **remettre en question tout héritage culturel et
philosophique**.

Le béninois **Paulin Hountondji** va dans le même sens dans *Sur la
« philosophie africaine ». Critique de l''ethnophilosophie* (1976). Il propose
une définition volontairement sobre : la philosophie africaine, c''est
**l''ensemble des textes écrits par des Africains et que leurs auteurs
qualifient eux-mêmes de philosophiques**. Et il dénonce l''**unanimisme** —
l''illusion que tous les Africains penseraient la même chose.

### La troisième voie : Eboussi Boulaga

Le camerounais **Fabien Eboussi Boulaga**, dans *La crise du Muntu.
Authenticité africaine et philosophie* (1977), refuse les deux camps.

L''ethnophilosophie enferme l''Africain dans un passé figé. Mais la critique de
Towa et Hountondji risque de ne lui laisser qu''une chose à faire : répéter
l''Occident. Entre les deux, Eboussi Boulaga cherche une parole propre, qui ne
soit ni un musée ni une copie.

### Et au Cameroun

**Ebénézer Njoh Mouelle**, dans *De la médiocrité à l''excellence* (1970), pose
la question du développement comme une question philosophique : il s''agit pour
l''homme africain de refuser la médiocrité et de se vouloir excellent. Ce livre
est au programme, et il revient régulièrement à l''épreuve.

**Hubert Mono Ndjana** a écrit l''histoire de cette philosophie africaine, et
**Nsame Mbongo** en a poursuivi le travail critique.

### La synthèse à retenir

Les deux camps ont raison contre quelque chose.

L''ethnophilosophie a raison contre **l''ethnocentrisme** : il y a bien une
pensée africaine, et elle mérite d''être étudiée.

Ses critiques ont raison contre **la complaisance** : appeler philosophie tout
ce qui se pense en Afrique, c''est renoncer à l''exigence qui fait la
philosophie.

Et l''existence même de cette querelle règle la question initiale. **Un débat
rigoureux, écrit, signé, argumenté, entre Africains, sur la nature de la
philosophie : voilà de la philosophie africaine.** Elle ne se prouve pas en
exhibant des proverbes ; elle se prouve en se faisant.

---

**Exercice corrigé**

*Qu''est-ce que l''ethnophilosophie ? Exposer la critique que Marcien Towa lui
adresse, puis montrer la limite de cette critique.*

**Correction.**

*Définition.* L''**ethnophilosophie** est la démarche qui cherche la philosophie
d''un peuple africain dans sa **culture collective** — ses proverbes, ses mythes,
sa langue, ses rites — et qui la reconstitue comme un système cohérent.
Placide Tempels l''inaugure avec *La Philosophie bantoue* (1945) ; Alexis Kagame
la prolonge par l''analyse du kinyarwanda (1956).

*La critique de Towa*, dans l''*Essai sur la problématique philosophique dans
l''Afrique actuelle* (1971), tient en trois points.

La **méthode** est viciée : la conclusion précède l''enquête, et le résultat
n''est obtenu qu''en rebaptisant des faits de culture avec des mots de
philosophie.

Il n''y a **pas de sujet** : une vision du monde anonyme ne peut être discutée,
puisque personne ne la soutient. Or la philosophie vit de la discussion.

Enfin, la démarche est **contradictoire avec la philosophie elle-même** :
philosopher, c''est remettre en question son héritage, et l''ethnophilosophie
consiste à le célébrer.

*La limite de cette critique.* En refusant toute valeur philosophique aux
traditions, Towa risque de laisser l''Afrique sans autre ressource que
l''imitation de l''Occident : si la seule philosophie est celle qui rompt avec
l''héritage, et si le seul modèle disponible est européen, la libération se
retourne en dépendance.

C''est l''objection de **Fabien Eboussi Boulaga** dans *La crise du Muntu*
(1977) : il faut une parole qui ne soit ni la répétition du passé, ni la copie
de l''autre.

*Transition possible vers une troisième partie : et si la philosophie africaine
n''était ni dans la tradition ni dans l''imitation, mais dans ce débat même ?*
', NULL, 32),
      (v_chapitre_id, 'Simulation : classer les auteurs par courant', 9, 'interactif', '{
  "widget": "courants-philo-africaine",
  "consigne": "Trois colonnes t''attendent : ethnophilosophie, critique de l''ethnophilosophie, troisième voie. Place les auteurs, puis leurs ouvrages, puis leurs thèses. La simulation refuse de mettre Towa et Tempels dans la même colonne et t''explique pourquoi. Un second volet te fait jouer la querelle : tu choisis un camp, la simulation te sert l''objection adverse, et tu dois y répondre en choisissant le bon argument — c''est exactement le mouvement d''une dissertation."
}', NULL, 10),
      (v_chapitre_id, 'Sujet type Baccalauréat — Existe-t-il une philosophie africaine ?', 10, 'texte', '
**Deuxième partie de l''épreuve — Évaluation de l''agir compétent — 9 points**

*En te fondant sur ta culture philosophique et dans le respect des règles de la
logique, est-il légitime de penser qu''il n''existe pas de philosophie
africaine ?*

*Consigne : rédiger une dissertation de deux pages au plus. Première tâche, la
thèse (3 points). Deuxième tâche, l''antithèse (3 points). Troisième tâche, la
synthèse (3 points).*

---
---

## Corrigé

### I. Analyse et compréhension du sujet

**A. Les concepts-clés.**

*Philosophie* : discours rationnel, critique et argumenté sur les questions
fondamentales de l''existence, porté par un auteur identifiable.

*Africaine* : qui appartient à l''Afrique, par son origine, son objet ou son
auteur. Le mot est ambigu, et cette ambiguïté est au cœur du sujet.

*Légitime* : fondé en raison, et non simplement répandu ou commode.

**B. Reformulation.** A-t-on de bonnes raisons de soutenir que l''Afrique n''a
produit aucun discours philosophique ?

**C. Le présupposé.** Le sujet suppose que la philosophie pourrait être le
privilège d''une aire culturelle, et donc qu''elle aurait une patrie.

**D. La thèse opposée.** Il existe bien une philosophie africaine.

**E. Le problème philosophique.** L''universalité de la philosophie.

**F. La problématique.** La philosophie est-elle un évènement grec que l''Afrique
n''aurait pas connu, ou bien un exercice de la raison dont aucun peuple n''est
exclu ? Et si l''Afrique a philosophé, où faut-il chercher cette philosophie :
dans ses traditions, ou dans les œuvres signées de ses penseurs ?

### II. Première tâche — la thèse : il n''existerait pas de philosophie africaine *(3 points)*

**Argument 1.** La philosophie serait un évènement historique localisé. Née en
Grèce au VIe siècle avant notre ère, elle y aurait rompu avec le mythe pour la
première fois. **Heidegger** le soutient : « la philosophie est grecque dans son
être propre », et l''expression « philosophie occidentale » est pour lui une
tautologie.

**Argument 2.** Ce qu''on appelle pensée africaine relèverait de la **sagesse**,
non de la philosophie. Proverbes, mythes et rites sont anonymes, hérités et
soustraits à la discussion. Il leur manque les trois caractères du discours
philosophique : l''auteur, l''argument, la réfutabilité.

**Argument 3.** Les Africains eux-mêmes l''ont reconnu. **Marcien Towa**, dans
l''*Essai sur la problématique philosophique dans l''Afrique actuelle* (1971), et
**Paulin Hountondji**, dans *Sur la « philosophie africaine »* (1976),
démontrent que l''ethnophilosophie de Tempels et de Kagame ne tient pas : elle
rebaptise la coutume en ontologie et conclut avant d''enquêter.

*Transition.* Mais cette thèse ne confond-elle pas l''absence d''une certaine
forme de philosophie avec l''absence de toute philosophie ?

### III. Deuxième tâche — l''antithèse : il existe une philosophie africaine *(3 points)*

**Argument 1.** La raison est universelle. **Descartes** ouvre le *Discours de
la méthode* en affirmant que « le bon sens est la chose du monde la mieux
partagée », et **Aristote** définit l''homme comme un animal raisonnable. Refuser
la raison à un peuple, c''est lui refuser l''humanité.

**Argument 2.** L''Afrique est antérieure à la Grèce. **Cheikh Anta Diop**, dans
*Nations nègres et culture* (1954), rappelle que l''Égypte pharaonique est
africaine et que les premiers penseurs grecs s''y sont formés. Les *Maximes de
Ptahhotep* précèdent Thalès de dix-huit siècles.

**Argument 3, et c''est le plus fort.** Il existe des œuvres. **Zera Yacob**
écrit son *Hatata* en Éthiopie en 1667 : un texte signé, argumenté, où l''auteur
soumet les religions à l''examen de sa raison, à l''époque de Descartes et sans
l''avoir lu. **Anton Wilhelm Amo**, né vers 1703 en pays nzema, enseigne la
philosophie à Halle et à Iéna. Et le XXe siècle donne **Towa**, **Njoh
Mouelle**, **Eboussi Boulaga**, **Mono Ndjana**, **Hountondji**.

Une thèse de fait se réfute par un contre-exemple, et il en faut un seul.

*Transition.* Faut-il alors choisir entre les deux camps, ou bien la querelle
elle-même nous apprend-elle quelque chose ?

### IV. Troisième tâche — la synthèse *(3 points)*

**Premier moment : chaque thèse a raison contre quelque chose.**

La première a raison contre la **complaisance** : appeler philosophie tout ce
qui se pense en Afrique, c''est renoncer à l''exigence qui définit la
philosophie, et rendre un mauvais service à l''Afrique.

La seconde a raison contre l''**ethnocentrisme** : réserver la philosophie à une
aire culturelle, c''est décider par définition ce qu''il fallait établir par
enquête — une pétition de principe.

**Deuxième moment : le départage.** Il faut distinguer deux sens du mot
« africaine ». Au sens d''une **vision du monde collective**, la pensée
traditionnelle africaine n''est pas une philosophie, et Towa a raison. Au sens
des **œuvres produites par des philosophes africains**, la philosophie
africaine existe, et Hountondji en donne le critère : les textes écrits par des
Africains et que leurs auteurs tiennent pour philosophiques.

**Troisième moment : la réponse.** La preuve la plus solide n''est pas dans un
corpus mais dans un acte. Tempels, Kagame, Towa, Hountondji et Eboussi Boulaga
ont mené, par écrit, sous leur nom, une discussion rigoureuse sur la nature de
la philosophie. **Cette querelle est elle-même un exercice philosophique.** La
philosophie africaine ne se prouve donc pas en exhibant des proverbes : elle se
prouve en se faisant, et elle s''est faite.

**Conclusion.** Il n''est pas légitime de penser qu''il n''existe pas de
philosophie africaine. Cette thèse repose sur une définition arbitraire de la
philosophie et se trouve démentie par des œuvres datées et signées. Reste
qu''elle aura eu une vertu : en obligeant les penseurs africains à dire ce
qu''ils entendaient par philosopher, elle aura provoqué la philosophie africaine
contemporaine.

---

### Ce que le correcteur attend

**Des noms, des titres, des dates.** Une dissertation de philosophie sans
auteur est une dissertation sans preuve. Ici, Heidegger, Towa, Hountondji,
Diop, Zera Yacob et Tempels suffisent.

**Une transition entre chaque tâche.** Elle vaut des points et prend une
phrase : elle pose la question à laquelle la tâche suivante répondra.

**Une synthèse qui ne soit pas un compromis mou.** « Les deux thèses ont du
vrai » ne vaut rien. Il faut dire **sur quoi** chacune a raison, puis
**trancher**.
', NULL, 36),
      (v_chapitre_id, 'Quiz du chapitre 1', 11, 'quiz', '{
  "titre": "Vérifie que tu as compris",
  "questions": [
    {
      "question": "Quels sont les trois caractères qui définissent le discours philosophique ?",
      "choix": [
        "Ancien, écrit et respecté",
        "Rationnel, critique et argumenté",
        "Grec, latin et européen",
        "Oral, collectif et traditionnel"
      ],
      "bonne": 1,
      "explication": "Toute la querelle de la philosophie africaine tient à ces trois mots. Un proverbe peut être profond sans être philosophique : il lui manque l''auteur, l''argument et la possibilité d''être réfuté."
    },
    {
      "question": "Qui écrit que « la philosophie est grecque dans son être propre » ?",
      "choix": [
        "Hegel",
        "Martin Heidegger",
        "Lucien Lévy-Bruhl",
        "Placide Tempels"
      ],
      "bonne": 1,
      "explication": "Heidegger ajoute que « philosophie occidentale » est une tautologie. L''argument commet une pétition de principe : il pose dans la définition ce qu''il faudrait démontrer."
    },
    {
      "question": "Qu''est-ce que l''ethnophilosophie ?",
      "choix": [
        "L''étude des ethnies africaines",
        "La démarche qui cherche la philosophie d''un peuple dans sa culture collective — proverbes, mythes, langue, rites",
        "La philosophie enseignée dans les écoles africaines",
        "Le refus de toute philosophie africaine"
      ],
      "bonne": 1,
      "explication": "Placide Tempels l''inaugure avec La Philosophie bantoue en 1945, Alexis Kagame la prolonge par l''analyse du kinyarwanda en 1956."
    },
    {
      "question": "Quelle est la critique centrale que Marcien Towa adresse à l''ethnophilosophie ?",
      "choix": [
        "Elle est écrite par des Européens",
        "Elle cherche la philosophie dans l''héritage, alors que philosopher commence par remettre cet héritage en question",
        "Elle est trop difficile pour les élèves",
        "Elle ignore la Grèce"
      ],
      "bonne": 1,
      "explication": "Towa ajoute deux autres coups : la méthode conclut avant d''enquêter, et une vision du monde anonyme n''a aucun sujet à qui demander des comptes."
    },
    {
      "question": "Quel philosophe éthiopien écrit en 1667 un traité où il soumet les religions à l''examen de sa raison ?",
      "choix": [
        "Ahmed Baba",
        "Zera Yacob, dans le Hatata",
        "Anton Wilhelm Amo",
        "Ptahhotep"
      ],
      "bonne": 1,
      "explication": "C''est le contre-exemple le plus décisif : un texte signé, argumenté, critique, écrit à l''époque de Descartes et sans l''avoir lu."
    },
    {
      "question": "Quel écart sépare les Maximes de Ptahhotep de Thalès de Milet ?",
      "choix": [
        "Un siècle",
        "Environ dix-huit siècles",
        "Cinquante ans",
        "Ils sont contemporains"
      ],
      "bonne": 1,
      "explication": "Vers 2400 avant notre ère pour Ptahhotep, VIe siècle avant notre ère pour Thalès. C''est l''argument chronologique de Cheikh Anta Diop contre l''idée d''un « miracle grec »."
    },
    {
      "question": "Quelle définition Paulin Hountondji donne-t-il de la philosophie africaine ?",
      "choix": [
        "La sagesse des anciens",
        "L''ensemble des textes écrits par des Africains et que leurs auteurs qualifient eux-mêmes de philosophiques",
        "La pensée des peuples bantous",
        "La philosophie enseignée en Afrique"
      ],
      "bonne": 1,
      "explication": "Une définition volontairement sobre, qui écarte l''unanimisme — l''illusion que tous les Africains penseraient la même chose."
    },
    {
      "question": "Quel philosophe camerounais cherche, dans La crise du Muntu, une voie entre l''ethnophilosophie et sa critique ?",
      "choix": [
        "Marcien Towa",
        "Fabien Eboussi Boulaga",
        "Ebénézer Njoh Mouelle",
        "Hubert Mono Ndjana"
      ],
      "bonne": 1,
      "explication": "Son objection : l''ethnophilosophie enferme l''Africain dans un passé figé, mais la critique radicale risque de ne lui laisser que l''imitation de l''Occident."
    }
  ]
}', NULL, 5);

    RAISE NOTICE '% : 11 leçons ajoutées au chapitre 1, La philosophie africaine.', v_nom;
  END LOOP;
END $philo$;
