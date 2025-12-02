import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/product_service.dart';
import '../theme/app_theme.dart';
import '../widgets/animated_product_card.dart';
import '../widgets/shimmer_loading.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();
  List<Product> _results = [];
  bool _isLoading = false;
  bool _hasSearched = false;
  final List<String> _recentSearches = ['iPhone', 'Samsung', 'Laptop', 'Tai nghe'];
  final List<String> _popularSearches = ['iPhone 15', 'MacBook', 'AirPods', 'Galaxy S24', 'iPad'];

  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _search(String query) async {
    if (query.isEmpty) return;
    
    setState(() {
      _isLoading = true;
      _hasSearched = true;
    });

    final result = await ProductService.searchProducts(query);
    
    if (mounted) {
      setState(() {
        _results = result['products'] as List<Product>;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).iconTheme.color),
          onPressed: () => Navigator.pop(context),
        ),
        title: Hero(
          tag: 'search_bar',
          child: Material(
            color: Colors.transparent,
            child: TextField(
              controller: _searchController,
              focusNode: _focusNode,
              decoration: InputDecoration(
                hintText: 'Tìm kiếm sản phẩm...',
                hintStyle: TextStyle(color: AppTheme.getHintTextColor(context)),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              onSubmitted: _search,
              textInputAction: TextInputAction.search,
            ),
          ),
        ),
        actions: [
          if (_searchController.text.isNotEmpty)
            IconButton(
              icon: Icon(Icons.clear, color: AppTheme.getSecondaryTextColor(context)),
              onPressed: () {
                _searchController.clear();
                setState(() {
                  _results = [];
                  _hasSearched = false;
                });
              },
            ),
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.search, color: Colors.white, size: 20),
            ),
            onPressed: () => _search(_searchController.text),
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
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

    if (_hasSearched) {
      if (_results.isEmpty) {
        return _buildEmptyResult();
      }
      return _buildSearchResults();
    }

    return _buildSuggestions();
  }

  Widget _buildSuggestions() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_recentSearches.isNotEmpty) ...[
            Row(
              children: [
                Icon(Icons.history, size: 20, color: AppTheme.getSecondaryTextColor(context)),
                const SizedBox(width: 8),
                const Text('Tìm kiếm gần đây', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const Spacer(),
                TextButton(
                  onPressed: () => setState(() => _recentSearches.clear()),
                  child: const Text('Xóa', style: TextStyle(color: AppTheme.secondaryColor)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _recentSearches.map((s) => _buildSearchChip(s, isRecent: true)).toList(),
            ),
            const SizedBox(height: 24),
          ],
          Row(
            children: [
              const Icon(Icons.trending_up, size: 20, color: AppTheme.primaryColor),
              const SizedBox(width: 8),
              const Text('Tìm kiếm phổ biến', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _popularSearches.map((s) => _buildSearchChip(s)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchChip(String text, {bool isRecent = false}) {
    return GestureDetector(
      onTap: () {
        _searchController.text = text;
        _search(text);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isRecent 
              ? (Theme.of(context).brightness == Brightness.dark ? const Color(0xFF2D2D2D) : Colors.grey[100]) 
              : AppTheme.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isRecent ? Theme.of(context).dividerColor : AppTheme.primaryColor.withOpacity(0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isRecent) ...[
              Icon(Icons.history, size: 16, color: AppTheme.getSecondaryTextColor(context)),
              const SizedBox(width: 6),
            ],
            Text(
              text,
              style: TextStyle(
                color: isRecent ? AppTheme.getSecondaryTextColor(context) : AppTheme.primaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyResult() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 80, color: AppTheme.getTertiaryTextColor(context)),
          const SizedBox(height: 16),
          Text(
            'Không tìm thấy sản phẩm',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.getSecondaryTextColor(context)),
          ),
          const SizedBox(height: 8),
          Text(
            'Thử tìm kiếm với từ khóa khác',
            style: TextStyle(color: AppTheme.getSecondaryTextColor(context)),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Tìm thấy ${_results.length} sản phẩm',
            style: TextStyle(fontWeight: FontWeight.w500, color: AppTheme.getSecondaryTextColor(context)),
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.68,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: _results.length,
            itemBuilder: (_, i) => AnimatedProductCard(product: _results[i], index: i),
          ),
        ),
      ],
    );
  }
}
