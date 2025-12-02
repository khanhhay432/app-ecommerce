import '../config/api_config.dart';
import '../models/product.dart';
import 'api_service.dart';

class AdminProductService {
  // Tạo sản phẩm mới (Admin only)
  static Future<Product?> createProduct({
    required String name,
    required String description,
    required double price,
    double? originalPrice,
    required int stockQuantity,
    required String imageUrl,
    required bool isFeatured,
    required int categoryId,
  }) async {
    try {
      print('🔨 [AdminProductService] Creating product: $name');
      
      final response = await ApiService.post(
        ApiConfig.products,
        {
          'name': name,
          'description': description,
          'price': price,
          'originalPrice': originalPrice,
          'stockQuantity': stockQuantity,
          'imageUrl': imageUrl,
          'isFeatured': isFeatured,
          'categoryId': categoryId,
        },
        auth: true,
      );
      
      if (response['success'] == true && response['data'] != null) {
        print('✅ [AdminProductService] Product created successfully');
        return Product.fromJson(response['data']);
      }
      return null;
    } catch (e) {
      print('❌ [AdminProductService] Error creating product: $e');
      rethrow;
    }
  }

  // Cập nhật sản phẩm (Admin only)
  static Future<Product?> updateProduct({
    required int id,
    required String name,
    required String description,
    required double price,
    double? originalPrice,
    required int stockQuantity,
    required String imageUrl,
    required bool isFeatured,
    required int categoryId,
  }) async {
    try {
      print('🔨 [AdminProductService] Updating product: $id');
      
      final response = await ApiService.put(
        '${ApiConfig.products}/$id',
        {
          'name': name,
          'description': description,
          'price': price,
          'originalPrice': originalPrice,
          'stockQuantity': stockQuantity,
          'imageUrl': imageUrl,
          'isFeatured': isFeatured,
          'categoryId': categoryId,
        },
        auth: true,
      );
      
      if (response['success'] == true && response['data'] != null) {
        print('✅ [AdminProductService] Product updated successfully');
        return Product.fromJson(response['data']);
      }
      return null;
    } catch (e) {
      print('❌ [AdminProductService] Error updating product: $e');
      rethrow;
    }
  }

  // Xóa sản phẩm (Admin only)
  static Future<bool> deleteProduct(int id) async {
    try {
      print('🔨 [AdminProductService] Deleting product: $id');
      
      final response = await ApiService.delete(
        '${ApiConfig.products}/$id',
        auth: true,
      );
      
      print('✅ [AdminProductService] Product deleted successfully');
      return response['success'] == true;
    } catch (e) {
      print('❌ [AdminProductService] Error deleting product: $e');
      return false;
    }
  }
}
