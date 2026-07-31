import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';

class WaterTestingScreen extends StatelessWidget {
  const WaterTestingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color cyanColor = Color(0xFF00ACC1);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(
          'পানি পরীক্ষা',
          style: GoogleFonts.hindSiliguri(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: cyanColor,
        elevation: 0,
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.science, size: 100, color: cyanColor.withOpacity(0.5)),
              const SizedBox(height: 20),
              Text(
                'বিশেষজ্ঞ দ্বারা পানি পরীক্ষা করান',
                style: GoogleFonts.hindSiliguri(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'আমাদের সার্টিফাইড সার্ভিস প্রোভাইডার আপনার খামারে গিয়ে পানির সকল প্যারামিটার পরীক্ষা করে রিপোর্ট প্রদান করবে।',
                style: GoogleFonts.hindSiliguri(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                onPressed: () {
                  Get.snackbar(
                    'বুকিং সম্পন্ন',
                    'আপনার রিকোয়েস্ট গ্রহণ করা হয়েছে। শীঘ্রই একজন প্রতিনিধি যোগাযোগ করবেন।',
                    backgroundColor: Colors.white,
                    colorText: cyanColor,
                  );
                },
                icon: const Icon(Icons.calendar_month),
                label: Text(
                  'টেস্টিং সার্ভিস বুক করুন',
                  style: GoogleFonts.hindSiliguri(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: cyanColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
