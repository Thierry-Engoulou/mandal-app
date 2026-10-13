import type {
  ProgrammeDetailResponse,
  ProgrammeChapitre,
  ProgrammeConcept,
} from "./use-student-programmes";

export const CURATED_COURSES_DETAILS: Record<string, ProgrammeDetailResponse> = {
  "curated-bac-maths": {
    programme: {
      id: "curated-bac-maths",
      titre: "Mathématiques Générales — Terminale C & D",
      description:
        "Analyse réelle, limites & continuité, dérivabilité, primitives & intégrales, fonctions exponentielles et logarithmiques, suites numériques, nombres complexes, probabilités et géométrie spatiale.",
      matiereNom: "Mathématiques",
      classeNom: "Baccalauréat (Séries C & D)",
    },
    chapitres: [
      {
        id: "bac-m-ch1",
        programme_id: "curated-bac-maths",
        titre: "Chapitre 1 : Limites, Continuité et Dérivabilité",
        ordre: 1,
        niveau: "Terminale C & D",
        concepts: [
          {
            id: "bac-m-c1-1",
            chapitre_id: "bac-m-ch1",
            titre: "Théorème des Valeurs Intermédiaires (TVI) & Continuité",
            ordre: 1,
            type_contenu: "texte",
            contenu_texte: `### 1. Continuité d'une fonction en un point et sur un intervalle

Une fonction f est dite continue en un point a de son ensemble de définition si :
$$\\lim_{x \\to a} f(x) = f(a)$$

#### Théorème des Valeurs Intermédiaires (TVI)
Si une fonction f est continue sur un intervalle fermé [a, b], alors pour tout réel k compris entre f(a) et f(b), il existe au moins un réel c dans [a, b] tel que :
$$f(c) = k$$

#### Corollaire (Théorème de la bijection)
Si de plus f est **strictement monotone** (strictement croissante ou strictement décroissante) sur [a, b], alors l'équation f(x) = k admet une **unique solution** dans [a, b].

> **Application BAC typique :** Démontrer qu'une équation $x^3 + 3x - 5 = 0$ admet une solution unique sur $[1, 2]$.`,
            media_url: null,
            duree_minutes: 25,
          },
          {
            id: "bac-m-c1-2",
            chapitre_id: "bac-m-ch1",
            titre: "Dérivabilité, Tangentes et Approximation Affine",
            ordre: 2,
            type_contenu: "texte",
            contenu_texte: `### Dérivabilité & Nombre Dérivé

Le nombre dérivé de f en a est la limite du taux d'accroissement :
$$f'(a) = \\lim_{h \\to 0} \\frac{f(a+h) - f(a)}{h}$$

#### Équation de la tangente
L'équation de la tangente à la courbe $C_f$ au point d'abscisse a est :
$$y = f'(a)(x - a) + f(a)$$

#### Dérivées usuelles et opérations
- $(u \\cdot v)' = u'v + uv'$
- $\\left(\\frac{u}{v}\\right)' = \\frac{u'v - uv'}{v^2}$
- $(u^n)' = n \\cdot u' \\cdot u^{n-1}$
- $(\\sqrt{u})' = \\frac{u'}{2\\sqrt{u}}$
- $(\\ln(u))' = \\frac{u'}{u}$
- $(e^u)' = u' \\cdot e^u$`,
            media_url: null,
            duree_minutes: 30,
          },
          {
            id: "bac-m-c1-3",
            chapitre_id: "bac-m-ch1",
            titre: "Visualisation Graphique Interactive des Tangentes",
            ordre: 3,
            type_contenu: "graphique",
            contenu_texte: JSON.stringify({
              title: "Courbe f(x) = x³ - 3x et sa tangente en x = 1",
              fn: "x^3 - 3*x",
              domain: [-3, 3],
              range: [-4, 4],
            }),
            media_url: null,
            duree_minutes: 15,
          },
        ],
      },
      {
        id: "bac-m-ch2",
        programme_id: "curated-bac-maths",
        titre: "Chapitre 2 : Fonctions Exponentielles et Logarithmiques",
        ordre: 2,
        niveau: "Terminale C & D",
        concepts: [
          {
            id: "bac-m-c2-1",
            chapitre_id: "bac-m-ch2",
            titre: "Fonction Logarithme Népérien (Propriétés et Limites Utiles)",
            ordre: 1,
            type_contenu: "texte",
            contenu_texte: `### Propriétés fondamentales de la fonction ln

La fonction $\\ln$ est la primitive sur $]0, +\\infty[$ de la fonction $x \\mapsto 1/x$ qui s'annule en 1.

#### Propriétés algébriques :
- $\\ln(ab) = \\ln(a) + \\ln(b)$
- $\\ln(a/b) = \\ln(a) - \\ln(b)$
- $\\ln(a^n) = n \\cdot \\ln(a)$
- $\\ln(1) = 0$ et $\\ln(e) = 1$

#### Croissances comparées incontournables au BAC :
- $\\lim_{x \\to +\\infty} \\frac{\\ln(x)}{x} = 0$
- $\\lim_{x \\to 0^+} x \\ln(x) = 0$
- $\\lim_{x \\to 0} \\frac{\\ln(1+x)}{x} = 1$`,
            media_url: null,
            duree_minutes: 35,
          },
          {
            id: "bac-m-c2-2",
            chapitre_id: "bac-m-ch2",
            titre: "Fonction Exponentielle & Équations Différentielles y' = ay",
            ordre: 2,
            type_contenu: "texte",
            contenu_texte: `### La fonction exponentielle $x \\mapsto e^x$

La fonction exponentielle est la bijection réciproque de la fonction $\\ln$.
- $e^{a+b} = e^a \\cdot e^b$
- $\\lim_{x \\to +\\infty} \\frac{e^x}{x^n} = +\\infty$
- $\\lim_{x \\to -\\infty} x^n e^x = 0$

#### Équation différentielle $y' = ay$ :
Les solutions sur $\\mathbb{R}$ sont les fonctions de la forme :
$$f(x) = C e^{ax} \\quad (C \\in \\mathbb{R})$$`,
            media_url: null,
            duree_minutes: 30,
          },
        ],
      },
      {
        id: "bac-m-ch3",
        programme_id: "curated-bac-maths",
        titre: "Chapitre 3 : Primitives et Calcul Intégral",
        ordre: 3,
        niveau: "Terminale C & D",
        concepts: [
          {
            id: "bac-m-c3-1",
            chapitre_id: "bac-m-ch3",
            titre: "Intégration par Parties & Calcul d'Aires",
            ordre: 1,
            type_contenu: "texte",
            contenu_texte: `### Formule d'intégration par parties (IPP)

Soient u et v deux fonctions dérivables sur [a, b] telles que u' et v' soient continues :
$$\\int_a^b u'(x) v(x) dx = [u(x)v(x)]_a^b - \\int_a^b u(x) v'(x) dx$$

#### Règle mnémotechnique ALPES pour le choix de u et v :
- **A**rcsin / Arccos
- **L**ogarithme
- **P**olynôme
- **E**xponentielle
- **S**inus / Cosinus`,
            media_url: null,
            duree_minutes: 40,
          },
        ],
      },
    ],
  },
  "curated-bac-physique": {
    programme: {
      id: "curated-bac-physique",
      titre: "Physique Générale — Terminale C, D & TI",
      description:
        "Cinématique et dynamique newtonienne, mouvement dans un champ uniforme, oscillateurs mécaniques, circuits RLC en régime sinusoïdal forcé, résonance, optique ondulatoire et interférences.",
      matiereNom: "Physique-Chimie",
      classeNom: "Baccalauréat (Séries C & D)",
    },
    chapitres: [
      {
        id: "bac-p-ch1",
        programme_id: "curated-bac-physique",
        titre: "Chapitre 1 : Mouvement d'un Projectile dans un Champ de Pesanteur",
        ordre: 1,
        niveau: "Terminale C & D",
        concepts: [
          {
            id: "bac-p-c1-1",
            chapitre_id: "bac-p-ch1",
            titre: "Lois de Newton & Équations Horaires de la Trajectoire",
            ordre: 1,
            type_contenu: "texte",
            contenu_texte: `### Application du 2ème Principe de Newton (PFD)

Système : projectile de masse m.
Référentiel : terrestre supposé galiléen.
Bilan des forces : seul le poids $\\vec{P} = m\\vec{g}$ est pris en compte (frottements négligés).

$$\\sum \\vec{F}_{ext} = m\\vec{a} \\implies m\\vec{g} = m\\vec{a} \\implies \\vec{a} = \\vec{g}$$

#### Vecteur accélération dans le repère $(O, \\vec{i}, \\vec{j})$ :
- $a_x(t) = 0$
- $a_y(t) = -g$

#### Équations horaires de la vitesse (avec angle de tir $\\alpha$ et vitesse initiale $V_0$) :
- $v_x(t) = V_0 \\cos(\\alpha)$
- $v_y(t) = -gt + V_0 \\sin(\\alpha)$

#### Équation cartésienne de la trajectoire :
$$y(x) = -\\frac{g}{2 V_0^2 \\cos^2(\\alpha)} x^2 + x \\tan(\\alpha)$$
C'est l'équation d'une parabole contenue dans le plan vertical de tir.`,
            media_url: null,
            duree_minutes: 30,
          },
          {
            id: "bac-p-c1-2",
            chapitre_id: "bac-p-ch1",
            titre: "Simulation de Tir Balistique Interactive (GeoGebra)",
            ordre: 2,
            type_contenu: "simulation",
            contenu_texte: null,
            media_url: "https://www.geogebra.org/material/iframe/id/bkmqg7fv",
            duree_minutes: 20,
          },
        ],
      },
      {
        id: "bac-p-ch2",
        programme_id: "curated-bac-physique",
        titre: "Chapitre 2 : Circuits RLC en Régime Forcé & Résonance",
        ordre: 2,
        niveau: "Terminale C & D",
        concepts: [
          {
            id: "bac-p-c2-1",
            chapitre_id: "bac-p-ch2",
            titre: "Impédance, Déphasage et Fréquence de Résonance",
            ordre: 1,
            type_contenu: "texte",
            contenu_texte: `### Circuit RLC série alimenté par une tension sinusoïdale

Tension d'alimentation : $u(t) = U_m \\cos(\\omega t)$.
Courant résultant : $i(t) = I_m \\cos(\\omega t - \\varphi)$.

#### Impédance du circuit RLC :
$$Z = \\sqrt{R^2 + \\left(L\\omega - \\frac{1}{C\\omega}\\right)^2}$$

#### Condition de résonance d'intensité :
La résonance d'intensité a lieu lorsque l'impédance Z est minimale, soit $L\\omega - \\frac{1}{C\\omega} = 0$.
$$\\omega_0 = \\frac{1}{\\sqrt{LC}} \\quad \\text{ou} \\quad f_0 = \\frac{1}{2\\pi\\sqrt{LC}}$$`,
            media_url: null,
            duree_minutes: 35,
          },
        ],
      },
    ],
  },
  "curated-prob-maths": {
    programme: {
      id: "curated-prob-maths",
      titre: "Mathématiques Générales — Première C & D",
      description:
        "Polynômes du second degré, barycentres, produit scalaire, trigonométrie, dérivation et études de fonctions rationnelles.",
      matiereNom: "Mathématiques",
      classeNom: "Probatoire (Séries C & D)",
    },
    chapitres: [
      {
        id: "prob-m-ch1",
        programme_id: "curated-prob-maths",
        titre: "Chapitre 1 : Trinôme du Second Degré & Équations Inéquations",
        ordre: 1,
        niveau: "Première C & D",
        concepts: [
          {
            id: "prob-m-c1-1",
            chapitre_id: "prob-m-ch1",
            titre: "Discriminant Delta, Factorisation et Signe",
            ordre: 1,
            type_contenu: "texte",
            contenu_texte: `### Étude du trinôme $P(x) = ax^2 + bx + c$ ($a \\neq 0$)

Le discriminant est donné par : $\\Delta = b^2 - 4ac$.

1. **Si $\\Delta > 0$** : Deux racines réelles distinctes :
   $$x_1 = \\frac{-b - \\sqrt{\\Delta}}{2a}, \\quad x_2 = \\frac{-b + \\sqrt{\\Delta}}{2a}$$
   Forme factorisée : $P(x) = a(x - x_1)(x - x_2)$.
2. **Si $\\Delta = 0$** : Une racine double $x_0 = -\\frac{b}{2a}$.
3. **Si $\\Delta < 0$** : Aucune racine réelle. P(x) est du signe de a sur $\\mathbb{R}$.`,
            media_url: null,
            duree_minutes: 30,
          },
        ],
      },
    ],
  },
  "curated-bepc-maths": {
    programme: {
      id: "curated-bepc-maths",
      titre: "Mathématiques — Classe de 3ème / BEPC",
      description:
        "Calcul numérique, théorème de Thalès, trigonométrie dans le triangle rectangle, équations et inéquations du premier degré, géométrie dans l'espace.",
      matiereNom: "Mathématiques",
      classeNom: "BEPC (3ème)",
    },
    chapitres: [
      {
        id: "bepc-m-ch1",
        programme_id: "curated-bepc-maths",
        titre: "Chapitre 1 : Théorème de Pythagore et Théorème de Thalès",
        ordre: 1,
        niveau: "3ème / BEPC",
        concepts: [
          {
            id: "bepc-m-c1-1",
            chapitre_id: "bepc-m-ch1",
            titre: "Théorème de Thalès et sa Réciproque",
            ordre: 1,
            type_contenu: "texte",
            contenu_texte: `### Énoncé du Théorème de Thalès

Soient deux droites (d) et (d') sécantes en un point A.
Soient B et M deux points de (d), distincts de A.
Soient C et N deux points de (d'), distincts de A.
Si les droites (BC) et (MN) sont parallèles, alors :
$$\\frac{AM}{AB} = \\frac{AN}{AC} = \\frac{MN}{BC}$$

#### Réciproque :
Si les points A, M, B d'une part, et A, N, C d'autre part, sont alignés dans le même ordre, et si $\\frac{AM}{AB} = \\frac{AN}{AC}$, alors les droites (MN) et (BC) sont parallèles.`,
            media_url: null,
            duree_minutes: 25,
          },
        ],
      },
    ],
  },
  "curated-enspd-maths": {
    programme: {
      id: "curated-enspd-maths",
      titre: "Algèbre Linéaire & Analyse Avancée (Concours ENSPD)",
      description:
        "Espaces vectoriels, matrices et déterminants, diagonalisation, développements limités, équations différentielles linéaires d'ordre 2.",
      matiereNom: "Mathématiques",
      classeNom: "Concours ENSPD (Polytechnique)",
    },
    chapitres: [
      {
        id: "enspd-m-ch1",
        programme_id: "curated-enspd-maths",
        titre: "Chapitre 1 : Espaces Vectoriels et Applications Linéaires",
        ordre: 1,
        niveau: "Prépa ENSPD",
        concepts: [
          {
            id: "enspd-m-c1-1",
            chapitre_id: "enspd-m-ch1",
            titre: "Sous-espaces, Familles Libres et Théorème du Rang",
            ordre: 1,
            type_contenu: "texte",
            contenu_texte: `### Théorème du Rang (Fondamental pour le Concours ENSPD)

Soit E un espace vectoriel de dimension finie et $f : E \\to F$ une application linéaire.
Alors $\\text{Im}(f)$ est de dimension finie et l'on a :
$$\\dim(E) = \\dim(\\ker(f)) + \\text{rg}(f)$$

#### Conséquence importante :
Si $\\dim(E) = \\dim(F)$, alors f est injective $\\iff$ f est surjective $\\iff$ f est bijective.`,
            media_url: null,
            duree_minutes: 40,
          },
        ],
      },
    ],
  },
};
