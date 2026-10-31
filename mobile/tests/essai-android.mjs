// Essai de l'application sur un émulateur Android (workflow GitHub « Android »).
// Pilote la WebView de l'app avec Playwright et vérifie les parcours clés.
// Identifiants de test facultatifs : secrets GitHub MANDAL_TEST_EMAIL et
// MANDAL_TEST_PASSWORD (un compte élève) ; sans eux, les essais connectés sont sautés.
import { _android as android } from "playwright";
import { mkdirSync, writeFileSync } from "node:fs";

const PKG = "cm.mandal.education";
const SITE = "https://mandal-education.vercel.app";
const DOSSIER = process.env.CAPTURES ?? "captures";
const EMAIL = process.env.MANDAL_TEST_EMAIL ?? "";
const MOT_DE_PASSE = process.env.MANDAL_TEST_PASSWORD ?? "";
mkdirSync(DOSSIER, { recursive: true });

const resultats = [];
const attendre = (ms) => new Promise((r) => setTimeout(r, ms));

const [device] = await android.devices();
if (!device) throw new Error("Aucun appareil Android détecté.");
console.log(`Appareil : ${device.model()} (${device.serial()})`);

async function capture(nom) {
  await device.screenshot({ path: `${DOSSIER}/${nom}.png` });
}

async function essai(nom, fn) {
  const debut = Date.now();
  try {
    const detail = await fn();
    if (detail === "SAUTÉ") {
      resultats.push({ nom, statut: "SAUTÉ" });
      console.log(`⏭️  ${nom} : sauté (pas d'identifiants de test)`);
      return;
    }
    resultats.push({ nom, statut: "OK", detail });
    console.log(`✅ ${nom}${detail ? ` : ${detail}` : ""} (${Date.now() - debut} ms)`);
  } catch (e) {
    resultats.push({ nom, statut: "ÉCHEC", detail: String(e?.message ?? e).slice(0, 400) });
    console.log(`❌ ${nom} : ${String(e?.message ?? e).slice(0, 400)}`);
    await capture(`echec-${nom.replace(/[^a-z0-9]+/gi, "-")}`).catch(() => {});
  }
}

/** Intentions Android lancées depuis le début du test (logcat). */
async function intentions() {
  const log = (await device.shell("logcat -d -s ActivityTaskManager:I")).toString();
  return log.split("\n").filter((l) => l.includes("START u0"));
}

async function reseau(actif) {
  const etat = actif ? "enable" : "disable";
  await device.shell(`svc wifi ${etat}`);
  await device.shell(`svc data ${etat}`);
  await attendre(4000);
}

// --- Lancement -------------------------------------------------------------
await device.shell("logcat -c");
await device.shell(`am force-stop ${PKG}`);
await device.shell(`am start -W -n ${PKG}/.MainActivity`);
const webview = await device.webView({ pkg: PKG }, { timeout: 120000 });
const page = await webview.page();
page.setDefaultTimeout(60000);

// Les essais ne doivent pas gonfler les statistiques du site.
await page.waitForLoadState("domcontentloaded");
await page.evaluate(() => localStorage.setItem("mandal_statistiques_refus", "1")).catch(() => {});

await essai("Ouverture de l'application", async () => {
  await page.waitForURL(/mandal-education\.vercel\.app/, { timeout: 90000 });
  await page.waitForLoadState("load");
  const ua = await page.evaluate(() => navigator.userAgent);
  if (!ua.includes("MandalApp")) throw new Error(`Agent utilisateur sans « MandalApp » : ${ua}`);
  await attendre(3000);
  await capture("01-accueil");
  return `page « ${await page.title()} »`;
});

// --- 1. Connexion ------------------------------------------------------------
await essai("Page de connexion (sans bouton Google)", async () => {
  await page.goto(`${SITE}/auth`);
  await page.locator("#email").waitFor();
  await attendre(1500);
  const google = await page.getByText(/avec Google/).count();
  await capture("02-connexion");
  if (google > 0) throw new Error("Le bouton Google est encore affiché dans l'app.");
  return "formulaire e-mail / téléphone affiché, Google masqué";
});

let connecte = false;
await essai("Connexion par e-mail", async () => {
  if (!EMAIL || !MOT_DE_PASSE) return "SAUTÉ";
  await page.goto(`${SITE}/auth`);
  await page.locator("#email").fill(EMAIL);
  await page.locator("#password").fill(MOT_DE_PASSE);
  await page.locator('button[type="submit"]').click();
  await page.waitForURL((u) => !u.pathname.startsWith("/auth"), { timeout: 60000 });
  await page.waitForLoadState("load");
  await attendre(3000);
  await capture("03-espace-connecte");
  connecte = true;
  return `redirigé vers ${new URL(page.url()).pathname}`;
});

// --- 2. Un cours -------------------------------------------------------------
await essai("Ouverture d'un cours", async () => {
  await page.goto(`${SITE}/courses`);
  const lien = page.locator('a[href^="/courses/"]:not([href="/courses/new"])').first();
  await lien.waitFor({ timeout: 60000 });
  await capture("04-catalogue-cours");
  await lien.click();
  await page.waitForURL(/\/courses\/[0-9a-f-]{36}/);
  await page.waitForLoadState("load");
  await attendre(3000);
  const titre = (await page.locator("h1").first().textContent())?.trim();
  await capture("05-cours");
  if (!titre) throw new Error("Page du cours sans titre.");
  return `cours « ${titre} »`;
});

// --- 3. Téléchargement d'une épreuve ----------------------------------------
await essai("Téléchargement d'une épreuve", async () => {
  await page.goto(`${SITE}/banque-epreuves`);
  const bouton = page.getByRole("button", { name: /Télécharger/ }).first();
  await bouton.waitFor({ timeout: 60000 });
  await capture("06-banque");
  await device.shell("logcat -c");
  await bouton.click();
  let lancees = [];
  for (let i = 0; i < 20 && !lancees.some((l) => l.includes("supabase.co")); i++) {
    await attendre(1000);
    lancees = await intentions();
  }
  await attendre(3000);
  await capture("07-telechargement");
  const pdf = lancees.find((l) => l.includes("supabase.co"));
  if (!pdf)
    throw new Error(
      `Aucun lien de téléchargement ouvert. Intentions : ${lancees.join(" | ") || "aucune"}`,
    );
  return "le PDF s'ouvre dans le navigateur du téléphone";
});
await device.shell(`am start -W -n ${PKG}/.MainActivity`);
await attendre(2000);

// --- 4. Correction de copie avec l'appareil photo ---------------------------
await essai("Correction de copie : appareil photo", async () => {
  if (!connecte) return "SAUTÉ";
  await page.goto(`${SITE}/etudiant/correction`);
  const majeur = page.getByRole("button", { name: /18 ans ou plus/ });
  if (await majeur.isVisible({ timeout: 15000 }).catch(() => false)) await majeur.click();
  const photo = page.getByText("Prendre une photo").first();
  await photo.waitFor({ timeout: 60000 });
  await capture("08-correction");
  await device.shell("logcat -c");
  await photo.click();
  let lancees = [];
  for (let i = 0; i < 15 && !lancees.length; i++) {
    await attendre(1000);
    lancees = await intentions();
  }
  await attendre(3000);
  await capture("09-appareil-photo");
  const camera = lancees.find((l) => /IMAGE_CAPTURE|camera|CHOOSER|GET_CONTENT/i.test(l));
  if (!camera)
    throw new Error(
      `L'appareil photo ne s'est pas ouvert. Intentions : ${lancees.join(" | ") || "aucune"}`,
    );
  return "l'appareil photo s'ouvre";
});
await device.shell("input keyevent KEYCODE_BACK");
await device.shell(`am start -W -n ${PKG}/.MainActivity`);
await attendre(2000);

// --- 5. Sans internet --------------------------------------------------------
await essai("Mode sans internet", async () => {
  await reseau(false);
  await page.goto(`${SITE}/a-propos`).catch(() => {});
  await page.getByText("Pas de connexion internet").waitFor({ timeout: 30000 });
  await capture("10-hors-ligne");
  await reseau(true);
  await page.getByRole("button", { name: "Réessayer" }).click();
  await page.waitForURL(/mandal-education\.vercel\.app/, { timeout: 60000 });
  await page.waitForLoadState("load");
  await attendre(3000);
  await capture("11-retour-en-ligne");
  return "page « Pas de connexion internet », puis retour au site avec « Réessayer »";
});
await reseau(true);

// --- Bilan -------------------------------------------------------------------
writeFileSync(`${DOSSIER}/resultats.json`, JSON.stringify(resultats, null, 2));
console.log("\n===== BILAN =====");
for (const r of resultats)
  console.log(`${r.statut.padEnd(6)} ${r.nom}${r.detail ? ` — ${r.detail}` : ""}`);
await device.close();
if (resultats.some((r) => r.statut === "ÉCHEC")) process.exit(1);
