import sys

def apply_orders_screen():
    with open('lib/presentation/screens/buyer/buyer_orders_screen.dart', 'r', encoding='utf-8') as f:
        content = f.read()

    # 1. Imports
    if 'import \'package:agrolinkbd/core/models/order_model.dart\';' not in content:
        content = content.replace(
            'import \'package:flutter/material.dart\';',
            'import \'package:flutter/material.dart\';\nimport \'package:agrolinkbd/core/models/order_model.dart\';\nimport \'package:agrolinkbd/core/services/order_service.dart\';\nimport \'package:firebase_auth/firebase_auth.dart\';\nimport \'dart:math\';'
        )

    # 2. Font
    content = content.replace('GoogleFonts.poppins', 'GoogleFonts.hindSiliguri')

    # 3. Flexible Tabs
    content = content.replace(
        "const Icon(Icons.pending_actions, size: 18),\n                                const SizedBox(width: 6),\n                                const Text('সক্রিয়'),",
        "const Icon(Icons.pending_actions, size: 16),\n                                const SizedBox(width: 4),\n                                const Flexible(child: Text('সক্রিয়', overflow: TextOverflow.ellipsis)),"
    )
    content = content.replace(
        "const Icon(Icons.history, size: 18),\n                                const SizedBox(width: 6),\n                                const Text('অতীত'),",
        "const Icon(Icons.history, size: 16),\n                                const SizedBox(width: 4),\n                                const Flexible(child: Text('অতীত', overflow: TextOverflow.ellipsis)),"
    )

    # 4. StreamBuilder instead of setState/initState logic
    target_tabview = '''Expanded(
                        child: TabBarView(
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
                        ),
                      ),'''

    replacement_tabview = '''Expanded(
                        child: StreamBuilder<List<OrderModel>>(
                          stream: OrderService().streamUserOrders(FirebaseAuth.instance.currentUser?.uid ?? ''),
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
                      ),'''
    
    content = content.replace(target_tabview, replacement_tabview)

    # 5. OrderCards definitions
    content = content.replace("Widget _buildActiveOrderCard(Map<String, dynamic> order, bool isDark) {", "Widget _buildActiveOrderCard(OrderModel order, bool isDark) {")
    content = content.replace("final statusStep = order['statusStep'] as int;", "final statusStep = order.statusStep;")
    
    # Active Card Text Replaces
    content = content.replace("order['id']", ''' '#ORD-${order.id.substring(0, min(6, order.id.length))}' ''')
    content = content.replace("order['status']", "order.status")
    content = content.replace("order['date']", ''' '${order.createdAt.day}/${order.createdAt.month}/${order.createdAt.year}' ''')
    content = content.replace("order['farmer']", "order.farmerName")
    content = content.replace("order['items']", ''' '${order.productName} (${order.quantity})' ''')
    content = content.replace("order['total']", ''' '৳${order.totalAmount}' ''')
    
    content = content.replace("const SizedBox(height: 16),\n\n          // Status tracker", '''const SizedBox(height: 8),
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

            // Status tracker''')

    # Past Card Definitions
    content = content.replace("Widget _buildPastOrderCard(Map<String, dynamic> order, bool isDark) {", "Widget _buildPastOrderCard(OrderModel order, bool isDark) {")
    
    # Inject Rating Dialog
    if 'void _showRatingDialog' not in content:
        rating_code = '''
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
'''
        content = content[:-2] + rating_code

    with open('lib/presentation/screens/buyer/buyer_orders_screen.dart', 'w', encoding='utf-8') as f:
        f.write(content)

apply_orders_screen()
