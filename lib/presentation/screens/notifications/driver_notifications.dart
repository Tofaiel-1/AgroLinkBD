import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:agrolinkbd/core/providers/driver_notification_provider.dart';
import 'package:get/get.dart';

class DriverNotificationsScreen extends ConsumerStatefulWidget {
  const DriverNotificationsScreen({super.key});

  @override
  ConsumerState<DriverNotificationsScreen> createState() => _DriverNotificationsScreenState();
}

class _DriverNotificationsScreenState extends ConsumerState<DriverNotificationsScreen> {
  final List<String> _filters = ['সব', 'ট্রিপ', 'আয়', 'অ্যালার্ট'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(driverNotificationProvider.notifier).markAllAsRead();
    });
  }

  @override
  Widget build(BuildContext context) {
    final notifications = ref.watch(driverNotificationProvider);
    final activeFilter = ref.watch(notificationFilterProvider);

    final filteredNotifications = notifications.where((n) {
      if (activeFilter == 'সব') return true;
      if (activeFilter == 'ট্রিপ' && (n.type == DriverNotificationType.newTrip || n.type == DriverNotificationType.tripStatus)) return true;
      if (activeFilter == 'আয়' && n.type == DriverNotificationType.earnings) return true;
      if (activeFilter == 'অ্যালার্ট' &&
          (n.type == DriverNotificationType.vehicleAlert ||
           n.type == DriverNotificationType.routeAlert)) return true;
      return false;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6), // Professional cool grey
      appBar: AppBar(
        backgroundColor: const Color(0xFFF57C00),
        elevation: 0,
        title: Text(
          'নোটিফিকেশন (ড্রাইভার)',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.white,
            fontSize: 18,
          ),
        ),
        actions: [
          if (notifications.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.playlist_remove_rounded, color: Colors.white),
              tooltip: 'সব মুছুন',
              onPressed: () {
                Get.snackbar(
                  'নোটিফিকেশন',
                  'সব নোটিফিকেশন মুছে ফেলা হয়েছে',
                  snackPosition: SnackPosition.BOTTOM,
                );
              },
            ),
        ],
      ),
      body: Column(
        children: [
          // Filter Chips Section
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: _filters.map((filter) {
                  final isSelected = activeFilter == filter;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(
                        filter,
                        style: GoogleFonts.poppins(
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                          color: isSelected ? Colors.white : Colors.grey.shade700,
                        ),
                      ),
                      selected: isSelected,
                      selectedColor: const Color(0xFFF57C00),
                      backgroundColor: Colors.grey.shade100,
                      side: BorderSide(color: isSelected ? Colors.transparent : Colors.grey.shade300),
                      onSelected: (selected) {
                        if (selected) {
                          ref.read(notificationFilterProvider.notifier).state = filter;
                        }
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          
          // Notifications List Section
          Expanded(
            child: filteredNotifications.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredNotifications.length,
                    itemBuilder: (context, index) {
                      final notification = filteredNotifications[index];
                      return _buildNotificationCard(notification);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_rounded,
              size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'কোনো নোটিফিকেশন নেই',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'ড্রাইভিং সংক্রান্ত সকল আপডেট এখানে দেখতে পাবেন',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(DriverNotification notification) {
    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        ref.read(driverNotificationProvider.notifier).deleteNotification(notification.id);
      },
      background: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFE53935), // Red
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: const Icon(Icons.delete_sweep_rounded, color: Colors.white, size: 32),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: notification.isRead ? Colors.transparent : Colors.grey.shade200,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: notification.isRead ? 0.02 : 0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Colored indicator bar at the top
              Container(
                height: 4,
                width: double.infinity,
                color: _getAccentColor(notification.type),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header: Icon, Title, Time
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: _getAccentColor(notification.type).withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(_getIconData(notification.type), 
                                      color: _getAccentColor(notification.type), size: 24),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                notification.title,
                                style: GoogleFonts.poppins(
                                  fontSize: 15,
                                  fontWeight: notification.isRead ? FontWeight.w600 : FontWeight.w700,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _formatTime(notification.timestamp),
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    
                    // Message
                    Text(
                      notification.message,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.grey.shade700,
                        height: 1.5,
                      ),
                    ),
                    
                    // Dynamic Payload specific to Driver
                    _buildDynamicPayload(notification),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDynamicPayload(DriverNotification notification) {
    if (notification.data == null) return const SizedBox.shrink();

    if (notification.type == DriverNotificationType.newTrip) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          // Route Visualization
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.my_location_rounded, size: 16, color: Colors.blue),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        notification.data!['pickup'] ?? '',
                        style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 7),
                  child: Container(
                    height: 20,
                    width: 2,
                    color: Colors.grey.shade300,
                  ),
                ),
                Row(
                  children: [
                    const Icon(Icons.location_on_rounded, size: 16, color: Colors.red),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        notification.data!['dropoff'] ?? '',
                        style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24),
                // Trip Details Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('দূরত্ব', style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey.shade500)),
                        Text(notification.data!['distance'] ?? '', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600)),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('পণ্য', style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey.shade500)),
                        Text(notification.data!['cargo'] ?? '', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600)),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('ভাড়া', style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey.shade500)),
                        Text(
                          notification.data!['fare'] ?? '', 
                          style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.green.shade700)
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Action Buttons
          Row(
            children: [
              Expanded(
                flex: 1,
                child: OutlinedButton(
                  onPressed: () {
                    ref.read(driverNotificationProvider.notifier).deleteNotification(notification.id);
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    foregroundColor: Colors.red.shade700,
                    side: BorderSide(color: Colors.red.shade200),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text('বাতিল', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: () {
                    Get.snackbar(
                      'ট্রিপ গৃহীত',
                      'আপনি ট্রিপটি সফলভাবে গ্রহণ করেছেন। নেভিগেশন শুরু হচ্ছে...',
                      backgroundColor: Colors.green.shade800,
                      colorText: Colors.white,
                      icon: const Icon(Icons.check_circle, color: Colors.white),
                    );
                    ref.read(driverNotificationProvider.notifier).deleteNotification(notification.id);
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    backgroundColor: const Color(0xFFF57C00),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text(
                    'ট্রিপ গ্রহণ করুন', 
                    style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    } 
    
    if (notification.type == DriverNotificationType.earnings) {
      return Column(
        children: [
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green.shade100),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'মোট আয়:',
                  style: GoogleFonts.poppins(fontSize: 14, color: Colors.green.shade800),
                ),
                Text(
                  notification.data!['amount'] ?? '',
                  style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green.shade800),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.account_balance_wallet_rounded, size: 18),
              label: Text('ওয়ালেট চেক করুন', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFFF57C00),
              ),
            ),
          ),
        ],
      );
    }

    return const SizedBox.shrink();
  }

  Color _getAccentColor(DriverNotificationType type) {
    switch (type) {
      case DriverNotificationType.newTrip:
        return const Color(0xFFF57C00); // AgroLink Orange
      case DriverNotificationType.earnings:
        return const Color(0xFF2E7D32); // Deep Green
      case DriverNotificationType.tripStatus:
        return const Color(0xFF1976D2); // Trust Blue
      case DriverNotificationType.vehicleAlert:
        return const Color(0xFFD32F2F); // Alert Red
      case DriverNotificationType.routeAlert:
        return const Color(0xFFFBC02D); // Warning Yellow
    }
  }

  IconData _getIconData(DriverNotificationType type) {
    switch (type) {
      case DriverNotificationType.newTrip:
        return Icons.airport_shuttle_rounded;
      case DriverNotificationType.earnings:
        return Icons.payments_rounded;
      case DriverNotificationType.tripStatus:
        return Icons.verified_rounded;
      case DriverNotificationType.vehicleAlert:
        return Icons.gpp_maybe_rounded;
      case DriverNotificationType.routeAlert:
        return Icons.traffic_rounded;
    }
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} মি. আগে';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} ঘ. আগে';
    } else {
      return '${difference.inDays} দিন আগে';
    }
  }
}
