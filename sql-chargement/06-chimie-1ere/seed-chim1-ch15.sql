-- ---------------------------------------------------------------------------
-- M'Andal — Chimie, classes de Première
-- Chapitre 15 : Les piles et le potentiel d'oxydoréduction
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
    WHERE programme_id = v_programme_id AND ordre = 15;

    IF v_chapitre_id IS NULL THEN
      INSERT INTO public.chapitres (programme_id, titre, ordre, niveau)
      VALUES (v_programme_id, 'Les piles et le potentiel d''oxydoréduction', 15, 'Module 3 : Oxydoréduction')
      RETURNING id INTO v_chapitre_id;
      RAISE NOTICE '% : chapitre 15 créé.', v_nom;
    END IF;

    -- Les leçons. Si le chapitre en a déjà, on passe son tour sans rien toucher.
    SELECT count(*) INTO v_deja FROM public.concepts WHERE chapitre_id = v_chapitre_id;
    IF v_deja > 0 THEN
      RAISE NOTICE '% : le chapitre 15 a déjà ses % leçons, je n''y touche pas.', v_nom, v_deja;
      CONTINUE;
    END IF;

    INSERT INTO public.concepts
      (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes) VALUES
      (v_chapitre_id, 'La pile Daniell', 1, 'texte', '
Jusqu''ici, lorsque le zinc réagissait avec les ions cuivre, les électrons
passaient directement d''une espèce à l''autre, dans le même bécher, et toute
l''énergie partait en chaleur. L''idée de la pile est simple et géniale :
**séparer** les deux demi-réactions, et forcer les électrons à passer par un
fil. On récupère alors de l''énergie électrique.

### Le montage

Deux béchers. Dans le premier, une **lame de zinc** plongée dans une solution de
sulfate de zinc à 1 mol/L. Dans le second, une **lame de cuivre** plongée dans
une solution de sulfate de cuivre à 1 mol/L. Les deux lames métalliques
constituent les **électrodes**.

Un **pont salin** relie les deux béchers. C''est un tube en U rempli d''une
solution saturée de nitrate d''ammonium $(NH_4^+ + NO_3^-)$. Une languette de
papier imbibée de cette solution fait aussi l''affaire.

Relie les deux électrodes par un milliampèremètre et un résistor : **un courant
circule**, de l''électrode de cuivre vers l''électrode de zinc.

Cette pile zinc-cuivre s''appelle la **pile Daniell**.

### Ce qui se passe aux électrodes

$$\text{pôle négatif :} \quad Zn \longrightarrow Zn^{2+} + 2e^- \quad \text{oxydation}$$
$$\text{pôle positif :} \quad Cu^{2+} + 2e^- \longrightarrow Cu \quad \text{réduction}$$
$$\boxed{\;Zn + Cu^{2+} \longrightarrow Zn^{2+} + Cu\;}$$

Regarde bien cette équation-bilan : c''est **exactement** celle de la réaction
spontanée du chapitre précédent. La pile ne crée aucune chimie nouvelle. Elle
oblige simplement les électrons à faire un détour par le circuit extérieur.

### La représentation conventionnelle

$$\ominus \; Zn \;|\; Zn^{2+} \;||\; Cu^{2+} \;|\; Cu \; \oplus$$

Le trait simple sépare un métal de sa solution. Le **double trait** représente
le pont salin. Le pôle **négatif** s''écrit à gauche.

### La force électromotrice

Lorsque les solutions sont à 1 mol/L, on mesure :

$$E_{Zn-Cu} = V_{Cu} - V_{Zn} = 1{,}10 \text{ V}$$

### Le sens du courant

Dans le circuit extérieur, les **électrons** vont du pôle négatif vers le pôle
positif, c''est-à-dire du zinc vers le cuivre. Le **courant**, lui, circule en
sens inverse : du cuivre vers le zinc. C''est une convention ancienne, mais
elle tombe à l''examen.

---

**Exercice corrigé**

*Une pile Daniell est réalisée avec un vase poreux à la place du pont salin.
Pourquoi utilise-t-on ce vase ? Quel métal constitue le pôle positif ?*
*On donne $E°(Cu^{2+}/Cu) = 0{,}34$ V et $E°(Zn^{2+}/Zn) = -0{,}76$ V.*

**Correction.**
Le **vase poreux** assure la fermeture du circuit électrique, c''est-à-dire le
contact entre les deux solutions, tout en **évitant leur mélange**. Il joue
exactement le rôle du pont salin.
Le **pôle positif** est le cuivre, parce que le potentiel du couple
$Cu^{2+}/Cu$ est supérieur à celui du couple $Zn^{2+}/Zn$.
$$E = E°(Cu^{2+}/Cu) - E°(Zn^{2+}/Zn) = 0{,}34 - (-0{,}76) = 1{,}10 \text{ V}$$
Cette f.é.m. est bien égale à celle qu''indique le voltmètre.
', NULL, 28),
      (v_chapitre_id, 'Simulation : la pile Daniell', 2, 'interactif', '{
  "widget": "pile-daniell",
  "consigne": "Monte la pile pièce par pièce : les deux béchers, les deux lames, le pont salin, le circuit. Tant que le pont n''est pas en place, l''aiguille ne bouge pas — tu comprendras alors à quoi il sert. Branche ensuite le voltmètre, lis la force électromotrice, et suis les électrons qui quittent le zinc pour aller se déposer en cuivre sur l''autre lame."
}', NULL, 10),
      (v_chapitre_id, 'Demi-pile, pile, pont salin', 3, 'texte', '
### Les définitions

Une **demi-pile** est une plaque de métal $M$ plongeant dans une solution
contenant des ions métalliques $M^{n+}$.

Une **pile** est un ensemble de **deux demi-piles reliées par un pont salin**.

### Les trois constituants essentiels

Une question de cours fréquente te demande de les citer :

1. les **électrodes**, les deux lames métalliques ;
2. les **électrolytes**, les deux solutions ioniques ;
3. le **pont salin**.

### Le rôle du pont salin

Il assure la **fermeture du circuit électrique** — le contact entre les deux
solutions — tout en **évitant leur mélange**.

Sans lui, les électrons s''accumuleraient d''un côté et manqueraient de l''autre :
les charges se déséquilibreraient et tout s''arrêterait en une fraction de
seconde. Le pont salin laisse passer les ions qui rétablissent la neutralité
de chaque bécher.

On peut le remplacer par une **paroi poreuse**, ou **vase poreux**, placé entre
les deux demi-piles. Il joue le même rôle.

### La polarité

> Le pôle **négatif** est constitué du métal le **plus réducteur**. Le métal
> le **moins réducteur** fait office de pôle **positif**.

C''est logique : le métal le plus réducteur est celui qui cède le plus
facilement ses électrons, donc c''est lui qui les envoie dans le circuit, donc
c''est lui la borne d''où ils sortent — le pôle négatif.

### La transformation d''énergie

Dans une pile, l''**énergie chimique** est transformée en **énergie
électrique**.

---

**Exercice corrigé**

*On construit une pile en associant une électrode de zinc dans du sulfate de
zinc et une électrode de plomb dans du sulfate de plomb. Représente cette pile
en faisant apparaître ses deux pôles et calcule sa f.é.m.*
*On donne $E°(Zn^{2+}/Zn) = -0{,}76$ V et $E°(Pb^{2+}/Pb) = -0{,}13$ V.*

**Correction.**
Le plomb a le potentiel le plus élevé : c''est donc le **pôle positif**. Le zinc
est le pôle négatif.
$$\ominus \; Zn \;|\; Zn^{2+} \;||\; Pb^{2+} \;|\; Pb \; \oplus$$
$$E = E°(Pb^{2+}/Pb) - E°(Zn^{2+}/Zn) = -0{,}13 - (-0{,}76) = 0{,}63 \text{ V}$$
', NULL, 22),
      (v_chapitre_id, 'Simulation : construire sa propre pile', 4, 'interactif', '{
  "widget": "construire-pile",
  "consigne": "Choisis deux métaux et leurs solutions, monte la pile, et la simulation détermine les pôles, écrit la représentation conventionnelle et calcule la force électromotrice. Retire le pont salin : le courant tombe à zéro instantanément, et tu verras les charges s''accumuler de part et d''autre. Essaie toutes les paires du tableau pour trouver la pile la plus puissante."
}', NULL, 10),
      (v_chapitre_id, 'L''électrode standard à hydrogène et les potentiels', 5, 'texte', '
### Le problème

On ne peut pas mesurer le potentiel d''une seule électrode : un voltmètre mesure
toujours une **différence**. Il faut donc choisir une référence et lui attribuer
arbitrairement la valeur zéro.

### L''électrode standard à hydrogène

Par convention, lorsque les conditions sont **standard**, c''est-à-dire :

- le pH de la solution nul, $pH = 0$ ;
- la pression atmosphérique égale à 1 bar ;

le potentiel redox standard du couple $H_3O^+/H_2$ est **nul à toute
température** :

$$E°(H_3O^+/H_2) = 0 \text{ V}$$

Utilisée dans ces conditions, la demi-pile à hydrogène est appelée **électrode
standard à hydrogène**, abrégée **E.S.H.**

### Le potentiel d''un couple

Le potentiel d''oxydoréduction d''un couple $M^{n+}/M$ s''obtient en réalisant la
pile constituée de l''électrode standard à hydrogène et de la demi-pile
$M^{n+}/M$ :

$$E°(M^{n+}/M) = V_M - V_{ESH}$$

### Lire le tableau

> Un **oxydant** est d''autant plus **fort** que le couple auquel il appartient a
> un potentiel **élevé**.
>
> Un **réducteur** est d''autant plus **fort** que le couple auquel il appartient
> a un potentiel **faible**.

Les deux phrases vont ensemble : un potentiel élevé signifie un oxydant fort,
donc un réducteur conjugué faible.

### Calculer la force électromotrice

Considérons une pile réalisée à partir des couples $M_1^{n_1+}/M_1$ et
$M_2^{n_2+}/M_2$ tels que :

$$E°(M_2^{n_2+}/M_2) > E°(M_1^{n_1+}/M_1)$$

La représentation conventionnelle est :

$$\ominus \; M_1 \;|\; M_1^{n_1+} \;||\; M_2^{n_2+} \;|\; M_2 \; \oplus$$

et la force électromotrice vaut :

$$\boxed{\;E = E°(M_2^{n_2+}/M_2) - E°(M_1^{n_1+}/M_1)\;}$$

soit, en une phrase : **la f.é.m. est le potentiel du pôle positif moins celui
du pôle négatif**. Elle est donc toujours **positive**.

---

**Exercice corrigé**

*On considère la pile de représentation $\ominus \, Zn \,|\, Zn^{2+} \,||\,
M^{n+} \,|\, M \, \oplus$. Les solutions sont à 1 mol/L et la f.é.m. vaut
0,53 V. Détermine la nature du métal inconnu M, sachant que
$E°(Zn^{2+}/Zn) = -0{,}76$ V.*

**Correction.**
$$E = E°(M^{n+}/M) - E°(Zn^{2+}/Zn)$$
$$E°(M^{n+}/M) = E + E°(Zn^{2+}/Zn) = 0{,}53 + (-0{,}76) = -0{,}23 \text{ V}$$
En consultant le tableau des potentiels standard, la valeur $-0{,}23$ V est
celle du couple $Ni^{2+}/Ni$.

Le métal inconnu est donc le **nickel**, et l''équation-bilan du fonctionnement
de cette pile s''écrit :
$$Zn + Ni^{2+} \longrightarrow Zn^{2+} + Ni$$
', NULL, 28),
      (v_chapitre_id, 'Figure : le tableau des potentiels standard', 6, 'figure', '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 540 400" width="540" height="400">
<rect width="540" height="400" fill="#ffffff"/>
<text x="270" y="22" text-anchor="middle" font-size="14" font-weight="700" fill="#0f172a">Potentiels standard de quelques couples M&#8319;&#8314;/M à 25 °C</text>

<rect x="60" y="38" width="420" height="22" fill="#1e293b"/>
<text x="76" y="53" font-size="10" font-weight="700" fill="#ffffff">OXYDANT</text>
<text x="236" y="53" font-size="10" font-weight="700" fill="#ffffff">RÉDUCTEUR</text>
<text x="404" y="53" font-size="10" font-weight="700" fill="#ffffff">E° (V)</text>

<g font-size="11">
  <rect x="60" y="60" width="420" height="24" fill="#ffffff"/>
  <text x="76" y="77" font-weight="700" fill="#0f172a">Au³⁺</text><text x="130" y="77" fill="#64748b">ion or</text>
  <text x="236" y="77" font-weight="700" fill="#0f172a">Au</text><text x="286" y="77" fill="#64748b">or</text>
  <text x="404" y="77" font-weight="700" fill="#0f172a">+1,50</text>

  <rect x="60" y="84" width="420" height="24" fill="#f1f5f9"/>
  <text x="76" y="101" font-weight="700" fill="#0f172a">Hg²⁺</text><text x="130" y="101" fill="#64748b">ion mercure II</text>
  <text x="236" y="101" font-weight="700" fill="#0f172a">Hg</text><text x="286" y="101" fill="#64748b">mercure</text>
  <text x="404" y="101" font-weight="700" fill="#0f172a">+0,86</text>

  <rect x="60" y="108" width="420" height="24" fill="#ffffff"/>
  <text x="76" y="125" font-weight="700" fill="#0f172a">Ag⁺</text><text x="130" y="125" fill="#64748b">ion argent</text>
  <text x="236" y="125" font-weight="700" fill="#0f172a">Ag</text><text x="286" y="125" fill="#64748b">argent</text>
  <text x="404" y="125" font-weight="700" fill="#0f172a">+0,80</text>

  <rect x="60" y="132" width="420" height="24" fill="#f1f5f9"/>
  <text x="76" y="149" font-weight="700" fill="#0f172a">Cu²⁺</text><text x="130" y="149" fill="#64748b">ion cuivre II</text>
  <text x="236" y="149" font-weight="700" fill="#0f172a">Cu</text><text x="286" y="149" fill="#64748b">cuivre</text>
  <text x="404" y="149" font-weight="700" fill="#0f172a">+0,34</text>

  <rect x="60" y="156" width="420" height="26" fill="#fef9c3" stroke="#ca8a04" stroke-width="1.4"/>
  <text x="76" y="174" font-weight="700" fill="#713f12">H₃O⁺</text><text x="130" y="174" fill="#854d0e">ion hydronium</text>
  <text x="236" y="174" font-weight="700" fill="#713f12">H₂</text><text x="286" y="174" fill="#854d0e">dihydrogène</text>
  <text x="404" y="174" font-weight="700" fill="#713f12">0,00</text>

  <rect x="60" y="182" width="420" height="24" fill="#ffffff"/>
  <text x="76" y="199" font-weight="700" fill="#0f172a">Pb²⁺</text><text x="130" y="199" fill="#64748b">ion plomb</text>
  <text x="236" y="199" font-weight="700" fill="#0f172a">Pb</text><text x="286" y="199" fill="#64748b">plomb</text>
  <text x="404" y="199" font-weight="700" fill="#0f172a">&#8722;0,13</text>

  <rect x="60" y="206" width="420" height="24" fill="#f1f5f9"/>
  <text x="76" y="223" font-weight="700" fill="#0f172a">Sn²⁺</text><text x="130" y="223" fill="#64748b">ion étain</text>
  <text x="236" y="223" font-weight="700" fill="#0f172a">Sn</text><text x="286" y="223" fill="#64748b">étain</text>
  <text x="404" y="223" font-weight="700" fill="#0f172a">&#8722;0,14</text>

  <rect x="60" y="230" width="420" height="24" fill="#ffffff"/>
  <text x="76" y="247" font-weight="700" fill="#0f172a">Ni²⁺</text><text x="130" y="247" fill="#64748b">ion nickel</text>
  <text x="236" y="247" font-weight="700" fill="#0f172a">Ni</text><text x="286" y="247" fill="#64748b">nickel</text>
  <text x="404" y="247" font-weight="700" fill="#0f172a">&#8722;0,23</text>

  <rect x="60" y="254" width="420" height="24" fill="#f1f5f9"/>
  <text x="76" y="271" font-weight="700" fill="#0f172a">Fe²⁺</text><text x="130" y="271" fill="#64748b">ion fer II</text>
  <text x="236" y="271" font-weight="700" fill="#0f172a">Fe</text><text x="286" y="271" fill="#64748b">fer</text>
  <text x="404" y="271" font-weight="700" fill="#0f172a">&#8722;0,44</text>

  <rect x="60" y="278" width="420" height="24" fill="#ffffff"/>
  <text x="76" y="295" font-weight="700" fill="#0f172a">Zn²⁺</text><text x="130" y="295" fill="#64748b">ion zinc</text>
  <text x="236" y="295" font-weight="700" fill="#0f172a">Zn</text><text x="286" y="295" fill="#64748b">zinc</text>
  <text x="404" y="295" font-weight="700" fill="#0f172a">&#8722;0,76</text>

  <rect x="60" y="302" width="420" height="24" fill="#f1f5f9"/>
  <text x="76" y="319" font-weight="700" fill="#0f172a">Al³⁺</text><text x="130" y="319" fill="#64748b">ion aluminium</text>
  <text x="236" y="319" font-weight="700" fill="#0f172a">Al</text><text x="286" y="319" fill="#64748b">aluminium</text>
  <text x="404" y="319" font-weight="700" fill="#0f172a">&#8722;1,66</text>

  <rect x="60" y="326" width="420" height="24" fill="#ffffff"/>
  <text x="76" y="343" font-weight="700" fill="#0f172a">Mg²⁺</text><text x="130" y="343" fill="#64748b">ion magnésium</text>
  <text x="236" y="343" font-weight="700" fill="#0f172a">Mg</text><text x="286" y="343" fill="#64748b">magnésium</text>
  <text x="404" y="343" font-weight="700" fill="#0f172a">&#8722;2,37</text>

  <rect x="60" y="350" width="420" height="24" fill="#f1f5f9"/>
  <text x="76" y="367" font-weight="700" fill="#0f172a">Na⁺</text><text x="130" y="367" fill="#64748b">ion sodium</text>
  <text x="236" y="367" font-weight="700" fill="#0f172a">Na</text><text x="286" y="367" fill="#64748b">sodium</text>
  <text x="404" y="367" font-weight="700" fill="#0f172a">&#8722;2,71</text>
</g>

<line x1="42" y1="62" x2="42" y2="372" stroke="#334155" stroke-width="1.6"/>
<polygon points="42,56 37,68 47,68" fill="#334155"/>
<text x="24" y="220" font-size="9" font-weight="700" fill="#334155" transform="rotate(-90 24 220)" text-anchor="middle">pouvoir oxydant croissant</text>

<line x1="500" y1="62" x2="500" y2="372" stroke="#334155" stroke-width="1.6"/>
<polygon points="500,378 495,366 505,366" fill="#334155"/>
<text x="518" y="220" font-size="9" font-weight="700" fill="#334155" transform="rotate(90 518 220)" text-anchor="middle">pouvoir réducteur croissant</text>

<text x="270" y="392" text-anchor="middle" font-size="10" fill="#64748b">la ligne jaune, E° = 0, est la référence : tout métal en dessous est attaqué par les acides, tout métal au-dessus ne l&apos;est pas</text>
</svg>', NULL, 5),
      (v_chapitre_id, 'Simulation : lire le tableau des potentiels', 7, 'interactif', '{
  "widget": "potentiels-standards",
  "consigne": "Le tableau est devant toi, et la simulation te pose des questions dessus : quel est l''oxydant le plus fort de cette liste, le réducteur le plus faible, cette réaction est-elle possible ? Branche ensuite deux couples pour en faire une pile et vérifie que la f.é.m. calculée correspond bien à celle qu''affiche le voltmètre."
}', NULL, 10),
      (v_chapitre_id, 'Les variations de masse des électrodes', 8, 'texte', '
Voici le calcul qu''on te demande le plus souvent après avoir monté la pile. Il
n''est pas difficile, mais il faut raisonner proprement.

### Ce qui arrive à chaque électrode

Au **pôle négatif**, le métal s''oxyde : il passe en solution. L''électrode
**maigrit**, sa variation de masse $\Delta m$ est **négative**.

Au **pôle positif**, les ions se réduisent : le métal se dépose. L''électrode
**grossit**, sa variation de masse est **positive**.

### La relation entre les deux

Les électrons perdus d''un côté sont exactement ceux qui sont gagnés de l''autre.
C''est le fil qui les transporte, et aucun ne se perd en route.

Pour la pile Daniell, chaque atome de zinc libère 2 électrons, et chaque ion
cuivre en consomme 2. Donc :

$$n_{Zn\;\text{dissous}} = n_{Cu\;\text{déposé}}$$

$$\frac{|\Delta m_1|}{M_{Zn}} = \frac{|\Delta m_2|}{M_{Cu}}$$

Attention : cette égalité des **quantités de matière** n''est vraie que si les
deux demi-équations échangent le **même nombre d''électrons**. Si l''un des
couples est $Al^{3+}/Al$ et l''autre $Cu^{2+}/Cu$, il faut repasser par les
coefficients de l''équation-bilan.

### La méthode en trois temps

1. Écrire l''équation-bilan du fonctionnement de la pile.
2. Convertir la variation de masse connue en **quantité de matière**.
3. Utiliser la relation de stœchiométrie pour trouver l''autre.

---

**Exercice corrigé**

*Dans la pile $\ominus \, Fe \,|\, Fe^{2+} \,||\, Cu^{2+} \,|\, Cu \,
\oplus$, la variation de masse de l''électrode de fer après une durée de
fonctionnement vaut $\Delta m_1 = -2{,}45$ g.*
*1) Justifie le signe négatif. 2) Quel est le signe de $\Delta m_2$ ?
3) Calcule $\Delta m_2$. 4) Sachant qu''après cette durée l''électrode de cuivre
pèse 102,10 g, quelle était sa masse initiale ?*
*On donne $M(Cu) = 63{,}5$ et $M(Fe) = 56$ g/mol.*

**Correction.**

**1)** Le fer est au pôle négatif : il s''oxyde selon
$Fe \rightarrow Fe^{2+} + 2e^-$ et passe en solution. L''électrode perd donc de
la matière, d''où le signe négatif.

**2)** Le cuivre est au pôle positif : les ions $Cu^{2+}$ s''y réduisent et se
déposent. $\Delta m_2$ est donc **positif**.

**3)** L''équation-bilan est $Fe + Cu^{2+} \rightarrow Fe^{2+} + Cu$ : une mole
de fer dissous donne une mole de cuivre déposé.
$$n = \frac{2{,}45}{56} = 0{,}04375 \text{ mol}$$
$$\Delta m_2 = 0{,}04375 \times 63{,}5 = +2{,}78 \text{ g}$$

**4)** La masse initiale était
$$m_0 = 102{,}10 - 2{,}78 = 99{,}32 \text{ g}$$
', NULL, 25),
      (v_chapitre_id, 'Simulation : suivre la masse des électrodes', 9, 'interactif', '{
  "widget": "masse-electrodes",
  "consigne": "Laisse la pile débiter et regarde les deux balances : celle du pôle négatif descend, celle du pôle positif monte, et la simulation affiche à chaque instant les quantités de matière correspondantes. Change de couple pour prendre un métal trivalent comme l''aluminium : tu verras alors que l''égalité simple des quantités de matière ne tient plus, et pourquoi il faut repasser par l''équation-bilan."
}', NULL, 10),
      (v_chapitre_id, 'Quiz du chapitre 15', 10, 'quiz', '{
  "titre": "Vérifie que tu as compris",
  "questions": [
    {
      "question": "Quels sont les trois constituants essentiels d''une pile ?",
      "choix": [
        "Les fils, l''ampoule et l''interrupteur",
        "Les électrodes, les électrolytes et le pont salin",
        "Deux métaux et de l''eau",
        "Un voltmètre et deux béchers"
      ],
      "bonne": 1,
      "explication": "Le pont salin peut être remplacé par un vase poreux, qui joue exactement le même rôle."
    },
    {
      "question": "Quel est le rôle du pont salin ?",
      "choix": [
        "Mélanger les deux solutions",
        "Fermer le circuit électrique tout en évitant le mélange des solutions",
        "Chauffer la pile",
        "Mesurer la tension"
      ],
      "bonne": 1,
      "explication": "Sans lui, les charges se déséquilibreraient immédiatement et le courant s''arrêterait."
    },
    {
      "question": "Quel métal constitue le pôle négatif d''une pile ?",
      "choix": [
        "Le plus réducteur",
        "Le moins réducteur",
        "Le plus lourd",
        "Peu importe"
      ],
      "bonne": 0,
      "explication": "C''est lui qui cède le plus facilement ses électrons, donc c''est de lui qu''ils sortent vers le circuit."
    },
    {
      "question": "Combien vaut le potentiel standard du couple $H_3O^+/H_2$ ?",
      "choix": [
        "1 V",
        "0 V par convention",
        "$-1$ V",
        "Cela dépend de la température"
      ],
      "bonne": 1,
      "explication": "C''est la référence de toute l''échelle. La demi-pile correspondante s''appelle l''électrode standard à hydrogène, ou E.S.H."
    },
    {
      "question": "Comment calcule-t-on la force électromotrice d''une pile ?",
      "choix": [
        "En additionnant les deux potentiels",
        "Potentiel du pôle positif moins celui du pôle négatif",
        "Potentiel du pôle négatif moins celui du positif",
        "En multipliant les deux potentiels"
      ],
      "bonne": 1,
      "explication": "Elle est donc toujours positive. Pour la pile Daniell : $0{,}34 - (-0{,}76) = 1{,}10$ V."
    },
    {
      "question": "Dans une pile en fonctionnement, l''électrode du pôle négatif :",
      "choix": [
        "grossit",
        "maigrit",
        "ne change pas",
        "change de couleur seulement"
      ],
      "bonne": 1,
      "explication": "Le métal s''y oxyde et passe en solution. Au pôle positif, au contraire, le métal se dépose et l''électrode grossit."
    },
    {
      "question": "Dans une pile, quelle transformation d''énergie a lieu ?",
      "choix": [
        "Électrique en chimique",
        "Chimique en électrique",
        "Thermique en chimique",
        "Mécanique en électrique"
      ],
      "bonne": 1,
      "explication": "C''est l''inverse de l''électrolyse, que tu verras au chapitre 18, où l''énergie électrique force une réaction chimique."
    }
  ]
}', NULL, 5);

    RAISE NOTICE '% : 10 leçons ajoutées au chapitre 15, Les piles et le potentiel d''oxydoréduction.', v_nom;
  END LOOP;
END $ch1$;
