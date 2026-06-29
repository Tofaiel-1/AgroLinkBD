import 'package:flutter/material.dart';
import 'package:agrolinkbd/core/models/order_model.dart';
import 'package:agrolinkbd/core/services/order_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math';
import 'package:get/get.dart';

/// Buyer Orders Screen — Tab-based order management
class BuyerOrdersScreen extends StatefulWidget {
  const BuyerOrdersScreen({super.key});

  @override
  State<BuyerOrdersScreen> createState() => _BuyerOrdersScreenState();
}

class _BuyerOrdersScreenState extends State<BuyerOrdersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;


  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF5F7FA),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'আমার অর্ডার 📦',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Tab Bar
                  TabBar(
                    controller: _tabController,
                    labelColor: const Color(0xFF1976D2),
                    unselectedLabelColor:
                        isDark ? Colors.white54 : Colors.grey.shade500,
                    indicatorColor: const Color(0xFF1976D2),
                    indicatorWeight: 3,
                    labelStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    tabs: [
                      Tab(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.pending_actions, size: 18),
                            const SizedBox(width: 6),
                            const Text('সক্রিয়'),

                          ],
                        ),
                      ),
                      const Tab(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.history, size: 18),
                            SizedBox(width: 6),
                            Text('পূর্ববর্তী'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Tab content
            Expanded(
              child: StreamBuilder<List<OrderModel>>(
                stream: OrderService().getOrdersByBuyerId(FirebaseAuth.instance.currentUser?.uid ?? ''),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  
                  final allOrders = snapshot.data ?? [];
                  final activeOrders = allOrders.where((o) => o.status == 'pending' || o.status == 'processing' || o.status == 'shipped').toList();
                  final pastOrders = allOrders.where((o) => o.status == 'delivered' || o.status == 'cancelled').toList();

                  return TabBarView(
                    controller: _tabController,
                    children: [
                      // Active orders tab
                      activeOrders.isEmpty
                          ? _buildEmptyState(
                              isDark, 'কোনো সক্রিয় অর্ডার নেই', Icons.inbox)
                          : ListView.builder(
                              physics: const BouncingScrollPhysics(),
                              padding: const EdgeInsets.all(16),
                              itemCount: activeOrders.length,
                              itemBuilder: (context, index) {
                                return _buildActiveOrderCard(
                                    activeOrders[index], isDark);
                              },
                            ),
                      
                      // Past orders tab
                      pastOrders.isEmpty
                          ? _buildEmptyState(
                              isDark, 'কোনো পূর্ববর্তী অর্ডার নেই', Icons.history)
                          : ListView.builder(
                              physics: const BouncingScrollPhysics(),
                              padding: const EdgeInsets.all(16),
                              itemCount: pastOrders.length,
                              itemBuilder: (context, index) {
                                return _buildPastOrderCard(
                                    pastOrders[index], isDark);
                              },
                            ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark, String message, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64,
              color: isDark ? Colors.white24 : Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: isDark ? Colors.white54 : Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveOrderCard(OrderModel order, bool isDark) {
    final statusStep = order.statusStep;
    final steps = ['গৃহীত', 'প্রস্তুতি', 'পাঠানো', 'ডেলিভার'];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white12 : Colors.grey.shade100,
        ),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                 '#ORD-${order.id.substring(0, min(6, order.id.length))}' ,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(isDark ? 0.2 : 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  order.status,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1976D2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Order details
          Row(
            children: [
              Icon(Icons.calendar_today,
                  size: 14, color: isDark ? Colors.white38 : Colors.grey.shade400),
              const SizedBox(width: 6),
              Text(
                 '${order.createdAt.day}/${order.createdAt.month}/${order.createdAt.year}' ,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.white54 : Colors.grey.shade600,
                ),
              ),
              const SizedBox(width: 16),
              Icon(Icons.person_outline,
                  size: 14, color: isDark ? Colors.white38 : Colors.grey.shade400),
              const SizedBox(width: 4),
              Text(
                order.farmerName,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.white54 : Colors.grey.shade600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
             '${order.productName} (${order.quantity})' ,
            style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),
          const SizedBox(height: 6),
          Text(
             '৳${order.totalAmount}' ,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Color(0xFF1976D2),
            ),
          ),
          const SizedBox(height: 8),
            if (order.estimatedDeliveryDate != null)
              Text(
                'ETA: ${order.estimatedDeliveryDate!.day}/${order.estimatedDeliveryDate!.month}/${order.estimatedDeliveryDate!.year}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white70 : Colors.black87,
                ),
              ),
            const SizedBox(height: 16),

            // Status tracker
          Row(
            children: List.generate(4, (i) {
              final isActive = i < statusStep;
              final isCurrent = i == statusStep - 1;
              return Expanded(
                child: Column(
                  children: [
                    Row(
                      children: [
                        if (i > 0)
                          Expanded(
                            child: Container(
                              height: 3,
                              color: isActive
                                  ? const Color(0xFF1976D2)
                                  : isDark
                                      ? Colors.white12
                                      : Colors.grey.shade200,
                            ),
                          ),
                        Container(
                          width: isCurrent ? 24 : 18,
                          height: isCurrent ? 24 : 18,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isActive
                                ? const Color(0xFF1976D2)
                                : isDark
                                    ? Colors.white12
                                    : Colors.grey.shade200,
                            border: isCurrent
                                ? Border.all(
                                    color: const Color(0xFF1976D2)
                                        .withOpacity(0.3),
                                    width: 3,
                                  )
                                : null,
                          ),
                          child: isActive
                              ? const Icon(Icons.check,
                                  size: 12, color: Colors.white)
                              : null,
                        ),
                        if (i < 3)
                          Expanded(
                            child: Container(
                              height: 3,
                              color: i < statusStep - 1
                                  ? const Color(0xFF1976D2)
                                  : isDark
                                      ? Colors.white12
                                      : Colors.grey.shade200,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      steps[i],
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight:
                            isCurrent ? FontWeight.bold : FontWeight.normal,
                        color: isActive
                            ? const Color(0xFF1976D2)
                            : isDark
                                ? Colors.white38
                                : Colors.grey.shade400,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildPastOrderCard(OrderModel order, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white12 : Colors.grey.shade100,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(isDark ? 0.2 : 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.check_circle, color: Colors.green, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                       '#ORD-${order.id.substring(0, min(6, order.id.length))}' ,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    Text(
                       '${order.createdAt.day}/${order.createdAt.month}/${order.createdAt.year}' ,
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? Colors.white38 : Colors.grey.shade400,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                   '${order.productName} (${order.quantity})' ,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white54 : Colors.grey.shade600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                       '৳${order.totalAmount}' ,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Color(0xFF1976D2),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Get.snackbar('পুনরায় অর্ডার', '${ '${order.productName} (${order.quantity})' } পুনরায় অর্ডার করুন');
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1976D2).withOpacity(isDark ? 0.2 : 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'পুনরায় অর্ডার',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1976D2),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showRatingDialog(BuildContext context, OrderModel order) {
    double currentRating = 5.0;
    TextEditingController reviewController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text('Rate ' + order.productName),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    return IconButton(
                      icon: Icon(
                        index < currentRating ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                        size: 36,
                      ),
                      onPressed: () {
                        setState(() {
                          currentRating = index + 1.0;
                        });
                      },
                    );
                  }),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: reviewController,
                  decoration: const InputDecoration(
                    hintText: 'Write a review (optional)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  await OrderService().updateOrderRating(order.id, currentRating, reviewController.text);
                  Navigator.pop(context);
                  Get.snackbar('Success', 'Thank you for your feedback!');
                },
                child: const Text('Submit'),
              ),
            ],
          );
        },
      ),
    );
  }
}
