-- ---------------------------------------------------------------------------
-- M'Andal — Informatique, classes de Terminale
-- Chapitre 6 : Les fonctions d'un classeur dans la production d'un document
-- Module 1 : Systèmes informatiques — 8 leçons
--
-- Ce fichier remplit les deux séries d'un coup : la Terminale C et la
-- Terminale D. Il n'a besoin de rien d'autre pour tourner. Si la matière, les
-- classes, les programmes ou le chapitre n'existent pas encore, il les crée
-- lui-même au passage.
--
-- Lancez-le quand vous voulez, dans l'ordre que vous voulez, et autant de fois
-- que vous voulez : quand le chapitre a déjà ses leçons, le script s'en rend
-- compte et n'ajoute rien.
-- ---------------------------------------------------------------------------
DO $inf7$
DECLARE
  v_lettres text[] := ARRAY['C', 'D'];
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
  INSERT INTO public.matieres (nom) VALUES ('Informatique') ON CONFLICT (nom) DO NOTHING;
  SELECT id INTO v_matiere_id FROM public.matieres WHERE nom = 'Informatique';

  -- L'établissement, on le retrouve à partir des classes déjà en base.
  SELECT count(DISTINCT etablissement_id) INTO v_nb_etabs FROM public.classes;
  IF v_nb_etabs <> 1 THEN
    RAISE EXCEPTION 'Je ne sais pas à quel établissement rattacher ces classes : j''en trouve % dans la table des classes, et il m''en faudrait exactement un.', v_nb_etabs;
  END IF;
  SELECT etablissement_id INTO v_etab_id FROM public.classes LIMIT 1;

  -- On refait le même travail trois fois : pour la 1ère C, puis la D, puis la E.
  FOR v_i IN 1..2 LOOP
    v_lettre := v_lettres[v_i];
    v_nom := 'Terminale ' || v_lettre;

    -- Le programme de Chimie de cette série existe-t-il déjà ?
    SELECT p.id INTO v_programme_id FROM public.programmes p
    WHERE p.titre = 'Informatique — ' || v_nom;

    -- Non : on le crée, et la classe avec si besoin.
    IF v_programme_id IS NULL THEN
      -- La classe a pu être écrite de plusieurs façons : Terminale C, Tle C, TC.
      SELECT id INTO v_classe_id FROM public.classes
      WHERE etablissement_id = v_etab_id
        AND (nom = v_nom OR nom ILIKE 'T%le ' || v_lettre OR nom ILIKE 'Terminale ' || v_lettre)
      ORDER BY (nom = v_nom) DESC
      LIMIT 1;

      IF v_classe_id IS NULL THEN
        INSERT INTO public.classes (etablissement_id, nom, niveau, filiere)
        VALUES (v_etab_id, v_nom, 'Terminale', v_lettre)
        RETURNING id INTO v_classe_id;
        RAISE NOTICE 'La classe % n''existait pas : je viens de la créer.', v_nom;
      END IF;

      INSERT INTO public.programmes (matiere_id, classe_id, etablissement_id, titre, description)
      VALUES (v_matiere_id, v_classe_id, v_etab_id, 'Informatique — ' || v_nom,
              'Programme officiel d''Informatique, classe de Terminale ' || v_lettre ||
              ' (Cameroun) — 3 modules, 25 chapitres.')
      RETURNING id INTO v_programme_id;
      RAISE NOTICE 'Programme d''Informatique de la % : créé.', v_nom;
    END IF;

    -- Le chapitre lui-même.
    SELECT id INTO v_chapitre_id FROM public.chapitres
    WHERE programme_id = v_programme_id AND ordre = 6;

    IF v_chapitre_id IS NULL THEN
      INSERT INTO public.chapitres (programme_id, titre, ordre, niveau)
      VALUES (v_programme_id, 'Les fonctions d''un classeur dans la production d''un document', 6, 'Module 1 : Systèmes informatiques')
      RETURNING id INTO v_chapitre_id;
      RAISE NOTICE '% : chapitre 6 créé.', v_nom;
    END IF;

    -- Les leçons. Si le chapitre en a déjà, on passe son tour sans rien toucher.
    SELECT count(*) INTO v_deja FROM public.concepts WHERE chapitre_id = v_chapitre_id;
    IF v_deja > 0 THEN
      RAISE NOTICE '% : le chapitre 6 a déjà ses % leçons, je n''y touche pas.', v_nom, v_deja;
      CONTINUE;
    END IF;

    INSERT INTO public.concepts
      (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes) VALUES
      (v_chapitre_id, 'Les références : relative, absolue, et entre feuilles', 1, 'texte', '
Avant les fonctions, il faut comprendre les références — sans quoi la recopie
d''une formule donne n''importe quoi.

### La référence relative

C''est l''écriture ordinaire : `B2`, `D5`.

Quand on **recopie** la formule vers le bas ou vers la droite, la référence
**s''adapte**. Une formule `=B2*C2` écrite en D2 devient `=B3*C3` en D3, puis
`=B4*C4` en D4.

C''est exactement ce qu''on veut dans un bulletin : chaque ligne calcule avec ses
propres valeurs. On appelle cela la **recopie incrémentée**, et c''est la
technique que le Baccalauréat 2023 demandait de nommer.

Pour recopier : sélectionner la cellule, saisir le petit carré en bas à droite —
la **poignée de recopie** — et tirer.

### La référence absolue

Parfois, on ne veut **pas** que la référence bouge : le taux de TVA, le taux de
change, le total général.

On la fige avec le **signe dollar** : `$B$1`.

Le dollar devant la lettre fige la **colonne**, le dollar devant le chiffre fige
la **ligne**. `$B1` fige la colonne seule, `B$1` fige la ligne seule : c''est la
référence **mixte**.

Le raccourci : sélectionner la référence dans la formule et appuyer sur la
touche `F4`.

```
D2 = C2 * $B$1        le prix hors taxe fois le taux figé en B1
```

Recopiée vers le bas, cette formule devient `=C3*$B$1`, puis `=C4*$B$1` : la
première référence suit, la seconde reste.

### La référence entre feuilles

C''est une action explicite du programme : **utiliser les références entre
plusieurs feuilles de calculs**.

La syntaxe met le **nom de la feuille, un point d''exclamation, puis la
cellule** :

```
=Trimestre1!D7
=MOYENNE(Trimestre1!D7;Trimestre2!D7;Trimestre3!D7)
```

Si le nom de la feuille contient un **espace**, il faut l''encadrer
d''**apostrophes** :

```=''Trimestre 1''!D7```

En pratique, on n''a pas besoin de taper tout cela : on commence la formule, on
clique sur l''onglet de l''autre feuille, on clique sur la cellule, et le tableur
écrit la référence tout seul.

C''est ainsi qu''on construit une feuille **Bilan** qui va chercher les moyennes
dans les trois feuilles trimestrielles, sans ressaisir une seule note.

---

**Exercice corrigé**

*Un classeur contient trois feuilles nommées Trimestre1, Trimestre2 et
Trimestre3, chacune avec la moyenne de l''élève en D7. Une quatrième feuille
nommée Bilan doit afficher la moyenne annuelle. Écrire la formule.*

**Correction.**

```
=MOYENNE(Trimestre1!D7;Trimestre2!D7;Trimestre3!D7)
```

*Trois points vérifiés par le correcteur.* Le signe **égal** en tête, sans quoi
le tableur affiche du texte. Le **point d''exclamation** entre le nom de la
feuille et la cellule. Et le **point-virgule** comme séparateur d''arguments.

*On accepte aussi la forme développée :*

```
=(Trimestre1!D7+Trimestre2!D7+Trimestre3!D7)/3
```

*mais la première est préférable : si une moyenne trimestrielle manque, MOYENNE
l''ignore, tandis que la division par 3 donnerait un résultat faux.*
', NULL, 26),
      (v_chapitre_id, 'Simulation : recopier une formule', 2, 'interactif', '{
  "widget": "references-cellules",
  "consigne": "Écris une formule, attrape la poignée de recopie et tire vers le bas : la simulation te montre, cellule par cellule, comment chaque référence relative se décale. Ajoute un dollar et regarde celle-là rester immobile pendant que les autres suivent. Un troisième volet relie trois feuilles trimestrielles à une feuille Bilan, et tu vois la référence Trimestre1!D7 s''écrire toute seule quand tu cliques sur l''onglet."
}', NULL, 10),
      (v_chapitre_id, 'Les sept fonctions au programme', 3, 'texte', '
Le programme nomme sept fonctions, et pas une de plus. Les voici avec leur
syntaxe exacte.

### La forme d''une fonction

Une fonction se compose d''un **nom**, suivi d''**arguments entre parenthèses**,
**séparés par des points-virgules**. Et toute formule commence par le signe
**égal**.

Pour l''insérer sans la taper : onglet **Formules**, **Insérer une fonction**, ou
le bouton **fx** de la barre de formule.

### Les trois fonctions de calcul

**SOMME** additionne.

```
=SOMME(nombre1;[nombre2];…)
=SOMME(B2:B10)
```

**PRODUIT** multiplie.

```
=PRODUIT(nombre1;[nombre2];…)
=PRODUIT(B2;C2)
```

**MOYENNE** calcule la moyenne arithmétique.

```
=MOYENNE(nombre1;[nombre2];…)
=MOYENNE(B2:B10)
```

### La fonction de décision

**SI** renvoie une valeur si la condition est vraie, une autre sinon.

```
=SI(test_logique;[valeur_si_vrai];[valeur_si_faux])
=SI(A1>10;"ADMIS";"REFUSE")
```

Les textes se mettent **entre guillemets**, les nombres non. Et une fonction SI
peut en contenir une autre, pour traiter plus de deux cas.

### La fonction de classement

**RANG** donne le rang d''une valeur dans une plage.

```
=RANG(nombre;référence;[ordre])
=RANG(A1;A1:A8;0)
```

Le troisième argument décide du sens : **vide ou 0 pour l''ordre décroissant** —
le plus grand est premier, ce qu''on veut pour des notes —, une valeur non nulle
pour l''ordre croissant.

Attention en recopiant : la **plage de référence doit être figée** avec des
dollars, sinon elle glisse et chaque élève est classé dans une plage
différente.

```
=RANG(D2;$D$2:$D$40;0)
```

### Les deux fonctions conditionnelles

**NB.SI** **compte** les cellules qui répondent à un critère.

```
=NB.SI(plage;critères)
=NB.SI(D3:D7;">=10")
```

**SOMME.SI** **additionne** les valeurs qui répondent à un critère.

```
=SOMME.SI(plage;critère;[somme_plage])
=SOMME.SI(A1:A5;">10")
=SOMME.SI(C2:C4;">=2";B2:B4)
```

Dans la forme à trois arguments, le critère est **testé sur la première plage**
et la **somme est faite sur la troisième**. C''est la forme la plus demandée, et
celle qu''on comprend mal la première fois.

**Le critère se met toujours entre guillemets** dès qu''il contient un opérateur :
`">=10"`, `"<5"`, `"Douala"`.

---

**Exercice corrigé**

*Dans un devis, la colonne B contient les prix unitaires et la colonne C les
quantités, sur les lignes 2 à 4 :*

| | A | B — Prix unitaire | C — Quantité |
| --- | --- | --- | --- |
| 2 | Ordinateur | 250 000 | 2 |
| 3 | Imprimante | 120 000 | 1 |
| 4 | Onduleur | 65 000 | 3 |

*Donner le résultat de la formule `=SOMME.SI(C2:C4;">=2";B2:B4)`.*

**Correction.** La fonction **teste le critère sur C2:C4** et **additionne les
valeurs correspondantes de B2:B4**.

Ligne par ligne :

| Ligne | C vaut | Critère « ≥ 2 » | B pris en compte |
| --- | --- | --- | --- |
| 2 | 2 | **vrai** | 250 000 |
| 3 | 1 | faux | — |
| 4 | 3 | **vrai** | 65 000 |

$$250\,000 + 65\,000 = 315\,000$$

Le résultat est donc **315 000**.

*Cette question est tombée au Baccalauréat 2024, pour 0,75 point. Le piège est
de sommer la colonne C au lieu de la colonne B : on teste sur la première plage,
on additionne sur la troisième.*
', NULL, 30),
      (v_chapitre_id, 'Simulation : les sept fonctions à l''essai', 4, 'interactif', '{
  "widget": "fonctions-tableur",
  "consigne": "Une feuille de calcul remplie t''attend, et une barre de formule où tu composes tes fonctions. Les sept fonctions du programme sont reconnues : tape ta formule et le résultat s''affiche, avec les cellules concernées qui s''éclairent dans le tableau. La simulation décompose SOMME.SI ligne par ligne — critère testé d''un côté, valeur additionnée de l''autre — et te signale le guillemet oublié autour d''un critère."
}', NULL, 10),
      (v_chapitre_id, 'Figure : un bulletin de notes et les formules derrière', 5, 'figure', '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 560 260" width="560" height="260">
<rect width="560" height="260" fill="#ffffff"/>
<text x="280" y="22" text-anchor="middle" font-size="14" font-weight="700" fill="#0f172a">Un bulletin de notes, et les formules derrière</text>

<rect x="20" y="34" width="330" height="20" fill="#1e293b"/>
<text x="38" y="48" font-size="9" font-weight="700" fill="#ffffff">A — Matière</text>
<text x="172" y="48" font-size="9" font-weight="700" fill="#ffffff">B — Note</text>
<text x="240" y="48" font-size="9" font-weight="700" fill="#ffffff">C — Coef</text>
<text x="300" y="48" font-size="9" font-weight="700" fill="#ffffff">D — N×C</text>

<g font-size="9" fill="#0f172a">
<rect x="20" y="54" width="330" height="22" fill="#f8fafc" stroke="#cbd5e1"/>
<text x="38" y="69">Mathématiques</text><text x="180" y="69">14</text><text x="248" y="69">5</text><text x="306" y="69">70</text>
<rect x="20" y="76" width="330" height="22" fill="#ffffff" stroke="#cbd5e1"/>
<text x="38" y="91">Physique</text><text x="180" y="91">11</text><text x="248" y="91">4</text><text x="306" y="91">44</text>
<rect x="20" y="98" width="330" height="22" fill="#f8fafc" stroke="#cbd5e1"/>
<text x="38" y="113">Informatique</text><text x="180" y="113">16</text><text x="248" y="113">2</text><text x="306" y="113">32</text>
<rect x="20" y="120" width="330" height="22" fill="#ffffff" stroke="#cbd5e1"/>
<text x="38" y="135">Français</text><text x="180" y="135">9</text><text x="248" y="135">3</text><text x="306" y="135">27</text>
</g>

<rect x="20" y="142" width="330" height="24" fill="#fef3c7" stroke="#ca8a04" stroke-width="1.4"/>
<text x="38" y="158" font-size="9" font-weight="700" fill="#78350f">TOTAUX (ligne 6)</text>
<text x="248" y="158" font-size="9" font-weight="700" fill="#78350f">14</text>
<text x="306" y="158" font-size="9" font-weight="700" fill="#78350f">173</text>

<rect x="20" y="166" width="330" height="24" fill="#dcfce7" stroke="#15803d" stroke-width="1.4"/>
<text x="38" y="182" font-size="9" font-weight="700" fill="#14532d">MOYENNE</text>
<text x="300" y="182" font-size="9" font-weight="700" fill="#14532d">12,36</text>

<text x="372" y="50" font-size="10" font-weight="700" fill="#0f172a">Les formules</text>
<text x="372" y="70" font-size="9" font-family="monospace" fill="#2563eb">D2 = B2*C2</text>
<text x="372" y="88" font-size="9" fill="#64748b">puis recopie vers le bas</text>
<text x="372" y="112" font-size="9" font-family="monospace" fill="#2563eb">C6 = SOMME(C2:C5)</text>
<text x="372" y="130" font-size="9" font-family="monospace" fill="#2563eb">D6 = SOMME(D2:D5)</text>
<text x="372" y="156" font-size="9" font-family="monospace" fill="#15803d">D7 = D6/C6</text>
<text x="372" y="174" font-size="9" fill="#64748b">173 / 14 = 12,36</text>
<text x="372" y="202" font-size="9" font-family="monospace" fill="#b45309">= NB.SI(B2:B5;&quot;&gt;=10&quot;)</text>
<text x="372" y="220" font-size="9" fill="#64748b">compte 3 notes sur 4</text>

<text x="280" y="248" text-anchor="middle" font-size="10" fill="#64748b">La moyenne pondérée se divise par le total des coefficients, jamais par le nombre de matières.</text>
</svg>', NULL, 5),
      (v_chapitre_id, 'Produire un document : facture, devis et bulletin', 6, 'texte', '
Le programme demande de **reproduire une facture, un devis, un bulletin de paie
ou de notes**. Ces quatre documents se construisent sur le même squelette.

### Le squelette commun

1. Un **en-tête** fusionné et centré : le nom de l''établissement ou de
l''entreprise, le type de document, la date.
2. Un **tableau de lignes**, une par article ou par matière.
3. Une **colonne calculée** par ligne : montant, ou note pondérée.
4. Une **ligne de totaux**, avec `SOMME`.
5. Un **résultat final** : net à payer, moyenne, mention.

### La facture et le devis

La différence tient en un mot : le **devis** est une **proposition**, la
**facture** est une **demande de paiement**. Les calculs sont identiques.

```
D2  = B2*C2                     montant de la ligne
D6  = SOMME(D2:D5)              total hors taxe
D7  = D6*$B$9                   la TVA, taux figé en B9
D8  = D6+D7                     net à payer
```

Le taux de TVA se place dans **une cellule à part**, référencée en **absolu**.
S''il change, on le corrige à un seul endroit.

### Le bulletin de notes

```
D2  = B2*C2                     note × coefficient
C6  = SOMME(C2:C5)              total des coefficients
D6  = SOMME(D2:D5)              total des points
D7  = D6/C6                     la moyenne pondérée
E2  = RANG(D2;$D$2:$D$40;0)     le rang de l''élève
F2  = SI(D7>=10;"ADMIS";"REFUSE")
```

**La moyenne pondérée se divise par le total des coefficients**, jamais par le
nombre de matières. C''est l''erreur la plus fréquente en copie.

### Le bulletin de paie

Même principe, avec les retenues :

```
D5  = D2*$B$10                  cotisation CNPS, taux figé
D6  = D2*$B$11                  impôt
D8  = D2-D5-D6                  net à payer
```

---

**Exercice corrigé**

*Sur un bulletin, les notes sont en D3:D7 et les coefficients en C3:C7.*
*1. Quelle formule place-t-on en E9 pour obtenir le total des coefficients ?
2. Quelle formule place-t-on en D10 pour compter le nombre de notes supérieures
ou égales à 10 ? 3. Comment obtient-on les autres notes trimestrielles sans les
saisir une à une ?*

**Correction.**

1. `=SOMME(C3:C7)`

2. `=NB.SI(D3:D7;">=10")`

Le critère **doit être entre guillemets** : il contient un opérateur. Et c''est
bien **NB.SI** qu''on emploie, puisqu''on **compte** ; `SOMME.SI` additionnerait
les notes au lieu de les dénombrer.

3. Par la **recopie incrémentée** : on écrit la formule une fois dans la
première cellule, on attrape la poignée de recopie en bas à droite, et on tire.
Les **références relatives** s''adaptent d''elles-mêmes à chaque ligne.

*Les trois questions viennent de la partie tableur du Baccalauréat 2023.*
', NULL, 28),
      (v_chapitre_id, 'Simulation : construire un bulletin de notes', 7, 'interactif', '{
  "widget": "bulletin-notes",
  "consigne": "Un bulletin vide t''attend, avec ses matières et ses coefficients. Remplis les cellules de formule une par une : la note pondérée, les totaux, la moyenne, le rang, la mention. La simulation vérifie chaque formule et signale les deux fautes classiques — diviser par le nombre de matières au lieu du total des coefficients, et oublier de figer la plage du RANG avant de recopier."
}', NULL, 10),
      (v_chapitre_id, 'Quiz du chapitre 6', 8, 'quiz', '{
  "titre": "Vérifie que tu as compris",
  "questions": [
    {
      "question": "Que devient la formule =B2*C2 écrite en D2 lorsqu''on la recopie en D3 ?",
      "choix": [
        "Elle reste =B2*C2",
        "Elle devient =B3*C3",
        "Elle devient =C2*D2",
        "Elle affiche une erreur"
      ],
      "bonne": 1,
      "explication": "Les références relatives s''adaptent : c''est la recopie incrémentée, et c''est exactement ce qu''on veut dans un bulletin."
    },
    {
      "question": "À quoi sert le signe dollar dans la référence $B$1 ?",
      "choix": [
        "À afficher un montant",
        "À figer la référence pour qu''elle ne bouge pas à la recopie",
        "À multiplier par cent",
        "À protéger la cellule"
      ],
      "bonne": 1,
      "explication": "C''est la référence absolue. Le dollar devant la lettre fige la colonne, celui devant le chiffre fige la ligne. Raccourci : la touche F4."
    },
    {
      "question": "Comment référence-t-on la cellule D7 de la feuille Trimestre1 ?",
      "choix": [
        "Trimestre1.D7",
        "Trimestre1!D7",
        "Trimestre1:D7",
        "=D7(Trimestre1)"
      ],
      "bonne": 1,
      "explication": "Le nom de la feuille, un point d''exclamation, puis la cellule. Si le nom contient un espace, on l''encadre d''apostrophes."
    },
    {
      "question": "Quelle fonction compte les cellules répondant à un critère ?",
      "choix": [
        "SOMME.SI",
        "NB.SI",
        "SI",
        "RANG"
      ],
      "bonne": 1,
      "explication": "NB.SI compte, SOMME.SI additionne. Confondre les deux change complètement le résultat."
    },
    {
      "question": "Dans =SOMME.SI(C2:C4;\\u0022>=2\\u0022;B2:B4), sur quelle plage le critère est-il testé ?",
      "choix": [
        "Sur B2:B4",
        "Sur C2:C4",
        "Sur les deux",
        "Sur toute la feuille"
      ],
      "bonne": 1,
      "explication": "Le critère est testé sur la PREMIÈRE plage, et la somme est faite sur la TROISIÈME. C''est le piège du Baccalauréat 2024."
    },
    {
      "question": "Que donne =RANG(A1;A1:A8;0) ?",
      "choix": [
        "La moyenne de la plage",
        "Le rang de A1 dans la plage, en ordre décroissant",
        "Le rang en ordre croissant",
        "Le nombre de valeurs de la plage"
      ],
      "bonne": 1,
      "explication": "Troisième argument vide ou 0 : ordre décroissant, le plus grand est premier. Et il faut figer la plage avec des dollars avant de recopier."
    },
    {
      "question": "Comment calcule-t-on une moyenne pondérée sur un bulletin ?",
      "choix": [
        "En divisant le total des points par le nombre de matières",
        "En divisant le total des points par le total des coefficients",
        "Avec la fonction MOYENNE sur les notes",
        "En additionnant les notes"
      ],
      "bonne": 1,
      "explication": "Diviser par le nombre de matières est l''erreur la plus fréquente en copie : elle ignore complètement les coefficients."
    }
  ]
}', NULL, 5);

    RAISE NOTICE '% : 8 leçons ajoutées au chapitre 6, Les fonctions d''un classeur dans la production d''un document.', v_nom;
  END LOOP;
END $inf7$;
