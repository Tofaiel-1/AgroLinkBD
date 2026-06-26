import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'pdf_theme_service.dart';
import 'report_generator_utils.dart';

enum ReportPeriod { daily, weekly, monthly }

class UserReportService {
  
  /// Generates a dynamic Activity Report for any user role
  /// [userName], [userId], [userRole]
  /// [period] The period of the report (daily, weekly, monthly)
  /// [totalEarnings] / [totalSpent] dynamic based on role
  /// [transactions] Ledger of transactions for the period
  static Future<Uint8List> generateActivityReport({
    required String userName,
    required String userId,
    required String userRole,
    required ReportPeriod period,
    required double totalAmount1,
    required String amount1Label,
    required double totalAmount2,
    required String amount2Label,
    required List<Map<String, dynamic>> transactions,
  }) async {
    final pdf = pw.Document(theme: PdfThemeService.getTheme());

    final String periodLabel = period == ReportPeriod.daily 
        ? 'Daily' 
        : (period == ReportPeriod.weekly ? 'Weekly' : 'Monthly');

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (context) => ReportGeneratorUtils.buildHeader(
          title: '$periodLabel Activity Report',
          subtitle: 'Generated for $userName ($userRole)',
          dateRange: _getDateRangeText(period),
        ),
        footer: (context) => ReportGeneratorUtils.buildFooter(context),
        build: (context) {
          return [
            // User Info
            pw.Text('Account ID: $userId', style: pw.TextStyle(fontSize: 10, color: PdfThemeService.subtextColor)),
            pw.SizedBox(height: 16),

            // Summary Cards Row
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Expanded(
                  child: ReportGeneratorUtils.buildSummaryCard(
                    amount1Label, 
                    '৳ ${totalAmount1.toStringAsFixed(2)}',
                    color: PdfColor.fromInt(0xFF2E7D32), // Green
                  ),
                ),
                pw.SizedBox(width: 16),
                pw.Expanded(
                  child: ReportGeneratorUtils.buildSummaryCard(
                    amount2Label, 
                    '৳ ${totalAmount2.toStringAsFixed(2)}',
                    color: PdfColor.fromInt(0xFF1976D2), // Blue
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 32),
            
            // Section Title
            pw.Text(
              'Transaction Ledger',
              style: pw.TextStyle(
                fontSize: 14,
                fontWeight: pw.FontWeight.bold,
                color: PdfThemeService.textColor,
              ),
            ),
            pw.SizedBox(height: 12),
            
            // Transactions Table
            if (transactions.isEmpty)
              pw.Container(
                padding: const pw.EdgeInsets.all(16),
                alignment: pw.Alignment.center,
                decoration: pw.BoxDecoration(
                  color: PdfThemeService.backgroundColor,
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                ),
                child: pw.Text('No activity recorded for this period.', style: pw.TextStyle(color: PdfThemeService.subtextColor)),
              )
            else
              ReportGeneratorUtils.buildTable(
                headers: ['Date', 'Description', 'Amount', 'Status'],
                columnWidths: [2.0, 4.0, 1.5, 1.5],
                data: transactions.map((tx) {
                  return [
                    tx['date']?.toString() ?? 'N/A',
                    tx['description']?.toString() ?? 'N/A',
                    '৳ ${tx['amount']?.toString() ?? '0.00'}',
                    tx['status']?.toString() ?? 'N/A',
                  ];
                }).toList(),
              ),
              
            pw.SizedBox(height: 32),
            
            // End of Report Note
            pw.Center(
              child: pw.Text(
                '--- End of Report ---',
                style: pw.TextStyle(
                  fontSize: 10,
                  color: PdfThemeService.subtextColor,
                  fontStyle: pw.FontStyle.italic,
                ),
              ),
            ),
          ];
        },
      ),
    );

    return await pdf.save();
  }

  static String _getDateRangeText(ReportPeriod period) {
    final now = DateTime.now();
    switch (period) {
      case ReportPeriod.daily:
        return 'Today';
      case ReportPeriod.weekly:
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        return 'This Week';
      case ReportPeriod.monthly:
        return 'This Month';
    }
  }
}
