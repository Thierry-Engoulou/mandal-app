-- ---------------------------------------------------------------------------
-- M'Andal — Informatique, classes de Première
-- Chapitre 8 : Notions d'algorithmique
-- Module 2 : Algorithmique et programmation — 7 leçons
--
-- Ce fichier remplit les trois séries d'un coup : la 1ère A, la 1ère C et la
-- 1ère D. Il n'a besoin de rien d'autre pour tourner. Si la matière, les
-- classes, les programmes ou le chapitre n'existent pas encore, il les crée
-- lui-même au passage.
--
-- Lancez-le quand vous voulez, dans l'ordre que vous voulez, et autant de fois
-- que vous voulez : quand le chapitre a déjà ses leçons, le script s'en rend
-- compte et n'ajoute rien.
-- ---------------------------------------------------------------------------
DO $inf1$
DECLARE
  v_lettres text[] := ARRAY['A', 'C', 'D'];
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
  FOR v_i IN 1..3 LOOP
    v_lettre := v_lettres[v_i];
    v_nom := '1ère ' || v_lettre;

    -- Le programme de Chimie de cette série existe-t-il déjà ?
    SELECT p.id INTO v_programme_id FROM public.programmes p
    WHERE p.titre = 'Informatique — ' || v_nom;

    -- Non : on le crée, et la classe avec si besoin.
    IF v_programme_id IS NULL THEN
      -- La classe a pu être écrite de plusieurs façons : 1ère A, 1ere A, Première A.
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
      VALUES (v_matiere_id, v_classe_id, v_etab_id, 'Informatique — ' || v_nom,
              'Programme officiel d''Informatique, classe de Première ' || v_lettre ||
              ' (Cameroun) — 3 modules, 20 chapitres.')
      RETURNING id INTO v_programme_id;
      RAISE NOTICE 'Programme d''Informatique de la % : créé.', v_nom;
    END IF;

    -- Le chapitre lui-même.
    SELECT id INTO v_chapitre_id FROM public.chapitres
    WHERE programme_id = v_programme_id AND ordre = 8;

    IF v_chapitre_id IS NULL THEN
      INSERT INTO public.chapitres (programme_id, titre, ordre, niveau)
      VALUES (v_programme_id, 'Notions d''algorithmique', 8, 'Module 2 : Algorithmique et programmation')
      RETURNING id INTO v_chapitre_id;
      RAISE NOTICE '% : chapitre 8 créé.', v_nom;
    END IF;

    -- Les leçons. Si le chapitre en a déjà, on passe son tour sans rien toucher.
    SELECT count(*) INTO v_deja FROM public.concepts WHERE chapitre_id = v_chapitre_id;
    IF v_deja > 0 THEN
      RAISE NOTICE '% : le chapitre 8 a déjà ses % leçons, je n''y touche pas.', v_nom, v_deja;
      CONTINUE;
    END IF;

    INSERT INTO public.concepts
      (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes) VALUES
      (v_chapitre_id, 'Qu''est-ce qu''un algorithme ?', 1, 'texte', '
Changement complet de module. On range les tournevis : on va apprendre à faire
travailler la machine, pas à la réparer.

### La définition

Un **algorithme** est une **suite finie et ordonnée d''instructions** permettant
de résoudre un problème donné.

Trois mots à peser.

**Suite** : les instructions se succèdent, l''une après l''autre.

**Finie** : elle s''arrête. Un algorithme qui tourne sans jamais finir n''est pas
un algorithme, c''est une erreur.

**Ordonnée** : l''ordre compte. Mettre de l''eau puis le riz, ou le riz puis
l''eau, ne donne pas le même résultat.

### Un algorithme n''est pas un programme

C''est la distinction la plus demandée en examen.

L''**algorithme** est le **raisonnement**. Il s''écrit dans un langage proche du
français, qu''on appelle le **langage de description d''algorithme**, abrégé
**LDA**. Il ne dépend d''aucune machine ni d''aucun langage.

Le **programme** est la **traduction** de cet algorithme dans un langage de
programmation — Python, C, Pascal, PHP — pour qu''un ordinateur l''exécute.

Autrement dit : on **réfléchit** une fois en algorithme, on **traduit** autant
de fois qu''on veut en programmes.

### Ses trois parties

Tout algorithme en LDA se présente ainsi :

```
Algorithme : PrixTTC

Constante
    tva = 0.07 ;
Variable
    pu, q, p : réel ;

Début
    lire(pu, q)
    p ← pu * q
    écrire(p * (1 + tva))
Fin
```

**L''en-tête** : le mot `Algorithme` suivi du nom. Il dit *qui*.

**Les déclarations** : les parties `Constante` et `Variable`, où l''on annonce
tout ce dont on va se servir, avec son type. Elles disent *avec quoi*.

**Le corps** : tout ce qui se trouve entre `Début` et `Fin`. Il dit *comment*.

Un algorithme sans `Début` et `Fin`, ou dont les variables ne sont pas
déclarées, est faux — même si le raisonnement est juste. En examen, cela coûte
des points à chaque fois.

---

**Exercice corrigé**

*Donner la différence entre un algorithme et un programme.*

**Correction.** Un **algorithme** est la description du raisonnement permettant
de résoudre un problème ; il est écrit en langage de description d''algorithme,
proche du français, et il est **indépendant** de tout langage de programmation
et de toute machine.

Un **programme** est la **traduction** d''un algorithme dans un langage de
programmation donné, afin qu''il puisse être exécuté par un ordinateur.

En une phrase : l''algorithme se **lit** par un humain, le programme s''**exécute**
par une machine.
', NULL, 25),
      (v_chapitre_id, 'Figure : les trois parties d''un algorithme', 2, 'figure', '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 520 300" width="520" height="300">
<rect width="520" height="300" fill="#ffffff"/>
<text x="260" y="22" text-anchor="middle" font-size="14" font-weight="700" fill="#0f172a">Les trois parties d&apos;un algorithme</text>

<rect x="112" y="38" width="296" height="40" rx="6" fill="#fed7aa" stroke="#ea580c" stroke-width="2"/>
<text x="130" y="63" font-size="13" font-family="monospace" fill="#7c2d12">Algorithme : PrixTTC</text>
<text x="420" y="57" font-size="10" font-weight="700" fill="#ea580c">1. L&apos;EN-TÊTE</text>
<text x="420" y="70" font-size="9" fill="#9a3412">il nomme</text>

<rect x="112" y="84" width="296" height="86" rx="6" fill="#dbeafe" stroke="#2563eb" stroke-width="2"/>
<text x="130" y="106" font-size="13" font-family="monospace" fill="#1e3a8a">Constante</text>
<text x="146" y="124" font-size="13" font-family="monospace" fill="#1e3a8a">tva = 0.07 ;</text>
<text x="130" y="142" font-size="13" font-family="monospace" fill="#1e3a8a">Variable</text>
<text x="146" y="160" font-size="13" font-family="monospace" fill="#1e3a8a">pu, q, p : réel ;</text>
<text x="420" y="118" font-size="10" font-weight="700" fill="#2563eb">2. LES</text>
<text x="420" y="131" font-size="10" font-weight="700" fill="#2563eb">DÉCLARATIONS</text>
<text x="420" y="146" font-size="9" fill="#1e40af">elles réservent</text>
<text x="420" y="158" font-size="9" fill="#1e40af">la place</text>

<rect x="112" y="176" width="296" height="110" rx="6" fill="#dcfce7" stroke="#16a34a" stroke-width="2"/>
<text x="130" y="198" font-size="13" font-family="monospace" font-weight="700" fill="#14532d">Début</text>
<text x="146" y="216" font-size="13" font-family="monospace" fill="#14532d">lire(pu, q)</text>
<text x="146" y="234" font-size="13" font-family="monospace" fill="#14532d">p ← pu * q</text>
<text x="146" y="252" font-size="13" font-family="monospace" fill="#14532d">écrire(p * (1 + tva))</text>
<text x="130" y="274" font-size="13" font-family="monospace" font-weight="700" fill="#14532d">Fin</text>
<text x="420" y="222" font-size="10" font-weight="700" fill="#16a34a">3. LE CORPS</text>
<text x="420" y="237" font-size="9" fill="#166534">il travaille,</text>
<text x="420" y="249" font-size="9" fill="#166534">entre Début</text>
<text x="420" y="261" font-size="9" fill="#166534">et Fin</text>

<text x="104" y="63" text-anchor="end" font-size="11" font-weight="700" fill="#64748b">QUI ?</text>
<text x="104" y="130" text-anchor="end" font-size="11" font-weight="700" fill="#64748b">AVEC QUOI ?</text>
<text x="104" y="230" text-anchor="end" font-size="11" font-weight="700" fill="#64748b">COMMENT ?</text>
</svg>', NULL, 5),
      (v_chapitre_id, 'Simulation : reconstituer un algorithme', 3, 'interactif', '{
  "widget": "parties-algorithme",
  "consigne": "Les lignes d''un algorithme te sont données en désordre : l''en-tête, les déclarations, Début, les instructions, Fin. Remets-les dans l''ordre. La simulation refuse les ordres impossibles en t''expliquant pourquoi — une variable utilisée avant d''être déclarée, une instruction placée hors du corps — et te montre les trois blocs se colorer dès que la structure est correcte."
}', NULL, 10),
      (v_chapitre_id, 'De l''énoncé à l''algorithme', 4, 'texte', '
L''erreur de la plupart des élèves est de commencer à écrire tout de suite. Un
algorithme s''**analyse** avant de s''écrire, et l''analyse tient en trois
questions.

### Les trois questions

**1. Quelles sont les données d''entrée ?** Ce que l''algorithme doit recevoir de
l''extérieur, et qu''il ne peut pas deviner. Ce seront les `lire(…)`.

**2. Quel est le traitement ?** Les calculs et les décisions qui mènent de
l''entrée au résultat. Ce seront les affectations et les tests.

**3. Quels sont les résultats de sortie ?** Ce que l''algorithme doit afficher.
Ce seront les `écrire(…)`.

Tu reconnais le schéma du chapitre 1 : **Entrée — Traitement — Sortie**. C''est
le même, et ce n''est pas un hasard.

### Un exemple complet

*Problème : calculer le périmètre et l''aire d''un rectangle.*

**Entrées** : la longueur `L` et la largeur `l`, deux réels.
**Traitement** : $P = 2 \times (L + l)$ et $A = L \times l$.
**Sorties** : `P` et `A`.

```
Algorithme : Rectangle

Variable
    L, l, P, A : réel ;

Début
    écrire("Entrez la longueur et la largeur :")
    lire(L, l)
    P ← 2 * (L + l)
    A ← L * l
    écrire("Périmètre = ", P)
    écrire("Aire = ", A)
Fin
```

Remarque le `écrire` **avant** le `lire`. Il ne sert pas au calcul : il dit à
l''utilisateur ce qu''on attend de lui. Un algorithme qui lit sans rien demander
laisse l''utilisateur devant un écran muet.

### L''organigramme

Un **organigramme** — ou *ordinogramme* — est la **représentation graphique**
d''un algorithme. Il utilise quatre symboles, détaillés dans la figure qui suit.

Il est plus lisible qu''un texte pour montrer des choix, et beaucoup moins
pratique dès que l''algorithme grandit. En examen, on demande souvent l''un ou
l''autre : lis bien la consigne.

---

**Exercice corrigé**

*Écrire un algorithme qui lit la note d''un élève sur 20 et affiche cette note
sur 100.*

**Correction.** D''abord l''analyse.

*Entrée* : la note sur 20, un réel.
*Traitement* : $n_{100} = n_{20} \times 5$, puisque $100 / 20 = 5$.
*Sortie* : la note sur 100.

```
Algorithme : NoteSurCent

Variable
    n20, n100 : réel ;

Début
    écrire("Entrez la note sur 20 :")
    lire(n20)
    n100 ← n20 * 5
    écrire("Note sur 100 : ", n100)
Fin
```

Vérification sur un cas simple : avec `n20 = 12`, on obtient 60. Prends toujours
cette habitude de tester ton algorithme à la main sur une valeur. C''est ainsi
qu''on attrape les erreurs de signe et de facteur.
', NULL, 25),
      (v_chapitre_id, 'Figure : les symboles de l''organigramme', 5, 'figure', '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 520 320" width="520" height="320">
<rect width="520" height="320" fill="#ffffff"/>
<text x="260" y="22" text-anchor="middle" font-size="14" font-weight="700" fill="#0f172a">Les symboles de l&apos;organigramme</text>

<ellipse cx="90" cy="64" rx="56" ry="22" fill="#1e293b"/>
<text x="90" y="69" text-anchor="middle" font-size="12" font-weight="700" fill="#ffffff">Début / Fin</text>
<text x="176" y="60" font-size="11" fill="#334155">l&apos;ovale ouvre et ferme</text>
<text x="176" y="76" font-size="10" fill="#64748b">un seul au début, un seul à la fin</text>

<polygon points="40,114 150,114 134,152 56,152" fill="#dbeafe" stroke="#2563eb" stroke-width="2"/>
<text x="95" y="138" text-anchor="middle" font-size="12" font-weight="700" fill="#1e3a8a">lire / écrire</text>
<text x="176" y="130" font-size="11" fill="#334155">le parallélogramme : les entrées-sorties</text>
<text x="176" y="146" font-size="10" fill="#64748b">tout ce qui entre ou sort de l&apos;algorithme</text>

<rect x="40" y="176" width="110" height="38" rx="2" fill="#dcfce7" stroke="#16a34a" stroke-width="2"/>
<text x="95" y="200" text-anchor="middle" font-size="12" font-weight="700" fill="#14532d">p ← pu * q</text>
<text x="176" y="192" font-size="11" fill="#334155">le rectangle : un traitement</text>
<text x="176" y="208" font-size="10" fill="#64748b">un calcul, une affectation</text>

<polygon points="95,238 150,266 95,294 40,266" fill="#fef3c7" stroke="#ca8a04" stroke-width="2"/>
<text x="95" y="270" text-anchor="middle" font-size="11" font-weight="700" fill="#78350f">x &gt; 0 ?</text>
<text x="176" y="258" font-size="11" fill="#334155">le losange : un test</text>
<text x="176" y="274" font-size="10" fill="#64748b">deux sorties, une pour oui, une pour non</text>
<text x="176" y="290" font-size="10" fill="#64748b">c&apos;est le seul symbole à deux sorties</text>
</svg>', NULL, 5),
      (v_chapitre_id, 'Simulation : analyser un problème', 6, 'interactif', '{
  "widget": "analyse-probleme",
  "consigne": "Six énoncés te sont proposés — le prix TTC d''un achat, la moyenne de trois notes, la conversion d''une durée en secondes. Pour chacun, tu dois ranger les grandeurs en entrées, traitement et sorties avant d''avoir le droit d''écrire la moindre ligne. La simulation te montre ensuite l''algorithme complet, et pourquoi une grandeur rangée du mauvais côté le casse."
}', NULL, 10),
      (v_chapitre_id, 'Quiz du chapitre 8', 7, 'quiz', '{
  "titre": "Vérifie que tu as compris",
  "questions": [
    {
      "question": "Qu''est-ce qu''un algorithme ?",
      "choix": [
        "Un programme écrit en Python",
        "Une suite finie et ordonnée d''instructions permettant de résoudre un problème",
        "Un logiciel de calcul",
        "Le langage de la machine"
      ],
      "bonne": 1,
      "explication": "Les trois mots comptent : suite, car les instructions se succèdent ; finie, car elle s''arrête ; ordonnée, car l''ordre change le résultat."
    },
    {
      "question": "Quelle est la différence entre un algorithme et un programme ?",
      "choix": [
        "Aucune, ce sont deux mots pour la même chose",
        "L''algorithme est le raisonnement, indépendant de tout langage ; le programme est sa traduction dans un langage de programmation",
        "L''algorithme est plus long",
        "Le programme s''écrit en français, l''algorithme en anglais"
      ],
      "bonne": 1,
      "explication": "On réfléchit une fois en algorithme, on traduit autant de fois qu''on veut en programmes. L''algorithme se lit par un humain, le programme s''exécute par une machine."
    },
    {
      "question": "Que signifie le sigle LDA ?",
      "choix": [
        "Logiciel de Développement Algorithmique",
        "Langage de Description d''Algorithme",
        "Liste des Données Associées",
        "Langage Déclaratif Avancé"
      ],
      "bonne": 1,
      "explication": "C''est le langage proche du français dans lequel on écrit les algorithmes, avec Algorithme, Variable, Début et Fin."
    },
    {
      "question": "Quelles sont les trois parties d''un algorithme ?",
      "choix": [
        "Début, milieu, fin",
        "L''en-tête, les déclarations et le corps",
        "Entrée, traitement, sortie",
        "Variables, constantes, instructions"
      ],
      "bonne": 1,
      "explication": "L''en-tête dit QUI, les déclarations disent AVEC QUOI, le corps — entre Début et Fin — dit COMMENT."
    },
    {
      "question": "Quelles sont les trois questions de l''analyse d''un problème ?",
      "choix": [
        "Qui, quoi, comment",
        "Quelles entrées, quel traitement, quelles sorties",
        "Combien, pourquoi, quand",
        "Quelles variables, quelles constantes, quels types"
      ],
      "bonne": 1,
      "explication": "C''est le schéma Entrée-Traitement-Sortie du chapitre 1, appliqué à l''écriture d''un algorithme. Les entrées deviennent les lire, les sorties les écrire."
    },
    {
      "question": "Dans un organigramme, quel symbole représente un test ?",
      "choix": [
        "L''ovale",
        "Le rectangle",
        "Le losange",
        "Le parallélogramme"
      ],
      "bonne": 2,
      "explication": "C''est le seul symbole à deux sorties : une pour oui, une pour non. Le rectangle est un traitement, le parallélogramme une entrée-sortie."
    },
    {
      "question": "Pourquoi écrit-on un message avant un lire ?",
      "choix": [
        "Pour accélérer l''algorithme",
        "Pour dire à l''utilisateur ce qu''on attend de lui",
        "C''est obligatoire en LDA",
        "Pour déclarer la variable"
      ],
      "bonne": 1,
      "explication": "Ce message ne sert pas au calcul, mais un algorithme qui lit sans rien demander laisse l''utilisateur devant un écran muet."
    }
  ]
}', NULL, 5);

    RAISE NOTICE '% : 7 leçons ajoutées au chapitre 8, Notions d''algorithmique.', v_nom;
  END LOOP;
END $inf1$;
