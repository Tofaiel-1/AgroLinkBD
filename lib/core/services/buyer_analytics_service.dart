import 'package:cloud_firestore/cloud_firestore.dart';

class BuyerSpendingInsights {
  final double monthlySpend;
  final int totalOrders;
  final int activeOrders;
  final double averageOrderValue;
  final String topCategory;
  final int trustScore;
  final String trustTier;

  BuyerSpendingInsights({
    required this.monthlySpend,
    required this.totalOrders,
    required this.activeOrders,
    required this.averageOrderValue,
    required this.topCategory,
    required this.trustScore,
    required this.trustTier,
  });

  factory BuyerSpendingInsights.empty() {
    return BuyerSpendingInsights(
      monthlySpend: 0.0,
      totalOrders: 0,
      activeOrders: 0,
      averageOrderValue: 0.0,
      topCategory: '',
      trustScore: 75,
      trustTier: 'Silver',
    );
  }
}

class BuyerAnalyticsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<BuyerSpendingInsights> getSpendingInsightsStream(String uid) {
    if (uid.isEmpty) {
      return Stream.value(BuyerSpendingInsights.empty());
    }

    return _firestore
        .collection('orders')
        .where('buyerId', isEqualTo: uid)
        .snapshots()
        .map((snapshot) {
      final now = DateTime.now();
      double currentMonthSpend = 0.0;
      double totalSpend = 0.0;
      int completedOrdersCount = 0;
      int activeOrdersCount = 0;
      final Map<String, int> categoryCounts = {};

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final amount = (data['totalAmount'] as num?)?.toDouble() ?? 0.0;
        final status = (data['status'] as String? ?? '').toLowerCase();
        final category = (data['category'] as String? ?? '').toLowerCase();

        if (category.isNotEmpty) {
          categoryCounts[category] = (categoryCounts[category] ?? 0) + 1;
        }

        if (status == 'pending' ||
            status == 'processing' ||
            status == 'in_transit' ||
            status == 'shipped') {
          activeOrdersCount++;
        }

        if (status == 'completed' || status == 'delivered') {
          completedOrdersCount++;
          totalSpend += amount;

          final createdAt = (data['createdAt'] as Timestamp?)?.toDate();
          if (createdAt != null &&
              createdAt.year == now.year &&
              createdAt.month == now.month) {
            currentMonthSpend += amount;
          }
        }
      }

      // Top category calculation
      String topCategory = '';
      int maxCategoryCount = 0;
      categoryCounts.forEach((cat, count) {
        if (count > maxCategoryCount) {
          maxCategoryCount = count;
          topCategory = cat;
        }
      });

      final totalOrders = snapshot.docs.length;
      final avgOrder =
          completedOrdersCount > 0 ? (totalSpend / completedOrdersCount) : 0.0;

      // Trust Score Calculation: 70 base + points for completed orders
      int calculatedScore = 70 + (completedOrdersCount * 5);
      if (calculatedScore > 100) calculatedScore = 100;

      String tier = 'Bronze';
      if (calculatedScore >= 95) {
        tier = 'Platinum';
      } else if (calculatedScore >= 85) {
        tier = 'Gold';
      } else if (calculatedScore >= 75) {
        tier = 'Silver';
      }

      return BuyerSpendingInsights(
        monthlySpend: currentMonthSpend,
        totalOrders: totalOrders,
        activeOrders: activeOrdersCount,
        averageOrderValue: avgOrder,
        topCategory: topCategory,
        trustScore: calculatedScore,
        trustTier: tier,
      );
    });
  }
}
