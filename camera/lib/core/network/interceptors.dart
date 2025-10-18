import 'package:http/http.dart' as http;

/// Intercepteur pour ajouter des headers d'authentification
class AuthInterceptor {
  final String Function()? getToken;
  
  const AuthInterceptor({this.getToken});
  
  /// Intercepte la requête pour ajouter le token d'authentification
  Future<http.BaseRequest> onRequest(http.BaseRequest request) async {
    final token = getToken?.call();
    
    if (token != null && token.isNotEmpty) {
      request.headers['Authorization'] = 'Bearer $token';
    }
    
    return request;
  }
}

/// Intercepteur pour logger les requêtes
class LoggingInterceptor {
  const LoggingInterceptor();
  
  /// Intercepte la requête pour le logging
  Future<http.BaseRequest> onRequest(http.BaseRequest request) async {
    print('🚀 ${request.method} ${request.url}');
    print('📤 Headers: ${request.headers}');
    
    if (request is http.Request && request.body.isNotEmpty) {
      print('📤 Body: ${request.body}');
    }
    
    return request;
  }
  
  /// Intercepte la réponse pour le logging
  void onResponse(http.Response response) {
    print('📥 ${response.statusCode} ${response.request?.url}');
    print('📥 Headers: ${response.headers}');
    
    if (response.body.isNotEmpty) {
      print('📥 Body: ${response.body}');
    }
  }
  
  /// Intercepte l'erreur pour le logging
  void onError(dynamic error) {
    print('❌ Error: $error');
  }
}
