import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class OptimizedImage extends StatelessWidget {
  final String? imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Widget? placeholder;
  final Widget? errorWidget;

  const OptimizedImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholder,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    Widget imageWidget;

    if (imageUrl != null && imageUrl!.isNotEmpty) {
      if (imageUrl!.startsWith('assets/')) {
        // Local asset image
        imageWidget = Image.asset(
          imageUrl!,
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (context, error, stackTrace) => _buildErrorWidget(context),
        );
      } else {
        // Network image (fallback)
        print('🖼️ [OptimizedImage] Loading image: $imageUrl');
        imageWidget = Image.network(
          imageUrl!,
          width: width,
          height: height,
          fit: fit,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return _buildPlaceholder(context);
          },
          errorBuilder: (context, error, stackTrace) {
            print('❌ [OptimizedImage] Error loading image: $imageUrl');
            print('Error: $error');
            return _buildErrorWidget(context);
          },
        );
      }
    } else {
      imageWidget = Builder(
        builder: (context) => _buildErrorWidget(context),
      );
    }

    if (borderRadius != null) {
      imageWidget = ClipRRect(
        borderRadius: borderRadius!,
        child: imageWidget,
      );
    }

    return imageWidget;
  }

  Widget _buildPlaceholder(BuildContext context) {
    if (placeholder != null) return placeholder!;
    
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[800] : Colors.grey[200],
        borderRadius: borderRadius,
      ),
      child: const Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
        ),
      ),
    );
  }

  Widget _buildErrorWidget(BuildContext context) {
    if (errorWidget != null) return errorWidget!;
    
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF2D2D2D) : Colors.grey[100],
        borderRadius: borderRadius,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_not_supported_outlined,
            size: (height != null && height! < 100) ? 24 : 40,
            color: AppTheme.getTertiaryTextColor(context),
          ),
          if (height == null || height! >= 100) ...[
            const SizedBox(height: 8),
            Text(
              'Không có hình ảnh',
              style: TextStyle(
                color: AppTheme.getSecondaryTextColor(context),
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// Widget chuyên dụng cho product image
class ProductImage extends StatelessWidget {
  final String? imageUrl;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  const ProductImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return OptimizedImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      borderRadius: borderRadius,
      fit: BoxFit.cover,
    );
  }
}

// Widget chuyên dụng cho category image
class CategoryImage extends StatelessWidget {
  final String? imageUrl;
  final double size;

  const CategoryImage({
    super.key,
    required this.imageUrl,
    this.size = 60,
  });

  @override
  Widget build(BuildContext context) {
    return OptimizedImage(
      imageUrl: imageUrl,
      width: size,
      height: size,
      borderRadius: BorderRadius.circular(12),
      fit: BoxFit.cover,
      errorWidget: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: AppTheme.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          Icons.category_rounded,
          color: AppTheme.primaryColor,
          size: size * 0.5,
        ),
      ),
    );
  }
}