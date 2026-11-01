-- ---------------------------------------------------------------------------
-- M'Andal — Français, classe de 3ème
-- Chapitre 6 : Lecture méthodique et lecture suivie : le roman africain
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
  WHERE programme_id = v_programme_id AND ordre = 6;

  IF v_chapitre_id IS NULL THEN
    INSERT INTO public.chapitres (programme_id, titre, ordre, niveau)
    VALUES (v_programme_id, 'Lecture méthodique et lecture suivie : le roman africain', 6, 'Module 1 : La vie familiale et socioculturelle')
    RETURNING id INTO v_chapitre_id;
    RAISE NOTICE 'Chapitre 6 créé.';
  END IF;

  -- Les leçons. Si le chapitre en a déjà, on passe son tour sans rien toucher.
  SELECT count(*) INTO v_deja FROM public.concepts WHERE chapitre_id = v_chapitre_id;
  IF v_deja > 0 THEN
    RAISE NOTICE 'Le chapitre 6 a déjà ses % leçons, je n''y touche pas.', v_deja;
    RETURN;
  END IF;

  INSERT INTO public.concepts
    (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes) VALUES
    (v_chapitre_id, 'La lecture méthodique en quatre temps', 1, 'texte', '
Lire méthodiquement, ce n''est pas lire lentement. C''est lire **avec un
projet** : chercher comment un texte est construit, et ce que cette construction
produit sur le lecteur.

Quatre temps, toujours les mêmes.

### Premier temps : situer

Avant de lire, réponds à trois questions.

**Qui parle ?** Un narrateur extérieur à l''histoire, ou un personnage qui dit
« je » ?
**De quoi ?** Le thème, en deux ou trois mots.
**Dans quel genre ?** Un récit, un poème, une scène de théâtre, un article, une
lettre.

Ces trois réponses prennent trente secondes et t''évitent les contresens.

### Deuxième temps : repérer

Tu relis, crayon en main, et tu marques quatre choses.

**Les champs lexicaux**, c''est-à-dire les thèmes qui reviennent.
**Les temps verbaux** et leur alternance.
**Les figures de style** — comparaisons, métaphores, répétitions.
**Les marques de la personne** : qui dit « je », « nous », « ils » ?

Ne cherche pas à tout voir. Cherche ce qui **revient**, car ce qui revient est
voulu.

### Troisième temps : interpréter

C''est l''étape que les copies sautent, et c''est celle qui rapporte.

Pour chaque chose repérée, pose la question : **pourquoi ?**

Tu as trouvé un champ lexical de la peur ? Pourquoi l''auteur installe-t-il la
peur ici ? Tu as trouvé des phrases très courtes ? Pourquoi, à cet endroit ?

Un relevé sans interprétation ne vaut rien. Dire « il y a beaucoup de
comparaisons » n''est pas une analyse ; dire « les comparaisons rapprochent la
ville d''un animal, ce qui la rend menaçante » en est une.

### Quatrième temps : conclure

En deux phrases, dis ce que le texte fait et comment. C''est ta réponse à la
question *quel est l''intérêt de ce texte ?*

### La méthode appliquée

Prenons un passage de récit, où un jeune homme venu du village découvre la
ville.

*Situer* : un narrateur extérieur, le thème de l''arrivée en ville, un récit.

*Repérer* : un champ lexical du bruit et de la foule, des phrases qui
s''allongent, des verbes de mouvement au présent.

*Interpréter* : le bruit et la foule disent le choc du personnage ; les phrases
qui s''allongent imitent l''étourdissement ; le présent met le lecteur dans la
scène, à la place du personnage.

*Conclure* : le texte fait éprouver au lecteur ce que le personnage éprouve. Il
ne décrit pas la ville, il fait vivre son effet.

Voilà une lecture méthodique. Elle tient en huit lignes.

---

**Exercice corrigé**

*Appliquer les quatre temps au texte suivant.*

> *La route était longue. Il marchait depuis l''aube, son sac sur l''épaule, et le
> soleil montait. Il pensait à sa mère, restée au village, qui lui avait donné
> ses derniers billets. Il pensait au cousin qui devait l''attendre en ville, et
> qu''il n''avait pas vu depuis six ans. Il pensait au travail qu''il trouverait.
> Puis il cessa de penser, car la poussière entrait dans sa bouche et il fallait
> garder ses forces.*

**Correction.**

*Situer.* Un narrateur extérieur — il dit « il », pas « je » — mais qui connaît
les pensées du personnage. Le thème est le départ vers la ville, ou l''exode
rural. C''est un récit.

*Repérer.* Trois choses sautent aux yeux.

La **répétition** de « il pensait », trois fois en tête de phrase. C''est une
figure de style qu''on appelle l''**anaphore**.

Les **temps** : l''imparfait partout — était, marchait, montait, pensait — sauf
un passé simple à la fin, « il cessa ». Tu reconnais l''arrière-plan et le
premier plan du chapitre 4.

Le **champ lexical de la fatigue et de l''effort** : « longue », « depuis
l''aube », « le soleil montait », « la poussière », « garder ses forces ».

*Interpréter.* Maintenant le pourquoi, pour chacun.

La répétition de « il pensait » imite le **ressassement** : le personnage tourne
et retourne les mêmes pensées, comme on le fait en marchant longtemps. Et les
trois pensées vont dans l''ordre du temps — la mère au passé, le cousin au
présent, le travail au futur. Toute sa vie tient dans ces trois lignes.

L''imparfait installe une marche qui n''en finit pas. Le seul passé simple,
« cessa », tombe comme un couperet : c''est le moment où le corps l''emporte sur
l''esprit.

Le champ lexical de la fatigue prépare ce basculement : la poussière et les
forces sont du côté du corps.

*Conclure.* Le texte raconte beaucoup plus qu''une marche. En quelques lignes, il
donne au personnage un passé, un présent et un avenir, puis il les fait taire
par la fatigue. Le lecteur comprend que ce départ coûte, avant même que la ville
soit atteinte.
', NULL, 26),
    (v_chapitre_id, 'Figure : la structure de l''épreuve d''étude de texte', 2, 'figure', '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 580 300" width="580" height="300">
<rect width="580" height="300" fill="#ffffff"/>
<text x="290" y="24" text-anchor="middle" font-size="14" font-weight="700" fill="#0f172a">L&apos;épreuve d&apos;étude de texte au BEPC</text>
<text x="290" y="42" text-anchor="middle" font-size="10" fill="#64748b">Deux parties de 10 points, cinq questions à 2 points chacune. Rien ne varie.</text>

<rect x="20" y="58" width="260" height="212" rx="6" fill="#dbeafe" stroke="#2563eb" stroke-width="1.8"/>
<text x="150" y="80" text-anchor="middle" font-size="12" font-weight="700" fill="#1e3a8a">I. COMPRÉHENSION</text>
<text x="150" y="96" text-anchor="middle" font-size="11" font-weight="700" fill="#2563eb">10 points</text>
<line x1="34" y1="106" x2="266" y2="106" stroke="#93c5fd"/>
<text x="34" y="126" font-size="9" fill="#1e40af">1. un titre, ou une information</text>
<text x="34" y="146" font-size="9" fill="#1e40af">2. un fait précis du texte</text>
<text x="34" y="166" font-size="9" fill="#1e40af">3. une justification par citation</text>
<text x="34" y="186" font-size="9" fill="#1e40af">4. les sentiments du narrateur</text>
<text x="34" y="206" font-size="9" fill="#1e40af">5. ton opinion personnelle</text>
<line x1="60" y1="220" x2="240" y2="220" stroke="#bfdbfe"/>
<text x="150" y="240" text-anchor="middle" font-size="9" font-weight="700" fill="#1e3a8a">2 points chacune</text>
<text x="150" y="258" text-anchor="middle" font-size="9" font-style="italic" fill="#475569">cite le texte, toujours</text>

<rect x="300" y="58" width="260" height="212" rx="6" fill="#dcfce7" stroke="#15803d" stroke-width="1.8"/>
<text x="430" y="80" text-anchor="middle" font-size="12" font-weight="700" fill="#14532d">II. LA LANGUE</text>
<text x="430" y="96" text-anchor="middle" font-size="11" font-weight="700" fill="#15803d">10 points</text>
<line x1="314" y1="106" x2="546" y2="106" stroke="#86efac"/>
<text x="314" y="126" font-size="9" fill="#166534">1. le sens d&apos;un ou deux mots</text>
<text x="314" y="146" font-size="9" fill="#166534">2. relever un champ lexical</text>
<text x="314" y="166" font-size="9" fill="#166534">3. nature et fonction, ou formation</text>
<text x="314" y="186" font-size="9" fill="#166534">4. temps d&apos;un verbe, puis réécriture</text>
<text x="314" y="206" font-size="9" fill="#166534">5. les propositions d&apos;une phrase</text>
<line x1="340" y1="220" x2="520" y2="220" stroke="#bbf7d0"/>
<text x="430" y="240" text-anchor="middle" font-size="9" font-weight="700" fill="#14532d">2 points chacune</text>
<text x="430" y="258" text-anchor="middle" font-size="9" font-style="italic" fill="#475569">c&apos;est tout ton programme de langue</text>

<text x="290" y="290" text-anchor="middle" font-size="10" font-weight="700" fill="#7f1d1d">Cinq chapitres de l&apos;année préparent à eux seuls les cinq questions de la partie II.</text>
</svg>', NULL, 5),
    (v_chapitre_id, 'Simulation : les quatre temps de la lecture', 3, 'interactif', '{
  "widget": "lecture-methodique",
  "consigne": "Un texte s''affiche et la simulation t''accompagne dans les quatre temps, un par un. Tu situes d''abord en répondant à trois questions, puis tu surlignes dans le texte ce que tu repères — champs lexicaux, temps verbaux, figures, marques de la personne — et la simulation range tes relevés par catégorie. Vient alors le temps qui rapporte : pour chaque relevé, elle te demande « pourquoi ? » et refuse de passer tant que tu n''as donné qu''un constat. Six textes, dont trois d''auteurs camerounais."
}', NULL, 10),
    (v_chapitre_id, 'La lecture suivie : « Ville cruelle » d''Eza Boto', 4, 'texte', '
Le programme impose une **œuvre intégrale par trimestre** : un roman d''un auteur
africain au premier, une tragédie française du XVIIe siècle au deuxième, un
recueil de poèmes camerounais au troisième.

Pour ce premier trimestre, nous lirons **Ville cruelle**, d''**Eza Boto**.

### L''auteur

Eza Boto est le premier pseudonyme d''**Alexandre Biyidi Awala**, né en 1932 près
de Yaoundé et mort en 2001. Il est bien plus connu sous son second pseudonyme :
**Mongo Beti**.

*Ville cruelle* paraît en **1954**, alors qu''il a vingt-deux ans et qu''il
étudie en France. C''est son premier roman. Il signera les suivants — *Le pauvre
Christ de Bomba*, *Mission terminée* — du nom de Mongo Beti.

Pourquoi deux noms ? Parce qu''écrire contre l''administration coloniale, en 1954,
n''était pas sans risque pour sa famille restée au pays.

### L''histoire, sans en dire trop

Le roman suit **Banda**, un jeune homme du village de Bamila, qui descend à la
ville de Tanga pour y vendre sa récolte de cacao. Avec cet argent, il doit payer
la dot de la femme qu''il veut épouser, et aussi soigner sa mère malade.

Mais à Tanga, les inspecteurs saisissent sa récolte sous un prétexte
administratif, et la brûlent. Banda perd tout en une journée.

Le reste du roman raconte ce qu''il advient de lui dans cette ville qui l''a
dépouillé.

### Les deux villes en une

Le titre dit *ville*, au singulier, mais Tanga est **double**, et c''est la
trouvaille du livre.

Il y a **Tanga-Nord**, celle des Européens et de leurs commerces, avec ses rues
propres, ses maisons en dur et son administration.

Il y a **Tanga-Sud**, celle des Africains, avec ses cases, sa boue, son marché
et ses chantiers.

Les deux sont séparées, et tout le roman tient dans cette séparation : la
richesse d''un côté, le travail de l''autre.

### Les thèmes à retenir

**L''exploitation économique.** Banda cultive, un autre achète à vil prix, un
troisième revend. Il ne maîtrise rien de ce qu''il produit.

**L''opposition du village et de la ville.** Bamila est pauvre mais tient
ensemble ; Tanga est riche et dévore. Le titre n''est pas une image gratuite.

**L''arbitraire administratif.** La récolte est brûlée sans explication, sans
recours. C''est un fait, pas une opinion du narrateur.

**La solidarité.** Elle existe, mais elle vient d''en bas, et elle est fragile.

### Ce qu''on te demandera

Trois choses, et pas davantage.

**Résumer** le roman en quinze lignes, sans raconter la fin dans le détail.

**Présenter un personnage** : qui il est, ce qu''il veut, ce qui l''en empêche,
comment il change.

**Dégager un thème** et l''illustrer par deux ou trois passages précis.

La fiche de lecture que tu tiendras cette année doit contenir, pour chaque
œuvre : le titre, l''auteur, la date, le genre, le cadre — où et quand —, les
personnages principaux en une ligne chacun, le résumé en quinze lignes, trois
thèmes, et ton avis personnel justifié.

C''est ce dernier point que les élèves bâclent. « J''ai aimé ce livre » ne vaut
rien. « J''ai été frappé par la scène où la récolte est brûlée, parce qu''elle
montre que le travail d''une année peut être anéanti par une signature » : voilà
un avis.

---

**Exercice corrigé**

*Rédiger la présentation du personnage de Banda, en respectant les quatre points
de la méthode : qui il est, ce qu''il veut, ce qui l''en empêche, comment il
change.*

**Correction.**

*Qui il est.* Banda est un jeune paysan du village de Bamila, orphelin de père,
qui vit seul avec sa mère malade. Il cultive le cacao. Il n''a reçu que peu
d''instruction, mais il observe et il juge.

*Ce qu''il veut.* Il veut deux choses, et elles tiennent toutes deux à l''argent de
sa récolte : épouser la jeune fille qu''il a choisie, ce qui suppose de payer la
dot, et soigner sa mère avant qu''il ne soit trop tard. Ses désirs sont concrets
et modestes : il ne rêve pas de fortune, il veut tenir ses deux obligations.

*Ce qui l''en empêche.* Un système entier, et c''est ce qui fait la force du
roman. Les inspecteurs saisissent et brûlent sa récolte sous un prétexte de
qualité. Les acheteurs fixent les prix sans lui. L''administration ne lui doit
aucune explication. Banda n''a devant lui ni adversaire à combattre ni faute à
réparer : il a un mécanisme, et le mécanisme ne discute pas.

*Comment il change.* Il arrive à Tanga en confiance, avec le calcul simple d''un
homme qui a travaillé une année. Il en repart ayant compris que le travail ne
suffit pas, que la ville ne rend pas ce qu''elle prend, et que la solidarité des
humbles est la seule ressource qui lui reste. Sa naïveté est détruite ; sa
dignité, non.

*On peut ajouter, pour conclure, que Banda n''est pas seulement un individu : Eza
Boto en fait le représentant de toute une génération de jeunes ruraux pris entre
un village qui ne nourrit plus et une ville qui exploite. C''est ce qui donne au
roman sa portée, bien au-delà de l''histoire d''un sac de cacao.*
', NULL, 28),
    (v_chapitre_id, 'Simulation : la fiche de lecture', 5, 'interactif', '{
  "widget": "fiche-lecture",
  "consigne": "Tu construis la fiche de lecture de « Ville cruelle » case par case : titre, auteur, date, genre, cadre, personnages, résumé, thèmes, avis personnel. Pour chaque case, la simulation te propose plusieurs réponses, dont les erreurs classiques — le résumé qui raconte la fin, le personnage réduit à son nom, le thème confondu avec l''histoire, et l''avis qui se contente de « j''ai aimé ». Elle note comme un professeur, et te montre à la fin la fiche complète, celle que tu devras savoir refaire pour les deux autres œuvres de l''année."
}', NULL, 10),
    (v_chapitre_id, 'Sujet type BEPC — Étude de texte', 6, 'texte', '
**Épreuve d''étude de texte — 20 points — deux parties de 10 points**

Lis attentivement le texte, puis réponds aux questions.

---

### Le texte

> Le cacao était là, dans les sacs, et les sacs étaient là, sur la place, depuis
> quatre heures du matin. Banda s''était assis dessus. Il attendait.
>
> Les autres attendaient aussi. Ils étaient venus de Bamila, de Nkongsamba, de
> plus loin encore, et chacun gardait sa récolte comme on garde un enfant. On ne
> se parlait pas beaucoup. On regardait la porte du hangar.
>
> Vers neuf heures, l''inspecteur sortit. Il était accompagné de deux hommes en
> uniforme. Il marcha le long des sacs, en ouvrit un, prit une poignée de fèves,
> la laissa couler entre ses doigts et dit un mot que personne n''entendit. Un
> des hommes en uniforme écrivit quelque chose.
>
> Banda se leva. Il voulait expliquer que ce cacao avait séché trois semaines au
> soleil, qu''il l''avait retourné chaque matin, que sa mère était malade et que
> le mariage attendait. Il ouvrit la bouche.
>
> — Deuxième choix, dit l''inspecteur sans le regarder. Et il passa au sac
> suivant.
>
> Banda resta debout un moment. Puis il se rassit sur ses sacs, parce qu''il n''y
> avait rien d''autre à faire, et parce que la place était pleine de gens qui
> attendaient leur tour.

*Texte d''entraînement rédigé dans l''esprit de « Ville cruelle » d''Eza Boto.*

---
---

## Corrigé

### Partie I — Compréhension du texte *(10 points)*

**Question 1 — Proposez un titre à ce texte et justifiez votre choix.
*(2 points)***

*Réponse attendue.* « L''attente » ou « Deuxième choix » ou « La récolte
refusée ».

*Justification.* Le texte entier est construit sur une attente — le mot
« attendait » revient trois fois dès le début — qui se termine par une décision
que Banda subit sans pouvoir rien dire.

*Barème.* 1 point pour le titre, 1 point pour la justification. **Un titre sans
justification ne vaut que la moitié des points.** C''est l''erreur la plus
fréquente à cette question.

**Question 2 — Depuis combien de temps les paysans attendent-ils, et d''où
viennent-ils ? *(2 points)***

Ils attendent **depuis quatre heures du matin**, et l''inspecteur ne sort que
« vers neuf heures » : cela fait **cinq heures d''attente**.

Ils viennent de **Bamila**, de **Nkongsamba**, et « de plus loin encore ».

*Barème.* 1 point pour la durée, 1 point pour les lieux. Le texte donne les deux
informations : il faut les deux.

**Question 3 — Comment l''inspecteur examine-t-il la récolte de Banda ? Relevez
le passage qui le montre. *(2 points)***

Il l''examine **très rapidement et sans attention** : « il en ouvrit un, prit une
poignée de fèves, la laissa couler entre ses doigts et dit un mot que personne
n''entendit ».

Trois gestes en une phrase, et il ne regarde même pas Banda — le texte le précise
plus loin : « dit l''inspecteur sans le regarder ».

*Barème.* 1 point pour l''idée — un examen expéditif —, 1 point pour la citation.
**Toute réponse de compréhension doit s''appuyer sur le texte.**

**Question 4 — Quels sentiments Banda éprouve-t-il au quatrième paragraphe ?
*(2 points)***

Il éprouve d''abord de **l''espoir** et une **volonté de se défendre** : il se
lève, il veut expliquer, et le texte énumère tout ce qu''il a à dire.

Puis vient **l''impuissance**, ou le découragement : « Il ouvrit la bouche », et
la phrase s''arrête là. Il n''a pas pu parler.

*Signes à citer.* « Banda se leva », « il voulait expliquer », « Il ouvrit la
bouche ».

*Barème.* 1 point par sentiment nommé **et** justifié par le texte. Rappelle-toi
la règle du chapitre 5 : nommer sans citer ne vaut qu''un demi-point, citer sans
nommer non plus.

**Question 5 — Selon vous, que faudrait-il changer pour que les paysans comme
Banda ne subissent plus cette situation ? *(2 points)***

*C''est la question d''opinion, et il n''y a pas de réponse unique. Ce qui est noté,
c''est que tu proposes quelque chose de précis et que tu l''expliques.*

Trois réponses recevables, parmi d''autres.

**S''organiser en coopérative.** Seuls, les paysans subissent le prix qu''on leur
impose ; groupés, ils peuvent négocier et contester un classement.

**Rendre le contrôle contestable.** Il faudrait qu''un paysan puisse demander une
seconde expertise et obtenir une explication écrite.

**Transformer sur place.** Vendre du cacao brut, c''est laisser la valeur partir
ailleurs. La transformer au pays garderait le bénéfice sur place.

*Barème.* 1 point pour la proposition, 1 point pour la justification. **Une
réponse en une ligne, sans explication, ne vaut qu''un point.**

### Partie II — Connaissance et maniement de la langue *(10 points)*

**Question 1 — Donnez le sens des mots « récolte » et « expertise » tel qu''ils
s''emploient ici. *(2 points)***

**Récolte** : l''ensemble des produits agricoles ramassés à la fin d''une
saison de culture. Ici, le cacao que Banda a cultivé et séché pendant l''année.

**Fèves** : les graines du cacaoyer, qui constituent le produit vendu après
séchage.

*Méthode.* Une définition se construit en deux pièces : le **genre prochain** —
« l''ensemble des produits », « les graines » — et la **différence spécifique** —
« ramassés à la fin d''une saison », « du cacaoyer ». Une définition par l''exemple
ou par un synonyme seul ne rapporte qu''un demi-point.

**Question 2 — Relevez quatre mots ou expressions appartenant au champ lexical
de l''agriculture. *(2 points)***

> « le cacao », « la récolte », « les fèves », « avait séché trois semaines au
> soleil »

*On accepterait aussi « les sacs » et « il l''avait retourné chaque matin ».*

*Barème.* 0,5 point par mot juste. Attention : on en demande **quatre**. En
donner huit ne rapporte rien de plus, et si les quatre premiers contiennent une
erreur, elle compte.

**Question 3 — Donnez la nature et la fonction des mots soulignés. *(2 points)***

Prenons quatre mots du texte : *dessus* (« Banda s''était assis dessus »), *le*
(« il l''avait retourné »), *sans le regarder*, *qui attendaient*.

| Mot | Nature | Fonction |
| --- | --- | --- |
| dessus | adverbe de lieu | complément circonstanciel de lieu de « s''était assis » |
| l'' (dans « il l''avait retourné ») | pronom personnel | complément d''objet direct de « avait retourné » |
| sans le regarder | groupe infinitif prépositionnel | complément circonstanciel de manière de « dit » |
| qui (dans « gens qui attendaient ») | pronom relatif | sujet de « attendaient » |

*Barème.* 0,5 point par mot, et il faut **les deux** — la nature et la fonction —
pour avoir le demi-point. C''est ici que les deux tests du chapitre 1 servent :
supprimable et déplaçable, donc complément circonstanciel.

**Question 4 — a) Donnez le temps et le mode du verbe « attendait » dans la
première phrase. b) Réécrivez la phrase « Il attendait » au passé simple.
*(2 points)***

*a)* « attendait » est à l''**imparfait de l''indicatif**.

*Justification, si on te la demande :* c''est un imparfait de durée. Il installe
une attente qui s''étire, et c''est tout l''effet du début du texte.

*b)* Au passé simple : **« Il attendit. »**

*Attention.* *Attendre* est un verbe du 3e groupe qui suit la série en *-i* :
j''attendis, tu attendis, il attendit, nous attendîmes, vous attendîtes, ils
attendirent.

*Et remarque ce que la réécriture fait au sens : « il attendait » laisse l''attente
ouverte, « il attendit » la referme. Le signaler vaut un point de plus si la
question le demande.*

*Barème.* 1 point pour a, 1 point pour b.

**Question 5 — Dans la phrase « Puis il se rassit sur ses sacs, parce qu''il n''y
avait rien d''autre à faire », relevez les propositions, donnez leur nature, et
précisez la fonction de la subordonnée. *(2 points)***

*Je compte les verbes conjugués :* « se rassit » et « avait ». Deux verbes
conjugués, donc **deux propositions**. Remarque que « à faire » est un infinitif
et ne compte pas.

*Je les relève :*

**Proposition principale** : « Puis il se rassit sur ses sacs ».

**Proposition subordonnée** : « parce qu''il n''y avait rien d''autre à faire ».

*Je donne sa nature et sa fonction :* c''est une **proposition subordonnée
conjonctive circonstancielle de cause**, introduite par la conjonction *parce
que*. Elle est **complément circonstanciel de cause** du verbe « se rassit ».

*Barème.* 0,5 point par proposition relevée, 0,5 point pour la nature, 0,5 point
pour la fonction.

*Le piège.* Si le sujet avait écrit « car il n''y avait rien d''autre à faire », la
réponse aurait été tout autre : « car » coordonne, donc il y aurait eu **deux
propositions indépendantes coordonnées**, et pas de subordonnée du tout. Même
sens, nature opposée.

---

### Ce que le correcteur attend

**Citer le texte à chaque question de compréhension.** Une réponse juste mais
sans citation perd systématiquement la moitié des points.

**Répondre au nombre exact demandé.** Quatre mots signifie quatre.

**Donner la nature ET la fonction** quand les deux sont demandées. L''une sans
l''autre ne vaut rien.

**Justifier l''opinion personnelle.** La question 5 de la première partie n''a pas
de bonne réponse, mais elle a de mauvaises copies : celles qui répondent en une
ligne.
', NULL, 32),
    (v_chapitre_id, 'Simulation : l''épreuve en conditions', 7, 'interactif', '{
  "widget": "etude-de-texte-bepc",
  "consigne": "L''épreuve entière, avec son chronomètre. Un texte s''affiche et les dix questions se présentent dans l''ordre réel, cinq de compréhension puis cinq de langue. Tu réponds, et la simulation note comme le barème officiel : un point pour l''idée, un point pour la citation, un demi-point par nature et fonction. Elle refuse une réponse de compréhension qui ne cite pas le texte, et te signale quand tu relèves six mots là où on t''en demandait quatre. À la fin, elle te donne ta note sur vingt et te dit quelle question t''a coûté le plus. Trois textes au choix, dont deux tirés de sessions réelles."
}', NULL, 10),
    (v_chapitre_id, 'Quiz du chapitre 6', 8, 'quiz', '{
  "titre": "Vérifie que tu as compris",
  "questions": [
    {
      "question": "Quels sont les quatre temps de la lecture méthodique ?",
      "choix": [
        "Lire, relire, résumer, conclure",
        "Situer, repérer, interpréter, conclure",
        "Chercher, souligner, recopier, apprendre",
        "Comprendre, apprendre, réciter, appliquer"
      ],
      "bonne": 1,
      "explication": "C''est le troisième que les copies sautent, et c''est celui qui rapporte : pour chaque relevé, demande-toi POURQUOI."
    },
    {
      "question": "« Il y a beaucoup de comparaisons dans ce texte. » Est-ce une analyse ?",
      "choix": [
        "Oui",
        "Non, c''est un constat : l''analyse commence quand on dit ce que les comparaisons produisent",
        "Oui, si on en compte le nombre",
        "Cela dépend du texte"
      ],
      "bonne": 1,
      "explication": "« Les comparaisons rapprochent la ville d''un animal, ce qui la rend menaçante » : voilà une analyse. Un relevé sans interprétation ne vaut rien."
    },
    {
      "question": "Qui est Eza Boto ?",
      "choix": [
        "Un écrivain sénégalais",
        "Le premier pseudonyme d''Alexandre Biyidi Awala, plus connu sous le nom de Mongo Beti",
        "Le héros de Ville cruelle",
        "Un poète camerounais"
      ],
      "bonne": 1,
      "explication": "Ville cruelle paraît en 1954, son premier roman, écrit à vingt-deux ans. Le héros s''appelle Banda."
    },
    {
      "question": "Pourquoi la ville de Tanga est-elle « double » dans le roman ?",
      "choix": [
        "Elle a deux noms",
        "Elle se divise en Tanga-Nord, européenne et commerçante, et Tanga-Sud, africaine et laborieuse",
        "Elle est décrite deux fois",
        "Banda y va deux fois"
      ],
      "bonne": 1,
      "explication": "Tout le roman tient dans cette séparation : la richesse d''un côté, le travail de l''autre. Le titre n''est pas une image gratuite."
    },
    {
      "question": "Combien de points vaut l''épreuve d''étude de texte au BEPC, et comment se partagent-ils ?",
      "choix": [
        "10 points en une seule partie",
        "20 points : 10 pour la compréhension, 10 pour la langue, et cinq questions à 2 points dans chaque partie",
        "30 points en trois parties",
        "20 points mais seulement pour la langue"
      ],
      "bonne": 1,
      "explication": "Et les cinq questions de la partie II sont toujours les mêmes types : sens d''un mot, champ lexical, nature et fonction, temps et réécriture, propositions."
    },
    {
      "question": "Que vaut une réponse de compréhension juste mais sans citation du texte ?",
      "choix": [
        "Les deux points",
        "La moitié des points seulement",
        "Rien du tout",
        "Un point bonus"
      ],
      "bonne": 1,
      "explication": "C''est la règle qui coûte le plus de points au BEPC. 1 point pour l''idée, 1 point pour la citation, à presque chaque question."
    },
    {
      "question": "Dans un avis personnel sur une œuvre, que faut-il éviter ?",
      "choix": [
        "Donner son avis",
        "Se contenter de « j''ai aimé » : il faut dire quelle scène, et pourquoi elle t''a marqué",
        "Citer le texte",
        "Être critique"
      ],
      "bonne": 1,
      "explication": "« J''ai été frappé par la scène où la récolte est brûlée, parce qu''elle montre que le travail d''une année peut être anéanti par une signature » : voilà un avis."
    }
  ]
}', NULL, 5);

  RAISE NOTICE '8 leçons ajoutées au chapitre 6, Lecture méthodique et lecture suivie : le roman africain.';
END $fr3$;
