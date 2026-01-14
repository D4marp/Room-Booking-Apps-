import 'package:http/http.dart' as http;
import 'dart:convert';
import 'api_config.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  late http.Client _httpClient;
  String? _authToken;

  ApiService._internal() {
    _httpClient = http.Client();
  }

  factory ApiService() {
    return _instance;
  }

  // Set auth token
  void setAuthToken(String token) {
    _authToken = token;
  }

  // Clear auth token
  void clearAuthToken() {
    _authToken = null;
  }

  // Build headers
  Map<String, String> _buildHeaders() {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    return headers;
  }

  // GET request
  Future<dynamic> get(String endpoint) async {
    try {
      final response = await _httpClient.get(
        Uri.parse('${ApiConfig.baseUrl}$endpoint'),
        headers: _buildHeaders(),
      ).timeout(ApiConfig.connectionTimeout);

      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }
    }
  }

  // POST request
  Future<dynamic> post(String endpoint, {required dynamic data}) async {
    try {
      final response = await _httpClient.post(
        Uri.parse('${ApiConfig.baseUrl}$endpoint'),
        headers: _buildHeaders(),
        body: jsonEncode(data),
      ).timeout(ApiConfig.connectionTimeout);

      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // PUT request
  Future<dynamic> put(String endpoint, {required dynamic data}) async {
    try {
      final response = await _httpClient.put(
        Uri.parse('${ApiConfig.baseUrl}$endpoint'),
        headers: _buildHeaders(),
        body: jsonEncode(data),
      ).timeout(ApiConfig.connectionTimeout);

      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // DELETE request
  Future<dynamic> delete(String endpoint) async {
    try {
      final response = await _httpClient.delete(
        Uri.parse('${ApiConfig.baseUrl}$endpoint'),
        headers: _buildHeaders(),
      ).timeout(ApiConfig.connectionTimeout);

      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Handle response
  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) {
        return {};
      }
      try {
        return jsonDecode(response.body);
      } catch (e) {
        throw 'Invalid response format';
      }
    } else if (response.statusCode == 401) {
      clearAuthToken();
      throw 'Unauthorized - Please login again';
    } else if (response.statusCode == 403) {
      throw 'Forbidden - Access denied';
    } else if (response.statusCode == 404) {
      throw 'Not found';
    } else if (response.statusCode >= 500) {
      throw 'Server error - Please try again later';
    } else {
      try {
        final errorBody = jsonDecode(response.body);
        throw errorBody['error'] ?? 'An error occurred';
      } catch (e) {
        throw 'Error: ${response.statusCode}';
      }
    }
  }

  // Handle errors
  String _handleError(dynamic error) {
    if (error is String) {
      return error;
    }
    return 'An unexpected error occurred';
  }
}
