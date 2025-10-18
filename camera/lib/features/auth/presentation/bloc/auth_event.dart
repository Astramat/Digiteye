import 'package:equatable/equatable.dart';

/// Événements du bloc d'authentification
abstract class AuthEvent extends Equatable {
  const AuthEvent();
  
  @override
  List<Object?> get props => [];
}

/// Événement de connexion
class LoginEvent extends AuthEvent {
  final String email;
  final String password;
  
  const LoginEvent({
    required this.email,
    required this.password,
  });
  
  @override
  List<Object> get props => [email, password];
}

/// Événement d'inscription
class RegisterEvent extends AuthEvent {
  final String email;
  final String password;
  final String firstName;
  final String lastName;
  final String? phone;
  
  const RegisterEvent({
    required this.email,
    required this.password,
    required this.firstName,
    required this.lastName,
    this.phone,
  });
  
  @override
  List<Object?> get props => [email, password, firstName, lastName, phone];
}

/// Événement de déconnexion
class LogoutEvent extends AuthEvent {
  const LogoutEvent();
}

/// Événement de vérification du statut de connexion
class CheckAuthStatusEvent extends AuthEvent {
  const CheckAuthStatusEvent();
}

/// Événement de récupération de l'utilisateur actuel
class GetCurrentUserEvent extends AuthEvent {
  const GetCurrentUserEvent();
}

/// Événement de récupération du mot de passe
class ForgotPasswordEvent extends AuthEvent {
  final String email;
  
  const ForgotPasswordEvent({required this.email});
  
  @override
  List<Object> get props => [email];
}

/// Événement de réinitialisation du mot de passe
class ResetPasswordEvent extends AuthEvent {
  final String token;
  final String newPassword;
  
  const ResetPasswordEvent({
    required this.token,
    required this.newPassword,
  });
  
  @override
  List<Object> get props => [token, newPassword];
}

/// Événement de changement de mot de passe
class ChangePasswordEvent extends AuthEvent {
  final String currentPassword;
  final String newPassword;
  
  const ChangePasswordEvent({
    required this.currentPassword,
    required this.newPassword,
  });
  
  @override
  List<Object> get props => [currentPassword, newPassword];
}

/// Événement de mise à jour du profil
class UpdateProfileEvent extends AuthEvent {
  final Map<String, dynamic> userData;
  
  const UpdateProfileEvent({required this.userData});
  
  @override
  List<Object> get props => [userData];
}

/// Événement de suppression du compte
class DeleteAccountEvent extends AuthEvent {
  const DeleteAccountEvent();
}
