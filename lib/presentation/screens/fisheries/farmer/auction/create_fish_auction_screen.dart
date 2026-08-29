import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:agrolinkbd/core/providers/user_provider.dart';
import 'package:agrolinkbd/core/models/fish_auction_model.dart';
import 'package:agrolinkbd/core/services/fish_auction_service.dart';

class CreateFishAuctionScreen extends StatefulWidget {
  const CreateFishAuctionScreen({super.key});

  @override
  State<CreateFishAuctionScreen> createState() => _CreateFishAuctionScreenState();
}

class _CreateFishAuctionScreenState extends State<CreateFishAuctionScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final _lotTitleController = TextEditingController();
  final _totalKgController = TextEditingController();
  final _avgWeightController = TextEditingController();
  final _startPriceController = TextEditingController();
  final _reservePriceController = TextEditingController();
  final _minIncrementController = TextEditingController(text: '5');
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();

  String _selectedSpecies = 'দেশি রুই';
  FishCondition _selectedCondition = FishCondition.liveInWater;
  String _selectedGrade = 'Grade A+ (তাজা জ্যান্ত)';
  int _auctionDurationHours = 24;
  bool _providesOxygenTransport = true;
  bool _isLoading = false;

  final List<String> _commonSpecies = [
    'দেশি রুই',
    'কাতলা',
    'মৃগেল ও কার্প',
    'পাঙ্গাশ (মাটিমুক্ত)',
    'তেলাপিয়া',
    'দেশি শিং ও মাগুর',
    'পাবদা ও গুলশা',
    'কৈ (ভিয়েতনাম/দেশি)',
    'বাগদা চিংড়ি',
    'গলদা চিংড়ি',
    'পদ্মার ইলিশ',
    'কোরাল / ভেঁটকি',
  ];

  @override
  void dispose() {
    _lotTitleController.dispose();
    _totalKgController.dispose();
    _avgWeightController.dispose();
    _startPriceController.dispose();
    _reservePriceController.dispose();
    _minIncrementController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _submitAuction() {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.currentUser;

    final auctionService = Get.isRegistered<FishAuctionService>()
        ? Get.find<FishAuctionService>()
        : Get.put(FishAuctionService());

    final totalKg = double.tryParse(_totalKgController.text) ?? 100.0;
    final startPrice = double.tryParse(_startPriceController.text) ?? 200.0;

    final newAuction = FishAuctionModel(
      id: 'AUC-FISH-${DateTime.now().millisecondsSinceEpoch}',
      farmerId: user?.id ?? 'farmer_demo',
      farmerName: user?.name ?? 'মৎস্য খামারি',
      farmerPhone: user?.phone ?? '01700000000',
      farmLocation: _locationController.text.isNotEmpty
          ? _locationController.text
          : '${user?.upazila ?? "সিংড়া"}, ${user?.district ?? "নাটোর"}',
      district: user?.district ?? 'নাটোর',
      upazila: user?.upazila ?? 'সিংড়া',
      fishSpecies: _selectedSpecies,
      lotTitle: _lotTitleController.text.isNotEmpty
          ? _lotTitleController.text
          : '$_selectedSpecies এর $totalKg কেজি লট',
      estimatedTotalKg: totalKg,
      avgWeightGram: double.tryParse(_avgWeightController.text) ?? 1000.0,
      condition: _selectedCondition,
      grade: _selectedGrade,
      images: [
        'https://images.unsplash.com/photo-1534483509719-3feaee7c30da?w=600&auto=format&fit=crop&q=80',
      ],
      startingPricePerKg: startPrice,
      reservePricePerKg: double.tryParse(_reservePriceController.text),
      minBidIncrement: double.tryParse(_minIncrementController.text) ?? 5.0,
      currentHighestBidPerKg: startPrice,
      startTime: DateTime.now(),
      endTime: DateTime.now().add(Duration(hours: _auctionDurationHours)),
      status: FishAuctionStatus.live,
      providesOxygenTransport: _providesOxygenTransport,
      description: _descriptionController.text.isNotEmpty
          ? _descriptionController.text
          : 'উন্নত মানের মাছ, খামার থেকে সরাসরি লাইভ বিডিংয়ে বিক্রয়ের জন্য প্রস্তাবিত।',
      createdAt: DateTime.now(),
    );

    auctionService.addAuction(newAuction);

    setState(() => _isLoading = false);

    Get.back();
    Get.snackbar(
      'লাইভ ডাক শুরু হয়েছে! 🐟',
      'আপনার মাছের লটটি সফলভাবে নিলাম ঘরে লাইভ করা হয়েছে। পাইকাররা বিড করতে পারবেন।',
      backgroundColor: const Color(0xFF006064),
      colorText: Colors.white,
      duration: const Duration(seconds: 4),
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color deepAqua = Color(0xFF006064);
    const Color oceanBlue = Color(0xFF0288D1);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(
          'মাছের লাইভ ডাক তুলুন (Auction)',
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
                  boxShadow: [
                    BoxShadow(
                      color: deepAqua.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.gavel, size: 40, color: Colors.amberAccent),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'সরাসরি পাইকারদের কাছে সর্বোচ্চ দামে বিক্রি',
                            style: GoogleFonts.hindSiliguri(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'কোনো দালাল সিন্ডিকেট ছাড়া সারাদেশের আড়তদারদের থেকে লাইভ দর প্রস্তাব পান।',
                            style: GoogleFonts.hindSiliguri(
                              fontSize: 12,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
              Text(
                'মাছের বিবরণ ও লটের তথ্য',
                style: GoogleFonts.hindSiliguri(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 16),

              // Species Dropdown
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
                      return DropdownMenuItem(
                        value: s,
                        child: Text(s, style: GoogleFonts.hindSiliguri(fontSize: 15)),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedSpecies = val);
                    },
                  ),
                ),
              ),

              const SizedBox(height: 16),
              _buildInputField(
                controller: _lotTitleController,
                label: 'লটের শিরোনাম (ঐচ্ছিক)',
                hint: 'যেমন: পুকুর-১ এর ৫০০ কেজি জ্যান্ত রুই মাছ',
                icon: Icons.title,
              ),

              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildInputField(
                      controller: _totalKgController,
                      label: 'মোট ওজন (কেজি) *',
                      hint: 'যেমন: ৫০০',
                      icon: Icons.scale,
                      isNumber: true,
                      validator: (val) => val == null || val.isEmpty ? 'পরিমাণ দিন' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildInputField(
                      controller: _avgWeightController,
                      label: 'গড় ওজন (প্রতিটির গ্রাম) *',
                      hint: 'যেমন: ১৫০০',
                      icon: Icons.fitness_center,
                      isNumber: true,
                      validator: (val) => val == null || val.isEmpty ? 'গড় ওজন দিন' : null,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),
              Text('সরবরাহের অবস্থা (Condition)', style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildConditionChip(FishCondition.liveInWater, 'জ্যান্ত মাছ (অক্সিজেন ড্রাম)', Icons.pool),
                  const SizedBox(width: 8),
                  _buildConditionChip(FishCondition.icedFresh, 'বরফ দেওয়া তাজা', Icons.ac_unit),
                ],
              ),

              const SizedBox(height: 24),
              Text(
                'নিলামের আর্থিক শর্তাবলী',
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
                      controller: _startPriceController,
                      label: 'প্রারম্ভিক দর (৳/কেজি) *',
                      hint: 'যেমন: ৩২০',
                      icon: Icons.sell,
                      isNumber: true,
                      validator: (val) => val == null || val.isEmpty ? 'শুরুর দর দিন' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildInputField(
                      controller: _reservePriceController,
                      label: 'গোপন রিজার্ভ দর (৳/কেজি)',
                      hint: 'যেমন: ৩৫০',
                      icon: Icons.lock_outline,
                      isNumber: true,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildInputField(
                      controller: _minIncrementController,
                      label: 'ন্যূনতম বৃদ্ধি (৳/বিড)',
                      hint: '৫',
                      icon: Icons.trending_up,
                      isNumber: true,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('নিলামের সময়সীমা', style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: isDark ? Colors.white24 : Colors.grey.shade300),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<int>(
                              value: _auctionDurationHours,
                              isExpanded: true,
                              items: const [
                                DropdownMenuItem(value: 6, child: Text('৬ ঘণ্টা (জরুরি)')),
                                DropdownMenuItem(value: 12, child: Text('১২ ঘণ্টা')),
                                DropdownMenuItem(value: 24, child: Text('২৪ ঘণ্টা (১ দিন)')),
                                DropdownMenuItem(value: 48, child: Text('৪৮ ঘণ্টা (২ দিন)')),
                              ],
                              onChanged: (val) {
                                if (val != null) setState(() => _auctionDurationHours = val);
                              },
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
                controller: _locationController,
                label: 'খামারের অবস্থান / পিকআপ পয়েন্ট',
                hint: 'যেমন: সিংড়া, চলনবিল রোড, নাটোর',
                icon: Icons.location_on,
              ),

              const SizedBox(height: 16),
              _buildInputField(
                controller: _descriptionController,
                label: 'বিশেষ বিবরণ (ফিড, স্বাদ ও গুণমান)',
                hint: 'যেমন: ১০০% ভাসমান ফিড ও প্রাকৃতিক খাবারে চাষকৃত',
                icon: Icons.description,
                maxLines: 2,
              ),

              const SizedBox(height: 12),
              // Oxygen Transport Switch
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                activeColor: deepAqua,
                title: Text(
                  'আমাদের নিজস্ব অক্সিজেন ভ্যানে ডেলিভারি দিতে সক্ষম',
                  style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.w600, fontSize: 14),
                ),
                subtitle: Text(
                  'জ্যান্ত মাছ দ্রুত পৌঁছালে পাইকাররা বেশি দর দিতে আগ্রহী হয়',
                  style: GoogleFonts.hindSiliguri(fontSize: 12, color: Colors.grey.shade600),
                ),
                value: _providesOxygenTransport,
                onChanged: (val) => setState(() => _providesOxygenTransport = val),
              ),

              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _submitAuction,
                  icon: const Icon(Icons.flash_on, color: Colors.white),
                  label: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          'নিলাম লাইভ করুন (Start Auction)',
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

  Widget _buildConditionChip(FishCondition condition, String title, IconData icon) {
    final isSelected = _selectedCondition == condition;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedCondition = condition),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF006064).withOpacity(0.12) : Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? const Color(0xFF006064) : Colors.grey.shade300,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: isSelected ? const Color(0xFF006064) : Colors.grey),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  title,
                  style: GoogleFonts.hindSiliguri(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? const Color(0xFF006064) : Colors.black87,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
