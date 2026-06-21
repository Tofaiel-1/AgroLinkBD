import 'package:cloud_firestore/cloud_firestore.dart';

/// Audit Log Model - Tracks all admin actions
class AuditLogModel {
  final String id;
  final String adminId;
  final String adminName;
  final String adminRole;
  final String actionType; // CREATE, UPDATE, DELETE, APPROVE, etc.
  final String entityType; // ADMIN, USER, PRODUCT, ORDER, etc.
  final String entityId;
  final Map<String, dynamic> oldValues; // Before changes
  final Map<String, dynamic> newValues; // After changes
  final String description; // Human readable
  final DateTime timestamp;
  final bool success;
  final String? errorMessage;
  final Map<String, dynamic>? metadata;

  AuditLogModel({
    required this.id,
    required this.adminId,
    required this.adminName,
    required this.adminRole,
    required this.actionType,
    required this.entityType,
    required this.entityId,
    required this.oldValues,
    required this.newValues,
    required this.description,
    required this.timestamp,
    required this.success,
    this.errorMessage,
    this.metadata,
  });

  /// Convert from Firestore map
  factory AuditLogModel.fromMap(Map<String, dynamic> map, String docId) {
    return AuditLogModel(
      id: docId,
      adminId: map['adminId'] as String? ?? '',
      adminName: map['adminName'] as String? ?? 'Unknown',
      adminRole: map['adminRole'] as String? ?? 'admin',
      actionType: map['actionType'] as String? ?? 'UNKNOWN',
      entityType: map['entityType'] as String? ?? 'UNKNOWN',
      entityId: map['entityId'] as String? ?? '',
      oldValues: (map['oldValues'] as Map<String, dynamic>?) ?? {},
      newValues: (map['newValues'] as Map<String, dynamic>?) ?? {},
      description: map['description'] as String? ?? '',
      timestamp: map['timestamp'] != null
          ? (map['timestamp'] as Timestamp).toDate()
          : DateTime.now(),
      success: map['success'] as bool? ?? true,
      errorMessage: map['errorMessage'] as String?,
      metadata: map['metadata'] as Map<String, dynamic>?,
    );
  }

  /// Convert to Firestore map
  Map<String, dynamic> toMap() {
    return {
      'adminId': adminId,
      'adminName': adminName,
      'adminRole': adminRole,
      'actionType': actionType,
      'entityType': entityType,
      'entityId': entityId,
      'oldValues': oldValues,
      'newValues': newValues,
      'description': description,
      'timestamp': timestamp,
      'success': success,
      'errorMessage': errorMessage,
      'metadata': metadata,
    };
  }

  /// Get readable action description
  String getActionLabel() {
    switch (actionType) {
      case 'ADMIN_CREATED':
        return '➕ Admin Created';
      case 'ADMIN_DELETED':
        return '❌ Admin Deleted';
      case 'ADMIN_UPDATED':
        return '✏️ Admin Updated';
      case 'ADMIN_SUSPENDED':
        return '🚫 Admin Suspended';
      case 'ADMIN_ACTIVATED':
        return '✅ Admin Activated';
      case 'USER_CREATED':
        return '➕ User Created';
      case 'USER_DELETED':
        return '❌ User Deleted';
      case 'USER_UPDATED':
        return '✏️ User Updated';
      case 'USER_BANNED':
        return '🚫 User Banned';
      case 'PRODUCT_CREATED':
        return '📦 Product Listed';
      case 'PRODUCT_APPROVED':
        return '✅ Product Approved';
      case 'PRODUCT_REJECTED':
        return '❌ Product Rejected';
      case 'PRODUCT_DELETED':
        return '🗑️ Product Deleted';
      case 'ORDER_PROCESSED':
        return '📋 Order Processed';
      case 'ORDER_SHIPPED':
        return '📤 Order Shipped';
      case 'ORDER_DELIVERED':
        return '📥 Order Delivered';
      case 'ORDER_CANCELLED':
        return '❌ Order Cancelled';
      default:
        return actionType;
    }
  }

  /// Get entity type icon
  String getEntityIcon() {
    switch (entityType) {
      case 'ADMIN':
        return '👨‍💼';
      case 'USER':
        return '👤';
      case 'PRODUCT':
        return '📦';
      case 'ORDER':
        return '📋';
      case 'SYSTEM':
        return '⚙️';
      default:
        return '📌';
    }
  }

  /// Get changes summary
  String getChangesSummary() {
    List<String> changes = [];

    // Check what changed
    for (var key in newValues.keys) {
      final oldVal = oldValues[key];
      final newVal = newValues[key];

      if (oldVal != newVal) {
        changes.add('$key: "$oldVal" → "$newVal"');
      }
    }

    return changes.isEmpty ? 'No specific changes' : changes.join(', ');
  }

  @override
  String toString() => 'AuditLog($actionType on $entityType)';
}

/// Collection of audit log utilities
class AuditLogUtils {
  /// Get color for action type
  static int getActionColor(String actionType) {
    if (actionType.contains('CREATED') || actionType.contains('APPROVED')) {
      return 0xFF4CAF50; // Green
    } else if (actionType.contains('DELETED') ||
        actionType.contains('REJECTED') ||
        actionType.contains('BANNED')) {
      return 0xFFF44336; // Red
    } else if (actionType.contains('UPDATED') ||
        actionType.contains('EDITED')) {
      return 0xFF2196F3; // Blue
    } else if (actionType.contains('SUSPENDED')) {
      return 0xFFFF9800; // Orange
    }
    return 0xFF9E9E9E; // Grey
  }

  /// Filter logs by date range
  static List<AuditLogModel> filterByDateRange(
    List<AuditLogModel> logs,
    DateTime startDate,
    DateTime endDate,
  ) {
    return logs
        .where((log) =>
            log.timestamp.isAfter(startDate) &&
            log.timestamp.isBefore(endDate.add(const Duration(days: 1))))
        .toList();
  }

  /// Group logs by action type
  static Map<String, List<AuditLogModel>> groupByActionType(
    List<AuditLogModel> logs,
  ) {
    Map<String, List<AuditLogModel>> grouped = {};

    for (var log in logs) {
      if (!grouped.containsKey(log.actionType)) {
        grouped[log.actionType] = [];
      }
      grouped[log.actionType]!.add(log);
    }

    return grouped;
  }

  /// Get statistics from logs
  static Map<String, int> getStatistics(List<AuditLogModel> logs) {
    return {
      'totalLogs': logs.length,
      'successfulActions': logs.where((l) => l.success).length,
      'failedActions': logs.where((l) => !l.success).length,
      'adminActions': logs.where((l) => l.entityType.contains('ADMIN')).length,
      'userActions': logs.where((l) => l.entityType.contains('USER')).length,
      'productActions':
          logs.where((l) => l.entityType.contains('PRODUCT')).length,
      'orderActions': logs.where((l) => l.entityType.contains('ORDER')).length,
    };
  }
}
