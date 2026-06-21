import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:agrolinkbd/core/services/phase2_services/analytics_service.dart';
import 'package:agrolinkbd/core/models/phase2_models/analytics_models.dart';

/// Driver analytics dashboard
class DriverAnalyticsScreen extends StatefulWidget {
  const DriverAnalyticsScreen({Key? key}) : super(key: key);

  @override
  State<DriverAnalyticsScreen> createState() => _DriverAnalyticsScreenState();
}

class _DriverAnalyticsScreenState extends State<DriverAnalyticsScreen> {
  final analyticsService = AnalyticsService();
  late Future<DriverAnalytics> analyticsFuture;

  @override
  void initState() {
    super.initState();
    analyticsFuture = analyticsService.getDriverAnalytics(
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
        backgroundColor: const Color(0xFFF57C00),
        title: Text(
          'Earnings & Performance',
          style: GoogleFonts.openSans(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
      body: FutureBuilder<DriverAnalytics>(
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
                  '+8.5%',
                  const Color(0xFFF57C00),
                  Icons.money,
                ),
                const SizedBox(height: 12),
                _buildMetricCard(
                  'Completed Trips',
                  '${analytics.completedTrips}',
                  '+12.0%',
                  const Color(0xFFF57C00),
                  Icons.local_shipping,
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
                        'Earnings Trend',
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

  Widget _buildStatGrid(DriverAnalytics analytics) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Avg Rating',
            '${analytics.avgRating}',
            Icons.star,
            const Color(0xFFF57C00),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Total Distance',
            '${analytics.totalDistance.toStringAsFixed(0)} km',
            Icons.directions,
            const Color(0xFFF57C00),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Acceptance Rate',
            '${analytics.acceptanceRate.toStringAsFixed(1)}%',
            Icons.check_circle,
            const Color(0xFFF57C00),
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
