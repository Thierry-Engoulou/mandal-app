-- ---------------------------------------------------------------------------
-- M'Andal — Chimie, classes de Première
-- Chapitre 10 : Les composés aromatiques : le benzène
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
    WHERE programme_id = v_programme_id AND ordre = 10;

    IF v_chapitre_id IS NULL THEN
      INSERT INTO public.chapitres (programme_id, titre, ordre, niveau)
      VALUES (v_programme_id, 'Les composés aromatiques : le benzène', 10, 'Module 1 : Chimie organique')
      RETURNING id INTO v_chapitre_id;
      RAISE NOTICE '% : chapitre 10 créé.', v_nom;
    END IF;

    -- Les leçons. Si le chapitre en a déjà, on passe son tour sans rien toucher.
    SELECT count(*) INTO v_deja FROM public.concepts WHERE chapitre_id = v_chapitre_id;
    IF v_deja > 0 THEN
      RAISE NOTICE '% : le chapitre 10 a déjà ses % leçons, je n''y touche pas.', v_nom, v_deja;
      CONTINUE;
    END IF;

    INSERT INTO public.concepts
      (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes) VALUES
      (v_chapitre_id, 'Le benzène : une structure à part', 1, 'texte', '
Nous quittons les chaînes ouvertes. Les **composés aromatiques** sont les
composés qui comportent au moins un **noyau benzénique**, et le plus connu de
tous est le benzène lui-même.

### La formule et la forme

Formule brute : $C_6H_6$. Six carbones, six hydrogènes.

La molécule est **plane** et **cyclique**. Ses six atomes de carbone occupent
les sommets d''un **hexagone régulier**.

$$d(C-C) = 140 \text{ pm} \qquad d(C-H) = 110 \text{ pm}$$

Tous les angles valenciels valent **120°**.

### Le fait troublant

Regarde bien cette longueur de 140 pm. Tu connais déjà les deux autres :

$$\underbrace{154}_{C-C \text{ simple}} \quad > \quad \underbrace{140}_{\text{benzène}} \quad > \quad \underbrace{134}_{C=C \text{ double}}$$

La liaison du benzène n''est **ni une simple, ni une double** : elle est entre
les deux. Et les six liaisons du cycle sont **toutes identiques**.

### Kekulé, et pourquoi sa représentation ne suffit pas

Au XIXᵉ siècle, le chimiste allemand August Kekulé propose un cycle avec trois
liaisons doubles et trois liaisons simples **alternées**. C''est ingénieux, et
cela explique une bonne partie des propriétés du benzène.

Mais cette représentation a des insuffisances, et l''expérience les révèle.
Prenons l''orthodichlorobenzène, dans lequel deux chlores occupent deux carbones
voisins. Avec le modèle de Kekulé, ces deux carbones sont reliés soit par une
simple, soit par une double : il devrait donc exister **deux**
orthodichlorobenzènes différents. Or l''expérience n''en trouve qu''**un seul**.

### La réponse : les électrons délocalisés

Chaque atome de carbone du benzène possède **un électron libre**, qui n''est
engagé dans aucune liaison. Les six carbones mettent ces six électrons **en
commun**. Ils forment un nuage électronique qui couvre tout le cycle.

On dit que les six électrons sont **délocalisés** : ils n''appartiennent à aucune
liaison en particulier, ils appartiennent au cycle entier.

C''est ce nuage qu''on représente par un **cercle** à l''intérieur de l''hexagone.
Ce cercle s''appelle le **noyau benzénique**.

Et du coup, plus de paradoxe : les six liaisons sont rigoureusement
équivalentes, donc il n''existe bien qu''un seul orthodichlorobenzène.

---

**Exercice corrigé**

*Vrai ou faux, en justifiant : « l''origine du terme aromatique donné au benzène
est son odeur forte d''arôme. »*

**Correction.** **Vrai** pour l''origine historique du mot : les premiers
composés de cette famille furent isolés de substances odorantes, baumes et
résines, et le nom leur est resté. Mais attention, le mot a changé de sens : en
chimie moderne, « aromatique » ne désigne plus une odeur, il désigne la
présence du noyau benzénique et la stabilité particulière qu''il confère.
', NULL, 25),
      (v_chapitre_id, 'Figure : Kekulé et le noyau benzénique', 2, 'figure', '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 540 280" width="540" height="280">
<rect width="540" height="280" fill="#ffffff"/>
<text x="270" y="22" text-anchor="middle" font-size="14" font-weight="700" fill="#0f172a">Le benzène C&#8326;H&#8326; : de Kekulé au nuage délocalisé</text>

<g>
  <line x1="130.0" y1="82.0" x2="169.8" y2="105.0" stroke="#0f172a" stroke-width="2.2"/>
  <line x1="130.0" y1="90.3" x2="162.7" y2="109.1" stroke="#0f172a" stroke-width="2.2"/>
  <line x1="169.8" y1="105.0" x2="169.8" y2="151.0" stroke="#0f172a" stroke-width="2.2"/>
  <line x1="169.8" y1="151.0" x2="130.0" y2="174.0" stroke="#0f172a" stroke-width="2.2"/>
  <line x1="162.7" y1="146.9" x2="130.0" y2="165.7" stroke="#0f172a" stroke-width="2.2"/>
  <line x1="130.0" y1="174.0" x2="90.2" y2="151.0" stroke="#0f172a" stroke-width="2.2"/>
  <line x1="90.2" y1="151.0" x2="90.2" y2="105.0" stroke="#0f172a" stroke-width="2.2"/>
  <line x1="97.3" y1="146.9" x2="97.3" y2="109.1" stroke="#0f172a" stroke-width="2.2"/>
  <line x1="90.2" y1="105.0" x2="130.0" y2="82.0" stroke="#0f172a" stroke-width="2.2"/>
  <text x="130" y="190" text-anchor="middle" font-size="12" font-weight="700" fill="#dc2626">représentation de Kekulé</text>
  <text x="130" y="208" text-anchor="middle" font-size="10" fill="#64748b">3 doubles et 3 simples alternées</text>
  <text x="130" y="226" text-anchor="middle" font-size="10" fill="#dc2626">elle prévoit 2 orthodichlorobenzènes</text>
  <text x="130" y="242" text-anchor="middle" font-size="10" fill="#dc2626">or l&apos;expérience n&apos;en trouve qu&apos;UN</text>
</g>

<text x="270" y="134" text-anchor="middle" font-size="26" fill="#64748b">&#8594;</text>

<g>
  <line x1="410.0" y1="82.0" x2="449.8" y2="105.0" stroke="#0f172a" stroke-width="2.2"/>
  <line x1="449.8" y1="105.0" x2="449.8" y2="151.0" stroke="#0f172a" stroke-width="2.2"/>
  <line x1="449.8" y1="151.0" x2="410.0" y2="174.0" stroke="#0f172a" stroke-width="2.2"/>
  <line x1="410.0" y1="174.0" x2="370.2" y2="151.0" stroke="#0f172a" stroke-width="2.2"/>
  <line x1="370.2" y1="151.0" x2="370.2" y2="105.0" stroke="#0f172a" stroke-width="2.2"/>
  <line x1="370.2" y1="105.0" x2="410.0" y2="82.0" stroke="#0f172a" stroke-width="2.2"/>
  <circle cx="410" cy="128" r="27" fill="none" stroke="#2563eb" stroke-width="2.6"/>
  <text x="410" y="190" text-anchor="middle" font-size="12" font-weight="700" fill="#2563eb">représentation actuelle</text>
  <text x="410" y="208" text-anchor="middle" font-size="10" fill="#64748b">les 6 électrons sont délocalisés</text>
  <text x="410" y="226" text-anchor="middle" font-size="10" fill="#2563eb">les 6 liaisons sont identiques</text>
  <text x="410" y="242" text-anchor="middle" font-size="10" fill="#2563eb">le cercle = le noyau benzénique</text>
</g>

<g transform="translate(228,56)">
  <text x="0" y="0" font-size="10" fill="#334155">C&#8211;C : 154 pm</text>
  <text x="0" y="16" font-size="10" font-weight="700" fill="#2563eb">benzène : 140 pm</text>
  <text x="0" y="32" font-size="10" fill="#334155">C=C : 134 pm</text>
  <text x="0" y="52" font-size="10" fill="#64748b">ni simple, ni double :</text>
  <text x="0" y="66" font-size="10" fill="#64748b">entre les deux</text>
</g>
</svg>', NULL, 5),
      (v_chapitre_id, 'Simulation : le nuage délocalisé', 3, 'interactif', '{
  "widget": "benzene-structure",
  "consigne": "Bascule entre la représentation de Kekulé et la représentation actuelle, et mesure les six liaisons du cycle dans chaque cas. Place ensuite deux chlores sur deux carbones voisins : avec Kekulé la simulation te construit deux composés différents, avec le nuage délocalisé elle n''en construit qu''un. Tu vois de tes yeux l''expérience qui a départagé les deux modèles."
}', NULL, 10),
      (v_chapitre_id, 'Quelques composés aromatiques', 4, 'texte', '
On obtient la plupart d''entre eux en remplaçant un ou plusieurs hydrogènes du
benzène par d''autres groupes.

### Le toluène, ou méthylbenzène

$$C_7H_8 \quad \text{ou} \quad C_6H_5-CH_3$$

Un hydrogène du benzène est remplacé par un groupe méthyle. C''est un liquide à
température ordinaire, aux propriétés proches de celles du benzène. On
l''utilise pour fabriquer des **explosifs** — le TNT, trinitrotoluène — des
matières plastiques, des colorants et des solvants.

### Le phénol

$$C_6H_6O \quad \text{ou} \quad C_6H_5-OH$$

Un hydrogène est remplacé par un groupe hydroxyle $-OH$. C''est un solide blanc,
utilisé pour fabriquer des explosifs, des colorants, des résines et des
médicaments, dont l''**aspirine**.

### Les autres à connaître

| Nom | Formule | Particularité |
| --- | --- | --- |
| aniline, ou aminobenzène | $C_6H_5-NH_2$ | liquide, sert aux colorants |
| styrène, ou phényléthylène | $C_6H_5-CH=CH_2$ | se polymérise en polystyrène |
| diphényle | $C_{12}H_{10}$ | **deux** noyaux séparés, très toxique, conserve les agrumes |
| naphtalène | $C_{10}H_8$ | **deux** noyaux accolés, la « naphtaline » antimite |

### Nommer les dérivés disubstitués

Quand deux groupes sont fixés sur le cycle, on peut les placer de trois façons,
et chacune a un nom :

- **ortho** : sur deux carbones voisins — positions 1 et 2 ;
- **méta** : séparés par un carbone — positions 1 et 3 ;
- **para** : diamétralement opposés — positions 1 et 4.

Ainsi l''ortho diméthylbenzène s''écrit $C_6H_4(CH_3)_2$ avec les deux méthyles
côte à côte.

---

**Exercice corrigé**

*Donne la formule semi-développée du méta nitrotoluène.*

**Correction.** *Toluène* signifie qu''un méthyle $-CH_3$ est déjà fixé : on le
place sur le carbone n° 1. *Nitro* désigne le groupe $-NO_2$. *Méta* impose les
positions 1 et 3.

Le composé est donc le 3-nitrotoluène, de formule $C_6H_4(CH_3)(NO_2)$, avec le
méthyle en 1 et le groupe nitro en 3.
', NULL, 22),
      (v_chapitre_id, 'Simulation : ortho, méta, para', 5, 'interactif', '{
  "widget": "aromatiques-nomenclature",
  "consigne": "Accroche des groupes sur le cycle — méthyle, nitro, chlore, hydroxyle — et déplace-les d''un sommet à l''autre. Le nom se recalcule à chaque fois, et la simulation t''indique si tu es en ortho, en méta ou en para. Essaie aussi de fabriquer le TNT en plaçant trois groupes nitro aux bons endroits."
}', NULL, 10),
      (v_chapitre_id, 'Les réactions d''addition du benzène', 6, 'texte', '
Le benzène est insaturé, mais il donne **peu** de réactions d''addition : le
nuage délocalisé le rend très stable, et l''ouvrir coûte cher en énergie. Il n''y
en a que trois à connaître, et chacune exige des conditions sévères.

### La combustion

$$2\,C_6H_6 + 15\,O_2 \longrightarrow 12\,CO_2 + 6\,H_2O$$

La réaction est très exothermique : elle libère **3 300 kJ par mole** de
benzène brûlé. Dans l''air, cependant, la combustion du benzène est
**incomplète** : elle dégage beaucoup de suie, parce que la molécule est très
riche en carbone. Le benzène brûle aussi dans le dichlore.

### L''hydrogénation

$$C_6H_6 + 3\,H_2 \xrightarrow[250\,°C,\;40\text{ bars}]{\;Ni\;} C_6H_{12}$$

Note bien les conditions : nickel, 250 °C et 40 bars de pression. Compare avec
l''hydrogénation d''un alcène, qui se faisait tranquillement à température
ordinaire. C''est la mesure de la stabilité du noyau.

Le produit est le **cyclohexane**. Il est cyclique et hexagonal comme le
benzène, mais **il n''est pas plan** : ses carbones sont redevenus tétragonaux.
Il sert de matière première à la fabrication du **nylon**.

### L''addition du dichlore

$$C_6H_6 + 3\,Cl_2 \xrightarrow{\;\text{lumière}\;} C_6H_6Cl_6$$

Le produit est le 1,2,3,4,5,6-hexachlorocyclohexane, connu sous le nom
commercial de **lindane**. Ce sont de fins cristaux blancs, utilisés comme
insecticide. La molécule est cyclique, saturée et non plane.

Retiens la condition : il faut **la lumière**.

### Un avertissement qui n''est pas une formalité

Le benzène est **toxique et cancérigène**. Au laboratoire on ne le manipule
qu''en petites quantités et **sous une hotte**.

---

**Exercice corrigé**

*Vrai ou faux : « les additions sur le noyau benzénique se font en une seule
étape. »*

**Correction.** **Vrai**. Regarde les deux équations : le benzène fixe
directement trois molécules de dihydrogène, ou trois molécules de dichlore, en
un seul bilan. On ne peut pas s''arrêter en chemin.
C''est le contraire des substitutions, que tu vas voir maintenant, et qui se
font elles par étapes successives.
', NULL, 22),
      (v_chapitre_id, 'Simulation : additionner sur le benzène', 7, 'interactif', '{
  "widget": "benzene-addition",
  "consigne": "Choisis le réactif — dihydrogène, dichlore, dioxygène — et règle la température et la pression. Tant que les conditions sont trop douces, rien ne se passe : le noyau résiste. Monte à 250 °C et 40 bars avec du nickel et regarde les trois molécules s''additionner d''un coup, puis le cycle se déplier pour donner le cyclohexane, qui n''est plus plan."
}', NULL, 10),
      (v_chapitre_id, 'Les réactions de substitution', 8, 'texte', '
C''est la chimie habituelle du benzène. Dans une **substitution**, un hydrogène
du cycle est remplacé par un autre atome ou groupe, et le noyau reste intact.
Ces réactions se font par **étapes successives** : une fois le premier
hydrogène remplacé, on peut recommencer.

### Les halogénations

**Avec le dibrome**, en présence de bromure de fer $FeBr_3$ comme catalyseur :

$$C_6H_6 + Br_2 \xrightarrow{\;FeBr_3\;} C_6H_5Br + HBr$$
$$C_6H_5Br + Br_2 \xrightarrow{\;FeBr_3\;} C_6H_4Br_2 + HBr$$

et ainsi de suite jusqu''à $C_6Br_6$. Le produit majoritaire est le
monobromobenzène, accompagné de dérivés polysubstitués.

**Avec le dichlore**, en présence de l''un de ces trois catalyseurs : diiode
$I_2$, chlorure d''aluminium $AlCl_3$ ou chlorure de fer $FeCl_3$ :

$$C_6H_6 + Cl_2 \longrightarrow C_6H_5Cl + HCl$$

On obtient successivement le monochlorobenzène, le dichlorobenzène, le
trichlorobenzène, jusqu''à l''hexachlorobenzène $C_6Cl_6$.

**Le piège.** Avec le dichlore, le benzène fait une **addition à la lumière** et
une **substitution avec catalyseur**. Deux réactions, deux produits, deux jeux
de conditions. Lis toujours les conditions avant de répondre.

### La nitration

$$C_6H_6 + HNO_3 \longrightarrow C_6H_5NO_2 + H_2O$$

Le produit, le **mononitrobenzène**, est utilisé en parfumerie.

Si l''on élève la température et qu''on remplace l''acide nitrique par un
**mélange sulfonitrique** — acide nitrique concentré et acide sulfurique
concentré — la substitution se poursuit : on obtient le 1,3-dinitrobenzène puis
le **1,3,5-trinitrobenzène**, explosif connu sous le nom de *benzite*.

Le même procédé appliqué au toluène donne le **2,4,6-trinitrotoluène**, le
célèbre **TNT**.

### La sulfonation

Vers 80 °C, l''acide sulfurique très concentré réagit sur le benzène :

$$C_6H_6 + H_2SO_4 \xrightarrow{\;80\,°C\;} C_6H_5-HSO_3 + H_2O$$

Le produit est l''acide benzène sulfonique. La réaction peut se poursuivre
jusqu''au dérivé disulfoné puis trisulfoné.

### La réaction de Friedel et Crafts, ou alkylation

C''est la réaction d''un **chlorure d''alkyle** $R-Cl$ avec le benzène, en présence
de chlorure d''aluminium $AlCl_3$. Elle permet de **fixer un groupe alkyle** sur
le cycle.

$$C_6H_6 + CH_3Cl \xrightarrow{\;AlCl_3\;} C_6H_5-CH_3 + HCl$$

Le produit est le méthylbenzène, autrement dit le toluène. Voilà donc comment
on le fabrique.

---

**Exercice corrigé**

*On fait agir un excès de mélange sulfonitrique sur 100 g de benzène. Le
rendement est de 90 %. Quelle masse de trinitrobenzène obtient-on ?*
*On donne $M(H)=1$, $M(C)=12$, $M(N)=14$, $M(O)=16$ g/mol.*

**Correction.** L''équation globale est
$$C_6H_6 + 3\,HNO_3 \longrightarrow C_6H_3(NO_2)_3 + 3\,H_2O$$
$$M(C_6H_6) = 78 \text{ g/mol}$$
$$M(C_6H_3(NO_2)_3) = 72 + 3 + 3(14 + 32) = 213 \text{ g/mol}$$
$$n_{benzène} = \frac{100}{78} = 1{,}28 \text{ mol}$$
Une mole de benzène donnerait une mole de trinitrobenzène. Avec un rendement de
90 % :
$$m = 0{,}90 \times 1{,}28 \times 213 = 245{,}6 \text{ g}$$
On obtient environ **246 g** de 1,3,5-trinitrobenzène.
', NULL, 28),
      (v_chapitre_id, 'Simulation : substituer sur le benzène', 9, 'interactif', '{
  "widget": "benzene-substitution",
  "consigne": "Choisis le réactif et le catalyseur, puis lance la réaction étape par étape : un hydrogène part, un groupe arrive, et le noyau reste intact. Continue et tu verras le di-, puis le tri-substitué se former. Mets du dichlore sans catalyseur mais avec de la lumière : la simulation bascule en addition et le cycle se referme sur le lindane. C''est le piège d''examen, autant le voir une fois pour toutes."
}', NULL, 10),
      (v_chapitre_id, 'Sujet type Probatoire corrigé — fin du module 1', 10, 'texte', '
Voici l''exercice de chimie organique du **Probatoire C et D, session 2012,
Cameroun**. Il balaie tout le module : nomenclature, aromatiques, alcanes,
alcools, déshydratation, Markovnikov. Cherche-le entièrement avant de lire la
correction.

---

### Énoncé

**1.** Nommer les hydrocarbures suivants :
$$\text{(i)} \quad CH_3-C \equiv C-CH(C_2H_5)-CH_2-CH_2-CH_2-CH_3$$
(ii) le dérivé du benzène portant un groupe méthyle en 1 et trois groupes
nitro en 2, 4 et 6.

**2.** Définir : composé aromatique ; réaction de Friedel et Crafts.

**3.** Le méthane est le plus simple des alcanes.
**3.1.** Écrire sa formule développée, représenter sa structure géométrique et
donner la valeur de ses angles valenciels.
**3.2.** Un alcane A a une masse molaire de 72 g/mol.
**3.2.1.** Écrire la formule générale des alcanes, en déduire la formule brute
de A.
**3.2.2.** Écrire les formules semi-développées des isomères de A et les
nommer. De quel type d''isomérie s''agit-il ? Lequel aurait le plus grand indice
d''octane ?
**3.2.3.** On traite le 1-chloropentane et le 2-chloro-2-méthylbutane par une
solution d''hydroxyde de sodium. Le bilan correspond au remplacement de
l''atome de chlore par un groupe hydroxyle.
**3.2.3.1.** Écrire les formules semi-développées des deux produits. À quelle
famille appartiennent-ils ?
**3.2.3.2.** La déshydratation en milieu acide du produit ramifié conduit à
deux alcènes : écrire leurs formules semi-développées.
**3.2.3.3.** On fait réagir le chlorure d''hydrogène sur le 2-méthylbut-2-ène.
Il se forme deux produits dont l''un est majoritaire. Lequel ? Justifier, puis
écrire l''équation-bilan.

*Données : $M(C) = 12$ ; $M(H) = 1$ g/mol.*

---

### Correction

**1. Les deux noms.**
(i) La chaîne la plus longue contenant la triple liaison compte huit carbones :
racine *oct-*, suffixe *-yne*. La triple liaison part du carbone 2, le groupe
éthyle est sur le carbone 4. C''est le **4-éthyloct-2-yne**.
(ii) C''est le **2,4,6-trinitrotoluène**, autrement dit le
**1-méthyl-2,4,6-trinitrobenzène** — le TNT.

**2. Les deux définitions.**
Un **composé aromatique** est tout composé contenant au moins un noyau
benzénique.
La **réaction de Friedel et Crafts**, ou alkylation, est une réaction au cours
de laquelle un groupe alkyle provenant d''un halogénure d''alkyle vient
substituer un atome d''hydrogène sur le noyau benzénique.

**3.1. Le méthane.**
Sa formule développée place les quatre hydrogènes autour du carbone central.
L''atome de carbone occupe le centre d''un **tétraèdre régulier** dont les quatre
sommets portent chacun un hydrogène. Les angles valenciels $\widehat{HCH}$
valent **109°** et les distances $C-H$ valent 110 pm.

**3.2.1. La formule brute de A.**
$$C_nH_{2n+2} \qquad M = 14n + 2 = 72 \;\Longrightarrow\; n = \frac{70}{14} = 5$$
A est le **pentane**, de formule brute $C_5H_{12}$.

**3.2.2. Ses isomères.**
$$CH_3-CH_2-CH_2-CH_2-CH_3 \qquad \text{le } n\text{-pentane}$$
$$CH_3-CH(CH_3)-CH_2-CH_3 \qquad \text{le 2-méthylbutane}$$
$$C(CH_3)_4 \qquad \text{le 2,2-diméthylpropane}$$
C''est une **isomérie de chaîne**.
Le plus grand indice d''octane est celui du **2,2-diméthylpropane** : c''est le
plus ramifié, donc celui qui résiste le mieux à l''autoinflammation.

**3.2.3.1. Les deux produits.**
$$CH_3-CH_2-CH_2-CH_2-CH_2-OH \qquad \text{le pentan-1-ol}$$
$$CH_3-CH_2-C(CH_3)(OH)-CH_3 \qquad \text{le 2-méthylbutan-2-ol}$$
Ils appartiennent à la famille des **alcools**.

**3.2.3.2. La déshydratation du produit ramifié.**
Le 2-méthylbutan-2-ol peut perdre son eau de deux côtés :
$$CH_3-CH=C(CH_3)-CH_3 \qquad \text{le 2-méthylbut-2-ène}$$
$$CH_3-CH_2-C(CH_3)=CH_2 \qquad \text{le 2-méthylbut-1-ène}$$

**3.2.3.3. L''addition de HCl.**
Les deux produits envisageables sont :
$$CH_3-CH_2-CCl(CH_3)-CH_3 \qquad \text{le 2-chloro-2-méthylbutane}$$
$$CH_3-CHCl-CH(CH_3)-CH_3 \qquad \text{le 2-chloro-3-méthylbutane}$$

Le **2-chloro-2-méthylbutane est majoritaire**. Justification : dans le
2-méthylbut-2-ène, le carbone 2 ne porte **aucun** hydrogène et le carbone 3 en
porte **un**. D''après la règle de Markovnikov, l''hydrogène du chlorure
d''hydrogène se fixe sur le carbone le plus hydrogéné, donc sur le carbone 3 ;
le chlore se fixe par conséquent sur le carbone 2.

$$CH_3-CH=C(CH_3)-CH_3 + HCl \longrightarrow CH_3-CH_2-CCl(CH_3)-CH_3$$

---

**Ce que ce sujet t''apprend sur le module.** Une seule question sur le benzène,
une seule sur la nomenclature — et tout le reste enchaîne alcane, alcool,
alcène, addition. Le jury ne teste pas des chapitres séparés : il teste ta
capacité à passer de l''un à l''autre. Révise les **passages** entre familles
autant que les familles elles-mêmes.
', NULL, 35),
      (v_chapitre_id, 'Quiz du chapitre 10', 11, 'quiz', '{
  "titre": "Vérifie que tu as compris",
  "questions": [
    {
      "question": "Combien vaut la longueur d''une liaison carbone-carbone dans le benzène ?",
      "choix": [
        "134 pm, comme une double",
        "154 pm, comme une simple",
        "140 pm, entre les deux",
        "120 pm, comme une triple"
      ],
      "bonne": 2,
      "explication": "Les six liaisons sont identiques et intermédiaires entre la simple et la double. C''est la signature du nuage délocalisé."
    },
    {
      "question": "Quelle insuffisance la représentation de Kekulé présente-t-elle ?",
      "choix": [
        "Elle ne respecte pas la formule brute",
        "Elle prévoit deux orthodichlorobenzènes alors qu''il n''en existe qu''un",
        "Elle rend la molécule non plane",
        "Elle oublie les hydrogènes"
      ],
      "bonne": 1,
      "explication": "Avec des liaisons alternées, deux carbones voisins seraient reliés tantôt par une simple, tantôt par une double. L''expérience montre qu''un seul composé existe."
    },
    {
      "question": "Que représente le cercle dessiné à l''intérieur de l''hexagone ?",
      "choix": [
        "Les six hydrogènes",
        "Le nuage des six électrons délocalisés",
        "Une triple liaison",
        "Le catalyseur"
      ],
      "bonne": 1,
      "explication": "Chaque carbone apporte un électron libre ; les six sont mis en commun sur tout le cycle. Ce cercle s''appelle le noyau benzénique."
    },
    {
      "question": "Dans quelles conditions hydrogène-t-on le benzène en cyclohexane ?",
      "choix": [
        "À température ordinaire sans catalyseur",
        "Nickel, 250 °C, 40 bars",
        "À la lumière",
        "Avec $FeBr_3$"
      ],
      "bonne": 1,
      "explication": "Il faut des conditions sévères, parce que le noyau délocalisé est très stable. Un alcène, lui, s''hydrogène bien plus facilement."
    },
    {
      "question": "Que donne l''action du dichlore sur le benzène à la lumière ?",
      "choix": [
        "Une substitution, le monochlorobenzène",
        "Une addition, le lindane $C_6H_6Cl_6$",
        "Rien",
        "Une combustion"
      ],
      "bonne": 1,
      "explication": "À la lumière c''est une addition. Avec un catalyseur comme $FeCl_3$, c''est au contraire une substitution : lis toujours les conditions."
    },
    {
      "question": "Comment s''appelle la réaction d''un chlorure d''alkyle sur le benzène en présence de $AlCl_3$ ?",
      "choix": [
        "La nitration",
        "La sulfonation",
        "La réaction de Friedel et Crafts",
        "La bromation"
      ],
      "bonne": 2,
      "explication": "Aussi appelée alkylation, elle fixe un groupe alkyle sur le cycle. Avec $CH_3Cl$, elle donne le toluène."
    },
    {
      "question": "Deux groupes occupent les positions 1 et 4 du cycle. Comment dit-on ?",
      "choix": [
        "ortho",
        "méta",
        "para",
        "cyclo"
      ],
      "bonne": 2,
      "explication": "Ortho, c''est 1 et 2 ; méta, c''est 1 et 3 ; para, c''est 1 et 4, diamétralement opposés."
    }
  ]
}', NULL, 5);

    RAISE NOTICE '% : 11 leçons ajoutées au chapitre 10, Les composés aromatiques : le benzène.', v_nom;
  END LOOP;
END $ch1$;
