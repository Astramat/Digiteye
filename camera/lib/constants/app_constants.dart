/// Constantes globales de l'application
class AppConstants {
  // Informations de l'application
  static const String appName = 'Hackathon App';
  static const String appVersion = '1.0.0';
  static const String appBuildNumber = '1';
  
  // URLs et endpoints
  static const String baseUrl = 'https://api.example.com';
  static const String apiVersion = '/v1';
  static const String fullApiUrl = '$baseUrl$apiVersion';
  
  // Timeouts
  static const Duration apiTimeout = Duration(seconds: 30);
  static const Duration connectionTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 30);
  
  // Taille des pages pour la pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
  
  // Limites de validation
  static const int maxNameLength = 100;
  static const int maxEmailLength = 255;
  static const int maxPhoneLength = 20;
  static const int maxPasswordLength = 128;
  static const int minPasswordLength = 8;
  static const int maxDescriptionLength = 1000;
  
  // Formats
  static const String dateFormat = 'dd/MM/yyyy';
  static const String dateTimeFormat = 'dd/MM/yyyy HH:mm';
  static const String timeFormat = 'HH:mm';
  static const String currencyFormat = '€';
  static const String locale = 'fr_FR';
  
  // Clés de stockage
  static const String keyAuthToken = 'auth_token';
  static const String keyRefreshToken = 'refresh_token';
  static const String keyUserId = 'user_id';
  static const String keyUserEmail = 'user_email';
  static const String keyThemeMode = 'theme_mode';
  static const String keyLanguage = 'language';
  static const String keyFirstLaunch = 'first_launch';
  static const String keyNotificationsEnabled = 'notifications_enabled';
  
  // Messages d'erreur
  static const String errorNetwork = 'Erreur de connexion réseau';
  static const String errorServer = 'Erreur du serveur';
  static const String errorUnknown = 'Une erreur inattendue s\'est produite';
  static const String errorValidation = 'Données invalides';
  static const String errorAuth = 'Erreur d\'authentification';
  static const String errorPermission = 'Permission refusée';
  
  // Messages de succès
  static const String successSaved = 'Données sauvegardées';
  static const String successDeleted = 'Élément supprimé';
  static const String successUpdated = 'Élément mis à jour';
  static const String successCreated = 'Élément créé';
  
  // Messages d'information
  static const String infoLoading = 'Chargement...';
  static const String infoNoData = 'Aucune donnée disponible';
  static const String infoEmpty = 'Aucun élément';
  
  // Regex patterns
  static const String emailPattern = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
  static const String phonePattern = r'^(\+33|0)[1-9](\d{8})$';
  static const String postalCodePattern = r'^\d{5}$';
  static const String passwordPattern = r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)';
  
  // Animation durations
  static const Duration animationFast = Duration(milliseconds: 150);
  static const Duration animationNormal = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);
  
  // Breakpoints pour le responsive design
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 1024;
  static const double desktopBreakpoint = 1440;
  
  // Tailles d'image
  static const double avatarSize = 40;
  static const double avatarSizeLarge = 80;
  static const double thumbnailSize = 100;
  static const double imageMaxWidth = 800;
  static const double imageMaxHeight = 600;
  
  // Durées de cache
  static const Duration cacheShort = Duration(minutes: 5);
  static const Duration cacheMedium = Duration(hours: 1);
  static const Duration cacheLong = Duration(hours: 24);
  static const Duration cacheVeryLong = Duration(days: 7);
}
