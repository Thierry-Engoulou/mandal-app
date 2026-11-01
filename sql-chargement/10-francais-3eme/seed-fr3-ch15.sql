-- ---------------------------------------------------------------------------
-- M'Andal — Français, classe de 3ème
-- Chapitre 15 : Le témoignage, opposer ou concilier deux thèses
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
  WHERE programme_id = v_programme_id AND ordre = 15;

  IF v_chapitre_id IS NULL THEN
    INSERT INTO public.chapitres (programme_id, titre, ordre, niveau)
    VALUES (v_programme_id, 'Le témoignage, opposer ou concilier deux thèses', 15, 'Module 2 : Citoyenneté et environnement')
    RETURNING id INTO v_chapitre_id;
    RAISE NOTICE 'Chapitre 15 créé.';
  END IF;

  -- Les leçons. Si le chapitre en a déjà, on passe son tour sans rien toucher.
  SELECT count(*) INTO v_deja FROM public.concepts WHERE chapitre_id = v_chapitre_id;
  IF v_deja > 0 THEN
    RAISE NOTICE 'Le chapitre 15 a déjà ses % leçons, je n''y touche pas.', v_deja;
    RETURN;
  END IF;

  INSERT INTO public.concepts
    (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes) VALUES
    (v_chapitre_id, 'Le témoignage : raconter pour prouver', 1, 'texte', '
Nous passons de la lecture à l''écriture. Tu sais maintenant reconnaître une
thèse, un argument et un exemple ; il faut à présent savoir en produire.

Et nous commençons par le plus accessible : **le témoignage**.

### Qu''est-ce qu''un témoignage ?

C''est un **récit** que l''on raconte pour **prouver** quelque chose. Il
appartient donc à deux mondes à la fois : il se raconte comme une histoire, et
il sert comme un exemple.

> « Je crois qu''un enfant qui marche deux heures pour aller à l''école
> n''apprendra pas comme les autres. Je le sais : je l''ai fait pendant trois
> ans. Je partais à cinq heures et j''arrivais en classe la tête vide, les pieds
> brûlants. Le professeur croyait que je n''écoutais pas. »

Le témoignage transforme une idée abstraite — la distance nuit à
l''apprentissage — en quelque chose que le lecteur **voit**.

### Sa force, et sa faiblesse

**Sa force** est d''être incontestable. Personne ne peut te dire que tu n''as pas
vécu ce que tu as vécu. C''est l''argument le plus difficile à réfuter.

**Sa faiblesse** est d''être unique. Un seul cas ne prouve pas une règle, et un
lecteur exigeant te répondra : « c''était peut-être une exception ».

C''est pourquoi un bon texte argumentatif **ne repose jamais sur le seul
témoignage**. Il l''emploie comme un exemple, au service d''un argument plus
général.

> Argument : la distance décourage la scolarisation des filles.
> Témoignage : ce que j''ai vu dans mon village.
> Chiffre ou fait général : ce que disent les statistiques régionales.

Les trois ensemble sont redoutables. Le témoignage seul est seulement touchant.

### Comment on écrit un témoignage efficace

**Première règle : être précis.** Un témoignage vague ne vaut rien. « C''était
difficile » ne prouve rien. « Je partais à cinq heures, et j''arrivais les pieds
brûlants » prouve.

Donne des heures, des distances, des objets, des sensations. Le détail concret
est ce qui rend un témoignage crédible.

**Deuxième règle : être bref.** Un témoignage est un exemple, pas un roman. Dix
lignes au maximum dans une rédaction de BEPC. Si tu racontes ta vie entière, le
correcteur ne voit plus l''argument.

**Troisième règle : conclure.** Ne laisse jamais le récit se terminer tout seul.
Dis ce qu''il prouve.

> « … le professeur croyait que je n''écoutais pas. **C''est ainsi que l''on perd
> des élèves sans jamais savoir pourquoi.** »

Cette dernière phrase est celle qui transforme le récit en argument. Sans elle,
tu as raconté une anecdote.

### Les temps du témoignage

Tu les connais depuis le chapitre 4. Le témoignage se raconte au **passé
composé** et à l''**imparfait**, parce qu''il appartient à l''expérience du
locuteur.

> *passé composé* pour les événements : « je l''ai fait pendant trois ans »
> *imparfait* pour les habitudes et le décor : « je partais à cinq heures »

Le passé simple serait déplacé : il appartient au récit littéraire, pas au
témoignage personnel.

Et la conclusion, elle, se dit au **présent**, parce qu''elle vaut encore.

> « C''est ainsi que l''on **perd** des élèves. »

---

**Exercice corrigé**

*Voici un témoignage mal écrit. Le réécrire en appliquant les trois règles.*

> « Dans mon quartier il y a des problèmes avec les ordures depuis longtemps.
> C''est vraiment catastrophique et les gens ne savent plus quoi faire. Ma mère
> dit toujours que ce n''est pas normal. Moi aussi je trouve que c''est pas
> normal. Il faudrait que ça change parce que c''est devenu invivable et
> personne ne fait rien du tout. »

**Correction.**

*Ce qui ne va pas.*

**Aucune précision.** « Des problèmes », « depuis longtemps », « les gens » : le
lecteur ne voit rien. Il n''y a pas un seul détail concret dans ces cinq lignes.

**Aucun fait, que des jugements.** « Catastrophique », « pas normal »,
« invivable », « personne ne fait rien » : ce sont des opinions répétées, pas un
témoignage. Et l''hyperbole « catastrophique » affaiblit au lieu de renforcer, tu
le sais depuis le chapitre 13.

**Aucune conclusion argumentative.** Le texte se termine sur une plainte, pas
sur ce qu''il prouve.

*Et un détail de langue : « c''est pas normal » est du registre oral. En
rédaction, on écrit « ce n''est pas normal ».*

*La réécriture.*

> « Le bac à ordures de notre carrefour a été retiré en janvier dernier, et il
> n''a jamais été remplacé. Depuis, les habitants déposent leurs sacs au pied du
> poteau électrique, à trente mètres de chez nous. En saison des pluies, l''eau
> emporte le tas jusque dans la cour de l''école voisine ; les enfants jouent
> autour. Ma mère a écrit deux fois à la mairie. Elle n''a jamais reçu de
> réponse.
>
> Un quartier n''est pas sale parce que ses habitants le veulent. Il le devient
> quand on retire un bac et qu''on oublie de le remettre. »

*Compare les deux textes. Le second ne contient aucun mot plus savant que le
premier. Mais il a une date — janvier —, un lieu — le carrefour, le poteau,
l''école —, une distance — trente mètres —, un fait vérifiable — deux lettres
sans réponse. Et il se termine par deux phrases au présent qui disent ce que le
récit prouve.*

*C''est cela, écrire un témoignage. Ce n''est pas ressentir plus fort ; c''est
regarder plus précisément.*
', NULL, 28),
    (v_chapitre_id, 'Figure : les deux plans de l''argumentation', 2, 'figure', '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 580 310" width="580" height="310">
<rect width="580" height="310" fill="#ffffff"/>
<text x="290" y="24" text-anchor="middle" font-size="14" font-weight="700" fill="#0f172a">Deux façons d&apos;organiser une argumentation</text>
<text x="290" y="42" text-anchor="middle" font-size="10" fill="#64748b">Le sujet vous dit lequel choisir. Lisez sa consigne avant de rédiger.</text>

<rect x="20" y="58" width="262" height="230" rx="6" fill="#dbeafe" stroke="#2563eb" stroke-width="1.6"/>
<text x="151" y="80" text-anchor="middle" font-size="12" font-weight="700" fill="#1e3a8a">PLAN DIALECTIQUE</text>
<text x="151" y="96" text-anchor="middle" font-size="9" font-style="italic" fill="#1e40af">« Discutez cette opinion »</text>

<rect x="36" y="108" width="230" height="44" rx="4" fill="#ffffff" stroke="#60a5fa"/>
<text x="151" y="125" text-anchor="middle" font-size="10" font-weight="700" fill="#1e3a8a">I — THÈSE</text>
<text x="151" y="141" text-anchor="middle" font-size="8" fill="#1e40af">ce qu&apos;on peut dire POUR — 2 arguments</text>

<rect x="36" y="158" width="230" height="44" rx="4" fill="#ffffff" stroke="#60a5fa"/>
<text x="151" y="175" text-anchor="middle" font-size="10" font-weight="700" fill="#1e3a8a">II — ANTITHÈSE</text>
<text x="151" y="191" text-anchor="middle" font-size="8" fill="#1e40af">ce qu&apos;on peut dire CONTRE — 2 arguments</text>

<rect x="36" y="208" width="230" height="44" rx="4" fill="#ffffff" stroke="#60a5fa"/>
<text x="151" y="225" text-anchor="middle" font-size="10" font-weight="700" fill="#1e3a8a">III — SYNTHÈSE</text>
<text x="151" y="241" text-anchor="middle" font-size="8" fill="#1e40af">votre position, qui dépasse les deux</text>

<text x="151" y="270" text-anchor="middle" font-size="8" fill="#1e3a8a">La synthèse n&apos;est pas un résumé.</text>
<text x="151" y="282" text-anchor="middle" font-size="8" fill="#1e3a8a">Elle tranche, en disant à quelle condition.</text>

<rect x="298" y="58" width="262" height="230" rx="6" fill="#dcfce7" stroke="#15803d" stroke-width="1.6"/>
<text x="429" y="80" text-anchor="middle" font-size="12" font-weight="700" fill="#14532d">PLAN THÉMATIQUE</text>
<text x="429" y="96" text-anchor="middle" font-size="9" font-style="italic" fill="#166534">« Défendez cette opinion »</text>

<rect x="314" y="108" width="230" height="38" rx="4" fill="#ffffff" stroke="#4ade80"/>
<text x="429" y="124" text-anchor="middle" font-size="10" font-weight="700" fill="#14532d">I — ARGUMENT 1 + exemple</text>
<text x="429" y="139" text-anchor="middle" font-size="8" fill="#166534">le plus faible, pour commencer</text>

<rect x="314" y="152" width="230" height="38" rx="4" fill="#ffffff" stroke="#4ade80"/>
<text x="429" y="168" text-anchor="middle" font-size="10" font-weight="700" fill="#14532d">II — ARGUMENT 2 + exemple</text>
<text x="429" y="183" text-anchor="middle" font-size="8" fill="#166534">plus fort</text>

<rect x="314" y="196" width="230" height="38" rx="4" fill="#ffffff" stroke="#4ade80"/>
<text x="429" y="212" text-anchor="middle" font-size="10" font-weight="700" fill="#14532d">III — ARGUMENT 3 + exemple</text>
<text x="429" y="227" text-anchor="middle" font-size="8" fill="#166534">le plus fort, pour finir</text>

<rect x="314" y="240" width="230" height="30" rx="4" fill="#fef3c7" stroke="#ca8a04"/>
<text x="429" y="259" text-anchor="middle" font-size="9" font-weight="700" fill="#78350f">+ une concession quelque part</text>

<text x="429" y="282" text-anchor="middle" font-size="8" fill="#14532d">On monte en puissance : le dernier argument reste.</text>
</svg>', NULL, 5),
    (v_chapitre_id, 'Simulation : du récit à l''argument', 3, 'interactif', '{
  "widget": "temoignage-argument",
  "consigne": "Un témoignage vague s''affiche, et la simulation te fait travailler en trois passes : d''abord tu remplaces chaque mot flou par un détail concret — elle te demande une heure, une distance, un objet —, ensuite tu supprimes les jugements répétés, enfin tu rédiges la phrase de conclusion au présent. À chaque passe, le texte se réécrit à côté de l''original, et tu vois l''écart se creuser. Six témoignages, tous sur des situations de quartier, et un compteur de détails concrets qui doit atteindre cinq avant qu''elle te laisse passer."
}', NULL, 10),
    (v_chapitre_id, 'Opposer ou concilier deux thèses : choisir son plan', 4, 'texte', '
Le sujet de BEPC te demandera presque toujours l''une de ces deux choses :
**défendre** une opinion, ou la **discuter**. Et le verbe de la consigne décide
du plan.

### Lire la consigne avant tout

Voici les verbes que tu rencontreras, et ce qu''ils commandent.

**« Défendez », « montrez que », « justifiez »** → tu es d''un seul côté. Plan
**thématique** : trois arguments qui vont tous dans le même sens.

**« Discutez », « qu''en pensez-vous ? », « partagez-vous cet avis ? »** → tu
dois examiner les deux côtés. Plan **dialectique** : thèse, antithèse,
synthèse.

**« Comparez », « opposez »** → deux positions à confronter, point par point.

Un élève qui discute quand on lui demandait de défendre perd la moitié de sa
note, même s''il écrit bien. Lis la consigne deux fois.

### Le plan thématique

C''est le plus simple. Tu défends une seule thèse, et tu alignes tes raisons.

> **Introduction** — le sujet, la thèse, l''annonce du plan
> **I.** Premier argument + un exemple
> **II.** Deuxième argument + un exemple
> **III.** Troisième argument + un exemple
> **Conclusion** — bilan, et ouverture

**Dans quel ordre ranger les arguments ?** Du **plus faible au plus fort**. Le
lecteur garde en mémoire ce qu''il a lu en dernier : garde ta meilleure raison
pour la fin.

**Et place une concession quelque part**, de préférence au début du troisième
paragraphe. Elle montre que tu as pensé à l''objection, et elle vaut des points.

### Le plan dialectique

C''est celui qu''on demande quand le sujet dit « discutez ».

> **Introduction**
> **I. Thèse** — ce qu''on peut dire **pour** : deux arguments
> **II. Antithèse** — ce qu''on peut dire **contre** : deux arguments
> **III. Synthèse** — **ta** position
> **Conclusion**

### Ce qu''est vraiment une synthèse

C''est la partie que tout le monde rate, alors je m''y arrête.

**Une synthèse n''est pas un résumé des deux parties précédentes.** Si tu écris
« nous avons vu que certains pensent ceci et d''autres cela », tu n''as rien dit
et tu n''auras rien.

**Une synthèse n''est pas non plus un refus de trancher.** « Chacun a ses
raisons, il faut respecter toutes les opinions » est la phrase la plus faible
qu''on puisse écrire dans une copie.

**Une synthèse tranche, en disant à quelle condition.** Elle dépasse
l''opposition en déplaçant la question.

Prends un exemple. Sujet : *faut-il interdire les motos-taxis en centre-ville ?*

> *Thèse* : oui, elles causent des accidents et de la pollution.
> *Antithèse* : non, elles font vivre des milliers de jeunes et desservent les
> quartiers où les bus ne vont pas.
> *Mauvaise synthèse* : « Les deux points de vue se valent, il faut trouver un
> équilibre. » → rien.
> *Bonne synthèse* : « Le vrai problème n''est pas la moto, c''est l''absence de
> transport public dans les quartiers périphériques. Interdire les motos sans
> les remplacer déplacerait la difficulté sur les plus pauvres ; les encadrer —
> casque obligatoire, immatriculation, zones réservées — traiterait le danger
> sans supprimer le revenu. L''interdiction devrait venir en dernier, et
> seulement là où une autre solution existe. »

La bonne synthèse prend position — encadrer plutôt qu''interdire — et elle dit
**à quelle condition** l''autre solution deviendrait acceptable. C''est cela,
dépasser.

### Les connecteurs qui marquent le plan

Le correcteur doit voir ton plan sans effort. Emploie-les.

> **Pour ouvrir la thèse** : « Il est vrai que », « On ne peut nier que »,
> « D''abord »
> **Pour basculer vers l''antithèse** : « Cependant », « Toutefois », « Mais
> cette opinion néglige »
> **Pour ouvrir la synthèse** : « En réalité », « Le vrai problème est
> ailleurs », « À bien y regarder »

---

**Exercice corrigé**

*Voici trois sujets. Pour chacun, dire quel plan la consigne impose, et donner
les titres des parties.*

*1. « Les réseaux sociaux éloignent les jeunes de leur famille. » Défendez cette
opinion.*

*2. « L''école doit se faire dans la langue maternelle. » Qu''en pensez-vous ?*

*3. « Certains pensent qu''il faut interdire les sacs plastiques ; d''autres
estiment que c''est pénaliser les petits commerçants. » Discutez.*

**Correction.**

*Sujet 1.* Le verbe est **« défendez »**. Je suis d''un seul côté : plan
**thématique**.

> **I.** Le temps passé devant l''écran est du temps retiré à la conversation
> familiale. *(argument le plus faible, le plus évident)*
> **II.** Les réseaux créent une vie sociale parallèle que la famille ne
> connaît pas, et dont elle ne peut plus parler avec l''adolescent.
> **III.** Ils installent une hiérarchie nouvelle : le jeune sait des choses que
> ses aînés ignorent, et l''autorité familiale s''en trouve fragilisée. *(le plus
> fort, gardé pour la fin)*
>
> *Concession à placer au début du III : « Certes, un adolescent peut aussi
> partager en famille ce qu''il découvre en ligne, et certains le font. Mais… »*

*Sujet 2.* La consigne est **« qu''en pensez-vous ? »** : il faut examiner les
deux côtés. Plan **dialectique**.

> **I. Thèse** — l''enseignement en langue maternelle facilite les apprentissages
> des premières années et préserve le patrimoine culturel.
> **II. Antithèse** — le Cameroun compte plus de deux cents langues ; enseigner
> dans chacune est matériellement impossible, et le français et l''anglais
> ouvrent sur le pays entier et sur le monde.
> **III. Synthèse** — la question n''est pas « quelle langue », mais « à quel
> moment ». Les premières années en langue maternelle, pour comprendre ; le
> passage progressif aux langues officielles, pour poursuivre. C''est ce que
> pratiquent plusieurs expériences pilotes.

*Remarque le déplacement : je ne choisis pas entre les deux langues, je change
la question en passant de « laquelle » à « quand ». C''est le mouvement
caractéristique d''une synthèse réussie.*

*Sujet 3.* La consigne est **« discutez »**, et le sujet présente lui-même les
deux positions. Plan **dialectique**, et les deux premières parties sont
données.

> **I. Thèse** — les sacs plastiques bouchent les caniveaux, mettent des
> siècles à disparaître et tuent le bétail.
> **II. Antithèse** — l''interdiction frappe d''abord les petits commerçants, qui
> n''ont pas les moyens d''acheter des emballages en papier, et le contrôle
> s''exerce sur eux plutôt que sur les importateurs.
> **III. Synthèse** — interdire la production et l''importation plutôt que la
> détention : on tarit la source au lieu de sanctionner le dernier maillon. Avec
> un délai et une filière de remplacement, l''objection du II tombe.

*Encore un déplacement : je ne discute plus « interdire ou non », mais
« interdire à quel bout de la chaîne ». La synthèse ne cherche pas le milieu
entre deux opinions : elle cherche l''angle que ni l''une ni l''autre n''avait vu.*
', NULL, 28),
    (v_chapitre_id, 'Simulation : construire son plan', 5, 'interactif', '{
  "widget": "plan-dialectique",
  "consigne": "Un sujet de BEPC s''affiche, et la simulation te fait d''abord souligner le verbe de la consigne — défendez, discutez, comparez — avant de te laisser choisir le plan ; si tu te trompes de plan, elle te montre la moitié de note que cela coûte. Ensuite tu remplis les parties en faisant glisser des arguments proposés, et elle vérifie l''ordre : le plus fort doit finir. Pour la synthèse, elle te propose trois rédactions dont deux sont les pièges classiques — le résumé déguisé et le refus de trancher — et tu dois trouver celle qui déplace la question. Dix sujets, tous de sessions réelles."
}', NULL, 10),
    (v_chapitre_id, 'Sujet type BEPC — Expression écrite, corrigé', 6, 'texte', '
Voici la seconde épreuve de français du BEPC. Elle te demande une production
écrite complète. Prends une feuille, compose en une heure trente, puis compare
avec le corrigé.

### Ce que le correcteur regarde

Le corrigé harmonisé national retient trois critères.

**La pertinence des idées** — tes arguments répondent-ils vraiment au sujet ?
Sont-ils développés, illustrés ?

**La cohérence de l''organisation** — y a-t-il une introduction, des parties
distinctes, une conclusion ? Les connecteurs marquent-ils le plan ?

**La correction linguistique** — orthographe, conjugaison, syntaxe, ponctuation,
richesse du vocabulaire.

*Une réserve honnête : je n''ai pas pu obtenir le barème chiffré officiel qui
répartit les points entre ces trois critères. Si ton établissement le possède,
demande-le à ton professeur. Les trois critères, eux, sont certains.*

---

## SUJET

> « Dans certains quartiers de nos villes, des jeunes se sont organisés pour
> ramasser eux-mêmes les ordures, faute de voir passer le camion de la commune.
> Certains y voient un bel exemple de citoyenneté ; d''autres estiment que
> c''est décharger l''État de ses devoirs. »
>
> **Qu''en pensez-vous ? Vous développerez votre point de vue dans un texte
> argumenté d''une trentaine de lignes, appuyé sur des arguments et des
> exemples.**

---

## CORRIGÉ

### Le travail au brouillon — dix minutes, et elles sont décisives

**Premier geste : repérer la consigne.** « Qu''en pensez-vous ? » → plan
**dialectique**. Le sujet me donne d''ailleurs les deux positions, je n''ai pas à
les inventer.

**Deuxième geste : reformuler le problème en une question.** C''est elle qui ira
dans l''introduction.

> *L''initiative citoyenne supplée-t-elle l''État, ou l''excuse-t-elle ?*

**Troisième geste : chercher des arguments et des exemples.** Deux par partie,
et un exemple concret pour chacun. C''est ici que se gagne la note.

> **I. Oui, c''est un bel exemple de citoyenneté**
> - le quartier devient propre tout de suite, sans attendre
>   *exemple : les inondations qui refluent quand les caniveaux sont dégagés*
> - l''habitant qui a ramassé ne jette plus ; l''effort crée le respect
>   *exemple : les jeunes du groupe deviennent ceux qui rappellent les règles*
>
> **II. Non, c''est décharger l''État de ses devoirs**
> - le ramassage est un service public, déjà payé par l''impôt
>   *exemple : on paie deux fois, en taxes et en sueur*
> - si les habitants compensent, la commune n''a plus de raison d''agir
>   *exemple : le bac retiré qu''on ne remplace jamais*
>
> **III. Synthèse — déplacer la question**
> - l''initiative n''est utile que si elle est **visible et comptée**
> - ce n''est pas « faire à la place » mais « obliger à faire »

**Quatrième geste : vérifier que j''ai une concession.** Elle ira au début du
III.

---

### La rédaction

> **Introduction**
>
> Dans plusieurs quartiers de Douala et de Yaoundé, des groupes de jeunes se
> sont mis à ramasser eux-mêmes les ordures que le camion de la commune ne vient
> plus chercher. Faut-il s''en réjouir comme d''un réveil citoyen, ou s''en
> inquiéter comme d''une démission de l''État ? Les deux lectures se défendent, et
> il vaut la peine de les examiner avant de prendre parti.
>
> **I**
>
> Il est vrai, d''abord, que ces initiatives font du bien, et tout de suite. Un
> caniveau dégagé est un caniveau qui évacue : dans les quartiers bas de Douala,
> les habitants qui ont nettoyé leurs rigoles avant la saison des pluies ont vu
> l''eau se retirer en quelques heures là où elle stagnait des jours. Aucune
> réunion administrative n''aurait obtenu ce résultat en un samedi matin.
>
> Ce travail produit de plus un effet moins visible, et peut-être plus
> important : celui qui a ramassé les ordures ne les jette plus. Les jeunes qui
> ont passé une matinée à retirer des sachets d''un caniveau deviennent ceux qui
> interpellent le voisin négligent, et leur parole porte, parce qu''ils ont les
> mains sales. L''effort fait naître le respect mieux que l''affiche.
>
> **II**
>
> Cependant, cette belle image masque une question gênante. Le ramassage des
> ordures n''est pas un service rendu par charité : c''est un service public,
> financé par des taxes que les habitants de ces mêmes quartiers paient. Quand
> ils le font eux-mêmes, ils paient deux fois, une fois en argent et une fois en
> sueur, et personne ne leur rembourse la première.
>
> Il y a pire. Si les habitants compensent chaque défaillance, la commune n''a
> plus aucune raison de la corriger. Le bac retiré en janvier et jamais remplacé
> ne sera jamais remplacé, précisément parce que le quartier s''est organisé sans
> lui. L''initiative citoyenne, dans ce cas, ne complète pas le service public :
> elle l''enterre doucement.
>
> **III**
>
> Certes, on ne peut pas demander à des habitants de laisser pourrir leurs rues
> pour faire la preuve d''un manquement ; ce serait punir les enfants du quartier
> pour forcer la main d''une mairie. L''opposition entre les deux positions est
> donc moins nette qu''elle n''en a l''air.
>
> En réalité, la vraie question n''est pas de savoir s''il faut ramasser, mais ce
> que l''on fait de ce ramassage. Une collecte menée en silence excuse l''inaction
> ; une collecte comptée, affichée, adressée, l''accuse. Que les jeunes pèsent ce
> qu''ils ont retiré, qu''ils écrivent à la commune le nombre de sacs et la date,
> qu''ils demandent le remplacement du bac en joignant la liste de ce qu''ils ont
> fait à sa place : l''initiative devient alors une pression, et non plus une
> excuse. C''est ce qu''a fait une association de Bonabéri, qui tient un registre
> de ses sorties et l''envoie chaque trimestre à la mairie.
>
> **Conclusion**
>
> Ramasser soi-même ses ordures n''est donc ni une vertu en soi, ni une faute :
> tout dépend de ce qui suit le ramassage. Fait dans l''ombre, ce geste soulage
> l''administration ; fait au grand jour et documenté, il l''oblige. Peut-être
> est-ce là, plus largement, ce que devrait être la citoyenneté dans un pays où
> les services manquent : non pas remplacer l''État en se taisant, mais faire à
> sa place en le disant.

---

### Ce qui fait la note de cette copie

**Les idées sont pertinentes et illustrées.** Chaque argument est suivi d''un
exemple concret : les caniveaux de Douala, le bac retiré en janvier, le registre
de Bonabéri. Aucun paragraphe ne reste abstrait.

**L''organisation est visible.** L''introduction pose la question sous forme
interrogative. Les connecteurs marquent le plan : « Il est vrai, d''abord »,
« de plus », « Cependant », « Il y a pire », « Certes », « En réalité »,
« donc ». Le correcteur voit le plan sans le chercher.

**La concession est là**, au début du III : « Certes, on ne peut pas demander à
des habitants de laisser pourrir leurs rues ». Elle désamorce l''objection avant
qu''elle soit formulée.

**La synthèse déplace la question.** Elle ne dit pas « les deux positions se
valent ». Elle dit : la question n''est pas *s''il faut ramasser*, mais *ce qu''on
fait du ramassage*. Et elle tranche : documenté et adressé, le geste devient une
pression.

**La conclusion ouvre.** La dernière phrase élargit du quartier à la
citoyenneté, sans partir dans la généralité creuse.

**La longueur est tenue.** Trente-cinq lignes environ, comme demandé. Une copie
de soixante lignes n''est pas mieux notée : elle est moins bien tenue.

---

### Les cinq fautes qui coûtent le plus

Je les liste parce qu''elles reviennent dans presque toutes les copies.

**1. Ne pas lire la consigne.** « Qu''en pensez-vous » demandait les deux
positions. Un élève qui n''en défend qu''une perd la moitié des points d''idées,
même brillamment.

**2. Des arguments sans exemples.** Trois paragraphes d''idées générales, sans un
seul fait concret. C''est la copie la plus fréquente, et elle plafonne.

**3. Une synthèse qui refuse de trancher.** « Il faut trouver un équilibre »,
« chacun a ses raisons » : zéro.

**4. Pas d''introduction, ou une introduction qui recopie le sujet.**
L''introduction doit **reformuler** le problème, pas le répéter.

**5. L''oubli de la relecture.** Les cinq dernières minutes servent à chasser les
accords du participe passé, les « si j''aurais », les homophones. Tu as vu au
chapitre 11 qu''un test de trois secondes règle chacune de ces fautes. Cinq
minutes, c''est cent tests.
', NULL, 36),
    (v_chapitre_id, 'Simulation : composer et se faire corriger', 7, 'interactif', '{
  "widget": "redaction-argumentee",
  "consigne": "L''épreuve en conditions. Un sujet s''affiche avec un chronomètre d''une heure trente, et la simulation t''impose le brouillon avant la rédaction : tu dois souligner le verbe de la consigne, reformuler le problème en une question, et poser deux arguments avec leur exemple par partie avant qu''elle ouvre la page de rédaction. Pendant que tu écris, un panneau latéral coche ce que le correcteur cherche — l''introduction qui reformule, les connecteurs, la concession, l''exemple concret dans chaque paragraphe, la synthèse qui tranche. À la fin, elle note sur les trois critères officiels et te montre les cinq fautes qui coûtent le plus, avec celles que tu as commises en rouge. Huit sujets, tous de sessions réelles ou de leur forme exacte."
}', NULL, 10),
    (v_chapitre_id, 'Quiz du chapitre 15', 8, 'quiz', '{
  "titre": "Vérifie que tu as compris",
  "questions": [
    {
      "question": "Quelle est la force du témoignage, et quelle est sa faiblesse ?",
      "choix": [
        "Il est toujours vrai",
        "Il est incontestable — personne ne peut nier ce que tu as vécu — mais il est unique : un seul cas ne prouve pas une règle",
        "Il est long",
        "Il n''a pas de faiblesse"
      ],
      "bonne": 1,
      "explication": "C''est pourquoi un bon texte ne repose jamais sur le seul témoignage : il l''emploie comme exemple, au service d''un argument plus général."
    },
    {
      "question": "Quelle phrase transforme un récit en argument ?",
      "choix": [
        "La première",
        "La conclusion, au présent, qui dit ce que le récit prouve : « C''est ainsi que l''on perd des élèves »",
        "Le titre",
        "Aucune"
      ],
      "bonne": 1,
      "explication": "Sans elle, tu as raconté une anecdote. Le récit se dit au passé composé et à l''imparfait ; la conclusion au présent, parce qu''elle vaut encore."
    },
    {
      "question": "La consigne dit « Défendez cette opinion ». Quel plan ?",
      "choix": [
        "Dialectique",
        "Thématique : trois arguments qui vont tous dans le même sens, du plus faible au plus fort",
        "Comparatif",
        "Narratif"
      ],
      "bonne": 1,
      "explication": "« Discutez » et « qu''en pensez-vous » appellent le plan dialectique. Se tromper de plan coûte la moitié de la note, même en écrivant bien."
    },
    {
      "question": "Dans quel ordre ranger les arguments d''un plan thématique ?",
      "choix": [
        "Du plus fort au plus faible",
        "Du plus faible au plus fort : le lecteur garde en mémoire ce qu''il a lu en dernier",
        "Au hasard",
        "Par ordre alphabétique"
      ],
      "bonne": 1,
      "explication": "Garde ta meilleure raison pour la fin, et place une concession au début du troisième paragraphe."
    },
    {
      "question": "Qu''est-ce qu''une vraie synthèse ?",
      "choix": [
        "Un résumé des deux parties",
        "Une position qui tranche en déplaçant la question — pas « il faut un équilibre », mais « le vrai problème est ailleurs, et voici à quelle condition »",
        "Un refus de choisir",
        "Une répétition de l''introduction"
      ],
      "bonne": 1,
      "explication": "« Chacun a ses raisons » est la phrase la plus faible d''une copie. La synthèse ne cherche pas le milieu : elle cherche l''angle que ni l''une ni l''autre n''avait vu."
    },
    {
      "question": "Sur quels trois critères le BEPC note-t-il l''expression écrite ?",
      "choix": [
        "La longueur, l''écriture, la propreté",
        "La pertinence des idées, la cohérence de l''organisation, la correction linguistique",
        "L''orthographe seule",
        "Le nombre d''exemples"
      ],
      "bonne": 1,
      "explication": "Ce sont les trois critères du corrigé harmonisé national. Une copie de soixante lignes n''est pas mieux notée qu''une copie de trente bien tenue."
    },
    {
      "question": "Quelle est la faute la plus fréquente dans les copies de BEPC ?",
      "choix": [
        "Les fautes d''orthographe",
        "Des arguments sans exemples : trois paragraphes d''idées générales sans un seul fait concret",
        "Une copie trop courte",
        "Trop de connecteurs"
      ],
      "bonne": 1,
      "explication": "C''est la copie la plus fréquente, et elle plafonne. Chaque argument doit être suivi d''un exemple situé, daté ou chiffré."
    }
  ]
}', NULL, 5);

  RAISE NOTICE '8 leçons ajoutées au chapitre 15, Le témoignage, opposer ou concilier deux thèses.';
END $fr3$;
