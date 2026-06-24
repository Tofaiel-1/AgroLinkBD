import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:agrolinkbd/core/models/phase2_models/farm_models.dart';
import 'package:agrolinkbd/core/services/phase2_services/farm_service.dart';

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

  Future<void> _saveCrop() async {
    if (!_formKey.currentState!.validate()) return;
    if (_farmIdController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a farm first')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final crop = CropPlanting(
        id: widget.crop?.id ?? '', // Service assigns ID on create
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
      } else {
        // Implement updateCropPlanting later if needed
      }

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.crop == null ? 'Crop added successfully' : 'Crop updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
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
        backgroundColor: const Color(0xFF8BC34A),
        elevation: 0,
        title: Text(
          widget.crop == null ? 'Add New Crop' : 'Edit Crop',
          style: GoogleFonts.openSans(fontWeight: FontWeight.bold, color: Colors.white),
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
                              'You need to create a Farm first!',
                              style: GoogleFonts.openSans(color: Colors.red, fontWeight: FontWeight.bold),
                            ),
                          )
                        : DropdownButtonFormField<String>(
                            value: _farmIdController.text.isNotEmpty ? _farmIdController.text : null,
                            decoration: InputDecoration(
                              labelText: 'Select Farm',
                              prefixIcon: const Icon(Icons.landscape, color: Color(0xFF8BC34A)),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            items: _myFarms.map((farm) {
                              return DropdownMenuItem(value: farm.id, child: Text(farm.name));
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) setState(() => _farmIdController.text = val);
                            },
                          ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _nameController,
                      label: 'Crop Name (e.g., Tomato)',
                      icon: Icons.grass,
                      validator: (value) => value!.isEmpty ? 'Please enter a crop name' : null,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: _areaController,
                            label: 'Area (ha)',
                            icon: Icons.aspect_ratio,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildTextField(
                            controller: _yieldController,
                            label: 'Est. Yield (kg)',
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
                        labelText: 'Stage',
                        prefixIcon: const Icon(Icons.timeline, color: Color(0xFF8BC34A)),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'planning', child: Text('Planning')),
                        DropdownMenuItem(value: 'planted', child: Text('Planted')),
                        DropdownMenuItem(value: 'growing', child: Text('Growing')),
                        DropdownMenuItem(value: 'ready_to_harvest', child: Text('Ready to Harvest')),
                        DropdownMenuItem(value: 'harvested', child: Text('Harvested')),
                      ],
                      onChanged: (val) {
                        if (val != null) setState(() => _statusController.text = val);
                      },
                    ),
                    const SizedBox(height: 40),
                    ElevatedButton(
                      onPressed: _myFarms.isEmpty ? null : _saveCrop,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8BC34A),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 4,
                      ),
                      child: Text(
                        widget.crop == null ? 'Add Crop' : 'Save Changes',
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
