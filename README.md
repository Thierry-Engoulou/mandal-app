# Teacher Hub

voici mon projet zippé,
Construis l'espace Enseignant de MANDAL, actuellement à l'état de pages vides (page-placeholder). Utilise le même style de code que l'espace Étudiant et Admin déjà existants : server functions (createServerFn + Supabase), TanStack Query, composants shadcn/ui.

1) SÉLECTEUR D'ÉTABLISSEMENT (TeacherShell)

Le sélecteur d'établissement dans la sidebar est actuellement une liste statique ("Lycée de Bonanjo", "Collège d'Akwa"). Remplace-le par les vrais établissements où l'enseignant a une classe assignée (jointure classes.enseignant_id = profile.id), stockés en state global ou query param, pour filtrer les pages ci-dessous.

2) /enseignant (Overview)

Dashboard avec : nombre de classes, nombre total d'élèves, examens à corriger (resultats_examens en attente), messages non lus (conversations où enseignant_id = moi et statut = en_attente), statut de validation du compte (table validations_enseignants — si statut != 'approuve', afficher un bandeau "compte en attente de validation par votre chef d'établissement" et limiter l'accès en écriture).

3) /enseignant/ecole

Fiche de l'établissement sélectionné (nom, logo, type, systeme_educatif) + liste des classes de l'enseignant dans cet établissement + effectif total.

4) /enseignant/syllabus

Gestion des programmes/chapitres/concepts (tables programmes, chapitres, concepts) pour les matières/classes de l'enseignant : CRUD complet avec formulaires (créer un programme, ajouter des chapitres, ajouter des concepts par chapitre), réordonnancement par glisser-déposer ou boutons monter/descendre (colonne ordre).

5) /enseignant/examens

Liste des examens créés par l'enseignant (table examens filtrée par programme -> classe -> enseignant_id) avec statut (brouillon/publié/clos), dates, nombre de questions. Bouton "Créer un examen" : formulaire (titre, programme, durée, dates, mode d'évaluation) puis éditeur de questions (table questions : énoncé, type, options en jsonb, réponse correcte, points). Ajoute une page de correction/résultats par examen listant resultats_examens avec score et détail des réponses.

6) /enseignant/eleves

Liste de tous les élèves des classes de l'enseignant (jointure class_membres -> profiles), avec XP total, dernier examen passé, moyenne. Recherche et filtre par classe.

7) /enseignant/messages

Liste des conversations (table conversations où enseignant_id = moi), avec fil de messages (table messages) et possibilité de répondre, changer le statut (en_attente/accepté), même pattern que la messagerie élève déjà existante.

8) /enseignant/notifications

Liste réelle des notifications (table notifications où profile_id = moi), marquer comme lu. Remplace le badge statique "3" dans la sidebar (TeacherShell) par le vrai compteur de notifications non lues.

9) /enseignant/parametres

Formulaire d'édition du profil (nom, prénom, avatar_url via upload dans le bucket avatars) et affichage en lecture seule du statut de validation.

10) MÉDIATHÈQUE (nouveau, absent du menu)

Ajoute une page /enseignant/mediatheque permettant d'uploader une ressource (vidéo/audio/document) dans le bucket privé correspondant (mediatheque-videos, mediatheque-audio, mediatheque-documents ou contenus-en-attente selon le statut_validation), avec formulaire (titre, type, matière, valeur XP) créant une ligne dans ressources_mediatheque en statut_validation = en_attente, en attente de validation par le chef d'établissement.

CONTRAINTES

- Respecte les RLS existantes : un enseignant ne doit voir/modifier que les données liées à ses propres classes (enseignant_id) et à son établissement.

- Si le compte n'est pas encore approuvé (validations_enseignants.statut != 'approuve'), bloque la création de contenu (syllabus, examens, médiathèque) et affiche un message clair.

- Garde le même design system (couleurs, cartes, badges de statut colorés) que le reste de l'application.

This project was built with [Lovable](https://lovable.dev).

## Build with Lovable

Continue developing this project in the [Lovable editor](https://lovable.dev/projects/fc29a2af-9a18-4897-bbbf-3610a446dea7).

- **Ship faster**: describe what you want to build and Lovable handles the code.
- **Stay in sync**: every change made in Lovable is committed straight to this repository.
- **Full ownership**: this code is yours. Push to `main` on GitHub and your changes sync back into Lovable, ready for your next prompt.

## Development

Prefer working locally? You need Node.js and npm — [install with nvm](https://github.com/nvm-sh/nvm#installing-and-updating).

```sh
git clone <this-repository-url>
cd <repository-name>
npm i
npm run dev
```
