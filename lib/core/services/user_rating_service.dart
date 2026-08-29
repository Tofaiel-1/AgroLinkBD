import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:agrolinkbd/core/models/user_model.dart';

class UserRatingReview {
  final String id;
  final String reviewerId;
  final String reviewerName;
  final double farmerRating; // পণ্যের মান / দক্ষতা রেটিং (1-5)
  final double paymentScore; // পেমেন্ট ও লেনদেন নির্ভরযোগ্যতা (1-5)
  final double transportScore; // সময়নিষ্ঠতা ও পেশাদার আচরণ (1-5)
  final String? comment;
  final String? workType; // 'order', 'transport', 'service', 'contract'
  final String? workReference;
  final DateTime createdAt;

  UserRatingReview({
    required this.id,
    required this.reviewerId,
    required this.reviewerName,
    required this.farmerRating,
    required this.paymentScore,
    required this.transportScore,
    this.comment,
    this.workType,
    this.workReference,
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
      'workType': workType ?? 'order',
      'workReference': workReference ?? 'TRD-VERIFIED',
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
      workType: map['workType'] ?? 'order',
      workReference: map['workReference'],
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

class UserRatingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Calculate 0–100% Universal Trust Score dynamically combining:
  // Peer reviews (50 max) + Payment booster (15 max) + App Tenure (15 max) + Trade Volume (20 max) - Fraud penalties
  static double calculateTrustScore(UserModel user) {
    double peerPoints = (user.totalRatings > 0 ? (user.rating / 5.0) * 50.0 : 50.0);
    double paymentPoints = (user.totalOrders * 1.5).clamp(0.0, 15.0);
    double tenureMonths = DateTime.now().difference(user.createdAt).inDays / 30.0;
    double tenurePoints = (tenureMonths * 2.0 + 5.0).clamp(0.0, 15.0);
    double volumePoints = (user.totalOrders * 2.0).clamp(0.0, 20.0);

    double fraudPenalty = user.fraudReports * 15.0;
    double cancelPenalty = user.cancelledOrders * 5.0;
    double defaultPenalty = user.paymentDefaults * 10.0;
    double latePenalty = user.lateDeliveries * 3.0;

    double score = peerPoints +
        paymentPoints +
        tenurePoints +
        volumePoints -
        (fraudPenalty + cancelPenalty + defaultPenalty + latePenalty);
    return score.clamp(0.0, 100.0);
  }

  // Submit a multi-criteria review for a user and automatically update their aggregate Firebase scores & trust score
  Future<void> submitUserRating({
    required String targetUserId,
    required String reviewerId,
    required String reviewerName,
    required double farmerRating,
    required double paymentScore,
    required double transportScore,
    String? comment,
    String? workType,
    String? workReference,
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
        workType: workType ?? 'order',
        workReference: workReference ?? 'TRD-VERIFIED-${DateTime.now().millisecondsSinceEpoch}',
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

  // Submit a dispute/fraud report against another user to Super Admin for review
  Future<bool> submitUserDisputeReport({
    required String targetUserId,
    required String targetUserName,
    String? targetUserRole,
    String? targetUserPhone,
    required String reporterId,
    required String reporterName,
    String? reporterRole,
    String? reporterPhone,
    required int penaltyType, // 1=fake weight/quality, 2=cancel/breach, 3=payment default, 4=late/no-show, 5=misbehavior, 6=other
    required String category,
    required String reason,
    String? orderReference,
  }) async {
    try {
      if (reporterId.isNotEmpty && targetUserId.isNotEmpty && reporterId == targetUserId) {
        debugPrint('Cannot report self!');
        return false;
      }

      final reportRef = _firestore.collection('user_reports').doc();
      final reportData = {
        'id': reportRef.id,
        'targetUserId': targetUserId,
        'targetUserName': targetUserName,
        'targetUserRole': targetUserRole ?? 'User',
        'targetUserPhone': targetUserPhone ?? '',
        'reporterId': reporterId,
        'reporterName': reporterName,
        'reporterRole': reporterRole ?? 'User',
        'reporterPhone': reporterPhone ?? '',
        'penaltyType': penaltyType,
        'category': category,
        'reason': reason,
        'orderReference': orderReference ?? 'N/A',
        'status': 'pending', // 'pending', 'action_taken', 'dismissed'
        'adminNotes': '',
        'penaltyDeducted': 0,
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      };

      await reportRef.set(reportData);
      return true;
    } catch (e) {
      debugPrint('Error submitting user dispute report: $e');
      return false;
    }
  }

  // Super Admin action: Approve penalty on target user and deduct trust points
  Future<bool> resolveDisputeAndApplyPenalty({
    required String reportId,
    required String targetUserId,
    required int penaltyType,
    required String adminNotes,
    required String adminId,
    required String adminName,
  }) async {
    try {
      final userRef = _firestore.collection('users').doc(targetUserId);
      final reportRef = _firestore.collection('user_reports').doc(reportId);

      // Record in target user's penalties subcollection for audit history
      await userRef.collection('penalties').add({
        'reportId': reportId,
        'penaltyType': penaltyType,
        'adminNotes': adminNotes,
        'approvedBy': adminName,
        'approvedById': adminId,
        'createdAt': DateTime.now().toIso8601String(),
      });

      // Update user penalty statistics
      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(userRef);
        if (snapshot.exists) {
          final data = snapshot.data() ?? {};
          int fraudReports = data['fraudReports'] ?? 0;
          int cancelledOrders = data['cancelledOrders'] ?? 0;
          int paymentDefaults = data['paymentDefaults'] ?? 0;
          int lateDeliveries = data['lateDeliveries'] ?? 0;

          if (penaltyType == 1 || penaltyType == 5 || penaltyType == 6) {
            fraudReports += 1;
          } else if (penaltyType == 2) {
            cancelledOrders += 1;
          } else if (penaltyType == 3) {
            paymentDefaults += 1;
          } else if (penaltyType == 4) {
            lateDeliveries += 1;
          }

          transaction.update(userRef, {
            'fraudReports': fraudReports,
            'cancelledOrders': cancelledOrders,
            'paymentDefaults': paymentDefaults,
            'lateDeliveries': lateDeliveries,
          });
        }
      });

      // Update report status in user_reports
      await reportRef.update({
        'status': 'action_taken',
        'adminNotes': adminNotes,
        'resolvedBy': adminName,
        'resolvedById': adminId,
        'resolvedAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      });

      return true;
    } catch (e) {
      debugPrint('Error applying admin penalty: $e');
      return false;
    }
  }

  // Super Admin action: Dismiss/Reject report as baseless or resolved without penalty
  Future<bool> dismissDispute({
    required String reportId,
    required String adminNotes,
    required String adminId,
    required String adminName,
  }) async {
    try {
      final reportRef = _firestore.collection('user_reports').doc(reportId);
      await reportRef.update({
        'status': 'dismissed',
        'adminNotes': adminNotes,
        'resolvedBy': adminName,
        'resolvedById': adminId,
        'resolvedAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (e) {
      debugPrint('Error dismissing dispute report: $e');
      return false;
    }
  }

  // Super Admin action: Toggle Ban/Suspend User
  Future<bool> toggleUserBan({
    required String targetUserId,
    required bool isBanned,
    required String reason,
    required String adminName,
  }) async {
    try {
      await _firestore.collection('users').doc(targetUserId).update({
        'isBanned': isBanned,
        'banReason': isBanned ? reason : '',
        'bannedAt': isBanned ? DateTime.now().toIso8601String() : null,
      });
      return true;
    } catch (e) {
      debugPrint('Error toggling user ban: $e');
      return false;
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

  // Matrix verification helper: Who can rate whom
  static bool canUserRate({
    required String reviewerId,
    required String targetUserId,
    String? reviewerRole,
    String? targetUserRole,
  }) {
    // 1. Cannot rate yourself
    if (reviewerId.isNotEmpty && targetUserId.isNotEmpty && reviewerId == targetUserId) {
      return false;
    }

    if (reviewerRole == null || targetUserRole == null || reviewerRole.isEmpty || targetUserRole.isEmpty) {
      return true; // fallback if roles are not explicitly passed
    }

    final String rev = _normalizeRole(reviewerRole);
    final String tar = _normalizeRole(targetUserRole);

    // 2. "same user ekjon onno jonke dite parbe na" -> Same role cannot rate same role
    if (rev == tar) {
      return false;
    }

    // 3. Exact user matrix:
    // rating farmer theke pabe = buyer, service provider, driver, company
    // rating fish farmer theke pabe = fish buyer, service provider, driver, company
    // service provider theke pabe = farmer, fish farmer
    // driver theke pabe = buyer, fish buyer, service provider, company
    // company theke pabe = farmer, fish farmer, service provider
    switch (rev) {
      case 'farmer':
        return ['buyer', 'serviceprovider', 'driver', 'company'].contains(tar);
      case 'fishfarmer':
        return ['fishbuyer', 'serviceprovider', 'driver', 'company'].contains(tar);
      case 'serviceprovider':
        return ['farmer', 'fishfarmer'].contains(tar);
      case 'driver':
        return ['buyer', 'fishbuyer', 'serviceprovider', 'company'].contains(tar);
      case 'company':
        return ['farmer', 'fishfarmer', 'serviceprovider'].contains(tar);
      case 'buyer':
        return ['farmer', 'driver', 'serviceprovider', 'company'].contains(tar);
      case 'fishbuyer':
        return ['fishfarmer', 'driver', 'serviceprovider', 'company'].contains(tar);
      default:
        return true;
    }
  }

  static String _normalizeRole(String role) {
    return role.toLowerCase().replaceAll(' ', '').replaceAll('_', '').replaceAll('-', '');
  }

  // Show Universal 360° Cross-Role Rating Modal (supports any role combination with matrix enforcement)
  static void showUniversalRateModal({
    required BuildContext context,
    required String targetUserId,
    required String targetUserName,
    required String reviewerId,
    required String reviewerName,
    String? reviewerRole,
    String? targetUserRole,
    required VoidCallback onRatingSubmitted,
  }) {
    // Check rating permission rules first
    if (reviewerId == targetUserId && reviewerId.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ আপনি নিজেকে রেটিং দিতে পারবেন না!'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }
    if (reviewerRole != null &&
        targetUserRole != null &&
        reviewerRole.isNotEmpty &&
        targetUserRole.isNotEmpty &&
        _normalizeRole(reviewerRole) == _normalizeRole(targetUserRole)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ একই পেশার বা রোলের ব্যবহারকারী একে অপরকে রেটিং দিতে পারবেন না!'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }
    if (!canUserRate(
      reviewerId: reviewerId,
      targetUserId: targetUserId,
      reviewerRole: reviewerRole,
      targetUserRole: targetUserRole,
    )) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ আপনার রোল থেকে এই ব্যবহারকারীকে রেটিং দেওয়ার অনুমতি নেই!'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    double farmerRating = 5.0;
    double paymentScore = 5.0;
    double transportScore = 5.0;
    final TextEditingController commentController = TextEditingController();

    final List<Map<String, String>> workTypes = [
      {'id': 'order', 'label': '📦 মাছ/পণ্য ক্রয়-বিক্রয় লেনদেন (Order / Trade)'},
      {'id': 'transport', 'label': '🚚 মাছ/পণ্য পরিবহন ও ডেলিভারি (Trip)'},
      {'id': 'service', 'label': '⚙️ কৃষি/মৎস্য সেবা বা যন্ত্রাংশ ভাড়া (Service)'},
      {'id': 'contract', 'label': '🤝 চুক্তিবদ্ধ সাপ্লাই ও বাল্ক ক্রয় (Contract)'},
    ];
    String selectedWorkType = 'order';

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
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
            ),
            content: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 450),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green, width: 1),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.verified, color: Colors.green, size: 18),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '১০০% ভেরিফাইড কাজের মূল্যায়ন (কোনো ভিত্তিহীন রেটিং গ্রহণযোগ্য নয়)',
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.green),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'সম্পন্ন কাজের ধরন নির্বাচন করুন (বাধ্যতামূলক):',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    value: selectedWorkType,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                    ),
                    items: workTypes.map((item) {
                      return DropdownMenuItem<String>(
                        value: item['id']!,
                        child: Text(
                          item['label']!,
                          style: const TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          selectedWorkType = val;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'পণ্যের মান ও সেবার দক্ষতা (Quality / Expertise):',
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
                          size: 28,
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
                    'পেমেন্ট ও লেনদেনের নির্ভরযোগ্যতা (Payment Score):',
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
                          size: 28,
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
                    'সময়নিষ্ঠতা ও পেশাদার আচরণ (Punctuality & Behavior):',
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
                          size: 28,
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
                    workType: selectedWorkType,
                    workReference: 'TRD-$selectedWorkType-${DateTime.now().millisecondsSinceEpoch}',
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

  // Backward compatibility wrapper
  static void showRateUserDialog({
    required BuildContext context,
    required String targetUserId,
    required String targetUserName,
    required String reviewerId,
    required String reviewerName,
    required VoidCallback onRatingSubmitted,
  }) {
    showUniversalRateModal(
      context: context,
      targetUserId: targetUserId,
      targetUserName: targetUserName,
      reviewerId: reviewerId,
      reviewerName: reviewerName,
      onRatingSubmitted: onRatingSubmitted,
    );
  }

  // Show Fraud & Penalty Deduction Modal - Submits dispute to Super Admin for verification and penalty action
  static void showFraudPenaltyDialog({
    required BuildContext context,
    required String targetUserId,
    required String targetUserName,
    String? targetUserRole,
    String? targetUserPhone,
    required String reporterId,
    required String reporterName,
    String? reporterRole,
    String? reporterPhone,
    String? orderReference,
    required VoidCallback onPenaltySubmitted,
  }) {
    if (reporterId.isNotEmpty && targetUserId.isNotEmpty && reporterId == targetUserId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ আপনি নিজের বিরুদ্ধে রিপোর্ট বা জরিমানা আবেদন করতে পারবেন না!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    int selectedPenaltyType = 1;
    final TextEditingController reasonController = TextEditingController();
    final TextEditingController orderRefController = TextEditingController(text: orderReference ?? '');

    final List<Map<String, dynamic>> penaltyOptions = [
      {
        'id': 1,
        'category': 'ভুয়া ওজন বা নিম্নমানের পণ্য (Quality/Weight Fraud)',
        'label': '🚫 ভুয়া ওজন বা নিম্নমানের পণ্য (Quality/Weight Fraud)',
        'deduction': '-১৫ পয়েন্ট',
      },
      {
        'id': 2,
        'category': 'অর্ডার বাতিল বা গ্রহণ না করা (Breach/Cancellation)',
        'label': '❌ অর্ডার নিশ্চিত করার পর বাতিল বা পণ্য গ্রহণ না করা',
        'deduction': '-৫ পয়েন্ট',
      },
      {
        'id': 3,
        'category': 'পেমেন্ট বকেয়া বা প্রতারণা (Payment Default/Scam)',
        'label': '💸 পেমেন্ট বকেয়া বা লেনদেনে প্রতারণা (Payment Default)',
        'deduction': '-১০ পয়েন্ট',
      },
      {
        'id': 4,
        'category': 'ডেলিভারি বিলম্ব বা নো-শো (Delivery/Trip Failure)',
        'label': '⏰ নির্ধারিত সময়ে উপস্থিত না হওয়া বা ট্রিপ ড্রপ (No-Show)',
        'deduction': '-৫ পয়েন্ট',
      },
      {
        'id': 5,
        'category': 'অসদাচরণ বা ভুয়া তথ্য (Harassment/Misbehavior)',
        'label': '⚠️ অসদাচরণ, ভুয়া তথ্য বা দুর্ব্যবহার (Misbehavior)',
        'deduction': '-১০ পয়েন্ট',
      },
      {
        'id': 6,
        'category': 'অন্যান্য চুক্তিভঙ্গ বা অনিয়ম (Other Policy Violation)',
        'label': '📑 অন্যান্য চুক্তিভঙ্গ বা গুরুতর অনিয়ম',
        'deduction': '-৫ থেকে -১৫ পয়েন্ট',
      },
    ];

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) {
          final selectedOption = penaltyOptions.firstWhere(
            (o) => o['id'] == selectedPenaltyType,
            orElse: () => penaltyOptions.first,
          );

          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                const Icon(Icons.gavel_rounded, color: Colors.red, size: 22),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '$targetUserName-এর বিরুদ্ধে অভিযোগ / রিপোর্ট',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.red),
                  ),
                ),
              ],
            ),
            content: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.amber.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.amber.shade700, width: 1),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.admin_panel_settings, color: Colors.amber, size: 20),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'অভিযোগটি যাচাইয়ের জন্য সুপার অ্যাডমিনের কাছে পাঠানো হবে। প্রমাণিত হলে অভিযুক্ত ব্যবহারকারীর ট্রাস্ট স্কোর কর্তন ও প্রয়োজনীয় ব্যবস্থা নেওয়া হবে।',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.black87),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'সুনির্দিষ্ট কারণ নির্বাচন করুন (বাধ্যতামূলক):',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                    const SizedBox(height: 8),
                    ...penaltyOptions.map((option) {
                      return RadioListTile<int>(
                        title: Text(
                          option['label'],
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                        ),
                        subtitle: Text(
                          'প্রস্তাবিত কর্তন: ${option['deduction']}',
                          style: const TextStyle(color: Colors.red, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                        value: option['id'] as int,
                        groupValue: selectedPenaltyType,
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              selectedPenaltyType = val;
                            });
                          }
                        },
                      );
                    }),
                    const SizedBox(height: 10),
                    TextField(
                      controller: orderRefController,
                      decoration: InputDecoration(
                        labelText: 'অর্ডার / ট্রিপ / রেফারেন্স নম্বর (যদি থাকে)',
                        hintText: 'যেমন: ORD-1024 / TRP-502',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: reasonController,
                      decoration: InputDecoration(
                        labelText: 'অভিযোগের বিস্তারিত বিবরণ ও প্রমাণ (বাধ্যতামূলক)',
                        hintText: 'ঘটনাটি কখন ঘটেছে এবং কী অনিয়ম হয়েছে বিস্তারিত লিখুন...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('বাতিল'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                onPressed: () async {
                  final reasonText = reasonController.text.trim();
                  if (reasonText.isEmpty || reasonText.length < 5) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('অনুগ্রহ করে অভিযোগের বিস্তারিত বিবরণ লিখুন (কমপক্ষে ৫ অক্ষর)!'),
                        backgroundColor: Colors.orange,
                      ),
                    );
                    return;
                  }

                  Navigator.pop(dialogContext);
                  final success = await UserRatingService().submitUserDisputeReport(
                    targetUserId: targetUserId,
                    targetUserName: targetUserName,
                    targetUserRole: targetUserRole,
                    targetUserPhone: targetUserPhone,
                    reporterId: reporterId,
                    reporterName: reporterName,
                    reporterRole: reporterRole,
                    reporterPhone: reporterPhone,
                    penaltyType: selectedPenaltyType,
                    category: selectedOption['category'] ?? 'General Dispute',
                    reason: reasonText,
                    orderReference: orderRefController.text.trim(),
                  );

                  if (success) {
                    onPenaltySubmitted();
                    if (context.mounted) {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          title: const Row(
                            children: [
                              Icon(Icons.check_circle, color: Colors.green),
                              SizedBox(width: 8),
                              Text('অভিযোগ দাখিল সফল'),
                            ],
                          ),
                          content: const Text(
                            'আপনার অভিযোগটি সফলভাবে সুপার অ্যাডমিনের পর্যালোচনায় জমা হয়েছে। সুপার অ্যাডমিন তথ্য যাচাই করে অভিযুক্ত ব্যবহারকারীর বিরুদ্ধে ব্যবস্থা গ্রহণ করবেন।',
                            style: TextStyle(fontSize: 13),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text('ঠিক আছে'),
                            ),
                          ],
                        ),
                      );
                    }
                  } else {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('অভিযোগ দাখিল করা সম্ভব হয়নি। পুনরায় চেষ্টা করুন।'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
                child: const Text('সুপার অ্যাডমিনে রিপোর্ট পাঠান'),
              ),
            ],
          );
        },
      ),
    );
  }
}
