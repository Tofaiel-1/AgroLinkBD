import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';
import 'package:agrolinkbd/core/providers/language_provider.dart';
import 'package:agrolinkbd/core/providers/admin_provider.dart';
import 'package:agrolinkbd/presentation/screens/auth/login_screen.dart';
import 'package:agrolinkbd/presentation/screens/admin/widgets/admin_quick_price_command_sheet.dart';
import 'package:agrolinkbd/presentation/screens/admin/widgets/admin_price_command_history_view.dart';
import 'package:agrolinkbd/presentation/screens/admin/widgets/admin_price_safety_policy_card.dart';
import 'package:agrolinkbd/presentation/screens/admin/widgets/admin_ai_price_analysis_tab.dart';
import 'package:agrolinkbd/core/services/admin_price_command_service.dart';

/// ============================================================
/// ADMIN PRICE CONTROL CENTER (BILINGUAL & FULL SETTINGS)
/// Super Admin can manage product prices, market rates, run AI
/// scans, and access full settings (Theme, Refresh, Logout, Lang).
/// ============================================================
class AdminPriceControlScreen extends StatefulWidget {
  const AdminPriceControlScreen({super.key});

  @override
  State<AdminPriceControlScreen> createState() =>
      _AdminPriceControlScreenState();
}

class _AdminPriceControlScreenState extends State<AdminPriceControlScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'all';

  static const _accent = Color(0xFF2563EB);
  static const _green = Color(0xFF10B981);
  static const _red = Color(0xFFEF4444);
  static const _gradientStart = Color(0xFF0D1B3E);
  static const _gradientMid = Color(0xFF1E3A8A);
  static const _gradientEnd = Color(0xFF312E81);

  final List<Map<String, dynamic>> _categories = [
    {'key': 'all', 'labelBn': 'সব', 'labelEn': 'All', 'icon': Icons.grid_view_rounded},
    {'key': 'vegetables', 'labelBn': 'শাকসবজি', 'labelEn': 'Vegetables', 'icon': Icons.eco_rounded},
    {'key': 'fruits', 'labelBn': 'ফলমূল', 'labelEn': 'Fruits', 'icon': Icons.apple_rounded},
    {'key': 'grains', 'labelBn': 'শস্য', 'labelEn': 'Grains', 'icon': Icons.grain_rounded},
    {'key': 'fish', 'labelBn': 'মাছ', 'labelEn': 'Fish', 'icon': Icons.water_rounded},
    {'key': 'meat', 'labelBn': 'মাংস', 'labelEn': 'Meat', 'icon': Icons.set_meal_rounded},
    {'key': 'spices', 'labelBn': 'মসলা', 'labelEn': 'Spices', 'icon': Icons.local_fire_department_rounded},
    {'key': 'dairy', 'labelBn': 'দুগ্ধ', 'labelEn': 'Dairy', 'icon': Icons.egg_rounded},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  /// Trigger full refresh across the screen
  void _triggerRefresh({bool showToast = true}) {
    setState(() {});
    if (showToast && mounted) {
      final isBn = LanguageProvider.isBn(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.refresh_rounded, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Text(
                isBn
                    ? 'তথ্য সফলভাবে রিফ্রেশ করা হয়েছে'
                    : 'Data refreshed successfully',
                style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  /// Open comprehensive Super Admin Settings modal
  void _showAdminSettingsSheet(BuildContext context) {
    final isBn = LanguageProvider.isBn(context);
    final currentUser = FirebaseAuth.instance.currentUser;
    final adminEmail = currentUser?.email ?? 'admin@agrolinkbd.com';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          final currentIsDark = Theme.of(context).brightness == Brightness.dark;
          final sheetBg = currentIsDark ? const Color(0xFF1E293B) : Colors.white;
          final textPrimary = currentIsDark ? Colors.white : const Color(0xFF0F172A);
          final textSec = currentIsDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
          final tileBg = currentIsDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9);
          final borderColor = currentIsDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);

          return Container(
            decoration: BoxDecoration(
              color: sheetBg,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Drag Handle
                Center(
                  child: Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: currentIsDark ? Colors.white24 : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Sheet Header with Admin Profile & Close
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [_gradientStart, _gradientEnd],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: _accent.withValues(alpha: 0.3),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: const Icon(Icons.shield_rounded, color: Colors.amberAccent, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                isBn ? 'এডমিন সেটিংস' : 'Admin Settings',
                                style: GoogleFonts.hindSiliguri(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: textPrimary,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.amber.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: Colors.amber.shade700, width: 0.8),
                                ),
                                child: Text(
                                  isBn ? 'সুপার এডমিন' : 'SUPER ADMIN',
                                  style: GoogleFonts.inter(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.amber.shade800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Text(
                            adminEmail,
                            style: GoogleFonts.inter(
                              fontSize: 11.5,
                              color: textSec,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close_rounded, color: textSec, size: 20),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Divider(color: borderColor, height: 1),
                const SizedBox(height: 16),

                // ─── 1. THEME SWITCHER (LIGHT / DARK) ───
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: tileBg,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: borderColor),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: currentIsDark
                              ? const Color(0xFF38BDF8).withValues(alpha: 0.15)
                              : Colors.amber.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          currentIsDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                          color: currentIsDark ? const Color(0xFF38BDF8) : Colors.amber.shade700,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isBn ? 'থিম মোড' : 'Theme Mode',
                              style: GoogleFonts.hindSiliguri(
                                fontWeight: FontWeight.bold,
                                fontSize: 13.5,
                                color: textPrimary,
                              ),
                            ),
                            Text(
                              currentIsDark
                                  ? (isBn ? '🌙 ডার্ক মোড সক্রিয়' : '🌙 Dark Mode Active')
                                  : (isBn ? '☀️ লাইট মোড সক্রিয়' : '☀️ Light Mode Active'),
                              style: GoogleFonts.hindSiliguri(
                                fontSize: 11,
                                color: textSec,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch.adaptive(
                        value: currentIsDark,
                        activeTrackColor: const Color(0xFF38BDF8),
                        activeThumbColor: Colors.white,
                        onChanged: (val) {
                          Get.changeThemeMode(val ? ThemeMode.dark : ThemeMode.light);
                          setSheetState(() {});
                          setState(() {});
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                // ─── 2. LANGUAGE SELECTOR (BANGLA / ENGLISH) ───
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: tileBg,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: borderColor),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _accent.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.language_rounded, color: _accent, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isBn ? 'ভাষা নির্বাচন' : 'Language Selection',
                              style: GoogleFonts.hindSiliguri(
                                fontWeight: FontWeight.bold,
                                fontSize: 13.5,
                                color: textPrimary,
                              ),
                            ),
                            Text(
                              isBn ? 'বাংলা ও ইংরেজি পরিবর্তন করুন' : 'Switch Bangla & English',
                              style: GoogleFonts.hindSiliguri(
                                fontSize: 11,
                                color: textSec,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Segmented Language Toggle Button
                      Container(
                        decoration: BoxDecoration(
                          color: currentIsDark ? const Color(0xFF1E293B) : Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: borderColor),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            GestureDetector(
                              onTap: () {
                                Provider.of<LanguageProvider>(context, listen: false)
                                    .setLanguage('বাংলা');
                                setSheetState(() {});
                                setState(() {});
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: isBn ? _accent : Colors.transparent,
                                  borderRadius: BorderRadius.circular(9),
                                ),
                                child: Text(
                                  'বাংলা',
                                  style: GoogleFonts.hindSiliguri(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.bold,
                                    color: isBn ? Colors.white : textSec,
                                  ),
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Provider.of<LanguageProvider>(context, listen: false)
                                    .setLanguage('English');
                                setSheetState(() {});
                                setState(() {});
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: !isBn ? _accent : Colors.transparent,
                                  borderRadius: BorderRadius.circular(9),
                                ),
                                child: Text(
                                  'EN',
                                  style: GoogleFonts.inter(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.bold,
                                    color: !isBn ? Colors.white : textSec,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                // ─── 3. REFRESH DATA BUTTON ───
                InkWell(
                  onTap: () {
                    Navigator.pop(ctx);
                    _triggerRefresh(showToast: true);
                  },
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: tileBg,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: borderColor),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: _green.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.sync_rounded, color: _green, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isBn ? 'তথ্য রিফ্রেশ করুন' : 'Refresh Data',
                                style: GoogleFonts.hindSiliguri(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13.5,
                                  color: textPrimary,
                                ),
                              ),
                              Text(
                                isBn
                                    ? 'পণ্য, বাজার রেট ও লাইভ স্ট্রিম আপডেট করুন'
                                    : 'Reload live products, rates & streams',
                                style: GoogleFonts.hindSiliguri(
                                  fontSize: 11,
                                  color: textSec,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.arrow_forward_ios_rounded, size: 14, color: textSec),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // ─── 4. SECURITY & SYSTEM STATUS ───
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: tileBg,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: borderColor),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.amber.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.verified_user_rounded, color: Colors.amber, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isBn ? 'সার্কিট ব্রেকার পলিসি' : 'Circuit Breaker Policy',
                              style: GoogleFonts.hindSiliguri(
                                fontWeight: FontWeight.bold,
                                fontSize: 13.5,
                                color: textPrimary,
                              ),
                            ),
                            Text(
                              isBn
                                  ? '±২৫% সর্বোচ্চ পরিবর্তন সীমা সক্রিয়'
                                  : '±25% Max Delta Guard Active',
                              style: GoogleFonts.hindSiliguri(
                                fontSize: 11,
                                color: textSec,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: _green.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          isBn ? 'সক্রিয়' : 'ACTIVE',
                          style: const TextStyle(
                            color: _green,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // ─── 5. LOGOUT BUTTON ───
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      _showLogoutConfirmDialog(context);
                    },
                    icon: const Icon(Icons.logout_rounded, color: Colors.white, size: 18),
                    label: Text(
                      isBn ? 'লগআউট (Sign Out)' : 'Sign Out',
                      style: GoogleFonts.hindSiliguri(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _red,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Show Confirmation Dialog before Admin Sign Out
  Future<void> _showLogoutConfirmDialog(BuildContext context) async {
    final isBn = LanguageProvider.isBn(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final shouldSignOut = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _red.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.logout_rounded, color: _red, size: 22),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                isBn ? 'লগআউট নিশ্চিতকরণ' : 'Confirm Sign Out',
                style: GoogleFonts.hindSiliguri(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
            ),
          ],
        ),
        content: Text(
          isBn
              ? 'আপনি কি নিশ্চিত যে সুপার এডমিন কন্ট্রোল সেন্টার থেকে লগআউট করতে চান?'
              : 'Are you sure you want to log out from the Super Admin Control Center?',
          style: GoogleFonts.hindSiliguri(
            fontSize: 13.5,
            color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              isBn ? 'বাতিল' : 'Cancel',
              style: GoogleFonts.hindSiliguri(
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: _red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(
              isBn ? 'হ্যাঁ, লগআউট' : 'Sign Out',
              style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (shouldSignOut == true && context.mounted) {
      try {
        final adminProvider = Provider.of<AdminProvider>(context, listen: false);
        await adminProvider.adminSignOut();
      } catch (e) {
        debugPrint('⚠️ Error in adminProvider.adminSignOut: $e');
      }
      await FirebaseAuth.instance.signOut();
      Get.offAll(() => const LoginScreen());
    }
  }

  @override
  Widget build(BuildContext context) {
    final isBn = LanguageProvider.isBn(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9);
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textPrimary = isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A);
    final textSec = isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [_gradientStart, _gradientMid, _gradientEnd],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
              ),
              child: const Icon(Icons.price_change_rounded, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isBn ? 'প্রাইস কন্ট্রোল সেন্টার' : 'Price Control Center',
                    style: GoogleFonts.hindSiliguri(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.3,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    isBn
                        ? 'এআই-চালিত মার্কেটপ্লেস ব্যবস্থাপনা'
                        : 'AI-powered marketplace management',
                    style: GoogleFonts.inter(
                      fontSize: 9.5,
                      color: Colors.white70,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          // ─── Language Quick Switch Pill ───────────────────────
          GestureDetector(
            onTap: () =>
                Provider.of<LanguageProvider>(context, listen: false).toggleLanguage(),
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.g_translate_rounded, color: Colors.white, size: 13),
                  const SizedBox(width: 4),
                  Text(
                    isBn ? 'EN' : 'বাং',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ─── Quick Command Button ─────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            child: GestureDetector(
              onTap: () => AdminQuickPriceCommandSheet.show(
                context,
                initialIsBangla: isBn,
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.amberAccent.withValues(alpha: 0.9),
                      Colors.orange.shade600,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(9),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.amberAccent.withValues(alpha: 0.35),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.bolt_rounded, color: Colors.white, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      isBn ? 'কমান্ড' : 'Command',
                      style: GoogleFonts.hindSiliguri(
                        fontWeight: FontWeight.bold,
                        fontSize: 11.5,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ─── Settings Gear Button ─────────────────────────────
          IconButton(
            icon: const Icon(Icons.settings_rounded, color: Colors.white, size: 21),
            tooltip: isBn ? 'এডমিন সেটিংস' : 'Admin Settings',
            onPressed: () => _showAdminSettingsSheet(context),
          ),
          const SizedBox(width: 4),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.amberAccent,
          indicatorWeight: 3,
          indicatorSize: TabBarIndicatorSize.tab,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white54,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          labelStyle: GoogleFonts.hindSiliguri(
            fontSize: 11.5,
            fontWeight: FontWeight.bold,
          ),
          unselectedLabelStyle: GoogleFonts.hindSiliguri(fontSize: 11),
          tabs: [
            Tab(icon: const Icon(Icons.inventory_2_rounded, size: 16), text: isBn ? 'পণ্য ও লট' : 'Products & Lots'),
            Tab(icon: const Icon(Icons.price_change_rounded, size: 16), text: isBn ? 'বাজার রেট' : 'Market Rates'),
            Tab(icon: const Icon(Icons.auto_awesome_rounded, size: 16), text: isBn ? '🤖 এআই স্ক্যান' : '🤖 AI Scan'),
            Tab(icon: const Icon(Icons.history_rounded, size: 16), text: isBn ? 'কমান্ড লগ' : 'Command Logs'),
            Tab(icon: const Icon(Icons.shield_rounded, size: 16), text: isBn ? 'সেফটি' : 'Safety Policy'),
          ],
        ),
      ),
      body: Column(
        children: [
          // ─── Emergency Command Shortcut Bar (Bilingual) ─────────────
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [_gradientStart, _gradientMid, _gradientEnd],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: [
                  _buildShortcutPill(
                    icon: Icons.auto_awesome_rounded,
                    label: isBn ? '🤖 এআই স্ক্যান' : '🤖 AI Scan',
                    gradient: const LinearGradient(
                      colors: [Color(0xFF7C3AED), Color(0xFF2563EB)],
                    ),
                    onTap: () => _tabController.animateTo(2),
                  ),
                  const SizedBox(width: 8),
                  _buildShortcutPill(
                    icon: Icons.trending_down_rounded,
                    label: isBn ? '📉 বাজার ধস (-১০%)' : '📉 Market Crash (-10%)',
                    bgColor: const Color(0xFFEF4444).withValues(alpha: 0.25),
                    borderColor: const Color(0xFFEF4444).withValues(alpha: 0.6),
                    onTap: () => AdminQuickPriceCommandSheet.show(
                      context,
                      initialAction: PriceCommandAction.decrease,
                      initialScope: PriceCommandScope.all,
                      initialIsBangla: isBn,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildShortcutPill(
                    icon: Icons.trending_up_rounded,
                    label: isBn ? '📈 কৃষক সুরক্ষা (+১০%)' : '📈 Farmer Shield (+10%)',
                    bgColor: const Color(0xFF10B981).withValues(alpha: 0.25),
                    borderColor: const Color(0xFF10B981).withValues(alpha: 0.6),
                    onTap: () => AdminQuickPriceCommandSheet.show(
                      context,
                      initialAction: PriceCommandAction.increase,
                      initialScope: PriceCommandScope.all,
                      initialIsBangla: isBn,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildShortcutPill(
                    icon: Icons.tune_rounded,
                    label: isBn ? '⚡ কমান্ড শর্টকাট' : '⚡ Command Shortcut',
                    textColor: Colors.amberAccent,
                    bgColor: Colors.white.withValues(alpha: 0.2),
                    borderColor: Colors.white.withValues(alpha: 0.35),
                    onTap: () => AdminQuickPriceCommandSheet.show(
                      context,
                      initialAction: PriceCommandAction.syncBenchmark,
                      initialScope: PriceCommandScope.all,
                      initialIsBangla: isBn,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildShortcutPill(
                    icon: Icons.refresh_rounded,
                    label: isBn ? '🔄 রিফ্রেশ' : '🔄 Refresh',
                    textColor: Colors.cyanAccent,
                    bgColor: Colors.cyan.withValues(alpha: 0.2),
                    borderColor: Colors.cyan.withValues(alpha: 0.4),
                    onTap: () => _triggerRefresh(showToast: true),
                  ),
                ],
              ),
            ),
          ),

          // ─── Search Bar & Category Chips (Tabs 0 & 1) ───────────
          if (_tabController.index == 0 || _tabController.index == 1) ...[
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [_gradientStart, _gradientMid, _gradientEnd],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: isBn
                      ? 'পণ্য বা বিক্রেতা খুঁজুন... / Search products...'
                      : 'Search products or sellers...',
                  hintStyle: const TextStyle(color: Colors.white54, fontSize: 13),
                  prefixIcon: const Icon(Icons.search_rounded, color: Colors.white70, size: 20),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: Colors.white70, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.15),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                ),
                onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
              ),
            ),

            // ─── Category Filter Chips ────────────────────────────
            Container(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              height: 46,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                itemCount: _categories.length,
                itemBuilder: (context, i) {
                  final cat = _categories[i];
                  final isSelected = _selectedCategory == cat['key'];
                  final label = isBn ? cat['labelBn'] : cat['labelEn'];
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      selected: isSelected,
                      onSelected: (_) =>
                          setState(() => _selectedCategory = cat['key']),
                      avatar: Icon(cat['icon'] as IconData,
                          size: 14,
                          color: isSelected ? Colors.white : _accent),
                      label: Text(
                        label,
                        style: GoogleFonts.hindSiliguri(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? Colors.white : textPrimary,
                        ),
                      ),
                      backgroundColor: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                      selectedColor: _accent,
                      checkmarkColor: Colors.white,
                      showCheckmark: false,
                      side: BorderSide(
                        color: isSelected ? _accent : Colors.transparent,
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  );
                },
              ),
            ),
          ],

          // ─── Tab Views (5 Enterprise Tabs) ─────────────────────
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildProductPriceList(isBn, isDark, cardBg, textPrimary, textSec),
                _buildMarketRatesEditor(isBn, isDark, cardBg, textPrimary, textSec),
                AdminAiPriceAnalysisTab(
                  onCommandExecuted: () => setState(() {}),
                ),
                const AdminPriceCommandHistoryView(),
                const AdminPriceSafetyPolicyCard(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => AdminQuickPriceCommandSheet.show(
          context,
          initialIsBangla: isBn,
        ),
        backgroundColor: const Color(0xFF0D47A1),
        icon: const Icon(Icons.bolt_rounded, color: Colors.amberAccent),
        label: Text(
          isBn ? '⚡ প্রাইস কমান্ড শর্টকাট' : '⚡ Price Command',
          style: GoogleFonts.hindSiliguri(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildShortcutPill({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? bgColor,
    Color? borderColor,
    Color textColor = Colors.white,
    Gradient? gradient,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 12),
        decoration: BoxDecoration(
          color: bgColor,
          gradient: gradient,
          borderRadius: BorderRadius.circular(10),
          border: borderColor != null ? Border.all(color: borderColor) : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: textColor, size: 15),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.hindSiliguri(
                color: textColor,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================================================================
  // TAB 1: ALL PRODUCTS PRICE LIST (BILINGUAL)
  // ================================================================
  Widget _buildProductPriceList(
      bool isBn, bool isDark, Color cardBg, Color textPrimary, Color textSec) {
    Query query = FirebaseFirestore.instance
        .collection('products')
        .orderBy('title');

    if (_selectedCategory != 'all') {
      query = FirebaseFirestore.instance
          .collection('products')
          .where('category', whereIn: [
        _selectedCategory,
        'ProductCategory.$_selectedCategory',
      ]);
    }

    return StreamBuilder<QuerySnapshot>(
      stream: query.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: _accent));
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, color: _red, size: 48),
                const SizedBox(height: 8),
                Text('Error: ${snapshot.error}',
                    style: const TextStyle(color: _red)),
              ],
            ),
          );
        }

        var docs = snapshot.data?.docs ?? [];

        // Client-side search filter
        if (_searchQuery.isNotEmpty) {
          docs = docs.where((d) {
            final data = d.data() as Map<String, dynamic>;
            final title = (data['title'] as String? ?? '').toLowerCase();
            final seller = (data['sellerName'] as String? ?? '').toLowerCase();
            return title.contains(_searchQuery) || seller.contains(_searchQuery);
          }).toList();
        }

        if (docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.inventory_2_outlined, size: 64, color: textSec),
                const SizedBox(height: 12),
                Text(
                  isBn ? 'কোনো পণ্য পাওয়া যায়নি' : 'No products found',
                  style: GoogleFonts.hindSiliguri(
                    color: textSec,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(12),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final doc = docs[index];
            final data = doc.data() as Map<String, dynamic>;
            final price = (data['price'] as num?)?.toDouble() ?? 0.0;
            final adminPrice = (data['adminOverridePrice'] as num?)?.toDouble();
            final effectivePrice = adminPrice ?? price;
            final isOverridden = adminPrice != null;

            return _buildProductPriceCard(
              context,
              docId: doc.id,
              data: data,
              originalPrice: price,
              effectivePrice: effectivePrice,
              isOverridden: isOverridden,
              isBn: isBn,
              isDark: isDark,
              cardBg: cardBg,
              textPrimary: textPrimary,
              textSec: textSec,
            );
          },
        );
      },
    );
  }

  Widget _buildProductPriceCard(
    BuildContext context, {
    required String docId,
    required Map<String, dynamic> data,
    required double originalPrice,
    required double effectivePrice,
    required bool isOverridden,
    required bool isBn,
    required bool isDark,
    required Color cardBg,
    required Color textPrimary,
    required Color textSec,
  }) {
    final title = data['title'] as String? ?? (isBn ? 'নামবিহীন পণ্য' : 'Unknown Product');
    final seller = data['sellerName'] as String? ?? (isBn ? 'নামবিহীন বিক্রেতা' : 'Unknown Seller');
    final unit = data['unit'] as String? ?? (isBn ? 'কেজি' : 'kg');
    final category = data['category'] as String? ?? '';
    final qty = (data['quantity'] as num?)?.toDouble() ?? 0.0;

    String emoji = '🥬';
    Color catColor = _green;
    if (category.contains('fruit')) {
      emoji = '🍎';
      catColor = Colors.red;
    } else if (category.contains('grain')) {
      emoji = '🌾';
      catColor = Colors.amber.shade700;
    } else if (category.contains('fish')) {
      emoji = '🐟';
      catColor = _accent;
    } else if (category.contains('meat')) {
      emoji = '🥩';
      catColor = Colors.brown;
    } else if (category.contains('spice')) {
      emoji = '🌶️';
      catColor = Colors.deepOrange;
    } else if (category.contains('dairy')) {
      emoji = '🥛';
      catColor = Colors.teal;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      color: cardBg,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: isOverridden
              ? _accent.withValues(alpha: 0.5)
              : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
          width: isOverridden ? 1.5 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Product Icon
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: catColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(emoji, style: const TextStyle(fontSize: 22)),
              ),
            ),
            const SizedBox(width: 12),

            // Product Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: GoogleFonts.hindSiliguri(
                            fontWeight: FontWeight.bold,
                            fontSize: 13.5,
                            color: textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isOverridden)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: _accent.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            isBn ? 'এডমিন সেট' : 'ADMIN SET',
                            style: const TextStyle(
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                                color: _accent),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isBn
                        ? '🧑‍🌾 $seller | পরিমাণ: ${qty.toStringAsFixed(0)} $unit'
                        : '🧑‍🌾 $seller | Qty: ${qty.toStringAsFixed(0)} $unit',
                    style: GoogleFonts.hindSiliguri(
                        fontSize: 10.5, color: textSec),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      if (isOverridden) ...[
                        Text(
                          '৳${originalPrice.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 11,
                            color: textSec,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                        const SizedBox(width: 6),
                      ],
                      Text(
                        '৳${effectivePrice.toStringAsFixed(0)}/$unit',
                        style: GoogleFonts.hindSiliguri(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isOverridden ? _accent : textPrimary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Price Action Buttons
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildPriceActionBtn(
                  icon: Icons.arrow_upward_rounded,
                  color: _red,
                  tooltip: isBn ? 'মূল্য বৃদ্ধি' : 'Increase Price',
                  onTap: () => _showPriceDialog(
                    context,
                    docId: docId,
                    productName: title,
                    currentPrice: effectivePrice,
                    unit: unit,
                    isIncrease: true,
                    isBn: isBn,
                  ),
                ),
                const SizedBox(height: 6),
                _buildPriceActionBtn(
                  icon: Icons.arrow_downward_rounded,
                  color: _green,
                  tooltip: isBn ? 'মূল্য হ্রাস' : 'Decrease Price',
                  onTap: () => _showPriceDialog(
                    context,
                    docId: docId,
                    productName: title,
                    currentPrice: effectivePrice,
                    unit: unit,
                    isIncrease: false,
                    isBn: isBn,
                  ),
                ),
                if (isOverridden) ...[
                  const SizedBox(height: 6),
                  _buildPriceActionBtn(
                    icon: Icons.refresh_rounded,
                    color: Colors.grey,
                    tooltip: isBn ? 'আসল মূল্যে রিসেট' : 'Reset to Original',
                    onTap: () => _resetProductPrice(docId, title, isBn),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceActionBtn({
    required IconData icon,
    required Color color,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
      ),
    );
  }

  // ================================================================
  // TAB 2: MARKET RATES EDITOR (BILINGUAL)
  // ================================================================
  Widget _buildMarketRatesEditor(
      bool isBn, bool isDark, Color cardBg, Color textPrimary, Color textSec) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('market_prices')
          .orderBy('productName')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: _accent));
        }

        final docs = snapshot.data?.docs ?? [];

        if (docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.price_change_rounded,
                    size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  isBn
                      ? 'কোনো বাজার রেট কনফিগার করা হয়নি।'
                      : 'No market rates configured yet.',
                  style: GoogleFonts.hindSiliguri(
                      color: textSec, fontSize: 15),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () => _initializeDefaultMarketRates(isBn),
                  icon: const Icon(Icons.add_rounded),
                  label: Text(
                    isBn ? 'ডিফল্ট রেট চালু করুন' : 'Initialize Default Rates',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _accent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          );
        }

        var filteredDocs = docs;
        if (_selectedCategory != 'all') {
          filteredDocs = docs.where((d) {
            final data = d.data() as Map<String, dynamic>;
            final cat = (data['category'] as String? ?? '').toLowerCase();
            return cat.contains(_selectedCategory);
          }).toList();
        }
        if (_searchQuery.isNotEmpty) {
          filteredDocs = filteredDocs.where((d) {
            final data = d.data() as Map<String, dynamic>;
            final name =
                (data['productName'] as String? ?? '').toLowerCase();
            return name.contains(_searchQuery);
          }).toList();
        }

        return ListView.builder(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(12),
          itemCount: filteredDocs.length,
          itemBuilder: (context, index) {
            final doc = filteredDocs[index];
            final data = doc.data() as Map<String, dynamic>;
            return _buildMarketRateCard(
              context,
              docId: doc.id,
              data: data,
              isBn: isBn,
              isDark: isDark,
              cardBg: cardBg,
              textPrimary: textPrimary,
              textSec: textSec,
            );
          },
        );
      },
    );
  }

  Widget _buildMarketRateCard(
    BuildContext context, {
    required String docId,
    required Map<String, dynamic> data,
    required bool isBn,
    required bool isDark,
    required Color cardBg,
    required Color textPrimary,
    required Color textSec,
  }) {
    final productName = data['productName'] as String? ?? (isBn ? 'অজানা' : 'Unknown');
    final currentPrice = (data['currentPrice'] as num?)?.toDouble() ?? 0.0;
    final previousPrice = (data['previousPrice'] as num?)?.toDouble() ?? currentPrice;
    final unit = data['unit'] as String? ?? (isBn ? 'কেজি' : 'kg');
    final trendStr = data['trend'] as String? ?? 'stable';
    final imageUrl = data['imageUrl'] as String?;

    final isUp = trendStr.contains('up');
    final isDown = trendStr.contains('down');
    final diff = currentPrice - previousPrice;
    final diffPercent = previousPrice > 0 ? (diff / previousPrice * 100) : 0.0;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      color: cardBg,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Product Image / Emoji
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: const Color(0xFFE2E8F0),
              ),
              child: imageUrl != null && imageUrl.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            const Icon(Icons.image_outlined, color: Colors.grey),
                      ),
                    )
                  : const Icon(Icons.price_change_rounded,
                      color: Colors.grey, size: 26),
            ),
            const SizedBox(width: 12),

            // Name + Trend
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    productName,
                    style: GoogleFonts.hindSiliguri(
                      fontWeight: FontWeight.bold,
                      fontSize: 13.5,
                      color: textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        '৳${currentPrice.toStringAsFixed(0)}/$unit',
                        style: GoogleFonts.hindSiliguri(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isUp ? _red : isDown ? _green : textPrimary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (diff != 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: (isUp ? _red : _green)
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isUp
                                    ? Icons.arrow_upward_rounded
                                    : Icons.arrow_downward_rounded,
                                size: 10,
                                color: isUp ? _red : _green,
                              ),
                              Text(
                                '${diffPercent.abs().toStringAsFixed(1)}%',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: isUp ? _red : _green,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  Text(
                    isBn
                        ? 'পূর্বের দর: ৳${previousPrice.toStringAsFixed(0)}'
                        : 'Prev: ৳${previousPrice.toStringAsFixed(0)}',
                    style: GoogleFonts.hindSiliguri(
                        fontSize: 10.5, color: textSec),
                  ),
                ],
              ),
            ),

            // Action buttons
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildPriceActionBtn(
                  icon: Icons.arrow_upward_rounded,
                  color: _red,
                  tooltip: isBn ? 'রেট বৃদ্ধি' : 'Increase Rate',
                  onTap: () => _showMarketRateDialog(
                    context,
                    docId: docId,
                    productName: productName,
                    currentPrice: currentPrice,
                    unit: unit,
                    isIncrease: true,
                    isBn: isBn,
                  ),
                ),
                const SizedBox(height: 6),
                _buildPriceActionBtn(
                  icon: Icons.arrow_downward_rounded,
                  color: _green,
                  tooltip: isBn ? 'রেট হ্রাস' : 'Decrease Rate',
                  onTap: () => _showMarketRateDialog(
                    context,
                    docId: docId,
                    productName: productName,
                    currentPrice: currentPrice,
                    unit: unit,
                    isIncrease: false,
                    isBn: isBn,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ================================================================
  // BILINGUAL PRICE ADJUSTMENT DIALOGS
  // ================================================================
  Future<void> _showPriceDialog(
    BuildContext context, {
    required String docId,
    required String productName,
    required double currentPrice,
    required String unit,
    required bool isIncrease,
    required bool isBn,
  }) async {
    final ctrl = TextEditingController();
    bool usePercent = false;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Icon(
                isIncrease
                    ? Icons.trending_up_rounded
                    : Icons.trending_down_rounded,
                color: isIncrease ? _red : _green,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isBn
                      ? '${isIncrease ? "মূল্য বৃদ্ধি" : "মূল্য হ্রাস"}'
                      : '${isIncrease ? "Increase" : "Decrease"} Price',
                  style: GoogleFonts.hindSiliguri(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product info
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        productName,
                        style: GoogleFonts.hindSiliguri(
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    Text(
                      '৳${currentPrice.toStringAsFixed(0)}/$unit',
                      style: GoogleFonts.hindSiliguri(
                          color: _accent, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Toggle: Fixed / Percent
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setS(() => usePercent = false),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: !usePercent ? _accent : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            isBn ? 'নির্দিষ্ট (৳)' : 'Fixed (৳)',
                            style: TextStyle(
                              color: !usePercent ? Colors.white : Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setS(() => usePercent = true),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: usePercent ? _accent : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            isBn ? 'শতকরা (%)' : 'Percent (%)',
                            style: TextStyle(
                              color: usePercent ? Colors.white : Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              TextField(
                controller: ctrl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))
                ],
                decoration: InputDecoration(
                  labelText: isBn
                      ? (usePercent ? 'শতকরা হার দিন (%)' : 'টাকার পরিমাণ লিখুন (৳)')
                      : (usePercent ? 'Enter percentage (%)' : 'Enter amount (৳)'),
                  prefixText: usePercent ? '' : '৳ ',
                  suffixText: usePercent ? '%' : '',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: _accent, width: 2),
                  ),
                ),
                autofocus: true,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(isBn ? 'বাতিল' : 'Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final val = double.tryParse(ctrl.text);
                if (val == null || val <= 0) return;
                double newPrice;
                if (usePercent) {
                  newPrice = isIncrease
                      ? currentPrice * (1 + val / 100)
                      : currentPrice * (1 - val / 100);
                } else {
                  newPrice = isIncrease
                      ? currentPrice + val
                      : currentPrice - val;
                }
                if (newPrice < 1) newPrice = 1;
                Navigator.pop(ctx);
                await _applyProductPriceOverride(
                    docId, productName, newPrice.roundToDouble(), isBn);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isIncrease ? _red : _green,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: Text(
                isBn
                    ? (isIncrease ? 'বৃদ্ধি করুন' : 'হ্রাস করুন')
                    : (isIncrease ? 'Increase' : 'Decrease'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showMarketRateDialog(
    BuildContext context, {
    required String docId,
    required String productName,
    required double currentPrice,
    required String unit,
    required bool isIncrease,
    required bool isBn,
  }) async {
    final ctrl = TextEditingController();
    bool usePercent = false;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Icon(
                isIncrease
                    ? Icons.trending_up_rounded
                    : Icons.trending_down_rounded,
                color: isIncrease ? _red : _green,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isBn
                      ? 'বাজার রেট: $productName'
                      : 'Market Rate: $productName',
                  style: GoogleFonts.hindSiliguri(
                      fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isBn
                    ? 'বর্তমান: ৳${currentPrice.toStringAsFixed(0)}/$unit'
                    : 'Current: ৳${currentPrice.toStringAsFixed(0)}/$unit',
                style: GoogleFonts.hindSiliguri(
                    fontSize: 14, color: _accent, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setS(() => usePercent = false),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: !usePercent ? _accent : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            isBn ? 'নির্দিষ্ট (৳)' : 'Fixed (৳)',
                            style: TextStyle(
                              color: !usePercent ? Colors.white : Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setS(() => usePercent = true),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: usePercent ? _accent : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            isBn ? 'শতকরা (%)' : 'Percent (%)',
                            style: TextStyle(
                              color: usePercent ? Colors.white : Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: ctrl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))
                ],
                decoration: InputDecoration(
                  labelText: isBn
                      ? (usePercent ? 'শতকরা হার (%)' : 'টাকার পরিমাণ (৳)')
                      : (usePercent ? 'Percentage (%)' : 'Amount (৳)'),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: _accent, width: 2),
                  ),
                ),
                autofocus: true,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(isBn ? 'বাতিল' : 'Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final val = double.tryParse(ctrl.text);
                if (val == null || val <= 0) return;
                double newPrice;
                if (usePercent) {
                  newPrice = isIncrease
                      ? currentPrice * (1 + val / 100)
                      : currentPrice * (1 - val / 100);
                } else {
                  newPrice = isIncrease
                      ? currentPrice + val
                      : currentPrice - val;
                }
                if (newPrice < 1) newPrice = 1;
                Navigator.pop(ctx);
                await _updateMarketRate(
                    docId, productName, newPrice.roundToDouble(), currentPrice, isBn);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isIncrease ? _red : _green,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: Text(
                isBn
                    ? (isIncrease ? 'রেট বৃদ্ধি করুন' : 'রেট হ্রাস করুন')
                    : (isIncrease ? 'Increase Rate' : 'Decrease Rate'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================================================================
  // FIREBASE WRITE OPERATIONS (WITH BILINGUAL LOGS & SNACKBARS)
  // ================================================================

  Future<void> _applyProductPriceOverride(
      String docId, String productName, double newPrice, bool isBn) async {
    try {
      await FirebaseFirestore.instance
          .collection('products')
          .doc(docId)
          .update({
        'adminOverridePrice': newPrice,
        'adminOverrideAt': FieldValue.serverTimestamp(),
        'adminOverrideBy':
            FirebaseAuth.instance.currentUser?.email ?? 'admin',
      });

      await FirebaseFirestore.instance.collection('admin_price_logs').add({
        'productId': docId,
        'productName': productName,
        'newPrice': newPrice,
        'action': 'override',
        'adminEmail':
            FirebaseAuth.instance.currentUser?.email ?? 'unknown',
        'timestamp': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isBn
                  ? '✅ $productName এর মূল্য সমন্বয়: ৳${newPrice.toStringAsFixed(0)}'
                  : '✅ $productName price updated to ৳${newPrice.toStringAsFixed(0)}',
            ),
            backgroundColor: const Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: $e'),
            backgroundColor: _red,
          ),
        );
      }
    }
  }

  Future<void> _resetProductPrice(String docId, String productName, bool isBn) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(isBn ? 'দাম রিসেট নিশ্চিতকরণ' : 'Reset Price?'),
        content: Text(
          isBn
              ? '"$productName" এর দাম কৃষকের আসল মূল্যে ফিরিয়ে নিতে চান?'
              : 'Reset "$productName" back to the farmer\'s original price?',
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(isBn ? 'বাতিল' : 'Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: Text(isBn ? 'রিসেট' : 'Reset', style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await FirebaseFirestore.instance
          .collection('products')
          .doc(docId)
          .update({
        'adminOverridePrice': FieldValue.delete(),
        'adminOverrideAt': FieldValue.delete(),
        'adminOverrideBy': FieldValue.delete(),
      });

      await FirebaseFirestore.instance.collection('admin_price_logs').add({
        'productId': docId,
        'productName': productName,
        'action': 'reset',
        'adminEmail':
            FirebaseAuth.instance.currentUser?.email ?? 'unknown',
        'timestamp': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isBn
                  ? '🔄 $productName এর দাম আসল মূল্যে ফিরিয়ে নেওয়া হয়েছে।'
                  : '🔄 $productName price reset to original.',
            ),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: _red),
        );
      }
    }
  }

  Future<void> _updateMarketRate(
      String docId, String productName, double newPrice, double prevPrice, bool isBn) async {
    try {
      final trend = newPrice > prevPrice ? 'PriceTrend.up' : 'PriceTrend.down';
      await FirebaseFirestore.instance
          .collection('market_prices')
          .doc(docId)
          .update({
        'currentPrice': newPrice,
        'previousPrice': prevPrice,
        'trend': trend,
        'updatedAt': DateTime.now().toIso8601String(),
        'updatedBy':
            FirebaseAuth.instance.currentUser?.email ?? 'admin',
      });

      await FirebaseFirestore.instance.collection('admin_price_logs').add({
        'collection': 'market_prices',
        'docId': docId,
        'productName': productName,
        'newPrice': newPrice,
        'previousPrice': prevPrice,
        'action': 'market_rate_update',
        'adminEmail':
            FirebaseAuth.instance.currentUser?.email ?? 'unknown',
        'timestamp': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isBn
                  ? '📊 $productName এর বাজার রেট → ৳${newPrice.toStringAsFixed(0)}'
                  : '📊 $productName market rate → ৳${newPrice.toStringAsFixed(0)}',
            ),
            backgroundColor: _accent,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: _red),
        );
      }
    }
  }

  Future<void> _initializeDefaultMarketRates(bool isBn) async {
    final defaults = [
      {'id': 'tomato', 'productName': 'টমেটো', 'category': 'vegetables', 'currentPrice': 80.0, 'unit': 'কেজি', 'imageUrl': 'https://res.cloudinary.com/dbbvlg2dz/image/upload/v1782757091/Tomato_hcjt7o.png'},
      {'id': 'potato', 'productName': 'আলু', 'category': 'vegetables', 'currentPrice': 40.0, 'unit': 'কেজি', 'imageUrl': 'https://res.cloudinary.com/dbbvlg2dz/image/upload/v1782584736/Screenshot_2026-06-28_002524_ziwqmo.png'},
      {'id': 'onion', 'productName': 'পেঁয়াজ', 'category': 'vegetables', 'currentPrice': 90.0, 'unit': 'কেজি', 'imageUrl': 'https://res.cloudinary.com/dbbvlg2dz/image/upload/v1782757375/images_z5w9hg.jpg'},
      {'id': 'chilli', 'productName': 'কাঁচা মরিচ', 'category': 'spices', 'currentPrice': 150.0, 'unit': 'কেজি', 'imageUrl': ''},
      {'id': 'rice', 'productName': 'চাল (মিনিকেট)', 'category': 'grains', 'currentPrice': 70.0, 'unit': 'কেজি', 'imageUrl': 'https://res.cloudinary.com/dbbvlg2dz/image/upload/v1782584453/Screenshot_2026-06-28_002037_e5q6ll.png'},
      {'id': 'mango', 'productName': 'আম (হিমসাগর)', 'category': 'fruits', 'currentPrice': 100.0, 'unit': 'কেজি', 'imageUrl': 'https://res.cloudinary.com/dbbvlg2dz/image/upload/v1782583216/image_sxwwpa.png'},
      {'id': 'rui_fish', 'productName': 'রুই মাছ', 'category': 'fish', 'currentPrice': 350.0, 'unit': 'কেজি', 'imageUrl': 'https://res.cloudinary.com/dbbvlg2dz/image/upload/v1782734272/Screenshot_2026-06-29_175728_q4k1bk.png'},
      {'id': 'beef', 'productName': 'গরুর মাংস', 'category': 'meat', 'currentPrice': 750.0, 'unit': 'কেজি', 'imageUrl': 'https://res.cloudinary.com/dbbvlg2dz/image/upload/v1782756123/images_wrgten.webp'},
      {'id': 'chicken', 'productName': 'মুরগি (ব্রয়লার)', 'category': 'meat', 'currentPrice': 200.0, 'unit': 'কেজি', 'imageUrl': 'https://res.cloudinary.com/dbbvlg2dz/image/upload/v1782757555/images_xgtcyf.jpg'},
      {'id': 'egg', 'productName': 'ডিম (হালি)', 'category': 'dairy', 'currentPrice': 50.0, 'unit': 'হালি', 'imageUrl': 'https://res.cloudinary.com/dbbvlg2dz/image/upload/v1782756249/download_ezwxls.jpg'},
      {'id': 'hilsa', 'productName': 'ইলিশ মাছ', 'category': 'fish', 'currentPrice': 900.0, 'unit': 'কেজি', 'imageUrl': ''},
      {'id': 'catfish', 'productName': 'কই মাছ', 'category': 'fish', 'currentPrice': 280.0, 'unit': 'কেজি', 'imageUrl': ''},
      {'id': 'garlic', 'productName': 'রসুন', 'category': 'spices', 'currentPrice': 200.0, 'unit': 'কেজি', 'imageUrl': ''},
      {'id': 'ginger', 'productName': 'আদা', 'category': 'spices', 'currentPrice': 120.0, 'unit': 'কেজি', 'imageUrl': ''},
    ];

    final batch = FirebaseFirestore.instance.batch();
    for (final item in defaults) {
      final ref = FirebaseFirestore.instance
          .collection('market_prices')
          .doc(item['id'] as String);
      batch.set(ref, {
        ...item,
        'previousPrice': item['currentPrice'],
        'trend': 'PriceTrend.stable',
        'updatedAt': DateTime.now().toIso8601String(),
        'location': 'সারা বাংলাদেশ',
      });
    }
    await batch.commit();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isBn
                ? '✅ ডিফল্ট বাজার রেট সফলভাবে চালু করা হয়েছে!'
                : '✅ Default market rates initialized!',
          ),
          backgroundColor: const Color(0xFF10B981),
        ),
      );
    }
  }
}
