-- ---------------------------------------------------------------------------
-- M'Andal — Philosophie, classes de Terminale
-- Chapitre 11 : L'existence et la mort
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
    WHERE programme_id = v_programme_id AND ordre = 11;

    IF v_chapitre_id IS NULL THEN
      INSERT INTO public.chapitres (programme_id, titre, ordre, niveau)
      VALUES (v_programme_id, 'L''existence et la mort', 11, 'Module 1 : La philosophie')
      RETURNING id INTO v_chapitre_id;
      RAISE NOTICE '% : chapitre 11 créé.', v_nom;
    END IF;

    -- Les leçons. Si le chapitre en a déjà, on passe son tour sans rien toucher.
    SELECT count(*) INTO v_deja FROM public.concepts WHERE chapitre_id = v_chapitre_id;
    IF v_deja > 0 THEN
      RAISE NOTICE '% : le chapitre 11 a déjà ses % leçons, je n''y touche pas.', v_nom, v_deja;
      CONTINUE;
    END IF;

    INSERT INTO public.concepts
      (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes) VALUES
      (v_chapitre_id, 'Exister : le mot et le problème', 1, 'texte', '
On confond facilement « être » et « exister ». La philosophie
contemporaine tient à la différence, et c''est d''elle que naît tout le chapitre.

### L''étymologie, qui dit déjà l''essentiel

**Exister** vient du latin *ex-sistere* : se tenir hors de, surgir, se dresser.
Exister, ce n''est pas simplement être là comme une pierre est là. C''est **se
tenir hors de soi**, être projeté, inachevé.

D''où la distinction :

**Les choses sont.** La pierre est ce qu''elle est, tout entière, sans reste.

**L''homme existe.** Il n''est jamais achevé ; il est toujours en avant de
lui-même, dans ses projets, ses manques, son avenir.

### Essence et existence

L''**essence** est ce qu''une chose est, sa nature, sa définition. L''**existence**
est le fait d''être là.

Pour la tradition, l''essence **précède** l''existence : il y a une nature humaine,
voulue par Dieu ou inscrite dans l''ordre du monde, et chaque homme la réalise.
C''est le modèle de l''artisan : l''idée du couteau existe avant le couteau.

**Sartre** renverse ce rapport : **l''existence précède l''essence**. L''homme
surgit d''abord, sans définition, et il se fait ensuite ce qu''il est. « Il n''y a
pas de nature humaine. » L''homme n''est que la somme de ses actes.

### Les grandes notions de l''existence

**L''angoisse.** Chez **Kierkegaard**, qu''on tient pour le père de
l''existentialisme, elle n''est pas la peur : la peur a un objet, l''angoisse n''en
a pas. Elle est le **vertige de la liberté** — la découverte que tout est
possible et que rien ne me dit quoi faire.

**L''absurde.** Chez **Camus**, c''est le divorce entre l''homme qui demande du
sens et un monde qui n''en fournit pas. *Le Mythe de Sisyphe* ouvre sur une
phrase qu''il faut connaître : « il n''y a qu''un problème philosophique vraiment
sérieux : c''est le suicide ». Sa réponse n''est pourtant pas le désespoir : il
faut imaginer Sisyphe heureux, parce qu''il a fait de son rocher son affaire.

**La finitude.** L''homme est un être **fini** : limité dans sa durée, son
savoir, son pouvoir. **Héraclite** le disait du monde entier — tout coule, on ne
se baigne jamais deux fois dans le même fleuve — et l''homme coule avec.

**Le Dasein.** **Heidegger**, dans *Être et Temps* (1927), nomme ainsi
l''existence humaine : *Da-sein*, l''« être-là ». Son trait principal est d''être
un être **pour qui son propre être fait question**.

---

**Exercice corrigé**

*Distinguer l''être et l''exister, puis expliquer la formule de Sartre selon
laquelle l''existence précède l''essence.*

**Correction.**

*La distinction.* **Être** se dit de tout ce qui est : la pierre est, le nombre
est, l''arbre est. C''est le fait brut de la présence.

**Exister**, au sens que la philosophie contemporaine donne au mot, se dit de ce
qui se tient hors de soi — *ex-sistere*. La pierre est ce qu''elle est, entière
et close. L''homme, lui, n''est jamais achevé : il est devant lui-même, dans ce
qu''il projette, espère et craint.

Autrement dit, la pierre n''a pas de rapport à son propre être ; l''homme en a un,
et ce rapport est ce qu''on appelle exister.

*La formule de Sartre.* « L''existence précède l''essence. »

*Ce qu''elle renverse.* La tradition tenait l''ordre inverse. Pour le modèle
artisanal, l''idée du couteau précède le couteau : on sait ce qu''il doit faire
avant de le fabriquer. Appliqué à l''homme, ce modèle suppose une **nature
humaine** — donnée par Dieu, par la biologie ou par l''ordre du monde — que chacun
n''aurait plus qu''à réaliser.

*Ce qu''elle affirme.* Pour Sartre, l''homme « surgit d''abord dans le monde, et se
définit après ». Il n''y a pas de nature humaine, parce qu''il n''y a pas d''artisan
qui l''aurait conçue. L''homme n''est rien d''autre que ce qu''il se fait : la somme
de ses actes, et rien de plus.

*Les deux conséquences.*

**La liberté.** Aucune définition ne me précède, donc rien ne me dicte ma
conduite. Je suis « condamné à être libre ».

**La responsabilité, et l''angoisse qui l''accompagne.** Puisque je me fais, je
n''ai aucune excuse : je ne peux invoquer ni ma nature, ni mon caractère. Invoquer
une nature pour se justifier, c''est ce que Sartre nomme la **mauvaise foi** —
se traiter soi-même comme une chose.

*On peut noter la limite, que l''on retrouvera en synthèse : cette liberté est la
même pour tous, alors que les conditions réelles de l''existence ne le sont pas.*
', NULL, 28),
      (v_chapitre_id, 'Simulation : essence ou existence d''abord ?', 2, 'interactif', '{
  "widget": "essence-existence",
  "consigne": "Douze objets et douze êtres te sont présentés — un couteau, une table, un chien, un nouveau-né, un vieillard, un personnage de roman — et tu dois dire pour chacun si son essence précède son existence ou l''inverse. La simulation te fait découvrir le modèle de l''artisan : pour tout objet fabriqué, l''idée vient avant la chose. Puis elle te pose la question de Sartre : qui a pensé l''idée de l''homme avant l''homme ? Tu vois alors ce que la formule « il n''y a pas de nature humaine » engage vraiment."
}', NULL, 10),
      (v_chapitre_id, 'Figure : cinq attitudes devant la mort', 3, 'figure', '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 580 300" width="580" height="300">
<rect width="580" height="300" fill="#ffffff"/>
<text x="290" y="24" text-anchor="middle" font-size="14" font-weight="700" fill="#0f172a">Cinq attitudes devant la mort</text>

<rect x="16" y="44" width="106" height="150" rx="6" fill="#dcfce7" stroke="#15803d" stroke-width="1.5"/>
<text x="69" y="64" text-anchor="middle" font-size="10" font-weight="700" fill="#14532d">ÉPICURE</text>
<line x1="28" y1="72" x2="110" y2="72" stroke="#86efac"/>
<text x="69" y="90" text-anchor="middle" font-size="8" fill="#166534">la mort n&apos;est</text>
<text x="69" y="102" text-anchor="middle" font-size="8" fill="#166534">rien pour nous</text>
<text x="69" y="124" text-anchor="middle" font-size="8" fill="#166534">quand elle est là,</text>
<text x="69" y="136" text-anchor="middle" font-size="8" fill="#166534">je ne suis plus</text>
<text x="69" y="162" text-anchor="middle" font-size="8" font-style="italic" fill="#475569">ne la crains pas :</text>
<text x="69" y="174" text-anchor="middle" font-size="8" font-style="italic" fill="#475569">elle ne te</text>
<text x="69" y="186" text-anchor="middle" font-size="8" font-style="italic" fill="#475569">rencontre jamais</text>

<rect x="130" y="44" width="106" height="150" rx="6" fill="#ede9fe" stroke="#7c3aed" stroke-width="1.5"/>
<text x="183" y="64" text-anchor="middle" font-size="10" font-weight="700" fill="#5b21b6">PLATON</text>
<line x1="142" y1="72" x2="224" y2="72" stroke="#c4b5fd"/>
<text x="183" y="90" text-anchor="middle" font-size="8" fill="#6d28d9">la mort libère</text>
<text x="183" y="102" text-anchor="middle" font-size="8" fill="#6d28d9">l&apos;âme du corps</text>
<text x="183" y="124" text-anchor="middle" font-size="8" fill="#6d28d9">philosopher,</text>
<text x="183" y="136" text-anchor="middle" font-size="8" fill="#6d28d9">c&apos;est s&apos;y exercer</text>
<text x="183" y="162" text-anchor="middle" font-size="8" font-style="italic" fill="#475569">le Phédon,</text>
<text x="183" y="174" text-anchor="middle" font-size="8" font-style="italic" fill="#475569">dernier jour</text>
<text x="183" y="186" text-anchor="middle" font-size="8" font-style="italic" fill="#475569">de Socrate</text>

<rect x="244" y="44" width="106" height="150" rx="6" fill="#fef3c7" stroke="#ca8a04" stroke-width="1.5"/>
<text x="297" y="64" text-anchor="middle" font-size="10" font-weight="700" fill="#78350f">SPINOZA</text>
<line x1="256" y1="72" x2="338" y2="72" stroke="#fde047"/>
<text x="297" y="90" text-anchor="middle" font-size="8" fill="#92400e">l&apos;homme libre</text>
<text x="297" y="102" text-anchor="middle" font-size="8" fill="#92400e">ne pense pas</text>
<text x="297" y="114" text-anchor="middle" font-size="8" fill="#92400e">à la mort</text>
<text x="297" y="136" text-anchor="middle" font-size="8" fill="#92400e">sa sagesse est</text>
<text x="297" y="148" text-anchor="middle" font-size="8" fill="#92400e">méditation de la vie</text>
<text x="297" y="172" text-anchor="middle" font-size="8" font-style="italic" fill="#475569">l&apos;exact contraire</text>
<text x="297" y="184" text-anchor="middle" font-size="8" font-style="italic" fill="#475569">de Montaigne</text>

<rect x="358" y="44" width="106" height="150" rx="6" fill="#dbeafe" stroke="#2563eb" stroke-width="1.5"/>
<text x="411" y="64" text-anchor="middle" font-size="10" font-weight="700" fill="#1e3a8a">HEIDEGGER</text>
<line x1="370" y1="72" x2="452" y2="72" stroke="#93c5fd"/>
<text x="411" y="90" text-anchor="middle" font-size="8" fill="#1e40af">l&apos;être-pour-la-mort</text>
<text x="411" y="112" text-anchor="middle" font-size="8" fill="#1e40af">la possibilité la</text>
<text x="411" y="124" text-anchor="middle" font-size="8" fill="#1e40af">plus propre et</text>
<text x="411" y="136" text-anchor="middle" font-size="8" fill="#1e40af">indépassable</text>
<text x="411" y="162" text-anchor="middle" font-size="8" font-style="italic" fill="#475569">dire « on meurt »</text>
<text x="411" y="174" text-anchor="middle" font-size="8" font-style="italic" fill="#475569">est une fuite</text>
<text x="411" y="186" text-anchor="middle" font-size="8" font-style="italic" fill="#475569">Être et Temps, 1927</text>

<rect x="472" y="44" width="92" height="150" rx="6" fill="#ffedd5" stroke="#c2410c" stroke-width="1.5"/>
<text x="518" y="64" text-anchor="middle" font-size="10" font-weight="700" fill="#7c2d12">AFRIQUE</text>
<line x1="482" y1="72" x2="554" y2="72" stroke="#fdba74"/>
<text x="518" y="90" text-anchor="middle" font-size="8" fill="#9a3412">la mort est</text>
<text x="518" y="102" text-anchor="middle" font-size="8" fill="#9a3412">un passage</text>
<text x="518" y="124" text-anchor="middle" font-size="8" fill="#9a3412">le mort rejoint</text>
<text x="518" y="136" text-anchor="middle" font-size="8" fill="#9a3412">les ancêtres</text>
<text x="518" y="162" text-anchor="middle" font-size="8" font-style="italic" fill="#475569">« ceux qui sont</text>
<text x="518" y="174" text-anchor="middle" font-size="8" font-style="italic" fill="#475569">morts ne sont</text>
<text x="518" y="186" text-anchor="middle" font-size="8" font-style="italic" fill="#475569">jamais partis »</text>

<rect x="60" y="212" width="460" height="74" rx="6" fill="#f8fafc" stroke="#94a3b8"/>
<text x="290" y="232" text-anchor="middle" font-size="11" font-weight="700" fill="#0f172a">Deux familles de réponses</text>
<text x="290" y="252" text-anchor="middle" font-size="9" fill="#475569">la mort est un néant qu&apos;il faut cesser de craindre — Épicure, Spinoza</text>
<text x="290" y="268" text-anchor="middle" font-size="9" fill="#475569">la mort est un passage ou une révélation qui donne son prix à la vie</text>
<text x="290" y="282" text-anchor="middle" font-size="9" fill="#475569">Platon, Montaigne, Heidegger, les traditions africaines</text>
</svg>', NULL, 5),
      (v_chapitre_id, 'Que penser de la mort ?', 4, 'texte', '
Cinq réponses au programme, et elles se répartissent en deux familles. Ce
partage est la colonne vertébrale de toute copie sur ce chapitre.

### Première famille : la mort n''est rien, cessez de la craindre

**Épicure**, dans la *Lettre à Ménécée*, donne l''argument le plus serré de
toute l''histoire de la philosophie sur ce point :

**« La mort n''est rien pour nous. »**

Son raisonnement tient en trois temps. Tout bien et tout mal résident dans la
sensation. Or la mort est privation de toute sensation. Donc la mort n''est ni un
bien ni un mal : elle n''est rien.

Et il ajoute l''argument de la rencontre impossible : quand la mort est là, je ne
suis plus ; quand je suis, elle n''est pas. Nous ne nous croisons jamais. Craindre
la mort, c''est donc craindre ce qu''on ne connaîtra jamais.

**Lucrèce** prolonge : nous ne nous plaignons pas de n''avoir pas existé avant
notre naissance ; pourquoi nous plaindre de ne plus exister après ?

**Spinoza** arrive au même refus de la crainte par un autre chemin. Dans
l''*Éthique*, livre IV : **« L''homme libre ne pense pas à la mort, et sa sagesse
est une méditation non de la mort, mais de la vie. »** Penser sans cesse à la
mort est une tristesse, et la tristesse diminue notre puissance d''agir.

### Seconde famille : la mort donne son prix à la vie

**Platon**, dans le *Phédon*, fait parler Socrate le dernier jour de sa vie : la
mort sépare l''âme du corps, et comme la philosophie est l''effort de l''âme pour
se détacher du sensible, **philosopher est un exercice de la mort**.

**Montaigne** reprend la formule dans ses *Essais* : « **philosopher, c''est
apprendre à mourir** ». Non par morbidité, mais par liberté : « qui a appris à
mourir, il a désappris à servir ». Celui qui ne craint plus la mort ne craint
plus rien, et devient inattaquable.

Remarquez l''opposition frontale avec Spinoza. Montaigne dit : pense à la mort,
tu seras libre. Spinoza dit : n''y pense pas, tu seras libre. Les deux cherchent
la liberté par des chemins contraires, et c''est un excellent matériau pour une
antithèse.

**Heidegger** donne la version la plus exigeante. Dans *Être et Temps*,
l''existence humaine est un **être-pour-la-mort** (*Sein zum Tode*). La mort n''est
pas un événement lointain qui m''attend : elle est ma possibilité la plus
**propre** — personne ne peut mourir à ma place —, la plus **certaine**, et
**indépassable**.

Et Heidegger dénonce la fuite ordinaire : nous disons « **on** meurt ». Ce « on »
anonyme transforme ma mort en un fait général qui concerne tout le monde, c''est-à-
dire personne. C''est l''existence **inauthentique**. Assumer sa mort comme
*mienne*, c''est au contraire accéder à l''existence **authentique**, car c''est
alors seulement que mon temps devient précieux.

### La conception africaine : la mort comme passage

Le programme camerounais y tient, et elle ne se réduit à aucune des quatre
précédentes.

Dans les traditions africaines, la mort n''est pas un anéantissement mais un
**changement de statut**. Le défunt quitte la communauté des vivants pour celle
des **ancêtres**, et il continue d''y agir : on le consulte, on l''honore, il
protège ou il réclame.

**Birago Diop** l''a dit en poète, dans *Souffles* : « **ceux qui sont morts ne
sont jamais partis** ». **Placide Tempels**, dans *La Philosophie bantoue*, et
**Alexis Kagame** y voient l''effet d''une ontologie de la **force vitale** : être,
c''est être une force, et la mort diminue cette force sans l''éteindre.

La conséquence est pratique : la vie humaine ne s''arrête pas au corps
individuel, et la communauté comprend les morts, les vivants et ceux qui ne sont
pas encore nés. **Thomas Sankara** en donne une version laïque : « on peut tuer
un révolutionnaire, on ne tue pas des idées ».

Attention en copie : il ne s''agit pas de présenter cette conception comme une
croyance naïve face à des thèses savantes. Elle répond à la même question — que
reste-t-il de nous ? — et sa réponse est l''inscription dans une continuité.

---

**Exercice corrigé**

*Épicure affirme que « la mort n''est rien pour nous ». Reconstituer son
argument, puis indiquer deux objections.*

**Correction.**

*L''argument, en trois propositions.*

**Première proposition.** Tout bien et tout mal résident dans la sensation :
est un mal ce que je souffre, est un bien ce dont je jouis.

**Deuxième proposition.** La mort est privation totale de sensation.

**Conclusion.** La mort n''est donc ni un bien ni un mal pour celui qui meurt.
Elle n''est rien pour lui.

*L''argument complémentaire, celui de la rencontre impossible.* La mort et moi ne
pouvons jamais être présents ensemble : tant que je suis, elle n''est pas
survenue ; quand elle est survenue, je ne suis plus là pour la subir. Je ne la
rencontre donc jamais, et craindre ce qu''on ne rencontrera jamais est sans
objet.

*Première objection : ce n''est pas la mort qu''on craint, c''est de mourir.*
L''argument d''Épicure vise l''état d''être mort, et il porte. Mais la crainte réelle
des hommes ne porte pas sur cet état : elle porte sur l''**agonie**, qui est bien
une sensation, et sur l''**interruption** de tout ce qu''on avait commencé.

On peut aussi craindre pour les autres : le père ne craint pas d''être mort, il
craint de laisser ses enfants sans lui. Épicure répond mal à cela, parce que son
argument raisonne sur un individu séparé.

*Seconde objection : Heidegger, et elle est plus profonde.* Épicure traite la
mort comme un **événement** futur, qui arrivera à un certain moment. Dès lors, il
est facile de montrer qu''il ne me concerne pas encore et ne me concernera jamais.

Mais pour Heidegger, la mort n''est pas un événement à venir : elle est une
**structure présente** de mon existence. Je suis, dès maintenant et à chaque
instant, un être qui peut mourir, et c''est cette possibilité qui donne à mon
temps sa limite, donc son prix.

Autrement dit, Épicure a raison sur la mort comme fait et manque la mort comme
**sens**. En écartant la crainte, il écarte aussi ce que la mort révèle : que mon
temps est compté, et qu''il faut donc en faire quelque chose.

*On peut remarquer enfin que les traditions africaines refusent la deuxième
proposition elle-même : si le mort rejoint les ancêtres et continue d''agir dans
la communauté, la mort n''est pas privation totale, et l''argument d''Épicure
n''atteint plus son objet.*
', NULL, 34),
      (v_chapitre_id, 'Simulation : cinq philosophes au chevet', 5, 'interactif', '{
  "widget": "cinq-attitudes-mort",
  "consigne": "Un homme apprend qu''il va mourir et pose douze questions — faut-il avoir peur ? ma vie a-t-elle encore un sens ? que restera-t-il de moi ? dois-je y penser ? — et tu choisis à chaque fois qui répond : Épicure, Platon, Spinoza, Heidegger ou la tradition africaine. Chacun répond selon sa thèse, dans ses propres termes. La simulation te montre ensuite les deux endroits où les réponses s''affrontent frontalement : Montaigne contre Spinoza sur le fait d''y penser, Épicure contre Heidegger sur ce que la mort est."
}', NULL, 10),
      (v_chapitre_id, 'La mort donne-t-elle un sens à la vie ?', 6, 'texte', '
Dernier problème du chapitre, et il articule les deux notions du titre.

### Thèse : la mort ôte tout sens à la vie

**Argument 1 — l''absurde.** Si tout finit, rien ne compte durablement.
**Camus** décrit ce divorce entre l''homme qui réclame du sens et le monde qui
n''en donne pas. **Schopenhauer** y voit la preuve que la vie est une erreur.

**Argument 2 — l''inachèvement.** La mort interrompt sans égard pour l''œuvre
commencée. L''artiste meurt au milieu de son tableau, le père avant d''avoir élevé
son fils. Ce qui est interrompu au hasard n''a pas de forme, donc pas de sens.

**Argument 3 — l''égalité dans le néant.** Si le juste et le criminel finissent
pareillement, qu''importe la vertu ? L''argument est ancien, et c''est celui auquel
toutes les morales ont eu à répondre.

### Antithèse : la mort donne son sens à la vie

**Argument 1 — la rareté fait la valeur.** C''est l''argument le plus solide. Une
vie sans fin serait une vie sans urgence : rien n''y serait jamais à faire
maintenant, puisque tout pourrait être fait plus tard. **Heidegger** : c''est
l''être-pour-la-mort qui rend le temps précieux. Supprimez la mort, vous supprimez
l''importance de l''instant.

**Argument 2 — la mort libère.** **Montaigne** : « qui a appris à mourir, il a
désappris à servir ». Celui qui ne craint plus la mort n''est plus tenu par les
menaces, et c''est pourquoi les tyrans craignent les hommes qui ne craignent pas
de mourir.

**Argument 3 — l''authenticité.** Toujours **Heidegger** : tant que je dis « on
meurt », je vis dans la dispersion. Assumer ma mort comme mienne me ramène à ce
qui compte réellement pour moi, et sépare l''essentiel de l''accessoire.

**Argument 4 — la survie dans la communauté.** Les traditions africaines
répondent autrement : le sens de ma vie ne s''arrête pas à mon corps, parce que je
continue dans les ancêtres, dans la lignée, dans la mémoire. « Ceux qui sont
morts ne sont jamais partis. » **Sankara** : on peut tuer un révolutionnaire, on
ne tue pas des idées.

### La synthèse

La question est mal posée, et c''est par là qu''il faut conclure.

La mort ne **donne** pas un sens — ce serait étrange qu''un néant produise du
sens. Elle ne l''**ôte** pas non plus. Elle fait autre chose : elle rend la
question du sens **inévitable**.

Un être immortel n''aurait jamais à se demander ce qu''il fait de son temps,
puisqu''il en aurait toujours. C''est parce que notre temps est compté que nous
devons choisir — et choisir, c''est donner un sens.

Le sens n''est donc ni dans la mort ni dans la vie prise comme un fait : il est
dans ce que l''on fait d''une vie dont on sait la limite. **Camus** le dit à sa
manière en refusant le suicide : constater l''absurde n''oblige pas à abdiquer, il
faut imaginer Sisyphe heureux, parce qu''il a fait de son rocher son affaire.

Et les traditions africaines ajoutent le correctif qui manque à
l''existentialisme : ce sens n''est pas seulement individuel. On vit pour une
communauté qui nous précède et nous suit, et c''est une autre façon de répondre
à la mort que de l''affronter seul.

---

**Exercice corrigé**

*Montrer que la thèse « la mort ôte tout sens à la vie » et la thèse « la mort
donne son sens à la vie » reposent sur deux conceptions différentes du sens.*

**Correction.**

*Le point de départ.* Les deux thèses semblent se contredire directement. En
réalité, elles n''emploient pas le mot « sens » dans la même acception, et c''est
pourquoi elles peuvent être vraies ensemble.

*Le sens au premier sens : la permanence.* La thèse pessimiste suppose que **ce
qui a un sens est ce qui dure**. Une œuvre détruite n''aurait pas eu de sens, une
vie qui s''achève serait annulée par son terme. Dans cette conception, la mort est
en effet fatale au sens, puisqu''elle supprime la permanence.

C''est le raisonnement de **Schopenhauer** et celui que **Camus** décrit sous le
nom d''absurde : l''homme demande de l''éternel, et le monde ne lui en donne pas.

*Le sens au second sens : la direction.* L''autre thèse entend « sens » comme on
l''entend d''un fleuve ou d''une flèche : une **orientation**. Dans cette
conception, le sens suppose non pas la durée illimitée, mais au contraire une
**limite** : une direction n''existe que s''il y a un terme vers lequel elle va.

C''est le raisonnement de **Heidegger**. L''être-pour-la-mort n''annule pas
l''existence, il la **tend**. Un temps infini serait un temps sans urgence, où
rien ne serait jamais à faire maintenant.

*La conséquence.* La première conception cherche le sens **au-delà** de la vie,
et la mort le lui interdit. La seconde cherche le sens **dans** la vie, et la
mort le lui rend possible.

*Les traditions africaines occupent une position intéressante entre les deux :
elles répondent à la demande de permanence, mais sans sortir du monde, puisque le
mort continue dans la communauté des ancêtres. C''est une permanence
**relationnelle** et non individuelle.*

*On peut conclure ainsi : la mort ôte le sens à qui le cherchait dans la durée,
et le donne à qui le cherche dans l''usage du temps. La question « la mort
donne-t-elle un sens à la vie ? » devient alors : où avons-nous décidé de
chercher le sens ?*
', NULL, 30),
      (v_chapitre_id, 'Simulation : une vie sans fin', 7, 'interactif', '{
  "widget": "vie-sans-fin",
  "consigne": "On te donne l''immortalité et une liste de choses à faire : apprendre le piano, réconcilier deux amis, écrire un livre, dire à quelqu''un qu''on l''aime. Tu disposes d''un temps infini, et la simulation te laisse tout reporter. Reporte, et reporte encore : rien ne se fait jamais, parce que rien n''est jamais urgent. Puis réactive la finitude et refais la même liste avec un compteur qui descend. Tu obtiens l''argument de Heidegger sans qu''on te le récite : ce n''est pas la mort qui donne le sens, c''est elle qui rend la question du sens inévitable."
}', NULL, 10),
      (v_chapitre_id, 'Sujet type Baccalauréat — Faut-il craindre la mort ?', 8, 'texte', '
**Deuxième partie de l''épreuve — Évaluation de l''agir compétent — 9 points**

*En te fondant sur ta culture philosophique et dans le respect des règles de la
logique, est-il légitime de penser qu''il faut craindre la mort ?*

---
---

## Corrigé

### I. Analyse et compréhension du sujet

**Les concepts-clés.** *Craindre* : éprouver de la peur devant un mal à venir —
ce qui suppose que ce mal soit réel et qu''il me concerne. *La mort* : il faut la
dédoubler, et c''est la clé du sujet — l''**état** d''être mort, et l''**événement**
de mourir. *Faut-il* : non pas « craint-on en fait », mais « a-t-on raison de
craindre » ; la question est normative.

**Reformulation.** Avons-nous de bonnes raisons d''éprouver de la peur devant
notre propre mort ?

**Le présupposé.** Que la mort soit un mal, et un mal qui me concerne.

**La thèse opposée.** La mort n''est rien pour nous, donc la crainte est sans
objet.

**Le problème.** Le rapport de l''existence humaine à sa propre finitude.

**La problématique.** La crainte de la mort est-elle une erreur de raisonnement
dont la philosophie doit nous guérir, ou le signe que nous avons compris ce que
la mort révèle de notre existence ?

### II. Première tâche — la thèse : oui, il faut la craindre *(3 points)*

**Argument 1.** Elle supprime tous les biens. Si tout bien est dans la vie, ce
qui met fin à la vie met fin à tous les biens. La crainte est alors la réaction
juste devant la perte la plus grande.

**Argument 2.** Elle interrompt sans égard. **Camus** décrit l''absurde : l''homme
réclame du sens, et la mort coupe au hasard l''œuvre, l''amour, le projet.
**Schopenhauer** y voit la preuve que la vie se termine en déception.

**Argument 3.** La crainte est utile. C''est elle qui nous fait fuir le danger,
soigner nos malades, construire des abris. Une espèce qui ne craindrait pas la
mort n''aurait pas survécu. Et chez **Kierkegaard**, l''**angoisse** devant notre
finitude n''est pas un défaut : elle est ce qui nous réveille.

*Transition.* Mais cette crainte porte-t-elle sur quelque chose que nous puissions
réellement subir ?

### III. Deuxième tâche — l''antithèse : non, elle est sans objet *(3 points)*

**Argument 1, et c''est le plus serré.** **Épicure**, dans la *Lettre à
Ménécée* : tout bien et tout mal sont dans la sensation ; la mort est privation
de toute sensation ; donc la mort n''est ni un bien ni un mal. Et l''argument de la
rencontre impossible : quand elle est là, je ne suis plus ; quand je suis, elle
n''est pas. **Lucrèce** ajoute que nous ne nous plaignons pas de n''avoir pas
existé avant notre naissance.

**Argument 2.** La crainte nuit. **Spinoza**, *Éthique* IV : « l''homme libre ne
pense pas à la mort, et sa sagesse est une méditation non de la mort, mais de la
vie ». La tristesse diminue notre puissance d''agir ; craindre la mort, c''est
mourir un peu d''avance.

**Argument 3.** Elle n''est pas une fin. Pour **Platon**, dans le *Phédon*, elle
libère l''âme du corps, et c''est pourquoi Socrate meurt sans trouble. Les
**traditions africaines** refusent même la prémisse d''Épicure : le défunt rejoint
la communauté des ancêtres et continue d''y agir. « Ceux qui sont morts ne sont
jamais partis », écrit **Birago Diop**. La mort est alors un passage, et l''on ne
craint pas un passage.

*Transition.* Faut-il donc congédier purement et simplement la crainte, et avec
elle tout ce que la mort nous apprend ?

### IV. Troisième tâche — la synthèse *(3 points)*

**Premier moment — dédoubler l''objet de la crainte.** L''argument d''Épicure
porte sur l''**état** d''être mort, et il est irréprochable : un état sans
sensation n''est ni bon ni mauvais. Mais la crainte réelle des hommes ne porte pas
là : elle porte sur l''**agonie**, qui est une sensation ; sur l''**interruption**
de ce qui était commencé ; et sur les **autres** — le père ne craint pas d''être
mort, il craint de laisser ses enfants. Épicure a raison contre une crainte que
personne n''éprouve exactement.

**Deuxième moment — ce que la crainte manque, et ce qu''elle garde.**
**Heidegger** déplace la question : la mort n''est pas un événement futur, elle
est une structure présente de mon existence. Je suis un **être-pour-la-mort**,
et cette possibilité la plus propre, certaine et indépassable est ce qui donne à
mon temps sa limite, donc son prix. Dire « **on** meurt » est la fuite ordinaire,
l''existence inauthentique. Ce qu''il faut, ce n''est donc ni craindre ni oublier :
c''est **assumer**.

**Troisième moment — l''apport des traditions africaines.** Elles offrent une
troisième voie, que ni le stoïcisme du courage ni l''argument épicurien
n''occupent. Le sens de ma vie ne s''achève pas avec mon corps parce que je
m''inscris dans une communauté qui me précède et me suit. **Sankara** : on peut
tuer un révolutionnaire, on ne tue pas des idées. La mort cesse d''être affrontée
seule, et c''est peut-être la réponse la plus praticable.

**Conclusion.** Il n''est pas légitime de craindre la mort comme **état**,
puisqu''elle ne sera jamais rien pour nous. Il est légitime de redouter ce qui
l''entoure — la souffrance, l''inachèvement, l''abandon des siens — et il est
nécessaire de l''**assumer** comme horizon, faute de quoi notre temps nous paraît
illimité et nous le gaspillons. La sagesse n''est donc ni la crainte ni l''oubli :
elle est cette lucidité que **Montaigne** appelait apprendre à mourir, et qui
servait selon lui à désapprendre à servir.

---

### Ce que le correcteur attend

**Le dédoublement « être mort » / « mourir »**. Sans lui, la copie oppose
Épicure et le sens commun sans pouvoir les départager.

**Épicure cité avec son raisonnement complet**, pas seulement avec la formule.
Les trois propositions rapportent plus que la citation seule.

**Au moins une référence africaine traitée philosophiquement**, et non comme une
curiosité : elle conteste une prémisse d''Épicure, et c''est à ce titre qu''elle
compte.
', NULL, 34),
      (v_chapitre_id, 'Quiz du chapitre 11', 9, 'quiz', '{
  "titre": "Vérifie que tu as compris",
  "questions": [
    {
      "question": "Que signifie l''étymologie du mot « exister » ?",
      "choix": [
        "Être présent",
        "Ex-sistere : se tenir hors de, surgir — l''homme n''est jamais achevé, il est en avant de lui-même",
        "Vivre longtemps",
        "Avoir une essence"
      ],
      "bonne": 1,
      "explication": "D''où la distinction : les choses SONT, tout entières et closes ; l''homme EXISTE, toujours inachevé."
    },
    {
      "question": "Que veut dire Sartre en affirmant que l''existence précède l''essence ?",
      "choix": [
        "Que l''homme a une nature qu''il découvre",
        "Que l''homme surgit d''abord sans définition et se fait ensuite ce qu''il est : il n''y a pas de nature humaine",
        "Que l''existence est plus importante",
        "Que Dieu a créé l''homme libre"
      ],
      "bonne": 1,
      "explication": "C''est le renversement du modèle de l''artisan, où l''idée du couteau précède le couteau. D''où la liberté, la responsabilité, et la mauvaise foi de qui invoque sa nature."
    },
    {
      "question": "Quelle différence Kierkegaard fait-il entre la peur et l''angoisse ?",
      "choix": [
        "Aucune",
        "La peur a un objet, l''angoisse n''en a pas : elle est le vertige de la liberté",
        "L''angoisse est plus faible",
        "La peur est irrationnelle"
      ],
      "bonne": 1,
      "explication": "L''angoisse est la découverte que tout est possible et que rien ne me dit quoi faire. Kierkegaard est tenu pour le père de l''existentialisme."
    },
    {
      "question": "Reconstituez l''argument d''Épicure sur la mort.",
      "choix": [
        "La mort est naturelle donc acceptable",
        "Tout bien et tout mal sont dans la sensation ; la mort est privation de sensation ; donc elle n''est ni bien ni mal",
        "L''âme est immortelle donc rien n''est perdu",
        "Les ancêtres nous attendent"
      ],
      "bonne": 1,
      "explication": "Plus l''argument de la rencontre impossible : quand elle est là je ne suis plus, quand je suis elle n''est pas. Lettre à Ménécée."
    },
    {
      "question": "Quelle opposition sépare Montaigne et Spinoza sur la mort ?",
      "choix": [
        "Aucune, ils disent la même chose",
        "Montaigne : « philosopher c''est apprendre à mourir » ; Spinoza : « l''homme libre ne pense pas à la mort ». Les deux cherchent la liberté par des chemins contraires",
        "Montaigne nie la mort",
        "Spinoza croit à l''immortalité"
      ],
      "bonne": 1,
      "explication": "Montaigne ajoute : « qui a appris à mourir, il a désappris à servir ». Spinoza répond que la tristesse diminue notre puissance d''agir."
    },
    {
      "question": "Qu''est-ce que l''être-pour-la-mort chez Heidegger ?",
      "choix": [
        "La peur de mourir",
        "La mort comme possibilité la plus propre, certaine et indépassable du Dasein — une structure présente de l''existence, non un événement futur",
        "Le suicide",
        "La croyance en l''au-delà"
      ],
      "bonne": 1,
      "explication": "Dire « ON meurt » est la fuite ordinaire, l''existence inauthentique. Assumer sa mort comme mienne rend le temps précieux. Être et Temps, 1927."
    },
    {
      "question": "Que soutient la conception africaine de la mort ?",
      "choix": [
        "Que la mort est un néant",
        "Que la mort est un passage : le défunt rejoint la communauté des ancêtres et continue d''y agir",
        "Que l''âme se réincarne en animal",
        "Qu''il ne faut pas en parler"
      ],
      "bonne": 1,
      "explication": "Birago Diop : « ceux qui sont morts ne sont jamais partis ». Cette thèse conteste une prémisse d''Épicure — la mort n''est plus privation totale."
    }
  ]
}', NULL, 5);

    RAISE NOTICE '% : 9 leçons ajoutées au chapitre 11, L''existence et la mort.', v_nom;
  END LOOP;
END $philo$;
