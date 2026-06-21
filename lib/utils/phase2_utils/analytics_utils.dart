import 'package:agrolinkbd/core/models/phase2_models/analytics_models.dart';

/// Utilities for analytics calculations and formatting
class AnalyticsUtils {
  /// Generate chart data from values and labels
  static ChartData generateChartData(
    List<double> values,
    List<String> labels,
    String title,
    String unit,
  ) {
    return ChartData(
      values: values,
      labels: labels,
      title: title,
      unit: unit,
    );
  }

  /// Format currency value
  static String formatCurrency(double amount) {
    return '৳${amount.toStringAsFixed(0)}';
  }

  /// Format percentage
  static String formatPercentage(double percent) {
    return '${percent.toStringAsFixed(1)}%';
  }

  /// Get trend label based on change percentage
  static String getTrendLabel(double changePercent) {
    if (changePercent > 0) {
      return '+${changePercent.toStringAsFixed(1)}%';
    } else if (changePercent < 0) {
      return '${changePercent.toStringAsFixed(1)}%';
    } else {
      return '0%';
    }
  }

  /// Calculate average
  static double calculateAverage(List<double> values) {
    if (values.isEmpty) return 0;
    return values.reduce((a, b) => a + b) / values.length;
  }

  /// Calculate sum
  static double calculateSum(List<double> values) {
    return values.reduce((a, b) => a + b);
  }

  /// Calculate percentage change
  static double calculatePercentageChange(
    double currentValue,
    double previousValue,
  ) {
    if (previousValue == 0) return 0;
    return ((currentValue - previousValue) / previousValue) * 100;
  }
}
