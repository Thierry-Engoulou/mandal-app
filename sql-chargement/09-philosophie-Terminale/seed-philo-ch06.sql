-- ---------------------------------------------------------------------------
-- M'Andal — Philosophie, classes de Terminale
-- Chapitre 6 : Droit et justice
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
    WHERE programme_id = v_programme_id AND ordre = 6;

    IF v_chapitre_id IS NULL THEN
      INSERT INTO public.chapitres (programme_id, titre, ordre, niveau)
      VALUES (v_programme_id, 'Droit et justice', 6, 'Module 1 : La philosophie')
      RETURNING id INTO v_chapitre_id;
      RAISE NOTICE '% : chapitre 6 créé.', v_nom;
    END IF;

    -- Les leçons. Si le chapitre en a déjà, on passe son tour sans rien toucher.
    SELECT count(*) INTO v_deja FROM public.concepts WHERE chapitre_id = v_chapitre_id;
    IF v_deja > 0 THEN
      RAISE NOTICE '% : le chapitre 6 a déjà ses % leçons, je n''y touche pas.', v_nom, v_deja;
      CONTINUE;
    END IF;

    INSERT INTO public.concepts
      (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes) VALUES
      (v_chapitre_id, 'Droit naturel et droit positif', 1, 'texte', '
Tout ce chapitre tient à une distinction. Si vous la maîtrisez, vous tenez le
sujet ; si vous la manquez, vous tournez en rond.

### Le droit positif

C''est le droit **effectivement posé** : l''ensemble des règles écrites,
édictées par une autorité souveraine, en vigueur dans un pays à une époque
donnée, et appliquées par des tribunaux.

Le Code pénal camerounais est du droit positif. Il est **particulier** — il
n''est pas celui du Nigeria —, **modifiable** — on le vote, on l''abroge —, et
**contraignant** — il s''impose par la force publique.

### Le droit naturel

C''est le droit tel qu''il **devrait être** : un ensemble de principes
universels, antérieurs à toute loi écrite, fondés sur la nature de l''homme ou
sur la raison.

Il est **universel**, **immuable** et **idéal**. On ne le vote pas : on le
découvre.

### Pourquoi la distinction est décisive

Posez-vous cette question : **que veut dire « cette loi est injuste » ?**

Si le droit se réduit au droit positif, la phrase n''a aucun sens. Une loi est
la loi ; dire qu''elle est injuste reviendrait à dire qu''elle n''est pas conforme
à elle-même.

Pour pouvoir juger une loi, il faut une **mesure extérieure** à elle. Cette
mesure est le droit naturel. C''est au nom du droit naturel que l''esclavage,
pourtant parfaitement légal pendant des siècles, a pu être déclaré injuste.

### La loi, la justice, la légalité, la légitimité

Quatre mots qu''il faut savoir séparer, et la confusion coûte des points.

La **loi** est la règle. La **justice** est la vertu qui donne à chacun ce qui
lui revient. Est **légal** ce qui est conforme à la loi en vigueur. Est
**légitime** ce qui est fondé en raison et en justice.

Et le point central : **le légal et le légitime ne coïncident pas toujours**.
Une loi peut être légale et illégitime — les lois raciales en sont l''exemple.
Un acte peut être illégal et légitime — la désobéissance à une telle loi.

André Lalande définit la loi comme une règle générale qui régit l''activité
humaine **de l''extérieur**. Retenez ce « de l''extérieur » : il distingue la loi
juridique de la loi morale, que je me donne moi-même.

---

**Exercice corrigé**

*Définir le droit positif et le droit naturel. Montrer ensuite qu''une loi peut
être légale et injuste, et préciser ce que cette possibilité suppose.*

**Correction.**

*Les définitions.* Le **droit positif** est l''ensemble des règles écrites,
édictées par une autorité souveraine, en vigueur dans une société déterminée et
assorties d''une contrainte. Le **droit naturel** est l''ensemble des principes
universels et immuables, fondés sur la raison ou la nature de l''homme, au nom
desquels on juge les lois.

*Une loi légale et injuste.* Prenons une loi qui priverait une catégorie de
citoyens du droit de propriété en raison de leur origine. Elle est **légale**
si elle a été votée selon les formes par l''autorité compétente. Elle est
**injuste** parce qu''elle traite inégalement des êtres égaux en dignité.

*Ce que cette possibilité suppose.* Pour dire d''une loi qu''elle est injuste, il
faut disposer d''un critère **qui ne soit pas elle-même**. Si la seule mesure du
juste était la loi en vigueur, aucune loi ne pourrait jamais être dite
injuste : toutes seraient justes par définition, et le mot « injustice » ne
désignerait rien.

La critique des lois suppose donc le droit naturel. C''est pourquoi les
positivistes les plus rigoureux, qui réduisent le droit au droit positif, ont
beaucoup de mal à condamner une législation inique autrement qu''au nom de leurs
préférences.
', NULL, 28),
      (v_chapitre_id, 'Figure : droit naturel et droit positif', 2, 'figure', '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 560 270" width="560" height="270">
<rect width="560" height="270" fill="#ffffff"/>
<text x="280" y="24" text-anchor="middle" font-size="14" font-weight="700" fill="#0f172a">Droit naturel et droit positif</text>
<text x="280" y="42" text-anchor="middle" font-size="10" fill="#64748b">Deux sens du mot « droit », et tout le chapitre tient à leur écart</text>

<rect x="20" y="58" width="252" height="150" rx="6" fill="#dbeafe" stroke="#2563eb" stroke-width="1.8"/>
<text x="146" y="80" text-anchor="middle" font-size="12" font-weight="700" fill="#1e3a8a">LE DROIT NATUREL</text>
<text x="146" y="98" text-anchor="middle" font-size="9" fill="#1e40af">ce qui devrait être</text>
<line x1="36" y1="108" x2="256" y2="108" stroke="#60a5fa"/>
<text x="34" y="126" font-size="9" fill="#1e40af">· universel, le même partout</text>
<text x="34" y="142" font-size="9" fill="#1e40af">· immuable, il ne se vote pas</text>
<text x="34" y="158" font-size="9" fill="#1e40af">· fondé sur la raison ou la nature</text>
<text x="34" y="174" font-size="9" fill="#1e40af">· il juge les lois</text>
<text x="146" y="196" text-anchor="middle" font-size="9" font-style="italic" fill="#475569">« cette loi est injuste »</text>

<rect x="288" y="58" width="252" height="150" rx="6" fill="#fef3c7" stroke="#ca8a04" stroke-width="1.8"/>
<text x="414" y="80" text-anchor="middle" font-size="12" font-weight="700" fill="#78350f">LE DROIT POSITIF</text>
<text x="414" y="98" text-anchor="middle" font-size="9" fill="#92400e">ce qui est effectivement posé</text>
<line x1="304" y1="108" x2="524" y2="108" stroke="#facc15"/>
<text x="302" y="126" font-size="9" fill="#92400e">· particulier à un pays, à une époque</text>
<text x="302" y="142" font-size="9" fill="#92400e">· modifiable, il se vote et s&apos;abroge</text>
<text x="302" y="158" font-size="9" fill="#92400e">· écrit, appliqué par des tribunaux</text>
<text x="302" y="174" font-size="9" fill="#92400e">· il contraint</text>
<text x="414" y="196" text-anchor="middle" font-size="9" font-style="italic" fill="#475569">« la loi dit ceci »</text>

<path d="M 146 208 L 146 226 L 414 226 L 414 208" fill="none" stroke="#b91c1c" stroke-width="1.6"/>
<text x="280" y="246" text-anchor="middle" font-size="10" font-weight="700" fill="#7f1d1d">Sans droit naturel, aucune loi ne peut être dite injuste.</text>
<text x="280" y="262" text-anchor="middle" font-size="10" fill="#475569">Sans droit positif, aucune justice n&apos;est appliquée.</text>
</svg>', NULL, 5),
      (v_chapitre_id, 'Simulation : légal ou légitime ?', 3, 'interactif', '{
  "widget": "legal-legitime",
  "consigne": "Douze situations te sont soumises — une loi votée qui prive une catégorie de ses biens, un vol pour nourrir un enfant, une grève interdite, un impôt contesté — et tu dois croiser deux questions : est-ce légal, est-ce légitime ? Les quatre cases du tableau se remplissent, et tu découvres que les deux diagonales existent vraiment. La simulation te montre ensuite ce qu''il advient d''un raisonnement qui confond les deux mots."
}', NULL, 10),
      (v_chapitre_id, 'Le droit se fonde-t-il sur la force ?', 4, 'texte', '
Premier problème du chapitre, et il est redoutable, parce que la réponse la
plus cynique est aussi la plus observable.

### Thèse : le droit se fonde sur la force

**Argument 1 — la loi naturelle.** Dans la nature, le plus fort l''emporte, et
le droit ne serait que la mise en forme de ce fait. **Spinoza** lie le droit
naturel à la **puissance** de chaque individu : chacun a droit à tout ce qu''il
peut. **Calliclès**, dans le *Gorgias* de Platon, définit la justice comme la
supériorité du meilleur et du plus fort sur les plus faibles.

**Argument 2 — les faits sociaux.** Ce sont les puissants qui écrivent les
lois. **Platon** fait dire à Thrasymaque, dans *La République*, que le juste
est partout ce qui profite au plus fort. **La Fontaine** en fait une morale :
« la raison du plus fort est toujours la meilleure ». **Bismarck** soutient que
la force crée le droit.

**Argument 3 — le droit codifie les injustices.** Pour **Marx**, le droit
positif organise, sous forme de lois, l''oppression d''une classe par une autre.
Le droit de propriété protège surtout ceux qui ont des propriétés.

### Antithèse : le droit ne se fonde pas sur la force

**Argument 1 — le droit se fonde sur la raison.** **Montesquieu**, dans *De
l''esprit des lois* (livre I, chapitre 3), écrit que « la loi est la raison
humaine en tant qu''elle gouverne tous les peuples de la terre ». La raison
étant universelle, le droit qui s''y fonde peut valoir pour tous.

**Argument 2 — le droit se fonde sur un contrat.** **Rousseau** : le droit naît
de la **volonté générale**, et « l''obéissance à la loi qu''on s''est prescrite est
liberté ». Ce n''est pas la force qui oblige, c''est l''accord.

**Argument 3 — la force ne peut pas fonder le droit, logiquement.** C''est
l''argument décisif, et Rousseau le donne au premier livre du *Contrat social*.

Si la force fonde le droit, alors dès que la force change de camp, le droit
change avec elle. Or un droit qui cesse d''être valable dès qu''on est le plus
faible n''oblige personne : il n''y aurait plus de devoir d''obéir, seulement une
nécessité de céder.

Rousseau le formule ainsi : **céder à la force est un acte de nécessité, non de
volonté** ; tout au plus un acte de prudence. Une force à laquelle on cède ne
crée aucune obligation, et une obligation qui disparaît avec la force n''est pas
une obligation.

### Le départage

Les deux thèses ne parlent pas de la même chose.

La première décrit **l''origine historique** des lois : elles ont souvent été
imposées par les puissants, et c''est un fait.

La seconde énonce **la condition de leur validité** : pour qu''une règle oblige
en conscience, il faut autre chose que la contrainte.

Un droit peut donc avoir une origine violente et une légitimité acquise ensuite
— c''est le cas du suffrage universel, arraché par des luttes.

---

**Exercice corrigé**

*Rousseau écrit que « céder à la force est un acte de nécessité, non de
volonté ». Montrer en quoi cette phrase réfute la thèse du droit du plus fort.*

**Correction.**

*Ce que soutient la thèse adverse.* Le plus fort a raison ; sa puissance crée
son droit ; obéir au plus fort est donc un devoir.

*L''argument de Rousseau.* Il distingue deux choses que la thèse confond :
**céder** et **obéir**.

Quand un brigand me menace d''une arme et que je lui donne ma bourse, je
**cède**. Mon geste est un acte de **nécessité** : je préfère ma vie à mon
argent. Ce n''est pas un acte de **volonté**, et il ne crée aucune obligation —
dès que le brigand a le dos tourné, je n''ai aucun devoir de continuer à lui
donner quoi que ce soit.

*La conséquence.* Si le droit se fondait sur la force, le devoir d''obéir
durerait exactement aussi longtemps que la force. Un droit qui s''évanouit dès
qu''on peut désobéir impunément n''est pas un droit : c''est une contrainte
momentanée.

*La réfutation est donc logique, et non morale.* Rousseau ne dit pas qu''il est
laid d''obéir au plus fort ; il montre que l''expression « droit du plus fort »
est **contradictoire**. Si c''est un droit, il oblige même quand la force
manque ; si c''est la force, il n''oblige pas du tout.

*On peut conclure : la force peut expliquer qu''une loi existe, elle ne peut
jamais expliquer qu''elle oblige.*
', NULL, 30),
      (v_chapitre_id, 'Simulation : le droit du plus fort', 5, 'interactif', '{
  "widget": "droit-plus-fort",
  "consigne": "Une société s''affiche avec ses groupes, leurs forces respectives et ses lois. Change le rapport de forces et regarde les lois se réécrire d''elles-mêmes : c''est la thèse de Thrasymaque, et elle fonctionne. Puis la simulation te pose la question de Rousseau : quand le groupe dominé devient le plus fort, les anciennes lois obligent-elles encore ? Tu vois alors pourquoi un droit qui s''évanouit avec la force n''était pas un droit."
}', NULL, 10),
      (v_chapitre_id, 'Le droit est-il juste ?', 6, 'texte', '
Second problème. Il ne porte plus sur le fondement du droit, mais sur sa
**valeur**.

### Thèse : le droit est légitime, c''est-à-dire juste

**Argument 1 — il s''inspire de la morale et de la raison.** **Montesquieu** :
la loi est la raison en tant qu''elle gouverne tous les peuples de la terre. Le
droit prolonge ainsi une exigence rationnelle, et non un caprice.

**Argument 2 — il résulte d''un contrat.** Il tire sa légitimité de la volonté
générale, ou au moins de celle du plus grand nombre. **Rousseau** :
« l''obéissance à la loi qu''on s''est prescrite est liberté ».

**Argument 3 — il protège les faibles.** C''est l''argument le plus concret.
Sans droit, le faible est livré au fort. La loi qui interdit le vol protège
d''abord celui qui ne peut pas se défendre seul. Lacordaire l''a dit : entre le
fort et le faible, c''est la liberté qui opprime et la loi qui affranchit.

### Antithèse : le droit est illégitime, c''est-à-dire injuste

**Argument 1 — certaines lois sont immorales.** L''histoire en fournit assez :
les lois esclavagistes, les lois raciales, les lois d''exception. Toutes étaient
parfaitement légales.

**Argument 2 — le droit repose parfois sur la force.** On retrouve La Fontaine
et Bismarck. Une loi imposée par un vainqueur à un vaincu reste une loi.

**Argument 3 — le droit sert les puissants.** **Marx** : le droit positif
organise l''oppression d''une classe par une autre. Et l''égalité devant la loi
reste formelle tant que les moyens de la faire valoir sont inégaux : le riche
et le pauvre ont également le droit de se faire défendre par un avocat.

### La synthèse possible

Le droit n''est ni juste ni injuste par nature : il est **perfectible**.

Son histoire le montre. L''esclavage a été légal, puis aboli ; les femmes
n''avaient pas le droit de vote, puis l''ont obtenu. Chaque fois, c''est **au nom
du droit naturel** qu''on a corrigé le droit positif.

Le droit est donc le lieu d''un **écart** entre ce qui est et ce qui devrait
être. C''est cet écart qui le rend critiquable, et c''est aussi lui qui le rend
améliorable. Un droit parfait n''aurait pas besoin de juristes ; un droit sans
aucune justice ne pourrait pas être réformé, faute de critère.

---

**Exercice corrigé**

*« Entre le fort et le faible, c''est la liberté qui opprime et la loi qui
affranchit » (Lacordaire). Expliquer, puis discuter.*

**Correction.**

*L''explication.* « Liberté » désigne ici l''absence de règle, la situation où
chacun fait ce qu''il peut. Dans cette situation, le fort impose ses conditions
et le faible les subit : la liberté de l''un est l''oppression de l''autre.

La **loi**, en limitant également la liberté de tous, protège surtout celui qui
avait le moins de moyens de se défendre. Interdire au propriétaire d''expulser
sans préavis restreint sa liberté et libère le locataire.

La formule renverse donc l''opposition ordinaire entre liberté et loi : ce n''est
pas la loi qui s''oppose à la liberté, c''est la loi qui la rend réelle pour tous.
On rejoint Rousseau : « il n''y a point de liberté sans lois ».

*La discussion.*

**Premier point : la loi peut aussi opprimer.** Lacordaire suppose une loi
juste. Mais une loi peut être écrite par le fort pour consolider sa force, et
c''est l''objection de Marx : le droit codifie souvent l''oppression au lieu de la
corriger.

**Deuxième point : l''égalité devant la loi reste formelle.** Le riche et le
pauvre ont le même droit de se défendre, mais pas les mêmes moyens. La loi
affranchit à condition qu''on puisse l''invoquer.

**Troisième point, pour la synthèse.** La formule reste vraie comme **principe**
et fausse comme **constat**. Elle dit ce que la loi doit faire, non ce qu''elle
fait toujours. Elle fournit ainsi le critère au nom duquel on peut réclamer de
meilleures lois — et c''est précisément l''usage que la tradition du droit
naturel en a fait.
', NULL, 28),
      (v_chapitre_id, 'Simulation : un droit perfectible', 7, 'interactif', '{
  "widget": "droit-perfectible",
  "consigne": "Huit lois qui ont réellement existé te sont présentées — l''esclavage, l''interdiction faite aux femmes de voter, le travail des enfants, les lois d''exception — avec la période où chacune était parfaitement légale. Tu dois dire pour chacune au nom de quoi elle a pu être abolie, et la simulation te fait constater le même mécanisme huit fois : c''est toujours un principe extérieur à la loi qui a servi à la corriger. Elle te pose enfin la question gênante : s''il n''existait aucun droit naturel, qu''est-ce qui aurait permis ces abolitions ?"
}', NULL, 10),
      (v_chapitre_id, 'Sujet type Baccalauréat — Le droit du plus fort', 8, 'texte', '
**Deuxième partie de l''épreuve — Évaluation de l''agir compétent — 9 points**

*En te fondant sur ta culture philosophique et dans le respect des règles de la
logique, est-il légitime de penser que la raison du plus fort est toujours la
meilleure ?*

---
---

## Corrigé

### I. Analyse et compréhension du sujet

**Les concepts-clés.** *Raison* : ici, la justification qu''on donne de sa
conduite, ce qui la fait tenir pour fondée. *Le plus fort* : celui qui dispose
de la puissance, physique, économique ou politique. *La meilleure* : celle qui
l''emporte, ou celle qui vaut le plus — et l''ambiguïté est au cœur du sujet.

**Reformulation.** A-t-on de bonnes raisons de soutenir que la puissance suffit
à fonder le droit ?

**Le présupposé.** Que la force puisse produire autre chose qu''une contrainte,
à savoir une obligation.

**La thèse opposée.** La force n''engendre aucun droit.

**Le problème.** Le fondement du droit.

**La problématique.** Le droit n''est-il que la mise en forme d''un rapport de
forces, ou bien suppose-t-il un principe que la force ne peut pas produire ?

### II. Première tâche — la thèse *(3 points)*

**Argument 1.** Dans la nature, la puissance décide. **Spinoza** lie le droit
naturel à la puissance : chacun a droit à ce qu''il peut. **Calliclès**, dans le
*Gorgias*, définit la justice comme la supériorité du plus fort.

**Argument 2.** Les faits confirment. **Platon** fait soutenir à Thrasymaque,
dans *La République*, que le juste est partout ce qui profite au plus fort. Les
traités sont écrits par les vainqueurs, et **Bismarck** affirme que la force
crée le droit.

**Argument 3.** Le droit positif sert les puissants. Pour **Marx**, il organise
en lois l''oppression d''une classe par une autre, et l''égalité qu''il proclame
reste formelle tant que les moyens de l''invoquer sont inégaux.

*Transition.* Mais un droit qui ne tiendrait qu''à la force obligerait-il encore
quand la force vient à manquer ?

### III. Deuxième tâche — l''antithèse *(3 points)*

**Argument 1, et il est décisif.** **Rousseau** montre que l''expression « droit
du plus fort » est **contradictoire**. Céder à la force est un acte de
nécessité, non de volonté. Or une obligation qui disparaît avec la force n''est
pas une obligation : si c''est un droit, il oblige même quand la force manque ;
si c''est la force, il n''oblige pas du tout.

**Argument 2.** Le droit se fonde sur la raison, qui est universelle.
**Montesquieu**, dans *De l''esprit des lois*, écrit que la loi est la raison
humaine en tant qu''elle gouverne tous les peuples de la terre.

**Argument 3.** Le droit se fonde sur un contrat et sur la volonté générale.
**Rousseau** encore : « l''obéissance à la loi qu''on s''est prescrite est
liberté ». Ce n''est pas la contrainte qui oblige, c''est l''accord.

*Transition.* Faut-il alors conclure que la force n''a aucun rôle dans le droit,
alors que toute loi s''accompagne d''une contrainte ?

### IV. Troisième tâche — la synthèse *(3 points)*

**Premier moment — les deux thèses ne parlent pas de la même chose.** La
première décrit **l''origine historique** des lois : elles ont souvent été
imposées, et c''est un fait. La seconde énonce la **condition de leur
validité** : pour obliger en conscience, il faut autre chose que la contrainte.

**Deuxième moment — le rôle réel de la force.** Le droit a besoin de la force
pour être **appliqué**, non pour être **fondé**. Une loi juste sans police
reste un vœu ; une force sans justice reste une menace. Max Weber définit
d''ailleurs l''État par le **monopole de la violence légitime** — et l''adjectif
compte autant que le nom.

**Troisième moment — la réponse.** Il n''est pas légitime de penser que la
raison du plus fort est toujours la meilleure. Elle est souvent la plus
**efficace**, et c''est ce que la fable de La Fontaine constate avec amertume.
Mais efficace n''est pas juste, et confondre les deux, c''est renoncer à pouvoir
dire qu''une loi est mauvaise.

**Conclusion.** La force explique qu''une loi existe ; elle n''explique jamais
qu''elle oblige. Le droit du plus fort est donc un fait sans être un droit.
Reste à savoir qui, dans un État, détient cette force et au nom de quoi — et
c''est la question du chapitre suivant.

---

### Ce que le correcteur attend

**La distinction céder / obéir**, qui est le cœur de l''argument de Rousseau.

**Que « la meilleure » soit discuté** : la plus efficace ou la plus juste ? Les
copies qui ne voient pas l''ambiguïté passent à côté du sujet.

**Un contre-exemple historique** en deuxième tâche : l''abolition de l''esclavage
montre qu''une loi peut être corrigée au nom d''un principe que la force ne
donnait pas.
', NULL, 32),
      (v_chapitre_id, 'Quiz du chapitre 6', 9, 'quiz', '{
  "titre": "Vérifie que tu as compris",
  "questions": [
    {
      "question": "Qu''est-ce que le droit positif ?",
      "choix": [
        "Le droit qui donne raison",
        "L''ensemble des règles écrites, édictées par une autorité souveraine et en vigueur dans une société donnée",
        "Les principes universels de la justice",
        "Le droit des plus forts"
      ],
      "bonne": 1,
      "explication": "Il est particulier, modifiable et contraignant. Le droit naturel, lui, est universel, immuable, et c''est au nom de lui qu''on juge les lois."
    },
    {
      "question": "Pourquoi faut-il le droit naturel pour dire qu''une loi est injuste ?",
      "choix": [
        "Parce qu''il est plus ancien",
        "Parce que juger une loi suppose une mesure extérieure à elle : sans cela, toute loi serait juste par définition",
        "Parce qu''il est écrit",
        "Parce que les tribunaux l''appliquent"
      ],
      "bonne": 1,
      "explication": "C''est au nom du droit naturel que l''esclavage, pourtant parfaitement légal pendant des siècles, a pu être déclaré injuste."
    },
    {
      "question": "Quelle différence entre le légal et le légitime ?",
      "choix": [
        "Aucune",
        "Est légal ce qui est conforme à la loi en vigueur ; est légitime ce qui est fondé en raison et en justice",
        "Le légal concerne la morale",
        "Le légitime est plus récent"
      ],
      "bonne": 1,
      "explication": "Les deux ne coïncident pas toujours : une loi raciale est légale et illégitime, la désobéissance à cette loi est illégale et légitime."
    },
    {
      "question": "Comment Rousseau réfute-t-il le droit du plus fort ?",
      "choix": [
        "En disant que c''est immoral",
        "En montrant que céder à la force est un acte de nécessité, non de volonté : une obligation qui disparaît avec la force n''en est pas une",
        "En citant la Bible",
        "En invoquant la volonté générale"
      ],
      "bonne": 1,
      "explication": "La réfutation est LOGIQUE, pas morale : l''expression « droit du plus fort » est contradictoire. Si c''est un droit, il oblige même sans force."
    },
    {
      "question": "Que soutient Thrasymaque dans La République de Platon ?",
      "choix": [
        "Que la justice vient de Dieu",
        "Que le juste est partout ce qui profite au plus fort",
        "Que la loi est la raison humaine",
        "Que l''homme naît bon"
      ],
      "bonne": 1,
      "explication": "Calliclès, dans le Gorgias, tient une position voisine : la justice serait la supériorité du meilleur et du plus fort sur les plus faibles."
    },
    {
      "question": "Selon Montesquieu, sur quoi la loi se fonde-t-elle ?",
      "choix": [
        "Sur la force",
        "Sur la raison, « en tant qu''elle gouverne tous les peuples de la terre »",
        "Sur la coutume",
        "Sur la religion"
      ],
      "bonne": 1,
      "explication": "La formule est dans De l''esprit des lois, livre I, chapitre 3. La raison étant universelle, le droit qui s''y fonde peut valoir pour tous."
    },
    {
      "question": "Quel rôle la force joue-t-elle réellement dans le droit ?",
      "choix": [
        "Elle le fonde",
        "Elle sert à l''appliquer, non à le fonder",
        "Elle n''y joue aucun rôle",
        "Elle le remplace"
      ],
      "bonne": 1,
      "explication": "Une loi juste sans police reste un vœu ; une force sans justice reste une menace. Weber définit l''État par le monopole de la violence LÉGITIME."
    }
  ]
}', NULL, 5);

    RAISE NOTICE '% : 9 leçons ajoutées au chapitre 6, Droit et justice.', v_nom;
  END LOOP;
END $philo$;
