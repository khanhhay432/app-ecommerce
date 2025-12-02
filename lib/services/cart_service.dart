import '../config/api_config.dart';
import '../models/cart_item.dart';
import 'api_service.dart';

class CartService {
  // Lấy giỏ hàng từ backend
  static Future<List<CartItem>> getCart() async {
    try {
      print('🛒 [CartService] Fetching cart...');
      
      final response = await ApiService.get(
        ApiConfig.cart,
        auth: true,
      );
      
      if (response['success'] == true && response['data'] != null) {
        final data = response['data'];
        if (data['items'] != null) {
          final List<dynamic> items = data['items'];
          print('✅ [CartService] Cart items count: ${items.length}');
          return items.map((json) => CartItem.fromJson(json)).toList();
        }
      }
      return [];
    } catch (e) {
      print('❌ [CartService] Error fetching cart: $e');
      return [];
    }
  }

  // Thêm sản phẩm vào giỏ hàng
  static Future<bool> addToCart(int productId, int quantity) async {
    try {
      print('🛒 [CartService] Adding to cart: Product $productId x$quantity');
      
      final response = await ApiService.post(
        '${ApiConfig.cart}/add?productId=$productId&quantity=$quantity',
        {},
        auth: true,
      );
      
      print('✅ [CartService] Added to cart');
      return response['success'] == true;
    } catch (e) {
      print('❌ [CartService] Error adding to cart: $e');
      return false;
    }
  }

  // Cập nhật số lượng sản phẩm trong giỏ
  static Future<bool> updateCartItem(int productId, int quantity) async {
    try {
      print('🛒 [CartService] Updating cart: Product $productId -> $quantity');
      
      final response = await ApiService.put(
        '${ApiConfig.cart}/update?productId=$productId&quantity=$quantity',
        {},
        auth: true,
      );
      
      print('✅ [CartService] Cart updated');
      return response['success'] == true;
    } catch (e) {
      print('❌ [CartService] Error updating cart: $e');
      return false;
    }
  }

  // Xóa sản phẩm khỏi giỏ hàng
  static Future<bool> removeFromCart(int productId) async {
    try {
      print('🛒 [CartService] Removing from cart: Product $productId');
      
      final response = await ApiService.delete(
        '${ApiConfig.cart}/remove/$productId',
        auth: true,
      );
      
      print('✅ [CartService] Removed from cart');
      return response['success'] == true;
    } catch (e) {
      print('❌ [CartService] Error removing from cart: $e');
      return false;
    }
  }

  // Xóa toàn bộ giỏ hàng
  static Future<bool> clearCart() async {
    try {
      print('🛒 [CartService] Clearing cart...');
      
      final response = await ApiService.delete(
        '${ApiConfig.cart}/clear',
        auth: true,
      );
      
      print('✅ [CartService] Cart cleared');
      return response['success'] == true;
    } catch (e) {
      print('❌ [CartService] Error clearing cart: $e');
      return false;
    }
  }
}
