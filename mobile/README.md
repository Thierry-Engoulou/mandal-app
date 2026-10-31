# Application Android M'ANDAL

Application Android construite avec [Capacitor](https://capacitorjs.com). Elle affiche le site
<https://mandal-education.vercel.app> dans une application installable : toute mise à jour du
site apparaît aussitôt dans l'application, sans republier l'APK.

- Identifiant : `cm.mandal.education` — nom affiché : « M'ANDAL »
- Sans connexion internet, l'application affiche une page « Pas de connexion internet ».
- La connexion avec Google est masquée dans l'application (Google la refuse dans une
  application de ce type) : les élèves se connectent par e-mail / téléphone et mot de passe.
- Les liens externes (WhatsApp, YouTube, téléchargements de PDF) s'ouvrent dans le navigateur
  du téléphone.

## Obtenir l'APK de test sans rien installer

À chaque modification du dossier `mobile/`, GitHub construit l'APK automatiquement :

1. Sur GitHub, onglet **Actions** → workflow **Android** → dernière exécution réussie.
2. En bas de la page, section **Artifacts** : télécharger **mandal-android-apk** (fichier zip).
3. Décompresser, envoyer `app-debug.apk` sur le téléphone (WhatsApp, câble, Google Drive…),
   l'ouvrir et autoriser « Installer des applications inconnues ».

Le bouton **Run workflow** de la même page relance une construction à la demande.

## Construire sur un ordinateur Windows

Prérequis : [Node.js 22](https://nodejs.org), [Git](https://git-scm.com) et
[Android Studio](https://developer.android.com/studio) (il installe le SDK Android et Java).

```powershell
cd "C:\Users\RODRIGUE SINGOR\Desktop\Projet_Mandal"
git clone https://github.com/Thierry-Engoulou/mandal-app.git MANDALAPP
cd MANDALAPP\mobile
npm install
npx cap sync android
npx cap open android
```

Android Studio s'ouvre : brancher un téléphone Android (mode développeur et débogage USB
activés) et cliquer sur ▶ **Run**, ou **Build → Build App Bundle(s) / APK(s) → Build APK(s)**.

## Modifier l'icône ou l'écran de démarrage

Remplacer les images de `assets/` (`icon-only.png`, `icon-foreground.png`,
`icon-background.png` en 1024 × 1024, `splash.png` en 2732 × 2732), puis :

```powershell
npm run icones
npx cap sync android
```

## Publier sur Google Play (plus tard)

1. Compte développeur Google Play (25 $, une seule fois).
2. Dans Android Studio : **Build → Generate Signed App Bundle** avec une clé de signature
   (à conserver précieusement : sans elle, plus de mise à jour possible).
3. Envoyer le fichier `.aab` dans la Google Play Console, avec la fiche, les captures et la
   politique de confidentialité (<https://mandal-education.vercel.app/confidentialite>).
