import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/product_service.dart';
import '../theme/app_theme.dart';
import '../widgets/animated_product_card.dart';
import '../widgets/shimmer_loading.dart';

class CategoryProductsScreen extends StatefulWidget {
  final int categoryId;
  final String categoryName;

  const CategoryProductsScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  @override
  State<CategoryProductsScreen> createState() => _CategoryProductsScreenState();
}

class _CategoryProductsScreenState extends State<CategoryProductsScreen> {
  List<Product> _products = [];
  bool _isLoading = true;
  int _currentPage = 0;
  bool _hasMore = true;
  final ScrollController _scrollController = ScrollController();
  String _sortBy = 'newest';

  @override
  void initState() {
    super.initState();
    _loadProducts();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      if (!_isLoading && _hasMore) {
        _loadMore();
      }
    }
  }

  Future<void> _loadProducts() async {
    setState(() => _isLoading = true);
    
    final result = await ProductService.getProductsByCategory(widget.categoryId, page: 0);
    
    if (mounted) {
      setState(() {
        _products = result['products'] as List<Product>;
        _hasMore = !(result['isLast'] as bool);
        _currentPage = 0;
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMore() async {
    if (_isLoading) return;
    
    setState(() => _isLoading = true);
    
    final result = await ProductService.getProductsByCategory(
      widget.categoryId,
      page: _currentPage + 1,
    );
    
    if (mounted) {
      setState(() {
        _products.addAll(result['products'] as List<Product>);
        _hasMore = !(result['isLast'] as bool);
        _currentPage++;
        _isLoading = false;
      });
    }
  }

  void _sortProducts(String sortBy) {
    setState(() {
      _sortBy = sortBy;
      switch (sortBy) {
        case 'price_low':
          _products.sort((a, b) => a.price.compareTo(b.price));
          break;
        case 'price_high':
          _products.sort((a, b) => b.price.compareTo(a.price));
          break;
        case 'popular':
          _products.sort((a, b) => b.soldQuantity.compareTo(a.soldQuantity));
          break;
        case 'newest':
        default:
          // Keep original order from API
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        title: Text(widget.categoryName, style: const TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showSortOptions,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading && _products.isEmpty) {
      return GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.68,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: 6,
        itemBuilder: (_, __) => const ShimmerProductCard(),
      );
    }

    if (_products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined, size: 80, color: AppTheme.getTertiaryTextColor(context)),
            const SizedBox(height: 16),
            Text(
              'Không có sản phẩm',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.getSecondaryTextColor(context)),
            ),
            const SizedBox(height: 8),
            Text(
              'Danh mục này chưa có sản phẩm nào',
              style: TextStyle(color: AppTheme.getSecondaryTextColor(context)),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadProducts,
      child: CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverToBoxAdapter(
              child: Row(
                children: [
                  Text(
                    '${_products.length} sản phẩm',
                    style: TextStyle(fontWeight: FontWeight.w500, color: AppTheme.getSecondaryTextColor(context)),
                  ),
                  const Spacer(),
                  _buildSortChip(),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.68,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              delegate: SliverChildBuilderDelegate(
                (_, i) => AnimatedProductCard(product: _products[i], index: i),
                childCount: _products.length,
              ),
            ),
          ),
          if (_isLoading && _products.isNotEmpty)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSortChip() {
    final sortLabels = {
      'newest': 'Mới nhất',
      'popular': 'Phổ biến',
      'price_low': 'Giá thấp',
      'price_high': 'Giá cao',
    };

    return GestureDetector(
      onTap: _showSortOptions,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppTheme.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.sort, size: 16, color: AppTheme.primaryColor),
            const SizedBox(width: 4),
            Text(
              sortLabels[_sortBy]!,
              style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.w500, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Sắp xếp theo', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildSortOption('newest', 'Mới nhất', Icons.access_time),
            _buildSortOption('popular', 'Phổ biến nhất', Icons.trending_up),
            _buildSortOption('price_low', 'Giá thấp đến cao', Icons.arrow_upward),
            _buildSortOption('price_high', 'Giá cao đến thấp', Icons.arrow_downward),
          ],
        ),
      ),
    );
  }

  Widget _buildSortOption(String value, String label, IconData icon) {
    final isSelected = _sortBy == value;
    return ListTile(
      leading: Icon(icon, color: isSelected ? AppTheme.primaryColor : Colors.grey),
      title: Text(label, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
      trailing: isSelected ? const Icon(Icons.check, color: AppTheme.primaryColor) : null,
      onTap: () {
        _sortProducts(value);
        Navigator.pop(context);
      },
    );
  }
}
