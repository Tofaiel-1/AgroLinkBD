import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:agrolinkbd/core/services/phase2_services/analytics_service.dart';
import 'package:agrolinkbd/core/models/phase2_models/analytics_models.dart';

/// Company analytics dashboard
class CompanyAnalyticsScreen extends StatefulWidget {
  const CompanyAnalyticsScreen({Key? key}) : super(key: key);

  @override
  State<CompanyAnalyticsScreen> createState() => _CompanyAnalyticsScreenState();
}

class _CompanyAnalyticsScreenState extends State<CompanyAnalyticsScreen> {
  final analyticsService = AnalyticsService();
  late Future<CompanyAnalytics> analyticsFuture;

  @override
  void initState() {
    super.initState();
    analyticsFuture = analyticsService.getCompanyAnalytics(
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
        backgroundColor: const Color(0xFF0D47A1),
        title: Text(
          'Business Analytics',
          style: GoogleFonts.openSans(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
      body: FutureBuilder<CompanyAnalytics>(
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
                  'Total Order Value',
                  '৳${analytics.totalOrderValue.toStringAsFixed(0)}',
                  '+18.5%',
                  const Color(0xFF0D47A1),
                  Icons.shopping_cart,
                ),
                const SizedBox(height: 12),
                _buildMetricCard(
                  'Active Contracts',
                  '${analytics.activeContracts}',
                  '+4',
                  const Color(0xFF0D47A1),
                  Icons.assignment,
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
                        'Top Suppliers',
                        style: GoogleFonts.openSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...analytics.topSuppliers.map((supplier) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 18,
                                backgroundColor: Colors.grey[300],
                                child: const Icon(Icons.store, size: 18),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  supplier,
                                  style: GoogleFonts.openSans(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              Text(
                                '${(analytics.totalOrderValue / analytics.topSuppliers.length).toStringAsFixed(0)}',
                                style: GoogleFonts.openSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
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

  Widget _buildStatGrid(CompanyAnalytics analytics) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Budget Used',
            '${(analytics.budgetUsed / analytics.totalOrderValue * 100).toStringAsFixed(1)}%',
            Icons.percent,
            const Color(0xFF0D47A1),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Suppliers',
            '${analytics.topSuppliers.length}',
            Icons.business,
            const Color(0xFF0D47A1),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Avg Contract Value',
            '৳${(analytics.totalOrderValue / analytics.activeContracts).toStringAsFixed(0)}',
            Icons.trending_up,
            const Color(0xFF0D47A1),
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
                  fontSize: 12, fontWeight: FontWeight.w700)),
          Text(label,
              style:
                  GoogleFonts.openSans(fontSize: 9, color: Colors.grey[600])),
        ],
      ),
    );
  }
}
