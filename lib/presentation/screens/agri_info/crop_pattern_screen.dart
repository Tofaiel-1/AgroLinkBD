import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:agrolinkbd/core/models/agri_info_model.dart';
import 'package:agrolinkbd/core/providers/language_provider.dart';

/// ফসল বিন্যাস Screen — বর্তমান ও লাভজনক ফসল বিন্যাস
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
    final bool isBn = LanguageProvider.isBn(context);

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
            Text(
              isBn ? 'ফসল বিন্যাস' : 'Crop Pattern',
              style: GoogleFonts.hindSiliguri(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            if (data != null)
              Text(
                '${data.division} › ${data.zilla} › ${data.upazila}',
                style: GoogleFonts.hindSiliguri(color: Colors.white70, fontSize: 11),
              ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.save_alt, color: Colors.white),
            tooltip: isBn ? 'সংরক্ষণ করুন' : 'Save',
            onPressed: () => Get.snackbar(
              isBn ? 'সংরক্ষিত' : 'Saved',
              isBn ? 'তথ্য সংরক্ষণ করা হয়েছে' : 'Pattern data saved',
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelStyle: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, fontSize: 14),
          unselectedLabelStyle: GoogleFonts.hindSiliguri(fontSize: 13),
          tabs: [
            Tab(text: isBn ? 'বর্তমান বিন্যাস' : 'Current Pattern'),
            Tab(text: isBn ? 'লাভজনক বিন্যাস' : 'Profitable Pattern'),
          ],
        ),
      ),
      body: data == null
          ? _buildNoData(isBn)
          : TabBarView(
              controller: _tabController,
              children: [
                _buildCurrentPatternTable(data, isBn),
                _buildProfitablePatternTable(data, isBn),
              ],
            ),
    );
  }

  Widget _buildNoData(bool isBn) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.view_module_outlined, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            isBn ? 'এলাকার তথ্য পাওয়া যায়নি' : 'No region information found',
            style: GoogleFonts.hindSiliguri(fontSize: 16, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  // ================================================================
  // বর্তমান ফসল বিন্যাস — Table
  // ================================================================
  Widget _buildCurrentPatternTable(UpazilaCropData data, bool isBn) {
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
                  isBn 
                      ? 'বর্তমানে কৃষকরা এই বিন্যাস অনুসরণ করছেন'
                      : 'Patterns currently practiced by local farmers',
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
                        _headerCell(isBn ? 'ফসল বিন্যাস' : 'Crop Pattern'),
                        _headerCell(isBn ? 'লাভ (প্রতি\nশতাংশ)' : 'Profit (per\ndecimal)'),
                        _headerCell(isBn ? 'আয়-ব্যয় অনুপাত\n(ভি. সি.)' : 'B-C Ratio\n(V.C.)'),
                        _headerCell(isBn ? 'আয়-ব্যয় অনুপাত\n(টি. সি.)' : 'B-C Ratio\n(T.C.)'),
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
        _buildLegend(isBn),
      ],
    );
  }

  // ================================================================
  // লাভজনক ফসল বিন্যাস — Table
  // ================================================================
  Widget _buildProfitablePatternTable(UpazilaCropData data, bool isBn) {
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
                  isBn 
                      ? 'মুনাফার ভিত্তিতে সর্বোচ্চ লাভজনক ফসল বিন্যাস'
                      : 'Most profitable crop patterns ranked by return',
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
                        _headerCell(isBn ? 'রবি' : 'Rabi'),
                        _headerCell(isBn ? 'খরিফ[১]' : 'Kharif[1]'),
                        _headerCell(isBn ? 'খরিফ[২]' : 'Kharif[2]'),
                        _headerCell(isBn ? 'মুনাফা *' : 'Profit *'),
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
            isBn 
                ? '* মুনাফা = নিট আয় প্রতি শতাংশ (টাকা) | উৎস: BARC কৃষি তথ্য'
                : '* Profit = Net income per decimal (BDT) | Source: BARC Agri Data',
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

  Widget _buildLegend(bool isBn) {
    return Container(
      padding: const EdgeInsets.all(12),
      color: Colors.grey.shade50,
      child: Wrap(
        spacing: 16,
        runSpacing: 4,
        children: [
          Text(
            isBn ? 'ভি.সি. = ভ্যারিয়েবল কস্ট' : 'V.C. = Variable Cost',
            style: GoogleFonts.hindSiliguri(fontSize: 11, color: Colors.grey.shade600),
          ),
          Text(
            isBn ? 'টি.সি. = টোটাল কস্ট' : 'T.C. = Total Cost',
            style: GoogleFonts.hindSiliguri(fontSize: 11, color: Colors.grey.shade600),
          ),
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
