import 'package:flutter/material.dart';
import 'auth_constants.dart';

/// Reusable auth text field for all roles
class AuthTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String labelBn;
  final String hint;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final bool isPassword;
  final Color roleColor;
  final int maxLines;
  final String? prefixIcon;

  const AuthTextField({
    Key? key,
    required this.controller,
    required this.label,
    required this.labelBn,
    required this.hint,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.isPassword = false,
    required this.roleColor,
    this.maxLines = 1,
    this.prefixIcon,
  }) : super(key: key);

  @override
  State<AuthTextField> createState() => _AuthTextFieldState();
}

class _AuthTextFieldState extends State<AuthTextField> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AuthConstants.padding16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.labelBn,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AuthConstants.textDark,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: widget.controller,
            obscureText: _obscureText,
            keyboardType: widget.keyboardType,
            maxLines: widget.isPassword ? 1 : widget.maxLines,
            validator: widget.validator,
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: const TextStyle(color: AuthConstants.textLight),
              prefixIcon: widget.prefixIcon != null
                  ? Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(widget.prefixIcon!,
                          style: const TextStyle(fontSize: 20)),
                    )
                  : null,
              suffixIcon: widget.isPassword
                  ? IconButton(
                      icon: Icon(
                        _obscureText ? Icons.visibility_off : Icons.visibility,
                        color: widget.roleColor,
                      ),
                      onPressed: () =>
                          setState(() => _obscureText = !_obscureText),
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AuthConstants.borderRadius),
                borderSide: const BorderSide(color: AuthConstants.borderColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AuthConstants.borderRadius),
                borderSide: const BorderSide(color: AuthConstants.borderColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AuthConstants.borderRadius),
                borderSide: BorderSide(color: widget.roleColor, width: 2),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AuthConstants.borderRadius),
                borderSide: const BorderSide(
                  color: AuthConstants.errorColor,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
