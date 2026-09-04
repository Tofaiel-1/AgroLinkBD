import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:agrolinkbd/core/models/pond_model.dart';
import 'package:agrolinkbd/core/controllers/pond_controller.dart';
import 'package:agrolinkbd/core/providers/language_provider.dart';
import 'package:agrolinkbd/core/utils/number_converter.dart';

class EditPondScreen extends StatefulWidget {
  final PondModel pond;

  const EditPondScreen({super.key, required this.pond});

  @override
  State<EditPondScreen> createState() => _EditPondScreenState();
}

class _EditPondScreenState extends State<EditPondScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  late TextEditingController _nameController;
  late TextEditingController _areaController;
  late TextEditingController _speciesController;
  late TextEditingController _fishCountController;
  late TextEditingController _initialWeightController;
  late TextEditingController _targetWeightController;
  late TextEditingController _cycleDaysController;
  late TextEditingController _priceController;
  late TextEditingController _dailyFeedController;
  late TextEditingController _feedBrandController;
  late TextEditingController _locationController;
  late TextEditingController _managerNameController;
  late TextEditingController _managerPhoneController;
  late TextEditingController _customUrlController;

  // State selections
  late String _selectedCategory;
  late String _selectedWaterSource;
  late String _selectedBioSecurity;
  late String _selectedStatus;
  late int _aeratorCount;
  bool _isSubmitting = false;

  // Image Selection State
  File? _pickedImageFile;
  late String _currentImageUrl;

  @override
  void initState() {
    super.initState();
    final p = widget.pond;
    _nameController = TextEditingController(text: p.name);
    _areaController = TextEditingController(text: p.area);
    _speciesController = TextEditingController(text: p.fishSpecies);
    _fishCountController = TextEditingController(text: p.totalFishCount.toString());
    _initialWeightController = TextEditingController(text: p.avgWeightGrams.toStringAsFixed(0));
    _targetWeightController = TextEditingController(text: p.targetHarvestWeightGrams.toStringAsFixed(0));
    _cycleDaysController = TextEditingController(text: p.totalCycleDays.toString());
    _priceController = TextEditingController(text: p.expectedMarketPricePerKg.toStringAsFixed(0));
    _dailyFeedController = TextEditingController(text: p.dailyFeedingKg.toStringAsFixed(0));
    _feedBrandController = TextEditingController(text: p.feedBrand);
    _locationController = TextEditingController(text: p.location);
    _managerNameController = TextEditingController(text: p.farmManagerName);
    _managerPhoneController = TextEditingController(text: p.managerPhone);
    _customUrlController = TextEditingController();

    _selectedCategory = p.farmCategory;
    _selectedWaterSource = p.waterSource;
    _selectedBioSecurity = p.bioSecurityGrade;
    _selectedStatus = p.status;
    _aeratorCount = p.aeratorCount;
    _currentImageUrl = p.imageUrl;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _areaController.dispose();
    _speciesController.dispose();
    _fishCountController.dispose();
    _initialWeightController.dispose();
    _targetWeightController.dispose();
    _cycleDaysController.dispose();
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
        isBn ? 'ছবি নির্বাচন করা সম্ভব হয়নি।' : 'Failed to pick image.',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
    }
  }

  Future<void> _submitUpdate(bool isBn) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final pondController = Get.isRegistered<PondController>()
          ? Get.find<PondController>()
          : Get.put(PondController());

      String finalImageUrl = _currentImageUrl;

      if (_pickedImageFile != null) {
        try {
          final fileName = 'pond_images/pond_${widget.pond.id}_${DateTime.now().millisecondsSinceEpoch}.jpg';
          final storageRef = FirebaseStorage.instance.ref().child(fileName);
          await storageRef.putFile(_pickedImageFile!);
          finalImageUrl = await storageRef.getDownloadURL();
        } catch (e) {
          debugPrint('Pond update image upload error: $e');
        }
      } else if (_customUrlController.text.trim().isNotEmpty) {
        finalImageUrl = _customUrlController.text.trim();
      }

      final updatedPond = PondModel(
        id: widget.pond.id,
        userId: widget.pond.userId,
        name: _nameController.text.trim(),
        area: _areaController.text.trim(),
        fishSpecies: _speciesController.text.trim(),
        stockedDate: widget.pond.stockedDate,
        totalFishCount: BanglaEnglishNumberHelper.toInt(_fishCountController.text.trim(), widget.pond.totalFishCount),
        status: _selectedStatus,
        ph: widget.pond.ph,
        ammonia: widget.pond.ammonia,
        dissolvedOxygen: widget.pond.dissolvedOxygen,
        temperature: widget.pond.temperature,
        salinity: widget.pond.salinity,
        waterClarity: widget.pond.waterClarity,
        nitrite: widget.pond.nitrite,
        alkalinity: widget.pond.alkalinity,
        avgWeightGrams: BanglaEnglishNumberHelper.toDouble(_initialWeightController.text.trim(), widget.pond.avgWeightGrams),
        targetHarvestWeightGrams: BanglaEnglishNumberHelper.toDouble(_targetWeightController.text.trim(), widget.pond.targetHarvestWeightGrams),
        growthStage: widget.pond.growthStage,
        totalCycleDays: BanglaEnglishNumberHelper.toInt(_cycleDaysController.text.trim(), widget.pond.totalCycleDays),
        expectedMarketPricePerKg: BanglaEnglishNumberHelper.toDouble(_priceController.text.trim(), widget.pond.expectedMarketPricePerKg),
        fcr: widget.pond.fcr,
        survivalRatePercent: widget.pond.survivalRatePercent,
        dailyFeedingKg: BanglaEnglishNumberHelper.toDouble(_dailyFeedController.text.trim(), widget.pond.dailyFeedingKg),
        feedBrand: _feedBrandController.text.trim(),
        aeratorOn: widget.pond.aeratorOn,
        aeratorCount: _aeratorCount,
        autoFeederActive: widget.pond.autoFeederActive,
        farmCategory: _selectedCategory,
        bioSecurityGrade: _selectedBioSecurity,
        waterSource: _selectedWaterSource,
        imageUrl: finalImageUrl,
        galleryUrls: widget.pond.galleryUrls,
        location: _locationController.text.trim(),
        farmManagerName: _managerNameController.text.trim(),
        managerPhone: _managerPhoneController.text.trim(),
        activities: widget.pond.activities,
      );

      await pondController.updatePond(updatedPond);

      Get.back(result: true);
      Get.snackbar(
        isBn ? 'সফলভাবে হালনাগাদ করা হয়েছে! 🌊' : 'Updated Successfully! 🌊',
        isBn ? '${updatedPond.name} এর তথ্য আপডেট করা হয়েছে।' : '${updatedPond.name} has been updated.',
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
        isBn ? 'হালনাগাদ ব্যর্থ হয়েছে' : 'Update Failed',
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
          isBn ? 'পুকুরের তথ্য সম্পাদন' : 'Edit Pond Information',
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
              // SECTION 1: STATUS & CATEGORY
              _buildSectionCard(
                isDark,
                title: isBn ? '১. পুকুরের অবস্থা ও ক্যাটাগরি' : '1. Pond Status & Category',
                icon: Icons.category,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isBn ? 'বর্তমান স্বাস্থ্য অবস্থা:' : 'Current Health Status:',
                      style: GoogleFonts.hindSiliguri(fontSize: 13, fontWeight: FontWeight.bold, color: isDark ? Colors.white70 : Colors.black87),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        {'bn': 'স্বাভাবিক', 'en': 'Optimal', 'color': Colors.teal},
                        {'bn': 'সতর্কতা', 'en': 'Warning', 'color': Colors.orange},
                        {'bn': 'ঝুঁকিপূর্ণ', 'en': 'Critical', 'color': Colors.red},
                        {'bn': 'হারভেস্ট প্রস্তুত', 'en': 'Ready to Harvest', 'color': Colors.green},
                      ].map((statusMap) {
                        final statusBn = statusMap['bn'] as String;
                        final statusEn = statusMap['en'] as String;
                        final statusColor = statusMap['color'] as Color;
                        final isSelected = _selectedStatus == statusBn;
                        return ChoiceChip(
                          label: Text(
                            isBn ? statusBn : statusEn,
                            style: GoogleFonts.hindSiliguri(
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                            ),
                          ),
                          selected: isSelected,
                          selectedColor: statusColor,
                          backgroundColor: isDark ? const Color(0xFF16252F) : Theme.of(context).cardColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                            side: BorderSide(color: isSelected ? statusColor : (isDark ? Colors.white24 : Colors.grey.shade300)),
                          ),
                          onSelected: (val) {
                            setState(() {
                              _selectedStatus = statusBn;
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      isBn ? 'খামারের ধরন:' : 'Farm Type:',
                      style: GoogleFonts.hindSiliguri(fontSize: 13, fontWeight: FontWeight.bold, color: isDark ? Colors.white70 : Colors.black87),
                    ),
                    const SizedBox(height: 8),
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
                title: isBn ? '২. খামারের ছবি' : '2. Farm Image',
                icon: Icons.camera_alt,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          if (_pickedImageFile != null)
                            Image.file(
                              _pickedImageFile!,
                              height: 180,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            )
                          else
                            CachedNetworkImage(
                              imageUrl: _customUrlController.text.trim().isNotEmpty
                                  ? _customUrlController.text.trim()
                                  : _currentImageUrl,
                              height: 180,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorWidget: (c, u, e) => Container(
                                height: 180,
                                color: deepAqua,
                                child: const Icon(Icons.pool, size: 50, color: Colors.white),
                              ),
                            ),
                          if (_pickedImageFile != null)
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
                                  _pickedImageFile != null 
                                      ? (isBn ? 'নতুন ছবি নির্বাচিত' : 'New Photo Selected')
                                      : (isBn ? 'বর্তমান ছবি' : 'Current Photo'),
                                  style: GoogleFonts.hindSiliguri(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
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
                title: isBn ? '৩. পুকুর / ট্যাংকের প্রাথমিক তথ্য' : '3. Basic & Technical Specs',
                icon: Icons.water_drop,
                child: Column(
                  children: [
                    _buildTextField(
                      controller: _nameController,
                      label: isBn ? 'পুকুর / ট্যাংকের নাম *' : 'Pond / Tank Name *',
                      icon: Icons.pool,
                      validator: (v) => (v == null || v.trim().isEmpty) ? (isBn ? 'নাম আবশ্যক' : 'Name is required') : null,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: _areaController,
                      label: isBn ? 'আয়তন *' : 'Area *',
                      icon: Icons.straighten,
                      validator: (v) => (v == null || v.trim().isEmpty) ? (isBn ? 'আয়তন আবশ্যক' : 'Area is required') : null,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<int>(
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
                    _buildTextField(
                      controller: _locationController,
                      label: isBn ? 'খামার অবস্থান (উপজেলা, জেলা)' : 'Location (Upazila, District)',
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
                title: isBn ? '৪. মাছের পোনা মজুত ও টার্গেট' : '4. Stocking & Targets',
                icon: Icons.set_meal,
                child: Column(
                  children: [
                    _buildTextField(
                      controller: _speciesController,
                      label: isBn ? 'মাছের প্রজাতি ও জাত *' : 'Fish Species & Variety *',
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
                            icon: Icons.format_list_numbered,
                            keyboardType: TextInputType.number,
                            validator: (v) => (v == null || v.trim().isEmpty) ? (isBn ? 'সংখ্যা আবশ্যক' : 'Count is required') : null,
                            isDark: isDark,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildTextField(
                            controller: _initialWeightController,
                            label: isBn ? 'বর্তমান ওজন (গ্রাম)' : 'Current Weight (g)',
                            icon: Icons.scale,
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
                            controller: _targetWeightController,
                            label: isBn ? 'টার্গেট ওজন (গ্রাম)' : 'Target Weight (g)',
                            icon: Icons.fitness_center,
                            keyboardType: TextInputType.number,
                            isDark: isDark,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildTextField(
                            controller: _cycleDaysController,
                            label: isBn ? 'মোট সাইকেল দিন' : 'Total Cycle Days',
                            icon: Icons.calendar_month,
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
                            controller: _priceController,
                            label: isBn ? 'প্রত্যাশিত দর (৳/কেজি)' : 'Expected Price (৳/kg)',
                            icon: Icons.trending_up,
                            keyboardType: TextInputType.number,
                            isDark: isDark,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildTextField(
                            controller: _dailyFeedController,
                            label: isBn ? 'দৈনিক ফিড (কেজি)' : 'Daily Feed (kg)',
                            icon: Icons.inventory_2,
                            keyboardType: TextInputType.number,
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
                  onPressed: _isSubmitting ? null : () => _submitUpdate(isBn),
                  icon: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                        )
                      : const Icon(Icons.check_circle_rounded, color: Colors.white, size: 22),
                  label: Text(
                    _isSubmitting 
                        ? (isBn ? 'হালনাগাদ হচ্ছে...' : 'Updating...')
                        : (isBn ? 'পুকুরের তথ্য আপডেট করুন' : 'Update Pond Details'),
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
