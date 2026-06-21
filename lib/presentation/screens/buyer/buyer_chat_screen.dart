import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';

/// Buyer Chat Screen - Real-time messaging with farmers
class BuyerChatScreen extends StatefulWidget {
  const BuyerChatScreen({super.key});

  @override
  State<BuyerChatScreen> createState() => _BuyerChatScreenState();
}

class _BuyerChatScreenState extends State<BuyerChatScreen> {
  final List<Map<String, dynamic>> chats = [
    {
      'id': 1,
      'name': 'করিম ফার্ম',
      'lastMessage': 'হ্যাঁ, আগামীকাল ডেলিভারি দিতে পারব।',
      'time': '১৫ মিনিট আগে',
      'unread': 0,
      'status': 'অনলাইন',
    },
    {
      'id': 2,
      'name': 'মোহাম্মদ এগ্রো',
      'lastMessage': 'নতুন ফসল এসেছে, আগ্রহী?',
      'time': '২ ঘণ্টা আগে',
      'unread': 1,
      'status': 'অফলাইন',
    },
    {
      'id': 3,
      'name': 'গ্রীন হার্ভেস্ট',
      'lastMessage': 'ধন্যবাদ অর্ডারের জন্য',
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
        backgroundColor: const Color(0xFF1976D2),
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
                      // Avatar with online status
                      Stack(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.blue.withOpacity(0.1),
                            ),
                            child: const Icon(
                              Icons.person,
                              color: Colors.blue,
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
                                color: chat['status'] == 'অনলাইন'
                                    ? Colors.green
                                    : Colors.grey,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
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
                                      color: Colors.blue,
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
