import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/product.dart';
import '../widgets/animated_product_card.dart';
import '../widgets/custom_bottom_sheet.dart';
import '../theme/app_theme.dart';

class AllProductsScreen extends StatefulWidget {
  final String? title;
  const AllProductsScreen({super.key, this.title});
  @override
  State<AllProductsScreen> createState() => _AllProductsScreenState();
}

class _AllProductsScreenState extends State<AllProductsScreen> {
  String _sortBy = 'popular';
  RangeValues _priceRange = const RangeValues(0, 50000000);
  double _minRating = 0;
  bool _isGridView = true;

  List<Product> _filterAndSort(List<Product> products) {
    var filtered = products.where((p) {
      final inPriceRange = p.price >= _priceRange.start && p.price <= _priceRange.end;
      final hasRating = (p.averageRating ?? 0) >= _minRating;
      return inPriceRange && hasRating;
    }).toList();

    switch (_sortBy) {
      case 'newest': filtered.sort((a, b) => b.id.compareTo(a.id)); break;
      case 'price_low': filtered.sort((a, b) => a.price.compareTo(b.price)); break;
      case 'price_high': filtered.sort((a, b) => b.price.compareTo(a.price)); break;
      case 'rating': filtered.sort((a, b) => (b.averageRating ?? 0).compareTo(a.averageRating ?? 0)); break;
      default: filtered.sort((a, b) => b.soldQuantity.compareTo(a.soldQuantity));
    }
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final products = _filterAndSort(provider.products);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? 'Tất cả sản phẩm'),
        actions: [
          IconButton(
            icon: Icon(_isGridView ? Icons.view_list : Icons.grid_view),
            onPressed: () => setState(() => _isGridView = !_isGridView),
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => showFilterBottomSheet(context, (filters) {
              setState(() {
                _priceRange = filters['priceRange'];
                _minRating = filters['minRating'];
                _sortBy = filters['sortBy'];
              });
            }),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Text('${products.length} sản phẩm', style: TextStyle(color: Colors.grey[600])),
                const Spacer(),
                DropdownButton<String>(
                  value: _sortBy,
                  underline: const SizedBox(),
                  items: const [
                    DropdownMenuItem(value: 'popular', child: Text('Phổ biến')),
                    DropdownMenuItem(value: 'newest', child: Text('Mới nhất')),
                    DropdownMenuItem(value: 'price_low', child: Text('Giá thấp')),
                    DropdownMenuItem(value: 'price_high', child: Text('Giá cao')),
                    DropdownMenuItem(value: 'rating', child: Text('Đánh giá')),
                  ],
                  onChanged: (v) => setState(() => _sortBy = v!),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isGridView
                ? GridView.builder(
                    padding: const EdgeInsets.all(12),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, childAspectRatio: 0.62, crossAxisSpacing: 12, mainAxisSpacing: 12,
                    ),
                    itemCount: products.length,
                    itemBuilder: (_, i) => AnimatedProductCard(product: products[i], index: i),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: products.length,
                    itemBuilder: (_, i) => _buildListItem(products[i]),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildListItem(Product product) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(8),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(product.imageUrl ?? '', width: 80, height: 80, fit: BoxFit.cover),
        ),
        title: Text(product.name, maxLines: 2, overflow: TextOverflow.ellipsis),
        subtitle: Text('${product.price.toStringAsFixed(0)}₫', style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold)),
        trailing: IconButton(icon: const Icon(Icons.add_shopping_cart), onPressed: () => context.read<AppProvider>().addToCart(product)),
      ),
    );
  }
}
