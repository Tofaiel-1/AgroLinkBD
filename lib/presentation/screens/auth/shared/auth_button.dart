import 'package:flutter/material.dart';
import 'auth_constants.dart';

/// Reusable button for all auth screens
class AuthButton extends StatelessWidget {
  final String label;
  final String labelBn;
  final VoidCallback onPressed;
  final Color roleColor;
  final bool isLoading;
  final bool isSecondary;
  final double? width;
  final double height;

  const AuthButton({
    Key? key,
    required this.label,
    required this.labelBn,
    required this.onPressed,
    required this.roleColor,
    this.isLoading = false,
    this.isSecondary = false,
    this.width,
    this.height = AuthConstants.buttonHeight,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isSecondary ? Colors.transparent : roleColor,
          foregroundColor: isSecondary ? roleColor : Colors.white,
          side: isSecondary ? BorderSide(color: roleColor) : null,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AuthConstants.borderRadius),
          ),
          elevation: isSecondary ? 0 : 2,
          disabledBackgroundColor: Colors.grey[300],
        ),
        child: isLoading
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isSecondary ? roleColor : Colors.white,
                  ),
                ),
              )
            : Text(
                labelBn,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}
