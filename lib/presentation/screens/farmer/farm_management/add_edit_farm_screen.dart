import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:agrolinkbd/core/models/phase2_models/farm_models.dart';
import 'package:agrolinkbd/core/services/phase2_services/farm_service.dart';
import 'package:agrolinkbd/core/providers/language_provider.dart';

class AddEditFarmScreen extends StatefulWidget {
  final Farm? farm;

  const AddEditFarmScreen({Key? key, this.farm}) : super(key: key);

  @override
  State<AddEditFarmScreen> createState() => _AddEditFarmScreenState();
}

class _AddEditFarmScreenState extends State<AddEditFarmScreen> {
  final _formKey = GlobalKey<FormState>();
  final _farmService = FarmService();
  bool _isLoading = false;

  late TextEditingController _nameController;
  late TextEditingController _locationController;
  late TextEditingController _areaController;
  late TextEditingController _waterAreaController;
  late TextEditingController _pondsCountController;
  late TextEditingController _managerNameController;
  late TextEditingController _managerPhoneController;
  late TextEditingController _customImageUrlController;

  FarmType _selectedFarmType = FarmType.fishPond;
  String _selectedSoil = 'loam';
  String _selectedWaterSource = 'river_sweet';
  String _selectedBioSecurity = 'grade_a';
  String _selectedImageUrl = 'https://images.unsplash.com/photo-1544551763-46a013bb70d5?w=900&auto=format&fit=crop&q=80';

  final List<Map<String, String>> _soilTypes = [
    {'id': 'loam', 'bn': 'দোআঁশ (Loam)', 'en': 'Loam Soil'},
    {'id': 'sandy_loam', 'bn': 'বেলে দোআঁশ (Sandy Loam)', 'en': 'Sandy Loam'},
    {'id': 'clay_loam', 'bn': 'এঁটেল দোআঁশ (Clay Loam)', 'en': 'Clay Loam'},
    {'id': 'silt_loam', 'bn': 'পলি দোআঁশ (Silt Loam)', 'en': 'Silt Loam'},
    {'id': 'silt', 'bn': 'পলি মাটি (Silt)', 'en': 'Silt Soil'},
    {'id': 'clay', 'bn': 'এঁটেল মাটি (Clay)', 'en': 'Clay Soil'},
    {'id': 'sandy', 'bn': 'বেলে মাটি (Sandy)', 'en': 'Sandy Soil'},
    {'id': 'peat', 'bn': 'পিট মাটি (Peat)', 'en': 'Peat Soil'},
    {'id': 'black', 'bn': 'কালো মাটি (Black Soil)', 'en': 'Black Soil'},
    {'id': 'red', 'bn': 'লাল মাটি (Red Soil)', 'en': 'Red Soil'},
  ];

  final List<Map<String, String>> _waterSources = [
    {'id': 'river_sweet', 'bn': 'নদীর মিষ্টি পানি ও গভীর নলকূপ', 'en': 'Freshwater River & Deep Tubewell'},
    {'id': 'submersible', 'bn': 'গভীর সাবমারসিবল নলকূপ', 'en': 'Deep Submersible Tubewell'},
    {'id': 'tidal_saline', 'bn': 'জোয়ার-ভাটার লবণাক্ত খাঁড়ি গেট', 'en': 'Tidal Saline Estuary / Canal'},
    {'id': 'rain_canal', 'bn': 'বৃষ্টি ও প্রাকৃতিক ক্যানেল', 'en': 'Rainwater & Natural Canal'},
    {'id': 'ras_recirc', 'bn': 'ফিল্টার্ড আরএএস প্ল্যান্ট', 'en': 'Filtered RAS Plant'},
    {'id': 'spring', 'bn': 'ভূগর্ভস্থ স্প্রিং ওয়াটার', 'en': 'Underground Spring Water'},
  ];

  final List<Map<String, String>> _bioSecurityGrades = [
    {'id': 'grade_a', 'bn': 'Grade A+ (SPF Certified)', 'en': 'Grade A+ (SPF Certified)'},
    {'id': 'eu_export', 'bn': 'ইইউ এক্সপোর্ট কোয়ালিটি সার্টিফাইড', 'en': 'EU Export Certified Standard'},
    {'id': 'indoor_clean', 'bn': 'হাইজিনিক ইনডোর সিস্টেম', 'en': 'Hygienic Indoor Facility'},
    {'id': 'commercial', 'bn': 'স্ট্যান্ডার্ড কমার্শিয়াল ফার্ম গ্রেড', 'en': 'Standard Commercial Farm Grade'},
    {'id': 'organic', 'bn': 'অর্গানিক বায়ো-সার্টিফাইড', 'en': 'Organic Bio-Certified'},
  ];

  final List<Map<String, dynamic>> _presetPhotos = [
    {
      'titleBn': 'মেগা কার্প পুকুর',
      'titleEn': 'Mega Carp Pond',
      'url': 'https://images.unsplash.com/photo-1544551763-46a013bb70d5?w=900&auto=format&fit=crop&q=80',
      'type': FarmType.fishPond,
    },
    {
      'titleBn': 'সাতক্ষীরা চিংড়ি ঘের',
      'titleEn': 'Satkhira Shrimp Gher',
      'url': 'https://images.unsplash.com/photo-1559742811-822873691df8?w=900&auto=format&fit=crop&q=80',
      'type': FarmType.shrimpGher,
    },
    {
      'titleBn': 'সার্কুলার বায়োফ্লক',
      'titleEn': 'Circular Biofloc',
      'url': 'https://images.unsplash.com/photo-1524704654690-b56c05c78a00?w=900&auto=format&fit=crop&q=80',
      'type': FarmType.biofloc,
    },
    {
      'titleBn': 'আরএএস ইনডোর হ্যাচারি',
      'titleEn': 'RAS Indoor Hatchery',
      'url': 'https://images.unsplash.com/photo-1519708227418-c8fd9a32b7a2?w=900&auto=format&fit=crop&q=80',
      'type': FarmType.rasAquaculture,
    },
    {
      'titleBn': 'আধুনিক শস্য খেত',
      'titleEn': 'Modern Crop Field',
      'url': 'https://images.unsplash.com/photo-1500382017468-9049fed747ef?w=900&auto=format&fit=crop&q=80',
      'type': FarmType.cropField,
    },
    {
      'titleBn': 'স্মার্ট গ্রিনহাউস',
      'titleEn': 'Smart Greenhouse',
      'url': 'https://images.unsplash.com/photo-1585320806297-9794b3e4eeae?w=900&auto=format&fit=crop&q=80',
      'type': FarmType.greenhouse,
    },
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.farm?.name ?? '');
    _locationController = TextEditingController(text: widget.farm?.location ?? '');
    _areaController = TextEditingController(text: widget.farm != null ? widget.farm!.area.toString() : '2.5');
    _waterAreaController = TextEditingController(text: widget.farm != null ? widget.farm!.area.toString() : '2.0');
    _pondsCountController = TextEditingController(text: widget.farm != null ? widget.farm!.pondCount.toString() : '4');
    _managerNameController = TextEditingController(text: widget.farm?.farmManagerName ?? '');
    _managerPhoneController = TextEditingController(text: widget.farm?.managerPhone ?? '');
    _customImageUrlController = TextEditingController();

    if (widget.farm != null) {
      _selectedFarmType = widget.farm!.farmType;
      _selectedSoil = widget.farm!.soilType;
      _selectedWaterSource = widget.farm!.waterSource;
      _selectedBioSecurity = widget.farm!.bioSecurityRating;
      _selectedImageUrl = widget.farm!.imageUrl;
      _pondsCountController.text = widget.farm!.pondCount.toString();
      _managerNameController.text = widget.farm!.farmManagerName;
      _managerPhoneController.text = widget.farm!.managerPhone;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _areaController.dispose();
    _waterAreaController.dispose();
    _pondsCountController.dispose();
    _managerNameController.dispose();
    _managerPhoneController.dispose();
    _customImageUrlController.dispose();
    super.dispose();
  }

  Future<void> _saveFarm(bool isBn) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final imgUrl = _customImageUrlController.text.trim().isNotEmpty
          ? _customImageUrlController.text.trim()
          : _selectedImageUrl;

      final farm = Farm(
        id: widget.farm?.id ?? '',
        userId: widget.farm?.userId ?? '',
        name: _nameController.text.trim(),
        area: double.tryParse(_areaController.text.trim()) ?? 0.0,
        location: _locationController.text.trim(),
        crops: widget.farm?.crops ?? [],
        established: widget.farm?.established ?? DateTime.now(),
        soilType: _selectedSoil,
        farmTypeStr: isBn ? _selectedFarmType.displayNameBn : _selectedFarmType.displayNameEn,
        waterSource: _selectedWaterSource,
        bioSecurityRating: _selectedBioSecurity,
        pondCount: int.tryParse(_pondsCountController.text.trim()) ?? 1,
        farmManagerName: _managerNameController.text.trim(),
        managerPhone: _managerPhoneController.text.trim(),
        imageUrl: imgUrl,
        latitude: widget.farm?.latitude ?? 0.0,
        longitude: widget.farm?.longitude ?? 0.0,
      );

      if (widget.farm == null) {
        await _farmService.createFarm(farm);
      } else {
        await _farmService.updateFarm(farm);
      }

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.farm == null 
                ? (isBn ? 'ফার্ম সফলভাবে ফায়ারবেসে যোগ করা হয়েছে' : 'Farm added successfully')
                : (isBn ? 'ফার্ম তথ্য সফলভাবে আপডেট হয়েছে' : 'Farm updated successfully')),
            backgroundColor: const Color(0xFF006064),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${isBn ? "ত্রুটি:" : "Error:"} ${e.toString()}'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color deepAqua = Color(0xFF006064);
    final bool isBn = LanguageProvider.isBn(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF2F6F9),
      appBar: AppBar(
        backgroundColor: deepAqua,
        elevation: 0,
        title: Text(
          widget.farm == null 
              ? (isBn ? 'নতুন খামার / ফার্ম যুক্ত করুন' : 'Add New Farm / Plot')
              : (isBn ? 'ফার্ম তথ্য সম্পাদনা' : 'Edit Farm Details'),
          style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 18),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: deepAqua))
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Section 1: Farm Type
                    _buildCard(
                      title: isBn ? '১. খামারের ধরন ও ক্যাটাগরি' : '1. Farm Type & Category',
                      icon: Icons.category_rounded,
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: FarmType.values.map((type) {
                          final isSelected = _selectedFarmType == type;
                          final label = isBn ? type.displayNameBn : type.displayNameEn;
                          return ChoiceChip(
                            label: Text(
                              label,
                              style: GoogleFonts.hindSiliguri(
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                color: isSelected ? Colors.white : Colors.black87,
                              ),
                            ),
                            selected: isSelected,
                            selectedColor: deepAqua,
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(color: isSelected ? deepAqua : Colors.grey.shade300),
                            ),
                            onSelected: (val) {
                              setState(() {
                                _selectedFarmType = type;
                                _selectedImageUrl = type.defaultImage;
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Section 2: Real Farm Photo Preview & Presets
                    _buildCard(
                      title: isBn ? '২. খামারের আসল ছবি (Real Photo)' : '2. Farm Photo & Presets',
                      icon: Icons.photo_camera_rounded,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: CachedNetworkImage(
                              imageUrl: _customImageUrlController.text.trim().isNotEmpty
                                  ? _customImageUrlController.text.trim()
                                  : _selectedImageUrl,
                              height: 160,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorWidget: (c, u, e) => Container(
                                height: 160,
                                color: deepAqua,
                                child: const Icon(Icons.landscape, size: 50, color: Colors.white),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            isBn ? 'অথেনটিক ফটো প্রিসেট থেকে বেছে নিন:' : 'Choose from high-res farm presets:',
                            style: GoogleFonts.hindSiliguri(fontSize: 12.5, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            height: 75,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              physics: const BouncingScrollPhysics(),
                              itemCount: _presetPhotos.length,
                              itemBuilder: (context, index) {
                                final photo = _presetPhotos[index];
                                final isSelected = _selectedImageUrl == photo['url'];
                                final title = isBn ? photo['titleBn'] : photo['titleEn'];
                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _customImageUrlController.clear();
                                      _selectedImageUrl = photo['url'];
                                      _selectedFarmType = photo['type'] as FarmType;
                                    });
                                  },
                                  child: Container(
                                    width: 100,
                                    margin: const EdgeInsets.only(right: 8),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: isSelected ? deepAqua : Colors.grey.shade300, width: isSelected ? 2.5 : 1),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(9),
                                      child: Stack(
                                        fit: StackFit.expand,
                                        children: [
                                          CachedNetworkImage(imageUrl: photo['url'], fit: BoxFit.cover),
                                          Container(color: Colors.black26),
                                          Positioned(
                                            bottom: 4,
                                            left: 4,
                                            right: 4,
                                            child: Text(
                                              title,
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

                    // Section 3: Farm Details
                    _buildCard(
                      title: isBn ? '৩. খামারের বিস্তারিত তথ্য' : '3. Farm Specifics & Infrastructure',
                      icon: Icons.info_outline_rounded,
                      child: Column(
                        children: [
                          _buildTextField(
                            controller: _nameController,
                            label: isBn ? 'খামারের নাম *' : 'Farm Name *',
                            hint: isBn ? 'যেমন: পদ্মা ড্রিম এগ্রো অ্যান্ড ফিশারিজ' : 'e.g., Green Valley Agri Farm',
                            icon: Icons.landscape,
                            validator: (v) => v!.isEmpty ? (isBn ? 'নাম আবশ্যক' : 'Name is required') : null,
                          ),
                          const SizedBox(height: 12),
                          _buildTextField(
                            controller: _locationController,
                            label: isBn ? 'খামার অবস্থান (উপজেলা, জেলা) *' : 'Location (Upazila, District) *',
                            hint: isBn ? 'যেমন: চাঁদপুর সদর, চাঁদপুর' : 'e.g., Bogura Sadar, Bogura',
                            icon: Icons.location_on,
                            validator: (v) => v!.isEmpty ? (isBn ? 'অবস্থান দিন' : 'Location is required') : null,
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _buildTextField(
                                  controller: _areaController,
                                  label: isBn ? 'মোট জমি (হেক্টর/একর)' : 'Total Land (Acres)',
                                  icon: Icons.aspect_ratio,
                                  keyboardType: TextInputType.number,
                                  validator: (v) => v!.isEmpty ? (isBn ? 'আয়তন দিন' : 'Required') : null,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _buildTextField(
                                  controller: _waterAreaController,
                                  label: isBn ? 'মোট জলাশয় (একর)' : 'Water Area (Acres)',
                                  icon: Icons.water_drop,
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _buildTextField(
                                  controller: _pondsCountController,
                                  label: isBn ? 'পুকুর / প্লট সংখ্যা' : 'Ponds / Plots Count',
                                  icon: Icons.format_list_numbered,
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  value: _selectedSoil,
                                  decoration: InputDecoration(
                                    labelText: isBn ? 'মাটির ধরন' : 'Soil Type',
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                                  ),
                                  items: _soilTypes.map((s) => DropdownMenuItem(
                                    value: s['id']!,
                                    child: Text(isBn ? s['bn']! : s['en']!, style: GoogleFonts.hindSiliguri(fontSize: 12)),
                                  )).toList(),
                                  onChanged: (val) {
                                    if (val != null) setState(() => _selectedSoil = val);
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<String>(
                            value: _selectedWaterSource,
                            decoration: InputDecoration(
                              labelText: isBn ? 'পানির প্রধান উৎস' : 'Main Water Source',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              prefixIcon: const Icon(Icons.waves, color: deepAqua),
                            ),
                            items: _waterSources.map((w) => DropdownMenuItem(
                              value: w['id']!,
                              child: Text(isBn ? w['bn']! : w['en']!, style: GoogleFonts.hindSiliguri(fontSize: 12.5)),
                            )).toList(),
                            onChanged: (val) {
                              if (val != null) setState(() => _selectedWaterSource = val);
                            },
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<String>(
                            value: _selectedBioSecurity,
                            decoration: InputDecoration(
                              labelText: isBn ? 'বায়োসিকিউরিটি রেটিং' : 'Biosecurity Grade',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              prefixIcon: const Icon(Icons.verified_user, color: Colors.green),
                            ),
                            items: _bioSecurityGrades.map((b) => DropdownMenuItem(
                              value: b['id']!,
                              child: Text(isBn ? b['bn']! : b['en']!, style: GoogleFonts.hindSiliguri(fontSize: 12.5)),
                            )).toList(),
                            onChanged: (val) {
                              if (val != null) setState(() => _selectedBioSecurity = val);
                            },
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _buildTextField(
                                  controller: _managerNameController,
                                  label: isBn ? 'ম্যানেজার নাম' : 'Manager Name',
                                  hint: isBn ? 'যেমন: মোঃ করিম' : 'e.g., Md. Karim',
                                  icon: Icons.person,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _buildTextField(
                                  controller: _managerPhoneController,
                                  label: isBn ? 'ম্যানেজার ফোন' : 'Manager Phone',
                                  hint: '01711223344',
                                  icon: Icons.phone,
                                  keyboardType: TextInputType.phone,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Save Button
                    ElevatedButton.icon(
                      onPressed: () => _saveFarm(isBn),
                      icon: const Icon(Icons.cloud_upload_rounded, color: Colors.white),
                      label: Text(
                        widget.farm == null 
                            ? (isBn ? 'খামার ফায়ারবেসে সংরক্ষণ করুন' : 'Save Farm to Database')
                            : (isBn ? 'আপডেট সম্পন্ন করুন' : 'Save Changes'),
                        style: GoogleFonts.hindSiliguri(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: deepAqua,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 4,
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildCard({required String title, required IconData icon, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 3)),
        ],
        border: Border.all(color: Colors.grey.shade200),
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
                style: GoogleFonts.hindSiliguri(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87),
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
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: GoogleFonts.hindSiliguri(fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: GoogleFonts.hindSiliguri(color: Colors.grey.shade700, fontSize: 13),
        hintStyle: GoogleFonts.hindSiliguri(color: Colors.grey.shade400, fontSize: 12),
        prefixIcon: Icon(icon, color: const Color(0xFF006064), size: 20),
        filled: true,
        fillColor: const Color(0xFFF9FBFC),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF006064), width: 1.8)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
      validator: validator,
    );
  }
}