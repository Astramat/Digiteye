# Digiteye - Application de streaming vidéo avec intelligence visuelle

Projet complet combinant une application Flutter mobile/web pour le streaming vidéo en temps réel et un backend avec traitement d'images par IA (Qwen2-VL-2B-Instruct).

## 📋 Table des matières

- [Vue d'ensemble](#vue-densemble)
- [Architecture](#architecture)
- [Prérequis](#prérequis)
- [Installation](#installation)
- [Lancement](#lancement)
- [Structure du projet](#structure-du-projet)
- [Documentation](#documentation)
- [Configuration](#configuration)

## 🎯 Vue d'ensemble

Digiteye est une plateforme de streaming vidéo en temps réel avec analyse d'images par IA. Le projet comprend :

- **Application Flutter** : Interface mobile/web pour streaming vidéo en temps réel
- **Serveur Socket.IO** : Gestion des communications temps réel (Node.js/TypeScript)
- **Serveur FastAPI** : Traitement d'images avec modèle Qwen2-VL-2B-Instruct (Python)

### Fonctionnalités principales

- ✅ Streaming vidéo en temps réel depuis la caméra
- ✅ Communication temps réel via Socket.IO
- ✅ Analyse d'images avec Qwen2-VL-2B-Instruct
- ✅ Génération de descriptions d'images (captioning)
- ✅ Support multi-plateforme (Android, iOS, Web, Windows, macOS)

## 🏗️ Architecture

```
Digiteye/
├── camera/              # Application Flutter
│   ├── lib/            # Code source Dart
│   └── ...
├── server/             # Backend
│   ├── src/            # Serveur Socket.IO (TypeScript)
│   ├── bridge.py       # Serveur FastAPI (Python)
│   └── ...
└── camera_server/      # Serveur Flask pour upload d'images
```

### Flux de données

```
[Flutter App] ←→ [Socket.IO Server] ←→ [FastAPI Bridge (Qwen2-VL)]
     ↓
[Caméra/Capture] → [Streaming vidéo] → [Analyse IA]
```

## 📦 Prérequis

### Pour le backend (serveur)

- **Python 3.8+** avec pip
- **Node.js 18+** et npm
- **CUDA** et **PyTorch avec CUDA** (pour le traitement GPU)
- **Carte graphique NVIDIA** avec support CUDA
- **ngrok** (optionnel, pour exposer le serveur Socket.IO)

### Pour l'application Flutter

- **Flutter SDK 3.35.6** ou compatible
- **Dart SDK** (inclus avec Flutter)
- **IDE** : VS Code ou Android Studio
- **Émulateur/appareil** pour tester

## 🚀 Installation

### 1. Backend - Serveur Socket.IO

```bash
cd server
npm install
```

### 2. Backend - Serveur FastAPI (Python)

```bash
cd server
pip install -r requirements.txt
```

**Note importante** : Le serveur FastAPI nécessite une carte graphique NVIDIA avec CUDA. Les poids du modèle Qwen2-VL-2B-Instruct (environ 2GB) seront téléchargés automatiquement au premier lancement.

### 3. Application Flutter

```bash
cd camera
flutter pub get
```

Si vous utilisez **FVM** (Flutter Version Manager) :

```bash
cd camera
fvm install
fvm flutter pub get
```

## ▶️ Lancement

### Méthode recommandée : Lancement manuel dans des terminaux séparés

Pour une meilleure gestion et visualisation des logs, lancez chaque serveur dans un terminal séparé.

#### Terminal 1 : Serveur Socket.IO

```bash
cd server
npm run dev
# ou pour la production
npm start
```

Le serveur démarre sur le port par défaut (généralement 3000).

#### Terminal 2 : Serveur FastAPI (Qwen2-VL)

```bash
cd server
python bridge.py
# ou si vous utilisez python3
python3 bridge.py
```

Le serveur démarre sur `http://localhost:8089`.

**Endpoints disponibles** :
- `GET /` : Informations sur le serveur
- `GET /healthz` : État de santé du serveur
- `POST /caption-file` : Génération de description d'image

#### Terminal 3 : Application Flutter

```bash
cd camera
flutter run -d Edge      # Pour le web
flutter run -d Windows     # Pour Windows
flutter run -d android     # Pour Android
```

**Note** : Consultez `camera/LAUNCH.md` pour des instructions détaillées sur le lancement de l'application Flutter.

### Exposer le serveur Socket.IO (ngrok)

Pour permettre à l'application mobile de se connecter :

```bash
cd server
ngrok start --config=./ngrok.yml socketio
```

Mettez à jour l'URL dans `camera/lib/shared/services/socket_service.dart` avec l'URL ngrok.

## 📁 Structure du projet

```
Digiteye/
├── camera/                    # Application Flutter
│   ├── lib/
│   │   ├── main.dart          # Point d'entrée
│   │   ├── app.dart           # Configuration de l'app
│   │   ├── features/          # Fonctionnalités
│   │   │   ├── auth/          # Authentification
│   │   │   ├── socket/         # Connexion Socket.IO
│   │   │   └── stream/        # Streaming vidéo
│   │   ├── shared/
│   │   │   └── services/      # Services partagés
│   │   └── core/              # Code core (DI, network, etc.)
│   ├── pubspec.yaml           # Dépendances Flutter
│   └── LAUNCH.md              # Guide de lancement Flutter
│
├── server/                    # Backend
│   ├── src/
│   │   ├── server.ts          # Serveur Express principal
│   │   ├── socket_manager.ts  # Gestionnaire Socket.IO
│   │   └── routes/
│   │       └── sockets/       # Routes Socket.IO
│   ├── bridge.py              # Serveur FastAPI (Qwen2-VL)
│   ├── weights/               # Poids du modèle (auto-downloadé)
│   ├── package.json           # Dépendances Node.js
│   ├── requirements.txt      # Dépendances Python
│   └── SOCKET_ROUTES.md       # Documentation routes Socket.IO
│
└── README.md                  # Ce fichier
```

## 📚 Documentation

- **Application Flutter** : Voir `camera/LAUNCH.md`
- **Routes Socket.IO** : Voir `server/SOCKET_ROUTES.md`
- **Architecture Flutter** : Voir `camera/ARCHITECTURE.md`

## ⚙️ Configuration

### Configuration du serveur Socket.IO

L'URL du serveur est configurée dans :
- `camera/lib/shared/services/socket_service.dart` : URL par défaut
- Variable d'environnement ou fichier de configuration

### Configuration du serveur FastAPI

Variables d'environnement (optionnelles) :

```bash
# Dossier de stockage des poids du modèle
export WEIGHTS_DIR="./weights/Qwen2-VL-2B-Instruct"

# Limite de concurrence
export MAX_CONCURRENT=1

# Timeout d'acquisition
export ACQUIRE_TIMEOUT_S=0

# Délai avant retry
export RETRY_AFTER_S=1
```

### Prompt par défaut du modèle

Modifiable dans `server/bridge.py` :

```python
DEFAULT_PROMPT = "Describe this image in accurate, concise detail."
```

## 🔧 Dépannage

### Le serveur FastAPI ne démarre pas

1. **Vérifier CUDA** :
   ```bash
   python -c "import torch; print(torch.cuda.is_available())"
   ```

2. **Vérifier les dépendances** :
   ```bash
   pip install -r server/requirements.txt
   ```

3. **Vérifier l'espace disque** : Le modèle nécessite ~2GB

### L'application Flutter ne se connecte pas

1. **Vérifier l'URL du serveur** dans `socket_service.dart`
2. **Vérifier que le serveur Socket.IO est démarré**
3. **Vérifier ngrok** si utilisé en production
4. **Vérifier les permissions** (caméra, microphone)

### Problèmes de dépendances Flutter

```bash
cd camera
flutter clean
flutter pub get
```

### Problèmes de build

```bash
# Android
cd camera/android
./gradlew clean

# iOS (Mac)
cd camera/ios
pod install
```

## 📝 Endpoints API

### FastAPI (Qwen2-VL)

- **GET `/`** : Informations sur le serveur
- **GET `/healthz`** : État de santé
- **POST `/caption-file`** : Générer une description d'image
  - Paramètres :
    - `file` : Fichier image (obligatoire)
    - `prompt` : Prompt personnalisé (optionnel)
    - `max_new_tokens` : Nombre max de tokens (défaut: 128)
    - `temperature` : Température de génération (défaut: 0.2)

### Socket.IO

Voir `server/SOCKET_ROUTES.md` pour la documentation complète.

Principales routes :
- `connection:welcome` : Message de bienvenue
- `session:start` : Démarrer une session
- `video:frame` : Envoi de frame vidéo
- `llm:message` : Message au LLM
- `llm:response` : Réponse du LLM

## 🤝 Contribution

Pour contribuer au projet :

1. Fork le projet
2. Créez une branche (`git checkout -b feature/AmazingFeature`)
3. Committez vos changements (`git commit -m 'Add some AmazingFeature'`)
4. Pushez vers la branche (`git push origin feature/AmazingFeature`)
5. Ouvrez une Pull Request

## 📄 Licence

[À compléter selon votre licence]

## 👥 Auteurs

[À compléter]

## 🙏 Remerciements

- **Qwen Team** pour le modèle Qwen2-VL-2B-Instruct
- **Flutter** pour le framework multiplateforme
- **Socket.IO** pour la communication temps réel
- **FastAPI** pour l'API Python moderne

## 📞 Support

Pour toute question ou problème :
- Créez une issue sur GitHub
- Consultez la documentation dans chaque dossier

---

**Note** : Ce projet nécessite une carte graphique NVIDIA avec CUDA pour fonctionner correctement. Le traitement CPU n'est pas supporté pour des raisons de performance.

