import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:agrolinkbd/core/providers/service_provider_providers.dart';
import 'package:agrolinkbd/core/models/service_provider_models.dart';

/// Order Management Screen for Service Provider
/// Shows all orders in tab-based view: নতুন | প্রক্রিয়াধীন | সম্পন্ন | বাতিল
class ServiceProviderOrdersScreen extends ConsumerStatefulWidget {
  const ServiceProviderOrdersScreen({super.key});

  @override
  ConsumerState<ServiceProviderOrdersScreen> createState() => _ServiceProviderOrdersScreenState();
}

class _ServiceProviderOrdersScreenState extends ConsumerState<ServiceProviderOrdersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allOrders = ref.watch(serviceOrderProvider);

    final pendingOrders = allOrders.where((o) => o.status == ServiceOrderStatus.pending || o.status == ServiceOrderStatus.accepted).toList();
    final processingOrders = allOrders.where((o) => o.status == ServiceOrderStatus.processing).toList();
    final deliveredOrders = allOrders.where((o) => o.status == ServiceOrderStatus.delivered).toList();
    final cancelledOrders = allOrders.where((o) => o.status == ServiceOrderStatus.cancelled).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF4527A0),
        title: Text('অর্ডার ব্যবস্থাপনা', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
        iconTheme: const IconThemeData(color: Colors.white),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13),
          unselectedLabelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w400, fontSize: 12),
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          tabs: [
            Tab(text: 'নতুন (${pendingOrders.length})'),
            Tab(text: 'চলমান (${processingOrders.length})'),
            Tab(text: 'সম্পন্ন (${deliveredOrders.length})'),
            Tab(text: 'বাতিল (${cancelledOrders.length})'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOrderList(pendingOrders, 'নতুন অর্ডার নেই', 'কৃষকরা অর্ডার করলে এখানে দেখতে পাবেন'),
          _buildOrderList(processingOrders, 'প্রক্রিয়াধীন অর্ডার নেই', 'অর্ডার গ্রহণ করলে এখানে আসবে'),
          _buildOrderList(deliveredOrders, 'সম্পন্ন অর্ডার নেই', 'বিতরণ সম্পন্ন অর্ডার এখানে দেখাবে'),
          _buildOrderList(cancelledOrders, 'বাতিল অর্ডার নেই', 'বাতিল করা অর্ডার এখানে দেখাবে'),
        ],
      ),
    );
  }

  Widget _buildOrderList(List<ServiceOrder> orders, String emptyTitle, String emptySubtitle) {
    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_rounded, size: 70, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(emptyTitle, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey.shade600)),
            const SizedBox(height: 6),
            Text(emptySubtitle, style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade400)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      itemBuilder: (context, index) => _buildDetailedOrderCard(orders[index]),
    );
  }

  Widget _buildDetailedOrderCard(ServiceOrder order) {
    final statusColors = {
      ServiceOrderStatus.pending: Colors.orange,
      ServiceOrderStatus.accepted: Colors.blue,
      ServiceOrderStatus.processing: Colors.indigo,
      ServiceOrderStatus.delivered: Colors.green,
      ServiceOrderStatus.cancelled: Colors.red,
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 3)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status bar
            Container(height: 4, color: statusColors[order.status]),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Order ID and Status
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        order.id,
                        style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF4527A0)),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColors[order.status]!.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          order.status.bengaliName,
                          style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: statusColors[order.status]),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Farmer Info
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: const Color(0xFF4527A0).withValues(alpha: 0.1),
                        child: const Icon(Icons.person, color: Color(0xFF4527A0), size: 20),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(order.farmerName, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600)),
                            Text(order.farmerPhone, style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade600)),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.phone_rounded, color: Color(0xFF4527A0)),
                        onPressed: () {
                          Get.snackbar('কল', '${order.farmerName} কে কল করা হচ্ছে...');
                        },
                      ),
                    ],
                  ),
                  const Divider(height: 24),

                  // Order Items
                  Text('অর্ডারকৃত পণ্য:', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey.shade700)),
                  const SizedBox(height: 8),
                  ...order.items.map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${item.productName} × ${item.quantity} ${item.unit}',
                          style: GoogleFonts.poppins(fontSize: 13),
                        ),
                        Text(
                          '৳ ${item.totalPrice.toStringAsFixed(0)}',
                          style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  )),
                  const Divider(height: 16),

                  // Total
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('মোট:', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold)),
                      Text(
                        '৳ ${order.totalAmount.toStringAsFixed(0)}',
                        style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green.shade700),
                      ),
                    ],
                  ),

                  // Delivery Address
                  if (order.deliveryAddress != null) ...[
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(Icons.location_on_rounded, size: 16, color: Colors.grey.shade500),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            order.deliveryAddress!,
                            style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade600),
                          ),
                        ),
                      ],
                    ),
                  ],

                  // Note
                  if (order.note != null) ...[
                    const SizedBox(height: 6),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.amber.shade100),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.note_rounded, size: 16, color: Colors.amber.shade700),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              order.note!,
                              style: GoogleFonts.poppins(fontSize: 12, color: Colors.amber.shade900),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // Action Buttons
                  if (order.status == ServiceOrderStatus.pending) ...[
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              ref.read(serviceOrderProvider.notifier).cancelOrder(order.id);
                            },
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              side: BorderSide(color: Colors.red.shade300),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            child: Text('বাতিল করুন', style: GoogleFonts.poppins(color: Colors.red, fontWeight: FontWeight.w600)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            onPressed: () {
                              ref.read(serviceOrderProvider.notifier).updateOrderStatus(order.id, ServiceOrderStatus.accepted);
                              Get.snackbar('অর্ডার গৃহীত', '${order.farmerName} এর অর্ডার সফলভাবে গ্রহণ করা হয়েছে!',
                                backgroundColor: Colors.green.shade700, colorText: Colors.white);
                            },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              backgroundColor: const Color(0xFF4527A0),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            child: Text('অর্ডার গ্রহণ করুন', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
                          ),
                        ),
                      ],
                    ),
                  ],

                  if (order.status == ServiceOrderStatus.accepted) ...[
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          ref.read(serviceOrderProvider.notifier).updateOrderStatus(order.id, ServiceOrderStatus.processing);
                        },
                        icon: const Icon(Icons.local_shipping_rounded, color: Colors.white),
                        label: Text('ডেলিভারিতে পাঠান', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          backgroundColor: Colors.indigo,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                  ],

                  if (order.status == ServiceOrderStatus.processing) ...[
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          ref.read(serviceOrderProvider.notifier).updateOrderStatus(order.id, ServiceOrderStatus.delivered);
                          Get.snackbar('বিতরণ সম্পন্ন', 'অর্ডারটি সফলভাবে বিতরণ হয়েছে!',
                            backgroundColor: Colors.green.shade700, colorText: Colors.white);
                        },
                        icon: const Icon(Icons.check_circle_rounded, color: Colors.white),
                        label: Text('বিতরণ সম্পন্ন', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          backgroundColor: Colors.green.shade700,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
