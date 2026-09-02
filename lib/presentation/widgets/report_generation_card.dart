import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:agrolinkbd/core/providers/language_provider.dart';
import '../../core/services/pdf/user_report_service.dart';

class ReportGenerationCard extends StatefulWidget {
  final String userName;
  final String userId;
  final String userRole;
  final String amount1Label;
  final String amount2Label;
  final Color color;

  const ReportGenerationCard({
    super.key,
    required this.userName,
    required this.userId,
    required this.userRole,
    required this.amount1Label,
    required this.amount2Label,
    this.color = Colors.green,
  });

  @override
  State<ReportGenerationCard> createState() => _ReportGenerationCardState();
}

class _ReportGenerationCardState extends State<ReportGenerationCard> {
  ReportPeriod _selectedPeriod = ReportPeriod.daily;
  bool _isGenerating = false;

  Future<void> _generateReport() async {
    setState(() => _isGenerating = true);
    try {
      final pdfBytes = await UserReportService.fetchAndGenerateUserReport(
        userName: widget.userName,
        userId: widget.userId,
        userRole: widget.userRole,
        period: _selectedPeriod,
      );

      if (!mounted) return;

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(title: Text('${widget.userRole.toUpperCase()} Report Preview')),
            body: PdfPreview(
              build: (format) => pdfBytes,
              canChangeOrientation: false,
              canChangePageFormat: false,
              allowPrinting: true,
              allowSharing: true,
            ),
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error generating report: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isGenerating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bool isBn = LanguageProvider.isBn(context);

    return Card(
      elevation: 2,
      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: widget.color.withValues(alpha: isDark ? 0.2 : 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.analytics, color: widget.color, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isBn ? 'অ্যাক্টিভিটি রিপোর্ট' : 'Activity Report',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isBn 
                            ? 'আপনার একাউন্টের লেনদেন ও কার্যক্রমের বিস্তারিত পিডিএফ রিপোর্ট তৈরি করুন।'
                            : 'Generate a detailed PDF ledger of your account activity.', 
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              isBn ? 'সময়কাল নির্বাচন করুন' : 'Select Period',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.grey.shade300 : Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildPeriodChip(isBn ? 'আজ' : 'Today', ReportPeriod.daily, isDark),
                const SizedBox(width: 8),
                _buildPeriodChip(isBn ? 'এই সপ্তাহ' : 'This Week', ReportPeriod.weekly, isDark),
                const SizedBox(width: 8),
                _buildPeriodChip(isBn ? 'এই মাস' : 'This Month', ReportPeriod.monthly, isDark),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isGenerating ? null : _generateReport,
                icon: _isGenerating
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.picture_as_pdf),
                label: Text(_isGenerating ? (isBn ? 'তৈরি হচ্ছে...' : 'Generating...') : (isBn ? 'পিডিএফ রিপোর্ট তৈরি করুন' : 'Generate My Report')),
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.color,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodChip(String label, ReportPeriod period, bool isDark) {
    final isSelected = _selectedPeriod == period;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) setState(() => _selectedPeriod = period);
      },
      selectedColor: widget.color.withValues(alpha: isDark ? 0.3 : 0.2),
      labelStyle: TextStyle(
        color: isSelected ? widget.color : (isDark ? Colors.grey.shade300 : Colors.grey.shade700),
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }
}
