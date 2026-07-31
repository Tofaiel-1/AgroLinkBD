import 'package:flutter/material.dart';
import 'package:agrolinkbd/core/utils/responsive_helper.dart';

/// Responsive Web Wrapper - Constrains max width & centers UI on Web/Desktop displays.
/// On mobile phones, renders full width without overhead.
class ResponsiveWebWrapper extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final bool showCardBorderOnDesktop;

  const ResponsiveWebWrapper({
    super.key,
    required this.child,
    this.maxWidth = 1200,
    this.padding,
    this.backgroundColor,
    this.showCardBorderOnDesktop = false,
  });

  /// Specialized wrapper for Auth / Form screens (e.g. Login, Register, OTP)
  factory ResponsiveWebWrapper.auth({
    required Widget child,
    double maxWidth = 480,
    EdgeInsetsGeometry? padding,
  }) {
    return ResponsiveWebWrapper(
      maxWidth: maxWidth,
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      showCardBorderOnDesktop: true,
      child: child,
    );
  }

  /// Specialized wrapper for standard Content / Dashboard screens
  factory ResponsiveWebWrapper.content({
    required Widget child,
    double maxWidth = 1200,
    EdgeInsetsGeometry? padding,
  }) {
    return ResponsiveWebWrapper(
      maxWidth: maxWidth,
      padding: padding,
      showCardBorderOnDesktop: false,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveHelper.isDesktop(context);
    final isTablet = ResponsiveHelper.isTablet(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (!isDesktop && !isTablet) {
      // Mobile - return directly with optional padding
      if (padding != null) {
        return Padding(
          padding: padding!,
          child: child,
        );
      }
      return child;
    }

    // Tablet or Desktop Widescreen
    return Container(
      width: double.infinity,
      color: backgroundColor ?? (isDark ? const Color(0xFF12121A) : const Color(0xFFF8FAFC)),
      alignment: Alignment.topCenter,
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Container(
            margin: isDesktop && showCardBorderOnDesktop
                ? const EdgeInsets.symmetric(vertical: 32, horizontal: 24)
                : EdgeInsets.zero,
            decoration: isDesktop && showCardBorderOnDesktop
                ? BoxDecoration(
                    color: isDark ? const Color(0xFF1E1E2C) : Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(isDark ? 0.4 : 0.06),
                        blurRadius: 24,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  )
                : null,
            child: Padding(
              padding: padding ?? EdgeInsets.zero,
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
