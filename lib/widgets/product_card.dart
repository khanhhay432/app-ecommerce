import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../models/product.dart';
import '../utils/currency_format.dart';
import '../screens/product_detail_screen.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(
        builder: (_) => ProductDetailScreen(productId: product.id),
      )),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: CachedNetworkImage(
                    imageUrl: product.imageUrl ?? '',
                    height: 150, width: double.infinity, fit: BoxFit.cover,
                    placeholder: (_, __) => Container(height: 150, color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[800] : Colors.grey[200]),
                    errorWidget: (_, __, ___) => Container(
                      height: 150, color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[800] : Colors.grey[200],
                      child: const Icon(Icons.image, size: 50),
                    ),
                  ),
                ),
                if (product.discountPercent != null && product.discountPercent! > 0)
                  Positioned(
                    top: 8, left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red, borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text('-${product.discountPercent}%',
                        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.name, maxLines: 2, overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 4),
                  Text(formatCurrency(product.price),
                    style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold),
                  ),
                  if (product.originalPrice != null && product.originalPrice! > product.price)
                    Text(formatCurrency(product.originalPrice!),
                      style: const TextStyle(decoration: TextDecoration.lineThrough, color: Colors.grey, fontSize: 12),
                    ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (product.averageRating != null) ...[
                        RatingBarIndicator(
                          rating: product.averageRating!,
                          itemBuilder: (_, __) => const Icon(Icons.star, color: Colors.amber),
                          itemCount: 5, itemSize: 14,
                        ),
                        const SizedBox(width: 4),
                        Text('(${product.reviewCount})', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text('Đã bán ${product.soldQuantity}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
