import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'pdf_theme_service.dart';
import 'report_generator_utils.dart';

class AdminReportService {
  
  /// Generates the Platform Overview Report
  /// [usersCount] total registered users
  /// [totalRevenue] total revenue from platform commissions
  /// [activeLoans] number of active microfinance loans
  /// [recentTransactions] list of maps containing 'date', 'user', 'amount', 'type', 'status'
  static Future<Uint8List> generatePlatformOverviewReport({
    required int usersCount,
    required double totalRevenue,
    required int activeLoans,
    required List<Map<String, dynamic>> recentTransactions,
  }) async {
    final pdf = pw.Document(theme: PdfThemeService.getTheme());

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (context) => ReportGeneratorUtils.buildHeader(
          title: 'Platform Overview & Financial Report',
          subtitle: 'A comprehensive summary of AgroLinkBD platform statistics.',
          dateRange: 'All Time (Up to Current Date)',
        ),
        footer: (context) => ReportGeneratorUtils.buildFooter(context),
        build: (context) {
          return [
            // Summary Cards Row
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Expanded(
                  child: ReportGeneratorUtils.buildSummaryCard(
                    'Total Users', 
                    usersCount.toString(),
                    color: PdfColor.fromInt(0xFF1976D2), // Blue
                  ),
                ),
                pw.SizedBox(width: 16),
                pw.Expanded(
                  child: ReportGeneratorUtils.buildSummaryCard(
                    'Total Platform Revenue', 
                    '৳ ${totalRevenue.toStringAsFixed(2)}',
                    color: PdfColor.fromInt(0xFF2E7D32), // Green
                  ),
                ),
                pw.SizedBox(width: 16),
                pw.Expanded(
                  child: ReportGeneratorUtils.buildSummaryCard(
                    'Active Loans', 
                    activeLoans.toString(),
                    color: PdfColor.fromInt(0xFFF57C00), // Orange
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 32),
            
            // Section Title
            pw.Text(
              'Recent Transactions Ledger',
              style: pw.TextStyle(
                fontSize: 14,
                fontWeight: pw.FontWeight.bold,
                color: PdfThemeService.textColor,
              ),
            ),
            pw.SizedBox(height: 12),
            
            // Transactions Table
            if (recentTransactions.isEmpty)
              pw.Container(
                padding: const pw.EdgeInsets.all(16),
                alignment: pw.Alignment.center,
                decoration: pw.BoxDecoration(
                  color: PdfThemeService.backgroundColor,
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                ),
                child: pw.Text('No transactions available for this period.', style: pw.TextStyle(color: PdfThemeService.subtextColor)),
              )
            else
              ReportGeneratorUtils.buildTable(
                headers: ['Date', 'User', 'Amount', 'Type', 'Status'],
                columnWidths: [1.5, 2.0, 1.2, 1.2, 1.0],
                data: recentTransactions.map((tx) {
                  return [
                    tx['date']?.toString() ?? 'N/A',
                    tx['user']?.toString() ?? 'Unknown',
                    '৳ ${tx['amount']?.toString() ?? '0.00'}',
                    tx['type']?.toString() ?? 'N/A',
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
}
