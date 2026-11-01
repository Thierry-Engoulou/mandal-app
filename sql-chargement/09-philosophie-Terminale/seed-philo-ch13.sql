-- ---------------------------------------------------------------------------
-- M'Andal — Philosophie, classes de Terminale
-- Chapitre 13 : La logique
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
    WHERE programme_id = v_programme_id AND ordre = 13;

    IF v_chapitre_id IS NULL THEN
      INSERT INTO public.chapitres (programme_id, titre, ordre, niveau)
      VALUES (v_programme_id, 'La logique', 13, 'Module 1 : La philosophie')
      RETURNING id INTO v_chapitre_id;
      RAISE NOTICE '% : chapitre 13 créé.', v_nom;
    END IF;

    -- Les leçons. Si le chapitre en a déjà, on passe son tour sans rien toucher.
    SELECT count(*) INTO v_deja FROM public.concepts WHERE chapitre_id = v_chapitre_id;
    IF v_deja > 0 THEN
      RAISE NOTICE '% : le chapitre 13 a déjà ses % leçons, je n''y touche pas.', v_nom, v_deja;
      CONTINUE;
    END IF;

    INSERT INTO public.concepts
      (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes) VALUES
      (v_chapitre_id, 'La logique : vérité et validité', 1, 'texte', '
Dernier chapitre du programme, et le plus utile de tous pour l''épreuve. Rappelez-
vous le libellé de chaque sujet : « **dans le respect des règles de la
logique** ». Ces règles, les voici.

### Qu''est-ce que la logique ?

La **logique** est la science des **conditions formelles** de la validité du
raisonnement. Du grec *logos*, parole et raison.

**Aristote** en est le fondateur, dans l''ensemble de traités qu''on a nommé
l''*Organon* — l''instrument. Il n''a pas inventé le raisonnement correct, bien
sûr : il a été le premier à en dégager les **formes**, indépendamment de ce dont
on parle.

On distingue la **logique naturelle**, celle que tout le monde pratique sans
l''avoir apprise, et la **logique formelle**, qui en explicite les règles. La
seconde ne remplace pas la première : elle la corrige quand elle se trompe.

### La distinction capitale : vérité et validité

Si vous ne retenez qu''une chose de ce chapitre, retenez celle-ci.

La **vérité** est une propriété des **propositions** : une proposition est vraie
quand elle est conforme à ce qui est.

La **validité** est une propriété des **raisonnements** : un raisonnement est
valide quand sa conclusion découle nécessairement de ses prémisses.

Ce sont deux choses indépendantes, et les quatre combinaisons existent.

**Valide et vrai.** Tous les hommes sont mortels ; Socrate est un homme ; donc
Socrate est mortel. Rien à redire.

**Valide mais conclusion fausse.** Tous les oiseaux sont rouges ; le corbeau est
un oiseau ; donc le corbeau est rouge. La **forme** est irréprochable ; c''est la
première prémisse qui est fausse. La logique n''a rien à y voir.

**Invalide et conclusion fausse.** Tous les chats sont mortels ; Socrate est
mortel ; donc Socrate est un chat. Les prémisses sont vraies, la conclusion est
absurde, et la faute est dans la **forme**.

**Invalide mais conclusion vraie.** Tous les chats sont mortels ; Socrate est
mortel ; donc Socrate est mortel. La conclusion est vraie, mais le raisonnement
ne l''a pas établie : elle est vraie par accident.

Ce que la validité garantit, c''est donc exactement ceci : **si les prémisses
sont vraies, alors la conclusion l''est aussi.** Rien de plus. Un raisonnement
valide à partir de prémisses fausses conclut n''importe quoi, et c''est pourquoi
la logique ne dispense jamais de vérifier les faits.

### Les quatre principes logiques

**Le principe d''identité.** Une chose est ce qu''elle est : A est A. Il paraît
vide, et il interdit pourtant la faute la plus commune : changer en route le sens
d''un mot.

**Le principe de non-contradiction.** On ne peut pas affirmer et nier la même
chose, du même sujet, sous le même rapport, au même moment. **Aristote** le
tient pour le premier de tous : on ne peut pas même le discuter sans s''en servir.

**Le principe du tiers exclu.** De deux propositions contradictoires, l''une est
vraie et l''autre fausse ; il n''y a pas de troisième possibilité.

**Le principe de raison suffisante.** **Leibniz** : rien n''est sans raison. Ce
n''est pas une règle de forme mais une exigence de la pensée, et c''est elle qui
interdit de s''arrêter à « c''est comme ça ».

---

**Exercice corrigé**

*Distinguer la vérité et la validité. Donner un exemple de raisonnement valide à
conclusion fausse, et un exemple de raisonnement invalide à conclusion vraie.
Que faut-il en conclure sur l''usage de la logique ?*

**Correction.**

*Les définitions.* La **vérité** qualifie une proposition : elle est vraie si
elle est conforme à ce qui est. La **validité** qualifie un raisonnement : il est
valide si sa conclusion découle nécessairement de ses prémisses.

La vérité se vérifie en regardant le monde ; la validité s''examine en regardant
la forme, sans rien savoir du monde.

*Premier exemple — valide, conclusion fausse.*

Tous les métaux flottent sur l''eau. Le fer est un métal. Donc le fer flotte sur
l''eau.

La forme est parfaite : c''est le même enchaînement que celui de Socrate mortel.
La conclusion est fausse parce que la première prémisse est fausse. **La logique
a fait son travail ; c''est l''information qui manquait.**

*Second exemple — invalide, conclusion vraie.*

Tous les Camerounais sont africains. Les Sénégalais sont africains. Donc les
Sénégalais sont camerounais... Prenons plutôt un cas à conclusion vraie :

Tous les hommes sont mortels. Les chats sont mortels. Donc les chats sont
mortels.

La conclusion est vraie, mais elle ne vient pas du raisonnement : elle a été
posée dans la deuxième prémisse, et le raisonnement n''a rien ajouté. On parle
alors de **pétition de principe** : on a supposé ce qu''on voulait établir.

*Ce qu''il faut en conclure.* Deux choses.

**La logique est nécessaire mais non suffisante.** Elle garantit le passage des
prémisses à la conclusion ; elle ne garantit pas les prémisses. Un raisonnement
impeccable à partir d''informations fausses mène tranquillement à l''erreur, et
c''est souvent ainsi que les erreurs voyagent : bien habillées.

**Une conclusion vraie ne prouve pas un bon raisonnement.** C''est contre-
intuitif, et pourtant décisif au Baccalauréat : le correcteur n''évalue pas
seulement ce que vous concluez, il évalue **comment** vous y arrivez. Une bonne
conclusion mal démontrée vaut peu de points ; c''est la démarche qui est notée.
', NULL, 30),
      (v_chapitre_id, 'Figure : vérité et validité', 2, 'figure', '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 580 330" width="580" height="330">
<rect width="580" height="330" fill="#ffffff"/>
<text x="290" y="24" text-anchor="middle" font-size="14" font-weight="700" fill="#0f172a">Vérité et validité : deux choses différentes</text>
<text x="290" y="42" text-anchor="middle" font-size="10" fill="#64748b">la logique juge la forme, pas le contenu</text>

<rect x="22" y="58" width="258" height="112" rx="6" fill="#dcfce7" stroke="#15803d" stroke-width="1.6"/>
<text x="151" y="78" text-anchor="middle" font-size="10" font-weight="700" fill="#14532d">VALIDE et VRAI</text>
<line x1="34" y1="86" x2="268" y2="86" stroke="#86efac"/>
<text x="34" y="104" font-size="9" fill="#166534">Tous les hommes sont mortels.</text>
<text x="34" y="120" font-size="9" fill="#166534">Socrate est un homme.</text>
<text x="34" y="138" font-size="9" font-weight="700" fill="#14532d">Donc Socrate est mortel.</text>
<text x="151" y="160" text-anchor="middle" font-size="8" font-style="italic" fill="#475569">forme correcte, prémisses vraies</text>

<rect x="300" y="58" width="258" height="112" rx="6" fill="#fef3c7" stroke="#ca8a04" stroke-width="1.6"/>
<text x="429" y="78" text-anchor="middle" font-size="10" font-weight="700" fill="#78350f">VALIDE mais FAUX</text>
<line x1="312" y1="86" x2="546" y2="86" stroke="#fde047"/>
<text x="312" y="104" font-size="9" fill="#92400e">Tous les oiseaux sont rouges.</text>
<text x="312" y="120" font-size="9" fill="#92400e">Le corbeau est un oiseau.</text>
<text x="312" y="138" font-size="9" font-weight="700" fill="#78350f">Donc le corbeau est rouge.</text>
<text x="429" y="160" text-anchor="middle" font-size="8" font-style="italic" fill="#475569">forme correcte, prémisse fausse</text>

<rect x="22" y="182" width="258" height="112" rx="6" fill="#fee2e2" stroke="#b91c1c" stroke-width="1.6"/>
<text x="151" y="202" text-anchor="middle" font-size="10" font-weight="700" fill="#7f1d1d">INVALIDE mais VRAI</text>
<line x1="34" y1="210" x2="268" y2="210" stroke="#fca5a5"/>
<text x="34" y="228" font-size="9" fill="#991b1b">Tous les chats sont mortels.</text>
<text x="34" y="244" font-size="9" fill="#991b1b">Socrate est mortel.</text>
<text x="34" y="262" font-size="9" font-weight="700" fill="#7f1d1d">Donc Socrate est un chat.</text>
<text x="151" y="284" text-anchor="middle" font-size="8" font-style="italic" fill="#475569">conclusion fausse, forme fautive</text>

<rect x="300" y="182" width="258" height="112" rx="6" fill="#f1f5f9" stroke="#475569" stroke-width="1.6"/>
<text x="429" y="202" text-anchor="middle" font-size="10" font-weight="700" fill="#0f172a">LA LEÇON</text>
<line x1="312" y1="210" x2="546" y2="210" stroke="#cbd5e1"/>
<text x="312" y="228" font-size="9" fill="#334155">Un raisonnement valide ne</text>
<text x="312" y="242" font-size="9" fill="#334155">garantit pas une conclusion</text>
<text x="312" y="256" font-size="9" fill="#334155">vraie : il garantit que SI les</text>
<text x="312" y="270" font-size="9" fill="#334155">prémisses sont vraies, la</text>
<text x="312" y="284" font-size="9" fill="#334155">conclusion l&apos;est aussi.</text>

<text x="290" y="318" text-anchor="middle" font-size="10" font-weight="700" fill="#7f1d1d">Au Baccalauréat, le correcteur juge votre forme. Un argument faux dans une forme correcte se voit.</text>
</svg>', NULL, 5),
      (v_chapitre_id, 'Simulation : vrai, valide, ou ni l''un ni l''autre ?', 3, 'interactif', '{
  "widget": "verite-validite",
  "consigne": "Seize raisonnements défilent, et tu dois répondre à deux questions indépendantes pour chacun : les prémisses sont-elles vraies, et la forme est-elle valide ? Les quatre combinaisons sont représentées, y compris la plus déroutante — une conclusion vraie obtenue par un raisonnement fautif. La simulation te signale à chaque fois ce que le correcteur verrait, et te montre pourquoi une bonne conclusion mal démontrée rapporte peu de points."
}', NULL, 10),
      (v_chapitre_id, 'Le syllogisme et les formes du raisonnement', 4, 'texte', '
Les outils maintenant. Vous les utilisez déjà sans les nommer ; les nommer
permet de repérer vos fautes.

### Les quatre types de propositions

Toute proposition de la logique classique se ramène à l''une de ces quatre
formes, qu''on désigne par des lettres.

**A — universelle affirmative.** « Tous les S sont P. »

**E — universelle négative.** « Aucun S n''est P. »

**I — particulière affirmative.** « Quelques S sont P. »

**O — particulière négative.** « Quelques S ne sont pas P. »

Les rapports entre elles forment le **carré logique**. Retenez-en l''essentiel :

**A et O sont contradictoires**, de même que **E et I**. Si l''une est vraie,
l''autre est nécessairement fausse, et réciproquement.

**A et E sont contraires** : elles ne peuvent pas être vraies ensemble, mais
elles peuvent être fausses ensemble — « tous les élèves sont présents » et
« aucun élève n''est présent » sont toutes deux fausses si la moitié est là.

La conséquence pratique est une règle d''or pour vos dissertations : **pour
réfuter une affirmation universelle, un seul contre-exemple suffit.** Et
réciproquement, si l''on vous objecte un contre-exemple, votre thèse universelle
est morte ; il faut la rendre particulière.

### Le syllogisme

C''est le raisonnement déductif de base, formalisé par **Aristote** : deux
prémisses, une conclusion, trois termes.

> Tous les hommes sont mortels. *(la majeure)*
> Socrate est un homme. *(la mineure)*
> Donc Socrate est mortel. *(la conclusion)*

Les **trois termes** : le **moyen terme** est celui qui figure dans les deux
prémisses et disparaît de la conclusion — ici « homme ». Le **grand terme** est
le prédicat de la conclusion — « mortel ». Le **petit terme** en est le sujet —
« Socrate ».

Le moyen terme est la charnière : c''est par lui que les deux autres se
rencontrent, et c''est lui qui doit disparaître à la fin. Un syllogisme dont le
moyen terme reste dans la conclusion n''a rien conclu.

### Les règles à connaître

**Le moyen terme doit être pris universellement au moins une fois.** Sinon, les
deux prémisses peuvent parler de deux parties différentes du même ensemble, et
ne se rejoignent pas. C''est la faute du raisonnement sur Socrate et les chats.

**D''au moins une prémisse universelle, sinon rien ne suit.** De « quelques
élèves sont studieux » et « quelques élèves sont bavards », on ne tire rien.

**De deux prémisses négatives, rien ne suit non plus.**

**La conclusion suit la prémisse la plus faible** : si une prémisse est
particulière, la conclusion l''est ; si une est négative, la conclusion l''est.

### Les autres formes de raisonnement

**La déduction** va du général au particulier, et elle est **nécessaire** : si
les prémisses sont vraies, la conclusion ne peut pas être fausse.

**L''induction** va du particulier au général, et elle est **probable** : mille
corbeaux noirs ne garantissent pas le mille-et-unième. C''est le problème que
**Hume** a posé et que **Popper** a contourné par la falsifiabilité.

**L''analogie** raisonne par ressemblance : A est à B ce que C est à D. Elle est
féconde pour trouver et faible pour prouver. La comparaison de l''État avec un
corps vivant a éclairé bien des pages et justifié bien des abus.

**Le raisonnement par l''absurde** suppose vraie la thèse adverse et en tire une
conséquence impossible ; la thèse adverse est donc fausse. C''est un excellent
outil pour vos antithèses.

**Le raisonnement a fortiori** : à plus forte raison. Si l''on ne doit pas
mentir à un étranger, à plus forte raison pas à un ami.

**Le modus ponens.** Si A alors B ; or A ; donc B. **Valide.**

**Le modus tollens.** Si A alors B ; or non-B ; donc non-A. **Valide**, et c''est
la forme même de la réfutation chez Popper.

Et les deux **pièges** qui ressemblent aux précédents sans l''être :

**L''affirmation du conséquent.** Si A alors B ; or B ; donc A. **Invalide.**
S''il pleut, la route est mouillée ; la route est mouillée ; donc il a plu — non :
un camion-citerne est passé.

**La négation de l''antécédent.** Si A alors B ; or non-A ; donc non-B.
**Invalide.** S''il pleut, la route est mouillée ; il ne pleut pas ; donc la route
est sèche — non, même camion.

---

**Exercice corrigé**

*Analyser le raisonnement suivant : « Tous les chats sont mortels. Socrate est
mortel. Donc Socrate est un chat. » Nommer la faute, puis montrer par le modus
tollens comment on réfute correctement une thèse.*

**Correction.**

*L''analyse.* Les prémisses sont toutes deux **vraies**. La conclusion est
**fausse**. La faute est donc dans la **forme**, et nulle part ailleurs.

*Identifions les termes.* Le moyen terme est « mortel », puisqu''il figure dans
les deux prémisses et non dans la conclusion. Le grand terme est « chat », le
petit « Socrate ».

*La faute.* Le moyen terme « mortel » n''est pris **universellement** dans aucune
des deux prémisses.

« Tous les chats sont mortels » ne dit rien de **tous** les mortels : elle dit
que les chats sont **parmi** les mortels. « Socrate est mortel » place Socrate
lui aussi parmi les mortels. Les deux prémisses situent donc chats et Socrate
dans le même grand ensemble, sans jamais dire qu''ils occupent la même partie de
cet ensemble.

C''est la violation de la règle : **le moyen terme doit être pris universellement
au moins une fois.** La faute s''appelle le **moyen terme non distribué**.

On la reconnaît à vue : la forme « tous les A sont C ; B est C ; donc B est A »
est toujours invalide, quoi qu''on mette dans A, B et C. Elle est très fréquente
dans les copies et dans les débats, parce qu''elle a l''air d''un syllogisme.

*La réfutation correcte, par le modus tollens.*

La forme valide est : **si A alors B ; or non-B ; donc non-A.**

Appliquons-la. Supposons la thèse : « si l''âme est immortelle, alors elle ne
dépend pas du corps ». Montrons que l''âme dépend du corps — par les effets d''une
lésion, d''une fièvre, d''un vieillissement. Nous obtenons non-B, et nous concluons
non-A : l''âme n''est pas immortelle en ce sens.

Que le contenu soit discutable n''importe pas ici : la **forme** est correcte, et
c''est elle qui rend la réfutation recevable.

*Et c''est exactement ce que fait Popper en épistémologie : une théorie n''est
jamais vérifiée, elle est réfutée par un modus tollens — si la théorie est vraie,
on doit observer ceci ; on ne l''observe pas ; donc la théorie est fausse.*
', NULL, 34),
      (v_chapitre_id, 'Simulation : l''atelier du syllogisme', 5, 'interactif', '{
  "widget": "atelier-syllogisme",
  "consigne": "Tu construis tes propres syllogismes en choisissant deux prémisses dans une banque de propositions, et la simulation vérifie la forme règle par règle : le moyen terme est-il pris universellement ? reste-t-il une prémisse universelle ? la conclusion suit-elle la prémisse la plus faible ? Un diagramme à trois cercles te montre pourquoi ça passe ou pourquoi ça casse. Les six formes invalides classiques t''attendent, modus ponens et modus tollens compris, avec leurs deux imitations trompeuses."
}', NULL, 10),
      (v_chapitre_id, 'Les sophismes, ou comment les raisonnements trichent', 6, 'texte', '
C''est la partie la plus immédiatement rentable du chapitre : elle vous sert dans
vos copies, dans vos lectures, et dans tout débat public.

### Sophisme et paralogisme

Un **paralogisme** est un raisonnement faux commis **de bonne foi**, par erreur.

Un **sophisme** est le même raisonnement faux employé **volontairement**, pour
convaincre malgré tout.

La différence est dans l''intention, pas dans la forme. Les **sophistes**, dans
l''Athènes du Ve siècle avant notre ère, enseignaient l''art de convaincre
indépendamment du vrai ; **Platon** leur oppose Socrate, qui cherche le vrai
indépendamment de l''effet produit. La querelle n''est pas close.

### Les sophismes qui portent sur la structure

**La pétition de principe**, ou cercle vicieux. On suppose dans les prémisses ce
qu''on veut démontrer. « Ce livre dit vrai, car il est inspiré ; il est inspiré,
car il le dit lui-même. » C''est la faute la plus fréquente dans les copies de
philosophie, et la plus difficile à voir dans ses propres phrases.

**La généralisation hâtive.** Conclure du particulier à l''universel sur quelques
cas. « Deux commerçants m''ont trompé, donc les commerçants sont malhonnêtes. »

**Le faux dilemme.** Réduire à deux options ce qui en comporte davantage. « Ou
bien on accepte ce projet, ou bien on reste dans la misère. » Le remède est de
chercher la troisième voie que le dilemme cache.

**La pente glissante.** Enchaîner des conséquences de plus en plus graves sans
établir aucun des maillons. « Si on autorise ceci, bientôt plus rien ne sera
interdit. »

**Post hoc ergo propter hoc** — après cela, donc à cause de cela. Confondre la
**succession** avec la **causalité**. « J''ai porté cette chemise et j''ai réussi
mon examen. » C''est la racine de la plupart des superstitions, et aussi de bien
des erreurs savantes : une corrélation n''est pas une cause.

### Les sophismes qui détournent le sujet

**L''argument ad hominem.** Attaquer la personne au lieu de sa thèse. « Tu ne peux
rien dire de la pauvreté, tu es riche. » Un riche peut dire le vrai sur la
pauvreté ; l''origine d''un énoncé ne décide pas de sa valeur.

**L''homme de paille.** Déformer la thèse adverse pour la rendre absurde, et
réfuter ensuite cette déformation. On la reconnaît à ceci : l''adversaire ne se
reconnaît pas dans ce qu''on lui prête. C''est pourquoi une bonne antithèse de
dissertation présente la thèse adverse **sous sa forme la plus forte**.

**L''appel à l''autorité.** « C''est vrai parce qu''un grand auteur l''a dit. »
Attention, nuance utile en philosophie : citer un auteur pour **exposer** une
thèse est nécessaire, et c''est même attendu de vous. Le sophisme commence quand
la citation **remplace** l''argument. Un nom n''est pas une preuve.

**L''appel à la majorité** — *ad populum*. « Tout le monde le croit, donc c''est
vrai. » Tout le monde a cru la Terre immobile.

**L''appel à l''ignorance.** « On n''a pas prouvé que c''était faux, donc c''est
vrai. » L''absence de preuve contre n''est pas une preuve pour.

**L''appel à la tradition ou à la nouveauté.** « On a toujours fait ainsi »,
« c''est dépassé ». Ni l''ancienneté ni la nouveauté ne sont des raisons.

**L''équivoque.** Changer en route le sens d''un mot. « L''homme est libre ; or le
prisonnier n''est pas libre ; donc le prisonnier n''est pas un homme. » Le mot
« libre » n''a pas le même sens dans les deux prémisses, et c''est le principe
d''identité qui est violé.

### Les limites de la logique

Pour finir honnêtement, il faut dire ce que la logique ne fait pas.

**Elle ne fournit pas les prémisses.** Elle garantit un passage ; elle ne donne
aucune information sur le monde. Un raisonnement impeccable sur des données
fausses reste impeccable et faux.

**Elle ne décide pas des valeurs.** Aucune règle formelle ne dit s''il faut
préférer la liberté à la sécurité.

**Elle ne suffit pas à comprendre.** **Pascal** distingue l''esprit de
**géométrie**, qui déduit à partir de définitions claires, et l''esprit de
**finesse**, qui saisit des ensembles dont les principes « ne se peuvent pas
voir ». Les affaires humaines demandent le second autant que le premier.

**Et elle a rencontré sa limite en elle-même.** **Kurt Gödel** a démontré en
1931 que dans tout système formel suffisamment riche et non contradictoire, il
existe des énoncés vrais qu''on ne peut pas y démontrer. Autrement dit, même en
mathématiques, la démonstration ne couvre pas la vérité.

Cela ne discrédite pas la logique : cela la situe. Elle est l''instrument le plus
sûr que nous ayons, et elle ne remplace ni l''information, ni le jugement, ni la
décision.

---

**Exercice corrigé**

*Identifier et nommer la faute dans chacun des cinq raisonnements suivants.*

*1. « Les étrangers sont malhonnêtes : j''en ai rencontré deux qui m''ont
trompé. »*
*2. « Ce traité est vrai, car son auteur ne se trompe jamais ; et il ne se trompe
jamais, puisque ses traités sont vrais. »*
*3. « Tu défends les pauvres ? Tu es toi-même pauvre, ton avis ne compte pas. »*
*4. « Depuis qu''on a installé cette antenne, les gens tombent malades : il faut
la retirer. »*
*5. « Ou bien tu acceptes cette réforme, ou bien tu veux la ruine du pays. »*

**Correction.**

*1. Généralisation hâtive.* On conclut d''un universel — « les étrangers » — à
partir de deux cas. Deux cas ne constituent pas un échantillon, et le carré
logique nous apprend qu''un seul contre-exemple suffirait à renverser la
conclusion. **Correction :** « deux étrangers m''ont trompé », qui est une
particulière et n''engage rien d''autre.

*2. Pétition de principe*, ou cercle vicieux. La première proposition s''appuie
sur la seconde, qui s''appuie sur la première. Rien n''est établi : on tourne.
**Correction :** il faudrait un critère **extérieur** aux deux propositions —
une vérification indépendante.

*3. Argument ad hominem.* On attaque la situation de la personne au lieu
d''examiner sa thèse. Or l''origine d''un énoncé ne décide pas de sa valeur : un
pauvre peut dire le vrai sur la pauvreté, un riche aussi. **Correction :**
examiner ce qu''il affirme, et le réfuter s''il a tort.

*4. Post hoc ergo propter hoc.* On confond la succession avec la causalité. Deux
faits simultanés n''ont pas pour autant de lien. **Correction :** établir un
mécanisme et comparer avec un groupe témoin — des gens sans antenne — avant de
conclure quoi que ce soit.

*5. Faux dilemme.* Deux options sont présentées comme exhaustives, alors qu''il en
existe d''autres : amender la réforme, en différer une partie, en proposer une
autre. **Correction :** montrer la troisième voie, ce qui suffit à défaire le
dilemme.

*Remarque pour l''épreuve : ces cinq fautes sont celles qui coûtent le plus de
points dans les copies, et la pétition de principe arrive en tête. Relisez
toujours votre antithèse en vous demandant si l''adversaire se reconnaîtrait dans
ce que vous lui faites dire.*
', NULL, 32),
      (v_chapitre_id, 'Simulation : le détecteur de sophismes', 7, 'interactif', '{
  "widget": "detecteur-sophismes",
  "consigne": "Vingt arguments tirés de débats ordinaires te sont soumis — « tout le monde le fait », « on n''a jamais prouvé le contraire », « depuis qu''on a changé la loi, tout va mal », « tu ne peux rien dire, tu es concerné », « ou bien ceci ou bien la ruine » — et tu dois nommer la faute parmi les douze du cours. La simulation te donne pour chacune la correction : non pas la réponse opposée, mais la façon de refaire l''argument honnêtement. Un dernier lot t''attend, le plus difficile : cinq arguments parfaitement valides, qu''il faut laisser passer sans y chercher un piège."
}', NULL, 10),
      (v_chapitre_id, 'Sujet type Baccalauréat — La logique suffit-elle à bien penser ?', 8, 'texte', '
**Deuxième partie de l''épreuve — Évaluation de l''agir compétent — 9 points**

*En te fondant sur ta culture philosophique et dans le respect des règles de la
logique, est-il légitime de penser que la logique suffit à bien penser ?*

---
---

## Corrigé

### I. Analyse et compréhension du sujet

**Les concepts-clés.** *Logique* : science des conditions formelles de la
validité du raisonnement. *Suffire* : être à soi seul la condition complète —
il faut la distinguer de « être nécessaire ». *Bien penser* : ce n''est pas
seulement raisonner sans faute, c''est aussi partir du vrai et aboutir à ce qui
importe.

**Reformulation.** Avons-nous de bonnes raisons de soutenir que la correction
formelle du raisonnement est à elle seule la condition d''une pensée juste ?

**Le présupposé.** Que bien penser se réduise à bien enchaîner.

**La thèse opposée.** La logique est nécessaire et insuffisante.

**Le problème.** Les conditions d''une pensée juste.

**La problématique.** La rigueur formelle garantit-elle la justesse de la pensée,
ou peut-on se tromper parfaitement, c''est-à-dire sans aucune faute de
raisonnement ?

### II. Première tâche — la thèse : la logique suffit *(3 points)*

**Argument 1.** Sans elle, tout s''écroule. **Aristote** le montre à propos du
principe de non-contradiction : on ne peut pas même le contester sans s''en
servir. Celui qui s''autorise la contradiction peut tout démontrer, donc rien.

**Argument 2.** Elle est le seul juge impartial du raisonnement. Elle examine la
**forme** sans rien devoir au contenu, ce qui la met à l''abri des préjugés : la
validité d''un syllogisme ne dépend ni de celui qui parle ni de ce dont il parle.
C''est pourquoi les sujets du Baccalauréat exigent qu''on raisonne « dans le
respect des règles de la logique ».

**Argument 3.** Elle démasque les tricheries. Pétition de principe, homme de
paille, faux dilemme, confusion de la succession et de la cause : ce sont les
règles formelles qui permettent de les nommer, et donc de leur résister.

*Transition.* Mais un raisonnement impeccable ne peut-il pas conduire
tranquillement à l''erreur ?

### III. Deuxième tâche — l''antithèse : elle ne suffit pas *(3 points)*

**Argument 1, et il est décisif.** La logique **ne fournit pas les prémisses**.
« Tous les métaux flottent ; le fer est un métal ; donc le fer flotte » : la
forme est irréprochable et la conclusion fausse. Un raisonnement valide ne
garantit que ceci — si les prémisses sont vraies, la conclusion l''est. Il
faut donc, hors de la logique, savoir si elles le sont : c''est l''affaire de
l''observation et de la méthode expérimentale de **Claude Bernard**.

**Argument 2.** Elle ne décide pas des valeurs. Aucune règle formelle ne dit
s''il faut préférer la sécurité à la liberté. Le juste et le bien ne se déduisent
pas, et **Kant** doit recourir à un impératif que nulle démonstration n''établit.

**Argument 3.** Elle ne suffit pas à comprendre les choses humaines. **Pascal**
distingue l''esprit de **géométrie**, qui déduit de définitions claires, et
l''esprit de **finesse**, qui saisit des ensembles dont les principes « ne se
peuvent pas voir ». Qui n''a que le premier raisonne juste sur ce qui ne compte
pas. **Bergson** ajoute que l''intelligence, qui découpe et mesure, manque la
durée vécue.

**Argument 4.** Elle a rencontré sa limite en elle-même. **Gödel** a démontré en
1931 que dans tout système formel suffisamment riche et non contradictoire, il
existe des énoncés vrais qu''on ne peut pas y démontrer. La démonstration ne
couvre donc pas la vérité, même en mathématiques.

*Transition.* Faut-il alors tenir la logique pour un ornement, et s''en remettre
à l''intuition ?

### IV. Troisième tâche — la synthèse *(3 points)*

**Premier moment — le sujet confond nécessaire et suffisant.** La logique est
**nécessaire** : sans elle, aucune pensée ne tient, et les sophismes passent. Elle
n''est pas **suffisante** : elle garantit un passage, non un point de départ.
Celui qui raisonne bien à partir du faux se trompe avec méthode, et c''est ainsi
que les erreurs les plus durables ont voyagé — bien habillées.

**Deuxième moment — bien penser suppose trois choses, et la logique n''en est
qu''une.** Des **prémisses vraies**, que l''observation fournit ; une **forme
valide**, que la logique contrôle ; et un **jugement** sur ce qui vaut la peine
d''être pensé, qui n''est ni l''une ni l''autre. Le sophiste a la forme sans le
souci du vrai ; le fanatique a des convictions sans la forme ; **Socrate** a les
deux, et c''est pourquoi **Platon** l''oppose aux premiers.

**Troisième moment — ce que cela veut dire pour vous, concrètement.** Une copie
de philosophie est jugée exactement là-dessus. Une bonne conclusion mal
démontrée vaut peu de points, parce que le correcteur note la démarche. Et une
démarche irréprochable sur des contresens n''en vaut pas davantage. C''est
pourquoi l''épreuve demande deux choses ensemble : une **culture
philosophique** — les prémisses — et le **respect des règles de la logique** —
la forme.

**Conclusion.** Il n''est pas légitime de penser que la logique suffit à bien
penser : elle est l''instrument le plus sûr que nous ayons, et un instrument ne
remplace pas celui qui s''en sert. Elle ne nous dit ni d''où partir, ni ce qui
mérite d''être pensé. Mais s''en dispenser serait pire, car sans elle on ne peut
même pas s''apercevoir qu''on se trompe. Bien penser consiste donc à joindre une
information vérifiée, une forme rigoureuse et le jugement de ce qui importe — et
c''est tout le programme de cette année.

---

### Ce que le correcteur attend

**La distinction nécessaire / suffisant**, dégagée dès l''analyse du sujet. Elle
donne à elle seule la structure des trois tâches.

**Un exemple de raisonnement valide à conclusion fausse.** C''est la preuve en
une ligne de l''insuffisance de la logique, et elle vaut dix lignes
d''explication.

**Une synthèse qui ne sacrifie pas la logique.** Les copies qui concluent qu''il
faut « écouter son cœur » se ferment la porte : l''épreuve exige elle-même le
respect des règles de la logique.
', NULL, 36),
      (v_chapitre_id, 'Quiz du chapitre 13', 9, 'quiz', '{
  "titre": "Vérifie que tu as compris",
  "questions": [
    {
      "question": "Quelle est la différence entre la vérité et la validité ?",
      "choix": [
        "Aucune",
        "La vérité qualifie une proposition conforme à ce qui est ; la validité qualifie un raisonnement dont la conclusion découle nécessairement des prémisses",
        "La validité concerne les faits",
        "La vérité concerne la forme"
      ],
      "bonne": 1,
      "explication": "Ce que la validité garantit : SI les prémisses sont vraies, ALORS la conclusion l''est. Rien de plus — un raisonnement valide sur des prémisses fausses conclut n''importe quoi."
    },
    {
      "question": "« Tous les métaux flottent ; le fer est un métal ; donc le fer flotte. » Que dire de ce raisonnement ?",
      "choix": [
        "Il est invalide",
        "Il est valide, mais sa conclusion est fausse parce qu''une prémisse est fausse",
        "Il est valide et vrai",
        "Il contient une pétition de principe"
      ],
      "bonne": 1,
      "explication": "C''est l''exemple qui prouve en une ligne que la logique est nécessaire mais non suffisante : elle garantit le passage, pas les prémisses."
    },
    {
      "question": "Dans un syllogisme, qu''est-ce que le moyen terme ?",
      "choix": [
        "Le sujet de la conclusion",
        "Celui qui figure dans les deux prémisses et disparaît de la conclusion",
        "Le prédicat de la conclusion",
        "La prémisse la plus faible"
      ],
      "bonne": 1,
      "explication": "C''est la charnière par laquelle les deux autres se rencontrent. Il doit être pris universellement au moins une fois, sinon le raisonnement est invalide."
    },
    {
      "question": "« S''il pleut, la route est mouillée. Or la route est mouillée. Donc il a plu. » Quelle est cette faute ?",
      "choix": [
        "Le modus ponens",
        "L''affirmation du conséquent, qui est invalide : un camion-citerne a pu passer",
        "Le modus tollens",
        "La négation de l''antécédent"
      ],
      "bonne": 1,
      "explication": "Les deux formes valides sont le modus ponens (si A alors B ; or A ; donc B) et le modus tollens (si A alors B ; or non-B ; donc non-A)."
    },
    {
      "question": "Qu''est-ce que la pétition de principe ?",
      "choix": [
        "Attaquer la personne au lieu de sa thèse",
        "Supposer dans les prémisses ce qu''on veut démontrer : on tourne en cercle sans rien établir",
        "Généraliser à partir de peu de cas",
        "Confondre succession et causalité"
      ],
      "bonne": 1,
      "explication": "C''est la faute la plus fréquente dans les copies de philosophie, et la plus difficile à repérer dans ses propres phrases."
    },
    {
      "question": "Que signifie « post hoc ergo propter hoc » ?",
      "choix": [
        "Après cela, donc à cause de cela : confondre la succession avec la causalité",
        "À plus forte raison",
        "Je crois parce que c''est absurde",
        "La foi qui cherche l''intelligence"
      ],
      "bonne": 1,
      "explication": "C''est la racine de la plupart des superstitions, et aussi de bien des erreurs savantes : une corrélation n''est pas une cause."
    },
    {
      "question": "Qu''a démontré Gödel en 1931 ?",
      "choix": [
        "Que la logique est inutile",
        "Que dans tout système formel suffisamment riche et non contradictoire, il existe des énoncés vrais qu''on ne peut pas y démontrer",
        "Que les mathématiques sont fausses",
        "Que le tiers exclu est faux"
      ],
      "bonne": 1,
      "explication": "La démonstration ne couvre donc pas la vérité, même en mathématiques. Cela ne discrédite pas la logique : cela la situe."
    }
  ]
}', NULL, 5);

    RAISE NOTICE '% : 9 leçons ajoutées au chapitre 13, La logique.', v_nom;
  END LOOP;
END $philo$;
