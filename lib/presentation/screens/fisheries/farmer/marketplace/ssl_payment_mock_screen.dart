import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';

class SSLPaymentMockScreen extends StatefulWidget {
  final double totalAmount;
  final String productName;

  const SSLPaymentMockScreen({
    super.key,
    required this.totalAmount,
    required this.productName,
  });

  @override
  State<SSLPaymentMockScreen> createState() => _SSLPaymentMockScreenState();
}

class _SSLPaymentMockScreenState extends State<SSLPaymentMockScreen> {
  bool _isProcessing = true;
  bool _isSuccess = false;

  @override
  void initState() {
    super.initState();
    _processPayment();
  }

  void _processPayment() async {
    // Simulate SSL Commerz processing delay
    await Future.delayed(const Duration(seconds: 3));
    if (mounted) {
      setState(() {
        _isProcessing = false;
        _isSuccess = true;
      });
      _returnToApp();
    }
  }

  void _returnToApp() async {
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      // Pop checkout and SSL screen, return to marketplace
      Get.until((route) => route.isFirst);
      Get.snackbar(
        'অর্ডার সফল',
        '${widget.productName} এর অর্ডার সফলভাবে সম্পন্ন হয়েছে!',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('SSL COMMERZ', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
        backgroundColor: Colors.blue.shade900,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false, // Prevent back during payment
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isProcessing) ...[
              const CircularProgressIndicator(),
              const SizedBox(height: 24),
              Text(
                'পেমেন্ট প্রসেস করা হচ্ছে...',
                style: GoogleFonts.hindSiliguri(fontSize: 18, color: Colors.grey.shade800),
              ),
              const SizedBox(height: 8),
              Text(
                'দয়া করে অপেক্ষা করুন, পেজটি বন্ধ করবেন না',
                style: GoogleFonts.hindSiliguri(fontSize: 14, color: Colors.red),
              ),
            ] else if (_isSuccess) ...[
              const Icon(Icons.check_circle, color: Colors.green, size: 100),
              const SizedBox(height: 24),
              Text(
                'পেমেন্ট সফল!',
                style: GoogleFonts.hindSiliguri(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green),
              ),
              const SizedBox(height: 8),
              Text(
                '৳${widget.totalAmount.toStringAsFixed(0)} প্রদান করা হয়েছে।',
                style: GoogleFonts.poppins(fontSize: 18, color: Colors.black87),
              ),
              const SizedBox(height: 20),
              Text(
                'আপনাকে অ্যাপে ফিরিয়ে নেয়া হচ্ছে...',
                style: GoogleFonts.hindSiliguri(fontSize: 14, color: Colors.grey.shade600),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
