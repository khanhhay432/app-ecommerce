import '../config/api_config.dart';
import 'api_service.dart';

class ReviewService {
  // Lấy reviews của sản phẩm
  static Future<List<Map<String, dynamic>>> getProductReviews(int productId, {int page = 0, int size = 20}) async {
    try {
      print('⭐ [ReviewService] Fetching reviews for product: $productId');
      
      final response = await ApiService.get(
        '${ApiConfig.reviews}/product/$productId?page=$page&size=$size',
      );
      
      if (response['success'] == true && response['data'] != null) {
        final data = response['data'];
        
        // Backend trả về Page object với content array
        if (data is Map && data['content'] != null) {
          final List<dynamic> content = data['content'];
          print('✅ [ReviewService] Reviews count: ${content.length}');
          return content.cast<Map<String, dynamic>>();
        }
        // Hoặc trả về trực tiếp array
        else if (data is List) {
          print('✅ [ReviewService] Reviews count: ${data.length}');
          return data.cast<Map<String, dynamic>>();
        }
      }
      print('⚠️ [ReviewService] No reviews found or invalid response');
      return [];
    } catch (e) {
      print('❌ [ReviewService] Error fetching reviews: $e');
      return [];
    }
  }

  // Tạo review mới
  static Future<Map<String, dynamic>?> createReview({
    required int productId,
    required int rating,
    required String comment,
  }) async {
    try {
      print('⭐ [ReviewService] Creating review for product: $productId');
      
      final response = await ApiService.post(
        ApiConfig.reviews,
        {
          'productId': productId,
          'rating': rating,
          'comment': comment,
        },
        auth: true,
      );
      
      if (response['success'] == true && response['data'] != null) {
        print('✅ [ReviewService] Review created');
        return response['data'];
      }
      return null;
    } catch (e) {
      print('❌ [ReviewService] Error creating review: $e');
      rethrow;
    }
  }

  // Lấy reviews của user
  static Future<List<Map<String, dynamic>>> getMyReviews() async {
    try {
      print('⭐ [ReviewService] Fetching my reviews...');
      
      final response = await ApiService.get(
        '${ApiConfig.reviews}/my',
        auth: true,
      );
      
      if (response['success'] == true && response['data'] != null) {
        final List<dynamic> data = response['data'];
        print('✅ [ReviewService] My reviews count: ${data.length}');
        return data.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      print('❌ [ReviewService] Error fetching my reviews: $e');
      return [];
    }
  }
}
