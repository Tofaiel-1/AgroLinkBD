import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'দ্রুত সেবা',
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
            itemCount: _getActions().length,
            itemBuilder: (context, index) {
              final action = _getActions()[index];
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

  List<Map<String, dynamic>> _getActions() {
    return [
      {
        'icon': Icons.shopping_cart,
        'label': 'Marketplace',
        'onTap': () => Get.to(() => const MarketplaceScreen()),
      },
      {
        'icon': Icons.agriculture,
        'label': 'Machinery',
        'onTap': () => Get.to(() => const MachineryRentalScreen()),
      },
      {
        'icon': Icons.local_shipping,
        'label': 'Transport',
        'onTap': () => Get.to(() => const TransportScreen()),
      },
      {
        'icon': Icons.gavel,
        'label': 'Auction',
        'onTap': () => Get.to(() => const AuctionScreen()),
      },
      {
        'icon': Icons.attach_money,
        'label': 'Investment',
        'onTap': () => Get.to(() => const InvestmentScreen()),
      },
      {
        'icon': Icons.science,
        'label': 'Soil Testing',
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
        'label': 'Advisor',
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
        'label': 'Calendar',
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
        'label': 'Farming',
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
