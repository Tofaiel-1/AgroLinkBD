import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/payment_model.dart';
import '../../core/providers/payment_provider.dart';

/// Payment Summary Widget
/// Displays payment amount and details in a card format
class PaymentSummaryWidget extends StatelessWidget {
  final double amount;
  final String purpose;
  final String? orderId;
  final bool showBreakdown;
  final Map<String, double>?
      breakdown; // e.g., {'subtotal': 500, 'tax': 50, 'shipping': 20}

  const PaymentSummaryWidget({
    required this.amount,
    required this.purpose,
    this.orderId,
    this.showBreakdown = false,
    this.breakdown,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Payment Summary',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          if (showBreakdown && breakdown != null)
            _buildBreakdown()
          else
            _buildSimpleAmount(),
          const SizedBox(height: 12),
          Container(
            height: 1,
            color: Colors.grey.shade200,
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Amount',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              Text(
                'Tk ${amount.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          if (orderId != null) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Order ID', style: TextStyle(color: Colors.grey.shade600)),
                Text(orderId!,
                    style: const TextStyle(fontWeight: FontWeight.w500)),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSimpleAmount() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(purpose, style: TextStyle(color: Colors.grey.shade600)),
        Text('Tk ${amount.toStringAsFixed(2)}'),
      ],
    );
  }

  Widget _buildBreakdown() {
    return Column(
      children: breakdown!.entries.map((entry) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(entry.key, style: TextStyle(color: Colors.grey.shade600)),
              Text('Tk ${entry.value.toStringAsFixed(2)}'),
            ],
          ),
        );
      }).toList(),
    );
  }
}

/// Payment Method Selector Widget
/// Allows user to select from available payment methods
class PaymentMethodSelector extends StatefulWidget {
  final Function(PaymentMethod) onMethodSelected;
  final PaymentMethod? initialMethod;

  const PaymentMethodSelector({
    required this.onMethodSelected,
    this.initialMethod,
    Key? key,
  }) : super(key: key);

  @override
  State<PaymentMethodSelector> createState() => _PaymentMethodSelectorState();
}

class _PaymentMethodSelectorState extends State<PaymentMethodSelector> {
  late PaymentMethod selectedMethod;

  @override
  void initState() {
    super.initState();
    selectedMethod = widget.initialMethod ?? PaymentMethod.bkash;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Payment Method',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: PaymentMethod.values.map((method) {
            return GestureDetector(
              onTap: () {
                setState(() => selectedMethod = method);
                widget.onMethodSelected(method);
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: selectedMethod == method
                        ? Colors.blue
                        : Colors.grey.shade300,
                    width: selectedMethod == method ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(8),
                  color: selectedMethod == method
                      ? Colors.blue.withOpacity(0.05)
                      : Colors.white,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getMethodIcon(method),
                      size: 16,
                      color:
                          selectedMethod == method ? Colors.blue : Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      method.toString().split('.').last,
                      style: TextStyle(
                        fontWeight: selectedMethod == method
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  IconData _getMethodIcon(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.bkash:
      case PaymentMethod.nagad:
      case PaymentMethod.rocket:
        return Icons.phone_android;
      case PaymentMethod.card:
        return Icons.credit_card;
      case PaymentMethod.flutterwave:
        return Icons.security;
    }
  }
}

/// Wallet Balance Widget
/// Displays current wallet balance
class WalletBalanceWidget extends ConsumerWidget {
  final String userId;
  final bool showHistory;
  final Function()? onHistoryTap;

  const WalletBalanceWidget({
    required this.userId,
    this.showHistory = true,
    this.onHistoryTap,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final balanceAsync = ref.watch(walletBalanceProvider(userId));

    return balanceAsync.when(
      data: (balance) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade400, Colors.blue.shade600],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Wallet Balance',
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tk ${balance.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            if (showHistory)
              IconButton(
                icon: const Icon(Icons.history, color: Colors.white),
                onPressed: onHistoryTap,
              ),
          ],
        ),
      ),
      loading: () => const SizedBox(
        height: 100,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text('Error: $error'),
      ),
    );
  }
}

/// Payment Status Badge
/// Shows payment status with appropriate color
class PaymentStatusBadge extends StatelessWidget {
  final PaymentStatus status;
  final double fontSize;

  const PaymentStatusBadge({
    required this.status,
    this.fontSize = 12,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor;
    IconData icon;

    switch (status) {
      case PaymentStatus.completed:
        backgroundColor = Colors.green.withOpacity(0.1);
        textColor = Colors.green;
        icon = Icons.check_circle;
        break;
      case PaymentStatus.processing:
        backgroundColor = Colors.orange.withOpacity(0.1);
        textColor = Colors.orange;
        icon = Icons.hourglass_bottom;
        break;
      case PaymentStatus.pending:
        backgroundColor = Colors.blue.withOpacity(0.1);
        textColor = Colors.blue;
        icon = Icons.schedule;
        break;
      case PaymentStatus.failed:
        backgroundColor = Colors.red.withOpacity(0.1);
        textColor = Colors.red;
        icon = Icons.cancel;
        break;
      case PaymentStatus.refunded:
        backgroundColor = Colors.purple.withOpacity(0.1);
        textColor = Colors.purple;
        icon = Icons.restore;
        break;
      case PaymentStatus.cancelled:
        backgroundColor = Colors.grey.withOpacity(0.1);
        textColor = Colors.grey;
        icon = Icons.block;
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 8,
        vertical: fontSize == 12 ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: textColor, size: fontSize),
          const SizedBox(width: 4),
          Text(
            status.toString().split('.').last,
            style: TextStyle(
              color: textColor,
              fontSize: fontSize,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

/// Transaction Type Icon
/// Shows icon based on transaction type
class TransactionTypeIcon extends StatelessWidget {
  final TransactionType type;
  final double size;

  const TransactionTypeIcon({
    required this.type,
    this.size = 24,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color color;

    switch (type) {
      case TransactionType.credit:
        icon = Icons.add_circle;
        color = Colors.green;
        break;
      case TransactionType.debit:
        icon = Icons.remove_circle;
        color = Colors.red;
        break;
      case TransactionType.refund:
        icon = Icons.restore;
        color = Colors.purple;
        break;
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Icon(icon, color: color, size: size * 0.6),
      ),
    );
  }
}

/// Pay Now Button
/// Reusable button for initiating payment
class PayNowButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isLoading;
  final double amount;
  final String label;

  const PayNowButton({
    required this.onPressed,
    required this.amount,
    this.isLoading = false,
    this.label = 'Pay Now',
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: isLoading ? null : onPressed,
        icon: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Icon(Icons.payment),
        label: Text(
          isLoading
              ? 'Processing...'
              : '$label - Tk ${amount.toStringAsFixed(2)}',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
