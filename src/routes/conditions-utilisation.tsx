import { createFileRoute, Link } from "@tanstack/react-router";
import { LegalLayout } from "@/components/legal/legal-layout";
import { SITE_INFO } from "@/lib/site-info";

export const Route = createFileRoute("/conditions-utilisation")({
  head: () => ({
    meta: [
      { title: "Conditions d'utilisation — M'ANDAL" },
      { name: "description", content: "Les règles d'utilisation de la plateforme M'ANDAL." },
    ],
  }),
  component: ConditionsPage,
});

function ConditionsPage() {
  const mail = <a href={`mailto:${SITE_INFO.email}`}>{SITE_INFO.email}</a>;
  return (
    <LegalLayout titre="Conditions d'utilisation">
      <p>
        En créant un compte ou en utilisant M'ANDAL, tu acceptes ces règles. Elles sont là pour que
        la plateforme reste utile et sûre pour tous, en particulier pour les plus jeunes.
      </p>

      <h2>1. Le service</h2>
      <p>
        M'ANDAL propose des cours, des exercices, une banque d'épreuves, un répétiteur
        d'intelligence artificielle (Mandal IA), des outils d'orientation et une messagerie
        scolaire, principalement pour les élèves du Cameroun et d'Afrique francophone. Le service
        est gratuit pour les élèves. Nous pouvons le faire évoluer ou l'interrompre temporairement,
        par exemple pour maintenance.
      </p>

      <h2>2. Ton compte</h2>
      <ul>
        <li>Les informations que tu donnes doivent être exactes.</li>
        <li>Ton mot de passe est personnel : ne le partage avec personne.</li>
        <li>Si tu as moins de 15 ans, un parent ou responsable légal doit être d'accord.</li>
        <li>
          Le statut d'enseignant est validé par un établissement ou par l'équipe M'ANDAL. Se faire
          passer pour un enseignant est interdit.
        </li>
      </ul>

      <h2>3. Règles de la messagerie et des échanges</h2>
      <p>Dans les salons, les fils d'épreuves et toutes les zones de texte, il est interdit de :</p>
      <ul>
        <li>insulter, harceler, menacer ou humilier quelqu'un ;</li>
        <li>publier des contenus violents, sexuels, haineux ou discriminatoires ;</li>
        <li>
          partager des informations personnelles sur soi ou sur les autres (adresse, téléphone…) ;
        </li>
        <li>proposer de l'argent ou des faveurs, ou faire de la publicité ;</li>
        <li>diffuser des sujets d'examen frauduleux ou aider à tricher pendant une épreuve.</li>
      </ul>
      <p>
        Les enseignants et l'équipe M'ANDAL peuvent supprimer un message et suspendre un compte qui
        ne respecte pas ces règles. Pour signaler un problème : {mail}.
      </p>

      <h2>4. Mandal IA</h2>
      <p>
        Mandal IA (questions, conseiller d'orientation, correction de copies, épreuves blanches)
        utilise le service Gemini de Google et est{" "}
        <strong>réservé aux personnes de 18 ans ou plus</strong>, qui le confirment avant d'y
        accéder. Le reste de M'ANDAL reste ouvert à tous.
      </p>
      <p>
        Mandal IA est un outil d'entraînement : ses réponses et ses corrections peuvent contenir des
        erreurs et ne remplacent ni ton enseignant ni une note officielle. N'y écris pas
        d'informations personnelles (voir la{" "}
        <Link to="/confidentialite">politique de confidentialité</Link>). Un nombre maximum de
        demandes par jour s'applique pour que le service reste disponible pour tous.
      </p>

      <h2>5. Banque d'épreuves et contenus déposés</h2>
      <ul>
        <li>
          Les épreuves sont diffusées à des fins pédagogiques, avec leur source. Leur usage
          commercial est interdit.
        </li>
        <li>
          En déposant une épreuve, un corrigé ou tout autre contenu, l'enseignant garantit qu'il a
          le droit de le partager, et il accorde à {SITE_INFO.editeur} une autorisation gratuite et
          non exclusive de le diffuser sur M'ANDAL, pour la durée de son exploitation.
        </li>
        <li>
          Tout titulaire de droits peut demander le retrait d'un document : {mail}. Nous le retirons
          dans les meilleurs délais.
        </li>
      </ul>

      <h2>6. Propriété intellectuelle</h2>
      <p>
        Les contenus originaux de M'ANDAL (cours, exercices, textes, logo) restent la propriété de
        l'éditeur. Tu peux les utiliser pour apprendre, mais pas les revendre ni les republier
        ailleurs sans autorisation.
      </p>

      <h2>7. Responsabilité</h2>
      <p>
        Nous faisons de notre mieux pour proposer des contenus exacts et à jour, mais des erreurs
        restent possibles. Pour les dates, frais et conditions des examens et concours, seuls les
        communiqués officiels font foi.
      </p>

      <h2>8. Modification et contact</h2>
      <p>
        Ces conditions peuvent évoluer : la date de mise à jour figure en haut de la page. Pour
        toute question : {mail}. Ces conditions sont régies par le droit camerounais.
      </p>
    </LegalLayout>
  );
}
