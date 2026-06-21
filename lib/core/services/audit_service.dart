import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// Audit Service - Comprehensive activity logging
/// Logs every admin action with before/after values for compliance & debugging
class AuditService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Log admin action with full details
  Future<void> logAdminAction({
    required String adminId,
    required String adminName,
    required String actionType,
    required String entityType,
    required String entityId,
    required String description,
    Map<String, dynamic>? oldValues,
    Map<String, dynamic>? newValues,
    bool success = true,
    String? errorMessage,
  }) async {
    try {
      await _firestore.collection('audit_logs').add({
        'adminId': adminId,
        'adminName': adminName,
        'actionType': actionType,
        'entityType': entityType,
        'entityId': entityId,
        'oldValues': oldValues ?? {},
        'newValues': newValues ?? {},
        'description': description,
        'timestamp': FieldValue.serverTimestamp(),
        'success': success,
        'errorMessage': errorMessage,
        'metadata': {
          'platform': 'flutter',
          'version': '1.0.0',
        },
      });

      debugPrint('✅ Logged: $actionType - $description');
    } catch (e) {
      debugPrint('❌ Error logging action: $e');
      // Don't fail the main operation if logging fails
    }
  }

  /// Log user action (for non-admin users)
  Future<void> logUserAction({
    required String userId,
    required String actionType,
    required String description,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      await _firestore.collection('audit_logs').add({
        'userId': userId,
        'actionType': actionType,
        'entityType': 'USER',
        'description': description,
        'timestamp': FieldValue.serverTimestamp(),
        'metadata': metadata ?? {},
      });
    } catch (e) {
      debugPrint('Error logging user action: $e');
    }
  }

  /// Get audit logs with filters
  Future<List<Map<String, dynamic>>> getAuditLogs({
    String? adminId,
    String? actionType,
    String? entityType,
    DateTime? startDate,
    DateTime? endDate,
    int limit = 100,
  }) async {
    try {
      Query query = _firestore.collection('audit_logs');

      if (adminId != null) {
        query = query.where('adminId', isEqualTo: adminId);
      }

      if (actionType != null) {
        query = query.where('actionType', isEqualTo: actionType);
      }

      if (entityType != null) {
        query = query.where('entityType', isEqualTo: entityType);
      }

      if (startDate != null) {
        query = query.where('timestamp', isGreaterThanOrEqualTo: startDate);
      }

      if (endDate != null) {
        query = query.where('timestamp', isLessThanOrEqualTo: endDate);
      }

      final snapshot =
          await query.orderBy('timestamp', descending: true).limit(limit).get();

      return snapshot.docs
          .map((doc) => {...doc.data() as Map<String, dynamic>, 'id': doc.id})
          .toList();
    } catch (e) {
      debugPrint('Error retrieving audit logs: $e');
      return [];
    }
  }

  /// Get admin activity summary for specific date
  Future<Map<String, dynamic>> getAdminActivitySummary(
    String adminId, {
    DateTime? date,
  }) async {
    try {
      date = date ?? DateTime.now();
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final snapshot = await _firestore
          .collection('audit_logs')
          .where('adminId', isEqualTo: adminId)
          .where('timestamp', isGreaterThanOrEqualTo: startOfDay)
          .where('timestamp', isLessThan: endOfDay)
          .get();

      Map<String, int> actions = {};
      for (var doc in snapshot.docs) {
        final action = doc['actionType'] as String;
        actions[action] = (actions[action] ?? 0) + 1;
      }

      return {
        'totalActions': snapshot.docs.length,
        'actionBreakdown': actions,
        'date': date.toIso8601String().split('T')[0],
      };
    } catch (e) {
      debugPrint('Error getting activity summary: $e');
      return {};
    }
  }

  /// Get system activity statistics
  Future<Map<String, dynamic>> getSystemActivityStats({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      endDate = endDate ?? DateTime.now();
      startDate = startDate ?? endDate.subtract(const Duration(days: 30));

      final snapshot = await _firestore
          .collection('audit_logs')
          .where('timestamp', isGreaterThanOrEqualTo: startDate)
          .where('timestamp', isLessThanOrEqualTo: endDate)
          .get();

      Map<String, int> actionCounts = {};
      Map<String, int> adminCounts = {};
      int successCount = 0;
      int failureCount = 0;

      for (var doc in snapshot.docs) {
        final actionType = doc['actionType'] as String;
        final adminName = doc['adminName'] as String? ?? 'Unknown';
        final success = doc['success'] as bool? ?? true;

        actionCounts[actionType] = (actionCounts[actionType] ?? 0) + 1;
        adminCounts[adminName] = (adminCounts[adminName] ?? 0) + 1;

        if (success) {
          successCount++;
        } else {
          failureCount++;
        }
      }

      return {
        'totalActions': snapshot.docs.length,
        'successCount': successCount,
        'failureCount': failureCount,
        'actionBreakdown': actionCounts,
        'adminBreakdown': adminCounts,
        'period': {
          'start': startDate.toIso8601String(),
          'end': endDate.toIso8601String(),
        },
      };
    } catch (e) {
      debugPrint('Error getting system stats: $e');
      return {};
    }
  }

  /// Export audit logs to CSV format
  Future<String> exportAuditLogsAsCSV({
    String? adminId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final logs = await getAuditLogs(
        adminId: adminId,
        startDate: startDate,
        endDate: endDate,
        limit: 10000,
      );

      // CSV Header
      StringBuffer csv = StringBuffer();
      csv.writeln(
          'Timestamp,Admin Name,Action Type,Entity Type,Entity ID,Description,Success');

      // CSV Rows
      for (var log in logs) {
        final timestamp = log['timestamp']?.toDate() ?? DateTime.now();
        final adminName = log['adminName'] ?? 'N/A';
        final actionType = log['actionType'] ?? 'N/A';
        final entityType = log['entityType'] ?? 'N/A';
        final entityId = log['entityId'] ?? 'N/A';
        final description = (log['description'] ?? '').replaceAll(',', ';');
        final success = log['success'] ?? true;

        csv.writeln(
            '$timestamp,$adminName,$actionType,$entityType,$entityId,"$description",$success');
      }

      return csv.toString();
    } catch (e) {
      debugPrint('Error exporting logs: $e');
      return '';
    }
  }

  /// Delete old audit logs (data retention policy)
  Future<int> deleteOldAuditLogs(int daysToKeep) async {
    try {
      final cutoffDate = DateTime.now().subtract(Duration(days: daysToKeep));

      final snapshot = await _firestore
          .collection('audit_logs')
          .where('timestamp', isLessThan: cutoffDate)
          .get();

      int deletedCount = 0;
      for (var doc in snapshot.docs) {
        await doc.reference.delete();
        deletedCount++;
      }

      debugPrint('✅ Deleted $deletedCount old audit logs');
      return deletedCount;
    } catch (e) {
      debugPrint('Error deleting old logs: $e');
      return 0;
    }
  }

  /// Search audit logs by keyword
  Future<List<Map<String, dynamic>>> searchAuditLogs(
    String keyword, {
    int limit = 100,
  }) async {
    try {
      final snapshot = await _firestore
          .collection('audit_logs')
          .orderBy('timestamp', descending: true)
          .limit(limit * 2) // Get more to filter
          .get();

      final keywordLower = keyword.toLowerCase();
      final results = snapshot.docs
          .where((doc) {
            final description =
                (doc['description'] as String? ?? '').toLowerCase();
            final adminName = (doc['adminName'] as String? ?? '').toLowerCase();
            return description.contains(keywordLower) ||
                adminName.contains(keywordLower);
          })
          .map((doc) => {...doc.data(), 'id': doc.id})
          .take(limit)
          .toList();

      return results;
    } catch (e) {
      debugPrint('Error searching audit logs: $e');
      return [];
    }
  }
}
