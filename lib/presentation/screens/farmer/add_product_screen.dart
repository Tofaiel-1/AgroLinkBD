import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:agrolinkbd/core/providers/user_provider.dart';
import 'package:agrolinkbd/core/providers/language_provider.dart';
import 'package:agrolinkbd/core/utils/masked_identity_helper.dart';
import 'package:agrolinkbd/core/services/sslcommerz_service.dart';

/// Add Product Screen - Farmers can list new crops for sale with Super Class Monetization & Boosting options
class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cropController = TextEditingController();
  final _quantityController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _harvestDateController = TextEditingController();

  String _selectedCategory = 'vegetables';
  String? _selectedUnit = 'kg';
  String _selectedTier = 'free'; // 'free', 'urgent', 'featured', 'vip'
  String _qualityGrade = 'grade_a';
  final List<XFile> _pickedImages = [];
  bool _isSubmitting = false;
  DateTime? _harvestDate;

  // Category options
  final List<Map<String, String>> _categories = [
    {'labelBn': 'সবজি 🥦', 'labelEn': 'Vegetables 🥦', 'value': 'vegetables'},
    {'labelBn': 'ফল 🍎', 'labelEn': 'Fruits 🍎', 'value': 'fruits'},
    {'labelBn': 'শস্য/ধান 🌾', 'labelEn': 'Grains/Rice 🌾', 'value': 'grains'},
    {'labelBn': 'ডাল 🫘', 'labelEn': 'Pulses 🫘', 'value': 'pulses'},
    {'labelBn': 'মসলা 🌶️', 'labelEn': 'Spices 🌶️', 'value': 'spices'},
    {'labelBn': 'মাছ 🐟', 'labelEn': 'Fish 🐟', 'value': 'fish'},
    {'labelBn': 'ফুল 🌸', 'labelEn': 'Flowers 🌸', 'value': 'flowers'},
    {'labelBn': 'অন্যান্য', 'labelEn': 'Other', 'value': 'other'},
  ];

  final List<Map<String, String>> _units = [
    {'value': 'kg', 'labelBn': 'কেজি', 'labelEn': 'kg'},
    {'value': 'maund', 'labelBn': 'মণ', 'labelEn': 'maund'},
    {'value': 'liter', 'labelBn': 'লিটার', 'labelEn': 'liter'},
    {'value': 'piece', 'labelBn': 'পিস', 'labelEn': 'piece'},
    {'value': 'ton', 'labelBn': 'টন', 'labelEn': 'ton'},
  ];

  final List<Map<String, String>> _grades = [
    {'value': 'grade_a', 'labelBn': 'Grade A (প্রিমিয়াম - রপ্তানিযোগ্য)', 'labelEn': 'Grade A (Premium - Export Quality)'},
    {'value': 'grade_b', 'labelBn': 'Grade B (স্ট্যান্ডার্ড বাজার মান)', 'labelEn': 'Grade B (Standard Market Quality)'},
    {'value': 'grade_c', 'labelBn': 'Grade C (সাধারণ পাইকারি মান)', 'labelEn': 'Grade C (Standard Wholesale)'},
  ];

  @override
  void dispose() {
    _cropController.dispose();
    _quantityController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _harvestDateController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final bool isBn = LanguageProvider.isBn(context);
    if (_pickedImages.length >= 5) {
      Get.snackbar(
        isBn ? 'সর্বোচ্চ ৫টি' : 'Max 5 Photos',
        isBn ? 'আপনি সর্বোচ্চ ৫টি ছবি যোগ করতে পারবেন' : 'You can upload up to 5 photos maximum',
      );
      return;
    }

    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isBn ? 'ছবি নির্বাচন করুন' : 'Select Photo',
              style: GoogleFonts.hindSiliguri(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Color(0xFF2E7D32)),
              title: Text(isBn ? 'ক্যামেরা থেকে তুলুন' : 'Take Photo with Camera', style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.w600)),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Color(0xFF2E7D32)),
              title: Text(isBn ? 'গ্যালারি থেকে নিন' : 'Choose from Gallery', style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.w600)),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (source == null) return;

    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: source,
      imageQuality: 70,
      maxWidth: 1024,
    );

    if (image != null) {
      setState(() => _pickedImages.add(image));
    }
  }

  Future<List<String>> _uploadImages(String productId) async {
    final List<String> urls = [];
    for (int i = 0; i < _pickedImages.length; i++) {
      final ref = FirebaseStorage.instance
          .ref()
          .child('product_images')
          .child('${productId}_$i.jpg');
      await ref.putFile(File(_pickedImages[i].path));
      final url = await ref.getDownloadURL();
      urls.add(url);
    }
    return urls;
  }

  Future<void> _submitProduct() async {
    final bool isBn = LanguageProvider.isBn(context);
    if (!_formKey.currentState!.validate()) {
      Get.snackbar(
        isBn ? 'তথ্য অসম্পূর্ণ' : 'Incomplete Form',
        isBn ? 'অনুগ্রহ করে ফসলের নাম, পরিমাণ ও দর সঠিকভাবে পূরণ করুন।' : 'Please fill in crop name, quantity, and price properly.',
        backgroundColor: Colors.orange.shade800,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      final user = FirebaseAuth.instance.currentUser;
      final userId = user?.uid ?? 'demo_farmer';
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final userModel = userProvider.currentUser;

      double boostPrice = 0.0;
      int boostDays = 0;
      String tierName = 'Boost';
      String boostTxnId = 'BOOST_${DateTime.now().millisecondsSinceEpoch}';

      // Check if Paid Boost Tier is selected
      if (_selectedTier != 'free') {
        if (_selectedTier == 'urgent') {
          boostPrice = 20.0;
          boostDays = 3;
          tierName = 'Urgent Sale Boost (৩ দিন)';
        } else if (_selectedTier == 'featured') {
          boostPrice = 50.0;
          boostDays = 7;
          tierName = 'Premium Featured Lot (৭ দিন)';
        } else if (_selectedTier == 'vip') {
          boostPrice = 100.0;
          boostDays = 15;
          tierName = 'VIP Wholesaler Partner (১৫ দিন)';
        }

        final paymentSuccess = await SSLCommerzService.initiatePayment(
          context: context,
          amount: boostPrice,
          productName: 'পণ্য বুস্টিং: $tierName (${_cropController.text.trim()})',
          customerName: userModel?.name ?? 'Farmer User',
          customerEmail: user?.email ?? 'farmer@agrolinkbd.com',
          customerPhone: userModel?.phone ?? (user?.phoneNumber ?? '01700000000'),
          customerAddress: '${userModel?.upazila ?? 'সদর'}, ${userModel?.district ?? 'বাংলাদেশ'}',
        );

        if (!paymentSuccess) {
          if (mounted) {
            Get.snackbar(
              isBn ? 'পেমেন্ট সম্পন্ন হয়নি' : 'Payment Cancelled',
              isBn ? 'বুস্টিং পেমেন্ট সম্পন্ন না হওয়ায় পণ্য প্রকাশ স্থগিত রাখা হয়েছে।' : 'Product listing paused as boost payment was not completed.',
              backgroundColor: Colors.orange.shade800,
              colorText: Colors.white,
              snackPosition: SnackPosition.BOTTOM,
            );
          }
          return;
        }
      }

      setState(() => _isSubmitting = true);

      final docRef = FirebaseFirestore.instance.collection('products').doc();

      List<String> imageUrls = [];
      if (_pickedImages.isNotEmpty) {
        try {
          imageUrls = await _uploadImages(docRef.id);
        } catch (e) {
          debugPrint('Image upload error: $e');
        }
      }

      final maskedSellerName = MaskedIdentityHelper.getMaskedFarmerName(
        userId: userId,
        district: userModel?.district,
        upazila: userModel?.upazila,
        fallbackName: userModel?.name ?? 'কৃষক',
      );

      final batchCode = MaskedIdentityHelper.generateBatchCode();
      final DateTime now = DateTime.now();
      final DateTime? boostExpiresDate = _selectedTier != 'free' ? now.add(Duration(days: boostDays)) : null;

      final productData = {
        'id': docRef.id,
        'title': _cropController.text.trim(),
        'cropName': _cropController.text.trim(),
        'sellerId': userId,
        'farmerId': userId,
        'sellerName': userModel?.name ?? 'কৃষক',
        'farmerName': userModel?.name ?? 'কৃষক',
        'maskedSellerName': maskedSellerName,
        'district': userModel?.district ?? 'বগুড়া',
        'upazila': userModel?.upazila ?? 'সদর',
        'location': '${userModel?.upazila ?? 'সদর'}, ${userModel?.district ?? 'বগুড়া'} হাব',
        'category': _selectedCategory ?? 'vegetables',
        'quantity': double.tryParse(_quantityController.text) ?? 0.0,
        'unit': _selectedUnit ?? 'কেজি',
        'price': double.tryParse(_priceController.text) ?? 0.0,
        'pricePerUnit': double.tryParse(_priceController.text) ?? 0.0,
        'description': _descriptionController.text.trim(),
        'qualityGrade': _qualityGrade,
        'boostTier': _selectedTier,
        'isFeatured': _selectedTier != 'free',
        'boostPaid': _selectedTier != 'free',
        'boostAmount': boostPrice,
        'boostDurationDays': boostDays,
        'boostStatus': _selectedTier != 'free' ? 'active' : 'none',
        'boostPaymentMethod': _selectedTier != 'free' ? 'SSLCommerz' : null,
        'boostTransactionId': _selectedTier != 'free' ? boostTxnId : null,
        'boostActivatedAt': _selectedTier != 'free' ? FieldValue.serverTimestamp() : null,
        'boostExpiresAt': boostExpiresDate != null ? Timestamp.fromDate(boostExpiresDate) : null,
        'escrowProtected': true,
        'batchCode': batchCode,
        'harvestDate': _harvestDate != null ? Timestamp.fromDate(_harvestDate!) : null,
        'images': imageUrls,
        'status': 'ProductStatus.available',
        'views': 0,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await docRef.set(productData);

      // Save Boost Transaction to Database
      if (_selectedTier != 'free') {
        final Map<String, dynamic> boostTxnData = {
          'id': boostTxnId,
          'userId': userId,
          'type': 'debit',
          'amount': boostPrice,
          'title': isBn ? 'পণ্য বুস্টিং ($tierName)' : 'Product Boost ($tierName)',
          'description': 'Crop: ${_cropController.text.trim()} (ID: ${docRef.id})',
          'paymentId': boostTxnId,
          'relatedId': docRef.id,
          'relatedType': 'product_boost',
          'status': 'completed',
          'paymentMethod': 'SSLCommerz',
          'createdAt': now.toIso8601String(),
          'timestamp': FieldValue.serverTimestamp(),
          'metadata': {
            'productId': docRef.id,
            'cropName': _cropController.text.trim(),
            'boostTier': _selectedTier,
            'boostDays': boostDays,
            'amount': boostPrice,
            'farmerName': userModel?.name ?? 'Farmer User',
            'farmerPhone': userModel?.phone ?? (user?.phoneNumber ?? ''),
          },
        };

        // Write to global transactions collection for wallet/financial logs
        await FirebaseFirestore.instance.collection('transactions').doc(boostTxnId).set(boostTxnData);

        // Write to user specific boost logs
        await FirebaseFirestore.instance.collection('boost_payments').doc(boostTxnId).set({
          'id': boostTxnId,
          'productId': docRef.id,
          'cropName': _cropController.text.trim(),
          'farmerId': userId,
          'farmerName': userModel?.name ?? 'Farmer',
          'amount': boostPrice,
          'tier': _selectedTier,
          'durationDays': boostDays,
          'paymentMethod': 'SSLCommerz',
          'status': 'paid',
          'createdAt': FieldValue.serverTimestamp(),
          'expiresAt': Timestamp.fromDate(boostExpiresDate!),
        });
      }

      if (mounted) {
        Get.back();
        Get.snackbar(
          isBn ? '✅ পণ্য মার্কেটে প্রকাশিত!' : '✅ Crop Listed on Market!',
          isBn
              ? '"${_cropController.text}" ${_selectedTier != 'free' ? 'বুস্টসহ' : ''} সফলভাবে তালিকাভুক্ত হয়েছে।'
              : '"${_cropController.text}" ${_selectedTier != 'free' ? 'with Boost' : ''} listed successfully.',
          backgroundColor: const Color(0xFF2E7D32),
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      if (mounted) {
        Get.snackbar(
          isBn ? 'ত্রুটি হয়েছে' : 'Error',
          isBn ? 'পণ্য যোগ করতে সমস্যা: $e' : 'Failed to add crop: $e',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryGreen = Color(0xFF2E7D32);
    final bool isBn = LanguageProvider.isBn(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: primaryGreen,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          isBn ? 'পণ্য বিক্রয়ে দিন 🌾' : 'Sell Your Crop 🌾',
          style: GoogleFonts.hindSiliguri(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Escrow Protection Info Header
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.green.shade300),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.shield_outlined, color: primaryGreen, size: 24),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        isBn
                            ? '🔒 এগ্রোলিংক সুরক্ষিত এস্ক্রো: আপনার পণ্য প্রকাশের পর বায়ার ১০০% টাকা অগ্রিম জমা রাখবে। ওটিপি যাচাইয়ের সাথে সাথে আপনার ওয়ালেটে ৯৭% নেট মূল্য পৌঁছে যাবে।'
                            : '🔒 AgroLink Secure Escrow: Buyers deposit 100% upfront in escrow. Once delivery OTP is verified, 97% net amount is instantly credited to your wallet.',
                        style: GoogleFonts.hindSiliguri(
                          fontSize: 12,
                          color: const Color(0xFF1B5E20),
                          fontWeight: FontWeight.w600,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Crop Name
              _sectionLabel(isBn ? 'ফসলের নাম *' : 'Crop Name *'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _cropController,
                decoration: _inputDeco(
                  hint: isBn ? 'যেমন: গোল আলু, দেশি টমেটো' : 'e.g., Round Potato, Local Tomato',
                  icon: Icons.agriculture,
                ),
                style: GoogleFonts.hindSiliguri(fontSize: 16),
                validator: (v) => (v == null || v.isEmpty) ? (isBn ? 'ফসলের নাম দিন' : 'Enter crop name') : null,
              ),
              const SizedBox(height: 16),

              // Category Selector
              _sectionLabel(isBn ? 'ক্যাটাগরি *' : 'Category *'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _categories.map((cat) {
                  final isSelected = _selectedCategory == cat['value'];
                  final label = isBn ? cat['labelBn']! : cat['labelEn']!;
                  return ChoiceChip(
                    label: Text(
                      label,
                      style: GoogleFonts.hindSiliguri(
                        color: isSelected ? Colors.white : Colors.black87,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        fontSize: 13,
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: primaryGreen,
                    backgroundColor: Colors.white,
                    side: BorderSide(
                      color: isSelected ? primaryGreen : Colors.grey.shade300,
                    ),
                    onSelected: (selected) {
                      if (selected) {
                        setState(() => _selectedCategory = cat['value']!);
                      }
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // Quality Grade
              _sectionLabel(isBn ? 'পণ্যের কোয়ালিটি গ্রেড *' : 'Quality Grade *'),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                decoration: _inputDeco(
                  hint: isBn ? 'গ্রেড নির্বাচন করুন' : 'Select Grade',
                  icon: Icons.verified_outlined,
                ),
                initialValue: _qualityGrade,
                dropdownColor: Colors.white,
                isExpanded: true,
                icon: const Icon(Icons.keyboard_arrow_down_rounded, color: primaryGreen, size: 24),
                items: _grades
                    .map((g) => DropdownMenuItem(
                          value: g['value'],
                          child: Row(
                            children: [
                              Icon(
                                g['value'] == 'grade_a'
                                    ? Icons.stars_rounded
                                    : (g['value'] == 'grade_b' ? Icons.check_circle_rounded : Icons.inventory_2_outlined),
                                size: 18,
                                color: g['value'] == 'grade_a'
                                    ? Colors.amber.shade800
                                    : (g['value'] == 'grade_b' ? primaryGreen : Colors.blueGrey),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  isBn ? g['labelBn']! : g['labelEn']!,
                                  style: GoogleFonts.hindSiliguri(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF1E293B),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => _qualityGrade = v ?? _grades.first['value']!),
                style: GoogleFonts.hindSiliguri(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 16),

              // Quantity + Unit (Fixed 8.0px overflow with isExpanded and optimized flex ratios)
              _sectionLabel(isBn ? 'পরিমাণ ও একক *' : 'Quantity & Unit *'),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: TextFormField(
                      controller: _quantityController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: _inputDeco(
                        hint: isBn ? 'যেমন: ৫০০' : 'e.g., 500',
                        icon: Icons.scale,
                      ),
                      style: GoogleFonts.hindSiliguri(fontSize: 15, fontWeight: FontWeight.w600, color: const Color(0xFF1E293B)),
                      validator: (v) => (v == null || v.isEmpty) ? (isBn ? 'পরিমাণ দিন' : 'Enter quantity') : null,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: DropdownButtonFormField<String>(
                      isExpanded: true,
                      dropdownColor: Colors.white,
                      icon: const Icon(Icons.arrow_drop_down, color: primaryGreen),
                      decoration: InputDecoration(
                        hintText: isBn ? 'একক' : 'Unit',
                        hintStyle: GoogleFonts.hindSiliguri(color: Colors.grey.shade400, fontSize: 13),
                        prefixIcon: Icon(Icons.straighten, color: Colors.grey.shade600, size: 18),
                        prefixIconConstraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                        filled: true,
                        fillColor: Colors.white,
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
                          borderSide: const BorderSide(color: Color(0xFF2E7D32), width: 2),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
                      ),
                      initialValue: _selectedUnit,
                      items: _units
                          .map((u) => DropdownMenuItem(
                                value: u['value'],
                                child: Text(
                                  isBn ? u['labelBn']! : u['labelEn']!,
                                  style: GoogleFonts.hindSiliguri(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF1E293B),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ))
                          .toList(),
                      onChanged: (v) => setState(() => _selectedUnit = v),
                      style: GoogleFonts.hindSiliguri(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Price
              _sectionLabel(isBn ? 'প্রতি একক মূল্য (৳) *' : 'Price per Unit (৳) *'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _priceController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: _inputDeco(
                  hint: isBn ? 'প্রতি দর (টাকা)' : 'Price (BDT)',
                  icon: Icons.currency_exchange_rounded,
                ),
                style: GoogleFonts.hindSiliguri(fontSize: 16),
                validator: (v) => (v == null || v.isEmpty) ? (isBn ? 'মূল্য দিন' : 'Enter price') : null,
              ),
              const SizedBox(height: 16),

              // Harvest Date
              _sectionLabel(isBn ? 'ফসল কাটার তারিখ' : 'Harvest Date'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _harvestDateController,
                readOnly: true,
                decoration: _inputDeco(
                  hint: isBn ? 'তারিখ নির্বাচন করুন' : 'Select Date',
                  icon: Icons.calendar_today,
                ).copyWith(
                  suffixIcon: const Icon(Icons.calendar_month, color: primaryGreen),
                ),
                style: GoogleFonts.hindSiliguri(fontSize: 16),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now().subtract(const Duration(days: 30)),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                    builder: (ctx, child) => Theme(
                      data: Theme.of(ctx).copyWith(
                        colorScheme: const ColorScheme.light(primary: primaryGreen),
                      ),
                      child: child!,
                    ),
                  );
                  if (date != null && mounted) {
                    setState(() {
                      _harvestDate = date;
                      _harvestDateController.text = '${date.day}/${date.month}/${date.year}';
                    });
                  }
                },
              ),
              const SizedBox(height: 16),

              // Description
              _sectionLabel(isBn ? 'বিবরণ (ঐচ্ছিক)' : 'Description (Optional)'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: _inputDeco(
                  hint: isBn ? 'ফসলের জাত, রঙ, বিশেষ বৈশিষ্ট্য ইত্যাদি লিখুন...' : 'Write crop variety, color, special qualities...',
                  icon: Icons.description,
                ),
                style: GoogleFonts.hindSiliguri(fontSize: 15),
              ),
              const SizedBox(height: 20),

              // Photo Upload
              _sectionLabel(isBn ? 'ছবি যোগ করুন (সর্বোচ্চ ৫টি)' : 'Add Photos (Max 5)'),
              const SizedBox(height: 8),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childAspectRatio: 1,
                ),
                itemCount: _pickedImages.length < 5 ? _pickedImages.length + 1 : _pickedImages.length,
                itemBuilder: (context, index) {
                  if (index == _pickedImages.length) {
                    return GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: primaryGreen.withValues(alpha: 0.4), width: 2),
                          borderRadius: BorderRadius.circular(12),
                          color: primaryGreen.withValues(alpha: 0.05),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_a_photo, color: primaryGreen.withValues(alpha: 0.8), size: 28),
                            const SizedBox(height: 4),
                            Text(
                              isBn ? 'ছবি যোগ' : 'Add Photo',
                              style: GoogleFonts.hindSiliguri(
                                fontSize: 12,
                                color: primaryGreen,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          File(_pickedImages[index].path),
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () => setState(() => _pickedImages.removeAt(index)),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                            child: const Icon(Icons.close, size: 14, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),

              // ==============================================
              // SUPER CLASS MONETIZED BOOSTING PLANS
              // ==============================================
              _sectionLabel(isBn ? 'পণ্য প্রমোশন ও বুস্টিং প্ল্যান 🚀' : 'Product Promotion & Boost Plans 🚀'),
              const SizedBox(height: 4),
              Text(
                isBn
                    ? 'দ্রুত বিক্রি করতে ও বড় পাইকারদের দৃষ্টি আকর্ষণ করতে বুস্ট নির্বাচন করুন:'
                    : 'Choose a boost tier to sell faster and reach major wholesalers:',
                style: GoogleFonts.hindSiliguri(fontSize: 12, color: Colors.grey.shade700),
              ),
              const SizedBox(height: 12),

              _buildBoostCard(
                tier: 'free',
                title: isBn ? 'সাধারণ লিস্টিং' : 'Standard Listing',
                subtitle: isBn ? 'রেগুলার মার্কেটপ্লেস ফিডে বিনামূল্যে প্রদর্শিত হবে' : 'Free display in regular marketplace feed',
                price: isBn ? 'বিনামূল্যে (৳০)' : 'Free (৳0)',
                icon: Icons.check_circle_outline,
                color: Colors.grey.shade700,
                badgeText: isBn ? 'ফ্রি' : 'Free',
              ),
              const SizedBox(height: 10),

              _buildBoostCard(
                tier: 'urgent',
                title: isBn ? 'জরুরি বিক্রি বুস্ট ⚡' : 'Urgent Sale Boost ⚡',
                subtitle: isBn ? '৩ দিন "Urgent Sale" লাল ব্যাজ ও সবার উপরে থাকবে' : '3 days with "Urgent Sale" red badge on top',
                price: isBn ? '৳ ২০ / ৩ দিন' : '৳ 20 / 3 Days',
                icon: Icons.bolt,
                color: Colors.red.shade600,
                badgeText: isBn ? 'জনপ্রিয়' : 'Popular',
              ),
              const SizedBox(height: 10),

              _buildBoostCard(
                tier: 'featured',
                title: isBn ? 'প্রিমিয়াম ফিচার্ড লট 👑' : 'Premium Featured Lot 👑',
                subtitle: isBn ? '৭ দিন হোমপেজ গোল্ডেন ব্যানারে এবং টপ লিস্টিংয়ে থাকবে' : '7 days on homepage golden banner & top lots',
                price: isBn ? '৳ ৫০ / ৭ দিন' : '৳ 50 / 7 Days',
                icon: Icons.workspace_premium_rounded,
                color: Colors.amber.shade800,
                badgeText: isBn ? 'বেস্ট ভ্যালু' : 'Best Value',
              ),
              const SizedBox(height: 10),

              _buildBoostCard(
                tier: 'vip',
                title: isBn ? 'ভিআইপি হোলসেলার পার্টনার 💎' : 'VIP Wholesaler Partner 💎',
                subtitle: isBn ? '১৫ দিন ঢাকার শীর্ষ আড়তদার ও বড় ক্রেতাদের এসএমএস অ্যালার্ট' : '15 days SMS alert to top commission agents & bulk buyers',
                price: isBn ? '৳ ১০০ / ১৫ দিন' : '৳ 100 / 15 Days',
                icon: Icons.diamond_rounded,
                color: const Color(0xFF1976D2),
                badgeText: isBn ? 'ভিআইপি' : 'VIP',
              ),
              const SizedBox(height: 16),

              // SSL Payment Summary Card when Paid Tier is Selected
              if (_selectedTier != 'free') ...[
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF1E3A8A).withValues(alpha: 0.08),
                        const Color(0xFF3B82F6).withValues(alpha: 0.05),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFF3B82F6).withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E3A8A),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.payment_rounded, color: Colors.white, size: 18),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              isBn ? '💳 SSLCommerz পেমেন্ট বিবরণী' : '💳 SSLCommerz Payment Details',
                              style: GoogleFonts.hindSiliguri(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF1E3A8A),
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2E7D32).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.lock, size: 12, color: Color(0xFF2E7D32)),
                                const SizedBox(width: 4),
                                Text(
                                  isBn ? '১০০% নিরাপদ' : '100% Secure',
                                  style: GoogleFonts.hindSiliguri(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF2E7D32),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            isBn ? 'নির্বাচিত বুস্ট প্ল্যান:' : 'Selected Boost Plan:',
                            style: GoogleFonts.hindSiliguri(fontSize: 13, color: Colors.grey.shade700),
                          ),
                          Text(
                            _selectedTier == 'urgent'
                                ? (isBn ? 'জরুরি বিক্রি বুস্ট (৩ দিন)' : 'Urgent Sale (3 Days)')
                                : _selectedTier == 'featured'
                                    ? (isBn ? 'প্রিমিয়াম লট (৭ দিন)' : 'Premium Lot (7 Days)')
                                    : (isBn ? 'ভিআইপি পার্টনার (১৫ দিন)' : 'VIP Partner (15 Days)'),
                            style: GoogleFonts.hindSiliguri(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            isBn ? 'পেমেন্ট মেথড:' : 'Payment Method:',
                            style: GoogleFonts.hindSiliguri(fontSize: 13, color: Colors.grey.shade700),
                          ),
                          Text(
                            isBn ? 'SSLCommerz (বিকাশ, নগদ, রকেট, কার্ড)' : 'SSLCommerz (bKash, Nagad, Cards)',
                            style: GoogleFonts.hindSiliguri(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF2563EB),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            isBn ? 'মোট প্রদেয় ফি:' : 'Total Payable Fee:',
                            style: GoogleFonts.hindSiliguri(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                          Text(
                            _selectedTier == 'urgent'
                                ? '৳ ২০.০০'
                                : _selectedTier == 'featured'
                                    ? '৳ ৫০.০০'
                                    : '৳ ১০০.০০',
                            style: GoogleFonts.hindSiliguri(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF2E7D32),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],

              const SizedBox(height: 12),

              // Submit & SSL Payment Button
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: _isSubmitting ? null : _submitProduct,
                  icon: _isSubmitting
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                        )
                      : Icon(
                          _selectedTier != 'free' ? Icons.payment_rounded : Icons.storefront_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                  label: Text(
                    _isSubmitting
                        ? (isBn ? 'প্রক্রিয়াধীন...' : 'Processing...')
                        : (_selectedTier != 'free'
                            ? (isBn
                                ? 'SSL পেমেন্ট করুন ও বুস্টসহ প্রকাশ করুন (${_selectedTier == 'urgent' ? '৳২০' : _selectedTier == 'featured' ? '৳৫০' : '৳১০০'})'
                                : 'Pay ${_selectedTier == 'urgent' ? '৳20' : _selectedTier == 'featured' ? '৳50' : '৳100'} via SSL & Publish')
                            : (isBn ? 'পণ্য মার্কেটে প্রকাশ করুন' : 'Publish Crop to Market')),
                    style: GoogleFonts.hindSiliguri(
                      fontSize: 15.5,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _selectedTier != 'free'
                        ? (_selectedTier == 'urgent'
                            ? const Color(0xFFD32F2F)
                            : _selectedTier == 'featured'
                                ? const Color(0xFFD97706)
                                : const Color(0xFF1D4ED8))
                        : primaryGreen,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: _selectedTier != 'free' ? 5 : 3,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Supported Payment Gateways Footer
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.verified_user_outlined, size: 14, color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Text(
                      isBn
                          ? 'SSLCommerz সুরক্ষিত গেটওয়ে: বিকাশ • নগদ • রকেট • কার্ড • ভিসা'
                          : 'Secured by SSLCommerz: bKash • Nagad • Rocket • Cards • Visa',
                      style: GoogleFonts.hindSiliguri(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBoostCard({
    required String tier,
    required String title,
    required String subtitle,
    required String price,
    required IconData icon,
    required Color color,
    required String badgeText,
  }) {
    final isSelected = _selectedTier == tier;

    return GestureDetector(
      onTap: () => setState(() => _selectedTier = tier),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.06) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [BoxShadow(color: color.withValues(alpha: 0.15), blurRadius: 10, offset: const Offset(0, 4))]
              : [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 4, offset: const Offset(0, 2))],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          title,
                          style: GoogleFonts.hindSiliguri(
                            fontSize: 13.5,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          badgeText,
                          style: GoogleFonts.hindSiliguri(
                            fontSize: 9.5,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            height: 1.1,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.hindSiliguri(fontSize: 11, color: Colors.grey.shade700, height: 1.2),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  price,
                  style: GoogleFonts.hindSiliguri(
                    fontSize: 12.5,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 3),
                Icon(
                  isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                  color: isSelected ? color : Colors.grey.shade400,
                  size: 18,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String label) {
    return Text(
      label,
      style: GoogleFonts.hindSiliguri(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: Colors.black87,
      ),
    );
  }

  InputDecoration _inputDeco({required String hint, required IconData icon}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.hindSiliguri(color: Colors.grey.shade400, fontSize: 14),
      prefixIcon: Icon(icon, color: Colors.grey.shade500, size: 20),
      filled: true,
      fillColor: Colors.white,
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
        borderSide: const BorderSide(color: Color(0xFF2E7D32), width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
}
