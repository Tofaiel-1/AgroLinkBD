import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:agrolinkbd/core/services/transaction_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:agrolinkbd/core/models/user_model.dart';

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
  
  List<UserModel> _recipients = [];
  List<UserModel> _filteredRecipients = [];
  UserModel? _selectedRecipient;
  
  bool _isLoadingRecipients = true;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _fetchRecipients();
  }

  Future<void> _fetchRecipients() async {
    try {
      // Fetch drivers
      final driverSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('userType', isEqualTo: 'UserType.driver')
          .get();
          
      // Fetch service providers
      final providerSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('userType', isEqualTo: 'UserType.serviceProvider')
          .get();
          
      final allDocs = [...driverSnapshot.docs, ...providerSnapshot.docs];
      
      final users = allDocs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return UserModel.fromJson(data);
      }).toList();
      
      setState(() {
        _recipients = users;
        _filteredRecipients = users;
        _isLoadingRecipients = false;
      });
    } catch (e) {
      debugPrint('Error fetching recipients: $e');
      setState(() {
        _isLoadingRecipients = false;
      });
    }
  }

  void _showRecipientSearchDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Container(
                constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.7),
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Select Recipient',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      decoration: InputDecoration(
                        hintText: 'Search by name or phone...',
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      onChanged: (query) {
                        setDialogState(() {
                          if (query.isEmpty) {
                            _filteredRecipients = _recipients;
                          } else {
                            _filteredRecipients = _recipients.where((user) {
                              return user.name.toLowerCase().contains(query.toLowerCase()) ||
                                     user.phone.contains(query);
                            }).toList();
                          }
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: _isLoadingRecipients
                          ? const Center(child: CircularProgressIndicator())
                          : _filteredRecipients.isEmpty
                              ? const Center(child: Text('No users found', style: TextStyle(color: Colors.grey)))
                              : ListView.builder(
                                  itemCount: _filteredRecipients.length,
                                  itemBuilder: (context, index) {
                                    final user = _filteredRecipients[index];
                                    final isDriver = user.userType == UserType.driver;
                                    
                                    return ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor: isDriver ? Colors.blue.shade100 : Colors.orange.shade100,
                                        child: Icon(
                                          isDriver ? Icons.local_shipping : Icons.handyman,
                                          color: isDriver ? Colors.blue.shade800 : Colors.orange.shade800,
                                        ),
                                      ),
                                      title: Text(user.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                      subtitle: Text('${user.phone} • ${isDriver ? 'Driver' : 'Service Provider'}'),
                                      onTap: () {
                                        setState(() {
                                          _selectedRecipient = user;
                                        });
                                        // Reset filter for next time
                                        _filteredRecipients = _recipients;
                                        Navigator.pop(context);
                                      },
                                    );
                                  },
                                ),
                    ),
                  ],
                ),
              ),
            );
          }
        );
      },
    );
  }

  void _submitTransfer() async {
    if (_selectedRecipient == null) {
      Get.snackbar('Error', 'Please select a recipient first', backgroundColor: Colors.red.shade100);
      return;
    }

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
        receiverId: _selectedRecipient!.id,
        amount: amount,
        reason: _reasonController.text.isNotEmpty ? _reasonController.text : 'Payment for Services',
      );

      if (success) {
        Get.back();
        Get.snackbar(
          'Success', 
          'Transferred ৳$amount to ${_selectedRecipient!.name} successfully.',
          backgroundColor: Colors.green.shade100,
          colorText: Colors.green.shade900,
        );
      } else {
        Get.snackbar('Failed', 'Insufficient balance or transfer failed.', backgroundColor: Colors.red.shade100);
      }
    } catch (e) {
      Get.snackbar('Error', 'Transfer failed: $e', backgroundColor: Colors.red.shade100);
    } finally {
      if (mounted) setState(() => _isProcessing = false);
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
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: _isLoadingRecipients ? null : _showRecipientSearchDialog,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  children: [
                    if (_selectedRecipient != null) ...[
                      Icon(
                        _selectedRecipient!.userType == UserType.driver ? Icons.local_shipping : Icons.handyman,
                        color: Colors.green.shade700,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _selectedRecipient!.name,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
                            ),
                            Text(
                              _selectedRecipient!.phone,
                              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      const Icon(Icons.person_search, color: Colors.grey),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _isLoadingRecipients ? 'Loading recipients...' : 'Search for Driver or Provider...',
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                        ),
                      ),
                    ],
                    Icon(Icons.arrow_drop_down, color: Colors.grey.shade600),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Enter Amount',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
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
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 24),
            const Text(
              'Reason / Purpose',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
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
              style: const TextStyle(color: Colors.black87),
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
