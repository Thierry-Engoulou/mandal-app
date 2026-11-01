-- ---------------------------------------------------------------------------
-- M'Andal — Français, classe de 3ème
-- Chapitre 11 : Les homophones lexicaux
-- Module 2 : Citoyenneté et environnement — 8 leçons
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
  WHERE programme_id = v_programme_id AND ordre = 11;

  IF v_chapitre_id IS NULL THEN
    INSERT INTO public.chapitres (programme_id, titre, ordre, niveau)
    VALUES (v_programme_id, 'Les homophones lexicaux', 11, 'Module 2 : Citoyenneté et environnement')
    RETURNING id INTO v_chapitre_id;
    RAISE NOTICE 'Chapitre 11 créé.';
  END IF;

  -- Les leçons. Si le chapitre en a déjà, on passe son tour sans rien toucher.
  SELECT count(*) INTO v_deja FROM public.concepts WHERE chapitre_id = v_chapitre_id;
  IF v_deja > 0 THEN
    RAISE NOTICE 'Le chapitre 11 a déjà ses % leçons, je n''y touche pas.', v_deja;
    RETURN;
  END IF;

  INSERT INTO public.concepts
    (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes) VALUES
    (v_chapitre_id, 'Les homophones lexicaux : quand l''oreille ne sert à rien', 1, 'texte', '
Ce chapitre prépare la **question 1** et la **question 3** de la seconde partie
du BEPC — le sens d''un mot, et la formation des mots. Chacune vaut **deux
points**.

### Deux sortes d''homophones

Des **homophones** sont des mots qui se prononcent de la même manière mais ne
s''écrivent pas pareil et n''ont pas le même sens.

On les sépare en deux familles, et il ne faut pas les confondre.

Les **homophones lexicaux** sont des mots différents, qui ont chacun leur
entrée dans le dictionnaire : *ver, verre, vert, vers*. C''est l''objet de ce
chapitre.

Les **homophones grammaticaux** sont des formes qui appartiennent à la
grammaire : *a / à*, *ce / se*, *ces / ses*, *on / ont*. Tu les verras au
chapitre 19, au module 3.

### Pourquoi c''est difficile

Parce que **l''oreille ne peut rien pour toi**. Les quatre mots *ver, verre,
vert, vers* se prononcent exactement de la même façon. Aucune dictée, aucune
relecture à voix haute ne te sauvera.

Il faut donc un autre outil, et il y en a deux.

### Premier outil : la nature du mot

Regarde la place du mot dans la phrase et demande-toi ce qu''il est.

> Il est allé **vers** la ville. → c''est une **préposition**, elle introduit un
> complément. Seul *vers* est une préposition.

> Une robe **verte**. → le mot s''accorde avec « robe », donc c''est un
> **adjectif**. Seul *vert* est un adjectif.

> Je bois un **verre** d''eau. → il y a un article devant, donc c''est un **nom**.

Cette seule question élimine déjà la moitié des candidats.

### Second outil : la famille de mots

C''est le meilleur, et c''est celui qu''il faut installer comme réflexe. **Cherche
un mot de la même famille, dans lequel la lettre muette se prononce.**

> *verre* → **verr**ier, **verr**erie, **verr**ière → deux r
> *vert* → **verd**ir, **verd**ure, **verd**âtre → un d, qu''on entend dans
> *verdir*
> *vers* → **vers**ification, **vers**ifier
> *ver* → **ver**mine, **ver**misseau

Le mot de la famille fait entendre ce que le mot seul cachait. C''est la
méthode des grands orthographiens, et elle marche presque toujours.

### Le même outil pour le genre

> *un* ver, *un* verre, *un* vers — mais *la* verdure, *la* verrerie.

Quand tu doutes, essaie l''article. Si « un » sonne mieux que « une », ton mot
est masculin, et cela t''oriente.

---

**Exercice corrigé**

*Compléter par le mot qui convient, et justifier par la nature et par la
famille.*

*1. Le maçon a posé la dernière … de la maison. (pierre / …)*
*2. Nous marchions … le marché quand la pluie a commencé.*
*3. Ce mangue n''est pas mûre, elle est encore ….*
*4. Récite-moi les quatre premiers … de ce poème.*
*5. Un … de terre est sorti après l''averse.*

**Correction.**

*2.* Le mot est suivi d''un groupe nominal, « le marché », et il introduit une
direction. C''est donc une **préposition** : seul *vers* en est une.

> Nous marchions **vers** le marché quand la pluie a commencé.

*3.* Le mot suit « elle est » et s''accorde avec « mangue », féminin. C''est donc
un **adjectif** : seul *vert* est un adjectif, et il prend ici un e.

> Elle est encore **verte**.

*La famille le confirme : si je dis « la mangue verdit », j''entends le d.*

*4.* Il y a un déterminant, « les quatre premiers », et il s''agit de lignes de
poème. C''est un **nom masculin pluriel**, et c''est *vers*.

> Récite-moi les quatre premiers **vers** de ce poème.

*La famille le confirme : versification, versifier.*

*5.* Il y a un article, « un », et le mot désigne un animal. C''est **ver**.

> Un **ver** de terre est sorti après l''averse.

*La famille le confirme : vermine, vermisseau — un seul r, pas de d, pas de s.*

*Tu remarqueras qu''à aucun moment je n''ai écouté la phrase. Les quatre mots
sonnent pareil. C''est la nature qui a trié, et la famille qui a confirmé.*
', NULL, 26),
    (v_chapitre_id, 'Figure : un son, quatre mots', 2, 'figure', '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 580 300" width="580" height="300">
<rect width="580" height="300" fill="#ffffff"/>
<text x="290" y="24" text-anchor="middle" font-size="14" font-weight="700" fill="#0f172a">Un seul son, quatre mots : [vɛʁ]</text>
<text x="290" y="42" text-anchor="middle" font-size="10" fill="#64748b">L&apos;oreille ne peut rien. Seuls le sens et la famille de mots décident.</text>

<ellipse cx="290" cy="70" rx="58" ry="17" fill="#fef3c7" stroke="#ca8a04" stroke-width="1.5"/>
<text x="290" y="76" text-anchor="middle" font-size="13" font-weight="700" fill="#78350f">[ v ɛ ʁ ]</text>

<line x1="252" y1="84" x2="90" y2="116" stroke="#94a3b8" stroke-width="1.2"/>
<line x1="276" y1="88" x2="222" y2="116" stroke="#94a3b8" stroke-width="1.2"/>
<line x1="304" y1="88" x2="358" y2="116" stroke="#94a3b8" stroke-width="1.2"/>
<line x1="328" y1="84" x2="490" y2="116" stroke="#94a3b8" stroke-width="1.2"/>

<rect x="20" y="118" width="128" height="86" rx="6" fill="#dbeafe" stroke="#2563eb" stroke-width="1.4"/>
<text x="84" y="138" text-anchor="middle" font-size="13" font-weight="700" fill="#1e3a8a">le ver</text>
<text x="84" y="156" text-anchor="middle" font-size="9" fill="#1e40af">l&apos;animal</text>
<line x1="34" y1="166" x2="134" y2="166" stroke="#93c5fd"/>
<text x="84" y="182" text-anchor="middle" font-size="8" fill="#1e40af">vermine, vermisseau</text>
<text x="84" y="195" text-anchor="middle" font-size="8" font-style="italic" fill="#475569">un ver de terre</text>

<rect x="158" y="118" width="128" height="86" rx="6" fill="#dcfce7" stroke="#15803d" stroke-width="1.4"/>
<text x="222" y="138" text-anchor="middle" font-size="13" font-weight="700" fill="#14532d">le verre</text>
<text x="222" y="156" text-anchor="middle" font-size="9" fill="#166534">la matière, le récipient</text>
<line x1="172" y1="166" x2="272" y2="166" stroke="#86efac"/>
<text x="222" y="182" text-anchor="middle" font-size="8" fill="#166534">verrier, verrerie, verrière</text>
<text x="222" y="195" text-anchor="middle" font-size="8" font-style="italic" fill="#475569">un verre d&apos;eau</text>

<rect x="296" y="118" width="128" height="86" rx="6" fill="#fce7f3" stroke="#be185d" stroke-width="1.4"/>
<text x="360" y="138" text-anchor="middle" font-size="13" font-weight="700" fill="#831843">vert</text>
<text x="360" y="156" text-anchor="middle" font-size="9" fill="#9d174d">la couleur — adjectif</text>
<line x1="310" y1="166" x2="410" y2="166" stroke="#fbcfe8"/>
<text x="360" y="182" text-anchor="middle" font-size="8" fill="#9d174d">verdure, verdir, verdâtre</text>
<text x="360" y="195" text-anchor="middle" font-size="8" font-style="italic" fill="#475569">un fruit vert, une robe verte</text>

<rect x="434" y="118" width="128" height="86" rx="6" fill="#ede9fe" stroke="#6d28d9" stroke-width="1.4"/>
<text x="498" y="138" text-anchor="middle" font-size="13" font-weight="700" fill="#4c1d95">vers</text>
<text x="498" y="156" text-anchor="middle" font-size="9" fill="#5b21b6">préposition, ou ligne de poème</text>
<line x1="448" y1="166" x2="548" y2="166" stroke="#ddd6fe"/>
<text x="498" y="182" text-anchor="middle" font-size="8" fill="#5b21b6">versification, versifier</text>
<text x="498" y="195" text-anchor="middle" font-size="8" font-style="italic" fill="#475569">aller vers la ville</text>

<rect x="20" y="218" width="542" height="66" rx="6" fill="#f1f5f9" stroke="#64748b" stroke-width="1.4"/>
<text x="291" y="238" text-anchor="middle" font-size="11" font-weight="700" fill="#0f172a">LA MÉTHODE EN DEUX GESTES</text>
<text x="40" y="258" font-size="9" fill="#334155">1. Je regarde la NATURE : est-ce un nom, un adjectif, une préposition ?</text>
<text x="40" y="274" font-size="9" fill="#334155">2. Je cherche un mot de la même FAMILLE : verdir me donne « vert », verrier me donne « verre ».</text>
</svg>', NULL, 5),
    (v_chapitre_id, 'Simulation : le mot qui convient', 3, 'interactif', '{
  "widget": "homophone-contexte",
  "consigne": "Une phrase à trou s''affiche, et les trois ou quatre homophones possibles. Avant de te laisser choisir, la simulation te fait répondre à une seule question : quelle est la nature du mot attendu — nom, adjectif, verbe, préposition ? Dès que tu réponds, elle grise les candidats qui n''ont pas cette nature, et il n''en reste souvent qu''un. Vingt phrases, et les familles les plus fréquentes du français y passent."
}', NULL, 10),
    (v_chapitre_id, 'Les grandes familles à connaître par cœur', 4, 'texte', '
Il y a quelques dizaines de couples ou de trios qui reviennent sans cesse. Les
voici, rangés, avec à chaque fois le mot de la famille qui tranche.

### Les plus fréquents à l''écrit

**cour / cours / court / courre**

> la **cour** de l''école, la **cour** du roi → *courtisan, courette*
> un **cours** de français, le **cours** d''eau → *parcours*
> il **court** vite, un chemin **court** → *courir, courte*
> la chasse à **courre** → rare, à ne pas confondre

**mer / mère / maire**

> la **mer** est calme → *maritime, marin*
> ma **mère** → *maternel*
> le **maire** de la ville → *mairie*

**sang / cent / sans / sent**

> le **sang** rouge → *sanguin, saigner*
> **cent** francs → *centaine, centime*
> il est parti **sans** moi → préposition, aucun complément possible
> il **sent** la fatigue → verbe *sentir*, je peux changer le temps : il
> *sentait*

**conte / compte / comte**

> un **conte** africain → *conter, raconter*
> le **compte** en banque, je **compte** sur toi → *compter, comptable*
> le **comte** et la comtesse → *comté*

**voie / voix / vois**

> la **voie** ferrée, une **voie** sans issue → *voyage, convoi*
> une belle **voix** → *vocal, vocalise*
> je **vois** le car → verbe *voir*, je peux dire *il voit*

### Les pièges du français d''Afrique centrale

Certains mots s''écrivent différemment mais se prononcent chez nous d''une façon
très proche. Ouvre l''œil.

**pêcheur / pécheur**

> le **pêcheur** sort son filet → *pêche, pêcher le poisson*
> le **pécheur** demande pardon → *péché, pécher*

Un accent circonflexe au lieu d''un accent aigu, et on passe de la pirogue à
l''église.

**censé / sensé**

> il est **censé** venir — c''est-à-dire : on le suppose → famille de *censeur*
> une décision **sensée** — c''est-à-dire : pleine de bon sens → famille de
> *sens*

**amende / amande**

> payer une **amende** au commissariat
> manger une **amande**

### Les paronymes : presque pareil, pas tout à fait

Ce ne sont pas des homophones — ils ne se prononcent pas exactement pareil —
mais on les confond tout autant, et le correcteur les sanctionne.

> **conjecture** (une supposition) / **conjoncture** (la situation économique)
> **éminent** (illustre) / **imminent** (sur le point d''arriver)
> **collision** (un choc) / **collusion** (une entente secrète)
> **affection** (un sentiment) / **affectation** (une nomination, ou un air
> faux)
> **original** (nouveau, inventif) / **originel** (qui vient de l''origine)

---

**Exercice corrigé**

*Corriger les erreurs de cette lettre, et justifier chacune.*

> *Monsieur le Maire,*
> *Je vous écrit au nom des habitants de notre quartier. La cour d''eau qui
> traverse le village déborde chaque saison, et sent mauvais. Nous sommes sencés
> payer une amande si nous jetons nos ordures, ce qui est sensé ; mais la
> municipalité, elle, ne fait rien. Dans la conjecture actuelle, une décision
> est imminente.*

**Correction.**

*« la cour d''eau » → le **cours** d''eau.* La cour est l''espace d''une école ou
d''un palais. Le cours d''eau est celui qui coule : la famille le confirme, un
*parcours*, un *concours*. Et le mot est **masculin** : *le* cours, ce qui
oblige à corriger l''article.

*« et sent mauvais » → correct.* C''est le verbe *sentir*, troisième personne du
singulier. Vérification : au passé, *il sentait mauvais*. La phrase accepte le
changement de temps, donc c''est bien un verbe.

*« nous sommes sencés » → **censés**.* Le sens est « on nous suppose devoir
payer ». C''est la famille de *censeur*, de *recensement*. Et il faut un c, pas
un s.

*« payer une amande » → une **amende**.* On ne paie pas un fruit au
commissariat. L''amende est la sanction, avec un e.

*« ce qui est sensé » → correct.* Ici le sens est « plein de bon sens », donc
*sensé*, de la famille de *sens*.

*Remarque la finesse de la phrase : « censés » et « sensé » y voisinent à six
mots d''écart, et il faut les écrire différemment. C''est exactement le genre de
phrase qu''un correcteur aime poser.*

*« dans la conjecture actuelle » → la **conjoncture**.* La conjecture est une
supposition. La conjoncture est la situation du moment, celle dont on parle
ici. C''est un paronyme, et la confusion est très répandue dans la presse.

*« une décision est imminente » → correct.* La décision est sur le point
d''arriver : c''est bien *imminente*. Si on avait voulu dire qu''elle est
illustre, ce serait *éminente* — mais cela n''aurait pas de sens pour une
décision.
', NULL, 28),
    (v_chapitre_id, 'Simulation : remonter à la famille', 5, 'interactif', '{
  "widget": "famille-de-mots",
  "consigne": "Un mot s''affiche avec sa lettre muette cachée, et tu dois retrouver le mot de la même famille qui la fait entendre. « verd… » attend verdir, « verr… » attend verrier. Dès que tu trouves, la lettre apparaît dans le mot de départ. Dix-huit mots, et la simulation garde la trace de ceux où tu as hésité : c''est ta liste personnelle à relire la veille de l''examen."
}', NULL, 10),
    (v_chapitre_id, 'Les écrire juste sous la dictée', 6, 'texte', '
Dernière leçon du chapitre, et c''est celle de l''épreuve réelle. Au BEPC, les
homophones ne sont pas interrogés dans un exercice à part : ils sont dans le
texte, dans ta rédaction, et chaque faute coûte.

### Les trois gestes de la relecture

Quand tu relis ta copie, tu n''as pas le temps de tout vérifier. Concentre-toi
sur ces trois gestes, dans cet ordre.

**Geste 1 : repérer les mots à risque.** Tu les connais maintenant. Passe sur
ta copie et entoure mentalement tous les *cour/cours*, *ce/se*, *sang/sans*,
*voie/voix*. Il y en a toujours trois ou quatre dans une page.

**Geste 2 : donner la nature.** Pour chacun, dis-toi ce qu''il est. Un verbe ?
Essaie de changer le temps. Un nom ? Essaie de mettre un article. Un adjectif ?
Essaie de l''accorder au féminin.

**Geste 3 : appeler la famille.** Si le doute persiste, cherche le mot de la
même famille. Il tranche presque toujours.

### Le test du changement de temps

C''est le plus efficace, et il règle à lui seul tous les homophones qui cachent
un verbe.

> Il **sent** la fatigue. → Il **sentait** la fatigue. ✓ verbe.
> Il est parti **sans** moi. → Il est parti **sentait** moi ? ✗ pas un verbe.

> Elle **compte** ses billets. → Elle **comptait** ses billets. ✓ verbe.
> Un **conte** africain. → Un **contait** africain ? ✗ pas un verbe.

Si le mot accepte de changer de temps, c''est un verbe. Sinon, c''est autre
chose.

### Les mots que tu écriras cette année

Voici la liste que je te conseille de recopier et de garder. Ce sont les
homophones qui tombent le plus souvent dans les sujets de BEPC, parce qu''ils
sont les plus fréquents du français écrit.

> cour / cours / court
> mer / mère / maire
> sang / cent / sans / sent
> voie / voix / vois
> conte / compte / comte
> ver / verre / vert / vers
> tache / tâche
> pêcheur / pécheur
> dessin / dessein
> foi / foie / fois
> tant / temps / tend
> plutôt / plus tôt
> quand / quant / qu''en

Treize lignes. Si tu les maîtrises, tu as couvert la quasi-totalité de ce que
l''examen peut demander.

### Trois cas qu''il faut détailler

**tache / tâche.** L''accent circonflexe change tout. Une *tache* est une
salissure ; une *tâche* est un travail à faire. Moyen de retenir : l''accent
circonflexe est le chapeau de celui qui travaille.

**plutôt / plus tôt.** En un mot, cela veut dire « de préférence » : *je
prendrai plutôt le car*. En deux mots, c''est le contraire de « plus tard » :
*je suis arrivé plus tôt que prévu*. Le test : remplace par « plus tard ». Si
la phrase tient, écris **plus tôt** en deux mots.

**quand / quant / qu''en.** *Quand* marque le temps — *quand tu viendras*. *Quant
à* veut dire « en ce qui concerne » — *quant à moi, je reste*. *Qu''en* est la
contraction de « que en » — *qu''en penses-tu ?*. Le test : remplace par
« lorsque ». Si la phrase tient, c''est **quand**.

---

**Exercice corrigé**

*Dictée à corriger. Treize mots sont soulignés ; six sont faux.*

> *Dès qu''en arrive la saison des pluies, le court d''eau déborde. Les pêcheurs
> ne sortent plus leurs pirogues ; leur tâche devient impossible, et la boue
> fait des tâches sur les murs. Quand à nous, nous partons plutôt que d''habitude
> pour arriver au marché avant l''averse. J''ai confiance : ma foie est solide.*

**Correction.**

*« Dès qu''en arrive » → **quand**.* Test : je remplace par « lorsque ».
« Lorsque arrive la saison » tient debout. C''est donc *quand*, qui marque le
temps. *Qu''en* serait la contraction de « que en », et elle n''a aucun sens ici.

*« le court d''eau » → le **cours** d''eau.* Déjà vu à la leçon précédente ;
*court* est l''adjectif ou le verbe *courir*.

*« les pêcheurs » → correct.* Ils sortent des pirogues : ce sont bien ceux qui
pêchent le poisson, avec l''accent circonflexe.

*« leur tâche devient impossible » → correct.* Il s''agit de leur travail.
L''accent circonflexe est bien là.

*« la boue fait des tâches » → des **taches**.* Il s''agit ici de salissures,
pas de travaux. Pas d''accent.

*Les deux mots se suivent à une ligne d''écart, l''un avec accent, l''autre sans.
Encore une fois, c''est le genre de voisinage que le correcteur installe
volontiers.*

*« Quand à nous » → **Quant** à nous.* Test : je remplace par « lorsque ».
« Lorsque à nous » ne veut rien dire. Ce n''est donc pas *quand*. Le sens est
« en ce qui nous concerne » : c''est **quant à**, avec un t.

*« nous partons plutôt que d''habitude » → **plus tôt**.* Test : je remplace par
« plus tard ». « Nous partons plus tard que d''habitude » tient parfaitement
debout. Donc deux mots.

*« ma foie est solide » → ma **foi**.* La *foi* est la croyance ; le *foie* est
l''organe. Et le mot est ici féminin — « ma » — alors que *le foie* est
masculin : l''article seul aurait dû alerter.

*Six fautes sur treize mots soulignés. C''est à peu près la proportion d''une
copie moyenne, et chacune se corrigeait par un test de trois secondes.*
', NULL, 26),
    (v_chapitre_id, 'Simulation : la dictée corrigée', 7, 'interactif', '{
  "widget": "dictee-homophones",
  "consigne": "Un texte court s''affiche avec ses homophones surlignés, et tu valides ou tu corriges chacun. À chaque clic, la simulation te propose le test qui convient : changer le temps si tu soupçonnes un verbe, remplacer par « plus tard » pour trancher plutôt, remplacer par « lorsque » pour trancher quand. Six textes de longueur croissante, dont deux tirés de sujets de BEPC, et la proportion de fautes y est celle d''une vraie copie."
}', NULL, 10),
    (v_chapitre_id, 'Quiz du chapitre 11', 8, 'quiz', '{
  "titre": "Vérifie que tu as compris",
  "questions": [
    {
      "question": "Quelle différence entre homophone lexical et homophone grammatical ?",
      "choix": [
        "Aucune",
        "Le lexical oppose des mots différents du dictionnaire (ver, verre, vert) ; le grammatical oppose des formes de grammaire (a/à, ce/se)",
        "Le lexical est plus long",
        "Le grammatical ne s''entend pas"
      ],
      "bonne": 1,
      "explication": "Les homophones grammaticaux font l''objet du chapitre 19, au module 3. Ici, ce sont des mots qui ont chacun leur entrée dans le dictionnaire."
    },
    {
      "question": "Quel est le meilleur outil pour trancher entre deux homophones ?",
      "choix": [
        "Lire la phrase à voix haute",
        "Chercher un mot de la même FAMILLE où la lettre muette se prononce : verdir donne « vert », verrier donne « verre »",
        "Compter les lettres",
        "Prendre le plus court"
      ],
      "bonne": 1,
      "explication": "Lire à voix haute ne sert à rien, justement : les homophones se prononcent de la même façon. Il faut un autre outil, et la famille de mots est le meilleur."
    },
    {
      "question": "« Nous marchions … le marché. » Quel mot, et pourquoi ?",
      "choix": [
        "verre",
        "vers, car le mot introduit un groupe nominal : c''est une préposition, et seul « vers » en est une",
        "vert",
        "ver"
      ],
      "bonne": 1,
      "explication": "La nature du mot élimine déjà la moitié des candidats. Un adjectif s''accorde, un nom prend un article, une préposition introduit un complément."
    },
    {
      "question": "Comment savoir si un homophone cache un verbe ?",
      "choix": [
        "En regardant sa longueur",
        "En essayant de changer le temps : « il sent » devient « il sentait », donc c''est un verbe ; « sans moi » ne l''accepte pas",
        "En comptant les syllabes",
        "En mettant au pluriel"
      ],
      "bonne": 1,
      "explication": "C''est le test le plus efficace, et il règle à lui seul tous les homophones qui cachent un verbe : sent/sans, compte/conte, vois/voie/voix."
    },
    {
      "question": "Quelle différence entre « tache » et « tâche » ?",
      "choix": [
        "Aucune",
        "Une tache est une salissure ; une tâche est un travail à faire — l''accent circonflexe est le chapeau de celui qui travaille",
        "La première est féminine",
        "La seconde est un verbe"
      ],
      "bonne": 1,
      "explication": "Un correcteur installe volontiers les deux mots à une ligne d''écart dans le même texte, pour voir si l''élève fait la différence."
    },
    {
      "question": "Comment trancher entre « plutôt » et « plus tôt » ?",
      "choix": [
        "Au hasard",
        "Remplacer par « plus tard » : si la phrase tient, il faut écrire « plus tôt » en deux mots",
        "Toujours en un mot",
        "Regarder l''accent"
      ],
      "bonne": 1,
      "explication": "« Nous partons plus tard que d''habitude » tient debout, donc on écrit « plus tôt » en deux mots. En un mot, « plutôt » veut dire « de préférence »."
    },
    {
      "question": "Qu''est-ce qu''un paronyme, comme « conjecture » et « conjoncture » ?",
      "choix": [
        "Un synonyme",
        "Deux mots qui se ressemblent beaucoup sans se prononcer exactement pareil, et qu''on confond tout autant",
        "Un mot composé",
        "Un mot de la même famille"
      ],
      "bonne": 1,
      "explication": "Une conjecture est une supposition, une conjoncture est la situation du moment. La confusion est très répandue dans la presse, et le correcteur la sanctionne."
    }
  ]
}', NULL, 5);

  RAISE NOTICE '8 leçons ajoutées au chapitre 11, Les homophones lexicaux.';
END $fr3$;
