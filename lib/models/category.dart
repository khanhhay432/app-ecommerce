class Category {
  final int id;
  final String name;
  final String? description;
  final String? imageUrl;
  final int? parentId;
  final int productCount;

  Category({
    required this.id,
    required this.name,
    this.description,
    this.imageUrl,
    this.parentId,
    this.productCount = 0,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'],
      imageUrl: json['imageUrl'],
      parentId: json['parentId'],
      productCount: json['productCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'parentId': parentId,
      'productCount': productCount,
    };
  }
}
