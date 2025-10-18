import 'package:flutter/foundation.dart';

/// Service d'analytics et de tracking
class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();
  
  /// Initialise le service d'analytics
  static Future<void> initialize() async {
    // Initialisation du service d'analytics
    // Utilisez Firebase Analytics, Mixpanel, ou un autre service
    if (kDebugMode) {
      print('Analytics Service initialized');
    }
  }
  
  /// Enregistre un événement
  static Future<void> logEvent(String eventName, {Map<String, dynamic>? parameters}) async {
    if (kDebugMode) {
      print('Event: $eventName ${parameters ?? ''}');
    }
    
    // Envoi de l'événement à votre service d'analytics
    // await firebaseAnalytics.logEvent(
    //   name: eventName,
    //   parameters: parameters,
    // );
  }
  
  /// Enregistre l'écran actuel
  static Future<void> setCurrentScreen(String screenName) async {
    if (kDebugMode) {
      print('Screen: $screenName');
    }
    
    // await firebaseAnalytics.setCurrentScreen(screenName: screenName);
  }
  
  /// Enregistre l'identifiant utilisateur
  static Future<void> setUserId(String userId) async {
    if (kDebugMode) {
      print('User ID: $userId');
    }
    
    // await firebaseAnalytics.setUserId(id: userId);
  }
  
  /// Enregistre les propriétés utilisateur
  static Future<void> setUserProperties(Map<String, dynamic> properties) async {
    if (kDebugMode) {
      print('User Properties: $properties');
    }
    
    // for (final entry in properties.entries) {
    //   await firebaseAnalytics.setUserProperty(
    //     name: entry.key,
    //     value: entry.value.toString(),
    //   );
    // }
  }
  
  /// Événements prédéfinis
  static Future<void> logLogin(String method) async {
    await logEvent('login', parameters: {'method': method});
  }
  
  static Future<void> logSignUp(String method) async {
    await logEvent('sign_up', parameters: {'method': method});
  }
  
  static Future<void> logLogout() async {
    await logEvent('logout');
  }
  
  static Future<void> logPurchase(double value, String currency) async {
    await logEvent('purchase', parameters: {
      'value': value,
      'currency': currency,
    });
  }
  
  static Future<void> logSearch(String searchTerm) async {
    await logEvent('search', parameters: {'search_term': searchTerm});
  }
  
  static Future<void> logViewItem(String itemId, String itemName) async {
    await logEvent('view_item', parameters: {
      'item_id': itemId,
      'item_name': itemName,
    });
  }
  
  static Future<void> logAddToCart(String itemId, String itemName, String category) async {
    await logEvent('add_to_cart', parameters: {
      'item_id': itemId,
      'item_name': itemName,
      'item_category': category,
    });
  }
  
  static Future<void> logRemoveFromCart(String itemId, String itemName) async {
    await logEvent('remove_from_cart', parameters: {
      'item_id': itemId,
      'item_name': itemName,
    });
  }
  
  static Future<void> logShare(String contentType, String itemId) async {
    await logEvent('share', parameters: {
      'content_type': contentType,
      'item_id': itemId,
    });
  }
}
