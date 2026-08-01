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

/// Add Product Screen - Farmers can list new crops for sale
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

  String? _selectedCategory;
  String? _selectedUnit;
  final List<XFile> _pickedImages = [];
  bool _isSubmitting = false;
  DateTime? _harvestDate;

  // Category options
  final List<Map<String, String>> _categories = [
    {'label': 'সবজি 🥦', 'value': 'vegetables'},
    {'label': 'ফল 🍎', 'value': 'fruits'},
    {'label': 'শস্য/ধান 🌾', 'value': 'grains'},
    {'label': 'ডাল 🫘', 'value': 'pulses'},
    {'label': 'মসলা 🌶️', 'value': 'spices'},
    {'label': 'মাছ 🐟', 'value': 'fish'},
    {'label': 'ফুল 🌸', 'value': 'flowers'},
    {'label': 'অন্যান্য', 'value': 'other'},
  ];

  final List<String> _units = ['কেজি', 'মণ', 'লিটার', 'পিস', 'টন'];

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
    if (_pickedImages.length >= 5) {
      Get.snackbar('সর্বোচ্চ ৫টি', 'আপনি সর্বোচ্চ ৫টি ছবি যোগ করতে পারবেন');
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
              'ছবি নিন',
              style: GoogleFonts.hindSiliguri(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Color(0xFF2E7D32)),
              title: Text('ক্যামেরা থেকে', style: GoogleFonts.hindSiliguri()),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Color(0xFF2E7D32)),
              title: Text('গ্যালারি থেকে', style: GoogleFonts.hindSiliguri()),
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

    if (image != null && mounted) {
      setState(() {
        _pickedImages.add(image);
      });
    }
  }

  Future<List<String>> _uploadImages(String productId) async {
    final List<String> urls = [];
    for (int i = 0; i < _pickedImages.length; i++) {
      final file = File(_pickedImages[i].path);
      final ref = FirebaseStorage.instance
          .ref()
          .child('products/$productId/image_$i.jpg');
      final uploadTask = await ref.putFile(file);
      final url = await uploadTask.ref.getDownloadURL();
      urls.add(url);
    }
    return urls;
  }

  Future<void> _submitProduct() async {
    if (!_formKey.currentState!.validate()) return;
    if (_pickedImages.isEmpty) {
      Get.snackbar(
        '⚠️ ছবি দরকার',
        'অন্তত ১টি ছবি যোগ করুন',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      final userId = user?.uid ?? 'demo_farmer';
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final userModel = userProvider.currentUser;

      // 1. Create a temp doc reference to get ID for image paths
      final docRef = FirebaseFirestore.instance.collection('products').doc();

      // 2. Upload images to Firebase Storage
      List<String> imageUrls = [];
      if (_pickedImages.isNotEmpty) {
        try {
          imageUrls = await _uploadImages(docRef.id);
        } catch (e) {
          // If upload fails, continue without images (still save text data)
          debugPrint('Image upload error: $e');
        }
      }

      // 3. Save product data to Firestore
      final productData = {
        'id': docRef.id,
        'farmerId': userId,
        'farmerName': userModel?.name ?? 'কৃষক',
        'farmerPhone': userModel?.phone ?? '',
        'farmerDistrict': userModel?.district ?? '',
        'farmerUpazila': userModel?.upazila ?? '',
        'farmerLocation': '${userModel?.upazila ?? ''}, ${userModel?.district ?? ''}',
        'cropName': _cropController.text.trim(),
        'category': _selectedCategory ?? 'other',
        'quantity': double.tryParse(_quantityController.text) ?? 0.0,
        'unit': _selectedUnit ?? 'কেজি',
        'pricePerUnit': double.tryParse(_priceController.text) ?? 0.0,
        'description': _descriptionController.text.trim(),
        'harvestDate': _harvestDate != null ? Timestamp.fromDate(_harvestDate!) : null,
        'images': imageUrls,
        'status': 'active', // active, sold, expired
        'views': 0,
        'isAvailable': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await docRef.set(productData);

      if (mounted) {
        Get.back();
        Get.snackbar(
          '✅ পণ্য যোগ হয়েছে!',
          '"${_cropController.text}" সফলভাবে মার্কেটপ্লেসে যোগ করা হয়েছে।',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      if (mounted) {
        Get.snackbar(
          'ত্রুটি হয়েছে',
          'পণ্য যোগ করতে সমস্যা: $e',
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

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: primaryGreen,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'পণ্য বিক্রয়ে দিন 🌾',
          style: GoogleFonts.hindSiliguri(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User info banner
              Consumer<UserProvider>(
                builder: (context, userProvider, _) {
                  final u = userProvider.currentUser;
                  if (u == null) return const SizedBox.shrink();
                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: primaryGreen.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: primaryGreen.withOpacity(0.2)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.person_pin, color: primaryGreen, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${u.name} • ${u.upazila}, ${u.district}',
                            style: GoogleFonts.hindSiliguri(
                              color: primaryGreen,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),

              // --- Crop Name ---
              _sectionLabel('ফসলের নাম *'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _cropController,
                decoration: _inputDeco(
                  hint: 'যেমন: টমেটো, পেঁয়াজ, ধান',
                  icon: Icons.grass,
                ),
                style: GoogleFonts.hindSiliguri(fontSize: 16),
                validator: (v) => (v == null || v.isEmpty) ? 'ফসলের নাম দিন' : null,
              ),
              const SizedBox(height: 16),

              // --- Category ---
              _sectionLabel('বিভাগ *'),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                decoration: _inputDeco(hint: 'বিভাগ নির্বাচন করুন', icon: Icons.category),
                value: _selectedCategory,
                items: _categories
                    .map((e) => DropdownMenuItem(
                          value: e['value'],
                          child: Text(e['label']!, style: GoogleFonts.hindSiliguri()),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => _selectedCategory = v),
                validator: (v) => (v == null || v.isEmpty) ? 'বিভাগ নির্বাচন করুন' : null,
                style: GoogleFonts.hindSiliguri(fontSize: 16, color: Colors.black87),
              ),
              const SizedBox(height: 16),

              // --- Quantity + Unit ---
              _sectionLabel('পরিমাণ ও একক *'),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _quantityController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: _inputDeco(hint: 'যেমন: ৫০০', icon: Icons.scale),
                      style: GoogleFonts.hindSiliguri(fontSize: 16),
                      validator: (v) => (v == null || v.isEmpty) ? 'পরিমাণ দিন' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      decoration: _inputDeco(hint: 'একক', icon: Icons.straighten),
                      value: _selectedUnit,
                      items: _units
                          .map((u) => DropdownMenuItem(
                                value: u,
                                child: Text(u, style: GoogleFonts.hindSiliguri()),
                              ))
                          .toList(),
                      onChanged: (v) => setState(() => _selectedUnit = v),
                      style: GoogleFonts.hindSiliguri(fontSize: 16, color: Colors.black87),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // --- Price ---
              _sectionLabel('মূল্য (৳) *'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _priceController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: _inputDeco(
                  hint: 'প্রতি ${_selectedUnit ?? 'কেজি'} মূল্য',
                  icon: Icons.currency_rupee,
                ),
                style: GoogleFonts.hindSiliguri(fontSize: 16),
                validator: (v) => (v == null || v.isEmpty) ? 'মূল্য দিন' : null,
              ),
              const SizedBox(height: 16),

              // --- Harvest Date ---
              _sectionLabel('ফসল কাটার তারিখ'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _harvestDateController,
                readOnly: true,
                decoration: _inputDeco(
                  hint: 'তারিখ নির্বাচন করুন',
                  icon: Icons.calendar_today,
                ).copyWith(
                  suffixIcon: const Icon(Icons.calendar_month, color: Color(0xFF2E7D32)),
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
                        colorScheme: const ColorScheme.light(primary: Color(0xFF2E7D32)),
                      ),
                      child: child!,
                    ),
                  );
                  if (date != null && mounted) {
                    setState(() {
                      _harvestDate = date;
                      _harvestDateController.text =
                          '${date.day}/${date.month}/${date.year}';
                    });
                  }
                },
              ),
              const SizedBox(height: 16),

              // --- Description ---
              _sectionLabel('বিবরণ (ঐচ্ছিক)'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: _inputDeco(
                  hint: 'ফসলের মান, চাষের পদ্ধতি, বিশেষ তথ্য লিখুন...',
                  icon: Icons.description,
                ),
                style: GoogleFonts.hindSiliguri(fontSize: 15),
              ),
              const SizedBox(height: 20),

              // --- Photo Upload ---
              _sectionLabel('ছবি যোগ করুন (সর্বোচ্চ ৫টি) *'),
              const SizedBox(height: 4),
              Text(
                'ভালো ছবি দিলে ক্রেতারা বেশি আগ্রহী হবেন',
                style: GoogleFonts.hindSiliguri(fontSize: 12, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 10),

              // Image grid
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childAspectRatio: 1,
                ),
                itemCount: _pickedImages.length < 5
                    ? _pickedImages.length + 1
                    : _pickedImages.length,
                itemBuilder: (context, index) {
                  if (index == _pickedImages.length) {
                    // Add button
                    return GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: primaryGreen.withOpacity(0.4),
                            style: BorderStyle.solid,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          color: primaryGreen.withOpacity(0.05),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_a_photo, color: primaryGreen.withOpacity(0.7), size: 30),
                            const SizedBox(height: 4),
                            Text(
                              'ছবি যোগ',
                              style: GoogleFonts.hindSiliguri(
                                fontSize: 11,
                                color: primaryGreen,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  // Show picked image
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
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.close, size: 14, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 28),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isSubmitting ? null : _submitProduct,
                  icon: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Icon(Icons.storefront),
                  label: Text(
                    _isSubmitting ? 'যোগ হচ্ছে...' : 'পণ্য মার্কেটে দিন',
                    style: GoogleFonts.hindSiliguri(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 3,
                    disabledBackgroundColor: Colors.grey.shade400,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  '📢 পণ্য যোগ করলে ক্রেতারা দেখতে পাবেন',
                  style: GoogleFonts.hindSiliguri(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
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
