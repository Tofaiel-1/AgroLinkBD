import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:agrolinkbd/core/models/review_model.dart';

class ReviewProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final Map<String, List<ProductReview>> _productReviews = {};
  final Map<String, ProductRating> _productRatings = {};

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  Future<void> loadProductReviews(String productId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final querySnapshot = await _firestore
          .collection('product_reviews')
          .where('productId', isEqualTo: productId)
          .orderBy('createdAt', descending: true)
          .get();

      final reviews = querySnapshot.docs
          .map((doc) => ProductReview.fromJson(doc.data()))
          .toList();

      _productReviews[productId] = reviews;

      // Calculate rating
      final average = ProductRating.calculateAverage(reviews);
      final distribution = ProductRating.getStarDistribution(reviews);

      _productRatings[productId] = ProductRating(
        productId: productId,
        averageRating: average,
        totalReviews: reviews.length,
        ratingCounts: distribution,
      );

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading reviews: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addReview({
    required String productId,
    required String buyerId,
    required String buyerName,
    required double rating,
    required String comment,
  }) async {
    try {
      final review = ProductReview(
        id: '',
        productId: productId,
        buyerId: buyerId,
        buyerName: buyerName,
        rating: rating,
        comment: comment,
        createdAt: DateTime.now(),
      );

      await _firestore
          .collection('product_reviews')
          .add(review.toJson());

      // Reload reviews
      await loadProductReviews(productId);

      debugPrint('✅ Review added successfully');
    } catch (e) {
      debugPrint('❌ Error adding review: $e');
    }
  }

  List<ProductReview> getProductReviews(String productId) {
    return _productReviews[productId] ?? [];
  }

  ProductRating? getProductRating(String productId) {
    return _productRatings[productId];
  }

  double getAverageRating(String productId) {
    return _productRatings[productId]?.averageRating ?? 0;
  }

  int getTotalReviews(String productId) {
    return _productRatings[productId]?.totalReviews ?? 0;
  }
}
