import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

const _kBg      = Color(0xFF0D1B3E);
const _kGlass   = Color(0x0DFFFFFF);
const _kBorder  = Color(0x1AFFFFFF);
const _kGreen   = Color(0xFF10B981);
const _kBlue    = Color(0xFF3B82F6);
const _kAmber   = Color(0xFFF59E0B);
const _kRed     = Color(0xFFEF4444);
const _kText    = Colors.white;
const _kSubtext = Color(0xFFAEB8CC);

// ─────────────────────────────────────────────
// EMI Model
// ─────────────────────────────────────────────
class _EmiItem {
  final String month;
  final String amount;
  final String status; // 'paid', 'due', 'upcoming'
  
  const _EmiItem({
    required this.month,
    required this.amount,
    required this.status,
  });
}

final _emiSchedule = [
  const _EmiItem(month: 'March 2024', amount: '৳5,000', status: 'paid'),
  const _EmiItem(month: 'April 2024', amount: '৳5,000', status: 'paid'),
  const _EmiItem(month: 'May 2024', amount: '৳5,000', status: 'paid'),
  const _EmiItem(month: 'June 2024', amount: '৳5,000', status: 'due'),
  const _EmiItem(month: 'July 2024', amount: '৳5,000', status: 'upcoming'),
  const _EmiItem(month: 'August 2024', amount: '৳5,000', status: 'upcoming'),
];

// ─────────────────────────────────────────────
// Screen
// ─────────────────────────────────────────────
class MicrofinanceRepaymentScreen extends StatefulWidget {
  const MicrofinanceRepaymentScreen({super.key});

  @override
  State<MicrofinanceRepaymentScreen> createState() => _MicrofinanceRepaymentScreenState();
}

class _MicrofinanceRepaymentScreenState extends State<MicrofinanceRepaymentScreen>
    with SingleTickerProviderStateMixin {
  
  late final AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: Stack(
        children: [
          _buildOrbs(),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      SliverToBoxAdapter(child: _buildNextPaymentCard()),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                          child: const Text('Payment Methods',
                              style: TextStyle(color: _kText, fontSize: 16, fontWeight: FontWeight.w700)),
                        ),
                      ),
                      SliverToBoxAdapter(child: _buildPaymentMethods()),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 32, 20, 16),
                          child: const Text('EMI Schedule',
                              style: TextStyle(color: _kText, fontSize: 16, fontWeight: FontWeight.w700)),
                        ),
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) => _buildEmiTimelineItem(_emiSchedule[index], index),
                            childCount: _emiSchedule.length,
                          ),
                        ),
                      ),
                      const SliverToBoxAdapter(child: SizedBox(height: 40)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrbs() => Stack(
        children: [
          Positioned(
            top: -100,
            left: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _kBlue.withOpacity(0.15),
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            right: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _kAmber.withOpacity(0.1),
              ),
            ),
          ),
        ],
      );

  Widget _buildHeader() => Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        child: Row(
          children: [
            GestureDetector(
              onTap: () => Get.back(),
              child: _glassBtn(Icons.arrow_back_ios_new_rounded),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Repayment',
                      style: TextStyle(color: _kText, fontSize: 20, fontWeight: FontWeight.w700, letterSpacing: -0.4)),
                  Text('Manage your EMI schedule',
                      style: TextStyle(color: _kSubtext, fontSize: 12)),
                ],
              ),
            ),
            _glassBtn(Icons.history_rounded),
          ],
        ),
      );

  Widget _glassBtn(IconData icon) => ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: _kGlass,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _kBorder),
            ),
            child: Icon(icon, color: _kText, size: 20),
          ),
        ),
      );

  Widget _buildNextPaymentCard() => Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [_kBlue.withOpacity(0.2), _kBlue.withOpacity(0.05)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: _kBlue.withOpacity(0.3)),
                boxShadow: [
                  BoxShadow(color: _kBlue.withOpacity(0.1), blurRadius: 20),
                ],
              ),
              child: Column(
                children: [
                  const Text('Next Payment Due', style: TextStyle(color: _kSubtext, fontSize: 13)),
                  const SizedBox(height: 8),
                  const Text('৳ 5,000', style: TextStyle(color: _kText, fontSize: 36, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 4),
                  const Text('Due on 10 June, 2024', style: TextStyle(color: _kBlue, fontSize: 14, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _countdownItem('04', 'Days'),
                      _countdownItem('12', 'Hours'),
                      _countdownItem('30', 'Mins'),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );

  Widget _countdownItem(String value, String label) => Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: Text(value, style: const TextStyle(color: _kText, fontSize: 20, fontWeight: FontWeight.w700)),
          ),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(color: _kSubtext, fontSize: 11)),
        ],
      );

  Widget _buildPaymentMethods() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: [
            Expanded(child: _paymentMethodCard('bKash', Icons.account_balance_wallet_rounded, const Color(0xFFE2136E))),
            const SizedBox(width: 12),
            Expanded(child: _paymentMethodCard('Nagad', Icons.account_balance_wallet_rounded, const Color(0xFFF7931E))),
            const SizedBox(width: 12),
            Expanded(child: _paymentMethodCard('Bank Slip', Icons.upload_file_rounded, _kBlue)),
          ],
        ),
      );

  Widget _paymentMethodCard(String name, IconData icon, Color color) => ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: _kGlass,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _kBorder),
            ),
            child: Column(
              children: [
                Icon(icon, color: color, size: 28),
                const SizedBox(height: 8),
                Text(name, style: const TextStyle(color: _kText, fontSize: 12, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ),
      );

  Widget _buildEmiTimelineItem(_EmiItem item, int index) {
    final isLast = index == _emiSchedule.length - 1;
    
    Color dotColor;
    IconData icon;
    bool isPulsing = false;
    
    switch (item.status) {
      case 'paid':
        dotColor = _kGreen;
        icon = Icons.check_circle_rounded;
        break;
      case 'due':
        dotColor = _kAmber;
        icon = Icons.error_rounded;
        isPulsing = true;
        break;
      case 'upcoming':
      default:
        dotColor = _kSubtext.withOpacity(0.5);
        icon = Icons.radio_button_unchecked_rounded;
        break;
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Timeline line and dot
          SizedBox(
            width: 30,
            child: Column(
              children: [
                if (isPulsing)
                  AnimatedBuilder(
                    animation: _pulseCtrl,
                    builder: (context, child) => Container(
                      margin: const EdgeInsets.only(top: 16),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: _kAmber.withOpacity(0.5 * _pulseCtrl.value),
                            blurRadius: 10 * _pulseCtrl.value,
                            spreadRadius: 2 * _pulseCtrl.value,
                          )
                        ]
                      ),
                      child: Icon(icon, color: dotColor, size: 20),
                    )
                  )
                else
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Icon(icon, color: dotColor, size: 20),
                  ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      color: item.status == 'paid' ? _kGreen.withOpacity(0.5) : Colors.white.withOpacity(0.1),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Content Card
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: item.status == 'due' ? _kAmber.withOpacity(0.1) : _kGlass,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: item.status == 'due' ? _kAmber.withOpacity(0.3) : _kBorder,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.month, style: const TextStyle(color: _kText, fontSize: 14, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 4),
                            Text(
                              item.status.toUpperCase(),
                              style: TextStyle(
                                color: dotColor,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                        Text(item.amount, style: const TextStyle(color: _kText, fontSize: 16, fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
