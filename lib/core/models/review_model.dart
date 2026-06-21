class ProductReview {
  final String id;
  final String productId;
  final String buyerId;
  final String buyerName;
  final double rating;
  final String comment;
  final DateTime createdAt;
  final int helpful;

  ProductReview({
    required this.id,
    required this.productId,
    required this.buyerId,
    required this.buyerName,
    required this.rating,
    required this.comment,
    required this.createdAt,
    this.helpful = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'buyerId': buyerId,
      'buyerName': buyerName,
      'rating': rating,
      'comment': comment,
      'createdAt': createdAt.toIso8601String(),
      'helpful': helpful,
    };
  }

  factory ProductReview.fromJson(Map<String, dynamic> json) {
    return ProductReview(
      id: json['id'],
      productId: json['productId'],
      buyerId: json['buyerId'],
      buyerName: json['buyerName'],
      rating: (json['rating'] as num).toDouble(),
      comment: json['comment'],
      createdAt: DateTime.parse(json['createdAt']),
      helpful: json['helpful'] ?? 0,
    );
  }
}

class ProductRating {
  final String productId;
  final double averageRating;
  final int totalReviews;
  final Map<int, int> ratingCounts;

  ProductRating({
    required this.productId,
    required this.averageRating,
    required this.totalReviews,
    required this.ratingCounts,
  });

  // Calculate average from reviews
  static double calculateAverage(List<ProductReview> reviews) {
    if (reviews.isEmpty) return 0;
    final sum = reviews.fold<double>(0, (sum, review) => sum + review.rating);
    return sum / reviews.length;
  }

  // Get star distribution
  static Map<int, int> getStarDistribution(List<ProductReview> reviews) {
    final distribution = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
    for (var review in reviews) {
      final stars = review.rating.round();
      distribution[stars] = (distribution[stars] ?? 0) + 1;
    }
    return distribution;
  }

  String getRatingText() {
    if (averageRating >= 4.5) return 'Excellent';
    if (averageRating >= 4) return 'Very Good';
    if (averageRating >= 3) return 'Good';
    if (averageRating >= 2) return 'Fair';
    return 'Poor';
  }
}
