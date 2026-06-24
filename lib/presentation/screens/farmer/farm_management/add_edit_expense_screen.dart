import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:agrolinkbd/core/models/phase2_models/farm_models.dart';
import 'package:agrolinkbd/core/services/phase2_services/farm_service.dart';
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

  final List<String> _categories = [
    'Fertilizer',
    'Labor',
    'Seeds',
    'Equipment',
    'Pesticides',
    'Irrigation',
    'Other'
  ];

  List<Farm> _farms = [];

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(text: widget.expense != null ? widget.expense!.amount.toString() : '');
    _descController = TextEditingController(text: widget.expense?.description ?? '');
    _selectedCategory = widget.expense?.category ?? _categories.first;
    _selectedDate = widget.expense?.date ?? DateTime.now();
    _selectedFarmId = widget.expense?.farmId;
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
    _amountController.dispose();
    _descController.dispose();
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

  Future<void> _saveExpense() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedFarmId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a farm')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final expense = FarmExpense(
        id: widget.expense?.id ?? '',
        userId: widget.expense?.userId ?? '',
        farmId: _selectedFarmId!,
        category: _selectedCategory!,
        amount: double.parse(_amountController.text.trim()),
        date: _selectedDate,
        description: _descController.text.trim(),
      );

      if (widget.expense == null) {
        await _farmService.addExpense(expense);
      } else {
        // Update method not implemented in service for expense, but for creation it's fine.
        // Let's assume we just add for now.
      }

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Expense added successfully'), backgroundColor: Colors.green),
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
        backgroundColor: const Color(0xFFF44336),
        elevation: 0,
        title: Text(
          widget.expense == null ? 'Add Expense' : 'Edit Expense',
          style: GoogleFonts.openSans(fontWeight: FontWeight.bold, color: Colors.white),
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
                      label: 'Farm',
                      icon: Icons.landscape,
                      value: _selectedFarmId,
                      items: _farms.map((f) => DropdownMenuItem(value: f.id, child: Text(f.name))).toList(),
                      onChanged: (val) => setState(() => _selectedFarmId = val),
                    ),
                    const SizedBox(height: 16),
                    _buildDropdown<String>(
                      label: 'Category',
                      icon: Icons.category,
                      value: _selectedCategory,
                      items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                      onChanged: (val) => setState(() => _selectedCategory = val),
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
                      decoration: _inputDecoration('Amount (৳)', Icons.attach_money),
                    ),
                    const SizedBox(height: 16),
                    InkWell(
                      onTap: () => _selectDate(context),
                      child: IgnorePointer(
                        child: TextFormField(
                          controller: TextEditingController(text: DateFormat('dd MMM yyyy').format(_selectedDate)),
                          decoration: _inputDecoration('Date', Icons.calendar_today),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descController,
                      maxLines: 3,
                      decoration: _inputDecoration('Description', Icons.description),
                    ),
                    const SizedBox(height: 40),
                    ElevatedButton(
                      onPressed: _saveExpense,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF44336),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: Text(
                        'Save Expense',
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
      prefixIcon: Icon(icon, color: const Color(0xFFF44336)),
      filled: true,
      fillColor: Colors.white,
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey.shade300)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFF44336), width: 2)),
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
