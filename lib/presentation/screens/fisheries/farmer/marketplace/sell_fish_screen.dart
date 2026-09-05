import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:agrolinkbd/core/providers/language_provider.dart';
import 'package:agrolinkbd/core/providers/user_provider.dart';
import 'package:agrolinkbd/core/models/marketplace_item_model.dart';
import 'package:agrolinkbd/core/controllers/marketplace_controller.dart';
import 'package:agrolinkbd/core/models/market_price_model.dart';
import 'package:agrolinkbd/core/services/market_price_service.dart';

class SellFishScreen extends StatefulWidget {
  final MarketplaceItemModel? itemToEdit;
  final String? initialFishType;
  final double? initialPricePerKg;
  final String? initialLocation;

  const SellFishScreen({
    super.key,
    this.itemToEdit,
    this.initialFishType,
    this.initialPricePerKg,
    this.initialLocation,
  });

  @override
  State<SellFishScreen> createState() => _SellFishScreenState();
}

class _SellFishScreenState extends State<SellFishScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fishTypeController = TextEditingController();
  final _quantityController = TextEditingController();
  final _avgWeightController = TextEditingController();
  final _priceController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _phoneController = TextEditingController();

  bool _isLoading = false;
  bool get _isEditing => widget.itemToEdit != null;

  final MarketPriceService _marketPriceService = MarketPriceService();
  StreamSubscription<List<MarketPriceModel>>? _marketPriceSub;
  List<MarketPriceModel> _marketPrices = [];
  MarketPriceModel? _matchedFishPrice;

  final List<String> _popularSpeciesBn = [
    'রুই মাছ',
    'কাতলা মাছ',
    'মৃগেল মাছ',
    'পাঙ্গাস মাছ',
    'তেলাপিয়া মাছ',
    'বাগদা চিংড়ি',
    'গলদা চিংড়ি',
    'শিং মাছ',
    'মাগুর মাছ',
    'পাবদা মাছ',
    'সিলভার কার্প',
    'রূপচাঁদা',
  ];

  final List<String> _popularSpeciesEn = [
    'Rui Fish',
    'Katla Fish',
    'Mrigel Fish',
    'Pangas Fish',
    'Tilapia',
    'Black Tiger Shrimp',
    'Giant River Prawn',
    'Singhi Fish',
    'Magur Fish',
    'Pabda Fish',
    'Silver Carp',
    'Pomfret',
  ];

  @override
  void initState() {
    super.initState();
    _subscribeToMarketPrices();
    _fishTypeController.addListener(_updateFishMatch);
    _priceController.addListener(_onPriceChanged);
    if (_isEditing) {
      final item = widget.itemToEdit!;
      _fishTypeController.text = item.fishType;
      _quantityController.text = item.quantityKg > 0 ? item.quantityKg.toStringAsFixed(0) : '';
      _avgWeightController.text = item.avgWeightGram > 0 ? item.avgWeightGram.toStringAsFixed(0) : '';
      _priceController.text = item.pricePerKg > 0 ? item.pricePerKg.toStringAsFixed(0) : '';
      _locationController.text = item.location;
      _descriptionController.text = item.description ?? '';
      _phoneController.text = item.farmerPhone;
    } else {
      if (widget.initialFishType != null) {
        _fishTypeController.text = widget.initialFishType!;
      }
      if (widget.initialPricePerKg != null && widget.initialPricePerKg! > 0) {
        _priceController.text = widget.initialPricePerKg!.toStringAsFixed(0);
      }
      if (widget.initialLocation != null) {
        _locationController.text = widget.initialLocation!;
      }
    }
  }

  void _subscribeToMarketPrices() {
    _marketPriceSub = _marketPriceService.streamCurrentMarketPrices().listen((prices) {
      if (mounted) {
        setState(() {
          _marketPrices = prices;
          _updateFishMatch();
        });
      }
    });
  }

  void _updateFishMatch() {
    final text = _fishTypeController.text.trim().toLowerCase();
    if (text.isEmpty) {
      if (_matchedFishPrice != null) setState(() => _matchedFishPrice = null);
      return;
    }
    MarketPriceModel? match;
    for (var p in _marketPrices) {
      if (p.category == 'fish' || p.productName.contains('মাছ') || p.productName.toLowerCase().contains('fish')) {
        if (text.contains(p.productName.toLowerCase()) ||
            p.productName.toLowerCase().contains(text)) {
          match = p;
          break;
        }
      }
    }
    // Also try general match if not found in fish
    if (match == null) {
      for (var p in _marketPrices) {
        if (text.contains(p.productName.toLowerCase()) ||
            p.productName.toLowerCase().contains(text)) {
          match = p;
          break;
        }
      }
    }
    if (match != _matchedFishPrice) {
      setState(() => _matchedFishPrice = match);
    }
  }

  void _onPriceChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _marketPriceSub?.cancel();
    _fishTypeController.removeListener(_updateFishMatch);
    _priceController.removeListener(_onPriceChanged);
    _fishTypeController.dispose();
    _quantityController.dispose();
    _avgWeightController.dispose();
    _priceController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isBn = LanguageProvider.isBn(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const Color deepAqua = Color(0xFF004D40);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0C141A) : const Color(0xFFF4F7F9),
      appBar: AppBar(
        title: Text(
          _isEditing
              ? (isBn ? 'মাছের লট সংশোধন করুন' : 'Edit Fish Lot')
              : (isBn ? 'নতুন মাছ বিক্রির বিজ্ঞাপন' : 'Post New Fish Listing'),
          style: GoogleFonts.hindSiliguri(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        backgroundColor: deepAqua,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [const Color(0xFF132B2B), const Color(0xFF0D1D24)]
                        : [const Color(0xFFE0F2F1), const Color(0xFFE8F5E9)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.teal.shade300.withValues(alpha: 0.4)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: deepAqua.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _isEditing ? Icons.edit_note_rounded : Icons.storefront_rounded,
                        color: deepAqua,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _isEditing
                                ? (isBn ? 'লটের তথ্য আপডেট করুন' : 'Update Lot Information')
                                : (isBn ? 'আড়তদার ও পাইকারদের কাছে মাছ বিক্রি' : 'Direct Wholesale & Buyer Listing'),
                            style: GoogleFonts.hindSiliguri(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: isDark ? Colors.tealAccent : deepAqua,
                            ),
                          ),
                          Text(
                            isBn
                                ? 'সঠিক তথ্য দিলে সারাদেশে দ্রুত ক্রেতা পাওয়া যায়।'
                                : 'Accurate lot details attract top buyers and fair prices.',
                            style: GoogleFonts.hindSiliguri(
                              fontSize: 11.5,
                              color: isDark ? Colors.white70 : Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Fish Species Quick Selection
              Text(
                isBn ? 'জনপ্রিয় মাছ নির্বাচন করুন:' : 'Quick Select Fish Species:',
                style: GoogleFonts.hindSiliguri(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.tealAccent : const Color(0xFF004D40),
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: (isBn ? _popularSpeciesBn : _popularSpeciesEn).map((species) {
                  final isSelected = _fishTypeController.text.trim() == species.trim();
                  return InkWell(
                    onTap: () {
                      setState(() {
                        _fishTypeController.text = species;
                      });
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? deepAqua
                            : (isDark ? const Color(0xFF1E2D38) : Colors.white),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? deepAqua : Colors.teal.shade200.withValues(alpha: 0.6),
                          width: 1.2,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: deepAqua.withValues(alpha: 0.3),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                )
                              ]
                            : null,
                      ),
                      child: Text(
                        species,
                        style: GoogleFonts.hindSiliguri(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 18),

              // Fish Species Input Field
              _buildInputField(
                label: isBn ? 'মাছের নাম / প্রজাতি' : 'Fish Species Name',
                hint: isBn ? 'যেমন: রুই মাছ, গলদা চিংড়ি' : 'e.g. Rui Fish, River Prawn',
                icon: Icons.set_meal_rounded,
                controller: _fishTypeController,
                isDark: isDark,
                isBn: isBn,
              ),

              if (_matchedFishPrice != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0F2FE),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFF7DD3FC)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _matchedFishPrice!.trend == PriceTrend.up
                            ? Icons.trending_up_rounded
                            : _matchedFishPrice!.trend == PriceTrend.down
                                ? Icons.trending_down_rounded
                                : Icons.info_outline_rounded,
                        size: 18,
                        color: _matchedFishPrice!.trend == PriceTrend.up
                            ? const Color(0xFFEF4444)
                            : const Color(0xFF0284C7),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isBn
                                  ? 'বাজার রেট (লাইভ): ৳${_matchedFishPrice!.currentPrice.toStringAsFixed(0)} / ${_matchedFishPrice!.unit}'
                                  : 'Market Rate (Live): ৳${_matchedFishPrice!.currentPrice.toStringAsFixed(0)} / ${_matchedFishPrice!.unit}',
                              style: GoogleFonts.hindSiliguri(
                                fontSize: 12.5,
                                color: const Color(0xFF0369A1),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              isBn
                                  ? 'সুপার এডমিন কর্তৃক নির্ধারিত বর্তমান বেস প্রাইস'
                                  : 'Current market rate set by Super Admin',
                              style: GoogleFonts.hindSiliguri(
                                fontSize: 10,
                                color: const Color(0xFF0284C7),
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          _priceController.text = _matchedFishPrice!.currentPrice.toStringAsFixed(0);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0284C7),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            isBn ? 'দর বসান' : 'Apply Rate',
                            style: GoogleFonts.hindSiliguri(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 14),

              // Quantity & Avg Weight Row
              Row(
                children: [
                  Expanded(
                    child: _buildInputField(
                      label: isBn ? 'মোট পরিমাণ (কেজি)' : 'Total Quantity (kg)',
                      hint: '100',
                      icon: Icons.scale_rounded,
                      controller: _quantityController,
                      isNumber: true,
                      isDark: isDark,
                      isBn: isBn,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildInputField(
                      label: isBn ? 'গড় ওজন (গ্রাম)' : 'Avg Weight (g)',
                      hint: '1200',
                      icon: Icons.fitness_center_rounded,
                      controller: _avgWeightController,
                      isNumber: true,
                      isDark: isDark,
                      isBn: isBn,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // Price per kg & Location Row
              Row(
                children: [
                  Expanded(
                    child: _buildInputField(
                      label: isBn ? 'প্রত্যাশিত দর (টাকা/কেজি)' : 'Price (৳/kg)',
                      hint: '320',
                      icon: Icons.monetization_on_rounded,
                      controller: _priceController,
                      isNumber: true,
                      isDark: isDark,
                      isBn: isBn,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildInputField(
                      label: isBn ? 'খামারের জেলা / এলাকা' : 'District / Area',
                      hint: isBn ? 'ময়মনসিংহ' : 'Mymensingh',
                      icon: Icons.location_on_rounded,
                      controller: _locationController,
                      isDark: isDark,
                      isBn: isBn,
                      isRequired: false,
                    ),
                  ),
                ],
              ),

              if (_matchedFishPrice != null) ...[
                const SizedBox(height: 8),
                _buildFishPriceAdvisoryChip(isBn, isDark),
              ],

              const SizedBox(height: 14),

              // Contact Phone
              _buildInputField(
                label: isBn ? 'যোগাযোগের মোবাইল নম্বর' : 'Contact Phone Number',
                hint: '017XXXXXXXX',
                icon: Icons.phone_rounded,
                controller: _phoneController,
                isNumber: true,
                isDark: isDark,
                isBn: isBn,
                isRequired: false,
              ),

              const SizedBox(height: 14),

              // Description / Notes
              _buildInputField(
                label: isBn ? 'মাছের বিশেষ বিবরণ ও শর্তাবলী (ঐচ্ছিক)' : 'Harvest Notes & Details (Optional)',
                hint: isBn ? 'যেমন: শতভাগ জীবন্ত অক্সিজেন ডেলিভারি সম্ভব, ফিড খাওয়ানো তাজা মাছ।' : 'e.g. 100% live oxygen harvest, organic feed fed.',
                icon: Icons.notes_rounded,
                controller: _descriptionController,
                isDark: isDark,
                isBn: isBn,
                maxLines: 3,
                isRequired: false,
              ),

              const SizedBox(height: 24),

              // Total Estimate Banner Preview
              AnimatedBuilder(
                animation: Listenable.merge([_quantityController, _priceController]),
                builder: (context, _) {
                  final qty = double.tryParse(_quantityController.text) ?? 0.0;
                  final price = double.tryParse(_priceController.text) ?? 0.0;
                  final total = qty * price;

                  if (total <= 0) return const SizedBox.shrink();

                  return Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF132B2B) : const Color(0xFFE0F2F1),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.teal.shade300),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isBn ? 'লটের আনুমানিক মোট বিক্রয়মূল্য:' : 'Estimated Total Lot Value:',
                          style: GoogleFonts.hindSiliguri(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            color: isDark ? Colors.tealAccent : const Color(0xFF004D40),
                          ),
                        ),
                        Text(
                          '৳${total.toStringAsFixed(0)}',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: const Color(0xFF00796B),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : () => _submitFishListing(isBn),
                  icon: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : Icon(_isEditing ? Icons.check_circle_rounded : Icons.cloud_upload_rounded, color: Colors.white),
                  label: Text(
                    _isLoading
                        ? (isBn ? 'সংরক্ষণ হচ্ছে...' : 'Saving to Database...')
                        : (_isEditing
                            ? (isBn ? 'লটের তথ্য আপডেট করুন' : 'Update Lot Listing')
                            : (isBn ? 'মার্কেটপ্লেসে মাছ বিজ্ঞাপন দিন' : 'Publish Fish Listing')),
                    style: GoogleFonts.hindSiliguri(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: deepAqua,
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    required bool isDark,
    required bool isBn,
    bool isNumber = false,
    bool isRequired = true,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.hindSiliguri(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white70 : Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: isNumber
              ? const TextInputType.numberWithOptions(decimal: true)
              : (maxLines > 1 ? TextInputType.multiline : TextInputType.text),
          style: GoogleFonts.hindSiliguri(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : Colors.black87,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.hindSiliguri(color: Colors.grey.shade400, fontSize: 13),
            prefixIcon: Icon(icon, color: const Color(0xFF00796B), size: 20),
            filled: true,
            fillColor: isDark ? const Color(0xFF16252F) : Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.teal.shade100),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: isDark ? Colors.white12 : Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF00796B), width: 2),
            ),
          ),
          validator: isRequired
              ? (value) {
                  if (value == null || value.trim().isEmpty) {
                    return isBn ? 'এই তথ্যটি দেওয়া আবশ্যক' : 'This field is required';
                  }
                  if (isNumber) {
                    final numVal = double.tryParse(value.trim());
                    if (numVal == null || numVal <= 0) {
                      return isBn ? 'সঠিক সংখ্যা প্রদান করুন' : 'Please enter a valid positive number';
                    }
                  }
                  return null;
                }
              : null,
        ),
      ],
    );
  }

  Future<void> _submitFishListing(bool isBn) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final user = userProvider.currentUser;
      final currentUid = FirebaseAuth.instance.currentUser?.uid ?? user?.id ?? 'FARMER_123';
      final farmerName = user?.name ?? FirebaseAuth.instance.currentUser?.displayName ?? (isBn ? 'খামারী' : 'Fish Farmer');
      final farmerPhone = _phoneController.text.trim().isNotEmpty
          ? _phoneController.text.trim()
          : (user?.phone ?? FirebaseAuth.instance.currentUser?.phoneNumber ?? '');

      final marketplaceController = Get.find<MarketplaceController>();

      if (_isEditing) {
        // Update existing lot
        final updatedLot = widget.itemToEdit!.copyWith(
          fishType: _fishTypeController.text.trim(),
          quantityKg: double.parse(_quantityController.text.trim()),
          avgWeightGram: double.parse(_avgWeightController.text.trim()),
          pricePerKg: double.parse(_priceController.text.trim()),
          location: _locationController.text.trim(),
          farmerPhone: farmerPhone,
          description: _descriptionController.text.trim(),
          updatedAt: DateTime.now(),
        );

        final success = await marketplaceController.updateLot(updatedLot);
        if (success) {
          if (mounted) {
            Navigator.of(context).pop();
            Get.snackbar(
              isBn ? 'সফলভাবে সংরক্ষিত' : 'Successfully Updated',
              isBn ? 'মাছের লটের তথ্য ডেটাবেসে আপডেট হয়েছে।' : 'Fish lot has been updated in database.',
              backgroundColor: const Color(0xFF004D40),
              colorText: Colors.white,
              snackPosition: SnackPosition.BOTTOM,
              margin: const EdgeInsets.all(16),
            );
          }
        } else {
          throw Exception('Failed to update lot in database.');
        }
      } else {
        // Create new real lot in Firebase
        final newItem = MarketplaceItemModel(
          id: 'LOT_${DateTime.now().millisecondsSinceEpoch}',
          farmerId: currentUid,
          farmerName: farmerName,
          farmerPhone: farmerPhone,
          fishType: _fishTypeController.text.trim(),
          quantityKg: double.parse(_quantityController.text.trim()),
          avgWeightGram: double.parse(_avgWeightController.text.trim()),
          pricePerKg: double.parse(_priceController.text.trim()),
          location: _locationController.text.trim().isNotEmpty ? _locationController.text.trim() : (isBn ? 'বাংলাদেশ' : 'Bangladesh'),
          status: 'active',
          description: _descriptionController.text.trim(),
          createdAt: DateTime.now(),
        );

        final newDocId = await marketplaceController.addLot(newItem);
        if (newDocId != null) {
          if (mounted) {
            Navigator.of(context).pop();
            Get.snackbar(
              isBn ? 'সফলভাবে লিস্ট হয়েছে' : 'Successfully Listed',
              isBn ? 'আপনার মাছের লট সরাসরি ফায়ারবেস ডেটাবেসে বিজ্ঞাপিত হয়েছে!' : 'Fish lot published to live marketplace database!',
              backgroundColor: const Color(0xFF004D40),
              colorText: Colors.white,
              snackPosition: SnackPosition.BOTTOM,
              margin: const EdgeInsets.all(16),
            );
          }
        } else {
          throw Exception('Failed to create lot in database.');
        }
      }
    } catch (e) {
      Get.snackbar(
        isBn ? 'ত্রুটি' : 'Error',
        isBn ? 'তথ্য সংরক্ষণে সমস্যা হয়েছে: $e' : 'Failed to save lot: $e',
        backgroundColor: Colors.red.shade700,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildFishPriceAdvisoryChip(bool isBn, bool isDark) {
    if (_matchedFishPrice == null) return const SizedBox.shrink();

    final bench = _matchedFishPrice!.currentPrice;
    final unitText = _matchedFishPrice!.unit;
    final enteredText = _priceController.text.trim();
    final enteredPrice = double.tryParse(enteredText);

    if (enteredPrice == null || enteredPrice <= 0) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0F2633) : const Color(0xFFE0F2FE),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFF0284C7).withValues(alpha: 0.4)),
        ),
        child: Row(
          children: [
            const Icon(Icons.info_outline_rounded, size: 16, color: Color(0xFF0284C7)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                isBn
                    ? 'বর্তমান বাজার রেট: ৳${bench.toStringAsFixed(0)} / $unitText'
                    : 'Current Market Rate: ৳${bench.toStringAsFixed(0)} / $unitText',
                style: GoogleFonts.hindSiliguri(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isDark ? const Color(0xFF38BDF8) : const Color(0xFF0369A1),
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                _priceController.text = bench.toStringAsFixed(0);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF0284C7),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  isBn ? 'দর বসান' : 'Apply Rate',
                  style: GoogleFonts.hindSiliguri(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    final diff = (enteredPrice - bench) / bench;

    if (diff.abs() <= 0.05) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF10281C) : const Color(0xFFE8F5E9),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.green.withValues(alpha: 0.4)),
        ),
        child: Row(
          children: [
            const Icon(Icons.check_circle_outline, size: 16, color: Colors.green),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                isBn
                    ? '✓ নির্ধারিত দর বাজারদরের (৳${bench.toStringAsFixed(0)}/$unitText) সাথে মানানসই।'
                    : '✓ Price aligns with market benchmark (৳${bench.toStringAsFixed(0)}/$unitText).',
                style: GoogleFonts.hindSiliguri(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.greenAccent : const Color(0xFF1B5E20),
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (diff > 0.05) {
      final diffAmount = (enteredPrice - bench).toStringAsFixed(0);
      return Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2A1C0E) : const Color(0xFFFFF8E1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.amber.shade700.withValues(alpha: 0.5)),
        ),
        child: Row(
          children: [
            Icon(Icons.trending_down_rounded, size: 18, color: Colors.amber.shade800),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isBn
                        ? 'বাজারের চেয়ে ৳$diffAmount বেশি (দর কমানোর সুপারিশ)'
                        : '৳$diffAmount above market (Decrease advised)',
                    style: GoogleFonts.hindSiliguri(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber.shade900,
                    ),
                  ),
                  Text(
                    isBn
                        ? 'মাছ পচনশীল পণ্য, দ্রুত আড়তদার বিড পেতে বাজারদর ৳${bench.toStringAsFixed(0)} নির্ধারণ করুন।'
                        : 'Fresh fish is perishable; align with ৳${bench.toStringAsFixed(0)} to sell quickly.',
                    style: GoogleFonts.hindSiliguri(
                      fontSize: 10.5,
                      color: isDark ? Colors.grey.shade400 : Colors.grey.shade800,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            ElevatedButton(
              onPressed: () {
                _priceController.text = bench.toStringAsFixed(0);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber.shade800,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              ),
              child: Text(
                isBn ? '৳${bench.toStringAsFixed(0)} করুন' : 'Set ৳${bench.toStringAsFixed(0)}',
                style: GoogleFonts.hindSiliguri(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      );
    }

    final diffAmount = (bench - enteredPrice).toStringAsFixed(0);
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F2633) : const Color(0xFFE0F2FE),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF0284C7).withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          const Icon(Icons.trending_up_rounded, size: 18, color: Color(0xFF0284C7)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isBn
                      ? 'বাজারের চেয়ে ৳$diffAmount কম (দর বাড়ানোর সুযোগ)'
                      : '৳$diffAmount below market (Increase advised)',
                  style: GoogleFonts.hindSiliguri(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0284C7),
                  ),
                ),
                Text(
                  isBn
                      ? 'আপনার লাভ বাড়াতে বর্তমান বাজার রেট ৳${bench.toStringAsFixed(0)}/$unitText নির্ধারণ করতে পারেন।'
                      : 'You can increase price to ৳${bench.toStringAsFixed(0)}/$unitText for fair margin.',
                  style: GoogleFonts.hindSiliguri(
                    fontSize: 10.5,
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade800,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          ElevatedButton(
            onPressed: () {
              _priceController.text = bench.toStringAsFixed(0);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0284C7),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
            ),
            child: Text(
              isBn ? '৳${bench.toStringAsFixed(0)} করুন' : 'Set ৳${bench.toStringAsFixed(0)}',
              style: GoogleFonts.hindSiliguri(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
