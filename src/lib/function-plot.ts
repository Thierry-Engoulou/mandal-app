/**
 * Mini-moteur de calcul formel pour tracer des courbes de fonctions à une variable (x).
 * Pas d'eval() : on tokenise puis on construit un petit AST, évalué numériquement.
 * Supporte : + - * / ^, parenthèses, unaire -, et sin cos tan sqrt abs exp ln log pi e.
 */

type Token = { type: "num" | "ident" | "op"; value: string };

const FUNCS: Record<string, (a: number) => number> = {
  sin: Math.sin,
  cos: Math.cos,
  tan: Math.tan,
  sqrt: Math.sqrt,
  abs: Math.abs,
  exp: Math.exp,
  ln: Math.log,
  log: Math.log10,
};
const CONSTS: Record<string, number> = { pi: Math.PI, e: Math.E };

function tokenize(src: string): Token[] {
  const tokens: Token[] = [];
  let i = 0;
  while (i < src.length) {
    const c = src[i];
    if (/\s/.test(c)) {
      i++;
      continue;
    }
    if (/[0-9.]/.test(c)) {
      let j = i;
      while (j < src.length && /[0-9.]/.test(src[j])) j++;
      tokens.push({ type: "num", value: src.slice(i, j) });
      i = j;
      continue;
    }
    if (/[a-zA-Z]/.test(c)) {
      let j = i;
      while (j < src.length && /[a-zA-Z]/.test(src[j])) j++;
      tokens.push({ type: "ident", value: src.slice(i, j) });
      i = j;
      continue;
    }
    if ("+-*/^(),".includes(c)) {
      tokens.push({ type: "op", value: c });
      i++;
      continue;
    }
    throw new Error(`Caractère inattendu : "${c}"`);
  }
  return tokens;
}

type Node =
  | { kind: "num"; value: number }
  | { kind: "var" }
  | { kind: "const"; value: number }
  | { kind: "call"; name: string; arg: Node }
  | { kind: "unary"; arg: Node }
  | { kind: "bin"; op: "+" | "-" | "*" | "/" | "^"; left: Node; right: Node };

class Parser {
  private pos = 0;
  constructor(private tokens: Token[]) {}

  private peek() {
    return this.tokens[this.pos];
  }
  private next() {
    return this.tokens[this.pos++];
  }
  private expectOp(op: string) {
    const t = this.next();
    if (!t || t.type !== "op" || t.value !== op) {
      throw new Error(`Attendu "${op}"`);
    }
  }

  parse(): Node {
    const node = this.parseExpr();
    if (this.pos < this.tokens.length) throw new Error("Expression mal formée");
    return node;
  }

  private parseExpr(): Node {
    let left = this.parseTerm();
    while (this.peek() && this.peek().type === "op" && (this.peek().value === "+" || this.peek().value === "-")) {
      const op = this.next().value as "+" | "-";
      left = { kind: "bin", op, left, right: this.parseTerm() };
    }
    return left;
  }

  private parseTerm(): Node {
    let left = this.parseUnary();
    while (this.peek() && this.peek().type === "op" && (this.peek().value === "*" || this.peek().value === "/")) {
      const op = this.next().value as "*" | "/";
      left = { kind: "bin", op, left, right: this.parseUnary() };
    }
    return left;
  }

  private parseUnary(): Node {
    if (this.peek() && this.peek().type === "op" && this.peek().value === "-") {
      this.next();
      return { kind: "unary", arg: this.parseUnary() };
    }
    return this.parsePower();
  }

  private parsePower(): Node {
    const base = this.parsePrimary();
    if (this.peek() && this.peek().type === "op" && this.peek().value === "^") {
      this.next();
      const exponent = this.parseUnary();
      return { kind: "bin", op: "^", left: base, right: exponent };
    }
    return base;
  }

  private parsePrimary(): Node {
    const t = this.next();
    if (!t) throw new Error("Expression incomplète");
    if (t.type === "num") return { kind: "num", value: Number(t.value) };
    if (t.type === "op" && t.value === "(") {
      const inner = this.parseExpr();
      this.expectOp(")");
      return inner;
    }
    if (t.type === "ident") {
      const name = t.value.toLowerCase();
      if (name === "x") return { kind: "var" };
      if (name in CONSTS) return { kind: "const", value: CONSTS[name] };
      if (this.peek() && this.peek().type === "op" && this.peek().value === "(") {
        this.next();
        const arg = this.parseExpr();
        this.expectOp(")");
        if (!(name in FUNCS)) throw new Error(`Fonction inconnue : "${name}"`);
        return { kind: "call", name, arg };
      }
      throw new Error(`Identifiant inconnu : "${name}"`);
    }
    throw new Error("Expression mal formée");
  }
}

function evalNode(node: Node, x: number): number {
  switch (node.kind) {
    case "num":
      return node.value;
    case "var":
      return x;
    case "const":
      return node.value;
    case "unary":
      return -evalNode(node.arg, x);
    case "call":
      return FUNCS[node.name](evalNode(node.arg, x));
    case "bin": {
      const l = evalNode(node.left, x);
      const r = evalNode(node.right, x);
      if (node.op === "+") return l + r;
      if (node.op === "-") return l - r;
      if (node.op === "*") return l * r;
      if (node.op === "/") return l / r;
      return Math.pow(l, r);
    }
  }
}

/** Compile une expression texte (ex: "x^2 - 2*x + 1") en fonction numérique évaluable. */
export function compileExpression(expr: string): (x: number) => number {
  const ast = new Parser(tokenize(expr)).parse();
  return (x: number) => evalNode(ast, x);
}

export type PlotFunction = { expr: string; label?: string; color?: string };
export type PlotPoint = { x: number; y: number; label?: string };
export type GraphSpec = {
  functions: PlotFunction[];
  domain?: [number, number];
  range?: [number, number];
  points?: PlotPoint[];
};

/** Échantillonne une fonction compilée sur un domaine ; NaN/Infinity coupent le tracé (asymptotes). */
export function sample(fn: (x: number) => number, domain: [number, number], steps = 400) {
  const [xMin, xMax] = domain;
  const pts: { x: number; y: number }[] = [];
  for (let i = 0; i <= steps; i++) {
    const x = xMin + ((xMax - xMin) * i) / steps;
    let y: number;
    try {
      y = fn(x);
    } catch {
      y = NaN;
    }
    pts.push({ x, y: Number.isFinite(y) ? y : NaN });
  }
  return pts;
}
