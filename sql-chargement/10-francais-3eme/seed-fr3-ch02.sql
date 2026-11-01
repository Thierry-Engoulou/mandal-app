-- ---------------------------------------------------------------------------
-- M'Andal — Français, classe de 3ème
-- Chapitre 2 : Phrase simple, phrase composée, phrase complexe
-- Module 1 : La vie familiale et socioculturelle — 8 leçons
--
-- Ce fichier n'a besoin de rien d'autre pour tourner. Si la matière, la classe,
-- le programme ou le chapitre n'existent pas encore, il les crée lui-même au
-- passage.
--
-- Lancez-le quand vous voulez, dans l'ordre que vous voulez, et autant de fois
-- que vous voulez : quand le chapitre a déjà ses leçons, le script s'en rend
-- compte et n'ajoute rien.
-- ---------------------------------------------------------------------------
DO $fr3$
DECLARE
  v_matiere_id uuid;
  v_classe_id uuid;
  v_etab_id uuid;
  v_programme_id uuid;
  v_chapitre_id uuid;
  v_nb_etabs int;
  v_deja int;
BEGIN
  -- La matière Français : on ne la crée qu'une fois pour toutes.
  INSERT INTO public.matieres (nom) VALUES ('Français') ON CONFLICT (nom) DO NOTHING;
  SELECT id INTO v_matiere_id FROM public.matieres WHERE nom = 'Français';

  -- L'établissement, on le retrouve à partir des classes déjà en base.
  SELECT count(DISTINCT etablissement_id) INTO v_nb_etabs FROM public.classes;
  IF v_nb_etabs <> 1 THEN
    RAISE EXCEPTION 'Je ne sais pas à quel établissement rattacher cette classe : j''en trouve % dans la table des classes, et il m''en faudrait exactement un.', v_nb_etabs;
  END IF;
  SELECT etablissement_id INTO v_etab_id FROM public.classes LIMIT 1;

  -- Le programme de Français de la 3ème existe-t-il déjà ?
  SELECT p.id INTO v_programme_id FROM public.programmes p
  WHERE p.titre = 'Français — 3ème';

  -- Non : on le crée, et la classe avec si besoin.
  IF v_programme_id IS NULL THEN
    -- La classe a pu être écrite de plusieurs façons : 3ème, 3e, Troisième.
    SELECT id INTO v_classe_id FROM public.classes
    WHERE etablissement_id = v_etab_id
      AND (nom = '3ème' OR nom ILIKE '3%me' OR nom ILIKE 'Troisi%me' OR nom = '3e')
    ORDER BY (nom = '3ème') DESC
    LIMIT 1;

    IF v_classe_id IS NULL THEN
      INSERT INTO public.classes (etablissement_id, nom, niveau, filiere)
      VALUES (v_etab_id, '3ème', '3ème', NULL)
      RETURNING id INTO v_classe_id;
      RAISE NOTICE 'La classe de 3ème n''existait pas : je viens de la créer.';
    END IF;

    INSERT INTO public.programmes (matiere_id, classe_id, etablissement_id, titre, description)
    VALUES (v_matiere_id, v_classe_id, v_etab_id, 'Français — 3ème',
            'Programme officiel de Français 1ère langue, classe de 3ème (MINESEC, Cameroun) — 5 modules, 40 chapitres.')
    RETURNING id INTO v_programme_id;
    RAISE NOTICE 'Programme de Français de la 3ème : créé.';
  END IF;

  -- Le chapitre lui-même.
  SELECT id INTO v_chapitre_id FROM public.chapitres
  WHERE programme_id = v_programme_id AND ordre = 2;

  IF v_chapitre_id IS NULL THEN
    INSERT INTO public.chapitres (programme_id, titre, ordre, niveau)
    VALUES (v_programme_id, 'Phrase simple, phrase composée, phrase complexe', 2, 'Module 1 : La vie familiale et socioculturelle')
    RETURNING id INTO v_chapitre_id;
    RAISE NOTICE 'Chapitre 2 créé.';
  END IF;

  -- Les leçons. Si le chapitre en a déjà, on passe son tour sans rien toucher.
  SELECT count(*) INTO v_deja FROM public.concepts WHERE chapitre_id = v_chapitre_id;
  IF v_deja > 0 THEN
    RAISE NOTICE 'Le chapitre 2 a déjà ses % leçons, je n''y touche pas.', v_deja;
    RETURN;
  END IF;

  INSERT INTO public.concepts
    (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes) VALUES
    (v_chapitre_id, 'La proposition, et comment la compter', 1, 'texte', '
Ce chapitre prépare directement la **question 5 de la deuxième partie du
BEPC**, qui vaut deux points et qui tombe à chaque session : *relevez les
propositions de cette phrase, nommez-les, et donnez la fonction de la
subordonnée*.

La bonne nouvelle, c''est que tout part d''un geste mécanique.

### Une proposition, c''est un verbe conjugué

Voilà la règle, et elle ne souffre aucune exception :

**Autant de verbes conjugués, autant de propositions.**

> Le car arrive.

Un verbe conjugué, *arrive*. Une proposition.

> Le car arrive et les voyageurs descendent.

Deux verbes conjugués, *arrive* et *descendent*. Deux propositions.

### Attention : conjugué, pas n''importe quel verbe

Un verbe à l''infinitif ou au participe ne compte pas, parce qu''il n''est pas
conjugué.

> Les voyageurs veulent descendre.

Combien de verbes vois-tu ? Deux : *veulent* et *descendre*. Mais *descendre* est
à l''infinitif. Il n''y a donc **qu''un seul verbe conjugué**, et **une seule
proposition**. La phrase est simple.

C''est le piège le plus courant de l''exercice. Prends l''habitude de te demander,
pour chaque verbe : *celui-là, il est conjugué ?* Un verbe conjugué a un sujet et
se met à un temps. Un infinitif ne change pas.

Même chose pour les participes :

> Fatigués par la route, les voyageurs descendent lentement.

*Fatigués* est un participe passé employé comme adjectif. Un seul verbe conjugué,
*descendent*. Une proposition, phrase simple.

### Le vocabulaire à employer

Quand une phrase n''a qu''une proposition, on dit que c''est une **proposition
indépendante**, et la phrase est **simple**.

Quand il y en a plusieurs, il faut regarder si elles sont à égalité ou si l''une
dépend de l''autre. C''est tout l''objet des deux leçons qui suivent.

---

**Exercice corrigé**

*Compter les propositions de chacune de ces phrases, et dire si elle est simple
ou non.*

*1. Mon père répare la moto dans la cour.*
*2. Ma mère prépare le repas pendant que mon père répare la moto.*
*3. Mon père a décidé de réparer la moto lui-même.*
*4. Ayant terminé ses devoirs, ma sœur aide ma mère et prépare le feu.*

**Correction.**

*1.* Verbes : *répare*. Un seul, conjugué. **Une proposition**, donc phrase
**simple**. « Dans la cour » est un complément circonstanciel, pas une
proposition : il n''a pas de verbe.

*2.* Verbes : *prépare* et *répare*. Deux verbes conjugués. **Deux
propositions**, donc la phrase n''est pas simple.

*3.* Verbes : *a décidé* et *réparer*. Attention : *a décidé* est conjugué au
passé composé, mais *réparer* est à l''infinitif. Donc **une seule proposition**,
et la phrase est **simple** — malgré sa longueur.

*4.* Verbes : *ayant terminé*, *aide*, *prépare*. Le premier est un participe
passé composé, donc non conjugué au sens où nous l''entendons. Restent *aide* et
*prépare* : **deux propositions**.

*La leçon des phrases 3 et 4 : la longueur d''une phrase ne dit rien du nombre de
ses propositions. Compte les verbes conjugués, et seulement eux.*
', NULL, 20),
    (v_chapitre_id, 'Figure : simple, composée, complexe', 2, 'figure', '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 580 320" width="580" height="320">
<rect width="580" height="320" fill="#ffffff"/>
<text x="290" y="24" text-anchor="middle" font-size="14" font-weight="700" fill="#0f172a">Compter les verbes conjugués, et tout devient simple</text>
<text x="290" y="42" text-anchor="middle" font-size="10" fill="#64748b">Autant de verbes conjugués, autant de propositions.</text>

<rect x="20" y="56" width="540" height="72" rx="6" fill="#dcfce7" stroke="#15803d" stroke-width="1.6"/>
<text x="34" y="76" font-size="11" font-weight="700" fill="#14532d">PHRASE SIMPLE — un seul verbe conjugué, donc une seule proposition</text>
<text x="34" y="98" font-size="10" fill="#166534">Le car de Douala <tspan font-weight="700" fill="#15803d">arrive</tspan> à huit heures.</text>
<text x="34" y="118" font-size="9" font-style="italic" fill="#475569">On l&apos;appelle aussi une proposition indépendante.</text>

<rect x="20" y="138" width="540" height="84" rx="6" fill="#fef3c7" stroke="#ca8a04" stroke-width="1.6"/>
<text x="34" y="158" font-size="11" font-weight="700" fill="#78350f">PHRASE COMPOSÉE — plusieurs verbes, et les propositions sont à égalité</text>
<text x="34" y="180" font-size="10" fill="#92400e">Le car <tspan font-weight="700" fill="#ca8a04">arrive</tspan>, les voyageurs <tspan font-weight="700" fill="#ca8a04">descendent</tspan>.</text>
<text x="300" y="180" font-size="9" fill="#92400e">→ juxtaposition (virgule)</text>
<text x="34" y="198" font-size="10" fill="#92400e">Le car <tspan font-weight="700" fill="#ca8a04">arrive</tspan> et les voyageurs <tspan font-weight="700" fill="#ca8a04">descendent</tspan>.</text>
<text x="300" y="198" font-size="9" fill="#92400e">→ coordination (mais, ou, et, donc…)</text>
<text x="34" y="214" font-size="9" font-style="italic" fill="#475569">Aucune ne dépend de l&apos;autre : on peut les séparer en deux phrases.</text>

<rect x="20" y="232" width="540" height="78" rx="6" fill="#dbeafe" stroke="#2563eb" stroke-width="1.6"/>
<text x="34" y="252" font-size="11" font-weight="700" fill="#1e3a8a">PHRASE COMPLEXE — une proposition dépend d&apos;une autre</text>
<text x="34" y="274" font-size="10" fill="#1e40af">Les voyageurs <tspan font-weight="700" fill="#2563eb">descendent</tspan> dès que le car <tspan font-weight="700" fill="#2563eb">arrive</tspan>.</text>
<text x="34" y="292" font-size="9" fill="#1e40af">principale : « les voyageurs descendent » · subordonnée : « dès que le car arrive »</text>
<text x="34" y="306" font-size="9" font-style="italic" fill="#7f1d1d">Retire la subordonnée : la phrase tient encore. Retire la principale : elle tombe.</text>
</svg>', NULL, 5),
    (v_chapitre_id, 'Simulation : compter les propositions', 3, 'interactif', '{
  "widget": "compter-propositions",
  "consigne": "Une phrase s''affiche, et tu cliques sur chaque verbe que tu repères. La simulation te demande alors pour chacun : est-il conjugué ? Elle compte avec toi, puis annonce le nombre de propositions. Les quinze phrases contiennent tous les pièges du BEPC : l''infinitif après un verbe conjugué, le participe présent en tête de phrase, le participe passé employé comme adjectif, et la phrase très longue qui n''a pourtant qu''une seule proposition."
}', NULL, 10),
    (v_chapitre_id, 'La phrase composée : juxtaposition et coordination', 4, 'texte', '
Plusieurs propositions, et aucune ne commande aux autres : la phrase est
**composée**. Les propositions y sont **indépendantes**, à égalité.

Il n''y a que deux façons de les relier.

### La juxtaposition

Les propositions sont posées côte à côte, séparées par un signe de ponctuation :
une **virgule**, un **point-virgule** ou **deux points**.

> Le car arrive, les voyageurs descendent, les porteurs se précipitent.

Trois propositions indépendantes **juxtaposées**. Aucun mot de liaison, seulement
des virgules.

### La coordination

Les propositions sont reliées par une **conjonction de coordination** ou par un
**adverbe de liaison**.

Les sept conjonctions de coordination, que tu dois connaître par cœur :

> **mais, ou, et, donc, or, ni, car**

On les retient avec la phrase « Mais où est donc Ornicar ? », qui les contient
toutes dans l''ordre.

> Le car arrive **mais** les voyageurs ne descendent pas.

Les adverbes de liaison font le même travail : *puis*, *ensuite*, *cependant*,
*pourtant*, *alors*, *enfin*.

> Le car arrive, **puis** les voyageurs descendent.

### Le test qui prouve l''indépendance

Comment être sûr que les propositions sont bien indépendantes ? Essaie de les
**séparer en deux phrases**.

> Le car arrive mais les voyageurs ne descendent pas.
> → Le car arrive. Les voyageurs ne descendent pas.

Les deux phrases tiennent debout toutes seules. Les propositions étaient donc
bien indépendantes, et la phrase était composée.

Garde ce test : il est la clé du chapitre, et il te servira à la leçon suivante
pour reconnaître le cas contraire.

---

**Exercice corrigé**

*Relever les propositions, dire comment elles sont reliées, et prouver qu''elles
sont indépendantes.*

> *Les commerçants ouvrent leurs boutiques dès six heures ; les clients arrivent
> plus tard, car le soleil est encore doux.*

**Correction.**

*Je compte les verbes conjugués :* *ouvrent*, *arrivent*, *est*. Trois verbes
conjugués, donc **trois propositions**.

*Je les délimite :*

Première proposition : « Les commerçants ouvrent leurs boutiques dès six
heures ».
Deuxième proposition : « les clients arrivent plus tard ».
Troisième proposition : « le soleil est encore doux ».

*Comment sont-elles reliées ?*

Entre la première et la deuxième, un **point-virgule** : elles sont
**juxtaposées**.

Entre la deuxième et la troisième, la conjonction **car** : elles sont
**coordonnées**.

*La preuve de leur indépendance.* Je les sépare :

> Les commerçants ouvrent leurs boutiques dès six heures. Les clients arrivent
> plus tard. Le soleil est encore doux.

Les trois phrases tiennent debout. Aucune ne dépend d''une autre pour exister.

*Conclusion : trois propositions indépendantes, deux juxtaposées et une
coordonnée. La phrase est une phrase composée.*

*Une remarque qui vaut un point de plus si tu la fais : « car » relie bien deux
indépendantes, alors que « parce que », qui a presque le même sens, introduirait
au contraire une subordonnée. Le sens est proche, la nature est opposée.*
', NULL, 22),
    (v_chapitre_id, 'Simulation : juxtaposées ou coordonnées ?', 5, 'interactif', '{
  "widget": "juxtaposition-coordination",
  "consigne": "Tu reçois des propositions séparées et tu construis toi-même la phrase en choisissant le lien : une virgule, un point-virgule, ou l''une des sept conjonctions de coordination. La simulation affiche la phrase obtenue, nomme le procédé et vérifie que le sens tient — mets « car » là où il faudrait « mais » et elle te le signale. Un second volet te sert le piège qui coûte des points : « car » et « parce que » ont presque le même sens, et pourtant l''un coordonne quand l''autre subordonne."
}', NULL, 10),
    (v_chapitre_id, 'La phrase complexe : la subordination', 6, 'texte', '
Nous y voilà. Une proposition **dépend** d''une autre : la phrase est
**complexe**.

> Les voyageurs descendent dès que le car arrive.

Deux verbes conjugués, donc deux propositions. Mais applique le test de la leçon
précédente, celui de la séparation :

> Les voyageurs descendent. **Dès que le car arrive.**

La première tient. La seconde ne tient pas : « Dès que le car arrive » tout seul
n''est pas une phrase, on attend la suite. Elle **dépend** de l''autre.

### Le vocabulaire exact

La proposition qui tient toute seule est la **proposition principale**.
Celle qui dépend est la **proposition subordonnée**.

Le mot qui les relie est le **subordonnant** : *dès que*, *parce que*, *quand*,
*si*, *que*, *qui*, *lorsque*, *bien que*, *afin que*…

> [Les voyageurs descendent] **dès que** [le car arrive].
>   proposition principale              proposition subordonnée

### Reconnaître la subordonnée en un coup d''œil

Elle commence par un subordonnant, et elle ne peut pas vivre seule. Ces deux
signes vont toujours ensemble.

Attention, ne confonds pas :

*mais, ou, et, donc, or, ni, car* **coordonnent** : les propositions restent
indépendantes.

*parce que, quand, si, que, qui, bien que…* **subordonnent** : la seconde
proposition devient dépendante.

Le cas de *car* et *parce que* mérite qu''on s''arrête, parce qu''il tombe souvent.
Les deux expriment la cause, et pourtant :

> Je rentre **car** il pleut. → deux indépendantes, phrase **composée**.
> Je rentre **parce qu''**il pleut. → principale + subordonnée, phrase
> **complexe**.

Même sens, nature différente. Si tu dois nommer les propositions, ne te fie pas
au sens : regarde le mot de liaison.

### Les trois subordonnées du programme de 3ème

Tu les étudieras une par une dans les modules suivants, mais il est bon de
savoir dès maintenant qu''elles sont trois.

**La subordonnée relative**, introduite par *qui, que, dont, où* : elle complète
un nom.

> Le car **qui vient de Douala** est complet.

**La subordonnée complétive**, introduite par *que* : elle complète un verbe,
souvent comme complément d''objet direct.

> Je sais **que le car est complet**.

**La subordonnée circonstancielle**, introduite par *quand, parce que, si, bien
que…* : elle complète toute la phrase, comme un complément circonstanciel.

> Je rentrerai **quand le car arrivera**.

### Ce que le BEPC demande exactement

La question type, telle qu''elle est tombée en 2024, est celle-ci : *dans la
phrase suivante, identifiez les propositions et donnez leur nature*. Le corrigé
attendait :

> « Quand un Blanc est ruiné, la banque peut lui avancer de l''argent. »
> Principale : « la banque peut lui avancer de l''argent ».
> Subordonnée : « Quand un Blanc est ruiné », circonstancielle de temps.

Deux points, et une méthode en trois gestes : compter les verbes conjugués,
repérer le subordonnant, nommer.

---

**Exercice corrigé**

*Dire si chaque phrase est simple, composée ou complexe. Pour les complexes,
nommer la principale et la subordonnée.*

*1. Le marché ferme à dix-huit heures.*
*2. Le marché ferme à dix-huit heures, car les commerçants rentrent chez eux.*
*3. Le marché ferme à dix-huit heures parce que les commerçants rentrent chez
eux.*
*4. Le commerçant qui vend le poisson a fermé plus tôt.*

**Correction.**

*1.* Un seul verbe conjugué, *ferme*. Une proposition indépendante. Phrase
**simple**.

*2.* Deux verbes conjugués, *ferme* et *rentrent*. Le lien est **car**, une
conjonction de coordination. Je teste la séparation : « Le marché ferme à
dix-huit heures. Les commerçants rentrent chez eux. » Les deux tiennent. Donc
deux **indépendantes coordonnées**, phrase **composée**.

*3.* Deux verbes conjugués, les mêmes. Mais le lien est **parce que**, un
subordonnant. Je teste : « Parce que les commerçants rentrent chez eux » ne tient
pas seul. Donc phrase **complexe** :

> principale : « Le marché ferme à dix-huit heures »
> subordonnée : « parce que les commerçants rentrent chez eux », circonstancielle
> de cause

*4.* Deux verbes conjugués, *vend* et *a fermé*. Le lien est **qui**, un pronom
relatif, donc un subordonnant. Phrase **complexe** :

> principale : « Le commerçant a fermé plus tôt »
> subordonnée : « qui vend le poisson », relative, complément de l''antécédent
> « commerçant »

*Remarque la différence entre 2 et 3 : le sens est identique, et pourtant l''une
est composée et l''autre complexe. C''est la nature du mot de liaison qui décide,
jamais le sens.*

*Et remarque, en 4, que la principale est coupée en deux par la subordonnée. On
dit alors que la subordonnée est enchâssée. Pour la relever proprement, il faut
recoller les deux morceaux : « Le commerçant a fermé plus tôt ».*
', NULL, 26),
    (v_chapitre_id, 'Simulation : la question 5 du BEPC', 7, 'interactif', '{
  "widget": "propositions-bepc",
  "consigne": "C''est l''exercice de l''examen, dans sa forme exacte. Une phrase s''affiche, et tu dois faire les trois gestes dans l''ordre : surligner chaque proposition, nommer la principale et la subordonnée, puis donner la fonction de la subordonnée. La simulation note comme le ferait un correcteur, un demi-point par geste, et refuse les deux erreurs qui coûtent le plus : confondre « car » et « parce que », et oublier de recoller une principale coupée en deux par une subordonnée enchâssée. Douze phrases, dont quatre tirées de sessions réelles."
}', NULL, 10),
    (v_chapitre_id, 'Quiz du chapitre 2', 8, 'quiz', '{
  "titre": "Vérifie que tu as compris",
  "questions": [
    {
      "question": "Comment compte-t-on les propositions d''une phrase ?",
      "choix": [
        "On compte les virgules",
        "On compte les verbes conjugués : autant de verbes conjugués, autant de propositions",
        "On compte les mots de liaison",
        "On compte tous les verbes"
      ],
      "bonne": 1,
      "explication": "Tous les verbes, non : seulement les conjugués. Un infinitif ou un participe ne compte pas."
    },
    {
      "question": "« Mon père a décidé de réparer la moto. » Combien de propositions ?",
      "choix": [
        "Deux",
        "Une seule : « réparer » est à l''infinitif, donc non conjugué",
        "Trois",
        "Aucune"
      ],
      "bonne": 1,
      "explication": "C''est le piège le plus courant. La phrase est simple malgré ses deux verbes, et malgré sa longueur."
    },
    {
      "question": "Quelles sont les sept conjonctions de coordination ?",
      "choix": [
        "Quand, si, que, qui, dont, où, parce que",
        "Mais, ou, et, donc, or, ni, car",
        "Puis, ensuite, alors, enfin, cependant, pourtant, aussi",
        "À, de, par, pour, en, vers, chez"
      ],
      "bonne": 1,
      "explication": "On les retient avec « Mais où est donc Ornicar ? », qui les contient toutes dans l''ordre. Le troisième groupe, ce sont des adverbes de liaison."
    },
    {
      "question": "Quel test prouve que deux propositions sont indépendantes ?",
      "choix": [
        "Les lire à voix haute",
        "Essayer de les séparer en deux phrases : si les deux tiennent debout, elles sont indépendantes",
        "Compter leurs mots",
        "Chercher une virgule"
      ],
      "bonne": 1,
      "explication": "« Dès que le car arrive » tout seul ne tient pas : c''est donc une subordonnée, et la phrase est complexe."
    },
    {
      "question": "Quelle différence entre « car » et « parce que » ?",
      "choix": [
        "Aucune",
        "Même sens, mais « car » coordonne deux indépendantes et « parce que » introduit une subordonnée : l''une donne une phrase composée, l''autre une phrase complexe",
        "« Car » est familier",
        "« Parce que » est au passé"
      ],
      "bonne": 1,
      "explication": "C''est la nature du mot de liaison qui décide de la nature de la phrase, jamais le sens. Faire cette remarque en copie rapporte."
    },
    {
      "question": "Quelles sont les trois subordonnées au programme de 3ème ?",
      "choix": [
        "Déclarative, interrogative, exclamative",
        "Relative, complétive, circonstancielle",
        "Simple, composée, complexe",
        "Principale, coordonnée, juxtaposée"
      ],
      "bonne": 1,
      "explication": "La relative complète un nom, la complétive complète un verbe, la circonstancielle complète toute la phrase."
    },
    {
      "question": "« Le commerçant qui vend le poisson a fermé plus tôt. » Comment relever la principale ?",
      "choix": [
        "« Le commerçant »",
        "« Le commerçant a fermé plus tôt » : il faut recoller les deux morceaux, car la subordonnée est enchâssée",
        "« a fermé plus tôt »",
        "« qui vend le poisson »"
      ],
      "bonne": 1,
      "explication": "Une subordonnée enchâssée coupe la principale en deux. Oublier de la recoller est l''une des erreurs qui coûtent le plus à cette question."
    }
  ]
}', NULL, 5);

  RAISE NOTICE '8 leçons ajoutées au chapitre 2, Phrase simple, phrase composée, phrase complexe.';
END $fr3$;
