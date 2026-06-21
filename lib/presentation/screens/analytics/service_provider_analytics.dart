import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:agrolinkbd/core/services/phase2_services/analytics_service.dart';
import 'package:agrolinkbd/core/models/phase2_models/analytics_models.dart';

/// Service Provider analytics dashboard
class ServiceProviderAnalyticsScreen extends StatefulWidget {
  const ServiceProviderAnalyticsScreen({Key? key}) : super(key: key);

  @override
  State<ServiceProviderAnalyticsScreen> createState() =>
      _ServiceProviderAnalyticsScreenState();
}

class _ServiceProviderAnalyticsScreenState
    extends State<ServiceProviderAnalyticsScreen> {
  final analyticsService = AnalyticsService();
  late Future<ServiceProviderAnalytics> analyticsFuture;

  @override
  void initState() {
    super.initState();
    analyticsFuture = analyticsService.getServiceProviderAnalytics(
      AnalyticsPeriod(
        period: 'monthly',
        startDate: DateTime.now().subtract(const Duration(days: 30)),
        endDate: DateTime.now(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF7B1FA2),
        title: Text(
          'Service Analytics',
          style: GoogleFonts.openSans(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
      body: FutureBuilder<ServiceProviderAnalytics>(
        future: analyticsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('No data available'));
          }

          final analytics = snapshot.data!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildMetricCard(
                  'Total Earnings',
                  '৳${analytics.totalEarnings.toStringAsFixed(0)}',
                  '+15.3%',
                  const Color(0xFF7B1FA2),
                  Icons.money,
                ),
                const SizedBox(height: 12),
                _buildMetricCard(
                  'Completed Bookings',
                  '${analytics.completedBookings}',
                  '+9.2%',
                  const Color(0xFF7B1FA2),
                  Icons.check_circle,
                ),
                const SizedBox(height: 20),
                _buildStatGrid(analytics),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Booking Trend',
                        style: GoogleFonts.openSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        height: 150,
                        color: Colors.grey[100],
                        child: Center(
                          child: Text(
                            'Chart View (coming in Phase 3)',
                            style: GoogleFonts.openSans(fontSize: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMetricCard(
    String title,
    String value,
    String trend,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.openSans(fontSize: 12)),
                Text(value,
                    style: GoogleFonts.openSans(
                        fontSize: 18, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(trend,
                style: GoogleFonts.openSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.green)),
          ),
        ],
      ),
    );
  }

  Widget _buildStatGrid(ServiceProviderAnalytics analytics) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Avg Rating',
            '${analytics.avgRating}',
            Icons.star,
            const Color(0xFF7B1FA2),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Total Reviews',
            '${analytics.totalReviews}',
            Icons.rate_review,
            const Color(0xFF7B1FA2),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Completion',
            '${analytics.completionRate.toStringAsFixed(1)}%',
            Icons.done_all,
            const Color(0xFF7B1FA2),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 6),
          Text(value,
              style: GoogleFonts.openSans(
                  fontSize: 14, fontWeight: FontWeight.w700)),
          Text(label,
              style:
                  GoogleFonts.openSans(fontSize: 10, color: Colors.grey[600])),
        ],
      ),
    );
  }
}
