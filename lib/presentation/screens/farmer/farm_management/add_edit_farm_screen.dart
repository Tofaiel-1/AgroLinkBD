import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
  // Removed _soilController – will use _selectedSoil instead
  String? _selectedSoil; // New variable for dropdown value

  // বাংলাদেশের প্রচলিত মাটির ধরন (বৈজ্ঞানিক ও স্থানীয় নাম)
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

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.farm?.name ?? '');
    _locationController = TextEditingController(text: widget.farm?.location ?? '');
    _areaController = TextEditingController(text: widget.farm != null ? widget.farm!.area.toString() : '');
    // Set initial soil type from farm, or null
    _selectedSoil = widget.farm?.soilType ?? _soilTypes.first; // default to first if null
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _areaController.dispose();
    // No need to dispose _selectedSoil
    super.dispose();
  }

  Future<void> _saveFarm() async {
    if (!_formKey.currentState!.validate()) return;

    // Validate that a soil type is selected (though dropdown ensures it)
    if (_selectedSoil == null || _selectedSoil!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('দয়া করে মাটির ধরন নির্বাচন করুন'), backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final farm = Farm(
        id: widget.farm?.id ?? '',
        userId: widget.farm?.userId ?? '',
        name: _nameController.text.trim(),
        area: double.tryParse(_areaController.text.trim()) ?? 0.0,
        location: _locationController.text.trim(),
        crops: widget.farm?.crops ?? [],
        established: widget.farm?.established ?? DateTime.now(),
        soilType: _selectedSoil!, // Use dropdown value
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
            content: Text(widget.farm == null ? 'ফার্ম সফলভাবে যোগ করা হয়েছে' : 'ফার্ম সফলভাবে আপডেট করা হয়েছে'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('ত্রুটি: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E7D32),
        elevation: 0,
        title: Text(
          widget.farm == null ? 'নতুন ফার্ম যোগ করুন' : 'ফার্ম সম্পাদনা',
          style: GoogleFonts.openSans(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF2E7D32)))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildTextField(
                      controller: _nameController,
                      label: 'ফার্মের নাম',
                      icon: Icons.landscape,
                      validator: (value) => value!.isEmpty ? 'নাম দিন' : null,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _locationController,
                      label: 'অবস্থান',
                      icon: Icons.location_on,
                      validator: (value) => value!.isEmpty ? 'অবস্থান দিন' : null,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: _areaController,
                            label: 'আয়তন (হেক্টর)',
                            icon: Icons.aspect_ratio,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            validator: (value) {
                              if (value!.isEmpty) return 'প্রয়োজন';
                              if (double.tryParse(value) == null) return 'সঠিক সংখ্যা দিন';
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildDropdownField(), // নতুন ড্রপডাউন উইজেট
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                    ElevatedButton(
                      onPressed: _saveFarm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E7D32),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 4,
                      ),
                      child: Text(
                        widget.farm == null ? 'ফার্ম যোগ করুন' : 'সংরক্ষণ করুন',
                        style: GoogleFonts.openSans(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  // আগের মতো টেক্সট ফিল্ড (অপরিবর্তিত)
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      style: GoogleFonts.openSans(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF2D3748),
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.openSans(color: Colors.grey.shade600),
        prefixIcon: Icon(icon, color: const Color(0xFF4CAF50)),
        filled: true,
        fillColor: Colors.white,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF4CAF50), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
      ),
    );
  }

  // নতুন ড্রপডাউন উইজেট – ডিজাইন টেক্সট ফিল্ডের সাথে মিল রেখে
  Widget _buildDropdownField() {
    return DropdownButtonFormField<String>(
      value: _selectedSoil,
      isExpanded: true,
      items: _soilTypes.map((soil) {
        return DropdownMenuItem<String>(
          value: soil,
          child: Text(
            soil,
            style: GoogleFonts.openSans(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF2D3748),
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedSoil = value;
        });
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'মাটির ধরন নির্বাচন করুন';
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: 'মাটির ধরন',
        labelStyle: GoogleFonts.openSans(color: Colors.grey.shade600),
        prefixIcon: const Icon(Icons.grass, color: Color(0xFF4CAF50)),
        filled: true,
        fillColor: Colors.white,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF4CAF50), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
      ),
      // ড্রপডাউনের স্টাইল (ঐচ্ছিক)
      icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF4CAF50)),
      dropdownColor: Colors.white,
      style: GoogleFonts.openSans(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF2D3748),
      ),
    );
  }
}