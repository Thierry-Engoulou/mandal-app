-- ---------------------------------------------------------------------------
-- M'Andal — Chimie, classes de Première
-- Chapitre 18 : Électrolyse, corrosion et protection des métaux
-- Module 3 : Oxydoréduction — 11 leçons
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
    WHERE programme_id = v_programme_id AND ordre = 18;

    IF v_chapitre_id IS NULL THEN
      INSERT INTO public.chapitres (programme_id, titre, ordre, niveau)
      VALUES (v_programme_id, 'Électrolyse, corrosion et protection des métaux', 18, 'Module 3 : Oxydoréduction')
      RETURNING id INTO v_chapitre_id;
      RAISE NOTICE '% : chapitre 18 créé.', v_nom;
    END IF;

    -- Les leçons. Si le chapitre en a déjà, on passe son tour sans rien toucher.
    SELECT count(*) INTO v_deja FROM public.concepts WHERE chapitre_id = v_chapitre_id;
    IF v_deja > 0 THEN
      RAISE NOTICE '% : le chapitre 18 a déjà ses % leçons, je n''y touche pas.', v_nom, v_deja;
      CONTINUE;
    END IF;

    INSERT INTO public.concepts
      (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes) VALUES
      (v_chapitre_id, 'L''électrolyse : définition et principes', 1, 'texte', '
Dans une pile, une réaction **spontanée** produit du courant. L''électrolyse,
c''est exactement l''inverse : on **impose** un courant pour forcer une réaction
qui ne se ferait jamais toute seule.

### La définition

L''**électrolyse** est l''ensemble des réactions chimiques qui s''effectuent dans
une solution lors du **passage du courant électrique**.

L''appareil où elle se déroule s''appelle un **électrolyseur**.

### Les deux électrodes

Au cours du passage du courant, il se produit **toujours** :

- une **oxydation à l''anode** ;
- une **réduction à la cathode**.

**Comment les reconnaître ?** L''**anode** est l''électrode reliée à la borne
**positive** du générateur. La cathode est reliée à la borne négative.

Un moyen de ne plus se tromper : **anode** et **oxydation** commencent toutes
deux par une voyelle ; **cathode** et **réduction** par une consonne.

### Quelles espèces réagissent

Les espèces qui réagissent aux électrodes peuvent provenir du **soluté**, du
**solvant**, ou des **électrodes** elles-mêmes. Il faut donc toutes les
recenser avant de prévoir quoi que ce soit.

Ensuite, la règle est la même que partout :

> L''**oxydant le plus fort** est réduit à la **cathode**, pendant que le
> **réducteur le plus fort** est oxydé à l''**anode**.

### La tension à appliquer

Ces réactions se déclenchent dès que la tension appliquée est **supérieure ou
égale à la f.é.m. de l''électrolyseur**. En dessous, rien ne se passe.

### Une honnêteté nécessaire

La connaissance des potentiels d''oxydoréduction permet de prévoir les réactions
aux électrodes. Mais à cause du phénomène de **surtension**, ces prévisions ne
sont **pas toujours vérifiées** par l''expérience.

Retiens cette nuance : elle t''évitera de t''acharner si ton calcul ne correspond
pas au résultat de laboratoire.

---

**Exercice corrigé**

*Pour qu''une électrolyse se produise avec les couples $Cu^{2+}/Cu$ et
$Br_2/Br^-$, quelle condition la tension doit-elle remplir ? Montrer que
l''équation $Cu^{2+} + 2Br^- \rightarrow Br_2 + Cu$ correspond bien à une
oxydoréduction forcée.*

**Correction.**
*La tension.* Il faut que la différence de potentiel entre les deux couples
soit franchie, donc que le générateur délivre
$$E > E°(Cu^{2+}/Cu) - E°(Br^-/Br)$$

*La réaction forcée.* Appliquons la règle du gamma. $Br_2$ est l''oxydant le
plus fort (1,07 V contre 0,34 V), $Cu$ le réducteur le plus fort. La réaction
**spontanée** serait donc
$$Br_2 + Cu \longrightarrow Cu^{2+} + 2Br^-$$
Or l''énoncé donne la réaction **inverse**. Elle ne peut donc pas se produire
spontanément : c''est bien une oxydoréduction **forcée**, qui exige l''apport
d''énergie électrique d''un générateur.
', NULL, 25),
      (v_chapitre_id, 'Simulation : forcer une réaction', 2, 'interactif', '{
  "widget": "electrolyse",
  "consigne": "Monte l''électrolyseur, choisis la solution, et augmente la tension du générateur petit à petit. En dessous du seuil, rien ne bouge. Au-dessus, les électrodes se mettent à travailler : la simulation te montre quelle espèce est oxydée à l''anode, laquelle est réduite à la cathode, et pourquoi. Inverse les bornes du générateur et regarde les rôles s''échanger."
}', NULL, 10),
      (v_chapitre_id, 'L''électrolyse de l''eau', 3, 'texte', '
### Le montage

Les électrodes de l''électrolyseur sont en **platine**, métal inattaquable.
L''électrolyte est une solution aqueuse d''**acide sulfurique**. À partir d''une
tension $U_{AC} = 1{,}7$ V, on observe des dégagements gazeux aux deux
électrodes.

### Identifier les deux gaz

À la **cathode**, un gaz qui produit une **détonation** dès qu''on approche une
bûchette allumée : c''est le **dihydrogène** $H_2$.

À l''**anode**, un gaz qui **ravive l''incandescence** d''une bûchette : c''est le
**dioxygène** $O_2$.

### Les demi-équations

À la cathode, ce sont les ions hydronium $H_3O^+$ qui sont réduits, car ce
sont les seuls oxydants présents au départ :

$$2H_3O^+ + 2e^- \longrightarrow H_2 + 2H_2O$$

À l''anode, ce sont les molécules d''eau qui sont oxydées, car elles sont **plus
réductrices** que les ions $SO_4^{2-}$ :

$$3H_2O \longrightarrow \tfrac{1}{2}O_2 + 2H_3O^+ + 2e^-$$

$$\boxed{\;H_2O \longrightarrow H_2 + \tfrac{1}{2}O_2\;}$$

### La conclusion, et elle surprend

Cette électrolyse se réduit tout simplement à la **décomposition de l''eau**.
L''acide sulfurique n''est pas consommé : son rôle est seulement de **rendre la
solution conductrice**.

### Le résultat à retenir

Regarde les coefficients du bilan : une molécule d''eau donne une molécule de
dihydrogène et une demi-molécule de dioxygène. Donc

$$\boxed{\;V_{H_2} = 2\,V_{O_2}\;}$$

Le volume de dihydrogène dégagé est toujours **le double** de celui du
dioxygène formé simultanément. C''est visible à l''œil nu sur les deux tubes, et
c''est une question qui tombe souvent.

### Avec de la soude, le même résultat

Si l''on remplace l''acide sulfurique par une solution d''**hydroxyde de sodium**,
toujours avec des électrodes de platine :

$$\text{cathode :} \quad 2H_2O + 2e^- \longrightarrow H_2 + 2OH^-$$
$$\text{anode :} \quad 2OH^- \longrightarrow \tfrac{1}{2}O_2 + H_2O + 2e^-$$
$$H_2O \longrightarrow H_2 + \tfrac{1}{2}O_2$$

Même bilan. Acide ou base, l''électrolyse décompose l''eau, et l''électrolyte ne
sert qu''à conduire.

### Un cas où l''électrolyte réagit

Avec une solution de **chlorure d''étain II** $(Sn^{2+} + 2Cl^-)$, c''est
différent : ce sont les ions du soluté qui réagissent.

$$\text{cathode :} \quad Sn^{2+} + 2e^- \longrightarrow Sn$$
$$\text{anode :} \quad 2Cl^- \longrightarrow Cl_2 + 2e^-$$
$$\boxed{\;Sn^{2+} + 2Cl^- \longrightarrow Sn + Cl_2\;}$$

---

**Exercice corrigé**

*Au cours d''une électrolyse de l''eau, on recueille 60 cm³ de dihydrogène. Quel
volume de dioxygène a été formé dans le même temps ?*

**Correction.** D''après le bilan $H_2O \rightarrow H_2 + \frac{1}{2}O_2$ :
$$V_{H_2} = 2\,V_{O_2} \;\Longrightarrow\; V_{O_2} = \frac{60}{2} = 30 \text{ cm³}$$
', NULL, 28),
      (v_chapitre_id, 'Figure : l''électrolyse de l''eau', 4, 'figure', '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 540 320" width="540" height="320">
<rect width="540" height="320" fill="#ffffff"/>
<text x="270" y="22" text-anchor="middle" font-size="14" font-weight="700" fill="#0f172a">L&apos;électrolyse de l&apos;eau : deux fois plus de dihydrogène que de dioxygène</text>

<path d="M120 120 L420 120 L404 250 L136 250 Z" fill="#f8fafc" stroke="#334155" stroke-width="2"/>
<path d="M124 152 L416 152 L404 250 L136 250 Z" fill="#bfdbfe" opacity="0.6"/>
<text x="270" y="214" text-anchor="middle" font-size="11" font-weight="700" fill="#1e3a8a">solution d&apos;acide sulfurique</text>
<text x="270" y="230" text-anchor="middle" font-size="9" fill="#1e3a8a">elle ne sert qu&apos;à rendre l&apos;eau conductrice</text>

<rect x="176" y="96" width="34" height="86" fill="none" stroke="#334155" stroke-width="1.6"/>
<rect x="178" y="112" width="30" height="68" fill="#fca5a5" opacity="0.7"/>
<text x="193" y="146" text-anchor="middle" font-size="11" font-weight="700" fill="#7f1d1d">O&#8322;</text>
<text x="193" y="90" text-anchor="middle" font-size="10" font-weight="700" fill="#7f1d1d">dioxygène</text>
<text x="193" y="194" text-anchor="middle" font-size="9" fill="#64748b">1 volume</text>

<rect x="330" y="62" width="34" height="120" fill="none" stroke="#334155" stroke-width="1.6"/>
<rect x="332" y="78" width="30" height="102" fill="#86efac" opacity="0.7"/>
<text x="347" y="130" text-anchor="middle" font-size="11" font-weight="700" fill="#14532d">H&#8322;</text>
<text x="347" y="56" text-anchor="middle" font-size="10" font-weight="700" fill="#14532d">dihydrogène</text>
<text x="347" y="194" text-anchor="middle" font-size="9" font-weight="700" fill="#14532d">2 volumes</text>

<rect x="188" y="160" width="10" height="76" fill="#64748b"/>
<rect x="342" y="160" width="10" height="76" fill="#64748b"/>
<line x1="193" y1="160" x2="193" y2="120" stroke="#64748b" stroke-width="3"/>
<line x1="347" y1="160" x2="347" y2="120" stroke="#64748b" stroke-width="3"/>

<text x="140" y="268" font-size="11" font-weight="700" fill="#b91c1c">ANODE (+)</text>
<text x="140" y="282" font-size="9" fill="#334155">oxydation</text>
<text x="140" y="294" font-size="9" fill="#334155">3H&#8322;O &#8594; ½O&#8322; + 2H&#8323;O⁺ + 2e⁻</text>

<text x="400" y="268" font-size="11" font-weight="700" fill="#15803d">CATHODE (&#8722;)</text>
<text x="400" y="282" font-size="9" fill="#334155">réduction</text>
<text x="400" y="294" font-size="9" fill="#334155">2H&#8323;O⁺ + 2e⁻ &#8594; H&#8322; + 2H&#8322;O</text>

<line x1="193" y1="120" x2="193" y2="46" stroke="#334155" stroke-width="2"/>
<line x1="347" y1="120" x2="347" y2="46" stroke="#334155" stroke-width="2"/>
<line x1="193" y1="46" x2="246" y2="46" stroke="#334155" stroke-width="2"/>
<line x1="294" y1="46" x2="347" y2="46" stroke="#334155" stroke-width="2"/>

<line x1="252" y1="34" x2="252" y2="58" stroke="#334155" stroke-width="3"/>
<line x1="262" y1="40" x2="262" y2="52" stroke="#334155" stroke-width="1.6"/>
<line x1="272" y1="34" x2="272" y2="58" stroke="#334155" stroke-width="3"/>
<line x1="282" y1="40" x2="282" y2="52" stroke="#334155" stroke-width="1.6"/>
<line x1="246" y1="46" x2="252" y2="46" stroke="#334155" stroke-width="2"/>
<line x1="282" y1="46" x2="294" y2="46" stroke="#334155" stroke-width="2"/>
<text x="243" y="30" text-anchor="middle" font-size="12" font-weight="700" fill="#b91c1c">+</text>
<text x="291" y="30" text-anchor="middle" font-size="12" font-weight="700" fill="#15803d">&#8722;</text>
<text x="267" y="74" text-anchor="middle" font-size="10" fill="#64748b">générateur &#8212; U &#8805; 1,7 V</text>

<rect x="36" y="300" width="468" height="16" fill="#f1f5f9" rx="4"/>
<text x="270" y="312" text-anchor="middle" font-size="11" font-weight="700" fill="#0f172a">Bilan : H&#8322;O &#8594; H&#8322; + ½O&#8322;    donc    V(H&#8322;) = 2 &#215; V(O&#8322;)</text>
</svg>', NULL, 5),
      (v_chapitre_id, 'Simulation : électrolyser l''eau', 5, 'interactif', '{
  "widget": "electrolyse-eau",
  "consigne": "Allume le générateur et regarde les deux tubes se remplir. Celui du dihydrogène monte exactement deux fois plus vite que celui du dioxygène : arrête quand tu veux et vérifie le rapport. Remplace ensuite l''acide sulfurique par de la soude, puis par du chlorure d''étain : dans les deux premiers cas c''est l''eau qui se décompose, dans le dernier ce sont les ions du soluté qui réagissent."
}', NULL, 10),
      (v_chapitre_id, 'L''électrolyse à anode soluble', 6, 'texte', '
Jusqu''ici les électrodes étaient en platine, donc inertes. Que se passe-t-il si
l''électrode elle-même peut réagir ?

### Le montage

Les deux électrodes plongent dans une solution de **sulfate de cuivre**.
L''anode est en **cuivre brut**, la cathode en **cuivre raffiné**, c''est-à-dire
pur.

### Les observations

Pour une tension $U_{AC}$ **même infime**, on observe :

- l''**usure progressive de l''anode**, dont la partie immergée se ronge ;
- un **dépôt métallique rouge** à la cathode ;
- la **conservation de la teinte bleue** de la solution.

Ce troisième point est le plus instructif : la concentration en ions $Cu^{2+}$
ne change pas. Autant d''ions passent en solution à l''anode qu''il en disparaît à
la cathode.

### Les équations

$$\text{anode :} \quad Cu \longrightarrow Cu^{2+} + 2e^-$$
$$\text{cathode :} \quad Cu^{2+} + 2e^- \longrightarrow Cu$$
$$\boxed{\;Cu \longrightarrow Cu\;}$$

Une équation-bilan qui ne dit rien, et c''est précisément le point. Cette
électrolyse se résume à un **transport du cuivre de l''anode vers la cathode**.
Elle s''appelle l''**électrolyse à anode soluble**.

### Pourquoi c''est utile

Le cuivre brut contient des impuretés. Elles ne passent pas en solution, ou ne
se redéposent pas à la cathode : elles tombent au fond de la cuve. Le cuivre
qui arrive sur la cathode est donc **plus pur** que celui qui est parti de
l''anode.

Le principe est utilisé en industrie pour :

- l''**affinage des métaux** — c''est ainsi qu''on obtient le cuivre pur des
câbles électriques ;
- le **revêtement de dépôts métalliques** à la surface de certains objets —
c''est la galvanoplastie : chromage, nickelage, dorure des bijoux.

---

**Exercice corrigé**

*Vrai ou faux : « dans une électrolyse à anode soluble, le métal qui constitue
l''anode reste intact du début à la fin de la réaction. »*

**Correction.** **Faux**, et c''est même l''inverse. L''anode est **oxydée** : son
métal passe en solution sous forme d''ions, et l''électrode se ronge
progressivement. C''est précisément ce qui donne son nom à l''électrolyse : une
anode **soluble**. L''électrode qui grossit est la cathode.
', NULL, 25),
      (v_chapitre_id, 'Simulation : affiner le cuivre', 7, 'interactif', '{
  "widget": "anode-soluble",
  "consigne": "Lance l''électrolyse et regarde l''anode de cuivre brut maigrir tandis que la cathode s''épaissit. Observe la teinte bleue de la solution : elle ne change pas, puisque autant d''ions partent qu''il en arrive. Suis les impuretés : elles tombent au fond de la cuve au lieu de se déposer, et c''est ce qui rend le cuivre de la cathode plus pur que celui de départ."
}', NULL, 10),
      (v_chapitre_id, 'La corrosion et la protection des métaux', 8, 'texte', '
### La définition

La **corrosion** est la détérioration d''un métal par une **oxydation en
profondeur**.

Elle résulte de l''action **simultanée** de l''**eau** et du **dioxygène de
l''air** sur les métaux. Les deux sont nécessaires : du fer dans de l''eau
bouillie et désaérée ne rouille pas, et du fer dans de l''air parfaitement sec
non plus.

### Ce qui l''accélère

L''action est **accélérée par le chlorure de sodium**. C''est ce qui explique que
les régions humides et les **côtes littorales** soient propices au
développement de la rouille — une observation que tu peux vérifier toi-même à
Douala, à Limbé ou à Kribi.

### Le mécanisme, en deux étapes

**Première étape : formation des ions $Fe^{2+}$.**
$$Fe \longrightarrow Fe^{2+} + 2e^-$$

**Deuxième étape : formation des ions $Fe^{3+}$, puis de la rouille.**
$$Fe^{2+} \longrightarrow Fe^{3+} + e^-$$
$$Fe^{3+} + 3OH^- \longrightarrow Fe(OH)_3$$

D''où viennent les ions $OH^-$ ? Du dioxygène, qui est réduit :
$$\tfrac{1}{2}O_2 + H_2O + 2e^- \longrightarrow 2OH^-$$

Et voilà pourquoi l''air est indispensable : sans dioxygène, pas d''ions $OH^-$,
donc pas de rouille.

La couleur caractéristique de la rouille est celle du composé $Fe(OH)_3$, qui
se transforme ensuite en oxyde de fer III $Fe_2O_3$.

### Les méthodes de protection

Les métaux ferreux autres que l''inox doivent être protégés. Trois méthodes, de
la plus simple à la plus ingénieuse.

**1. Le recouvrement par une couche protectrice.** Peinture, vernis, graisses,
feuilles de matières plastiques. Simple et économique, mais la moindre rayure
ouvre une brèche.

**2. Le revêtement métallisé.** On dépose en surface un autre métal, par
électrolyse ou par immersion dans un bain métallique. Attention, le choix du
métal n''est pas libre : il doit s''agir de l''**aluminium** ou du **zinc**, car
ces métaux sont **plus réducteurs que le fer**. C''est la galvanisation.

**3. La protection cathodique, ou protection à anode sacrifiée.** On plaque
simplement un morceau de **zinc** sur la pièce à protéger. Le zinc, plus
réducteur, joue le rôle d''**anode** et subit l''oxydation en permanence ; la
pièce de fer joue le rôle de **cathode** et reste protégée.

C''est la méthode employée pour les **coques des navires et des bateaux**. On
remplace le bloc de zinc de temps en temps, et la coque, elle, ne rouille pas.

### Le fil conducteur de tout le module

Regarde ce que la protection cathodique a de beau : on utilise le classement
électrochimique du chapitre 14 pour sacrifier volontairement un métal et en
sauver un autre. Toute la chimie du module tient dans ce geste.

---

**Exercice corrigé**

*Pourquoi protège-t-on les coques de navires avec du zinc et non avec du
cuivre ?*

**Correction.** Il faut que le métal protecteur soit **plus réducteur** que le
fer, c''est-à-dire que son couple ait un potentiel **plus faible**.
$$E°(Zn^{2+}/Zn) = -0{,}76 \text{ V} \;<\; E°(Fe^{2+}/Fe) = -0{,}44 \text{ V}$$
Le zinc convient : c''est lui qui s''oxydera, pas le fer.
$$E°(Cu^{2+}/Cu) = +0{,}34 \text{ V} \;>\; E°(Fe^{2+}/Fe)$$
Le cuivre est **moins** réducteur que le fer. Le placer sur la coque
**aggraverait** la corrosion : c''est le fer qui jouerait le rôle d''anode et qui
se sacrifierait pour protéger le cuivre.
', NULL, 28),
      (v_chapitre_id, 'Figure : le mécanisme de la rouille', 9, 'figure', '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 540 300" width="540" height="300">
<rect width="540" height="300" fill="#ffffff"/>
<text x="270" y="22" text-anchor="middle" font-size="14" font-weight="700" fill="#0f172a">La rouille : il faut l&apos;eau ET le dioxygène</text>

<g transform="translate(0,40)">
  <rect x="24" y="0" width="150" height="130" fill="#f1f5f9" rx="8" stroke="#94a3b8" stroke-width="1.2"/>
  <text x="99" y="22" text-anchor="middle" font-size="11" font-weight="700" fill="#0f172a">eau SEULE</text>
  <rect x="54" y="48" width="90" height="26" fill="#94a3b8" rx="3"/>
  <text x="99" y="66" text-anchor="middle" font-size="10" font-weight="700" fill="#ffffff">fer intact</text>
  <text x="99" y="100" text-anchor="middle" font-size="22" fill="#16a34a">&#10003;</text>
  <text x="99" y="120" text-anchor="middle" font-size="10" fill="#15803d">pas de rouille</text>

  <rect x="195" y="0" width="150" height="130" fill="#f1f5f9" rx="8" stroke="#94a3b8" stroke-width="1.2"/>
  <text x="270" y="22" text-anchor="middle" font-size="11" font-weight="700" fill="#0f172a">air SEC</text>
  <rect x="225" y="48" width="90" height="26" fill="#94a3b8" rx="3"/>
  <text x="270" y="66" text-anchor="middle" font-size="10" font-weight="700" fill="#ffffff">fer intact</text>
  <text x="270" y="100" text-anchor="middle" font-size="22" fill="#16a34a">&#10003;</text>
  <text x="270" y="120" text-anchor="middle" font-size="10" fill="#15803d">pas de rouille</text>

  <rect x="366" y="0" width="150" height="130" fill="#fef2f2" rx="8" stroke="#dc2626" stroke-width="1.6"/>
  <text x="441" y="22" text-anchor="middle" font-size="11" font-weight="700" fill="#991b1b">EAU + AIR</text>
  <rect x="396" y="48" width="90" height="26" fill="#c2410c" rx="3"/>
  <text x="441" y="66" text-anchor="middle" font-size="10" font-weight="700" fill="#ffffff">fer rongé</text>
  <text x="441" y="100" text-anchor="middle" font-size="22" fill="#dc2626">&#10007;</text>
  <text x="441" y="120" text-anchor="middle" font-size="10" font-weight="700" fill="#991b1b">ROUILLE</text>
</g>

<text x="270" y="196" text-anchor="middle" font-size="11" font-weight="700" fill="#0f172a">le mécanisme, en trois temps</text>

<g font-size="11" fill="#334155">
  <rect x="36" y="206" width="468" height="20" fill="#f8fafc"/>
  <text x="48" y="220" font-weight="700" fill="#0f172a">1.</text>
  <text x="72" y="220">Fe &#8594; Fe²⁺ + 2e⁻</text>
  <text x="300" y="220" font-size="10" fill="#64748b">le fer s&apos;oxyde</text>

  <rect x="36" y="228" width="468" height="20" fill="#f1f5f9"/>
  <text x="48" y="242" font-weight="700" fill="#0f172a">2.</text>
  <text x="72" y="242">Fe²⁺ &#8594; Fe³⁺ + e⁻</text>
  <text x="300" y="242" font-size="10" fill="#64748b">puis il s&apos;oxyde encore</text>

  <rect x="36" y="250" width="468" height="20" fill="#f8fafc"/>
  <text x="48" y="264" font-weight="700" fill="#0f172a">3.</text>
  <text x="72" y="264">Fe³⁺ + 3OH⁻ &#8594; Fe(OH)&#8323;</text>
  <text x="300" y="264" font-size="10" font-weight="700" fill="#c2410c">la rouille, couleur rouille</text>
</g>

<text x="270" y="288" text-anchor="middle" font-size="10" fill="#64748b">les ions OH⁻ viennent du dioxygène réduit : ½O&#8322; + H&#8322;O + 2e⁻ &#8594; 2OH⁻ &#8212; sans air, pas d&apos;ions OH⁻, donc pas de rouille</text>
</svg>', NULL, 5),
      (v_chapitre_id, 'Simulation : faire rouiller, ou protéger', 10, 'interactif', '{
  "widget": "corrosion",
  "consigne": "Expose une pièce de fer à ce que tu veux : eau seule, air sec, eau et air, avec ou sans sel, et fais défiler le temps. La rouille apparaît ou n''apparaît pas, et la simulation écrit les équations correspondantes. Pose ensuite un bloc de zinc sur la pièce : il se ronge à sa place. Essaie avec du cuivre à la place du zinc et regarde la corrosion s''accélérer au lieu de s''arrêter."
}', NULL, 10),
      (v_chapitre_id, 'Quiz du chapitre 18', 11, 'quiz', '{
  "titre": "Vérifie que tu as compris",
  "questions": [
    {
      "question": "Que se passe-t-il à l''anode d''un électrolyseur ?",
      "choix": [
        "Une réduction",
        "Une oxydation",
        "Rien",
        "Une précipitation"
      ],
      "bonne": 1,
      "explication": "Anode et oxydation commencent toutes deux par une voyelle. L''anode est reliée à la borne positive du générateur."
    },
    {
      "question": "Dans l''électrolyse d''une solution d''acide sulfurique, à quoi sert l''acide ?",
      "choix": [
        "Il est décomposé",
        "Il rend seulement la solution conductrice",
        "Il produit le dioxygène",
        "Il protège les électrodes"
      ],
      "bonne": 1,
      "explication": "Le bilan se réduit à $H_2O \\rightarrow H_2 + \\frac{1}{2}O_2$ : c''est l''eau qui est décomposée, pas l''acide."
    },
    {
      "question": "Quel est le rapport entre les volumes des deux gaz dans l''électrolyse de l''eau ?",
      "choix": [
        "$V_{H_2} = V_{O_2}$",
        "$V_{H_2} = 2 V_{O_2}$",
        "$V_{O_2} = 2 V_{H_2}$",
        "$V_{H_2} = 4 V_{O_2}$"
      ],
      "bonne": 1,
      "explication": "Le bilan donne une molécule de $H_2$ pour une demi-molécule de $O_2$. C''est visible à l''œil nu sur les deux tubes."
    },
    {
      "question": "Dans une électrolyse à anode soluble, que devient l''anode ?",
      "choix": [
        "Elle reste intacte",
        "Elle se ronge progressivement",
        "Elle grossit",
        "Elle change de couleur"
      ],
      "bonne": 1,
      "explication": "Son métal passe en solution sous forme d''ions, et c''est la cathode qui grossit. Le principe sert à l''affinage des métaux."
    },
    {
      "question": "Quelles conditions sont nécessaires pour que le fer rouille ?",
      "choix": [
        "L''eau seule",
        "L''air sec seul",
        "L''eau et le dioxygène ensemble",
        "La chaleur"
      ],
      "bonne": 2,
      "explication": "Sans dioxygène, pas d''ions $OH^-$, donc pas de $Fe(OH)_3$. Le chlorure de sodium accélère le phénomène."
    },
    {
      "question": "Pourquoi protège-t-on les coques de navires avec du zinc ?",
      "choix": [
        "Parce que le zinc est moins cher",
        "Parce que le zinc est plus réducteur que le fer et s''oxyde à sa place",
        "Parce que le zinc est plus dur",
        "Parce que le zinc flotte"
      ],
      "bonne": 1,
      "explication": "C''est la protection à anode sacrifiée : le zinc joue le rôle d''anode et subit l''oxydation, la coque joue le rôle de cathode et reste protégée."
    },
    {
      "question": "Quel métal ne faut-il surtout pas utiliser pour revêtir le fer ?",
      "choix": [
        "Le zinc",
        "L''aluminium",
        "Le cuivre",
        "Aucun des trois"
      ],
      "bonne": 2,
      "explication": "Le cuivre est moins réducteur que le fer : c''est alors le fer qui se sacrifierait, et la corrosion serait aggravée."
    }
  ]
}', NULL, 5);

    RAISE NOTICE '% : 11 leçons ajoutées au chapitre 18, Électrolyse, corrosion et protection des métaux.', v_nom;
  END LOOP;
END $ch1$;
