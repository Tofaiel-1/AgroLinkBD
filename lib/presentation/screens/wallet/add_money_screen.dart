import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:agrolinkbd/core/services/deposit_service.dart';

class AddMoneyScreen extends StatefulWidget {
  final String userId;

  const AddMoneyScreen({Key? key, required this.userId}) : super(key: key);

  @override
  State<AddMoneyScreen> createState() => _AddMoneyScreenState();
}

class _AddMoneyScreenState extends State<AddMoneyScreen> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _txnIdController = TextEditingController();
  final DepositService _depositService = DepositService();
  
  String _selectedMethod = 'bkash';
  bool _isLoading = false;

  void _submitRequest() async {
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
      await _depositService.createDepositRequest(
        userId: widget.userId,
        amount: amount,
        paymentMethod: _selectedMethod,
        transactionId: _txnIdController.text.trim().isNotEmpty ? _txnIdController.text.trim() : null,
      );

      Get.back();
      Get.snackbar(
        'Success', 
        'Deposit request submitted successfully. Awaiting admin approval.',
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade900,
        duration: const Duration(seconds: 4),
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to submit request', backgroundColor: Colors.red.shade100);
    } finally {
      setState(() => _isLoading = false);
    }
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
            Text(
              'Select Payment Method',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor),
            ),
            const SizedBox(height: 12),
            _buildMethodOption('bkash', 'bKash', Colors.pink),
            _buildMethodOption('nagad', 'Nagad', Colors.orange),
            _buildMethodOption('bank', 'Bank Transfer', Colors.blue),
            const SizedBox(height: 24),
            Text(
              'Transaction ID (Optional)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _txnIdController,
              style: TextStyle(color: textColor),
              decoration: InputDecoration(
                hintText: 'e.g. 8KDF93HDK',
                hintStyle: TextStyle(color: hintColor),
                filled: true,
                fillColor: cardColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitRequest,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _isLoading 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      'Submit Request',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMethodOption(String id, String name, Color color) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final borderColor = isDark ? Colors.grey.shade800 : Colors.grey.shade300;

    final isSelected = _selectedMethod == id;
    return GestureDetector(
      onTap: () => setState(() => _selectedMethod = id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : borderColor,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.account_balance_wallet, color: color),
            const SizedBox(width: 16),
            Text(
              name,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: textColor),
            ),
            const Spacer(),
            if (isSelected) Icon(Icons.check_circle, color: color),
          ],
        ),
      ),
    );
  }
}
