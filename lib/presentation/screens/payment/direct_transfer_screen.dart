import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:agrolinkbd/core/services/transaction_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:agrolinkbd/core/models/user_model.dart';
import 'package:agrolinkbd/core/providers/language_provider.dart';
import 'package:flutter/services.dart';

class DirectTransferScreen extends StatefulWidget {
  final String senderId;

  const DirectTransferScreen({Key? key, required this.senderId}) : super(key: key);

  @override
  State<DirectTransferScreen> createState() => _DirectTransferScreenState();
}

class _DirectTransferScreenState extends State<DirectTransferScreen> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _reasonController = TextEditingController();
  final TextEditingController _accountNumberController = TextEditingController();
  final TransactionService _transactionService = TransactionService();
  
  List<UserModel> _recipients = [];
  List<UserModel> _filteredRecipients = [];
  UserModel? _selectedRecipient;
  String _selectedPaymentMethod = 'bKash';
  String _selectedReasonKey = 'machine';
  
  bool _isLoadingRecipients = true;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _fetchRecipients();
  }

  Future<void> _fetchRecipients() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('users').get();
          
      final users = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return UserModel.fromJson(data);
      }).where((user) => 
        user.userType == UserType.driver || 
        user.userType == UserType.serviceProvider
      ).toList();
      
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

  void _showRecipientSearchDialog(bool isBn) {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Container(
                constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.7),
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      isBn ? 'প্রাপক নির্বাচন করুন' : 'Select Recipient',
                      style: GoogleFonts.hindSiliguri(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      style: GoogleFonts.hindSiliguri(color: Colors.black87),
                      decoration: InputDecoration(
                        hintText: isBn ? 'নাম বা ফোন নম্বর দিয়ে খুঁজুন...' : 'Search by name or phone...',
                        hintStyle: GoogleFonts.hindSiliguri(color: Colors.grey.shade600),
                        prefixIcon: Icon(Icons.search, color: Colors.grey.shade600),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.green),
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
                              ? Center(
                                  child: Text(
                                    isBn ? 'কোনো ব্যবহারকারী পাওয়া যায়নি' : 'No users found',
                                    style: GoogleFonts.hindSiliguri(color: Colors.grey),
                                  ),
                                )
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
                                      title: Text(user.name, style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, color: Colors.black87)),
                                      subtitle: Text(
                                        '${user.phone} • ${isDriver ? (isBn ? 'ড্রাইভার' : 'Driver') : (isBn ? 'সার্ভিস প্রোভাইডার' : 'Service Provider')}',
                                        style: GoogleFonts.hindSiliguri(color: Colors.grey.shade700),
                                      ),
                                      onTap: () {
                                        setState(() {
                                          _selectedRecipient = user;
                                        });
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

  void _submitTransfer(bool isBn) async {
    if (_selectedRecipient == null) {
      Get.snackbar(
        isBn ? 'ত্রুটি' : 'Error',
        isBn ? 'প্রথমে একজন প্রাপক নির্বাচন করুন' : 'Please select a recipient first',
        backgroundColor: Colors.red.shade100,
      );
      return;
    }

    final accountNumber = _accountNumberController.text.trim();
    if (accountNumber.isEmpty) {
      Get.snackbar(
        isBn ? 'ত্রুটি' : 'Error',
        isBn ? 'প্রাপকের অ্যাকাউন্ট নম্বর দিন' : 'Please enter recipient account number',
        backgroundColor: Colors.red.shade100,
      );
      return;
    }

    if (_selectedPaymentMethod == 'bKash' || _selectedPaymentMethod == 'Nagad') {
      if (accountNumber.length < 11 || accountNumber.length > 14) {
        Get.snackbar(
          isBn ? 'ত্রুটি' : 'Error',
          isBn ? 'মোবাইল নম্বর ফরম্যাট সঠিক নয়' : 'Invalid mobile number format',
          backgroundColor: Colors.red.shade100,
        );
        return;
      }
    }

    if (_selectedPaymentMethod == 'Bank' && accountNumber.length > 16) {
      Get.snackbar(
        isBn ? 'ত্রুটি' : 'Error',
        isBn ? 'ব্যাংক হিসাব নম্বর ১৬ ডিজিটের বেশি হতে পারে না' : 'Bank account number cannot exceed 16 digits',
        backgroundColor: Colors.red.shade100,
      );
      return;
    }

    final amountText = _amountController.text.trim();
    if (amountText.isEmpty) {
      Get.snackbar(
        isBn ? 'ত্রুটি' : 'Error',
        isBn ? 'টাকার পরিমাণ উল্লেখ করুন' : 'Please enter an amount',
        backgroundColor: Colors.red.shade100,
      );
      return;
    }

    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) {
      Get.snackbar(
        isBn ? 'ত্রুটি' : 'Error',
        isBn ? 'সঠিক টাকার পরিমাণ দিন' : 'Please enter a valid amount',
        backgroundColor: Colors.red.shade100,
      );
      return;
    }

    final reasonMap = {
      'machine': isBn ? 'ট্রাক্টর / মেশিন ভাড়া' : 'Tractor / Machine Rental',
      'transport': isBn ? 'পরিবহন / ট্রাক ভাড়া' : 'Transport / Truck Fare',
      'labor': isBn ? 'কৃষি শ্রমিক মজুরি' : 'Labor Payment',
      'agri_inputs': isBn ? 'বীজ / সার / কীটনাশক' : 'Seeds / Fertilizer / Pesticide',
      'other': _reasonController.text.isNotEmpty ? _reasonController.text : (isBn ? 'সেবা বাবদ পেমেন্ট' : 'Payment for Services'),
    };

    final finalReason = reasonMap[_selectedReasonKey] ?? (isBn ? 'সেবা বাবদ পেমেন্ট' : 'Payment for Services');

    setState(() => _isProcessing = true);

    try {
      bool success = await _transactionService.requestTransfer(
        senderId: widget.senderId,
        receiverId: _selectedRecipient!.id,
        amount: amount,
        paymentMethod: _selectedPaymentMethod,
        accountNumber: accountNumber,
        reason: finalReason,
      );

      if (success) {
        Get.back();
        Get.snackbar(
          isBn ? 'সফল' : 'Success', 
          isBn ? 'ট্রান্সফার সফলভাবে অ্যাডমিন অনুমোদনের জন্য জমা দেওয়া হয়েছে।' : 'Transfer request submitted for Admin approval.',
          backgroundColor: Colors.green.shade100,
          colorText: Colors.green.shade900,
        );
      } else {
        Get.snackbar(
          isBn ? 'ব্যর্থ' : 'Failed',
          isBn ? 'পর্যাপ্ত ব্যালেন্স নেই বা ট্রান্সফার ব্যর্থ হয়েছে।' : 'Insufficient balance or transfer failed.',
          backgroundColor: Colors.red.shade100,
        );
      }
    } catch (e) {
      Get.snackbar(
        isBn ? 'ত্রুটি' : 'Error',
        '${isBn ? 'ট্রান্সফার ব্যর্থ হয়েছে:' : 'Transfer failed:'} $e',
        backgroundColor: Colors.red.shade100,
      );
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isBn = LanguageProvider.isBn(context);

    final reasonItems = [
      {'key': 'machine', 'label': isBn ? 'ট্রাক্টর / মেশিন ভাড়া' : 'Tractor / Machine Rental'},
      {'key': 'transport', 'label': isBn ? 'পরিবহন / ট্রাক ভাড়া' : 'Transport / Truck Fare'},
      {'key': 'labor', 'label': isBn ? 'কৃষি শ্রমিক মজুরি' : 'Labor Payment'},
      {'key': 'agri_inputs', 'label': isBn ? 'বীজ / সার / কীটনাশক' : 'Seeds / Fertilizer / Pesticide'},
      {'key': 'other', 'label': isBn ? 'অন্যান্য (বিবরণ দিন)' : 'Other (Please specify)'},
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(
          isBn ? 'সরাসরি পেমেন্ট' : 'Direct Transfer',
          style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF2E7D32),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isBn ? 'প্রাপক নির্বাচন করুন' : 'Select Recipient',
              style: GoogleFonts.hindSiliguri(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: _isLoadingRecipients ? null : () => _showRecipientSearchDialog(isBn),
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
                              style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
                            ),
                            Text(
                              _selectedRecipient!.phone,
                              style: GoogleFonts.hindSiliguri(color: Colors.grey.shade600, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      const Icon(Icons.person_search, color: Colors.grey),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _isLoadingRecipients 
                              ? (isBn ? 'প্রাপকদের লোড হচ্ছে...' : 'Loading recipients...')
                              : (isBn ? 'ড্রাইভার বা প্রোভাইডার খুঁজুন...' : 'Search for Driver or Provider...'),
                          style: GoogleFonts.hindSiliguri(color: Colors.grey.shade600, fontSize: 15),
                        ),
                      ),
                    ],
                    Icon(Icons.arrow_drop_down, color: Colors.grey.shade600),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              isBn ? 'পেমেন্টের কারণ / উদ্দেশ্য' : 'Reason / Purpose',
              style: GoogleFonts.hindSiliguri(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedReasonKey,
                  isExpanded: true,
                  items: reasonItems.map((item) {
                    return DropdownMenuItem(
                      value: item['key'],
                      child: Text(item['label']!, style: GoogleFonts.hindSiliguri(color: Colors.black87)),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedReasonKey = val);
                  },
                ),
              ),
            ),
            if (_selectedReasonKey == 'other') ...[
              const SizedBox(height: 12),
              TextField(
                controller: _reasonController,
                decoration: InputDecoration(
                  hintText: isBn ? 'কারণ লিখুন...' : 'Type your reason...',
                  hintStyle: GoogleFonts.hindSiliguri(color: Colors.grey.shade400),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
                style: GoogleFonts.hindSiliguri(color: Colors.black87),
              ),
            ],
            const SizedBox(height: 24),
            Text(
              isBn ? 'পেমেন্ট মেথড' : 'Payment Method',
              style: GoogleFonts.hindSiliguri(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedPaymentMethod,
                  isExpanded: true,
                  items: [
                    DropdownMenuItem(value: 'bKash', child: Text('bKash (বিকাশ)', style: GoogleFonts.hindSiliguri(color: Colors.black87))),
                    DropdownMenuItem(value: 'Nagad', child: Text('Nagad (নগদ)', style: GoogleFonts.hindSiliguri(color: Colors.black87))),
                    DropdownMenuItem(value: 'Bank', child: Text(isBn ? 'ব্যাংক ট্রান্সফার' : 'Bank Transfer', style: GoogleFonts.hindSiliguri(color: Colors.black87))),
                  ],
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedPaymentMethod = val);
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              isBn ? 'অ্যাকাউন্ট / মোবাইল নম্বর' : 'Account / Mobile Number',
              style: GoogleFonts.hindSiliguri(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _accountNumberController,
              keyboardType: TextInputType.phone,
              maxLength: _selectedPaymentMethod == 'Bank' ? 16 : 14,
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9+]'))],
              decoration: InputDecoration(
                counterText: '',
                hintText: isBn ? 'প্রাপকের অ্যাকাউন্ট নম্বর দিন' : 'Enter recipient number',
                hintStyle: GoogleFonts.hindSiliguri(color: Colors.grey.shade400),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
              ),
              style: GoogleFonts.hindSiliguri(color: Colors.black87),
            ),
            const SizedBox(height: 24),
            Text(
              isBn ? 'টাকার পরিমাণ' : 'Enter Amount',
              style: GoogleFonts.hindSiliguri(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                prefixText: '৳ ',
                hintText: isBn ? 'যেমন: ৫০০' : 'e.g. 500',
                hintStyle: GoogleFonts.hindSiliguri(color: Colors.grey.shade400),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
              ),
              style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _isProcessing ? null : () => _submitTransfer(isBn),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _isProcessing 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(
                      isBn ? 'পেমেন্ট সম্পন্ন করুন' : 'Transfer Now',
                      style: GoogleFonts.hindSiliguri(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
