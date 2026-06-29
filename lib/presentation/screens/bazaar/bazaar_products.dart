import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:agrolinkbd/core/services/sslcommerz_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:agrolinkbd/core/providers/user_provider.dart';
import 'dart:io';

class BazaarProducts extends StatefulWidget {
  final String category; // 'vegetables', 'fruits', 'spices'

  const BazaarProducts({super.key, required this.category});

  @override
  State<BazaarProducts> createState() => _BazaarProductsState();
}

String _getCategoryName(String key) {
  switch (key) {
    case 'vegetables':
      return 'Vegetables';
    case 'fruits':
      return 'Fruits';
    case 'spices':
      return 'Spices';
    default:
      return key;
  }
}

class _BazaarProductsState extends State<BazaarProducts> {
  List<Map<String, dynamic>> _products = [];
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _imagePicker = ImagePicker();
  late String _userId;
  bool _isLoading = true;
  File? _selectedImage;
  String? _editingProductId;

  @override
  void initState() {
    super.initState();
    _initializeUser();
  }

  void _initializeUser() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    _userId = userProvider.currentUser?.id ??
        FirebaseAuth.instance.currentUser?.uid ??
        '';
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    if (_userId.isEmpty) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final querySnapshot = await _firestore
          .collection('bazaar_products')
          .where('userId', isEqualTo: _userId)
          .where('category', isEqualTo: widget.category)
          .get();

      setState(() {
        _products = querySnapshot.docs.map((doc) {
          final data = doc.data();
          data['id'] = doc.id;
          return data;
        }).toList();
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading products: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 800,
        maxHeight: 800,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error picking image: $e')));
    }
  }

  void _showAddProductDialog({Map<String, dynamic>? product}) {
    _editingProductId = product?['id'];
    _nameController.text = product?['name'] ?? '';
    _priceController.text = product?['price']?.toString() ?? '';
    _quantityController.text = product?['quantity']?.toString() ?? '';
    _selectedImage = null;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
          title: Text(
            product != null ? 'Edit Product' : 'Add Product',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Image Preview
                Container(
                  width: double.infinity,
                  height: 150,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Theme.of(context).primaryColor.withOpacity(0.3),
                    ),
                  ),
                  child: _selectedImage != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.file(_selectedImage!, fit: BoxFit.cover),
                        )
                      : (product?['imageUrl'] != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(
                                product!['imageUrl'],
                                fit: BoxFit.cover,
                              ),
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.image_outlined,
                                  size: 48,
                                  color: Theme.of(context).primaryColor,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'No image selected',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.bodySmall,
                                ),
                              ],
                            )),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () async {
                    await _pickImage();
                    setDialogState(() {});
                  },
                  icon: const Icon(Icons.photo_camera),
                  label: const Text('Choose Image'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Product Name',
                    prefixIcon: Icon(
                      Icons.shopping_bag,
                      color: Theme.of(context).primaryColor,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _priceController,
                  decoration: InputDecoration(
                    labelText: 'Price (per unit)',
                    prefixIcon: Icon(
                      Icons.currency_pound,
                      color: Theme.of(context).primaryColor,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _quantityController,
                  decoration: InputDecoration(
                    labelText: 'Quantity',
                    prefixIcon: Icon(
                      Icons.inventory_2,
                      color: Theme.of(context).primaryColor,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                _selectedImage = null;
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                await _saveProduct(context);
              },
              child: Text(product != null ? 'Update' : 'Add'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveProduct(BuildContext dialogContext) async {
    if (_nameController.text.isEmpty ||
        _priceController.text.isEmpty ||
        _quantityController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
      return;
    }

    try {
      String? imageUrl;

      // Upload image if selected (new image)
      if (_selectedImage != null) {
        final fileName =
            'bazaar_${_userId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final storageRef = _storage.ref().child('bazaar_products/$fileName');

        await storageRef.putFile(_selectedImage!);
        imageUrl = await storageRef.getDownloadURL();
        debugPrint('✅ Image uploaded: $imageUrl');
      }

      final productData = {
        'userId': _userId,
        'name': _nameController.text.trim(),
        'price': double.parse(_priceController.text),
        'quantity': int.parse(_quantityController.text),
        'category': widget.category,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // Add imageUrl if available (new upload only)
      if (imageUrl != null) {
        productData['imageUrl'] = imageUrl;
      }

      if (_editingProductId != null) {
        // Update existing product
        await _firestore
            .collection('bazaar_products')
            .doc(_editingProductId)
            .update(productData);
        debugPrint('✅ Product updated: $_editingProductId');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product updated successfully')),
        );
      } else {
        // Add new product
        productData['createdAt'] = FieldValue.serverTimestamp();
        final docRef =
            await _firestore.collection('bazaar_products').add(productData);
        debugPrint('✅ Product added: ${docRef.id}');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product added successfully')),
        );
      }

      _editingProductId = null;
      _selectedImage = null;
      Navigator.pop(dialogContext);
      _loadProducts();
    } catch (e) {
      debugPrint('❌ Error saving product: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error saving product: $e')));
    }
  }

  void _deleteProduct(String productId, String? imageUrl) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: const Text('Delete Product'),
        content: const Text('Are you sure you want to delete this product?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                // Delete image from storage if exists
                if (imageUrl != null && imageUrl.isNotEmpty) {
                  try {
                    await _storage.refFromURL(imageUrl).delete();
                  } catch (e) {
                    debugPrint('Error deleting image: $e');
                  }
                }

                // Delete product from Firestore
                await _firestore
                    .collection('bazaar_products')
                    .doc(productId)
                    .delete();

                Navigator.pop(context);
                _loadProducts();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Product deleted')),
                );
              } catch (error) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error deleting product: $error')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Dark theme background
      appBar: AppBar(
        title: Text(
          _getCategoryName(widget.category),
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart_outlined, color: Colors.white),
                onPressed: () {
                  // Navigate to cart
                },
              ),
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.orange,
                    shape: BoxShape.circle,
                  ),
                  child: const Text(
                    '0',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _products.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.shopping_basket_outlined,
                        size: 64,
                        color: Theme.of(context).primaryColor.withOpacity(0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No products added yet',
                        style: Theme.of(
                          context,
                        ).textTheme.bodyLarge?.copyWith(color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _products.length,
                  itemBuilder: (context, index) {
                    final product = _products[index];
                    final price = (product['price'] as num).toStringAsFixed(2);
                    final quantity = product['quantity'] ?? 0;
                    final imageUrl = product['imageUrl'];
                    final name = product['name'] ?? 'Unknown Product';

                    // Internal state for quantity selector (mocking the UI state)
                    int selectedQuantity = 1;

                    return StatefulBuilder(
                      builder: (context, setState) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 20),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.15),
                                    width: 1.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.white.withOpacity(0.02),
                                      blurRadius: 20,
                                      spreadRadius: -5,
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Product Thumbnail
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(12),
                                          child: imageUrl != null && imageUrl.isNotEmpty
                                              ? Image.network(
                                                  imageUrl,
                                                  height: 80,
                                                  width: 80,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (context, error, stackTrace) => _buildPlaceholderImage(),
                                                )
                                              : _buildPlaceholderImage(),
                                        ),
                                        const SizedBox(width: 16),
                                        // Product Details
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      name,
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 18,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                  // Edit and Delete Buttons for Farmer
                                                  Row(
                                                    children: [
                                                      IconButton(
                                                        padding: EdgeInsets.zero,
                                                        constraints: const BoxConstraints(),
                                                        icon: const Icon(Icons.edit, color: Colors.amber, size: 20),
                                                        onPressed: () {
                                                          _showAddProductDialog(product: product);
                                                        },
                                                      ),
                                                      const SizedBox(width: 8),
                                                      IconButton(
                                                        padding: EdgeInsets.zero,
                                                        constraints: const BoxConstraints(),
                                                        icon: const Icon(Icons.delete, color: Colors.redAccent, size: 20),
                                                        onPressed: () {
                                                          _deleteProduct(product['id'] as String, imageUrl);
                                                        },
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                'Price: ৳$price | Qty: $quantity Available',
                                                style: TextStyle(
                                                  color: Colors.white.withOpacity(0.7),
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 20),
                                    // Action Area
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        // Quantity Selector
                                        Container(
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(30),
                                          ),
                                          child: Row(
                                            children: [
                                              IconButton(
                                                icon: const Icon(Icons.remove, color: Colors.white, size: 18),
                                                onPressed: () {
                                                  if (selectedQuantity > 1) {
                                                    setState(() => selectedQuantity--);
                                                  }
                                                },
                                              ),
                                              Text(
                                                '$selectedQuantity',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                ),
                                              ),
                                              IconButton(
                                                icon: const Icon(Icons.add, color: Colors.white, size: 18),
                                                onPressed: () {
                                                  if (selectedQuantity < quantity) {
                                                    setState(() => selectedQuantity++);
                                                  }
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                        // Buttons Area
                                        Expanded(
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.end,
                                            children: [
                                              ElevatedButton.icon(
                                                onPressed: () {
                                                  // Handle add to cart
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    SnackBar(content: Text('Added $selectedQuantity $name to cart')),
                                                  );
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.orange.shade600,
                                                  foregroundColor: Colors.white,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(30),
                                                  ),
                                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                                                  elevation: 5,
                                                  shadowColor: Colors.orange.withOpacity(0.5),
                                                ),
                                                icon: const Icon(Icons.shopping_cart, size: 16),
                                                label: const Text(
                                                  'Add',
                                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              ElevatedButton(
                                                onPressed: () {
                                                  SSLCommerzService.initiatePayment(
                                                    context: context,
                                                    amount: double.tryParse(price) ?? 0.0 * selectedQuantity,
                                                    productName: name,
                                                    customerName: "Buyer User",
                                                    customerEmail: "buyer@example.com",
                                                    customerPhone: "01700000000",
                                                    customerAddress: "Dhaka, Bangladesh",
                                                  );
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: const Color(0xFF1976D2),
                                                  foregroundColor: Colors.white,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(30),
                                                  ),
                                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                                                  elevation: 5,
                                                ),
                                                child: const Text(
                                                  'Order',
                                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _nameController.clear();
          _priceController.clear();
          _quantityController.clear();
          _selectedImage = null;
          _editingProductId = null;
          _showAddProductDialog();
        },
        backgroundColor: Colors.amber,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.add, color: Colors.black, size: 28),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      height: 80,
      width: 80,
      color: Colors.white.withOpacity(0.1),
      child: const Icon(
        Icons.image,
        color: Colors.white54,
        size: 30,
      ),
    );
  }
}
