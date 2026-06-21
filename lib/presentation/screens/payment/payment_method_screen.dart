import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/payment_model.dart';

class PaymentMethodScreen extends ConsumerWidget {
  final double amount;
  final String purpose;
  final String? orderId;
  final Map<String, dynamic>? metadata;

  const PaymentMethodScreen({
    required this.amount,
    required this.purpose,
    this.orderId,
    this.metadata,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Payment Method'),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Amount Display
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const Text(
                    'Amount to Pay',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tk ${amount.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Purpose: $purpose',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Payment Methods List
            Expanded(
              child: ListView(
                children: PaymentMethod.values
                    .map((method) => PaymentMethodCard(
                          method: method,
                          amount: amount,
                          purpose: purpose,
                          orderId: orderId,
                          metadata: metadata,
                        ))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PaymentMethodCard extends ConsumerWidget {
  final PaymentMethod method;
  final double amount;
  final String purpose;
  final String? orderId;
  final Map<String, dynamic>? metadata;

  const PaymentMethodCard({
    required this.method,
    required this.amount,
    required this.purpose,
    this.orderId,
    this.metadata,
    Key? key,
  }) : super(key: key);

  String get _methodName {
    switch (method) {
      case PaymentMethod.bkash:
        return 'bKash';
      case PaymentMethod.nagad:
        return 'Nagad';
      case PaymentMethod.rocket:
        return 'Rocket';
      case PaymentMethod.card:
        return 'Card (Visa/Mastercard)';
      case PaymentMethod.flutterwave:
        return 'Flutterwave';
    }
  }

  String get _description {
    switch (method) {
      case PaymentMethod.bkash:
        return 'Mobile banking service from bKash';
      case PaymentMethod.nagad:
        return 'Nagad digital payment service';
      case PaymentMethod.rocket:
        return 'Rocket mobile wallet service';
      case PaymentMethod.card:
        return 'Credit/Debit card payment';
      case PaymentMethod.flutterwave:
        return 'Secure payment with Flutterwave';
    }
  }

  IconData get _icon {
    switch (method) {
      case PaymentMethod.bkash:
        return Icons.phone_android;
      case PaymentMethod.nagad:
        return Icons.phone_android;
      case PaymentMethod.rocket:
        return Icons.phone_android;
      case PaymentMethod.card:
        return Icons.credit_card;
      case PaymentMethod.flutterwave:
        return Icons.security;
    }
  }

  Color get _color {
    switch (method) {
      case PaymentMethod.bkash:
        return Colors.purple;
      case PaymentMethod.nagad:
        return Colors.orange;
      case PaymentMethod.rocket:
        return Colors.blue;
      case PaymentMethod.card:
        return Colors.indigo;
      case PaymentMethod.flutterwave:
        return Colors.teal;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => _selectMethod(context, ref),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade200),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: _color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(_icon, color: _color, size: 28),
            ),
            const SizedBox(width: 16),
            // Method Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _methodName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _description,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            // Arrow
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }

  void _selectMethod(BuildContext context, WidgetRef ref) {
    // Navigate to payment confirmation screen
    Navigator.of(context).pushNamed(
      '/payment-confirmation',
      arguments: {
        'method': method,
        'amount': amount,
        'purpose': purpose,
        'orderId': orderId,
        'metadata': metadata,
      },
    );
  }
}
