import '../../../../core/storage/local_storage.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../../../core/error/exceptions.dart';
import '../models/user_model.dart';

/// Source de données locale pour l'authentification
abstract class AuthLocalDataSource {
  Future<UserModel?> getCachedUser();
  Future<void> cacheUser(UserModel user);
  Future<void> clearUserCache();
  Future<String?> getAuthToken();
  Future<void> cacheAuthToken(String token);
  Future<void> clearAuthToken();
  Future<String?> getRefreshToken();
  Future<void> cacheRefreshToken(String token);
  Future<void> clearRefreshToken();
  Future<bool> isLoggedIn();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final LocalStorage localStorage;
  final SecureStorage secureStorage;
  
  static const String _userCacheKey = 'cached_user';
  static const String _authTokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _isLoggedInKey = 'is_logged_in';
  
  AuthLocalDataSourceImpl({
    required this.localStorage,
    required this.secureStorage,
  });
  
  @override
  Future<UserModel?> getCachedUser() async {
    try {
      final userJson = localStorage.getJson(_userCacheKey);
      if (userJson != null) {
        return UserModel.fromJson(userJson);
      }
      return null;
    } catch (e) {
      throw CacheException('Erreur lors de la récupération de l\'utilisateur en cache: $e');
    }
  }
  
  @override
  Future<void> cacheUser(UserModel user) async {
    try {
      await localStorage.setJson(_userCacheKey, user.toJson());
      await localStorage.setBool(_isLoggedInKey, true);
    } catch (e) {
      throw CacheException('Erreur lors de la mise en cache de l\'utilisateur: $e');
    }
  }
  
  @override
  Future<void> clearUserCache() async {
    try {
      await localStorage.remove(_userCacheKey);
      await localStorage.setBool(_isLoggedInKey, false);
    } catch (e) {
      throw CacheException('Erreur lors du nettoyage du cache utilisateur: $e');
    }
  }
  
  @override
  Future<String?> getAuthToken() async {
    try {
      return await secureStorage.getToken();
    } catch (e) {
      throw CacheException('Erreur lors de la récupération du token: $e');
    }
  }
  
  @override
  Future<void> cacheAuthToken(String token) async {
    try {
      await secureStorage.saveToken(token);
    } catch (e) {
      throw CacheException('Erreur lors de la mise en cache du token: $e');
    }
  }
  
  @override
  Future<void> clearAuthToken() async {
    try {
      await secureStorage.deleteToken();
    } catch (e) {
      throw CacheException('Erreur lors de la suppression du token: $e');
    }
  }
  
  @override
  Future<String?> getRefreshToken() async {
    try {
      return await secureStorage.read('refresh_token');
    } catch (e) {
      throw CacheException('Erreur lors de la récupération du refresh token: $e');
    }
  }
  
  @override
  Future<void> cacheRefreshToken(String token) async {
    try {
      await secureStorage.write('refresh_token', token);
    } catch (e) {
      throw CacheException('Erreur lors de la mise en cache du refresh token: $e');
    }
  }
  
  @override
  Future<void> clearRefreshToken() async {
    try {
      await secureStorage.delete('refresh_token');
    } catch (e) {
      throw CacheException('Erreur lors de la suppression du refresh token: $e');
    }
  }
  
  @override
  Future<bool> isLoggedIn() async {
    try {
      final isLoggedIn = localStorage.getBool(_isLoggedInKey) ?? false;
      final hasToken = await getAuthToken() != null;
      return isLoggedIn && hasToken;
    } catch (e) {
      throw CacheException('Erreur lors de la vérification du statut de connexion: $e');
    }
  }
}
