import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../models/product.dart';
import '../theme/app_theme.dart';
import '../services/review_service.dart';

class ReviewScreen extends StatefulWidget {
  final Product product;
  const ReviewScreen({super.key, required this.product});
  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  double _rating = 5;
  final _commentController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitReview() async {
    if (_commentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập nhận xét'), backgroundColor: Colors.orange),
      );
      return;
    }
    
    setState(() => _isLoading = true);
    
    try {
      final review = await ReviewService.createReview(
        productId: widget.product.id,
        rating: _rating.toInt(),
        comment: _commentController.text,
      );
      
      if (mounted) {
        if (review != null) {
          Navigator.pop(context, true); // Trả về true để reload reviews
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Cảm ơn bạn đã đánh giá!'),
              backgroundColor: AppTheme.successColor,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('❌ Lỗi khi gửi đánh giá'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = '❌ Lỗi khi gửi đánh giá';
        
        // Parse error message
        final errorStr = e.toString();
        if (errorStr.contains('already reviewed')) {
          errorMessage = '⚠️ Bạn đã đánh giá sản phẩm này rồi';
        } else if (errorStr.contains('Unauthorized') || errorStr.contains('401')) {
          errorMessage = '🔒 Vui lòng đăng nhập để đánh giá';
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: errorStr.contains('already reviewed') ? Colors.orange : Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Đánh giá sản phẩm')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(widget.product.imageUrl ?? '', width: 80, height: 80, fit: BoxFit.cover),
                    ),
                    const SizedBox(width: 16),
                    Expanded(child: Text(widget.product.name, style: const TextStyle(fontWeight: FontWeight.bold))),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Center(child: Text('Bạn đánh giá sản phẩm này như thế nào?', style: TextStyle(fontSize: 16))),
            const SizedBox(height: 16),
            Center(
              child: RatingBar.builder(
                initialRating: _rating,
                minRating: 1,
                direction: Axis.horizontal,
                allowHalfRating: false,
                itemCount: 5,
                itemSize: 48,
                itemPadding: const EdgeInsets.symmetric(horizontal: 4),
                itemBuilder: (_, __) => const Icon(Icons.star, color: Colors.amber),
                onRatingUpdate: (rating) => setState(() => _rating = rating),
              ),
            ),
            const SizedBox(height: 8),
            Center(child: Text(_getRatingText(), style: TextStyle(color: AppTheme.getSecondaryTextColor(context)))),
            const SizedBox(height: 24),
            const Text('Nhận xét của bạn', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _commentController,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: 'Chia sẻ trải nghiệm của bạn về sản phẩm...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.camera_alt_outlined),
                  label: const Text('Thêm ảnh'),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.videocam_outlined),
                  label: const Text('Thêm video'),
                ),
              ],
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitReview,
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                child: _isLoading
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Gửi đánh giá', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getRatingText() {
    switch (_rating.toInt()) {
      case 1: return 'Rất tệ 😞';
      case 2: return 'Tệ 😕';
      case 3: return 'Bình thường 😐';
      case 4: return 'Tốt 😊';
      case 5: return 'Tuyệt vời 🤩';
      default: return '';
    }
  }
}
