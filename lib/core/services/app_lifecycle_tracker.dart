import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:agrolinkbd/core/services/audit_service.dart';
import 'package:agrolinkbd/core/services/auth_service.dart';

class AppLifecycleTracker extends StatefulWidget {
  final Widget child;

  const AppLifecycleTracker({super.key, required this.child});

  @override
  State<AppLifecycleTracker> createState() => _AppLifecycleTrackerState();
}

class _AppLifecycleTrackerState extends State<AppLifecycleTracker> with WidgetsBindingObserver {
  final AuditService _auditService = AuditService();
  final AuthService _authService = AuthService(); // Used to get device info
  
  DateTime? _sessionStartTime;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _sessionStartTime = DateTime.now();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _sessionStartTime = DateTime.now();
    } else if (state == AppLifecycleState.paused || state == AppLifecycleState.detached) {
      _logSessionEnd();
    }
  }

  Future<void> _logSessionEnd() async {
    if (_sessionStartTime == null) return;
    
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final duration = DateTime.now().difference(_sessionStartTime!).inSeconds;
      
      // Only log if they spent more than 5 seconds in the app
      if (duration > 5) {
        try {
          // We can't use await getDeviceInfo here easily because app is pausing,
          // but we can just use a placeholder or basic string.
          // Actually, we can run it asynchronously.
          _auditService.logUserSessionEvent(
            userId: user.uid,
            userName: user.email ?? user.phoneNumber ?? 'Unknown',
            action: 'app_session_ended',
            deviceInfo: 'App Backgrounded',
            sessionDuration: duration,
          );
        } catch (e) {
          debugPrint('Error logging session end: $e');
        }
      }
    }
    _sessionStartTime = null;
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
