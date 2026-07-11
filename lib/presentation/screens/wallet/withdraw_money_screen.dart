import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:agrolinkbd/core/services/withdraw_service.dart';

class WithdrawMoneyScreen extends StatefulWidget {
  final String userId;
  final double currentBalance;

  const WithdrawMoneyScreen({
    Key? key,
    required this.userId,
    required this.currentBalance,
  }) : super(key: key);

  @override
  State<WithdrawMoneyScreen> createState() => _WithdrawMoneyScreenState();
}

class _WithdrawMoneyScreenState extends State<WithdrawMoneyScreen> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _accountDetailsController = TextEditingController();
  
  // Bank specific controllers
  final TextEditingController _receiverNameController = TextEditingController();
  final TextEditingController _bankAccountController = TextEditingController();
  final TextEditingController _routingNoController = TextEditingController();
  final TextEditingController _branchController = TextEditingController();
  String? _selectedBank;

  final WithdrawService _withdrawService = WithdrawService();
  
  String _selectedMethod = 'bkash';
  bool _isLoading = false;

  final List<String> _bangladeshBanks = [
    'AB Bank', 'Agrani Bank', 'Al-Arafah Islami Bank', 'Bank Asia', 'BRAC Bank',
    'City Bank', 'Dutch-Bangla Bank (DBBL)', 'Eastern Bank (EBL)', 'EXIM Bank', 
    'First Security Islami Bank', 'HSBC', 'IFIC Bank', 'Islami Bank (IBBL)', 
    'Jamuna Bank', 'Janata Bank', 'Mercantile Bank', 'Midland Bank', 'Modhumoti Bank',
    'Mutual Trust Bank (MTB)', 'National Bank', 'NCC Bank', 'NRB Bank', 'NRB Commercial Bank',
    'NRB Global Bank', 'One Bank', 'Padma Bank', 'Prime Bank', 'Pubali Bank', 
    'Rajshahi Krishi Unnayan Bank', 'Rupali Bank', 'Shahjalal Islami Bank', 
    'Social Islami Bank', 'Sonali Bank', 'South Bangla Agriculture and Commerce Bank',
    'Southeast Bank', 'Standard Bank', 'Standard Chartered Bank', 'Trust Bank', 
    'Union Bank', 'United Commercial Bank (UCB)', 'Uttara Bank'
  ];

  @override
  void dispose() {
    _amountController.dispose();
    _accountDetailsController.dispose();
    _receiverNameController.dispose();
    _bankAccountController.dispose();
    _routingNoController.dispose();
    _branchController.dispose();
    super.dispose();
  }

  void _submitRequest() async {
    final amountText = _amountController.text.trim();
    String accountDetails = '';
    
    if (amountText.isEmpty) {
      Get.snackbar('Error', 'Please enter an amount', backgroundColor: Colors.red.shade100);
      return;
    }

    if (_selectedMethod == 'bank') {
      if (_selectedBank == null || _selectedBank!.isEmpty) {
        Get.snackbar('Error', 'Please select a bank', backgroundColor: Colors.red.shade100);
        return;
      }
      if (_receiverNameController.text.trim().isEmpty) {
        Get.snackbar('Error', 'Please enter receiver name', backgroundColor: Colors.red.shade100);
        return;
      }
      if (_bankAccountController.text.trim().isEmpty) {
        Get.snackbar('Error', 'Please enter account number', backgroundColor: Colors.red.shade100);
        return;
      }
      
      accountDetails = 'Bank: $_selectedBank\n'
          'Name: ${_receiverNameController.text.trim()}\n'
          'A/C No: ${_bankAccountController.text.trim()}\n'
          'Routing: ${_routingNoController.text.trim()}\n'
          'Branch: ${_branchController.text.trim()}';
    } else {
      accountDetails = _accountDetailsController.text.trim();
      if (accountDetails.isEmpty) {
        Get.snackbar('Error', 'Please enter $_selectedMethod account number', backgroundColor: Colors.red.shade100);
        return;
      }
    }

    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) {
      Get.snackbar('Error', 'Please enter a valid amount', backgroundColor: Colors.red.shade100);
      return;
    }
    
    if (amount > widget.currentBalance) {
      Get.snackbar('Error', 'Insufficient balance', backgroundColor: Colors.red.shade100);
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _withdrawService.createWithdrawRequest(
        userId: widget.userId,
        amount: amount,
        method: _selectedMethod,
        accountDetails: accountDetails,
      );

      Get.back();
      Get.snackbar(
        'Success', 
        'Withdrawal request submitted successfully. Awaiting admin approval.',
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade900,
        duration: const Duration(seconds: 4),
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to submit request: ${e.toString().replaceAll('Exception: ', '')}', backgroundColor: Colors.red.shade100);
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
        title: const Text('Withdraw Money'),
        backgroundColor: const Color(0xFF2E7D32),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Available Balance',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor),
                  ),
                  Text(
                    '৳${widget.currentBalance}',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green.shade700),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.security, color: Colors.blue, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'All withdrawal requests are securely processed and verified by Admin before payout.',
                      style: TextStyle(color: isDark ? Colors.blue.shade200 : Colors.blue.shade800, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
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
              'Select Withdrawal Method',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor),
            ),
            const SizedBox(height: 12),
            _buildMethodOption('bkash', 'bKash', Colors.pink),
            _buildMethodOption('nagad', 'Nagad', Colors.orange),
            _buildMethodOption('bank', 'Bank Transfer', Colors.blue),
            const SizedBox(height: 24),
            Text(
              'Account Details',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor),
            ),
            const SizedBox(height: 12),
            if (_selectedMethod == 'bank') ...[
              Autocomplete<String>(
                optionsBuilder: (TextEditingValue textEditingValue) {
                  if (textEditingValue.text.isEmpty) {
                    return _bangladeshBanks;
                  }
                  return _bangladeshBanks.where((String option) {
                    return option.toLowerCase().contains(textEditingValue.text.toLowerCase());
                  });
                },
                onSelected: (String selection) {
                  setState(() {
                    _selectedBank = selection;
                  });
                },
                fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) {
                  return TextField(
                    controller: textEditingController,
                    focusNode: focusNode,
                    style: TextStyle(color: textColor),
                    decoration: InputDecoration(
                      labelText: 'Search Bank',
                      labelStyle: TextStyle(color: hintColor),
                      prefixIcon: Icon(Icons.account_balance, color: hintColor),
                      filled: true,
                      fillColor: cardColor,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _receiverNameController,
                style: TextStyle(color: textColor),
                decoration: InputDecoration(
                  labelText: 'Receiver Name',
                  labelStyle: TextStyle(color: hintColor),
                  filled: true,
                  fillColor: cardColor,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _bankAccountController,
                keyboardType: TextInputType.number,
                style: TextStyle(color: textColor),
                decoration: InputDecoration(
                  labelText: 'Account Number',
                  labelStyle: TextStyle(color: hintColor),
                  filled: true,
                  fillColor: cardColor,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _routingNoController,
                      keyboardType: TextInputType.number,
                      style: TextStyle(color: textColor),
                      decoration: InputDecoration(
                        labelText: 'Routing No. (Optional)',
                        labelStyle: TextStyle(color: hintColor),
                        filled: true,
                        fillColor: cardColor,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _branchController,
                      style: TextStyle(color: textColor),
                      decoration: InputDecoration(
                        labelText: 'Branch (Optional)',
                        labelStyle: TextStyle(color: hintColor),
                        filled: true,
                        fillColor: cardColor,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                    ),
                  ),
                ],
              ),
            ] else ...[
              TextField(
                controller: _accountDetailsController,
                keyboardType: TextInputType.phone,
                style: TextStyle(color: textColor),
                decoration: InputDecoration(
                  hintText: 'Enter $_selectedMethod Account Number',
                  hintStyle: TextStyle(color: hintColor),
                  filled: true,
                  fillColor: cardColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ],
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
