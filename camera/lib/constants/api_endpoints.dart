/// Endpoints de l'API
class ApiEndpoints {
  // Authentification
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/refresh';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
  static const String changePassword = '/auth/change-password';
  
  // Utilisateurs
  static const String users = '/users';
  static const String userProfile = '/users/profile';
  static const String updateProfile = '/users/profile';
  static const String deleteAccount = '/users/account';
  
  // Exemple de feature (à adapter selon vos besoins)
  static const String posts = '/posts';
  static const String postById = '/posts/{id}';
  static const String createPost = '/posts';
  static const String updatePost = '/posts/{id}';
  static const String deletePost = '/posts/{id}';
  
  // Upload de fichiers
  static const String upload = '/upload';
  static const String uploadImage = '/upload/image';
  static const String uploadDocument = '/upload/document';
  
  // Configuration
  static const String appConfig = '/config';
  static const String healthCheck = '/health';
  
  // Méthodes utilitaires pour construire les URLs avec paramètres
  static String postByIdUrl(String id) => postById.replaceAll('{id}', id);
  static String updatePostUrl(String id) => updatePost.replaceAll('{id}', id);
  static String deletePostUrl(String id) => deletePost.replaceAll('{id}', id);
}
