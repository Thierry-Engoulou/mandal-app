import { createElement, Fragment, type ReactNode } from "react";

/**
 * Petit moteur de rendu HTML pour les simulations d'informatique.
 * Il n'injecte jamais de HTML brut : il analyse la source, construit un arbre,
 * puis fabrique des éléments React à partir d'une liste de balises autorisées.
 * Les balises inconnues et les imbrications fautives sont signalées à l'élève.
 */

export type Noeud =
  | { kind: "el"; tag: string; attrs: Record<string, string>; enfants: Noeud[] }
  | { kind: "txt"; texte: string };

const VIDES = new Set(["br", "hr", "img", "input", "meta", "link"]);

const AUTORISEES = new Set([
  "h1",
  "h2",
  "h3",
  "h4",
  "h5",
  "h6",
  "p",
  "br",
  "hr",
  "strong",
  "em",
  "b",
  "i",
  "u",
  "span",
  "div",
  "code",
  "pre",
  "ul",
  "ol",
  "li",
  "dl",
  "dt",
  "dd",
  "table",
  "caption",
  "thead",
  "tbody",
  "tfoot",
  "tr",
  "th",
  "td",
  "a",
  "img",
  "form",
  "label",
  "input",
  "select",
  "option",
  "textarea",
  "fieldset",
  "legend",
  "button",
]);

const ATTRS_OK = new Set([
  "href",
  "src",
  "alt",
  "width",
  "height",
  "border",
  "cellpadding",
  "cellspacing",
  "colspan",
  "rowspan",
  "type",
  "name",
  "value",
  "placeholder",
  "rows",
  "cols",
  "id",
  "for",
  "selected",
  "checked",
  "required",
  "target",
]);

export type Erreur = { message: string };

export function analyserHtml(source: string): { arbre: Noeud[]; erreurs: Erreur[] } {
  const erreurs: Erreur[] = [];
  const racine: Noeud[] = [];
  const pile: Array<{ tag: string; enfants: Noeud[] }> = [];

  const pousser = (n: Noeud) => {
    const haut = pile[pile.length - 1];
    if (haut) haut.enfants.push(n);
    else racine.push(n);
  };

  const balise =
    /<(\/?)([a-zA-Z][a-zA-Z0-9]*)((?:\s+[a-zA-Z-]+(?:\s*=\s*(?:"[^"]*"|'[^']*'|[^\s>]+))?)*)\s*(\/?)>/g;

  let pos = 0;
  let m = balise.exec(source);
  while (m !== null) {
    if (m.index > pos) {
      const brut = source.slice(pos, m.index);
      if (brut.trim() !== "") pousser({ kind: "txt", texte: brut.replace(/\s+/g, " ") });
    }

    const fermante = m[1] === "/";
    const tag = (m[2] ?? "").toLowerCase();
    const brutAttrs = m[3] ?? "";
    const autoFerme = m[4] === "/";

    if (!AUTORISEES.has(tag)) {
      erreurs.push({
        message: `La balise <${tag}> n'est pas reconnue. Vérifie l'orthographe : les balises du programme sont peu nombreuses.`,
      });
    } else if (fermante) {
      const haut = pile[pile.length - 1];
      if (!haut) {
        erreurs.push({
          message: `</${tag}> ferme une balise qui n'a jamais été ouverte.`,
        });
      } else if (haut.tag !== tag) {
        erreurs.push({
          message: `Les balises se croisent : tu fermes </${tag}> alors que <${haut.tag}> est encore ouverte. Elles se ferment comme des parenthèses — la dernière ouverte est la première fermée.`,
        });
        // on referme quand même pour continuer l'analyse
        const fini = pile.pop();
        if (fini) pousser({ kind: "el", tag: fini.tag, attrs: {}, enfants: fini.enfants });
      } else {
        const fini = pile.pop();
        if (fini) pousser({ kind: "el", tag: fini.tag, attrs: {}, enfants: fini.enfants });
      }
    } else {
      const attrs: Record<string, string> = {};
      const re = /([a-zA-Z-]+)(?:\s*=\s*(?:"([^"]*)"|'([^']*)'|([^\s>]+)))?/g;
      let a = re.exec(brutAttrs);
      while (a !== null) {
        const nom = (a[1] ?? "").toLowerCase();
        const val = a[2] ?? a[3] ?? a[4] ?? "";
        if (ATTRS_OK.has(nom)) attrs[nom] = val;
        a = re.exec(brutAttrs);
      }

      if (VIDES.has(tag) || autoFerme) {
        pousser({ kind: "el", tag, attrs, enfants: [] });
      } else {
        pile.push({ tag, enfants: [] });
        // les attributs sont rattachés à la fermeture : on les garde ici
        const haut = pile[pile.length - 1];
        if (haut) Object.assign(haut, { attrs });
      }
    }

    pos = m.index + m[0].length;
    m = balise.exec(source);
  }

  if (pos < source.length) {
    const reste = source.slice(pos);
    if (reste.trim() !== "") pousser({ kind: "txt", texte: reste.replace(/\s+/g, " ") });
  }

  while (pile.length > 0) {
    const fini = pile.pop();
    if (!fini) break;
    erreurs.push({
      message: `La balise <${fini.tag}> n'a jamais été fermée. Il manque </${fini.tag}>.`,
    });
    const haut = pile[pile.length - 1];
    const n: Noeud = { kind: "el", tag: fini.tag, attrs: {}, enfants: fini.enfants };
    if (haut) haut.enfants.push(n);
    else racine.push(n);
  }

  return { arbre: racine, erreurs };
}

function lienSur(href: string): string | undefined {
  if (/^(https?:\/\/|mailto:|#)/i.test(href)) return href;
  return undefined;
}

function nombre(v: string | undefined): number | undefined {
  if (v === undefined) return undefined;
  const n = Number(v.replace("%", ""));
  return Number.isFinite(n) ? n : undefined;
}

function rendre(n: Noeud, cle: number): ReactNode {
  if (n.kind === "txt") return n.texte;

  const enfants = n.enfants.map((e, k) => rendre(e, k));

  if (n.tag === "img") {
    const l = nombre(n.attrs["width"]) ?? 120;
    const h = nombre(n.attrs["height"]) ?? Math.round(l * 0.66);
    return createElement(
      "span",
      {
        key: cle,
        style: {
          display: "inline-flex",
          alignItems: "center",
          justifyContent: "center",
          width: Math.min(l, 320),
          height: Math.min(h, 240),
          border: "1px dashed #94a3b8",
          background: "#f1f5f9",
          color: "#64748b",
          fontSize: 10,
          textAlign: "center",
          padding: 4,
          margin: "2px 4px",
        },
      },
      n.attrs["alt"] ?? "image sans attribut alt",
    );
  }

  if (n.tag === "a") {
    const href = lienSur(n.attrs["href"] ?? "");
    return createElement(
      "span",
      {
        key: cle,
        style: {
          color: href ? "#2563eb" : "#b91c1c",
          textDecoration: "underline",
          cursor: "pointer",
        },
        title: href ? `va vers ${href}` : "lien dont l'adresse n'est pas valable",
      },
      enfants.length > 0 ? enfants : "lien sans texte",
    );
  }

  if (n.tag === "input") {
    const type = (n.attrs["type"] ?? "text").toLowerCase();
    if (type === "submit" || type === "reset" || type === "button") {
      return createElement(
        "button",
        {
          key: cle,
          type: "button",
          style: {
            border: "1px solid #94a3b8",
            borderRadius: 4,
            padding: "2px 8px",
            fontSize: 11,
            background: "#e2e8f0",
            margin: 2,
          },
        },
        n.attrs["value"] ?? "Envoyer",
      );
    }
    const commun = {
      key: cle,
      readOnly: true,
      style: {
        border: "1px solid #cbd5e1",
        borderRadius: 3,
        padding: "1px 4px",
        fontSize: 11,
        margin: 2,
      },
    };
    if (type === "radio" || type === "checkbox") {
      return createElement("input", { ...commun, type, name: n.attrs["name"] ?? undefined });
    }
    return createElement("input", {
      ...commun,
      type: type === "password" ? "password" : "text",
      placeholder: n.attrs["placeholder"] ?? "",
      value: n.attrs["value"] ?? "",
    });
  }

  if (n.tag === "textarea") {
    return createElement("textarea", {
      key: cle,
      readOnly: true,
      rows: nombre(n.attrs["rows"]) ?? 3,
      cols: nombre(n.attrs["cols"]) ?? 30,
      style: { border: "1px solid #cbd5e1", borderRadius: 3, fontSize: 11, margin: 2 },
      value: n.enfants.map((e) => (e.kind === "txt" ? e.texte : "")).join(""),
    });
  }

  if (n.tag === "table") {
    const bord = nombre(n.attrs["border"]) ?? 0;
    const esp = nombre(n.attrs["cellspacing"]) ?? 2;
    return createElement(
      "table",
      {
        key: cle,
        style: {
          borderCollapse: "separate" as const,
          borderSpacing: esp,
          border: bord > 0 ? `${bord}px solid #334155` : "none",
          fontSize: 11,
          margin: "4px 0",
        },
      },
      createElement("tbody", { key: "tb" }, enfants),
    );
  }

  if (n.tag === "th" || n.tag === "td") {
    return createElement(
      n.tag,
      {
        key: cle,
        colSpan: nombre(n.attrs["colspan"]) ?? undefined,
        rowSpan: nombre(n.attrs["rowspan"]) ?? undefined,
        style: {
          border: "1px solid #94a3b8",
          padding: "3px 6px",
          fontWeight: n.tag === "th" ? 700 : 400,
          background: n.tag === "th" ? "#f1f5f9" : "transparent",
        },
      },
      enfants,
    );
  }

  // thead, tbody et tfoot regroupent des lignes : on les traverse sans rien dessiner
  if (n.tag === "thead" || n.tag === "tbody" || n.tag === "tfoot") {
    return createElement(Fragment, { key: cle }, enfants);
  }

  if (n.tag === "select") {
    const options = n.enfants
      .filter(
        (e): e is { kind: "el"; tag: string; attrs: Record<string, string>; enfants: Noeud[] } =>
          e.kind === "el" && e.tag === "option",
      )
      .map((e, k) =>
        createElement(
          "option",
          { key: k },
          e.enfants.map((x) => (x.kind === "txt" ? x.texte : "")).join(""),
        ),
      );
    return createElement(
      "select",
      {
        key: cle,
        disabled: true,
        style: { border: "1px solid #cbd5e1", borderRadius: 3, fontSize: 11, margin: 2 },
      },
      options,
    );
  }

  if (n.tag === "fieldset") {
    return createElement(
      "fieldset",
      {
        key: cle,
        style: { border: "1px solid #94a3b8", borderRadius: 4, padding: 8, margin: "6px 0" },
      },
      enfants,
    );
  }

  if (n.tag === "legend") {
    return createElement("legend", { key: cle, style: { fontSize: 11, fontWeight: 700 } }, enfants);
  }

  if (n.tag === "caption") {
    return createElement(
      "caption",
      {
        key: cle,
        style: { fontSize: 11, fontWeight: 700, captionSide: "top" as const, paddingBottom: 3 },
      },
      enfants,
    );
  }

  if (n.tag === "hr") {
    return createElement("hr", {
      key: cle,
      style: { border: "none", borderTop: "1px solid #cbd5e1", margin: "6px 0" },
    });
  }

  if (n.tag === "br") return createElement("br", { key: cle });

  const tailles: Record<string, number> = { h1: 20, h2: 17, h3: 15, h4: 13, h5: 12, h6: 11 };
  const t = tailles[n.tag];
  if (t !== undefined) {
    return createElement(
      n.tag,
      { key: cle, style: { fontSize: t, fontWeight: 700, margin: "6px 0 3px" } },
      enfants,
    );
  }

  if (n.tag === "ul" || n.tag === "ol") {
    return createElement(
      n.tag,
      { key: cle, style: { paddingLeft: 20, margin: "4px 0", fontSize: 12 } },
      enfants,
    );
  }

  return createElement(n.tag, { key: cle, style: { fontSize: 12, margin: "3px 0" } }, enfants);
}

export function RenduHtml({ source }: { source: string }) {
  const { arbre } = analyserHtml(source);
  return (
    <div className="rounded-lg border border-border bg-white p-3 text-slate-900">
      {arbre.length === 0 ? (
        <p className="text-xs text-slate-400">La page est vide : rien à afficher.</p>
      ) : (
        arbre.map((n, k) => rendre(n, k))
      )}
    </div>
  );
}
