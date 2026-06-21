import 'package:flutter/material.dart';

/// Responsive Design Helper - Provides responsive breakpoints and sizing utilities
/// Phone: < 600dp
/// Tablet: 600-1200dp
/// Desktop: > 1200dp

class ResponsiveHelper {
  static const double phoneBreakpoint = 600;
  static const double tabletBreakpoint = 1200;

  /// Get screen width
  static double screenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  /// Get screen height  lib/presentation/screens/admin/
  static double screenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  /// Check if device is phone
  static bool isPhone(BuildContext context) {
    return screenWidth(context) < phoneBreakpoint;
  }

  /// Check if device is tablet
  static bool isTablet(BuildContext context) {
    return screenWidth(context) >= phoneBreakpoint &&
        screenWidth(context) < tabletBreakpoint;
  }

  /// Check if device is desktop
  static bool isDesktop(BuildContext context) {
    return screenWidth(context) >= tabletBreakpoint;
  }

  /// Check if device is in landscape mode
  static bool isLandscape(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }

  /// Check if device is in portrait mode
  static bool isPortrait(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.portrait;
  }

  /// Get responsive padding
  static EdgeInsets getResponsivePadding(BuildContext context) {
    if (isPhone(context)) {
      return const EdgeInsets.all(12);
    } else if (isTablet(context)) {
      return const EdgeInsets.all(16);
    } else {
      return const EdgeInsets.all(24);
    }
  }

  /// Get responsive font size
  static double getResponsiveFontSize(BuildContext context, double baseSize) {
    if (isPhone(context)) {
      return baseSize;
    } else if (isTablet(context)) {
      return baseSize * 1.1;
    } else {
      return baseSize * 1.2;
    }
  }

  /// Get responsive grid columns
  static int getGridColumns(BuildContext context) {
    if (isPhone(context)) {
      return 2;
    } else if (isTablet(context)) {
      return 3;
    } else {
      return 4;
    }
  }

  /// Get responsive widget width (percentage of screen width)
  static double getResponsiveWidth(BuildContext context, double percentage) {
    return screenWidth(context) * (percentage / 100);
  }

  /// Get responsive widget height (percentage of screen height)
  static double getResponsiveHeight(BuildContext context, double percentage) {
    return screenHeight(context) * (percentage / 100);
  }

  /// Get responsive margin
  static EdgeInsets getResponsiveMargin(BuildContext context) {
    if (isPhone(context)) {
      return const EdgeInsets.symmetric(horizontal: 12, vertical: 8);
    } else if (isTablet(context)) {
      return const EdgeInsets.symmetric(horizontal: 16, vertical: 12);
    } else {
      return const EdgeInsets.symmetric(horizontal: 24, vertical: 16);
    }
  }

  /// Get safe padding (taking into account notch/safe area)
  static EdgeInsets getSafePadding(BuildContext context) {
    MediaQueryData data = MediaQuery.of(context);
    return data.padding;
  }

  /// Get responsive widget aspect ratio
  static double getResponsiveAspectRatio(BuildContext context) {
    if (isPhone(context)) {
      return 0.85;
    } else if (isTablet(context)) {
      return 0.9;
    } else {
      return 1.0;
    }
  }

  /// Get maximum width for content (useful for very large screens)
  static double getMaxContentWidth(BuildContext context) {
    double width = screenWidth(context);
    if (width > 1200) {
      return 1200; // Limit content width on very large screens
    }
    return width;
  }

  /// Check if status bar is visible (not fullscreen)
  static bool isStatusBarVisible(BuildContext context) {
    return !MediaQuery.of(context).viewInsets.bottom.isInfinite;
  }

  /// Get device padding
  static EdgeInsets getDevicePadding(BuildContext context) {
    return MediaQuery.of(context).padding;
  }

  /// Get device view insets (keyboard etc)
  static EdgeInsets getViewInsets(BuildContext context) {
    return MediaQuery.of(context).viewInsets;
  }
}

/// Responsive widget that adapts to screen size
class ResponsiveWidget extends StatelessWidget {
  final Widget Function(
      BuildContext, bool isPhone, bool isTablet, bool isDesktop) builder;

  const ResponsiveWidget({
    required this.builder,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return builder(
      context,
      ResponsiveHelper.isPhone(context),
      ResponsiveHelper.isTablet(context),
      ResponsiveHelper.isDesktop(context),
    );
  }
}

/// Responsive padding widget
class ResponsivePadding extends StatelessWidget {
  final Widget child;
  final EdgeInsets? phonePadding;
  final EdgeInsets? tabletPadding;
  final EdgeInsets? desktopPadding;

  const ResponsivePadding({
    required this.child,
    this.phonePadding,
    this.tabletPadding,
    this.desktopPadding,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    EdgeInsets padding = phonePadding ?? const EdgeInsets.all(12);

    if (ResponsiveHelper.isTablet(context)) {
      padding = tabletPadding ?? const EdgeInsets.all(16);
    } else if (ResponsiveHelper.isDesktop(context)) {
      padding = desktopPadding ?? const EdgeInsets.all(24);
    }

    return Padding(padding: padding, child: child);
  }
}
