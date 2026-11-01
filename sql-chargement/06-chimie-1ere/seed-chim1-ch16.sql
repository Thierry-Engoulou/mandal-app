-- ---------------------------------------------------------------------------
-- M'Andal — Chimie, classes de Première
-- Chapitre 16 : Demi-équations et équilibrage des réactions rédox
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
    WHERE programme_id = v_programme_id AND ordre = 16;

    IF v_chapitre_id IS NULL THEN
      INSERT INTO public.chapitres (programme_id, titre, ordre, niveau)
      VALUES (v_programme_id, 'Demi-équations et équilibrage des réactions rédox', 16, 'Module 3 : Oxydoréduction')
      RETURNING id INTO v_chapitre_id;
      RAISE NOTICE '% : chapitre 16 créé.', v_nom;
    END IF;

    -- Les leçons. Si le chapitre en a déjà, on passe son tour sans rien toucher.
    SELECT count(*) INTO v_deja FROM public.concepts WHERE chapitre_id = v_chapitre_id;
    IF v_deja > 0 THEN
      RAISE NOTICE '% : le chapitre 16 a déjà ses % leçons, je n''y touche pas.', v_nom, v_deja;
      CONTINUE;
    END IF;

    INSERT INTO public.concepts
      (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes) VALUES
      (v_chapitre_id, 'Établir une demi-équation en milieu acide', 1, 'texte', '
Jusqu''ici les demi-équations étaient faciles : $Zn \rightleftharpoons Zn^{2+} +
2e^-$ ne demande aucun effort. Mais que faire avec l''ion permanganate
$MnO_4^-$, qui donne l''ion $Mn^{2+}$ ? Il y a quatre oxygènes à gauche et aucun
à droite.

La réponse tient en une méthode de **cinq étapes**, à appliquer toujours dans
cet ordre. Apprends-la une fois, elle marchera sur tous les cas.

### La méthode

**1. L''élément principal.** Celui qui change de forme. On l''équilibre d''abord.

**2. L''oxygène, avec des molécules d''eau.** On ajoute autant de $H_2O$ qu''il
manque d''atomes d''oxygène, du côté qui en manque.

**3. L''hydrogène, avec des ions $H^+$.** On ajoute autant de $H^+$ qu''il
manque d''atomes d''hydrogène.

**4. On passe aux ions hydronium.** Chaque $H^+$ devient un $H_3O^+$, et on
compense en ajoutant autant de $H_2O$ **de l''autre côté**.

**5. Les charges, avec des électrons.** On compte la charge totale de chaque
membre et on ajoute les électrons du côté le plus positif.

### L''exemple de référence : le permanganate

**Étape 1.** Un manganèse de chaque côté, c''est déjà fait.
$$MnO_4^- \longrightarrow Mn^{2+}$$

**Étape 2.** Quatre oxygènes à gauche, zéro à droite. On ajoute $4H_2O$ à
droite.
$$MnO_4^- \longrightarrow Mn^{2+} + 4H_2O$$

**Étape 3.** Huit hydrogènes à droite, zéro à gauche. On ajoute $8H^+$ à gauche.
$$MnO_4^- + 8H^+ \longrightarrow Mn^{2+} + 4H_2O$$

**Étape 4.** Les $8H^+$ deviennent $8H_3O^+$, et on ajoute $8H_2O$ à droite.
$$MnO_4^- + 8H_3O^+ \longrightarrow Mn^{2+} + 12H_2O$$

**Étape 5.** À gauche : $-1 + 8 = +7$. À droite : $+2$. Il faut retirer 5
charges positives à gauche, donc ajouter **5 électrons**.

$$\boxed{\;MnO_4^- + 8H_3O^+ + 5e^- \rightleftharpoons Mn^{2+} + 12H_2O\;}$$

### La vérification, toujours

Compte une dernière fois : Mn, 1 et 1. O, $4+8 = 12$ et 12. H, 24 et 24.
Charges, $+7-5 = +2$ et $+2$. Tout est bon.

Ne saute jamais cette vérification. Une demi-équation fausse ruine tout
l''exercice qui suit.

---

**Exercice corrigé**

*Établis la demi-équation du couple $Cr_2O_7^{2-}/Cr^{3+}$ en milieu acide.*

**Correction.**
*1.* Deux chromes à gauche, il en faut deux à droite :
$$Cr_2O_7^{2-} \longrightarrow 2Cr^{3+}$$
*2.* Sept oxygènes à gauche :
$$Cr_2O_7^{2-} \longrightarrow 2Cr^{3+} + 7H_2O$$
*3.* Quatorze hydrogènes à droite :
$$Cr_2O_7^{2-} + 14H^+ \longrightarrow 2Cr^{3+} + 7H_2O$$
*4.* On passe aux ions hydronium :
$$Cr_2O_7^{2-} + 14H_3O^+ \longrightarrow 2Cr^{3+} + 21H_2O$$
*5.* À gauche $-2+14 = +12$, à droite $+6$. Il faut 6 électrons :
$$\boxed{\;Cr_2O_7^{2-} + 14H_3O^+ + 6e^- \rightleftharpoons 2Cr^{3+} + 21H_2O\;}$$
', NULL, 28),
      (v_chapitre_id, 'Simulation : construire une demi-équation', 2, 'interactif', '{
  "widget": "demi-equation",
  "consigne": "Choisis un couple et la simulation t''accompagne étape par étape : elle compte les atomes pour toi, te laisse placer les molécules d''eau, les ions hydronium puis les électrons, et refuse de passer à l''étape suivante tant que la précédente n''est pas juste. Au bout de cinq ou six couples, tu n''auras plus besoin d''elle."
}', NULL, 10),
      (v_chapitre_id, 'Les couples qui ne sont pas des métaux', 3, 'texte', '
Les couples $M^{n+}/M$ du chapitre 14 ne sont qu''une partie du paysage.
Beaucoup de couples mettent en jeu des ions polyatomiques, des molécules, ou
deux ions du même métal à des charges différentes. Voici ceux qui reviennent le
plus souvent.

### Les grands oxydants

$$MnO_4^- + 8H_3O^+ + 5e^- \rightleftharpoons Mn^{2+} + 12H_2O \qquad E° = 1{,}51 \text{ V}$$

$$Cr_2O_7^{2-} + 14H_3O^+ + 6e^- \rightleftharpoons 2Cr^{3+} + 21H_2O \qquad E° = 1{,}33 \text{ V}$$

$$Cl_2 + 2e^- \rightleftharpoons 2Cl^- \qquad E° = 1{,}36 \text{ V}$$

$$H_2O_2 + 2H_3O^+ + 2e^- \rightleftharpoons 4H_2O \qquad E° = 1{,}77 \text{ V}$$

**Les couleurs, qui servent de témoin.** L''ion permanganate $MnO_4^-$ est
**violet** ; l''ion $Mn^{2+}$ est **rose très pâle**, pratiquement incolore.
L''ion dichromate $Cr_2O_7^{2-}$ est **orange** ; l''ion $Cr^{3+}$ est **vert**.

Ces changements de couleur sont ce qui rend les dosages possibles sans aucun
indicateur ajouté. Tu verras cela au chapitre suivant.

### Les couples intermédiaires

$$Fe^{3+} + e^- \rightleftharpoons Fe^{2+} \qquad E° = 0{,}77 \text{ V}$$

$$I_2 + 2e^- \rightleftharpoons 2I^- \qquad E° = 0{,}54 \text{ V}$$

$$S_4O_6^{2-} + 2e^- \rightleftharpoons 2S_2O_3^{2-} \qquad E° = 0{,}08 \text{ V}$$

$$SO_4^{2-} + 4H_3O^+ + 2e^- \rightleftharpoons SO_2 + 6H_2O \qquad E° = 0{,}17 \text{ V}$$

$$NO_3^- + 4H_3O^+ + 3e^- \rightleftharpoons NO + 6H_2O \qquad E° = 0{,}96 \text{ V}$$

### L''eau, à la fois oxydante et réductrice

$$O_2 + 4H_3O^+ + 4e^- \rightleftharpoons 6H_2O \qquad E° = 1{,}23 \text{ V}$$
$$2H_3O^+ + 2e^- \rightleftharpoons H_2 + 2H_2O \qquad E° = 0 \text{ V}$$

Dans le couple $O_2/H_2O$, l''eau est le **réducteur**. Dans le couple
$H_3O^+/H_2$, elle est du côté **oxydant**. L''eau étant en même temps oxydante
et réductrice, on dit qu''elle est **amphotère**, ou **ampholyte**.

Retiens ce mot : il tombe en définition.

---

**Exercice corrigé**

*L''acide chlorhydrique est sans action sur le cuivre. L''acide nitrique, en
revanche, même dilué, l''attaque, et il se dégage du monoxyde d''azote NO.
Identifie les deux couples mis en jeu et écris l''équation-bilan.*

**Correction.**
Les couples sont $NO_3^-/NO$ à 0,96 V et $Cu^{2+}/Cu$ à 0,34 V.

L''oxydant le plus fort est $NO_3^-$, le réducteur le plus fort est $Cu$ : la
réaction est possible, alors qu''avec $H_3O^+$ à 0 V elle ne l''était pas.
$$NO_3^- + 4H_3O^+ + 3e^- \longrightarrow NO + 6H_2O \qquad (\times 2)$$
$$Cu \longrightarrow Cu^{2+} + 2e^- \qquad (\times 3)$$
$$\boxed{\;2NO_3^- + 8H_3O^+ + 3Cu \longrightarrow 2NO + 3Cu^{2+} + 12H_2O\;}$$
', NULL, 25),
      (v_chapitre_id, 'Figure : les couples à connaître et leurs potentiels', 4, 'figure', '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 540 440" width="540" height="440">
<rect width="540" height="440" fill="#ffffff"/>
<text x="270" y="24" text-anchor="middle" font-size="14" font-weight="700" fill="#0f172a">Les couples qui tombent à l&apos;examen</text>
<text x="270" y="42" text-anchor="middle" font-size="10" fill="#64748b">potentiels standard à 25 °C, du plus oxydant au plus réducteur</text>

<rect x="40" y="50" width="460" height="20" fill="#1e293b"/>
<text x="54" y="64" font-size="10" font-weight="700" fill="#ffffff">COUPLE</text>
<text x="214" y="64" font-size="10" font-weight="700" fill="#ffffff">NOM DE L&apos;OXYDANT</text>
<text x="432" y="64" font-size="10" font-weight="700" fill="#ffffff">E° (V)</text>

<rect x="40" y="64" width="460" height="20" fill="#ffffff"/>
<text x="54" y="78" font-size="11" font-weight="700" fill="#0f172a">S&#8322;O&#8328;²⁻ / SO&#8324;²⁻</text>
<text x="214" y="78" font-size="10" fill="#64748b">ion peroxodisulfate</text>
<text x="432" y="78" font-size="11" font-weight="700" fill="#0f172a">2,01</text>
<rect x="40" y="84" width="460" height="20" fill="#f1f5f9"/>
<text x="54" y="98" font-size="11" font-weight="700" fill="#0f172a">H&#8322;O&#8322; / H&#8322;O</text>
<text x="214" y="98" font-size="10" fill="#64748b">peroxyde d&apos;hydrogène</text>
<text x="432" y="98" font-size="11" font-weight="700" fill="#0f172a">1,77</text>
<rect x="40" y="104" width="460" height="20" fill="#ffffff"/>
<text x="54" y="118" font-size="11" font-weight="700" fill="#0f172a">MnO&#8324;⁻ / Mn²⁺</text>
<text x="214" y="118" font-size="10" fill="#64748b">ion permanganate</text>
<text x="432" y="118" font-size="11" font-weight="700" fill="#0f172a">1,51</text>
<rect x="40" y="124" width="460" height="20" fill="#f1f5f9"/>
<text x="54" y="138" font-size="11" font-weight="700" fill="#0f172a">Au³⁺ / Au</text>
<text x="214" y="138" font-size="10" fill="#64748b">ion or</text>
<text x="432" y="138" font-size="11" font-weight="700" fill="#0f172a">1,50</text>
<rect x="40" y="144" width="460" height="20" fill="#ffffff"/>
<text x="54" y="158" font-size="11" font-weight="700" fill="#0f172a">Cl&#8322; / Cl⁻</text>
<text x="214" y="158" font-size="10" fill="#64748b">dichlore</text>
<text x="432" y="158" font-size="11" font-weight="700" fill="#0f172a">1,36</text>
<rect x="40" y="164" width="460" height="20" fill="#f1f5f9"/>
<text x="54" y="178" font-size="11" font-weight="700" fill="#0f172a">Cr&#8322;O&#8327;²⁻ / Cr³⁺</text>
<text x="214" y="178" font-size="10" fill="#64748b">ion dichromate</text>
<text x="432" y="178" font-size="11" font-weight="700" fill="#0f172a">1,33</text>
<rect x="40" y="184" width="460" height="20" fill="#ffffff"/>
<text x="54" y="198" font-size="11" font-weight="700" fill="#0f172a">O&#8322; / H&#8322;O</text>
<text x="214" y="198" font-size="10" fill="#64748b">dioxygène</text>
<text x="432" y="198" font-size="11" font-weight="700" fill="#0f172a">1,23</text>
<rect x="40" y="204" width="460" height="20" fill="#f1f5f9"/>
<text x="54" y="218" font-size="11" font-weight="700" fill="#0f172a">Br&#8322; / Br⁻</text>
<text x="214" y="218" font-size="10" fill="#64748b">dibrome</text>
<text x="432" y="218" font-size="11" font-weight="700" fill="#0f172a">1,07</text>
<rect x="40" y="224" width="460" height="20" fill="#ffffff"/>
<text x="54" y="238" font-size="11" font-weight="700" fill="#0f172a">NO&#8323;⁻ / NO</text>
<text x="214" y="238" font-size="10" fill="#64748b">ion nitrate</text>
<text x="432" y="238" font-size="11" font-weight="700" fill="#0f172a">0,96</text>
<rect x="40" y="244" width="460" height="20" fill="#f1f5f9"/>
<text x="54" y="258" font-size="11" font-weight="700" fill="#0f172a">Ag⁺ / Ag</text>
<text x="214" y="258" font-size="10" fill="#64748b">ion argent</text>
<text x="432" y="258" font-size="11" font-weight="700" fill="#0f172a">0,80</text>
<rect x="40" y="264" width="460" height="20" fill="#ffffff"/>
<text x="54" y="278" font-size="11" font-weight="700" fill="#0f172a">Fe³⁺ / Fe²⁺</text>
<text x="214" y="278" font-size="10" fill="#64748b">ion fer III</text>
<text x="432" y="278" font-size="11" font-weight="700" fill="#0f172a">0,77</text>
<rect x="40" y="284" width="460" height="20" fill="#f1f5f9"/>
<text x="54" y="298" font-size="11" font-weight="700" fill="#0f172a">O&#8322; / H&#8322;O&#8322;</text>
<text x="214" y="298" font-size="10" fill="#64748b">dioxygène</text>
<text x="432" y="298" font-size="11" font-weight="700" fill="#0f172a">0,68</text>
<rect x="40" y="304" width="460" height="20" fill="#ffffff"/>
<text x="54" y="318" font-size="11" font-weight="700" fill="#0f172a">I&#8322; / I⁻</text>
<text x="214" y="318" font-size="10" fill="#64748b">diiode</text>
<text x="432" y="318" font-size="11" font-weight="700" fill="#0f172a">0,54</text>
<rect x="40" y="324" width="460" height="20" fill="#f1f5f9"/>
<text x="54" y="338" font-size="11" font-weight="700" fill="#0f172a">Cu²⁺ / Cu</text>
<text x="214" y="338" font-size="10" fill="#64748b">ion cuivre II</text>
<text x="432" y="338" font-size="11" font-weight="700" fill="#0f172a">0,34</text>
<rect x="40" y="344" width="460" height="20" fill="#ffffff"/>
<text x="54" y="358" font-size="11" font-weight="700" fill="#0f172a">SO&#8324;²⁻ / SO&#8322;</text>
<text x="214" y="358" font-size="10" fill="#64748b">ion sulfate</text>
<text x="432" y="358" font-size="11" font-weight="700" fill="#0f172a">0,17</text>
<rect x="40" y="364" width="460" height="20" fill="#f1f5f9"/>
<text x="54" y="378" font-size="11" font-weight="700" fill="#0f172a">S&#8324;O&#8326;²⁻ / S&#8322;O&#8323;²⁻</text>
<text x="214" y="378" font-size="10" fill="#64748b">ion tétrathionate</text>
<text x="432" y="378" font-size="11" font-weight="700" fill="#0f172a">0,08</text>
<rect x="40" y="384" width="460" height="20" fill="#fef9c3"/>
<text x="54" y="398" font-size="11" font-weight="700" fill="#0f172a">H&#8323;O⁺ / H&#8322;</text>
<text x="214" y="398" font-size="10" fill="#64748b">ion hydronium</text>
<text x="432" y="398" font-size="11" font-weight="700" fill="#0f172a">0,00</text>
<line x1="26" y1="72" x2="26" y2="402" stroke="#334155" stroke-width="1.6"/>
<polygon points="26,66 21,78 31,78" fill="#334155"/>
<text x="14" y="238" font-size="9" font-weight="700" fill="#334155" transform="rotate(-90 14 238)" text-anchor="middle">pouvoir oxydant croissant</text>

<text x="270" y="424" text-anchor="middle" font-size="10" fill="#64748b">la ligne jaune, E° = 0, est la référence de toute l&apos;échelle</text>
</svg>', NULL, 5),
      (v_chapitre_id, 'Simulation : explorer l''échelle des potentiels', 5, 'interactif', '{
  "widget": "couples-non-metalliques",
  "consigne": "L''échelle complète est devant toi, des grands oxydants en haut aux grands réducteurs en bas. Clique sur un couple : sa demi-équation s''écrit, avec les couleurs des deux formes. Sélectionne-en deux et la simulation te dit si la réaction se fait, dans quel sens, et si elle est totale. Cherche par exemple pourquoi l''acide nitrique attaque le cuivre alors que l''acide chlorhydrique ne le fait pas."
}', NULL, 10),
      (v_chapitre_id, 'Prévoir une réaction, et savoir si elle est totale', 6, 'texte', '
### La règle du gamma, avec des chiffres

Tu connais déjà la règle : l''oxydant le plus fort réagit avec le réducteur le
plus fort. Maintenant tu as les potentiels, donc tu n''as plus besoin de deviner
qui est le plus fort :

$$E°(\text{oxydant}_1/\text{réducteur}_1) > E°(\text{oxydant}_2/\text{réducteur}_2)$$

alors $\text{oxydant}_1$ réagit avec $\text{réducteur}_2$.

### Le critère de totalité

Une réaction peut être possible sans être complète. Le critère à retenir est le
suivant :

> Pour que la réaction soit **totale**, la différence des potentiels des deux
> couples doit être **supérieure à 0,34 V**.

$$\Delta E = E°_1 - E°_2 > 0{,}34 \text{ V}$$

C''est une condition très importante : un dosage n''est fiable que si la
réaction utilisée est totale. En dessous de ce seuil, il reste toujours un peu
de réactif, et le point d''équivalence devient flou.

### Premier exemple : diiode et thiosulfate

Les couples sont $I_2/I^-$ à 0,54 V et $S_4O_6^{2-}/S_2O_3^{2-}$ à 0,08 V.

$$I_2 + 2e^- \longrightarrow 2I^- \qquad \text{réduction}$$
$$2S_2O_3^{2-} \longrightarrow S_4O_6^{2-} + 2e^- \qquad \text{oxydation}$$
$$\boxed{\;I_2 + 2S_2O_3^{2-} \longrightarrow 2I^- + S_4O_6^{2-}\;}$$

$\Delta E = 0{,}54 - 0{,}08 = 0{,}46$ V $> 0{,}34$ V : la réaction est
**totale**.

### Deuxième exemple : permanganate et fer II

Les couples sont $MnO_4^-/Mn^{2+}$ à 1,51 V et $Fe^{3+}/Fe^{2+}$ à 0,77 V.

$$MnO_4^- + 8H_3O^+ + 5e^- \longrightarrow Mn^{2+} + 12H_2O \qquad (\times 1)$$
$$Fe^{2+} \longrightarrow Fe^{3+} + e^- \qquad (\times 5)$$
$$\boxed{\;MnO_4^- + 5Fe^{2+} + 8H_3O^+ \longrightarrow Mn^{2+} + 5Fe^{3+} + 12H_2O\;}$$

$\Delta E = 1{,}51 - 0{,}77 = 0{,}74$ V $> 0{,}34$ V : **totale** également.
C''est la réaction de dosage la plus utilisée au lycée.

---

**Exercice corrigé**

*Parmi ces réactions, lesquelles sont totales ?*
*a) $I_2/I^-$ (0,54 V) et $Fe^{3+}/Fe^{2+}$ (0,77 V)*
*b) $MnO_4^-/Mn^{2+}$ (1,51 V) et $Br_2/Br^-$ (1,07 V)*
*c) $Fe^{3+}/Fe^{2+}$ (0,77 V) et $Cr_2O_7^{2-}/Cr^{3+}$ (1,33 V)*

**Correction.**
a) $\Delta E = 0{,}77 - 0{,}54 = 0{,}23$ V. C''est **inférieur** à 0,34 V : la
réaction est possible mais **non totale**.
b) $\Delta E = 1{,}51 - 1{,}07 = 0{,}44$ V $> 0{,}34$ V : **totale**.
c) $\Delta E = 1{,}33 - 0{,}77 = 0{,}56$ V $> 0{,}34$ V : **totale**.

Pour b) et c) :
$$2MnO_4^- + 10Br^- + 16H_3O^+ \longrightarrow 2Mn^{2+} + 5Br_2 + 24H_2O$$
$$Cr_2O_7^{2-} + 6Fe^{2+} + 14H_3O^+ \longrightarrow 2Cr^{3+} + 6Fe^{3+} + 21H_2O$$
', NULL, 28),
      (v_chapitre_id, 'Simulation : la réaction sera-t-elle totale ?', 7, 'interactif', '{
  "widget": "reaction-totale",
  "consigne": "Pose deux couples sur l''échelle et la simulation calcule la différence de potentiel, trace le gamma et écrit l''équation-bilan équilibrée. Un curseur te montre ce qui se passe dans le bécher : au-dessus de 0,34 volt tout le réactif limitant disparaît, en dessous il en reste toujours un peu — et tu comprends pourquoi on ne dose jamais avec une réaction non totale."
}', NULL, 10),
      (v_chapitre_id, 'Quiz du chapitre 16', 8, 'quiz', '{
  "titre": "Vérifie que tu as compris",
  "questions": [
    {
      "question": "Dans la méthode des cinq étapes, avec quoi équilibre-t-on l''oxygène ?",
      "choix": [
        "Avec des ions $H_3O^+$",
        "Avec des molécules d''eau",
        "Avec des électrons",
        "Avec du dioxygène"
      ],
      "bonne": 1,
      "explication": "L''oxygène d''abord avec $H_2O$, puis l''hydrogène avec $H^+$ que l''on convertit en $H_3O^+$, et les charges en dernier avec les électrons."
    },
    {
      "question": "Quelle est la demi-équation du couple $MnO_4^-/Mn^{2+}$ en milieu acide ?",
      "choix": [
        "$MnO_4^- + 4H_3O^+ + 3e^- \\rightleftharpoons Mn^{2+} + 6H_2O$",
        "$MnO_4^- + 8H_3O^+ + 5e^- \\rightleftharpoons Mn^{2+} + 12H_2O$",
        "$MnO_4^- + 2e^- \\rightleftharpoons Mn^{2+}$",
        "$MnO_4^- + 8H_2O \\rightleftharpoons Mn^{2+} + 5e^-$"
      ],
      "bonne": 1,
      "explication": "Vérifie : 12 oxygènes de chaque côté, 24 hydrogènes, et une charge de $+2$ des deux côtés."
    },
    {
      "question": "De quelle couleur est l''ion permanganate $MnO_4^-$ ?",
      "choix": [
        "Vert",
        "Violet",
        "Orange",
        "Incolore"
      ],
      "bonne": 1,
      "explication": "Et l''ion $Mn^{2+}$ qu''il devient est rose très pâle, presque incolore. C''est ce qui rend le dosage visible sans indicateur."
    },
    {
      "question": "Que signifie le mot amphotère appliqué à l''eau ?",
      "choix": [
        "Qu''elle est transparente",
        "Qu''elle est à la fois oxydante et réductrice",
        "Qu''elle est neutre",
        "Qu''elle conduit le courant"
      ],
      "bonne": 1,
      "explication": "Dans le couple $O_2/H_2O$ elle est réductrice, dans le couple $H_3O^+/H_2$ elle est du côté oxydant. On dit aussi ampholyte."
    },
    {
      "question": "À partir de quelle différence de potentiel une réaction est-elle totale ?",
      "choix": [
        "0,10 V",
        "0,34 V",
        "1,00 V",
        "Toute réaction est totale"
      ],
      "bonne": 1,
      "explication": "En dessous de ce seuil, il reste toujours un peu de réactif et le point d''équivalence devient flou : le dosage n''est plus fiable."
    },
    {
      "question": "Quelle est l''équation du dosage du fer II par le permanganate ?",
      "choix": [
        "$MnO_4^- + Fe^{2+} \\rightarrow Mn^{2+} + Fe^{3+}$",
        "$MnO_4^- + 5Fe^{2+} + 8H_3O^+ \\rightarrow Mn^{2+} + 5Fe^{3+} + 12H_2O$",
        "$MnO_4^- + 2Fe^{2+} \\rightarrow Mn^{2+} + 2Fe^{3+}$",
        "$5MnO_4^- + Fe^{2+} \\rightarrow 5Mn^{2+} + Fe^{3+}$"
      ],
      "bonne": 1,
      "explication": "Le permanganate capte 5 électrons, chaque ion fer II n''en cède qu''un : il en faut donc cinq."
    },
    {
      "question": "Pourquoi l''acide nitrique attaque-t-il le cuivre, alors que l''acide chlorhydrique ne le fait pas ?",
      "choix": [
        "Parce qu''il est plus concentré",
        "Parce que le couple $NO_3^-/NO$ est à 0,96 V, bien au-dessus de $Cu^{2+}/Cu$ à 0,34 V",
        "Parce qu''il est plus chaud",
        "Parce qu''il contient de l''azote"
      ],
      "bonne": 1,
      "explication": "Dans l''acide chlorhydrique, c''est l''ion $H_3O^+$ à 0 V qui serait l''oxydant : trop faible pour le cuivre."
    }
  ]
}', NULL, 5);

    RAISE NOTICE '% : 8 leçons ajoutées au chapitre 16, Demi-équations et équilibrage des réactions rédox.', v_nom;
  END LOOP;
END $ch1$;
