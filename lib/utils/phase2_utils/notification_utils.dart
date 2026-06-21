import 'package:flutter/material.dart';
import 'package:agrolinkbd/core/models/phase2_models/notification_models.dart';

/// Utilities for notification handling and formatting
class NotificationUtils {
  /// Get color for notification type
  static Color getNotificationColor(NotificationType type) {
    switch (type) {
      case NotificationType.order_received:
        return Colors.blue;
      case NotificationType.order_shipped:
        return Colors.orange;
      case NotificationType.order_delivered:
        return Colors.green;
      case NotificationType.new_message:
        return Colors.purple;
      case NotificationType.rating_received:
        return Colors.amber;
      case NotificationType.payment_received:
        return Colors.green;
      case NotificationType.contract_created:
        return Colors.blue;
      case NotificationType.service_booked:
        return Colors.teal;
      case NotificationType.trip_available:
        return Colors.orange;
      case NotificationType.document_expiring:
        return Colors.red;
      case NotificationType.system_alert:
        return Colors.grey;
      case NotificationType.farm_alert:
        return Colors.green;
      case NotificationType.portfolio_update:
        return Colors.purple;
      case NotificationType.team_update:
        return Colors.blue;
    }
  }

  /// Get icon for notification type
  static IconData getNotificationIcon(NotificationType type) {
    switch (type) {
      case NotificationType.order_received:
        return Icons.shopping_bag;
      case NotificationType.order_shipped:
        return Icons.local_shipping;
      case NotificationType.order_delivered:
        return Icons.check_circle;
      case NotificationType.new_message:
        return Icons.message;
      case NotificationType.rating_received:
        return Icons.star;
      case NotificationType.payment_received:
        return Icons.payment;
      case NotificationType.contract_created:
        return Icons.assignment;
      case NotificationType.service_booked:
        return Icons.calendar_month;
      case NotificationType.trip_available:
        return Icons.directions_car;
      case NotificationType.document_expiring:
        return Icons.warning;
      case NotificationType.system_alert:
        return Icons.notifications;
      case NotificationType.farm_alert:
        return Icons.agriculture;
      case NotificationType.portfolio_update:
        return Icons.image;
      case NotificationType.team_update:
        return Icons.people;
    }
  }

  /// Get title for notification type
  static String getNotificationTitle(NotificationType type) {
    switch (type) {
      case NotificationType.order_received:
        return 'New Order';
      case NotificationType.order_shipped:
        return 'Order Shipped';
      case NotificationType.order_delivered:
        return 'Order Delivered';
      case NotificationType.new_message:
        return 'New Message';
      case NotificationType.rating_received:
        return 'New Rating';
      case NotificationType.payment_received:
        return 'Payment Received';
      case NotificationType.contract_created:
        return 'Contract Created';
      case NotificationType.service_booked:
        return 'Service Booked';
      case NotificationType.trip_available:
        return 'Trip Available';
      case NotificationType.document_expiring:
        return 'Document Expiring';
      case NotificationType.system_alert:
        return 'System Alert';
      case NotificationType.farm_alert:
        return 'Farm Alert';
      case NotificationType.portfolio_update:
        return 'Portfolio Updated';
      case NotificationType.team_update:
        return 'Team Update';
    }
  }
}
