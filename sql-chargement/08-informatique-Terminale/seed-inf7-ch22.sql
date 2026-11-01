-- ---------------------------------------------------------------------------
-- M'Andal — Informatique, classes de Terminale
-- Chapitre 22 : Les bases du langage C
-- Module 3 : Algorithme et programmation — 8 leçons
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
    WHERE programme_id = v_programme_id AND ordre = 22;

    IF v_chapitre_id IS NULL THEN
      INSERT INTO public.chapitres (programme_id, titre, ordre, niveau)
      VALUES (v_programme_id, 'Les bases du langage C', 22, 'Module 3 : Algorithme et programmation')
      RETURNING id INTO v_chapitre_id;
      RAISE NOTICE '% : chapitre 22 créé.', v_nom;
    END IF;

    -- Les leçons. Si le chapitre en a déjà, on passe son tour sans rien toucher.
    SELECT count(*) INTO v_deja FROM public.concepts WHERE chapitre_id = v_chapitre_id;
    IF v_deja > 0 THEN
      RAISE NOTICE '% : le chapitre 22 a déjà ses % leçons, je n''y touche pas.', v_nom, v_deja;
      CONTINUE;
    END IF;

    INSERT INTO public.concepts
      (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes) VALUES
      (v_chapitre_id, 'Les langages de programmation', 1, 'texte', '
Nous avons écrit des algorithmes en **LDA**. Mais le LDA ne s''exécute sur aucune
machine : c''est un langage pour **penser et communiquer**, pas pour faire
tourner un ordinateur.

Pour que la machine exécute, il faut un **langage de programmation**.

### La définition

Un **langage de programmation** est un **langage formel permettant d''écrire des
instructions exécutables par un ordinateur**.

### Les trois niveaux

**Le langage machine.** Du binaire pur, exécuté directement par le processeur.
Illisible pour un humain.

**Le langage d''assemblage**, ou assembleur. Chaque instruction machine reçoit un
nom court (`MOV`, `ADD`, `JMP`). Lisible, mais dépendant du processeur.

**Les langages évolués**, ou de haut niveau. Proches du langage humain et
indépendants de la machine. C''est la famille du **C**, du **Pascal**, de
**Java**, du **Python**, du **PHP**.

Le programme écrit en langage évolué est le **code source**. La machine ne le
comprend pas : il faut le **traduire**.

### Les deux modes de traduction

**La compilation.** Un **compilateur** traduit **tout le code source d''un coup**
et produit un **fichier exécutable** autonome. C''est le mode du **C** et du
**C++**. L''exécutable est rapide, et il tourne sans le code source.

**L''interprétation.** Un **interpréteur** traduit et exécute **ligne par
ligne**, à chaque lancement. C''est le mode du **Python**, du **PHP**, du
**JavaScript**. Plus souple à mettre au point, mais plus lent, et il faut
l''interpréteur sur la machine.

### Les langages à citer

Quand le programme demande d''en **citer quelques-uns**, on répond : **C**,
**C++**, **Java**, **Python**, **Pascal**, **PHP**, **JavaScript**, **Visual
Basic**.

### Pourquoi le C au programme

Le C est le langage retenu par le programme camerounais de Terminale, et ce
n''est pas un hasard.

Il est **compilé**, donc rapide. Il est **proche de la machine**, ce qui le rend
incontournable pour les systèmes d''exploitation. Il est **concis**. Et surtout,
sa syntaxe a été **reprise** par le C++, le Java, le JavaScript et le PHP : qui
sait lire du C sait déchiffrer la moitié des langages du monde.

---

**Exercice corrigé**

*Définir « langage de programmation », citer quatre langages évolués, puis
expliquer la différence entre compilation et interprétation.*

**Correction.**

Un **langage de programmation** est un langage formel permettant d''écrire des
instructions **exécutables par un ordinateur**.

*Quatre langages évolués :* le **C**, le **Java**, le **Python** et le
**Pascal**.

*La différence.* Le **compilateur** traduit **l''ensemble du code source en une
seule fois** et produit un **fichier exécutable** que l''on peut lancer sans le
code source ; c''est le mode du langage C. L''**interpréteur** traduit et exécute
**ligne par ligne, à chaque lancement**, et il doit être présent sur la machine ;
c''est le mode du Python.

*La conséquence pratique :* un programme compilé est plus **rapide** à
l''exécution, un programme interprété est plus **souple** à mettre au point.
', NULL, 24),
      (v_chapitre_id, 'Simulation : du source à l''exécution', 2, 'interactif', '{
  "widget": "langages-programmation",
  "consigne": "Un même petit programme s''affiche dans quatre langages, et tu peux comparer leur syntaxe ligne à ligne. Lance ensuite la chaîne de traduction : la simulation fait avancer le compilateur sur tout le fichier d''un coup, puis l''interpréteur ligne par ligne, et chronomètre les deux. Un volet classe une liste de langages entre compilés et interprétés."
}', NULL, 10),
      (v_chapitre_id, 'L''environnement de développement intégré', 3, 'texte', '
### Le sigle

**IDE** signifie *Integrated Development Environment*, en français
**environnement de développement intégré**.

**Cette question est tombée au Baccalauréat 2023 pour un demi-point.** Elle est
gratuite : il suffit de connaître le sigle.

### La définition

Un **IDE** est un **logiciel qui regroupe en une seule interface tous les outils
nécessaires au développement d''un programme**.

### Les quatre outils qu''il regroupe

**L''éditeur de code**, qui colore la syntaxe, indente automatiquement et
complète les mots.

**Le compilateur**, qui traduit le source en exécutable et signale les erreurs.

**Le débogueur**, qui exécute le programme **pas à pas** pour voir le contenu
des variables à chaque ligne. C''est exactement la **trace d''exécution** du
chapitre précédent, faite par la machine.

**Le gestionnaire de projet**, qui organise les fichiers d''un même programme.

### Les IDE à citer pour le langage C

**Code::Blocks**, libre, léger, multiplateforme. C''est le plus répandu dans les
lycées camerounais, et c''est celui à citer en priorité.

**Dev-C++**, libre, très simple, longtemps le standard scolaire.

**Visual Studio**, de Microsoft, très complet mais lourd.

**Turbo C**, ancien, encore cité dans certains manuels.

*Pour les autres langages, on peut citer **NetBeans** et **Eclipse** pour Java,
**PyCharm** pour Python.*

### Installer Code::Blocks

**1. Télécharger** depuis le site officiel `codeblocks.org`, rubrique
*Downloads*. **Choisir impérativement la version dont le nom contient
`mingw-setup`** : c''est celle qui inclut le compilateur. La version sans
`mingw` n''apporte que l''éditeur, et le programme refusera de compiler avec le
message « *no compiler found* ».

**2. Lancer** le fichier téléchargé, et accepter la licence.

**3. Choisir le type d''installation** : garder *Full*, qui installe le
compilateur MinGW.

**4. Confirmer le dossier** d''installation proposé.

**5. Attendre** la copie des fichiers, puis lancer Code::Blocks.

**6. Au premier démarrage**, l''IDE détecte le compilateur et demande de le
définir par défaut : accepter.

### Créer et exécuter un premier programme

**File → New → Empty file**, puis enregistrer sous un nom **terminé par
`.c`** — par exemple `bonjour.c`. Sans cette extension, l''IDE ne sait pas qu''il
s''agit de langage C.

Taper le programme, puis **Build and run**, ou la touche **F9**, qui compile et
exécute en une fois.

### Les trois messages du début

« **no compiler found** » : la version installée n''incluait pas MinGW. Il faut
réinstaller la version `mingw-setup`.

« **undefined reference to main** » : le fichier a été enregistré sans
l''extension `.c`, ou la fonction `main` est mal écrite.

**La console s''ouvre et se referme aussitôt** : ce n''est pas une erreur. Le
programme a fini. On ajoute `getchar();` avant le `return 0;` pour qu''il attende
une touche.

---

**Exercice corrigé**

*Donner la signification du sigle IDE, citer deux IDE utilisables pour le
langage C, et nommer deux outils qu''un IDE regroupe.*

**Correction.**

**IDE** signifie *Integrated Development Environment*, soit **environnement de
développement intégré**. C''est un logiciel qui regroupe en une seule interface
tous les outils nécessaires au développement d''un programme.

*Deux IDE pour le langage C :* **Code::Blocks** et **Dev-C++**.

*Deux outils regroupés :* l''**éditeur de code** et le **compilateur**. *On
accepte aussi le débogueur et le gestionnaire de projet.*

*La question du sigle est tombée au Baccalauréat 2023, partie III.*
', NULL, 26),
      (v_chapitre_id, 'Simulation : installer et lancer un IDE', 4, 'interactif', '{
  "widget": "installer-ide",
  "consigne": "L''installation de Code::Blocks se déroule écran par écran, et tu dois faire les bons choix. Prends la version sans MinGW et la simulation te met devant le message « no compiler found » au premier essai de compilation, puis te montre comment le réparer. Une fois l''IDE prêt, écris un petit programme, appuie sur F9 et vois la console s''ouvrir — avec le piège de la fenêtre qui se referme aussitôt."
}', NULL, 10),
      (v_chapitre_id, 'La structure d''un programme en langage C', 5, 'texte', '
### Le programme minimal

```c
#include <stdio.h>

int main()
{
    printf("Bonjour la Terminale !\n");
    return 0;
}
```

### Les cinq parties, dans l''ordre

**1. Les directives au préprocesseur.** Elles commencent par `#` et se placent
tout en haut. `#include <stdio.h>` charge la bibliothèque d''**entrées-sorties
standard** — *standard input output* — et sans elle, `printf` et `scanf`
n''existent pas.

**Ces lignes ne se terminent pas par un point-virgule.**

**2. Les constantes**, s''il y en a : `#define PI 3.14`.

**3. Les déclarations de fonctions**, s''il y en a.

**4. La fonction `main`.** C''est **le point d''entrée obligatoire** : l''exécution
commence toujours là. Tout programme C en possède **une et une seule**.

**5. Le corps**, entre **accolades** `{` et `}`, qui contient les déclarations
de variables puis les instructions.

### Les cinq règles de syntaxe

**Chaque instruction se termine par un point-virgule.** L''oubli du `;` est
l''erreur la plus fréquente du débutant — et le compilateur la signale souvent à
la **ligne suivante**, ce qui désoriente.

**Les blocs sont délimités par des accolades** `{ }`, là où le LDA écrivait
`Début`/`Fin`, `Finsi`, `FinPour`.

**Le C distingue les majuscules des minuscules.** `age`, `Age` et `AGE` sont
trois variables différentes, et `Printf` n''existe pas.

**`return 0;`** termine `main` et signale au système que tout s''est bien passé.
C''est pour cela que `main` est déclarée `int`.

**Les commentaires** s''écrivent `/* … */` sur plusieurs lignes, ou `//` jusqu''à
la fin de la ligne.

### Le tableau de correspondance LDA → C

| En LDA | En C |
| --- | --- |
| `Algorithme : Nom` | `int main()` |
| `Variable` | les déclarations en tête du bloc |
| `Début` … `Fin` | `{` … `}` |
| `lire(x)` | `scanf("%d", &x);` |
| `écrire(x)` | `printf("%d", x);` |
| `x ← 5` | `x = 5;` |
| `Si … alors … Finsi` | `if ( … ) { … }` |
| `TantQue … FinTantQue` | `while ( … ) { … }` |
| `Pour i de 1 à n` | `for (i = 1; i <= n; i++)` |
| `=` *(comparaison)* | `==` |
| `et`, `ou`, `non` | `&&`, `||`, `!` |

**Deux pièges à retenir de ce tableau.** En C, `=` **affecte** et `==`
**compare** : écrire `if (x = 5)` est accepté par le compilateur et ne teste
rien. Et `scanf` exige le **`&`** devant la variable, alors que `printf` ne le
veut pas.

---

**Exercice corrigé**

*Écrire la structure générale d''un programme en langage C, en commentant chaque
partie. Puis traduire en C l''algorithme qui lit un âge et affiche « majeur » ou
« mineur ».*

**Correction.**

*La structure générale :*

```c
#include <stdio.h>        /* les bibliothèques */

#define MAJORITE 18       /* les constantes */

int main()                /* la fonction principale, point d''entrée */
{
    int age;              /* les déclarations de variables */

    printf("Votre age : ");
    scanf("%d", &age);    /* les instructions */

    if (age >= MAJORITE)
    {
        printf("Majeur\n");
    }
    else
    {
        printf("Mineur\n");
    }

    return 0;             /* la valeur de retour au système */
}
```

*Les quatre points que le correcteur vérifie.*

Le **`#include <stdio.h>`**, sans lequel `printf` et `scanf` sont inconnus.

La fonction **`int main()`**, point d''entrée obligatoire.

Le **`&` devant `age` dans le `scanf`**, et son absence dans le `printf`.

Le **`>=`** et non `=>`, et le **`return 0;`** en fin de fonction.
', NULL, 28),
      (v_chapitre_id, 'Figure : du code source à la console', 6, 'figure', '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 560 300" width="560" height="300">
<rect width="560" height="300" fill="#ffffff"/>
<text x="280" y="22" text-anchor="middle" font-size="14" font-weight="700" fill="#0f172a">La structure d&apos;un programme C et son parcours jusqu&apos;à l&apos;exécution</text>

<rect x="20" y="36" width="250" height="238" rx="5" fill="#f8fafc" stroke="#94a3b8" stroke-width="1.4"/>
<text x="145" y="54" text-anchor="middle" font-size="11" font-weight="700" fill="#334155">bonjour.c — le code source</text>

<rect x="32" y="64" width="226" height="40" rx="3" fill="#ede9fe" stroke="#7c3aed" stroke-width="1.2"/>
<text x="40" y="80" font-size="9" font-family="monospace" fill="#4c1d95">#include &lt;stdio.h&gt;</text>
<text x="40" y="96" font-size="8" fill="#6d28d9">les directives au préprocesseur</text>

<rect x="32" y="110" width="226" height="28" rx="3" fill="#fef3c7" stroke="#ca8a04" stroke-width="1.2"/>
<text x="40" y="122" font-size="9" font-family="monospace" fill="#78350f">#define PI 3.14</text>
<text x="40" y="133" font-size="8" fill="#a16207">les constantes</text>

<rect x="32" y="144" width="226" height="118" rx="3" fill="#dbeafe" stroke="#2563eb" stroke-width="1.4"/>
<text x="40" y="160" font-size="9" font-family="monospace" fill="#1e3a8a">int main()</text>
<text x="40" y="174" font-size="9" font-family="monospace" fill="#1e3a8a">{</text>
<text x="52" y="188" font-size="9" font-family="monospace" fill="#1d4ed8">int age ;</text>
<text x="52" y="202" font-size="9" font-family="monospace" fill="#1d4ed8">scanf(&quot;%d&quot;, &amp;age) ;</text>
<text x="52" y="216" font-size="9" font-family="monospace" fill="#1d4ed8">printf(&quot;%d ans&quot;, age) ;</text>
<text x="52" y="230" font-size="9" font-family="monospace" fill="#1d4ed8">return 0 ;</text>
<text x="40" y="244" font-size="9" font-family="monospace" fill="#1e3a8a">}</text>
<text x="40" y="257" font-size="8" fill="#2563eb">la fonction main : le corps du programme</text>

<path d="M 276 155 L 310 155" fill="none" stroke="#334155" stroke-width="1.6"/>
<polygon points="316,155 306,150 306,160" fill="#334155"/>
<text x="296" y="148" text-anchor="middle" font-size="8" fill="#475569">compilation</text>

<rect x="322" y="100" width="216" height="52" rx="4" fill="#dcfce7" stroke="#15803d" stroke-width="1.4"/>
<text x="430" y="120" text-anchor="middle" font-size="10" font-weight="700" fill="#14532d">bonjour.exe</text>
<text x="430" y="138" text-anchor="middle" font-size="9" fill="#166534">le programme exécutable</text>

<path d="M 430 152 L 430 180" fill="none" stroke="#334155" stroke-width="1.6"/>
<polygon points="430,186 425,176 435,176" fill="#334155"/>
<text x="446" y="172" font-size="8" fill="#475569">exécution</text>

<rect x="322" y="190" width="216" height="62" rx="4" fill="#0f172a"/>
<text x="334" y="210" font-size="9" font-family="monospace" fill="#e2e8f0">&gt; 17</text>
<text x="334" y="228" font-size="9" font-family="monospace" fill="#4ade80">17 ans</text>
<text x="430" y="246" text-anchor="middle" font-size="8" fill="#94a3b8">la console</text>

<text x="430" y="274" text-anchor="middle" font-size="9" fill="#64748b">L&apos;IDE regroupe l&apos;éditeur, le compilateur</text>
<text x="430" y="288" text-anchor="middle" font-size="9" fill="#64748b">et le débogueur dans une seule fenêtre.</text>
</svg>', NULL, 5),
      (v_chapitre_id, 'Simulation : assembler un programme C', 7, 'interactif', '{
  "widget": "structure-programme-c",
  "consigne": "Les morceaux d''un programme C sont mélangés et tu dois les remettre dans l''ordre : directives, constantes, main, corps. Chaque mauvaise place déclenche le message d''erreur exact du compilateur. Enlève le point-virgule d''une ligne, écris Printf avec une majuscule, oublie le #include : la simulation te montre les trois erreurs les plus fréquentes et où le compilateur les signale."
}', NULL, 10),
      (v_chapitre_id, 'Quiz du chapitre 22', 8, 'quiz', '{
  "titre": "Vérifie que tu as compris",
  "questions": [
    {
      "question": "Que signifie le sigle IDE ?",
      "choix": [
        "Interface de développement électronique",
        "Integrated Development Environment, environnement de développement intégré",
        "Interpréteur de données exécutables",
        "Instruction de déclaration étendue"
      ],
      "bonne": 1,
      "explication": "Cette question est tombée au Bac 2023 pour un demi-point. C''est le point le plus facile de l''épreuve."
    },
    {
      "question": "Quelle différence entre un compilateur et un interpréteur ?",
      "choix": [
        "Aucune",
        "Le compilateur traduit tout le source d''un coup et produit un exécutable ; l''interpréteur traduit et exécute ligne par ligne à chaque lancement",
        "Le compilateur est plus lent",
        "L''interpréteur ne marche qu''avec le C"
      ],
      "bonne": 1,
      "explication": "Le C est compilé, le Python est interprété. Le compilé est plus rapide, l''interprété plus souple à mettre au point."
    },
    {
      "question": "À quoi sert la ligne #include <stdio.h> ?",
      "choix": [
        "À déclarer les variables",
        "À charger la bibliothèque d''entrées-sorties standard, sans laquelle printf et scanf n''existent pas",
        "À démarrer le programme",
        "À compiler le fichier"
      ],
      "bonne": 1,
      "explication": "stdio = standard input output. Et cette ligne ne se termine PAS par un point-virgule."
    },
    {
      "question": "Quel est le point d''entrée obligatoire d''un programme C ?",
      "choix": [
        "La fonction début()",
        "La fonction main()",
        "La ligne #include",
        "La première accolade"
      ],
      "bonne": 1,
      "explication": "L''exécution commence toujours dans main, et tout programme C en possède une et une seule."
    },
    {
      "question": "En C, quelle est la différence entre = et == ?",
      "choix": [
        "Aucune",
        "Le = affecte une valeur, le == compare deux valeurs",
        "Le == affecte, le = compare",
        "Le == n''existe pas"
      ],
      "bonne": 1,
      "explication": "if (x = 5) est accepté par le compilateur et ne teste rien du tout : c''est un piège redoutable."
    },
    {
      "question": "Quelle version de Code::Blocks faut-il télécharger ?",
      "choix": [
        "N''importe laquelle",
        "Celle dont le nom contient mingw-setup, parce qu''elle inclut le compilateur",
        "La plus légère",
        "La version sans compilateur, plus rapide"
      ],
      "bonne": 1,
      "explication": "Sans MinGW, l''IDE n''a que l''éditeur et refuse de compiler avec le message « no compiler found »."
    },
    {
      "question": "Comment le C traite-t-il les majuscules et les minuscules ?",
      "choix": [
        "Il les confond",
        "Il les distingue : age, Age et AGE sont trois variables différentes",
        "Il n''accepte que les minuscules",
        "Il n''accepte que les majuscules"
      ],
      "bonne": 1,
      "explication": "C''est pourquoi Printf avec une majuscule provoque une erreur : la fonction s''appelle printf."
    }
  ]
}', NULL, 5);

    RAISE NOTICE '% : 8 leçons ajoutées au chapitre 22, Les bases du langage C.', v_nom;
  END LOOP;
END $inf7$;
