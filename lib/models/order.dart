import 'cart_item.dart';

class Order {
  final String id;
  final List<CartItem> items;
  final double subtotal;
  final double discount;
  final double shippingFee;
  final double total;
  final String shippingName;
  final String shippingPhone;
  final String shippingAddress;
  final String paymentMethod;
  final String status;
  final DateTime createdAt;
  final String? couponCode;

  Order({
    required this.id,
    required this.items,
    required this.subtotal,
    required this.discount,
    required this.shippingFee,
    required this.total,
    required this.shippingName,
    required this.shippingPhone,
    required this.shippingAddress,
    required this.paymentMethod,
    required this.status,
    required this.createdAt,
    this.couponCode,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id']?.toString() ?? '',
      items: (json['items'] as List?)?.map((e) => CartItem.fromJson(e)).toList() ?? [],
      subtotal: (json['subtotal'] ?? 0).toDouble(),
      discount: (json['discountAmount'] ?? json['discount'] ?? 0).toDouble(),
      shippingFee: (json['shippingFee'] ?? 0).toDouble(),
      total: (json['totalAmount'] ?? json['total'] ?? 0).toDouble(),
      shippingName: json['shippingName'] ?? '',
      shippingPhone: json['shippingPhone'] ?? '',
      shippingAddress: json['shippingAddress'] ?? '',
      paymentMethod: json['paymentMethod'] ?? '',
      status: json['status'] ?? '',
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
      couponCode: json['couponCode'],
    );
  }

  Order copyWith({
    String? id,
    List<CartItem>? items,
    double? subtotal,
    double? discount,
    double? shippingFee,
    double? total,
    String? shippingName,
    String? shippingPhone,
    String? shippingAddress,
    String? paymentMethod,
    String? status,
    DateTime? createdAt,
    String? couponCode,
  }) {
    return Order(
      id: id ?? this.id,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      discount: discount ?? this.discount,
      shippingFee: shippingFee ?? this.shippingFee,
      total: total ?? this.total,
      shippingName: shippingName ?? this.shippingName,
      shippingPhone: shippingPhone ?? this.shippingPhone,
      shippingAddress: shippingAddress ?? this.shippingAddress,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      couponCode: couponCode ?? this.couponCode,
    );
  }
}
