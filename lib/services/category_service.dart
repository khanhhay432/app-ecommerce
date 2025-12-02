import '../config/api_config.dart';
import '../models/category.dart';
import 'api_service.dart';

class CategoryService {
  static Future<List<Category>> getAllCategories() async {
    try {
      print('🔍 [CategoryService] Fetching all categories...');
      print('📍 [CategoryService] URL: ${ApiConfig.baseUrl}${ApiConfig.categories}');
      
      final response = await ApiService.get(ApiConfig.categories);
      
      print('✅ [CategoryService] Response received');
      print('📊 [CategoryService] Success: ${response['success']}');
      
      if (response['success'] == true && response['data'] != null) {
        final List<dynamic> data = response['data'];
        print('✨ [CategoryService] Categories count: ${data.length}');
        if (data.isEmpty) {
          print('⚠️ [CategoryService] WARNING: No categories found in database!');
        }
        return data.map((json) => Category.fromJson(json)).toList();
      }
      print('⚠️ [CategoryService] Response success is false or data is null');
      return [];
    } catch (e) {
      print('❌ [CategoryService] Error fetching categories: $e');
      return [];
    }
  }

  static Future<List<Category>> getRootCategories() async {
    try {
      final response = await ApiService.get(ApiConfig.rootCategories);
      if (response['success'] == true && response['data'] != null) {
        final List<dynamic> data = response['data'];
        return data.map((json) => Category.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching root categories: $e');
      return [];
    }
  }
}
