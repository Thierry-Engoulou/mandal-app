-- ---------------------------------------------------------------------------
-- M'Andal — Philosophie, classes de Terminale
-- Chapitre 4 : La conscience et l'inconscient
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
    WHERE programme_id = v_programme_id AND ordre = 4;

    IF v_chapitre_id IS NULL THEN
      INSERT INTO public.chapitres (programme_id, titre, ordre, niveau)
      VALUES (v_programme_id, 'La conscience et l''inconscient', 4, 'Module 1 : La philosophie')
      RETURNING id INTO v_chapitre_id;
      RAISE NOTICE '% : chapitre 4 créé.', v_nom;
    END IF;

    -- Les leçons. Si le chapitre en a déjà, on passe son tour sans rien toucher.
    SELECT count(*) INTO v_deja FROM public.concepts WHERE chapitre_id = v_chapitre_id;
    IF v_deja > 0 THEN
      RAISE NOTICE '% : le chapitre 4 a déjà ses % leçons, je n''y touche pas.', v_nom, v_deja;
      CONTINUE;
    END IF;

    INSERT INTO public.concepts
      (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes) VALUES
      (v_chapitre_id, 'La conscience : ce que le mot recouvre', 1, 'texte', '
Avant de demander si l''homme est maître chez lui, il faut savoir de quelle
maison on parle. Le mot **conscience** a deux sens, et les confondre rend le
chapitre incompréhensible.

### La conscience psychologique

C''est la **présence à soi** : le fait de savoir ce qui se passe en moi et
autour de moi.

André Lalande en donne la formule de référence : « l''**intuition** plus ou
moins claire que le sujet a de **soi** et de **ses actes** ».

Retenez les deux termes du couple. Je suis conscient de **quelque chose** — un
objet, un bruit, une douleur — et je suis conscient que c''est **moi** qui en
suis conscient. On appelle le premier la conscience **spontanée**, le second la
conscience **réfléchie**.

### La conscience morale

C''est la faculté de **juger du bien et du mal**, et de se juger soi-même. Elle
n''est pas une connaissance mais une évaluation.

Rousseau y voit un « instinct divin ». Socrate évoque son **démon**, cette voix
intérieure qui, dans l''*Apologie de Socrate*, ne lui dit jamais ce qu''il faut
faire mais toujours ce qu''il ne faut pas faire.

### L''inconscient

Le mot a lui aussi deux emplois, et la distinction rapporte un point en examen.

**Au sens adjectif**, est inconscient tout ce qui n''est pas actuellement
conscient : mon numéro de téléphone pendant que je n''y pense pas.

**Au sens substantif**, et c''est le sens freudien, **l''inconscient** est une
**instance** de l''appareil psychique : un ensemble de contenus maintenus hors
de la conscience par une force, et qui continuent d''agir.

Le premier sens n''a jamais fait problème. C''est le second qui a bouleversé la
philosophie.

### Le problème du chapitre

Si la conscience est ce qui définit l''homme, et si une part de lui lui échappe,
alors qui est « je » ? Freud résume la secousse en une formule devenue célèbre :
**« le moi n''est pas maître dans sa propre maison »**.

C''est le sujet tombé au Baccalauréat 2023.

---

**Exercice corrigé**

*Distinguer la conscience psychologique de la conscience morale, en montrant
qu''un même acte peut relever des deux.*

**Correction.**

*Les deux définitions.* La conscience **psychologique** est la faculté par
laquelle le sujet se saisit lui-même et saisit le monde : elle **constate**. La
conscience **morale** est la faculté par laquelle il juge du bien et du mal :
elle **évalue**.

*Le même acte sous les deux regards.* Un élève copie sur son voisin pendant une
composition.

Par sa conscience **psychologique**, il sait ce qu''il fait : il perçoit sa
main, la copie du voisin, le risque. C''est un constat, et il serait le même si
l''acte était anodin.

Par sa conscience **morale**, il sait que ce qu''il fait est mal, et il
l''éprouve comme un malaise avant même d''y réfléchir. C''est ce que Rousseau
appelle l''instinct divin, et ce que Socrate appelait son démon : une voix qui
retient.

*Ce que la distinction permet de comprendre.* On peut avoir une conscience
psychologique parfaite d''un acte et une conscience morale endormie — c''est le
cas du criminel lucide. L''inverse existe aussi : éprouver un remords sans
parvenir à dire de quoi. Les deux facultés sont donc bien distinctes.
', NULL, 26),
      (v_chapitre_id, 'Simulation : conscience, inconscient, ou les deux ?', 2, 'interactif', '{
  "widget": "notions-conscience",
  "consigne": "Douze situations te sont décrites — un lapsus en plein exposé, le remords après une faute, un geste machinal au volant, un rêve, l''oubli du nom de quelqu''un qu''on n''aime pas — et tu les ranges entre conscience psychologique, conscience morale et inconscient. La simulation te renvoie à chaque fois le critère qui tranche, et elle montre les cas où deux réponses se défendent, parce que ce sont eux qui font les bons sujets de dissertation."
}', NULL, 10),
      (v_chapitre_id, 'La thèse rationaliste : le psychisme est essentiellement conscient', 3, 'texte', '
Première thèse du chapitre. Elle est la plus ancienne et elle tient la
philosophie européenne pendant trois siècles.

### Argument 1 : l''homme est un être vigilant

Il est informé de ce qui se passe en lui et autour de lui. C''est la définition
même de Lalande : l''intuition que le sujet a de soi et de ses actes.

### Argument 2 : la conscience est une évidence indubitable

C''est l''argument le plus solide, et il vient de **Descartes**.

Le doute méthodique emporte tout : les sens trompent, les raisonnements se
trompent, le monde entier pourrait être un rêve. Mais une chose résiste : pour
douter, il faut penser, et pour penser, il faut être. **Je pense, donc je
suis.**

La conscience devient ainsi la **première vérité**, celle sur laquelle tout le
reste se construit. Et par là, elle devient transparente à elle-même : rien ne
se passerait en moi que je ne puisse savoir.

### Argument 3 : la conscience fait de l''homme un producteur de connaissances

L''homme peut réfléchir sur lui-même et sur le monde, se prendre lui-même pour
objet. C''est ce retour sur soi qui rend la science possible, et seule la
conscience le permet.

### Argument 4 : la capacité de distinguer le bien du mal

Si l''homme peut juger ses propres actes, c''est qu''il en a conscience. Rousseau
parle d''un « instinct divin » ; Socrate, dans l''*Apologie*, évoque son démon.

### Ce que cette thèse implique

Si le psychisme est tout entier conscient, alors **l''homme est responsable de
tout ce qu''il fait**, puisque rien ne lui échappe. La thèse rationaliste est
donc aussi une thèse morale, et c''est pour cela qu''on tient tant à elle.

---

**Exercice corrigé**

*« Je pense, donc je suis. » Montrer en quoi cette formule fait de la conscience
une évidence, et quelle conséquence elle entraîne pour le problème de
l''inconscient.*

**Correction.**

*La démarche.* Descartes cherche une vérité qui résiste à tout doute. Il écarte
successivement les sens, qui l''ont déjà trompé ; les raisonnements, où l''on se
trompe aussi ; et le monde lui-même, qui pourrait n''être qu''un rêve.

*Le point de résistance.* Une chose ne peut pas être mise en doute : au moment
même où je doute, **je pense**, et ce qui pense doit exister. Le doute, en se
poussant à bout, se détruit lui-même et laisse apparaître une certitude.

*Pourquoi c''est une évidence.* Elle n''est pas démontrée par autre chose ; elle
se saisit immédiatement, et elle ne peut pas être niée sans être confirmée —
car pour la nier, il faut penser.

*La conséquence pour l''inconscient.* Si la conscience est la première vérité, et
si je me saisis moi-même immédiatement, alors **rien en moi ne peut m''être
étranger**. L''hypothèse d''un psychisme inconscient devient contradictoire : ce
serait une pensée que personne ne pense.

C''est précisément cette conséquence que Freud va contester, et c''est pourquoi
la psychanalyse a été reçue comme une blessure infligée à l''orgueil humain.
', NULL, 28),
      (v_chapitre_id, 'Simulation : le doute cartésien pas à pas', 4, 'interactif', '{
  "widget": "doute-cartesien",
  "consigne": "Tu mènes le doute toi-même. La simulation te présente des certitudes — ce que tu vois, ce que tu calcules, l''existence de ton corps, l''existence du monde — et tu les élimines une par une en appliquant l''argument qui convient : l''illusion des sens, l''erreur de raisonnement, le rêve, le malin génie. Quand il ne reste plus rien, la simulation te demande ce qui résiste encore, et te montre pourquoi nier le cogito revient à le confirmer."
}', NULL, 10),
      (v_chapitre_id, 'La thèse psychanalytique : l''inconscient existe à côté de la conscience', 5, 'texte', '
Seconde thèse, et elle date de 1900. Freud ne nie pas la conscience : il nie
qu''elle soit **tout** le psychisme.

### Argument 1 : l''homme ne maîtrise pas ses phénomènes psychiques

Des faits ordinaires résistent à l''explication par la conscience : les
**rêves**, les **lapsus**, les **actes manqués**, l''**oubli** sélectif, les
**névroses**.

Qui n''a jamais oublié le rendez-vous qu''il redoutait, ou appelé quelqu''un par
le prénom d''un autre au plus mauvais moment ?

Freud en tire la conséquence : « pour mieux comprendre la vie psychique, il
faut cesser de surestimer la conscience ». Les données de la conscience sont
**lacunaires** : elles laissent des trous que seule une autre hypothèse comble.

### Argument 2 : la psychanalyse décrit ce qui échappe à la conscience

Freud propose deux descriptions successives de l''appareil psychique. On les
appelle les **topiques**, du grec *topos*, le lieu.

**La première topique (1900)** distingue trois degrés : le **conscient**, ce
dont je m''aperçois maintenant ; le **préconscient**, ce qui est disponible si
j''y pense ; l''**inconscient**, ce qui m''est inaccessible, maintenu à distance
par la **censure**.

**La seconde topique (1923)** ne remplace pas la première : elle décrit des
**instances** là où la première décrivait des degrés. Le **ça**, réservoir des
pulsions, sans ordre ni morale ni patience. Le **surmoi**, les interdits
parentaux et sociaux intériorisés. Le **moi**, pressé des deux côtés, qui
arbitre comme il peut — et qui n''est pas maître chez lui.

### Argument 3 : le déterminisme psychique

Rien n''arrive au hasard dans la vie psychique. Les expériences de l''enfance,
notamment les traumatismes, sont conservées et structurent les comportements de
l''adulte.

Le poète **Wordsworth** l''avait dit avant Freud : « **l''enfant est le père de
l''homme** ». Le théologien **Roger Ebacher** résume la thèse en une formule
qu''on peut citer : l''inconscient « agit **en nous, sans nous et malgré nous** ».

### Les trois blessures

Freud présentait sa découverte comme la troisième humiliation infligée à
l''orgueil humain. Copernic a retiré à la Terre le centre du monde. Darwin a
retiré à l''homme sa place à part dans le vivant. La psychanalyse lui retire la
maîtrise de lui-même.

### Les objections

Elles sont au programme, et il faut les connaître.

**Alain** et les rationalistes refusent l''hypothèse : elle fournit une excuse
commode, et elle transforme l''homme en spectateur de lui-même.

**Sartre** va plus loin : l''inconscient est une **mauvaise foi**. Dire « mon
inconscient m''y a poussé », c''est se mentir à soi-même pour fuir sa liberté. Et
il pose une objection logique redoutable : la censure doit savoir ce qu''elle
refoule pour le refouler — elle est donc consciente de ce qu''elle rend
inconscient.

**Karl Popper** objecte que la théorie n''est pas **réfutable** : elle explique
un comportement et son contraire, et une théorie que rien ne peut démentir
n''est pas scientifique.

---

**Exercice corrigé**

*Expliquer la formule de Freud : « le moi n''est pas maître dans sa propre
maison ». Puis présenter l''objection de Sartre.*

**Correction.**

*L''explication.* La métaphore est domestique. La **maison**, c''est le psychisme.
Le **moi**, c''est la conscience, qui croit y régner. Freud soutient qu''elle n''y
règne pas : elle y habite, elle y arbitre, mais les décisions se prennent
ailleurs.

Dans la seconde topique, le moi est pressé par trois exigences qu''il ne
contrôle pas : les pulsions du **ça**, les interdits du **surmoi**, et les
contraintes du **réel**. Il n''est donc pas l''auteur de ce qu''il fait, mais le
négociateur entre des forces qui le dépassent.

*Les preuves que Freud invoque.* Le rêve, le lapsus, l''acte manqué, le symptôme
névrotique : autant de conduites qui ont un **sens** sans que le sujet l''ait
voulu.

*L''objection de Sartre.* Elle a deux faces.

**Sur le plan moral** : invoquer l''inconscient relève de la **mauvaise foi**.
L''homme est libre, et dire « ce n''est pas moi, c''est mon inconscient » est une
manière de refuser cette liberté tout en continuant d''en user. Sartre écrit :
« l''homme est condamné à être libre ».

**Sur le plan logique** : pour refouler un contenu, la censure doit d''abord le
**reconnaître** comme dangereux. Elle sait donc ce qu''elle ne veut pas savoir.
L''inconscient freudien supposerait ainsi une conscience qui se cache quelque
chose à elle-même, ce qui est la définition même de la mauvaise foi.

*Transition possible.* L''objection de Sartre est forte, mais elle suppose
résolu ce qui est en question : que la conscience soit entièrement transparente
à elle-même.
', NULL, 32),
      (v_chapitre_id, 'Figure : les deux topiques freudiennes', 6, 'figure', '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 560 280" width="560" height="280">
<rect width="560" height="280" fill="#ffffff"/>
<text x="280" y="24" text-anchor="middle" font-size="14" font-weight="700" fill="#0f172a">Les deux topiques de Freud</text>
<text x="280" y="42" text-anchor="middle" font-size="10" fill="#64748b">Deux descriptions du même appareil psychique, à vingt-cinq ans d&apos;écart</text>

<text x="140" y="66" text-anchor="middle" font-size="11" font-weight="700" fill="#2563eb">Première topique — 1900</text>
<rect x="40" y="76" width="200" height="40" rx="4" fill="#dbeafe" stroke="#2563eb" stroke-width="1.6"/>
<text x="140" y="94" text-anchor="middle" font-size="11" font-weight="700" fill="#1e3a8a">LE CONSCIENT</text>
<text x="140" y="108" text-anchor="middle" font-size="8" fill="#1e40af">ce dont je m&apos;aperçois maintenant</text>

<rect x="40" y="122" width="200" height="40" rx="4" fill="#e0e7ff" stroke="#6366f1" stroke-width="1.6"/>
<text x="140" y="140" text-anchor="middle" font-size="11" font-weight="700" fill="#3730a3">LE PRÉCONSCIENT</text>
<text x="140" y="154" text-anchor="middle" font-size="8" fill="#4338ca">disponible si j&apos;y pense</text>

<rect x="40" y="168" width="200" height="60" rx="4" fill="#ede9fe" stroke="#7c3aed" stroke-width="1.6"/>
<text x="140" y="190" text-anchor="middle" font-size="11" font-weight="700" fill="#4c1d95">L&apos;INCONSCIENT</text>
<text x="140" y="204" text-anchor="middle" font-size="8" fill="#5b21b6">inaccessible à la volonté</text>
<text x="140" y="216" text-anchor="middle" font-size="8" fill="#5b21b6">mais agissant sans cesse</text>

<line x1="40" y1="166" x2="240" y2="166" stroke="#b91c1c" stroke-width="2" stroke-dasharray="5 3"/>
<text x="248" y="170" font-size="8" fill="#b91c1c">la censure</text>

<text x="420" y="66" text-anchor="middle" font-size="11" font-weight="700" fill="#15803d">Seconde topique — 1923</text>

<rect x="320" y="76" width="200" height="40" rx="4" fill="#fef3c7" stroke="#ca8a04" stroke-width="1.6"/>
<text x="420" y="94" text-anchor="middle" font-size="11" font-weight="700" fill="#78350f">LE SURMOI</text>
<text x="420" y="108" text-anchor="middle" font-size="8" fill="#92400e">les interdits intériorisés</text>

<rect x="320" y="122" width="200" height="40" rx="4" fill="#dcfce7" stroke="#15803d" stroke-width="1.6"/>
<text x="420" y="140" text-anchor="middle" font-size="11" font-weight="700" fill="#14532d">LE MOI</text>
<text x="420" y="154" text-anchor="middle" font-size="8" fill="#166534">il arbitre, et il n&apos;est pas maître</text>

<rect x="320" y="168" width="200" height="60" rx="4" fill="#fee2e2" stroke="#b91c1c" stroke-width="1.6"/>
<text x="420" y="190" text-anchor="middle" font-size="11" font-weight="700" fill="#7f1d1d">LE ÇA</text>
<text x="420" y="204" text-anchor="middle" font-size="8" fill="#991b1b">les pulsions, sans ordre</text>
<text x="420" y="216" text-anchor="middle" font-size="8" fill="#991b1b">ni morale ni patience</text>

<path d="M 420 168 L 420 162" stroke="#334155" stroke-width="1.4"/>
<path d="M 420 122 L 420 116" stroke="#334155" stroke-width="1.4"/>
<text x="534" y="145" text-anchor="end" font-size="8" fill="#64748b">pressé des deux côtés</text>

<text x="280" y="252" text-anchor="middle" font-size="10" fill="#334155">La seconde ne remplace pas la première : elle décrit des INSTANCES là où</text>
<text x="280" y="268" text-anchor="middle" font-size="10" font-weight="700" fill="#0f172a">la première décrivait des DEGRÉS de conscience.</text>
</svg>', NULL, 5),
      (v_chapitre_id, 'Simulation : les deux topiques', 7, 'interactif', '{
  "widget": "topiques-freud",
  "consigne": "Les deux topiques s''affichent côte à côte, vides, et tu y places les éléments : conscient, préconscient, inconscient d''un côté, ça, moi, surmoi de l''autre. La simulation te soumet ensuite des conduites — un enfant qui vole un fruit et s''arrête, un lapsus devant son professeur, un rêve — et te demande quelle instance a parlé. Un dernier volet te montre pourquoi la seconde topique ne remplace pas la première : elles ne décrivent pas la même chose."
}', NULL, 10),
      (v_chapitre_id, 'Sujet type Baccalauréat — « Le moi n''est pas maître dans sa propre maison »', 8, 'texte', '
**Deuxième partie de l''épreuve — Évaluation de l''agir compétent — 9 points**

*En te fondant sur ta culture philosophique et dans le respect des règles de la
logique, est-il légitime de penser avec Sigmund Freud que « le moi n''est pas
maître dans sa propre maison » ?*

*Session 2023, séries C, D, E et TI.*

---
---

## Corrigé

### I. Analyse et compréhension du sujet

**Les concepts-clés.** *Moi* : l''instance consciente, le sujet qui dit « je ».
*Maître* : celui qui dispose, décide et répond. *Maison* : ici, le psychisme,
par métaphore.

**Reformulation.** A-t-on de bonnes raisons de soutenir que la conscience ne
gouverne pas la vie psychique ?

**Le présupposé.** Le sujet suppose que le psychisme comporte autre chose que
la conscience.

**La thèse opposée.** La conscience est souveraine et transparente à
elle-même.

**Le problème.** La nature du psychisme humain.

**La problématique.** La conscience est-elle le tout du psychisme, ou bien
n''en est-elle que la partie éclairée ? Et si elle n''en est qu''une partie, que
devient la responsabilité de l''homme ?

**La forme.** Sujet-citation : le plan sera explication, limites,
réinterprétation.

### II. Première tâche — explication et commentaire *(3 points)*

**Ce que la formule signifie.** Le moi habite le psychisme sans le gouverner.
Les décisions se prennent ailleurs, dans ce que Freud appelle l''inconscient.

**Argument 1 — les faits que la conscience n''explique pas.** Rêves, lapsus,
actes manqués, oublis sélectifs, symptômes névrotiques. Tous ont un sens, et
aucun n''a été voulu. Freud en conclut qu''il faut cesser de surestimer la
conscience, dont les données sont lacunaires.

**Argument 2 — la description de l''appareil psychique.** Première topique :
conscient, préconscient, inconscient, séparés par la censure. Seconde topique :
le moi pressé entre le ça, le surmoi et le réel. Dans les deux cas, le moi
n''est qu''une pièce parmi d''autres.

**Argument 3 — le déterminisme psychique.** L''enfance structure l''adulte.
Wordsworth : « l''enfant est le père de l''homme ». Roger Ebacher : l''inconscient
« agit en nous, sans nous et malgré nous ».

*Transition.* Mais si le moi n''est pas maître chez lui, qui donc répond de nos
actes ?

### III. Deuxième tâche — les limites *(3 points)*

**Argument 1 — l''évidence du cogito.** Descartes établit que la conscience est
la première vérité, celle qui résiste au doute le plus radical. Une pensée que
personne ne pense est une contradiction dans les termes.

**Argument 2 — l''objection logique de Sartre.** Pour refouler un contenu, la
censure doit le reconnaître comme dangereux : elle sait donc ce qu''elle ne veut
pas savoir. L''inconscient supposerait une conscience qui se cache quelque chose
à elle-même, c''est-à-dire exactement ce que Sartre appelle la **mauvaise foi**.

**Argument 3 — la conséquence morale.** Si le moi n''est pas maître, personne
n''est responsable. Le voleur, le violent, le menteur invoqueront leur
inconscient, et la notion de faute s''effondre. Sartre refuse ce refuge :
« l''homme est condamné à être libre ».

*On peut ajouter l''objection épistémologique de Popper : une théorie qui
explique aussi bien un comportement que son contraire n''est pas réfutable, donc
pas scientifique.*

*Transition.* Faut-il alors rejeter la découverte de Freud, ou l''avons-nous mal
entendue ?

### IV. Troisième tâche — réinterprétation *(3 points)*

**Premier moment.** La formule ne dit pas que le moi n''est rien : elle dit
qu''il n''est pas **maître**. Nuance décisive. Un homme peut habiter une maison
dont il ne connaît pas toutes les pièces sans cesser d''y vivre et d''y décider.

**Deuxième moment.** Freud ne soigne pas pour excuser. Toute sa pratique vise
à **étendre** le domaine du moi. Sa formule la plus exacte n''est pas celle du
sujet mais celle-ci : « **Là où était le Ça, le Je doit advenir.** » La
psychanalyse est une entreprise de libération, pas de déresponsabilisation.

**Troisième moment — la réponse.** Il est légitime de penser avec Freud que le
moi n''est pas maître dans sa propre maison, à condition d''entendre la formule
comme un **constat de départ** et non comme un verdict. Elle ne supprime pas la
liberté : elle en indique le prix, qui est la lucidité. Sartre et Freud, qui
s''opposent, se rejoignent sur ce point — pour l''un comme pour l''autre, l''homme
doit devenir ce qu''il est.

**Conclusion.** La conscience n''est pas le tout du psychisme, mais elle en
reste le lieu de la décision. La formule de Freud est légitime si elle invite à
connaître ce qui nous échappe, illégitime si elle sert d''alibi. Reste à savoir
si cette connaissance de soi est possible seul, ou si elle exige le détour par
autrui.

---

### Ce que le correcteur attend

**La nuance entre « n''est pas maître » et « n''existe pas ».** Les copies qui
font dire à Freud que la conscience est une illusion n''ont pas lu la formule.

**Au moins trois auteurs par tâche**, et au moins un qui ne soit pas Freud.

**La citation « Là où était le Ça, le Je doit advenir »** en troisième partie :
c''est elle qui retourne le sujet.
', NULL, 36),
      (v_chapitre_id, 'Quiz du chapitre 4', 9, 'quiz', '{
  "titre": "Vérifie que tu as compris",
  "questions": [
    {
      "question": "Quelle définition André Lalande donne-t-il de la conscience ?",
      "choix": [
        "La faculté de juger du bien et du mal",
        "L''intuition plus ou moins claire que le sujet a de soi et de ses actes",
        "Le contraire de l''inconscient",
        "La mémoire des évènements passés"
      ],
      "bonne": 1,
      "explication": "C''est la conscience psychologique. La conscience morale, elle, évalue au lieu de constater, et Rousseau y voit un « instinct divin »."
    },
    {
      "question": "Quelle est la différence entre « inconscient » adjectif et « l''inconscient » de Freud ?",
      "choix": [
        "Aucune",
        "L''adjectif désigne ce qui n''est pas actuellement conscient ; le substantif désigne une instance du psychisme maintenue hors de la conscience par une force",
        "L''adjectif est plus récent",
        "Le substantif désigne le sommeil"
      ],
      "bonne": 1,
      "explication": "Le premier sens n''a jamais fait problème. C''est le second qui a bouleversé la philosophie, et la distinction rapporte un point en examen."
    },
    {
      "question": "Pourquoi le cogito de Descartes rend-il la conscience indubitable ?",
      "choix": [
        "Parce que Descartes était très célèbre",
        "Parce qu''au moment même où je doute, je pense, et que ce qui pense doit exister : nier le cogito revient à le confirmer",
        "Parce que les sens ne trompent jamais",
        "Parce que Dieu le garantit"
      ],
      "bonne": 1,
      "explication": "Le doute, poussé à bout, se détruit lui-même et laisse apparaître une certitude. C''est pourquoi l''hypothèse d''un psychisme inconscient a paru contradictoire."
    },
    {
      "question": "Que distingue la première topique de Freud ?",
      "choix": [
        "Le ça, le moi et le surmoi",
        "Le conscient, le préconscient et l''inconscient",
        "Le corps et l''esprit",
        "Le bien et le mal"
      ],
      "bonne": 1,
      "explication": "La première topique décrit des DEGRÉS de conscience, séparés par la censure. La seconde, en 1923, décrit des INSTANCES : le ça, le moi, le surmoi."
    },
    {
      "question": "Quelle instance de la seconde topique contient les interdits intériorisés ?",
      "choix": [
        "Le ça",
        "Le surmoi",
        "Le moi",
        "Le préconscient"
      ],
      "bonne": 1,
      "explication": "Le ça est le réservoir des pulsions, le moi arbitre entre les trois exigences, et le surmoi porte les interdits parentaux et sociaux."
    },
    {
      "question": "En quoi consiste l''objection logique de Sartre à l''inconscient ?",
      "choix": [
        "L''inconscient n''est pas observable",
        "Pour refouler un contenu, la censure doit d''abord le reconnaître comme dangereux : elle sait donc ce qu''elle ne veut pas savoir",
        "Freud n''était pas philosophe",
        "L''inconscient n''explique pas les rêves"
      ],
      "bonne": 1,
      "explication": "Sartre y voit la définition même de la mauvaise foi : une conscience qui se cache quelque chose à elle-même. Sur le plan moral, il refuse qu''on invoque l''inconscient pour fuir sa liberté."
    },
    {
      "question": "Quelle formule de Freud sert à retourner le sujet en troisième partie ?",
      "choix": [
        "« Le moi n''est pas maître dans sa propre maison »",
        "« Là où était le Ça, le Je doit advenir »",
        "« L''enfant est le père de l''homme »",
        "« Dieu est mort »"
      ],
      "bonne": 1,
      "explication": "Elle montre que la psychanalyse vise à ÉTENDRE le domaine du moi, et non à excuser l''homme. C''est elle qui transforme le constat en programme."
    }
  ]
}', NULL, 5);

    RAISE NOTICE '% : 9 leçons ajoutées au chapitre 4, La conscience et l''inconscient.', v_nom;
  END LOOP;
END $philo$;
