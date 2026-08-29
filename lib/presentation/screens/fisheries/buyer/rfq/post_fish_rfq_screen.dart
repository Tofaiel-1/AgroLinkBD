import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:agrolinkbd/core/providers/user_provider.dart';
import 'package:agrolinkbd/core/models/fish_rfq_model.dart';
import 'package:agrolinkbd/core/services/fish_auction_service.dart';

class PostFishRfqScreen extends StatefulWidget {
  const PostFishRfqScreen({super.key});

  @override
  State<PostFishRfqScreen> createState() => _PostFishRfqScreenState();
}

class _PostFishRfqScreenState extends State<PostFishRfqScreen> {
  final _formKey = GlobalKey<FormState>();

  final _quantityController = TextEditingController();
  final _minWeightController = TextEditingController();
  final _budgetController = TextEditingController();
  final _addressController = TextEditingController(text: 'কাওরান বাজার মৎস্য মার্কেট, ঢাকা');
  final _notesController = TextEditingController();

  String _selectedSpecies = 'দেশি রুই (তাজা জ্যান্ত)';
  String _buyerType = 'পাইকারি আড়তদার';
  bool _requiresLiveFish = true;
  DateTime _deliveryDeadline = DateTime.now().add(const Duration(days: 3));
  bool _isLoading = false;

  final List<String> _speciesList = [
    'দেশি রুই (তাজা জ্যান্ত)',
    'কাতলা মাছ (বড় সাইজ)',
    'পাঙ্গাশ (মাটিমুক্ত)',
    'তেলাপিয়া মনোসেক্স',
    'রপ্তানি গ্রেড বাগদা চিংড়ি',
    'গলদা চিংড়ি (গ্রেড ১)',
    'পাবদা ও গুলশা',
    'দেশি জ্যান্ত শিং ও মাগুর',
    'পদ্মার রূপালি ইলিশ',
  ];

  final List<String> _buyerTypes = [
    'পাইকারি আড়তদার',
    'রেস্তোরাঁ চেইন ও ক্যাটারিং',
    'সুপারশপ ও রিটেইল চেইন',
    'এক্সপোর্টার ও প্রসেসিং প্ল্যান্ট',
    'ইভেন্ট / বিয়ের খাবার সরবরাহকারী',
  ];

  @override
  void dispose() {
    _quantityController.dispose();
    _minWeightController.dispose();
    _budgetController.dispose();
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _submitRfq() {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.currentUser;

    final auctionService = Get.isRegistered<FishAuctionService>()
        ? Get.find<FishAuctionService>()
        : Get.put(FishAuctionService());

    final qty = double.tryParse(_quantityController.text) ?? 500.0;
    final budget = double.tryParse(_budgetController.text) ?? 300.0;

    final newRfq = FishRfqModel(
      id: 'RFQ-FISH-${DateTime.now().millisecondsSinceEpoch}',
      buyerId: user?.id ?? 'buyer_demo',
      buyerName: user?.name ?? 'মেসার্স ভাই ভাই মৎস্য আড়ত',
      buyerPhone: user?.phone ?? '01711000000',
      buyerType: _buyerType,
      destinationAddress: _addressController.text,
      destinationDistrict: user?.district ?? 'ঢাকা',
      fishSpecies: _selectedSpecies,
      requiredQuantityKg: qty,
      minAvgWeightGram: double.tryParse(_minWeightController.text) ?? 1000.0,
      requiresLiveFish: _requiresLiveFish,
      targetBudgetPerKg: budget,
      deliveryDeadline: _deliveryDeadline,
      notes: _notesController.text,
      createdAt: DateTime.now(),
    );

    auctionService.addRfq(newRfq);

    setState(() => _isLoading = false);

    Get.back();
    Get.snackbar(
      'চাহিদাপত্র পোস্ট সম্পন্ন! 📢',
      'আপনার মাছের চাহিদাপত্রটি রেজিস্টার্ড খামারিদের কাছে পাঠানো হয়েছে। শীঘ্রই দর প্রস্তাব পাবেন।',
      backgroundColor: const Color(0xFF006064),
      colorText: Colors.white,
      duration: const Duration(seconds: 4),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color deepAqua = Color(0xFF006064);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(
          'পাইকারি চাহিদাপত্র দিন (Post RFQ)',
          style: GoogleFonts.hindSiliguri(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: deepAqua,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        physics: const BouncingScrollPhysics(),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF006064), Color(0xFF00838F)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.campaign, size: 40, color: Colors.amberAccent),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'সরাসরি খামারিদের কাছ থেকে পাইকারি রেট নিন',
                            style: GoogleFonts.hindSiliguri(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'আপনার মাছের চাহিদা পোস্ট করুন। সারাদেশের খামারিরা সরাসরি দর প্রস্তাব পাঠাবে।',
                            style: GoogleFonts.hindSiliguri(fontSize: 12, color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
              Text('চাহিদার বিবরণ', style: GoogleFonts.hindSiliguri(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),

              Text('মাছের প্রজাতি বা আইটেম *', style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isDark ? Colors.white24 : Colors.grey.shade300),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedSpecies,
                    isExpanded: true,
                    items: _speciesList.map((s) {
                      return DropdownMenuItem(value: s, child: Text(s, style: GoogleFonts.hindSiliguri()));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedSpecies = val);
                    },
                  ),
                ),
              ),

              const SizedBox(height: 16),
              Text('আপনার প্রতিষ্ঠানের ধরন', style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isDark ? Colors.white24 : Colors.grey.shade300),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _buyerType,
                    isExpanded: true,
                    items: _buyerTypes.map((t) {
                      return DropdownMenuItem(value: t, child: Text(t, style: GoogleFonts.hindSiliguri()));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _buyerType = val);
                    },
                  ),
                ),
              ),

              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildInputField(
                      controller: _quantityController,
                      label: 'প্রয়োজনীয় পরিমাণ (কেজি) *',
                      hint: 'যেমন: ৫০০',
                      icon: Icons.scale,
                      isNumber: true,
                      validator: (v) => v == null || v.isEmpty ? 'পরিমাণ দিন' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildInputField(
                      controller: _minWeightController,
                      label: 'ন্যূনতম গড় ওজন (গ্রাম) *',
                      hint: 'যেমন: ১২০০',
                      icon: Icons.fitness_center,
                      isNumber: true,
                      validator: (v) => v == null || v.isEmpty ? 'সাইজ দিন' : null,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildInputField(
                      controller: _budgetController,
                      label: 'টার্গেট বাজেট (৳/কেজি) *',
                      hint: 'যেমন: ৩২০',
                      icon: Icons.attach_money,
                      isNumber: true,
                      validator: (v) => v == null || v.isEmpty ? 'বাজেট লিখুন' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('ডেলিভারির শেষ সময়', style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.w600, fontSize: 13)),
                        const SizedBox(height: 6),
                        InkWell(
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: _deliveryDeadline,
                              firstDate: DateTime.now(),
                              lastDate: DateTime.now().add(const Duration(days: 30)),
                            );
                            if (picked != null) setState(() => _deliveryDeadline = picked);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: isDark ? Colors.white24 : Colors.grey.shade300),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('${_deliveryDeadline.day}/${_deliveryDeadline.month}/${_deliveryDeadline.year}', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold)),
                                const Icon(Icons.calendar_month, size: 18, color: Color(0xFF006064)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),
              _buildInputField(
                controller: _addressController,
                label: 'ডেলিভারি নেওয়ার ঠিকানা ও মোকাম *',
                hint: 'যেমন: কাওরান বাজার, ঢাকা',
                icon: Icons.location_on,
              ),

              const SizedBox(height: 16),
              _buildInputField(
                controller: _notesController,
                label: 'বিশেষ শর্ত বা রিকোয়ারমেন্ট',
                hint: 'যেমন: অবশ্যই ভোরে অক্সিজেন ভ্যানে জীবন্ত সরবরাহ করতে হবে',
                icon: Icons.notes,
                maxLines: 2,
              ),

              const SizedBox(height: 10),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                activeColor: deepAqua,
                title: Text('১০০% জ্যান্ত মাছ সরবরাহ আবশ্যক', style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, fontSize: 14)),
                value: _requiresLiveFish,
                onChanged: (v) => setState(() => _requiresLiveFish = v),
              ),

              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _submitRfq,
                  icon: const Icon(Icons.send, color: Colors.white),
                  label: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          'চাহিদাপত্র পোস্ট করুন',
                          style: GoogleFonts.hindSiliguri(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: deepAqua,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool isNumber = false,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.w600, fontSize: 13)),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: isNumber ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
          maxLines: maxLines,
          validator: validator,
          style: GoogleFonts.hindSiliguri(fontSize: 15),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.hindSiliguri(fontSize: 13, color: Colors.grey.shade400),
            prefixIcon: Icon(icon, color: const Color(0xFF006064), size: 20),
            filled: true,
            fillColor: Theme.of(context).cardColor,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: isDark ? Colors.white24 : Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: isDark ? Colors.white24 : Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF006064), width: 2),
            ),
          ),
        ),
      ],
    );
  }
}
