import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:agrolinkbd/core/controllers/pond_controller.dart';
import 'package:agrolinkbd/core/providers/language_provider.dart';
import 'package:agrolinkbd/core/utils/number_converter.dart';

class AddPondScreen extends StatefulWidget {
  const AddPondScreen({super.key});

  @override
  State<AddPondScreen> createState() => _AddPondScreenState();
}

class _AddPondScreenState extends State<AddPondScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  final _nameController = TextEditingController();
  final _areaController = TextEditingController(text: '1.5');
  final _depthController = TextEditingController(text: '6.5');
  final _speciesController = TextEditingController();
  final _fishCountController = TextEditingController(text: '5000');
  final _initialWeightController = TextEditingController(text: '50');
  final _targetWeightController = TextEditingController(text: '1500');
  final _cycleDaysController = TextEditingController(text: '120');
  final _costController = TextEditingController();
  final _priceController = TextEditingController(text: '380');
  final _dailyFeedController = TextEditingController(text: '25');
  final _feedBrandController = TextEditingController(text: 'Mega Feed Floating 28% Protein');
  final _locationController = TextEditingController();
  final _managerNameController = TextEditingController();
  final _managerPhoneController = TextEditingController();
  final _customUrlController = TextEditingController();

  // State selections
  String _selectedCategory = 'বাণিজ্যিক কার্প পুকুর';
  String _selectedWaterSource = 'নদীর মিষ্টি পানি ও গভীর নলকূপ';
  String _selectedBioSecurity = 'Grade A+ (শতভাগ রোগমুক্ত ও অর্গানিক)';
  String _selectedAreaUnit = 'একর';
  int _aeratorCount = 4;
  bool _isSubmitting = false;

  // Image Selection State
  File? _pickedImageFile;
  static const String _defaultPondImageUrl =
      'https://images.unsplash.com/photo-1544551763-46a013bb70d5?w=900&auto=format&fit=crop&q=80';

  @override
  void dispose() {
    _nameController.dispose();
    _areaController.dispose();
    _depthController.dispose();
    _speciesController.dispose();
    _fishCountController.dispose();
    _initialWeightController.dispose();
    _targetWeightController.dispose();
    _cycleDaysController.dispose();
    _costController.dispose();
    _priceController.dispose();
    _dailyFeedController.dispose();
    _feedBrandController.dispose();
    _locationController.dispose();
    _managerNameController.dispose();
    _managerPhoneController.dispose();
    _customUrlController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source, bool isBn) async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: source,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );
      if (picked != null) {
        setState(() {
          _pickedImageFile = File(picked.path);
        });
      }
    } catch (e) {
      Get.snackbar(
        isBn ? 'ক্যামেরা / গ্যালারি এরর' : 'Camera / Gallery Error',
        isBn ? 'ছবি নির্বাচন করা সম্ভব হয়নি। দয়া করে আবার চেষ্টা করুন।' : 'Failed to pick image. Please try again.',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
    }
  }

  Future<void> _submit(bool isBn) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final pondController = Get.isRegistered<PondController>()
          ? Get.find<PondController>()
          : Get.put(PondController());

      String finalImageUrl = _defaultPondImageUrl;

      if (_pickedImageFile != null) {
        try {
          final fileName = 'pond_images/pond_${DateTime.now().millisecondsSinceEpoch}.jpg';
          final storageRef = FirebaseStorage.instance.ref().child(fileName);
          await storageRef.putFile(_pickedImageFile!);
          finalImageUrl = await storageRef.getDownloadURL();
        } catch (e) {
          debugPrint('Pond image upload error: $e');
          finalImageUrl = _defaultPondImageUrl;
        }
      } else if (_customUrlController.text.trim().isNotEmpty) {
        finalImageUrl = _customUrlController.text.trim();
      }

      final name = _nameController.text.trim();
      final area = '${_areaController.text.trim()} $_selectedAreaUnit';
      final species = _speciesController.text.trim();
      
      // Use resilient BanglaEnglishNumberHelper to support both English & Bengali numerals
      final count = BanglaEnglishNumberHelper.toInt(_fishCountController.text.trim(), 1000);
      final cost = BanglaEnglishNumberHelper.toDouble(_costController.text.trim(), 0.0);
      final expectedPrice = BanglaEnglishNumberHelper.toDouble(_priceController.text.trim(), 350.0);
      final avgWeight = BanglaEnglishNumberHelper.toDouble(_initialWeightController.text.trim(), 50.0);
      final targetWeight = BanglaEnglishNumberHelper.toDouble(_targetWeightController.text.trim(), 1500.0);
      final cycleDays = BanglaEnglishNumberHelper.toInt(_cycleDaysController.text.trim(), 120);
      final dailyFeed = BanglaEnglishNumberHelper.toDouble(_dailyFeedController.text.trim(), 25.0);
      final location = _locationController.text.trim();
      final managerName = _managerNameController.text.trim();
      final managerPhone = _managerPhoneController.text.trim();

      await pondController.addPond(
        name,
        area,
        species,
        count,
        cost,
        expectedPrice: expectedPrice,
        location: location.isNotEmpty ? location : (isBn ? 'বাংলাদেশ' : 'Bangladesh'),
        imageUrl: finalImageUrl,
        farmCategory: _selectedCategory,
        bioSecurity: _selectedBioSecurity,
        waterSource: _selectedWaterSource,
        avgWeightGrams: avgWeight,
        targetHarvestWeightGrams: targetWeight,
        totalCycleDays: cycleDays,
        dailyFeedingKg: dailyFeed,
        feedBrand: _feedBrandController.text.trim(),
        aeratorCount: _aeratorCount,
        farmManagerName: managerName,
        managerPhone: managerPhone,
      );

      Get.back();
      Get.snackbar(
        isBn ? 'সফলভাবে সংরক্ষিত! 🌊' : 'Saved Successfully! 🌊',
        isBn ? '$name সফলভাবে যুক্ত হয়েছে।' : '$name has been added to your farm.',
        backgroundColor: const Color(0xFF006064),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        borderRadius: 14,
        duration: const Duration(seconds: 4),
        icon: const Icon(Icons.check_circle, color: Colors.greenAccent),
      );
    } catch (e) {
      Get.snackbar(
        isBn ? 'সংরক্ষণ ব্যর্থ হয়েছে' : 'Failed to Save',
        isBn ? 'ত্রুটি: $e' : 'Error: $e',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isBn = LanguageProvider.isBn(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const Color deepAqua = Color(0xFF006064);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0A1218) : const Color(0xFFF1F5F8),
      appBar: AppBar(
        title: Text(
          isBn ? 'নতুন পুকুর / ট্যাংক যুক্ত করুন' : 'Add New Pond / Tank',
          style: GoogleFonts.hindSiliguri(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        backgroundColor: deepAqua,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // SECTION 1: FARM CATEGORY SELECTOR
              _buildSectionCard(
                isDark,
                title: isBn ? '১. খামারের ধরন ও ক্যাটাগরি' : '1. Farm Type & Category',
                icon: Icons.category,
                child: Column(
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        {'bn': 'বাণিজ্যিক কার্প পুকুর', 'en': 'Commercial Carp Pond'},
                        {'bn': 'বায়োফ্লক ট্যাংক', 'en': 'Biofloc Tank'},
                        {'bn': 'চিংড়ি ঘের', 'en': 'Shrimp Ghér'},
                        {'bn': 'আরএএস সিস্টেম', 'en': 'RAS System'},
                        {'bn': 'হ্যাচারি ও নার্সারি', 'en': 'Hatchery & Nursery'},
                      ].map((catMap) {
                        final catBn = catMap['bn']!;
                        final catEn = catMap['en']!;
                        final isSelected = _selectedCategory == catBn;
                        return ChoiceChip(
                          label: Text(
                            isBn ? catBn : catEn,
                            style: GoogleFonts.hindSiliguri(
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                            ),
                          ),
                          selected: isSelected,
                          selectedColor: deepAqua,
                          backgroundColor: isDark ? const Color(0xFF16252F) : Theme.of(context).cardColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                            side: BorderSide(color: isSelected ? deepAqua : (isDark ? Colors.white24 : Colors.grey.shade300)),
                          ),
                          onSelected: (val) {
                            setState(() {
                              _selectedCategory = catBn;
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // SECTION 2: REAL IMAGE SELECTION & UPLOAD
              _buildSectionCard(
                isDark,
                title: isBn ? '২. খামারের বাস্তব ছবি (ঐচ্ছিক)' : '2. Farm Image (Optional)',
                icon: Icons.camera_alt,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Live Preview Area / Upload Placeholder
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: _pickedImageFile != null
                          ? Stack(
                              alignment: Alignment.bottomRight,
                              children: [
                                Image.file(
                                  _pickedImageFile!,
                                  height: 180,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _pickedImageFile = null;
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withValues(alpha: 0.65),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.close,
                                        size: 18,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                                Container(
                                  margin: const EdgeInsets.all(10),
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.75),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.check_circle, color: Colors.greenAccent, size: 14),
                                      const SizedBox(width: 4),
                                      Text(
                                        isBn ? 'ছবি নির্বাচিত হয়েছে' : 'Photo Selected',
                                        style: GoogleFonts.hindSiliguri(
                                          color: Colors.white,
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            )
                          : Container(
                              height: 140,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF13222B) : const Color(0xFFF1F8F8),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isDark ? Colors.tealAccent.withValues(alpha: 0.2) : Colors.teal.shade200,
                                  width: 1.5,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.add_a_photo_outlined,
                                    size: 38,
                                    color: deepAqua,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    isBn
                                        ? 'পুকুর বা ট্যাংকের ছবি তুলুন বা গ্যালারি থেকে যোগ করুন'
                                        : 'Take pond/tank photo or choose from gallery',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.hindSiliguri(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: isDark ? Colors.white70 : Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    isBn
                                        ? '(ঐচ্ছিক - ছবি না দিলে অটোমেটিক ডিফল্ট কভার ব্যবহৃত হবে)'
                                        : '(Optional - Default cover used if omitted)',
                                    style: GoogleFonts.hindSiliguri(
                                      fontSize: 11,
                                      color: isDark ? Colors.white38 : Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                    ),
                    const SizedBox(height: 12),

                    // Camera & Gallery Buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _pickImage(ImageSource.camera, isBn),
                            icon: const Icon(Icons.camera_alt, size: 18, color: deepAqua),
                            label: Text(
                              isBn ? 'ক্যামেরা' : 'Camera',
                              style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, color: deepAqua),
                            ),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              side: const BorderSide(color: deepAqua),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _pickImage(ImageSource.gallery, isBn),
                            icon: const Icon(Icons.photo_library, size: 18, color: Color(0xFF0288D1)),
                            label: Text(
                              isBn ? 'গ্যালারি' : 'Gallery',
                              style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, color: const Color(0xFF0288D1)),
                            ),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              side: const BorderSide(color: Color(0xFF0288D1)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // SECTION 3: BASIC & TECHNICAL DETAILS
              _buildSectionCard(
                isDark,
                title: isBn ? '৩. পুকুর / ট্যাংকের প্রাথমিক ও কারিগরি তথ্য' : '3. Basic & Technical Specs',
                icon: Icons.water_drop,
                child: Column(
                  children: [
                    _buildTextField(
                      controller: _nameController,
                      label: isBn ? 'পুকুর / ট্যাংকের নাম *' : 'Pond / Tank Name *',
                      hint: isBn ? 'যেমন: পদ্মা কার্প পুকুর-২' : 'e.g. Padma Carp Pond-2',
                      icon: Icons.pool,
                      validator: (v) => (v == null || v.trim().isEmpty) ? (isBn ? 'নাম আবশ্যক' : 'Name is required') : null,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: _buildTextField(
                            controller: _areaController,
                            label: isBn ? 'আয়তন *' : 'Area *',
                            hint: isBn ? 'যেমন: ১.৫' : 'e.g. 1.5',
                            icon: Icons.straighten,
                            keyboardType: TextInputType.number,
                            validator: (v) => (v == null || v.trim().isEmpty) ? (isBn ? 'আয়তন আবশ্যক' : 'Area is required') : null,
                            isDark: isDark,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 1,
                          child: DropdownButtonFormField<String>(
                            value: _selectedAreaUnit,
                            dropdownColor: isDark ? const Color(0xFF16252F) : Colors.white,
                            style: GoogleFonts.hindSiliguri(
                              color: isDark ? Colors.white : Colors.black87,
                              fontSize: 12,
                            ),
                            decoration: InputDecoration(
                              labelText: isBn ? 'একক' : 'Unit',
                              labelStyle: GoogleFonts.hindSiliguri(color: isDark ? Colors.grey.shade400 : Colors.grey.shade700, fontSize: 12),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                              filled: true,
                              fillColor: isDark ? const Color(0xFF0F1A22) : const Color(0xFFF9FBFC),
                            ),
                            items: [
                              {'bn': 'একর', 'en': 'Acre'},
                              {'bn': 'শতাংশ', 'en': 'Decimal'},
                              {'bn': 'হেক্টর', 'en': 'Hectare'},
                              {'bn': 'লিটার (ট্যাংক)', 'en': 'Liter (Tank)'},
                            ].map((uMap) {
                              final u = uMap['bn']!;
                              return DropdownMenuItem(
                                value: u, 
                                child: Text(isBn ? uMap['bn']! : uMap['en']!, style: GoogleFonts.hindSiliguri(fontSize: 12)),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) setState(() => _selectedAreaUnit = val);
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: _depthController,
                            label: isBn ? 'গভীরতা (ফুট)' : 'Depth (Feet)',
                            hint: isBn ? 'যেমন: ৬.৫' : 'e.g. 6.5',
                            icon: Icons.height,
                            keyboardType: TextInputType.number,
                            isDark: isDark,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: DropdownButtonFormField<int>(
                            value: _aeratorCount,
                            dropdownColor: isDark ? const Color(0xFF16252F) : Colors.white,
                            style: GoogleFonts.hindSiliguri(
                              color: isDark ? Colors.white : Colors.black87,
                              fontSize: 12,
                            ),
                            decoration: InputDecoration(
                              labelText: isBn ? 'অ্যারেটর সংখ্যা' : 'Aerators',
                              labelStyle: GoogleFonts.hindSiliguri(color: isDark ? Colors.grey.shade400 : Colors.grey.shade700, fontSize: 12),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                              filled: true,
                              fillColor: isDark ? const Color(0xFF0F1A22) : const Color(0xFFF9FBFC),
                            ),
                            items: [0, 2, 4, 6, 8, 12].map((c) {
                              return DropdownMenuItem(
                                value: c, 
                                child: Text(
                                  isBn ? '$c টি ইউনিট' : '$c Units', 
                                  style: GoogleFonts.hindSiliguri(fontSize: 12),
                                ),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) setState(() => _aeratorCount = val);
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _selectedWaterSource,
                      dropdownColor: isDark ? const Color(0xFF16252F) : Colors.white,
                      style: GoogleFonts.hindSiliguri(
                        color: isDark ? Colors.white : Colors.black87,
                        fontSize: 12.5,
                      ),
                      decoration: InputDecoration(
                        labelText: isBn ? 'পানির উৎস' : 'Water Source',
                        labelStyle: GoogleFonts.hindSiliguri(color: isDark ? Colors.grey.shade400 : Colors.grey.shade700, fontSize: 12),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        prefixIcon: const Icon(Icons.waves, color: deepAqua),
                        filled: true,
                        fillColor: isDark ? const Color(0xFF0F1A22) : const Color(0xFFF9FBFC),
                      ),
                      items: [
                        {'bn': 'নদীর মিষ্টি পানি ও গভীর নলকূপ', 'en': 'River Fresh Water & Deep Tubewell'},
                        {'bn': 'গভীর সাবমারসিবল নলকূপ', 'en': 'Deep Submersible Tubewell'},
                        {'bn': 'জোয়ার-ভাটার লবণাক্ত খাঁড়ি গেট', 'en': 'Tidal Brackish Canal Sluice'},
                        {'bn': 'বৃষ্টি ও প্রাকৃতিক ক্যানেল', 'en': 'Rainfall & Natural Canal'},
                        {'bn': 'ফিল্টার্ড আরএএস রিসার্কুলেশন প্ল্যান্ট', 'en': 'Filtered RAS Recirculation Plant'},
                      ].map((wMap) => DropdownMenuItem(
                        value: wMap['bn']!, 
                        child: Text(isBn ? wMap['bn']! : wMap['en']!, style: GoogleFonts.hindSiliguri(fontSize: 12)),
                      )).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedWaterSource = val);
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _selectedBioSecurity,
                      dropdownColor: isDark ? const Color(0xFF16252F) : Colors.white,
                      style: GoogleFonts.hindSiliguri(
                        color: isDark ? Colors.white : Colors.black87,
                        fontSize: 12.5,
                      ),
                      decoration: InputDecoration(
                        labelText: isBn ? 'বায়োসিকিউরিটি গ্রেড' : 'Bio-Security Grade',
                        labelStyle: GoogleFonts.hindSiliguri(color: isDark ? Colors.grey.shade400 : Colors.grey.shade700, fontSize: 12),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        prefixIcon: const Icon(Icons.verified_user, color: Colors.green),
                        filled: true,
                        fillColor: isDark ? const Color(0xFF0F1A22) : const Color(0xFFF9FBFC),
                      ),
                      items: [
                        {'bn': 'Grade A+ (শতভাগ রোগমুক্ত ও অর্গানিক)', 'en': 'Grade A+ (100% Disease-Free Organic)'},
                        {'bn': 'ইইউ এক্সপোর্ট কোয়ালিটি সার্টিফাইড', 'en': 'EU Export Quality Certified'},
                        {'bn': 'হাইজিনিক ইনডোর বায়োফ্লক সিস্টেম', 'en': 'Hygienic Indoor Biofloc System'},
                        {'bn': 'স্ট্যান্ডার্ড কমার্শিয়াল ফার্ম গ্রেড', 'en': 'Standard Commercial Farm Grade'},
                      ].map((bMap) => DropdownMenuItem(
                        value: bMap['bn']!, 
                        child: Text(isBn ? bMap['bn']! : bMap['en']!, style: GoogleFonts.hindSiliguri(fontSize: 12)),
                      )).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedBioSecurity = val);
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: _locationController,
                      label: isBn ? 'খামার অবস্থান (উপজেলা, জেলা)' : 'Location (Upazila, District)',
                      hint: isBn ? 'যেমন: চাঁদপুর সদর, চাঁদপুর' : 'e.g. Chandpur Sadar, Chandpur',
                      icon: Icons.location_on,
                      isDark: isDark,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // SECTION 4: FISH STOCK & BIOMASS TARGETS
              _buildSectionCard(
                isDark,
                title: isBn ? '৪. মাছের পোনা মজুত ও অর্থনৈতিক লক্ষ্যমাত্রা' : '4. Stocking & Financial Targets',
                icon: Icons.set_meal,
                child: Column(
                  children: [
                    _buildTextField(
                      controller: _speciesController,
                      label: isBn ? 'মাছের প্রজাতি ও জাত *' : 'Fish Species & Variety *',
                      hint: isBn ? 'যেমন: রুই, কাতলা ও মৃগেল (মিশ্র কার্প)' : 'e.g. Rui, Catla & Mrigal (Mixed Carp)',
                      icon: Icons.phishing,
                      validator: (v) => (v == null || v.trim().isEmpty) ? (isBn ? 'প্রজাতি আবশ্যক' : 'Species is required') : null,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: _fishCountController,
                            label: isBn ? 'মোট পোনা সংখ্যা *' : 'Total Fish Stock *',
                            hint: isBn ? 'যেমন: ৫০০০' : 'e.g. 5000',
                            icon: Icons.format_list_numbered,
                            keyboardType: TextInputType.number,
                            validator: (v) => (v == null || v.trim().isEmpty) ? (isBn ? 'সংখ্যা আবশ্যক' : 'Count is required') : null,
                            isDark: isDark,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildTextField(
                            controller: _costController,
                            label: isBn ? 'পোনা ক্রয় খরচ (৳)' : 'Stocking Cost (৳)',
                            hint: isBn ? 'যেমন: ২৫০০০' : 'e.g. 25000',
                            icon: Icons.monetization_on,
                            keyboardType: TextInputType.number,
                            isDark: isDark,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: _initialWeightController,
                            label: isBn ? 'শুরুর গড় ওজন (গ্রাম)' : 'Initial Weight (g)',
                            hint: isBn ? 'যেমন: ৫০' : 'e.g. 50',
                            icon: Icons.scale,
                            keyboardType: TextInputType.number,
                            isDark: isDark,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildTextField(
                            controller: _targetWeightController,
                            label: isBn ? 'টার্গেট ওজন (গ্রাম)' : 'Target Weight (g)',
                            hint: isBn ? 'যেমন: ১৫০০' : 'e.g. 1500',
                            icon: Icons.fitness_center,
                            keyboardType: TextInputType.number,
                            isDark: isDark,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: _cycleDaysController,
                            label: isBn ? 'মোট সাইকেল দিন' : 'Total Cycle Days',
                            hint: isBn ? 'যেমন: ১২০' : 'e.g. 120',
                            icon: Icons.calendar_month,
                            keyboardType: TextInputType.number,
                            isDark: isDark,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildTextField(
                            controller: _priceController,
                            label: isBn ? 'প্রত্যাশিত দর (৳/কেজি)' : 'Expected Price (৳/kg)',
                            hint: isBn ? 'যেমন: ৩৮০' : 'e.g. 380',
                            icon: Icons.trending_up,
                            keyboardType: TextInputType.number,
                            isDark: isDark,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: _dailyFeedController,
                            label: isBn ? 'দৈনিক ফিড (কেজি)' : 'Daily Feed (kg)',
                            hint: isBn ? 'যেমন: ২৫' : 'e.g. 25',
                            icon: Icons.inventory_2,
                            keyboardType: TextInputType.number,
                            isDark: isDark,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildTextField(
                            controller: _feedBrandController,
                            label: isBn ? 'ফিড ব্র্যান্ড' : 'Feed Brand',
                            hint: isBn ? 'মেগা ফিড ভাসমান ২৮%' : 'Mega Feed Floating 28%',
                            icon: Icons.local_dining,
                            isDark: isDark,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // SUBMIT BUTTON
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isSubmitting ? null : () => _submit(isBn),
                  icon: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                        )
                      : const Icon(Icons.cloud_upload_rounded, color: Colors.white, size: 22),
                  label: Text(
                    _isSubmitting 
                        ? (isBn ? 'সংরক্ষণ হচ্ছে...' : 'Saving...')
                        : (isBn ? 'পুকুর / ট্যাংক সংরক্ষণ করুন' : 'Save Pond / Tank'),
                    style: GoogleFonts.hindSiliguri(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: deepAqua,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 4,
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard(bool isDark, {required String title, required IconData icon, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF16252F) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(color: isDark ? Colors.white10 : Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF006064), size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.hindSiliguri(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    required bool isDark,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: GoogleFonts.hindSiliguri(
        color: isDark ? Colors.white : Colors.black87,
        fontSize: 14,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: GoogleFonts.hindSiliguri(color: isDark ? Colors.grey.shade400 : Colors.grey.shade700, fontSize: 13),
        hintStyle: GoogleFonts.hindSiliguri(color: isDark ? Colors.white38 : Colors.grey.shade400, fontSize: 12),
        prefixIcon: Icon(icon, color: const Color(0xFF006064), size: 20),
        filled: true,
        fillColor: isDark ? const Color(0xFF0F1A22) : const Color(0xFFF9FBFC),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: isDark ? Colors.white12 : Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: isDark ? Colors.white12 : Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF006064), width: 1.8),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
      validator: validator,
    );
  }
}
