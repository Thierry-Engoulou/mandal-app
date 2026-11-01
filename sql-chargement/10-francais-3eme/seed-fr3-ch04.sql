-- ---------------------------------------------------------------------------
-- M'Andal — Français, classe de 3ème
-- Chapitre 4 : Les temps simples et composés de l'indicatif
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
  WHERE programme_id = v_programme_id AND ordre = 4;

  IF v_chapitre_id IS NULL THEN
    INSERT INTO public.chapitres (programme_id, titre, ordre, niveau)
    VALUES (v_programme_id, 'Les temps simples et composés de l''indicatif', 4, 'Module 1 : La vie familiale et socioculturelle')
    RETURNING id INTO v_chapitre_id;
    RAISE NOTICE 'Chapitre 4 créé.';
  END IF;

  -- Les leçons. Si le chapitre en a déjà, on passe son tour sans rien toucher.
  SELECT count(*) INTO v_deja FROM public.concepts WHERE chapitre_id = v_chapitre_id;
  IF v_deja > 0 THEN
    RAISE NOTICE 'Le chapitre 4 a déjà ses % leçons, je n''y touche pas.', v_deja;
    RETURN;
  END IF;

  INSERT INTO public.concepts
    (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes) VALUES
    (v_chapitre_id, 'Les huit temps de l''indicatif, et comment ils se répondent', 1, 'texte', '
L''indicatif est le mode du **réel** : il présente l''action comme un fait. C''est
le mode du récit, et c''est de loin le plus employé.

Il compte huit temps, et la bonne nouvelle, c''est qu''ils vont **deux par deux**.

### La règle qui tient tout

**Chaque temps composé se forme avec l''auxiliaire conjugué au temps simple
correspondant, suivi du participe passé.**

| Temps simple | Temps composé | Exemple |
| --- | --- | --- |
| Présent, *je chante* | Passé composé | *j''ai chanté* |
| Imparfait, *je chantais* | Plus-que-parfait | *j''avais chanté* |
| Passé simple, *je chantai* | Passé antérieur | *j''eus chanté* |
| Futur simple, *je chanterai* | Futur antérieur | *j''aurai chanté* |

Regarde la colonne du milieu : à chaque fois, l''auxiliaire *avoir* est conjugué
au temps simple de la même ligne. *J''ai* est le présent, *j''avais* l''imparfait,
*j''eus* le passé simple, *j''aurai* le futur.

Tu n''as donc pas huit temps à apprendre, mais quatre, plus une règle de
fabrication.

### Quel auxiliaire ?

La plupart des verbes se conjuguent avec **avoir**.

Se conjuguent avec **être** : les verbes **pronominaux** — ceux qui ont un
pronom réfléchi, *se lever*, *se souvenir* — et une liste courte de verbes de
mouvement ou de changement d''état : *aller, venir, arriver, partir, entrer,
sortir, monter, descendre, naître, mourir, rester, tomber, devenir, passer*.

> Je **suis** arrivé. Elle **est** partie. Nous **nous sommes** levés.

Avec *être*, le participe passé **s''accorde avec le sujet** :

> Elle est arriv**ée**. Elles sont arriv**ées**.

Avec *avoir*, il **ne s''accorde pas avec le sujet**. Il s''accorde seulement avec
le complément d''objet direct, et seulement si celui-ci est placé avant. Tu
reverras cette règle au module 4, mais retiens dès maintenant la différence :

> Elle **est** arrivé**e**. *(accord avec le sujet)*
> Elle **a** mang**é** la mangue. *(pas d''accord)*
> La mangue qu''elle **a** mang**ée**. *(accord avec le complément placé avant)*

### Les valeurs du présent, en avant-goût

Le présent ne sert pas qu''à dire ce qui se passe maintenant. Tu étudieras ses
cinq valeurs au module 5, mais note dès à présent la plus utile pour tes
rédactions : le **présent de narration**, qui raconte un fait passé comme s''il
se déroulait sous nos yeux.

> Il marchait tranquillement. Soudain, un chien **surgit** et **se jette** sur
> lui.

L''effet est saisissant, et il ne coûte rien.

---

**Exercice corrigé**

*Donner le temps composé qui correspond à chaque temps simple, à la première
personne du singulier, pour le verbe « partir ». Préciser l''auxiliaire et
justifier l''accord.*

**Correction.**

*L''auxiliaire d''abord.* *Partir* fait partie de la liste des verbes de mouvement
qui se conjuguent avec **être**. Le participe passé s''accordera donc avec le
sujet. Prenons un sujet masculin singulier, *je* désignant un garçon : pas de
marque d''accord.

*Les quatre paires :*

Présent *je pars* → passé composé **je suis parti**. L''auxiliaire *être* est au
présent, *je suis*.

Imparfait *je partais* → plus-que-parfait **j''étais parti**. L''auxiliaire est à
l''imparfait, *j''étais*.

Passé simple *je partis* → passé antérieur **je fus parti**. L''auxiliaire est au
passé simple, *je fus*.

Futur simple *je partirai* → futur antérieur **je serai parti**. L''auxiliaire est
au futur, *je serai*.

*Et si le sujet est féminin ?* Le participe s''accorde, puisque l''auxiliaire est
*être* : *je suis partie*, *j''étais partie*, *je fus partie*, *je serai partie*.

*Compare avec un verbe qui prend « avoir », « chanter » : j''ai chanté, j''avais
chanté, j''eus chanté, j''aurai chanté — et jamais de e, même si le sujet est
féminin, parce que le participe ne s''accorde pas avec le sujet quand
l''auxiliaire est « avoir ».*
', NULL, 24),
    (v_chapitre_id, 'Figure : les huit temps vont deux par deux', 2, 'figure', '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 580 300" width="580" height="300">
<rect width="580" height="300" fill="#ffffff"/>
<text x="290" y="24" text-anchor="middle" font-size="14" font-weight="700" fill="#0f172a">Les huit temps de l&apos;indicatif vont deux par deux</text>
<text x="290" y="42" text-anchor="middle" font-size="10" fill="#64748b">Chaque temps composé = l&apos;auxiliaire au temps simple correspondant + le participe passé.</text>

<rect x="20" y="58" width="258" height="30" rx="4" fill="#1e293b"/>
<text x="149" y="78" text-anchor="middle" font-size="11" font-weight="700" fill="#ffffff">LES QUATRE TEMPS SIMPLES</text>
<rect x="302" y="58" width="258" height="30" rx="4" fill="#1e293b"/>
<text x="431" y="78" text-anchor="middle" font-size="11" font-weight="700" fill="#ffffff">LES QUATRE TEMPS COMPOSÉS</text>

<rect x="20" y="94" width="258" height="44" rx="4" fill="#dcfce7" stroke="#15803d"/>
<text x="32" y="112" font-size="10" font-weight="700" fill="#14532d">Présent</text>
<text x="32" y="130" font-size="10" font-style="italic" fill="#166534">je chante</text>
<rect x="302" y="94" width="258" height="44" rx="4" fill="#dcfce7" stroke="#15803d"/>
<text x="314" y="112" font-size="10" font-weight="700" fill="#14532d">Passé composé</text>
<text x="314" y="130" font-size="10" font-style="italic" fill="#166534">j&apos;ai chanté</text>
<path d="M 278 116 L 296 116" stroke="#15803d" stroke-width="1.4"/>
<polygon points="302,116 294,112 294,120" fill="#15803d"/>

<rect x="20" y="144" width="258" height="44" rx="4" fill="#dbeafe" stroke="#2563eb"/>
<text x="32" y="162" font-size="10" font-weight="700" fill="#1e3a8a">Imparfait</text>
<text x="32" y="180" font-size="10" font-style="italic" fill="#1e40af">je chantais</text>
<rect x="302" y="144" width="258" height="44" rx="4" fill="#dbeafe" stroke="#2563eb"/>
<text x="314" y="162" font-size="10" font-weight="700" fill="#1e3a8a">Plus-que-parfait</text>
<text x="314" y="180" font-size="10" font-style="italic" fill="#1e40af">j&apos;avais chanté</text>
<path d="M 278 166 L 296 166" stroke="#2563eb" stroke-width="1.4"/>
<polygon points="302,166 294,162 294,170" fill="#2563eb"/>

<rect x="20" y="194" width="258" height="44" rx="4" fill="#fef3c7" stroke="#ca8a04"/>
<text x="32" y="212" font-size="10" font-weight="700" fill="#78350f">Passé simple</text>
<text x="32" y="230" font-size="10" font-style="italic" fill="#92400e">je chantai</text>
<rect x="302" y="194" width="258" height="44" rx="4" fill="#fef3c7" stroke="#ca8a04"/>
<text x="314" y="212" font-size="10" font-weight="700" fill="#78350f">Passé antérieur</text>
<text x="314" y="230" font-size="10" font-style="italic" fill="#92400e">j&apos;eus chanté</text>
<path d="M 278 216 L 296 216" stroke="#ca8a04" stroke-width="1.4"/>
<polygon points="302,216 294,212 294,220" fill="#ca8a04"/>

<rect x="20" y="244" width="258" height="44" rx="4" fill="#fce7f3" stroke="#be185d"/>
<text x="32" y="262" font-size="10" font-weight="700" fill="#831843">Futur simple</text>
<text x="32" y="280" font-size="10" font-style="italic" fill="#9d174d">je chanterai</text>
<rect x="302" y="244" width="258" height="44" rx="4" fill="#fce7f3" stroke="#be185d"/>
<text x="314" y="262" font-size="10" font-weight="700" fill="#831843">Futur antérieur</text>
<text x="314" y="280" font-size="10" font-style="italic" fill="#9d174d">j&apos;aurai chanté</text>
<path d="M 278 266 L 296 266" stroke="#be185d" stroke-width="1.4"/>
<polygon points="302,266 294,262 294,270" fill="#be185d"/>
</svg>', NULL, 5),
    (v_chapitre_id, 'Simulation : l''atelier des temps composés', 3, 'interactif', '{
  "widget": "temps-indicatif",
  "consigne": "Tu choisis un verbe, une personne et un temps simple, et la simulation te demande de construire toi-même le temps composé correspondant : d''abord l''auxiliaire — avoir ou être ? — puis sa conjugaison au bon temps simple, puis le participe passé et son accord. Chaque erreur t''indique laquelle des trois pièces a cédé. Un second volet te sert les quatorze verbes de mouvement qui prennent être, et les verbes pronominaux."
}', NULL, 10),
    (v_chapitre_id, 'Le passé simple, parce que l''examen le demande', 4, 'texte', '
De tous les temps, le passé simple est celui qu''on parle le moins et qu''on
t''interroge le plus. À la **question 4 de la deuxième partie** du BEPC, on te
donne une phrase et on te demande de la réécrire au passé simple. Deux points, à
chaque session ou presque.

Alors apprends-le une bonne fois.

### À quoi il sert

Le passé simple est le temps du **récit écrit**. Il présente une action passée,
**achevée**, et qui fait **avancer l''histoire**.

> Il ouvrit la porte, entra et s''assit.

Trois actions, trois pas en avant. On ne l''emploie quasiment jamais à l''oral — on
dit « il a ouvert » — et c''est pour cela qu''il paraît difficile. Il n''est pas
difficile : il est seulement peu familier.

### Les trois séries de terminaisons

**Les verbes du 1er groupe, en -er**, et le verbe *aller* :

> -ai, -as, -a, -âmes, -âtes, -èrent

*je chantai, tu chantas, il chanta, nous chantâmes, vous chantâtes, ils
chantèrent*

**Les verbes du 2e groupe, en -ir**, et beaucoup du 3e :

> -is, -is, -it, -îmes, -îtes, -irent

*je finis, tu finis, il finit, nous finîmes, vous finîtes, ils finirent*

**Une partie des verbes du 3e groupe** prend la série en *u* :

> -us, -us, -ut, -ûmes, -ûtes, -urent

*je courus, je voulus, je pus, je dus, je sus, je crus, je lus, je vécus*

Trois séries, et c''est tout. Les accents circonflexes des deux premières
personnes du pluriel sont obligatoires : les oublier est une faute.

### Les verbes qu''il faut savoir par cœur

Ce sont ceux qui tombent.

| Verbe | Passé simple |
| --- | --- |
| être | je fus, il fut, nous fûmes, ils furent |
| avoir | j''eus, il eut, nous eûmes, ils eurent |
| aller | j''allai, il alla, ils allèrent |
| faire | je fis, il fit, nous fîmes, ils firent |
| dire | je dis, il dit, ils dirent |
| voir | je vis, il vit, ils virent |
| venir | je vins, il vint, nous vînmes, ils vinrent |
| tenir | je tins, il tint, ils tinrent |
| prendre | je pris, il prit, ils prirent |
| pouvoir | je pus, il put, ils purent |
| vouloir | je voulus, il voulut, ils voulurent |
| savoir | je sus, il sut, ils surent |
| écrire | j''écrivis, il écrivit, ils écrivirent |
| mettre | je mis, il mit, ils mirent |

*Venir* et *tenir* sont les seuls à faire *-ins, -ins, -int, -înmes, -întes,
-inrent*. Ils méritent une ligne à part dans ton cahier.

### Les deux pièges de l''examen

**Le premier :** ne confonds pas la 1re personne du singulier du passé simple
avec celle de l''imparfait, au premier groupe.

> *je chantai* → passé simple
> *je chantais* → imparfait

Un **s**, et le temps change. À l''oral on n''entend presque rien ; à l''écrit, tout
se voit.

**Le second :** à la 3e personne du pluriel du premier groupe, c''est **-èrent**,
avec un accent grave, et non *-erent*.

> ils chant**èrent**, ils mang**èrent**, ils travaill**èrent**

---

**Exercice corrigé**

*Réécrire ce texte au passé simple, en conservant les personnes.*

> *Le chauffeur gare le car sur la place. Les voyageurs descendent un par un.
> Une vieille femme ne peut pas porter son panier ; deux jeunes gens viennent
> l''aider et le prennent chacun par une anse. Elle les remercie et ils
> disparaissent dans la foule.*

**Correction.**

Procédons verbe par verbe, en nommant le groupe à chaque fois.

*gare* → 1er groupe, 3e personne du singulier : **gara**.
*descendent* → 3e groupe, série en *-i*, 3e personne du pluriel :
**descendirent**.
*peut* → *pouvoir*, série en *-u* : **put**.
*viennent* → *venir*, série particulière en *-in* : **vinrent**.
*prennent* → *prendre*, série en *-i* : **prirent**.
*remercie* → 1er groupe : **remercia**.
*disparaissent* → *disparaître*, formé sur *paraître*, série en *-u* :
**disparurent**.

*Le texte au passé simple :*

> *Le chauffeur **gara** le car sur la place. Les voyageurs **descendirent** un
> par un. Une vieille femme ne **put** pas porter son panier ; deux jeunes gens
> **vinrent** l''aider et le **prirent** chacun par une anse. Elle les
> **remercia** et ils **disparurent** dans la foule.*

*Deux remarques qui valent des points.*

*La première : « vinrent » est le piège du texte. On écrit souvent « vindrent »
ou « venirent ». La forme est « ils vinrent », comme « ils tinrent ».*

*La seconde : le sens du texte a changé en changeant de temps. Au présent, la
scène se déroulait sous nos yeux. Au passé simple, elle est révolue, racontée.
C''est exactement ce que le temps apporte, et c''est ce qu''on te demandera de
commenter en compréhension de texte.*
', NULL, 26),
    (v_chapitre_id, 'Simulation : la question 4 du BEPC', 5, 'interactif', '{
  "widget": "passe-simple",
  "consigne": "L''exercice de l''examen, en conditions. Une phrase ou un court texte s''affiche, et tu dois le réécrire au passé simple. Tu tapes chaque forme, la simulation la compare et, en cas d''erreur, ne te donne pas la réponse tout de suite : elle te dit d''abord à quel groupe appartient le verbe et quelle série de terminaisons il suit. Les quatorze verbes irréguliers du cours reviennent sans cesse, et un compteur te montre lequel te résiste encore. Les deux pièges — le « s » de l''imparfait et l''accent de « -èrent » — sont signalés à part."
}', NULL, 10),
    (v_chapitre_id, 'Imparfait ou passé simple ? Le choix qui fait le récit', 6, 'texte', '
Tu sais maintenant conjuguer. Reste à savoir **quand** employer l''un plutôt que
l''autre, et c''est ce qui sépare une rédaction plate d''une rédaction vivante.

### Les deux rôles

Le **passé simple** porte les actions qui **font avancer** l''histoire. Elles sont
brèves, achevées, elles se succèdent. C''est le **premier plan**.

L''**imparfait** porte ce qui **dure** : le décor, le temps qu''il fait, les
habitudes, l''état d''esprit des personnages. C''est l''**arrière-plan**.

> Il **pleuvait** depuis le matin. La route **était** boueuse et les boutiques
> **restaient** fermées. Soudain, un car **déboucha** du virage, **klaxonna** et
> **s''arrêta** devant l''église.

Lis à nouveau. Les trois premiers verbes installent un décor qui dure : on ne
sait pas quand la pluie a commencé ni quand elle finira. Les trois derniers sont
des coups : chacun arrive, s''achève, et laisse la place au suivant.

Voilà toute la différence. L''imparfait **étale**, le passé simple **découpe**.

### Les trois valeurs de l''imparfait à connaître

**L''imparfait de description** : le décor, les personnages.

> La cour **était** vaste et un manguier **ombrageait** le mur.

**L''imparfait d''habitude**, ou de répétition : une action qui revenait souvent.

> Chaque matin, il **allait** chercher l''eau à la borne-fontaine.

**L''imparfait de durée** : une action en train de se dérouler, souvent
interrompue par un passé simple.

> Il **dormait** quand le téléphone **sonna**.

Cette dernière construction est la plus utile de toutes, et tu la reconnaîtras
partout : *imparfait + quand + passé simple*. La longue action est coupée net par
la brève.

### Ce que l''examen en fait

En **compréhension de texte**, on te demande souvent : *relevez les temps
employés et justifiez leur emploi*. La réponse attendue n''est jamais « c''est du
passé ». Elle est :

> L''auteur emploie l''imparfait pour décrire le décor et les habitudes, et le
> passé simple pour les actions qui font avancer le récit.

Cette phrase, apprise par cœur, vaut deux points.

En **expression écrite**, un récit entièrement au passé simple est illisible :
tout est au premier plan, rien ne respire. Un récit entièrement à l''imparfait
n''avance jamais. Alterne, et tu écriras.

---

**Exercice corrigé**

*Mettre les verbes entre parenthèses à l''imparfait ou au passé simple, et
justifier chaque choix.*

> *Le soleil (se coucher) derrière les collines. Dans la concession, ma
> grand-mère (préparer) le repas comme chaque soir ; le feu (crépiter)
> doucement. Tout à coup, un cri (déchirer) le silence. Ma grand-mère (se
> lever), (sortir) et (courir) vers la route.*

**Correction.**

*se coucher* → **se couchait**. C''est une description de décor, une action qui
dure : imparfait.

*préparer* → **préparait**. Le texte précise « comme chaque soir » : c''est une
habitude, donc l''imparfait de répétition. Le détail du texte te donne la réponse.

*crépiter* → **crépitait**. Décor sonore qui dure : imparfait de description.

*déchirer* → **déchira**. « Tout à coup » annonce la rupture : action brève,
soudaine, qui fait basculer le récit. Passé simple.

*se lever*, *sortir*, *courir* → **se leva**, **sortit**, **courut**. Trois
actions successives et brèves, qui se suivent comme trois pas. Passé simple.

*Le texte complet :*

> *Le soleil **se couchait** derrière les collines. Dans la concession, ma
> grand-mère **préparait** le repas comme chaque soir ; le feu **crépitait**
> doucement. Tout à coup, un cri **déchira** le silence. Ma grand-mère **se
> leva**, **sortit** et **courut** vers la route.*

*Remarque la forme du texte : trois imparfaits, puis quatre passés simples. C''est
la structure la plus courante du récit — on installe, puis l''événement arrive. Et
remarque le rôle de « tout à coup » : il marque la charnière. Les mots « soudain
», « alors », « tout à coup », « brusquement » annoncent presque toujours un
passé simple.*

*Dernier détail à ne pas manquer : « courut » et non « courit ». Courir suit la
série en -u, comme pouvoir et vouloir.*
', NULL, 24),
    (v_chapitre_id, 'Simulation : installer le décor, puis l''événement', 7, 'interactif', '{
  "widget": "imparfait-passe-simple",
  "consigne": "Un récit s''affiche avec ses verbes à l''infinitif, et tu choisis pour chacun entre l''imparfait et le passé simple. La simulation ne se contente pas de te corriger : elle colore le texte en deux teintes, l''arrière-plan et le premier plan, et tu vois d''un coup d''œil la forme de ton récit. Mets tout au passé simple : le texte devient une liste et la simulation te le dit. Mets tout à l''imparfait : il n''avance plus. Quatre récits camerounais t''attendent, et les mots charnières — soudain, tout à coup, alors — y sont signalés."
}', NULL, 10),
    (v_chapitre_id, 'Quiz du chapitre 4', 8, 'quiz', '{
  "titre": "Vérifie que tu as compris",
  "questions": [
    {
      "question": "Comment se forme un temps composé de l''indicatif ?",
      "choix": [
        "Avec deux participes",
        "Avec l''auxiliaire conjugué au temps simple correspondant, suivi du participe passé",
        "Avec le verbe au futur",
        "En ajoutant un s"
      ],
      "bonne": 1,
      "explication": "J''ai chanté (présent de l''auxiliaire), j''avais chanté (imparfait), j''eus chanté (passé simple), j''aurai chanté (futur). Quatre temps à savoir, plus une règle."
    },
    {
      "question": "Avec l''auxiliaire être, avec quoi s''accorde le participe passé ?",
      "choix": [
        "Avec le complément d''objet",
        "Avec le sujet : elle est arrivée, elles sont arrivées",
        "Il ne s''accorde jamais",
        "Avec l''auxiliaire"
      ],
      "bonne": 1,
      "explication": "Avec AVOIR, au contraire, il ne s''accorde pas avec le sujet : elle a mangé la mangue, sans e."
    },
    {
      "question": "Quelles sont les trois séries de terminaisons du passé simple ?",
      "choix": [
        "-ais, -ait, -aient",
        "-ai/-as/-a… pour le 1er groupe, -is/-is/-it… pour le 2e et une partie du 3e, -us/-us/-ut… pour le reste du 3e",
        "-erai, -eras, -era",
        "-e, -es, -e"
      ],
      "bonne": 1,
      "explication": "Et les accents circonflexes des deux personnes du pluriel sont obligatoires : nous chantâmes, vous chantâtes."
    },
    {
      "question": "Quel est le passé simple de « venir » à la 3e personne du pluriel ?",
      "choix": [
        "ils venirent",
        "ils vinrent",
        "ils vindrent",
        "ils venaient"
      ],
      "bonne": 1,
      "explication": "Venir et tenir sont les seuls à faire -ins, -ins, -int, -înmes, -întes, -inrent. Ils méritent une ligne à part dans ton cahier."
    },
    {
      "question": "Quelle différence entre « je chantai » et « je chantais » ?",
      "choix": [
        "Aucune",
        "« je chantai » est au passé simple, « je chantais » à l''imparfait : un seul s change le temps",
        "La première est fausse",
        "La seconde est au futur"
      ],
      "bonne": 1,
      "explication": "À l''oral on n''entend presque rien ; à l''écrit, tout se voit. C''est l''un des deux pièges de la question 4 du BEPC."
    },
    {
      "question": "Dans un récit, à quoi sert l''imparfait ?",
      "choix": [
        "Aux actions qui font avancer l''histoire",
        "À l''arrière-plan : le décor, les habitudes, les actions qui durent",
        "À parler du futur",
        "À poser des questions"
      ],
      "bonne": 1,
      "explication": "L''imparfait étale, le passé simple découpe. Un récit tout au passé simple devient une liste ; tout à l''imparfait, il n''avance jamais."
    },
    {
      "question": "Que signalent les mots « soudain », « tout à coup », « brusquement » ?",
      "choix": [
        "Un imparfait",
        "Presque toujours un passé simple : ils marquent la rupture et l''entrée dans le premier plan",
        "Un futur",
        "Une question"
      ],
      "bonne": 1,
      "explication": "Il dormait QUAND le téléphone SONNA : imparfait + quand + passé simple est la construction la plus utile du récit, la longue action coupée net par la brève."
    }
  ]
}', NULL, 5);

  RAISE NOTICE '8 leçons ajoutées au chapitre 4, Les temps simples et composés de l''indicatif.';
END $fr3$;
