-- ---------------------------------------------------------------------------
-- M'Andal — Français, classe de 3ème
-- Chapitre 7 : Le schéma narratif, le schéma actanciel et le point de vue
-- Module 1 : La vie familiale et socioculturelle — 10 leçons
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
  WHERE programme_id = v_programme_id AND ordre = 7;

  IF v_chapitre_id IS NULL THEN
    INSERT INTO public.chapitres (programme_id, titre, ordre, niveau)
    VALUES (v_programme_id, 'Le schéma narratif, le schéma actanciel et le point de vue', 7, 'Module 1 : La vie familiale et socioculturelle')
    RETURNING id INTO v_chapitre_id;
    RAISE NOTICE 'Chapitre 7 créé.';
  END IF;

  -- Les leçons. Si le chapitre en a déjà, on passe son tour sans rien toucher.
  SELECT count(*) INTO v_deja FROM public.concepts WHERE chapitre_id = v_chapitre_id;
  IF v_deja > 0 THEN
    RAISE NOTICE 'Le chapitre 7 a déjà ses % leçons, je n''y touche pas.', v_deja;
    RETURN;
  END IF;

  INSERT INTO public.concepts
    (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes) VALUES
    (v_chapitre_id, 'Le schéma narratif : les cinq étapes de tout récit', 1, 'texte', '
Tout récit, du conte que ta grand-mère raconte au roman de six cents pages, suit
la même charpente. Cinq étapes. Les connaître, c''est pouvoir construire une
rédaction au lieu de l''improviser.

### Les cinq étapes

**1. La situation initiale.** On installe : qui, où, quand. Rien ne se passe
encore, et c''est normal. Le temps dominant est l''**imparfait**, parce qu''on
décrit un état qui dure.

> Awa vivait avec sa grand-mère à Bamenda. Chaque matin, elle allait chercher
> l''eau avant l''école.

**2. L''élément perturbateur.** Quelque chose arrive et rompt l''équilibre. C''est
le moment où l''histoire commence vraiment. Le temps bascule au **passé simple**,
et un mot charnière l''annonce souvent : *un jour*, *soudain*, *ce matin-là*.

> Un matin, la borne-fontaine du quartier fut fermée.

**3. Les péripéties.** Les actions s''enchaînent, le personnage affronte des
obstacles. C''est la partie la plus longue, et elle doit **monter** : chaque
obstacle est plus difficile que le précédent.

**4. Le dénouement.** Le problème se règle, en bien ou en mal. Le récit n''est pas
obligé de bien finir ; il est obligé de **finir**.

**5. La situation finale.** Le nouvel équilibre. Le personnage ou sa situation a
changé.

### La règle que les copies oublient

**La situation finale ne doit jamais être identique à la situation initiale.**

Si Awa recommence à chercher l''eau exactement comme avant, et que rien n''a
changé ni dans sa vie ni en elle, alors il ne s''est rien passé : ton récit
tourne en rond.

Ce qui a changé peut être extérieur — une nouvelle borne-fontaine — ou intérieur
— Awa sait désormais qu''elle peut organiser son quartier. Le second est souvent
plus intéressant.

### La faute de proportion

Voici ce que fait la moitié des candidats au BEPC : une situation initiale de
quinze lignes, un élément perturbateur à l''avant-dernière ligne, et un
dénouement expédié en « heureusement tout s''arrangea ».

Les proportions correctes, pour une rédaction d''une trentaine de lignes :

> situation initiale : 4 lignes
> élément perturbateur : 2 lignes
> péripéties : 18 lignes
> dénouement : 4 lignes
> situation finale : 2 lignes

Les péripéties occupent plus de la moitié. C''est là qu''est ton récit ; le reste
l''encadre.

Fais ce schéma au brouillon, en cinq lignes, **avant** d''écrire. Cinq minutes, et
tu ne te retrouveras pas à court de place.

---

**Exercice corrigé**

*Repérer les cinq étapes du récit suivant, et dire ce qui a changé entre la
situation initiale et la situation finale.*

> *Depuis trois ans, mon oncle tenait une petite échoppe de réparation de
> téléphones au carrefour. Il connaissait tout le monde et tout le monde le
> connaissait.*
>
> *Un soir de juillet, un orage emporta la tôle de son toit et noya son
> matériel.*
>
> *Il essaya d''abord de sécher les appareils au soleil ; la plupart ne
> repartirent pas. Il alla voir un prêteur, qui lui demanda un intérêt
> impossible. Il pensa fermer. C''est alors que trois de ses clients, apprenant
> la nouvelle, passèrent le voir et lui avancèrent chacun une petite somme, sans
> intérêt, à rembourser quand il pourrait.*
>
> *En trois semaines, l''échoppe rouvrit.*
>
> *Mon oncle travaille toujours au même carrefour. Mais il a pris l''habitude,
> quand un client est en difficulté, de réparer d''abord et de se faire payer
> ensuite.*

**Correction.**

*Situation initiale.* Le premier paragraphe. L''imparfait domine — *tenait*,
*connaissait* — et il installe un équilibre qui dure depuis trois ans.

*Élément perturbateur.* « Un soir de juillet, un orage emporta la tôle. » On
reconnaît les deux marques : le complément de temps en tête — *un soir de
juillet* — et le passage au passé simple — *emporta*, *noya*.

*Péripéties.* Tout le troisième paragraphe, et c''est le plus long, comme il se
doit. Trois obstacles qui montent : le séchage au soleil échoue, le prêteur
demande trop, il pense fermer. Le récit touche le fond avant de remonter.

*Dénouement.* L''arrivée des trois clients, puis « en trois semaines, l''échoppe
rouvrit ». Le problème est réglé.

*Situation finale.* Le dernier paragraphe. Le présent revient — *travaille* —
parce qu''on est sorti du récit pour revenir au moment où l''on parle.

*Ce qui a changé.* En apparence, rien : même oncle, même carrefour, même métier.
Mais la dernière phrase dit le vrai changement, et il est **intérieur** : ayant
reçu de l''aide, il en donne à son tour.

*C''est le modèle à suivre. Le changement extérieur — l''échoppe rouvre — règle
l''intrigue ; le changement intérieur — il répare d''abord et se fait payer
ensuite — donne au récit son sens. Une rédaction qui a les deux est une bonne
rédaction.*
', NULL, 26),
    (v_chapitre_id, 'Figure : les cinq étapes du schéma narratif', 2, 'figure', '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 580 270" width="580" height="270">
<rect width="580" height="270" fill="#ffffff"/>
<text x="290" y="24" text-anchor="middle" font-size="14" font-weight="700" fill="#0f172a">Le schéma narratif : cinq étapes, toujours les mêmes</text>

<path d="M 40 170 L 150 170 L 290 60 L 430 170 L 540 170" fill="none" stroke="#cbd5e1" stroke-width="2.5"/>

<circle cx="40" cy="170" r="7" fill="#2563eb"/>
<circle cx="150" cy="170" r="7" fill="#ca8a04"/>
<circle cx="290" cy="60" r="7" fill="#b91c1c"/>
<circle cx="430" cy="170" r="7" fill="#15803d"/>
<circle cx="540" cy="170" r="7" fill="#7c3aed"/>

<text x="40" y="196" text-anchor="middle" font-size="9" font-weight="700" fill="#1e3a8a">1. SITUATION</text>
<text x="40" y="208" text-anchor="middle" font-size="9" font-weight="700" fill="#1e3a8a">INITIALE</text>
<text x="40" y="224" text-anchor="middle" font-size="8" fill="#64748b">qui, où, quand</text>
<text x="40" y="236" text-anchor="middle" font-size="8" fill="#64748b">à l&apos;imparfait</text>

<text x="150" y="196" text-anchor="middle" font-size="9" font-weight="700" fill="#78350f">2. ÉLÉMENT</text>
<text x="150" y="208" text-anchor="middle" font-size="9" font-weight="700" fill="#78350f">PERTURBATEUR</text>
<text x="150" y="224" text-anchor="middle" font-size="8" fill="#64748b">soudain, un jour</text>
<text x="150" y="236" text-anchor="middle" font-size="8" fill="#64748b">au passé simple</text>

<text x="290" y="44" text-anchor="middle" font-size="9" font-weight="700" fill="#7f1d1d">3. PÉRIPÉTIES</text>
<text x="290" y="30" text-anchor="middle" font-size="8" fill="#64748b">les obstacles, le plus gros est ici</text>

<text x="430" y="196" text-anchor="middle" font-size="9" font-weight="700" fill="#14532d">4. DÉNOUEMENT</text>
<text x="430" y="212" text-anchor="middle" font-size="8" fill="#64748b">le problème se règle</text>
<text x="430" y="224" text-anchor="middle" font-size="8" fill="#64748b">bien ou mal</text>

<text x="540" y="196" text-anchor="middle" font-size="9" font-weight="700" fill="#5b21b6">5. SITUATION</text>
<text x="540" y="208" text-anchor="middle" font-size="9" font-weight="700" fill="#5b21b6">FINALE</text>
<text x="540" y="224" text-anchor="middle" font-size="8" fill="#64748b">un nouvel</text>
<text x="540" y="236" text-anchor="middle" font-size="8" fill="#64748b">équilibre</text>

<text x="290" y="258" text-anchor="middle" font-size="10" font-weight="700" fill="#7f1d1d">La situation finale n&apos;est jamais identique à l&apos;initiale : sinon rien ne s&apos;est passé.</text>
</svg>', NULL, 5),
    (v_chapitre_id, 'Simulation : bâtir le schéma avant d''écrire', 3, 'interactif', '{
  "widget": "schema-narratif",
  "consigne": "Tu reçois un sujet de rédaction et cinq cases vides à remplir au brouillon. Pour chaque étape, la simulation te propose plusieurs suites possibles et te montre ce que chacune promet pour la suite du récit. Elle surveille deux choses que les correcteurs guettent : les proportions — si ta situation initiale dépasse le cinquième du texte, la barre vire au rouge — et le changement final, car elle refuse une situation finale identique à l''initiale. Un second volet fait l''inverse : un récit s''affiche en désordre et tu dois le remettre dans ses cinq étapes."
}', NULL, 10),
    (v_chapitre_id, 'Le schéma actanciel : qui veut quoi, et qui l''en empêche', 4, 'texte', '
Le schéma narratif dit **ce qui se passe**. Le schéma actanciel dit **qui agit**,
et pourquoi. Les deux se complètent, et le programme te demande de savoir
construire l''un ou l''autre.

### Les six rôles

Un **actant** n''est pas forcément une personne. C''est un rôle dans l''histoire, et
il peut être tenu par un objet, un sentiment, une institution.

**Le sujet.** Celui qui veut quelque chose et qui agit. C''est en général le
héros.

**L''objet.** Ce qu''il veut. Un but, une personne, un bien, une reconnaissance.

**Le destinateur.** Ce qui pousse le sujet à vouloir, ce qui le met en route.
Une personne, mais aussi un devoir, un besoin, une promesse.

**Le destinataire.** Celui qui profitera de la réussite. Souvent le sujet
lui-même, mais pas toujours.

**Les adjuvants.** Ceux qui aident. Personnes, objets, qualités.

**Les opposants.** Ceux qui font obstacle. Personnes, mais aussi la peur, la
pauvreté, l''administration.

### L''exemple de « Ville cruelle »

Reprenons Banda, du roman lu ce trimestre.

> **Sujet** : Banda.
> **Objet** : vendre sa récolte de cacao pour obtenir de l''argent.
> **Destinateur** : sa mère malade et le mariage qu''il veut conclure — ce sont
> eux qui le mettent en route.
> **Destinataire** : sa mère, sa future épouse, et lui-même.
> **Adjuvants** : son travail, sa force, et plus tard la solidarité de quelques
> habitants de Tanga.
> **Opposants** : l''inspecteur, l''administration coloniale, le système des prix,
> et plus largement la ville elle-même.

Remarque les deux derniers : les opposants principaux ne sont pas des méchants,
ce sont des **mécanismes**. C''est ce qui fait la force du roman, et le dire en
copie montre que tu as compris autre chose qu''une histoire.

### À quoi cela te sert, concrètement

**Pour analyser une œuvre**, cela te donne un plan tout fait quand on te demande
d''étudier un personnage.

**Pour écrire une rédaction**, cela t''évite le défaut le plus courant : le héros
qui veut quelque chose de vague, contre un obstacle vague. Avant d''écrire,
remplis les six cases. Si tu n''arrives pas à nommer l''objet ou l''opposant, ton
récit n''a pas encore d''histoire.

Et retiens cette règle d''or : **plus l''opposant est fort, meilleur est le
récit**. Un héros qui réussit sans difficulté n''intéresse personne.

---

**Exercice corrigé**

*Construire le schéma actanciel du récit de l''oncle réparateur, étudié à la leçon
précédente. Puis dire pourquoi ce récit tient debout.*

**Correction.**

*Le schéma.*

**Sujet** : l''oncle. C''est lui qui agit — il sèche, il va voir le prêteur, il
pense fermer, il rouvre.

**Objet** : rouvrir son échoppe, c''est-à-dire retrouver son métier et son
revenu.

**Destinateur** : ce qui le met en route est double. Le besoin de vivre, et
l''attachement à un métier qu''il exerce depuis trois ans au même carrefour.

**Destinataire** : lui-même, et par extension sa famille. On pourrait ajouter le
quartier, qui perdrait son réparateur.

**Adjuvants** : les trois clients, et derrière eux la réputation qu''il s''était
faite — « il connaissait tout le monde et tout le monde le connaissait ». C''est
cette phrase de la situation initiale qui rend l''aide finale croyable.

**Opposants** : l''orage, la perte du matériel, et le prêteur avec son intérêt
impossible.

*Pourquoi ce récit tient debout.* Trois raisons, et elles se lisent dans le
schéma.

**L''objet est précis.** Rouvrir l''échoppe. On peut dire à chaque ligne si le
personnage s''en rapproche ou s''en éloigne.

**Les opposants sont réels et variés.** Un accident naturel, puis une difficulté
matérielle, puis une personne. Ils ne se répètent pas, et ils montent.

**L''adjuvant était préparé.** Les trois clients n''arrivent pas de nulle part :
la situation initiale avait installé la réputation de l''oncle. C''est la
différence entre un dénouement et un coup de chance.

*La leçon pour tes rédactions : un sauveur qui tombe du ciel au dernier moment
ne sauve rien. Place dans ta situation initiale l''élément qui rendra ton
dénouement possible, et le lecteur sentira que ton histoire tenait depuis le
début.*
', NULL, 26),
    (v_chapitre_id, 'Simulation : remplir les six cases', 5, 'interactif', '{
  "widget": "schema-actanciel",
  "consigne": "Six cases vides, et une histoire à y faire entrer. Tu commences par les œuvres du programme — Ville cruelle, puis d''autres récits — en plaçant les personnages et les forces dans les bons rôles. La simulation accepte qu''un actant ne soit pas une personne : la pauvreté, l''administration et la peur sont des opposants recevables, et elle te le signale si tu ne cherches que des gens. Un second volet renverse l''exercice : tu construis ton propre schéma pour un sujet de rédaction, et elle t''avertit si l''objet reste vague ou si l''opposant est trop faible pour faire un récit."
}', NULL, 10),
    (v_chapitre_id, 'Le point de vue : qui voit, et jusqu''où', 6, 'texte', '
Dernière notion du chapitre, et c''est celle qui change le plus un texte. Le
**point de vue**, qu''on appelle aussi la **focalisation**, c''est la position
depuis laquelle l''histoire est racontée.

Il y en a trois.

### La focalisation externe

Le narrateur est une **caméra**. Il rapporte ce qu''on peut voir et entendre, rien
de plus. Aucune pensée, aucun sentiment.

> Un homme entra, traversa la pièce et s''assit. Il ne dit rien. Au bout d''un
> moment, il sortit une enveloppe de sa poche et la posa sur la table.

Que pense cet homme ? On n''en sait rien, et c''est voulu. **Le lecteur en sait
moins que le personnage.**

*Effet* : le mystère, la tension. C''est le point de vue des débuts de romans
policiers et des scènes où l''on veut inquiéter.

### La focalisation interne

Le narrateur entre dans la tête d''**un seul** personnage. On connaît ses
pensées, ses sensations, ses souvenirs — et uniquement les siens.

> Il entra. La pièce sentait le vieux papier, comme le bureau de son père. Il
> s''assit, le cœur battant, et chercha du regard un visage qu''il aurait reconnu.
> Personne.

**Le lecteur en sait autant que le personnage**, ni plus ni moins. Si le
personnage se trompe, le lecteur se trompe avec lui.

*Effet* : l''identification. C''est le point de vue le plus utile pour une
rédaction où l''on te demande de raconter une expérience.

### La focalisation omnisciente

Le narrateur sait **tout** : les pensées de tous les personnages, le passé,
l''avenir, ce qui se passe ailleurs au même moment.

> Il entra, inquiet sans savoir pourquoi. Son père, qui l''attendait depuis une
> heure et avait répété dix fois ce qu''il allait dire, se tut en le voyant.
> Aucun des deux ne savait que cette conversation serait la dernière.

**Le lecteur en sait plus que les personnages.**

*Effet* : la compréhension d''ensemble, et parfois l''ironie — on voit le
personnage se tromper alors qu''on sait la vérité.

### Le repère qui ne trompe pas

Pour trouver le point de vue d''un texte, pose une seule question :

> **Dans combien de têtes entre-t-on ?**

Aucune → focalisation **externe**.
Une seule → focalisation **interne**.
Plusieurs → focalisation **omnisciente**.

Attention à l''erreur classique : la focalisation interne n''est pas liée au
« je ». On peut être en focalisation interne avec « il », comme dans l''exemple
ci-dessus. Ce qui compte n''est pas le pronom, c''est de savoir dans quelle tête
on est.

### En rédaction : choisir, et s''y tenir

Changer de point de vue au milieu d''un récit sans raison est une maladresse que
les correcteurs sanctionnent.

Si tu as commencé en focalisation interne sur Awa, tu ne peux pas écrire
soudain : « Pendant ce temps, sa grand-mère pensait qu''elle était bien
imprudente. » Tu viens de sortir de la tête d''Awa sans prévenir.

Choisis au brouillon, note-le, et tiens-le jusqu''au bout.

---

**Exercice corrigé**

*Réécrire la scène suivante dans les deux autres focalisations, puis dire ce que
chacune apporte.*

> *(focalisation externe)* *La femme s''arrêta devant la porte de la classe. Elle
> regarda sa montre, puis la porte, puis sa montre encore. Elle fit trois pas en
> arrière, s''adossa au mur et attendit.*

**Correction.**

*En focalisation interne.* J''entre dans la tête de la femme, et dans la sienne
seulement.

> *Elle s''arrêta devant la porte. Il était onze heures vingt : le cours ne
> finirait pas avant midi. Entrer maintenant, c''était faire se retourner trente
> élèves et obliger le professeur à s''interrompre pour elle. Elle recula de trois
> pas, s''adossa au mur et décida d''attendre. Quarante minutes. Elle aurait pu
> téléphoner avant de venir.*

*Ce que cela apporte.* Les gestes de l''original reçoivent une explication. On
comprend pourquoi elle regarde sa montre — elle calcule — et pourquoi elle
recule — par égard. On s''attache à elle, et le dernier regret la rend humaine.

*En focalisation omnisciente.* J''entre dans plusieurs têtes, et je sais des
choses que personne ne sait.

> *Elle s''arrêta devant la porte, calculant qu''il restait quarante minutes de
> cours. Derrière le battant, le professeur l''avait entendue et espérait qu''elle
> entrerait, car il cherchait depuis un quart d''heure un prétexte pour écourter
> sa leçon. Au fond de la classe, un élève avait reconnu le pas de sa mère et
> commençait à ranger ses affaires. Aucun des trois ne se doutait de ce que les
> deux autres pensaient.*

*Ce que cela apporte.* L''ironie. Trois personnes se trouvent à deux mètres les
unes des autres, chacune empêchée par une idée fausse de ce que les autres
veulent. Seul le lecteur voit le malentendu complet, et c''est de cette
supériorité que naît le sourire.

*Récapitulons ce que les trois versions font du même geste — reculer de trois
pas. En externe, c''est un mystère. En interne, c''est de la délicatesse. En
omniscient, c''est une erreur, puisque le professeur l''attendait. Le fait n''a pas
changé ; le point de vue a tout changé.*
', NULL, 28),
    (v_chapitre_id, 'Simulation : la même scène, trois points de vue', 7, 'interactif', '{
  "widget": "point-de-vue",
  "consigne": "Une scène s''affiche et tu choisis la focalisation : externe, interne ou omnisciente. Le texte se réécrit devant toi, et un panneau te montre ce que le lecteur sait à chaque instant, comparé à ce que savent les personnages. Essaie ensuite le mode correcteur : des textes te sont soumis avec une rupture de point de vue cachée au milieu, et tu dois trouver la phrase qui sort de la tête du personnage sans prévenir. C''est la maladresse la plus sanctionnée en rédaction, et elle est difficile à voir quand on est l''auteur."
}', NULL, 10),
    (v_chapitre_id, 'Figure : la même scène selon le point de vue', 8, 'figure', '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 580 280" width="580" height="280">
<rect width="580" height="280" fill="#ffffff"/>
<text x="290" y="24" text-anchor="middle" font-size="14" font-weight="700" fill="#0f172a">Trois points de vue, trois récits différents</text>
<text x="290" y="42" text-anchor="middle" font-size="10" fill="#64748b">La même scène : un homme entre dans une pièce et s&apos;assoit.</text>

<rect x="18" y="56" width="176" height="206" rx="6" fill="#fef3c7" stroke="#ca8a04" stroke-width="1.6"/>
<text x="106" y="78" text-anchor="middle" font-size="11" font-weight="700" fill="#78350f">EXTERNE</text>
<text x="106" y="94" text-anchor="middle" font-size="8" fill="#92400e">la caméra</text>
<line x1="30" y1="104" x2="182" y2="104" stroke="#fde047"/>
<text x="30" y="124" font-size="9" fill="#92400e">Un homme entra</text>
<text x="30" y="138" font-size="9" fill="#92400e">et s&apos;assit sans</text>
<text x="30" y="152" font-size="9" fill="#92400e">dire un mot.</text>
<line x1="50" y1="166" x2="162" y2="166" stroke="#fef08a"/>
<text x="30" y="186" font-size="8" fill="#78350f">On voit, on entend.</text>
<text x="30" y="200" font-size="8" fill="#78350f">Aucune pensée.</text>
<text x="30" y="222" font-size="8" font-style="italic" fill="#475569">Effet : mystère,</text>
<text x="30" y="234" font-size="8" font-style="italic" fill="#475569">tension. Le lecteur</text>
<text x="30" y="246" font-size="8" font-style="italic" fill="#475569">en sait moins que</text>
<text x="30" y="258" font-size="8" font-style="italic" fill="#475569">le personnage.</text>

<rect x="202" y="56" width="176" height="206" rx="6" fill="#dbeafe" stroke="#2563eb" stroke-width="1.6"/>
<text x="290" y="78" text-anchor="middle" font-size="11" font-weight="700" fill="#1e3a8a">INTERNE</text>
<text x="290" y="94" text-anchor="middle" font-size="8" fill="#1e40af">dans une seule tête</text>
<line x1="214" y1="104" x2="366" y2="104" stroke="#93c5fd"/>
<text x="214" y="124" font-size="9" fill="#1e40af">Il entra. La pièce</text>
<text x="214" y="138" font-size="9" fill="#1e40af">sentait le vieux</text>
<text x="214" y="152" font-size="9" fill="#1e40af">papier. Il s&apos;assit,</text>
<text x="214" y="166" font-size="9" fill="#1e40af">le cœur battant.</text>
<line x1="234" y1="180" x2="346" y2="180" stroke="#bfdbfe"/>
<text x="214" y="200" font-size="8" fill="#1e3a8a">On sait tout de lui,</text>
<text x="214" y="212" font-size="8" fill="#1e3a8a">rien des autres.</text>
<text x="214" y="232" font-size="8" font-style="italic" fill="#475569">Effet : on s&apos;attache.</text>
<text x="214" y="244" font-size="8" font-style="italic" fill="#475569">Le lecteur en sait</text>
<text x="214" y="256" font-size="8" font-style="italic" fill="#475569">autant que lui.</text>

<rect x="386" y="56" width="176" height="206" rx="6" fill="#dcfce7" stroke="#15803d" stroke-width="1.6"/>
<text x="474" y="78" text-anchor="middle" font-size="11" font-weight="700" fill="#14532d">OMNISCIENTE</text>
<text x="474" y="94" text-anchor="middle" font-size="8" fill="#166534">le narrateur sait tout</text>
<line x1="398" y1="104" x2="550" y2="104" stroke="#86efac"/>
<text x="398" y="124" font-size="9" fill="#166534">Il entra, inquiet.</text>
<text x="398" y="138" font-size="9" fill="#166534">Son père, qui</text>
<text x="398" y="152" font-size="9" fill="#166534">l&apos;attendait depuis</text>
<text x="398" y="166" font-size="9" fill="#166534">une heure, se tut.</text>
<line x1="418" y1="180" x2="530" y2="180" stroke="#bbf7d0"/>
<text x="398" y="200" font-size="8" fill="#14532d">Toutes les pensées,</text>
<text x="398" y="212" font-size="8" fill="#14532d">le passé, l&apos;avenir.</text>
<text x="398" y="232" font-size="8" font-style="italic" fill="#475569">Effet : on comprend</text>
<text x="398" y="244" font-size="8" font-style="italic" fill="#475569">tout. Le lecteur en</text>
<text x="398" y="256" font-size="8" font-style="italic" fill="#475569">sait plus qu&apos;eux.</text>
</svg>', NULL, 5),
    (v_chapitre_id, 'Sujet type BEPC — Expression écrite', 9, 'texte', '
**Épreuve d''expression écrite**

*Traite le sujet suivant en une trentaine de lignes.*

> **Sujet.** Un événement imprévu est venu bouleverser une journée que tu
> croyais ordinaire. Raconte cet événement et montre ce qu''il a changé pour toi.

---
---

## Corrigé

### I. Analyser le sujet avant d''écrire

Trois mots commandent tout, et il faut les repérer au brouillon.

**« Un événement imprévu ».** Le sujet impose un **élément perturbateur** : il y
aura donc une situation initiale calme, puis une rupture. La charpente est déjà
donnée.

**« Raconte ».** C''est un **récit**, pas une argumentation. On attend des
actions, des temps du passé, un personnage. Une copie qui disserte sur
l''imprévu est hors sujet, et perd la moitié des points d''emblée.

**« Montre ce qu''il a changé pour toi ».** Voilà la vraie exigence, et c''est
elle que les candidats oublient. Il ne suffit pas de raconter : il faut une
**situation finale différente de la situation initiale**. Le mot « toi » impose
en plus la première personne et la focalisation interne.

### II. Le brouillon : cinq lignes, cinq minutes

> **Situation initiale** — un samedi ordinaire, je devais aller au marché avec
> ma mère.
> **Élément perturbateur** — en chemin, nous trouvons un vieil homme tombé au
> bord de la route.
> **Péripéties** — personne ne s''arrête ; ma mère s''arrête ; nous cherchons de
> l''aide ; une moto refuse, une autre accepte ; nous le conduisons au centre de
> santé ; il faut avancer l''argent de la consultation, qui était celui du
> marché.
> **Dénouement** — l''homme est soigné ; sa famille arrive ; nous rentrons sans
> avoir fait le marché.
> **Situation finale** — je ne passe plus devant quelqu''un sans regarder.

*Le schéma actanciel, en trois lignes de plus :* sujet, ma mère et moi ; objet,
secourir l''homme ; opposants, l''indifférence des passants, le manque d''argent,
le temps ; adjuvants, le motocycliste, l''argent du marché.

### III. Le devoir rédigé

> C''était un samedi comme les autres. Ma mère m''avait réveillée tôt pour
> l''accompagner au marché, et je traînais les pieds derrière elle sur la route
> de terre. Je pensais surtout au tissu qu''elle m''avait promis si les prix
> étaient bons.
>
> Nous étions à mi-chemin quand je la vis s''arrêter net. Un vieil homme était
> assis contre le talus, la tête basse, une jambe repliée sous lui dans une
> position qui n''était pas naturelle. Trois personnes passèrent devant nous sans
> ralentir.
>
> Ma mère posa son panier. Elle s''accroupit près de l''homme et lui parla
> doucement, en bulu d''abord, puis en français. Il répondit à peine. Son front
> était trempé.
>
> Je restai debout, inutile. Je me souviens d''avoir pensé que nous allions
> manquer les bons prix, et j''ai honte aujourd''hui de m''en souvenir si bien.
>
> Ma mère me demanda d''arrêter une moto. La première refusa : il ne voulait pas
> de malade sur son engin. La deuxième hésita, puis accepta quand ma mère lui
> dit que c''était peut-être son propre père qui serait là un jour. Nous
> installâmes le vieil homme entre nous deux et nous partîmes vers le centre de
> santé.
>
> À l''accueil, on demanda deux mille francs pour la consultation. Ma mère ouvrit
> son pagne et paya sans un mot. C''était l''argent du marché. Je la regardai
> faire et je ne dis rien non plus.
>
> Le vieil homme avait une fracture. Sa famille arriva en fin de matinée,
> prévenue par le motocycliste, qui était reparti les chercher sans qu''on le lui
> demande. Le fils voulut rembourser ; ma mère refusa en disant que ce n''était
> pas un prêt.
>
> Nous sommes rentrées à pied, le panier vide. Il n''y a pas eu de tissu ce
> samedi-là, et le repas du soir fut maigre.
>
> Depuis, je ne passe plus devant quelqu''un d''assis au bord de la route sans
> ralentir et sans regarder. Ce n''est pas grand-chose. Mais ce samedi-là, trois
> personnes sont passées devant nous sans le faire, et j''ai compris que je
> pouvais très bien être la quatrième.

### IV. Pourquoi cette copie serait bien notée

**La charpente se voit sans être annoncée.** Les cinq étapes y sont, aux bonnes
proportions : trois lignes de situation initiale, deux pour la rupture, la
moitié du devoir pour les péripéties.

**Les obstacles montent.** L''indifférence des passants, puis le refus du premier
motocycliste, puis l''argent à sortir. Trois obstacles de nature différente, et
le dernier coûte le plus.

**Les temps alternent correctement.** Imparfait pour l''installation — *c''était*,
*traînais*, *pensais* —, passé simple pour les actions — *vit*, *posa*,
*partîmes* —, présent dans la dernière phrase pour revenir au moment où l''on
parle.

**Le point de vue tient du début à la fin.** On reste dans la tête de la
narratrice. On ne sait jamais ce que pense le vieil homme, ni ce que pense la
mère : seulement ce que la narratrice en voit.

**La situation finale est intérieure.** Rien n''a changé dans sa vie — pas de
tissu, un repas maigre. Ce qui a changé est en elle, et la dernière phrase le
dit sans le proclamer.

**Un détail porte tout le sens.** « J''ai honte aujourd''hui de m''en souvenir si
bien. » Cette phrase coûte une ligne et transforme le devoir : la narratrice se
juge elle-même, ce qui est bien plus fort que de juger les passants.

### Ce que le correcteur attend

**Répondre à toute la consigne.** « Raconte » **et** « montre ce qu''il a
changé ». Une copie qui s''arrête au récit perd les points du second verbe.

**Montrer plutôt que proclamer.** « J''ai appris ce jour-là qu''il faut aider son
prochain » est une morale plaquée. La dernière phrase de la copie dit la même
chose en se gardant de la dire.

**Soigner la langue.** C''est l''un des trois critères officiels de l''épreuve. Une
copie pleine d''idées mais fautive sur les accords perd plus qu''une copie moyenne
et correcte. Garde cinq minutes pour relire, et relis **en cherchant les verbes**
: pose devant chacun la question « qui est-ce qui ? ».
', NULL, 32),
    (v_chapitre_id, 'Quiz du chapitre 7', 10, 'quiz', '{
  "titre": "Vérifie que tu as compris",
  "questions": [
    {
      "question": "Quelles sont les cinq étapes du schéma narratif ?",
      "choix": [
        "Début, milieu, fin, morale, conclusion",
        "Situation initiale, élément perturbateur, péripéties, dénouement, situation finale",
        "Introduction, développement, conclusion",
        "Thèse, antithèse, synthèse"
      ],
      "bonne": 1,
      "explication": "Et les péripéties doivent occuper plus de la moitié du texte : c''est là qu''est ton récit, le reste l''encadre."
    },
    {
      "question": "Pourquoi la situation finale ne doit-elle jamais être identique à l''initiale ?",
      "choix": [
        "Pour faire plus long",
        "Parce que sinon il ne s''est rien passé : le récit tourne en rond",
        "Pour respecter le nombre de lignes",
        "Ce n''est pas une règle"
      ],
      "bonne": 1,
      "explication": "Le changement peut être extérieur ou intérieur. Le second est souvent plus intéressant, et c''est lui que les bons devoirs choisissent."
    },
    {
      "question": "Dans le schéma actanciel, qu''est-ce qu''un opposant ?",
      "choix": [
        "Toujours un personnage méchant",
        "Ce qui fait obstacle : une personne, mais aussi la peur, la pauvreté ou une administration",
        "Celui qui profite de la réussite",
        "Celui qui aide le héros"
      ],
      "bonne": 1,
      "explication": "Dans Ville cruelle, les opposants principaux ne sont pas des méchants mais des mécanismes. Le dire en copie montre qu''on a compris autre chose qu''une histoire."
    },
    {
      "question": "Quelle règle d''or sur les opposants ?",
      "choix": [
        "Il en faut le moins possible",
        "Plus l''opposant est fort, meilleur est le récit : un héros qui réussit sans difficulté n''intéresse personne",
        "Il faut un seul opposant",
        "L''opposant doit gagner"
      ],
      "bonne": 1,
      "explication": "Et place dans ta situation initiale l''élément qui rendra ton dénouement possible : un sauveur qui tombe du ciel au dernier moment ne sauve rien."
    },
    {
      "question": "Comment trouver le point de vue d''un texte ?",
      "choix": [
        "En regardant si le texte dit « je »",
        "En se demandant dans combien de têtes on entre : aucune, une seule, ou plusieurs",
        "En comptant les personnages",
        "En cherchant le narrateur"
      ],
      "bonne": 1,
      "explication": "La focalisation interne n''est pas liée au « je » : on peut être dans la tête d''un personnage avec « il ». Ce qui compte n''est pas le pronom."
    },
    {
      "question": "Quel effet produit la focalisation externe ?",
      "choix": [
        "L''identification au personnage",
        "Le mystère et la tension : le lecteur en sait moins que le personnage",
        "La compréhension d''ensemble",
        "L''ironie"
      ],
      "bonne": 1,
      "explication": "C''est le point de vue des débuts de romans policiers. L''interne fait s''attacher, l''omnisciente fait comprendre et permet l''ironie."
    },
    {
      "question": "Dans le sujet « Raconte cet événement et montre ce qu''il a changé pour toi », que oublient les candidats ?",
      "choix": [
        "De raconter",
        "Le second verbe : montrer ce qui a changé, c''est-à-dire la situation finale différente de l''initiale",
        "D''écrire trente lignes",
        "De mettre un titre"
      ],
      "bonne": 1,
      "explication": "Une copie qui s''arrête au récit perd les points du second verbe. Et « j''ai appris ce jour-là qu''il faut aider son prochain » est une morale plaquée : montre, ne proclame pas."
    }
  ]
}', NULL, 5);

  RAISE NOTICE '10 leçons ajoutées au chapitre 7, Le schéma narratif, le schéma actanciel et le point de vue.';
END $fr3$;
