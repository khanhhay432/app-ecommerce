import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../widgets/animated_product_card.dart';

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Yêu thích')),
      body: Consumer<AppProvider>(
        builder: (_, provider, __) {
          if (provider.wishlist.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(color: Colors.pink[50], shape: BoxShape.circle),
                    child: Icon(Icons.favorite_outline, size: 60, color: Colors.pink[200]),
                  ),
                  const SizedBox(height: 24),
                  const Text('Chưa có sản phẩm yêu thích', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text('Hãy thêm sản phẩm vào danh sách yêu thích', style: TextStyle(color: Colors.grey[600])),
                ],
              ),
            );
          }
          return GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, childAspectRatio: 0.62, crossAxisSpacing: 12, mainAxisSpacing: 12,
            ),
            itemCount: provider.wishlist.length,
            itemBuilder: (_, i) => AnimatedProductCard(product: provider.wishlist[i], index: i),
          );
        },
      ),
    );
  }
}
