import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FishOrdersTab extends StatelessWidget {
  const FishOrdersTab({super.key});

  @override
  Widget build(BuildContext context) {
    const Color orangeColor = Color(0xFFF57C00);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(
          'অর্ডারসমূহ',
          style: GoogleFonts.hindSiliguri(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: orangeColor,
        elevation: 0,
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.list_alt, size: 100, color: orangeColor.withOpacity(0.5)),
            const SizedBox(height: 20),
            Text(
              'আপনার সমস্ত ক্রয় ও বিক্রয় অর্ডার',
              style: GoogleFonts.hindSiliguri(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
