import { useMemo } from "react";
import katex from "katex";
import "katex/dist/katex.min.css";
import { cn } from "@/lib/utils";

type Segment = { kind: "text"; value: string } | { kind: "math"; value: string; display: boolean };

// $$...$$ et \[...\] : formule centrée ; $...$ et \(...\) : formule dans la ligne.
// \$ permet d'écrire un dollar littéral.
const MATH_PATTERN =
  /\\\$|\$\$([\s\S]+?)\$\$|\\\[([\s\S]+?)\\\]|\\\(([\s\S]+?)\\\)|\$([^$\n]+?)\$/g;

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

/** Affiche un texte de leçon en rendant les formules LaTeX avec KaTeX. */
export function MathText({ text, className }: { text: string; className?: string }) {
  const segments = useMemo(() => splitMath(text), [text]);
  return (
    <div className={cn("whitespace-pre-wrap", className)}>
      {segments.map((s, i) =>
        s.kind === "text" ? (
          <span key={i}>{s.value}</span>
        ) : (
          <span
            key={i}
            className={s.display ? "my-2 block overflow-x-auto text-center" : undefined}
            // KaTeX échappe le contenu (option trust désactivée par défaut).
            dangerouslySetInnerHTML={{
              __html: katex.renderToString(s.value, {
                displayMode: s.display,
                throwOnError: false,
              }),
            }}
          />
        ),
      )}
    </div>
  );
}
