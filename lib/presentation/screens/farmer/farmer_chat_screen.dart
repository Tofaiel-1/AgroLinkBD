import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:agrolinkbd/core/utils/masked_identity_helper.dart';

/// Farmer Chat Screen - Communication with buyers and drivers with masked identity
class FarmerChatScreen extends StatefulWidget {
  const FarmerChatScreen({super.key});

  @override
  State<FarmerChatScreen> createState() => _FarmerChatScreenState();
}

class _FarmerChatScreenState extends State<FarmerChatScreen> {
  final List<Map<String, dynamic>> chats = [
    {
      'id': 1,
      'name': MaskedIdentityHelper.getMaskedBuyerName(userId: 'buyer_01', district: 'ঢাকা'),
      'lastMessage': 'আপনার ২০ মণ আলুর লটের জন্য এস্ক্রো পেমেন্ট সম্পন্ন হয়েছে।',
      'time': '১ ঘণ্টা আগে',
      'unread': 2,
      'status': 'অনলাইন',
    },
    {
      'id': 2,
      'name': MaskedIdentityHelper.getMaskedBuyerName(userId: 'buyer_02', district: 'চট্টগ্রাম'),
      'lastMessage': 'কাঁচা মরিচ পিকআপের জন্য ড্রাইভার পাঠানো হয়েছে।',
      'time': '৩ ঘণ্টা আগে',
      'unread': 0,
      'status': 'অফলাইন',
    },
    {
      'id': 3,
      'name': MaskedIdentityHelper.getMaskedDriverName(userId: 'driver_01', vehicleType: 'পিকআপ'),
      'lastMessage': 'আজ দুপুর ১২টায় উপজেলা হাব থেকে লোড করব।',
      'time': '১ দিন আগে',
      'unread': 0,
      'status': 'অনলাইন',
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
        backgroundColor: const Color(0xFF2E7D32),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Escrow & Anti-Bypass Security Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              border: Border(bottom: BorderSide(color: Colors.green.shade200)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.verified_user_outlined, color: Color(0xFF2E7D32), size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '🔒 এগ্রোলিংক পেমেন্ট গ্যারান্টি: ক্রেতা ইতিমধ্যে এস্ক্রোতে ১০০% টাকা জমা রেখেছেন। পণ্য গাড়িতে লোড বা হাবে জমা দিলে ওটিপি কনফার্মেশনের পর সরাসরি আপনার বিকাশ/নগদ ওয়ালেটে টাকা পৌঁছে যাবে।',
                    style: GoogleFonts.hindSiliguri(
                      fontSize: 12,
                      color: const Color(0xFF1B5E20),
                      fontWeight: FontWeight.w600,
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // List of Chats
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
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
                            'এস্ক্রো সিকিউর চ্যাট সক্রিয় রয়েছে',
                            backgroundColor: Colors.green.shade100,
                            colorText: Colors.green.shade900,
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              // Avatar
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: const Color(0xFF2E7D32).withOpacity(0.1),
                                  border: Border.all(
                                    color: chat['status'] == 'অনলাইন' ? Colors.green : Colors.grey.shade300,
                                    width: 2,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.account_circle_outlined,
                                  color: Color(0xFF2E7D32),
                                  size: 30,
                                ),
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
                                              color: const Color(0xFF2E7D32),
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
