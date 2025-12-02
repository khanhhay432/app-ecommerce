import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import '../utils/currency_format.dart';
import '../screens/product_detail_screen.dart';
import 'optimized_image.dart';

class AnimatedProductCard extends StatefulWidget {
  final Product product;
  final int index;

  const AnimatedProductCard({
    super.key,
    required this.product,
    required this.index,
  });

  @override
  State<AnimatedProductCard> createState() => _AnimatedProductCardState();
}

class _AnimatedProductCardState extends State<AnimatedProductCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 400 + (widget.index * 100)),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
  }

  void _onTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
  }

  void _onTapCancel() {
    setState(() => _isPressed = false);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final isInWishlist = provider.isInWishlist(widget.product.id);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: child,
          ),
        );
      },
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        onTap: () {
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  ProductDetailScreen(product: widget.product),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.1),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
                    child: child,
                  ),
                );
              },
              transitionDuration: const Duration(milliseconds: 300),
            ),
          );
        },
        child: AnimatedScale(
          scale: _isPressed ? 0.95 : 1.0,
          duration: const Duration(milliseconds: 150),
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryColor.withOpacity(0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image section
                Expanded(
                  flex: 3,
                  child: Stack(
                    children: [
                      // Product image
                      Hero(
                        tag: 'product_${widget.product.id}',
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                          child: ProductImage(
                            imageUrl: widget.product.imageUrl,
                            width: double.infinity,
                            height: double.infinity,
                          ),
                        ),
                      ),
                      // Discount badge
                      if (widget.product.discountPercent != null)
                        Positioned(
                          top: 8,
                          left: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              gradient: AppTheme.secondaryGradient,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '-${widget.product.discountPercent}%',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      // Wishlist button
                      Positioned(
                        top: 8,
                        right: 8,
                        child: GestureDetector(
                          onTap: () => provider.toggleWishlist(widget.product),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: isInWishlist ? AppTheme.secondaryColor : Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                            child: Icon(
                              isInWishlist ? Icons.favorite : Icons.favorite_border,
                              size: 18,
                              color: isInWishlist ? Colors.white : AppTheme.secondaryColor,
                            ),
                          ),
                        ),
                      ),
                      // Out of stock overlay
                      if (widget.product.stockQuantity <= 0)
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.5),
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                            ),
                            child: const Center(
                              child: Text(
                                'Hết hàng',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                // Info section
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.product.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            height: 1.3,
                            color: Theme.of(context).brightness == Brightness.dark 
                                ? Colors.white 
                                : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        // Rating
                        if (widget.product.averageRating != null && widget.product.averageRating! > 0)
                          Row(
                            children: [
                              const Icon(Icons.star, size: 14, color: Colors.amber),
                              const SizedBox(width: 2),
                              Text(
                                widget.product.averageRating!.toStringAsFixed(1),
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
                              ),
                              Text(
                                ' (${widget.product.reviewCount})',
                                style: TextStyle(fontSize: 10, color: AppTheme.getTertiaryTextColor(context)),
                              ),
                            ],
                          ),
                        const Spacer(),
                        // Price
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    formatCurrency(widget.product.price),
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).brightness == Brightness.dark 
                                          ? Colors.white 
                                          : AppTheme.primaryColor,
                                    ),
                                  ),
                                  if (widget.product.originalPrice != null)
                                    Text(
                                      formatCurrency(widget.product.originalPrice!),
                                      style: TextStyle(
                                        fontSize: 11,
                                        decoration: TextDecoration.lineThrough,
                                        color: AppTheme.getTertiaryTextColor(context),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            // Add to cart button
                            GestureDetector(
                              onTap: widget.product.stockQuantity > 0
                                  ? () {
                                      provider.addToCart(widget.product);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: const Row(
                                            children: [
                                              Icon(Icons.check_circle, color: Colors.white),
                                              SizedBox(width: 8),
                                              Text('Đã thêm vào giỏ hàng'),
                                            ],
                                          ),
                                          backgroundColor: AppTheme.successColor,
                                          behavior: SnackBarBehavior.floating,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          duration: const Duration(seconds: 2),
                                        ),
                                      );
                                    }
                                  : null,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  gradient: widget.product.stockQuantity > 0
                                      ? AppTheme.primaryGradient
                                      : null,
                                  color: widget.product.stockQuantity <= 0 
                                      ? (Theme.of(context).brightness == Brightness.dark ? Colors.grey[700] : Colors.grey[300]) 
                                      : null,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  Icons.add_shopping_cart,
                                  size: 18,
                                  color: widget.product.stockQuantity > 0 ? Colors.white : Colors.grey,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
