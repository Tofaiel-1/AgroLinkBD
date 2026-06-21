import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:agrolinkbd/presentation/buyer/providers/cart_provider.dart';
import 'package:agrolinkbd/presentation/buyer/widgets/cart_item_widget.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);
    final cartSummary = ref.watch(cartSummaryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('আমার কার্ট'),
        elevation: 0,
      ),
      body: cart.when(
        data: (cartData) => cartData.items.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.shopping_cart_outlined,
                        size: 64, color: Colors.grey),
                    const SizedBox(height: 16),
                    const Text(
                      'কার্ট খালি',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'পণ্য যোগ করতে শুরু করুন',
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1976D2),
                      ),
                      child: const Text('শপিং চালিয়ে যান'),
                    ),
                  ],
                ),
              )
            : Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: cartData.items.length,
                      itemBuilder: (context, index) {
                        final item = cartData.items[index];
                        return CartItemWidget(
                          productName: item.productName,
                          productNamebn: item.productNamebn,
                          imageUrl: item.productImages.isNotEmpty
                              ? item.productImages[0]
                              : null,
                          price: item.price,
                          quantity: item.quantity,
                          unit: item.unit,
                          farmerName: item.farmerName,
                          onIncrement: () {
                            ref.read(updateCartItemQuantityProvider(
                              (itemId: item.id, quantity: item.quantity + 1),
                            ));
                          },
                          onDecrement: () {
                            if (item.quantity > 1) {
                              ref.read(updateCartItemQuantityProvider(
                                (itemId: item.id, quantity: item.quantity - 1),
                              ));
                            }
                          },
                          onRemove: () {
                            ref.read(removeFromCartProvider(item.id));
                          },
                        );
                      },
                    ),
                  ),
                  // Price summary
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border:
                          Border(top: BorderSide(color: Colors.grey.shade200)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('সাবটোটাল'),
                            Text('৳${cartSummary.subtotal.toStringAsFixed(0)}'),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('ডেলিভারি চার্জ'),
                            Text(
                                '৳${cartSummary.deliveryFee.toStringAsFixed(0)}'),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('ট্যাক্স'),
                            Text(
                                '৳${cartSummary.taxAmount.toStringAsFixed(0)}'),
                          ],
                        ),
                        if (cartSummary.discountAmount > 0) ...[
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('ছাড়'),
                              Text(
                                '-৳${cartSummary.discountAmount.toStringAsFixed(0)}',
                                style: const TextStyle(color: Colors.green),
                              ),
                            ],
                          ),
                        ],
                        const Divider(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'মোট',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '৳${cartSummary.total.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1976D2),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/buyer/checkout');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1976D2),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: const Text(
                              'চেকআউটে যান',
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
                  ),
                ],
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
    );
  }
}
