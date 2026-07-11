import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:agrolinkbd/core/models/agri_info_model.dart';

/// ফসল বিন্যাস Screen — বর্তমান ও লাভজনক ফসল বিন্যাস
/// Matches Image 4 & Image 5 style from BARC app
class CropPatternScreen extends StatefulWidget {
  final UpazilaCropData? data;
  const CropPatternScreen({super.key, this.data});

  @override
  State<CropPatternScreen> createState() => _CropPatternScreenState();
}

class _CropPatternScreenState extends State<CropPatternScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  static const Color primaryGreen = Color(0xFF2E7D32);
  static const Color headerGreen = Color(0xFF1B5E20);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

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
            Text('ফসল বিন্যাস',
                style: GoogleFonts.hindSiliguri(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            if (data != null)
              Text('${data.division} › ${data.zilla} › ${data.upazila}',
                  style: GoogleFonts.hindSiliguri(color: Colors.white70, fontSize: 11)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.save_alt, color: Colors.white),
            tooltip: 'সংরক্ষণ করুন',
            onPressed: () => Get.snackbar('সংরক্ষিত', 'তথ্য সংরক্ষণ করা হয়েছে'),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelStyle: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, fontSize: 14),
          unselectedLabelStyle: GoogleFonts.hindSiliguri(fontSize: 13),
          tabs: const [
            Tab(text: 'বর্তমান বিন্যাস'),
            Tab(text: 'লাভজনক বিন্যাস'),
          ],
        ),
      ),
      body: data == null
          ? _buildNoData()
          : TabBarView(
              controller: _tabController,
              children: [
                _buildCurrentPatternTable(data),
                _buildProfitablePatternTable(data),
              ],
            ),
    );
  }

  Widget _buildNoData() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.view_module_outlined, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'এলাকার তথ্য পাওয়া যায়নি',
            style: GoogleFonts.hindSiliguri(fontSize: 16, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  // ================================================================
  // বর্তমান ফসল বিন্যাস — Table (Image 4 style)
  // ================================================================
  Widget _buildCurrentPatternTable(UpazilaCropData data) {
    final all = data.cropPatterns;
    final current = all.where((p) => p.isCurrent).toList();
    final displayList = current.isNotEmpty ? current : all;

    return Column(
      children: [
        // Location header bar
        _buildLocationBar(data),
        // Info note
        Container(
          color: Colors.green.shade50,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              const Icon(Icons.info_outline, size: 16, color: Colors.green),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'বর্তমানে কৃষকরা এই বিন্যাস অনুসরণ করছেন',
                  style: GoogleFonts.hindSiliguri(fontSize: 12, color: Colors.green.shade800),
                ),
              ),
            ],
          ),
        ),
        // Table
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.all(12),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Table(
                  border: TableBorder.all(color: Colors.grey.shade300, width: 0.5),
                  defaultColumnWidth: const IntrinsicColumnWidth(),
                  children: [
                    // Header row
                    TableRow(
                      decoration: const BoxDecoration(color: headerGreen),
                      children: [
                        _headerCell('ফসল বিন্যাস'),
                        _headerCell('লাভ (প্রতি\nশতাংশ)'),
                        _headerCell('আয়-ব্যয় অনুপাত\n(ভি. সি.)'),
                        _headerCell('আয়-ব্যয় অনুপাত\n(টি. সি.)'),
                      ],
                    ),
                    // Data rows
                    ...displayList.asMap().entries.map((entry) {
                      final i = entry.key;
                      final p = entry.value;
                      final patternLabel = _formatPattern(p);
                      return TableRow(
                        decoration: BoxDecoration(
                          color: i.isEven ? Colors.white : Colors.green.shade50,
                        ),
                        children: [
                          _dataCell(patternLabel, bold: true),
                          _dataCell('৳${_formatNumber(p.profitIndex)}', color: primaryGreen),
                          _dataCell(p.bcRatioVig.toStringAsFixed(2)),
                          _dataCell(p.bcRatioTig.toStringAsFixed(2)),
                        ],
                      );
                    }),
                  ],
                ),
              ),
            ),
          ),
        ),
        _buildLegend(),
      ],
    );
  }

  // ================================================================
  // লাভজনক ফসল বিন্যাস — Table (Image 5 style)
  // ================================================================
  Widget _buildProfitablePatternTable(UpazilaCropData data) {
    final sorted = [...data.cropPatterns]
      ..sort((a, b) => b.profitIndex.compareTo(a.profitIndex));

    return Column(
      children: [
        _buildLocationBar(data),
        Container(
          color: Colors.orange.shade50,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              const Icon(Icons.trending_up, size: 16, color: Colors.orange),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'মুনাফার ভিত্তিতে সর্বোচ্চ লাভজনক ফসল বিন্যাস',
                  style: GoogleFonts.hindSiliguri(fontSize: 12, color: Colors.orange.shade800),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.all(12),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Table(
                  border: TableBorder.all(color: Colors.grey.shade300, width: 0.5),
                  defaultColumnWidth: const IntrinsicColumnWidth(),
                  children: [
                    // Header
                    TableRow(
                      decoration: const BoxDecoration(color: headerGreen),
                      children: [
                        _headerCell('রবি'),
                        _headerCell('খরিফ[১]'),
                        _headerCell('খরিফ[২]'),
                        _headerCell('মুনাফা *'),
                      ],
                    ),
                    // Data rows
                    ...sorted.asMap().entries.map((entry) {
                      final i = entry.key;
                      final p = entry.value;
                      return TableRow(
                        decoration: BoxDecoration(
                          color: i.isEven ? Colors.white : Colors.green.shade50,
                        ),
                        children: [
                          _dataCell(p.robi.isEmpty ? '-' : p.robi),
                          _dataCell(p.kharif1.isEmpty ? '-' : p.kharif1),
                          _dataCell(p.kharif2.isEmpty ? '-' : p.kharif2),
                          _dataCell(
                            '৳${_formatNumber(p.profitIndex)}',
                            color: _getProfitColor(p.profitIndex),
                            bold: true,
                          ),
                        ],
                      );
                    }),
                  ],
                ),
              ),
            ),
          ),
        ),
        // Profit footnote
        Container(
          padding: const EdgeInsets.all(12),
          color: Colors.grey.shade50,
          child: Text(
            '* মুনাফা = নিট আয় প্রতি শতাংশ (টাকা) | উৎস: BARC কৃষি তথ্য',
            style: GoogleFonts.hindSiliguri(fontSize: 11, color: Colors.grey.shade600),
          ),
        ),
      ],
    );
  }

  Widget _buildLocationBar(UpazilaCropData data) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      color: Colors.white,
      child: Row(
        children: [
          _locationChip(data.division),
          const Icon(Icons.chevron_right, size: 16, color: Colors.grey),
          _locationChip(data.zilla),
          const Icon(Icons.chevron_right, size: 16, color: Colors.grey),
          _locationChip(data.upazila, isActive: true),
          const Spacer(),
          Icon(Icons.filter_list, size: 18, color: primaryGreen),
        ],
      ),
    );
  }

  Widget _locationChip(String label, {bool isActive = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? primaryGreen : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: GoogleFonts.hindSiliguri(
          fontSize: 12,
          color: isActive ? Colors.white : Colors.grey.shade700,
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _headerCell(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: GoogleFonts.hindSiliguri(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _dataCell(String text, {Color? color, bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: GoogleFonts.hindSiliguri(
          fontSize: 13,
          color: color ?? Colors.black87,
          fontWeight: bold ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Container(
      padding: const EdgeInsets.all(12),
      color: Colors.grey.shade50,
      child: Wrap(
        spacing: 16,
        runSpacing: 4,
        children: [
          Text('ভি.সি. = ভ্যারিয়েবল কস্ট', style: GoogleFonts.hindSiliguri(fontSize: 11, color: Colors.grey.shade600)),
          Text('টি.সি. = টোটাল কস্ট', style: GoogleFonts.hindSiliguri(fontSize: 11, color: Colors.grey.shade600)),
        ],
      ),
    );
  }

  String _formatPattern(CropPattern p) {
    final parts = <String>[];
    if (p.robi.isNotEmpty) parts.add(p.robi);
    if (p.kharif1.isNotEmpty) parts.add(p.kharif1);
    if (p.kharif2.isNotEmpty) parts.add(p.kharif2);
    return parts.join(' - ');
  }

  String _formatNumber(int n) {
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return n.toString();
  }

  Color _getProfitColor(int profit) {
    if (profit >= 1500) return Colors.green.shade700;
    if (profit >= 800) return Colors.green.shade500;
    if (profit >= 400) return Colors.orange.shade700;
    return Colors.red.shade400;
  }
}
