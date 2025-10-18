import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';

// import 'package:record/record.dart'; // Commenté temporairement

import 'socket_service.dart';

/// Service pour gérer le streaming vidéo et audio
class StreamingService extends ChangeNotifier {
  static StreamingService? _instance;

  /// Singleton pattern
  static StreamingService get instance {
    _instance ??= StreamingService._internal();
    return _instance!;
  }

  StreamingService._internal();

  // Camera
  CameraController? _cameraController;
  List<CameraDescription> _cameras = [];
  bool _isCameraInitialized = false;
  Timer? _videoStreamTimer;

  // Audio - Désactivé temporairement
  // final AudioRecorder _audioRecorder = AudioRecorder();
  bool _isRecording = false;
  Timer? _audioStreamTimer;
  // StreamSubscription<Amplitude>? _amplitudeSubscription;

  // Streaming state
  bool _isStreaming = false;
  bool _serverReady = false;

  // Getters
  CameraController? get cameraController => _cameraController;
  bool get isCameraInitialized => _isCameraInitialized;
  bool get isRecording => _isRecording;
  bool get isStreaming => _isStreaming;
  bool get serverReady => _serverReady;
  List<CameraDescription> get cameras => _cameras;

  /// Initialise la caméra
  Future<bool> initializeCamera() async {
    try {
      if (kDebugMode) {
        print('🎥 DEBUG: Début initializeCamera()');
      }

      // Web support: le plugin camera supporte aussi le web pour l'aperçu.
      // On ne court-circuite plus l'initialisation ici afin d'obtenir un CameraController
      // utilisable par CameraPreview également sur le web.

      // Si la caméra est déjà initialisée, ne rien faire
      if (_isCameraInitialized && _cameraController != null) {
        return true;
      }

      // Nettoyer l'ancienne instance si elle existe
      if (_cameraController != null) {
        await _cameraController!.dispose();
        _cameraController = null;
      }

      if (kDebugMode) {
        print('🎥 DEBUG: Recherche des caméras disponibles...');
      }
      _cameras = await availableCameras();
      if (kDebugMode) {
        print('🎥 DEBUG: Caméras trouvées: ${_cameras.length}');
      }
      if (_cameras.isEmpty) {
        if (kDebugMode) {
          print('🎥 DEBUG: Aucune caméra disponible');
        }
        return false;
      }

      if (kDebugMode) {
        print('🎥 DEBUG: Création du CameraController...');
      }
      // Choisir de préférence la caméra frontale si disponible
      final CameraDescription selectedCamera = _cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => _cameras.first,
      );

      _cameraController = CameraController(
        selectedCamera,
        ResolutionPreset.low,
        enableAudio: false,
        // Ne pas forcer imageFormatGroup pour compatibilité maximale (web/mobile)
      );

      if (kDebugMode) {
        print('🎥 DEBUG: Initialisation du CameraController...');
      }
      await _cameraController!.initialize();
      _isCameraInitialized = true;
      notifyListeners();

      if (kDebugMode) {
        print('🎥 DEBUG: Caméra initialisée avec succès');
        print('🎥 DEBUG: isCameraInitialized: $_isCameraInitialized');
        print(
          '🎥 DEBUG: cameraController != null: ${_cameraController != null}',
        );
      }
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('🎥 DEBUG: ERREUR lors de l\'initialisation de la caméra: $e');
        print('🎥 DEBUG: Type d\'erreur: ${e.runtimeType}');
      }
      _isCameraInitialized = false;
      _cameraController = null;
      notifyListeners();
      return false;
    }
  }

  /// Démarre le streaming vidéo
  Future<void> startVideoStreaming() async {
    if (!_isCameraInitialized) {
      if (kDebugMode) {
        print('Caméra non initialisée');
      }
      return;
    }

    try {
      if (_cameraController == null) {
        if (kDebugMode) {
          print('CameraController non disponible');
        }
        return;
      }

      // Utiliser takePicture() sur toutes les plateformes pour un format d'image uniforme
      if (kDebugMode) {
        print('Utilisation de takePicture() pour le streaming (web et mobile)');
      }
      _videoStreamTimer = Timer.periodic(const Duration(milliseconds: 125), (
        timer,
      ) {
        _captureAndSendImage();
      });
    } catch (e) {
      if (kDebugMode) {
        print('Erreur lors du démarrage du streaming vidéo: $e');
      }
    }
  }

  /// Arrête le streaming vidéo
  Future<void> stopVideoStreaming() async {
    try {
      _videoStreamTimer?.cancel();
      _videoStreamTimer = null;

      if (!kIsWeb &&
          _cameraController != null &&
          _cameraController!.value.isStreamingImages) {
        await _cameraController!.stopImageStream();
      }

      if (kDebugMode) {
        print('Streaming vidéo arrêté');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Erreur lors de l\'arrêt du streaming vidéo: $e');
      }
    }
  }

  /// Démarre l'enregistrement audio
  Future<void> startAudioRecording() async {
    try {
      if (kDebugMode) {
        print('Enregistrement audio simulé (package record désactivé)');
      }

      _isRecording = true;
      notifyListeners();

      // Simuler l'envoi de données audio avec un timer stocké
      _audioStreamTimer = Timer.periodic(const Duration(milliseconds: 100), (
        timer,
      ) {
        _simulateAudioData();
      });
    } catch (e) {
      if (kDebugMode) {
        print('Erreur lors du démarrage de l\'enregistrement audio: $e');
      }
    }
  }

  /// Arrête l'enregistrement audio
  Future<void> stopAudioRecording() async {
    try {
      _isRecording = false;
      notifyListeners();

      // Arrêter le timer audio
      _audioStreamTimer?.cancel();
      _audioStreamTimer = null;

      if (kDebugMode) {
        print('Enregistrement audio arrêté');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Erreur lors de l\'arrêt de l\'enregistrement audio: $e');
      }
    }
  }

  /// Démarre le streaming complet
  Future<void> startStreaming() async {
    if (_isStreaming) return;

    _isStreaming = true;
    notifyListeners();

    // Toujours initialiser la caméra avant d'attendre le serveur
    if (!_isCameraInitialized || _cameraController == null) {
      final cameraOk = await initializeCamera();
      if (!cameraOk) {
        if (kDebugMode) {
          print('🎥 DEBUG: Échec initializeCamera()');
        }
        _isStreaming = false;
        notifyListeners();
        return;
      }
    }

    // Attendre que le serveur soit prêt (mais l'aperçu est déjà visible)
    await _waitForServerReady();

    if (_serverReady) {
      await startVideoStreaming();
      await startAudioRecording();

      // Notifier le serveur que le streaming a démarré
      SocketService.instance.emit('streaming:started', {
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
    }
  }

  /// Arrête le streaming complet
  Future<void> stopStreaming() async {
    if (!_isStreaming) return;

    _isStreaming = false;
    notifyListeners();

    await stopVideoStreaming();
    await stopAudioRecording();

    // Réinitialiser l'état de la caméra
    _isCameraInitialized = false;
    if (_cameraController != null) {
      await _cameraController!.dispose();
      _cameraController = null;
    }

    notifyListeners();

    // Notifier le serveur que le streaming s'est arrêté
    SocketService.instance.emit('streaming:stopped', {
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }

  /// Attend que le serveur soit prêt
  Future<void> _waitForServerReady() async {
    // Attendre un signal OK du serveur
    final completer = Completer<void>();

    void onServerReady(dynamic data) {
      _serverReady = true;
      completer.complete();
    }

    SocketService.instance.emit('server:ready', {});
    SocketService.instance.addSocketListener('server:ready', onServerReady);

    // Timeout après 10 secondes
    Timer(const Duration(seconds: 10), () {
      if (!completer.isCompleted) {
        _serverReady = false;
        completer.complete();
      }
    });

    await completer.future;
    SocketService.instance.removeSocketListener('server:ready', onServerReady);
  }

  // Méthodes startImageStream supprimées - on utilise takePicture() sur toutes les plateformes

  /// Capture et envoie une image (utilise takePicture sur toutes les plateformes)
  Future<void> _captureAndSendImage() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    try {
      final XFile imageFile = await _cameraController!.takePicture();
      final Uint8List imageBytes = await imageFile.readAsBytes();

      // Envoyer l'image au serveur via Socket.IO
      SocketService.instance.emit('video:frame', {
        'data': imageBytes,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'format': 'jpeg',
      });

      // Supprimer le fichier temporaire (si possible)
      try {
        final file = File(imageFile.path);
        if (await file.exists()) {
          await file.delete();
        }
      } catch (deleteError) {
        if (kDebugMode) {
          print(
            'Erreur lors de la suppression du fichier temporaire: $deleteError',
          );
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Erreur lors de la capture d\'image: $e');
      }
    }
  }

  // Méthode _convertCameraImageToBytes supprimée - on utilise takePicture() qui donne de vraies images JPEG

  /// Envoie les données audio (simulées)
  void _sendAudioData(dynamic amplitude) {
    SocketService.instance.emit('audio:data', {
      'amplitude': amplitude?.current ?? 0.5,
      'max_amplitude': amplitude?.max ?? 1.0,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }

  /// Simule une frame vidéo pour le web
  void _simulateVideoFrame() {
    // Créer des données simulées pour le web
    final simulatedData = List.generate(1000, (index) => index % 256);

    SocketService.instance.emit('video:frame', {
      'data': simulatedData,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'format': 'jpeg',
      'simulated': true,
    });
  }

  /// Simule des données audio pour le web
  void _simulateAudioData() {
    SocketService.instance.emit('audio:data', {
      'amplitude': (DateTime.now().millisecondsSinceEpoch % 100) / 100.0,
      'max_amplitude': 1.0,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'simulated': true,
    });
  }

  /// Réinitialise complètement le service
  Future<void> reset() async {
    await stopStreaming();
    _serverReady = false;
    notifyListeners();
  }

  /// Libère les ressources
  @override
  void dispose() {
    stopStreaming();
    _cameraController?.dispose();
    _audioStreamTimer?.cancel(); // Arrêter le timer audio
    // _audioRecorder.dispose(); // Commenté temporairement
    // _amplitudeSubscription?.cancel(); // Commenté temporairement
    super.dispose();
  }
}
