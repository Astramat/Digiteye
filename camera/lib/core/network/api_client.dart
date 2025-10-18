import 'dart:convert';
import 'package:http/http.dart' as http;
import '../error/error_handler.dart';
import '../error/exceptions.dart';

/// Client API centralisé
class ApiClient {
  final String baseUrl;
  final Duration timeout;
  final Map<String, String> defaultHeaders;
  
  ApiClient({
    required this.baseUrl,
    this.timeout = const Duration(seconds: 30),
    Map<String, String>? defaultHeaders,
  }) : defaultHeaders = defaultHeaders ?? {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
  
  /// Requête GET
  Future<Map<String, dynamic>> get(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      final uri = _buildUri(endpoint, queryParams);
      final response = await http.get(
        uri,
        headers: {...defaultHeaders, ...?headers},
      ).timeout(timeout);
      
      return _handleResponse(response);
    } catch (e) {
      throw ErrorHandler.handleNetworkError(e);
    }
  }
  
  /// Requête POST
  Future<Map<String, dynamic>> post(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      final uri = _buildUri(endpoint, queryParams);
      final response = await http.post(
        uri,
        headers: {...defaultHeaders, ...?headers},
        body: body != null ? jsonEncode(body) : null,
      ).timeout(timeout);
      
      return _handleResponse(response);
    } catch (e) {
      throw ErrorHandler.handleNetworkError(e);
    }
  }
  
  /// Requête PUT
  Future<Map<String, dynamic>> put(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      final uri = _buildUri(endpoint, queryParams);
      final response = await http.put(
        uri,
        headers: {...defaultHeaders, ...?headers},
        body: body != null ? jsonEncode(body) : null,
      ).timeout(timeout);
      
      return _handleResponse(response);
    } catch (e) {
      throw ErrorHandler.handleNetworkError(e);
    }
  }
  
  /// Requête DELETE
  Future<Map<String, dynamic>> delete(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      final uri = _buildUri(endpoint, queryParams);
      final response = await http.delete(
        uri,
        headers: {...defaultHeaders, ...?headers},
      ).timeout(timeout);
      
      return _handleResponse(response);
    } catch (e) {
      throw ErrorHandler.handleNetworkError(e);
    }
  }
  
  /// Construit l'URI avec les paramètres de requête
  Uri _buildUri(String endpoint, Map<String, dynamic>? queryParams) {
    final uri = Uri.parse('$baseUrl$endpoint');
    
    if (queryParams != null && queryParams.isNotEmpty) {
      return uri.replace(queryParameters: queryParams.map(
        (key, value) => MapEntry(key, value.toString()),
      ));
    }
    
    return uri;
  }
  
  /// Gère la réponse HTTP
  Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) {
        return {};
      }
      
      try {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } catch (e) {
        throw const ServerException('Format de réponse invalide');
      }
    } else {
      final errorMessage = _extractErrorMessage(response.body);
      throw ServerException(
        errorMessage,
        response.statusCode,
      );
    }
  }
  
  /// Extrait le message d'erreur de la réponse
  String _extractErrorMessage(String responseBody) {
    try {
      final json = jsonDecode(responseBody) as Map<String, dynamic>;
      return json['message'] ?? json['error'] ?? 'Erreur serveur';
    } catch (e) {
      return 'Erreur serveur';
    }
  }
}
