class Category {
  final int id;
  final String name;
  final String? description;
  final String? imageUrl;
  final int? parentId;

  Category({
    required this.id,
    required this.name,
    this.description,
    this.imageUrl,
    this.parentId,
  });
}
