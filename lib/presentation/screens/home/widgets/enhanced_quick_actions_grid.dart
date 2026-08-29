import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:agrolinkbd/presentation/screens/transport/upazila_transport_screen.dart';
import 'package:agrolinkbd/presentation/screens/auction/auction_screen.dart';
import 'package:agrolinkbd/presentation/screens/investment/investment_screen.dart';
import 'package:agrolinkbd/presentation/screens/machinery/machinery_rental_screen.dart';
import 'package:agrolinkbd/presentation/screens/telemedicine/agri_telemedicine_screen.dart';
import 'package:agrolinkbd/presentation/screens/marketplace/buyer_rfq_board_screen.dart';
import 'package:agrolinkbd/presentation/screens/card/card_preview_screen.dart' as agrolinkbd;
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
            'দ্রুত সেবা সমূহ ⚡',
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
        'icon': Icons.qr_code,
        'label': 'আমার কার্ড',
        'subtitle': 'ডিজিটাল কার্ড',
        'color': const Color(0xFF2E7D32),
        'onTap': () => Get.to(() => const agrolinkbd.CardPreviewScreen()),
      },
      {
        'icon': Icons.agriculture,
        'label': 'যন্ত্রপাতি',
        'subtitle': 'ভাড়া নিন 🚜',
        'color': const Color(0xFF1976D2),
        'onTap': () => Get.to(() => const MachineryRentalScreen()),
      },
      {
        'icon': Icons.local_shipping,
        'label': 'পরিবহন',
        'subtitle': 'পণ্য পাঠান 🚚',
        'color': const Color(0xFFFF6F00),
        'onTap': () => Get.to(() => const UpazilaTransportScreen()),
      },
      {
        'icon': Icons.video_call_rounded,
        'label': 'ডাক্তার কল',
        'subtitle': 'লাইভ পরামর্শ 🩺',
        'color': const Color(0xFF6A1B9A),
        'onTap': () => Get.to(() => const AgriTelemedicineScreen()),
      },
      {
        'icon': Icons.assignment_turned_in,
        'label': 'চাহিদা বোর্ড',
        'subtitle': 'পাইকারি টেন্ডার 📋',
        'color': const Color(0xFFC62828),
        'onTap': () => Get.to(() => const BuyerRfqBoardScreen()),
      },
      {
        'icon': Icons.gavel,
        'label': 'নিলাম',
        'subtitle': 'বিডিং করুন ⚖️',
        'color': const Color(0xFF0097A7),
        'onTap': () => Get.to(() => const AuctionScreen()),
      },
      {
        'icon': Icons.attach_money,
        'label': 'বিনিয়োগ',
        'subtitle': 'লাভ করুন 📈',
        'color': const Color(0xFF388E3C),
        'onTap': () => Get.to(() => const InvestmentScreen()),
      },
    ];
  }
}
