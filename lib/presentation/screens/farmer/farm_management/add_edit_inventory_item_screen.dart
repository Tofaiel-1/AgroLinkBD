import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:agrolinkbd/core/models/phase2_models/farm_models.dart';
import 'package:agrolinkbd/core/services/phase2_services/farm_service.dart';

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

  final List<String> _categories = [
    'Fertilizer',
    'Seeds',
    'Chemicals',
    'Fuel',
    'Equipment',
    'Other'
  ];

  final List<String> _units = ['kg', 'liter', 'piece', 'ton', 'bag'];

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

  Future<void> _saveItem() async {
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
          const SnackBar(content: Text('Item saved successfully'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF795548),
        elevation: 0,
        title: Text(
          widget.item == null ? 'Add Inventory Item' : 'Edit Inventory Item',
          style: GoogleFonts.openSans(fontWeight: FontWeight.bold, color: Colors.white),
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
                      validator: (value) => value == null || value.isEmpty ? 'Enter item name' : null,
                      decoration: _inputDecoration('Item Name (e.g. Urea)', Icons.inventory_2),
                    ),
                    const SizedBox(height: 16),
                    _buildDropdown<String>(
                      label: 'Category',
                      icon: Icons.category,
                      value: _selectedCategory,
                      items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
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
                              if (value == null || value.isEmpty) return 'Required';
                              if (double.tryParse(value) == null) return 'Invalid';
                              return null;
                            },
                            decoration: _inputDecoration('Quantity', Icons.scale),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 1,
                          child: _buildDropdown<String>(
                            label: 'Unit',
                            icon: Icons.square_foot,
                            value: _selectedUnit,
                            items: _units.map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
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
                        if (value == null || value.isEmpty) return 'Enter value';
                        if (double.tryParse(value) == null) return 'Invalid';
                        return null;
                      },
                      decoration: _inputDecoration('Estimated Value Per Unit (৳)', Icons.attach_money),
                    ),
                    const SizedBox(height: 40),
                    ElevatedButton(
                      onPressed: _saveItem,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF795548),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: Text(
                        'Save Item',
                        style: GoogleFonts.openSans(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
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
      labelStyle: GoogleFonts.openSans(color: Colors.grey.shade600),
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
