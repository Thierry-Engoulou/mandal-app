import { useState } from "react";
import { Board, Choice, Ctrl, PALETTE, Panel, Stat, Verdict, fmt } from "./controls";

/** Informatique 1ère A, C et D — chapitres 18 à 20 : image, infographie, son et vidéo. */

function clamp(v: number, lo: number, hi: number) {
  return Math.max(lo, Math.min(hi, v));
}

/* ------------------------------------------------------------------ */
/* Chapitre 18 — Définition, résolution et poids                       */
/* ------------------------------------------------------------------ */

export function PixelsDefinition() {
  const [cote, setCote] = useState(24);
  const [ppp, setPpp] = useState(300);
  const [profondeur, setProfondeur] = useState(24);

  const n = clamp(Math.round(cote), 4, 48);
  const cotePx = n * 50; // la définition réelle de l'image, en pixels
  const pixels = cotePx * cotePx;
  const octets = (pixels * profondeur) / 8;
  const mo = octets / 1048576;

  // la même image imprimée à ppp points par pouce
  const pouces = cotePx / ppp;
  const cm = pouces * 2.54;
  const fin = ppp >= 300;
  const cote4 = Math.min(cm * 2.1, 104);

  const W = 440;
  const H = 242;
  const taille = 180 / n;

  // un disque dessiné sur la grille : plus n est grand, plus il est net
  const centre = (n - 1) / 2;
  const rayon = n * 0.42;

  return (
    <div className="space-y-3">
      <Panel>
        <Ctrl
          label="Définition de l'image (côté)"
          value={n}
          min={4}
          max={48}
          step={1}
          onChange={setCote}
          display={`${cotePx} × ${cotePx} px`}
        />
        <Ctrl
          label="Résolution d'impression"
          value={ppp}
          min={36}
          max={600}
          step={6}
          onChange={setPpp}
          display={`${ppp} ppp`}
          color={PALETTE.orange}
        />
      </Panel>

      <Choice<"1" | "8" | "24">
        label="Profondeur de couleur"
        value={profondeur === 1 ? "1" : profondeur === 8 ? "8" : "24"}
        options={[
          { value: "1", label: "1 bit — 2 couleurs" },
          { value: "8", label: "8 bits — 256" },
          { value: "24", label: "24 bits — 16,7 M" },
        ]}
        onChange={(v) => setProfondeur(Number(v))}
      />

      <Board width={W} height={H}>
        <rect width={W} height={H} fill="#ffffff" />
        <text x={110} y={16} textAnchor="middle" fontSize={10} fontWeight={700} fill={PALETTE.ink}>
          {cotePx} × {cotePx} pixels
        </text>
        <text x={110} y={28} textAnchor="middle" fontSize={8} fill={PALETTE.slate}>
          détail agrandi : la grille des pixels
        </text>

        {Array.from({ length: n }).map((_, j) =>
          Array.from({ length: n }).map((__, i) => {
            const d = Math.sqrt((i - centre) ** 2 + (j - centre) ** 2);
            const dedans = d <= rayon;
            const couleur = !dedans
              ? "#ffffff"
              : profondeur === 1
                ? "#0f172a"
                : profondeur === 8
                  ? d > rayon - 1.2
                    ? "#94a3b8"
                    : "#334155"
                  : `hsl(217 70% ${clamp(70 - (rayon - d) * 6, 25, 70)}%)`;
            return (
              <rect
                key={`${i}-${j}`}
                x={20 + i * taille}
                y={36 + j * taille}
                width={taille}
                height={taille}
                fill={couleur}
                stroke={n <= 24 ? "#e2e8f0" : "none"}
                strokeWidth={0.4}
              />
            );
          }),
        )}

        <text x={330} y={54} textAnchor="middle" fontSize={10} fontWeight={700} fill={PALETTE.ink}>
          à l&apos;impression
        </text>
        <rect
          x={330 - cote4 / 2}
          y={66}
          width={cote4}
          height={cote4}
          fill="#dbeafe"
          stroke="#2563eb"
          strokeWidth={1.4}
        />
        <text x={330} y={190} textAnchor="middle" fontSize={11} fontWeight={700} fill="#1e3a8a">
          {fmt(cm, 2)} cm de côté
        </text>
        <text
          x={330}
          y={196}
          textAnchor="middle"
          fontSize={10}
          fontWeight={700}
          fill={fin ? "#15803d" : "#b45309"}
        >
          {fin ? "impression fine" : "impression grossière"}
        </text>

        <text x={20} y={234} fontSize={10} fill={PALETTE.slate}>
          {pixels.toLocaleString("fr-FR")} pixels × {profondeur} bits ={" "}
          {octets.toLocaleString("fr-FR")} octets, soit {fmt(mo, 2)} Mo
        </text>
      </Board>

      <Panel>
        <Stat label="Définition" value={`${fmt(pixels / 1000000, 2)} Mpx`} />
        <Stat label="Résolution" value={`${ppp} ppp`} color={PALETTE.orange} />
        <Stat label="Taille imprimée" value={`${fmt(cm, 2)} cm`} color={PALETTE.blue} />
        <Stat label="Poids non compressé" value={`${fmt(mo, 2)} Mo`} color={PALETTE.purple} />
      </Panel>

      <Verdict tone="warn">
        Fais varier la résolution <strong>sans toucher à la définition</strong> : le nombre de
        pixels ne change pas, et pourtant la taille imprimée et la qualité changent du tout au tout.
        La définition dit <strong>combien</strong> il y a de pixels, la résolution dit à quel point
        ils sont <strong>serrés</strong>. C&apos;est la question d&apos;examen la plus prévisible du
        module, et celle que les candidats confondent.
      </Verdict>

      <Verdict tone={profondeur === 24 ? "ok" : "bad"}>
        {profondeur === 1
          ? "Avec 1 bit par pixel, il n'y a que deux couleurs : le disque devient une silhouette. Et le fichier est 24 fois plus léger."
          : profondeur === 8
            ? "Avec 8 bits, 256 couleurs : les dégradés deviennent des marches d'escalier. C'est la limite du format GIF."
            : "Avec 24 bits — 8 pour le rouge, 8 pour le vert, 8 pour le bleu — on a 16,7 millions de couleurs, ce qu'on appelle les « vraies couleurs ». C'est le mode RVB des écrans ; l'imprimeur, lui, travaille en CMJN."}
      </Verdict>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Chapitre 18 — Matricielle contre vectorielle                        */
/* ------------------------------------------------------------------ */

export function MatricielleVectorielle() {
  const [zoom, setZoom] = useState(100);
  const [sujet, setSujet] = useState<"logo" | "photo">("logo");

  const z = clamp(zoom, 100, 1600) / 100;
  const base = 16; // l'image matricielle d'origine fait 16 × 16 pixels
  const W = 440;
  const H = 260;
  const vue = 150;
  const taille = (vue / base) * z;
  const centre = (base - 1) / 2;
  const rayon = base * 0.4;

  const poidsMat = sujet === "photo" ? 1440 : 2.4;
  const poidsVec = sujet === "photo" ? 0 : 0.6;

  return (
    <div className="space-y-3">
      <Choice<"logo" | "photo">
        label="Sujet à représenter"
        value={sujet}
        options={[
          { value: "logo", label: "Un logo : un disque net" },
          { value: "photo", label: "Une photographie" },
        ]}
        onChange={setSujet}
      />

      <Ctrl
        label="Zoom"
        value={zoom}
        min={100}
        max={1600}
        step={50}
        onChange={setZoom}
        display={`${zoom} %`}
        color={PALETTE.purple}
      />

      <Board width={W} height={H}>
        <rect width={W} height={H} fill="#ffffff" />

        <text x={110} y={20} textAnchor="middle" fontSize={11} fontWeight={700} fill="#b91c1c">
          MATRICIELLE
        </text>
        <text x={330} y={20} textAnchor="middle" fontSize={11} fontWeight={700} fill="#15803d">
          VECTORIELLE
        </text>

        <clipPath id="cadreGauche">
          <rect x={34} y={30} width={vue} height={vue} />
        </clipPath>
        <clipPath id="cadreDroit">
          <rect x={254} y={30} width={vue} height={vue} />
        </clipPath>

        <g clipPath="url(#cadreGauche)">
          {Array.from({ length: base }).map((_, j) =>
            Array.from({ length: base }).map((__, i) => {
              const d = Math.sqrt((i - centre) ** 2 + (j - centre) ** 2);
              const dedans = sujet === "photo" ? (i * 5 + j * 3) % 7 > 1 : d <= rayon;
              if (!dedans) return null;
              const couleur =
                sujet === "photo"
                  ? `hsl(${(i * 23 + j * 37) % 360} 55% ${45 + ((i + j) % 4) * 8}%)`
                  : "#1d4ed8";
              return (
                <rect
                  key={`${i}-${j}`}
                  x={34 + vue / 2 - (taille * base) / 2 + i * taille}
                  y={30 + vue / 2 - (taille * base) / 2 + j * taille}
                  width={taille + 0.5}
                  height={taille + 0.5}
                  fill={couleur}
                />
              );
            }),
          )}
        </g>
        <rect
          x={34}
          y={30}
          width={vue}
          height={vue}
          fill="none"
          stroke="#94a3b8"
          strokeWidth={1.4}
        />

        <g clipPath="url(#cadreDroit)">
          {sujet === "logo" ? (
            <circle cx={254 + vue / 2} cy={30 + vue / 2} r={vue * 0.4 * z} fill="#15803d" />
          ) : (
            <>
              <rect x={254} y={30} width={vue} height={vue} fill="#f1f5f9" />
              <text
                x={254 + vue / 2}
                y={30 + vue / 2 - 6}
                textAnchor="middle"
                fontSize={11}
                fontWeight={700}
                fill="#b91c1c"
              >
                impossible
              </text>
              <text
                x={254 + vue / 2}
                y={30 + vue / 2 + 12}
                textAnchor="middle"
                fontSize={9}
                fill={PALETTE.slate}
              >
                aucune formule ne décrit
              </text>
              <text
                x={254 + vue / 2}
                y={30 + vue / 2 + 26}
                textAnchor="middle"
                fontSize={9}
                fill={PALETTE.slate}
              >
                des millions de nuances
              </text>
            </>
          )}
        </g>
        <rect
          x={254}
          y={30}
          width={vue}
          height={vue}
          fill="none"
          stroke="#94a3b8"
          strokeWidth={1.4}
        />

        <text
          x={110}
          y={200}
          textAnchor="middle"
          fontSize={10}
          fontWeight={700}
          fill={z > 2 ? "#b91c1c" : PALETTE.slate}
        >
          {z > 2 ? "les pixels deviennent des carrés" : "une grille de 16 × 16 pixels"}
        </text>
        <text
          x={330}
          y={200}
          textAnchor="middle"
          fontSize={10}
          fontWeight={700}
          fill={sujet === "photo" ? "#b91c1c" : "#15803d"}
        >
          {sujet === "photo" ? "pas son terrain" : "le trait reste net"}
        </text>

        <text x={110} y={226} textAnchor="middle" fontSize={10} fill={PALETTE.slate}>
          poids : {sujet === "photo" ? "1,4 Mo" : "2,4 ko"}
        </text>
        <text x={330} y={226} textAnchor="middle" fontSize={10} fill={PALETTE.slate}>
          poids : {sujet === "photo" ? "—" : "0,6 ko"}
        </text>
        <text x={220} y={250} textAnchor="middle" fontSize={9} fill={PALETTE.slate}>
          Le zoom agit sur les deux en même temps.
        </text>
      </Board>

      <Panel>
        <Stat label="Zoom" value={`${zoom} %`} />
        <Stat label="Matricielle" value={`${fmt(poidsMat, 1)} ko`} color={PALETTE.red} />
        <Stat
          label="Vectorielle"
          value={poidsVec === 0 ? "—" : `${fmt(poidsVec, 1)} ko`}
          color={PALETTE.green}
        />
      </Panel>

      {sujet === "photo" ? (
        <Verdict tone="bad">
          Une photographie en vectoriel est impossible : elle contient des millions de nuances
          irrégulières qu&apos;aucune formule ne décrit. C&apos;est pour cela que la règle tient en
          une phrase — <strong>une photographie est matricielle, un logo est vectoriel</strong>.
        </Verdict>
      ) : z > 4 ? (
        <Verdict tone="ok">
          À {zoom} %, la différence est criante. À gauche, le logiciel ne peut qu&apos;agrandir les
          carrés enregistrés : c&apos;est la pixelisation, et l&apos;information manquante
          n&apos;était pas dans le fichier. À droite, l&apos;ordinateur <strong>recalcule</strong>{" "}
          la formule à la nouvelle taille et redessine un trait net. C&apos;est pourquoi un logo
          officiel doit toujours être conservé en vectoriel.
        </Verdict>
      ) : (
        <Verdict tone="warn">
          À cette taille, les deux se ressemblent. Monte le zoom au-delà de 400 % : c&apos;est à
          l&apos;agrandissement que tout se joue.
        </Verdict>
      )}
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Chapitre 18 — Choisir le bon format                                 */
/* ------------------------------------------------------------------ */

type Format = "jpg" | "png" | "gif" | "svg" | "tif" | "raw";

const FORMATS: ReadonlyArray<{ value: Format; label: string }> = [
  { value: "jpg", label: "JPEG" },
  { value: "png", label: "PNG" },
  { value: "gif", label: "GIF" },
  { value: "svg", label: "SVG" },
  { value: "tif", label: "TIFF" },
  { value: "raw", label: "RAW" },
];

type Situation = {
  titre: string;
  bons: ReadonlyArray<Format>;
  poids: Partial<Record<Format, string>>;
  defauts: Partial<Record<Format, string>>;
  pourquoi: string;
};

const SITUATIONS: ReadonlyArray<Situation> = [
  {
    titre: "Le logo du lycée, à fond transparent, pour le site web.",
    bons: ["png", "svg"],
    poids: { png: "18 ko", svg: "3 ko", jpg: "26 ko", gif: "12 ko" },
    defauts: {
      jpg: "Le JPEG ne gère pas la transparence : le fond devient un rectangle blanc, visible sur la page.",
      gif: "Le GIF accepte la transparence mais plafonne à 256 couleurs, et ses bords sont dentelés.",
      tif: "Bien trop lourd pour le web, et mal géré par les navigateurs.",
      raw: "Un fichier de capteur d'appareil photo : aucun navigateur ne l'affiche.",
    },
    pourquoi:
      "Le PNG gère la transparence et compresse sans perte, donc les traits du logo restent nets. Si le logo existe en vectoriel, le SVG est encore meilleur : plus léger et net sur tous les écrans.",
  },
  {
    titre: "La photographie de la cérémonie de rentrée, pour le site web.",
    bons: ["jpg"],
    poids: { jpg: "180 ko", png: "4,2 Mo", gif: "900 ko", tif: "9 Mo" },
    defauts: {
      png: "Sans perte sur une photographie, le fichier pèse plus de quatre mégaoctets : la page mettra longtemps à s'afficher.",
      gif: "256 couleurs seulement : le ciel devient une suite de bandes.",
      tif: "Neuf mégaoctets : impensable sur une connexion ordinaire.",
      svg: "Impossible : une photographie ne se décrit pas par des formules.",
      raw: "Le négatif numérique, non affichable par un navigateur.",
    },
    pourquoi:
      "C'est le terrain du JPEG : sa compression avec perte est pratiquement invisible sur une photographie, et elle divise le poids par vingt.",
  },
  {
    titre: "Une petite animation de trois images pour une bannière.",
    bons: ["gif"],
    poids: { gif: "48 ko", png: "—", jpg: "—" },
    defauts: {
      png: "Le PNG n'anime pas.",
      jpg: "Le JPEG n'anime pas.",
      svg: "Le SVG peut s'animer, mais ce n'est pas ce que le programme attend ici.",
      tif: "Pas d'animation.",
      raw: "Pas d'animation.",
    },
    pourquoi: "Le GIF est le seul format matriciel du programme qui accepte l'animation.",
  },
  {
    titre: "Un scan d'archive à imprimer en grand format, en imprimerie.",
    bons: ["tif"],
    poids: { tif: "28 Mo", jpg: "1,2 Mo", png: "14 Mo" },
    defauts: {
      jpg: "Compression avec perte : à l'agrandissement en imprimerie, les défauts deviennent visibles.",
      gif: "256 couleurs : inacceptable pour une impression professionnelle.",
      svg: "Un scan est matriciel, pas vectoriel.",
      raw: "Réservé aux appareils photo, pas aux scanners d'archive.",
    },
    pourquoi:
      "Le TIFF est le format sans perte de l'impression professionnelle : lourd, mais il garde toute l'information.",
  },
  {
    titre: "Une capture d'écran d'un message d'erreur, à envoyer au technicien.",
    bons: ["png"],
    poids: { png: "64 ko", jpg: "88 ko", gif: "70 ko" },
    defauts: {
      jpg: "Sur du texte, la compression avec perte brouille les lettres : le message devient difficile à lire — et ici, c'est tout l'intérêt de l'image.",
      gif: "Acceptable, mais le PNG fait mieux et sans limite de couleurs.",
      svg: "Une capture d'écran est matricielle.",
      tif: "Inutilement lourd pour un envoi.",
      raw: "Sans objet.",
    },
    pourquoi:
      "Sur du texte et des aplats, le PNG est à la fois plus net et plus léger que le JPEG. C'est l'exception qui surprend : le JPEG n'est pas toujours le plus léger.",
  },
  {
    titre: "La prise de vue d'origine, à retoucher longuement ensuite.",
    bons: ["raw"],
    poids: { raw: "24 Mo", jpg: "3 Mo" },
    defauts: {
      jpg: "Le JPEG a déjà jeté de l'information à la prise de vue : la latitude de retouche est bien plus faible.",
      png: "Le capteur ne produit pas de PNG.",
      gif: "Sans objet.",
      svg: "Sans objet.",
      tif: "Possible pour l'archivage après traitement, mais ce n'est pas le fichier brut du capteur.",
    },
    pourquoi:
      "Le RAW est le fichier brut du capteur, sans aucun traitement : c'est le négatif numérique du photographe, lourd mais complet.",
  },
];

const SITUATION_DEFAUT: Situation = { titre: "", bons: [], poids: {}, defauts: {}, pourquoi: "" };

export function FormatsImage() {
  const [i, setI] = useState(0);
  const [choix, setChoix] = useState<Record<number, Format>>({});
  const [resauves, setResauves] = useState(0);

  const s = SITUATIONS[i] ?? SITUATION_DEFAUT;
  const c = choix[i];
  const juste = c !== undefined && s.bons.includes(c);
  const bons = SITUATIONS.filter((q, k) => {
    const r = choix[k];
    return r !== undefined && q.bons.includes(r);
  }).length;

  const qualite = Math.max(8, 100 - resauves * 9);

  return (
    <div className="space-y-3">
      <div className="rounded-lg border border-border bg-secondary/30 px-3 py-2.5">
        <p className="text-[11px] text-muted-foreground">
          Situation {i + 1} sur {SITUATIONS.length}
        </p>
        <p className="text-sm font-medium">{s.titre}</p>
      </div>

      <Choice<Format>
        label="Format choisi"
        value={c ?? "jpg"}
        options={FORMATS}
        onChange={(v) => setChoix({ ...choix, [i]: v })}
      />

      <Panel>
        <Stat label="Poids obtenu" value={c !== undefined ? (s.poids[c] ?? "très lourd") : "—"} />
        <Stat
          label="Bonnes réponses"
          value={`${bons} / ${SITUATIONS.length}`}
          color={PALETTE.green}
        />
      </Panel>

      {c === undefined ? (
        <Verdict tone="warn">
          Trois questions tranchent presque toujours : y a-t-il de la transparence ? est-ce une
          photographie ou un aplat ? l&apos;image doit-elle s&apos;agrandir ?
        </Verdict>
      ) : juste ? (
        <Verdict tone="ok">Bon choix. {s.pourquoi}</Verdict>
      ) : (
        <Verdict tone="bad">
          {s.defauts[c] ?? "Ce format ne convient pas ici."} Il fallait choisir{" "}
          {s.bons.map((b) => FORMATS.find((f) => f.value === b)?.label ?? b).join(" ou ")}.{" "}
          {s.pourquoi}
        </Verdict>
      )}

      <button
        type="button"
        onClick={() => setI((v) => (v + 1) % SITUATIONS.length)}
        className="rounded-lg bg-primary px-3 py-1.5 text-xs font-semibold text-primary-foreground"
      >
        Situation suivante
      </button>

      <div className="rounded-lg border border-border bg-background p-3 space-y-2">
        <p className="text-xs font-semibold">
          Que se passe-t-il quand on réenregistre dix fois un JPEG ?
        </p>

        <Board width={440} height={110}>
          <rect width={440} height={110} fill="#ffffff" />
          {Array.from({ length: 11 }).map((_, k) => {
            const q = Math.max(8, 100 - k * 9);
            const vu = k <= resauves;
            return (
              <g key={k} opacity={vu ? 1 : 0.15}>
                <rect
                  x={14 + k * 38}
                  y={24}
                  width={32}
                  height={46}
                  fill={`hsl(217 ${q * 0.6}% ${100 - q * 0.45}%)`}
                  stroke="#94a3b8"
                  strokeWidth={0.8}
                />
                {/* des blocs de compression de plus en plus visibles */}
                {Array.from({ length: Math.round((100 - q) / 12) }).map((__, j) => (
                  <rect
                    key={j}
                    x={14 + k * 38 + ((j * 7) % 24)}
                    y={24 + ((j * 11) % 36)}
                    width={8}
                    height={8}
                    fill="#f8fafc"
                    opacity={0.7}
                  />
                ))}
                <text x={30 + k * 38} y={86} textAnchor="middle" fontSize={8} fill={PALETTE.slate}>
                  {k}
                </text>
              </g>
            );
          })}
          <text x={14} y={104} fontSize={9} fill={PALETTE.slate}>
            nombre de réenregistrements — qualité restante : {qualite} %
          </text>
        </Board>

        <div className="flex gap-2">
          <button
            type="button"
            onClick={() => setResauves(Math.min(10, resauves + 1))}
            className="rounded-lg border border-border bg-background px-3 py-1.5 text-xs font-medium hover:bg-secondary/60"
          >
            Ouvrir, modifier, réenregistrer
          </button>
          <button
            type="button"
            onClick={() => setResauves(0)}
            className="rounded-lg border border-border bg-background px-3 py-1.5 text-xs font-medium text-muted-foreground hover:bg-secondary/60"
          >
            Repartir de l&apos;original
          </button>
        </div>

        {resauves >= 4 ? (
          <Verdict tone="bad">
            Après {resauves} réenregistrements, la dégradation est visible et{" "}
            <strong>irréversible</strong> : chaque passage a jeté un peu plus d&apos;information. On
            travaille donc dans un format sans perte — PNG, TIFF, ou le format du logiciel — et on
            n&apos;exporte en JPEG qu&apos;à la fin.
          </Verdict>
        ) : (
          <Verdict tone="warn">
            Clique plusieurs fois et observe les blocs apparaître. C&apos;est la conséquence de la
            compression <strong>avec perte</strong> : on ne retrouve jamais l&apos;original.
          </Verdict>
        )}
      </div>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Chapitre 19 — L'interface d'un logiciel de retouche                 */
/* ------------------------------------------------------------------ */

type PartieId = "menus" | "options" | "outils" | "travail" | "palettes";

const PARTIES: ReadonlyArray<{ id: PartieId; nom: string; detail: string }> = [
  {
    id: "menus",
    nom: "La barre de menus",
    detail: "Fichier, Édition, Image, Calque, Filtre : toutes les commandes du logiciel sont là.",
  },
  {
    id: "options",
    nom: "La barre d'options",
    detail:
      "Elle change selon l'outil choisi. C'est pour cela qu'elle est comptée comme une partie à elle seule : essaie de changer d'outil pour la voir se transformer.",
  },
  {
    id: "outils",
    nom: "La boîte à outils",
    detail: "Sélection, lasso, baguette magique, pinceau, gomme, texte, pot de peinture, zoom.",
  },
  { id: "travail", nom: "La zone de travail", detail: "L'image elle-même, au centre." },
  {
    id: "palettes",
    nom: "Les palettes",
    detail:
      "Les fenêtres flottantes du côté : calques, couleurs, historique. La plus importante est de loin la palette des calques.",
  },
];

const PARTIE_DEFAUT = PARTIES[0] ?? { id: "menus" as PartieId, nom: "", detail: "" };

type OutilId = "selection" | "lasso" | "baguette" | "pinceau" | "texte" | "zoom";

const OUTILS_RETOUCHE: ReadonlyArray<{ id: OutilId; nom: string; court: string; options: string }> =
  [
    {
      id: "selection",
      court: "Sél.",
      nom: "Sélection rectangle",
      options: "Mode : nouveau · ajouter · soustraire     Contour progressif : 0 px",
    },
    {
      id: "lasso",
      court: "Lasso",
      nom: "Lasso",
      options: "Mode : nouveau · ajouter     Contour progressif : 2 px     Lissage : oui",
    },
    {
      id: "baguette",
      court: "Bag.",
      nom: "Baguette magique",
      options: "Tolérance : 32     Pixels contigus : oui     Lissage : oui",
    },
    {
      id: "pinceau",
      court: "Pinc.",
      nom: "Pinceau",
      options: "Taille : 24 px     Dureté : 80 %     Opacité : 100 %     Flux : 100 %",
    },
    {
      id: "texte",
      court: "Texte",
      nom: "Texte",
      options: "Police : Arial     Corps : 18 pt     Couleur : noir     Alignement : gauche",
    },
    {
      id: "zoom",
      court: "Zoom",
      nom: "Zoom",
      options: "Zoom + · Zoom −     Ajuster à l'écran     Taille réelle : 100 %",
    },
  ];

const OUTIL_DEFAUT = OUTILS_RETOUCHE[0] ?? {
  id: "selection" as OutilId,
  nom: "",
  court: "",
  options: "",
};

export function InterfacePhotoshop() {
  const [sel, setSel] = useState<PartieId | "rien">("rien");
  const [outil, setOutil] = useState<OutilId>("selection");
  const [trouvees, setTrouvees] = useState<PartieId[]>([]);

  const p = PARTIES.find((q) => q.id === sel) ?? PARTIE_DEFAUT;
  const o = OUTILS_RETOUCHE.find((q) => q.id === outil) ?? OUTIL_DEFAUT;

  const cliquer = (id: PartieId) => {
    setSel(id);
    if (!trouvees.includes(id)) setTrouvees([...trouvees, id]);
  };

  const W = 440;
  const H = 240;
  const trait = (id: PartieId) => (sel === id ? "#ea580c" : "#94a3b8");
  const ep = (id: PartieId) => (sel === id ? 2.4 : 1);

  return (
    <div className="space-y-3">
      <Board width={W} height={H}>
        <rect width={W} height={H} fill="#f8fafc" />

        <g onClick={() => cliquer("menus")} style={{ cursor: "pointer" }}>
          <rect
            x={8}
            y={8}
            width={424}
            height={22}
            fill="#1e293b"
            stroke={trait("menus")}
            strokeWidth={ep("menus")}
          />
          <text x={18} y={23} fontSize={9} fill="#e2e8f0">
            Fichier Édition Image Calque Sélection Filtre Affichage
          </text>
        </g>

        <g onClick={() => cliquer("options")} style={{ cursor: "pointer" }}>
          <rect
            x={8}
            y={32}
            width={424}
            height={22}
            fill="#e2e8f0"
            stroke={trait("options")}
            strokeWidth={ep("options")}
          />
          <text x={18} y={47} fontSize={8} fill="#334155">
            {o.options}
          </text>
        </g>

        <g onClick={() => cliquer("outils")} style={{ cursor: "pointer" }}>
          <rect
            x={8}
            y={58}
            width={44}
            height={174}
            fill="#cbd5e1"
            stroke={trait("outils")}
            strokeWidth={ep("outils")}
          />
          {OUTILS_RETOUCHE.map((q, k) => (
            <g
              key={q.id}
              onClick={(e) => {
                e.stopPropagation();
                setOutil(q.id);
                cliquer("outils");
              }}
            >
              <rect
                x={14}
                y={64 + k * 28}
                width={32}
                height={24}
                rx={3}
                fill={outil === q.id ? "#2563eb" : "#f1f5f9"}
                stroke="#94a3b8"
                strokeWidth={0.8}
              />
              <text
                x={30}
                y={80 + k * 28}
                textAnchor="middle"
                fontSize={8}
                fontWeight={700}
                fill={outil === q.id ? "#ffffff" : "#334155"}
              >
                {q.court}
              </text>
            </g>
          ))}
        </g>

        <g onClick={() => cliquer("travail")} style={{ cursor: "pointer" }}>
          <rect
            x={58}
            y={58}
            width={252}
            height={174}
            fill="#ffffff"
            stroke={trait("travail")}
            strokeWidth={ep("travail")}
          />
          <rect x={92} y={92} width={184} height={106} fill="#bfdbfe" />
          <circle cx={140} cy={128} r={18} fill="#fcd34d" />
          <polygon points="92,198 160,138 220,198" fill="#4ade80" />
          <polygon points="180,198 236,152 276,198" fill="#22c55e" />
          <text x={184} y={74} textAnchor="middle" fontSize={9} fill={PALETTE.slate}>
            photo.jpg — 100 %
          </text>
        </g>

        <g onClick={() => cliquer("palettes")} style={{ cursor: "pointer" }}>
          <rect
            x={316}
            y={58}
            width={116}
            height={174}
            fill="#e2e8f0"
            stroke={trait("palettes")}
            strokeWidth={ep("palettes")}
          />
          <text x={324} y={74} fontSize={9} fontWeight={700} fill="#334155">
            Calques
          </text>
          <rect
            x={322}
            y={80}
            width={104}
            height={20}
            fill="#ffffff"
            stroke="#cbd5e1"
            strokeWidth={0.8}
          />
          <text x={328} y={94} fontSize={8} fill="#334155">
            Texte
          </text>
          <rect
            x={322}
            y={104}
            width={104}
            height={20}
            fill="#ffffff"
            stroke="#cbd5e1"
            strokeWidth={0.8}
          />
          <text x={328} y={118} fontSize={8} fill="#334155">
            Logo
          </text>
          <rect
            x={322}
            y={128}
            width={104}
            height={20}
            fill="#ffffff"
            stroke="#cbd5e1"
            strokeWidth={0.8}
          />
          <text x={328} y={142} fontSize={8} fill="#334155">
            Photographie
          </text>
          <text x={324} y={172} fontSize={9} fontWeight={700} fill="#334155">
            Couleurs
          </text>
          <rect x={322} y={178} width={24} height={24} fill="#1d4ed8" />
          <rect x={350} y={178} width={24} height={24} fill="#dc2626" />
          <rect x={378} y={178} width={24} height={24} fill="#16a34a" />
        </g>
      </Board>

      <p className="text-xs text-muted-foreground">
        Clique sur chacune des cinq parties de l&apos;interface pour la nommer. Dans la boîte à
        outils, clique un outil et regarde la barre d&apos;options changer.
      </p>

      <Panel>
        <Stat label="Parties trouvées" value={`${trouvees.length} / 5`} color={PALETTE.green} />
        <Stat label="Outil sélectionné" value={o.nom} color={PALETTE.blue} />
      </Panel>

      {sel === "rien" ? (
        <Verdict tone="warn">
          Les cinq parties au programme : la barre de menus, la barre d&apos;options, la boîte à
          outils, la zone de travail et les palettes.
        </Verdict>
      ) : (
        <Verdict tone="ok">
          <strong>{p.nom}.</strong> {p.detail}
        </Verdict>
      )}

      {trouvees.length === 5 ? (
        <Verdict tone="ok">
          Les cinq y sont. Change encore d&apos;outil : la barre d&apos;options se transforme
          complètement, et c&apos;est la raison pour laquelle on la compte à part de la boîte à
          outils.
        </Verdict>
      ) : null}
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Chapitre 19 — Retoucher une photographie                            */
/* ------------------------------------------------------------------ */

export function RetoucheImage() {
  const [lum, setLum] = useState(100);
  const [contraste, setContraste] = useState(100);
  const [saturation, setSaturation] = useState(100);
  const [nettete, setNettete] = useState(0);
  const [recadre, setRecadre] = useState(100);
  const [calques, setCalques] = useState<Record<string, boolean>>({ texte: true, logo: true });
  const [opaciteTexte, setOpaciteTexte] = useState(100);
  const [aplati, setAplati] = useState(false);

  const part = clamp(recadre, 30, 100) / 100;
  const defDepart = 3000 * 2000;
  const defRestante = Math.round(defDepart * part * part);
  const pppImpression = Math.round(Math.sqrt(defRestante / (20 * 13.3)) / 1);
  const imprimable = defRestante > 1500000;

  const filtre = `brightness(${lum / 100}) contrast(${contraste / 100}) saturate(${saturation / 100})${nettete > 0 ? ` drop-shadow(0 0 0 transparent)` : ""}`;

  return (
    <div className="space-y-3">
      <div className="rounded-lg border border-border bg-white p-3">
        <div
          className="relative mx-auto overflow-hidden rounded"
          style={{ width: 300 * part, height: 190 * part, filter: filtre, transition: "all .15s" }}
        >
          <svg viewBox="0 0 300 190" width={300 * part} height={190 * part}>
            <rect width={300} height={190} fill="#bfdbfe" />
            <circle cx={236} cy={44} r={22} fill="#fcd34d" />
            <polygon points="0,190 90,86 170,190" fill="#4ade80" />
            <polygon points="130,190 212,104 300,190" fill="#16a34a" />
            <rect y={160} width={300} height={30} fill="#a16207" />
            {nettete > 0 ? (
              <g opacity={clamp(nettete / 100, 0, 1)}>
                <polyline
                  points="0,190 90,86 170,190"
                  fill="none"
                  stroke="#065f46"
                  strokeWidth={1.4}
                />
                <polyline
                  points="130,190 212,104 300,190"
                  fill="none"
                  stroke="#065f46"
                  strokeWidth={1.4}
                />
                <circle cx={236} cy={44} r={22} fill="none" stroke="#b45309" strokeWidth={1.2} />
              </g>
            ) : null}
            {calques["logo"] && !aplati ? (
              <g>
                <circle cx={32} cy={28} r={16} fill="#1d4ed8" opacity={0.9} />
                <text
                  x={32}
                  y={33}
                  textAnchor="middle"
                  fontSize={11}
                  fontWeight={700}
                  fill="#ffffff"
                >
                  M
                </text>
              </g>
            ) : null}
            {calques["logo"] && aplati ? (
              <g>
                <circle cx={32} cy={28} r={16} fill="#1d4ed8" opacity={0.9} />
                <text
                  x={32}
                  y={33}
                  textAnchor="middle"
                  fontSize={11}
                  fontWeight={700}
                  fill="#ffffff"
                >
                  M
                </text>
              </g>
            ) : null}
            {calques["texte"] ? (
              <text
                x={150}
                y={150}
                textAnchor="middle"
                fontSize={16}
                fontWeight={700}
                fill="#ffffff"
                opacity={opaciteTexte / 100}
              >
                Rentrée 2026
              </text>
            ) : null}
          </svg>
        </div>
      </div>

      <Panel>
        <Ctrl
          label="Luminosité"
          value={lum}
          min={40}
          max={180}
          step={5}
          onChange={setLum}
          display={`${lum} %`}
        />
        <Ctrl
          label="Contraste"
          value={contraste}
          min={40}
          max={200}
          step={5}
          onChange={setContraste}
          display={`${contraste} %`}
          color={PALETTE.orange}
        />
      </Panel>

      <Panel>
        <Ctrl
          label="Saturation"
          value={saturation}
          min={0}
          max={220}
          step={5}
          onChange={setSaturation}
          display={saturation === 0 ? "0 % — noir et blanc" : `${saturation} %`}
          color={PALETTE.purple}
        />
        <Ctrl
          label="Netteté"
          value={nettete}
          min={0}
          max={100}
          step={5}
          onChange={setNettete}
          display={`${nettete} %`}
          color={PALETTE.green}
        />
      </Panel>

      <Ctrl
        label="Cadre de recadrage"
        value={recadre}
        min={30}
        max={100}
        step={5}
        onChange={setRecadre}
        display={`${recadre} % de l'image`}
        color={imprimable ? PALETTE.green : PALETTE.red}
      />

      <Panel>
        <Stat
          label="Définition restante"
          value={`${fmt(defRestante / 1000000, 2)} Mpx`}
          color={imprimable ? PALETTE.green : PALETTE.red}
        />
        <Stat
          label="Impression A4"
          value={imprimable ? `environ ${pppImpression} ppp` : "insuffisante"}
        />
      </Panel>

      {!imprimable ? (
        <Verdict tone="bad">
          Trop recadré : il ne reste que {fmt(defRestante / 1000000, 2)} mégapixels, et
          l&apos;impression en A4 montrera les pixels. Le recadrage{" "}
          <strong>jette des pixels</strong>, et ils ne reviennent pas.
        </Verdict>
      ) : saturation === 0 ? (
        <Verdict tone="ok">
          Saturation à zéro : l&apos;image est en noir et blanc. Remarque que la luminosité et le
          contraste continuent d&apos;agir — la saturation ne règle que l&apos;intensité des
          couleurs.
        </Verdict>
      ) : (
        <Verdict tone="ok">
          La luminosité éclaircit <em>tous</em> les pixels, le contraste écarte les clairs des
          sombres, la saturation règle l&apos;intensité des couleurs. Trois réglages distincts,
          qu&apos;on confond souvent.
        </Verdict>
      )}

      <div className="rounded-lg border border-border bg-background p-3 space-y-2">
        <p className="text-xs font-semibold">La palette des calques</p>

        <div className="flex flex-wrap gap-1.5">
          {(["texte", "logo"] as const).map((k) => (
            <button
              key={k}
              type="button"
              disabled={aplati}
              onClick={() => setCalques({ ...calques, [k]: !calques[k] })}
              className={
                aplati
                  ? "rounded-lg border border-border bg-secondary/40 px-3 py-1.5 text-xs text-muted-foreground/50"
                  : calques[k]
                    ? "rounded-lg bg-primary px-3 py-1.5 text-xs font-semibold text-primary-foreground"
                    : "rounded-lg border border-border bg-background px-3 py-1.5 text-xs font-medium hover:bg-secondary/60"
              }
            >
              calque {k} {calques[k] ? "visible" : "masqué"}
            </button>
          ))}
        </div>

        <Ctrl
          label="Opacité du calque texte"
          value={opaciteTexte}
          min={0}
          max={100}
          step={5}
          onChange={setOpaciteTexte}
          display={`${opaciteTexte} %`}
        />

        <button
          type="button"
          onClick={() => setAplati(!aplati)}
          className={
            aplati
              ? "rounded-lg bg-rose-600 px-3 py-1.5 text-xs font-semibold text-white"
              : "rounded-lg border border-border bg-background px-3 py-1.5 text-xs font-medium hover:bg-secondary/60"
          }
        >
          {aplati ? "Revenir au fichier à calques" : "Aplatir l'image et exporter en JPEG"}
        </button>

        {aplati ? (
          <Verdict tone="bad">
            L&apos;image est aplatie : les boutons de calques ne répondent plus. Le texte et le logo
            ne sont plus des objets modifiables, ce sont des pixels comme les autres — pour corriger
            une faute de frappe, il faudrait reconstituer la photographie cachée dessous. C&apos;est
            pourquoi on garde toujours le fichier à calques — PSD ou XCF — à côté du JPEG exporté.
          </Verdict>
        ) : (
          <Verdict tone="ok">
            Chaque élément vit sur sa couche transparente : on le déplace, on le masque, on change
            son opacité, et la photographie en dessous n&apos;est jamais touchée. Essaie maintenant
            d&apos;aplatir.
          </Verdict>
        )}
      </div>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Chapitre 19 — Réussir ou rater un photomontage                      */
/* ------------------------------------------------------------------ */

type EtapeId = "detourage" | "echelle" | "rotation" | "couleurs" | "ombre";

const ETAPES_MONTAGE: ReadonlyArray<{ id: EtapeId; nom: string; rate: string }> = [
  {
    id: "detourage",
    nom: "Détourer le sujet",
    rate: "Le sujet garde un morceau de son ancien arrière-plan : un liseré clair autour des contours.",
  },
  {
    id: "echelle",
    nom: "Ajuster l'échelle",
    rate: "Le sujet est trop grand ou trop petit pour la scène : l'œil le repère immédiatement.",
  },
  {
    id: "rotation",
    nom: "Corriger l'inclinaison",
    rate: "Le sujet penche alors que la scène est droite.",
  },
  {
    id: "couleurs",
    nom: "Harmoniser luminosité et couleurs",
    rate: "Le sujet est éclairé par la gauche quand la scène l'est par la droite. C'est l'étape que les débutants sautent, et celle qui trahit le plus un montage.",
  },
  {
    id: "ombre",
    nom: "Poser l'ombre portée",
    rate: "Le sujet flotte : rien ne le rattache au sol.",
  },
];

const IMAGES_DETECTIVE: ReadonlyArray<{ titre: string; truquee: boolean; indice: string }> = [
  {
    titre: "Une photo de classe où un élève a une ombre qui part dans l'autre sens.",
    truquee: true,
    indice: "Les ombres de tous les sujets d'une même scène vont dans le même sens.",
  },
  {
    titre: "Une photo de rue légèrement redressée et recadrée.",
    truquee: false,
    indice: "Recadrer et redresser ne change pas ce que la photo montre : ce n'est pas un trucage.",
  },
  {
    titre: "Un portrait dont la luminosité a été relevée.",
    truquee: false,
    indice: "Une retouche anodine, qui ne fait croire à rien de faux.",
  },
  {
    titre: "Une foule où un même groupe de visages se répète trois fois.",
    truquee: true,
    indice: "La répétition d'un motif identique est la trace d'un copier-coller.",
  },
  {
    titre: "Une pancarte dont le texte a été remplacé par un autre message.",
    truquee: true,
    indice: "On fait dire à quelqu'un ce qu'il n'a pas dit : c'est le trucage le plus grave.",
  },
  {
    titre: "Une photo convertie en noir et blanc.",
    truquee: false,
    indice: "Un choix esthétique, qui ne modifie aucun fait.",
  },
];

const IMAGE_DEFAUT = IMAGES_DETECTIVE[0] ?? { titre: "", truquee: false, indice: "" };

export function Photomontage() {
  const [faites, setFaites] = useState<EtapeId[]>([]);
  const [mode, setMode] = useState<"montage" | "detective">("montage");
  const [di, setDi] = useState(0);
  const [rep, setRep] = useState<Record<number, boolean>>({});

  const manquantes = ETAPES_MONTAGE.filter((e) => !faites.includes(e.id));
  const note = Math.round((faites.length / ETAPES_MONTAGE.length) * 20);

  const img = IMAGES_DETECTIVE[di] ?? IMAGE_DEFAUT;
  const r = rep[di];
  const justeDetective = r !== undefined && r === img.truquee;
  const bonsDetective = IMAGES_DETECTIVE.filter((q, k) => rep[k] === q.truquee).length;

  const bascule = (id: EtapeId) =>
    setFaites((s) => (s.includes(id) ? s.filter((x) => x !== id) : [...s, id]));

  const ok = (id: EtapeId) => faites.includes(id);

  const W = 440;
  const H = 194;
  const echelle = ok("echelle") ? 1 : 1.35;
  const rot = ok("rotation") ? 0 : -14;

  return (
    <div className="space-y-3">
      <Choice<"montage" | "detective">
        label="Mode"
        value={mode}
        options={[
          { value: "montage", label: "Fabriquer un montage" },
          { value: "detective", label: "Repérer les trucages" },
        ]}
        onChange={setMode}
      />

      {mode === "montage" ? (
        <>
          <Board width={W} height={H}>
            <rect width={W} height={H} fill="#ffffff" />

            {/* le décor : éclairé par la droite */}
            <rect x={14} y={14} width={412} height={150} fill="#bfdbfe" />
            <circle cx={386} cy={42} r={16} fill="#fcd34d" />
            <polygon points="14,164 130,84 234,164" fill="#4ade80" />
            <rect x={14} y={140} width={412} height={24} fill="#a16207" />

            {/* le sujet rapporté */}
            <g transform={`translate(190 100) rotate(${rot}) scale(${echelle})`}>
              {!ok("detourage") ? (
                <rect x={-26} y={-46} width={52} height={92} fill="#f8fafc" opacity={0.95} />
              ) : null}
              {ok("ombre") ? (
                <ellipse cx={-14} cy={44} rx={26} ry={6} fill="#000000" opacity={0.25} />
              ) : null}
              <circle cx={0} cy={-30} r={13} fill={ok("couleurs") ? "#d6a77a" : "#f3cfae"} />
              <rect
                x={-12}
                y={-16}
                width={24}
                height={44}
                rx={5}
                fill={ok("couleurs") ? "#1d4ed8" : "#60a5fa"}
              />
              <rect x={-10} y={28} width={8} height={18} fill="#334155" />
              <rect x={2} y={28} width={8} height={18} fill="#334155" />
              {!ok("couleurs") ? (
                <rect x={-12} y={-16} width={10} height={44} fill="#ffffff" opacity={0.35} />
              ) : (
                <rect x={2} y={-16} width={10} height={44} fill="#ffffff" opacity={0.22} />
              )}
            </g>

            <text x={220} y={184} textAnchor="middle" fontSize={9} fill={PALETTE.slate}>
              le soleil est en haut à droite : le sujet doit être éclairé du même côté
            </text>
          </Board>

          <div className="flex flex-wrap gap-1.5">
            {ETAPES_MONTAGE.map((e) => (
              <button
                key={e.id}
                type="button"
                onClick={() => bascule(e.id)}
                className={
                  faites.includes(e.id)
                    ? "rounded-lg bg-primary px-2.5 py-1.5 text-[11px] font-semibold text-primary-foreground"
                    : "rounded-lg border border-border bg-background px-2.5 py-1.5 text-[11px] font-medium hover:bg-secondary/60"
                }
              >
                {e.nom}
              </button>
            ))}
          </div>

          <Panel>
            <Stat label="Étapes faites" value={`${faites.length} / 5`} />
            <Stat
              label="Note du montage"
              value={`${note} / 20`}
              color={note >= 16 ? PALETTE.green : PALETTE.red}
            />
          </Panel>

          {manquantes.length === 0 ? (
            <Verdict tone="ok">
              Montage crédible. Les cinq étapes y sont, et notamment l&apos;harmonisation des
              couleurs et l&apos;ombre portée — les deux que les débutants sautent, et par
              lesquelles se repèrent presque tous les montages ratés.
            </Verdict>
          ) : (
            <div className="space-y-1.5">
              {manquantes.map((e) => (
                <Verdict key={e.id} tone="bad">
                  <strong>{e.nom} : </strong>
                  {e.rate}
                </Verdict>
              ))}
            </div>
          )}
        </>
      ) : (
        <>
          <div className="rounded-lg border border-border bg-secondary/30 px-3 py-2.5">
            <p className="text-[11px] text-muted-foreground">
              Image {di + 1} sur {IMAGES_DETECTIVE.length}
            </p>
            <p className="text-sm font-medium">{img.titre}</p>
          </div>

          <Choice<"oui" | "non">
            label="Est-ce un trucage ?"
            value={r === undefined ? "non" : r ? "oui" : "non"}
            options={[
              { value: "oui", label: "Oui, c'est un trucage" },
              { value: "non", label: "Non, simple retouche" },
            ]}
            onChange={(v) => setRep({ ...rep, [di]: v === "oui" })}
          />

          <Panel>
            <Stat
              label="Bonnes réponses"
              value={`${bonsDetective} / ${IMAGES_DETECTIVE.length}`}
              color={PALETTE.green}
            />
            <Stat
              label="Cette image"
              value={r === undefined ? "à juger" : justeDetective ? "juste" : "faux"}
            />
          </Panel>

          {r === undefined ? (
            <Verdict tone="warn">
              La technique est la même dans les deux cas ; ce qui change est l&apos;{" "}
              <strong>intention</strong>. Le photomontage assume d&apos;être une image composée, le
              trucage cherche à se faire prendre pour un document authentique.
            </Verdict>
          ) : justeDetective ? (
            <Verdict tone="ok">Exact. {img.indice}</Verdict>
          ) : (
            <Verdict tone="bad">
              Non : {img.truquee ? "c'est bien un trucage" : "ce n'en est pas un"}. {img.indice}
            </Verdict>
          )}

          <button
            type="button"
            onClick={() => setDi((v) => (v + 1) % IMAGES_DETECTIVE.length)}
            className="rounded-lg bg-primary px-3 py-1.5 text-xs font-semibold text-primary-foreground"
          >
            Image suivante
          </button>

          <p className="text-[11px] text-muted-foreground">
            Une image numérique se modifie sans laisser de trace : elle n&apos;est donc plus une
            preuve en soi. Avant d&apos;y croire, demande-toi d&apos;où elle vient et qui la diffuse
            — y compris quand elle confirme ce que tu penses déjà.
          </p>
        </>
      )}
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Chapitre 20 — Numériser un son                                      */
/* ------------------------------------------------------------------ */

export function SonNumerique() {
  const [freq, setFreq] = useState(44100);
  const [bits, setBits] = useState(16);
  const [stereo, setStereo] = useState(true);
  const [duree, setDuree] = useState(60);

  const canaux = stereo ? 2 : 1;
  const octets = freq * (bits / 8) * canaux * duree;
  const mo = octets / 1048576;
  const moMp3 = mo / 10;

  // le dessin : le nombre de points visibles suit la fréquence
  const points = clamp(Math.round((freq / 44100) * 40) + 3, 4, 60);
  const niveaux = Math.pow(2, Math.min(bits, 16));

  const W = 440;
  const H = 190;
  const onde = (x: number) => Math.sin((x / 400) * Math.PI * 3);
  const quantifier = (v: number) => {
    const pas = 2 / Math.min(niveaux, 64);
    return Math.round(v / pas) * pas;
  };

  const chemin = Array.from({ length: 200 })
    .map((_, k) => {
      const x = 20 + (k / 199) * 400;
      const y = 62 - onde(x - 20) * 26;
      return `${k === 0 ? "M" : "L"} ${x.toFixed(1)} ${y.toFixed(1)}`;
    })
    .join(" ");

  const echantillons = Array.from({ length: points }).map((_, k) => {
    const x = 20 + (k / (points - 1)) * 400;
    const brut = onde(x - 20);
    const y = 142 - quantifier(brut) * 24;
    return { x, y };
  });

  const reconstruit = echantillons
    .map((p, k) => `${k === 0 ? "M" : "L"} ${p.x.toFixed(1)} ${p.y.toFixed(1)}`)
    .join(" ");

  const fidele = freq >= 44100 && bits >= 16;

  return (
    <div className="space-y-3">
      <Choice<string>
        label="Fréquence d'échantillonnage"
        value={String(freq)}
        options={[
          { value: "8000", label: "8 000 Hz — téléphone" },
          { value: "22050", label: "22 050 Hz" },
          { value: "44100", label: "44 100 Hz — CD" },
          { value: "48000", label: "48 000 Hz — vidéo pro" },
        ]}
        onChange={(v) => setFreq(Number(v))}
      />

      <Panel>
        <Choice<string>
          label="Quantification"
          value={String(bits)}
          options={[
            { value: "8", label: "8 bits" },
            { value: "16", label: "16 bits — CD" },
            { value: "24", label: "24 bits — studio" },
          ]}
          onChange={(v) => setBits(Number(v))}
        />
        <Choice<"mono" | "stereo">
          label="Canaux"
          value={stereo ? "stereo" : "mono"}
          options={[
            { value: "mono", label: "Mono" },
            { value: "stereo", label: "Stéréo" },
          ]}
          onChange={(v) => setStereo(v === "stereo")}
        />
      </Panel>

      <Ctrl
        label="Durée"
        value={duree}
        min={1}
        max={300}
        step={1}
        onChange={setDuree}
        display={`${duree} s`}
        color={PALETTE.orange}
      />

      <Board width={W} height={H}>
        <rect width={W} height={H} fill="#ffffff" />

        <text x={20} y={20} fontSize={10} fontWeight={700} fill="#2563eb">
          Le son réel : une onde continue
        </text>
        <line x1={20} y1={62} x2={420} y2={62} stroke="#e2e8f0" strokeWidth={1} />
        <path d={chemin} fill="none" stroke="#2563eb" strokeWidth={2.2} />

        <text x={20} y={104} fontSize={10} fontWeight={700} fill="#b91c1c">
          Ce que le fichier retient : {points} mesures, sur {Math.min(niveaux, 16777216)} niveaux
        </text>
        <line x1={20} y1={142} x2={420} y2={142} stroke="#e2e8f0" strokeWidth={1} />
        <path d={reconstruit} fill="none" stroke="#fca5a5" strokeWidth={1.6} />
        {echantillons.map((p, k) => (
          <circle key={k} cx={p.x} cy={p.y} r={2.6} fill="#b91c1c" />
        ))}

        <text x={20} y={182} fontSize={9} fill={PALETTE.slate}>
          {fidele
            ? "points serrés et niveaux fins : la copie suit l'original de près"
            : "points écartés ou niveaux grossiers : la copie s'éloigne de l'original"}
        </text>
      </Board>

      <Panel>
        <Stat label="Poids non compressé" value={`${fmt(mo, 2)} Mo`} color={PALETTE.purple} />
        <Stat label="Le même en MP3" value={`environ ${fmt(moMp3, 2)} Mo`} color={PALETTE.green} />
      </Panel>

      <div className="rounded-lg border border-border bg-secondary/30 p-3">
        <p className="font-mono text-[11px] leading-relaxed">
          {freq} × {bits}/8 × {canaux} × {duree} = {fmt(octets, 0)} octets
          <br />
          {fmt(octets, 0)} ÷ 1 048 576 = {fmt(mo, 2)} Mo
        </p>
      </div>

      {freq === 44100 && bits === 16 && stereo && duree === 60 ? (
        <Verdict tone="ok">
          C&apos;est exactement l&apos;exercice du cours : une minute en qualité disque compact pèse{" "}
          {fmt(mo, 1)} Mo, et un morceau de quatre minutes environ 40 Mo. En MP3, dix fois moins —
          parce que sa compression avec perte supprime ce que l&apos;oreille ne perçoit pas, et
          surtout les sons masqués par un son plus fort émis au même instant.
        </Verdict>
      ) : !fidele ? (
        <Verdict tone="bad">
          {freq < 44100
            ? `À ${freq} Hz, les points de mesure sont trop écartés : la courbe reconstruite coupe les crêtes, et les aigus disparaissent. C'est pourquoi la voix au téléphone, à 8 000 Hz, est reconnaissable mais pauvre.`
            : `À ${bits} bits, il n'y a que ${niveaux} niveaux d'amplitude : la courbe devient un escalier, et le son souffle.`}
        </Verdict>
      ) : (
        <Verdict tone="ok">
          Points serrés, niveaux fins : la copie numérique suit l&apos;original de près. Et le prix
          à payer est le poids — {fmt(mo, 2)} Mo. Plus la qualité monte, plus le fichier grossit,
          sans exception.
        </Verdict>
      )}

      <div className="rounded-lg border border-border bg-background p-3 space-y-1">
        <p className="text-xs font-semibold">Le piège du MIDI</p>
        <p className="text-[11px] text-muted-foreground">
          Un fichier MIDI ne contient <strong>aucun son enregistré</strong> : seulement des
          instructions — « note la, sur un piano, pendant une demi-seconde ». D&apos;où sa taille
          minuscule, et le fait que le même fichier sonne différemment d&apos;une machine à
          l&apos;autre. Le MIDI est au son ce que le vectoriel est à l&apos;image : il décrit au
          lieu d&apos;enregistrer.
        </p>
      </div>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Chapitre 20 — Les réglages d'une vidéo                              */
/* ------------------------------------------------------------------ */

const DEFINITIONS_VIDEO: ReadonlyArray<{ value: string; label: string; l: number; h: number }> = [
  { value: "sd", label: "640 × 480", l: 640, h: 480 },
  { value: "hd", label: "1280 × 720", l: 1280, h: 720 },
  { value: "fhd", label: "1920 × 1080", l: 1920, h: 1080 },
  { value: "uhd", label: "3840 × 2160", l: 3840, h: 2160 },
];

const DEF_VIDEO_DEFAUT = DEFINITIONS_VIDEO[2] ?? { value: "fhd", label: "", l: 1920, h: 1080 };

export function VideoNumerique() {
  const [def, setDef] = useState("fhd");
  const [fps, setFps] = useState(25);
  const [compression, setCompression] = useState(60);
  const [conteneur, setConteneur] = useState<"avi" | "mp4" | "mkv">("mp4");
  const [codecPresent, setCodecPresent] = useState(true);

  const d = DEFINITIONS_VIDEO.find((q) => q.value === def) ?? DEF_VIDEO_DEFAUT;
  const brutParSeconde = d.l * d.h * 3 * fps;
  const facteur = Math.max(1, 1 + (compression / 100) * 300);
  const parSeconde = brutParSeconde / facteur;
  const parMinute = (parSeconde * 60) / 1048576;
  const brutParMinute = (brutParSeconde * 60) / 1073741824;
  const film = (parMinute * 120) / 1024;

  const fluide = fps >= 24;
  const trop = compression > 88;

  const W = 440;
  const H = 150;

  return (
    <div className="space-y-3">
      <Choice<string>
        label="Définition de chaque image"
        value={def}
        options={DEFINITIONS_VIDEO.map((q) => ({ value: q.value, label: q.label }))}
        onChange={setDef}
      />

      <Panel>
        <Ctrl
          label="Images par seconde"
          value={fps}
          min={5}
          max={60}
          step={1}
          onChange={setFps}
          display={`${fps} fps`}
        />
        <Ctrl
          label="Compression"
          value={compression}
          min={0}
          max={98}
          step={2}
          onChange={setCompression}
          display={compression === 0 ? "aucune" : `${compression} %`}
          color={trop ? PALETTE.red : PALETTE.green}
        />
      </Panel>

      <Board width={W} height={H}>
        <rect width={W} height={H} fill="#ffffff" />

        {/* une pellicule : le nombre de vignettes suit la cadence */}
        <text x={20} y={20} fontSize={10} fontWeight={700} fill={PALETTE.ink}>
          Une seconde de vidéo, en images
        </text>
        {Array.from({ length: Math.min(fps, 30) }).map((_, k) => {
          const x = 20 + k * (390 / Math.min(fps, 30));
          const l = 390 / Math.min(fps, 30) - 2;
          return (
            <rect
              key={k}
              x={x}
              y={30}
              width={Math.max(l, 1.5)}
              height={34}
              fill={`hsl(${(k * 360) / Math.min(fps, 30)} 45% ${trop ? 75 : 58}%)`}
              stroke="#ffffff"
              strokeWidth={0.4}
            />
          );
        })}
        {fps > 30 ? (
          <text x={414} y={52} textAnchor="end" fontSize={8} fill={PALETTE.slate}>
            …
          </text>
        ) : null}

        <text x={20} y={86} fontSize={10} fontWeight={700} fill={fluide ? "#15803d" : "#b91c1c"}>
          {fluide
            ? `${fps} images par seconde : le mouvement est fluide`
            : `${fps} images par seconde : l'œil perçoit des saccades`}
        </text>

        <text x={20} y={112} fontSize={10} fill={PALETTE.slate}>
          sans compression : {fmt(brutParMinute, 2)} Go par minute
        </text>
        <text x={20} y={130} fontSize={11} fontWeight={700} fill="#2563eb">
          avec la compression réglée : {fmt(parMinute, 1)} Mo par minute
        </text>
        <text x={20} y={146} fontSize={10} fill={PALETTE.slate}>
          un film de deux heures : {fmt(film, 2)} Go
        </text>
      </Board>

      <Panel>
        <Stat
          label="Sans compression"
          value={`${fmt(brutParMinute, 2)} Go/min`}
          color={PALETTE.red}
        />
        <Stat label="Compressée" value={`${fmt(parMinute, 1)} Mo/min`} color={PALETTE.green} />
        <Stat label="Film de 2 h" value={`${fmt(film, 2)} Go`} color={PALETTE.purple} />
        <Stat label="Cadence" value={fluide ? "fluide" : "saccadée"} />
      </Panel>

      {compression === 0 ? (
        <Verdict tone="bad">
          Sans compression, une minute pèse {fmt(brutParMinute, 2)} Go et un film de deux heures
          dépasse le millier de gigaoctets. C&apos;est impossible à stocker et impossible à
          transmettre : <strong>toute vidéo est compressée</strong>, sans exception. La compression
          exploite une idée simple — d&apos;une image à la suivante, presque rien ne change, donc on
          n&apos;enregistre que les différences.
        </Verdict>
      ) : trop ? (
        <Verdict tone="bad">
          À {compression} % de compression, le fichier est minuscule mais l&apos;image est en
          bouillie : les couleurs se délavent et des blocs apparaissent. La compression vidéo est
          elle aussi <strong>avec perte</strong>.
        </Verdict>
      ) : (
        <Verdict tone="ok">
          {fmt(parMinute, 1)} Mo par minute : c&apos;est l&apos;ordre de grandeur d&apos;une vidéo
          courante. Baisse la compression à zéro pour voir le chiffre affolant de la vidéo brute.
        </Verdict>
      )}

      <div className="rounded-lg border border-border bg-background p-3 space-y-2">
        <p className="text-xs font-semibold">Le conteneur et le codec, c&apos;est différent</p>

        <Choice<"avi" | "mp4" | "mkv">
          label="Conteneur — c'est lui que désigne l'extension"
          value={conteneur}
          options={[
            { value: "avi", label: ".avi" },
            { value: "mp4", label: ".mp4" },
            { value: "mkv", label: ".mkv" },
          ]}
          onChange={setConteneur}
        />

        <Choice<"oui" | "non">
          label="Le lecteur possède-t-il le codec ?"
          value={codecPresent ? "oui" : "non"}
          options={[
            { value: "oui", label: "Oui" },
            { value: "non", label: "Non" },
          ]}
          onChange={(v) => setCodecPresent(v === "oui")}
        />

        <div className="rounded-lg border border-border bg-slate-900 p-3">
          {codecPresent ? (
            <div className="space-y-1">
              <div className="h-14 rounded bg-gradient-to-r from-sky-700 via-emerald-600 to-amber-500" />
              <p className="font-mono text-[11px] text-emerald-400">image et son : d&apos;accord</p>
            </div>
          ) : (
            <div className="space-y-1">
              <div className="h-14 rounded bg-black" />
              <p className="font-mono text-[11px] text-rose-400">
                image : noire — son : d&apos;accord
              </p>
            </div>
          )}
        </div>

        {codecPresent ? (
          <Verdict tone="ok">
            Le conteneur <code>.{conteneur}</code> est l&apos;emballage — le carton — et le codec
            est la manière de plier ce qu&apos;on met dedans : H.264, H.265, DivX, VP9. Les deux
            sont reconnus, la vidéo se lit.
          </Verdict>
        ) : (
          <Verdict tone="bad">
            Le fichier <code>.{conteneur}</code> s&apos;ouvre — le conteneur est bien reconnu — mais
            le lecteur ne possède pas le <strong>décodeur</strong> du codec qu&apos;il contient :
            d&apos;où le son sans l&apos;image. C&apos;est l&apos;explication de ce{" "}
            <code>.avi</code> qui ne marche pas alors qu&apos;un autre <code>.avi</code> marche. La
            solution la plus simple : utiliser VLC, qui embarque ses propres codecs.
          </Verdict>
        )}
      </div>
    </div>
  );
}
