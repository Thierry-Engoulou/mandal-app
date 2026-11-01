-- ---------------------------------------------------------------------------
-- M'Andal — Chimie, classes de Première
-- Chapitre 17 : Les dosages d'oxydoréduction
-- Module 3 : Oxydoréduction — 10 leçons
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
    WHERE programme_id = v_programme_id AND ordre = 17;

    IF v_chapitre_id IS NULL THEN
      INSERT INTO public.chapitres (programme_id, titre, ordre, niveau)
      VALUES (v_programme_id, 'Les dosages d''oxydoréduction', 17, 'Module 3 : Oxydoréduction')
      RETURNING id INTO v_chapitre_id;
      RAISE NOTICE '% : chapitre 17 créé.', v_nom;
    END IF;

    -- Les leçons. Si le chapitre en a déjà, on passe son tour sans rien toucher.
    SELECT count(*) INTO v_deja FROM public.concepts WHERE chapitre_id = v_chapitre_id;
    IF v_deja > 0 THEN
      RAISE NOTICE '% : le chapitre 17 a déjà ses % leçons, je n''y touche pas.', v_nom, v_deja;
      CONTINUE;
    END IF;

    INSERT INTO public.concepts
      (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes) VALUES
      (v_chapitre_id, 'Le principe du dosage', 1, 'texte', '
### Ce qu''on cherche

**Doser** une solution, c''est déterminer sa **concentration molaire** en une
espèce chimique donnée.

### L''idée

On fait réagir la solution à doser, dont on ignore la concentration, avec une
solution dont on connaît la concentration exactement. En suivant la réaction,
on repère l''instant où les deux réactifs ont exactement été consommés l''un par
l''autre. Une simple proportion donne alors la concentration cherchée.

### Les deux solutions

La solution **à doser** est celle dont on cherche la concentration. On en
prélève un volume **précis** à la pipette jaugée, et on le verse dans le
bécher.

La solution **dosante**, ou titrante, est celle dont on connaît la
concentration. Elle se place dans la **burette**.

**La règle à ne jamais oublier :** on place **toujours la solution dosante dans
la burette**, et la solution à doser dans le bécher. Les sujets te demandent
régulièrement de justifier ce choix.

### Le point d''équivalence

Le **point d''équivalence** est atteint lorsque les réactifs sont dans les
**proportions stœchiométriques** du milieu réactionnel. À cet instant précis,
aucun des deux n''est en excès.

On le repère par un **changement de teinte** du milieu.

### Les deux conditions d''un bon dosage

Un bon dosage d''oxydoréduction repose sur une réaction qui doit être :

1. **totale** — d''où le critère $\Delta E > 0{,}34$ V du chapitre précédent ;
2. **rapide** — sinon on dépasse l''équivalence avant que la réaction ait eu le
temps de se faire.

---

**Exercice corrigé**

*Quelle solution est-il conseillé de verser dans la burette lors d''un dosage,
la solution à doser ou la solution dosante ? Pourquoi ?*

**Correction.** On place la **solution dosante** dans la burette.
La raison est pratique : la burette sert à verser un volume que l''on lit au
fur et à mesure, goutte à goutte, jusqu''au changement de teinte. C''est donc
elle qui doit contenir le réactif dont on contrôle l''ajout. La solution à
doser, elle, est prélevée une fois pour toutes à la pipette jaugée, qui donne
un volume beaucoup plus précis qu''une burette.
', NULL, 22),
      (v_chapitre_id, 'Simulation : qu''est-ce que l''équivalence ?', 2, 'interactif', '{
  "widget": "point-equivalence",
  "consigne": "Deux colonnes te montrent ce qu''il reste de chaque réactif dans le bécher pendant que tu verses. Avant l''équivalence, le réactif dosé est encore là et il consomme tout ce qui arrive. Après, c''est le réactif dosant qui s''accumule. Entre les deux, un point unique où les deux colonnes tombent à zéro en même temps : c''est l''équivalence, et c''est le seul instant où la proportion stœchiométrique est respectée."
}', NULL, 10),
      (v_chapitre_id, 'Le matériel et le protocole', 3, 'texte', '
### Le matériel

| Instrument | À quoi il sert |
| --- | --- |
| **burette graduée** | contient la solution dosante, permet de lire le volume versé |
| **pipette jaugée** | prélève un volume précis de la solution à doser |
| **bécher** ou erlenmeyer | reçoit la solution pipetée |
| **agitateur magnétique** | homogénéise le mélange pendant toute l''opération |
| **barreau aimanté** | placé au fond du bécher, il tourne et agite |
| **potence** | soutient la burette |

### Le protocole, dans l''ordre

1. Verser dans la burette graduée l''une des deux solutions, **de préférence la
solution dosante**.
2. Prélever à l''aide d''une pipette un volume précis de la seconde solution,
celle à doser.
3. Placer le barreau magnétique au fond du bécher.
4. Verser la solution pipetée dans le bécher.
5. Faire couler progressivement la solution de la burette dans le bécher, tout
en homogénéisant à l''agitateur magnétique, **jusqu''au changement persistant de
teinte**.
6. Déterminer à l''aide des graduations de la burette le volume de solution
dosante qui a permis d''atteindre le point d''équivalence.
7. Déterminer par calcul la concentration de la solution dosée.

### Un mot sur la sécurité

Pour prélever une solution de permanganate de potassium à la pipette, on
utilise toujours une **poire d''aspiration**. On ne pipette **jamais à la
bouche** : le permanganate est corrosif, et cette règle vaut pour tous les
réactifs du laboratoire.

---

**Exercice corrigé**

*On veut préparer 250 mL d''une solution de permanganate de potassium $KMnO_4$
de concentration $C_0 = 2{,}0 \times 10^{-2}$ mol/L à partir de cristaux.
Quelle masse de cristaux faut-il peser ? Décris le mode opératoire.*
*On donne $M(K) = 39{,}1$, $M(Mn) = 54{,}9$, $M(O) = 16$ g/mol.*

**Correction.**
$$M(KMnO_4) = 39{,}1 + 54{,}9 + 4 \times 16 = 158 \text{ g/mol}$$
$$C_0 = \frac{m_0}{M_0 V} \;\Longrightarrow\; m_0 = C_0 M_0 V$$
$$m_0 = 2{,}0 \times 10^{-2} \times 158 \times 0{,}25 = 0{,}79 \text{ g}$$

*Mode opératoire.* On pèse 0,79 g de $KMnO_4$ à la balance, on le verse dans
une **fiole jaugée de 250 mL**, puis on complète avec de l''eau distillée jusqu''au
trait de jauge en homogénéisant.

La verrerie adaptée ici est la **fiole jaugée**, parce que c''est elle qui donne
un volume précis. Un bécher gradué ne conviendrait pas.
', NULL, 22),
      (v_chapitre_id, 'Figure : le dispositif de dosage', 4, 'figure', '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 540 330" width="540" height="330">
<rect width="540" height="330" fill="#ffffff"/>
<text x="270" y="22" text-anchor="middle" font-size="14" font-weight="700" fill="#0f172a">Le dispositif de dosage</text>

<rect x="110" y="44" width="14" height="250" fill="#94a3b8"/>
<rect x="80" y="286" width="150" height="12" fill="#64748b"/>
<text x="76" y="62" font-size="10" fill="#334155" text-anchor="end">potence</text>
<line x1="80" y1="56" x2="106" y2="56" stroke="#334155" stroke-width="1"/>

<rect x="124" y="92" width="34" height="12" fill="#64748b"/>

<rect x="196" y="56" width="30" height="150" fill="#f8fafc" stroke="#334155" stroke-width="1.8" rx="3"/>
<rect x="198" y="70" width="26" height="110" fill="#c084fc" opacity="0.75"/>
<g stroke="#334155" stroke-width="0.8">
  <line x1="196" y1="80" x2="206" y2="80"/><line x1="196" y1="100" x2="206" y2="100"/>
  <line x1="196" y1="120" x2="206" y2="120"/><line x1="196" y1="140" x2="206" y2="140"/>
  <line x1="196" y1="160" x2="206" y2="160"/><line x1="196" y1="180" x2="206" y2="180"/>
</g>
<polygon points="196,206 226,206 215,226 207,226" fill="#f8fafc" stroke="#334155" stroke-width="1.6"/>
<rect x="205" y="226" width="12" height="10" fill="#334155"/>
<line x1="211" y1="236" x2="211" y2="252" stroke="#c084fc" stroke-width="2.4" stroke-dasharray="3 5"/>

<text x="246" y="74" font-size="11" font-weight="700" fill="#7e22ce">BURETTE GRADUÉE</text>
<text x="246" y="90" font-size="10" fill="#334155">la solution DOSANTE</text>
<text x="246" y="105" font-size="10" fill="#64748b">ici le permanganate de potassium</text>
<text x="246" y="120" font-size="10" fill="#64748b">(K⁺ + MnO&#8324;⁻), violet</text>
<text x="246" y="140" font-size="10" font-weight="700" fill="#0f172a">on lit le volume versé</text>
<text x="246" y="155" font-size="10" fill="#64748b">à l&apos;équivalence</text>

<path d="M172 252 L250 252 L240 300 L182 300 Z" fill="#f8fafc" stroke="#334155" stroke-width="1.8"/>
<path d="M177 276 L245 276 L240 300 L182 300 Z" fill="#86efac" opacity="0.7"/>
<rect x="200" y="292" width="22" height="7" rx="3" fill="#475569"/>

<text x="286" y="258" font-size="11" font-weight="700" fill="#15803d">BÉCHER</text>
<text x="286" y="274" font-size="10" fill="#334155">la solution À DOSER</text>
<text x="286" y="289" font-size="10" fill="#64748b">prélevée à la pipette jaugée</text>
<text x="286" y="304" font-size="10" fill="#64748b">ici le sulfate de fer II (Fe²⁺ + SO&#8324;²⁻)</text>

<rect x="166" y="300" width="90" height="16" fill="#cbd5e1" stroke="#64748b" stroke-width="1.2" rx="3"/>
<text x="156" y="312" font-size="10" fill="#334155" text-anchor="end">agitateur</text>
<text x="156" y="324" font-size="10" fill="#334155" text-anchor="end">magnétique</text>
<text x="211" y="312" text-anchor="middle" font-size="8" fill="#334155">barreau aimanté au fond</text>

<rect x="286" y="40" width="222" height="52" fill="#fef2f2" stroke="#dc2626" stroke-width="1.2" rx="6"/>
<text x="296" y="58" font-size="11" font-weight="700" fill="#991b1b">LE POINT D&apos;ÉQUIVALENCE</text>
<text x="296" y="74" font-size="10" fill="#334155">une teinte violette persiste dans le bécher :</text>
<text x="296" y="87" font-size="10" fill="#334155">tous les ions Fe²⁺ ont réagi</text>
</svg>', NULL, 5),
      (v_chapitre_id, 'Simulation : monter un dosage', 5, 'interactif', '{
  "widget": "materiel-dosage",
  "consigne": "Prépare le poste de travail toi-même : choisis la verrerie, décide quelle solution va dans la burette et laquelle dans le bécher, pose le barreau aimanté. La simulation refuse les montages incorrects et t''explique pourquoi — par exemple si tu inverses les deux solutions, ou si tu prélèves au bécher gradué plutôt qu''à la pipette jaugée."
}', NULL, 10),
      (v_chapitre_id, 'Le dosage manganimétrique', 6, 'texte', '
C''est le dosage de référence du programme. On dose une solution de **sulfate de
fer II** par une solution de **permanganate de potassium**.

### Le montage

Dans la burette : la solution de permanganate de potassium
$(K^+ + MnO_4^-)$, violette, de concentration connue $C_0$. C''est l''**oxydant**.

Dans le bécher : la solution de sulfate de fer II $(Fe^{2+} + SO_4^{2-})$, de
concentration inconnue $C_r$, dont on a pipeté un volume $V_r$. C''est le
**réducteur**.

### L''équation du dosage

$$MnO_4^- + 8H_3O^+ + 5e^- \longrightarrow Mn^{2+} + 12H_2O \qquad \text{réduction}$$
$$Fe^{2+} \longrightarrow Fe^{3+} + e^- \qquad (\times 5) \qquad \text{oxydation}$$

$$\boxed{\;MnO_4^- + 5Fe^{2+} + 8H_3O^+ \longrightarrow Mn^{2+} + 5Fe^{3+} + 12H_2O\;}$$

### Le repérage de l''équivalence

Tant qu''il reste des ions $Fe^{2+}$ dans le bécher, chaque goutte de
permanganate versée est **décolorée** aussitôt : le violet disparaît.

À la première goutte en excès, il n''y a plus de $Fe^{2+}$ pour la consommer :
la solution prend une **teinte violacée persistante**. C''est l''équivalence.

Remarque l''élégance : aucun indicateur coloré n''est nécessaire. L''oxydant est
son propre indicateur.

### La relation à l''équivalence

$$\frac{n_{MnO_4^-}}{1} = \frac{n_{Fe^{2+}}}{5} \;\Longrightarrow\; n_{Fe^{2+}} = 5\,n_{MnO_4^-}$$

$$\boxed{\;C_r V_r = 5\,C_0 V_0\;}$$

où $C_0$ et $V_0$ se rapportent au permanganate, $C_r$ et $V_r$ au fer II.

Ces dosages à l''ion permanganate s''appellent aussi des **dosages
manganimétriques**.

---

**Exercice corrigé**

*On dose $V_r = 40$ mL d''une solution de sulfate de fer II par une solution de
permanganate de potassium à $C_0 = 2 \times 10^{-2}$ mol/L. L''équivalence est
atteinte après avoir versé $V_0 = 20$ mL. Calcule $C_r$.*

**Correction.**
$$C_r = \frac{5\,C_0 V_0}{V_r} = \frac{5 \times 2 \times 10^{-2} \times 20 \times 10^{-3}}{40 \times 10^{-3}}$$
$$C_r = 5 \times 10^{-2} \text{ mol/L}$$
', NULL, 25),
      (v_chapitre_id, 'Simulation : le dosage manganimétrique', 7, 'interactif', '{
  "widget": "dosage-redox",
  "consigne": "Ouvre le robinet de la burette et regarde chaque goutte violette se décolorer dans le bécher. Approche-toi de l''équivalence goutte à goutte : à un moment, la couleur reste. Note le volume versé, calcule la concentration, et compare avec la valeur réelle que la simulation te révèle ensuite. Recommence en dépassant exprès l''équivalence pour voir de combien tu te trompes."
}', NULL, 10),
      (v_chapitre_id, 'La généralisation et l''iodométrie', 8, 'texte', '
### La formule qui marche pour tous les dosages

Pour réaliser un dosage d''oxydoréduction, trois étapes sont toujours
nécessaires :

1. écrire l''équation-bilan de la réaction du dosage ;
2. repérer le changement de teinte à l''équivalence ;
3. déduire la concentration cherchée par la relation à l''équivalence :

$$\boxed{\;n_0\,C_0 V_0 = n_r\,C_r V_r\;}$$

où $n_0$ et $n_r$ sont respectivement les **nombres de moles d''électrons**
figurant dans chacune des demi-équations, pour une mole d''oxydant et une mole
de réducteur.

Vérifie sur le cas précédent : le permanganate capte 5 électrons, donc
$n_0 = 5$ ; l''ion fer II en cède 1, donc $n_r = 1$. La relation donne
$5\,C_0 V_0 = C_r V_r$ — c''est bien ce qu''on avait trouvé.

Cette formule unique remplace tous les cas particuliers. Apprends-la, elle vaut
plusieurs exercices.

### L''iodométrie

C''est l''autre grand dosage du programme. On dose une solution de **diiode** par
une solution de **thiosulfate de sodium**.

$$I_2 + 2e^- \longrightarrow 2I^- \qquad \text{réduction}$$
$$2S_2O_3^{2-} \longrightarrow S_4O_6^{2-} + 2e^- \qquad \text{oxydation}$$
$$\boxed{\;I_2 + 2S_2O_3^{2-} \longrightarrow 2I^- + S_4O_6^{2-}\;}$$

Dans la burette : le thiosulfate de sodium. Dans le bécher : le diiode.

### Pourquoi il faut un indicateur ici

La solution de diiode passe du **brun** à l''**incolore**. Ce changement est à
peine perceptible à l''œil nu, surtout en fin de dosage où la solution est déjà
très pâle.

On ajoute donc quelques gouttes d''**empois d''amidon** dans le bécher. L''amidon
donne au diiode une teinte **bleu foncé** très visible, qui disparaît d''un coup
à l''équivalence.

C''est la différence avec le dosage manganimétrique, où le permanganate se
suffisait à lui-même.

---

**Exercice corrigé**

*On dose $V_0 = 20$ mL d''une solution de diiode par une solution de thiosulfate
de sodium à $C_r = 0{,}1$ mol/L. L''équivalence est atteinte après avoir versé
$V_r = 16$ mL. Calcule la concentration $C_0$ de la solution de diiode.*

**Correction.** D''après l''équation-bilan, une mole de diiode consomme deux
moles d''ions thiosulfate :
$$\frac{n_{S_2O_3^{2-}}}{2} = \frac{n_{I_2}}{1} \;\Longrightarrow\; n_{I_2} = \frac{1}{2}\,n_{S_2O_3^{2-}}$$
$$C_0 V_0 = \frac{1}{2}\,C_r V_r$$
$$C_0 = \frac{1}{2} \times \frac{0{,}1 \times 16 \times 10^{-3}}{20 \times 10^{-3}} = 4 \times 10^{-2} \text{ mol/L}$$
', NULL, 25),
      (v_chapitre_id, 'Simulation : l''iodométrie et l''empois d''amidon', 9, 'interactif', '{
  "widget": "iodometrie",
  "consigne": "Dose le diiode par le thiosulfate, d''abord sans empois d''amidon : tu verras à quel point le virage du brun à l''incolore est difficile à saisir. Ajoute ensuite quelques gouttes d''empois et recommence : la solution devient bleu foncé et la couleur s''efface d''un coup à l''équivalence. Compare les deux volumes que tu as lus et mesure l''erreur que l''indicateur t''a évitée."
}', NULL, 10),
      (v_chapitre_id, 'Quiz du chapitre 17', 10, 'quiz', '{
  "titre": "Vérifie que tu as compris",
  "questions": [
    {
      "question": "Que signifie doser une solution ?",
      "choix": [
        "La diluer",
        "Déterminer sa concentration molaire en une espèce donnée",
        "La chauffer",
        "La filtrer"
      ],
      "bonne": 1,
      "explication": "On la fait réagir avec une solution de concentration connue et on repère le point d''équivalence."
    },
    {
      "question": "Quelle solution place-t-on dans la burette ?",
      "choix": [
        "La solution à doser",
        "La solution dosante",
        "Peu importe",
        "De l''eau distillée"
      ],
      "bonne": 1,
      "explication": "C''est elle dont on contrôle l''ajout goutte à goutte. La solution à doser est prélevée une fois pour toutes à la pipette jaugée."
    },
    {
      "question": "Quelles sont les deux conditions d''un bon dosage d''oxydoréduction ?",
      "choix": [
        "Chaude et concentrée",
        "Totale et rapide",
        "Lente et colorée",
        "Diluée et froide"
      ],
      "bonne": 1,
      "explication": "Totale, d''où le critère $\\Delta E > 0{,}34$ V ; rapide, sinon on dépasse l''équivalence avant que la réaction se fasse."
    },
    {
      "question": "Comment repère-t-on l''équivalence dans un dosage manganimétrique ?",
      "choix": [
        "Par un dégagement gazeux",
        "Par une teinte violacée persistante",
        "Par un précipité blanc",
        "Par un changement de température"
      ],
      "bonne": 1,
      "explication": "Tant qu''il reste des ions $Fe^{2+}$, chaque goutte violette est décolorée. À l''équivalence, la couleur reste."
    },
    {
      "question": "Quelle est la relation à l''équivalence pour le dosage du fer II par le permanganate ?",
      "choix": [
        "$C_0 V_0 = C_r V_r$",
        "$C_r V_r = 5 C_0 V_0$",
        "$5 C_r V_r = C_0 V_0$",
        "$C_r V_r = 2 C_0 V_0$"
      ],
      "bonne": 1,
      "explication": "Le permanganate capte 5 électrons et l''ion fer II n''en cède qu''un : il en faut cinq pour un."
    },
    {
      "question": "Que vaut la relation générale à l''équivalence ?",
      "choix": [
        "$C_0 V_0 = C_r V_r$",
        "$n_0 C_0 V_0 = n_r C_r V_r$",
        "$n_0 + C_0 V_0 = n_r + C_r V_r$",
        "$C_0/V_0 = C_r/V_r$"
      ],
      "bonne": 1,
      "explication": "$n_0$ et $n_r$ sont les nombres d''électrons de chaque demi-équation. Cette formule unique couvre tous les dosages."
    },
    {
      "question": "Pourquoi ajoute-t-on de l''empois d''amidon dans un dosage iodométrique ?",
      "choix": [
        "Pour accélérer la réaction",
        "Parce que le virage du brun à l''incolore est à peine perceptible",
        "Pour colorer le thiosulfate",
        "Pour neutraliser l''acide"
      ],
      "bonne": 1,
      "explication": "L''amidon donne au diiode une teinte bleu foncé bien visible, qui disparaît d''un coup à l''équivalence."
    }
  ]
}', NULL, 5);

    RAISE NOTICE '% : 10 leçons ajoutées au chapitre 17, Les dosages d''oxydoréduction.', v_nom;
  END LOOP;
END $ch1$;
