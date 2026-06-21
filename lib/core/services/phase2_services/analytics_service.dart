import 'package:agrolinkbd/core/models/phase2_models/analytics_models.dart';

/// Service for managing analytics data across all roles
class AnalyticsService {
  /// Get farmer analytics for a specific period
  Future<FarmerAnalytics> getFarmerAnalytics(AnalyticsPeriod period) async {
    await Future.delayed(const Duration(milliseconds: 800));
    return FarmerAnalytics(
      totalSales: 45000.0,
      monthlyRevenue: 12500.0,
      salesTrend: [
        ChartData(
          values: [1000, 1500, 1200, 2000, 1800, 2500, 3000],
          labels: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
          title: 'Sales Trend',
          unit: 'TK',
        ),
      ],
      productPerformance: [
        ChartData(
          values: [30, 25, 20, 15, 10],
          labels: ['Tomato', 'Cucumber', 'Potato', 'Onion', 'Garlic'],
          title: 'Product Performance',
          unit: '%',
        ),
      ],
      totalOrders: 156,
      avgRating: 4.7,
    );
  }

  /// Get buyer analytics for a specific period
  Future<BuyerAnalytics> getBuyerAnalytics(AnalyticsPeriod period) async {
    await Future.delayed(const Duration(milliseconds: 800));
    return BuyerAnalytics(
      totalSpent: 75000.0,
      totalPurchases: 42,
      spendingTrend: [
        ChartData(
          values: [5000, 6000, 5500, 8000, 7500, 9000, 10000],
          labels: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
          title: 'Spending Trend',
          unit: 'TK',
        ),
      ],
      categoryBreakdown: [
        ChartData(
          values: [35, 25, 20, 15, 5],
          labels: ['Vegetables', 'Fruits', 'Grains', 'Dairy', 'Other'],
          title: 'Category Breakdown',
          unit: '%',
        ),
      ],
      avgOrderValue: 1785.0,
      favoriteFarmers: ['Farm 1', 'Farm 2', 'Farm 3'],
    );
  }

  /// Get driver analytics for a specific period
  Future<DriverAnalytics> getDriverAnalytics(AnalyticsPeriod period) async {
    await Future.delayed(const Duration(milliseconds: 800));
    return DriverAnalytics(
      totalEarnings: 35000.0,
      completedTrips: 284,
      earningsTrend: [
        ChartData(
          values: [800, 900, 850, 1100, 1000, 1200, 1300],
          labels: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
          title: 'Earnings Trend',
          unit: 'TK',
        ),
      ],
      avgRating: 4.8,
      totalDistance: 4250.0,
      acceptanceRate: 94.5,
    );
  }

  /// Get service provider analytics for a specific period
  Future<ServiceProviderAnalytics> getServiceProviderAnalytics(
      AnalyticsPeriod period) async {
    await Future.delayed(const Duration(milliseconds: 800));
    return ServiceProviderAnalytics(
      totalEarnings: 52000.0,
      completedBookings: 127,
      bookingTrend: [
        ChartData(
          values: [8, 10, 9, 12, 11, 14, 16],
          labels: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
          title: 'Bookings Trend',
          unit: 'Count',
        ),
      ],
      avgRating: 4.9,
      totalReviews: 98,
      completionRate: 96.8,
    );
  }

  /// Get company analytics for a specific period
  Future<CompanyAnalytics> getCompanyAnalytics(AnalyticsPeriod period) async {
    await Future.delayed(const Duration(milliseconds: 800));
    return CompanyAnalytics(
      totalOrderValue: 250000.0,
      activeContracts: 8,
      orderTrend: [
        ChartData(
          values: [30000, 35000, 32000, 40000, 38000, 45000, 50000],
          labels: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
          title: 'Order Trend',
          unit: 'TK',
        ),
      ],
      contractValue: [
        ChartData(
          values: [50000, 45000, 60000, 55000],
          labels: ['Contract 1', 'Contract 2', 'Contract 3', 'Contract 4'],
          title: 'Contract Values',
          unit: 'TK',
        ),
      ],
      budgetUsed: 175000.0,
      topSuppliers: ['Farm A', 'Farm B', 'Farm C', 'Farm D'],
    );
  }

  /// Export analytics as PDF (stub)
  Future<String> exportAnalyticsAsPDF() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return '/path/to/analytics.pdf';
  }

  /// Export analytics as CSV (stub)
  Future<String> exportAnalyticsAsCSV() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return '/path/to/analytics.csv';
  }
}
