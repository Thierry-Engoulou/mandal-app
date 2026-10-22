import { createFileRoute } from "@tanstack/react-router";
import { useState } from "react";
import { LegalLayout } from "@/components/legal/legal-layout";
import { Button } from "@/components/ui/button";
import { compterVisites, desactiverComptage } from "@/lib/site-analytics";

export const Route = createFileRoute("/cookies")({
  head: () => ({
    meta: [
      { title: "Cookies et traceurs — M'ANDAL" },
      { name: "description", content: "Les traceurs utilisés par M'ANDAL et comment t'y opposer." },
    ],
  }),
  component: CookiesPage,
});

function CookiesPage() {
  const [compte, setCompte] = useState(() => compterVisites());

  return (
    <LegalLayout titre="Cookies et traceurs">
      <p>
        M'ANDAL n'utilise <strong>aucun traceur publicitaire</strong>, aucun outil de réseau social
        et aucun service de statistiques externe (pas de Google Analytics). Voici tout ce que le
        site enregistre dans ton navigateur.
      </p>

      <div className="overflow-x-auto">
        <table className="min-w-[560px]">
          <thead>
            <tr>
              <th>Nom</th>
              <th>À quoi il sert</th>
              <th>Durée</th>
              <th>Ton accord</th>
            </tr>
          </thead>
          <tbody>
            <tr>
              <td>Session de connexion (sb-…-auth-token)</td>
              <td>Te garder connecté à ton compte</td>
              <td>Jusqu'à la déconnexion</td>
              <td>Pas nécessaire : indispensable au service</td>
            </tr>
            <tr>
              <td>mandal.inscription.role</td>
              <td>Retenir ton rôle (élève ou enseignant) pendant l'inscription avec Google</td>
              <td>Quelques minutes</td>
              <td>Pas nécessaire : indispensable</td>
            </tr>
            <tr>
              <td>mandal.enseignant.etablissement</td>
              <td>Retenir l'établissement choisi par un enseignant</td>
              <td>Jusqu'au changement</td>
              <td>Pas nécessaire : préférence demandée</td>
            </tr>
            <tr>
              <td>mandal.blanche.…</td>
              <td>Chronomètre d'une épreuve blanche que tu as lancé</td>
              <td>Jusqu'à la fin de l'épreuve</td>
              <td>Pas nécessaire : fonction demandée</td>
            </tr>
            <tr>
              <td>mandal_visiteur_v1</td>
              <td>
                Compter les visites de façon <strong>anonyme</strong> : un identifiant tiré au
                hasard, sans nom, e-mail ni adresse IP, utilisé uniquement pour nos statistiques
              </td>
              <td>13 mois</td>
              <td>
                Pas nécessaire (mesure d'audience exemptée), mais tu peux t'y opposer ci-dessous
              </td>
            </tr>
          </tbody>
        </table>
      </div>

      <h2>Ne pas être compté dans les statistiques</h2>
      <p>
        {compte
          ? "Tes visites sont actuellement comptées (de façon anonyme)."
          : "Tes visites ne sont plus comptées sur ce navigateur."}
      </p>
      <Button
        variant="outline"
        onClick={() => {
          desactiverComptage(compte);
          setCompte(!compte);
        }}
      >
        {compte ? "Ne plus compter mes visites" : "Recompter mes visites"}
      </Button>

      <h2>Contenus d'autres sites</h2>
      <p>
        Certaines leçons contiennent une vidéo YouTube ou une figure GeoGebra. Elles ne se chargent
        que si tu cliques sur « Afficher ». YouTube (Google) ou GeoGebra peuvent alors déposer leurs
        propres cookies, selon leurs politiques de confidentialité. Les vidéos YouTube utilisent le
        mode « confidentialité renforcée ».
      </p>

      <h2>Effacer ces données</h2>
      <p>
        Tu peux tout effacer depuis les réglages de ton navigateur (« Effacer les données de
        navigation »). Si tu effaces la session, tu seras simplement déconnecté.
      </p>
    </LegalLayout>
  );
}
