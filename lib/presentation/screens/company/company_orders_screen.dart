import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:provider/provider.dart';
import 'package:agrolinkbd/presentation/screens/company/providers/company_provider.dart';

/// Company Orders Management Screen
/// Create, manage, and track bulk orders
class CompanyOrdersScreen extends StatefulWidget {
  const CompanyOrdersScreen({super.key});

  @override
  State<CompanyOrdersScreen> createState() => _CompanyOrdersScreenState();
}

class _CompanyOrdersScreenState extends State<CompanyOrdersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CompanyProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          backgroundColor: const Color(0xFFFAFAFA),
          appBar: AppBar(
            backgroundColor: const Color(0xFF4169E1),
            elevation: 0,
            title: Text(
              'অর্ডার ব্যবস্থাপনা',
              style: GoogleFonts.openSans(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.menu, color: Colors.white),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.add_circle_outline),
                onPressed: () {
                  // Create new order
                },
              ),
            ],
          ),
          body: Column(
            children: [
              // Search bar
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'অর্ডার অনুসন্ধান করুন...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  ),
                ),
              ),

              // Tabs
              TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(
                    text: 'সক্রিয়',
                    icon: Icon(Icons.hourglass_empty),
                  ),
                  Tab(
                    text: 'ডেলিভারিযুক্ত',
                    icon: Icon(Icons.check_circle),
                  ),
                  Tab(
                    text: 'বাতিল',
                    icon: Icon(Icons.cancel),
                  ),
                  Tab(
                    text: 'সমস্ত',
                    icon: Icon(Icons.list),
                  ),
                ],
              ),

              // Tab content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildOrdersList(provider, status: 'active'),
                    _buildOrdersList(provider, status: 'delivered'),
                    _buildOrdersList(provider, status: 'cancelled'),
                    _buildOrdersList(provider, status: 'all'),
                  ],
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: const Color(0xFF4169E1),
            onPressed: () {
              // Create new order
            },
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }

  Widget _buildOrdersList(CompanyProvider provider, {required String status}) {
    List<CompanyOrder> filteredOrders = provider.orders;
    if (status != 'all') {
      filteredOrders = provider.orders.where((o) => o.status == status).toList();
    }

    if (filteredOrders.isEmpty) {
      return const Center(child: Text("কোনো অর্ডার পাওয়া যায়নি"));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredOrders.length,
      itemBuilder: (context, index) {
        final order = filteredOrders[index];
        return _buildOrderCard(
          orderId: order.id,
          farmer: order.farmerName,
          items: order.items,
          amount: order.amount,
          status: order.status,
          date: order.date,
          onComplete: order.status == 'active' ? () {
            provider.completeOrder(order.id);
          } : null,
        );
      },
    );
  }

  Widget _buildOrderCard({
    required String orderId,
    required String farmer,
    required String items,
    required String amount,
    required String status,
    required String date,
    VoidCallback? onComplete,
  }) {
    Color statusColor;
    String statusLabel;

    switch (status) {
      case 'active':
        statusColor = const Color(0xFFFFA500);
        statusLabel = 'চলমান';
        break;
      case 'delivered':
        statusColor = const Color(0xFF2ECC71);
        statusLabel = 'ডেলিভার করা';
        break;
      case 'cancelled':
        statusColor = const Color(0xFFE74C3C);
        statusLabel = 'বাতিল';
        break;
      default:
        statusColor = const Color(0xFF999999);
        statusLabel = 'অজানা';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                orderId,
                style: GoogleFonts.openSans(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1A1A1A),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  statusLabel,
                  style: GoogleFonts.openSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            farmer,
            style: GoogleFonts.openSans(
              fontSize: 12,
              color: const Color(0xFF999999),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            items,
            style: GoogleFonts.openSans(
              fontSize: 12,
              color: const Color(0xFF666666),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                amount,
                style: GoogleFonts.openSans(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1A1A1A),
                ),
              ),
              Text(
                date,
                style: GoogleFonts.openSans(
                  fontSize: 11,
                  color: const Color(0xFFCCCCCC),
                ),
              ),
            ],
          ),
          if (onComplete != null) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onComplete,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2ECC71),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                child: const Text('ডেলিভারি নিশ্চিত করুন', style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
