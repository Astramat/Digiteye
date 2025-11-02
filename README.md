# Digiteye – Video Streaming Application with Visual Intelligence

Complete project combining a Flutter mobile/web application for real-time video streaming and a backend with AI-based image processing (Qwen2-VL-2B-Instruct).

## App Screenshots

A quick look at the **Digiteye** interface:

![Interface 1](https://github.com/Astramat/Digiteye/blob/main/image/image_1.png)
![Interface 2](https://github.com/Astramat/Digiteye/blob/main/image/image_2.png)

## Demo Video

Watch the full **Digiteye** demo in action:  

[![Watch the demo on YouTube](https://img.youtube.com/vi/SVvIWC7ST24/maxresdefault.jpg)](https://www.youtube.com/shorts/SVvIWC7ST24?feature=share)

## Table of Contents

* [Overview](#overview)
* [Architecture](#architecture)
* [Prerequisites](#prerequisites)
* [Installation](#installation)
* [Running the Project](#running-the-project)
* [Project Structure](#project-structure)
* [Documentation](#documentation)
* [Configuration](#configuration)

## Overview

Digiteye is a real-time video streaming platform with AI-powered image analysis. The project includes:

* **Flutter Application**: Mobile/web interface for real-time video streaming
* **Socket.IO Server**: Real-time communication handling (Node.js/TypeScript)
* **FastAPI Server**: Image processing using Qwen2-VL-2B-Instruct (Python)

### Key Features

* ✅ Real-time video streaming from camera
* ✅ Real-time communication via Socket.IO
* ✅ Image analysis with Qwen2-VL-2B-Instruct
* ✅ Automatic image captioning
* ✅ Multi-platform support (Android, iOS, Web, Windows, macOS)

## Architecture

```
Digiteye/
├── camera/              # Flutter application
│   ├── lib/            # Dart source code
│   └── ...
├── server/             # Backend
│   ├── src/            # Socket.IO server (TypeScript)
│   ├── bridge.py       # FastAPI server (Python)
│   └── ...
└── camera_server/      # Flask server for image uploads
```

### Data Flow

```
[Flutter App] ←→ [Socket.IO Server] ←→ [FastAPI Bridge (Qwen2-VL)]
     ↓
[Camera/Capture] → [Video Streaming] → [AI Analysis]
```

## Prerequisites

### Backend (Server)

* **Python 3.8+** with pip
* **Node.js 18+** and npm
* **CUDA** and **PyTorch with CUDA** (GPU required)
* **NVIDIA GPU** with CUDA support
* **ngrok** (optional, to expose Socket.IO server)

### Flutter Application

* **Flutter SDK 3.35.6** or compatible
* **Dart SDK** (included with Flutter)
* **IDE**: VS Code or Android Studio
* **Emulator/device** for testing

## Installation

### 1. Backend – Socket.IO Server

```bash
cd server
npm install
```

### 2. Backend – FastAPI Server (Python)

```bash
cd server
pip install -r requirements.txt
```

**Important Note**: FastAPI server requires an NVIDIA GPU with CUDA. Qwen2-VL-2B-Instruct model weights (~2GB) will be downloaded automatically on first run.

### 3. Flutter Application

```bash
cd camera
flutter pub get
```

If using **FVM (Flutter Version Manager)**:

```bash
cd camera
fvm install
fvm flutter pub get
```

## Running the Project

### Recommended Method: Run manually in separate terminals

This allows better log management and debugging.

#### Terminal 1: Socket.IO Server

```bash
cd server
npm run dev
# or for production
npm start
```

Server runs on the default port (usually 3000).

#### Terminal 2: FastAPI Server (Qwen2-VL)

```bash
cd server
python bridge.py
# or
python3 bridge.py
```

Server runs on `http://localhost:8089`.

**Available Endpoints**:

* `GET /` : Server info
* `GET /healthz` : Health check
* `POST /caption-file` : Generate image captions

#### Terminal 3: Flutter Application

```bash
cd camera
flutter run -d Edge      # For web
flutter run -d Windows   # For Windows
flutter run -d android   # For Android
```

**Note**: See `camera/LAUNCH.md` for detailed Flutter launch instructions.

### Expose Socket.IO Server (ngrok)

```bash
cd server
ngrok start --config=./ngrok.yml socketio
```

Update the URL in `camera/lib/shared/services/socket_service.dart` with your ngrok URL.

## Project Structure

```
Digiteye/
├── camera/                    # Flutter application
│   ├── lib/
│   │   ├── main.dart          # Entry point
│   │   ├── app.dart           # App configuration
│   │   ├── features/          # Feature modules
│   │   │   ├── auth/          # Authentication
│   │   │   ├── socket/        # Socket.IO connection
│   │   │   └── stream/        # Video streaming
│   │   ├── shared/
│   │   │   └── services/      # Shared services
│   │   └── core/              # Core logic (DI, networking, etc.)
│   ├── pubspec.yaml           # Flutter dependencies
│   └── LAUNCH.md              # Flutter launch guide
│
├── server/                    # Backend
│   ├── src/
│   │   ├── server.ts          # Main Express server
│   │   ├── socket_manager.ts  # Socket.IO manager
│   │   └── routes/
│   │       └── sockets/       # Socket.IO routes
│   ├── bridge.py              # FastAPI (Qwen2-VL)
│   ├── weights/               # Model weights (auto-download)
│   ├── package.json           # Node.js dependencies
│   ├── requirements.txt       # Python dependencies
│   └── SOCKET_ROUTES.md       # Socket.IO routes documentation
│
└── README.md                  # This file
```

## Documentation

* **Flutter Application**: See `camera/LAUNCH.md`
* **Socket.IO Routes**: See `server/SOCKET_ROUTES.md`
* **Flutter Architecture**: See `camera/ARCHITECTURE.md`

## Configuration

### Socket.IO Server Configuration

Server URL is set in:

* `camera/lib/shared/services/socket_service.dart` (default URL)
* Environment variable or config file

### FastAPI Server Configuration

Optional environment variables:

```bash
# Directory for model weights
export WEIGHTS_DIR="./weights/Qwen2-VL-2B-Instruct"

# Max concurrent requests
export MAX_CONCURRENT=1

# Acquisition timeout
export ACQUIRE_TIMEOUT_S=0

# Retry delay
export RETRY_AFTER_S=1
```

### Default Model Prompt

Can be modified in `server/bridge.py`:

```python
DEFAULT_PROMPT = "Describe this image in accurate, concise detail."
```

## Troubleshooting

### FastAPI Server Won’t Start

1. **Check CUDA**:

   ```bash
   python -c "import torch; print(torch.cuda.is_available())"
   ```

2. **Check dependencies**:

   ```bash
   pip install -r server/requirements.txt
   ```

3. **Check disk space**: Model requires ~2GB

### Flutter App Cannot Connect

1. Verify server URL in `socket_service.dart`
2. Ensure Socket.IO server is running
3. Check ngrok if used in production
4. Verify permissions (camera, microphone)

### Flutter Dependency Issues

```bash
cd camera
flutter clean
flutter pub get
```

### Build Issues

```bash
# Android
cd camera/android
./gradlew clean

# iOS (Mac)
cd camera/ios
pod install
```

## API Endpoints

### FastAPI (Qwen2-VL)

* **GET `/`** : Server info
* **GET `/healthz`** : Health check
* **POST `/caption-file`** : Generate image captions

  * Parameters:

    * `file` : Image file (required)
    * `prompt` : Custom prompt (optional)
    * `max_new_tokens` : Max tokens (default: 128)
    * `temperature` : Generation temperature (default: 0.2)

### Socket.IO

See `server/SOCKET_ROUTES.md` for full documentation.

Main routes:

* `connection:welcome` : Welcome message
* `session:start` : Start session
* `video:frame` : Send video frame
* `llm:message` : Send message to LLM
* `llm:response` : Receive LLM response

## Authors

* Jacques Marques
* Matthis Brocheton
* Louis De Caumont
* Antoine Dufour
* Alex Di Venanzio

---

**Note**: This project requires an NVIDIA GPU with CUDA. CPU-only operation is not supported due to performance constraints.
