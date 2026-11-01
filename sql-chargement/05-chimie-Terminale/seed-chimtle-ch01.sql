-- ============================================================================
-- MANDAL — Chimie Terminale : chapitre 1, Propriétés chimiques des alcools
-- Module 1 : Chimie organique
-- 6 leçons.
--
-- Ce fichier remplit LES TROIS CLASSES a la fois : Terminale C, D et E.
-- Autonome : il cree lui-meme la matiere, les classes, les programmes et le
-- chapitre s'ils n'existent pas encore. Lancez-le seul, dans n'importe quel
-- ordre.
-- Idempotent : si le chapitre contient deja des lecons, rien n'est ajoute.
-- ============================================================================
DO $chi$
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
  -- la matiere, une seule fois
  INSERT INTO public.matieres (nom) VALUES ('Chimie') ON CONFLICT (nom) DO NOTHING;
  SELECT id INTO v_matiere_id FROM public.matieres WHERE nom = 'Chimie';

  -- l'etablissement, deduit de la table des classes
  SELECT count(DISTINCT etablissement_id) INTO v_nb_etabs FROM public.classes;
  IF v_nb_etabs <> 1 THEN
    RAISE EXCEPTION 'Impossible de deduire l''etablissement : % etablissement(s) distinct(s) dans public.classes.', v_nb_etabs;
  END IF;
  SELECT etablissement_id INTO v_etab_id FROM public.classes LIMIT 1;

  -- on refait le meme travail pour la Terminale C, puis la D, puis la E
  FOR v_i IN 1..3 LOOP
    v_lettre := v_lettres[v_i];
    v_nom := 'Terminale ' || v_lettre;

    -- 1. le programme existe-t-il deja ?
    SELECT p.id INTO v_programme_id FROM public.programmes p
    WHERE p.titre = 'Chimie — ' || v_nom;

    -- 2. sinon on le cree
    IF v_programme_id IS NULL THEN
      -- la classe, quelle que soit la facon dont elle a ete ecrite
      SELECT id INTO v_classe_id FROM public.classes
      WHERE etablissement_id = v_etab_id
        AND (nom = v_nom OR nom ILIKE 'T%le ' || v_lettre)
      ORDER BY (nom = v_nom) DESC
      LIMIT 1;

      -- si elle n'existe pas, on la cree
      IF v_classe_id IS NULL THEN
        INSERT INTO public.classes (etablissement_id, nom, niveau, filiere)
        VALUES (v_etab_id, v_nom, 'Terminale', v_lettre)
        RETURNING id INTO v_classe_id;
        RAISE NOTICE 'Classe "%" creee.', v_nom;
      END IF;

      INSERT INTO public.programmes (matiere_id, classe_id, etablissement_id, titre, description)
      VALUES (v_matiere_id, v_classe_id, v_etab_id, 'Chimie — ' || v_nom,
              'Programme officiel de Chimie, classe de Terminale ' || v_lettre ||
              ' (Cameroun) — 4 modules, 17 chapitres.')
      RETURNING id INTO v_programme_id;
      RAISE NOTICE 'Programme "Chimie — %" cree.', v_nom;
    END IF;

    -- 3. le chapitre existe-t-il deja ?
    SELECT id INTO v_chapitre_id FROM public.chapitres
    WHERE programme_id = v_programme_id AND ordre = 1;

    -- 4. sinon on le cree
    IF v_chapitre_id IS NULL THEN
      INSERT INTO public.chapitres (programme_id, titre, ordre, niveau)
      VALUES (v_programme_id, 'Propriétés chimiques des alcools', 1, 'Module 1 : Chimie organique')
      RETURNING id INTO v_chapitre_id;
      RAISE NOTICE '% : chapitre 1 cree.', v_nom;
    END IF;

    -- 5. les lecons
    SELECT count(*) INTO v_deja FROM public.concepts WHERE chapitre_id = v_chapitre_id;
    IF v_deja > 0 THEN
      RAISE NOTICE '% : chapitre 1 contient deja % lecon(s) — aucun ajout.', v_nom, v_deja;
      CONTINUE;
    END IF;

    INSERT INTO public.concepts
      (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes) VALUES
      (v_chapitre_id, 'Reconnaître les trois classes d''alcools', 1, 'texte', 'Un alcool, c''est une molécule qui porte un groupe hydroxyle $-\text{OH}$ fixé sur un carbone saturé. Sa formule générale est $\text{C}_{n}\text{H}_{2n+1}\text{OH}$, qu''on écrit souvent $\text{R}-\text{OH}$.

Avant toute chose, tu dois savoir reconnaître sa classe. Presque toutes les réactions du chapitre en dépendent.

## Les trois classes

Regarde le carbone qui porte le $-\text{OH}$, qu''on appelle le **carbone fonctionnel**. Compte combien d''autres carbones lui sont directement liés.

Un alcool est **primaire** si ce carbone est lié à un seul autre carbone, ou à aucun dans le cas du méthanol. Exemple, l''éthanol $\text{CH}_{3}-\text{CH}_{2}-\text{OH}$.

Il est **secondaire** si le carbone fonctionnel est lié à deux autres carbones. Exemple, le propan-2-ol $\text{CH}_{3}-\text{CHOH}-\text{CH}_{3}$.

Il est **tertiaire** si ce carbone est lié à trois autres carbones. Exemple, le 2-méthylpropan-2-ol $(\text{CH}_{3})_{3}\text{C}-\text{OH}$.

## Le réflexe de lecture

Ne compte pas les hydrogènes, ne compte pas les carbones de toute la molécule. Place ton doigt sur le carbone qui porte le $\text{OH}$, et compte uniquement ses voisins carbonés.

Un alcool primaire garde deux hydrogènes sur son carbone fonctionnel, un secondaire n''en garde qu''un, un tertiaire n''en garde aucun. C''est exactement ce qui explique la suite : pour s''oxyder, l''alcool doit perdre un hydrogène porté par ce carbone. Le tertiaire n''en a plus, donc il ne s''oxyde pas.

## La nomenclature

On prend la chaîne carbonée la plus longue qui contient le carbone portant le $\text{OH}$. On numérote de façon à donner à ce carbone le plus petit indice possible. On remplace le $-e$ final de l''alcane par $-ol$, précédé de l''indice.

Ainsi $\text{CH}_{3}-\text{CH}_{2}-\text{CH}_{2}-\text{OH}$ devient propan-1-ol, et $\text{CH}_{3}-\text{CHOH}-\text{CH}_{2}-\text{CH}_{3}$ devient butan-2-ol.

Attention, c''est le $\text{OH}$ qui commande la numérotation, pas les ramifications.

## Les propriétés physiques

Les alcools bouillent beaucoup plus haut que les alcanes de masse comparable, à cause des **liaisons hydrogène** entre leurs molécules. L''éthanol bout à $78\ °\text{C}$ alors que le propane, de masse voisine, bout à $-42\ °\text{C}$.

Les premiers alcools sont miscibles à l''eau en toutes proportions, pour la même raison. Mais plus la chaîne carbonée s''allonge, plus la partie grasse l''emporte et moins l''alcool se dissout.

## Exercice d''application

Nomme et donne la classe des trois alcools suivants, de formules semi-développées
$$\text{CH}_{3}-\text{CH}_{2}-\text{CH}_{2}-\text{CH}_{2}-\text{OH} \qquad (\text{CH}_{3})_{2}\text{CH}-\text{CH}_{2}-\text{OH} \qquad \text{CH}_{3}-\text{C}(\text{CH}_{3})(\text{OH})-\text{CH}_{2}-\text{CH}_{3}$$

Correction. Le premier a quatre carbones en ligne et le $\text{OH}$ au bout : c''est le butan-1-ol. Son carbone fonctionnel n''a qu''un voisin carboné, l''alcool est **primaire**.

Le deuxième s''écrit aussi $\text{CH}_{3}-\text{CH}(\text{CH}_{3})-\text{CH}_{2}-\text{OH}$. La chaîne la plus longue a trois carbones, avec un méthyle en position 2 et le $\text{OH}$ en position 1 : c''est le 2-méthylpropan-1-ol. Son carbone fonctionnel n''a qu''un voisin carboné, l''alcool est **primaire** lui aussi. Ne te laisse pas tromper par la ramification, elle ne touche pas le carbone fonctionnel.

Le troisième a une chaîne de quatre carbones, un méthyle et le $\text{OH}$ tous deux en position 2 : c''est le 2-méthylbutan-2-ol. Son carbone fonctionnel est lié à trois carbones, l''alcool est **tertiaire**.', NULL, 15),
      (v_chapitre_id, 'Classe les alcools toi-même', 2, 'interactif', '{
  "widget": "classe-alcool",
  "consigne": "Fais varier la molécule et observe comment la classe de l''alcool change. Compte à chaque fois les voisins carbonés du carbone qui porte le groupe OH. Trouve ensuite un alcool tertiaire, et vérifie qu''il ne reste aucun hydrogène sur ce carbone."
}', NULL, 10),
      (v_chapitre_id, 'Réaction avec le sodium et déshydratation', 3, 'texte', 'Deux réactions ne touchent pas au carbone fonctionnel. La première casse la liaison $\text{O}-\text{H}$, la seconde arrache une molécule d''eau.

## L''action du sodium

Jette un petit morceau de sodium dans de l''éthanol. Un gaz se dégage doucement, et il brûle avec une petite détonation : c''est du dihydrogène.
$$2\,\text{R}-\text{OH} + 2\,\text{Na} \longrightarrow 2\,\text{R}-\text{O}^{-}\text{Na}^{+} + \text{H}_{2}$$

Le produit $\text{R}-\text{O}^{-}\text{Na}^{+}$ s''appelle un **alcoolate** de sodium. Avec l''éthanol on obtient l''éthanolate de sodium.

Cette réaction prouve que l''hydrogène du groupe $\text{OH}$ est mobile. L''alcool se comporte donc comme un acide très faible.

Compare avec l''eau : la réaction est la même, mais beaucoup plus calme. L''alcool est un acide encore plus faible que l''eau, et la vivacité décroît quand la chaîne s''allonge.

Retiens le bilan de matière : **deux moles d''alcool donnent une mole de dihydrogène**. Mesurer le volume de gaz permet donc de remonter à la quantité d''alcool, et c''est une question classique d''examen.

## La déshydratation

Chauffe un alcool en présence d''un déshydratant comme l''alumine $\text{Al}_{2}\text{O}_{3}$ ou l''acide sulfurique concentré. Il perd une molécule d''eau. Le produit dépend de la température.

**Vers $170\ °\text{C}$, la déshydratation est intramoléculaire** et donne un alcène :
$$\text{C}_{n}\text{H}_{2n+1}\text{OH} \longrightarrow \text{C}_{n}\text{H}_{2n} + \text{H}_{2}\text{O}$$

L''eau part en emportant le $\text{OH}$ et un hydrogène porté par un carbone **voisin**. Il se forme alors une double liaison entre ces deux carbones.

**Vers $140\ °\text{C}$, la déshydratation est intermoléculaire** et donne un éther-oxyde :
$$2\,\text{R}-\text{OH} \longrightarrow \text{R}-\text{O}-\text{R} + \text{H}_{2}\text{O}$$

Ici, l''eau est formée à partir du $\text{OH}$ d''une molécule et de l''hydrogène du $\text{OH}$ de l''autre.

## La règle de Zaïtsev

Quand plusieurs alcènes sont possibles, c''est le plus **substitué** qui se forme majoritairement, c''est-à-dire celui dont la double liaison porte le plus de groupes carbonés.

Prends le butan-2-ol. L''eau peut emporter un hydrogène du carbone 1 ou du carbone 3. On obtient donc le but-1-ène ou le but-2-ène. Le but-2-ène, dont la double liaison est entre les carbones 2 et 3, porte deux méthyles : c''est lui le produit majoritaire.

## Exercice d''application

Un alcool saturé à chaîne ouverte a une masse molaire de $74\ \text{g}\cdot\text{mol}^{-1}$. On fait réagir $3{,}7$ g de cet alcool avec un excès de sodium et on recueille $560$ mL de gaz dans les conditions normales. Détermine la formule brute de l''alcool, puis vérifie la cohérence avec le volume de gaz. On donne $\text{C} : 12$, $\text{H} : 1$, $\text{O} : 16$, et le volume molaire $V_{m} = 22{,}4\ \text{L}\cdot\text{mol}^{-1}$.

Correction. La formule générale est $\text{C}_{n}\text{H}_{2n+2}\text{O}$, de masse molaire $14n + 18$.

On résout $14n + 18 = 74$, donc $14n = 56$ et $n = 4$. L''alcool est en $\text{C}_{4}\text{H}_{10}\text{O}$.

Vérifions avec le gaz. La quantité d''alcool vaut
$$n_{\text{alcool}} = \dfrac{3{,}7}{74} = 0{,}050\ \text{mol}$$

D''après l''équation, il se forme deux fois moins de dihydrogène :
$$n_{\text{H}_{2}} = \dfrac{0{,}050}{2} = 0{,}025\ \text{mol}$$

Le volume correspondant vaut
$$V = 0{,}025 \times 22{,}4 = 0{,}56\ \text{L} = 560\ \text{mL}$$

C''est exactement le volume mesuré. Les deux données concordent, la formule $\text{C}_{4}\text{H}_{10}\text{O}$ est confirmée.', NULL, 15),
      (v_chapitre_id, 'L''oxydation ménagée des alcools', 4, 'texte', 'Voici le cœur du chapitre, et la question qui revient à chaque examen. Selon la classe de l''alcool, l''oxydation donne un produit différent, ou ne donne rien du tout.

## Ce qu''on appelle oxydation ménagée

Oxyder un alcool, c''est lui retirer des hydrogènes sans casser sa chaîne carbonée. C''est le contraire de la combustion, qui détruit tout et ne donne que du dioxyde de carbone et de l''eau.
$$\text{C}_{n}\text{H}_{2n+1}\text{OH} + \dfrac{3n}{2}\,\text{O}_{2} \longrightarrow n\,\text{CO}_{2} + (n+1)\,\text{H}_{2}\text{O}$$

L''oxydation ménagée, elle, préserve le squelette carboné.

## L''alcool primaire donne un aldéhyde puis un acide

Un alcool primaire s''oxyde en deux temps.
$$\text{R}-\text{CH}_{2}\text{OH} \longrightarrow \text{R}-\text{CHO} \longrightarrow \text{R}-\text{COOH}$$

Le premier produit est un **aldéhyde**, le second un **acide carboxylique**.

Ce qui décide du produit obtenu, c''est la quantité d''oxydant. Avec l''oxydant **en défaut** et en distillant au fur et à mesure, on s''arrête à l''aldéhyde. Avec l''oxydant **en excès**, on va jusqu''à l''acide.

## L''alcool secondaire donne une cétone, et s''arrête là

$$\text{R}-\text{CHOH}-\text{R}'' \longrightarrow \text{R}-\text{CO}-\text{R}''$$

La **cétone** obtenue ne peut plus s''oxyder sans casser la chaîne, donc la réaction s''arrête d''elle-même, même avec un excès d''oxydant.

## L''alcool tertiaire ne s''oxyde pas

Son carbone fonctionnel ne porte aucun hydrogène. Il n''y a donc rien à lui retirer, et l''oxydation ménagée est impossible.

## Les oxydants et leurs couleurs

En solution aqueuse, on utilise deux oxydants, et leur **changement de couleur** sert de test.

Le permanganate de potassium en milieu acide, couple $\text{MnO}_{4}^{-}/\text{Mn}^{2+}$. La solution passe du **violet à l''incolore**.
$$\text{MnO}_{4}^{-} + 8\,\text{H}^{+} + 5\,\text{e}^{-} \longrightarrow \text{Mn}^{2+} + 4\,\text{H}_{2}\text{O}$$

Le dichromate de potassium en milieu acide, couple $\text{Cr}_{2}\text{O}_{7}^{2-}/\text{Cr}^{3+}$. La solution passe de l''**orange au vert**.
$$\text{Cr}_{2}\text{O}_{7}^{2-} + 14\,\text{H}^{+} + 6\,\text{e}^{-} \longrightarrow 2\,\text{Cr}^{3+} + 7\,\text{H}_{2}\text{O}$$

En milieu anhydre, on utilise le cuivre porté au rouge, ou l''oxyde de cuivre $\text{CuO}$.

## Identifier le produit obtenu

Deux familles de tests, et il faut les enchaîner dans le bon ordre.

La **2,4-DNPH**, ou 2,4-dinitrophénylhydrazine, donne un **précipité jaune orangé** avec un aldéhyde comme avec une cétone. Elle prouve donc la présence d''un groupe carbonyle $\text{C}=\text{O}$, sans distinguer les deux.

Pour trancher, on utilise un test spécifique des aldéhydes. Le **réactif de Tollens**, une solution de nitrate d''argent ammoniacal, dépose un **miroir d''argent**. La **liqueur de Fehling**, chauffée, donne un **précipité rouge brique** d''oxyde de cuivre $\text{Cu}_{2}\text{O}$.

Une cétone ne répond à aucun de ces deux derniers tests.

Et si le produit rougit le **papier pH humide**, c''est qu''on est allé jusqu''à l''acide carboxylique.

## La stratégie d''identification

Face à un alcool inconnu, procède ainsi. Tu oxydes et tu testes le produit à la 2,4-DNPH. S''il n''y a pas de précipité, l''alcool était tertiaire. S''il y a un précipité, tu fais le test de Fehling ou de Tollens. Positif, l''alcool était primaire. Négatif, il était secondaire.

## Exercice d''application

Un composé $A$ de formule brute $\text{C}_{4}\text{H}_{10}\text{O}$ est oxydé par une solution de dichromate de potassium en excès. Le produit $B$ obtenu donne un précipité jaune avec la 2,4-DNPH mais ne réagit pas avec le réactif de Tollens. Identifie $A$ et $B$, puis écris l''équation de la réaction.

Correction. Le précipité à la 2,4-DNPH montre que $B$ porte un groupe carbonyle. L''absence de réaction avec Tollens élimine l''aldéhyde : $B$ est donc une **cétone**.

Une cétone ne peut venir que d''un alcool **secondaire**. Parmi les alcools en $\text{C}_{4}\text{H}_{10}\text{O}$, le seul secondaire est le **butan-2-ol**, donc $A = \text{CH}_{3}-\text{CHOH}-\text{CH}_{2}-\text{CH}_{3}$.

Le produit $B$ est la **butan-2-one**, $\text{CH}_{3}-\text{CO}-\text{CH}_{2}-\text{CH}_{3}$.

Pour l''équation, la demi-équation d''oxydation de l''alcool s''écrit
$$\text{C}_{4}\text{H}_{10}\text{O} \longrightarrow \text{C}_{4}\text{H}_{8}\text{O} + 2\,\text{H}^{+} + 2\,\text{e}^{-}$$

On la combine avec la demi-équation du dichromate, en multipliant la première par 3 pour équilibrer les six électrons :
$$3\,\text{C}_{4}\text{H}_{10}\text{O} + \text{Cr}_{2}\text{O}_{7}^{2-} + 8\,\text{H}^{+} \longrightarrow 3\,\text{C}_{4}\text{H}_{8}\text{O} + 2\,\text{Cr}^{3+} + 7\,\text{H}_{2}\text{O}$$

Pendant la réaction, la solution passe de l''orange au vert.', NULL, 15),
      (v_chapitre_id, 'Oxyde un alcool et teste le produit', 5, 'interactif', '{
  "widget": "oxydation-alcool",
  "consigne": "Choisis un alcool et la quantité d''oxydant, puis lance l''oxydation. Observe la couleur de la solution changer et lis le produit obtenu. Fais ensuite les tests d''identification. Trouve l''alcool qui ne donne aucun produit, et explique pourquoi."
}', NULL, 10),
      (v_chapitre_id, 'Quiz du chapitre 1', 6, 'quiz', '{
  "titre": "Vérifie que tu as compris",
  "questions": [
    {
      "question": "Quelle est la classe de l''alcool $(\\text{CH}_3)_3\\text{C}-\\text{OH}$ ?",
      "choix": [
        "Primaire",
        "Secondaire",
        "Tertiaire",
        "Ce n''est pas un alcool"
      ],
      "bonne": 2,
      "explication": "Le carbone qui porte le groupe OH est lié à trois autres carbones, donc l''alcool est tertiaire. Il ne lui reste aucun hydrogène sur ce carbone, c''est pourquoi il ne s''oxyde pas."
    },
    {
      "question": "Un alcool primaire oxydé par un excès de dichromate donne :",
      "choix": [
        "un aldéhyde",
        "une cétone",
        "un acide carboxylique",
        "un alcène"
      ],
      "bonne": 2,
      "explication": "Avec l''oxydant en excès, l''oxydation ne s''arrête pas à l''aldéhyde : elle se poursuit jusqu''à l''acide carboxylique. Pour obtenir l''aldéhyde il faut l''oxydant en défaut, et le distiller au fur et à mesure."
    },
    {
      "question": "Le produit d''oxydation d''un alcool donne un précipité jaune avec la 2,4-DNPH mais aucun miroir d''argent avec Tollens. De quel alcool part-on ?",
      "choix": [
        "Primaire",
        "Secondaire",
        "Tertiaire",
        "On ne peut pas conclure"
      ],
      "bonne": 1,
      "explication": "La 2,4-DNPH prouve un groupe carbonyle, aldéhyde ou cétone. L''absence de réaction avec Tollens élimine l''aldéhyde, donc c''est une cétone, qui ne peut venir que d''un alcool secondaire."
    },
    {
      "question": "On fait réagir 0,2 mol d''éthanol avec un excès de sodium. Quel volume de gaz obtient-on dans les conditions normales ?",
      "choix": [
        "1,12 L",
        "2,24 L",
        "4,48 L",
        "0,56 L"
      ],
      "bonne": 1,
      "explication": "Deux moles d''alcool donnent une mole de dihydrogène, donc 0,2 mol d''éthanol donnent 0,1 mol de gaz. Le volume vaut $0{,}1 \\times 22{,}4 = 2{,}24$ L."
    },
    {
      "question": "La déshydratation du butan-2-ol vers 170 °C donne majoritairement :",
      "choix": [
        "le but-1-ène",
        "le but-2-ène",
        "un éther-oxyde",
        "de l''eau seulement"
      ],
      "bonne": 1,
      "explication": "D''après la règle de Zaïtsev, c''est l''alcène le plus substitué qui se forme majoritairement. Le but-2-ène porte deux groupes méthyle sur sa double liaison, contre un seul pour le but-1-ène."
    },
    {
      "question": "Pourquoi l''éthanol bout-il à 78 °C alors que le propane, de masse voisine, bout à −42 °C ?",
      "choix": [
        "L''éthanol est plus lourd",
        "À cause des liaisons hydrogène entre molécules d''éthanol",
        "Le propane est un gaz noble",
        "L''éthanol contient du carbone"
      ],
      "bonne": 1,
      "explication": "Le groupe OH permet des liaisons hydrogène entre molécules voisines. Il faut donc beaucoup plus d''énergie pour les séparer, d''où une température d''ébullition très supérieure."
    }
  ]
}', NULL, 5);

    RAISE NOTICE '% : chapitre 1, Propriétés chimiques des alcools — 6 lecons ajoutees.', v_nom;
  END LOOP;
END $chi$;
