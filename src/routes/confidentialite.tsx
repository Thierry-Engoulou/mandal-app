import { createFileRoute, Link } from "@tanstack/react-router";
import { LegalLayout } from "@/components/legal/legal-layout";
import { SITE_INFO } from "@/lib/site-info";

export const Route = createFileRoute("/confidentialite")({
  head: () => ({
    meta: [
      { title: "Politique de confidentialité — M'ANDAL" },
      {
        name: "description",
        content: "Quelles données M'ANDAL collecte, pourquoi, combien de temps, et tes droits.",
      },
    ],
  }),
  component: ConfidentialitePage,
});

function ConfidentialitePage() {
  const mail = <a href={`mailto:${SITE_INFO.email}`}>{SITE_INFO.email}</a>;
  return (
    <LegalLayout titre="Politique de confidentialité">
      <p>
        Cette page explique simplement quelles informations nous enregistrons quand tu utilises
        M'ANDAL, pourquoi, et ce que tu peux demander. Elle s'appuie sur la loi camerounaise
        n°2024/017 du 23 décembre 2024 relative à la protection des données à caractère personnel
        et, pour les utilisateurs situés dans l'Union européenne, sur le RGPD.
      </p>

      <h2>1. Qui est responsable ?</h2>
      <p>
        {SITE_INFO.editeur}, {SITE_INFO.adresse}. Pour toute question sur tes données : {mail}.
      </p>

      <h2>2. Quelles données ?</h2>
      <ul>
        <li>
          <strong>Ton compte</strong> : nom, e-mail ou numéro de téléphone, mot de passe (enregistré
          sous forme chiffrée, nous ne pouvons pas le lire), rôle (élève, enseignant), niveau,
          établissement.
        </li>
        <li>
          <strong>Ton travail</strong> : cours suivis, résultats d'examens, épreuves composées,
          photos de copies que tu envoies, épreuves blanches générées.
        </li>
        <li>
          <strong>Tes échanges</strong> : questions posées à Mandal IA et au conseiller
          d'orientation, messages dans les salons et les fils d'épreuves.
        </li>
        <li>
          <strong>Demandes d'inscription</strong> : nom, e-mail, téléphone et ville (facultatifs),
          établissement, niveau, motivation.
        </li>
        <li>
          <strong>Statistiques anonymes</strong> : pages visitées et téléchargements, rattachés à un
          identifiant tiré au hasard, sans nom ni adresse IP (voir la{" "}
          <Link to="/cookies">page Cookies</Link>).
        </li>
      </ul>

      <h2>3. Pourquoi ?</h2>
      <ul>
        <li>
          Te fournir le service : cours, exercices, corrections, messagerie (exécution du service).
        </li>
        <li>Permettre aux enseignants de suivre leurs élèves et de corriger leurs copies.</li>
        <li>Mesurer la fréquentation du site de façon anonyme (intérêt légitime).</li>
        <li>Assurer la sécurité des comptes et du service (intérêt légitime).</li>
      </ul>
      <p>Nous ne vendons aucune donnée et ne faisons aucune publicité ciblée.</p>

      <h2>4. Mandal IA (intelligence artificielle)</h2>
      <p>
        Les réponses de Mandal IA, les corrections de copies et les épreuves blanches sont produites
        par un service d'intelligence artificielle externe : actuellement{" "}
        <strong>Gemini, de Google</strong>. Ta question, les photos de copie et les sujets joints
        lui sont envoyés pour produire la réponse. Dans l'offre utilisée, Google peut se servir de
        ces contenus pour améliorer ses services, et des personnes peuvent les relire après
        séparation de toute information d'identification du compte.
      </p>
      <p>
        <strong>N'écris donc jamais ton nom complet, ton numéro de téléphone ou ton adresse</strong>{" "}
        dans une question, et cache ton nom sur les photos de copies. Mandal IA peut se tromper :
        vérifie avec ton enseignant.
      </p>

      <h2>5. Qui reçoit ces données ?</h2>
      <ul>
        <li>L'équipe M'ANDAL et, pour leurs classes et leurs épreuves, tes enseignants.</li>
        <li>
          Nos prestataires techniques : Vercel (hébergement du site, États-Unis), Supabase (base de
          données et fichiers, {SITE_INFO.regionSupabase}), Google (connexion avec Google et service
          d'IA Gemini).
        </li>
      </ul>
      <p>
        Ces prestataires sont situés hors du Cameroun. Ces transferts s'appuient sur les garanties
        contractuelles proposées par ces prestataires (pour l'Union européenne : clauses
        contractuelles types de la Commission européenne) et sur les démarches prévues par la loi
        n°2024/017 auprès de l'APDP.
      </p>

      <h2>6. Combien de temps ?</h2>
      <ul>
        <li>Compte et travail scolaire : tant que ton compte existe.</li>
        <li>Demandes d'inscription non retenues : 12 mois maximum.</li>
        <li>Statistiques anonymes : 13 mois maximum pour l'identifiant du navigateur.</li>
      </ul>

      <h2>7. Mineurs</h2>
      <p>
        M'ANDAL s'adresse notamment à des élèves mineurs. Si tu as moins de 15 ans, demande à un
        parent ou à un responsable légal de lire cette page avec toi et de donner son accord avant
        de créer ton compte. Un parent peut nous écrire à tout moment ({mail}) pour accéder aux
        données de son enfant ou les faire supprimer.
      </p>

      <h2>8. Tes droits</h2>
      <p>
        Tu peux demander l'accès à tes données, leur correction, leur suppression ou leur
        portabilité, et t'opposer à certains usages. Écris-nous à {mail} depuis l'adresse liée à ton
        compte : nous répondons dans un délai d'un mois.
      </p>
      <p>
        Si notre réponse ne te satisfait pas, tu peux saisir l'Autorité de protection des données à
        caractère personnel du Cameroun (APDP) ou, si tu vis dans l'Union européenne, l'autorité de
        ton pays (en France : la CNIL).
      </p>

      <h2>9. Sécurité</h2>
      <p>
        Connexion chiffrée (HTTPS), mots de passe chiffrés, accès aux données limité par des règles
        en base (chaque élève ne voit que ses propres données), journal des actions
        d'administration.
      </p>
    </LegalLayout>
  );
}
