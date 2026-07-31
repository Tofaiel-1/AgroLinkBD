import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:agrolinkbd/core/controllers/pond_controller.dart';

class AddPondScreen extends StatefulWidget {
  const AddPondScreen({super.key});

  @override
  State<AddPondScreen> createState() => _AddPondScreenState();
}

class _AddPondScreenState extends State<AddPondScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final _nameController = TextEditingController();
  final _areaController = TextEditingController();
  final _speciesController = TextEditingController();
  final _fishCountController = TextEditingController();
  final _costController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _areaController.dispose();
    _speciesController.dispose();
    _fishCountController.dispose();
    _costController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final pondController = Get.find<PondController>();
      
      pondController.addPond(
        _nameController.text.trim(),
        _areaController.text.trim(),
        _speciesController.text.trim(),
        int.tryParse(_fishCountController.text.trim()) ?? 0,
        double.tryParse(_costController.text.trim()) ?? 0.0,
      );

      Get.back();
      Get.snackbar(
        'সফল', 
        'নতুন পুকুর সফলভাবে যুক্ত হয়েছে!',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color oceanBlue = Color(0xFF0288D1);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'নতুন পুকুর যোগ করুন',
          style: GoogleFonts.hindSiliguri(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: oceanBlue,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('পুকুরের প্রাথমিক তথ্য'),
              const SizedBox(height: 12),
              _buildInputField(
                controller: _nameController,
                label: 'পুকুরের নাম (যেমন: পুকুর ৩)',
                icon: Icons.pool,
              ),
              const SizedBox(height: 16),
              _buildInputField(
                controller: _areaController,
                label: 'আয়তন (যেমন: ১.৫ একর)',
                icon: Icons.straighten,
              ),
              
              const SizedBox(height: 24),
              _buildSectionTitle('মাছের পোনা ও মজুত'),
              const SizedBox(height: 12),
              _buildInputField(
                controller: _speciesController,
                label: 'মাছের প্রজাতি (যেমন: পাঙ্গাস)',
                icon: Icons.set_meal,
              ),
              const SizedBox(height: 16),
              _buildInputField(
                controller: _fishCountController,
                label: 'মোট পোনার সংখ্যা',
                icon: Icons.numbers,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              _buildInputField(
                controller: _costController,
                label: 'পোনা ক্রয়ের মোট খরচ (৳)',
                icon: Icons.monetization_on,
                keyboardType: TextInputType.number,
              ),
              
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: oceanBlue,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'সংরক্ষণ করুন',
                    style: GoogleFonts.hindSiliguri(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.hindSiliguri(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).textTheme.titleLarge?.color ?? Colors.black87,
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: GoogleFonts.hindSiliguri(
        color: Theme.of(context).textTheme.bodyLarge?.color,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.hindSiliguri(color: isDark ? Colors.grey.shade400 : Colors.grey.shade600),
        prefixIcon: Icon(icon, color: isDark ? Colors.blue.shade300 : Colors.blue.shade600),
        filled: true,
        fillColor: Theme.of(context).cardColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: isDark ? Colors.grey.shade700 : Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: isDark ? Colors.grey.shade700 : Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.blue.shade600, width: 2),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'এই ঘরটি পূরণ করা আবশ্যক';
        }
        return null;
      },
    );
  }
}
