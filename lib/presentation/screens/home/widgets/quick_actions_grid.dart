import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:agrolinkbd/core/providers/language_provider.dart';
import 'package:agrolinkbd/presentation/screens/transport/transport_screen.dart';
import 'package:agrolinkbd/presentation/screens/auction/auction_screen.dart';
import 'package:agrolinkbd/presentation/screens/investment/investment_screen.dart';
import 'package:agrolinkbd/presentation/screens/marketplace/marketplace_screen.dart';
import 'package:agrolinkbd/presentation/screens/machinery/machinery_rental_screen.dart';
import 'quick_action_card.dart';

class QuickActionsGrid extends StatefulWidget {
  const QuickActionsGrid({super.key});

  @override
  State<QuickActionsGrid> createState() => _QuickActionsGridState();
}

class _QuickActionsGridState extends State<QuickActionsGrid>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isBn = LanguageProvider.isBn(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isBn ? 'দ্রুত সেবা' : 'Quick Actions',
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1B5E20),
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 18),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: 0.82,
            ),
            itemCount: _getActions(isBn).length,
            itemBuilder: (context, index) {
              final action = _getActions(isBn)[index];
              return _buildAnimatedCard(index, action);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedCard(int index, Map<String, dynamic> action) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 600),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, (1 - value) * 30),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: QuickActionCard(
        icon: action['icon'],
        label: action['label'],
        onTap: action['onTap'],
      ),
    );
  }

  List<Map<String, dynamic>> _getActions(bool isBn) {
    return [
      {
        'icon': Icons.shopping_cart,
        'label': isBn ? 'মার্কেটপ্লেস' : 'Marketplace',
        'onTap': () => Get.to(() => const MarketplaceScreen()),
      },
      {
        'icon': Icons.agriculture,
        'label': isBn ? 'যন্ত্রপাতি' : 'Machinery',
        'onTap': () => Get.to(() => const MachineryRentalScreen()),
      },
      {
        'icon': Icons.local_shipping,
        'label': isBn ? 'পরিবহন' : 'Transport',
        'onTap': () => Get.to(() => const TransportScreen()),
      },
      {
        'icon': Icons.gavel,
        'label': isBn ? 'নিলাম' : 'Auction',
        'onTap': () => Get.to(() => const AuctionScreen()),
      },
      {
        'icon': Icons.attach_money,
        'label': isBn ? 'বিনিয়োগ' : 'Investment',
        'onTap': () => Get.to(() => const InvestmentScreen()),
      },
      {
        'icon': Icons.science,
        'label': isBn ? 'মাটি পরীক্ষা' : 'Soil Testing',
        'onTap': () {
          Get.snackbar(
            isBn ? 'মাটি পরীক্ষা' : 'Soil Testing',
            isBn ? 'শীঘ্রই আসছে' : 'Coming Soon',
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
        'label': isBn ? 'পরামর্শ' : 'Advisor',
        'onTap': () {
          Get.snackbar(
            isBn ? 'কৃষক পরামর্শ' : 'Farmer Advisor',
            isBn ? 'শীঘ্রই আসছে' : 'Coming Soon',
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
        'label': isBn ? 'ক্যালেন্ডার' : 'Calendar',
        'onTap': () {
          Get.snackbar(
            isBn ? 'ক্যালেন্ডার' : 'Calendar',
            isBn ? 'শীঘ্রই আসছে' : 'Coming Soon',
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
        'label': isBn ? 'চাষাবাদ' : 'Farming',
        'onTap': () {
          Get.snackbar(
            isBn ? 'চুক্তি চাষাবাদ' : 'Contract Farming',
            isBn ? 'শীঘ্রই আসছে' : 'Coming Soon',
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
