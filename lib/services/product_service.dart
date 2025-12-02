import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/product.dart';
import 'api_service.dart';

class ProductService {
  static Future<List<Product>> getFeaturedProducts() async {
    try {
      print('🔍 [ProductService] Fetching featured products...');
      print('📍 [ProductService] URL: ${ApiConfig.baseUrl}${ApiConfig.featuredProducts}');
      
      final response = await ApiService.get(ApiConfig.featuredProducts);
      
      print('✅ [ProductService] Response received');
      print('📊 [ProductService] Success: ${response['success']}');
      print('📦 [ProductService] Data type: ${response['data'].runtimeType}');
      
      if (response['success'] == true && response['data'] != null) {
        final List<dynamic> data = response['data'];
        print('✨ [ProductService] Featured products count: ${data.length}');
        if (data.isEmpty) {
          print('⚠️ [ProductService] WARNING: No featured products found in database!');
        }
        return data.map((json) => Product.fromJson(json)).toList();
      }
      print('⚠️ [ProductService] Response success is false or data is null');
      return [];
    } catch (e) {
      print('❌ [ProductService] Error fetching featured products: $e');
      return [];
    }
  }

  static Future<List<Product>> getTopSellingProducts({int limit = 10}) async {
    try {
      final response = await ApiService.get('${ApiConfig.topSellingProducts}?limit=$limit');
      if (response['success'] == true && response['data'] != null) {
        final List<dynamic> data = response['data'];
        return data.map((json) => Product.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching top selling products: $e');
      return [];
    }
  }

  static Future<List<Product>> getNewArrivals({int limit = 10}) async {
    try {
      final response = await ApiService.get('${ApiConfig.newArrivals}?limit=$limit');
      if (response['success'] == true && response['data'] != null) {
        final List<dynamic> data = response['data'];
        return data.map((json) => Product.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching new arrivals: $e');
      return [];
    }
  }

  static Future<List<Product>> getOnSaleProducts({int limit = 10}) async {
    try {
      final response = await ApiService.get('${ApiConfig.onSaleProducts}?limit=$limit');
      if (response['success'] == true && response['data'] != null) {
        final List<dynamic> data = response['data'];
        return data.map((json) => Product.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching on sale products: $e');
      return [];
    }
  }


  static Future<Map<String, dynamic>> getAllProducts({
    int page = 0,
    int size = 20,
    String sortBy = 'id',
    String sortDir = 'desc',
  }) async {
    try {
      final response = await ApiService.get(
        '${ApiConfig.products}?page=$page&size=$size&sortBy=$sortBy&sortDir=$sortDir'
      );
      if (response['success'] == true && response['data'] != null) {
        final data = response['data'];
        final List<dynamic> content = data['content'] ?? [];
        return {
          'products': content.map((json) => Product.fromJson(json)).toList(),
          'totalPages': data['totalPages'] ?? 0,
          'totalElements': data['totalElements'] ?? 0,
          'currentPage': data['page'] ?? 0,
          'isLast': data['last'] ?? true,
        };
      }
      return {'products': [], 'totalPages': 0, 'totalElements': 0, 'currentPage': 0, 'isLast': true};
    } catch (e) {
      print('Error fetching all products: $e');
      return {'products': [], 'totalPages': 0, 'totalElements': 0, 'currentPage': 0, 'isLast': true};
    }
  }

  static Future<Map<String, dynamic>> getProductsByCategory(int categoryId, {int page = 0, int size = 20}) async {
    try {
      final response = await ApiService.get(
        '${ApiConfig.products}/category/$categoryId?page=$page&size=$size'
      );
      if (response['success'] == true && response['data'] != null) {
        final data = response['data'];
        final List<dynamic> content = data['content'] ?? [];
        return {
          'products': content.map((json) => Product.fromJson(json)).toList(),
          'totalPages': data['totalPages'] ?? 0,
          'totalElements': data['totalElements'] ?? 0,
          'currentPage': data['page'] ?? 0,
          'isLast': data['last'] ?? true,
        };
      }
      return {'products': [], 'totalPages': 0, 'totalElements': 0, 'currentPage': 0, 'isLast': true};
    } catch (e) {
      print('Error fetching products by category: $e');
      return {'products': [], 'totalPages': 0, 'totalElements': 0, 'currentPage': 0, 'isLast': true};
    }
  }

  static Future<Product?> getProductById(int id) async {
    try {
      final response = await ApiService.get('${ApiConfig.products}/$id');
      if (response['success'] == true && response['data'] != null) {
        return Product.fromJson(response['data']);
      }
      return null;
    } catch (e) {
      print('Error fetching product by id: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>> searchProducts(String keyword, {int page = 0, int size = 20}) async {
    try {
      final response = await ApiService.get(
        '${ApiConfig.searchProducts}?keyword=$keyword&page=$page&size=$size'
      );
      if (response['success'] == true && response['data'] != null) {
        final data = response['data'];
        final List<dynamic> content = data['content'] ?? [];
        return {
          'products': content.map((json) => Product.fromJson(json)).toList(),
          'totalPages': data['totalPages'] ?? 0,
          'totalElements': data['totalElements'] ?? 0,
          'currentPage': data['page'] ?? 0,
          'isLast': data['last'] ?? true,
        };
      }
      return {'products': [], 'totalPages': 0, 'totalElements': 0, 'currentPage': 0, 'isLast': true};
    } catch (e) {
      print('Error searching products: $e');
      return {'products': [], 'totalPages': 0, 'totalElements': 0, 'currentPage': 0, 'isLast': true};
    }
  }
}
