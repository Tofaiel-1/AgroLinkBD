import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:agrolinkbd/core/providers/user_provider.dart';
import 'package:agrolinkbd/core/providers/language_provider.dart';
import 'package:agrolinkbd/core/services/vip_subscription_service.dart';
import 'package:agrolinkbd/presentation/screens/subscription/vip_subscription_paywall_screen.dart';

class VipWholesaleGatekeeperCard extends StatefulWidget {
  final bool isDark;
  final bool isBn;
  final VoidCallback? onSubscriptionSuccess;

  const VipWholesaleGatekeeperCard({
    super.key,
    required this.isDark,
    required this.isBn,
    this.onSubscriptionSuccess,
  });

  @override
  State<VipWholesaleGatekeeperCard> createState() => _VipWholesaleGatekeeperCardState();
}

class _VipWholesaleGatekeeperCardState extends State<VipWholesaleGatekeeperCard> {
  final VipSubscriptionService _vipService = VipSubscriptionService();
  bool _isProcessing = false;

  void _handleSslCommerzPayment(BuildContext context) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.currentUser;

    setState(() => _isProcessing = true);

    final success = await _vipService.initiateSslCommerzPayment(
      context,
      userId: user?.id ?? 'temp_user',
      userName: user?.name ?? 'Valued Trader',
      userPhone: user?.phone ?? '01700000000',
      userEmail: user?.email ?? 'trader@agrolinkbd.com',
      amount: 299.0,
      planName: 'Monthly VIP Wholesale Pass',
    );

    setState(() => _isProcessing = false);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.isBn
                ? 'অভিনন্দন! এসএসএলকমার্জ পেমেন্ট সফল হয়েছে এবং ভিআইপি পাইকারি অ্যাক্সেস সক্রিয় হয়েছে! 👑'
                : 'Congratulations! SSLCommerz payment successful and VIP Wholesale access unlocked! 👑',
            style: GoogleFonts.hindSiliguri(),
          ),
          backgroundColor: const Color(0xFF1B5E20),
          duration: const Duration(seconds: 4),
        ),
      );
      if (widget.onSubscriptionSuccess != null) {
        widget.onSubscriptionSuccess!();
      }
    }
  }

  void _showManualTrxDialog(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.currentUser;

    final phoneController = TextEditingController(text: user?.phone ?? '');
    final trxController = TextEditingController();
    String selectedMethod = 'bKash';
    String selectedPlan = 'মাসিক ভিআইপি (৳২৯৯)';
    double selectedAmount = 299.0;
    bool isSubmitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          final isBn = widget.isBn;
          final isDark = widget.isDark;

          return Container(
            padding: EdgeInsets.only(
              top: 20,
              left: 20,
              right: 20,
              bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            ),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF162319) : Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade400,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.amber.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.verified_user_rounded, color: Colors.amber, size: 24),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isBn ? 'অ্যাডমিন ভেরিফিকেশন ও TrxID সাবমিট' : 'Manual TrxID Verification',
                              style: GoogleFonts.hindSiliguri(
                                fontSize: 16.5,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                            Text(
                              isBn ? 'টাকা পাঠিয়ে ট্রানজেকশন আইডি প্রদান করুন' : 'Send payment & submit Transaction ID',
                              style: GoogleFonts.hindSiliguri(
                                fontSize: 11.5,
                                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(height: 1),
                  const SizedBox(height: 14),

                  // Official Numbers Box
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1B5E20).withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFF1B5E20).withValues(alpha: 0.25)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isBn ? 'অফিসিয়াল পেমেন্ট নম্বর (Send Money / Merchant):' : 'Official Payment Numbers:',
                          style: GoogleFonts.hindSiliguri(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1B5E20),
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildCopyNumberRow('bKash Merchant / Personal:', '01711002233', Colors.pink.shade700),
                        const SizedBox(height: 4),
                        _buildCopyNumberRow('Nagad Merchant / Personal:', '01822334455', Colors.orange.shade800),
                        const SizedBox(height: 4),
                        _buildCopyNumberRow('Rocket Agent / Personal:', '01933445566-7', Colors.purple.shade700),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Method Selection Chips
                  Text(
                    isBn ? '১. পেমেন্ট মাধ্যম বেছে নিন:' : '1. Select Payment Method:',
                    style: GoogleFonts.hindSiliguri(fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: ['bKash', 'Nagad', 'Rocket', 'Upay'].map((method) {
                      final isSelected = selectedMethod == method;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(
                            method,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                            ),
                          ),
                          selected: isSelected,
                          selectedColor: const Color(0xFF1B5E20),
                          backgroundColor: isDark ? const Color(0xFF233526) : Colors.grey.shade100,
                          onSelected: (val) {
                            if (val) setModalState(() => selectedMethod = method);
                          },
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 14),

                  // Sender Phone
                  TextField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    style: GoogleFonts.poppins(fontSize: 14),
                    decoration: InputDecoration(
                      labelText: isBn ? 'আপনার প্রেরক নম্বর (Sender Phone)' : 'Sender Phone Number',
                      hintText: '017XXXXXXXX',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      prefixIcon: const Icon(Icons.phone_android),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Transaction ID
                  TextField(
                    controller: trxController,
                    textCapitalization: TextCapitalization.characters,
                    style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                    decoration: InputDecoration(
                      labelText: isBn ? 'ট্রানজেকশন আইডি (TrxID) *' : 'Transaction ID (TrxID) *',
                      hintText: 'e.g. BL9A7X3M9Q',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      prefixIcon: const Icon(Icons.receipt_long),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: isSubmitting
                          ? null
                          : () async {
                              final trx = trxController.text.trim();
                              final phone = phoneController.text.trim();

                              if (trx.isEmpty || trx.length < 6) {
                                Get.snackbar(
                                  isBn ? 'সতর্কতা' : 'Warning',
                                  isBn ? 'অনুগ্রহ করে সঠিক ট্রানজেকশন আইডি দিন।' : 'Please enter valid Transaction ID.',
                                  backgroundColor: Colors.red.shade700,
                                  colorText: Colors.white,
                                );
                                return;
                              }

                              setModalState(() => isSubmitting = true);

                              final res = await _vipService.submitManualTransaction(
                                userId: user?.id ?? 'temp_user',
                                userName: user?.name ?? 'Valued Trader',
                                userPhone: user?.phone ?? phone,
                                paymentMethod: selectedMethod,
                                senderPhone: phone,
                                transactionId: trx,
                                amount: selectedAmount,
                                planName: selectedPlan,
                              );

                              setModalState(() => isSubmitting = false);

                              if (res && mounted) {
                                Navigator.pop(ctx);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      isBn
                                          ? 'ট্রানজেকশন আইডি সফলভাবে সাবমিট হয়েছে! অ্যাডমিন দ্রুত ভেরিফাই করে এপ্রুভ করবেন।'
                                          : 'TrxID submitted successfully! Admin will verify and approve.',
                                      style: GoogleFonts.hindSiliguri(),
                                    ),
                                    backgroundColor: const Color(0xFF1B5E20),
                                    duration: const Duration(seconds: 4),
                                  ),
                                );
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1B5E20),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: isSubmitting
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : Text(
                              isBn ? 'ভেরিফিকেশনের জন্য পাঠান' : 'Submit for Admin Verification',
                              style: GoogleFonts.hindSiliguri(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCopyNumberRow(String label, String number, Color color) {
    return Row(
      children: [
        Text(
          label,
          style: GoogleFonts.hindSiliguri(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.black87),
        ),
        const SizedBox(width: 6),
        Text(
          number,
          style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: color),
        ),
        const Spacer(),
        InkWell(
          onTap: () {
            Clipboard.setData(ClipboardData(text: number));
            Get.snackbar(
              'কপি হয়েছে',
              '$number ক্লিপবোর্ডে কপি করা হয়েছে।',
              backgroundColor: Colors.black87,
              colorText: Colors.white,
              duration: const Duration(seconds: 2),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              'Copy',
              style: GoogleFonts.poppins(fontSize: 9, fontWeight: FontWeight.bold, color: color),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).currentUser;
    final userId = user?.id ?? '';

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: _vipService.getSubscriptionStatusStream(userId),
      builder: (context, snapshot) {
        final data = snapshot.data?.data();
        final status = data?['status'] as String?;
        final isPending = status == 'pending_approval';
        final trxId = data?['transactionId'] as String? ?? '';
        final method = data?['paymentMethod'] as String? ?? '';

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: widget.isDark
                  ? [const Color(0xFF17241A), const Color(0xFF223526)]
                  : [const Color(0xFFFFFFFF), const Color(0xFFF1F8F3)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isPending ? Colors.amber.shade700 : const Color(0xFF2E7D32).withValues(alpha: 0.35),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: widget.isDark ? 0.3 : 0.06),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Header Badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFE65100), Color(0xFFFF8F00)],
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.workspace_premium_rounded, color: Colors.white, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            widget.isBn ? 'ভিআইপি ফিচার 👑' : 'VIP FEATURE 👑',
                            style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: isPending ? Colors.amber.withValues(alpha: 0.15) : Colors.green.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        isPending
                            ? (widget.isBn ? '⏳ ভেরিফিকেশন রিভিউ' : '⏳ Review Pending')
                            : (widget.isBn ? '🔒 লক করা' : '🔒 Locked'),
                        style: GoogleFonts.hindSiliguri(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isPending ? Colors.amber.shade900 : const Color(0xFF1B5E20),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Icon & Title
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1B5E20).withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.lock_person_rounded, size: 42, color: Color(0xFF2E7D32)),
                ),
                const SizedBox(height: 12),
                Text(
                  widget.isBn ? 'পাইকারি ফসল ট্রেড এক্সচেঞ্জ' : 'Wholesale Commodity Trade Floor',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.hindSiliguri(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: widget.isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  widget.isBn
                      ? 'বাণিজ্যিক পাইকারি বাজার ও বড় খামারিদের আসল স্টক রেট প্রিমিয়াম মেম্বারদের জন্য সংরক্ষিত। এসএসএলকমার্জ বা মোবাইল ব্যাংকিং দিয়ে পেমেন্ট করলে অ্যাডমিন ট্রানজেকশন আইডি যাচাই করে এপ্রুভ করে দিবেন।'
                      : 'Active bulk wholesale crop trading is an exclusive VIP feature. Pay via SSLCommerz or MFS and admin will verify TrxID to approve instant access.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.hindSiliguri(
                    fontSize: 12.5,
                    color: widget.isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),

                // Pending Banner if active
                if (isPending) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.amber.shade400),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.hourglass_top_rounded, color: Colors.amber, size: 18),
                            const SizedBox(width: 6),
                            Text(
                              widget.isBn ? 'পেমেন্ট ভেরিফিকেশন চলমান' : 'Payment Verification In Progress',
                              style: GoogleFonts.hindSiliguri(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.brown.shade900,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${widget.isBn ? "পেমেন্ট মাধ্যম:" : "Method:"} $method • ${widget.isBn ? "ট্রানজেকশন আইডি:" : "TrxID:"} $trxId',
                          style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.brown.shade800),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.isBn
                              ? 'অ্যাডমিন টিম আপনার ট্রানজেকশন আইডি চেক করছেন। যাচাই শেষ হলে স্বয়ংক্রিয়ভাবে ফিচারটি খুলে যাবে।'
                              : 'Admin is verifying your Transaction ID. Access will unlock automatically once confirmed.',
                          style: GoogleFonts.hindSiliguri(fontSize: 11, color: Colors.brown.shade700),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Feature Bullets
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: widget.isDark ? const Color(0xFF141F16) : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.green.withValues(alpha: 0.15)),
                  ),
                  child: Column(
                    children: [
                      _buildBulletItem(
                        icon: Icons.verified,
                        text: widget.isBn
                            ? '১০০% যাচাইকৃত বাণিজ্যিক খামারি ও আড়তদার'
                            : '100% Verified Bulk Farmers & Arat Merchants',
                        color: Colors.green,
                      ),
                      const SizedBox(height: 6),
                      _buildBulletItem(
                        icon: Icons.security,
                        text: widget.isBn
                            ? 'এসএসএলকমার্জ ও এমএফএস সুরক্ষিত এসক্রো গ্যারান্টি'
                            : 'SSLCommerz & Digital MFS Escrow Guarantee',
                        color: Colors.blue,
                      ),
                      const SizedBox(height: 6),
                      _buildBulletItem(
                        icon: Icons.insights_rounded,
                        text: widget.isBn
                            ? '১৪-দিনের এআই পাইকারি দর পূর্বাভাস রাডার'
                            : '14-Day AI Crop Wholesale Price Radar',
                        color: Colors.purple,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // SSLCommerz Instant Action
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: _isProcessing ? null : () => _handleSslCommerzPayment(context),
                    icon: _isProcessing
                        ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Icon(Icons.flash_on_rounded, color: Colors.amberAccent, size: 20),
                    label: Text(
                      widget.isBn ? 'এসএসএলকমার্জ দিয়ে তাৎক্ষণিক আনলক (৳২৯৯)' : 'Instant Unlock via SSLCommerz (৳299)',
                      style: GoogleFonts.hindSiliguri(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1B5E20),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 3,
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Alternative Options Row
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _showManualTrxDialog(context),
                        icon: const Icon(Icons.receipt_long, size: 16, color: Color(0xFF2E7D32)),
                        label: Text(
                          widget.isBn ? 'TrxID সাবমিট' : 'Submit TrxID',
                          style: GoogleFonts.hindSiliguri(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF2E7D32),
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFF2E7D32)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => Get.to(() => const VipSubscriptionPaywallScreen()),
                        icon: const Icon(Icons.card_membership, size: 16, color: Color(0xFFE65100)),
                        label: Text(
                          widget.isBn ? 'সকল প্ল্যান' : 'All VIP Plans',
                          style: GoogleFonts.hindSiliguri(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFFE65100),
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFE65100)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBulletItem({required IconData icon, required String text, required Color color}) {
    return Row(
      children: [
        Icon(icon, size: 15, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.hindSiliguri(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: widget.isDark ? Colors.white70 : Colors.black87,
            ),
          ),
        ),
      ],
    );
  }
}
