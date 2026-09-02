import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:agrolinkbd/core/models/phase2_models/farm_models.dart';
import 'package:agrolinkbd/core/services/phase2_services/farm_service.dart';
import 'package:agrolinkbd/core/providers/language_provider.dart';

class AddEditCropScreen extends StatefulWidget {
  final CropPlanting? crop;

  const AddEditCropScreen({Key? key, this.crop}) : super(key: key);

  @override
  State<AddEditCropScreen> createState() => _AddEditCropScreenState();
}

class _AddEditCropScreenState extends State<AddEditCropScreen> {
  final _formKey = GlobalKey<FormState>();
  final _farmService = FarmService();
  bool _isLoading = false;

  late TextEditingController _nameController;
  late TextEditingController _areaController;
  late TextEditingController _yieldController;
  late TextEditingController _statusController;
  late TextEditingController _farmIdController; // To link to a farm

  List<Farm> _myFarms = [];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.crop?.cropName ?? '');
    _areaController = TextEditingController(text: widget.crop != null ? widget.crop!.area.toString() : '');
    _yieldController = TextEditingController(text: widget.crop != null ? widget.crop!.expectedYield.toString() : '');
    _statusController = TextEditingController(text: widget.crop?.status ?? 'planted');
    _farmIdController = TextEditingController(text: widget.crop?.farmId ?? '');
    _loadFarms();
  }

  Future<void> _loadFarms() async {
    final farms = await _farmService.getFarms();
    if (mounted) {
      setState(() {
        _myFarms = farms;
        if (_farmIdController.text.isEmpty && farms.isNotEmpty) {
          _farmIdController.text = farms.first.id;
        }
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _areaController.dispose();
    _yieldController.dispose();
    _statusController.dispose();
    _farmIdController.dispose();
    super.dispose();
  }

  Future<void> _saveCrop(bool isBn) async {
    if (!_formKey.currentState!.validate()) return;
    if (_farmIdController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(isBn ? 'প্রথমে একটি খামার নির্বাচন করুন' : 'Please select a farm first')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final crop = CropPlanting(
        id: widget.crop?.id ?? '',
        userId: widget.crop?.userId ?? '', 
        farmId: _farmIdController.text,
        cropName: _nameController.text.trim(),
        plantedDate: widget.crop?.plantedDate ?? DateTime.now(),
        expectedHarvestDate: widget.crop?.expectedHarvestDate ?? DateTime.now().add(const Duration(days: 90)),
        area: double.tryParse(_areaController.text.trim()) ?? 0.0,
        soilPreparation: widget.crop?.soilPreparation ?? '',
        fertilizersUsed: widget.crop?.fertilizersUsed ?? [],
        pesticidesUsed: widget.crop?.pesticidesUsed ?? [],
        expectedYield: double.tryParse(_yieldController.text.trim()) ?? 0.0,
        status: _statusController.text.trim(),
      );

      if (widget.crop == null) {
        await _farmService.addCropPlanting(crop);
      }

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.crop == null 
                ? (isBn ? 'ফসল ট্র্যাকিং সফলভাবে যোগ করা হয়েছে' : 'Crop added successfully')
                : (isBn ? 'ফসল তথ্য সফলভাবে আপডেট হয়েছে' : 'Crop updated successfully')),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${isBn ? "ত্রুটি:" : "Error:"} ${e.toString()}'),
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
    final bool isBn = LanguageProvider.isBn(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF8BC34A),
        elevation: 0,
        title: Text(
          widget.crop == null 
              ? (isBn ? 'নতুন ফসল ট্র্যাক করুন' : 'Add New Crop')
              : (isBn ? 'ফসল সম্পাদনা' : 'Edit Crop'),
          style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF8BC34A)))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _myFarms.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: Text(
                              isBn ? 'আপনাকে প্রথমে একটি খামার তৈরি করতে হবে!' : 'You need to create a Farm first!',
                              style: GoogleFonts.hindSiliguri(color: Colors.red, fontWeight: FontWeight.bold),
                            ),
                          )
                        : DropdownButtonFormField<String>(
                            value: _farmIdController.text.isNotEmpty ? _farmIdController.text : null,
                            decoration: InputDecoration(
                              labelText: isBn ? 'খামার নির্বাচন করুন' : 'Select Farm',
                              labelStyle: GoogleFonts.hindSiliguri(),
                              prefixIcon: const Icon(Icons.landscape, color: Color(0xFF8BC34A)),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            items: _myFarms.map((farm) {
                              return DropdownMenuItem(value: farm.id, child: Text(farm.name, style: GoogleFonts.hindSiliguri()));
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) setState(() => _farmIdController.text = val);
                            },
                          ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _nameController,
                      label: isBn ? 'ফসলের নাম (যেমন: টমেটো, ব্রি ধান-২৮)' : 'Crop Name (e.g., Tomato, BRRI Dhan-28)',
                      icon: Icons.grass,
                      validator: (value) => value!.isEmpty ? (isBn ? 'ফসলের নাম দিন' : 'Please enter a crop name') : null,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: _areaController,
                            label: isBn ? 'জমির পরিমাণ (হেক্টর/একর)' : 'Area (ha / acre)',
                            icon: Icons.aspect_ratio,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildTextField(
                            controller: _yieldController,
                            label: isBn ? 'প্রত্যাশিত ফলন (কেজি/মণ)' : 'Est. Yield (kg / maund)',
                            icon: Icons.analytics,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _statusController.text,
                      decoration: InputDecoration(
                        labelText: isBn ? 'ফসলের বর্তমান পর্যায়' : 'Growth Stage',
                        labelStyle: GoogleFonts.hindSiliguri(),
                        prefixIcon: const Icon(Icons.timeline, color: Color(0xFF8BC34A)),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      items: [
                        DropdownMenuItem(value: 'planning', child: Text(isBn ? 'পরিকল্পনা (Planning)' : 'Planning', style: GoogleFonts.hindSiliguri())),
                        DropdownMenuItem(value: 'planted', child: Text(isBn ? 'রোপিত (Planted)' : 'Planted', style: GoogleFonts.hindSiliguri())),
                        DropdownMenuItem(value: 'growing', child: Text(isBn ? 'বর্ধমান (Growing)' : 'Growing', style: GoogleFonts.hindSiliguri())),
                        DropdownMenuItem(value: 'ready_to_harvest', child: Text(isBn ? 'ফসল কাটার সময় (Ready)' : 'Ready to Harvest', style: GoogleFonts.hindSiliguri())),
                        DropdownMenuItem(value: 'harvested', child: Text(isBn ? 'সংগৃহীত (Harvested)' : 'Harvested', style: GoogleFonts.hindSiliguri())),
                      ],
                      onChanged: (val) {
                        if (val != null) setState(() => _statusController.text = val);
                      },
                    ),
                    const SizedBox(height: 40),
                    ElevatedButton(
                      onPressed: _myFarms.isEmpty ? null : () => _saveCrop(isBn),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8BC34A),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 4,
                      ),
                      child: Text(
                        widget.crop == null 
                            ? (isBn ? 'ফসল যোগ করুন' : 'Add Crop')
                            : (isBn ? 'সংরক্ষণ করুন' : 'Save Changes'),
                        style: GoogleFonts.hindSiliguri(
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
      style: GoogleFonts.hindSiliguri(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF2D3748),
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.hindSiliguri(color: Colors.grey.shade600),
        prefixIcon: Icon(icon, color: const Color(0xFF8BC34A)),
        filled: true,
        fillColor: Colors.white,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF8BC34A), width: 2),
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
}
