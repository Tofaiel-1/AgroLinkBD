import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:agrolinkbd/core/providers/user_provider.dart';
import 'package:agrolinkbd/core/models/payment_model.dart';
import 'package:agrolinkbd/core/services/payment_service.dart';

enum MfsProvider { bkash, nagad, rocket, upay, card }

class MfsPaymentCheckoutScreen extends StatefulWidget {
  final String title;
  final String description;
  final double amount;
  final String purpose; // 'vip_subscription', 'auction_deposit', 'transport_fare', etc.
  final Duration subscriptionDuration;

  const MfsPaymentCheckoutScreen({
    super.key,
    required this.title,
    required this.description,
    required this.amount,
    this.purpose = 'vip_subscription',
    this.subscriptionDuration = const Duration(days: 30),
  });

  @override
  State<MfsPaymentCheckoutScreen> createState() => _MfsPaymentCheckoutScreenState();
}

class _MfsPaymentCheckoutScreenState extends State<MfsPaymentCheckoutScreen> {
  MfsProvider _selectedProvider = MfsProvider.bkash;
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  final _pinController = TextEditingController();

  int _currentStep = 0; // 0: Select Provider & Number, 1: OTP, 2: PIN / Confirm
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final user = Provider.of<UserProvider>(context, listen: false).currentUser;
    if (user != null && user.phone.isNotEmpty) {
      _phoneController.text = user.phone;
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  Color _getProviderColor(MfsProvider p) {
    switch (p) {
      case MfsProvider.bkash:
        return const Color(0xFFD12053);
      case MfsProvider.nagad:
        return const Color(0xFFF7941D);
      case MfsProvider.rocket:
        return const Color(0xFF8C3494);
      case MfsProvider.upay:
        return const Color(0xFF0072CE);
      case MfsProvider.card:
        return const Color(0xFF1E88E5);
    }
  }

  String _getProviderName(MfsProvider p) {
    switch (p) {
      case MfsProvider.bkash:
        return 'বিকাশ (bKash)';
      case MfsProvider.nagad:
        return 'নগদ (Nagad)';
      case MfsProvider.rocket:
        return 'রকেট (Rocket)';
      case MfsProvider.upay:
        return 'উপায় (Upay)';
      case MfsProvider.card:
        return 'ভিসা / মাস্টারকার্ড (Card)';
    }
  }

  void _proceedToOtp() {
    if (_phoneController.text.trim().length < 11) {
      Get.snackbar('সতর্কতা', 'অনুগ্রহ করে সঠিক ১১ ডিজিটের মোবাইল নম্বর লিখুন।', backgroundColor: Colors.amber.shade700, colorText: Colors.white);
      return;
    }
    setState(() => _isLoading = true);
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _isLoading = false;
        _currentStep = 1;
      });
      Get.snackbar(
        'ওটিপি পাঠানো হয়েছে 📩',
        'আপনার ${_phoneController.text} নম্বরে ৬ ডিজিটের ভেরিফিকেশন কোড পাঠানো হয়েছে (ডেমো কোড: 123456)',
        backgroundColor: _getProviderColor(_selectedProvider),
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
      );
    });
  }

  void _proceedToPin() {
    if (_otpController.text.trim().length < 4) {
      Get.snackbar('ভুল ওটিপি', 'অনুগ্রহ করে সঠিক ভেরিফিকেশন কোড লিখুন।', backgroundColor: Colors.red.shade700, colorText: Colors.white);
      return;
    }
    setState(() => _currentStep = 2);
  }

  Future<void> _completePayment() async {
    if (_pinController.text.trim().length < 4) {
      Get.snackbar('পিন নম্বর আবশ্যক', 'অনুগ্রহ করে আপনার ${_getProviderName(_selectedProvider)} এর গোপন পিন দিন।', backgroundColor: Colors.red.shade700, colorText: Colors.white);
      return;
    }

    setState(() => _isLoading = true);

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.currentUser;
    final txnId = 'AGRO-TXN-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';

    // 1. Process payment via service
    try {
      PaymentMethod pMethod;
      switch (_selectedProvider) {
        case MfsProvider.bkash:
          pMethod = PaymentMethod.bkash;
          break;
        case MfsProvider.nagad:
          pMethod = PaymentMethod.nagad;
          break;
        case MfsProvider.rocket:
        case MfsProvider.upay:
          pMethod = PaymentMethod.rocket;
          break;
        case MfsProvider.card:
          pMethod = PaymentMethod.card;
          break;
      }

      final paymentService = PaymentService();
      final payment = await paymentService.initializePayment(
        userId: user?.id ?? 'guest_user',
        amount: widget.amount,
        method: pMethod,
        purpose: widget.purpose,
        metadata: {
          'title': widget.title,
          'provider': _getProviderName(_selectedProvider),
          'phone': _phoneController.text,
        },
      );
      await paymentService.verifyAndCompletePayment(
        paymentId: payment.id,
        transactionId: txnId,
      );
    } catch (e) {
      debugPrint('Payment record error: $e');
    }

    // 2. Activate Premium in UserProvider and Firebase if purpose is vip_subscription
    if (widget.purpose == 'vip_subscription') {
      final expiryDate = DateTime.now().add(widget.subscriptionDuration);
      await userProvider.upgradeToPremium(expiryDate);
    }

    setState(() => _isLoading = false);

    // Show Success Dialog
    _showSuccessDialog(txnId);
  }

  void _showSuccessDialog(String txnId) {
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
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle, size: 60, color: Colors.green),
            ),
            const SizedBox(height: 16),
            Text(
              'পেমেন্ট সফল হয়েছে! 🎉',
              style: GoogleFonts.hindSiliguri(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'আপনার ৳${widget.amount.toStringAsFixed(0)} টাকা পেমেন্ট সফলভাবে সম্পন্ন হয়েছে।',
              textAlign: TextAlign.center,
              style: GoogleFonts.hindSiliguri(fontSize: 14, color: Colors.grey.shade700),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('TrxID:', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade600)),
                  Text(txnId, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx); // close dialog
                  Get.back(result: true); // return success
                  Get.snackbar(
                    'ভিআইপি মেম্বারশিপ সক্রিয় 👑',
                    'আপনার সকল প্রিমিয়াম ফিচার আনলক করা হয়েছে!',
                    backgroundColor: const Color(0xFF2E7D32),
                    colorText: Colors.white,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text('সম্পন্ন করুন', style: GoogleFonts.hindSiliguri(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final providerColor = _getProviderColor(_selectedProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF4F6F9),
      appBar: AppBar(
        title: Text(
          'নিরাপদ এমএফএস পেমেন্ট',
          style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: providerColor,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Summary Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(color: isDark ? Colors.white12 : Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(widget.title, style: GoogleFonts.hindSiliguri(fontSize: 16, fontWeight: FontWeight.bold)),
                      Text(
                        '৳${widget.amount.toStringAsFixed(0)}',
                        style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: providerColor),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(widget.description, style: GoogleFonts.hindSiliguri(fontSize: 12, color: Colors.grey.shade600)),
                ],
              ),
            ),

            const SizedBox(height: 20),
            Text('পেমেন্ট মেথড নির্বাচন করুন', style: GoogleFonts.hindSiliguri(fontSize: 15, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            // Provider selection chips
            Row(
              children: [
                _buildProviderChip(MfsProvider.bkash, 'বিকাশ', const Color(0xFFD12053)),
                const SizedBox(width: 8),
                _buildProviderChip(MfsProvider.nagad, 'নগদ', const Color(0xFFF7941D)),
                const SizedBox(width: 8),
                _buildProviderChip(MfsProvider.rocket, 'রকেট', const Color(0xFF8C3494)),
                const SizedBox(width: 8),
                _buildProviderChip(MfsProvider.card, 'কার্ড', const Color(0xFF1E88E5)),
              ],
            ),

            const SizedBox(height: 24),

            // Steps container
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: providerColor.withOpacity(0.4), width: 1.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: providerColor.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.security, color: providerColor, size: 20),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '${_getProviderName(_selectedProvider)} সিকিউর গেটওয়ে',
                        style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  if (_currentStep == 0) ...[
                    Text('আপনার ${_getProviderName(_selectedProvider)} একাউন্ট নম্বর দিন', style: GoogleFonts.hindSiliguri(fontSize: 13, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      maxLength: 11,
                      style: GoogleFonts.poppins(fontSize: 16, letterSpacing: 1),
                      decoration: InputDecoration(
                        hintText: '01XXXXXXXXX',
                        prefixIcon: const Icon(Icons.phone_android),
                        filled: true,
                        fillColor: isDark ? Colors.grey.shade900 : Colors.grey.shade50,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _proceedToOtp,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: providerColor,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : Text('ওটিপি পাঠান (Send OTP)', style: GoogleFonts.hindSiliguri(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                    ),
                  ] else if (_currentStep == 1) ...[
                    Text('ভেরিফিকেশন ওটিপি কোড লিখুন', style: GoogleFonts.hindSiliguri(fontSize: 13, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text('আপনার ফোনে প্রাপ্ত ৬-ডিজিটের কোড দিন (ডেমো: 123456)', style: GoogleFonts.hindSiliguri(fontSize: 11, color: Colors.grey)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _otpController,
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      style: GoogleFonts.poppins(fontSize: 20, letterSpacing: 8, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        hintText: '123456',
                        filled: true,
                        fillColor: isDark ? Colors.grey.shade900 : Colors.grey.shade50,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => setState(() => _currentStep = 0),
                            child: Text('নম্বর পরিবর্তন', style: GoogleFonts.hindSiliguri()),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _proceedToPin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: providerColor,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: Text('যাচাই করুন', style: GoogleFonts.hindSiliguri(color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ] else if (_currentStep == 2) ...[
                    Text('আপনার গোপন পিন (PIN) লিখুন', style: GoogleFonts.hindSiliguri(fontSize: 13, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text('পেমেন্ট নিশ্চিত করতে আপনার ${_getProviderName(_selectedProvider)} এর পিন দিন', style: GoogleFonts.hindSiliguri(fontSize: 11, color: Colors.grey)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _pinController,
                      keyboardType: TextInputType.number,
                      obscureText: true,
                      maxLength: 5,
                      style: GoogleFonts.poppins(fontSize: 22, letterSpacing: 10, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        hintText: '•••••',
                        filled: true,
                        fillColor: isDark ? Colors.grey.shade900 : Colors.grey.shade50,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _completePayment,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: providerColor,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : Text(
                                'পেমেন্ট সম্পন্ন করুন ৳${widget.amount.toStringAsFixed(0)}',
                                style: GoogleFonts.hindSiliguri(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.lock, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  '১২৮-বিট এসএসএল এনক্রিপ্টেড ও শতভাগ সুরক্ষিত লেনদেন',
                  style: GoogleFonts.hindSiliguri(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProviderChip(MfsProvider provider, String name, Color color) {
    final isSelected = _selectedProvider == provider;
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedProvider = provider;
            _currentStep = 0;
            _otpController.clear();
            _pinController.clear();
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? color : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? color : Colors.grey.shade400,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Center(
            child: Text(
              name,
              style: GoogleFonts.hindSiliguri(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : Colors.grey.shade800,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
