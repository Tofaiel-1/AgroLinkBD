import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:agrolinkbd/core/models/order_model.dart';
import 'package:agrolinkbd/core/services/escrow_service.dart';

class OrderQrDeliveryScreen extends StatefulWidget {
  final OrderModel order;
  final bool isDriverView;

  const OrderQrDeliveryScreen({
    Key? key,
    required this.order,
    this.isDriverView = true,
  }) : super(key: key);

  @override
  State<OrderQrDeliveryScreen> createState() => _OrderQrDeliveryScreenState();
}

class _OrderQrDeliveryScreenState extends State<OrderQrDeliveryScreen> {
  final TextEditingController _otpController = TextEditingController();
  final EscrowService _escrowService = EscrowService();
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _verifyAndRelease() async {
    final otp = _otpController.text.trim();
    if (otp.length != 4) {
      setState(() => _errorMessage = 'দয়া করে ৪-সংখ্যার সঠিক ওটিপি দিন।');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    final result = await _escrowService.releaseEscrowFunds(
      orderId: widget.order.id,
      enteredOtp: otp,
      verifiedByDriverId: widget.order.driverId ?? 'driver_demo',
    );

    setState(() => _isSubmitting = false);

    if (result['success'] == true) {
      _showSuccessDialog(result);
    } else {
      setState(() => _errorMessage = result['message'] ?? 'যাচাই ব্যর্থ হয়েছে।');
    }
  }

  void _showSuccessDialog(Map<String, dynamic> result) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, color: Colors.white, size: 40),
            ),
            const SizedBox(height: 16),
            Text(
              'ডেলিভারি ও পেমেন্ট সম্পন্ন! ✅',
              style: GoogleFonts.hindSiliguri(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'এগ্রোলিংক এস্ক্রো থেকে অর্থ স্বয়ংক্রিয়ভাবে বণ্টন করা হয়েছে:',
              textAlign: TextAlign.center,
              style: GoogleFonts.hindSiliguri(fontSize: 12, color: Colors.grey.shade700),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Column(
                children: [
                  _buildSplitRow('🌾 খামারির ওয়ালেটে জমা:', '৳${(result['farmerPayout'] as num?)?.toStringAsFixed(0) ?? '0'}'),
                  const SizedBox(height: 6),
                  _buildSplitRow('🚚 ড্রাইভার ট্রিপ ভাড়া:', '৳${(result['driverFare'] as num?)?.toStringAsFixed(0) ?? '0'}'),
                  const SizedBox(height: 6),
                  _buildSplitRow('💻 প্ল্যাটফর্ম রেভিনিউ:', '৳${(result['platformFee'] as num?)?.toStringAsFixed(0) ?? '0'}', isHighlight: true),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () {
                  Navigator.pop(ctx); // Close dialog
                  Navigator.pop(context); // Close screen
                },
                child: Text(
                  'ঠিক আছে',
                  style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSplitRow(String label, String value, {bool isHighlight = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.hindSiliguri(
            fontSize: 12,
            fontWeight: isHighlight ? FontWeight.bold : FontWeight.w500,
            color: isHighlight ? const Color(0xFF1B5E20) : Colors.black87,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.hindSiliguri(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: isHighlight ? const Color(0xFF1B5E20) : const Color(0xFF2E7D32),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(
          'ডেলিভারি ভেরিফিকেশন ও এস্ক্রো',
          style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF1976D2),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Batch Card with Simulated QR
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    width: 140,
                    height: 140,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.qr_code_2_rounded, size: 80, color: Color(0xFF1976D2)),
                        Text(
                          widget.order.batchCode,
                          style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'লট ট্র্যাকিং ব্যাচ: ${widget.order.batchCode}',
                    style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF1976D2)),
                  ),
                  Text(
                    'পণ্য: ${widget.order.productName} (${widget.order.quantity} ${widget.order.unit})',
                    style: GoogleFonts.hindSiliguri(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87),
                  ),
                  Text(
                    'বিক্রেতা: ${widget.order.farmerName}',
                    style: GoogleFonts.hindSiliguri(fontSize: 12, color: Colors.grey.shade700),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // OTP Verification Box
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.lock_clock_rounded, color: Color(0xFF1976D2), size: 22),
                      const SizedBox(width: 8),
                      Text(
                        'ডেলিভারি ওটিপি দিন (Delivery OTP)',
                        style: GoogleFonts.hindSiliguri(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'ক্রেতার ফোন স্ক্রিনে প্রদর্শিত ৪-সংখ্যার ওটিপি কোডটি সংগ্রহ করে এখানে প্রবেশ করান:',
                    style: GoogleFonts.hindSiliguri(fontSize: 12, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _otpController,
                    keyboardType: TextInputType.number,
                    maxLength: 4,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: 12, color: const Color(0xFF1976D2)),
                    decoration: InputDecoration(
                      hintText: '----',
                      hintStyle: GoogleFonts.poppins(letterSpacing: 12, color: Colors.grey.shade400),
                      counterText: '',
                      filled: true,
                      fillColor: const Color(0xFFF5F7FA),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.blue.shade200),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.blue.shade200),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF1976D2), width: 2),
                      ),
                    ),
                  ),
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      _errorMessage!,
                      style: GoogleFonts.hindSiliguri(color: Colors.red, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ],
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1976D2),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: _isSubmitting ? null : _verifyAndRelease,
                      child: _isSubmitting
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : Text(
                              'ওটিপি যাচাই ও পেমেন্ট রিলিজ',
                              style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
