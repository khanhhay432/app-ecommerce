class Review {
  final int id;
  final int productId;
  final int userId;
  final String userName;
  final String? userAvatar;
  final int rating;
  final String? comment;
  final List<String> images;
  final bool isVerifiedPurchase;
  final DateTime createdAt;

  Review({
    required this.id, required this.productId, required this.userId,
    required this.userName, this.userAvatar, required this.rating,
    this.comment, required this.images, required this.isVerifiedPurchase,
    required this.createdAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) => Review(
    id: json['id'], productId: json['productId'], userId: json['userId'],
    userName: json['userName'], userAvatar: json['userAvatar'],
    rating: json['rating'], comment: json['comment'],
    images: json['images'] != null ? List<String>.from(json['images']) : [],
    isVerifiedPurchase: json['isVerifiedPurchase'] ?? false,
    createdAt: DateTime.parse(json['createdAt']),
  );
}
