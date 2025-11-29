import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/app_provider.dart';
import '../utils/currency_format.dart';
import '../theme/app_theme.dart';
import '../screens/product_detail_screen.dart';
import 'optimized_image.dart';

class AnimatedProductCard extends StatefulWidget {
  final Product product;
  final int index;
  const AnimatedProductCard({super.key, required this.product, this.index = 0});

  @override
  State<AnimatedProductCard> createState() => _AnimatedProductCardState();
}

class _AnimatedProductCardState extends State<AnimatedProductCard> 
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _hoverController;
  late AnimationController _heartController;
  
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _hoverAnimation;
  late Animation<double> _heartAnimation;
  
  bool _isPressed = false;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    
    // Main animation controller
    _controller = AnimationController(
      duration: Duration(milliseconds: 600 + (widget.index * 150)),
      vsync: this,
    );
    
    // Hover animation controller
    _hoverController = AnimationController(
      duration: AppTheme.normalAnimation,
      vsync: this,
    );
    
    // Heart animation controller
    _heartController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    // Setup animations
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.2, 1.0, curve: Curves.easeOut)),
    );
    
    _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.3, 1.0, curve: Curves.easeOutCubic)),
    );
    
    _hoverAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _hoverController, curve: Curves.easeInOut),
    );
    
    _heartAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _heartController, curve: Curves.elasticOut),
    );

    // Start entrance animation
    Future.delayed(Duration(milliseconds: widget.index * 100), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _hoverController.dispose();
    _heartController.dispose();
    super.dispose();
  }

  void _onHover(bool isHovered) {
    setState(() => _isHovered = isHovered);
    if (isHovered) {
      _hoverController.forward();
    } else {
      _hoverController.reverse();
    }
  }

  void _onHeartTap(AppProvider provider) {
    provider.toggleWishlist(widget.product);
    _heartController.forward().then((_) {
      _heartController.reverse();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final isInWishlist = provider.isInWishlist(widget.product.id);

    return AnimatedBuilder(
      animation: Listenable.merge([_controller, _hoverController, _heartController]),
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value),
          child: Transform.scale(
            scale: _scaleAnimation.value * _hoverAnimation.value,
            child: Opacity(
              opacity: _fadeAnimation.value,
              child: child,
            ),
          ),
        );
      },
      child: MouseRegion(
        onEnter: (_) => _onHover(true),
        onExit: (_) => _onHover(false),
        child: GestureDetector(
          onTapDown: (_) => setState(() => _isPressed = true),
          onTapUp: (_) => setState(() => _isPressed = false),
          onTapCancel: () => setState(() => _isPressed = false),
          onTap: () => Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  ProductDetailScreen(product: widget.product),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
              transitionDuration: AppTheme.normalAnimation,
            ),
          ),
          child: AnimatedContainer(
            duration: AppTheme.fastAnimation,
            transform: Matrix4.identity()..scale(_isPressed ? 0.96 : 1.0),
            child: Container(
              constraints: const BoxConstraints(
                maxHeight: 260,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: AppTheme.surfaceColor,
                boxShadow: [
                  BoxShadow(
                    color: _isHovered 
                        ? AppTheme.primaryColor.withOpacity(0.2)
                        : Colors.black.withOpacity(0.08),
                    blurRadius: _isHovered ? 20 : 10,
                    offset: Offset(0, _isHovered ? 8 : 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildImageSection(isInWishlist, provider),
                  Flexible(
                    child: _buildContentSection(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageSection(bool isInWishlist, AppProvider provider) {
    return Stack(
      children: [
        Hero(
          tag: 'product_${widget.product.id}',
          child: ProductImage(
            imageUrl: widget.product.imageUrl,
            width: double.infinity,
            height: 135,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
        ),
        
        // Discount badge
        if (widget.product.discountPercent != null)
          Positioned(
            top: 12,
            left: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                gradient: AppTheme.secondaryGradient,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.secondaryColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                '-${widget.product.discountPercent}%',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        
        // Wishlist button
        Positioned(
          top: 12,
          right: 12,
          child: GestureDetector(
            onTap: () => _onHeartTap(provider),
            child: AnimatedContainer(
              duration: AppTheme.normalAnimation,
              transform: Matrix4.identity()..scale(_heartAnimation.value),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isInWishlist 
                      ? AppTheme.secondaryColor 
                      : Colors.white.withOpacity(0.9),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  isInWishlist ? Icons.favorite : Icons.favorite_border,
                  color: isInWishlist ? Colors.white : AppTheme.secondaryColor,
                  size: 18,
                ),
              ),
            ),
          ),
        ),
        
        // Stock status
        if (widget.product.stockQuantity <= 5)
          Positioned(
            bottom: 8,
            left: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: widget.product.stockQuantity == 0 
                    ? AppTheme.errorColor 
                    : AppTheme.warningColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                widget.product.stockQuantity == 0 
                    ? 'Hết hàng' 
                    : 'Còn ${widget.product.stockQuantity}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildContentSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Product name
          Text(
            widget.product.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: AppTheme.textPrimary,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 5),
          
          // Price section
          Row(
            children: [
              Flexible(
                child: Text(
                  formatCurrency(widget.product.price),
                  style: const TextStyle(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (widget.product.originalPrice != null) ...[
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    formatCurrency(widget.product.originalPrice!),
                    style: const TextStyle(
                      decoration: TextDecoration.lineThrough,
                      color: AppTheme.textTertiary,
                      fontSize: 11,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 5),
          
          // Rating and reviews
          if (widget.product.averageRating != null) ...[
            Row(
              children: [
                RatingBarIndicator(
                  rating: widget.product.averageRating!,
                  itemBuilder: (_, __) => const Icon(
                    Icons.star_rounded,
                    color: Colors.amber,
                  ),
                  itemCount: 5,
                  itemSize: 11,
                ),
                const SizedBox(width: 3),
                Text(
                  '(${widget.product.reviewCount})',
                  style: const TextStyle(
                    fontSize: 9,
                    color: AppTheme.textTertiary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 3),
          ],
          
          // Sold quantity
          Row(
            children: [
              const Icon(
                Icons.local_fire_department_rounded,
                size: 11,
                color: AppTheme.secondaryColor,
              ),
              const SizedBox(width: 2),
              Flexible(
                child: Text(
                  'Đã bán ${widget.product.soldQuantity}',
                  style: const TextStyle(
                    fontSize: 9,
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
