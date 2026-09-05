import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:agrolinkbd/core/services/admin_price_command_service.dart';

class AdminQuickPriceCommandSheet extends StatefulWidget {
  final PriceCommandScope initialScope;
  final PriceCommandAction initialAction;
  final String? initialCategory;
  final String? initialDistrict;
  final String? initialDivision;
  final double? initialDelta;
  final String? initialReason;
  final VoidCallback? onCommandExecuted;

  const AdminQuickPriceCommandSheet({
    super.key,
    this.initialScope = PriceCommandScope.all,
    this.initialAction = PriceCommandAction.decrease,
    this.initialCategory,
    this.initialDistrict,
    this.initialDivision,
    this.initialDelta,
    this.initialReason,
    this.onCommandExecuted,
  });

  static Future<void> show(
    BuildContext context, {
    PriceCommandScope initialScope = PriceCommandScope.all,
    PriceCommandAction initialAction = PriceCommandAction.decrease,
    String? initialCategory,
    String? initialDistrict,
    String? initialDivision,
    double? initialDelta,
    String? initialReason,
    VoidCallback? onCommandExecuted,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => AdminQuickPriceCommandSheet(
        initialScope: initialScope,
        initialAction: initialAction,
        initialCategory: initialCategory,
        initialDistrict: initialDistrict,
        initialDivision: initialDivision,
        initialDelta: initialDelta,
        initialReason: initialReason,
        onCommandExecuted: onCommandExecuted,
      ),
    );
  }

  @override
  State<AdminQuickPriceCommandSheet> createState() =>
      _AdminQuickPriceCommandSheetState();
}

class _AdminQuickPriceCommandSheetState
    extends State<AdminQuickPriceCommandSheet> {
  final AdminPriceCommandService _commandService = AdminPriceCommandService();
  final TextEditingController _customDeltaController = TextEditingController(text: '10');
  final TextEditingController _reasonController = TextEditingController();

  late PriceCommandScope _selectedScope;
  late PriceCommandAction _selectedAction;
  PriceAdjustmentUnit _selectedUnit = PriceAdjustmentUnit.percent;
  double _deltaValue = 10.0;
  String _selectedCategory = 'all';
  String _selectedDivision = 'rajshahi';
  String _selectedDistrict = 'natore';
  String _selectedDuration = 'permanent';
  bool _circuitBreakerConfirmed = false;

  bool _isExecuting = false;
  int _affectedProductsCount = 0;
  int _affectedFishLotsCount = 0;
  bool _isLoadingCounts = true;
  PriceSimulationResult? _simulationResult;

  final List<Map<String, String>> _divisions = [
    {'value': 'rajshahi', 'labelBn': 'রাজশাহী বিভাগ', 'labelEn': 'Rajshahi Division'},
    {'value': 'dhaka', 'labelBn': 'ঢাকা বিভাগ', 'labelEn': 'Dhaka Division'},
    {'value': 'rangpur', 'labelBn': 'রংপুর বিভাগ', 'labelEn': 'Rangpur Division'},
    {'value': 'chittagong', 'labelBn': 'চট্টগ্রাম বিভাগ', 'labelEn': 'Chattogram Division'},
    {'value': 'khulna', 'labelBn': 'খুলনা বিভাগ', 'labelEn': 'Khulna Division'},
    {'value': 'barisal', 'labelBn': 'বরিশাল বিভাগ', 'labelEn': 'Barisal Division'},
    {'value': 'sylhet', 'labelBn': 'সিলেট বিভাগ', 'labelEn': 'Sylhet Division'},
    {'value': 'mymensingh', 'labelBn': 'ময়মনসিংহ বিভাগ', 'labelEn': 'Mymensingh Division'},
  ];

  final List<Map<String, String>> _districts = [
    {'value': 'natore', 'labelBn': 'নাটোর', 'labelEn': 'Natore'},
    {'value': 'bogura', 'labelBn': 'বগুড়া', 'labelEn': 'Bogura'},
    {'value': 'mymensingh', 'labelBn': 'ময়মনসিংহ', 'labelEn': 'Mymensingh'},
    {'value': 'pabna', 'labelBn': 'পাবনা', 'labelEn': 'Pabna'},
    {'value': 'sirajganj', 'labelBn': 'সিরাজগঞ্জ', 'labelEn': 'Sirajganj'},
    {'value': 'dinajpur', 'labelBn': 'দিনাজপুর', 'labelEn': 'Dinajpur'},
    {'value': 'jashore', 'labelBn': 'যশোর', 'labelEn': 'Jashore'},
    {'value': 'comilla', 'labelBn': 'কুমিল্লা', 'labelEn': 'Comilla'},
    {'value': 'dhaka', 'labelBn': 'ঢাকা সদর', 'labelEn': 'Dhaka Sadar'},
    {'value': 'rajshahi', 'labelBn': 'রাজশাহী সদর', 'labelEn': 'Rajshahi Sadar'},
  ];

  final List<Map<String, String>> _durations = [
    {'value': 'permanent', 'label': 'স্থায়ী সমন্বয় (Permanent)'},
    {'value': '24h', 'label': '২৪ ঘণ্টা (24 Hours)'},
    {'value': '48h', 'label': '৪৮ ঘণ্টা (48 Hours)'},
    {'value': '7d', 'label': '৭ দিন (7 Days)'},
  ];

  @override
  void initState() {
    super.initState();
    _selectedScope = widget.initialScope;
    _selectedAction = widget.initialAction;
    _selectedCategory = widget.initialCategory ?? 'all';
    _selectedDistrict = widget.initialDistrict ?? 'natore';
    _selectedDivision = widget.initialDivision ?? 'rajshahi';
    if (widget.initialDelta != null) {
      _deltaValue = widget.initialDelta!;
      _customDeltaController.text = widget.initialDelta!.toStringAsFixed(0);
    }
    if (widget.initialReason != null && widget.initialReason!.isNotEmpty) {
      _reasonController.text = widget.initialReason!;
    } else {
      _applyPresetReason();
    }
    _fetchLiveCountsAndSimulation();
  }

  @override
  void dispose() {
    _customDeltaController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  void _applyPresetReason() {
    final unitStr = _selectedUnit == PriceAdjustmentUnit.percent ? '%' : '৳';
    final deltaStr = _deltaValue.toStringAsFixed(0);
    String geoContext = '';
    if (_selectedScope == PriceCommandScope.district) {
      geoContext = ' ($_selectedDistrict জেলায়)';
    } else if (_selectedScope == PriceCommandScope.division) {
      geoContext = ' ($_selectedDivision বিভাগে)';
    }

    if (_selectedAction == PriceCommandAction.decrease) {
      _reasonController.text =
          'পাইকারি বাজারে সরবরাহ বৃদ্ধির প্রেক্ষিতে সাময়িক $deltaStr$unitStr মূল্য হ্রাস$geoContext';
    } else if (_selectedAction == PriceCommandAction.increase) {
      _reasonController.text =
          'বাজারদর বৃদ্ধির প্রেক্ষিতে কৃষক সুরক্ষায় $deltaStr$unitStr মূল্য বৃদ্ধি$geoContext';
    } else if (_selectedAction == PriceCommandAction.syncBenchmark) {
      _reasonController.text = 'সুপার এডমিন সরকারি ও কেন্দ্রীয় বাজার রেটে সমন্বিত সমতা';
    } else {
      _reasonController.text = 'এডমিন ওভাররাইড প্রত্যাহার করে কৃষকের আসল মূল্যে ফেরত';
    }
  }

  Future<void> _fetchLiveCountsAndSimulation() async {
    setState(() => _isLoadingCounts = true);
    final counts = await _commandService.getAffectedCounts(
      scope: _selectedScope,
      category: _selectedCategory != 'all' ? _selectedCategory : null,
      district: _selectedScope == PriceCommandScope.district ? _selectedDistrict : null,
      division: _selectedScope == PriceCommandScope.division ? _selectedDivision : null,
    );

    final sim = await _commandService.calculateSimulatedImpact(
      scope: _selectedScope,
      action: _selectedAction,
      unit: _selectedUnit,
      deltaValue: _deltaValue,
      targetCategory: _selectedCategory != 'all' ? _selectedCategory : null,
      targetDistrict: _selectedScope == PriceCommandScope.district ? _selectedDistrict : null,
      targetDivision: _selectedScope == PriceCommandScope.division ? _selectedDivision : null,
    );

    if (mounted) {
      setState(() {
        _affectedProductsCount = counts['products'] ?? 0;
        _affectedFishLotsCount = counts['fishLots'] ?? 0;
        _simulationResult = sim;
        _isLoadingCounts = false;
      });
    }
  }

  Future<void> _handleExecute() async {
    if (_deltaValue > 25 && !_circuitBreakerConfirmed) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '⚠️ ২৫% এর বেশি পরিবর্তন করতে সার্কিট ব্রেকার কনফার্মেশন অন করুন।',
            style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold),
          ),
          backgroundColor: const Color(0xFFD97706),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isExecuting = true);

    final result = await _commandService.executePriceCommand(
      scope: _selectedScope,
      action: _selectedAction,
      unit: _selectedUnit,
      deltaValue: _deltaValue,
      reason: _reasonController.text.trim(),
      targetCategory: _selectedCategory != 'all' ? _selectedCategory : null,
      targetDistrict: _selectedScope == PriceCommandScope.district ? _selectedDistrict : null,
      targetDivision: _selectedScope == PriceCommandScope.division ? _selectedDivision : null,
      durationOption: _selectedDuration,
    );

    if (mounted) {
      setState(() => _isExecuting = false);
      if (result.success) {
        widget.onCommandExecuted?.call();
      }
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                result.success ? Icons.check_circle_rounded : Icons.error_rounded,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  result.message,
                  style: GoogleFonts.hindSiliguri(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: result.success
              ? const Color(0xFF10B981)
              : const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0F172A) : Colors.white;
    final cardBg = isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC);
    final borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1);
    final textPrimary = isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A);
    final textSecondary = isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569);

    final isHighDelta = _deltaValue > 25 &&
        (_selectedAction == PriceCommandAction.decrease ||
            _selectedAction == PriceCommandAction.increase);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.92,
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag Handle
          Container(
            margin: const EdgeInsets.only(top: 10, bottom: 6),
            width: 44,
            height: 4,
            decoration: BoxDecoration(
              color: textSecondary.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.bolt_rounded,
                      color: Colors.amberAccent, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '⚡ সুপার এডমিন প্রাইস কমান্ড শর্টকাট',
                        style: GoogleFonts.hindSiliguri(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: textPrimary,
                        ),
                      ),
                      Text(
                        'লাইভ মার্কেটপ্লেসে এগ্রি ও ফিশ ফার্মারদের পণ্যের দাম নিয়ন্ত্রণ',
                        style: GoogleFonts.hindSiliguri(
                          fontSize: 11.5,
                          color: textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close_rounded, color: textSecondary),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Scrollable Body
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. SCENARIO PRESETS
                  Text(
                    '১. পরিস্থিতি নির্বাচন করুন (Scenario Preset)',
                    style: GoogleFonts.hindSiliguri(
                      fontSize: 13.5,
                      fontWeight: FontWeight.bold,
                      color: textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildScenarioCard(
                          title: '📉 বাজার ধস (হ্রাস)',
                          sub: 'অতিরিক্ত সরবরাহ / দাম কমানো',
                          action: PriceCommandAction.decrease,
                          color: const Color(0xFFEF4444),
                          isDark: isDark,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildScenarioCard(
                          title: '📈 কৃষক সুরক্ষা (বৃদ্ধি)',
                          sub: 'বাজার ঊর্ধ্বগতি / দাম বাড়ানো',
                          action: PriceCommandAction.increase,
                          color: const Color(0xFF10B981),
                          isDark: isDark,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildScenarioCard(
                          title: '🎯 বেঞ্চমার্কে সিঙ্ক',
                          sub: 'বাজারের গড় রেটে সমতা',
                          action: PriceCommandAction.syncBenchmark,
                          color: const Color(0xFF3B82F6),
                          isDark: isDark,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildScenarioCard(
                          title: '🔄 মূল দামে রিসেট',
                          sub: 'কৃষকের আসল রেট ফিরিয়ে নিন',
                          action: PriceCommandAction.reset,
                          color: const Color(0xFFF59E0B),
                          isDark: isDark,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  // 2. TARGET SCOPE & REGION
                  Text(
                    '২. কাদের পণ্যে ও কোন অঞ্চলে প্রয়োগ হবে (Scope & Region)',
                    style: GoogleFonts.hindSiliguri(
                      fontSize: 13.5,
                      fontWeight: FontWeight.bold,
                      color: textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildScopeChip(
                        label: '🌐 সারা বাংলাদেশ',
                        scope: PriceCommandScope.all,
                        isDark: isDark,
                      ),
                      _buildScopeChip(
                        label: '🐟 মৎস্য চাষী (Fish Lots)',
                        scope: PriceCommandScope.fish,
                        isDark: isDark,
                      ),
                      _buildScopeChip(
                        label: '🌾 কৃষি খামারী (Agri Crops)',
                        scope: PriceCommandScope.agri,
                        isDark: isDark,
                      ),
                      _buildScopeChip(
                        label: '🏛️ বিভাগ ভিত্তিক (Division)',
                        scope: PriceCommandScope.division,
                        isDark: isDark,
                      ),
                      _buildScopeChip(
                        label: '📍 জেলা ভিত্তিক (District)',
                        scope: PriceCommandScope.district,
                        isDark: isDark,
                      ),
                    ],
                  ),

                  // Dynamic Region Selectors
                  if (_selectedScope == PriceCommandScope.division) ...[
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedDivision,
                      dropdownColor: cardBg,
                      decoration: InputDecoration(
                        labelText: 'বিভাগ নির্বাচন করুন',
                        labelStyle: GoogleFonts.hindSiliguri(color: textSecondary, fontSize: 13),
                        filled: true,
                        fillColor: cardBg,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: borderColor)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                      items: _divisions.map((d) => DropdownMenuItem(
                        value: d['value'],
                        child: Text(d['labelBn']!, style: GoogleFonts.hindSiliguri(color: textPrimary, fontWeight: FontWeight.bold)),
                      )).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => _selectedDivision = val);
                          _applyPresetReason();
                          _fetchLiveCountsAndSimulation();
                        }
                      },
                    ),
                  ] else if (_selectedScope == PriceCommandScope.district) ...[
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedDistrict,
                      dropdownColor: cardBg,
                      decoration: InputDecoration(
                        labelText: 'জেলা নির্বাচন করুন',
                        labelStyle: GoogleFonts.hindSiliguri(color: textSecondary, fontSize: 13),
                        filled: true,
                        fillColor: cardBg,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: borderColor)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                      items: _districts.map((d) => DropdownMenuItem(
                        value: d['value'],
                        child: Text(d['labelBn']!, style: GoogleFonts.hindSiliguri(color: textPrimary, fontWeight: FontWeight.bold)),
                      )).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => _selectedDistrict = val);
                          _applyPresetReason();
                          _fetchLiveCountsAndSimulation();
                        }
                      },
                    ),
                  ],

                  // 3. DELTA ADJUSTMENT
                  if (_selectedAction == PriceCommandAction.decrease ||
                      _selectedAction == PriceCommandAction.increase) ...[
                    const SizedBox(height: 18),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '৩. পরিবর্তনের পরিমাণ (Adjustment Delta)',
                          style: GoogleFonts.hindSiliguri(
                            fontSize: 13.5,
                            fontWeight: FontWeight.bold,
                            color: textPrimary,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _buildUnitToggle(
                                label: '% শতকরা',
                                unit: PriceAdjustmentUnit.percent,
                                isDark: isDark,
                              ),
                              _buildUnitToggle(
                                label: '৳ টাকা/কেজি',
                                unit: PriceAdjustmentUnit.fixedBdt,
                                isDark: isDark,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Quick Chips
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _selectedUnit == PriceAdjustmentUnit.percent
                          ? [
                              _buildDeltaChip(5, isDark),
                              _buildDeltaChip(10, isDark),
                              _buildDeltaChip(15, isDark),
                              _buildDeltaChip(20, isDark),
                              _buildDeltaChip(25, isDark),
                              _buildDeltaChip(30, isDark),
                            ]
                          : [
                              _buildDeltaChip(5, isDark),
                              _buildDeltaChip(10, isDark),
                              _buildDeltaChip(15, isDark),
                              _buildDeltaChip(20, isDark),
                              _buildDeltaChip(50, isDark),
                            ],
                    ),
                    const SizedBox(height: 8),

                    // Custom Delta Input
                    TextField(
                      controller: _customDeltaController,
                      keyboardType: TextInputType.number,
                      style: GoogleFonts.poppins(
                        color: textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: InputDecoration(
                        labelText: _selectedUnit == PriceAdjustmentUnit.percent
                            ? 'কাস্টম শতকরা হার (%)'
                            : 'কাস্টম টাকার পরিমাণ (৳)',
                        labelStyle: GoogleFonts.hindSiliguri(
                          color: textSecondary,
                          fontSize: 12,
                        ),
                        prefixIcon: Icon(
                          _selectedAction == PriceCommandAction.decrease
                              ? Icons.remove_circle_outline_rounded
                              : Icons.add_circle_outline_rounded,
                          color: _selectedAction == PriceCommandAction.decrease
                              ? Colors.redAccent
                              : Colors.green,
                          size: 20,
                        ),
                        filled: true,
                        fillColor: cardBg,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: borderColor),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                      ),
                      onChanged: (val) {
                        final parsed = double.tryParse(val);
                        if (parsed != null && parsed > 0) {
                          setState(() {
                            _deltaValue = parsed;
                            _applyPresetReason();
                          });
                          _fetchLiveCountsAndSimulation();
                        }
                      },
                    ),
                  ],

                  // 4. DURATION & EXPIRY
                  const SizedBox(height: 16),
                  Text(
                    '৪. কমান্ডের কার্যকারিতা মেয়াদ (Duration)',
                    style: GoogleFonts.hindSiliguri(
                      fontSize: 13.5,
                      fontWeight: FontWeight.bold,
                      color: textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _durations.map((d) {
                      final isSelected = _selectedDuration == d['value'];
                      return ChoiceChip(
                        selected: isSelected,
                        label: Text(
                          d['label']!,
                          style: GoogleFonts.hindSiliguri(
                            fontSize: 11.5,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            color: isSelected ? Colors.white : textPrimary,
                          ),
                        ),
                        selectedColor: const Color(0xFF2563EB),
                        backgroundColor: cardBg,
                        onSelected: (_) => setState(() => _selectedDuration = d['value']!),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 16),

                  // 5. LIVE IMPACT SIMULATION & CALCULATION BOX
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: borderColor),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.analytics_outlined,
                                    size: 18, color: Color(0xFF2563EB)),
                                const SizedBox(width: 6),
                                Text(
                                  'লাইভ সিমুলেশন ও প্রভাব বিশ্লেষণ',
                                  style: GoogleFonts.hindSiliguri(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: textPrimary,
                                  ),
                                ),
                              ],
                            ),
                            if (_isLoadingCounts)
                              const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            else
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF2563EB).withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'মোট ${_affectedProductsCount + _affectedFishLotsCount} টি লিস্টিং',
                                  style: GoogleFonts.hindSiliguri(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF2563EB),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          '🎯 লক্ষ্য: $_affectedProductsCount টি কৃষি ফসল + $_affectedFishLotsCount টি লাইভ মাছের লট',
                          style: GoogleFonts.hindSiliguri(
                            fontSize: 12,
                            color: textSecondary,
                          ),
                        ),
                        if (_simulationResult != null && _simulationResult!.totalListings > 0) ...[
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'গড় দর পরিবর্তন:',
                                style: GoogleFonts.hindSiliguri(fontSize: 12, color: textSecondary),
                              ),
                              Text(
                                '৳${_simulationResult!.averageCurrentPrice.toStringAsFixed(0)} ➔ ৳${_simulationResult!.averageNewPrice.toStringAsFixed(0)} / কেজি',
                                style: GoogleFonts.poppins(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.bold,
                                  color: textPrimary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'মোট মার্কেটপ্লেস ভ্যালু প্রভাব:',
                                style: GoogleFonts.hindSiliguri(fontSize: 12, color: textSecondary),
                              ),
                              Text(
                                '${_simulationResult!.estimatedTotalValueDelta >= 0 ? "+" : ""}৳${_simulationResult!.estimatedTotalValueDelta.toStringAsFixed(0)}',
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: _simulationResult!.estimatedTotalValueDelta < 0
                                      ? const Color(0xFFEF4444)
                                      : const Color(0xFF10B981),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),

                  // 6. CIRCUIT BREAKER WARNING & CONFIRMATION (if > 25%)
                  if (isHighDelta) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF3B1E08) : const Color(0xFFFFFBEB),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFF59E0B)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.warning_amber_rounded, color: Color(0xFFF59E0B), size: 20),
                              const SizedBox(width: 8),
                              Text(
                                '⚠️ সার্কিট ব্রেকার নিরাপত্তা অ্যালার্ট',
                                style: GoogleFonts.hindSiliguri(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFFB45309),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'আপনি ২৫% এর বেশি (${_deltaValue.toStringAsFixed(0)}%) বড় মূল্য পরিবর্তন করতে যাচ্ছেন। বাজারে অনাকাঙ্ক্ষিত অস্থিতিশীলতা এড়াতে নিচের নিশ্চিতকরণ টগল সক্রিয় করুন:',
                            style: GoogleFonts.hindSiliguri(
                              fontSize: 11.5,
                              color: isDark ? Colors.amber.shade100 : Colors.brown.shade800,
                            ),
                          ),
                          const SizedBox(height: 8),
                          SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                              'আমি সচেতনভাবে এই বড় পরিবর্তন প্রয়োগ করতে চাই',
                              style: GoogleFonts.hindSiliguri(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: textPrimary,
                              ),
                            ),
                            value: _circuitBreakerConfirmed,
                            activeThumbColor: const Color(0xFFF59E0B),
                            onChanged: (v) => setState(() => _circuitBreakerConfirmed = v),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 16),

                  // 7. REASON NOTE
                  Text(
                    '৫. এডমিন নোটিশ ও কারণ (Audit Reason)',
                    style: GoogleFonts.hindSiliguri(
                      fontSize: 13.5,
                      fontWeight: FontWeight.bold,
                      color: textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _reasonController,
                    style: GoogleFonts.hindSiliguri(
                      fontSize: 12.5,
                      color: textPrimary,
                    ),
                    maxLines: 2,
                    decoration: InputDecoration(
                      hintText: 'কারণ লিখুন (যেমন: নাটোর জেলায় আলুর বাম্পার ফলনজনিত সাময়িক দর হ্রাস)',
                      filled: true,
                      fillColor: cardBg,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: borderColor),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 8. EXECUTE BUTTON
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: (_isExecuting || (isHighDelta && !_circuitBreakerConfirmed))
                          ? null
                          : _handleExecute,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _selectedAction == PriceCommandAction.decrease
                            ? const Color(0xFFDC2626)
                            : _selectedAction == PriceCommandAction.increase
                                ? const Color(0xFF059669)
                                : const Color(0xFF2563EB),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 3,
                      ),
                      child: _isExecuting
                          ? const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                ),
                                SizedBox(width: 10),
                                Text(
                                  'এক্সিকিউট হচ্ছে...',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.bolt_rounded,
                                    color: Colors.amberAccent, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  '⚡ প্রাইস কমান্ড কার্যকর করুন (Execute Command)',
                                  style: GoogleFonts.hindSiliguri(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
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

  Widget _buildScenarioCard({
    required String title,
    required String sub,
    required PriceCommandAction action,
    required Color color,
    required bool isDark,
  }) {
    final isSelected = _selectedAction == action;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedAction = action;
          _applyPresetReason();
        });
        _fetchLiveCountsAndSimulation();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: isDark ? 0.25 : 0.12)
              : (isDark ? const Color(0xFF1E293B) : Colors.white),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
            width: isSelected ? 1.8 : 1.0,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.hindSiliguri(
                fontSize: 12.5,
                fontWeight: FontWeight.bold,
                color: isSelected ? color : (isDark ? Colors.white : Colors.black87),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              sub,
              style: GoogleFonts.hindSiliguri(
                fontSize: 10,
                color: isDark ? Colors.white60 : Colors.grey.shade600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScopeChip({
    required String label,
    required PriceCommandScope scope,
    required bool isDark,
  }) {
    final isSelected = _selectedScope == scope;
    return ChoiceChip(
      selected: isSelected,
      label: Text(
        label,
        style: GoogleFonts.hindSiliguri(
          fontSize: 11.5,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          color: isSelected ? Colors.white : (isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A)),
        ),
      ),
      selectedColor: const Color(0xFF2563EB),
      backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: isSelected
              ? const Color(0xFF2563EB)
              : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
        ),
      ),
      onSelected: (_) {
        setState(() => _selectedScope = scope);
        _applyPresetReason();
        _fetchLiveCountsAndSimulation();
      },
    );
  }

  Widget _buildUnitToggle({
    required String label,
    required PriceAdjustmentUnit unit,
    required bool isDark,
  }) {
    final isSelected = _selectedUnit == unit;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedUnit = unit;
          _deltaValue = unit == PriceAdjustmentUnit.percent ? 10 : 5;
          _customDeltaController.text = _deltaValue.toStringAsFixed(0);
          _applyPresetReason();
        });
        _fetchLiveCountsAndSimulation();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2563EB) : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: GoogleFonts.hindSiliguri(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
          ),
        ),
      ),
    );
  }

  Widget _buildDeltaChip(double val, bool isDark) {
    final isSelected = _deltaValue == val;
    final suffix = _selectedUnit == PriceAdjustmentUnit.percent ? '%' : '৳';
    return ChoiceChip(
      selected: isSelected,
      label: Text(
        '${val.toStringAsFixed(0)}$suffix',
        style: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
        ),
      ),
      selectedColor: _selectedAction == PriceCommandAction.decrease
          ? const Color(0xFFDC2626)
          : const Color(0xFF059669),
      backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: isSelected ? Colors.transparent : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
        ),
      ),
      onSelected: (_) {
        setState(() {
          _deltaValue = val;
          _customDeltaController.text = val.toStringAsFixed(0);
          _applyPresetReason();
        });
        _fetchLiveCountsAndSimulation();
      },
    );
  }
}
