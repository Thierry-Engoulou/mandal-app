-- ---------------------------------------------------------------------------
-- M'Andal — Français, classe de 3ème
-- Chapitre 5 : Le champ lexical des sentiments
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
  WHERE programme_id = v_programme_id AND ordre = 5;

  IF v_chapitre_id IS NULL THEN
    INSERT INTO public.chapitres (programme_id, titre, ordre, niveau)
    VALUES (v_programme_id, 'Le champ lexical des sentiments', 5, 'Module 1 : La vie familiale et socioculturelle')
    RETURNING id INTO v_chapitre_id;
    RAISE NOTICE 'Chapitre 5 créé.';
  END IF;

  -- Les leçons. Si le chapitre en a déjà, on passe son tour sans rien toucher.
  SELECT count(*) INTO v_deja FROM public.concepts WHERE chapitre_id = v_chapitre_id;
  IF v_deja > 0 THEN
    RAISE NOTICE 'Le chapitre 5 a déjà ses % leçons, je n''y touche pas.', v_deja;
    RETURN;
  END IF;

  INSERT INTO public.concepts
    (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes) VALUES
    (v_chapitre_id, 'Le champ lexical, et ce qu''il n''est pas', 1, 'texte', '
Cette notion vaut **deux points à chaque session** du BEPC, à la question 2 de
la deuxième partie. L''énoncé est toujours le même : *relevez quatre mots ou
expressions appartenant au champ lexical de…*

Encore faut-il ne pas la confondre avec sa voisine.

### Définition

Un **champ lexical** est l''ensemble des mots d''un texte qui se rapportent à une
même idée, à un même thème.

> Il **tremblait**. Une **sueur** froide coulait dans son dos et son cœur
> **battait** à se rompre. Il n''osait pas **avancer**.

Les mots *tremblait*, *sueur froide*, *cœur battait*, *n''osait pas* appartiennent
tous au champ lexical de la **peur**. Pourtant, le mot « peur » n''apparaît nulle
part.

C''est le point important : **le champ lexical dit le thème sans le nommer**.

### Ne pas confondre avec la famille de mots

Une **famille de mots** rassemble des mots formés sur la même **racine**.

> *terre, terrain, terrasse, enterrer, déterrer, souterrain, atterrir*

Tous contiennent *terr*. C''est la **forme** qui les rassemble.

Un **champ lexical** rassemble des mots de **sens** voisin, quelle que soit leur
forme.

> *peur, trembler, pâlir, fuir, angoisse, effroi*

Aucune racine commune. C''est le **sens** qui les rassemble.

Retiens la formule : la famille de mots se voit **avec les yeux**, le champ
lexical se voit **avec la tête**.

Et note bien que les deux tombent au BEPC, mais à des questions différentes : le
champ lexical à la question 2, la famille de mots à la question 3, quand on te
demande de décomposer un mot et d''en trouver un de la même famille.

### Comment on relève un champ lexical, concrètement

Trois gestes, dans cet ordre.

**Un.** Lis l''énoncé et retiens le thème demandé : le commerce, la peur,
l''ordinateur, la ville.

**Deux.** Relis le texte avec ce seul thème en tête, et souligne tout ce qui s''y
rapporte — les noms, mais aussi les verbes, les adjectifs et les expressions.
C''est l''erreur la plus fréquente : on ne relève que des noms. Or *vendre* et
*cher* appartiennent au champ lexical du commerce autant que *marchand*.

**Trois.** Recopie le nombre exact de mots demandé, **entre guillemets**, et
pas un de plus. Si l''on t''en demande quatre et que tu en donnes huit, le
correcteur ne note que les quatre premiers — et si les deux premiers sont faux,
tu perds des points que tu avais.

---

**Exercice corrigé**

*Relever quatre mots ou expressions appartenant au champ lexical du marché dans
le texte suivant. Puis dire quel sentiment domine, en relevant trois éléments
de son champ lexical.*

> *Il était à peine six heures et déjà les étals débordaient. Les marchandes
> criaient leurs prix, les acheteurs marchandaient, et des porteurs se
> faufilaient entre les allées avec des sacs de riz sur la tête. Mariam avançait
> lentement. Sa poitrine se serrait. Elle n''avait que deux mille francs dans son
> pagne, et la liste de sa mère était longue. Ses mains devenaient moites.*

**Correction.**

*Le champ lexical du marché.* Je relis en ne cherchant que cela. Je trouve :
« les étals », « les marchandes », « leurs prix », « les acheteurs »,
« marchandaient », « les allées », « des sacs de riz », « deux mille francs ».

Il m''en faut quatre. J''en choisis quatre qui ne se ressemblent pas trop, pour
montrer que j''ai compris l''étendue du champ :

> « les étals », « les marchandes », « marchandaient », « les acheteurs ».

*Remarque que j''ai pris un verbe, « marchandaient ». Une liste de quatre noms
passe aussi, mais le verbe prouve que tu sais qu''un champ lexical n''est pas
seulement fait de noms.*

*Le sentiment dominant.* Il n''est jamais nommé. Pourtant il est partout dans la
seconde moitié du texte :

> « sa poitrine se serrait », « elle n''avait que deux mille francs », « ses mains
> devenaient moites ».

Le sentiment est **l''angoisse**, ou l''inquiétude. Le texte ne l''écrit pas : il
le fait **sentir** par le corps — la poitrine, les mains — et par la disproportion
entre la somme et la liste.

*C''est exactement ce que la question 4 de la première partie demande quand elle
porte sur les sentiments du narrateur : ne cherche pas le mot, cherche les
signes.*
', NULL, 24),
    (v_chapitre_id, 'Figure : champ lexical et famille de mots', 2, 'figure', '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 580 280" width="580" height="280">
<rect width="580" height="280" fill="#ffffff"/>
<text x="290" y="24" text-anchor="middle" font-size="14" font-weight="700" fill="#0f172a">Champ lexical ou famille de mots ? Ne les confonds pas.</text>

<rect x="20" y="44" width="260" height="212" rx="6" fill="#dbeafe" stroke="#2563eb" stroke-width="1.6"/>
<text x="150" y="66" text-anchor="middle" font-size="12" font-weight="700" fill="#1e3a8a">CHAMP LEXICAL</text>
<text x="150" y="82" text-anchor="middle" font-size="9" fill="#1e40af">des mots différents, une même idée</text>
<line x1="34" y1="92" x2="266" y2="92" stroke="#93c5fd"/>
<text x="150" y="112" text-anchor="middle" font-size="10" font-weight="700" fill="#1e3a8a">la peur</text>
<text x="150" y="134" text-anchor="middle" font-size="10" fill="#1e40af">trembler · pâlir · fuir</text>
<text x="150" y="152" text-anchor="middle" font-size="10" fill="#1e40af">angoisse · effroi · terreur</text>
<text x="150" y="170" text-anchor="middle" font-size="10" fill="#1e40af">sursauter · frisson</text>
<line x1="60" y1="186" x2="240" y2="186" stroke="#bfdbfe"/>
<text x="150" y="206" text-anchor="middle" font-size="9" fill="#1e3a8a">Les racines sont toutes différentes.</text>
<text x="150" y="222" text-anchor="middle" font-size="9" fill="#1e3a8a">C&apos;est le SENS qui les rassemble.</text>
<text x="150" y="244" text-anchor="middle" font-size="9" font-weight="700" fill="#7f1d1d">C&apos;est cela que le BEPC demande.</text>

<rect x="300" y="44" width="260" height="212" rx="6" fill="#fef3c7" stroke="#ca8a04" stroke-width="1.6"/>
<text x="430" y="66" text-anchor="middle" font-size="12" font-weight="700" fill="#78350f">FAMILLE DE MOTS</text>
<text x="430" y="82" text-anchor="middle" font-size="9" fill="#92400e">une même racine, des sens voisins</text>
<line x1="314" y1="92" x2="546" y2="92" stroke="#fde047"/>
<text x="430" y="112" text-anchor="middle" font-size="10" font-weight="700" fill="#78350f">la racine TERRE</text>
<text x="430" y="134" text-anchor="middle" font-size="10" fill="#92400e">terrain · terrasse · terrier</text>
<text x="430" y="152" text-anchor="middle" font-size="10" fill="#92400e">enterrer · déterrer · terrestre</text>
<text x="430" y="170" text-anchor="middle" font-size="10" fill="#92400e">atterrir · souterrain</text>
<line x1="340" y1="186" x2="520" y2="186" stroke="#fef08a"/>
<text x="430" y="206" text-anchor="middle" font-size="9" fill="#78350f">On retrouve « terr » dans chacun.</text>
<text x="430" y="222" text-anchor="middle" font-size="9" fill="#78350f">C&apos;est la FORME qui les rassemble.</text>
<text x="430" y="244" text-anchor="middle" font-size="9" font-weight="700" fill="#7f1d1d">C&apos;est la question 3 du BEPC.</text>
</svg>', NULL, 5),
    (v_chapitre_id, 'Simulation : la question 2 du BEPC', 3, 'interactif', '{
  "widget": "champ-lexical",
  "consigne": "Un texte s''affiche et on te demande de relever quatre mots d''un champ lexical précis. Tu cliques dans le texte, et la simulation compte pour toi. Elle refuse les mots hors du champ en te disant pourquoi, et elle te signale si tu n''as relevé que des noms — car un champ lexical contient aussi des verbes et des adjectifs. Un second volet mélange champ lexical et famille de mots dans le même texte : il faut trier, et c''est là que la plupart des candidats perdent leurs deux points."
}', NULL, 10),
    (v_chapitre_id, 'Nommer un sentiment avec précision', 4, 'texte', '
Au module 1, le programme te demande le champ lexical des **sentiments**, parce
que c''est celui de la vie familiale et socioculturelle : on y parle de ce qu''on
éprouve pour les siens.

Et il y a un vrai gain à la clé pour tes rédactions. « Il était content », « il
était triste », « il était en colère » : avec trois mots, on ne peut rien écrire.
Avec trente, on peut tout dire.

### Les six grandes familles

**La joie** : contentement, satisfaction, gaieté, allégresse, euphorie, bonheur,
jubilation, ravissement.

**La tristesse** : chagrin, peine, mélancolie, morosité, accablement, désespoir,
affliction, nostalgie.

**La colère** : agacement, irritation, énervement, exaspération, fureur, rage,
indignation, courroux.

**La peur** : inquiétude, appréhension, crainte, angoisse, frayeur, effroi,
terreur, panique.

**L''amour et l''attachement** : affection, tendresse, amitié, admiration,
attachement, dévotion, passion.

**La honte et le regret** : gêne, embarras, confusion, remords, regret,
culpabilité, humiliation.

### L''intensité change le mot

C''est là que ton vocabulaire devient précis. À l''intérieur d''une famille, les
mots ne sont pas interchangeables : ils se classent **du plus faible au plus
fort**.

Pour la colère :

> agacé → irrité → énervé → en colère → furieux → fou de rage

Pour la peur :

> inquiet → anxieux → effrayé → terrorisé → paniqué

Pour la tristesse :

> contrarié → peiné → triste → affligé → désespéré

Dans une rédaction, choisis le mot qui correspond vraiment. Écrire « il était
fou de rage » parce que son petit frère a pris son stylo, c''est se priver du mot
qu''il faudra le jour où le personnage apprendra une vraie mauvaise nouvelle.

### Les mots que le français a et que tu n''emploies pas

Trois sentiments ont, en français, un mot précis que les copies ignorent, et les
employer se remarque aussitôt.

**La nostalgie** : la tristesse douce qu''on éprouve en pensant à ce qui est
passé et ne reviendra pas. C''est le sentiment du village quitté, de l''enfance,
du grand-parent mort.

**Le soulagement** : la détente qui suit une peur, quand on apprend que le
danger est écarté.

**L''appréhension** : la peur **avant**, celle qui précède un examen ou une
annonce. On ne dit pas « j''avais peur de l''examen », on dit « j''appréhendais
l''examen ».

---

**Exercice corrigé**

*Remplacer chaque mot souligné par un terme plus précis, et justifier.*

*1. En revoyant la maison de son enfance, il était <u>triste</u>.*
*2. Avant d''entrer dans le bureau du proviseur, elle était <u>inquiète</u>.*
*3. Quand il apprit que son frère était sain et sauf, il était <u>content</u>.*
*4. Son petit frère avait cassé sa règle ; il était <u>en colère</u>.*

**Correction.**

*1. Nostalgique.* Ce n''est pas une tristesse quelconque : c''est celle qui naît du
souvenir d''un temps révolu. « Triste » décrit l''effet, « nostalgique » nomme
l''origine. On pourrait aussi écrire « ému » si l''on veut garder la douceur sans
la peine.

*2. Elle appréhendait cet entretien.* La peur ici porte sur quelque chose qui
n''est pas encore arrivé : c''est la définition de l''appréhension. « Inquiète »
n''est pas faux, mais il est vague — on peut être inquiet pour un absent, pour sa
santé, pour l''avenir.

*3. Soulagé.* Le texte dit bien ce qui précède : on craignait pour le frère. La
joie qui suit une peur écartée porte son nom.

*4. Agacé*, ou *contrarié*. Une règle cassée ne justifie ni la fureur ni la rage.
Employer « en colère » ici n''est pas une faute, mais c''est gaspiller : garde les
mots forts pour les situations fortes, sinon il ne te restera rien à écrire
quand il le faudra.

*Les quatre corrections ont le même principe : ne décris pas l''émotion en gros,
nomme-la exactement. Un correcteur de BEPC reconnaît en trois lignes une copie
qui dispose de son vocabulaire.*
', NULL, 22),
    (v_chapitre_id, 'Simulation : l''échelle des sentiments', 5, 'interactif', '{
  "widget": "nuancer-sentiment",
  "consigne": "Une situation t''est décrite — ton petit frère casse ta règle, tu apprends que ton oncle est sorti de l''hôpital, tu revois ta case d''enfance — et tu places le curseur sur une échelle d''intensité, de l''agacement à la fureur, de l''inquiétude à la panique. Le mot exact s''affiche sous le curseur. La simulation te dit ensuite si tu as visé juste : mets « fou de rage » pour une règle cassée et elle te fera remarquer qu''il ne te reste plus de mot pour la vraie colère. Vingt situations, six familles de sentiments."
}', NULL, 10),
    (v_chapitre_id, 'Montrer un sentiment sans le nommer', 6, 'texte', '
Voici le procédé qui transforme une rédaction. Les bons écrivains ne disent
presque jamais qu''un personnage a peur : ils **montrent** la peur, et le lecteur
la nomme lui-même.

### Trois manières de montrer

**Par le corps.** Le sentiment se voit, s''entend, se touche.

> *Il avait peur.*
> → Ses mains tremblaient. Sa gorge était sèche et il n''arrivait plus à avaler.

**Par l''action.** Le sentiment se devine à ce que fait le personnage.

> *Elle était en colère.*
> → Elle posa l''assiette si fort que la table en trembla, puis sortit sans
> refermer la porte.

**Par la comparaison et la métaphore.** Tu reverras ces figures au module 4.

> *Il était triste.*
> → Il se sentait vide, comme une case abandonnée après le départ des siens.

### Le détail vaut mieux que l''adjectif

Compare ces deux phrases :

> Ma grand-mère était très contente de me revoir.

> Ma grand-mère ne dit rien. Elle posa ses deux mains sur mes joues, longtemps,
> et je sentis qu''elles tremblaient un peu.

La seconde est plus longue de quelques mots, et elle vaut dix fois la première.
Elle ne contient aucun mot de sentiment, et pourtant tout y est.

### Quand nommer, quand montrer

Ne crois pas qu''il faille bannir les mots de sentiment. La règle pratique est
celle-ci :

**Montre** les sentiments importants, ceux sur lesquels ton récit repose.
**Nomme** les sentiments secondaires, pour ne pas alourdir.

Si tu montres tout, ton texte devient une devinette. Si tu nommes tout, il
devient plat. Alterne, comme tu alternes l''imparfait et le passé simple.

### Et pour l''étude de texte

Ce procédé te sert aussi en **lecture**, à la question 4 de la première partie :
*quels sentiments le narrateur exprime-t-il dans ce paragraphe ?*

Le texte ne contiendra presque jamais le mot. Tu devras le déduire des signes du
corps, des actions et des images. Et dans ta réponse, tu feras les deux choses :
tu **nommes** le sentiment, puis tu **cites** le signe qui te l''a fait trouver.

> Le narrateur exprime du découragement : « il laissa retomber ses bras » et
> « à quoi bon, pensa-t-il ».

Nommer sans citer ne vaut qu''un point sur deux. Citer sans nommer non plus.

---

**Exercice corrigé**

*Réécrire ce passage en remplaçant chaque mot de sentiment par une expression
indirecte. Le texte final ne doit contenir aucun nom de sentiment.*

> *Awa était heureuse de retrouver son village. Mais en voyant la case de sa
> grand-mère fermée, elle fut très triste. Son oncle était gêné de devoir lui
> annoncer la nouvelle.*

**Correction.**

> *Awa descendit du car avant même qu''il se fût arrêté. Elle reconnut l''odeur de
> la terre mouillée, le manguier, le cri des enfants, et elle se mit à marcher
> plus vite sans s''en apercevoir.*
>
> *Puis elle vit la case de sa grand-mère. La porte était fermée par une planche
> clouée en travers. Elle resta là, son sac à la main, et ne le posa pas.*
>
> *Son oncle s''approcha, s''arrêta à deux pas, ôta son chapeau et le tourna
> plusieurs fois entre ses doigts avant de parler.*

*Examinons ce qui a été fait.*

*Pour la joie :* aucun mot de joie. Elle est dans l''**action** — descendre avant
l''arrêt, marcher plus vite sans s''en apercevoir — et dans les **sensations** —
l''odeur, le cri des enfants. Un personnage heureux remarque le monde autour de
lui.

*Pour la tristesse :* aucun mot non plus. Elle est dans une **immobilité** et
dans un **détail** : elle ne pose pas son sac. Ce geste manqué dit tout, parce
qu''il montre qu''elle n''est pas encore capable de s''installer dans ce qui
arrive.

*Pour la gêne de l''oncle :* le chapeau tourné entre les doigts, l''arrêt à deux
pas. Ce sont des gestes que chacun reconnaît sans qu''on les explique.

*Remarque enfin la planche clouée en travers. Un seul détail concret porte toute
la nouvelle : personne n''a eu besoin de dire que la grand-mère était morte.*
', NULL, 22),
    (v_chapitre_id, 'Simulation : montrer au lieu de dire', 7, 'interactif', '{
  "widget": "montrer-sentiment",
  "consigne": "Une phrase plate s''affiche — « il était triste », « elle avait peur », « il était gêné » — et tu dois la remplacer en assemblant des propositions : un geste du corps, une action, un détail de décor, une comparaison. La simulation construit le passage devant toi et te montre ce que chaque choix ajoute. Elle refuse ceux qui nomment encore le sentiment, et te signale le piège de l''excès : montre tout et ton texte devient une devinette. Un second volet fait l''inverse — un texte littéraire s''affiche, et tu dois nommer le sentiment puis citer le signe qui te l''a fait trouver, comme à la question 4 du BEPC."
}', NULL, 10),
    (v_chapitre_id, 'Quiz du chapitre 5', 8, 'quiz', '{
  "titre": "Vérifie que tu as compris",
  "questions": [
    {
      "question": "Qu''est-ce qu''un champ lexical ?",
      "choix": [
        "Des mots formés sur la même racine",
        "L''ensemble des mots d''un texte qui se rapportent à une même idée, quelle que soit leur forme",
        "Les mots difficiles d''un texte",
        "Les synonymes d''un mot"
      ],
      "bonne": 1,
      "explication": "La famille de mots se voit avec les yeux — la racine commune ; le champ lexical se voit avec la tête — le sens commun."
    },
    {
      "question": "« terre, terrain, enterrer, souterrain » : qu''est-ce que c''est ?",
      "choix": [
        "Un champ lexical",
        "Une famille de mots : tous contiennent la racine « terr »",
        "Des synonymes",
        "Des homophones"
      ],
      "bonne": 1,
      "explication": "Les deux tombent au BEPC, mais à des questions différentes : le champ lexical à la question 2, la famille de mots à la question 3."
    },
    {
      "question": "Quelle est l''erreur la plus fréquente quand on relève un champ lexical ?",
      "choix": [
        "En relever trop peu",
        "Ne relever que des noms, alors qu''il contient aussi des verbes, des adjectifs et des expressions",
        "Recopier le texte",
        "Utiliser des guillemets"
      ],
      "bonne": 1,
      "explication": "« Vendre » et « cher » appartiennent au champ lexical du commerce autant que « marchand »."
    },
    {
      "question": "Que signifie « appréhender » quelque chose ?",
      "choix": [
        "Le comprendre",
        "Avoir peur de ce qui n''est pas encore arrivé",
        "Le regretter",
        "L''attendre avec joie"
      ],
      "bonne": 1,
      "explication": "On ne dit pas « j''avais peur de l''examen », on dit « j''appréhendais l''examen ». Et la joie qui suit une peur écartée s''appelle le soulagement."
    },
    {
      "question": "Classe du plus faible au plus fort : agacé, furieux, irrité, fou de rage.",
      "choix": [
        "furieux, agacé, irrité, fou de rage",
        "agacé, irrité, furieux, fou de rage",
        "irrité, agacé, fou de rage, furieux",
        "fou de rage, furieux, irrité, agacé"
      ],
      "bonne": 1,
      "explication": "Garde les mots forts pour les situations fortes. Écrire « fou de rage » pour une règle cassée, c''est se priver du mot qu''il faudra plus tard."
    },
    {
      "question": "Quelles sont les trois manières de montrer un sentiment sans le nommer ?",
      "choix": [
        "Le répéter, le souligner, l''écrire en majuscules",
        "Par le corps, par l''action, par la comparaison",
        "Par un adverbe, un adjectif, un nom",
        "Par le dialogue uniquement"
      ],
      "bonne": 1,
      "explication": "« Ses mains tremblaient » vaut mieux que « il avait peur ». Mais ne montre pas tout : un texte où rien n''est nommé devient une devinette."
    },
    {
      "question": "À la question 4 du BEPC, sur les sentiments du narrateur, que doit contenir ta réponse ?",
      "choix": [
        "Le nom du sentiment, seulement",
        "Une citation, seulement",
        "Le nom du sentiment ET la citation du signe qui te l''a fait trouver",
        "Ton propre avis"
      ],
      "bonne": 1,
      "explication": "Nommer sans citer ne vaut qu''un point sur deux. Citer sans nommer non plus. Les deux ensemble valent les deux points."
    }
  ]
}', NULL, 5);

  RAISE NOTICE '8 leçons ajoutées au chapitre 5, Le champ lexical des sentiments.';
END $fr3$;
