// Notification Models for Phase 2

enum NotificationType {
  order_received,
  order_shipped,
  order_delivered,
  new_message,
  rating_received,
  payment_received,
  contract_created,
  service_booked,
  trip_available,
  document_expiring,
  system_alert,
  farm_alert,
  portfolio_update,
  team_update,
}

class AppNotification {
  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final String icon;
  final String? actionUrl;
  final DateTime timestamp;
  final bool isRead;
  final String userRole;

  AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.icon,
    this.actionUrl,
    required this.timestamp,
    required this.isRead,
    required this.userRole,
  });
}

class NotificationPreferences {
  final String userId;
  final Map<NotificationType, bool> enabledNotifications;
  final bool soundEnabled;
  final bool vibrationEnabled;
  final String timezone;

  NotificationPreferences({
    required this.userId,
    required this.enabledNotifications,
    required this.soundEnabled,
    required this.vibrationEnabled,
    required this.timezone,
  });
}
