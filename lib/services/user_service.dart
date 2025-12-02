import '../config/api_config.dart';
import '../models/user.dart';
import 'api_service.dart';

class UserService {
  // Lấy thông tin profile
  static Future<User?> getProfile() async {
    try {
      print('👤 [UserService] Fetching profile...');
      
      final response = await ApiService.get(ApiConfig.profile, auth: true);
      
      if (response['success'] == true && response['data'] != null) {
        print('✅ [UserService] Profile loaded');
        return User.fromJson(response['data']);
      }
      return null;
    } catch (e) {
      print('❌ [UserService] Error fetching profile: $e');
      return null;
    }
  }

  // Cập nhật profile
  static Future<User?> updateProfile({
    required String fullName,
    String? phone,
    String? avatarUrl,
  }) async {
    try {
      print('👤 [UserService] Updating profile...');
      
      final response = await ApiService.put(
        ApiConfig.profile,
        {
          'fullName': fullName,
          if (phone != null) 'phone': phone,
          if (avatarUrl != null) 'avatarUrl': avatarUrl,
        },
        auth: true,
      );
      
      if (response['success'] == true && response['data'] != null) {
        print('✅ [UserService] Profile updated');
        return User.fromJson(response['data']);
      }
      return null;
    } catch (e) {
      print('❌ [UserService] Error updating profile: $e');
      rethrow;
    }
  }

  // Đổi mật khẩu
  static Future<bool> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      print('👤 [UserService] Changing password...');
      
      final response = await ApiService.post(
        '/users/change-password',
        {
          'oldPassword': oldPassword,
          'newPassword': newPassword,
        },
        auth: true,
      );
      
      print('✅ [UserService] Password changed');
      return response['success'] == true;
    } catch (e) {
      print('❌ [UserService] Error changing password: $e');
      rethrow;
    }
  }
}
