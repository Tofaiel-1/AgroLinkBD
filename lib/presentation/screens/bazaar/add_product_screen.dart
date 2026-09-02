import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:agrolinkbd/core/providers/user_provider.dart';
import 'package:agrolinkbd/core/providers/language_provider.dart';
import 'package:agrolinkbd/core/services/sslcommerz_service.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firestore = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;
  final _imagePicker = ImagePicker();

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _quantityController = TextEditingController();
  final _unitController = TextEditingController(text: 'kg');
  final _locationController = TextEditingController();

  String _selectedCategory = 'vegetables';
  String _selectedTier = 'free'; // 'free', 'urgent', 'featured', 'vip'
  File? _selectedImage;
  bool _isLoading = false;
  late String _userId;

  final List<Map<String, String>> _categories = [
    {'labelEn': 'Vegetables', 'labelBn': 'শাকসবজি', 'value': 'vegetables'},
    {'labelEn': 'Fruits', 'labelBn': 'ফলমূল', 'value': 'fruits'},
    {'labelEn': 'Spices', 'labelBn': 'মসলা', 'value': 'spices'},
    {'labelEn': 'Grains', 'labelBn': 'শস্য ও ধান', 'value': 'grains'},
    {'labelEn': 'Seeds', 'labelBn': 'বীজ', 'value': 'seeds'},
    {'labelEn': 'Tools', 'labelBn': 'কৃষি যন্ত্রপাতি', 'value': 'tools'},
    {'labelEn': 'Other', 'labelBn': 'অন্যান্য', 'value': 'other'},
  ];

  final List<Map<String, String>> _units = [
    {'value': 'kg', 'labelEn': 'kg', 'labelBn': 'কেজি'},
    {'value': 'gram', 'labelEn': 'gram', 'labelBn': 'গ্রাম'},
    {'value': 'piece', 'labelEn': 'piece', 'labelBn': 'পিস'},
    {'value': 'bunch', 'labelEn': 'bunch', 'labelBn': 'মুঠা/আঁটি'},
    {'value': 'dozen', 'labelEn': 'dozen', 'labelBn': 'ডজন'},
    {'value': 'bag', 'labelEn': 'bag', 'labelBn': 'বস্তা'},
  ];

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
  }

  Future<void> _pickImage() async {
    final bool isBn = LanguageProvider.isBn(context);
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1000,
        maxHeight: 1000,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(isBn ? 'ছবি নির্বাচনে সমস্যা: $e' : 'Error picking image: $e')),
        );
      }
    }
  }

  Future<void> _submitForm() async {
    final bool isBn = LanguageProvider.isBn(context);
    if (!_formKey.currentState!.validate()) return;

    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(isBn ? 'অনুগ্রহ করে পণ্যের ছবি নির্বাচন করুন' : 'Please select a product image')),
      );
      return;
    }

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final userModel = userProvider.currentUser;
      final authUser = FirebaseAuth.instance.currentUser;

      double boostPrice = 0.0;
      int boostDays = 0;
      String tierName = 'Boost';
      String boostTxnId = 'BOOST_${DateTime.now().millisecondsSinceEpoch}';

      if (_selectedTier != 'free') {
        if (_selectedTier == 'urgent') {
          boostPrice = 20.0;
          boostDays = 3;
          tierName = 'Urgent Sale Boost (৩ দিন)';
        } else if (_selectedTier == 'featured') {
          boostPrice = 50.0;
          boostDays = 7;
          tierName = 'Premium Featured Lot (৭ দিন)';
        } else if (_selectedTier == 'vip') {
          boostPrice = 100.0;
          boostDays = 15;
          tierName = 'VIP Wholesaler Partner (১৫ দিন)';
        }

        final paymentSuccess = await SSLCommerzService.initiatePayment(
          context: context,
          amount: boostPrice,
          productName: 'পণ্য বুস্টিং: $tierName (${_titleController.text.trim()})',
          customerName: userModel?.name ?? 'Seller User',
          customerEmail: authUser?.email ?? 'seller@agrolinkbd.com',
          customerPhone: userModel?.phone ?? (authUser?.phoneNumber ?? '01700000000'),
          customerAddress: _locationController.text.trim().isNotEmpty
              ? _locationController.text.trim()
              : 'ঢাকা, বাংলাদেশ',
        );

        if (!paymentSuccess) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(isBn ? 'পেমেন্ট সম্পন্ন হয়নি। পণ্য প্রকাশ বাতিল করা হলো।' : 'Payment incomplete. Product publishing cancelled.'),
                backgroundColor: Colors.orange.shade800,
              ),
            );
          }
          return;
        }
      }

      setState(() => _isLoading = true);

      // Upload image to Firebase Storage
      final fileName =
          'products/${_userId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final storageRef = _storage.ref().child(fileName);

      await storageRef.putFile(_selectedImage!);
      final imageUrl = await storageRef.getDownloadURL();

      debugPrint('✅ Image uploaded successfully: $imageUrl');

      final DateTime now = DateTime.now();
      final DateTime? boostExpiresDate = _selectedTier != 'free' ? now.add(Duration(days: boostDays)) : null;

      // Save product to Firestore
      final productData = {
        'sellerId': _userId,
        'userId': _userId,
        'title': _titleController.text.trim(),
        'name': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'price': double.parse(_priceController.text),
        'quantity': double.parse(_quantityController.text),
        'unit': _unitController.text,
        'category': _selectedCategory,
        'location': _locationController.text.trim(),
        'imageUrl': imageUrl,
        'images': [imageUrl],
        'boostTier': _selectedTier,
        'isFeatured': _selectedTier != 'free',
        'boostPaid': _selectedTier != 'free',
        'boostAmount': boostPrice,
        'boostDurationDays': boostDays,
        'boostStatus': _selectedTier != 'free' ? 'active' : 'none',
        'boostPaymentMethod': _selectedTier != 'free' ? 'SSLCommerz' : null,
        'boostTransactionId': _selectedTier != 'free' ? boostTxnId : null,
        'boostExpiresAt': boostExpiresDate != null ? Timestamp.fromDate(boostExpiresDate) : null,
        'createdAt': FieldValue.serverTimestamp(),
        'status': 'available',
        'views': 0,
        'favorites': 0,
      };

      // Save to bazaar_products collection
      final docRef =
          await _firestore.collection('bazaar_products').add(productData);

      // Save boost transaction logs if paid
      if (_selectedTier != 'free') {
        final boostTxnData = {
          'id': boostTxnId,
          'userId': _userId,
          'type': 'debit',
          'amount': boostPrice,
          'title': isBn ? 'পণ্য বুস্টিং ($tierName)' : 'Product Boost ($tierName)',
          'description': 'Product: ${_titleController.text.trim()} (ID: ${docRef.id})',
          'paymentId': boostTxnId,
          'relatedId': docRef.id,
          'relatedType': 'product_boost',
          'status': 'completed',
          'paymentMethod': 'SSLCommerz',
          'createdAt': now.toIso8601String(),
          'timestamp': FieldValue.serverTimestamp(),
        };

        await _firestore.collection('transactions').doc(boostTxnId).set(boostTxnData);
      }

      debugPrint('✅ Product created: ${docRef.id}');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isBn ? 'পণ্যটি সফলভাবে মার্কেটে যোগ করা হয়েছে!' : 'Product added successfully to market!'),
            backgroundColor: const Color(0xFF2E7D32),
          ),
        );

        Navigator.pop(context, true);
      }
    } catch (e) {
      debugPrint('❌ Error creating product: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(isBn ? 'ত্রুটি: $e' : 'Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    _unitController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isBn = LanguageProvider.isBn(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(isBn ? 'পণ্য যোগ করুন' : 'Add Product'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Section
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    width: double.infinity,
                    height: 220,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
                        width: 2,
                      ),
                    ),
                    child: _selectedImage != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.file(
                              _selectedImage!,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.cloud_upload_outlined,
                                size: 56,
                                color: Theme.of(context).primaryColor,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                isBn ? 'পণ্যের ছবি নির্বাচন করতে ট্যাপ করুন' : 'Tap to select product image',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.copyWith(
                                      color: Theme.of(context).primaryColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                isBn ? 'JPG, PNG সর্বোচ্চ ৫ মেগাবাইট' : 'JPG, PNG up to 5MB',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Product Title
              Text(
                isBn ? 'পণ্যের নাম' : 'Product Title',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  hintText: isBn ? 'যেমন: দেশি গোল আলু' : 'e.g., Fresh Potatoes',
                  prefixIcon: const Icon(Icons.shopping_bag_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return isBn ? 'পণ্যের নাম আবশ্যক' : 'Product title is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Description
              Text(
                isBn ? 'বিবরণ' : 'Description',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: isBn ? 'আপনার পণ্যের গুণগত মান ও বিবরণ লিখুন...' : 'Describe your product quality & details...',
                  prefixIcon: const Icon(Icons.description_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return isBn ? 'বিবরণ আবশ্যক' : 'Description is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Category
              Text(
                isBn ? 'ক্যাটাগরি' : 'Category',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                items: _categories
                    .map((cat) => DropdownMenuItem<String>(
                          value: cat['value']!,
                          child: Text(isBn ? (cat['labelBn'] ?? cat['labelEn']!) : cat['labelEn']!),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedCategory = value);
                  }
                },
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.category_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Price and Quantity Row
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isBn ? 'মূল্য (প্রতি একক)' : 'Price (per unit)',
                          style:
                              Theme.of(context).textTheme.labelMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _priceController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: '0',
                            prefixText: '৳ ',
                            prefixIcon:
                                const Icon(Icons.currency_pound_outlined),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          validator: (value) {
                            if (value?.isEmpty ?? true) {
                              return isBn ? 'মূল্য আবশ্যক' : 'Price is required';
                            }
                            if (double.tryParse(value!) == null) {
                              return isBn ? 'সঠিক মূল্য দিন' : 'Invalid price';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isBn ? 'পরিমাণ' : 'Quantity',
                          style:
                              Theme.of(context).textTheme.labelMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _quantityController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: '0',
                            prefixIcon: const Icon(Icons.inventory_2_outlined),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          validator: (value) {
                            if (value?.isEmpty ?? true) {
                              return isBn ? 'পরিমাণ আবশ্যক' : 'Quantity is required';
                            }
                            if (double.tryParse(value!) == null) {
                              return isBn ? 'সঠিক পরিমাণ দিন' : 'Invalid quantity';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Unit
              Text(
                isBn ? 'একক' : 'Unit',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _unitController.text,
                items: _units
                    .map((unit) => DropdownMenuItem<String>(
                          value: unit['value']!,
                          child: Text(isBn ? unit['labelBn']! : unit['labelEn']!),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    _unitController.text = value;
                  }
                },
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.rule_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Location
              Text(
                isBn ? 'অবস্থান' : 'Location',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _locationController,
                decoration: InputDecoration(
                  hintText: isBn ? 'যেমন: বগুড়া সদর, বগুড়া' : 'e.g., Bogura Sadar, Bogura',
                  prefixIcon: const Icon(Icons.location_on_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return isBn ? 'অবস্থান আবশ্যক' : 'Location is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Super Class Monetized Boosting Plans
              Text(
                isBn ? 'পণ্য প্রমোশন ও বুস্টিং প্ল্যান 🚀' : 'Product Promotion & Boost Plans 🚀',
                style: GoogleFonts.hindSiliguri(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                isBn
                    ? 'দ্রুত বিক্রির জন্য ও বড় পাইকারদের দৃষ্টি আকর্ষণ করতে বুস্ট নির্বাচন করুন:'
                    : 'Choose a boost tier to sell faster and reach major wholesalers:',
                style: GoogleFonts.hindSiliguri(fontSize: 12, color: Colors.grey.shade700),
              ),
              const SizedBox(height: 12),

              _buildBoostCard(
                tier: 'free',
                title: isBn ? 'সাধারণ লিস্টিং' : 'Standard Listing',
                subtitle: isBn ? 'রেগুলার মার্কেটপ্লেস ফিডে বিনামূল্যে প্রদর্শিত হবে' : 'Free display in regular marketplace feed',
                price: isBn ? 'বিনামূল্যে (৳০)' : 'Free (৳0)',
                icon: Icons.check_circle_outline,
                color: Colors.grey.shade700,
                badgeText: isBn ? 'ফ্রি' : 'Free',
              ),
              const SizedBox(height: 10),

              _buildBoostCard(
                tier: 'urgent',
                title: isBn ? 'জরুরি বিক্রি বুস্ট ⚡' : 'Urgent Sale Boost ⚡',
                subtitle: isBn ? '৩ দিন "Urgent Sale" লাল ব্যাজ ও সবার উপরে থাকবে' : '3 days with "Urgent Sale" red badge on top',
                price: isBn ? '৳ ২০ / ৩ দিন' : '৳ 20 / 3 Days',
                icon: Icons.bolt,
                color: Colors.red.shade600,
                badgeText: isBn ? 'জনপ্রিয়' : 'Popular',
              ),
              const SizedBox(height: 10),

              _buildBoostCard(
                tier: 'featured',
                title: isBn ? 'প্রিমিয়াম ফিচার্ড লট 👑' : 'Premium Featured Lot 👑',
                subtitle: isBn ? '৭ দিন হোমপেজ গোল্ডেন ব্যানারে এবং টপ লিস্টিংয়ে থাকবে' : '7 days on homepage golden banner & top lots',
                price: isBn ? '৳ ৫০ / ৭ দিন' : '৳ 50 / 7 Days',
                icon: Icons.workspace_premium_rounded,
                color: Colors.amber.shade800,
                badgeText: isBn ? 'বেস্ট ভ্যালু' : 'Best Value',
              ),
              const SizedBox(height: 10),

              _buildBoostCard(
                tier: 'vip',
                title: isBn ? 'ভিআইপি হোলসেলার পার্টনার 💎' : 'VIP Wholesaler Partner 💎',
                subtitle: isBn ? '১৫ দিন ঢাকার শীর্ষ আড়তদার ও বড় ক্রেতাদের এসএমএস অ্যালার্ট' : '15 days SMS alert to top commission agents & bulk buyers',
                price: isBn ? '৳ ১০০ / ১৫ দিন' : '৳ 100 / 15 Days',
                icon: Icons.diamond_rounded,
                color: const Color(0xFF1976D2),
                badgeText: isBn ? 'ভিআইপি' : 'VIP',
              ),
              const SizedBox(height: 16),

              // SSL Payment Summary Card when Paid Tier is Selected
              if (_selectedTier != 'free') ...[
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF1E3A8A).withValues(alpha: 0.08),
                        const Color(0xFF3B82F6).withValues(alpha: 0.05),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFF3B82F6).withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E3A8A),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.payment_rounded, color: Colors.white, size: 18),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              isBn ? '💳 SSLCommerz পেমেন্ট বিবরণী' : '💳 SSLCommerz Payment Details',
                              style: GoogleFonts.hindSiliguri(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF1E3A8A),
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2E7D32).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.lock, size: 12, color: Color(0xFF2E7D32)),
                                const SizedBox(width: 4),
                                Text(
                                  isBn ? '১০০% নিরাপদ' : '100% Secure',
                                  style: GoogleFonts.hindSiliguri(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF2E7D32),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            isBn ? 'নির্বাচিত বুস্ট প্ল্যান:' : 'Selected Boost Plan:',
                            style: GoogleFonts.hindSiliguri(fontSize: 13, color: Colors.grey.shade700),
                          ),
                          Text(
                            _selectedTier == 'urgent'
                                ? (isBn ? 'জরুরি বিক্রি বুস্ট (৩ দিন)' : 'Urgent Sale (3 Days)')
                                : _selectedTier == 'featured'
                                    ? (isBn ? 'প্রিমিয়াম লট (৭ দিন)' : 'Premium Lot (7 Days)')
                                    : (isBn ? 'ভিআইপি পার্টনার (১৫ দিন)' : 'VIP Partner (15 Days)'),
                            style: GoogleFonts.hindSiliguri(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            isBn ? 'পেমেন্ট মেথড:' : 'Payment Method:',
                            style: GoogleFonts.hindSiliguri(fontSize: 13, color: Colors.grey.shade700),
                          ),
                          Text(
                            isBn ? 'SSLCommerz (বিকাশ, নগদ, রকেট, কার্ড)' : 'SSLCommerz (bKash, Nagad, Cards)',
                            style: GoogleFonts.hindSiliguri(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF2563EB),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            isBn ? 'মোট প্রদেয় ফি:' : 'Total Payable Fee:',
                            style: GoogleFonts.hindSiliguri(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                          Text(
                            _selectedTier == 'urgent'
                                ? '৳ ২০.০০'
                                : _selectedTier == 'featured'
                                    ? '৳ ৫০.০০'
                                    : '৳ ১০০.০০',
                            style: GoogleFonts.hindSiliguri(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF2E7D32),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],

              const SizedBox(height: 12),

              // Submit & SSL Payment Button
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _submitForm,
                  icon: _isLoading
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                        )
                      : Icon(
                          _selectedTier != 'free' ? Icons.payment_rounded : Icons.storefront_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                  label: Text(
                    _isLoading
                        ? (isBn ? 'প্রক্রিয়াধীন...' : 'Processing...')
                        : (_selectedTier != 'free'
                            ? (isBn
                                ? 'SSL পেমেন্ট করুন ও বুস্টসহ প্রকাশ করুন (${_selectedTier == 'urgent' ? '৳২০' : _selectedTier == 'featured' ? '৳৫০' : '৳১০০'})'
                                : 'Pay ${_selectedTier == 'urgent' ? '৳20' : _selectedTier == 'featured' ? '৳50' : '৳100'} via SSL & Publish')
                            : (isBn ? 'পণ্য মার্কেটে প্রকাশ করুন' : 'Publish Crop to Market')),
                    style: GoogleFonts.hindSiliguri(
                      fontSize: 15.5,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _selectedTier != 'free'
                        ? (_selectedTier == 'urgent'
                            ? const Color(0xFFD32F2F)
                            : _selectedTier == 'featured'
                                ? const Color(0xFFD97706)
                                : const Color(0xFF1D4ED8))
                        : Theme.of(context).primaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: _selectedTier != 'free' ? 5 : 3,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Supported Payment Gateways Footer
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.verified_user_outlined, size: 14, color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Text(
                      isBn
                          ? 'SSLCommerz সুরক্ষিত গেটওয়ে: বিকাশ • নগদ • রকেট • কার্ড • ভিসা'
                          : 'Secured by SSLCommerz: bKash • Nagad • Rocket • Cards • Visa',
                      style: GoogleFonts.hindSiliguri(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBoostCard({
    required String tier,
    required String title,
    required String subtitle,
    required String price,
    required IconData icon,
    required Color color,
    required String badgeText,
  }) {
    final isSelected = _selectedTier == tier;

    return GestureDetector(
      onTap: () => setState(() => _selectedTier = tier),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.06) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [BoxShadow(color: color.withValues(alpha: 0.15), blurRadius: 10, offset: const Offset(0, 4))]
              : [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 4, offset: const Offset(0, 2))],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          title,
                          style: GoogleFonts.hindSiliguri(
                            fontSize: 13.5,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          badgeText,
                          style: GoogleFonts.hindSiliguri(
                            fontSize: 9.5,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            height: 1.1,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.hindSiliguri(fontSize: 11, color: Colors.grey.shade700, height: 1.2),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  price,
                  style: GoogleFonts.hindSiliguri(
                    fontSize: 12.5,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 3),
                Icon(
                  isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                  color: isSelected ? color : Colors.grey.shade400,
                  size: 18,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
