import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../models/product.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import '../utils/currency_format.dart';
import '../data/mock_data.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;
  const ProductDetailScreen({super.key, required this.product});
  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> with SingleTickerProviderStateMixin {
  int _quantity = 1;
  late AnimationController _animController;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(duration: const Duration(milliseconds: 500), vsync: this);
    _slideAnimation = Tween<double>(begin: 100, end: 0).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _addToCart() {
    final provider = context.read<AppProvider>();
    provider.addToCart(widget.product, quantity: _quantity);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            const Text('Đã thêm vào giỏ hàng!'),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final isInWishlist = provider.isInWishlist(widget.product.id);
    final reviews = MockData.reviews.where((r) => r['productId'] == widget.product.id).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 350,
            pinned: true,
            backgroundColor: Colors.white,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8)]),
                child: const Icon(Icons.arrow_back, color: Colors.black),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8)]),
                  child: Icon(isInWishlist ? Icons.favorite : Icons.favorite_border, color: isInWishlist ? AppTheme.secondaryColor : Colors.black),
                ),
                onPressed: () => provider.toggleWishlist(widget.product),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: 'product_${widget.product.id}',
                child: CachedNetworkImage(imageUrl: widget.product.imageUrl ?? '', fit: BoxFit.cover),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: AnimatedBuilder(
              animation: _animController,
              builder: (context, child) => Transform.translate(offset: Offset(0, _slideAnimation.value), child: child),
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(child: Text(widget.product.categoryName, style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.w500))),
                        if (widget.product.discountPercent != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(color: AppTheme.secondaryColor, borderRadius: BorderRadius.circular(20)),
                            child: Text('-${widget.product.discountPercent}%', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(widget.product.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(formatCurrency(widget.product.price), style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
                        if (widget.product.originalPrice != null) ...[
                          const SizedBox(width: 12),
                          Text(formatCurrency(widget.product.originalPrice!), style: TextStyle(fontSize: 18, decoration: TextDecoration.lineThrough, color: Colors.grey[400])),
                        ],
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        RatingBarIndicator(
                          rating: widget.product.averageRating ?? 0,
                          itemBuilder: (_, __) => const Icon(Icons.star, color: Colors.amber),
                          itemCount: 5, itemSize: 20,
                        ),
                        const SizedBox(width: 8),
                        Text('${widget.product.averageRating?.toStringAsFixed(1) ?? 0}', style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text(' (${widget.product.reviewCount} đánh giá)', style: TextStyle(color: Colors.grey[600])),
                        const Spacer(),
                        Icon(Icons.local_fire_department, color: Colors.orange[400], size: 18),
                        Text(' Đã bán ${widget.product.soldQuantity}', style: TextStyle(color: Colors.grey[600])),
                      ],
                    ),
                    const Divider(height: 32),
                    const Text('Mô tả sản phẩm', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Text(widget.product.description ?? 'Không có mô tả', style: TextStyle(color: Colors.grey[700], height: 1.6)),
                    const Divider(height: 32),
                    Row(
                      children: [
                        const Text('Đánh giá', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const Spacer(),
                        TextButton(onPressed: () {}, child: const Text('Xem tất cả')),
                      ],
                    ),
                    if (reviews.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Center(child: Text('Chưa có đánh giá nào', style: TextStyle(color: Colors.grey[500]))),
                      )
                    else
                      ...reviews.map((r) => _buildReviewItem(r)),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, -5))],
        ),
        child: SafeArea(
          child: Row(
            children: [
              Container(
                decoration: BoxDecoration(border: Border.all(color: Colors.grey[300]!), borderRadius: BorderRadius.circular(12)),
                child: Row(
                  children: [
                    IconButton(icon: const Icon(Icons.remove), onPressed: () { if (_quantity > 1) setState(() => _quantity--); }),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: Text('$_quantity', key: ValueKey(_quantity), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                    IconButton(icon: const Icon(Icons.add), onPressed: () { if (_quantity < widget.product.stockQuantity) setState(() => _quantity++); }),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: widget.product.stockQuantity > 0 ? _addToCart : null,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: AppTheme.primaryColor,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.shopping_cart_outlined),
                      const SizedBox(width: 8),
                      Text(widget.product.stockQuantity > 0 ? 'Thêm vào giỏ' : 'Hết hàng', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReviewItem(Map<String, dynamic> review) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(backgroundColor: AppTheme.primaryColor.withOpacity(0.2), child: Text(review['userName'][0], style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold))),
              const SizedBox(width: 12),
              Expanded(child: Text(review['userName'], style: const TextStyle(fontWeight: FontWeight.bold))),
              const Icon(Icons.verified, color: Colors.green, size: 16),
            ],
          ),
          const SizedBox(height: 8),
          RatingBarIndicator(rating: (review['rating'] as int).toDouble(), itemBuilder: (_, __) => const Icon(Icons.star, color: Colors.amber), itemCount: 5, itemSize: 16),
          const SizedBox(height: 8),
          Text(review['comment'], style: TextStyle(color: Colors.grey[700])),
          const SizedBox(height: 4),
          Text(review['date'], style: TextStyle(color: Colors.grey[400], fontSize: 12)),
        ],
      ),
    );
  }
}
