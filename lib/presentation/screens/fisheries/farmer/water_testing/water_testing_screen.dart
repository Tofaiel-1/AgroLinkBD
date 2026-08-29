import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';

class WaterTestingScreen extends StatefulWidget {
  const WaterTestingScreen({super.key});

  @override
  State<WaterTestingScreen> createState() => _WaterTestingScreenState();
}

class _WaterTestingScreenState extends State<WaterTestingScreen> {
  double _ph = 7.4;
  double _ammonia = 0.05; // ppm
  double _dissolvedOxygen = 6.2; // ppm
  double _temperature = 28.5; // °C
  double _alkalinity = 120.0; // ppm

  final _pondNameController = TextEditingController(text: 'পুকুর-১ (প্রধান দিঘি)');
  final _phoneController = TextEditingController(text: '01711223344');
  final _addressController = TextEditingController(text: 'সিংড়া, নাটোর');

  String _getPhStatus() {
    if (_ph >= 7.2 && _ph <= 8.5) return 'আদর্শ (Ideal)';
    if (_ph < 6.5) return 'অতিরিক্ত অম্লীয় (চুন প্রয়োগ প্রয়োজন)';
    if (_ph > 9.0) return 'অতিরিক্ত ক্ষারীয় (পানি পরিবর্তন প্রয়োজন)';
    return 'স্বাভাবিক';
  }

  String _getAmmoniaStatus() {
    if (_ammonia <= 0.1) return 'নিরাপদ (Safe)';
    if (_ammonia <= 0.5) return 'মাঝারি (সতর্কতা)';
    return 'বিপজ্জনক (জরুরি জিওলাইট দিন)';
  }

  String _getDoStatus() {
    if (_dissolvedOxygen >= 5.0) return 'চমৎকার (Healthy)';
    if (_dissolvedOxygen >= 3.0) return 'মাঝারি (অক্সিজেন ড্রপ করছে)';
    return 'মারাত্মক (অবিলম্বে অ্যারেটর চালান)';
  }

  @override
  void dispose() {
    _pondNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _bookLabTest() {
    Get.defaultDialog(
      title: 'ল্যাব টেস্ট বুকিং নিশ্চিত 🎉',
      titleStyle: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, color: const Color(0xFF00ACC1)),
      content: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            const Icon(Icons.verified, color: Colors.green, size: 50),
            const SizedBox(height: 10),
            Text(
              'আপনার খামারে পানি পরীক্ষার জন্য প্রতিনিধি নিয়োগ করা হয়েছে।',
              textAlign: TextAlign.center,
              style: GoogleFonts.hindSiliguri(fontSize: 14),
            ),
            const SizedBox(height: 6),
            Text(
              'টেকনিশিয়ান: ড. মৎস্য ল্যাব টিম\nফি: ৳৩৫০ (রিপোর্ট সহ)',
              textAlign: TextAlign.center,
              style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey.shade700),
            ),
          ],
        ),
      ),
      confirm: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00ACC1)),
        onPressed: () => Get.back(),
        child: Text('ধন্যবাদ', style: GoogleFonts.hindSiliguri(color: Colors.white)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color cyanColor = Color(0xFF00ACC1);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(
          'পুকুরের পানির স্মার্ট ল্যাব ও টেস্টিং',
          style: GoogleFonts.hindSiliguri(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: cyanColor,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Instant Status Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF00ACC1), Color(0xFF00838F)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'পুকুরের বর্তমান স্বাস্থ্য সূচক',
                        style: GoogleFonts.hindSiliguri(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(8)),
                        child: Text('লাইভ ইনডেক্স', style: GoogleFonts.hindSiliguri(color: Colors.white, fontSize: 11)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildHeaderParam('pH মান', '$_ph', _ph >= 7.0 && _ph <= 8.5 ? Colors.white : Colors.amberAccent),
                      _buildHeaderParam('অ্যামোনিয়া', '$_ammonia ppm', _ammonia <= 0.1 ? Colors.white : Colors.redAccent),
                      _buildHeaderParam('দ্রবীভূত O₂', '$_dissolvedOxygen ppm', _dissolvedOxygen >= 5.0 ? Colors.white : Colors.redAccent),
                      _buildHeaderParam('তাপমাত্রা', '$_temperature°C', Colors.white),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
            Text(
              'প্যারামিটার পরীক্ষা ও তাৎক্ষণিক পরামর্শ',
              style: GoogleFonts.hindSiliguri(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            _buildSliderParamCard(
              title: 'পানির pH লেভেল',
              value: _ph,
              min: 5.0,
              max: 11.0,
              unit: '',
              status: _getPhStatus(),
              color: cyanColor,
              onChanged: (v) => setState(() => _ph = double.parse(v.toStringAsFixed(1))),
            ),
            const SizedBox(height: 12),

            _buildSliderParamCard(
              title: 'বিষাক্ত অ্যামোনিয়া (NH3)',
              value: _ammonia,
              min: 0.0,
              max: 2.0,
              unit: ' ppm',
              status: _getAmmoniaStatus(),
              color: _ammonia > 0.5 ? Colors.red : Colors.green,
              onChanged: (v) => setState(() => _ammonia = double.parse(v.toStringAsFixed(2))),
            ),
            const SizedBox(height: 12),

            _buildSliderParamCard(
              title: 'দ্রবীভূত অক্সিজেন (Dissolved Oxygen)',
              value: _dissolvedOxygen,
              min: 1.0,
              max: 10.0,
              unit: ' ppm',
              status: _getDoStatus(),
              color: _dissolvedOxygen < 4.0 ? Colors.red : Colors.blue,
              onChanged: (v) => setState(() => _dissolvedOxygen = double.parse(v.toStringAsFixed(1))),
            ),
            const SizedBox(height: 12),

            _buildSliderParamCard(
              title: 'ক্ষারত্ব বা অ্যালকালিনিটি (Alkalinity)',
              value: _alkalinity,
              min: 40.0,
              max: 250.0,
              unit: ' ppm',
              status: _alkalinity >= 80.0 && _alkalinity <= 180.0 ? 'আদর্শ (অনুকূল)' : 'চুন বা ডলোমাইট প্রয়োজন',
              color: _alkalinity >= 80.0 && _alkalinity <= 180.0 ? Colors.teal : Colors.orange,
              onChanged: (v) => setState(() => _alkalinity = double.parse(v.toStringAsFixed(0))),
            ),

            const SizedBox(height: 24),
            Text(
              'বিশেষজ্ঞ দ্বারা খামারে পানি পরীক্ষা বুকিং',
              style: GoogleFonts.hindSiliguri(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: cyanColor.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  _buildBookField('পুকুরের নাম', _pondNameController, Icons.pool),
                  const SizedBox(height: 10),
                  _buildBookField('মোবাইল নম্বর', _phoneController, Icons.phone),
                  const SizedBox(height: 10),
                  _buildBookField('ঠিকানা ও অবস্থান', _addressController, Icons.location_on),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: _bookLabTest,
                      icon: const Icon(Icons.science, color: Colors.white),
                      label: Text(
                        'অন-ফিল্ড ল্যাব টেস্ট বুক করুন (৳৩৫০)',
                        style: GoogleFonts.hindSiliguri(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: cyanColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderParam(String label, String value, Color valColor) {
    return Column(
      children: [
        Text(value, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16, color: valColor)),
        Text(label, style: GoogleFonts.hindSiliguri(fontSize: 11, color: Colors.white70)),
      ],
    );
  }

  Widget _buildSliderParamCard({
    required String title,
    required double value,
    required double min,
    required double max,
    required String unit,
    required String status,
    required Color color,
    required ValueChanged<double> onChanged,
  }) {
    return Card(
      color: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, fontSize: 14)),
                Text('$value$unit', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16, color: color)),
              ],
            ),
            Slider(
              value: value.clamp(min, max),
              min: min,
              max: max,
              activeColor: color,
              onChanged: onChanged,
            ),
            Text(
              'অবস্থা: $status',
              style: GoogleFonts.hindSiliguri(fontSize: 12, fontWeight: FontWeight.w600, color: color),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookField(String label, TextEditingController controller, IconData icon) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextField(
      controller: controller,
      style: GoogleFonts.hindSiliguri(fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF00ACC1), size: 18),
        filled: true,
        fillColor: isDark ? Colors.grey.shade900 : Colors.grey.shade50,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: isDark ? Colors.white24 : Colors.grey.shade300),
        ),
      ),
    );
  }
}
