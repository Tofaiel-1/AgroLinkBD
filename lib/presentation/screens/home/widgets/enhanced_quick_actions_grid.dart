import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:agrolinkbd/core/providers/language_provider.dart';
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
    final bool isBn = LanguageProvider.isBn(context);

    int crossAxisCount;
    if (isMobile) {
      crossAxisCount = 3;
    } else if (isTablet) {
      crossAxisCount = 4;
    } else {
      crossAxisCount = 5;
    }

    final actions = _getActions(context);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isBn ? 'দ্রুত সেবা সমূহ ⚡' : 'Quick Actions ⚡',
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

  List<Map<String, dynamic>> _getActions(BuildContext context) {
    final bool isBn = LanguageProvider.isBn(context);
    return [
      {
        'icon': Icons.qr_code,
        'label': isBn ? 'আমার কার্ড' : 'My Card',
        'subtitle': isBn ? 'ডিজিটাল কার্ড' : 'Digital ID',
        'color': const Color(0xFF2E7D32),
        'onTap': () => Get.to(() => const agrolinkbd.CardPreviewScreen()),
      },
      {
        'icon': Icons.agriculture,
        'label': isBn ? 'যন্ত্রপাতি' : 'Machinery',
        'subtitle': isBn ? 'ভাড়া নিন 🚜' : 'Rent Now 🚜',
        'color': const Color(0xFF1976D2),
        'onTap': () => Get.to(() => const MachineryRentalScreen()),
      },
      {
        'icon': Icons.local_shipping,
        'label': isBn ? 'পরিবহন' : 'Transport',
        'subtitle': isBn ? 'পণ্য পাঠান 🚚' : 'Send Crop 🚚',
        'color': const Color(0xFFFF6F00),
        'onTap': () => Get.to(() => const UpazilaTransportScreen()),
      },
      {
        'icon': Icons.video_call_rounded,
        'label': isBn ? 'ডাক্তার কল' : 'Doctor Call',
        'subtitle': isBn ? 'লাইভ পরামর্শ 🩺' : 'Live Consult 🩺',
        'color': const Color(0xFF6A1B9A),
        'onTap': () => Get.to(() => const AgriTelemedicineScreen()),
      },
      {
        'icon': Icons.assignment_turned_in,
        'label': isBn ? 'চাহিদা বোর্ড' : 'RFQ Board',
        'subtitle': isBn ? 'পাইকারি টেন্ডার 📋' : 'Wholesale RFQ 📋',
        'color': const Color(0xFFC62828),
        'onTap': () => Get.to(() => const BuyerRfqBoardScreen()),
      },
      {
        'icon': Icons.gavel,
        'label': isBn ? 'নিলাম' : 'Auction',
        'subtitle': isBn ? 'বিডিং করুন ⚖️' : 'Live Bidding ⚖️',
        'color': const Color(0xFF0097A7),
        'onTap': () => Get.to(() => const AuctionScreen()),
      },
      {
        'icon': Icons.attach_money,
        'label': isBn ? 'বিনিয়োগ' : 'Investment',
        'subtitle': isBn ? 'লাভ করুন 📈' : 'Agri Funds 📈',
        'color': const Color(0xFF388E3C),
        'onTap': () => Get.to(() => const InvestmentScreen()),
      },
    ];
  }
}
