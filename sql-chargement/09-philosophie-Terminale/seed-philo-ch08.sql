-- ---------------------------------------------------------------------------
-- M'Andal — Philosophie, classes de Terminale
-- Chapitre 8 : Liberté et responsabilité
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
    WHERE programme_id = v_programme_id AND ordre = 8;

    IF v_chapitre_id IS NULL THEN
      INSERT INTO public.chapitres (programme_id, titre, ordre, niveau)
      VALUES (v_programme_id, 'Liberté et responsabilité', 8, 'Module 1 : La philosophie')
      RETURNING id INTO v_chapitre_id;
      RAISE NOTICE '% : chapitre 8 créé.', v_nom;
    END IF;

    -- Les leçons. Si le chapitre en a déjà, on passe son tour sans rien toucher.
    SELECT count(*) INTO v_deja FROM public.concepts WHERE chapitre_id = v_chapitre_id;
    IF v_deja > 0 THEN
      RAISE NOTICE '% : le chapitre 8 a déjà ses % leçons, je n''y touche pas.', v_nom, v_deja;
      CONTINUE;
    END IF;

    INSERT INTO public.concepts
      (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes) VALUES
      (v_chapitre_id, 'Liberté, déterminisme, fatalisme', 1, 'texte', '
Ce chapitre se perd presque toujours au même endroit : on confond déterminisme
et fatalisme. Réglons la question d''abord, le reste suivra.

### Les sens du mot « liberté »

**Le sens étymologique.** En latin, *liber* désigne celui qui n''est pas esclave.
La liberté est d''abord une **condition juridique** : être libre, c''est ne pas
appartenir à un autre.

**Le sens courant, ou liberté-indépendance.** C''est l''absence de contrainte :
faire ce que l''on veut. Un oiseau en cage n''est pas libre.

**Le libre arbitre.** C''est le pouvoir de la volonté de choisir entre plusieurs
possibles, sans y être déterminée. **Descartes** l''affirme sans détour : « la
volonté est tellement libre de sa nature qu''elle ne peut jamais être
contrainte ».

**La liberté-autonomie.** C''est se donner à soi-même sa propre loi — *autos*,
soi-même, *nomos*, la loi. **Kant** et **Rousseau** y voient la liberté véritable :
« l''obéissance à la loi qu''on s''est prescrite est liberté ». Elle s''oppose à
l''**hétéronomie**, où la loi vient d''ailleurs.

Remarquez que les deuxième et quatrième sens peuvent s''opposer : l''enfant qui
fait tout ce qu''il veut est libre au sens de l''indépendance, et nullement au
sens de l''autonomie.

### Le déterminisme

C''est le principe selon lequel **tout phénomène a une cause qui l''explique
nécessairement**. Les mêmes causes produisent les mêmes effets.

Ce n''est pas une doctrine du désespoir : c''est le principe de toute science.
Le médecin est déterministe, et c''est pour cela qu''il cherche la cause de la
fièvre — parce qu''en agissant sur la cause, il agira sur l''effet.

### Le fatalisme

C''est la croyance que les événements sont **écrits d''avance** par un destin,
et qu''aucune action ne peut les changer. Œdipe tue son père quoi qu''il fasse,
et c''est précisément en fuyant son destin qu''il l''accomplit.

### La différence, et elle est capitale

Le **déterminisme** dit : *cet effet a une cause*. Donc si je modifie la cause,
je modifie l''effet. **Le déterminisme fonde l''action.**

Le **fatalisme** dit : *cet événement arrivera de toute façon*. Donc agir ne
sert à rien. **Le fatalisme supprime l''action.**

Le déterministe va chez le médecin. Le fataliste n''y va pas.

### L''indéterminisme

C''est la thèse inverse du déterminisme : il existe des événements sans cause
déterminante, et la volonté humaine en fait partie.

---

**Exercice corrigé**

*Distinguer déterminisme et fatalisme, et montrer par un exemple que la
confusion des deux conduit à une conséquence pratique opposée.*

**Correction.**

*Les définitions.* Le **déterminisme** est le principe selon lequel tout
phénomène a une cause qui l''explique nécessairement ; les mêmes causes
produisent les mêmes effets. Le **fatalisme** est la croyance que les
événements sont fixés d''avance par un destin, et qu''aucune action humaine ne
peut en changer le cours.

*Le point commun, qui explique la confusion.* Les deux affirment une
**nécessité** : ce qui arrive ne pouvait pas ne pas arriver.

*La différence.* Le déterminisme fait dépendre l''effet de **causes
identifiables et modifiables**. Le fatalisme fait dépendre l''événement d''un
**destin**, qui n''est ni identifiable ni modifiable.

*L''exemple.* Un élève échoue à l''examen.

Le **fataliste** dit : c''était écrit, il n''était pas fait pour les études. Il
en tire une conséquence pratique : ne rien changer, puisque rien ne peut
changer.

Le **déterministe** dit : cet échec a des causes — un cours mal compris, un
travail mal réparti, trop peu de sommeil. Il en tire la conséquence opposée :
identifier les causes et agir sur elles, puisque les mêmes causes produisent
les mêmes effets.

*La conclusion.* La même thèse de la nécessité conduit à la résignation dans un
cas et à l''action dans l''autre. C''est pourquoi le déterminisme est le principe
de toutes les sciences, et le fatalisme leur contraire exact : une science
fataliste n''aurait aucune raison de chercher.
', NULL, 28),
      (v_chapitre_id, 'Figure : quatre doctrines sur la liberté', 2, 'figure', '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 560 300" width="560" height="300">
<rect width="560" height="300" fill="#ffffff"/>
<text x="280" y="24" text-anchor="middle" font-size="14" font-weight="700" fill="#0f172a">Quatre doctrines sur la liberté humaine</text>
<text x="280" y="42" text-anchor="middle" font-size="10" fill="#64748b">Ne confondez jamais déterminisme et fatalisme : c&apos;est l&apos;erreur la plus coûteuse du chapitre</text>

<rect x="18" y="56" width="128" height="106" rx="6" fill="#fee2e2" stroke="#b91c1c" stroke-width="1.6"/>
<text x="82" y="78" text-anchor="middle" font-size="11" font-weight="700" fill="#7f1d1d">FATALISME</text>
<text x="82" y="96" text-anchor="middle" font-size="8" fill="#991b1b">tout est écrit d&apos;avance</text>
<text x="82" y="110" text-anchor="middle" font-size="8" fill="#991b1b">par un destin</text>
<text x="82" y="130" text-anchor="middle" font-size="8" font-style="italic" fill="#475569">agir ne sert à rien</text>
<text x="82" y="150" text-anchor="middle" font-size="8" fill="#7f1d1d">Œdipe, le Mektoub</text>

<rect x="154" y="56" width="128" height="106" rx="6" fill="#fef3c7" stroke="#ca8a04" stroke-width="1.6"/>
<text x="218" y="78" text-anchor="middle" font-size="11" font-weight="700" fill="#78350f">DÉTERMINISME</text>
<text x="218" y="96" text-anchor="middle" font-size="8" fill="#92400e">tout effet a une cause</text>
<text x="218" y="110" text-anchor="middle" font-size="8" fill="#92400e">qui l&apos;explique</text>
<text x="218" y="130" text-anchor="middle" font-size="8" font-style="italic" fill="#475569">connaître les causes,</text>
<text x="218" y="142" text-anchor="middle" font-size="8" font-style="italic" fill="#475569">c&apos;est pouvoir agir</text>
<text x="218" y="156" text-anchor="middle" font-size="8" fill="#78350f">Spinoza, Freud, Marx</text>

<rect x="290" y="56" width="128" height="106" rx="6" fill="#dbeafe" stroke="#2563eb" stroke-width="1.6"/>
<text x="354" y="78" text-anchor="middle" font-size="11" font-weight="700" fill="#1e3a8a">LIBRE ARBITRE</text>
<text x="354" y="96" text-anchor="middle" font-size="8" fill="#1e40af">la volonté choisit</text>
<text x="354" y="110" text-anchor="middle" font-size="8" fill="#1e40af">sans être contrainte</text>
<text x="354" y="130" text-anchor="middle" font-size="8" font-style="italic" fill="#475569">je suis l&apos;auteur</text>
<text x="354" y="142" text-anchor="middle" font-size="8" font-style="italic" fill="#475569">de mes actes</text>
<text x="354" y="156" text-anchor="middle" font-size="8" fill="#1e3a8a">Descartes, Kant, Sartre</text>

<rect x="426" y="56" width="116" height="106" rx="6" fill="#dcfce7" stroke="#15803d" stroke-width="1.6"/>
<text x="484" y="78" text-anchor="middle" font-size="11" font-weight="700" fill="#14532d">LIBÉRATION</text>
<text x="484" y="96" text-anchor="middle" font-size="8" fill="#166534">la liberté se conquiert</text>
<text x="484" y="110" text-anchor="middle" font-size="8" fill="#166534">par la connaissance</text>
<text x="484" y="130" text-anchor="middle" font-size="8" font-style="italic" fill="#475569">on ne naît pas libre,</text>
<text x="484" y="142" text-anchor="middle" font-size="8" font-style="italic" fill="#475569">on le devient</text>
<text x="484" y="156" text-anchor="middle" font-size="8" fill="#14532d">Spinoza, Hegel, Bergson</text>

<line x1="146" y1="109" x2="154" y2="109" stroke="#94a3b8" stroke-dasharray="2 2"/>
<text x="280" y="192" text-anchor="middle" font-size="11" font-weight="700" fill="#7f1d1d">Le fatalisme supprime l&apos;action. Le déterminisme la rend possible.</text>
<text x="280" y="210" text-anchor="middle" font-size="10" fill="#475569">Le médecin est déterministe : il cherche la cause pour agir sur elle.</text>
<text x="280" y="226" text-anchor="middle" font-size="10" fill="#475569">Le fataliste ne va pas chez le médecin.</text>

<rect x="90" y="242" width="380" height="46" rx="6" fill="#f1f5f9" stroke="#94a3b8"/>
<text x="280" y="260" text-anchor="middle" font-size="10" font-weight="700" fill="#0f172a">Sans liberté, aucune responsabilité</text>
<text x="280" y="278" text-anchor="middle" font-size="9" fill="#475569">on ne juge pas le fou, l&apos;enfant, celui qu&apos;on a contraint</text>
</svg>', NULL, 5),
      (v_chapitre_id, 'Simulation : déterminisme ou fatalisme ?', 3, 'interactif', '{
  "widget": "determinisme-fatalisme",
  "consigne": "Douze propos te sont soumis — « c''était écrit », « il a échoué parce qu''il n''a pas révisé », « on ne change pas la nature humaine », « son enfance explique sa violence » — et tu les classes entre fatalisme, déterminisme et libre arbitre. Pour chacun, la simulation te demande ensuite la conséquence pratique : faut-il agir ou non ? Tu découvres que les propos déterministes appellent toujours une action, et les propos fatalistes jamais."
}', NULL, 10),
      (v_chapitre_id, 'L''homme est-il libre ?', 4, 'texte', '
Premier problème du chapitre, et le plus fréquent au Baccalauréat.

### Thèse : l''homme n''est pas libre

**Argument 1 — le déterminisme universel.** Tout phénomène a une cause. Si mes
actes sont des phénomènes, ils ont des causes, et je ne les choisis pas.
**Leibniz** : rien n''arrive sans raison déterminante. **Laplace** imagine une
intelligence qui, connaissant toutes les causes à un instant, connaîtrait tout
l''avenir. **Spinoza** va plus loin : les hommes se croient libres parce qu''ils
sont conscients de leurs désirs et ignorants des causes qui les déterminent.
La liberté serait donc une **illusion** née de l''ignorance.

**Argument 2 — le déterminisme psychique.** **Freud** : nos actes sont
commandés par des pulsions inconscientes. Le moi n''est pas maître chez lui, et
quand je crois choisir, je rationalise après coup une décision prise sans moi.

**Argument 3 — le déterminisme social.** **Marx** : ce ne sont pas les idées des
hommes qui déterminent leur existence sociale, mais leur existence sociale qui
détermine leurs idées. **Durkheim** montre que les faits sociaux s''imposent à
nous de l''extérieur. Même ce que je crois mes goûts m''a été donné par mon
milieu, ma langue, ma classe, mon époque.

**Argument 4 — le déterminisme biologique.** L''hérédité, le tempérament, les
besoins du corps. **Taine** résume : l''homme est le produit de la race, du
milieu et du moment.

### Antithèse : l''homme est libre

**Argument 1 — le témoignage de la conscience.** **Descartes** : la volonté est
si libre qu''elle ne peut jamais être contrainte. Je puis douter de tout, et ce
doute même est un acte libre. L''expérience du choix est pour Descartes la mieux
connue de toutes.

**Argument 2 — la liberté comme condition de la morale.** C''est l''argument de
**Kant**, et il est fort. Si je ne suis pas libre, le mot « devoir » ne veut
rien dire : on ne commande qu''à ce qui peut obéir. Or j''éprouve l''obligation
morale. Donc je suis libre. Kant le formule ainsi : **« tu dois, donc tu
peux »**. La liberté n''est pas prouvée par l''expérience, elle est **postulée**
par la raison pratique.

**Argument 3 — l''existence précède l''essence.** **Sartre** : l''homme n''a pas de
nature donnée qui le déterminerait ; il est d''abord, et il se définit ensuite
par ses actes. Il est donc **« condamné à être libre »** — condamné, parce
qu''il ne peut pas ne pas choisir. Même refuser de choisir est un choix, et
invoquer ses déterminismes pour se justifier est ce que Sartre appelle la
**mauvaise foi**.

**Argument 4 — l''imprévisibilité de l''acte créateur.** **Bergson** : le moi
profond, quand il agit vraiment, invente. Aucun calcul sur le passé ne permet
de prévoir ce qu''un artiste va créer.

### Le départage

Les deux thèses ne se contredisent pas tout à fait, parce qu''elles ne parlent
pas de la même liberté.

Les déterministes ont raison contre la liberté **absolue** : je ne choisis ni
mon corps, ni mon époque, ni ma langue, ni mes premières années.

Les partisans de la liberté ont raison contre la liberté **nulle** : entre les
contraintes, il reste une marge, et c''est dans cette marge que je deviens
quelqu''un.

D''où la formule qui ferme le mieux une copie : **la liberté n''est pas un état,
c''est une conquête.** On ne naît pas libre, on le devient — en connaissant ce
qui nous détermine. **Spinoza** le dit dans son langage : la liberté est la
connaissance de la nécessité. Celui qui ignore ce qui le pousse est poussé ;
celui qui le sait peut faire autrement.

---

**Exercice corrigé**

*Sartre écrit que l''homme est « condamné à être libre ». Expliquer la formule,
puis indiquer une limite.*

**Correction.**

*L''explication du paradoxe.* Les deux mots semblent se contredire : une
condamnation est une contrainte, et la liberté est l''absence de contrainte.
Sartre les réunit volontairement.

*« Libre ».* Pour Sartre, l''existence précède l''essence : l''homme n''a pas de
nature donnée d''avance qui dicterait sa conduite. Il n''est rien d''autre que ce
qu''il se fait. Aucun déterminisme — ni Dieu, ni l''hérédité, ni le milieu — ne
peut décider à sa place du sens qu''il donne à sa situation.

*« Condamné ».* Parce que cette liberté n''est pas choisie : elle est subie. Je
n''ai pas choisi d''avoir à choisir. Et je ne peux pas m''en débarrasser : ne pas
choisir est encore un choix, puisque je choisis alors de laisser faire.

La liberté est donc un **fardeau** : elle rend l''homme entièrement
**responsable**, sans excuse. Invoquer son éducation ou son caractère pour
justifier sa conduite, c''est ce que Sartre nomme la **mauvaise foi** — se
mentir à soi-même en se faisant passer pour une chose.

*Une limite, et il en faut une.* La formule sous-estime le poids des
déterminismes. Celui qui n''a jamais été à l''école et celui qui a fait des
études n''ont pas la même gamme de choix possibles : leur liberté formelle est
égale, leur liberté réelle ne l''est pas.

**Marx** et **Durkheim** opposeraient que les conditions sociales ne sont pas
seulement une « situation » que j''interprète, mais ce qui façonne l''interprète
lui-même. La liberté sartrienne risque alors de devenir une liberté de
l''intention, qui laisse l''inégalité des conditions intacte.

*On peut conclure en gardant ce qui résiste : même sous la contrainte la plus
lourde, il reste le choix de l''attitude — et c''est ce reste que Sartre appelle
liberté.*
', NULL, 34),
      (v_chapitre_id, 'Simulation : les causes et la marge', 5, 'interactif', '{
  "widget": "causes-et-marge",
  "consigne": "Un personnage t''est présenté avec ses déterminismes : son hérédité, son milieu social, son éducation, son époque, ses pulsions. Tu peux les activer un par un et voir la zone de ses choix possibles se rétrécir sur un graphique. Pousse tous les curseurs au maximum : la zone ne disparaît jamais complètement, et la simulation te montre ce qui reste — le choix de l''attitude, que Sartre appelle liberté. Puis essaie le bouton « connaître ses causes » : la zone s''élargit, et tu tiens la thèse de Spinoza en image."
}', NULL, 10),
      (v_chapitre_id, 'Liberté et responsabilité', 6, 'texte', '
Second problème : pourquoi les deux notions sont-elles au programme ensemble ?
Parce que l''une n''a aucun sens sans l''autre.

### La responsabilité

Est **responsable** celui qui doit répondre de ses actes. Le mot vient de
*respondere*, répondre.

On distingue la **responsabilité juridique** — répondre devant un tribunal — et
la **responsabilité morale** — répondre devant sa conscience. Les deux ne se
recouvrent pas : on peut être relaxé par un juge et se sentir coupable.

### Pas de responsabilité sans liberté

Le lien est logique, et il se vérifie dans tous les droits du monde.

On ne juge pas l''**enfant** en bas âge, parce qu''il ne discerne pas. On ne juge
pas celui dont le **discernement était aboli**, parce qu''il n''était pas maître
de lui. On atténue la peine de celui qui a agi sous la **contrainte**, parce que
sa volonté n''était pas entière.

Dans les trois cas, c''est la même règle : **on n''impute un acte qu''à qui
pouvait faire autrement.**

Les circonstances atténuantes sont donc la preuve, inscrite dans le Code, que
le droit tout entier suppose la liberté. Un déterminisme absolu rendrait toute
justice absurde — on ne punit pas une pierre qui tombe.

### Pas de liberté sans responsabilité

L''inverse est vrai aussi, et c''est là que **Sartre** insiste. Si je suis libre,
je ne peux rien mettre sur le compte d''autre chose : ni mon enfance, ni mon
caractère, ni les circonstances. « Nous sommes seuls, sans excuses. »

Et **Kant** ajoute l''universel : l''acte dont je suis responsable, je dois
pouvoir vouloir que tout le monde le fasse.

### Jusqu''où va la responsabilité ?

Trois extensions au programme, et elles valent des exemples en copie.

**La responsabilité envers autrui.** **Emmanuel Levinas** : le visage d''autrui
m''oblige avant même que je l''aie choisi.

**La responsabilité envers les générations futures.** **Hans Jonas** formule un
nouvel impératif : agis de façon que les effets de ton action soient compatibles
avec la permanence d''une vie authentiquement humaine sur terre. La pollution et
la déforestation engagent ceux qui ne sont pas encore nés.

**La responsabilité collective.** Peut-on être responsable de ce qu''a fait son
groupe ? Le droit répond non pour la faute, mais oui pour la réparation.

### La synthèse

Liberté et responsabilité ne sont pas deux notions qui se limiteraient l''une
l''autre : elles s''**impliquent**.

Une liberté sans responsabilité serait un caprice, et le caprice n''est pas la
liberté mais sa caricature : celui qui suit toutes ses impulsions obéit à la
dernière venue.

Une responsabilité sans liberté serait une injustice : punir qui ne pouvait pas
faire autrement.

La vraie liberté est donc celle qui **assume ses conséquences**. C''est pourquoi
on dit d''un adulte qu''il est libre et d''un enfant qu''il ne l''est pas encore : la
différence n''est pas dans le pouvoir de faire, elle est dans la capacité de
répondre.

---

**Exercice corrigé**

*Pourquoi le droit prévoit-il des circonstances atténuantes ? Que cela
prouve-t-il sur le rapport de la liberté et de la responsabilité ?*

**Correction.**

*Ce que sont les circonstances atténuantes.* Des faits qui, sans supprimer
l''infraction, diminuent la peine : la contrainte subie, la provocation, le
jeune âge, l''altération du discernement.

*Pourquoi le droit les prévoit.* Parce qu''il ne punit pas un acte, il punit un
**auteur**. Or un auteur n''est pleinement auteur que s''il était pleinement
maître de son acte. Quand sa maîtrise était réduite, sa part dans l''acte est
réduite, et la peine doit l''être aussi.

On le voit mieux par les cas extrêmes. L''enfant en bas âge n''est pas jugé du
tout, parce qu''il ne discerne pas. Celui dont le discernement était aboli n''est
pas jugé non plus, mais soigné. Entre ces deux extrêmes et la responsabilité
pleine, les circonstances atténuantes assurent le dégradé.

*Ce que cela prouve.* Que la responsabilité est **proportionnelle à la
liberté**. Le droit mesure la seconde pour fixer la première.

Autrement dit, le Code pénal est **déterministe sur les causes et libertaire sur
l''imputation** : il admet que des causes expliquent l''acte, et il maintient que
l''auteur devait répondre. C''est cette double exigence qui rend la justice
possible, et qui la rend difficile.

*La conséquence philosophique.* Si le déterminisme était absolu, aucune peine ne
serait juste : toutes les circonstances seraient atténuantes, et il ne resterait
plus de coupable. Si la liberté était absolue, aucune circonstance ne pourrait
atténuer : tout criminel mériterait la peine maximale.

Le droit réel se tient entre les deux, et il a raison : les hommes ne sont ni
des pierres qui tombent ni des anges qui choisissent dans le vide.
', NULL, 30),
      (v_chapitre_id, 'Simulation : le tribunal des circonstances', 7, 'interactif', '{
  "widget": "tribunal-circonstances",
  "consigne": "Dix affaires te sont présentées — un enfant de sept ans, un homme menacé d''une arme, un conducteur ivre, quelqu''un dont le discernement était aboli, un complice contraint par sa famille — et tu dois fixer pour chacune la part de liberté de l''auteur, puis la peine qui en découle. La simulation compare ton verdict à la règle du Code et t''explique l''écart. Essaie ensuite les deux boutons extrêmes : « déterminisme absolu » fait tomber toutes les peines à zéro, « liberté absolue » les porte toutes au maximum. Tu comprends alors pourquoi aucun droit ne tient à l''une ou l''autre de ces positions."
}', NULL, 10),
      (v_chapitre_id, 'Sujet type Baccalauréat — Sommes-nous responsables de ce que nous sommes ?', 8, 'texte', '
**Deuxième partie de l''épreuve — Évaluation de l''agir compétent — 9 points**

*En te fondant sur ta culture philosophique et dans le respect des règles de la
logique, est-il légitime de penser que nous sommes responsables de ce que nous
sommes ?*

---
---

## Corrigé

### I. Analyse et compréhension du sujet

**Les concepts-clés.** *Responsable* : qui doit répondre de quelque chose
devant une instance, et qui peut donc en être loué ou blâmé. *Ce que nous
sommes* : non pas ce que nous faisons, mais notre caractère, nos goûts, nos
dispositions — ce qui nous définit.

**Reformulation.** Avons-nous de bonnes raisons de soutenir que chacun est
l''auteur de son propre caractère ?

**Le présupposé.** Que nous puissions être les auteurs de ce que nous sommes,
et pas seulement de ce que nous faisons. C''est beaucoup demander, et c''est
l''intérêt du sujet.

**La thèse opposée.** Nous ne sommes pas responsables de ce que nous sommes :
nous le découvrons.

**Le problème.** Le rapport de la liberté et de la responsabilité.

**La problématique.** Notre caractère est-il le produit de causes que nous
n''avons pas choisies, ou le résultat d''une suite de choix dont nous devons
répondre ?

### II. Première tâche — la thèse : nous sommes responsables *(3 points)*

**Argument 1.** L''existence précède l''essence. **Sartre** : l''homme n''est rien
d''autre que ce qu''il se fait. Il est « condamné à être libre », et invoquer son
caractère pour s''excuser est de la **mauvaise foi** — car ce caractère, il l''a
construit par ses actes répétés.

**Argument 2.** Le témoignage de la conscience. **Descartes** : la volonté est
si libre qu''elle ne peut jamais être contrainte. Je sais, quand je choisis, que
j''aurais pu choisir autrement.

**Argument 3.** La morale l''exige. **Kant** : si je ne pouvais pas faire
autrement, le mot « devoir » n''aurait aucun sens, car on ne commande qu''à ce qui
peut obéir. Or j''éprouve l''obligation. Donc je suis libre, et donc responsable.
« Tu dois, donc tu peux. »

*Transition.* Mais ce que je suis ne commence-t-il pas bien avant mes premiers
choix ?

### III. Deuxième tâche — l''antithèse : nous ne le sommes pas *(3 points)*

**Argument 1.** Le déterminisme psychique. **Freud** : le moi n''est pas maître
chez lui. Mes désirs sont commandés par un inconscient que je n''ai pas formé,
et dont les premières années ont décidé.

**Argument 2.** Le déterminisme social. **Marx** : l''existence sociale
détermine la conscience. **Durkheim** : les faits sociaux s''imposent du dehors.
Ma langue, ma religion, mes goûts, ma manière même de raisonner m''ont été
transmis avant que je puisse en juger.

**Argument 3.** L''illusion de la liberté. **Spinoza** : les hommes se croient
libres parce qu''ils sont conscients de leurs désirs et ignorants des causes qui
les déterminent. **Taine** : l''homme est le produit de la race, du milieu et du
moment. Nul ne choisit son hérédité, son siècle, ni son enfance.

*Transition.* Faut-il alors conclure que personne n''est jamais responsable de
rien, et renoncer à toute justice ?

### IV. Troisième tâche — la synthèse *(3 points)*

**Premier moment — distinguer deux questions que le sujet confond.** Suis-je
responsable de mon **point de départ** ? Non : ni mon corps, ni ma langue, ni
mes premières années ne m''ont été soumis. Suis-je responsable de ce que j''en
**fais** ? Oui, dans la mesure où une marge subsiste.

**Deuxième moment — la preuve par le droit.** Les **circonstances atténuantes**
montrent que les hommes ont toujours raisonné ainsi. Le droit n''impute pleinement
qu''à qui pouvait pleinement faire autrement : il réduit la peine quand il
reconnaît une cause, et il la maintient quand il reconnaît une marge. Un
déterminisme absolu supprimerait la justice ; une liberté absolue supprimerait
toute circonstance atténuante.

**Troisième moment — la liberté comme conquête.** La formule qui lève le
paradoxe est celle de **Spinoza** : la liberté est la connaissance de la
nécessité. Celui qui ignore ce qui le pousse est poussé ; celui qui l''a reconnu
peut agir sur la cause, comme le médecin agit sur la fièvre. Nous ne sommes donc
pas responsables de ce que nous sommes **devenus** sans le savoir ; nous le
devenons de ce que nous choisissons d''en faire à partir du moment où nous le
savons.

**Conclusion.** Il n''est pas tout à fait légitime de penser que nous sommes
responsables de ce que nous sommes, si l''on parle de notre point de départ. Il
le devient dès qu''on parle de ce que nous en faisons. La liberté n''est pas un
état que l''on constate, c''est une conquête que l''on mène — et la responsabilité
grandit exactement avec elle. Reste à savoir si cette conquête est une affaire
individuelle, ou si elle suppose aussi des conditions collectives.

---

### Ce que le correcteur attend

**Que le présupposé soit repéré** : le sujet parle de ce que nous *sommes*, pas
de ce que nous *faisons*. Les copies qui glissent de l''un à l''autre perdent le
sujet.

**Déterminisme et fatalisme non confondus.** Une copie qui écrit « tout est
déterminé donc rien ne sert d''agir » se contredit.

**Les circonstances atténuantes en synthèse** : c''est l''exemple qui montre que
la liberté se mesure, au lieu d''être tout ou rien.
', NULL, 34),
      (v_chapitre_id, 'Quiz du chapitre 8', 9, 'quiz', '{
  "titre": "Vérifie que tu as compris",
  "questions": [
    {
      "question": "Quelle est la différence entre déterminisme et fatalisme ?",
      "choix": [
        "Aucune",
        "Le déterminisme fait dépendre l''effet de causes identifiables et modifiables, donc il fonde l''action ; le fatalisme invoque un destin, donc il la supprime",
        "Le fatalisme est scientifique",
        "Le déterminisme nie les causes"
      ],
      "bonne": 1,
      "explication": "Le déterministe va chez le médecin parce qu''il cherche la cause pour agir sur elle. Le fataliste n''y va pas. C''est la confusion la plus coûteuse du chapitre."
    },
    {
      "question": "Que signifie « liberté-autonomie » ?",
      "choix": [
        "Faire tout ce qu''on veut",
        "Se donner à soi-même sa propre loi : autos, soi-même, nomos, la loi",
        "Ne pas être esclave",
        "Choisir entre plusieurs possibles"
      ],
      "bonne": 1,
      "explication": "Elle s''oppose à l''hétéronomie, où la loi vient d''ailleurs. L''enfant qui fait tout ce qu''il veut est indépendant, pas autonome."
    },
    {
      "question": "Pourquoi Spinoza dit-il que la liberté est une illusion ?",
      "choix": [
        "Parce que Dieu décide de tout",
        "Parce que les hommes sont conscients de leurs désirs et ignorants des causes qui les déterminent",
        "Parce que la volonté n''existe pas",
        "Parce que le destin est écrit"
      ],
      "bonne": 1,
      "explication": "Mais Spinoza ajoute le remède : la liberté est la connaissance de la nécessité. Celui qui ignore ce qui le pousse est poussé."
    },
    {
      "question": "Quel est l''argument de Kant en faveur de la liberté ?",
      "choix": [
        "La conscience en témoigne",
        "Si je ne suis pas libre, « devoir » n''a aucun sens : on ne commande qu''à ce qui peut obéir. Or j''éprouve l''obligation morale, donc je suis libre",
        "La science le prouve",
        "L''homme n''a pas de nature"
      ],
      "bonne": 1,
      "explication": "Kant le formule ainsi : « tu dois, donc tu peux ». La liberté n''est pas prouvée par l''expérience, elle est postulée par la raison pratique."
    },
    {
      "question": "Que veut dire Sartre en écrivant que l''homme est « condamné à être libre » ?",
      "choix": [
        "Que la liberté est un malheur",
        "Que l''homme n''a pas choisi d''avoir à choisir et ne peut pas s''en débarrasser, puisque ne pas choisir est encore un choix",
        "Que la société l''oblige",
        "Que Dieu l''a voulu"
      ],
      "bonne": 1,
      "explication": "D''où la mauvaise foi : invoquer son éducation ou son caractère pour se justifier, c''est se faire passer pour une chose."
    },
    {
      "question": "Que prouvent les circonstances atténuantes ?",
      "choix": [
        "Que les juges sont indulgents",
        "Que la responsabilité est proportionnelle à la liberté : on n''impute pleinement qu''à qui pouvait pleinement faire autrement",
        "Que le déterminisme est faux",
        "Que la loi est injuste"
      ],
      "bonne": 1,
      "explication": "Si le déterminisme était absolu, toutes les circonstances seraient atténuantes et il ne resterait aucun coupable. On ne punit pas une pierre qui tombe."
    },
    {
      "question": "Quel impératif Hans Jonas formule-t-il ?",
      "choix": [
        "Agis de telle sorte que ta maxime devienne universelle",
        "Agis de façon que les effets de ton action soient compatibles avec la permanence d''une vie authentiquement humaine sur terre",
        "Connais-toi toi-même",
        "Deviens ce que tu es"
      ],
      "bonne": 1,
      "explication": "C''est la responsabilité envers les générations futures : la pollution et la déforestation engagent ceux qui ne sont pas encore nés. Le premier énoncé est de Kant."
    }
  ]
}', NULL, 5);

    RAISE NOTICE '% : 9 leçons ajoutées au chapitre 8, Liberté et responsabilité.', v_nom;
  END LOOP;
END $philo$;
