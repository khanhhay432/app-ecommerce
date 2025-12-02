import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../theme/app_theme.dart';
import '../../models/product.dart';
import '../../utils/currency_format.dart';
import 'add_product_screen.dart';
import 'edit_product_screen.dart';

class ManageProductsScreen extends StatefulWidget {
  const ManageProductsScreen({super.key});

  @override
  State<ManageProductsScreen> createState() => _ManageProductsScreenState();
}

class _ManageProductsScreenState extends State<ManageProductsScreen> {
  String _searchQuery = '';
  int _selectedCategoryId = 0; // 0 = All

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        title: const Text('Quản lý sản phẩm', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<AppProvider>().refreshData(),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchAndFilter(),
          Expanded(
            child: Consumer<AppProvider>(
              builder: (context, provider, child) {
                final products = _getFilteredProducts(provider);
                
                if (products.isEmpty) {
                  return _buildEmptyState();
                }
                
                return RefreshIndicator(
                  onRefresh: () => provider.refreshData(),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: products.length,
                    itemBuilder: (_, i) => _buildProductCard(products[i]),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddProductScreen()),
          );
          if (result == true && mounted) {
            context.read<AppProvider>().refreshData();
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Thêm sản phẩm'),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Theme.of(context).cardColor,
      child: Column(
        children: [
          // Search bar
          TextField(
            decoration: InputDecoration(
              hintText: 'Tìm kiếm sản phẩm...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Theme.of(context).brightness == Brightness.dark 
                  ? const Color(0xFF2D2D2D) 
                  : Colors.grey[100],
            ),
            onChanged: (value) => setState(() => _searchQuery = value),
          ),
          const SizedBox(height: 12),
          // Category filter
          Consumer<AppProvider>(
            builder: (context, provider, child) {
              return SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _buildCategoryChip(0, 'Tất cả'),
                    ...provider.categories.map((cat) => _buildCategoryChip(cat.id, cat.name)),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(int categoryId, String label) {
    final isSelected = _selectedCategoryId == categoryId;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) => setState(() => _selectedCategoryId = categoryId),
        backgroundColor: Theme.of(context).brightness == Brightness.dark 
            ? const Color(0xFF2D2D2D) 
            : Colors.grey[100],
        selectedColor: AppTheme.primaryColor.withOpacity(0.2),
        labelStyle: TextStyle(
          color: isSelected ? AppTheme.primaryColor : AppTheme.getSecondaryTextColor(context),
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 80, color: AppTheme.getTertiaryTextColor(context)),
          const SizedBox(height: 16),
          Text(
            'Chưa có sản phẩm',
            style: TextStyle(fontSize: 18, color: AppTheme.getSecondaryTextColor(context)),
          ),
          const SizedBox(height: 8),
          Text(
            'Nhấn nút + để thêm sản phẩm mới',
            style: TextStyle(color: AppTheme.getTertiaryTextColor(context)),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(Product product) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: Row(
        children: [
          // Product image
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              bottomLeft: Radius.circular(16),
            ),
            child: Image.network(
              product.imageUrl ?? '',
              width: 100,
              height: 120,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 100,
                height: 120,
                color: Colors.grey[300],
                child: const Icon(Icons.image_not_supported),
              ),
            ),
          ),
          // Product info
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.categoryName ?? '',
                    style: TextStyle(color: AppTheme.getSecondaryTextColor(context), fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    formatCurrency(product.price),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).brightness == Brightness.dark 
                          ? AppTheme.primaryColor 
                          : const Color(0xFF4338CA),
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.inventory_2, size: 14, color: AppTheme.getSecondaryTextColor(context)),
                      const SizedBox(width: 4),
                      Text(
                        'Kho: ${product.stockQuantity}',
                        style: TextStyle(color: AppTheme.getSecondaryTextColor(context), fontSize: 12),
                      ),
                      const SizedBox(width: 12),
                      Icon(Icons.shopping_cart, size: 14, color: AppTheme.getSecondaryTextColor(context)),
                      const SizedBox(width: 4),
                      Text(
                        'Đã bán: ${product.soldQuantity}',
                        style: TextStyle(color: AppTheme.getSecondaryTextColor(context), fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // Actions
          Column(
            children: [
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.blue),
                onPressed: () => _editProduct(product),
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _deleteProduct(product),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<Product> _getFilteredProducts(AppProvider provider) {
    var products = provider.products;
    
    // Filter by category
    if (_selectedCategoryId != 0) {
      products = products.where((p) => p.categoryId == _selectedCategoryId).toList();
    }
    
    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      products = products.where((p) => 
        p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        (p.description ?? '').toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }
    
    return products;
  }

  Future<void> _editProduct(Product product) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EditProductScreen(product: product)),
    );
    if (result == true && mounted) {
      context.read<AppProvider>().refreshData();
    }
  }

  Future<void> _deleteProduct(Product product) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc muốn xóa sản phẩm "${product.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
    
    if (confirm == true && mounted) {
      final provider = context.read<AppProvider>();
      final success = await provider.deleteProduct(product.id);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? '✅ Đã xóa sản phẩm' : '❌ Lỗi khi xóa sản phẩm'),
            backgroundColor: success ? AppTheme.successColor : Colors.red,
          ),
        );
        if (success) {
          provider.refreshData();
        }
      }
    }
  }
}
