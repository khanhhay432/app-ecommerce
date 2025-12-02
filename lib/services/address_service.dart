import '../config/api_config.dart';
import '../models/address.dart';
import 'api_service.dart';

class AddressService {
  // Lấy tất cả địa chỉ của user
  static Future<List<Address>> getMyAddresses() async {
    try {
      print('📍 [AddressService] Fetching addresses...');
      
      final response = await ApiService.get(ApiConfig.addresses, auth: true);
      
      if (response['success'] == true && response['data'] != null) {
        final List<dynamic> data = response['data'];
        print('✅ [AddressService] Addresses count: ${data.length}');
        return data.map((json) => Address.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('❌ [AddressService] Error fetching addresses: $e');
      return [];
    }
  }

  // Tạo địa chỉ mới
  static Future<Address?> createAddress({
    required String fullName,
    required String phone,
    required String address,
    required String city,
    required String district,
    required String ward,
    bool isDefault = false,
  }) async {
    try {
      print('📍 [AddressService] Creating address...');
      
      final response = await ApiService.post(
        ApiConfig.addresses,
        {
          'fullName': fullName,
          'phone': phone,
          'streetAddress': address,
          'province': city,
          'district': district,
          'ward': ward,
          'isDefault': isDefault,
        },
        auth: true,
      );
      
      if (response['success'] == true && response['data'] != null) {
        print('✅ [AddressService] Address created');
        return Address.fromJson(response['data']);
      }
      return null;
    } catch (e) {
      print('❌ [AddressService] Error creating address: $e');
      rethrow;
    }
  }

  // Cập nhật địa chỉ
  static Future<Address?> updateAddress({
    required int id,
    required String fullName,
    required String phone,
    required String address,
    required String city,
    required String district,
    required String ward,
    bool isDefault = false,
  }) async {
    try {
      print('📍 [AddressService] Updating address: $id');
      
      final response = await ApiService.put(
        '${ApiConfig.addresses}/$id',
        {
          'fullName': fullName,
          'phone': phone,
          'streetAddress': address,
          'province': city,
          'district': district,
          'ward': ward,
          'isDefault': isDefault,
        },
        auth: true,
      );
      
      if (response['success'] == true && response['data'] != null) {
        print('✅ [AddressService] Address updated');
        return Address.fromJson(response['data']);
      }
      return null;
    } catch (e) {
      print('❌ [AddressService] Error updating address: $e');
      rethrow;
    }
  }

  // Xóa địa chỉ
  static Future<bool> deleteAddress(int id) async {
    try {
      print('📍 [AddressService] Deleting address: $id');
      
      final response = await ApiService.delete(
        '${ApiConfig.addresses}/$id',
        auth: true,
      );
      
      print('✅ [AddressService] Address deleted');
      return response['success'] == true;
    } catch (e) {
      print('❌ [AddressService] Error deleting address: $e');
      return false;
    }
  }

  // Set địa chỉ mặc định
  static Future<Address?> setDefaultAddress(int id) async {
    try {
      print('📍 [AddressService] Setting default address: $id');
      
      final response = await ApiService.put(
        '${ApiConfig.addresses}/$id/default',
        {},
        auth: true,
      );
      
      if (response['success'] == true && response['data'] != null) {
        print('✅ [AddressService] Default address set');
        return Address.fromJson(response['data']);
      }
      return null;
    } catch (e) {
      print('❌ [AddressService] Error setting default address: $e');
      rethrow;
    }
  }
}
