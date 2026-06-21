import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';

/// Farmer Chat Screen - Communication with buyers and drivers
class FarmerChatScreen extends StatefulWidget {
  const FarmerChatScreen({super.key});

  @override
  State<FarmerChatScreen> createState() => _FarmerChatScreenState();
}

class _FarmerChatScreenState extends State<FarmerChatScreen> {
  final List<Map<String, dynamic>> chats = [
    {
      'id': 1,
      'name': 'রহিম মার্কেট',
      'lastMessage': 'আরও টমেটো পাওয়া যাবে?',
      'time': '১ ঘণ্টা আগে',
      'unread': 2,
      'status': 'অনলাইন',
    },
    {
      'id': 2,
      'name': 'ফারিয়া ফুড স্টোর',
      'lastMessage': 'ধন্যবাদ, আগামীকাল ডেলিভারি দিয়ে দেবেন?',
      'time': '৩ ঘণ্টা আগে',
      'unread': 0,
      'status': 'অফলাইন',
    },
    {
      'id': 3,
      'name': 'মোহাম্মদ ড্রাইভার',
      'lastMessage': 'আজ সকাল ১০টায় পিক আপ করব',
      'time': '১ দিন আগে',
      'unread': 0,
      'status': 'অনলাইন',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('চ্যাট'),
        backgroundColor: const Color(0xFF2E7D32),
      ),
      body: ListView.builder(
        itemCount: chats.length,
        itemBuilder: (context, index) {
          final chat = chats[index];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 1),
            child: Material(
              child: InkWell(
                onTap: () {
                  Get.snackbar(
                    chat['name'] as String,
                    'চ্যাট স্ক্রিন খুলছে',
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.grey.shade200),
                    ),
                  ),
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
                            color: chat['status'] == 'অনলাইন'
                                ? Colors.green
                                : Colors.grey,
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          Icons.person,
                          color: Color(0xFF2E7D32),
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
                                Text(
                                  chat['name'] as String,
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                                Text(
                                  chat['time'] as String,
                                  style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    chat['lastMessage'] as String,
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if ((chat['unread'] as int) > 0)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
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
          );
        },
      ),
    );
  }
}
