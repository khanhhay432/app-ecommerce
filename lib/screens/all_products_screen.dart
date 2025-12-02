import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/product_service.dart';
import '../theme/app_theme.dart';
import '../widgets/animated_product_card.dart';
import '../widgets/shimmer_loading.dart';

class AllProductsScreen extends StatefulWidget {
  final String title;
  final String type;
  const AllProductsScreen({super.key, required this.title, this.type = 'all'});
  @override
  State<AllProductsScreen> createState() => _AllProductsScreenState();
}

class _AllProductsScreenState extends State<AllProductsScreen> {
  List<Product> _products = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() => _isLoading = true);
    List<Product> products;
    switch (widget.type) {
      case 'featured': products = await ProductService.getFeaturedProducts(); break;
      case 'top-selling': products = await ProductService.getTopSellingProducts(limit: 50); break;
      case 'new-arrivals': products = await ProductService.getNewArrivals(limit: 50); break;
      case 'on-sale': products = await ProductService.getOnSaleProducts(limit: 50); break;
      default:
        final result = await ProductService.getAllProducts();
        products = result['products'] as List<Product>;
    }
    if (mounted) setState(() { _products = products; _isLoading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor, 
        elevation: 0, 
        title: Text(widget.title, style: const TextStyle(fontWeight: FontWeight.bold))
      ),
      body: _isLoading
          ? GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.68, crossAxisSpacing: 12, mainAxisSpacing: 12),
              itemCount: 6,
              itemBuilder: (_, __) => const ShimmerProductCard(),
            )
          : _products.isEmpty
              ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.inventory_2_outlined, size: 60, color: AppTheme.getTertiaryTextColor(context)),
                  const SizedBox(height: 16),
                  Text('Không có sản phẩm', style: TextStyle(color: AppTheme.getSecondaryTextColor(context))),
                ]))
              : RefreshIndicator(
                  onRefresh: _loadProducts,
                  child: GridView.builder(
                    padding: const EdgeInsets.all(16),
                    physics: const BouncingScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.68, crossAxisSpacing: 12, mainAxisSpacing: 12),
                    itemCount: _products.length,
                    itemBuilder: (_, i) => AnimatedProductCard(product: _products[i], index: i),
                  ),
                ),
    );
  }
}
