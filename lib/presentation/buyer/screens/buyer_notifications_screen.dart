import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:agrolinkbd/core/providers/language_provider.dart';

class BuyerNotificationsScreen extends StatefulWidget {
  const BuyerNotificationsScreen({super.key});

  @override
  State<BuyerNotificationsScreen> createState() =>
      _BuyerNotificationsScreenState();
}

class _BuyerNotificationsScreenState extends State<BuyerNotificationsScreen> {
  static const Color _primaryBlue = Color(0xFF1976D2);
  String _selectedFilter = 'all';

  String get _currentUid => FirebaseAuth.instance.currentUser?.uid ?? '';

  Future<void> _markAllAsRead() async {
    if (_currentUid.isEmpty) return;
    final collection = FirebaseFirestore.instance
        .collection('users')
        .doc(_currentUid)
        .collection('notifications');

    final unreadSnap =
        await collection.where('read', isEqualTo: false).get();
    for (var doc in unreadSnap.docs) {
      await doc.reference.update({'read': true});
    }
  }

  Future<void> _toggleRead(String docId, bool currentStatus) async {
    if (_currentUid.isEmpty) return;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(_currentUid)
        .collection('notifications')
        .doc(docId)
        .update({'read': !currentStatus});
  }

  Future<void> _deleteNotification(String docId) async {
    if (_currentUid.isEmpty) return;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(_currentUid)
        .collection('notifications')
        .doc(docId)
        .delete();
  }

  @override
  Widget build(BuildContext context) {
    final isBn = LanguageProvider.isBn(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final Color bgColor =
        isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final Color cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final Color cardBorder =
        isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    final Color textPrimary =
        isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A);
    final Color textSecondary =
        isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isBn ? 'বিজ্ঞপ্তি' : 'Notifications',
          style: GoogleFonts.hindSiliguri(
            color: textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          TextButton.icon(
            onPressed: _markAllAsRead,
            icon: const Icon(Icons.done_all_rounded,
                size: 16, color: _primaryBlue),
            label: Text(
              isBn ? 'সব পঠিত' : 'Read all',
              style: GoogleFonts.hindSiliguri(
                color: _primaryBlue,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Filter Pills
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                _buildFilterChip('all', isBn ? 'সকল' : 'All', isDark),
                const SizedBox(width: 8),
                _buildFilterChip('order', isBn ? 'অর্ডার' : 'Orders', isDark),
                const SizedBox(width: 8),
                _buildFilterChip('promo', isBn ? 'অফার' : 'Offers', isDark),
              ],
            ),
          ),

          // Notifications Stream List
          Expanded(
            child: _currentUid.isEmpty
                ? _buildEmptyState(isBn, textPrimary, textSecondary)
                : StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .doc(_currentUid)
                        .collection('notifications')
                        .orderBy('createdAt', descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(color: _primaryBlue),
                        );
                      }

                      final allDocs = snapshot.data?.docs ?? [];
                      final filteredDocs = allDocs.where((doc) {
                        if (_selectedFilter == 'all') return true;
                        final data = doc.data() as Map<String, dynamic>;
                        return (data['type'] ?? '') == _selectedFilter;
                      }).toList();

                      if (filteredDocs.isEmpty) {
                        // Fallback sample alerts so screen is informative if no firebase items yet
                        return _buildDefaultShowcase(
                          isBn,
                          isDark,
                          cardBg,
                          cardBorder,
                          textPrimary,
                          textSecondary,
                        );
                      }

                      return ListView.separated(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        itemCount: filteredDocs.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final doc = filteredDocs[index];
                          final data = doc.data() as Map<String, dynamic>;
                          final bool isRead = data['read'] == true;
                          final String title = isBn
                              ? (data['title_bn'] ??
                                  data['title'] ??
                                  'অর্ডারের আপডেট')
                              : (data['title_en'] ??
                                  data['title'] ??
                                  'Order Update');
                          final String body = isBn
                              ? (data['body_bn'] ?? data['body'] ?? '')
                              : (data['body_en'] ?? data['body'] ?? '');
                          final String type = data['type'] ?? 'order';

                          return Dismissible(
                            key: Key(doc.id),
                            direction: DismissDirection.endToStart,
                            onDismissed: (_) => _deleteNotification(doc.id),
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              decoration: BoxDecoration(
                                color: Colors.red.shade400,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Icon(Icons.delete_outline,
                                  color: Colors.white),
                            ),
                            child: _buildNotificationCard(
                              id: doc.id,
                              title: title,
                              body: body,
                              type: type,
                              isRead: isRead,
                              timestamp: (data['createdAt'] as Timestamp?)
                                  ?.toDate(),
                              isDark: isDark,
                              cardBg: cardBg,
                              cardBorder: cardBorder,
                              textPrimary: textPrimary,
                              textSecondary: textSecondary,
                              isBn: isBn,
                              onTap: () => _toggleRead(doc.id, isRead),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String filterKey, String label, bool isDark) {
    final isSelected = _selectedFilter == filterKey;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = filterKey),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? _primaryBlue
              : (isDark ? const Color(0xFF1E293B) : Colors.white),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? _primaryBlue
                : (isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.hindSiliguri(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isSelected
                ? Colors.white
                : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationCard({
    required String id,
    required String title,
    required String body,
    required String type,
    required bool isRead,
    DateTime? timestamp,
    required bool isDark,
    required Color cardBg,
    required Color cardBorder,
    required Color textPrimary,
    required Color textSecondary,
    required bool isBn,
    required VoidCallback onTap,
  }) {
    IconData icon = Icons.notifications_active_outlined;
    Color iconColor = _primaryBlue;

    if (type == 'order') {
      icon = Icons.local_shipping_outlined;
      iconColor = const Color(0xFF10B981);
    } else if (type == 'promo') {
      icon = Icons.local_offer_outlined;
      iconColor = const Color(0xFFF59E0B);
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isRead
              ? cardBg
              : (isDark
                  ? const Color(0xFF1E293B).withValues(alpha: 0.95)
                  : const Color(0xFFEFF6FF)),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isRead ? cardBorder : _primaryBlue.withValues(alpha: 0.3),
            width: isRead ? 1 : 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: GoogleFonts.hindSiliguri(
                            fontSize: 13.5,
                            fontWeight:
                                isRead ? FontWeight.w600 : FontWeight.bold,
                            color: textPrimary,
                          ),
                        ),
                      ),
                      if (!isRead)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: _primaryBlue,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    body,
                    style: GoogleFonts.hindSiliguri(
                      fontSize: 11.5,
                      color: textSecondary,
                    ),
                  ),
                  if (timestamp != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      '${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')} • ${timestamp.day}/${timestamp.month}',
                      style: GoogleFonts.hindSiliguri(
                        fontSize: 10,
                        color: textSecondary.withValues(alpha: 0.7),
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
  }

  Widget _buildDefaultShowcase(
    bool isBn,
    bool isDark,
    Color cardBg,
    Color cardBorder,
    Color textPrimary,
    Color textSecondary,
  ) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      children: [
        _buildNotificationCard(
          id: 'def_1',
          title: isBn
              ? 'স্বাগতম এগ্রোলিংক বিডি-তে!'
              : 'Welcome to AgroLinkBD!',
          body: isBn
              ? 'কৃষকের কাছ থেকে সরাসরি সেরা দামে কৃষি পণ্য কিনুন।'
              : 'Buy direct agricultural produce at the best prices.',
          type: 'promo',
          isRead: false,
          timestamp: DateTime.now(),
          isDark: isDark,
          cardBg: cardBg,
          cardBorder: cardBorder,
          textPrimary: textPrimary,
          textSecondary: textSecondary,
          isBn: isBn,
          onTap: () {},
        ),
        const SizedBox(height: 10),
        _buildNotificationCard(
          id: 'def_2',
          title: isBn ? 'এস্ক্রো সিকিউরিটি সক্রিয়' : 'Escrow Security Active',
          body: isBn
              ? 'পণ্য হাতে পেয়ে কোয়ালিটি চেক করার পর পেমেন্ট ছাড় হবে।'
              : 'Payment is released only after you inspect produce quality.',
          type: 'order',
          isRead: true,
          timestamp: DateTime.now().subtract(const Duration(hours: 3)),
          isDark: isDark,
          cardBg: cardBg,
          cardBorder: cardBorder,
          textPrimary: textPrimary,
          textSecondary: textSecondary,
          isBn: isBn,
          onTap: () {},
        ),
        const SizedBox(height: 10),
        _buildNotificationCard(
          id: 'def_3',
          title: isBn
              ? '👑 ভিআইপি ট্রেডার্স পাস সুবিধা'
              : '👑 VIP Traders Pass Advantage',
          body: isBn
              ? 'ভিআইপি মেম্বারশিপে ০% কমিশন ও সরাসরি অগ্রাধিকার ডেলিভারি।'
              : 'Enjoy 0% platform fee and priority delivery with VIP pass.',
          type: 'promo',
          isRead: true,
          timestamp: DateTime.now().subtract(const Duration(days: 1)),
          isDark: isDark,
          cardBg: cardBg,
          cardBorder: cardBorder,
          textPrimary: textPrimary,
          textSecondary: textSecondary,
          isBn: isBn,
          onTap: () {},
        ),
      ],
    );
  }

  Widget _buildEmptyState(
      bool isBn, Color textPrimary, Color textSecondary) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_off_outlined,
              size: 56, color: textSecondary.withValues(alpha: 0.5)),
          const SizedBox(height: 12),
          Text(
            isBn ? 'কোনো নতুন বিজ্ঞপ্তি নেই' : 'No notifications yet',
            style: GoogleFonts.hindSiliguri(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            isBn
                ? 'আপনার অর্ডার ও অফারের আপডেট এখানে দেখানো হবে'
                : 'Updates about your orders & offers will show here',
            style: GoogleFonts.hindSiliguri(
              fontSize: 12,
              color: textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
