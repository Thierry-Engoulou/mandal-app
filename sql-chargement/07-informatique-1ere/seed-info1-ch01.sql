-- ---------------------------------------------------------------------------
-- M'Andal — Informatique, classes de Première
-- Chapitre 1 : Le fonctionnement d'un ordinateur
-- Module 1 : Maintenance informatique — 6 leçons
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
    WHERE programme_id = v_programme_id AND ordre = 1;

    IF v_chapitre_id IS NULL THEN
      INSERT INTO public.chapitres (programme_id, titre, ordre, niveau)
      VALUES (v_programme_id, 'Le fonctionnement d''un ordinateur', 1, 'Module 1 : Maintenance informatique')
      RETURNING id INTO v_chapitre_id;
      RAISE NOTICE '% : chapitre 1 créé.', v_nom;
    END IF;

    -- Les leçons. Si le chapitre en a déjà, on passe son tour sans rien toucher.
    SELECT count(*) INTO v_deja FROM public.concepts WHERE chapitre_id = v_chapitre_id;
    IF v_deja > 0 THEN
      RAISE NOTICE '% : le chapitre 1 a déjà ses % leçons, je n''y touche pas.', v_nom, v_deja;
      CONTINUE;
    END IF;

    INSERT INTO public.concepts
      (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes) VALUES
      (v_chapitre_id, 'L''ordinateur : entrée, traitement, sortie', 1, 'texte', '
Avant d''apprendre à réparer un ordinateur, il faut savoir ce qu''il fait. Et ce
qu''il fait tient en trois mots.

### La définition

Un **ordinateur** est un appareil électronique programmable qui traite
automatiquement les informations.

Pèse chaque mot, car chacun compte en examen.

**Électronique** : il fonctionne au courant. Sans alimentation, c''est, comme le
dit ton manuel, « un amas métallique de câbles et de plaquettes de silicium
complètement inutile ».

**Programmable** : il ne sait rien faire de lui-même. C''est le logiciel qui lui
dit quoi faire. Son immense potentiel n''est réalisé que grâce à lui.

**Automatiquement** : une fois lancé, il déroule le programme seul, sans qu''on
ait à le guider à chaque étape.

### Le principe : Entrée — Traitement — Sortie

Un ordinateur est en général constitué d''une **unité centrale** entourée de
**périphériques d''entrée et de sortie**.

Une information entre dans l''unité centrale, elle y est traitée, puis elle
ressort vers l''utilisateur. C''est le principe **Entrée-Traitement-Sortie**, et
il n''y a pas d''exception : tout ce que fait un ordinateur suit ce chemin.

Quand tu tapes une lettre au clavier, elle entre. Le processeur la traite.
L''écran l''affiche : elle sort.

### Les trois familles de périphériques

| Famille | À quoi elle sert | Exemples |
| --- | --- | --- |
| **entrée** | faire entrer l''information | clavier, souris, scanner, micro, webcam, manette |
| **sortie** | faire ressortir l''information | écran, imprimante, haut-parleurs, vidéoprojecteur |
| **stockage** | garder l''information | disque dur, clé USB, carte SD, DVD |

Attention au piège : certains périphériques sont **à la fois** entrée et
sortie. Un écran tactile reçoit tes doigts et affiche l''image. Un modem envoie
et reçoit. Une clé USB lit et écrit.

---

**Exercice corrigé**

*Citer deux périphériques d''entrée, deux périphériques de sortie et deux
périphériques de stockage.*

**Correction.**
*Entrée* : le clavier et la souris.
*Sortie* : l''écran et l''imprimante.
*Stockage* : le disque dur et la clé USB.

Un conseil pour ne jamais te tromper : demande-toi dans quel sens va
l''information. Si elle va **vers** l''unité centrale, c''est une entrée. Si elle
en **sort**, c''est une sortie. Si elle y **reste**, c''est du stockage.
', NULL, 20),
      (v_chapitre_id, 'Figure : le schéma fonctionnel de l''ordinateur', 2, 'figure', '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 540 280" width="540" height="280">
<rect width="540" height="280" fill="#ffffff"/>
<text x="270" y="24" text-anchor="middle" font-size="14" font-weight="700" fill="#0f172a">Le schéma fonctionnel de l&apos;ordinateur</text>
<text x="270" y="44" text-anchor="middle" font-size="11" fill="#64748b">une information entre, elle est traitée, elle ressort</text>

<rect x="24" y="92" width="124" height="68" rx="10" fill="#dbeafe" stroke="#2563eb" stroke-width="2"/>
<text x="86" y="120" text-anchor="middle" font-size="12" font-weight="700" fill="#1e3a8a">PÉRIPHÉRIQUES</text>
<text x="86" y="138" text-anchor="middle" font-size="12" font-weight="700" fill="#1e3a8a">D&apos;ENTRÉE</text>
<text x="86" y="176" text-anchor="middle" font-size="10" fill="#64748b">clavier, souris, scanner,</text>
<text x="86" y="190" text-anchor="middle" font-size="10" fill="#64748b">micro, webcam</text>

<rect x="208" y="92" width="124" height="68" rx="10" fill="#1e293b"/>
<text x="270" y="122" text-anchor="middle" font-size="13" font-weight="700" fill="#ffffff">UNITÉ</text>
<text x="270" y="140" text-anchor="middle" font-size="13" font-weight="700" fill="#ffffff">CENTRALE</text>
<text x="270" y="176" text-anchor="middle" font-size="10" fill="#64748b">c&apos;est là que tout se traite</text>

<rect x="392" y="92" width="124" height="68" rx="10" fill="#dcfce7" stroke="#16a34a" stroke-width="2"/>
<text x="454" y="120" text-anchor="middle" font-size="12" font-weight="700" fill="#14532d">PÉRIPHÉRIQUES</text>
<text x="454" y="138" text-anchor="middle" font-size="12" font-weight="700" fill="#14532d">DE SORTIE</text>
<text x="454" y="176" text-anchor="middle" font-size="10" fill="#64748b">écran, imprimante,</text>
<text x="454" y="190" text-anchor="middle" font-size="10" fill="#64748b">haut-parleurs</text>

<line x1="148" y1="126" x2="198" y2="126" stroke="#334155" stroke-width="2.4"/>
<polygon points="208,126 196,120 196,132" fill="#334155"/>
<line x1="332" y1="126" x2="382" y2="126" stroke="#334155" stroke-width="2.4"/>
<polygon points="392,126 380,120 380,132" fill="#334155"/>

<rect x="208" y="216" width="124" height="54" rx="10" fill="#fef3c7" stroke="#ca8a04" stroke-width="2"/>
<text x="270" y="240" text-anchor="middle" font-size="12" font-weight="700" fill="#78350f">PÉRIPHÉRIQUES</text>
<text x="270" y="258" text-anchor="middle" font-size="12" font-weight="700" fill="#78350f">DE STOCKAGE</text>
<line x1="270" y1="160" x2="270" y2="206" stroke="#334155" stroke-width="2.4"/>
<polygon points="270,216 264,204 276,204" fill="#334155"/>
<polygon points="270,160 264,172 276,172" fill="#334155"/>
<text x="356" y="246" font-size="10" fill="#64748b">disque dur, clé USB,</text>
<text x="356" y="260" font-size="10" fill="#64748b">carte SD, DVD</text>
</svg>', NULL, 5),
      (v_chapitre_id, 'Simulation : ranger les périphériques', 3, 'interactif', '{
  "widget": "schema-fonctionnel",
  "consigne": "Une pile de périphériques t''attend à gauche : clavier, écran, scanner, imprimante, clé USB, micro, haut-parleurs. Range-les dans les trois cases du schéma fonctionnel. La simulation corrige à chaque dépôt et t''explique le sens de circulation de l''information. Les quelques périphériques qui vont dans deux cases à la fois sont là exprès."
}', NULL, 10),
      (v_chapitre_id, 'Les unités de mesure', 4, 'texte', '
Chaque composant se mesure avec sa propre unité. C''est une question qui tombe
presque à chaque Probatoire, et elle ne demande aucun raisonnement : il faut
simplement les connaître.

| Composant | Unité | Exemple |
| --- | --- | --- |
| processeur | le **hertz** (Hz) | 2,5 GHz |
| mémoire vive, disque dur, clé USB | l''**octet** et ses multiples | 4 Go, 500 Go |
| écran | le **pouce**, mesuré en diagonale | 15 pouces |
| imprimante, scanner | le **point par pouce** (ppp, ou dpi) | 600 ppp |
| débit d''une connexion | le **bit par seconde** (bit/s) | 20 Mbit/s |

### Les multiples de l''octet

$$1 \text{ Ko} = 1024 \text{ octets}$$
$$1 \text{ Mo} = 1024 \text{ Ko}$$
$$1 \text{ Go} = 1024 \text{ Mo}$$
$$1 \text{ To} = 1024 \text{ Go}$$

Pourquoi 1024 et non 1000 ? Parce que l''ordinateur compte en base deux, et que
$2^{10} = 1024$. Les fabricants de disques durs, eux, comptent en base dix :
c''est pour cela qu''un disque vendu pour 500 Go en affiche 465 une fois branché.

### Le pouce

$$1 \text{ pouce} = 2{,}54 \text{ cm}$$

Un écran de 15 pouces mesure donc $15 \times 2{,}54 = 38{,}1$ cm **en
diagonale**, et non en largeur. C''est un piège classique.

---

**Exercice corrigé**

*Donner l''unité de mesure des composants matériels suivants : imprimante,
disque dur, processeur, écran plat.*

**Correction.**
*Imprimante* : le point par pouce (ppp), qui mesure la finesse d''impression.
*Disque dur* : l''octet et ses multiples, aujourd''hui le gigaoctet et le
téraoctet.
*Processeur* : le hertz, aujourd''hui le gigahertz, qui mesure le nombre
d''opérations par seconde.
*Écran plat* : le pouce, mesuré sur la diagonale de la dalle.
', NULL, 20),
      (v_chapitre_id, 'Simulation : à chaque composant son unité', 5, 'interactif', '{
  "widget": "unites-mesure",
  "consigne": "La simulation te présente un composant et te laisse choisir son unité parmi cinq. Elle garde ton score et te redonne ceux que tu as ratés. Passe ensuite en mode conversion : tu entres une taille en gigaoctets et tu la retrouves en mégaoctets, en octets, puis en bits — et tu vois pourquoi un disque vendu pour 500 Go n''en affiche que 465 une fois branché."
}', NULL, 10),
      (v_chapitre_id, 'Quiz du chapitre 1', 6, 'quiz', '{
  "titre": "Vérifie que tu as compris",
  "questions": [
    {
      "question": "Quelle est la définition d''un ordinateur ?",
      "choix": [
        "Une machine à écrire moderne",
        "Un appareil électronique programmable qui traite automatiquement les informations",
        "Un téléviseur relié à un clavier",
        "Un appareil qui stocke des fichiers"
      ],
      "bonne": 1,
      "explication": "Chacun des trois mots compte : électronique, programmable, et automatique. Le mot « programmable » est le plus important : sans logiciel, l''ordinateur ne sait rien faire."
    },
    {
      "question": "Quel est le principe de fonctionnement d''un ordinateur ?",
      "choix": [
        "Entrée — Traitement — Sortie",
        "Démarrage — Travail — Arrêt",
        "Matériel — Logiciel — Réseau",
        "Lecture — Écriture — Suppression"
      ],
      "bonne": 0,
      "explication": "L''information entre par un périphérique d''entrée, elle est traitée dans l''unité centrale, elle ressort par un périphérique de sortie. Tout ce que fait l''ordinateur suit ce chemin."
    },
    {
      "question": "Le scanner est un périphérique :",
      "choix": [
        "de sortie",
        "d''entrée",
        "de stockage",
        "d''alimentation"
      ],
      "bonne": 1,
      "explication": "Il fait ENTRER une image dans l''ordinateur. Demande-toi toujours dans quel sens va l''information : vers l''unité centrale, c''est une entrée."
    },
    {
      "question": "Dans quelle unité mesure-t-on la fréquence d''un processeur ?",
      "choix": [
        "En octets",
        "En hertz",
        "En pouces",
        "En points par pouce"
      ],
      "bonne": 1,
      "explication": "Le hertz mesure le nombre d''opérations par seconde. On l''exprime aujourd''hui en gigahertz, soit des milliards d''opérations par seconde."
    },
    {
      "question": "Un écran de 15 pouces : que mesure-t-on ?",
      "choix": [
        "Sa largeur",
        "Sa hauteur",
        "Sa diagonale",
        "Son épaisseur"
      ],
      "bonne": 2,
      "explication": "Toujours la diagonale. Un pouce valant 2,54 cm, un écran de 15 pouces mesure 38,1 cm d''un coin à l''autre."
    },
    {
      "question": "Combien d''octets dans un kilooctet ?",
      "choix": [
        "1000",
        "1024",
        "512",
        "2048"
      ],
      "bonne": 1,
      "explication": "L''ordinateur compte en base deux, et 2 puissance 10 vaut 1024. C''est pourquoi un disque vendu pour 500 Go n''en affiche que 465 une fois branché."
    },
    {
      "question": "Quel périphérique est à la fois un périphérique d''entrée et de sortie ?",
      "choix": [
        "Le scanner",
        "L''imprimante",
        "L''écran tactile",
        "Le vidéoprojecteur"
      ],
      "bonne": 2,
      "explication": "Il reçoit tes doigts — c''est une entrée — et il affiche l''image — c''est une sortie. Le modem et la clé USB sont dans le même cas."
    }
  ]
}', NULL, 5);

    RAISE NOTICE '% : 6 leçons ajoutées au chapitre 1, Le fonctionnement d''un ordinateur.', v_nom;
  END LOOP;
END $inf1$;
