import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Typography system for AgroLinkBD
/// Uses Google Fonts: Poppins (primary), Roboto (fallback)
class AppTypography {
  AppTypography._();

  // ========== HEADLINE STYLES ==========
  /// H1: Extra Large Headlines (32sp)
  static TextStyle h1({
    Color color = const Color(0xFF212121),
    FontWeight fontWeight = FontWeight.bold,
  }) =>
      GoogleFonts.poppins(
        fontSize: 32,
        fontWeight: fontWeight,
        color: color,
        height: 1.25,
        letterSpacing: -0.5,
      );

  /// H2: Large Headlines (28sp)
  static TextStyle h2({
    Color color = const Color(0xFF212121),
    FontWeight fontWeight = FontWeight.bold,
  }) =>
      GoogleFonts.poppins(
        fontSize: 28,
        fontWeight: fontWeight,
        color: color,
        height: 1.3,
        letterSpacing: -0.3,
      );

  /// H3: Medium Headlines (24sp)
  static TextStyle h3({
    Color color = const Color(0xFF212121),
    FontWeight fontWeight = FontWeight.bold,
  }) =>
      GoogleFonts.poppins(
        fontSize: 24,
        fontWeight: fontWeight,
        color: color,
        height: 1.3,
      );

  /// H4: Small Headlines (20sp)
  static TextStyle h4({
    Color color = const Color(0xFF212121),
    FontWeight fontWeight = FontWeight.w600,
  }) =>
      GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: fontWeight,
        color: color,
        height: 1.4,
      );

  // ========== BODY STYLES ==========
  /// Body Large (16sp) - Main body text
  static TextStyle bodyLarge({
    Color color = const Color(0xFF212121),
    FontWeight fontWeight = FontWeight.w400,
  }) =>
      GoogleFonts.roboto(
        fontSize: 16,
        fontWeight: fontWeight,
        color: color,
        height: 1.5,
        letterSpacing: 0.1,
      );

  /// Body Medium (14sp) - Regular body text
  static TextStyle bodyMedium({
    Color color = const Color(0xFF212121),
    FontWeight fontWeight = FontWeight.w400,
  }) =>
      GoogleFonts.roboto(
        fontSize: 14,
        fontWeight: fontWeight,
        color: color,
        height: 1.43,
        letterSpacing: 0.2,
      );

  /// Body Small (12sp) - Secondary body text
  static TextStyle bodySmall({
    Color color = const Color(0xFF757575),
    FontWeight fontWeight = FontWeight.w400,
  }) =>
      GoogleFonts.roboto(
        fontSize: 12,
        fontWeight: fontWeight,
        color: color,
        height: 1.33,
        letterSpacing: 0.4,
      );

  // ========== LABEL STYLES ==========
  /// Label Large (14sp) - Buttons, Important Labels
  static TextStyle labelLarge({
    Color color = const Color(0xFF212121),
    FontWeight fontWeight = FontWeight.w600,
  }) =>
      GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: fontWeight,
        color: color,
        height: 1.43,
        letterSpacing: 0.1,
      );

  /// Label Medium (12sp) - Field labels
  static TextStyle labelMedium({
    Color color = const Color(0xFF757575),
    FontWeight fontWeight = FontWeight.w500,
  }) =>
      GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: fontWeight,
        color: color,
        height: 1.33,
        letterSpacing: 0.5,
      );

  /// Label Small (11sp) - Small labels, captions
  static TextStyle labelSmall({
    Color color = const Color(0xFF9E9E9E),
    FontWeight fontWeight = FontWeight.w500,
  }) =>
      GoogleFonts.poppins(
        fontSize: 11,
        fontWeight: fontWeight,
        color: color,
        height: 1.45,
        letterSpacing: 0.5,
      );

  // ========== DISPLAY STYLES ==========
  /// Display Large (45sp) - Hero sections, splash screens
  static TextStyle displayLarge({
    Color color = const Color(0xFF212121),
    FontWeight fontWeight = FontWeight.bold,
  }) =>
      GoogleFonts.poppins(
        fontSize: 45,
        fontWeight: fontWeight,
        color: color,
        height: 1.2,
        letterSpacing: -1.5,
      );

  /// Display Medium (36sp) - Large promotional text
  static TextStyle displayMedium({
    Color color = const Color(0xFF212121),
    FontWeight fontWeight = FontWeight.bold,
  }) =>
      GoogleFonts.poppins(
        fontSize: 36,
        fontWeight: fontWeight,
        color: color,
        height: 1.25,
        letterSpacing: -0.5,
      );
}

/// Spacing and sizing system
class AppSpacing {
  AppSpacing._();

  // ========== PADDING & MARGINS ==========
  static const double xs = 4.0; // Micro spacing
  static const double sm = 8.0; // Small
  static const double md = 12.0; // Medium-small
  static const double lg = 16.0; // Medium (default)
  static const double xl = 24.0; // Large
  static const double xxl = 32.0; // Extra large
  static const double xxxl = 48.0; // Massive

  // ========== COMMON SPACING VALUES ==========
  static const EdgeInsets p0 = EdgeInsets.zero;
  static const EdgeInsets p_xs = EdgeInsets.all(xs);
  static const EdgeInsets p_sm = EdgeInsets.all(sm);
  static const EdgeInsets p_md = EdgeInsets.all(md);
  static const EdgeInsets p_lg = EdgeInsets.all(lg);
  static const EdgeInsets p_xl = EdgeInsets.all(xl);
  static const EdgeInsets p_xxl = EdgeInsets.all(xxl);

  /// Screen padding - Standard content inset
  static const EdgeInsets screenPadding = EdgeInsets.symmetric(
    horizontal: lg,
    vertical: lg,
  );

  /// Screen padding - Compact (for dense layouts)
  static const EdgeInsets screenPaddingCompact = EdgeInsets.symmetric(
    horizontal: md,
    vertical: md,
  );

  /// Card padding - Standard card content padding
  static const EdgeInsets cardPadding = EdgeInsets.all(lg);

  /// Button padding - Standard button content padding
  static const EdgeInsets buttonPadding = EdgeInsets.symmetric(
    horizontal: xl,
    vertical: md,
  );

  /// Input field padding
  static const EdgeInsets inputPadding = EdgeInsets.symmetric(
    horizontal: lg,
    vertical: md,
  );

  // ========== COMMON SIZES ==========
  static const double iconSmall = 16.0;
  static const double iconMedium = 24.0;
  static const double iconLarge = 32.0;
  static const double iconXLarge = 48.0;

  static const double avatarSmall = 32.0;
  static const double avatarMedium = 48.0;
  static const double avatarLarge = 64.0;

  static const double buttonHeightSmall = 36.0;
  static const double buttonHeightMedium = 44.0;
  static const double buttonHeightLarge = 52.0;

  static const double minTapTarget = 48.0; // Material guideline

  // ========== RADII ==========
  static const double radiusSmall = 4.0;
  static const double radiusMedium = 8.0;
  static const double radiusLarge = 12.0;
  static const double radiusXLarge = 16.0;
  static const double radiusCircle = 50.0;

  static const Radius circleSmall = Radius.circular(radiusSmall);
  static const Radius circleMedium = Radius.circular(radiusMedium);
  static const Radius circleLarge = Radius.circular(radiusLarge);
  static const Radius circleXLarge = Radius.circular(radiusXLarge);

  // ========== COMMON BORDER RADII ==========
  static const BorderRadius br_sm = BorderRadius.all(circleSmall);
  static const BorderRadius br_md = BorderRadius.all(circleMedium);
  static const BorderRadius br_lg = BorderRadius.all(circleLarge);
  static const BorderRadius br_xl = BorderRadius.all(circleXLarge);

  // ========== ELEVATION/SHADOWS ==========
  static const double elevationSmall = 2.0;
  static const double elevationMedium = 4.0;
  static const double elevationLarge = 8.0;
  static const double elevationXLarge = 12.0;
}

/// Duration constants for animations
class AppDurations {
  AppDurations._();

  static const Duration instant = Duration(milliseconds: 100);
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration slowest = Duration(milliseconds: 800);
}

/// Curve constants for animations
class AppCurves {
  AppCurves._();

  static const Curve easeInOut = Curves.easeInOut;
  static const Curve easeIn = Curves.easeIn;
  static const Curve easeOut = Curves.easeOut;
  static const Curve bouncy = Curves.bounceOut;
  static const Curve smooth = Curves.decelerate;
}
