import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HarvestTrackingScreen extends StatelessWidget {
  const HarvestTrackingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> _harvestLogs = [
      {
        'crop': 'Potato (Diamant)',
        'date': '15 May 2026',
        'yield': '2,500 kg',
        'quality': 'Grade A',
        'revenue': '৳ 45,000',
      },
      {
        'crop': 'Boro Rice',
        'date': '20 Apr 2026',
        'yield': '4,200 kg',
        'quality': 'Grade B',
        'revenue': '৳ 84,000',
      },
      {
        'crop': 'Tomato (Roma)',
        'date': '10 Mar 2026',
        'yield': '800 kg',
        'quality': 'Grade A',
        'revenue': '৳ 24,000',
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFC107),
        elevation: 0,
        title: Text(
          'Harvest Tracking',
          style: GoogleFonts.openSans(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Color(0xFFFFC107),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Yield (2026)',
                    style: GoogleFonts.openSans(
                      color: Colors.black87,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '7,500 kg',
                    style: GoogleFonts.openSans(
                      color: Colors.black87,
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return _buildHarvestCard(_harvestLogs[index]);
                },
                childCount: _harvestLogs.length,
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: const Color(0xFFFFC107),
        child: const Icon(Icons.add, color: Colors.black87),
      ),
    );
  }

  Widget _buildHarvestCard(Map<String, dynamic> log) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFCBD5E1).withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                log['crop'],
                style: GoogleFonts.openSans(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: const Color(0xFF2D3748),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  log['quality'],
                  style: GoogleFonts.openSans(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.calendar_today, size: 16, color: Colors.grey.shade500),
              const SizedBox(width: 8),
              Text(
                log['date'],
                style: GoogleFonts.openSans(fontSize: 14, color: Colors.grey.shade600),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Yield',
                    style: GoogleFonts.openSans(fontSize: 12, color: Colors.grey.shade500),
                  ),
                  Text(
                    log['yield'],
                    style: GoogleFonts.openSans(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF2D3748),
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Est. Revenue',
                    style: GoogleFonts.openSans(fontSize: 12, color: Colors.grey.shade500),
                  ),
                  Text(
                    log['revenue'],
                    style: GoogleFonts.openSans(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF009688),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
