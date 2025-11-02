import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

/// Use case pour la connexion
class LoginUseCase {
  final AuthRepository repository;
  
  LoginUseCase(this.repository);
  
  /// Exécute la connexion
  Future<Either<Failure, User>> call(LoginParams params) async {
    return await repository.login(params.email, params.password);
  }
}

/// Paramètres pour la connexion
class LoginParams {
  final String email;
  final String password;
  
  const LoginParams({
    required this.email,
    required this.password,
  });
}
