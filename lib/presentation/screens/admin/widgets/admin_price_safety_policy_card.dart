import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminPriceSafetyPolicyCard extends StatefulWidget {
  const AdminPriceSafetyPolicyCard({super.key});

  @override
  State<AdminPriceSafetyPolicyCard> createState() =>
      _AdminPriceSafetyPolicyCardState();
}

class _AdminPriceSafetyPolicyCardState
    extends State<AdminPriceSafetyPolicyCard> {
  final TextEditingController _testPriceController = TextEditingController(text: '80');
  double _testDelta = 10.0;
  bool _isDecrease = true;

  @override
  void dispose() {
    _testPriceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textPrimary = isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A);
    final textSecondary = isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569);
    final borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);

    final testOriginal = double.tryParse(_testPriceController.text) ?? 80.0;
    final testFactor = _testDelta / 100.0;
    double calculated = _isDecrease
        ? testOriginal * (1.0 - testFactor)
        : testOriginal * (1.0 + testFactor);
    if (calculated < 5.0) calculated = 5.0; // Floor guard

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── Header Info Card ─────────────────────────────────
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [const Color(0xFF1E3A5F), const Color(0xFF0F172A)]
                    : [const Color(0xFF0D47A1), const Color(0xFF1976D2)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0D47A1).withValues(alpha: 0.25),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.shield_rounded, color: Colors.amberAccent, size: 22),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '🛡️ মার্কেট সেফটি গার্ড ও সার্কিট ব্রেকার',
                            style: GoogleFonts.hindSiliguri(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'বাজারের স্থিতিশীলতা ও কৃষক সুরক্ষায় স্বয়ংক্রিয় প্রতিরক্ষা ব্যবস্থা',
                            style: GoogleFonts.hindSiliguri(
                              fontSize: 11.5,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildSummaryStat('সর্বোচ্চ পরিবর্তন', '±২৫% সীমা', Colors.amberAccent),
                      Container(height: 28, width: 1, color: Colors.white24),
                      _buildSummaryStat('কৃষি ফ্লোর রেট', 'ন্যূনতম ৳৫/কেজি', Colors.lightGreenAccent),
                      Container(height: 28, width: 1, color: Colors.white24),
                      _buildSummaryStat('মৎস্য ফ্লোর রেট', 'ন্যূনতম ৳৪০/কেজি', Colors.cyanAccent),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ─── Policy Rules List ────────────────────────────────
          Text(
            'সক্রিয় পলিসি ও নিরাপত্তা বিধিসমূহ',
            style: GoogleFonts.hindSiliguri(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: textPrimary,
            ),
          ),
          const SizedBox(height: 10),

          _buildPolicyTile(
            icon: Icons.speed_rounded,
            color: const Color(0xFFEF4444),
            title: 'সার্কিট ব্রেকার সীমা (Circuit Breaker)',
            subtitle: 'কোনো কমান্ডে ২৫% এর বেশি মূল্য পরিবর্তন করতে গেলে অ্যাডমিনকে নিশ্চিতকরণ টগল সক্রিয় করতে হবে।',
            cardBg: cardBg,
            textPrimary: textPrimary,
            textSecondary: textSecondary,
            borderColor: borderColor,
          ),
          _buildPolicyTile(
            icon: Icons.grass_rounded,
            color: const Color(0xFF10B981),
            title: 'কৃষি উৎপাদন ফ্লোর প্রাইস (Agri Minimum Floor)',
            subtitle: 'বাজার ধসের কমান্ড প্রয়োগ করলেও কোনো কৃষিজাত ফসলের দাম কেজি প্রতি ৫ টাকার নিচে নামবে না।',
            cardBg: cardBg,
            textPrimary: textPrimary,
            textSecondary: textSecondary,
            borderColor: borderColor,
          ),
          _buildPolicyTile(
            icon: Icons.water_rounded,
            color: const Color(0xFF0284C7),
            title: 'মৎস্য চাষী সুরক্ষা ফ্লোর (Fish Minimum Floor)',
            subtitle: 'জীবন্ত মাছের জন্য কেজি প্রতি ন্যূনতম ৪০ টাকা ফ্লোর নিশ্চিত করা হয়েছে যাতে মৎস্য চাষীর মূলধন রক্ষা পায়।',
            cardBg: cardBg,
            textPrimary: textPrimary,
            textSecondary: textSecondary,
            borderColor: borderColor,
          ),
          _buildPolicyTile(
            icon: Icons.notifications_active_rounded,
            color: const Color(0xFFF59E0B),
            title: 'কৃষক সতর্কতা ব্রডকাস্ট (Farmer Notification)',
            subtitle: 'যেকোনো কমান্ড এক্সিকিউট হওয়ার পর সংশ্লিষ্ট কৃষকদের ইন-অ্যাপ নোটিফিকেশনে কারণসহ লাইভ আপডেট পৌঁছে যায়।',
            cardBg: cardBg,
            textPrimary: textPrimary,
            textSecondary: textSecondary,
            borderColor: borderColor,
          ),
          const SizedBox(height: 24),

          // ─── Interactive Sandbox Simulator ────────────────────
          Text(
            '🧪 লাইভ প্রাইস সিমুলেশন টেস্ট স্যান্ডবক্স',
            style: GoogleFonts.hindSiliguri(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'পরীক্ষামূলক দর ইনপুট দিয়ে পরিবর্তনের প্রভাব দেখুন:',
                  style: GoogleFonts.hindSiliguri(
                    fontSize: 12.5,
                    color: textSecondary,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: TextField(
                        controller: _testPriceController,
                        keyboardType: TextInputType.number,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          color: textPrimary,
                        ),
                        decoration: InputDecoration(
                          labelText: 'বর্তমান দর (টাকা)',
                          labelStyle: GoogleFonts.hindSiliguri(fontSize: 12, color: textSecondary),
                          prefixText: '৳ ',
                          prefixStyle: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: const Color(0xFF0D47A1)),
                          filled: true,
                          fillColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 2,
                      child: DropdownButtonFormField<bool>(
                        initialValue: _isDecrease,
                        dropdownColor: cardBg,
                        decoration: InputDecoration(
                          labelText: 'অ্যাকশন',
                          labelStyle: GoogleFonts.hindSiliguri(fontSize: 12, color: textSecondary),
                          filled: true,
                          fillColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        ),
                        items: [
                          DropdownMenuItem(
                            value: true,
                            child: Text('হ্রাস (-)', style: GoogleFonts.hindSiliguri(color: const Color(0xFFEF4444), fontWeight: FontWeight.bold)),
                          ),
                          DropdownMenuItem(
                            value: false,
                            child: Text('বৃদ্ধি (+)', style: GoogleFonts.hindSiliguri(color: const Color(0xFF10B981), fontWeight: FontWeight.bold)),
                          ),
                        ],
                        onChanged: (v) {
                          if (v != null) setState(() => _isDecrease = v);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Percentage Slider
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'পরিবর্তনের শতকরা হার: ${_testDelta.toStringAsFixed(0)}%',
                      style: GoogleFonts.hindSiliguri(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: textPrimary,
                      ),
                    ),
                    if (_testDelta > 25)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.amber.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.amber),
                        ),
                        child: Text(
                          '⚠️ সার্কিট ব্রেকার অ্যালার্ট',
                          style: GoogleFonts.hindSiliguri(
                            fontSize: 10.5,
                            fontWeight: FontWeight.bold,
                            color: Colors.amber.shade800,
                          ),
                        ),
                      ),
                  ],
                ),
                Slider(
                  value: _testDelta,
                  min: 5,
                  max: 40,
                  divisions: 7,
                  activeColor: _testDelta > 25 ? const Color(0xFFEF4444) : const Color(0xFF0D47A1),
                  label: '${_testDelta.toStringAsFixed(0)}%',
                  onChanged: (v) => setState(() => _testDelta = v),
                ),

                // Calculation Result
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: borderColor),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'সমন্বিত চূড়ান্ত দর:',
                            style: GoogleFonts.hindSiliguri(fontSize: 11, color: textSecondary),
                          ),
                          Text(
                            '৳${calculated.toStringAsFixed(0)} / কেজি',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: _isDecrease ? const Color(0xFFEF4444) : const Color(0xFF10B981),
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'নিট ব্যবধান:',
                            style: GoogleFonts.hindSiliguri(fontSize: 11, color: textSecondary),
                          ),
                          Text(
                            '${_isDecrease ? "-" : "+"}৳${(calculated - testOriginal).abs().toStringAsFixed(0)} (${_testDelta.toStringAsFixed(0)}%)',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: textPrimary,
                            ),
                          ),
                        ],
                      ),
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

  Widget _buildSummaryStat(String title, String value, Color valueColor) {
    return Column(
      children: [
        Text(
          title,
          style: GoogleFonts.hindSiliguri(
            fontSize: 10.5,
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: GoogleFonts.hindSiliguri(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  Widget _buildPolicyTile({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required Color cardBg,
    required Color textPrimary,
    required Color textSecondary,
    required Color borderColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.hindSiliguri(
                    fontSize: 13.5,
                    fontWeight: FontWeight.bold,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.hindSiliguri(
                    fontSize: 11.5,
                    color: textSecondary,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
