import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:agrolinkbd/core/models/phase2_models/farm_models.dart';
import 'package:agrolinkbd/core/services/phase2_services/farm_service.dart';
import 'package:intl/intl.dart';

class AddEditRevenueScreen extends StatefulWidget {
  final FarmRevenue? revenue;

  const AddEditRevenueScreen({Key? key, this.revenue}) : super(key: key);

  @override
  State<AddEditRevenueScreen> createState() => _AddEditRevenueScreenState();
}

class _AddEditRevenueScreenState extends State<AddEditRevenueScreen> {
  final _formKey = GlobalKey<FormState>();
  final _farmService = FarmService();
  bool _isLoading = false;

  late TextEditingController _cropNameController;
  late TextEditingController _amountController;
  late TextEditingController _quantityController;
  late TextEditingController _buyerNameController;
  String? _selectedFarmId;
  String _selectedUnit = 'kg';
  DateTime _selectedDate = DateTime.now();

  List<Farm> _farms = [];
  final List<String> _units = ['kg', 'ton', 'piece', 'liter'];

  @override
  void initState() {
    super.initState();
    _cropNameController = TextEditingController(text: widget.revenue?.cropName ?? '');
    _amountController = TextEditingController(text: widget.revenue != null ? widget.revenue!.amount.toString() : '');
    _quantityController = TextEditingController(text: widget.revenue != null ? widget.revenue!.quantity.toString() : '');
    _buyerNameController = TextEditingController(text: widget.revenue?.buyerName ?? '');
    _selectedDate = widget.revenue?.date ?? DateTime.now();
    _selectedUnit = widget.revenue?.unit ?? 'kg';
    _selectedFarmId = widget.revenue?.farmId;
    _loadFarms();
  }

  Future<void> _loadFarms() async {
    final farms = await _farmService.getFarms();
    setState(() {
      _farms = farms;
      if (_farms.isNotEmpty && _selectedFarmId == null) {
        _selectedFarmId = _farms.first.id;
      }
    });
  }

  @override
  void dispose() {
    _cropNameController.dispose();
    _amountController.dispose();
    _quantityController.dispose();
    _buyerNameController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _saveRevenue() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedFarmId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a farm')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final revenue = FarmRevenue(
        id: widget.revenue?.id ?? '',
        userId: widget.revenue?.userId ?? '',
        farmId: _selectedFarmId!,
        cropName: _cropNameController.text.trim(),
        amount: double.parse(_amountController.text.trim()),
        quantity: double.parse(_quantityController.text.trim()),
        unit: _selectedUnit,
        date: _selectedDate,
        buyerName: _buyerNameController.text.trim(),
      );

      if (widget.revenue == null) {
        await _farmService.addRevenue(revenue);
      }

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Revenue added successfully'), backgroundColor: Colors.green),
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
        backgroundColor: const Color(0xFF009688),
        elevation: 0,
        title: Text(
          widget.revenue == null ? 'Add Revenue' : 'Edit Revenue',
          style: GoogleFonts.openSans(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF009688)))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildDropdown<String>(
                      label: 'Farm',
                      icon: Icons.landscape,
                      value: _selectedFarmId,
                      items: _farms.map((f) => DropdownMenuItem(value: f.id, child: Text(f.name))).toList(),
                      onChanged: (val) => setState(() => _selectedFarmId = val),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _cropNameController,
                      validator: (value) => value == null || value.isEmpty ? 'Enter crop name' : null,
                      decoration: _inputDecoration('Crop Sold (e.g. Boro Rice)', Icons.grass),
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
                      controller: _amountController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Enter amount';
                        if (double.tryParse(value) == null) return 'Invalid amount';
                        return null;
                      },
                      decoration: _inputDecoration('Total Revenue (৳)', Icons.attach_money),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _buyerNameController,
                      decoration: _inputDecoration('Buyer Name (Optional)', Icons.person),
                    ),
                    const SizedBox(height: 16),
                    InkWell(
                      onTap: () => _selectDate(context),
                      child: IgnorePointer(
                        child: TextFormField(
                          controller: TextEditingController(text: DateFormat('dd MMM yyyy').format(_selectedDate)),
                          decoration: _inputDecoration('Date of Sale', Icons.calendar_today),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    ElevatedButton(
                      onPressed: _saveRevenue,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF009688),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: Text(
                        'Save Revenue',
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
      prefixIcon: Icon(icon, color: const Color(0xFF009688)),
      filled: true,
      fillColor: Colors.white,
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey.shade300)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFF009688), width: 2)),
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
