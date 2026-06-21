import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

class AppException implements Exception {
  final String message;
  final String code;
  final Exception? originalException;

  AppException({
    required this.message,
    required this.code,
    this.originalException,
  });

  @override
  String toString() => message;
}

class ErrorHandler {
  static AppException handleException(Exception e, {String? context}) {
    String message = 'An error occurred';
    String code = 'unknown_error';

    if (e is FirebaseAuthException) {
      code = e.code;
      message = _handleFirebaseAuthException(e);
    } else if (e is FirebaseException) {
      code = e.code;
      message = _handleFirebaseException(e);
    } else if (e is FormatException) {
      message = 'Invalid data format. Please check your input.';
      code = 'format_error';
    } else if (e is TimeoutException) {
      message = 'Request timed out. Please check your connection.';
      code = 'timeout_error';
    } else {
      message = e.toString();
    }

    if (context != null) {
      message = '[$context] $message';
    }

    return AppException(
      message: message,
      code: code,
      originalException: e,
    );
  }

  static String _handleFirebaseAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'Password is too weak. Please use a stronger password.';
      case 'email-already-in-use':
        return 'Email is already registered.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'user-disabled':
        return 'User account is disabled.';
      case 'user-not-found':
        return 'User not found. Please check your email.';
      case 'wrong-password':
        return 'Invalid password.';
      case 'operation-not-allowed':
        return 'Operation not allowed.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'invalid-credential':
        return 'Invalid credentials.';
      default:
        return 'Authentication failed: ${e.message}';
    }
  }

  static String _handleFirebaseException(FirebaseException e) {
    switch (e.code) {
      case 'permission-denied':
        return 'You do not have permission to perform this action.';
      case 'not-found':
        return 'Data not found.';
      case 'failed-precondition':
        return 'A precondition failed for the operation.';
      case 'aborted':
        return 'Operation was aborted.';
      case 'out-of-range':
        return 'Data is out of range.';
      case 'unimplemented':
        return 'This feature is not implemented yet.';
      case 'internal':
        return 'An internal error occurred.';
      case 'unavailable':
        return 'Service is currently unavailable. Please try again later.';
      case 'data-loss':
        return 'Data loss occurred.';
      case 'unauthenticated':
        return 'Please log in to continue.';
      default:
        return 'Error: ${e.message}';
    }
  }

  static void showErrorSnackBar(BuildContext context, Exception e) {
    final appException = handleException(e);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(appException.message),
        backgroundColor: Colors.red.shade700,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }

  static void showErrorDialog(BuildContext context, Exception e) {
    final appException = handleException(e);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(appException.message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  static void logError(Exception e, {String? context}) {
    final appException = handleException(e, context: context);
    debugPrint('Error [${appException.code}]: ${appException.message}');
    if (appException.originalException != null) {
      debugPrintStack(label: 'Stack trace for: ${appException.code}');
    }
  }
}

// Custom exceptions
class NetworkException extends AppException {
  NetworkException({String message = 'Network error occurred'})
      : super(message: message, code: 'network_error');
}

class ValidationException extends AppException {
  ValidationException({String message = 'Validation failed'})
      : super(message: message, code: 'validation_error');
}

class PaymentException extends AppException {
  PaymentException({String message = 'Payment failed'})
      : super(message: message, code: 'payment_error');
}

class AuthException extends AppException {
  AuthException({String message = 'Authentication failed'})
      : super(message: message, code: 'auth_error');
}

class DataException extends AppException {
  DataException({String message = 'Data operation failed'})
      : super(message: message, code: 'data_error');
}
