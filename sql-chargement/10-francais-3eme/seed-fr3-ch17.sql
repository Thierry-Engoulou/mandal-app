-- ---------------------------------------------------------------------------
-- M'Andal — Français, classe de 3ème
-- Chapitre 17 : Les propositions subordonnées circonstancielles
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
  WHERE programme_id = v_programme_id AND ordre = 17;

  IF v_chapitre_id IS NULL THEN
    INSERT INTO public.chapitres (programme_id, titre, ordre, niveau)
    VALUES (v_programme_id, 'Les propositions subordonnées circonstancielles', 17, 'Module 3 : La vie économique')
    RETURNING id INTO v_chapitre_id;
    RAISE NOTICE 'Chapitre 17 créé.';
  END IF;

  -- Les leçons. Si le chapitre en a déjà, on passe son tour sans rien toucher.
  SELECT count(*) INTO v_deja FROM public.concepts WHERE chapitre_id = v_chapitre_id;
  IF v_deja > 0 THEN
    RAISE NOTICE 'Le chapitre 17 a déjà ses % leçons, je n''y touche pas.', v_deja;
    RETURN;
  END IF;

  INSERT INTO public.concepts
    (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes) VALUES
    (v_chapitre_id, 'Les sept circonstancielles, et la conjonction qui les annonce', 1, 'texte', '
Troisième et dernière des subordonnées du programme — et la plus riche, car
elle se décline en sept sens différents.

Ce chapitre achève la **question 5** du BEPC : *relevez les propositions,
nommez-les, donnez la fonction de la subordonnée*. Après lui, tu sauras nommer
n''importe quelle subordonnée du français.

### Définition

La **proposition subordonnée circonstancielle** est introduite par une
**conjonction de subordination** autre que *que* seul, et elle indique une
**circonstance** de l''action de la principale.

> Je rentrerai **quand la pluie aura cessé**.
> *(quand ? → circonstance de temps)*

### Ce qui la distingue des deux autres

Tu connais maintenant les trois.

La **relative** complète un **nom**, et son pronom a une fonction.
La **complétive** complète un **verbe**, et son « que » n''a pas de fonction.
La **circonstancielle** complète la **phrase entière**, et on peut souvent la
déplacer.

> **Quand la pluie aura cessé**, je rentrerai.
> Je rentrerai **quand la pluie aura cessé**.

Les deux phrases sont correctes. C''est le test le plus sûr : **une
circonstancielle se déplace, une relative et une complétive ne se déplacent
pas.**

### Les sept sens

**Le TEMPS** — *quand ?*
> quand, lorsque, dès que, aussitôt que, pendant que, tandis que, depuis que,
> avant que, après que
>
> Je préviendrai ma mère **dès que j''arriverai**.

*Attention au couple qui tombe souvent : **avant que** demande le subjonctif,
**après que** demande l''indicatif.*

> Avant qu''il **parte**. / Après qu''il **est parti**.

**La CAUSE** — *pourquoi ?*
> parce que, puisque, comme, étant donné que, vu que, du moment que
>
> Le marché a fermé **parce que la pluie a commencé**.

*Nuance utile : « parce que » apporte une cause nouvelle ; « puisque » rappelle
une cause que l''interlocuteur connaît déjà.*

**La CONSÉQUENCE** — *avec quel effet ?*
> si bien que, de sorte que, au point que, tellement… que, si… que
>
> Il a tellement plu **que le pont a cédé**.

**Le BUT** — *dans quelle intention ?*
> pour que, afin que, de peur que, de crainte que
>
> Je pars tôt **pour que tu ne m''attendes pas**.

*Le but est toujours au **subjonctif**, sans exception : l''intention n''est pas
un fait accompli.*

**L''OPPOSITION ou la CONCESSION** — *malgré quoi ?*
> bien que, quoique, alors que, tandis que, même si, encore que
>
> **Bien qu''il pleuve**, le marché reste ouvert.

*Encore un couple à retenir : **bien que** demande le subjonctif, **même si**
demande l''indicatif.*

**La CONDITION** — *à quelle condition ?*
> si, à condition que, pourvu que, à moins que, au cas où
>
> **Si tu viens demain**, nous irons au marché.

*Tu connais la règle d''or depuis le chapitre 12 : jamais de conditionnel après
« si ».*

**La COMPARAISON** — *comme quoi ?*
> comme, ainsi que, de même que, plus… que, moins… que, autant que
>
> Il travaille **comme son père travaillait**.

### La méthode, en trois gestes

> 1. **Je repère la conjonction.** C''est elle qui porte le sens.
> 2. **Je pose la question** : quand ? pourquoi ? dans quelle intention ?
> 3. **Je nomme** : proposition subordonnée circonstancielle de…

Et retiens le principe général : **apprends les conjonctions, tu connaîtras les
circonstancielles.** C''est un travail de liste, et il se fait en une soirée.

---

**Exercice corrigé**

*Relever la subordonnée, donner sa nature complète, et prouver par le
déplacement que c''est bien une circonstancielle.*

*1. Le car est parti avant que nous soyons arrivés.*
*2. Il a tellement couru qu''il ne pouvait plus parler.*
*3. Nous avons attendu sous l''auvent parce que la pluie tombait fort.*
*4. Bien que la route soit coupée, le camion est passé.*

**Correction.**

*1.* La subordonnée est **« avant que nous soyons arrivés »**.

*Nature* : proposition subordonnée **circonstancielle de temps**, introduite
par la locution conjonctive *avant que*.

*La preuve par le déplacement* : « Avant que nous soyons arrivés, le car est
parti. » La phrase tient. C''est bien une circonstancielle.

*Et remarque le mode* : *avant que* commande le **subjonctif**, d''où « nous
**soyons** » et non « nous sommes ». C''est l''erreur la plus fréquente sur cette
locution.

*2.* La subordonnée est **« qu''il ne pouvait plus parler »**.

*Nature* : proposition subordonnée **circonstancielle de conséquence**. Elle
n''est pas introduite par « que » seul, mais par la locution **tellement… que**,
dont le premier élément se trouve dans la principale.

*La preuve par le déplacement* : ici, le déplacement est impossible, parce que
la locution est coupée en deux. C''est le cas particulier de la conséquence, et
il ne remet pas en cause la nature.

*Attention à ne pas confondre avec une complétive : « il a tellement couru » ne
réclame pas de complément d''objet. C''est le « tellement » qui annonce le
« que ».*

*3.* La subordonnée est **« parce que la pluie tombait fort »**.

*Nature* : proposition subordonnée **circonstancielle de cause**.

*La preuve par le déplacement* : « Parce que la pluie tombait fort, nous avons
attendu sous l''auvent. » La phrase tient.

*4.* La subordonnée est **« Bien que la route soit coupée »**.

*Nature* : proposition subordonnée **circonstancielle d''opposition**, ou de
concession — les deux appellations sont acceptées.

*La preuve par le déplacement* : « Le camion est passé bien que la route soit
coupée. » La phrase tient, et elle est même plus naturelle à l''écrit.

*Et le mode* : *bien que* commande le **subjonctif**, d''où « soit coupée ». Si
tu écris « bien que la route est coupée », c''est une faute, et elle s''entend
partout.
', NULL, 28),
    (v_chapitre_id, 'Figure : les sept circonstancielles', 2, 'figure', '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 580 330" width="580" height="330">
<rect width="580" height="330" fill="#ffffff"/>
<text x="290" y="24" text-anchor="middle" font-size="14" font-weight="700" fill="#0f172a">Les sept circonstancielles, et le mot qui les annonce</text>
<text x="290" y="42" text-anchor="middle" font-size="10" fill="#64748b">La conjonction donne le sens. Apprends les conjonctions, tu connaîtras les circonstancielles.</text>

<rect x="20" y="56" width="268" height="56" rx="6" fill="#dbeafe" stroke="#2563eb" stroke-width="1.4"/>
<text x="36" y="74" font-size="11" font-weight="700" fill="#1e3a8a">TEMPS — quand ?</text>
<text x="36" y="90" font-size="8" fill="#1e40af">quand · lorsque · dès que · pendant que</text>
<text x="36" y="104" font-size="8" fill="#1e40af">avant que (subj.) · après que (ind.)</text>

<rect x="296" y="56" width="264" height="56" rx="6" fill="#dcfce7" stroke="#15803d" stroke-width="1.4"/>
<text x="312" y="74" font-size="11" font-weight="700" fill="#14532d">CAUSE — pourquoi ?</text>
<text x="312" y="90" font-size="8" fill="#166534">parce que · puisque · comme · étant donné que</text>
<text x="312" y="104" font-size="8" font-style="italic" fill="#475569">la cause est un fait établi</text>

<rect x="20" y="120" width="268" height="56" rx="6" fill="#fef3c7" stroke="#ca8a04" stroke-width="1.4"/>
<text x="36" y="138" font-size="11" font-weight="700" fill="#78350f">CONSÉQUENCE — avec quel effet ?</text>
<text x="36" y="154" font-size="8" fill="#92400e">si bien que · de sorte que · au point que</text>
<text x="36" y="168" font-size="8" fill="#92400e">tellement… que · si… que</text>

<rect x="296" y="120" width="264" height="56" rx="6" fill="#fce7f3" stroke="#be185d" stroke-width="1.4"/>
<text x="312" y="138" font-size="11" font-weight="700" fill="#831843">BUT — dans quelle intention ?</text>
<text x="312" y="154" font-size="8" fill="#9d174d">pour que · afin que · de peur que</text>
<text x="312" y="168" font-size="8" font-style="italic" fill="#475569">toujours + SUBJONCTIF</text>

<rect x="20" y="184" width="268" height="56" rx="6" fill="#ede9fe" stroke="#6d28d9" stroke-width="1.4"/>
<text x="36" y="202" font-size="11" font-weight="700" fill="#4c1d95">OPPOSITION — malgré quoi ?</text>
<text x="36" y="218" font-size="8" fill="#5b21b6">bien que · quoique · alors que · même si</text>
<text x="36" y="232" font-size="8" font-style="italic" fill="#475569">bien que + SUBJ. · même si + IND.</text>

<rect x="296" y="184" width="264" height="56" rx="6" fill="#fed7aa" stroke="#ea580c" stroke-width="1.4"/>
<text x="312" y="202" font-size="11" font-weight="700" fill="#7c2d12">CONDITION — à quelle condition ?</text>
<text x="312" y="218" font-size="8" fill="#9a3412">si · à condition que · pourvu que</text>
<text x="312" y="232" font-size="8" font-style="italic" fill="#475569">jamais de conditionnel après « si »</text>

<rect x="20" y="248" width="268" height="52" rx="6" fill="#f1f5f9" stroke="#64748b" stroke-width="1.4"/>
<text x="36" y="266" font-size="11" font-weight="700" fill="#0f172a">COMPARAISON — comme quoi ?</text>
<text x="36" y="282" font-size="8" fill="#334155">comme · ainsi que · de même que</text>
<text x="36" y="294" font-size="8" fill="#334155">plus… que · moins… que · autant que</text>

<rect x="296" y="248" width="264" height="68" rx="6" fill="#1e293b"/>
<text x="428" y="268" text-anchor="middle" font-size="10" font-weight="700" fill="#ffffff">LA MÉTHODE</text>
<text x="312" y="286" font-size="8.5" fill="#cbd5e1">1. je repère la conjonction</text>
<text x="312" y="300" font-size="8.5" fill="#cbd5e1">2. je pose la question : quand ? pourquoi ?</text>
<text x="312" y="312" font-size="8.5" fill="#cbd5e1">3. je nomme : circonstancielle de…</text>
</svg>', NULL, 5),
    (v_chapitre_id, 'Simulation : nommer la circonstancielle', 3, 'interactif', '{
  "widget": "nommer-circonstancielle",
  "consigne": "Une phrase complexe s''affiche, et la simulation surligne la conjonction pour toi — c''est elle qui porte tout le sens. Tu poses ensuite la question : quand ? pourquoi ? dans quelle intention ? — et tu nommes. Vingt-quatre phrases, les sept sens du programme, et un bouton « déplacer la subordonnée » qui te prouve que c''en est bien une. Six pièges y sont glissés : des complétives et des relatives qui ressemblent à des circonstancielles."
}', NULL, 10),
    (v_chapitre_id, 'Les modes : où le subjonctif est obligatoire', 4, 'texte', '
Voici la partie qui rapporte le plus, et qui fait perdre le plus de points dans
les copies comme dans la vie courante.

### La règle en une ligne

**Les conjonctions qui présentent un fait NON RÉALISÉ commandent le
subjonctif.**

Tout découle de là. Le subjonctif est le mode de ce qui n''est pas accompli : le
souhait, l''intention, l''éventualité, ce qu''on redoute. L''indicatif est le mode
de ce qui est.

### Les conjonctions à subjonctif, par cœur

**Le BUT — toutes, sans exception.**
> pour que, afin que, de peur que, de crainte que
>
> Je pars tôt **pour que tu ne m''attendes pas**.

L''intention n''est jamais un fait accompli : c''est logique.

**L''OPPOSITION — les principales.**
> bien que, quoique, encore que, sans que
>
> **Bien qu''il ait compris**, il recommence.
> Il est sorti **sans que personne le voie**.

**Le TEMPS — seulement celles de l''antériorité.**
> avant que, jusqu''à ce que, en attendant que
>
> Préviens-moi **avant que tu partes**.

Et c''est logique encore : *avant que* parle d''un fait qui n''a pas eu lieu au
moment dont on parle.

**La CONDITION — toutes, sauf « si ».**
> à condition que, pourvu que, à moins que, pour peu que
>
> J''irai **à condition qu''il fasse beau**.

### Les pièges, à connaître absolument

Ce sont les couples où la ressemblance trompe.

**avant que → SUBJONCTIF / après que → INDICATIF**

> Avant qu''il **parte**. / Après qu''il **est parti**.

C''est le piège le plus posé. La logique le justifie : après que parle d''un fait
accompli.

*Dans la langue parlée, « après qu''il soit parti » est devenu très courant.
C''est une faute, et le BEPC la sanctionne encore.*

**bien que → SUBJONCTIF / même si → INDICATIF**

> Bien qu''il **pleuve**, nous sortons.
> Même s''il **pleut**, nous sortons.

Même sens, deux modes opposés. Le second contient un « si », et tu sais depuis
le chapitre 12 que « si » n''aime pas les fantaisies de mode.

**parce que → INDICATIF**

> Il est resté **parce qu''il pleuvait**.

La cause est un fait établi : indicatif, toujours. Beaucoup d''élèves mettent le
subjonctif par contagion de « bien que ». C''est une faute.

**si bien que → INDICATIF / de sorte que → les deux**

> Il a plu, **si bien que le pont a cédé**. *(conséquence réelle : indicatif)*
> Range-le **de sorte qu''on le trouve**. *(but : subjonctif)*

La même locution change de sens et de mode selon qu''elle rapporte un effet ou
une intention. C''est fin, mais le raisonnement est toujours le même : fait
accompli ou pas.

### Le test de l''oreille, encore

Tu l''as déjà rencontré au chapitre 10 : remplace ton verbe par **être** ou
**faire**.

> « Bien qu''il **soit** là » sonne juste ; « bien qu''il **est** là » sonne faux.
> « Après qu''il **est** parti » sonne juste ; « après qu''il **soit** parti »
> sonne faux à l''oreille exercée, même si tout le monde le dit.

---

**Exercice corrigé**

*Mettre le verbe au mode qui convient, et justifier par la conjonction.*

*1. Je t''écris avant que tu (partir).*
*2. Je t''ai écrit après que tu (partir).*
*3. Bien qu''il (pleuvoir), le marché reste ouvert.*
*4. Même s''il (pleuvoir), le marché reste ouvert.*
*5. Nous avons fermé parce que la pluie (tomber) trop fort.*
*6. Range les sacs pour que personne ne les (voir).*

**Correction.**

*1.* **Avant que** → subjonctif, parce que le départ n''a pas encore eu lieu.

> Je t''écris avant que tu **partes**.

*2.* **Après que** → indicatif, parce que le départ est accompli.

> Je t''ai écrit après que tu **es parti**.

*Les deux phrases sont le couple à retenir. Elles se ressemblent, elles sont
voisines dans le dictionnaire, et elles demandent deux modes opposés.*

*3.* **Bien que** → subjonctif. Le verbe *pleuvoir* est impersonnel : son
subjonctif est **qu''il pleuve**.

> Bien qu''il **pleuve**, le marché reste ouvert.

*4.* **Même si** → indicatif. Même sens que la phrase 3, mode opposé.

> Même s''il **pleut**, le marché reste ouvert.

*Mets les phrases 3 et 4 côte à côte dans ton cahier. Elles disent exactement
la même chose, et un correcteur voit immédiatement si tu connais la
différence.*

*5.* **Parce que** → indicatif. La cause est un fait établi.

> Nous avons fermé parce que la pluie **tombait** trop fort.

*Si tu as écrit « parce que la pluie tombât », c''est une faute par contagion de
« bien que ». Elle est fréquente chez les élèves qui viennent d''apprendre le
subjonctif.*

*6.* **Pour que** → subjonctif, sans exception. Le subjonctif de *voir* est
**voie**.

> Range les sacs pour que personne ne les **voie**.

*Et attention à l''orthographe : « voie » avec un e, du verbe voir au
subjonctif — à ne pas confondre avec « la voie » du chapitre 11, ni avec
« il voit ».*
', NULL, 28),
    (v_chapitre_id, 'Simulation : indicatif ou subjonctif après la conjonction', 5, 'interactif', '{
  "widget": "mode-circonstancielle",
  "consigne": "La conjonction s''affiche seule, d''abord, et la simulation te demande si elle présente un fait accompli ou un fait non réalisé — c''est de là que tout découle. Puis la phrase apparaît, et tu écris le verbe. Vingt phrases, et les quatre couples pièges y sont montés l''un contre l''autre : avant que contre après que, bien que contre même si, pour que contre parce que, si bien que contre de sorte que. Un bouton te rappelle l''astuce de l''oreille."
}', NULL, 10),
    (v_chapitre_id, 'Relever et nommer : la question 5 du BEPC, en entier', 6, 'texte', '
Nous y sommes. Tu connais les trois subordonnées, et tu peux maintenant
répondre à la question 5 quelle que soit la phrase proposée. Voici la méthode
complète.

### Rappel du chapitre 2 : compter les verbes conjugués

**Autant de verbes conjugués, autant de propositions.** C''est la règle de
départ, et elle ne souffre aucune exception.

Attention aux faux verbes :

> un **participe** employé comme adjectif ne compte pas — « une somme versée »
> un **infinitif** ne compte pas — « il veut partir »
> un verbe au participe présent ne compte pas — « marchant vite, il arriva »

Seul un verbe **conjugué à un mode personnel** — indicatif, subjonctif,
conditionnel, impératif — crée une proposition.

### La marche à suivre, en cinq gestes

**Geste 1 — J''entoure les verbes conjugués.** S''il n''y en a qu''un, la phrase est
simple, elle ne contient qu''une proposition indépendante, et j''ai fini.

**Geste 2 — Je repère les mots subordonnants.** Pronom relatif (*qui, que,
dont, où, lequel*), conjonction *que*, conjonction circonstancielle (*quand,
parce que, bien que*…).

**Geste 3 — Je découpe.** Chaque subordonnant ouvre une subordonnée. Ce qui
reste est la principale.

**Geste 4 — Je nomme chaque subordonnée.**
> un pronom relatif → **relative**, et je précise déterminative ou explicative
> un « que » sans antécédent → **complétive**
> une conjonction circonstancielle → **circonstancielle de…**

**Geste 5 — Je donne la fonction de la subordonnée.**
> relative → complément de son antécédent
> complétive → complément d''objet direct du verbe, en général
> circonstancielle → complément circonstanciel de la principale

### Le tableau complet

C''est celui qu''il faut avoir en tête le jour de l''épreuve.

> **RELATIVE** — introduite par qui, que, dont, où, lequel
> complète un NOM · le pronom a une fonction · ne se déplace pas
> fonction : complément de l''antécédent
>
> **COMPLÉTIVE** — introduite par la conjonction que
> complète un VERBE · le « que » n''a pas de fonction · ne se déplace pas
> fonction : complément d''objet direct, le plus souvent
>
> **CIRCONSTANCIELLE** — introduite par quand, parce que, bien que, si, pour
> que…
> complète la PHRASE · se déplace
> fonction : complément circonstanciel de temps, de cause, de but…

### Le piège de la phrase longue

Tu l''as rencontré au chapitre 14, dans le sujet corrigé. Une phrase peut être
longue, pleine de virgules, et ne contenir qu''un seul verbe conjugué : elle est
alors **simple**.

> « Chaque famille reçoit cinq plants et une somme modeste, versée non pas le
> jour de la plantation, mais trois ans plus tard. »

Un seul verbe conjugué, « reçoit ». *Versée* est un participe employé comme
adjectif. La phrase est **simple**, et beaucoup de candidats y inventent une
subordonnée qui n''existe pas.

### Le piège inverse

Une phrase courte peut contenir trois propositions.

> « Je sais qu''il viendra quand il pourra. »

Trois verbes conjugués : *sais*, *viendra*, *pourra*. Donc trois propositions :

> principale : « Je sais »
> complétive, complément d''objet direct de « sais » : « qu''il viendra »
> circonstancielle de temps, dans la complétive : « quand il pourra »

*Et note la finesse : la circonstancielle ne dépend pas de la principale mais
de la complétive. On dit qu''elle est enchâssée au second degré. Si tu le
signales, le correcteur le remarque.*

---

**Exercice corrigé**

*Relever toutes les propositions, nommer chacune, et donner la fonction des
subordonnées.*

*1. Comme la route était coupée, le chauffeur a pris le chemin qui longe la
rivière.*

*2. Je crois que nous arriverons avant la nuit, bien que le car soit parti en
retard.*

**Correction.**

*Phrase 1.*

**Geste 1 — les verbes conjugués** : *était*, *a pris*, *longe*. Trois verbes,
donc **trois propositions**.

**Geste 2 — les subordonnants** : *Comme* en tête, et *qui* au milieu.

**Geste 3 — le découpage** :

> « Comme la route était coupée » — ouverte par *comme*
> « le chauffeur a pris le chemin » — aucun subordonnant : c''est la
> **principale**
> « qui longe la rivière » — ouverte par le pronom relatif *qui*

**Geste 4 et 5 — nommer et donner la fonction** :

> **« Comme la route était coupée »** : proposition subordonnée
> **circonstancielle de cause**. Fonction : complément circonstanciel de cause
> de la principale.
>
> *Preuve par le déplacement : « Le chauffeur a pris le chemin qui longe la
> rivière, comme la route était coupée. » La phrase tient.*
>
> *Attention : « comme » peut aussi introduire une comparaison. Ici il signifie
> « puisque », donc c''est bien la cause. C''est le sens qui décide, pas le mot.*
>
> **« le chauffeur a pris le chemin »** : proposition **principale**.
>
> **« qui longe la rivière »** : proposition subordonnée **relative
> déterminative**. Son pronom *qui* est sujet de « longe », et son antécédent
> est « chemin ». Fonction de la proposition : complément de l''antécédent
> « chemin ».

*Phrase 2.*

**Geste 1 — les verbes conjugués** : *crois*, *arriverons*, *soit parti*. Trois
propositions.

**Geste 2 — les subordonnants** : *que*, et *bien que*.

**Geste 3 — le découpage** :

> « Je crois » — **principale**
> « que nous arriverons avant la nuit » — ouverte par *que*
> « bien que le car soit parti en retard » — ouverte par *bien que*

**Geste 4 et 5** :

> **« que nous arriverons avant la nuit »** : proposition subordonnée
> **conjonctive complétive**. Le « que » ne remplace aucun nom et n''a pas de
> fonction. Fonction de la proposition : **complément d''objet direct du verbe
> « crois »**.
>
> *Preuve par le remplacement : « Je crois à notre arrivée avant la nuit. »*
>
> **« bien que le car soit parti en retard »** : proposition subordonnée
> **circonstancielle d''opposition**. Fonction : complément circonstanciel
> d''opposition.
>
> *Preuve par le déplacement : « Bien que le car soit parti en retard, je crois
> que nous arriverons avant la nuit. » La phrase tient — et elle est même mieux
> construite.*
>
> *Et note le mode : « bien que » commande le subjonctif, d''où « soit parti ».*

*Dernière remarque, qui vaut un demi-point : « avant la nuit » n''est PAS une
proposition. Il n''y a pas de verbe conjugué — c''est un simple groupe nominal
complément circonstanciel. Beaucoup de candidats comptent quatre propositions
dans cette phrase à cause de ce « avant ». Compte les verbes, et rien d''autre.*
', NULL, 28),
    (v_chapitre_id, 'Simulation : la question 5, en entier', 7, 'interactif', '{
  "widget": "question-cinq-bepc",
  "consigne": "L''exercice complet de l''examen, en cinq gestes imposés. Tu entoures d''abord les verbes conjugués — et la simulation refuse les participes, les infinitifs et les participes présents que tu entourerais par erreur. Tu repères ensuite les subordonnants, tu découpes, tu nommes, tu donnes la fonction. Dix-huit phrases tirées de sessions réelles, dont trois phrases longues qui ne contiennent qu''un seul verbe conjugué, et deux phrases courtes qui en contiennent trois. Noté au demi-point, comme au BEPC."
}', NULL, 10),
    (v_chapitre_id, 'Quiz du chapitre 17', 8, 'quiz', '{
  "titre": "Vérifie que tu as compris",
  "questions": [
    {
      "question": "Qu''est-ce qui distingue une circonstancielle d''une relative et d''une complétive ?",
      "choix": [
        "Sa longueur",
        "Elle complète la PHRASE entière, et on peut souvent la déplacer",
        "Elle est toujours en tête",
        "Elle n''a pas de verbe"
      ],
      "bonne": 1,
      "explication": "« Quand la pluie aura cessé, je rentrerai » et « je rentrerai quand la pluie aura cessé » sont tous deux corrects. C''est le test le plus sûr."
    },
    {
      "question": "Quel mode après « avant que », et quel mode après « après que » ?",
      "choix": [
        "Les deux l''indicatif",
        "« Avant que » le subjonctif, « après que » l''indicatif — car après que parle d''un fait accompli",
        "Les deux le subjonctif",
        "Le conditionnel"
      ],
      "bonne": 1,
      "explication": "« Avant qu''il parte » / « après qu''il est parti ». C''est le piège le plus posé, et « après qu''il soit parti » reste une faute au BEPC."
    },
    {
      "question": "« Bien qu''il … » et « même s''il … » : quels modes ?",
      "choix": [
        "Les deux le subjonctif",
        "« Bien que » le subjonctif, « même si » l''indicatif — même sens, modes opposés",
        "Les deux l''indicatif",
        "Cela dépend du verbe"
      ],
      "bonne": 1,
      "explication": "« Bien qu''il pleuve » et « même s''il pleut » disent exactement la même chose. Un correcteur voit immédiatement si tu connais la différence."
    },
    {
      "question": "Quel mode après « pour que », « afin que », « de peur que » ?",
      "choix": [
        "L''indicatif",
        "Le subjonctif, sans exception : l''intention n''est jamais un fait accompli",
        "Le conditionnel",
        "Les deux se valent"
      ],
      "bonne": 1,
      "explication": "Toute la règle des modes tient à cela : les conjonctions qui présentent un fait NON RÉALISÉ commandent le subjonctif."
    },
    {
      "question": "Quel mode après « parce que » ?",
      "choix": [
        "Le subjonctif",
        "L''indicatif, toujours : la cause est un fait établi",
        "Le conditionnel",
        "L''impératif"
      ],
      "bonne": 1,
      "explication": "Beaucoup d''élèves y mettent le subjonctif par contagion de « bien que ». C''est une faute fréquente chez ceux qui viennent d''apprendre le subjonctif."
    },
    {
      "question": "Comment compte-t-on les propositions d''une phrase ?",
      "choix": [
        "On compte les virgules",
        "On compte les verbes CONJUGUÉS : participes, infinitifs et participes présents ne comptent pas",
        "On compte les mots de liaison",
        "On compte les sujets"
      ],
      "bonne": 1,
      "explication": "Une phrase longue pleine de virgules peut n''avoir qu''un seul verbe conjugué, et être simple. Une phrase courte peut en avoir trois."
    },
    {
      "question": "Dans « Je sais qu''il viendra quand il pourra », de quoi dépend la circonstancielle ?",
      "choix": [
        "De la principale",
        "De la complétive : elle est enchâssée au second degré, et le signaler se remarque",
        "De rien",
        "Du pronom"
      ],
      "bonne": 1,
      "explication": "Trois verbes, trois propositions : principale « je sais », complétive « qu''il viendra », et circonstancielle de temps « quand il pourra » à l''intérieur de la complétive."
    }
  ]
}', NULL, 5);

  RAISE NOTICE '8 leçons ajoutées au chapitre 17, Les propositions subordonnées circonstancielles.';
END $fr3$;
