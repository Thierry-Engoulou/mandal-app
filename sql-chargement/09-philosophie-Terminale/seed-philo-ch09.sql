-- ---------------------------------------------------------------------------
-- M'Andal — Philosophie, classes de Terminale
-- Chapitre 9 : Panafricanisme et développement de l'Afrique
-- Module 1 : La philosophie — 9 leçons
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
    WHERE programme_id = v_programme_id AND ordre = 9;

    IF v_chapitre_id IS NULL THEN
      INSERT INTO public.chapitres (programme_id, titre, ordre, niveau)
      VALUES (v_programme_id, 'Panafricanisme et développement de l''Afrique', 9, 'Module 1 : La philosophie')
      RETURNING id INTO v_chapitre_id;
      RAISE NOTICE '% : chapitre 9 créé.', v_nom;
    END IF;

    -- Les leçons. Si le chapitre en a déjà, on passe son tour sans rien toucher.
    SELECT count(*) INTO v_deja FROM public.concepts WHERE chapitre_id = v_chapitre_id;
    IF v_deja > 0 THEN
      RAISE NOTICE '% : le chapitre 9 a déjà ses % leçons, je n''y touche pas.', v_nom, v_deja;
      CONTINUE;
    END IF;

    INSERT INTO public.concepts
      (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes) VALUES
      (v_chapitre_id, 'Le panafricanisme : naissance d''une idée', 1, 'texte', '
Attention au piège de ce chapitre : le panafricanisme n''est pas né en Afrique.
Il est né dans la **diaspora**, chez les descendants d''esclaves, et cela change
tout à son sens.

### La définition

Le **panafricanisme** est le mouvement politique, culturel et intellectuel qui
affirme l''**unité de destin** des peuples africains et de leurs diasporas, et
qui prône leur solidarité et leur union contre la domination.

Le préfixe *pan*, en grec, signifie « tout ». Le panafricanisme pense l''Afrique
comme un tout, contre un morcellement qu''elle n''a pas choisi.

### Pourquoi la diaspora d''abord

Un homme vivant au Cameroun au XIXe siècle se savait Douala, Bamiléké
ou Fulbé : il n''avait aucune raison de se dire « africain ». C''est aux Amériques
que l''identité africaine s''est forgée, parce que là, la couleur de la peau avait
effacé toutes les autres appartenances. L''unité africaine a d''abord été une
**expérience commune de la négation**, avant d''être un projet politique.

### Les fondateurs

**Edward Wilmot Blyden** (1832-1912), né aux Antilles, installé au Libéria :
l''un des premiers à soutenir que l''Afrique a une personnalité propre, et qu''elle
n''a pas à devenir européenne pour valoir.

**Henry Sylvester Williams**, avocat trinidadien, organise à **Londres en 1900**
la première conférence panafricaine. C''est l''acte de naissance du mot.

**W.E.B. Du Bois** (1868-1963), sociologue américain, qu''on appelle le **père du
panafricanisme**. Il organise les congrès panafricains successifs — Paris 1919,
Londres 1921, Londres et Lisbonne 1923, New York 1927, et surtout **Manchester
1945**. Sa thèse : « le problème du XXe siècle est le problème de la
ligne de couleur ». Il finira ses jours au Ghana, invité par Nkrumah.

**Marcus Garvey** (1887-1940), Jamaïcain, fonde l''*Universal Negro Improvement
Association*. Son mot d''ordre est le **retour en Afrique**, et son influence
immense : « Afrique pour les Africains, ceux de l''intérieur comme ceux de
l''extérieur ».

**George Padmore**, Trinidadien, théoricien et conseiller de Nkrumah : il fait
le pont entre la diaspora et l''Afrique en voie d''indépendance.

### Le tournant de 1945

Le congrès de **Manchester** change la nature du mouvement. Jusque-là, il
réclamait des droits ; désormais, il réclame l''**indépendance**. Et pour la
première fois, les militants africains y sont majoritaires : **Kwame Nkrumah**
pour la Gold Coast, **Jomo Kenyatta** pour le Kenya. Le panafricanisme passe
de la diaspora au continent.

### Le versant culturel : la négritude

Parallèlement, à Paris, **Léopold Sédar Senghor**, **Aimé Césaire** et
**Léon-Gontran Damas** lancent la **négritude**, que Césaire définit comme « la
simple reconnaissance du fait d''être noir, et l''acceptation de ce fait, de notre
destin de Noir, de notre histoire et de notre culture ».

La négritude est au panafricanisme ce que la culture est à la politique : la
même revendication, par un autre chemin.

---

**Exercice corrigé**

*Définir le panafricanisme. Expliquer pourquoi il est né dans la diaspora, et
dire ce que le congrès de Manchester a changé.*

**Correction.**

*La définition.* Le panafricanisme est le mouvement politique, culturel et
intellectuel qui affirme l''unité de destin des peuples africains et de leurs
diasporas, et qui prône leur solidarité et leur union contre la domination
étrangère.

*Pourquoi la diaspora d''abord.* Parce que l''identité « africaine » est née de
la **négation**, non de la proximité.

Sur le continent, les hommes s''identifiaient par leur peuple, leur langue et
leur royaume ; rien ne les poussait à se penser comme un seul ensemble. Dans les
Amériques, la traite avait effacé ces appartenances et ne laissait qu''un seul
trait commun : la couleur, devenue marque d''infériorité.

C''est donc l''oppression qui a produit l''unité qu''elle niait. Blyden, Williams,
Du Bois, Garvey et Padmore sont tous nés hors d''Afrique.

*Ce que Manchester a changé, en 1945.* Deux choses.

**L''objet de la revendication.** Avant, les congrès demandaient des droits, des
réformes, la fin des discriminations. À Manchester, ils demandent
l''**indépendance** — sans délai, et sans la mendier.

**Les acteurs.** Pour la première fois, les militants du continent sont au
premier rang : Nkrumah, Kenyatta. Le panafricanisme cesse d''être une pensée de
la diaspora sur l''Afrique pour devenir le programme politique des futurs États
africains.

*On peut conclure : l''idée a fait le trajet inverse de la traite. Partie
d''Afrique dans les cales, elle est revenue par les congrès.*
', NULL, 30),
      (v_chapitre_id, 'Figure : du premier congrès à l''Union africaine', 2, 'figure', '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 580 300" width="580" height="300">
<rect width="580" height="300" fill="#ffffff"/>
<text x="290" y="24" text-anchor="middle" font-size="14" font-weight="700" fill="#0f172a">Le panafricanisme : de la diaspora à l&apos;Union africaine</text>

<line x1="40" y1="100" x2="548" y2="100" stroke="#334155" stroke-width="2"/>
<polygon points="548,100 540,96 540,104" fill="#334155"/>

<g font-size="8" fill="#334155" text-anchor="middle">
<line x1="70" y1="94" x2="70" y2="106" stroke="#334155"/><text x="70" y="120">1900</text>
<line x1="160" y1="94" x2="160" y2="106" stroke="#334155"/><text x="160" y="120">1919-1945</text>
<line x1="265" y1="94" x2="265" y2="106" stroke="#334155"/><text x="265" y="120">1958-1961</text>
<line x1="370" y1="94" x2="370" y2="106" stroke="#334155"/><text x="370" y="120">1963</text>
<line x1="480" y1="94" x2="480" y2="106" stroke="#334155"/><text x="480" y="120">2002</text>
</g>

<rect x="22" y="44" width="96" height="44" rx="4" fill="#ede9fe" stroke="#7c3aed" stroke-width="1.4"/>
<text x="70" y="60" text-anchor="middle" font-size="8" font-weight="700" fill="#5b21b6">1er congrès</text>
<text x="70" y="72" text-anchor="middle" font-size="7" fill="#6d28d9">Londres</text>
<text x="70" y="83" text-anchor="middle" font-size="7" fill="#6d28d9">S. Williams</text>

<rect x="112" y="44" width="96" height="44" rx="4" fill="#ede9fe" stroke="#7c3aed" stroke-width="1.4"/>
<text x="160" y="60" text-anchor="middle" font-size="8" font-weight="700" fill="#5b21b6">les congrès</text>
<text x="160" y="72" text-anchor="middle" font-size="7" fill="#6d28d9">Du Bois, Garvey</text>
<text x="160" y="83" text-anchor="middle" font-size="7" fill="#6d28d9">Padmore</text>

<rect x="216" y="44" width="98" height="44" rx="4" fill="#fef3c7" stroke="#ca8a04" stroke-width="1.4"/>
<text x="265" y="60" text-anchor="middle" font-size="8" font-weight="700" fill="#78350f">Accra, Casablanca</text>
<text x="265" y="72" text-anchor="middle" font-size="7" fill="#92400e">Nkrumah, Touré</text>
<text x="265" y="83" text-anchor="middle" font-size="7" fill="#92400e">Keïta, Nasser</text>

<rect x="322" y="44" width="96" height="44" rx="4" fill="#dcfce7" stroke="#15803d" stroke-width="1.4"/>
<text x="370" y="60" text-anchor="middle" font-size="8" font-weight="700" fill="#14532d">OUA</text>
<text x="370" y="72" text-anchor="middle" font-size="7" fill="#166534">Addis-Abeba</text>
<text x="370" y="83" text-anchor="middle" font-size="7" fill="#166534">32 États</text>

<rect x="430" y="44" width="100" height="44" rx="4" fill="#dcfce7" stroke="#15803d" stroke-width="1.4"/>
<text x="480" y="60" text-anchor="middle" font-size="8" font-weight="700" fill="#14532d">Union africaine</text>
<text x="480" y="72" text-anchor="middle" font-size="7" fill="#166534">Durban</text>
<text x="480" y="83" text-anchor="middle" font-size="7" fill="#166534">55 États</text>

<rect x="30" y="144" width="248" height="134" rx="6" fill="#fef2f2" stroke="#dc2626" stroke-width="1.6"/>
<text x="154" y="164" text-anchor="middle" font-size="11" font-weight="700" fill="#7f1d1d">Groupe de CASABLANCA</text>
<text x="154" y="180" text-anchor="middle" font-size="9" fill="#991b1b">les unionistes, 1961</text>
<line x1="46" y1="190" x2="262" y2="190" stroke="#fca5a5"/>
<text x="44" y="208" font-size="9" fill="#991b1b">Nkrumah, Sékou Touré,</text>
<text x="44" y="222" font-size="9" fill="#991b1b">Modibo Keïta, Nasser</text>
<text x="44" y="242" font-size="9" font-weight="700" fill="#7f1d1d">Les États-Unis d&apos;Afrique,</text>
<text x="44" y="256" font-size="9" font-weight="700" fill="#7f1d1d">tout de suite.</text>
<text x="154" y="272" text-anchor="middle" font-size="8" font-style="italic" fill="#475569">« L&apos;Afrique doit s&apos;unir »</text>

<rect x="300" y="144" width="250" height="134" rx="6" fill="#eff6ff" stroke="#2563eb" stroke-width="1.6"/>
<text x="425" y="164" text-anchor="middle" font-size="11" font-weight="700" fill="#1e3a8a">Groupe de MONROVIA</text>
<text x="425" y="180" text-anchor="middle" font-size="9" fill="#1e40af">les gradualistes, 1961</text>
<line x1="316" y1="190" x2="534" y2="190" stroke="#93c5fd"/>
<text x="314" y="208" font-size="9" fill="#1e40af">Houphouët-Boigny, Ahidjo,</text>
<text x="314" y="222" font-size="9" fill="#1e40af">Senghor, Azikiwe</text>
<text x="314" y="242" font-size="9" font-weight="700" fill="#1e3a8a">D&apos;abord la coopération,</text>
<text x="314" y="256" font-size="9" font-weight="700" fill="#1e3a8a">l&apos;union viendra.</text>
<text x="425" y="272" text-anchor="middle" font-size="8" font-style="italic" fill="#475569">respect des souverainetés</text>

<path d="M 154 136 L 154 126 L 425 126 L 425 136" fill="none" stroke="#15803d" stroke-width="1.4"/>
<text x="290" y="140" text-anchor="middle" font-size="8" font-weight="700" fill="#14532d">compromis de 1963 : l&apos;OUA</text>
</svg>', NULL, 5),
      (v_chapitre_id, 'Simulation : les pères du panafricanisme', 3, 'interactif', '{
  "widget": "peres-panafricanisme",
  "consigne": "Une galerie te présente douze figures — Blyden, Williams, Du Bois, Garvey, Padmore, Nkrumah, Senghor, Césaire, Cheikh Anta Diop, Sankara, Nasser, Houphouët-Boigny — et tu dois associer à chacune son œuvre, son pays et sa thèse. La simulation te fait ensuite placer chaque figure sur deux axes : diaspora ou continent, culture ou politique. Le nuage qui apparaît raconte l''histoire du mouvement, et tu vois d''un coup d''œil pourquoi 1945 est la charnière."
}', NULL, 10),
      (v_chapitre_id, 'Casablanca contre Monrovia : quelle unité ?', 4, 'texte', '
Les indépendances arrivent, et l''unité africaine devient une question pratique.
Elle divise aussitôt ses partisans, et cette division explique tout ce qui a
suivi.

### Le groupe de Casablanca : les unionistes

Réunis en 1961, **Kwame Nkrumah** (Ghana), **Sékou Touré** (Guinée), **Modibo
Keïta** (Mali), **Gamal Abdel Nasser** (Égypte) et le roi du Maroc défendent
l''union politique **immédiate**.

Leur thèse : les États issus de la colonisation sont trop petits, trop
artificiels et trop dépendants pour être réellement souverains. Il faut des
**États-Unis d''Afrique**, avec un gouvernement, une monnaie et une armée
communs.

Nkrumah la résume dans le titre de son livre : **« L''Afrique doit s''unir »**
(1963). Et il avertit : l''indépendance politique sans indépendance économique
est une coquille vide. C''est la thèse de son autre ouvrage, *Le néo-colonialisme,
dernier stade de l''impérialisme* (1965) — la domination continue par
l''économie, après que les drapeaux ont changé.

### Le groupe de Monrovia : les gradualistes

La même année, **Félix Houphouët-Boigny** (Côte d''Ivoire), **Ahmadou Ahidjo**
(Cameroun), **Léopold Sédar Senghor** (Sénégal) et **Nnamdi Azikiwe** (Nigeria)
défendent une union **progressive**, fondée sur la coopération entre États
souverains.

Leur thèse : les jeunes États ont d''abord besoin de se construire. Une
fédération précipitée écraserait les petits, raviverait les rivalités, et
l''unité imposée d''en haut se défera comme elle s''est faite.

### Le compromis de 1963 : l''OUA

Le 25 mai 1963, à **Addis-Abeba**, trente-deux États créent l''**Organisation de
l''unité africaine**. C''est la thèse de Monrovia qui l''emporte : une
organisation de coopération, non une fédération.

Deux principes y sont inscrits, et ils vont peser lourd : l''**intangibilité des
frontières héritées de la colonisation**, et la **non-ingérence dans les
affaires intérieures** des États membres.

Le premier a évité les guerres de frontières. Le second a réduit l''OUA au
silence devant les dictatures, au point qu''on l''a surnommée le « syndicat des
chefs d''État ».

En 2002, à Durban, l''OUA devient l''**Union africaine**, qui se donne un droit
d''intervention en cas de crimes graves, un parlement, et un projet de marché
commun.

### Les penseurs du développement africain

**Cheikh Anta Diop** fournit au panafricanisme sa base savante. Dans *Nations
nègres et culture* (1954), il soutient l''antériorité des civilisations nègres et
l''**unité culturelle** de l''Afrique noire. Dans *Les fondements économiques et
culturels d''un État fédéral d''Afrique noire* (1960), il montre que l''unité n''est
pas un rêve mais une condition : aucun État africain seul n''atteint la taille
critique.

**Thomas Sankara** met la thèse en pratique au Burkina Faso : refus de la dette
— « la dette est une reconquête de l''Afrique » —, consommation locale,
autosuffisance alimentaire, lutte contre le gaspillage de l''État.

**Joseph Ki-Zerbo** avertit par un proverbe : « quand on dort sur la natte des
autres, c''est comme si on dormait par terre ». Le développement importé n''est
pas un développement.

**Ebénézer Njoh Mouelle**, dans *De la médiocrité à l''excellence* (1970),
déplace la question : le sous-développement est d''abord un **état d''esprit**, et
le développement une exigence d''excellence que chacun doit s''imposer.

**Axelle Kabou**, dans *Et si l''Afrique refusait le développement ?* (1991),
porte l''accusation la plus dure, et il faut la citer honnêtement : les Africains
ne seraient pas seulement victimes, ils seraient aussi complices, par le
fatalisme, le culte du passé et la démission des élites.

---

**Exercice corrigé**

*Opposer le groupe de Casablanca et le groupe de Monrovia, puis apprécier le
compromis de 1963.*

**Correction.**

*Le groupe de Casablanca.* Nkrumah, Sékou Touré, Modibo Keïta, Nasser. Ils
veulent l''**union politique immédiate** : un gouvernement, une monnaie et une
armée pour toute l''Afrique.

Leur raison est claire : les frontières coloniales ont été tracées sans les
Africains, les États qu''elles enferment sont trop petits pour peser, et une
indépendance politique sans puissance économique reste nominale. Nkrumah nomme
cela le **néocolonialisme**.

*Le groupe de Monrovia.* Houphouët-Boigny, Ahidjo, Senghor, Azikiwe. Ils veulent
une **union progressive** par la coopération, dans le respect des souverainetés.

Leur raison est également solide : une fédération improvisée serait dominée par
les plus grands, raviverait les rivalités, et l''unité décrétée d''en haut ne
tiendrait pas.

*Le compromis de 1963.* L''OUA retient la méthode de Monrovia : coopération, non
fédération. Elle inscrit l''intangibilité des frontières et la non-ingérence.

*L''appréciation, et elle doit être double.*

**Au crédit de l''OUA :** elle a existé et duré, elle a soutenu efficacement les
luttes de décolonisation et la fin de l''apartheid, et l''intangibilité des
frontières a épargné au continent les guerres de frontières généralisées que
tout rendait possibles.

**À son passif :** la non-ingérence l''a rendue muette devant les coups d''État
et les massacres commis par ses propres membres — d''où le surnom de « syndicat
des chefs d''État ». Et le refus de l''union économique a laissé intacte la
dépendance que Nkrumah dénonçait : soixante ans plus tard, le commerce entre
pays africains reste faible comparé à celui qu''ils entretiennent avec
l''extérieur.

*On peut conclure que les gradualistes ont gagné la méthode et les unionistes le
diagnostic : l''Union africaine de 2002, avec son droit d''intervention et son
projet de marché commun, est en train de donner raison aux seconds par les
moyens des premiers.*
', NULL, 32),
      (v_chapitre_id, 'Simulation : Casablanca ou Monrovia ?', 5, 'interactif', '{
  "widget": "casablanca-monrovia",
  "consigne": "Tu es à la table d''Addis-Abeba en 1963 et tu dois construire une organisation africaine en réglant cinq leviers : la monnaie, l''armée, les frontières, la non-ingérence et le marché commun. Chaque réglage te rapproche de Casablanca ou de Monrovia, et trois jauges répondent — poids diplomatique, stabilité, autonomie économique. Essaie l''OUA réelle : tu verras la stabilité monter et l''autonomie stagner. Puis essaie les États-Unis d''Afrique de Nkrumah, et regarde quelle jauge s''effondre."
}', NULL, 10),
      (v_chapitre_id, 'Le panafricanisme peut-il développer l''Afrique ?', 6, 'texte', '
C''est la question du chapitre, et elle demande qu''on définisse d''abord le second
terme.

### Croissance et développement

La **croissance** est l''augmentation quantitative et durable de la production
d''un pays. Elle se mesure.

Le **développement** est autre chose. **François Perroux** le définit comme « la
combinaison des changements mentaux et sociaux d''une population qui la rendent
apte à faire croître cumulativement et durablement son produit réel global ».

Pesez ces mots : **changements mentaux et sociaux**. La croissance est un
chiffre, le développement est une transformation. Un pays peut connaître une
forte croissance pétrolière sans se développer, si la richesse sort aussitôt du
pays et ne change rien ni à l''école, ni à la santé, ni aux mentalités.

### Thèse : oui, le panafricanisme est la condition du développement

**Argument 1 — la taille.** Aucun État africain pris seul n''atteint la taille
critique d''un marché moderne. **Cheikh Anta Diop** en fait la démonstration dans
*Les fondements économiques et culturels d''un État fédéral d''Afrique noire* : la
balkanisation est le premier obstacle économique du continent.

**Argument 2 — le poids.** Face aux grandes puissances et aux multinationales,
cinquante-cinq États qui négocient séparément sont cinquante-cinq fois plus
faibles. **Nkrumah** : l''Afrique doit s''unir, ou elle restera sous tutelle.

**Argument 3 — la mutualisation.** Un barrage, un chemin de fer, une université
de rang mondial, une industrie pharmaceutique dépassent les moyens d''un seul
pays et seraient à la portée d''un ensemble.

**Argument 4 — la fin du néocolonialisme.** C''est la thèse du *Néo-colonialisme,
dernier stade de l''impérialisme* : l''indépendance juridique sans souveraineté
économique est une façade. Seule l''union peut donner la seconde.

### Antithèse : non, le panafricanisme n''y suffit pas

**Argument 1 — l''expérience.** Le panafricanisme a soixante ans d''institutions,
et le commerce intra-africain reste faible. Les fédérations tentées — Mali-Sénégal
en 1960, la République arabe unie — ont éclaté en quelques mois.

**Argument 2 — les causes internes.** **Axelle Kabou** : tant que le fatalisme,
la corruption et la démission des élites demeurent, aucune union ne développera
rien. On n''additionne pas des faiblesses pour obtenir une force.

**Argument 3 — le développement est d''abord mental.** **Njoh Mouelle** : le
sous-développement est un état d''esprit, celui de la médiocrité acceptée. Le
passage à l''excellence est une exigence personnelle, qu''aucun traité ne décrète.
Et **Perroux** le disait déjà : des changements mentaux et sociaux.

**Argument 4 — l''unité peut servir d''alibi.** Invoquer l''unité africaine pour
différer les réformes intérieures, c''est transformer un projet en excuse.

### La synthèse

Le panafricanisme est une condition **nécessaire** et **non suffisante**.

Nécessaire, parce que les arguments de Diop et de Nkrumah sur la taille et le
poids n''ont pas été réfutés : ils se vérifient tous les jours dans les
négociations commerciales.

Non suffisante, parce qu''une union d''États mal gouvernés ne produirait qu''une
plus grande mauvaise gouvernance.

La conclusion la mieux armée est donc celle qui tient les deux bouts. Le
panafricanisme doit cesser d''être seulement une affaire de sommets de chefs
d''État pour devenir ce que **Sankara** en faisait : une pratique quotidienne —
produire et consommer africain, former ici, se soigner ici, refuser la dette qui
asservit.

Et **Ki-Zerbo** donne le critère : « quand on dort sur la natte des autres,
c''est comme si on dormait par terre ». Le développement n''est pas ce qu''on
reçoit, c''est ce qu''on tisse.

---

**Exercice corrigé**

*Distinguer croissance et développement, puis montrer par un exemple qu''un pays
peut connaître l''une sans l''autre.*

**Correction.**

*Les définitions.* La **croissance** est l''augmentation quantitative et durable
de la production d''un pays ; c''est une grandeur **mesurable**.

Le **développement**, selon **François Perroux**, est « la combinaison des
changements mentaux et sociaux d''une population qui la rendent apte à faire
croître cumulativement et durablement son produit réel global ». C''est une
transformation **qualitative**.

*La différence.* Trois écarts.

La croissance est quantitative, le développement qualitatif. La croissance peut
être passagère, le développement est cumulatif et durable. La croissance
concerne la production, le développement concerne la **population** — ses
mentalités, ses institutions, ses capacités.

*L''exemple d''une croissance sans développement.* Un pays découvre du pétrole. Sa
production double en cinq ans : la croissance est spectaculaire.

Mais l''extraction est faite par des entreprises étrangères avec des techniciens
étrangers, les revenus financent des importations de produits finis, l''école et
l''hôpital restent dans l''état où ils étaient, et aucun savoir-faire nouveau ne
se diffuse dans la population.

Le jour où le gisement s''épuise, le pays retrouve exactement la situation d''où
il était parti. Il a connu la croissance sans le développement, parce que rien
dans la population n''a été rendu **apte** à produire autrement. C''est ce que les
économistes nomment la malédiction des matières premières.

*L''exemple inverse est possible aussi : un pays qui alphabétise, forme des
techniciens et réforme ses institutions peut n''avoir aucune croissance pendant
dix ans, et se développer — la croissance arrivant ensuite, et durablement.*

*On retrouve ainsi Njoh Mouelle : le développement commence par un changement
mental, et c''est pourquoi il ne s''achète pas.*
', NULL, 32),
      (v_chapitre_id, 'Simulation : croissance ou développement ?', 7, 'interactif', '{
  "widget": "croissance-developpement",
  "consigne": "Tu diriges un pays africain pendant vingt ans et tu répartis ton budget entre six postes : l''extraction minière, les importations, l''école, la santé, les routes et la formation technique. Deux courbes avancent côte à côte — la production d''un côté, l''aptitude de la population de l''autre. Mise tout sur l''extraction : la production s''envole puis s''écroule quand le gisement s''épuise, et le pays se retrouve où il était parti. Mise tout sur l''école : rien ne bouge pendant dix ans, puis la courbe décolle et ne redescend plus. C''est la définition de Perroux en mouvement."
}', NULL, 10),
      (v_chapitre_id, 'Sujet type Baccalauréat — L''unité africaine et le développement', 8, 'texte', '
**Deuxième partie de l''épreuve — Évaluation de l''agir compétent — 9 points**

*En te fondant sur ta culture philosophique et dans le respect des règles de la
logique, est-il légitime de penser que l''unité africaine est la condition du
développement du continent ?*

---
---

## Corrigé

### I. Analyse et compréhension du sujet

**Les concepts-clés.** *Unité africaine* : le rassemblement politique et
économique des États du continent, projet du panafricanisme. *Condition* : ce
sans quoi une chose ne peut pas être. *Développement* : au sens de **Perroux**,
la combinaison des changements mentaux et sociaux d''une population qui la
rendent apte à faire croître durablement sa production — et non la simple
croissance.

**Reformulation.** Avons-nous de bonnes raisons de soutenir que l''Afrique ne
peut pas se développer sans s''unir ?

**Le présupposé.** Que l''obstacle principal au développement soit **extérieur**
aux sociétés africaines, à savoir leur morcellement.

**La thèse opposée.** Le développement dépend d''abord de causes internes, et
l''unité n''y changerait rien.

**Le problème.** Les conditions du développement de l''Afrique.

**La problématique.** Le morcellement du continent est-il la cause de son
sous-développement, ou n''en est-il qu''un symptôme parmi d''autres, derrière
lequel se cachent des causes internes ?

### II. Première tâche — la thèse : l''unité est la condition *(3 points)*

**Argument 1.** La taille. **Cheikh Anta Diop**, dans *Les fondements
économiques et culturels d''un État fédéral d''Afrique noire*, montre qu''aucun
État africain pris isolément n''atteint la dimension d''un marché moderne : la
balkanisation est le premier obstacle économique du continent.

**Argument 2.** Le poids. **Nkrumah**, dans *L''Afrique doit s''unir* : cinquante
États qui négocient séparément face aux mêmes puissances sont cinquante fois
plus faibles. Et dans *Le néo-colonialisme, dernier stade de l''impérialisme*, il
établit que l''indépendance politique sans souveraineté économique n''est qu''une
façade.

**Argument 3.** La mutualisation. Un barrage, un réseau ferroviaire continental,
une industrie pharmaceutique, une université de rang mondial dépassent les
moyens d''un État et seraient à la portée d''un ensemble.

*Transition.* Mais soixante ans d''institutions communes ont-ils produit ce
développement ?

### III. Deuxième tâche — l''antithèse : l''unité n''y suffit pas *(3 points)*

**Argument 1.** L''expérience. L''OUA, née en 1963, a laissé le commerce
intra-africain faible, et les fédérations tentées — la Fédération du Mali, la
République arabe unie — ont éclaté en quelques mois. La non-ingérence inscrite
dans sa charte l''a rendue muette devant les dictatures de ses propres membres.

**Argument 2.** Les causes internes. **Axelle Kabou**, dans *Et si l''Afrique
refusait le développement ?*, soutient que le fatalisme, la corruption et la
démission des élites pèsent plus que les frontières. On n''additionne pas des
faiblesses pour obtenir une force.

**Argument 3.** Le développement est d''abord mental. **Njoh Mouelle**, dans *De
la médiocrité à l''excellence*, tient le sous-développement pour un état
d''esprit, et le développement pour une exigence personnelle d''excellence
qu''aucun traité ne peut décréter. **Perroux** le disait dans sa définition même :
des changements mentaux et sociaux.

*Transition.* Faut-il alors renvoyer chaque pays à ses propres efforts, comme si
le morcellement n''était pour rien dans sa faiblesse ?

### IV. Troisième tâche — la synthèse *(3 points)*

**Premier moment — distinguer condition nécessaire et condition suffisante.**
C''est la clé du sujet. L''unité est **nécessaire** : les arguments de Diop et de
Nkrumah sur la taille et le poids n''ont jamais été réfutés, et chaque
négociation commerciale les confirme. Elle n''est pas **suffisante** : une union
d''États mal gouvernés ne produirait qu''une mauvaise gouvernance plus vaste.

**Deuxième moment — les deux thèses désignent deux obstacles réels.** Le
morcellement est un obstacle **externe**, la médiocrité des pratiques un
obstacle **interne**. Lever l''un sans l''autre ne mène nulle part, et chacun sert
volontiers d''excuse pour ne pas s''attaquer à l''autre.

**Troisième moment — déplacer le panafricanisme.** Tant qu''il reste une affaire
de sommets de chefs d''État, il reste un discours. **Sankara** en a montré
l''autre forme : produire et consommer africain, former ici, se soigner ici,
refuser la dette qui asservit. C''est un panafricanisme de pratiques, et il ne
demande pas d''attendre un traité. **Ki-Zerbo** en donne le critère : « quand on
dort sur la natte des autres, c''est comme si on dormait par terre ».

**Conclusion.** Il est légitime de penser que l''unité africaine est **une**
condition du développement, et non **la** condition. Les gradualistes de
Monrovia ont gagné la méthode, les unionistes de Casablanca avaient le bon
diagnostic ; l''Union africaine, avec son projet de marché commun, tente
aujourd''hui de leur donner raison aux deux. Mais rien de tout cela ne dispense
de ce que Njoh Mouelle demandait : le passage de la médiocrité à l''excellence,
qui commence dans les salles de classe avant de commencer dans les sommets.

---

### Ce que le correcteur attend

**La distinction nécessaire / suffisante.** C''est elle qui transforme une copie
hésitante en une synthèse ferme.

**Croissance et développement distingués**, avec la définition de Perroux. Une
copie qui les confond discute un autre sujet.

**Des auteurs africains cités avec leurs ouvrages** : Diop, Nkrumah, Njoh
Mouelle, Kabou, Ki-Zerbo, Sankara. Le programme camerounais y tient, et le
barème le récompense.
', NULL, 34),
      (v_chapitre_id, 'Quiz du chapitre 9', 9, 'quiz', '{
  "titre": "Vérifie que tu as compris",
  "questions": [
    {
      "question": "Pourquoi le panafricanisme est-il né dans la diaspora ?",
      "choix": [
        "Parce que les Africains n''y pensaient pas",
        "Parce que la traite avait effacé les appartenances particulières et ne laissait qu''un trait commun, la couleur : l''unité africaine est née de la négation avant d''être un projet",
        "Parce que les Européens l''ont inventé",
        "Parce que l''Afrique était trop grande"
      ],
      "bonne": 1,
      "explication": "Blyden, Williams, Du Bois, Garvey et Padmore sont tous nés hors d''Afrique. Un homme du Cameroun au XIXe siècle se savait Douala ou Bamiléké, pas « africain »."
    },
    {
      "question": "Qu''a changé le congrès panafricain de Manchester en 1945 ?",
      "choix": [
        "Rien",
        "L''objet de la revendication — désormais l''indépendance et non plus des droits — et les acteurs, les militants du continent devenant majoritaires",
        "Il a créé l''OUA",
        "Il a lancé la négritude"
      ],
      "bonne": 1,
      "explication": "Nkrumah pour la Gold Coast et Kenyatta pour le Kenya y sont au premier rang. Le panafricanisme passe de la diaspora au continent."
    },
    {
      "question": "Que voulait le groupe de Casablanca en 1961 ?",
      "choix": [
        "La coopération progressive entre États souverains",
        "L''union politique immédiate : les États-Unis d''Afrique, avec gouvernement, monnaie et armée communs",
        "Le retour aux royaumes précoloniaux",
        "L''indépendance des colonies portugaises"
      ],
      "bonne": 1,
      "explication": "Nkrumah, Sékou Touré, Modibo Keïta, Nasser. Le groupe de Monrovia — Houphouët-Boigny, Ahidjo, Senghor, Azikiwe — défendait au contraire la voie graduelle."
    },
    {
      "question": "Quels deux principes l''OUA a-t-elle inscrits en 1963 ?",
      "choix": [
        "Le marché commun et la monnaie unique",
        "L''intangibilité des frontières héritées de la colonisation et la non-ingérence dans les affaires intérieures",
        "Le droit d''intervention et le parlement africain",
        "La négritude et l''unité culturelle"
      ],
      "bonne": 1,
      "explication": "Le premier a évité les guerres de frontières ; le second l''a rendue muette devant les dictatures, d''où le surnom de « syndicat des chefs d''État »."
    },
    {
      "question": "Comment François Perroux définit-il le développement ?",
      "choix": [
        "L''augmentation du produit intérieur brut",
        "La combinaison des changements mentaux et sociaux d''une population qui la rendent apte à faire croître cumulativement et durablement son produit réel global",
        "L''industrialisation",
        "L''aide extérieure"
      ],
      "bonne": 1,
      "explication": "« Changements mentaux et sociaux » : la croissance est un chiffre, le développement une transformation. Un pays peut avoir l''une sans l''autre."
    },
    {
      "question": "Que soutient Njoh Mouelle dans De la médiocrité à l''excellence ?",
      "choix": [
        "Que l''Afrique doit s''unir politiquement",
        "Que le sous-développement est d''abord un état d''esprit, et le développement une exigence personnelle d''excellence",
        "Que la dette est une reconquête de l''Afrique",
        "Que l''Afrique a inventé la philosophie"
      ],
      "bonne": 1,
      "explication": "La deuxième formule est de Sankara. Njoh Mouelle déplace la question du politique vers le mental, et rejoint ainsi la définition de Perroux."
    },
    {
      "question": "Quelle est la conclusion la mieux armée sur l''unité et le développement ?",
      "choix": [
        "L''unité suffit",
        "L''unité est une condition nécessaire mais non suffisante : elle lève un obstacle externe, pas les obstacles internes",
        "L''unité est inutile",
        "Le développement est impossible"
      ],
      "bonne": 1,
      "explication": "Une union d''États mal gouvernés ne produirait qu''une mauvaise gouvernance plus vaste. Mais les arguments de Diop et Nkrumah sur la taille et le poids n''ont jamais été réfutés."
    }
  ]
}', NULL, 5);

    RAISE NOTICE '% : 9 leçons ajoutées au chapitre 9, Panafricanisme et développement de l''Afrique.', v_nom;
  END LOOP;
END $philo$;
