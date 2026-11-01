-- ---------------------------------------------------------------------------
-- M'Andal — Informatique, classes de Première
-- Chapitre 4 : Introduction à la maintenance
-- Module 1 : Maintenance informatique — 8 leçons
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
    WHERE programme_id = v_programme_id AND ordre = 4;

    IF v_chapitre_id IS NULL THEN
      INSERT INTO public.chapitres (programme_id, titre, ordre, niveau)
      VALUES (v_programme_id, 'Introduction à la maintenance', 4, 'Module 1 : Maintenance informatique')
      RETURNING id INTO v_chapitre_id;
      RAISE NOTICE '% : chapitre 4 créé.', v_nom;
    END IF;

    -- Les leçons. Si le chapitre en a déjà, on passe son tour sans rien toucher.
    SELECT count(*) INTO v_deja FROM public.concepts WHERE chapitre_id = v_chapitre_id;
    IF v_deja > 0 THEN
      RAISE NOTICE '% : le chapitre 4 a déjà ses % leçons, je n''y touche pas.', v_nom, v_deja;
      CONTINUE;
    END IF;

    INSERT INTO public.concepts
      (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes) VALUES
      (v_chapitre_id, 'Qu''est-ce que la maintenance ?', 1, 'texte', '
Tu sais maintenant comment un ordinateur fonctionne. On peut passer à ce qui
fait vivre un technicien : le garder en état de marche.

### La définition

La **maintenance** est l''ensemble des actions permettant de **maintenir** ou de
**rétablir** un bien dans un état spécifié, ou en mesure d''assurer un service
déterminé.

Les deux verbes de cette définition dessinent déjà les deux familles.

**Maintenir**, c''est agir alors que la machine marche encore, pour qu''elle
continue : c''est la maintenance **préventive**.

**Rétablir**, c''est agir après la panne, pour la faire repartir : c''est la
maintenance **corrective**.

Toute la suite du chapitre n''est que la subdivision de ces deux familles.

### Pourquoi s''en occuper

Un parc informatique mal entretenu coûte toujours plus cher qu''un parc
entretenu. Les trois raisons qu''on te demandera de citer :

- **prolonger la durée de vie** du matériel ;
- **réduire les arrêts** de travail imprévus ;
- **sécuriser les données**, qui valent souvent bien plus que la machine.

### Un sigle à connaître

**GMAO** signifie **Gestion de la Maintenance Assistée par Ordinateur**. C''est
un logiciel qui tient le registre du parc : quelle machine, quelle
intervention, à quelle date, par qui, pour combien.

Dans un lycée de 400 ordinateurs, c''est lui qui permet de savoir qu''une salle
tombe en panne trois fois plus souvent que les autres — et donc qu''il y a un
problème électrique dans cette salle, pas un problème d''ordinateurs.

---

**Exercice corrigé**

*Un chef d''établissement vous demande pourquoi il devrait payer un technicien
alors que ses ordinateurs fonctionnent. Que lui répondez-vous ?*

**Correction.** Parce que l''essentiel du travail d''un technicien est justement
de faire en sorte qu''ils continuent à fonctionner.

C''est la maintenance **préventive** : dépoussiérer, vérifier les protections
électriques, mettre à jour l''antivirus, sauvegarder les données. Chacune de ces
actions coûte quelques minutes et évite une panne qui immobiliserait une salle
pendant des jours.

Attendre la panne, c''est se condamner à la maintenance **corrective** — la plus
chère des deux, parce qu''on y perd à la fois le matériel, le temps et parfois
les données.
', NULL, 20),
      (v_chapitre_id, 'Figure : l''arbre de la maintenance', 2, 'figure', '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 560 310" width="560" height="310">
<rect width="560" height="310" fill="#ffffff"/>
<text x="280" y="22" text-anchor="middle" font-size="14" font-weight="700" fill="#0f172a">Les deux familles de maintenance, et leurs branches</text>

<rect x="206" y="38" width="148" height="34" rx="8" fill="#1e293b"/>
<text x="280" y="60" text-anchor="middle" font-size="12" font-weight="700" fill="#ffffff">LA MAINTENANCE</text>

<line x1="280" y1="72" x2="280" y2="88" stroke="#334155" stroke-width="2"/>
<line x1="140" y1="88" x2="420" y2="88" stroke="#334155" stroke-width="2"/>
<line x1="140" y1="88" x2="140" y2="104" stroke="#334155" stroke-width="2"/>
<line x1="420" y1="88" x2="420" y2="104" stroke="#334155" stroke-width="2"/>

<rect x="60" y="104" width="160" height="42" rx="8" fill="#b91c1c"/>
<text x="140" y="122" text-anchor="middle" font-size="12" font-weight="700" fill="#ffffff">CORRECTIVE</text>
<text x="140" y="138" text-anchor="middle" font-size="10" fill="#fecaca">après la panne</text>

<rect x="340" y="104" width="160" height="42" rx="8" fill="#15803d"/>
<text x="420" y="122" text-anchor="middle" font-size="12" font-weight="700" fill="#ffffff">PRÉVENTIVE</text>
<text x="420" y="138" text-anchor="middle" font-size="10" fill="#bbf7d0">avant la panne</text>

<line x1="140" y1="146" x2="140" y2="162" stroke="#334155" stroke-width="1.6"/>
<line x1="84" y1="162" x2="196" y2="162" stroke="#334155" stroke-width="1.6"/>
<line x1="84" y1="162" x2="84" y2="178" stroke="#334155" stroke-width="1.6"/>
<line x1="196" y1="162" x2="196" y2="178" stroke="#334155" stroke-width="1.6"/>
<rect x="28" y="178" width="112" height="38" rx="6" fill="#fee2e2" stroke="#b91c1c" stroke-width="1.4"/>
<text x="84" y="195" text-anchor="middle" font-size="11" font-weight="700" fill="#7f1d1d">palliative</text>
<text x="84" y="209" text-anchor="middle" font-size="9" fill="#991b1b">dépannage provisoire</text>
<rect x="142" y="178" width="112" height="38" rx="6" fill="#fee2e2" stroke="#b91c1c" stroke-width="1.4"/>
<text x="198" y="195" text-anchor="middle" font-size="11" font-weight="700" fill="#7f1d1d">curative</text>
<text x="198" y="209" text-anchor="middle" font-size="9" fill="#991b1b">réparation définitive</text>

<line x1="420" y1="146" x2="420" y2="162" stroke="#334155" stroke-width="1.6"/>
<line x1="326" y1="162" x2="514" y2="162" stroke="#334155" stroke-width="1.6"/>
<line x1="326" y1="162" x2="326" y2="178" stroke="#334155" stroke-width="1.6"/>
<line x1="420" y1="162" x2="420" y2="178" stroke="#334155" stroke-width="1.6"/>
<line x1="514" y1="162" x2="514" y2="178" stroke="#334155" stroke-width="1.6"/>
<rect x="276" y="178" width="100" height="52" rx="6" fill="#dcfce7" stroke="#15803d" stroke-width="1.4"/>
<text x="326" y="196" text-anchor="middle" font-size="11" font-weight="700" fill="#14532d">systématique</text>
<text x="326" y="210" text-anchor="middle" font-size="9" fill="#166534">selon un</text>
<text x="326" y="222" text-anchor="middle" font-size="9" fill="#166534">échéancier</text>
<rect x="382" y="178" width="100" height="52" rx="6" fill="#dcfce7" stroke="#15803d" stroke-width="1.4"/>
<text x="432" y="196" text-anchor="middle" font-size="11" font-weight="700" fill="#14532d">conditionnelle</text>
<text x="432" y="210" text-anchor="middle" font-size="9" fill="#166534">quand un seuil</text>
<text x="432" y="222" text-anchor="middle" font-size="9" fill="#166534">est franchi</text>
<rect x="488" y="178" width="66" height="52" rx="6" fill="#dcfce7" stroke="#15803d" stroke-width="1.4"/>
<text x="521" y="196" text-anchor="middle" font-size="10" font-weight="700" fill="#14532d">prévision-</text>
<text x="521" y="208" text-anchor="middle" font-size="10" font-weight="700" fill="#14532d">nelle</text>
<text x="521" y="222" text-anchor="middle" font-size="9" fill="#166534">on anticipe</text>

<rect x="28" y="256" width="504" height="40" rx="8" fill="#eff6ff" stroke="#2563eb" stroke-width="1.4"/>
<text x="280" y="272" text-anchor="middle" font-size="11" font-weight="700" fill="#1e3a8a">Le repère : CORRECTIVE = la panne est déjà là. PRÉVENTIVE = on veut l&apos;éviter.</text>
<text x="280" y="288" text-anchor="middle" font-size="10" fill="#1e40af">Tout le reste n&apos;est qu&apos;une question de moment et de déclencheur.</text>
</svg>', NULL, 5),
      (v_chapitre_id, 'Simulation : corrective ou préventive ?', 3, 'interactif', '{
  "widget": "types-maintenance",
  "consigne": "La simulation te présente des situations réelles — un disque dur qui grince, un planning de dépoussiérage trimestriel, un écran qui ne s''allume plus, un antivirus à mettre à jour — et te demande de les classer dans le bon type de maintenance. Elle t''explique chaque réponse en te montrant où se trouve la panne dans le temps : avant, ou après."
}', NULL, 10),
      (v_chapitre_id, 'Corrective, préventive : les cinq branches', 4, 'texte', '
### La maintenance corrective

Elle intervient **après la panne**. Elle se divise en deux.

La maintenance **palliative** est un **dépannage provisoire**. On remet le bien
en état de fonctionnement en attendant mieux. Tu remplaces l''alimentation
grillée par celle d''une machine hors service pour que le secrétariat puisse
finir sa journée : c''est du palliatif.

La maintenance **curative** est la **réparation définitive**. Tu commandes la
bonne alimentation, tu la montes, le problème est réglé pour de bon.

Le mot *palliatif* vient de *pallium*, le manteau : on couvre le problème. Le
mot *curatif* vient de *cura*, le soin : on le guérit.

### La maintenance préventive

Elle intervient **avant la panne**. Elle se divise en trois, selon ce qui
déclenche l''intervention.

La maintenance **systématique** suit un **échéancier** fixé à l''avance : un
calendrier, ou un nombre d''heures d''utilisation. « On dépoussière toutes les
salles le premier samedi de chaque trimestre. » Peu importe l''état des
machines : la date est arrivée, on y va.

La maintenance **conditionnelle** est **subordonnée au franchissement d''un
seuil**. On surveille un indicateur, et on intervient quand il dépasse une
valeur. « Quand le disque dur dépasse 90 % de remplissage, on le vide. »

La maintenance **prévisionnelle** suit l''**évolution** des paramètres pour
**prévoir la date** de la défaillance. On ne regarde pas seulement la valeur,
on regarde la pente. « Ce disque perd deux secteurs par semaine depuis trois
mois : il sera mort en avril, je le remplace en mars. »

La différence entre les deux dernières est subtile, et c''est précisément pour
cela qu''on la demande en examen. **Conditionnelle, on réagit à un seuil.
Prévisionnelle, on extrapole une tendance.**

---

**Exercice corrigé**

*Classer chacune de ces interventions : a) changer l''écran cassé d''un poste ;
b) brancher provisoirement un vieil écran en attendant la livraison du neuf ;
c) remplacer toutes les piles de cartes mères tous les quatre ans ; d) nettoyer
le ventilateur dès que la température du processeur dépasse 70 °C.*

**Correction.**
a) Corrective **curative** — la panne est là, la réparation est définitive.
b) Corrective **palliative** — la panne est là, la solution est provisoire.
c) Préventive **systématique** — un échéancier, sans regarder l''état.
d) Préventive **conditionnelle** — un seuil de 70 °C déclenche l''action.
', NULL, 25),
      (v_chapitre_id, 'Simulation : l''arbre à compléter', 5, 'interactif', '{
  "widget": "arbre-maintenance",
  "consigne": "L''arbre de la maintenance t''est donné vide. Place les cinq étiquettes — palliative, curative, systématique, conditionnelle, prévisionnelle — au bon endroit. À chaque dépôt, la simulation te donne un exemple concret de cette branche, et elle insiste sur la frontière entre conditionnelle et prévisionnelle, celle qu''on confond le plus souvent."
}', NULL, 10),
      (v_chapitre_id, 'La maintenance logicielle', 6, 'texte', '
Jusqu''ici nous avons parlé de matériel. Mais un logiciel s''entretient aussi, et
la typologie change de noms.

On distingue **trois** maintenances logicielles.

### Corrective

Elle **corrige les erreurs** — les *bugs* — découvertes dans le logiciel après
sa livraison. Le logiciel était censé faire quelque chose, il le faisait mal, on
le répare.

### Évolutive

Elle **ajoute des fonctionnalités** nouvelles. Le logiciel marchait bien, mais
les utilisateurs veulent maintenant pouvoir exporter en PDF. On ne répare rien :
on fait grandir.

### Adaptative

Elle **adapte** le logiciel à un **nouvel environnement**. Rien n''a changé dans
le logiciel ni dans les besoins ; c''est le monde autour qui a bougé. Un nouveau
système d''exploitation, un nouveau format de fichier, un nouveau matériel.

Le moyen de ne pas les confondre tient en trois questions :

| Question | Réponse |
| --- | --- |
| Le logiciel était-il en faute ? | corrective |
| L''utilisateur veut-il plus ? | évolutive |
| Est-ce l''environnement qui a changé ? | adaptative |

---

**Exercice corrigé**

*Le logiciel de gestion des notes de votre lycée tournait sous Windows 7.
L''établissement passe à Windows 11, et le logiciel ne démarre plus. De quelle
maintenance logicielle relève la mise à jour du logiciel ?*

**Correction.** De la maintenance **adaptative**.

Le logiciel n''a pas de défaut : il fonctionnait parfaitement sous Windows 7, et
personne ne lui demande une fonctionnalité nouvelle. C''est son **environnement**
qui a changé. On l''adapte.

Si le même logiciel calculait mal les moyennes, ce serait de la maintenance
**corrective**. Si on lui demandait d''envoyer les bulletins par SMS, ce serait
de la maintenance **évolutive**.
', NULL, 20),
      (v_chapitre_id, 'Simulation : corrective, évolutive ou adaptative ?', 7, 'interactif', '{
  "widget": "maintenance-logicielle",
  "consigne": "Dix demandes arrivent sur le bureau d''un développeur, rédigées comme de vrais tickets : « le total est faux », « on voudrait un export Excel », « ça ne marche plus depuis la mise à jour du téléphone ». Classe chacune dans l''une des trois maintenances logicielles. La simulation te renvoie à chaque fois la question qui tranche : qui était en faute ?"
}', NULL, 10),
      (v_chapitre_id, 'Quiz du chapitre 4', 8, 'quiz', '{
  "titre": "Vérifie que tu as compris",
  "questions": [
    {
      "question": "Quelle est la définition de la maintenance ?",
      "choix": [
        "La réparation d''un appareil en panne",
        "L''ensemble des actions permettant de maintenir ou de rétablir un bien dans un état spécifié",
        "Le nettoyage régulier du matériel",
        "L''achat de matériel de remplacement"
      ],
      "bonne": 1,
      "explication": "Les deux verbes de la définition donnent les deux familles : MAINTENIR, c''est le préventif ; RÉTABLIR, c''est le correctif."
    },
    {
      "question": "Quand intervient la maintenance corrective ?",
      "choix": [
        "Avant la panne",
        "Après la panne",
        "Pendant la fabrication",
        "Au moment de l''achat"
      ],
      "bonne": 1,
      "explication": "Elle rétablit : la panne est déjà là. La préventive, elle, intervient avant, pour l''éviter."
    },
    {
      "question": "Comment appelle-t-on un dépannage provisoire ?",
      "choix": [
        "Une maintenance curative",
        "Une maintenance palliative",
        "Une maintenance systématique",
        "Une maintenance conditionnelle"
      ],
      "bonne": 1,
      "explication": "Palliative vient de pallium, le manteau : on couvre le problème. Curative vient de cura, le soin : on le guérit définitivement."
    },
    {
      "question": "Une maintenance déclenchée par un calendrier fixé à l''avance est :",
      "choix": [
        "systématique",
        "conditionnelle",
        "prévisionnelle",
        "palliative"
      ],
      "bonne": 0,
      "explication": "Un échéancier, une date, un nombre d''heures d''utilisation : la date est arrivée, on intervient, sans regarder l''état de la machine."
    },
    {
      "question": "Quelle est la différence entre maintenance conditionnelle et prévisionnelle ?",
      "choix": [
        "Aucune, ce sont deux noms pour la même chose",
        "La conditionnelle réagit à un seuil franchi, la prévisionnelle extrapole une tendance pour prévoir la date de la panne",
        "La conditionnelle est corrective, la prévisionnelle est préventive",
        "La prévisionnelle concerne les logiciels, la conditionnelle le matériel"
      ],
      "bonne": 1,
      "explication": "La conditionnelle regarde la valeur, la prévisionnelle regarde la pente. C''est la frontière qu''on te demande le plus souvent."
    },
    {
      "question": "Que signifie le sigle GMAO ?",
      "choix": [
        "Gestion du Matériel Après Ouverture",
        "Gestion de la Maintenance Assistée par Ordinateur",
        "Groupe de Maintenance Assistée et Organisée",
        "Gestion Mensuelle des Appareils Ordinés"
      ],
      "bonne": 1,
      "explication": "C''est un logiciel qui tient le registre du parc : quelle machine, quelle intervention, à quelle date, par qui, pour combien."
    },
    {
      "question": "Un logiciel fonctionne mal depuis que l''établissement a changé de système d''exploitation. La mise à jour relève de la maintenance logicielle :",
      "choix": [
        "corrective",
        "évolutive",
        "adaptative",
        "palliative"
      ],
      "bonne": 2,
      "explication": "Le logiciel n''avait aucun défaut et personne ne demande de fonctionnalité nouvelle : c''est l''environnement qui a changé, donc adaptative."
    }
  ]
}', NULL, 5);

    RAISE NOTICE '% : 8 leçons ajoutées au chapitre 4, Introduction à la maintenance.', v_nom;
  END LOOP;
END $inf1$;
