import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

/// Use case pour l'inscription
class RegisterUseCase {
  final AuthRepository repository;
  
  RegisterUseCase(this.repository);
  
  /// Exécute l'inscription
  Future<Either<Failure, User>> call(RegisterParams params) async {
    return await repository.register(
      email: params.email,
      password: params.password,
      firstName: params.firstName,
      lastName: params.lastName,
      phone: params.phone,
    );
  }
}

/// Paramètres pour l'inscription
class RegisterParams {
  final String email;
  final String password;
  final String firstName;
  final String lastName;
  final String? phone;
  
  const RegisterParams({
    required this.email,
    required this.password,
    required this.firstName,
    required this.lastName,
    this.phone,
  });
}
