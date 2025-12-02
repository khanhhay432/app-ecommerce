import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

class ApiService {
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<void> setToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }

  static Future<Map<String, String>> _getHeaders({bool auth = false}) async {
    final headers = {'Content-Type': 'application/json'};
    if (auth) {
      final token = await getToken();
      if (token != null) headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  static Future<Map<String, dynamic>> get(String endpoint, {bool auth = false}) async {
    final url = '${ApiConfig.baseUrl}$endpoint';
    print('🌐 [ApiService] GET: $url');
    
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: await _getHeaders(auth: auth),
      ).timeout(const Duration(seconds: 30));
      
      print('📡 [ApiService] Status: ${response.statusCode}');
      print('📦 [ApiService] Response length: ${response.body.length} bytes');
      return _handleResponse(response);
    } catch (e) {
      print('❌ [ApiService] Request failed: $e');
      print('💡 [ApiService] Tip: Check if backend is running and IP is correct');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> body, {bool auth = false}) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}$endpoint'),
      headers: await _getHeaders(auth: auth),
      body: jsonEncode(body),
    );
    return _handleResponse(response);
  }

  static Future<Map<String, dynamic>> put(String endpoint, Map<String, dynamic> body, {bool auth = false}) async {
    final response = await http.put(
      Uri.parse('${ApiConfig.baseUrl}$endpoint'),
      headers: await _getHeaders(auth: auth),
      body: jsonEncode(body),
    );
    return _handleResponse(response);
  }


  static Future<Map<String, dynamic>> delete(String endpoint, {bool auth = false}) async {
    final response = await http.delete(
      Uri.parse('${ApiConfig.baseUrl}$endpoint'),
      headers: await _getHeaders(auth: auth),
    );
    return _handleResponse(response);
  }

  static Map<String, dynamic> _handleResponse(http.Response response) {
    final body = jsonDecode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    } else {
      throw Exception(body['message'] ?? 'Request failed');
    }
  }
}
