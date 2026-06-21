import 'package:agrolinkbd/core/models/phase2_models/notification_models.dart';

/// Mock data for notification module testing
class NotificationMocks {
  /// Sample notifications for farmer
  static List<AppNotification> getFarmerNotifications() {
    return [
      AppNotification(
        id: '1',
        title: 'New Order Received',
        message: 'Buyer ordered 50kg Tomatoes for ৳5,000',
        type: NotificationType.order_received,
        icon: 'shopping_bag',
        timestamp: DateTime.now(),
        isRead: false,
        userRole: 'farmer',
      ),
      AppNotification(
        id: '2',
        title: 'Product Review',
        message: '5-star review: Great quality and fresh products!',
        type: NotificationType.rating_received,
        icon: 'star',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        isRead: true,
        userRole: 'farmer',
      ),
      AppNotification(
        id: '3',
        title: 'Payment Received',
        message: '৳12,500 deposited to your account',
        type: NotificationType.payment_received,
        icon: 'payment',
        timestamp: DateTime.now().subtract(const Duration(hours: 5)),
        isRead: true,
        userRole: 'farmer',
      ),
    ];
  }

  /// Sample notifications for buyer
  static List<AppNotification> getBuyerNotifications() {
    return [
      AppNotification(
        id: '1',
        title: 'Order Confirmed',
        message: 'Your order #ORD123 has been confirmed',
        type: NotificationType.order_received,
        icon: 'check_circle',
        timestamp: DateTime.now(),
        isRead: false,
        userRole: 'buyer',
      ),
      AppNotification(
        id: '2',
        title: 'Delivery Arriving Soon',
        message: 'Your order arrives in 15 minutes',
        type: NotificationType.order_shipped,
        icon: 'local_shipping',
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
        isRead: true,
        userRole: 'buyer',
      ),
    ];
  }

  /// Sample notifications for driver
  static List<AppNotification> getDriverNotifications() {
    return [
      AppNotification(
        id: '1',
        title: 'New Trip Available',
        message: 'Trip to Gulshan - ৳250 earnings',
        type: NotificationType.trip_available,
        icon: 'directions_car',
        timestamp: DateTime.now(),
        isRead: false,
        userRole: 'driver',
      ),
      AppNotification(
        id: '2',
        title: 'Trip Assigned',
        message: 'Order #DL456 assigned to you',
        type: NotificationType.order_received,
        icon: 'assignment',
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
        isRead: true,
        userRole: 'driver',
      ),
    ];
  }

  /// Sample preferences
  static NotificationPreferences getDefaultPreferences(String userId) {
    return NotificationPreferences(
      userId: userId,
      enabledNotifications: {
        NotificationType.order_received: true,
        NotificationType.order_shipped: true,
        NotificationType.order_delivered: true,
        NotificationType.new_message: true,
        NotificationType.rating_received: true,
        NotificationType.payment_received: true,
        NotificationType.contract_created: true,
        NotificationType.service_booked: true,
        NotificationType.trip_available: true,
        NotificationType.document_expiring: true,
        NotificationType.system_alert: true,
        NotificationType.farm_alert: true,
        NotificationType.portfolio_update: true,
        NotificationType.team_update: true,
      },
      soundEnabled: true,
      vibrationEnabled: true,
      timezone: 'Asia/Dhaka',
    );
  }
}
