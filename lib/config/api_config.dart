class ApiConfig {
  // Thay đổi IP này thành IP máy chạy backend
  // Dùng 10.0.2.2 cho Android Emulator, localhost cho web/desktop
  // IP máy: 192.168.1.88 (dùng cho cả emulator và thiết bị thật)
  static const String baseUrl = 'http://192.168.1.88:8080/api';
  static const String webBaseUrl = 'http://localhost:8080/api';
  
  // Endpoints - Auth
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  
  // Endpoints - Products
  static const String products = '/products';
  static const String featuredProducts = '/products/featured';
  static const String topSellingProducts = '/products/top-selling';
  static const String newArrivals = '/products/new-arrivals';
  static const String onSaleProducts = '/products/on-sale';
  static const String searchProducts = '/products/search';
  
  // Endpoints - Categories
  static const String categories = '/categories';
  static const String rootCategories = '/categories/root';
  
  // Endpoints - Cart
  static const String cart = '/cart';
  static const String cartItems = '/cart/items';
  
  // Endpoints - Orders
  static const String orders = '/orders';
  
  // Endpoints - Reviews
  static const String reviews = '/reviews';
  
  // Endpoints - Wishlist
  static const String wishlist = '/wishlist';
  
  // Endpoints - Coupons
  static const String coupons = '/coupons';
  static const String validateCoupon = '/coupons/validate';
  
  // Endpoints - Address
  static const String addresses = '/addresses';
  
  // Endpoints - User
  static const String profile = '/users/profile';
}
