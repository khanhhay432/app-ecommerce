import 'package:flutter/material.dart';
import '../models/product.dart';
import '../models/category.dart';
import '../data/mock_data.dart';

class ProductProvider with ChangeNotifier {
  List<Product> _products = [];
  List<Product> _featuredProducts = [];
  List<Category> _categories = [];
  List<int> _wishlist = [];
  bool _isLoading = false;

  List<Product> get products => _products;
  List<Product> get featuredProducts => _featuredProducts;
  List<Category> get categories => _categories;
  List<int> get wishlist => _wishlist;
  bool get isLoading => _isLoading;

  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();
    
    await Future.delayed(const Duration(milliseconds: 800)); // Simulate loading
    _products = MockData.products;
    _featuredProducts = MockData.products.where((p) => p.isFeatured).toList();
    _categories = MockData.categories;
    
    _isLoading = false;
    notifyListeners();
  }

  List<Product> getProductsByCategory(int categoryId) {
    return _products.where((p) => p.categoryId == categoryId).toList();
  }

  List<Product> searchProducts(String query) {
    return _products.where((p) => 
      p.name.toLowerCase().contains(query.toLowerCase()) ||
      p.description!.toLowerCase().contains(query.toLowerCase())
    ).toList();
  }

  Product? getProductById(int id) {
    try {
      return _products.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  void toggleWishlist(int productId) {
    if (_wishlist.contains(productId)) {
      _wishlist.remove(productId);
    } else {
      _wishlist.add(productId);
    }
    notifyListeners();
  }

  bool isInWishlist(int productId) => _wishlist.contains(productId);

  List<Product> get wishlistProducts => 
    _products.where((p) => _wishlist.contains(p.id)).toList();
}
