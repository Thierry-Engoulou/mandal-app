-- ---------------------------------------------------------------------------
-- M'Andal — Philosophie, classes de Terminale
-- Chapitre 10 : La science
-- Module 1 : La philosophie — 9 leçons
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
    WHERE programme_id = v_programme_id AND ordre = 10;

    IF v_chapitre_id IS NULL THEN
      INSERT INTO public.chapitres (programme_id, titre, ordre, niveau)
      VALUES (v_programme_id, 'La science', 10, 'Module 1 : La philosophie')
      RETURNING id INTO v_chapitre_id;
      RAISE NOTICE '% : chapitre 10 créé.', v_nom;
    END IF;

    -- Les leçons. Si le chapitre en a déjà, on passe son tour sans rien toucher.
    SELECT count(*) INTO v_deja FROM public.concepts WHERE chapitre_id = v_chapitre_id;
    IF v_deja > 0 THEN
      RAISE NOTICE '% : le chapitre 10 a déjà ses % leçons, je n''y touche pas.', v_nom, v_deja;
      CONTINUE;
    END IF;

    INSERT INTO public.concepts
      (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes) VALUES
      (v_chapitre_id, 'De l''opinion à la science', 1, 'texte', '
Ce chapitre commence par une rupture. Il y a ce que l''on croit savoir, et il y
a ce que l''on sait — et le second ne s''obtient pas en accumulant le premier.

### Les trois degrés de la connaissance

**L''opinion** est un jugement qui n''est pas fondé sur des raisons suffisantes,
et qui tient souvent sa force de sa seule répétition. **Platon** la nomme *doxa*
et l''oppose à l''*épistémè*, le savoir véritable. On peut avoir une opinion vraie
par hasard : le joueur qui annonce le bon numéro n''en sait rien pour autant.

**La croyance** est l''adhésion à une proposition sans preuve, mais assumée comme
telle. Elle n''est pas disqualifiée par l''absence de preuve, parce qu''elle ne la
revendique pas.

**La science** est une connaissance **rationnelle**, **méthodique**,
**objective** et **vérifiable**. Quatre adjectifs, et chacun exclut l''opinion.

### La thèse de Bachelard : l''opinion n''est pas un premier pas

On croirait volontiers que la science corrige l''opinion. **Gaston Bachelard**,
dans *La formation de l''esprit scientifique* (1938), soutient quelque chose de
plus fort :

**« L''opinion pense mal ; elle ne pense pas. »**

Son argument : l''opinion traduit des besoins en connaissances. Elle désigne les
objets par leur usage, et non par leur nature. Elle n''est donc pas une
connaissance imparfaite qu''on pourrait affiner : elle est d''un autre ordre, et
il faut la **détruire** avant de construire.

D''où la notion d''**obstacle épistémologique** : ce qui empêche de connaître
n''est pas l''ignorance, c''est ce que l''on croit déjà savoir. L''élève n''arrive
jamais l''esprit vide ; il arrive l''esprit encombré.

Bachelard en tire une règle de méthode : « il faut accepter une rupture nette
entre la connaissance sensible et la connaissance scientifique ».

### Les trois types de sciences

**Les sciences formelles** — logique et mathématiques. Elles portent sur des
objets idéaux, procèdent par **démonstration** à partir d''axiomes, et leur
vérité est une **cohérence** interne. Aucune expérience ne confirme ni ne
réfute un théorème.

**Les sciences expérimentales** — physique, chimie, biologie. Elles portent sur
des faits, procèdent par **expérimentation**, et leur vérité est une
**correspondance** avec le réel.

**Les sciences humaines** — histoire, sociologie, psychologie, économie. Elles
portent sur l''homme, et c''est là que la difficulté commence : le sujet qui
connaît est de la même nature que l''objet connu.

---

**Exercice corrigé**

*Bachelard écrit : « L''opinion pense mal ; elle ne pense pas. » Expliquer, puis
dire quelle conséquence cette thèse a pour l''enseignement.*

**Correction.**

*Le paradoxe apparent.* Si l''opinion « pense mal », c''est qu''elle pense ; et si
elle « ne pense pas », on ne peut pas dire qu''elle pense mal. Bachelard se
corrige lui-même dans la phrase, et la correction est le cœur de sa thèse.

*Le premier membre est ce qu''on croirait.* On se représente volontiers l''opinion
comme une pensée approximative, une science en miniature qu''il suffirait
d''affiner. Dans cette image, l''opinion serait le premier pas.

*Le second membre renverse cela.* Bachelard affirme que l''opinion n''est pas une
pensée faible, mais **autre chose qu''une pensée**. Sa raison : l''opinion
« traduit des besoins en connaissances ». Elle désigne les choses par leur
usage pour nous — ce qui est bon à manger, dangereux, utile — et non par leur
nature propre. Elle répond à une question qu''elle n''a pas posée.

Or la science commence par **poser un problème**. Tant qu''on n''a pas de
question, on n''a pas de pensée : on a des réflexes.

*La conséquence pour l''enseignement.* Elle est considérable, et Bachelard
l''énonce lui-même.

L''élève n''arrive pas l''esprit **vide** : il arrive l''esprit **encombré**. Il a
déjà des représentations sur la chaleur, le mouvement, la vie, et ces
représentations lui ont servi. Elles constituent ce que Bachelard appelle des
**obstacles épistémologiques**.

Enseigner ne consiste donc pas à **ajouter** du savoir à l''ignorance, mais à
**défaire** un savoir apparent. Le professeur qui croit remplir un vase se
trompe de geste : il doit d''abord vider.

*C''est pourquoi une erreur bien installée est plus difficile à corriger qu''une
ignorance franche — et pourquoi le bon exercice n''est pas celui qui confirme
l''élève, mais celui qui le met en difficulté.*
', NULL, 28),
      (v_chapitre_id, 'Simulation : opinion, croyance ou science ?', 2, 'interactif', '{
  "widget": "opinion-croyance-science",
  "consigne": "Quinze énoncés te sont soumis — « la Terre tourne autour du Soleil », « le rouge porte chance », « l''eau bout à 100 degrés au niveau de la mer », « Dieu existe », « les vaccins rendent malade » — et tu dois les classer. Pour chacun la simulation te demande ensuite ce qui le rendrait faux : si rien ne peut le réfuter, ce n''est pas un énoncé scientifique, et tu viens d''appliquer le critère de Popper sans qu''on te l''ait encore enseigné."
}', NULL, 10),
      (v_chapitre_id, 'Figure : la méthode expérimentale de Claude Bernard', 3, 'figure', '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 580 320" width="580" height="320">
<rect width="580" height="320" fill="#ffffff"/>
<text x="290" y="24" text-anchor="middle" font-size="14" font-weight="700" fill="#0f172a">La méthode expérimentale selon Claude Bernard</text>
<text x="290" y="42" text-anchor="middle" font-size="10" fill="#64748b">Introduction à l&apos;étude de la médecine expérimentale, 1865</text>

<rect x="36" y="60" width="140" height="58" rx="6" fill="#dbeafe" stroke="#2563eb" stroke-width="1.6"/>
<text x="106" y="82" text-anchor="middle" font-size="11" font-weight="700" fill="#1e3a8a">1. OBSERVATION</text>
<text x="106" y="98" text-anchor="middle" font-size="8" fill="#1e40af">un fait surprend</text>
<text x="106" y="110" text-anchor="middle" font-size="8" fill="#1e40af">l&apos;esprit est passif</text>

<rect x="220" y="60" width="140" height="58" rx="6" fill="#fef3c7" stroke="#ca8a04" stroke-width="1.6"/>
<text x="290" y="82" text-anchor="middle" font-size="11" font-weight="700" fill="#78350f">2. HYPOTHÈSE</text>
<text x="290" y="98" text-anchor="middle" font-size="8" fill="#92400e">une idée vient</text>
<text x="290" y="110" text-anchor="middle" font-size="8" fill="#92400e">l&apos;esprit invente</text>

<rect x="404" y="60" width="140" height="58" rx="6" fill="#fce7f3" stroke="#be185d" stroke-width="1.6"/>
<text x="474" y="82" text-anchor="middle" font-size="11" font-weight="700" fill="#831843">3. EXPÉRIENCE</text>
<text x="474" y="98" text-anchor="middle" font-size="8" fill="#9d174d">on provoque le fait</text>
<text x="474" y="110" text-anchor="middle" font-size="8" fill="#9d174d">l&apos;esprit est actif</text>

<path d="M 176 89 L 214 89" fill="none" stroke="#334155" stroke-width="1.6"/>
<polygon points="220,89 212,85 212,93" fill="#334155"/>
<path d="M 360 89 L 398 89" fill="none" stroke="#334155" stroke-width="1.6"/>
<polygon points="404,89 396,85 396,93" fill="#334155"/>

<path d="M 474 118 L 474 140 L 290 140 L 290 158" fill="none" stroke="#334155" stroke-width="1.6"/>
<polygon points="290,164 286,156 294,156" fill="#334155"/>

<rect x="200" y="166" width="180" height="50" rx="6" fill="#f1f5f9" stroke="#475569" stroke-width="1.6"/>
<text x="290" y="186" text-anchor="middle" font-size="11" font-weight="700" fill="#0f172a">le résultat juge l&apos;hypothèse</text>
<text x="290" y="204" text-anchor="middle" font-size="8" fill="#475569">et non l&apos;hypothèse le résultat</text>

<path d="M 200 191 L 120 191 L 120 230" fill="none" stroke="#b91c1c" stroke-width="1.6" stroke-dasharray="4 3"/>
<polygon points="120,236 116,228 124,228" fill="#b91c1c"/>
<rect x="36" y="238" width="168" height="54" rx="6" fill="#fee2e2" stroke="#b91c1c" stroke-width="1.6"/>
<text x="120" y="258" text-anchor="middle" font-size="10" font-weight="700" fill="#7f1d1d">hypothèse réfutée</text>
<text x="120" y="274" text-anchor="middle" font-size="8" fill="#991b1b">on en cherche une autre</text>
<text x="120" y="286" text-anchor="middle" font-size="8" fill="#991b1b">« fuir les idées fixes »</text>

<path d="M 380 191 L 460 191 L 460 230" fill="none" stroke="#15803d" stroke-width="1.6"/>
<polygon points="460,236 456,228 464,228" fill="#15803d"/>
<rect x="376" y="238" width="168" height="54" rx="6" fill="#dcfce7" stroke="#15803d" stroke-width="1.6"/>
<text x="460" y="258" text-anchor="middle" font-size="10" font-weight="700" fill="#14532d">4. LOI</text>
<text x="460" y="274" text-anchor="middle" font-size="8" fill="#166534">provisoirement confirmée</text>
<text x="460" y="286" text-anchor="middle" font-size="8" fill="#166534">jamais définitivement vraie</text>

<text x="290" y="310" text-anchor="middle" font-size="9" font-style="italic" fill="#475569">« L&apos;expérimentateur doit douter, fuir les idées fixes » — Claude Bernard</text>
</svg>', NULL, 5),
      (v_chapitre_id, 'La méthode scientifique et ses limites', 4, 'texte', '
Comment la science s''y prend-elle ? Et jusqu''où sa vérité tient-elle ?

### Les quatre étapes de la méthode expérimentale

**Claude Bernard**, dans son *Introduction à l''étude de la médecine
expérimentale* (1865), en donne la description qui fait référence.

**1. L''observation.** Un fait se présente et surprend. L''esprit est ici
**passif** : il constate.

**2. L''hypothèse.** Une idée vient, qui expliquerait le fait. L''esprit est
**inventif** — et c''est le moment le moins mécanique de toute la science.
Bernard insiste : l''hypothèse ne sort pas des faits, elle vient de celui qui les
regarde.

**3. L''expérimentation.** On provoque le fait dans des conditions contrôlées,
pour voir si l''hypothèse tient. L''esprit est **actif** : il ne subit plus le
réel, il l''interroge.

**4. La loi.** Si l''expérience confirme, on énonce une relation constante.

Et Bernard ajoute l''avertissement qui vaut tout le reste : **« l''expérimentateur
doit douter, fuir les idées fixes »**. C''est le résultat qui juge l''hypothèse,
jamais l''hypothèse qui juge le résultat.

### Déduction et induction

La **déduction** va du général au particulier. Elle est **certaine** quand les
prémisses le sont : si tous les hommes sont mortels et que Socrate est un homme,
alors Socrate est mortel, sans reste.

L''**induction** va du particulier au général. **Francis Bacon**, dans le *Novum
Organum*, en fait l''instrument des sciences de la nature : de mille corbeaux
noirs observés, on conclut que les corbeaux sont noirs.

Mais **Hume** y a vu un problème redoutable : aucun nombre de cas observés ne
garantit le cas suivant. Rien dans mille corbeaux noirs n''interdit le
mille-et-unième d''être blanc. L''induction repose donc sur une **habitude**, non
sur une démonstration.

### La réponse de Popper : la falsifiabilité

**Karl Popper** retourne la difficulté au lieu de la résoudre.

Puisqu''aucune expérience ne peut **vérifier** définitivement une loi — il
faudrait examiner tous les cas, y compris futurs —, mais qu''une seule suffit à
la **réfuter**, le critère de la science n''est pas la vérifiabilité : c''est la
**falsifiabilité**.

Un énoncé est scientifique s''il est possible de dire **ce qui le rendrait
faux**. Une théorie qui explique tout, et que rien ne pourrait démentir, n''est
pas pour cela plus solide : elle sort de la science.

La conséquence est rude et féconde : la vérité scientifique est toujours
**provisoire**. Elle n''est pas une acquisition, c''est une conjecture qui a
survécu aux tests jusqu''ici.

### Les ruptures et les paradigmes

**Bachelard** parle de **rupture épistémologique** : la science n''avance pas en
accumulant, elle avance en rompant. La physique d''Einstein ne complète pas celle
de Newton, elle la refonde.

**Thomas Kuhn**, dans *La structure des révolutions scientifiques*, nomme
**paradigme** le cadre admis par une communauté de savants à une époque. La
science ordinaire travaille dans le paradigme ; quand les anomalies
s''accumulent, une **révolution** change de cadre, et les mêmes faits reçoivent
un autre sens.

### Le problème des sciences humaines

Elles rencontrent trois difficultés que les sciences de la nature ignorent.

**L''objet est aussi le sujet.** Le sociologue appartient à la société qu''il
étudie, avec ses intérêts et ses préjugés.

**L''expérimentation est limitée.** On ne refait pas une révolution en
laboratoire pour en isoler la cause.

**L''objet est conscient.** Celui qu''on observe se sait observé, et il modifie sa
conduite.

**Durkheim** propose une règle : traiter les faits sociaux « comme des choses »,
c''est-à-dire de l''extérieur, en se défaisant de toute notion préalable.
**Max Weber** répond qu''il faut au contraire **comprendre** le sens que les
acteurs donnent à leur action, ce qu''aucun thermomètre ne fait.

Les deux ont raison contre un excès : Durkheim contre l''introspection,
Weber contre l''illusion que l''homme soit un objet comme les autres.

---

**Exercice corrigé**

*Expliquer le critère de falsifiabilité de Popper, et montrer par deux exemples
qu''il sépare la science de ce qui n''en est pas.*

**Correction.**

*Le point de départ.* Une loi scientifique porte sur un nombre indéfini de cas,
dont des cas futurs. Aucune série d''observations ne peut donc la **vérifier**
complètement : c''est le problème de l''induction, posé par **Hume**.

*Le renversement de Popper.* Si la vérification complète est impossible, la
**réfutation**, elle, est possible en une seule fois. Mille corbeaux noirs ne
prouvent pas que tous le soient ; un seul corbeau blanc prouve que non.

Popper en tire son critère : **est scientifique un énoncé dont on peut dire ce
qui le rendrait faux.** Non pas un énoncé faux, ni un énoncé douteux : un énoncé
qui **s''expose** au démenti.

*Premier exemple, un énoncé scientifique.* « Tous les corps tombent avec la même
accélération dans le vide. » On sait exactement ce qui la réfuterait : un corps
qui, dans le vide, tomberait plus lentement qu''un autre. L''énoncé prend un
risque, l''expérience peut le tuer, et c''est pour cela qu''il est scientifique.

*Second exemple, un énoncé qui n''en est pas.* « Tout événement de ta vie était
inscrit dans ton destin. » Essayez de dire ce qui la rendrait fausse : rien.
Si vous réussissez, c''était écrit ; si vous échouez, c''était écrit aussi.

L''énoncé est **irréfutable**, et Popper montre que c''est sa faiblesse et non sa
force. Il n''interdit rien, donc il n''apprend rien.

*La conséquence.* Une théorie qui explique tout n''explique rien, parce
qu''expliquer, c''est exclure. La force d''une science se mesure à ce qu''elle
**interdit** d''observer.

*Et la vérité scientifique en sort modeste : elle est une conjecture qui a
résisté aux épreuves jusqu''à présent. Ce n''est pas peu, et ce n''est pas
définitif.*
', NULL, 34),
      (v_chapitre_id, 'Simulation : le laboratoire de Claude Bernard', 5, 'interactif', '{
  "widget": "laboratoire-bernard",
  "consigne": "Un fait étrange t''est présenté — les lapins nourris d''herbe ont une urine acide, c''est l''observation réelle de Claude Bernard — et tu dois mener l''enquête en quatre étapes. Tu formules une hypothèse, tu choisis ton expérience, tu lis le résultat. La simulation refuse les raccourcis : si tu sautes l''hypothèse, elle te demande ce que tu cherches ; si tu interprètes l''expérience en faveur de ton idée malgré le résultat, elle te renvoie à l''avertissement de Bernard, « fuir les idées fixes ». Trois enquêtes différentes t''attendent."
}', NULL, 10),
      (v_chapitre_id, 'La science peut-elle tout connaître ? Et doit-elle tout faire ?', 6, 'texte', '
Deux questions distinctes, et les mélanger coûte cher. La première porte sur la
**puissance** de la science, la seconde sur sa **valeur**.

### Première question : la science peut-elle tout connaître ?

**Thèse du scientisme.** La science finira par tout expliquer, et ce qu''elle
n''explique pas aujourd''hui, elle l''expliquera demain. **Ernest Renan**, dans
*L''avenir de la science*, annonce une science qui organisera scientifiquement
l''humanité. **Laplace** avait donné la formule extrême avec son intelligence qui,
connaissant toutes les causes, connaîtrait tout l''avenir.

Les arguments sont réels : l''extension continue du savoir, la chute successive
de tout ce qu''on avait déclaré inconnaissable — la composition des étoiles, le
code génétique, l''origine de l''univers.

**Antithèse : il y a des limites.**

**Des limites de fait.** Les deux infinis de **Pascal** : l''homme est pris entre
l''immensité et l''infiniment petit, et « le silence éternel de ces espaces
infinis m''effraie ».

**Des limites de méthode.** La science explique **comment**, non **pourquoi**.
Elle dit par quelles lois l''univers fonctionne ; elle ne dit pas s''il a un sens.
**Bergson** sépare l''intelligence, qui découpe et mesure, de l''intuition, qui
saisit la durée vécue.

**Des limites de nature.** Les questions de valeur ne sont pas des questions de
fait. Aucune expérience ne démontrera qu''il est mal de torturer. **Pascal** :
« le cœur a ses raisons que la raison ne connaît point ». **Jaspers** parle de ce
qui ne peut être qu''« englobé », jamais objectivé.

**Et une limite interne**, que les sciences se sont donnée à elles-mêmes :
**Popper** rappelle qu''aucune loi n''est définitivement établie. Une science qui
prétendrait tout savoir cesserait d''être une science, faute de pouvoir être
démentie.

### Seconde question : la science doit-elle tout faire ?

Ici la question n''est plus épistémologique, elle est **morale**.

**Thèse de la neutralité.** La science cherche le vrai, un point c''est tout. Le
savoir n''est ni bon ni mauvais ; seul l''usage l''est. Ce n''est pas le physicien
qui a lancé la bombe.

**Antithèse.** On ne peut pas séparer le savoir de ses conséquences
prévisibles. **Rabelais** l''avait dit avant que la question ne devienne
brûlante : « science sans conscience n''est que ruine de l''âme ».
Hiroshima, les expérimentations sur des êtres humains, le clonage, les armes
biologiques : chaque fois, le savoir précédait l''usage et le rendait possible.

**Bergson** conclut les *Deux sources de la morale et de la religion* par une
formule qu''on cite toujours : l''humanité a grandi démesurément son corps par la
technique, et « ce corps agrandi attend un supplément d''âme ».

**Heidegger** va plus loin : la technique moderne n''est pas un simple outil, elle
est une manière de voir le monde, qui transforme tout — la forêt, le fleuve,
l''homme lui-même — en **réserve de ressources disponibles**.

**Hans Jonas** en tire un impératif pour l''âge technique : agis de façon que les
effets de ton action soient compatibles avec la permanence d''une vie
authentiquement humaine sur terre.

### La synthèse

Sur la première question, la position tenable est la suivante : la science n''a
pas de limite **assignable d''avance** — on a trop souvent déclaré
inconnaissable ce qui fut connu — mais elle a une limite de **domaine**. Elle
répond à des questions de fait, et les questions de sens et de valeur ne sont
pas de ce genre. Ce n''est pas une faiblesse de la science, c''est sa définition.

Sur la seconde, la neutralité du savoir est vraie en principe et insuffisante en
pratique. Le chercheur ne maîtrise pas les usages, mais il choisit ses
recherches, et ce choix est déjà moral. D''où les comités d''éthique, qui ne sont
pas une censure de la science mais une délibération sur ce que nous voulons
pouvoir faire.

La vraie conclusion est celle de Rabelais, prise au sérieux : la conscience
n''est pas l''ennemie de la science, elle en est la condition de survie.

---

**Exercice corrigé**

*« Science sans conscience n''est que ruine de l''âme » (Rabelais). Expliquer,
puis discuter la thèse de la neutralité de la science.*

**Correction.**

*L''explication de la formule.* « Science » désigne ici le savoir et le pouvoir
qu''il donne. « Conscience » a un double sens, et les deux comptent : la
conscience **morale**, qui juge du bien et du mal, et la **conscience de soi**,
qui mesure ce qu''on fait.

« Ruine de l''âme » : non pas l''inutilité, mais la **destruction** de ce qui fait
la valeur de l''homme. Un savoir sans jugement moral ne laisse pas l''homme où il
était : il l''abaisse.

*La thèse de la neutralité.* Elle objecte que la science cherche le vrai et rien
d''autre. Un savoir est vrai ou faux, non bon ou mauvais. La fission de l''atome
n''est ni morale ni immorale : elle est un fait. Seul l''**usage** mérite un
jugement, et l''usage n''appartient pas au savant mais au politique.

Cette thèse a une force : elle protège la liberté de chercher, sans laquelle
aucune science n''existe. Qui soumettrait la recherche à la morale du moment
aurait condamné Galilée.

*La discussion.*

**Premier point.** La séparation du savoir et de l''usage est moins nette qu''elle
n''en a l''air. Le chercheur ne décide pas de l''usage, mais il décide de l''objet
de sa recherche, et une recherche sur un virus modifié n''a pas les mêmes
débouchés qu''une recherche sur un vaccin. **Le choix du programme est déjà un
acte moral.**

**Deuxième point.** Les conséquences prévisibles engagent. **Hans Jonas** le
formule pour l''âge technique : agis de façon que les effets de ton action soient
compatibles avec la permanence d''une vie authentiquement humaine sur terre. Ne
pas vouloir savoir ce que son savoir produira est une forme d''irresponsabilité.

**Troisième point.** **Heidegger** montre que la technique n''est pas un outil
neutre qu''on emploierait bien ou mal : elle installe un regard qui traite toute
chose comme une ressource disponible, y compris l''homme. Ce regard-là précède
tout usage.

*La synthèse.* La neutralité vaut pour les **énoncés** et non pour les
**pratiques**. Une équation n''est pas morale ; un protocole d''expérience sur des
êtres humains l''est entièrement.

C''est pourquoi la réponse n''est ni la liberté sans règle ni la censure, mais la
**délibération** : les comités d''éthique ne jugent pas du vrai, dont ils sont
incompétents ; ils jugent de ce que nous acceptons de faire.

*On peut conclure avec Bergson : notre corps a grandi démesurément par la
technique, et ce corps agrandi attend un supplément d''âme. La conscience n''est
pas l''ennemie de la science : elle est devenue sa condition de survie.*
', NULL, 32),
      (v_chapitre_id, 'Simulation : le comité d''éthique', 7, 'interactif', '{
  "widget": "comite-ethique",
  "consigne": "Huit projets de recherche arrivent sur ton bureau — un vaccin testé sans consentement, le clonage humain, un virus modifié « pour mieux s''en défendre », la culture d''organes, une arme autonome — et tu dois les autoriser ou les refuser, en séparant à chaque fois ce qui relève du vrai et ce qui relève du bien. La simulation te montre ensuite ce que chaque décision a produit dix ans plus tard, et te fait constater le point difficile : un refus coûte aussi, et aucune des huit décisions n''est gratuite."
}', NULL, 10),
      (v_chapitre_id, 'Sujet type Baccalauréat — Les limites de la science', 8, 'texte', '
**Deuxième partie de l''épreuve — Évaluation de l''agir compétent — 9 points**

*En te fondant sur ta culture philosophique et dans le respect des règles de la
logique, est-il légitime de penser que la science peut tout connaître ?*

---
---

## Corrigé

### I. Analyse et compréhension du sujet

**Les concepts-clés.** *Science* : connaissance rationnelle, méthodique,
objective et vérifiable des phénomènes. *Tout connaître* : n''avoir aucun objet
hors de sa portée — ce qui suppose à la fois une puissance illimitée et un
domaine illimité. *Pouvoir* : il faut distinguer le pouvoir de droit, que rien
n''interdit, du pouvoir de fait, qui reste à exercer.

**Reformulation.** Avons-nous de bonnes raisons de soutenir qu''aucune réalité
n''échappe par nature à la connaissance scientifique ?

**Le présupposé.** Que tout ce qui est puisse devenir **objet** — c''est-à-dire
être mesuré, isolé, reproduit.

**La thèse opposée.** Certaines réalités ne peuvent pas être objectivées.

**Le problème.** Les limites de la connaissance scientifique.

**La problématique.** Les limites que la science rencontre ne sont-elles que
provisoires, dues à l''état présent de ses moyens, ou tiennent-elles à la nature
même de sa méthode ?

### II. Première tâche — la thèse : la science peut tout connaître *(3 points)*

**Argument 1.** L''extension continue du savoir. Tout ce qu''on avait déclaré
inconnaissable a fini par être connu : la composition des étoiles, l''intérieur
de l''atome, le code génétique, les premiers instants de l''univers. L''histoire
des sciences est un cimetière de limites prétendues.

**Argument 2.** Le déterminisme universel. Si tout phénomène a une cause,
alors tout phénomène est en droit explicable. **Laplace** le pousse à sa
conséquence : une intelligence qui connaîtrait toutes les causes connaîtrait
tout l''avenir.

**Argument 3.** La méthode est extensible. **Claude Bernard** a montré qu''on
pouvait expérimenter sur le vivant, qu''on jugeait rebelle au laboratoire ; la
sociologie de **Durkheim** a traité les faits sociaux « comme des choses ».
Chaque domaine réputé inaccessible a fini par recevoir sa science.

*Transition.* Mais ces conquêtes portent toutes sur des **faits**. En est-il de
même de tout ce qui nous importe ?

### III. Deuxième tâche — l''antithèse : il y a des limites *(3 points)*

**Argument 1.** La science explique **comment**, non **pourquoi**. Elle dit par
quelles lois l''univers fonctionne, et reste muette sur son sens. **Pascal** :
« le cœur a ses raisons que la raison ne connaît point », et « le silence
éternel de ces espaces infinis m''effraie ».

**Argument 2.** Les questions de valeur ne sont pas des questions de fait.
Aucune expérience ne démontrera qu''il est mal de torturer un innocent. Le juste,
le beau, le sacré ne se mesurent pas, et la méthode scientifique ne les manque
pas par faiblesse : ils ne sont pas de son ordre.

**Argument 3.** La limite est inscrite dans la science elle-même. **Popper** :
aucune loi n''est définitivement vérifiable, puisqu''elle porte sur des cas
futurs ; une science n''offre que des conjectures bien testées. **Bachelard**
ajoute que chaque progrès se fait par **rupture**, ce qui interdit de croire au
savoir définitif. Une science qui prétendrait tout savoir ne pourrait plus être
démentie, et cesserait pour cette raison d''être une science.

*Transition.* Faut-il alors fixer d''avance des frontières à la science, au
risque de répéter l''erreur de tous ceux qui l''ont fait avant nous ?

### IV. Troisième tâche — la synthèse *(3 points)*

**Premier moment — distinguer deux sortes de limites.** Les limites de **fait**
sont provisoires : l''histoire des sciences les a toujours déplacées, et il est
imprudent d''en décréter de nouvelles. Les limites de **domaine** sont d''un autre
ordre : elles ne tiennent pas à la puissance de la science mais à sa
**définition**. La science répond à des questions de fait ; les questions de sens
et de valeur n''en sont pas.

**Deuxième moment — ce n''est pas une infirmité.** Reprocher à la science de ne
pas dire le sens de la vie, c''est lui reprocher de n''être pas autre chose
qu''elle-même, comme on reprocherait à un thermomètre de ne pas peser. La
rigueur de la science vient précisément de ce qu''elle se restreint.

**Troisième moment — le danger est le scientisme.** Croire que la science peut
tout connaître, c''est lui faire répondre à des questions qui ne sont pas les
siennes, et cela finit mal : les doctrines qui ont prétendu fonder
scientifiquement une morale ou une politique ont servi à justifier le pire. La
réponse est donc double : **confiance** dans la méthode, et **refus** de son
extension hors de son domaine. **Rabelais** le disait déjà : science sans
conscience n''est que ruine de l''âme ; **Bergson** l''achève : ce corps agrandi
attend un supplément d''âme.

**Conclusion.** Il n''est pas légitime de penser que la science peut tout
connaître — non parce qu''elle serait faible, mais parce que « tout connaître »
suppose que tout soit objet, et que le sens, la valeur et le vécu ne le sont
pas. La science n''a pas de frontière qu''on puisse lui tracer d''avance ; elle a
un domaine, qui est le fait. Reste à savoir ce qui, de notre existence, échappe
ainsi au regard scientifique — et c''est la question du chapitre qui suit.

---

### Ce que le correcteur attend

**La distinction entre limite de fait et limite de domaine.** C''est elle qui
évite les deux mauvaises copies : celle qui prophétise une science toute
puissante, et celle qui fixe arbitrairement des interdits.

**Le piège du « pouvoir ».** Le sujet demande ce que la science **peut**
connaître, non ce qu''elle **doit** faire. Une copie qui part sur Hiroshima et le
clonage traite un autre sujet — ce matériau sert en synthèse, pas en thèse.

**Popper et Bachelard cités du côté des limites**, car c''est plus fort : la
limite est reconnue par les épistémologues eux-mêmes, et non imposée du dehors.
', NULL, 34),
      (v_chapitre_id, 'Quiz du chapitre 10', 9, 'quiz', '{
  "titre": "Vérifie que tu as compris",
  "questions": [
    {
      "question": "Que soutient Bachelard en écrivant « l''opinion pense mal ; elle ne pense pas » ?",
      "choix": [
        "Que l''opinion est un premier pas vers la science",
        "Que l''opinion n''est pas une pensée faible mais autre chose qu''une pensée : elle traduit des besoins en connaissances",
        "Que l''opinion est toujours fausse",
        "Que l''opinion est une croyance"
      ],
      "bonne": 1,
      "explication": "D''où l''obstacle épistémologique : ce qui empêche de connaître n''est pas l''ignorance mais ce qu''on croit déjà savoir. L''élève arrive l''esprit encombré, pas vide."
    },
    {
      "question": "Quelles sont les quatre étapes de la méthode selon Claude Bernard ?",
      "choix": [
        "Doute, évidence, analyse, synthèse",
        "Observation, hypothèse, expérimentation, loi",
        "Thèse, antithèse, synthèse, conclusion",
        "Induction, déduction, vérification, publication"
      ],
      "bonne": 1,
      "explication": "Et son avertissement : « l''expérimentateur doit douter, fuir les idées fixes ». C''est le résultat qui juge l''hypothèse, jamais l''inverse."
    },
    {
      "question": "Quel problème Hume soulève-t-il à propos de l''induction ?",
      "choix": [
        "Qu''elle est trop lente",
        "Qu''aucun nombre de cas observés ne garantit le cas suivant : mille corbeaux noirs n''interdisent pas au mille-et-unième d''être blanc",
        "Qu''elle ne part pas des faits",
        "Qu''elle est réservée aux mathématiques"
      ],
      "bonne": 1,
      "explication": "L''induction reposerait donc sur une habitude, non sur une démonstration. C''est à ce problème que Popper répond par la falsifiabilité."
    },
    {
      "question": "Qu''est-ce que le critère de falsifiabilité de Popper ?",
      "choix": [
        "Un énoncé est scientifique s''il est vérifié",
        "Un énoncé est scientifique si l''on peut dire ce qui le rendrait faux",
        "Un énoncé est scientifique s''il est mathématique",
        "Un énoncé est scientifique s''il est admis par la communauté"
      ],
      "bonne": 1,
      "explication": "Une théorie qui explique tout et que rien ne pourrait démentir sort de la science : expliquer, c''est exclure. La force d''une science se mesure à ce qu''elle interdit."
    },
    {
      "question": "Quelles difficultés propres rencontrent les sciences humaines ?",
      "choix": [
        "Aucune",
        "L''objet est aussi le sujet, l''expérimentation est limitée, et l''objet observé est conscient d''être observé",
        "Elles manquent de mathématiques",
        "Elles sont trop récentes"
      ],
      "bonne": 1,
      "explication": "Durkheim répond en traitant les faits sociaux « comme des choses » ; Weber en cherchant à comprendre le sens que les acteurs donnent à leur action."
    },
    {
      "question": "Que nomme Kuhn un « paradigme » ?",
      "choix": [
        "Une loi scientifique",
        "Le cadre admis par une communauté de savants à une époque, qui change lors des révolutions scientifiques",
        "Une hypothèse réfutée",
        "Un obstacle épistémologique"
      ],
      "bonne": 1,
      "explication": "La science ordinaire travaille dans le paradigme ; quand les anomalies s''accumulent, une révolution change le cadre et les mêmes faits reçoivent un autre sens."
    },
    {
      "question": "Quelle limite de la science est de « domaine » et non de « fait » ?",
      "choix": [
        "La taille de l''univers",
        "Les questions de valeur : aucune expérience ne démontrera qu''il est mal de torturer un innocent",
        "La puissance des instruments",
        "La durée des recherches"
      ],
      "bonne": 1,
      "explication": "Les limites de fait ont toujours été déplacées par l''histoire des sciences. La limite de domaine tient à la définition même de la science : elle répond à des questions de fait."
    }
  ]
}', NULL, 5);

    RAISE NOTICE '% : 9 leçons ajoutées au chapitre 10, La science.', v_nom;
  END LOOP;
END $philo$;
