import '../config/api_config.dart';
import '../models/user.dart';
import 'api_service.dart';

class AuthService {
  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await ApiService.post(ApiConfig.login, {
        'email': email,
        'password': password,
      });
      
      if (response['success'] == true && response['data'] != null) {
        final data = response['data'];
        final token = data['token'];
        final userData = data['user'];
        
        if (token != null) {
          await ApiService.setToken(token);
        }
        
        return {
          'success': true,
          'token': token,
          'user': userData != null ? User.fromJson(userData) : null,
        };
      }
      return {'success': false, 'message': response['message'] ?? 'Login failed'};
    } catch (e) {
      print('Error logging in: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String fullName,
    String? phone,
  }) async {
    try {
      final response = await ApiService.post(ApiConfig.register, {
        'email': email,
        'password': password,
        'fullName': fullName,
        'phone': phone,
      });
      
      if (response['success'] == true && response['data'] != null) {
        final data = response['data'];
        final token = data['token'];
        final userData = data['user'];
        
        if (token != null) {
          await ApiService.setToken(token);
        }
        
        return {
          'success': true,
          'token': token,
          'user': userData != null ? User.fromJson(userData) : null,
        };
      }
      return {'success': false, 'message': response['message'] ?? 'Registration failed'};
    } catch (e) {
      print('Error registering: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<void> logout() async {
    await ApiService.clearToken();
  }

  static Future<bool> isLoggedIn() async {
    final token = await ApiService.getToken();
    return token != null && token.isNotEmpty;
  }
}
