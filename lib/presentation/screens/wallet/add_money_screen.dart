import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_sslcommerz/model/SSLCSdkType.dart';
import 'package:flutter_sslcommerz/model/SSLCTransactionInfoModel.dart';
import 'package:flutter_sslcommerz/model/SSLCommerzInitialization.dart';
import 'package:flutter_sslcommerz/sslcommerz.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddMoneyScreen extends StatefulWidget {
  final String userId;

  const AddMoneyScreen({Key? key, required this.userId}) : super(key: key);

  @override
  State<AddMoneyScreen> createState() => _AddMoneyScreenState();
}

class _AddMoneyScreenState extends State<AddMoneyScreen> {
  final TextEditingController _amountController = TextEditingController();
  bool _isLoading = false;

  void _submitPayment() async {
    final amountText = _amountController.text.trim();
    if (amountText.isEmpty) {
      Get.snackbar('Error', 'Please enter an amount', backgroundColor: Colors.red.shade100);
      return;
    }

    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) {
      Get.snackbar('Error', 'Please enter a valid amount', backgroundColor: Colors.red.shade100);
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1. Initialize SSLCommerz
      Sslcommerz sslcommerz = Sslcommerz(
        initializer: SSLCommerzInitialization(
          multi_card_name: 'internetbank',
          currency: 'BDT',
          product_category: 'Wallet Deposit',
          sdkType: SSLCSdkType.TESTBOX, 
          store_id: 'testbox', 
          store_passwd: 'testpassword',
          total_amount: amount,
          tran_id: 'TXN_${DateTime.now().millisecondsSinceEpoch}',
        ),
      );

      // 2. Launch SSLCommerz Payment UI
      var result = await sslcommerz.payNow();

      if (result.status == 'VALID' || result.status == 'VALIDATED') {
        // Payment successful - securely update balance
        await _processSuccessfulPayment(amount, result.tranId ?? 'UNKNOWN_TXN');
        
        Get.back();
        Get.snackbar(
          'Success', 
          'Money added successfully via SSLCommerz!',
          backgroundColor: Colors.green.shade100,
          colorText: Colors.green.shade900,
          duration: const Duration(seconds: 4),
        );
      } else {
        // Payment failed or cancelled
        Get.snackbar('Payment Failed', 'Transaction was cancelled or failed.', backgroundColor: Colors.red.shade100);
      }
    } catch (e) {
      Get.snackbar('Error', 'Could not initiate payment: $e', backgroundColor: Colors.red.shade100);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _processSuccessfulPayment(double amount, String txnId) async {
    final db = FirebaseFirestore.instance;
    final batch = db.batch();

    // 1. Log transaction
    final txRef = db.collection('wallet_transactions').doc();
    batch.set(txRef, {
      'userId': widget.userId,
      'amount': amount,
      'type': 'credit',
      'title': 'Deposit via SSLCommerz',
      'status': 'completed',
      'transactionId': txnId,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // 2. Update wallet/main balance (assuming cards collection holds wallet data)
    final cardRef = db.collection('cards').doc(widget.userId);
    final userRef = db.collection('users').doc(widget.userId);
    
    // We increment both places or just cards depending on app logic
    // Using increment ensures atomic update
    batch.set(cardRef, {'walletBalance': FieldValue.increment(amount)}, SetOptions(merge: true));
    
    // Also updating mainBalance in user profile if they share it
    batch.set(userRef, {'mainBalance': FieldValue.increment(amount)}, SetOptions(merge: true));

    await batch.commit();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFF5F7FA);
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final hintColor = isDark ? Colors.grey.shade500 : Colors.grey.shade400;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text('Add Money to Wallet'),
        backgroundColor: const Color(0xFF2E7D32),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enter Amount',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textColor),
              decoration: InputDecoration(
                prefixText: '৳ ',
                prefixStyle: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textColor),
                hintText: 'e.g. 1000',
                hintStyle: TextStyle(color: hintColor),
                filled: true,
                fillColor: cardColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.security, color: Colors.blue),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Secured by SSLCommerz. You can pay via Cards, Mobile Banking (bKash, Nagad), and Net Banking.',
                      style: TextStyle(color: isDark ? Colors.blue.shade200 : Colors.blue.shade800, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _isLoading 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      'Proceed to Pay',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
