import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:agrolinkbd/core/models/pond_model.dart';
import 'package:agrolinkbd/core/controllers/pond_controller.dart';

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
  late String _selectedPresetImageUrl;

  final List<Map<String, String>> _realPresetImages = [
    {
      'title': 'বাণিজ্যিক কার্প পুকুর (চাঁদপুর)',
      'url': 'https://images.unsplash.com/photo-1544551763-46a013bb70d5?w=900&auto=format&fit=crop&q=80',
      'category': 'বাণিজ্যিক কার্প পুকুর',
    },
    {
      'title': 'সার্কুলার বায়োফ্লক ট্যাংক (ত্রিশাল)',
      'url': 'https://images.unsplash.com/photo-1524704654690-b56c05c78a00?w=900&auto=format&fit=crop&q=80',
      'category': 'বায়োফ্লক ট্যাংক',
    },
    {
      'title': 'রপ্তানি গ্রেড চিংড়ি ঘের (সাতক্ষীরা)',
      'url': 'https://images.unsplash.com/photo-1559742811-822873691df8?w=900&auto=format&fit=crop&q=80',
      'category': 'চিংড়ি ঘের',
    },
    {
      'title': 'আরএএস ইনডোর হ্যাচারি (চট্টগ্রাম)',
      'url': 'https://images.unsplash.com/photo-1519708227418-c8fd9a32b7a2?w=900&auto=format&fit=crop&q=80',
      'category': 'আরএএস সিস্টেম',
    },
    {
      'title': 'মনোসেক্স তেলাপিয়া ফার্ম (চলনবিল)',
      'url': 'https://images.unsplash.com/photo-1534483509719-3feaee7c30da?w=900&auto=format&fit=crop&q=80',
      'category': 'বাণিজ্যিক কার্প পুকুর',
    },
    {
      'title': 'হাই-টেক ওয়াটার এয়ারেশন জোন',
      'url': 'https://images.unsplash.com/photo-1500382017468-9049fed747ef?w=900&auto=format&fit=crop&q=80',
      'category': 'বাণিজ্যিক কার্প পুকুর',
    },
  ];

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
    _selectedPresetImageUrl = p.imageUrl;
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

  Future<void> _pickImage(ImageSource source) async {
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
        'ক্যামেরা / গ্যালারি এরর',
        'ছবি নির্বাচন করা সম্ভব হয়নি।',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
    }
  }

  Future<void> _submitUpdate() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final pondController = Get.find<PondController>();

      final String finalImageUrl = _customUrlController.text.trim().isNotEmpty
          ? _customUrlController.text.trim()
          : _selectedPresetImageUrl;

      final updatedPond = PondModel(
        id: widget.pond.id,
        userId: widget.pond.userId,
        name: _nameController.text.trim(),
        area: _areaController.text.trim(),
        fishSpecies: _speciesController.text.trim(),
        stockedDate: widget.pond.stockedDate,
        totalFishCount: int.tryParse(_fishCountController.text.trim()) ?? widget.pond.totalFishCount,
        status: _selectedStatus,
        ph: widget.pond.ph,
        ammonia: widget.pond.ammonia,
        dissolvedOxygen: widget.pond.dissolvedOxygen,
        temperature: widget.pond.temperature,
        salinity: widget.pond.salinity,
        waterClarity: widget.pond.waterClarity,
        nitrite: widget.pond.nitrite,
        alkalinity: widget.pond.alkalinity,
        avgWeightGrams: double.tryParse(_initialWeightController.text.trim()) ?? widget.pond.avgWeightGrams,
        targetHarvestWeightGrams: double.tryParse(_targetWeightController.text.trim()) ?? widget.pond.targetHarvestWeightGrams,
        growthStage: widget.pond.growthStage,
        totalCycleDays: int.tryParse(_cycleDaysController.text.trim()) ?? widget.pond.totalCycleDays,
        expectedMarketPricePerKg: double.tryParse(_priceController.text.trim()) ?? widget.pond.expectedMarketPricePerKg,
        fcr: widget.pond.fcr,
        survivalRatePercent: widget.pond.survivalRatePercent,
        dailyFeedingKg: double.tryParse(_dailyFeedController.text.trim()) ?? widget.pond.dailyFeedingKg,
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

      Get.back(result: updatedPond);
      Get.snackbar(
        'সফলভাবে আপডেট হয়েছে! 🌊',
        '${updatedPond.name} এর নতুন তথ্য ফায়ারবেসে সংরক্ষিত হয়েছে।',
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
        'আপডেট ব্যর্থ হয়েছে',
        'ত্রুটি: $e',
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const Color deepAqua = Color(0xFF006064);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0A1218) : const Color(0xFFF1F5F8),
      appBar: AppBar(
        title: Text(
          'পুকুর / ট্যাংক তথ্য সম্পাদনা',
          style: GoogleFonts.hindSiliguri(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        backgroundColor: deepAqua,
        elevation: 0,
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
                title: '১. খামারের ধরন ও ক্যাটাগরি',
                icon: Icons.category,
                child: Column(
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        'বাণিজ্যিক কার্প পুকুর',
                        'বায়োফ্লক ট্যাংক',
                        'চিংড়ি ঘের',
                        'আরএএস সিস্টেম',
                        'হ্যাচারি ও নার্সারি',
                      ].map((cat) {
                        final isSelected = _selectedCategory == cat;
                        return ChoiceChip(
                          label: Text(
                            cat,
                            style: GoogleFonts.hindSiliguri(
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              color: isSelected ? Colors.white : Colors.black87,
                            ),
                          ),
                          selected: isSelected,
                          selectedColor: deepAqua,
                          backgroundColor: Theme.of(context).cardColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                            side: BorderSide(color: isSelected ? deepAqua : Colors.grey.shade300),
                          ),
                          onSelected: (val) {
                            setState(() {
                              _selectedCategory = cat;
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
                title: '২. খামারের আসল ছবি (Real Image)',
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
                                  : _selectedPresetImageUrl,
                              height: 180,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorWidget: (c, u, e) => Container(
                                height: 180,
                                color: deepAqua,
                                child: const Icon(Icons.pool, size: 50, color: Colors.white),
                              ),
                            ),
                          Container(
                            margin: const EdgeInsets.all(10),
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.7),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.check_circle, color: Colors.greenAccent, size: 14),
                                const SizedBox(width: 4),
                                Text(
                                  _pickedImageFile != null ? 'ক্যামেরা ছবি সক্রিয়' : 'ছবি নির্বাচন নিশ্চিত',
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
                            onPressed: () => _pickImage(ImageSource.camera),
                            icon: const Icon(Icons.camera_alt, size: 18, color: deepAqua),
                            label: Text('ক্যামেরা ছবি', style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, color: deepAqua)),
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
                            onPressed: () => _pickImage(ImageSource.gallery),
                            icon: const Icon(Icons.photo_library, size: 18, color: Color(0xFF0288D1)),
                            label: Text('গ্যালারি', style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, color: const Color(0xFF0288D1))),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              side: const BorderSide(color: Color(0xFF0288D1)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    Text('অথবা প্রিসেট থেকে পরিবর্তন করুন:', style: GoogleFonts.hindSiliguri(fontSize: 12.5, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),

                    SizedBox(
                      height: 80,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        itemCount: _realPresetImages.length,
                        itemBuilder: (context, index) {
                          final preset = _realPresetImages[index];
                          final isSelected = _pickedImageFile == null && _selectedPresetImageUrl == preset['url'];

                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _pickedImageFile = null;
                                _customUrlController.clear();
                                _selectedPresetImageUrl = preset['url']!;
                              });
                            },
                            child: Container(
                              width: 105,
                              margin: const EdgeInsets.only(right: 10),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected ? Colors.teal : Colors.grey.shade300,
                                  width: isSelected ? 2.5 : 1,
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    CachedNetworkImage(imageUrl: preset['url']!, fit: BoxFit.cover),
                                    Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [Colors.transparent, Colors.black.withValues(alpha: 0.8)],
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 4,
                                      left: 4,
                                      right: 4,
                                      child: Text(
                                        preset['title']!,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.hindSiliguri(color: Colors.white, fontSize: 9.5, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // SECTION 3: BASIC & TECHNICAL DETAILS
              _buildSectionCard(
                isDark,
                title: '৩. পুকুর / ট্যাংকের কারিগরি তথ্য',
                icon: Icons.water_drop,
                child: Column(
                  children: [
                    _buildTextField(
                      controller: _nameController,
                      label: 'পুকুর / ট্যাংকের নাম *',
                      icon: Icons.pool,
                      validator: (v) => v!.isEmpty ? 'নাম আবশ্যক' : null,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: _buildTextField(
                            controller: _areaController,
                            label: 'আয়তন *',
                            icon: Icons.straighten,
                            validator: (v) => v!.isEmpty ? 'আয়তন আবশ্যক' : null,
                            isDark: isDark,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 1,
                          child: DropdownButtonFormField<int>(
                            value: _aeratorCount,
                            decoration: InputDecoration(
                              labelText: 'অ্যারেটর',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                            ),
                            items: [0, 2, 4, 6, 8, 12].map((c) {
                              return DropdownMenuItem(value: c, child: Text('$c টি', style: GoogleFonts.hindSiliguri(fontSize: 12)));
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
                      decoration: InputDecoration(
                        labelText: 'পানির উৎস',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        prefixIcon: const Icon(Icons.waves, color: deepAqua),
                      ),
                      items: [
                        'নদীর মিষ্টি পানি ও গভীর নলকূপ',
                        'গভীর সাবমারসিবল নলকূপ',
                        'জোয়ার-ভাটার লবণাক্ত খাঁড়ি গেট',
                        'বৃষ্টি ও প্রাকৃতিক ক্যানেল',
                        'ফিল্টার্ড আরএএস রিসার্কুলেশন প্ল্যান্ট',
                      ].map((w) => DropdownMenuItem(value: w, child: Text(w, style: GoogleFonts.hindSiliguri(fontSize: 12.5)))).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedWaterSource = val);
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _selectedBioSecurity,
                      decoration: InputDecoration(
                        labelText: 'বায়োসিকিউরিটি রেটিং',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        prefixIcon: const Icon(Icons.verified_user, color: Colors.green),
                      ),
                      items: [
                        'Grade A+ (শতভাগ রোগমুক্ত ও অর্গানিক)',
                        'ইইউ এক্সপোর্ট কোয়ালিটি সার্টিফাইড',
                        'হাইজিনিক ইনডোর বায়োফ্লক সিস্টেম',
                        'স্ট্যান্ডার্ড কমার্শিয়াল ফার্ম গ্রেড',
                      ].map((b) => DropdownMenuItem(value: b, child: Text(b, style: GoogleFonts.hindSiliguri(fontSize: 12.5)))).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedBioSecurity = val);
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: _locationController,
                      label: 'খামার অবস্থান (উপজেলা, জেলা)',
                      icon: Icons.location_on,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: _managerNameController,
                            label: 'ফার্ম ম্যানেজার',
                            icon: Icons.person,
                            isDark: isDark,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildTextField(
                            controller: _managerPhoneController,
                            label: 'ফোন নম্বর',
                            icon: Icons.phone,
                            keyboardType: TextInputType.phone,
                            isDark: isDark,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // SECTION 4: FISH STOCK & TARGETS
              _buildSectionCard(
                isDark,
                title: '৪. মাছের পোনা মজুত ও ফিডিং শিডিউল',
                icon: Icons.set_meal,
                child: Column(
                  children: [
                    _buildTextField(
                      controller: _speciesController,
                      label: 'মাছের প্রজাতি ও জাত *',
                      icon: Icons.phishing,
                      validator: (v) => v!.isEmpty ? 'প্রজাতি আবশ্যক' : null,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: _fishCountController,
                            label: 'মোট পোনা সংখ্যা *',
                            icon: Icons.format_list_numbered,
                            keyboardType: TextInputType.number,
                            validator: (v) => v!.isEmpty ? 'সংখ্যা আবশ্যক' : null,
                            isDark: isDark,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildTextField(
                            controller: _initialWeightController,
                            label: 'বর্তমান গড় ওজন (গ্রাম)',
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
                            label: 'টার্গেট ওজন (গ্রাম)',
                            icon: Icons.fitness_center,
                            keyboardType: TextInputType.number,
                            isDark: isDark,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildTextField(
                            controller: _priceController,
                            label: 'বাজার দর (৳/কেজি)',
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
                            label: 'দৈনিক ফিড (কেজি)',
                            icon: Icons.inventory_2,
                            keyboardType: TextInputType.number,
                            isDark: isDark,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildTextField(
                            controller: _feedBrandController,
                            label: 'ফিড ব্র্যান্ড ও প্রোটিন %',
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

              // UPDATE BUTTON
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isSubmitting ? null : _submitUpdate,
                  icon: _isSubmitting
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                      : const Icon(Icons.check_circle_outline_rounded, color: Colors.white, size: 22),
                  label: Text(
                    _isSubmitting ? 'ফায়ারবেসে আপডেট হচ্ছে...' : 'আপডেট সম্পন্ন ও সেভ করুন',
                    style: GoogleFonts.hindSiliguri(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
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
              Text(
                title,
                style: GoogleFonts.hindSiliguri(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
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
        hintStyle: GoogleFonts.hindSiliguri(color: Colors.grey.shade400, fontSize: 12),
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
