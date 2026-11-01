-- ---------------------------------------------------------------------------
-- M'Andal — Français, classe de 3ème
-- Chapitre 24 : Exprimer une opinion et présenter un stand
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
  WHERE programme_id = v_programme_id AND ordre = 24;

  IF v_chapitre_id IS NULL THEN
    INSERT INTO public.chapitres (programme_id, titre, ordre, niveau)
    VALUES (v_programme_id, 'Exprimer une opinion et présenter un stand', 24, 'Module 3 : La vie économique')
    RETURNING id INTO v_chapitre_id;
    RAISE NOTICE 'Chapitre 24 créé.';
  END IF;

  -- Les leçons. Si le chapitre en a déjà, on passe son tour sans rien toucher.
  SELECT count(*) INTO v_deja FROM public.concepts WHERE chapitre_id = v_chapitre_id;
  IF v_deja > 0 THEN
    RAISE NOTICE 'Le chapitre 24 a déjà ses % leçons, je n''y touche pas.', v_deja;
    RETURN;
  END IF;

  INSERT INTO public.concepts
    (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes) VALUES
    (v_chapitre_id, 'Exprimer une opinion à l''oral', 1, 'texte', '
Nous passons à l''oral du module 3. Deux situations y sont au programme :
**donner son avis** dans un échange, et **présenter un stand** — c''est-à-dire
défendre un projet devant des visiteurs.

Commençons par la première, qui te servira tous les jours.

### Donner son avis n''est pas crier plus fort

Tu as vu au chapitre 16 comment contredire sans blesser. Nous abordons ici le
mouvement inverse : **affirmer** quelque chose, et le faire de manière qu''on
t''écoute.

Trois choses sont en jeu, et elles se règlent séparément.

> **Qu''est-ce que je dis ?** — le contenu
> **À quel point je m''engage ?** — la modalisation, que tu as vue au
> chapitre 21
> **Comment je le dis ?** — le ton et le registre

### S''engager : l''échelle de l''affirmation

Comme toujours, il y a une échelle, et il faut savoir où l''on se place.

> **« Il me semble que… »** — j''avance prudemment, je laisse la porte ouverte
> **« Je crois que… »** — je prends position, sans exclure de me tromper
> **« Je pense que… »** — position assumée, c''est la forme standard
> **« Je suis convaincu que… »** — engagement fort
> **« Il est évident que… »** — je ne laisse pas de place au doute

**La règle d''usage : adapte ton engagement à ce que tu sais vraiment.**

> Si tu as un fait : engage-toi. « Le bac a été retiré en janvier, je l''ai vu. »
> Si tu as une impression : dis-le. « Il me semble que le camion passe moins
> souvent. »

Un interlocuteur pardonne une erreur. Il ne pardonne pas qu''on lui ait présenté
une supposition comme une certitude.

### Les formules qui donnent du poids

**Annoncer ce qu''on va dire.**
> « Je voudrais dire deux choses. »
> « Sur ce point, j''ai une objection précise. »

**Rattacher à ce qui précède.**
> « Pour revenir à ce que disait Paul… »
> « Dans le prolongement de ce qui vient d''être dit… »

Celle-ci est précieuse : elle montre que tu as écouté, et elle fait entrer ton
intervention dans la discussion au lieu de la poser à côté.

**S''appuyer sur un fait.**
> « Je m''appuie sur un chiffre : six bacs pour quarante mille habitants. »

**Reconnaître une limite.**
> « Je n''ai pas vérifié ce point, mais il me semble que… »

Cette dernière formule paraît faible. Elle est au contraire très forte :
celui qui sait dire ce qu''il ignore est cru sur ce qu''il affirme.

### Le registre : où l''on parle

Tu as vu au chapitre 18 que l''oral n''est pas de l''écrit lu. Mais tous les oraux
ne se valent pas non plus.

> **Registre familier** — entre amis : « ça craint », « c''est nul », « on s''en
> fout »
> **Registre courant** — en classe, au marché : « ce n''est pas bien », « cela ne
> m''intéresse pas »
> **Registre soutenu** — devant un jury, une autorité : « cela me paraît
> fâcheux », « je n''y attache pas d''importance »

**En situation d''examen oral, en exposé ou devant un visiteur, le registre
courant soigné est le bon.** Pas familier, pas guindé.

Trois marques à surveiller, qui trahissent le familier :

> **la négation incomplète** : « c''est pas vrai » → dis « ce n''est pas vrai »
> **le redoublement du sujet** : « les gens ils disent » → dis « les gens
> disent »
> **l''interrogation sans inversion** : « tu viens quand ? » → dis « quand
> viens-tu ? » en situation formelle

*Ces trois corrections ne demandent aucun vocabulaire nouveau. Elles demandent
seulement de l''attention, et elles changent entièrement l''impression produite.*

---

**Exercice corrigé**

*Réécrire ces quatre interventions en registre courant soigné, et en ajustant
l''engagement à ce que le locuteur sait réellement.*

*1. « Franchement c''est nul leur truc, ça marchera jamais. »*
*2. « Moi je suis sûr qu''ils ont volé l''argent, c''est évident. »*
*3. « Les gens ils comprennent rien à ce qu''on leur dit. »*
*4. « Bah je sais pas trop, enfin peut-être, euh, voilà. »*

**Correction.**

*1.* Registre familier — « franchement », « nul », « truc », négation
incomplète. Et l''engagement est maximal — « ça marchera jamais » — alors que
rien ne le fonde.

> « Ce projet me paraît fragile, et je doute qu''il tienne. Pour deux raisons :
> il ne prévoit aucun financement après la première année, et il repose sur des
> bénévoles qu''on n''a pas encore trouvés. »

*J''ai baissé l''engagement — « me paraît », « je doute » — et je l''ai remplacé
par deux raisons. L''intervention est à la fois plus modeste et plus forte.*

*2.* L''accusation est grave et l''engagement est total — « je suis sûr », « c''est
évident » — sans aucune preuve. C''est ce qu''il ne faut jamais faire : une
supposition présentée comme une certitude.

> « Je constate que la somme annoncée ne correspond pas aux travaux réalisés.
> Je ne sais pas ce qui s''est passé, et je ne veux accuser personne ; mais je
> voudrais qu''on nous explique l''écart. »

*J''ai séparé ce qui est constaté de ce qui est supposé, et j''ai transformé
l''accusation en demande. C''est plus efficace : une accusation se nie, une
demande d''explication est difficile à refuser.*

*3.* Redoublement du sujet — « les gens ils » — et jugement global non fondé.

> « Je crois que le message n''a pas été compris, et je me demande si la manière
> dont il a été présenté n''y est pas pour quelque chose. »

*Remarque le déplacement : au lieu d''accuser les gens de ne rien comprendre,
j''interroge la façon dont on leur a parlé. C''est le même constat, et il devient
utilisable.*

*4.* Ici, le problème n''est pas le registre mais l''**absence totale
d''engagement**, noyée dans les tics. Le locuteur n''a rien dit.

> « Je n''ai pas d''avis arrêté sur ce point. Ce qui me retient, c''est que nous
> n''avons pas de chiffres sur le coût. Si on me les donne, je pourrai me
> prononcer. »

*Ne pas avoir d''avis est parfaitement acceptable. Ce qui ne l''est pas, c''est de
le laisser deviner à travers des « euh ». Dis-le clairement, dis pourquoi, et
dis ce qu''il te faudrait pour en avoir un.*
', NULL, 26),
    (v_chapitre_id, 'Figure : présenter un stand en trois minutes', 2, 'figure', '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 580 300" width="580" height="300">
<rect width="580" height="300" fill="#ffffff"/>
<text x="290" y="24" text-anchor="middle" font-size="14" font-weight="700" fill="#0f172a">Présenter un stand en trois minutes</text>
<text x="290" y="42" text-anchor="middle" font-size="10" fill="#64748b">Le visiteur s&apos;arrête vingt secondes. Tout se joue là.</text>

<rect x="20" y="56" width="128" height="78" rx="6" fill="#dbeafe" stroke="#2563eb" stroke-width="1.5"/>
<text x="84" y="76" text-anchor="middle" font-size="10" font-weight="700" fill="#1e3a8a">0 — 20 s</text>
<text x="84" y="94" text-anchor="middle" font-size="9" font-weight="700" fill="#1e40af">L&apos;ACCROCHE</text>
<text x="84" y="110" text-anchor="middle" font-size="8" fill="#1e40af">un chiffre, un objet,</text>
<text x="84" y="122" text-anchor="middle" font-size="8" fill="#1e40af">une question</text>

<rect x="156" y="56" width="128" height="78" rx="6" fill="#dcfce7" stroke="#15803d" stroke-width="1.5"/>
<text x="220" y="76" text-anchor="middle" font-size="10" font-weight="700" fill="#14532d">20 s — 1 min</text>
<text x="220" y="94" text-anchor="middle" font-size="9" font-weight="700" fill="#166534">LE PROBLÈME</text>
<text x="220" y="110" text-anchor="middle" font-size="8" fill="#166534">à quoi ça sert,</text>
<text x="220" y="122" text-anchor="middle" font-size="8" fill="#166534">pour qui</text>

<rect x="292" y="56" width="128" height="78" rx="6" fill="#fef3c7" stroke="#ca8a04" stroke-width="1.5"/>
<text x="356" y="76" text-anchor="middle" font-size="10" font-weight="700" fill="#78350f">1 — 2 min 30</text>
<text x="356" y="94" text-anchor="middle" font-size="9" font-weight="700" fill="#92400e">LA SOLUTION</text>
<text x="356" y="110" text-anchor="middle" font-size="8" fill="#92400e">on montre, on fait</text>
<text x="356" y="122" text-anchor="middle" font-size="8" fill="#92400e">toucher, on prouve</text>

<rect x="428" y="56" width="132" height="78" rx="6" fill="#fce7f3" stroke="#be185d" stroke-width="1.5"/>
<text x="494" y="76" text-anchor="middle" font-size="10" font-weight="700" fill="#831843">2 min 30 — 3</text>
<text x="494" y="94" text-anchor="middle" font-size="9" font-weight="700" fill="#9d174d">LA DEMANDE</text>
<text x="494" y="110" text-anchor="middle" font-size="8" fill="#9d174d">ce que tu veux</text>
<text x="494" y="122" text-anchor="middle" font-size="8" fill="#9d174d">du visiteur</text>

<rect x="20" y="146" width="540" height="62" rx="6" fill="#f1f5f9" stroke="#64748b" stroke-width="1.4"/>
<text x="290" y="166" text-anchor="middle" font-size="10" font-weight="700" fill="#0f172a">CE QUE LE VISITEUR RETIENT</text>
<text x="40" y="186" font-size="9" fill="#334155">il oubliera tes phrases · il retiendra UN chiffre, UNE image, et ce que tu lui as fait faire</text>
<text x="40" y="200" font-size="9" fill="#334155">choisis donc à l&apos;avance les trois choses qu&apos;il doit emporter</text>

<rect x="20" y="218" width="268" height="66" rx="6" fill="#dcfce7" stroke="#15803d" stroke-width="1.4"/>
<text x="154" y="238" text-anchor="middle" font-size="10" font-weight="700" fill="#14532d">CE QUI MARCHE</text>
<text x="36" y="256" font-size="8.5" fill="#166534">un objet à prendre en main</text>
<text x="36" y="268" font-size="8.5" fill="#166534">un chiffre unique, bien choisi</text>
<text x="36" y="280" font-size="8.5" fill="#166534">une question posée au visiteur</text>

<rect x="296" y="218" width="264" height="66" rx="6" fill="#fee2e2" stroke="#b91c1c" stroke-width="1.4"/>
<text x="428" y="238" text-anchor="middle" font-size="10" font-weight="700" fill="#7f1d1d">CE QUI NE MARCHE PAS</text>
<text x="312" y="256" font-size="8.5" fill="#991b1b">réciter un texte appris</text>
<text x="312" y="268" font-size="8.5" fill="#991b1b">une affiche couverte de texte</text>
<text x="312" y="280" font-size="8.5" fill="#991b1b">attendre que le visiteur demande</text>
</svg>', NULL, 5),
    (v_chapitre_id, 'Simulation : l''échelle de l''engagement', 3, 'interactif', '{
  "widget": "exprimer-opinion",
  "consigne": "Une situation s''affiche avec ce que tu sais réellement — un fait vérifié, une impression, une rumeur — et un curseur à cinq crans allant de « il me semble que » à « il est évident que ». Tu places le curseur, et la simulation te montre comment un interlocuteur reçoit ta phrase : crédible, ou présomptueuse. Elle traque aussi les trois marques du registre familier — la négation incomplète, le sujet redoublé, l''interrogation sans inversion — et te réécrit la phrase en registre courant soigné. Seize situations."
}', NULL, 10),
    (v_chapitre_id, 'Présenter un stand : trois minutes, et vingt secondes décisives', 4, 'texte', '
Deuxième situation du programme, et elle est très concrète : une journée portes
ouvertes, un forum des métiers, une foire agricole, une exposition de projets
d''élèves. Tu es derrière une table, et des visiteurs passent.

### Ce qui se passe réellement

Il faut le savoir avant de préparer quoi que ce soit.

**Le visiteur ne vient pas pour toi.** Il passe, il regarde, il s''arrête ou
non. Tu as environ **vingt secondes** pour qu''il décide de rester.

**Il ne lira pas ton affiche.** Une affiche couverte de texte ne se lit jamais
debout. Trois mots en gros, une image, un chiffre : c''est tout ce qui passe.

**Il oubliera tes phrases.** Il retiendra au mieux **trois choses** : un
chiffre, une image, et ce que tu lui as fait faire.

Prépare donc ta présentation à l''envers : choisis d''abord les trois choses
qu''il doit emporter, puis construis autour.

### La structure en quatre temps

**0 à 20 secondes — L''ACCROCHE.**

Elle doit arrêter quelqu''un qui marche. Trois formes marchent bien.

> **un chiffre** : « Quatre cents maisons, un seul robinet. »
> **un objet tendu** : « Tenez, prenez ça dans la main. »
> **une question** : « Vous savez combien de temps met un sachet à
> disparaître ? »

*La question est la plus efficace, parce qu''elle oblige à répondre, et que
celui qui a répondu reste.*

**20 secondes à 1 minute — LE PROBLÈME.**

Tu expliques à quoi ça sert, et pour qui. Pas encore ta solution : le problème.

> « Dans notre secteur, l''eau coule deux heures par jour. Les femmes se lèvent à
> quatre heures pour prendre leur tour. »

*Si le visiteur ne comprend pas le problème, ta solution ne l''intéressera pas.*

**1 minute à 2 minutes 30 — LA SOLUTION.**

Tu montres. C''est le moment du stand, pas celui du discours.

> fais toucher l''objet
> montre le schéma, et pointe du doigt
> fais une démonstration, même courte

*Règle : chaque fois que tu peux montrer au lieu de dire, montre.*

**2 minutes 30 à 3 minutes — LA DEMANDE.**

Ne laisse jamais partir quelqu''un sans lui avoir dit ce que tu attends de lui.

> « Si ça vous intéresse, laissez-nous votre nom sur cette feuille. »
> « Parlez-en au chef de votre quartier. »
> « Venez voir la démonstration à quinze heures. »

*C''est le temps que tout le monde oublie. On présente, on remercie, et le
visiteur repart sans savoir quoi faire. Une présentation sans demande est un
coup d''épée dans l''eau.*

### Le support visuel

Trois règles, et elles sont impitoyables.

**Pas plus de sept mots par affiche.** Si tu as besoin de plus, c''est que
l''affiche fait ton travail à ta place.

**Un seul chiffre, très gros.** Celui que tu veux qu''on retienne.

**Une image qui se comprend sans légende.**

### Ce qui ne marche pas

**Réciter un texte appris.** Cela s''entend immédiatement, et cela interdit toute
question. Apprends tes trois idées, pas tes phrases.

**Attendre que le visiteur demande.** Il ne demandera pas. C''est à toi
d''engager, et une seule phrase suffit : « Vous voulez que je vous montre ? »

**Parler à plusieurs en même temps.** Si vous êtes trois sur le stand, un seul
parle. Les autres préparent, ou s''occupent d''un autre visiteur.

**S''excuser.** « C''est pas terminé », « on n''a pas eu le temps ». Le visiteur ne
sait pas ce que vous aviez prévu. Montrez ce qui existe.

---

**Exercice corrigé**

*Préparer la présentation d''un stand sur le thème : « Un composteur de quartier
pour réduire les ordures ». Rédiger les quatre temps, et choisir les trois
choses à faire retenir.*

**Correction.**

*D''abord, les trois choses à faire retenir. Je les choisis avant tout le
reste.*

> **un chiffre** : la moitié du poids de nos poubelles est constituée de
> déchets de cuisine
> **une image** : le bac à ordures qui déborde, à côté du composteur qui tient
> dans un coin de cour
> **un geste** : le visiteur aura pris une poignée de compost dans la main

*Maintenant les quatre temps.*

**L''accroche — 20 secondes.**

> « Bonjour. Vous savez ce qu''il y a dans votre poubelle ? »
>
> *(je laisse répondre, quelle que soit la réponse)*
>
> « La moitié, c''est des épluchures. De l''eau et des légumes. On paie pour
> transporter de l''eau. »

*Pourquoi cela marche : une question qui oblige à répondre, puis un chiffre
simple, puis une formule qui surprend — « on paie pour transporter de l''eau ».*

**Le problème — 40 secondes.**

> « Le camion passe une fois par semaine chez nous, quand il passe. Le bac
> déborde au bout de trois jours, et ce qui déborde finit dans le caniveau. En
> septembre, le caniveau bouché nous met les pieds dans l''eau.
>
> Or sur ce qui déborde, la moitié n''avait rien à faire là. »

*Pourquoi cela marche : je décris une situation que le visiteur connaît, avec
des détails concrets — trois jours, septembre, les pieds dans l''eau. Et je
termine en rattachant au chiffre de l''accroche.*

**La solution — 1 minute 30.**

> « Voilà le composteur. *(je montre)* C''est un bac en bois d''un mètre sur un
> mètre. On y met les épluchures, les feuilles, un peu de terre, et on remue
> une fois par semaine.
>
> Au bout de trois mois, ça donne ça. *(je tends une poignée)* Prenez, ça ne
> sent rien. Ça sent la terre.
>
> Celui qu''on a installé derrière l''école reçoit les déchets de douze familles.
> Depuis janvier, leur bac à ordures ne déborde plus. »

*Pourquoi cela marche : je montre l''objet, je le décris en une phrase, et
surtout je fais toucher. « Prenez, ça ne sent rien » répond à l''objection que le
visiteur avait en tête sans l''avoir formulée.*

*Note aussi l''exemple final : douze familles, derrière l''école, depuis janvier.
C''est un exemple au sens du chapitre 14 — situé, daté, chiffré.*

**La demande — 30 secondes.**

> « Nous cherchons cinq familles de plus pour en installer un deuxième du côté
> du carrefour. Si ça vous dit, écrivez votre nom et votre maison sur cette
> feuille. Je passerai samedi.
>
> Et si vous préférez voir avant de décider, venez derrière l''école un matin,
> n''importe lequel. »

*Pourquoi cela marche : la demande est précise — cinq familles, une feuille, un
jour — et une seconde porte de sortie est offerte à celui qui hésite. Personne
ne repart les mains vides.*

*Durée totale : trois minutes. Et le visiteur emporte un chiffre, une image, et
le souvenir d''avoir tenu du compost dans la main.*
', NULL, 28),
    (v_chapitre_id, 'Simulation : la console du stand', 5, 'interactif', '{
  "widget": "presenter-stand",
  "consigne": "Tu prépares un stand, et la simulation te fait commencer par la fin : quelles trois choses le visiteur doit-il emporter ? Elle n''ouvre les quatre temps qu''ensuite. Un chronomètre tourne pendant que tu rédiges chaque bloc, et une jauge d''attention monte ou descend selon ce que tu y mets — un chiffre la fait monter, une phrase récitée la fait tomber, un objet tendu la fait bondir. L''atelier de l''affiche te laisse écrire sept mots, pas un de plus, et te montre à distance ce qui reste lisible. Huit projets, du composteur de quartier au stand d''orientation."
}', NULL, 10),
    (v_chapitre_id, 'Répondre aux questions : le moment qui révèle tout', 6, 'texte', '
Dernière leçon de l''année sur l''oral, et c''est le moment qu''on prépare le
moins alors que c''est celui qui compte le plus.

### Pourquoi ce moment est décisif

Parce qu''une présentation peut être apprise. **Une réponse ne peut pas.**

Celui qui t''écoute le sait. C''est à tes réponses qu''il jugera si tu maîtrises
ton sujet ou si tu as récité. C''est vrai au stand, c''est vrai devant un jury,
c''est vrai en entretien d''embauche.

### Les quatre gestes

**Geste 1 — Écouter jusqu''au bout.**

La tentation est de répondre dès qu''on a compris le début de la question. Ne le
fais pas : tu répondrais à une autre question que celle qui est posée, et cela
se voit.

**Geste 2 — Reformuler.**

Tu connais ce geste depuis le chapitre 16, et il vaut ici encore plus.

> « Si je comprends bien, vous demandez combien ça coûte à installer ? »

Il fait trois choses : il te donne trois secondes pour réfléchir, il montre que
tu as écouté, et il évite de répondre à côté.

**Geste 3 — Répondre court, puis développer.**

> *Question* : « Est-ce que ça sent mauvais ? »
> *Réponse* : « Non. *(court)* Parce qu''on y met des épluchures et des feuilles
> sèches, et qu''on remue. Ce qui sent, c''est la viande et le manque d''air.
> *(développement)* »

Celui qui développe avant de répondre donne l''impression d''éviter la question.

**Geste 4 — Vérifier.**

> « Est-ce que cela répond à votre question ? »

Quatre mots, et ils changent tout : ils montrent que ton but est de répondre, et
non de parler.

### Dire qu''on ne sait pas

Voici le point le plus important de la leçon.

**Ne jamais inventer une réponse.** Celui qui pose la question connaît souvent
la réponse — c''est même parfois pour cela qu''il la pose.

La bonne formule tient en trois temps :

> **« Je ne sais pas.** *(on le dit)* **Je peux me renseigner et vous le dire
> demain.** *(on propose)* **Ce que je sais, en revanche, c''est que…** *(on
> donne ce qu''on a)* »

> « Je ne sais pas combien de temps le bois tient dehors. Je peux demander au
> menuisier et vous le dire samedi. Ce que je sais, c''est que celui de l''école
> est installé depuis janvier et qu''il n''a pas bougé. »

*Cette réponse-là vaut mieux qu''une réponse inventée qui serait juste. Celui qui
sait dire ce qu''il ignore est cru sur ce qu''il affirme — c''est la même règle
qu''à la première leçon.*

### Les questions difficiles, et comment les prendre

**La question agressive.**
> « De toute façon ça ne marchera jamais, comme tout le reste. »

Ne te défends pas, et ne réponds pas à l''agressivité. **Cherche la question
dans la phrase**, et réponds à elle seule.

> « Vous voulez dire que d''autres projets ont échoué ici ? Lesquels ? Cela
> m''intéresse, parce qu''on aimerait éviter les mêmes erreurs. »

*Tu as transformé une attaque en information utile. C''est souvent ce que la
personne voulait, d''ailleurs : être entendue sur ce qui l''a déçue.*

**La question hors sujet.**

Réponds brièvement, puis ramène.

> « Ça, c''est un autre problème, et il est réel. Pour ce qui nous occupe ici… »

**La question à laquelle tu as déjà répondu.**

Ne le fais jamais remarquer. Réponds de nouveau, autrement.

> ✗ « Je viens de le dire. »
> ✓ « Oui — et je vais le dire d''une autre façon, parce que je n''ai peut-être
> pas été clair. »

*Cette seconde formule te fait gagner la salle entière.*

**La question que tu attendais.**

Il y en a toujours une, et c''est celle de l''objection principale. Prépare-la.
Si tu présentes un composteur, quelqu''un demandera si ça sent mauvais. Si tu
présentes un projet, quelqu''un demandera qui paie.

*Fais la liste des trois questions que tu redoutes, et prépare les trois
réponses. Ce sont celles qui viendront.*

### Ce qu''il ne faut pas faire

> **couper celui qui pose la question** — il n''a pas fini, et tu auras l''air
> pressé de parler
> **répondre à la personne au lieu de répondre à la question** — « vous dites
> ça parce que… » : c''est l''attaque de la personne du chapitre 16
> **s''énerver** — celui qui s''énerve a perdu, même s''il a raison
> **parler trop longtemps** — une réponse de trois minutes à une question de
> dix secondes épuise tout le monde

---

**Exercice corrigé**

*Répondre à ces quatre questions sur le stand du composteur, en appliquant les
gestes du cours.*

*1. « Et ça coûte combien ? »*
*2. « Ça va attirer les rats, non ? »*
*3. « De toute façon, ici, rien ne marche jamais. »*
*4. « Est-ce que le bois va tenir sous la pluie ? » — et tu ne sais pas.*

**Correction.**

*1.* Question simple et légitime. Réponds court, puis développe.

> « Environ quinze mille francs pour le bac. *(court)* C''est le bois et les
> clous ; la main-d''œuvre, c''est nous. Le composteur de l''école nous a coûté
> douze mille parce qu''on a récupéré des planches. *(développement)* Est-ce que
> cela répond à votre question ? *(vérification)* »

*2.* C''est la question qu''on attendait : l''objection principale. Elle doit être
préparée.

> « C''est la question qu''on nous pose à chaque fois, et c''est normal. *(je
> reconnais)* Non, à condition de n''y mettre ni viande ni poisson — ce sont eux
> qui attirent les rats. Épluchures, feuilles, coquilles d''œuf : ça ne les
> intéresse pas. *(réponse et raison)* Celui de l''école tourne depuis janvier,
> vous pouvez aller voir. *(preuve)* »

*Remarque le « c''est normal » : il désamorce. La personne ne se sent pas sotte
d''avoir posé la question, et elle écoute la réponse.*

*3.* Question agressive. Ne te défends pas : cherche la question dans la
phrase.

> « Vous pensez à des projets précis qui ont échoué ici ? Lesquels ? »
>
> *(j''écoute la réponse)*
>
> « Je comprends. Ce que nous faisons différemment, c''est que le bac appartient
> aux douze familles qui s''en servent, et qu''il n''y a pas d''argent extérieur à
> gérer. C''est peut-être ce qui a manqué aux autres. »

*Je n''ai pas nié l''expérience de la personne — ce serait l''humilier — et je n''ai
pas promis que ça marcherait. J''ai nommé une différence vérifiable.*

*4.* Tu ne sais pas. Applique les trois temps.

> « Je ne sais pas. *(on le dit)* Je peux demander au menuisier qui a fait le
> premier et vous le dire samedi, si vous repassez. *(on propose)* Ce que je
> sais, c''est que celui de l''école est dehors depuis janvier, qu''il a pris
> toute la saison des pluies, et qu''il n''a pas bougé. *(on donne ce qu''on a)* »

*C''est la meilleure réponse des quatre, et c''est la seule qui avoue une
ignorance. Celui qui t''écoute retiendra deux choses : que tu n''inventes pas, et
que tu as un fait à donner quand même. Après ça, il croira tout le reste.*
', NULL, 26),
    (v_chapitre_id, 'Simulation : la salle de questions', 7, 'interactif', '{
  "widget": "repondre-questions",
  "consigne": "Tu viens de présenter ton stand, et les questions arrivent — simples, agressives, hors sujet, déjà posées, et deux auxquelles tu ne peux pas répondre. Pour chacune, la simulation te fait appliquer les quatre gestes dans l''ordre : écouter jusqu''au bout — elle t''interdit de répondre avant la fin —, reformuler, répondre court puis développer, vérifier. Elle repère quand tu réponds à la personne au lieu de la question, et quand tu inventes une réponse. Un atelier final te fait lister les trois questions que tu redoutes sur ton projet, et préparer les trois réponses : ce sont celles qui viendront."
}', NULL, 10),
    (v_chapitre_id, 'Quiz du chapitre 24', 8, 'quiz', '{
  "titre": "Vérifie que tu as compris",
  "questions": [
    {
      "question": "Comment adapter son engagement quand on donne un avis ?",
      "choix": [
        "Toujours affirmer fort",
        "À ce qu''on sait vraiment : un fait vérifié autorise « je suis convaincu », une impression appelle « il me semble que »",
        "Toujours nuancer",
        "Selon l''interlocuteur"
      ],
      "bonne": 1,
      "explication": "Un interlocuteur pardonne une erreur. Il ne pardonne pas qu''on lui ait présenté une supposition comme une certitude."
    },
    {
      "question": "Quelles sont les trois marques du registre familier à corriger à l''oral soigné ?",
      "choix": [
        "Le vocabulaire, la vitesse, le volume",
        "La négation incomplète (« c''est pas »), le sujet redoublé (« les gens ils »), l''interrogation sans inversion",
        "Les gestes, le regard, la posture",
        "Les tics de langue"
      ],
      "bonne": 1,
      "explication": "Ces trois corrections ne demandent aucun vocabulaire nouveau, seulement de l''attention — et elles changent entièrement l''impression produite."
    },
    {
      "question": "Combien de temps a-t-on pour qu''un visiteur décide de s''arrêter à un stand ?",
      "choix": [
        "Deux minutes",
        "Environ vingt secondes — c''est pourquoi l''accroche se prépare avant tout le reste",
        "Dix minutes",
        "Le temps qu''on veut"
      ],
      "bonne": 1,
      "explication": "Et la question est l''accroche la plus efficace, parce qu''elle oblige à répondre, et que celui qui a répondu reste."
    },
    {
      "question": "Que retient réellement un visiteur d''une présentation de stand ?",
      "choix": [
        "Tes phrases",
        "Trois choses au mieux : un chiffre, une image, et ce que tu lui as fait faire",
        "Le nom du projet",
        "L''affiche"
      ],
      "bonne": 1,
      "explication": "Prépare donc ta présentation à l''envers : choisis d''abord les trois choses qu''il doit emporter, puis construis autour."
    },
    {
      "question": "Quel temps de la présentation les élèves oublient-ils toujours ?",
      "choix": [
        "L''accroche",
        "La DEMANDE : dire au visiteur ce qu''on attend de lui — sans elle, il repart sans savoir quoi faire",
        "Le problème",
        "La solution"
      ],
      "bonne": 1,
      "explication": "Une présentation sans demande est un coup d''épée dans l''eau. Et il faut une seconde porte de sortie pour celui qui hésite."
    },
    {
      "question": "Que faire quand on ne sait pas répondre à une question ?",
      "choix": [
        "Inventer quelque chose de plausible",
        "Trois temps : je ne sais pas, je peux me renseigner et vous le dire, et voici ce que je sais en revanche",
        "Changer de sujet",
        "Renvoyer à quelqu''un d''autre"
      ],
      "bonne": 1,
      "explication": "Celui qui pose la question connaît souvent la réponse — c''est parfois pour cela qu''il la pose. Celui qui sait dire ce qu''il ignore est cru sur ce qu''il affirme."
    },
    {
      "question": "Comment répondre à une question agressive comme « de toute façon rien ne marche jamais ici » ?",
      "choix": [
        "Se défendre",
        "Chercher la question dans la phrase et répondre à elle seule : « vous pensez à des projets précis qui ont échoué ? Lesquels ? »",
        "Ignorer",
        "Répondre sur le même ton"
      ],
      "bonne": 1,
      "explication": "Tu transformes une attaque en information utile — et c''est souvent ce que la personne voulait : être entendue sur ce qui l''a déçue."
    }
  ]
}', NULL, 5);

  RAISE NOTICE '8 leçons ajoutées au chapitre 24, Exprimer une opinion et présenter un stand.';
END $fr3$;
