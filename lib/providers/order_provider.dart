import 'package:flutter/material.dart';
import '../models/order.dart';
import '../services/api_service.dart';
import '../config/api_config.dart';

class OrderProvider with ChangeNotifier {
  List<Order> _orders = [];
  bool _isLoading = false;

  List<Order> get orders => _orders;
  bool get isLoading => _isLoading;

  Future<void> loadOrders() async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await ApiService.get(ApiConfig.orders, auth: true);
      final content = response['data']['content'] as List;
      _orders = content.map((e) => Order.fromJson(e)).toList();
    } catch (e) {
      debugPrint('Error loading orders: $e');
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<Order?> createOrder({
    required String shippingName,
    required String shippingPhone,
    required String shippingAddress,
    required String paymentMethod,
    String? couponCode,
    String? note,
  }) async {
    try {
      final response = await ApiService.post(ApiConfig.orders, {
        'shippingName': shippingName,
        'shippingPhone': shippingPhone,
        'shippingAddress': shippingAddress,
        'paymentMethod': paymentMethod,
        'couponCode': couponCode,
        'note': note,
      }, auth: true);
      final order = Order.fromJson(response['data']);
      _orders.insert(0, order);
      notifyListeners();
      return order;
    } catch (e) {
      debugPrint('Error creating order: $e');
      return null;
    }
  }

  Future<bool> cancelOrder(int orderId) async {
    try {
      await ApiService.post('${ApiConfig.orders}/$orderId/cancel', {}, auth: true);
      await loadOrders();
      return true;
    } catch (e) {
      return false;
    }
  }
}
