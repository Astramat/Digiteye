import '../../../../core/network/api_client.dart';
import '../../../../core/error/exceptions.dart';
import '../models/user_model.dart';

/// Source de données distante pour l'authentification
abstract class AuthRemoteDataSource {
  Future<UserModel> login(String email, String password);
  Future<UserModel> register(Map<String, dynamic> userData);
  Future<void> logout();
  Future<void> forgotPassword(String email);
  Future<void> resetPassword(String token, String newPassword);
  Future<void> changePassword(String currentPassword, String newPassword);
  Future<UserModel> getCurrentUser();
  Future<String> refreshToken();
  Future<UserModel> updateProfile(UserModel user);
  Future<void> deleteAccount();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient apiClient;
  
  AuthRemoteDataSourceImpl({required this.apiClient});
  
  @override
  Future<UserModel> login(String email, String password) async {
    try {
      final response = await apiClient.post('/auth/login', body: {
        'email': email,
        'password': password,
      });
      
      return UserModel.fromJson(response['user']);
    } catch (e) {
      throw ServerException('Erreur lors de la connexion: $e');
    }
  }
  
  @override
  Future<UserModel> register(Map<String, dynamic> userData) async {
    try {
      final response = await apiClient.post('/auth/register', body: userData);
      
      return UserModel.fromJson(response['user']);
    } catch (e) {
      throw ServerException('Erreur lors de l\'inscription: $e');
    }
  }
  
  @override
  Future<void> logout() async {
    try {
      await apiClient.post('/auth/logout');
    } catch (e) {
      throw ServerException('Erreur lors de la déconnexion: $e');
    }
  }
  
  @override
  Future<void> forgotPassword(String email) async {
    try {
      await apiClient.post('/auth/forgot-password', body: {
        'email': email,
      });
    } catch (e) {
      throw ServerException('Erreur lors de la récupération du mot de passe: $e');
    }
  }
  
  @override
  Future<void> resetPassword(String token, String newPassword) async {
    try {
      await apiClient.post('/auth/reset-password', body: {
        'token': token,
        'password': newPassword,
      });
    } catch (e) {
      throw ServerException('Erreur lors de la réinitialisation du mot de passe: $e');
    }
  }
  
  @override
  Future<void> changePassword(String currentPassword, String newPassword) async {
    try {
      await apiClient.post('/auth/change-password', body: {
        'current_password': currentPassword,
        'new_password': newPassword,
      });
    } catch (e) {
      throw ServerException('Erreur lors du changement de mot de passe: $e');
    }
  }
  
  @override
  Future<UserModel> getCurrentUser() async {
    try {
      final response = await apiClient.get('/auth/me');
      
      return UserModel.fromJson(response['user']);
    } catch (e) {
      throw ServerException('Erreur lors de la récupération de l\'utilisateur: $e');
    }
  }
  
  @override
  Future<String> refreshToken() async {
    try {
      final response = await apiClient.post('/auth/refresh');
      
      return response['token'] as String;
    } catch (e) {
      throw ServerException('Erreur lors du rafraîchissement du token: $e');
    }
  }
  
  @override
  Future<UserModel> updateProfile(UserModel user) async {
    try {
      final response = await apiClient.put('/auth/profile', body: user.toJson());
      
      return UserModel.fromJson(response['user']);
    } catch (e) {
      throw ServerException('Erreur lors de la mise à jour du profil: $e');
    }
  }
  
  @override
  Future<void> deleteAccount() async {
    try {
      await apiClient.delete('/auth/account');
    } catch (e) {
      throw ServerException('Erreur lors de la suppression du compte: $e');
    }
  }
}
