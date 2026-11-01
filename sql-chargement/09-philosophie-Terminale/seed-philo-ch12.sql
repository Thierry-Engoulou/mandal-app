-- ---------------------------------------------------------------------------
-- M'Andal — Philosophie, classes de Terminale
-- Chapitre 12 : Dieu et la religion
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
    WHERE programme_id = v_programme_id AND ordre = 12;

    IF v_chapitre_id IS NULL THEN
      INSERT INTO public.chapitres (programme_id, titre, ordre, niveau)
      VALUES (v_programme_id, 'Dieu et la religion', 12, 'Module 1 : La philosophie')
      RETURNING id INTO v_chapitre_id;
      RAISE NOTICE '% : chapitre 12 créé.', v_nom;
    END IF;

    -- Les leçons. Si le chapitre en a déjà, on passe son tour sans rien toucher.
    SELECT count(*) INTO v_deja FROM public.concepts WHERE chapitre_id = v_chapitre_id;
    IF v_deja > 0 THEN
      RAISE NOTICE '% : le chapitre 12 a déjà ses % leçons, je n''y touche pas.', v_nom, v_deja;
      CONTINUE;
    END IF;

    INSERT INTO public.concepts
      (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes) VALUES
      (v_chapitre_id, 'Dieu, la religion, la foi : les mots d''abord', 1, 'texte', '
Ce chapitre est celui où l''on risque le plus de confondre croire et savoir, et
aussi le plus de blesser. Posons les mots avec soin.

### L''étymologie de « religion »

Deux étymologies latines sont proposées, et elles éclairent deux aspects.

**Cicéron** la rattache à *relegere*, relire, recueillir soigneusement : la
religion serait d''abord le **scrupule**, le soin apporté au culte.

**Lactance** la rattache à *religare*, relier : la religion serait le **lien**
entre l''homme et le divin, et entre les hommes qui partagent ce lien.

Les deux sens sont présents dans toute religion réelle : des rites observés avec
soin, et une communauté qu''ils relient.

### La définition de Durkheim

**Émile Durkheim**, dans *Les formes élémentaires de la vie religieuse* (1912),
donne la définition la plus utilisée en sciences humaines :

La religion est « **un système solidaire de croyances et de pratiques relatives
à des choses sacrées, c''est-à-dire séparées, interdites** », qui unit en une
même communauté morale ceux qui y adhèrent.

Trois éléments à retenir : des **croyances**, des **pratiques**, et une
**communauté**. Une religion n''est jamais une opinion privée.

La distinction qui la commande est celle du **sacré** et du **profane**. Le sacré
est ce qui est mis à part, soustrait à l''usage ordinaire ; le profane est le
reste. Ce n''est pas la nature de l''objet qui le rend sacré — une pierre, un
arbre, un livre — c''est sa **séparation**.

### Le vocabulaire à ne pas confondre

**La foi** est l''adhésion à ce qui n''est pas démontré, assumée comme telle. Elle
n''est pas une connaissance faible : elle est d''un autre ordre que la
connaissance.

**Le théisme** affirme un Dieu personnel, qui intervient dans le monde.

**Le déisme** affirme un Dieu créateur, mais qui n''intervient pas et n''exige pas
de culte particulier. Voltaire est déiste, non chrétien.

**L''athéisme** nie l''existence de Dieu. C''est une **position**, qui a donc à se
justifier comme toute autre.

**L''agnosticisme** soutient qu''on ne peut pas savoir. Ce n''est pas un athéisme
timide : c''est une thèse sur les limites de la connaissance.

Et une remarque de méthode qui vaut pour tout le chapitre : « Dieu existe-t-il ? »
et « la religion est-elle utile ? » sont **deux questions distinctes**. La
première est métaphysique, la seconde sociologique. On peut répondre non à la
première et oui à la seconde, comme Durkheim ; ou l''inverse. Confondre les deux
est l''erreur la plus fréquente en copie.

---

**Exercice corrigé**

*Définir la religion selon Durkheim et expliquer la distinction du sacré et du
profane. Préciser ce que cette approche laisse de côté.*

**Correction.**

*La définition.* Pour **Durkheim**, dans *Les formes élémentaires de la vie
religieuse*, la religion est un système solidaire de croyances et de pratiques
relatives à des choses sacrées, c''est-à-dire séparées et interdites, et qui unit
en une même communauté morale ceux qui y adhèrent.

Trois éléments la composent : des **croyances** — ce qu''on tient pour vrai —,
des **pratiques** — rites, prières, interdits —, et une **communauté**, que
Durkheim nomme l''Église au sens large. Le mot « solidaire » signifie que ces
éléments se tiennent : on ne peut pas en retirer un sans défaire les autres.

*Le sacré et le profane.* Le **sacré** est ce qui est mis à part, soustrait à
l''usage ordinaire, entouré d''interdits. Le **profane** est le domaine de la vie
courante.

Le point important, et il est contre-intuitif : **rien n''est sacré par nature**.
Une pierre, un arbre, un animal, un livre, un jour de la semaine peuvent l''être
ou ne pas l''être. C''est la **séparation** instituée par le groupe qui fait le
sacré, non une propriété de l''objet.

C''est pourquoi la profanation est si grave aux yeux des croyants : elle ne
détériore pas l''objet, elle abolit la séparation.

*Ce que cette approche laisse de côté, et il faut le dire.* Durkheim étudie la
religion comme **fait social**. Il décrit sa fonction : elle unit, elle produit
de la conscience commune, et il va jusqu''à dire que dans ses cérémonies, la
société s''adore elle-même.

Deux choses échappent alors à son analyse.

**La question de la vérité.** Dire à quoi sert une croyance ne dit pas si elle
est vraie. Montrer que la religion unit le groupe ne prouve ni que Dieu existe ni
qu''il n''existe pas.

**L''expérience du croyant.** Pour celui qui prie, il ne s''agit pas d''un lien
social mais d''une relation personnelle. La sociologie décrit du dehors ce qui est
d''abord vécu du dedans — et elle n''a pas les moyens de ce dedans.

*On peut conclure que l''approche de Durkheim est rigoureuse dans son domaine, à
condition de ne pas transformer une explication fonctionnelle en réfutation : ce
serait sortir de la science pour prendre parti, ce que la science ne peut pas
faire ici.*
', NULL, 28),
      (v_chapitre_id, 'Simulation : théisme, déisme, athéisme, agnosticisme', 2, 'interactif', '{
  "widget": "positions-religieuses",
  "consigne": "Quinze affirmations te sont proposées — « Dieu a créé le monde puis l''a laissé tourner », « je ne peux pas savoir », « Dieu entend mes prières », « la religion est utile même si Dieu n''existe pas » — et tu dois identifier la position de celui qui parle. La simulation te place ensuite chaque position sur deux axes : Dieu existe-t-il, et peut-on le savoir ? Tu découvres alors que l''agnosticisme n''est pas un athéisme timide, et que la question « Dieu existe-t-il ? » et la question « la religion est-elle utile ? » sont indépendantes — ce qui te sauvera au moins un hors-sujet."
}', NULL, 10),
      (v_chapitre_id, 'Figure : trois preuves et leurs objections', 3, 'figure', '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 580 330" width="580" height="330">
<rect width="580" height="330" fill="#ffffff"/>
<text x="290" y="24" text-anchor="middle" font-size="14" font-weight="700" fill="#0f172a">Trois preuves de l&apos;existence de Dieu, et leurs objections</text>

<rect x="18" y="44" width="178" height="150" rx="6" fill="#dbeafe" stroke="#2563eb" stroke-width="1.6"/>
<text x="107" y="64" text-anchor="middle" font-size="11" font-weight="700" fill="#1e3a8a">ONTOLOGIQUE</text>
<text x="107" y="78" text-anchor="middle" font-size="8" fill="#1e40af">Anselme, Descartes</text>
<line x1="30" y1="86" x2="184" y2="86" stroke="#93c5fd"/>
<text x="28" y="104" font-size="8" fill="#1e40af">J&apos;ai l&apos;idée d&apos;un être</text>
<text x="28" y="116" font-size="8" fill="#1e40af">parfait.</text>
<text x="28" y="134" font-size="8" fill="#1e40af">Un être parfait qui</text>
<text x="28" y="146" font-size="8" fill="#1e40af">n&apos;existerait pas serait</text>
<text x="28" y="158" font-size="8" fill="#1e40af">imparfait.</text>
<text x="28" y="178" font-size="8" font-weight="700" fill="#1e3a8a">Donc il existe.</text>

<rect x="202" y="44" width="178" height="150" rx="6" fill="#fef3c7" stroke="#ca8a04" stroke-width="1.6"/>
<text x="291" y="64" text-anchor="middle" font-size="11" font-weight="700" fill="#78350f">COSMOLOGIQUE</text>
<text x="291" y="78" text-anchor="middle" font-size="8" fill="#92400e">Thomas d&apos;Aquin, Leibniz</text>
<line x1="214" y1="86" x2="368" y2="86" stroke="#fde047"/>
<text x="212" y="104" font-size="8" fill="#92400e">Tout ce qui est a une</text>
<text x="212" y="116" font-size="8" fill="#92400e">cause.</text>
<text x="212" y="134" font-size="8" fill="#92400e">La série des causes ne</text>
<text x="212" y="146" font-size="8" fill="#92400e">peut pas être infinie.</text>
<text x="212" y="166" font-size="8" font-weight="700" fill="#78350f">Donc une cause</text>
<text x="212" y="178" font-size="8" font-weight="700" fill="#78350f">première existe.</text>

<rect x="386" y="44" width="176" height="150" rx="6" fill="#dcfce7" stroke="#15803d" stroke-width="1.6"/>
<text x="474" y="64" text-anchor="middle" font-size="11" font-weight="700" fill="#14532d">PAR LE DESSEIN</text>
<text x="474" y="78" text-anchor="middle" font-size="8" fill="#166534">Voltaire, les stoïciens</text>
<line x1="398" y1="86" x2="550" y2="86" stroke="#86efac"/>
<text x="396" y="104" font-size="8" fill="#166534">Le monde est ordonné</text>
<text x="396" y="116" font-size="8" fill="#166534">comme une horloge.</text>
<text x="396" y="134" font-size="8" fill="#166534">Un ordre suppose un</text>
<text x="396" y="146" font-size="8" fill="#166534">ordonnateur.</text>
<text x="396" y="166" font-size="8" font-weight="700" fill="#14532d">Donc il y a un</text>
<text x="396" y="178" font-size="8" font-weight="700" fill="#14532d">horloger.</text>

<path d="M 107 194 L 107 212" fill="none" stroke="#b91c1c" stroke-width="1.4"/>
<polygon points="107,218 103,210 111,210" fill="#b91c1c"/>
<path d="M 291 194 L 291 212" fill="none" stroke="#b91c1c" stroke-width="1.4"/>
<polygon points="291,218 287,210 295,210" fill="#b91c1c"/>
<path d="M 474 194 L 474 212" fill="none" stroke="#b91c1c" stroke-width="1.4"/>
<polygon points="474,218 470,210 478,210" fill="#b91c1c"/>

<rect x="18" y="220" width="178" height="80" rx="6" fill="#fee2e2" stroke="#b91c1c" stroke-width="1.4"/>
<text x="107" y="238" text-anchor="middle" font-size="9" font-weight="700" fill="#7f1d1d">KANT</text>
<text x="28" y="256" font-size="8" fill="#991b1b">L&apos;existence n&apos;est pas une</text>
<text x="28" y="268" font-size="8" fill="#991b1b">qualité de plus.</text>
<text x="28" y="286" font-size="8" font-style="italic" fill="#7f1d1d">« cent thalers réels »</text>

<rect x="202" y="220" width="178" height="80" rx="6" fill="#fee2e2" stroke="#b91c1c" stroke-width="1.4"/>
<text x="291" y="238" text-anchor="middle" font-size="9" font-weight="700" fill="#7f1d1d">L&apos;OBJECTION DE LA SÉRIE</text>
<text x="212" y="256" font-size="8" fill="#991b1b">Pourquoi arrêter la série ?</text>
<text x="212" y="268" font-size="8" fill="#991b1b">Qui a causé la cause</text>
<text x="212" y="280" font-size="8" fill="#991b1b">première ?</text>
<text x="212" y="296" font-size="8" font-style="italic" fill="#7f1d1d">la règle s&apos;arrête où l&apos;on veut</text>

<rect x="386" y="220" width="176" height="80" rx="6" fill="#fee2e2" stroke="#b91c1c" stroke-width="1.4"/>
<text x="474" y="238" text-anchor="middle" font-size="9" font-weight="700" fill="#7f1d1d">LE PROBLÈME DU MAL</text>
<text x="396" y="256" font-size="8" fill="#991b1b">Si l&apos;horloger est bon,</text>
<text x="396" y="268" font-size="8" fill="#991b1b">pourquoi l&apos;horloge</text>
<text x="396" y="280" font-size="8" fill="#991b1b">broie-t-elle les innocents ?</text>
<text x="474" y="296" text-anchor="middle" font-size="8" font-style="italic" fill="#7f1d1d">Épicure, Voltaire</text>

<text x="290" y="322" text-anchor="middle" font-size="10" font-weight="700" fill="#0f172a">Kant conclut : Dieu n&apos;est pas un objet de connaissance, mais un postulat de la raison pratique.</text>
</svg>', NULL, 5),
      (v_chapitre_id, 'Peut-on prouver que Dieu existe ?', 4, 'texte', '
Trois preuves classiques, trois objections. C''est le cœur du chapitre, et il
faut connaître les deux côtés avec la même précision.

### La preuve ontologique

**Saint Anselme**, dans le *Proslogion*, puis **Descartes** dans les
*Méditations métaphysiques*.

L''argument : j''ai en moi l''idée d''un être parfait. Or un être parfait qui
n''existerait pas serait moins parfait qu''un être parfait qui existe. L''existence
fait donc partie de la perfection. Donc l''être parfait existe.

Descartes ajoute un argument par l''origine de l''idée : moi qui suis imparfait,
je ne pouvais pas produire de moi-même l''idée de l''infini. Cette idée doit donc
venir de l''infini lui-même, qui existe.

**L''objection de Kant**, et elle est décisive. L''**existence n''est pas un
prédicat**, c''est-à-dire pas une qualité qui s''ajouterait à un concept.

Kant le montre par un exemple qu''il faut retenir : « cent thalers réels ne
contiennent rien de plus que cent thalers possibles ». Le concept des cent
thalers est le même dans ma poche et dans mon imagination ; ce qui change, c''est
que dans un cas il y a quelque chose, et dans l''autre non. L''existence ne se
déduit donc jamais d''une définition.

### La preuve cosmologique

**Saint Thomas d''Aquin**, dans la *Somme théologique*, en donne cinq versions,
dont les plus célèbres sont celle du **premier moteur** et celle de la **cause
première**.

L''argument : tout ce qui est a une cause. Mais la série des causes ne peut pas
remonter à l''infini, car alors rien n''aurait jamais commencé. Il faut donc une
cause première, qui n''est pas causée. Et cette cause, dit Thomas, « tous la
nomment Dieu ».

**Leibniz** en donne la version la plus pure avec le **principe de raison
suffisante** : rien n''est sans raison. Et la question qu''il pose est celle qui
inquiète encore : **pourquoi y a-t-il quelque chose plutôt que rien ?**

**L''objection.** Elle porte sur l''arrêt de la série. Si tout ce qui est a une
cause, Dieu aussi devrait en avoir ; si Dieu peut être sans cause, pourquoi
l''univers ne pourrait-il pas l''être ? La règle dont on part est abandonnée
exactement là où elle gênerait. On gagne un terme, on ne résout pas la question.

### La preuve par le dessein

L''argument de l''ordre du monde. Un ordre aussi réglé — les saisons, les orbites,
l''œil, la main — suppose une intelligence ordonnatrice.

**Voltaire** la résume en deux vers qu''on cite toujours : « L''univers
m''embarrasse, et je ne puis songer / que cette horloge existe et n''ait point
d''horloger. »

**L''objection : le problème du mal.** Et c''est l''objection la plus forte de tout
le chapitre.

**Épicure**, rapporté par Lactance, la pose en dilemme : si Dieu veut supprimer
le mal et ne peut pas, il n''est pas tout-puissant ; s''il peut et ne veut pas, il
n''est pas bon ; s''il peut et veut, d''où vient le mal ?

**Leibniz** répond par la **théodicée** : ce monde est le meilleur des mondes
possibles, et les maux particuliers concourent à un bien d''ensemble que nous ne
voyons pas.

**Voltaire** réplique férocement, après le tremblement de terre de Lisbonne qui
tua des milliers de fidèles un jour de fête : dans *Candide*, le « tout est
bien » devient une sottise criminelle. On ne console pas un enfant écrasé en lui
disant qu''il contribue à l''harmonie du tout.

### Les critiques de la religion elle-même

Elles ne portent plus sur les preuves mais sur l''origine de la croyance.

**Feuerbach**, dans *L''essence du christianisme* : l''homme a projeté hors de lui
sa propre essence — sa bonté, sa puissance, son savoir — et l''a appelée Dieu.
« L''homme a créé Dieu à son image. » La religion est une **aliénation** : l''homme
s''appauvrit de tout ce qu''il attribue au ciel.

**Marx** reprend et politise : « la religion est le soupir de la créature
opprimée », et elle est « l''**opium du peuple** ». Elle console d''une misère au
lieu de la supprimer, et consolide ainsi ce qui la cause. On note que la formule
est moins méprisante qu''on ne le croit : l''opium soulage réellement, et c''est
précisément son danger.

**Nietzsche**, dans *Le Gai Savoir* : « **Dieu est mort** » — ce qui n''est pas
une thèse métaphysique mais un constat historique sur une civilisation qui ne
croit plus à ses propres valeurs. Et il accuse la morale religieuse d''être une
morale de faibles, née du ressentiment contre la vie.

**Freud**, dans *L''avenir d''une illusion* : la religion est la survivance de la
détresse infantile. L''enfant impuissant a eu un père protecteur ; l''adulte,
toujours impuissant devant la nature et la mort, s''en donne un à l''échelle du
monde.

### La position de Kant, qui organise tout

Kant fait les deux choses à la fois, et c''est pourquoi il est incontournable.

Il **détruit les preuves** théoriques : Dieu n''est pas un objet d''expérience
possible, donc pas un objet de connaissance. La raison théorique n''a rien à dire
de lui.

Et il **sauve la foi** : Dieu, la liberté et l''immortalité sont des **postulats
de la raison pratique**. La morale exige que la vertu ne soit pas finalement
vaine, et cette exigence nous fait postuler ce que nous ne pouvons pas connaître.

D''où sa formule : « j''ai dû supprimer le savoir pour faire place à la foi ».
Ce qu''il retire à la science, il ne le donne pas à l''ignorance : il le rend à un
autre usage de la raison.

---

**Exercice corrigé**

*Exposer la preuve ontologique, puis l''objection de Kant selon laquelle
l''existence n''est pas un prédicat.*

**Correction.**

*La preuve.* Elle part d''une **idée** et non d''un fait, ce qui fait sa force
apparente et sa faiblesse réelle.

J''ai en moi l''idée d''un être souverainement parfait. Or l''existence est une
perfection : un être parfait qui n''existerait pas serait moins parfait qu''un
être parfait existant. Un être parfait qui n''existe pas est donc une
contradiction, comme un cercle carré. Donc l''être parfait existe.

**Saint Anselme** la formule dans le *Proslogion*, **Descartes** la reprend dans
les *Méditations métaphysiques* : l''existence appartient à l''essence de l''être
parfait comme l''égalité des trois angles appartient à l''essence du triangle.

*L''objection de Kant.* Elle attaque la seule prémisse qui compte : l''existence
est-elle une perfection, c''est-à-dire une **qualité** ?

Kant répond non. Un prédicat est ce qui **enrichit** un concept : dire d''un
cheval qu''il est noir ajoute quelque chose à l''idée de cheval. Or dire d''une
chose qu''elle **existe** n''ajoute rien à son concept : cela pose le concept
comme réalisé.

**L''exemple des cent thalers.** « Cent thalers réels ne contiennent rien de plus
que cent thalers possibles. » Si les cent thalers réels contenaient une pièce de
plus, ils ne seraient plus cent. Le concept est identique dans les deux cas ; ce
qui diffère n''est pas dans le concept, c''est qu''il y ait ou non quelque chose qui
lui corresponde.

*La conséquence.* On ne peut jamais tirer une existence d''une définition. Je puis
définir un être parfait aussi parfaitement que je veux : je resterai dans l''ordre
du concept, et il faudra sortir du concept pour trouver l''être.

*Ce que Kant en conclut, et qu''il faut mentionner pour être juste.* Il ne conclut
pas que Dieu n''existe pas : il conclut que son existence ne peut pas être
**connue**. La raison théorique est incompétente ici — et c''est pourquoi Kant
place Dieu parmi les **postulats de la raison pratique**, qu''exige la morale
sans qu''aucune démonstration ne les établisse. « J''ai dû supprimer le savoir pour
faire place à la foi. »
', NULL, 36),
      (v_chapitre_id, 'Simulation : les preuves au tribunal', 5, 'interactif', '{
  "widget": "preuves-de-dieu",
  "consigne": "Les trois preuves classiques te sont présentées étape par étape, et tu dois les accepter ou les contester à chaque pas : la prémisse tient-elle, le saut est-il permis ? La simulation te met ensuite en face de l''objection correspondante — Kant et ses cent thalers, l''arrêt arbitraire de la série, le dilemme d''Épicure — et te demande si la preuve y survit. Elle ne te dit pas s''il faut croire : elle te montre où chaque raisonnement cède, et c''est tout ce qu''une épreuve de philosophie attend de toi."
}', NULL, 10),
      (v_chapitre_id, 'La religion est-elle nécessaire à l''homme ?', 6, 'texte', '
La question change de nature : elle ne porte plus sur la vérité de la croyance,
mais sur sa **fonction**. On peut donc y répondre sans trancher la première.

### Thèse : la religion est nécessaire

**Argument 1 — elle fonde le lien social.** **Durkheim** : dans ses rites, le
groupe se rassemble et prend conscience de lui-même. Les cérémonies produisent
cette « effervescence » d''où sort le sentiment du commun. Supprimez les rites,
vous n''aurez pas un groupe plus rationnel, vous aurez un groupe moins uni.

**Argument 2 — elle donne un sens.** La science explique comment le monde
fonctionne, elle ne dit pas pourquoi il y a un monde, ni ce que vaut une vie. La
religion répond à des questions que nous ne cessons pas de poser.

**Argument 3 — elle consolerait de l''inévitable.** La mort, l''injustice, la
souffrance des innocents. **Pascal** y voit la misère de l''homme sans Dieu, et
son fameux **pari** n''est pas une preuve mais un calcul : l''enjeu est infini, le
coût est fini, donc pariez.

**Argument 4 — elle a porté des libérations.** On l''oublie souvent. Les grandes
luttes contre l''esclavage et pour les droits civiques ont été portées par des
prédicateurs ; la théologie de la libération a soutenu des opprimés en Amérique
latine ; en Afrique, **Jean-Marc Ela**, dans *Le cri de l''homme africain*
(1980), propose une « théologie sous l''arbre », au ras des villages, contre une
Église de cathédrales.

### Antithèse : elle n''est pas nécessaire, et parfois nuisible

**Argument 1 — elle est une aliénation.** **Feuerbach** : l''homme s''appauvrit de
tout ce qu''il attribue à Dieu. **Marx** : elle est l''opium du peuple, elle
soulage la douleur sans toucher à la maladie, et les dominants le savent.

**Argument 2 — elle est une illusion infantile.** **Freud** : le père protecteur
de l''enfance projeté à l''échelle du cosmos. Il souhaite une humanité adulte, qui
supporte le réel sans consolation.

**Argument 3 — elle a nourri l''intolérance.** Les guerres de religion,
l''Inquisition, les condamnations de savants, les persécutions encore présentes.
Le fait est historique et ne se discute pas.

**Argument 4, et il est spécialement important pour nous — elle a servi la
colonisation.** **Fabien Eboussi Boulaga**, dans *Christianisme sans fétiche*
(1981), montre comment l''évangélisation coloniale a présenté le christianisme
avec les habits de la culture européenne, exigeant de l''Africain qu''il renie sa
langue, ses noms et ses morts pour être sauvé. **Engelbert Mveng** parle d''une
« pauvreté anthropologique » : on n''a pas seulement pris les terres, on a enlevé
aux gens la valeur de ce qu''ils étaient.

### La synthèse

Deux distinctions permettent de sortir du face-à-face.

**Première distinction : nécessaire à quoi ?** La religion n''est pas nécessaire
à la **connaissance** — la science s''en passe et doit s''en passer. Elle a été
jusqu''ici nécessaire au **lien social** et à la **réponse au sens**, et aucune
société ne s''en est entièrement privée sans se donner des substituts qui en
reprennent les formes : fêtes nationales, monuments, grands récits.

**Seconde distinction : nécessaire ou inévitable ?** Dire que les hommes ont
toujours eu des religions n''est pas dire qu''ils doivent en avoir. Le besoin
constaté n''est pas un devoir.

Reste le point que les critiques, à force de dénoncer, ont parfois manqué : la
même religion peut opprimer et libérer, et cela ne dépend pas de son contenu mais
de l''usage qu''on en fait. Les mêmes Évangiles ont été lus par les propriétaires
d''esclaves et par les abolitionnistes.

C''est pourquoi la conclusion la plus solide n''est ni « il faut la religion » ni
« il faut en finir avec elle », mais : **la question n''est pas de savoir si la
religion est nécessaire, mais laquelle et pour quoi faire.** Eboussi Boulaga ne
demande pas à l''Africain de cesser de croire, il lui demande de croire sans le
fétiche qu''on a mis dans sa foi.

---

**Exercice corrigé**

*« La religion est l''opium du peuple » (Marx). Expliquer et discuter.*

**Correction.**

*L''explication, et il faut lire la formule plus finement qu''on ne le fait.* La
phrase complète est : « la religion est le soupir de la créature opprimée, […]
elle est l''opium du peuple ».

L''opium, au XIXe siècle, est un médicament : il **soulage réellement** la
douleur. Marx ne dit donc pas que la religion est un mensonge grossier qui
tromperait des imbéciles. Il dit qu''elle **apaise une souffrance réelle**.

Mais l''opium ne soigne pas : il endort. En rendant la misère supportable, la
religion ôte l''urgence de la supprimer. Elle reporte la justice dans un
au-delà — les derniers seront les premiers — et détourne ainsi la révolte de son
objet terrestre.

Cette critique s''appuie sur **Feuerbach** : l''homme projette hors de lui ses
propres qualités et s''appauvrit d''autant. Marx la politise : cette projection
sert objectivement ceux qui profitent de l''ordre existant.

*La discussion.*

**Premier point : la critique explique une fonction, pas une vérité.** Montrer
qu''une croyance console ne montre pas qu''elle est fausse ; un malade consolé
peut avoir une maladie réelle et un médecin véritable. Marx raisonne sur les
effets sociaux, et il faut s''en tenir à ce terrain.

**Deuxième point : les faits contredisent partiellement la thèse.** La religion
n''a pas toujours endormi. Les luttes abolitionnistes aux États-Unis, le
mouvement des droits civiques, la théologie de la libération en Amérique latine,
la « théologie sous l''arbre » de **Jean-Marc Ela** en Afrique ont tiré leur
force de la foi même. Le soupir de la créature opprimée est devenu, dans ces
cas, un cri.

**Troisième point : la critique garde sa force quand on la retourne.** Ce que
Marx décrit existe bel et bien, et **Eboussi Boulaga** le montre dans un autre
contexte : l''évangélisation coloniale a bien servi la domination, en demandant à
l''Africain de renier sa culture pour être sauvé. Le reproche de Marx vaut donc
contre un **usage** de la religion.

*La synthèse.* La formule est juste comme **diagnostic d''un usage** et fausse
comme **définition d''une essence**. La religion peut endormir et peut réveiller ;
ce qui décide n''est pas sa doctrine mais la place qu''elle occupe dans les
rapports de force.

*On peut conclure en remarquant que Marx a eu, sans le vouloir, le même destin :
sa doctrine a servi à libérer et à opprimer. Une pensée ne contrôle pas
l''usage qu''on fait d''elle — et c''est peut-être cela qu''il faut retenir des deux
côtés.*
', NULL, 32),
      (v_chapitre_id, 'Simulation : la même religion, deux usages', 7, 'interactif', '{
  "widget": "religion-deux-usages",
  "consigne": "Dix situations historiques te sont présentées — l''esclavage défendu et combattu avec les mêmes Évangiles, l''évangélisation coloniale, la théologie sous l''arbre de Jean-Marc Ela, les guerres de religion, le mouvement des droits civiques — et tu dois dire pour chacune si la religion y a servi à libérer ou à dominer. La simulation garde le compte des deux colonnes, puis te montre que plusieurs lignes citent le même texte sacré. Tu obtiens par toi-même la conclusion du cours : ce qui décide n''est pas la doctrine, c''est l''usage — et la bonne question n''est donc pas si la religion est nécessaire, mais laquelle et pour quoi faire."
}', NULL, 10),
      (v_chapitre_id, 'Sujet type Baccalauréat — Foi et raison', 8, 'texte', '
**Deuxième partie de l''épreuve — Évaluation de l''agir compétent — 9 points**

*En te fondant sur ta culture philosophique et dans le respect des règles de la
logique, est-il légitime de penser que la foi s''oppose à la raison ?*

---
---

## Corrigé

### I. Analyse et compréhension du sujet

**Les concepts-clés.** *Foi* : adhésion à ce qui n''est pas démontré, assumée
comme telle, et portant sur un objet qui dépasse l''expérience. *Raison* :
faculté de connaître par démonstration et par preuve, et de n''accepter que ce
qui est fondé. *S''opposer* : attention au mot — deux choses s''opposent soit
parce qu''elles se **contredisent**, soit parce qu''elles sont **incompatibles**,
soit simplement parce qu''elles sont **différentes**. Ces trois sens ne donnent
pas la même réponse.

**Reformulation.** Avons-nous de bonnes raisons de soutenir que croire et
raisonner s''excluent ?

**Le présupposé.** Que les deux portent sur le même objet et selon le même
mode — sans quoi elles ne pourraient pas s''opposer.

**La thèse opposée.** Foi et raison ne se rencontrent pas sur le même terrain,
ou bien se soutiennent l''une l''autre.

**Le problème.** Le rapport du croire et du savoir.

**La problématique.** La foi et la raison se disputent-elles le même territoire,
ou bien l''opposition que l''on croit constater vient-elle de ce qu''on leur demande
le même genre de réponse ?

### II. Première tâche — la thèse : elles s''opposent *(3 points)*

**Argument 1.** Elles ont des exigences contraires. La raison n''admet que ce qui
est prouvé ; la foi adhère sans preuve. **Tertullien** le dit sans ménagement :
*credo quia absurdum*, je crois parce que c''est absurde — et il assume que la
foi commence là où la raison s''arrête.

**Argument 2.** Les preuves de l''existence de Dieu échouent. **Kant** démontre
que la preuve ontologique repose sur une erreur, l''existence n''étant pas un
prédicat : « cent thalers réels ne contiennent rien de plus que cent thalers
possibles ». La preuve cosmologique abandonne sa propre règle en arrêtant
arbitrairement la série des causes. Si la raison ne peut rien établir ici, la foi
occupe un terrain qu''elle ne peut pas justifier.

**Argument 3.** Les critiques expliquent la croyance par autre chose que la
raison. **Feuerbach** : l''homme a créé Dieu à son image, et s''appauvrit de ce
qu''il lui attribue. **Marx** : elle est l''opium du peuple. **Freud**, dans
*L''avenir d''une illusion* : la religion est la survivance du père protecteur de
l''enfance. Dans les trois cas, croire a une cause, non une raison.

*Transition.* Mais la raison peut-elle légitimement juger ce qui, par
définition, excède son domaine d''expérience ?

### III. Deuxième tâche — l''antithèse : elles ne s''opposent pas *(3 points)*

**Argument 1.** Elles n''ont pas le même objet. La science répond à des questions
de **fait** ; la foi porte sur le **sens**. Aucune expérience ne démontrera que
la vie vaut d''être vécue, et ce n''est pas une faiblesse de la science : c''est sa
définition. Là où les domaines ne se recouvrent pas, il n''y a pas de conflit
possible.

**Argument 2.** La tradition elle-même les a conjuguées. **Saint Augustin** :
*crede ut intelligas*, crois pour comprendre. **Saint Anselme** : *fides quaerens
intellectum*, la foi qui cherche l''intelligence. **Saint Thomas d''Aquin** et
**Averroès**, dans deux traditions différentes, tiennent que les deux voies
mènent au même vrai et ne peuvent donc se contredire. Mille ans de théologie sont
des exercices de raisonnement.

**Argument 3.** La raison a elle-même besoin d''un acte qu''elle ne démontre pas.
**Pascal** : « le cœur a ses raisons que la raison ne connaît point » — et le
cœur, chez lui, n''est pas le sentiment mais un autre ordre de connaissance. De
son côté, **Kant** maintient Dieu comme **postulat de la raison pratique** : la
morale exige ce que la connaissance ne peut pas établir. « J''ai dû supprimer le
savoir pour faire place à la foi. »

*Transition.* Faut-il alors séparer si nettement les deux domaines que plus
aucune croyance ne puisse être critiquée ?

### IV. Troisième tâche — la synthèse *(3 points)*

**Premier moment — distinguer les trois sens de « s''opposer ».** Foi et raison
sont **différentes** : l''une démontre, l''autre adhère. Elles ne sont pas
nécessairement **incompatibles** : un savant peut croire, et l''histoire en est
pleine. Elles ne se **contredisent** que lorsqu''elles prétendent au même office —
quand la foi veut trancher une question de fait, ou quand la raison veut trancher
une question de sens.

**Deuxième moment — les deux excès symétriques.** Le **fondamentalisme** fait de
la foi une physique, et il perd les deux : il expose la croyance à être réfutée
par une mesure. Le **scientisme** fait de la science une morale, et il perd aussi
les deux : les doctrines qui ont prétendu fonder scientifiquement une politique
ont justifié le pire. Chaque excès détruit ce qu''il voulait défendre.

**Troisième moment — un enjeu qui nous concerne directement.** **Eboussi
Boulaga**, dans *Christianisme sans fétiche*, montre que la foi apportée par la
colonisation exigeait de l''Africain qu''il renie sa langue et ses morts pour être
sauvé : c''était une foi qui refusait l''examen. Demander à une croyance de rendre
des comptes sur ce qu''elle exige n''est pas la détruire, c''est la **purifier** —
et c''est exactement ce que la raison peut faire pour la foi.

**Conclusion.** Il n''est pas légitime de penser que la foi s''oppose à la raison,
si l''on entend par là qu''elles se contredisent : elles ne répondent pas aux mêmes
questions. Il est légitime de les distinguer fermement, et c''est cette distinction
même qui les protège l''une de l''autre. La raison n''a pas à démontrer Dieu, ni la
foi à expliquer la chute des corps ; mais la raison a bien à examiner ce qu''une
foi réclame des hommes, et aucune foi vivante n''a jamais eu à craindre cet
examen.

---

### Ce que le correcteur attend

**Les trois sens de « s''opposer » dégagés.** C''est là que se gagne la synthèse,
et c''est ce que presque aucune copie ne fait.

**Kant des deux côtés.** Il détruit les preuves en thèse et sauve la foi en
antithèse : c''est le même auteur, et le montrer prouve qu''on l''a compris.

**Au moins un auteur africain** — Eboussi Boulaga, Mveng ou Ela — traité
philosophiquement. Le programme camerounais y tient.
', NULL, 34),
      (v_chapitre_id, 'Quiz du chapitre 12', 9, 'quiz', '{
  "titre": "Vérifie que tu as compris",
  "questions": [
    {
      "question": "Comment Durkheim définit-il la religion ?",
      "choix": [
        "Comme la croyance en Dieu",
        "Comme un système solidaire de croyances et de pratiques relatives à des choses sacrées, qui unit une communauté morale",
        "Comme l''opium du peuple",
        "Comme une illusion infantile"
      ],
      "bonne": 1,
      "explication": "Trois éléments : croyances, pratiques, communauté. Les deux autres formules sont de Marx et de Freud."
    },
    {
      "question": "Qu''est-ce qui rend une chose sacrée selon Durkheim ?",
      "choix": [
        "Sa nature",
        "Sa séparation : le sacré est ce qui est mis à part et interdit, et rien n''est sacré par nature",
        "Son ancienneté",
        "Son origine divine"
      ],
      "bonne": 1,
      "explication": "Une pierre, un arbre, un livre, un jour peuvent l''être ou non. C''est pourquoi la profanation est si grave : elle n''abîme pas l''objet, elle abolit la séparation."
    },
    {
      "question": "Quelle est la différence entre le théisme et le déisme ?",
      "choix": [
        "Aucune",
        "Le théisme affirme un Dieu personnel qui intervient dans le monde ; le déisme un Dieu créateur qui n''intervient pas et n''exige pas de culte",
        "Le déisme nie Dieu",
        "Le théisme est agnostique"
      ],
      "bonne": 1,
      "explication": "Voltaire est déiste, non chrétien. Et l''agnosticisme n''est pas un athéisme timide : c''est une thèse sur les limites de la connaissance."
    },
    {
      "question": "Comment Kant réfute-t-il la preuve ontologique ?",
      "choix": [
        "En niant Dieu",
        "En montrant que l''existence n''est pas un prédicat : « cent thalers réels ne contiennent rien de plus que cent thalers possibles »",
        "En invoquant le problème du mal",
        "En citant Feuerbach"
      ],
      "bonne": 1,
      "explication": "On ne tire jamais une existence d''une définition. Mais Kant ne conclut pas que Dieu n''existe pas : il le place parmi les postulats de la raison pratique."
    },
    {
      "question": "Quel est le dilemme d''Épicure sur le problème du mal ?",
      "choix": [
        "Dieu existe ou non",
        "Si Dieu veut supprimer le mal et ne peut pas, il n''est pas tout-puissant ; s''il peut et ne veut pas, il n''est pas bon ; s''il peut et veut, d''où vient le mal ?",
        "Le mal est une illusion",
        "Le mal vient des hommes"
      ],
      "bonne": 1,
      "explication": "Leibniz répond par la théodicée — le meilleur des mondes possibles. Voltaire réplique dans Candide, après le tremblement de terre de Lisbonne."
    },
    {
      "question": "Que soutient Feuerbach dans L''essence du christianisme ?",
      "choix": [
        "Que Dieu est mort",
        "Que l''homme a projeté hors de lui sa propre essence et l''a appelée Dieu : « l''homme a créé Dieu à son image »",
        "Que la religion est une névrose",
        "Que la religion unit la société"
      ],
      "bonne": 1,
      "explication": "C''est la thèse de l''aliénation religieuse : l''homme s''appauvrit de tout ce qu''il attribue au ciel. Marx la reprend et la politise."
    },
    {
      "question": "Que reproche Eboussi Boulaga à l''évangélisation coloniale dans Christianisme sans fétiche ?",
      "choix": [
        "D''avoir converti trop peu de gens",
        "D''avoir présenté le christianisme dans les habits de la culture européenne, exigeant de l''Africain qu''il renie sa langue, ses noms et ses morts pour être sauvé",
        "D''avoir ignoré les Évangiles",
        "D''avoir favorisé l''islam"
      ],
      "bonne": 1,
      "explication": "Mveng parle d''une « pauvreté anthropologique » : on n''a pas seulement pris les terres, on a enlevé aux gens la valeur de ce qu''ils étaient."
    }
  ]
}', NULL, 5);

    RAISE NOTICE '% : 9 leçons ajoutées au chapitre 12, Dieu et la religion.', v_nom;
  END LOOP;
END $philo$;
