-- ---------------------------------------------------------------------------
-- M'Andal — Français, classe de 3ème
-- Chapitre 23 : Hiérarchiser ses arguments et rédiger une transition
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
  WHERE programme_id = v_programme_id AND ordre = 23;

  IF v_chapitre_id IS NULL THEN
    INSERT INTO public.chapitres (programme_id, titre, ordre, niveau)
    VALUES (v_programme_id, 'Hiérarchiser ses arguments et rédiger une transition', 23, 'Module 3 : La vie économique')
    RETURNING id INTO v_chapitre_id;
    RAISE NOTICE 'Chapitre 23 créé.';
  END IF;

  -- Les leçons. Si le chapitre en a déjà, on passe son tour sans rien toucher.
  SELECT count(*) INTO v_deja FROM public.concepts WHERE chapitre_id = v_chapitre_id;
  IF v_deja > 0 THEN
    RAISE NOTICE 'Le chapitre 23 a déjà ses % leçons, je n''y touche pas.', v_deja;
    RETURN;
  END IF;

  INSERT INTO public.concepts
    (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes) VALUES
    (v_chapitre_id, 'Hiérarchiser ses arguments : lequel en premier ?', 1, 'texte', '
Tu sais depuis le chapitre 15 qu''un plan thématique range les arguments **du
plus faible au plus fort**. Il est temps de voir ce que « fort » veut dire, et
comment on décide.

Ce chapitre travaille directement l''épreuve d''**expression écrite** du BEPC, et
plus précisément le critère de **cohérence de l''organisation**.

### Qu''est-ce qu''un argument fort ?

Ce n''est pas celui auquel tu crois le plus. C''est celui qui **convaincra le
lecteur que tu as en face de toi**. Quatre critères permettent d''en juger.

**Critère 1 — Il est difficile à réfuter.**

Un argument appuyé sur un fait vérifiable est plus fort qu''un argument
d''opinion.

> faible : « les sachets, c''est laid »
> fort : « un sac plastique met quatre cents ans à se dégrader »

**Critère 2 — Il touche le lecteur de près.**

Un argument qui concerne la vie quotidienne de celui qui lit pèse plus qu''un
argument abstrait.

> faible : « la pollution plastique menace les océans »
> fort : « les sachets bouchent les caniveaux de ton quartier et provoquent les
> inondations de septembre »

*Les deux disent vrai. Le second parle à quelqu''un.*

**Critère 3 — Il est difficile à retourner.**

Certains arguments se renvoient facilement. Évite de commencer par eux, ou
prépare la parade.

> « il faut interdire les sachets » → « et les commerçants, alors ? »

**Critère 4 — Il engage une valeur, pas seulement un intérêt.**

Un argument qui fait appel à la justice, à la santé des enfants, à la dignité
porte plus loin qu''un argument de confort.

### L''ordre : du plus faible au plus fort

Et voici pourquoi.

**Le lecteur retient ce qu''il a lu en dernier.** C''est un fait de mémoire, et
il vaut pour le correcteur du BEPC comme pour n''importe quel lecteur.

**La montée produit une impression de rigueur.** Si tes arguments descendent en
force, le lecteur a le sentiment que tu t''essouffles.

**Le dernier argument porte la conclusion.** Il doit donc être celui sur lequel
tu veux finir.

### Trois ordres possibles, selon le sujet

L''ordre croissant est la règle, mais il existe deux variantes utiles.

**L''ordre CROISSANT** — du plus faible au plus fort. C''est le défaut, et il
convient à presque tout.

**L''ordre CHRONOLOGIQUE** — quand les arguments suivent un déroulement dans le
temps.

> I. ce qui se passe à court terme
> II. à moyen terme
> III. à long terme

**L''ordre du PARTICULIER AU GÉNÉRAL** — quand tu pars d''un cas concret pour
élargir.

> I. ce que cela change dans un quartier
> II. dans une ville
> III. pour le pays

*Ce dernier ordre est très efficace en rédaction de BEPC, parce qu''il permet de
commencer par ce que tu connais et de finir sur une idée large. Et il rend la
conclusion facile à écrire.*

### Ce qu''il ne faut jamais faire

**Mettre deux arguments dans le même paragraphe.** Un paragraphe, une idée.
Sinon le correcteur ne voit pas ton plan.

**Garder un argument faible qui affaiblit l''ensemble.** Mieux vaut trois
arguments solides que cinq dont deux sont discutables : un argument faible
donne à l''adversaire une prise, et il décrédibilise les autres.

**Mettre le meilleur argument en premier.** C''est l''erreur la plus fréquente,
et elle vient d''un bon sentiment : on veut convaincre tout de suite. Mais ce
qui suit paraît alors fade.

---

**Exercice corrigé**

*Voici cinq arguments contre la vente de sachets plastiques au marché. En
éliminer un, classer les quatre autres du plus faible au plus fort, et
justifier chaque décision.*

> *a. Les sachets sont laids et sales quand ils traînent.*
> *b. Un sac plastique met quatre cents ans à disparaître.*
> *c. Les sachets bouchent les caniveaux et aggravent les inondations de
> septembre dans les quartiers bas.*
> *d. Le bétail qui avale des sachets meurt, et c''est une perte pour les
> éleveurs.*
> *e. Les pays voisins les ont déjà interdits.*

**Correction.**

*L''argument à éliminer : a.*

« Les sachets sont laids » est un argument **d''opinion pure**, impossible à
prouver et facile à retourner — on peut trouver cela sans importance. Et il est
faible au regard des autres : à côté d''un enfant noyé dans un caniveau, la
laideur ne pèse rien. Le garder affaiblirait l''ensemble.

*L''argument e mérite une discussion.*

« Les pays voisins l''ont fait » est un **appel à l''autorité** déguisé — tu l''as
vu au chapitre 14 — et il est logiquement faible : que d''autres l''aient fait ne
prouve pas que ce soit bon. Mais il a une utilité : il montre que la mesure est
**réalisable**, ce qui répond par avance à l''objection « c''est impossible ».

Je le garde donc, mais **en premier**, parce que c''est le plus faible.

*Le classement, du plus faible au plus fort :*

> **I. e — les pays voisins l''ont déjà fait.**
> Le plus faible logiquement, mais utile en ouverture : il installe l''idée que
> la chose est possible.
>
> **II. b — quatre cents ans pour se dégrader.**
> Un fait vérifiable, donc difficile à réfuter. Mais il reste abstrait : quatre
> cents ans, personne ne les voit.
>
> **III. d — le bétail meurt, et les éleveurs perdent.**
> Plus fort, parce qu''il ajoute une victime concrète et un préjudice chiffrable.
> Il touche un groupe identifiable.
>
> **IV. c — les caniveaux bouchés et les inondations.**
> Le plus fort, pour trois raisons. Il est vérifiable. Il touche le lecteur de
> près — c''est son quartier, sa saison des pluies, sa maison. Et il engage une
> valeur, la sécurité des habitants, plus qu''un simple intérêt.

*Et il porte naturellement la conclusion : « il ne s''agit plus d''esthétique ni
même d''écologie, il s''agit de savoir si nos quartiers seront sous l''eau en
septembre prochain. »*

*Remarque le travail que fait ce classement : il ne change pas un seul
argument, et il double la force du texte.*
', NULL, 28),
    (v_chapitre_id, 'Figure : le paragraphe argumentatif', 2, 'figure', '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 580 320" width="580" height="320">
<rect width="580" height="320" fill="#ffffff"/>
<text x="290" y="24" text-anchor="middle" font-size="14" font-weight="700" fill="#0f172a">Le paragraphe argumentatif : quatre temps, toujours les mêmes</text>
<text x="290" y="42" text-anchor="middle" font-size="10" fill="#64748b">Un paragraphe = une idée. Si tu as deux idées, fais deux paragraphes.</text>

<rect x="20" y="58" width="540" height="52" rx="6" fill="#dbeafe" stroke="#2563eb" stroke-width="1.5"/>
<text x="38" y="78" font-size="11" font-weight="700" fill="#1e3a8a">1. L&apos;ARGUMENT — une phrase, en tête</text>
<text x="38" y="96" font-size="9" fill="#1e40af">« D&apos;abord, le ramassage des ordures est un service public déjà payé par l&apos;impôt. »</text>
<text x="548" y="78" text-anchor="end" font-size="8" font-style="italic" fill="#475569">général, abstrait</text>

<rect x="20" y="118" width="540" height="52" rx="6" fill="#dcfce7" stroke="#15803d" stroke-width="1.5"/>
<text x="38" y="138" font-size="11" font-weight="700" fill="#14532d">2. L&apos;EXPLICATION — deux ou trois phrases</text>
<text x="38" y="156" font-size="9" fill="#166534">« Les habitants versent des taxes dont une part finance la collecte. Le faire eux-mêmes… »</text>
<text x="548" y="138" text-anchor="end" font-size="8" font-style="italic" fill="#475569">pourquoi c&apos;est vrai</text>

<rect x="20" y="178" width="540" height="52" rx="6" fill="#fef3c7" stroke="#ca8a04" stroke-width="1.5"/>
<text x="38" y="198" font-size="11" font-weight="700" fill="#78350f">3. L&apos;EXEMPLE — un fait situé, daté, chiffré</text>
<text x="38" y="216" font-size="9" fill="#92400e">« Le bac de notre carrefour a été retiré en janvier et n&apos;a jamais été remplacé. »</text>
<text x="548" y="198" text-anchor="end" font-size="8" font-style="italic" fill="#475569">particulier, vérifiable</text>

<rect x="20" y="238" width="540" height="52" rx="6" fill="#fce7f3" stroke="#be185d" stroke-width="1.5"/>
<text x="38" y="258" font-size="11" font-weight="700" fill="#831843">4. LA MINI-CONCLUSION — une phrase, qui rattache à la thèse</text>
<text x="38" y="276" font-size="9" fill="#9d174d">« Payer deux fois n&apos;est donc pas de la citoyenneté : c&apos;est une double peine. »</text>
<text x="548" y="258" text-anchor="end" font-size="8" font-style="italic" fill="#475569">celle que les élèves oublient</text>

<text x="290" y="308" text-anchor="middle" font-size="9" font-style="italic" fill="#475569">Six à dix lignes. Un correcteur reconnaît ce moule en trois secondes, et il le note.</text>
</svg>', NULL, 5),
    (v_chapitre_id, 'Simulation : hiérarchiser', 3, 'interactif', '{
  "widget": "hierarchiser-arguments",
  "consigne": "Six arguments s''affichent en vrac sur un sujet, et tu dois en éliminer un puis classer les autres. La simulation note chaque argument sur les quatre critères du cours — difficile à réfuter, proche du lecteur, difficile à retourner, engage une valeur — et te montre ton classement à côté du sien, critère par critère. Elle te fait aussi tester l''ordre inverse pour que tu entendes la différence : le même texte, arguments descendants, paraît s''essouffler. Dix sujets, et trois où un argument piégé décrédibilise tout l''ensemble si tu le gardes."
}', NULL, 10),
    (v_chapitre_id, 'La transition : le paragraphe que personne n''écrit', 4, 'texte', '
Voici l''outil qui distingue le plus nettement une bonne copie d''une copie
moyenne, et presque aucun élève ne l''emploie. C''est donc une occasion.

### Ce qu''est une transition

C''est une ou deux phrases placées **entre deux parties**, qui font trois choses
à la fois :

> **1.** elles rappellent ce qu''on vient d''établir
> **2.** elles montrent ce qui manque encore
> **3.** elles annoncent la partie qui vient

Elles ne sont pas un ornement. Elles sont ce qui transforme une liste de
paragraphes en un **raisonnement**.

### Le moule, en trois temps

> *« Nous avons vu que [ce qui précède]. Mais [ce que cela laisse sans
> réponse]. Il faut donc examiner [ce qui suit]. »*

Un exemple, entre une première et une deuxième partie.

> « Les initiatives des habitants nettoient donc les rues rapidement et sans
> coût pour la commune. **Mais** elles laissent une question sans réponse :
> qui finit par payer ce travail, et au nom de quoi ? **C''est ce qu''il faut
> maintenant regarder.** »

Trois phrases. Elles ne contiennent aucun argument nouveau, et pourtant elles
font tout le travail : le lecteur sait d''où il vient, pourquoi il avance, et où
il va.

### Pourquoi c''est si efficace

Parce que le correcteur du BEPC note la **cohérence de l''organisation**, et
qu''une transition est la preuve matérielle que tu as organisé.

Sans transition, le lecteur passe de la partie I à la partie II par un saut. Il
doit faire lui-même le lien. Avec une transition, tu le fais pour lui — et il
te sait gré de l''effort.

*Un correcteur lit soixante copies. Celle qui lui épargne un effort se
distingue.*

### Où placer les transitions

Dans un plan en trois parties, il en faut **deux** : entre I et II, et entre
II et III.

> Introduction
> **I.**
> *transition*
> **II.**
> *transition*
> **III.**
> Conclusion

Et dans un plan dialectique, la transition entre l''antithèse et la synthèse est
la plus importante de toutes : c''est elle qui justifie que tu dépasses
l''opposition.

> « Les deux positions semblent donc irréconciliables. **En réalité**, elles
> partagent un présupposé que ni l''une ni l''autre n''interroge : que le problème
> serait de ramasser ou non. **C''est ce présupposé qu''il faut examiner.** »

*Cette transition-là vaut à elle seule la synthèse : elle annonce le
déplacement.*

### Les connecteurs de transition

Pour le premier temps, le rappel :
> « nous avons vu que », « il apparaît donc que », « ce premier point
> établi », « ainsi »

Pour le second temps, la limite :
> « mais », « cependant », « toutefois », « reste que », « cela ne dit
> pourtant rien de »

Pour le troisième temps, l''annonce :
> « c''est ce qu''il faut maintenant examiner », « il convient donc de », « nous
> en venons à », « reste à savoir »

### L''erreur à ne pas commettre

**Une transition n''est pas un résumé.** Si tu te contentes de répéter la partie
précédente, tu n''as pas fait de transition.

> ✗ « Nous avons donc vu que les initiatives des habitants nettoient les rues,
> créent du lien et responsabilisent. Passons à la deuxième partie. »

Ce texte rappelle, mais il ne montre aucune limite et n''annonce rien. C''est un
résumé suivi d''une annonce mécanique.

> ✓ « Ces initiatives nettoient donc les rues. Mais elles ne disent rien de ce
> qui les a rendues nécessaires. C''est de ce côté qu''il faut chercher. »

Deux fois moins long, et infiniment plus efficace.

---

**Exercice corrigé**

*Rédiger les deux transitions d''un devoir dont voici le plan.*

> *Sujet : « Faut-il interdire les motos-taxis en centre-ville ? » Discutez.*
>
> *I. Oui : elles causent des accidents, et elles circulent sans casque ni
> assurance.*
> *II. Non : elles font vivre des milliers de jeunes et desservent les
> quartiers que les bus ne desservent pas.*
> *III. La vraie question est l''absence de transport public : il faut encadrer
> avant d''interdire.*

**Correction.**

*Transition entre I et II.*

> « Le danger est donc réel, et les chiffres ne se discutent pas. **Mais** une
> interdiction ne se juge pas seulement à ce qu''elle supprime : elle se juge
> aussi à ce qu''elle laisse derrière elle. **Il faut donc regarder qui vit de
> ces motos, et qui les prend.** »

*Analyse de ce qu''elle fait.* Le premier temps concède la force de la partie I
— « les chiffres ne se discutent pas » — ce qui évite de paraître revenir sur
ce qu''on vient d''écrire. Le deuxième temps introduit un critère nouveau : on ne
juge pas une mesure seulement sur son objectif. Le troisième annonce précisément
les deux arguments du II.

*Transition entre II et III.*

> « Les deux positions semblent donc également fondées, et c''est bien ce qui
> rend la question difficile. **En réalité**, elles partagent un présupposé que
> ni l''une ni l''autre n''interroge : toutes deux admettent que le choix se pose
> entre la moto et rien. **C''est ce présupposé qu''il faut examiner.** »

*Analyse.* Cette transition est plus ambitieuse, et c''est normal : elle ouvre la
synthèse. Elle ne départage pas les deux parties — ce serait prendre parti trop
tôt — mais elle nomme ce qu''elles ont **en commun** sans le voir. Et c''est ce
point commun qui sera déplacé en partie III.

*Garde ce moule : « les deux positions partagent un présupposé que ni l''une ni
l''autre n''interroge ». Il ouvre presque toutes les synthèses, et il fonctionne
sur n''importe quel sujet, parce qu''une opposition bien installée repose
toujours sur quelque chose que personne n''a questionné.*

*Un dernier conseil pratique : écris tes deux transitions au brouillon, avant
de rédiger les parties. Si tu n''arrives pas à les écrire, c''est que ton plan ne
tient pas — et il vaut mieux s''en apercevoir à ce moment-là.*
', NULL, 28),
    (v_chapitre_id, 'Simulation : rédiger la transition', 5, 'interactif', '{
  "widget": "rediger-transition",
  "consigne": "Deux parties d''un devoir s''affichent, et un blanc entre elles. Tu écris la transition, et la simulation vérifie les trois temps un par un : y a-t-il un rappel de ce qui précède, une limite nommée, une annonce de ce qui suit ? Elle repère le piège du résumé — quand tu te contentes de répéter la partie précédente — et te montre l''écart avec un modèle. Douze couples de parties, dont quatre ouvrant une synthèse, où le moule « les deux positions partagent un présupposé » est travaillé à fond."
}', NULL, 10),
    (v_chapitre_id, 'Le paragraphe argumentatif : quatre temps, toujours les mêmes', 6, 'texte', '
Dernière leçon du chapitre, et c''est la plus directement rentable. Voici
comment se construit chacun de tes paragraphes.

### Le moule

> **1. L''ARGUMENT** — une phrase, en tête de paragraphe.
> **2. L''EXPLICATION** — deux ou trois phrases : pourquoi c''est vrai.
> **3. L''EXEMPLE** — un fait situé, daté, chiffré.
> **4. LA MINI-CONCLUSION** — une phrase qui rattache à la thèse.

Six à dix lignes. Pas plus.

### Un paragraphe complet, commenté

> **« D''abord, le ramassage des ordures est un service public, et non un
> service rendu.** *(argument)* **Les habitants d''un quartier versent des taxes
> dont une part finance précisément la collecte ; lorsqu''ils la font eux-mêmes,
> ils paient deux fois, une fois en argent et une fois en temps, et personne ne
> leur rembourse la première.** *(explication)* **Le bac de notre carrefour a
> été retiré en janvier dernier ; il n''a jamais été remplacé, et ma mère a écrit
> deux fois à la mairie sans recevoir de réponse.** *(exemple)* **Ramasser
> soi-même n''est donc pas de la citoyenneté : c''est une double peine.** *(mini-
> conclusion)* »

Huit lignes, quatre temps, et le correcteur voit immédiatement que tu sais
construire.

### Ce que chaque temps apporte

**L''argument en tête** permet au lecteur de savoir où il va dès la première
ligne. S''il est noyé au milieu, le paragraphe paraît confus.

*Technique : commence par un connecteur — « d''abord », « de plus », « enfin ».
Il signale le passage à une idée nouvelle.*

**L''explication** est ce que les élèves sautent. Ils énoncent l''argument puis
donnent l''exemple, et le lecteur ne voit pas le raisonnement. Il faut deux ou
trois phrases pour dire **pourquoi** l''argument est vrai.

**L''exemple** est ce que les élèves oublient. Tu le sais depuis le chapitre 15 :
c''est la faute la plus fréquente de toutes les copies de BEPC.

**La mini-conclusion** est ce que personne n''écrit. Elle rattache le paragraphe
à la thèse générale, et elle produit un effet remarquable : le lecteur a
l''impression que chaque paragraphe fait avancer la démonstration, au lieu de
simplement s''ajouter aux précédents.

*Si tu ne devais retenir qu''une chose de ce chapitre, retiens celle-là : écris
la dernière phrase de chaque paragraphe en la rattachant à ta thèse. Cinq
secondes, et ta copie change de niveau.*

### La règle d''or : un paragraphe, une idée

Si tu as deux idées, fais deux paragraphes. Un paragraphe qui contient deux
arguments est illisible, et le correcteur n''y voit plus ton plan.

**Comment vérifier ?** Résume ton paragraphe en une phrase. Si tu n''y arrives
pas, c''est qu''il en contient deux.

### La présentation matérielle

Elle compte, et elle ne coûte rien.

> **Un alinéa** au début de chaque paragraphe — deux carreaux.
> **Une ligne sautée** entre les grandes parties.
> **Pas de ligne sautée** entre les paragraphes d''une même partie.

Une copie bien présentée donne envie d''être lue. Une copie en bloc compact
fatigue dès la première ligne.

### Le cas de la concession

Tu as vu au chapitre 14 que la concession rapporte. Voici où la placer dans le
moule : elle prend la place de l''explication, dans le troisième paragraphe.

> « Enfin, interdire sans proposer de solution frappe d''abord les plus
> pauvres. *(argument)* **Certes**, on peut répondre que les commerçants
> trouveront d''autres emballages ; **mais** ces emballages coûtent trois fois
> plus cher, et ce sont les petits vendeurs, pas les grossistes, qui paieront
> la différence. *(concession + explication)* Au marché de Mokolo, un paquet de
> cent sachets coûte deux cents francs quand les sacs en papier équivalents en
> coûtent six cents. *(exemple)* Une mesure juste dans son principe peut donc
> être injuste dans son application. *(mini-conclusion)* »

---

**Exercice corrigé**

*Voici un paragraphe mal construit. Identifier ce qui manque, puis le
réécrire.*

> *« Il faut dire aussi que les jeunes qui ramassent les ordures c''est bien
> mais que ça pose problème parce que la mairie devrait le faire et aussi parce
> que ça coûte du temps aux gens qui travaillent. Dans mon quartier il y a eu
> des problèmes. C''est vraiment pas normal. »*

**Correction.**

*Ce qui manque, point par point.*

**Il n''y a pas d''argument en tête.** La première phrase mélange une concession
— « c''est bien » — et deux arguments — la mairie devrait le faire, et cela coûte
du temps. Le lecteur ne sait pas quelle est l''idée du paragraphe.

**Il y a deux idées, donc il faudrait deux paragraphes.**

**Il n''y a pas d''explication.** Les deux arguments sont jetés, et aucun n''est
développé.

**L''exemple est vide.** « Dans mon quartier il y a eu des problèmes » ne situe
rien, ne date rien, ne chiffre rien. C''est exactement le témoignage vague du
chapitre 15.

**La mini-conclusion est un jugement, pas une conclusion.** « C''est vraiment pas
normal » ne rattache rien à la thèse — et le registre est familier : à l''écrit,
on écrit « ce n''est pas normal ».

*La réécriture, en deux paragraphes.*

> **Premier paragraphe.**
>
> « D''abord, ce travail incombe à la commune, et non aux habitants. Le
> ramassage des ordures est un service public, financé par les taxes que les
> habitants versent chaque année ; lorsqu''ils l''assurent eux-mêmes, ils
> acquittent deux fois la même charge. Le bac de notre carrefour a été retiré
> en janvier dernier, et il n''a jamais été remplacé malgré deux lettres restées
> sans réponse. Faire à la place de la commune n''est donc pas la soulager :
> c''est la dispenser d''agir. »
>
> **Second paragraphe.**
>
> « De plus, cet effort pèse sur ceux qui en ont le moins les moyens. Un samedi
> matin passé à curer un caniveau est un samedi matin retiré à un travail, à un
> commerce ou à une révision ; et ce sont les familles les plus modestes qui
> peuvent le moins se le permettre. Sur les douze jeunes qui ont nettoyé notre
> rue en septembre, neuf travaillent au marché le week-end. Une solidarité qui
> coûte cher aux plus pauvres cesse d''être une solidarité. »

*Compare les volumes : le texte de départ fait quatre lignes, la réécriture en
fait seize. Ce n''est pas parce que j''ai ajouté des idées — il y avait déjà les
deux — mais parce que j''ai développé, illustré et conclu chacune.*

*C''est le travail que le correcteur attend, et c''est ce qui sépare une copie de
huit d''une copie de quatorze.*
', NULL, 28),
    (v_chapitre_id, 'Simulation : bâtir le paragraphe', 7, 'interactif', '{
  "widget": "paragraphe-argumentatif",
  "consigne": "Quatre cases s''affichent — argument, explication, exemple, mini-conclusion — et tu les remplis dans l''ordre. La simulation refuse de passer à la suivante tant que la précédente ne remplit pas son rôle : elle vérifie que l''argument tient en une phrase et reste général, que l''explication dit pourquoi, que l''exemple contient un lieu, une date ou un chiffre, et que la mini-conclusion reprend un mot de la thèse. Un second atelier te donne des paragraphes mal bâtis à réparer, dont trois qui contiennent deux idées et qu''il faut couper en deux. Douze sujets."
}', NULL, 10),
    (v_chapitre_id, 'Quiz du chapitre 23', 8, 'quiz', '{
  "titre": "Vérifie que tu as compris",
  "questions": [
    {
      "question": "Qu''est-ce qui rend un argument « fort » ?",
      "choix": [
        "Le fait d''y croire",
        "Quatre critères : il est difficile à réfuter, il touche le lecteur de près, il est difficile à retourner, et il engage une valeur",
        "Sa longueur",
        "Sa place dans le devoir"
      ],
      "bonne": 1,
      "explication": "« La pollution menace les océans » et « les sachets bouchent les caniveaux de ton quartier » disent vrai tous les deux. Le second parle à quelqu''un."
    },
    {
      "question": "Pourquoi ranger les arguments du plus faible au plus fort ?",
      "choix": [
        "Par tradition",
        "Parce que le lecteur retient ce qu''il a lu en dernier, et parce que la montée donne une impression de rigueur",
        "Pour faire plus long",
        "Parce que c''est plus facile"
      ],
      "bonne": 1,
      "explication": "Si les arguments descendent en force, le lecteur a le sentiment que tu t''essouffles. Et le dernier argument porte la conclusion."
    },
    {
      "question": "Vaut-il mieux cinq arguments dont deux discutables, ou trois solides ?",
      "choix": [
        "Cinq, c''est plus complet",
        "Trois solides : un argument faible donne une prise à l''adversaire et décrédibilise les autres",
        "Cela ne change rien",
        "Cinq, si on les classe bien"
      ],
      "bonne": 1,
      "explication": "C''est pourquoi un bon brouillon commence par éliminer, et non par accumuler."
    },
    {
      "question": "Que fait une transition, en trois temps ?",
      "choix": [
        "Elle résume",
        "Elle rappelle ce qu''on vient d''établir, montre ce que cela laisse sans réponse, et annonce la partie qui vient",
        "Elle répète le sujet",
        "Elle conclut"
      ],
      "bonne": 1,
      "explication": "Elle ne contient aucun argument nouveau, et pourtant elle fait tout le travail : le lecteur sait d''où il vient, pourquoi il avance, et où il va."
    },
    {
      "question": "Quel moule ouvre presque toutes les synthèses ?",
      "choix": [
        "« Il faut trouver un équilibre »",
        "« Les deux positions partagent un présupposé que ni l''une ni l''autre n''interroge »",
        "« En conclusion, c''est complexe »",
        "« Les avis divergent »"
      ],
      "bonne": 1,
      "explication": "Il fonctionne sur n''importe quel sujet, parce qu''une opposition bien installée repose toujours sur quelque chose que personne n''a questionné."
    },
    {
      "question": "Quels sont les quatre temps d''un paragraphe argumentatif ?",
      "choix": [
        "Introduction, idée, exemple, fin",
        "Argument, explication, exemple, mini-conclusion",
        "Thèse, antithèse, synthèse, transition",
        "Accroche, problème, solution, demande"
      ],
      "bonne": 1,
      "explication": "Six à dix lignes. Un correcteur reconnaît ce moule en trois secondes, et il le note."
    },
    {
      "question": "Quel temps du paragraphe les élèves oublient-ils le plus, et que change-t-il ?",
      "choix": [
        "L''argument",
        "La mini-conclusion : elle rattache le paragraphe à la thèse, et donne l''impression que chaque paragraphe fait AVANCER la démonstration au lieu de s''ajouter",
        "L''explication",
        "L''alinéa"
      ],
      "bonne": 1,
      "explication": "Écris la dernière phrase de chaque paragraphe en la rattachant à ta thèse. Cinq secondes, et ta copie change de niveau."
    }
  ]
}', NULL, 5);

  RAISE NOTICE '8 leçons ajoutées au chapitre 23, Hiérarchiser ses arguments et rédiger une transition.';
END $fr3$;
