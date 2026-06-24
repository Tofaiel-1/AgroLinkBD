import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:agrolinkbd/core/providers/user_provider.dart';
import 'package:agrolinkbd/core/models/user_model.dart';
import 'package:google_fonts/google_fonts.dart';

class GlobalAnnouncementBanner extends StatelessWidget {
  const GlobalAnnouncementBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, _) {
        final currentUser = userProvider.currentUser;
        if (currentUser == null) return const SizedBox.shrink();

        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('announcements')
              .where('isActive', isEqualTo: true)
              .orderBy('createdAt', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const SizedBox.shrink();
            }

            // Find relevant announcements for the user
            final docs = snapshot.data!.docs;
            final relevantAnnouncements = docs.where((doc) {
              final data = doc.data() as Map<String, dynamic>;
              final audience = data['audience'] as String? ?? 'All Users';

              if (audience == 'All Users') return true;
              
              if (currentUser.userType == UserType.farmer && audience == 'Farmers Only') return true;
              if (currentUser.userType == UserType.buyer && audience == 'Buyers Only') return true;
              if (currentUser.userType == UserType.driver && audience == 'Drivers Only') return true;
              
              return false;
            }).toList();

            if (relevantAnnouncements.isEmpty) return const SizedBox.shrink();

            // Just show the most recent relevant announcement
            final latestData = relevantAnnouncements.first.data() as Map<String, dynamic>;
            final priority = latestData['priority'] as String? ?? 'Normal';
            final title = latestData['title'] ?? 'Announcement';
            final details = latestData['details'] ?? '';

            Color bgColor;
            Color iconColor;
            IconData icon;

            switch (priority) {
              case 'High':
                bgColor = Colors.red.shade50;
                iconColor = Colors.red.shade700;
                icon = Icons.warning_amber_rounded;
                break;
              case 'Normal':
                bgColor = Colors.blue.shade50;
                iconColor = Colors.blue.shade700;
                icon = Icons.info_outline_rounded;
                break;
              case 'Low':
                bgColor = Colors.grey.shade100;
                iconColor = Colors.grey.shade700;
                icon = Icons.campaign_rounded;
                break;
              default:
                bgColor = Colors.blue.shade50;
                iconColor = Colors.blue.shade700;
                icon = Icons.campaign_rounded;
            }

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: iconColor.withOpacity(0.3)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(icon, color: iconColor),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: GoogleFonts.hindSiliguri(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          details,
                          style: GoogleFonts.hindSiliguri(
                            fontSize: 13,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
