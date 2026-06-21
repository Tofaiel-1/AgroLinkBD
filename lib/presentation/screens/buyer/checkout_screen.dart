import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';

/// Checkout Screen - Complete order placement
class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String _selectedPayment = 'bkash';
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _addressController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('চেকআউট'),
        backgroundColor: const Color(0xFF1976D2),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Delivery Address
            Text(
              'ডেলিভারি ঠিকানা',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _addressController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'আপনার সম্পূর্ণ ঠিকানা লিখুন',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Phone Number
            Text(
              'ফোন নম্বর',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                hintText: '০১৭XXXXXXXX',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Payment Method
            Text(
              'পেমেন্ট পদ্ধতি',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            _buildPaymentOption('bkash', 'bKash', Icons.mobile_screen_share),
            _buildPaymentOption('nagad', 'Nagad', Icons.payment),
            _buildPaymentOption('rocket', 'Rocket', Icons.credit_card),
            _buildPaymentOption(
                'card', 'ক্রেডিট কার্ড', Icons.credit_card_sharp),
            const SizedBox(height: 24),

            // Order Summary
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  _buildSummaryRow('আইটেম', '৳ ২,২৫০'),
                  const SizedBox(height: 8),
                  _buildSummaryRow('ডেলিভারি', '৳ ১৫০'),
                  const SizedBox(height: 8),
                  _buildSummaryRow('কর', '৳ ১২০'),
                  const SizedBox(height: 12),
                  Container(height: 1, color: Colors.grey.shade300),
                  const SizedBox(height: 12),
                  _buildSummaryRow('মোট', '৳ ২,৫২০', isBold: true),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Place Order Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                ),
                onPressed: () {
                  Get.snackbar(
                    'সাফল্য',
                    'আপনার অর্ডার সফলভাবে স্থাপন করা হয়েছে',
                    backgroundColor: Colors.green,
                    colorText: Colors.white,
                  );
                  Get.back();
                },
                child: Text(
                  'অর্ডার স্থাপন করুন',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentOption(String value, String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        child: InkWell(
          onTap: () => setState(() => _selectedPayment = value),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _selectedPayment == value
                  ? Colors.blue.withOpacity(0.1)
                  : Colors.white,
              border: Border.all(
                color: _selectedPayment == value
                    ? Colors.blue
                    : Colors.grey.shade200,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Radio(
                  value: value,
                  groupValue: _selectedPayment,
                  onChanged: (v) =>
                      setState(() => _selectedPayment = v as String),
                  activeColor: Colors.blue,
                ),
                const SizedBox(width: 12),
                Icon(icon, color: Colors.blue),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: Colors.grey.shade600,
            fontWeight: isBold ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: Colors.black87,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
