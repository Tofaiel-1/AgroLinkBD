import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:agrolinkbd/core/models/agri_info_model.dart';

/// Fertilizer Recommendation Screen
class FertilizerRecommendationScreen extends StatefulWidget {
  final UpazilaCropData? data;
  const FertilizerRecommendationScreen({super.key, this.data});

  @override
  State<FertilizerRecommendationScreen> createState() => _FertilizerRecommendationScreenState();
}

class _FertilizerRecommendationScreenState extends State<FertilizerRecommendationScreen> {
  String? _selectedCrop;
  double _areaInBigha = 1.0;
  static const Color primaryGreen = Color(0xFF2E7D32);

  FertilizerDose? get _selectedDose => widget.data?.fertilizerDoses
      .cast<FertilizerDose?>()
      .firstWhere((d) => d?.cropNameBn == _selectedCrop, orElse: () => null);

  @override
  Widget build(BuildContext context) {
    final data = widget.data;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: primaryGreen,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('সার সুপারিশ',
                style: GoogleFonts.hindSiliguri(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            if (data != null)
              Text('${data.zilla} › ${data.upazila}',
                  style: GoogleFonts.hindSiliguri(color: Colors.white70, fontSize: 11)),
          ],
        ),
      ),
      body: data == null
          ? Center(child: Text('তথ্য নেই', style: GoogleFonts.hindSiliguri(color: Colors.black87)))
          : Column(
              children: [
                // Crop selector
                _buildCropSelector(data),
                // Area slider
                _buildAreaSlider(),
                // Fertilizer display
                Expanded(
                  child: _selectedCrop == null
                      ? _buildPrompt()
                      : _buildFertilizerDisplay(),
                ),
              ],
            ),
    );
  }

  Widget _buildCropSelector(UpazilaCropData data) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('ফসল বেছে নিন', style: GoogleFonts.hindSiliguri(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey.shade700)),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: data.fertilizerDoses.map((d) {
                final selected = _selectedCrop == d.cropNameBn;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedCrop = d.cropNameBn),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: selected ? primaryGreen : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: selected ? primaryGreen : Colors.grey.shade300),
                        boxShadow: selected ? [BoxShadow(color: primaryGreen.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 3))] : [],
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.grass, size: 16, color: selected ? Colors.white : Colors.grey.shade600),
                          const SizedBox(width: 6),
                          Text(d.cropNameBn,
                              style: GoogleFonts.hindSiliguri(
                                fontSize: 14,
                                color: selected ? Colors.white : Colors.black87,
                                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                              )),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAreaSlider() {
    return Container(
      color: Colors.white,
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Text('জমির পরিমাণ:', style: GoogleFonts.hindSiliguri(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
          const SizedBox(width: 8),
          Text('${_areaInBigha.toStringAsFixed(1)} বিঘা',
              style: GoogleFonts.hindSiliguri(fontSize: 16, fontWeight: FontWeight.bold, color: primaryGreen)),
          Expanded(
            child: Slider(
              value: _areaInBigha,
              min: 0.5,
              max: 20,
              divisions: 39,
              activeColor: primaryGreen,
              onChanged: (v) => setState(() => _areaInBigha = v),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrompt() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.science_outlined, size: 60, color: Color(0xFF558B2F)),
          const SizedBox(height: 16),
          Text('উপরে থেকে ফসল বেছে নিন',
              style: GoogleFonts.hindSiliguri(fontSize: 16, color: Colors.grey.shade600)),
          const SizedBox(height: 8),
          Text('সারের পরিমাণ ও সময়সূচি দেখুন',
              style: GoogleFonts.hindSiliguri(fontSize: 14, color: Colors.grey.shade500)),
        ],
      ),
    );
  }

  Widget _buildFertilizerDisplay() {
    final dose = _selectedDose;
    if (dose == null) {
      return Center(child: Text('এই ফসলের সার তথ্য নেই', style: GoogleFonts.hindSiliguri(color: Colors.black87)));
    }

    final fertilizers = [
      {'name': 'ইউরিয়া (Urea)', 'perHa': dose.urea, 'color': Colors.blue.shade600, 'icon': Icons.water_drop},
      {'name': 'টিএসপি (TSP)', 'perHa': dose.tsp, 'color': Colors.orange.shade600, 'icon': Icons.circle},
      {'name': 'এমওপি (MOP)', 'perHa': dose.mop, 'color': Colors.purple.shade500, 'icon': Icons.diamond},
      if (dose.gypsum != '-') {'name': 'জিপসাম', 'perHa': dose.gypsum, 'color': Colors.teal.shade500, 'icon': Icons.grain},
      if (dose.zinc != '-') {'name': 'জিংক সালফেট', 'perHa': dose.zinc, 'color': Colors.brown.shade500, 'icon': Icons.eco},
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Header card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF1B5E20), Color(0xFF4CAF50)]),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              const Icon(Icons.grass, color: Colors.white, size: 32),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_selectedCrop!,
                      style: GoogleFonts.hindSiliguri(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  Text('${_areaInBigha.toStringAsFixed(1)} বিঘা জমির জন্য সার সুপারিশ',
                      style: GoogleFonts.hindSiliguri(color: Colors.white70, fontSize: 12)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Fertilizer cards
        ...fertilizers.map((f) {
          final color = f['color'] as Color;
          final perHaStr = f['perHa'] as String;
          final perHaKg = double.tryParse(perHaStr.replaceAll(RegExp(r'[^\d.]'), '')) ?? 0;
          final totalKg = (perHaKg * 0.134 * _areaInBigha).toStringAsFixed(1);
          return Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
                    child: Icon(f['icon'] as IconData, color: color, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(f['name'] as String,
                            style: GoogleFonts.hindSiliguri(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87)),
                        const SizedBox(height: 4),
                        Text('প্রতি হেক্টরে: $perHaStr কেজি',
                            style: GoogleFonts.hindSiliguri(fontSize: 12, color: Colors.grey.shade600)),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('$totalKg কেজি',
                          style: GoogleFonts.hindSiliguri(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
                      Text('আপনার জমিতে', style: GoogleFonts.hindSiliguri(fontSize: 11, color: Colors.grey.shade500)),
                    ],
                  ),
                ],
              ),
            ),
          );
        }),

        // Remarks
        if (dose.remarks.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 4),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.amber.shade200),
            ),
            child: Row(
              children: [
                const Icon(Icons.tips_and_updates, color: Colors.amber, size: 22),
                const SizedBox(width: 10),
                Expanded(child: Text(dose.remarks, style: GoogleFonts.hindSiliguri(fontSize: 13, color: Colors.amber.shade900))),
              ],
            ),
          ),
        const SizedBox(height: 8),
        Text(
          '* সার মাটি পরীক্ষার ভিত্তিতে পরিবর্তন হতে পারে। উৎস: BARC সার সুপারিশ গাইড।',
          style: GoogleFonts.hindSiliguri(fontSize: 11, color: Colors.grey.shade500),
        ),
      ],
    );
  }
}
