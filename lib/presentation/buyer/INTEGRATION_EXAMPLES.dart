/// EXAMPLE: How to use BuyerInitializationService
///
/// This file shows the correct implementation patterns for:
/// 1. Initializing buyer profile after registration
/// 2. Initializing buyer session after login
///
/// Copy these patterns into your registration and login screens/services

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:agrolinkbd/core/services/auth_service.dart';
import 'package:agrolinkbd/core/services/buyer_initialization_service.dart';

// ============================================================================
// EXAMPLE 1: REGISTRATION SCREEN - Initialize buyer after registration
// ============================================================================

class BuyerRegistrationExample extends ConsumerStatefulWidget {
  const BuyerRegistrationExample({Key? key}) : super(key: key);

  @override
  ConsumerState<BuyerRegistrationExample> createState() =>
      _BuyerRegistrationExampleState();
}

class _BuyerRegistrationExampleState
    extends ConsumerState<BuyerRegistrationExample> {
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  Future<void> _registerBuyer({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    setState(() => _isLoading = true);

    try {
      // Step 1: Register with Firebase Auth
      final credential = await _authService.registerWithEmail(
        email: email,
        password: password,
      );

      debugPrint('✅ Firebase Auth account created: ${credential.user?.uid}');

      if (credential.user != null) {
        // Step 2: Initialize buyer profile
        final success =
            await BuyerInitializationService.initializeBuyerAfterRegistration(
          userId: credential.user!.uid,
          name: name,
          email: email,
          phone: phone,
        );

        if (success) {
          debugPrint('✅ Buyer profile created successfully');

          // Step 3: Navigate to dashboard
          if (mounted) {
            Get.toNamed('/buyer/dashboard');
          }
        } else {
          throw 'Failed to create buyer profile';
        }
      }
    } catch (e) {
      debugPrint('❌ Registration error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registration failed: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register as Buyer')),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : ElevatedButton(
                onPressed: () => _registerBuyer(
                  name: 'John Doe',
                  email: 'john@example.com',
                  phone: '01711111111',
                  password: 'password123',
                ),
                child: const Text('Register'),
              ),
      ),
    );
  }
}

// ============================================================================
// EXAMPLE 2: LOGIN SCREEN - Initialize buyer session after login
// ============================================================================

class BuyerLoginExample extends ConsumerStatefulWidget {
  const BuyerLoginExample({Key? key}) : super(key: key);

  @override
  ConsumerState<BuyerLoginExample> createState() => _BuyerLoginExampleState();
}

class _BuyerLoginExampleState extends ConsumerState<BuyerLoginExample> {
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  Future<void> _loginBuyer({
    required String email,
    required String password,
  }) async {
    setState(() => _isLoading = true);

    try {
      // Step 1: Sign in with Firebase Auth
      final credential = await _authService.signInWithEmail(
        email: email,
        password: password,
      );

      debugPrint('✅ Signed in as: ${credential.user?.uid}');

      if (credential.user != null) {
        // Step 2: Initialize buyer session
        // IMPORTANT: Pass 'ref' from ConsumerWidget
        final success = await BuyerInitializationService.initializeBuyerSession(
          userId: credential.user!.uid,
          ref: ref, // ← Pass the WidgetRef here
        );

        if (success) {
          debugPrint('✅ Buyer session initialized');

          // Step 3: Navigate to dashboard
          if (mounted) {
            Get.toNamed('/buyer/dashboard');
          }
        } else {
          throw 'Failed to initialize buyer session';
        }
      }
    } catch (e) {
      debugPrint('❌ Login error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login failed: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Buyer Login')),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : ElevatedButton(
                onPressed: () => _loginBuyer(
                  email: 'john@example.com',
                  password: 'password123',
                ),
                child: const Text('Login'),
              ),
      ),
    );
  }
}

// ============================================================================
// KEY POINTS TO REMEMBER:
// ============================================================================
//
// ✅ AFTER REGISTRATION:
//    1. Register with Firebase Auth
//    2. Call initializeBuyerAfterRegistration() with userId, name, email, phone
//    3. Navigate to buyer dashboard
//
// ✅ AFTER LOGIN:
//    1. Sign in with Firebase Auth
//    2. Call initializeBuyerSession() with userId and ref
//    3. Navigate to buyer dashboard
//
// ✅ REQUIRED IMPORTS:
//    - import 'package:agrolinkbd/core/services/buyer_initialization_service.dart';
//    - import 'package:flutter_riverpod/flutter_riverpod.dart';
//    - Make sure your widget extends ConsumerWidget or ConsumerStatefulWidget
//
// ✅ REF REQUIREMENT:
//    - For login, you MUST pass 'ref' from a ConsumerWidget
//    - This sets the currentBuyerIdProvider which enables all buyer features
//
// ❌ COMMON MISTAKES:
//    - Forgetting to pass ref in initializeBuyerSession()
//    - Not checking if success is true before navigating
//    - Using StatefulWidget instead of ConsumerStatefulWidget for login
//    - Not awaiting the initialization functions
//
// ============================================================================
