import { useMemo, type ReactNode } from "react";
import katex from "katex";
import "katex/dist/katex.min.css";
import { cn } from "@/lib/utils";

/*
 * Mise en forme légère des textes de leçon :
 *   ## Titre              -> sous-titre avec barre bleue
 *   - élément             -> liste à puces (lignes consécutives)
 *   | a | b |             -> tableau (1re ligne = en-têtes, |---| ignorée)
 *   $$ formule $$         -> seule sur sa ligne : formule centrée encadrée
 *   $x$, \(x\), $$x$$     -> formules dans le texte ; \$ = dollar littéral
 *   **gras**
 * Toute autre ligne reste un paragraphe qui garde ses espaces et retours
 * à la ligne : un texte sans ces symboles s'affiche exactement comme avant.
 */

type Segment = { kind: "text"; value: string } | { kind: "math"; value: string; display: boolean };

type Block =
  | { kind: "paragraph"; text: string }
  | { kind: "heading"; text: string }
  | { kind: "list"; items: string[] }
  | { kind: "table"; header: string[]; rows: string[][] }
  | { kind: "formula"; tex: string };

// $$...$$ et \[...\] : formule centrée ; $...$ et \(...\) : formule dans la ligne.
// \$ permet d'écrire un dollar littéral.
const MATH_PATTERN =
  /\\\$|\$\$([\s\S]+?)\$\$|\\\[([\s\S]+?)\\\]|\\\(([\s\S]+?)\\\)|\$([^$\n]+?)\$/g;

const HEADING_LINE = /^\s*##\s+(.+?)\s*$/;
const LIST_LINE = /^\s*-\s+(.*)$/;
const TABLE_LINE = /^\s*\|/;
const TABLE_SEPARATOR = /^\s*\|?\s*:?-{2,}:?\s*(\|\s*:?-{2,}:?\s*)*\|?\s*$/;
const FORMULA_LINE = /^\s*\$\$([\s\S]+?)\$\$\s*$/;

function splitMath(source: string): Segment[] {
  const segments: Segment[] = [];
  let text = "";
  let last = 0;
  for (const match of source.matchAll(MATH_PATTERN)) {
    text += source.slice(last, match.index);
    last = match.index + match[0].length;
    if (match[0] === "\\$") {
      text += "$";
      continue;
    }
    if (text) segments.push({ kind: "text", value: text });
    text = "";
    const display = match[1] ?? match[2];
    segments.push(
      display !== undefined
        ? { kind: "math", value: display.trim(), display: true }
        : { kind: "math", value: (match[3] ?? match[4] ?? "").trim(), display: false },
    );
  }
  text += source.slice(last);
  if (text) segments.push({ kind: "text", value: text });
  return segments;
}

/** Copie de `source` où le contenu des formules est neutralisé (même longueur),
 *  pour chercher `**` ou `|` sans toucher à ce qui est à l'intérieur d'une formule. */
function maskMath(source: string): string {
  return source.replace(MATH_PATTERN, (m) => (m === "\\$" ? m : "\u0001".repeat(m.length)));
}

function renderTex(tex: string, display: boolean) {
  // KaTeX échappe le contenu (option trust désactivée par défaut).
  return { __html: katex.renderToString(tex, { displayMode: display, throwOnError: false }) };
}

function renderMath(source: string): ReactNode[] {
  return splitMath(source).map((s, i) =>
    s.kind === "text" ? (
      <span key={i}>{s.value}</span>
    ) : (
      <span
        key={i}
        className={s.display ? "my-2 block overflow-x-auto text-center" : undefined}
        dangerouslySetInnerHTML={renderTex(s.value, s.display)}
      />
    ),
  );
}

/** Texte d'une ligne : formules + **gras** (le gras peut contenir des formules). */
function renderInline(source: string): ReactNode[] {
  const masked = maskMath(source);
  const nodes: ReactNode[] = [];
  let last = 0;
  for (const match of masked.matchAll(/\*\*(?=\S)([\s\S]*?\S)\*\*/g)) {
    if (match.index > last) nodes.push(...renderMath(source.slice(last, match.index)));
    const inner = source.slice(match.index + 2, match.index + match[0].length - 2);
    nodes.push(<strong key={`b${match.index}`}>{renderMath(inner)}</strong>);
    last = match.index + match[0].length;
  }
  if (last < source.length) nodes.push(...renderMath(source.slice(last)));
  return nodes.map((n, i) => <span key={i}>{n}</span>);
}

function splitCells(line: string): string[] {
  let row = line.trim();
  if (row.startsWith("|")) row = row.slice(1);
  if (row.endsWith("|") && !row.endsWith("\\|")) row = row.slice(0, -1);
  // On découpe sur les | hors formules : $|x|$ reste dans sa cellule.
  const masked = maskMath(row);
  const cells: string[] = [];
  let start = 0;
  for (let i = 0; i < masked.length; i++) {
    if (masked[i] === "|") {
      cells.push(row.slice(start, i).trim());
      start = i + 1;
    }
  }
  cells.push(row.slice(start).trim());
  return cells;
}

function isBlank(line: string) {
  return line.trim() === "";
}

function parseBlocks(text: string): Block[] {
  const lines = text.split("\n");
  const blocks: Block[] = [];
  let paragraph: string[] = [];

  const flushParagraph = (beforeBlock: boolean) => {
    // Lignes vides collées à un titre, une liste, etc. : l'espacement est géré
    // par le bloc lui-même.
    if (beforeBlock)
      while (paragraph.length > 0 && isBlank(paragraph[paragraph.length - 1]!)) paragraph.pop();
    if (blocks.length > 0) while (paragraph.length > 0 && isBlank(paragraph[0]!)) paragraph.shift();
    if (paragraph.length > 0) blocks.push({ kind: "paragraph", text: paragraph.join("\n") });
    paragraph = [];
  };

  let i = 0;
  while (i < lines.length) {
    const line = lines[i]!;

    const heading = HEADING_LINE.exec(line);
    if (heading) {
      flushParagraph(true);
      blocks.push({ kind: "heading", text: heading[1]! });
      i++;
      continue;
    }

    const formula = FORMULA_LINE.exec(line);
    if (formula && !formula[1]!.includes("$$")) {
      flushParagraph(true);
      blocks.push({ kind: "formula", tex: formula[1]!.trim() });
      i++;
      continue;
    }

    // $$ ouvert seul sur sa ligne, fermé quelques lignes plus bas.
    if (line.trim().startsWith("$$") && !line.trim().slice(2).includes("$$")) {
      const end = lines.findIndex((l, j) => j > i && l.trim().endsWith("$$"));
      if (end !== -1) {
        const tex = [
          line.trim().slice(2),
          ...lines.slice(i + 1, end),
          lines[end]!.trim().slice(0, -2),
        ]
          .join("\n")
          .trim();
        flushParagraph(true);
        blocks.push({ kind: "formula", tex });
        i = end + 1;
        continue;
      }
    }

    if (LIST_LINE.test(line)) {
      flushParagraph(true);
      const items: string[] = [];
      while (i < lines.length && LIST_LINE.test(lines[i]!)) {
        items.push(LIST_LINE.exec(lines[i]!)![1]!);
        i++;
      }
      blocks.push({ kind: "list", items });
      continue;
    }

    if (TABLE_LINE.test(line)) {
      flushParagraph(true);
      const rows: string[][] = [];
      while (i < lines.length && TABLE_LINE.test(lines[i]!)) {
        if (!TABLE_SEPARATOR.test(lines[i]!)) rows.push(splitCells(lines[i]!));
        i++;
      }
      const [header = [], ...body] = rows;
      blocks.push({ kind: "table", header, rows: body });
      continue;
    }

    paragraph.push(line);
    i++;
  }
  flushParagraph(false);
  return blocks;
}

function BlockView({ block }: { block: Block }) {
  switch (block.kind) {
    case "paragraph":
      return <div className="whitespace-pre-wrap">{renderInline(block.text)}</div>;
    case "heading":
      return (
        <h3 className="border-l-4 border-primary pl-3 font-display text-base font-bold text-foreground">
          {renderInline(block.text)}
        </h3>
      );
    case "list":
      return (
        <ul className="list-disc space-y-1 pl-6">
          {block.items.map((item, i) => (
            <li key={i}>{renderInline(item)}</li>
          ))}
        </ul>
      );
    case "formula":
      return (
        <div
          className="overflow-x-auto rounded-xl border border-border bg-secondary px-4 py-3 text-center"
          dangerouslySetInnerHTML={renderTex(block.tex, true)}
        />
      );
    case "table": {
      const columns = Math.max(block.header.length, ...block.rows.map((r) => r.length));
      const pad = (cells: string[]) => Array.from({ length: columns }, (_, i) => cells[i] ?? "");
      return (
        <div className="overflow-x-auto">
          <table className="min-w-full border-collapse border border-border text-center">
            {block.header.length > 0 && (
              <thead className="bg-secondary">
                <tr>
                  {pad(block.header).map((cell, i) => (
                    <th key={i} className="border border-border px-3 py-2 font-semibold">
                      {renderInline(cell)}
                    </th>
                  ))}
                </tr>
              </thead>
            )}
            <tbody>
              {block.rows.map((row, r) => (
                <tr key={r}>
                  {pad(row).map((cell, i) => (
                    <td key={i} className="border border-border px-3 py-2">
                      {renderInline(cell)}
                    </td>
                  ))}
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      );
    }
  }
}

/** Affiche un texte de leçon : formules LaTeX (KaTeX), titres, listes, tableaux, gras. */
export function MathText({ text, className }: { text: string; className?: string }) {
  const blocks = useMemo(() => parseBlocks(text), [text]);
  return (
    <div className={cn("space-y-3", className)}>
      {blocks.map((block, i) => (
        <BlockView key={i} block={block} />
      ))}
    </div>
  );
}
