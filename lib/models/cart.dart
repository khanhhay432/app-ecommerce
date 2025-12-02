import 'cart_item.dart';

class Cart {
  final int id;
  final List<CartItem> items;
  final double totalAmount;
  final int totalItems;

  Cart({
    required this.id, 
    required this.items, 
    required this.totalAmount, 
    required this.totalItems,
  });

  factory Cart.fromJson(Map<String, dynamic> json) {
    return Cart(
      id: json['id'] ?? 0,
      items: (json['items'] as List?)?.map((e) => CartItem.fromJson(e)).toList() ?? [],
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
      totalItems: json['totalItems'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'items': items.map((e) => e.toJson()).toList(),
      'totalAmount': totalAmount,
      'totalItems': totalItems,
    };
  }
}
