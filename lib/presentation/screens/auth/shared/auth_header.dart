import 'package:flutter/material.dart';
import 'auth_constants.dart';

/// Reusable header for all auth screens with role info
class AuthHeader extends StatelessWidget {
  final String roleKey; // 'farmer', 'buyer', 'driver', etc.
  final String title;
  final String subtitle;
  final bool isRegister;

  const AuthHeader({
    Key? key,
    required this.roleKey,
    required this.title,
    required this.subtitle,
    this.isRegister = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final roleData = AuthConstants.roleConfig[roleKey] as Map<String, dynamic>;
    final roleColor = roleData['color'] as Color;
    final roleEmoji = roleData['icon'] as String;
    final roleLabel = roleData['label'] as String;

    return Column(
      children: [
        // Role indicator with emoji and color
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: roleColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              roleEmoji,
              style: const TextStyle(fontSize: 40),
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Role label in both languages
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: roleColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: roleColor),
          ),
          child: Text(
            roleLabel,
            style: TextStyle(
              color: roleColor,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Title
        Text(
          title,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: AuthConstants.textDark,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),

        // Subtitle
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 14,
            color: AuthConstants.textLight,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

/// Title bar for role-based auth screens
class AuthTitleBar extends StatelessWidget {
  final String roleKey;
  final bool isRegister;

  const AuthTitleBar({
    Key? key,
    required this.roleKey,
    required this.isRegister,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final roleData = AuthConstants.roleConfig[roleKey] as Map<String, dynamic>;
    final roleColor = roleData['color'] as Color;

    return Container(
      padding: const EdgeInsets.all(AuthConstants.padding16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [roleColor, roleColor.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: const Icon(
                Icons.arrow_back,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isRegister ? 'নতুন অ্যাকাউন্ট' : 'লগইন করুন',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    isRegister ? 'Create New Account' : 'Sign In',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
