import 'product.dart';

class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});

  double get subtotal => product.price * quantity;

  factory CartItem.fromJson(Map<String, dynamic> json) {
    // Handle both formats: with nested product or flat structure
    if (json.containsKey('product')) {
      return CartItem(
        product: Product.fromJson(json['product']),
        quantity: json['quantity'] ?? 1,
      );
    } else {
      // Flat structure from backend CartItemDTO
      final price = json['price'] is num 
          ? (json['price'] as num).toDouble() 
          : double.tryParse(json['price'].toString()) ?? 0.0;
      final originalPrice = json['originalPrice'] is num 
          ? (json['originalPrice'] as num).toDouble() 
          : double.tryParse(json['originalPrice']?.toString() ?? '0') ?? price;
          
      return CartItem(
        product: Product(
          id: json['productId'] ?? 0,
          name: json['productName'] ?? '',
          price: price,
          originalPrice: originalPrice,
          imageUrl: json['productImage'],
          stockQuantity: json['stockQuantity'] ?? 0,
          soldQuantity: 0,
          isFeatured: false,
          categoryId: 0,
          categoryName: '',
          reviewCount: 0,
        ),
        quantity: json['quantity'] ?? 1,
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': product.id,
      'productName': product.name,
      'productImage': product.imageUrl,
      'price': product.price,
      'quantity': quantity,
      'subtotal': subtotal,
      'stockQuantity': product.stockQuantity,
    };
  }
}
