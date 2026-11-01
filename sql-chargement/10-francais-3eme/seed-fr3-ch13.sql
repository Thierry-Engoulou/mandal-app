-- ---------------------------------------------------------------------------
-- M'Andal — Français, classe de 3ème
-- Chapitre 13 : Dénotation et connotation
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
  WHERE programme_id = v_programme_id AND ordre = 13;

  IF v_chapitre_id IS NULL THEN
    INSERT INTO public.chapitres (programme_id, titre, ordre, niveau)
    VALUES (v_programme_id, 'Dénotation et connotation', 13, 'Module 2 : Citoyenneté et environnement')
    RETURNING id INTO v_chapitre_id;
    RAISE NOTICE 'Chapitre 13 créé.';
  END IF;

  -- Les leçons. Si le chapitre en a déjà, on passe son tour sans rien toucher.
  SELECT count(*) INTO v_deja FROM public.concepts WHERE chapitre_id = v_chapitre_id;
  IF v_deja > 0 THEN
    RAISE NOTICE 'Le chapitre 13 a déjà ses % leçons, je n''y touche pas.', v_deja;
    RETURN;
  END IF;

  INSERT INTO public.concepts
    (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes) VALUES
    (v_chapitre_id, 'Dénotation et connotation : ce que le mot dit, et ce qu''il traîne', 1, 'texte', '
Ce chapitre prépare la **question 1** du BEPC — expliquer le sens d''un ou deux
mots — et il vaut **deux points**. Mais il sert surtout à autre chose : il
t''apprend à voir que **le choix d''un mot est déjà un argument**.

### Deux sens dans un seul mot

**La dénotation** est le sens que donne le dictionnaire. C''est le sens neutre,
objectif, que tout le monde reconnaît.

> *serpent* : reptile sans pattes, au corps allongé.

Personne ne conteste cela. C''est la définition.

**La connotation** est ce que le mot traîne avec lui : les images, les
jugements, les émotions qu''il réveille chez celui qui l''entend.

> *serpent* : la traîtrise, le danger, la ruse, le mal.

> « Méfie-toi de lui, c''est un serpent. »

Je n''ai pas voulu dire que cet homme est un reptile. J''ai employé la
connotation.

### La connotation dépend de la culture

Et c''est important à comprendre dans un pays comme le nôtre.

Le mot **panthère** connote en Europe la beauté dangereuse. Au Cameroun, il
connote aussi le pouvoir, la royauté, le chef — pensez aux insignes
traditionnels des chefferies de l''Ouest.

Le mot **blanc** connote la pureté en Europe, et le deuil dans plusieurs
cultures d''Asie.

Le mot **vieux** connote l''usure en français de France, mais le respect dans
beaucoup de nos langues : « le vieux » y désigne celui qui sait.

Un mot ne voyage donc jamais seul : il emporte avec lui la culture de ceux qui
l''emploient.

### Les trois valeurs

Pour l''examen, tu dois savoir ranger une connotation dans l''une de ces trois
cases.

**Méliorative** : le mot valorise, il donne une image positive.

> une *demeure*, un *parfum*, une *silhouette*, la *fermeté*

**Péjorative** : le mot dévalorise, il donne une image négative.

> une *bicoque*, une *odeur*, une *carcasse*, l''*entêtement*

**Neutre** : le mot décrit sans juger.

> une *maison*, une *senteur*, un *corps*, la *constance*

Regarde la troisième ligne : *fermeté*, *entêtement*, *constance* désignent à
peu près le même comportement. Mais si je dis de toi que tu es ferme, je te
félicite ; si je dis que tu es entêté, je te critique. Le fait est le même ; le
jugement est dans le mot.

---

**Exercice corrigé**

*Pour chaque série, dire quelle est la dénotation commune, puis ranger les trois
mots selon leur connotation.*

*1. maison — demeure — bicoque*
*2. économe — avare — pingre*
*3. odeur — parfum — puanteur*

**Correction.**

*Série 1.* La **dénotation commune** est : bâtiment destiné à l''habitation.

> *demeure* : **méliorative**. Le mot évoque la grandeur, la noblesse,
> l''ancienneté. On parle de la demeure d''un notable, jamais d''une case.
> *maison* : **neutre**. C''est le terme ordinaire, celui du dictionnaire et de
> l''état civil.
> *bicoque* : **péjorative**. Le mot évoque la petitesse, la vétusté, la
> pauvreté. Il méprise.

*Série 2.* La **dénotation commune** est : qui dépense peu d''argent.

> *économe* : **méliorative**. C''est une qualité : savoir gérer son argent.
> *avare* : **péjorative**. C''est un défaut : garder son argent par attachement
> excessif.
> *pingre* : **péjorative, et plus forte encore**. Le mot est familier et
> méprisant.

*Remarque qu''il n''y a pas de terme neutre évident dans cette série. C''est
fréquent : la langue n''offre pas toujours les trois cases. Le plus proche du
neutre serait une périphrase, « qui dépense peu ».*

*Série 3.* La **dénotation commune** est : ce que l''on perçoit par l''odorat.

> *parfum* : **méliorative**.
> *odeur* : **neutre**.
> *puanteur* : **péjorative**.

*Et voici l''usage qu''un journaliste en fait. Écrire « une odeur montait du
marché » est une description. Écrire « une puanteur montait du marché » est
déjà un reproche adressé à la municipalité. Le fait rapporté est le même.*
', NULL, 26),
    (v_chapitre_id, 'Figure : trois mots pour une même action', 2, 'figure', '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 580 300" width="580" height="300">
<rect width="580" height="300" fill="#ffffff"/>
<text x="290" y="24" text-anchor="middle" font-size="14" font-weight="700" fill="#0f172a">Trois mots pour la même chose</text>
<text x="290" y="42" text-anchor="middle" font-size="10" fill="#64748b">Même dénotation, trois connotations. Le choix du mot est déjà un argument.</text>

<rect x="20" y="58" width="540" height="40" rx="6" fill="#f1f5f9" stroke="#64748b" stroke-width="1.4"/>
<text x="38" y="76" font-size="10" font-weight="700" fill="#0f172a">DÉNOTATION — ce que dit le dictionnaire, et que personne ne conteste</text>
<text x="38" y="91" font-size="9" font-style="italic" fill="#475569">« Action de couper des arbres sur une surface donnée. »</text>

<rect x="20" y="112" width="172" height="112" rx="6" fill="#dcfce7" stroke="#15803d" stroke-width="1.5"/>
<text x="106" y="134" text-anchor="middle" font-size="13" font-weight="700" fill="#14532d">exploitation</text>
<text x="106" y="150" text-anchor="middle" font-size="9" font-weight="700" fill="#15803d">MÉLIORATIVE</text>
<line x1="36" y1="160" x2="176" y2="160" stroke="#86efac"/>
<text x="106" y="178" text-anchor="middle" font-size="8" fill="#166534">travail, organisation, revenu</text>
<text x="106" y="192" text-anchor="middle" font-size="8" fill="#166534">emplois, développement</text>
<line x1="56" y1="202" x2="156" y2="202" stroke="#bbf7d0"/>
<text x="106" y="217" text-anchor="middle" font-size="8" font-style="italic" fill="#475569">employé par l&apos;entreprise</text>

<rect x="204" y="112" width="172" height="112" rx="6" fill="#f1f5f9" stroke="#64748b" stroke-width="1.5"/>
<text x="290" y="134" text-anchor="middle" font-size="13" font-weight="700" fill="#0f172a">abattage</text>
<text x="290" y="150" text-anchor="middle" font-size="9" font-weight="700" fill="#475569">NEUTRE</text>
<line x1="220" y1="160" x2="360" y2="160" stroke="#cbd5e1"/>
<text x="290" y="178" text-anchor="middle" font-size="8" fill="#334155">terme technique, descriptif</text>
<text x="290" y="192" text-anchor="middle" font-size="8" fill="#334155">ne juge ni ne défend</text>
<line x1="240" y1="202" x2="340" y2="202" stroke="#e2e8f0"/>
<text x="290" y="217" text-anchor="middle" font-size="8" font-style="italic" fill="#475569">employé par le forestier</text>

<rect x="388" y="112" width="172" height="112" rx="6" fill="#fee2e2" stroke="#b91c1c" stroke-width="1.5"/>
<text x="474" y="134" text-anchor="middle" font-size="13" font-weight="700" fill="#7f1d1d">saccage</text>
<text x="474" y="150" text-anchor="middle" font-size="9" font-weight="700" fill="#b91c1c">PÉJORATIVE</text>
<line x1="404" y1="160" x2="544" y2="160" stroke="#fecaca"/>
<text x="474" y="178" text-anchor="middle" font-size="8" fill="#991b1b">violence, destruction, pillage</text>
<text x="474" y="192" text-anchor="middle" font-size="8" fill="#991b1b">irréparable</text>
<line x1="424" y1="202" x2="524" y2="202" stroke="#fecaca"/>
<text x="474" y="217" text-anchor="middle" font-size="8" font-style="italic" fill="#475569">employé par l&apos;association</text>

<rect x="20" y="238" width="540" height="48" rx="6" fill="#fef3c7" stroke="#ca8a04" stroke-width="1.5"/>
<text x="290" y="258" text-anchor="middle" font-size="10" font-weight="700" fill="#78350f">CE QUE CELA VEUT DIRE POUR TOI</text>
<text x="40" y="277" font-size="9" fill="#92400e">Avant de lire un texte argumentatif, regarde quels mots l&apos;auteur a choisis. Il a déjà pris parti.</text>
</svg>', NULL, 5),
    (v_chapitre_id, 'Simulation : dénotation ou connotation ?', 3, 'interactif', '{
  "widget": "denote-connote",
  "consigne": "Une phrase s''affiche avec un mot en relief, et deux questions : quelle est sa dénotation, et quelle connotation porte-t-il ? La simulation te montre d''abord l''entrée du dictionnaire, puis te laisse cocher les images que le mot réveille — et elle te fait remarquer quand une connotation est propre à notre culture et n''existerait pas ailleurs. Seize mots, dont six où la connotation camerounaise diffère de la connotation européenne."
}', NULL, 10),
    (v_chapitre_id, 'L''échelle des mots : l''intensité se choisit', 4, 'texte', '
La connotation n''est pas seulement positive ou négative. Elle a aussi une
**intensité**, et c''est elle qu''on règle quand on écrit bien.

### Une échelle, pas deux cases

Prends une même idée et range les mots du plus faible au plus fort.

> **contrarié** → **agacé** → **irrité** → **en colère** → **furieux** →
> **fou de rage**

Six mots pour un seul sentiment, et un auteur qui écrit « il était contrarié »
ne dit pas du tout la même chose que celui qui écrit « il était fou de rage ».

Tu as déjà rencontré cette échelle au chapitre 5, avec le champ lexical des
sentiments. Elle vaut pour tout.

> **dire** → **affirmer** → **soutenir** → **clamer** → **marteler**
> **grand** → **vaste** → **immense** → **colossal** → **démesuré**
> **pauvre** → **démuni** → **indigent** → **misérable** → **miséreux**

### Le piège de la surenchère

Voici un conseil que je te donne pour ta rédaction, et qui vaut pour le reste
de ta vie.

**Si tu emploies tout de suite le mot le plus fort, il ne te reste rien pour la
suite.**

Un élève écrit : « J''étais furieux parce que mon stylo ne marchait plus. »
Que lui restera-t-il à écrire quand il parlera de la mort de son grand-père ?

L''échelle est un capital. On la monte, on ne commence pas par le haut.

### Deux procédés qui jouent sur l''intensité

**L''euphémisme** atténue : on choisit un mot plus faible pour adoucir une
réalité pénible.

> *il nous a quittés* pour *il est mort*
> *un demandeur d''emploi* pour *un chômeur*
> *un établissement pénitentiaire* pour *une prison*
> *une frappe chirurgicale* pour *un bombardement*

L''euphémisme est parfois une délicatesse — on l''emploie par respect pour la
famille d''un défunt. Il est parfois un masque — les deux derniers exemples
servent à rendre acceptable ce qui ne l''est pas. Apprends à repérer lequel des
deux tu as sous les yeux.

**L''hyperbole** exagère : on choisit un mot trop fort, volontairement.

> *je meurs de faim* — je n''en meurs pas
> *un siècle que je t''attends* — vingt minutes
> *un travail titanesque* — trois heures de ménage

L''hyperbole est partout dans la publicité et dans la conversation. Elle
affaiblit celui qui en abuse.

### Pourquoi cela compte pour ta copie

Le correcteur du BEPC lit soixante copies. Celle qui emploie *furieux*,
*catastrophique* et *extraordinaire* à chaque paragraphe se repère tout de
suite, et pas en bien.

Celle qui règle l''intensité — un mot faible ici, un mot fort là où il faut —
donne l''impression d''un élève qui maîtrise sa langue. C''est souvent ce qui
sépare le douze du quinze.

---

**Exercice corrigé**

*1. Ranger du plus faible au plus fort : terrifié, inquiet, effrayé, anxieux,
pétrifié.*

*2. Dire si chaque expression est un euphémisme ou une hyperbole, et donner le
terme direct.*

> *a. les personnes à mobilité réduite*
> *b. je t''ai appelé mille fois*
> *c. un plan social*
> *d. c''est un cauchemar, ce devoir*

*3. Réécrire cette phrase en baissant l''intensité d''un cran à chaque mot
souligné : « J''étais fou de rage : cette catastrophe avait anéanti mon travail
titanesque. »*

**Correction.**

*1.* Du plus faible au plus fort :

> **inquiet** → **anxieux** → **effrayé** → **terrifié** → **pétrifié**

*« Inquiet » est un simple souci. « Anxieux » installe une durée. « Effrayé »
suppose une cause identifiée. « Terrifié » est une peur qui domine. « Pétrifié »
est la peur qui empêche de bouger : c''est le dernier degré, parce qu''il ajoute
un effet physique.*

*2.*

*a.* **Euphémisme** de *handicapés*, ou *infirmes*. Ici l''intention est le
respect : c''est l''usage délicat de l''euphémisme.

*b.* **Hyperbole** de *plusieurs fois*. Personne n''a appelé mille fois.

*c.* **Euphémisme** de *licenciements*. Et ici l''intention est le masque :
l''expression « plan social » fait entendre une aide sociale alors qu''il s''agit
de renvoyer des employés. C''est l''usage qu''il faut savoir démonter.

*d.* **Hyperbole** de *c''est difficile*.

*3.* En baissant d''un cran :

> « J''étais **en colère** : cet **incident** avait **compromis** mon travail
> **considérable**. »

*Et si l''on baisse encore d''un cran :*

> « J''étais **contrarié** : ce **contretemps** avait **gêné** mon travail
> **soigné**. »

*Les trois phrases racontent le même fait. La première convient si l''on a perdu
un an de recherche ; la troisième, si l''on a taché une page. Écrire juste, c''est
choisir le bon niveau — et garder les mots forts pour les moments forts.*
', NULL, 26),
    (v_chapitre_id, 'Simulation : l''échelle de l''intensité', 5, 'interactif', '{
  "widget": "echelle-connotation",
  "consigne": "Une situation s''affiche — on t''a bousculé dans un taxi, tu as perdu ton cahier, ton quartier est inondé — et un curseur à six crans allant de « contrarié » à « fou de rage ». Tu places le curseur, et la simulation réécrit la phrase avec le mot choisi, puis te demande ce qu''il te restera pour la situation suivante, plus grave. Au bout de cinq situations, elle te montre ta courbe : ceux qui commencent trop haut se retrouvent sans mots. Un second atelier porte sur l''euphémisme et l''hyperbole, avec huit expressions tirées de la presse à démonter."
}', NULL, 10),
    (v_chapitre_id, 'Le mot n''est jamais innocent : lire entre les lignes', 6, 'texte', '
Troisième leçon, et c''est celle qui prépare vraiment le module. Nous parlons de
citoyenneté et d''environnement ; or ces sujets-là se discutent, et la
discussion commence par le choix des mots.

### Une même réalité, trois mots

Reprends la figure du chapitre. Des arbres sont coupés sur mille hectares. Le
fait est le même pour tout le monde. Et pourtant :

> l''entreprise écrit : « l''**exploitation** forestière »
> le technicien écrit : « l''**abattage** »
> l''association écrit : « le **saccage** de la forêt »

Trois mots, une seule réalité. Celui qui lit sans attention croit lire trois
descriptions ; en vérité, il lit trois **opinions**.

### D''autres couples à connaître

Ce sont des exemples réels, et ils te serviront en lecture comme en rédaction.

> *un bidonville* / *un quartier précaire* / *un quartier populaire*
> *un chômeur* / *un demandeur d''emploi* / *un sans-emploi*
> *la croissance* / *l''exploitation des ressources* / *le pillage*
> *un dirigeant* / *un chef d''État* / *un régime*
> *une manifestation* / *un rassemblement* / *un attroupement*
> *les déchets* / *les ordures* / *les immondices*

Dans chaque ligne, les mots dénotent la même chose. Ils ne connotent pas la
même chose du tout.

### Les mots de l''environnement, que tu rencontreras

Puisque c''est le thème du module, autant t''équiper.

**Neutres et techniques** : *déforestation, érosion, pollution, biodiversité,
écosystème, assainissement, reboisement, effluent, décharge.*

**Mélioratifs, employés par ceux qui défendent la nature** : *patrimoine,
sanctuaire, poumon vert, richesse naturelle, équilibre, préservation.*

**Péjoratifs, employés par ceux qui dénoncent** : *saccage, pillage, désastre,
agression, désert, mise à mort, hémorragie.*

Note que les mots les plus efficaces sont souvent des **métaphores** : « poumon
vert », « hémorragie », « mise à mort ». Elles font voir, et ce qui se voit
convainc mieux que ce qui se démontre.

### Lire un texte en repérant ses mots

Voici la méthode, en trois gestes, et tu la reprendras au chapitre suivant.

**Geste 1.** Lis le texte une première fois sans rien noter, pour comprendre de
quoi il parle.

**Geste 2.** Relis-le en soulignant tous les mots **chargés** — ceux qui
jugent, ceux qui ne sont pas neutres. Tu verras aussitôt apparaître le camp de
l''auteur.

**Geste 3.** Demande-toi comment l''adversaire aurait écrit le même paragraphe.
Si tu sais le refaire avec d''autres mots, tu as compris le texte.

### En rédaction, cela vaut deux points

Au BEPC, l''épreuve d''expression écrite te demandera souvent de défendre une
opinion sur un sujet de société. Le correcteur regarde la pertinence des idées,
la cohérence de l''organisation, et la correction de la langue.

Les mots que tu choisis jouent sur les trois. Un élève qui écrit « on détruit
la forêt » dit une chose banale. Celui qui écrit « on ampute la forêt de son
poumon » dit la même chose, mais le correcteur se souviendra de la phrase.

Attention cependant : **une image par paragraphe suffit**. Trois métaphores
d''affilée fatiguent.

---

**Exercice corrigé**

*Voici deux textes sur le même fait. Repérer les mots chargés, dire de quel
camp est chaque auteur, et réécrire le premier paragraphe du texte A avec le
vocabulaire du texte B.*

> **Texte A.** « La société a entrepris l''exploitation rationnelle de la
> concession forestière. Les opérations, menées selon un plan d''aménagement
> approuvé, permettront la création de trois cents emplois et le désenclavement
> de la zone. Un programme de reboisement accompagnera le chantier. »

> **Texte B.** « La société s''est attaquée à la dernière forêt du
> département. Le saccage, mené au mépris des villageois, détruira les champs
> et chassera le gibier. On nous promet quelques plants pour faire oublier
> l''hémorragie. »

**Correction.**

*Les mots chargés du texte A* : « rationnelle » (mélioratif : la raison contre
le désordre), « approuvé » (mélioratif : l''autorité a validé), « permettront »
(le futur de la promesse), « création », « désenclavement », « accompagnera ».
Ce sont tous des mots de **progrès** et d''**ordre**. Le camp de l''auteur est
celui de l''entreprise.

*Remarque aussi ce que le texte A ne nomme pas : il ne parle ni des arbres, ni
des villageois, ni des champs. Ce qu''un texte tait est aussi révélateur que ce
qu''il dit.*

*Les mots chargés du texte B* : « s''est attaquée » (métaphore militaire),
« la dernière » (l''irréparable), « saccage », « au mépris », « détruira »,
« chassera », « quelques plants » (le diminutif méprisant), « hémorragie »
(métaphore médicale, le sang qui s''échappe). Le camp de l''auteur est celui des
riverains.

*Le premier paragraphe du texte A, réécrit avec le vocabulaire du texte B :*

> « La société s''est attaquée à la dernière forêt du département. Le saccage,
> mené au mépris d''un plan d''aménagement que personne n''a vu, chassera les
> villageois de leurs champs pour trois cents emplois précaires. »

*Et l''exercice inverse, le texte B réécrit avec le vocabulaire du texte A :*

> « La société a entrepris la mise en valeur du massif forestier du
> département. Les opérations, menées en concertation avec les communautés
> riveraines, permettront la reconversion des activités agricoles, et un
> programme de reboisement accompagnera le chantier. »

*Les deux paragraphes rapportent le même fait. Et aucun des deux ne ment
exactement. C''est précisément ce que ce chapitre t''apprend à voir.*
', NULL, 28),
    (v_chapitre_id, 'Simulation : réécrire dans l''autre camp', 7, 'interactif', '{
  "widget": "mot-choisi",
  "consigne": "Un texte s''affiche, et chaque mot chargé est surligné. En cliquant dessus, tu fais apparaître ses deux voisins sur l''échelle — le neutre et l''opposé — et le texte se réécrit sous tes yeux. Tu peux basculer un article entier d''un camp à l''autre sans changer un seul fait, puis comparer les deux versions côte à côte. Six textes, tous sur des sujets d''environnement et de citoyenneté, dont deux extraits de la presse camerounaise. Un compteur te dit combien de mots il a suffi de changer : c''est en général moins de dix."
}', NULL, 10),
    (v_chapitre_id, 'Quiz du chapitre 13', 8, 'quiz', '{
  "titre": "Vérifie que tu as compris",
  "questions": [
    {
      "question": "Quelle différence entre dénotation et connotation ?",
      "choix": [
        "Aucune",
        "La dénotation est le sens du dictionnaire, neutre et incontesté ; la connotation est ce que le mot traîne avec lui — images, jugements, émotions",
        "La dénotation est plus longue",
        "La connotation est une faute"
      ],
      "bonne": 1,
      "explication": "« Serpent » dénote un reptile sans pattes. Il connote la traîtrise, et c''est cette connotation que j''emploie en disant d''un homme que c''est un serpent."
    },
    {
      "question": "Les mots « demeure », « maison » et « bicoque » ont…",
      "choix": [
        "Des dénotations différentes",
        "La même dénotation, mais des connotations méliorative, neutre et péjorative",
        "Le même sens exactement",
        "Des natures différentes"
      ],
      "bonne": 1,
      "explication": "La dénotation commune est « bâtiment destiné à l''habitation ». Le jugement est dans le mot, pas dans le fait."
    },
    {
      "question": "Pourquoi la connotation dépend-elle de la culture ?",
      "choix": [
        "Elle n''en dépend pas",
        "Parce que les images qu''un mot réveille sont celles de ceux qui l''emploient : « panthère » connote la royauté au Cameroun, « vieux » y connote le respect",
        "Parce que les dictionnaires diffèrent",
        "Parce que les langues sont différentes"
      ],
      "bonne": 1,
      "explication": "Un mot ne voyage jamais seul : il emporte avec lui la culture de ceux qui l''emploient."
    },
    {
      "question": "Qu''est-ce qu''un euphémisme ?",
      "choix": [
        "Une exagération",
        "Un mot plus faible choisi pour adoucir une réalité pénible : « il nous a quittés » pour « il est mort »",
        "Une métaphore",
        "Une répétition"
      ],
      "bonne": 1,
      "explication": "Il est parfois une délicatesse — par respect pour une famille — et parfois un masque : « plan social » pour « licenciements ». Apprends à distinguer les deux."
    },
    {
      "question": "Quel est le danger d''employer tout de suite le mot le plus fort ?",
      "choix": [
        "Aucun",
        "Il ne reste plus rien pour la suite : celui qui est « furieux » parce que son stylo ne marche plus n''a plus de mot pour un vrai malheur",
        "Le correcteur ne comprend pas",
        "La phrase est trop longue"
      ],
      "bonne": 1,
      "explication": "L''échelle de l''intensité est un capital. On la monte, on ne commence pas par le haut."
    },
    {
      "question": "« Exploitation », « abattage », « saccage » pour la même coupe d''arbres : que lit-on en réalité ?",
      "choix": [
        "Trois descriptions",
        "Trois opinions : l''entreprise, le technicien et l''association ont déjà pris parti par leur seul choix de mot",
        "Trois erreurs",
        "Trois synonymes exacts"
      ],
      "bonne": 1,
      "explication": "Celui qui lit sans attention croit lire trois descriptions. C''est pourquoi la première chose à faire devant un texte argumentatif est de regarder quels mots l''auteur a choisis."
    },
    {
      "question": "Que révèle souvent ce qu''un texte ne nomme PAS ?",
      "choix": [
        "Rien du tout",
        "Autant que ce qu''il dit : un texte sur l''exploitation forestière qui ne parle ni des arbres ni des villageois a choisi de les taire",
        "Que l''auteur a oublié",
        "Que le texte est incomplet"
      ],
      "bonne": 1,
      "explication": "C''est un réflexe de lecteur averti : après avoir souligné les mots chargés, demande-toi quels mots manquent."
    }
  ]
}', NULL, 5);

  RAISE NOTICE '8 leçons ajoutées au chapitre 13, Dénotation et connotation.';
END $fr3$;
