import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';

enum DriverNotificationType {
  newTrip,          // নতুন ট্রিপ রিকোয়েস্ট (Action Heavy)
  tripStatus,       // ট্রিপ স্ট্যাটাস আপডেট
  earnings,         // আয় ও বোনাস
  vehicleAlert,     // সিস্টেম/ভেহিকেল অ্যালার্ট (License Expiry)
  routeAlert,       // আবহাওয়া ও রুট অ্যালার্ট
}

class DriverNotification {
  final String id;
  final String title;
  final String message;
  final DriverNotificationType type;
  final DateTime timestamp;
  final bool isRead;
  final Map<String, dynamic>? data;

  DriverNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.timestamp,
    this.isRead = false,
    this.data,
  });

  DriverNotification copyWith({
    String? id,
    String? title,
    String? message,
    DriverNotificationType? type,
    DateTime? timestamp,
    bool? isRead,
    Map<String, dynamic>? data,
  }) {
    return DriverNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      data: data ?? this.data,
    );
  }
}

class DriverNotificationNotifier extends StateNotifier<List<DriverNotification>> {
  DriverNotificationNotifier() : super([]) {
    _loadMockData();
  }

  void _loadMockData() {
    state = [
      DriverNotification(
        id: 'trip_1001',
        title: 'নতুন ট্রিপ রিকোয়েস্ট',
        message: 'নতুন ট্রিপ পাওয়া গেছে! দ্রুত অ্যাকসেপ্ট করুন।',
        type: DriverNotificationType.newTrip,
        timestamp: DateTime.now().subtract(const Duration(seconds: 30)),
        data: {
          'pickup': 'মহাস্থানগড়, বগুড়া',
          'dropoff': 'কাওরান বাজার, ঢাকা',
          'distance': '১৯৫ কিমি',
          'est_time': '৫ ঘণ্টা ২০ মিনিট',
          'cargo': '৫০০ কেজি গোল আলু',
          'fare': '৳ ৬,৫০০',
          'expires_in_seconds': 60,
        },
      ),
      DriverNotification(
        id: 'alert_101',
        title: 'রাস্তার অবস্থা',
        message: 'টাঙ্গাইল হাইওয়েতে বর্তমানে দীর্ঘ যানজট রয়েছে। দয়া করে বিকল্প রুট ব্যবহার করার চেষ্টা করুন।',
        type: DriverNotificationType.routeAlert,
        timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
      ),
      DriverNotification(
        id: 'earn_505',
        title: 'পেমেন্ট ওয়ালেটে যুক্ত হয়েছে',
        message: 'ট্রিপ #TR-9092 সম্পূর্ণ করার জন্য আপনার ওয়ালেটে পেমেন্ট যুক্ত হয়েছে।',
        type: DriverNotificationType.earnings,
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        data: {
          'amount': '৳ ৫,২০০',
          'bonus': '৳ ৩০০',
        },
      ),
      DriverNotification(
        id: 'status_202',
        title: 'কৃষক পণ্য প্যাক করেছেন',
        message: 'কৃষক মোঃ জলিল পণ্য পিকআপের জন্য প্রস্তুত রেখেছেন। আপনি পিকআপ লোকেশনের দিকে রওনা দিন।',
        type: DriverNotificationType.tripStatus,
        timestamp: DateTime.now().subtract(const Duration(hours: 5)),
      ),
      DriverNotification(
        id: 'sys_001',
        title: 'জরুরী: ড্রাইভিং লাইসেন্স',
        message: 'আপনার ড্রাইভিং লাইসেন্সের মেয়াদ আগামী ১৫ দিনের মধ্যে শেষ হতে যাচ্ছে। দ্রুত নবায়ন করুন।',
        type: DriverNotificationType.vehicleAlert,
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        isRead: true,
      ),
    ];
  }

  void addNotification(DriverNotification notification) {
    state = [notification, ...state];
  }

  void markAsRead(String id) {
    state = [
      for (final n in state)
        if (n.id == id) n.copyWith(isRead: true) else n
    ];
  }

  void markAllAsRead() {
    state = [for (final n in state) n.copyWith(isRead: true)];
  }

  void deleteNotification(String id) {
    state = state.where((n) => n.id != id).toList();
  }
}

final driverNotificationProvider =
    StateNotifierProvider<DriverNotificationNotifier, List<DriverNotification>>((ref) {
  return DriverNotificationNotifier();
});

final unreadDriverNotificationCountProvider = Provider<int>((ref) {
  final notifications = ref.watch(driverNotificationProvider);
  return notifications.where((n) => !n.isRead).length;
});

final notificationFilterProvider = StateProvider<String>((ref) => 'সব');
