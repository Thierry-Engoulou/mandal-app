/**
 * Extraction de texte depuis un fichier importé (navigateur uniquement).
 * Formats gérés : .txt, .md, .docx, .pdf
 */

export const ACCEPTED_IMPORT_TYPES = ".txt,.md,.markdown,.docx,.pdf";

function cleanup(text: string): string {
  return text
    .replace(/\r\n/g, "\n")
    .replace(/\n{3,}/g, "\n\n")
    .trim();
}

async function readDocx(file: File): Promise<string> {
  const mammoth = await import("mammoth/mammoth.browser.js" as string);
  const arrayBuffer = await file.arrayBuffer();
  const result = await (mammoth.default ?? mammoth).extractRawText({ arrayBuffer });
  return result.value as string;
}

async function readPdf(file: File): Promise<string> {
  const pdfjs = await import("pdfjs-dist");
  const workerUrl = (await import("pdfjs-dist/build/pdf.worker.min.mjs?url")).default;
  pdfjs.GlobalWorkerOptions.workerSrc = workerUrl;

  const data = new Uint8Array(await file.arrayBuffer());
  const pdf = await pdfjs.getDocument({ data }).promise;
  const pages: string[] = [];

  for (let pageNumber = 1; pageNumber <= pdf.numPages; pageNumber += 1) {
    const page = await pdf.getPage(pageNumber);
    const content = await page.getTextContent();
    const text = content.items
      .map((item) => ("str" in item ? item.str : ""))
      .join(" ")
      .replace(/\s+/g, " ");
    pages.push(text.trim());
  }

  return pages.filter(Boolean).join("\n\n");
}

export async function extractTextFromFile(file: File): Promise<string> {
  const name = file.name.toLowerCase();

  if (name.endsWith(".docx")) return cleanup(await readDocx(file));
  if (name.endsWith(".pdf")) return cleanup(await readPdf(file));
  if (name.endsWith(".txt") || name.endsWith(".md") || name.endsWith(".markdown")) {
    return cleanup(await file.text());
  }
  if (name.endsWith(".doc")) {
    throw new Error("Le format .doc n'est pas géré. Enregistrez le fichier en .docx puis réessayez.");
  }

  throw new Error("Format non pris en charge. Utilisez un fichier .txt, .md, .docx ou .pdf.");
}

/** Déduit un titre à partir du nom de fichier. */
export function titleFromFileName(fileName: string): string {
  return fileName
    .replace(/\.[^.]+$/, "")
    .replace(/[_-]+/g, " ")
    .replace(/\s+/g, " ")
    .trim();
}
