-- ---------------------------------------------------------------------------
-- M'Andal — Français, classe de 3ème
-- Chapitre 19 : Les homophones grammaticaux
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
  WHERE programme_id = v_programme_id AND ordre = 19;

  IF v_chapitre_id IS NULL THEN
    INSERT INTO public.chapitres (programme_id, titre, ordre, niveau)
    VALUES (v_programme_id, 'Les homophones grammaticaux', 19, 'Module 3 : La vie économique')
    RETURNING id INTO v_chapitre_id;
    RAISE NOTICE 'Chapitre 19 créé.';
  END IF;

  -- Les leçons. Si le chapitre en a déjà, on passe son tour sans rien toucher.
  SELECT count(*) INTO v_deja FROM public.concepts WHERE chapitre_id = v_chapitre_id;
  IF v_deja > 0 THEN
    RAISE NOTICE 'Le chapitre 19 a déjà ses % leçons, je n''y touche pas.', v_deja;
    RETURN;
  END IF;

  INSERT INTO public.concepts
    (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes) VALUES
    (v_chapitre_id, 'Les homophones grammaticaux : un couple, un test', 1, 'texte', '
Ce chapitre prépare la **question 3** du BEPC et, surtout, il règle la
catégorie de fautes la plus coûteuse de la rédaction. Deux points à l''examen,
et bien plus dans ta vie d''écriture.

### Quelle différence avec le chapitre 11 ?

Au chapitre 11, tu as vu les **homophones lexicaux** : des mots différents, qui
ont chacun leur entrée dans le dictionnaire — *ver, verre, vert, vers*.

Ici, ce sont les **homophones grammaticaux** : des formes qui appartiennent à
la grammaire. *a* et *à*, *ce* et *se*, *on* et *ont*. Elles n''ont pas d''entrée
de dictionnaire, elles ont une **fonction**.

Et la méthode change : au chapitre 11, la famille de mots tranchait. Ici, elle
ne sert à rien.

### Le principe : on ne retient pas des règles, on retient des remplacements

Voici l''idée qui fait tout le chapitre. Pour chaque couple, il existe **un
remplacement** qui tranche en trois secondes. Tu n''as pas besoin de savoir
nommer la nature du mot : tu as besoin de connaître le remplacement.

Un exemple, pour comprendre le mécanisme.

> « Il a faim. » / « Il va à Douala. »

Je remplace par **avait** :
> « Il **avait** faim. » ✓ → donc **a**, le verbe avoir.
> « Il va **avait** Douala. » ✗ → donc **à**, la préposition, avec son accent.

Trois secondes. Et je n''ai eu besoin de savoir ni ce qu''est un auxiliaire, ni
ce qu''est une préposition.

### Pourquoi ces fautes coûtent si cher

Parce qu''elles sont **très visibles**. Un correcteur qui lit « il va a Douala »
le voit avant même d''avoir lu la phrase. C''est le genre de faute qui donne
l''impression d''une copie bâclée, même quand les idées sont bonnes.

Et parce qu''elles sont **très fréquentes**. Les mots concernés sont parmi les
plus courants du français : *a*, *à*, *et*, *est*, *on*, *ont*, *ce*, *se*. Tu
les écris des dizaines de fois par copie.

### La liste à connaître

Je te la donne en entier, et nous la détaillerons dans les deux leçons
suivantes.

> **a / à**
> **on / ont / on n''**
> **son / sont**
> **est / et / ai / es**
> **ce / se / ceux**
> **c''est / s''est / ces / ses / sais / sait**
> **la / l''a / l''as / là**
> **leur / leurs**
> **peu / peut / peux**
> **quel / quelle / quels / quelles / qu''elle / qu''elles**
> **notre / nôtre, votre / vôtre**
> **plus tôt / plutôt** *(déjà vu au chapitre 11)*
> **quand / quant / qu''en** *(déjà vu au chapitre 11)*

Treize lignes. Si tu les maîtrises, tu as supprimé la moitié des fautes d''une
copie moyenne.

### Le geste de relecture

Tu le connais depuis le chapitre 11, et il vaut ici encore plus.

> 1. Je repère les mots à risque en relisant.
> 2. J''applique le remplacement du couple.
> 3. Je corrige si le remplacement échoue.

Cinq minutes de relecture, c''est largement cent tests. Et chaque test évité est
un point perdu.

---

**Exercice corrigé**

*Corriger ce paragraphe, en indiquant pour chaque faute le test employé.*

> *Mon frère a décidé de partir a Yaoundé. Il ma dit qu''il reviendrait, mais on
> sais jamais. Ses parents sont inquiets, ces normal. Il n''as rien emporté, se
> qui m''étonne.*

**Correction.**

*« partir a Yaoundé » → partir **à** Yaoundé.*
Test : « partir **avait** Yaoundé » ne veut rien dire. Donc la préposition, avec
accent.

*« Il ma dit » → il **m''a** dit.*
Test : « il m''**avait** dit » fonctionne. Donc le verbe avoir, et le pronom
« me » élidé devant lui s''écrit avec une apostrophe.

*« on sais jamais » → on **ne sait** jamais.*
Deux fautes en trois mots. D''abord la personne : « on » est une troisième
personne du singulier — remplace-le par « il » — donc le verbe est **sait**, et
non « sais ». Ensuite, il manque le « ne » de la négation : à l''écrit, on écrit
toujours « on **ne** sait jamais ».

*« ces normal » → **c''est** normal.*
Test : « **cela est** normal » fonctionne. Donc *c''est*. « Ces » serait un
déterminant démonstratif pluriel, et il n''y a aucun nom pluriel derrière.

*« Il n''as rien emporté » → il n''**a** rien emporté.*
Test de personne : le sujet est « il », troisième personne, donc **a**. La forme
« as » appartient à « tu ». C''est une faute de personne, pas d''homophone au
sens strict — mais elle vient du même manque d''attention.

*« se qui m''étonne » → **ce** qui m''étonne.*
Test : « se » est toujours devant un verbe, et se remplace par « me » — « il
**se** lave » → « je **me** lave ». Ici, il n''y a pas de verbe pronominal : le
mot est devant le pronom relatif « qui ». C''est donc **ce**.

*Six fautes en quatre lignes, et chacune se corrigeait par un remplacement de
trois secondes. C''est exactement la densité d''une copie de BEPC qui n''a pas été
relue.*
', NULL, 26),
    (v_chapitre_id, 'Figure : un couple, un test', 2, 'figure', '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 580 340" width="580" height="340">
<rect width="580" height="340" fill="#ffffff"/>
<text x="290" y="24" text-anchor="middle" font-size="14" font-weight="700" fill="#0f172a">Un couple, un test. Et le test tient en trois secondes.</text>
<text x="290" y="42" text-anchor="middle" font-size="10" fill="#64748b">On ne retient pas des règles : on retient des remplacements.</text>

<rect x="20" y="56" width="540" height="34" rx="5" fill="#dbeafe" stroke="#2563eb" stroke-width="1.3"/>
<text x="36" y="70" font-size="10" font-weight="700" fill="#1e3a8a">a / à</text>
<text x="120" y="70" font-size="9" fill="#1e40af">je remplace par AVAIT</text>
<text x="300" y="70" font-size="9" font-style="italic" fill="#475569">« il a faim » → « il avait faim » ✓ donc A</text>
<text x="36" y="84" font-size="8.5" fill="#1e40af">si « avait » ne passe pas, c&apos;est la préposition À, avec son accent</text>

<rect x="20" y="96" width="540" height="34" rx="5" fill="#dcfce7" stroke="#15803d" stroke-width="1.3"/>
<text x="36" y="110" font-size="10" font-weight="700" fill="#14532d">on / ont</text>
<text x="120" y="110" font-size="9" fill="#166534">je remplace par AVAIENT</text>
<text x="300" y="110" font-size="9" font-style="italic" fill="#475569">« ils ont fini » → « ils avaient fini » ✓</text>
<text x="36" y="124" font-size="8.5" fill="#166534">ON se remplace aussi par IL : « on part » → « il part »</text>

<rect x="20" y="136" width="540" height="34" rx="5" fill="#fef3c7" stroke="#ca8a04" stroke-width="1.3"/>
<text x="36" y="150" font-size="10" font-weight="700" fill="#78350f">son / sont</text>
<text x="120" y="150" font-size="9" fill="#92400e">je remplace par ÉTAIENT</text>
<text x="300" y="150" font-size="9" font-style="italic" fill="#475569">« ils sont partis » → « ils étaient partis » ✓</text>
<text x="36" y="164" font-size="8.5" fill="#92400e">SON se remplace par MON : « son cahier » → « mon cahier »</text>

<rect x="20" y="176" width="540" height="34" rx="5" fill="#fce7f3" stroke="#be185d" stroke-width="1.3"/>
<text x="36" y="190" font-size="10" font-weight="700" fill="#831843">ce / se</text>
<text x="120" y="190" font-size="9" fill="#9d174d">SE est devant un VERBE</text>
<text x="300" y="190" font-size="9" font-style="italic" fill="#475569">« il se lave » → « je ME lave » ✓</text>
<text x="36" y="204" font-size="8.5" fill="#9d174d">CE est devant un NOM : « ce cahier » → « mon cahier »</text>

<rect x="20" y="216" width="540" height="34" rx="5" fill="#ede9fe" stroke="#6d28d9" stroke-width="1.3"/>
<text x="36" y="230" font-size="10" font-weight="700" fill="#4c1d95">c&apos;est / s&apos;est</text>
<text x="120" y="230" font-size="9" fill="#5b21b6">S&apos;EST se remplace par JE ME SUIS</text>
<text x="300" y="230" font-size="9" font-style="italic" fill="#475569">« il s&apos;est levé » → « je me suis levé » ✓</text>
<text x="36" y="244" font-size="8.5" fill="#5b21b6">C&apos;EST se remplace par CELA EST : « c&apos;est vrai » → « cela est vrai »</text>

<rect x="20" y="256" width="540" height="34" rx="5" fill="#fed7aa" stroke="#ea580c" stroke-width="1.3"/>
<text x="36" y="270" font-size="10" font-weight="700" fill="#7c2d12">ces / ses</text>
<text x="120" y="270" font-size="9" fill="#9a3412">SES se remplace par LES SIENS</text>
<text x="300" y="270" font-size="9" font-style="italic" fill="#475569">« ses cahiers » → « les siens » ✓</text>
<text x="36" y="284" font-size="8.5" fill="#9a3412">CES se remplace par CEUX-LÀ : « ces cahiers » → « ces cahiers-LÀ »</text>

<rect x="20" y="296" width="540" height="34" rx="5" fill="#f1f5f9" stroke="#64748b" stroke-width="1.3"/>
<text x="36" y="310" font-size="10" font-weight="700" fill="#0f172a">leur / leurs</text>
<text x="120" y="310" font-size="9" fill="#334155">devant un VERBE, LEUR est invariable</text>
<text x="36" y="324" font-size="8.5" fill="#334155">« je LEUR parle » → je LUI parle ✓ invariable  |  « leurs cahiers » → son cahier, donc pluriel</text>
</svg>', NULL, 5),
    (v_chapitre_id, 'Simulation : le test de chaque couple', 3, 'interactif', '{
  "widget": "tests-homophones-gram",
  "consigne": "Un couple s''affiche — a/à, on/ont, ce/se, c''est/s''est — et la simulation te donne d''abord son test de remplacement, puis te le retire et te laisse l''appliquer seul sur dix phrases. Elle note combien de fois tu as réussi sans l''aide, couple par couple, et te rend à la fin ta liste personnelle : les trois ou quatre qui te résistent, et qu''il faudra relire la veille de l''examen. Les treize couples du programme y passent."
}', NULL, 10),
    (v_chapitre_id, 'Les couples où un verbe se cache', 4, 'texte', '
Première famille, et la plus simple : dans chaque couple, l''un des deux mots
est un **verbe**. Le test est donc toujours le même — **changer le temps**.

### a / à

> **a** = le verbe *avoir*, troisième personne du singulier.
> **à** = la préposition, et elle porte l''accent.

*Test* : remplace par **avait**.

> Il **a** fini son devoir. → Il **avait** fini. ✓ → **a**
> Il va **à** l''école. → Il va **avait** l''école. ✗ → **à**

*Moyen de retenir l''accent : la préposition est le petit mot qui indique une
direction, et l''accent est une flèche.*

### on / ont — et le terrible « on n'' »

> **on** = le pronom indéfini sujet.
> **ont** = le verbe *avoir*, troisième personne du pluriel.

*Test* : remplace **on** par **il**, et **ont** par **avaient**.

> **On** part demain. → **Il** part demain. ✓ → **on**
> Ils **ont** fini. → Ils **avaient** fini. ✓ → **ont**

**Et maintenant le piège qui coûte le plus : « on n'' ».**

Quand la phrase est négative, « on » est suivi de **ne**, qui s''élide en **n''**
devant une voyelle. À l''oral, on ne l''entend pas du tout.

> **On n''**a rien vu. *(= on ne a rien vu)*
> **On n''**est jamais sûr.
> **On n''**y comprend rien.

*Test* : remplace « on » par « il » et écoute.
> « **Il n''**a rien vu » — le « n'' » s''entend très bien. Donc il faut l''écrire.

*Et le test inverse : mets la phrase à la forme affirmative. « On a tout vu » :
pas de négation, pas de « n'' ». « On n''a rien vu » : il y a « rien », donc il y
a une négation, donc il faut le « n'' ».*

**Les mots qui annoncent une négation** : *rien, jamais, plus, personne,
aucun, guère*. Dès que l''un d''eux apparaît après « on », cherche le « n'' ».

### son / sont

> **son** = le déterminant possessif.
> **sont** = le verbe *être*, troisième personne du pluriel.

*Test* : remplace **sont** par **étaient**, et **son** par **mon**.

> Ils **sont** partis. → Ils **étaient** partis. ✓ → **sont**
> **Son** cahier est neuf. → **Mon** cahier est neuf. ✓ → **son**

### est / et / ai / es

Quatre formes qui se ressemblent, et un test pour chacune.

> **est** = verbe *être*, 3e personne. Test : **était**.
> **et** = conjonction de coordination. Test : **et puis**.
> **ai** = verbe *avoir*, 1re personne. Test : **avais**.
> **es** = verbe *être*, 2e personne. Test : **étais**.

> Il **est** malade. → Il **était** malade. ✓
> Le riz **et** le poisson. → Le riz **et puis** le poisson. ✓
> J''**ai** compris. → J''**avais** compris. ✓
> Tu **es** prêt. → Tu **étais** prêt. ✓

### peu / peut / peux

> **peu** = l''adverbe de quantité. Test : **beaucoup**.
> **peut** = verbe *pouvoir*, 3e personne. Test : **pouvait**.
> **peux** = verbe *pouvoir*, 1re ou 2e personne. Test : **pouvais**.

> Il mange **peu**. → Il mange **beaucoup**. ✓ → **peu**
> Il **peut** venir. → Il **pouvait** venir. ✓ → **peut**

### la / l''a / l''as / là

> **la** = déterminant ou pronom. Test : **une** ou **le**.
> **l''a / l''as** = pronom + verbe *avoir*. Test : **l''avait / l''avais**.
> **là** = adverbe de lieu. Test : **ici**.

> **La** porte est fermée. → **Une** porte est fermée. ✓ → **la**
> Il **l''a** vue. → Il **l''avait** vue. ✓ → **l''a**
> Pose-le **là**. → Pose-le **ici**. ✓ → **là**

---

**Exercice corrigé**

*Compléter, et dire le test employé à chaque fois.*

*1. Mon oncle … décidé de partir … Garoua.*
*2. Ils … rentrés tard ; … mère était inquiète.*
*3. … … rien compris … ce qu''il … dit.*
*4. Il … venir, mais il … de temps.*

**Correction.**

*1.* « Mon oncle **a** décidé » — test : *mon oncle avait décidé* ✓. « partir
**à** Garoua » — test : *partir avait Garoua* ✗.

> Mon oncle **a** décidé de partir **à** Garoua.

*2.* « Ils **sont** rentrés » — test : *ils étaient rentrés* ✓. « **sa** mère
était inquiète » — attention, ici le possessif attendu est *sa*, féminin, parce
que « mère » est féminin. Si l''exercice voulait *son*, il faudrait un nom
masculin.

> Ils **sont** rentrés tard ; **sa** mère était inquiète.

*3.* Trois difficultés d''affilée.

« **On n''**a rien compris » — il y a « rien », donc une négation, donc le
« n'' ». Test : *il n''a rien compris*, et le « n'' » s''entend.

« compris **à** ce qu''il **a** dit » — *à* est la préposition après
« comprendre à » ; *a* est le verbe, test : *ce qu''il avait dit* ✓.

> **On n''**a rien compris **à** ce qu''il **a** dit.

*C''est la phrase la plus difficile du chapitre : elle contient un « on n'' », un
« à » préposition et un « a » verbe en douze mots. Si tu la réussis, tu tiens
toute la famille.*

*4.* « Il **peut** venir » — test : *il pouvait venir* ✓. « il a **peu** de
temps » — test : *il a beaucoup de temps* ✓.

> Il **peut** venir, mais il a **peu** de temps.
', NULL, 28),
    (v_chapitre_id, 'Simulation : le « a » et le « on n'' »', 5, 'interactif', '{
  "widget": "a-ou-a",
  "consigne": "Les deux couples qui coûtent le plus, traités à fond. Pour a/à, la simulation réécrit ta phrase avec « avait » et te laisse juger si elle tient. Pour on/ont/on n'', elle fait deux choses que personne ne fait : elle remplace « on » par « il » pour te faire entendre le « n'' », et elle surligne en rouge les mots qui annoncent une négation — rien, jamais, plus, personne, aucun. Vingt-quatre phrases, dont huit où le « n'' » manque et où rien ne s''entend à l''oral."
}', NULL, 10),
    (v_chapitre_id, 'Les couples où rien n''est un verbe', 6, 'texte', '
Seconde famille : déterminants, pronoms, adjectifs. Le test du changement de
temps ne sert plus. Il faut d''autres remplacements, et ils sont tout aussi
mécaniques.

### ce / se

> **ce** = déterminant démonstratif, devant un **nom**. Ou pronom, devant
> *qui*, *que*, *dont*.
> **se** = pronom réfléchi, devant un **verbe**.

*Test pour se* : remplace par **me** et mets à la première personne.

> Il **se** lave. → Je **me** lave. ✓ → **se**
> **Ce** cahier est neuf. → Je **me** cahier ? ✗ → **ce**

*Test pour ce* : remplace par **le** ou **mon**.

> **Ce** cahier → **Mon** cahier ✓
> **Ce** qui m''étonne → le fait qui m''étonne ✓

*Et retiens la règle courte : **SE est toujours collé à un verbe**. S''il n''y a
pas de verbe juste derrière, c''est CE.*

### c''est / s''est / ces / ses / sais / sait

Six formes qui se prononcent presque pareil. C''est le groupe le plus redouté,
et il se règle avec quatre remplacements.

> **c''est** = cela est. Test : **cela est**.
> **s''est** = pronom réfléchi + être. Test : **je me suis**.
> **ces** = déterminant démonstratif pluriel. Test : ajouter **-là**.
> **ses** = déterminant possessif pluriel. Test : **les siens**.
> **sais / sait** = verbe *savoir*. Test : **savais / savait**.

> **C''est** vrai. → **Cela est** vrai. ✓
> Il **s''est** levé. → **Je me suis** levé. ✓
> **Ces** cahiers-là. → **Ces** cahiers **-là** ✓
> **Ses** cahiers → **les siens** ✓
> Il **sait** nager. → Il **savait** nager. ✓

*La confusion la plus fréquente est **ces / ses**, et elle se règle toujours
par le sens : « ces » montre, « ses » appartient.*

> J''ai rangé **ses** affaires. *(les affaires de quelqu''un)*
> J''ai rangé **ces** affaires. *(celles-là, que je montre)*

### leur / leurs

Voici la règle la plus mal connue du français, et elle est pourtant simple.

**Devant un VERBE, « leur » est un pronom, et il est INVARIABLE.**

> Je **leur** parle. Je **leur** ai dit. Il **leur** donne.

*Test* : remplace par **lui**. Si « lui » passe, c''est le pronom, et il ne
prend **jamais** de s.

> Je **leur** parle → Je **lui** parle ✓ → invariable

**Devant un NOM, « leur » est un déterminant, et il s''accorde.**

> **Leur** cahier *(un cahier chacun)* / **Leurs** cahiers *(plusieurs)*

*Test* : remplace par **son/sa** au singulier, **ses** au pluriel.

> **Leur** cahier → **son** cahier ✓ singulier
> **Leurs** cahiers → **ses** cahiers ✓ pluriel

*La faute la plus répandue : « je leurs ai dit ». Devant un verbe, jamais de s.
Jamais.*

### quel / quelle / quels / quelles / qu''elle / qu''elles

> **quel, quelle, quels, quelles** = adjectif interrogatif ou exclamatif, et il
> s''accorde avec le nom.
> **qu''elle, qu''elles** = la conjonction *que* + le pronom *elle*.

*Test* : remplace par **qu''il**. Si cela fonctionne, c''est **qu''elle** en deux
mots.

> Je crois **qu''elle** viendra. → Je crois **qu''il** viendra. ✓ → **qu''elle**
> **Quelle** heure est-il ? → **Qu''il** heure est-il ? ✗ → **quelle**

### notre / nôtre, votre / vôtre

> **notre, votre** = déterminants possessifs, devant un nom, sans accent.
> **nôtre, vôtre** = pronoms possessifs, avec l''article, et avec l''accent
> circonflexe.

> **Notre** maison est là. *(déterminant)*
> Cette maison est **la nôtre**. *(pronom, précédé de l''article)*

*Test* : s''il y a « le », « la » ou « les » juste devant, il faut l''accent.

---

**Exercice corrigé**

*Corriger ce texte, et nommer le test employé pour chaque correction.*

> *Les commerçants du marché ses sont réunis hier. Ils leurs ont demandé de
> revoir ces tarifs. Quel que soit la décision, ils disent que c''est trop tard
> et qu''elles ne changeront rien. Se qui compte, disent-ils, se sont les
> familles.*

**Correction.**

*« ses sont réunis » → **se** sont réunis.*
Test : il y a un verbe juste derrière — *sont réunis* — donc c''est le pronom
réfléchi **se**. Vérification : « je **me** suis réuni » ✓.

*« Ils leurs ont demandé » → ils **leur** ont demandé.*
Test : devant le verbe *ont demandé*. Remplace par *lui* : « ils **lui** ont
demandé » ✓. Donc pronom, donc **invariable**, sans s. C''est la faute la plus
répandue du français écrit.

*« revoir ces tarifs » → revoir **leurs** tarifs, ou **ces** tarifs.*
Les deux sont possibles selon le sens ! Si l''on parle des tarifs des
commerçants, c''est **leurs**. Si l''on montre des tarifs dont on vient de
parler, c''est **ces**. Le texte parle des commerçants, donc **leurs tarifs**.

*C''est le cas où aucun test mécanique ne suffit : il faut lire le sens. Les
tests tranchent entre les formes, ils ne pensent pas à ta place.*

*« Quel que soit la décision » → **Quelle** que soit la décision.*
L''adjectif s''accorde avec « décision », féminin singulier. Et il s''écrit en
deux mots dans cette tournure.

*« qu''elles ne changeront rien » → correct.*
Test : « **qu''ils** ne changeront rien » ✓. C''est bien *que + elles*, en deux
mots.

*« Se qui compte » → **Ce** qui compte.*
Test : il n''y a pas de verbe juste derrière mais le pronom relatif *qui*. Donc
**ce**.

*« se sont les familles » → **ce** sont les familles.*
Test : remplace par *cela* — « **cela** est les familles », maladroit mais
compréhensible. Et surtout, « je **me** suis les familles » ✗. Donc **ce**.

*Les deux derniers mots du texte sont le même piège, à deux lignes d''écart, et
l''un des deux est devant un verbe. C''est exactement ce qu''un correcteur pose.*
', NULL, 28),
    (v_chapitre_id, 'Simulation : la dictée grammaticale', 7, 'interactif', '{
  "widget": "dictee-grammaticale",
  "consigne": "Un texte s''affiche, ses homophones grammaticaux surlignés, et tu valides ou tu corriges chacun. Pour chaque mot, la simulation applique le test devant toi : elle réécrit la phrase avec « avait », avec « il », avec « lui », avec « cela est », et tu juges. Huit textes de longueur croissante, dont trois de sujets de BEPC. Un cas y est volontairement insoluble par le test seul — deux formes y sont grammaticalement possibles, et seul le sens tranche : c''est la leçon la plus utile du chapitre."
}', NULL, 10),
    (v_chapitre_id, 'Quiz du chapitre 19', 8, 'quiz', '{
  "titre": "Vérifie que tu as compris",
  "questions": [
    {
      "question": "Quelle différence entre homophones lexicaux et grammaticaux ?",
      "choix": [
        "Aucune",
        "Les lexicaux sont des mots du dictionnaire (ver, verre, vert) ; les grammaticaux sont des formes de grammaire (a/à, ce/se) qui ont une fonction",
        "Les grammaticaux sont plus longs",
        "Les lexicaux sont plus rares"
      ],
      "bonne": 1,
      "explication": "Et la méthode change : pour les lexicaux, la famille de mots tranche ; pour les grammaticaux, elle ne sert à rien. Il faut un remplacement."
    },
    {
      "question": "Quel test tranche entre « a » et « à » ?",
      "choix": [
        "Compter les lettres",
        "Remplacer par « avait » : si la phrase tient, c''est le verbe « a » ; sinon c''est la préposition « à »",
        "Lire à voix haute",
        "Mettre au pluriel"
      ],
      "bonne": 1,
      "explication": "« Il avait faim » ✓ donc « il a faim ». « Il va avait Douala » ✗ donc « il va à Douala »."
    },
    {
      "question": "Pourquoi écrit-on « On n''a rien vu » et non « On a rien vu » ?",
      "choix": [
        "C''est une coquetterie",
        "Parce que la phrase est négative : « rien » annonce la négation, et le « ne » s''élide en « n'' » — qu''on n''entend pas à l''oral",
        "Parce que « on » est pluriel",
        "C''est facultatif"
      ],
      "bonne": 1,
      "explication": "Test : remplace « on » par « il » et écoute — « il n''a rien vu », le « n'' » s''entend très bien. Les mots qui annoncent une négation : rien, jamais, plus, personne, aucun, guère."
    },
    {
      "question": "Comment distinguer « ce » et « se » ?",
      "choix": [
        "Au hasard",
        "SE est toujours collé à un verbe et se remplace par « me » ; s''il n''y a pas de verbe juste derrière, c''est CE",
        "SE est plus court",
        "CE est toujours en début de phrase"
      ],
      "bonne": 1,
      "explication": "« Il se lave » → « je me lave » ✓. « Ce qui m''étonne » : il y a le pronom « qui », pas un verbe pronominal, donc CE."
    },
    {
      "question": "« Je leur ai dit » ou « je leurs ai dit » ?",
      "choix": [
        "Leurs, car ils sont plusieurs",
        "Leur, invariable : devant un VERBE c''est un pronom, et on le vérifie en le remplaçant par « lui »",
        "Les deux se valent",
        "Cela dépend du verbe"
      ],
      "bonne": 1,
      "explication": "« Je lui ai dit » ✓, donc pronom, donc jamais de s. Devant un NOM au contraire il s''accorde : « leurs cahiers », comme « ses cahiers »."
    },
    {
      "question": "Quel test distingue « quelle » de « qu''elle » ?",
      "choix": [
        "L''accent",
        "Remplacer par « qu''il » : si cela fonctionne, c''est « qu''elle » en deux mots",
        "Compter les syllabes",
        "Regarder le genre"
      ],
      "bonne": 1,
      "explication": "« Je crois qu''il viendra » ✓ donc « qu''elle viendra ». « Qu''il heure est-il ? » ✗ donc « quelle heure »."
    },
    {
      "question": "Que faire quand deux formes sont toutes deux grammaticalement possibles ?",
      "choix": [
        "Prendre la plus courte",
        "Lire le sens : les tests tranchent entre les formes, ils ne pensent pas à ta place",
        "Prendre celle du début",
        "Laisser un blanc"
      ],
      "bonne": 1,
      "explication": "« Revoir ces tarifs » et « revoir leurs tarifs » sont tous deux corrects, et ne disent pas la même chose. Seul le contexte décide."
    }
  ]
}', NULL, 5);

  RAISE NOTICE '8 leçons ajoutées au chapitre 19, Les homophones grammaticaux.';
END $fr3$;
