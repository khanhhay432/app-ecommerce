class Analytics {
  final double totalRevenue;
  final int totalOrders;
  final int totalProducts;
  final int totalCustomers;
  final double revenueGrowth;
  final double ordersGrowth;
  final List<RevenueDataPoint> revenueChart;
  final Map<String, int> ordersByStatus;
  final List<TopProduct> topProducts;

  Analytics({
    required this.totalRevenue,
    required this.totalOrders,
    required this.totalProducts,
    required this.totalCustomers,
    required this.revenueGrowth,
    required this.ordersGrowth,
    required this.revenueChart,
    required this.ordersByStatus,
    required this.topProducts,
  });

  factory Analytics.fromJson(Map<String, dynamic> json) {
    return Analytics(
      totalRevenue: (json['totalRevenue'] as num?)?.toDouble() ?? 0.0,
      totalOrders: json['totalOrders'] as int? ?? 0,
      totalProducts: json['totalProducts'] as int? ?? 0,
      totalCustomers: json['totalCustomers'] as int? ?? 0,
      revenueGrowth: (json['revenueGrowth'] as num?)?.toDouble() ?? 0.0,
      ordersGrowth: (json['ordersGrowth'] as num?)?.toDouble() ?? 0.0,
      revenueChart: (json['revenueChart'] as List?)
              ?.map((e) => RevenueDataPoint.fromJson(e))
              .toList() ??
          [],
      ordersByStatus: Map<String, int>.from(json['ordersByStatus'] ?? {}),
      topProducts: (json['topProducts'] as List?)
              ?.map((e) => TopProduct.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class RevenueDataPoint {
  final String label;
  final double value;

  RevenueDataPoint({required this.label, required this.value});

  factory RevenueDataPoint.fromJson(Map<String, dynamic> json) {
    return RevenueDataPoint(
      label: json['label'] as String? ?? '',
      value: (json['value'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class TopProduct {
  final int id;
  final String name;
  final String? imageUrl;
  final double price;
  final int soldQuantity;
  final double revenue;

  TopProduct({
    required this.id,
    required this.name,
    this.imageUrl,
    required this.price,
    required this.soldQuantity,
    required this.revenue,
  });

  factory TopProduct.fromJson(Map<String, dynamic> json) {
    return TopProduct(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      imageUrl: json['imageUrl'] as String?,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      soldQuantity: json['soldQuantity'] as int? ?? 0,
      revenue: (json['revenue'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
