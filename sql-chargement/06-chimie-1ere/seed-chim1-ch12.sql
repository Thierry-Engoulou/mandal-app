-- ---------------------------------------------------------------------------
-- M'Andal — Chimie, classes de Première
-- Chapitre 12 : Les engrais
-- Module 2 : Les pétroles, les gaz naturels et les engrais — 10 leçons
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
    WHERE programme_id = v_programme_id AND ordre = 12;

    IF v_chapitre_id IS NULL THEN
      INSERT INTO public.chapitres (programme_id, titre, ordre, niveau)
      VALUES (v_programme_id, 'Les engrais', 12, 'Module 2 : Les pétroles, les gaz naturels et les engrais')
      RETURNING id INTO v_chapitre_id;
      RAISE NOTICE '% : chapitre 12 créé.', v_nom;
    END IF;

    -- Les leçons. Si le chapitre en a déjà, on passe son tour sans rien toucher.
    SELECT count(*) INTO v_deja FROM public.concepts WHERE chapitre_id = v_chapitre_id;
    IF v_deja > 0 THEN
      RAISE NOTICE '% : le chapitre 12 a déjà ses % leçons, je n''y touche pas.', v_nom, v_deja;
      CONTINUE;
    END IF;

    INSERT INTO public.concepts
      (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes) VALUES
      (v_chapitre_id, 'Le sol et le complexe argilo-humique', 1, 'texte', '
Au Cameroun, l''agriculture fait vivre la majorité des familles. Ce chapitre est
le plus directement utile de tout le programme : il explique ce qu''on met dans
la terre, et pourquoi.

### Ce que les plantes prélèvent

Une plante puise dans le sol l''eau et les **sels minéraux** dont elle a besoin
pour grandir. Récolte après récolte, ces sels s''épuisent : ce que la plante
emporte au marché, le sol ne l''a plus.

Un **engrais** est un produit que l''on apporte au sol pour lui restituer les
éléments que les cultures lui ont retirés.

### Le complexe argilo-humique

C''est l''association, dans le sol, de l''**argile** — la fraction minérale la
plus fine — et de l''**humus** — la matière organique décomposée. Ces deux
constituants se lient pour former un ensemble appelé **complexe
argilo-humique**.

Son rôle est double, et il faut comprendre les deux :

1. Il **retient les éléments fertilisants** et les restitue peu à peu à la
plante. Sans lui, l''engrais serait entraîné par la première pluie.
2. Il donne au sol sa **structure** : il colle les grains entre eux, ce qui
laisse passer l''air et l''eau sans que la terre parte en poussière ni se
compacte.

Un sol pauvre en complexe argilo-humique — un sol sableux, par exemple — retient
mal les engrais. Il faut l''amender en matière organique avant même de penser
aux engrais minéraux. C''est une réponse qu''on attend de toi en examen.

---

**Exercice corrigé**

*Qu''est-ce que le complexe argilo-humique ?*

**Correction.** C''est l''ensemble formé dans le sol par l''association de l''argile
et de l''humus. Il retient les éléments fertilisants et les libère
progressivement au profit des plantes, et il assure la stabilité de la
structure du sol.
', NULL, 20),
      (v_chapitre_id, 'Simulation : le sol qui retient, le sol qui lessive', 2, 'interactif', '{
  "widget": "complexe-argilo-humique",
  "consigne": "Choisis un type de sol — sableux, argileux, riche en humus — répands l''engrais, puis fais tomber la pluie. La simulation te montre ce que le complexe argilo-humique retient et ce qui part dans la nappe. Augmente la teneur en humus et recommence : tu verras combien d''engrais tu économises, et pourquoi on parle d''amender un sol avant de le fertiliser."
}', NULL, 10),
      (v_chapitre_id, 'Les trois éléments fertilisants', 3, 'texte', '
Trois éléments dominent la nutrition des plantes. On les désigne par leurs
symboles chimiques, et on les cite toujours dans cet ordre : **N, P, K**.

### N, l''azote

Il **assure la croissance** et donne un **feuillage vert** aux plantes. C''est
l''élément de la végétation : tiges, feuilles, masse verte.

Un manque d''azote se voit tout de suite — les feuilles jaunissent et la plante
reste petite.

### P, le phosphore

Il **facilite les échanges énergétiques** dans les cellules végétales. Il
favorise aussi la **fructification et la floraison**.

C''est l''élément du rendement : sans phosphore, la plante pousse mais ne donne
pas de fruits.

### K, le potassium

Il **active la photosynthèse** et **augmente la résistance** des plantes — à la
sécheresse, au froid, aux maladies.

### Comment les retenir sans se tromper

Associe chaque lettre à une partie de la plante :

| Élément | La partie | Le mot-clé |
| --- | --- | --- |
| **N** azote | les feuilles | croissance, vert |
| **P** phosphore | les fleurs et les fruits | énergie, floraison |
| **K** potassium | la plante entière | photosynthèse, résistance |

De haut en bas de la plante, dans l''ordre N, P, K. C''est un moyen mnémotechnique
imparfait mais il rend service le jour de l''examen.

---

**Exercice corrigé**

*Un planteur de tomates constate que ses pieds sont grands, très verts et
touffus, mais donnent peu de fruits. Quel élément manque probablement, et
lequel a-t-il mis en excès ?*

**Correction.** Grands, verts et touffus : l''**azote** est abondant, peut-être
en excès. Peu de fruits : c''est le **phosphore**, responsable de la
fructification, qui fait défaut.
Il lui faut un engrais dont le deuxième nombre est plus élevé que le premier :
un 10-20-15 plutôt qu''un 20-10-10.
', NULL, 20),
      (v_chapitre_id, 'Figure : l''étiquette d''un sac d''engrais', 4, 'figure', '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 540 290" width="540" height="290">
<rect width="540" height="290" fill="#ffffff"/>
<text x="270" y="22" text-anchor="middle" font-size="14" font-weight="700" fill="#0f172a">Lire l&apos;étiquette d&apos;un sac d&apos;engrais</text>

<rect x="36" y="44" width="200" height="212" fill="#f8fafc" stroke="#334155" stroke-width="2" rx="10"/>
<rect x="36" y="44" width="200" height="46" fill="#166534" rx="10"/>
<rect x="36" y="76" width="200" height="14" fill="#166534"/>
<text x="136" y="74" text-anchor="middle" font-size="15" font-weight="700" fill="#ffffff">ENGRAIS COMPLET</text>

<text x="136" y="140" text-anchor="middle" font-size="34" font-weight="700" fill="#0f172a">15 &#8211; 11 &#8211; 20</text>
<text x="136" y="164" text-anchor="middle" font-size="12" font-weight="700" fill="#166534">N &#8211; P&#8322;O&#8325; &#8211; K&#8322;O</text>
<line x1="60" y1="180" x2="212" y2="180" stroke="#cbd5e1" stroke-width="1.4"/>
<text x="136" y="202" text-anchor="middle" font-size="11" fill="#334155">Sac de 50 kg</text>
<text x="136" y="222" text-anchor="middle" font-size="10" fill="#64748b">Cultures maraîchères</text>
<text x="136" y="240" text-anchor="middle" font-size="10" fill="#64748b">et bananeraies</text>

<g font-size="11">
  <line x1="236" y1="128" x2="276" y2="98" stroke="#2563eb" stroke-width="1.5"/>
  <rect x="280" y="80" width="232" height="38" fill="#dbeafe" rx="6"/>
  <text x="290" y="96" font-weight="700" fill="#1e3a8a">15 kg d&apos;AZOTE N pour 100 kg</text>
  <text x="290" y="111" fill="#334155">croissance, feuillage vert</text>

  <line x1="236" y1="136" x2="276" y2="140" stroke="#ca8a04" stroke-width="1.5"/>
  <rect x="280" y="124" width="232" height="38" fill="#fef3c7" rx="6"/>
  <text x="290" y="140" font-weight="700" fill="#78350f">11 kg de P&#8322;O&#8325; pour 100 kg</text>
  <text x="290" y="155" fill="#334155">énergie, floraison, fructification</text>

  <line x1="236" y1="146" x2="276" y2="184" stroke="#16a34a" stroke-width="1.5"/>
  <rect x="280" y="168" width="232" height="38" fill="#dcfce7" rx="6"/>
  <text x="290" y="184" font-weight="700" fill="#14532d">20 kg de K&#8322;O pour 100 kg</text>
  <text x="290" y="199" fill="#334155">photosynthèse, résistance</text>
</g>

<rect x="280" y="216" width="232" height="50" fill="#f1f5f9" stroke="#94a3b8" stroke-width="1.2" rx="6"/>
<text x="290" y="234" font-size="11" font-weight="700" fill="#0f172a">Attention au piège</text>
<text x="290" y="250" font-size="10" fill="#334155">les 2&#170; et 3&#170; valeurs sont des OXYDES,</text>
<text x="290" y="262" font-size="10" fill="#334155">pas du phosphore ni du potassium purs</text>
</svg>', NULL, 5),
      (v_chapitre_id, 'Simulation : nourrir une plante', 5, 'interactif', '{
  "widget": "role-npk",
  "consigne": "Fais pousser une plante en réglant toi-même les apports d''azote, de phosphore et de potassium. Coupe l''azote et regarde les feuilles jaunir ; coupe le phosphore et la plante poussera sans jamais fleurir ; coupe le potassium et le premier coup de sécheresse la couchera. Tu comprendras en trois essais ce qu''un tableau met une page à expliquer."
}', NULL, 10),
      (v_chapitre_id, 'Lire une étiquette et calculer les masses', 6, 'texte', '
C''est l''exercice d''examen. Il tombe presque chaque année, et il se résout
toujours de la même façon.

### Ce que signifient les trois nombres

Un sac porte l''inscription **NPK : 15 – 11 – 20**. Ces trois nombres sont les
**teneurs**, notées $t$, exprimées en **kilogrammes pour 100 kg d''engrais** :

$$t_N = 15\,\% \qquad t_{P_2O_5} = 11\,\% \qquad t_{K_2O} = 20\,\%$$

Autrement dit, 100 kg de cet engrais contiennent 15 kg d''azote, 11 kg d''oxyde
de phosphore $P_2O_5$ et 20 kg d''oxyde de potassium $K_2O$.

### Le piège, et il est redoutable

Le premier nombre est une teneur en **azote pur**.

Les deux autres sont des teneurs en **oxydes**, $P_2O_5$ et $K_2O$ — pas en
phosphore ni en potassium purs. Si on te demande la masse de **phosphore**, il
faut convertir.

### Les trois formules

Pour un échantillon de masse $m_e$ :

$$\boxed{\;m_N = t_N \times \frac{m_e}{100}\;}$$

$$\boxed{\;m_P = \frac{2M_P}{M_{P_2O_5}} \times t_{P_2O_5} \times \frac{m_e}{100}\;}$$

$$\boxed{\;m_K = \frac{2M_K}{M_{K_2O}} \times t_{K_2O} \times \frac{m_e}{100}\;}$$

Le facteur $\frac{2M_P}{M_{P_2O_5}}$ se lit directement : dans une mole
d''oxyde $P_2O_5$ il y a **deux** moles de phosphore. On ne garde donc que la
fraction de masse qui correspond au phosphore.

Avec $M_P = 31$ et $M_O = 16$ :
$$\frac{2M_P}{M_{P_2O_5}} = \frac{62}{142} = 0{,}436$$

Avec $M_K = 39{,}1$ :
$$\frac{2M_K}{M_{K_2O}} = \frac{78{,}2}{94{,}2} = 0{,}830$$

Retiens ces deux coefficients, **0,436** pour le phosphore et **0,830** pour le
potassium. Ils te feront gagner cinq minutes le jour de l''épreuve.

---

**Exercice corrigé**

*L''étiquette d''un sac d''engrais porte l''inscription NPK : 15 – 11 – 20. On
considère un échantillon de 2,5 kg. Détermine les masses d''azote et de
phosphore qu''il contient.*
*On donne $M(O) = 16$, $M(N) = 14$, $M(P) = 31$, $M(K) = 39{,}1$ g/mol.*

**Correction.**

*Azote.* C''est direct, pas de conversion :
$$m_N = 15 \times \frac{2{,}5}{100} = 0{,}375 \text{ kg}$$

*Phosphore.* Il faut convertir l''oxyde en élément :
$$M_{P_2O_5} = 2 \times 31 + 5 \times 16 = 142 \text{ g/mol}$$
$$m_P = \frac{62}{142} \times 11 \times \frac{2{,}5}{100} = 0{,}436 \times 11 \times 0{,}025 = 0{,}12 \text{ kg}$$

L''échantillon contient **375 g d''azote** et **120 g de phosphore**.
', NULL, 28),
      (v_chapitre_id, 'Simulation : calculer un apport d''engrais', 7, 'interactif', '{
  "widget": "engrais-npk",
  "consigne": "Compose ton propre sac en réglant les trois nombres de l''étiquette, choisis une masse d''échantillon, et la simulation calcule les masses de N, de P et de K — en te montrant à chaque fois la conversion de l''oxyde vers l''élément. Pars ensuite dans l''autre sens : indique ce que ton champ a besoin de recevoir, et elle te dit combien de kilos de sac répandre."
}', NULL, 10),
      (v_chapitre_id, 'Les familles d''engrais et les précautions', 8, 'texte', '
### Les engrais simples

Ils n''apportent qu''un seul des trois éléments.

**Les azotés.** L''urée $CO(NH_2)_2$, la plus concentrée ; le nitrate d''ammonium
$NH_4NO_3$ ; le sulfate d''ammonium $(NH_4)_2SO_4$.

L''azote de ces engrais vient de l''**ammoniac**, fabriqué industriellement à
partir du diazote de l''air :

$$N_2 + 3\,H_2 \rightleftharpoons 2\,NH_3$$

**Les phosphatés.** Le superphosphate, obtenu en traitant le phosphate naturel
par l''acide sulfurique, ce qui le rend assimilable par les plantes.

**Les potassiques.** Le chlorure de potassium $KCl$ et le sulfate de potassium
$K_2SO_4$.

### Les engrais composés

Un engrais **binaire** apporte deux éléments, par exemple un NP ou un PK.

Un engrais **ternaire**, dit aussi **complet**, apporte les trois : c''est le cas
du 15-11-20 de la leçon précédente.

### Les précautions d''emploi

**Ne pas dépasser la dose.** L''excès n''est pas absorbé par la plante : il est
lessivé par les pluies et rejoint les rivières et les nappes. Les nitrates en
excès rendent l''eau impropre à la consommation et provoquent la prolifération
des algues, qui étouffent la vie des cours d''eau.

**Épandre au bon moment.** Un engrais répandu juste avant une forte pluie part
avec elle : l''argent est perdu et la rivière est polluée.

**Choisir selon la culture et selon le sol.** Un sol pauvre en humus retient mal
les engrais, comme tu l''as vu au début du chapitre. L''analyse de sol précède
toujours le choix de la formule.

---

**Exercice corrigé**

*Un maraîcher dispose de deux engrais : un 20-10-10 et un 10-20-20. Son sol est
sableux, et il cultive des tomates en pleine saison des pluies. Que
lui conseilles-tu ?*

**Correction.**
La tomate est une culture **fruitière** : elle a surtout besoin de phosphore
pour la fructification et de potassium pour la résistance. Le **10-20-20** est
donc le mieux adapté.
Le sol étant **sableux**, il retient mal les éléments : il faut y apporter de la
matière organique pour enrichir le complexe argilo-humique.
Enfin, en **saison des pluies**, le risque de lessivage est maximal : il vaut
mieux fractionner l''apport en plusieurs petites doses plutôt que de tout
répandre en une fois, et éviter d''épandre juste avant une averse.
', NULL, 25),
      (v_chapitre_id, 'Simulation : choisir le bon engrais', 9, 'interactif', '{
  "widget": "familles-engrais",
  "consigne": "La simulation te propose une culture, un type de sol et une saison, et te laisse choisir parmi plusieurs formules NPK et plusieurs dates d''épandage. Tu récoltes à la fin, et elle te montre le rendement obtenu, l''engrais parti dans la rivière et ce que tout cela a coûté. Recommence en changeant un seul paramètre à la fois pour comprendre lequel pèse le plus."
}', NULL, 10),
      (v_chapitre_id, 'Quiz du chapitre 12', 10, 'quiz', '{
  "titre": "Vérifie que tu as compris",
  "questions": [
    {
      "question": "Qu''est-ce que le complexe argilo-humique ?",
      "choix": [
        "Un engrais chimique",
        "L''association de l''argile et de l''humus dans le sol",
        "Une machine agricole",
        "Un type de plante"
      ],
      "bonne": 1,
      "explication": "Il retient les éléments fertilisants et les restitue peu à peu à la plante, tout en donnant au sol sa structure."
    },
    {
      "question": "Quel élément donne aux plantes un feuillage vert et assure leur croissance ?",
      "choix": [
        "Le phosphore",
        "L''azote",
        "Le potassium",
        "Le calcium"
      ],
      "bonne": 1,
      "explication": "Un manque d''azote se voit immédiatement : les feuilles jaunissent et la plante reste petite."
    },
    {
      "question": "Quel élément favorise la floraison et la fructification ?",
      "choix": [
        "L''azote",
        "Le phosphore",
        "Le potassium",
        "Le soufre"
      ],
      "bonne": 1,
      "explication": "Le phosphore facilite aussi les échanges énergétiques dans les cellules végétales. Sans lui, la plante pousse mais ne donne pas de fruits."
    },
    {
      "question": "Sur un sac marqué NPK 15-11-20, que représente le nombre 11 ?",
      "choix": [
        "11 kg de phosphore pur pour 100 kg",
        "11 kg de $P_2O_5$ pour 100 kg",
        "11 % de la masse du sac",
        "11 kg de potassium pour 100 kg"
      ],
      "bonne": 1,
      "explication": "C''est le piège de l''exercice : les deuxième et troisième nombres sont des teneurs en oxydes, pas en éléments purs. Il faut convertir."
    },
    {
      "question": "Quelle masse d''azote contient 2,5 kg d''un engrais 15-11-20 ?",
      "choix": [
        "0,375 kg",
        "0,15 kg",
        "1,5 kg",
        "0,12 kg"
      ],
      "bonne": 0,
      "explication": "$m_N = 15 \\times \\frac{2{,}5}{100} = 0{,}375$ kg. Pour l''azote, aucune conversion n''est nécessaire."
    },
    {
      "question": "Par quel coefficient multiplie-t-on pour passer de $P_2O_5$ au phosphore pur ?",
      "choix": [
        "0,436",
        "0,830",
        "2",
        "1,42"
      ],
      "bonne": 0,
      "explication": "$\\frac{2M_P}{M_{P_2O_5}} = \\frac{62}{142} = 0{,}436$. Pour le potassium, le coefficient vaut 0,830."
    },
    {
      "question": "Que devient l''engrais répandu en excès ?",
      "choix": [
        "Il est stocké par la plante pour plus tard",
        "Il est lessivé et pollue les rivières et les nappes",
        "Il disparaît dans l''air",
        "Il reste indéfiniment dans le sol"
      ],
      "bonne": 1,
      "explication": "Les nitrates en excès rendent l''eau impropre à la consommation et font proliférer les algues, qui étouffent la vie des cours d''eau."
    }
  ]
}', NULL, 5);

    RAISE NOTICE '% : 10 leçons ajoutées au chapitre 12, Les engrais.', v_nom;
  END LOOP;
END $ch1$;
