-- ---------------------------------------------------------------------------
-- M'Andal — Philosophie, classes de Terminale
-- Chapitre 7 : L'État et le pouvoir
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
    WHERE programme_id = v_programme_id AND ordre = 7;

    IF v_chapitre_id IS NULL THEN
      INSERT INTO public.chapitres (programme_id, titre, ordre, niveau)
      VALUES (v_programme_id, 'L''État et le pouvoir', 7, 'Module 1 : La philosophie')
      RETURNING id INTO v_chapitre_id;
      RAISE NOTICE '% : chapitre 7 créé.', v_nom;
    END IF;

    -- Les leçons. Si le chapitre en a déjà, on passe son tour sans rien toucher.
    SELECT count(*) INTO v_deja FROM public.concepts WHERE chapitre_id = v_chapitre_id;
    IF v_deja > 0 THEN
      RAISE NOTICE '% : le chapitre 7 a déjà ses % leçons, je n''y touche pas.', v_nom, v_deja;
      CONTINUE;
    END IF;

    INSERT INTO public.concepts
      (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes) VALUES
      (v_chapitre_id, 'L''État : de quoi parle-t-on ?', 1, 'texte', '
Le mot désigne trois choses qu''il faut savoir distinguer, sous peine de
confusion dès l''introduction.

### Les trois sens

**L''État au sens juridique** : la personne morale qui détient la souveraineté
sur un territoire et une population. C''est l''État qui signe les traités.

**L''État au sens institutionnel** : l''ensemble des organes qui exercent le
pouvoir — gouvernement, administration, armée, police, justice.

**L''État au sens géopolitique** : le pays lui-même, avec ses trois éléments
constitutifs — un **territoire**, une **population**, un **pouvoir souverain**.

Le **gouvernement** n''est pas l''État : il en est l''organe exécutif. Un
gouvernement tombe, l''État demeure. La confusion des deux est l''erreur la plus
courante, et elle se paie dès la définition des concepts.

### La définition de Weber

**Max Weber** donne la définition que l''on cite : l''État est la communauté
humaine qui **revendique avec succès le monopole de la violence physique
légitime** sur un territoire donné.

Trois mots sont à peser.

**Monopole** : nul autre que l''État n''a le droit d''user de la force. C''est ce
qui distingue la police du gang, alors que tous deux usent de la contrainte.

**Violence** : Weber ne l''euphémise pas. L''État contraint, arrête, emprisonne.

**Légitime** : et c''est l''adjectif qui fait toute la différence. L''État ne
prétend pas seulement être le plus fort, il prétend avoir le **droit** de l''être.

### La souveraineté

C''est le caractère du pouvoir d''État : il est **suprême** — nul pouvoir ne lui
est supérieur à l''intérieur — et **indépendant** — nul État étranger ne lui
commande.

C''est pourquoi la question du chapitre est politique et pas seulement
théorique : savoir d''où vient le pouvoir de l''État, c''est savoir qui a le droit
de lui désobéir.

---

**Exercice corrigé**

*Distinguer l''État du gouvernement, puis expliquer les trois termes de la
définition de Weber.*

**Correction.**

*La distinction.* L''**État** est la personne morale souveraine, permanente, qui
détient l''autorité sur un territoire et une population. Le **gouvernement** est
l''ensemble des organes qui exercent cette autorité à un moment donné.

L''État est **permanent**, le gouvernement est **temporaire**. Une élection
change le gouvernement sans changer l''État ; un coup d''État change le
gouvernement par la force, et c''est précisément pour cela qu''on dit « coup
d''État » et non « État ».

*La définition de Weber.* L''État est la communauté humaine qui revendique avec
succès le monopole de la violence physique légitime sur un territoire donné.

Le **monopole** : l''État seul a le droit d''user de la contrainte. Je n''ai pas
le droit d''arrêter mon voisin, même coupable ; le policier l''a.

La **violence physique** : Weber refuse d''adoucir le mot. L''État dispose de la
prison, de la force publique, et en dernier ressort de l''armée.

La **légitimité** : c''est ce qui sépare l''État du brigand. Tous deux prennent
de l''argent sous la contrainte ; mais l''impôt est dû et le racket ne l''est pas.
Saint Augustin posait d''ailleurs la question à l''envers : si l''État n''est pas
juste, qu''est-il d''autre qu''« une troupe de brigands » ?

*Le « revendique avec succès » mérite aussi un mot : l''État ne détient pas ce
monopole par nature, il le réclame, et il faut que cette prétention soit
reconnue. Un État dont l''autorité n''est plus reconnue sur une partie de son
territoire cesse d''y être un État.*
', NULL, 26),
      (v_chapitre_id, 'Simulation : État, gouvernement, nation, pouvoir', 2, 'interactif', '{
  "widget": "notions-etat",
  "consigne": "Quinze énoncés te sont soumis — « il a été renversé par les urnes », « il signe les traités », « elle partage une langue et une histoire », « il dure quand le ministre tombe » — et tu désignes à chaque fois ce dont il s''agit. La simulation sépare l''État du gouvernement, de la nation et du pouvoir, et te montre le cas qui piège tout le monde : un coup d''État renverse le gouvernement, pas l''État."
}', NULL, 10),
      (v_chapitre_id, 'Figure : trois contrats, trois États', 3, 'figure', '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 560 300" width="560" height="300">
<rect width="560" height="300" fill="#ffffff"/>
<text x="280" y="24" text-anchor="middle" font-size="14" font-weight="700" fill="#0f172a">Du contrat social : trois versions, trois États</text>

<g>
<rect x="18" y="44" width="170" height="236" rx="6" fill="#fee2e2" stroke="#b91c1c" stroke-width="1.6"/>
<text x="103" y="66" text-anchor="middle" font-size="12" font-weight="700" fill="#7f1d1d">HOBBES</text>
<text x="103" y="80" text-anchor="middle" font-size="8" fill="#991b1b">Le Léviathan, 1651</text>
<line x1="30" y1="88" x2="176" y2="88" stroke="#fca5a5"/>
<text x="30" y="106" font-size="9" font-weight="700" fill="#7f1d1d">L&apos;état de nature</text>
<text x="30" y="120" font-size="8" fill="#991b1b">guerre de tous contre tous</text>
<text x="30" y="132" font-size="8" fill="#991b1b">« l&apos;homme est un loup »</text>
<text x="30" y="154" font-size="9" font-weight="700" fill="#7f1d1d">Le contrat</text>
<text x="30" y="168" font-size="8" fill="#991b1b">chacun abandonne son droit</text>
<text x="30" y="180" font-size="8" fill="#991b1b">de se gouverner lui-même</text>
<text x="30" y="202" font-size="9" font-weight="700" fill="#7f1d1d">L&apos;État obtenu</text>
<text x="30" y="216" font-size="8" fill="#991b1b">souverain absolu</text>
<text x="30" y="228" font-size="8" fill="#991b1b">on ne peut pas se révolter</text>
<text x="103" y="256" text-anchor="middle" font-size="9" font-style="italic" fill="#475569">la sécurité</text>
<text x="103" y="270" text-anchor="middle" font-size="9" font-style="italic" fill="#475569">avant la liberté</text>
</g>

<g>
<rect x="196" y="44" width="170" height="236" rx="6" fill="#dbeafe" stroke="#2563eb" stroke-width="1.6"/>
<text x="281" y="66" text-anchor="middle" font-size="12" font-weight="700" fill="#1e3a8a">LOCKE</text>
<text x="281" y="80" text-anchor="middle" font-size="8" fill="#1e40af">Traité du gouvernement civil, 1690</text>
<line x1="208" y1="88" x2="354" y2="88" stroke="#93c5fd"/>
<text x="208" y="106" font-size="9" font-weight="700" fill="#1e3a8a">L&apos;état de nature</text>
<text x="208" y="120" font-size="8" fill="#1e40af">des droits existent déjà</text>
<text x="208" y="132" font-size="8" fill="#1e40af">mais nul ne les garantit</text>
<text x="208" y="154" font-size="9" font-weight="700" fill="#1e3a8a">Le contrat</text>
<text x="208" y="168" font-size="8" fill="#1e40af">on confie la garantie</text>
<text x="208" y="180" font-size="8" fill="#1e40af">de droits qu&apos;on garde</text>
<text x="208" y="202" font-size="9" font-weight="700" fill="#1e3a8a">L&apos;État obtenu</text>
<text x="208" y="216" font-size="8" fill="#1e40af">pouvoir limité</text>
<text x="208" y="228" font-size="8" fill="#1e40af">la révolte est légitime</text>
<text x="281" y="256" text-anchor="middle" font-size="9" font-style="italic" fill="#475569">l&apos;État au service</text>
<text x="281" y="270" text-anchor="middle" font-size="9" font-style="italic" fill="#475569">des droits</text>
</g>

<g>
<rect x="374" y="44" width="170" height="236" rx="6" fill="#dcfce7" stroke="#15803d" stroke-width="1.6"/>
<text x="459" y="66" text-anchor="middle" font-size="12" font-weight="700" fill="#14532d">ROUSSEAU</text>
<text x="459" y="80" text-anchor="middle" font-size="8" fill="#166534">Du contrat social, 1762</text>
<line x1="386" y1="88" x2="532" y2="88" stroke="#86efac"/>
<text x="386" y="106" font-size="9" font-weight="700" fill="#14532d">L&apos;état de nature</text>
<text x="386" y="120" font-size="8" fill="#166534">l&apos;homme y est bon</text>
<text x="386" y="132" font-size="8" fill="#166534">la propriété le corrompt</text>
<text x="386" y="154" font-size="9" font-weight="700" fill="#14532d">Le contrat</text>
<text x="386" y="168" font-size="8" fill="#166534">chacun se donne à tous,</text>
<text x="386" y="180" font-size="8" fill="#166534">donc à personne</text>
<text x="386" y="202" font-size="9" font-weight="700" fill="#14532d">L&apos;État obtenu</text>
<text x="386" y="216" font-size="8" fill="#166534">la volonté générale</text>
<text x="386" y="228" font-size="8" fill="#166534">le peuple est souverain</text>
<text x="459" y="256" text-anchor="middle" font-size="9" font-style="italic" fill="#475569">obéir à la loi</text>
<text x="459" y="270" text-anchor="middle" font-size="9" font-style="italic" fill="#475569">qu&apos;on s&apos;est donnée</text>
</g>
</svg>', NULL, 5),
      (v_chapitre_id, 'D''où vient le pouvoir de l''État ?', 4, 'texte', '
Premier problème. Deux réponses s''affrontent, et la seconde a mis des siècles à
l''emporter.

### Thèse religieuse : le pouvoir vient de Dieu

**Argument 1.** Dieu, être tout-puissant, est la source de tout pouvoir. Aucune
autorité ne peut exister sans qu''il l''ait voulue.

**Argument 2.** Les autorités sont ses représentants sur terre. **Saint Paul**
l''écrit : chacun doit se soumettre aux autorités, car « il n''y a point
d''autorité qui ne vienne de Dieu ». **Bossuet**, précepteur du Dauphin, fonde
sur ce verset la théorie du **droit divin** : Dieu établit les rois comme ses
ministres et règne par eux sur les hommes.

**La conséquence politique, et c''est pour elle que la thèse a servi :** se
révolter contre le roi, c''est se révolter contre Dieu. La thèse rend donc toute
désobéissance sacrilège.

### Thèse contractualiste : le pouvoir vient des hommes

Les hommes ont institué l''État par un **contrat**. Mais les trois grands
contractualistes ne racontent pas la même histoire, et c''est leur comparaison
qui fait les bonnes copies.

**Thomas Hobbes**, dans *Le Léviathan* (1651). À l''état de nature, chacun ayant
droit à tout, c''est la **guerre de tous contre tous** : *homo homini lupus*.
Pour en sortir, chacun autorise un homme ou une assemblée à le gouverner et lui
**abandonne** son droit de se gouverner lui-même, à condition que les autres en
fassent autant. L''État obtenu est **absolu**, et la révolte est illégitime :
elle ramènerait la guerre.

**John Locke**, dans le *Traité du gouvernement civil* (1690). À l''état de
nature, les hommes ont déjà des droits — la vie, la liberté, la propriété —
mais nul ne les garantit. Par le contrat, ils ne les abandonnent pas : ils en
**confient la garantie** à un pouvoir. L''État est donc **limité**, et s''il viole
les droits qu''il devait protéger, la **révolte est légitime**.

**Jean-Jacques Rousseau**, dans *Du contrat social* (1762). L''homme naît bon,
et c''est la propriété qui l''a corrompu. Par le contrat, chacun se donne à tous,
donc à personne en particulier : naît alors la **volonté générale**, et le
peuple devient **souverain**. Obéir à la loi, c''est obéir à soi-même :
« l''obéissance à la loi qu''on s''est prescrite est liberté ».

### Comment les comparer en copie

Le tableau est simple, et il rapporte des points.

Chez **Hobbes**, l''état de nature est terrible, le contrat est un abandon,
l''État est absolu, et la révolte est interdite.

Chez **Locke**, l''état de nature est précaire, le contrat est un dépôt, l''État
est limité, et la révolte est un droit.

Chez **Rousseau**, l''état de nature est heureux, le contrat est une association,
l''État est la volonté générale, et le peuple reste souverain.

La question qui les sépare : **qu''est-ce qu''on cède, et à qui ?**

---

**Exercice corrigé**

*Comparer les contrats de Hobbes et de Locke, et montrer que la différence porte
sur le droit de résistance.*

**Correction.**

*Le point de départ.* Pour **Hobbes**, l''état de nature est une guerre de tous
contre tous, où la vie est « solitaire, misérable, dangereuse, animale et
brève ». Pour **Locke**, il n''est pas une guerre : les hommes y ont déjà des
droits naturels, mais chacun étant juge en sa propre cause, ces droits sont mal
garantis.

*Le contrat.* Chez Hobbes, chacun **abandonne** son droit de se gouverner
lui-même au profit du souverain, à condition que tous en fassent autant. Chez
Locke, chacun **confie** la garantie de droits qu''il **conserve**.

La différence est celle d''un don et d''un dépôt. Ce qui est donné n''est plus à
moi ; ce qui est déposé le reste.

*La conséquence sur la révolte.* Chez **Hobbes**, le souverain n''est pas partie
au contrat : il n''a donc rien promis, et on ne peut rien lui reprocher. Se
révolter, c''est rompre le pacte et ramener la guerre — c''est donc toujours
illégitime, même contre un tyran, car la pire tyrannie vaut mieux que l''état de
nature.

Chez **Locke**, le pouvoir a reçu une **mission**. S''il viole les droits qu''il
devait protéger, il trahit le dépôt et perd sa légitimité. La **résistance
devient un droit**, et c''est de cette thèse que se réclameront les révolutions
anglaise, américaine et française.

*La raison profonde de l''écart.* Les deux hommes ne craignent pas la même
chose. Hobbes, qui a vécu la guerre civile anglaise, craint le désordre. Locke,
qui a vu l''absolutisme, craint la tyrannie. Chacun construit l''État contre le
mal qu''il redoute le plus.
', NULL, 32),
      (v_chapitre_id, 'Simulation : les trois contrats', 5, 'interactif', '{
  "widget": "trois-contrats",
  "consigne": "Choisis un état de nature — guerre de tous contre tous, droits mal garantis, ou bonté naturelle — puis le contrat qui en découle, et la simulation construit l''État correspondant : son étendue, ses limites, et le droit de révolte qui en résulte. Essaie ensuite le cas limite : un gouvernement viole les droits qu''il devait protéger. Hobbes interdit la révolte, Locke l''autorise, Rousseau pose une autre question. Tu vois alors que le droit de résistance ne se discute pas en lui-même : il découle du contrat qu''on a signé."
}', NULL, 10),
      (v_chapitre_id, 'L''État est-il un bien ou un mal ?', 6, 'texte', '
Second problème, et c''est celui qui tombe le plus souvent.

### Thèse : l''État est un mal

**Argument 1 — il produit de la violence.** Par l''armée et la police, il
contraint les citoyens et entretient la crainte. **Max Weber** le reconnaît
lui-même en le définissant par le monopole de la violence physique légitime.
**Louis Althusser** parle des **appareils répressifs d''État**.

**Argument 2 — il manipule les consciences.** Par l''école, les médias et les
Églises, il forme les esprits, désinforme et rend les individus passifs.
Althusser parle cette fois des **appareils idéologiques d''État** : l''État ne
tient pas seulement par la peur, il tient par ce qu''on croit.

**Argument 3 — il crée et entretient les injustices.** **Saint Augustin** :
sans la justice, qu''est-ce qu''un État sinon « une troupe de brigands » ?
**Marx** : l''État est l''instrument que la bourgeoisie se donne pour garantir
ses biens et ses intérêts.

**Argument 4 — il est liberticide.** En organisant, réglementant et commandant,
il étouffe l''indépendance des citoyens. **Bakounine** le dit avec violence :
l''État est « un vaste cimetière » où viennent s''enterrer toutes les
manifestations de la vie individuelle.

### Antithèse : l''État est un bien

**Argument 1 — il assure la sécurité.** Sans lui, les individus seraient
exposés en permanence. C''est la fonction première, et c''est celle que Hobbes
met au-dessus de tout.

**Argument 2 — il assure le bien-être.** Santé, éducation, logement,
infrastructures : aucun individu ne peut se les donner seul. Un hôpital, une
route, une école ne se construisent pas par un contrat entre voisins.

**Argument 3 — il régule la vie sociale.** Il fixe les règles des échanges et
tranche les conflits. Pour les contractualistes — **Hobbes**, **Locke**,
**Spinoza** —, l''avènement de l''État est le remède à l''état de nature.

### La synthèse

L''État est un **mal nécessaire**, mais cette formule est paresseuse si on s''y
arrête. Il faut la préciser.

Il est un mal **dans ses moyens** : il contraint, et la contrainte est toujours
un mal pour celui qui la subit.

Il est un bien **dans sa fin** : il rend possible une liberté réelle. Sans lui,
je serais libre de tout faire et capable de rien, puisque les autres seraient
libres de m''en empêcher.

Et surtout, la question « l''État est-il un bien ou un mal ? » est mal posée. Un
État n''est pas une essence, c''est une **institution** : tout dépend de ce qu''il
fait et de qui le contrôle. La vraie question n''est pas s''il faut un État, mais
**lequel**, et comment l''empêcher de devenir ce que Bakounine décrit.

C''est d''ailleurs la réponse de Locke : limiter le pouvoir, et séparer les
pouvoirs. C''est aussi celle de Montesquieu : il faut que, par la disposition
des choses, le pouvoir arrête le pouvoir.

---

**Exercice corrigé**

*Qu''est-ce que l''État selon Althusser ? Expliquer la distinction entre appareils
répressifs et appareils idéologiques, et dire ce qu''elle apporte à la critique
de l''État.*

**Correction.**

*La thèse d''Althusser.* L''État ne se maintient pas seulement par la force : il
se maintient surtout par l''adhésion de ceux qu''il gouverne. Il dispose pour
cela de deux séries d''instruments.

*Les appareils répressifs d''État.* L''armée, la police, les tribunaux, les
prisons. Ils fonctionnent **principalement par la violence**. Ils sont
unifiés, publics, et commandés directement par le pouvoir.

*Les appareils idéologiques d''État.* L''école, la famille, les Églises, les
médias, les partis, la culture. Ils fonctionnent **principalement par
l''idéologie** : ils ne contraignent pas, ils forment. Ils sont multiples,
souvent privés, et d''autant plus efficaces qu''on ne les voit pas comme des
instruments de pouvoir.

*Ce que la distinction apporte.* Elle explique une énigme : pourquoi les
dominés obéissent-ils alors qu''ils sont les plus nombreux ?

La réponse par la peur est insuffisante — aucune police ne suffirait à
surveiller tout le monde. Althusser répond que l''obéissance est d''abord
**intériorisée** : on apprend à l''école ce qu''il est normal de vouloir, et
l''ordre existant finit par paraître naturel.

*La limite de cette analyse, à mentionner.* Si toute éducation est un appareil
idéologique, on ne voit plus comment une critique serait possible : Althusser
lui-même a été formé par l''école qu''il dénonce. Une théorie qui explique
**tout** explique peut-être trop — c''est l''objection que Popper adressait déjà
à d''autres doctrines.
', NULL, 30),
      (v_chapitre_id, 'Simulation : quel État ?', 7, 'interactif', '{
  "widget": "quel-etat",
  "consigne": "Tu construis un État en réglant quatre curseurs : la force de sa police, l''étendue de ses services publics, la séparation de ses pouvoirs et la liberté de sa presse. À chaque réglage, trois jauges répondent — sécurité, liberté réelle, risque de tyrannie — et un verdict te dit à quel penseur ressemble ton État : le Léviathan de Hobbes, le gouvernement limité de Locke, ou le cimetière de Bakounine. Essaie de supprimer complètement l''État, puis de tout lui donner : tu découvres que les deux extrêmes font chuter la même jauge, et que c''est la séparation des pouvoirs qui change tout."
}', NULL, 10),
      (v_chapitre_id, 'Sujet type Baccalauréat — L''État est-il un mal nécessaire ?', 8, 'texte', '
**Deuxième partie de l''épreuve — Évaluation de l''agir compétent — 9 points**

*En te fondant sur ta culture philosophique et dans le respect des règles de la
logique, est-il légitime de penser que l''État est un mal nécessaire ?*

---
---

## Corrigé

### I. Analyse et compréhension du sujet

**Les concepts-clés.** *État* : personne morale souveraine qui détient
l''autorité sur un territoire et une population, et qui revendique le monopole
de la violence physique légitime. *Mal* : ce qui nuit, ce qu''on subit.
*Nécessaire* : ce dont on ne peut pas se passer.

**Reformulation.** A-t-on de bonnes raisons de soutenir que l''État nuit aux
hommes tout en leur étant indispensable ?

**Le présupposé.** Le sujet tient pour acquis que l''État **est** un mal : il ne
discute que sa nécessité. C''est ce présupposé que l''antithèse contestera.

**La thèse opposée.** L''État n''est pas un mal : il est un bien.

**Le problème.** La valeur de l''État.

**La problématique.** L''État, parce qu''il repose sur la contrainte, est-il un
mal qu''il faut seulement tolérer, ou bien la condition d''une liberté qui, sans
lui, n''aurait aucune garantie ?

### II. Première tâche — la thèse : l''État est un mal *(3 points)*

**Argument 1.** Il repose sur la violence. **Weber** le définit par le monopole
de la violence physique légitime ; **Althusser** nomme armée, police et
tribunaux les **appareils répressifs d''État**.

**Argument 2.** Il façonne les consciences. Par l''école, les médias et les
Églises — les **appareils idéologiques** —, il rend l''ordre existant naturel et
désarme la contestation avant qu''elle ne naisse.

**Argument 3.** Il sert les puissants et entretient les injustices. **Marx** y
voit l''instrument de la bourgeoisie ; **Saint Augustin** demandait déjà : sans
la justice, qu''est-ce qu''un État sinon une troupe de brigands ? **Bakounine**
le nomme « un vaste cimetière » des libertés individuelles.

*Transition.* Mais la suppression de l''État rendrait-elle les hommes plus
libres, ou seulement plus exposés ?

### III. Deuxième tâche — l''antithèse : l''État est un bien *(3 points)*

**Argument 1.** Il assure la sécurité. **Hobbes** décrit ce qu''est la vie sans
lui : une guerre de tous contre tous où chacun craint tout le monde. L''État
n''enlève pas une liberté réelle, il met fin à une insécurité totale.

**Argument 2.** Il rend possible la liberté au lieu de la supprimer.
**Rousseau** : « il n''y a point de liberté sans lois », et « l''obéissance à la
loi qu''on s''est prescrite est liberté ». Sans État, le faible n''a aucune
liberté effective, seulement celle que le fort lui laisse.

**Argument 3.** Il assure le bien-être et la régulation. Santé, éducation,
routes, justice : aucun individu ni aucun groupe privé ne peut se les donner
seul.

*Transition.* Faut-il alors choisir entre le cimetière de Bakounine et le
Léviathan de Hobbes, ou la question est-elle mal posée ?

### IV. Troisième tâche — la synthèse *(3 points)*

**Premier moment — les deux thèses ont chacune raison contre quelque chose.**
La première a raison contre la **naïveté** : un État n''est jamais innocent, et
celui qui détient la force est toujours tenté d''en user pour lui. La seconde a
raison contre l''**utopie** : une société sans État n''est pas une société de
libres, c''est une société où le plus fort règne sans contrôle.

**Deuxième moment — préciser la formule.** L''État est un mal dans ses
**moyens**, puisqu''il contraint ; il est un bien dans sa **fin**, puisqu''il
rend la liberté effective. Dire qu''il est un « mal nécessaire » n''est donc pas
faux, mais c''est paresseux : cela suppose que son mal soit constant, alors
qu''il varie.

**Troisième moment — la vraie question.** L''État n''est pas une essence, c''est
une **institution**. Tout dépend de ce qu''il fait et de qui le contrôle. La
question n''est donc pas « faut-il un État ? », mais « **lequel ?** » — et la
réponse est connue depuis Locke et Montesquieu : un État **limité**, où les
pouvoirs se contrôlent mutuellement, de sorte que, par la disposition des
choses, le pouvoir arrête le pouvoir.

**Conclusion.** Il n''est pas tout à fait légitime de penser que l''État est un
mal nécessaire, parce que la formule fige en nature ce qui dépend d''une
organisation. L''État est dangereux par construction et utile par destination :
il appelle moins la résignation que la vigilance. Reste à savoir si cette
vigilance suffit, ou si la liberté suppose encore autre chose que de bonnes
institutions.

---

### Ce que le correcteur attend

**Que le présupposé soit repéré** : le sujet accorde déjà que l''État est un
mal, et une bonne copie commence par le contester.

**Les trois contractualistes distingués**, et pas confondus en un bloc.

**Une synthèse qui déplace la question** : de « faut-il un État ? » à « quel
État ? ». C''est elle qui fait la différence entre 5 et 8 sur 9.
', NULL, 34),
      (v_chapitre_id, 'Quiz du chapitre 7', 9, 'quiz', '{
  "titre": "Vérifie que tu as compris",
  "questions": [
    {
      "question": "Quelle différence entre l''État et le gouvernement ?",
      "choix": [
        "Aucune",
        "L''État est la personne morale souveraine et permanente ; le gouvernement est l''organe qui exerce cette autorité à un moment donné",
        "L''État est plus petit",
        "Le gouvernement est plus ancien"
      ],
      "bonne": 1,
      "explication": "Une élection change le gouvernement sans changer l''État. C''est pour cela qu''on dit « coup d''État » : il renverse le gouvernement, pas l''État."
    },
    {
      "question": "Comment Max Weber définit-il l''État ?",
      "choix": [
        "Comme la volonté générale",
        "Comme la communauté humaine qui revendique avec succès le monopole de la violence physique légitime sur un territoire",
        "Comme une troupe de brigands",
        "Comme un mal nécessaire"
      ],
      "bonne": 1,
      "explication": "Trois mots comptent : monopole, violence, et surtout LÉGITIME — c''est l''adjectif qui sépare la police du gang, alors que tous deux contraignent."
    },
    {
      "question": "Chez Hobbes, pourquoi la révolte est-elle illégitime ?",
      "choix": [
        "Parce que Dieu l''interdit",
        "Parce que le souverain n''est pas partie au contrat et n''a donc rien promis : se révolter, c''est ramener la guerre de tous contre tous",
        "Parce que le peuple est ignorant",
        "Parce que la loi l''interdit"
      ],
      "bonne": 1,
      "explication": "Chez Locke au contraire, le pouvoir a reçu un dépôt : s''il viole les droits qu''il devait garantir, la résistance devient un droit."
    },
    {
      "question": "Quelle est la différence entre le contrat de Hobbes et celui de Locke ?",
      "choix": [
        "Aucune",
        "Chez Hobbes on ABANDONNE son droit de se gouverner ; chez Locke on CONFIE la garantie de droits qu''on conserve",
        "Hobbes est plus récent",
        "Locke refuse tout État"
      ],
      "bonne": 1,
      "explication": "La différence d''un don et d''un dépôt. Ce qui est donné n''est plus à moi ; ce qui est déposé le reste — et c''est de là que vient le droit de résistance."
    },
    {
      "question": "Que sont les appareils idéologiques d''État chez Althusser ?",
      "choix": [
        "L''armée et la police",
        "L''école, la famille, les Églises et les médias, qui fonctionnent par l''idéologie plutôt que par la violence",
        "Les ministères",
        "Les partis d''opposition"
      ],
      "bonne": 1,
      "explication": "Ils expliquent pourquoi les dominés obéissent alors qu''ils sont les plus nombreux : l''obéissance est intériorisée avant d''être imposée."
    },
    {
      "question": "Quelle formule Bakounine emploie-t-il contre l''État ?",
      "choix": [
        "Une troupe de brigands",
        "Un vaste cimetière où s''enterrent toutes les manifestations de la vie individuelle",
        "Le monopole de la violence légitime",
        "L''opium du peuple"
      ],
      "bonne": 1,
      "explication": "« Une troupe de brigands » est de Saint Augustin, « l''opium du peuple » de Marx à propos de la religion. Attribuer correctement les formules rapporte des points."
    },
    {
      "question": "Comment déplacer la question « l''État est-il un mal nécessaire ? » en synthèse ?",
      "choix": [
        "En répondant oui",
        "En montrant que l''État n''est pas une essence mais une institution, et que la vraie question est « lequel ? »",
        "En citant plus d''auteurs",
        "En refusant de répondre"
      ],
      "bonne": 1,
      "explication": "La réponse est connue depuis Locke et Montesquieu : un État limité, où le pouvoir arrête le pouvoir. C''est ce déplacement qui fait la différence entre 5 et 8 sur 9."
    }
  ]
}', NULL, 5);

    RAISE NOTICE '% : 9 leçons ajoutées au chapitre 7, L''État et le pouvoir.', v_nom;
  END LOOP;
END $philo$;
