-- ---------------------------------------------------------------------------
-- M'Andal — Philosophie, classes de Terminale
-- Chapitre 5 : Autrui et la morale
-- Module 1 : La philosophie — 8 leçons
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
    WHERE programme_id = v_programme_id AND ordre = 5;

    IF v_chapitre_id IS NULL THEN
      INSERT INTO public.chapitres (programme_id, titre, ordre, niveau)
      VALUES (v_programme_id, 'Autrui et la morale', 5, 'Module 1 : La philosophie')
      RETURNING id INTO v_chapitre_id;
      RAISE NOTICE '% : chapitre 5 créé.', v_nom;
    END IF;

    -- Les leçons. Si le chapitre en a déjà, on passe son tour sans rien toucher.
    SELECT count(*) INTO v_deja FROM public.concepts WHERE chapitre_id = v_chapitre_id;
    IF v_deja > 0 THEN
      RAISE NOTICE '% : le chapitre 5 a déjà ses % leçons, je n''y touche pas.', v_nom, v_deja;
      CONTINUE;
    END IF;

    INSERT INTO public.concepts
      (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes) VALUES
      (v_chapitre_id, 'Autrui : peut-on le connaître ?', 1, 'texte', '
Autrui n''est pas un objet parmi d''autres. C''est **un autre moi-même** : un
sujet, une conscience, une liberté. Et c''est ce qui rend sa connaissance
problématique.

Je peux faire le tour d''une table. Je ne peux pas faire le tour d''une
conscience.

### Les voies d''accès à autrui

**L''intuition.** On perçoit d''emblée si quelqu''un est bienveillant ou non, sans
passer par la réflexion. **Bergson** soutient que « l''intuition est une saisie
immédiate de la réalité ».

**Le raisonnement par analogie.** Autrui me ressemble ; je comprends ses
attitudes en me référant à moi-même. Quand il sourit, je suppose qu''il est
joyeux, parce que c''est ce que signifie mon propre sourire. **Malebranche**
conjecture que les âmes des autres hommes sont de même espèce que la nôtre.

*La faiblesse de cette voie saute aux yeux : elle projette sur autrui ce que je
suis. Elle me renseigne sur moi autant que sur lui.*

**Le dialogue.** Le langage donne accès aux pensées, aux désirs, aux
intentions. **Merleau-Ponty** écrit que, dans l''expérience du dialogue, ma
pensée et celle de l''autre forment **un seul tissu**.

**L''amitié.** La proximité, le partage et l''entraide font tomber les masques.
**Saint Augustin** soutient qu''on ne connaît personne sinon par amitié.

### Les obstacles

**La liberté.** Autrui est libre : il peut toujours démentir ce que je croyais
savoir de lui. **Sartre** le résume : l''homme est liberté, et une liberté ne se
définit pas.

**La variabilité.** L''homme change et présente plusieurs visages. **Montaigne**
le juge « ondoyant et divers ».

**L''intériorité.** Nul ne peut entrer dans la conscience d''un autre. **Proust**
y voit une ombre impénétrable ; **Gaston Berger** affirme que nul ne peut violer
ma conscience ; **Leibniz** fait de chaque individu une **monade**, une
substance close.

### Le paradoxe à exploiter en dissertation

Les quatre voies d''accès reposent toutes sur une **ressemblance** : autrui est
comme moi, donc je le comprends. Les trois obstacles reposent tous sur une
**différence** : autrui est autre, donc il m''échappe.

Or c''est le même fait qui fonde les deux. Autrui est un autre **moi** — et
c''est pourquoi je peux le connaître. Autrui est un **autre** moi — et c''est
pourquoi je ne le connaîtrai jamais entièrement.

---

**Exercice corrigé**

*Le raisonnement par analogie permet-il de connaître autrui ? Exposer sa force
et sa limite.*

**Correction.**

*Le raisonnement.* Autrui a un corps semblable au mien. Or, quand je souris,
j''éprouve de la joie. Donc, quand il sourit, il éprouve probablement de la
joie. Malebranche formule ainsi cette conjecture : les âmes des autres hommes
sont de même espèce que la nôtre.

*Sa force.* Il est le seul accès dont nous disposions d''emblée, et il
fonctionne : c''est grâce à lui que la vie sociale est possible dès le premier
regard, sans attendre la conversation.

*Sa limite, et elle est double.*

**C''est une induction**, donc une probabilité, jamais une certitude. Un sourire
peut être de politesse, de gêne ou de moquerie.

**Elle projette ce que je suis.** Je comprends autrui en supposant qu''il me
ressemble, ce qui est exactement ce qu''il faudrait établir. Si autrui me
ressemble, l''analogie est inutile ; s''il ne me ressemble pas, elle est fausse.

*La conséquence.* L''analogie ne donne pas accès à autrui comme sujet : elle
donne accès à l''image que je me fais de lui. C''est pourquoi Merleau-Ponty lui
préfère le **dialogue**, où la pensée de l''autre ne se devine pas mais se
construit avec la mienne.
', NULL, 28),
      (v_chapitre_id, 'Simulation : connaître autrui', 2, 'interactif', '{
  "widget": "connaitre-autrui",
  "consigne": "Un personnage t''est présenté par bribes — un geste, une phrase, un silence, une réaction — et tu formules des hypothèses sur ce qu''il pense. La simulation te montre ensuite ce qu''il pensait réellement, et nomme la voie que tu as employée : l''intuition, l''analogie, le dialogue. Elle te fait toucher la limite de l''analogie en te présentant quelqu''un qui ne réagit pas comme toi, et c''est là que tout le chapitre se joue."
}', NULL, 10),
      (v_chapitre_id, 'Les rapports avec autrui : conflit ou paix ?', 3, 'texte', '
Deuxième problème du chapitre, et il est politique autant que moral.

### Thèse : les rapports avec autrui sont conflictuels

**Argument 1 — autrui est naturellement dangereux.** **Hobbes** l''énonce par la
formule latine *homo homini lupus* : « l''homme est un loup pour l''homme ». À
l''état de nature, chacun ayant droit à tout, la guerre de tous contre tous est
inévitable. **Freud** y ajoute la **pulsion de mort**, le *thanatos* : il y a en
l''homme une part d''agressivité qui ne vient pas des circonstances.

**Argument 2 — le regard d''autrui est aliénant.** Tant que je suis seul, je suis
une conscience libre. Dès qu''un autre me regarde, je deviens un **objet** dans
son monde : il me juge, me classe, me fige. **Sartre** en tire sa formule la
plus célèbre : « **l''enfer, c''est les autres** ». Et il analyse la **honte**
comme l''épreuve de cette chute au rang d''objet.

**Argument 3 — la quête de reconnaissance.** Chacun veut être reconnu par
l''autre comme une conscience, et cette exigence conduit à la lutte. **Hegel**
en fait le ressort de la dialectique du maître et de l''esclave.
**Nietzsche** parle de **volonté de puissance**.

### Antithèse : les rapports avec autrui sont pacifiques

**Argument 1 — l''homme naît bon.** **Rousseau** le soutient contre Hobbes :
l''homme à l''état de nature n''est pas méchant, il est seulement ignorant et
plein de **pitié** naturelle. C''est la société qui le corrompt.

**Argument 2 — autrui m''assiste.** Je ne survivrais pas seul, et je ne
deviendrais pas moi-même sans les autres. **Gabriel Marcel** répond
directement à Sartre : « **le ciel, c''est les autres** ».

**Argument 3 — l''amitié, l''amour, la coopération** existent, et il faut en
rendre compte. Les alliances, les associations, les mariages prouvent qu''autrui
n''est pas seulement un rival.

### Le départage possible

Hobbes et Rousseau ne décrivent pas le même homme. Hobbes décrit l''homme **tel
que la rareté le rend** ; Rousseau décrit l''homme **avant** la propriété et la
comparaison. L''opposition n''est donc peut-être pas entre deux natures, mais
entre deux **situations**.

Et le regard d''autrui, que Sartre juge aliénant, est aussi ce par quoi j''existe
pour quelqu''un. Un homme que personne ne regarde n''est pas plus libre : il est
seulement seul.

---

**Exercice corrigé**

*« L''enfer, c''est les autres » (Sartre). Expliquer la formule, puis montrer ce
qu''elle oublie.*

**Correction.**

*L''explication.* La formule n''est pas une plainte de misanthrope. Elle décrit
une structure.

Tant que je suis seul, je suis une **conscience** : un pour-soi, libre,
indéfini. Dès qu''autrui me regarde, je deviens une **chose vue** : un timide,
un paresseux, un bon élève. Autrui me donne une nature que je n''ai pas choisie
et que je ne peux pas contester de l''intérieur, puisqu''elle n''existe que dans
sa conscience à lui.

L''enfer n''est donc pas la méchanceté des autres : c''est le fait que mon être
m''échappe et se décide ailleurs. Sartre analyse la **honte** comme l''épreuve
même de cette chute : j''ai honte de ce que je suis **pour** autrui.

*Ce que la formule oublie.*

**Le regard d''autrui me fait aussi exister.** Sans lui, je ne serais rien pour
personne. Gabriel Marcel renverse la formule : « le ciel, c''est les autres ».

**Autrui est aussi celui qui me révèle à moi-même.** Je ne connais mon visage
que par un miroir, et mes défauts que par quelqu''un qui me les dit. La
conscience de soi passe par la conscience d''autrui — c''est la leçon de Hegel.

**Et la formule est tirée d''une pièce**, *Huis clos*, où trois morts sont
enfermés ensemble pour l''éternité. Sartre lui-même a précisé qu''elle décrivait
un rapport **détérioré** à autrui, non le rapport à autrui en général.

*Le point de méthode : quand une citation est célèbre, en donner le contexte
rapporte des points. Elle est presque toujours plus nuancée qu''on ne le croit.*
', NULL, 30),
      (v_chapitre_id, 'Simulation : Hobbes ou Rousseau ?', 4, 'interactif', '{
  "widget": "etat-de-nature",
  "consigne": "Une île, quelques naufragés, et des ressources que tu règles toi-même. Fais varier la rareté, la proximité et la présence d''une autorité, et regarde le groupe basculer. Avec des vivres en abondance, Rousseau a raison ; avec une seule source d''eau, Hobbes aussi. La simulation te montre que les deux philosophes ne décrivent peut-être pas deux natures humaines, mais deux situations — et c''est exactement le mouvement d''une synthèse."
}', NULL, 10),
      (v_chapitre_id, 'La morale : d''où vient-elle, que vaut-elle ?', 5, 'texte', '
La morale est la seconde moitié du chapitre, et elle se divise en trois
problèmes. Chacun peut faire un sujet.

### Premier problème : la morale est-elle innée ou acquise ?

**Thèse : elle est innée.**

L''homme est naturellement bon et porte en lui des sentiments nobles.
**Rousseau** parle d''une **pitié naturelle** et d''un « principe inné de justice
et de vertu ».

L''homme est naturellement raisonnable, donc disposé au bien. **Descartes**
affirme que le bon sens est la chose du monde la mieux partagée. **Kant**
soutient qu''un être doué de raison et de liberté peut agir moralement sans
qu''aucune source extérieure lui dicte sa conduite.

**Antithèse : elle est acquise.**

Par la **socialisation**, et d''abord par l''éducation. **Freud** voit dans le
**surmoi** l''intériorisation des interdits parentaux et sociaux : la morale est
d''abord la voix du père. **Durkheim** affirme que l''essentiel de notre vie
mentale nous vient de la société.

Par l''**histoire**. **Nietzsche** soutient que la morale est une invention des
**faibles** pour désarmer les forts : en appelant « vertu » la douceur et
« péché » la puissance, les faibles ont retourné leur impuissance en mérite.

Par le **calcul**. Les utilitaristes font de la morale un arbitrage entre des
intérêts, appris par l''expérience.

### Deuxième problème : la morale est-elle relative ou universelle ?

**Thèse : elle est relative.**

Elle varie selon les **sociétés**. **Durkheim** montre que chaque peuple a une
morale déterminée par ses conditions de vie. **Pascal** ironise : « vérité en
deçà des Pyrénées, erreur au-delà ».

Elle varie selon les **individus**. **Protagoras** : « l''homme est la mesure de
toute chose ».

Elle repose parfois sur des critères **subjectifs** — le plaisir, le sentiment,
l''intérêt — qui changent d''une personne à l''autre.

**Antithèse : elle est universelle.**

La morale cherche le bien, et elle le cherche par la **raison**, qui est
commune à tous les hommes. **Kant** en donne le critère, l''**impératif
catégorique** : agis selon une maxime dont tu puisses vouloir qu''elle devienne
une loi universelle. Le test tient en une question : **et si tout le monde en
faisait autant ?**

Et si la morale était purement relative, elle n''existerait pas : le mal
pourrait devenir bien par simple changement d''avis.

### Troisième problème : la morale est-elle bénéfique ou dangereuse ?

**Elle est dangereuse.** **Nietzsche** y voit un frein à la **volonté de
puissance** et à l''épanouissement vital. **Marx** y voit un instrument de
domination : elle adoucit les pauvres pour mieux les exploiter, comme la
religion, cet « opium du peuple ».

**Elle est bénéfique.** Elle distingue l''homme du reste de la nature, parce que
lui seul se donne ses propres lois — **Alain** résume : la morale consiste à se
savoir esprit. Elle mène au bonheur : **Épicure** associe la vie morale à
l''**ataraxie**, l''absence de trouble. Et elle rend la coexistence possible :
**Kant** demande de traiter l''humanité, en soi et chez autrui, toujours comme
une **fin** et jamais seulement comme un **moyen**.

---

**Exercice corrigé**

*Énoncer l''impératif catégorique de Kant et l''appliquer à un cas concret.
Montrer ensuite la limite de ce critère.*

**Correction.**

*L''énoncé.* « Agis uniquement d''après la maxime qui fait que tu peux vouloir en
même temps qu''elle devienne une loi universelle. »

*Ce qu''il demande.* Non pas de regarder les conséquences de mon acte, mais de
vérifier que la **règle** que je me donne pourrait être suivie par tous sans se
détruire elle-même.

*L''application.* Soit la maxime : « je peux mentir quand cela m''arrange. »

Universalisons-la : tout le monde ment dès que cela l''arrange. Alors plus
personne ne croit personne. Mais si plus personne ne croit personne, le
mensonge **ne sert plus à rien** : on ne peut tromper que quelqu''un qui vous
croit.

La maxime se détruit elle-même en devenant universelle. Elle est donc immorale,
et Kant n''a eu besoin d''aucun calcul de conséquences pour l''établir.

*La limite.* Kant refuse toute exception, y compris le mensonge qui sauverait
une vie — il l''écrit explicitement à propos de celui qui cacherait un ami
poursuivi par un meurtrier.

Un critère qui interdit de mentir à un assassin pour sauver un innocent heurte
la conscience commune. **Benjamin Constant** lui a opposé cette objection, et
elle tient : l''impératif catégorique garantit la cohérence de la règle, mais il
reste muet quand deux devoirs s''opposent.

*La réponse kantienne possible, à mentionner pour une bonne copie : la maxime à
universaliser n''est pas « mentir », mais « mentir pour sauver un innocent », et
celle-là peut s''universaliser sans se détruire. Le débat reste ouvert, et c''est
pourquoi il fait un bon sujet.*
', NULL, 32),
      (v_chapitre_id, 'Simulation : le test de l''impératif catégorique', 6, 'interactif', '{
  "widget": "imperatif-categorique",
  "consigne": "Formule une maxime — « je peux mentir quand cela m''arrange », « je peux emprunter sans rendre », « je peux tricher si personne ne voit » — et la simulation l''universalise devant toi : elle fait agir tout le monde ainsi et te montre si la règle survit ou se détruit. Essaie ensuite le cas du mensonge qui sauve une vie, et vois pourquoi Benjamin Constant a objecté à Kant. Un second volet oppose le calcul utilitariste au test kantien sur les mêmes cas."
}', NULL, 10),
      (v_chapitre_id, 'Sujet type Baccalauréat — Faut-il craindre le regard d''autrui ?', 7, 'texte', '
**Deuxième partie de l''épreuve — Évaluation de l''agir compétent — 9 points**

*En te fondant sur ta culture philosophique et dans le respect des règles de la
logique, est-il légitime de penser que le regard d''autrui nous aliène ?*

---
---

## Corrigé

### I. Analyse et compréhension du sujet

**Les concepts-clés.** *Regard d''autrui* : la conscience qu''un autre a de moi,
et par laquelle je deviens objet pour lui. *Aliéner* : du latin *alienus*,
étranger — rendre étranger à soi-même, déposséder.

**Reformulation.** A-t-on de bonnes raisons de soutenir que le fait d''être vu
par un autre nous dépossède de nous-mêmes ?

**Le présupposé.** Le sujet suppose que je suis d''abord à moi-même, et qu''autrui
vient ensuite me prendre quelque chose.

**La thèse opposée.** Le regard d''autrui ne me dépossède pas : il me constitue.

**Le problème.** La nature du rapport à autrui.

**La problématique.** Le regard d''autrui me vole-t-il mon être en me figeant
dans une image, ou bien est-il ce par quoi j''accède à moi-même ?

### II. Première tâche — la thèse : le regard d''autrui aliène *(3 points)*

**Argument 1.** Sous le regard, je cesse d''être une conscience libre pour
devenir un objet. **Sartre** analyse la **honte** comme l''épreuve de cette
chute, et conclut : « l''enfer, c''est les autres ».

**Argument 2.** Autrui me fige dans une essence que je n''ai pas choisie. On me
dit timide, paresseux, bavard, et je dois désormais vivre avec une nature
décidée ailleurs.

**Argument 3.** Le rapport à autrui est originellement conflictuel. **Hobbes** :
« l''homme est un loup pour l''homme ». **Hegel** montre que la rencontre de deux
consciences commence par une lutte pour la reconnaissance. **Freud** y ajoute
la pulsion de mort.

*Transition.* Mais un homme que personne ne regarderait serait-il plus
lui-même, ou seulement plus seul ?

### III. Deuxième tâche — l''antithèse : le regard d''autrui me constitue *(3 points)*

**Argument 1.** Je ne me connais pas moi-même sans autrui. Je ne vois mon
visage que dans un miroir, et mes défauts que par celui qui me les dit. Chez
**Hegel**, la conscience de soi passe par la conscience d''autrui : la lutte
elle-même est le chemin de la reconnaissance.

**Argument 2.** Autrui m''assiste et me fait vivre. **Gabriel Marcel** répond
directement à Sartre : « le ciel, c''est les autres ». L''amitié, l''amour et la
coopération ne sont pas des exceptions mais le tissu ordinaire de l''existence.
**Saint Augustin** soutient qu''on ne connaît personne sinon par amitié.

**Argument 3.** L''homme n''est pas naturellement hostile. **Rousseau** oppose à
Hobbes la **pitié naturelle** : c''est la société, et non la nature, qui
corrompt.

*Transition.* Faut-il alors choisir entre l''enfer et le ciel, ou bien le regard
d''autrui est-il l''un et l''autre selon ce que nous en faisons ?

### IV. Troisième tâche — la synthèse *(3 points)*

**Premier moment.** Chaque thèse a raison contre quelque chose. Sartre a raison
contre l''**illusion de l''autarcie** : personne ne possède son être à l''abri du
regard d''autrui. Marcel et Hegel ont raison contre le **repli** : une conscience
sans autrui ne serait pas plus libre, elle serait vide.

**Deuxième moment — le départage.** Le regard n''aliène pas par lui-même : il
aliène quand il **fige**. Il libère quand il **appelle**. Le professeur qui dit
à un élève « tu es nul en mathématiques » le fige ; celui qui lui dit « tu peux
y arriver » lui ouvre un possible. C''est le même regard, et ce ne sont pas les
mêmes effets.

**Troisième moment.** D''ailleurs, Sartre lui-même a précisé que sa formule,
tirée de *Huis clos*, décrivait un rapport **détérioré** à autrui, non le
rapport à autrui en général.

**Conclusion.** Il n''est pas légitime de penser que le regard d''autrui nous
aliène nécessairement. Il nous expose, c''est vrai, et cette exposition est le
prix de l''existence partagée. Mais c''est par lui que nous devenons quelqu''un.
Reste à savoir ce qui, dans une société, décide que les regards figent ou
qu''ils appellent — et l''on rejoint alors la question du droit et de la justice.

---

### Ce que le correcteur attend

**Que « aliéner » soit défini**, et pas seulement traduit par « gêner ».
L''aliénation est une dépossession, pas un désagrément.

**Que Sartre soit cité correctement**, avec le contexte de *Huis clos* : cela
distingue immédiatement la copie qui a lu de celle qui récite.

**Une synthèse qui tranche.** Ici, le départage se fait sur la distinction
entre un regard qui fige et un regard qui appelle.
', NULL, 34),
      (v_chapitre_id, 'Quiz du chapitre 5', 8, 'quiz', '{
  "titre": "Vérifie que tu as compris",
  "questions": [
    {
      "question": "Sur quoi repose le raisonnement par analogie pour connaître autrui ?",
      "choix": [
        "Sur le dialogue",
        "Sur l''idée qu''autrui me ressemble, et que je peux donc l''interpréter à partir de moi",
        "Sur l''observation scientifique",
        "Sur l''intuition immédiate"
      ],
      "bonne": 1,
      "explication": "Sa limite est double : c''est une induction, donc une probabilité, et elle projette sur autrui ce que je suis — exactement ce qu''il faudrait établir."
    },
    {
      "question": "Que signifie exactement « l''enfer, c''est les autres » ?",
      "choix": [
        "Que les autres sont méchants",
        "Que sous le regard d''autrui je cesse d''être une conscience libre pour devenir un objet dont l''être se décide ailleurs",
        "Qu''il faut vivre seul",
        "Que la société est mal organisée"
      ],
      "bonne": 1,
      "explication": "La formule est tirée de Huis clos, et Sartre a précisé qu''elle décrivait un rapport détérioré à autrui. Donner ce contexte rapporte des points."
    },
    {
      "question": "Qui répond à Sartre par « le ciel, c''est les autres » ?",
      "choix": [
        "Rousseau",
        "Gabriel Marcel",
        "Hegel",
        "Merleau-Ponty"
      ],
      "bonne": 1,
      "explication": "L''argument : autrui m''assiste et me fait exister. Un homme que personne ne regarde n''est pas plus libre, il est seulement seul."
    },
    {
      "question": "Comment Nietzsche explique-t-il l''origine de la morale ?",
      "choix": [
        "Elle vient de la raison",
        "Elle est une invention des faibles pour désarmer les forts",
        "Elle vient de Dieu",
        "Elle est innée"
      ],
      "bonne": 1,
      "explication": "En appelant « vertu » la douceur et « péché » la puissance, les faibles ont retourné leur impuissance en mérite. C''est un argument de la thèse « la morale est acquise »."
    },
    {
      "question": "Quel est le test de l''impératif catégorique de Kant ?",
      "choix": [
        "Calculer les conséquences",
        "Vérifier que la maxime pourrait devenir une loi universelle sans se détruire elle-même",
        "Demander son avis à autrui",
        "Consulter la loi du pays"
      ],
      "bonne": 1,
      "explication": "« Et si tout le monde en faisait autant ? » Universalisé, le mensonge se détruit : on ne peut tromper que quelqu''un qui vous croit."
    },
    {
      "question": "Quelle objection Benjamin Constant adresse-t-il à Kant ?",
      "choix": [
        "Son critère est trop compliqué",
        "Il interdit de mentir même à un assassin pour sauver un innocent",
        "Il ignore la religion",
        "Il copie Rousseau"
      ],
      "bonne": 1,
      "explication": "La réponse kantienne possible : la maxime à universaliser n''est pas « mentir » mais « mentir pour sauver un innocent », et celle-là survit au test."
    },
    {
      "question": "Comment départager Hobbes et Rousseau sur la nature humaine ?",
      "choix": [
        "L''un a raison, l''autre a tort",
        "Ils ne décrivent peut-être pas deux natures mais deux situations : la rareté chez l''un, l''abondance d''avant la propriété chez l''autre",
        "Ils disent la même chose",
        "La question n''a pas de sens"
      ],
      "bonne": 1,
      "explication": "C''est exactement le mouvement attendu d''une synthèse : ne pas trancher entre deux thèses, mais montrer sur quel terrain chacune est vraie."
    }
  ]
}', NULL, 5);

    RAISE NOTICE '% : 8 leçons ajoutées au chapitre 5, Autrui et la morale.', v_nom;
  END LOOP;
END $philo$;
