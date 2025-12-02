import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/animated_product_card.dart';

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        title: const Text('Yêu thích', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Consumer<AppProvider>(
        builder: (context, provider, child) {
          if (provider.wishlist.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.elasticOut,
                    builder: (context, value, child) => Transform.scale(scale: value, child: child),
                    child: Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(color: AppTheme.secondaryColor.withOpacity(0.1), shape: BoxShape.circle),
                      child: const Icon(Icons.favorite_border, size: 60, color: AppTheme.secondaryColor),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text('Chưa có sản phẩm yêu thích', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text('Hãy thêm sản phẩm vào danh sách yêu thích', style: TextStyle(color: AppTheme.getSecondaryTextColor(context))),
                ],
              ),
            );
          }
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            physics: const BouncingScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.68, crossAxisSpacing: 12, mainAxisSpacing: 12),
            itemCount: provider.wishlist.length,
            itemBuilder: (_, i) => AnimatedProductCard(product: provider.wishlist[i], index: i),
          );
        },
      ),
    );
  }
}
