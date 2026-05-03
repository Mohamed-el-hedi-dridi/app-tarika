# tarika

تطبيقة الأوراد اليومية Tarika

## Présentation

Ce repo contient l'application Flutter `tarika`, avec prise en charge d'une mise à jour OTA Android via un fichier `version.json` et un script de release automatique.

## Prérequis

- Flutter 3.x+ installé et configuré
- Git
- macOS / Linux / Windows avec les outils Flutter
- Pour les releases automatiques : `gh` et `jq`

## Installation

```bash
flutter pub get
```

## Lancement de l'application

```bash
flutter run
```

## OTA Android

L'application vérifie au démarrage un fichier `version.json` hébergé dans le repo GitHub :

- `lib/services/update_service.dart` pointe vers
  `https://raw.githubusercontent.com/Mohamed-el-hedi-dridi/app-tarika/main/version.json`
- si la clé `build` est plus élevée que la version installée, une fenêtre s'affiche
- l'APK est téléchargé et Android propose l'installation

### Structure attendue de `version.json`

```json
{
  "build": 2,
  "version": "1.0.1",
  "apk_url": "https://github.com/Mohamed-el-hedi-dridi/app-tarika/releases/download/v1.0.1/tarika.apk",
  "changelog": "Corrections et nouvelles fonctionnalités"
}
```

## Script de release automatique

Un script de release est disponible dans `scripts/release.sh`.

### Commandes supportées

```bash
./scripts/release.sh patch   # correction mineure
./scripts/release.sh minor   # nouvelle fonctionnalité
./scripts/release.sh major   # refonte majeure
```

### Ce que fait le script

- met à jour `pubspec.yaml` avec la nouvelle version et le nouveau build number
- met à jour `version.json` avec le nouvel APK et le changelog
- build l'APK release via `flutter build apk --release`
- commit + tag git, pousse sur `main`
- crée une GitHub Release et téléverse l'APK

### Prérequis pour le script

```bash
brew install gh jq
gh auth login
```

## Publier une nouvelle version manuellement

1. Build l'APK :
   ```bash
   flutter build apk --release
   ```
2. Crée une release GitHub `vX.Y.Z`
3. Upload `tarika.apk` dans la release
4. Met à jour `version.json` avec le nouveau `build`, `version`, `apk_url` et `changelog`
5. Incrémente `pubspec.yaml` et pousse les changements

## Notes

- L'OTA Android fonctionne uniquement pour la plateforme Android.
- Le FileProvider Android est configuré dans `android/app/src/main/AndroidManifest.xml` et `android/app/src/main/res/xml/file_paths.xml`.
- Pour les utilisateurs finaux, l'application se met à jour automatiquement à l'ouverture si une nouvelle version est disponible.
