import { createFileRoute } from "@tanstack/react-router";
import { LegalLayout } from "@/components/legal/legal-layout";
import { SITE_INFO } from "@/lib/site-info";

export const Route = createFileRoute("/mentions-legales")({
  head: () => ({
    meta: [
      { title: "Mentions légales — M'ANDAL" },
      {
        name: "description",
        content: "Éditeur, hébergeurs et propriété intellectuelle de M'ANDAL.",
      },
    ],
  }),
  component: MentionsLegalesPage,
});

function MentionsLegalesPage() {
  return (
    <LegalLayout titre="Mentions légales">
      <h2>Éditeur du site</h2>
      <p>
        Le site <a href={SITE_INFO.url}>{SITE_INFO.url}</a> ({SITE_INFO.nom}) est édité par{" "}
        {SITE_INFO.editeur}, {SITE_INFO.formeJuridique}, {SITE_INFO.immatriculation}, dont le siège
        est situé {SITE_INFO.adresse}.
      </p>
      <ul>
        <li>Téléphone : {SITE_INFO.telephone}</li>
        <li>
          E-mail : <a href={`mailto:${SITE_INFO.email}`}>{SITE_INFO.email}</a>
        </li>
        <li>Responsable de la publication : {SITE_INFO.responsablePublication}</li>
      </ul>

      <h2>Hébergement</h2>
      <ul>
        <li>
          Site : Vercel Inc., 440 N Barranca Ave #4133, Covina, CA 91723, États-Unis —{" "}
          <a href="https://vercel.com">vercel.com</a>
        </li>
        <li>
          Base de données et fichiers : Supabase Inc. ({SITE_INFO.regionSupabase}) —{" "}
          <a href="https://supabase.com">supabase.com</a>
        </li>
      </ul>

      <h2>Propriété intellectuelle</h2>
      <p>
        Les contenus originaux du site (cours, exercices, textes, logo) appartiennent à l'éditeur.
        Toute reproduction en dehors d'un usage personnel et pédagogique demande son accord.
      </p>
      <p>
        Les épreuves d'examens officiels de la banque d'épreuves restent la propriété de leurs
        auteurs (Office du Baccalauréat du Cameroun, Cameroon GCE Board, ministères, établissements)
        et sont diffusées à des fins pédagogiques, avec l'indication de leur source. Pour demander
        le retrait d'un document : <a href={`mailto:${SITE_INFO.email}`}>{SITE_INFO.email}</a>. Nous
        le retirons dans les meilleurs délais.
      </p>

      <h2>Crédits</h2>
      <ul>
        <li>Polices Inter, Outfit et JetBrains Mono : SIL Open Font License.</li>
        <li>Icônes Lucide : licence ISC. Formules mathématiques : KaTeX (licence MIT).</li>
        <li>Image de la page d'accueil : illustration générée par intelligence artificielle.</li>
      </ul>
    </LegalLayout>
  );
}
