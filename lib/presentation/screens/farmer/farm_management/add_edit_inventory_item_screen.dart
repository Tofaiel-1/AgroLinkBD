import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:agrolinkbd/core/models/phase2_models/farm_models.dart';
import 'package:agrolinkbd/core/services/phase2_services/farm_service.dart';
import 'package:agrolinkbd/core/providers/language_provider.dart';

class AddEditInventoryItemScreen extends StatefulWidget {
  final FarmInventoryItem? item;

  const AddEditInventoryItemScreen({Key? key, this.item}) : super(key: key);

  @override
  State<AddEditInventoryItemScreen> createState() => _AddEditInventoryItemScreenState();
}

class _AddEditInventoryItemScreenState extends State<AddEditInventoryItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _farmService = FarmService();
  bool _isLoading = false;

  late TextEditingController _nameController;
  late TextEditingController _quantityController;
  late TextEditingController _valueController;
  String _selectedCategory = 'Fertilizer';
  String _selectedUnit = 'kg';

  final List<Map<String, String>> _categories = [
    {'id': 'Fertilizer', 'bn': 'সার (Fertilizer)', 'en': 'Fertilizer'},
    {'id': 'Seeds', 'bn': 'বীজ ও চারা (Seeds)', 'en': 'Seeds'},
    {'id': 'Chemicals', 'bn': 'কীটনাশক ও বালাইনাশক (Chemicals)', 'en': 'Chemicals'},
    {'id': 'Fuel', 'bn': 'জ্বালানি (Fuel)', 'en': 'Fuel'},
    {'id': 'Equipment', 'bn': 'যন্ত্রপাতি (Equipment)', 'en': 'Equipment'},
    {'id': 'Other', 'bn': 'অন্যান্য (Other)', 'en': 'Other'},
  ];

  final List<Map<String, String>> _units = [
    {'id': 'kg', 'bn': 'কেজি', 'en': 'kg'},
    {'id': 'liter', 'bn': 'লিটার', 'en': 'liter'},
    {'id': 'piece', 'bn': 'টি / পিস', 'en': 'piece'},
    {'id': 'ton', 'bn': 'টন', 'en': 'ton'},
    {'id': 'bag', 'bn': 'বস্তা', 'en': 'bag'},
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.item?.name ?? '');
    _quantityController = TextEditingController(text: widget.item != null ? widget.item!.quantity.toString() : '');
    _valueController = TextEditingController(text: widget.item != null ? widget.item!.valuePerUnit.toString() : '');
    _selectedCategory = widget.item?.category ?? 'Fertilizer';
    _selectedUnit = widget.item?.unit ?? 'kg';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _valueController.dispose();
    super.dispose();
  }

  Future<void> _saveItem(bool isBn) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final item = FarmInventoryItem(
        id: widget.item?.id ?? '',
        userId: widget.item?.userId ?? '',
        name: _nameController.text.trim(),
        category: _selectedCategory,
        quantity: double.parse(_quantityController.text.trim()),
        unit: _selectedUnit,
        valuePerUnit: double.parse(_valueController.text.trim()),
      );

      if (widget.item == null) {
        await _farmService.addInventoryItem(item);
      } else {
        await _farmService.updateInventoryItem(item);
      }

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isBn ? 'মালামাল সফলভাবে সংরক্ষণ করা হয়েছে' : 'Inventory item saved successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${isBn ? "ত্রুটি:" : "Error:"} $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isBn = LanguageProvider.isBn(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF795548),
        elevation: 0,
        title: Text(
          widget.item == null 
              ? (isBn ? 'নতুন মালামাল যোগ করুন' : 'Add Inventory Item')
              : (isBn ? 'মালামাল সম্পাদনা' : 'Edit Inventory Item'),
          style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF795548)))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _nameController,
                      validator: (value) => value == null || value.isEmpty ? (isBn ? 'নাম লিখুন' : 'Enter item name') : null,
                      decoration: _inputDecoration(isBn ? 'মালামালের নাম (যেমন: ইউরিয়া সার)' : 'Item Name (e.g. Urea Fertilizer)', Icons.inventory_2),
                    ),
                    const SizedBox(height: 16),
                    _buildDropdown<String>(
                      label: isBn ? 'ক্যাটাগরি' : 'Category',
                      icon: Icons.category,
                      value: _selectedCategory,
                      items: _categories.map((c) => DropdownMenuItem(value: c['id']!, child: Text(isBn ? c['bn']! : c['en']!))).toList(),
                      onChanged: (val) => setState(() => _selectedCategory = val!),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            controller: _quantityController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            validator: (value) {
                              if (value == null || value.isEmpty) return isBn ? 'পরিমাণ আবশ্যক' : 'Required';
                              if (double.tryParse(value) == null) return isBn ? 'সঠিক সংখ্যা দিন' : 'Invalid';
                              return null;
                            },
                            decoration: _inputDecoration(isBn ? 'পরিমাণ' : 'Quantity', Icons.scale),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 2,
                          child: _buildDropdown<String>(
                            label: isBn ? 'একক' : 'Unit',
                            icon: Icons.square_foot,
                            value: _selectedUnit,
                            items: _units.map((u) => DropdownMenuItem(value: u['id']!, child: Text(isBn ? u['bn']! : u['en']!))).toList(),
                            onChanged: (val) => setState(() => _selectedUnit = val!),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _valueController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (value) {
                        if (value == null || value.isEmpty) return isBn ? 'মূল্য লিখুন' : 'Enter value';
                        if (double.tryParse(value) == null) return isBn ? 'সঠিক মূল্য দিন' : 'Invalid';
                        return null;
                      },
                      decoration: _inputDecoration(isBn ? 'আনুমানিক একক প্রতি মূল্য (৳)' : 'Estimated Value Per Unit (৳)', Icons.attach_money),
                    ),
                    const SizedBox(height: 40),
                    ElevatedButton(
                      onPressed: () => _saveItem(isBn),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF795548),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: Text(
                        isBn ? 'সংরক্ষণ করুন' : 'Save Item',
                        style: GoogleFonts.hindSiliguri(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.hindSiliguri(color: Colors.grey.shade600),
      prefixIcon: Icon(icon, color: const Color(0xFF795548)),
      filled: true,
      fillColor: Colors.white,
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey.shade300)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFF795548), width: 2)),
      errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Colors.red)),
      focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Colors.red, width: 2)),
    );
  }

  Widget _buildDropdown<T>({
    required String label,
    required IconData icon,
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required void Function(T?) onChanged,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      isExpanded: true,
      items: items,
      onChanged: onChanged,
      decoration: _inputDecoration(label, icon),
      validator: (val) => val == null ? 'Please select' : null,
    );
  }
}
