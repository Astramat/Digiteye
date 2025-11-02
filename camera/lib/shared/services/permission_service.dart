import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

/// Service pour gérer les permissions de l'application
class PermissionService {
  static PermissionService? _instance;
  
  /// Singleton pattern
  static PermissionService get instance {
    _instance ??= PermissionService._internal();
    return _instance!;
  }

  PermissionService._internal();

  /// Demande les permissions pour la caméra et le microphone
  Future<PermissionStatus> requestCameraAndMicrophonePermissions() async {
    try {
      // Demander les permissions caméra et microphone
      final Map<Permission, PermissionStatus> statuses = await [
        Permission.camera,
        Permission.microphone,
      ].request();

      final cameraStatus = statuses[Permission.camera];
      final microphoneStatus = statuses[Permission.microphone];

      if (kDebugMode) {
        print('Camera permission: $cameraStatus');
        print('Microphone permission: $microphoneStatus');
      }

      // Retourner le statut global
      if (cameraStatus == PermissionStatus.granted && 
          microphoneStatus == PermissionStatus.granted) {
        return PermissionStatus.granted;
      } else if (cameraStatus == PermissionStatus.denied || 
                 microphoneStatus == PermissionStatus.denied) {
        return PermissionStatus.denied;
      } else {
        return PermissionStatus.permanentlyDenied;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Erreur lors de la demande de permissions: $e');
      }
      return PermissionStatus.denied;
    }
  }

  /// Vérifie si les permissions sont accordées
  Future<bool> hasCameraAndMicrophonePermissions() async {
    final cameraStatus = await Permission.camera.status;
    final microphoneStatus = await Permission.microphone.status;
    
    return cameraStatus == PermissionStatus.granted && 
           microphoneStatus == PermissionStatus.granted;
  }

  /// Ouvre les paramètres de l'application
  Future<void> openAppSettingsPage() async {
    await openAppSettings();
  }

  /// Obtient le message d'erreur approprié selon le statut
  String getPermissionErrorMessage(PermissionStatus status) {
    switch (status) {
      case PermissionStatus.denied:
        return 'Les permissions caméra et microphone sont nécessaires pour utiliser cette fonctionnalité.';
      case PermissionStatus.permanentlyDenied:
        return 'Les permissions ont été refusées de façon permanente. Veuillez les activer dans les paramètres de l\'application.';
      case PermissionStatus.restricted:
        return 'Les permissions sont restreintes sur cet appareil.';
      case PermissionStatus.limited:
        return 'Les permissions sont limitées sur cet appareil.';
      case PermissionStatus.provisional:
        return 'Les permissions sont provisoires.';
      case PermissionStatus.granted:
        return 'Permissions accordées.';
    }
  }
}
