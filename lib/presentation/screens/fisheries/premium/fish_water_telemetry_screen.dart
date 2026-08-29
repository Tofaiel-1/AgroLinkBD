import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:agrolinkbd/presentation/widgets/premium_feature_gatekeeper.dart';

class FishWaterTelemetryScreen extends StatefulWidget {
  const FishWaterTelemetryScreen({super.key});

  @override
  State<FishWaterTelemetryScreen> createState() => _FishWaterTelemetryScreenState();
}

class _FishWaterTelemetryScreenState extends State<FishWaterTelemetryScreen> {
  double _ph = 7.6;
  double _dissolvedOxygen = 5.8; // mg/L
  double _ammonia = 0.03; // mg/L
  double _temperature = 28.5; // °C
  double _alkalinity = 120.0; // ppm

  String _selectedPond = 'পুকুর-১ (কার্প নার্সারি - ৪০ শতক)';

  @override
  Widget build(BuildContext context) {
    const Color oceanCyan = Color(0xFF006064);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final isDoSafe = _dissolvedOxygen >= 5.0;
    final isPhSafe = _ph >= 6.8 && _ph <= 8.4;
    final isAmmoniaSafe = _ammonia <= 0.05;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF4F7F9),
      appBar: AppBar(
        title: Text(
          'ওয়াটার কোয়ালিটি ও অক্সিজেন রাডার 🌊',
          style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16),
        ),
        backgroundColor: oceanCyan,
        elevation: 0,
        centerTitle: true,
      ),
      body: PremiumFeatureGatekeeper(
        featureName: 'এআই ওয়াটার কোয়ালিটি ও আর্লি অক্সিজেন অ্যালার্ম',
        description: 'পুকুরের লাইভ দ্রবীভূত অক্সিজেন, পিএইচ ও অ্যামোনিয়া পর্যবেক্ষণ এবং ভোর ৩টা-৬টায় অক্সিজেন ড্রপ পূর্বাভাস পান।',
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Pond Selector
              Card(
                color: Theme.of(context).cardColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: _selectedPond,
                      items: [
                        'পুকুর-১ (কার্প নার্সারি - ৪০ শতক)',
                        'পুকুর-২ (পাবদা ও গুলশা প্রজেক্ট - ৬০ শতক)',
                        'পুকুর-৩ (তেলাপিয়া গ্রো-আউট - ১০০ শতক)',
                      ].map((p) => DropdownMenuItem(value: p, child: Text(p, style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, fontSize: 14)))).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedPond = val);
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Hero DO Status Card
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDoSafe
                        ? [const Color(0xFF006064), const Color(0xFF00838F), const Color(0xFF0097A7)]
                        : [const Color(0xFFB71C1C), const Color(0xFFC62828), const Color(0xFFD32F2F)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: (isDoSafe ? Colors.teal : Colors.red).withOpacity(0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.water_drop, color: Colors.cyanAccent, size: 24),
                            const SizedBox(width: 8),
                            Text('দ্রবীভূত অক্সিজেন (Dissolved Oxygen)', style: GoogleFonts.hindSiliguri(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.white24,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(isDoSafe ? 'অনুকূল মাত্রা ✓' : 'সতর্কতা ⚠️', style: GoogleFonts.hindSiliguri(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('$_dissolvedOxygen', style: GoogleFonts.poppins(fontSize: 42, fontWeight: FontWeight.bold, color: Colors.white)),
                        const SizedBox(width: 6),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text('mg/L (পিপিএম)', style: GoogleFonts.hindSiliguri(color: Colors.white70, fontSize: 14)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      isDoSafe
                          ? 'মাছের শ্বাস-প্রশ্বাস ও খাদ্য গ্রহণ স্বাভাবিক রয়েছে। ভোর ৫:০০ টায় সামান্য কমতে পারে।'
                          : 'অক্সিজেন সংকট! এখনই এয়ারেটর চালু করুন অথবা অক্সি-ম্যাক্স / সোডিয়াম পার-কার্বনেট ছিটান।',
                      style: GoogleFonts.hindSiliguri(color: Colors.white.withOpacity(0.9), fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Multi-Parameter Metric Grid
              Text('পানির রাসায়নিক মানদণ্ড (Water Quality Matrix)', style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, fontSize: 15)),
              const SizedBox(height: 10),

              Row(
                children: [
                  Expanded(child: _buildParameterCard('পিএইচ (pH)', '$_ph', isPhSafe ? 'স্বাভাবিক (৭.৫-৮.৫)' : 'চুন প্রয়োজন', isPhSafe ? Colors.green : Colors.red, isDark)),
                  const SizedBox(width: 10),
                  Expanded(child: _buildParameterCard('অ্যামোনিয়া (NH3)', '$_ammonia mg/L', isAmmoniaSafe ? 'নিরাপদ (<০.০৫)' : 'টক্সিক গ্যাস!', isAmmoniaSafe ? Colors.green : Colors.red, isDark)),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: _buildParameterCard('তাপমাত্রা', '$_temperature °C', 'অনুকূল গ্রোথ', Colors.teal, isDark)),
                  const SizedBox(width: 10),
                  Expanded(child: _buildParameterCard('ক্ষারত্ব (Alkalinity)', '$_alkalinity ppm', 'ফার্টিলিটি ভালো', Colors.blue, isDark)),
                ],
              ),
              const SizedBox(height: 20),

              // AI Prescription & Early Morning Safety Action
              Card(
                color: Theme.of(context).cardColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.shield_moon, color: Colors.purple, size: 24),
                          const SizedBox(width: 8),
                          Text('ভোর রাতের অক্সিজেন ড্রপ প্রেডিকশন 🌙', style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, fontSize: 15)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'ফাইটোপ্ল্যাঙ্কটন ও মেঘলা আবহাওয়ার কারণে রাত ৩:৩০ থেকে ভোর ৬:০০ পর্যন্ত পুকুরের তলদেশে অক্সিজেন ০.৮-১.৫ mg/L পর্যন্ত ড্রপ হতে পারে।',
                        style: GoogleFonts.hindSiliguri(fontSize: 12, color: Colors.grey.shade700),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.amber.shade400),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.lightbulb, color: Colors.orange, size: 22),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'পরামর্শ: রাত ১২টা থেকে ভোর ৬টা পর্যন্ত এয়ারেটর স্বয়ংক্রিয় শিডিউলে অন রাখুন।',
                                style: GoogleFonts.hindSiliguri(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.brown.shade900),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Get.snackbar(
                              'স্মার্ট এলার্ট সক্রিয়! 🔔',
                              'ভোর রাতের জরুরি অক্সিজেন ড্রপ অ্যালার্ম এসএমএস আপনার মোবাইলে পাঠানো হবে।',
                              backgroundColor: oceanCyan,
                              colorText: Colors.white,
                            );
                          },
                          icon: const Icon(Icons.alarm_on, color: Colors.white, size: 18),
                          label: Text('জরুরি নাইট অ্যালার্ম অন করুন', style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: oceanCyan,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildParameterCard(String title, String val, String status, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade900 : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: GoogleFonts.hindSiliguri(fontSize: 11, color: Colors.grey.shade600)),
          const SizedBox(height: 4),
          Text(val, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 4),
          Text(status, style: GoogleFonts.hindSiliguri(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }
}
