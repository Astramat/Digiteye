import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/error_handler.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../datasources/auth_local_datasource.dart';
import '../models/user_model.dart';

/// Implémentation du repository d'authentification
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;
  final NetworkInfo networkInfo;
  
  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });
  
  @override
  Future<Either<Failure, User>> login(String email, String password) async {
    try {
      if (await networkInfo.isConnected) {
        final userModel = await remoteDataSource.login(email, password);
        await localDataSource.cacheUser(userModel);
        
        // Note: En réalité, vous devriez aussi sauvegarder le token d'authentification
        // qui serait retourné par l'API
        
        return Right(userModel.toEntity());
      } else {
        return const Left(NetworkFailure('Pas de connexion internet'));
      }
    } catch (e) {
      return Left(ErrorHandler.handleException(e));
    }
  }
  
  @override
  Future<Either<Failure, User>> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? phone,
  }) async {
    try {
      if (await networkInfo.isConnected) {
        final userData = {
          'email': email,
          'password': password,
          'first_name': firstName,
          'last_name': lastName,
          if (phone != null) 'phone': phone,
        };
        
        final userModel = await remoteDataSource.register(userData);
        await localDataSource.cacheUser(userModel);
        
        return Right(userModel.toEntity());
      } else {
        return const Left(NetworkFailure('Pas de connexion internet'));
      }
    } catch (e) {
      return Left(ErrorHandler.handleException(e));
    }
  }
  
  @override
  Future<Either<Failure, void>> logout() async {
    try {
      if (await networkInfo.isConnected) {
        await remoteDataSource.logout();
      }
      
      await localDataSource.clearUserCache();
      await localDataSource.clearAuthToken();
      await localDataSource.clearRefreshToken();
      
      return const Right(null);
    } catch (e) {
      // Même en cas d'erreur serveur, on nettoie le cache local
      await localDataSource.clearUserCache();
      await localDataSource.clearAuthToken();
      await localDataSource.clearRefreshToken();
      
      return Left(ErrorHandler.handleException(e));
    }
  }
  
  @override
  Future<Either<Failure, void>> forgotPassword(String email) async {
    try {
      if (await networkInfo.isConnected) {
        await remoteDataSource.forgotPassword(email);
        return const Right(null);
      } else {
        return const Left(NetworkFailure('Pas de connexion internet'));
      }
    } catch (e) {
      return Left(ErrorHandler.handleException(e));
    }
  }
  
  @override
  Future<Either<Failure, void>> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    try {
      if (await networkInfo.isConnected) {
        await remoteDataSource.resetPassword(token, newPassword);
        return const Right(null);
      } else {
        return const Left(NetworkFailure('Pas de connexion internet'));
      }
    } catch (e) {
      return Left(ErrorHandler.handleException(e));
    }
  }
  
  @override
  Future<Either<Failure, void>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      if (await networkInfo.isConnected) {
        await remoteDataSource.changePassword(currentPassword, newPassword);
        return const Right(null);
      } else {
        return const Left(NetworkFailure('Pas de connexion internet'));
      }
    } catch (e) {
      return Left(ErrorHandler.handleException(e));
    }
  }
  
  @override
  Future<Either<Failure, User?>> getCurrentUser() async {
    try {
      final cachedUser = await localDataSource.getCachedUser();
      if (cachedUser != null) {
        return Right(cachedUser.toEntity());
      }
      
      if (await networkInfo.isConnected) {
        final userModel = await remoteDataSource.getCurrentUser();
        await localDataSource.cacheUser(userModel);
        return Right(userModel.toEntity());
      }
      
      return const Right(null);
    } catch (e) {
      return Left(ErrorHandler.handleException(e));
    }
  }
  
  @override
  Future<Either<Failure, bool>> isLoggedIn() async {
    try {
      final isLoggedIn = await localDataSource.isLoggedIn();
      return Right(isLoggedIn);
    } catch (e) {
      return Left(ErrorHandler.handleException(e));
    }
  }
  
  @override
  Future<Either<Failure, String>> refreshToken() async {
    try {
      if (await networkInfo.isConnected) {
        final newToken = await remoteDataSource.refreshToken();
        await localDataSource.cacheAuthToken(newToken);
        return Right(newToken);
      } else {
        return const Left(NetworkFailure('Pas de connexion internet'));
      }
    } catch (e) {
      return Left(ErrorHandler.handleException(e));
    }
  }
  
  @override
  Future<Either<Failure, User>> updateProfile(User user) async {
    try {
      if (await networkInfo.isConnected) {
        final userModel = UserModel.fromEntity(user);
        final updatedUserModel = await remoteDataSource.updateProfile(userModel);
        await localDataSource.cacheUser(updatedUserModel);
        return Right(updatedUserModel.toEntity());
      } else {
        return const Left(NetworkFailure('Pas de connexion internet'));
      }
    } catch (e) {
      return Left(ErrorHandler.handleException(e));
    }
  }
  
  @override
  Future<Either<Failure, void>> deleteAccount() async {
    try {
      if (await networkInfo.isConnected) {
        await remoteDataSource.deleteAccount();
      }
      
      await localDataSource.clearUserCache();
      await localDataSource.clearAuthToken();
      await localDataSource.clearRefreshToken();
      
      return const Right(null);
    } catch (e) {
      return Left(ErrorHandler.handleException(e));
    }
  }
}
