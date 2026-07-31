import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FishMarketPriceScreen extends StatelessWidget {
  const FishMarketPriceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color purpleColor = Color(0xFF9C27B0);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(
          'বাজার দর',
          style: GoogleFonts.hindSiliguri(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: purpleColor,
        elevation: 0,
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildPriceCard('রুই', '২৫০ - ৩০০ ৳/কেজি', purpleColor),
          _buildPriceCard('কাতলা', '৩০০ - ৩৫০ ৳/কেজি', purpleColor),
          _buildPriceCard('তেলাপিয়া', '১৫০ - ১৮০ ৳/কেজি', purpleColor),
        ],
      ),
    );
  }

  Widget _buildPriceCard(String fish, String price, Color color) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Icon(Icons.show_chart, color: color, size: 30),
        title: Text(fish, style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, fontSize: 18)),
        trailing: Text(price, style: GoogleFonts.hindSiliguri(color: Colors.grey.shade700, fontSize: 16)),
      ),
    );
  }
}
