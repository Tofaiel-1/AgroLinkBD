import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'shared/auth_constants.dart';

/// Role Selection Screen - First screen users see
/// Allows users to choose their role before login/register
class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  String? selectedRole;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(AuthConstants.padding24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // App logo/title
                const SizedBox(height: 40),
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Colors.green.shade600, Colors.green.shade400],
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      '🌾',
                      style: TextStyle(fontSize: 50),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Title
                const Text(
                  'আগ্রোলিংকবিডি',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: AuthConstants.textDark,
                  ),
                ),
                const Text(
                  'AgroLinkBD',
                  style: TextStyle(
                    fontSize: 14,
                    color: AuthConstants.textLight,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 12),

                // Subtitle
                const Text(
                  'কৃষি ব্যবসার জন্য ডিজিটাল প্ল্যাটফর্ম',
                  style: TextStyle(
                    fontSize: 16,
                    color: AuthConstants.textLight,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 50),

                // Role selection cards
                const Text(
                  'আপনার ভূমিকা নির্বাচন করুন',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AuthConstants.textDark,
                  ),
                ),
                const SizedBox(height: 24),

                // Role cards
                ..._buildRoleCards(),

                const SizedBox(height: 40),

                // Next button
                SizedBox(
                  width: double.infinity,
                  height: AuthConstants.buttonHeight,
                  child: ElevatedButton(
                    onPressed: selectedRole == null
                        ? null
                        : () => _navigateToAuth(selectedRole!),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade600,
                      disabledBackgroundColor: Colors.grey[300],
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AuthConstants.borderRadius),
                      ),
                    ),
                    child: const Text(
                      'পরবর্তী',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildRoleCards() {
    return AuthConstants.roleConfig.entries.map((entry) {
      final roleKey = entry.key;
      final roleData = entry.value;
      final roleColor = roleData['color'] as Color;
      final roleEmoji = roleData['icon'] as String;
      final roleLabel = roleData['label'] as String;
      final roleDescription = roleData['description'] as String;
      final isSelected = selectedRole == roleKey;

      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: GestureDetector(
          onTap: () => setState(() => selectedRole = roleKey),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(
                color: isSelected ? roleColor : AuthConstants.borderColor,
                width: isSelected ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(AuthConstants.borderRadius),
              color: isSelected ? roleColor.withOpacity(0.05) : Colors.white,
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: roleColor.withOpacity(0.2),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : [],
            ),
            child: Row(
              children: [
                // Role emoji
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: roleColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      roleEmoji,
                      style: const TextStyle(fontSize: 32),
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // Role info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        roleLabel,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: roleColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        roleDescription,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AuthConstants.textLight,
                        ),
                      ),
                    ],
                  ),
                ),

                // Checkbox
                AnimatedScale(
                  scale: isSelected ? 1.1 : 1.0,
                  duration: const Duration(milliseconds: 300),
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color:
                            isSelected ? roleColor : AuthConstants.borderColor,
                        width: 2,
                      ),
                      color: isSelected ? roleColor : Colors.transparent,
                    ),
                    child: isSelected
                        ? const Center(
                            child: Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 14,
                            ),
                          )
                        : null,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }).toList();
  }

  void _navigateToAuth(String roleKey) {
    // Navigate to role-specific login screen
    // This will be implemented in the next step
    Get.toNamed('/auth/$roleKey/login', arguments: {'role': roleKey});
  }
}
