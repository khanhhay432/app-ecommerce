class ApiConfig {
  // Thay đổi IP này thành IP máy chạy backend
  // Dùng 10.0.2.2 cho Android Emulator, localhost cho web
  static const String baseUrl = 'http://10.0.2.2:8081/api';
  
  // Endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String products = '/products';
  static const String categories = '/categories';
  static const String cart = '/cart';
  static const String orders = '/orders';
  static const String reviews = '/reviews';
  static const String coupons = '/coupons';
}
