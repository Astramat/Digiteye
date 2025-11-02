import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../error/exceptions.dart';

/// Service de stockage sécurisé pour les données sensibles
class SecureStorage {
  static SecureStorage? _instance;
  late final FlutterSecureStorage _storage;
  
  SecureStorage._() {
    _storage = const FlutterSecureStorage(
      aOptions: AndroidOptions(
        encryptedSharedPreferences: true,
      ),
      iOptions: IOSOptions(
        accessibility: KeychainAccessibility.first_unlock_this_device,
      ),
    );
  }
  
  static SecureStorage get instance {
    _instance ??= SecureStorage._();
    return _instance!;
  }
  
  /// Sauvegarde une valeur sécurisée
  Future<void> write(String key, String value) async {
    try {
      await _storage.write(key: key, value: value);
    } catch (e) {
      throw CacheException('Erreur lors de la sauvegarde sécurisée: $e');
    }
  }
  
  /// Récupère une valeur sécurisée
  Future<String?> read(String key) async {
    try {
      return await _storage.read(key: key);
    } catch (e) {
      throw CacheException('Erreur lors de la lecture sécurisée: $e');
    }
  }
  
  /// Supprime une clé sécurisée
  Future<void> delete(String key) async {
    try {
      await _storage.delete(key: key);
    } catch (e) {
      throw CacheException('Erreur lors de la suppression sécurisée: $e');
    }
  }
  
  /// Supprime toutes les clés sécurisées
  Future<void> deleteAll() async {
    try {
      await _storage.deleteAll();
    } catch (e) {
      throw CacheException('Erreur lors du nettoyage sécurisé: $e');
    }
  }
  
  /// Vérifie si une clé existe
  Future<bool> containsKey(String key) async {
    try {
      return await _storage.containsKey(key: key);
    } catch (e) {
      throw CacheException('Erreur lors de la vérification sécurisée: $e');
    }
  }
  
  /// Récupère toutes les clés
  Future<Map<String, String>> readAll() async {
    try {
      return await _storage.readAll();
    } catch (e) {
      throw CacheException('Erreur lors de la lecture complète sécurisée: $e');
    }
  }
  
  /// Méthodes spécialisées pour les tokens
  Future<void> saveToken(String token) async {
    await write('auth_token', token);
  }
  
  Future<String?> getToken() async {
    return await read('auth_token');
  }
  
  Future<void> deleteToken() async {
    await delete('auth_token');
  }
  
  /// Méthodes spécialisées pour les identifiants
  Future<void> saveUserId(String userId) async {
    await write('user_id', userId);
  }
  
  Future<String?> getUserId() async {
    return await read('user_id');
  }
  
  Future<void> deleteUserId() async {
    await delete('user_id');
  }
}
