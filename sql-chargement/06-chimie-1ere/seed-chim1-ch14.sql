-- ---------------------------------------------------------------------------
-- M'Andal — Chimie, classes de Première
-- Chapitre 14 : Couple oxydant-réducteur et classification électrochimique
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
    WHERE programme_id = v_programme_id AND ordre = 14;

    IF v_chapitre_id IS NULL THEN
      INSERT INTO public.chapitres (programme_id, titre, ordre, niveau)
      VALUES (v_programme_id, 'Couple oxydant-réducteur et classification électrochimique', 14, 'Module 3 : Oxydoréduction')
      RETURNING id INTO v_chapitre_id;
      RAISE NOTICE '% : chapitre 14 créé.', v_nom;
    END IF;

    -- Les leçons. Si le chapitre en a déjà, on passe son tour sans rien toucher.
    SELECT count(*) INTO v_deja FROM public.concepts WHERE chapitre_id = v_chapitre_id;
    IF v_deja > 0 THEN
      RAISE NOTICE '% : le chapitre 14 a déjà ses % leçons, je n''y touche pas.', v_nom, v_deja;
      CONTINUE;
    END IF;

    INSERT INTO public.concepts
      (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes) VALUES
      (v_chapitre_id, 'Les cinq définitions à connaître par cœur', 1, 'texte', '
Ce sont les cinq définitions les plus rentables du programme. Elles valent des
points dans presque toutes les épreuves, et tout le reste du module repose
dessus.

> **Oxydation** : réaction chimique au cours de laquelle une espèce chimique
> **perd** des électrons.

> **Réduction** : réaction chimique au cours de laquelle une espèce chimique
> **gagne** des électrons.

> **Oxydant** : espèce chimique qui **capte** des électrons.

> **Réducteur** : espèce chimique qui **cède** des électrons.

> **Oxydoréduction** : réaction de transfert d''électrons au cours de laquelle
> il se produit simultanément l''oxydation du réducteur et la réduction de
> l''oxydant.

### Le piège, et il est partout

Relis la dernière définition. C''est le **réducteur** qui est **oxydé**, et
l''**oxydant** qui est **réduit**. Pas l''inverse. Les sujets d''examen
retournent la phrase exprès pour voir si tu suis.

### Un moyen de ne plus se tromper

Un **oxydant** se fait réduire : il **gagne** des électrons.

Pense à « **OXYDANT = capte** ». Celui qui porte le nom capte, celui qui le
subit perd. Ou retiens la formule que les élèves se transmettent :
« l''oxydant prend, le réducteur donne ».

### Un point essentiel

L''oxydation et la réduction sont **toujours simultanées**. Il est impossible
qu''une espèce perde des électrons sans qu''une autre les récupère : les
électrons ne restent jamais libres en solution. C''est pour cela qu''on écrit
toujours **deux** demi-équations.

---

**Exercice corrigé**

*Vrai ou faux : « la réaction d''équation $Fe \rightarrow Fe^{2+} + 2e^-$ est
une réduction. »*

**Correction.** **Faux**. Le fer **perd** deux électrons : c''est une
**oxydation**. Le fer joue donc ici le rôle de **réducteur**.
', NULL, 20),
      (v_chapitre_id, 'Simulation : qui prend, qui donne', 2, 'interactif', '{
  "widget": "oxydant-reducteur",
  "consigne": "La simulation te présente une demi-équation et te demande deux choses : s''agit-il d''une oxydation ou d''une réduction, et l''espèce de gauche est-elle oxydante ou réductrice ? Les électrons sont dessinés, tu les vois passer d''un côté à l''autre. Enchaîne les cas jusqu''à ce que tu répondes sans réfléchir : c''est un réflexe à installer, pas un raisonnement à refaire."
}', NULL, 10),
      (v_chapitre_id, 'La notion de couple oxydant-réducteur', 3, 'texte', '
### Deux expériences avec le même élément

**Première expérience.** Plonge un fil de **zinc** dans une solution de sulfate
de cuivre $(Cu^{2+} + SO_4^{2-})$. Le fil se couvre d''un dépôt rouge, et la
couleur bleue pâlit.

$$Zn \longrightarrow Zn^{2+} + 2e^- \qquad \text{oxydation}$$
$$Cu^{2+} + 2e^- \longrightarrow Cu \qquad \text{réduction}$$
$$\boxed{\;Zn + Cu^{2+} \longrightarrow Zn^{2+} + Cu\;}$$

Ici, l''ion $Cu^{2+}$ **capte** des électrons : il est **oxydant**.

**Deuxième expérience.** Plonge un fil de **cuivre** dans une solution de
nitrate d''argent $(Ag^+ + NO_3^-)$. Le fil se couvre d''un dépôt gris
d''argent, et la solution bleuit.

$$Cu \longrightarrow Cu^{2+} + 2e^- \qquad \text{oxydation}$$
$$Ag^+ + e^- \longrightarrow Ag \qquad (\times 2)$$
$$\boxed{\;Cu + 2Ag^+ \longrightarrow Cu^{2+} + 2Ag\;}$$

Ici, le métal $Cu$ **cède** des électrons : il est **réducteur**.

### La conclusion

L''élément cuivre a joué les deux rôles. Sous forme d''ion $Cu^{2+}$ il est
oxydant ; sous forme de métal $Cu$ il est réducteur. On regroupe donc les deux
formes sur un même schéma :

$$Cu^{2+} + 2e^- \rightleftharpoons Cu$$
$$\underbrace{Cu^{2+}}_{\text{oxydant}} \qquad \underbrace{Cu}_{\text{réducteur}}$$

L''ion $Cu^{2+}$ et le métal $Cu$ constituent un **couple oxydant-réducteur**,
noté $Cu^{2+}/Cu$.

**L''ordre compte** : l''oxydant s''écrit toujours **en premier**, au numérateur.
Écrire $Cu/Cu^{2+}$ est une faute.

On dit que $Cu^{2+}$ et $Cu$ sont **oxydant et réducteur conjugués**.

La double flèche signifie que la transformation peut s''effectuer dans un sens
comme dans l''autre, selon les réactifs en présence.

### La généralisation

À tout métal $M$ correspond un cation naturel $M^{n+}$. Ces deux espèces
forment le couple $M^{n+}/M$, de demi-équation :

$$M^{n+} + ne^- \rightleftharpoons M$$

---

**Exercice corrigé**

*Écris les demi-équations des couples $Mg^{2+}/Mg$, $Hg^{2+}/Hg$ et
$Sn^{2+}/Sn$.*

**Correction.**
$$Mg^{2+} + 2e^- \rightleftharpoons Mg$$
$$Hg^{2+} + 2e^- \rightleftharpoons Hg$$
$$Sn^{2+} + 2e^- \rightleftharpoons Sn$$
Dans les trois cas, le nombre d''électrons est égal à la charge du cation.
', NULL, 25),
      (v_chapitre_id, 'Simulation : construire un couple', 4, 'interactif', '{
  "widget": "couple-redox",
  "consigne": "Choisis un métal, plonge-le dans la solution d''un autre, et regarde : parfois un dépôt se forme, parfois rien ne se passe. Dans chaque cas la simulation écrit les deux demi-équations et t''indique lequel des deux éléments joue l''oxydant et lequel le réducteur. Fais l''expérience inverse ensuite : tu verras qu''un même élément change de rôle selon la forme sous laquelle il se trouve."
}', NULL, 10),
      (v_chapitre_id, 'La classification et la règle du gamma', 5, 'texte', '
### Classer les couples

Reprends les deux équations suivantes, qui sont vraies :

$$Zn + Fe^{2+} \longrightarrow Zn^{2+} + Fe$$
$$Fe + Cu^{2+} \longrightarrow Fe^{2+} + Cu$$

Les réactions **inverses** sont impossibles : on n''a jamais vu du fer
déplacer du zinc. Ces deux faits suffisent à ranger les trois couples.

Classement des formes **oxydées** par pouvoir oxydant croissant :
$$Zn^{2+} < Fe^{2+} < Cu^{2+}$$

Classement des formes **métalliques** par pouvoir réducteur croissant :
$$Cu < Fe < Zn$$

Remarque que les deux classements sont **inverses** l''un de l''autre. C''est
logique : plus un oxydant est fort, plus son réducteur conjugué est faible.

Des études expérimentales permettent d''étendre ce classement à tous les métaux,
et de montrer que le couple $H_3O^+/H_2$ se place **entre** $Cu^{2+}/Cu$ et
$Pb^{2+}/Pb$. C''est exactement ce qui explique le chapitre 13 : les métaux
situés **en dessous** du couple $H_3O^+/H_2$ sont attaqués par les acides, ceux
situés **au-dessus** ne le sont pas.

### À quoi sert la classification

Elle permet deux choses :

1. **prévoir** si une réaction d''oxydoréduction est possible entre un oxydant et
un réducteur donnés ;
2. **écrire** l''équation-bilan de cette réaction.

### La règle du gamma

Une réaction d''oxydoréduction spontanée s''écrit toujours sous la forme :

$$\text{oxydant fort} + \text{réducteur fort} \longrightarrow \text{oxydant faible} + \text{réducteur faible}$$

Place les couples sur une échelle verticale, les oxydants à gauche, les
réducteurs à droite, les plus oxydants en haut. Trace alors la lettre grecque
**gamma** ($\gamma$) : elle part de l''oxydant le plus fort, descend, et arrive
sur le réducteur le plus fort.

Le sens de la flèche donne le sens de la réaction, et l''équation-bilan se lit
directement.

Pour $Cu^{2+}/Cu$ et $Zn^{2+}/Zn$ :

$$Cu^{2+} + Zn \longrightarrow Zn^{2+} + Cu$$

$Cu^{2+}$ est bien l''oxydant le plus fort, $Zn$ le réducteur le plus fort.

---

**Exercice corrigé**

*Parmi ces substances, lesquelles sont capables d''oxyder les ions bromure
$Br^-$ ? On donne $E°(Br_2/Br^-) = 1{,}07$ V, $E°(H_3O^+/H_2) = 0$ V,
$E°(Cl_2/Cl^-) = 1{,}36$ V, $E°(Ni^{2+}/Ni) = -0{,}23$ V,
$E°(MnO_4^-/Mn^{2+}) = 1{,}51$ V.*

**Correction.** Pour oxyder $Br^-$, il faut un oxydant **plus fort** que
$Br_2$, c''est-à-dire un couple de potentiel **supérieur** à 1,07 V.

- $H_3O^+$ : 0 V, trop faible. **Non**.
- $Cl_2$ : 1,36 V > 1,07 V. **Oui**.
- $Ni^{2+}$ : $-0{,}23$ V, trop faible. **Non**.
- $MnO_4^-$ : 1,51 V > 1,07 V. **Oui**.

Les équations correspondantes :
$$Cl_2 + 2Br^- \longrightarrow 2Cl^- + Br_2$$
$$2MnO_4^- + 10Br^- + 16H_3O^+ \longrightarrow 2Mn^{2+} + 5Br_2 + 24H_2O$$
', NULL, 25),
      (v_chapitre_id, 'Figure : la règle du gamma', 6, 'figure', '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 540 310" width="540" height="310">
<rect width="540" height="310" fill="#ffffff"/>
<text x="270" y="22" text-anchor="middle" font-size="14" font-weight="700" fill="#0f172a">La règle du gamma : lire une réaction sur l&apos;échelle</text>

<line x1="270" y1="48" x2="270" y2="250" stroke="#334155" stroke-width="2"/>
<polygon points="270,42 264,54 276,54" fill="#334155"/>
<text x="282" y="46" font-size="11" font-weight="700" fill="#334155">E° (V)</text>

<text x="150" y="70" text-anchor="end" font-size="11" font-weight="700" fill="#0f172a">OXYDANTS</text>
<text x="390" y="70" text-anchor="start" font-size="11" font-weight="700" fill="#0f172a">RÉDUCTEURS</text>
<text x="150" y="86" text-anchor="end" font-size="9" fill="#64748b">pouvoir oxydant croissant &#8593;</text>
<text x="390" y="86" text-anchor="start" font-size="9" fill="#64748b">pouvoir réducteur croissant &#8595;</text>

<g font-size="12" font-weight="700" fill="#0f172a">
  <line x1="250" y1="112" x2="290" y2="112" stroke="#94a3b8" stroke-width="1.2" stroke-dasharray="3 3"/>
  <text x="244" y="116" text-anchor="end">Cu²⁺</text>
  <text x="296" y="116">Cu</text>
  <text x="206" y="116" text-anchor="end" font-size="10" font-weight="400" fill="#64748b">+0,34</text>

  <line x1="250" y1="166" x2="290" y2="166" stroke="#94a3b8" stroke-width="1.2" stroke-dasharray="3 3"/>
  <text x="244" y="170" text-anchor="end">H₃O⁺</text>
  <text x="296" y="170">H₂</text>
  <text x="206" y="170" text-anchor="end" font-size="10" font-weight="400" fill="#64748b">0,00</text>

  <line x1="250" y1="220" x2="290" y2="220" stroke="#94a3b8" stroke-width="1.2" stroke-dasharray="3 3"/>
  <text x="244" y="224" text-anchor="end">Zn²⁺</text>
  <text x="296" y="224">Zn</text>
  <text x="206" y="224" text-anchor="end" font-size="10" font-weight="400" fill="#64748b">&#8722;0,76</text>
</g>

<path d="M244 112 C 196 112, 196 224, 296 224" fill="none" stroke="#dc2626" stroke-width="2.6"/>
<polygon points="296,224 284,218 284,230" fill="#dc2626"/>
<text x="150" y="172" text-anchor="middle" font-size="26" font-weight="700" fill="#dc2626">&#947;</text>

<rect x="36" y="258" width="468" height="40" fill="#fef2f2" stroke="#dc2626" stroke-width="1.2" rx="6"/>
<text x="270" y="275" text-anchor="middle" font-size="12" font-weight="700" fill="#991b1b">Cu²⁺ + Zn &#8594; Zn²⁺ + Cu</text>
<text x="270" y="291" text-anchor="middle" font-size="10" fill="#334155">l&apos;oxydant le plus fort réagit avec le réducteur le plus fort &#8212; le gamma se lit toujours dans ce sens</text>
</svg>', NULL, 5),
      (v_chapitre_id, 'Simulation : la règle du gamma', 7, 'interactif', '{
  "widget": "regle-gamma",
  "consigne": "Choisis deux couples et pose-les sur l''échelle : la simulation trace le gamma à ta place et écrit l''équation-bilan qui en découle. Essaie ensuite de faire la réaction dans l''autre sens, celui que le gamma interdit : rien ne se produira, et la simulation t''expliquera pourquoi. Ajoute un troisième couple au milieu et regarde quelles réactions deviennent possibles."
}', NULL, 10),
      (v_chapitre_id, 'Quiz du chapitre 14', 8, 'quiz', '{
  "titre": "Vérifie que tu as compris",
  "questions": [
    {
      "question": "Qu''est-ce qu''une oxydation ?",
      "choix": [
        "Une réaction où une espèce gagne des électrons",
        "Une réaction où une espèce perd des électrons",
        "Une réaction avec du dioxygène obligatoirement",
        "Une réaction qui dégage de la chaleur"
      ],
      "bonne": 1,
      "explication": "Attention au piège classique : c''est le réducteur qui est oxydé, et l''oxydant qui est réduit."
    },
    {
      "question": "Un oxydant est une espèce qui :",
      "choix": [
        "cède des électrons",
        "capte des électrons",
        "ne réagit pas",
        "se dissout"
      ],
      "bonne": 1,
      "explication": "L''oxydant prend, le réducteur donne. L''oxydant est donc réduit au cours de la réaction."
    },
    {
      "question": "Comment note-t-on correctement le couple formé par l''ion cuivre II et le cuivre métal ?",
      "choix": [
        "$Cu/Cu^{2+}$",
        "$Cu^{2+}/Cu$",
        "$Cu^{2+} + Cu$",
        "$Cu^{2+}-Cu$"
      ],
      "bonne": 1,
      "explication": "L''oxydant s''écrit toujours en premier. Écrire $Cu/Cu^{2+}$ est compté comme une faute."
    },
    {
      "question": "Quelle est la demi-équation du couple $Al^{3+}/Al$ ?",
      "choix": [
        "$Al^{3+} \\rightleftharpoons Al + 3e^-$",
        "$Al^{3+} + 3e^- \\rightleftharpoons Al$",
        "$Al + 3e^- \\rightleftharpoons Al^{3+}$",
        "$Al^{3+} + e^- \\rightleftharpoons Al$"
      ],
      "bonne": 1,
      "explication": "Le nombre d''électrons est égal à la charge du cation, et l''oxydant est du côté qui reçoit les électrons."
    },
    {
      "question": "Que dit la règle du gamma ?",
      "choix": [
        "L''oxydant le plus faible réagit avec le réducteur le plus faible",
        "L''oxydant le plus fort réagit avec le réducteur le plus fort",
        "Tous les couples réagissent entre eux",
        "Rien ne réagit en dessous de 0 V"
      ],
      "bonne": 1,
      "explication": "Et le produit est l''oxydant faible plus le réducteur faible. Tracé sur l''échelle, le gamma donne directement le sens de la réaction."
    },
    {
      "question": "Si $E°(Cu^{2+}/Cu) = 0{,}34$ V et $E°(Zn^{2+}/Zn) = -0{,}76$ V, quelle réaction est spontanée ?",
      "choix": [
        "$Zn^{2+} + Cu \\rightarrow Zn + Cu^{2+}$",
        "$Cu^{2+} + Zn \\rightarrow Zn^{2+} + Cu$",
        "Aucune",
        "Les deux"
      ],
      "bonne": 1,
      "explication": "$Cu^{2+}$ est l''oxydant le plus fort car son potentiel est le plus élevé, et $Zn$ est le réducteur le plus fort."
    },
    {
      "question": "Pourquoi les acides n''attaquent-ils pas le cuivre ?",
      "choix": [
        "Parce que le cuivre est trop dur",
        "Parce que le couple $Cu^{2+}/Cu$ est au-dessus du couple $H_3O^+/H_2$",
        "Parce que le cuivre est coloré",
        "Parce qu''il n''y a pas d''ions"
      ],
      "bonne": 1,
      "explication": "Le cuivre métal est un réducteur plus faible que le dihydrogène : il ne peut pas céder ses électrons aux ions hydronium."
    }
  ]
}', NULL, 5);

    RAISE NOTICE '% : 8 leçons ajoutées au chapitre 14, Couple oxydant-réducteur et classification électrochimique.', v_nom;
  END LOOP;
END $ch1$;
