import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:agrolinkbd/core/services/transaction_service.dart';

class DirectTransferScreen extends StatefulWidget {
  final String senderId;

  const DirectTransferScreen({Key? key, required this.senderId}) : super(key: key);

  @override
  State<DirectTransferScreen> createState() => _DirectTransferScreenState();
}

class _DirectTransferScreenState extends State<DirectTransferScreen> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _reasonController = TextEditingController();
  final TransactionService _transactionService = TransactionService();
  
  String _selectedReceiver = 'provider_demo'; // Default Service Provider for demo
  bool _isProcessing = false;

  void _submitTransfer() async {
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

    setState(() => _isProcessing = true);

    try {
      bool success = await _transactionService.transferFunds(
        senderId: widget.senderId,
        receiverId: _selectedReceiver,
        amount: amount,
        reason: _reasonController.text.isNotEmpty ? _reasonController.text : 'Payment for Services',
      );

      if (success) {
        Get.back();
        Get.snackbar(
          'Success', 
          'Transferred ৳$amount to $_selectedReceiver successfully.',
          backgroundColor: Colors.green.shade100,
          colorText: Colors.green.shade900,
        );
      } else {
        Get.snackbar('Failed', 'Insufficient balance or transfer failed.', backgroundColor: Colors.red.shade100);
      }
    } catch (e) {
      Get.snackbar('Error', 'Transfer failed: $e', backgroundColor: Colors.red.shade100);
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Direct Transfer'),
        backgroundColor: const Color(0xFF2E7D32),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Recipient',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedReceiver,
                  isExpanded: true,
                  items: const [
                    DropdownMenuItem(value: 'provider_demo', child: Text('Service Provider (Demo)')),
                    DropdownMenuItem(value: 'driver_demo', child: Text('Driver (Demo)')),
                    DropdownMenuItem(value: 'farmer_demo', child: Text('Farmer (Demo)')),
                  ],
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedReceiver = val);
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Enter Amount',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                prefixText: '৳ ',
                hintText: 'e.g. 500',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            const Text(
              'Reason / Purpose',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _reasonController,
              decoration: InputDecoration(
                hintText: 'e.g. Tractor rental',
                filled: true,
                fillColor: Colors.white,
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
                onPressed: _isProcessing ? null : _submitTransfer,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _isProcessing 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      'Transfer Now',
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
