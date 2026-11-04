// Détection de l'application Android (Capacitor) : elle charge le site dans une
// WebView dont l'agent utilisateur se termine par « MandalApp ».
import { useEffect, useState } from "react";

export function dansAppMobile(): boolean {
  if (typeof navigator === "undefined") return false;
  return navigator.userAgent.includes("MandalApp");
}

/** Vrai dans l'application mobile (faux au premier rendu, côté serveur). */
export function useAppMobile(): boolean {
  const [app, setApp] = useState(false);
  useEffect(() => setApp(dansAppMobile()), []);
  return app;
}
