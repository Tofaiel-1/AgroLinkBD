import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CropProductionScreen extends StatefulWidget {
  const CropProductionScreen({Key? key}) : super(key: key);

  @override
  State<CropProductionScreen> createState() => _CropProductionScreenState();
}

class _CropProductionScreenState extends State<CropProductionScreen> {
  final List<Map<String, dynamic>> _activeCrops = [
    {
      'name': 'Paddy (BRRI Dhan 28)',
      'planted_date': '12 Jan 2026',
      'est_harvest': '20 Apr 2026',
      'progress': 0.7,
      'status': 'Flowering Stage',
      'health': 'Good',
      'health_color': Colors.green,
    },
    {
      'name': 'Tomato (Roma)',
      'planted_date': '05 Mar 2026',
      'est_harvest': '10 Jun 2026',
      'progress': 0.35,
      'status': 'Vegetative Stage',
      'health': 'Excellent',
      'health_color': Colors.blue,
    },
    {
      'name': 'Potato (Diamant)',
      'planted_date': '15 Dec 2025',
      'est_harvest': '05 Apr 2026',
      'progress': 0.85,
      'status': 'Maturation Stage',
      'health': 'Warning: Pests',
      'health_color': Colors.orange,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF8BC34A),
        elevation: 0,
        title: Text(
          'Crop Production',
          style: GoogleFonts.openSans(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: Colors.white),
            onPressed: () {
              // Add new crop
            },
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color(0xFF8BC34A),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Active Crops Summary',
                    style: GoogleFonts.openSans(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildSummaryStat('Total Crops', '3'),
                      _buildSummaryStat('Healthy', '2'),
                      _buildSummaryStat('Needs Attn.', '1'),
                    ],
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(20.0),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return _buildCropCard(_activeCrops[index]);
                },
                childCount: _activeCrops.length,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: GoogleFonts.openSans(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.openSans(
            color: Colors.white.withOpacity(0.8),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildCropCard(Map<String, dynamic> crop) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFCBD5E1).withOpacity(0.4),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  crop['name'],
                  style: GoogleFonts.openSans(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2D3748),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: (crop['health_color'] as Color).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  crop['health'],
                  style: GoogleFonts.openSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: crop['health_color'],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.calendar_today, size: 16, color: Colors.grey.shade500),
              const SizedBox(width: 8),
              Text(
                'Planted: ${crop['planted_date']}',
                style: GoogleFonts.openSans(fontSize: 13, color: Colors.grey.shade600),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.event_available, size: 16, color: Colors.grey.shade500),
              const SizedBox(width: 8),
              Text(
                'Est. Harvest: ${crop['est_harvest']}',
                style: GoogleFonts.openSans(fontSize: 13, color: Colors.grey.shade600),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'Stage: ${crop['status']}',
            style: GoogleFonts.openSans(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: crop['progress'],
              minHeight: 10,
              backgroundColor: Colors.grey.shade200,
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF8BC34A)),
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '${(crop['progress'] * 100).toInt()}% to Harvest',
              style: GoogleFonts.openSans(
                fontSize: 12,
                color: Colors.grey.shade500,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
