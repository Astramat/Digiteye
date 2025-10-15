### Prérequis
- Flutter SDK installé.
- Android Studio configuré pour Flutter.

### Installation des dépendances
1. Ouvrez le terminal dans le dossier `lib/main.dart`.
2. Exécutez `flutter pub get`.

### Configuration
- Dans `lib/main.dart`, modifiez `_serverUrl` avec l'adresse IP de votre machine hôte (ex: `'http://192.168.1.32:5000/upload_image'`).

### Lancer l'application
1. Ouvrez le projet dans Android Studio.
2. Connectez un appareil Android physique avec une caméra. (Les émulateurs ont des limitations pour la caméra et le réseau).
3. Exécutez l'application (Run `main.dart`).

### Fonctionnalités
- Capture automatique d'images toutes les secondes vers le serveur.
- Boutons "Play" et "Stop" pour contrôler la capture.
- Logs de session affichant la durée, les photos prises/envoyées.
