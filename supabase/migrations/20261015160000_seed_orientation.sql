-- ============================================================================
-- Contenu de la base d'orientation : 32 filières, 54 métiers, 52 questions fréquentes.
-- FICHIER GÉNÉRÉ par scripts/generer-seed-orientation.mjs — ne pas modifier à la main.
-- Ré-exécutable : les fiches existantes (même slug) sont mises à jour.
-- ============================================================================

INSERT INTO public.orientation_fiches
  (slug, type, titre, categorie, niveau_acces, resume, contenu, debouches, formations, mots_cles, sources)
VALUES
('systeme-educatif-camerounais', 'filiere', 'Le système éducatif camerounais en un coup d''œil', 'Repères', 'Tous niveaux', 'Deux sous-systèmes (francophone et anglophone), un enseignement général et un enseignement technique, puis l''enseignement supérieur (système LMD) et la formation professionnelle.', '## Deux sous-systèmes
Le Cameroun a un sous-système **francophone** et un sous-système **anglophone**, organisés par la loi d''orientation de l''éducation de 1998.
- **Francophone** : premier cycle (6e à 3e, BEPC ou CAP au technique), puis second cycle (2nde à Terminale, Probatoire puis Baccalauréat).
- **Anglophone** : Form 1 à Form 5 (GCE Ordinary Level), puis Lower Sixth et Upper Sixth (GCE Advanced Level).

## Qui organise les examens ?
- Le **MINESEC** pour le BEPC, le CAP et le Probatoire.
- L''**Office du Baccalauréat du Cameroun (OBC)** pour le Baccalauréat, le Brevet de technicien (BT) et d''autres brevets.
- Le **GCE Board** pour le GCE O Level et le A Level.

## Après le secondaire
- **Universités d''État** : 11 depuis 2022, avec la création de Bertoua, Ebolowa et Garoua. Leurs facultés suivent le système **LMD** : Licence en 3 ans, Master en 2 ans, Doctorat.
- **Grandes écoles** recrutant sur concours : écoles d''ingénieurs, ENS, ENAM, écoles de santé, etc.
- **Instituts privés d''enseignement supérieur (IPES)** : BTS et HND en 2 ans, avec un examen national organisé par le MINESUP.
- **Formation professionnelle** sous la tutelle du MINEFOP, pour apprendre un métier rapidement.', ARRAY[]::text[], ARRAY['BEPC / CAP', 'Probatoire', 'Baccalauréat / BT', 'GCE O Level / A Level', 'Licence, Master, Doctorat', 'BTS / HND']::text[], ARRAY['système éducatif', 'cycle', 'francophone', 'anglophone', 'LMD', 'examens officiels', 'orientation']::text[], '[{"titre":"Loi n°98/004 du 14 avril 1998 d''orientation de l''éducation au Cameroun"},{"titre":"Loi n°2023/007 du 25 juillet 2023 portant orientation de l''enseignement supérieur au Cameroun"},{"titre":"Décret n°2012/267 du 11 juin 2012 portant organisation du MINESEC"},{"titre":"Ministère des Enseignements Secondaires (MINESEC)","url":"https://www.minesec.gov.cm"},{"titre":"Office du Baccalauréat du Cameroun (OBC) — Probatoire, Baccalauréat, BT","url":"https://www.obc.cm"},{"titre":"Cameroon GCE Board — GCE O Level / A Level","url":"https://www.camgceb.org"},{"titre":"Ministère de l''Enseignement Supérieur (MINESUP) — concours, BTS/HND, établissements","url":"https://www.minesup.gov.cm"}]'::jsonb),
('choisir-sa-serie-en-seconde', 'filiere', 'Choisir sa série après la 3e (2nde C, A, TI ou enseignement technique)', 'Secondaire général (francophone)', 'Fin de 3e (BEPC)', 'Le choix de la série en 2nde engage la suite : scientifique (C, D, E, TI), littéraire (A) ou technique (industriel, commercial). Il doit partir de tes résultats, de tes goûts et du métier visé.', '## Les grandes familles
- **Scientifique** : 2nde C, qui mène en 1ère aux séries C, D ou E, ou à la série TI (technologies de l''information) dans les établissements qui la proposent.
- **Littéraire** : 2nde A, qui mène à la série A et à ses options de langues.
- **Technique** : lycées techniques, avec les séries industrielles (F1 à F8…) ou les séries commerciales et tertiaires.

## Comment décider
- Regarde tes **notes de 4e et 3e** en mathématiques, sciences physiques, SVT, français et langues.
- Pars du **métier visé** : médecine et agronomie demandent C ou D ; ingénierie demande C, E ou F ; le droit et le journalisme acceptent A et C.
- Les séries scientifiques ouvrent plus de portes, mais une série A choisie par goût et bien réussie vaut mieux qu''une série C subie.
- Parle au **conseiller d''orientation** de ton établissement et à tes enseignants.

## Bon à savoir
Les passerelles existent (redoublement réorienté, changement d''établissement), mais elles sont plus faciles au début du second cycle.', ARRAY['Séries C, D, E, TI', 'Série A', 'Baccalauréat technique (F, commercial)']::text[], ARRAY['Lycées d''enseignement général', 'Lycées techniques']::text[], ARRAY['seconde', '2nde', 'série', 'choisir', 'BEPC', 'après la troisième', 'orientation']::text[], '[{"titre":"Ministère des Enseignements Secondaires (MINESEC)","url":"https://www.minesec.gov.cm"},{"titre":"Conseiller d''orientation de ton établissement (service d''orientation scolaire)"}]'::jsonb),
('serie-c', 'filiere', 'Série C (Mathématiques et Sciences physiques)', 'Secondaire général (francophone)', '2nde C', 'La série la plus orientée vers les mathématiques et la physique-chimie. Elle ouvre toutes les écoles d''ingénieurs et la plupart des filières scientifiques.', '## Contenu
Les **mathématiques** et les **sciences physiques** y ont les plus forts coefficients. La SVT, le français, la philosophie et les langues restent présentes.

## Pour qui ?
Pour l''élève à l''aise en calcul et en raisonnement, qui aime résoudre des problèmes.

## Ce qu''elle ouvre
- **Écoles d''ingénieurs** sur concours : Polytechnique de Yaoundé (ENSP), ENSPD Douala, ENSTP, ENSAI, IUT, etc.
- Facultés des sciences : mathématiques, physique, informatique.
- Médecine, pharmacie et agronomie : la série C y est admise comme la série D.
- Statistique (ISSEA), économie, enseignement des sciences (ENS, ENSET).

## Conseil
Travaille l''**analyse** (fonctions, suites, intégrales) et la **mécanique**, très présentes aux concours d''ingénieurs.', ARRAY['Ingénieur', 'Statisticien', 'Médecin', 'Enseignant de sciences', 'Informaticien']::text[], ARRAY['ENSP Yaoundé', 'ENSPD Douala', 'ENSTP', 'ISSEA', 'Facultés des sciences', 'FMSB']::text[], ARRAY['bac c', 'série c', 'maths', 'physique', 'scientifique', 'ingénieur']::text[], '[{"titre":"Office du Baccalauréat du Cameroun (OBC) — Probatoire, Baccalauréat, BT","url":"https://www.obc.cm"},{"titre":"Ministère de l''Enseignement Supérieur (MINESUP) — concours, BTS/HND, établissements","url":"https://www.minesup.gov.cm"},{"titre":"Université de Yaoundé I (ENSP, ENS, FMSB, Faculté des Sciences)","url":"http://www.uy1.uninet.cm"}]'::jsonb),
('serie-d', 'filiere', 'Série D (Mathématiques et Sciences de la vie et de la Terre)', 'Secondaire général (francophone)', '2nde C', 'Série scientifique où la SVT a un poids important. C''est la voie naturelle vers la médecine, la pharmacie, l''agronomie, la biologie et les métiers de la santé.', '## Contenu
Mathématiques, **SVT** et sciences physiques forment le cœur de la série, avec le français, la philosophie et les langues.

## Ce qu''elle ouvre
- **Médecine, pharmacie et chirurgie dentaire** sur concours : FMSB (Yaoundé I), FMSP (Douala), Faculty of Health Sciences (Buea) et autres facultés de médecine.
- **Agronomie** : FASA (Dschang), et les **agro-industries** à l''ENSAI (Ngaoundéré).
- Écoles **paramédicales** : infirmiers, sages-femmes, techniciens de laboratoire.
- Facultés des sciences (biologie, biochimie, géologie), ENS (SVT), vétérinaire.

## Conseil
Les concours de médecine sont très sélectifs. Vise un très bon niveau en **SVT, chimie et physique** et prépare-toi tôt avec les annales.', ARRAY['Médecin', 'Pharmacien', 'Infirmier', 'Agronome', 'Biologiste', 'Vétérinaire']::text[], ARRAY['FMSB', 'FMSP Douala', 'FHS Buea', 'FASA Dschang', 'ENSAI', 'Écoles paramédicales']::text[], ARRAY['bac d', 'série d', 'svt', 'médecine', 'santé', 'biologie', 'agronomie']::text[], '[{"titre":"Office du Baccalauréat du Cameroun (OBC) — Probatoire, Baccalauréat, BT","url":"https://www.obc.cm"},{"titre":"Ministère de l''Enseignement Supérieur (MINESUP) — concours, BTS/HND, établissements","url":"https://www.minesup.gov.cm"},{"titre":"Université de Yaoundé I (ENSP, ENS, FMSB, Faculté des Sciences)","url":"http://www.uy1.uninet.cm"},{"titre":"Université de Dschang (FASA, IUT Fotso Victor de Bandjoun)"},{"titre":"University of Buea (Faculty of Health Sciences, COT, faculties)"},{"titre":"Université de Douala (ENSPD, ENSET, IUT, FMSP, ESSEC)"}]'::jsonb),
('serie-e', 'filiere', 'Série E (Mathématiques et Techniques)', 'Secondaire général (francophone)', '2nde C', 'Série scientifique tournée vers les sciences et techniques industrielles. Elle prépare très bien aux écoles d''ingénieurs et aux IUT.', '## Contenu
Mathématiques et sciences physiques à forts coefficients, plus des enseignements de **technologie** : construction, dessin technique, mécanique.

## Ce qu''elle ouvre
- **Écoles d''ingénieurs** : génie mécanique, génie civil, génie électrique, génie industriel.
- **IUT** et ENSET, pour devenir professeur de l''enseignement technique.
- Licences scientifiques et technologiques.

## Bon à savoir
La série E n''existe que dans certains établissements : renseigne-toi auprès de ton lycée ou de la délégation régionale du MINESEC.', ARRAY['Ingénieur mécanicien', 'Ingénieur génie civil', 'Technicien supérieur', 'Professeur de l''enseignement technique']::text[], ARRAY['ENSP', 'ENSPD', 'ENSTP', 'IUT', 'ENSET']::text[], ARRAY['bac e', 'série e', 'technique', 'mécanique', 'ingénieur']::text[], '[{"titre":"Office du Baccalauréat du Cameroun (OBC) — Probatoire, Baccalauréat, BT","url":"https://www.obc.cm"},{"titre":"Ministère des Enseignements Secondaires (MINESEC)","url":"https://www.minesec.gov.cm"},{"titre":"Ministère de l''Enseignement Supérieur (MINESUP) — concours, BTS/HND, établissements","url":"https://www.minesup.gov.cm"}]'::jsonb),
('serie-ti', 'filiere', 'Série TI (Technologies de l''Information)', 'Secondaire général (francophone)', '2nde C ou 2nde TI selon l''établissement', 'Série scientifique centrée sur l''informatique : algorithmique, programmation et réseaux, avec des mathématiques solides. Elle prépare aux études d''informatique et du numérique.', '## Contenu
Mathématiques, **informatique** (algorithmique, programmation, bases de données, réseaux) et sciences physiques.

## Ce qu''elle ouvre
- Licences et écoles d''**informatique** et de **génie logiciel**.
- IUT (génie informatique, réseaux et télécoms), BTS/HND en informatique.
- Concours d''ingénieurs qui l''admettent : vérifie la liste des diplômes acceptés dans chaque communiqué.

## Conseil
Programme en dehors des cours : petits projets, sites web, applications. Les entreprises du numérique regardent ce que tu sais **faire**.', ARRAY['Développeur', 'Administrateur réseaux', 'Analyste de données', 'Technicien informatique']::text[], ARRAY['Facultés des sciences (informatique)', 'IUT', 'ENSP (génie informatique)', 'BTS/HND informatique']::text[], ARRAY['bac ti', 'série ti', 'informatique', 'programmation', 'numérique', 'technologies de l''information']::text[], '[{"titre":"Office du Baccalauréat du Cameroun (OBC) — Probatoire, Baccalauréat, BT","url":"https://www.obc.cm"},{"titre":"Ministère des Enseignements Secondaires (MINESEC)","url":"https://www.minesec.gov.cm"},{"titre":"Ministère de l''Enseignement Supérieur (MINESUP) — concours, BTS/HND, établissements","url":"https://www.minesup.gov.cm"}]'::jsonb),
('serie-a', 'filiere', 'Série A (Lettres, Langues et Philosophie)', 'Secondaire général (francophone)', '2nde A', 'Série littéraire : français, philosophie, histoire-géographie et langues vivantes. Elle mène au droit, au journalisme, aux langues, à l''enseignement et à l''administration.', '## Contenu
Le **français**, la **philosophie**, l''histoire-géographie et les **langues** (anglais et une autre langue selon l''option) dominent, avec des mathématiques.

## Ce qu''elle ouvre
- **Droit** et science politique, **lettres**, langues, histoire, géographie, sociologie.
- **Journalisme et communication** (ESSTIC, sur concours).
- **Enseignement** (ENS, filières littéraires), **traduction et interprétation**.
- Administration, après une licence (ENAM cycle A, IRIC pour la diplomatie).

## Conseil
Au Cameroun, pays bilingue, **une très bonne maîtrise de l''anglais** est un vrai atout. Lis beaucoup et entraîne-toi à la dissertation.', ARRAY['Avocat', 'Journaliste', 'Enseignant de lettres', 'Traducteur', 'Diplomate', 'Administrateur civil']::text[], ARRAY['Facultés de droit', 'Facultés des lettres', 'ESSTIC', 'ENS', 'ENAM', 'IRIC']::text[], ARRAY['bac a', 'série a', 'littéraire', 'lettres', 'philosophie', 'langues', 'droit']::text[], '[{"titre":"Office du Baccalauréat du Cameroun (OBC) — Probatoire, Baccalauréat, BT","url":"https://www.obc.cm"},{"titre":"Ministère de l''Enseignement Supérieur (MINESUP) — concours, BTS/HND, établissements","url":"https://www.minesup.gov.cm"},{"titre":"Université de Yaoundé II-Soa (Droit, Économie, ESSTIC, IRIC)"},{"titre":"École Nationale d''Administration et de Magistrature (ENAM)","url":"https://www.enam.cm"}]'::jsonb),
('enseignement-technique-industriel', 'filiere', 'Enseignement technique industriel (séries F)', 'Secondaire technique', 'CAP ou 2nde technique', 'Les lycées techniques préparent aux métiers de l''industrie : fabrication mécanique (F1), électronique (F2), électrotechnique (F3), génie civil (F4), froid et climatisation (F5), génie chimique (F6), sciences biologiques et médico-sanitaires (F7), santé et social (F8).', '## Les spécialités les plus courantes
- **F1** : fabrication mécanique.
- **F2** : électronique.
- **F3** : électrotechnique.
- **F4** : génie civil, avec les options bâtiment, travaux publics et bureau d''études.
- **F5** : froid et climatisation.
- **F6** : génie chimique.
- **F7** : sciences biologiques.
- **F8** : sciences médico-sociales.

## Les diplômes
- **CAP** à la fin du premier cycle technique.
- **Probatoire** et **Baccalauréat de technicien**, ou **Brevet de technicien (BT)**, au second cycle.

## Ce qu''elle ouvre
- Un **emploi qualifié rapide** : technicien, chef de chantier, électricien, frigoriste.
- **IUT**, **BTS/HND**, ENSET, certaines **écoles d''ingénieurs** sur concours, et l''**auto-emploi**, très recherché au Cameroun.

## Conseil
Les stages en entreprise comptent beaucoup : profite de chaque période de stage pour te faire connaître.', ARRAY['Technicien BTP', 'Électricien', 'Électronicien', 'Frigoriste', 'Mécanicien', 'Chef de chantier']::text[], ARRAY['Lycées techniques', 'IUT', 'ENSET', 'BTS/HND', 'ENSTP']::text[], ARRAY['technique', 'série f', 'f1', 'f2', 'f3', 'f4', 'f5', 'génie civil', 'électrotechnique', 'cap', 'bt']::text[], '[{"titre":"Office du Baccalauréat du Cameroun (OBC) — Probatoire, Baccalauréat, BT","url":"https://www.obc.cm"},{"titre":"Ministère des Enseignements Secondaires (MINESEC)","url":"https://www.minesec.gov.cm"}]'::jsonb),
('enseignement-technique-commercial', 'filiere', 'Enseignement technique commercial et tertiaire', 'Secondaire technique', 'CAP ou 2nde technique commerciale', 'Les séries commerciales et tertiaires forment à la comptabilité et à la gestion, au commerce et à la vente, au secrétariat et à la bureautique.', '## Les spécialités
- **Comptabilité et gestion**.
- **Action commerciale et vente**.
- **Secrétariat et bureautique**.
- Selon les établissements : banque, assurance, transport-logistique.

Les appellations historiques sont G1, G2 et G3. Les intitulés évoluent avec les réformes : vérifie-les auprès de ton lycée ou du MINESEC.

## Ce qu''elle ouvre
- Un **emploi** dans les PME, les commerces, les banques et les administrations.
- **BTS/HND** (comptabilité, banque, marketing, logistique), **ESSEC**, IUT, facultés de sciences économiques et de gestion.
- La **création d''entreprise** : les bases de gestion sont un atout réel.

## Conseil
Maîtrise un **logiciel de comptabilité** et le **tableur** : c''est ce que demandent d''abord les employeurs.', ARRAY['Comptable', 'Commercial', 'Assistant de direction', 'Agent de banque', 'Gestionnaire de stock']::text[], ARRAY['Lycées techniques commerciaux', 'BTS/HND', 'ESSEC Douala', 'IUT', 'FSEG']::text[], ARRAY['commercial', 'comptabilité', 'gestion', 'secrétariat', 'série g', 'g1', 'g2', 'g3', 'tertiaire']::text[], '[{"titre":"Office du Baccalauréat du Cameroun (OBC) — Probatoire, Baccalauréat, BT","url":"https://www.obc.cm"},{"titre":"Ministère des Enseignements Secondaires (MINESEC)","url":"https://www.minesec.gov.cm"}]'::jsonb),
('gce-o-level', 'filiere', 'GCE Ordinary Level (O Level)', 'Sous-système anglophone', 'Form 5', 'Examen de fin de Form 5 organisé par le Cameroon GCE Board. Le nombre et le choix des matières réussies conditionnent l''entrée en Lower Sixth.', '## Principe
L''élève compose plusieurs **subjects** : English language, mathematics, sciences, humanities, commercial or technical subjects. Chaque matière réussie compte.

## Pourquoi c''est important
- L''entrée en **Lower Sixth**, dans la bonne combinaison (sciences, arts, commercial), dépend des matières réussies et de leurs notes.
- De nombreux concours et formations demandent un **minimum de matières réussies**, souvent avec l''anglais et les mathématiques.

## Conseil
Choisis tes subjects en pensant à ta future combinaison au A Level : pour la médecine, il faut biology, chemistry et physics.', ARRAY['GCE A Level', 'Technical / commercial training', 'Professional schools']::text[], ARRAY['Secondary and high schools (anglophone subsystem)']::text[], ARRAY['gce', 'o level', 'ordinary level', 'form 5', 'anglophone', 'subjects']::text[], '[{"titre":"Cameroon GCE Board — GCE O Level / A Level","url":"https://www.camgceb.org"},{"titre":"Ministère des Enseignements Secondaires (MINESEC)","url":"https://www.minesec.gov.cm"}]'::jsonb),
('gce-a-level', 'filiere', 'GCE Advanced Level (A Level)', 'Sous-système anglophone', 'Upper Sixth', 'Examen de fin de Upper Sixth, équivalent du Baccalauréat. La combinaison de matières (science, arts, commercial) détermine les études possibles.', '## Combinaisons fréquentes
- **Sciences** : mathematics, physics, chemistry ou biology. Elles mènent à l''ingénierie, à la médecine, à l''agronomie et à l''informatique.
- **Arts** : literature, history, geography, languages, economics. Elles mènent au droit, au journalisme et aux langues.
- **Commercial** : accounting, economics, business mathematics. Elles mènent à la gestion, à la banque et à la comptabilité.

## Ce qu''il ouvre
Les universités d''État comme Buea et Bamenda, et toutes les grandes écoles bilingues. Les concours publient des versions françaises et anglaises, avec des conditions précises en nombre de papers et de points.

## Conseil
Vérifie dans chaque communiqué de concours le **nombre de papers** et les **subjects exigés**.', ARRAY['Engineering', 'Medicine', 'Law', 'Business', 'Teaching']::text[], ARRAY['University of Buea', 'University of Bamenda', 'Grandes écoles (bilingual)']::text[], ARRAY['gce', 'a level', 'advanced level', 'upper sixth', 'anglophone', 'combination', 'papers']::text[], '[{"titre":"Cameroon GCE Board — GCE O Level / A Level","url":"https://www.camgceb.org"},{"titre":"Ministère de l''Enseignement Supérieur (MINESUP) — concours, BTS/HND, établissements","url":"https://www.minesup.gov.cm"},{"titre":"University of Buea (Faculty of Health Sciences, COT, faculties)"},{"titre":"University of Bamenda (COLTECH, HTTTC, NAHPI)"}]'::jsonb),
('universites-etat-lmd', 'filiere', 'Universités d''État et système LMD', 'Enseignement supérieur', 'Baccalauréat ou GCE A Level', 'Le Cameroun compte 11 universités d''État. Leurs facultés accueillent les bacheliers sur dossier ; leurs grandes écoles recrutent sur concours. Diplômes : Licence (3 ans), Master (2 ans), Doctorat.', '## Les universités d''État
Yaoundé I, Yaoundé II (Soa), Douala, Dschang, Buea, Ngaoundéré, Maroua et Bamenda, auxquelles s''ajoutent depuis 2022 **Bertoua, Ebolowa et Garoua**.

## Facultés et grandes écoles
- **Facultés** (sciences, lettres, droit, économie…) : inscription généralement sur étude de dossier après le Bac ou le A Level.
- **Grandes écoles et instituts** des universités (ENSP, ENS, FMSB, ESSTIC, IUT…) : **concours**, souvent très sélectifs.

## Le système LMD
- **Licence** en 3 ans, **Master** en 2 ans, **Doctorat** en 3 ans environ.
- Les enseignements sont organisés en **unités d''enseignement (UE)** capitalisables, comptées en **crédits**.

## Conseil
Consulte le **site du MINESUP** et ceux des universités pour les calendriers d''inscription et la liste des concours.', ARRAY[]::text[], ARRAY['Licence', 'Master', 'Doctorat']::text[], ARRAY['université', 'faculté', 'lmd', 'licence', 'master', 'doctorat', 'inscription']::text[], '[{"titre":"Ministère de l''Enseignement Supérieur (MINESUP) — concours, BTS/HND, établissements","url":"https://www.minesup.gov.cm"},{"titre":"Loi n°2023/007 du 25 juillet 2023 portant orientation de l''enseignement supérieur au Cameroun"},{"titre":"Université de Yaoundé I (ENSP, ENS, FMSB, Faculté des Sciences)","url":"http://www.uy1.uninet.cm"}]'::jsonb),
('faculte-des-sciences', 'filiere', 'Faculté des sciences (mathématiques, physique, chimie, biologie, informatique, géologie)', 'Enseignement supérieur', 'Bac C, D, E, TI ou A Level sciences', 'Licences et masters scientifiques dans toutes les universités d''État. Une voie solide vers l''enseignement, la recherche, l''informatique, les mines et l''environnement, et une passerelle vers les concours après la licence.', '## Parcours
Licences en **mathématiques, physique, chimie, biologie, biochimie, informatique, sciences de la Terre (géologie)**, puis masters professionnels ou de recherche.

## Débouchés au Cameroun
- **Enseignement**, via le concours de l''ENS après la licence.
- **Informatique** et numérique.
- **Mines, pétrole et environnement** pour les géosciences.
- **Laboratoires** : santé, agroalimentaire, contrôle qualité.
- **Recherche**, avec le doctorat.

## Conseil
La licence ouvre aussi des **concours de niveau Licence** : ENS deuxième cycle, ENAM cycle A, ISSEA, certaines écoles d''ingénieurs en admission parallèle.', ARRAY['Enseignant', 'Chercheur', 'Géologue', 'Informaticien', 'Technicien de laboratoire']::text[], ARRAY['Facultés des sciences des universités d''État']::text[], ARRAY['faculté des sciences', 'licence', 'maths', 'physique', 'chimie', 'biologie', 'informatique', 'géologie']::text[], '[{"titre":"Ministère de l''Enseignement Supérieur (MINESUP) — concours, BTS/HND, établissements","url":"https://www.minesup.gov.cm"},{"titre":"Université de Yaoundé I (ENSP, ENS, FMSB, Faculté des Sciences)","url":"http://www.uy1.uninet.cm"}]'::jsonb),
('droit-science-politique', 'filiere', 'Droit et science politique', 'Enseignement supérieur', 'Baccalauréat (toutes séries) ou A Level', 'Licences en droit privé, droit public, science politique, en français ou en anglais (common law). Elles mènent au barreau, à la magistrature (ENAM), à l''administration, aux banques et aux entreprises.', '## Parcours
Licence puis master en **droit privé, droit public, droit des affaires, science politique**. Le **bijuridisme**, entre droit civil et common law, est une particularité camerounaise.

## Débouchés
- **Avocat**, après le master et l''accès au barreau.
- **Magistrat**, par le concours de l''ENAM, section magistrature.
- **Huissier, notaire**, juriste d''entreprise, administrateur, diplomate (IRIC), forces de l''ordre (officiers de police).

## Conseil
Lis beaucoup, entraîne-toi à l''écrit et à l''oral, et apprends le **vocabulaire juridique dans les deux langues officielles**.', ARRAY['Avocat', 'Magistrat', 'Juriste d''entreprise', 'Huissier', 'Notaire', 'Diplomate']::text[], ARRAY['Facultés de sciences juridiques et politiques (Yaoundé II, Douala, Dschang, Buea…)', 'ENAM', 'IRIC']::text[], ARRAY['droit', 'juriste', 'avocat', 'magistrat', 'science politique', 'common law', 'faculté de droit']::text[], '[{"titre":"Ministère de l''Enseignement Supérieur (MINESUP) — concours, BTS/HND, établissements","url":"https://www.minesup.gov.cm"},{"titre":"Université de Yaoundé II-Soa (Droit, Économie, ESSTIC, IRIC)"},{"titre":"École Nationale d''Administration et de Magistrature (ENAM)","url":"https://www.enam.cm"},{"titre":"Ministère de la Justice — barreau, huissiers, notaires"}]'::jsonb),
('sciences-economiques-gestion', 'filiere', 'Sciences économiques et gestion', 'Enseignement supérieur', 'Baccalauréat ou A Level', 'Licences et masters en économie, gestion, finance, comptabilité, marketing. Débouchés dans les banques, les entreprises, les administrations financières et la création d''entreprise.', '## Où étudier
- **Facultés de sciences économiques et de gestion** (FSEG) des universités d''État.
- **ESSEC Douala**, sur concours, pour la gestion et le commerce.
- **ISSEA**, sur concours, pour la statistique et l''économie appliquée.
- **BTS/HND** en comptabilité, banque ou marketing dans les instituts privés.

## Débouchés
Banques, microfinance, assurances, entreprises, cabinets comptables, régies financières (impôts, douanes, trésor) par l''ENAM, et création d''entreprise.

## Conseil
Les **mathématiques** comptent en économie : n''abandonne pas les maths si tu vises la finance ou la statistique.', ARRAY['Économiste', 'Comptable', 'Banquier', 'Contrôleur de gestion', 'Inspecteur des impôts']::text[], ARRAY['FSEG', 'ESSEC Douala', 'ISSEA', 'BTS/HND', 'ENAM (régies financières)']::text[], ARRAY['économie', 'gestion', 'finance', 'comptabilité', 'fseg', 'essec', 'banque']::text[], '[{"titre":"Ministère de l''Enseignement Supérieur (MINESUP) — concours, BTS/HND, établissements","url":"https://www.minesup.gov.cm"},{"titre":"Université de Douala (ENSPD, ENSET, IUT, FMSP, ESSEC)"},{"titre":"Institut Sous-régional de Statistique et d''Économie Appliquée (ISSEA, Yaoundé — CEMAC)"},{"titre":"École Nationale d''Administration et de Magistrature (ENAM)","url":"https://www.enam.cm"}]'::jsonb),
('lettres-langues-sciences-humaines', 'filiere', 'Lettres, langues et sciences humaines', 'Enseignement supérieur', 'Baccalauréat ou A Level', 'Lettres modernes, langues (anglais, allemand, espagnol, chinois…), histoire, géographie, sociologie, psychologie, philosophie. Vers l''enseignement, la traduction, le tourisme, la culture et la communication.', '## Parcours
Licences et masters en **lettres, langues étrangères, langues et cultures camerounaises, histoire, géographie, sociologie, psychologie, philosophie**.

## Débouchés
- **Enseignement**, par le concours de l''ENS.
- **Traduction et interprétation** : le bilinguisme anglais-français est très demandé.
- **Tourisme**, **culture** et patrimoine.
- **Communication**, ONG, ressources humaines (psychologie, sociologie), conseil d''orientation.

## Conseil
Ajoute une **compétence pratique** à ton diplôme (informatique, langue rare, gestion de projet) pour te démarquer sur le marché de l''emploi.', ARRAY['Enseignant', 'Traducteur', 'Guide touristique', 'Psychologue', 'Chargé de communication']::text[], ARRAY['Facultés des lettres et sciences humaines', 'ENS', 'ASTI (Buea, traduction)']::text[], ARRAY['lettres', 'langues', 'histoire', 'géographie', 'sociologie', 'psychologie', 'philosophie', 'traduction']::text[], '[{"titre":"Ministère de l''Enseignement Supérieur (MINESUP) — concours, BTS/HND, établissements","url":"https://www.minesup.gov.cm"},{"titre":"University of Buea (Faculty of Health Sciences, COT, faculties)"}]'::jsonb),
('ecoles-ingenieurs', 'filiere', 'Écoles d''ingénieurs (ENSP Yaoundé, ENSPD Douala, ENSPM Maroua, ENSTP…)', 'Grandes écoles', 'Bac C, D, E, F, TI ou A Level sciences (selon l''école)', 'Les écoles d''ingénieurs publiques recrutent sur concours très sélectif après le Bac (formation en 5 ans) et parfois en admission parallèle après une licence. Spécialités : génie civil, électrique, mécanique, informatique, télécoms, industriel, chimique…', '## Les principales écoles publiques
- **École Nationale Supérieure Polytechnique de Yaoundé** (Université de Yaoundé I).
- **ENSPD Douala** (Université de Douala).
- **ENSP de Maroua** (Université de Maroua).
- **ENSTP**, pour les travaux publics.
- **ENSAI** (Ngaoundéré), pour les agro-industries.
- Les **IUT**, pour les techniciens supérieurs.

## Le concours
Les épreuves portent surtout sur les **mathématiques**, la **physique-chimie** et parfois la culture générale ou le français.

## Conseil
Entraîne-toi sur les **annales** des concours et travaille la vitesse. Les places sont limitées : présente plusieurs concours la même année.

Les conditions exactes (diplômes admis, âge, frais, dates, nombre de places) changent chaque année : vérifie toujours le communiqué officiel du concours.', ARRAY['Ingénieur génie civil', 'Ingénieur électricien', 'Ingénieur informaticien', 'Ingénieur télécoms', 'Ingénieur mécanicien']::text[], ARRAY['ENSP Yaoundé', 'ENSPD Douala', 'ENSPM Maroua', 'ENSTP', 'ENSAI']::text[], ARRAY['ingénieur', 'polytechnique', 'enspy', 'enspd', 'enstp', 'concours', 'génie']::text[], '[{"titre":"Ministère de l''Enseignement Supérieur (MINESUP) — concours, BTS/HND, établissements","url":"https://www.minesup.gov.cm"},{"titre":"Université de Yaoundé I (ENSP, ENS, FMSB, Faculté des Sciences)","url":"http://www.uy1.uninet.cm"},{"titre":"Université de Douala (ENSPD, ENSET, IUT, FMSP, ESSEC)"},{"titre":"Université de Maroua (ENSPM, ENS)"},{"titre":"Ministère des Travaux Publics (MINTP) — ENSTP"}]'::jsonb),
('iut', 'filiere', 'Instituts Universitaires de Technologie (IUT)', 'Grandes écoles', 'Bac scientifique, technique ou commercial, ou A Level', 'Les IUT (Douala, Fotso Victor de Bandjoun, Ngaoundéré) forment des techniciens supérieurs en 2 à 3 ans (DUT, licence technologique), avec une possibilité de poursuite en école d''ingénieurs.', '## Spécialités fréquentes
Génie civil, génie électrique, génie mécanique, génie informatique, réseaux et télécoms, maintenance industrielle, gestion, commerce, logistique, génie biologique.

## Atouts
- Une formation **courte et pratique**, avec des stages.
- Une **insertion rapide**.
- Une possibilité de **poursuite d''études**, en licence professionnelle ou en école d''ingénieurs, sur concours.

Les conditions exactes (diplômes admis, âge, frais, dates, nombre de places) changent chaque année : vérifie toujours le communiqué officiel du concours.', ARRAY['Technicien supérieur', 'Chef d''équipe', 'Technicien de maintenance', 'Assistant de gestion']::text[], ARRAY['IUT de Douala', 'IUT Fotso Victor de Bandjoun', 'IUT de Ngaoundéré']::text[], ARRAY['iut', 'dut', 'technicien supérieur', 'licence technologique', 'bandjoun', 'douala']::text[], '[{"titre":"Ministère de l''Enseignement Supérieur (MINESUP) — concours, BTS/HND, établissements","url":"https://www.minesup.gov.cm"},{"titre":"Université de Douala (ENSPD, ENSET, IUT, FMSP, ESSEC)"},{"titre":"Université de Dschang (FASA, IUT Fotso Victor de Bandjoun)"},{"titre":"Université de Ngaoundéré (ENSAI, IUT, EGCIM)"}]'::jsonb),
('medecine-pharmacie', 'filiere', 'Médecine, pharmacie et chirurgie dentaire', 'Santé', 'Bac C ou D, ou A Level sciences (biology, chemistry, physics)', 'Les facultés de médecine publiques (FMSB Yaoundé I, FMSP Douala, Faculty of Health Sciences de Buea et autres) recrutent sur concours très sélectif. La formation de médecin généraliste dure environ 7 ans.', '## Où se former
- **FMSB** (Faculté de Médecine et des Sciences Biomédicales, Université de Yaoundé I).
- **FMSP** (Université de Douala).
- **Faculty of Health Sciences** (University of Buea).
- D''autres facultés de médecine publiques et des établissements privés agréés.

## Le concours
Les épreuves portent surtout sur la **biologie**, la **chimie**, la **physique** et parfois la culture générale. Il y a beaucoup de candidats pour peu de places.

## La réalité
Les études sont **longues et exigeantes**. Les besoins sont réels, surtout dans les **zones rurales**. Après le doctorat, les spécialisations (chirurgie, pédiatrie, gynécologie…) passent par d''autres concours.

## Conseil
Si tu échoues au concours, l''**option paramédicale** (infirmier, sage-femme, technicien de laboratoire) ou la **biologie** sont de bonnes voies de rebond.

Les conditions exactes (diplômes admis, âge, frais, dates, nombre de places) changent chaque année : vérifie toujours le communiqué officiel du concours.', ARRAY['Médecin généraliste', 'Médecin spécialiste', 'Pharmacien', 'Chirurgien-dentiste', 'Chercheur biomédical']::text[], ARRAY['FMSB (Yaoundé I)', 'FMSP (Douala)', 'FHS (Buea)']::text[], ARRAY['médecine', 'médecin', 'pharmacie', 'dentiste', 'fmsb', 'concours médecine', 'santé']::text[], '[{"titre":"Ministère de l''Enseignement Supérieur (MINESUP) — concours, BTS/HND, établissements","url":"https://www.minesup.gov.cm"},{"titre":"Université de Yaoundé I (ENSP, ENS, FMSB, Faculté des Sciences)","url":"http://www.uy1.uninet.cm"},{"titre":"Université de Douala (ENSPD, ENSET, IUT, FMSP, ESSEC)"},{"titre":"University of Buea (Faculty of Health Sciences, COT, faculties)"},{"titre":"Ministère de la Santé Publique (MINSANTE) — écoles de formation paramédicale"}]'::jsonb),
('formations-paramedicales', 'filiere', 'Formations paramédicales (infirmier, sage-femme, technicien de laboratoire…)', 'Santé', 'Probatoire, Baccalauréat ou GCE selon la formation', 'Les écoles publiques de formation du MINSANTE et des universités, ainsi que les instituts privés agréés (BTS/HND santé), forment infirmiers, sages-femmes, techniciens de laboratoire, d''imagerie, de pharmacie, kinésithérapeutes.', '## Les métiers
- Infirmier diplômé d''État.
- Sage-femme ou maïeuticien.
- Technicien de laboratoire, technicien en imagerie médicale.
- Préparateur en pharmacie.
- Kinésithérapeute.
- Aide-soignant.

## Où se former
- **Écoles publiques**, sur concours : écoles du MINSANTE, filières des universités.
- **Instituts privés agréés**, en **BTS/HND santé**. Vérifie toujours que l''institut est **agréé** et que la filière est autorisée.

## Réalité
Les besoins sont forts dans les hôpitaux, les centres de santé, les cliniques privées et les ONG, notamment hors des grandes villes.

Les conditions exactes (diplômes admis, âge, frais, dates, nombre de places) changent chaque année : vérifie toujours le communiqué officiel du concours.', ARRAY['Infirmier', 'Sage-femme', 'Technicien de laboratoire', 'Technicien d''imagerie', 'Kinésithérapeute']::text[], ARRAY['Écoles du MINSANTE', 'Universités (filières santé)', 'BTS/HND santé (instituts agréés)']::text[], ARRAY['infirmier', 'sage-femme', 'paramédical', 'laboratoire', 'santé', 'aide-soignant', 'kiné']::text[], '[{"titre":"Ministère de la Santé Publique (MINSANTE) — écoles de formation paramédicale"},{"titre":"Ministère de l''Enseignement Supérieur (MINESUP) — concours, BTS/HND, établissements","url":"https://www.minesup.gov.cm"}]'::jsonb),
('agronomie-agro-industrie', 'filiere', 'Agronomie, agro-industrie, élevage et forêt', 'Agriculture & environnement', 'Bac C ou D, ou A Level sciences', 'La FASA (Université de Dschang) forme des ingénieurs agronomes et forestiers ; l''ENSAI (Ngaoundéré) des ingénieurs des industries agroalimentaires. L''agriculture reste un grand secteur d''emploi et d''entrepreneuriat au Cameroun.', '## Où se former
- **FASA** (Faculté d''Agronomie et des Sciences Agricoles, Université de Dschang), sur concours : agronomie, productions animales, forêt, économie rurale.
- **ENSAI** (Ngaoundéré) : agro-industries et transformation alimentaire.
- Écoles et centres sous tutelle du MINADER et du MINEPIA, pour les techniciens d''agriculture et d''élevage.
- **IUT** (génie biologique) et **BTS/HND** en agriculture.

## Débouchés
- **Agrobusiness** et création d''exploitation (cacao, café, maïs, cultures maraîchères, aviculture, pisciculture).
- Agro-industries, conseil agricole, projets de développement, administration (MINADER, MINEPIA).

## Conseil
L''agriculture moderne est un **vrai métier d''entrepreneur** : gestion, irrigation, transformation et commercialisation font la différence.

Les conditions exactes (diplômes admis, âge, frais, dates, nombre de places) changent chaque année : vérifie toujours le communiqué officiel du concours.', ARRAY['Ingénieur agronome', 'Technicien agricole', 'Agro-entrepreneur', 'Ingénieur agroalimentaire', 'Ingénieur forestier']::text[], ARRAY['FASA Dschang', 'ENSAI Ngaoundéré', 'Écoles MINADER / MINEPIA', 'BTS/HND agriculture']::text[], ARRAY['agronomie', 'agriculture', 'fasa', 'ensai', 'élevage', 'forêt', 'agro-industrie', 'agrobusiness']::text[], '[{"titre":"Ministère de l''Enseignement Supérieur (MINESUP) — concours, BTS/HND, établissements","url":"https://www.minesup.gov.cm"},{"titre":"Université de Dschang (FASA, IUT Fotso Victor de Bandjoun)"},{"titre":"Université de Ngaoundéré (ENSAI, IUT, EGCIM)"},{"titre":"Ministère de l''Agriculture et du Développement Rural (MINADER)"},{"titre":"Ministère de l''Élevage, des Pêches et des Industries Animales (MINEPIA)"}]'::jsonb),
('ens-enseignement', 'filiere', 'Devenir enseignant : ENS, ENSET, ENIEG / ENIET', 'Enseignement', 'Bac / A Level (ENS 1er cycle), Licence (ENS 2nd cycle), BEPC à Bac (ENIEG/ENIET)', 'Les Écoles Normales Supérieures forment les professeurs du secondaire général (ENS) et technique (ENSET) ; les ENIEG et ENIET forment les instituteurs. Accès sur concours.', '## Les écoles
- **ENS** (Yaoundé, Maroua, Bambili, et d''autres créées récemment) : professeurs de lycées et de collèges, toutes disciplines.
- **ENSET** (Douala, Bambili, Kumba, Ebolowa…) : professeurs de l''**enseignement technique**.
- **ENIEG / ENIET** : **instituteurs** de l''enseignement général et technique, pour le primaire et la maternelle.

## Les cycles
- **Premier cycle** après le Bac ou le A Level : diplôme de professeur des collèges.
- **Second cycle** après la licence : diplôme de professeur des lycées.

## Réalité
L''enseignement est un **grand employeur public**. Les affectations peuvent se faire **partout sur le territoire**.

Les conditions exactes (diplômes admis, âge, frais, dates, nombre de places) changent chaque année : vérifie toujours le communiqué officiel du concours.', ARRAY['Professeur de lycée', 'Professeur de collège', 'Professeur de l''enseignement technique', 'Instituteur', 'Conseiller d''orientation']::text[], ARRAY['ENS Yaoundé', 'ENS Maroua', 'ENSET Douala', 'ENIEG / ENIET']::text[], ARRAY['enseignant', 'professeur', 'ens', 'enset', 'enieg', 'eniet', 'instituteur', 'concours']::text[], '[{"titre":"Ministère de l''Enseignement Supérieur (MINESUP) — concours, BTS/HND, établissements","url":"https://www.minesup.gov.cm"},{"titre":"Université de Yaoundé I (ENSP, ENS, FMSB, Faculté des Sciences)","url":"http://www.uy1.uninet.cm"},{"titre":"Université de Douala (ENSPD, ENSET, IUT, FMSP, ESSEC)"},{"titre":"Université de Maroua (ENSPM, ENS)"},{"titre":"Ministère des Enseignements Secondaires (MINESEC)","url":"https://www.minesec.gov.cm"}]'::jsonb),
('enam-administration', 'filiere', 'ENAM : administration, magistrature et régies financières', 'Administration & diplomatie', 'Cycle B : Baccalauréat ; cycle A : Licence (selon la division)', 'L''École Nationale d''Administration et de Magistrature forme administrateurs civils, magistrats, inspecteurs des impôts, du trésor et des douanes. Concours en ligne sur concours.enam.cm.', '## Les divisions
- **Administration générale** : administrateurs civils.
- **Magistrature** et greffes.
- **Régies financières** : impôts, trésor, douanes.

## Les cycles
- **Cycle A**, accessible avec une licence selon la division.
- **Cycle B**, accessible avec le baccalauréat.

## Le concours
L''inscription se fait **en ligne** sur la plateforme officielle de l''ENAM. On prépare un dossier, notamment avec un casier judiciaire récent. Les épreuves portent sur la culture générale, le droit, l''économie ou les finances selon la division.

## Attention
Méfie-toi des intermédiaires qui promettent des places contre de l''argent : **le recrutement se fait uniquement par concours**.

Les conditions exactes (diplômes admis, âge, frais, dates, nombre de places) changent chaque année : vérifie toujours le communiqué officiel du concours.', ARRAY['Administrateur civil', 'Magistrat', 'Inspecteur des impôts', 'Inspecteur du trésor', 'Inspecteur des douanes']::text[], ARRAY['ENAM (Yaoundé)']::text[], ARRAY['enam', 'administration', 'magistrature', 'impôts', 'douanes', 'trésor', 'fonction publique', 'concours']::text[], '[{"titre":"École Nationale d''Administration et de Magistrature (ENAM)","url":"https://www.enam.cm"},{"titre":"Plateforme des concours de l''ENAM","url":"https://concours.enam.cm"},{"titre":"Ministère des Finances (MINFI) — impôts, douanes, trésor"}]'::jsonb),
('iric-diplomatie', 'filiere', 'Relations internationales et diplomatie (IRIC)', 'Administration & diplomatie', 'Licence (concours d''entrée en master)', 'L''Institut des Relations Internationales du Cameroun (Université de Yaoundé II) forme aux relations internationales, à la diplomatie, au contentieux international et à la communication internationale.', '## Accès
Concours après une **licence**, le plus souvent en droit, science politique, économie, histoire ou langues.

## Débouchés
Diplomatie, via les concours de la fonction publique, organisations internationales et régionales (Union africaine, CEMAC, agences de l''ONU), ONG, entreprises internationales, journalisme international.

## Conseil
Le **bilinguisme parfait** et une **troisième langue** sont de vrais atouts.

Les conditions exactes (diplômes admis, âge, frais, dates, nombre de places) changent chaque année : vérifie toujours le communiqué officiel du concours.', ARRAY['Diplomate', 'Chargé de relations internationales', 'Fonctionnaire international', 'Consultant']::text[], ARRAY['IRIC (Université de Yaoundé II)']::text[], ARRAY['iric', 'diplomatie', 'relations internationales', 'diplomate', 'onu', 'affaires étrangères']::text[], '[{"titre":"Ministère de l''Enseignement Supérieur (MINESUP) — concours, BTS/HND, établissements","url":"https://www.minesup.gov.cm"},{"titre":"Université de Yaoundé II-Soa (Droit, Économie, ESSTIC, IRIC)"}]'::jsonb),
('esstic-journalisme-communication', 'filiere', 'Journalisme et communication (ESSTIC)', 'Communication & arts', 'Baccalauréat ou A Level (concours)', 'L''École Supérieure des Sciences et Techniques de l''Information et de la Communication (Université de Yaoundé II) forme journalistes, communicateurs, publicitaires, éditeurs et documentalistes.', '## Filières
- **Journalisme** : presse écrite, radio, télévision, web.
- **Communication** des organisations, **publicité**.
- **Édition**, **documentation et archives**.

## Débouchés
Médias publics et privés, services de communication des ministères et des entreprises, agences, ONG, communication numérique (community management).

## Conseil
Lance-toi dès maintenant : **blog, radio scolaire, journal du lycée**, pages sur les réseaux sociaux. Un portfolio compte autant que le diplôme.

Les conditions exactes (diplômes admis, âge, frais, dates, nombre de places) changent chaque année : vérifie toujours le communiqué officiel du concours.', ARRAY['Journaliste', 'Chargé de communication', 'Community manager', 'Publicitaire', 'Documentaliste']::text[], ARRAY['ESSTIC (Yaoundé II)', 'Licences de communication', 'BTS/HND communication']::text[], ARRAY['journalisme', 'journaliste', 'communication', 'esstic', 'médias', 'publicité', 'community manager']::text[], '[{"titre":"Ministère de l''Enseignement Supérieur (MINESUP) — concours, BTS/HND, établissements","url":"https://www.minesup.gov.cm"},{"titre":"Université de Yaoundé II-Soa (Droit, Économie, ESSTIC, IRIC)"}]'::jsonb),
('issea-statistique', 'filiere', 'Statistique et économie appliquée (ISSEA)', 'Grandes écoles', 'Bac scientifique (cycles techniciens) ou Licence (cycles ingénieurs), selon le cycle', 'L''ISSEA (Yaoundé), institut de la CEMAC, forme des statisticiens et économistes. Ce sont des profils rares et demandés : INS, banques, assurances, organisations internationales.', '## Formations
Plusieurs cycles, de technicien supérieur de la statistique à ingénieur statisticien-économiste. Le recrutement se fait sur **concours communs** à plusieurs écoles africaines de statistique.

## Débouchés
- **Institut National de la Statistique** et services statistiques des ministères.
- Banques, assurances, télécoms.
- Bureaux d''études, organisations internationales, **science des données**.

## Conseil
Il faut un **excellent niveau en mathématiques** (probabilités, analyse) et de la rigueur.

Les conditions exactes (diplômes admis, âge, frais, dates, nombre de places) changent chaque année : vérifie toujours le communiqué officiel du concours.', ARRAY['Statisticien', 'Économiste', 'Data analyst', 'Actuaire']::text[], ARRAY['ISSEA (Yaoundé)']::text[], ARRAY['issea', 'statistique', 'statisticien', 'économie appliquée', 'data', 'actuariat']::text[], '[{"titre":"Institut Sous-régional de Statistique et d''Économie Appliquée (ISSEA, Yaoundé — CEMAC)"},{"titre":"Institut National de la Statistique (INS) — annuaires et enquêtes","url":"https://ins-cameroun.cm"}]'::jsonb),
('essec-gestion', 'filiere', 'Commerce et gestion (ESSEC Douala et écoles de commerce)', 'Commerce & gestion', 'Baccalauréat ou A Level (concours)', 'L''ESSEC (Université de Douala) et les écoles de commerce forment aux métiers de la gestion, du marketing, de la finance, de la logistique et des ressources humaines.', '## Formations
Gestion des entreprises, comptabilité et finance, marketing et commerce, logistique et transport, ressources humaines.

## Débouchés
- Entreprises de Douala, la **capitale économique**.
- Le port, les banques, les télécoms, la grande distribution.
- La création d''entreprise.

## Alternatives
Les FSEG des universités, les **BTS/HND** en gestion et commerce dans les instituts privés agréés.

Les conditions exactes (diplômes admis, âge, frais, dates, nombre de places) changent chaque année : vérifie toujours le communiqué officiel du concours.', ARRAY['Gestionnaire', 'Responsable marketing', 'Logisticien', 'Contrôleur de gestion', 'Responsable RH']::text[], ARRAY['ESSEC (Université de Douala)', 'FSEG', 'BTS/HND gestion']::text[], ARRAY['essec', 'école de commerce', 'gestion', 'marketing', 'logistique', 'ressources humaines', 'douala']::text[], '[{"titre":"Ministère de l''Enseignement Supérieur (MINESUP) — concours, BTS/HND, établissements","url":"https://www.minesup.gov.cm"},{"titre":"Université de Douala (ENSPD, ENSET, IUT, FMSP, ESSEC)"}]'::jsonb),
('bts-hnd', 'filiere', 'BTS et HND (instituts privés d''enseignement supérieur)', 'Enseignement supérieur', 'Baccalauréat, BT ou GCE A Level', 'Le BTS (francophone) et le HND (anglophone) se préparent en 2 ans dans des instituts privés d''enseignement supérieur (IPES) agréés ; l''examen national est organisé par le MINESUP.', '## Principe
- Formation **professionnelle courte**, en 2 ans.
- Domaines variés : informatique, comptabilité, banque, marketing, logistique, santé, génie civil, électrotechnique, tourisme…
- L''**examen national** de BTS et de HND est organisé chaque année par le **MINESUP**.

## Avant de t''inscrire
- Vérifie que l''institut est **agréé** et que **la filière est autorisée**. Le MINESUP publie des listes et des classements des établissements.
- Renseigne-toi sur les **stages** et le **taux de réussite** à l''examen national.

## Après
Emploi direct, licence professionnelle, ou concours d''admission parallèle dans certaines écoles.', ARRAY['Technicien supérieur', 'Assistant comptable', 'Technicien informatique', 'Agent commercial']::text[], ARRAY['Instituts privés d''enseignement supérieur (IPES) agréés']::text[], ARRAY['bts', 'hnd', 'higher national diploma', 'institut privé', 'ipes', 'deux ans', 'minesup']::text[], '[{"titre":"Ministère de l''Enseignement Supérieur (MINESUP) — concours, BTS/HND, établissements","url":"https://www.minesup.gov.cm"}]'::jsonb),
('formation-professionnelle', 'filiere', 'Formation professionnelle (centres agréés, SAR/SM, apprentissage)', 'Formation professionnelle', 'Tous niveaux (souvent dès le CEP ou le BEPC)', 'Les centres de formation professionnelle publics et privés agréés (tutelle MINEFOP) forment rapidement aux métiers : couture, coiffure, menuiserie, mécanique, électricité, froid, maçonnerie, informatique, hôtellerie…', '## Pour qui ?
Pour les jeunes qui veulent **apprendre un métier rapidement**, après le CEP, le BEPC ou le Probatoire, ou qui veulent **se reconvertir**.

## Les structures
- **Centres de formation professionnelle** publics et privés **agréés**.
- **Sections artisanales rurales et sections ménagères (SAR/SM)**.
- **Apprentissage** chez un artisan ou en entreprise.

## Réalité
Beaucoup de jeunes Camerounais vivent d''un **métier technique** et de l''**auto-emploi**. Une bonne qualification permet de se lancer avec peu de moyens, puis de grandir.

## Conseil
Choisis un centre **agréé par le MINEFOP**. Renseigne-toi sur les **bourses de formation** et sur l''accompagnement du **FNE** pour l''emploi et le financement de projets.', ARRAY['Couturier', 'Coiffeur', 'Menuisier', 'Électricien', 'Mécanicien', 'Cuisinier']::text[], ARRAY['Centres de formation professionnelle agréés', 'SAR/SM', 'Apprentissage']::text[], ARRAY['formation professionnelle', 'métier', 'centre de formation', 'minefop', 'apprentissage', 'sar sm', 'auto-emploi']::text[], '[{"titre":"Ministère de l''Emploi et de la Formation Professionnelle (MINEFOP) — centres de formation agréés, bourses"},{"titre":"Fonds National de l''Emploi (FNE) — accompagnement vers l''emploi et l''auto-emploi"}]'::jsonb),
('defense-securite', 'filiere', 'Défense et sécurité (EMIA, armée, police, gendarmerie)', 'Défense & sécurité', 'Selon le corps : BEPC, Probatoire, Baccalauréat ou Licence', 'L''École Militaire Interarmées (EMIA) forme les officiers ; les recrutements de soldats, sous-officiers, gendarmes et policiers se font par concours annuels du MINDEF et de la DGSN.', '## Les voies
- **EMIA** (Yaoundé) : officiers des armées, sur concours après le Bac ou la licence.
- **Armée et gendarmerie** : recrutements de militaires du rang et de sous-officiers.
- **Police** (DGSN) : concours de gardien de la paix, d''inspecteur, d''officier, de commissaire, selon le diplôme.
- **Sapeurs-pompiers**.

## Ce qu''on attend de toi
Aptitude physique et médicale, discipline, casier judiciaire vierge, limites d''âge.

## Attention
Les **arnaques aux faux recrutements** sont fréquentes : les inscriptions et les résultats sont publiés par les **communiqués officiels** du MINDEF et de la DGSN. On ne paie **jamais** un intermédiaire.

Les conditions exactes (diplômes admis, âge, frais, dates, nombre de places) changent chaque année : vérifie toujours le communiqué officiel du concours.', ARRAY['Officier', 'Sous-officier', 'Gendarme', 'Policier', 'Sapeur-pompier']::text[], ARRAY['EMIA', 'Écoles de la gendarmerie et de l''armée', 'École Nationale Supérieure de Police']::text[], ARRAY['armée', 'emia', 'militaire', 'police', 'gendarmerie', 'dgsn', 'mindef', 'sapeur-pompier']::text[], '[{"titre":"Ministère de la Défense (MINDEF) — EMIA et recrutements des forces de défense"},{"titre":"Délégation Générale à la Sûreté Nationale (DGSN) — concours de la police"}]'::jsonb),
('beaux-arts-culture', 'filiere', 'Arts, culture, design et métiers créatifs', 'Communication & arts', 'Selon la formation (souvent Baccalauréat)', 'Beaux-arts, architecture, design, audiovisuel, musique : l''Institut des Beaux-Arts de Foumban (Université de Dschang), les filières d''arts des universités, des écoles privées et l''apprentissage auprès de professionnels.', '## Formations
- **Institut des Beaux-Arts de Foumban** (Université de Dschang) : arts plastiques, architecture et arts du patrimoine, cinéma et audiovisuel, musique.
- Filières **arts du spectacle** et **cinéma** de certaines universités.
- Écoles privées de **design graphique**, de **mode** et d''**audiovisuel**.

## Réalité
Les métiers créatifs demandent un **portfolio** et un **réseau**. Beaucoup combinent leur art avec le **numérique** : graphisme, vidéo, réseaux sociaux.

## Conseil
Crée et publie régulièrement, participe aux **festivals et concours**, et apprends à **vendre ton travail**.', ARRAY['Graphiste', 'Architecte', 'Réalisateur', 'Musicien', 'Styliste', 'Artiste plasticien']::text[], ARRAY['Institut des Beaux-Arts de Foumban', 'Filières arts des universités', 'Écoles privées']::text[], ARRAY['arts', 'beaux-arts', 'foumban', 'design', 'musique', 'cinéma', 'audiovisuel', 'mode', 'architecture']::text[], '[{"titre":"Ministère de l''Enseignement Supérieur (MINESUP) — concours, BTS/HND, établissements","url":"https://www.minesup.gov.cm"},{"titre":"Université de Dschang (FASA, IUT Fotso Victor de Bandjoun)"}]'::jsonb),
('traduction-interpretation', 'filiere', 'Traduction et interprétation (ASTI Buea)', 'Communication & arts', 'Licence (concours d''entrée)', 'Le Cameroun, pays bilingue, a besoin de traducteurs et d''interprètes. L''Advanced School of Translators and Interpreters (ASTI, University of Buea) en forme sur concours après la licence.', '## Accès
Concours après une **licence**, avec un excellent niveau en **anglais et en français**, et souvent une autre langue.

## Débouchés
Services de traduction de l''administration, organisations internationales, entreprises, médias, traducteur et interprète indépendant, enseignement des langues.

## Conseil
Lis et écris **chaque jour dans les deux langues officielles**. Une troisième langue, comme l''espagnol, l''allemand, le chinois ou l''arabe, multiplie tes chances.', ARRAY['Traducteur', 'Interprète de conférence', 'Rédacteur bilingue', 'Enseignant de langues']::text[], ARRAY['ASTI (University of Buea)', 'Facultés de lettres (langues)']::text[], ARRAY['traduction', 'traducteur', 'interprète', 'asti', 'bilinguisme', 'langues', 'buea']::text[], '[{"titre":"Ministère de l''Enseignement Supérieur (MINESUP) — concours, BTS/HND, établissements","url":"https://www.minesup.gov.cm"},{"titre":"University of Buea (Faculty of Health Sciences, COT, faculties)"}]'::jsonb),
('metier-medecin', 'metier', 'Médecin', 'Santé', 'Bac C ou D / A Level sciences + concours de médecine', 'Diagnostique et soigne les patients, en hôpital public, en clinique privée, en mission humanitaire ou en zone rurale.', '## Le métier
- Examiner les patients, poser un diagnostic, prescrire des traitements
- Prévenir les maladies (vaccination, paludisme, santé maternelle)
- Se spécialiser éventuellement (chirurgie, pédiatrie, gynécologie…)

## Comment y arriver au Cameroun
- Bac C ou D, ou A Level biology, chemistry, physics
- Concours d''entrée en faculté de médecine (FMSB, FMSP Douala, FHS Buea…)
- Environ 7 ans d''études jusqu''au doctorat en médecine, puis spécialisation éventuelle

## Qualités utiles
- Excellent niveau en SVT et chimie
- Résistance au stress et à la fatigue
- Empathie et sens de l''écoute

## La réalité du terrain
Les besoins sont importants, surtout dans les régions éloignées des grandes villes. Les débuts se font souvent dans les hôpitaux publics de district.

## Conseil Mandal
Prépare le concours avec les annales dès la Terminale et garde un plan B (paramédical, biologie) pour ne pas perdre d''année.', ARRAY[]::text[], ARRAY['FMSB', 'FMSP Douala', 'FHS Buea']::text[], ARRAY['médecin', 'médecine', 'docteur', 'hôpital', 'santé']::text[], '[{"titre":"Ministère de l''Enseignement Supérieur (MINESUP) — concours, BTS/HND, établissements","url":"https://www.minesup.gov.cm"},{"titre":"Université de Yaoundé I (ENSP, ENS, FMSB, Faculté des Sciences)","url":"http://www.uy1.uninet.cm"},{"titre":"Ministère de la Santé Publique (MINSANTE) — écoles de formation paramédicale"}]'::jsonb),
('metier-infirmier', 'metier', 'Infirmier / Infirmière', 'Santé', 'Probatoire ou Baccalauréat / GCE + concours ou BTS/HND santé', 'Dispense les soins, surveille les patients et accompagne les médecins à l''hôpital, en centre de santé ou en entreprise.', '## Le métier
- Réaliser les soins (pansements, injections, perfusions)
- Surveiller l''état des patients et alerter
- Éduquer à la santé (hygiène, paludisme, nutrition)

## Comment y arriver au Cameroun
- Concours des écoles publiques de formation paramédicale (MINSANTE, universités)
- Ou BTS/HND santé dans un institut privé agréé
- Environ 3 ans de formation selon le diplôme

## Qualités utiles
- Rigueur et propreté
- Calme en situation d''urgence
- Bienveillance

## La réalité du terrain
Métier très demandé dans les hôpitaux publics, les cliniques privées et les ONG. Le travail de nuit et le week-end fait partie du métier.

## Conseil Mandal
Vérifie absolument que ton école est agréée : un diplôme non reconnu ne permet ni concours ni emploi public.', ARRAY[]::text[], ARRAY['Écoles paramédicales MINSANTE', 'BTS/HND santé']::text[], ARRAY['infirmier / infirmière', 'infirmière', 'soins', 'paramédical']::text[], '[{"titre":"Ministère de la Santé Publique (MINSANTE) — écoles de formation paramédicale"},{"titre":"Ministère de l''Enseignement Supérieur (MINESUP) — concours, BTS/HND, établissements","url":"https://www.minesup.gov.cm"}]'::jsonb),
('metier-sage-femme', 'metier', 'Sage-femme / Maïeuticien', 'Santé', 'Baccalauréat ou GCE A Level + concours', 'Suit les grossesses, réalise les accouchements et accompagne la mère et le nouveau-né.', '## Le métier
- Consultations prénatales
- Accouchements et soins au nouveau-né
- Planning familial et santé de la reproduction

## Comment y arriver au Cameroun
- Concours des écoles de sages-femmes publiques ou filières universitaires
- Ou formation dans un institut privé agréé

## Qualités utiles
- Sang-froid
- Sens des responsabilités
- Écoute

## La réalité du terrain
Profession essentielle pour réduire la mortalité maternelle ; les besoins sont forts dans les districts de santé ruraux.

## Conseil Mandal
Les stages en maternité sont décisifs : sois présent(e) et curieux(se).', ARRAY[]::text[], ARRAY['Écoles de sages-femmes', 'Filières santé des universités']::text[], ARRAY['sage-femme / maïeuticien', 'sage femme', 'accouchement', 'maternité', 'maïeutique']::text[], '[{"titre":"Ministère de la Santé Publique (MINSANTE) — écoles de formation paramédicale"},{"titre":"Ministère de l''Enseignement Supérieur (MINESUP) — concours, BTS/HND, établissements","url":"https://www.minesup.gov.cm"}]'::jsonb),
('metier-pharmacien', 'metier', 'Pharmacien', 'Santé', 'Bac C ou D / A Level sciences + concours', 'Délivre et conseille sur les médicaments, en officine, à l''hôpital, en laboratoire ou dans l''industrie.', '## Le métier
- Vérifier les ordonnances et conseiller les patients
- Gérer les stocks de médicaments
- Lutter contre les médicaments de rue et la contrefaçon

## Comment y arriver au Cameroun
- Concours d''entrée en pharmacie (facultés de médecine et sciences pharmaceutiques)
- Plusieurs années d''études jusqu''au doctorat en pharmacie

## Qualités utiles
- Rigueur scientifique
- Sens du conseil
- Éthique

## La réalité du terrain
L''officine demande un investissement important ; beaucoup commencent comme pharmaciens assistants, à l''hôpital ou chez les distributeurs.

## Conseil Mandal
Excellente chimie et biologie indispensables ; informe-toi aussi sur la pharmacie hospitalière et l''industrie.', ARRAY[]::text[], ARRAY['FMSB', 'FMSP Douala']::text[], ARRAY['pharmacien', 'pharmacie', 'médicaments', 'officine']::text[], '[{"titre":"Ministère de l''Enseignement Supérieur (MINESUP) — concours, BTS/HND, établissements","url":"https://www.minesup.gov.cm"},{"titre":"Ministère de la Santé Publique (MINSANTE) — écoles de formation paramédicale"}]'::jsonb),
('metier-technicien-laboratoire', 'metier', 'Technicien de laboratoire d''analyses médicales', 'Santé', 'Baccalauréat (D, C, F7) / A Level + formation paramédicale ou BTS/HND', 'Réalise les analyses de sang, d''urine et de prélèvements qui permettent aux médecins de poser un diagnostic.', '## Le métier
- Prélèvements et analyses (paludisme, VIH, glycémie…)
- Entretien des appareils
- Respect strict des règles d''hygiène et de qualité

## Comment y arriver au Cameroun
- Écoles paramédicales publiques sur concours
- BTS/HND en biologie médicale dans un institut agréé
- Licence en biologie / sciences biomédicales

## Qualités utiles
- Précision
- Minutie
- Respect des protocoles

## La réalité du terrain
Postes dans les hôpitaux, laboratoires privés, centres de santé et programmes de santé publique.

## Conseil Mandal
Les séries D et F7 préparent bien à ce métier.', ARRAY[]::text[], ARRAY['Écoles paramédicales', 'BTS/HND biologie médicale']::text[], ARRAY['technicien de laboratoire d''analyses médicales', 'laborantin', 'analyses', 'biologie médicale']::text[], '[{"titre":"Ministère de la Santé Publique (MINSANTE) — écoles de formation paramédicale"},{"titre":"Ministère de l''Enseignement Supérieur (MINESUP) — concours, BTS/HND, établissements","url":"https://www.minesup.gov.cm"}]'::jsonb),
('metier-veterinaire', 'metier', 'Vétérinaire / Technicien d''élevage', 'Agriculture & environnement', 'Bac C ou D / A Level sciences', 'Soigne les animaux, protège les élevages et veille à la sécurité sanitaire des aliments d''origine animale.', '## Le métier
- Soins et vaccination des animaux
- Conseil aux éleveurs (bovins, volaille, porcs, poissons)
- Contrôle sanitaire des viandes et produits animaux

## Comment y arriver au Cameroun
- Études vétérinaires (École des sciences et médecine vétérinaire, Université de Ngaoundéré) sur concours
- Formations de techniciens d''élevage (centres MINEPIA, BTS/HND)

## Qualités utiles
- Amour des animaux
- Endurance
- Sens de l''observation

## La réalité du terrain
L''élevage (Adamaoua, Nord, Ouest) et l''aviculture sont des secteurs importants ; beaucoup s''installent à leur compte.

## Conseil Mandal
Associe compétences vétérinaires et gestion pour créer ton propre élevage ou cabinet.', ARRAY[]::text[], ARRAY['Université de Ngaoundéré', 'Centres MINEPIA']::text[], ARRAY['vétérinaire / technicien d''élevage', 'animaux', 'élevage', 'volaille', 'bétail']::text[], '[{"titre":"Ministère de l''Élevage, des Pêches et des Industries Animales (MINEPIA)"},{"titre":"Université de Ngaoundéré (ENSAI, IUT, EGCIM)"},{"titre":"Ministère de l''Enseignement Supérieur (MINESUP) — concours, BTS/HND, établissements","url":"https://www.minesup.gov.cm"}]'::jsonb),
('metier-ingenieur-genie-civil', 'metier', 'Ingénieur en génie civil', 'BTP & construction', 'Bac C, E ou F4 / A Level sciences + école d''ingénieurs', 'Conçoit, calcule et dirige la construction de bâtiments, routes, ponts, barrages et réseaux.', '## Le métier
- Concevoir et dimensionner les ouvrages
- Diriger les chantiers et contrôler la qualité
- Gérer budgets, délais et équipes

## Comment y arriver au Cameroun
- Concours d''entrée dans une école d''ingénieurs (ENSP Yaoundé, ENSPD Douala, ENSTP…)
- Environ 5 ans d''études
- Ou IUT/BTS génie civil puis admission parallèle

## Qualités utiles
- Solide en maths et mécanique
- Leadership sur le chantier
- Sens des responsabilités (sécurité)

## La réalité du terrain
Grands projets d''infrastructures (routes, ports, barrages, logements) : le secteur recrute, avec des missions parfois loin des grandes villes.

## Conseil Mandal
Apprends tôt un logiciel de dessin et de calcul de structures, et fais des stages sur de vrais chantiers.', ARRAY[]::text[], ARRAY['ENSP Yaoundé', 'ENSPD Douala', 'ENSTP']::text[], ARRAY['ingénieur en génie civil', 'btp', 'bâtiment', 'travaux publics', 'routes', 'ponts', 'construction']::text[], '[{"titre":"Ministère de l''Enseignement Supérieur (MINESUP) — concours, BTS/HND, établissements","url":"https://www.minesup.gov.cm"},{"titre":"Université de Yaoundé I (ENSP, ENS, FMSB, Faculté des Sciences)","url":"http://www.uy1.uninet.cm"},{"titre":"Ministère des Travaux Publics (MINTP) — ENSTP"}]'::jsonb),
('metier-technicien-btp', 'metier', 'Technicien en bâtiment et travaux publics / Chef de chantier', 'BTP & construction', 'CAP, BT ou Bac F4 / BTS-HND génie civil', 'Organise et suit les travaux sur le chantier : implantation, coffrage, béton, maçonnerie, voirie.', '## Le métier
- Lire les plans et implanter l''ouvrage
- Encadrer les ouvriers et contrôler l''avancement
- Commander et gérer les matériaux

## Comment y arriver au Cameroun
- Lycée technique (F4 bâtiment ou travaux publics)
- IUT ou BTS/HND génie civil
- Expérience de chantier

## Qualités utiles
- Sens pratique
- Autorité
- Rigueur sur la sécurité

## La réalité du terrain
Beaucoup de travail dans la construction privée et publique ; possibilité de devenir entrepreneur du bâtiment.

## Conseil Mandal
Maîtrise les métrés et les devis : c''est la base pour devenir un jour chef d''entreprise.', ARRAY[]::text[], ARRAY['Lycées techniques', 'IUT', 'BTS/HND']::text[], ARRAY['technicien en bâtiment et travaux publics / chef de chantier', 'chantier', 'bâtiment', 'maçonnerie', 'f4', 'génie civil']::text[], '[{"titre":"Office du Baccalauréat du Cameroun (OBC) — Probatoire, Baccalauréat, BT","url":"https://www.obc.cm"},{"titre":"Ministère de l''Enseignement Supérieur (MINESUP) — concours, BTS/HND, établissements","url":"https://www.minesup.gov.cm"},{"titre":"Ministère de l''Emploi et de la Formation Professionnelle (MINEFOP) — centres de formation agréés, bourses"}]'::jsonb),
('metier-architecte', 'metier', 'Architecte', 'BTP & construction', 'Baccalauréat (C, D, E ou F4) + école d''architecture', 'Conçoit des bâtiments beaux, solides et adaptés au climat et à la culture, du plan au suivi du chantier.', '## Le métier
- Concevoir les plans et les maquettes
- Respecter les règles d''urbanisme
- Suivre la construction

## Comment y arriver au Cameroun
- Écoles d''architecture (ex. filière architecture de l''Institut des Beaux-Arts de Foumban, écoles spécialisées)
- Plusieurs années d''études puis inscription à l''ordre professionnel

## Qualités utiles
- Créativité
- Sens de l''espace
- Bon niveau en dessin et en maths

## La réalité du terrain
Clients privés, promoteurs, collectivités ; l''architecture adaptée au climat tropical et aux matériaux locaux est un vrai atout.

## Conseil Mandal
Dessine beaucoup et apprends un logiciel de modélisation 3D.', ARRAY[]::text[], ARRAY['Institut des Beaux-Arts de Foumban', 'Écoles d''architecture']::text[], ARRAY['architecte', 'architecture', 'plans', 'urbanisme', 'design']::text[], '[{"titre":"Ministère de l''Enseignement Supérieur (MINESUP) — concours, BTS/HND, établissements","url":"https://www.minesup.gov.cm"},{"titre":"Université de Dschang (FASA, IUT Fotso Victor de Bandjoun)"}]'::jsonb),
('metier-geometre', 'metier', 'Géomètre-topographe', 'BTP & construction', 'Bac C, E ou F4 + formation spécialisée', 'Mesure les terrains, délimite les parcelles et fournit les plans indispensables aux constructions et au foncier.', '## Le métier
- Relevés topographiques (GPS, station totale)
- Bornage et plans de parcelles
- Implantation des ouvrages

## Comment y arriver au Cameroun
- ENSTP ou filières de topographie et de géomatique
- BTS/HND topographie

## Qualités utiles
- Précision
- Goût du terrain
- Maîtrise des outils numériques

## La réalité du terrain
Le foncier et la construction en font un métier recherché ; le titre de géomètre-expert est réglementé.

## Conseil Mandal
Apprends les logiciels de SIG (systèmes d''information géographique).', ARRAY[]::text[], ARRAY['ENSTP', 'BTS/HND topographie']::text[], ARRAY['géomètre-topographe', 'topographie', 'foncier', 'cadastre', 'bornage', 'sig']::text[], '[{"titre":"Ministère des Travaux Publics (MINTP) — ENSTP"},{"titre":"Ministère de l''Enseignement Supérieur (MINESUP) — concours, BTS/HND, établissements","url":"https://www.minesup.gov.cm"}]'::jsonb),
('metier-electricien', 'metier', 'Électricien (bâtiment et industrie)', 'Industrie & énergie', 'CAP, BT ou Bac F3 / formation professionnelle', 'Installe et dépanne les installations électriques des maisons, bureaux et usines, y compris le solaire.', '## Le métier
- Installer câblage, tableaux, prises et éclairage
- Dépanner et mettre en sécurité
- Installer des kits solaires

## Comment y arriver au Cameroun
- Lycée technique (F3 électrotechnique)
- Centres de formation professionnelle agréés
- BTS/HND électrotechnique

## Qualités utiles
- Rigueur et respect de la sécurité
- Logique
- Habileté manuelle

## La réalité du terrain
Très demandé, avec beaucoup d''auto-emploi ; l''énergie solaire ouvre un marché en forte croissance.

## Conseil Mandal
Ajoute le solaire photovoltaïque à tes compétences et soigne ta réputation : le bouche-à-oreille fait le chiffre d''affaires.', ARRAY[]::text[], ARRAY['Lycées techniques (F3)', 'Centres MINEFOP', 'BTS/HND']::text[], ARRAY['électricien (bâtiment et industrie)', 'électricité', 'électrotechnique', 'f3', 'solaire', 'installation']::text[], '[{"titre":"Office du Baccalauréat du Cameroun (OBC) — Probatoire, Baccalauréat, BT","url":"https://www.obc.cm"},{"titre":"Ministère de l''Emploi et de la Formation Professionnelle (MINEFOP) — centres de formation agréés, bourses"}]'::jsonb),
('metier-technicien-energie-solaire', 'metier', 'Technicien en énergies renouvelables (solaire)', 'Industrie & énergie', 'CAP/BT électricité, BTS/HND ou Licence professionnelle', 'Dimensionne, installe et entretient des installations solaires pour les ménages, les écoles, les centres de santé et les entreprises.', '## Le métier
- Dimensionner panneaux, batteries et onduleurs
- Installer et mettre en service
- Assurer la maintenance

## Comment y arriver au Cameroun
- Électrotechnique au lycée technique
- Formations spécialisées en énergies renouvelables (BTS/HND, licences professionnelles)

## Qualités utiles
- Bases solides en électricité
- Autonomie
- Sens du service client

## La réalité du terrain
Les coupures d''électricité et les zones non raccordées créent une forte demande, en ville comme au village.

## Conseil Mandal
Commence par de petites installations bien faites et garanties ; ta réputation sera ton meilleur argument.', ARRAY[]::text[], ARRAY['BTS/HND énergies renouvelables', 'Licences professionnelles']::text[], ARRAY['technicien en énergies renouvelables (solaire)', 'énergie', 'solaire', 'photovoltaïque', 'renouvelable']::text[], '[{"titre":"Ministère de l''Enseignement Supérieur (MINESUP) — concours, BTS/HND, établissements","url":"https://www.minesup.gov.cm"},{"titre":"Ministère de l''Emploi et de la Formation Professionnelle (MINEFOP) — centres de formation agréés, bourses"}]'::jsonb),
('metier-mecanicien-auto', 'metier', 'Mécanicien automobile / Technicien de maintenance', 'Industrie & énergie', 'CAP, BT ou formation professionnelle', 'Diagnostique et répare les véhicules (voitures, motos, engins) et les machines.', '## Le métier
- Diagnostic des pannes
- Réparation et entretien
- Électronique automobile (diagnostic par ordinateur)

## Comment y arriver au Cameroun
- Lycée technique (mécanique automobile)
- Centres de formation professionnelle
- Apprentissage dans un garage sérieux

## Qualités utiles
- Curiosité technique
- Patience
- Honnêteté avec les clients

## La réalité du terrain
Le parc de véhicules, de motos et d''engins assure du travail ; l''électronique embarquée change le métier.

## Conseil Mandal
Forme-toi au diagnostic électronique : les garages modernes en manquent.', ARRAY[]::text[], ARRAY['Lycées techniques', 'Centres MINEFOP']::text[], ARRAY['mécanicien automobile / technicien de maintenance', 'mécanique', 'garage', 'automobile', 'moto', 'maintenance']::text[], '[{"titre":"Ministère de l''Emploi et de la Formation Professionnelle (MINEFOP) — centres de formation agréés, bourses"},{"titre":"Office du Baccalauréat du Cameroun (OBC) — Probatoire, Baccalauréat, BT","url":"https://www.obc.cm"}]'::jsonb),
('metier-frigoriste', 'metier', 'Frigoriste / Technicien froid et climatisation', 'Industrie & énergie', 'CAP, BT ou Bac F5 / BTS', 'Installe et répare réfrigérateurs, chambres froides et climatiseurs.', '## Le métier
- Installation de climatiseurs et chambres froides
- Dépannage et recharge en fluide
- Entretien préventif

## Comment y arriver au Cameroun
- Lycée technique (F5 froid et climatisation)
- Centres de formation professionnelle
- BTS/HND

## Qualités utiles
- Habileté technique
- Rigueur
- Sens du service

## La réalité du terrain
Hôtels, supermarchés, hôpitaux, pêche et agroalimentaire ont besoin du froid : forte demande sous le climat camerounais.

## Conseil Mandal
Les chambres froides pour l''agroalimentaire et la pêche sont un marché porteur.', ARRAY[]::text[], ARRAY['Lycées techniques (F5)', 'Centres MINEFOP']::text[], ARRAY['frigoriste / technicien froid et climatisation', 'froid', 'climatisation', 'f5', 'réfrigération']::text[], '[{"titre":"Office du Baccalauréat du Cameroun (OBC) — Probatoire, Baccalauréat, BT","url":"https://www.obc.cm"},{"titre":"Ministère de l''Emploi et de la Formation Professionnelle (MINEFOP) — centres de formation agréés, bourses"}]'::jsonb),
('metier-geologue', 'metier', 'Géologue / Ingénieur des mines', 'Industrie & énergie', 'Bac C ou D + Licence/Master en géosciences ou école d''ingénieurs des mines', 'Étudie le sous-sol pour trouver et exploiter durablement les ressources (minerais, eau, pétrole) et prévenir les risques naturels.', '## Le métier
- Prospection minière et hydrogéologique
- Études de sols pour la construction
- Suivi environnemental des exploitations

## Comment y arriver au Cameroun
- Licence et master en sciences de la Terre (facultés des sciences)
- Écoles d''ingénieurs des mines et de la géologie

## Qualités utiles
- Goût du terrain
- Esprit scientifique
- Endurance

## La réalité du terrain
Le Cameroun a un potentiel minier (fer, bauxite, or, cobalt) et pétrolier ; l''eau souterraine est aussi un enjeu majeur.

## Conseil Mandal
Associe géologie et outils numériques (SIG, télédétection).', ARRAY[]::text[], ARRAY['Facultés des sciences (géologie)', 'Écoles des mines']::text[], ARRAY['géologue / ingénieur des mines', 'géologie', 'mines', 'pétrole', 'forage', 'hydrogéologie']::text[], '[{"titre":"Ministère de l''Enseignement Supérieur (MINESUP) — concours, BTS/HND, établissements","url":"https://www.minesup.gov.cm"},{"titre":"Université de Yaoundé I (ENSP, ENS, FMSB, Faculté des Sciences)","url":"http://www.uy1.uninet.cm"}]'::jsonb),
('metier-developpeur', 'metier', 'Développeur / Ingénieur logiciel', 'Numérique', 'Bac TI, C ou E + BTS/HND, Licence ou école d''ingénieurs', 'Conçoit et programme des applications web et mobiles, des logiciels de gestion et des plateformes numériques.', '## Le métier
- Analyser les besoins
- Programmer, tester, corriger
- Mettre en ligne et maintenir les applications

## Comment y arriver au Cameroun
- Licence d''informatique, IUT, BTS/HND en génie logiciel
- Écoles d''ingénieurs (génie informatique)
- Apprentissage par projets

## Qualités utiles
- Logique
- Persévérance
- Curiosité et autoformation

## La réalité du terrain
Start-ups (Yaoundé, Douala, Buea), banques, télécoms et freelance pour l''étranger : le portfolio de projets compte autant que le diplôme.

## Conseil Mandal
Construis des projets concrets (paiement mobile, gestion d''école, commerce en ligne) et publie ton code.', ARRAY[]::text[], ARRAY['Facultés des sciences', 'IUT', 'ENSP (génie informatique)', 'BTS/HND']::text[], ARRAY['développeur / ingénieur logiciel', 'informatique', 'programmation', 'développeur', 'web', 'mobile', 'application', 'code']::text[], '[{"titre":"Ministère de l''Enseignement Supérieur (MINESUP) — concours, BTS/HND, établissements","url":"https://www.minesup.gov.cm"},{"titre":"Ministère des Postes et Télécommunications (MINPOSTEL)"}]'::jsonb),
('metier-reseaux-telecoms', 'metier', 'Technicien / Ingénieur réseaux et télécommunications', 'Numérique', 'Bac TI, C, E ou F2 + BTS/HND, IUT ou école d''ingénieurs', 'Installe et sécurise les réseaux informatiques, la fibre, la téléphonie mobile et Internet.', '## Le métier
- Installer et configurer les réseaux
- Surveiller et dépanner
- Assurer la cybersécurité

## Comment y arriver au Cameroun
- IUT ou BTS/HND réseaux et télécoms
- Écoles d''ingénieurs (télécommunications)
- Certifications professionnelles

## Qualités utiles
- Méthode
- Logique
- Disponibilité pour les urgences

## La réalité du terrain
Opérateurs télécoms, fournisseurs d''accès, banques, administrations : la cybersécurité est en forte demande.

## Conseil Mandal
Les certifications reconnues (réseaux, sécurité) font la différence à l''embauche.', ARRAY[]::text[], ARRAY['IUT', 'ENSP', 'BTS/HND']::text[], ARRAY['technicien / ingénieur réseaux et télécommunications', 'réseaux', 'télécoms', 'fibre', 'cybersécurité', 'internet']::text[], '[{"titre":"Ministère de l''Enseignement Supérieur (MINESUP) — concours, BTS/HND, établissements","url":"https://www.minesup.gov.cm"},{"titre":"Ministère des Postes et Télécommunications (MINPOSTEL)"}]'::jsonb),
('metier-data-analyst', 'metier', 'Analyste de données / Statisticien', 'Numérique', 'Bac C ou TI + Licence/Master ou ISSEA', 'Transforme les données en informations utiles pour décider : enquêtes, tableaux de bord, prévisions.', '## Le métier
- Collecter et nettoyer les données
- Analyser et modéliser
- Présenter les résultats

## Comment y arriver au Cameroun
- ISSEA (statistique)
- Masters en mathématiques appliquées, informatique, économie
- Formations en science des données

## Qualités utiles
- Excellent niveau en maths
- Rigueur
- Esprit de synthèse

## La réalité du terrain
INS, banques, télécoms, ONG et projets de développement recherchent ces profils encore rares.

## Conseil Mandal
Apprends un outil d''analyse de données (tableur avancé puis un langage de programmation) en plus des statistiques.', ARRAY[]::text[], ARRAY['ISSEA', 'Facultés des sciences']::text[], ARRAY['analyste de données / statisticien', 'données', 'data', 'statistique', 'analyse', 'excel', 'python']::text[], '[{"titre":"Institut Sous-régional de Statistique et d''Économie Appliquée (ISSEA, Yaoundé — CEMAC)"},{"titre":"Institut National de la Statistique (INS) — annuaires et enquêtes","url":"https://ins-cameroun.cm"}]'::jsonb),
('metier-enseignant-secondaire', 'metier', 'Professeur de collège ou de lycée', 'Enseignement', 'Bac (ENS 1er cycle) ou Licence (ENS 2nd cycle)', 'Enseigne une discipline aux élèves du secondaire et les accompagne vers les examens officiels.', '## Le métier
- Préparer et donner les cours
- Évaluer et corriger
- Accompagner et orienter les élèves

## Comment y arriver au Cameroun
- Concours de l''ENS (enseignement général) ou de l''ENSET (enseignement technique)
- Recrutement public après la formation, ou enseignement privé

## Qualités utiles
- Maîtrise de la discipline
- Patience et pédagogie
- Autorité bienveillante

## La réalité du terrain
Grand employeur public ; les affectations peuvent se faire dans toutes les régions, et les effectifs de classe sont souvent élevés.

## Conseil Mandal
Commence par donner des cours de répétition : tu sauras vite si la transmission te plaît.', ARRAY[]::text[], ARRAY['ENS', 'ENSET']::text[], ARRAY['professeur de collège ou de lycée', 'professeur', 'enseignant', 'ens', 'enseignement']::text[], '[{"titre":"Ministère de l''Enseignement Supérieur (MINESUP) — concours, BTS/HND, établissements","url":"https://www.minesup.gov.cm"},{"titre":"Ministère des Enseignements Secondaires (MINESEC)","url":"https://www.minesec.gov.cm"}]'::jsonb),
('metier-instituteur', 'metier', 'Instituteur / Institutrice', 'Enseignement', 'BEPC, Probatoire ou Baccalauréat + ENIEG / ENIET', 'Enseigne à l''école maternelle et primaire : lecture, écriture, calcul et éveil des enfants.', '## Le métier
- Apprendre à lire, écrire, compter
- Éduquer et éveiller
- Suivre chaque enfant et dialoguer avec les parents

## Comment y arriver au Cameroun
- Concours d''entrée dans les Écoles Normales d''Instituteurs (ENIEG / ENIET)

## Qualités utiles
- Patience
- Créativité
- Amour des enfants

## La réalité du terrain
Les besoins sont importants, surtout dans les zones rurales ; l''enseignement privé recrute aussi.

## Conseil Mandal
L''animation de groupes d''enfants (catéchisme, colonies, soutien scolaire) est une excellente préparation.', ARRAY[]::text[], ARRAY['ENIEG', 'ENIET']::text[], ARRAY['instituteur / institutrice', 'instituteur', 'maîtresse', 'école primaire', 'maternelle', 'enieg']::text[], '[{"titre":"Ministère des Enseignements Secondaires (MINESEC)","url":"https://www.minesec.gov.cm"}]'::jsonb),
('metier-conseiller-orientation', 'metier', 'Conseiller d''orientation / Psychologue', 'Social & humain', 'Licence/Master en psychologie ou sciences de l''éducation + formation', 'Aide les élèves à se connaître, à choisir leur filière et à construire leur projet ; accompagne en cas de difficultés.', '## Le métier
- Entretiens individuels et tests d''intérêts
- Information sur les filières et métiers
- Accompagnement psychologique

## Comment y arriver au Cameroun
- Licence puis master en psychologie ou sciences de l''éducation
- Concours de conseiller d''orientation (ENS) pour le public

## Qualités utiles
- Écoute
- Discrétion
- Connaissance du système éducatif

## La réalité du terrain
Présents dans les établissements secondaires, les universités, les ONG et le secteur privé (RH).

## Conseil Mandal
Va voir le conseiller d''orientation de ton établissement : c''est gratuit et utile.', ARRAY[]::text[], ARRAY['Facultés de lettres et sciences humaines', 'ENS']::text[], ARRAY['conseiller d''orientation / psychologue', 'orientation', 'psychologue', 'conseil', 'psychologie']::text[], '[{"titre":"Ministère des Enseignements Secondaires (MINESEC)","url":"https://www.minesec.gov.cm"},{"titre":"Ministère de l''Enseignement Supérieur (MINESUP) — concours, BTS/HND, établissements","url":"https://www.minesup.gov.cm"}]'::jsonb),
('metier-travailleur-social', 'metier', 'Travailleur social / Animateur', 'Social & humain', 'Baccalauréat + formation en travail social', 'Accompagne les personnes et familles en difficulté : enfants vulnérables, personnes handicapées, déplacés internes.', '## Le métier
- Écouter et orienter vers les aides
- Monter des dossiers d''assistance
- Animer des actions de prévention

## Comment y arriver au Cameroun
- Écoles et filières de travail social
- Licence en sociologie / sciences sociales

## Qualités utiles
- Empathie
- Patience
- Sens de l''organisation

## La réalité du terrain
Les ONG, les services sociaux publics et les organisations humanitaires emploient ces profils.

## Conseil Mandal
Le bénévolat associatif est une très bonne porte d''entrée.', ARRAY[]::text[], ARRAY['Filières de travail social', 'Facultés de sciences sociales']::text[], ARRAY['travailleur social / animateur', 'social', 'ong', 'humanitaire', 'animation']::text[], '[{"titre":"Ministère de l''Enseignement Supérieur (MINESUP) — concours, BTS/HND, établissements","url":"https://www.minesup.gov.cm"}]'::jsonb),
('metier-avocat', 'metier', 'Avocat', 'Droit & administration', 'Master en droit + accès au barreau', 'Conseille et défend ses clients devant les tribunaux, en droit civil (francophone) ou en common law (anglophone).', '## Le métier
- Conseiller juridiquement
- Plaider devant les juridictions
- Rédiger contrats et actes

## Comment y arriver au Cameroun
- Licence puis master en droit
- Examen d''accès au stage, stage auprès d''un avocat, puis inscription au barreau

## Qualités utiles
- Éloquence
- Rigueur
- Sens de la justice

## La réalité du terrain
Les débuts sont souvent difficiles ; la spécialisation (affaires, travail, foncier) aide à se faire une clientèle.

## Conseil Mandal
Maîtrise les deux systèmes juridiques camerounais et les deux langues officielles.', ARRAY[]::text[], ARRAY['Facultés de droit']::text[], ARRAY['avocat', 'avocat', 'barreau', 'droit', 'justice', 'plaider']::text[], '[{"titre":"Ministère de l''Enseignement Supérieur (MINESUP) — concours, BTS/HND, établissements","url":"https://www.minesup.gov.cm"},{"titre":"Ministère de la Justice — barreau, huissiers, notaires"}]'::jsonb),
('metier-magistrat', 'metier', 'Magistrat', 'Droit & administration', 'Licence en droit + concours ENAM (magistrature)', 'Juge les affaires (magistrat du siège) ou poursuit au nom de la société (parquet).', '## Le métier
- Instruire et juger les affaires
- Veiller à l''application de la loi
- Protéger les droits des citoyens

## Comment y arriver au Cameroun
- Licence en droit
- Concours de l''ENAM, division magistrature
- Formation à l''ENAM puis nomination

## Qualités utiles
- Intégrité
- Impartialité
- Capacité de travail

## La réalité du terrain
Les affectations se font dans les tribunaux de tout le pays.

## Conseil Mandal
Prépare le concours avec sérieux (droit, culture générale) et méfie-toi des promesses de places payantes.', ARRAY[]::text[], ARRAY['ENAM']::text[], ARRAY['magistrat', 'juge', 'magistrature', 'tribunal', 'procureur']::text[], '[{"titre":"École Nationale d''Administration et de Magistrature (ENAM)","url":"https://www.enam.cm"},{"titre":"Plateforme des concours de l''ENAM","url":"https://concours.enam.cm"},{"titre":"Ministère de la Justice — barreau, huissiers, notaires"}]'::jsonb),
('metier-administrateur-civil', 'metier', 'Administrateur civil', 'Droit & administration', 'Licence + concours ENAM (administration générale)', 'Met en œuvre les politiques publiques dans les ministères et les circonscriptions administratives (sous-préfet, préfet…).', '## Le métier
- Administrer et coordonner les services publics
- Représenter l''État sur le territoire
- Préparer les décisions

## Comment y arriver au Cameroun
- Licence (droit, science politique, économie…)
- Concours de l''ENAM, division administration générale

## Qualités utiles
- Sens de l''intérêt général
- Leadership
- Discrétion

## La réalité du terrain
Carrière dans toute l''administration et sur tout le territoire national.

## Conseil Mandal
Travaille la culture générale, l''actualité et les institutions camerounaises.', ARRAY[]::text[], ARRAY['ENAM']::text[], ARRAY['administrateur civil', 'administration', 'préfet', 'sous-préfet', 'fonction publique', 'enam']::text[], '[{"titre":"École Nationale d''Administration et de Magistrature (ENAM)","url":"https://www.enam.cm"},{"titre":"Plateforme des concours de l''ENAM","url":"https://concours.enam.cm"}]'::jsonb),
('metier-inspecteur-impots-douanes', 'metier', 'Inspecteur des impôts, du trésor ou des douanes', 'Droit & administration', 'Baccalauréat (cycle B) ou Licence (cycle A) + concours ENAM (régies financières)', 'Collecte les recettes de l''État, contrôle les entreprises et les marchandises, lutte contre la fraude.', '## Le métier
- Calculer et contrôler l''impôt
- Contrôler les marchandises aux frontières et au port
- Gérer les fonds publics

## Comment y arriver au Cameroun
- Concours de l''ENAM (division des régies financières)
- Formation puis affectation

## Qualités utiles
- Intégrité
- Rigueur en chiffres
- Fermeté

## La réalité du terrain
Carrières dans les centres des impôts, les ports (Douala, Kribi), les frontières et les services du trésor.

## Conseil Mandal
Économie, comptabilité et droit fiscal sont les matières à soigner.', ARRAY[]::text[], ARRAY['ENAM']::text[], ARRAY['inspecteur des impôts, du trésor ou des douanes', 'impôts', 'douane', 'trésor', 'fiscalité', 'régies financières']::text[], '[{"titre":"École Nationale d''Administration et de Magistrature (ENAM)","url":"https://www.enam.cm"},{"titre":"Ministère des Finances (MINFI) — impôts, douanes, trésor"}]'::jsonb),
('metier-diplomate', 'metier', 'Diplomate', 'Droit & administration', 'Master (IRIC) + recrutement de la fonction publique', 'Représente le Cameroun à l''étranger, négocie et défend ses intérêts, protège les Camerounais de l''étranger.', '## Le métier
- Négocier et représenter
- Analyser l''actualité internationale
- Services consulaires

## Comment y arriver au Cameroun
- Licence puis concours de l''IRIC
- Recrutement dans le corps diplomatique

## Qualités utiles
- Bilinguisme parfait
- Culture générale
- Sens de la négociation

## La réalité du terrain
Peu de places, beaucoup de candidats : les organisations internationales et les ONG offrent d''autres débouchés.

## Conseil Mandal
Apprends une troisième langue et suis l''actualité internationale chaque jour.', ARRAY[]::text[], ARRAY['IRIC']::text[], ARRAY['diplomate', 'diplomatie', 'ambassade', 'affaires étrangères', 'iric']::text[], '[{"titre":"Université de Yaoundé II-Soa (Droit, Économie, ESSTIC, IRIC)"},{"titre":"Ministère de l''Enseignement Supérieur (MINESUP) — concours, BTS/HND, établissements","url":"https://www.minesup.gov.cm"}]'::jsonb),
('metier-comptable', 'metier', 'Comptable / Expert-comptable', 'Commerce & gestion', 'Bac commercial + BTS/HND, Licence ou parcours d''expertise comptable', 'Tient les comptes de l''entreprise, prépare les déclarations fiscales et les états financiers.', '## Le métier
- Enregistrer les opérations
- Préparer bilans et déclarations
- Conseiller sur la gestion

## Comment y arriver au Cameroun
- Lycée technique commercial, BTS/HND comptabilité
- Licence/Master en comptabilité-finance
- Expertise comptable (diplômes et stage réglementés)

## Qualités utiles
- Rigueur
- Discrétion
- Aisance avec les chiffres

## La réalité du terrain
Toutes les entreprises, ONG et administrations ont besoin de comptables ; le référentiel comptable régional (OHADA) est la base.

## Conseil Mandal
Maîtrise un logiciel comptable et la fiscalité camerounaise.', ARRAY[]::text[], ARRAY['BTS/HND', 'FSEG', 'ESSEC']::text[], ARRAY['comptable / expert-comptable', 'comptabilité', 'ohada', 'fiscalité', 'expert-comptable', 'bilan']::text[], '[{"titre":"Ministère de l''Enseignement Supérieur (MINESUP) — concours, BTS/HND, établissements","url":"https://www.minesup.gov.cm"},{"titre":"Office du Baccalauréat du Cameroun (OBC) — Probatoire, Baccalauréat, BT","url":"https://www.obc.cm"}]'::jsonb),
('metier-banquier', 'metier', 'Conseiller bancaire / Agent de microfinance', 'Commerce & gestion', 'Baccalauréat + BTS/HND, Licence ou Master (banque, finance)', 'Accueille et conseille les clients, ouvre les comptes, étudie les demandes de crédit.', '## Le métier
- Conseiller les clients
- Étudier les dossiers de crédit
- Vendre les produits financiers (épargne, mobile money…)

## Comment y arriver au Cameroun
- BTS/HND banque-finance
- Licence/Master en économie, finance, gestion

## Qualités utiles
- Sens commercial
- Rigueur
- Confiance

## La réalité du terrain
Banques, établissements de microfinance et services de paiement mobile recrutent ; le numérique transforme le métier.

## Conseil Mandal
Comprends bien le mobile money et l''inclusion financière : c''est l''avenir du secteur.', ARRAY[]::text[], ARRAY['BTS/HND', 'FSEG', 'ESSEC']::text[], ARRAY['conseiller bancaire / agent de microfinance', 'banque', 'microfinance', 'crédit', 'finance', 'mobile money']::text[], '[{"titre":"Ministère de l''Enseignement Supérieur (MINESUP) — concours, BTS/HND, établissements","url":"https://www.minesup.gov.cm"}]'::jsonb),
('metier-commercial', 'metier', 'Commercial / Vendeur', 'Commerce & gestion', 'Tous niveaux (Bac commercial, BTS/HND marketing conseillés)', 'Fait connaître et vend les produits ou services d''une entreprise, fidélise la clientèle.', '## Le métier
- Prospecter les clients
- Négocier et conclure
- Suivre la satisfaction

## Comment y arriver au Cameroun
- Lycée technique commercial
- BTS/HND marketing ou action commerciale
- Écoles de commerce

## Qualités utiles
- Aisance relationnelle
- Persévérance
- Sens de l''objectif

## La réalité du terrain
Métier très accessible et recherché (télécoms, distribution, agroalimentaire) ; la rémunération dépend souvent des résultats.

## Conseil Mandal
Apprends à vendre en ligne (réseaux sociaux, WhatsApp Business) : c''est devenu indispensable.', ARRAY[]::text[], ARRAY['BTS/HND', 'ESSEC']::text[], ARRAY['commercial / vendeur', 'vente', 'marketing', 'commerce', 'négociation']::text[], '[{"titre":"Ministère de l''Enseignement Supérieur (MINESUP) — concours, BTS/HND, établissements","url":"https://www.minesup.gov.cm"},{"titre":"Office du Baccalauréat du Cameroun (OBC) — Probatoire, Baccalauréat, BT","url":"https://www.obc.cm"}]'::jsonb),
('metier-entrepreneur', 'metier', 'Entrepreneur / Créateur d''entreprise', 'Commerce & gestion', 'Tous niveaux', 'Crée et développe sa propre activité : commerce, transformation agricole, services, numérique…', '## Le métier
- Identifier un besoin et une solution
- Trouver le financement
- Gérer, vendre, recruter

## Comment y arriver au Cameroun
- Une formation dans le métier visé (technique, agricole, commerce…)
- Formations à la création d''entreprise
- Accompagnement (FNE, incubateurs, associations)

## Qualités utiles
- Persévérance
- Prise de risque mesurée
- Sens de la gestion

## La réalité du terrain
Une grande partie des Camerounais travaille à son compte, souvent dans l''informel ; se formaliser facilite l''accès au crédit et aux marchés.

## Conseil Mandal
Commence petit, tiens une comptabilité dès le premier jour et réinvestis tes bénéfices.', ARRAY[]::text[], ARRAY['Toutes filières', 'Programmes du FNE']::text[], ARRAY['entrepreneur / créateur d''entreprise', 'entreprise', 'auto-emploi', 'business', 'création', 'startup']::text[], '[{"titre":"Fonds National de l''Emploi (FNE) — accompagnement vers l''emploi et l''auto-emploi"},{"titre":"Ministère de l''Emploi et de la Formation Professionnelle (MINEFOP) — centres de formation agréés, bourses"}]'::jsonb),
('metier-logisticien', 'metier', 'Logisticien / Transitaire', 'Commerce & gestion', 'Baccalauréat + BTS/HND ou Licence en transport-logistique', 'Organise le transport, le stockage et le dédouanement des marchandises, notamment autour des ports de Douala et Kribi.', '## Le métier
- Planifier les transports
- Gérer les entrepôts et stocks
- Préparer les formalités douanières

## Comment y arriver au Cameroun
- BTS/HND transport-logistique
- IUT, ESSEC (logistique)
- Masters spécialisés

## Qualités utiles
- Organisation
- Réactivité
- Maîtrise des documents

## La réalité du terrain
Le Cameroun est une porte d''entrée vers les pays voisins (Tchad, RCA) : transit et logistique offrent beaucoup d''emplois.

## Conseil Mandal
Apprends les procédures douanières et l''anglais commercial.', ARRAY[]::text[], ARRAY['BTS/HND', 'IUT', 'ESSEC']::text[], ARRAY['logisticien / transitaire', 'logistique', 'transit', 'port', 'douala', 'kribi', 'transport']::text[], '[{"titre":"Ministère de l''Enseignement Supérieur (MINESUP) — concours, BTS/HND, établissements","url":"https://www.minesup.gov.cm"}]'::jsonb),
('metier-assistant-direction', 'metier', 'Assistant(e) de direction / Secrétaire bureautique', 'Commerce & gestion', 'Bac (secrétariat) + BTS/HND', 'Organise l''agenda, le courrier, les réunions et les dossiers d''un dirigeant ou d''un service.', '## Le métier
- Accueil et gestion des appels
- Rédaction et classement
- Organisation des réunions et déplacements

## Comment y arriver au Cameroun
- Lycée technique (secrétariat-bureautique)
- BTS/HND assistanat de direction

## Qualités utiles
- Discrétion
- Organisation
- Excellente expression écrite

## La réalité du terrain
Présent dans toutes les organisations ; le bilinguisme et la maîtrise de l''informatique font la différence.

## Conseil Mandal
Sois excellent(e) en traitement de texte, tableur et en anglais.', ARRAY[]::text[], ARRAY['Lycées techniques', 'BTS/HND']::text[], ARRAY['assistant(e) de direction / secrétaire bureautique', 'secrétariat', 'bureautique', 'assistant', 'secrétaire']::text[], '[{"titre":"Office du Baccalauréat du Cameroun (OBC) — Probatoire, Baccalauréat, BT","url":"https://www.obc.cm"},{"titre":"Ministère de l''Enseignement Supérieur (MINESUP) — concours, BTS/HND, établissements","url":"https://www.minesup.gov.cm"}]'::jsonb),
('metier-ressources-humaines', 'metier', 'Gestionnaire des ressources humaines', 'Commerce & gestion', 'Licence/Master (RH, gestion, psychologie, droit)', 'Recrute, forme, gère la paie et les carrières, veille au respect du droit du travail.', '## Le métier
- Recruter et intégrer
- Gérer la paie et les contrats
- Organiser la formation

## Comment y arriver au Cameroun
- Licence/Master en gestion des RH, psychologie du travail ou droit social

## Qualités utiles
- Écoute
- Discrétion
- Connaissance du Code du travail

## La réalité du terrain
Entreprises, cabinets de recrutement, administrations, ONG.

## Conseil Mandal
Apprends le droit du travail camerounais et un logiciel de paie.', ARRAY[]::text[], ARRAY['FSEG', 'ESSEC', 'Facultés de lettres et sciences humaines']::text[], ARRAY['gestionnaire des ressources humaines', 'rh', 'recrutement', 'paie', 'personnel']::text[], '[{"titre":"Ministère de l''Enseignement Supérieur (MINESUP) — concours, BTS/HND, établissements","url":"https://www.minesup.gov.cm"}]'::jsonb),
('metier-agronome', 'metier', 'Ingénieur agronome / Technicien d''agriculture', 'Agriculture & environnement', 'Bac C ou D + FASA ou écoles d''agriculture', 'Améliore les productions agricoles, conseille les producteurs et gère des exploitations ou des projets.', '## Le métier
- Conseil technique aux producteurs
- Gestion d''exploitations et de projets
- Recherche et amélioration des cultures

## Comment y arriver au Cameroun
- FASA (Université de Dschang) sur concours
- Écoles d''agriculture du MINADER
- BTS/HND agriculture

## Qualités utiles
- Goût du terrain
- Esprit pratique
- Pédagogie avec les producteurs

## La réalité du terrain
L''agriculture emploie une très grande partie des actifs ; cacao, café, banane, maïs, manioc et maraîchage offrent de nombreuses opportunités.

## Conseil Mandal
Pense agrobusiness : production, transformation et vente.', ARRAY[]::text[], ARRAY['FASA', 'Écoles MINADER', 'BTS/HND']::text[], ARRAY['ingénieur agronome / technicien d''agriculture', 'agriculture', 'agronomie', 'cacao', 'café', 'exploitation', 'fasa']::text[], '[{"titre":"Ministère de l''Agriculture et du Développement Rural (MINADER)"},{"titre":"Université de Dschang (FASA, IUT Fotso Victor de Bandjoun)"},{"titre":"Ministère de l''Enseignement Supérieur (MINESUP) — concours, BTS/HND, établissements","url":"https://www.minesup.gov.cm"}]'::jsonb),
('metier-agro-entrepreneur', 'metier', 'Agro-entrepreneur (aviculture, pisciculture, maraîchage)', 'Agriculture & environnement', 'Tous niveaux (formation agricole conseillée)', 'Crée une exploitation rentable : poulets, poissons, porcs, légumes, et souvent leur transformation.', '## Le métier
- Produire (élevage, cultures)
- Gérer la santé des animaux et des plantes
- Vendre et transformer

## Comment y arriver au Cameroun
- Formations agricoles courtes (centres agréés, programmes publics)
- BTS/HND ou formation d''ingénieur pour aller plus loin

## Qualités utiles
- Patience
- Rigueur
- Esprit d''entreprise

## La réalité du terrain
La demande alimentaire des villes est forte ; les risques (maladies, prix des intrants) se gèrent par la formation et la comptabilité.

## Conseil Mandal
Commence par une petite unité, maîtrise-la, puis agrandis-toi.', ARRAY[]::text[], ARRAY['Centres MINADER / MINEPIA', 'Formation professionnelle']::text[], ARRAY['agro-entrepreneur (aviculture, pisciculture, maraîchage)', 'aviculture', 'pisciculture', 'élevage', 'maraîchage', 'poulets', 'agrobusiness']::text[], '[{"titre":"Ministère de l''Agriculture et du Développement Rural (MINADER)"},{"titre":"Ministère de l''Élevage, des Pêches et des Industries Animales (MINEPIA)"},{"titre":"Fonds National de l''Emploi (FNE) — accompagnement vers l''emploi et l''auto-emploi"}]'::jsonb),
('metier-ingenieur-agroalimentaire', 'metier', 'Ingénieur / Technicien agroalimentaire', 'Agriculture & environnement', 'Bac C ou D + ENSAI, IUT ou BTS/HND', 'Transforme les produits agricoles (jus, farines, huiles, chocolat…) en garantissant qualité et sécurité.', '## Le métier
- Concevoir et améliorer les procédés
- Contrôler la qualité et l''hygiène
- Gérer la production

## Comment y arriver au Cameroun
- ENSAI (Ngaoundéré) sur concours
- IUT (génie biologique), BTS/HND

## Qualités utiles
- Rigueur scientifique
- Sens de l''hygiène
- Esprit d''innovation

## La réalité du terrain
Transformer localement réduit les pertes et crée de la valeur : brasseries, huileries, chocolateries, PME de transformation.

## Conseil Mandal
Les petites unités de transformation (fruits, manioc, soja) sont accessibles aux jeunes entrepreneurs formés.', ARRAY[]::text[], ARRAY['ENSAI', 'IUT', 'BTS/HND']::text[], ARRAY['ingénieur / technicien agroalimentaire', 'agroalimentaire', 'transformation', 'ensai', 'qualité', 'industrie alimentaire']::text[], '[{"titre":"Université de Ngaoundéré (ENSAI, IUT, EGCIM)"},{"titre":"Ministère de l''Enseignement Supérieur (MINESUP) — concours, BTS/HND, établissements","url":"https://www.minesup.gov.cm"}]'::jsonb),
('metier-ingenieur-forestier-environnement', 'metier', 'Ingénieur forestier / Spécialiste de l''environnement', 'Agriculture & environnement', 'Bac C ou D + formation forestière ou master en environnement', 'Protège et gère durablement les forêts, la faune et l''environnement ; lutte contre le changement climatique.', '## Le métier
- Inventaires et aménagement forestier
- Protection de la faune et des aires protégées
- Études d''impact environnemental

## Comment y arriver au Cameroun
- FASA (foresterie)
- Écoles de faune et des eaux et forêts
- Masters en environnement

## Qualités utiles
- Amour de la nature
- Endurance
- Sens de la négociation avec les communautés

## La réalité du terrain
Le Cameroun possède une partie importante du massif forestier du Bassin du Congo : enjeux de conservation et d''exploitation durable.

## Conseil Mandal
Associe terrain et outils numériques (SIG, télédétection).', ARRAY[]::text[], ARRAY['FASA', 'Écoles des eaux et forêts']::text[], ARRAY['ingénieur forestier / spécialiste de l''environnement', 'forêt', 'environnement', 'climat', 'faune', 'écologie']::text[], '[{"titre":"Université de Dschang (FASA, IUT Fotso Victor de Bandjoun)"},{"titre":"Ministère de l''Enseignement Supérieur (MINESUP) — concours, BTS/HND, établissements","url":"https://www.minesup.gov.cm"}]'::jsonb),
('metier-journaliste', 'metier', 'Journaliste', 'Communication & arts', 'Bac + ESSTIC (concours) ou formations en journalisme', 'Recherche, vérifie et diffuse l''information à la radio, à la télévision, dans la presse et sur le web.', '## Le métier
- Enquêter et vérifier les faits
- Rédiger, présenter, réaliser des reportages
- Respecter l''éthique et la déontologie

## Comment y arriver au Cameroun
- ESSTIC (Université de Yaoundé II) sur concours
- Licences de communication / journalisme

## Qualités utiles
- Curiosité
- Excellente expression
- Honnêteté

## La réalité du terrain
Médias publics et privés, radios communautaires, web ; la lutte contre les fausses informations est un enjeu majeur.

## Conseil Mandal
Écris et produis dès maintenant (journal scolaire, podcast, blog).', ARRAY[]::text[], ARRAY['ESSTIC']::text[], ARRAY['journaliste', 'journalisme', 'médias', 'radio', 'télévision', 'presse']::text[], '[{"titre":"Université de Yaoundé II-Soa (Droit, Économie, ESSTIC, IRIC)"},{"titre":"Ministère de l''Enseignement Supérieur (MINESUP) — concours, BTS/HND, établissements","url":"https://www.minesup.gov.cm"}]'::jsonb),
('metier-community-manager', 'metier', 'Community manager / Chargé de communication digitale', 'Communication & arts', 'Bac + formation en communication ou marketing digital', 'Anime les réseaux sociaux d''une marque, crée du contenu et suit les performances.', '## Le métier
- Créer des publications et vidéos
- Répondre à la communauté
- Analyser les statistiques

## Comment y arriver au Cameroun
- ESSTIC, BTS/HND communication, formations en marketing digital

## Qualités utiles
- Créativité
- Réactivité
- Bonne orthographe

## La réalité du terrain
Les entreprises camerounaises investissent sur les réseaux sociaux ; beaucoup de missions en freelance.

## Conseil Mandal
Gère une page avec de vrais résultats : c''est ton meilleur CV.', ARRAY[]::text[], ARRAY['ESSTIC', 'BTS/HND']::text[], ARRAY['community manager / chargé de communication digitale', 'réseaux sociaux', 'digital', 'marketing', 'communication', 'facebook', 'tiktok']::text[], '[{"titre":"Ministère de l''Enseignement Supérieur (MINESUP) — concours, BTS/HND, établissements","url":"https://www.minesup.gov.cm"}]'::jsonb),
('metier-graphiste', 'metier', 'Graphiste / Designer', 'Communication & arts', 'Bac + formation en arts graphiques ou design', 'Crée logos, affiches, emballages, interfaces d''applications et identités visuelles.', '## Le métier
- Concevoir des visuels
- Travailler avec les clients
- Maîtriser les logiciels de création

## Comment y arriver au Cameroun
- Institut des Beaux-Arts de Foumban, écoles de design
- Formations courtes et autoformation

## Qualités utiles
- Créativité
- Sens esthétique
- Écoute du client

## La réalité du terrain
Agences, imprimeries, entreprises et freelance ; un portfolio solide est indispensable.

## Conseil Mandal
Constitue un portfolio en ligne et apprends aussi le design d''interfaces (applications, sites).', ARRAY[]::text[], ARRAY['Institut des Beaux-Arts de Foumban', 'Écoles de design']::text[], ARRAY['graphiste / designer', 'design', 'graphisme', 'infographie', 'logo', 'création']::text[], '[{"titre":"Université de Dschang (FASA, IUT Fotso Victor de Bandjoun)"}]'::jsonb),
('metier-traducteur', 'metier', 'Traducteur / Interprète', 'Communication & arts', 'Licence + ASTI (concours) ou formation en traduction', 'Traduit des documents et interprète des échanges entre langues, en premier lieu entre le français et l''anglais.', '## Le métier
- Traduire des textes administratifs, juridiques, techniques
- Interpréter en réunion ou conférence
- Relire et harmoniser la terminologie

## Comment y arriver au Cameroun
- ASTI (University of Buea) sur concours
- Licences et masters en langues et traduction

## Qualités utiles
- Maîtrise parfaite de deux langues
- Rigueur
- Culture générale

## La réalité du terrain
Le bilinguisme officiel crée une demande forte dans l''administration, les entreprises et les organisations internationales.

## Conseil Mandal
Lis chaque jour en français et en anglais, et apprends une troisième langue.', ARRAY[]::text[], ARRAY['ASTI', 'Facultés de lettres']::text[], ARRAY['traducteur / interprète', 'traduction', 'interprète', 'bilinguisme', 'anglais', 'langues']::text[], '[{"titre":"University of Buea (Faculty of Health Sciences, COT, faculties)"},{"titre":"Ministère de l''Enseignement Supérieur (MINESUP) — concours, BTS/HND, établissements","url":"https://www.minesup.gov.cm"}]'::jsonb),
('metier-artiste-musicien', 'metier', 'Artiste musicien / Producteur', 'Communication & arts', 'Tous niveaux (formation musicale conseillée)', 'Compose, interprète, enregistre et produit de la musique ; vit de la scène, du streaming et des droits.', '## Le métier
- Créer et interpréter
- Enregistrer et produire
- Promouvoir et gérer sa carrière

## Comment y arriver au Cameroun
- Institut des Beaux-Arts de Foumban (musique), conservatoires et écoles privées
- Apprentissage auprès de professionnels

## Qualités utiles
- Talent et travail
- Persévérance
- Sens des affaires

## La réalité du terrain
La scène musicale camerounaise est riche (makossa, bikutsi, urban) ; peu en vivent sans gestion professionnelle de leurs droits.

## Conseil Mandal
Déclare tes œuvres auprès de l''organisme de gestion des droits d''auteur et apprends le marketing musical.', ARRAY[]::text[], ARRAY['Institut des Beaux-Arts de Foumban']::text[], ARRAY['artiste musicien / producteur', 'musique', 'artiste', 'chanteur', 'production', 'makossa', 'bikutsi']::text[], '[{"titre":"Université de Dschang (FASA, IUT Fotso Victor de Bandjoun)"}]'::jsonb),
('metier-officier-armee', 'metier', 'Officier des forces armées', 'Défense & sécurité', 'Baccalauréat ou Licence + concours EMIA', 'Commande des unités militaires, assure la défense du territoire et participe à des missions de paix.', '## Le métier
- Commander et former des soldats
- Planifier des opérations
- Servir dans l''armée de terre, l''air ou la marine

## Comment y arriver au Cameroun
- Concours de l''École Militaire Interarmées (EMIA) après le Bac ou la licence
- Formation militaire et académique

## Qualités utiles
- Aptitude physique
- Discipline
- Sens du commandement

## La réalité du terrain
Carrière exigeante avec des affectations partout au Cameroun ; les recrutements sont annoncés par communiqué officiel du MINDEF.

## Conseil Mandal
Entraîne-toi physiquement et ne paie jamais un intermédiaire pour un recrutement.', ARRAY[]::text[], ARRAY['EMIA']::text[], ARRAY['officier des forces armées', 'armée', 'militaire', 'emia', 'officier', 'défense']::text[], '[{"titre":"Ministère de la Défense (MINDEF) — EMIA et recrutements des forces de défense"}]'::jsonb),
('metier-policier', 'metier', 'Policier (gardien de la paix, inspecteur, officier, commissaire)', 'Défense & sécurité', 'BEPC à Licence selon le grade + concours DGSN', 'Assure la sécurité des personnes et des biens, la circulation, les enquêtes et le maintien de l''ordre.', '## Le métier
- Patrouilles et sécurité publique
- Enquêtes judiciaires
- Contrôles (circulation, frontières)

## Comment y arriver au Cameroun
- Concours de la Sûreté Nationale (DGSN) selon le diplôme
- Formation dans les écoles de police

## Qualités utiles
- Intégrité
- Sang-froid
- Condition physique

## La réalité du terrain
Les concours attirent énormément de candidats ; seuls les communiqués officiels de la DGSN font foi.

## Conseil Mandal
Prépare l''épreuve sportive autant que l''écrit, et méfie-toi des arnaques au recrutement.', ARRAY[]::text[], ARRAY['École Nationale Supérieure de Police', 'Écoles de police']::text[], ARRAY['policier (gardien de la paix, inspecteur, officier, commissaire)', 'police', 'dgsn', 'commissaire', 'inspecteur de police', 'gardien de la paix']::text[], '[{"titre":"Délégation Générale à la Sûreté Nationale (DGSN) — concours de la police"}]'::jsonb),
('metier-couturier-styliste', 'metier', 'Couturier / Styliste-modéliste', 'Artisanat & services', 'Tous niveaux (centres de formation professionnelle)', 'Conçoit et confectionne des vêtements sur mesure ou en série, du pagne au costume.', '## Le métier
- Prendre les mesures et conseiller
- Couper, assembler, finir
- Créer des collections

## Comment y arriver au Cameroun
- Centres de formation professionnelle agréés (couture, stylisme)
- SAR/SM
- Apprentissage dans un atelier

## Qualités utiles
- Précision
- Créativité
- Respect des délais

## La réalité du terrain
Forte demande pour les tenues de cérémonie et le pagne ; la mode africaine s''exporte.

## Conseil Mandal
Montre tes créations sur les réseaux sociaux et soigne les finitions.', ARRAY[]::text[], ARRAY['Centres MINEFOP', 'SAR/SM']::text[], ARRAY['couturier / styliste-modéliste', 'couture', 'mode', 'stylisme', 'pagne', 'atelier']::text[], '[{"titre":"Ministère de l''Emploi et de la Formation Professionnelle (MINEFOP) — centres de formation agréés, bourses"}]'::jsonb),
('metier-coiffeur-estheticien', 'metier', 'Coiffeur / Esthéticien', 'Artisanat & services', 'Tous niveaux (formation professionnelle)', 'Coiffe, tresse, soigne et met en beauté ; gère souvent son propre salon.', '## Le métier
- Coupes, tresses, tissages, soins
- Conseil beauté
- Gestion du salon

## Comment y arriver au Cameroun
- Centres de formation professionnelle agréés
- Apprentissage en salon

## Qualités utiles
- Habileté
- Sens du contact
- Hygiène

## La réalité du terrain
Métier très répandu, idéal pour l''auto-emploi ; la qualité de l''accueil fidélise la clientèle.

## Conseil Mandal
Forme-toi aux techniques nouvelles et tiens tes comptes.', ARRAY[]::text[], ARRAY['Centres MINEFOP']::text[], ARRAY['coiffeur / esthéticien', 'coiffure', 'esthétique', 'beauté', 'salon', 'tresses']::text[], '[{"titre":"Ministère de l''Emploi et de la Formation Professionnelle (MINEFOP) — centres de formation agréés, bourses"}]'::jsonb),
('metier-menuisier', 'metier', 'Menuisier / Ébéniste', 'Artisanat & services', 'CAP ou formation professionnelle', 'Fabrique et pose meubles, portes, fenêtres et charpentes en bois.', '## Le métier
- Lire un plan, débiter et assembler
- Finir et poser
- Conseiller le client sur les essences de bois

## Comment y arriver au Cameroun
- Lycée technique (menuiserie)
- Centres de formation professionnelle
- Apprentissage

## Qualités utiles
- Habileté manuelle
- Précision
- Sens esthétique

## La réalité du terrain
Le bois local est une richesse ; beaucoup d''artisans s''installent à leur compte.

## Conseil Mandal
Apprends le dessin assisté par ordinateur pour proposer des modèles modernes.', ARRAY[]::text[], ARRAY['Lycées techniques', 'Centres MINEFOP']::text[], ARRAY['menuisier / ébéniste', 'menuiserie', 'bois', 'meubles', 'ébénisterie']::text[], '[{"titre":"Ministère de l''Emploi et de la Formation Professionnelle (MINEFOP) — centres de formation agréés, bourses"},{"titre":"Office du Baccalauréat du Cameroun (OBC) — Probatoire, Baccalauréat, BT","url":"https://www.obc.cm"}]'::jsonb),
('metier-plombier', 'metier', 'Plombier / Installateur sanitaire', 'Artisanat & services', 'CAP ou formation professionnelle', 'Installe et répare les canalisations, les sanitaires, les pompes et les citernes.', '## Le métier
- Installer les réseaux d''eau
- Réparer les fuites
- Installer pompes et chauffe-eau

## Comment y arriver au Cameroun
- Lycée technique / centres de formation professionnelle
- Apprentissage

## Qualités utiles
- Sens pratique
- Rigueur
- Disponibilité

## La réalité du terrain
La construction et les besoins en eau assurent une demande régulière.

## Conseil Mandal
Ajoute le solaire thermique et les pompes solaires à tes compétences.', ARRAY[]::text[], ARRAY['Centres MINEFOP']::text[], ARRAY['plombier / installateur sanitaire', 'plomberie', 'sanitaire', 'eau', 'canalisations']::text[], '[{"titre":"Ministère de l''Emploi et de la Formation Professionnelle (MINEFOP) — centres de formation agréés, bourses"}]'::jsonb),
('metier-reparateur-telephones', 'metier', 'Technicien en réparation de téléphones et d''ordinateurs', 'Artisanat & services', 'Tous niveaux (formation technique conseillée)', 'Diagnostique et répare smartphones, ordinateurs et petits appareils électroniques.', '## Le métier
- Diagnostic des pannes
- Remplacement de pièces, soudure
- Installation de logiciels

## Comment y arriver au Cameroun
- Lycée technique (électronique F2)
- Centres de formation professionnelle
- Apprentissage

## Qualités utiles
- Minutie
- Patience
- Honnêteté

## La réalité du terrain
Très forte demande dans toutes les villes ; activité accessible avec peu d''investissement.

## Conseil Mandal
Sois transparent sur les pièces et les prix : la confiance fait revenir les clients.', ARRAY[]::text[], ARRAY['Lycées techniques (F2)', 'Centres MINEFOP']::text[], ARRAY['technicien en réparation de téléphones et d''ordinateurs', 'téléphone', 'réparation', 'électronique', 'smartphone', 'ordinateur']::text[], '[{"titre":"Ministère de l''Emploi et de la Formation Professionnelle (MINEFOP) — centres de formation agréés, bourses"},{"titre":"Office du Baccalauréat du Cameroun (OBC) — Probatoire, Baccalauréat, BT","url":"https://www.obc.cm"}]'::jsonb),
('metier-cuisinier-hotellerie', 'metier', 'Cuisinier / Professionnel de l''hôtellerie et de la restauration', 'Tourisme & hôtellerie', 'Tous niveaux (formation hôtelière conseillée)', 'Prépare les repas, gère la cuisine, l''accueil ou l''hébergement dans les restaurants et hôtels.', '## Le métier
- Préparer les plats (cuisine camerounaise et internationale)
- Respecter l''hygiène
- Accueillir et servir

## Comment y arriver au Cameroun
- Écoles hôtelières, BTS/HND hôtellerie-tourisme
- Centres de formation professionnelle

## Qualités utiles
- Créativité
- Endurance
- Hygiène irréprochable

## La réalité du terrain
Restaurants, hôtels, traiteurs et événements ; la cuisine camerounaise a un grand potentiel commercial.

## Conseil Mandal
Le service traiteur pour les cérémonies est un bon démarrage en auto-emploi.', ARRAY[]::text[], ARRAY['Écoles hôtelières', 'BTS/HND']::text[], ARRAY['cuisinier / professionnel de l''hôtellerie et de la restauration', 'cuisine', 'restaurant', 'hôtel', 'traiteur', 'hôtellerie']::text[], '[{"titre":"Ministère de l''Emploi et de la Formation Professionnelle (MINEFOP) — centres de formation agréés, bourses"},{"titre":"Ministère de l''Enseignement Supérieur (MINESUP) — concours, BTS/HND, établissements","url":"https://www.minesup.gov.cm"}]'::jsonb),
('metier-guide-tourisme', 'metier', 'Guide touristique / Agent de tourisme', 'Tourisme & hôtellerie', 'Baccalauréat + BTS/HND tourisme ou licence', 'Fait découvrir le Cameroun, « l''Afrique en miniature » : sites naturels, culturels et historiques.', '## Le métier
- Organiser des circuits
- Accueillir et guider
- Présenter l''histoire et les cultures

## Comment y arriver au Cameroun
- BTS/HND tourisme
- Licences en tourisme, histoire, géographie, langues

## Qualités utiles
- Excellente expression
- Culture générale
- Plusieurs langues

## La réalité du terrain
Le pays offre mer, montagnes, savanes, forêts et chefferies ; le tourisme intérieur se développe.

## Conseil Mandal
Les langues étrangères et la connaissance des cultures locales sont tes meilleurs atouts.', ARRAY[]::text[], ARRAY['BTS/HND', 'Facultés de lettres']::text[], ARRAY['guide touristique / agent de tourisme', 'tourisme', 'guide', 'voyage', 'patrimoine']::text[], '[{"titre":"Ministère de l''Enseignement Supérieur (MINESUP) — concours, BTS/HND, établissements","url":"https://www.minesup.gov.cm"}]'::jsonb),
('metier-pilote-aviation', 'metier', 'Pilote / Technicien de l''aviation', 'Transport', 'Bac C ou E (pilotes) / Bac technique (maintenance)', 'Pilote des avions ou en assure la maintenance, la sécurité et le contrôle du trafic.', '## Le métier
- Piloter en sécurité
- Entretenir les aéronefs
- Contrôler la navigation aérienne

## Comment y arriver au Cameroun
- Écoles de pilotage et d''aviation (souvent à l''étranger ou régionales)
- Écoles de la navigation aérienne sur concours

## Qualités utiles
- Excellent niveau en maths et physique
- Aptitude médicale
- Anglais courant

## La réalité du terrain
Formations longues et coûteuses ; les bourses et concours régionaux sont à surveiller.

## Conseil Mandal
Travaille l''anglais : c''est la langue de l''aviation.', ARRAY[]::text[], ARRAY['Écoles d''aviation']::text[], ARRAY['pilote / technicien de l''aviation', 'pilote', 'avion', 'aviation', 'aéroport', 'aéronautique']::text[], '[{"titre":"Ministère de l''Enseignement Supérieur (MINESUP) — concours, BTS/HND, établissements","url":"https://www.minesup.gov.cm"}]'::jsonb),
('metier-chercheur', 'metier', 'Enseignant-chercheur / Chercheur', 'Enseignement', 'Doctorat', 'Fait avancer la connaissance (santé, agriculture, technologies…) et enseigne à l''université.', '## Le métier
- Mener des recherches
- Publier et participer aux colloques
- Enseigner et encadrer des étudiants

## Comment y arriver au Cameroun
- Licence, master puis doctorat
- Recrutement dans les universités ou instituts de recherche

## Qualités utiles
- Curiosité
- Persévérance
- Rigueur scientifique

## La réalité du terrain
Les universités d''État recrutent régulièrement des enseignants-chercheurs, notamment dans les nouvelles universités.

## Conseil Mandal
Obtiens d''excellents résultats en master et maîtrise l''anglais scientifique.', ARRAY[]::text[], ARRAY['Universités d''État']::text[], ARRAY['enseignant-chercheur / chercheur', 'recherche', 'doctorat', 'université', 'professeur d''université']::text[], '[{"titre":"Ministère de l''Enseignement Supérieur (MINESUP) — concours, BTS/HND, établissements","url":"https://www.minesup.gov.cm"},{"titre":"Loi n°2023/007 du 25 juillet 2023 portant orientation de l''enseignement supérieur au Cameroun"}]'::jsonb),
('faq-serie-c-ou-d', 'faq', 'Dois-je choisir la série C ou la série D ?', 'Choisir sa série', NULL, 'Choisis la **C** si tu es très à l''aise en mathématiques et en physique, la **D** si tu préfères les sciences de la vie (SVT) tout en gardant un bon niveau en maths.', 'Choisis la **C** si tu es très à l''aise en mathématiques et en physique, la **D** si tu préfères les sciences de la vie (SVT) tout en gardant un bon niveau en maths.

- La **C** mène surtout aux écoles d''ingénieurs, aux maths, à la physique, à l''informatique et à la statistique.
- La **D** mène surtout à la médecine, la pharmacie, l''agronomie, la biologie et le paramédical.
- Beaucoup de concours (médecine, ingénieurs, ENS) acceptent les deux séries, mais les épreuves favorisent celle qui correspond au programme.
- Parle avec ton professeur de maths et le conseiller d''orientation de ton établissement avant de décider.', ARRAY[]::text[], ARRAY[]::text[], ARRAY['série c', 'série d', 'seconde c', 'première', 'choix de série', 'maths', 'svt']::text[], '[{"titre":"Ministère des Enseignements Secondaires (MINESEC)","url":"https://www.minesec.gov.cm"},{"titre":"Office du Baccalauréat du Cameroun (OBC) — Probatoire, Baccalauréat, BT","url":"https://www.obc.cm"}]'::jsonb),
('faq-serie-a-avenir', 'faq', 'La série A a-t-elle de l''avenir ?', 'Choisir sa série', NULL, 'Oui. La série **A** ouvre au droit, aux lettres, aux langues, au journalisme, à la diplomatie, à l''enseignement et à de nombreux concours administratifs.', 'Oui. La série **A** ouvre au droit, aux lettres, aux langues, au journalisme, à la diplomatie, à l''enseignement et à de nombreux concours administratifs.

- Points forts à cultiver : expression écrite, culture générale, langues (français, anglais, et une autre langue).
- Débouchés : avocat, magistrat (via l''ENAM), journaliste (ESSTIC), traducteur (ASTI), diplomate (IRIC), enseignant (ENS), communication.
- Le bilinguisme est un énorme atout au Cameroun.', ARRAY[]::text[], ARRAY[]::text[], ARRAY['série a', 'littéraire', 'lettres', 'philosophie', 'droit']::text[], '[{"titre":"Ministère des Enseignements Secondaires (MINESEC)","url":"https://www.minesec.gov.cm"},{"titre":"Office du Baccalauréat du Cameroun (OBC) — Probatoire, Baccalauréat, BT","url":"https://www.obc.cm"},{"titre":"Ministère de l''Enseignement Supérieur (MINESUP) — concours, BTS/HND, établissements","url":"https://www.minesup.gov.cm"}]'::jsonb),
('faq-serie-ti', 'faq', 'Qu''est-ce que la série TI et que faire après ?', 'Choisir sa série', NULL, 'La série **TI** (Technologies de l''Information) renforce l''informatique et les mathématiques au second cycle de l''enseignement général.', 'La série **TI** (Technologies de l''Information) renforce l''informatique et les mathématiques au second cycle de l''enseignement général.

- Après le Bac TI : licence d''informatique, IUT, écoles d''ingénieurs (génie informatique, télécoms), BTS/HND en génie logiciel ou réseaux.
- Le portfolio de projets (sites, applications) compte beaucoup à l''embauche.', ARRAY[]::text[], ARRAY[]::text[], ARRAY['ti', 'technologies de l''information', 'informatique', 'série ti']::text[], '[{"titre":"Ministère des Enseignements Secondaires (MINESEC)","url":"https://www.minesec.gov.cm"},{"titre":"Office du Baccalauréat du Cameroun (OBC) — Probatoire, Baccalauréat, BT","url":"https://www.obc.cm"},{"titre":"Ministère de l''Enseignement Supérieur (MINESUP) — concours, BTS/HND, établissements","url":"https://www.minesup.gov.cm"}]'::jsonb),
('faq-technique-ou-general', 'faq', 'Faut-il aller au lycée technique ou au lycée général ?', 'Choisir sa série', NULL, 'Le **technique** prépare à un métier concret (électricité, mécanique, bâtiment, comptabilité…) tout en permettant les études supérieures ; le **général** prépare surtout aux études longues.', 'Le **technique** prépare à un métier concret (électricité, mécanique, bâtiment, comptabilité…) tout en permettant les études supérieures ; le **général** prépare surtout aux études longues.

- Au technique : CAP en fin de premier cycle, puis Probatoire et Baccalauréat technique (séries F, G…) ou Brevet de technicien.
- Le Bac technique permet d''aller à l''université, en IUT, en BTS/HND ou en école d''ingénieurs.
- Si tu aimes manipuler, réparer, construire ou gérer, le technique est un excellent choix et pas une voie « de seconde zone ».', ARRAY[]::text[], ARRAY[]::text[], ARRAY['lycée technique', 'enseignement technique', 'cap', 'f3', 'f4', 'comptabilité', 'lycée général']::text[], '[{"titre":"Ministère des Enseignements Secondaires (MINESEC)","url":"https://www.minesec.gov.cm"},{"titre":"Office du Baccalauréat du Cameroun (OBC) — Probatoire, Baccalauréat, BT","url":"https://www.obc.cm"}]'::jsonb),
('faq-changer-de-serie', 'faq', 'Peut-on changer de série en cours de route ?', 'Choisir sa série', NULL, 'C''est possible dans certains cas (surtout entre la Seconde et la Première), sur décision du conseil de classe et selon tes résultats et les places disponibles.', 'C''est possible dans certains cas (surtout entre la Seconde et la Première), sur décision du conseil de classe et selon tes résultats et les places disponibles.

- Adresse-toi à ton censeur et au conseiller d''orientation.
- Plus le changement est tardif, plus il est difficile de rattraper le programme.', ARRAY[]::text[], ARRAY[]::text[], ARRAY['changer de série', 'réorientation', 'conseil de classe']::text[], '[{"titre":"Ministère des Enseignements Secondaires (MINESEC)","url":"https://www.minesec.gov.cm"}]'::jsonb),
('faq-bepc-ou-cap', 'faq', 'Après la 3e : BEPC ou CAP, quelle différence ?', 'Choisir sa série', NULL, 'Le **BEPC** sanctionne le premier cycle de l''enseignement général ; le **CAP** sanctionne le premier cycle de l''enseignement technique et atteste une qualification professionnelle.', 'Le **BEPC** sanctionne le premier cycle de l''enseignement général ; le **CAP** sanctionne le premier cycle de l''enseignement technique et atteste une qualification professionnelle.

- Les deux permettent de poursuivre au second cycle selon l''orientation décidée.
- Les examens du premier cycle sont organisés par le MINESEC.', ARRAY[]::text[], ARRAY[]::text[], ARRAY['bepc', 'cap', '3e', 'premier cycle']::text[], '[{"titre":"Ministère des Enseignements Secondaires (MINESEC)","url":"https://www.minesec.gov.cm"},{"titre":"Décret n°2012/267 du 11 juin 2012 portant organisation du MINESEC"}]'::jsonb),
('faq-gce-ou-bac', 'faq', 'GCE A Level ou Baccalauréat : lequel est le mieux ?', 'Choisir sa série', NULL, 'Aucun n''est « meilleur » : ce sont deux diplômes nationaux équivalents pour l''accès à l''enseignement supérieur au Cameroun, l''un dans le sous-système anglophone, l''autre dans le francophone.', 'Aucun n''est « meilleur » : ce sont deux diplômes nationaux équivalents pour l''accès à l''enseignement supérieur au Cameroun, l''un dans le sous-système anglophone, l''autre dans le francophone.

- Le **GCE** est organisé par le GCE Board, le **Bac** par l''OBC.
- Choisis le sous-système dans lequel tu réussis le mieux, et travaille l''autre langue officielle : être bilingue est un vrai avantage.', ARRAY[]::text[], ARRAY[]::text[], ARRAY['gce', 'a level', 'o level', 'baccalauréat', 'anglophone', 'bilingue']::text[], '[{"titre":"Cameroon GCE Board — GCE O Level / A Level","url":"https://www.camgceb.org"},{"titre":"Office du Baccalauréat du Cameroun (OBC) — Probatoire, Baccalauréat, BT","url":"https://www.obc.cm"}]'::jsonb),
('faq-a-level-subjects', 'faq', 'Which A Level subjects should I take for medicine or engineering?', 'Choisir sa série', NULL, 'For **medicine**, take Biology and Chemistry (often with Physics or Mathematics). For **engineering**, take Mathematics and Physics (often with Chemistry or Further Mathematics).', 'For **medicine**, take Biology and Chemistry (often with Physics or Mathematics). For **engineering**, take Mathematics and Physics (often with Chemistry or Further Mathematics).

- Always check the exact requirements in the official entrance examination notice (MINESUP or the institution).
- Good O Level grades in English and Mathematics are also required by many schools.', ARRAY[]::text[], ARRAY[]::text[], ARRAY['a level', 'subjects', 'medicine', 'engineering', 'biology', 'physics']::text[], '[{"titre":"Cameroon GCE Board — GCE O Level / A Level","url":"https://www.camgceb.org"},{"titre":"Ministère de l''Enseignement Supérieur (MINESUP) — concours, BTS/HND, établissements","url":"https://www.minesup.gov.cm"},{"titre":"University of Buea (Faculty of Health Sciences, COT, faculties)"}]'::jsonb),
('faq-resultats-bac', 'faq', 'Où consulter les résultats du Probatoire et du Baccalauréat ?', 'Examens officiels', NULL, 'Les résultats sont publiés par l''**Office du Baccalauréat du Cameroun (OBC)**, sur son site officiel et par affichage dans les centres.', 'Les résultats sont publiés par l''**Office du Baccalauréat du Cameroun (OBC)**, sur son site officiel et par affichage dans les centres.

- Méfie-toi des pages et groupes qui publient de faux résultats ou demandent de l''argent.
- Pour le GCE, consulte le **GCE Board**.', ARRAY[]::text[], ARRAY[]::text[], ARRAY['résultats', 'bac', 'probatoire', 'obc', 'publication']::text[], '[{"titre":"Office du Baccalauréat du Cameroun (OBC) — Probatoire, Baccalauréat, BT","url":"https://www.obc.cm"},{"titre":"Cameroon GCE Board — GCE O Level / A Level","url":"https://www.camgceb.org"}]'::jsonb),
('faq-resultats-bepc', 'faq', 'Où trouver les résultats du BEPC et du CAP ?', 'Examens officiels', NULL, 'Le BEPC et le CAP relèvent du **MINESEC** : les résultats sont publiés par ses services (délégations régionales, affichage dans les centres, canaux officiels).', 'Le BEPC et le CAP relèvent du **MINESEC** : les résultats sont publiés par ses services (délégations régionales, affichage dans les centres, canaux officiels).

- Ne paie jamais pour « voir » des résultats.', ARRAY[]::text[], ARRAY[]::text[], ARRAY['résultats bepc', 'cap', 'minesec']::text[], '[{"titre":"Ministère des Enseignements Secondaires (MINESEC)","url":"https://www.minesec.gov.cm"}]'::jsonb),
('faq-echec-bac', 'faq', 'J''ai échoué au Baccalauréat : que faire ?', 'Examens officiels', NULL, 'Ce n''est pas la fin : tu peux redoubler pour repasser l''examen, te présenter en candidat libre, ou t''orienter vers la formation professionnelle.', 'Ce n''est pas la fin : tu peux redoubler pour repasser l''examen, te présenter en candidat libre, ou t''orienter vers la formation professionnelle.

- Analyse tes notes : quelles matières t''ont fait perdre des points ?
- Utilise les annales et les épreuves blanches de Mandal pour t''entraîner.
- Si tu veux un métier rapidement, regarde les centres de formation professionnelle agréés (MINEFOP).', ARRAY[]::text[], ARRAY[]::text[], ARRAY['échec', 'redoubler', 'candidat libre', 'bac raté']::text[], '[{"titre":"Office du Baccalauréat du Cameroun (OBC) — Probatoire, Baccalauréat, BT","url":"https://www.obc.cm"},{"titre":"Ministère de l''Emploi et de la Formation Professionnelle (MINEFOP) — centres de formation agréés, bourses"}]'::jsonb),
('faq-candidat-libre', 'faq', 'Peut-on passer le Bac ou le GCE en candidat libre ?', 'Examens officiels', NULL, 'Oui, les examens officiels acceptent des candidats libres, sous réserve des conditions fixées chaque année (âge, diplôme requis, dossier, dates).', 'Oui, les examens officiels acceptent des candidats libres, sous réserve des conditions fixées chaque année (âge, diplôme requis, dossier, dates).

- Les inscriptions se font selon le calendrier de l''OBC (Bac) ou du GCE Board (GCE).
- Les dates, les frais et le nombre de places changent chaque année : seul le **communiqué officiel** fait foi.', ARRAY[]::text[], ARRAY[]::text[], ARRAY['candidat libre', 'inscription', 'bac', 'gce']::text[], '[{"titre":"Office du Baccalauréat du Cameroun (OBC) — Probatoire, Baccalauréat, BT","url":"https://www.obc.cm"},{"titre":"Cameroon GCE Board — GCE O Level / A Level","url":"https://www.camgceb.org"}]'::jsonb),
('faq-preparer-bac', 'faq', 'Comment bien préparer le Baccalauréat ?', 'Examens officiels', NULL, 'Commence tôt, travaille avec les **annales**, fais des épreuves en temps limité et corrige tes erreurs avec méthode.', 'Commence tôt, travaille avec les **annales**, fais des épreuves en temps limité et corrige tes erreurs avec méthode.

- Fais un planning hebdomadaire : les matières à fort coefficient d''abord.
- Refais les sujets des années précédentes et chronomètre-toi.
- Sur Mandal : cours, épreuves blanches générées par Mandal IA, correction de copie par photo.
- Dors suffisamment avant l''examen.', ARRAY[]::text[], ARRAY[]::text[], ARRAY['préparer', 'révision', 'annales', 'méthode', 'bac']::text[], '[{"titre":"Office du Baccalauréat du Cameroun (OBC) — Probatoire, Baccalauréat, BT","url":"https://www.obc.cm"},{"titre":"Ministère des Enseignements Secondaires (MINESEC)","url":"https://www.minesec.gov.cm"}]'::jsonb),
('faq-coefficients', 'faq', 'Comment connaître les coefficients de ma série ?', 'Examens officiels', NULL, 'Les coefficients sont fixés par les textes officiels de chaque examen ; ton établissement (censeur, professeurs) peut te les communiquer.', 'Les coefficients sont fixés par les textes officiels de chaque examen ; ton établissement (censeur, professeurs) peut te les communiquer.

- Concentre tes efforts sur les matières à fort coefficient de ta série sans abandonner les autres.
- Pour le Bac, référence : OBC ; pour BEPC/Probatoire : MINESEC.', ARRAY[]::text[], ARRAY[]::text[], ARRAY['coefficients', 'notes', 'moyenne', 'série']::text[], '[{"titre":"Office du Baccalauréat du Cameroun (OBC) — Probatoire, Baccalauréat, BT","url":"https://www.obc.cm"},{"titre":"Ministère des Enseignements Secondaires (MINESEC)","url":"https://www.minesec.gov.cm"}]'::jsonb),
('faq-equivalence-diplome', 'faq', 'Comment faire reconnaître un diplôme obtenu à l''étranger ?', 'Examens officiels', NULL, 'La reconnaissance des diplômes de l''enseignement supérieur se fait auprès du **MINESUP** (équivalences) ; pour les diplômes du secondaire, renseigne-toi auprès du MINESEC.', 'La reconnaissance des diplômes de l''enseignement supérieur se fait auprès du **MINESUP** (équivalences) ; pour les diplômes du secondaire, renseigne-toi auprès du MINESEC.

- Prépare les originaux, les relevés de notes et les traductions certifiées si nécessaire.', ARRAY[]::text[], ARRAY[]::text[], ARRAY['équivalence', 'diplôme étranger', 'reconnaissance']::text[], '[{"titre":"Ministère de l''Enseignement Supérieur (MINESUP) — concours, BTS/HND, établissements","url":"https://www.minesup.gov.cm"},{"titre":"Ministère des Enseignements Secondaires (MINESEC)","url":"https://www.minesec.gov.cm"}]'::jsonb),
('faq-inscription-universite', 'faq', 'Comment s''inscrire dans une université d''État ?', 'Université', NULL, 'Dans les facultés classiques, l''inscription se fait après le Bac ou le GCE A Level, en général sur étude de dossier ; les écoles et instituts (ENSP, IUT, ENS, FMSB…) recrutent sur **concours**.', 'Dans les facultés classiques, l''inscription se fait après le Bac ou le GCE A Level, en général sur étude de dossier ; les écoles et instituts (ENSP, IUT, ENS, FMSB…) recrutent sur **concours**.

- Suis les communiqués de l''université choisie et du MINESUP.
- Prépare : diplôme ou attestation de réussite, relevé de notes, acte de naissance, photos.
- Les dates, les frais et le nombre de places changent chaque année : seul le **communiqué officiel** fait foi.', ARRAY[]::text[], ARRAY[]::text[], ARRAY['inscription', 'université', 'faculté', 'préinscription', 'dossier']::text[], '[{"titre":"Ministère de l''Enseignement Supérieur (MINESUP) — concours, BTS/HND, établissements","url":"https://www.minesup.gov.cm"},{"titre":"Université de Yaoundé I (ENSP, ENS, FMSB, Faculté des Sciences)","url":"http://www.uy1.uninet.cm"}]'::jsonb),
('faq-liste-universites', 'faq', 'Quelles sont les universités d''État du Cameroun ?', 'Université', NULL, 'Le Cameroun compte **11 universités d''État** : Yaoundé I, Yaoundé II-Soa, Douala, Dschang, Buea, Ngaoundéré, Maroua, Bamenda, et depuis 2022 Bertoua, Ebolowa et Garoua.', 'Le Cameroun compte **11 universités d''État** : Yaoundé I, Yaoundé II-Soa, Douala, Dschang, Buea, Ngaoundéré, Maroua, Bamenda, et depuis 2022 Bertoua, Ebolowa et Garoua.

- Buea et Bamenda sont de tradition anglo-saxonne.
- Il existe aussi de nombreux établissements privés (IPES) agréés par le MINESUP.', ARRAY[]::text[], ARRAY[]::text[], ARRAY['universités d''état', 'liste', 'bertoua', 'ebolowa', 'garoua', 'université publique']::text[], '[{"titre":"Ministère de l''Enseignement Supérieur (MINESUP) — concours, BTS/HND, établissements","url":"https://www.minesup.gov.cm"},{"titre":"Loi n°2023/007 du 25 juillet 2023 portant orientation de l''enseignement supérieur au Cameroun"}]'::jsonb),
('faq-lmd', 'faq', 'Qu''est-ce que le système LMD ?', 'Université', NULL, '**LMD** signifie Licence (3 ans), Master (2 ans), Doctorat (environ 3 ans). Les études sont organisées en semestres et en **crédits**.', '**LMD** signifie Licence (3 ans), Master (2 ans), Doctorat (environ 3 ans). Les études sont organisées en semestres et en **crédits**.

- Une licence correspond à 180 crédits, un master à 120 crédits de plus.
- Les crédits acquis restent acquis, ce qui facilite la mobilité entre établissements.', ARRAY[]::text[], ARRAY[]::text[], ARRAY['lmd', 'licence', 'master', 'doctorat', 'crédits', 'semestre']::text[], '[{"titre":"Ministère de l''Enseignement Supérieur (MINESUP) — concours, BTS/HND, établissements","url":"https://www.minesup.gov.cm"},{"titre":"Loi n°2023/007 du 25 juillet 2023 portant orientation de l''enseignement supérieur au Cameroun"}]'::jsonb),
('faq-universite-privee', 'faq', 'Les universités et instituts privés sont-ils reconnus ?', 'Université', NULL, 'Seuls les établissements **agréés par le MINESUP** délivrent des diplômes reconnus (souvent sous tutelle académique d''une université d''État).', 'Seuls les établissements **agréés par le MINESUP** délivrent des diplômes reconnus (souvent sous tutelle académique d''une université d''État).

- Avant de payer, demande le numéro d''arrêté d''agrément et vérifie auprès du MINESUP.
- Vérifie que la filière précise que tu vises est bien autorisée.', ARRAY[]::text[], ARRAY[]::text[], ARRAY['privé', 'ipes', 'agrément', 'reconnu', 'université privée']::text[], '[{"titre":"Ministère de l''Enseignement Supérieur (MINESUP) — concours, BTS/HND, établissements","url":"https://www.minesup.gov.cm"}]'::jsonb),
('faq-bourses-etudes', 'faq', 'Comment obtenir une bourse d''études ?', 'Université', NULL, 'Les bourses (excellence, coopération internationale, organismes privés) sont annoncées par **communiqué officiel**, notamment par le MINESUP et les ambassades.', 'Les bourses (excellence, coopération internationale, organismes privés) sont annoncées par **communiqué officiel**, notamment par le MINESUP et les ambassades.

- Garde d''excellents résultats : la plupart des bourses sont au mérite.
- Prépare à l''avance : relevés, lettres de recommandation, lettre de motivation.
- Ne paie jamais un intermédiaire qui « garantit » une bourse.', ARRAY[]::text[], ARRAY[]::text[], ARRAY['bourse', 'aide', 'financement', 'excellence', 'étudier']::text[], '[{"titre":"Ministère de l''Enseignement Supérieur (MINESUP) — concours, BTS/HND, établissements","url":"https://www.minesup.gov.cm"}]'::jsonb),
('faq-etudier-etranger', 'faq', 'Comment étudier à l''étranger après le Bac ?', 'Université', NULL, 'Prépare ton projet un an à l''avance : choix du pays et de l''établissement, admission, financement, puis visa.', 'Prépare ton projet un an à l''avance : choix du pays et de l''établissement, admission, financement, puis visa.

- Vérifie la reconnaissance du diplôme visé au retour (équivalences MINESUP).
- Compare avec les formations locales : beaucoup de filières de qualité existent au Cameroun à moindre coût.
- Méfie-toi des agences qui promettent un visa garanti.', ARRAY[]::text[], ARRAY[]::text[], ARRAY['étranger', 'visa', 'campus', 'partir étudier']::text[], '[{"titre":"Ministère de l''Enseignement Supérieur (MINESUP) — concours, BTS/HND, établissements","url":"https://www.minesup.gov.cm"}]'::jsonb),
('faq-reorientation-universite', 'faq', 'Je me suis trompé de filière à l''université : puis-je me réorienter ?', 'Université', NULL, 'Oui. Grâce au système LMD, certains crédits peuvent être reconnus ; tu peux aussi présenter des concours (IUT, écoles) ou passer en BTS/HND.', 'Oui. Grâce au système LMD, certains crédits peuvent être reconnus ; tu peux aussi présenter des concours (IUT, écoles) ou passer en BTS/HND.

- Parle aux responsables pédagogiques de ta faculté.
- Réfléchis à ce qui te plaît vraiment avant de changer une seconde fois.', ARRAY[]::text[], ARRAY[]::text[], ARRAY['réorientation', 'changer de filière', 'université', 'crédits']::text[], '[{"titre":"Ministère de l''Enseignement Supérieur (MINESUP) — concours, BTS/HND, établissements","url":"https://www.minesup.gov.cm"}]'::jsonb),
('faq-concours-apres-bac', 'faq', 'Quels concours peut-on passer après le Bac ?', 'Concours', NULL, 'Après le Bac ou le A Level : écoles d''ingénieurs (ENSP, ENSPD, ENSTP…), IUT, ENS et ENSET (1er cycle), facultés de médecine, ENSAI, FASA, ESSEC, écoles militaires (EMIA), écoles paramédicales, et d''autres selon ta série.', 'Après le Bac ou le A Level : écoles d''ingénieurs (ENSP, ENSPD, ENSTP…), IUT, ENS et ENSET (1er cycle), facultés de médecine, ENSAI, FASA, ESSEC, écoles militaires (EMIA), écoles paramédicales, et d''autres selon ta série.

- Chaque concours a ses séries admises et ses épreuves.
- Les dates, les frais et le nombre de places changent chaque année : seul le **communiqué officiel** fait foi.', ARRAY[]::text[], ARRAY[]::text[], ARRAY['concours', 'après le bac', 'grandes écoles', 'ensp', 'ens', 'iut']::text[], '[{"titre":"Ministère de l''Enseignement Supérieur (MINESUP) — concours, BTS/HND, établissements","url":"https://www.minesup.gov.cm"},{"titre":"Université de Yaoundé I (ENSP, ENS, FMSB, Faculté des Sciences)","url":"http://www.uy1.uninet.cm"},{"titre":"Université de Douala (ENSPD, ENSET, IUT, FMSP, ESSEC)"}]'::jsonb),
('faq-concours-apres-licence', 'faq', 'Quels concours peut-on passer après une Licence ?', 'Concours', NULL, 'Après une licence : ENAM (administration, magistrature, régies financières), IRIC, ASTI, ENS 2nd cycle, ESSTIC (certains cycles), concours de la fonction publique et masters sélectifs.', 'Après une licence : ENAM (administration, magistrature, régies financières), IRIC, ASTI, ENS 2nd cycle, ESSTIC (certains cycles), concours de la fonction publique et masters sélectifs.

- Vérifie les spécialités de licence admises pour chaque concours.
- Les dates, les frais et le nombre de places changent chaque année : seul le **communiqué officiel** fait foi.', ARRAY[]::text[], ARRAY[]::text[], ARRAY['concours', 'après licence', 'enam', 'iric', 'asti', 'fonction publique']::text[], '[{"titre":"École Nationale d''Administration et de Magistrature (ENAM)","url":"https://www.enam.cm"},{"titre":"Plateforme des concours de l''ENAM","url":"https://concours.enam.cm"},{"titre":"Ministère de l''Enseignement Supérieur (MINESUP) — concours, BTS/HND, établissements","url":"https://www.minesup.gov.cm"}]'::jsonb),
('faq-communique-concours', 'faq', 'Où trouver les communiqués officiels des concours ?', 'Concours', NULL, 'Les concours de l''enseignement supérieur sont annoncés par le **MINESUP** et par les établissements eux-mêmes ; l''ENAM publie les siens sur sa plateforme de concours.', 'Les concours de l''enseignement supérieur sont annoncés par le **MINESUP** et par les établissements eux-mêmes ; l''ENAM publie les siens sur sa plateforme de concours.

- Les autres ministères (Défense, Santé, Sûreté nationale…) publient les leurs.
- Garde une copie du communiqué : il précise les pièces, les dates et les centres.', ARRAY[]::text[], ARRAY[]::text[], ARRAY['communiqué', 'concours', 'date', 'inscription', 'arrêté']::text[], '[{"titre":"Ministère de l''Enseignement Supérieur (MINESUP) — concours, BTS/HND, établissements","url":"https://www.minesup.gov.cm"},{"titre":"Plateforme des concours de l''ENAM","url":"https://concours.enam.cm"},{"titre":"Ministère de la Défense (MINDEF) — EMIA et recrutements des forces de défense"},{"titre":"Délégation Générale à la Sûreté Nationale (DGSN) — concours de la police"},{"titre":"Ministère de la Santé Publique (MINSANTE) — écoles de formation paramédicale"}]'::jsonb),
('faq-arnaque-concours', 'faq', 'On me propose de payer pour réussir un concours : est-ce sérieux ?', 'Concours', NULL, '**Non.** Aucune place dans un concours officiel ne s''achète : c''est une arnaque et une infraction. Les seuls frais sont ceux indiqués dans le communiqué officiel.', '**Non.** Aucune place dans un concours officiel ne s''achète : c''est une arnaque et une infraction. Les seuls frais sont ceux indiqués dans le communiqué officiel.

- Ne transmets jamais d''argent à un « intermédiaire ».
- Signale ces propositions aux autorités compétentes.
- Investis plutôt ton énergie dans la préparation : annales, épreuves blanches, travail régulier.', ARRAY[]::text[], ARRAY[]::text[], ARRAY['arnaque', 'corruption', 'payer concours', 'réseau', 'fraude']::text[], '[{"titre":"Ministère de l''Enseignement Supérieur (MINESUP) — concours, BTS/HND, établissements","url":"https://www.minesup.gov.cm"},{"titre":"Ministère de la Défense (MINDEF) — EMIA et recrutements des forces de défense"},{"titre":"Délégation Générale à la Sûreté Nationale (DGSN) — concours de la police"}]'::jsonb),
('faq-preparer-concours', 'faq', 'Comment préparer un concours d''entrée en grande école ?', 'Concours', NULL, 'Procure-toi les **annales**, identifie les matières et coefficients du concours, et entraîne-toi en temps réel plusieurs semaines avant.', 'Procure-toi les **annales**, identifie les matières et coefficients du concours, et entraîne-toi en temps réel plusieurs semaines avant.

- Révise le programme de Terminale en profondeur.
- Pour les concours scientifiques, la vitesse en calcul est décisive.
- Travaille aussi la culture générale si elle est au programme.
- Les épreuves blanches de Mandal t''aident à t''entraîner.', ARRAY[]::text[], ARRAY[]::text[], ARRAY['préparer concours', 'annales', 'méthode', 'grande école']::text[], '[{"titre":"Ministère de l''Enseignement Supérieur (MINESUP) — concours, BTS/HND, établissements","url":"https://www.minesup.gov.cm"}]'::jsonb),
('faq-enspd-ensp', 'faq', 'Quelle différence entre l''ENSP Yaoundé et l''ENSPD Douala ?', 'Concours', NULL, 'Ce sont deux **écoles publiques d''ingénieurs** : l''ENSP dépend de l''Université de Yaoundé I, l''ENSPD de l''Université de Douala. Elles recrutent sur concours et proposent plusieurs spécialités.', 'Ce sont deux **écoles publiques d''ingénieurs** : l''ENSP dépend de l''Université de Yaoundé I, l''ENSPD de l''Université de Douala. Elles recrutent sur concours et proposent plusieurs spécialités.

- Compare les spécialités offertes (génie civil, électrique, informatique, télécoms, industriel…).
- Il existe aussi des écoles d''ingénieurs à Maroua, Ngaoundéré, Bamenda et ailleurs.', ARRAY[]::text[], ARRAY[]::text[], ARRAY['ensp', 'enspd', 'polytechnique', 'ingénieur', 'école d''ingénieurs']::text[], '[{"titre":"Université de Yaoundé I (ENSP, ENS, FMSB, Faculté des Sciences)","url":"http://www.uy1.uninet.cm"},{"titre":"Université de Douala (ENSPD, ENSET, IUT, FMSP, ESSEC)"},{"titre":"Ministère de l''Enseignement Supérieur (MINESUP) — concours, BTS/HND, établissements","url":"https://www.minesup.gov.cm"}]'::jsonb),
('faq-concours-medecine', 'faq', 'Comment réussir le concours de médecine ?', 'Concours', NULL, 'Le concours de médecine est très sélectif : un excellent niveau en **SVT, chimie, physique** et souvent en culture générale ou en français est indispensable.', 'Le concours de médecine est très sélectif : un excellent niveau en **SVT, chimie, physique** et souvent en culture générale ou en français est indispensable.

- Entraîne-toi avec les annales dès la Terminale.
- Inscris-toi à plusieurs concours (facultés publiques, paramédical) pour multiplier tes chances.
- Les dates, les frais et le nombre de places changent chaque année : seul le **communiqué officiel** fait foi.', ARRAY[]::text[], ARRAY[]::text[], ARRAY['médecine', 'concours médecine', 'fmsb', 'fmsp', 'santé']::text[], '[{"titre":"Ministère de l''Enseignement Supérieur (MINESUP) — concours, BTS/HND, établissements","url":"https://www.minesup.gov.cm"},{"titre":"Université de Yaoundé I (ENSP, ENS, FMSB, Faculté des Sciences)","url":"http://www.uy1.uninet.cm"},{"titre":"Ministère de la Santé Publique (MINSANTE) — écoles de formation paramédicale"}]'::jsonb),
('faq-concours-ens', 'faq', 'Comment devenir enseignant par le concours de l''ENS ?', 'Concours', NULL, 'L''ENS recrute au **1er cycle** (après le Bac) et au **2nd cycle** (après la Licence) ; l''ENSET forme les enseignants du technique.', 'L''ENS recrute au **1er cycle** (après le Bac) et au **2nd cycle** (après la Licence) ; l''ENSET forme les enseignants du technique.

- Choisis la section correspondant à la matière que tu veux enseigner.
- Les dates, les frais et le nombre de places changent chaque année : seul le **communiqué officiel** fait foi.', ARRAY[]::text[], ARRAY[]::text[], ARRAY['ens', 'enset', 'enseignant', 'professeur', 'concours']::text[], '[{"titre":"Ministère de l''Enseignement Supérieur (MINESUP) — concours, BTS/HND, établissements","url":"https://www.minesup.gov.cm"},{"titre":"Université de Yaoundé I (ENSP, ENS, FMSB, Faculté des Sciences)","url":"http://www.uy1.uninet.cm"},{"titre":"Ministère des Enseignements Secondaires (MINESEC)","url":"https://www.minesec.gov.cm"}]'::jsonb),
('faq-concours-enam', 'faq', 'Comment s''inscrire au concours de l''ENAM ?', 'Concours', NULL, 'L''inscription au concours de l''ENAM se fait en ligne sur la **plateforme des concours de l''ENAM**, selon les conditions de chaque division (administration, magistrature, régies financières…).', 'L''inscription au concours de l''ENAM se fait en ligne sur la **plateforme des concours de l''ENAM**, selon les conditions de chaque division (administration, magistrature, régies financières…).

- Vérifie le diplôme exigé (Bac, Licence, Master selon le cycle) et la limite d''âge.
- Les dates, les frais et le nombre de places changent chaque année : seul le **communiqué officiel** fait foi.', ARRAY[]::text[], ARRAY[]::text[], ARRAY['enam', 'inscription', 'administration', 'magistrature', 'régies financières']::text[], '[{"titre":"École Nationale d''Administration et de Magistrature (ENAM)","url":"https://www.enam.cm"},{"titre":"Plateforme des concours de l''ENAM","url":"https://concours.enam.cm"}]'::jsonb),
('faq-concours-armee', 'faq', 'Comment entrer dans l''armée (EMIA, sous-officiers, soldats) ?', 'Concours', NULL, 'Les recrutements des forces de défense sont annoncés par le **MINDEF** : EMIA pour les officiers, et campagnes de recrutement pour les sous-officiers et militaires du rang.', 'Les recrutements des forces de défense sont annoncés par le **MINDEF** : EMIA pour les officiers, et campagnes de recrutement pour les sous-officiers et militaires du rang.

- Une bonne condition physique et un dossier médical sont exigés.
- Seuls les communiqués du MINDEF font foi : méfie-toi des faux recruteurs.', ARRAY[]::text[], ARRAY[]::text[], ARRAY['armée', 'emia', 'militaire', 'recrutement', 'soldat', 'défense']::text[], '[{"titre":"Ministère de la Défense (MINDEF) — EMIA et recrutements des forces de défense"}]'::jsonb),
('faq-concours-police', 'faq', 'Comment devenir policier au Cameroun ?', 'Concours', NULL, 'La **DGSN** organise des concours selon le diplôme : gardiens de la paix, inspecteurs, officiers de police, commissaires.', 'La **DGSN** organise des concours selon le diplôme : gardiens de la paix, inspecteurs, officiers de police, commissaires.

- Prépare l''écrit et l''épreuve sportive.
- Les dates, les frais et le nombre de places changent chaque année : seul le **communiqué officiel** fait foi.', ARRAY[]::text[], ARRAY[]::text[], ARRAY['police', 'dgsn', 'policier', 'concours police']::text[], '[{"titre":"Délégation Générale à la Sûreté Nationale (DGSN) — concours de la police"}]'::jsonb),
('faq-concours-paramedical', 'faq', 'Comment devenir infirmier ou technicien de santé ?', 'Concours', NULL, 'Par les **concours des écoles publiques de formation paramédicale** (MINSANTE, universités) ou par un BTS/HND santé dans un institut privé agréé.', 'Par les **concours des écoles publiques de formation paramédicale** (MINSANTE, universités) ou par un BTS/HND santé dans un institut privé agréé.

- Vérifie l''agrément de l''école avant tout paiement.
- Les séries D, C et F7 sont les plus adaptées.', ARRAY[]::text[], ARRAY[]::text[], ARRAY['infirmier', 'paramédical', 'santé', 'école de santé']::text[], '[{"titre":"Ministère de la Santé Publique (MINSANTE) — écoles de formation paramédicale"},{"titre":"Ministère de l''Enseignement Supérieur (MINESUP) — concours, BTS/HND, établissements","url":"https://www.minesup.gov.cm"}]'::jsonb),
('faq-concours-iut', 'faq', 'Comment entrer dans un IUT ?', 'Concours', NULL, 'Les **IUT** (Douala, Bandjoun/Dschang, Ngaoundéré…) recrutent sur concours ou étude de dossier après le Bac, pour des formations courtes et professionnelles (DUT, licences professionnelles).', 'Les **IUT** (Douala, Bandjoun/Dschang, Ngaoundéré…) recrutent sur concours ou étude de dossier après le Bac, pour des formations courtes et professionnelles (DUT, licences professionnelles).

- Les spécialités : génie civil, électrique, mécanique, informatique, gestion, génie biologique…
- Les dates, les frais et le nombre de places changent chaque année : seul le **communiqué officiel** fait foi.', ARRAY[]::text[], ARRAY[]::text[], ARRAY['iut', 'dut', 'technologie', 'concours iut']::text[], '[{"titre":"Université de Douala (ENSPD, ENSET, IUT, FMSP, ESSEC)"},{"titre":"Université de Dschang (FASA, IUT Fotso Victor de Bandjoun)"},{"titre":"Université de Ngaoundéré (ENSAI, IUT, EGCIM)"},{"titre":"Ministère de l''Enseignement Supérieur (MINESUP) — concours, BTS/HND, établissements","url":"https://www.minesup.gov.cm"}]'::jsonb),
('faq-bts-hnd', 'faq', 'Qu''est-ce que le BTS et le HND ?', 'BTS, HND et formation professionnelle', NULL, 'Le **BTS** (francophone) et le **HND** (anglophone) sont des diplômes de l''enseignement supérieur en 2 ans, préparés dans des instituts agréés et sanctionnés par un **examen national du MINESUP**.', 'Le **BTS** (francophone) et le **HND** (anglophone) sont des diplômes de l''enseignement supérieur en 2 ans, préparés dans des instituts agréés et sanctionnés par un **examen national du MINESUP**.

- Ils mènent directement à l''emploi ou à une licence professionnelle.
- Vérifie que l''institut et la spécialité sont agréés.', ARRAY[]::text[], ARRAY[]::text[], ARRAY['bts', 'hnd', 'brevet de technicien supérieur', 'higher national diploma']::text[], '[{"titre":"Ministère de l''Enseignement Supérieur (MINESUP) — concours, BTS/HND, établissements","url":"https://www.minesup.gov.cm"}]'::jsonb),
('faq-formation-professionnelle', 'faq', 'Je veux apprendre un métier rapidement : quelles options ?', 'BTS, HND et formation professionnelle', NULL, 'La **formation professionnelle** (centres publics et privés agréés par le MINEFOP) forme en quelques mois à quelques années à des métiers pratiques.', 'La **formation professionnelle** (centres publics et privés agréés par le MINEFOP) forme en quelques mois à quelques années à des métiers pratiques.

- Exemples : électricité, solaire, couture, coiffure, mécanique, informatique, hôtellerie, agriculture, BTP.
- Le FNE accompagne vers l''emploi et l''auto-emploi.', ARRAY[]::text[], ARRAY[]::text[], ARRAY['formation professionnelle', 'métier', 'centre de formation', 'apprentissage']::text[], '[{"titre":"Ministère de l''Emploi et de la Formation Professionnelle (MINEFOP) — centres de formation agréés, bourses"},{"titre":"Fonds National de l''Emploi (FNE) — accompagnement vers l''emploi et l''auto-emploi"}]'::jsonb),
('faq-sans-bac', 'faq', 'Peut-on réussir sans le Baccalauréat ?', 'BTS, HND et formation professionnelle', NULL, 'Oui. Beaucoup de métiers s''apprennent par la **formation professionnelle** et l''**apprentissage** : artisanat, BTP, mécanique, couture, agriculture, services.', 'Oui. Beaucoup de métiers s''apprennent par la **formation professionnelle** et l''**apprentissage** : artisanat, BTP, mécanique, couture, agriculture, services.

- Le CAP ou un certificat professionnel donne une vraie qualification.
- Tu pourras toujours reprendre tes études plus tard (candidat libre).
- L''auto-emploi demande aussi des compétences en gestion.', ARRAY[]::text[], ARRAY[]::text[], ARRAY['sans bac', 'pas de bac', 'réussir', 'métier', 'apprentissage']::text[], '[{"titre":"Ministère de l''Emploi et de la Formation Professionnelle (MINEFOP) — centres de formation agréés, bourses"},{"titre":"Fonds National de l''Emploi (FNE) — accompagnement vers l''emploi et l''auto-emploi"}]'::jsonb),
('faq-fne', 'faq', 'Que fait le Fonds National de l''Emploi (FNE) ?', 'BTS, HND et formation professionnelle', NULL, 'Le **FNE** aide les demandeurs d''emploi : inscription, orientation, mise en relation avec les employeurs, formations et appui aux projets d''auto-emploi.', 'Le **FNE** aide les demandeurs d''emploi : inscription, orientation, mise en relation avec les employeurs, formations et appui aux projets d''auto-emploi.

- Rends-toi dans une agence du FNE avec ton CV et tes diplômes.', ARRAY[]::text[], ARRAY[]::text[], ARRAY['fne', 'emploi', 'chômage', 'auto-emploi', 'insertion']::text[], '[{"titre":"Fonds National de l''Emploi (FNE) — accompagnement vers l''emploi et l''auto-emploi"},{"titre":"Ministère de l''Emploi et de la Formation Professionnelle (MINEFOP) — centres de formation agréés, bourses"}]'::jsonb),
('faq-metiers-porteurs', 'faq', 'Quels sont les métiers porteurs au Cameroun ?', 'Métiers & emploi', NULL, 'Parmi les secteurs qui recrutent : **numérique**, **santé**, **BTP et infrastructures**, **agriculture et agro-industrie**, **énergie (notamment solaire)**, **logistique** autour des ports de Douala et Kribi, et l''**enseignement**.', 'Parmi les secteurs qui recrutent : **numérique**, **santé**, **BTP et infrastructures**, **agriculture et agro-industrie**, **énergie (notamment solaire)**, **logistique** autour des ports de Douala et Kribi, et l''**enseignement**.

- Le meilleur métier pour toi combine tes talents, ce que tu aimes et ce dont le marché a besoin.
- Les données sur l''emploi sont publiées par l''INS.', ARRAY[]::text[], ARRAY[]::text[], ARRAY['métiers porteurs', 'avenir', 'emploi', 'secteurs', 'recrutent']::text[], '[{"titre":"Institut National de la Statistique (INS) — annuaires et enquêtes","url":"https://ins-cameroun.cm"},{"titre":"Ministère de l''Emploi et de la Formation Professionnelle (MINEFOP) — centres de formation agréés, bourses"}]'::jsonb),
('faq-choisir-metier', 'faq', 'Comment choisir mon futur métier ?', 'Métiers & emploi', NULL, 'Pars de trois questions : **qu''est-ce que j''aime faire ? dans quoi suis-je bon ? de quoi la société a-t-elle besoin ?** Puis renseigne-toi sur les études nécessaires.', 'Pars de trois questions : **qu''est-ce que j''aime faire ? dans quoi suis-je bon ? de quoi la société a-t-elle besoin ?** Puis renseigne-toi sur les études nécessaires.

- Discute avec des professionnels du métier visé.
- Fais un stage ou une observation si possible.
- Consulte le conseiller d''orientation de ton établissement.', ARRAY[]::text[], ARRAY[]::text[], ARRAY['choisir métier', 'orientation', 'projet professionnel', 'passion']::text[], '[{"titre":"Conseiller d''orientation de ton établissement (service d''orientation scolaire)"}]'::jsonb),
('faq-metier-informatique', 'faq', 'Comment travailler dans l''informatique au Cameroun ?', 'Métiers & emploi', NULL, 'Plusieurs voies : licence d''informatique, IUT, écoles d''ingénieurs, BTS/HND, ou autoformation sérieuse avec un **portfolio de projets**.', 'Plusieurs voies : licence d''informatique, IUT, écoles d''ingénieurs, BTS/HND, ou autoformation sérieuse avec un **portfolio de projets**.

- Métiers : développeur, administrateur réseaux, cybersécurité, analyste de données, designer d''interfaces.
- Les start-ups, banques et télécoms recrutent ; le freelance international est possible.', ARRAY[]::text[], ARRAY[]::text[], ARRAY['informatique', 'développeur', 'programmation', 'numérique', 'tech']::text[], '[{"titre":"Ministère de l''Enseignement Supérieur (MINESUP) — concours, BTS/HND, établissements","url":"https://www.minesup.gov.cm"},{"titre":"Ministère des Postes et Télécommunications (MINPOSTEL)"}]'::jsonb),
('faq-metier-agriculture', 'faq', 'L''agriculture est-elle un bon choix de carrière ?', 'Métiers & emploi', NULL, 'Oui, surtout si tu la vois comme une **entreprise** : production, transformation et vente (agrobusiness). Elle nourrit le pays et emploie une très grande partie des actifs.', 'Oui, surtout si tu la vois comme une **entreprise** : production, transformation et vente (agrobusiness). Elle nourrit le pays et emploie une très grande partie des actifs.

- Formations : FASA (Dschang), ENSAI (Ngaoundéré), écoles du MINADER, BTS/HND, formations courtes.
- Filières : cacao, café, maïs, manioc, maraîchage, aviculture, pisciculture.', ARRAY[]::text[], ARRAY[]::text[], ARRAY['agriculture', 'agrobusiness', 'élevage', 'agronome', 'ferme']::text[], '[{"titre":"Ministère de l''Agriculture et du Développement Rural (MINADER)"},{"titre":"Ministère de l''Élevage, des Pêches et des Industries Animales (MINEPIA)"},{"titre":"Université de Dschang (FASA, IUT Fotso Victor de Bandjoun)"}]'::jsonb),
('faq-fonction-publique', 'faq', 'Comment entrer dans la fonction publique ?', 'Métiers & emploi', NULL, 'Principalement par **concours** (ENAM, ENS, écoles de santé, police, armée…) ou par les recrutements spéciaux annoncés officiellement.', 'Principalement par **concours** (ENAM, ENS, écoles de santé, police, armée…) ou par les recrutements spéciaux annoncés officiellement.

- Chaque concours précise le diplôme, l''âge et les pièces requises.
- Les dates, les frais et le nombre de places changent chaque année : seul le **communiqué officiel** fait foi.', ARRAY[]::text[], ARRAY[]::text[], ARRAY['fonction publique', 'fonctionnaire', 'concours administratifs', 'état']::text[], '[{"titre":"École Nationale d''Administration et de Magistrature (ENAM)","url":"https://www.enam.cm"},{"titre":"Ministère de l''Enseignement Supérieur (MINESUP) — concours, BTS/HND, établissements","url":"https://www.minesup.gov.cm"}]'::jsonb),
('faq-creer-entreprise', 'faq', 'Je veux créer mon entreprise après mes études : par où commencer ?', 'Métiers & emploi', NULL, 'Commence par une idée qui répond à un vrai besoin, teste-la à petite échelle, tiens une comptabilité dès le départ et formalise ton activité.', 'Commence par une idée qui répond à un vrai besoin, teste-la à petite échelle, tiens une comptabilité dès le départ et formalise ton activité.

- Formations à l''entrepreneuriat, incubateurs universitaires, accompagnement du FNE.
- Apprends les bases : gestion, marketing, fiscalité.', ARRAY[]::text[], ARRAY[]::text[], ARRAY['entreprise', 'entrepreneuriat', 'startup', 'business', 'auto-emploi']::text[], '[{"titre":"Fonds National de l''Emploi (FNE) — accompagnement vers l''emploi et l''auto-emploi"},{"titre":"Ministère de l''Emploi et de la Formation Professionnelle (MINEFOP) — centres de formation agréés, bourses"}]'::jsonb),
('faq-stage', 'faq', 'Comment trouver un stage ?', 'Métiers & emploi', NULL, 'Prépare un CV clair et une lettre de motivation, puis démarche directement les entreprises, les administrations et les ONG ; utilise aussi le réseau de ton école.', 'Prépare un CV clair et une lettre de motivation, puis démarche directement les entreprises, les administrations et les ONG ; utilise aussi le réseau de ton école.

- Commence tôt (plusieurs mois avant).
- Un stage bien fait se transforme souvent en premier emploi.', ARRAY[]::text[], ARRAY[]::text[], ARRAY['stage', 'cv', 'lettre de motivation', 'entreprise', 'expérience']::text[], '[{"titre":"Fonds National de l''Emploi (FNE) — accompagnement vers l''emploi et l''auto-emploi"}]'::jsonb),
('faq-methode-travail', 'faq', 'Comment mieux réviser et retenir mes cours ?', 'Méthode de travail', NULL, 'Révise un peu **chaque jour**, reformule avec tes mots, fais des fiches et surtout **entraîne-toi sur des exercices**.', 'Révise un peu **chaque jour**, reformule avec tes mots, fais des fiches et surtout **entraîne-toi sur des exercices**.

- Technique utile : relire le cours le soir même, puis 3 jours et 1 semaine après.
- Explique la leçon à un camarade : si tu sais l''expliquer, tu la maîtrises.
- Pose tes questions à Mandal IA quand tu bloques.', ARRAY[]::text[], ARRAY[]::text[], ARRAY['réviser', 'mémoriser', 'méthode', 'apprendre', 'organisation']::text[], '[{"titre":"Conseiller d''orientation de ton établissement (service d''orientation scolaire)"}]'::jsonb),
('faq-gerer-stress', 'faq', 'Comment gérer le stress avant un examen ?', 'Méthode de travail', NULL, 'Prépare-toi régulièrement, dors suffisamment, mange bien et entraîne-toi en conditions réelles : le stress diminue quand on se sent prêt.', 'Prépare-toi régulièrement, dors suffisamment, mange bien et entraîne-toi en conditions réelles : le stress diminue quand on se sent prêt.

- Le jour J : arrive en avance, lis tout le sujet, commence par ce que tu maîtrises.
- Si l''anxiété est forte, parles-en au conseiller d''orientation ou à un adulte de confiance.', ARRAY[]::text[], ARRAY[]::text[], ARRAY['stress', 'anxiété', 'examen', 'peur', 'confiance']::text[], '[{"titre":"Conseiller d''orientation de ton établissement (service d''orientation scolaire)"}]'::jsonb),
('faq-mauvaises-notes', 'faq', 'J''ai de mauvaises notes en maths : suis-je fichu pour les sciences ?', 'Méthode de travail', NULL, 'Non. Les maths se rattrapent avec de la **régularité** : reprends les bases, fais beaucoup d''exercices corrigés et demande de l''aide tôt.', 'Non. Les maths se rattrapent avec de la **régularité** : reprends les bases, fais beaucoup d''exercices corrigés et demande de l''aide tôt.

- Identifie précisément les chapitres qui te posent problème.
- Travaille 30 minutes par jour plutôt que 5 heures la veille.
- Utilise les cours et la correction de copie de Mandal.', ARRAY[]::text[], ARRAY[]::text[], ARRAY['mauvaises notes', 'maths', 'difficultés', 'rattraper', 'échec scolaire']::text[], '[{"titre":"Conseiller d''orientation de ton établissement (service d''orientation scolaire)"}]'::jsonb),
('faq-apprendre-anglais', 'faq', 'Comment améliorer mon anglais (ou mon français) ?', 'Méthode de travail', NULL, 'Pratique **tous les jours** : lecture, écoute (radio, vidéos), écriture courte et conversation avec des camarades de l''autre sous-système.', 'Pratique **tous les jours** : lecture, écoute (radio, vidéos), écriture courte et conversation avec des camarades de l''autre sous-système.

- Le bilinguisme est un grand atout pour les concours (ENAM, IRIC, ASTI) et l''emploi au Cameroun.', ARRAY[]::text[], ARRAY[]::text[], ARRAY['anglais', 'français', 'bilinguisme', 'langue', 'améliorer']::text[], '[{"titre":"Conseiller d''orientation de ton établissement (service d''orientation scolaire)"}]'::jsonb),
('faq-parents-orientation', 'faq', 'Mes parents veulent que je fasse médecine mais je préfère autre chose : que faire ?', 'Méthode de travail', NULL, 'Parle-leur calmement de ton projet, avec des informations concrètes (études, débouchés, réussites dans ce domaine). Un projet réfléchi rassure les parents.', 'Parle-leur calmement de ton projet, avec des informations concrètes (études, débouchés, réussites dans ce domaine). Un projet réfléchi rassure les parents.

- Propose un rendez-vous commun avec le conseiller d''orientation.
- Montre tes résultats et ta motivation dans le domaine choisi.', ARRAY[]::text[], ARRAY[]::text[], ARRAY['parents', 'conflit', 'choix', 'pression familiale', 'projet']::text[], '[{"titre":"Conseiller d''orientation de ton établissement (service d''orientation scolaire)"}]'::jsonb),
('faq-conseiller-orientation', 'faq', 'À quoi sert le conseiller d''orientation de mon lycée ?', 'Méthode de travail', NULL, 'Il t''aide **gratuitement** à mieux te connaître, à choisir ta série ou ta filière et à préparer ton projet ; il peut aussi t''écouter en cas de difficultés.', 'Il t''aide **gratuitement** à mieux te connaître, à choisir ta série ou ta filière et à préparer ton projet ; il peut aussi t''écouter en cas de difficultés.

- Va le voir avec tes bulletins et tes questions.', ARRAY[]::text[], ARRAY[]::text[], ARRAY['conseiller d''orientation', 'lycée', 'aide', 'orientation']::text[], '[{"titre":"Ministère des Enseignements Secondaires (MINESEC)","url":"https://www.minesec.gov.cm"},{"titre":"Conseiller d''orientation de ton établissement (service d''orientation scolaire)"}]'::jsonb)
ON CONFLICT (slug) DO UPDATE SET
  type = EXCLUDED.type,
  titre = EXCLUDED.titre,
  categorie = EXCLUDED.categorie,
  niveau_acces = EXCLUDED.niveau_acces,
  resume = EXCLUDED.resume,
  contenu = EXCLUDED.contenu,
  debouches = EXCLUDED.debouches,
  formations = EXCLUDED.formations,
  mots_cles = EXCLUDED.mots_cles,
  sources = EXCLUDED.sources,
  mis_a_jour = current_date;
