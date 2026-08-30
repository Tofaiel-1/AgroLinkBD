import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:agrolinkbd/core/models/phase2_models/farm_models.dart';
import 'package:agrolinkbd/core/services/phase2_services/farm_service.dart';

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
  String _selectedSoil = 'দোআঁশ (Loam)';
  String _selectedWaterSource = 'নদীর মিষ্টি পানি ও গভীর নলকূপ';
  String _selectedBioSecurity = 'Grade A+ (SPF Certified)';
  String _selectedImageUrl = 'https://images.unsplash.com/photo-1544551763-46a013bb70d5?w=900&auto=format&fit=crop&q=80';

  final List<String> _soilTypes = [
    'দোআঁশ (Loam)',
    'বেলে দোআঁশ (Sandy Loam)',
    'এঁটেল দোআঁশ (Clay Loam)',
    'পলি দোআঁশ (Silt Loam)',
    'পলি (Silt)',
    'এঁটেল (Clay)',
    'বেলে (Sandy)',
    'পিট মাটি (Peat)',
    'এসিড সালফেট মাটি (Acid Sulphate)',
    'কালো মাটি (Black Soil)',
    'লাল মাটি (Red Soil)',
  ];

  final List<String> _waterSources = [
    'নদীর মিষ্টি পানি ও গভীর নলকূপ',
    'গভীর সাবমারসিবল নলকূপ',
    'জোয়ার-ভাটার লবণাক্ত খাঁড়ি গেট',
    'বৃষ্টি ও প্রাকৃতিক ক্যানেল',
    'ফিল্টার্ড আরএএস রিসার্কুলেশন প্ল্যান্ট',
    'ভূগর্ভস্থ স্প্রিং ওয়াটার',
  ];

  final List<String> _bioSecurityGrades = [
    'Grade A+ (SPF Certified)',
    'ইইউ এক্সপোর্ট কোয়ালিটি সার্টিফাইড',
    'হাইজিনিক ইনডোর সিস্টেম',
    'স্ট্যান্ডার্ড কমার্শিয়াল ফার্ম গ্রেড',
    'অর্গানিক বায়ো-সার্টিফাইড',
  ];

  final List<Map<String, dynamic>> _presetPhotos = [
    {
      'title': 'মেগা কার্প পুকুর',
      'url': 'https://images.unsplash.com/photo-1544551763-46a013bb70d5?w=900&auto=format&fit=crop&q=80',
      'type': FarmType.fishPond,
    },
    {
      'title': 'সাতক্ষীরা চিংড়ি ঘের',
      'url': 'https://images.unsplash.com/photo-1559742811-822873691df8?w=900&auto=format&fit=crop&q=80',
      'type': FarmType.shrimpGher,
    },
    {
      'title': 'সার্কুলার বায়োফ্লক',
      'url': 'https://images.unsplash.com/photo-1524704654690-b56c05c78a00?w=900&auto=format&fit=crop&q=80',
      'type': FarmType.biofloc,
    },
    {
      'title': 'আরএএস ইনডোর হ্যাচারি',
      'url': 'https://images.unsplash.com/photo-1519708227418-c8fd9a32b7a2?w=900&auto=format&fit=crop&q=80',
      'type': FarmType.rasAquaculture,
    },
    {
      'title': 'আধুনিক শস্য খেত',
      'url': 'https://images.unsplash.com/photo-1500382017468-9049fed747ef?w=900&auto=format&fit=crop&q=80',
      'type': FarmType.cropField,
    },
    {
      'title': 'স্মার্ট গ্রিনহাউস',
      'url': 'https://images.unsplash.com/photo-1585320806297-9794b3e4eeae?w=900&auto=format&fit=crop&q=80',
      'type': FarmType.greenhouse,
    },
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.farm?.name ?? '');
    _locationController = TextEditingController(text: widget.farm?.location ?? '');
    _areaController = TextEditingController(text: widget.farm != null ? widget.farm!.area.toString() : '২.৫');
    _waterAreaController = TextEditingController(text: widget.farm != null ? widget.farm!.area.toString() : '২.০');
    _pondsCountController = TextEditingController(text: widget.farm != null ? widget.farm!.pondCount.toString() : '৪');
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

  Future<void> _saveFarm() async {
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
        farmTypeStr: _selectedFarmType.displayNameBn,
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
            content: Text(widget.farm == null ? 'ফার্ম সফলভাবে ফায়ারবেসে যোগ করা হয়েছে' : 'ফার্ম তথ্য সফলভাবে আপডেট হয়েছে'),
            backgroundColor: const Color(0xFF006064),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('ত্রুটি: ${e.toString()}'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color deepAqua = Color(0xFF006064);

    return Scaffold(
      backgroundColor: const Color(0xFFF2F6F9),
      appBar: AppBar(
        backgroundColor: deepAqua,
        elevation: 0,
        title: Text(
          widget.farm == null ? 'নতুন খামার / ফার্ম যুক্ত করুন' : 'ফার্ম তথ্য সম্পাদনা',
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
                      title: '১. খামারের ধরন ও ক্যাটাগরি',
                      icon: Icons.category_rounded,
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: FarmType.values.map((type) {
                          final isSelected = _selectedFarmType == type;
                          return ChoiceChip(
                            label: Text(
                              type.displayNameBn,
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
                      title: '২. খামারের আসল ছবি (Real Photo)',
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
                          Text('অথেনটিক ফটো প্রিসেট থেকে বেছে নিন:', style: GoogleFonts.hindSiliguri(fontSize: 12.5, fontWeight: FontWeight.bold)),
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
                                              photo['title'],
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
                      title: '৩. খামারের বিস্তারিত তথ্য',
                      icon: Icons.info_outline_rounded,
                      child: Column(
                        children: [
                          _buildTextField(
                            controller: _nameController,
                            label: 'খামারের নাম *',
                            hint: 'যেমন: পদ্মা ড্রিম এগ্রো অ্যান্ড ফিশারিজ',
                            icon: Icons.landscape,
                            validator: (v) => v!.isEmpty ? 'নাম আবশ্যক' : null,
                          ),
                          const SizedBox(height: 12),
                          _buildTextField(
                            controller: _locationController,
                            label: 'খামার অবস্থান (উপজেলা, জেলা) *',
                            hint: 'যেমন: চাঁদপুর সদর, চাঁদপুর',
                            icon: Icons.location_on,
                            validator: (v) => v!.isEmpty ? 'অবস্থান দিন' : null,
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _buildTextField(
                                  controller: _areaController,
                                  label: 'মোট জমি (হেক্টর/একর)',
                                  icon: Icons.aspect_ratio,
                                  keyboardType: TextInputType.number,
                                  validator: (v) => v!.isEmpty ? 'আয়তন দিন' : null,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _buildTextField(
                                  controller: _waterAreaController,
                                  label: 'মোট জলাশয় (একর)',
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
                                  label: 'পুকুর / ট্যাংক সংখ্যা',
                                  icon: Icons.format_list_numbered,
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  value: _selectedSoil,
                                  decoration: InputDecoration(
                                    labelText: 'মাটির ধরন',
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                                  ),
                                  items: _soilTypes.map((s) => DropdownMenuItem(value: s, child: Text(s, style: GoogleFonts.hindSiliguri(fontSize: 12)))).toList(),
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
                              labelText: 'পানির প্রধান উৎস',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              prefixIcon: const Icon(Icons.waves, color: deepAqua),
                            ),
                            items: _waterSources.map((w) => DropdownMenuItem(value: w, child: Text(w, style: GoogleFonts.hindSiliguri(fontSize: 12.5)))).toList(),
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
                            items: _bioSecurityGrades.map((b) => DropdownMenuItem(value: b, child: Text(b, style: GoogleFonts.hindSiliguri(fontSize: 12.5)))).toList(),
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
                                  label: 'ম্যানেজার নাম',
                                  hint: 'মোঃ তোফায়েল আহমেদ',
                                  icon: Icons.person,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _buildTextField(
                                  controller: _managerPhoneController,
                                  label: 'ম্যানেজার ফোন',
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
                      onPressed: _saveFarm,
                      icon: const Icon(Icons.cloud_upload_rounded, color: Colors.white),
                      label: Text(
                        widget.farm == null ? 'খামার ফায়ারবেসে সংরক্ষণ করুন' : 'আপডেট সম্পন্ন করুন',
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