import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart' as firestore;

/// App exception hierarchy for consistent error handling
abstract class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalException;

  AppException({
    required this.message,
    this.code,
    this.originalException,
  });

  @override
  String toString() => message;
}

/// Authentication related exceptions
class AuthException extends AppException {
  AuthException({
    required String message,
    String? code,
    dynamic originalException,
  }) : super(
          message: message,
          code: code,
          originalException: originalException,
        );

  /// Factory constructor to parse Firebase Auth exceptions
  factory AuthException.fromFirebaseAuth(
      firebase_auth.FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return AuthException(
          message: 'User not found. Please register first.',
          code: e.code,
          originalException: e,
        );
      case 'wrong-password':
        return AuthException(
          message: 'Incorrect password. Please try again.',
          code: e.code,
          originalException: e,
        );
      case 'weak-password':
        return AuthException(
          message: 'Password is too weak. Please use a stronger password.',
          code: e.code,
          originalException: e,
        );
      case 'email-already-in-use':
        return AuthException(
          message: 'Email is already registered. Please login instead.',
          code: e.code,
          originalException: e,
        );
      case 'invalid-email':
        return AuthException(
          message: 'Invalid email format.',
          code: e.code,
          originalException: e,
        );
      case 'user-disabled':
        return AuthException(
          message: 'This user account has been disabled.',
          code: e.code,
          originalException: e,
        );
      case 'too-many-requests':
        return AuthException(
          message: 'Too many login attempts. Please try again later.',
          code: e.code,
          originalException: e,
        );
      case 'operation-not-allowed':
        return AuthException(
          message: 'This authentication method is not enabled.',
          code: e.code,
          originalException: e,
        );
      default:
        return AuthException(
          message: e.message ?? 'Authentication error occurred.',
          code: e.code,
          originalException: e,
        );
    }
  }
}

/// Firestore related exceptions
class FirestoreException extends AppException {
  FirestoreException({
    required String message,
    String? code,
    dynamic originalException,
  }) : super(
          message: message,
          code: code,
          originalException: originalException,
        );

  /// Factory constructor to parse Firestore exceptions
  factory FirestoreException.fromFirestore(dynamic e) {
    if (e is firestore.FirebaseException) {
      switch (e.code) {
        case 'permission-denied':
          return FirestoreException(
            message: 'You do not have permission to access this data.',
            code: e.code,
            originalException: e,
          );
        case 'not-found':
          return FirestoreException(
            message: 'The requested document was not found.',
            code: e.code,
            originalException: e,
          );
        case 'already-exists':
          return FirestoreException(
            message: 'This document already exists.',
            code: e.code,
            originalException: e,
          );
        case 'failed-precondition':
          return FirestoreException(
            message: 'Operation failed. Please try again.',
            code: e.code,
            originalException: e,
          );
        case 'aborted':
          return FirestoreException(
            message: 'Operation was aborted. Please try again.',
            code: e.code,
            originalException: e,
          );
        case 'out-of-range':
          return FirestoreException(
            message: 'Value is out of valid range.',
            code: e.code,
            originalException: e,
          );
        case 'unauthenticated':
          return FirestoreException(
            message: 'Please login to perform this action.',
            code: e.code,
            originalException: e,
          );
        case 'unavailable':
          return FirestoreException(
            message: 'Service is temporarily unavailable. Please try again.',
            code: e.code,
            originalException: e,
          );
        default:
          return FirestoreException(
            message: 'Database error: ${e.message}',
            code: e.code,
            originalException: e,
          );
      }
    }

    return FirestoreException(
      message: 'An unknown database error occurred.',
      originalException: e,
    );
  }
}

/// Network related exceptions
class NetworkException extends AppException {
  NetworkException({
    required String message,
    String? code,
    dynamic originalException,
  }) : super(
          message: message,
          code: code,
          originalException: originalException,
        );

  /// Check if error is network related
  static bool isNetworkError(dynamic e) {
    return e.toString().contains('SocketException') ||
        e.toString().contains('ConnectionRefused') ||
        e.toString().contains('No route to host') ||
        e.toString().contains('Failed host lookup');
  }
}

/// Validation exceptions
class ValidationException extends AppException {
  final Map<String, String>? fieldErrors;

  ValidationException({
    required String message,
    this.fieldErrors,
    dynamic originalException,
  }) : super(
          message: message,
          originalException: originalException,
        );

  /// Check if specific field has error
  bool hasError(String fieldName) {
    return fieldErrors?.containsKey(fieldName) ?? false;
  }

  /// Get error for specific field
  String? getFieldError(String fieldName) {
    return fieldErrors?[fieldName];
  }
}

/// Payment related exceptions
class PaymentException extends AppException {
  final String? transactionId;

  PaymentException({
    required String message,
    String? code,
    this.transactionId,
    dynamic originalException,
  }) : super(
          message: message,
          code: code,
          originalException: originalException,
        );
}

/// Generic app exception for unknown errors
class UnknownException extends AppException {
  UnknownException({
    String message = 'An unexpected error occurred. Please try again.',
    dynamic originalException,
  }) : super(
          message: message,
          originalException: originalException,
        );
}

/// Exception handler utility
class ExceptionHandler {
  /// Parse any exception and return appropriate AppException
  static AppException handle(dynamic exception) {
    if (exception is AppException) {
      return exception;
    }

    if (exception is firebase_auth.FirebaseAuthException) {
      return AuthException.fromFirebaseAuth(exception);
    }

    if (exception is firestore.FirebaseException) {
      return FirestoreException.fromFirestore(exception);
    }

    if (NetworkException.isNetworkError(exception)) {
      return NetworkException(
        message: 'Network error. Please check your internet connection.',
        originalException: exception,
      );
    }

    return UnknownException(originalException: exception);
  }

  /// Get user-friendly error message
  static String getErrorMessage(dynamic exception) {
    final appException = handle(exception);
    return appException.message;
  }

  /// Get error code for logging
  static String? getErrorCode(dynamic exception) {
    if (exception is AppException) {
      return exception.code;
    }
    return null;
  }
}
