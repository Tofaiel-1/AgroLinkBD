import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:agrolinkbd/core/models/phase2_models/farm_models.dart';
import 'package:agrolinkbd/core/services/phase2_services/farm_service.dart';
import 'package:agrolinkbd/core/providers/language_provider.dart';
import 'package:intl/intl.dart';

class AddEditExpenseScreen extends StatefulWidget {
  final FarmExpense? expense;

  const AddEditExpenseScreen({Key? key, this.expense}) : super(key: key);

  @override
  State<AddEditExpenseScreen> createState() => _AddEditExpenseScreenState();
}

class _AddEditExpenseScreenState extends State<AddEditExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _farmService = FarmService();
  bool _isLoading = false;

  late TextEditingController _amountController;
  late TextEditingController _descController;
  String? _selectedCategory;
  String? _selectedFarmId;
  DateTime _selectedDate = DateTime.now();

  final List<Map<String, String>> _categories = [
    {'id': 'Fertilizer', 'bn': 'সার (Fertilizer)', 'en': 'Fertilizer'},
    {'id': 'Labor', 'bn': 'শ্রমিক মজুরি (Labor)', 'en': 'Labor'},
    {'id': 'Seeds', 'bn': 'বীজ/চারা (Seeds)', 'en': 'Seeds'},
    {'id': 'Equipment', 'bn': 'যন্ত্রপাতি ও জ্বালানি (Equipment)', 'en': 'Equipment'},
    {'id': 'Pesticides', 'bn': 'কীটনাশক ও বালাইনাশক (Pesticides)', 'en': 'Pesticides'},
    {'id': 'Irrigation', 'bn': 'সেচ ও পানি (Irrigation)', 'en': 'Irrigation'},
    {'id': 'Transport', 'bn': 'পরিবহন (Transport)', 'en': 'Transport'},
    {'id': 'Other', 'bn': 'অন্যান্য খরচ (Other)', 'en': 'Other'},
  ];

  List<Farm> _farms = [];

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(
        text: widget.expense != null ? widget.expense!.amount.toStringAsFixed(0) : '');
    _descController = TextEditingController(text: widget.expense?.description ?? '');
    _selectedCategory = widget.expense?.category ?? 'Fertilizer';
    _selectedDate = widget.expense?.date ?? DateTime.now();
    _selectedFarmId = widget.expense?.farmId ?? 'main_farm';
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
    _amountController.dispose();
    _descController.dispose();
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

  Future<void> _saveExpense() async {
    if (!_formKey.currentState!.validate()) return;
    
    final isBn = LanguageProvider.isBn(context);
    final farmIdToUse = _selectedFarmId ?? 'main_farm';

    setState(() => _isLoading = true);

    try {
      final double amount = double.tryParse(_amountController.text.trim()) ?? 0.0;
      final expense = FarmExpense(
        id: widget.expense?.id ?? '',
        userId: _farmService.currentUserId ?? '',
        farmId: farmIdToUse,
        category: _selectedCategory ?? 'Fertilizer',
        amount: amount,
        date: _selectedDate,
        description: _descController.text.trim(),
      );

      if (widget.expense == null) {
        await _farmService.addExpense(expense);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isBn ? 'খরচের হিসাব সফলভাবে যুক্ত হয়েছে' : 'Expense added successfully'),
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
        backgroundColor: const Color(0xFFF44336),
        elevation: 0,
        title: Text(
          widget.expense == null
              ? (isBn ? 'খরচ যোগ করুন' : 'Add Expense')
              : (isBn ? 'খরচ সম্পাদনা' : 'Edit Expense'),
          style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFF44336)))
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
                    _buildDropdown<String>(
                      label: isBn ? 'খরচের খাত (ক্যাটাগরি)' : 'Expense Category',
                      icon: Icons.category,
                      value: _selectedCategory,
                      items: _categories
                          .map((c) => DropdownMenuItem<String>(
                                value: c['id']!,
                                child: Text(isBn ? c['bn']! : c['en']!),
                              ))
                          .toList(),
                      onChanged: (val) => setState(() => _selectedCategory = val),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _amountController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      style: GoogleFonts.hindSiliguri(fontSize: 16, fontWeight: FontWeight.bold),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return isBn ? 'টাকার পরিমাণ লিখুন' : 'Enter amount';
                        }
                        if (double.tryParse(value.trim()) == null || double.parse(value.trim()) <= 0) {
                          return isBn ? 'সঠিক টাকার পরিমাণ দিন' : 'Enter valid amount';
                        }
                        return null;
                      },
                      decoration: _inputDecoration(
                        isBn ? 'টাকার পরিমাণ (৳)' : 'Amount (৳)',
                        Icons.attach_money,
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
                            isBn ? 'তারিখ' : 'Date',
                            Icons.calendar_today,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descController,
                      maxLines: 3,
                      style: GoogleFonts.hindSiliguri(fontSize: 15),
                      decoration: _inputDecoration(
                        isBn ? 'বিবরণ / নোট (ঐচ্ছিক)' : 'Description / Notes (Optional)',
                        Icons.description,
                      ),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: _saveExpense,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF44336),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 3,
                      ),
                      child: Text(
                        isBn ? 'খরচের হিসাব সংরক্ষণ করুন' : 'Save Expense',
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
      prefixIcon: Icon(icon, color: const Color(0xFFF44336)),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFF44336), width: 2),
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
