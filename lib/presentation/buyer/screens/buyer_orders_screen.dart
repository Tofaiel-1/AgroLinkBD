import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:agrolinkbd/core/providers/language_provider.dart';
import 'package:agrolinkbd/presentation/buyer/providers/order_provider.dart';
import 'package:agrolinkbd/presentation/buyer/widgets/order_card.dart';

class BuyerOrdersScreen extends ConsumerStatefulWidget {
  const BuyerOrdersScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<BuyerOrdersScreen> createState() => _BuyerOrdersScreenState();
}

class _BuyerOrdersScreenState extends ConsumerState<BuyerOrdersScreen>
    with TickerProviderStateMixin {
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
    final isBn = LanguageProvider.isBn(context);
    final activeOrders = ref.watch(activeOrdersProvider);
    final completedOrders = ref.watch(completedOrdersProvider);
    final cancelledOrders = ref.watch(cancelledOrdersProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(isBn ? 'আমার অর্ডার' : 'My Orders'),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: isBn ? 'সক্রিয়' : 'Active'),
            Tab(text: isBn ? 'সম্পন্ন' : 'Completed'),
            Tab(text: isBn ? 'বাতিল' : 'Cancelled'),
            Tab(text: isBn ? 'রিটার্ন' : 'Returns'),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(buyerOrdersProvider);
          return Future.value();
        },
        child: TabBarView(
          controller: _tabController,
          children: [
            // Active orders
            activeOrders.when(
              data: (orders) => orders.isEmpty
                  ? Center(child: Text(isBn ? 'কোন সক্রিয় অর্ডার নেই' : 'No active orders'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: orders.length,
                      itemBuilder: (context, index) {
                        final order = orders[index];
                        return OrderCard(
                          orderId: order.id,
                          status: order.orderStatus,
                          statusBN: order.getStatusBN(),
                          orderDate: order.createdAt,
                          farmerName: order.farmerName,
                          totalAmount: order.totalAmount,
                          itemCount: order.items.length,
                          onTap: () {},
                          onTrackOrder: () {
                            Navigator.pushNamed(context, '/buyer/track-order',
                                arguments: order.id);
                          },
                          onCancel: () {},
                        );
                      },
                    ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(child: Text('Error: $error')),
            ),
            // Completed orders
            completedOrders.when(
              data: (orders) => orders.isEmpty
                  ? Center(child: Text(isBn ? 'কোন সম্পন্ন অর্ডার নেই' : 'No completed orders'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: orders.length,
                      itemBuilder: (context, index) {
                        final order = orders[index];
                        return OrderCard(
                          orderId: order.id,
                          status: order.orderStatus,
                          statusBN: order.getStatusBN(),
                          orderDate: order.createdAt,
                          farmerName: order.farmerName,
                          totalAmount: order.totalAmount,
                          itemCount: order.items.length,
                          onTap: () {},
                        );
                      },
                    ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(child: Text('Error: $error')),
            ),
            // Cancelled orders
            cancelledOrders.when(
              data: (orders) => orders.isEmpty
                  ? Center(child: Text(isBn ? 'কোন বাতিল অর্ডার নেই' : 'No cancelled orders'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: orders.length,
                      itemBuilder: (context, index) {
                        final order = orders[index];
                        return OrderCard(
                          orderId: order.id,
                          status: order.orderStatus,
                          statusBN: order.getStatusBN(),
                          orderDate: order.createdAt,
                          farmerName: order.farmerName,
                          totalAmount: order.totalAmount,
                          itemCount: order.items.length,
                          onTap: () {},
                        );
                      },
                    ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(child: Text('Error: $error')),
            ),
            // Return orders
            Center(child: Text(isBn ? 'কোন রিটার্ন অর্ডার নেই' : 'No return orders')),
          ],
        ),
      ),
    );
  }
}
