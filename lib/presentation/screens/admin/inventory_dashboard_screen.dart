import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:agrolinkbd/core/providers/admin_provider.dart';

class InventoryDashboardScreen extends StatefulWidget {
  const InventoryDashboardScreen({super.key});

  @override
  State<InventoryDashboardScreen> createState() => _InventoryDashboardScreenState();
}

class _InventoryDashboardScreenState extends State<InventoryDashboardScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLightMode = false;
  String _searchQuery = '';

  Color get _bgColor => _isLightMode ? const Color(0xFFF3F4F6) : const Color(0xFF0B0F19);
  Color get _textColor => _isLightMode ? const Color(0xFF1F2937) : Colors.white;
  Color get _cardColor => _isLightMode ? Colors.white.withOpacity(0.7) : Colors.white.withOpacity(0.03);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      body: SafeArea(
        child: Stack(
          children: [
            // Ambient glowing background
            Positioned(top: -100, left: -100, child: Container(width: 300, height: 300, decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFF059669).withOpacity(_isLightMode ? 0.2 : 0.15)))),
            Positioned(bottom: -150, right: -50, child: Container(width: 400, height: 400, decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFF3B82F6).withOpacity(_isLightMode ? 0.2 : 0.1)))),
            BackdropFilter(filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60), child: Container(color: Colors.transparent)),
            
            Column(
              children: [
                _buildHeader(),
                Expanded(child: _buildInventoryList()),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showProductModal(),
        backgroundColor: const Color(0xFF10B981),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Product', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  IconButton(icon: Icon(Icons.arrow_back_ios_new_rounded, color: _textColor), onPressed: () => Get.back()),
                  Text('Inventory', style: TextStyle(color: _textColor, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
                ],
              ),
              GestureDetector(
                onTap: () => setState(() => _isLightMode = !_isLightMode),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: _cardColor, borderRadius: BorderRadius.circular(12), border: Border.all(color: _textColor.withOpacity(0.1))),
                  child: Icon(_isLightMode ? Icons.dark_mode_rounded : Icons.light_mode_rounded, color: _textColor, size: 20),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: TextField(
                onChanged: (val) => setState(() => _searchQuery = val.toLowerCase()),
                style: TextStyle(color: _textColor),
                decoration: InputDecoration(
                  hintText: 'Search by SKU or Title...',
                  hintStyle: TextStyle(color: _textColor.withOpacity(0.5)),
                  prefixIcon: Icon(Icons.search_rounded, color: _textColor.withOpacity(0.7)),
                  filled: true,
                  fillColor: _cardColor,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInventoryList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('inventory_products').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: Color(0xFF10B981)));
        
        var products = snapshot.data!.docs;
        if (_searchQuery.isNotEmpty) {
          products = products.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final title = (data['title'] ?? '').toString().toLowerCase();
            final sku = (data['sku'] ?? '').toString().toLowerCase();
            return title.contains(_searchQuery) || sku.contains(_searchQuery);
          }).toList();
        }

        if (products.isEmpty) {
          return Center(child: Text('No products found', style: TextStyle(color: _textColor.withOpacity(0.5))));
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          itemCount: products.length,
          itemBuilder: (context, index) {
            final doc = products[index];
            final data = doc.data() as Map<String, dynamic>;
            return _buildProductCard(doc.id, data);
          },
        );
      },
    );
  }

  Widget _buildProductCard(String id, Map<String, dynamic> data) {
    final title = data['title'] ?? 'Unknown';
    final price = data['price'] ?? 0.0;
    final stock = data['stockQuantity'] ?? 0;
    final lowStock = data['lowStockThreshold'] ?? 5;
    final sku = data['sku'] ?? 'N/A';
    
    final isLowStock = stock <= lowStock;
    final stockColor = isLowStock ? Colors.redAccent : const Color(0xFF10B981);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(color: _cardColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: _textColor.withOpacity(0.05))),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  width: 50, height: 50,
                  decoration: BoxDecoration(color: const Color(0xFF3B82F6).withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.inventory_2_rounded, color: Color(0xFF3B82F6)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: TextStyle(color: _textColor, fontWeight: FontWeight.bold, fontSize: 16)),
                      Text('SKU: $sku  •  ৳$price', style: TextStyle(color: _textColor.withOpacity(0.6), fontSize: 12)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('Stock', style: TextStyle(color: _textColor.withOpacity(0.5), fontSize: 10)),
                    Text('$stock', style: TextStyle(color: stockColor, fontWeight: FontWeight.w900, fontSize: 18)),
                  ],
                ),
                const SizedBox(width: 12),
                IconButton(
                  icon: const Icon(Icons.edit_rounded, color: Colors.amber),
                  onPressed: () => _showProductModal(docId: id, data: data),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showProductModal({String? docId, Map<String, dynamic>? data}) {
    final titleCtrl = TextEditingController(text: data?['title']);
    final descCtrl = TextEditingController(text: data?['description']);
    final priceCtrl = TextEditingController(text: data?['price']?.toString());
    final stockCtrl = TextEditingController(text: data?['stockQuantity']?.toString());
    final threshCtrl = TextEditingController(text: data?['lowStockThreshold']?.toString() ?? '5');
    final skuCtrl = TextEditingController(text: data?['sku']);

    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(color: _bgColor, borderRadius: const BorderRadius.vertical(top: Radius.circular(30))),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(docId == null ? 'Add Product' : 'Edit Product', style: TextStyle(color: _textColor, fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              _buildTextField(titleCtrl, 'Product Title'),
              _buildTextField(descCtrl, 'Description'),
              _buildTextField(skuCtrl, 'SKU Code'),
              Row(
                children: [
                  Expanded(child: _buildTextField(priceCtrl, 'Price (৳)', isNumber: true)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildTextField(stockCtrl, 'Initial Stock', isNumber: true)),
                ],
              ),
              _buildTextField(threshCtrl, 'Low Stock Threshold', isNumber: true),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  final payload = {
                    'title': titleCtrl.text,
                    'description': descCtrl.text,
                    'sku': skuCtrl.text,
                    'price': double.tryParse(priceCtrl.text) ?? 0.0,
                    'stockQuantity': int.tryParse(stockCtrl.text) ?? 0,
                    'lowStockThreshold': int.tryParse(threshCtrl.text) ?? 5,
                    'updatedAt': FieldValue.serverTimestamp(),
                  };
                  
                  if (docId == null) {
                    payload['createdAt'] = FieldValue.serverTimestamp();
                    await _firestore.collection('inventory_products').add(payload);
                  } else {
                    await _firestore.collection('inventory_products').doc(docId).update(payload);
                  }

                  // Log action
                  final provider = Provider.of<AdminProvider>(context, listen: false);
                  provider.logAdminAction('INVENTORY_UPDATE', 'Admin updated product: ${titleCtrl.text}');

                  Get.back();
                  Get.snackbar('Success', 'Product saved successfully!', backgroundColor: Colors.green, colorText: Colors.white);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Save Product', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              )
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        style: TextStyle(color: _textColor),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: _textColor.withOpacity(0.5)),
          filled: true,
          fillColor: _cardColor,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        ),
      ),
    );
  }
}
