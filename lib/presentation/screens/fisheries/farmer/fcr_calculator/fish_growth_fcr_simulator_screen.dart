import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:agrolinkbd/core/services/fish_fcr_calculator_service.dart';

class FishGrowthFcrSimulatorScreen extends StatefulWidget {
  const FishGrowthFcrSimulatorScreen({super.key});

  @override
  State<FishGrowthFcrSimulatorScreen> createState() => _FishGrowthFcrSimulatorScreenState();
}

class _FishGrowthFcrSimulatorScreenState extends State<FishGrowthFcrSimulatorScreen> {
  final _fishCountController = TextEditingController(text: '2000');
  final _survivalRateController = TextEditingController(text: '92');
  final _initialWeightController = TextEditingController(text: '25'); // gram
  final _currentWeightController = TextEditingController(text: '1400'); // gram
  final _totalFeedController = TextEditingController(text: '3200'); // kg
  final _feedPriceController = TextEditingController(text: '68'); // Tk/kg
  final _marketPriceController = TextEditingController(text: '320'); // Tk/kg
  final _otherExpensesController = TextEditingController(text: '35000'); // Medicine + lease

  FishFcrSimulationResult? _result;

  @override
  void initState() {
    super.initState();
    _runSimulation();
  }

  @override
  void dispose() {
    _fishCountController.dispose();
    _survivalRateController.dispose();
    _initialWeightController.dispose();
    _currentWeightController.dispose();
    _totalFeedController.dispose();
    _feedPriceController.dispose();
    _marketPriceController.dispose();
    _otherExpensesController.dispose();
    super.dispose();
  }

  void _runSimulation() {
    final fishCount = int.tryParse(_fishCountController.text) ?? 2000;
    final survivalRate = double.tryParse(_survivalRateController.text) ?? 90.0;
    final initWeight = double.tryParse(_initialWeightController.text) ?? 20.0;
    final currWeight = double.tryParse(_currentWeightController.text) ?? 1200.0;
    final totalFeed = double.tryParse(_totalFeedController.text) ?? 3000.0;
    final feedPrice = double.tryParse(_feedPriceController.text) ?? 68.0;
    final marketPrice = double.tryParse(_marketPriceController.text) ?? 300.0;
    final otherExp = double.tryParse(_otherExpensesController.text) ?? 30000.0;

    setState(() {
      _result = FishFcrCalculatorService.calculateFcr(
        totalFishCount: fishCount,
        survivalRatePercent: survivalRate,
        initialAvgWeightGram: initWeight,
        currentAvgWeightGram: currWeight,
        totalFeedGivenKg: totalFeed,
        feedPricePerKg: feedPrice,
        expectedMarketPricePerKg: marketPrice,
        otherExpenses: otherExp,
      );
    });
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
          'FCR ও মুনাফা সিমুলেটর',
          style: GoogleFonts.hindSiliguri(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.orange.shade700,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner Explanation
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.orange.shade700, Colors.deepOrange.shade600],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calculate, size: 40, color: Colors.white),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'FCR (খাদ্য রূপান্তর হার) ও সর্বোচ্চ মুনাফা',
                          style: GoogleFonts.hindSiliguri(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '১ কেজি মাছ উৎপাদনে কত কেজি খাবার লাগছে এবং কোন ওজনে বিক্রি করলে সর্বোচ্চ লাভ হবে তা হিসাব করুন।',
                          style: GoogleFonts.hindSiliguri(fontSize: 12, color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Calculation Results Card (If ready)
            if (_result != null) ...[
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.orange.shade300, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.orange.withOpacity(0.12),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'আপনার খামারের FCR স্কোর:',
                          style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: _result!.fcr <= 1.5 ? Colors.green.shade50 : Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _result!.fcr <= 1.5 ? Colors.green : Colors.orange,
                            ),
                          ),
                          child: Text(
                            'FCR: ${_result!.fcr}',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: _result!.fcr <= 1.5 ? Colors.green.shade800 : Colors.orange.shade900,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _result!.fcrRating,
                      style: GoogleFonts.hindSiliguri(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: _result!.fcr <= 1.5 ? Colors.green.shade700 : Colors.orange.shade800,
                      ),
                    ),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildResultStat('মোট মাছের ওজন', '${_result!.totalBiomassKg} কেজি'),
                        _buildResultStat('প্রতি কেজি ফিড খরচ', '৳${_result!.feedCostPerKgFish}'),
                        _buildResultStat('মোট ফিড ব্যয়', '৳${_result!.totalFeedCost}'),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.green.shade300),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'আনুমানিক নিট মুনাফা (Net Profit)',
                                style: GoogleFonts.hindSiliguri(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.green.shade900,
                                ),
                              ),
                              Text(
                                'মোট বিক্রয়মূল্য: ৳${_result!.estimatedGrossRevenue}',
                                style: GoogleFonts.hindSiliguri(fontSize: 11, color: Colors.green.shade700),
                              ),
                            ],
                          ),
                          Text(
                            '+৳${_result!.estimatedNetProfit}',
                            style: GoogleFonts.poppins(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade800,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.lightbulb, color: Colors.blue, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _result!.harvestAdvice,
                              style: GoogleFonts.hindSiliguri(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.blue.shade900,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 24),
            Text(
              'খামারের ডেটা ইনপুট দিন',
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
                  child: _buildInputField('মোট ছাড়া পোনা (সংখ্যা)', _fishCountController),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildInputField('বেঁচে থাকার হার (%)', _survivalRateController),
                ),
              ],
            ),

            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildInputField('পোনা ছাড়ার গড় ওজন (গ্রাম)', _initialWeightController),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildInputField('বর্তমান গড় ওজন (গ্রাম)', _currentWeightController),
                ),
              ],
            ),

            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildInputField('মোট খাওয়ানো খাবার (কেজি)', _totalFeedController),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildInputField('ফিডের দর (৳/কেজি)', _feedPriceController),
                ),
              ],
            ),

            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildInputField('প্রত্যাশিত বাজারদর (৳/কেজি)', _marketPriceController),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildInputField('অন্যান্য খরচ (পোনা, বিদ্যুৎ, লিজ)', _otherExpensesController),
                ),
              ],
            ),

            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _runSimulation,
                icon: const Icon(Icons.analytics, color: Colors.white),
                label: Text(
                  'পুনরায় হিসাব করুন (Recalculate)',
                  style: GoogleFonts.hindSiliguri(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange.shade700,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildResultStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.hindSiliguri(fontSize: 11, color: Colors.grey.shade600)),
        Text(value, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildInputField(String label, TextEditingController controller) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.hindSiliguri(fontSize: 12, fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          onChanged: (_) => _runSimulation(),
          style: GoogleFonts.poppins(fontSize: 14),
          decoration: InputDecoration(
            filled: true,
            fillColor: Theme.of(context).cardColor,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: isDark ? Colors.white24 : Colors.grey.shade300),
            ),
          ),
        ),
      ],
    );
  }
}
