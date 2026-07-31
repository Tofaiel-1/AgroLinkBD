import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:agrolinkbd/core/providers/user_provider.dart';
import 'package:agrolinkbd/core/models/marketplace_item_model.dart';
import 'package:agrolinkbd/core/controllers/marketplace_controller.dart';

class SellFishScreen extends StatefulWidget {
  const SellFishScreen({super.key});

  @override
  State<SellFishScreen> createState() => _SellFishScreenState();
}

class _SellFishScreenState extends State<SellFishScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fishTypeController = TextEditingController();
  final _quantityController = TextEditingController();
  final _avgWeightController = TextEditingController();
  final _priceController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    const Color greenColor = Color(0xFF43A047);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'মাছ বিক্রি করুন',
          style: GoogleFonts.hindSiliguri(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: greenColor,
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
              Text(
                'বিক্রির জন্য মাছের তথ্য দিন',
                style: GoogleFonts.hindSiliguri(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              const SizedBox(height: 20),
              _buildInputField('মাছের ধরন (যেমন: রুই, কাতলা)', Icons.set_meal, _fishTypeController),
              const SizedBox(height: 16),
              _buildInputField('মাছের পরিমাণ (কেজি)', Icons.scale, _quantityController, isNumber: true),
              const SizedBox(height: 16),
              _buildInputField('গড় ওজন (প্রতিটি মাছের গ্রাম)', Icons.fitness_center, _avgWeightController, isNumber: true),
              const SizedBox(height: 16),
              _buildInputField('প্রত্যাশিত দাম (প্রতি কেজি)', Icons.attach_money, _priceController, isNumber: true),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitFishListing,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: greenColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        'সাবমিট করুন',
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

  Widget _buildInputField(String label, IconData icon, TextEditingController controller, {bool isNumber = false}) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.hindSiliguri(color: Colors.grey.shade600),
        prefixIcon: Icon(icon, color: Colors.green.shade600),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.green.shade400, width: 2),
        ),
        filled: true,
        fillColor: Theme.of(context).cardColor,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'এই তথ্যটি প্রয়োজন';
        }
        return null;
      },
    );
  }

  Future<void> _submitFishListing() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final user = userProvider.currentUser;
      
      final newItem = MarketplaceItemModel(
        id: 'PROD_${DateTime.now().millisecondsSinceEpoch}',
        farmerId: user?.id ?? 'mock_farmer_id',
        farmerName: user?.name ?? 'আমাদের কৃষক',
        fishType: _fishTypeController.text,
        quantityKg: double.parse(_quantityController.text),
        avgWeightGram: double.parse(_avgWeightController.text),
        pricePerKg: double.parse(_priceController.text),
        createdAt: DateTime.now(),
      );

      final MarketplaceController marketplaceController = Get.find<MarketplaceController>();
      marketplaceController.addItem(newItem);
          
      Get.back();
      Get.snackbar(
        'সফল', 
        'মাছ বিক্রির জন্য মার্কেটপ্লেসে দেওয়া হয়েছে!',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar('ত্রুটি', 'মাছ বিক্রি লিস্ট করতে সমস্যা হয়েছে: $e', backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
