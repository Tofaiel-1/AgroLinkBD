import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ExpertAdviceScreen extends StatelessWidget {
  const ExpertAdviceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color indigoColor = Color(0xFF3949AB);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(
          'বিশেষজ্ঞ পরামর্শ',
          style: GoogleFonts.hindSiliguri(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: indigoColor,
        elevation: 0,
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildExpertCard('ড. মৎস্য বিজ্ঞানী', 'মৎস্য বিশেষজ্ঞ, ঢাবি', 'ভিডিও কল', indigoColor),
          _buildExpertCard('মোঃ কামাল হোসেন', 'উপজেলা মৎস্য কর্মকর্তা', 'চ্যাট', indigoColor),
        ],
      ),
    );
  }

  Widget _buildExpertCard(String name, String title, String action, Color color) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          radius: 30,
          backgroundColor: color.withOpacity(0.1),
          child: Icon(Icons.person, color: color, size: 30),
        ),
        title: Text(name, style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, fontSize: 18)),
        subtitle: Text(title, style: GoogleFonts.hindSiliguri(color: Colors.grey.shade600)),
        trailing: ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(backgroundColor: color, foregroundColor: Colors.white),
          child: Text(action, style: GoogleFonts.hindSiliguri()),
        ),
      ),
    );
  }
}
