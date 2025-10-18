import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../error/exceptions.dart';

/// Service de stockage local utilisant SharedPreferences
class LocalStorage {
  static LocalStorage? _instance;
  static SharedPreferences? _prefs;
  
  LocalStorage._();
  
  /// Constructeur public pour l'injection de dépendances
  factory LocalStorage() {
    _instance ??= LocalStorage._();
    return _instance!;
  }
  
  static Future<LocalStorage> getInstance() async {
    _instance ??= LocalStorage._();
    _prefs ??= await SharedPreferences.getInstance();
    return _instance!;
  }
  
  /// Sauvegarde une valeur string
  Future<bool> setString(String key, String value) async {
    try {
      return await _prefs!.setString(key, value);
    } catch (e) {
      throw CacheException('Erreur lors de la sauvegarde: $e');
    }
  }
  
  /// Récupère une valeur string
  String? getString(String key) {
    try {
      return _prefs!.getString(key);
    } catch (e) {
      throw CacheException('Erreur lors de la récupération: $e');
    }
  }
  
  /// Sauvegarde une valeur int
  Future<bool> setInt(String key, int value) async {
    try {
      return await _prefs!.setInt(key, value);
    } catch (e) {
      throw CacheException('Erreur lors de la sauvegarde: $e');
    }
  }
  
  /// Récupère une valeur int
  int? getInt(String key) {
    try {
      return _prefs!.getInt(key);
    } catch (e) {
      throw CacheException('Erreur lors de la récupération: $e');
    }
  }
  
  /// Sauvegarde une valeur bool
  Future<bool> setBool(String key, bool value) async {
    try {
      return await _prefs!.setBool(key, value);
    } catch (e) {
      throw CacheException('Erreur lors de la sauvegarde: $e');
    }
  }
  
  /// Récupère une valeur bool
  bool? getBool(String key) {
    try {
      return _prefs!.getBool(key);
    } catch (e) {
      throw CacheException('Erreur lors de la récupération: $e');
    }
  }
  
  /// Sauvegarde un objet JSON
  Future<bool> setJson(String key, Map<String, dynamic> json) async {
    try {
      final jsonString = jsonEncode(json);
      return await setString(key, jsonString);
    } catch (e) {
      throw CacheException('Erreur lors de la sérialisation: $e');
    }
  }
  
  /// Récupère un objet JSON
  Map<String, dynamic>? getJson(String key) {
    try {
      final jsonString = getString(key);
      if (jsonString != null) {
        return jsonDecode(jsonString) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      throw CacheException('Erreur lors de la désérialisation: $e');
    }
  }
  
  /// Supprime une clé
  Future<bool> remove(String key) async {
    try {
      return await _prefs!.remove(key);
    } catch (e) {
      throw CacheException('Erreur lors de la suppression: $e');
    }
  }
  
  /// Supprime toutes les clés
  Future<bool> clear() async {
    try {
      return await _prefs!.clear();
    } catch (e) {
      throw CacheException('Erreur lors du nettoyage: $e');
    }
  }
  
  /// Vérifie si une clé existe
  bool containsKey(String key) {
    try {
      return _prefs!.containsKey(key);
    } catch (e) {
      throw CacheException('Erreur lors de la vérification: $e');
    }
  }
  
  /// Récupère toutes les clés
  Set<String> getKeys() {
    try {
      return _prefs!.getKeys();
    } catch (e) {
      throw CacheException('Erreur lors de la récupération des clés: $e');
    }
  }
}
