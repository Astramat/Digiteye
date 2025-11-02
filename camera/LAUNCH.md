# Flutter Project Launch Guide

## Prerequisites

1. **Flutter SDK** installed (version 3.35.6 via FVM or a compatible version)
2. **Dart SDK** (included with Flutter)
3. **Recommended IDE**: VS Code or Android Studio
4. **Emulator/Device**:

   * Android: Android Studio emulator or physical device
   * iOS: Xcode simulator or physical device (Mac only)
   * Web: Chrome browser
   * Windows: Windows 10/11

## Dependency Installation

### Option 1: Using FVM (Flutter Version Manager)

If you are using FVM:

```bash
# Navigate to the camera folder
cd camera

# Install the Flutter version specified in .fvmrc
fvm install

# Use FVM for Flutter commands
fvm flutter pub get
```

### Option 2: Without FVM (Standard Flutter)

```bash
# Navigate to the camera folder
cd camera

# Install dependencies
flutter pub get
```

## Running the Application

### List Available Devices

```bash
flutter devices
```

### Run on Different Platforms

#### Android

```bash
flutter run
# Or specify a device
flutter run -d <device-id>
```

#### iOS (Mac only)

```bash
flutter run -d ios
```

#### Web

```bash
flutter run -d chrome
# Or with a specific port
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

## Useful Commands

### Debug Mode (with hot reload)

```bash
flutter run
```

* Press `r` for hot reload
* Press `R` for hot restart
* Press `q` to quit

### Release Mode (optimized)

```bash
flutter run --release
```

### Clean the Project

```bash
flutter clean
flutter pub get
```

### Code Generation (if needed)

```bash
flutter pub run build_runner build
# Or in watch mode
flutter pub run build_runner watch
```

## Troubleshooting

### Check Flutter Installation

```bash
flutter doctor
```

### Resolve Dependency Issues

```bash
flutter clean
flutter pub get
flutter pub upgrade
```

### Android-Specific Issues

```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
```

### iOS-Specific Issues

```bash
cd ios
pod install
cd ..
flutter clean
flutter pub get
```

## Configuration

### Socket.IO Server URL

The Socket.IO server is configured in `lib/shared/services/socket_service.dart`:

* Default URL: `http://localhost:3000`
* Can be modified in code or via configuration

### Required Permissions

The app requires:

* **Camera**: for video streaming
* **Microphone**: for audio (if enabled)

Permissions are automatically managed via `permission_handler`.

## Project Structure

* `lib/main.dart`: Application entry point
* `lib/app.dart`: App configuration
* `lib/features/`: Features (auth, socket, stream)
* `lib/shared/services/`: Shared services (socket, streaming, etc.)
* `lib/core/`: Core code (DI, network, storage, etc.)

## Support

* Flutter Documentation: [https://docs.flutter.dev](https://docs.flutter.dev)
* Dart Documentation: [https://dart.dev](https://dart.dev)
