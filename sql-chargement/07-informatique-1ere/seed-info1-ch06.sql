-- ---------------------------------------------------------------------------
-- M'Andal — Informatique, classes de Première
-- Chapitre 6 : Les virus et les antivirus
-- Module 1 : Maintenance informatique — 7 leçons
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
    WHERE programme_id = v_programme_id AND ordre = 6;

    IF v_chapitre_id IS NULL THEN
      INSERT INTO public.chapitres (programme_id, titre, ordre, niveau)
      VALUES (v_programme_id, 'Les virus et les antivirus', 6, 'Module 1 : Maintenance informatique')
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
      (v_chapitre_id, 'Qu''est-ce qu''un virus informatique ?', 1, 'texte', '
### La définition

Un **virus informatique** est un **programme** capable de se **dupliquer** et de
se **propager** d''un ordinateur à un autre, et conçu pour nuire.

On l''appelle aussi **CPA**, pour **Code Auto-Propageable**. Ce sigle est à
retenir : il dit l''essentiel. Un virus est d''abord un **code**, c''est-à-dire un
programme écrit par quelqu''un, et il se **propage tout seul**.

Deux conséquences qu''on te demande souvent.

Un virus n''apparaît pas par hasard et n''est pas une panne : **il est écrit
exprès**, par une personne.

Et comme c''est un programme, **il peut être détecté et supprimé** par un autre
programme : l''antivirus.

### Les principaux types

| Nom | Son mode d''action |
| --- | --- |
| le **ver** (*worm*) | il se propage seul à travers le réseau, sans avoir besoin qu''on ouvre quoi que ce soit |
| le **cheval de Troie** (*trojan*) | il se cache dans un programme d''apparence utile, et ouvre une porte à l''attaquant |
| la **bombe logique** | elle reste endormie et se déclenche à une date ou sur un évènement précis |
| le **macrovirus** | il se loge dans les macros d''un document bureautique, Word ou Excel |
| le **logiciel espion** (*spyware*) | il ne détruit rien : il observe et envoie ce que tu fais |

Le cheval de Troie porte ce nom à cause du cheval de bois des Grecs : ce qui le
caractérise n''est pas ce qu''il détruit, c''est qu''il **se déguise**.

### Comment ils entrent

Les quatre portes d''entrée, par fréquence : la **clé USB** partagée de machine
en machine, les **pièces jointes** d''un courriel, les **logiciels téléchargés**
sur des sites douteux, et les **réseaux** non protégés.

---

**Exercice corrigé**

*Que signifie le sigle CPA, et qu''apprend-il sur la nature d''un virus ?*

**Correction.** CPA signifie **Code Auto-Propageable**.

**Code** : c''est un programme, écrit volontairement par quelqu''un. Un virus
n''est donc jamais une panne accidentelle ni une usure du matériel.

**Auto-propageable** : il se duplique et se transmet par lui-même, sans que son
auteur soit encore là. C''est cette propriété qui le rend dangereux, et qui le
distingue d''un simple programme nuisible qu''il faudrait relancer à la main sur
chaque machine.
', NULL, 22),
      (v_chapitre_id, 'Simulation : reconnaître les types de virus', 2, 'interactif', '{
  "widget": "types-virus",
  "consigne": "Cinq programmes malveillants se présentent à toi par leur comportement, sans dire leur nom : l''un se propage seul sur le réseau, l''autre se cache dans un faux jeu, un troisième attend le 1er avril. Donne à chacun son type. La simulation te montre ensuite sa propagation sur un petit réseau de six machines, pour que tu voies la différence entre un ver et un cheval de Troie."
}', NULL, 10),
      (v_chapitre_id, 'Reconnaître une machine infectée', 3, 'texte', '
Les élèves croient souvent qu''un virus annonce sa présence. Les bons virus font
exactement le contraire. Voici les signes auxquels un technicien se fie.

### Les manifestations courantes

- **Un ralentissement général** inexpliqué : le virus consomme du processeur et
de la mémoire pour son propre travail.
- La **saturation** du disque dur ou de la mémoire vive sans raison.
- La **perte ou la modification de données**, des fichiers qui disparaissent ou
deviennent illisibles.
- L''**apparition de raccourcis** à la place de tes dossiers, notamment sur les
clés USB — c''est la signature la plus connue au Cameroun.
- Des **fichiers devenus cachés**, que tu ne retrouves plus alors qu''ils sont
toujours là.
- Le **lancement automatique** de programmes ou de fenêtres que tu n''as pas
demandés.
- Des **redémarrages** intempestifs.
- L''**antivirus désactivé** et impossible à relancer : beaucoup de virus
commencent par là.

### Ce qui n''est pas forcément un virus

Attention au raisonnement trop rapide. Un ralentissement peut venir d''un disque
plein ou fragmenté. Un redémarrage intempestif peut venir d''une surchauffe.

C''est pourquoi le diagnostic du chapitre précédent reste nécessaire : **on
cherche la cause, on ne l''annonce pas.** Le signe qui ne trompe presque jamais,
en revanche, c''est l''antivirus qui se désactive tout seul.

---

**Exercice corrigé**

*Vous branchez votre clé USB sur l''ordinateur d''un cybercafé. En la rebranchant
chez vous, vous ne voyez plus vos dossiers mais des raccourcis portant leurs
noms. Qu''est-il arrivé, et vos fichiers sont-ils perdus ?*

**Correction.** La clé a été **infectée** par un virus qui remplace les dossiers
par des raccourcis.

**Vos fichiers ne sont pas perdus.** Ils sont toujours sur la clé : le virus les
a seulement rendus **cachés**, et a placé à leur place des raccourcis qui, en
plus de vous emmener au bon endroit, relancent le virus.

La bonne démarche : **ne cliquer sur aucun raccourci**, analyser la clé avec un
antivirus à jour, puis réafficher les fichiers cachés pour les récupérer. Et ne
jamais rebrancher cette clé avant de l''avoir nettoyée, sinon elle réinfectera
la machine suivante.
', NULL, 22),
      (v_chapitre_id, 'Simulation : la machine est-elle infectée ?', 4, 'interactif', '{
  "widget": "machine-infectee",
  "consigne": "Huit situations te sont décrites, avec leurs symptômes et un peu de contexte. Pour chacune, décide s''il s''agit d''un virus ou d''une autre cause — disque plein, surchauffe, pilote manquant — et justifie en choisissant l''indice décisif. La simulation te félicite surtout quand tu refuses de conclure au virus trop vite."
}', NULL, 10),
      (v_chapitre_id, 'Les antivirus', 5, 'texte', '
### Ce qu''est un antivirus

Un **antivirus** est un programme chargé de **détecter**, de **neutraliser** et
d''**éliminer** les programmes malveillants.

### Ses deux méthodes de détection

La **détection par signature**, ou **scanning**. L''antivirus possède un
dictionnaire des signatures connues — une sorte d''empreinte de chaque virus
identifié — et compare les fichiers de la machine à ce dictionnaire.

C''est précis, mais cela n''attrape que les virus **déjà connus**. D''où l''absolue
nécessité de la **mise à jour** : un antivirus qui n''est pas à jour ne connaît
pas les virus de ce mois-ci, et ne sert presque plus à rien.

L''**analyse comportementale**, ou heuristique. L''antivirus n''identifie plus le
virus, il surveille ce que font les programmes. Un programme qui se met à
modifier tous les fichiers d''un dossier, ou à se copier dans le démarrage, est
suspect — même si on ne l''a jamais vu.

Celle-ci attrape les virus inconnus, mais se trompe parfois sur un programme
honnête : c''est ce qu''on appelle un **faux positif**.

### Les quatre décisions possibles

Quand l''antivirus trouve un fichier infecté, il peut :

1. le **réparer**, c''est-à-dire le désinfecter en gardant le fichier ;
2. le **supprimer**, si la désinfection est impossible ;
3. le **mettre en quarantaine**, c''est-à-dire l''isoler dans un dossier d''où il
ne peut plus agir, en attendant de décider ;
4. **ne rien faire**, et laisser l''utilisateur trancher.

La **quarantaine** est le bon choix dans le doute : elle neutralise le fichier
sans le détruire, au cas où ce serait un faux positif.

### Quelques exemples

**Avast**, **Norton**, **Kaspersky**, **AVG**, **Microsoft Security
Essentials**, **Smadav** — ce dernier étant très répandu contre les virus de
clés USB.

### Les règles de prévention

Un antivirus **à jour**. Pas de clé USB branchée sans analyse. Pas de pièce
jointe ouverte sans vérification. Pas de logiciel téléchargé sur n''importe quel
site. Et des **sauvegardes régulières** : le seul remède qui marche encore quand
tout le reste a échoué.

---

**Exercice corrigé**

*Un utilisateur affirme : « j''ai un antivirus installé, donc je suis protégé ».
Que lui répondez-vous ?*

**Correction.** Qu''un antivirus installé mais **non mis à jour** ne protège que
contre les virus d''hier.

La détection par signature repose sur un dictionnaire de virus connus. Des
centaines de nouveaux programmes malveillants apparaissent chaque jour. Un
antivirus dont le dictionnaire date de six mois ne les reconnaît pas.

Et même à jour, il ne dispense pas des précautions : ne pas brancher une clé
inconnue sans l''analyser, ne pas ouvrir une pièce jointe inattendue, et
sauvegarder ses données. L''antivirus est une couche de protection, pas une
garantie.
', NULL, 25),
      (v_chapitre_id, 'Simulation : analyser et nettoyer une machine', 6, 'interactif', '{
  "widget": "scan-antivirus",
  "consigne": "Lance une analyse sur une machine infectée et prends les décisions à la place de l''antivirus : pour chaque fichier détecté, tu choisis entre réparer, supprimer, mettre en quarantaine ou ignorer. La simulation te montre les conséquences — y compris le fichier de cours que tu viens de supprimer alors que c''était un faux positif. Tu peux aussi relancer l''analyse avec un antivirus volontairement non mis à jour, pour voir ce qu''il laisse passer."
}', NULL, 10),
      (v_chapitre_id, 'Quiz du chapitre 6', 7, 'quiz', '{
  "titre": "Vérifie que tu as compris",
  "questions": [
    {
      "question": "Que signifie le sigle CPA appliqué aux virus ?",
      "choix": [
        "Composant Principal Attaqué",
        "Code Auto-Propageable",
        "Contrôle Préventif Antivirus",
        "Code Prioritaire d''Attaque"
      ],
      "bonne": 1,
      "explication": "Code, parce que c''est un programme écrit exprès par quelqu''un ; auto-propageable, parce qu''il se duplique et se transmet tout seul."
    },
    {
      "question": "Quel programme malveillant se cache dans un logiciel d''apparence utile ?",
      "choix": [
        "Le ver",
        "Le cheval de Troie",
        "La bombe logique",
        "Le macrovirus"
      ],
      "bonne": 1,
      "explication": "Comme le cheval de bois des Grecs : ce qui le caractérise n''est pas ce qu''il détruit, c''est qu''il se déguise."
    },
    {
      "question": "Quel programme malveillant se déclenche à une date précise ?",
      "choix": [
        "Le ver",
        "Le cheval de Troie",
        "La bombe logique",
        "Le logiciel espion"
      ],
      "bonne": 2,
      "explication": "Elle reste endormie sur la machine et s''active sur un évènement ou une date fixée par son auteur."
    },
    {
      "question": "Vos dossiers sont remplacés par des raccourcis sur votre clé USB. Vos fichiers sont-ils perdus ?",
      "choix": [
        "Oui, définitivement",
        "Non, ils sont seulement cachés et récupérables après nettoyage",
        "Oui, sauf si on reformate la clé",
        "Non, il suffit de cliquer sur les raccourcis"
      ],
      "bonne": 1,
      "explication": "Le virus a rendu les fichiers cachés. Surtout, ne cliquez sur aucun raccourci : ils relancent le virus. Analysez d''abord, réaffichez ensuite."
    },
    {
      "question": "Sur quoi repose la détection par signature ?",
      "choix": [
        "Sur la surveillance du comportement des programmes",
        "Sur un dictionnaire des empreintes de virus déjà connus",
        "Sur la taille des fichiers",
        "Sur la date de création des fichiers"
      ],
      "bonne": 1,
      "explication": "C''est pourquoi la mise à jour est indispensable : un antivirus non mis à jour ne connaît pas les virus de ce mois-ci."
    },
    {
      "question": "Quelles sont les quatre décisions possibles d''un antivirus face à un fichier infecté ?",
      "choix": [
        "Analyser, détecter, signaler, archiver",
        "Réparer, supprimer, mettre en quarantaine, ne rien faire",
        "Copier, déplacer, renommer, cacher",
        "Bloquer, chiffrer, compresser, envoyer"
      ],
      "bonne": 1,
      "explication": "Dans le doute, la quarantaine est le meilleur choix : elle neutralise le fichier sans le détruire, au cas où ce serait un faux positif."
    },
    {
      "question": "Qu''appelle-t-on un faux positif ?",
      "choix": [
        "Un virus que l''antivirus n''a pas vu",
        "Un fichier sain que l''antivirus signale à tort comme infecté",
        "Un antivirus non mis à jour",
        "Un virus mis en quarantaine"
      ],
      "bonne": 1,
      "explication": "C''est le défaut de l''analyse comportementale : elle attrape les virus inconnus, mais se trompe parfois sur un programme honnête."
    }
  ]
}', NULL, 5);

    RAISE NOTICE '% : 7 leçons ajoutées au chapitre 6, Les virus et les antivirus.', v_nom;
  END LOOP;
END $inf1$;
