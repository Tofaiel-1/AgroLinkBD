import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

/// Farmer-specific notifications - Shows real Firestore notifications
class FarmerNotificationsScreen extends StatelessWidget {
  const FarmerNotificationsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const Color primaryGreen = Color(0xFF2E7D32);
    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: primaryGreen,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'নোটিফিকেশন 🔔',
          style: GoogleFonts.hindSiliguri(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () => _markAllRead(userId),
            child: Text(
              'সব পড়া হয়েছে',
              style: GoogleFonts.hindSiliguri(color: Colors.white70, fontSize: 13),
            ),
          ),
        ],
      ),
      body: userId.isEmpty
          ? _emptyState()
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(userId)
                  .collection('notifications')
                  .orderBy('timestamp', descending: true)
                  .limit(50)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: primaryGreen));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return _emptyState();
                }

                final notifications = snapshot.data!.docs;

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: notifications.length,
                  itemBuilder: (context, index) {
                    final data = notifications[index].data() as Map<String, dynamic>;
                    final docId = notifications[index].id;
                    final bool isRead = data['isRead'] == true;
                    final String type = data['type'] ?? 'general';
                    final String message = data['message'] ?? '';
                    final Timestamp? ts = data['timestamp'] as Timestamp?;

                    // Determine icon and color based on type
                    IconData icon;
                    Color color;
                    String typeLabel;

                    switch (type) {
                      case 'booking_request':
                        icon = Icons.local_shipping;
                        color = Colors.orange.shade700;
                        typeLabel = 'ট্রান্সপোর্ট';
                        break;
                      case 'order':
                        icon = Icons.shopping_bag;
                        color = primaryGreen;
                        typeLabel = 'অর্ডার';
                        break;
                      case 'payment':
                        icon = Icons.payment;
                        color = Colors.green.shade700;
                        typeLabel = 'পেমেন্ট';
                        break;
                      case 'market_price':
                        icon = Icons.trending_up;
                        color = Colors.blue.shade700;
                        typeLabel = 'বাজার দর';
                        break;
                      case 'weather_alert':
                        icon = Icons.cloud_outlined;
                        color = Colors.indigo.shade700;
                        typeLabel = 'আবহাওয়া';
                        break;
                      default:
                        icon = Icons.notifications;
                        color = Colors.grey.shade700;
                        typeLabel = 'সাধারণ';
                    }

                    String timeText = '';
                    if (ts != null) {
                      final dt = ts.toDate();
                      final now = DateTime.now();
                      final diff = now.difference(dt);
                      if (diff.inMinutes < 60) {
                        timeText = '${diff.inMinutes} মিনিট আগে';
                      } else if (diff.inHours < 24) {
                        timeText = '${diff.inHours} ঘন্টা আগে';
                      } else {
                        timeText = '${diff.inDays} দিন আগে';
                      }
                    }

                    return GestureDetector(
                      onTap: () {
                        // Mark as read
                        FirebaseFirestore.instance
                            .collection('users')
                            .doc(userId)
                            .collection('notifications')
                            .doc(docId)
                            .update({'isRead': true});
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: isRead ? Colors.white : color.withOpacity(0.06),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isRead ? Colors.grey.shade200 : color.withOpacity(0.25),
                            width: isRead ? 1 : 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(icon, color: color, size: 24),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: color.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          typeLabel,
                                          style: GoogleFonts.hindSiliguri(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            color: color,
                                          ),
                                        ),
                                      ),
                                      if (!isRead) ...[
                                        const SizedBox(width: 8),
                                        Container(
                                          width: 8,
                                          height: 8,
                                          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                                        ),
                                      ],
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    message,
                                    style: GoogleFonts.hindSiliguri(
                                      fontSize: 14,
                                      color: Colors.black87,
                                      fontWeight: isRead ? FontWeight.normal : FontWeight.w600,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (timeText.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      timeText,
                                      style: GoogleFonts.hindSiliguri(
                                        fontSize: 12,
                                        color: Colors.grey.shade500,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_none, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'কোনো নোটিফিকেশন নেই',
            style: GoogleFonts.hindSiliguri(
              fontSize: 18,
              color: Colors.grey.shade500,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'নতুন অর্ডার বা আপডেট এলে এখানে দেখাবে',
            style: GoogleFonts.hindSiliguri(
              fontSize: 14,
              color: Colors.grey.shade400,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Future<void> _markAllRead(String userId) async {
    if (userId.isEmpty) return;
    final snapshots = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .where('isRead', isEqualTo: false)
        .get();

    final batch = FirebaseFirestore.instance.batch();
    for (final doc in snapshots.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();

    Get.snackbar(
      '✅ সব পড়া হয়েছে',
      'সব নোটিফিকেশন পঠিত হিসেবে চিহ্নিত হয়েছে',
      backgroundColor: Colors.green,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
