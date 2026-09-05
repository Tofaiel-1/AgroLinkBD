import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:agrolinkbd/core/providers/language_provider.dart';

/// Service Provider Earnings Screen - View income, analytics and withdrawals
class ServiceProviderEarningsScreen extends StatefulWidget {
  const ServiceProviderEarningsScreen({super.key});

  @override
  State<ServiceProviderEarningsScreen> createState() =>
      _ServiceProviderEarningsScreenState();
}

class _ServiceProviderEarningsScreenState
    extends State<ServiceProviderEarningsScreen> {
  @override
  Widget build(BuildContext context) {
    final isBn = LanguageProvider.isBn(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          isBn ? 'আয় ও বিশ্লেষণ' : 'Earnings & Analytics',
          style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: const Color(0xFF2B32B2),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Get.back();
            }
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Earnings Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF2B32B2),
                    Color(0xFF1488CC),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2B32B2).withValues(alpha: 0.25),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isBn ? 'এই মাসের আয়' : 'This Month\'s Earnings',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.white.withValues(alpha: 0.9),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isBn ? '৳ ১৮,৭৫০' : '৳ 18,750',
                    style: GoogleFonts.poppins(
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Stats
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildStatColumn(isBn ? 'সেবা সংখ্যা' : 'Services', isBn ? '১৫ টি' : '15'),
                      _buildStatColumn(isBn ? 'কাজের ঘণ্টা' : 'Hours', isBn ? '৪২ ঘণ্টা' : '42 hrs'),
                      _buildStatColumn(isBn ? 'রেটিং' : 'Rating', '৪.৯ ★'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),

            // Earning Breakdown
            Text(
              isBn ? 'আয়ের বিবরণ' : 'Earnings Breakdown',
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 12),
            _buildBreakdownItem(isBn ? 'কীটনাশক স্প্রে' : 'Pesticide Spray', isBn ? '৳ ১০,০০০' : '৳ 10,000', const Color(0xFF6A11CB)),
            const SizedBox(height: 8),
            _buildBreakdownItem(isBn ? 'মাটি পরীক্ষা' : 'Soil Testing', isBn ? '৳ ৬,০০০' : '৳ 6,000', const Color(0xFF0288D1)),
            const SizedBox(height: 8),
            _buildBreakdownItem(isBn ? 'পরামর্শ সেবা' : 'Consultancy', isBn ? '৳ ২,৭৫০' : '৳ 2,750', const Color(0xFF00796B)),
            const SizedBox(height: 22),

            // Weekly Breakdown
            Text(
              isBn ? 'সাপ্তাহিক আয় চিত্র' : 'Weekly Revenue Trend',
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 12),
            _buildWeeklyChart(isBn),
            const SizedBox(height: 24),

            // Withdraw Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2B32B2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 2,
                ),
                onPressed: () {
                  Get.snackbar(
                    isBn ? 'উত্তোলন' : 'Withdraw',
                    isBn ? 'উত্তোলন প্রক্রিয়া সফলভাবে শুরু হয়েছে!' : 'Withdrawal request submitted successfully!',
                    backgroundColor: Colors.white,
                    colorText: Colors.black87,
                  );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.account_balance_rounded, color: Colors.white, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      isBn ? 'টাকা উত্তোলন করুন' : 'Withdraw Funds',
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 11,
            color: Colors.white.withValues(alpha: 0.85),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildBreakdownItem(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 10),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 13.5,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyChart(bool isBn) {
    final days = isBn
        ? ['সোম', 'মঙ্গল', 'বুধ', 'বৃহস্প', 'শুক্র', 'শনি', 'রবি']
        : ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final earnings = [2000, 2500, 2200, 2800, 2400, 3000, 3250];

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: List.generate(
          days.length,
          (index) => Padding(
            padding: EdgeInsets.only(bottom: index < days.length - 1 ? 10 : 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: 36,
                  child: Text(
                    days[index],
                    style: GoogleFonts.poppins(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    height: 14,
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: FractionallySizedBox(
                      widthFactor: earnings[index] / 3500,
                      alignment: Alignment.centerLeft,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF2B32B2), Color(0xFF1488CC)],
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ),
                Text(
                  '৳${earnings[index]}',
                  style: GoogleFonts.poppins(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF2B32B2),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
