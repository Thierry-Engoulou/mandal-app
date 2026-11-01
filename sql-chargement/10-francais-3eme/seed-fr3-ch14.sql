-- ---------------------------------------------------------------------------
-- M'Andal — Français, classe de 3ème
-- Chapitre 14 : Lecture méthodique : le texte argumentatif
-- Module 2 : Citoyenneté et environnement — 9 leçons
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
  WHERE programme_id = v_programme_id AND ordre = 14;

  IF v_chapitre_id IS NULL THEN
    INSERT INTO public.chapitres (programme_id, titre, ordre, niveau)
    VALUES (v_programme_id, 'Lecture méthodique : le texte argumentatif', 14, 'Module 2 : Citoyenneté et environnement')
    RETURNING id INTO v_chapitre_id;
    RAISE NOTICE 'Chapitre 14 créé.';
  END IF;

  -- Les leçons. Si le chapitre en a déjà, on passe son tour sans rien toucher.
  SELECT count(*) INTO v_deja FROM public.concepts WHERE chapitre_id = v_chapitre_id;
  IF v_deja > 0 THEN
    RAISE NOTICE 'Le chapitre 14 a déjà ses % leçons, je n''y touche pas.', v_deja;
    RETURN;
  END IF;

  INSERT INTO public.concepts
    (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes) VALUES
    (v_chapitre_id, 'Reconnaître un texte argumentatif', 1, 'texte', '
Deuxième chapitre de lecture méthodique de l''année. Au premier module, tu as
étudié le texte narratif, à travers le roman. Ici, nous changeons de terrain :
le texte qui ne raconte pas, mais qui **veut te faire changer d''avis**.

### Quatre types de textes

Pour situer, voici les quatre que tu dois savoir distinguer.

Le texte **narratif** raconte une histoire. Repères : des verbes d''action, un
récit au passé simple et à l''imparfait, des indicateurs de temps.

Le texte **descriptif** fait voir un lieu, un objet, une personne. Repères :
des verbes d''état, des adjectifs, des indicateurs de lieu.

Le texte **explicatif** fait comprendre un fonctionnement. Repères : le présent
de vérité générale, un vocabulaire technique, des liens de cause. Tu l''étudieras
au module 4.

Le texte **argumentatif** cherche à convaincre ou à persuader. Repères : une
opinion affirmée, des connecteurs logiques, des marques de la première
personne, des modalisateurs.

Un même texte peut mêler plusieurs types. Mais il y en a toujours un qui
domine, et c''est celui qu''on nomme.

### L''architecture du texte argumentatif

Trois étages, et il faut savoir les nommer sans se tromper. C''est la question
la plus posée.

**La thèse** est l''**opinion** que l''auteur veut faire admettre. Une seule par
texte, en général. Elle se formule en une phrase.

> « Il faut interdire les sacs plastiques. »

**Les arguments** sont les **raisons** de penser cela. Ils sont généraux,
abstraits, et chacun pourrait se défendre seul.

> « Ils mettent des siècles à se dégrader. »
> « Ils bouchent les canalisations et aggravent les inondations. »
> « Ils tuent le bétail qui les avale. »

**Les exemples** sont les **cas précis** qui illustrent un argument. Ils sont
particuliers, datés, situés.

> « À Douala, lors des inondations de septembre, les services techniques ont
> retiré douze tonnes de sachets des caniveaux du quartier Bonabéri. »

### L''erreur à ne jamais commettre

Confondre **argument** et **exemple**. C''est l''erreur numéro un, et elle coûte
des points à chaque session.

Le test est simple : **un argument est général, un exemple est particulier.**

> « Les sacs plastiques bouchent les canalisations. » → aucune date, aucun
> lieu, aucun nom → **argument**.
> « À Douala en septembre, douze tonnes retirées à Bonabéri. » → une ville, un
> mois, un chiffre, un quartier → **exemple**.

Dès qu''apparaissent un nom propre, une date ou un chiffre, tu es presque
toujours devant un exemple.

### Convaincre ou persuader ?

Encore une distinction qui tombe, et qui est simple une fois posée.

**Convaincre**, c''est s''adresser à la **raison**. L''auteur démontre, il aligne
des preuves, des chiffres, une logique. Le lecteur est d''accord parce qu''il a
compris.

**Persuader**, c''est s''adresser aux **sentiments**. L''auteur émeut, indigne,
fait rire ou fait peur. Le lecteur est d''accord parce qu''il est touché.

> Convaincre : « Douze tonnes de sachets ont été retirées des caniveaux. »
> Persuader : « Une vache est morte le ventre plein de sachets ; et nous
> continuons. »

La plupart des bons textes font les deux. On te demandera lequel domine.

---

**Exercice corrigé**

*Lire ce texte, puis répondre.*

> « Nos villes étouffent. Chaque année, les inondations de septembre emportent
> des maisons entières dans les bas quartiers de Douala, et chaque année on
> accuse la pluie. La pluie n''y est pour rien : ce sont nos sachets qui bouchent
> les caniveaux. Un sac plastique met quatre cents ans à disparaître ; celui que
> tu as jeté hier sera encore là quand ton arrière-petit-fils naîtra. Faut-il
> vraiment attendre qu''un enfant se noie dans un caniveau bouché pour agir ?
> Certes, l''interdiction gênera les petits commerçants, qui n''ont pas les moyens
> d''acheter des emballages en papier. Mais faut-il préférer un marché propre à
> une ville vivable ? »

*1. Quelle est la thèse ?*
*2. Relever deux arguments et un exemple.*
*3. L''auteur cherche-t-il surtout à convaincre ou à persuader ? Justifier par
deux procédés.*

**Correction.**

*1. La thèse.* L''auteur n''écrit nulle part « je pense que ». Il faut donc la
reconstituer, et c''est souvent le cas. Tout le texte tend vers une seule idée :

> **Il faut interdire les sacs plastiques.**

*Le dernier paragraphe le confirme : l''auteur envisage « l''interdiction » comme
la mesure à prendre, et il répond par avance à ceux qui s''y opposeraient.*

*2. Les arguments et l''exemple.*

**Argument 1** : « ce sont nos sachets qui bouchent les caniveaux » — c''est
général, sans date ni lieu précis.

**Argument 2** : « Un sac plastique met quatre cents ans à disparaître » — c''est
une donnée générale, vraie partout.

**Exemple** : « les inondations de septembre emportent des maisons entières dans
les bas quartiers de Douala » — une ville, un mois, un quartier. C''est précis,
situé, daté : c''est un exemple.

*Un piège à signaler : la phrase « celui que tu as jeté hier sera encore là
quand ton arrière-petit-fils naîtra » semble être un exemple parce qu''elle est
concrète. Mais elle ne rapporte aucun fait réel : elle imagine. C''est un
exemple fictif, ou mieux, une illustration — et c''est un procédé de persuasion.*

*3. Convaincre ou persuader ?*

L''auteur fait les deux, mais **la persuasion domine**. Deux procédés le
montrent.

**Premier procédé : la question rhétorique.** « Faut-il vraiment attendre qu''un
enfant se noie dans un caniveau bouché pour agir ? » Ce n''est pas une vraie
question : l''auteur n''attend pas de réponse, il impose la sienne. Et il choisit
l''image la plus bouleversante possible, celle d''un enfant mort.

**Second procédé : l''interpellation du lecteur.** « celui que tu as jeté hier ».
L''auteur passe au tutoiement et rend le lecteur personnellement responsable. Ce
n''est plus un raisonnement, c''est une mise en accusation.

*On relèvera aussi la métaphore du début — « nos villes étouffent » — qui donne
à la ville un corps et une respiration. Convaincre aurait consisté à aligner les
chiffres des services techniques ; persuader consiste à faire étouffer le
lecteur avec la ville.*
', NULL, 28),
    (v_chapitre_id, 'Figure : l''architecture d''un texte argumentatif', 2, 'figure', '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 580 310" width="580" height="310">
<rect width="580" height="310" fill="#ffffff"/>
<text x="290" y="24" text-anchor="middle" font-size="14" font-weight="700" fill="#0f172a">L&apos;architecture d&apos;un texte argumentatif</text>

<rect x="140" y="40" width="300" height="44" rx="6" fill="#1e293b"/>
<text x="290" y="60" text-anchor="middle" font-size="11" font-weight="700" fill="#ffffff">LA THÈSE</text>
<text x="290" y="76" text-anchor="middle" font-size="9" fill="#cbd5e1">l&apos;opinion que l&apos;auteur veut faire admettre</text>

<line x1="200" y1="84" x2="110" y2="104" stroke="#64748b" stroke-width="1.4"/>
<line x1="290" y1="84" x2="290" y2="104" stroke="#64748b" stroke-width="1.4"/>
<line x1="380" y1="84" x2="470" y2="104" stroke="#64748b" stroke-width="1.4"/>

<rect x="24" y="106" width="172" height="58" rx="6" fill="#dbeafe" stroke="#2563eb" stroke-width="1.4"/>
<text x="110" y="126" text-anchor="middle" font-size="10" font-weight="700" fill="#1e3a8a">ARGUMENT 1</text>
<text x="110" y="143" text-anchor="middle" font-size="8" fill="#1e40af">une raison de penser cela</text>
<text x="110" y="156" text-anchor="middle" font-size="8" font-style="italic" fill="#475569">abstrait, général</text>

<rect x="204" y="106" width="172" height="58" rx="6" fill="#dbeafe" stroke="#2563eb" stroke-width="1.4"/>
<text x="290" y="126" text-anchor="middle" font-size="10" font-weight="700" fill="#1e3a8a">ARGUMENT 2</text>
<text x="290" y="143" text-anchor="middle" font-size="8" fill="#1e40af">une autre raison</text>
<text x="290" y="156" text-anchor="middle" font-size="8" font-style="italic" fill="#475569">abstrait, général</text>

<rect x="384" y="106" width="172" height="58" rx="6" fill="#dbeafe" stroke="#2563eb" stroke-width="1.4"/>
<text x="470" y="126" text-anchor="middle" font-size="10" font-weight="700" fill="#1e3a8a">ARGUMENT 3</text>
<text x="470" y="143" text-anchor="middle" font-size="8" fill="#1e40af">une troisième raison</text>
<text x="470" y="156" text-anchor="middle" font-size="8" font-style="italic" fill="#475569">abstrait, général</text>

<line x1="110" y1="164" x2="110" y2="184" stroke="#2563eb" stroke-width="1.2" stroke-dasharray="3 3"/>
<line x1="290" y1="164" x2="290" y2="184" stroke="#2563eb" stroke-width="1.2" stroke-dasharray="3 3"/>
<line x1="470" y1="164" x2="470" y2="184" stroke="#2563eb" stroke-width="1.2" stroke-dasharray="3 3"/>

<rect x="24" y="186" width="172" height="48" rx="6" fill="#dcfce7" stroke="#15803d" stroke-width="1.4"/>
<text x="110" y="205" text-anchor="middle" font-size="10" font-weight="700" fill="#14532d">EXEMPLE</text>
<text x="110" y="222" text-anchor="middle" font-size="8" font-style="italic" fill="#166534">un cas précis, daté, situé</text>

<rect x="204" y="186" width="172" height="48" rx="6" fill="#dcfce7" stroke="#15803d" stroke-width="1.4"/>
<text x="290" y="205" text-anchor="middle" font-size="10" font-weight="700" fill="#14532d">EXEMPLE</text>
<text x="290" y="222" text-anchor="middle" font-size="8" font-style="italic" fill="#166534">un cas précis, daté, situé</text>

<rect x="384" y="186" width="172" height="48" rx="6" fill="#dcfce7" stroke="#15803d" stroke-width="1.4"/>
<text x="470" y="205" text-anchor="middle" font-size="10" font-weight="700" fill="#14532d">EXEMPLE</text>
<text x="470" y="222" text-anchor="middle" font-size="8" font-style="italic" fill="#166534">un cas précis, daté, situé</text>

<rect x="24" y="248" width="532" height="52" rx="6" fill="#fef3c7" stroke="#ca8a04" stroke-width="1.5"/>
<text x="290" y="266" text-anchor="middle" font-size="10" font-weight="700" fill="#78350f">LES CONNECTEURS — ce sont eux qui montrent l&apos;architecture</text>
<text x="40" y="285" font-size="9" fill="#92400e">d&apos;abord · ensuite · enfin   |   en effet · car · parce que   |   par exemple · ainsi</text>
<text x="40" y="296" font-size="9" fill="#92400e">certes… mais · cependant · toutefois   |   donc · c&apos;est pourquoi · par conséquent</text>
</svg>', NULL, 5),
    (v_chapitre_id, 'Simulation : trier thèse, arguments et exemples', 3, 'interactif', '{
  "widget": "trier-argumentation",
  "consigne": "Un texte argumentatif s''affiche, découpé en morceaux, et trois paniers : thèse, argument, exemple. Tu fais glisser chaque morceau, et la simulation te rappelle le test à chaque hésitation — un argument est général, un exemple est particulier ; dès qu''un nom propre, une date ou un chiffre apparaît, tu es devant un exemple. Huit textes, tous sur des questions de citoyenneté et d''environnement, et le dernier contient un exemple fictif pour voir si tu le repères."
}', NULL, 10),
    (v_chapitre_id, 'Les procédés de l''argumentation', 4, 'texte', '
Savoir repérer la thèse ne suffit pas. L''examen te demandera comment l''auteur
s''y prend. Voici les procédés que tu dois nommer.

### Les connecteurs logiques

Ce sont les mots qui montrent l''architecture. Les relever est le geste le plus
rentable de l''exercice, parce qu''ils se voient.

**L''addition et l''ordre** : d''abord, ensuite, enfin, de plus, par ailleurs, en
outre.

**La cause** : car, parce que, en effet, puisque, étant donné que.

**La conséquence** : donc, ainsi, c''est pourquoi, par conséquent, si bien que.

**L''opposition** : mais, cependant, toutefois, pourtant, néanmoins, en revanche.

**La concession** : certes… mais, bien que, même si, il est vrai que… cependant.

**L''illustration** : par exemple, ainsi, notamment, en particulier.

**La conclusion** : en somme, bref, finalement, en définitive.

### La concession : le procédé des bons textes

Je m''arrête dessus parce que c''est celui que les élèves n''utilisent jamais,
alors qu''il rapporte le plus.

**Concéder, c''est reconnaître un point à l''adversaire avant de le réfuter.**

> « **Certes**, l''interdiction gênera les petits commerçants. **Mais**
> faut-il préférer un marché propre à une ville vivable ? »

Pourquoi est-ce efficace ? Parce que l''auteur montre qu''il a entendu
l''objection. Le lecteur se sent respecté, et il baisse sa garde.

Un texte qui ne concède jamais paraît aveugle. Un texte qui concède paraît
honnête — et il est plus redoutable.

**Retiens le moule : certes… mais.** Si tu en places un seul dans ta rédaction
de BEPC, le correcteur le verra.

### La question rhétorique

C''est une question qui n''attend pas de réponse, parce que la réponse est
évidente — et c''est celle de l''auteur.

> « Faut-il attendre qu''un enfant se noie pour agir ? »

Elle est efficace parce qu''elle fait croire au lecteur qu''il décide lui-même,
alors qu''on lui a soufflé la réponse.

### Les autres procédés à connaître

**L''exemple** — tu le connais. Il ancre l''argument dans le réel.

**L''analogie et la comparaison** : rapprocher deux situations pour éclairer la
première.

> « Une ville sans caniveaux est un corps sans veines. »

**L''appel à l''autorité** : citer quelqu''un que le lecteur respecte.

> « Comme le disait Nelson Mandela… »

Attention : c''est un procédé faible sur le plan logique. Qu''une personne
illustre ait dit une chose n''en fait pas une vérité. Sache le repérer, et
sache t''en méfier.

**Le raisonnement par l''absurde** : supposer le contraire de sa thèse, et
montrer où cela mène.

> « Admettons qu''on ne fasse rien. Dans vingt ans, les caniveaux seront des
> remblais, et Douala sera sous l''eau six mois par an. »

**L''ironie** : dire le contraire de ce qu''on pense, pour que le lecteur
rétablisse.

> « Quelle belle idée que de laisser les sachets décorer nos rues. »

L''ironie est un procédé dangereux : si le lecteur la prend au premier degré,
tout s''effondre. Elle demande un signal — une exagération, un ton.

### Les modalisateurs

Ce sont les mots par lesquels l''auteur montre son **degré d''adhésion**. Les
relever révèle sa prudence ou son assurance.

> **Certitude** : évidemment, assurément, il est certain que, sans aucun doute.
> **Probabilité** : sans doute, probablement, il semble que, il est possible.
> **Jugement** : heureusement, malheureusement, à juste titre, hélas.

Un auteur qui écrit « il est certain que » et un auteur qui écrit « il semble
que » ne s''engagent pas de la même façon. Le BEPC te le demandera sous la forme
« relevez les marques de la subjectivité de l''auteur ».

---

**Exercice corrigé**

*Dans ce texte, nommer les procédés employés.*

> « Nos forêts tombent. **Certes**, le pays a besoin de devises, et le bois en
> rapporte ; **mais** faut-il vendre la maison pour payer le repas ? Un pays
> sans forêt est un corps sans poumon : il respire encore un moment, puis il
> s''arrête. **Admettons** que nous continuions au rythme actuel. **En 2050**,
> selon les services des eaux et forêts, il ne restera que des souches. Quelle
> belle réussite nous laisserons à nos enfants. »

**Correction.**

*« Certes… mais » : la **concession**.* L''auteur reconnaît que le pays a besoin
de devises — c''est l''argument adverse — avant de le réfuter. Il montre qu''il a
entendu l''objection, et le lecteur lui en sait gré.

*« faut-il vendre la maison pour payer le repas ? » : la **question
rhétorique**, doublée d''une **analogie**.* La question n''attend pas de réponse.
Et elle compare la vente du bois à la vente de sa propre maison : le
rapprochement rend l''absurdité sensible en six mots.

*« Un pays sans forêt est un corps sans poumon » : la **métaphore**, ou
l''**analogie filée**.* L''auteur ne se contente pas du rapprochement : il le
prolonge — « il respire encore un moment, puis il s''arrête ». C''est le procédé
le plus visuel du texte.

*« Admettons que nous continuions… » : le **raisonnement par l''absurde**.*
L''auteur suppose le contraire de ce qu''il souhaite, et montre où cela mène.

*« En 2050, selon les services des eaux et forêts » : l''**exemple chiffré** et
l''**appel à l''autorité**.* La date et la source donnent du poids. Note
cependant que la source est nommée sans être vérifiable : c''est un procédé
courant, et un lecteur averti le remarque.

*« Quelle belle réussite nous laisserons à nos enfants. » : l''**ironie**.*
L''auteur dit exactement le contraire de ce qu''il pense. Le signal est dans
l''écart entre « belle réussite » et ce qui précède — des souches.

*Six procédés en six lignes. C''est beaucoup, et c''est ce qui fait la densité
d''un texte argumentatif bien écrit : chaque phrase y travaille.*
', NULL, 28),
    (v_chapitre_id, 'Simulation : nommer les procédés', 5, 'interactif', '{
  "widget": "proceder-argumentation",
  "consigne": "Un texte s''affiche, et tu cliques sur chaque passage pour nommer le procédé : concession, question rhétorique, analogie, raisonnement par l''absurde, appel à l''autorité, ironie, exemple. La simulation te montre le signal que tu aurais dû voir — le « certes », le point d''interrogation sans réponse, l''écart ironique. Un second atelier te fait construire toi-même une concession sur cinq sujets, avec le moule « certes… mais » : c''est le procédé qui rapporte le plus en rédaction, et celui que personne n''emploie."
}', NULL, 10),
    (v_chapitre_id, 'Lire un texte argumentatif pas à pas : la méthode de l''examen', 6, 'texte', '
Voici la marche à suivre, celle que tu appliqueras le jour de l''épreuve. Elle
tient en cinq étapes, et elle convient à n''importe quel texte.

### Étape 1 — Le paratexte, avant tout

Avant de lire une ligne, lis ce qui entoure le texte : le **titre**, le nom de
l''**auteur**, la **source**, la **date**.

Cela t''apprend déjà beaucoup. Un texte tiré d''un journal militant ne se lit pas
comme un rapport administratif. Un texte de 1960 ne parle pas du même pays
qu''un texte de 2020.

Et attention : la date et la source sont souvent **la réponse à une question**.
On te demandera « à qui ce texte s''adresse-t-il ? », et c''est la source qui le
dit.

### Étape 2 — Première lecture, sans stylo

Lis le texte entièrement, sans rien souligner. Le but est de comprendre de quoi
il parle, pas encore de l''analyser.

À la fin de cette lecture, pose-toi une seule question : **de quoi veut-il me
convaincre ?** Si tu peux répondre en une phrase, tu as la thèse.

### Étape 3 — Deuxième lecture, le stylo à la main

Maintenant tu annotes, et tu cherches quatre choses.

**Les connecteurs logiques.** Entoure-les. Ils dessinent le plan du texte, et
le plan du texte est la moitié de l''analyse.

**Les mots chargés.** Souligne-les. Tu sais depuis le chapitre 13 qu''ils
révèlent le camp de l''auteur.

**Les marques de l''énonciation.** Qui parle ? *Je*, *nous*, *on* ? À qui ?
*Vous*, *tu*, personne ? Un texte qui tutoie son lecteur ne fait pas le même
travail qu''un texte impersonnel.

**Les procédés.** Repère les questions rhétoriques, les concessions, les
images. Note-les dans la marge avec leur nom.

### Étape 4 — Reconstituer le plan

Avec les connecteurs que tu as entourés, écris au brouillon :

> thèse : …
> argument 1 : … (connecteur : d''abord)
> exemple : …
> argument 2 : … (connecteur : de plus)
> concession : … (certes… mais)
> conclusion : … (connecteur : en somme)

Cinq lignes de brouillon, et tu peux répondre à presque toutes les questions.

### Étape 5 — Répondre, avec les citations

Et voici le point qui fait les notes. Le barème du BEPC accorde en général
**un point pour l''idée et un point pour la citation**, sur les deux points de
la question.

Autrement dit, un élève qui a parfaitement compris et qui ne cite pas perd la
moitié des points. À chaque session, à chaque question.

**Règle absolue : chaque réponse s''appuie sur une citation entre guillemets,
avec la ligne.**

> ✗ « L''auteur pense qu''il faut interdire les sachets. »
> ✓ « L''auteur pense qu''il faut interdire les sachets : il écrit que ce sont
> "nos sachets qui bouchent les caniveaux" (l. 4). »

### Les cinq questions qui reviennent toujours

En partie I, l''épreuve pose cinq questions de compréhension à deux points. Elles
portent presque toujours sur ces points :

> 1. De quoi parle le texte ? Quel est son thème ?
> 2. Quelle est la thèse de l''auteur ?
> 3. Relevez deux arguments, ou un argument et un exemple.
> 4. Quel procédé l''auteur emploie-t-il dans tel passage ?
> 5. Que pensez-vous de cette opinion ? *(question d''opinion personnelle,
>    toujours la dernière)*

Pour la cinquième, un conseil : **donne un avis nuancé et justifié**. Un élève
qui écrit « je suis d''accord » sans plus n''a aucun point. Un élève qui écrit
« je partage cette opinion pour telle raison, mais je crois qu''elle néglige tel
aspect » les a tous.

---

**Exercice corrigé**

*Appliquer les cinq étapes au texte suivant, et reconstituer son plan au
brouillon.*

> *Jean-Baptiste Mbarga, « La ville et ses déchets », Le Quotidien de Yaoundé,
> 12 mars 2023.*
>
> « (1) On accuse volontiers les habitants de nos quartiers de jeter leurs
> ordures n''importe où. (2) L''accusation est facile, et elle arrange ceux qui
> la portent. (3) D''abord, où jetteraient-ils ? (4) Dans un quartier de
> quarante mille habitants, la commune a installé six bacs, et le camion passe
> une fois par semaine quand il passe. (5) Ensuite, il faut rappeler que
> ramasser les ordures est un service public, financé par l''impôt que ces mêmes
> habitants paient. (6) Certes, une partie de la population jette sans se
> soucier de rien, et aucune excuse ne la lavera. (7) Mais faut-il punir tout un
> quartier pour l''incivilité de quelques-uns ? (8) En somme, avant de donner des
> leçons, que la commune fasse passer le camion. »

**Correction.**

*Étape 1 — Le paratexte.* Un article de presse, signé, daté de mars 2023, paru
dans un quotidien de Yaoundé. Le texte s''adresse donc à un lectorat urbain
camerounais, et il est récent. L''auteur n''est pas un fonctionnaire : il prend
position contre la commune.

*Étape 2 — La thèse.* De quoi veut-il me convaincre ? Que la responsabilité des
ordures incombe d''abord à la commune, et non aux habitants.

*Étape 3 — Les annotations.*

> Connecteurs : « D''abord » (3), « Ensuite » (5), « Certes… Mais » (6-7),
> « En somme » (8).
> Mots chargés : « accuse », « L''accusation est facile », « arrange ceux qui la
> portent », « donner des leçons ». Tous du côté du reproche adressé à
> l''autorité.
> Énonciation : « On » indéfini au début, qui désigne les accusateurs sans les
> nommer ; aucun « je ». L''auteur reste en retrait, ce qui donne un ton de
> constat.
> Procédés : question rhétorique en (3) et en (7), concession en (6-7), exemple
> chiffré en (4).

*Étape 4 — Le plan reconstitué.*

> thèse : la commune, et non les habitants, est responsable des ordures
> argument 1 (3-4) : il n''y a pas d''endroit où jeter
>    exemple (4) : six bacs pour quarante mille habitants, un camion par semaine
> argument 2 (5) : le ramassage est un service public, déjà payé par l''impôt
> concession (6) : certes, une partie de la population jette sans se soucier
> réfutation (7) : mais on ne punit pas un quartier pour quelques-uns
> conclusion (8) : que la commune fasse passer le camion

*Étape 5 — Un exemple de réponse citée.*

Question : *quel argument l''auteur oppose-t-il à ceux qui accusent les
habitants ?*

> « L''auteur répond que les habitants n''ont nulle part où jeter leurs ordures.
> Il le prouve par un chiffre : dans un quartier de quarante mille habitants,
> "la commune a installé six bacs, et le camion passe une fois par semaine quand
> il passe" (l. 4). La restriction finale, "quand il passe", souligne que même
> ce service minimal n''est pas assuré. »

*Note ce que fait cette réponse : elle donne l''idée, elle cite entre guillemets
avec la ligne, et elle ajoute un commentaire sur un détail de la citation. C''est
le modèle à reproduire, et il vaut les deux points.*
', NULL, 28),
    (v_chapitre_id, 'Simulation : la lecture en cinq étapes', 7, 'interactif', '{
  "widget": "lecture-argumentative",
  "consigne": "Un texte s''ouvre avec son paratexte caché, et la simulation te fait suivre les cinq étapes dans l''ordre : elle te montre d''abord la source et la date et te demande ce que tu en déduis, puis elle t''interdit de souligner pendant la première lecture, puis elle ouvre le stylo. Tu entoures les connecteurs, tu soulignes les mots chargés, et elle reconstitue le plan à mesure. À la fin, elle te fait rédiger une réponse et la note comme au BEPC : un point pour l''idée, un point pour la citation. Six textes de presse camerounaise."
}', NULL, 10),
    (v_chapitre_id, 'Sujet type BEPC — Étude de texte, 20 points, corrigé', 8, 'texte', '
Voici une épreuve complète, dans la forme exacte de l''examen, avec son corrigé
et son barème. Prends une feuille, compose en deux heures, puis compare.

---

## SUJET

**Texte.** *Adapté d''un article de presse camerounaise, 2024.*

> (1) Il n''est pas un seul village de ce pays où l''on n''ait planté un arbre un
> jour de cérémonie. (2) Les ministres viennent, les photographes aussi, la
> terre est retournée, le jeune plant est mis en place, et tout le monde
> repart. (3) Six mois plus tard, le plant est mort.
>
> (4) Ce n''est pas la faute des ministres, ni même des photographes. (5) C''est
> que reboiser n''est pas planter : c''est arroser pendant trois saisons, c''est
> protéger des chèvres, c''est confier l''arbre à quelqu''un qui en répondra. (6)
> Or nous aimons les cérémonies et nous détestons les trois saisons.
>
> (7) Certes, les grandes campagnes nationales ont leur utilité : elles font
> parler, et il faut bien que l''on parle. (8) Mais combien de millions de plants
> annoncés chaque année pour combien d''arbres debout cinq ans après ? (9) La
> question n''est jamais posée, et pour cause : personne ne compte.
>
> (10) À Ngaoundéré, une association de femmes a pris le problème autrement.
> (11) Chaque famille reçoit cinq plants et une somme modeste, versée non pas
> le jour de la plantation, mais trois ans plus tard, et seulement pour les
> arbres encore vivants. (12) Sur mille deux cents plants distribués en 2019,
> neuf cents étaient debout en 2022. (13) Le taux est de soixante-quinze pour
> cent, là où les campagnes nationales plafonnent à dix.
>
> (14) Faut-il en conclure qu''il ne faut plus rien planter ? (15) Bien sûr que
> non. (16) Il faut cesser de compter les trous et commencer à compter les
> arbres.

---

**PARTIE I — COMPRÉHENSION DU TEXTE (10 points)**

*1. Quel est le thème de ce texte ? (2 pts)*

*2. Quelle est la thèse défendue par l''auteur ? (2 pts)*

*3. Relevez un argument et un exemple, et justifiez votre choix. (2 pts)*

*4. Expliquez le procédé employé à la phrase (8), et dites ce qu''il apporte au
texte. (2 pts)*

*5. « Il faut cesser de compter les trous et commencer à compter les arbres. »
Que pensez-vous de cette formule ? (2 pts)*

**PARTIE II — CONNAISSANCE ET MANIEMENT DE LA LANGUE (10 points)**

*1. Expliquez le sens des mots « reboiser » (5) et « plafonnent » (13). (2 pts)*

*2. Relevez quatre mots appartenant au champ lexical de l''arbre. (2 pts)*

*3. Donnez la nature et la fonction de « qui » dans « quelqu''un qui en
répondra » (5). (2 pts)*

*4. À quel temps est « est » dans la phrase (3) ? Réécrivez cette phrase au
passé simple. (2 pts)*

*5. Relevez les propositions de la phrase (11), nommez-les et donnez la fonction
de la subordonnée. (2 pts)*

---

## CORRIGÉ

**PARTIE I**

**1. Le thème (2 pts).** *Un point pour l''idée, un point pour la citation.*

> Le texte traite de l''**échec du reboisement au Cameroun**, et plus précisément
> de l''écart entre les campagnes de plantation spectaculaires et le nombre
> d''arbres réellement vivants quelques années plus tard. L''auteur résume lui-même
> ce décalage : « reboiser n''est pas planter » (l. 5).

*Erreur à éviter : répondre « le texte parle de l''environnement ». C''est trop
large, et cela ne vaut que la moitié du point.*

**2. La thèse (2 pts).**

> L''auteur soutient qu''**il faut changer la manière de reboiser** : non plus
> multiplier les plantations de cérémonie, mais assurer le suivi des arbres et
> mesurer les résultats. Il le formule dans sa dernière phrase : « Il faut
> cesser de compter les trous et commencer à compter les arbres » (l. 16).

*Attention à ne pas écrire que l''auteur est contre le reboisement : la phrase
(15), « Bien sûr que non », l''interdit expressément. Les correcteurs attendent
cette nuance.*

**3. Un argument et un exemple (2 pts).**

> **Argument** : « reboiser n''est pas planter : c''est arroser pendant trois
> saisons, c''est protéger des chèvres, c''est confier l''arbre à quelqu''un qui en
> répondra » (l. 5). C''est un argument parce qu''il énonce une vérité générale,
> valable partout, sans date ni lieu.
>
> **Exemple** : l''association de femmes de Ngaoundéré, qui verse la prime trois
> ans après la plantation et seulement pour les arbres vivants, avec « neuf
> cents » plants debout « sur mille deux cents » distribués (l. 10-12). C''est un
> exemple parce qu''il est situé — une ville —, daté — 2019 et 2022 — et chiffré.

*Le test est rappelé : un argument est général, un exemple est particulier. Dès
qu''apparaissent un nom propre, une date ou un chiffre, c''est un exemple.*

**4. Le procédé de la phrase 8 (2 pts).**

> La phrase (8), « Mais combien de millions de plants annoncés chaque année pour
> combien d''arbres debout cinq ans après ? », est une **question rhétorique** :
> l''auteur n''attend pas de réponse, puisqu''il donne la sienne à la phrase
> suivante — « personne ne compte » (l. 9).
>
> Elle apporte deux choses au texte. D''une part, elle **oppose deux chiffres**
> sans avoir à les donner, ce qui souligne précisément qu''on ne les connaît pas.
> D''autre part, elle fait participer le lecteur, qui cherche la réponse et
> découvre qu''il n''y en a pas.
>
> On notera qu''elle suit immédiatement une **concession**, « Certes, les grandes
> campagnes nationales ont leur utilité » (l. 7) : l''auteur accorde un point à
> l''adversaire avant de le réfuter, ce qui rend sa critique plus difficile à
> rejeter.

*Signaler la concession en plus de la question rhétorique n''est pas exigé, mais
c''est ce qui distingue une réponse à deux points d''une réponse à un point et
demi.*

**5. Que pensez-vous de la formule ? (2 pts)**

*Cette question est une question d''opinion. Il n''y a pas de bonne réponse, mais
il y a de mauvaises façons de répondre : approuver sans justifier, ou se
contenter de reformuler la phrase. Voici un modèle de réponse complète, qui
prend position et nuance.*

> Cette formule me paraît juste, et bien trouvée. Elle oppose deux gestes qui se
> ressemblent — creuser un trou, voir un arbre — mais qui ne mesurent pas la
> même chose : l''un mesure l''effort, l''autre le résultat. Beaucoup de politiques
> publiques se jugent ainsi au nombre d''actions entreprises plutôt qu''aux effets
> obtenus.
>
> Je crois cependant qu''elle simplifie un peu. Compter les arbres suppose de
> pouvoir y retourner cinq ans après, ce qui coûte de l''argent et du personnel
> ; il est plus facile de tenir cette exigence pour une association de quartier
> que pour une campagne nationale couvrant dix régions. L''exemple de Ngaoundéré
> est convaincant, mais il porte sur mille deux cents plants, pas sur des
> millions.
>
> La formule indique donc la bonne direction sans dire comment y aller.

*Note la structure : j''approuve, je justifie, je nuance en m''appuyant sur un
chiffre du texte, je conclus. Quatre mouvements, dix lignes, deux points.*

---

**PARTIE II**

**1. Le sens des mots (2 pts).** *Un point par mot.*

> **« reboiser »** (l. 5) : replanter des arbres sur un terrain qui en a été
> dépouillé. Le mot est formé du préfixe **re-**, qui marque la répétition ou le
> retour à un état antérieur, et du radical **bois**. On reconnaît la même
> famille dans *boisé*, *déboisement*, *boisement*.
>
> **« plafonnent »** (l. 13) : atteignent une limite qu''elles ne dépassent pas.
> Le verbe vient du nom *plafond*, le haut d''une pièce, et il est employé ici au
> **sens figuré** : les campagnes nationales butent contre un maximum de dix
> pour cent.

*Donner la formation du mot et la famille, comme pour « reboiser », est ce que
le correcteur attend : c''est le point de la question 3 qui déborde sur celui-ci.*

**2. Le champ lexical de l''arbre (2 pts).** *Un demi-point par mot juste.*

> **arbre** (l. 1, 5, 16) — **planté / planter / plantation / plant** (l. 1, 2,
> 5, 8, 11, 12) — **reboiser** (l. 5) — **terre** (l. 2) — **arroser** (l. 5) —
> **debout** (l. 8, 12), employé ici pour les arbres vivants.

*Quatre suffisent. Attention à ne pas relever « chèvres » : l''animal appartient
au champ lexical de l''élevage, même s''il mange les plants.*

**3. Nature et fonction de « qui » (2 pts).**

> **Nature** : « qui » est un **pronom relatif**.
>
> **Fonction** : je lis la subordonnée seule, « qui en répondra ». **Qui**
> est-ce qui répondra ? *Qui*. Il est donc **sujet du verbe « répondra »**.
>
> Son **antécédent** est le pronom indéfini « quelqu''un », et la proposition
> « qui en répondra » est une **proposition subordonnée relative déterminative**,
> complément de son antécédent.

*Rappel du geste : cacher la principale et lire la relative seule. C''est ce qui
donne la fonction sans hésitation.*

**4. Le temps, et la réécriture au passé simple (2 pts).** *Un point pour
l''identification, un point pour la réécriture.*

> Dans la phrase (3), « le plant **est** mort », le verbe « est » est à
> l''**indicatif présent**. Il s''agit ici d''un **présent à valeur de constat**,
> qui rend le fait immédiat et définitif.
>
> *Une remarque pour être complet : « est mort » peut se lire de deux façons —
> comme le présent du verbe* être *suivi de l''adjectif* mort*, ce qui décrit un
> état ; ou comme le passé composé du verbe* mourir*, ce qui rapporte un
> événement. Les deux lectures sont recevables, et les corrigés harmonisés
> acceptent l''une comme l''autre à condition qu''elle soit justifiée.*
>
> **Réécriture au passé simple :**
>
> > Six mois plus tard, le plant **fut** mort.
>
> *Si l''on retient la seconde lecture — le passé composé de* mourir *— la
> réécriture au passé simple donne :*
>
> > Six mois plus tard, le plant **mourut**.
>
> *C''est cette seconde réécriture qui est la plus naturelle en français, et
> c''est celle que je te conseille d''écrire, en signalant en une ligne que tu as
> lu « est mort » comme un passé composé.*

**5. Les propositions de la phrase 11 (2 pts).**

*Voici la question la plus lourde de l''épreuve, et la phrase a été choisie
longue exprès. Procédons comme au chapitre 2 : je compte les verbes conjugués.*

> « Chaque famille **reçoit** cinq plants et une somme modeste, versée non pas
> le jour de la plantation, mais trois ans plus tard, et seulement pour les
> arbres encore vivants. »

> Il n''y a **qu''un seul verbe conjugué** : « reçoit ». « Versée » est un
> **participe passé employé comme adjectif**, épithète de « somme » ; il n''est
> pas conjugué et ne forme donc pas de proposition.
>
> **La phrase est donc une phrase simple**, constituée d''une seule **proposition
> indépendante** : il n''y a ni principale, ni subordonnée.

*C''est un piège classique, et il est redoutable. La phrase est longue, elle a
des virgules partout, elle semble complexe — et elle ne l''est pas. Le compte des
verbes CONJUGUÉS, et lui seul, décide. Beaucoup de candidats inventent ici une
subordonnée qui n''existe pas.*

*Si le sujet avait porté sur la phrase (5), la réponse aurait été tout autre :*

> « C''est que reboiser n''est pas planter : c''est arroser pendant trois saisons,
> c''est protéger des chèvres, c''est confier l''arbre à quelqu''un **qui en
> répondra**. »

> *Proposition principale : « C''est que reboiser n''est pas planter… » ;
> proposition subordonnée relative : « qui en répondra », complément de
> l''antécédent « quelqu''un ».*

---

**Barème récapitulatif**

> Partie I — 5 questions à 2 points = **10 points**
> Partie II — 5 questions à 2 points = **10 points**
> **Total : 20 points**

*Dans chaque question, compte un point pour l''idée et un point pour la
justification — citation, relevé, ou raisonnement. C''est la règle qui explique
pourquoi un élève qui a tout compris peut n''avoir que la moitié de la note.*
', NULL, 34),
    (v_chapitre_id, 'Quiz du chapitre 14', 9, 'quiz', '{
  "titre": "Vérifie que tu as compris",
  "questions": [
    {
      "question": "Quelle différence entre un argument et un exemple ?",
      "choix": [
        "Aucune",
        "Un argument est général et abstrait ; un exemple est particulier, daté, situé, chiffré",
        "L''argument est plus long",
        "L''exemple vient toujours en premier"
      ],
      "bonne": 1,
      "explication": "C''est l''erreur numéro un de l''épreuve. Dès qu''apparaissent un nom propre, une date ou un chiffre, tu es presque toujours devant un exemple."
    },
    {
      "question": "Quelle différence entre convaincre et persuader ?",
      "choix": [
        "Aucune",
        "Convaincre s''adresse à la raison par des preuves ; persuader s''adresse aux sentiments par l''émotion",
        "Convaincre est plus poli",
        "Persuader est une faute"
      ],
      "bonne": 1,
      "explication": "« Douze tonnes de sachets retirées » convainc. « Une vache est morte le ventre plein de sachets » persuade. La plupart des bons textes font les deux."
    },
    {
      "question": "Qu''est-ce que la concession, et pourquoi est-elle efficace ?",
      "choix": [
        "Un abandon",
        "Reconnaître un point à l''adversaire avant de le réfuter — « certes… mais » : le lecteur se sent entendu et baisse sa garde",
        "Une répétition",
        "Une conclusion"
      ],
      "bonne": 1,
      "explication": "C''est le procédé que les élèves n''emploient jamais et qui rapporte le plus. Un texte qui ne concède jamais paraît aveugle."
    },
    {
      "question": "Pourquoi se méfier de l''appel à l''autorité ?",
      "choix": [
        "Il n''y a pas à s''en méfier",
        "Parce qu''il est faible logiquement : qu''une personne illustre ait dit une chose n''en fait pas une vérité",
        "Parce qu''il est trop long",
        "Parce qu''il est interdit à l''examen"
      ],
      "bonne": 1,
      "explication": "Sache le repérer, et sache t''en méfier. C''est un réflexe de lecteur averti."
    },
    {
      "question": "Que fait-on AVANT de lire un texte à l''examen ?",
      "choix": [
        "On répond aux questions",
        "On lit le paratexte : titre, auteur, source, date — ils répondent souvent à une question à eux seuls",
        "On souligne tout",
        "On compte les lignes"
      ],
      "bonne": 1,
      "explication": "Un texte tiré d''un journal militant ne se lit pas comme un rapport administratif, et « à qui ce texte s''adresse-t-il ? » se répond par la source."
    },
    {
      "question": "Quelle est la règle absolue pour répondre aux questions de compréhension ?",
      "choix": [
        "Faire court",
        "Citer entre guillemets avec la ligne : le barème accorde un point pour l''idée et un point pour la citation",
        "Recopier le texte",
        "Répondre par oui ou non"
      ],
      "bonne": 1,
      "explication": "C''est la règle qui explique pourquoi un élève qui a tout compris peut n''avoir que la moitié de la note."
    },
    {
      "question": "À la question « que pensez-vous de cette opinion ? », que faut-il faire ?",
      "choix": [
        "Répondre « je suis d''accord »",
        "Prendre position, justifier, puis nuancer en s''appuyant sur le texte — approuver sans justifier ne vaut aucun point",
        "Reformuler la phrase",
        "Ne pas répondre"
      ],
      "bonne": 1,
      "explication": "Quatre mouvements : j''approuve, je justifie, je nuance avec un élément du texte, je conclus. Dix lignes, deux points."
    }
  ]
}', NULL, 5);

  RAISE NOTICE '9 leçons ajoutées au chapitre 14, Lecture méthodique : le texte argumentatif.';
END $fr3$;
