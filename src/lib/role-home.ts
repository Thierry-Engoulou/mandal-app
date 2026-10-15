/** Page d'accueil de chaque rôle après la connexion. */
export function homeForRole(role: string | null | undefined) {
  switch (role) {
    case "admin":
    case "super_admin":
      return "/admin" as const;
    case "chef_etablissement":
      return "/etablissement" as const;
    case "teacher":
      return "/enseignant" as const;
    default:
      return "/etudiant" as const;
  }
}

/** Rôle choisi sur la page d'inscription avant de partir chez Google : on le
 *  garde le temps de l'aller-retour OAuth (Google ne transmet pas de rôle). */
export const GOOGLE_SIGNUP_ROLE_KEY = "mandal.inscription.role";
