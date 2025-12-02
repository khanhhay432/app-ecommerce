import 'package:flutter/material.dart';
import '../models/product.dart';
import '../models/category.dart';
import '../models/cart_item.dart';
import '../models/order.dart';
import '../models/user.dart';
import '../services/product_service.dart';
import '../services/category_service.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';
import '../services/admin_product_service.dart';
import '../services/order_service.dart';
import '../services/cart_service.dart';

class AppProvider with ChangeNotifier {
  // User state
  User? _currentUser;
  bool _isLoggedIn = false;
  bool _isLoading = false;
  String? _error;

  // Products & Categories from API
  List<Product> _products = [];
  List<Product> _featuredProducts = [];
  List<Product> _topSellingProducts = [];
  List<Product> _newArrivals = [];
  List<Product> _onSaleProducts = [];
  List<Category> _categories = [];
  List<Product> _wishlist = [];

  // Cart (local management)
  List<CartItem> _cartItems = [];

  // Orders
  List<Order> _orders = [];

  // Getters
  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;
  String? get error => _error;
  User? get currentUser => _currentUser;
  String get userName => _currentUser?.fullName ?? '';
  String get userEmail => _currentUser?.email ?? '';
  String? get userAvatar => _currentUser?.avatarUrl;
  bool get isAdmin => _currentUser?.isAdmin ?? false;
  bool get isCustomer => _currentUser?.isCustomer ?? true;
  UserRole get userRole => _currentUser?.role ?? UserRole.customer;

  List<Product> get products => _products;
  List<Product> get featuredProducts => _featuredProducts;
  List<Product> get topSellingProducts => _topSellingProducts;
  List<Product> get newArrivals => _newArrivals;
  List<Product> get onSaleProducts => _onSaleProducts;
  List<Category> get categories => _categories;
  List<Product> get wishlist => _wishlist;
  List<CartItem> get cartItems => _cartItems;
  List<Order> get orders => _orders;
  int get cartItemCount => _cartItems.fold(0, (sum, item) => sum + item.quantity);
  double get cartTotal => _cartItems.fold(0, (sum, item) => sum + item.subtotal);

  AppProvider() {
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    await _checkLoginStatus();
    await loadData();
  }

  Future<void> _checkLoginStatus() async {
    final token = await ApiService.getToken();
    if (token != null && token.isNotEmpty) {
      _isLoggedIn = true;
      notifyListeners();
    }
  }


  Future<void> loadData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        CategoryService.getAllCategories(),
        ProductService.getFeaturedProducts(),
        ProductService.getTopSellingProducts(limit: 10),
        ProductService.getNewArrivals(limit: 10),
        ProductService.getOnSaleProducts(limit: 10),
      ]);

      _categories = results[0] as List<Category>;
      _featuredProducts = results[1] as List<Product>;
      _topSellingProducts = results[2] as List<Product>;
      _newArrivals = results[3] as List<Product>;
      _onSaleProducts = results[4] as List<Product>;

      // Combine all products
      _products = [
        ..._featuredProducts,
        ..._topSellingProducts,
        ..._newArrivals,
        ..._onSaleProducts
      ];
      _products = _products.toSet().toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshData() async {
    await loadData();
  }

  // Auth methods
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await AuthService.login(email, password);

      if (result['success'] == true) {
        _currentUser = result['user'];
        _isLoggedIn = true;
        _isLoading = false;
        notifyListeners();
        
        // Đồng bộ cart sau khi đăng nhập
        await syncCartToBackend();
        await loadCart();
        
        return true;
      } else {
        _error = result['message'];
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(String name, String email, String password, {String? phone}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await AuthService.register(
        email: email,
        password: password,
        fullName: name,
        phone: phone,
      );

      if (result['success'] == true) {
        _currentUser = result['user'];
        _isLoggedIn = true;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = result['message'];
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await AuthService.logout();
    _isLoggedIn = false;
    _currentUser = null;
    _cartItems.clear();
    _orders.clear();
    _wishlist.clear();
    notifyListeners();
  }

  void updateUserInfo(User user) {
    _currentUser = user;
    notifyListeners();
  }

  // Cart methods - Đồng bộ với backend
  Future<void> addToCart(Product product, {int quantity = 1}) async {
    // Cập nhật local trước
    final existingIndex = _cartItems.indexWhere((item) => item.product.id == product.id);
    if (existingIndex >= 0) {
      _cartItems[existingIndex].quantity += quantity;
    } else {
      _cartItems.add(CartItem(product: product, quantity: quantity));
    }
    notifyListeners();
    
    // Đồng bộ với backend nếu đã đăng nhập
    if (_isLoggedIn) {
      await CartService.addToCart(product.id, quantity);
    }
  }

  Future<void> updateCartQuantity(int productId, int quantity) async {
    final index = _cartItems.indexWhere((item) => item.product.id == productId);
    if (index >= 0) {
      if (quantity <= 0) {
        _cartItems.removeAt(index);
        if (_isLoggedIn) {
          await CartService.removeFromCart(productId);
        }
      } else {
        _cartItems[index].quantity = quantity;
        if (_isLoggedIn) {
          await CartService.updateCartItem(productId, quantity);
        }
      }
      notifyListeners();
    }
  }

  Future<void> removeFromCart(int productId) async {
    _cartItems.removeWhere((item) => item.product.id == productId);
    notifyListeners();
    
    if (_isLoggedIn) {
      await CartService.removeFromCart(productId);
    }
  }

  Future<void> clearCart() async {
    _cartItems.clear();
    notifyListeners();
    
    if (_isLoggedIn) {
      await CartService.clearCart();
    }
  }
  
  // Load cart từ backend khi đăng nhập
  Future<void> loadCart() async {
    if (!_isLoggedIn) return;
    
    try {
      print('🛒 [AppProvider] Loading cart from backend...');
      final items = await CartService.getCart();
      _cartItems = items;
      notifyListeners();
      print('✅ [AppProvider] Cart loaded: ${items.length} items');
    } catch (e) {
      print('❌ [AppProvider] Error loading cart: $e');
    }
  }
  
  // Đồng bộ cart local lên backend sau khi đăng nhập
  Future<void> syncCartToBackend() async {
    if (!_isLoggedIn || _cartItems.isEmpty) return;
    
    try {
      print('🛒 [AppProvider] Syncing cart to backend...');
      for (var item in _cartItems) {
        await CartService.addToCart(item.product.id, item.quantity);
      }
      print('✅ [AppProvider] Cart synced to backend');
    } catch (e) {
      print('❌ [AppProvider] Error syncing cart: $e');
    }
  }

  // Wishlist methods
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

  // Order methods
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

  // Search & Filter methods
  Future<List<Product>> searchProducts(String query) async {
    if (query.isEmpty) return _products;
    final result = await ProductService.searchProducts(query);
    return result['products'] as List<Product>;
  }

  Future<List<Product>> getProductsByCategory(int categoryId) async {
    final result = await ProductService.getProductsByCategory(categoryId);
    return result['products'] as List<Product>;
  }

  Future<Product?> getProductById(int id) async {
    try {
      return _products.firstWhere((p) => p.id == id);
    } catch (_) {
      return await ProductService.getProductById(id);
    }
  }

  // Admin methods - Gọi API thực sự lưu vào MySQL
  Future<bool> addProduct(Product product) async {
    try {
      print('🔨 [AppProvider] Adding product to MySQL backend: ${product.name}');
      
      // Gọi API để lưu vào MySQL
      final createdProduct = await AdminProductService.createProduct(
        name: product.name,
        description: product.description ?? '',
        price: product.price,
        originalPrice: product.originalPrice,
        stockQuantity: product.stockQuantity,
        imageUrl: product.imageUrl ?? '',
        isFeatured: product.isFeatured,
        categoryId: product.categoryId,
      );
      
      if (createdProduct != null) {
        // Thêm vào list local sau khi lưu thành công vào MySQL
        _products.insert(0, createdProduct);
        if (createdProduct.isFeatured) {
          _featuredProducts.insert(0, createdProduct);
        }
        notifyListeners();
        print('✅ [AppProvider] Product saved to MySQL: ${createdProduct.name} (ID: ${createdProduct.id})');
        return true;
      }
      return false;
    } catch (e) {
      print('❌ [AppProvider] Error adding product to MySQL: $e');
      return false;
    }
  }

  Future<bool> updateProduct(Product product) async {
    try {
      print('🔨 [AppProvider] Updating product in MySQL: ${product.name}');
      
      // Gọi API để cập nhật trong MySQL
      final updatedProduct = await AdminProductService.updateProduct(
        id: product.id,
        name: product.name,
        description: product.description ?? '',
        price: product.price,
        originalPrice: product.originalPrice,
        stockQuantity: product.stockQuantity,
        imageUrl: product.imageUrl ?? '',
        isFeatured: product.isFeatured,
        categoryId: product.categoryId,
      );
      
      if (updatedProduct != null) {
        // Cập nhật trong list local sau khi update MySQL thành công
        final index = _products.indexWhere((p) => p.id == product.id);
        if (index >= 0) {
          _products[index] = updatedProduct;
        }
        notifyListeners();
        print('✅ [AppProvider] Product updated in MySQL: ${updatedProduct.name}');
        return true;
      }
      return false;
    } catch (e) {
      print('❌ [AppProvider] Error updating product in MySQL: $e');
      return false;
    }
  }

  Future<bool> deleteProduct(int productId) async {
    try {
      print('🔨 [AppProvider] Deleting product from MySQL: $productId');
      
      // Gọi API để xóa khỏi MySQL (soft delete - set isActive = false)
      final success = await AdminProductService.deleteProduct(productId);
      
      if (success) {
        print('✅ [AppProvider] Product soft deleted in MySQL: $productId');
        
        // Xóa khỏi TẤT CẢ list local ngay lập tức
        _products.removeWhere((p) => p.id == productId);
        _featuredProducts.removeWhere((p) => p.id == productId);
        _topSellingProducts.removeWhere((p) => p.id == productId);
        _newArrivals.removeWhere((p) => p.id == productId);
        _onSaleProducts.removeWhere((p) => p.id == productId);
        
        print('🧹 [AppProvider] Product removed from all local lists: $productId');
        notifyListeners();
        
        // Refresh data từ backend để đảm bảo đồng bộ
        await refreshData();
        print('🔄 [AppProvider] Data refreshed after delete');
        
        return true;
      }
      print('❌ [AppProvider] Delete API returned false');
      return false;
    } catch (e) {
      print('❌ [AppProvider] Error deleting product from MySQL: $e');
      return false;
    }
  }

  // Order methods - Gọi API thực sự lưu vào MySQL
  Future<Order?> createOrderInBackend({
    required String shippingName,
    required String shippingPhone,
    required String shippingAddress,
    required String paymentMethod,
    double discount = 0,
    String? couponCode,
  }) async {
    try {
      print('📦 [AppProvider] Creating order in MySQL backend...');
      
      // Chuẩn bị items
      final items = _cartItems.map((item) => {
        'productId': item.product.id,
        'quantity': item.quantity,
        'price': item.product.price,
      }).toList();
      
      // Tính toán total
      final subtotal = _cartItems.fold<double>(0, (sum, item) => sum + item.subtotal);
      final shippingFee = subtotal >= 500000 ? 0.0 : 30000.0;
      final total = subtotal - discount + shippingFee;
      
      print('💰 [AppProvider] Order calculation:');
      print('   Subtotal: $subtotal');
      print('   Discount: $discount');
      print('   Shipping: $shippingFee');
      print('   Total: $total');
      
      // Gọi API để lưu vào MySQL
      final response = await OrderService.createOrder(
        items: items,
        shippingName: shippingName,
        shippingPhone: shippingPhone,
        shippingAddress: shippingAddress,
        paymentMethod: paymentMethod,
        couponCode: couponCode,
        discount: discount,
        shippingFee: shippingFee,
        total: total,
      );
      
      if (response['success'] == true && response['data'] != null) {
        final order = Order.fromJson(response['data']);
        
        // Nếu backend trả về total = 0, tính lại ở frontend
        if (order.total == 0) {
          print('⚠️ [AppProvider] Backend returned total = 0, recalculating...');
          final calculatedTotal = subtotal - discount + shippingFee;
          
          // Tạo order mới với total đúng
          final correctedOrder = Order(
            id: order.id,
            items: order.items,
            subtotal: subtotal,
            discount: discount,
            shippingFee: shippingFee,
            total: calculatedTotal,
            shippingName: order.shippingName,
            shippingPhone: order.shippingPhone,
            shippingAddress: order.shippingAddress,
            paymentMethod: order.paymentMethod,
            status: order.status,
            createdAt: order.createdAt,
            couponCode: order.couponCode,
          );
          
          _orders.insert(0, correctedOrder);
          _cartItems.clear();
          notifyListeners();
          print('✅ [AppProvider] Order corrected with total: $calculatedTotal');
          return correctedOrder;
        }
        
        _orders.insert(0, order);
        _cartItems.clear();
        notifyListeners();
        print('✅ [AppProvider] Order saved to MySQL: ${order.id}, total: ${order.total}');
        return order;
      }
      return null;
    } catch (e) {
      print('❌ [AppProvider] Error creating order in MySQL: $e');
      return null;
    }
  }

  // Load orders từ MySQL backend
  Future<void> loadOrders() async {
    if (!_isLoggedIn) return;
    
    try {
      print('📦 [AppProvider] Loading orders from MySQL...');
      
      final orders = await OrderService.getMyOrders();
      
      // Fix orders với total = 0
      final fixedOrders = orders.map((order) {
        if (order.total == 0 && order.items.isNotEmpty) {
          // Tính lại total từ items
          final calculatedSubtotal = order.items.fold<double>(
            0, 
            (sum, item) => sum + (item.product.price * item.quantity)
          );
          final calculatedShippingFee = calculatedSubtotal >= 500000 ? 0.0 : 30000.0;
          final calculatedTotal = calculatedSubtotal - order.discount + calculatedShippingFee;
          
          print('🔧 [AppProvider] Fixed order ${order.id}: total $calculatedTotal');
          
          return Order(
            id: order.id,
            items: order.items,
            subtotal: calculatedSubtotal,
            discount: order.discount,
            shippingFee: calculatedShippingFee,
            total: calculatedTotal,
            shippingName: order.shippingName,
            shippingPhone: order.shippingPhone,
            shippingAddress: order.shippingAddress,
            paymentMethod: order.paymentMethod,
            status: order.status,
            createdAt: order.createdAt,
            couponCode: order.couponCode,
          );
        }
        return order;
      }).toList();
      
      _orders = fixedOrders;
      notifyListeners();
      print('✅ [AppProvider] Orders loaded from MySQL: ${orders.length}');
    } catch (e) {
      print('❌ [AppProvider] Error loading orders from MySQL: $e');
    }
  }
}
