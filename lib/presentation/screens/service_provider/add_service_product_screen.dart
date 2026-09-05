import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:agrolinkbd/core/providers/language_provider.dart';
import 'package:agrolinkbd/core/providers/service_provider_providers.dart';
import 'package:agrolinkbd/core/models/service_provider_models.dart';

/// Screen for Service Providers to add a new product to their catalog and save to Firebase Firestore
class AddServiceProductScreen extends ConsumerStatefulWidget {
  const AddServiceProductScreen({super.key});

  @override
  ConsumerState<AddServiceProductScreen> createState() => _AddServiceProductScreenState();
}

class _AddServiceProductScreenState extends ConsumerState<AddServiceProductScreen> {
  final _formKey = GlobalKey<FormState>();

  ServiceProductCategory _selectedCategory = ServiceProductCategory.fertilizer;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _nameEnController = TextEditingController();
  final TextEditingController _brandController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _discountPriceController = TextEditingController();
  final TextEditingController _stockController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();
  final TextEditingController _rentPriceController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _descEnController = TextEditingController();

  String _selectedUnit = 'বস্তা (৫০ কেজি)';
  String _selectedUnitEN = 'Bag (50 kg)';
  bool _isForRent = false;
  bool _isLoading = false;

  final List<Map<String, String>> _unitOptions = [
    {'bn': 'বস্তা (৫০ কেজি)', 'en': 'Bag (50 kg)'},
    {'bn': 'বস্তা (২৫ কেজি)', 'en': 'Bag (25 kg)'},
    {'bn': 'কেজি', 'en': 'kg'},
    {'bn': 'গ্রাম', 'en': 'gm'},
    {'bn': 'বোতল (১ লি.)', 'en': 'Bottle (1 L)'},
    {'bn': 'বোতল (৫০০ মিলি)', 'en': 'Bottle (500 ml)'},
    {'bn': 'প্যাকেট (১০ গ্রাম)', 'en': 'Packet (10 g)'},
    {'bn': 'প্যাকেট (১০০ গ্রাম)', 'en': 'Packet (100 g)'},
    {'bn': 'পিস', 'en': 'pcs'},
    {'bn': 'ঘণ্টা', 'en': 'hr'},
    {'bn': 'দিন', 'en': 'day'},
  ];

  final List<Map<String, String>> _sampleImages = [
    {
      'label': 'সার (Urea)',
      'url': 'https://res.cloudinary.com/dbbvlg2dz/image/upload/v1788536279/images_nom0jd.jpg',
    },
    {
      'label': 'টিএসপি (TSP)',
      'url': 'https://res.cloudinary.com/dbbvlg2dz/image/upload/v1788536328/images_i4or4z.jpg',
    },
    {
      'label': 'ভার্মি (Compost)',
      'url': 'https://res.cloudinary.com/dbbvlg2dz/image/upload/v1788536395/images_sy3zpw.jpg',
    },
    {
      'label': 'কীটনাশক (Pesticide)',
      'url': 'https://res.cloudinary.com/dbbvlg2dz/image/upload/v1788536403/images_vse3bl.jpg',
    },
    {
      'label': 'রিপকর্ড (Ripcord)',
      'url': 'https://res.cloudinary.com/dbbvlg2dz/image/upload/v1788536445/images_muw2qn.jpg',
    },
    {
      'label': 'ধান বীজ (BRRI)',
      'url': 'https://res.cloudinary.com/dbbvlg2dz/image/upload/v1788536508/images_kx5jto.jpg',
    },
    {
      'label': 'টমেটো বীজ (Seeds)',
      'url': 'https://res.cloudinary.com/dbbvlg2dz/image/upload/v1788536818/images_vgtkqt.jpg',
    },
    {
      'label': 'ট্র্যাক্টর (Tractor)',
      'url': 'https://res.cloudinary.com/dbbvlg2dz/image/upload/v1788536934/images_ju0kgd.jpg',
    },
    {
      'label': 'স্প্রেয়ার (Sprayer)',
      'url': 'https://res.cloudinary.com/dbbvlg2dz/image/upload/v1788536954/images_avkjra.jpg',
    },
    {
      'label': 'সেচ পাম্প (Pump)',
      'url': 'https://res.cloudinary.com/dbbvlg2dz/image/upload/v1788536977/images_osi8wx.jpg',
    },
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _nameEnController.dispose();
    _brandController.dispose();
    _priceController.dispose();
    _discountPriceController.dispose();
    _stockController.dispose();
    _imageUrlController.dispose();
    _rentPriceController.dispose();
    _descController.dispose();
    _descEnController.dispose();
    super.dispose();
  }

  Future<void> _submitProduct() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final isBn = LanguageProvider.isBn(context);
      final price = double.tryParse(_priceController.text.trim()) ?? 0.0;
      final discountPrice = _discountPriceController.text.trim().isNotEmpty
          ? double.tryParse(_discountPriceController.text.trim())
          : null;
      final stockQuantity = int.tryParse(_stockController.text.trim()) ?? 1;
      final rentPrice = _isForRent && _rentPriceController.text.trim().isNotEmpty
          ? double.tryParse(_rentPriceController.text.trim())
          : null;

      final currentUid = FirebaseAuth.instance.currentUser?.uid ?? 'shop_001';
      final images = _imageUrlController.text.trim().isNotEmpty
          ? [_imageUrlController.text.trim()]
          : <String>[];

      final newProduct = ServiceProduct(
        id: '', // Will be generated by Firestore
        shopOwnerId: currentUid,
        name: _nameController.text.trim(),
        nameEN: _nameEnController.text.trim().isNotEmpty ? _nameEnController.text.trim() : null,
        description: _descController.text.trim(),
        descriptionEN: _descEnController.text.trim().isNotEmpty ? _descEnController.text.trim() : null,
        category: _selectedCategory,
        price: price,
        discountPrice: discountPrice,
        stockQuantity: stockQuantity,
        unit: _selectedUnit,
        unitEN: _selectedUnitEN,
        brand: _brandController.text.trim().isNotEmpty ? _brandController.text.trim() : null,
        images: images,
        isAvailable: true,
        isForRent: _isForRent,
        rentPricePerDay: rentPrice,
        rating: 5.0,
        totalSold: 0,
        totalReviews: 0,
        createdAt: DateTime.now(),
      );

      await ref.read(serviceProductProvider.notifier).addProduct(newProduct);

      if (mounted) {
        setState(() => _isLoading = false);
        Get.back();
        Get.snackbar(
          isBn ? 'সফল হয়েছে!' : 'Success!',
          isBn ? 'নতুন পণ্য সফলভাবে ক্যাটালগে যুক্ত হয়েছে।' : 'New product successfully added to catalog.',
          backgroundColor: const Color(0xFF2E7D32),
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        Get.snackbar(
          'ত্রুটি / Error',
          'পণ্য সংরক্ষণে সমস্যা হয়েছে: $e',
          backgroundColor: Colors.red.shade700,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isBn = LanguageProvider.isBn(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2B32B2),
        elevation: 0,
        titleSpacing: 0,
        title: Text(
          isBn ? 'নতুন পণ্য যুক্ত করুন' : 'Add New Product',
          style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 17),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
          onPressed: () => Get.back(),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 30),
          physics: const BouncingScrollPhysics(),
          children: [
            // 1. Category Selector
            _buildSectionCard(
              title: isBn ? 'ক্যাটাগরি নির্বাচন করুন' : 'Select Category',
              icon: Icons.category_rounded,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: ServiceProductCategory.values.map((cat) {
                    final isSelected = _selectedCategory == cat;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _selectedCategory = cat;
                            if (cat == ServiceProductCategory.tractor || cat == ServiceProductCategory.equipment) {
                              _isForRent = true;
                            }
                          });
                        },
                        borderRadius: BorderRadius.circular(10),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFF2B32B2) : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isSelected ? const Color(0xFF2B32B2) : Colors.grey.shade300,
                              width: 1.2,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(cat.icon, style: const TextStyle(fontSize: 16)),
                              const SizedBox(width: 6),
                              Text(
                                isBn ? cat.bengaliName : cat.englishName,
                                style: GoogleFonts.poppins(
                                  fontSize: 11.5,
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                  color: isSelected ? Colors.white : Colors.grey.shade800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // 2. Basic Info (Names & Brand)
            _buildSectionCard(
              title: isBn ? 'পণ্যের নাম ও ব্র্যান্ড' : 'Product Name & Brand',
              icon: Icons.inventory_2_rounded,
              child: Column(
                children: [
                  _buildTextField(
                    controller: _nameController,
                    label: isBn ? 'পণ্যের নাম (বাংলা)*' : 'Product Name (Bengali)*',
                    hint: isBn ? 'যেমন: ইউরিয়া সার (সাদা দানাদার)' : 'e.g. Urea Fertilizer',
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return isBn ? 'পণ্যের নাম আবশ্যক' : 'Product name is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  _buildTextField(
                    controller: _nameEnController,
                    label: isBn ? 'পণ্যের নাম (English)' : 'Product Name (English)',
                    hint: 'e.g. Urea Fertilizer (Granular)',
                  ),
                  const SizedBox(height: 10),
                  _buildTextField(
                    controller: _brandController,
                    label: isBn ? 'ব্র্যান্ড / প্রস্তুতকারক' : 'Brand / Manufacturer',
                    hint: isBn ? 'যেমন: যমুনা ফার্টিলাইজার / সিনজেন্টা' : 'e.g. Syngenta, Bayer',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // 3. Pricing & Stock Quantity
            _buildSectionCard(
              title: isBn ? 'মূল্য ও মজুদ' : 'Pricing & Stock',
              icon: Icons.price_change_rounded,
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          controller: _priceController,
                          label: isBn ? 'মূল্য (৳)*' : 'Price (৳)*',
                          hint: '0',
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return isBn ? 'মূল্য দিন' : 'Enter price';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildTextField(
                          controller: _discountPriceController,
                          label: isBn ? 'ছাড় মূল্য (৳)' : 'Discount Price (৳)',
                          hint: 'ঐচ্ছিক',
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          controller: _stockController,
                          label: isBn ? 'মজুদ পরিমাণ*' : 'Stock Quantity*',
                          hint: '10',
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return isBn ? 'মজুদ দিন' : 'Enter stock';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isBn ? 'পরিমাপের একক' : 'Unit',
                              style: GoogleFonts.poppins(fontSize: 11.5, fontWeight: FontWeight.w600, color: Colors.grey.shade700),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              height: 44,
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F3F7),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  isExpanded: true,
                                  value: _selectedUnit,
                                  icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 20),
                                  style: GoogleFonts.poppins(fontSize: 12, color: Colors.black87),
                                  items: _unitOptions.map((u) {
                                    return DropdownMenuItem<String>(
                                      value: u['bn'],
                                      child: Text(isBn ? u['bn']! : u['en']!),
                                    );
                                  }).toList(),
                                  onChanged: (val) {
                                    if (val != null) {
                                      setState(() {
                                        _selectedUnit = val;
                                        final matched = _unitOptions.firstWhere((e) => e['bn'] == val, orElse: () => {'bn': val, 'en': val});
                                        _selectedUnitEN = matched['en']!;
                                      });
                                    }
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // 4. Rental Option (For Tractor & Equipment)
            _buildSectionCard(
              title: isBn ? 'ভাড়ার সুবিধা (Rental)' : 'Rental Facility',
              icon: Icons.car_rental_rounded,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isBn ? 'পণ্যটি ভাড়ায় দিতে চান?' : 'Offer for daily rental?',
                            style: GoogleFonts.poppins(fontSize: 12.5, fontWeight: FontWeight.w600),
                          ),
                          Text(
                            isBn ? 'ট্র্যাক্টর ও যন্ত্রপাতির জন্য প্রযোজ্য' : 'Ideal for tractors & equipment',
                            style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey.shade500),
                          ),
                        ],
                      ),
                      Switch(
                        value: _isForRent,
                        activeThumbColor: const Color(0xFF2B32B2),
                        onChanged: (val) => setState(() => _isForRent = val),
                      ),
                    ],
                  ),
                  if (_isForRent) ...[
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _rentPriceController,
                      label: isBn ? 'দৈনিক ভাড়া রেট (৳/দিন)*' : 'Daily Rent Rate (৳/day)*',
                      hint: 'যেমন: ৩৫০০',
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 12),

            // 5. Image URL & Quick Sample Presets
            _buildSectionCard(
              title: isBn ? 'পণ্যের ছবি (Image)' : 'Product Image',
              icon: Icons.image_rounded,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTextField(
                    controller: _imageUrlController,
                    label: isBn ? 'ছবির লিংক (URL)' : 'Image URL',
                    hint: 'https://...',
                    onChanged: (v) => setState(() {}),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isBn ? 'অথবা দ্রুত নমুনা ছবি সিলেক্ট করুন:' : 'Or choose a sample preset image:',
                    style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 6),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: _sampleImages.map((sample) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: ActionChip(
                            avatar: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: Image.network(sample['url']!, width: 18, height: 18, fit: BoxFit.cover),
                            ),
                            label: Text(
                              sample['label']!,
                              style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w500),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            backgroundColor: Colors.grey.shade100,
                            onPressed: () {
                              setState(() {
                                _imageUrlController.text = sample['url']!;
                              });
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  if (_imageUrlController.text.trim().isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: SizedBox(
                          height: 100,
                          width: 140,
                          child: Image.network(
                            _imageUrlController.text.trim(),
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: Colors.grey.shade200,
                              child: const Center(
                                child: Icon(Icons.broken_image_rounded, color: Colors.grey),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 12),

            // 6. Description
            _buildSectionCard(
              title: isBn ? 'পণ্যের বিবরণ' : 'Description',
              icon: Icons.description_rounded,
              child: Column(
                children: [
                  _buildTextField(
                    controller: _descController,
                    label: isBn ? 'বিবরণ (বাংলা)' : 'Description (Bengali)',
                    hint: isBn ? 'পণ্যের গুণগত মান, ব্যবহারের নিয়ম...' : 'Product details and benefits...',
                    maxLines: 2,
                  ),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: _descEnController,
                    label: isBn ? 'বিবরণ (English)' : 'Description (English)',
                    hint: 'Details and usage instructions in English...',
                    maxLines: 2,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 7. Submit Button
            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitProduct,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2B32B2),
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            isBn ? 'পণ্য সংরক্ষণ করুন' : 'Save Product',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200, width: 0.8),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 4, offset: const Offset(0, 1)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: const Color(0xFF2B32B2)),
              const SizedBox(width: 6),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 12.5,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey.shade700),
        ),
        const SizedBox(height: 4),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          validator: validator,
          onChanged: onChanged,
          maxLines: maxLines,
          style: GoogleFonts.poppins(fontSize: 12.5),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.poppins(fontSize: 11.5, color: Colors.grey.shade400),
            filled: true,
            fillColor: const Color(0xFFF1F3F7),
            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF2B32B2), width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
