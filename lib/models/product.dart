class Product {
  final int id;
  final String name;
  final String? description;
  final double price;
  final double? originalPrice;
  final int stockQuantity;
  final int soldQuantity;
  final String? imageUrl;
  final bool isFeatured;
  final int categoryId;
  final String categoryName;
  final double? averageRating;
  final int reviewCount;

  Product({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    this.originalPrice,
    required this.stockQuantity,
    required this.soldQuantity,
    this.imageUrl,
    required this.isFeatured,
    required this.categoryId,
    required this.categoryName,
    this.averageRating,
    required this.reviewCount,
  });

  int? get discountPercent {
    if (originalPrice != null && originalPrice! > price) {
      return ((originalPrice! - price) / originalPrice! * 100).round();
    }
    return null;
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'],
      price: (json['price'] ?? 0).toDouble(),
      originalPrice: json['originalPrice']?.toDouble(),
      stockQuantity: json['stockQuantity'] ?? 0,
      soldQuantity: json['soldQuantity'] ?? 0,
      imageUrl: json['imageUrl'],
      isFeatured: json['isFeatured'] ?? false,
      categoryId: json['categoryId'] ?? 0,
      categoryName: json['categoryName'] ?? '',
      averageRating: json['averageRating']?.toDouble(),
      reviewCount: json['reviewCount'] ?? 0,
    );
  }
}
