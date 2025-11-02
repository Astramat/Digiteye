import 'package:equatable/equatable.dart';

/// Classe abstraite pour les échecs de l'application
abstract class Failure extends Equatable {
  final String message;
  final int? statusCode;
  
  const Failure(this.message, [this.statusCode]);
  
  @override
  List<Object?> get props => [message, statusCode];
}

/// Échec du serveur
class ServerFailure extends Failure {
  const ServerFailure(super.message, [super.statusCode]);
}

/// Échec du cache local
class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

/// Échec du réseau
class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

/// Échec de validation
class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

/// Échec d'authentification
class AuthenticationFailure extends Failure {
  const AuthenticationFailure(super.message);
}

/// Échec de permission
class PermissionFailure extends Failure {
  const PermissionFailure(super.message);
}

/// Échec inconnu
class UnknownFailure extends Failure {
  const UnknownFailure(super.message);
}
