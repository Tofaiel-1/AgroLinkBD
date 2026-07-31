import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../core/models/enhanced_transaction_model.dart';
import '../../core/models/payment_flow_model.dart';
import '../../core/theme/app_theme.dart';

// ============================================================================
// PAYMENT FLOW TRACKING SCREEN
// ============================================================================

class PaymentFlowTrackingScreen extends ConsumerWidget {
  final PaymentFlow paymentFlow;

  const PaymentFlowTrackingScreen({
    required this.paymentFlow,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Status'),
        elevation: 0,
        backgroundColor: AppColors.primary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Flow Status Card
            _buildFlowStatusCard(),
            const SizedBox(height: 24),

            // Progress Indicator
            _buildProgressIndicator(),
            const SizedBox(height: 24),

            // Amount Breakdown
            _buildAmountBreakdown(),
            const SizedBox(height: 24),

            // Payment Parties
            _buildPaymentParties(),
            const SizedBox(height: 24),

            // Timeline
            _buildTimeline(),
            const SizedBox(height: 24),

            // Action Buttons
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildFlowStatusCard() {
    final statusColor = _getStatusColor();

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [
              statusColor.withOpacity(0.1),
              statusColor.withOpacity(0.05)
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getStatusIcon(),
                    color: statusColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        paymentFlow.typeText,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        paymentFlow.statusText,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildInfoChip('Total Amount', paymentFlow.formattedAmount),
                _buildInfoChip('Commission',
                    'Tk ${paymentFlow.totalCommission.toStringAsFixed(2)}'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressIndicator() {
    final progress = paymentFlow.allPartiesPaid
        ? 1.0
        : paymentFlow.completedParties / paymentFlow.totalParties;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Payment Progress',
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(
              progress == 1.0 ? Colors.green : AppColors.primary,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          paymentFlow.progressText,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildAmountBreakdown() {
    return Card(
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Amount Breakdown',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            ...paymentFlow.splits.map((split) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          split.reasonText,
                          style: GoogleFonts.poppins(fontSize: 13),
                        ),
                        Text(
                          split.recipientName ?? 'Recipient',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          split.formattedAmount,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          split.formattedPercentage,
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentParties() {
    return Card(
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Payment Parties',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            ...paymentFlow.parties.asMap().entries.map((entry) {
              final party = entry.value;
              final isLast = entry.key == paymentFlow.parties.length - 1;

              return Column(
                children: [
                  _buildPartyItem(party),
                  if (!isLast) ...[
                    const SizedBox(height: 12),
                    Divider(color: Colors.grey.shade300),
                    const SizedBox(height: 12),
                  ],
                ],
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildPartyItem(PaymentParty party) {
    final statusColor = party.isPaid ? Colors.green : Colors.orange;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            party.isPaid ? Icons.check_circle : Icons.pending,
            color: statusColor,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                party.userName ?? party.userType,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                party.statusText,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
        Text(
          party.formattedAmount,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildTimeline() {
    return Card(
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Timeline',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            _buildTimelineItem(
              'Initiated',
              DateFormat('dd MMM yyyy, hh:mm a').format(paymentFlow.createdAt),
              true,
            ),
            if (paymentFlow.initiatedAt != null) ...[
              _buildTimelineDivider(),
              _buildTimelineItem(
                'Started',
                DateFormat('dd MMM yyyy, hh:mm a')
                    .format(paymentFlow.initiatedAt!),
                true,
              ),
            ],
            if (paymentFlow.completedAt != null) ...[
              _buildTimelineDivider(),
              _buildTimelineItem(
                'Completed',
                DateFormat('dd MMM yyyy, hh:mm a')
                    .format(paymentFlow.completedAt!),
                true,
              ),
            ],
            if (!paymentFlow.isCompleted) ...[
              _buildTimelineDivider(),
              _buildTimelineItem(
                'Expected Completion',
                DateFormat('dd MMM yyyy').format(
                  DateTime.now().add(const Duration(days: 3)),
                ),
                false,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineItem(String title, String date, bool isCompleted) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCompleted ? Colors.green : Colors.grey.shade300,
              ),
              child: isCompleted
                  ? const Icon(Icons.check, color: Colors.white, size: 14)
                  : null,
            ),
          ],
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              date,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTimelineDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Container(
        width: 2,
        height: 16,
        margin: const EdgeInsets.only(left: 11),
        color: Colors.grey.shade300,
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _sharePaymentDetails(context),
            icon: const Icon(Icons.share),
            label: const Text('Share'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(width: 12),
        if (paymentFlow.isCompleted)
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _downloadReceipt(context),
              icon: const Icon(Icons.download),
              label: const Text('Receipt'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          )
        else
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _contactSupport(context),
              icon: const Icon(Icons.help),
              label: const Text('Help'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
      ],
    );
  }

  Color _getStatusColor() {
    switch (paymentFlow.status) {
      case PaymentFlowStatus.completed:
        return Colors.green;
      case PaymentFlowStatus.failed:
        return Colors.red;
      case PaymentFlowStatus.disputed:
        return Colors.orange;
      default:
        return AppColors.primary;
    }
  }

  IconData _getStatusIcon() {
    switch (paymentFlow.status) {
      case PaymentFlowStatus.completed:
        return Icons.check_circle;
      case PaymentFlowStatus.failed:
        return Icons.error;
      case PaymentFlowStatus.disputed:
        return Icons.warning;
      case PaymentFlowStatus.partiallyPaid:
        return Icons.schedule;
      default:
        return Icons.pending;
    }
  }

  void _sharePaymentDetails(BuildContext context) {
    // TODO: Implement sharing
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sharing payment details...')),
    );
  }

  void _downloadReceipt(BuildContext context) {
    // TODO: Implement download
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Downloading receipt...')),
    );
  }

  void _contactSupport(BuildContext context) {
    // TODO: Implement support
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Contacting support...')),
    );
  }
}

// ============================================================================
// MULTI-PARTY PAYMENT DIALOG
// ============================================================================

class MultiPartyPaymentDialog extends StatefulWidget {
  final double totalAmount;
  final String buyerId;
  final String farmerId;
  final String driverId;

  const MultiPartyPaymentDialog({
    required this.totalAmount,
    required this.buyerId,
    required this.farmerId,
    required this.driverId,
    Key? key,
  }) : super(key: key);

  @override
  State<MultiPartyPaymentDialog> createState() =>
      _MultiPartyPaymentDialogState();
}

class _MultiPartyPaymentDialogState extends State<MultiPartyPaymentDialog> {
  late double buyerShare;
  late double farmerShare;

  @override
  void initState() {
    super.initState();
    buyerShare = widget.totalAmount / 2;
    farmerShare = widget.totalAmount / 2;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Split Transport Payment',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 20),

            // Total Amount
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Transport Cost',
                    style: GoogleFonts.poppins(fontSize: 13),
                  ),
                  Text(
                    'Tk ${widget.totalAmount.toStringAsFixed(2)}',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Buyer Share
            Text(
              'Buyer Share: Tk ${buyerShare.toStringAsFixed(2)}',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Slider(
              value: buyerShare,
              min: 0,
              max: widget.totalAmount,
              divisions: 20,
              onChanged: (value) {
                setState(() {
                  buyerShare = value;
                  farmerShare = widget.totalAmount - value;
                });
              },
            ),
            const SizedBox(height: 16),

            // Farmer Share
            Text(
              'Farmer Share: Tk ${farmerShare.toStringAsFixed(2)}',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Slider(
              value: farmerShare,
              min: 0,
              max: widget.totalAmount,
              divisions: 20,
              onChanged: (value) {
                setState(() {
                  farmerShare = value;
                  buyerShare = widget.totalAmount - value;
                });
              },
            ),
            const SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context, {
                        'buyerShare': buyerShare,
                        'farmerShare': farmerShare,
                      });
                    },
                    child: const Text('Confirm'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
