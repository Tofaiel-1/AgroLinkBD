import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:agrolinkbd/core/providers/user_provider.dart';
import 'package:agrolinkbd/core/models/fish_harvest_contract_model.dart';
import 'package:agrolinkbd/core/services/fish_auction_service.dart';

class CreateHarvestContractScreen extends StatefulWidget {
  const CreateHarvestContractScreen({super.key});

  @override
  State<CreateHarvestContractScreen> createState() => _CreateHarvestContractScreenState();
}

class _CreateHarvestContractScreenState extends State<CreateHarvestContractScreen> {
  final _formKey = GlobalKey<FormState>();

  final _pondNameController = TextEditingController(text: 'পুকুর-১ (প্রধান দিঘি)');
  final _estimatedYieldController = TextEditingController();
  final _targetWeightController = TextEditingController();
  final _priceController = TextEditingController();
  final _advancePercentController = TextEditingController(text: '25');
  final _feedingProtocolController = TextEditingController(text: 'উন্নত ফ্লোটিং ফিড ও খৈল');
  final _waterQualityController = TextEditingController(text: 'pH 7.5, অ্যামোনিয়া ০.০, অক্সিজেন ৬.২ ppm');

  String _selectedSpecies = 'দেশি রুই ও কাতলা';
  DateTime _harvestDate = DateTime.now().add(const Duration(days: 30));
  bool _isLoading = false;

  final List<String> _commonSpecies = [
    'দেশি রুই ও কাতলা',
    'পাঙ্গাশ (বড় সাইজ)',
    'তেলাপিয়া ও মনোসেক্স',
    'পাবদা ও গুলশা',
    'দেশি শিং ও মাগুর',
    'বাগদা ও গলদা চিংড়ি',
    'কার্প জাতীয় মাছ (মিক্সড)',
  ];

  @override
  void dispose() {
    _pondNameController.dispose();
    _estimatedYieldController.dispose();
    _targetWeightController.dispose();
    _priceController.dispose();
    _advancePercentController.dispose();
    _feedingProtocolController.dispose();
    _waterQualityController.dispose();
    super.dispose();
  }

  void _submitContract() {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.currentUser;

    final auctionService = Get.isRegistered<FishAuctionService>()
        ? Get.find<FishAuctionService>()
        : Get.put(FishAuctionService());

    final yieldKg = double.tryParse(_estimatedYieldController.text) ?? 500.0;
    final price = double.tryParse(_priceController.text) ?? 300.0;
    final advancePercent = double.tryParse(_advancePercentController.text) ?? 25.0;

    final newContract = FishHarvestContractModel(
      id: 'CNT-FISH-${DateTime.now().millisecondsSinceEpoch}',
      farmerId: user?.id ?? 'farmer_demo',
      farmerName: user?.name ?? 'মৎস্য খামারি',
      farmerPhone: user?.phone ?? '01700000000',
      pondId: 'POND-${DateTime.now().millisecondsSinceEpoch}',
      pondName: _pondNameController.text,
      location: '${user?.upazila ?? "সিংড়া"}, ${user?.district ?? "নাটোর"}',
      district: user?.district ?? 'নাটোর',
      fishSpecies: _selectedSpecies,
      estimatedYieldKg: yieldKg,
      targetAvgWeightGram: double.tryParse(_targetWeightController.text) ?? 1500.0,
      expectedHarvestDate: _harvestDate,
      agreedPricePerKg: price,
      advancePercentage: advancePercent,
      waterQualityReport: _waterQualityController.text,
      feedingProtocol: _feedingProtocolController.text,
      createdAt: DateTime.now(),
    );

    auctionService.addContract(newContract);

    setState(() => _isLoading = false);

    Get.back();
    Get.snackbar(
      'আগাম বিক্রয় প্রস্তাব তৈরি হয়েছে! 📋',
      'আপনার আগাম মাছের লট বুকিংয়ের জন্য উন্মুক্ত করা হয়েছে। ক্রেতারা অগ্রিম দিয়ে বুকিং দিতে পারবেন।',
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
          'আগাম মাছ বিক্রয় চুক্তি (Futures Contract)',
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
              // Advance Benefit Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.verified_user, size: 40, color: Colors.amberAccent),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'মাছ ধরার আগেই ২৫-৩০% অগ্রিম ক্যাশ!',
                            style: GoogleFonts.hindSiliguri(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'মাছ বিক্রির ঝুঁকি দূর করুন। আগে থেকেই নিশ্চিত বায়ারের সাথে দর চূড়ান্ত করে ফিড কেনার ক্যাশফ্লো পান।',
                            style: GoogleFonts.hindSiliguri(fontSize: 12, color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
              Text(
                'চুক্তির বিবরণ ও ফলন প্রজেকশন',
                style: GoogleFonts.hindSiliguri(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 16),

              Text('মাছের প্রজাতি বা জাত', style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.w600)),
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
                    items: _commonSpecies.map((s) {
                      return DropdownMenuItem(value: s, child: Text(s, style: GoogleFonts.hindSiliguri()));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedSpecies = val);
                    },
                  ),
                ),
              ),

              const SizedBox(height: 16),
              _buildInputField(
                controller: _pondNameController,
                label: 'পুকুর বা খামারের নাম',
                hint: 'পুকুর-১',
                icon: Icons.pool,
              ),

              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildInputField(
                      controller: _estimatedYieldController,
                      label: 'প্রত্যাশিত মোট ফলন (কেজি) *',
                      hint: 'যেমন: ১০০০',
                      icon: Icons.scale,
                      isNumber: true,
                      validator: (val) => val == null || val.isEmpty ? 'পরিমাণ দিন' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildInputField(
                      controller: _targetWeightController,
                      label: 'টার্গেট গড় ওজন (গ্রাম) *',
                      hint: 'যেমন: ১৫০০',
                      icon: Icons.fitness_center,
                      isNumber: true,
                      validator: (val) => val == null || val.isEmpty ? 'টার্গেট ওজন দিন' : null,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),
              // Expected Harvest Date Picker
              Text('সম্ভাব্য মাছ ধরার (হারভেস্ট) তারিখ *', style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _harvestDate,
                    firstDate: DateTime.now().add(const Duration(days: 7)),
                    lastDate: DateTime.now().add(const Duration(days: 180)),
                  );
                  if (picked != null) setState(() => _harvestDate = picked);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: isDark ? Colors.white24 : Colors.grey.shade300),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.calendar_month, color: Color(0xFF006064), size: 20),
                          const SizedBox(width: 10),
                          Text(
                            '${_harvestDate.day}/${_harvestDate.month}/${_harvestDate.year} (${_harvestDate.difference(DateTime.now()).inDays} দিন পর)',
                            style: GoogleFonts.hindSiliguri(fontSize: 15, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      const Icon(Icons.arrow_drop_down, color: Colors.grey),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),
              Text(
                'চুক্তির আর্থিক শর্তাবলী ও অগ্রিম এসক্রো',
                style: GoogleFonts.hindSiliguri(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: _buildInputField(
                      controller: _priceController,
                      label: 'নির্ধারিত চুক্তির দর (৳/কেজি) *',
                      hint: 'যেমন: ৩৫০',
                      icon: Icons.attach_money,
                      isNumber: true,
                      validator: (val) => val == null || val.isEmpty ? 'দর উল্লেখ করুন' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildInputField(
                      controller: _advancePercentController,
                      label: 'প্রত্যাশিত অগ্রিম (%) *',
                      hint: '২৫',
                      icon: Icons.percent,
                      isNumber: true,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),
              _buildInputField(
                controller: _feedingProtocolController,
                label: 'ফিডিং ও খাদ্য প্রোটোকল',
                hint: 'যেমন: মেগা প্রিমিয়াম ভাসমান ফিড ও সরিষার খৈল',
                icon: Icons.restaurant,
              ),

              const SizedBox(height: 16),
              _buildInputField(
                controller: _waterQualityController,
                label: 'পানির স্বাস্থ্য ও গুণমান স্টেটাস',
                hint: 'pH 7.5, অ্যামোনিয়া ০.০ ppm',
                icon: Icons.water_drop,
              ),

              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _submitContract,
                  icon: const Icon(Icons.assignment_turned_in, color: Colors.white),
                  label: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          'আগাম চুক্তি পাবলিশ করুন',
                          style: GoogleFonts.hindSiliguri(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
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
