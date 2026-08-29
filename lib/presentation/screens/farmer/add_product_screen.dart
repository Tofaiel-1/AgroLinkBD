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
import 'package:agrolinkbd/core/utils/masked_identity_helper.dart';

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

  String? _selectedCategory;
  String? _selectedUnit = 'কেজি';
  String _selectedTier = 'free'; // 'free', 'urgent', 'featured', 'vip'
  String _qualityGrade = 'Grade A (প্রিমিয়াম)';
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
  final List<String> _grades = [
    'Grade A (প্রিমিয়াম - রপ্তানিযোগ্য)',
    'Grade B (স্ট্যান্ডার্ড বাজার মান)',
    'Grade C (সাধারণ পাইকারি মান)',
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
              'ছবি নির্বাচন করুন',
              style: GoogleFonts.hindSiliguri(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Color(0xFF2E7D32)),
              title: Text('ক্যামেরা থেকে তুলুন', style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.w600)),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Color(0xFF2E7D32)),
              title: Text('গ্যালারি থেকে নিন', style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.w600)),
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
          .child('$productId\_$i.jpg');
      await ref.putFile(File(_pickedImages[i].path));
      final url = await ref.getDownloadURL();
      urls.add(url);
    }
    return urls;
  }

  Future<void> _submitProduct() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedCategory == null) {
      Get.snackbar(
        'ক্যাটাগরি প্রয়োজন',
        'দয়া করে ফসলের ধরন/ক্যাটাগরি নির্বাচন করুন',
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

      if (mounted) {
        Get.back();
        Get.snackbar(
          '✅ পণ্য মার্কেটে প্রকাশিত!',
          '"${_cropController.text}" ${_selectedTier != 'free' ? 'বুস্টসহ' : ''} সফলভাবে তালিকাভুক্ত হয়েছে।',
          backgroundColor: const Color(0xFF2E7D32),
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
          'পণ্য বিক্রয়ে দিন 🌾',
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
                        '🔒 এগ্রোলিংক সুরক্ষিত এস্ক্রো: আপনার পণ্য প্রকাশের পর বায়ার ১০০% টাকা অগ্রিম জমা রাখবে। ওটিপি যাচাইয়ের সাথে সাথে আপনার ওয়ালেটে ৯৭% নেট মূল্য পৌঁছে যাবে।',
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
              _sectionLabel('ফসলের নাম *'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _cropController,
                decoration: _inputDeco(hint: 'যেমন: গোল আলু, দেশি টমেটো', icon: Icons.agriculture),
                style: GoogleFonts.hindSiliguri(fontSize: 16),
                validator: (v) => (v == null || v.isEmpty) ? 'ফসলের নাম দিন' : null,
              ),
              const SizedBox(height: 16),

              // Category Selector
              _sectionLabel('ক্যাটাগরি *'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _categories.map((cat) {
                  final isSelected = _selectedCategory == cat['value'];
                  return ChoiceChip(
                    label: Text(
                      cat['label']!,
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
                      setState(() => _selectedCategory = selected ? cat['value'] : null);
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // Quality Grade
              _sectionLabel('পণ্যের কোয়ালিটি গ্রেড *'),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                decoration: _inputDeco(hint: 'গ্রেড নির্বাচন করুন', icon: Icons.verified_outlined),
                value: _qualityGrade,
                items: _grades
                    .map((g) => DropdownMenuItem(
                          value: g,
                          child: Text(g, style: GoogleFonts.hindSiliguri(fontSize: 14)),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => _qualityGrade = v ?? _grades.first),
                style: GoogleFonts.hindSiliguri(fontSize: 15, color: Colors.black87),
              ),
              const SizedBox(height: 16),

              // Quantity + Unit
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

              // Price
              _sectionLabel('প্রতি একক মূল্য (৳) *'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _priceController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: _inputDeco(
                  hint: 'প্রতি ${_selectedUnit ?? 'কেজি'} দর',
                  icon: Icons.currency_exchange_rounded,
                ),
                style: GoogleFonts.hindSiliguri(fontSize: 16),
                validator: (v) => (v == null || v.isEmpty) ? 'মূল্য দিন' : null,
              ),
              const SizedBox(height: 16),

              // Harvest Date
              _sectionLabel('ফসল কাটার তারিখ'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _harvestDateController,
                readOnly: true,
                decoration: _inputDeco(
                  hint: 'তারিখ নির্বাচন করুন',
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
              _sectionLabel('বিবরণ (ঐচ্ছিক)'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: _inputDeco(
                  hint: 'ফসলের জাত, রঙ, বিশেষ বৈশিষ্ট্য ইত্যাদি লিখুন...',
                  icon: Icons.description,
                ),
                style: GoogleFonts.hindSiliguri(fontSize: 15),
              ),
              const SizedBox(height: 20),

              // Photo Upload
              _sectionLabel('ছবি যোগ করুন (সর্বোচ্চ ৫টি)'),
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
                          border: Border.all(color: primaryGreen.withOpacity(0.4), width: 2),
                          borderRadius: BorderRadius.circular(12),
                          color: primaryGreen.withOpacity(0.05),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_a_photo, color: primaryGreen.withOpacity(0.8), size: 28),
                            const SizedBox(height: 4),
                            Text(
                              'ছবি যোগ',
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
              _sectionLabel('পণ্য প্রমোশন ও বুস্টিং প্ল্যান 🚀'),
              const SizedBox(height: 4),
              Text(
                'দ্রুত বিক্রি করতে ও বড় পাইকারদের দৃষ্টি আকর্ষণ করতে বুস্ট নির্বাচন করুন:',
                style: GoogleFonts.hindSiliguri(fontSize: 12, color: Colors.grey.shade700),
              ),
              const SizedBox(height: 12),

              _buildBoostCard(
                tier: 'free',
                title: 'সাধারণ লিস্টিং',
                subtitle: 'রেগুলার মার্কেটপ্লেস ফিডে প্রদর্শিত হবে',
                price: 'বিনামূল্যে (৳০)',
                icon: Icons.check_circle_outline,
                color: Colors.grey.shade700,
                badgeText: 'ফ্রি',
              ),
              const SizedBox(height: 10),

              _buildBoostCard(
                tier: 'urgent',
                title: 'জরুরি বিক্রি বুস্ট ⚡',
                subtitle: '৩ দিন "Urgent Sale" লাল ব্যাজ ও সবার উপরে থাকবে',
                price: '৳ ২০ / ৩ দিন',
                icon: Icons.bolt,
                color: Colors.red.shade600,
                badgeText: 'জনপ্রিয়',
              ),
              const SizedBox(height: 10),

              _buildBoostCard(
                tier: 'featured',
                title: 'প্রিমিয়াম ফিচার্ড লট 👑',
                subtitle: '৭ দিন হোমপেজ গোল্ডেন ব্যানারে এবং টপ লিস্টিংয়ে থাকবে',
                price: '৳ ৫০ / ৭ দিন',
                icon: Icons.workspace_premium_rounded,
                color: Colors.amber.shade800,
                badgeText: 'বেস্ট ভ্যালু',
              ),
              const SizedBox(height: 10),

              _buildBoostCard(
                tier: 'vip',
                title: 'ভিআইপি হোলসেলার পার্টনার 💎',
                subtitle: '১৫ দিন ঢাকার শীর্ষ আড়তদার ও বড় ক্রেতাদের এসএমএস অ্যালার্ট',
                price: '৳ ১০০ / ১৫ দিন',
                icon: Icons.diamond_rounded,
                color: const Color(0xFF1976D2),
                badgeText: 'ভিআইপি',
              ),
              const SizedBox(height: 28),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _isSubmitting ? null : _submitProduct,
                  icon: _isSubmitting
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Icon(Icons.storefront_rounded, color: Colors.white),
                  label: Text(
                    _isSubmitting
                        ? 'মার্কেটে যুক্ত হচ্ছে...'
                        : (_selectedTier != 'free' ? 'পেমেন্ট ও বুস্টসহ প্রকাশ করুন' : 'পণ্য মার্কেটে প্রকাশ করুন'),
                    style: GoogleFonts.hindSiliguri(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryGreen,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 4,
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
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.06) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [BoxShadow(color: color.withOpacity(0.15), blurRadius: 10, offset: const Offset(0, 4))]
              : [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2))],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.hindSiliguri(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          badgeText,
                          style: GoogleFonts.hindSiliguri(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.hindSiliguri(fontSize: 11, color: Colors.grey.shade700),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              price,
              style: GoogleFonts.hindSiliguri(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected ? color : Colors.grey.shade400,
              size: 20,
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
