import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:agrolinkbd/core/models/phase2_models/farm_models.dart';
import 'package:agrolinkbd/core/services/phase2_services/farm_service.dart';
import 'package:agrolinkbd/core/providers/language_provider.dart';
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
  final List<Map<String, String>> _units = [
    {'id': 'kg', 'bn': 'কেজি', 'en': 'kg'},
    {'id': 'maund', 'bn': 'মণ', 'en': 'maund'},
    {'id': 'ton', 'bn': 'টন', 'en': 'ton'},
    {'id': 'piece', 'bn': 'টি / পিস', 'en': 'piece'},
    {'id': 'liter', 'bn': 'লিটার', 'en': 'liter'},
  ];

  @override
  void initState() {
    super.initState();
    _cropNameController = TextEditingController(text: widget.revenue?.cropName ?? '');
    _amountController = TextEditingController(
        text: widget.revenue != null ? widget.revenue!.amount.toStringAsFixed(0) : '');
    _quantityController = TextEditingController(
        text: widget.revenue != null ? widget.revenue!.quantity.toStringAsFixed(0) : '');
    _buyerNameController = TextEditingController(text: widget.revenue?.buyerName ?? '');
    _selectedDate = widget.revenue?.date ?? DateTime.now();
    _selectedUnit = widget.revenue?.unit ?? 'kg';
    _selectedFarmId = widget.revenue?.farmId ?? 'main_farm';
    _loadFarms();
  }

  Future<void> _loadFarms() async {
    final farms = await _farmService.getFarms();
    if (mounted) {
      setState(() {
        _farms = farms;
        if (_farms.isNotEmpty && (_selectedFarmId == null || _selectedFarmId == 'main_farm')) {
          _selectedFarmId = _farms.first.id;
        } else if (_farms.isEmpty) {
          _selectedFarmId = 'main_farm';
        }
      });
    }
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
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _saveRevenue() async {
    if (!_formKey.currentState!.validate()) return;
    
    final isBn = LanguageProvider.isBn(context);
    final farmIdToUse = _selectedFarmId ?? 'main_farm';

    setState(() => _isLoading = true);

    try {
      final double amount = double.tryParse(_amountController.text.trim()) ?? 0.0;
      final double qty = double.tryParse(_quantityController.text.trim()) ?? 0.0;

      final revenue = FarmRevenue(
        id: widget.revenue?.id ?? '',
        userId: _farmService.currentUserId ?? '',
        farmId: farmIdToUse,
        cropName: _cropNameController.text.trim(),
        amount: amount,
        quantity: qty,
        unit: _selectedUnit,
        date: _selectedDate,
        buyerName: _buyerNameController.text.trim(),
      );

      if (widget.revenue == null) {
        await _farmService.addRevenue(revenue);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isBn ? 'বিক্রয় ও আয়ের হিসাব সংরক্ষিত হয়েছে' : 'Revenue added successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
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
    final isBn = LanguageProvider.isBn(context);

    // Build farm dropdown items
    List<DropdownMenuItem<String>> farmItems = [];
    if (_farms.isNotEmpty) {
      farmItems = _farms
          .map((f) => DropdownMenuItem<String>(value: f.id, child: Text(f.name)))
          .toList();
    } else {
      farmItems = [
        DropdownMenuItem<String>(
          value: 'main_farm',
          child: Text(isBn ? 'প্রধান খামার (Main Farm)' : 'Main Farm (Default)'),
        ),
      ];
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF009688),
        elevation: 0,
        title: Text(
          widget.revenue == null
              ? (isBn ? 'বিক্রয় ও আয় যোগ করুন' : 'Add Revenue')
              : (isBn ? 'আয় সম্পাদনা' : 'Edit Revenue'),
          style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, color: Colors.white),
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
                      label: isBn ? 'খামার নির্বাচন' : 'Select Farm',
                      icon: Icons.landscape,
                      value: _selectedFarmId ?? 'main_farm',
                      items: farmItems,
                      onChanged: (val) => setState(() => _selectedFarmId = val),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _cropNameController,
                      style: GoogleFonts.hindSiliguri(fontSize: 15),
                      validator: (value) =>
                          value == null || value.trim().isEmpty ? (isBn ? 'ফসলের নাম লিখুন' : 'Enter crop name') : null,
                      decoration: _inputDecoration(
                        isBn ? 'বিক্রিত ফসল/পণ্য (যেমন: ব্রি-২৮ ধান)' : 'Crop Sold (e.g. Rice)',
                        Icons.grass,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            controller: _quantityController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            style: GoogleFonts.hindSiliguri(fontSize: 15, fontWeight: FontWeight.bold),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) return isBn ? 'পরিমাণ দিন' : 'Required';
                              if (double.tryParse(value.trim()) == null || double.parse(value.trim()) <= 0) return isBn ? 'সঠিক মান দিন' : 'Invalid';
                              return null;
                            },
                            decoration: _inputDecoration(isBn ? 'পরিমাণ' : 'Quantity', Icons.scale),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: _buildDropdown<String>(
                            label: isBn ? 'একক' : 'Unit',
                            icon: Icons.straighten,
                            value: _selectedUnit,
                            items: _units
                                .map((u) => DropdownMenuItem(
                                      value: u['id']!,
                                      child: Text(isBn ? u['bn']! : u['en']!),
                                    ))
                                .toList(),
                            onChanged: (val) => setState(() => _selectedUnit = val ?? 'kg'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _amountController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      style: GoogleFonts.hindSiliguri(fontSize: 16, fontWeight: FontWeight.bold),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) return isBn ? 'টাকার পরিমাণ লিখুন' : 'Enter amount';
                        if (double.tryParse(value.trim()) == null || double.parse(value.trim()) <= 0) return isBn ? 'সঠিক টাকার পরিমাণ দিন' : 'Invalid amount';
                        return null;
                      },
                      decoration: _inputDecoration(
                        isBn ? 'মোট বিক্রয়মূল্য / আয় (৳)' : 'Total Revenue (৳)',
                        Icons.attach_money,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _buyerNameController,
                      style: GoogleFonts.hindSiliguri(fontSize: 15),
                      decoration: _inputDecoration(
                        isBn ? 'ক্রেতার নাম (ঐচ্ছিক)' : 'Buyer Name (Optional)',
                        Icons.person,
                      ),
                    ),
                    const SizedBox(height: 16),
                    InkWell(
                      onTap: () => _selectDate(context),
                      child: IgnorePointer(
                        child: TextFormField(
                          controller: TextEditingController(
                              text: DateFormat('dd MMM yyyy').format(_selectedDate)),
                          style: GoogleFonts.hindSiliguri(fontSize: 15),
                          decoration: _inputDecoration(
                            isBn ? 'বিক্রির তারিখ' : 'Date of Sale',
                            Icons.calendar_today,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: _saveRevenue,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF009688),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 3,
                      ),
                      child: Text(
                        isBn ? 'আয়ের হিসাব সংরক্ষণ করুন' : 'Save Revenue',
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

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.hindSiliguri(color: Colors.grey.shade700, fontSize: 14),
      prefixIcon: Icon(icon, color: const Color(0xFF009688)),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFF009688), width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
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
      validator: (val) => val == null ? 'Required' : null,
    );
  }
}
