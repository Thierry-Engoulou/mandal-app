# M'Andal

Plateforme éducative M'Andal : espaces élève, enseignant, chef d'établissement
et administrateur (cours, examens, médiathèque, orientation, messagerie).

Projet connecté à [Lovable](https://lovable.dev) : les commits poussés sur la
branche principale sont synchronisés avec l'éditeur Lovable.

## Stack

- [TanStack Start](https://tanstack.com/start) (React 19, TanStack Router & Query), Vite
- Tailwind CSS 4 + composants shadcn/ui
- Supabase (Postgres + RLS, Auth, Storage) — migrations dans `supabase/migrations`

## Démarrer en local

```bash
npm ci --legacy-peer-deps
npm run dev
```

Le fichier `.env` contient l'URL et la clé **publique** Supabase. Les server
functions ont en plus besoin, côté serveur uniquement, de
`SUPABASE_SERVICE_ROLE_KEY` (et `LOVABLE_API_KEY` pour le conseiller IA) :
ne jamais commiter ces clés.

## Vérifications

```bash
npm run typecheck   # TypeScript
npm run lint        # ESLint + Prettier
npm run build       # build de production
npm run format      # formatage automatique
```

Ces trois vérifications tournent aussi en CI (GitHub Actions) à chaque pull
request.

## Structure

| Dossier                     | Contenu                                                                            |
| --------------------------- | ---------------------------------------------------------------------------------- |
| `src/routes`                | Pages (routing par fichiers TanStack Router). `_authenticated.*` = pages protégées |
| `src/lib/*.functions.ts`    | Server functions (`createServerFn`)                                                |
| `src/lib/use-*.ts`          | Hooks de données (TanStack Query + Supabase)                                       |
| `src/components`            | Composants partagés ; `ui/` = shadcn/ui                                            |
| `src/integrations/supabase` | Clients et types Supabase (générés par Lovable)                                    |
| `supabase/migrations`       | Schéma SQL, politiques RLS, fonctions                                              |

## Sécurité : règles à respecter

- Les rôles (`role`), `statut_validation`, `etablissement_id` et `xp_total`
  d'un profil ne sont modifiables que par un administrateur, le chef
  d'établissement (statut) ou le backend — un trigger en base l'impose.
- Les examens sont corrigés en base (`soumettre_examen`) ; les élèves lisent
  les questions via `questions_examen`, qui n'expose pas les réponses.
- Le client `supabaseAdmin` (service role, contourne la RLS) ne doit être
  utilisé que dans des server functions qui vérifient d'abord les droits
  de l'appelant.
