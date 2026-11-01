-- ---------------------------------------------------------------------------
-- M'Andal — Chimie, classes de Première
-- Chapitre 9 : Les composés oxygénés : alcools, aldéhydes et cétones
-- Module 1 : Chimie organique — 11 leçons
--
-- Ce fichier remplit les trois séries d'un coup : la 1ère C, la 1ère D et la
-- 1ère E. Il n'a besoin de rien d'autre pour tourner. Si la matière, les
-- classes, les programmes ou le chapitre n'existent pas encore, il les crée
-- lui-même au passage.
--
-- Lancez-le quand vous voulez, dans l'ordre que vous voulez, et autant de fois
-- que vous voulez : quand le chapitre a déjà ses leçons, le script s'en rend
-- compte et n'ajoute rien.
-- ---------------------------------------------------------------------------
DO $ch1$
DECLARE
  v_lettres text[] := ARRAY['C', 'D', 'E'];
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
  -- La matière Chimie : on ne la crée qu'une fois pour toutes.
  INSERT INTO public.matieres (nom) VALUES ('Chimie') ON CONFLICT (nom) DO NOTHING;
  SELECT id INTO v_matiere_id FROM public.matieres WHERE nom = 'Chimie';

  -- L'établissement, on le retrouve à partir des classes déjà en base.
  SELECT count(DISTINCT etablissement_id) INTO v_nb_etabs FROM public.classes;
  IF v_nb_etabs <> 1 THEN
    RAISE EXCEPTION 'Je ne sais pas à quel établissement rattacher ces classes : j''en trouve % dans la table des classes, et il m''en faudrait exactement un.', v_nb_etabs;
  END IF;
  SELECT etablissement_id INTO v_etab_id FROM public.classes LIMIT 1;

  -- On refait le même travail trois fois : pour la 1ère C, puis la D, puis la E.
  FOR v_i IN 1..3 LOOP
    v_lettre := v_lettres[v_i];
    v_nom := '1ère ' || v_lettre;

    -- Le programme de Chimie de cette série existe-t-il déjà ?
    SELECT p.id INTO v_programme_id FROM public.programmes p
    WHERE p.titre = 'Chimie — ' || v_nom;

    -- Non : on le crée, et la classe avec si besoin.
    IF v_programme_id IS NULL THEN
      -- La classe a pu être écrite de plusieurs façons : 1ère C, 1ere C, Première C.
      SELECT id INTO v_classe_id FROM public.classes
      WHERE etablissement_id = v_etab_id
        AND (nom = v_nom OR nom ILIKE '1%re ' || v_lettre OR nom ILIKE 'Premi%re ' || v_lettre)
      ORDER BY (nom = v_nom) DESC
      LIMIT 1;

      IF v_classe_id IS NULL THEN
        INSERT INTO public.classes (etablissement_id, nom, niveau, filiere)
        VALUES (v_etab_id, v_nom, 'Première', v_lettre)
        RETURNING id INTO v_classe_id;
        RAISE NOTICE 'La classe % n''existait pas : je viens de la créer.', v_nom;
      END IF;

      INSERT INTO public.programmes (matiere_id, classe_id, etablissement_id, titre, description)
      VALUES (v_matiere_id, v_classe_id, v_etab_id, 'Chimie — ' || v_nom,
              'Programme officiel de Chimie, classe de Première ' || v_lettre ||
              ' (Cameroun) — 3 modules, 19 chapitres.')
      RETURNING id INTO v_programme_id;
      RAISE NOTICE 'Programme de Chimie de la % : créé.', v_nom;
    END IF;

    -- Le chapitre lui-même.
    SELECT id INTO v_chapitre_id FROM public.chapitres
    WHERE programme_id = v_programme_id AND ordre = 9;

    IF v_chapitre_id IS NULL THEN
      INSERT INTO public.chapitres (programme_id, titre, ordre, niveau)
      VALUES (v_programme_id, 'Les composés oxygénés : alcools, aldéhydes et cétones', 9, 'Module 1 : Chimie organique')
      RETURNING id INTO v_chapitre_id;
      RAISE NOTICE '% : chapitre 9 créé.', v_nom;
    END IF;

    -- Les leçons. Si le chapitre en a déjà, on passe son tour sans rien toucher.
    SELECT count(*) INTO v_deja FROM public.concepts WHERE chapitre_id = v_chapitre_id;
    IF v_deja > 0 THEN
      RAISE NOTICE '% : le chapitre 9 a déjà ses % leçons, je n''y touche pas.', v_nom, v_deja;
      CONTINUE;
    END IF;

    INSERT INTO public.concepts
      (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes) VALUES
      (v_chapitre_id, 'Les alcools et leurs trois classes', 1, 'texte', '
Nous avons fini les hydrocarbures. Nous abordons maintenant les composés
**oxygénés** : des molécules qui contiennent, en plus du carbone et de
l''hydrogène, un ou plusieurs atomes d''oxygène. Trois familles vous suffiront
cette année : les alcools, les aldéhydes et les cétones.

### Définition

Un **alcool** est un composé dans lequel un groupe **hydroxyle** $-OH$ est fixé
sur un carbone **tétragonal**, c''est-à-dire un carbone qui ne porte que des
liaisons simples.

$$R-OH$$

La précision « carbone tétragonal » exclut le phénol, où le $-OH$ est accroché
au noyau benzénique : le phénol n''est pas un alcool.

### La nomenclature

On prend le nom de l''alcane correspondant et on remplace le **-e** final par
**-ol**, en indiquant la position du groupe $-OH$ par le plus petit indice
possible.

$$CH_3-OH \quad \text{méthanol}$$
$$CH_3-CH_2-OH \quad \text{éthanol}$$
$$CH_3-CH(OH)-CH_3 \quad \text{propan-2-ol}$$

### Les trois classes

C''est le point essentiel du chapitre, et tout en découle. On classe les alcools
selon le **nombre de carbones voisins** du carbone qui porte le $-OH$. On
appelle ce carbone le **carbone fonctionnel**.

| Classe | Voisins carbonés | Hydrogènes sur le carbone fonctionnel | Exemple |
| --- | --- | --- | --- |
| primaire | 0 ou 1 | 2 | $CH_3-CH_2-OH$, éthanol |
| secondaire | 2 | 1 | $CH_3-CH(OH)-CH_3$, propan-2-ol |
| tertiaire | 3 | 0 | $(CH_3)_3C-OH$, 2-méthylpropan-2-ol |

**La méthode, en deux gestes.** Repère le carbone qui porte le $-OH$. Compte
ses voisins carbonés. C''est tout.

Si tu préfères, compte plutôt les hydrogènes restants sur ce carbone : deux pour
un primaire, un pour un secondaire, aucun pour un tertiaire. Les deux comptes se
déduisent l''un de l''autre, puisque le carbone a toujours quatre liaisons.

---

**Exercice corrigé**

*Donne la classe des trois alcools de formule $C_4H_{10}O$ à chaîne linéaire ou
ramifiée que tu connais.*

**Correction.**
$CH_3-CH_2-CH_2-CH_2-OH$, le butan-1-ol : le carbone fonctionnel a **un** voisin
carboné, c''est un alcool **primaire**.
$CH_3-CH_2-CH(OH)-CH_3$, le butan-2-ol : **deux** voisins, alcool
**secondaire**.
$(CH_3)_3C-OH$, le 2-méthylpropan-2-ol : **trois** voisins, alcool
**tertiaire**.
', NULL, 25),
      (v_chapitre_id, 'Simulation : trouver la classe d''un alcool', 2, 'interactif', '{
  "widget": "classe-alcool",
  "consigne": "Construis l''alcool que tu veux et déplace le groupe hydroxyle d''un carbone à l''autre. La simulation surligne le carbone fonctionnel, compte ses voisins carbonés et annonce la classe. Essaie de fabriquer un alcool tertiaire : tu découvriras qu''il faut au moins quatre carbones, et tu comprendras pourquoi."
}', NULL, 10),
      (v_chapitre_id, 'Propriétés physiques des composés oxygénés', 3, 'texte', '
Un détail d''apparence anodine explique presque tout ce chapitre : l''atome
d''oxygène attire fortement les électrons. Il rend la molécule **polaire**, et
une molécule polaire ne se comporte pas comme un hydrocarbure.

### Les alcools bouillent étonnamment haut

Compare deux molécules de masse molaire voisine :

| Composé | Formule | M (g/mol) | Température d''ébullition |
| --- | --- | --- | --- |
| éthane | $C_2H_6$ | 30 | $-89$ °C |
| éthanol | $C_2H_6O$ | 46 | $+78$ °C |

Plus de 160 degrés d''écart. Pourquoi ?

Parce que le groupe $-OH$ d''un alcool peut s''accrocher au groupe $-OH$ de la
molécule voisine. Cette attache s''appelle une **liaison hydrogène**. Les
molécules d''alcool se tiennent donc par la main, et il faut beaucoup plus
d''énergie pour les séparer les unes des autres.

### La solubilité dans l''eau

Pour la même raison, les premiers alcools se mélangent à l''eau **en toutes
proportions** : le méthanol, l''éthanol et le propan-1-ol sont totalement
miscibles à l''eau.

Mais la solubilité **diminue quand la chaîne s''allonge** : le butan-1-ol est
déjà peu soluble, et au-delà de six carbones la partie hydrocarbonée l''emporte
et l''alcool ne se dissout plus.

Retiens la règle : **la tête $-OH$ aime l''eau, la queue carbonée la fuit**. Le
plus long des deux l''emporte.

### Les aldéhydes et les cétones : entre les deux

| Composé | Formule | M (g/mol) | Température d''ébullition |
| --- | --- | --- | --- |
| propane | $C_3H_8$ | 44 | $-42$ °C |
| propanone | $C_3H_6O$ | 58 | $+56$ °C |
| propan-1-ol | $C_3H_8O$ | 60 | $+97$ °C |

Les aldéhydes et les cétones bouillent **plus haut que les alcanes** — le
groupe $C=O$ est polaire — mais **moins haut que les alcools**. La raison est
nette : ils n''ont pas d''hydrogène sur l''oxygène, donc ils ne peuvent pas
s''accrocher entre eux. En revanche ils peuvent s''accrocher à l''eau, ce qui
explique que la propanone, l''acétone des vernis à ongles, soit miscible à l''eau.

### Les odeurs

Ce sont des composés très odorants, et plusieurs d''entre eux servent
d''arômes : le benzaldéhyde sent l''amande amère, la vanilline la vanille.
L''acétone a l''odeur piquante du dissolvant.

---

**Exercice corrigé**

*Range par température d''ébullition croissante : le butane ($C_4H_{10}$), le
butan-1-ol ($C_4H_{10}O$) et la butanone ($C_4H_8O$). Justifie.*

**Correction.**
Le **butane** est un alcane : aucune polarité, aucune liaison hydrogène, il
bout le plus bas ($-0{,}5$ °C).
La **butanone** porte un groupe $C=O$ polaire mais ne peut pas former de
liaison hydrogène avec ses voisines : elle bout au milieu ($+80$ °C).
Le **butan-1-ol** porte un groupe $-OH$ : les molécules se lient entre elles
par liaison hydrogène, il bout le plus haut ($+118$ °C).

Ordre croissant : **butane < butanone < butan-1-ol**.
', NULL, 22),
      (v_chapitre_id, 'Simulation : pourquoi les alcools bouillent-ils si haut ?', 4, 'interactif', '{
  "widget": "proprietes-oxygenes",
  "consigne": "Mets côte à côte un alcane, un aldéhyde, une cétone et un alcool de même longueur de chaîne, et chauffe-les ensemble : tu verras l''ordre dans lequel ils se mettent à bouillir. La simulation dessine les liaisons hydrogène qui apparaissent entre les molécules d''alcool — ce sont elles qui expliquent l''écart. Allonge ensuite la chaîne et regarde la solubilité dans l''eau s''effondrer."
}', NULL, 10),
      (v_chapitre_id, 'L''oxydation ménagée', 5, 'texte', '
Oxyder « ménagé », cela veut dire oxyder **sans casser la chaîne carbonée** —
par opposition à la combustion, qui réduit tout en $CO_2$ et en eau. On utilise
un oxydant doux, le plus souvent une solution de permanganate de potassium ou
de dichromate de potassium en milieu acide.

Le résultat **dépend entièrement de la classe** de l''alcool. C''est pour cela
que la leçon précédente était importante.

### Alcool primaire : deux étapes

$$R-CH_2-OH \;\longrightarrow\; R-CHO \;\longrightarrow\; R-COOH$$

D''abord un **aldéhyde**, puis, si l''oxydant est en excès, un **acide
carboxylique**.

Pour l''éthanol :
$$CH_3-CH_2-OH \longrightarrow CH_3-CHO \longrightarrow CH_3-COOH$$
soit : éthanol, puis éthanal, puis acide éthanoïque — le vinaigre. C''est
exactement ce qui arrive à un vin qu''on laisse ouvert.

Si l''on veut s''arrêter à l''aldéhyde, il faut mettre l''alcool **en excès** et
distiller l''aldéhyde au fur et à mesure qu''il se forme.

### Alcool secondaire : une seule étape

$$R-CH(OH)-R'' \;\longrightarrow\; R-CO-R''$$

On obtient une **cétone**, et la réaction s''arrête là.

Pour le propan-2-ol :
$$CH_3-CH(OH)-CH_3 \longrightarrow CH_3-CO-CH_3$$
soit la propanone, plus connue sous le nom d''**acétone**.

### Alcool tertiaire : rien

$$R_3C-OH \;\longrightarrow\; \text{pas de réaction}$$

Et la raison est limpide : l''oxydation ménagée consiste à arracher un hydrogène
porté par le carbone fonctionnel. Un alcool tertiaire n''en a aucun. Il ne peut
donc pas être oxydé sans rompre la chaîne.

### Ce que cela te permet de faire

Tu disposes maintenant d''une méthode expérimentale pour **déterminer la classe
d''un alcool inconnu** : tu l''oxydes, et tu identifies le produit. Aldéhyde,
c''était un primaire. Cétone, un secondaire. Rien, un tertiaire.

---

**Exercice corrigé**

*L''oxydation ménagée d''un alcool A de formule $C_3H_8O$ donne un produit B qui
rosit le réactif de Schiff. Identifie A et B.*

**Correction.** Rosir le réactif de Schiff est le test de l''aldéhyde, donc B est
un aldéhyde, donc A est un alcool **primaire**.
Des deux alcools de formule $C_3H_8O$, seul le propan-1-ol est primaire :
$$A = CH_3-CH_2-CH_2-OH$$
$$B = CH_3-CH_2-CHO \quad \text{le propanal}$$
', NULL, 25),
      (v_chapitre_id, 'Simulation : oxyder un alcool', 6, 'interactif', '{
  "widget": "oxydation-alcool",
  "consigne": "Verse l''oxydant goutte à goutte sur l''alcool de ton choix et regarde le produit se former. Avec un primaire, arrête-toi à temps pour garder l''aldéhyde, ou continue jusqu''à l''acide. Avec un secondaire, la réaction s''arrête d''elle-même sur la cétone. Avec un tertiaire, il ne se passe rien, et la simulation te montre pourquoi : il n''y a aucun hydrogène à arracher sur le carbone fonctionnel."
}', NULL, 10),
      (v_chapitre_id, 'Aldéhydes et cétones : les reconnaître', 7, 'texte', '
Les deux familles possèdent le même groupe **carbonyle** $C=O$. Ce qui les
distingue, c''est sa **position** sur la chaîne.

### Les aldéhydes

Le carbonyle est en **bout de chaîne** : le carbone fonctionnel porte un
hydrogène. On écrit le groupe $-CHO$.

$$R-CHO$$

Nomenclature : on remplace le **-e** de l''alcane par **-al**. Le carbone du
$-CHO$ porte toujours le numéro 1.

$$HCHO \text{ méthanal} \qquad CH_3-CHO \text{ éthanal} \qquad CH_3-CH_2-CHO \text{ propanal}$$

### Les cétones

Le carbonyle est **en milieu de chaîne** : le carbone fonctionnel porte deux
carbones.

$$R-CO-R''$$

Nomenclature : on remplace le **-e** par **-one**, avec l''indice de position.

$$CH_3-CO-CH_3 \text{ propanone} \qquad CH_3-CO-CH_2-CH_3 \text{ butan-2-one}$$

La plus petite cétone possible a **trois** carbones : il en faut un de chaque
côté du carbonyle.

### Les quatre tests à connaître

**La 2,4-DNPH** (2,4-dinitrophénylhydrazine) donne un **précipité jaune** avec
les aldéhydes **et** les cétones. Elle révèle donc la présence du groupe
carbonyle, mais elle ne permet pas de trancher entre les deux.

**Le réactif de Schiff** **rosit** avec les aldéhydes seulement.

**La liqueur de Fehling**, bleue, donne un **précipité rouge brique** avec les
aldéhydes seulement, à chaud.

**Le réactif de Tollens** donne un **dépôt d''argent** — le « miroir d''argent » —
avec les aldéhydes seulement.

**La logique du diagnostic.** Les trois derniers tests fonctionnent parce que
l''aldéhyde est **réducteur** et la cétone ne l''est pas : l''aldéhyde peut encore
s''oxyder en acide, la cétone ne le peut pas.

La méthode est donc toujours la même : la 2,4-DNPH d''abord, pour savoir s''il y a
un carbonyle. Puis Schiff, Fehling ou Tollens, pour savoir lequel des deux.

---

**Exercice corrigé**

*Un composé organique X de formule $C_3H_6O$ donne un précipité jaune avec la
2,4-DNPH, mais ne rosit pas le réactif de Schiff. Identifie X, puis l''alcool
dont il provient par oxydation ménagée.*

**Correction.** Précipité jaune : X contient un groupe carbonyle. Pas de
coloration rose : ce n''est pas un aldéhyde. X est donc une **cétone**.
Avec trois carbones, une seule cétone est possible :
$$X = CH_3-CO-CH_3 \quad \text{la propanone}$$
Une cétone provient de l''oxydation d''un alcool **secondaire** :
$$CH_3-CH(OH)-CH_3 \quad \text{le propan-2-ol}$$
', NULL, 25),
      (v_chapitre_id, 'Figure : l''arbre des tests d''identification', 8, 'figure', '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 540 320" width="540" height="320">
<rect width="540" height="320" fill="#ffffff"/>
<text x="270" y="22" text-anchor="middle" font-size="14" font-weight="700" fill="#0f172a">Identifier un composé oxygéné : l&apos;arbre des tests</text>

<rect x="190" y="38" width="160" height="34" fill="#1e293b" rx="6"/>
<text x="270" y="60" text-anchor="middle" font-size="12" font-weight="700" fill="#ffffff">composé inconnu</text>

<text x="270" y="92" text-anchor="middle" font-size="11" font-weight="700" fill="#334155">2,4-DNPH : précipité jaune ?</text>

<line x1="200" y1="100" x2="110" y2="128" stroke="#64748b" stroke-width="1.6"/>
<line x1="340" y1="100" x2="430" y2="128" stroke="#64748b" stroke-width="1.6"/>
<text x="138" y="118" font-size="10" font-weight="700" fill="#dc2626">NON</text>
<text x="382" y="118" font-size="10" font-weight="700" fill="#16a34a">OUI</text>

<rect x="30" y="130" width="160" height="34" fill="#fee2e2" stroke="#dc2626" stroke-width="1.4" rx="6"/>
<text x="110" y="152" text-anchor="middle" font-size="11" font-weight="700" fill="#991b1b">pas de C=O</text>
<text x="110" y="180" text-anchor="middle" font-size="10" fill="#334155">c&apos;est un ALCOOL</text>
<text x="110" y="196" text-anchor="middle" font-size="10" fill="#64748b">groupe &#8211;OH</text>

<rect x="350" y="130" width="160" height="34" fill="#dcfce7" stroke="#16a34a" stroke-width="1.4" rx="6"/>
<text x="430" y="152" text-anchor="middle" font-size="11" font-weight="700" fill="#14532d">il y a un C=O</text>

<text x="430" y="186" text-anchor="middle" font-size="11" font-weight="700" fill="#334155">réactif de Schiff : rosit ?</text>

<line x1="380" y1="194" x2="300" y2="222" stroke="#64748b" stroke-width="1.6"/>
<line x1="480" y1="194" x2="500" y2="222" stroke="#64748b" stroke-width="1.6"/>
<text x="322" y="212" font-size="10" font-weight="700" fill="#dc2626">NON</text>
<text x="486" y="212" font-size="10" font-weight="700" fill="#16a34a">OUI</text>

<rect x="226" y="226" width="150" height="34" fill="#f1f5f9" stroke="#64748b" stroke-width="1.4" rx="6"/>
<text x="301" y="248" text-anchor="middle" font-size="12" font-weight="700" fill="#0f172a">CÉTONE</text>
<text x="301" y="276" text-anchor="middle" font-size="10" fill="#64748b">groupe C=O en milieu</text>
<text x="301" y="292" text-anchor="middle" font-size="10" fill="#64748b">de chaîne &#8212; nom en &#8211;one</text>

<rect x="400" y="226" width="118" height="34" fill="#dbeafe" stroke="#2563eb" stroke-width="1.4" rx="6"/>
<text x="459" y="248" text-anchor="middle" font-size="12" font-weight="700" fill="#1e3a8a">ALDÉHYDE</text>
<text x="459" y="276" text-anchor="middle" font-size="10" fill="#64748b">groupe &#8211;CHO en</text>
<text x="459" y="292" text-anchor="middle" font-size="10" fill="#64748b">bout de chaîne &#8212; &#8211;al</text>

<text x="110" y="226" text-anchor="middle" font-size="10" fill="#64748b">oxydation ménagée pour</text>
<text x="110" y="242" text-anchor="middle" font-size="10" fill="#64748b">trouver sa classe :</text>
<text x="110" y="262" text-anchor="middle" font-size="10" fill="#334155">aldéhyde &#8594; primaire</text>
<text x="110" y="278" text-anchor="middle" font-size="10" fill="#334155">cétone &#8594; secondaire</text>
<text x="110" y="294" text-anchor="middle" font-size="10" fill="#334155">rien &#8594; tertiaire</text>
</svg>', NULL, 5),
      (v_chapitre_id, 'Simulation : le laboratoire d''identification', 9, 'interactif', '{
  "widget": "test-aldehyde-cetone",
  "consigne": "Un flacon te présente un composé inconnu. Choisis tes tests dans l''ordre que tu veux — 2,4-DNPH, réactif de Schiff, liqueur de Fehling, réactif de Tollens — et observe les couleurs et les précipités. Quand tu crois savoir, annonce ta réponse : la simulation te dit si tu as raison et, surtout, si tu aurais pu conclure avec moins de tests."
}', NULL, 10),
      (v_chapitre_id, 'Sujet type Probatoire corrigé — les composés oxygénés', 10, 'texte', '
Voici un sujet complet dans l''esprit des épreuves de Probatoire C et D. Prends
une feuille et cherche-le **entièrement** avant de lire la correction. C''est
seulement à ce prix qu''il te servira à quelque chose.

---

### Énoncé

Un composé organique X ne contient que du carbone, de l''hydrogène et de
l''oxygène. Sa composition centésimale massique est : 60,0 % de carbone et
13,3 % d''hydrogène. On vaporise 1,0 g de ce composé : la vapeur obtenue occupe
un volume de 373,5 cm³ dans les conditions normales de température et de
pression.

**1.** Calculer la masse molaire de X.
**2.** Déterminer le nombre d''atomes de carbone et d''hydrogène dans une
molécule de X.
**3.** Trouver le troisième élément constitutif de X, puis sa formule brute.
**4.** X ne donne aucun précipité avec la 2,4-DNPH. Son oxydation ménagée
conduit à un composé Y qui, lui, donne un précipité jaune avec la 2,4-DNPH mais
ne rosit pas le réactif de Schiff. Identifier X et Y, et les nommer.
**5.** Donner la classe de X et écrire l''équation de son oxydation ménagée.

*On donne : $M(H)=1$, $M(C)=12$, $M(O)=16$ g/mol ; volume molaire
$V_0 = 22{,}4$ L/mol.*

---

### Correction

**1. Masse molaire.**
$$\frac{m}{M} = \frac{V}{V_0} \;\Longrightarrow\; M = \frac{m\,V_0}{V}$$
$$M = \frac{1{,}0 \times 22\,400}{373{,}5} = 60 \text{ g/mol}$$

**2. Carbone et hydrogène.**
$$\%C = \frac{12x}{M} \times 100 \;\Longrightarrow\; x = \frac{60{,}0 \times 60}{12 \times 100} = 3$$
$$\%H = \frac{y}{M} \times 100 \;\Longrightarrow\; y = \frac{13{,}3 \times 60}{100} = 8$$
Trois atomes de carbone, huit atomes d''hydrogène.

**3. Le troisième élément.**
$$\%T = 100 - (60{,}0 + 13{,}3) = 26{,}7\,\%$$
$$M_T = \frac{26{,}7 \times 60}{100} = 16 \text{ g/mol}$$
C''est l''**oxygène**, et il y en a un seul atome. La formule brute est
$$X = C_3H_8O$$

**4. Identification de X et de Y.**
X ne précipite pas avec la 2,4-DNPH : il ne porte donc **pas** de groupe
carbonyle. Avec un seul oxygène et une chaîne saturée, c''est un **alcool**.
Deux alcools répondent à la formule $C_3H_8O$ :
$$CH_3-CH_2-CH_2-OH \quad \text{propan-1-ol, primaire}$$
$$CH_3-CH(OH)-CH_3 \quad \text{propan-2-ol, secondaire}$$
Les deux tests sur Y départagent. Précipité jaune avec la 2,4-DNPH : Y porte un
carbonyle. Pas de coloration rose avec le réactif de Schiff : ce n''est pas un
aldéhyde. Donc **Y est une cétone**, et une cétone ne peut provenir que d''un
alcool **secondaire**.
$$X = CH_3-CH(OH)-CH_3 \quad \text{le propan-2-ol}$$
$$Y = CH_3-CO-CH_3 \quad \text{la propanone}$$

**5. Classe et équation.**
X est un alcool **secondaire** : le carbone qui porte le $-OH$ a deux voisins
carbonés.
$$CH_3-CH(OH)-CH_3 + \tfrac{1}{2}\,O_2 \longrightarrow CH_3-CO-CH_3 + H_2O$$

---

**Ce que ce sujet t''apprend sur la méthode.** Les trois premières questions sont
purement calculatoires : elles ne demandent aucune connaissance de cours, juste
de la rigueur. Les deux dernières ne demandent aucun calcul : elles testent si
tu sais lire un test chimique. Un sujet de Probatoire est presque toujours bâti
ainsi. Si les calculs te bloquent, saute-les et traite la fin : les points y
sont tout aussi nombreux.
', NULL, 35),
      (v_chapitre_id, 'Quiz du chapitre 9', 11, 'quiz', '{
  "titre": "Vérifie que tu as compris",
  "questions": [
    {
      "question": "Comment détermine-t-on la classe d''un alcool ?",
      "choix": [
        "En comptant tous les carbones de la molécule",
        "En comptant les voisins carbonés du carbone qui porte le $-OH$",
        "En mesurant sa masse molaire",
        "En regardant sa couleur"
      ],
      "bonne": 1,
      "explication": "Zéro ou un voisin : primaire. Deux voisins : secondaire. Trois voisins : tertiaire."
    },
    {
      "question": "L''oxydation ménagée d''un alcool secondaire donne :",
      "choix": [
        "un aldéhyde",
        "une cétone",
        "un acide carboxylique",
        "rien"
      ],
      "bonne": 1,
      "explication": "Et la réaction s''arrête là. Seul un alcool primaire peut aller jusqu''à l''acide, en passant par l''aldéhyde."
    },
    {
      "question": "Pourquoi un alcool tertiaire ne subit-il pas d''oxydation ménagée ?",
      "choix": [
        "Parce qu''il est trop lourd",
        "Parce que son carbone fonctionnel ne porte aucun hydrogène",
        "Parce qu''il est insoluble",
        "Parce qu''il est trop réactif"
      ],
      "bonne": 1,
      "explication": "L''oxydation ménagée arrache un hydrogène du carbone fonctionnel. Sans hydrogène, pas de réaction possible sans casser la chaîne."
    },
    {
      "question": "Quel test révèle la présence d''un groupe carbonyle, aldéhyde ou cétone indifféremment ?",
      "choix": [
        "Le réactif de Schiff",
        "La 2,4-DNPH",
        "La liqueur de Fehling",
        "Le réactif de Tollens"
      ],
      "bonne": 1,
      "explication": "La 2,4-DNPH donne un précipité jaune avec les deux familles. C''est pourquoi on la fait en premier, puis on tranche avec un autre test."
    },
    {
      "question": "Un composé rosit le réactif de Schiff. C''est :",
      "choix": [
        "un alcool",
        "un aldéhyde",
        "une cétone",
        "un alcane"
      ],
      "bonne": 1,
      "explication": "Schiff, Fehling et Tollens ne répondent qu''aux aldéhydes, parce que seul l''aldéhyde est réducteur : il peut encore s''oxyder en acide."
    },
    {
      "question": "Combien de carbones au minimum une cétone doit-elle contenir ?",
      "choix": [
        "1",
        "2",
        "3",
        "4"
      ],
      "bonne": 2,
      "explication": "Le carbonyle doit être en milieu de chaîne : il lui faut un carbone de chaque côté, plus le sien."
    },
    {
      "question": "L''oxydation complète de l''éthanol en excès d''oxydant donne :",
      "choix": [
        "de l''éthanal seulement",
        "de l''acide éthanoïque",
        "de la propanone",
        "du méthanol"
      ],
      "bonne": 1,
      "explication": "L''éthanol est un alcool primaire : il passe par l''éthanal puis, si l''oxydant reste en excès, devient l''acide éthanoïque — le vinaigre."
    }
  ]
}', NULL, 5);

    RAISE NOTICE '% : 11 leçons ajoutées au chapitre 9, Les composés oxygénés : alcools, aldéhydes et cétones.', v_nom;
  END LOOP;
END $ch1$;
