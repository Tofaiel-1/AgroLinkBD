import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/models/user_model.dart';
import '../../core/models/card_model.dart';
import '../../core/services/sokol_card_service.dart';
import 'card_preview_screen.dart';

class DynamicProfileForm extends StatefulWidget {
  final UserType selectedRole;
  const DynamicProfileForm({super.key, required this.selectedRole});

  @override
  State<DynamicProfileForm> createState() => _DynamicProfileFormState();
}

class _DynamicProfileFormState extends State<DynamicProfileForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  
  // Dynamic fields
  final Map<String, TextEditingController> _dynamicControllers = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeDynamicFields();
  }

  void _initializeDynamicFields() {
    switch (widget.selectedRole) {
      case UserType.farmer:
        _dynamicControllers['Land Size (Acres)'] = TextEditingController();
        _dynamicControllers['Primary Crops'] = TextEditingController();
        _dynamicControllers['Farming Season'] = TextEditingController();
        break;
      case UserType.seller:
      case UserType.company:
        _dynamicControllers['Trade License Number'] = TextEditingController();
        _dynamicControllers['Shop/Company Name'] = TextEditingController();
        _dynamicControllers['Product Categories'] = TextEditingController();
        break;
      case UserType.serviceProvider:
        _dynamicControllers['Service Type'] = TextEditingController();
        _dynamicControllers['Service Charge/Hour'] = TextEditingController();
        break;
      default:
        break;
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _isLoading = true; });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('No authenticated user');

      final uid = user.uid;
      
      // Prepare role specific data
      Map<String, dynamic> roleSpecificData = {};
      _dynamicControllers.forEach((key, controller) {
        roleSpecificData[key] = controller.text.trim();
      });

      // 1. Save to users collection (update UserModel)
      final userModel = UserModel(
        id: uid,
        name: _nameController.text.trim(),
        phone: user.phoneNumber ?? '',
        email: _emailController.text.trim(),
        userType: widget.selectedRole,
        status: UserStatus.active,
        address: _addressController.text.trim(),
        createdAt: DateTime.now(),
      );
      
      await FirebaseFirestore.instance.collection('users').doc(uid).set(
        userModel.toJson(),
        SetOptions(merge: true),
      );

      // 2. Save to cards collection
      final cardService = SokolCardService();
      final qrToken = cardService.generatePaymentToken(uid);
      
      final cardModel = CardModel(
        uid: uid,
        roleSpecificData: roleSpecificData,
        qrData: qrToken,
      );

      await cardService.saveCard(cardModel);

      // Navigate to Preview
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const CardPreviewScreen()),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      setState(() { _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Complete ${widget.selectedRole.name.toUpperCase()} Profile')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.grey,
                      child: Icon(Icons.camera_alt, size: 40, color: Colors.white),
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'Full Name', border: OutlineInputBorder()),
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(labelText: 'Email (Optional)', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _addressController,
                      decoration: const InputDecoration(labelText: 'Village / Address', border: OutlineInputBorder()),
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 24),
                    const Text('Role Specific Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    ..._dynamicControllers.entries.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: TextFormField(
                          controller: entry.value,
                          decoration: InputDecoration(labelText: entry.key, border: const OutlineInputBorder()),
                          validator: (v) => v!.isEmpty ? 'Required' : null,
                        ),
                      );
                    }).toList(),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green, padding: const EdgeInsets.all(16)),
                      onPressed: _submitForm,
                      child: const Text('Save & Generate Card', style: TextStyle(fontSize: 18, color: Colors.white)),
                    )
                  ],
                ),
              ),
            ),
    );
  }
}
