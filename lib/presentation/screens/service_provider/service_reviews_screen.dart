import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Service Reviews Screen - View customer reviews and ratings
class ServiceReviewsScreen extends StatefulWidget {
  const ServiceReviewsScreen({super.key});

  @override
  State<ServiceReviewsScreen> createState() => _ServiceReviewsScreenState();
}

class _ServiceReviewsScreenState extends State<ServiceReviewsScreen> {
  final List<Map<String, dynamic>> reviews = [
    {
      'client': 'করিম ফার্ম',
      'rating': 5,
      'comment':
          'দুর্দান্ত সেবা পেয়েছি। কর্মীরা অত্যন্ত পেশাদার এবং বন্ধুত্বপূর্ণ ছিল।',
      'date': '১৮ এপ্রিল ২০২৬',
    },
    {
      'client': 'মোহাম্মদ এগ্রো',
      'rating': 4,
      'comment': 'ভালো সেবা কিন্তু সময়মত আসতে একটু দেরি হয়েছিল।',
      'date': '১৬ এপ্রিল ২০২৬',
    },
    {
      'client': 'জয়পুরহাট কৃষক',
      'rating': 5,
      'comment': 'অসাধারণ! ফসলের ফলন অনেক বেড়েছে এই সেবার পরে।',
      'date': '১৪ এপ্রিল ২০২৬',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('পর্যালোচনা'),
        backgroundColor: const Color(0xFF7B1FA2),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Rating Summary
            Container(
              padding: const EdgeInsets.all(20),
              color: Colors.purple.withOpacity(0.05),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'আপনার রেটিং',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            '4.9',
                            style: GoogleFonts.poppins(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.purple,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: List.generate(
                                  5,
                                  (index) => Icon(
                                    Icons.star,
                                    color:
                                        index < 5 ? Colors.amber : Colors.grey,
                                    size: 16,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '৩৫টি পর্যালোচনা',
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Reviews List
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: reviews.length,
              itemBuilder: (context, index) {
                final review = reviews[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Client and Rating
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              review['client'] as String,
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            Row(
                              children: List.generate(
                                5,
                                (i) => Icon(
                                  Icons.star,
                                  color: i < (review['rating'] as int)
                                      ? Colors.amber
                                      : Colors.grey.shade300,
                                  size: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // Comment
                        Text(
                          review['comment'] as String,
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Date
                        Text(
                          review['date'] as String,
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
