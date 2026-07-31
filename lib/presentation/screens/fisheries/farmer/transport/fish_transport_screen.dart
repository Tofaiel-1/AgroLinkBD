import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FishTransportScreen extends StatelessWidget {
  const FishTransportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color deepAqua = Color(0xFF006064);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(
          'পরিবহন',
          style: GoogleFonts.hindSiliguri(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: deepAqua,
        elevation: 0,
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.local_shipping, size: 100, color: deepAqua.withOpacity(0.5)),
            const SizedBox(height: 20),
            Text(
              'পরিবহন সার্ভিস খুঁজুন',
              style: GoogleFonts.hindSiliguri(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
