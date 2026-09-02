import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:agrolinkbd/core/services/sslcommerz_service.dart';
import 'package:agrolinkbd/core/services/order_service.dart';
import 'package:agrolinkbd/core/models/order_model.dart';
import 'package:agrolinkbd/presentation/screens/buyer/fish_buyer_orders_screen.dart';

/// Checkout Screen - Complete order placement
class CheckoutScreen extends StatefulWidget {
  final double subtotal;
  final String productName;

  const CheckoutScreen({
    super.key,
    this.subtotal = 2250.0,
    this.productName = 'কৃষি পণ্যসমূহ',
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String _selectedPayment = 'sslcommerz';
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && user.phoneNumber != null && user.phoneNumber!.isNotEmpty) {
      _phoneController.text = user.phoneNumber!;
    }
  }

  @override
  void dispose() {
    _addressController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _handlePlaceOrder(double total) async {
    if (_addressController.text.trim().isEmpty) {
      Get.snackbar('সতর্কতা', 'অনুগ্রহ করে ডেলিভারি ঠিকানা লিখুন', backgroundColor: Colors.amber.shade700, colorText: Colors.white);
      return;
    }
    if (_phoneController.text.trim().isEmpty) {
      Get.snackbar('সতর্কতা', 'অনুগ্রহ করে ফোন নম্বর লিখুন', backgroundColor: Colors.amber.shade700, colorText: Colors.white);
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      final customerName = user?.displayName ?? 'Buyer User';
      final customerEmail = user?.email ?? 'buyer@agrolinkbd.com';
      final customerPhone = _phoneController.text.trim();
      final customerAddress = _addressController.text.trim();

      bool paymentSuccess = false;

      if (_selectedPayment == 'cod') {
        paymentSuccess = true;
      } else {
        paymentSuccess = await SSLCommerzService.initiatePayment(
          context: context,
          amount: total,
          productName: widget.productName,
          customerName: customerName,
          customerEmail: customerEmail,
          customerPhone: customerPhone,
          customerAddress: customerAddress,
        );
      }

      if (paymentSuccess) {
        final orderId = 'ORD_${DateTime.now().millisecondsSinceEpoch}';
        final newOrder = OrderModel(
          id: orderId,
          buyerId: user?.uid ?? 'guest_buyer',
          farmerId: 'FARMER_GENERAL',
          farmerName: 'ভেরিফাইড কৃষক সমবায়',
          productName: widget.productName,
          productImageUrl: 'https://images.unsplash.com/photo-1542838132-92c53300491e?w=400&q=80',
          quantity: 1.0,
          totalAmount: total,
          status: 'pending',
          statusStep: 1,
          transportStatus: _selectedPayment == 'cod' ? 'ক্যাশ অন ডেলিভারি অর্ডার গৃহীত' : 'পেমেন্ট সম্পন্ন • এস্ক্রো হোল্ডে সুরক্ষিত',
          paymentStatus: _selectedPayment == 'cod' ? 'unpaid' : 'paid',
          deliveryAddress: customerAddress,
          createdAt: DateTime.now(),
          estimatedDeliveryDate: DateTime.now().add(const Duration(days: 3)),
        );

        await OrderService().createOrder(newOrder);

        if (mounted) {
          Get.snackbar(
            'অর্ডার সফল! 🎉',
            'আপনার অর্ডারটি সফলভাবে গ্রহণ করা হয়েছে।',
            backgroundColor: const Color(0xFF2E7D32),
            colorText: Colors.white,
            duration: const Duration(seconds: 4),
          );
          Get.off(() => const FishBuyerOrdersScreen());
        }
      }
    } catch (e) {
      debugPrint('Checkout error: $e');
      Get.snackbar('ত্রুটি', 'অর্ডার সম্পন্ন করতে ব্যর্থ: $e', backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const delivery = 150.0;
    const tax = 120.0;
    final total = widget.subtotal + delivery + tax;

    return Scaffold(
      appBar: AppBar(
        title: Text('চেকআউট', style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFF1976D2),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Delivery Address
            Text(
              'ডেলিভারি ঠিকানা',
              style: GoogleFonts.hindSiliguri(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _addressController,
              maxLines: 2,
              style: GoogleFonts.hindSiliguri(),
              decoration: InputDecoration(
                hintText: 'আপনার সম্পূর্ণ ঠিকানা (বাড়ি, সড়ক, এলাকা, জেলা) লিখুন',
                hintStyle: GoogleFonts.hindSiliguri(fontSize: 13, color: Colors.grey.shade400),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Phone Number
            Text(
              'ফোন নম্বর',
              style: GoogleFonts.hindSiliguri(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              style: GoogleFonts.poppins(),
              decoration: InputDecoration(
                hintText: '০১XXXXXXXXX',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Payment Method
            Text(
              'পেমেন্ট পদ্ধতি নির্বাচন করুন',
              style: GoogleFonts.hindSiliguri(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            _buildPaymentOption('sslcommerz', 'SSLCommerz গেটওয়ে (কার্ড / বিকাশ / নগদ / ব্যাংক)', Icons.security, isRecommended: true),
            _buildPaymentOption('bkash', 'বিকাশ (bKash Instant)', Icons.mobile_screen_share),
            _buildPaymentOption('nagad', 'নগদ (Nagad Instant)', Icons.payment),
            _buildPaymentOption('card', 'ভিসা / মাস্টারকার্ড / এমেক্স', Icons.credit_card),
            _buildPaymentOption('cod', 'ক্যাশ অন ডেলিভারি (Cash on Delivery)', Icons.local_shipping_outlined),
            const SizedBox(height: 24),

            // Order Summary
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  _buildSummaryRow('আইটেম সাবটোটাল', '৳ ${widget.subtotal.toStringAsFixed(0)}'),
                  const SizedBox(height: 8),
                  _buildSummaryRow('লজিস্টিকস ও ডেলিভারি', '৳ ${delivery.toStringAsFixed(0)}'),
                  const SizedBox(height: 8),
                  _buildSummaryRow('ভ্যাট ও সার্ভিস চার্জ', '৳ ${tax.toStringAsFixed(0)}'),
                  const SizedBox(height: 12),
                  Container(height: 1, color: Colors.grey.shade300),
                  const SizedBox(height: 12),
                  _buildSummaryRow('সর্বমোট পরিশোধযোগ্য', '৳ ${total.toStringAsFixed(0)}', isBold: true),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Place Order Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1976D2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 3,
                ),
                onPressed: _isProcessing ? null : () => _handlePlaceOrder(total),
                child: _isProcessing
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.lock, color: Colors.white, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            _selectedPayment == 'cod' ? 'ক্যাশ অন ডেলিভারি অর্ডার দিন' : 'পেমেন্ট ও অর্ডার নিশ্চিত করুন ৳${total.toStringAsFixed(0)}',
                            style: GoogleFonts.hindSiliguri(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentOption(String value, String label, IconData icon, {bool isRecommended = false}) {
    final isSelected = _selectedPayment == value;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => setState(() => _selectedPayment = value),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF1976D2).withOpacity(0.08) : Colors.white,
              border: Border.all(
                color: isSelected ? const Color(0xFF1976D2) : Colors.grey.shade300,
                width: isSelected ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Radio<String>(
                  value: value,
                  groupValue: _selectedPayment,
                  onChanged: (v) => setState(() => _selectedPayment = v!),
                  activeColor: const Color(0xFF1976D2),
                ),
                const SizedBox(width: 4),
                Icon(icon, color: isSelected ? const Color(0xFF1976D2) : Colors.grey.shade700),
                const SizedBox(width: 10),
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          label,
                          style: GoogleFonts.hindSiliguri(
                            fontSize: 13,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      if (isRecommended)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.green.shade100,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'সেরা পছন্দ ⭐',
                            style: GoogleFonts.hindSiliguri(fontSize: 10, color: Colors.green.shade900, fontWeight: FontWeight.bold),
                          ),
                        ),
                    ],
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
          style: GoogleFonts.hindSiliguri(
            fontSize: 13,
            color: Colors.grey.shade700,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: isBold ? 16 : 13,
            color: isBold ? const Color(0xFF1976D2) : Colors.black87,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
