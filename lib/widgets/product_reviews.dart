import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../theme/app_theme.dart';
import '../services/review_service.dart';

class ProductReviews extends StatefulWidget {
  final int productId;

  const ProductReviews({super.key, required this.productId});

  @override
  State<ProductReviews> createState() => _ProductReviewsState();
}

class _ProductReviewsState extends State<ProductReviews> {
  List<Map<String, dynamic>> _reviews = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    setState(() => _isLoading = true);
    final reviews = await ReviewService.getProductReviews(widget.productId);
    if (mounted) {
      setState(() {
        _reviews = reviews;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Đánh giá sản phẩm',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: _showAddReviewDialog,
              icon: const Icon(Icons.rate_review, size: 18),
              label: const Text('Viết đánh giá'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (_isLoading)
          const Center(child: CircularProgressIndicator())
        else if (_reviews.isEmpty)
          _buildEmptyState()
        else
          ..._reviews.map((review) => _buildReviewCard(review)),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF2D2D2D) : Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.rate_review_outlined, size: 48, color: AppTheme.getTertiaryTextColor(context)),
            const SizedBox(height: 12),
            Text(
              'Chưa có đánh giá nào',
              style: TextStyle(color: AppTheme.getSecondaryTextColor(context)),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _showAddReviewDialog,
              child: const Text('Viết đánh giá đầu tiên'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewCard(Map<String, dynamic> review) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                child: Text(
                  (review['userName'] ?? 'U')[0].toUpperCase(),
                  style: const TextStyle(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review['userName'] ?? 'Anonymous',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      review['createdAt'] ?? '',
                      style: TextStyle(color: AppTheme.getSecondaryTextColor(context), fontSize: 12),
                    ),
                  ],
                ),
              ),
              RatingBarIndicator(
                rating: (review['rating'] ?? 0).toDouble(),
                itemBuilder: (_, __) => const Icon(Icons.star, color: Colors.amber),
                itemCount: 5,
                itemSize: 16,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(review['comment'] ?? ''),
        ],
      ),
    );
  }

  void _showAddReviewDialog() {
    double rating = 5;
    final commentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Viết đánh giá'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Đánh giá của bạn:'),
              const SizedBox(height: 8),
              RatingBar.builder(
                initialRating: rating,
                minRating: 1,
                direction: Axis.horizontal,
                allowHalfRating: false,
                itemCount: 5,
                itemBuilder: (_, __) => const Icon(Icons.star, color: Colors.amber),
                onRatingUpdate: (value) {
                  setDialogState(() => rating = value);
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: commentController,
                decoration: const InputDecoration(
                  labelText: 'Nhận xét',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (commentController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Vui lòng nhập nhận xét')),
                  );
                  return;
                }

                try {
                  await ReviewService.createReview(
                    productId: widget.productId,
                    rating: rating.toInt(),
                    comment: commentController.text,
                  );

                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('✅ Đã gửi đánh giá')),
                    );
                    _loadReviews();
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('❌ Lỗi: $e')),
                    );
                  }
                }
              },
              child: const Text('Gửi đánh giá'),
            ),
          ],
        ),
      ),
    );
  }
}
