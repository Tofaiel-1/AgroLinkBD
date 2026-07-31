import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:agrolinkbd/core/controllers/pond_controller.dart';
import 'package:agrolinkbd/core/models/pond_model.dart';

class FisheriesAnalyticsTab extends StatefulWidget {
  const FisheriesAnalyticsTab({super.key});

  @override
  State<FisheriesAnalyticsTab> createState() => _FisheriesAnalyticsTabState();
}

class _FisheriesAnalyticsTabState extends State<FisheriesAnalyticsTab> {
  late final PondController _pondController;
  PondModel? _selectedPond;

  @override
  void initState() {
    super.initState();
    _pondController = Get.isRegistered<PondController>() ? Get.find<PondController>() : Get.put(PondController());
    if (_pondController.ponds.isNotEmpty) {
      _selectedPond = _pondController.ponds.first;
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color tealColor = Color(0xFF00897B);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'বিশ্লেষণ',
          style: GoogleFonts.hindSiliguri(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: tealColor,
        elevation: 0,
        centerTitle: true,
      ),
      body: Obx(() {
        if (_pondController.ponds.isEmpty) {
          return Center(
            child: Text('কোনো পুকুর নেই। আগে পুকুর যোগ করুন।', style: GoogleFonts.hindSiliguri()),
          );
        }

        // Keep selected pond valid if lists update
        if (_selectedPond != null && !_pondController.ponds.contains(_selectedPond)) {
          _selectedPond = _pondController.ponds.first;
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTotalFarmOverview(tealColor),
              const SizedBox(height: 30),
              Text('পুকুর ভিত্তিক বিশ্লেষণ:', style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: DropdownButton<PondModel>(
                  isExpanded: true,
                  underline: const SizedBox(),
                  value: _selectedPond,
                  items: _pondController.ponds.map((p) {
                    return DropdownMenuItem(value: p, child: Text(p.name, style: GoogleFonts.hindSiliguri()));
                  }).toList(),
                  onChanged: (val) {
                    setState(() {
                      _selectedPond = val;
                    });
                  },
                ),
              ),
              const SizedBox(height: 24),
              if (_selectedPond != null) _buildProfitLossAnalysis(_selectedPond!, tealColor),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildTotalFarmOverview(Color color) {
    double totalFarmCost = _pondController.totalFarmCost;
    double totalFarmIncome = _pondController.totalFarmIncome;
    
    // Calculate total expected value across all ponds
    double totalExpectedValue = 0;
    for (var pond in _pondController.ponds) {
      double expectedWeightKg = (pond.totalFishCount * (pond.daysSinceStocked * 10)) / 1000;
      totalExpectedValue += expectedWeightKg * 200;
    }
    
    double totalProfit = (totalExpectedValue + totalFarmIncome) - totalFarmCost;
    bool isProfitable = totalProfit >= 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('সার্বিক খামার ওভারভিউ (সব পুকুর)', style: GoogleFonts.hindSiliguri(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color, color.withOpacity(0.8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(color: color.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4)),
            ],
          ),
          child: Column(
            children: [
              _buildStatRow('মোট খামার খরচ', '৳${totalFarmCost.toStringAsFixed(0)}', Colors.white, isBold: true, labelColor: Colors.white70),
              const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Divider(color: Colors.white30)),
              _buildStatRow('মোট খামার আয়', '৳${totalFarmIncome.toStringAsFixed(0)}', Colors.white, isBold: true, labelColor: Colors.white70),
              const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Divider(color: Colors.white30)),
              _buildStatRow('মোট বাজার মূল্য (আনুমানিক)', '৳${totalExpectedValue.toStringAsFixed(0)}', Colors.white, isBold: true, labelColor: Colors.white70),
              const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Divider(color: Colors.white30)),
              _buildStatRow(
                isProfitable ? 'মোট লাভ (আনুমানিক)' : 'মোট ক্ষতি (আনুমানিক)',
                '৳${totalProfit.abs().toStringAsFixed(0)}',
                Colors.white,
                isBold: true,
                labelColor: Colors.white,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProfitLossAnalysis(PondModel pond, Color color) {
    // Mock Calculation for Expected Value based on Fish Count and Days
    // Let's assume fish grows 10g per day, market price is 200 Tk/Kg
    double expectedWeightKg = (pond.totalFishCount * (pond.daysSinceStocked * 10)) / 1000;
    double expectedValue = expectedWeightKg * 200;
    double profit = (expectedValue + pond.totalIncome) - pond.totalCost;
    bool isProfitable = profit >= 0;

    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final costColor = isDark ? Colors.red.shade400 : Colors.red.shade700;
    final incomeColor = isDark ? Colors.green.shade400 : Colors.green.shade700;
    final expectedColor = isDark ? Colors.blue.shade400 : Colors.blue.shade700;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('পুকুরের লাভ-ক্ষতির বিশ্লেষণ', style: GoogleFonts.hindSiliguri(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(color: color.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4)),
            ],
          ),
          child: Column(
            children: [
              _buildStatRow('পুকুরের খরচ', '৳${pond.totalCost.toStringAsFixed(0)}', costColor),
              const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Divider()),
              _buildStatRow('পুকুরের আয়', '৳${pond.totalIncome.toStringAsFixed(0)}', incomeColor),
              const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Divider()),
              _buildStatRow('আনুমানিক বাজার মূল্য', '৳${expectedValue.toStringAsFixed(0)}', expectedColor),
              const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Divider()),
              _buildStatRow(
                isProfitable ? 'আনুমানিক লাভ' : 'আনুমানিক ক্ষতি',
                '৳${profit.abs().toStringAsFixed(0)}',
                isProfitable ? incomeColor : costColor,
                isBold: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatRow(String label, String value, Color color, {bool isBold = false, Color? labelColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.hindSiliguri(
            fontSize: isBold ? 18 : 16,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: labelColor,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: isBold ? 20 : 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
