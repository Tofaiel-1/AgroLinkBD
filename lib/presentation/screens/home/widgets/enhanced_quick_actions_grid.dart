import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:agrolinkbd/presentation/screens/transport/transport_screen.dart';
import 'package:agrolinkbd/presentation/screens/auction/auction_screen.dart';
import 'package:agrolinkbd/presentation/screens/investment/investment_screen.dart';
import 'package:agrolinkbd/presentation/screens/marketplace/marketplace_screen.dart';
import 'package:agrolinkbd/presentation/screens/machinery/machinery_rental_screen.dart';
import 'enhanced_quick_action_card.dart';

class EnhancedQuickActionsGrid extends StatelessWidget {
  const EnhancedQuickActionsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 600;
    final isTablet = size.width < 900;

    int crossAxisCount;
    if (isMobile) {
      crossAxisCount = 3;
    } else if (isTablet) {
      crossAxisCount = 4;
    } else {
      crossAxisCount = 5;
    }

    final actions = _getActions();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'দ্রুত সেবা',
            style: GoogleFonts.poppins(
              fontSize: isMobile ? 18 : 20,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1B5E20),
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: isMobile ? 12 : 14,
              mainAxisSpacing: isMobile ? 12 : 14,
              childAspectRatio: 0.9,
            ),
            itemCount: actions.length,
            itemBuilder: (context, index) {
              final action = actions[index];
              return TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: Duration(milliseconds: 400 + (index * 50)),
                builder: (context, value, child) {
                  return Transform.translate(
                    offset: Offset(0, (1 - value) * 30),
                    child: Opacity(
                      opacity: value,
                      child: child,
                    ),
                  );
                },
                child: EnhancedQuickActionCard(
                  icon: action['icon'],
                  label: action['label'],
                  subtitle: action['subtitle'],
                  color: action['color'],
                  onTap: action['onTap'],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getActions() {
    return [
      {
        'icon': Icons.agriculture,
        'label': 'যন্ত্রপাতি',
        'subtitle': 'ভাড়া নিন',
        'color': const Color(0xFF1976D2),
        'onTap': () => Get.to(() => const MachineryRentalScreen()),
      },
      {
        'icon': Icons.local_shipping,
        'label': 'পরিবহন',
        'subtitle': 'পণ্য পাঠান',
        'color': const Color(0xFFFF6F00),
        'onTap': () => Get.to(() => const TransportScreen()),
      },
      {
        'icon': Icons.gavel,
        'label': 'নিলাম',
        'subtitle': 'বিডিং করুন',
        'color': const Color(0xFF7B1FA2),
        'onTap': () => Get.to(() => const AuctionScreen()),
      },
      {
        'icon': Icons.attach_money,
        'label': 'বিনিয়োগ',
        'subtitle': 'লাভ করুন',
        'color': const Color(0xFF0097A7),
        'onTap': () => Get.to(() => const InvestmentScreen()),
      },
      {
        'icon': Icons.science,
        'label': 'মাটি পরীক্ষা',
        'subtitle': 'শিঘ্রই আসছে',
        'color': const Color(0xFF6D4C41),
        'onTap': () {
          Get.snackbar(
            'মাটি পরীক্ষা',
            'শীঘ্রই আসছে',
            backgroundColor: const Color(0xFF2E7D32),
            colorText: Colors.white,
            borderRadius: 12,
            margin: const EdgeInsets.all(12),
            duration: const Duration(seconds: 2),
          );
        },
      },
      {
        'icon': Icons.mic,
        'label': 'পরামর্শ',
        'subtitle': 'বিশেষজ্ঞের পরামর্শ',
        'color': const Color(0xFFD32F2F),
        'onTap': () {
          Get.snackbar(
            'কৃষক পরামর্শ',
            'শীঘ্রই আসছে',
            backgroundColor: const Color(0xFF2E7D32),
            colorText: Colors.white,
            borderRadius: 12,
            margin: const EdgeInsets.all(12),
            duration: const Duration(seconds: 2),
          );
        },
      },
      {
        'icon': Icons.calendar_today,
        'label': 'ক্যালেন্ডার',
        'subtitle': 'ফসল পরিকল্পনা',
        'color': const Color(0xFF00838F),
        'onTap': () {
          Get.snackbar(
            'ক্যালেন্ডার',
            'শীঘ্রই আসছে',
            backgroundColor: const Color(0xFF2E7D32),
            colorText: Colors.white,
            borderRadius: 12,
            margin: const EdgeInsets.all(12),
            duration: const Duration(seconds: 2),
          );
        },
      },
      {
        'icon': Icons.business,
        'label': 'চুক্তি চাষ',
        'subtitle': 'নিরাপদ বিক্রয়',
        'color': const Color(0xFF5E35B1),
        'onTap': () {
          Get.snackbar(
            'চুক্তি চাষাবাদ',
            'শীঘ্রই আসছে',
            backgroundColor: const Color(0xFF2E7D32),
            colorText: Colors.white,
            borderRadius: 12,
            margin: const EdgeInsets.all(12),
            duration: const Duration(seconds: 2),
          );
        },
      },
    ];
  }
}
