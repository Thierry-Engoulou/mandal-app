-- ---------------------------------------------------------------------------
-- M'Andal — Chimie, classes de Première
-- Chapitre 11 : Les pétroles et les gaz naturels
-- Module 2 : Les pétroles, les gaz naturels et les engrais — 9 leçons
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
    WHERE programme_id = v_programme_id AND ordre = 11;

    IF v_chapitre_id IS NULL THEN
      INSERT INTO public.chapitres (programme_id, titre, ordre, niveau)
      VALUES (v_programme_id, 'Les pétroles et les gaz naturels', 11, 'Module 2 : Les pétroles, les gaz naturels et les engrais')
      RETURNING id INTO v_chapitre_id;
      RAISE NOTICE '% : chapitre 11 créé.', v_nom;
    END IF;

    -- Les leçons. Si le chapitre en a déjà, on passe son tour sans rien toucher.
    SELECT count(*) INTO v_deja FROM public.concepts WHERE chapitre_id = v_chapitre_id;
    IF v_deja > 0 THEN
      RAISE NOTICE '% : le chapitre 11 a déjà ses % leçons, je n''y touche pas.', v_nom, v_deja;
      CONTINUE;
    END IF;

    INSERT INTO public.concepts
      (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes) VALUES
      (v_chapitre_id, 'D''où vient le pétrole et de quoi il est fait', 1, 'texte', '
### Une origine organique

Le pétrole brut provient de la **décomposition lente de matières organiques**
d''origine animale ou végétale, accumulées il y a des millions d''années.

C''est une source d''énergie **non renouvelable** : à l''échelle d''une vie humaine,
ce qu''on prélève ne se reforme pas. Elle se trouve à une profondeur comprise
entre **1 km et 4 km** dans la terre.

### Les trois facteurs de formation

Retiens-les, ils tombent souvent en question de cours :

1. la **décomposition** de la matière organique ;
2. la **géothermie**, c''est-à-dire la chaleur interne du sous-sol ;
3. la **durée** d''action de cette géothermie.

Enlève l''un des trois et il n''y a pas de pétrole. C''est pourquoi les gisements
sont rares et inégalement répartis.

### La composition du pétrole brut

Quelle que soit son origine, le pétrole est essentiellement constitué
d''**hydrocarbures** — tu les connais tous maintenant :

- les **alcanes**, majoritaires : de **50 à 98 %** du pétrole brut ;
- les **cyclanes** ;
- les **composés aromatiques**.

On y trouve aussi, sous forme de **traces** :

- des composés **soufrés**, comme le sulfure d''hydrogène $H_2S$ ;
- des composés **oxygénés** ;
- des composés **azotés** ;
- des composés **minéraux**, notamment le fer et le nickel.

Tous ces composés-là sont des **impuretés**. Elles sont éliminées pendant le
raffinage, parce qu''elles abîment les moteurs et empoisonnent les catalyseurs.

### Le gisement

Les trois fluides d''un gisement se rangent par densité : le **gaz naturel** en
haut, le **pétrole brut** au milieu, l''**eau salée** en bas. Le tout est
enfermé sous une **roche imperméable** qui fait office de couvercle. Sans elle,
tout se serait dispersé depuis longtemps.

---

**Exercice corrigé**

*Vrai ou faux : « le pétrole brut et le gaz naturel ont une origine commune :
la matière organique. »*

**Correction.** **Vrai**. Les deux proviennent de la décomposition de la même
matière organique, dans les mêmes conditions de géothermie. Ce qui les sépare,
c''est le degré d''avancement de la décomposition et la profondeur : plus c''est
profond et plus c''est chaud, plus les molécules sont petites, donc plus on
tend vers le gaz.
', NULL, 22),
      (v_chapitre_id, 'Simulation : explorer un gisement', 2, 'interactif', '{
  "widget": "gisement-petrole",
  "consigne": "Forme ton propre gisement : dépose la matière organique, règle la profondeur, la température du sous-sol et la durée, puis lance l''horloge géologique. Selon les réglages tu obtiendras du gaz, du pétrole, ou rien du tout. Place ensuite la roche imperméable et forre : la simulation te dit si tu as touché le gaz, le pétrole ou l''eau salée."
}', NULL, 10),
      (v_chapitre_id, 'Le raffinage : la distillation fractionnée', 3, 'texte', '
### Ce qu''est le raffinage

Le **raffinage**, c''est l''ensemble des opérations de traitement subies par le
pétrole brut avant son utilisation. Il a deux buts :

1. **Séparer** les constituants en plusieurs fractions, appelées **coupes**, de
volatilité croissante. C''est un traitement **physique** : la distillation
fractionnée.
2. **Obtenir** des hydrocarbures qui n''entrent pas dans la composition du
pétrole — les alcènes, par exemple — ou qui y sont en quantité insuffisante.
C''est un traitement **chimique** : le craquage, le reformage, l''isomérisation.

Retiens bien cette division en deux : elle structure toute la suite.

### La distillation

C''est le procédé de séparation des différents constituants du pétrole brut. Elle
se fait dans une tour à distillation appelée **colonne à plateaux**.

Le principe est simple. On chauffe le brut vers 350 à 400 °C et on l''injecte au
bas de la colonne. Les vapeurs montent. Plus elles montent, plus il fait froid.
Chaque molécule se recondense à l''étage dont la température correspond à sa
propre température d''ébullition. Les petites molécules, très volatiles, montent
tout en haut ; les grosses restent en bas.

**Attention au vocabulaire.** Les coupes obtenues ne sont pas des corps purs :
ce sont des **mélanges de corps purs de températures d''ébullition voisines**.
C''est une erreur fréquente aux examens.

### Les produits obtenus

Du haut vers le bas de la colonne, donc du plus léger au plus lourd :

| Coupe | Température | Usage |
| --- | --- | --- |
| gaz | moins de 20 °C | butane, propane domestiques |
| essences légères | 20 à 180 °C | moteurs à essence |
| pétrole lampant | 180 à 250 °C | lampes, kérosène pour avions |
| gasoil | 250 à 350 °C | moteurs diesel |
| fuel et huiles | 350 à 400 °C | chauffage, lubrifiants |
| bitumes | résidu | revêtement des routes |

L''installation industrielle où s''effectue cette distillation s''appelle une
**raffinerie**. Au Cameroun, c''est la **SONARA**, à Limbé.

---

**Exercice corrigé**

*Un mélange contient six alcanes de températures d''ébullition 36, 98, 150, 174,
216 et 270 °C. Quel est le plus volatil ? Lequel resterait au bas de la
colonne ? La distillation fractionnée peut-elle les séparer ?*

**Correction.**
Le plus **volatil** est celui qui bout le plus bas : le pentane, à 36 °C.
Celui qui resterait **au bas** de la colonne est celui qui bout le plus haut :
le pentadécane, à 270 °C.
Oui, la séparation est **possible** : les six températures d''ébullition sont
assez éloignées les unes des autres pour que chaque constituant se condense sur
un plateau distinct.
', NULL, 25),
      (v_chapitre_id, 'Simulation : la colonne à plateaux', 4, 'interactif', '{
  "widget": "distillation-petrole",
  "consigne": "Injecte le brut au bas de la tour et regarde les molécules monter. Règle la température de chaque plateau et récupère les coupes une à une. Change la composition du brut — plus d''alcanes légers, plus de lourds — et observe les proportions de chaque produit changer en sortie. C''est exactement ce que fait un opérateur de la SONARA devant ses écrans."
}', NULL, 10),
      (v_chapitre_id, 'Craquage, reformage et indice d''octane', 5, 'texte', '
La distillation sépare, mais elle ne crée rien. Or le marché veut surtout des
essences légères, et le brut en contient trop peu. Il faut donc **transformer
chimiquement** les coupes lourdes. Quatre opérations à connaître.

### Le craquage

C''est l''opération qui transforme des **hydrocarbures lourds en hydrocarbures
légers**, par rupture des liaisons carbone-carbone. Il a lieu après la
distillation fractionnée.

Le **craquage catalytique** se fait vers **500 °C**, à la pression
atmosphérique, en présence d''un catalyseur :

$$C_{10}H_{22} \longrightarrow C_8H_{18} + C_2H_4$$
$$C_9H_{20} \longrightarrow C_6H_{14} + C_3H_6$$

Note bien : chaque fois, on obtient un alcane **et un alcène**. Voilà d''où
viennent les alcènes de l''industrie des plastiques.

Le **vapocraquage**, ou craquage à la vapeur d''eau, est un craquage thermique
qui s''effectue sous faible pression, vers **800 °C**, en présence d''eau.

L''**hydrocraquage**, ou craquage à l''hydrogène, est un craquage catalytique
associé à une hydrogénation. Il s''effectue entre **250 et 450 °C** sous fortes
pressions de dihydrogène. Attention au préfixe : *hydro* signifie ici
**hydrogène**, pas eau.

### Le reformage

C''est l''opération qui **modifie la structure** d''un hydrocarbure **sans
modifier son nombre de carbones**. Elle vise à améliorer la qualité des
essences légères en augmentant leur **indice d''octane**.

$$C_8H_{18} \text{ (octane)} \xrightarrow[\text{catalyseur}]{500\,°C} \text{2,2,4-triméthylpentane}$$

### L''isomérisation et la cyclisation

L''**isomérisation** transforme les alcanes **linéaires** en alcanes
**ramifiés**.

La **cyclisation** transforme un alcane linéaire en **cyclane**, par
déshydrogénation.

### L''indice d''octane : la clé de tout

L''indice d''octane mesure la capacité d''une essence à **résister à
l''autoinflammation** dans le moteur. Une essence qui s''enflamme trop tôt fait
cogner le moteur et l''abîme.

**La règle à retenir : plus une molécule est ramifiée, plus son indice d''octane
est élevé.** Les cyclanes aussi ont un bon indice. Les alcanes à chaîne droite
sont les plus mauvais.

C''est exactement pour cela qu''on fait du reformage, de l''isomérisation et de la
cyclisation : les trois opérations ramifient ou cyclisent, donc les trois
améliorent l''indice d''octane.

---

**Exercice corrigé**

*Classe ces trois alcanes de $C_8H_{18}$ par indice d''octane croissant :*
*a)* $CH_3-(CH_2)_6-CH_3$   *b)* $CH_3-CH_2-CH(CH_3)-CH_2-CH_2-CH_2-CH_3$
*c)* $CH_3-C(CH_3)_2-C(CH_3)_2-CH_3$

**Correction.** On compte les ramifications.
a) l''octane linéaire : **zéro** ramification.
b) le 3-méthylheptane : **une** ramification.
c) le 2,2,3,3-tétraméthylbutane : **quatre** ramifications.

Classement par indice d''octane croissant : **a, puis b, puis c**. Le carburant
de qualité supérieure est le **c**.
', NULL, 25),
      (v_chapitre_id, 'Simulation : améliorer un carburant', 6, 'interactif', '{
  "widget": "indice-octane",
  "consigne": "Pars d''un alcane linéaire et applique les opérations de la raffinerie : isomérisation, cyclisation, reformage. À chaque transformation, la simulation recalcule l''indice d''octane et te montre le moteur cogner — ou tourner rond. Essaie de passer de l''heptane, indice zéro, au 2,2,4-triméthylpentane, indice cent : ce sont les deux bornes de l''échelle."
}', NULL, 10),
      (v_chapitre_id, 'Les gaz naturels, les usages et les dangers', 7, 'texte', '
### La composition des gaz naturels

Elle dépend de la matière organique de départ. Le constituant **principal** des
gisements de gaz naturels est le **méthane** $CH_4$.

En plus du méthane, on y trouve : l''éthane, le propane, le butane, le diazote,
le dioxyde de carbone et le sulfure d''hydrogène.

### Le traitement des gaz naturels

Pour rendre le gaz utilisable, il faut le débarrasser de ses impuretés :

- l''**eau** est éliminée par séchage, grâce à des déshydratants appropriés ;
- le **dioxyde de carbone** est fixé par des réactifs chimiques ;
- le **sulfure d''hydrogène** est fixé lui aussi par des réactifs chimiques, puis
régénéré par chauffage, et enfin utilisé pour préparer l''acide sulfurique ;
- le **propane et le butane** sont séparés des autres composés par distillation
fractionnée.

Remarque le détail élégant : l''impureté la plus gênante, le $H_2S$, n''est pas
jetée — elle devient une matière première.

### Trois familles d''usages

**Source d''énergie**, sous forme de carburants : gasoil et essence pour les
moteurs de voitures, kérosène pour les avions.

**Combustibles domestiques** : le pétrole lampant et le butane, encore appelé
gaz domestique — la bouteille de la cuisine.

**Matières premières**, pour la fabrication des matières plastiques et la
synthèse de certains produits pharmaceutiques, comme les huiles de beauté.

### Les dangers

Il faut les connaître, c''est au programme et c''est une question de cours
fréquente.

- Les **incendies**, car les produits pétroliers sont très inflammables.
- Les **intoxications** : la combustion des produits pétroliers libère des gaz
nocifs, le monoxyde de carbone $CO$, le cyanure d''hydrogène et le chlorure
d''hydrogène. C''est pourquoi on aère une cuisine au gaz.
- La **pollution atmosphérique** et la **pollution marine**.
- L''**effet de serre**, dû au dioxyde de carbone $CO_2$, aux fréons et aux CFC.
L''effet de serre est le réchauffement du globe terrestre causé par la
détérioration de la couche d''ozone par certains gaz.

### Au Cameroun

Quelques sigles à connaître, ils figurent dans les sujets d''examen :

| Sigle | Ce qu''il désigne |
| --- | --- |
| **SONARA** | Société nationale de raffinage, à Limbé |
| **SNH** | Société nationale des hydrocarbures |
| **SCDP** | Société camerounaise des dépôts pétroliers |
| **CSPH** | Caisse de stabilisation des prix des hydrocarbures |

Le **pipeline Tchad-Cameroun**, long de plus de 1 000 km, achemine le brut
tchadien jusqu''au terminal de Kribi.

---

**Exercice corrigé**

*Une dame utilise une bouteille de gaz liquéfié pour préparer du Ndolè. Elle
pèse la bouteille avant et après : la différence vaut $m = 2{,}30$ kg. Le gaz
est du butane. Détermine le volume de $CO_2$ rejeté dans la cuisine, la masse
d''eau formée, et le volume d''air nécessaire. L''air contient 20 % de dioxygène
en volume. On prend $V_m = 22{,}4$ L/mol.*

**Correction.** La masse $m$ représente la **masse de butane consommée**.

$$C_4H_{10} + \frac{13}{2}\,O_2 \longrightarrow 4\,CO_2 + 5\,H_2O$$
$$M(C_4H_{10}) = 58 \text{ g/mol} \qquad n = \frac{2\,300}{58} = 39{,}7 \text{ mol}$$

*Dioxyde de carbone.*
$$n_{CO_2} = 4 \times 39{,}7 = 158{,}6 \text{ mol} \qquad V_{CO_2} = 158{,}6 \times 22{,}4 = 3\,553 \text{ L}$$
soit environ **3,6 m³** de $CO_2$ rejetés dans la cuisine.

*Eau.*
$$n_{H_2O} = 5 \times 39{,}7 = 198{,}3 \text{ mol} \qquad m_{H_2O} = 198{,}3 \times 18 = 3\,569 \text{ g}$$
soit environ **3,6 kg** d''eau, qui se dépose sur les murs de la cuisine.

*Air.*
$$n_{O_2} = 6{,}5 \times 39{,}7 = 258 \text{ mol} \qquad V_{O_2} = 5\,779 \text{ L}$$
$$V_{air} = 5 \times V_{O_2} = 28\,896 \text{ L} \approx 29 \text{ m³}$$

*Pourquoi aérer.* Une cuisine ordinaire fait peut-être 20 m³. Il faut donc, pour
une seule bouteille, plus d''une fois et demie le volume de la pièce en air
frais — et l''on y rejette 3,6 m³ de $CO_2$. Sans aération efficace, le
dioxygène manque, la combustion devient incomplète, et c''est le **monoxyde de
carbone** qui se forme. Il est inodore et mortel.
', NULL, 28),
      (v_chapitre_id, 'Simulation : la bouteille de gaz et la cuisine', 8, 'interactif', '{
  "widget": "camping-gaz",
  "consigne": "Règle la masse de butane consommée et le volume de ta cuisine, puis allume le brûleur. La simulation suit en direct le dioxygène qui baisse, le dioxyde de carbone qui monte et l''eau qui se condense sur les murs. Ferme la fenêtre et regarde la flamme virer à l''orange : la combustion devient incomplète et le monoxyde de carbone apparaît. Ouvre-la et tout revient à la normale."
}', NULL, 10),
      (v_chapitre_id, 'Quiz du chapitre 11', 9, 'quiz', '{
  "titre": "Vérifie que tu as compris",
  "questions": [
    {
      "question": "Quels sont les trois facteurs de formation du pétrole ?",
      "choix": [
        "La pluie, le vent et le temps",
        "La décomposition de la matière organique, la géothermie et la durée",
        "Le volcanisme, la mer et le sel",
        "La pression, le froid et le sable"
      ],
      "bonne": 1,
      "explication": "Les trois sont nécessaires ensemble. Si l''un manque, il n''y a pas de pétrole, et c''est pourquoi les gisements sont rares."
    },
    {
      "question": "Quelle famille d''hydrocarbures est majoritaire dans le pétrole brut ?",
      "choix": [
        "Les alcènes",
        "Les alcanes, de 50 à 98 %",
        "Les aromatiques",
        "Les alcynes"
      ],
      "bonne": 1,
      "explication": "On y trouve aussi des cyclanes et des aromatiques, et des traces de composés soufrés, oxygénés, azotés et minéraux, qui sont des impuretés."
    },
    {
      "question": "Que sont les coupes obtenues par distillation fractionnée ?",
      "choix": [
        "Des corps purs",
        "Des mélanges de corps purs de températures d''ébullition voisines",
        "Des alcènes seulement",
        "Des impuretés"
      ],
      "bonne": 1,
      "explication": "C''est une erreur très fréquente aux examens : la distillation sépare par intervalle de température, pas molécule par molécule."
    },
    {
      "question": "Le craquage consiste à :",
      "choix": [
        "modifier la structure sans changer le nombre de carbones",
        "transformer des hydrocarbures lourds en hydrocarbures légers",
        "séparer les constituants du brut",
        "éliminer le soufre"
      ],
      "bonne": 1,
      "explication": "Il rompt les liaisons carbone-carbone. C''est le reformage qui modifie la structure sans toucher au nombre de carbones."
    },
    {
      "question": "Comment varie l''indice d''octane quand une molécule est plus ramifiée ?",
      "choix": [
        "Il diminue",
        "Il augmente",
        "Il ne change pas",
        "Il devient nul"
      ],
      "bonne": 1,
      "explication": "C''est tout l''intérêt de l''isomérisation et du reformage : ramifier la molécule pour qu''elle résiste mieux à l''autoinflammation."
    },
    {
      "question": "Quel est le constituant principal des gaz naturels ?",
      "choix": [
        "Le butane",
        "Le méthane",
        "Le diazote",
        "Le sulfure d''hydrogène"
      ],
      "bonne": 1,
      "explication": "Le gaz naturel contient aussi de l''éthane, du propane, du butane, du diazote, du dioxyde de carbone et du sulfure d''hydrogène."
    },
    {
      "question": "Pourquoi faut-il bien aérer une cuisine où brûle du gaz ?",
      "choix": [
        "Pour évacuer l''odeur",
        "Parce que sans dioxygène suffisant la combustion devient incomplète et produit du monoxyde de carbone",
        "Pour refroidir la pièce",
        "Pour économiser le gaz"
      ],
      "bonne": 1,
      "explication": "Le monoxyde de carbone est inodore et mortel. Une seule bouteille de butane consomme plus d''air que le volume d''une cuisine ordinaire."
    }
  ]
}', NULL, 5);

    RAISE NOTICE '% : 9 leçons ajoutées au chapitre 11, Les pétroles et les gaz naturels.', v_nom;
  END LOOP;
END $ch1$;
