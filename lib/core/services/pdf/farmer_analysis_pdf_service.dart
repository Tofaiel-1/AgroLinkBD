import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:agrolinkbd/core/controllers/farmer_analysis_controller.dart';
import 'pdf_theme_service.dart';
import 'report_generator_utils.dart';

class FarmerAnalysisPdfService {
  /// Generates and triggers interactive Print/Share preview for Farm Performance Statement
  static Future<void> generateAndShareReport({
    required BuildContext context,
    required double totalRevenue,
    required double totalExpense,
    required double netProfit,
    required double profitMargin,
    required int farmHealthScore,
    required Map<String, double> expenseBreakdown,
    required List<CropRoiItem> cropRoiList,
    required List<MarketOpportunity> marketOpportunities,
    required String selectedTimeframeName,
  }) async {
    final bytes = await _generatePdfBytes(
      totalRevenue: totalRevenue,
      totalExpense: totalExpense,
      netProfit: netProfit,
      profitMargin: profitMargin,
      farmHealthScore: farmHealthScore,
      expenseBreakdown: expenseBreakdown,
      cropRoiList: cropRoiList,
      marketOpportunities: marketOpportunities,
      selectedTimeframeName: selectedTimeframeName,
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => bytes,
      name: 'AgroLinkBD_Farm_Analysis_Statement_${DateFormat('yyyyMMdd').format(DateTime.now())}.pdf',
    );
  }

  static Future<Uint8List> _generatePdfBytes({
    required double totalRevenue,
    required double totalExpense,
    required double netProfit,
    required double profitMargin,
    required int farmHealthScore,
    required Map<String, double> expenseBreakdown,
    required List<CropRoiItem> cropRoiList,
    required List<MarketOpportunity> marketOpportunities,
    required String selectedTimeframeName,
  }) async {
    final pdf = pw.Document(theme: PdfThemeService.getTheme());
    final user = FirebaseAuth.instance.currentUser;
    final farmerName = user?.displayName ?? 'Valued Farmer Partner';
    final farmerPhone = user?.phoneNumber ?? 'N/A';

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (ctx) => ReportGeneratorUtils.buildHeader(
          title: 'Official Farm Performance & Financial Audit Statement',
          subtitle: 'Certified Agricultural & Aquaculture Analytics Statement for Bank Financing & Production Audits.',
          dateRange: selectedTimeframeName,
        ),
        footer: (ctx) => ReportGeneratorUtils.buildFooter(ctx),
        build: (ctx) {
          return [
            // Farmer Metadata Box
            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                color: PdfThemeService.backgroundColor,
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                border: pw.Border.all(color: PdfThemeService.borderColor),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Farmer / Proprietor: $farmerName', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11)),
                      pw.SizedBox(height: 2),
                      pw.Text('Contact: $farmerPhone', style: const pw.TextStyle(fontSize: 10, color: PdfThemeService.subtextColor)),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('Farm Health Rating: $farmHealthScore/100 (Optimal)', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfThemeService.primaryColor, fontSize: 11)),
                      pw.SizedBox(height: 2),
                      pw.Text('Audit Ref: AGRO-AUD-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}', style: const pw.TextStyle(fontSize: 9, color: PdfThemeService.subtextColor)),
                    ],
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 20),

            // Financial Summary KPI Row
            pw.Row(
              children: [
                pw.Expanded(
                  child: ReportGeneratorUtils.buildSummaryCard(
                    'Gross Revenue',
                    'BDT ${totalRevenue.toStringAsFixed(0)}',
                    color: const PdfColor.fromInt(0xFF2E7D32),
                  ),
                ),
                pw.SizedBox(width: 12),
                pw.Expanded(
                  child: ReportGeneratorUtils.buildSummaryCard(
                    'Operating Cost',
                    'BDT ${totalExpense.toStringAsFixed(0)}',
                    color: const PdfColor.fromInt(0xFFD32F2F),
                  ),
                ),
                pw.SizedBox(width: 12),
                pw.Expanded(
                  child: ReportGeneratorUtils.buildSummaryCard(
                    'Net Profit (Margin)',
                    'BDT ${netProfit.toStringAsFixed(0)} (${profitMargin.toStringAsFixed(1)}%)',
                    color: const PdfColor.fromInt(0xFF006A4E),
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 24),

            // Expense Breakdown Table
            pw.Text(
              'Operating Cost Distribution by Input Category',
              style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold, color: PdfThemeService.textColor),
            ),
            pw.SizedBox(height: 8),
            ReportGeneratorUtils.buildTable(
              headers: ['Input Category', 'Amount (BDT)', 'Cost Share %'],
              columnWidths: [2.5, 1.5, 1.0],
              data: expenseBreakdown.entries.map((e) {
                final pct = totalExpense > 0 ? (e.value / totalExpense * 100).toStringAsFixed(1) : '0.0';
                return [
                  e.key,
                  'BDT ${e.value.toStringAsFixed(0)}',
                  '$pct%',
                ];
              }).toList(),
            ),
            pw.SizedBox(height: 24),

            // Crop-wise Production & ROI Performance Table
            pw.Text(
              'Crop & Aquaculture Production ROI Performance Matrix',
              style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold, color: PdfThemeService.textColor),
            ),
            pw.SizedBox(height: 8),
            ReportGeneratorUtils.buildTable(
              headers: ['Commodity / Crop', 'Yield', 'Cost (BDT)', 'Revenue (BDT)', 'ROI %'],
              columnWidths: [2.0, 1.2, 1.2, 1.2, 1.0],
              data: cropRoiList.map((item) {
                return [
                  item.cropName,
                  '${item.yieldAmount.toStringAsFixed(0)} ${item.unit}',
                  'BDT ${item.cost.toStringAsFixed(0)}',
                  'BDT ${item.revenue.toStringAsFixed(0)}',
                  '${item.roiPct.toStringAsFixed(1)}%',
                ];
              }).toList(),
            ),
            pw.SizedBox(height: 24),

            // Market Price Intelligence Forecast
            pw.Text(
              'Market Intelligence & Wholesale Selling Opportunities',
              style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold, color: PdfThemeService.textColor),
            ),
            pw.SizedBox(height: 8),
            ReportGeneratorUtils.buildTable(
              headers: ['Commodity', 'Wholesale Market', 'Current Rate', '7-Day Forecast', 'AI Advisory'],
              columnWidths: [1.8, 1.8, 1.2, 1.2, 2.0],
              data: marketOpportunities.map((m) {
                return [
                  m.crop,
                  m.market,
                  'BDT ${m.currentPrice.toStringAsFixed(0)}',
                  'BDT ${m.projectedPrice7Days.toStringAsFixed(0)}',
                  m.recommendation,
                ];
              }).toList(),
            ),
            pw.SizedBox(height: 32),

            // Official Certification & Verification Signatures
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Container(width: 140, height: 1, color: PdfThemeService.textColor),
                    pw.SizedBox(height: 4),
                    pw.Text('Farmer / Farm Manager Signature', style: const pw.TextStyle(fontSize: 9, color: PdfThemeService.subtextColor)),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Container(width: 160, height: 1, color: PdfThemeService.textColor),
                    pw.SizedBox(height: 4),
                    pw.Text('AgroLinkBD Certified System Verification', style: const pw.TextStyle(fontSize: 9, color: PdfThemeService.subtextColor)),
                  ],
                ),
              ],
            ),
          ];
        },
      ),
    );

    return pdf.save();
  }
}
