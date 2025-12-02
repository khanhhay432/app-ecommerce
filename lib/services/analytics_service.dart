import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/analytics.dart';
import '../config/api_config.dart';
import 'api_service.dart';

class AnalyticsService {
  static Future<Analytics> getAnalytics(String period) async {
    try {
      final token = await ApiService.getToken();
      print('🔑 Token: ${token?.substring(0, 20)}...');
      
      final url = '${ApiConfig.baseUrl}/analytics?period=$period';
      print('🌐 Calling: $url');
      
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 30));

      print('📡 Status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        print('✅ Analytics data received');
        return Analytics.fromJson(data);
      } else if (response.statusCode == 403) {
        print('❌ 403 Forbidden - Token không hợp lệ hoặc không có quyền admin');
        throw Exception('Không có quyền truy cập. Vui lòng đăng nhập lại với tài khoản admin.');
      } else if (response.statusCode == 401) {
        print('❌ 401 Unauthorized - Token hết hạn');
        throw Exception('Phiên đăng nhập hết hạn. Vui lòng đăng nhập lại.');
      } else {
        print('❌ Error ${response.statusCode}: ${response.body}');
        throw Exception('Lỗi tải dữ liệu (${response.statusCode})');
      }
    } catch (e) {
      print('❌ Exception: $e');
      rethrow;
    }
  }
}
