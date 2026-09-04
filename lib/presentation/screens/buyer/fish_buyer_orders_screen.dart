import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:agrolinkbd/core/models/order_model.dart';
import 'package:agrolinkbd/core/services/order_service.dart';
import 'package:agrolinkbd/core/providers/language_provider.dart';
import 'package:agrolinkbd/core/utils/number_converter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math';
import 'package:get/get.dart';
import 'package:agrolinkbd/presentation/screens/buyer/order_details_screen.dart';
import 'package:agrolinkbd/presentation/screens/buyer/fish_order_tracking_screen.dart';
import 'package:agrolinkbd/presentation/screens/transport/order_qr_delivery_screen.dart';

/// Buyer Orders Screen — Tab-based order management with full English & Bangla support
class FishBuyerOrdersScreen extends StatefulWidget {
  const FishBuyerOrdersScreen({super.key});

  @override
  State<FishBuyerOrdersScreen> createState() => _FishBuyerOrdersScreenState();
}

class _FishBuyerOrdersScreenState extends State<FishBuyerOrdersScreen>
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

  String _getStatusLabel(String status, bool isBn) {
    switch (status.toLowerCase().trim()) {
      case 'pending':
        return isBn ? 'অপেক্ষমাণ' : 'Pending';
      case 'processing':
        return isBn ? 'প্রস্তুত হচ্ছে' : 'Processing';
      case 'shipped':
        return isBn ? 'পাঠানো হয়েছে' : 'Shipped';
      case 'delivered':
        return isBn ? 'ডেলিভার্ড' : 'Delivered';
      case 'cancelled':
        return isBn ? 'বাতিল' : 'Cancelled';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isBn = LanguageProvider.isBn(context);

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
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (Navigator.canPop(context))
                        Padding(
                          padding: const EdgeInsets.only(right: 12.0),
                          child: InkWell(
                            onTap: () => Navigator.pop(context),
                            child: Icon(
                              Icons.arrow_back,
                              size: 24,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                        ),
                      Text(
                        isBn ? 'আমার অর্ডার 📦' : 'My Orders 📦',
                        style: isBn
                            ? GoogleFonts.hindSiliguri(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.black87,
                              )
                            : GoogleFonts.poppins(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Tab Bar
                  TabBar(
                    controller: _tabController,
                    labelColor: const Color(0xFF1976D2),
                    unselectedLabelColor: isDark ? Colors.white54 : Colors.grey.shade500,
                    indicatorColor: const Color(0xFF1976D2),
                    indicatorWeight: 3,
                    labelStyle: isBn
                        ? GoogleFonts.hindSiliguri(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          )
                        : GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                    tabs: [
                      Tab(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.pending_actions, size: 18),
                            const SizedBox(width: 6),
                            Text(isBn ? 'সক্রিয় অর্ডার' : 'Active Orders'),
                          ],
                        ),
                      ),
                      Tab(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.history, size: 18),
                            const SizedBox(width: 6),
                            Text(isBn ? 'পূর্ববর্তী অর্ডার' : 'Past Orders'),
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
                  final activeOrders = allOrders.where((o) {
                    final status = o.status.toLowerCase().trim();
                    return status != 'delivered' && status != 'cancelled';
                  }).toList();
                  final pastOrders = allOrders.where((o) {
                    final status = o.status.toLowerCase().trim();
                    return status == 'delivered' || status == 'cancelled';
                  }).toList();

                  return TabBarView(
                    controller: _tabController,
                    children: [
                      // Active orders tab
                      activeOrders.isEmpty
                          ? _buildEmptyState(
                              isDark,
                              isBn ? 'কোনো সক্রিয় অর্ডার নেই' : 'No active orders found',
                              Icons.inbox_outlined,
                              isBn,
                            )
                          : ListView.builder(
                              physics: const BouncingScrollPhysics(),
                              padding: const EdgeInsets.all(16),
                              itemCount: activeOrders.length,
                              itemBuilder: (context, index) {
                                return _buildActiveOrderCard(activeOrders[index], isDark, isBn);
                              },
                            ),

                      // Past orders tab
                      pastOrders.isEmpty
                          ? _buildEmptyState(
                              isDark,
                              isBn ? 'কোনো পূর্ববর্তী অর্ডার নেই' : 'No past orders recorded',
                              Icons.history_outlined,
                              isBn,
                            )
                          : ListView.builder(
                              physics: const BouncingScrollPhysics(),
                              padding: const EdgeInsets.all(16),
                              itemCount: pastOrders.length,
                              itemBuilder: (context, index) {
                                return _buildPastOrderCard(pastOrders[index], isDark, isBn);
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

  Widget _buildEmptyState(bool isDark, String message, IconData icon, bool isBn) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: isDark ? Colors.white24 : Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: isBn
                ? GoogleFonts.hindSiliguri(
                    fontSize: 16,
                    color: isDark ? Colors.white54 : Colors.grey.shade500,
                    fontWeight: FontWeight.w600,
                  )
                : GoogleFonts.poppins(
                    fontSize: 15,
                    color: isDark ? Colors.white54 : Colors.grey.shade500,
                    fontWeight: FontWeight.w500,
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveOrderCard(OrderModel order, bool isDark, bool isBn) {
    final statusStep = order.statusStep;
    final steps = isBn
        ? ['গৃহীত', 'প্রস্তুতি', 'পাঠানো', 'ডেলিভার']
        : ['Accepted', 'Processing', 'Shipped', 'Delivered'];

    return GestureDetector(
      onTap: () => Get.to(() => OrderDetailsScreen(order: order)),
      child: Container(
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
                    color: Colors.black.withValues(alpha: 0.04),
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
                  '#ORD-${order.id.substring(0, min(6, order.id.length))}',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: isDark ? 0.25 : 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _getStatusLabel(order.status, isBn),
                    style: isBn
                        ? GoogleFonts.hindSiliguri(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1976D2),
                          )
                        : GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1976D2),
                          ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Order details
            Row(
              children: [
                Icon(Icons.calendar_today, size: 14, color: isDark ? Colors.white38 : Colors.grey.shade400),
                const SizedBox(width: 6),
                Text(
                  '${BanglaEnglishNumberHelper.format(order.createdAt.day, isBn)}/${BanglaEnglishNumberHelper.format(order.createdAt.month, isBn)}/${BanglaEnglishNumberHelper.format(order.createdAt.year, isBn)}',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: isDark ? Colors.white54 : Colors.grey.shade600,
                  ),
                ),
                const SizedBox(width: 16),
                Icon(Icons.person_outline, size: 14, color: isDark ? Colors.white38 : Colors.grey.shade400),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    order.farmerName,
                    style: isBn
                        ? GoogleFonts.hindSiliguri(
                            fontSize: 12,
                            color: isDark ? Colors.white54 : Colors.grey.shade600,
                          )
                        : GoogleFonts.poppins(
                            fontSize: 12,
                            color: isDark ? Colors.white54 : Colors.grey.shade600,
                          ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${order.productName} (${BanglaEnglishNumberHelper.format(order.quantity, isBn)})',
              style: isBn
                  ? GoogleFonts.hindSiliguri(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white70 : Colors.black87,
                    )
                  : GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
            ),
            const SizedBox(height: 6),
            Text(
              '৳${BanglaEnglishNumberHelper.format(order.totalAmount.toStringAsFixed(0), isBn)}',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: const Color(0xFF1976D2),
              ),
            ),
            const SizedBox(height: 10),

            // Delivery OTP Card
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF1976D2).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF1976D2).withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isBn ? '🔒 ডেলিভারি ওটিপি (Delivery OTP)' : '🔒 Delivery OTP',
                        style: isBn
                            ? GoogleFonts.hindSiliguri(
                                fontSize: 11,
                                color: const Color(0xFF0D47A1),
                                fontWeight: FontWeight.bold,
                              )
                            : GoogleFonts.poppins(
                                fontSize: 11,
                                color: const Color(0xFF0D47A1),
                                fontWeight: FontWeight.bold,
                              ),
                      ),
                      Text(
                        isBn ? 'পণ্য হাতে পেয়ে ড্রাইভারকে দিন' : 'Share OTP with driver upon delivery',
                        style: isBn
                            ? GoogleFonts.hindSiliguri(
                                fontSize: 10,
                                color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
                              )
                            : GoogleFonts.poppins(
                                fontSize: 9.5,
                                color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
                              ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1976D2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      order.deliveryOtp,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 3,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Get.to(() => FishOrderTrackingScreen(order: order));
                    },
                    icon: const Icon(Icons.local_shipping, size: 16),
                    label: Text(
                      isBn ? 'ট্র্যাকিং' : 'Track Order',
                      style: isBn
                          ? GoogleFonts.hindSiliguri(fontSize: 12, fontWeight: FontWeight.bold)
                          : GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF0277BD),
                      side: const BorderSide(color: Color(0xFF0277BD)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Get.to(() => OrderQrDeliveryScreen(order: order, isDriverView: false));
                    },
                    icon: const Icon(Icons.qr_code_2, size: 16, color: Colors.white),
                    label: Text(
                      isBn ? 'কিউআর ও এস্ক্রো' : 'QR & Escrow',
                      style: isBn
                          ? GoogleFonts.hindSiliguri(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold)
                          : GoogleFonts.poppins(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D32),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
              ],
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
                                      color: const Color(0xFF1976D2).withValues(alpha: 0.3),
                                      width: 3,
                                    )
                                  : null,
                            ),
                            child: isActive
                                ? const Icon(Icons.check, size: 12, color: Colors.white)
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
                        style: isBn
                            ? GoogleFonts.hindSiliguri(
                                fontSize: 10,
                                fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                                color: isActive
                                    ? const Color(0xFF1976D2)
                                    : isDark
                                        ? Colors.white38
                                        : Colors.grey.shade400,
                              )
                            : GoogleFonts.poppins(
                                fontSize: 9.5,
                                fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
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
      ),
    );
  }

  Widget _buildPastOrderCard(OrderModel order, bool isDark, bool isBn) {
    return GestureDetector(
      onTap: () => Get.to(() => OrderDetailsScreen(order: order)),
      child: Container(
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
                color: (order.status == 'cancelled' ? Colors.red : Colors.green)
                    .withValues(alpha: isDark ? 0.25 : 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                order.status == 'cancelled' ? Icons.cancel_outlined : Icons.check_circle_outlined,
                color: order.status == 'cancelled' ? Colors.red : Colors.green,
                size: 24,
              ),
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
                        '#ORD-${order.id.substring(0, min(6, order.id.length))}',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 13.5,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      Text(
                        '${BanglaEnglishNumberHelper.format(order.createdAt.day, isBn)}/${BanglaEnglishNumberHelper.format(order.createdAt.month, isBn)}/${BanglaEnglishNumberHelper.format(order.createdAt.year, isBn)}',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: isDark ? Colors.white38 : Colors.grey.shade400,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${order.productName} (${BanglaEnglishNumberHelper.format(order.quantity, isBn)})',
                    style: isBn
                        ? GoogleFonts.hindSiliguri(
                            fontSize: 12,
                            color: isDark ? Colors.white54 : Colors.grey.shade600,
                          )
                        : GoogleFonts.poppins(
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
                        '৳${BanglaEnglishNumberHelper.format(order.totalAmount.toStringAsFixed(0), isBn)}',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: const Color(0xFF1976D2),
                        ),
                      ),
                      Row(
                        children: [
                          if (order.status == 'delivered' && order.rating == null) ...[
                            GestureDetector(
                              onTap: () => _showRatingDialog(context, order, isBn),
                              child: Container(
                                margin: const EdgeInsets.only(right: 8),
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: Colors.orange.withValues(alpha: isDark ? 0.25 : 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  isBn ? 'রেটিং দিন' : 'Rate Order',
                                  style: isBn
                                      ? GoogleFonts.hindSiliguri(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.orange,
                                        )
                                      : GoogleFonts.poppins(
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.orange,
                                        ),
                                ),
                              ),
                            ),
                          ],
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1976D2).withValues(alpha: isDark ? 0.25 : 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _getStatusLabel(order.status, isBn),
                              style: isBn
                                  ? GoogleFonts.hindSiliguri(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF1976D2),
                                    )
                                  : GoogleFonts.poppins(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF1976D2),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showRatingDialog(BuildContext context, OrderModel order, bool isBn) {
    double currentRating = 5.0;
    TextEditingController reviewController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(
              isBn ? 'রেটিং দিন: ${order.productName}' : 'Rate ${order.productName}',
              style: isBn
                  ? GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold)
                  : GoogleFonts.poppins(fontWeight: FontWeight.bold),
            ),
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
                        size: 32,
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
                  decoration: InputDecoration(
                    hintText: isBn ? 'আপনার মন্তব্য লিখুন (ঐচ্ছিক)' : 'Write a review (optional)',
                    border: const OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(isBn ? 'বাতিল' : 'Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  await OrderService().updateOrderRating(order.id, currentRating, reviewController.text);
                  Navigator.pop(context);
                  Get.snackbar(
                    isBn ? 'সফল' : 'Success',
                    isBn ? 'আপনার মতামতের জন্য ধন্যবাদ!' : 'Thank you for your feedback!',
                    backgroundColor: Colors.green.shade100,
                    colorText: Colors.green.shade900,
                  );
                },
                child: Text(isBn ? 'জমা দিন' : 'Submit'),
              ),
            ],
          );
        },
      ),
    );
  }
}
