import 'package:equatable/equatable.dart';
import '../../domain/entities/user.dart';

/// États du bloc d'authentification
abstract class AuthState extends Equatable {
  const AuthState();
  
  @override
  List<Object?> get props => [];
}

/// État initial
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// État de chargement
class AuthLoading extends AuthState {
  const AuthLoading();
}

/// État d'authentification réussie
class AuthAuthenticated extends AuthState {
  final User user;
  
  const AuthAuthenticated({required this.user});
  
  @override
  List<Object> get props => [user];
}

/// État de non-authentification
class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

/// État d'erreur
class AuthError extends AuthState {
  final String message;
  
  const AuthError({required this.message});
  
  @override
  List<Object> get props => [message];
}

/// État de succès pour les opérations sans retour de données
class AuthSuccess extends AuthState {
  final String message;
  
  const AuthSuccess({required this.message});
  
  @override
  List<Object> get props => [message];
}

/// État de profil mis à jour
class ProfileUpdated extends AuthState {
  final User user;
  
  const ProfileUpdated({required this.user});
  
  @override
  List<Object> get props => [user];
}

/// État de compte supprimé
class AccountDeleted extends AuthState {
  const AccountDeleted();
}
