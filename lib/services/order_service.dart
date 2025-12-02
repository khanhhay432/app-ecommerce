import '../config/api_config.dart';
import '../models/order.dart';
import 'api_service.dart';

class OrderService {
  // Tạo đơn hàng mới
  static Future<Map<String, dynamic>> createOrder({
    required List<Map<String, dynamic>> items,
    required String shippingName,
    required String shippingPhone,
    required String shippingAddress,
    required String paymentMethod,
    String? couponCode,
    double discount = 0,
    double shippingFee = 0,
    double total = 0,
  }) async {
    try {
      print('📦 [OrderService] Creating order...');
      print('💰 Total to send: $total');
      
      final response = await ApiService.post(
        ApiConfig.orders,
        {
          'items': items,
          'shippingName': shippingName,
          'shippingPhone': shippingPhone,
          'shippingAddress': shippingAddress,
          'paymentMethod': paymentMethod,
          'couponCode': couponCode,
          'discount': discount,
          'shippingFee': shippingFee,
          'total': total,
        },
        auth: true,
      );
      
      print('✅ [OrderService] Order created successfully');
      return response;
    } catch (e) {
      print('❌ [OrderService] Error creating order: $e');
      rethrow;
    }
  }

  // Lấy danh sách đơn hàng của user
  static Future<List<Order>> getMyOrders({int page = 0, int size = 20}) async {
    try {
      print('📦 [OrderService] Fetching my orders...');
      
      final response = await ApiService.get(
        '${ApiConfig.orders}?page=$page&size=$size',
        auth: true,
      );
      
      print('📊 [OrderService] Response: $response');
      
      if (response['success'] == true && response['data'] != null) {
        final data = response['data'];
        
        // Backend trả về Page object với content array
        if (data is Map && data['content'] != null) {
          final List<dynamic> content = data['content'];
          print('✅ [OrderService] Orders count: ${content.length}');
          return content.map((json) => Order.fromJson(json)).toList();
        }
        // Hoặc trả về trực tiếp array
        else if (data is List) {
          print('✅ [OrderService] Orders count: ${data.length}');
          return data.map((json) => Order.fromJson(json)).toList();
        }
      }
      print('⚠️ [OrderService] No orders found or invalid response');
      return [];
    } catch (e) {
      print('❌ [OrderService] Error fetching orders: $e');
      print('Stack trace: ${StackTrace.current}');
      return [];
    }
  }

  // Hủy đơn hàng
  static Future<bool> cancelOrder(String orderId) async {
    try {
      print('📦 [OrderService] Cancelling order: $orderId');
      
      final response = await ApiService.post(
        '${ApiConfig.orders}/$orderId/cancel',
        {},
        auth: true,
      );
      
      print('✅ [OrderService] Order cancelled');
      return response['success'] == true;
    } catch (e) {
      print('❌ [OrderService] Error cancelling order: $e');
      return false;
    }
  }
  
  // Cập nhật trạng thái đơn hàng (Admin)
  static Future<Order?> updateOrderStatus(String orderId, String status) async {
    try {
      print('📦 [OrderService] Updating order status: $orderId -> $status');
      
      final response = await ApiService.put(
        '${ApiConfig.orders}/$orderId/status?status=$status',
        {},
        auth: true,
      );
      
      if (response['success'] == true && response['data'] != null) {
        print('✅ [OrderService] Order status updated');
        return Order.fromJson(response['data']);
      }
      return null;
    } catch (e) {
      print('❌ [OrderService] Error updating order status: $e');
      return null;
    }
  }
}
