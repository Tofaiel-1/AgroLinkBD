import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';

class DriverTripMeterScreen extends StatefulWidget {
  final String? tripId;
  final String? customerName;
  final String? customerPhone;
  final String? pickupAddress;
  final String? dropoffAddress;
  final double? estimatedFare;

  const DriverTripMeterScreen({
    super.key,
    this.tripId = 'AGRO-TRIP-8842',
    this.customerName = 'মোঃ রফিকুল ইসলাম (খামারি)',
    this.customerPhone = '01711998877',
    this.pickupAddress = 'গুরুদাসপুর, নাটোর',
    this.dropoffAddress = 'কাওরান বাজার পাইকারি মার্কেট, ঢাকা',
    this.estimatedFare = 8500.0,
  });

  @override
  State<DriverTripMeterScreen> createState() => _DriverTripMeterScreenState();
}

class _DriverTripMeterScreenState extends State<DriverTripMeterScreen> {
  bool _isTripStarted = false;
  bool _isTripCompleted = false;
  double _distanceCoveredKm = 0.0;
  int _tripSeconds = 0;
  int _currentSpeed = 0;
  Timer? _tripTimer;
  final _otpController = TextEditingController();

  @override
  void dispose() {
    _tripTimer?.cancel();
    _otpController.dispose();
    super.dispose();
  }

  void _startTripWithOtp() {
    if (_otpController.text.trim() != '1234' && _otpController.text.trim().length != 4) {
      Get.snackbar('সঠিক ওটিপি দিন', 'পণ্য তোলার সময় খামারির দেওয়া ৪ ডিজিটের ওটিপি প্রবেশ করান (যেমন: 1234)', backgroundColor: Colors.red.shade700, colorText: Colors.white);
      return;
    }

    setState(() {
      _isTripStarted = true;
    });

    Get.snackbar('ট্রিপ শুরু হয়েছে! 🚛', 'আপনার লাইভ মিটার ও জিপিএস ট্র্যাকিং সক্রিয়। সাবধানে গাড়ি চালান।', backgroundColor: const Color(0xFF2E7D32), colorText: Colors.white);

    _tripTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _tripSeconds++;
          // Simulate realistic speed and distance
          _currentSpeed = 45 + (_tripSeconds % 15);
          _distanceCoveredKm += (_currentSpeed / 3600.0);
        });
      }
    });
  }

  void _completeTrip() {
    _tripTimer?.cancel();
    setState(() {
      _isTripCompleted = true;
      _currentSpeed = 0;
    });

    _showReceiptDialog();
  }

  void _showReceiptDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Color(0xFF2E7D32), size: 54),
            const SizedBox(height: 10),
            Text('ট্রিপ সম্পন্ন হয়েছে! 🎉', style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 6),
            Text('পণ্য নিরাপদে গন্তব্যে পৌঁছেছে', style: GoogleFonts.hindSiliguri(fontSize: 12, color: Colors.grey.shade600)),
            const Divider(height: 24),
            _buildReceiptRow('মোট ট্রিপ দূরত্ব', '${_distanceCoveredKm.toStringAsFixed(1)} কিমি'),
            _buildReceiptRow('মোট সময়', '${(_tripSeconds ~/ 60)} মিনিট ${_tripSeconds % 60} সেকেন্ড'),
            _buildReceiptRow('ভাড়া পাওনা', '৳${widget.estimatedFare?.toInt()}', isBold: true),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  Get.back();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF57C00),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text('ভাড়া সংগ্রহ সম্পন্ন হয়েছে', style: GoogleFonts.hindSiliguri(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReceiptRow(String title, String val, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: GoogleFonts.hindSiliguri(fontSize: 13, color: Colors.black87)),
          Text(val, style: GoogleFonts.poppins(fontSize: 13, fontWeight: isBold ? FontWeight.bold : FontWeight.w600, color: isBold ? const Color(0xFFF57C00) : Colors.black87)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryOrange = Color(0xFFF57C00);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF4F6F8),
      appBar: AppBar(
        title: Text(
          'লাইভ ট্রিপ মিটার ও নেভিগেশন 🧭',
          style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16),
        ),
        backgroundColor: primaryOrange,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Live Speed & Distance Meter Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF212121), Color(0xFF37474F)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _isTripStarted && !_isTripCompleted ? Colors.greenAccent : Colors.grey,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _isTripStarted ? (_isTripCompleted ? 'ট্রিপ সম্পন্ন' : 'ট্রিপ রানিং...') : 'পণ্য তোলার অপেক্ষায়',
                            style: GoogleFonts.hindSiliguri(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      Text(widget.tripId!, style: GoogleFonts.poppins(color: Colors.amberAccent, fontWeight: FontWeight.bold, fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Speedometer Circle Display
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        children: [
                          Text('গতি (Speed)', style: GoogleFonts.hindSiliguri(color: Colors.white60, fontSize: 11)),
                          const SizedBox(height: 4),
                          Text('$_currentSpeed', style: GoogleFonts.poppins(fontSize: 42, fontWeight: FontWeight.bold, color: Colors.greenAccent)),
                          Text('কিমি/ঘণ্টা', style: GoogleFonts.hindSiliguri(color: Colors.white70, fontSize: 11)),
                        ],
                      ),
                      Container(height: 70, width: 1, color: Colors.white24),
                      Column(
                        children: [
                          Text('অতিক্রান্ত দূরত্ব', style: GoogleFonts.hindSiliguri(color: Colors.white60, fontSize: 11)),
                          const SizedBox(height: 4),
                          Text(_distanceCoveredKm.toStringAsFixed(1), style: GoogleFonts.poppins(fontSize: 42, fontWeight: FontWeight.bold, color: Colors.white)),
                          Text('কিলোমিটার', style: GoogleFonts.hindSiliguri(color: Colors.white70, fontSize: 11)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Running Time
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white10,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.timer, color: Colors.orangeAccent, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'সময়: ${(_tripSeconds ~/ 3600).toString().padLeft(2, '0')}:${((_tripSeconds % 3600) ~/ 60).toString().padLeft(2, '0')}:${(_tripSeconds % 60).toString().padLeft(2, '0')}',
                          style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Route Card
            Card(
              color: Theme.of(context).cardColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('ট্রিপ লোকেশন বিবরণ', style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.trip_origin, color: Colors.green, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('পিকআপ (লোড পয়েন্ট)', style: GoogleFonts.hindSiliguri(fontSize: 11, color: Colors.grey.shade600)),
                              Text(widget.pickupAddress!, style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, fontSize: 13)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 9),
                      child: Container(height: 16, width: 2, color: Colors.grey.shade300),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.location_on, color: Colors.red, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('গন্তব্য (আনলোড পয়েন্ট)', style: GoogleFonts.hindSiliguri(fontSize: 11, color: Colors.grey.shade600)),
                              Text(widget.dropoffAddress!, style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, fontSize: 13)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),

                    // Customer info
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(widget.customerName!, style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, fontSize: 14)),
                            Text('ভাড়া চুক্তি: ৳${widget.estimatedFare?.toInt()}', style: GoogleFonts.hindSiliguri(fontSize: 12, color: primaryOrange, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        ElevatedButton.icon(
                          onPressed: () {
                            Get.snackbar('কল করা হচ্ছে 📞', '${widget.customerName}: ${widget.customerPhone}', backgroundColor: primaryOrange, colorText: Colors.white);
                          },
                          icon: const Icon(Icons.phone, size: 16, color: Colors.white),
                          label: Text('কল দিন', style: GoogleFonts.hindSiliguri(color: Colors.white, fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E7D32)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // OTP or Trip Complete Action
            if (!_isTripStarted) ...[
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
                          const Icon(Icons.pin, color: primaryOrange, size: 22),
                          const SizedBox(width: 8),
                          Text('ট্রিপ শুরুর ওটিপি (OTP)', style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, fontSize: 15)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text('মাল গাড়িতে তোলার পর খামারির কাছ থেকে ৪ সংখ্যার কোড নিয়ে প্রবেশ করান।', style: GoogleFonts.hindSiliguri(fontSize: 12, color: Colors.grey.shade600)),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _otpController,
                        keyboardType: TextInputType.number,
                        maxLength: 4,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 8),
                        decoration: InputDecoration(
                          hintText: '----',
                          counterText: '',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _startTripWithOtp,
                          icon: const Icon(Icons.play_arrow, color: Colors.white),
                          label: Text('ট্রিপ স্টার্ট করুন', style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 15)),
                          style: ElevatedButton.styleFrom(backgroundColor: primaryOrange, padding: const EdgeInsets.symmetric(vertical: 12)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ] else if (!_isTripCompleted) ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _completeTrip,
                  icon: const Icon(Icons.check_circle, color: Colors.white),
                  label: Text('গন্তব্যে পৌঁছানো সম্পন্ন হয়েছে (End Trip)', style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 15)),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E7D32), padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
