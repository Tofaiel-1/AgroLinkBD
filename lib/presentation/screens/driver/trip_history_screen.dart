import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';

/// Trip History Screen - View past completed trips
class TripHistoryScreen extends StatefulWidget {
  const TripHistoryScreen({super.key});

  @override
  State<TripHistoryScreen> createState() => _TripHistoryScreenState();
}

class _TripHistoryScreenState extends State<TripHistoryScreen> {
  final List<Map<String, dynamic>> trips = [
    {
      'id': '#TRP001',
      'date': '১৮ এপ্রিল ২০২৬',
      'from': 'জয়পুরহাট',
      'to': 'ঢাকা',
      'distance': '১৫০ কিমি',
      'duration': '৪ ঘণ্টা',
      'earnings': '৳ ৫০০',
      'status': 'সম্পন্ন',
    },
    {
      'id': '#TRP002',
      'date': '১৭ এপ্রিল ২০২৬',
      'from': 'রাজশাহী',
      'to': 'খুলনা',
      'distance': '৯০ কিমি',
      'duration': '২.৫ ঘণ্টা',
      'earnings': '৳ ৩৫০',
      'status': 'সম্পন্ন',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ভ্রমণ ইতিহাস'),
        backgroundColor: const Color(0xFFF57C00),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: trips.length,
        itemBuilder: (context, index) {
          final trip = trips[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        trip['id'] as String,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          trip['status'] as String,
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: Colors.green,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Date
                  Row(
                    children: [
                      Icon(Icons.calendar_today,
                          size: 16, color: Colors.grey.shade600),
                      const SizedBox(width: 6),
                      Text(
                        trip['date'] as String,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Route
                  Row(
                    children: [
                      const Icon(Icons.near_me, size: 16, color: Colors.orange),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          '${trip['from']} → ${trip['to']}',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Stats
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem(
                          'দূরত্ব',
                          trip['distance'] as String,
                        ),
                        _buildStatItem(
                          'সময়',
                          trip['duration'] as String,
                        ),
                        _buildStatItem(
                          'আয়',
                          trip['earnings'] as String,
                          isHighlight: true,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Detail Button
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () {
                        Get.snackbar('বিবরণ', 'ভ্রমণ বিবরণ দেখুন');
                      },
                      child: const Text('বিস্তারিত দেখুন'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatItem(String label, String value,
      {bool isHighlight = false}) {
    return Column(
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 10,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isHighlight ? Colors.green : Colors.black87,
          ),
        ),
      ],
    );
  }
}
