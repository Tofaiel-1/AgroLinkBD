import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class InventoryScreen extends StatelessWidget {
  const InventoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> _inventoryItems = [
      {
        'name': 'Urea Fertilizer',
        'category': 'Fertilizer',
        'quantity': '50 kg',
        'status': 'In Stock',
        'color': Colors.green,
      },
      {
        'name': 'Paddy Seeds (BRRI 28)',
        'category': 'Seeds',
        'quantity': '5 kg',
        'status': 'Low Stock',
        'color': Colors.orange,
      },
      {
        'name': 'Pesticide (Actara)',
        'category': 'Chemicals',
        'quantity': '0 L',
        'status': 'Out of Stock',
        'color': Colors.red,
      },
      {
        'name': 'Tractor Fuel (Diesel)',
        'category': 'Fuel',
        'quantity': '120 L',
        'status': 'In Stock',
        'color': Colors.green,
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF795548),
        elevation: 0,
        title: Text(
          'Inventory Management',
          style: GoogleFonts.openSans(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Color(0xFF795548),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStat('Total Items', '120'),
                  _buildStat('Categories', '5'),
                  _buildStat('Low Stock', '3'),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return _buildInventoryCard(_inventoryItems[index]);
                },
                childCount: _inventoryItems.length,
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: const Color(0xFF795548),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.openSans(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.openSans(
            color: Colors.white.withOpacity(0.8),
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildInventoryCard(Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFCBD5E1).withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(Icons.inventory_2, color: Colors.grey.shade600, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['name'],
                  style: GoogleFonts.openSans(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: const Color(0xFF2D3748),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item['category'],
                  style: GoogleFonts.openSans(
                    fontSize: 13,
                    color: const Color(0xFF718096),
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                item['quantity'],
                style: GoogleFonts.openSans(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: const Color(0xFF2D3748),
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: (item['color'] as Color).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  item['status'],
                  style: GoogleFonts.openSans(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: item['color'],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
