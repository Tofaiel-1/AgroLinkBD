import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:agrolinkbd/presentation/buyer/providers/address_provider.dart';
import 'package:agrolinkbd/presentation/buyer/providers/cart_provider.dart';
import 'package:agrolinkbd/core/services/sslcommerz_service.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  int _currentStep = 0;
  final List<String> _paymentMethods = ['SSLCommerz (কার্ড / বিকাশ / নগদ)', 'COD (ক্যাশ অন ডেলিভারি)', 'Wallet (ওয়ালেট)'];
  String _selectedPaymentMethod = 'SSLCommerz (কার্ড / বিকাশ / নগদ)';
  String? _selectedAddressId;
  DateTime? _selectedDeliveryDate;
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    final addresses = ref.watch(addressesProvider);
    final cart = ref.watch(cartProvider);
    final cartSummary = ref.watch(cartSummaryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('চেকআউট'),
        elevation: 0,
      ),
      body: cart.when(
        data: (cartData) => Column(
          children: [
            // Stepper
            Expanded(
              child: Stepper(
                currentStep: _currentStep,
                onStepContinue: () {
                  if (_currentStep < 3) {
                    setState(() => _currentStep++);
                  }
                },
                onStepCancel: () {
                  if (_currentStep > 0) {
                    setState(() => _currentStep--);
                  }
                },
                onStepTapped: (step) {
                  setState(() => _currentStep = step);
                },
                steps: [
                  // Step 1: Address
                  Step(
                    title: const Text('ঠিকানা'),
                    content: addresses.when(
                      data: (addressList) => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ...addressList.map(
                            (address) => Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: ListTile(
                                selected: _selectedAddressId == address.id,
                                title: Text(address.label),
                                subtitle: Text(address.getFullAddress()),
                                onTap: () {
                                  setState(
                                      () => _selectedAddressId = address.id);
                                },
                                leading: Radio(
                                  value: address.id,
                                  groupValue: _selectedAddressId,
                                  onChanged: (value) {
                                    setState(() => _selectedAddressId = value);
                                  },
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.add),
                              label: const Text('নতুন ঠিকানা যোগ করুন'),
                            ),
                          ),
                        ],
                      ),
                      loading: () => const CircularProgressIndicator(),
                      error: (_, __) => const Text('Error loading addresses'),
                    ),
                    isActive: _currentStep >= 0,
                  ),
                  // Step 2: Delivery date
                  Step(
                    title: const Text('ডেলিভারি তারিখ'),
                    content: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'আপনার পছন্দের ডেলিভারি তারিখ নির্বাচন করুন',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate:
                                  DateTime.now().add(const Duration(days: 1)),
                              firstDate:
                                  DateTime.now().add(const Duration(days: 1)),
                              lastDate:
                                  DateTime.now().add(const Duration(days: 7)),
                            );
                            if (date != null) {
                              setState(() => _selectedDeliveryDate = date);
                            }
                          },
                          child: Text(
                            _selectedDeliveryDate == null
                                ? 'তারিখ নির্বাচন করুন'
                                : '${_selectedDeliveryDate!.day}/${_selectedDeliveryDate!.month}/${_selectedDeliveryDate!.year}',
                          ),
                        ),
                      ],
                    ),
                    isActive: _currentStep >= 1,
                  ),
                  // Step 3: Payment method
                  Step(
                    title: const Text('পেমেন্ট পদ্ধতি'),
                    content: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ..._paymentMethods.map(
                          (method) => RadioListTile(
                            title: Text(method),
                            value: method,
                            groupValue: _selectedPaymentMethod,
                            onChanged: (value) {
                              setState(() => _selectedPaymentMethod = value!);
                            },
                          ),
                        ),
                      ],
                    ),
                    isActive: _currentStep >= 2,
                  ),
                  // Step 4: Review
                  Step(
                    title: const Text('পর্যালোচনা'),
                    content: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'আপনার অর্ডার সম্পূর্ণ করতে প্রস্তুত',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('সাবটোটাল'),
                                  Text('৳${cartSummary.subtotal}'),
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('ডেলিভারি'),
                                  Text('৳${cartSummary.deliveryFee}'),
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('মোট'),
                                  Text('৳${cartSummary.total}'),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isProcessing
                                ? null
                                : () async {
                                    bool isPaid = true;
                                    if (_selectedPaymentMethod.contains('SSLCommerz')) {
                                      setState(() => _isProcessing = true);
                                      isPaid = await SSLCommerzService.initiatePayment(
                                        context: context,
                                        amount: cartSummary.total,
                                        productName: 'বাজার পণ্যসমূহ',
                                        customerName: 'Buyer User',
                                        customerEmail: 'buyer@agrolinkbd.com',
                                        customerPhone: '01700000000',
                                        customerAddress: 'Dhaka, Bangladesh',
                                      );
                                      if (mounted) setState(() => _isProcessing = false);
                                    }

                                    if (isPaid && mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                            content: Text(
                                                'অর্ডার সফলভাবে প্লেস করা হয়েছে! 🎉'),
                                            backgroundColor: Colors.green),
                                      );
                                      Navigator.pop(context);
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1976D2),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: _isProcessing
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                  )
                                : const Text(
                                    'অর্ডার নিশ্চিত করুন',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                    isActive: _currentStep >= 3,
                  ),
                ],
              ),
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
    );
  }
}
