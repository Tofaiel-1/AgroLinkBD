import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
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
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                    color: widget.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.analytics, color: widget.color, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Activity Report', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text('Generate a detailed PDF ledger of your account activity.', 
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text('Select Period', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey.shade800)),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildPeriodChip('Today', ReportPeriod.daily),
                const SizedBox(width: 8),
                _buildPeriodChip('This Week', ReportPeriod.weekly),
                const SizedBox(width: 8),
                _buildPeriodChip('This Month', ReportPeriod.monthly),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isGenerating ? null : _generateReport,
                icon: _isGenerating
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.picture_as_pdf),
                label: Text(_isGenerating ? 'Generating...' : 'Generate My Report'),
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

  Widget _buildPeriodChip(String label, ReportPeriod period) {
    final isSelected = _selectedPeriod == period;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) setState(() => _selectedPeriod = period);
      },
      selectedColor: widget.color.withOpacity(0.2),
      labelStyle: TextStyle(
        color: isSelected ? widget.color : Colors.grey.shade700,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }
}
