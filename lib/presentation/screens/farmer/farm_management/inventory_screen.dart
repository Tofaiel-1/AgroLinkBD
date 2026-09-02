import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:agrolinkbd/core/models/phase2_models/farm_models.dart';
import 'package:agrolinkbd/core/services/phase2_services/farm_service.dart';
import 'package:agrolinkbd/core/providers/language_provider.dart';
import 'add_edit_inventory_item_screen.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({Key? key}) : super(key: key);

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  final FarmService _farmService = FarmService();
  late Stream<List<FarmInventoryItem>> _inventoryStream;

  @override
  void initState() {
    super.initState();
    _inventoryStream = _farmService.getInventoryStream();
  }

  String _getCategoryName(String category, bool isBn) {
    if (!isBn) return category;
    switch (category) {
      case 'Fertilizer': return 'সার';
      case 'Seeds': return 'বীজ ও চারা';
      case 'Chemicals': return 'কীটনাশক ও বালাইনাশক';
      case 'Fuel': return 'জ্বালানি';
      case 'Equipment': return 'যন্ত্রপাতি';
      default: return 'অন্যান্য';
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isBn = LanguageProvider.isBn(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF795548),
        elevation: 0,
        title: Text(
          isBn ? 'মালামাল ও মজুত (স্টক)' : 'Inventory & Stock Management',
          style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<List<FarmInventoryItem>>(
        stream: _inventoryStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF795548)));
          }

          final items = snapshot.data ?? [];
          
          final totalItems = items.length;
          final categories = items.map((i) => i.category).toSet().length;
          final lowStock = items.where((i) => i.quantity < 10).length;

          return CustomScrollView(
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
                      _buildStat(isBn ? 'মোট মালামাল' : 'Total Items', totalItems.toString()),
                      _buildStat(isBn ? 'ক্যাটাগরি' : 'Categories', categories.toString()),
                      _buildStat(isBn ? 'স্বল্প স্টক' : 'Low Stock', lowStock.toString()),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver: SliverList(
                  delegate: SliverChildListDelegate(
                    items.isEmpty
                        ? [
                            Padding(
                              padding: const EdgeInsets.all(32.0),
                              child: Center(
                                child: Text(
                                  isBn ? 'ইনভেন্টরিতে কোনো মালামাল নেই' : 'No items in inventory',
                                  style: GoogleFonts.hindSiliguri(color: Colors.grey, fontSize: 16),
                                ),
                              ),
                            )
                          ]
                        : items.map((item) => _buildInventoryCard(item, isBn)).toList(),
                  ),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddEditInventoryItemScreen()),
          );
        },
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
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.hindSiliguri(
            color: Colors.white.withValues(alpha: 0.8),
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _buildInventoryCard(FarmInventoryItem item, bool isBn) {
    String status = 'In Stock';
    if (item.quantity <= 0) {
      status = isBn ? 'স্টক শেষ' : 'Out of Stock';
    } else if (item.quantity < 10) {
      status = isBn ? 'স্বল্প স্টক' : 'Low Stock';
    } else {
      status = isBn ? 'স্টকে আছে' : 'In Stock';
    }

    final color = item.quantity <= 0 ? Colors.red : (item.quantity < 10 ? Colors.orange : Colors.green);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFCBD5E1).withValues(alpha: 0.3),
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
                  item.name,
                  style: GoogleFonts.hindSiliguri(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: const Color(0xFF2D3748),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getCategoryName(item.category, isBn),
                  style: GoogleFonts.hindSiliguri(
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
                '${item.quantity.toStringAsFixed(1)} ${item.unit}',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                  color: const Color(0xFF2D3748),
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  status,
                  style: GoogleFonts.hindSiliguri(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: color,
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
