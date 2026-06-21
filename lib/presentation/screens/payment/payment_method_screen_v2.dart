import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';

class PaymentMethodScreen extends StatefulWidget {
  const PaymentMethodScreen({Key? key}) : super(key: key);

  @override
  State<PaymentMethodScreen> createState() => _PaymentMethodScreenState();
}

class _PaymentMethodScreenState extends State<PaymentMethodScreen> {
  int? _selectedMethodIndex;

  final List<PaymentMethodItem> _paymentMethods = [
    PaymentMethodItem(
      id: 'bkash',
      name: 'bKash',
      icon: Icons.phone_android,
      description: 'Fast & Secure Mobile Payment',
      color: const Color(0xFFEE1A3F),
      minAmount: 10,
      maxAmount: 100000,
    ),
    PaymentMethodItem(
      id: 'nagad',
      name: 'Nagad',
      icon: Icons.phone_android,
      description: 'Nagad Account Payment',
      color: const Color(0xFFC41E3A),
      minAmount: 10,
      maxAmount: 100000,
    ),
    PaymentMethodItem(
      id: 'rocket',
      name: 'Rocket',
      icon: Icons.phone_android,
      description: 'Rocket Money Transfer',
      color: const Color(0xFF7D3C65),
      minAmount: 10,
      maxAmount: 100000,
    ),
    PaymentMethodItem(
      id: 'card',
      name: 'Card',
      icon: Icons.credit_card,
      description: 'Visa/Mastercard Payment',
      color: const Color(0xFF1434CB),
      minAmount: 50,
      maxAmount: 500000,
    ),
    PaymentMethodItem(
      id: 'flutterwave',
      name: 'Flutterwave',
      icon: Icons.payment,
      description: 'Multiple Payment Options',
      color: const Color(0xFFFF6000),
      minAmount: 50,
      maxAmount: 500000,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Select Payment Method',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        elevation: 0,
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _paymentMethods.length,
              itemBuilder: (context, index) {
                final method = _paymentMethods[index];
                final isSelected = _selectedMethodIndex == index;

                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedMethodIndex = index);
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isSelected
                            ? AppTheme.primaryGreen
                            : Colors.grey.shade300,
                        width: isSelected ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      color: isSelected
                          ? AppTheme.primaryGreen.withOpacity(0.05)
                          : Colors.white,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: method.color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            method.icon,
                            color: method.color,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                method.name,
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                method.description,
                                style: GoogleFonts.roboto(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Tk ${method.minAmount} - Tk ${method.maxAmount}',
                                style: GoogleFonts.roboto(
                                  fontSize: 10,
                                  color: Colors.grey.shade500,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isSelected)
                          Icon(
                            Icons.check_circle,
                            color: AppTheme.primaryGreen,
                            size: 24,
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.grey.shade200),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 20,
                        color: Colors.blue.shade600,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'All transactions are secured and encrypted',
                          style: GoogleFonts.roboto(
                            fontSize: 12,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _selectedMethodIndex != null
                        ? () {
                            // TODO: Navigate to payment confirmation screen
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryGreen,
                      disabledBackgroundColor: Colors.grey.shade300,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Continue',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PaymentMethodItem {
  final String id;
  final String name;
  final IconData icon;
  final String description;
  final Color color;
  final double minAmount;
  final double maxAmount;

  PaymentMethodItem({
    required this.id,
    required this.name,
    required this.icon,
    required this.description,
    required this.color,
    required this.minAmount,
    required this.maxAmount,
  });
}
