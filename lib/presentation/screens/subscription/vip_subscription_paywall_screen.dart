import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:agrolinkbd/core/providers/user_provider.dart';
import 'package:agrolinkbd/core/services/vip_subscription_service.dart';

class VipSubscriptionPaywallScreen extends StatefulWidget {
  final String? highlightFeature;

  const VipSubscriptionPaywallScreen({super.key, this.highlightFeature});

  @override
  State<VipSubscriptionPaywallScreen> createState() => _VipSubscriptionPaywallScreenState();
}

class _VipSubscriptionPaywallScreenState extends State<VipSubscriptionPaywallScreen> {
  int _selectedPlanIndex = 1; // Default to Seasonal / Recommended
  bool _isProcessingSsl = false;
  final VipSubscriptionService _vipService = VipSubscriptionService();

  final List<Map<String, dynamic>> _plans = [
    {
      'name': 'মাসিক প্রো পাস',
      'subtitle': '১ মাস মেয়াদী সাবস্ক্রিপশন',
      'price': 299.0,
      'duration': const Duration(days: 30),
      'tag': 'বেসিক',
      'color': Colors.blueGrey,
    },
    {
      'name': 'সিজনাল পাস (Agro Pass)',
      'subtitle': '৬ মাস মেয়াদী • সেরা বাণিজ্যিক চয়েস',
      'price': 999.0,
      'duration': const Duration(days: 180),
      'tag': 'সবচেয়ে জনপ্রিয় ⭐',
      'color': const Color(0xFFE65100),
    },
    {
      'name': 'এন্টারপ্রাইজ পার্টনারশিপ',
      'subtitle': '১২ মাস মেয়াদী • আনলিমিটেড প্রিমিয়াম',
      'price': 2499.0,
      'duration': const Duration(days: 365),
      'tag': 'সর্বোচ্চ সেভিংস 💎',
      'color': const Color(0xFF006064),
    },
  ];

  Future<void> _handleSslCommerzPayment(BuildContext context, Map<String, dynamic> selected) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.currentUser;

    setState(() => _isProcessingSsl = true);

    try {
      final success = await _vipService.initiateSslCommerzPayment(
        context,
        userId: user?.id ?? 'guest_user',
        userName: user?.name ?? 'Valued Trader',
        userPhone: user?.phone ?? '01700000000',
        userEmail: user?.email ?? 'trader@agrolinkbd.com',
        amount: selected['price'],
        planName: selected['name'],
      );

      if (success) {
        final expiryDate = DateTime.now().add(selected['duration'] as Duration);
        await userProvider.upgradeToPremium(expiryDate);
        if (mounted) {
          setState(() {});
          _showVipSuccessDialog(selected['name'], expiryDate);
        }
      }
    } catch (e) {
      debugPrint('VIP SSL Payment Error: $e');
    } finally {
      if (mounted) {
        setState(() => _isProcessingSsl = false);
      }
    }
  }

  void _showVipSuccessDialog(String planName, DateTime expiryDate) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFFFFF8E1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.workspace_premium, size: 60, color: Color(0xFFE65100)),
            ),
            const SizedBox(height: 16),
            Text(
              'ভিআইপি সক্রিয় হয়েছে! 👑',
              style: GoogleFonts.hindSiliguri(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'আপনার $planName সফলভাবে সক্রিয় করা হয়েছে। মেয়াদ: ${expiryDate.day}/${expiryDate.month}/${expiryDate.year}',
              textAlign: TextAlign.center,
              style: GoogleFonts.hindSiliguri(fontSize: 14, color: Colors.grey.shade700),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE65100),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text('ধন্যবাদ', style: GoogleFonts.hindSiliguri(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  final List<Map<String, dynamic>> _premiumFeatures = [
    {
      'icon': Icons.trending_up,
      'title': '১৪-দিনের এআই পাইকারি দর প্রেডিকশন',
      'desc': 'কাওরান বাজার ও প্রধান মোকামের ভবিষ্যৎ দামের নিখুঁত পূর্বাভাস।',
    },
    {
      'icon': Icons.satellite_alt,
      'title': 'স্যাটেলাইট শেওলা ও অতিবৃষ্টি-বন্যা রাডার',
      'desc': 'অক্সিজেন ড্রপ ও পুকুরের পাড় ভাঙার লাইভ এসওএস নোটিফিকেশন।',
    },
    {
      'icon': Icons.account_balance,
      'title': 'ব্যাংক লোন ও অ্যাকোয়াকালচার প্রজেক্ট ডসিয়ার',
      'desc': 'কৃষি ও সোনালী ব্যাংকের জন্য ১ ক্লিকে প্রজেক্ট ফাইল ডাউনলোড।',
    },
    {
      'icon': Icons.phone_in_talk,
      'title': 'ভিআইপি ডিরেক্ট মোকাম আড়তদার ডিরেক্টরি',
      'desc': 'শীর্ষ ১০০+ পাইকার ও এক্সপোর্টারদের সাথে সরাসরি ফোন ও চ্যাট।',
    },
    {
      'icon': Icons.verified,
      'title': 'গোল্ড ট্রাস্ট ব্যাজ ও ৩ গুণ বেশি বিড প্লেসমেন্ট',
      'desc': 'নিলাম ও বাজারে লিস্টিং সবার উপরে প্রদর্শিত হবে।',
    },
    {
      'icon': Icons.percent,
      'title': '০% বায়ার এসক্রো ট্রানজেকশন ফি',
      'desc': 'পাইকারি লেনদেনে কোনো অতিরিক্ত কমিশন বা সার্ভিস চার্জ নেই।',
    },
  ];

  @override
  Widget build(BuildContext context) {
    const Color goldAccent = Color(0xFFFFB300);
    const Color deepAmber = Color(0xFFE65100);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isPremium = Provider.of<UserProvider>(context).isPremium;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFFAFBFD),
      appBar: AppBar(
        title: Text(
          'এগ্রোলিংক ভিআইপি পাস 👑',
          style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: deepAmber,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Shimmering VIP Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFE65100), Color(0xFFFF8F00), Color(0xFFFFB300)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: deepAmber.withOpacity(0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Icon(Icons.workspace_premium, size: 55, color: Colors.white),
                  const SizedBox(height: 8),
                  Text(
                    isPremium ? 'আপনি একজন গর্বিত ভিআইপি মেম্বার! 👑' : 'ব্যবসা ও খামারের আয় বাড়ান ৩ গুণ!',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.hindSiliguri(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isPremium
                        ? 'আপনার সকল প্রিমিয়াম সুবিধা সক্রিয় রয়েছে।'
                        : 'এআই প্রাইজ ফোরকাস্ট, স্যাটেলাইট রাডার ও মোকাম ডিরেক্টরি দিয়ে নিশ্চিত লাভ করুন।',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.hindSiliguri(fontSize: 13, color: Colors.white.withOpacity(0.9)),
                  ),
                ],
              ),
            ),

            if (widget.highlightFeature != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: goldAccent),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.lock_open, color: deepAmber, size: 22),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'আপনি "${widget.highlightFeature}" ফিচারটি আনলক করার চেষ্টা করছেন। নিচে থেকে প্ল্যান বেছে নিন।',
                        style: GoogleFonts.hindSiliguri(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.brown.shade900),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 24),
            Text('সাবস্ক্রিপশন প্ল্যান বেছে নিন', style: GoogleFonts.hindSiliguri(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            // Plan Selector Cards
            ...List.generate(_plans.length, (index) {
              final plan = _plans[index];
              final isSelected = _selectedPlanIndex == index;

              return InkWell(
                onTap: () => setState(() => _selectedPlanIndex = index),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? (isDark ? Colors.amber.shade900.withOpacity(0.2) : const Color(0xFFFFF8E1))
                        : Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? deepAmber : (isDark ? Colors.white12 : Colors.grey.shade300),
                      width: isSelected ? 2.5 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Radio<int>(
                        value: index,
                        groupValue: _selectedPlanIndex,
                        activeColor: deepAmber,
                        onChanged: (v) => setState(() => _selectedPlanIndex = v!),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  plan['name'],
                                  style: GoogleFonts.hindSiliguri(fontSize: 15, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: (plan['color'] as Color).withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    plan['tag'],
                                    style: GoogleFonts.hindSiliguri(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: plan['color'],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              plan['subtitle'],
                              style: GoogleFonts.hindSiliguri(fontSize: 12, color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '৳${plan['price'].toInt()}',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: deepAmber,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),

            const SizedBox(height: 16),
            // Primary SSLCommerz Payment Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _isProcessingSsl
                    ? null
                    : () => _handleSslCommerzPayment(context, _plans[_selectedPlanIndex]),
                icon: _isProcessingSsl
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Icon(Icons.flash_on, color: Colors.amberAccent),
                label: Text(
                  _isProcessingSsl
                      ? 'এসএসএল গেটওয়ে লোড হচ্ছে...'
                      : 'SSLCommerz দিয়ে তাৎক্ষণিক আনলক (৳${_plans[_selectedPlanIndex]['price'].toInt()}) 🚀',
                  style: GoogleFonts.hindSiliguri(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1B5E20), // Premium Forest Green
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 4,
                ),
              ),
            ),
            const SizedBox(height: 28),
            Text('ভিআইপি প্রিমিয়াম সুবিধাসমূহ', style: GoogleFonts.hindSiliguri(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            // Features Grid / List
            ..._premiumFeatures.map((f) {
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: isDark ? Colors.white12 : Colors.grey.shade200),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(f['icon'] as IconData, color: deepAmber, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(f['title'] as String, style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, fontSize: 14)),
                          Text(f['desc'] as String, style: GoogleFonts.hindSiliguri(fontSize: 12, color: Colors.grey.shade600)),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
