-- ---------------------------------------------------------------------------
-- M'Andal — Chimie, classes de Première
-- Chapitre 13 : Action d'un acide sur un métal
-- Module 3 : Oxydoréduction — 8 leçons
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
    WHERE programme_id = v_programme_id AND ordre = 13;

    IF v_chapitre_id IS NULL THEN
      INSERT INTO public.chapitres (programme_id, titre, ordre, niveau)
      VALUES (v_programme_id, 'Action d''un acide sur un métal', 13, 'Module 3 : Oxydoréduction')
      RETURNING id INTO v_chapitre_id;
      RAISE NOTICE '% : chapitre 13 créé.', v_nom;
    END IF;

    -- Les leçons. Si le chapitre en a déjà, on passe son tour sans rien toucher.
    SELECT count(*) INTO v_deja FROM public.concepts WHERE chapitre_id = v_chapitre_id;
    IF v_deja > 0 THEN
      RAISE NOTICE '% : le chapitre 13 a déjà ses % leçons, je n''y touche pas.', v_nom, v_deja;
      CONTINUE;
    END IF;

    INSERT INTO public.concepts
      (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes) VALUES
      (v_chapitre_id, 'Quand un acide attaque un métal', 1, 'texte', '
### Trois mots de vocabulaire d''abord

Une **solution** est un mélange homogène d''une substance en faible quantité, le
**soluté**, avec une substance en grande quantité, le **solvant**.

Une solution est dite **aqueuse** lorsque le solvant est l''eau.

Une solution est dite **ionique** lorsqu''elle contient des ions. Une telle
solution **conduit le courant électrique**. Et retiens ceci, qui sert souvent :
toute solution aqueuse est **électriquement neutre**, car sa charge totale est
nulle.

### L''expérience fondatrice

Verse de l''acide chlorhydrique dilué sur de la poudre d''aluminium, dans un tube
à essai. Il se passe trois choses :

1. un **dégagement gazeux** apparaît aussitôt ;
2. le **tube chauffe** — tu le sens à la main ;
3. le métal **disparaît** peu à peu.

Recommence avec de la limaille de fer, puis avec de la grenaille de zinc : même
résultat. Recommence avec de l''acide sulfurique dilué : même résultat encore.

### Les métaux qui résistent

Maintenant essaie avec le **cuivre**, l''**argent**, le **mercure**, l''**or** ou
le **platine**. Il ne se passe **rien**.

C''est pour cela qu''on fait des bijoux en or et en argent, et non en zinc : ils
ne sont attaqués ni par les acides ni par l''air.

Retiens les deux listes, elles tombent chaque année :

| Attaqués par les acides dilués | Non attaqués |
| --- | --- |
| aluminium Al, fer Fe, zinc Zn, magnésium Mg | cuivre Cu, argent Ag, mercure Hg, or Au, platine Pt |

### Ce qui se passe vraiment

Au cours de chacune de ces réactions, il y a **transfert d''électrons du métal
vers les ions hydronium de l''acide**. C''est cela, une oxydoréduction. Le gaz
qui se dégage est du **dihydrogène**, et le métal disparu est devenu un **ion
métallique** dissous.

---

**Exercice corrigé**

*Si nous versons 10 g de mercure dans un verre transparent d''acide
chlorhydrique, que se passe-t-il ? Le mélange pourra-t-il s''homogénéiser ? On
donne la densité du mercure $d = 13{,}6$.*

**Correction.** Le mercure n''est **pas attaqué** par l''acide chlorhydrique :
aucune réaction chimique n''a lieu.
Sa densité valant 13,6, il est beaucoup plus dense que la solution d''acide,
dont la masse volumique est proche de celle de l''eau. Le mercure descend donc
simplement **au fond du verre** et y reste.
Le mélange ne pourra **pas** s''homogénéiser : il n''y a ni réaction, ni
dissolution.
', NULL, 22),
      (v_chapitre_id, 'Simulation : quel métal l''acide attaque-t-il ?', 2, 'interactif', '{
  "widget": "acide-metal",
  "consigne": "Choisis un métal dans le portoir, verse l''acide chlorhydrique ou l''acide sulfurique dilué, et observe. Avec l''aluminium, le fer, le zinc ou le magnésium, le gaz monte et le métal fond à vue d''œil. Avec le cuivre, l''argent ou l''or, rien ne bouge. Approche ensuite la bûchette enflammée de l''orifice du tube : la détonation te prouve que le gaz est bien du dihydrogène."
}', NULL, 10),
      (v_chapitre_id, 'Écrire l''équation : les demi-équations', 3, 'texte', '
Une équation d''oxydoréduction ne s''écrit pas d''un seul jet. On écrit **deux
demi-équations**, puis on les additionne membre à membre après les avoir
multipliées pour que les électrons s''annulent.

### Le cas de l''aluminium

$$Al \longrightarrow Al^{3+} + 3e^- \qquad (\times 2)$$
$$2H_3O^+ + 2e^- \longrightarrow H_2 + 2H_2O \qquad (\times 3)$$

L''aluminium cède 3 électrons, l''ion hydronium en capte 2. Pour que tout
s''annule il faut 6 électrons de part et d''autre : on multiplie la première par
2 et la seconde par 3.

$$\boxed{\;2Al + 6H_3O^+ \longrightarrow 2Al^{3+} + 3H_2 + 6H_2O\;}$$

### Le cas du fer

$$Fe \longrightarrow Fe^{2+} + 2e^-$$
$$2H_3O^+ + 2e^- \longrightarrow H_2 + 2H_2O$$

Ici les électrons s''annulent déjà, pas besoin de multiplier.

$$\boxed{\;Fe + 2H_3O^+ \longrightarrow Fe^{2+} + H_2 + 2H_2O\;}$$

### Le cas du zinc

$$Zn \longrightarrow Zn^{2+} + 2e^-$$
$$2H_3O^+ + 2e^- \longrightarrow H_2 + 2H_2O$$
$$\boxed{\;Zn + 2H_3O^+ \longrightarrow Zn^{2+} + H_2 + 2H_2O\;}$$

### Les ions spectateurs

Où sont passés les ions chlorure $Cl^-$ de l''acide chlorhydrique ? Nulle part :
ils n''apparaissent dans aucune des équations.

Un **ion spectateur** est un ion qui, bien qu''étant dans le milieu
réactionnel, **ne subit aucune transformation** du début à la fin de la
réaction. Les ions $Cl^-$ et $SO_4^{2-}$ sont des ions spectateurs.

C''est précisément pour cela que l''acide chlorhydrique et l''acide sulfurique
donnent le même résultat : seul l''ion $H_3O^+$ travaille, et il est commun aux
deux.

---

**Exercice corrigé**

*On verse sur un clou de fer de masse 1,2 g un volume $V = 2{,}5$ cm³ d''une
solution molaire d''acide chlorhydrique. Calcule la masse de fer ayant réagi et
le volume de dihydrogène dégagé. On donne $M(Fe) = 56$ g/mol et
$V_m = 24$ L/mol.*

**Correction.**
$$n_{H_3O^+} = C \times V = 1 \times 2{,}5 \times 10^{-3} = 2{,}5 \times 10^{-3} \text{ mol}$$
D''après l''équation, une mole de fer consomme deux moles d''ions hydronium :
$$n_{Fe} = \frac{n_{H_3O^+}}{2} = 1{,}25 \times 10^{-3} \text{ mol}$$
$$m_{Fe} = 1{,}25 \times 10^{-3} \times 56 = 0{,}07 \text{ g}$$
Le clou pesait 1,2 g : le **fer est en excès**, c''est l''acide qui limite.
$$n_{H_2} = n_{Fe} = 1{,}25 \times 10^{-3} \text{ mol}$$
$$V_{H_2} = 1{,}25 \times 10^{-3} \times 24 = 0{,}03 \text{ L} = 30 \text{ cm³}$$
', NULL, 25),
      (v_chapitre_id, 'Simulation : équilibrer par les demi-équations', 4, 'interactif', '{
  "widget": "redox-metal",
  "consigne": "Choisis le métal et l''acide, puis construis l''équation-bilan toi-même : la simulation te laisse écrire les deux demi-équations et cherche pour toi le coefficient qui annule les électrons. Vérifie ensuite ton résultat sur le décompte des charges et des atomes, et regarde les ions spectateurs rester immobiles pendant que les autres réagissent."
}', NULL, 10),
      (v_chapitre_id, 'Identifier les produits : les tests', 5, 'texte', '
Une équation sans preuve expérimentale ne vaut rien. Voici comment on démontre
que les produits annoncés sont bien ceux qui se forment.

### Le gaz : le test à la bûchette

Approche une **bûchette d''allumette enflammée** de l''orifice du tube à essai.
Il se produit une **détonation** — un petit *pop* sec.

C''est la preuve que le gaz dégagé est du **dihydrogène**.

### Les ions métalliques : le test à la soude

Prélève un peu de la solution finale, filtre-la, puis ajoute goutte à goutte une
solution d''**hydroxyde de sodium**, appelée aussi **soude**. Un précipité
apparaît, et sa couleur trahit l''ion présent.

- Dans le tube qui contenait l''**aluminium** : précipité **blanc**, l''hydroxyde
d''aluminium $Al(OH)_3$. Il est **soluble dans un excès de soude** et
**insoluble dans l''ammoniac**. Preuve de la présence des ions $Al^{3+}$.
- Dans le tube qui contenait le **fer** : précipité **vert**, l''hydroxyde de
fer II $Fe(OH)_2$. Preuve des ions $Fe^{2+}$. Laissé à l''air, il devient
$Fe(OH)_3$ couleur rouille.
- Dans le tube qui contenait le **zinc** : précipité **blanc**, l''hydroxyde de
zinc $Zn(OH)_2$. Il est **soluble dans un excès de soude ET dans l''ammoniac**.
Preuve des ions $Zn^{2+}$.

### Comment départager les trois précipités blancs

$Al^{3+}$, $Zn^{2+}$ et $Mg^{2+}$ donnent tous un précipité blanc. On les
sépare ainsi :

| Ion | Excès de soude | Ammoniac |
| --- | --- | --- |
| $Al^{3+}$ | se dissout | reste |
| $Zn^{2+}$ | se dissout | se dissout |
| $Mg^{2+}$ | se dissout | — |

Deux tests successifs suffisent à identifier l''ion. C''est le type de
raisonnement qu''on attend de toi en épreuve pratique.

---

**Exercice corrigé**

*Fouda veut identifier trois lames $L_1$, $L_2$ et $L_3$. Il les plonge
respectivement dans trois flacons $F_1$, $F_2$ et $F_3$ d''acide sulfurique peu
concentré. Aucune réaction ne se produit dans $F_3$. Il ajoute ensuite de la
soude dans $F_1$ et $F_2$ : précipité vert dans $F_2$, précipité blanc dans
$F_1$. Que peut-il conclure ?*

**Correction.**
*Lame $L_3$.* Aucune réaction : le métal n''est pas attaqué par l''acide. C''est
donc l''**argent** — ou un autre métal de la liste des non attaqués.
*Lame $L_2$.* Le précipité est **vert**, donc $Fe(OH)_2$, donc la solution
contient des ions $Fe^{2+}$ : la lame $L_2$ est en **fer**.
*Lame $L_1$.* Le précipité est **blanc** : ce peut être l''aluminium, le
magnésium ou le zinc, dont les cations donnent tous un précipité blanc.
Pour trancher, il doit ajouter un **excès de soude**, puis de l''**ammoniac**,
et comparer avec le tableau ci-dessus.
', NULL, 25),
      (v_chapitre_id, 'Figure : reconnaître un ion métallique à la soude', 6, 'figure', '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 540 300" width="540" height="300">
<rect width="540" height="300" fill="#ffffff"/>
<text x="270" y="24" text-anchor="middle" font-size="14" font-weight="700" fill="#0f172a">Reconnaître un ion métallique à la soude</text>
<text x="270" y="42" text-anchor="middle" font-size="10" fill="#64748b">on verse goutte à goutte une solution d&apos;hydroxyde de sodium et on regarde le précipité</text>

<rect x="24" y="52" width="492" height="22" fill="#1e293b"/>
<text x="34" y="67" font-size="10" font-weight="700" fill="#ffffff">ION</text>
<text x="130" y="67" font-size="10" font-weight="700" fill="#ffffff">COULEUR EN SOLUTION</text>
<text x="262" y="67" font-size="10" font-weight="700" fill="#ffffff">AVEC LA SOUDE</text>
<text x="360" y="67" font-size="10" font-weight="700" fill="#ffffff">PARTICULARITÉ</text>

<rect x="24" y="74" width="492" height="26" fill="#ffffff"/>
<text x="34" y="92" font-size="11" font-weight="700" fill="#0f172a">Aluminium</text>
<rect x="130" y="81" width="14" height="14" rx="3" fill="#f8fafc" stroke="#94a3b8" stroke-width="0.8"/>
<text x="150" y="92" font-size="10" fill="#475569">incolore</text>
<text x="262" y="92" font-size="10" font-weight="700" fill="#0f172a">précipité blanc</text>
<text x="360" y="92" font-size="9" fill="#64748b">soluble dans un excès de soude, insoluble dans l''ammoniac</text>
<rect x="24" y="100" width="492" height="26" fill="#f1f5f9"/>
<text x="34" y="118" font-size="11" font-weight="700" fill="#0f172a">Zinc</text>
<rect x="130" y="107" width="14" height="14" rx="3" fill="#f8fafc" stroke="#94a3b8" stroke-width="0.8"/>
<text x="150" y="118" font-size="10" fill="#475569">incolore</text>
<text x="262" y="118" font-size="10" font-weight="700" fill="#0f172a">précipité blanc</text>
<text x="360" y="118" font-size="9" fill="#64748b">soluble dans un excès de soude ET dans l''ammoniac</text>
<rect x="24" y="126" width="492" height="26" fill="#ffffff"/>
<text x="34" y="144" font-size="11" font-weight="700" fill="#0f172a">Magnésium</text>
<rect x="130" y="133" width="14" height="14" rx="3" fill="#f8fafc" stroke="#94a3b8" stroke-width="0.8"/>
<text x="150" y="144" font-size="10" fill="#475569">incolore</text>
<text x="262" y="144" font-size="10" font-weight="700" fill="#0f172a">précipité blanc</text>
<text x="360" y="144" font-size="9" fill="#64748b">soluble dans un excès de soude</text>
<rect x="24" y="152" width="492" height="26" fill="#f1f5f9"/>
<text x="34" y="170" font-size="11" font-weight="700" fill="#0f172a">Cuivre II</text>
<rect x="130" y="159" width="14" height="14" rx="3" fill="#3b82f6" stroke="#94a3b8" stroke-width="0.8"/>
<text x="150" y="170" font-size="10" fill="#1e3a8a">bleue</text>
<text x="262" y="170" font-size="10" font-weight="700" fill="#0f172a">précipité bleu</text>
<text x="360" y="170" font-size="9" fill="#64748b">&#8212;</text>
<rect x="24" y="178" width="492" height="26" fill="#ffffff"/>
<text x="34" y="196" font-size="11" font-weight="700" fill="#0f172a">Fer II</text>
<rect x="130" y="185" width="14" height="14" rx="3" fill="#86efac" stroke="#94a3b8" stroke-width="0.8"/>
<text x="150" y="196" font-size="10" fill="#14532d">verdâtre très pâle</text>
<text x="262" y="196" font-size="10" font-weight="700" fill="#0f172a">précipité vert</text>
<text x="360" y="196" font-size="9" fill="#64748b">devient Fe(OH)&#8323; rouille à l''air</text>
<rect x="24" y="204" width="492" height="26" fill="#f1f5f9"/>
<text x="34" y="222" font-size="11" font-weight="700" fill="#0f172a">Fer III</text>
<rect x="130" y="211" width="14" height="14" rx="3" fill="#c2410c" stroke="#94a3b8" stroke-width="0.8"/>
<text x="150" y="222" font-size="10" fill="#7c2d12">rouille</text>
<text x="262" y="222" font-size="10" font-weight="700" fill="#0f172a">précipité rouille</text>
<text x="360" y="222" font-size="9" fill="#64748b">&#8212;</text>
<rect x="24" y="230" width="492" height="26" fill="#ffffff"/>
<text x="34" y="248" font-size="11" font-weight="700" fill="#0f172a">Manganèse II</text>
<rect x="130" y="237" width="14" height="14" rx="3" fill="#fbcfe8" stroke="#94a3b8" stroke-width="0.8"/>
<text x="150" y="248" font-size="10" fill="#831843">rose très pâle</text>
<text x="262" y="248" font-size="10" font-weight="700" fill="#0f172a">précipité blanc</text>
<text x="360" y="248" font-size="9" fill="#64748b">devient MnO&#8322; brun à l''air</text>
<text x="270" y="288" text-anchor="middle" font-size="10" fill="#64748b">les trois précipités blancs se départagent par leur solubilité dans un excès de soude ou dans l&apos;ammoniac</text>
</svg>', NULL, 5),
      (v_chapitre_id, 'Simulation : le laboratoire d''identification des ions', 7, 'interactif', '{
  "widget": "tests-ions",
  "consigne": "Une solution inconnue t''attend dans le bécher. Ajoute la soude goutte à goutte, regarde le précipité se former, note sa couleur. S''il est blanc, poursuis : ajoute un excès de soude, puis de l''ammoniac, et observe ce qui se dissout. Quand tu crois savoir, annonce ton ion : la simulation te dit si tu as raison et retrace la chaîne de déductions."
}', NULL, 10),
      (v_chapitre_id, 'Quiz du chapitre 13', 8, 'quiz', '{
  "titre": "Vérifie que tu as compris",
  "questions": [
    {
      "question": "Quels métaux l''acide chlorhydrique dilué attaque-t-il ?",
      "choix": [
        "L''or et l''argent",
        "L''aluminium, le fer, le zinc et le magnésium",
        "Tous les métaux",
        "Aucun métal"
      ],
      "bonne": 1,
      "explication": "Le cuivre, l''argent, le mercure, l''or et le platine résistent. C''est pourquoi on fait les bijoux avec ces métaux-là."
    },
    {
      "question": "Quel gaz se dégage quand un acide attaque un métal ?",
      "choix": [
        "Le dioxyde de carbone",
        "Le dihydrogène",
        "Le dioxygène",
        "Le chlore"
      ],
      "bonne": 1,
      "explication": "On le prouve en approchant une bûchette enflammée : il se produit une petite détonation."
    },
    {
      "question": "Qu''est-ce qu''un ion spectateur ?",
      "choix": [
        "Un ion qui accélère la réaction",
        "Un ion présent dans le milieu mais qui ne subit aucune transformation",
        "Un ion coloré",
        "Un ion qui disparaît"
      ],
      "bonne": 1,
      "explication": "Les ions $Cl^-$ et $SO_4^{2-}$ sont spectateurs. C''est pourquoi l''acide chlorhydrique et l''acide sulfurique donnent le même résultat."
    },
    {
      "question": "Quelle est l''équation-bilan de l''action de l''acide sur l''aluminium ?",
      "choix": [
        "$Al + H_3O^+ \\rightarrow Al^{3+} + H_2$",
        "$2Al + 6H_3O^+ \\rightarrow 2Al^{3+} + 3H_2 + 6H_2O$",
        "$Al + 3H_2O \\rightarrow Al(OH)_3$",
        "$Al + Cl^- \\rightarrow AlCl$"
      ],
      "bonne": 1,
      "explication": "L''aluminium cède 3 électrons, l''ion hydronium en capte 2 : il faut 6 électrons de part et d''autre, d''où les coefficients 2 et 3."
    },
    {
      "question": "On ajoute de la soude à une solution : un précipité vert apparaît. Quel ion est présent ?",
      "choix": [
        "$Al^{3+}$",
        "$Fe^{2+}$",
        "$Zn^{2+}$",
        "$Cu^{2+}$"
      ],
      "bonne": 1,
      "explication": "C''est l''hydroxyde de fer II, $Fe(OH)_2$. Laissé à l''air, il devient $Fe(OH)_3$ couleur rouille."
    },
    {
      "question": "Comment distingue-t-on $Al^{3+}$ de $Zn^{2+}$, qui donnent tous deux un précipité blanc ?",
      "choix": [
        "Par la couleur de la solution",
        "Par l''ammoniac : $Zn(OH)_2$ s''y dissout, $Al(OH)_3$ non",
        "Par le goût",
        "On ne peut pas les distinguer"
      ],
      "bonne": 1,
      "explication": "Les deux précipités se dissolvent dans un excès de soude. C''est l''ammoniac qui les départage."
    },
    {
      "question": "Pourquoi une solution ionique conduit-elle le courant électrique ?",
      "choix": [
        "Parce qu''elle est chaude",
        "Parce qu''elle contient des ions, porteurs de charge mobiles",
        "Parce qu''elle est colorée",
        "Parce qu''elle contient de l''eau"
      ],
      "bonne": 1,
      "explication": "Les ions se déplacent sous l''effet du champ électrique. L''eau pure, elle, conduit très mal."
    }
  ]
}', NULL, 5);

    RAISE NOTICE '% : 8 leçons ajoutées au chapitre 13, Action d''un acide sur un métal.', v_nom;
  END LOOP;
END $ch1$;
