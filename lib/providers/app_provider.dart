import 'package:flutter/material.dart';
import '../models/product.dart';
import '../models/category.dart';
import '../models/cart_item.dart';
import '../models/order.dart';
import '../models/user.dart';
import '../data/mock_data.dart';

class AppProvider with ChangeNotifier {
  // User với phân quyền
  User? _currentUser;
  bool _isLoggedIn = false;

  // Products & Categories
  List<Product> _products = [];
  List<Category> _categories = [];
  List<Product> _wishlist = [];

  // Cart
  List<CartItem> _cartItems = [];

  // Orders
  List<Order> _orders = [];

  // Getters
  bool get isLoggedIn => _isLoggedIn;
  User? get currentUser => _currentUser;
  String get userName => _currentUser?.fullName ?? '';
  String get userEmail => _currentUser?.email ?? '';
  String? get userAvatar => _currentUser?.avatarUrl;
  bool get isAdmin => _currentUser?.isAdmin ?? false;
  bool get isCustomer => _currentUser?.isCustomer ?? true;
  UserRole get userRole => _currentUser?.role ?? UserRole.customer;
  
  List<Product> get products => _products;
  List<Category> get categories => _categories;
  List<Product> get wishlist => _wishlist;
  List<CartItem> get cartItems => _cartItems;
  List<Order> get orders => _orders;
  int get cartItemCount => _cartItems.fold(0, (sum, item) => sum + item.quantity);
  double get cartTotal => _cartItems.fold(0, (sum, item) => sum + item.subtotal);

  List<Product> get featuredProducts => _products.where((p) => p.isFeatured).toList();
  List<Product> get topSellingProducts {
    var sorted = List<Product>.from(_products)..sort((a, b) => b.soldQuantity.compareTo(a.soldQuantity));
    return sorted.take(10).toList();
  }

  AppProvider() {
    _loadData();
  }

  void _loadData() {
    _products = MockData.products;
    _categories = MockData.categories;
    notifyListeners();
  }

  // Auth với phân quyền
  Future<bool> login(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 800));
    
    // Kiểm tra tài khoản test
    final testAccount = MockData.testAccounts.firstWhere(
      (acc) => acc['email'] == email && acc['password'] == password,
      orElse: () => {},
    );

    if (testAccount.isNotEmpty) {
      _currentUser = User(
        id: MockData.testAccounts.indexOf(testAccount) + 1,
        email: testAccount['email'],
        fullName: testAccount['fullName'],
        phone: testAccount['phone'],
        avatarUrl: testAccount['avatarUrl'],
        role: testAccount['role'] == 'ADMIN' ? UserRole.admin : UserRole.customer,
      );
      _isLoggedIn = true;
      notifyListeners();
      return true;
    }

    // Cho phép đăng nhập với email/password bất kỳ (role customer)
    if (email.isNotEmpty && password.length >= 6) {
      _currentUser = User(
        id: DateTime.now().millisecondsSinceEpoch,
        email: email,
        fullName: email.split('@')[0],
        role: UserRole.customer,
        avatarUrl: 'https://ui-avatars.com/api/?name=${email.split('@')[0]}&background=random',
      );
      _isLoggedIn = true;
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> register(String name, String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 800));
    if (name.isNotEmpty && email.isNotEmpty && password.length >= 6) {
      _currentUser = User(
        id: DateTime.now().millisecondsSinceEpoch,
        email: email,
        fullName: name,
        role: UserRole.customer,
        avatarUrl: 'https://ui-avatars.com/api/?name=${name.replaceAll(' ', '+')}&background=random',
      );
      _isLoggedIn = true;
      notifyListeners();
      return true;
    }
    return false;
  }

  void logout() {
    _isLoggedIn = false;
    _currentUser = null;
    _cartItems.clear();
    notifyListeners();
  }

  // Admin functions
  void addProduct(Product product) {
    if (!isAdmin) return;
    _products.add(product);
    notifyListeners();
  }

  void updateProduct(Product product) {
    if (!isAdmin) return;
    final index = _products.indexWhere((p) => p.id == product.id);
    if (index >= 0) {
      _products[index] = product;
      notifyListeners();
    }
  }

  void deleteProduct(int productId) {
    if (!isAdmin) return;
    _products.removeWhere((p) => p.id == productId);
    notifyListeners();
  }

  void addCategory(Category category) {
    if (!isAdmin) return;
    _categories.add(category);
    notifyListeners();
  }

  // Cart
  void addToCart(Product product, {int quantity = 1}) {
    final existingIndex = _cartItems.indexWhere((item) => item.product.id == product.id);
    if (existingIndex >= 0) {
      _cartItems[existingIndex].quantity += quantity;
    } else {
      _cartItems.add(CartItem(product: product, quantity: quantity));
    }
    notifyListeners();
  }

  void updateCartQuantity(int productId, int quantity) {
    final index = _cartItems.indexWhere((item) => item.product.id == productId);
    if (index >= 0) {
      if (quantity <= 0) {
        _cartItems.removeAt(index);
      } else {
        _cartItems[index].quantity = quantity;
      }
      notifyListeners();
    }
  }

  void removeFromCart(int productId) {
    _cartItems.removeWhere((item) => item.product.id == productId);
    notifyListeners();
  }

  void clearCart() {
    _cartItems.clear();
    notifyListeners();
  }

  // Wishlist
  void toggleWishlist(Product product) {
    final exists = _wishlist.any((p) => p.id == product.id);
    if (exists) {
      _wishlist.removeWhere((p) => p.id == product.id);
    } else {
      _wishlist.add(product);
    }
    notifyListeners();
  }

  bool isInWishlist(int productId) => _wishlist.any((p) => p.id == productId);

  // Orders
  Order createOrder({
    required String shippingName,
    required String shippingPhone,
    required String shippingAddress,
    required String paymentMethod,
    double discount = 0,
    String? couponCode,
  }) {
    final subtotal = cartTotal;
    final shippingFee = subtotal >= 500000 ? 0.0 : 30000.0;
    final total = subtotal - discount + shippingFee;

    final order = Order(
      id: 'ORD${DateTime.now().millisecondsSinceEpoch}',
      items: List.from(_cartItems),
      subtotal: subtotal,
      discount: discount,
      shippingFee: shippingFee,
      total: total,
      shippingName: shippingName,
      shippingPhone: shippingPhone,
      shippingAddress: shippingAddress,
      paymentMethod: paymentMethod,
      status: 'PENDING',
      createdAt: DateTime.now(),
      couponCode: couponCode,
    );

    _orders.insert(0, order);
    _cartItems.clear();
    notifyListeners();
    return order;
  }

  // Search & Filter
  List<Product> searchProducts(String query) {
    if (query.isEmpty) return _products;
    return _products.where((p) => 
      p.name.toLowerCase().contains(query.toLowerCase()) ||
      (p.description?.toLowerCase().contains(query.toLowerCase()) ?? false)
    ).toList();
  }

  List<Product> getProductsByCategory(int categoryId) {
    return _products.where((p) => p.categoryId == categoryId).toList();
  }

  Product? getProductById(int id) {
    try {
      return _products.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  // Coupon
  double applyCoupon(String code) {
    final coupon = MockData.coupons.firstWhere(
      (c) => c['code'] == code.toUpperCase(),
      orElse: () => {},
    );
    if (coupon.isEmpty) return 0;
    
    final minOrder = (coupon['minOrder'] ?? 0) as num;
    if (cartTotal < minOrder) return 0;

    if (coupon.containsKey('discountPercent')) {
      final percent = coupon['discountPercent'] as int;
      var discount = cartTotal * percent / 100;
      final maxDiscount = coupon['maxDiscount'] as int?;
      if (maxDiscount != null && discount > maxDiscount) {
        discount = maxDiscount.toDouble();
      }
      return discount;
    } else if (coupon.containsKey('discountAmount')) {
      return (coupon['discountAmount'] as int).toDouble();
    }
    return 0;
  }
}
