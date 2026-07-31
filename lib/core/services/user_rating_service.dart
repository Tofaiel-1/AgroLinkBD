import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UserRatingReview {
  final String id;
  final String reviewerId;
  final String reviewerName;
  final double farmerRating; // খামারি রেটিং (1-5)
  final double paymentScore; // পেমেন্ট সম্পূর্ণ করার রেটিং (1-5)
  final double transportScore; // ট্রান্সপোর্ট ও রিসিভ করার রেটিং (1-5)
  final String? comment;
  final DateTime createdAt;

  UserRatingReview({
    required this.id,
    required this.reviewerId,
    required this.reviewerName,
    required this.farmerRating,
    required this.paymentScore,
    required this.transportScore,
    this.comment,
    required this.createdAt,
  });

  double get overallScore => (farmerRating + paymentScore + transportScore) / 3.0;

  Map<String, dynamic> toMap() {
    return {
      'reviewerId': reviewerId,
      'reviewerName': reviewerName,
      'farmerRating': farmerRating,
      'paymentScore': paymentScore,
      'transportScore': transportScore,
      'overallScore': overallScore,
      'comment': comment,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory UserRatingReview.fromMap(String id, Map<String, dynamic> map) {
    return UserRatingReview(
      id: id,
      reviewerId: map['reviewerId'] ?? '',
      reviewerName: map['reviewerName'] ?? 'Anonymous',
      farmerRating: (map['farmerRating'] ?? 0.0).toDouble(),
      paymentScore: (map['paymentScore'] ?? 0.0).toDouble(),
      transportScore: (map['transportScore'] ?? 0.0).toDouble(),
      comment: map['comment'],
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

class UserRatingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Submit a multi-criteria review for a user and automatically update their aggregate Firebase scores
  Future<void> submitUserRating({
    required String targetUserId,
    required String reviewerId,
    required String reviewerName,
    required double farmerRating,
    required double paymentScore,
    required double transportScore,
    String? comment,
  }) async {
    try {
      final ratingsRef = _firestore
          .collection('users')
          .doc(targetUserId)
          .collection('ratings');

      final newReview = UserRatingReview(
        id: '',
        reviewerId: reviewerId,
        reviewerName: reviewerName,
        farmerRating: farmerRating,
        paymentScore: paymentScore,
        transportScore: transportScore,
        comment: comment,
        createdAt: DateTime.now(),
      );

      await ratingsRef.add(newReview.toMap());

      // Recalculate average scores across all reviews in Firestore
      final snapshot = await ratingsRef.get();
      if (snapshot.docs.isNotEmpty) {
        double sumFarmer = 0.0;
        double sumPayment = 0.0;
        double sumTransport = 0.0;
        double sumOverall = 0.0;

        for (var doc in snapshot.docs) {
          final data = doc.data();
          final r = (data['farmerRating'] ?? 0.0).toDouble();
          final p = (data['paymentScore'] ?? 0.0).toDouble();
          final t = (data['transportScore'] ?? 0.0).toDouble();
          sumFarmer += r;
          sumPayment += p;
          sumTransport += t;
          sumOverall += (r + p + t) / 3.0;
        }

        final count = snapshot.docs.length;
        final avgFarmer = sumFarmer / count;
        final avgPayment = sumPayment / count;
        final avgTransport = sumTransport / count;
        final avgOverall = sumOverall / count;

        await _firestore.collection('users').doc(targetUserId).update({
          'farmerRating': double.parse(avgFarmer.toStringAsFixed(1)),
          'paymentScore': double.parse(avgPayment.toStringAsFixed(1)),
          'transportScore': double.parse(avgTransport.toStringAsFixed(1)),
          'rating': double.parse(avgOverall.toStringAsFixed(1)),
          'totalRatings': count,
        });
      }
    } catch (e) {
      debugPrint('Error submitting user rating: $e');
    }
  }

  // Helper method to record completed purchase & spent amount in Firestore
  Future<void> recordCompletedPurchase(String userId, double spentAmount) async {
    try {
      final docRef = _firestore.collection('users').doc(userId);
      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(docRef);
        if (snapshot.exists) {
          final currentOrders = snapshot.data()?['totalOrders'] ?? 0;
          final currentSpent = (snapshot.data()?['totalSpent'] ?? 0.0).toDouble();
          transaction.update(docRef, {
            'totalOrders': currentOrders + 1,
            'totalSpent': currentSpent + spentAmount,
          });
        }
      });
    } catch (e) {
      debugPrint('Error recording completed purchase: $e');
    }
  }

  // Show a beautiful interactive modal dialog for rating any buyer / user across the 3 criteria
  static void showRateUserDialog({
    required BuildContext context,
    required String targetUserId,
    required String targetUserName,
    required String reviewerId,
    required String reviewerName,
    required VoidCallback onRatingSubmitted,
  }) {
    double farmerRating = 5.0;
    double paymentScore = 5.0;
    double transportScore = 5.0;
    final TextEditingController commentController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              '$targetUserName-কে মূল্যায়ন করুন',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'মাছ খামারিদের দেওয়া রেটিং (Farmer Rating):',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(
                          index < farmerRating
                              ? Icons.star
                              : Icons.star_border,
                          color: Colors.amber,
                          size: 30,
                        ),
                        onPressed: () {
                          setState(() {
                            farmerRating = (index + 1).toDouble();
                          });
                        },
                      );
                    }),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'পেমেন্ট সম্পূর্ণ করার রেটিং (Payment Score):',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(
                          index < paymentScore
                              ? Icons.star
                              : Icons.star_border,
                          color: Colors.amber,
                          size: 30,
                        ),
                        onPressed: () {
                          setState(() {
                            paymentScore = (index + 1).toDouble();
                          });
                        },
                      );
                    }),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'ট্রান্সপোর্ট ও রিসিভ রেটিং (Transport & Delivery):',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(
                          index < transportScore
                              ? Icons.star
                              : Icons.star_border,
                          color: Colors.amber,
                          size: 30,
                        ),
                        onPressed: () {
                          setState(() {
                            transportScore = (index + 1).toDouble();
                          });
                        },
                      );
                    }),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: commentController,
                    decoration: InputDecoration(
                      labelText: 'মতামত বা রিভিউ (ঐচ্ছিক)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    maxLines: 2,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('বাতিল'),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(dialogContext);
                  await UserRatingService().submitUserRating(
                    targetUserId: targetUserId,
                    reviewerId: reviewerId,
                    reviewerName: reviewerName,
                    farmerRating: farmerRating,
                    paymentScore: paymentScore,
                    transportScore: transportScore,
                    comment: commentController.text.trim(),
                  );
                  onRatingSubmitted();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('মূল্যায়ন সফলভাবে সেভ করা হয়েছে!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                },
                child: const Text('সাবমিট করুন'),
              ),
            ],
          );
        },
      ),
    );
  }
}
