class CartItem {
  final int id;
  final int productId;
  final String productName;
  final String? productImage;
  final double price;
  final int quantity;
  final double subtotal;
  final int stockQuantity;

  CartItem({
    required this.id,
    required this.productId,
    required this.productName,
    this.productImage,
    required this.price,
    required this.quantity,
    required this.subtotal,
    required this.stockQuantity,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'],
      productId: json['productId'],
      productName: json['productName'],
      productImage: json['productImage'],
      price: (json['price'] as num).toDouble(),
      quantity: json['quantity'],
      subtotal: (json['subtotal'] as num).toDouble(),
      stockQuantity: json['stockQuantity'] ?? 0,
    );
  }
}

class Cart {
  final int id;
  final List<CartItem> items;
  final double totalAmount;
  final int totalItems;

  Cart({required this.id, required this.items, required this.totalAmount, required this.totalItems});

  factory Cart.fromJson(Map<String, dynamic> json) {
    return Cart(
      id: json['id'],
      items: (json['items'] as List).map((e) => CartItem.fromJson(e)).toList(),
      totalAmount: (json['totalAmount'] as num).toDouble(),
      totalItems: json['totalItems'] ?? 0,
    );
  }
}
