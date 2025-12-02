import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/product_service.dart';
import '../theme/app_theme.dart';
import '../widgets/animated_product_card.dart';
import '../widgets/shimmer_loading.dart';

class FlashSaleScreen extends StatefulWidget {
  const FlashSaleScreen({super.key});
  @override
  State<FlashSaleScreen> createState() => _FlashSaleScreenState();
}

class _FlashSaleScreenState extends State<FlashSaleScreen> {
  List<Product> _products = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() => _isLoading = true);
    final products = await ProductService.getOnSaleProducts(limit: 50);
    if (mounted) setState(() { _products = products; _isLoading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            backgroundColor: AppTheme.secondaryColor,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(gradient: AppTheme.secondaryGradient),
                child: Stack(
                  children: [
                    Positioned(right: -50, bottom: -50, child: Icon(Icons.flash_on, size: 200, color: Colors.white.withOpacity(0.1))),
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                            child: const Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.flash_on, color: Colors.white, size: 16), SizedBox(width: 4), Text('FLASH SALE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12))]),
                          ),
                          const SizedBox(height: 12),
                          const Text('Giảm giá sốc!', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                          const Text('Ưu đãi có hạn, nhanh tay kẻo lỡ', style: TextStyle(color: Colors.white70)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: _isLoading
                ? SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.68, crossAxisSpacing: 12, mainAxisSpacing: 12),
                    delegate: SliverChildBuilderDelegate((_, __) => const ShimmerProductCard(), childCount: 6),
                  )
                : _products.isEmpty
                    ? SliverToBoxAdapter(child: SizedBox(height: 300, child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.flash_off, size: 60, color: AppTheme.getTertiaryTextColor(context)), const SizedBox(height: 16), Text('Chưa có sản phẩm giảm giá', style: TextStyle(color: AppTheme.getSecondaryTextColor(context)))]))))
                    : SliverGrid(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.68, crossAxisSpacing: 12, mainAxisSpacing: 12),
                        delegate: SliverChildBuilderDelegate((_, i) => AnimatedProductCard(product: _products[i], index: i), childCount: _products.length),
                      ),
          ),
        ],
      ),
    );
  }
}
