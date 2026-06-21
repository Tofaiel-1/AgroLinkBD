import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';

class ClientCrmScreen extends StatefulWidget {
  const ClientCrmScreen({super.key});

  @override
  State<ClientCrmScreen> createState() => _ClientCrmScreenState();
}

class _ClientCrmScreenState extends State<ClientCrmScreen> {
  final List<Map<String, dynamic>> _clients = [
    {
      'name': 'রহিম মিয়া',
      'last_msg': 'আগামীকাল কি আসা যাবে?',
      'time': '10:30 AM',
      'unread': 2,
      'is_top': true,
      'color': Colors.blue,
    },
    {
      'name': 'করিম এগ্রো',
      'last_msg': 'সার্ভিস খুব ভালো ছিল, ধন্যবাদ!',
      'time': 'Yesterday',
      'unread': 0,
      'is_top': true,
      'color': Colors.green,
    },
    {
      'name': 'সাভার ডেইরি',
      'last_msg': 'ভাই, পেমেন্ট পাঠিয়ে দিয়েছি।',
      'time': 'Yesterday',
      'unread': 0,
      'is_top': false,
      'color': Colors.purple,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'ক্লায়েন্ট ম্যানেজমেন্ট (CRM)',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF1E293B)),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded, color: Color(0xFF1E293B)),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Stats row
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Row(
              children: [
                Expanded(child: _buildStatCard('মোট ক্লায়েন্ট', '১২৪', Icons.people_alt_rounded, Colors.blue)),
                const SizedBox(width: 16),
                Expanded(child: _buildStatCard('রিপিট বুকিং', '৪৫%', Icons.repeat_rounded, Colors.orange)),
              ],
            ),
          ),
          
          const SizedBox(height: 10),
          
          // Chat List
          Expanded(
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              itemCount: _clients.length,
              itemBuilder: (context, index) {
                final client = _clients[index];
                return InkWell(
                  onTap: () {
                    // Navigate to individual chat
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
                    ),
                    child: Row(
                      children: [
                        Stack(
                          children: [
                            CircleAvatar(
                              radius: 28,
                              backgroundColor: client['color'].withOpacity(0.1),
                              child: Text(
                                client['name'][0],
                                style: GoogleFonts.poppins(color: client['color'], fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                            ),
                            if (client['is_top'])
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Colors.amber,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.star_rounded, color: Colors.white, size: 12),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                client['name'],
                                style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                client['last_msg'],
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  color: client['unread'] > 0 ? const Color(0xFF1E293B) : Colors.grey.shade500,
                                  fontWeight: client['unread'] > 0 ? FontWeight.w600 : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              client['time'],
                              style: GoogleFonts.poppins(fontSize: 11, color: client['unread'] > 0 ? Colors.green : Colors.grey.shade500),
                            ),
                            const SizedBox(height: 8),
                            if (client['unread'] > 0)
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: const BoxDecoration(
                                  color: Colors.green,
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  '${client['unread']}',
                                  style: GoogleFonts.poppins(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
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
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)),
          ),
          Text(
            title,
            style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}
