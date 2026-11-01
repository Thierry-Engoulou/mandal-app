-- ---------------------------------------------------------------------------
-- M'Andal — Français, classe de 3ème
-- Chapitre 18 : Le discours rapporté
-- Module 3 : La vie économique — 8 leçons
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
  WHERE programme_id = v_programme_id AND ordre = 18;

  IF v_chapitre_id IS NULL THEN
    INSERT INTO public.chapitres (programme_id, titre, ordre, niveau)
    VALUES (v_programme_id, 'Le discours rapporté', 18, 'Module 3 : La vie économique')
    RETURNING id INTO v_chapitre_id;
    RAISE NOTICE 'Chapitre 18 créé.';
  END IF;

  -- Les leçons. Si le chapitre en a déjà, on passe son tour sans rien toucher.
  SELECT count(*) INTO v_deja FROM public.concepts WHERE chapitre_id = v_chapitre_id;
  IF v_deja > 0 THEN
    RAISE NOTICE 'Le chapitre 18 a déjà ses % leçons, je n''y touche pas.', v_deja;
    RETURN;
  END IF;

  INSERT INTO public.concepts
    (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes) VALUES
    (v_chapitre_id, 'Le discours direct : faire entendre les voix', 1, 'texte', '
Nous passons de la grammaire de la phrase à celle du récit. Rapporter les
paroles de quelqu''un est l''un des gestes les plus fréquents de l''écriture, et
l''un des plus mal maîtrisés.

Ce chapitre prépare la **question 3** du BEPC — la nature et la fonction — et
il sert tout autant à ta rédaction.

### Les quatre façons de rapporter

Il y en a quatre, et chacune produit un effet différent.

**Le discours DIRECT** reproduit les mots exacts.
> Il m''a dit : « Je viendrai te voir demain. »

**Le discours INDIRECT** les rapporte dans une subordonnée.
> Il m''a dit qu''il viendrait me voir le lendemain.

**Le discours INDIRECT LIBRE** les mêle au récit, sans subordonnée ni
guillemets.
> Il viendrait me voir le lendemain. Il me l''avait promis.

**Le discours NARRATIVISÉ** les résume en un mot.
> Il m''annonça sa visite.

### Le discours direct, et sa ponctuation

C''est le plus vivant, et c''est celui dont la ponctuation est la plus exigeante.
Voici les règles, et elles se voient dans une copie.

**Les deux-points et les guillemets ouvrants** annoncent la parole.
> Il m''a dit : « Je viendrai. »

**Le tiret** marque chaque changement d''interlocuteur dans un dialogue.
> — Tu viens au marché ?
> — Pas aujourd''hui.
> — Pourquoi ?

**Les guillemets fermants** closent la parole, après le point.
> « Je viendrai te voir demain. »

**Le verbe introducteur peut se placer ailleurs**, et il s''inverse alors.
> « Je viendrai, **dit-il**, dès que j''aurai fini. »
> « Je viendrai », **répondit-il**.

*Note l''inversion du sujet : « dit-il », et non « il dit ». C''est la marque
écrite de l''incise, et beaucoup d''élèves l''oublient.*

**Quand la parole se termine par un point d''interrogation ou d''exclamation**,
celui-ci reste à l''intérieur des guillemets.
> « Viens-tu ? » demanda-t-elle.

### Les verbes de parole

Un conseil qui vaudra des points : **varie les verbes introducteurs**. Une
copie où tout le monde « dit » est une copie pauvre.

> **neutres** : dire, déclarer, répondre, ajouter, reprendre
> **avec un volume** : murmurer, chuchoter, crier, hurler, souffler
> **avec une intention** : expliquer, objecter, protester, avouer, promettre,
> menacer, supplier
> **avec un sentiment** : soupirer, s''exclamer, grommeler, s''étonner

> « Je viendrai », **promit-il**. ≠ « Je viendrai », **grommela-t-il**.

Le même énoncé, et deux scènes différentes. Le verbe introducteur fait la
moitié du travail.

### Pourquoi choisir le direct

Parce qu''il **ralentit le récit** et met le lecteur dans la scène. On l''emploie
au moment important : la dispute, l''aveu, la décision.

Si tout ton récit est au discours direct, rien ne ressort. Garde-le pour les
moments qui comptent, et rapporte le reste autrement.

---

**Exercice corrigé**

*Ponctuer correctement ce dialogue, et remplacer les verbes introducteurs
répétés.*

> *Le chauffeur a dit le car ne partira pas avant une heure. Un passager a dit
> mais vous aviez annoncé six heures. Le chauffeur a dit je ne pars pas à
> moitié vide. Alors remboursez-nous a dit le passager.*

**Correction.**

> Le chauffeur **annonça** : « Le car ne partira pas avant une heure. »
>
> — Mais vous aviez annoncé six heures ! **protesta** un passager.
>
> — Je ne pars pas à moitié vide, **répondit** le chauffeur.
>
> — Alors remboursez-nous, **lança** le passager.

*Ce qui a changé, point par point.*

**Les deux-points et les guillemets** ouvrent la première parole.

**Les tirets** marquent ensuite chaque changement d''interlocuteur : c''est la
présentation normale d''un dialogue, et elle dispense de répéter les guillemets.

**L''inversion du sujet dans les incises** : « protesta un passager »,
« répondit le chauffeur ». À l''écrit, le sujet passe derrière le verbe.

**Le point d''exclamation** reste collé à la parole qu''il concerne, avant
l''incise.

**Les verbes introducteurs** : annonça, protesta, répondit, lança. Le texte de
départ employait quatre fois « a dit ». Chacun des quatre verbes nouveaux
apporte en plus une information sur le ton — et aucun n''est inventé pour
l''occasion : ils décrivent ce que le passage raconte déjà.

*Un dernier point, souvent oublié : la virgule avant l''incise. « Je ne pars pas
à moitié vide, répondit le chauffeur. » Sans cette virgule, la phrase ne tient
pas.*
', NULL, 26),
    (v_chapitre_id, 'Figure : du direct à l''indirect', 2, 'figure', '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 580 300" width="580" height="300">
<rect width="580" height="300" fill="#ffffff"/>
<text x="290" y="24" text-anchor="middle" font-size="14" font-weight="700" fill="#0f172a">Passer du direct à l&apos;indirect : quatre choses changent</text>

<rect x="20" y="40" width="540" height="46" rx="6" fill="#dbeafe" stroke="#2563eb" stroke-width="1.5"/>
<text x="36" y="58" font-size="10" font-weight="700" fill="#1e3a8a">DISCOURS DIRECT — les mots exacts, entre guillemets</text>
<text x="36" y="76" font-size="10" font-style="italic" fill="#1e40af">Il m&apos;a dit : « Je viendrai te voir demain. »</text>

<line x1="290" y1="88" x2="290" y2="106" stroke="#64748b" stroke-width="1.6"/>
<polygon points="290,112 284,100 296,100" fill="#64748b"/>

<rect x="20" y="118" width="130" height="62" rx="6" fill="#dcfce7" stroke="#15803d" stroke-width="1.3"/>
<text x="85" y="136" text-anchor="middle" font-size="9" font-weight="700" fill="#14532d">1. LA PONCTUATION</text>
<text x="85" y="152" text-anchor="middle" font-size="8" fill="#166534">plus de deux-points,</text>
<text x="85" y="164" text-anchor="middle" font-size="8" fill="#166534">plus de guillemets</text>
<text x="85" y="176" text-anchor="middle" font-size="8" font-weight="700" fill="#15803d">→ « que »</text>

<rect x="158" y="118" width="130" height="62" rx="6" fill="#fef3c7" stroke="#ca8a04" stroke-width="1.3"/>
<text x="223" y="136" text-anchor="middle" font-size="9" font-weight="700" fill="#78350f">2. LES PRONOMS</text>
<text x="223" y="154" text-anchor="middle" font-size="8" fill="#92400e">je → il</text>
<text x="223" y="166" text-anchor="middle" font-size="8" fill="#92400e">tu → moi, me</text>
<text x="223" y="178" text-anchor="middle" font-size="8" fill="#92400e">mon → son</text>

<rect x="296" y="118" width="130" height="62" rx="6" fill="#fce7f3" stroke="#be185d" stroke-width="1.3"/>
<text x="361" y="136" text-anchor="middle" font-size="9" font-weight="700" fill="#831843">3. LES TEMPS</text>
<text x="361" y="154" text-anchor="middle" font-size="8" fill="#9d174d">présent → imparfait</text>
<text x="361" y="166" text-anchor="middle" font-size="8" fill="#9d174d">futur → conditionnel</text>
<text x="361" y="178" text-anchor="middle" font-size="8" fill="#9d174d">passé comp. → plus-que-parfait</text>

<rect x="434" y="118" width="126" height="62" rx="6" fill="#ede9fe" stroke="#6d28d9" stroke-width="1.3"/>
<text x="497" y="136" text-anchor="middle" font-size="9" font-weight="700" fill="#4c1d95">4. LE TEMPS ET LE LIEU</text>
<text x="497" y="154" text-anchor="middle" font-size="8" fill="#5b21b6">demain → le lendemain</text>
<text x="497" y="166" text-anchor="middle" font-size="8" fill="#5b21b6">hier → la veille</text>
<text x="497" y="178" text-anchor="middle" font-size="8" fill="#5b21b6">ici → là</text>

<rect x="20" y="192" width="540" height="46" rx="6" fill="#dcfce7" stroke="#15803d" stroke-width="1.5"/>
<text x="36" y="210" font-size="10" font-weight="700" fill="#14532d">DISCOURS INDIRECT — rapporté dans une subordonnée</text>
<text x="36" y="228" font-size="10" font-style="italic" fill="#166534">Il m&apos;a dit qu&apos;il viendrait me voir le lendemain.</text>

<rect x="20" y="248" width="540" height="42" rx="6" fill="#fef3c7" stroke="#ca8a04" stroke-width="1.4"/>
<text x="290" y="266" text-anchor="middle" font-size="10" font-weight="700" fill="#78350f">LE PIÈGE : si le verbe introducteur est au PRÉSENT, rien ne bouge</text>
<text x="290" y="282" text-anchor="middle" font-size="9" font-style="italic" fill="#92400e">Il dit qu&apos;il viendra demain. — seuls les pronoms changent.</text>
</svg>', NULL, 5),
    (v_chapitre_id, 'Simulation : ponctuer un dialogue', 3, 'interactif', '{
  "widget": "ponctuer-dialogue",
  "consigne": "Un dialogue s''affiche sans aucune ponctuation, et tu poses les signes un par un : deux-points, guillemets, tirets, virgules d''incise, points d''interrogation. La simulation refuse les combinaisons impossibles et t''explique chacune. Un second atelier te fait remplacer les « il a dit » répétés par des verbes de parole — elle t''en propose une trentaine, rangés par volume, intention et sentiment, et elle te dit lequel change le sens de la scène. Huit dialogues, dont trois tirés de sujets de BEPC."
}', NULL, 10),
    (v_chapitre_id, 'Passer au discours indirect : les quatre changements', 4, 'texte', '
C''est l''exercice de transformation que l''examen pose le plus souvent. Il est
mécanique, et il s''apprend.

### Ce qui change, et dans quel ordre le vérifier

**1. La ponctuation disparaît, remplacée par un mot subordonnant.**

Les deux-points, les guillemets et les tirets s''effacent. Une subordonnée les
remplace.

> Il m''a dit : « Je viendrai. » → Il m''a dit **qu''**il viendrait.

Le mot subordonnant dépend du type de phrase rapportée, et c''est le point que
nous détaillerons à la fin.

**2. Les pronoms et les possessifs changent de personne.**

C''est logique : celui qui parle n''est plus le même.

> « **Je** viendrai **te** voir. » → Il m''a dit qu''**il** viendrait **me** voir.
> « C''est **mon** cahier. » → Il a dit que c''était **son** cahier.

**3. Les temps reculent — si le verbe introducteur est au passé.**

C''est la **concordance des temps**, et voici le tableau.

> présent → **imparfait** : « je viens » → qu''il **venait**
> futur simple → **conditionnel présent** : « je viendrai » → qu''il
> **viendrait**
> passé composé → **plus-que-parfait** : « je suis venu » → qu''il **était
> venu**
> imparfait → **imparfait**, il ne bouge pas
> plus-que-parfait → **plus-que-parfait**, il ne bouge pas non plus

**4. Les indications de temps et de lieu changent.**

> aujourd''hui → **ce jour-là**
> hier → **la veille**
> demain → **le lendemain**
> la semaine prochaine → **la semaine suivante**
> maintenant → **alors**
> ici → **là**

### Le piège qui sauve la moitié des points

**Si le verbe introducteur est au PRÉSENT, rien ne bouge dans les temps.**

> Il dit : « Je viendrai demain. » → Il dit qu''il **viendra demain**.

Seuls les pronoms changent. Les temps restent, les indications de temps
restent.

Compare :

> Il **dit** qu''il **viendra demain**. *(introducteur au présent)*
> Il **a dit** qu''il **viendrait le lendemain**. *(introducteur au passé)*

Beaucoup d''élèves appliquent la concordance partout. Regarde d''abord le verbe
introducteur : c''est lui qui commande.

### Les quatre types de phrases rapportées

Le mot subordonnant change selon ce qui est rapporté.

**Une DÉCLARATION → « que »**
> « Je viendrai. » → Il a dit **qu''**il viendrait.

**Une QUESTION TOTALE — celle qui appelle oui ou non → « si »**
> « Viens-tu ? » → Il m''a demandé **si** je venais.

**Une QUESTION PARTIELLE — avec un mot interrogatif → ce mot reste**
> « Quand pars-tu ? » → Il m''a demandé **quand** je partais.
> « Pourquoi ris-tu ? » → Il m''a demandé **pourquoi** je riais.

*Trois exceptions à connaître :*
> « Qu''est-ce que tu fais ? » → il m''a demandé **ce que** je faisais
> « Qu''est-ce qui se passe ? » → il m''a demandé **ce qui** se passait
> « Que fais-tu ? » → il m''a demandé **ce que** je faisais

*« Il m''a demandé qu''est-ce que je faisais » est une faute lourde, et elle est
partout à l''oral.*

**Un ORDRE → « de » + infinitif**
> « Pars ! » → Il m''a dit **de partir**.
> « Ne bouge pas. » → Il m''a dit **de ne pas bouger**.

C''est le seul cas où la subordonnée disparaît au profit d''un infinitif.

### Et l''inverse : de l''indirect au direct

L''examen le demande parfois. Fais les mêmes opérations en sens inverse, et
n''oublie pas la ponctuation.

> Il m''a demandé si je venais. → Il m''a demandé : « Viens-tu ? »

*Attention : en repassant au direct, la question retrouve son inversion de
sujet et son point d''interrogation.*

---

**Exercice corrigé**

*Mettre au discours indirect.*

*1. Il m''a dit : « Je t''attendrai ici jusqu''à demain. »*
*2. Elle m''a demandé : « As-tu fini ton devoir ? »*
*3. Le professeur nous a demandé : « Qu''est-ce que vous avez compris ? »*
*4. Ma mère m''a dit : « Ne rentre pas trop tard ! »*
*5. Il dit : « Je partirai demain. »*

**Correction.**

*1.* Introducteur au passé composé, donc concordance.

> *Pronoms* : « je » → il, « t'' » → me.
> *Temps* : futur « attendrai » → conditionnel **attendrait**.
> *Lieu et temps* : « ici » → là, « demain » → le lendemain.

> Il m''a dit **qu''il m''attendrait là jusqu''au lendemain**.

*2.* C''est une **question totale** : elle appelle oui ou non. Donc **si**.

> *Temps* : passé composé « as fini » → plus-que-parfait **avais fini**.

> Elle m''a demandé **si j''avais fini mon devoir**.

*Attention : pas de point d''interrogation. Une question rapportée indirectement
n''est plus une question : c''est une subordonnée, et la phrase se termine par un
point.*

*3.* C''est une **question partielle** avec « qu''est-ce que », donc le cas
particulier : **ce que**.

> Le professeur nous a demandé **ce que nous avions compris**.

*« Le professeur nous a demandé qu''est-ce que nous avions compris » est la
faute attendue. Elle est partout à l''oral, et elle coûte le point.*

*4.* C''est un **ordre**, donc **de** + infinitif. Et la négation se place
devant l''infinitif, en bloc.

> Ma mère m''a dit **de ne pas rentrer trop tard**.

*Pas de point d''exclamation non plus : l''ordre rapporté a perdu son
intonation.*

*5.* Et voici le piège. L''introducteur est au **présent** : « il dit ». Donc
**rien ne bouge** dans les temps ni dans les indications de temps.

> Il dit **qu''il partira demain**.

*Si tu as écrit « qu''il partirait le lendemain », tu as appliqué une
concordance que rien ne demandait. Regarde toujours le verbe introducteur avant
de toucher aux temps.*
', NULL, 28),
    (v_chapitre_id, 'Simulation : du direct à l''indirect', 5, 'interactif', '{
  "widget": "direct-indirect",
  "consigne": "Une phrase au discours direct s''affiche, et la simulation te fait passer les quatre changements dans l''ordre : la ponctuation et le subordonnant, les pronoms, les temps, les indications de temps et de lieu. À chaque étape, la phrase se réécrit devant toi et les mots changés s''allument. Avant les temps, elle te force à regarder le verbe introducteur : s''il est au présent, elle saute l''étape et te dit pourquoi. Vingt-quatre phrases couvrant les quatre types — déclaration, question totale, question partielle, ordre —, avec les trois cas de « ce que » et « ce qui », et six phrases à remettre au direct."
}', NULL, 10),
    (v_chapitre_id, 'L''indirect libre, et le choix du romancier', 6, 'texte', '
Dernière leçon du chapitre, et c''est celle qui te servira en lecture méthodique
autant qu''en rédaction.

### Le discours indirect libre

C''est la quatrième façon de rapporter, et la plus subtile. Les paroles ou les
pensées se fondent dans le récit : **ni guillemets, ni subordonnée, ni verbe
introducteur**.

> *Direct* : Il pensa : « Je n''y arriverai jamais. »
> *Indirect* : Il pensa qu''il n''y arriverait jamais.
> **Indirect libre** : Il n''y arriverait jamais. Pourquoi s''obstiner ?

### Comment le reconnaître

Il garde les **temps et les pronoms de l''indirect** — troisième personne,
imparfait, conditionnel — mais il garde l''**expressivité du direct** :
exclamations, questions, mots familiers, rythme de la parole.

Les marques à relever :

> **une question ou une exclamation** au milieu d''un récit à la troisième
> personne
> **un vocabulaire** qui n''est pas celui du narrateur mais du personnage
> **une interjection** : ah, eh bien, voyons
> **un rythme** haché, des phrases courtes

> « Il regarda le ciel. La pluie, encore. Est-ce que cela ne finirait jamais ? »

La question n''est pas posée par le narrateur : elle est dans la tête du
personnage. C''est de l''indirect libre.

### Pourquoi les romanciers l''emploient

Parce qu''il **supprime la distance** entre le lecteur et le personnage, sans
casser le récit.

Le discours direct oblige à s''arrêter, à ouvrir des guillemets, à nommer celui
qui parle. L''indirect libre glisse la pensée du personnage dans le flux du
récit, et le lecteur l''adopte sans s''en apercevoir.

C''est aussi un procédé **ambigu**, et c''est sa force : on ne sait pas toujours
si c''est le narrateur qui juge ou le personnage qui pense. Un auteur ironique
s''en sert beaucoup.

### Le discours narrativisé

La quatrième forme, et la plus rapide. Les paroles sont **résumées en un verbe**.

> Il m''annonça sa visite.
> Elle refusa.
> Ils se disputèrent toute la soirée.

Aucune parole n''est rapportée, et pourtant on sait qu''il y en a eu. C''est
l''outil de l''**accélération** du récit : on passe sur ce qui n''est pas
important.

### Le choix, selon ce qu''on veut faire

Voici le tableau qui te servira en rédaction, et en lecture méthodique.

> **DIRECT** — ralentit, met dans la scène, fait entendre la voix
> *à employer au moment important : la dispute, l''aveu, la décision*
>
> **INDIRECT** — met à distance, résume en restant précis
> *à employer pour les échanges utiles mais sans relief*
>
> **INDIRECT LIBRE** — supprime la distance avec la pensée du personnage
> *à employer pour l''intériorité, le doute, l''ironie*
>
> **NARRATIVISÉ** — accélère
> *à employer pour passer sur ce qui ne compte pas*

Un récit réussi les alterne. Une rédaction qui n''emploie qu''une seule forme est
plate, quelle que soit celle qu''elle a choisie.

### En lecture méthodique

On te demandera souvent : *quelle forme de discours l''auteur emploie-t-il dans
ce passage, et quel effet produit-elle ?*

Voici le moule de réponse :

> « L''auteur emploie le discours indirect libre, comme le montre la question
> "Est-ce que cela ne finirait jamais ?" (l. 12), qui conserve l''intonation de
> la parole mais la troisième personne et l''imparfait du récit. Ce procédé
> supprime la distance entre le lecteur et le personnage : nous suivons sa
> pensée de l''intérieur, sans que le narrateur ait besoin de la présenter. »

Nature du procédé, citation, caractérisation technique, effet. Quatre
mouvements, deux points.

---

**Exercice corrigé**

*Identifier la forme de discours employée dans chaque passage, justifier, puis
dire quel effet elle produit.*

*1. « Le chauffeur refusa de partir avant d''avoir rempli son car. »*

*2. « — Vous aviez dit six heures ! cria le passager. »*

*3. « Il regarda sa montre. Sept heures passées. Il n''arriverait jamais à temps
pour le contrôle. Et le professeur fermait la porte à la minute, tout le monde
le savait. »*

*4. « Il expliqua au passager qu''il ne partirait pas à moitié vide, et que
c''était ainsi depuis toujours. »*

**Correction.**

*1.* **Discours narrativisé.** Les paroles sont résumées en un verbe,
« refusa », sans qu''aucun mot du chauffeur ne soit rapporté.

*Effet* : l''accélération. On sait qu''il y a eu une discussion, et l''auteur ne
s''y attarde pas. C''est la forme à employer pour ce qui ne mérite pas de place.

*2.* **Discours direct.** Le tiret, les mots exacts, le point d''exclamation à
l''intérieur de la parole, l''incise avec inversion du sujet — « cria le
passager » — sont les quatre marques.

*Effet* : le ralentissement. On entend la voix, et la scène devient présente.
L''auteur l''a choisi pour le moment de la colère.

*3.* **Discours indirect libre.** C''est le passage à reconnaître, et voici les
marques.

> *Pas de guillemets, pas de subordonnée, pas de verbe introducteur* : rien
> n''annonce la pensée.
> *Troisième personne et conditionnel* — « il n''arriverait jamais » — ce sont
> les temps de l''indirect.
> *Mais l''expressivité du direct* : la phrase nominale « Sept heures passées »
> n''est pas du narrateur, c''est le constat du personnage. Et « tout le monde le
> savait » rapporte ce que le personnage se dit, pas ce que le narrateur
> affirme.

*Effet* : la distance disparaît. Nous ne lisons pas que le personnage
s''inquiète, nous nous inquiétons avec lui. Le narrateur s''efface derrière la
pensée du personnage.

*4.* **Discours indirect.** Verbe introducteur « expliqua », subordonnées en
« que », troisième personne, concordance des temps — « ne partirait pas »,
« c''était ».

*Effet* : la mise à distance. Le contenu est rapporté avec précision, mais on
n''entend plus la voix. L''auteur donne l''information sans donner la scène.

*Remarque pour finir : les quatre passages racontent le même épisode — un car
qui ne part pas. L''auteur a choisi chaque fois une forme différente selon ce
qu''il voulait faire ressentir. C''est exactement le choix que tu auras à faire
dans ta rédaction.*
', NULL, 26),
    (v_chapitre_id, 'Simulation : les quatre formes du même épisode', 7, 'interactif', '{
  "widget": "formes-discours",
  "consigne": "Un épisode court s''affiche — une dispute, un aveu, une annonce —, et quatre boutons : direct, indirect, indirect libre, narrativisé. À chaque clic, le passage se réécrit entièrement dans la forme choisie, et une jauge te montre ce que tu viens de faire au récit : le temps de lecture s''allonge ou raccourcit, la distance au personnage augmente ou disparaît. Puis l''exercice de l''examen : dix passages à identifier, avec les marques à relever et l''effet à nommer — et l''indirect libre y est le plus représenté, parce que c''est celui que personne ne reconnaît."
}', NULL, 10),
    (v_chapitre_id, 'Quiz du chapitre 18', 8, 'quiz', '{
  "titre": "Vérifie que tu as compris",
  "questions": [
    {
      "question": "Quelles sont les quatre façons de rapporter des paroles ?",
      "choix": [
        "Direct et indirect seulement",
        "Direct, indirect, indirect libre, narrativisé",
        "Écrit et oral",
        "Dialogue et monologue"
      ],
      "bonne": 1,
      "explication": "Chacune produit un effet différent : le direct ralentit, l''indirect met à distance, l''indirect libre supprime la distance avec la pensée, le narrativisé accélère."
    },
    {
      "question": "Dans une incise comme « dit-il », qu''est-ce qui se passe au sujet ?",
      "choix": [
        "Rien",
        "Il s''inverse et passe derrière le verbe : on écrit « dit-il », jamais « il dit » en incise",
        "Il disparaît",
        "Il se met au pluriel"
      ],
      "bonne": 1,
      "explication": "C''est la marque écrite de l''incise, et beaucoup d''élèves l''oublient. N''oublie pas non plus la virgule qui la précède."
    },
    {
      "question": "« Il m''a dit : Je viendrai demain. » Au discours indirect ?",
      "choix": [
        "Il m''a dit qu''il viendra demain",
        "Il m''a dit qu''il viendrait le lendemain : l''introducteur est au passé, donc concordance et changement des indications de temps",
        "Il m''a dit qu''il vient demain",
        "Il m''a dit de venir demain"
      ],
      "bonne": 1,
      "explication": "Futur → conditionnel présent, et « demain » → « le lendemain ». Quatre changements : ponctuation, pronoms, temps, indications de temps et de lieu."
    },
    {
      "question": "« Il dit : Je partirai demain. » Au discours indirect ?",
      "choix": [
        "Il dit qu''il partirait le lendemain",
        "Il dit qu''il partira demain : l''introducteur est au PRÉSENT, donc rien ne bouge dans les temps",
        "Il dit de partir demain",
        "Il dit s''il partira demain"
      ],
      "bonne": 1,
      "explication": "C''est le piège qui sauve la moitié des points. Beaucoup appliquent la concordance partout : regarde d''abord le verbe introducteur, c''est lui qui commande."
    },
    {
      "question": "« Qu''est-ce que tu fais ? » rapporté indirectement devient…",
      "choix": [
        "Il m''a demandé qu''est-ce que je faisais",
        "Il m''a demandé ce que je faisais",
        "Il m''a demandé si je faisais",
        "Il m''a demandé que je faisais"
      ],
      "bonne": 1,
      "explication": "« Qu''est-ce que » devient « ce que », et « qu''est-ce qui » devient « ce qui ». La forme avec « qu''est-ce que » est une faute lourde, et elle est partout à l''oral."
    },
    {
      "question": "Comment rapporte-t-on un ordre : « Pars ! » ?",
      "choix": [
        "Il m''a dit que je parte",
        "Il m''a dit DE PARTIR : c''est le seul cas où la subordonnée laisse la place à un infinitif",
        "Il m''a dit si je partais",
        "Il m''a dit que je partais"
      ],
      "bonne": 1,
      "explication": "Et la négation se place en bloc devant l''infinitif : « Ne bouge pas » devient « il m''a dit de ne pas bouger »."
    },
    {
      "question": "À quoi reconnaît-on le discours indirect libre ?",
      "choix": [
        "Aux guillemets",
        "Aux temps et pronoms de l''indirect — troisième personne, imparfait, conditionnel — mais à l''expressivité du direct : questions, exclamations, rythme de la parole",
        "Au verbe introducteur",
        "Aux tirets"
      ],
      "bonne": 1,
      "explication": "Ni guillemets, ni subordonnée, ni verbe introducteur. Il supprime la distance entre le lecteur et le personnage, et c''est pourquoi les romanciers l''emploient."
    }
  ]
}', NULL, 5);

  RAISE NOTICE '8 leçons ajoutées au chapitre 18, Le discours rapporté.';
END $fr3$;
