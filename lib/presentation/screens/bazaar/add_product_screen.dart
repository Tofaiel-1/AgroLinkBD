import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:agrolinkbd/core/providers/user_provider.dart';
import 'dart:io';
import 'package:agrolinkbd/core/providers/language_provider.dart';

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

    setState(() => _isLoading = true);

    try {
      // Upload image to Firebase Storage
      final fileName =
          'products/${_userId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final storageRef = _storage.ref().child(fileName);

      await storageRef.putFile(_selectedImage!);
      final imageUrl = await storageRef.getDownloadURL();

      debugPrint('✅ Image uploaded successfully: $imageUrl');

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
        'createdAt': FieldValue.serverTimestamp(),
        'status': 'available',
        'views': 0,
        'favorites': 0,
      };

      // Save to bazaar_products collection
      final docRef =
          await _firestore.collection('bazaar_products').add(productData);

      debugPrint('✅ Product created: ${docRef.id}');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(isBn ? 'পণ্যটি সফলভাবে যোগ করা হয়েছে!' : 'Product added successfully!')),
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
              const SizedBox(height: 32),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          isBn ? 'পণ্য যোগ করুন' : 'Add Product',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
