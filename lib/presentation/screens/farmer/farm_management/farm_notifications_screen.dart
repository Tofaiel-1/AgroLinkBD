import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FarmNotificationsScreen extends StatelessWidget {
  const FarmNotificationsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> _notifications = [
      {
        'title': 'Low Fertilizer Stock',
        'body': 'Urea inventory is below 10kg. Please restock soon.',
        'time': '10 mins ago',
        'icon': Icons.warning,
        'color': Colors.redAccent,
        'isRead': false,
      },
      {
        'title': 'Weather Alert',
        'body': 'Heavy rainfall expected tomorrow afternoon.',
        'time': '2 hours ago',
        'icon': Icons.cloud,
        'color': Colors.blue,
        'isRead': false,
      },
      {
        'title': 'Task Completed',
        'body': 'Karim Miah finished "Irrigate Paddy Field".',
        'time': 'Yesterday, 5:30 PM',
        'icon': Icons.check_circle,
        'color': Colors.green,
        'isRead': true,
      },
      {
        'title': 'Yield Prediction Updated',
        'body': 'AI forecast for Tomato (Roma) has been updated.',
        'time': '20 Jun 2026',
        'icon': Icons.analytics,
        'color': Colors.indigo,
        'isRead': true,
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFF5722),
        elevation: 0,
        title: Text(
          'Notifications',
          style: GoogleFonts.openSans(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () {},
            child: Text(
              'Mark All Read',
              style: GoogleFonts.openSans(color: Colors.white, fontWeight: FontWeight.w600),
            ),
          )
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: _notifications.length,
        itemBuilder: (context, index) {
          final notif = _notifications[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: notif['isRead'] ? Colors.white : const Color(0xFFFFF3E0),
              borderRadius: BorderRadius.circular(16),
              border: notif['isRead'] ? Border.all(color: Colors.grey.shade200) : Border.all(color: const Color(0xFFFFCC80)),
              boxShadow: notif['isRead']
                  ? []
                  : [
                      BoxShadow(
                        color: const Color(0xFFFF5722).withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: (notif['color'] as Color).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(notif['icon'], color: notif['color'], size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              notif['title'],
                              style: GoogleFonts.openSans(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: const Color(0xFF2D3748),
                              ),
                            ),
                          ),
                          if (!notif['isRead'])
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Color(0xFFFF5722),
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        notif['body'],
                        style: GoogleFonts.openSans(
                          fontSize: 13,
                          color: const Color(0xFF4A5568),
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        notif['time'],
                        style: GoogleFonts.openSans(
                          fontSize: 11,
                          color: Colors.grey.shade500,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
