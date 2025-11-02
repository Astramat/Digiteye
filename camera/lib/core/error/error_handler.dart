import 'dart:developer' as dev;
import 'exceptions.dart';
import 'failures.dart';

/// Gestionnaire d'erreurs centralisé
class ErrorHandler {
  /// Convertit une exception en Failure
  static Failure handleException(dynamic exception) {
    dev.log('Exception caught: $exception', name: 'ErrorHandler');
    
    if (exception is ServerException) {
      return ServerFailure(exception.message, exception.statusCode);
    } else if (exception is CacheException) {
      return CacheFailure(exception.message);
    } else if (exception is NetworkException) {
      return NetworkFailure(exception.message);
    } else if (exception is ValidationException) {
      return ValidationFailure(exception.message);
    } else if (exception is AuthenticationException) {
      return AuthenticationFailure(exception.message);
    } else if (exception is PermissionException) {
      return PermissionFailure(exception.message);
    } else {
      return UnknownFailure('Une erreur inattendue s\'est produite');
    }
  }
  
  /// Gère les erreurs HTTP
  static Failure handleHttpError(int statusCode, String message) {
    switch (statusCode) {
      case 400:
        return ValidationFailure('Requête invalide: $message');
      case 401:
        return AuthenticationFailure('Non autorisé: $message');
      case 403:
        return PermissionFailure('Accès refusé: $message');
      case 404:
        return ServerFailure('Ressource non trouvée: $message', statusCode);
      case 500:
        return ServerFailure('Erreur serveur interne: $message', statusCode);
      default:
        return ServerFailure('Erreur HTTP $statusCode: $message', statusCode);
    }
  }
  
  /// Gère les erreurs de réseau
  static Failure handleNetworkError(dynamic error) {
    if (error.toString().contains('SocketException')) {
      return NetworkFailure('Vérifiez votre connexion internet');
    } else if (error.toString().contains('TimeoutException')) {
      return NetworkFailure('Délai d\'attente dépassé');
    } else {
      return NetworkFailure('Erreur de connexion: ${error.toString()}');
    }
  }
}
