-- ============================================================================
-- MANDAL — Physique Terminale : chapitre 12, Les oscillateurs électriques
-- Module 3 : Électricité, évolutions temporelles des circuits électriques
-- 6 leçons.
--
-- Ce fichier remplit LES DEUX CLASSES a la fois : Terminale C et Terminale D.
-- Autonome : il cree lui-meme la matiere, les classes, les programmes et le
-- chapitre s'ils n'existent pas encore. Lancez-le seul, dans n'importe quel
-- ordre.
-- Idempotent : si le chapitre contient deja des lecons, rien n'est ajoute.
-- ============================================================================
DO $ptc$
DECLARE
  v_noms text[] := ARRAY['Terminale C', 'Terminale D'];
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
  -- la matiere, une seule fois
  INSERT INTO public.matieres (nom) VALUES ('Physique') ON CONFLICT (nom) DO NOTHING;
  SELECT id INTO v_matiere_id FROM public.matieres WHERE nom = 'Physique';

  -- l'etablissement, deduit de la table des classes
  SELECT count(DISTINCT etablissement_id) INTO v_nb_etabs FROM public.classes;
  IF v_nb_etabs <> 1 THEN
    RAISE EXCEPTION 'Impossible de deduire l''etablissement : % etablissement(s) distinct(s) dans public.classes.', v_nb_etabs;
  END IF;
  SELECT etablissement_id INTO v_etab_id FROM public.classes LIMIT 1;

  -- on refait le meme travail pour la Terminale C puis pour la Terminale D
  FOR v_i IN 1..2 LOOP
    v_nom := v_noms[v_i];
    v_lettre := v_lettres[v_i];

    -- 1. le programme existe-t-il deja ?
    SELECT p.id INTO v_programme_id FROM public.programmes p
    WHERE p.titre = 'Physique — ' || v_nom;

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
      VALUES (v_matiere_id, v_classe_id, v_etab_id, 'Physique — ' || v_nom,
              'Programme officiel de Physique, classe de Terminale ' || v_lettre ||
              ' (Cameroun) — 4 modules, 22 chapitres.')
      RETURNING id INTO v_programme_id;
      RAISE NOTICE 'Programme "Physique — %" cree.', v_nom;
    END IF;

    -- 3. le chapitre existe-t-il deja ?
    SELECT id INTO v_chapitre_id FROM public.chapitres
    WHERE programme_id = v_programme_id AND ordre = 12;

    -- 4. sinon on le cree
    IF v_chapitre_id IS NULL THEN
      INSERT INTO public.chapitres (programme_id, titre, ordre, niveau)
      VALUES (v_programme_id, 'Les oscillateurs électriques', 12, 'Module 3 : Électricité, évolutions temporelles des circuits électriques')
      RETURNING id INTO v_chapitre_id;
      RAISE NOTICE '% : chapitre 12 cree.', v_nom;
    END IF;

    -- 5. les lecons
    SELECT count(*) INTO v_deja FROM public.concepts WHERE chapitre_id = v_chapitre_id;
    IF v_deja > 0 THEN
      RAISE NOTICE '% : chapitre 12 contient deja % lecon(s) — aucun ajout.', v_nom, v_deja;
      CONTINUE;
    END IF;

    INSERT INTO public.concepts
      (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes) VALUES
      (v_chapitre_id, 'Le circuit RC et le circuit RL', 1, 'texte', 'Quand on ferme un interrupteur, le courant ne s''installe pas instantanément. Il y a un bref moment de transition, appelé régime transitoire, et il obéit à une loi exponentielle.

## La charge d''un condensateur à travers une résistance

Un générateur de tension constante $E$, une résistance $R$ et un condensateur $C$ en série. À $t = 0$ on ferme l''interrupteur, le condensateur étant initialement déchargé.

La loi des mailles donne $E = u_{R} + u_{C}$, soit $E = Ri + u_{C}$.

Avec $i = C\dfrac{du_{C}}{dt}$, on obtient
$$RC\,\dfrac{du_{C}}{dt} + u_{C} = E$$

C''est une équation différentielle du premier ordre. Sa solution, avec $u_{C}(0) = 0$, est
$$u_{C}(t) = E\left(1 - e^{-t/\tau}\right) \qquad \text{avec} \qquad \tau = RC$$

Le courant vaut alors
$$i(t) = \dfrac{E}{R}\,e^{-t/\tau}$$

Observe ce qui se passe. À l''instant initial, le condensateur est vide, il se comporte comme un fil, et le courant est maximal à $\dfrac{E}{R}$. À la fin, le condensateur est plein, il bloque le courant, et $u_{C} = E$.

## La constante de temps

Le produit $\tau = RC$ est homogène à un temps, comme tu l''as vérifié au chapitre sur les dimensions.

Elle se lit sur la courbe de deux façons. Au bout de $\tau$, la tension a atteint $63\%$ de sa valeur finale, car $1 - e^{-1} = 0{,}63$. Et la tangente à l''origine coupe l''asymptote à la date $t = \tau$.

On considère le régime permanent atteint au bout de $5\tau$, car il reste alors moins de $1\%$ d''écart.

## La décharge

On remplace le générateur par un fil. L''équation devient $RC\dfrac{du_{C}}{dt} + u_{C} = 0$, de solution
$$u_{C}(t) = E\,e^{-t/\tau}$$

Au bout de $\tau$, il ne reste que $37\%$ de la tension initiale.

## Le circuit RL

Une bobine d''inductance $L$ s''oppose aux variations du courant qui la traverse. Sa tension vaut
$$u_{L} = L\,\dfrac{di}{dt} + r\,i$$
où $r$ est sa résistance interne, souvent négligée.

Pour un circuit $R$, $L$ et générateur $E$ en série, la loi des mailles donne
$$L\,\dfrac{di}{dt} + Ri = E$$

de solution
$$i(t) = \dfrac{E}{R}\left(1 - e^{-t/\tau}\right) \qquad \text{avec} \qquad \tau = \dfrac{L}{R}$$

La structure est la même qu''avec le condensateur, mais les rôles sont échangés. Ici c''est le **courant** qui ne peut pas sauter brutalement, parce qu''il faudrait une tension infinie aux bornes de la bobine.

Retiens ces deux règles pour écrire les conditions initiales. La tension d''un condensateur est continue, le courant dans une bobine est continu.

## Exercice d''application

Un circuit RC comporte $R = 10\ \text{k}\Omega$ et $C = 47\ \mu$F, alimenté par $E = 6{,}0$ V. Calcule la constante de temps, la tension au bout de $0{,}47$ s, et la durée au bout de laquelle le condensateur est pratiquement chargé.

Correction. La constante de temps vaut
$$\tau = RC = 10 \times 10^{3} \times 47 \times 10^{-6} = 0{,}47\ \text{s}$$

Au bout de $t = 0{,}47$ s, soit exactement $\tau$,
$$u_{C} = 6{,}0 \times (1 - e^{-1}) = 6{,}0 \times 0{,}632 \approx 3{,}8\ \text{V}$$

La charge est pratiquement terminée au bout de $5\tau = 5 \times 0{,}47 \approx 2{,}4$ s.', NULL, 15),
      (v_chapitre_id, 'Les oscillations libres du circuit LC et RLC', 2, 'texte', 'Associe un condensateur chargé et une bobine. L''énergie va passer de l''un à l''autre, aller et retour, exactement comme entre le ressort et la masse d''un pendule.

## Le circuit LC idéal

Un condensateur de capacité $C$, chargé sous la tension $U_{0}$, est brusquement relié à une bobine d''inductance $L$ de résistance nulle.

La loi des mailles donne $u_{C} + u_{L} = 0$, soit $u_{C} + L\dfrac{di}{dt} = 0$.

Avec $i = C\dfrac{du_{C}}{dt}$, on obtient
$$LC\,\dfrac{d^{2}u_{C}}{dt^{2}} + u_{C} = 0$$

soit
$$\ddot{u}_{C} + \dfrac{1}{LC}\,u_{C} = 0$$

Tu reconnais la forme $\ddot{x} + \omega^{2}x = 0$. La tension oscille donc sinusoïdalement, avec
$$\omega_{0} = \dfrac{1}{\sqrt{LC}} \qquad \text{et} \qquad T_{0} = 2\pi\sqrt{LC}$$

Cette dernière relation est la **formule de Thomson**, à connaître absolument.

## L''énergie dans le circuit LC

Le condensateur stocke $W_{C} = \dfrac{1}{2}Cu^{2}$ dans son champ électrique. La bobine stocke $W_{L} = \dfrac{1}{2}Li^{2}$ dans son champ magnétique.

Sans résistance, la somme reste constante :
$$W = \dfrac{1}{2}Cu^{2} + \dfrac{1}{2}Li^{2} = \text{constante}$$

L''énergie passe d''une forme à l''autre deux fois par période. Quand le condensateur est plein, le courant est nul. Quand le courant est maximal, le condensateur est vide.

## Les analogies électromécaniques

Compare avec le pendule élastique et tu verras que c''est la même physique.

La charge $q$ joue le rôle de l''élongation $x$. Le courant $i$ joue le rôle de la vitesse $v$. L''inductance $L$ joue le rôle de la masse $m$. L''inverse de la capacité, $\dfrac{1}{C}$, joue le rôle de la raideur $k$. La résistance $R$ joue le rôle du coefficient de frottement.

Vérifie sur les périodes. Pour le ressort, $T = 2\pi\sqrt{\dfrac{m}{k}}$. Pour le circuit, $T = 2\pi\sqrt{\dfrac{L}{1/C}} = 2\pi\sqrt{LC}$. C''est exactement la même formule.

Cette analogie n''est pas une coïncidence. Les deux systèmes obéissent à la même équation différentielle, donc ils se comportent pareil.

## Le circuit RLC série en oscillations libres

Dans la réalité, la bobine a une résistance, et il y a souvent une résistance ajoutée. L''équation devient
$$L\,\ddot{q} + R\,\dot{q} + \dfrac{q}{C} = 0$$

Le terme en $R$ dissipe l''énergie par effet Joule. Les oscillations s''amortissent, exactement comme un pendule dans l''air.

On retrouve les trois régimes. Si $R$ est faible, le régime est **pseudo-périodique** et l''amplitude décroît exponentiellement. Si $R$ est grande, le régime est **apériodique** et la tension revient à zéro sans osciller. Entre les deux se trouve le régime **critique**.

La condition de passage se fait pour
$$R_{c} = 2\sqrt{\dfrac{L}{C}}$$

## Exercice d''application

Un circuit oscillant comprend une bobine de $L = 0{,}10$ H et un condensateur de $C = 10\ \mu$F. Calcule la période propre et la fréquence. Quelle résistance critique faudrait-il pour supprimer les oscillations ?

Correction. La période vaut
$$T_{0} = 2\pi\sqrt{LC} = 2\pi\sqrt{0{,}10 \times 10 \times 10^{-6}} = 2\pi\sqrt{1{,}0 \times 10^{-6}} = 2\pi \times 1{,}0 \times 10^{-3}$$

soit $T_{0} \approx 6{,}3 \times 10^{-3}$ s, c''est-à-dire environ $6{,}3$ ms.

La fréquence vaut $N_{0} = \dfrac{1}{T_{0}} \approx 159$ Hz.

La résistance critique vaut
$$R_{c} = 2\sqrt{\dfrac{L}{C}} = 2\sqrt{\dfrac{0{,}10}{10 \times 10^{-6}}} = 2\sqrt{10^{4}} = 2 \times 100 = 200\ \Omega$$

Au-delà de $200\ \Omega$, le circuit ne produira plus d''oscillations.', NULL, 15),
      (v_chapitre_id, 'Observe un circuit RLC qui oscille', 3, 'interactif', '{
  "widget": "circuit-rlc",
  "consigne": "Fais varier $L$, $C$ et surtout $R$, puis regarde la tension évoluer. Vérifie la formule de Thomson en mesurant la pseudo-période. Augmente ensuite $R$ jusqu''à faire disparaître complètement les oscillations : tu viens de franchir le régime critique."
}', NULL, 10),
      (v_chapitre_id, 'Oscillations forcées et résonance électrique', 4, 'texte', 'Un générateur basse fréquence impose sa fréquence au circuit RLC. L''amplitude du courant dépend alors fortement de cette fréquence, et passe par un maximum spectaculaire.

## Le régime sinusoïdal forcé

On applique $u(t) = U_{m}\cos(\omega t)$ aux bornes d''un circuit RLC série. En régime permanent, le courant s''établit à la même pulsation :
$$i(t) = I_{m}\cos(\omega t + \varphi)$$

Deux inconnues restent à trouver, l''amplitude $I_{m}$ et le déphasage $\varphi$.

## L''impédance

L''**impédance** $Z$ du circuit est le rapport des amplitudes, ou des valeurs efficaces :
$$Z = \dfrac{U_{m}}{I_{m}} = \dfrac{U}{I}$$

Elle s''exprime en ohms. C''est la généralisation de la résistance au régime alternatif.

Pour les trois dipôles de base, le résistor a pour impédance $R$, la bobine parfaite a pour impédance $L\omega$ et le condensateur a pour impédance $\dfrac{1}{C\omega}$.

Remarque que l''impédance de la bobine **augmente** avec la fréquence, alors que celle du condensateur **diminue**. La bobine bloque le haut, le condensateur bloque le bas.

## La construction de Fresnel

Pour le circuit série, le courant est commun aux trois dipôles, donc on le prend comme référence et on place son vecteur sur l''axe horizontal.

La tension aux bornes du résistor est **en phase** avec le courant, son vecteur est horizontal, de longueur $RI$.

La tension aux bornes de la bobine est en **avance** de $\dfrac{\pi}{2}$, son vecteur pointe vers le haut, de longueur $L\omega I$.

La tension aux bornes du condensateur est en **retard** de $\dfrac{\pi}{2}$, son vecteur pointe vers le bas, de longueur $\dfrac{I}{C\omega}$.

La tension totale est la somme vectorielle. Les deux vecteurs verticaux étant opposés, le théorème de Pythagore donne
$$U = I\sqrt{R^{2} + \left(L\omega - \dfrac{1}{C\omega}\right)^{2}}$$

d''où l''impédance
$$Z = \sqrt{R^{2} + \left(L\omega - \dfrac{1}{C\omega}\right)^{2}}$$

et le déphasage
$$\tan\varphi = \dfrac{L\omega - \dfrac{1}{C\omega}}{R}$$

## La résonance d''intensité

L''intensité vaut $I = \dfrac{U}{Z}$. Elle est maximale quand $Z$ est minimale, donc quand le terme entre parenthèses s''annule :
$$L\omega - \dfrac{1}{C\omega} = 0 \qquad \text{soit} \qquad \omega_{0} = \dfrac{1}{\sqrt{LC}}$$

C''est la **résonance d''intensité**. On retrouve exactement la pulsation propre du circuit.

À la résonance, l''impédance se réduit à $Z = R$, l''intensité vaut $I_{\max} = \dfrac{U}{R}$, et le déphasage est nul : le circuit se comporte comme une simple résistance.

## La bande passante et le facteur de qualité

La **bande passante** à trois décibels est l''intervalle de pulsations pour lequel
$$I \geq \dfrac{I_{\max}}{\sqrt{2}}$$

Sa largeur vaut
$$\Delta\omega = \dfrac{R}{L}$$

Le **facteur de qualité** mesure l''acuité de la résonance :
$$Q = \dfrac{\omega_{0}}{\Delta\omega} = \dfrac{L\omega_{0}}{R} = \dfrac{1}{R}\sqrt{\dfrac{L}{C}}$$

Un $Q$ élevé signifie une résonance aiguë, donc un circuit très sélectif. C''est ce qu''on recherche dans un poste de radio pour isoler une station sans entendre les voisines.

## La puissance en régime sinusoïdal

La puissance moyenne consommée vaut
$$P = U\,I\cos\varphi$$

Le terme $\cos\varphi$ s''appelle le **facteur de puissance**. Seul le résistor consomme réellement, la bobine et le condensateur se contentent d''échanger de l''énergie avec le générateur.

À la résonance, $\varphi = 0$ donc $\cos\varphi = 1$, et la puissance est maximale. C''est pourquoi les installations industrielles cherchent à relever leur facteur de puissance, en ajoutant des condensateurs.

## Exercice d''application

Un circuit RLC série comporte $R = 20\ \Omega$, $L = 0{,}20$ H et $C = 5{,}0\ \mu$F. Il est alimenté sous une tension efficace de $12$ V. Calcule la fréquence de résonance, l''intensité à la résonance, et le facteur de qualité.

Correction. La pulsation de résonance vaut
$$\omega_{0} = \dfrac{1}{\sqrt{LC}} = \dfrac{1}{\sqrt{0{,}20 \times 5{,}0 \times 10^{-6}}} = \dfrac{1}{\sqrt{1{,}0 \times 10^{-6}}} = 1000\ \text{rad/s}$$

La fréquence vaut $N_{0} = \dfrac{1000}{2\pi} \approx 159$ Hz.

À la résonance, l''impédance se réduit à $R$, donc
$$I_{\max} = \dfrac{U}{R} = \dfrac{12}{20} = 0{,}60\ \text{A}$$

Le facteur de qualité vaut
$$Q = \dfrac{L\omega_{0}}{R} = \dfrac{0{,}20 \times 1000}{20} = 10$$

Un facteur de qualité de $10$ donne une bande passante $\Delta\omega = \dfrac{\omega_{0}}{Q} = 100$ rad/s. La résonance est donc assez aiguë.

Remarque au passage que la tension aux bornes de la bobine vaut $L\omega_{0}I = 0{,}20 \times 1000 \times 0{,}60 = 120$ V, soit dix fois la tension d''alimentation. C''est la surtension à la résonance, et elle vaut exactement $Q$ fois la tension du générateur. Attention aux claquages.', NULL, 15),
      (v_chapitre_id, 'Trouve la résonance', 5, 'interactif', '{
  "widget": "resonance-rlc",
  "consigne": "Balaie la fréquence du générateur et regarde la courbe de l''intensité se construire. Repère le sommet, c''est la résonance. Diminue ensuite la résistance : la courbe devient-elle plus pointue ou plus plate ? Déduis-en le lien entre $R$ et le facteur de qualité."
}', NULL, 10),
      (v_chapitre_id, 'Quiz du chapitre 12', 6, 'quiz', '{
  "titre": "Vérifie que tu as compris",
  "questions": [
    {
      "question": "Dans un circuit RC, que vaut la tension aux bornes du condensateur au bout d''une constante de temps ?",
      "choix": [
        "100 % de la tension finale",
        "63 % de la tension finale",
        "37 % de la tension finale",
        "50 % de la tension finale"
      ],
      "bonne": 1,
      "explication": "Au bout de $\\tau$, on a $u_C = E(1 - e^{-1}) = 0{,}63\\,E$. Les 37 % correspondent à ce qu''il reste lors d''une décharge, pas à ce qui est atteint lors d''une charge."
    },
    {
      "question": "Quelle est la période propre d''un circuit LC ?",
      "choix": [
        "$T = 2\\pi\\sqrt{L/C}$",
        "$T = 2\\pi\\sqrt{LC}$",
        "$T = 2\\pi LC$",
        "$T = \\sqrt{LC}/(2\\pi)$"
      ],
      "bonne": 1,
      "explication": "C''est la formule de Thomson, $T_0 = 2\\pi\\sqrt{LC}$. Elle découle de l''équation différentielle $\\ddot{u} + u/(LC) = 0$, dont la pulsation est $\\omega_0 = 1/\\sqrt{LC}$."
    },
    {
      "question": "Dans l''analogie électromécanique, à quoi correspond l''inductance $L$ ?",
      "choix": [
        "À la raideur du ressort",
        "À la masse",
        "Au coefficient de frottement",
        "À l''amplitude"
      ],
      "bonne": 1,
      "explication": "L''inductance joue le rôle de la masse, car elle s''oppose aux variations du courant comme la masse s''oppose aux variations de vitesse. C''est $1/C$ qui joue le rôle de la raideur $k$, et $R$ celui du frottement."
    },
    {
      "question": "À la résonance d''intensité d''un circuit RLC série, que vaut l''impédance ?",
      "choix": [
        "Elle est maximale",
        "Elle vaut $R$",
        "Elle est nulle",
        "Elle vaut $L\\omega$"
      ],
      "bonne": 1,
      "explication": "À la résonance, $L\\omega = 1/(C\\omega)$, donc le terme réactif s''annule et il ne reste que $Z = R$. L''impédance est minimale, l''intensité est maximale et le déphasage est nul."
    },
    {
      "question": "On diminue la résistance d''un circuit RLC en régime forcé. Que devient la résonance ?",
      "choix": [
        "Plus plate et plus large",
        "Plus aiguë et plus étroite",
        "Elle disparaît",
        "Elle se déplace vers les hautes fréquences"
      ],
      "bonne": 1,
      "explication": "Le facteur de qualité vaut $Q = L\\omega_0/R$. Diminuer $R$ augmente $Q$, donc la bande passante $\\Delta\\omega = R/L$ se rétrécit et le pic devient plus haut et plus pointu."
    },
    {
      "question": "Que vaut le facteur de puissance d''un circuit RLC à la résonance ?",
      "choix": [
        "0",
        "0,5",
        "1",
        "$\\sqrt{2}$"
      ],
      "bonne": 2,
      "explication": "À la résonance le déphasage $\\varphi$ est nul, donc $\\cos\\varphi = 1$. La puissance consommée $P = UI\\cos\\varphi$ est alors maximale, le circuit se comportant comme une simple résistance."
    }
  ]
}', NULL, 5);

    RAISE NOTICE '% : chapitre 12, Les oscillateurs électriques — 6 lecons ajoutees.', v_nom;
  END LOOP;
END $ptc$;
