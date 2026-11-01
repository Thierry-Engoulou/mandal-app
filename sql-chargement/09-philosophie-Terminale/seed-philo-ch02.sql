-- ---------------------------------------------------------------------------
-- M'Andal — Philosophie, classes de Terminale
-- Chapitre 2 : Consolidation des acquis de la dissertation philosophique
-- Module 1 : La philosophie — 10 leçons
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
    WHERE programme_id = v_programme_id AND ordre = 2;

    IF v_chapitre_id IS NULL THEN
      INSERT INTO public.chapitres (programme_id, titre, ordre, niveau)
      VALUES (v_programme_id, 'Consolidation des acquis de la dissertation philosophique', 2, 'Module 1 : La philosophie')
      RETURNING id INTO v_chapitre_id;
      RAISE NOTICE '% : chapitre 2 créé.', v_nom;
    END IF;

    -- Les leçons. Si le chapitre en a déjà, on passe son tour sans rien toucher.
    SELECT count(*) INTO v_deja FROM public.concepts WHERE chapitre_id = v_chapitre_id;
    IF v_deja > 0 THEN
      RAISE NOTICE '% : le chapitre 2 a déjà ses % leçons, je n''y touche pas.', v_nom, v_deja;
      CONTINUE;
    END IF;

    INSERT INTO public.concepts
      (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes) VALUES
      (v_chapitre_id, 'L''épreuve : ce qu''on vous demande vraiment', 1, 'texte', '
Ce chapitre et le suivant ne portent sur aucune notion. Ils portent sur les
**deux exercices** qui composent l''épreuve, et c''est sur eux que se joue votre
note.

Un professeur camerounais le dit sans détour : la non-maîtrise de la
méthodologie est **la première cause d''échec** à l''examen. On peut connaître
Kant et perdre la moitié des points en les écrivant dans le désordre.

### La structure de l''épreuve

Les deux parties sont **obligatoires**. On ne choisit pas.

**Première partie — l''évaluation des ressources, 9 points.** Un texte
philosophique vous est donné, suivi de quatre tâches : définir trois concepts,
dégager le thème et le problème, dégager la thèse de l''auteur, décliner la
structure logique du texte.

**Deuxième partie — l''évaluation de l''agir compétent, 9 points.** Un essai
personnel, c''est-à-dire une dissertation, **de deux pages au plus**, en trois
tâches : la thèse, l''antithèse, la synthèse, trois points chacune.

**La présentation, 2 points.** Un point pour le respect de la structure, un
point pour l''allure générale de la copie.

### Ce que ce barème vous apprend

Lisez-le encore une fois : **neuf points pour le texte, neuf pour la
dissertation**. Les deux pèsent exactement le même poids, et pourtant la
plupart des élèves travaillent la dissertation et négligent le texte.

Les **deux points de présentation** sont les moins chers de tout l''examen. Une
copie structurée, aérée, lisible, avec des parties apparentes, les rapporte
sans qu''on ait rien appris. Les perdre, c''est se priver d''un point de moyenne.

Et **deux pages au plus**. Ce n''est pas une suggestion. Une copie de six pages
n''est pas mieux notée : elle montre seulement que le candidat n''a pas su
choisir.

### Le vocabulaire officiel

L''énoncé de la deuxième partie revient à chaque session dans les mêmes termes :
« En te fondant sur ta **culture philosophique** et dans le respect des **règles
de la logique**, est-il **légitime** de penser que… ? »

Trois exigences, et elles se traduisent en points.

La **culture philosophique** : des auteurs, des ouvrages, des thèses. Une
dissertation sans nom propre est une dissertation sans preuve.

Les **règles de la logique** : pas de contradiction, pas de pétition de
principe, et des transitions qui tiennent. C''est l''objet du dernier chapitre du
programme.

La **légitimité** : on ne vous demande pas si c''est vrai, ni ce que vous en
pensez, mais si la thèse est **fondée en raison**.

---

**Exercice corrigé**

*Un candidat rend une copie de cinq pages, très documentée, où il expose
longuement la thèse puis l''antithèse, et termine par : « Voilà pourquoi la
question reste ouverte. » Il n''a pas sauté de lignes entre ses parties.
Combien de points perd-il, et où ?*

**Correction.**

*La synthèse, 3 points perdus.* « La question reste ouverte » n''est pas une
synthèse, c''est un renoncement. La troisième tâche exige de dire **sur quoi**
chaque thèse a raison, puis de **trancher**. Elle est notée sur 3 points, et
elle est ici vide.

*La présentation, 1 point perdu au moins.* Sans parties apparentes, le
correcteur ne voit pas la structure : le point du « respect de la structure de
la dissertation » saute. Si la copie est en plus serrée et raturée, le second
point saute aussi.

*La longueur.* Cinq pages au lieu de deux ne rapportent rien et coûtent du
temps — celui qu''il aurait fallu donner à la première partie, qui vaut autant.

*Le total.* Ce candidat perd au minimum **4 points sur 20** sans qu''aucune de
ses connaissances soit en cause. C''est une moyenne qui tombe de 12 à 8.
', NULL, 28),
      (v_chapitre_id, 'Figure : les 20 points de l''épreuve', 2, 'figure', '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 580 330" width="580" height="330">
<rect width="580" height="330" fill="#ffffff"/>
<text x="290" y="24" text-anchor="middle" font-size="14" font-weight="700" fill="#0f172a">L&apos;épreuve de philosophie du Baccalauréat, séries C, D, E et TI</text>
<text x="290" y="42" text-anchor="middle" font-size="10" fill="#64748b">Les deux parties sont obligatoires. Total : 20 points.</text>

<rect x="20" y="58" width="262" height="206" rx="6" fill="#dbeafe" stroke="#2563eb" stroke-width="1.8"/>
<text x="151" y="80" text-anchor="middle" font-size="12" font-weight="700" fill="#1e3a8a">Première partie</text>
<text x="151" y="96" text-anchor="middle" font-size="10" fill="#1e40af">Évaluation des ressources</text>
<text x="151" y="114" text-anchor="middle" font-size="16" font-weight="700" fill="#1e3a8a">9 points</text>
<text x="151" y="132" text-anchor="middle" font-size="10" font-weight="700" fill="#1e40af">Un texte philosophique</text>

<rect x="34" y="144" width="234" height="36" rx="4" fill="#ffffff" stroke="#60a5fa"/>
<text x="44" y="159" font-size="9" font-weight="700" fill="#1e3a8a">A1 — définir trois concepts</text>
<text x="44" y="172" font-size="9" fill="#475569">1 point par définition</text>
<text x="256" y="166" text-anchor="end" font-size="12" font-weight="700" fill="#2563eb">3 pts</text>

<rect x="34" y="186" width="234" height="66" rx="4" fill="#ffffff" stroke="#60a5fa"/>
<text x="44" y="201" font-size="9" font-weight="700" fill="#1e3a8a">A2 — le savoir-faire</text>
<text x="44" y="215" font-size="9" fill="#475569">1. le thème et le problème</text>
<text x="44" y="228" font-size="9" fill="#475569">2. la thèse de l&apos;auteur</text>
<text x="44" y="241" font-size="9" fill="#475569">3. la structure logique</text>
<text x="256" y="222" text-anchor="end" font-size="12" font-weight="700" fill="#2563eb">6 pts</text>

<rect x="298" y="58" width="262" height="206" rx="6" fill="#dcfce7" stroke="#15803d" stroke-width="1.8"/>
<text x="429" y="80" text-anchor="middle" font-size="12" font-weight="700" fill="#14532d">Deuxième partie</text>
<text x="429" y="96" text-anchor="middle" font-size="10" fill="#166534">Évaluation de l&apos;agir compétent</text>
<text x="429" y="114" text-anchor="middle" font-size="16" font-weight="700" fill="#14532d">9 points</text>
<text x="429" y="132" text-anchor="middle" font-size="10" font-weight="700" fill="#166534">Un essai personnel, deux pages au plus</text>

<rect x="312" y="144" width="234" height="30" rx="4" fill="#ffffff" stroke="#4ade80"/>
<text x="322" y="163" font-size="9" font-weight="700" fill="#14532d">Première tâche — la thèse</text>
<text x="534" y="163" text-anchor="end" font-size="12" font-weight="700" fill="#15803d">3 pts</text>

<rect x="312" y="180" width="234" height="30" rx="4" fill="#ffffff" stroke="#4ade80"/>
<text x="322" y="199" font-size="9" font-weight="700" fill="#14532d">Deuxième tâche — l&apos;antithèse</text>
<text x="534" y="199" text-anchor="end" font-size="12" font-weight="700" fill="#15803d">3 pts</text>

<rect x="312" y="216" width="234" height="30" rx="4" fill="#ffffff" stroke="#4ade80"/>
<text x="322" y="235" font-size="9" font-weight="700" fill="#14532d">Troisième tâche — la synthèse</text>
<text x="534" y="235" text-anchor="end" font-size="12" font-weight="700" fill="#15803d">3 pts</text>

<rect x="20" y="276" width="540" height="40" rx="6" fill="#fef3c7" stroke="#ca8a04" stroke-width="1.6"/>
<text x="34" y="294" font-size="11" font-weight="700" fill="#78350f">La présentation</text>
<text x="34" y="309" font-size="9" fill="#92400e">1 point pour le respect de la structure · 1 point pour l&apos;allure générale de la copie</text>
<text x="540" y="301" text-anchor="end" font-size="14" font-weight="700" fill="#ca8a04">2 pts</text>
</svg>', NULL, 5),
      (v_chapitre_id, 'Simulation : où sont les vingt points ?', 3, 'interactif', '{
  "widget": "bareme-epreuve",
  "consigne": "La copie d''un candidat s''affiche, partie par partie, et tu la notes toi-même selon le barème officiel. Enlève la synthèse, bâcle les définitions, écris cinq pages au lieu de deux : le total se recalcule devant toi. Un second volet te montre le temps à consacrer à chaque tâche pour quatre heures d''épreuve, et ce qui arrive quand on passe trois heures sur la dissertation."
}', NULL, 10),
      (v_chapitre_id, 'Analyser le sujet avant d''écrire', 4, 'texte', '
C''est l''étape que personne ne saute impunément. Un professeur camerounais le
dit ainsi : lire et relire le sujet, chercher le problème, et douter — **la
première idée n''est pas forcément la bonne**.

Six opérations, dans cet ordre, et elles tiennent sur un brouillon.

### 1. Les concepts-clés

Repérer les mots qui portent le sens, et les définir. Ils reviendront dans
l''introduction, où le correcteur les attend.

Attention aux mots qui semblent transparents. Dans « le panafricanisme est-il
un projet irréalisable ? », il faut définir *panafricanisme*, mais aussi
*projet* — un dessein, ce qu''on se propose de réaliser — et *irréalisable* —
utopique, chimérique. C''est en définissant « irréalisable » qu''on s''aperçoit
que le sujet ne demande pas si le panafricanisme a échoué, mais s''il **ne peut
pas** réussir.

### 2. La reformulation

Réécrire le sujet avec vos mots, en remplaçant chaque terme par sa définition.
Si vous n''y arrivez pas, vous ne l''avez pas compris.

### 3. Le présupposé

Ce que le sujet **tient pour acquis** sans le dire. Tout libellé en contient
un, et le repérer vous donne la moitié de votre antithèse.

« Est-il légitime de penser que le panafricanisme est irréalisable ? »
présuppose que le projet panafricaniste est utopique. Votre antithèse
contestera précisément ce présupposé.

### 4. La thèse opposée

L''énoncer en une phrase. C''est votre deuxième partie, et vous l''avez déjà.

### 5. Le problème philosophique

Attention, c''est le mot qui coûte le plus de points, parce qu''on le confond
avec le thème.

Le **thème** est le sujet dont on parle : la liberté, la mort, le
panafricanisme. Un nom.

Le **problème** est la difficulté que ce thème soulève : la possibilité de
réaliser le panafricanisme, le fondement de la liberté, la nature du psychisme
humain. Une question, ou un nom suivi d''un complément.

Retenez la formule : le thème est **ce dont on parle**, le problème est **ce
qui fait difficulté**.

### 6. La problématique

La question qui organisera tout le devoir, et qui doit contenir la **tension**
entre les deux thèses. Elle a presque toujours la forme : « si… alors… mais
si… alors… ? »

Pour le panafricanisme : *les obstacles à sa réalisation le rendent-ils
définitivement irréalisable, ou peut-on, à certaines conditions, le faire
advenir ?*

### L''introduction, qui découle de tout cela

Quatre mouvements, et pas un de plus.

**L''amorce** : une phrase qui situe le sujet. Pas de « De tout temps, les
hommes… ».

**L''énoncé du sujet**, recopié ou reformulé.

**La définition des concepts et le problème** : c''est le cœur, et c''est noté.

**L''annonce du plan** : les trois tâches, en une phrase chacune.

### La conclusion

Trois mouvements : on **rappelle** le chemin parcouru, on **répond** clairement
à la problématique, et on **ouvre** sur une question voisine — sans en ouvrir
une qui détruirait tout ce qu''on vient d''écrire.

---

**Exercice corrigé**

*Analyser le sujet : « Est-il légitime de penser que l''État est un mal
nécessaire ? » Donner les concepts-clés, la reformulation, le présupposé, la
thèse opposée, le problème et la problématique.*

**Correction.**

**Concepts-clés.** *État* : institution politique qui détient l''autorité
souveraine sur un territoire et une population. *Mal* : ce qui nuit, ce qu''on
subit. *Nécessaire* : ce qui ne peut pas ne pas être, ce dont on ne peut se
passer. *Légitime* : fondé en raison.

**Reformulation.** A-t-on de bonnes raisons de soutenir que l''État nuit aux
hommes, mais qu''on ne peut pas s''en passer ?

**Le présupposé.** Le sujet tient pour acquis que l''État **est** un mal — il ne
discute que sa nécessité. C''est ce présupposé que l''antithèse contestera.

**La thèse opposée.** L''État n''est pas un mal : il est un bien pour les
citoyens, parce qu''il assure la sécurité, le bien-être et la régulation de la
vie sociale.

**Le problème philosophique.** La valeur de l''État.

*Remarque : « l''État » serait le thème ; « la valeur de l''État » est le
problème. La différence tient au complément, et elle vaut des points.*

**La problématique.** L''État, parce qu''il repose sur la contrainte et la
violence légitime, est-il un mal qu''il faut seulement tolérer, ou bien la
condition même d''une liberté qui, sans lui, n''aurait aucune garantie ?
', NULL, 32),
      (v_chapitre_id, 'Simulation : analyser un sujet', 5, 'interactif', '{
  "widget": "analyser-sujet",
  "consigne": "Un libellé de Baccalauréat s''affiche, et tu le décomposes en six cases : concepts-clés, reformulation, présupposé, thèse opposée, problème, problématique. La simulation te propose plusieurs candidats pour chaque case, dont les erreurs classiques — le thème à la place du problème, une problématique sans tension, un présupposé qui n''est que la reformulation. Chaque mauvais choix est expliqué, et huit sujets des sessions récentes défilent."
}', NULL, 10),
      (v_chapitre_id, 'Les trois tâches, et les deux plans possibles', 6, 'texte', '
La consigne impose trois tâches : la thèse, l''antithèse, la synthèse. Mais leur
contenu change selon la **forme du libellé**, et c''est ce que beaucoup de
candidats ignorent.

### Reconnaître la forme du sujet

**Le sujet-question.** « Est-il légitime de penser que le panafricanisme est un
projet irréalisable ? » Aucun auteur n''est cité. Vous discutez une idée.

**Le sujet-citation.** « Est-il légitime de penser avec Sigmund Freud que “le
moi n''est pas maître dans sa propre maison” ? » Une pensée d''auteur est
proposée. Vous discutez **cette pensée-là**.

La différence est capitale, parce qu''elle change le plan.

### Le plan du sujet-question : thèse, antithèse, synthèse

**I. La thèse.** On soutient ce que le sujet avance, avec deux ou trois
arguments, chacun appuyé sur un auteur.

**II. L''antithèse.** On soutient le contraire, avec la même exigence.

**III. La synthèse.** On dit sur quoi chaque camp a raison, puis on tranche.

### Le plan du sujet-citation : expliquer, limiter, réinterpréter

C''est le plan que suit le corrigé harmonisé national, et il est différent.

**I. Explication et commentaire de la pensée de l''auteur.** On explique ce que
l''auteur veut dire, puis on l''argumente comme s''il fallait le défendre.

**II. Les limites de la pensée de l''auteur.** On montre ce qu''elle ne voit pas,
avec les auteurs qui s''y opposent.

**III. Réinterprétation et valorisation de la pensée.** On ne jette pas la
citation : on montre ce qu''elle garde de vrai une fois corrigée, et pourquoi
elle méritait d''être discutée.

La troisième partie est celle qui distingue une bonne copie. Elle ne dit pas
« l''auteur a tort » : elle dit **ce que l''auteur nous apprend malgré ses
limites**.

### Les transitions

Entre chaque tâche, **une phrase**, et elle pose la question à laquelle la
tâche suivante répondra.

Après la thèse : *« Mais l''influence des déterminismes suffit-elle à réduire
l''homme à la reproduction de son enfance ? »*

Après l''antithèse : *« L''homme est-il alors si libre que la pensée de l''auteur
en devienne sans valeur ? »*

Elles coûtent deux lignes et elles rapportent, parce qu''elles prouvent au
correcteur que vous avancez au lieu de juxtaposer.

### Les trois fautes qui coûtent le plus

**L''antithèse qui n''est qu''une reformulation de la thèse.** Si votre deuxième
partie dit la même chose que la première avec d''autres mots, vous perdez trois
points. Le test : les deux parties doivent pouvoir se contredire devant un
même cas concret.

**La synthèse en forme de compromis mou.** « Les deux thèses ont du vrai » ne
vaut rien. Il faut dire sur quoi, et trancher.

**Le hors-sujet par préjugé.** Un professeur camerounais prévient : aucun
préjugé ne doit être admis, sous peine de hors-sujet. Si vous répondez à la
question que vous auriez aimé avoir, vous ne répondez pas à celle qui est
posée.

---

**Exercice corrigé**

*Pour le sujet « Est-il légitime de penser avec Sigmund Freud que “le moi n''est
pas maître dans sa propre maison” ? », indiquer la forme du sujet, le plan à
suivre, et rédiger les deux transitions.*

**Correction.**

*La forme.* C''est un **sujet-citation** : une pensée est attribuée à un auteur
nommé, et c''est elle qu''il faut discuter. On n''écrira donc pas une dissertation
générale sur l''inconscient.

*Le plan.*

**I. Explication et commentaire de la pensée de Freud.** La formule signifie
que la conscience ne gouverne pas la vie psychique : le moi est traversé par
des forces qu''il ignore. On l''argumente par les rêves, les lapsus et les actes
manqués, par les deux topiques, et par le déterminisme psychique issu de
l''enfance.

**II. Les limites de cette pensée.** Pour les philosophies du sujet, la
conscience est souveraine : Descartes en fait la première vérité. Pour Sartre,
invoquer l''inconscient est une **mauvaise foi**, un alibi pour fuir sa
responsabilité. Et l''hypothèse d''un inconscient qui agit « en nous, sans nous
et malgré nous » risque de déresponsabiliser l''homme.

**III. Réinterprétation.** Freud n''enlève pas à l''homme sa maison : il lui
apprend qu''il n''en connaît pas toutes les pièces. Reconnaître l''inconscient
n''est pas renoncer à la liberté, c''est se donner les moyens de l''élargir.
Freud l''écrit : « Là où était le Ça, le Je doit advenir. »

*Les deux transitions.*

Après la première tâche : *« Mais si le moi n''est pas maître chez lui, qui donc
répond de nos actes ? »*

Après la deuxième tâche : *« Faut-il pour autant rejeter la découverte de
Freud, ou peut-on l''entendre autrement que comme une négation de la
liberté ? »*
', NULL, 32),
      (v_chapitre_id, 'Figure : le sujet-question et le sujet-citation', 7, 'figure', '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 580 290" width="580" height="290">
<rect width="580" height="290" fill="#ffffff"/>
<text x="290" y="24" text-anchor="middle" font-size="14" font-weight="700" fill="#0f172a">Deux libellés, deux plans</text>
<text x="290" y="42" text-anchor="middle" font-size="10" fill="#64748b">Le plan ne se choisit pas : il est imposé par la forme du sujet.</text>

<rect x="20" y="58" width="262" height="212" rx="6" fill="#eff6ff" stroke="#2563eb" stroke-width="1.6"/>
<text x="151" y="78" text-anchor="middle" font-size="11" font-weight="700" fill="#1e3a8a">Le sujet-question</text>
<text x="151" y="94" text-anchor="middle" font-size="9" font-style="italic" fill="#475569">« Est-il légitime de penser que… ? »</text>
<text x="151" y="108" text-anchor="middle" font-size="9" fill="#64748b">aucune citation, aucun auteur</text>

<rect x="34" y="120" width="234" height="40" rx="4" fill="#ffffff" stroke="#60a5fa"/>
<text x="44" y="136" font-size="10" font-weight="700" fill="#1e3a8a">I. La thèse</text>
<text x="44" y="151" font-size="9" fill="#475569">on soutient ce que le sujet avance</text>

<rect x="34" y="166" width="234" height="40" rx="4" fill="#ffffff" stroke="#60a5fa"/>
<text x="44" y="182" font-size="10" font-weight="700" fill="#1e3a8a">II. L&apos;antithèse</text>
<text x="44" y="197" font-size="9" fill="#475569">on soutient le contraire</text>

<rect x="34" y="212" width="234" height="44" rx="4" fill="#ffffff" stroke="#60a5fa"/>
<text x="44" y="228" font-size="10" font-weight="700" fill="#1e3a8a">III. La synthèse</text>
<text x="44" y="243" font-size="9" fill="#475569">on dit sur quoi chacune a raison,</text>
<text x="44" y="253" font-size="9" fill="#475569">puis on tranche</text>

<rect x="298" y="58" width="262" height="212" rx="6" fill="#f0fdf4" stroke="#15803d" stroke-width="1.6"/>
<text x="429" y="78" text-anchor="middle" font-size="11" font-weight="700" fill="#14532d">Le sujet-citation</text>
<text x="429" y="94" text-anchor="middle" font-size="9" font-style="italic" fill="#475569">« …penser avec X que “…” ? »</text>
<text x="429" y="108" text-anchor="middle" font-size="9" fill="#64748b">une pensée d&apos;auteur est citée</text>

<rect x="312" y="120" width="234" height="40" rx="4" fill="#ffffff" stroke="#4ade80"/>
<text x="322" y="136" font-size="10" font-weight="700" fill="#14532d">I. Explication de la pensée</text>
<text x="322" y="151" font-size="9" fill="#475569">on l&apos;explique et on l&apos;argumente</text>

<rect x="312" y="166" width="234" height="40" rx="4" fill="#ffffff" stroke="#4ade80"/>
<text x="322" y="182" font-size="10" font-weight="700" fill="#14532d">II. Limites de la pensée</text>
<text x="322" y="197" font-size="9" fill="#475569">ce que l&apos;auteur ne voit pas</text>

<rect x="312" y="212" width="234" height="44" rx="4" fill="#ffffff" stroke="#4ade80"/>
<text x="322" y="228" font-size="10" font-weight="700" fill="#14532d">III. Réinterprétation</text>
<text x="322" y="243" font-size="9" fill="#475569">ce que la pensée garde de vrai,</text>
<text x="322" y="253" font-size="9" fill="#475569">une fois corrigée</text>
</svg>', NULL, 5),
      (v_chapitre_id, 'Simulation : construire le plan', 8, 'interactif', '{
  "widget": "plan-dissertation",
  "consigne": "Un sujet s''affiche, et une douzaine d''arguments en vrac attendent d''être placés dans la thèse, l''antithèse ou la synthèse. La simulation refuse une antithèse qui répète la thèse et te le montre en confrontant les deux au même cas concret. Elle reconnaît aussi la forme du libellé : mets un plan thèse-antithèse-synthèse sur un sujet-citation et elle te propose le plan attendu par le corrigé national. Tu rédiges enfin les deux transitions en choisissant parmi des propositions, dont trois qui ne transitent rien."
}', NULL, 10),
      (v_chapitre_id, 'Sujet type Baccalauréat — « L''enfant est le père de l''homme »', 9, 'texte', '
**Deuxième partie de l''épreuve — Évaluation de l''agir compétent — 9 points**

*En te fondant sur ta culture philosophique et dans le respect des règles de la
logique, est-il légitime de penser, avec William Wordsworth, que « l''enfant est
le père de l''homme » ?*

*Consigne : rédiger une dissertation de deux pages au plus. Première tâche
(3 points), deuxième tâche (3 points), troisième tâche (3 points).*

*Ce sujet est celui de la session 2025, séries C, D, E et TI. Le plan ci-dessous
suit le corrigé harmonisé national.*

---
---

## Corrigé

### I. Analyse et compréhension du sujet

**Trois lectures possibles de la formule**, et il faut écarter les deux
premières.

*La lecture simpliste* : qui vient avant qui ? L''enfant précède l''adulte. C''est
une évidence biologique, et ce n''est pas un sujet de philosophie.

*La lecture auctoriale* : chez Wordsworth, le poète, l''enfance est la source de
ce que devient l''homme, et notamment de sa sensibilité.

*La lecture freudienne*, et c''est celle qu''on attend : l''enfance, c''est-à-dire
l''inconscient, forme le socle du psychisme adulte.

**La posture de l''auteur.** L''enfance détermine l''adulte ; ce que nous sommes
devenus s''est joué avant que nous en ayons conscience.

**La thèse opposée.** Pour les philosophies du sujet, la conscience est le
fondement du psychisme, et l''homme maîtrise son comportement.

**Le problème philosophique.** Le rôle de l''inconscient dans le comportement du
sujet.

**La problématique.** En expliquant l''adulte par son enfance, ne risque-t-on
pas de négliger le rôle de la conscience, et de fournir à l''homme un alibi
commode pour fuir ses responsabilités ?

**La forme du sujet.** C''est un **sujet-citation**. Le plan sera donc :
explication, limites, réinterprétation.

### II. Première tâche — explication et commentaire de la pensée *(3 points)*

**Ce que la formule veut dire.** Les expériences de l''enfance influencent
durablement la personnalité de l''adulte. L''enfant n''est pas un homme en
réduction : il est celui qui engendre l''homme.

**Argument 1 — la théorie freudienne.** Freud montre que les premières années
fixent des schémas que l''adulte répète sans les reconnaître. Le **refoulement**
ne supprime pas les contenus psychiques : il les écarte de la conscience, d''où
ils continuent d''agir. Les rêves, les lapsus et les actes manqués en sont les
témoins. Freud invite à cesser de surestimer la conscience, dont les données
sont lacunaires.

**Argument 2 — les philosophies du soupçon.** Freud, Marx et Nietzsche
soutiennent chacun que la conscience se trompe sur elle-même. Roger Ebacher
résume la position : l''inconscient « agit en nous, sans nous et malgré nous ».

**Argument 3 — le déterminisme.** Spinoza soutient que les hommes se croient
libres parce qu''ils ignorent les causes qui les déterminent. Cesare Lombroso,
bien plus contestable, va jusqu''à chercher dans l''hérédité l''origine du
comportement criminel.

*Transition.* Mais l''influence des déterminismes suffit-elle à réduire l''homme à
la reproduction de son enfance ?

### III. Deuxième tâche — les limites de la pensée *(3 points)*

**Argument 1 — la conscience est souveraine.** Pour les rationalistes, Descartes
en tête, la conscience est la première vérité et elle est transparente à
elle-même. Alain soutient que rien ne se passe en nous sans que nous puissions
le savoir.

**Argument 2 — l''homme est liberté.** Sartre refuse le déterminisme : « il n''y
a pas de déterminisme, l''homme est libre, l''homme est liberté », et « l''homme
est condamné à être libre ». Invoquer son enfance pour expliquer ses actes
relève de la **mauvaise foi** : c''est se donner une excuse.

**Argument 3 — la conséquence morale.** Si l''enfance détermine tout, personne
n''est responsable de rien. Le criminel invoquera son enfance, et la notion même
de faute s''effondre. Une thèse qui détruit la responsabilité se détruit
elle-même, puisque plus personne ne répond de ce qu''il affirme.

*Transition.* Faut-il pour autant rejeter la pensée de Wordsworth, ou peut-on
l''entendre autrement que comme une négation de la liberté ?

### IV. Troisième tâche — réinterprétation et valorisation *(3 points)*

**Premier moment.** La pensée de Wordsworth a une vertu : elle attire
l''attention sur ce que la conscience ignore d''elle-même. Le psychisme ne se
réduit pas à ce dont je m''aperçois, et le nier n''est pas de la rigueur, c''est
de l''aveuglement.

**Deuxième moment.** Mais reconnaître l''inconscient n''oblige pas à soumettre
l''homme au déterminisme. Freud ne soigne pas pour excuser : il éclaire les
zones d''ombre **afin que** l''homme reprenne la main sur son comportement. Sa
formule le dit exactement : « Là où était le Ça, le Je doit advenir. »

**Troisième moment — la réponse.** Il est légitime de penser avec Wordsworth
que l''enfant est le père de l''homme, à condition d''entendre « père » comme
**origine** et non comme **destin**. L''enfance explique d''où nous venons ; elle
ne dit pas où nous devons aller. La liberté n''est pas l''absence de passé :
elle est ce qu''on fait de ce passé une fois qu''on l''a reconnu.

**Conclusion.** La formule de Wordsworth est légitime si l''on y voit une
invitation à la lucidité, et non un alibi. Elle cesse de l''être dès qu''on en
fait une fatalité. Reste à savoir si cette lucidité sur soi s''acquiert seul, ou
si elle suppose le regard d''autrui.

---

### Ce que le correcteur attend

**Que vous ayez reconnu un sujet-citation.** Une dissertation générale sur
l''inconscient, même excellente, ne répond pas au sujet posé.

**Trois auteurs au minimum par tâche.** Ici Freud, Spinoza et Ebacher d''un
côté ; Descartes, Alain et Sartre de l''autre.

**Une troisième partie qui sauve la citation.** C''est elle qui sépare la copie
moyenne de la bonne copie.
', NULL, 38),
      (v_chapitre_id, 'Quiz du chapitre 2', 10, 'quiz', '{
  "titre": "Vérifie que tu as compris",
  "questions": [
    {
      "question": "Comment se répartissent les 20 points de l''épreuve ?",
      "choix": [
        "10 pour le texte, 10 pour la dissertation",
        "9 pour le texte, 9 pour la dissertation, 2 pour la présentation",
        "20 pour la dissertation seule",
        "5 pour le texte, 15 pour la dissertation"
      ],
      "bonne": 1,
      "explication": "Les deux parties pèsent exactement le même poids, et pourtant la plupart des élèves négligent le texte. Les 2 points de présentation sont les moins chers de l''examen."
    },
    {
      "question": "Quelle est la différence entre le thème et le problème ?",
      "choix": [
        "Aucune",
        "Le thème est ce dont on parle, le problème est ce qui fait difficulté",
        "Le thème est plus long",
        "Le problème se met dans la conclusion"
      ],
      "bonne": 1,
      "explication": "« L''État » est un thème ; « la valeur de l''État » est un problème. La différence tient au complément, et elle vaut des points à chaque session."
    },
    {
      "question": "Qu''est-ce que le présupposé d''un sujet ?",
      "choix": [
        "Le plan qu''on va suivre",
        "Ce que le sujet tient pour acquis sans le dire",
        "La conclusion attendue",
        "La définition des mots"
      ],
      "bonne": 1,
      "explication": "Le repérer donne la moitié de l''antithèse : c''est lui qu''on va contester en deuxième partie."
    },
    {
      "question": "Quel plan suit un sujet-citation, d''après le corrigé harmonisé national ?",
      "choix": [
        "Thèse, antithèse, synthèse",
        "Explication de la pensée, limites de la pensée, réinterprétation",
        "Introduction, développement, conclusion",
        "Pour, contre, conclusion"
      ],
      "bonne": 1,
      "explication": "La troisième partie ne dit pas « l''auteur a tort » : elle montre ce que la pensée garde de vrai une fois corrigée. C''est elle qui distingue une bonne copie."
    },
    {
      "question": "Quelle est la faute qui coûte les trois points de la deuxième tâche ?",
      "choix": [
        "Écrire trop court",
        "Une antithèse qui n''est qu''une reformulation de la thèse",
        "Citer trop d''auteurs",
        "Oublier la date d''un ouvrage"
      ],
      "bonne": 1,
      "explication": "Le test : les deux parties doivent pouvoir se contredire devant un même cas concret. Si elles ne le peuvent pas, il n''y a qu''une seule partie."
    },
    {
      "question": "Que vaut une synthèse qui dit « les deux thèses ont du vrai » ?",
      "choix": [
        "Le maximum des points",
        "Rien : il faut dire SUR QUOI chacune a raison, puis trancher",
        "La moitié des points",
        "Cela dépend du correcteur"
      ],
      "bonne": 1,
      "explication": "« La question reste ouverte » est un renoncement, pas une synthèse. La troisième tâche est notée sur 3 points et exige une réponse."
    },
    {
      "question": "Que signifie « dans le respect des règles de la logique » dans l''énoncé ?",
      "choix": [
        "Qu''il faut écrire lisiblement",
        "Qu''il ne faut ni contradiction, ni pétition de principe, et que les transitions doivent tenir",
        "Qu''il faut des mathématiques",
        "Que le plan doit faire trois parties"
      ],
      "bonne": 1,
      "explication": "C''est l''objet du dernier chapitre du programme. La formule revient à chaque session, et elle est notée."
    },
    {
      "question": "Quelle longueur la consigne impose-t-elle à la dissertation ?",
      "choix": [
        "Au moins quatre pages",
        "Deux pages au plus",
        "Six pages",
        "Aucune limite"
      ],
      "bonne": 1,
      "explication": "Ce n''est pas une suggestion. Une copie de six pages n''est pas mieux notée : elle montre que le candidat n''a pas su choisir, et elle vole le temps dû à la première partie."
    }
  ]
}', NULL, 5);

    RAISE NOTICE '% : 10 leçons ajoutées au chapitre 2, Consolidation des acquis de la dissertation philosophique.', v_nom;
  END LOOP;
END $philo$;
