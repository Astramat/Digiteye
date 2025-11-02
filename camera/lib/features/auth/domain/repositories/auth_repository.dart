import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/user.dart';

/// Repository abstrait pour l'authentification
abstract class AuthRepository {
  /// Connexion avec email et mot de passe
  Future<Either<Failure, User>> login(String email, String password);
  
  /// Inscription d'un nouvel utilisateur
  Future<Either<Failure, User>> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? phone,
  });
  
  /// Déconnexion
  Future<Either<Failure, void>> logout();
  
  /// Récupération du mot de passe
  Future<Either<Failure, void>> forgotPassword(String email);
  
  /// Réinitialisation du mot de passe
  Future<Either<Failure, void>> resetPassword({
    required String token,
    required String newPassword,
  });
  
  /// Changement de mot de passe
  Future<Either<Failure, void>> changePassword({
    required String currentPassword,
    required String newPassword,
  });
  
  /// Récupération de l'utilisateur actuel
  Future<Either<Failure, User?>> getCurrentUser();
  
  /// Vérification du statut de connexion
  Future<Either<Failure, bool>> isLoggedIn();
  
  /// Rafraîchissement du token
  Future<Either<Failure, String>> refreshToken();
  
  /// Mise à jour du profil utilisateur
  Future<Either<Failure, User>> updateProfile(User user);
  
  /// Suppression du compte
  Future<Either<Failure, void>> deleteAccount();
}
