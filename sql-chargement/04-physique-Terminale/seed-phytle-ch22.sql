-- ============================================================================
-- MANDAL — Physique Terminale : chapitre 22, La radioactivité
-- Module 4 : Ondes, matière et transformations nucléaires
-- 6 leçons.
--
-- Ce fichier remplit LES DEUX CLASSES a la fois : Terminale C et Terminale D.
-- Autonome : il cree lui-meme la matiere, les classes, les programmes et le
-- chapitre s'ils n'existent pas encore. Lancez-le seul, dans n'importe quel
-- ordre.
-- Idempotent : si le chapitre contient deja des lecons, rien n'est ajoute.
-- ============================================================================
DO $ptc$
DECLARE
  v_noms text[] := ARRAY['Terminale C', 'Terminale D'];
  v_lettres text[] := ARRAY['C', 'D'];
  v_i int;
  v_nom text;
  v_lettre text;
  v_matiere_id uuid;
  v_classe_id uuid;
  v_etab_id uuid;
  v_programme_id uuid;
  v_chapitre_id uuid;
  v_nb_etabs int;
  v_deja int;
BEGIN
  -- la matiere, une seule fois
  INSERT INTO public.matieres (nom) VALUES ('Physique') ON CONFLICT (nom) DO NOTHING;
  SELECT id INTO v_matiere_id FROM public.matieres WHERE nom = 'Physique';

  -- l'etablissement, deduit de la table des classes
  SELECT count(DISTINCT etablissement_id) INTO v_nb_etabs FROM public.classes;
  IF v_nb_etabs <> 1 THEN
    RAISE EXCEPTION 'Impossible de deduire l''etablissement : % etablissement(s) distinct(s) dans public.classes.', v_nb_etabs;
  END IF;
  SELECT etablissement_id INTO v_etab_id FROM public.classes LIMIT 1;

  -- on refait le meme travail pour la Terminale C puis pour la Terminale D
  FOR v_i IN 1..2 LOOP
    v_nom := v_noms[v_i];
    v_lettre := v_lettres[v_i];

    -- 1. le programme existe-t-il deja ?
    SELECT p.id INTO v_programme_id FROM public.programmes p
    WHERE p.titre = 'Physique — ' || v_nom;

    -- 2. sinon on le cree
    IF v_programme_id IS NULL THEN
      -- la classe, quelle que soit la facon dont elle a ete ecrite
      SELECT id INTO v_classe_id FROM public.classes
      WHERE etablissement_id = v_etab_id
        AND (nom = v_nom OR nom ILIKE 'T%le ' || v_lettre)
      ORDER BY (nom = v_nom) DESC
      LIMIT 1;

      -- si elle n'existe pas, on la cree
      IF v_classe_id IS NULL THEN
        INSERT INTO public.classes (etablissement_id, nom, niveau, filiere)
        VALUES (v_etab_id, v_nom, 'Terminale', v_lettre)
        RETURNING id INTO v_classe_id;
        RAISE NOTICE 'Classe "%" creee.', v_nom;
      END IF;

      INSERT INTO public.programmes (matiere_id, classe_id, etablissement_id, titre, description)
      VALUES (v_matiere_id, v_classe_id, v_etab_id, 'Physique — ' || v_nom,
              'Programme officiel de Physique, classe de Terminale ' || v_lettre ||
              ' (Cameroun) — 4 modules, 22 chapitres.')
      RETURNING id INTO v_programme_id;
      RAISE NOTICE 'Programme "Physique — %" cree.', v_nom;
    END IF;

    -- 3. le chapitre existe-t-il deja ?
    SELECT id INTO v_chapitre_id FROM public.chapitres
    WHERE programme_id = v_programme_id AND ordre = 22;

    -- 4. sinon on le cree
    IF v_chapitre_id IS NULL THEN
      INSERT INTO public.chapitres (programme_id, titre, ordre, niveau)
      VALUES (v_programme_id, 'La radioactivité', 22, 'Module 4 : Ondes, matière et transformations nucléaires')
      RETURNING id INTO v_chapitre_id;
      RAISE NOTICE '% : chapitre 22 cree.', v_nom;
    END IF;

    -- 5. les lecons
    SELECT count(*) INTO v_deja FROM public.concepts WHERE chapitre_id = v_chapitre_id;
    IF v_deja > 0 THEN
      RAISE NOTICE '% : chapitre 22 contient deja % lecon(s) — aucun ajout.', v_nom, v_deja;
      CONTINUE;
    END IF;

    INSERT INTO public.concepts
      (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes) VALUES
      (v_chapitre_id, 'Le noyau, le défaut de masse et l''énergie de liaison', 1, 'texte', 'Le noyau d''un atome rassemble des protons qui se repoussent violemment. S''il tient quand même, c''est qu''une force bien plus puissante que l''électricité les maintient ensemble.

## La composition du noyau

Un noyau se note $^{A}_{Z}\text{X}$.

Le **numéro atomique** $Z$ est le nombre de protons. Il identifie l''élément chimique.

Le **nombre de masse** $A$ est le nombre total de nucléons, c''est-à-dire protons plus neutrons. Le nombre de neutrons vaut donc $N = A - Z$.

Deux noyaux sont **isotopes** quand ils ont le même $Z$ mais des $A$ différents. Le carbone 12 et le carbone 14 sont isotopes : même élément, mais deux neutrons de plus pour le second.

## Le défaut de masse

Pèse un noyau, puis pèse séparément tous ses nucléons. Surprise : le noyau est **plus léger** que la somme de ses morceaux.

Cette différence s''appelle le **défaut de masse** :
$$\Delta m = Z\,m_{p} + (A - Z)\,m_{n} - m_{\text{noyau}}$$

Elle est toujours positive.

## L''énergie de liaison

Einstein a établi l''équivalence entre masse et énergie :
$$E = m\,c^{2}$$

La masse manquante s''est donc transformée en énergie lors de la formation du noyau. Cette énergie, c''est l''**énergie de liaison** :
$$E_{\ell} = \Delta m\,c^{2}$$

C''est l''énergie qu''il faudrait fournir pour séparer complètement tous les nucléons.

En pratique on travaille en MeV, et on utilise l''unité de masse atomique $u$, avec la correspondance très commode
$$1\ u = 931{,}5\ \text{MeV}/c^{2}$$

Ainsi, une masse exprimée en $u$ se convertit en énergie en la multipliant simplement par $931{,}5$.

## L''énergie de liaison par nucléon

Pour comparer deux noyaux de tailles différentes, on calcule
$$\dfrac{E_{\ell}}{A}$$

C''est la grandeur qui mesure la **stabilité** du noyau. Plus elle est grande, plus le noyau est solide.

La courbe d''Aston donne $\dfrac{E_{\ell}}{A}$ en fonction de $A$. Elle monte rapidement, passe par un maximum d''environ $8{,}8$ MeV par nucléon autour du fer, pour $A \approx 56$, puis redescend lentement.

Cette courbe explique toute l''énergie nucléaire. Les noyaux les plus stables sont au milieu. Pour gagner de l''énergie, il faut donc **casser** les noyaux lourds, c''est la fission, ou **assembler** les noyaux légers, c''est la fusion. Dans les deux cas on se rapproche du fer.

## Exercice d''application

Calcule l''énergie de liaison par nucléon du noyau d''hélium 4. On donne $m_{p} = 1{,}00728\ u$, $m_{n} = 1{,}00866\ u$ et $m(^{4}_{2}\text{He}) = 4{,}00150\ u$.

Correction. Le noyau d''hélium 4 contient $2$ protons et $2$ neutrons.

La masse des nucléons séparés vaut
$$2 \times 1{,}00728 + 2 \times 1{,}00866 = 2{,}01456 + 2{,}01732 = 4{,}03188\ u$$

Le défaut de masse vaut
$$\Delta m = 4{,}03188 - 4{,}00150 = 0{,}03038\ u$$

L''énergie de liaison vaut
$$E_{\ell} = 0{,}03038 \times 931{,}5 \approx 28{,}3\ \text{MeV}$$

L''énergie de liaison par nucléon vaut donc
$$\dfrac{E_{\ell}}{A} = \dfrac{28{,}3}{4} \approx 7{,}1\ \text{MeV/nucléon}$$

C''est une valeur élevée pour un noyau aussi léger, ce qui fait de l''hélium 4 un noyau remarquablement stable. C''est d''ailleurs pour cela qu''il est émis tel quel lors des désintégrations alpha.', NULL, 15),
      (v_chapitre_id, 'Les désintégrations radioactives', 2, 'texte', 'Certains noyaux sont instables. Tôt ou tard, sans qu''on puisse prévoir quand, ils se transforment spontanément en émettant une particule. C''est la radioactivité.

## Les deux lois de conservation

Toute réaction nucléaire respecte les **lois de Soddy**.

Le nombre de masse total se conserve : la somme des $A$ est la même avant et après.

La charge totale se conserve : la somme des $Z$ est la même avant et après.

Ces deux lois suffisent à écrire n''importe quelle équation de désintégration. Il n''y a rien d''autre à retenir.

## La radioactivité alpha

Un noyau lourd éjecte un noyau d''hélium, appelé particule alpha.
$$^{A}_{Z}\text{X} \longrightarrow\ ^{A-4}_{Z-2}\text{Y}\ +\ ^{4}_{2}\text{He}$$

Elle concerne les noyaux lourds, au-delà de $A = 200$. La particule alpha est lourde et chargée, donc elle est très ionisante mais peu pénétrante : une simple feuille de papier l''arrête.

Exemple, l''uranium 238 donne du thorium 234.

## La radioactivité bêta moins

Un noyau ayant trop de neutrons transforme l''un d''eux en proton, et éjecte un électron.
$$^{A}_{Z}\text{X} \longrightarrow\ ^{A}_{Z+1}\text{Y}\ +\ ^{0}_{-1}\text{e}$$

À l''intérieur du noyau, il s''est produit $n \to p + e^{-} + \bar{\nu}$.

L''électron émis est léger et rapide. Il faut quelques millimètres d''aluminium pour l''arrêter.

Exemple, le carbone 14 donne de l''azote 14.

## La radioactivité bêta plus

Un noyau ayant trop de protons transforme l''un d''eux en neutron, et éjecte un positon, qui est l''antiparticule de l''électron.
$$^{A}_{Z}\text{X} \longrightarrow\ ^{A}_{Z-1}\text{Y}\ +\ ^{0}_{+1}\text{e}$$

Le positon s''annihile presque aussitôt avec un électron du milieu, en produisant deux photons gamma. C''est ce qu''exploite la tomographie par émission de positons, la fameuse TEP des hôpitaux.

## L''émission gamma

Après une désintégration, le noyau fils est souvent dans un état excité, noté $^{A}_{Z}\text{Y}^{*}$. Il se désexcite en émettant un photon très énergétique.
$$^{A}_{Z}\text{Y}^{*} \longrightarrow\ ^{A}_{Z}\text{Y}\ +\ \gamma$$

Ici ni $A$ ni $Z$ ne changent : ce n''est pas une transmutation, seulement une perte d''énergie.

Le rayonnement gamma est le plus pénétrant des trois. Il faut plusieurs centimètres de plomb ou un mur de béton pour l''atténuer sérieusement.

## Les familles radioactives

Un noyau lourd ne devient pas stable d''un coup. Il enchaîne les désintégrations jusqu''à atteindre un noyau stable, en général un isotope du plomb.

L''uranium 238, par exemple, aboutit au plomb 206 après quatorze désintégrations successives. L''ensemble de la chaîne forme une **famille radioactive**.

## Exercice d''application

Le radium 226 se désintègre par émission alpha. Écris l''équation et identifie le noyau fils. Puis écris la désintégration du carbone 14, qui est un émetteur bêta moins. On donne les numéros atomiques : $\text{Rn}$ pour $Z = 86$, $\text{N}$ pour $Z = 7$.

Correction. Pour le radium, $^{226}_{88}\text{Ra}$ émet une particule $^{4}_{2}\text{He}$.

La conservation de $A$ donne $226 = A'' + 4$, donc $A'' = 222$.

La conservation de $Z$ donne $88 = Z'' + 2$, donc $Z'' = 86$.

L''élément de numéro atomique $86$ est le radon, donc
$$^{226}_{88}\text{Ra} \longrightarrow\ ^{222}_{86}\text{Rn}\ +\ ^{4}_{2}\text{He}$$

Pour le carbone 14, $^{14}_{6}\text{C}$ émet un électron $^{0}_{-1}\text{e}$.

La conservation de $A$ donne $14 = A'' + 0$, donc $A'' = 14$.

La conservation de $Z$ donne $6 = Z'' - 1$, donc $Z'' = 7$, c''est l''azote.
$$^{14}_{6}\text{C} \longrightarrow\ ^{14}_{7}\text{N}\ +\ ^{0}_{-1}\text{e}$$', NULL, 15),
      (v_chapitre_id, 'La décroissance radioactive et la datation', 3, 'texte', 'On ne peut pas prévoir quand un noyau donné va se désintégrer. Mais sur un très grand nombre de noyaux, la statistique donne une loi d''une précision remarquable.

## La loi de décroissance

Le nombre de noyaux restants à l''instant $t$ vaut
$$N(t) = N_{0}\,e^{-\lambda t}$$

où $N_{0}$ est le nombre initial et $\lambda$ la **constante radioactive**, en s⁻¹. Elle est propre à chaque nucléide.

Cette loi vient d''une idée simple. Pendant une durée courte, le nombre de désintégrations est proportionnel au nombre de noyaux présents, ce qui s''écrit $\dfrac{dN}{dt} = -\lambda N$.

## La demi-vie

La **demi-vie** $T$, ou période radioactive, est la durée au bout de laquelle la moitié des noyaux se sont désintégrés.

En écrivant $N(T) = \dfrac{N_{0}}{2}$, on obtient
$$T = \dfrac{\ln 2}{\lambda} \approx \dfrac{0{,}693}{\lambda}$$

Au bout de $2T$ il reste le quart, au bout de $3T$ le huitième, et ainsi de suite. De façon générale, après $n$ demi-vies il reste
$$N = \dfrac{N_{0}}{2^{n}}$$

Les demi-vies couvrent une gamme vertigineuse. Le polonium 214 vit $164$ microsecondes, l''iode 131 huit jours, le carbone 14 cinq mille sept cents ans, et l''uranium 238 quatre milliards et demi d''années.

## L''activité

L''**activité** $\mathcal{A}$ est le nombre de désintégrations par seconde :
$$\mathcal{A} = \lambda\,N = \mathcal{A}_{0}\,e^{-\lambda t}$$

Son unité est le becquerel, symbole Bq, qui vaut une désintégration par seconde. L''ancienne unité, le curie, vaut $3{,}7 \times 10^{10}$ Bq.

Le becquerel est une unité minuscule. Le corps humain a une activité naturelle d''environ $8\,000$ Bq, principalement due au potassium 40 des muscles.

L''activité suit exactement la même loi exponentielle que le nombre de noyaux. C''est pratique, car on mesure l''activité au compteur, jamais le nombre de noyaux.

## La datation au carbone 14

Tant qu''un être vivant respire, il échange du carbone avec l''atmosphère, donc sa proportion de carbone 14 reste constante.

À sa mort, les échanges cessent et le carbone 14 ne fait plus que décroître.

En mesurant l''activité d''un échantillon et en la comparant à celle d''un échantillon vivant, on remonte à la date de la mort :
$$t = \dfrac{T}{\ln 2}\,\ln\!\left(\dfrac{\mathcal{A}_{0}}{\mathcal{A}}\right)$$

La méthode est fiable jusqu''à environ $50\,000$ ans. Au-delà, il reste trop peu de carbone 14 pour mesurer quoi que ce soit, et on utilise d''autres couples, comme l''uranium-plomb pour les roches.

## Exercice d''application

Un morceau de charbon de bois trouvé sur un site archéologique au Nord-Cameroun présente une activité de $9{,}5$ Bq par gramme de carbone, alors qu''un échantillon vivant en présente $13{,}6$. La demi-vie du carbone 14 vaut $5\,730$ ans. Quel est l''âge du charbon ?

Correction. La constante radioactive vaut
$$\lambda = \dfrac{\ln 2}{T} = \dfrac{0{,}693}{5730} = 1{,}21 \times 10^{-4}\ \text{an}^{-1}$$

De $\mathcal{A} = \mathcal{A}_{0}e^{-\lambda t}$ on tire
$$t = \dfrac{1}{\lambda}\ln\!\left(\dfrac{\mathcal{A}_{0}}{\mathcal{A}}\right) = \dfrac{1}{1{,}21 \times 10^{-4}}\ln\!\left(\dfrac{13{,}6}{9{,}5}\right)$$

Le rapport vaut $\dfrac{13{,}6}{9{,}5} = 1{,}432$, dont le logarithme népérien vaut $0{,}359$.

Donc
$$t = \dfrac{0{,}359}{1{,}21 \times 10^{-4}} \approx 2\,970\ \text{ans}$$

Le charbon a donc environ trois mille ans. Comme il reste encore plus des deux tiers du carbone 14 initial, on n''a même pas atteint une demi-vie, ce qui est cohérent.', NULL, 15),
      (v_chapitre_id, 'Observe une décroissance radioactive', 4, 'interactif', '{
  "widget": "decroissance-radioactive",
  "consigne": "Choisis un noyau et regarde l''échantillon se vider au fil du temps. Repère la date où il reste la moitié des noyaux, puis le quart : les deux durées sont-elles égales ? Utilise ensuite la courbe pour dater un échantillon dont tu connais l''activité."
}', NULL, 10),
      (v_chapitre_id, 'Fission, fusion et radioprotection', 5, 'texte', 'Les désintégrations spontanées se produisent toutes seules. Mais on peut aussi provoquer des réactions nucléaires en bombardant des noyaux, et c''est là que se trouve l''énergie nucléaire.

## Les transmutations

Une **transmutation** est une réaction provoquée par le bombardement d''un noyau cible par une particule.

La première a été réalisée par Rutherford en 1919 :
$$^{14}_{7}\text{N}\ +\ ^{4}_{2}\text{He} \longrightarrow\ ^{17}_{8}\text{O}\ +\ ^{1}_{1}\text{H}$$

Les lois de Soddy s''appliquent exactement de la même façon.

## La fission nucléaire

La **fission** est la rupture d''un noyau lourd en deux noyaux plus légers, sous l''impact d''un neutron.
$$^{235}_{92}\text{U}\ +\ ^{1}_{0}\text{n} \longrightarrow\ ^{94}_{38}\text{Sr}\ +\ ^{140}_{54}\text{Xe}\ +\ 2\ ^{1}_{0}\text{n}$$

Elle libère environ $200$ MeV par noyau, soit des millions de fois plus qu''une réaction chimique.

Le point décisif, c''est que la fission produit **plusieurs neutrons**. Ceux-ci peuvent provoquer d''autres fissions, qui en produisent d''autres encore. C''est la **réaction en chaîne**.

Si on la laisse s''emballer, c''est la bombe atomique. Si on la contrôle avec des barres absorbantes qui capturent l''excédent de neutrons, c''est le réacteur de centrale nucléaire.

## La fusion nucléaire

La **fusion** est l''assemblage de deux noyaux légers en un noyau plus lourd.
$$^{2}_{1}\text{H}\ +\ ^{3}_{1}\text{H} \longrightarrow\ ^{4}_{2}\text{He}\ +\ ^{1}_{0}\text{n}$$

Elle libère encore plus d''énergie par nucléon que la fission, et ses produits ne sont pas radioactifs à long terme.

Mais elle exige des températures de plusieurs millions de degrés, pour vaincre la répulsion électrique entre les noyaux. C''est pourquoi elle fonctionne dans les étoiles, où la gravité confine la matière, et pas encore dans nos centrales.

C''est la fusion de l''hydrogène en hélium qui fait briller le Soleil depuis cinq milliards d''années.

## Le bilan énergétique

Pour toute réaction nucléaire, l''énergie libérée vaut
$$E = |\Delta m|\,c^{2}$$
où $\Delta m$ est la différence entre la masse totale finale et la masse totale initiale.

Si la masse a diminué, l''énergie est libérée. C''est le cas de la fission et de la fusion, et c''est pourquoi toutes deux rapprochent du fer sur la courbe d''Aston.

## Les effets biologiques et la radioprotection

Les rayonnements ionisants arrachent des électrons aux molécules du corps, ce qui peut casser l''ADN.

Les effets **déterministes** apparaissent au-delà d''une dose seuil, et leur gravité augmente avec la dose : brûlures, chute des cheveux, syndrome d''irradiation aiguë.

Les effets **stochastiques**, essentiellement les cancers, n''ont pas de seuil connu. C''est la **probabilité** de les voir apparaître qui augmente avec la dose.

La dose absorbée se mesure en grays, symbole Gy, et la dose équivalente, qui tient compte de la nocivité propre à chaque rayonnement, en sieverts, symbole Sv.

## Les trois règles de protection

**Le temps.** Réduis la durée d''exposition, puisque la dose y est proportionnelle.

**La distance.** Éloigne-toi, car l''intensité décroît comme le carré de la distance. Doubler la distance divise la dose par quatre.

**L''écran.** Interpose une barrière adaptée. Une feuille de papier suffit pour les alpha, quelques millimètres d''aluminium pour les bêta, plusieurs centimètres de plomb pour les gamma.

La loi d''atténuation dans un écran s''écrit
$$I = I_{0}\,e^{-\mu x}$$
où $\mu$ est le coefficient d''atténuation du matériau.

## Exercice d''application

Calcule l''énergie libérée par la fission d''un noyau d''uranium 235 selon l''équation donnée plus haut, sachant que la perte de masse vaut $\Delta m = 0{,}2152\ u$.

Correction. On utilise directement la correspondance $1\ u = 931{,}5$ MeV.
$$E = 0{,}2152 \times 931{,}5 \approx 200{,}5\ \text{MeV}$$

Convertissons en joules :
$$E = 200{,}5 \times 10^{6} \times 1{,}6 \times 10^{-19} = 3{,}21 \times 10^{-11}\ \text{J}$$

Cela paraît minuscule, mais un seul gramme d''uranium 235 contient environ $2{,}56 \times 10^{21}$ noyaux.

L''énergie totale vaudrait donc $3{,}21 \times 10^{-11} \times 2{,}56 \times 10^{21} \approx 8{,}2 \times 10^{10}$ J, soit environ $82$ gigajoules.

Pour comparaison, il faudrait brûler près de trois tonnes de charbon pour obtenir la même énergie. Voilà pourquoi le nucléaire intéresse tant, malgré ses déchets.', NULL, 15),
      (v_chapitre_id, 'Quiz du chapitre 22', 6, 'quiz', '{
  "titre": "Vérifie que tu as compris",
  "questions": [
    {
      "question": "Un noyau émet une particule alpha. Comment évoluent $A$ et $Z$ ?",
      "choix": [
        "$A$ diminue de 4 et $Z$ de 2",
        "$A$ ne change pas et $Z$ augmente de 1",
        "$A$ diminue de 2 et $Z$ de 4",
        "$A$ et $Z$ ne changent pas"
      ],
      "bonne": 0,
      "explication": "La particule alpha est un noyau d''hélium $^4_2$He. Par conservation, le noyau père perd 4 nucléons et 2 charges, donc $A$ diminue de 4 et $Z$ de 2."
    },
    {
      "question": "Après 3 demi-vies, quelle fraction des noyaux initiaux reste-t-il ?",
      "choix": [
        "Un tiers",
        "Un sixième",
        "Un huitième",
        "Rien"
      ],
      "bonne": 2,
      "explication": "Après chaque demi-vie il reste la moitié. Après trois, il reste $(1/2)^3 = 1/8$ des noyaux. La décroissance est exponentielle, jamais proportionnelle."
    },
    {
      "question": "Pourquoi la fission et la fusion libèrent-elles toutes deux de l''énergie ?",
      "choix": [
        "Parce qu''elles créent de la matière",
        "Parce qu''elles rapprochent du fer, le noyau le plus stable",
        "Parce qu''elles augmentent le nombre de nucléons",
        "Parce qu''elles refroidissent le noyau"
      ],
      "bonne": 1,
      "explication": "La courbe d''Aston a son maximum vers le fer. Casser un noyau lourd ou assembler des noyaux légers augmente dans les deux cas l''énergie de liaison par nucléon, donc libère l''excédent."
    },
    {
      "question": "Quel rayonnement est le plus pénétrant ?",
      "choix": [
        "Alpha",
        "Bêta moins",
        "Gamma",
        "Ils sont équivalents"
      ],
      "bonne": 2,
      "explication": "Le rayonnement gamma est un photon de très haute énergie, sans charge ni masse. Il faut plusieurs centimètres de plomb pour l''atténuer, alors qu''une feuille de papier arrête les alpha."
    },
    {
      "question": "On double la distance à une source radioactive. Que devient la dose reçue ?",
      "choix": [
        "Elle est divisée par 2",
        "Elle est divisée par 4",
        "Elle ne change pas",
        "Elle est divisée par 8"
      ],
      "bonne": 1,
      "explication": "L''intensité du rayonnement décroît comme le carré de la distance. En doublant la distance, on divise la dose par $2^2 = 4$. C''est la règle de protection la plus simple et la plus efficace."
    },
    {
      "question": "Qu''est-ce que le défaut de masse d''un noyau ?",
      "choix": [
        "Une erreur de mesure",
        "L''écart entre la masse du noyau et la somme des masses de ses nucléons séparés",
        "La masse des électrons manquants",
        "La masse perdue lors d''une désintégration"
      ],
      "bonne": 1,
      "explication": "Le noyau est toujours plus léger que ses nucléons pris séparément. Cette masse manquante s''est convertie en énergie de liaison lors de la formation du noyau, selon $E = \\Delta m\\,c^2$."
    }
  ]
}', NULL, 5);

    RAISE NOTICE '% : chapitre 22, La radioactivité — 6 lecons ajoutees.', v_nom;
  END LOOP;
END $ptc$;
