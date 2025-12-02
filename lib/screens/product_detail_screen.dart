import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../models/review.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import '../utils/currency_format.dart';
import '../services/review_service.dart';
import '../widgets/optimized_image.dart';
import 'review_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;
  const ProductDetailScreen({super.key, required this.product});
  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen>
    with TickerProviderStateMixin {
  int _quantity = 1;
  late AnimationController _animController;
  late AnimationController _pulseController;
  late Animation<double> _slideAnimation;
  late Animation<double> _pulseAnimation;
  List<Map<String, dynamic>> _reviews = [];
  bool _loadingReviews = true;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _slideAnimation = Tween<double>(begin: 100, end: 0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    
    _animController.forward();
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    final result = await ReviewService.getProductReviews(widget.product.id);
    if (mounted) {
      setState(() {
        _reviews = result;
        _loadingReviews = false;
      });
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    _pulseController.dispose();
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
            Text('Đã thêm $_quantity sản phẩm vào giỏ hàng!'),
          ],
        ),
        backgroundColor: AppTheme.successColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final isInWishlist = provider.isInWishlist(widget.product.id);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildAppBar(isInWishlist, provider),
          SliverToBoxAdapter(
            child: AnimatedBuilder(
              animation: _animController,
              builder: (context, child) => Transform.translate(
                offset: Offset(0, _slideAnimation.value),
                child: child,
              ),
              child: _buildContent(),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  SliverAppBar _buildAppBar(bool isInWishlist, AppProvider provider) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconBgColor = isDark ? const Color(0xFF2D3748) : Colors.white;
    final iconColor = isDark ? Colors.white : Colors.black;
    
    return SliverAppBar(
      expandedHeight: 350,
      pinned: true,
      backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconBgColor,
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8)],
          ),
          child: Icon(Icons.arrow_back, color: iconColor),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconBgColor,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8)],
            ),
            child: Icon(
              isInWishlist ? Icons.favorite : Icons.favorite_border,
              color: isInWishlist ? AppTheme.secondaryColor : iconColor,
            ),
          ),
          onPressed: () => provider.toggleWishlist(widget.product),
        ),
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconBgColor,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8)],
            ),
            child: Icon(Icons.share, color: iconColor),
          ),
          onPressed: () {},
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Hero(
          tag: 'product_${widget.product.id}',
          child: ProductImage(
            imageUrl: widget.product.imageUrl,
            width: double.infinity,
            height: double.infinity,
          ),
        ),
      ),
    );
  }


  Widget _buildContent() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category & Discount
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  widget.product.categoryName,
                  style: const TextStyle(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
              ),
              const Spacer(),
              if (widget.product.discountPercent != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: AppTheme.secondaryGradient,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '-${widget.product.discountPercent}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Product name
          Text(
            widget.product.name,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, height: 1.3),
          ),
          const SizedBox(height: 16),
          
          // Price
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                formatCurrency(widget.product.price),
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
              if (widget.product.originalPrice != null) ...[
                const SizedBox(width: 12),
                Text(
                  formatCurrency(widget.product.originalPrice!),
                  style: TextStyle(
                    fontSize: 18,
                    decoration: TextDecoration.lineThrough,
                    color: Colors.grey[400],
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),
          
          // Rating & Sold
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 18),
                    const SizedBox(width: 4),
                    Text(
                      '${widget.product.averageRating?.toStringAsFixed(1) ?? '0'}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      ' (${widget.product.reviewCount} đánh giá)',
                      style: TextStyle(color: AppTheme.getSecondaryTextColor(context), fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(Icons.local_fire_department, color: Colors.orange[400], size: 18),
                    const SizedBox(width: 4),
                    Text(
                      'Đã bán ${widget.product.soldQuantity}',
                      style: TextStyle(color: AppTheme.getSecondaryTextColor(context), fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          // Stock status
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                widget.product.stockQuantity > 0 ? Icons.check_circle : Icons.cancel,
                color: widget.product.stockQuantity > 0 ? AppTheme.successColor : Colors.red,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                widget.product.stockQuantity > 0
                    ? 'Còn ${widget.product.stockQuantity} sản phẩm'
                    : 'Hết hàng',
                style: TextStyle(
                  color: widget.product.stockQuantity > 0 ? AppTheme.successColor : Colors.red,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          
          const Divider(height: 32),
          
          // Description
          const Text(
            'Mô tả sản phẩm',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            widget.product.description ?? 'Không có mô tả',
            style: TextStyle(color: AppTheme.getSecondaryTextColor(context), height: 1.6, fontSize: 14),
          ),
          
          const Divider(height: 32),
          
          // Reviews section
          Row(
            children: [
              const Text(
                'Đánh giá',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              OutlinedButton.icon(
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ReviewScreen(product: widget.product),
                    ),
                  );
                  if (result == true) {
                    _loadReviews();
                  }
                },
                icon: const Icon(Icons.rate_review, size: 18),
                label: const Text('Viết đánh giá'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
            ],
          ),
          
          if (_loadingReviews)
            const Center(child: CircularProgressIndicator())
          else if (_reviews.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.rate_review_outlined, size: 48, color: AppTheme.getTertiaryTextColor(context)),
                    const SizedBox(height: 8),
                    Text('Chưa có đánh giá nào', style: TextStyle(color: AppTheme.getTertiaryTextColor(context))),
                  ],
                ),
              ),
            )
          else
            ...(_reviews.take(3).map((r) => _buildReviewItem(r))),
          
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildReviewItem(Map<String, dynamic> review) {
    final userName = review['userName'] ?? review['fullName'] ?? 'Anonymous';
    final userAvatar = review['userAvatar'] ?? review['avatarUrl'];
    final rating = review['rating'] ?? 0;
    final comment = review['comment'] ?? '';
    final isVerified = review['isVerifiedPurchase'] ?? false;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark 
            ? const Color(0xFF2D2D2D) 
            : Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: AppTheme.primaryColor.withOpacity(0.2),
                backgroundImage: userAvatar != null ? NetworkImage(userAvatar) : null,
                child: userAvatar == null
                    ? Text(userName[0].toUpperCase(), style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold))
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(userName, style: const TextStyle(fontWeight: FontWeight.bold)),
                    Row(
                      children: List.generate(5, (i) => Icon(
                        i < rating ? Icons.star : Icons.star_border,
                        size: 14,
                        color: Colors.amber,
                      )),
                    ),
                  ],
                ),
              ),
              if (isVerified)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.successColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.verified, color: AppTheme.successColor, size: 12),
                      SizedBox(width: 4),
                      Text('Đã mua', style: TextStyle(color: AppTheme.successColor, fontSize: 10)),
                    ],
                  ),
                ),
            ],
          ),
          if (comment.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(comment, style: TextStyle(color: AppTheme.getSecondaryTextColor(context), height: 1.4)),
          ],
          const SizedBox(height: 8),
          Text(
            review['createdAt'] ?? '',
            style: TextStyle(color: AppTheme.getTertiaryTextColor(context), fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, -5))],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Quantity selector
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Theme.of(context).dividerColor),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: () {
                      if (_quantity > 1) setState(() => _quantity--);
                    },
                  ),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: Text(
                      '$_quantity',
                      key: ValueKey(_quantity),
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      if (_quantity < widget.product.stockQuantity) {
                        setState(() => _quantity++);
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // Add to cart button
            Expanded(
              child: AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: widget.product.stockQuantity > 0 ? _pulseAnimation.value : 1.0,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: widget.product.stockQuantity > 0 ? AppTheme.primaryGradient : null,
                        color: widget.product.stockQuantity <= 0 ? (Theme.of(context).brightness == Brightness.dark ? Colors.grey[700] : Colors.grey[300]) : null,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: widget.product.stockQuantity > 0
                            ? [BoxShadow(color: AppTheme.primaryColor.withOpacity(0.4), blurRadius: 12, offset: const Offset(0, 4))]
                            : null,
                      ),
                      child: ElevatedButton(
                        onPressed: widget.product.stockQuantity > 0 ? _addToCart : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.shopping_cart_outlined,
                              color: widget.product.stockQuantity > 0 ? Colors.white : Colors.grey,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              widget.product.stockQuantity > 0 ? 'Thêm vào giỏ' : 'Hết hàng',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: widget.product.stockQuantity > 0 ? Colors.white : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
