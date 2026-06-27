import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'pdf_theme_service.dart';
import 'report_generator_utils.dart';

enum ReportPeriod { daily, weekly, monthly }

class UserReportService {
  static DateTime _getStartDate(ReportPeriod period) {
    final now = DateTime.now();
    switch (period) {
      case ReportPeriod.daily:
        return DateTime(now.year, now.month, now.day);
      case ReportPeriod.weekly:
        // Use exactly last 7 days to match user expectations
        return now.subtract(const Duration(days: 7));
      case ReportPeriod.monthly:
        // Use exactly last 30 days
        return now.subtract(const Duration(days: 30));
    }
  }

  // ---------------------------------------------------------------------------
  // INDIVIDUAL USER REPORT — Fetches all real data from Firestore
  // ---------------------------------------------------------------------------
  static Future<Uint8List> fetchAndGenerateUserReport({
    required String userId,
    required String userName,
    required String userRole,
    required ReportPeriod period,
  }) async {
    final startDate = _getStartDate(period);

    String amount1Label = 'Total Income';
    String amount2Label = 'Total Expense';
    if (userRole == 'buyer') {
      amount1Label = 'Total Purchases';
      amount2Label = 'Withdrawals';
    } else if (userRole == 'company') {
      amount1Label = 'Total Procurement';
      amount2Label = 'Operating Cost';
    } else if (userRole == 'driver') {
      amount1Label = 'Total Earnings';
      amount2Label = 'Withdrawals';
    } else if (userRole == 'service_provider') {
      amount1Label = 'Service Revenue';
      amount2Label = 'Withdrawals';
    }

    double totalAmount1 = 0;
    double totalAmount2 = 0;
    int totalLogins = 0;
    int totalLogouts = 0;
    int totalSessionSeconds = 0;
    List<Map<String, dynamic>> transactionList = [];

    // helper to extract DateTime from dynamic Firestore value
    DateTime? _parseDate(dynamic ts) {
      if (ts is Timestamp) return ts.toDate();
      if (ts is String) return DateTime.tryParse(ts);
      return null;
    }

    String _fmt(DateTime? d) =>
        d != null ? '${d.day}/${d.month}/${d.year}' : 'N/A';

      // ── 1. Transactions (General Wallet) ──────────────────────────────────
      try {
        final txSnap = await FirebaseFirestore.instance
            .collection('transactions')
            .where('userId', isEqualTo: userId)
            .where('createdAt', isGreaterThanOrEqualTo: startDate.toIso8601String())
            .get();

        for (var doc in txSnap.docs) {
          final d = doc.data();
          final amount = (d['amount'] as num?)?.toDouble() ?? 0.0;
          final date = _parseDate(d['createdAt']);
          if (date == null || date.isBefore(startDate)) continue;
          
          final type = d['type'] as String?;
          if (type == 'credit') totalAmount1 += amount;
          if (type == 'debit') totalAmount2 += amount;
          
          String desc = d['title'] ?? d['description'] ?? 'Transaction';
          if (desc.length > 25) desc = '${desc.substring(0, 22)}...';

          transactionList.add({
            'date': _fmt(date),
            'description': desc,
            'amount': amount,
            'status': d['status'] ?? 'completed',
            'rawDate': date,
          });
        }
      } catch (e) {
        print('Error fetching transactions: $e');
      }

      // ── 2. Deposit Requests ────────────────────────────────────────────────
      try {
        final depSnap = await FirebaseFirestore.instance
            .collection('deposit_requests')
            .where('userId', isEqualTo: userId)
            .get();

        for (var doc in depSnap.docs) {
          final d = doc.data();
          final date = _parseDate(d['createdAt']);
          if (date == null || date.isBefore(startDate)) continue;
          final amount = (d['amount'] as num?)?.toDouble() ?? 0.0;
          final status = d['status'] as String? ?? 'pending';
          if (status == 'approved') totalAmount1 += amount;
          transactionList.add({
            'date': _fmt(date),
            'description': 'Deposit',
            'amount': amount,
            'status': status,
            'rawDate': date,
          });
        }
      } catch (e) {
        print('Error fetching deposits: $e');
      }

      // ── 3. Withdraw Requests ───────────────────────────────────────────────
      try {
        final wdSnap = await FirebaseFirestore.instance
            .collection('withdraw_requests')
            .where('userId', isEqualTo: userId)
            .get();

        for (var doc in wdSnap.docs) {
          final d = doc.data();
          final date = _parseDate(d['createdAt']);
          if (date == null || date.isBefore(startDate)) continue;
          final amount = (d['amount'] as num?)?.toDouble() ?? 0.0;
          final status = d['status'] as String? ?? 'pending';
          if (status == 'approved') totalAmount2 += amount;
          transactionList.add({
            'date': _fmt(date),
            'description': 'Withdrawal',
            'amount': amount,
            'status': status,
            'rawDate': date,
          });
        }
      } catch (e) {
        print('Error fetching withdrawals: $e');
      }

      // ── 4. Transfer Requests (sender & receiver) ───────────────────────────
      try {
        // Sent transfers
        final trSnapSender = await FirebaseFirestore.instance
            .collection('transfer_requests')
            .where('senderId', isEqualTo: userId)
            .get();

        for (var doc in trSnapSender.docs) {
          final d = doc.data();
          final date = _parseDate(d['createdAt']);
          if (date == null || date.isBefore(startDate)) continue;
          final amount = (d['amount'] as num?)?.toDouble() ?? 0.0;
          final status = d['status'] as String? ?? 'pending';
          if (status == 'approved') totalAmount2 += amount;
          
          String receiver = d['receiverId'] ?? 'Unknown';
          if (receiver.length > 6) receiver = '...${receiver.substring(receiver.length - 4)}';
          
          transactionList.add({
            'date': _fmt(date),
            'description': 'Sent Transfer to $receiver',
            'amount': amount,
            'status': status,
            'rawDate': date,
          });
        }
      } catch (e) {
        print('Error fetching sent transfers: $e');
      }

      try {
        // Received transfers
        final trSnapReceiver = await FirebaseFirestore.instance
            .collection('transfer_requests')
            .where('receiverId', isEqualTo: userId)
            .get();

        for (var doc in trSnapReceiver.docs) {
          final d = doc.data();
          final date = _parseDate(d['createdAt']);
          if (date == null || date.isBefore(startDate)) continue;
          final amount = (d['amount'] as num?)?.toDouble() ?? 0.0;
          final status = d['status'] as String? ?? 'pending';
          
          if (status == 'approved' || status == 'completed') {
             totalAmount1 += amount;
          }
          
          String sender = d['senderId'] ?? 'Unknown';
          if (sender.length > 6) sender = '...${sender.substring(sender.length - 4)}';

          transactionList.add({
            'date': _fmt(date),
            'description': 'Received Transfer from $sender',
            'amount': amount,
            'status': status,
            'rawDate': date,
          });
        }
      } catch (e) {
        print('Error fetching received transfers: $e');
      }

      // ── 5. Refund Requests ────────────────────────────────────────────────
      try {
        final refSnap = await FirebaseFirestore.instance
            .collection('refund_requests')
            .where('userId', isEqualTo: userId)
            .get();

        for (var doc in refSnap.docs) {
          final d = doc.data();
          final date = _parseDate(d['createdAt']);
          if (date == null || date.isBefore(startDate)) continue;
          final amount = (d['amount'] as num?)?.toDouble() ?? 0.0;
          final status = d['status'] as String? ?? 'pending';
          if (status == 'approved') totalAmount1 += amount;
          transactionList.add({
            'date': _fmt(date),
            'description': 'Refund',
            'amount': amount,
            'status': status,
            'rawDate': date,
          });
        }
      } catch (e) {
        print('Error fetching refunds: $e');
      }

      // ── 6. Audit Logs (Login / Logout) ────────────────────────────────────
      try {
        final auditSnap = await FirebaseFirestore.instance
            .collection('user_audit_logs')
            .where('userId', isEqualTo: userId)
            .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
            .get();

        for (var doc in auditSnap.docs) {
          final d = doc.data();
          final action = d['action'] as String? ?? '';
          if (action == 'login') totalLogins++;
          if (action == 'logout') totalLogouts++;
          totalSessionSeconds += (d['sessionDuration'] as int? ?? 0);
        }
      } catch (_) {
        // audit logs might not exist yet — graceful ignore
      }

      transactionList.sort(
        (a, b) =>
            (b['rawDate'] as DateTime).compareTo(a['rawDate'] as DateTime),
      );

    return generateActivityReport(
      userName: userName,
      userId: userId,
      userRole: userRole,
      period: period,
      totalAmount1: totalAmount1,
      amount1Label: amount1Label,
      totalAmount2: totalAmount2,
      amount2Label: amount2Label,
      transactions: transactionList,
      totalLogins: totalLogins,
      totalLogouts: totalLogouts,
      totalSessionSeconds: totalSessionSeconds,
    );
  }

  // ---------------------------------------------------------------------------
  // ROLE AGGREGATE REPORT — all users of a given role, sum up cash flow
  // ---------------------------------------------------------------------------
  static Future<Uint8List> fetchAndGenerateRoleReport({
    required String userRole,
    required ReportPeriod period,
  }) async {
    final startDate = _getStartDate(period);
    double totalAmount1 = 0; // total volume
    double totalAmount2 = 0; // platform commission
    List<Map<String, dynamic>> transactionList = [];

    DateTime? _parseDate(dynamic ts) {
      if (ts is Timestamp) return ts.toDate();
      if (ts is String) return DateTime.tryParse(ts);
      return null;
    }

    String _fmt(DateTime? d) =>
        d != null ? '${d.day}/${d.month}/${d.year}' : 'N/A';

    try {
      final usersSnap = await FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: userRole)
          .get();
      final userIds = usersSnap.docs.map((e) => e.id).toSet();

      final txSnap = await FirebaseFirestore.instance
          .collection('transactions')
          .where('createdAt', isGreaterThanOrEqualTo: startDate.toIso8601String())
          .get();

      for (var doc in txSnap.docs) {
        final d = doc.data();
        final payerId = d['payerId'] as String?;
        final payeeId = d['payeeId'] as String?;
        if (!(userIds.contains(payerId) || userIds.contains(payeeId))) continue;
        final amount = (d['amount'] as num?)?.toDouble() ?? 0.0;
        final commission = (d['commissionAmount'] as num?)?.toDouble() ?? 0.0;
        totalAmount1 += amount;
        totalAmount2 += commission;
        final date = _parseDate(d['createdAt']);
        transactionList.add({
          'date': _fmt(date),
          'description': d['description'] ?? 'Transaction',
          'amount': amount,
          'status': d['status'] ?? 'N/A',
          'rawDate': date ?? DateTime(2000),
        });
      }

      transactionList.sort(
        (a, b) =>
            (b['rawDate'] as DateTime).compareTo(a['rawDate'] as DateTime),
      );
      if (transactionList.length > 50) {
        transactionList = transactionList.sublist(0, 50);
      }
    } catch (e) {
      print('Error fetching role report: $e');
    }

    return generateActivityReport(
      userName: 'All ${userRole[0].toUpperCase()}${userRole.substring(1)}s',
      userId: 'ROLE_AGGREGATE',
      userRole: userRole,
      period: period,
      totalAmount1: totalAmount1,
      amount1Label: 'Total Volume',
      totalAmount2: totalAmount2,
      amount2Label: 'Platform Commission',
      transactions: transactionList,
    );
  }

  // ---------------------------------------------------------------------------
  // PDF GENERATION — builds actual PDF from data
  // ---------------------------------------------------------------------------
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
    int totalLogins = 0,
    int totalLogouts = 0,
    int totalSessionSeconds = 0,
  }) async {
    final pdf = pw.Document(theme: PdfThemeService.getTheme());

    final String periodLabel = period == ReportPeriod.daily
        ? 'Daily'
        : (period == ReportPeriod.weekly ? 'Weekly' : 'Monthly');

    final String sessionText = totalSessionSeconds < 60
        ? '${totalSessionSeconds}s'
        : (totalSessionSeconds < 3600
            ? '${totalSessionSeconds ~/ 60}m ${totalSessionSeconds % 60}s'
            : '${totalSessionSeconds ~/ 3600}h ${(totalSessionSeconds % 3600) ~/ 60}m');

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
            pw.Text('Account ID: $userId',
                style: pw.TextStyle(
                    fontSize: 10, color: PdfThemeService.subtextColor)),
            pw.SizedBox(height: 16),

            // ── Summary Cards ───────────────────────────────────────────────
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Expanded(
                  child: ReportGeneratorUtils.buildSummaryCard(
                    amount1Label,
                    '৳ ${totalAmount1.toStringAsFixed(2)}',
                    color: PdfColor.fromInt(0xFF2E7D32),
                  ),
                ),
                pw.SizedBox(width: 12),
                pw.Expanded(
                  child: ReportGeneratorUtils.buildSummaryCard(
                    amount2Label,
                    '৳ ${totalAmount2.toStringAsFixed(2)}',
                    color: PdfColor.fromInt(0xFF1976D2),
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 16),

            // ── Session / Login Summary (if audit data available) ──────────
            if (totalLogins > 0 || totalLogouts > 0) ...[
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Expanded(
                    child: ReportGeneratorUtils.buildSummaryCard(
                      'Total Logins',
                      '$totalLogins sessions',
                      color: PdfColor.fromInt(0xFF6A1B9A),
                    ),
                  ),
                  pw.SizedBox(width: 12),
                  pw.Expanded(
                    child: ReportGeneratorUtils.buildSummaryCard(
                      'Total Session Time',
                      totalLogins == 0 ? 'N/A' : sessionText,
                      color: PdfColor.fromInt(0xFF00838F),
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 16),
            ],

            // ── Transaction Ledger ─────────────────────────────────────────
            pw.Text('Transaction Ledger',
                style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfThemeService.textColor)),
            pw.SizedBox(height: 12),

            if (transactions.isEmpty)
              pw.Container(
                padding: const pw.EdgeInsets.all(16),
                alignment: pw.Alignment.center,
                decoration: pw.BoxDecoration(
                  color: PdfThemeService.backgroundColor,
                  borderRadius:
                      const pw.BorderRadius.all(pw.Radius.circular(8)),
                ),
                child: pw.Text(
                    'No activity recorded for this period.',
                    style: pw.TextStyle(
                        color: PdfThemeService.subtextColor)),
              )
            else
              ReportGeneratorUtils.buildTable(
                headers: ['Date', 'Description', 'Amount (৳)', 'Status'],
                columnWidths: [2.0, 4.0, 1.5, 1.5],
                data: transactions.map((tx) {
                  final amt = tx['amount'];
                  final amtStr = amt is num
                      ? amt.toStringAsFixed(2)
                      : amt?.toString() ?? '0.00';
                  return [
                    tx['date']?.toString() ?? 'N/A',
                    tx['description']?.toString() ?? 'N/A',
                    amtStr,
                    tx['status']?.toString() ?? 'N/A',
                  ];
                }).toList(),
              ),

            pw.SizedBox(height: 32),
            pw.Center(
              child: pw.Text(
                '--- End of Report ---',
                style: pw.TextStyle(
                    fontSize: 10,
                    color: PdfThemeService.subtextColor,
                    fontStyle: pw.FontStyle.italic),
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
        return 'Today — ${now.day}/${now.month}/${now.year}';
      case ReportPeriod.weekly:
        final start = now.subtract(const Duration(days: 7));
        return '${start.day}/${start.month}/${start.year} – ${now.day}/${now.month}/${now.year}';
      case ReportPeriod.monthly:
        final start = now.subtract(const Duration(days: 30));
        return '${start.day}/${start.month}/${start.year} – ${now.day}/${now.month}/${now.year}';
    }
  }
}
