-- ============================================================================
-- Contenu de la base d'orientation : 67 filières et établissements, 97 métiers, 111 questions fréquentes.
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
Les concours de médecine sont très sélectifs. Vise un très bon niveau en **SVT, chimie et physique** et prépare-toi tôt avec les annales.', ARRAY['Médecin', 'Pharmacien', 'Infirmier', 'Agronome', 'Biologiste', 'Vétérinaire']::text[], ARRAY['FMSB', 'FMSP Douala', 'FHS Buea', 'FASA Dschang', 'ENSAI', 'Écoles paramédicales']::text[], ARRAY['bac d', 'série d', 'svt', 'médecine', 'santé', 'biologie', 'agronomie']::text[], '[{"titre":"Office du Baccalauréat du Cameroun (OBC) — Probatoire, Baccalauréat, BT","url":"https://www.obc.cm"},{"titre":"Ministère de l''Enseignement Supérieur (MINESUP) — concours, BTS/HND, établissements","url":"https://www.minesup.gov.cm"},{"titre":"Université de Yaoundé I (ENSP, ENS, FMSB, Faculté des Sciences)","url":"http://www.uy1.uninet.cm"},{"titre":"Université de Dschang (FASA, IUT Fotso Victor de Bandjoun)","url":"https://www.univ-dschang.org"},{"titre":"University of Buea (Faculty of Health Sciences, ASTI, COT, faculties)","url":"https://www.ubuea.cm"},{"titre":"Université de Douala (ENSPD, ENSET, IUT, FMSP, ESSEC)","url":"https://www.univ-douala.cm"}]'::jsonb),
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
Au Cameroun, pays bilingue, **une très bonne maîtrise de l''anglais** est un vrai atout. Lis beaucoup et entraîne-toi à la dissertation.', ARRAY['Avocat', 'Journaliste', 'Enseignant de lettres', 'Traducteur', 'Diplomate', 'Administrateur civil']::text[], ARRAY['Facultés de droit', 'Facultés des lettres', 'ESSTIC', 'ENS', 'ENAM', 'IRIC']::text[], ARRAY['bac a', 'série a', 'littéraire', 'lettres', 'philosophie', 'langues', 'droit']::text[], '[{"titre":"Office du Baccalauréat du Cameroun (OBC) — Probatoire, Baccalauréat, BT","url":"https://www.obc.cm"},{"titre":"Ministère de l''Enseignement Supérieur (MINESUP) — concours, BTS/HND, établissements","url":"https://www.minesup.gov.cm"},{"titre":"Université de Yaoundé II-Soa (Droit, Économie, ESSTIC, IRIC)","url":"https://site.univ-yaounde2.org"},{"titre":"École Nationale d''Administration et de Magistrature (ENAM)","url":"https://www.enam.cm"}]'::jsonb),
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
Vérifie dans chaque communiqué de concours le **nombre de papers** et les **subjects exigés**.', ARRAY['Engineering', 'Medicine', 'Law', 'Business', 'Teaching']::text[], ARRAY['University of Buea', 'University of Bamenda', 'Grandes écoles (bilingual)']::text[], ARRAY['gce', 'a level', 'advanced level', 'upper sixth', 'anglophone', 'combination', 'papers']::text[], '[{"titre":"Cameroon GCE Board — GCE O Level / A Level","url":"https://www.camgceb.org"},{"titre":"Ministère de l''Enseignement Supérieur (MINESUP) — concours, BTS/HND, établissements","url":"https://www.minesup.gov.cm"},{"titre":"University of Buea (Faculty of Health Sciences, ASTI, COT, faculties)","url":"https://www.ubuea.cm"},{"titre":"The University of Bamenda (COLTECH, HTTTC, NAHPI)","url":"https://uniba.cm"}]'::jsonb),
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
Lis beaucoup, entraîne-toi à l''écrit et à l''oral, et apprends le **vocabulaire juridique dans les deux langues officielles**.', ARRAY['Avocat', 'Magistrat', 'Juriste d''entreprise', 'Huissier', 'Notaire', 'Diplomate']::text[], ARRAY['Facultés de sciences juridiques et politiques (Yaoundé II, Douala, Dschang, Buea…)', 'ENAM', 'IRIC']::text[], ARRAY['droit', 'juriste', 'avocat', 'magistrat', 'science politique', 'common law', 'faculté de droit']::text[], '[{"titre":"Ministère de l''Enseignement Supérieur (MINESUP) — concours, BTS/HND, établissements","url":"https://www.minesup.gov.cm"},{"titre":"Université de Yaoundé II-Soa (Droit, Économie, ESSTIC, IRIC)","url":"https://site.univ-yaounde2.org"},{"titre":"École Nationale d''Administration et de Magistrature (ENAM)","url":"https://www.enam.cm"},{"titre":"Ministère de la Justice — textes de loi (LEGALIS), professions judiciaires","url":"http://www.minjustice.gov.cm"}]'::jsonb),
('sciences-economiques-gestion', 'filiere', 'Sciences économiques et gestion', 'Enseignement supérieur', 'Baccalauréat ou A Level', 'Licences et masters en économie, gestion, finance, comptabilité, marketing. Débouchés dans les banques, les entreprises, les administrations financières et la création d''entreprise.', '## Où étudier
- **Facultés de sciences économiques et de gestion** (FSEG) des universités d''État.
- **ESSEC Douala**, sur concours, pour la gestion et le commerce.
- **ISSEA**, sur concours, pour la statistique et l''économie appliquée.
- **BTS/HND** en comptabilité, banque ou marketing dans les instituts privés.

## Débouchés
Banques, microfinance, assurances, entreprises, cabinets comptables, régies financières (impôts, douanes, trésor) par l''ENAM, et création d''entreprise.

## Conseil
Les **mathématiques** comptent en économie : n''abandonne pas les maths si tu vises la finance ou la statistique.', ARRAY['Économiste', 'Comptable', 'Banquier', 'Contrôleur de gestion', 'Inspecteur des impôts']::text[], ARRAY['FSEG', 'ESSEC Douala', 'ISSEA', 'BTS/HND', 'ENAM (régies financières)']::text[], ARRAY['économie', 'gestion', 'finance', 'comptabilité', 'fseg', 'essec', 'banque']::text[], '[{"titre":"Ministère de l''Enseignement Supérieur (MINESUP) — concours, BTS/HND, établissements","url":"https://www.minesup.gov.cm"},{"titre":"Université de Douala (ENSPD, ENSET, IUT, FMSP, ESSEC)","url":"https://www.univ-douala.cm"},{"titre":"Institut Sous-régional de Statistique et d''Économie Appliquée (ISSEA, Yaoundé — CEMAC)","url":"https://www.issea-cemac.org"},{"titre":"École Nationale d''Administration et de Magistrature (ENAM)","url":"https://www.enam.cm"}]'::jsonb),
('lettres-langues-sciences-humaines', 'filiere', 'Lettres, langues et sciences humaines', 'Enseignement supérieur', 'Baccalauréat ou A Level', 'Lettres modernes, langues (anglais, allemand, espagnol, chinois…), histoire, géographie, sociologie, psychologie, philosophie. Vers l''enseignement, la traduction, le tourisme, la culture et la communication.', '## Parcours
Licences et masters en **lettres, langues étrangères, langues et cultures camerounaises, histoire, géographie, sociologie, psychologie, philosophie**.

## Débouchés
- **Enseignement**, par le concours de l''ENS.
- **Traduction et interprétation** : le bilinguisme anglais-français est très demandé.
- **Tourisme**, **culture** et patrimoine.
- **Communication**, ONG, ressources humaines (psychologie, sociologie), conseil d''orientation.

## Conseil
Ajoute une **compétence pratique** à ton diplôme (informatique, langue rare, gestion de projet) pour te démarquer sur le marché de l''emploi.', ARRAY['Enseignant', 'Traducteur', 'Guide touristique', 'Psychologue', 'Chargé de communication']::text[], ARRAY['Facultés des lettres et sciences humaines', 'ENS', 'ASTI (Buea, traduction)']::text[], ARRAY['lettres', 'langues', 'histoire', 'géographie', 'sociologie', 'psychologie', 'philosophie', 'traduction']::text[], '[{"titre":"Ministère de l''Enseignement Supérieur (MINESUP) — concours, BTS/HND, établissements","url":"https://www.minesup.gov.cm"},{"titre":"University of Buea (Faculty of Health Sciences, ASTI, COT, faculties)","url":"https://www.ubuea.cm"}]'::jsonb),
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

Les conditions exactes (diplômes admis, âge, frais, dates, nombre de places) changent chaque année : vérifie toujours le communiqué officiel du concours.', ARRAY['Ingénieur génie civil', 'Ingénieur électricien', 'Ingénieur informaticien', 'Ingénieur télécoms', 'Ingénieur mécanicien']::text[], ARRAY['ENSP Yaoundé', 'ENSPD Douala', 'ENSPM Maroua', 'ENSTP', 'ENSAI']::text[], ARRAY['ingénieur', 'polytechnique', 'enspy', 'enspd', 'enstp', 'concours', 'génie']::text[], '[{"titre":"Ministère de l''Enseignement Supérieur (MINESUP) — concours, BTS/HND, établissements","url":"https://www.minesup.gov.cm"},{"titre":"Université de Yaoundé I (ENSP, ENS, FMSB, Faculté des Sciences)","url":"http://www.uy1.uninet.cm"},{"titre":"Université de Douala (ENSPD, ENSET, IUT, FMSP, ESSEC)","url":"https://www.univ-douala.cm"},{"titre":"Université de Maroua (ENS, ENSPM, facultés)","url":"http://www.univ-maroua.cm"},{"titre":"Ministère des Travaux Publics (MINTP)","url":"https://mintp.cm"}]'::jsonb),
('iut', 'filiere', 'Instituts Universitaires de Technologie (IUT)', 'Grandes écoles', 'Bac scientifique, technique ou commercial, ou A Level', 'Les IUT (Douala, Fotso Victor de Bandjoun, Ngaoundéré) forment des techniciens supérieurs en 2 à 3 ans (DUT, licence technologique), avec une possibilité de poursuite en école d''ingénieurs.', '## Spécialités fréquentes
Génie civil, génie électrique, génie mécanique, génie informatique, réseaux et télécoms, maintenance industrielle, gestion, commerce, logistique, génie biologique.

## Atouts
- Une formation **courte et pratique**, avec des stages.
- Une **insertion rapide**.
- Une possibilité de **poursuite d''études**, en licence professionnelle ou en école d''ingénieurs, sur concours.

Les conditions exactes (diplômes admis, âge, frais, dates, nombre de places) changent chaque année : vérifie toujours le communiqué officiel du concours.', ARRAY['Technicien supérieur', 'Chef d''équipe', 'Technicien de maintenance', 'Assistant de gestion']::text[], ARRAY['IUT de Douala', 'IUT Fotso Victor de Bandjoun', 'IUT de Ngaoundéré']::text[], ARRAY['iut', 'dut', 'technicien supérieur', 'licence technologique', 'bandjoun', 'douala']::text[], '[{"titre":"Ministère de l''Enseignement Supérieur (MINESUP) — concours, BTS/HND, établissements","url":"https://www.minesup.gov.cm"},{"titre":"Université de Douala (ENSPD, ENSET, IUT, FMSP, ESSEC)","url":"https://www.univ-douala.cm"},{"titre":"Université de Dschang (FASA, IUT Fotso Victor de Bandjoun)","url":"https://www.univ-dschang.org"},{"titre":"Université de Ngaoundéré (ENSAI, ESMV, IUT, facultés)","url":"https://www.univ-ndere.cm"}]'::jsonb),
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

Les conditions exactes (diplômes admis, âge, frais, dates, nombre de places) changent chaque année : vérifie toujours le communiqué officiel du concours.', ARRAY['Médecin généraliste', 'Médecin spécialiste', 'Pharmacien', 'Chirurgien-dentiste', 'Chercheur biomédical']::text[], ARRAY['FMSB (Yaoundé I)', 'FMSP (Douala)', 'FHS (Buea)']::text[], ARRAY['médecine', 'médecin', 'pharmacie', 'dentiste', 'fmsb', 'concours médecine', 'santé']::text[], '[{"titre":"Ministère de l''Enseignement Supérieur (MINESUP) — concours, BTS/HND, établissements","url":"https://www.minesup.gov.cm"},{"titre":"Université de Yaoundé I (ENSP, ENS, FMSB, Faculté des Sciences)","url":"http://www.uy1.uninet.cm"},{"titre":"Université de Douala (ENSPD, ENSET, IUT, FMSP, ESSEC)","url":"https://www.univ-douala.cm"},{"titre":"University of Buea (Faculty of Health Sciences, ASTI, COT, faculties)","url":"https://www.ubuea.cm"},{"titre":"Ministère de la Santé Publique (MINSANTE) — écoles de formation paramédicale","url":"https://www.minsante.cm"}]'::jsonb),
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

Les conditions exactes (diplômes admis, âge, frais, dates, nombre de places) changent chaque année : vérifie toujours le communiqué officiel du concours.', ARRAY['Infirmier', 'Sage-femme', 'Technicien de laboratoire', 'Technicien d''imagerie', 'Kinésithérapeute']::text[], ARRAY['Écoles du MINSANTE', 'Universités (filières santé)', 'BTS/HND santé (instituts agréés)']::text[], ARRAY['infirmier', 'sage-femme', 'paramédical', 'laboratoire', 'santé', 'aide-soignant', 'kiné']::text[], '[{"titre":"Ministère de la Santé Publique (MINSANTE) — écoles de formation paramédicale","url":"https://www.minsante.cm"},{"titre":"Ministère de l''Enseignement Supérieur (MINESUP) — concours, BTS/HND, établissements","url":"https://www.minesup.gov.cm"}]'::jsonb),
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

Les conditions exactes (diplômes admis, âge, frais, dates, nombre de places) changent chaque année : vérifie toujours le communiqué officiel du concours.', ARRAY['Ingénieur agronome', 'Technicien agricole', 'Agro-entrepreneur', 'Ingénieur agroalimentaire', 'Ingénieur forestier']::text[], ARRAY['FASA Dschang', 'ENSAI Ngaoundéré', 'Écoles MINADER / MINEPIA', 'BTS/HND agriculture']::text[], ARRAY['agronomie', 'agriculture', 'fasa', 'ensai', 'élevage', 'forêt', 'agro-industrie', 'agrobusiness']::text[], '[{"titre":"Ministère de l''Enseignement Supérieur (MINESUP) — concours, BTS/HND, établissements","url":"https://www.minesup.gov.cm"},{"titre":"Université de Dschang (FASA, IUT Fotso Victor de Bandjoun)","url":"https://www.univ-dschang.org"},{"titre":"Université de Ngaoundéré (ENSAI, ESMV, IUT, facultés)","url":"https://www.univ-ndere.cm"},{"titre":"Ministère de l''Agriculture et du Développement Rural (MINADER) — écoles d''agriculture","url":"https://www.minader.cm"},{"titre":"Ministère de l''Élevage, des Pêches et des Industries Animales (MINEPIA)","url":"https://minepia.cm"}]'::jsonb),
('ens-enseignement', 'filiere', 'Devenir enseignant : ENS, ENSET, ENIEG / ENIET', 'Enseignement', 'Bac / A Level (ENS 1er cycle), Licence (ENS 2nd cycle), BEPC à Bac (ENIEG/ENIET)', 'Les Écoles Normales Supérieures forment les professeurs du secondaire général (ENS) et technique (ENSET) ; les ENIEG et ENIET forment les instituteurs. Accès sur concours.', '## Les écoles
- **ENS** (Yaoundé, Maroua, Bambili, et d''autres créées récemment) : professeurs de lycées et de collèges, toutes disciplines.
- **ENSET** (Douala, Bambili, Kumba, Ebolowa…) : professeurs de l''**enseignement technique**.
- **ENIEG / ENIET** : **instituteurs** de l''enseignement général et technique, pour le primaire et la maternelle.

## Les cycles
- **Premier cycle** après le Bac ou le A Level : diplôme de professeur des collèges.
- **Second cycle** après la licence : diplôme de professeur des lycées.

## Réalité
L''enseignement est un **grand employeur public**. Les affectations peuvent se faire **partout sur le territoire**.

Les conditions exactes (diplômes admis, âge, frais, dates, nombre de places) changent chaque année : vérifie toujours le communiqué officiel du concours.', ARRAY['Professeur de lycée', 'Professeur de collège', 'Professeur de l''enseignement technique', 'Instituteur', 'Conseiller d''orientation']::text[], ARRAY['ENS Yaoundé', 'ENS Maroua', 'ENSET Douala', 'ENIEG / ENIET']::text[], ARRAY['enseignant', 'professeur', 'ens', 'enset', 'enieg', 'eniet', 'instituteur', 'concours']::text[], '[{"titre":"Ministère de l''Enseignement Supérieur (MINESUP) — concours, BTS/HND, établissements","url":"https://www.minesup.gov.cm"},{"titre":"Université de Yaoundé I (ENSP, ENS, FMSB, Faculté des Sciences)","url":"http://www.uy1.uninet.cm"},{"titre":"Université de Douala (ENSPD, ENSET, IUT, FMSP, ESSEC)","url":"https://www.univ-douala.cm"},{"titre":"Université de Maroua (ENS, ENSPM, facultés)","url":"http://www.univ-maroua.cm"},{"titre":"Ministère des Enseignements Secondaires (MINESEC)","url":"https://www.minesec.gov.cm"}]'::jsonb),
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

Les conditions exactes (diplômes admis, âge, frais, dates, nombre de places) changent chaque année : vérifie toujours le communiqué officiel du concours.', ARRAY['Administrateur civil', 'Magistrat', 'Inspecteur des impôts', 'Inspecteur du trésor', 'Inspecteur des douanes']::text[], ARRAY['ENAM (Yaoundé)']::text[], ARRAY['enam', 'administration', 'magistrature', 'impôts', 'douanes', 'trésor', 'fonction publique', 'concours']::text[], '[{"titre":"École Nationale d''Administration et de Magistrature (ENAM)","url":"https://www.enam.cm"},{"titre":"Plateforme des concours de l''ENAM","url":"https://concours.enam.cm"},{"titre":"Ministère des Finances (MINFI) — impôts, douanes, trésor","url":"https://minfi.gov.cm"}]'::jsonb),
('iric-diplomatie', 'filiere', 'Relations internationales et diplomatie (IRIC)', 'Administration & diplomatie', 'Licence (concours d''entrée en master)', 'L''Institut des Relations Internationales du Cameroun (Université de Yaoundé II) forme aux relations internationales, à la diplomatie, au contentieux international et à la communication internationale.', '## Accès
Concours après une **licence**, le plus souvent en droit, science politique, économie, histoire ou langues.

## Débouchés
Diplomatie, via les concours de la fonction publique, organisations internationales et régionales (Union africaine, CEMAC, agences de l''ONU), ONG, entreprises internationales, journalisme international.

## Conseil
Le **bilinguisme parfait** et une **troisième langue** sont de vrais atouts.

Les conditions exactes (diplômes admis, âge, frais, dates, nombre de places) changent chaque année : vérifie toujours le communiqué officiel du concours.', ARRAY['Diplomate', 'Chargé de relations internationales', 'Fonctionnaire international', 'Consultant']::text[], ARRAY['IRIC (Université de Yaoundé II)']::text[], ARRAY['iric', 'diplomatie', 'relations internationales', 'diplomate', 'onu', 'affaires étrangères']::text[], '[{"titre":"Ministère de l''Enseignement Supérieur (MINESUP) — concours, BTS/HND, établissements","url":"https://www.minesup.gov.cm"},{"titre":"Université de Yaoundé II-Soa (Droit, Économie, ESSTIC, IRIC)","url":"https://site.univ-yaounde2.org"}]'::jsonb),
('esstic-journalisme-communication', 'filiere', 'Journalisme et communication (ESSTIC)', 'Communication & arts', 'Baccalauréat ou A Level (concours)', 'L''École Supérieure des Sciences et Techniques de l''Information et de la Communication (Université de Yaoundé II) forme journalistes, communicateurs, publicitaires, éditeurs et documentalistes.', '## Filières
- **Journalisme** : presse écrite, radio, télévision, web.
- **Communication** des organisations, **publicité**.
- **Édition**, **documentation et archives**.

## Débouchés
Médias publics et privés, services de communication des ministères et des entreprises, agences, ONG, communication numérique (community management).

## Conseil
Lance-toi dès maintenant : **blog, radio scolaire, journal du lycée**, pages sur les réseaux sociaux. Un portfolio compte autant que le diplôme.

Les conditions exactes (diplômes admis, âge, frais, dates, nombre de places) changent chaque année : vérifie toujours le communiqué officiel du concours.', ARRAY['Journaliste', 'Chargé de communication', 'Community manager', 'Publicitaire', 'Documentaliste']::text[], ARRAY['ESSTIC (Yaoundé II)', 'Licences de communication', 'BTS/HND communication']::text[], ARRAY['journalisme', 'journaliste', 'communication', 'esstic', 'médias', 'publicité', 'community manager']::text[], '[{"titre":"Ministère de l''Enseignement Supérieur (MINESUP) — concours, BTS/HND, établissements","url":"https://www.minesup.gov.cm"},{"titre":"Université de Yaoundé II-Soa (Droit, Économie, ESSTIC, IRIC)","url":"https://site.univ-yaounde2.org"}]'::jsonb),
('issea-statistique', 'filiere', 'Statistique et économie appliquée (ISSEA)', 'Grandes écoles', 'Bac scientifique (cycles techniciens) ou Licence (cycles ingénieurs), selon le cycle', 'L''ISSEA (Yaoundé), institut de la CEMAC, forme des statisticiens et économistes. Ce sont des profils rares et demandés : INS, banques, assurances, organisations internationales.', '## Formations
Plusieurs cycles, de technicien supérieur de la statistique à ingénieur statisticien-économiste. Le recrutement se fait sur **concours communs** à plusieurs écoles africaines de statistique.

## Débouchés
- **Institut National de la Statistique** et services statistiques des ministères.
- Banques, assurances, télécoms.
- Bureaux d''études, organisations internationales, **science des données**.

## Conseil
Il faut un **excellent niveau en mathématiques** (probabilités, analyse) et de la rigueur.

Les conditions exactes (diplômes admis, âge, frais, dates, nombre de places) changent chaque année : vérifie toujours le communiqué officiel du concours.', ARRAY['Statisticien', 'Économiste', 'Data analyst', 'Actuaire']::text[], ARRAY['ISSEA (Yaoundé)']::text[], ARRAY['issea', 'statistique', 'statisticien', 'économie appliquée', 'data', 'actuariat']::text[], '[{"titre":"Institut Sous-régional de Statistique et d''Économie Appliquée (ISSEA, Yaoundé — CEMAC)","url":"https://www.issea-cemac.org"},{"titre":"Institut National de la Statistique (INS) — annuaires et enquêtes","url":"https://ins-cameroun.cm"}]'::jsonb),
('essec-gestion', 'filiere', 'Commerce et gestion (ESSEC Douala et écoles de commerce)', 'Commerce & gestion', 'Baccalauréat ou A Level (concours)', 'L''ESSEC (Université de Douala) et les écoles de commerce forment aux métiers de la gestion, du marketing, de la finance, de la logistique et des ressources humaines.', '## Formations
Gestion des entreprises, comptabilité et finance, marketing et commerce, logistique et transport, ressources humaines.

## Débouchés
- Entreprises de Douala, la **capitale économique**.
- Le port, les banques, les télécoms, la grande distribution.
- La création d''entreprise.

## Alternatives
Les FSEG des universités, les **BTS/HND** en gestion et commerce dans les instituts privés agréés.

Les conditions exactes (diplômes admis, âge, frais, dates, nombre de places) changent chaque année : vérifie toujours le communiqué officiel du concours.', ARRAY['Gestionnaire', 'Responsable marketing', 'Logisticien', 'Contrôleur de gestion', 'Responsable RH']::text[], ARRAY['ESSEC (Université de Douala)', 'FSEG', 'BTS/HND gestion']::text[], ARRAY['essec', 'école de commerce', 'gestion', 'marketing', 'logistique', 'ressources humaines', 'douala']::text[], '[{"titre":"Ministère de l''Enseignement Supérieur (MINESUP) — concours, BTS/HND, établissements","url":"https://www.minesup.gov.cm"},{"titre":"Université de Douala (ENSPD, ENSET, IUT, FMSP, ESSEC)","url":"https://www.univ-douala.cm"}]'::jsonb),
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
Choisis un centre **agréé par le MINEFOP**. Renseigne-toi sur les **bourses de formation** et sur l''accompagnement du **FNE** pour l''emploi et le financement de projets.', ARRAY['Couturier', 'Coiffeur', 'Menuisier', 'Électricien', 'Mécanicien', 'Cuisinier']::text[], ARRAY['Centres de formation professionnelle agréés', 'SAR/SM', 'Apprentissage']::text[], ARRAY['formation professionnelle', 'métier', 'centre de formation', 'minefop', 'apprentissage', 'sar sm', 'auto-emploi']::text[], '[{"titre":"Ministère de l''Emploi et de la Formation Professionnelle (MINEFOP) — centres agréés, examens, bourses","url":"https://www.minefop.gov.cm"},{"titre":"Fonds National de l''Emploi (FNE) — emploi, stages, auto-emploi (services gratuits)","url":"https://fnecm.org"}]'::jsonb),
('defense-securite', 'filiere', 'Défense et sécurité (EMIA, armée, police, gendarmerie)', 'Défense & sécurité', 'Selon le corps : BEPC, Probatoire, Baccalauréat ou Licence', 'L''École Militaire Interarmées (EMIA) forme les officiers ; les recrutements de soldats, sous-officiers, gendarmes et policiers se font par concours annuels du MINDEF et de la DGSN.', '## Les voies
- **EMIA** (Yaoundé) : officiers des armées, sur concours après le Bac ou la licence.
- **Armée et gendarmerie** : recrutements de militaires du rang et de sous-officiers.
- **Police** (DGSN) : concours de gardien de la paix, d''inspecteur, d''officier, de commissaire, selon le diplôme.
- **Sapeurs-pompiers**.

## Ce qu''on attend de toi
Aptitude physique et médicale, discipline, casier judiciaire vierge, limites d''âge.

## Attention
Les **arnaques aux faux recrutements** sont fréquentes : les inscriptions et les résultats sont publiés par les **communiqués officiels** du MINDEF et de la DGSN. On ne paie **jamais** un intermédiaire.

Les conditions exactes (diplômes admis, âge, frais, dates, nombre de places) changent chaque année : vérifie toujours le communiqué officiel du concours.', ARRAY['Officier', 'Sous-officier', 'Gendarme', 'Policier', 'Sapeur-pompier']::text[], ARRAY['EMIA', 'Écoles de la gendarmerie et de l''armée', 'École Nationale Supérieure de Police']::text[], ARRAY['armée', 'emia', 'militaire', 'police', 'gendarmerie', 'dgsn', 'mindef', 'sapeur-pompier']::text[], '[{"titre":"Ministère de la Défense (MINDEF) — EMIA et recrutements des forces de défense","url":"https://mindef.gov.cm"},{"titre":"Délégation Générale à la Sûreté Nationale (DGSN) — concours de la police","url":"https://www.dgsn.cm"}]'::jsonb),
('beaux-arts-culture', 'filiere', 'Arts, culture, design et métiers créatifs', 'Communication & arts', 'Selon la formation (souvent Baccalauréat)', 'Beaux-arts, architecture, design, audiovisuel, musique : l''Institut des Beaux-Arts de Foumban (Université de Dschang), les filières d''arts des universités, des écoles privées et l''apprentissage auprès de professionnels.', '## Formations
- **Institut des Beaux-Arts de Foumban** (Université de Dschang) : arts plastiques, architecture et arts du patrimoine, cinéma et audiovisuel, musique.
- Filières **arts du spectacle** et **cinéma** de certaines universités.
- Écoles privées de **design graphique**, de **mode** et d''**audiovisuel**.

## Réalité
Les métiers créatifs demandent un **portfolio** et un **réseau**. Beaucoup combinent leur art avec le **numérique** : graphisme, vidéo, réseaux sociaux.

## Conseil
Crée et publie régulièrement, participe aux **festivals et concours**, et apprends à **vendre ton travail**.', ARRAY['Graphiste', 'Architecte', 'Réalisateur', 'Musicien', 'Styliste', 'Artiste plasticien']::text[], ARRAY['Institut des Beaux-Arts de Foumban', 'Filières arts des universités', 'Écoles privées']::text[], ARRAY['arts', 'beaux-arts', 'foumban', 'design', 'musique', 'cinéma', 'audiovisuel', 'mode', 'architecture']::text[], '[{"titre":"Ministère de l''Enseignement Supérieur (MINESUP) — concours, BTS/HND, établissements","url":"https://www.minesup.gov.cm"},{"titre":"Université de Dschang (FASA, IUT Fotso Victor de Bandjoun)","url":"https://www.univ-dschang.org"}]'::jsonb),
('traduction-interpretation', 'filiere', 'Traduction et interprétation (ASTI Buea)', 'Communication & arts', 'Licence (concours d''entrée)', 'Le Cameroun, pays bilingue, a besoin de traducteurs et d''interprètes. L''Advanced School of Translators and Interpreters (ASTI, University of Buea) en forme sur concours après la licence.', '## Accès
Concours après une **licence**, avec un excellent niveau en **anglais et en français**, et souvent une autre langue.

## Débouchés
Services de traduction de l''administration, organisations internationales, entreprises, médias, traducteur et interprète indépendant, enseignement des langues.

## Conseil
Lis et écris **chaque jour dans les deux langues officielles**. Une troisième langue, comme l''espagnol, l''allemand, le chinois ou l''arabe, multiplie tes chances.', ARRAY['Traducteur', 'Interprète de conférence', 'Rédacteur bilingue', 'Enseignant de langues']::text[], ARRAY['ASTI (University of Buea)', 'Facultés de lettres (langues)']::text[], ARRAY['traduction', 'traducteur', 'interprète', 'asti', 'bilinguisme', 'langues', 'buea']::text[], '[{"titre":"Ministère de l''Enseignement Supérieur (MINESUP) — concours, BTS/HND, établissements","url":"https://www.minesup.gov.cm"},{"titre":"University of Buea (Faculty of Health Sciences, ASTI, COT, faculties)","url":"https://www.ubuea.cm"}]'::jsonb),
('universite-yaounde-1', 'filiere', 'Université de Yaoundé I', 'Universités d''État', 'Bac / GCE A Level (facultés) ; concours pour les écoles', 'Grande université scientifique et littéraire de la capitale, avec des écoles réputées : ENSP (ingénieurs), ENS (enseignants) et FMSB (médecine).', '## Présentation
Située à Yaoundé (Centre), l''Université de Yaoundé I est l''héritière de la première université du pays. Elle regroupe des facultés classiques et plusieurs grandes écoles recrutant sur concours.

## Ce qu''on y étudie
- **Faculté des Sciences** : mathématiques, physique, chimie, biologie, informatique, géosciences
- **Faculté des Arts, Lettres et Sciences Humaines** : langues, histoire, géographie, philosophie, psychologie, sociologie
- **FMSB** : médecine, pharmacie, odontostomatologie (concours)
- **ENSP / ENSPY** : écoles d''ingénieurs (concours)
- **ENS** : formation des professeurs de l''enseignement secondaire (concours)

## Comment y entrer
Facultés : préinscription après le Bac ou le GCE A Level, selon les séries admises par filière. Écoles (ENSP, ENS, FMSB) : **concours** annoncés par le MINESUP.

## Conseil
Les filières scientifiques demandent un bon niveau en maths ; prépare les concours des écoles dès la Terminale. Les filières ouvertes, les conditions d''accès et le calendrier changent : vérifie toujours le communiqué officiel de l''année (MINESUP et site de l''établissement).', ARRAY['Ingénieur', 'Médecin', 'Professeur', 'Chercheur', 'Informaticien']::text[], ARRAY['Faculté des Sciences', 'Faculté des Arts, Lettres et Sciences Humaines', 'FMSB', 'ENSP / ENSPY', 'ENS']::text[], ARRAY['uy1', 'yaoundé 1', 'université de yaoundé', 'ngoa-ekelle', 'ensp', 'ens', 'fmsb']::text[], '[{"titre":"Université de Yaoundé I (ENSP, ENS, FMSB, Faculté des Sciences)","url":"http://www.uy1.uninet.cm"},{"titre":"École Nationale Supérieure Polytechnique de Yaoundé (ENSPY) — concours","url":"https://polytechnique.cm"},{"titre":"Ministère de l''Enseignement Supérieur (MINESUP) — concours, BTS/HND, établissements","url":"https://www.minesup.gov.cm"}]'::jsonb),
('universite-yaounde-2', 'filiere', 'Université de Yaoundé II-Soa', 'Universités d''État', 'Bac / GCE A Level (facultés) ; concours pour ESSTIC et IRIC', 'Université du droit, de la science politique, de l''économie et de la gestion, avec deux écoles très demandées : l''ESSTIC (journalisme, communication) et l''IRIC (relations internationales).', '## Présentation
Son campus principal est à Soa, près de Yaoundé. Elle possède aussi des sites à Yaoundé (ESSTIC, IRIC) et des antennes dans d''autres villes.

## Ce qu''on y étudie
- **Faculté des Sciences Juridiques et Politiques** : droit public, droit privé, science politique
- **Faculté des Sciences Économiques et de Gestion** : économie, gestion, finance
- **ESSTIC** : journalisme, communication des organisations, archivistique, édition (concours)
- **IRIC** : relations internationales, diplomatie, contentieux, marketing international (concours, niveau master)

## Comment y entrer
Facultés : préinscription en ligne après le Bac ou le A Level. ESSTIC et IRIC : **concours** publiés par le MINESUP.

## Conseil
Le droit et l''économie demandent beaucoup de lecture et de rédaction ; travaille ton expression écrite et l''anglais. Les filières ouvertes, les conditions d''accès et le calendrier changent : vérifie toujours le communiqué officiel de l''année (MINESUP et site de l''établissement).', ARRAY['Juriste', 'Avocat', 'Économiste', 'Journaliste', 'Diplomate']::text[], ARRAY['Faculté des Sciences Juridiques et Politiques', 'Faculté des Sciences Économiques et de Gestion', 'ESSTIC', 'IRIC']::text[], ARRAY['uy2', 'soa', 'yaoundé 2', 'droit', 'économie', 'esstic', 'iric']::text[], '[{"titre":"Université de Yaoundé II-Soa (Droit, Économie, ESSTIC, IRIC)","url":"https://site.univ-yaounde2.org"},{"titre":"ESSTIC — École Supérieure des Sciences et Techniques de l''Information et de la Communication (Université de Yaoundé II)"},{"titre":"IRIC — Institut des Relations Internationales du Cameroun (Université de Yaoundé II)"},{"titre":"Ministère de l''Enseignement Supérieur (MINESUP) — concours, BTS/HND, établissements","url":"https://www.minesup.gov.cm"}]'::jsonb),
('universite-douala', 'filiere', 'Université de Douala', 'Universités d''État', 'Bac / GCE A Level (facultés) ; concours pour les écoles', 'Université de la capitale économique, proche des entreprises et du port : écoles d''ingénieurs (ENSPD), d''enseignement technique (ENSET), de commerce (ESSEC), IUT et médecine.', '## Présentation
Créée en 1993, l''Université de Douala (Littoral) a hérité de l''ESSEC et de l''ENSET. Elle est très liée au tissu industriel et commercial de Douala.

## Ce qu''on y étudie
- **Facultés** : sciences, lettres et sciences humaines, sciences juridiques et politiques, sciences économiques et gestion appliquée
- **FMSP** : médecine et sciences pharmaceutiques (concours)
- **ENSPD** : école d''ingénieurs (concours)
- **ENSET** : professeurs de l''enseignement technique (concours)
- **ESSEC** : commerce, gestion, logistique (concours)
- **IUT de Douala** : formations technologiques courtes (concours ou dossier)

## Comment y entrer
Facultés : préinscription après le Bac ou le A Level. Écoles et IUT : **concours** annoncés par le MINESUP et l''université.

## Conseil
À Douala, les stages en entreprise sont plus faciles à trouver : profites-en dès la première année. Les filières ouvertes, les conditions d''accès et le calendrier changent : vérifie toujours le communiqué officiel de l''année (MINESUP et site de l''établissement).', ARRAY['Ingénieur', 'Gestionnaire', 'Logisticien', 'Professeur du technique', 'Médecin']::text[], ARRAY['Facultés', 'FMSP', 'ENSPD', 'ENSET', 'ESSEC', 'IUT de Douala']::text[], ARRAY['udo', 'douala', 'enspd', 'enset', 'essec', 'iut douala', 'fmsp']::text[], '[{"titre":"Université de Douala (ENSPD, ENSET, IUT, FMSP, ESSEC)","url":"https://www.univ-douala.cm"},{"titre":"ESSEC — École Supérieure des Sciences Économiques et Commerciales, Université de Douala","url":"https://essec-douala.cm"},{"titre":"Ministère de l''Enseignement Supérieur (MINESUP) — concours, BTS/HND, établissements","url":"https://www.minesup.gov.cm"}]'::jsonb),
('universite-dschang', 'filiere', 'Université de Dschang', 'Universités d''État', 'Bac / GCE A Level (facultés) ; concours pour FASA et IUT', 'Université bilingue de l''Ouest, référence nationale en agronomie (FASA), avec l''IUT Fotso Victor de Bandjoun et de nombreuses facultés.', '## Présentation
Issue d''un centre universitaire agricole fondé en 1977, l''Université de Dschang (Ouest) est devenue une université complète en 1993. Elle a des campus et annexes dans plusieurs villes.

## Ce qu''on y étudie
- **FASA** : agronomie, foresterie, productions animales, agroéconomie (concours)
- **IUT Fotso Victor (Bandjoun)** : génie électrique, génie civil, informatique, génie mécanique…
- **Facultés** : sciences, lettres, droit et science politique, sciences économiques et gestion, médecine et sciences pharmaceutiques

## Comment y entrer
Facultés : préinscription après le Bac ou le A Level. FASA et IUT : **concours** annoncés par le MINESUP.

## Conseil
Si l''agriculture moderne et l''agrobusiness t''intéressent, la FASA est l''une des meilleures portes d''entrée du pays. Les filières ouvertes, les conditions d''accès et le calendrier changent : vérifie toujours le communiqué officiel de l''année (MINESUP et site de l''établissement).', ARRAY['Ingénieur agronome', 'Ingénieur des eaux et forêts', 'Technicien supérieur', 'Juriste']::text[], ARRAY['FASA', 'IUT Fotso Victor (Bandjoun)', 'Facultés']::text[], ARRAY['uds', 'dschang', 'fasa', 'bandjoun', 'iut fv', 'agronomie', 'ouest']::text[], '[{"titre":"Université de Dschang (FASA, IUT Fotso Victor de Bandjoun)","url":"https://www.univ-dschang.org"},{"titre":"Faculté d''Agronomie et des Sciences Agricoles (FASA), Université de Dschang","url":"https://www.univ-dschang.org/fasa/"},{"titre":"Ministère de l''Enseignement Supérieur (MINESUP) — concours, BTS/HND, établissements","url":"https://www.minesup.gov.cm"}]'::jsonb),
('university-of-buea', 'filiere', 'University of Buea', 'Universités d''État', 'GCE A Level / Bac (faculties) ; entrance exams for professional schools', 'Université d''État de tradition anglo-saxonne (Sud-Ouest), en anglais : sciences, santé, agriculture, traduction et interprétation (ASTI), technologie.', '## Présentation
Founded as a university centre in 1985 and chartered as a full university in the early 1990s, the University of Buea (South West Region) teaches mainly in English and offers about 80 degree programmes.

## Ce qu''on y étudie
- **Faculty of Health Sciences** : medicine, nursing, medical laboratory science (concours)
- **ASTI** : traduction et interprétation, niveau master (concours)
- **College of Technology (COT)** : ingénierie et technologie
- **Faculties** : science, arts, social and management sciences, education, agriculture and veterinary medicine, engineering, law

## Comment y entrer
Faculties: admission on the basis of the GCE A Level (or equivalent). Professional schools: **competitive entrance examinations** published by MINESUP and the university.

## Conseil
Les élèves francophones peuvent y étudier s''ils maîtrisent bien l''anglais : c''est un excellent moyen de devenir parfaitement bilingue. Les filières ouvertes, les conditions d''accès et le calendrier changent : vérifie toujours le communiqué officiel de l''année (MINESUP et site de l''établissement).', ARRAY['Doctor', 'Nurse', 'Translator', 'Engineer', 'Teacher']::text[], ARRAY['Faculty of Health Sciences', 'ASTI', 'College of Technology (COT)', 'Faculties']::text[], ARRAY['ub', 'buea', 'anglophone', 'english', 'asti', 'molyko', 'health sciences']::text[], '[{"titre":"University of Buea (Faculty of Health Sciences, ASTI, COT, faculties)","url":"https://www.ubuea.cm"},{"titre":"Ministère de l''Enseignement Supérieur (MINESUP) — concours, BTS/HND, établissements","url":"https://www.minesup.gov.cm"},{"titre":"Cameroon GCE Board — GCE O Level / A Level","url":"https://www.camgceb.org"}]'::jsonb),
('universite-ngaoundere', 'filiere', 'Université de Ngaoundéré', 'Universités d''État', 'Bac / GCE A Level (facultés) ; concours pour les écoles', 'Grande université de l''Adamaoua, réputée pour l''agro-industrie (ENSAI) et la médecine vétérinaire (ESMV), avec un IUT et plusieurs facultés.', '## Présentation
Issue du Centre universitaire de Ngaoundéré (1982), elle est devenue université en 1993. Elle compte une dizaine d''établissements et plus d''une centaine de formations.

## Ce qu''on y étudie
- **ENSAI** : génie des procédés, génie alimentaire, qualité, chimie industrielle (concours)
- **ESMV** : médecine vétérinaire (concours)
- **IUT de Ngaoundéré** : formations technologiques courtes
- **Facultés** : sciences, lettres et sciences humaines, droit et science politique, sciences économiques et gestion

## Comment y entrer
Préinscription en ligne pour les facultés ; **concours** pour l''ENSAI, l''ESMV et l''IUT, annoncés par le MINESUP.

## Conseil
L''ENSAI est idéale si tu veux travailler dans la transformation des produits agricoles, un secteur porteur. Les filières ouvertes, les conditions d''accès et le calendrier changent : vérifie toujours le communiqué officiel de l''année (MINESUP et site de l''établissement).', ARRAY['Ingénieur agroalimentaire', 'Vétérinaire', 'Technicien supérieur', 'Contrôleur qualité']::text[], ARRAY['ENSAI', 'ESMV', 'IUT de Ngaoundéré', 'Facultés']::text[], ARRAY['ngaoundéré', 'ngaoundere', 'ensai', 'esmv', 'vétérinaire', 'adamaoua', 'dang']::text[], '[{"titre":"Université de Ngaoundéré (ENSAI, ESMV, IUT, facultés)","url":"https://www.univ-ndere.cm"},{"titre":"École Nationale Supérieure des Sciences Agro-Industrielles (ENSAI), Ngaoundéré","url":"https://ensai.univ-ndere.cm"},{"titre":"École des Sciences et de Médecine Vétérinaire (ESMV), Université de Ngaoundéré","url":"https://esmv.univ-ndere.cm"},{"titre":"Ministère de l''Enseignement Supérieur (MINESUP) — concours, BTS/HND, établissements","url":"https://www.minesup.gov.cm"}]'::jsonb),
('universite-maroua', 'filiere', 'Université de Maroua', 'Universités d''État', 'Bac / GCE A Level (facultés) ; concours pour les écoles', 'Université de l''Extrême-Nord créée en 2008, avec une École Normale Supérieure, des formations d''ingénieurs et un institut des mines et des industries pétrolières.', '## Présentation
Créée par décret en 2008, l''Université de Maroua compte plusieurs établissements, dont l''ENS de Maroua, l''École Nationale Supérieure Polytechnique de Maroua, l''Institut des Mines et des Industries Pétrolières et l''Institut Supérieur du Sahel.

## Ce qu''on y étudie
- **ENS de Maroua** : formation des enseignants (concours)
- **ENSPM** : ingénierie (concours)
- **Institut des Mines et des Industries Pétrolières** : mines, pétrole
- **Facultés** : sciences, lettres et sciences humaines, sciences économiques et gestion, sciences juridiques et politiques

## Comment y entrer
Préinscription en ligne pour les facultés ; **concours** pour les écoles et instituts.

## Conseil
Les concours de l''ENS de Maroua sont une voie importante pour devenir enseignant. Les filières ouvertes, les conditions d''accès et le calendrier changent : vérifie toujours le communiqué officiel de l''année (MINESUP et site de l''établissement).', ARRAY['Enseignant', 'Ingénieur', 'Technicien des mines', 'Cadre']::text[], ARRAY['ENS de Maroua', 'ENSPM', 'Institut des Mines et des Industries Pétrolières', 'Facultés']::text[], ARRAY['maroua', 'extrême-nord', 'ens maroua', 'enspm', 'mines', 'pétrole']::text[], '[{"titre":"Université de Maroua (ENS, ENSPM, facultés)","url":"http://www.univ-maroua.cm"},{"titre":"Ministère de l''Enseignement Supérieur (MINESUP) — concours, BTS/HND, établissements","url":"https://www.minesup.gov.cm"}]'::jsonb),
('university-of-bamenda', 'filiere', 'The University of Bamenda', 'Universités d''État', 'GCE A Level / Bac (faculties) ; entrance exams for professional schools', 'Université d''État anglophone du Nord-Ouest (Bambili), créée en 2010 : technologie (COLTECH), formation des enseignants du technique (HTTTC), polytechnique (NAHPI), santé.', '## Présentation
Created by decree in December 2010 on the Bambili site, the University of Bamenda teaches mainly in English.

## Ce qu''on y étudie
- **COLTECH** : College of Technology, ingénieurs et technologues
- **HTTTC** : Higher Technical Teacher Training College
- **NAHPI** : National Higher Polytechnic Institute
- **Health sciences** : nursing, midwifery, medical laboratory science (concours)
- **Faculties** : arts, science, economics and management, law and political science, education

## Comment y entrer
Admission on the basis of the GCE A Level (or equivalent) through the online UBa portal; **competitive entrance examinations** for professional schools.

## Conseil
Cette université parraine aussi des instituts privés : vérifie toujours l''agrément d''un institut qui se dit « sous tutelle ». Les filières ouvertes, les conditions d''accès et le calendrier changent : vérifie toujours le communiqué officiel de l''année (MINESUP et site de l''établissement).', ARRAY['Engineer', 'Technical teacher', 'Nurse', 'Lawyer']::text[], ARRAY['COLTECH', 'HTTTC', 'NAHPI', 'Health sciences', 'Faculties']::text[], ARRAY['uba', 'bamenda', 'bambili', 'coltech', 'htttc', 'nahpi', 'anglophone']::text[], '[{"titre":"The University of Bamenda (COLTECH, HTTTC, NAHPI)","url":"https://uniba.cm"},{"titre":"Ministère de l''Enseignement Supérieur (MINESUP) — concours, BTS/HND, établissements","url":"https://www.minesup.gov.cm"},{"titre":"Cameroon GCE Board — GCE O Level / A Level","url":"https://www.camgceb.org"}]'::jsonb),
('universite-bertoua', 'filiere', 'Université de Bertoua', 'Universités d''État', 'Bac / GCE A Level', 'Université d''État de l''Est, créée par décret en janvier 2022 à partir d''établissements déjà présents dans la région.', '## Présentation
Créée en 2022 avec Ebolowa et Garoua, l''Université de Bertoua a repris des écoles et annexes existantes de l''Est. Son offre de formation se développe chaque année.

## Ce qu''on y étudie
- Facultés et écoles en cours de développement (sciences, lettres, droit, économie, formations professionnelles)
- Consulte la liste à jour des filières ouvertes dans le communiqué de préinscription

## Comment y entrer
Préinscription après le Bac ou le A Level ; concours pour les écoles professionnelles.

## Conseil
Étudier près de chez soi réduit fortement le coût des études : renseigne-toi sur les filières ouvertes à Bertoua. Les filières ouvertes, les conditions d''accès et le calendrier changent : vérifie toujours le communiqué officiel de l''année (MINESUP et site de l''établissement).', ARRAY[]::text[], ARRAY['Facultés et écoles en cours de développement (sciences, lettres, droit, économie, formations professionnelles)', 'Consulte la liste à jour des filières ouvertes dans le communiqué de préinscription']::text[], ARRAY['bertoua', 'est', 'nouvelle université', '2022']::text[], '[{"titre":"Université de Bertoua (créée en 2022)"},{"titre":"Ministère de l''Enseignement Supérieur (MINESUP) — concours, BTS/HND, établissements","url":"https://www.minesup.gov.cm"},{"titre":"Loi n°2023/007 du 25 juillet 2023 portant orientation de l''enseignement supérieur au Cameroun"}]'::jsonb),
('universite-ebolowa', 'filiere', 'Université d''Ebolowa', 'Universités d''État', 'Bac / GCE A Level', 'Université d''État du Sud, créée par décret en janvier 2022, dont l''offre de formation se met en place progressivement.', '## Présentation
Créée en 2022 en même temps que Bertoua et Garoua, l''Université d''Ebolowa rapproche l''enseignement supérieur des étudiants de la région du Sud.

## Ce qu''on y étudie
- Facultés et écoles en cours de développement
- Consulte la liste à jour des filières ouvertes dans le communiqué de préinscription

## Comment y entrer
Préinscription après le Bac ou le A Level ; concours pour les écoles professionnelles.

## Conseil
Compare les filières d''Ebolowa avec celles de Yaoundé avant de choisir. Les filières ouvertes, les conditions d''accès et le calendrier changent : vérifie toujours le communiqué officiel de l''année (MINESUP et site de l''établissement).', ARRAY[]::text[], ARRAY['Facultés et écoles en cours de développement', 'Consulte la liste à jour des filières ouvertes dans le communiqué de préinscription']::text[], ARRAY['ebolowa', 'sud', 'nouvelle université', '2022']::text[], '[{"titre":"Université d''Ebolowa (créée en 2022)"},{"titre":"Ministère de l''Enseignement Supérieur (MINESUP) — concours, BTS/HND, établissements","url":"https://www.minesup.gov.cm"},{"titre":"Loi n°2023/007 du 25 juillet 2023 portant orientation de l''enseignement supérieur au Cameroun"}]'::jsonb),
('universite-garoua', 'filiere', 'Université de Garoua', 'Universités d''État', 'Bac / GCE A Level', 'Université d''État du Nord, créée par décret en janvier 2022, dont l''offre de formation se met en place progressivement.', '## Présentation
Créée en 2022 avec Bertoua et Ebolowa, l''Université de Garoua renforce l''offre universitaire dans la région du Nord.

## Ce qu''on y étudie
- Facultés et écoles en cours de développement
- Consulte la liste à jour des filières ouvertes dans le communiqué de préinscription

## Comment y entrer
Préinscription après le Bac ou le A Level ; concours pour les écoles professionnelles.

## Conseil
Renseigne-toi aussi sur les formations de Ngaoundéré et de Maroua, proches de Garoua. Les filières ouvertes, les conditions d''accès et le calendrier changent : vérifie toujours le communiqué officiel de l''année (MINESUP et site de l''établissement).', ARRAY[]::text[], ARRAY['Facultés et écoles en cours de développement', 'Consulte la liste à jour des filières ouvertes dans le communiqué de préinscription']::text[], ARRAY['garoua', 'nord', 'nouvelle université', '2022']::text[], '[{"titre":"Université de Garoua (créée en 2022)"},{"titre":"Ministère de l''Enseignement Supérieur (MINESUP) — concours, BTS/HND, établissements","url":"https://www.minesup.gov.cm"},{"titre":"Loi n°2023/007 du 25 juillet 2023 portant orientation de l''enseignement supérieur au Cameroun"}]'::jsonb),
('ecole-enspy', 'filiere', 'ENSP Yaoundé (École Nationale Supérieure Polytechnique)', 'Grandes écoles', 'Bac C, E (et autres séries admises) / A Level sciences + concours', 'La plus ancienne école publique d''ingénieurs du pays (Université de Yaoundé I), avec de nombreuses spécialités et un concours très sélectif.', '## Présentation
L''ENSPY recrute chaque année sur concours, avec des épreuves écrites organisées dans les chefs-lieux de région. Elle publie ses communiqués sur son site et sur sa plateforme de concours.

## Ce qu''on y étudie
- Génie civil, génie électrique, génie mécanique, génie industriel
- Génie informatique, télécommunications
- Autres filières ouvertes selon les années (ex. génie minier, humanités numériques)

## Comment y entrer
**Concours** en 1re année (après le Bac ou le A Level) et en 3e année (après une licence ou un diplôme équivalent). Inscription en ligne, dossier puis épreuves écrites.

## Conseil
Le concours porte surtout sur les maths et la physique : entraîne-toi avec les annales et chronomètre-toi. Les filières ouvertes, les conditions d''accès et le calendrier changent : vérifie toujours le communiqué officiel de l''année (MINESUP et site de l''établissement).', ARRAY['Ingénieur génie civil', 'Ingénieur informaticien', 'Ingénieur électricien', 'Ingénieur télécoms']::text[], ARRAY['Génie civil, génie électrique, génie mécanique, génie industriel', 'Génie informatique, télécommunications', 'Autres filières ouvertes selon les années (ex. génie minier, humanités numériques)']::text[], ARRAY['ensp', 'enspy', 'polytechnique', 'ingénieur', 'yaoundé']::text[], '[{"titre":"École Nationale Supérieure Polytechnique de Yaoundé (ENSPY) — concours","url":"https://polytechnique.cm"},{"titre":"Université de Yaoundé I (ENSP, ENS, FMSB, Faculté des Sciences)","url":"http://www.uy1.uninet.cm"},{"titre":"Ministère de l''Enseignement Supérieur (MINESUP) — concours, BTS/HND, établissements","url":"https://www.minesup.gov.cm"}]'::jsonb),
('ecole-enspd', 'filiere', 'ENSPD Douala (École Nationale Supérieure Polytechnique de Douala)', 'Grandes écoles', 'Bac C, E, F (selon spécialités) / A Level + concours', 'École publique d''ingénieurs de l''Université de Douala, proche des industries de la capitale économique.', '## Présentation
L''ENSPD forme des ingénieurs et des techniciens supérieurs dans plusieurs spécialités, en lien avec les entreprises de Douala.

## Ce qu''on y étudie
- Génie civil, génie électrique, génie mécanique, génie industriel
- Génie informatique, télécommunications, génie des procédés (selon les années)

## Comment y entrer
**Concours** publié par le MINESUP et l''Université de Douala.

## Conseil
Présente aussi le concours de l''ENSPY et des autres écoles pour multiplier tes chances. Les filières ouvertes, les conditions d''accès et le calendrier changent : vérifie toujours le communiqué officiel de l''année (MINESUP et site de l''établissement).', ARRAY['Ingénieur', 'Chef de projet industriel']::text[], ARRAY['Génie civil, génie électrique, génie mécanique, génie industriel', 'Génie informatique, télécommunications, génie des procédés (selon les années)']::text[], ARRAY['enspd', 'polytechnique douala', 'ingénieur', 'douala']::text[], '[{"titre":"Université de Douala (ENSPD, ENSET, IUT, FMSP, ESSEC)","url":"https://www.univ-douala.cm"},{"titre":"Ministère de l''Enseignement Supérieur (MINESUP) — concours, BTS/HND, établissements","url":"https://www.minesup.gov.cm"}]'::jsonb),
('ecole-enset-douala', 'filiere', 'ENSET de Douala (École Normale Supérieure d''Enseignement Technique)', 'Grandes écoles', 'Bac technique ou scientifique / Licence + concours', 'École de l''Université de Douala qui forme les professeurs des lycées techniques (industriel et commercial).', '## Présentation
L''ENSET forme les enseignants des disciplines techniques : génie électrique, génie mécanique, génie civil, sciences et techniques commerciales, etc.

## Ce qu''on y étudie
- Professeurs de l''enseignement technique industriel
- Professeurs de l''enseignement technique commercial

## Comment y entrer
**Concours** au 1er cycle (après le Bac) et au 2nd cycle (après la Licence).

## Conseil
Si tu viens d''une série F ou d''une série commerciale, c''est une voie naturelle vers l''enseignement. Les filières ouvertes, les conditions d''accès et le calendrier changent : vérifie toujours le communiqué officiel de l''année (MINESUP et site de l''établissement).', ARRAY['Professeur de lycée technique', 'Formateur']::text[], ARRAY['Professeurs de l''enseignement technique industriel', 'Professeurs de l''enseignement technique commercial']::text[], ARRAY['enset', 'enseignement technique', 'professeur', 'douala']::text[], '[{"titre":"Université de Douala (ENSPD, ENSET, IUT, FMSP, ESSEC)","url":"https://www.univ-douala.cm"},{"titre":"Ministère de l''Enseignement Supérieur (MINESUP) — concours, BTS/HND, établissements","url":"https://www.minesup.gov.cm"},{"titre":"Ministère des Enseignements Secondaires (MINESEC)","url":"https://www.minesec.gov.cm"}]'::jsonb),
('ecole-ens-yaounde', 'filiere', 'ENS de Yaoundé (École Normale Supérieure)', 'Grandes écoles', 'Bac ou GCE A Level (1er cycle) / Licence (2nd cycle) + concours', 'École de l''Université de Yaoundé I qui forme les professeurs de l''enseignement secondaire général, dans presque toutes les disciplines.', '## Présentation
Le concours de l''ENS est l''une des principales voies pour devenir professeur de collège ou de lycée. L''évaluation combine en général un dossier scolaire et des épreuves écrites.

## Ce qu''on y étudie
- Mathématiques, informatique, physique, chimie, sciences de la vie et de la Terre
- Français, anglais, langues étrangères, histoire, géographie, philosophie
- Conseillers d''orientation (selon les années)

## Comment y entrer
**Concours** au 1er cycle (après le Bac ou le A Level) et au 2nd cycle (après la Licence), publiés par le MINESUP.

## Conseil
Choisis la section qui correspond à la matière où tu as les meilleurs résultats. Les filières ouvertes, les conditions d''accès et le calendrier changent : vérifie toujours le communiqué officiel de l''année (MINESUP et site de l''établissement).', ARRAY['Professeur de collège ou de lycée', 'Conseiller d''orientation']::text[], ARRAY['Mathématiques, informatique, physique, chimie, sciences de la vie et de la Terre', 'Français, anglais, langues étrangères, histoire, géographie, philosophie', 'Conseillers d''orientation (selon les années)']::text[], ARRAY['ens', 'ens yaoundé', 'professeur', 'enseignant', 'école normale']::text[], '[{"titre":"Université de Yaoundé I (ENSP, ENS, FMSB, Faculté des Sciences)","url":"http://www.uy1.uninet.cm"},{"titre":"Ministère de l''Enseignement Supérieur (MINESUP) — concours, BTS/HND, établissements","url":"https://www.minesup.gov.cm"},{"titre":"Ministère des Enseignements Secondaires (MINESEC)","url":"https://www.minesec.gov.cm"}]'::jsonb),
('ecole-essec-douala', 'filiere', 'ESSEC de Douala', 'Grandes écoles', 'Bac (A, B, C, D, G…) / GCE A Level + concours ; Licence pour certains cycles', 'École publique de commerce et de gestion de l''Université de Douala : comptabilité, finance, marketing, logistique, management.', '## Présentation
L''ESSEC recrute sur concours, avec des centres d''examen dans plusieurs villes. Elle propose un cycle après le Bac et des cycles après la Licence.

## Ce qu''on y étudie
- **ESC** (Études Supérieures de Commerce) : après le Bac ou le A Level
- **EPA** (Études Professionnelles Approfondies) : après la Licence
- Spécialités : comptabilité, finance, marketing, logistique et transport, gestion

## Comment y entrer
**Concours** annoncé chaque année (formulaire, frais, dossier et inscription en ligne).

## Conseil
Les maths et la culture économique comptent beaucoup ; entraîne-toi sur les annales. Les filières ouvertes, les conditions d''accès et le calendrier changent : vérifie toujours le communiqué officiel de l''année (MINESUP et site de l''établissement).', ARRAY['Comptable', 'Banquier', 'Logisticien', 'Responsable marketing']::text[], ARRAY['ESC (Études Supérieures de Commerce)', 'EPA (Études Professionnelles Approfondies)', 'Spécialités']::text[], ARRAY['essec', 'commerce', 'gestion', 'douala', 'école de commerce']::text[], '[{"titre":"ESSEC — École Supérieure des Sciences Économiques et Commerciales, Université de Douala","url":"https://essec-douala.cm"},{"titre":"Université de Douala (ENSPD, ENSET, IUT, FMSP, ESSEC)","url":"https://www.univ-douala.cm"},{"titre":"Ministère de l''Enseignement Supérieur (MINESUP) — concours, BTS/HND, établissements","url":"https://www.minesup.gov.cm"}]'::jsonb),
('ecole-ensai', 'filiere', 'ENSAI de Ngaoundéré', 'Grandes écoles', 'Bac C, D, E, F / A Level sciences + concours', 'École Nationale Supérieure des Sciences Agro-Industrielles : ingénieurs et techniciens de la transformation agroalimentaire et des procédés.', '## Présentation
Rattachée à l''Université de Ngaoundéré, l''ENSAI forme aux métiers de l''agro-industrie, du contrôle qualité et du génie des procédés.

## Ce qu''on y étudie
- Génie des procédés et génie alimentaire
- Qualité, hygiène et sécurité des aliments
- Chimie industrielle et environnement (selon les années)

## Comment y entrer
**Concours** publié par le MINESUP.

## Conseil
Bon niveau en chimie et en biologie indispensable. Les filières ouvertes, les conditions d''accès et le calendrier changent : vérifie toujours le communiqué officiel de l''année (MINESUP et site de l''établissement).', ARRAY['Ingénieur agroalimentaire', 'Responsable qualité', 'Chef de production']::text[], ARRAY['Génie des procédés et génie alimentaire', 'Qualité, hygiène et sécurité des aliments', 'Chimie industrielle et environnement (selon les années)']::text[], ARRAY['ensai', 'agro-industrie', 'agroalimentaire', 'ngaoundéré', 'procédés']::text[], '[{"titre":"École Nationale Supérieure des Sciences Agro-Industrielles (ENSAI), Ngaoundéré","url":"https://ensai.univ-ndere.cm"},{"titre":"Université de Ngaoundéré (ENSAI, ESMV, IUT, facultés)","url":"https://www.univ-ndere.cm"},{"titre":"Ministère de l''Enseignement Supérieur (MINESUP) — concours, BTS/HND, établissements","url":"https://www.minesup.gov.cm"}]'::jsonb),
('ecole-esmv', 'filiere', 'ESMV de Ngaoundéré (médecine vétérinaire)', 'Grandes écoles', 'Bac C ou D / A Level sciences + concours', 'École des Sciences et de Médecine Vétérinaire de l''Université de Ngaoundéré : la voie publique pour devenir docteur vétérinaire.', '## Présentation
L''ESMV forme des vétérinaires pour la santé animale, l''élevage, la sécurité sanitaire des aliments et la santé publique.

## Ce qu''on y étudie
- Doctorat en médecine vétérinaire
- Santé animale et santé publique vétérinaire

## Comment y entrer
**Concours** publié par le MINESUP.

## Conseil
SVT et chimie sont essentielles ; les stages chez les éleveurs sont très formateurs. Les filières ouvertes, les conditions d''accès et le calendrier changent : vérifie toujours le communiqué officiel de l''année (MINESUP et site de l''établissement).', ARRAY['Vétérinaire', 'Inspecteur sanitaire', 'Conseiller en élevage']::text[], ARRAY['Doctorat en médecine vétérinaire', 'Santé animale et santé publique vétérinaire']::text[], ARRAY['esmv', 'vétérinaire', 'médecine vétérinaire', 'ngaoundéré']::text[], '[{"titre":"École des Sciences et de Médecine Vétérinaire (ESMV), Université de Ngaoundéré","url":"https://esmv.univ-ndere.cm"},{"titre":"Université de Ngaoundéré (ENSAI, ESMV, IUT, facultés)","url":"https://www.univ-ndere.cm"},{"titre":"Ministère de l''Élevage, des Pêches et des Industries Animales (MINEPIA)","url":"https://minepia.cm"}]'::jsonb),
('ecole-fasa', 'filiere', 'FASA de Dschang (agronomie)', 'Grandes écoles', 'Bac C ou D / A Level sciences + concours', 'Faculté d''Agronomie et des Sciences Agricoles de l''Université de Dschang : ingénieurs agronomes, forestiers et des productions animales.', '## Présentation
La FASA est la principale école publique d''ingénieurs agronomes du pays, avec des fermes d''application et de nombreux stages de terrain.

## Ce qu''on y étudie
- Productions végétales, productions animales
- Foresterie, eaux et forêts
- Agroéconomie, génie rural, sciences du sol

## Comment y entrer
**Concours** publié par le MINESUP.

## Conseil
Pense dès le départ à l''agrobusiness : produire, transformer, vendre. Les filières ouvertes, les conditions d''accès et le calendrier changent : vérifie toujours le communiqué officiel de l''année (MINESUP et site de l''établissement).', ARRAY['Ingénieur agronome', 'Ingénieur des eaux et forêts', 'Agro-entrepreneur']::text[], ARRAY['Productions végétales, productions animales', 'Foresterie, eaux et forêts', 'Agroéconomie, génie rural, sciences du sol']::text[], ARRAY['fasa', 'agronomie', 'dschang', 'ingénieur agronome', 'forêt']::text[], '[{"titre":"Faculté d''Agronomie et des Sciences Agricoles (FASA), Université de Dschang","url":"https://www.univ-dschang.org/fasa/"},{"titre":"Université de Dschang (FASA, IUT Fotso Victor de Bandjoun)","url":"https://www.univ-dschang.org"},{"titre":"Ministère de l''Agriculture et du Développement Rural (MINADER) — écoles d''agriculture","url":"https://www.minader.cm"}]'::jsonb),
('ecole-esstic', 'filiere', 'ESSTIC (journalisme et communication)', 'Grandes écoles', 'Bac / GCE A Level + concours (selon les cycles)', 'École de l''Université de Yaoundé II, créée en 1991 dans la continuité de l''école de journalisme de Yaoundé, qui forme journalistes, communicants, archivistes et éditeurs.', '## Présentation
L''ESSTIC propose des cycles de licence, master et doctorat en journalisme, communication des organisations, archivistique, bibliothéconomie et édition.

## Ce qu''on y étudie
- Journalisme
- Communication des organisations
- Archivistique, bibliothéconomie, édition

## Comment y entrer
**Concours** publié par le MINESUP.

## Conseil
Écris, lis la presse et pratique l''oral : la culture générale est décisive. Les filières ouvertes, les conditions d''accès et le calendrier changent : vérifie toujours le communiqué officiel de l''année (MINESUP et site de l''établissement).', ARRAY['Journaliste', 'Chargé de communication', 'Archiviste', 'Éditeur']::text[], ARRAY['Journalisme', 'Communication des organisations', 'Archivistique, bibliothéconomie, édition']::text[], ARRAY['esstic', 'journalisme', 'communication', 'médias']::text[], '[{"titre":"ESSTIC — École Supérieure des Sciences et Techniques de l''Information et de la Communication (Université de Yaoundé II)"},{"titre":"Université de Yaoundé II-Soa (Droit, Économie, ESSTIC, IRIC)","url":"https://site.univ-yaounde2.org"},{"titre":"Ministère de l''Enseignement Supérieur (MINESUP) — concours, BTS/HND, établissements","url":"https://www.minesup.gov.cm"}]'::jsonb),
('ecole-iric', 'filiere', 'IRIC (relations internationales)', 'Grandes écoles', 'Licence + concours (niveau master)', 'Institut des Relations Internationales du Cameroun (Université de Yaoundé II) : diplomatie, contentieux international, intégration régionale, banque et marketing internationaux.', '## Présentation
L''IRIC recrute sur concours après la licence. Les épreuves portent sur les relations internationales, des techniques propres à chaque filière et une épreuve de langue (anglais pour les francophones, français pour les anglophones).

## Ce qu''on y étudie
- Diplomatie
- Contentieux international
- Intégration régionale et institutions communautaires
- Banque et finance internationales, marketing international
- Communication et action publique internationale

## Comment y entrer
**Concours** publié chaque année par le MINESUP.

## Conseil
Le bilinguisme et le suivi de l''actualité internationale sont indispensables. Les filières ouvertes, les conditions d''accès et le calendrier changent : vérifie toujours le communiqué officiel de l''année (MINESUP et site de l''établissement).', ARRAY['Diplomate', 'Fonctionnaire international', 'Juriste international', 'Analyste']::text[], ARRAY['Diplomatie', 'Contentieux international', 'Intégration régionale et institutions communautaires', 'Banque et finance internationales, marketing international', 'Communication et action publique internationale']::text[], ARRAY['iric', 'diplomatie', 'relations internationales', 'affaires étrangères']::text[], '[{"titre":"IRIC — Institut des Relations Internationales du Cameroun (Université de Yaoundé II)"},{"titre":"Université de Yaoundé II-Soa (Droit, Économie, ESSTIC, IRIC)","url":"https://site.univ-yaounde2.org"},{"titre":"Ministère de l''Enseignement Supérieur (MINESUP) — concours, BTS/HND, établissements","url":"https://www.minesup.gov.cm"}]'::jsonb),
('ecole-asti', 'filiere', 'ASTI de Buea (traduction et interprétation)', 'Grandes écoles', 'Licence (toute discipline) + concours', 'Advanced School of Translators and Interpreters (University of Buea) : masters en traduction (écrit) et en interprétation (oral).', '## Présentation
L''ASTI recrute sur concours des titulaires d''une licence, quelle que soit la discipline. La division traduction a des épreuves écrites ; la division interprétation a des épreuves orales.

## Ce qu''on y étudie
- Master en traduction (combinaisons anglais/français, avec allemand, espagnol ou arabe selon les années)
- Master en interprétation de conférence

## Comment y entrer
**Concours** publié par le MINESUP.

## Conseil
Excellente maîtrise de l''anglais et du français exigée ; une troisième langue est un atout. Les filières ouvertes, les conditions d''accès et le calendrier changent : vérifie toujours le communiqué officiel de l''année (MINESUP et site de l''établissement).', ARRAY['Traducteur', 'Interprète de conférence', 'Réviseur']::text[], ARRAY['Master en traduction (combinaisons anglais/français, avec allemand, espagnol ou arabe selon les années)', 'Master en interprétation de conférence']::text[], ARRAY['asti', 'traduction', 'interprétation', 'buea', 'translator']::text[], '[{"titre":"University of Buea (Faculty of Health Sciences, ASTI, COT, faculties)","url":"https://www.ubuea.cm"},{"titre":"Ministère de l''Enseignement Supérieur (MINESUP) — concours, BTS/HND, établissements","url":"https://www.minesup.gov.cm"}]'::jsonb),
('ecole-enstp', 'filiere', 'ENSTP (École Nationale Supérieure des Travaux Publics)', 'Grandes écoles', 'Bac scientifique ou technique + concours ; Licence pour certains cycles', 'École de Yaoundé qui forme techniciens, ingénieurs et architectes pour les routes, le bâtiment, la topographie et l''urbanisme.', '## Présentation
Fondée en 1970 (d''abord École Nationale de Technologie), l''ENSTP porte son nom actuel depuis 1982. Ses concours sont publiés par le MINESUP.

## Ce qu''on y étudie
- Cycle technicien
- Cycle ingénieur : génie civil, travaux publics, topographie, génie rural…
- Architecture et urbanisme (selon les années)

## Comment y entrer
**Concours** publié par le MINESUP, avec plusieurs cycles d''entrée.

## Conseil
Bon niveau en maths et en physique ; intéresse-toi au dessin technique. Les filières ouvertes, les conditions d''accès et le calendrier changent : vérifie toujours le communiqué officiel de l''année (MINESUP et site de l''établissement).', ARRAY['Ingénieur des travaux publics', 'Géomètre-topographe', 'Architecte', 'Conducteur de travaux']::text[], ARRAY['Cycle technicien', 'Cycle ingénieur', 'Architecture et urbanisme (selon les années)']::text[], ARRAY['enstp', 'travaux publics', 'génie civil', 'topographie', 'architecture']::text[], '[{"titre":"ENSTP — École Nationale Supérieure des Travaux Publics, Yaoundé"},{"titre":"Ministère de l''Enseignement Supérieur (MINESUP) — concours, BTS/HND, établissements","url":"https://www.minesup.gov.cm"},{"titre":"Ministère des Travaux Publics (MINTP)","url":"https://mintp.cm"}]'::jsonb),
('ecole-issea', 'filiere', 'ISSEA (statistique et économie appliquée)', 'Grandes écoles', 'Bac C / Licence / Master selon le cycle + concours', 'Institut de la CEMAC basé à Yaoundé, qui forme statisticiens et économistes ; ses concours sont communs avec d''autres écoles africaines de statistique.', '## Présentation
Les concours des cycles ISE (ingénieurs statisticiens économistes) et AS (adjoints techniques) sont organisés en commun avec d''autres écoles africaines de statistique. Le cycle TSS (techniciens supérieurs) a son propre concours.

## Ce qu''on y étudie
- Techniciens supérieurs de la statistique (TSS)
- Analystes statisticiens (AS)
- Ingénieurs statisticiens économistes (ISE)
- Licences et masters professionnels

## Comment y entrer
**Concours** annoncés sur le site de l''ISSEA (inscriptions souvent closes en début d''année).

## Conseil
Excellent niveau en mathématiques indispensable ; l''épreuve d''anglais compte pour certains cycles. Les filières ouvertes, les conditions d''accès et le calendrier changent : vérifie toujours le communiqué officiel de l''année (MINESUP et site de l''établissement).', ARRAY['Statisticien', 'Économiste', 'Analyste de données', 'Actuaire']::text[], ARRAY['Techniciens supérieurs de la statistique (TSS)', 'Analystes statisticiens (AS)', 'Ingénieurs statisticiens économistes (ISE)', 'Licences et masters professionnels']::text[], ARRAY['issea', 'statistique', 'économie', 'cemac', 'ise', 'data']::text[], '[{"titre":"Institut Sous-régional de Statistique et d''Économie Appliquée (ISSEA, Yaoundé — CEMAC)","url":"https://www.issea-cemac.org"},{"titre":"Institut National de la Statistique (INS) — annuaires et enquêtes","url":"https://ins-cameroun.cm"}]'::jsonb),
('ecole-enam', 'filiere', 'ENAM (École Nationale d''Administration et de Magistrature)', 'Grandes écoles', 'Bac, Licence ou Master selon le cycle + concours', 'Grande école de la fonction publique : administrateurs civils, magistrats, inspecteurs des impôts, du trésor et des douanes, greffiers…', '## Présentation
L''ENAM recrute sur concours dans plusieurs divisions. Les inscriptions se font en ligne sur sa plateforme de concours.

## Ce qu''on y étudie
- Administration générale
- Magistrature et greffes
- Régies financières : impôts, trésor, douanes
- Travail et prévoyance sociale (selon les années)

## Comment y entrer
**Concours** directs et professionnels, inscription en ligne.

## Conseil
Prépare sérieusement la culture générale et le droit ; méfie-toi de toute offre de « place payée ». Les filières ouvertes, les conditions d''accès et le calendrier changent : vérifie toujours le communiqué officiel de l''année (MINESUP et site de l''établissement).', ARRAY['Administrateur civil', 'Magistrat', 'Inspecteur des impôts', 'Inspecteur des douanes']::text[], ARRAY['Administration générale', 'Magistrature et greffes', 'Régies financières', 'Travail et prévoyance sociale (selon les années)']::text[], ARRAY['enam', 'administration', 'magistrature', 'fonction publique', 'concours']::text[], '[{"titre":"École Nationale d''Administration et de Magistrature (ENAM)","url":"https://www.enam.cm"},{"titre":"Plateforme des concours de l''ENAM","url":"https://concours.enam.cm"}]'::jsonb),
('etudier-region-centre', 'filiere', 'Étudier dans la région du Centre', 'Étudier par région', 'Après le Bac / GCE A Level', 'Université d''État de la région : Yaoundé I et Yaoundé II-Soa. Écoles et instituts publics notables : UY1, ENSP, ENS, FMSB, ESSTIC, IRIC, ENSTP, ENAM, ISSEA.', '## Université d''État
- Yaoundé I et Yaoundé II-Soa

## Écoles et instituts publics
- UY1, ENSP, ENS, FMSB, ESSTIC, IRIC, ENSTP, ENAM, ISSEA

## Autres possibilités
- Instituts privés d''enseignement supérieur (IPES) agréés par le MINESUP : BTS, HND, licences
- Centres de formation professionnelle agréés par le MINEFOP
- Lycées techniques et formations courtes

## Conseil
Étudier dans sa région réduit le coût du logement et du transport. Vérifie toujours l''agrément d''un établissement privé avant de payer. Les filières ouvertes, les conditions d''accès et le calendrier changent : vérifie toujours le communiqué officiel de l''année (MINESUP et site de l''établissement).', ARRAY[]::text[], ARRAY['Yaoundé I et Yaoundé II-Soa']::text[], ARRAY['centre', 'région', 'étudier près de chez moi', 'université', 'yaoundé', 'i', 'et', 'yaoundé', 'ii-soa']::text[], '[{"titre":"Université de Yaoundé I (ENSP, ENS, FMSB, Faculté des Sciences)","url":"http://www.uy1.uninet.cm"},{"titre":"Université de Yaoundé II-Soa (Droit, Économie, ESSTIC, IRIC)","url":"https://site.univ-yaounde2.org"},{"titre":"École Nationale Supérieure Polytechnique de Yaoundé (ENSPY) — concours","url":"https://polytechnique.cm"},{"titre":"Ministère de l''Enseignement Supérieur (MINESUP) — concours, BTS/HND, établissements","url":"https://www.minesup.gov.cm"},{"titre":"Ministère de l''Emploi et de la Formation Professionnelle (MINEFOP) — centres agréés, examens, bourses","url":"https://www.minefop.gov.cm"}]'::jsonb),
('etudier-region-littoral', 'filiere', 'Étudier dans la région du Littoral', 'Étudier par région', 'Après le Bac / GCE A Level', 'Université d''État de la région : Douala. Écoles et instituts publics notables : ENSPD, ENSET, ESSEC, IUT de Douala, FMSP.', '## Université d''État
- Douala

## Écoles et instituts publics
- ENSPD, ENSET, ESSEC, IUT de Douala, FMSP

## Autres possibilités
- Instituts privés d''enseignement supérieur (IPES) agréés par le MINESUP : BTS, HND, licences
- Centres de formation professionnelle agréés par le MINEFOP
- Lycées techniques et formations courtes

## Conseil
Étudier dans sa région réduit le coût du logement et du transport. Vérifie toujours l''agrément d''un établissement privé avant de payer. Les filières ouvertes, les conditions d''accès et le calendrier changent : vérifie toujours le communiqué officiel de l''année (MINESUP et site de l''établissement).', ARRAY[]::text[], ARRAY['Douala']::text[], ARRAY['littoral', 'région', 'étudier près de chez moi', 'université', 'douala']::text[], '[{"titre":"Université de Douala (ENSPD, ENSET, IUT, FMSP, ESSEC)","url":"https://www.univ-douala.cm"},{"titre":"ESSEC — École Supérieure des Sciences Économiques et Commerciales, Université de Douala","url":"https://essec-douala.cm"},{"titre":"Ministère de l''Enseignement Supérieur (MINESUP) — concours, BTS/HND, établissements","url":"https://www.minesup.gov.cm"},{"titre":"Ministère de l''Emploi et de la Formation Professionnelle (MINEFOP) — centres agréés, examens, bourses","url":"https://www.minefop.gov.cm"}]'::jsonb),
('etudier-region-ouest', 'filiere', 'Étudier dans la région de l''Ouest', 'Étudier par région', 'Après le Bac / GCE A Level', 'Université d''État de la région : Dschang. Écoles et instituts publics notables : FASA, IUT Fotso Victor de Bandjoun.', '## Université d''État
- Dschang

## Écoles et instituts publics
- FASA, IUT Fotso Victor de Bandjoun

## Autres possibilités
- Instituts privés d''enseignement supérieur (IPES) agréés par le MINESUP : BTS, HND, licences
- Centres de formation professionnelle agréés par le MINEFOP
- Lycées techniques et formations courtes

## Conseil
Étudier dans sa région réduit le coût du logement et du transport. Vérifie toujours l''agrément d''un établissement privé avant de payer. Les filières ouvertes, les conditions d''accès et le calendrier changent : vérifie toujours le communiqué officiel de l''année (MINESUP et site de l''établissement).', ARRAY[]::text[], ARRAY['Dschang']::text[], ARRAY['ouest', 'région', 'étudier près de chez moi', 'université', 'dschang']::text[], '[{"titre":"Université de Dschang (FASA, IUT Fotso Victor de Bandjoun)","url":"https://www.univ-dschang.org"},{"titre":"Faculté d''Agronomie et des Sciences Agricoles (FASA), Université de Dschang","url":"https://www.univ-dschang.org/fasa/"},{"titre":"Ministère de l''Enseignement Supérieur (MINESUP) — concours, BTS/HND, établissements","url":"https://www.minesup.gov.cm"},{"titre":"Ministère de l''Emploi et de la Formation Professionnelle (MINEFOP) — centres agréés, examens, bourses","url":"https://www.minefop.gov.cm"}]'::jsonb),
('etudier-region-sud-ouest', 'filiere', 'Étudier dans la région du Sud-Ouest', 'Étudier par région', 'Après le Bac / GCE A Level', 'Université d''État de la région : Buea. Écoles et instituts publics notables : Faculty of Health Sciences, ASTI, College of Technology.', '## Université d''État
- Buea

## Écoles et instituts publics
- Faculty of Health Sciences, ASTI, College of Technology

## Autres possibilités
- Instituts privés d''enseignement supérieur (IPES) agréés par le MINESUP : BTS, HND, licences
- Centres de formation professionnelle agréés par le MINEFOP
- Lycées techniques et formations courtes

## Conseil
Étudier dans sa région réduit le coût du logement et du transport. Vérifie toujours l''agrément d''un établissement privé avant de payer. Les filières ouvertes, les conditions d''accès et le calendrier changent : vérifie toujours le communiqué officiel de l''année (MINESUP et site de l''établissement).', ARRAY[]::text[], ARRAY['Buea']::text[], ARRAY['sud-ouest', 'région', 'étudier près de chez moi', 'université', 'buea']::text[], '[{"titre":"University of Buea (Faculty of Health Sciences, ASTI, COT, faculties)","url":"https://www.ubuea.cm"},{"titre":"Ministère de l''Enseignement Supérieur (MINESUP) — concours, BTS/HND, établissements","url":"https://www.minesup.gov.cm"},{"titre":"Ministère de l''Emploi et de la Formation Professionnelle (MINEFOP) — centres agréés, examens, bourses","url":"https://www.minefop.gov.cm"}]'::jsonb),
('etudier-region-nord-ouest', 'filiere', 'Étudier dans la région du Nord-Ouest', 'Étudier par région', 'Après le Bac / GCE A Level', 'Université d''État de la région : Bamenda. Écoles et instituts publics notables : COLTECH, HTTTC, NAHPI.', '## Université d''État
- Bamenda

## Écoles et instituts publics
- COLTECH, HTTTC, NAHPI

## Autres possibilités
- Instituts privés d''enseignement supérieur (IPES) agréés par le MINESUP : BTS, HND, licences
- Centres de formation professionnelle agréés par le MINEFOP
- Lycées techniques et formations courtes

## Conseil
Étudier dans sa région réduit le coût du logement et du transport. Vérifie toujours l''agrément d''un établissement privé avant de payer. Les filières ouvertes, les conditions d''accès et le calendrier changent : vérifie toujours le communiqué officiel de l''année (MINESUP et site de l''établissement).', ARRAY[]::text[], ARRAY['Bamenda']::text[], ARRAY['nord-ouest', 'région', 'étudier près de chez moi', 'université', 'bamenda']::text[], '[{"titre":"The University of Bamenda (COLTECH, HTTTC, NAHPI)","url":"https://uniba.cm"},{"titre":"Ministère de l''Enseignement Supérieur (MINESUP) — concours, BTS/HND, établissements","url":"https://www.minesup.gov.cm"},{"titre":"Ministère de l''Emploi et de la Formation Professionnelle (MINEFOP) — centres agréés, examens, bourses","url":"https://www.minefop.gov.cm"}]'::jsonb),
('etudier-region-adamaoua', 'filiere', 'Étudier dans la région de l''Adamaoua', 'Étudier par région', 'Après le Bac / GCE A Level', 'Université d''État de la région : Ngaoundéré. Écoles et instituts publics notables : ENSAI, ESMV, IUT de Ngaoundéré.', '## Université d''État
- Ngaoundéré

## Écoles et instituts publics
- ENSAI, ESMV, IUT de Ngaoundéré

## Autres possibilités
- Instituts privés d''enseignement supérieur (IPES) agréés par le MINESUP : BTS, HND, licences
- Centres de formation professionnelle agréés par le MINEFOP
- Lycées techniques et formations courtes

## Conseil
Étudier dans sa région réduit le coût du logement et du transport. Vérifie toujours l''agrément d''un établissement privé avant de payer. Les filières ouvertes, les conditions d''accès et le calendrier changent : vérifie toujours le communiqué officiel de l''année (MINESUP et site de l''établissement).', ARRAY[]::text[], ARRAY['Ngaoundéré']::text[], ARRAY['adamaoua', 'région', 'étudier près de chez moi', 'université', 'ngaoundéré']::text[], '[{"titre":"Université de Ngaoundéré (ENSAI, ESMV, IUT, facultés)","url":"https://www.univ-ndere.cm"},{"titre":"École Nationale Supérieure des Sciences Agro-Industrielles (ENSAI), Ngaoundéré","url":"https://ensai.univ-ndere.cm"},{"titre":"Ministère de l''Enseignement Supérieur (MINESUP) — concours, BTS/HND, établissements","url":"https://www.minesup.gov.cm"},{"titre":"Ministère de l''Emploi et de la Formation Professionnelle (MINEFOP) — centres agréés, examens, bourses","url":"https://www.minefop.gov.cm"}]'::jsonb),
('etudier-region-extreme-nord', 'filiere', 'Étudier dans la région de l''Extrême-Nord', 'Étudier par région', 'Après le Bac / GCE A Level', 'Université d''État de la région : Maroua. Écoles et instituts publics notables : ENS de Maroua, ENSPM, Institut des Mines et des Industries Pétrolières.', '## Université d''État
- Maroua

## Écoles et instituts publics
- ENS de Maroua, ENSPM, Institut des Mines et des Industries Pétrolières

## Autres possibilités
- Instituts privés d''enseignement supérieur (IPES) agréés par le MINESUP : BTS, HND, licences
- Centres de formation professionnelle agréés par le MINEFOP
- Lycées techniques et formations courtes

## Conseil
Étudier dans sa région réduit le coût du logement et du transport. Vérifie toujours l''agrément d''un établissement privé avant de payer. Les filières ouvertes, les conditions d''accès et le calendrier changent : vérifie toujours le communiqué officiel de l''année (MINESUP et site de l''établissement).', ARRAY[]::text[], ARRAY['Maroua']::text[], ARRAY['extrême-nord', 'région', 'étudier près de chez moi', 'université', 'maroua']::text[], '[{"titre":"Université de Maroua (ENS, ENSPM, facultés)","url":"http://www.univ-maroua.cm"},{"titre":"Ministère de l''Enseignement Supérieur (MINESUP) — concours, BTS/HND, établissements","url":"https://www.minesup.gov.cm"},{"titre":"Ministère de l''Emploi et de la Formation Professionnelle (MINEFOP) — centres agréés, examens, bourses","url":"https://www.minefop.gov.cm"}]'::jsonb),
('etudier-region-nord', 'filiere', 'Étudier dans la région du Nord', 'Étudier par région', 'Après le Bac / GCE A Level', 'Université d''État de la région : Garoua (créée en 2022). Écoles et instituts publics notables : nouvelle université en développement ; École de Faune de Garoua (MINFOF).', '## Université d''État
- Garoua (créée en 2022)

## Écoles et instituts publics
- nouvelle université en développement ; École de Faune de Garoua (MINFOF)

## Autres possibilités
- Instituts privés d''enseignement supérieur (IPES) agréés par le MINESUP : BTS, HND, licences
- Centres de formation professionnelle agréés par le MINEFOP
- Lycées techniques et formations courtes

## Conseil
Étudier dans sa région réduit le coût du logement et du transport. Vérifie toujours l''agrément d''un établissement privé avant de payer. Les filières ouvertes, les conditions d''accès et le calendrier changent : vérifie toujours le communiqué officiel de l''année (MINESUP et site de l''établissement).', ARRAY[]::text[], ARRAY['Garoua (créée en 2022)']::text[], ARRAY['nord', 'région', 'étudier près de chez moi', 'université', 'garoua', '(créée', 'en', '2022)']::text[], '[{"titre":"Université de Garoua (créée en 2022)"},{"titre":"Ministère des Forêts et de la Faune (MINFOF) — ENEF Mbalmayo, École de Faune de Garoua","url":"https://www.minfof.gov.cm"},{"titre":"Ministère de l''Enseignement Supérieur (MINESUP) — concours, BTS/HND, établissements","url":"https://www.minesup.gov.cm"},{"titre":"Ministère de l''Emploi et de la Formation Professionnelle (MINEFOP) — centres agréés, examens, bourses","url":"https://www.minefop.gov.cm"}]'::jsonb),
('etudier-region-est', 'filiere', 'Étudier dans la région de l''Est', 'Étudier par région', 'Après le Bac / GCE A Level', 'Université d''État de la région : Bertoua (créée en 2022). Écoles et instituts publics notables : nouvelle université en développement.', '## Université d''État
- Bertoua (créée en 2022)

## Écoles et instituts publics
- nouvelle université en développement

## Autres possibilités
- Instituts privés d''enseignement supérieur (IPES) agréés par le MINESUP : BTS, HND, licences
- Centres de formation professionnelle agréés par le MINEFOP
- Lycées techniques et formations courtes

## Conseil
Étudier dans sa région réduit le coût du logement et du transport. Vérifie toujours l''agrément d''un établissement privé avant de payer. Les filières ouvertes, les conditions d''accès et le calendrier changent : vérifie toujours le communiqué officiel de l''année (MINESUP et site de l''établissement).', ARRAY[]::text[], ARRAY['Bertoua (créée en 2022)']::text[], ARRAY['est', 'région', 'étudier près de chez moi', 'université', 'bertoua', '(créée', 'en', '2022)']::text[], '[{"titre":"Université de Bertoua (créée en 2022)"},{"titre":"Ministère de l''Enseignement Supérieur (MINESUP) — concours, BTS/HND, établissements","url":"https://www.minesup.gov.cm"},{"titre":"Ministère de l''Emploi et de la Formation Professionnelle (MINEFOP) — centres agréés, examens, bourses","url":"https://www.minefop.gov.cm"}]'::jsonb),
('etudier-region-sud', 'filiere', 'Étudier dans la région du Sud', 'Étudier par région', 'Après le Bac / GCE A Level', 'Université d''État de la région : Ebolowa (créée en 2022). Écoles et instituts publics notables : nouvelle université en développement.', '## Université d''État
- Ebolowa (créée en 2022)

## Écoles et instituts publics
- nouvelle université en développement

## Autres possibilités
- Instituts privés d''enseignement supérieur (IPES) agréés par le MINESUP : BTS, HND, licences
- Centres de formation professionnelle agréés par le MINEFOP
- Lycées techniques et formations courtes

## Conseil
Étudier dans sa région réduit le coût du logement et du transport. Vérifie toujours l''agrément d''un établissement privé avant de payer. Les filières ouvertes, les conditions d''accès et le calendrier changent : vérifie toujours le communiqué officiel de l''année (MINESUP et site de l''établissement).', ARRAY[]::text[], ARRAY['Ebolowa (créée en 2022)']::text[], ARRAY['sud', 'région', 'étudier près de chez moi', 'université', 'ebolowa', '(créée', 'en', '2022)']::text[], '[{"titre":"Université d''Ebolowa (créée en 2022)"},{"titre":"Ministère de l''Enseignement Supérieur (MINESUP) — concours, BTS/HND, établissements","url":"https://www.minesup.gov.cm"},{"titre":"Ministère de l''Emploi et de la Formation Professionnelle (MINEFOP) — centres agréés, examens, bourses","url":"https://www.minefop.gov.cm"}]'::jsonb),
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
Prépare le concours avec les annales dès la Terminale et garde un plan B (paramédical, biologie) pour ne pas perdre d''année.', ARRAY[]::text[], ARRAY['FMSB', 'FMSP Douala', 'FHS Buea']::text[], ARRAY['médecin', 'médecine', 'docteur', 'hôpital', 'santé']::text[], '[{"titre":"Ministère de l''Enseignement Supérieur (MINESUP) — concours, BTS/HND, établissements","url":"https://www.minesup.gov.cm"},{"titre":"Université de Yaoundé I (ENSP, ENS, FMSB, Faculté des Sciences)","url":"http://www.uy1.uninet.cm"},{"titre":"Ministère de la Santé Publique (MINSANTE) — écoles de formation paramédicale","url":"https://www.minsante.cm"}]'::jsonb),
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
Vérifie absolument que ton école est agréée : un diplôme non reconnu ne permet ni concours ni emploi public.', ARRAY[]::text[], ARRAY['Écoles paramédicales MINSANTE', 'BTS/HND santé']::text[], ARRAY['infirmier / infirmière', 'infirmière', 'soins', 'paramédical']::text[], '[{"titre":"Ministère de la Santé Publique (MINSANTE) — écoles de formation paramédicale","url":"https://www.minsante.cm"},{"titre":"Ministère de l''Enseignement Supérieur (MINESUP) — concours, BTS/HND, établissements","url":"https://www.minesup.gov.cm"}]'::jsonb),
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
Les stages en maternité sont décisifs : sois présent(e) et curieux(se).', ARRAY[]::text[], ARRAY['Écoles de sages-femmes', 'Filières santé des universités']::text[], ARRAY['sage-femme / maïeuticien', 'sage femme', 'accouchement', 'maternité', 'maïeutique']::text[], '[{"titre":"Ministère de la Santé Publique (MINSANTE) — écoles de formation paramédicale","url":"https://www.minsante.cm"},{"titre":"Ministère de l''Enseignement Supérieur (MINESUP) — concours, BTS/HND, établissements","url":"https://www.minesup.gov.cm"}]'::jsonb),
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
Excellente chimie et biologie indispensables ; informe-toi aussi sur la pharmacie hospitalière et l''industrie.', ARRAY[]::text[], ARRAY['FMSB', 'FMSP Douala']::text[], ARRAY['pharmacien', 'pharmacie', 'médicaments', 'officine']::text[], '[{"titre":"Ministère de l''Enseignement Supérieur (MINESUP) — concours, BTS/HND, établissements","url":"https://www.minesup.gov.cm"},{"titre":"Ministère de la Santé Publique (MINSANTE) — écoles de formation paramédicale","url":"https://www.minsante.cm"}]'::jsonb),
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
Les séries D et F7 préparent bien à ce métier.', ARRAY[]::text[], ARRAY['Écoles paramédicales', 'BTS/HND biologie médicale']::text[], ARRAY['technicien de laboratoire d''analyses médicales', 'laborantin', 'analyses', 'biologie médicale']::text[], '[{"titre":"Ministère de la Santé Publique (MINSANTE) — écoles de formation paramédicale","url":"https://www.minsante.cm"},{"titre":"Ministère de l''Enseignement Supérieur (MINESUP) — concours, BTS/HND, établissements","url":"https://www.minesup.gov.cm"}]'::jsonb),
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
Associe compétences vétérinaires et gestion pour créer ton propre élevage ou cabinet.', ARRAY[]::text[], ARRAY['Université de Ngaoundéré', 'Centres MINEPIA']::text[], ARRAY['vétérinaire / technicien d''élevage', 'animaux', 'élevage', 'volaille', 'bétail']::text[], '[{"titre":"Ministère de l''Élevage, des Pêches et des Industries Animales (MINEPIA)","url":"https://minepia.cm"},{"titre":"Université de Ngaoundéré (ENSAI, ESMV, IUT, facultés)","url":"https://www.univ-ndere.cm"},{"titre":"Ministère de l''Enseignement Supérieur (MINESUP) — concours, BTS/HND, établissements","url":"https://www.minesup.gov.cm"}]'::jsonb),
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
Apprends tôt un logiciel de dessin et de calcul de structures, et fais des stages sur de vrais chantiers.', ARRAY[]::text[], ARRAY['ENSP Yaoundé', 'ENSPD Douala', 'ENSTP']::text[], ARRAY['ingénieur en génie civil', 'btp', 'bâtiment', 'travaux publics', 'routes', 'ponts', 'construction']::text[], '[{"titre":"Ministère de l''Enseignement Supérieur (MINESUP) — concours, BTS/HND, établissements","url":"https://www.minesup.gov.cm"},{"titre":"Université de Yaoundé I (ENSP, ENS, FMSB, Faculté des Sciences)","url":"http://www.uy1.uninet.cm"},{"titre":"Ministère des Travaux Publics (MINTP)","url":"https://mintp.cm"}]'::jsonb),
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
Maîtrise les métrés et les devis : c''est la base pour devenir un jour chef d''entreprise.', ARRAY[]::text[], ARRAY['Lycées techniques', 'IUT', 'BTS/HND']::text[], ARRAY['technicien en bâtiment et travaux publics / chef de chantier', 'chantier', 'bâtiment', 'maçonnerie', 'f4', 'génie civil']::text[], '[{"titre":"Office du Baccalauréat du Cameroun (OBC) — Probatoire, Baccalauréat, BT","url":"https://www.obc.cm"},{"titre":"Ministère de l''Enseignement Supérieur (MINESUP) — concours, BTS/HND, établissements","url":"https://www.minesup.gov.cm"},{"titre":"Ministère de l''Emploi et de la Formation Professionnelle (MINEFOP) — centres agréés, examens, bourses","url":"https://www.minefop.gov.cm"}]'::jsonb),
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
Dessine beaucoup et apprends un logiciel de modélisation 3D.', ARRAY[]::text[], ARRAY['Institut des Beaux-Arts de Foumban', 'Écoles d''architecture']::text[], ARRAY['architecte', 'architecture', 'plans', 'urbanisme', 'design']::text[], '[{"titre":"Ministère de l''Enseignement Supérieur (MINESUP) — concours, BTS/HND, établissements","url":"https://www.minesup.gov.cm"},{"titre":"Université de Dschang (FASA, IUT Fotso Victor de Bandjoun)","url":"https://www.univ-dschang.org"}]'::jsonb),
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
Apprends les logiciels de SIG (systèmes d''information géographique).', ARRAY[]::text[], ARRAY['ENSTP', 'BTS/HND topographie']::text[], ARRAY['géomètre-topographe', 'topographie', 'foncier', 'cadastre', 'bornage', 'sig']::text[], '[{"titre":"Ministère des Travaux Publics (MINTP)","url":"https://mintp.cm"},{"titre":"Ministère de l''Enseignement Supérieur (MINESUP) — concours, BTS/HND, établissements","url":"https://www.minesup.gov.cm"}]'::jsonb),
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
Ajoute le solaire photovoltaïque à tes compétences et soigne ta réputation : le bouche-à-oreille fait le chiffre d''affaires.', ARRAY[]::text[], ARRAY['Lycées techniques (F3)', 'Centres MINEFOP', 'BTS/HND']::text[], ARRAY['électricien (bâtiment et industrie)', 'électricité', 'électrotechnique', 'f3', 'solaire', 'installation']::text[], '[{"titre":"Office du Baccalauréat du Cameroun (OBC) — Probatoire, Baccalauréat, BT","url":"https://www.obc.cm"},{"titre":"Ministère de l''Emploi et de la Formation Professionnelle (MINEFOP) — centres agréés, examens, bourses","url":"https://www.minefop.gov.cm"}]'::jsonb),
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
Commence par de petites installations bien faites et garanties ; ta réputation sera ton meilleur argument.', ARRAY[]::text[], ARRAY['BTS/HND énergies renouvelables', 'Licences professionnelles']::text[], ARRAY['technicien en énergies renouvelables (solaire)', 'énergie', 'solaire', 'photovoltaïque', 'renouvelable']::text[], '[{"titre":"Ministère de l''Enseignement Supérieur (MINESUP) — concours, BTS/HND, établissements","url":"https://www.minesup.gov.cm"},{"titre":"Ministère de l''Emploi et de la Formation Professionnelle (MINEFOP) — centres agréés, examens, bourses","url":"https://www.minefop.gov.cm"}]'::jsonb),
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
Forme-toi au diagnostic électronique : les garages modernes en manquent.', ARRAY[]::text[], ARRAY['Lycées techniques', 'Centres MINEFOP']::text[], ARRAY['mécanicien automobile / technicien de maintenance', 'mécanique', 'garage', 'automobile', 'moto', 'maintenance']::text[], '[{"titre":"Ministère de l''Emploi et de la Formation Professionnelle (MINEFOP) — centres agréés, examens, bourses","url":"https://www.minefop.gov.cm"},{"titre":"Office du Baccalauréat du Cameroun (OBC) — Probatoire, Baccalauréat, BT","url":"https://www.obc.cm"}]'::jsonb),
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
Les chambres froides pour l''agroalimentaire et la pêche sont un marché porteur.', ARRAY[]::text[], ARRAY['Lycées techniques (F5)', 'Centres MINEFOP']::text[], ARRAY['frigoriste / technicien froid et climatisation', 'froid', 'climatisation', 'f5', 'réfrigération']::text[], '[{"titre":"Office du Baccalauréat du Cameroun (OBC) — Probatoire, Baccalauréat, BT","url":"https://www.obc.cm"},{"titre":"Ministère de l''Emploi et de la Formation Professionnelle (MINEFOP) — centres agréés, examens, bourses","url":"https://www.minefop.gov.cm"}]'::jsonb),
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
Construis des projets concrets (paiement mobile, gestion d''école, commerce en ligne) et publie ton code.', ARRAY[]::text[], ARRAY['Facultés des sciences', 'IUT', 'ENSP (génie informatique)', 'BTS/HND']::text[], ARRAY['développeur / ingénieur logiciel', 'informatique', 'programmation', 'développeur', 'web', 'mobile', 'application', 'code']::text[], '[{"titre":"Ministère de l''Enseignement Supérieur (MINESUP) — concours, BTS/HND, établissements","url":"https://www.minesup.gov.cm"},{"titre":"Ministère des Postes et Télécommunications (MINPOSTEL)","url":"https://www.minpostel.gov.cm"}]'::jsonb),
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
Les certifications reconnues (réseaux, sécurité) font la différence à l''embauche.', ARRAY[]::text[], ARRAY['IUT', 'ENSP', 'BTS/HND']::text[], ARRAY['technicien / ingénieur réseaux et télécommunications', 'réseaux', 'télécoms', 'fibre', 'cybersécurité', 'internet']::text[], '[{"titre":"Ministère de l''Enseignement Supérieur (MINESUP) — concours, BTS/HND, établissements","url":"https://www.minesup.gov.cm"},{"titre":"Ministère des Postes et Télécommunications (MINPOSTEL)","url":"https://www.minpostel.gov.cm"}]'::jsonb),
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
Apprends un outil d''analyse de données (tableur avancé puis un langage de programmation) en plus des statistiques.', ARRAY[]::text[], ARRAY['ISSEA', 'Facultés des sciences']::text[], ARRAY['analyste de données / statisticien', 'données', 'data', 'statistique', 'analyse', 'excel', 'python']::text[], '[{"titre":"Institut Sous-régional de Statistique et d''Économie Appliquée (ISSEA, Yaoundé — CEMAC)","url":"https://www.issea-cemac.org"},{"titre":"Institut National de la Statistique (INS) — annuaires et enquêtes","url":"https://ins-cameroun.cm"}]'::jsonb),
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
Maîtrise les deux systèmes juridiques camerounais et les deux langues officielles.', ARRAY[]::text[], ARRAY['Facultés de droit']::text[], ARRAY['avocat', 'avocat', 'barreau', 'droit', 'justice', 'plaider']::text[], '[{"titre":"Ministère de l''Enseignement Supérieur (MINESUP) — concours, BTS/HND, établissements","url":"https://www.minesup.gov.cm"},{"titre":"Ministère de la Justice — textes de loi (LEGALIS), professions judiciaires","url":"http://www.minjustice.gov.cm"}]'::jsonb),
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
Prépare le concours avec sérieux (droit, culture générale) et méfie-toi des promesses de places payantes.', ARRAY[]::text[], ARRAY['ENAM']::text[], ARRAY['magistrat', 'juge', 'magistrature', 'tribunal', 'procureur']::text[], '[{"titre":"École Nationale d''Administration et de Magistrature (ENAM)","url":"https://www.enam.cm"},{"titre":"Plateforme des concours de l''ENAM","url":"https://concours.enam.cm"},{"titre":"Ministère de la Justice — textes de loi (LEGALIS), professions judiciaires","url":"http://www.minjustice.gov.cm"}]'::jsonb),
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
Économie, comptabilité et droit fiscal sont les matières à soigner.', ARRAY[]::text[], ARRAY['ENAM']::text[], ARRAY['inspecteur des impôts, du trésor ou des douanes', 'impôts', 'douane', 'trésor', 'fiscalité', 'régies financières']::text[], '[{"titre":"École Nationale d''Administration et de Magistrature (ENAM)","url":"https://www.enam.cm"},{"titre":"Ministère des Finances (MINFI) — impôts, douanes, trésor","url":"https://minfi.gov.cm"}]'::jsonb),
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
Apprends une troisième langue et suis l''actualité internationale chaque jour.', ARRAY[]::text[], ARRAY['IRIC']::text[], ARRAY['diplomate', 'diplomatie', 'ambassade', 'affaires étrangères', 'iric']::text[], '[{"titre":"Université de Yaoundé II-Soa (Droit, Économie, ESSTIC, IRIC)","url":"https://site.univ-yaounde2.org"},{"titre":"Ministère de l''Enseignement Supérieur (MINESUP) — concours, BTS/HND, établissements","url":"https://www.minesup.gov.cm"}]'::jsonb),
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
Commence petit, tiens une comptabilité dès le premier jour et réinvestis tes bénéfices.', ARRAY[]::text[], ARRAY['Toutes filières', 'Programmes du FNE']::text[], ARRAY['entrepreneur / créateur d''entreprise', 'entreprise', 'auto-emploi', 'business', 'création', 'startup']::text[], '[{"titre":"Fonds National de l''Emploi (FNE) — emploi, stages, auto-emploi (services gratuits)","url":"https://fnecm.org"},{"titre":"Ministère de l''Emploi et de la Formation Professionnelle (MINEFOP) — centres agréés, examens, bourses","url":"https://www.minefop.gov.cm"}]'::jsonb),
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
Pense agrobusiness : production, transformation et vente.', ARRAY[]::text[], ARRAY['FASA', 'Écoles MINADER', 'BTS/HND']::text[], ARRAY['ingénieur agronome / technicien d''agriculture', 'agriculture', 'agronomie', 'cacao', 'café', 'exploitation', 'fasa']::text[], '[{"titre":"Ministère de l''Agriculture et du Développement Rural (MINADER) — écoles d''agriculture","url":"https://www.minader.cm"},{"titre":"Université de Dschang (FASA, IUT Fotso Victor de Bandjoun)","url":"https://www.univ-dschang.org"},{"titre":"Ministère de l''Enseignement Supérieur (MINESUP) — concours, BTS/HND, établissements","url":"https://www.minesup.gov.cm"}]'::jsonb),
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
Commence par une petite unité, maîtrise-la, puis agrandis-toi.', ARRAY[]::text[], ARRAY['Centres MINADER / MINEPIA', 'Formation professionnelle']::text[], ARRAY['agro-entrepreneur (aviculture, pisciculture, maraîchage)', 'aviculture', 'pisciculture', 'élevage', 'maraîchage', 'poulets', 'agrobusiness']::text[], '[{"titre":"Ministère de l''Agriculture et du Développement Rural (MINADER) — écoles d''agriculture","url":"https://www.minader.cm"},{"titre":"Ministère de l''Élevage, des Pêches et des Industries Animales (MINEPIA)","url":"https://minepia.cm"},{"titre":"Fonds National de l''Emploi (FNE) — emploi, stages, auto-emploi (services gratuits)","url":"https://fnecm.org"}]'::jsonb),
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
Les petites unités de transformation (fruits, manioc, soja) sont accessibles aux jeunes entrepreneurs formés.', ARRAY[]::text[], ARRAY['ENSAI', 'IUT', 'BTS/HND']::text[], ARRAY['ingénieur / technicien agroalimentaire', 'agroalimentaire', 'transformation', 'ensai', 'qualité', 'industrie alimentaire']::text[], '[{"titre":"Université de Ngaoundéré (ENSAI, ESMV, IUT, facultés)","url":"https://www.univ-ndere.cm"},{"titre":"Ministère de l''Enseignement Supérieur (MINESUP) — concours, BTS/HND, établissements","url":"https://www.minesup.gov.cm"}]'::jsonb),
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
Associe terrain et outils numériques (SIG, télédétection).', ARRAY[]::text[], ARRAY['FASA', 'Écoles des eaux et forêts']::text[], ARRAY['ingénieur forestier / spécialiste de l''environnement', 'forêt', 'environnement', 'climat', 'faune', 'écologie']::text[], '[{"titre":"Université de Dschang (FASA, IUT Fotso Victor de Bandjoun)","url":"https://www.univ-dschang.org"},{"titre":"Ministère de l''Enseignement Supérieur (MINESUP) — concours, BTS/HND, établissements","url":"https://www.minesup.gov.cm"}]'::jsonb),
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
Écris et produis dès maintenant (journal scolaire, podcast, blog).', ARRAY[]::text[], ARRAY['ESSTIC']::text[], ARRAY['journaliste', 'journalisme', 'médias', 'radio', 'télévision', 'presse']::text[], '[{"titre":"Université de Yaoundé II-Soa (Droit, Économie, ESSTIC, IRIC)","url":"https://site.univ-yaounde2.org"},{"titre":"Ministère de l''Enseignement Supérieur (MINESUP) — concours, BTS/HND, établissements","url":"https://www.minesup.gov.cm"}]'::jsonb),
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
Constitue un portfolio en ligne et apprends aussi le design d''interfaces (applications, sites).', ARRAY[]::text[], ARRAY['Institut des Beaux-Arts de Foumban', 'Écoles de design']::text[], ARRAY['graphiste / designer', 'design', 'graphisme', 'infographie', 'logo', 'création']::text[], '[{"titre":"Université de Dschang (FASA, IUT Fotso Victor de Bandjoun)","url":"https://www.univ-dschang.org"}]'::jsonb),
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
Lis chaque jour en français et en anglais, et apprends une troisième langue.', ARRAY[]::text[], ARRAY['ASTI', 'Facultés de lettres']::text[], ARRAY['traducteur / interprète', 'traduction', 'interprète', 'bilinguisme', 'anglais', 'langues']::text[], '[{"titre":"University of Buea (Faculty of Health Sciences, ASTI, COT, faculties)","url":"https://www.ubuea.cm"},{"titre":"Ministère de l''Enseignement Supérieur (MINESUP) — concours, BTS/HND, établissements","url":"https://www.minesup.gov.cm"}]'::jsonb),
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
Déclare tes œuvres auprès de l''organisme de gestion des droits d''auteur et apprends le marketing musical.', ARRAY[]::text[], ARRAY['Institut des Beaux-Arts de Foumban']::text[], ARRAY['artiste musicien / producteur', 'musique', 'artiste', 'chanteur', 'production', 'makossa', 'bikutsi']::text[], '[{"titre":"Université de Dschang (FASA, IUT Fotso Victor de Bandjoun)","url":"https://www.univ-dschang.org"}]'::jsonb),
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
Entraîne-toi physiquement et ne paie jamais un intermédiaire pour un recrutement.', ARRAY[]::text[], ARRAY['EMIA']::text[], ARRAY['officier des forces armées', 'armée', 'militaire', 'emia', 'officier', 'défense']::text[], '[{"titre":"Ministère de la Défense (MINDEF) — EMIA et recrutements des forces de défense","url":"https://mindef.gov.cm"}]'::jsonb),
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
Prépare l''épreuve sportive autant que l''écrit, et méfie-toi des arnaques au recrutement.', ARRAY[]::text[], ARRAY['École Nationale Supérieure de Police', 'Écoles de police']::text[], ARRAY['policier (gardien de la paix, inspecteur, officier, commissaire)', 'police', 'dgsn', 'commissaire', 'inspecteur de police', 'gardien de la paix']::text[], '[{"titre":"Délégation Générale à la Sûreté Nationale (DGSN) — concours de la police","url":"https://www.dgsn.cm"}]'::jsonb),
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
Montre tes créations sur les réseaux sociaux et soigne les finitions.', ARRAY[]::text[], ARRAY['Centres MINEFOP', 'SAR/SM']::text[], ARRAY['couturier / styliste-modéliste', 'couture', 'mode', 'stylisme', 'pagne', 'atelier']::text[], '[{"titre":"Ministère de l''Emploi et de la Formation Professionnelle (MINEFOP) — centres agréés, examens, bourses","url":"https://www.minefop.gov.cm"}]'::jsonb),
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
Forme-toi aux techniques nouvelles et tiens tes comptes.', ARRAY[]::text[], ARRAY['Centres MINEFOP']::text[], ARRAY['coiffeur / esthéticien', 'coiffure', 'esthétique', 'beauté', 'salon', 'tresses']::text[], '[{"titre":"Ministère de l''Emploi et de la Formation Professionnelle (MINEFOP) — centres agréés, examens, bourses","url":"https://www.minefop.gov.cm"}]'::jsonb),
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
Apprends le dessin assisté par ordinateur pour proposer des modèles modernes.', ARRAY[]::text[], ARRAY['Lycées techniques', 'Centres MINEFOP']::text[], ARRAY['menuisier / ébéniste', 'menuiserie', 'bois', 'meubles', 'ébénisterie']::text[], '[{"titre":"Ministère de l''Emploi et de la Formation Professionnelle (MINEFOP) — centres agréés, examens, bourses","url":"https://www.minefop.gov.cm"},{"titre":"Office du Baccalauréat du Cameroun (OBC) — Probatoire, Baccalauréat, BT","url":"https://www.obc.cm"}]'::jsonb),
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
Ajoute le solaire thermique et les pompes solaires à tes compétences.', ARRAY[]::text[], ARRAY['Centres MINEFOP']::text[], ARRAY['plombier / installateur sanitaire', 'plomberie', 'sanitaire', 'eau', 'canalisations']::text[], '[{"titre":"Ministère de l''Emploi et de la Formation Professionnelle (MINEFOP) — centres agréés, examens, bourses","url":"https://www.minefop.gov.cm"}]'::jsonb),
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
Sois transparent sur les pièces et les prix : la confiance fait revenir les clients.', ARRAY[]::text[], ARRAY['Lycées techniques (F2)', 'Centres MINEFOP']::text[], ARRAY['technicien en réparation de téléphones et d''ordinateurs', 'téléphone', 'réparation', 'électronique', 'smartphone', 'ordinateur']::text[], '[{"titre":"Ministère de l''Emploi et de la Formation Professionnelle (MINEFOP) — centres agréés, examens, bourses","url":"https://www.minefop.gov.cm"},{"titre":"Office du Baccalauréat du Cameroun (OBC) — Probatoire, Baccalauréat, BT","url":"https://www.obc.cm"}]'::jsonb),
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
Le service traiteur pour les cérémonies est un bon démarrage en auto-emploi.', ARRAY[]::text[], ARRAY['Écoles hôtelières', 'BTS/HND']::text[], ARRAY['cuisinier / professionnel de l''hôtellerie et de la restauration', 'cuisine', 'restaurant', 'hôtel', 'traiteur', 'hôtellerie']::text[], '[{"titre":"Ministère de l''Emploi et de la Formation Professionnelle (MINEFOP) — centres agréés, examens, bourses","url":"https://www.minefop.gov.cm"},{"titre":"Ministère de l''Enseignement Supérieur (MINESUP) — concours, BTS/HND, établissements","url":"https://www.minesup.gov.cm"}]'::jsonb),
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
('metier-chirurgien-dentiste', 'metier', 'Chirurgien-dentiste', 'Santé', 'Bac C ou D / A Level sciences + concours', 'Soigne les dents et la bouche : caries, extractions, prothèses, prévention.', '## Le métier
- Examiner et soigner les dents
- Poser des prothèses
- Éduquer à l''hygiène bucco-dentaire

## Comment y arriver au Cameroun
- Concours d''entrée en faculté de médecine (filière odontostomatologie / chirurgie dentaire)
- Plusieurs années d''études jusqu''au doctorat

## Qualités utiles
- Précision et habileté manuelle
- Patience
- Sens de l''hygiène

## La réalité du terrain
Les dentistes sont peu nombreux par rapport aux besoins, surtout hors des grandes villes.

## Conseil Mandal
Le concours est le même type d''épreuves que la médecine : SVT, chimie, physique.', ARRAY[]::text[], ARRAY['FMSB (Yaoundé I)', 'Facultés de médecine']::text[], ARRAY['chirurgien-dentiste', 'dentiste', 'dents', 'odontologie', 'bucco-dentaire']::text[], '[{"titre":"Ministère de l''Enseignement Supérieur (MINESUP) — concours, BTS/HND, établissements","url":"https://www.minesup.gov.cm"},{"titre":"Université de Yaoundé I (ENSP, ENS, FMSB, Faculté des Sciences)","url":"http://www.uy1.uninet.cm"},{"titre":"Ministère de la Santé Publique (MINSANTE) — écoles de formation paramédicale","url":"https://www.minsante.cm"}]'::jsonb),
('metier-kinesitherapeute', 'metier', 'Kinésithérapeute / Physiothérapeute', 'Santé', 'Baccalauréat (D, C) / A Level + formation paramédicale', 'Aide les patients à retrouver leurs mouvements après un accident, une maladie ou une opération.', '## Le métier
- Rééducation par le mouvement et les massages
- Accompagnement des personnes âgées et handicapées
- Rééducation des sportifs

## Comment y arriver au Cameroun
- Formations paramédicales publiques sur concours ou instituts privés agréés
- Licence en sciences de la réadaptation selon les établissements

## Qualités utiles
- Bonne condition physique
- Patience
- Écoute

## La réalité du terrain
Métier encore rare au Cameroun et très utile (accidents de la route, AVC, sport).

## Conseil Mandal
Vérifie que la formation est agréée et inclut beaucoup de stages pratiques.', ARRAY[]::text[], ARRAY['Écoles paramédicales', 'Instituts agréés']::text[], ARRAY['kinésithérapeute / physiothérapeute', 'kiné', 'kinésithérapie', 'rééducation', 'physiothérapie']::text[], '[{"titre":"Ministère de la Santé Publique (MINSANTE) — écoles de formation paramédicale","url":"https://www.minsante.cm"},{"titre":"Ministère de l''Enseignement Supérieur (MINESUP) — concours, BTS/HND, établissements","url":"https://www.minesup.gov.cm"}]'::jsonb),
('metier-technicien-imagerie', 'metier', 'Technicien d''imagerie médicale (radiologie)', 'Santé', 'Baccalauréat (C, D, F) / A Level + formation paramédicale', 'Réalise radiographies, échographies et scanners prescrits par les médecins.', '## Le métier
- Préparer le patient et réaliser les examens
- Respecter la radioprotection
- Entretenir les appareils

## Comment y arriver au Cameroun
- Formations paramédicales publiques sur concours
- BTS/HND en imagerie médicale dans un institut agréé

## Qualités utiles
- Rigueur
- Sens technique
- Contact humain

## La réalité du terrain
Les hôpitaux et cliniques s''équipent : les techniciens qualifiés sont recherchés.

## Conseil Mandal
La physique est importante dans ce métier.', ARRAY[]::text[], ARRAY['Écoles paramédicales', 'BTS/HND']::text[], ARRAY['technicien d''imagerie médicale (radiologie)', 'radiologie', 'imagerie', 'échographie', 'scanner']::text[], '[{"titre":"Ministère de la Santé Publique (MINSANTE) — écoles de formation paramédicale","url":"https://www.minsante.cm"},{"titre":"Ministère de l''Enseignement Supérieur (MINESUP) — concours, BTS/HND, établissements","url":"https://www.minesup.gov.cm"}]'::jsonb),
('metier-aide-soignant', 'metier', 'Aide-soignant(e)', 'Santé', 'BEPC / CAP ou Probatoire + formation', 'Assiste les infirmiers : hygiène et confort des patients, aide aux repas, surveillance.', '## Le métier
- Aider les patients dans les gestes quotidiens
- Surveiller et signaler
- Entretenir le matériel

## Comment y arriver au Cameroun
- Formations d''aide-soignant dans des écoles publiques ou privées agréées

## Qualités utiles
- Bienveillance
- Endurance
- Discrétion

## La réalité du terrain
Porte d''entrée rapide dans le secteur de la santé ; on peut ensuite viser le diplôme d''infirmier.

## Conseil Mandal
Vérifie l''agrément de l''école auprès du ministère de la Santé.', ARRAY[]::text[], ARRAY['Écoles paramédicales agréées']::text[], ARRAY['aide-soignant(e)', 'aide soignant', 'soins', 'hôpital']::text[], '[{"titre":"Ministère de la Santé Publique (MINSANTE) — écoles de formation paramédicale","url":"https://www.minsante.cm"}]'::jsonb),
('metier-nutritionniste', 'metier', 'Nutritionniste / Diététicien', 'Santé', 'Baccalauréat (D, C) + Licence/Master en nutrition', 'Conseille une alimentation adaptée pour prévenir et soigner la malnutrition, le diabète, l''hypertension.', '## Le métier
- Évaluer l''état nutritionnel
- Élaborer des régimes adaptés
- Mener des campagnes de nutrition

## Comment y arriver au Cameroun
- Licence/Master en nutrition, biochimie ou sciences des aliments

## Qualités utiles
- Pédagogie
- Rigueur scientifique
- Écoute

## La réalité du terrain
Malnutrition infantile et maladies chroniques coexistent : les besoins sont réels (hôpitaux, ONG, programmes publics).

## Conseil Mandal
Valorise les aliments locaux dans tes conseils : c''est plus efficace et moins cher.', ARRAY[]::text[], ARRAY['Facultés des sciences', 'ENSAI']::text[], ARRAY['nutritionniste / diététicien', 'nutrition', 'diététique', 'alimentation', 'malnutrition']::text[], '[{"titre":"Ministère de la Santé Publique (MINSANTE) — écoles de formation paramédicale","url":"https://www.minsante.cm"},{"titre":"Ministère de l''Enseignement Supérieur (MINESUP) — concours, BTS/HND, établissements","url":"https://www.minesup.gov.cm"}]'::jsonb),
('metier-psychologue', 'metier', 'Psychologue clinicien', 'Santé', 'Master en psychologie', 'Accompagne les personnes en souffrance psychologique : stress, traumatismes, dépression, addictions.', '## Le métier
- Entretiens et accompagnement
- Évaluations psychologiques
- Prévention en milieu scolaire et professionnel

## Comment y arriver au Cameroun
- Licence puis master en psychologie (facultés de lettres et sciences humaines)

## Qualités utiles
- Écoute
- Discrétion absolue
- Équilibre personnel

## La réalité du terrain
La santé mentale est un besoin croissant (jeunes, déplacés internes, victimes de violences).

## Conseil Mandal
Fais du bénévolat dans des associations d''écoute pour te préparer.', ARRAY[]::text[], ARRAY['Université de Yaoundé I', 'Autres facultés de lettres']::text[], ARRAY['psychologue clinicien', 'psychologie', 'santé mentale', 'écoute', 'thérapie']::text[], '[{"titre":"Ministère de l''Enseignement Supérieur (MINESUP) — concours, BTS/HND, établissements","url":"https://www.minesup.gov.cm"},{"titre":"Université de Yaoundé I (ENSP, ENS, FMSB, Faculté des Sciences)","url":"http://www.uy1.uninet.cm"}]'::jsonb),
('metier-notaire', 'metier', 'Notaire', 'Droit & administration', 'Master en droit + formation professionnelle réglementée', 'Rédige et authentifie les actes importants : ventes de terrains, successions, contrats de mariage, sociétés.', '## Le métier
- Rédiger des actes authentiques
- Sécuriser les transactions foncières
- Conseiller les familles et les entreprises

## Comment y arriver au Cameroun
- Licence puis master en droit privé
- Stage et conditions d''accès fixées par les textes régissant la profession

## Qualités utiles
- Rigueur juridique
- Probité
- Sens du conseil

## La réalité du terrain
Le foncier est un enjeu majeur au Cameroun : le notaire sécurise les achats de terrains.

## Conseil Mandal
Spécialise-toi tôt en droit foncier et droit des affaires (OHADA).', ARRAY[]::text[], ARRAY['Facultés de droit']::text[], ARRAY['notaire', 'notaire', 'foncier', 'terrain', 'succession', 'acte']::text[], '[{"titre":"Ministère de la Justice — textes de loi (LEGALIS), professions judiciaires","url":"http://www.minjustice.gov.cm"},{"titre":"Ministère de l''Enseignement Supérieur (MINESUP) — concours, BTS/HND, établissements","url":"https://www.minesup.gov.cm"}]'::jsonb),
('metier-huissier', 'metier', 'Huissier de justice', 'Droit & administration', 'Licence/Master en droit + accès réglementé', 'Signifie les actes de justice, constate des faits et fait exécuter les décisions de justice.', '## Le métier
- Signifier les décisions
- Réaliser des constats
- Recouvrer les créances

## Comment y arriver au Cameroun
- Études de droit
- Stage et conditions d''accès fixées par les textes régissant la profession

## Qualités utiles
- Fermeté
- Diplomatie
- Rigueur

## La réalité du terrain
Profession libérale réglementée, en lien étroit avec les tribunaux.

## Conseil Mandal
Le droit des procédures (OHADA) est central dans ce métier.', ARRAY[]::text[], ARRAY['Facultés de droit']::text[], ARRAY['huissier de justice', 'huissier', 'constat', 'justice', 'recouvrement']::text[], '[{"titre":"Ministère de la Justice — textes de loi (LEGALIS), professions judiciaires","url":"http://www.minjustice.gov.cm"},{"titre":"Ministère de l''Enseignement Supérieur (MINESUP) — concours, BTS/HND, établissements","url":"https://www.minesup.gov.cm"}]'::jsonb),
('metier-greffier', 'metier', 'Greffier', 'Droit & administration', 'Baccalauréat ou Licence + concours ENAM (greffes)', 'Assiste les magistrats, tient les dossiers et authentifie les actes du tribunal.', '## Le métier
- Tenir les audiences et les dossiers
- Rédiger les procès-verbaux
- Délivrer les copies de décisions

## Comment y arriver au Cameroun
- Concours de l''ENAM (division des greffes) selon le diplôme

## Qualités utiles
- Organisation
- Discrétion
- Précision

## La réalité du terrain
Fonctionnaire de la justice, affecté dans les juridictions de tout le pays.

## Conseil Mandal
Soigne ton expression écrite et tes connaissances en procédure.', ARRAY[]::text[], ARRAY['ENAM']::text[], ARRAY['greffier', 'greffier', 'greffe', 'tribunal', 'enam']::text[], '[{"titre":"École Nationale d''Administration et de Magistrature (ENAM)","url":"https://www.enam.cm"},{"titre":"Plateforme des concours de l''ENAM","url":"https://concours.enam.cm"},{"titre":"Ministère de la Justice — textes de loi (LEGALIS), professions judiciaires","url":"http://www.minjustice.gov.cm"}]'::jsonb),
('metier-juriste-entreprise', 'metier', 'Juriste d''entreprise', 'Droit & administration', 'Master en droit des affaires', 'Conseille l''entreprise sur ses contrats, ses litiges et le respect de la loi (droit OHADA, droit du travail, fiscalité).', '## Le métier
- Rédiger et vérifier les contrats
- Gérer les litiges
- Veiller à la conformité

## Comment y arriver au Cameroun
- Licence puis master en droit des affaires ou droit privé

## Qualités utiles
- Rigueur
- Esprit d''analyse
- Sens de la négociation

## La réalité du terrain
Banques, assurances, télécoms, BTP et grandes entreprises recrutent des juristes.

## Conseil Mandal
Maîtrise le droit OHADA et l''anglais juridique.', ARRAY[]::text[], ARRAY['Facultés de droit', 'Université de Yaoundé II']::text[], ARRAY['juriste d''entreprise', 'juriste', 'droit des affaires', 'ohada', 'contrats']::text[], '[{"titre":"Université de Yaoundé II-Soa (Droit, Économie, ESSTIC, IRIC)","url":"https://site.univ-yaounde2.org"},{"titre":"Ministère de l''Enseignement Supérieur (MINESUP) — concours, BTS/HND, établissements","url":"https://www.minesup.gov.cm"}]'::jsonb),
('metier-gendarme', 'metier', 'Gendarme', 'Défense & sécurité', 'BEPC à Licence selon le grade + recrutement MINDEF', 'Militaire chargé de la sécurité publique, surtout en zones rurales et sur les routes, et de la police judiciaire.', '## Le métier
- Sécurité des populations
- Enquêtes judiciaires
- Contrôles routiers et maintien de l''ordre

## Comment y arriver au Cameroun
- Recrutements annoncés par le MINDEF (élèves gendarmes, sous-officiers, officiers)
- Formation dans les écoles de gendarmerie

## Qualités utiles
- Intégrité
- Condition physique
- Discipline

## La réalité du terrain
Affectations sur tout le territoire ; la gendarmerie dépend du ministère de la Défense.

## Conseil Mandal
Seuls les communiqués du MINDEF font foi : refuse tout intermédiaire payant.', ARRAY[]::text[], ARRAY['Écoles de gendarmerie']::text[], ARRAY['gendarme', 'gendarmerie', 'gendarme', 'mindef', 'sécurité']::text[], '[{"titre":"Ministère de la Défense (MINDEF) — EMIA et recrutements des forces de défense","url":"https://mindef.gov.cm"}]'::jsonb),
('metier-sapeur-pompier', 'metier', 'Sapeur-pompier', 'Défense & sécurité', 'BEPC à Baccalauréat + recrutement', 'Lutte contre les incendies, secourt les victimes d''accidents et intervient lors des catastrophes.', '## Le métier
- Éteindre les incendies
- Secours aux victimes
- Prévention des risques

## Comment y arriver au Cameroun
- Recrutements annoncés par le ministère de la Défense (corps des sapeurs-pompiers)

## Qualités utiles
- Courage
- Excellente condition physique
- Esprit d''équipe

## La réalité du terrain
Métier exigeant et très utile, avec des interventions de jour comme de nuit.

## Conseil Mandal
Apprends dès maintenant les gestes de premiers secours.', ARRAY[]::text[], ARRAY['Écoles des sapeurs-pompiers']::text[], ARRAY['sapeur-pompier', 'pompier', 'incendie', 'secours', 'sapeur']::text[], '[{"titre":"Ministère de la Défense (MINDEF) — EMIA et recrutements des forces de défense","url":"https://mindef.gov.cm"}]'::jsonb),
('metier-agent-securite', 'metier', 'Agent de sécurité privée', 'Défense & sécurité', 'Tous niveaux + formation', 'Protège les bâtiments, les biens et les personnes pour le compte d''entreprises de sécurité.', '## Le métier
- Surveillance et contrôle des accès
- Rondes
- Alerte et premiers secours

## Comment y arriver au Cameroun
- Formation interne ou dans un centre agréé
- Possibilité d''évoluer vers chef d''équipe ou superviseur

## Qualités utiles
- Vigilance
- Honnêteté
- Calme

## La réalité du terrain
Secteur qui recrute beaucoup dans les villes, avec des horaires souvent de nuit.

## Conseil Mandal
Les certificats de secourisme et d''incendie te feront progresser.', ARRAY[]::text[], ARRAY['Centres de formation agréés']::text[], ARRAY['agent de sécurité privée', 'sécurité', 'gardiennage', 'vigile']::text[], '[{"titre":"Ministère de l''Emploi et de la Formation Professionnelle (MINEFOP) — centres agréés, examens, bourses","url":"https://www.minefop.gov.cm"}]'::jsonb),
('metier-auditeur', 'metier', 'Auditeur / Contrôleur de gestion', 'Commerce & gestion', 'Master en comptabilité, finance ou audit', 'Vérifie la fiabilité des comptes et aide la direction à piloter l''entreprise avec des chiffres.', '## Le métier
- Contrôler les comptes et procédures
- Construire des tableaux de bord
- Recommander des améliorations

## Comment y arriver au Cameroun
- Licence/Master en comptabilité-contrôle-audit (FSEG, ESSEC)
- Cabinets d''audit, expertise comptable

## Qualités utiles
- Rigueur
- Esprit critique
- Intégrité

## La réalité du terrain
Cabinets d''audit, banques, ONG et grandes entreprises recrutent ; l''anglais est souvent demandé.

## Conseil Mandal
Maîtrise le référentiel comptable OHADA et le tableur avancé.', ARRAY[]::text[], ARRAY['ESSEC', 'FSEG']::text[], ARRAY['auditeur / contrôleur de gestion', 'audit', 'contrôle de gestion', 'comptabilité', 'finance']::text[], '[{"titre":"ESSEC — École Supérieure des Sciences Économiques et Commerciales, Université de Douala","url":"https://essec-douala.cm"},{"titre":"Ministère de l''Enseignement Supérieur (MINESUP) — concours, BTS/HND, établissements","url":"https://www.minesup.gov.cm"}]'::jsonb),
('metier-assureur', 'metier', 'Conseiller en assurance', 'Commerce & gestion', 'Baccalauréat + BTS/HND, Licence ou Master (assurance, finance)', 'Conseille les clients et vend des contrats d''assurance : santé, automobile, habitation, vie.', '## Le métier
- Analyser les besoins des clients
- Proposer des contrats
- Gérer les sinistres

## Comment y arriver au Cameroun
- BTS/HND assurance ou banque
- Licence/Master en finance ou assurance

## Qualités utiles
- Sens commercial
- Pédagogie
- Rigueur

## La réalité du terrain
Le taux d''assurance reste faible : le marché a un fort potentiel de croissance.

## Conseil Mandal
Comprends la micro-assurance et l''assurance mobile, très adaptées au Cameroun.', ARRAY[]::text[], ARRAY['BTS/HND', 'FSEG']::text[], ARRAY['conseiller en assurance', 'assurance', 'assureur', 'sinistre', 'contrat']::text[], '[{"titre":"Ministère de l''Enseignement Supérieur (MINESUP) — concours, BTS/HND, établissements","url":"https://www.minesup.gov.cm"},{"titre":"Ministère des Finances (MINFI) — impôts, douanes, trésor","url":"https://minfi.gov.cm"}]'::jsonb),
('metier-actuaire', 'metier', 'Actuaire', 'Commerce & gestion', 'Master en actuariat ou statistique (ISSEA, masters spécialisés)', 'Calcule les risques et les tarifs pour les assurances, les banques et les caisses de retraite.', '## Le métier
- Modéliser les risques
- Calculer les primes et les réserves
- Conseiller la direction

## Comment y arriver au Cameroun
- Bac C, puis études de mathématiques ou de statistique (ISSEA, masters d''actuariat)

## Qualités utiles
- Excellent niveau en maths
- Rigueur
- Esprit d''analyse

## La réalité du terrain
Métier rare et très recherché dans la zone CEMAC.

## Conseil Mandal
Probabilités et statistiques doivent devenir tes points forts.', ARRAY[]::text[], ARRAY['ISSEA', 'Masters de mathématiques appliquées']::text[], ARRAY['actuaire', 'actuariat', 'assurance', 'risque', 'statistique']::text[], '[{"titre":"Institut Sous-régional de Statistique et d''Économie Appliquée (ISSEA, Yaoundé — CEMAC)","url":"https://www.issea-cemac.org"},{"titre":"Ministère de l''Enseignement Supérieur (MINESUP) — concours, BTS/HND, établissements","url":"https://www.minesup.gov.cm"}]'::jsonb),
('metier-agent-immobilier', 'metier', 'Agent immobilier / Gestionnaire de biens', 'Commerce & gestion', 'Baccalauréat + formation en immobilier, commerce ou droit', 'Met en relation propriétaires et locataires ou acheteurs, et gère des biens immobiliers.', '## Le métier
- Trouver et présenter des biens
- Rédiger les baux
- Gérer les loyers et l''entretien

## Comment y arriver au Cameroun
- BTS/HND, licence en gestion, droit ou immobilier

## Qualités utiles
- Sens commercial
- Honnêteté
- Connaissance du quartier

## La réalité du terrain
Forte demande de logements en ville ; la confiance est essentielle face aux arnaques foncières.

## Conseil Mandal
Apprends les bases du droit foncier : titre foncier, bail, vente.', ARRAY[]::text[], ARRAY['BTS/HND', 'Facultés de droit']::text[], ARRAY['agent immobilier / gestionnaire de biens', 'immobilier', 'location', 'logement', 'terrain', 'bail']::text[], '[{"titre":"Ministère de l''Enseignement Supérieur (MINESUP) — concours, BTS/HND, établissements","url":"https://www.minesup.gov.cm"},{"titre":"Ministère de la Justice — textes de loi (LEGALIS), professions judiciaires","url":"http://www.minjustice.gov.cm"}]'::jsonb),
('metier-chef-de-projet', 'metier', 'Chef de projet / Gestionnaire de projets de développement', 'Commerce & gestion', 'Licence/Master (gestion, économie, ingénierie, sciences sociales)', 'Planifie et pilote des projets (construction, santé, éducation, agriculture) dans les délais et le budget.', '## Le métier
- Planifier les activités et le budget
- Coordonner les équipes et partenaires
- Suivre et évaluer les résultats

## Comment y arriver au Cameroun
- Master en gestion de projets, économie du développement ou ingénierie
- Expérience de terrain

## Qualités utiles
- Organisation
- Leadership
- Communication

## La réalité du terrain
ONG, organisations internationales, ministères et entreprises gèrent de nombreux projets.

## Conseil Mandal
Apprends le suivi-évaluation et un outil de planification.', ARRAY[]::text[], ARRAY['FSEG', 'ESSEC', 'IRIC']::text[], ARRAY['chef de projet / gestionnaire de projets de développement', 'projet', 'ong', 'gestion de projet', 'développement', 'suivi-évaluation']::text[], '[{"titre":"Ministère de l''Enseignement Supérieur (MINESUP) — concours, BTS/HND, établissements","url":"https://www.minesup.gov.cm"}]'::jsonb),
('metier-ingenieur-electricien', 'metier', 'Ingénieur électricien / électrotechnicien', 'Industrie & énergie', 'Bac C, E ou F3 + école d''ingénieurs', 'Conçoit et gère les installations électriques : centrales, réseaux de distribution, usines, bâtiments.', '## Le métier
- Concevoir des réseaux et installations
- Superviser les travaux
- Assurer la maintenance et la sécurité

## Comment y arriver au Cameroun
- Concours d''écoles d''ingénieurs (ENSPY, ENSPD, IUT puis admission parallèle)

## Qualités utiles
- Solide en maths et physique
- Rigueur
- Sens de la sécurité

## La réalité du terrain
Production d''électricité (barrages, solaire), distribution et industrie ont besoin d''ingénieurs.

## Conseil Mandal
Les énergies renouvelables sont une spécialisation d''avenir.', ARRAY[]::text[], ARRAY['ENSPY', 'ENSPD', 'IUT']::text[], ARRAY['ingénieur électricien / électrotechnicien', 'électricité', 'électrotechnique', 'énergie', 'barrage', 'réseau électrique']::text[], '[{"titre":"École Nationale Supérieure Polytechnique de Yaoundé (ENSPY) — concours","url":"https://polytechnique.cm"},{"titre":"Université de Douala (ENSPD, ENSET, IUT, FMSP, ESSEC)","url":"https://www.univ-douala.cm"},{"titre":"Ministère de l''Enseignement Supérieur (MINESUP) — concours, BTS/HND, établissements","url":"https://www.minesup.gov.cm"}]'::jsonb),
('metier-ingenieur-mecanique', 'metier', 'Ingénieur / Technicien en génie mécanique', 'Industrie & énergie', 'Bac C, E ou F1 + IUT ou école d''ingénieurs', 'Conçoit, fabrique et entretient les machines et équipements industriels.', '## Le métier
- Concevoir des pièces et machines
- Organiser la maintenance
- Améliorer la production

## Comment y arriver au Cameroun
- Lycée technique (F1)
- IUT, BTS/HND, écoles d''ingénieurs

## Qualités utiles
- Logique
- Sens pratique
- Rigueur

## La réalité du terrain
Usines agroalimentaires, cimenteries, brasseries, mines et BTP recrutent.

## Conseil Mandal
Apprends un logiciel de conception assistée par ordinateur.', ARRAY[]::text[], ARRAY['Lycées techniques (F1)', 'IUT', 'ENSPY', 'ENSPD']::text[], ARRAY['ingénieur / technicien en génie mécanique', 'mécanique', 'f1', 'maintenance industrielle', 'machines']::text[], '[{"titre":"École Nationale Supérieure Polytechnique de Yaoundé (ENSPY) — concours","url":"https://polytechnique.cm"},{"titre":"Université de Douala (ENSPD, ENSET, IUT, FMSP, ESSEC)","url":"https://www.univ-douala.cm"},{"titre":"Office du Baccalauréat du Cameroun (OBC) — Probatoire, Baccalauréat, BT","url":"https://www.obc.cm"}]'::jsonb),
('metier-soudeur', 'metier', 'Soudeur / Chaudronnier / Métallier', 'Industrie & énergie', 'CAP ou formation professionnelle', 'Assemble et façonne les métaux : portails, charpentes métalliques, réservoirs, structures industrielles.', '## Le métier
- Lire un plan
- Découper, souder, assembler
- Contrôler la qualité des soudures

## Comment y arriver au Cameroun
- Lycée technique / centres de formation professionnelle agréés
- Certifications de soudage pour l''industrie

## Qualités utiles
- Habileté
- Respect de la sécurité
- Précision

## La réalité du terrain
Très demandé dans le BTP, l''industrie et la menuiserie métallique ; l''auto-emploi est courant.

## Conseil Mandal
Les certifications de soudage ouvrent l''accès aux chantiers industriels (pétrole, gaz, mines).', ARRAY[]::text[], ARRAY['Centres MINEFOP', 'Lycées techniques']::text[], ARRAY['soudeur / chaudronnier / métallier', 'soudure', 'métallerie', 'chaudronnerie', 'portail']::text[], '[{"titre":"Ministère de l''Emploi et de la Formation Professionnelle (MINEFOP) — centres agréés, examens, bourses","url":"https://www.minefop.gov.cm"},{"titre":"Office du Baccalauréat du Cameroun (OBC) — Probatoire, Baccalauréat, BT","url":"https://www.obc.cm"}]'::jsonb),
('metier-conducteur-engins', 'metier', 'Conducteur d''engins de chantier', 'BTP & construction', 'Tous niveaux + formation et permis adaptés', 'Conduit pelleteuses, niveleuses, bulldozers et grues sur les chantiers de routes, de bâtiments et de mines.', '## Le métier
- Terrassement et nivellement
- Chargement et transport de matériaux
- Entretien courant de l''engin

## Comment y arriver au Cameroun
- Centres de formation aux engins de chantier
- Expérience sur chantier

## Qualités utiles
- Précision
- Prudence
- Résistance

## La réalité du terrain
Les grands chantiers routiers recrutent des conducteurs qualifiés.

## Conseil Mandal
Choisis une formation reconnue, avec de la pratique réelle sur engins.', ARRAY[]::text[], ARRAY['Centres de formation professionnelle']::text[], ARRAY['conducteur d''engins de chantier', 'engins', 'bulldozer', 'pelleteuse', 'chantier', 'grue']::text[], '[{"titre":"Ministère de l''Emploi et de la Formation Professionnelle (MINEFOP) — centres agréés, examens, bourses","url":"https://www.minefop.gov.cm"},{"titre":"Ministère des Travaux Publics (MINTP)","url":"https://mintp.cm"}]'::jsonb),
('metier-chauffeur-poids-lourd', 'metier', 'Chauffeur professionnel (poids lourds, transport en commun)', 'Transport', 'Permis adapté + formation', 'Transporte des marchandises ou des voyageurs en toute sécurité, notamment sur les corridors vers le Tchad et la RCA.', '## Le métier
- Conduire en sécurité
- Vérifier le véhicule
- Gérer les documents de transport

## Comment y arriver au Cameroun
- Permis de conduire de la catégorie adaptée
- Formations à la conduite professionnelle et à la sécurité routière

## Qualités utiles
- Prudence
- Endurance
- Ponctualité

## La réalité du terrain
Le transport routier est vital pour l''économie ; la sécurité routière est un enjeu majeur.

## Conseil Mandal
Une conduite prudente et un véhicule bien entretenu sauvent des vies.', ARRAY[]::text[], ARRAY['Auto-écoles agréées', 'Centres de formation']::text[], ARRAY['chauffeur professionnel (poids lourds, transport en commun)', 'chauffeur', 'camion', 'transport', 'poids lourd', 'permis']::text[], '[{"titre":"Ministère de l''Emploi et de la Formation Professionnelle (MINEFOP) — centres agréés, examens, bourses","url":"https://www.minefop.gov.cm"}]'::jsonb),
('metier-marin', 'metier', 'Marin / Officier de la marine marchande / Agent portuaire', 'Transport', 'Baccalauréat (C, E, F) + formation maritime', 'Travaille sur les navires ou dans les ports de Douala et Kribi : navigation, manutention, logistique portuaire.', '## Le métier
- Navigation et sécurité à bord
- Manutention et gestion des conteneurs
- Opérations portuaires

## Comment y arriver au Cameroun
- Écoles et formations maritimes (souvent régionales)
- BTS/HND transport-logistique pour les métiers portuaires

## Qualités utiles
- Discipline
- Bonne santé
- Anglais technique

## La réalité du terrain
Le port en eau profonde de Kribi et le port de Douala créent des emplois portuaires et logistiques.

## Conseil Mandal
L''anglais est indispensable dans le monde maritime.', ARRAY[]::text[], ARRAY['Écoles maritimes', 'BTS/HND logistique']::text[], ARRAY['marin / officier de la marine marchande / agent portuaire', 'port', 'marine', 'maritime', 'kribi', 'douala', 'navire']::text[], '[{"titre":"Ministère de l''Enseignement Supérieur (MINESUP) — concours, BTS/HND, établissements","url":"https://www.minesup.gov.cm"}]'::jsonb),
('metier-cybersecurite', 'metier', 'Spécialiste en cybersécurité', 'Numérique', 'Bac C, TI ou E + Licence/Master informatique ou école d''ingénieurs', 'Protège les systèmes informatiques des banques, opérateurs et administrations contre les piratages et les fraudes.', '## Le métier
- Analyser les vulnérabilités
- Surveiller et répondre aux incidents
- Former les utilisateurs

## Comment y arriver au Cameroun
- Licence/Master en informatique, réseaux ou sécurité
- Certifications reconnues

## Qualités utiles
- Curiosité
- Éthique
- Rigueur

## La réalité du terrain
Les fraudes au mobile money et les attaques informatiques augmentent : les experts sont rares.

## Conseil Mandal
Pratique sur des plateformes d''entraînement légales et reste toujours éthique.', ARRAY[]::text[], ARRAY['ENSPY', 'Facultés des sciences', 'IUT']::text[], ARRAY['spécialiste en cybersécurité', 'cybersécurité', 'sécurité informatique', 'hacker éthique', 'piratage']::text[], '[{"titre":"Ministère des Postes et Télécommunications (MINPOSTEL)","url":"https://www.minpostel.gov.cm"},{"titre":"Ministère de l''Enseignement Supérieur (MINESUP) — concours, BTS/HND, établissements","url":"https://www.minesup.gov.cm"}]'::jsonb),
('metier-designer-ux', 'metier', 'Designer d''interfaces (UI/UX)', 'Numérique', 'Bac + formation en design, informatique ou communication', 'Conçoit des applications et des sites simples, beaux et faciles à utiliser.', '## Le métier
- Comprendre les utilisateurs
- Dessiner les écrans et parcours
- Tester et améliorer

## Comment y arriver au Cameroun
- Formations en design graphique, informatique ou multimédia
- Portfolio de projets

## Qualités utiles
- Créativité
- Empathie
- Sens du détail

## La réalité du terrain
Start-ups, banques et opérateurs créent des applications : les bons designers sont recherchés, y compris en freelance international.

## Conseil Mandal
Redessine des applications que tu utilises et publie tes travaux en ligne.', ARRAY[]::text[], ARRAY['Écoles de design', 'Formations multimédia']::text[], ARRAY['designer d''interfaces (ui/ux)', 'design', 'ux', 'ui', 'application', 'interface']::text[], '[{"titre":"Ministère des Postes et Télécommunications (MINPOSTEL)","url":"https://www.minpostel.gov.cm"}]'::jsonb),
('metier-technicien-maintenance-informatique', 'metier', 'Technicien de maintenance informatique', 'Numérique', 'Bac TI, F2 ou F3 + BTS/HND ou formation professionnelle', 'Installe, dépanne et entretient ordinateurs, imprimantes et petits réseaux dans les entreprises et administrations.', '## Le métier
- Installer le matériel et les logiciels
- Dépanner les utilisateurs
- Entretenir le parc informatique

## Comment y arriver au Cameroun
- BTS/HND maintenance informatique
- Centres de formation professionnelle

## Qualités utiles
- Patience
- Logique
- Sens du service

## La réalité du terrain
Toutes les organisations en ont besoin ; l''auto-emploi est aussi possible.

## Conseil Mandal
Ajoute les bases des réseaux et de la sécurité à tes compétences.', ARRAY[]::text[], ARRAY['BTS/HND', 'Centres MINEFOP']::text[], ARRAY['technicien de maintenance informatique', 'maintenance', 'informatique', 'dépannage', 'ordinateur']::text[], '[{"titre":"Ministère de l''Emploi et de la Formation Professionnelle (MINEFOP) — centres agréés, examens, bourses","url":"https://www.minefop.gov.cm"},{"titre":"Ministère de l''Enseignement Supérieur (MINESUP) — concours, BTS/HND, établissements","url":"https://www.minesup.gov.cm"}]'::jsonb),
('metier-pisciculteur', 'metier', 'Pisciculteur / Aquaculteur', 'Agriculture & environnement', 'Tous niveaux (formation conseillée)', 'Élève des poissons (tilapia, silure…) en étangs ou en bacs pour nourrir les villes.', '## Le métier
- Construire et gérer les étangs
- Nourrir et suivre les poissons
- Récolter et vendre

## Comment y arriver au Cameroun
- Formations proposées par le MINEPIA et les centres agréés
- Formations agricoles (BTS/HND, FASA)

## Qualités utiles
- Patience
- Observation
- Esprit d''entreprise

## La réalité du terrain
Le pays importe beaucoup de poisson ; l''État soutient le développement de la pisciculture.

## Conseil Mandal
Commence petit et maîtrise l''alimentation et la qualité de l''eau.', ARRAY[]::text[], ARRAY['Centres MINEPIA', 'FASA']::text[], ARRAY['pisciculteur / aquaculteur', 'pisciculture', 'poisson', 'tilapia', 'silure', 'étang', 'aquaculture']::text[], '[{"titre":"Ministère de l''Élevage, des Pêches et des Industries Animales (MINEPIA)","url":"https://minepia.cm"},{"titre":"Faculté d''Agronomie et des Sciences Agricoles (FASA), Université de Dschang","url":"https://www.univ-dschang.org/fasa/"}]'::jsonb),
('metier-apiculteur', 'metier', 'Apiculteur', 'Agriculture & environnement', 'Tous niveaux', 'Élève des abeilles pour produire miel, cire et autres produits, notamment dans l''Adamaoua et le Nord-Ouest.', '## Le métier
- Installer et suivre les ruches
- Récolter et conditionner le miel
- Vendre et transformer

## Comment y arriver au Cameroun
- Formations courtes en apiculture (ONG, centres agricoles)
- Apprentissage auprès d''apiculteurs

## Qualités utiles
- Calme
- Patience
- Respect de la nature

## La réalité du terrain
Le miel camerounais (dont celui d''Oku) a une réputation de qualité.

## Conseil Mandal
Soigne l''emballage et l''étiquetage pour mieux vendre.', ARRAY[]::text[], ARRAY['Centres agricoles']::text[], ARRAY['apiculteur', 'apiculture', 'miel', 'abeilles', 'ruche']::text[], '[{"titre":"Ministère de l''Élevage, des Pêches et des Industries Animales (MINEPIA)","url":"https://minepia.cm"},{"titre":"Ministère de l''Agriculture et du Développement Rural (MINADER) — écoles d''agriculture","url":"https://www.minader.cm"}]'::jsonb),
('metier-technicien-eaux-forets', 'metier', 'Technicien des eaux et forêts / Écogarde', 'Agriculture & environnement', 'Probatoire ou Baccalauréat + école forestière (concours)', 'Surveille et protège les forêts et la faune, lutte contre le braconnage et l''exploitation illégale.', '## Le métier
- Patrouilles et contrôles
- Inventaires forestiers et fauniques
- Sensibilisation des populations

## Comment y arriver au Cameroun
- ENEF de Mbalmayo ou École de Faune de Garoua (concours)
- FASA pour le niveau ingénieur

## Qualités utiles
- Goût du terrain
- Courage
- Intégrité

## La réalité du terrain
Le Cameroun abrite de vastes forêts et parcs nationaux : la protection de la nature emploie de nombreux agents.

## Conseil Mandal
Aime le terrain et sois prêt à vivre loin des villes.', ARRAY[]::text[], ARRAY['ENEF Mbalmayo', 'École de Faune de Garoua', 'FASA']::text[], ARRAY['technicien des eaux et forêts / écogarde', 'forêt', 'faune', 'écogarde', 'braconnage', 'parc national', 'enef']::text[], '[{"titre":"Ministère des Forêts et de la Faune (MINFOF) — ENEF Mbalmayo, École de Faune de Garoua","url":"https://www.minfof.gov.cm"},{"titre":"Faculté d''Agronomie et des Sciences Agricoles (FASA), Université de Dschang","url":"https://www.univ-dschang.org/fasa/"}]'::jsonb),
('metier-hydrologue', 'metier', 'Technicien / Ingénieur de l''eau et de l''assainissement', 'Agriculture & environnement', 'Bac C, D, E + Licence/Master ou école d''ingénieurs', 'Fournit l''eau potable et gère l''assainissement : forages, réseaux, stations de traitement.', '## Le métier
- Réaliser forages et adductions d''eau
- Contrôler la qualité de l''eau
- Concevoir l''assainissement

## Comment y arriver au Cameroun
- Géologie/hydrogéologie, génie civil, génie rural
- Écoles d''ingénieurs et masters spécialisés

## Qualités utiles
- Esprit pratique
- Rigueur
- Sens du service public

## La réalité du terrain
L''accès à l''eau potable reste un défi en ville comme au village : le secteur a de grands besoins.

## Conseil Mandal
Combine connaissances techniques et gestion de projets.', ARRAY[]::text[], ARRAY['ENSPY', 'ENSTP', 'Facultés des sciences']::text[], ARRAY['technicien / ingénieur de l''eau et de l''assainissement', 'eau', 'forage', 'assainissement', 'eau potable']::text[], '[{"titre":"Ministère de l''Enseignement Supérieur (MINESUP) — concours, BTS/HND, établissements","url":"https://www.minesup.gov.cm"},{"titre":"École Nationale Supérieure Polytechnique de Yaoundé (ENSPY) — concours","url":"https://polytechnique.cm"}]'::jsonb),
('metier-urbaniste', 'metier', 'Urbaniste', 'BTP & construction', 'Master en urbanisme, géographie ou architecture', 'Planifie l''organisation des villes : quartiers, routes, espaces verts, transports, assainissement.', '## Le métier
- Élaborer des plans d''urbanisme
- Conseiller les communes
- Restructurer les quartiers

## Comment y arriver au Cameroun
- Géographie, architecture ou génie civil puis master en urbanisme

## Qualités utiles
- Vision d''ensemble
- Dialogue
- Rigueur

## La réalité du terrain
Les villes camerounaises grandissent vite : les communes ont besoin d''urbanistes.

## Conseil Mandal
Apprends les SIG (systèmes d''information géographique).', ARRAY[]::text[], ARRAY['ENSTP', 'Facultés de lettres (géographie)']::text[], ARRAY['urbaniste', 'urbanisme', 'ville', 'aménagement', 'commune']::text[], '[{"titre":"ENSTP — École Nationale Supérieure des Travaux Publics, Yaoundé"},{"titre":"Ministère de l''Enseignement Supérieur (MINESUP) — concours, BTS/HND, établissements","url":"https://www.minesup.gov.cm"}]'::jsonb),
('metier-photographe-videaste', 'metier', 'Photographe / Vidéaste / Monteur', 'Communication & arts', 'Tous niveaux (formation conseillée)', 'Réalise photos et vidéos pour les cérémonies, les entreprises, les médias et les réseaux sociaux.', '## Le métier
- Prise de vue
- Montage et retouche
- Relation client

## Comment y arriver au Cameroun
- Formations audiovisuelles (ESSTIC, écoles privées)
- Autoformation et pratique

## Qualités utiles
- Créativité
- Sens technique
- Ponctualité

## La réalité du terrain
Mariages, événements et contenu numérique assurent une demande forte.

## Conseil Mandal
Construis un portfolio en ligne et soigne la qualité du son.', ARRAY[]::text[], ARRAY['ESSTIC', 'Écoles audiovisuelles']::text[], ARRAY['photographe / vidéaste / monteur', 'photo', 'vidéo', 'montage', 'audiovisuel', 'cinéma']::text[], '[{"titre":"ESSTIC — École Supérieure des Sciences et Techniques de l''Information et de la Communication (Université de Yaoundé II)"},{"titre":"Ministère de l''Emploi et de la Formation Professionnelle (MINEFOP) — centres agréés, examens, bourses","url":"https://www.minefop.gov.cm"}]'::jsonb),
('metier-animateur-radio', 'metier', 'Animateur radio / Présentateur', 'Communication & arts', 'Bac + formation en journalisme ou communication', 'Anime des émissions, informe et divertit les auditeurs à la radio, à la télévision ou en ligne.', '## Le métier
- Préparer et animer des émissions
- Interviewer des invités
- Interagir avec le public

## Comment y arriver au Cameroun
- ESSTIC ou formations en communication
- Radios communautaires et universitaires pour débuter

## Qualités utiles
- Belle voix et aisance
- Culture générale
- Réactivité

## La réalité du terrain
Les radios communautaires sont nombreuses et permettent de débuter.

## Conseil Mandal
Commence par la radio de ton école ou de ton quartier.', ARRAY[]::text[], ARRAY['ESSTIC']::text[], ARRAY['animateur radio / présentateur', 'radio', 'animateur', 'présentateur', 'télévision']::text[], '[{"titre":"ESSTIC — École Supérieure des Sciences et Techniques de l''Information et de la Communication (Université de Yaoundé II)"},{"titre":"Université de Yaoundé II-Soa (Droit, Économie, ESSTIC, IRIC)","url":"https://site.univ-yaounde2.org"}]'::jsonb),
('metier-bibliothecaire-archiviste', 'metier', 'Bibliothécaire / Archiviste / Documentaliste', 'Communication & arts', 'Bac + ESSTIC (archivistique, bibliothéconomie) ou licence', 'Organise, conserve et met à disposition les livres, archives et documents des institutions.', '## Le métier
- Classer et numériser les documents
- Accueillir et orienter les lecteurs
- Conserver les archives

## Comment y arriver au Cameroun
- ESSTIC (archivistique, bibliothéconomie, édition)
- Licences en sciences de l''information

## Qualités utiles
- Organisation
- Méthode
- Goût de la lecture

## La réalité du terrain
Administrations, universités et entreprises numérisent leurs archives : compétence recherchée.

## Conseil Mandal
La numérisation et la gestion électronique des documents sont des atouts.', ARRAY[]::text[], ARRAY['ESSTIC']::text[], ARRAY['bibliothécaire / archiviste / documentaliste', 'bibliothèque', 'archives', 'documentation', 'numérisation']::text[], '[{"titre":"ESSTIC — École Supérieure des Sciences et Techniques de l''Information et de la Communication (Université de Yaoundé II)"},{"titre":"Université de Yaoundé II-Soa (Droit, Économie, ESSTIC, IRIC)","url":"https://site.univ-yaounde2.org"}]'::jsonb),
('metier-ecrivain-editeur', 'metier', 'Écrivain / Éditeur / Correcteur', 'Communication & arts', 'Bac + études de lettres (conseillées)', 'Écrit, corrige et publie des livres, manuels scolaires et contenus.', '## Le métier
- Écrire ou sélectionner des textes
- Corriger et mettre en page
- Diffuser et promouvoir

## Comment y arriver au Cameroun
- Licences de lettres, ESSTIC (édition)
- Pratique de l''écriture

## Qualités utiles
- Maîtrise de la langue
- Créativité
- Persévérance

## La réalité du terrain
Le manuel scolaire et le livre numérique sont des marchés importants.

## Conseil Mandal
Écris régulièrement et participe aux concours littéraires.', ARRAY[]::text[], ARRAY['Facultés de lettres', 'ESSTIC']::text[], ARRAY['écrivain / éditeur / correcteur', 'écrivain', 'édition', 'livre', 'correcteur', 'littérature']::text[], '[{"titre":"ESSTIC — École Supérieure des Sciences et Techniques de l''Information et de la Communication (Université de Yaoundé II)"},{"titre":"Ministère de l''Enseignement Supérieur (MINESUP) — concours, BTS/HND, établissements","url":"https://www.minesup.gov.cm"}]'::jsonb),
('metier-boulanger-patissier', 'metier', 'Boulanger / Pâtissier', 'Artisanat & services', 'Tous niveaux (formation professionnelle)', 'Fabrique le pain, les viennoiseries et les gâteaux, souvent à son compte.', '## Le métier
- Préparer les pâtes et cuire
- Respecter l''hygiène
- Gérer la boutique

## Comment y arriver au Cameroun
- Centres de formation professionnelle agréés
- Apprentissage en boulangerie

## Qualités utiles
- Rigueur
- Endurance (horaires matinaux)
- Créativité

## La réalité du terrain
Les gâteaux de cérémonie et la pâtisserie sont un bon marché pour l''auto-emploi.

## Conseil Mandal
Teste des farines locales (manioc, maïs) pour te démarquer.', ARRAY[]::text[], ARRAY['Centres MINEFOP']::text[], ARRAY['boulanger / pâtissier', 'boulangerie', 'pâtisserie', 'pain', 'gâteau']::text[], '[{"titre":"Ministère de l''Emploi et de la Formation Professionnelle (MINEFOP) — centres agréés, examens, bourses","url":"https://www.minefop.gov.cm"}]'::jsonb),
('metier-transformateur-agro', 'metier', 'Transformateur agroalimentaire (artisanal)', 'Artisanat & services', 'Tous niveaux (formation conseillée)', 'Transforme les produits locaux : jus, farines, huiles, épices, chips de plantain, miondo…', '## Le métier
- Transformer et conditionner
- Respecter l''hygiène et la qualité
- Vendre aux boutiques et marchés

## Comment y arriver au Cameroun
- Formations courtes en transformation
- BTS/HND ou ENSAI pour aller plus loin

## Qualités utiles
- Hygiène
- Créativité
- Sens commercial

## La réalité du terrain
Transformer réduit les pertes après récolte et crée de la valeur localement.

## Conseil Mandal
Un bon emballage et un étiquetage clair font vendre ; renseigne-toi sur les normes.', ARRAY[]::text[], ARRAY['Centres de formation', 'ENSAI']::text[], ARRAY['transformateur agroalimentaire (artisanal)', 'transformation', 'jus', 'farine', 'plantain', 'agroalimentaire']::text[], '[{"titre":"Ministère de l''Agriculture et du Développement Rural (MINADER) — écoles d''agriculture","url":"https://www.minader.cm"},{"titre":"École Nationale Supérieure des Sciences Agro-Industrielles (ENSAI), Ngaoundéré","url":"https://ensai.univ-ndere.cm"},{"titre":"Fonds National de l''Emploi (FNE) — emploi, stages, auto-emploi (services gratuits)","url":"https://fnecm.org"}]'::jsonb),
('metier-mecanicien-moto', 'metier', 'Mécanicien moto', 'Artisanat & services', 'Tous niveaux (apprentissage ou formation professionnelle)', 'Entretient et répare les motos, très nombreuses dans les villes et les campagnes.', '## Le métier
- Diagnostic et réparation
- Entretien régulier
- Vente de pièces

## Comment y arriver au Cameroun
- Centres de formation professionnelle
- Apprentissage dans un atelier

## Qualités utiles
- Habileté
- Honnêteté
- Rapidité

## La réalité du terrain
Le transport par moto est omniprésent : les mécaniciens ont du travail toute l''année.

## Conseil Mandal
Apprends aussi les motos et tricycles électriques qui arrivent.', ARRAY[]::text[], ARRAY['Centres MINEFOP']::text[], ARRAY['mécanicien moto', 'moto', 'mécanique', 'bendskin', 'réparation']::text[], '[{"titre":"Ministère de l''Emploi et de la Formation Professionnelle (MINEFOP) — centres agréés, examens, bourses","url":"https://www.minefop.gov.cm"}]'::jsonb),
('metier-moniteur-auto-ecole', 'metier', 'Moniteur d''auto-école', 'Artisanat & services', 'Permis et expérience + qualification réglementée', 'Apprend à conduire en sécurité et prépare au permis de conduire.', '## Le métier
- Enseigner le code de la route
- Leçons de conduite
- Préparer à l''examen

## Comment y arriver au Cameroun
- Permis de conduire et expérience
- Qualification de moniteur selon la réglementation des transports

## Qualités utiles
- Patience
- Calme
- Pédagogie

## La réalité du terrain
La sécurité routière est un enjeu national : un bon moniteur sauve des vies.

## Conseil Mandal
Insiste sur la prudence et le respect du code avec chaque élève.', ARRAY[]::text[], ARRAY['Auto-écoles']::text[], ARRAY['moniteur d''auto-école', 'auto-école', 'permis', 'conduite', 'code de la route']::text[], '[{"titre":"Ministère de l''Emploi et de la Formation Professionnelle (MINEFOP) — centres agréés, examens, bourses","url":"https://www.minefop.gov.cm"}]'::jsonb),
('metier-educateur-sportif', 'metier', 'Éducateur sportif / Professeur d''EPS / Entraîneur', 'Enseignement', 'Bac + formation en sciences et techniques des activités physiques', 'Enseigne le sport à l''école, entraîne des équipes ou accompagne la remise en forme.', '## Le métier
- Planifier les séances
- Encadrer et motiver
- Veiller à la sécurité

## Comment y arriver au Cameroun
- Formations publiques des professeurs d''EPS (concours)
- Diplômes d''entraîneur des fédérations

## Qualités utiles
- Excellente condition physique
- Pédagogie
- Leadership

## La réalité du terrain
Le football et les autres sports sont très populaires ; les écoles et clubs recrutent.

## Conseil Mandal
Pratique plusieurs sports et passe les premiers diplômes d''entraîneur.', ARRAY[]::text[], ARRAY['Écoles de formation des professeurs d''EPS', 'Fédérations sportives']::text[], ARRAY['éducateur sportif / professeur d''eps / entraîneur', 'sport', 'eps', 'entraîneur', 'football', 'coach']::text[], '[{"titre":"Ministère de l''Enseignement Supérieur (MINESUP) — concours, BTS/HND, établissements","url":"https://www.minesup.gov.cm"},{"titre":"Ministère des Enseignements Secondaires (MINESEC)","url":"https://www.minesec.gov.cm"}]'::jsonb),
('metier-animateur-jeunesse', 'metier', 'Animateur socio-éducatif / Conseiller de jeunesse', 'Social & humain', 'Baccalauréat + formation (concours publics ou associatifs)', 'Organise des activités éducatives, civiques et culturelles pour les jeunes.', '## Le métier
- Animer des activités et des camps
- Accompagner les projets de jeunes
- Promouvoir le civisme

## Comment y arriver au Cameroun
- Concours de formation des cadres de la jeunesse
- Formations associatives

## Qualités utiles
- Dynamisme
- Écoute
- Sens de l''organisation

## La réalité du terrain
Le ministère de la Jeunesse et les associations encadrent de nombreux programmes pour les jeunes.

## Conseil Mandal
Engage-toi dans un club ou une association : c''est la meilleure école.', ARRAY[]::text[], ARRAY['Écoles de cadres de jeunesse', 'Associations']::text[], ARRAY['animateur socio-éducatif / conseiller de jeunesse', 'jeunesse', 'animation', 'civisme', 'volontariat']::text[], '[{"titre":"Ministère de la Jeunesse et de l''Éducation Civique (MINJEC) — insertion des jeunes","url":"https://www.minjec.gov.cm"}]'::jsonb),
('metier-inspecteur-travail', 'metier', 'Inspecteur du travail', 'Droit & administration', 'Licence + concours ENAM (travail)', 'Veille au respect du Code du travail : contrats, salaires, sécurité, règlement des conflits.', '## Le métier
- Contrôler les entreprises
- Concilier employeurs et salariés
- Informer sur les droits

## Comment y arriver au Cameroun
- Licence (droit, économie, sciences sociales)
- Concours de l''ENAM dans la division concernée

## Qualités utiles
- Impartialité
- Fermeté
- Connaissance du droit social

## La réalité du terrain
Fonctionnaire au service de l''équilibre entre employeurs et travailleurs.

## Conseil Mandal
Étudie le Code du travail camerounais.', ARRAY[]::text[], ARRAY['ENAM']::text[], ARRAY['inspecteur du travail', 'inspection du travail', 'code du travail', 'salariés', 'enam']::text[], '[{"titre":"École Nationale d''Administration et de Magistrature (ENAM)","url":"https://www.enam.cm"},{"titre":"Plateforme des concours de l''ENAM","url":"https://concours.enam.cm"}]'::jsonb),
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
- Good O Level grades in English and Mathematics are also required by many schools.', ARRAY[]::text[], ARRAY[]::text[], ARRAY['a level', 'subjects', 'medicine', 'engineering', 'biology', 'physics']::text[], '[{"titre":"Cameroon GCE Board — GCE O Level / A Level","url":"https://www.camgceb.org"},{"titre":"Ministère de l''Enseignement Supérieur (MINESUP) — concours, BTS/HND, établissements","url":"https://www.minesup.gov.cm"},{"titre":"University of Buea (Faculty of Health Sciences, ASTI, COT, faculties)","url":"https://www.ubuea.cm"}]'::jsonb),
('faq-resultats-bac', 'faq', 'Où consulter les résultats du Probatoire et du Baccalauréat ?', 'Examens officiels', NULL, 'Les résultats sont publiés par l''**Office du Baccalauréat du Cameroun (OBC)**, sur son site officiel et par affichage dans les centres.', 'Les résultats sont publiés par l''**Office du Baccalauréat du Cameroun (OBC)**, sur son site officiel et par affichage dans les centres.

- Méfie-toi des pages et groupes qui publient de faux résultats ou demandent de l''argent.
- Pour le GCE, consulte le **GCE Board**.', ARRAY[]::text[], ARRAY[]::text[], ARRAY['résultats', 'bac', 'probatoire', 'obc', 'publication']::text[], '[{"titre":"Office du Baccalauréat du Cameroun (OBC) — Probatoire, Baccalauréat, BT","url":"https://www.obc.cm"},{"titre":"Cameroon GCE Board — GCE O Level / A Level","url":"https://www.camgceb.org"}]'::jsonb),
('faq-resultats-bepc', 'faq', 'Où trouver les résultats du BEPC et du CAP ?', 'Examens officiels', NULL, 'Le BEPC et le CAP relèvent du **MINESEC** : les résultats sont publiés par ses services (délégations régionales, affichage dans les centres, canaux officiels).', 'Le BEPC et le CAP relèvent du **MINESEC** : les résultats sont publiés par ses services (délégations régionales, affichage dans les centres, canaux officiels).

- Ne paie jamais pour « voir » des résultats.', ARRAY[]::text[], ARRAY[]::text[], ARRAY['résultats bepc', 'cap', 'minesec']::text[], '[{"titre":"Ministère des Enseignements Secondaires (MINESEC)","url":"https://www.minesec.gov.cm"}]'::jsonb),
('faq-echec-bac', 'faq', 'J''ai échoué au Baccalauréat : que faire ?', 'Examens officiels', NULL, 'Ce n''est pas la fin : tu peux redoubler pour repasser l''examen, te présenter en candidat libre, ou t''orienter vers la formation professionnelle.', 'Ce n''est pas la fin : tu peux redoubler pour repasser l''examen, te présenter en candidat libre, ou t''orienter vers la formation professionnelle.

- Analyse tes notes : quelles matières t''ont fait perdre des points ?
- Utilise les annales et les épreuves blanches de Mandal pour t''entraîner.
- Si tu veux un métier rapidement, regarde les centres de formation professionnelle agréés (MINEFOP).', ARRAY[]::text[], ARRAY[]::text[], ARRAY['échec', 'redoubler', 'candidat libre', 'bac raté']::text[], '[{"titre":"Office du Baccalauréat du Cameroun (OBC) — Probatoire, Baccalauréat, BT","url":"https://www.obc.cm"},{"titre":"Ministère de l''Emploi et de la Formation Professionnelle (MINEFOP) — centres agréés, examens, bourses","url":"https://www.minefop.gov.cm"}]'::jsonb),
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
- Les dates, les frais et le nombre de places changent chaque année : seul le **communiqué officiel** fait foi.', ARRAY[]::text[], ARRAY[]::text[], ARRAY['concours', 'après le bac', 'grandes écoles', 'ensp', 'ens', 'iut']::text[], '[{"titre":"Ministère de l''Enseignement Supérieur (MINESUP) — concours, BTS/HND, établissements","url":"https://www.minesup.gov.cm"},{"titre":"Université de Yaoundé I (ENSP, ENS, FMSB, Faculté des Sciences)","url":"http://www.uy1.uninet.cm"},{"titre":"Université de Douala (ENSPD, ENSET, IUT, FMSP, ESSEC)","url":"https://www.univ-douala.cm"}]'::jsonb),
('faq-concours-apres-licence', 'faq', 'Quels concours peut-on passer après une Licence ?', 'Concours', NULL, 'Après une licence : ENAM (administration, magistrature, régies financières), IRIC, ASTI, ENS 2nd cycle, ESSTIC (certains cycles), concours de la fonction publique et masters sélectifs.', 'Après une licence : ENAM (administration, magistrature, régies financières), IRIC, ASTI, ENS 2nd cycle, ESSTIC (certains cycles), concours de la fonction publique et masters sélectifs.

- Vérifie les spécialités de licence admises pour chaque concours.
- Les dates, les frais et le nombre de places changent chaque année : seul le **communiqué officiel** fait foi.', ARRAY[]::text[], ARRAY[]::text[], ARRAY['concours', 'après licence', 'enam', 'iric', 'asti', 'fonction publique']::text[], '[{"titre":"École Nationale d''Administration et de Magistrature (ENAM)","url":"https://www.enam.cm"},{"titre":"Plateforme des concours de l''ENAM","url":"https://concours.enam.cm"},{"titre":"Ministère de l''Enseignement Supérieur (MINESUP) — concours, BTS/HND, établissements","url":"https://www.minesup.gov.cm"}]'::jsonb),
('faq-communique-concours', 'faq', 'Où trouver les communiqués officiels des concours ?', 'Concours', NULL, 'Les concours de l''enseignement supérieur sont annoncés par le **MINESUP** et par les établissements eux-mêmes ; l''ENAM publie les siens sur sa plateforme de concours.', 'Les concours de l''enseignement supérieur sont annoncés par le **MINESUP** et par les établissements eux-mêmes ; l''ENAM publie les siens sur sa plateforme de concours.

- Les autres ministères (Défense, Santé, Sûreté nationale…) publient les leurs.
- Garde une copie du communiqué : il précise les pièces, les dates et les centres.', ARRAY[]::text[], ARRAY[]::text[], ARRAY['communiqué', 'concours', 'date', 'inscription', 'arrêté']::text[], '[{"titre":"Ministère de l''Enseignement Supérieur (MINESUP) — concours, BTS/HND, établissements","url":"https://www.minesup.gov.cm"},{"titre":"Plateforme des concours de l''ENAM","url":"https://concours.enam.cm"},{"titre":"Ministère de la Défense (MINDEF) — EMIA et recrutements des forces de défense","url":"https://mindef.gov.cm"},{"titre":"Délégation Générale à la Sûreté Nationale (DGSN) — concours de la police","url":"https://www.dgsn.cm"},{"titre":"Ministère de la Santé Publique (MINSANTE) — écoles de formation paramédicale","url":"https://www.minsante.cm"}]'::jsonb),
('faq-arnaque-concours', 'faq', 'On me propose de payer pour réussir un concours : est-ce sérieux ?', 'Concours', NULL, '**Non.** Aucune place dans un concours officiel ne s''achète : c''est une arnaque et une infraction. Les seuls frais sont ceux indiqués dans le communiqué officiel.', '**Non.** Aucune place dans un concours officiel ne s''achète : c''est une arnaque et une infraction. Les seuls frais sont ceux indiqués dans le communiqué officiel.

- Ne transmets jamais d''argent à un « intermédiaire ».
- Signale ces propositions aux autorités compétentes.
- Investis plutôt ton énergie dans la préparation : annales, épreuves blanches, travail régulier.', ARRAY[]::text[], ARRAY[]::text[], ARRAY['arnaque', 'corruption', 'payer concours', 'réseau', 'fraude']::text[], '[{"titre":"Ministère de l''Enseignement Supérieur (MINESUP) — concours, BTS/HND, établissements","url":"https://www.minesup.gov.cm"},{"titre":"Ministère de la Défense (MINDEF) — EMIA et recrutements des forces de défense","url":"https://mindef.gov.cm"},{"titre":"Délégation Générale à la Sûreté Nationale (DGSN) — concours de la police","url":"https://www.dgsn.cm"}]'::jsonb),
('faq-preparer-concours', 'faq', 'Comment préparer un concours d''entrée en grande école ?', 'Concours', NULL, 'Procure-toi les **annales**, identifie les matières et coefficients du concours, et entraîne-toi en temps réel plusieurs semaines avant.', 'Procure-toi les **annales**, identifie les matières et coefficients du concours, et entraîne-toi en temps réel plusieurs semaines avant.

- Révise le programme de Terminale en profondeur.
- Pour les concours scientifiques, la vitesse en calcul est décisive.
- Travaille aussi la culture générale si elle est au programme.
- Les épreuves blanches de Mandal t''aident à t''entraîner.', ARRAY[]::text[], ARRAY[]::text[], ARRAY['préparer concours', 'annales', 'méthode', 'grande école']::text[], '[{"titre":"Ministère de l''Enseignement Supérieur (MINESUP) — concours, BTS/HND, établissements","url":"https://www.minesup.gov.cm"}]'::jsonb),
('faq-enspd-ensp', 'faq', 'Quelle différence entre l''ENSP Yaoundé et l''ENSPD Douala ?', 'Concours', NULL, 'Ce sont deux **écoles publiques d''ingénieurs** : l''ENSP dépend de l''Université de Yaoundé I, l''ENSPD de l''Université de Douala. Elles recrutent sur concours et proposent plusieurs spécialités.', 'Ce sont deux **écoles publiques d''ingénieurs** : l''ENSP dépend de l''Université de Yaoundé I, l''ENSPD de l''Université de Douala. Elles recrutent sur concours et proposent plusieurs spécialités.

- Compare les spécialités offertes (génie civil, électrique, informatique, télécoms, industriel…).
- Il existe aussi des écoles d''ingénieurs à Maroua, Ngaoundéré, Bamenda et ailleurs.', ARRAY[]::text[], ARRAY[]::text[], ARRAY['ensp', 'enspd', 'polytechnique', 'ingénieur', 'école d''ingénieurs']::text[], '[{"titre":"Université de Yaoundé I (ENSP, ENS, FMSB, Faculté des Sciences)","url":"http://www.uy1.uninet.cm"},{"titre":"Université de Douala (ENSPD, ENSET, IUT, FMSP, ESSEC)","url":"https://www.univ-douala.cm"},{"titre":"Ministère de l''Enseignement Supérieur (MINESUP) — concours, BTS/HND, établissements","url":"https://www.minesup.gov.cm"}]'::jsonb),
('faq-concours-medecine', 'faq', 'Comment réussir le concours de médecine ?', 'Concours', NULL, 'Le concours de médecine est très sélectif : un excellent niveau en **SVT, chimie, physique** et souvent en culture générale ou en français est indispensable.', 'Le concours de médecine est très sélectif : un excellent niveau en **SVT, chimie, physique** et souvent en culture générale ou en français est indispensable.

- Entraîne-toi avec les annales dès la Terminale.
- Inscris-toi à plusieurs concours (facultés publiques, paramédical) pour multiplier tes chances.
- Les dates, les frais et le nombre de places changent chaque année : seul le **communiqué officiel** fait foi.', ARRAY[]::text[], ARRAY[]::text[], ARRAY['médecine', 'concours médecine', 'fmsb', 'fmsp', 'santé']::text[], '[{"titre":"Ministère de l''Enseignement Supérieur (MINESUP) — concours, BTS/HND, établissements","url":"https://www.minesup.gov.cm"},{"titre":"Université de Yaoundé I (ENSP, ENS, FMSB, Faculté des Sciences)","url":"http://www.uy1.uninet.cm"},{"titre":"Ministère de la Santé Publique (MINSANTE) — écoles de formation paramédicale","url":"https://www.minsante.cm"}]'::jsonb),
('faq-concours-ens', 'faq', 'Comment devenir enseignant par le concours de l''ENS ?', 'Concours', NULL, 'L''ENS recrute au **1er cycle** (après le Bac) et au **2nd cycle** (après la Licence) ; l''ENSET forme les enseignants du technique.', 'L''ENS recrute au **1er cycle** (après le Bac) et au **2nd cycle** (après la Licence) ; l''ENSET forme les enseignants du technique.

- Choisis la section correspondant à la matière que tu veux enseigner.
- Les dates, les frais et le nombre de places changent chaque année : seul le **communiqué officiel** fait foi.', ARRAY[]::text[], ARRAY[]::text[], ARRAY['ens', 'enset', 'enseignant', 'professeur', 'concours']::text[], '[{"titre":"Ministère de l''Enseignement Supérieur (MINESUP) — concours, BTS/HND, établissements","url":"https://www.minesup.gov.cm"},{"titre":"Université de Yaoundé I (ENSP, ENS, FMSB, Faculté des Sciences)","url":"http://www.uy1.uninet.cm"},{"titre":"Ministère des Enseignements Secondaires (MINESEC)","url":"https://www.minesec.gov.cm"}]'::jsonb),
('faq-concours-enam', 'faq', 'Comment s''inscrire au concours de l''ENAM ?', 'Concours', NULL, 'L''inscription au concours de l''ENAM se fait en ligne sur la **plateforme des concours de l''ENAM**, selon les conditions de chaque division (administration, magistrature, régies financières…).', 'L''inscription au concours de l''ENAM se fait en ligne sur la **plateforme des concours de l''ENAM**, selon les conditions de chaque division (administration, magistrature, régies financières…).

- Vérifie le diplôme exigé (Bac, Licence, Master selon le cycle) et la limite d''âge.
- Les dates, les frais et le nombre de places changent chaque année : seul le **communiqué officiel** fait foi.', ARRAY[]::text[], ARRAY[]::text[], ARRAY['enam', 'inscription', 'administration', 'magistrature', 'régies financières']::text[], '[{"titre":"École Nationale d''Administration et de Magistrature (ENAM)","url":"https://www.enam.cm"},{"titre":"Plateforme des concours de l''ENAM","url":"https://concours.enam.cm"}]'::jsonb),
('faq-concours-armee', 'faq', 'Comment entrer dans l''armée (EMIA, sous-officiers, soldats) ?', 'Concours', NULL, 'Les recrutements des forces de défense sont annoncés par le **MINDEF** : EMIA pour les officiers, et campagnes de recrutement pour les sous-officiers et militaires du rang.', 'Les recrutements des forces de défense sont annoncés par le **MINDEF** : EMIA pour les officiers, et campagnes de recrutement pour les sous-officiers et militaires du rang.

- Une bonne condition physique et un dossier médical sont exigés.
- Seuls les communiqués du MINDEF font foi : méfie-toi des faux recruteurs.', ARRAY[]::text[], ARRAY[]::text[], ARRAY['armée', 'emia', 'militaire', 'recrutement', 'soldat', 'défense']::text[], '[{"titre":"Ministère de la Défense (MINDEF) — EMIA et recrutements des forces de défense","url":"https://mindef.gov.cm"}]'::jsonb),
('faq-concours-police', 'faq', 'Comment devenir policier au Cameroun ?', 'Concours', NULL, 'La **DGSN** organise des concours selon le diplôme : gardiens de la paix, inspecteurs, officiers de police, commissaires.', 'La **DGSN** organise des concours selon le diplôme : gardiens de la paix, inspecteurs, officiers de police, commissaires.

- Prépare l''écrit et l''épreuve sportive.
- Les dates, les frais et le nombre de places changent chaque année : seul le **communiqué officiel** fait foi.', ARRAY[]::text[], ARRAY[]::text[], ARRAY['police', 'dgsn', 'policier', 'concours police']::text[], '[{"titre":"Délégation Générale à la Sûreté Nationale (DGSN) — concours de la police","url":"https://www.dgsn.cm"}]'::jsonb),
('faq-concours-paramedical', 'faq', 'Comment devenir infirmier ou technicien de santé ?', 'Concours', NULL, 'Par les **concours des écoles publiques de formation paramédicale** (MINSANTE, universités) ou par un BTS/HND santé dans un institut privé agréé.', 'Par les **concours des écoles publiques de formation paramédicale** (MINSANTE, universités) ou par un BTS/HND santé dans un institut privé agréé.

- Vérifie l''agrément de l''école avant tout paiement.
- Les séries D, C et F7 sont les plus adaptées.', ARRAY[]::text[], ARRAY[]::text[], ARRAY['infirmier', 'paramédical', 'santé', 'école de santé']::text[], '[{"titre":"Ministère de la Santé Publique (MINSANTE) — écoles de formation paramédicale","url":"https://www.minsante.cm"},{"titre":"Ministère de l''Enseignement Supérieur (MINESUP) — concours, BTS/HND, établissements","url":"https://www.minesup.gov.cm"}]'::jsonb),
('faq-concours-iut', 'faq', 'Comment entrer dans un IUT ?', 'Concours', NULL, 'Les **IUT** (Douala, Bandjoun/Dschang, Ngaoundéré…) recrutent sur concours ou étude de dossier après le Bac, pour des formations courtes et professionnelles (DUT, licences professionnelles).', 'Les **IUT** (Douala, Bandjoun/Dschang, Ngaoundéré…) recrutent sur concours ou étude de dossier après le Bac, pour des formations courtes et professionnelles (DUT, licences professionnelles).

- Les spécialités : génie civil, électrique, mécanique, informatique, gestion, génie biologique…
- Les dates, les frais et le nombre de places changent chaque année : seul le **communiqué officiel** fait foi.', ARRAY[]::text[], ARRAY[]::text[], ARRAY['iut', 'dut', 'technologie', 'concours iut']::text[], '[{"titre":"Université de Douala (ENSPD, ENSET, IUT, FMSP, ESSEC)","url":"https://www.univ-douala.cm"},{"titre":"Université de Dschang (FASA, IUT Fotso Victor de Bandjoun)","url":"https://www.univ-dschang.org"},{"titre":"Université de Ngaoundéré (ENSAI, ESMV, IUT, facultés)","url":"https://www.univ-ndere.cm"},{"titre":"Ministère de l''Enseignement Supérieur (MINESUP) — concours, BTS/HND, établissements","url":"https://www.minesup.gov.cm"}]'::jsonb),
('faq-bts-hnd', 'faq', 'Qu''est-ce que le BTS et le HND ?', 'BTS, HND et formation professionnelle', NULL, 'Le **BTS** (francophone) et le **HND** (anglophone) sont des diplômes de l''enseignement supérieur en 2 ans, préparés dans des instituts agréés et sanctionnés par un **examen national du MINESUP**.', 'Le **BTS** (francophone) et le **HND** (anglophone) sont des diplômes de l''enseignement supérieur en 2 ans, préparés dans des instituts agréés et sanctionnés par un **examen national du MINESUP**.

- Ils mènent directement à l''emploi ou à une licence professionnelle.
- Vérifie que l''institut et la spécialité sont agréés.', ARRAY[]::text[], ARRAY[]::text[], ARRAY['bts', 'hnd', 'brevet de technicien supérieur', 'higher national diploma']::text[], '[{"titre":"Ministère de l''Enseignement Supérieur (MINESUP) — concours, BTS/HND, établissements","url":"https://www.minesup.gov.cm"}]'::jsonb),
('faq-formation-professionnelle', 'faq', 'Je veux apprendre un métier rapidement : quelles options ?', 'BTS, HND et formation professionnelle', NULL, 'La **formation professionnelle** (centres publics et privés agréés par le MINEFOP) forme en quelques mois à quelques années à des métiers pratiques.', 'La **formation professionnelle** (centres publics et privés agréés par le MINEFOP) forme en quelques mois à quelques années à des métiers pratiques.

- Exemples : électricité, solaire, couture, coiffure, mécanique, informatique, hôtellerie, agriculture, BTP.
- Le FNE accompagne vers l''emploi et l''auto-emploi.', ARRAY[]::text[], ARRAY[]::text[], ARRAY['formation professionnelle', 'métier', 'centre de formation', 'apprentissage']::text[], '[{"titre":"Ministère de l''Emploi et de la Formation Professionnelle (MINEFOP) — centres agréés, examens, bourses","url":"https://www.minefop.gov.cm"},{"titre":"Fonds National de l''Emploi (FNE) — emploi, stages, auto-emploi (services gratuits)","url":"https://fnecm.org"}]'::jsonb),
('faq-sans-bac', 'faq', 'Peut-on réussir sans le Baccalauréat ?', 'BTS, HND et formation professionnelle', NULL, 'Oui. Beaucoup de métiers s''apprennent par la **formation professionnelle** et l''**apprentissage** : artisanat, BTP, mécanique, couture, agriculture, services.', 'Oui. Beaucoup de métiers s''apprennent par la **formation professionnelle** et l''**apprentissage** : artisanat, BTP, mécanique, couture, agriculture, services.

- Le CAP ou un certificat professionnel donne une vraie qualification.
- Tu pourras toujours reprendre tes études plus tard (candidat libre).
- L''auto-emploi demande aussi des compétences en gestion.', ARRAY[]::text[], ARRAY[]::text[], ARRAY['sans bac', 'pas de bac', 'réussir', 'métier', 'apprentissage']::text[], '[{"titre":"Ministère de l''Emploi et de la Formation Professionnelle (MINEFOP) — centres agréés, examens, bourses","url":"https://www.minefop.gov.cm"},{"titre":"Fonds National de l''Emploi (FNE) — emploi, stages, auto-emploi (services gratuits)","url":"https://fnecm.org"}]'::jsonb),
('faq-fne', 'faq', 'Que fait le Fonds National de l''Emploi (FNE) ?', 'BTS, HND et formation professionnelle', NULL, 'Le **FNE** aide les demandeurs d''emploi : inscription, orientation, mise en relation avec les employeurs, formations et appui aux projets d''auto-emploi.', 'Le **FNE** aide les demandeurs d''emploi : inscription, orientation, mise en relation avec les employeurs, formations et appui aux projets d''auto-emploi.

- Rends-toi dans une agence du FNE avec ton CV et tes diplômes.', ARRAY[]::text[], ARRAY[]::text[], ARRAY['fne', 'emploi', 'chômage', 'auto-emploi', 'insertion']::text[], '[{"titre":"Fonds National de l''Emploi (FNE) — emploi, stages, auto-emploi (services gratuits)","url":"https://fnecm.org"},{"titre":"Ministère de l''Emploi et de la Formation Professionnelle (MINEFOP) — centres agréés, examens, bourses","url":"https://www.minefop.gov.cm"}]'::jsonb),
('faq-metiers-porteurs', 'faq', 'Quels sont les métiers porteurs au Cameroun ?', 'Métiers & emploi', NULL, 'Parmi les secteurs qui recrutent : **numérique**, **santé**, **BTP et infrastructures**, **agriculture et agro-industrie**, **énergie (notamment solaire)**, **logistique** autour des ports de Douala et Kribi, et l''**enseignement**.', 'Parmi les secteurs qui recrutent : **numérique**, **santé**, **BTP et infrastructures**, **agriculture et agro-industrie**, **énergie (notamment solaire)**, **logistique** autour des ports de Douala et Kribi, et l''**enseignement**.

- Le meilleur métier pour toi combine tes talents, ce que tu aimes et ce dont le marché a besoin.
- Les données sur l''emploi sont publiées par l''INS.', ARRAY[]::text[], ARRAY[]::text[], ARRAY['métiers porteurs', 'avenir', 'emploi', 'secteurs', 'recrutent']::text[], '[{"titre":"Institut National de la Statistique (INS) — annuaires et enquêtes","url":"https://ins-cameroun.cm"},{"titre":"Ministère de l''Emploi et de la Formation Professionnelle (MINEFOP) — centres agréés, examens, bourses","url":"https://www.minefop.gov.cm"}]'::jsonb),
('faq-choisir-metier', 'faq', 'Comment choisir mon futur métier ?', 'Métiers & emploi', NULL, 'Pars de trois questions : **qu''est-ce que j''aime faire ? dans quoi suis-je bon ? de quoi la société a-t-elle besoin ?** Puis renseigne-toi sur les études nécessaires.', 'Pars de trois questions : **qu''est-ce que j''aime faire ? dans quoi suis-je bon ? de quoi la société a-t-elle besoin ?** Puis renseigne-toi sur les études nécessaires.

- Discute avec des professionnels du métier visé.
- Fais un stage ou une observation si possible.
- Consulte le conseiller d''orientation de ton établissement.', ARRAY[]::text[], ARRAY[]::text[], ARRAY['choisir métier', 'orientation', 'projet professionnel', 'passion']::text[], '[{"titre":"Conseiller d''orientation de ton établissement (service d''orientation scolaire)"}]'::jsonb),
('faq-metier-informatique', 'faq', 'Comment travailler dans l''informatique au Cameroun ?', 'Métiers & emploi', NULL, 'Plusieurs voies : licence d''informatique, IUT, écoles d''ingénieurs, BTS/HND, ou autoformation sérieuse avec un **portfolio de projets**.', 'Plusieurs voies : licence d''informatique, IUT, écoles d''ingénieurs, BTS/HND, ou autoformation sérieuse avec un **portfolio de projets**.

- Métiers : développeur, administrateur réseaux, cybersécurité, analyste de données, designer d''interfaces.
- Les start-ups, banques et télécoms recrutent ; le freelance international est possible.', ARRAY[]::text[], ARRAY[]::text[], ARRAY['informatique', 'développeur', 'programmation', 'numérique', 'tech']::text[], '[{"titre":"Ministère de l''Enseignement Supérieur (MINESUP) — concours, BTS/HND, établissements","url":"https://www.minesup.gov.cm"},{"titre":"Ministère des Postes et Télécommunications (MINPOSTEL)","url":"https://www.minpostel.gov.cm"}]'::jsonb),
('faq-metier-agriculture', 'faq', 'L''agriculture est-elle un bon choix de carrière ?', 'Métiers & emploi', NULL, 'Oui, surtout si tu la vois comme une **entreprise** : production, transformation et vente (agrobusiness). Elle nourrit le pays et emploie une très grande partie des actifs.', 'Oui, surtout si tu la vois comme une **entreprise** : production, transformation et vente (agrobusiness). Elle nourrit le pays et emploie une très grande partie des actifs.

- Formations : FASA (Dschang), ENSAI (Ngaoundéré), écoles du MINADER, BTS/HND, formations courtes.
- Filières : cacao, café, maïs, manioc, maraîchage, aviculture, pisciculture.', ARRAY[]::text[], ARRAY[]::text[], ARRAY['agriculture', 'agrobusiness', 'élevage', 'agronome', 'ferme']::text[], '[{"titre":"Ministère de l''Agriculture et du Développement Rural (MINADER) — écoles d''agriculture","url":"https://www.minader.cm"},{"titre":"Ministère de l''Élevage, des Pêches et des Industries Animales (MINEPIA)","url":"https://minepia.cm"},{"titre":"Université de Dschang (FASA, IUT Fotso Victor de Bandjoun)","url":"https://www.univ-dschang.org"}]'::jsonb),
('faq-fonction-publique', 'faq', 'Comment entrer dans la fonction publique ?', 'Métiers & emploi', NULL, 'Principalement par **concours** (ENAM, ENS, écoles de santé, police, armée…) ou par les recrutements spéciaux annoncés officiellement.', 'Principalement par **concours** (ENAM, ENS, écoles de santé, police, armée…) ou par les recrutements spéciaux annoncés officiellement.

- Chaque concours précise le diplôme, l''âge et les pièces requises.
- Les dates, les frais et le nombre de places changent chaque année : seul le **communiqué officiel** fait foi.', ARRAY[]::text[], ARRAY[]::text[], ARRAY['fonction publique', 'fonctionnaire', 'concours administratifs', 'état']::text[], '[{"titre":"École Nationale d''Administration et de Magistrature (ENAM)","url":"https://www.enam.cm"},{"titre":"Ministère de l''Enseignement Supérieur (MINESUP) — concours, BTS/HND, établissements","url":"https://www.minesup.gov.cm"}]'::jsonb),
('faq-creer-entreprise', 'faq', 'Je veux créer mon entreprise après mes études : par où commencer ?', 'Métiers & emploi', NULL, 'Commence par une idée qui répond à un vrai besoin, teste-la à petite échelle, tiens une comptabilité dès le départ et formalise ton activité.', 'Commence par une idée qui répond à un vrai besoin, teste-la à petite échelle, tiens une comptabilité dès le départ et formalise ton activité.

- Formations à l''entrepreneuriat, incubateurs universitaires, accompagnement du FNE.
- Apprends les bases : gestion, marketing, fiscalité.', ARRAY[]::text[], ARRAY[]::text[], ARRAY['entreprise', 'entrepreneuriat', 'startup', 'business', 'auto-emploi']::text[], '[{"titre":"Fonds National de l''Emploi (FNE) — emploi, stages, auto-emploi (services gratuits)","url":"https://fnecm.org"},{"titre":"Ministère de l''Emploi et de la Formation Professionnelle (MINEFOP) — centres agréés, examens, bourses","url":"https://www.minefop.gov.cm"}]'::jsonb),
('faq-stage', 'faq', 'Comment trouver un stage ?', 'Métiers & emploi', NULL, 'Prépare un CV clair et une lettre de motivation, puis démarche directement les entreprises, les administrations et les ONG ; utilise aussi le réseau de ton école.', 'Prépare un CV clair et une lettre de motivation, puis démarche directement les entreprises, les administrations et les ONG ; utilise aussi le réseau de ton école.

- Commence tôt (plusieurs mois avant).
- Un stage bien fait se transforme souvent en premier emploi.', ARRAY[]::text[], ARRAY[]::text[], ARRAY['stage', 'cv', 'lettre de motivation', 'entreprise', 'expérience']::text[], '[{"titre":"Fonds National de l''Emploi (FNE) — emploi, stages, auto-emploi (services gratuits)","url":"https://fnecm.org"}]'::jsonb),
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

- Va le voir avec tes bulletins et tes questions.', ARRAY[]::text[], ARRAY[]::text[], ARRAY['conseiller d''orientation', 'lycée', 'aide', 'orientation']::text[], '[{"titre":"Ministère des Enseignements Secondaires (MINESEC)","url":"https://www.minesec.gov.cm"},{"titre":"Conseiller d''orientation de ton établissement (service d''orientation scolaire)"}]'::jsonb),
('faq-j-aime-maths', 'faq', 'J''aime les mathématiques : quels métiers et quelles études ?', 'Orientation par matière', NULL, 'Si tu aimes les mathématiques, plusieurs voies s''offrent à toi : ingénieur, informaticien, statisticien (ISSEA), actuaire, professeur de maths, économiste, analyste de données.', 'Si tu aimes les mathématiques, plusieurs voies s''offrent à toi : ingénieur, informaticien, statisticien (ISSEA), actuaire, professeur de maths, économiste, analyste de données.

## Séries conseillées
- C ou E (ou TI)

## Où se former au Cameroun
- ENSPY, ENSPD, ENSTP, ISSEA, ENS (section maths), facultés des sciences

## Pour aller plus loin
- Consulte les fiches **Métiers** et **Filières** correspondantes sur Mandal.
- Parle avec un professionnel du métier qui t''attire.
- Les dates, les frais et le nombre de places changent chaque année : seul le **communiqué officiel** fait foi.', ARRAY[]::text[], ARRAY[]::text[], ARRAY['mathématiques', 'j''aime', 'métiers', 'orientation', 'maths']::text[], '[{"titre":"École Nationale Supérieure Polytechnique de Yaoundé (ENSPY) — concours","url":"https://polytechnique.cm"},{"titre":"Institut Sous-régional de Statistique et d''Économie Appliquée (ISSEA, Yaoundé — CEMAC)","url":"https://www.issea-cemac.org"},{"titre":"Université de Yaoundé I (ENSP, ENS, FMSB, Faculté des Sciences)","url":"http://www.uy1.uninet.cm"},{"titre":"Conseiller d''orientation de ton établissement (service d''orientation scolaire)"}]'::jsonb),
('faq-j-aime-physique', 'faq', 'J''aime la physique : quels métiers et quelles études ?', 'Orientation par matière', NULL, 'Si tu aimes la physique, plusieurs voies s''offrent à toi : ingénieur (génie civil, électrique, mécanique), technicien en énergie solaire, géologue, technicien d''imagerie médicale, pilote, professeur de physique.', 'Si tu aimes la physique, plusieurs voies s''offrent à toi : ingénieur (génie civil, électrique, mécanique), technicien en énergie solaire, géologue, technicien d''imagerie médicale, pilote, professeur de physique.

## Séries conseillées
- C, D ou E

## Où se former au Cameroun
- écoles d''ingénieurs, IUT, facultés des sciences, ENS (physique-chimie)

## Pour aller plus loin
- Consulte les fiches **Métiers** et **Filières** correspondantes sur Mandal.
- Parle avec un professionnel du métier qui t''attire.
- Les dates, les frais et le nombre de places changent chaque année : seul le **communiqué officiel** fait foi.', ARRAY[]::text[], ARRAY[]::text[], ARRAY['physique', 'j''aime', 'métiers', 'orientation', 'physique']::text[], '[{"titre":"École Nationale Supérieure Polytechnique de Yaoundé (ENSPY) — concours","url":"https://polytechnique.cm"},{"titre":"Université de Yaoundé I (ENSP, ENS, FMSB, Faculté des Sciences)","url":"http://www.uy1.uninet.cm"},{"titre":"Ministère de l''Enseignement Supérieur (MINESUP) — concours, BTS/HND, établissements","url":"https://www.minesup.gov.cm"},{"titre":"Conseiller d''orientation de ton établissement (service d''orientation scolaire)"}]'::jsonb),
('faq-j-aime-svt', 'faq', 'J''aime les SVT (sciences de la vie et de la Terre) : quels métiers et quelles études ?', 'Orientation par matière', NULL, 'Si tu aimes les SVT (sciences de la vie et de la Terre), plusieurs voies s''offrent à toi : médecin, pharmacien, infirmier, sage-femme, vétérinaire, agronome, biologiste, technicien de laboratoire, professeur de SVT.', 'Si tu aimes les SVT (sciences de la vie et de la Terre), plusieurs voies s''offrent à toi : médecin, pharmacien, infirmier, sage-femme, vétérinaire, agronome, biologiste, technicien de laboratoire, professeur de SVT.

## Séries conseillées
- D (ou C)

## Où se former au Cameroun
- facultés de médecine (concours), FASA, ESMV, écoles paramédicales, facultés des sciences

## Pour aller plus loin
- Consulte les fiches **Métiers** et **Filières** correspondantes sur Mandal.
- Parle avec un professionnel du métier qui t''attire.
- Les dates, les frais et le nombre de places changent chaque année : seul le **communiqué officiel** fait foi.', ARRAY[]::text[], ARRAY[]::text[], ARRAY['SVT (sciences de la vie et de la Terre)', 'j''aime', 'métiers', 'orientation', 'svt']::text[], '[{"titre":"Ministère de la Santé Publique (MINSANTE) — écoles de formation paramédicale","url":"https://www.minsante.cm"},{"titre":"Faculté d''Agronomie et des Sciences Agricoles (FASA), Université de Dschang","url":"https://www.univ-dschang.org/fasa/"},{"titre":"École des Sciences et de Médecine Vétérinaire (ESMV), Université de Ngaoundéré","url":"https://esmv.univ-ndere.cm"},{"titre":"Conseiller d''orientation de ton établissement (service d''orientation scolaire)"}]'::jsonb),
('faq-j-aime-chimie', 'faq', 'J''aime la chimie : quels métiers et quelles études ?', 'Orientation par matière', NULL, 'Si tu aimes la chimie, plusieurs voies s''offrent à toi : pharmacien, ingénieur agroalimentaire (ENSAI), technicien de laboratoire, ingénieur des procédés, contrôleur qualité.', 'Si tu aimes la chimie, plusieurs voies s''offrent à toi : pharmacien, ingénieur agroalimentaire (ENSAI), technicien de laboratoire, ingénieur des procédés, contrôleur qualité.

## Séries conseillées
- C, D ou F7

## Où se former au Cameroun
- ENSAI, facultés des sciences, facultés de médecine et de pharmacie, IUT (génie biologique)

## Pour aller plus loin
- Consulte les fiches **Métiers** et **Filières** correspondantes sur Mandal.
- Parle avec un professionnel du métier qui t''attire.
- Les dates, les frais et le nombre de places changent chaque année : seul le **communiqué officiel** fait foi.', ARRAY[]::text[], ARRAY[]::text[], ARRAY['chimie', 'j''aime', 'métiers', 'orientation', 'chimie']::text[], '[{"titre":"École Nationale Supérieure des Sciences Agro-Industrielles (ENSAI), Ngaoundéré","url":"https://ensai.univ-ndere.cm"},{"titre":"Université de Yaoundé I (ENSP, ENS, FMSB, Faculté des Sciences)","url":"http://www.uy1.uninet.cm"},{"titre":"Ministère de l''Enseignement Supérieur (MINESUP) — concours, BTS/HND, établissements","url":"https://www.minesup.gov.cm"},{"titre":"Conseiller d''orientation de ton établissement (service d''orientation scolaire)"}]'::jsonb),
('faq-j-aime-informatique', 'faq', 'J''aime l''informatique : quels métiers et quelles études ?', 'Orientation par matière', NULL, 'Si tu aimes l''informatique, plusieurs voies s''offrent à toi : développeur, administrateur réseaux, spécialiste en cybersécurité, analyste de données, designer d''interfaces, technicien de maintenance.', 'Si tu aimes l''informatique, plusieurs voies s''offrent à toi : développeur, administrateur réseaux, spécialiste en cybersécurité, analyste de données, designer d''interfaces, technicien de maintenance.

## Séries conseillées
- TI, C ou E

## Où se former au Cameroun
- facultés des sciences, IUT, écoles d''ingénieurs (génie informatique, télécoms), BTS/HND

## Pour aller plus loin
- Consulte les fiches **Métiers** et **Filières** correspondantes sur Mandal.
- Parle avec un professionnel du métier qui t''attire.
- Les dates, les frais et le nombre de places changent chaque année : seul le **communiqué officiel** fait foi.', ARRAY[]::text[], ARRAY[]::text[], ARRAY['informatique', 'j''aime', 'métiers', 'orientation', 'informatique']::text[], '[{"titre":"École Nationale Supérieure Polytechnique de Yaoundé (ENSPY) — concours","url":"https://polytechnique.cm"},{"titre":"Ministère des Postes et Télécommunications (MINPOSTEL)","url":"https://www.minpostel.gov.cm"},{"titre":"Ministère de l''Enseignement Supérieur (MINESUP) — concours, BTS/HND, établissements","url":"https://www.minesup.gov.cm"},{"titre":"Conseiller d''orientation de ton établissement (service d''orientation scolaire)"}]'::jsonb),
('faq-j-aime-francais', 'faq', 'J''aime le français et la littérature : quels métiers et quelles études ?', 'Orientation par matière', NULL, 'Si tu aimes le français et la littérature, plusieurs voies s''offrent à toi : journaliste, écrivain, éditeur, avocat, professeur de français, traducteur, chargé de communication.', 'Si tu aimes le français et la littérature, plusieurs voies s''offrent à toi : journaliste, écrivain, éditeur, avocat, professeur de français, traducteur, chargé de communication.

## Séries conseillées
- A (ou toute série)

## Où se former au Cameroun
- facultés de lettres, ESSTIC, ENS (lettres), facultés de droit, ASTI après la licence

## Pour aller plus loin
- Consulte les fiches **Métiers** et **Filières** correspondantes sur Mandal.
- Parle avec un professionnel du métier qui t''attire.
- Les dates, les frais et le nombre de places changent chaque année : seul le **communiqué officiel** fait foi.', ARRAY[]::text[], ARRAY[]::text[], ARRAY['français et la littérature', 'j''aime', 'métiers', 'orientation', 'francais']::text[], '[{"titre":"ESSTIC — École Supérieure des Sciences et Techniques de l''Information et de la Communication (Université de Yaoundé II)"},{"titre":"Université de Yaoundé II-Soa (Droit, Économie, ESSTIC, IRIC)","url":"https://site.univ-yaounde2.org"},{"titre":"Ministère de l''Enseignement Supérieur (MINESUP) — concours, BTS/HND, établissements","url":"https://www.minesup.gov.cm"},{"titre":"Conseiller d''orientation de ton établissement (service d''orientation scolaire)"}]'::jsonb),
('faq-j-aime-anglais', 'faq', 'J''aime l''anglais et les langues : quels métiers et quelles études ?', 'Orientation par matière', NULL, 'Si tu aimes l''anglais et les langues, plusieurs voies s''offrent à toi : traducteur, interprète, professeur de langues, guide touristique, diplomate, assistant bilingue.', 'Si tu aimes l''anglais et les langues, plusieurs voies s''offrent à toi : traducteur, interprète, professeur de langues, guide touristique, diplomate, assistant bilingue.

## Séries conseillées
- A (ou toute série) ; Arts au GCE

## Où se former au Cameroun
- facultés de lettres (langues), ASTI (Buea), IRIC, ENS (langues)

## Pour aller plus loin
- Consulte les fiches **Métiers** et **Filières** correspondantes sur Mandal.
- Parle avec un professionnel du métier qui t''attire.
- Les dates, les frais et le nombre de places changent chaque année : seul le **communiqué officiel** fait foi.', ARRAY[]::text[], ARRAY[]::text[], ARRAY['anglais et les langues', 'j''aime', 'métiers', 'orientation', 'anglais']::text[], '[{"titre":"University of Buea (Faculty of Health Sciences, ASTI, COT, faculties)","url":"https://www.ubuea.cm"},{"titre":"IRIC — Institut des Relations Internationales du Cameroun (Université de Yaoundé II)"},{"titre":"Ministère de l''Enseignement Supérieur (MINESUP) — concours, BTS/HND, établissements","url":"https://www.minesup.gov.cm"},{"titre":"Conseiller d''orientation de ton établissement (service d''orientation scolaire)"}]'::jsonb),
('faq-j-aime-histoire-geo', 'faq', 'J''aime l''histoire et la géographie : quels métiers et quelles études ?', 'Orientation par matière', NULL, 'Si tu aimes l''histoire et la géographie, plusieurs voies s''offrent à toi : professeur d''histoire-géographie, urbaniste, géomaticien (SIG), guide touristique, diplomate, archiviste, administrateur civil.', 'Si tu aimes l''histoire et la géographie, plusieurs voies s''offrent à toi : professeur d''histoire-géographie, urbaniste, géomaticien (SIG), guide touristique, diplomate, archiviste, administrateur civil.

## Séries conseillées
- A

## Où se former au Cameroun
- facultés de lettres et sciences humaines, ENS, ENSTP (urbanisme), IRIC, ENAM

## Pour aller plus loin
- Consulte les fiches **Métiers** et **Filières** correspondantes sur Mandal.
- Parle avec un professionnel du métier qui t''attire.
- Les dates, les frais et le nombre de places changent chaque année : seul le **communiqué officiel** fait foi.', ARRAY[]::text[], ARRAY[]::text[], ARRAY['histoire et la géographie', 'j''aime', 'métiers', 'orientation', 'histoire geo']::text[], '[{"titre":"Université de Yaoundé I (ENSP, ENS, FMSB, Faculté des Sciences)","url":"http://www.uy1.uninet.cm"},{"titre":"École Nationale d''Administration et de Magistrature (ENAM)","url":"https://www.enam.cm"},{"titre":"Ministère de l''Enseignement Supérieur (MINESUP) — concours, BTS/HND, établissements","url":"https://www.minesup.gov.cm"},{"titre":"Conseiller d''orientation de ton établissement (service d''orientation scolaire)"}]'::jsonb),
('faq-j-aime-philosophie', 'faq', 'J''aime la philosophie : quels métiers et quelles études ?', 'Orientation par matière', NULL, 'Si tu aimes la philosophie, plusieurs voies s''offrent à toi : professeur de philosophie, journaliste, avocat, magistrat, administrateur, conseiller d''orientation.', 'Si tu aimes la philosophie, plusieurs voies s''offrent à toi : professeur de philosophie, journaliste, avocat, magistrat, administrateur, conseiller d''orientation.

## Séries conseillées
- A

## Où se former au Cameroun
- facultés de lettres (philosophie), ENS, facultés de droit, concours de l''ENAM

## Pour aller plus loin
- Consulte les fiches **Métiers** et **Filières** correspondantes sur Mandal.
- Parle avec un professionnel du métier qui t''attire.
- Les dates, les frais et le nombre de places changent chaque année : seul le **communiqué officiel** fait foi.', ARRAY[]::text[], ARRAY[]::text[], ARRAY['philosophie', 'j''aime', 'métiers', 'orientation', 'philosophie']::text[], '[{"titre":"Université de Yaoundé I (ENSP, ENS, FMSB, Faculté des Sciences)","url":"http://www.uy1.uninet.cm"},{"titre":"École Nationale d''Administration et de Magistrature (ENAM)","url":"https://www.enam.cm"},{"titre":"Ministère de l''Enseignement Supérieur (MINESUP) — concours, BTS/HND, établissements","url":"https://www.minesup.gov.cm"},{"titre":"Conseiller d''orientation de ton établissement (service d''orientation scolaire)"}]'::jsonb),
('faq-j-aime-economie', 'faq', 'J''aime l''économie et la gestion : quels métiers et quelles études ?', 'Orientation par matière', NULL, 'Si tu aimes l''économie et la gestion, plusieurs voies s''offrent à toi : comptable, banquier, auditeur, économiste, gestionnaire, logisticien, entrepreneur, inspecteur des impôts.', 'Si tu aimes l''économie et la gestion, plusieurs voies s''offrent à toi : comptable, banquier, auditeur, économiste, gestionnaire, logisticien, entrepreneur, inspecteur des impôts.

## Séries conseillées
- A, C, D ou séries commerciales (technique)

## Où se former au Cameroun
- facultés des sciences économiques et de gestion, ESSEC, BTS/HND, ISSEA, ENAM (régies financières)

## Pour aller plus loin
- Consulte les fiches **Métiers** et **Filières** correspondantes sur Mandal.
- Parle avec un professionnel du métier qui t''attire.
- Les dates, les frais et le nombre de places changent chaque année : seul le **communiqué officiel** fait foi.', ARRAY[]::text[], ARRAY[]::text[], ARRAY['économie et la gestion', 'j''aime', 'métiers', 'orientation', 'economie']::text[], '[{"titre":"ESSEC — École Supérieure des Sciences Économiques et Commerciales, Université de Douala","url":"https://essec-douala.cm"},{"titre":"Université de Yaoundé II-Soa (Droit, Économie, ESSTIC, IRIC)","url":"https://site.univ-yaounde2.org"},{"titre":"École Nationale d''Administration et de Magistrature (ENAM)","url":"https://www.enam.cm"},{"titre":"Conseiller d''orientation de ton établissement (service d''orientation scolaire)"}]'::jsonb),
('faq-j-aime-dessin-arts', 'faq', 'J''aime le dessin et les arts : quels métiers et quelles études ?', 'Orientation par matière', NULL, 'Si tu aimes le dessin et les arts, plusieurs voies s''offrent à toi : graphiste, architecte, designer d''interfaces, styliste, photographe, artiste plasticien.', 'Si tu aimes le dessin et les arts, plusieurs voies s''offrent à toi : graphiste, architecte, designer d''interfaces, styliste, photographe, artiste plasticien.

## Séries conseillées
- toute série (A conseillée) ou formation artistique

## Où se former au Cameroun
- Institut des Beaux-Arts de Foumban (Université de Dschang), écoles de design et d''architecture

## Pour aller plus loin
- Consulte les fiches **Métiers** et **Filières** correspondantes sur Mandal.
- Parle avec un professionnel du métier qui t''attire.
- Les dates, les frais et le nombre de places changent chaque année : seul le **communiqué officiel** fait foi.', ARRAY[]::text[], ARRAY[]::text[], ARRAY['dessin et les arts', 'j''aime', 'métiers', 'orientation', 'dessin arts']::text[], '[{"titre":"Université de Dschang (FASA, IUT Fotso Victor de Bandjoun)","url":"https://www.univ-dschang.org"},{"titre":"Ministère de l''Enseignement Supérieur (MINESUP) — concours, BTS/HND, établissements","url":"https://www.minesup.gov.cm"},{"titre":"Conseiller d''orientation de ton établissement (service d''orientation scolaire)"}]'::jsonb),
('faq-j-aime-sport', 'faq', 'J''aime le sport : quels métiers et quelles études ?', 'Orientation par matière', NULL, 'Si tu aimes le sport, plusieurs voies s''offrent à toi : professeur d''EPS, entraîneur, éducateur sportif, kinésithérapeute, sapeur-pompier, militaire.', 'Si tu aimes le sport, plusieurs voies s''offrent à toi : professeur d''EPS, entraîneur, éducateur sportif, kinésithérapeute, sapeur-pompier, militaire.

## Séries conseillées
- toute série

## Où se former au Cameroun
- formations des professeurs d''EPS (concours), diplômes des fédérations, écoles paramédicales (kinésithérapie)

## Pour aller plus loin
- Consulte les fiches **Métiers** et **Filières** correspondantes sur Mandal.
- Parle avec un professionnel du métier qui t''attire.
- Les dates, les frais et le nombre de places changent chaque année : seul le **communiqué officiel** fait foi.', ARRAY[]::text[], ARRAY[]::text[], ARRAY['sport', 'j''aime', 'métiers', 'orientation', 'sport']::text[], '[{"titre":"Ministère de l''Enseignement Supérieur (MINESUP) — concours, BTS/HND, établissements","url":"https://www.minesup.gov.cm"},{"titre":"Ministère de la Défense (MINDEF) — EMIA et recrutements des forces de défense","url":"https://mindef.gov.cm"},{"titre":"Conseiller d''orientation de ton établissement (service d''orientation scolaire)"}]'::jsonb),
('faq-j-aime-technique', 'faq', 'J''aime bricoler, réparer et construire : quels métiers et quelles études ?', 'Orientation par matière', NULL, 'Si tu aimes bricoler, réparer et construire, plusieurs voies s''offrent à toi : électricien, technicien solaire, mécanicien, frigoriste, soudeur, technicien BTP, réparateur de téléphones.', 'Si tu aimes bricoler, réparer et construire, plusieurs voies s''offrent à toi : électricien, technicien solaire, mécanicien, frigoriste, soudeur, technicien BTP, réparateur de téléphones.

## Séries conseillées
- lycée technique (séries F, CAP, BT)

## Où se former au Cameroun
- lycées techniques, IUT, BTS/HND, centres de formation professionnelle agréés (MINEFOP)

## Pour aller plus loin
- Consulte les fiches **Métiers** et **Filières** correspondantes sur Mandal.
- Parle avec un professionnel du métier qui t''attire.
- Les dates, les frais et le nombre de places changent chaque année : seul le **communiqué officiel** fait foi.', ARRAY[]::text[], ARRAY[]::text[], ARRAY['bricoler, réparer et construire', 'j''aime', 'métiers', 'orientation', 'technique']::text[], '[{"titre":"Office du Baccalauréat du Cameroun (OBC) — Probatoire, Baccalauréat, BT","url":"https://www.obc.cm"},{"titre":"Ministère de l''Emploi et de la Formation Professionnelle (MINEFOP) — centres agréés, examens, bourses","url":"https://www.minefop.gov.cm"},{"titre":"Ministère de l''Enseignement Supérieur (MINESUP) — concours, BTS/HND, établissements","url":"https://www.minesup.gov.cm"},{"titre":"Conseiller d''orientation de ton établissement (service d''orientation scolaire)"}]'::jsonb),
('faq-j-aime-social', 'faq', 'J''aime aider les autres : quels métiers et quelles études ?', 'Orientation par matière', NULL, 'Si tu aimes aider les autres, plusieurs voies s''offrent à toi : infirmier, sage-femme, travailleur social, psychologue, enseignant, conseiller d''orientation, animateur de jeunesse.', 'Si tu aimes aider les autres, plusieurs voies s''offrent à toi : infirmier, sage-femme, travailleur social, psychologue, enseignant, conseiller d''orientation, animateur de jeunesse.

## Séries conseillées
- toute série

## Où se former au Cameroun
- écoles paramédicales, facultés de lettres et sciences humaines, ENS, formations en travail social

## Pour aller plus loin
- Consulte les fiches **Métiers** et **Filières** correspondantes sur Mandal.
- Parle avec un professionnel du métier qui t''attire.
- Les dates, les frais et le nombre de places changent chaque année : seul le **communiqué officiel** fait foi.', ARRAY[]::text[], ARRAY[]::text[], ARRAY['aider les autres', 'j''aime', 'métiers', 'orientation', 'social']::text[], '[{"titre":"Ministère de la Santé Publique (MINSANTE) — écoles de formation paramédicale","url":"https://www.minsante.cm"},{"titre":"Ministère de la Jeunesse et de l''Éducation Civique (MINJEC) — insertion des jeunes","url":"https://www.minjec.gov.cm"},{"titre":"Ministère de l''Enseignement Supérieur (MINESUP) — concours, BTS/HND, établissements","url":"https://www.minesup.gov.cm"},{"titre":"Conseiller d''orientation de ton établissement (service d''orientation scolaire)"}]'::jsonb),
('faq-j-aime-nature', 'faq', 'J''aime la nature et les animaux : quels métiers et quelles études ?', 'Orientation par matière', NULL, 'Si tu aimes la nature et les animaux, plusieurs voies s''offrent à toi : agronome, vétérinaire, technicien des eaux et forêts, pisciculteur, apiculteur, spécialiste de l''environnement.', 'Si tu aimes la nature et les animaux, plusieurs voies s''offrent à toi : agronome, vétérinaire, technicien des eaux et forêts, pisciculteur, apiculteur, spécialiste de l''environnement.

## Séries conseillées
- D ou C

## Où se former au Cameroun
- FASA, ESMV, ENEF de Mbalmayo, École de Faune de Garoua, écoles d''agriculture du MINADER

## Pour aller plus loin
- Consulte les fiches **Métiers** et **Filières** correspondantes sur Mandal.
- Parle avec un professionnel du métier qui t''attire.
- Les dates, les frais et le nombre de places changent chaque année : seul le **communiqué officiel** fait foi.', ARRAY[]::text[], ARRAY[]::text[], ARRAY['nature et les animaux', 'j''aime', 'métiers', 'orientation', 'nature']::text[], '[{"titre":"Faculté d''Agronomie et des Sciences Agricoles (FASA), Université de Dschang","url":"https://www.univ-dschang.org/fasa/"},{"titre":"École des Sciences et de Médecine Vétérinaire (ESMV), Université de Ngaoundéré","url":"https://esmv.univ-ndere.cm"},{"titre":"Ministère des Forêts et de la Faune (MINFOF) — ENEF Mbalmayo, École de Faune de Garoua","url":"https://www.minfof.gov.cm"},{"titre":"Conseiller d''orientation de ton établissement (service d''orientation scolaire)"}]'::jsonb),
('faq-gce-results-where', 'faq', 'Where can I check my GCE O Level or A Level results?', 'Anglophone subsystem', NULL, 'GCE results are published by the **Cameroon GCE Board**, through its official channels and in schools.', 'GCE results are published by the **Cameroon GCE Board**, through its official channels and in schools.

- Never pay anyone who promises to show or change your results.
- Keep your candidate number safe.', ARRAY[]::text[], ARRAY[]::text[], ARRAY['gce results', 'o level', 'a level', 'gce board', 'results']::text[], '[{"titre":"Cameroon GCE Board — GCE O Level / A Level","url":"https://www.camgceb.org"}]'::jsonb),
('faq-after-o-level', 'faq', 'What can I do after my GCE O Level?', 'Anglophone subsystem', NULL, 'You can go to **High School** (Lower Sixth) and prepare the A Level, follow a **technical** path, or start a **vocational training** programme.', 'You can go to **High School** (Lower Sixth) and prepare the A Level, follow a **technical** path, or start a **vocational training** programme.

- Choose your A Level subjects according to the career you want (sciences, arts, commercial).
- Good O Level grades in English Language and Mathematics are required by many schools.', ARRAY[]::text[], ARRAY[]::text[], ARRAY['after o level', 'lower sixth', 'high school', 'subjects']::text[], '[{"titre":"Cameroon GCE Board — GCE O Level / A Level","url":"https://www.camgceb.org"},{"titre":"Ministère des Enseignements Secondaires (MINESEC)","url":"https://www.minesec.gov.cm"},{"titre":"Ministère de l''Emploi et de la Formation Professionnelle (MINEFOP) — centres agréés, examens, bourses","url":"https://www.minefop.gov.cm"}]'::jsonb),
('faq-a-level-to-university', 'faq', 'Which universities can I attend with the GCE A Level?', 'Anglophone subsystem', NULL, 'With the A Level you can apply to **all state universities**, especially the English-speaking ones: the **University of Buea** and the **University of Bamenda**, as well as bilingual universities.', 'With the A Level you can apply to **all state universities**, especially the English-speaking ones: the **University of Buea** and the **University of Bamenda**, as well as bilingual universities.

- Professional schools (medicine, engineering, teacher training) recruit through **competitive entrance examinations**.
- Les dates, les frais et le nombre de places changent chaque année : seul le **communiqué officiel** fait foi.', ARRAY[]::text[], ARRAY[]::text[], ARRAY['university', 'a level', 'buea', 'bamenda', 'admission']::text[], '[{"titre":"University of Buea (Faculty of Health Sciences, ASTI, COT, faculties)","url":"https://www.ubuea.cm"},{"titre":"The University of Bamenda (COLTECH, HTTTC, NAHPI)","url":"https://uniba.cm"},{"titre":"Ministère de l''Enseignement Supérieur (MINESUP) — concours, BTS/HND, établissements","url":"https://www.minesup.gov.cm"}]'::jsonb),
('faq-hnd-what', 'faq', 'What is the HND and is it recognised?', 'Anglophone subsystem', NULL, 'The **HND** (Higher National Diploma) is a two-year higher education diploma prepared in approved institutions and awarded after a **national examination organised by MINESUP**.', 'The **HND** (Higher National Diploma) is a two-year higher education diploma prepared in approved institutions and awarded after a **national examination organised by MINESUP**.

- Always check that the institution and the programme are approved by MINESUP.
- After the HND you can work or continue to a professional bachelor''s degree.', ARRAY[]::text[], ARRAY[]::text[], ARRAY['hnd', 'higher national diploma', 'approved', 'minesup']::text[], '[{"titre":"Ministère de l''Enseignement Supérieur (MINESUP) — concours, BTS/HND, établissements","url":"https://www.minesup.gov.cm"}]'::jsonb),
('faq-francophone-in-english-university', 'faq', 'Can a Francophone student study in an English-speaking university?', 'Anglophone subsystem', NULL, 'Yes. The Baccalauréat gives access to state universities, including Buea and Bamenda, but lectures are in **English**, so a good level of English is essential.', 'Yes. The Baccalauréat gives access to state universities, including Buea and Bamenda, but lectures are in **English**, so a good level of English is essential.

- Start improving your English now: reading, listening, writing.
- Being bilingual is a major advantage for competitive exams and jobs in Cameroon.', ARRAY[]::text[], ARRAY[]::text[], ARRAY['francophone', 'english', 'bilingual', 'buea', 'bamenda']::text[], '[{"titre":"University of Buea (Faculty of Health Sciences, ASTI, COT, faculties)","url":"https://www.ubuea.cm"},{"titre":"The University of Bamenda (COLTECH, HTTTC, NAHPI)","url":"https://uniba.cm"}]'::jsonb),
('faq-nursing-anglophone', 'faq', 'How can I become a nurse in the English-speaking system?', 'Anglophone subsystem', NULL, 'Through the **competitive entrance examinations** into nursing and midwifery programmes (for example at the University of Buea or the University of Bamenda) or into approved health training schools.', 'Through the **competitive entrance examinations** into nursing and midwifery programmes (for example at the University of Buea or the University of Bamenda) or into approved health training schools.

- Biology and Chemistry at A Level are very useful.
- Les dates, les frais et le nombre de places changent chaque année : seul le **communiqué officiel** fait foi.', ARRAY[]::text[], ARRAY[]::text[], ARRAY['nursing', 'nurse', 'midwifery', 'health']::text[], '[{"titre":"University of Buea (Faculty of Health Sciences, ASTI, COT, faculties)","url":"https://www.ubuea.cm"},{"titre":"The University of Bamenda (COLTECH, HTTTC, NAHPI)","url":"https://uniba.cm"},{"titre":"Ministère de la Santé Publique (MINSANTE) — écoles de formation paramédicale","url":"https://www.minsante.cm"}]'::jsonb),
('faq-engineering-anglophone', 'faq', 'How can I become an engineer after the A Level?', 'Anglophone subsystem', NULL, 'Take Mathematics and Physics at A Level, then write the entrance examinations of engineering schools such as the **College of Technology (Buea)**, **COLTECH / NAHPI (Bamenda)** or the **polytechnic schools** of Yaoundé and Douala.', 'Take Mathematics and Physics at A Level, then write the entrance examinations of engineering schools such as the **College of Technology (Buea)**, **COLTECH / NAHPI (Bamenda)** or the **polytechnic schools** of Yaoundé and Douala.

- Practise past questions in Mathematics and Physics.
- Les dates, les frais et le nombre de places changent chaque année : seul le **communiqué officiel** fait foi.', ARRAY[]::text[], ARRAY[]::text[], ARRAY['engineering', 'engineer', 'coltech', 'polytechnic', 'a level']::text[], '[{"titre":"University of Buea (Faculty of Health Sciences, ASTI, COT, faculties)","url":"https://www.ubuea.cm"},{"titre":"The University of Bamenda (COLTECH, HTTTC, NAHPI)","url":"https://uniba.cm"},{"titre":"École Nationale Supérieure Polytechnique de Yaoundé (ENSPY) — concours","url":"https://polytechnique.cm"}]'::jsonb),
('faq-teacher-anglophone', 'faq', 'How do I become a secondary school teacher in the English-speaking system?', 'Anglophone subsystem', NULL, 'Through the competitive entrance examinations of the **Higher Teacher Training Colleges** (for example HTTC/HTTTC Bambili) or the Écoles Normales Supérieures.', 'Through the competitive entrance examinations of the **Higher Teacher Training Colleges** (for example HTTC/HTTTC Bambili) or the Écoles Normales Supérieures.

- Choose the subject you are best at.
- Les dates, les frais et le nombre de places changent chaque année : seul le **communiqué officiel** fait foi.', ARRAY[]::text[], ARRAY[]::text[], ARRAY['teacher', 'httc', 'htttc', 'teaching', 'bambili']::text[], '[{"titre":"The University of Bamenda (COLTECH, HTTTC, NAHPI)","url":"https://uniba.cm"},{"titre":"Ministère de l''Enseignement Supérieur (MINESUP) — concours, BTS/HND, établissements","url":"https://www.minesup.gov.cm"},{"titre":"Ministère des Enseignements Secondaires (MINESEC)","url":"https://www.minesec.gov.cm"}]'::jsonb),
('faq-translator-asti', 'faq', 'How can I become a translator or interpreter?', 'Anglophone subsystem', NULL, 'After a bachelor''s degree in any field, write the entrance examination of **ASTI (University of Buea)**: written tests for translation, oral tests for interpretation.', 'After a bachelor''s degree in any field, write the entrance examination of **ASTI (University of Buea)**: written tests for translation, oral tests for interpretation.

- Read and write every day in English and French.
- A third language (German, Spanish, Arabic, Chinese…) is a strong asset.', ARRAY[]::text[], ARRAY[]::text[], ARRAY['translator', 'interpreter', 'asti', 'translation']::text[], '[{"titre":"University of Buea (Faculty of Health Sciences, ASTI, COT, faculties)","url":"https://www.ubuea.cm"},{"titre":"Ministère de l''Enseignement Supérieur (MINESUP) — concours, BTS/HND, établissements","url":"https://www.minesup.gov.cm"}]'::jsonb),
('faq-scholarship-anglophone', 'faq', 'How can I find a scholarship?', 'Anglophone subsystem', NULL, 'Scholarships are announced through **official communiqués** (MINESUP, embassies, international organisations) and are mostly based on academic merit.', 'Scholarships are announced through **official communiqués** (MINESUP, embassies, international organisations) and are mostly based on academic merit.

- Keep good grades and prepare your documents early (transcripts, recommendation letters).
- Never pay an agent who “guarantees” a scholarship.', ARRAY[]::text[], ARRAY[]::text[], ARRAY['scholarship', 'grant', 'study abroad', 'funding']::text[], '[{"titre":"Ministère de l''Enseignement Supérieur (MINESUP) — concours, BTS/HND, établissements","url":"https://www.minesup.gov.cm"}]'::jsonb),
('faq-frais-universite', 'faq', 'Combien coûte l''université d''État ?', 'Université', NULL, 'Dans les universités d''État, les **droits universitaires** sont fixés par les textes et restent modestes par rapport au privé ; les écoles professionnelles ont des frais de concours et de formation spécifiques.', 'Dans les universités d''État, les **droits universitaires** sont fixés par les textes et restent modestes par rapport au privé ; les écoles professionnelles ont des frais de concours et de formation spécifiques.

- Prévois aussi le logement, le transport, les fournitures et la nourriture : c''est souvent la plus grosse dépense.
- Les dates, les frais et le nombre de places changent chaque année : seul le **communiqué officiel** fait foi.', ARRAY[]::text[], ARRAY[]::text[], ARRAY['frais', 'coût', 'droits universitaires', 'prix', 'université']::text[], '[{"titre":"Ministère de l''Enseignement Supérieur (MINESUP) — concours, BTS/HND, établissements","url":"https://www.minesup.gov.cm"},{"titre":"Loi n°2023/007 du 25 juillet 2023 portant orientation de l''enseignement supérieur au Cameroun"}]'::jsonb),
('faq-logement-etudiant', 'faq', 'Comment trouver un logement étudiant ?', 'Université', NULL, 'Renseigne-toi sur les **cités universitaires** de ton université, puis sur les mini-cités privées autour du campus. Visite toujours avant de payer.', 'Renseigne-toi sur les **cités universitaires** de ton université, puis sur les mini-cités privées autour du campus. Visite toujours avant de payer.

- Demande un reçu pour chaque paiement et lis le contrat de bail.
- La colocation réduit les coûts.
- Méfie-toi des « démarcheurs » qui demandent de l''argent sans montrer le logement.', ARRAY[]::text[], ARRAY[]::text[], ARRAY['logement', 'cité universitaire', 'mini-cité', 'chambre', 'location']::text[], '[{"titre":"Ministère de l''Enseignement Supérieur (MINESUP) — concours, BTS/HND, établissements","url":"https://www.minesup.gov.cm"}]'::jsonb),
('faq-petits-boulots', 'faq', 'Peut-on travailler en étudiant ?', 'Université', NULL, 'Oui, beaucoup d''étudiants donnent des **cours de répétition**, font de la vente, du service client ou des missions numériques. L''essentiel est de garder du temps pour réviser.', 'Oui, beaucoup d''étudiants donnent des **cours de répétition**, font de la vente, du service client ou des missions numériques. L''essentiel est de garder du temps pour réviser.

- Les cours de répétition valorisent tes connaissances.
- Les compétences numériques (graphisme, saisie, réseaux sociaux) permettent des missions en ligne.', ARRAY[]::text[], ARRAY[]::text[], ARRAY['job étudiant', 'petit boulot', 'répétiteur', 'travailler']::text[], '[{"titre":"Fonds National de l''Emploi (FNE) — emploi, stages, auto-emploi (services gratuits)","url":"https://fnecm.org"}]'::jsonb),
('faq-redoublement-universite', 'faq', 'J''ai échoué à mes examens à l''université : que faire ?', 'Université', NULL, 'Grâce au système LMD, les **crédits acquis restent acquis** : concentre-toi sur les unités d''enseignement non validées lors des rattrapages ou de l''année suivante.', 'Grâce au système LMD, les **crédits acquis restent acquis** : concentre-toi sur les unités d''enseignement non validées lors des rattrapages ou de l''année suivante.

- Analyse tes résultats avec un enseignant ou un tuteur.
- Organise-toi en groupe de travail.
- Si la filière ne te convient vraiment pas, pense à une réorientation (IUT, BTS/HND, autre faculté).', ARRAY[]::text[], ARRAY[]::text[], ARRAY['échec', 'université', 'rattrapage', 'crédits', 'redoubler']::text[], '[{"titre":"Ministère de l''Enseignement Supérieur (MINESUP) — concours, BTS/HND, établissements","url":"https://www.minesup.gov.cm"},{"titre":"Loi n°2023/007 du 25 juillet 2023 portant orientation de l''enseignement supérieur au Cameroun"}]'::jsonb),
('faq-verifier-agrement', 'faq', 'Comment vérifier qu''un institut privé est agréé ?', 'BTS, HND et formation professionnelle', NULL, 'Demande à l''institut son **arrêté d''agrément** (numéro et date) et vérifie-le auprès du **MINESUP** pour l''enseignement supérieur, ou du **MINEFOP** pour la formation professionnelle.', 'Demande à l''institut son **arrêté d''agrément** (numéro et date) et vérifie-le auprès du **MINESUP** pour l''enseignement supérieur, ou du **MINEFOP** pour la formation professionnelle.

- Vérifie aussi que la **filière précise** est autorisée, pas seulement l''institut.
- Un diplôme non reconnu ne permet ni concours ni emploi public.', ARRAY[]::text[], ARRAY[]::text[], ARRAY['agrément', 'institut privé', 'reconnu', 'arnaque', 'école privée']::text[], '[{"titre":"Ministère de l''Enseignement Supérieur (MINESUP) — concours, BTS/HND, établissements","url":"https://www.minesup.gov.cm"},{"titre":"Ministère de l''Emploi et de la Formation Professionnelle (MINEFOP) — centres agréés, examens, bourses","url":"https://www.minefop.gov.cm"},{"titre":"Loi n°2018/010 du 11 juillet 2018 régissant la formation professionnelle au Cameroun"}]'::jsonb),
('faq-loi-formation-pro', 'faq', 'Que dit la loi sur la formation professionnelle ?', 'BTS, HND et formation professionnelle', NULL, 'La **loi n°2018/010 du 11 juillet 2018** régit la formation professionnelle au Cameroun : elle en fait une priorité nationale et organise les centres, les certifications et l''orientation professionnelle.', 'La **loi n°2018/010 du 11 juillet 2018** régit la formation professionnelle au Cameroun : elle en fait une priorité nationale et organise les centres, les certifications et l''orientation professionnelle.

- Les centres de formation doivent être agréés par le MINEFOP.
- Les examens et certifications professionnels sont organisés sous l''autorité de l''État.', ARRAY[]::text[], ARRAY[]::text[], ARRAY['loi', 'formation professionnelle', '2018', 'minefop']::text[], '[{"titre":"Loi n°2018/010 du 11 juillet 2018 régissant la formation professionnelle au Cameroun"},{"titre":"Ministère de l''Emploi et de la Formation Professionnelle (MINEFOP) — centres agréés, examens, bourses","url":"https://www.minefop.gov.cm"}]'::jsonb),
('faq-bourses-formation-pro', 'faq', 'Existe-t-il des bourses pour la formation professionnelle ?', 'BTS, HND et formation professionnelle', NULL, 'Oui, le **MINEFOP** publie des informations sur les bourses de formation professionnelle, et le **FNE** propose des programmes de formation et d''insertion.', 'Oui, le **MINEFOP** publie des informations sur les bourses de formation professionnelle, et le **FNE** propose des programmes de formation et d''insertion.

- Surveille les communiqués officiels du MINEFOP et du FNE.
- Les dates, les frais et le nombre de places changent chaque année : seul le **communiqué officiel** fait foi.', ARRAY[]::text[], ARRAY[]::text[], ARRAY['bourse', 'formation professionnelle', 'minefop', 'fne']::text[], '[{"titre":"Ministère de l''Emploi et de la Formation Professionnelle (MINEFOP) — centres agréés, examens, bourses","url":"https://www.minefop.gov.cm"},{"titre":"Fonds National de l''Emploi (FNE) — emploi, stages, auto-emploi (services gratuits)","url":"https://fnecm.org"}]'::jsonb),
('faq-fne-stage-diplomes', 'faq', 'Je suis diplômé sans emploi : le FNE peut-il m''aider ?', 'Métiers & emploi', NULL, 'Oui. Le **FNE** (services gratuits) inscrit les demandeurs d''emploi, les met en relation avec des employeurs et propose des programmes comme les stages pour jeunes diplômés et l''appui à l''auto-emploi.', 'Oui. Le **FNE** (services gratuits) inscrit les demandeurs d''emploi, les met en relation avec des employeurs et propose des programmes comme les stages pour jeunes diplômés et l''appui à l''auto-emploi.

- Rends-toi dans une agence du FNE avec ton CV et tes diplômes.
- Prépare un projet clair si tu veux un financement d''auto-emploi.', ARRAY[]::text[], ARRAY[]::text[], ARRAY['fne', 'chômage', 'diplômé', 'stage', 'emploi']::text[], '[{"titre":"Fonds National de l''Emploi (FNE) — emploi, stages, auto-emploi (services gratuits)","url":"https://fnecm.org"},{"titre":"Ministère de l''Emploi et de la Formation Professionnelle (MINEFOP) — centres agréés, examens, bourses","url":"https://www.minefop.gov.cm"}]'::jsonb),
('faq-cv-camerounais', 'faq', 'Comment rédiger un bon CV ?', 'Métiers & emploi', NULL, 'Un bon CV tient sur **une page** : coordonnées, objectif, formation, expériences (stages, bénévolat), compétences (langues, informatique) et centres d''intérêt utiles.', 'Un bon CV tient sur **une page** : coordonnées, objectif, formation, expériences (stages, bénévolat), compétences (langues, informatique) et centres d''intérêt utiles.

- Adapte ton CV à chaque offre.
- Vérifie l''orthographe et utilise une adresse e-mail sérieuse.
- Ajoute tes projets concrets (même scolaires).', ARRAY[]::text[], ARRAY[]::text[], ARRAY['cv', 'curriculum vitae', 'candidature', 'emploi']::text[], '[{"titre":"Fonds National de l''Emploi (FNE) — emploi, stages, auto-emploi (services gratuits)","url":"https://fnecm.org"}]'::jsonb),
('faq-entretien-embauche', 'faq', 'Comment réussir un entretien d''embauche ?', 'Métiers & emploi', NULL, 'Renseigne-toi sur l''entreprise, prépare des exemples concrets de ce que tu as fait, sois ponctuel et habillé proprement.', 'Renseigne-toi sur l''entreprise, prépare des exemples concrets de ce que tu as fait, sois ponctuel et habillé proprement.

- Entraîne-toi à te présenter en 2 minutes.
- Prépare 2 ou 3 questions à poser.
- Envoie un message de remerciement après l''entretien.', ARRAY[]::text[], ARRAY[]::text[], ARRAY['entretien', 'embauche', 'recrutement', 'emploi']::text[], '[{"titre":"Fonds National de l''Emploi (FNE) — emploi, stages, auto-emploi (services gratuits)","url":"https://fnecm.org"}]'::jsonb),
('faq-auto-emploi-financement', 'faq', 'Comment financer mon projet d''auto-emploi ?', 'Métiers & emploi', NULL, 'Commence avec une épargne personnelle, puis renseigne-toi sur les programmes d''appui (FNE, programmes publics pour les jeunes) et sur la microfinance.', 'Commence avec une épargne personnelle, puis renseigne-toi sur les programmes d''appui (FNE, programmes publics pour les jeunes) et sur la microfinance.

- Prépare un plan d''affaires simple : produit, clients, coûts, prix de vente.
- Tiens ta comptabilité dès le début.
- Méfie-toi des « financements garantis » contre paiement.', ARRAY[]::text[], ARRAY[]::text[], ARRAY['financement', 'auto-emploi', 'crédit', 'microfinance', 'projet']::text[], '[{"titre":"Fonds National de l''Emploi (FNE) — emploi, stages, auto-emploi (services gratuits)","url":"https://fnecm.org"},{"titre":"Ministère de la Jeunesse et de l''Éducation Civique (MINJEC) — insertion des jeunes","url":"https://www.minjec.gov.cm"}]'::jsonb),
('faq-service-civique', 'faq', 'Qu''est-ce que le Service civique national de participation au développement ?', 'Métiers & emploi', NULL, 'C''est un dispositif placé sous la tutelle du **MINJEC** qui permet aux jeunes de s''engager au service de la communauté et de se former.', 'C''est un dispositif placé sous la tutelle du **MINJEC** qui permet aux jeunes de s''engager au service de la communauté et de se former.

- Renseigne-toi auprès des délégations du ministère de la Jeunesse.', ARRAY[]::text[], ARRAY[]::text[], ARRAY['service civique', 'volontariat', 'jeunes', 'minjec']::text[], '[{"titre":"Ministère de la Jeunesse et de l''Éducation Civique (MINJEC) — insertion des jeunes","url":"https://www.minjec.gov.cm"}]'::jsonb),
('faq-devenir-instituteur', 'faq', 'Comment devenir instituteur au Cameroun ?', 'Concours', NULL, 'Par le **concours d''entrée dans les Écoles Normales d''Instituteurs** (ENIEG pour l''enseignement général, ENIET pour l''enseignement technique). Les instituteurs travaillent ensuite dans les écoles maternelles et primaires.', 'Par le **concours d''entrée dans les Écoles Normales d''Instituteurs** (ENIEG pour l''enseignement général, ENIET pour l''enseignement technique). Les instituteurs travaillent ensuite dans les écoles maternelles et primaires.

- Le niveau d''entrée dépend du cycle (BEPC, Probatoire ou Baccalauréat).
- Les dates, les frais et le nombre de places changent chaque année : seul le **communiqué officiel** fait foi.', ARRAY[]::text[], ARRAY[]::text[], ARRAY['instituteur', 'enieg', 'eniet', 'primaire', 'maternelle']::text[], '[{"titre":"Ministère des Enseignements Secondaires (MINESEC)","url":"https://www.minesec.gov.cm"},{"titre":"Ministère de l''Éducation de Base (MINEDUB) — maternelle et primaire","url":"https://www.minedub.cm"}]'::jsonb),
('faq-concours-agriculture', 'faq', 'Comment entrer dans une école d''agriculture ?', 'Concours', NULL, 'Le **MINADER** organise chaque année les concours d''entrée dans ses écoles de formation agricole ; la **FASA** (Dschang) forme les ingénieurs agronomes sur concours du MINESUP.', 'Le **MINADER** organise chaque année les concours d''entrée dans ses écoles de formation agricole ; la **FASA** (Dschang) forme les ingénieurs agronomes sur concours du MINESUP.

- Les séries D et C sont les plus adaptées.
- Les dates, les frais et le nombre de places changent chaque année : seul le **communiqué officiel** fait foi.', ARRAY[]::text[], ARRAY[]::text[], ARRAY['école d''agriculture', 'concours agriculture', 'minader', 'fasa']::text[], '[{"titre":"Ministère de l''Agriculture et du Développement Rural (MINADER) — écoles d''agriculture","url":"https://www.minader.cm"},{"titre":"Faculté d''Agronomie et des Sciences Agricoles (FASA), Université de Dschang","url":"https://www.univ-dschang.org/fasa/"},{"titre":"Ministère de l''Enseignement Supérieur (MINESUP) — concours, BTS/HND, établissements","url":"https://www.minesup.gov.cm"}]'::jsonb),
('faq-concours-forets', 'faq', 'Comment travailler dans la protection des forêts et de la faune ?', 'Concours', NULL, 'Par les écoles sous tutelle du **MINFOF** (ENEF de Mbalmayo, École de Faune de Garoua) ou par la **FASA** pour le niveau ingénieur.', 'Par les écoles sous tutelle du **MINFOF** (ENEF de Mbalmayo, École de Faune de Garoua) ou par la **FASA** pour le niveau ingénieur.

- Les concours sont publiés par les ministères concernés.
- Les dates, les frais et le nombre de places changent chaque année : seul le **communiqué officiel** fait foi.', ARRAY[]::text[], ARRAY[]::text[], ARRAY['forêts', 'faune', 'enef', 'mbalmayo', 'école de faune', 'garoua']::text[], '[{"titre":"Ministère des Forêts et de la Faune (MINFOF) — ENEF Mbalmayo, École de Faune de Garoua","url":"https://www.minfof.gov.cm"},{"titre":"Faculté d''Agronomie et des Sciences Agricoles (FASA), Université de Dschang","url":"https://www.univ-dschang.org/fasa/"}]'::jsonb),
('faq-concours-elevage', 'faq', 'Comment se former à l''élevage et à la pêche ?', 'Concours', NULL, 'Le **MINEPIA** dispose de centres nationaux de formation zootechnique et vétérinaire ; l''**ESMV** (Ngaoundéré) forme les vétérinaires.', 'Le **MINEPIA** dispose de centres nationaux de formation zootechnique et vétérinaire ; l''**ESMV** (Ngaoundéré) forme les vétérinaires.

- Des formations courtes existent aussi pour l''aviculture et la pisciculture.
- Les dates, les frais et le nombre de places changent chaque année : seul le **communiqué officiel** fait foi.', ARRAY[]::text[], ARRAY[]::text[], ARRAY['élevage', 'zootechnie', 'pêche', 'minepia', 'vétérinaire']::text[], '[{"titre":"Ministère de l''Élevage, des Pêches et des Industries Animales (MINEPIA)","url":"https://minepia.cm"},{"titre":"École des Sciences et de Médecine Vétérinaire (ESMV), Université de Ngaoundéré","url":"https://esmv.univ-ndere.cm"}]'::jsonb),
('faq-concours-issea', 'faq', 'Comment entrer à l''ISSEA ?', 'Concours', NULL, 'Par **concours** : les cycles ISE et AS ont des concours communs avec d''autres écoles africaines de statistique ; le cycle TSS a son propre concours.', 'Par **concours** : les cycles ISE et AS ont des concours communs avec d''autres écoles africaines de statistique ; le cycle TSS a son propre concours.

- Les inscriptions ferment souvent en début d''année : surveille le site de l''ISSEA dès la rentrée.
- Excellent niveau en maths exigé.
- Les dates, les frais et le nombre de places changent chaque année : seul le **communiqué officiel** fait foi.', ARRAY[]::text[], ARRAY[]::text[], ARRAY['issea', 'statistique', 'concours', 'cemac']::text[], '[{"titre":"Institut Sous-régional de Statistique et d''Économie Appliquée (ISSEA, Yaoundé — CEMAC)","url":"https://www.issea-cemac.org"}]'::jsonb),
('faq-concours-essec', 'faq', 'Comment entrer à l''ESSEC de Douala ?', 'Concours', NULL, 'Par **concours** : le cycle ESC après le Bac ou le A Level, le cycle EPA après une licence. L''inscription se fait avec un formulaire, des frais et un dossier, puis en ligne.', 'Par **concours** : le cycle ESC après le Bac ou le A Level, le cycle EPA après une licence. L''inscription se fait avec un formulaire, des frais et un dossier, puis en ligne.

- Plusieurs centres d''examen existent (Douala, Yaoundé et d''autres villes).
- Les dates, les frais et le nombre de places changent chaque année : seul le **communiqué officiel** fait foi.', ARRAY[]::text[], ARRAY[]::text[], ARRAY['essec', 'concours essec', 'commerce', 'douala']::text[], '[{"titre":"ESSEC — École Supérieure des Sciences Économiques et Commerciales, Université de Douala","url":"https://essec-douala.cm"},{"titre":"Ministère de l''Enseignement Supérieur (MINESUP) — concours, BTS/HND, établissements","url":"https://www.minesup.gov.cm"}]'::jsonb),
('faq-concours-enspy', 'faq', 'Comment s''inscrire au concours de l''ENSP de Yaoundé ?', 'Concours', NULL, 'L''inscription se fait en ligne sur la **plateforme de concours de l''ENSPY**, puis le dossier est déposé ; les épreuves écrites ont lieu dans plusieurs villes.', 'L''inscription se fait en ligne sur la **plateforme de concours de l''ENSPY**, puis le dossier est déposé ; les épreuves écrites ont lieu dans plusieurs villes.

- Entrées en 1re année (après le Bac) et en 3e année (après une licence ou équivalent).
- Les dates, les frais et le nombre de places changent chaque année : seul le **communiqué officiel** fait foi.', ARRAY[]::text[], ARRAY[]::text[], ARRAY['enspy', 'ensp', 'polytechnique', 'inscription', 'concours']::text[], '[{"titre":"École Nationale Supérieure Polytechnique de Yaoundé (ENSPY) — concours","url":"https://polytechnique.cm"},{"titre":"Ministère de l''Enseignement Supérieur (MINESUP) — concours, BTS/HND, établissements","url":"https://www.minesup.gov.cm"}]'::jsonb),
('faq-concours-dgsn-paiement', 'faq', 'Comment se passe l''inscription aux concours de la police ?', 'Concours', NULL, 'La **DGSN** publie les arrêtés et communiqués de ses concours sur son site officiel, avec les conditions (âge, diplôme, pièces) et la procédure d''inscription et de paiement.', 'La **DGSN** publie les arrêtés et communiqués de ses concours sur son site officiel, avec les conditions (âge, diplôme, pièces) et la procédure d''inscription et de paiement.

- Suis uniquement la procédure indiquée par la DGSN.
- Les dates, les frais et le nombre de places changent chaque année : seul le **communiqué officiel** fait foi.', ARRAY[]::text[], ARRAY[]::text[], ARRAY['police', 'dgsn', 'inscription', 'concours police']::text[], '[{"titre":"Délégation Générale à la Sûreté Nationale (DGSN) — concours de la police","url":"https://www.dgsn.cm"}]'::jsonb),
('faq-age-limite-concours', 'faq', 'Y a-t-il une limite d''âge pour les concours ?', 'Concours', NULL, 'Oui, beaucoup de concours fixent un **âge maximum** (souvent apprécié au 1er janvier de l''année du concours), qui varie selon l''école et le cycle.', 'Oui, beaucoup de concours fixent un **âge maximum** (souvent apprécié au 1er janvier de l''année du concours), qui varie selon l''école et le cycle.

- Vérifie l''âge limite dans l''arrêté officiel avant de payer les frais.
- Les dates, les frais et le nombre de places changent chaque année : seul le **communiqué officiel** fait foi.', ARRAY[]::text[], ARRAY[]::text[], ARRAY['âge limite', 'âge', 'conditions', 'concours']::text[], '[{"titre":"Ministère de l''Enseignement Supérieur (MINESUP) — concours, BTS/HND, établissements","url":"https://www.minesup.gov.cm"},{"titre":"École Nationale d''Administration et de Magistrature (ENAM)","url":"https://www.enam.cm"},{"titre":"Délégation Générale à la Sûreté Nationale (DGSN) — concours de la police","url":"https://www.dgsn.cm"}]'::jsonb),
('faq-plusieurs-concours', 'faq', 'Puis-je présenter plusieurs concours la même année ?', 'Concours', NULL, 'Oui, et c''est même conseillé pour multiplier tes chances, à condition que les dates d''épreuves ne se chevauchent pas et que tu puisses payer les frais.', 'Oui, et c''est même conseillé pour multiplier tes chances, à condition que les dates d''épreuves ne se chevauchent pas et que tu puisses payer les frais.

- Fais un calendrier de tous les concours qui t''intéressent.
- Garde un plan B (BTS/HND, faculté) pour ne pas perdre d''année.', ARRAY[]::text[], ARRAY[]::text[], ARRAY['plusieurs concours', 'plan b', 'chances', 'calendrier']::text[], '[{"titre":"Ministère de l''Enseignement Supérieur (MINESUP) — concours, BTS/HND, établissements","url":"https://www.minesup.gov.cm"}]'::jsonb),
('faq-pieces-dossier', 'faq', 'Quelles pièces prépare-t-on souvent pour un dossier de concours ?', 'Concours', NULL, 'Souvent : demande manuscrite ou formulaire, **acte de naissance**, copies certifiées des diplômes, photos d''identité, certificat médical, reçu de paiement des frais.', 'Souvent : demande manuscrite ou formulaire, **acte de naissance**, copies certifiées des diplômes, photos d''identité, certificat médical, reçu de paiement des frais.

- La liste exacte est toujours dans l''arrêté du concours.
- Prépare les copies certifiées à l''avance.
- Les dates, les frais et le nombre de places changent chaque année : seul le **communiqué officiel** fait foi.', ARRAY[]::text[], ARRAY[]::text[], ARRAY['dossier', 'pièces', 'acte de naissance', 'certificat médical', 'concours']::text[], '[{"titre":"Ministère de l''Enseignement Supérieur (MINESUP) — concours, BTS/HND, établissements","url":"https://www.minesup.gov.cm"},{"titre":"École Nationale d''Administration et de Magistrature (ENAM)","url":"https://www.enam.cm"}]'::jsonb),
('faq-handicap-etudes', 'faq', 'Je suis en situation de handicap : puis-je faire des études supérieures ?', 'Université', NULL, 'Oui. Signale ta situation à l''établissement dès l''inscription et aux examens pour demander des aménagements (accès aux salles, temps supplémentaire, documents adaptés).', 'Oui. Signale ta situation à l''établissement dès l''inscription et aux examens pour demander des aménagements (accès aux salles, temps supplémentaire, documents adaptés).

- Le service social de l''université peut t''accompagner.
- Choisis une filière selon tes talents : beaucoup de métiers sont accessibles.', ARRAY[]::text[], ARRAY[]::text[], ARRAY['handicap', 'aménagement', 'inclusion', 'études']::text[], '[{"titre":"Ministère de l''Enseignement Supérieur (MINESUP) — concours, BTS/HND, établissements","url":"https://www.minesup.gov.cm"}]'::jsonb),
('faq-filles-sciences', 'faq', 'Les filles peuvent-elles réussir dans les sciences et l''ingénierie ?', 'Choisir sa série', NULL, '**Absolument.** Les filles réussissent aussi bien que les garçons en sciences ; les écoles d''ingénieurs, de médecine et le numérique ont besoin de plus de femmes.', '**Absolument.** Les filles réussissent aussi bien que les garçons en sciences ; les écoles d''ingénieurs, de médecine et le numérique ont besoin de plus de femmes.

- Choisis ta série selon tes résultats et tes envies, pas selon les préjugés.
- Inspire-toi de femmes ingénieures, médecins et entrepreneures camerounaises.', ARRAY[]::text[], ARRAY[]::text[], ARRAY['filles', 'femmes', 'sciences', 'ingénieure', 'égalité']::text[], '[{"titre":"Ministère des Enseignements Secondaires (MINESEC)","url":"https://www.minesec.gov.cm"},{"titre":"Ministère de l''Enseignement Supérieur (MINESUP) — concours, BTS/HND, établissements","url":"https://www.minesup.gov.cm"}]'::jsonb),
('faq-deplaces-scolarite', 'faq', 'Je suis déplacé(e) interne : comment poursuivre ma scolarité ?', 'Méthode de travail', NULL, 'Rapproche-toi de l''établissement public le plus proche et du conseiller d''orientation : des mesures d''accueil existent pour les élèves déplacés, et tu peux aussi te présenter aux examens comme candidat libre.', 'Rapproche-toi de l''établissement public le plus proche et du conseiller d''orientation : des mesures d''accueil existent pour les élèves déplacés, et tu peux aussi te présenter aux examens comme candidat libre.

- Garde tous tes documents scolaires (bulletins, actes de naissance) ou demande des duplicatas.
- Les ONG éducatives peuvent t''aider (fournitures, soutien scolaire).', ARRAY[]::text[], ARRAY[]::text[], ARRAY['déplacé', 'crise', 'scolarité', 'nord-ouest', 'sud-ouest', 'extrême-nord']::text[], '[{"titre":"Ministère des Enseignements Secondaires (MINESEC)","url":"https://www.minesec.gov.cm"},{"titre":"Conseiller d''orientation de ton établissement (service d''orientation scolaire)"}]'::jsonb),
('faq-perte-diplome', 'faq', 'J''ai perdu mon diplôme du Bac ou du GCE : que faire ?', 'Examens officiels', NULL, 'Adresse-toi à l''organisme qui a délivré le diplôme (**OBC** pour le Bac, **GCE Board** pour le GCE, **MINESEC** pour le BEPC) pour obtenir une attestation ou un duplicata selon la procédure prévue.', 'Adresse-toi à l''organisme qui a délivré le diplôme (**OBC** pour le Bac, **GCE Board** pour le GCE, **MINESEC** pour le BEPC) pour obtenir une attestation ou un duplicata selon la procédure prévue.

- Fais toujours des copies certifiées de tes diplômes et garde-les en lieu sûr.', ARRAY[]::text[], ARRAY[]::text[], ARRAY['perte', 'diplôme perdu', 'duplicata', 'attestation']::text[], '[{"titre":"Office du Baccalauréat du Cameroun (OBC) — Probatoire, Baccalauréat, BT","url":"https://www.obc.cm"},{"titre":"Cameroon GCE Board — GCE O Level / A Level","url":"https://www.camgceb.org"},{"titre":"Ministère des Enseignements Secondaires (MINESEC)","url":"https://www.minesec.gov.cm"}]'::jsonb),
('faq-fraude-examen', 'faq', 'Que risque-t-on en cas de fraude aux examens officiels ?', 'Examens officiels', NULL, 'La fraude (anti-sèches, téléphone, sujets « fuités », substitution de candidat) est sévèrement sanctionnée : annulation de l''examen, exclusion des sessions suivantes et poursuites possibles.', 'La fraude (anti-sèches, téléphone, sujets « fuités », substitution de candidat) est sévèrement sanctionnée : annulation de l''examen, exclusion des sessions suivantes et poursuites possibles.

- Les « sujets fuités » vendus sur les réseaux sociaux sont presque toujours des arnaques.
- La meilleure stratégie reste la préparation régulière.', ARRAY[]::text[], ARRAY[]::text[], ARRAY['fraude', 'tricherie', 'sujets fuités', 'sanction', 'examen']::text[], '[{"titre":"Office du Baccalauréat du Cameroun (OBC) — Probatoire, Baccalauréat, BT","url":"https://www.obc.cm"},{"titre":"Cameroon GCE Board — GCE O Level / A Level","url":"https://www.camgceb.org"},{"titre":"Ministère des Enseignements Secondaires (MINESEC)","url":"https://www.minesec.gov.cm"}]'::jsonb),
('faq-travailler-en-groupe', 'faq', 'Comment bien travailler en groupe ?', 'Méthode de travail', NULL, 'Formez des groupes de 3 à 5 personnes sérieuses, avec un programme précis pour chaque séance et un rôle pour chacun.', 'Formez des groupes de 3 à 5 personnes sérieuses, avec un programme précis pour chaque séance et un rôle pour chacun.

- Chacun prépare avant la séance.
- Expliquez-vous les exercices à tour de rôle.
- Faites des sujets en temps limité ensemble.', ARRAY[]::text[], ARRAY[]::text[], ARRAY['groupe', 'travail en groupe', 'révision', 'entraide']::text[], '[{"titre":"Conseiller d''orientation de ton établissement (service d''orientation scolaire)"}]'::jsonb),
('faq-telephone-distraction', 'faq', 'Mon téléphone me distrait : comment me concentrer ?', 'Méthode de travail', NULL, 'Éloigne le téléphone pendant tes séances de travail, travaille par blocs de 25 à 45 minutes avec de courtes pauses, et coupe les notifications.', 'Éloigne le téléphone pendant tes séances de travail, travaille par blocs de 25 à 45 minutes avec de courtes pauses, et coupe les notifications.

- Utilise le téléphone comme outil (cours, Mandal IA) plutôt que comme distraction.
- Fixe-toi un objectif précis par séance.', ARRAY[]::text[], ARRAY[]::text[], ARRAY['concentration', 'téléphone', 'réseaux sociaux', 'distraction']::text[], '[{"titre":"Conseiller d''orientation de ton établissement (service d''orientation scolaire)"}]'::jsonb),
('faq-programme-revision', 'faq', 'Comment faire un planning de révision ?', 'Méthode de travail', NULL, 'Liste toutes les matières et chapitres, estime le temps nécessaire, puis répartis-les sur les semaines restantes en commençant par les matières à fort coefficient et les chapitres faibles.', 'Liste toutes les matières et chapitres, estime le temps nécessaire, puis répartis-les sur les semaines restantes en commençant par les matières à fort coefficient et les chapitres faibles.

- Garde un jour par semaine pour les sujets d''examen complets.
- Prévois du temps libre et du sommeil.
- Ajuste ton planning chaque semaine.', ARRAY[]::text[], ARRAY[]::text[], ARRAY['planning', 'programme', 'révision', 'organisation']::text[], '[{"titre":"Conseiller d''orientation de ton établissement (service d''orientation scolaire)"}]'::jsonb),
('faq-lire-sujet', 'faq', 'Comment bien lire un sujet d''examen ?', 'Méthode de travail', NULL, 'Lis tout le sujet avant de commencer, souligne les mots-clés et les consignes (« justifier », « calculer », « comparer »), puis commence par les questions que tu maîtrises.', 'Lis tout le sujet avant de commencer, souligne les mots-clés et les consignes (« justifier », « calculer », « comparer »), puis commence par les questions que tu maîtrises.

- Gère ton temps selon le barème.
- Garde 10 minutes pour te relire.', ARRAY[]::text[], ARRAY[]::text[], ARRAY['sujet', 'examen', 'consigne', 'méthode']::text[], '[{"titre":"Conseiller d''orientation de ton établissement (service d''orientation scolaire)"}]'::jsonb),
('faq-dissertation', 'faq', 'Comment réussir une dissertation ?', 'Méthode de travail', NULL, 'Analyse le sujet, formule une problématique, construis un plan en 2 ou 3 parties avec des arguments et des exemples, puis rédige une introduction et une conclusion soignées.', 'Analyse le sujet, formule une problématique, construis un plan en 2 ou 3 parties avec des arguments et des exemples, puis rédige une introduction et une conclusion soignées.

- Entraîne-toi à faire des plans détaillés en 30 minutes.
- Utilise des exemples précis (auteurs, faits, actualité camerounaise et africaine).', ARRAY[]::text[], ARRAY[]::text[], ARRAY['dissertation', 'plan', 'problématique', 'philosophie', 'français']::text[], '[{"titre":"Conseiller d''orientation de ton établissement (service d''orientation scolaire)"}]'::jsonb),
('faq-etudier-sans-internet', 'faq', 'Comment étudier quand on a peu d''Internet ?', 'Méthode de travail', NULL, 'Télécharge cours et annales quand tu as une connexion, utilise les bibliothèques de ton école et de ta ville, et travaille en groupe pour partager les ressources.', 'Télécharge cours et annales quand tu as une connexion, utilise les bibliothèques de ton école et de ta ville, et travaille en groupe pour partager les ressources.

- Une connexion courte suffit pour poser une question précise à Mandal IA.
- Les manuels au programme restent la base.', ARRAY[]::text[], ARRAY[]::text[], ARRAY['internet', 'connexion', 'données mobiles', 'bibliothèque']::text[], '[{"titre":"Conseiller d''orientation de ton établissement (service d''orientation scolaire)"}]'::jsonb)
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
