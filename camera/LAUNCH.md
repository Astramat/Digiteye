# Guide de lancement du projet Flutter

## Prérequis

1. **Flutter SDK** installé (version 3.35.6 via FVM ou version compatible)
2. **Dart SDK** (inclus avec Flutter)
3. **IDE** recommandé : VS Code ou Android Studio
4. **Émulateur/Appareil** :
   - Pour Android : Android Studio avec émulateur ou appareil physique
   - Pour iOS : Xcode avec simulateur ou appareil physique (Mac uniquement)
   - Pour Web : navigateur Chrome
   - Pour Windows : Windows 10/11

## Installation des dépendances

### Option 1 : Avec FVM (Flutter Version Manager)

Si vous utilisez FVM :

```bash
# Naviguer dans le dossier camera
cd camera

# Installer la version Flutter spécifiée dans .fvmrc
fvm install

# Utiliser FVM pour les commandes Flutter
fvm flutter pub get
```

### Option 2 : Sans FVM (Flutter standard)

```bash
# Naviguer dans le dossier camera
cd camera

# Installer les dépendances
flutter pub get
```

## Lancer l'application

### Détecter les appareils disponibles

```bash
flutter devices
```

### Lancer sur différentes plateformes

#### Android
```bash
flutter run
# ou spécifier un appareil
flutter run -d <device-id>
```

#### iOS (Mac uniquement)
```bash
flutter run -d ios
```

#### Web
```bash
flutter run -d chrome
# ou
flutter run -d web-server --web-port=8080
```

#### Windows
```bash
flutter run -d windows
```

#### macOS
```bash
flutter run -d macos
```

## Commandes utiles

### Mode debug (avec hot reload)
```bash
flutter run
```
- Appuyez sur `r` pour hot reload
- Appuyez sur `R` pour hot restart
- Appuyez sur `q` pour quitter

### Mode release (optimisé)
```bash
flutter run --release
```

### Nettoyer le projet
```bash
flutter clean
flutter pub get
```

### Générer du code (si nécessaire)
```bash
flutter pub run build_runner build
# ou en mode watch
flutter pub run build_runner watch
```

## Dépannage

### Vérifier l'installation Flutter
```bash
flutter doctor
```

### Résoudre les problèmes de dépendances
```bash
flutter clean
flutter pub get
flutter pub upgrade
```

### Problèmes spécifiques Android
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
```

### Problèmes spécifiques iOS
```bash
cd ios
pod install
cd ..
flutter clean
flutter pub get
```

## Configuration

### URL du serveur Socket.IO

Le serveur Socket.IO est configuré dans `lib/shared/services/socket_service.dart` :
- URL par défaut : `http://localhost:3000`
- Modifiable dans le code ou via configuration

### Permissions requises

L'application nécessite :
- **Caméra** : pour le streaming vidéo
- **Microphone** : pour l'audio (si activé)

Ces permissions sont gérées automatiquement via `permission_handler`.

## Structure du projet

- `lib/main.dart` : Point d'entrée de l'application
- `lib/app.dart` : Configuration de l'application
- `lib/features/` : Fonctionnalités (auth, socket, stream)
- `lib/shared/services/` : Services partagés (socket, streaming, etc.)
- `lib/core/` : Code core (DI, network, storage, etc.)

## Support

Pour plus d'informations :
- Documentation Flutter : https://docs.flutter.dev
- Documentation Dart : https://dart.dev

