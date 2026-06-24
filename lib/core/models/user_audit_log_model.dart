import 'package:cloud_firestore/cloud_firestore.dart';

class UserAuditLogModel {
  final String id;
  final String userId;
  final String userName;
  final String action; // 'login', 'logout', 'failed_login', 'suspicious_activity'
  final String deviceInfo;
  final String ipAddress;
  final int? sessionDuration; // in seconds
  final String status; // 'success', 'failed', 'suspicious'
  final DateTime timestamp;

  UserAuditLogModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.action,
    required this.deviceInfo,
    required this.ipAddress,
    this.sessionDuration,
    required this.status,
    required this.timestamp,
  });

  factory UserAuditLogModel.fromMap(Map<String, dynamic> map, String docId) {
    return UserAuditLogModel(
      id: docId,
      userId: map['userId'] as String? ?? '',
      userName: map['userName'] as String? ?? 'Unknown',
      action: map['action'] as String? ?? 'UNKNOWN',
      deviceInfo: map['deviceInfo'] as String? ?? 'Unknown Device',
      ipAddress: map['ipAddress'] as String? ?? '',
      sessionDuration: map['sessionDuration'] as int?,
      status: map['status'] as String? ?? 'success',
      timestamp: map['timestamp'] != null
          ? (map['timestamp'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'action': action,
      'deviceInfo': deviceInfo,
      'ipAddress': ipAddress,
      'sessionDuration': sessionDuration,
      'status': status,
      'timestamp': timestamp,
    };
  }

  String getActionLabel() {
    switch (action) {
      case 'login':
        return 'Login';
      case 'logout':
        return 'Logout';
      case 'failed_login':
        return 'Failed Login';
      case 'suspicious_activity':
        return 'Suspicious Activity';
      default:
        return action;
    }
  }

  String getFormattedDuration() {
    if (sessionDuration == null) return 'N/A';
    if (sessionDuration! < 60) return '${sessionDuration}s';
    final minutes = sessionDuration! ~/ 60;
    final seconds = sessionDuration! % 60;
    if (minutes < 60) return '${minutes}m ${seconds}s';
    final hours = minutes ~/ 60;
    final remMins = minutes % 60;
    return '${hours}h ${remMins}m';
  }
}
