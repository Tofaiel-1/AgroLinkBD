import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';

/// Saved Farmers Screen - View and manage saved farmer profiles
class SavedFarmersScreen extends StatefulWidget {
  const SavedFarmersScreen({super.key});

  @override
  State<SavedFarmersScreen> createState() => _SavedFarmersScreenState();
}

class _SavedFarmersScreenState extends State<SavedFarmersScreen> {
  final List<Map<String, dynamic>> savedFarmers = [
    {
      'id': 1,
      'name': 'করিম ফার্ম',
      'location': 'জয়পুরহাট',
      'specialty': 'সবজি চাষ',
      'rating': '4.8',
      'reviews': '১২৫',
      'followStatus': true,
    },
    {
      'id': 2,
      'name': 'মোহাম্মদ এগ্রো',
      'location': 'রাজশাহী',
      'specialty': 'শস্য উৎপাদন',
      'rating': '4.6',
      'reviews': '৮৯',
      'followStatus': true,
    },
    {
      'id': 3,
      'name': 'গ্রীন হার্ভেস্ট',
      'location': 'নাটোর',
      'specialty': 'জৈব চাষ',
      'rating': '4.9',
      'reviews': '৫৬',
      'followStatus': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('সংরক্ষিত কৃষক'),
        backgroundColor: const Color(0xFF1976D2),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: savedFarmers.length,
        itemBuilder: (context, index) {
          final farmer = savedFarmers[index];
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
                  // Farmer Avatar
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.person,
                      color: Colors.blue,
                      size: 40,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Farmer Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          farmer['name'] as String,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          farmer['specialty'] as String,
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.location_on,
                                size: 14, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(
                              farmer['location'] as String,
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.star,
                                size: 14, color: Colors.amber),
                            const SizedBox(width: 2),
                            Text(
                              '${farmer['rating']} (${farmer['reviews']})',
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Follow Button
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () {
                          Get.snackbar('সংরক্ষিত থেকে সরান',
                              'কৃষক সংরক্ষিত থেকে সরানো হয়েছে');
                        },
                        icon: const Icon(Icons.more_vert),
                        iconSize: 18,
                      ),
                      SizedBox(
                        height: 28,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: farmer['followStatus'] as bool
                                ? Colors.blue.withOpacity(0.1)
                                : Colors.blue,
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                          ),
                          onPressed: () {
                            Get.snackbar(
                              farmer['followStatus'] as bool
                                  ? 'অনুসরণ সরিয়ে দিন'
                                  : 'অনুসরণ করুন',
                              'অবস্থা আপডেট হয়েছে',
                            );
                          },
                          child: Text(
                            farmer['followStatus'] as bool
                                ? 'অনুসরণ করছেন'
                                : 'অনুসরণ করুন',
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              color: farmer['followStatus'] as bool
                                  ? Colors.blue
                                  : Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
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
