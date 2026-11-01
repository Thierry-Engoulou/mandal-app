-- ---------------------------------------------------------------------------
-- M'Andal — Philosophie, classes de Terminale
-- Chapitre 3 : Consolidation des acquis de la méthodologie de l'exercice sur texte philosophique
-- Module 1 : La philosophie — 11 leçons
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
DO $philo$
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
  -- La matière Philosophie : on ne la crée qu'une fois pour toutes.
  INSERT INTO public.matieres (nom) VALUES ('Philosophie') ON CONFLICT (nom) DO NOTHING;
  SELECT id INTO v_matiere_id FROM public.matieres WHERE nom = 'Philosophie';

  -- L'établissement, on le retrouve à partir des classes déjà en base.
  SELECT count(DISTINCT etablissement_id) INTO v_nb_etabs FROM public.classes;
  IF v_nb_etabs <> 1 THEN
    RAISE EXCEPTION 'Je ne sais pas à quel établissement rattacher ces classes : j''en trouve % dans la table des classes, et il m''en faudrait exactement un.', v_nb_etabs;
  END IF;
  SELECT etablissement_id INTO v_etab_id FROM public.classes LIMIT 1;

  -- On refait le même travail deux fois : pour la Terminale C, puis pour la D.
  FOR v_i IN 1..2 LOOP
    v_lettre := v_lettres[v_i];
    v_nom := 'Terminale ' || v_lettre;

    -- Le programme de Philosophie de cette série existe-t-il déjà ?
    SELECT p.id INTO v_programme_id FROM public.programmes p
    WHERE p.titre = 'Philosophie — ' || v_nom;

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
      VALUES (v_matiere_id, v_classe_id, v_etab_id, 'Philosophie — ' || v_nom,
              'Programme officiel de Philosophie, classe de Terminale ' || v_lettre ||
              ' (Cameroun) — 1 module, 13 chapitres.')
      RETURNING id INTO v_programme_id;
      RAISE NOTICE 'Programme de Philosophie de la % : créé.', v_nom;
    END IF;

    -- Le chapitre lui-même.
    SELECT id INTO v_chapitre_id FROM public.chapitres
    WHERE programme_id = v_programme_id AND ordre = 3;

    IF v_chapitre_id IS NULL THEN
      INSERT INTO public.chapitres (programme_id, titre, ordre, niveau)
      VALUES (v_programme_id, 'Consolidation des acquis de la méthodologie de l''exercice sur texte philosophique', 3, 'Module 1 : La philosophie')
      RETURNING id INTO v_chapitre_id;
      RAISE NOTICE '% : chapitre 3 créé.', v_nom;
    END IF;

    -- Les leçons. Si le chapitre en a déjà, on passe son tour sans rien toucher.
    SELECT count(*) INTO v_deja FROM public.concepts WHERE chapitre_id = v_chapitre_id;
    IF v_deja > 0 THEN
      RAISE NOTICE '% : le chapitre 3 a déjà ses % leçons, je n''y touche pas.', v_nom, v_deja;
      CONTINUE;
    END IF;

    INSERT INTO public.concepts
      (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes) VALUES
      (v_chapitre_id, 'L''exercice sur texte : quatre tâches, neuf points', 1, 'texte', '
Neuf points sur vingt, c''est-à-dire autant que la dissertation. Et pourtant
c''est la partie que l''on travaille le moins.

Une enseignante camerounaise le dit : les élèves préfèrent le texte parce
qu''ils lisent peu, et ils se trompent — **le texte n''est pas un refuge**. Il
demande la même culture philosophique, les mêmes auteurs, les mêmes concepts.

### Les quatre tâches

Elles reviennent à chaque session, dans le même ordre, avec les mêmes mots.

**A1 — Définir trois concepts.** 3 points, un par définition. Les trois mots
sont tirés du texte.

**A2.1 — Présenter le thème et le problème philosophique du texte.** 2 points.

**A2.2 — Dégager la thèse de l''auteur.** 1 à 2 points selon la session.

**A2.3 — Décliner la structure logique du texte : postulat, arguments,
conclusion.** 2 à 3 points selon la session.

*Le total de A2 fait toujours 6 points ; la répartition interne varie
légèrement d''une année à l''autre.*

### Ce que ces quatre tâches ont en commun

Aucune ne vous demande votre avis.

On ne vous demande pas si l''auteur a raison. On ne vous demande pas ce que vous
pensez du sujet. On vous demande de **restituer** ce que le texte dit, et de
montrer **comment** il le dit.

C''est la différence essentielle avec la dissertation, et c''est la faute la plus
fréquente : le candidat qui commence à discuter l''auteur en première partie
perd ses points et son temps.

### Le travail préalable, avant d''écrire une ligne

**Lire le texte trois fois.** La première pour comprendre de quoi il parle. La
deuxième, crayon en main, pour repérer les articulations — *mais*, *donc*,
*or*, *en effet*, *c''est pourquoi*. La troisième pour vérifier que votre
compréhension tient du début à la fin.

**Repérer les connecteurs**, parce qu''ils dessinent la structure. Un *donc*
annonce une conclusion, un *or* introduit un argument nouveau, un *mais* marque
une objection que l''auteur se fait à lui-même.

**Chercher la phrase qui porte la thèse.** Elle est souvent au début ou à la
fin. Dans un texte bien construit, elle est aux deux.

### L''erreur à ne pas commettre

Ne jamais paraphraser. **Paraphraser, c''est redire le texte avec d''autres
mots** ; expliquer, c''est dire ce qu''il fait, pourquoi il le fait, et contre
qui.

Le test est simple : si quelqu''un qui n''a pas lu le texte peut comprendre votre
réponse, vous avez expliqué. S''il faut avoir le texte sous les yeux pour vous
suivre, vous avez paraphrasé.

---

**Exercice corrigé**

*Un candidat répond à la question « dégage la thèse de l''auteur » par : « Dans
ce texte, l''auteur nous parle de la liberté et de la loi, et il montre que
c''est un sujet très important dans la société d''aujourd''hui. » Combien vaut
cette réponse, et pourquoi ?*

**Correction.**

*Elle vaut zéro.* Trois raisons, et chacune suffirait.

**Elle donne le thème, pas la thèse.** « La liberté et la loi » répond à la
question précédente. La thèse est **ce que l''auteur soutient** à propos de ce
thème : par exemple, qu''il n''y a pas de liberté sans loi.

**Elle est interchangeable.** On pourrait l''écrire devant n''importe quel texte
en changeant deux mots. Une réponse qui convient à tous les textes ne convient
à aucun.

**Elle ajoute un jugement non demandé.** « Un sujet très important dans la
société d''aujourd''hui » n''est ni dans le texte ni dans la question.

*La réponse attendue.* Une **phrase affirmative**, au présent, qui énonce la
position de l''auteur : « Rousseau soutient qu''il n''y a pas de liberté sans
loi : loin de s''opposer à la liberté, la loi en est le fondement. »

*Le repère : une thèse se reconnaît à ce qu''on peut la contredire. Si personne
ne peut être en désaccord avec votre phrase, ce n''est pas une thèse.*
', NULL, 28),
      (v_chapitre_id, 'Simulation : les quatre tâches et leurs points', 2, 'interactif', '{
  "widget": "quatre-taches-texte",
  "consigne": "Les quatre tâches de la première partie s''affichent, et pour chacune on te propose trois réponses : la bonne, une paraphrase et un hors-sujet. Tu choisis, la simulation note comme le ferait un correcteur et t''explique le retrait. Un second volet te donne une réponse et te demande à quelle tâche elle répond — c''est le meilleur entraînement contre la confusion entre le thème, le problème et la thèse."
}', NULL, 10),
      (v_chapitre_id, 'Définir les concepts : la tâche A1', 3, 'texte', '
Trois points, et ils sont les plus faciles de l''épreuve. Encore faut-il savoir
ce qu''est une définition.

### Ce qu''une définition doit contenir

**Le genre prochain** : la catégorie à laquelle la chose appartient.

**La différence spécifique** : ce qui la distingue des autres membres de cette
catégorie.

« La loi est une **règle** — genre — **édictée par une autorité souveraine,
obligatoire pour tous et assortie d''une contrainte** — différence. »

C''est la définition classique, celle d''Aristote, et le correcteur la reconnaît
immédiatement.

### Trois exemples tirés d''une session réelle

Voici les trois définitions attendues à la session 2021, pour les concepts de
liberté, de gouvernement et de loi.

**La liberté** : possibilité, garantie par les lois ou par le système politique
et social, d''agir selon sa volonté sans porter atteinte aux droits d''autrui ni
à la sécurité publique.

**Le gouvernement** : ensemble des organes par lesquels le souverain exerce son
autorité dans l''État ; ou la personne morale détentrice du pouvoir politique.

**La loi** : règle édictée par une autorité souveraine, obligatoire pour tous
et assortie d''une contrainte. André Lalande en donne cette formule : une règle
générale qui régit l''activité humaine **de l''extérieur**.

Remarquez trois choses. Chaque définition tient en une phrase. Chacune suit le
schéma genre + différence. Et la dernière cite un auteur de référence — Lalande,
dont le *Vocabulaire technique et critique de la philosophie* est l''ouvrage
qu''on cite pour les définitions.

### Les quatre fautes qui coûtent le point

**Le cercle.** « La liberté, c''est le fait d''être libre. » On a défini le mot
par lui-même.

**La définition par l''exemple.** « La loi, c''est par exemple le code de la
route. » Un exemple illustre, il ne définit pas.

**La définition trop large.** « La loi est une règle. » Vrai, mais la règle du
jeu de dames en est une aussi. Il manque la différence spécifique.

**La définition par la négation seule.** « La liberté, c''est l''absence de
contrainte. » Elle n''est pas fausse, mais elle ne dit pas ce que la liberté
**est**, et elle ne permet pas de comprendre la thèse de Rousseau, pour qui la
loi fonde la liberté au lieu de la supprimer.

### Le conseil qui fait gagner le point

Définir le concept **tel que le texte l''emploie**. Si Rousseau soutient que la
loi fonde la liberté, définir la liberté comme « l''absence de toute contrainte »
rend le texte incompréhensible, et le correcteur le voit.

Une définition de dictionnaire rapporte un demi-point. Une définition qui
éclaire le texte les rapporte tous.

---

**Exercice corrigé**

*Définir les concepts de « conscience », d''« inconscient » et de
« responsabilité », en une phrase chacun, selon le schéma genre prochain +
différence spécifique.*

**Correction.**

**La conscience** : *faculté* — genre — *par laquelle le sujet se saisit
immédiatement lui-même et saisit le monde qui l''entoure* — différence. André
Lalande en donne cette formule : « l''intuition plus ou moins claire que le sujet
a de soi et de ses actes ».

**L''inconscient** : *ensemble des contenus psychiques* — genre — *qui échappent
à la conscience tout en continuant d''agir sur la conduite du sujet* —
différence.

*Attention à la distinction : l''inconscient au sens de Freud est une
**instance**, pas simplement ce qu''on ignore. Le mot a un sens adjectif — ce
qui n''est pas conscient — et un sens substantif — le système mis au jour par la
psychanalyse. Le préciser rapporte le point entier.*

**La responsabilité** : *capacité* — genre — *à répondre de ses actes, c''est-à-dire
à en assumer les conséquences devant soi-même et devant autrui* — différence.

*Remarquez que les trois définitions forment un système : la responsabilité
suppose la conscience, et l''inconscient est ce qui menace de la dissoudre.
C''est ce lien qu''il faut faire apparaître, car il porte tout le texte.*
', NULL, 28),
      (v_chapitre_id, 'Simulation : définir un concept', 4, 'interactif', '{
  "widget": "definir-concept",
  "consigne": "Un concept s''affiche avec cinq définitions candidates : la bonne, un cercle vicieux, une définition par l''exemple, une trop large et une qui contredit le texte. Tu choisis, et la simulation nomme la faute. Tu construis ensuite tes propres définitions en assemblant un genre prochain et une différence spécifique, et elle te signale quand le genre est trop vaste ou la différence absente."
}', NULL, 10),
      (v_chapitre_id, 'Thème, problème, thèse : trois questions, trois réponses', 5, 'texte', '
Ces trois tâches sont confondues par la moitié des candidats, et la confusion
coûte quatre points sur neuf.

### Le thème

**Ce dont le texte parle.** Un groupe nominal, trois ou quatre mots.

« Le rapport entre la liberté et la loi. » « La liberté et la responsabilité
humaines chez Sartre. » « L''observation scientifique. »

Le thème n''est pas une phrase. Si vous écrivez un verbe conjugué, vous êtes
déjà dans le problème ou dans la thèse.

### Le problème

**La difficulté que le thème soulève.** Un groupe nominal avec un complément,
ou une question.

« Le fondement de la liberté. » « La nature de la liberté et de la
responsabilité de l''homme. » « La nature du psychisme humain. »

Le problème n''est pas une opinion : c''est une **question ouverte** à laquelle
plusieurs réponses sont possibles, et le texte en défend une.

Le repère : si le texte n''avait pas été écrit, la question se poserait encore.
C''est cela, un problème.

### La thèse

**La réponse que l''auteur donne au problème.** Une phrase affirmative, au
présent.

« Rousseau soutient qu''il n''y a pas de liberté sans loi : la loi est le
fondement de la liberté, et les deux sont indissociables. »

« Pour Sartre, la liberté et la responsabilité humaines sont absolues ; la
liberté fonde la responsabilité, et les deux sont indissociables. »

Deux exigences. Elle doit être **attribuée** : « l''auteur soutient que… ». Et
elle doit être **contredisable** : si personne ne peut être en désaccord, ce
n''est pas une thèse.

### Le tableau qui évite la confusion

| | Forme | Exemple |
| --- | --- | --- |
| **Thème** | un groupe nominal | la liberté et la loi |
| **Problème** | un nom + complément, ou une question | le fondement de la liberté |
| **Thèse** | une phrase affirmative attribuée | Rousseau soutient qu''il n''y a pas de liberté sans loi |

### La méthode en trois questions

Pour le thème : **de quoi ça parle ?**

Pour le problème : **qu''est-ce qui fait difficulté là-dedans ?**

Pour la thèse : **qu''est-ce que l''auteur répond ?**

Posez-les dans cet ordre, et notez chaque réponse sur votre brouillon avant de
rédiger. Vous ne les confondrez plus.

---

**Exercice corrigé**

*Un texte de Bachelard, extrait de l''introduction du* Nouvel Esprit scientifique
*(PUF, 1934), s''ouvre par : « L''observation scientifique est toujours une
observation polémique. » L''auteur y montre que l''observation scientifique ne se
contente jamais de regarder : elle conteste, elle instruit un procès, et elle
construit son objet au lieu de l''enregistrer.*

*Donner le thème, le problème et la thèse de ce texte.*

**Correction.**

**Le thème.** La nature de l''observation scientifique.

*Trois ou quatre mots, un groupe nominal, aucun verbe conjugué.*

**Le problème.** Le rapport entre l''observation et la construction de l''objet
scientifique. On peut aussi formuler : la science se contente-t-elle
d''enregistrer les faits, ou les construit-elle ?

*Remarquez que la question se poserait même sans ce texte : c''est le signe
qu''on tient bien un problème, et non un résumé.*

**La thèse.** Bachelard soutient que l''observation scientifique n''est jamais
neutre ni passive : elle est polémique, c''est-à-dire qu''elle conteste les
apparences et construit son objet contre l''évidence immédiate.

*Vérification.* La phrase est **attribuée** à Bachelard, elle est
**affirmative**, et elle est **contredisable** — l''empirisme classique soutient
exactement le contraire, à savoir que le savant observe d''abord et interprète
ensuite. C''est donc bien une thèse.

*Sujet de la session 2023, séries C, D, E et TI. La question A1 demandait de
définir « observation polémique », « expérimentation » et « science ».*
', NULL, 30),
      (v_chapitre_id, 'Simulation : thème, problème ou thèse ?', 6, 'interactif', '{
  "widget": "theme-probleme-these",
  "consigne": "Des réponses de candidats défilent et tu dois dire à quelle question chacune répond : le thème, le problème, la thèse, ou rien du tout. La simulation applique les trois repères du cours — un groupe nominal, une difficulté, une phrase attribuée et contredisable — et te montre pourquoi une thèse que personne ne peut contredire n''en est pas une. Tu rédiges ensuite les trois réponses pour quatre textes de sessions récentes."
}', NULL, 10),
      (v_chapitre_id, 'La structure logique : postulat, arguments, conclusion', 7, 'texte', '
Deux à trois points, et c''est la tâche la plus redoutée. À tort : elle obéit à
un schéma fixe, et l''énoncé le donne lui-même entre parenthèses —
« postulat-arguments-conclusion ».

### Les trois éléments

**Le postulat.** Ce que l''auteur **pose au départ sans le démontrer**. C''est son
point d''appui. Il se trouve presque toujours dans la première phrase, et il
commence souvent par une affirmation tranchée.

**Les arguments.** Les raisons qui soutiennent le postulat, dans l''ordre où
l''auteur les donne. Ce sont les **moments** du texte, et on en compte deux,
trois, rarement plus.

**La conclusion.** Ce que l''auteur établit au terme de sa marche. Elle est
souvent dans la dernière phrase, et elle reprend le postulat enrichi de tout le
chemin.

### Comment les repérer

Suivez les **connecteurs**. Un *en effet* introduit un argument. Un *or*
introduit un fait nouveau. Un *donc* ou un *c''est pourquoi* annonce une
conclusion. Un *mais* marque une objection que l''auteur se fait à lui-même pour
y répondre.

Et comptez les **paragraphes** : dans un texte bien construit, un paragraphe
égale un moment.

### La rédaction : un seul paragraphe

Le corrigé national est explicite : la structure logique se rédige **en un seul
paragraphe**, pas en liste à puces.

La formule attendue ressemble à ceci.

*« L''auteur part du postulat selon lequel… Il l''établit d''abord en montrant
que… Il poursuit en soulignant que… Il conclut enfin que… »*

Quatre articulations, quatre phrases, et le point est acquis.

### Un exemple complet

Prenons le texte de **Rousseau** donné au Baccalauréat 2021, séries D et TI :
un extrait de la VIIIe des *Lettres écrites de la montagne* (1764), qui s''ouvre
par « Il n''y a donc point de liberté sans lois, ni où quelqu''un est au-dessus
des lois », et se referme sur « Un peuple est libre, quelque forme qu''ait son
gouvernement, quand dans celui qui le gouverne il ne voit point l''homme ».

**Le postulat.** Il n''y a pas de liberté sans loi. Rousseau le pose d''emblée,
sans le démontrer : c''est son point de départ.

**Premier argument.** Il examine le rapport des **individus** à la loi : obéir
à la loi n''est pas obéir à un homme, et c''est ce qui distingue la dépendance de
la servitude.

**Deuxième argument.** Il examine le rapport des **lois au pouvoir exécutif** :
le gouvernement lui-même doit être soumis à la loi, sans quoi il n''y a plus de
loi du tout.

**La conclusion.** Un peuple est libre, quelle que soit la forme de son
gouvernement, dès lors qu''il n''obéit qu''à la loi et jamais à un homme.

**La rédaction attendue.** *« Rousseau part du postulat qu''il n''y a point de
liberté sans lois. Il l''établit d''abord en examinant le rapport des individus à
la loi, pour montrer qu''obéir à la loi n''est pas obéir à un homme. Il poursuit
en soumettant le pouvoir exécutif lui-même à la loi, faute de quoi la loi
cesserait d''exister. Il conclut qu''un peuple est libre, quelle que soit la
forme de son gouvernement, dès lors qu''il n''y voit point l''homme. »*

### Les deux pièges

**Confondre la structure logique avec le résumé.** Le résumé dit **ce que**
l''auteur affirme ; la structure dit **comment** il l''établit. Les verbes à
employer sont ceux du mouvement : il pose, il établit, il poursuit, il objecte,
il conclut.

**Oublier le postulat.** Beaucoup de candidats donnent deux arguments et une
conclusion. Le postulat vaut autant que le reste, et il est la première phrase :
c''est le point le plus facile de l''épreuve.

---

**Exercice corrigé**

*Le texte de Sartre donné à la session 2025 pose que l''homme existe avant d''être
défini et n''est déterminé par aucune nature. Il montre ensuite que l''homme est
essentiellement libre et se détermine lui-même, puis que, sans Dieu, il n''y a
ni nature humaine ni destin tracé. Il conclut que la liberté est l''attribut
fondamental qui rend l''homme responsable de ses actes.*

*Rédiger la structure logique de ce texte en un seul paragraphe.*

**Correction.**

*« Sartre part du postulat que l''homme existe avant d''être défini et qu''aucune
nature ne le détermine par avance. Il l''établit d''abord en montrant que l''homme
est essentiellement libre et qu''il se détermine lui-même par ses choix. Il
poursuit en tirant les conséquences de l''absence de Dieu : il n''existe alors ni
nature humaine fixée ni destin tracé, et rien ne vient excuser l''homme. Il
conclut que la liberté est l''attribut fondamental de l''homme, et que c''est elle
qui le rend entièrement responsable de ses actes. »*

*Quatre phrases, quatre articulations : le postulat, deux arguments, la
conclusion. Les verbes sont des verbes de mouvement — il part, il établit, il
poursuit, il conclut — et aucun ne dit ce que le candidat pense du texte.*
', NULL, 32),
      (v_chapitre_id, 'Figure : postulat, arguments, conclusion', 8, 'figure', '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 560 250" width="560" height="250">
<rect width="560" height="250" fill="#ffffff"/>
<text x="280" y="24" text-anchor="middle" font-size="14" font-weight="700" fill="#0f172a">La structure logique d&apos;un texte philosophique</text>
<text x="280" y="42" text-anchor="middle" font-size="10" fill="#64748b">Postulat, arguments, conclusion — et c&apos;est tout.</text>

<rect x="40" y="58" width="480" height="40" rx="5" fill="#dbeafe" stroke="#2563eb" stroke-width="1.6"/>
<text x="54" y="76" font-size="11" font-weight="700" fill="#1e3a8a">LE POSTULAT</text>
<text x="54" y="91" font-size="9" fill="#1e40af">Ce que l&apos;auteur pose au départ sans le démontrer. Souvent la première phrase.</text>

<line x1="280" y1="98" x2="280" y2="114" stroke="#334155" stroke-width="1.6"/>
<polygon points="280,120 275,110 285,110" fill="#334155"/>

<rect x="40" y="120" width="480" height="78" rx="5" fill="#fef3c7" stroke="#ca8a04" stroke-width="1.6"/>
<text x="54" y="138" font-size="11" font-weight="700" fill="#78350f">LES ARGUMENTS</text>
<text x="54" y="153" font-size="9" fill="#92400e">Les raisons qui soutiennent le postulat. Ce sont les MOMENTS du texte.</text>
<rect x="56" y="160" width="140" height="28" rx="3" fill="#ffffff" stroke="#facc15"/>
<text x="126" y="178" text-anchor="middle" font-size="9" fill="#78350f">1er moment</text>
<rect x="210" y="160" width="140" height="28" rx="3" fill="#ffffff" stroke="#facc15"/>
<text x="280" y="178" text-anchor="middle" font-size="9" fill="#78350f">2e moment</text>
<rect x="364" y="160" width="140" height="28" rx="3" fill="#ffffff" stroke="#facc15"/>
<text x="434" y="178" text-anchor="middle" font-size="9" fill="#78350f">3e moment</text>

<line x1="280" y1="198" x2="280" y2="206" stroke="#334155" stroke-width="1.6"/>
<polygon points="280,212 275,202 285,202" fill="#334155"/>

<rect x="40" y="212" width="480" height="30" rx="5" fill="#dcfce7" stroke="#15803d" stroke-width="1.6"/>
<text x="54" y="232" font-size="11" font-weight="700" fill="#14532d">LA CONCLUSION  —  ce que l&apos;auteur établit au terme de sa marche</text>
</svg>', NULL, 5),
      (v_chapitre_id, 'Simulation : dégager la structure d''un texte', 9, 'interactif', '{
  "widget": "structure-texte",
  "consigne": "Un texte s''affiche paragraphe par paragraphe, et tu étiquettes chaque moment : postulat, argument, objection, exemple, conclusion. La simulation éclaire les connecteurs — en effet, or, donc, mais — et te montre comment ils dessinent la marche du texte. Elle refuse qu''un exemple soit pris pour un argument, et c''est la confusion la plus coûteuse de l''exercice. Tu rédiges enfin le paragraphe attendu en assemblant quatre articulations."
}', NULL, 10),
      (v_chapitre_id, 'Sujet type Baccalauréat — Le texte de Bachelard sur l''observation scientifique', 10, 'texte', '
**Première partie de l''épreuve — Évaluation des ressources — 9 points**

*Texte : Gaston Bachelard,* Le Nouvel Esprit scientifique *, introduction,
Presses Universitaires de France, 1934. Le passage s''ouvre par : « L''observation
scientifique est toujours une observation polémique. »*

*A1 — Définis les concepts suivants : observation polémique, expérimentation,
science. (3 points)*

*A2 — 1. Dégage le thème et le problème philosophique du texte. (2 points)
2. Dégage la thèse de l''auteur. (1 point) 3. Dégage la structure logique du
texte : postulat, arguments, conclusion. (3 points)*

*Session 2023, séries C, D, E et TI.*

---
---

## Corrigé

### A1 — Les trois définitions *(3 points, 1 point chacune)*

**L''observation polémique.** Observation qui ne se borne pas à enregistrer ce
qui se présente, mais qui conteste les apparences et instruit un procès contre
l''évidence immédiate. Elle suppose une question posée à la nature, et non un
simple regard.

**L''expérimentation.** Méthode par laquelle le savant provoque un phénomène
dans des conditions qu''il a lui-même définies, afin de contrôler une hypothèse.
Elle se distingue de l''observation ordinaire en ce qu''elle **construit** son
objet au lieu de l''attendre.

**La science.** Ensemble de connaissances rationnelles, méthodiques et
vérifiables, portant sur un domaine déterminé du réel, et constamment soumises
à la révision.

*Remarquez que chaque définition suit le schéma genre + différence, et que
chacune est formulée de façon à éclairer le texte. Définir la science comme « la
connaissance » aurait valu un demi-point.*

### A2.1 — Le thème et le problème *(2 points)*

**Le thème.** La nature de l''observation scientifique.

**Le problème.** Le rapport entre l''observation et la construction de l''objet
scientifique. Autre formulation acceptée : la science enregistre-t-elle les
faits ou les construit-elle ?

### A2.2 — La thèse *(1 point)*

Bachelard soutient que l''observation scientifique n''est jamais neutre ni
passive : elle est polémique, c''est-à-dire qu''elle se construit **contre** les
apparences, en contestant l''évidence immédiate et le savoir commun.

### A2.3 — La structure logique *(3 points)*

*« Bachelard part du postulat que l''observation scientifique est toujours
polémique, et il le pose d''emblée, sans le démontrer. Il l''établit d''abord en
montrant que l''observation ne se contente pas de regarder : elle instruit un
procès contre ce qui se donne spontanément à voir. Il poursuit en soulignant
que l''expérimentation construit son objet au lieu de l''enregistrer, de sorte
que le fait scientifique n''est jamais donné mais toujours produit. Il conclut
que la science se bâtit contre le savoir commun, et non à partir de lui. »*

---

### Ce que le correcteur a sanctionné cette année-là

**Les définitions de dictionnaire.** « La science est l''ensemble des
connaissances » : vrai, trop large, un demi-point.

**Le thème pris pour le problème.** « Le thème est l''observation scientifique ;
le problème est l''observation scientifique » : la moitié des points de A2.1
perdue.

**La structure rédigée en liste.** Le corrigé demande un paragraphe. Trois
tirets alignés ne sont pas une structure logique rédigée.

**La paraphrase.** Les copies qui recopiaient le texte en changeant trois mots
n''ont rien obtenu à A2.3, parce que la tâche demande de dire **comment** le
texte avance, pas **ce qu''il dit**.
', NULL, 32),
      (v_chapitre_id, 'Quiz du chapitre 3', 11, 'quiz', '{
  "titre": "Vérifie que tu as compris",
  "questions": [
    {
      "question": "Combien de points vaut la première partie de l''épreuve ?",
      "choix": [
        "5 points",
        "9 points, autant que la dissertation",
        "12 points",
        "3 points"
      ],
      "bonne": 1,
      "explication": "Les élèves préfèrent le texte parce qu''ils lisent peu, et ils se trompent : il demande la même culture philosophique et les mêmes auteurs. Ce n''est pas un refuge."
    },
    {
      "question": "Que doit contenir une définition correcte ?",
      "choix": [
        "Un exemple parlant",
        "Le genre prochain et la différence spécifique",
        "Une citation d''auteur",
        "Une négation"
      ],
      "bonne": 1,
      "explication": "« La loi est une RÈGLE — genre — édictée par une autorité souveraine et assortie d''une contrainte — différence. » C''est le schéma d''Aristote, et le correcteur le reconnaît."
    },
    {
      "question": "Quelle est la différence entre le thème et la thèse ?",
      "choix": [
        "Aucune",
        "Le thème est ce dont le texte parle ; la thèse est ce que l''auteur soutient à ce propos",
        "Le thème est plus long",
        "La thèse se met dans l''introduction"
      ],
      "bonne": 1,
      "explication": "Le thème est un groupe nominal, la thèse une phrase affirmative attribuée à l''auteur. Confondre les deux coûte quatre points sur neuf."
    },
    {
      "question": "À quoi reconnaît-on une vraie thèse ?",
      "choix": [
        "Elle est longue",
        "On peut la contredire",
        "Elle cite un auteur",
        "Elle est dans la dernière phrase"
      ],
      "bonne": 1,
      "explication": "Si personne ne peut être en désaccord avec votre phrase, ce n''est pas une thèse mais un constat."
    },
    {
      "question": "Qu''est-ce que le postulat d''un texte ?",
      "choix": [
        "Sa conclusion",
        "Ce que l''auteur pose au départ sans le démontrer",
        "Le premier argument",
        "Un exemple"
      ],
      "bonne": 1,
      "explication": "Il est presque toujours dans la première phrase, et beaucoup de candidats l''oublient : c''est pourtant le point le plus facile de l''épreuve."
    },
    {
      "question": "Comment la structure logique doit-elle être rédigée ?",
      "choix": [
        "En liste à puces",
        "En un seul paragraphe, avec des verbes de mouvement : il pose, il établit, il poursuit, il conclut",
        "En trois pages",
        "Sous forme de tableau"
      ],
      "bonne": 1,
      "explication": "Le corrigé harmonisé national le précise. Trois tirets alignés ne sont pas une structure logique rédigée."
    },
    {
      "question": "Quelle différence entre expliquer et paraphraser ?",
      "choix": [
        "Aucune",
        "Paraphraser redit le texte avec d''autres mots ; expliquer dit ce qu''il fait, pourquoi, et contre qui",
        "Expliquer est plus court",
        "Paraphraser demande une citation"
      ],
      "bonne": 1,
      "explication": "Le test : si quelqu''un qui n''a pas lu le texte peut comprendre votre réponse, vous avez expliqué."
    },
    {
      "question": "Dans la première partie, vous demande-t-on votre avis sur l''auteur ?",
      "choix": [
        "Oui, c''est l''essentiel",
        "Non : aucune des quatre tâches ne demande votre opinion",
        "Seulement à la dernière question",
        "Seulement si le texte est contestable"
      ],
      "bonne": 1,
      "explication": "C''est la différence essentielle avec la dissertation, et la faute la plus fréquente : le candidat qui discute l''auteur en première partie perd ses points et son temps."
    }
  ]
}', NULL, 5);

    RAISE NOTICE '% : 11 leçons ajoutées au chapitre 3, Consolidation des acquis de la méthodologie de l''exercice sur texte philosophique.', v_nom;
  END LOOP;
END $philo$;
