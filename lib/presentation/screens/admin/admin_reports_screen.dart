import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import '../../../core/services/pdf/admin_report_service.dart';
import '../../../core/services/pdf/user_report_service.dart';
import 'package:flutter/cupertino.dart';

class AdminReportsScreen extends StatefulWidget {
  const AdminReportsScreen({super.key});

  @override
  State<AdminReportsScreen> createState() => _AdminReportsScreenState();
}

class _AdminReportsScreenState extends State<AdminReportsScreen> {
  bool _isGenerating = false;
  String _selectedRole = 'farmer';
  final TextEditingController _userIdController = TextEditingController();
  ReportPeriod _selectedPeriod = ReportPeriod.monthly;

  Future<void> _generatePlatformOverview() async {
    setState(() => _isGenerating = true);
    try {
      // In a real app, these values would be fetched from Firestore
      final pdfBytes = await AdminReportService.generatePlatformOverviewReport(
        usersCount: 1542,
        totalRevenue: 45200.50,
        activeLoans: 120,
        recentTransactions: [
          {'date': '2026-06-25', 'user': 'Arfan (Farmer)', 'amount': 1500, 'type': 'Sale', 'status': 'Completed'},
          {'date': '2026-06-26', 'user': 'Rahim (Buyer)', 'amount': 500, 'type': 'Deposit', 'status': 'Completed'},
          {'date': '2026-06-26', 'user': 'Karim (Driver)', 'amount': 250, 'type': 'Fee', 'status': 'Pending'},
        ],
      );

      if (!mounted) return;

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(title: const Text('Report Preview')),
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

  Future<void> _generateIndividualReport() async {
    if (_userIdController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a User ID'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isGenerating = true);
    try {
      final pdfBytes = await UserReportService.generateActivityReport(
        userName: 'User ${_userIdController.text}',
        userId: _userIdController.text,
        userRole: _selectedRole,
        period: _selectedPeriod,
        amount1Label: 'Total Income / Purchases',
        totalAmount1: 5000.0,
        amount2Label: 'Total Expenses / Savings',
        totalAmount2: 1200.0,
        transactions: [
          {'date': '2026-06-25', 'description': 'Sample Transaction', 'amount': 1500, 'status': 'Completed'},
        ],
      );

      if (!mounted) return;

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(title: Text('$_selectedRole Report Preview')),
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
  void dispose() {
    _userIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports & Statements'),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildReportCard(
            title: 'Platform Overview & Financial Report',
            description: 'A comprehensive summary of total users, revenue, active loans, and recent transactions.',
            icon: Icons.account_balance,
            onGenerate: _generatePlatformOverview,
            color: Colors.blue,
          ),
          const SizedBox(height: 16),
          _buildIndividualUserReportSection(),
        ],
      ),
    );
  }

  Widget _buildIndividualUserReportSection() {
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
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.person_search, color: Colors.orange, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Individual User Report', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text('Generate a detailed activity report for any specific user.', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _userIdController,
              decoration: InputDecoration(
                labelText: 'Enter User ID',
                prefixIcon: const Icon(Icons.perm_identity),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                isDense: true,
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedRole,
              decoration: InputDecoration(
                labelText: 'User Role',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                isDense: true,
              ),
              items: const [
                DropdownMenuItem(value: 'farmer', child: Text('Farmer')),
                DropdownMenuItem(value: 'buyer', child: Text('Buyer')),
                DropdownMenuItem(value: 'driver', child: Text('Driver')),
                DropdownMenuItem(value: 'company', child: Text('Company')),
              ],
              onChanged: (val) => setState(() => _selectedRole = val ?? 'farmer'),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('Today'),
                  selected: _selectedPeriod == ReportPeriod.daily,
                  onSelected: (s) => setState(() => _selectedPeriod = ReportPeriod.daily),
                ),
                ChoiceChip(
                  label: const Text('This Week'),
                  selected: _selectedPeriod == ReportPeriod.weekly,
                  onSelected: (s) => setState(() => _selectedPeriod = ReportPeriod.weekly),
                ),
                ChoiceChip(
                  label: const Text('This Month'),
                  selected: _selectedPeriod == ReportPeriod.monthly,
                  onSelected: (s) => setState(() => _selectedPeriod = ReportPeriod.monthly),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isGenerating ? null : _generateIndividualReport,
                icon: _isGenerating
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.picture_as_pdf),
                label: Text(_isGenerating ? 'Generating...' : 'Generate User Report'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
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

  Widget _buildReportCard({
    required String title,
    required String description,
    required IconData icon,
    required VoidCallback onGenerate,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.only(bottom: 16),
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
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(description, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isGenerating ? null : onGenerate,
                icon: _isGenerating
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.picture_as_pdf),
                label: Text(_isGenerating ? 'Generating...' : 'Generate Report'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
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
}
