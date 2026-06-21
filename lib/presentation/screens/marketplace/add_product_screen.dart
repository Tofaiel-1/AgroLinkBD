import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  String _selectedCategory = 'সবজি';
  final List<String> _categories = ['সবজি', 'ফলমূল', 'চাল', 'মসলা', 'মাছ', 'মাংস', 'দুধ-ডিম', 'অন্যান্য'];
  
  bool _isLoading = false;

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      // Simulate network request
      await Future.delayed(const Duration(seconds: 2));
      setState(() => _isLoading = false);
      
      Get.back();
      Get.snackbar(
        'সফল!',
        'আপনার পণ্যটি সফলভাবে মার্কেটপ্লেসে যোগ করা হয়েছে',
        backgroundColor: Colors.green.shade600,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        icon: const Icon(Icons.check_circle, color: Colors.white),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B5E20),
        elevation: 0,
        title: Text(
          'পণ্য যোগ করুন',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: Stack(
        children: [
          Container(
            height: 100,
            decoration: const BoxDecoration(
              color: Color(0xFF1B5E20),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
            ),
          ),
          SafeArea(
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(20),
                physics: const BouncingScrollPhysics(),
                children: [
                  // Image Upload Section
                  Center(
                    child: Stack(
                      children: [
                        Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 4),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 15, offset: const Offset(0, 5))
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.add_a_photo_rounded, size: 40, color: Color(0xFF1B5E20)),
                              const SizedBox(height: 8),
                              Text('ছবি যোগ করুন', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade600)),
                            ],
                          ),
                        ),
                        Positioned(
                          bottom: 5,
                          right: 5,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: Color(0xFF4CAF50),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.edit, color: Colors.white, size: 18),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Form Fields
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5))
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('পণ্যের নাম', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: const Color(0xFF1E293B))),
                        const SizedBox(height: 8),
                        TextFormField(
                          decoration: InputDecoration(
                            hintText: 'যেমন: তাজা টমেটো',
                            hintStyle: GoogleFonts.poppins(color: Colors.grey.shade400, fontSize: 14),
                            filled: true,
                            fillColor: const Color(0xFFF8F9FA),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          ),
                          validator: (value) => value == null || value.isEmpty ? 'পণ্যের নাম লিখুন' : null,
                        ),
                        const SizedBox(height: 20),

                        Text('ক্যাটাগরি', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: const Color(0xFF1E293B))),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          value: _selectedCategory,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: const Color(0xFFF8F9FA),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          ),
                          items: _categories.map((cat) => DropdownMenuItem(value: cat, child: Text(cat, style: GoogleFonts.poppins()))).toList(),
                          onChanged: (value) => setState(() => _selectedCategory = value!),
                        ),
                        const SizedBox(height: 20),

                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('দাম (৳)', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: const Color(0xFF1E293B))),
                                  const SizedBox(height: 8),
                                  TextFormField(
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      hintText: 'যেমন: ৪০',
                                      hintStyle: GoogleFonts.poppins(color: Colors.grey.shade400, fontSize: 14),
                                      filled: true,
                                      fillColor: const Color(0xFFF8F9FA),
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                    ),
                                    validator: (value) => value == null || value.isEmpty ? 'দাম লিখুন' : null,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('একক', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: const Color(0xFF1E293B))),
                                  const SizedBox(height: 8),
                                  TextFormField(
                                    decoration: InputDecoration(
                                      hintText: 'যেমন: কেজি',
                                      hintStyle: GoogleFonts.poppins(color: Colors.grey.shade400, fontSize: 14),
                                      filled: true,
                                      fillColor: const Color(0xFFF8F9FA),
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                    ),
                                    validator: (value) => value == null || value.isEmpty ? 'একক লিখুন' : null,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        Text('বিস্তারিত বিবরণ', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: const Color(0xFF1E293B))),
                        const SizedBox(height: 8),
                        TextFormField(
                          maxLines: 4,
                          decoration: InputDecoration(
                            hintText: 'পণ্যের গুণগত মান বা অন্যান্য তথ্য লিখুন...',
                            hintStyle: GoogleFonts.poppins(color: Colors.grey.shade400, fontSize: 14),
                            filled: true,
                            fillColor: const Color(0xFFF8F9FA),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          ),
                        ),
                        const SizedBox(height: 30),

                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _submitForm,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1B5E20),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              elevation: 5,
                              shadowColor: const Color(0xFF1B5E20).withOpacity(0.5),
                            ),
                            child: _isLoading 
                                ? const CircularProgressIndicator(color: Colors.white)
                                : Text(
                                    'পণ্য প্রকাশ করুন',
                                    style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
