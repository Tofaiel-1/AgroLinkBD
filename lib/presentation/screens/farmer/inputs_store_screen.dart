import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';

/// Inputs Store Screen - Farmers buy seeds, fertilizers, equipment
class InputsStoreScreen extends StatefulWidget {
  const InputsStoreScreen({super.key});

  @override
  State<InputsStoreScreen> createState() => _InputsStoreScreenState();
}

class _InputsStoreScreenState extends State<InputsStoreScreen> {
  final List<Map<String, dynamic>> items = [
    {
      'id': 1,
      'name': 'উচ্চ ফলনশীল টমেটো বীজ',
      'category': 'বীজ',
      'price': '৳ ৫৫০',
      'rating': '4.8',
      'reviews': '১২৫',
      'provider': 'গ্রীন ফার্ম সিড কোম্পানি',
    },
    {
      'id': 2,
      'name': 'জৈব সার (৫০ কেজি)',
      'category': 'সার',
      'price': '৳ ১,২০০',
      'rating': '4.6',
      'reviews': '৮৯',
      'provider': 'ইকো এগ্রো প্রোডাক্টস',
    },
    {
      'id': 3,
      'name': 'স্প্রে পাম্প (২০ লিটার)',
      'category': 'সরঞ্জাম',
      'price': '৳ ২,৫০০',
      'rating': '4.7',
      'reviews': '৬৫',
      'provider': 'এগ্রো সাপ্লাই কেন্দ্র',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('কৃষি ইনপুট স্টোর'),
        backgroundColor: const Color(0xFF2E7D32),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
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
              child: Row(
                children: [
                  // Product image placeholder
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.eco,
                      color: Colors.green,
                      size: 40,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Product details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['name'] as String,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item['provider'] as String,
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.star,
                                  size: 14,
                                  color: Colors.amber,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${item['rating']} (${item['reviews']})',
                                  style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              item['price'] as String,
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 30,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2E7D32),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                            ),
                            onPressed: () {
                              Get.snackbar(
                                'কার্টে যোগ করা হয়েছে',
                                '${item['name']} কার্টে যোগ করা হয়েছে',
                              );
                            },
                            child: Text(
                              'কার্টে যোগ করুন',
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
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
}
