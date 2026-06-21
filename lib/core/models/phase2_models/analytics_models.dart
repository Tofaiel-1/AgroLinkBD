// Analytics Models for Phase 2

class AnalyticsPeriod {
  final String period; // daily, weekly, monthly, yearly
  final DateTime startDate;
  final DateTime endDate;

  AnalyticsPeriod({
    required this.period,
    required this.startDate,
    required this.endDate,
  });
}

class ChartData {
  final List<double> values;
  final List<String> labels;
  final String title;
  final String unit;

  ChartData({
    required this.values,
    required this.labels,
    required this.title,
    required this.unit,
  });
}

class AnalyticsCard {
  final String title;
  final String value;
  final String subtitle;
  final String trend; // up, down, stable
  final double changePercent;

  AnalyticsCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.trend,
    required this.changePercent,
  });
}

class FarmerAnalytics {
  final double totalSales;
  final double monthlyRevenue;
  final List<ChartData> salesTrend;
  final List<ChartData> productPerformance;
  final int totalOrders;
  final double avgRating;

  FarmerAnalytics({
    required this.totalSales,
    required this.monthlyRevenue,
    required this.salesTrend,
    required this.productPerformance,
    required this.totalOrders,
    required this.avgRating,
  });
}

class BuyerAnalytics {
  final double totalSpent;
  final int totalPurchases;
  final List<ChartData> spendingTrend;
  final List<ChartData> categoryBreakdown;
  final double avgOrderValue;
  final List<String> favoriteFarmers;

  BuyerAnalytics({
    required this.totalSpent,
    required this.totalPurchases,
    required this.spendingTrend,
    required this.categoryBreakdown,
    required this.avgOrderValue,
    required this.favoriteFarmers,
  });
}

class DriverAnalytics {
  final double totalEarnings;
  final int completedTrips;
  final List<ChartData> earningsTrend;
  final double avgRating;
  final double totalDistance;
  final double acceptanceRate;

  DriverAnalytics({
    required this.totalEarnings,
    required this.completedTrips,
    required this.earningsTrend,
    required this.avgRating,
    required this.totalDistance,
    required this.acceptanceRate,
  });
}

class ServiceProviderAnalytics {
  final double totalEarnings;
  final int completedBookings;
  final List<ChartData> bookingTrend;
  final double avgRating;
  final int totalReviews;
  final double completionRate;

  ServiceProviderAnalytics({
    required this.totalEarnings,
    required this.completedBookings,
    required this.bookingTrend,
    required this.avgRating,
    required this.totalReviews,
    required this.completionRate,
  });
}

class CompanyAnalytics {
  final double totalOrderValue;
  final int activeContracts;
  final List<ChartData> orderTrend;
  final List<ChartData> contractValue;
  final double budgetUsed;
  final List<String> topSuppliers;

  CompanyAnalytics({
    required this.totalOrderValue,
    required this.activeContracts,
    required this.orderTrend,
    required this.contractValue,
    required this.budgetUsed,
    required this.topSuppliers,
  });
}
