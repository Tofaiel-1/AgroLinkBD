import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:agrolinkbd/core/utils/masked_identity_helper.dart';

/// Buyer Chat Screen - Real-time masked messaging with farmers
class BuyerChatScreen extends StatefulWidget {
  const BuyerChatScreen({super.key});

  @override
  State<BuyerChatScreen> createState() => _BuyerChatScreenState();
}

class _BuyerChatScreenState extends State<BuyerChatScreen> {
  final List<Map<String, dynamic>> chats = [
    {
      'id': 1,
      'farmerCode': 'AGR-4091',
      'name': MaskedIdentityHelper.getMaskedFarmerName(userId: 'farmer_01', district: 'বগুড়া', upazila: 'সদর'),
      'lastMessage': 'হ্যাঁ, কালেকশন পয়েন্টে ২০ মণ আলু প্রস্তুত রয়েছে।',
      'time': '১৫ মিনিট আগে',
      'unread': 0,
      'status': 'অনলাইন',
      'category': 'সবজি খামারি',
    },
    {
      'id': 2,
      'farmerCode': 'FSH-8812',
      'name': MaskedIdentityHelper.getMaskedFishFarmerName(userId: 'fish_02', district: 'ময়মনসিংহ', upazila: 'ত্রিশাল'),
      'lastMessage': 'আগামীকাল ভোরে লাইভ রুই মাছ হার্ভেস্ট ও ওজন করা হবে।',
      'time': '২ ঘণ্টা আগে',
      'unread': 1,
      'status': 'অফলাইন',
      'category': 'মৎস্য খামারি',
    },
    {
      'id': 3,
      'farmerCode': 'AGR-3305',
      'name': MaskedIdentityHelper.getMaskedFarmerName(userId: 'farmer_03', district: 'যশোর', upazila: 'শার্শা'),
      'lastMessage': 'এগ্রোলিংক ড্রাইভারে পণ্য লোড সম্পন্ন হয়েছে।',
      'time': '১ দিন আগে',
      'unread': 0,
      'status': 'অনলাইন',
      'category': 'ফসল খামারি',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(
          'সুরক্ষিত চ্যাটবক্স 🔒',
          style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF1976D2),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Escrow Protection Notice Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              border: Border(bottom: BorderSide(color: Colors.blue.shade200)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.shield_outlined, color: Color(0xFF1976D2), size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '🔒 এগ্রোলিংক এস্ক্রো নিরাপত্তা: কোনো ব্যক্তিগত মোবাইল বা বিকাশ নম্বর শেয়ার করবেন না। অ্যাপের মাধ্যমে অর্ডার ও পেমেন্ট করলে আপনার টাকা ও পণ্যের মান শতভাগ সুরক্ষিত।',
                    style: GoogleFonts.hindSiliguri(
                      fontSize: 12,
                      color: const Color(0xFF0D47A1),
                      fontWeight: FontWeight.w600,
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Chat List
          Expanded(
            child: ListView.builder(
              itemCount: chats.length,
              itemBuilder: (context, index) {
                final chat = chats[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          Get.snackbar(
                            chat['name'] as String,
                            'এস্ক্রো সিকিউর চ্যাট স্ক্রিন সক্রিয় রয়েছে',
                            backgroundColor: Colors.blue.shade100,
                            colorText: Colors.blue.shade900,
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              // Masked Avatar with online status
                              Stack(
                                children: [
                                  Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: const Color(0xFF1976D2).withOpacity(0.1),
                                      border: Border.all(color: const Color(0xFF1976D2).withOpacity(0.3)),
                                    ),
                                    child: const Icon(
                                      Icons.person_pin_rounded,
                                      color: Color(0xFF1976D2),
                                      size: 28,
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: Container(
                                      width: 14,
                                      height: 14,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: chat['status'] == 'অনলাইন' ? Colors.green : Colors.grey,
                                        border: Border.all(color: Colors.white, width: 2),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 12),
                              // Message details
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            chat['name'] as String,
                                            style: GoogleFonts.hindSiliguri(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black87,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        Text(
                                          chat['time'] as String,
                                          style: GoogleFonts.hindSiliguri(
                                            fontSize: 11,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            chat['lastMessage'] as String,
                                            style: GoogleFonts.hindSiliguri(
                                              fontSize: 12,
                                              color: Colors.grey.shade700,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        if ((chat['unread'] as int) > 0)
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF1976D2),
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            child: Text(
                                              '${chat['unread']}',
                                              style: GoogleFonts.poppins(
                                                fontSize: 10,
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
