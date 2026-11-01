-- ---------------------------------------------------------------------------
-- M'Andal — Français, classe de 3ème
-- Chapitre 12 : Le conditionnel présent et passé des verbes du 3e groupe
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
  WHERE programme_id = v_programme_id AND ordre = 12;

  IF v_chapitre_id IS NULL THEN
    INSERT INTO public.chapitres (programme_id, titre, ordre, niveau)
    VALUES (v_programme_id, 'Le conditionnel présent et passé des verbes du 3e groupe', 12, 'Module 2 : Citoyenneté et environnement')
    RETURNING id INTO v_chapitre_id;
    RAISE NOTICE 'Chapitre 12 créé.';
  END IF;

  -- Les leçons. Si le chapitre en a déjà, on passe son tour sans rien toucher.
  SELECT count(*) INTO v_deja FROM public.concepts WHERE chapitre_id = v_chapitre_id;
  IF v_deja > 0 THEN
    RAISE NOTICE 'Le chapitre 12 a déjà ses % leçons, je n''y touche pas.', v_deja;
    RETURN;
  END IF;

  INSERT INTO public.concepts
    (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes) VALUES
    (v_chapitre_id, 'Former le conditionnel présent, et ne plus confondre avec le futur', 1, 'texte', '
Ce chapitre prépare la **question 4** du BEPC — identifier le temps d''un verbe
et réécrire. Elle vaut **deux points**.

### La fabrication

Le conditionnel présent se fabrique avec deux pièces que tu connais déjà.

> **radical du futur** + **terminaisons de l''imparfait**

Les terminaisons de l''imparfait, tu les as vues au chapitre 4 : *-ais, -ais,
-ait, -ions, -iez, -aient*.

> prendre → futur : je prendr**ai** → conditionnel : je prendr**ais**
> finir → futur : je finir**ai** → conditionnel : je finir**ais**
> venir → futur : je viendr**ai** → conditionnel : je viendr**ais**

Le radical ne change jamais entre les deux temps. Si tu sais faire le futur, tu
sais faire le conditionnel.

### Les verbes du troisième groupe

C''est le programme de ce chapitre, et ce sont eux qui ont des radicaux
irréguliers. Les voici, et il faut les connaître.

> **être** → je ser**ais**, nous ser**ions**
> **avoir** → j''aur**ais**, nous aur**ions**
> **aller** → j''ir**ais**, nous ir**ions**
> **faire** → je fer**ais**, nous fer**ions**
> **venir** → je viendr**ais**, nous viendr**ions**
> **voir** → je verr**ais**, nous verr**ions**
> **pouvoir** → je pourr**ais**, nous pourr**ions**
> **vouloir** → je voudr**ais**, nous voudr**ions**
> **devoir** → je devr**ais**, nous devr**ions**
> **savoir** → je saur**ais**, nous saur**ions**
> **falloir** → il faudr**ait**
> **valoir** → il vaudr**ait**
> **prendre** → je prendr**ais**
> **mettre** → je mettr**ais**
> **dire** → je dir**ais**
> **tenir** → je tiendr**ais**

Remarque que plusieurs ont **deux r** : *courir → je courrais*, *mourir → je
mourrais*, *voir → je verrais*, *pouvoir → je pourrais*, *envoyer → j''enverrais*.
C''est un détail qui se voit immédiatement dans une copie.

### Le piège de la première personne

Et nous y voilà. À la première personne du singulier, le futur et le
conditionnel ne diffèrent que par **une lettre** :

> je prendr**ai** → futur
> je prendr**ais** → conditionnel

Et les deux se prononcent presque pareil. C''est la faute la plus fréquente de
tout le français écrit, chez les élèves comme chez les adultes.

### Le test qui règle tout

**Remplace « je » par « il ».** Les deux temps deviennent alors très
différents à l''oreille.

> « Demain je prendr? le car. »
> → Demain **il prendra** le car. On entend un *a* net, c''est le **futur**.
> → Donc j''écris : **je prendrai**.

> « Si j''avais l''argent, je prendr? le car. »
> → Si j''avais l''argent, **il prendrait** le car. On entend un *è*, c''est le
> **conditionnel**.
> → Donc j''écris : **je prendrais**.

Fais ce test chaque fois que tu écris un verbe à la première personne du
singulier au futur ou au conditionnel. Trois secondes, et une faute évitée.

---

**Exercice corrigé**

*Écrire le verbe à la forme qui convient, et justifier par le test du « il ».*

*1. Demain, je (partir) à six heures.*
*2. Si j''avais le temps, je (partir) à pied.*
*3. Je (vouloir) vous parler un instant.*
*4. Avec un peu de chance, nous (pouvoir) arriver avant la nuit.*
*5. Je (savoir) le résultat demain.*

**Correction.**

*1.* Test : « Demain, **il partira** à six heures. » J''entends un *a* net, c''est
le futur.

> Demain, je **partirai** à six heures.

*2.* Test : « Si j''avais le temps, **il partirait** à pied. » J''entends un *è*,
c''est le conditionnel. Et la phrase le confirme : elle commence par *si* suivi
d''un imparfait.

> Si j''avais le temps, je **partirais** à pied.

*3.* Test : « **Il voudrait** vous parler un instant. » Conditionnel. C''est
d''ailleurs l''emploi de politesse, que nous verrons à la troisième leçon : « je
voudrais » est plus courtois que « je veux ».

> Je **voudrais** vous parler un instant.

*4.* Le verbe est à la première personne du **pluriel**, donc il n''y a pas de
piège : les deux temps s''y distinguent nettement. « Nous pourrons » au futur,
« nous pourrions » au conditionnel. Ici, « avec un peu de chance » exprime une
éventualité, donc le **conditionnel**.

> Avec un peu de chance, nous **pourrions** arriver avant la nuit.

*Note les deux r de « pourrions ». Le radical du futur de « pouvoir » est
« pourr- », et il se garde au conditionnel.*

*5.* Test : « **Il saura** le résultat demain. » J''entends un *a*, c''est le
futur. Le mot « demain » le confirmait.

> Je **saurai** le résultat demain.
', NULL, 28),
    (v_chapitre_id, 'Figure : le S qui sépare le futur du conditionnel', 2, 'figure', '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 580 300" width="580" height="300">
<rect width="580" height="300" fill="#ffffff"/>
<text x="290" y="24" text-anchor="middle" font-size="14" font-weight="700" fill="#0f172a">Futur ou conditionnel : un S qui change tout</text>

<rect x="20" y="40" width="540" height="62" rx="6" fill="#f8fafc" stroke="#94a3b8"/>
<text x="290" y="60" text-anchor="middle" font-size="10" font-weight="700" fill="#0f172a">LA FABRICATION — les deux temps partagent le même radical</text>
<text x="50" y="82" font-size="10" fill="#334155">radical du FUTUR</text>
<text x="168" y="82" font-size="11" font-weight="700" fill="#64748b">+</text>
<text x="190" y="82" font-size="10" fill="#2563eb">terminaisons du futur → FUTUR</text>
<text x="190" y="96" font-size="10" fill="#be185d">terminaisons de l&apos;imparfait → CONDITIONNEL</text>

<rect x="20" y="114" width="264" height="104" rx="6" fill="#dbeafe" stroke="#2563eb" stroke-width="1.5"/>
<text x="152" y="134" text-anchor="middle" font-size="12" font-weight="700" fill="#1e3a8a">FUTUR SIMPLE</text>
<text x="40" y="156" font-size="10" fill="#1e40af">je prendr</text>
<text x="110" y="156" font-size="10" font-weight="700" fill="#2563eb">ai</text>
<text x="160" y="156" font-size="10" fill="#1e40af">nous prendr</text>
<text x="250" y="156" font-size="10" font-weight="700" fill="#2563eb">ons</text>
<text x="40" y="174" font-size="10" fill="#1e40af">tu prendr</text>
<text x="110" y="174" font-size="10" font-weight="700" fill="#2563eb">as</text>
<text x="160" y="174" font-size="10" fill="#1e40af">vous prendr</text>
<text x="250" y="174" font-size="10" font-weight="700" fill="#2563eb">ez</text>
<text x="40" y="192" font-size="10" fill="#1e40af">il prendr</text>
<text x="110" y="192" font-size="10" font-weight="700" fill="#2563eb">a</text>
<text x="160" y="192" font-size="10" fill="#1e40af">ils prendr</text>
<text x="250" y="192" font-size="10" font-weight="700" fill="#2563eb">ont</text>
<text x="152" y="211" text-anchor="middle" font-size="9" font-style="italic" fill="#1e3a8a">le fait aura lieu</text>

<rect x="296" y="114" width="264" height="104" rx="6" fill="#fce7f3" stroke="#be185d" stroke-width="1.5"/>
<text x="428" y="134" text-anchor="middle" font-size="12" font-weight="700" fill="#831843">CONDITIONNEL PRÉSENT</text>
<text x="316" y="156" font-size="10" fill="#9d174d">je prendr</text>
<text x="386" y="156" font-size="10" font-weight="700" fill="#be185d">ais</text>
<text x="440" y="156" font-size="10" fill="#9d174d">nous prendr</text>
<text x="530" y="156" font-size="10" font-weight="700" fill="#be185d">ions</text>
<text x="316" y="174" font-size="10" fill="#9d174d">tu prendr</text>
<text x="386" y="174" font-size="10" font-weight="700" fill="#be185d">ais</text>
<text x="440" y="174" font-size="10" fill="#9d174d">vous prendr</text>
<text x="530" y="174" font-size="10" font-weight="700" fill="#be185d">iez</text>
<text x="316" y="192" font-size="10" fill="#9d174d">il prendr</text>
<text x="386" y="192" font-size="10" font-weight="700" fill="#be185d">ait</text>
<text x="440" y="192" font-size="10" fill="#9d174d">ils prendr</text>
<text x="530" y="192" font-size="10" font-weight="700" fill="#be185d">aient</text>
<text x="428" y="211" text-anchor="middle" font-size="9" font-style="italic" fill="#831843">le fait dépend d&apos;une condition</text>

<rect x="20" y="230" width="540" height="56" rx="6" fill="#fef3c7" stroke="#ca8a04" stroke-width="1.6"/>
<text x="290" y="250" text-anchor="middle" font-size="11" font-weight="700" fill="#78350f">LE TEST DE LA 1re PERSONNE — remplace « je » par « il »</text>
<text x="48" y="270" font-size="9" fill="#92400e">« je prendr? le car » → il prendrA le car → futur → j&apos;écris je prendrAI</text>
<text x="48" y="282" font-size="9" fill="#92400e">« je prendr? le car si… » → il prendrAIT le car → conditionnel → j&apos;écris je prendrAIS</text>
</svg>', NULL, 5),
    (v_chapitre_id, 'Simulation : futur ou conditionnel ?', 3, 'interactif', '{
  "widget": "futur-ou-conditionnel",
  "consigne": "Une phrase à trou s''affiche avec un verbe à la première personne du singulier, et deux boutons : -ai, -ais. Dès que tu cliques, la simulation réécrit la phrase avec « il » à la place de « je » et te fait entendre la différence — « il prendra » contre « il prendrait ». Vingt phrases, et le verdict porte sur le test autant que sur la réponse : si tu as cliqué juste sans faire le test, elle te le dit."
}', NULL, 10),
    (v_chapitre_id, 'Le conditionnel passé, et ce qu''il raconte', 4, 'texte', '
### La formation

Le conditionnel passé est un **temps composé**. Tu connais le mécanisme depuis
le chapitre 4.

> **auxiliaire au conditionnel présent** + **participe passé**

> j''**aurais** pris — je **serais** parti — nous **aurions** fini — elle
> **serait** venue

L''auxiliaire est *avoir* ou *être*, selon le verbe, exactement comme au passé
composé. Et les accords du participe passé suivent les mêmes règles.

> Elle **serait venue**. *(auxiliaire être → accord avec le sujet)*
> Les lettres qu''il **aurait écrites**. *(avoir, mais complément d''objet direct
> avant → accord)*

### Ce que le conditionnel passé raconte

C''est ici que le temps devient intéressant. Le conditionnel passé dit toujours
la même chose au fond : **ce qui ne s''est pas produit**.

Mais selon le contexte, il prend trois couleurs différentes, et le BEPC te
demandera de les nommer.

**Le regret.** Le locuteur parle de ce qu''il aurait voulu faire, et qu''il n''a
pas fait.

> J''**aurais aimé** être présent à ton mariage.
> Nous **aurions pu** partir plus tôt.

**Le reproche.** Le locuteur parle de ce que l''autre aurait dû faire, et n''a
pas fait. C''est le même temps, mais adressé à quelqu''un.

> Tu **aurais dû** me prévenir.
> Vous **auriez pu** faire attention.

Remarque que le reproche passe presque toujours par *devoir* ou *pouvoir*.
C''est un indice sûr.

**L''irréel du passé.** Le locuteur imagine ce qui serait arrivé si les choses
s''étaient passées autrement. Et on sait qu''elles ne se sont pas passées ainsi.

> Si j''avais su, je **serais** resté.
> Avec un peu plus de temps, nous **aurions terminé**.

### Pourquoi on l''appelle « irréel »

Parce que la phrase dit en creux que ce n''est pas arrivé.

> « Si j''avais su, je serais resté. »

Cette phrase affirme deux choses sans les dire : je n''ai **pas** su, et je ne
suis **pas** resté. C''est la force de ce temps : il raconte le monde qui n''a
pas eu lieu.

### Le conditionnel passé de l''information

Il existe un dernier emploi, que tu rencontres tous les jours à la radio.

> L''accident **aurait fait** trois blessés.
> Le ministre **serait arrivé** hier soir.

Le journaliste emploie le conditionnel pour dire : **je rapporte, je ne
garantis pas**. L''information n''est pas confirmée.

C''est un usage professionnel, précis et honnête, et il vaut la peine d''être
expliqué à des élèves : quand vous entendez un conditionnel dans un bulletin
d''information, le journaliste vous avertit qu''il n''a pas vérifié.

---

**Exercice corrigé**

*Identifier la valeur du conditionnel passé dans chaque phrase : regret,
reproche, irréel du passé, ou information non confirmée.*

*1. Tu aurais pu m''attendre cinq minutes.*
*2. Le feu aurait détruit trois boutiques du marché.*
*3. J''aurais tellement voulu voir ce match.*
*4. Si le car était parti à l''heure, nous serions déjà arrivés.*

**Correction.**

*1.* **Reproche.** Le locuteur s''adresse à « tu » et lui dit ce qu''il aurait dû
faire. L''indice est double : la deuxième personne, et le verbe *pouvoir*. Le
reproche passe presque toujours par *devoir* ou *pouvoir* au conditionnel
passé.

*2.* **Information non confirmée.** C''est une formulation de journaliste. Le
locuteur rapporte un fait qu''il n''a pas vérifié, et le conditionnel est sa
manière de le signaler. Si le fait était établi, il écrirait : « Le feu **a
détruit** trois boutiques. »

*C''est une nuance à connaître pour lire la presse : le passage du passé composé
au conditionnel passé marque la frontière entre ce qui est vérifié et ce qui ne
l''est pas.*

*3.* **Regret.** Le locuteur parle de lui-même, à la première personne, et de ce
qu''il aurait aimé faire. L''adverbe « tellement » renforce le sentiment. On sait
en creux qu''il n''a **pas** vu le match.

*4.* **Irréel du passé.** La phrase imagine ce qui serait arrivé si les choses
s''étaient passées autrement. Elle affirme en creux deux faits négatifs : le car
n''est **pas** parti à l''heure, et nous ne sommes **pas** encore arrivés.

*Remarque la construction : « si » + plus-que-parfait dans la subordonnée,
conditionnel passé dans la principale. C''est le système hypothétique de l''irréel
du passé, et c''est l''objet de la leçon suivante.*
', NULL, 26),
    (v_chapitre_id, 'Simulation : la valeur du conditionnel', 5, 'interactif', '{
  "widget": "valeurs-conditionnel",
  "consigne": "Une phrase s''affiche, et quatre étiquettes : regret, reproche, irréel du passé, information non confirmée. Tu classes, et la simulation souligne l''indice que tu aurais dû voir — la personne du verbe, le choix de « devoir » ou de « pouvoir », la subordonnée en « si », le contexte journalistique. Seize phrases, dont quatre extraites de bulletins d''information réels, et un exercice final où tu réécris la même nouvelle deux fois : une fois vérifiée, une fois non confirmée."
}', NULL, 10),
    (v_chapitre_id, 'Le système hypothétique : les trois constructions avec « si »', 6, 'texte', '
Voici la leçon la plus utile du chapitre. Elle règle une faute que l''on entend
partout, et qui se voit encore plus à l''écrit.

### La règle d''or

> **Après « si » de condition, JAMAIS de conditionnel.**

Jamais. Ni *si j''aurais*, ni *si je serais*, ni *si je pourrais*. C''est une
faute lourde, et le correcteur la sanctionne sèchement.

> ✗ Si j''**aurais** su, je ne serais pas venu.
> ✓ Si j''**avais** su, je ne serais pas venu.

Apprends-la par cœur : **les si n''aiment pas les ré**. C''est un moyen
mnémotechnique ancien, mais il a sauvé beaucoup de copies.

### Les trois systèmes

Il y en a trois, et chacun dit une chose différente sur le réel.

**Premier système — le possible.**

> **si + présent** → futur simple

> Si tu **viens** demain, nous **irons** au marché.

Le fait est possible, et peut-être même probable. Rien n''est tranché.

**Deuxième système — le potentiel ou l''irréel du présent.**

> **si + imparfait** → conditionnel présent

> Si j''**avais** de l''argent, je **partirais** en vacances.

Le fait est peu probable, ou franchement contraire à la réalité présente. Cette
phrase dit en creux : je n''ai pas d''argent.

**Troisième système — l''irréel du passé.**

> **si + plus-que-parfait** → conditionnel passé

> Si j''**avais eu** de l''argent, je **serais parti** en vacances.

Le fait ne s''est pas produit, et il est trop tard. Cette phrase dit en creux :
je n''ai pas eu d''argent, et je ne suis pas parti.

### Le tableau à retenir

> si + **présent** → **futur** *(c''est possible)*
> si + **imparfait** → **conditionnel présent** *(ce n''est pas le cas
> maintenant)*
> si + **plus-que-parfait** → **conditionnel passé** *(cela n''a pas eu lieu)*

Trois lignes. Elles couvrent tout ce que le français sait dire sur l''hypothèse.

### Attention : tous les « si » ne sont pas des conditions

Il existe un autre « si », celui de l''**interrogation indirecte**, et après
celui-là le conditionnel est parfaitement correct.

> Je me demande s''il **viendrait** si on l''invitait.
> Dis-moi si tu **serais** d''accord.

Comment les distinguer ? Le « si » de condition peut se remplacer par **« à
condition que »** ou par **« au cas où »**. Le « si » d''interrogation se
remplace par **« oui ou non »**.

> Je me demande s''il viendrait. → Je me demande **oui ou non** il viendrait →
> interrogation indirecte → conditionnel autorisé.

> Si tu viens, nous irons. → **À condition que** tu viennes → condition →
> conditionnel interdit.

### Les autres façons d''exprimer l''hypothèse

Le « si » n''est pas seul. Connaître les autres te permettra de varier ta
rédaction, et le correcteur le remarquera.

> **Au cas où** il viendrait, préviens-moi. *(+ conditionnel, et c''est
> régulier)*
> **À supposer qu''**il vienne, que ferons-nous ? *(+ subjonctif)*
> **En cas de** pluie, nous resterons. *(+ nom)*
> **Avec** un peu de chance, nous arriverons. *(+ nom)*
> **Sans** ton aide, je n''y serais pas arrivé. *(+ nom, et sous-entend un
> irréel)*

---

**Exercice corrigé**

*Corriger les fautes, compléter les trous, et nommer le système à chaque fois.*

*1. Si j''aurais su, je ne serais pas venu.*
*2. Si tu (venir) demain, nous (aller) au marché.*
*3. Si nous (partir) plus tôt, nous (éviter) l''embouteillage. (il est trop tard,
c''est fini)*
*4. Je me demande si tu (être) d''accord.*

**Correction.**

*1.* **Faute lourde.** Après « si » de condition, jamais de conditionnel. Le
sens est celui de l''irréel du passé — je n''ai pas su, et je suis venu — donc le
troisième système : si + plus-que-parfait, puis conditionnel passé.

> Si j''**avais su**, je ne **serais** pas **venu**.

*Système : irréel du passé.*

*2.* Rien n''indique que le fait soit improbable : c''est une simple éventualité.
Premier système.

> Si tu **viens** demain, nous **irons** au marché.

*Système : le possible. Si + présent → futur simple.*

*3.* La consigne le dit : il est trop tard, c''est fini. Troisième système.

> Si nous **étions partis** plus tôt, nous **aurions évité** l''embouteillage.

*Système : irréel du passé. Et la phrase affirme en creux que nous ne sommes
pas partis plus tôt, et que nous n''avons pas évité l''embouteillage.*

*4.* Attention, piège. Ce « si » n''est pas une condition. Test : je le remplace
par « oui ou non ». « Je me demande **oui ou non** tu es d''accord » — la phrase
a du sens, c''est donc une **interrogation indirecte**. Le conditionnel y est
autorisé, et c''est même lui qui convient si l''on veut la nuance de politesse.

> Je me demande si tu **serais** d''accord.

*C''est la seule construction où « si » et conditionnel peuvent voisiner. Si tu
l''écris sans avoir fait le test, tu auras raison par hasard ; fais le test, et
tu sauras pourquoi.*
', NULL, 28),
    (v_chapitre_id, 'Simulation : le système hypothétique', 7, 'interactif', '{
  "widget": "systeme-hypothetique",
  "consigne": "Trois curseurs : le degré de réalité — possible, improbable, trop tard — et les deux verbes de la phrase. Tu bouges le premier, et la simulation t''impose les temps corrects pour les deux autres ; tu bouges les verbes, et elle te dit ce que ta phrase affirme en creux. Essaie d''écrire « si j''aurais » : elle le refuse et t''explique pourquoi, une fois. Puis dix-huit phrases à compléter, avec quatre pièges où le « si » est une interrogation indirecte et où le conditionnel redevient correct."
}', NULL, 10),
    (v_chapitre_id, 'Quiz du chapitre 12', 8, 'quiz', '{
  "titre": "Vérifie que tu as compris",
  "questions": [
    {
      "question": "Comment se fabrique le conditionnel présent ?",
      "choix": [
        "Radical de l''imparfait + terminaisons du futur",
        "Radical du FUTUR + terminaisons de l''IMPARFAIT",
        "Radical du présent + -ais",
        "Avec l''auxiliaire avoir"
      ],
      "bonne": 1,
      "explication": "Le radical ne change jamais entre les deux temps : si tu sais faire le futur, tu sais faire le conditionnel. « je prendrai » devient « je prendrais »."
    },
    {
      "question": "Quel test permet de choisir entre « je prendrai » et « je prendrais » ?",
      "choix": [
        "Compter les lettres",
        "Remplacer « je » par « il » : on entend alors « il prendra » (futur) ou « il prendrait » (conditionnel)",
        "Lire à voix haute",
        "Mettre au pluriel"
      ],
      "bonne": 1,
      "explication": "À la première personne du singulier, les deux temps ne diffèrent que par un s, et se prononcent presque pareil. Le test du « il » les sépare nettement."
    },
    {
      "question": "« Tu aurais dû me prévenir. » Quelle valeur du conditionnel passé ?",
      "choix": [
        "Le regret",
        "Le reproche : le locuteur s''adresse à « tu » et dit ce qu''il aurait dû faire",
        "L''information non confirmée",
        "L''irréel du présent"
      ],
      "bonne": 1,
      "explication": "L''indice est double : la deuxième personne, et le verbe « devoir ». Le reproche passe presque toujours par « devoir » ou « pouvoir »."
    },
    {
      "question": "Pourquoi un journaliste dit-il « l''accident aurait fait trois blessés » ?",
      "choix": [
        "Par politesse",
        "Pour signaler qu''il rapporte sans garantir : l''information n''est pas confirmée",
        "Par habitude",
        "Parce que c''est le passé"
      ],
      "bonne": 1,
      "explication": "Si le fait était vérifié, il écrirait « l''accident A FAIT trois blessés ». Le conditionnel marque la frontière entre ce qui est vérifié et ce qui ne l''est pas."
    },
    {
      "question": "Quelle est la règle d''or après « si » de condition ?",
      "choix": [
        "Toujours le conditionnel",
        "JAMAIS de conditionnel : on écrit « si j''avais su », et non « si j''aurais su »",
        "Toujours le subjonctif",
        "Toujours le présent"
      ],
      "bonne": 1,
      "explication": "« Les si n''aiment pas les ré » : c''est un moyen mnémotechnique ancien, mais il a sauvé beaucoup de copies. La faute est lourde et sèchement sanctionnée."
    },
    {
      "question": "« Si nous étions partis plus tôt, nous … l''embouteillage. »",
      "choix": [
        "éviterons",
        "aurions évité : si + plus-que-parfait appelle le conditionnel passé, c''est l''irréel du passé",
        "éviterions",
        "évitions"
      ],
      "bonne": 1,
      "explication": "Trois systèmes : si + présent → futur ; si + imparfait → conditionnel présent ; si + plus-que-parfait → conditionnel passé."
    },
    {
      "question": "Existe-t-il un cas où « si » et conditionnel peuvent voisiner ?",
      "choix": [
        "Non, jamais",
        "Oui : après le « si » d''interrogation indirecte, qu''on peut remplacer par « oui ou non » — « je me demande si tu serais d''accord »",
        "Oui, à l''oral seulement",
        "Oui, au pluriel"
      ],
      "bonne": 1,
      "explication": "Le « si » de condition se remplace par « à condition que » et interdit le conditionnel. Le « si » d''interrogation se remplace par « oui ou non » et l''autorise."
    }
  ]
}', NULL, 5);

  RAISE NOTICE '8 leçons ajoutées au chapitre 12, Le conditionnel présent et passé des verbes du 3e groupe.';
END $fr3$;
