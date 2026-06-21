import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Company Chat Screen
/// Communicate with farmers, drivers, and team members
class CompanyChatScreen extends StatefulWidget {
  const CompanyChatScreen({super.key});

  @override
  State<CompanyChatScreen> createState() => _CompanyChatScreenState();
}

class _CompanyChatScreenState extends State<CompanyChatScreen> {
  final TextEditingController _searchController = TextEditingController();
  final List<Map<String, dynamic>> conversations = [
    {
      'name': 'রহিম ফার্ম',
      'type': 'কৃষক',
      'lastMessage': 'পরের সপ্তাহে ধান প্রস্তুত থাকবে',
      'timestamp': '২ মিনিট আগে',
      'unread': 2,
      'avatar': '🌾',
    },
    {
      'name': 'আহমেদ ড্রাইভার',
      'type': 'ড্রাইভার',
      'lastMessage': 'অর্ডার ডেলিভারি সম্পন্ন হয়েছে',
      'timestamp': '১ ঘন্টা আগে',
      'unread': 0,
      'avatar': '🚗',
    },
    {
      'name': 'দল ব্যবস্থাপনা',
      'type': 'গ্রুপ',
      'lastMessage': 'আগামীকাল মিটিং ১০টায়',
      'timestamp': '৫ ঘন্টা আগে',
      'unread': 5,
      'avatar': '👥',
    },
    {
      'name': 'করিম সবজি বাগান',
      'type': 'কৃষক',
      'lastMessage': 'মূল্য নির্ধারণের জন্য অপেক্ষা করছি',
      'timestamp': '১ দিন আগে',
      'unread': 1,
      'avatar': '🥬',
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF4169E1),
        elevation: 0,
        title: Text(
          'বার্তা',
          style: GoogleFonts.openSans(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'কথোপকথন অনুসন্ধান করুন...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              ),
            ),
          ),

          // Conversations list
          Expanded(
            child: ListView.builder(
              itemCount: conversations.length,
              itemBuilder: (context, index) {
                final conv = conversations[index];
                return _buildConversationTile(
                  name: conv['name'],
                  type: conv['type'],
                  lastMessage: conv['lastMessage'],
                  timestamp: conv['timestamp'],
                  unread: conv['unread'],
                  avatar: conv['avatar'],
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF4169E1),
        onPressed: () {
          // Start new conversation
        },
        child: const Icon(Icons.message),
      ),
    );
  }

  Widget _buildConversationTile({
    required String name,
    required String type,
    required String lastMessage,
    required String timestamp,
    required int unread,
    required String avatar,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: const Color(0xFF4169E1).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              avatar,
              style: const TextStyle(fontSize: 24),
            ),
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                name,
                style: GoogleFonts.openSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1A1A1A),
                ),
              ),
            ),
            if (unread > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFE74C3C),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$unread',
                  style: GoogleFonts.openSans(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              type,
              style: GoogleFonts.openSans(
                fontSize: 10,
                color: const Color(0xFF4169E1),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              lastMessage,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.openSans(
                fontSize: 12,
                color: const Color(0xFF999999),
              ),
            ),
          ],
        ),
        trailing: Text(
          timestamp,
          style: GoogleFonts.openSans(
            fontSize: 10,
            color: const Color(0xFFCCCCCC),
          ),
        ),
      ),
    );
  }
}
