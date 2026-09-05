import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:agrolinkbd/core/models/service_model.dart';
import 'package:agrolinkbd/core/providers/language_provider.dart';
import 'package:agrolinkbd/core/providers/service_provider_providers.dart';

class ManageServicesScreen extends ConsumerStatefulWidget {
  const ManageServicesScreen({super.key});

  @override
  ConsumerState<ManageServicesScreen> createState() => _ManageServicesScreenState();
}

class _ManageServicesScreenState extends ConsumerState<ManageServicesScreen> {
  void _showAddServiceBottomSheet(BuildContext context, {ServiceModel? serviceToEdit}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddEditServiceSheet(service: serviceToEdit),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isBn = LanguageProvider.isBn(context);
    final servicesAsyncValue = ref.watch(providerServicesStreamProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5FA),
      appBar: AppBar(
        title: Text(
          isBn ? 'সেবা পরিচালনা করুন' : 'Manage Services',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF2B32B2),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Get.back();
            }
          },
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),
      body: servicesAsyncValue.when(
        data: (services) {
          if (services.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.design_services_outlined, size: 80, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    isBn ? 'কোনো সেবা যোগ করা হয়নি' : 'No services added yet',
                    style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => _showAddServiceBottomSheet(context),
                    icon: const Icon(Icons.add, color: Colors.white),
                    label: Text(
                      isBn ? 'নতুন সেবা যোগ করুন' : 'Add New Service',
                      style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2B32B2),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: services.length,
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              final service = services[index];
              return _buildServiceCard(service, isBn);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF2B32B2))),
        error: (error, stack) => Center(
          child: Text('Error: $error', style: const TextStyle(color: Colors.red)),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF2B32B2),
        onPressed: () => _showAddServiceBottomSheet(context),
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          isBn ? 'নতুন সেবা' : 'New Service',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildServiceCard(ServiceModel service, bool isBn) {
    final isActive = service.status == ServiceStatus.active;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image / Header area
          Container(
            height: 120,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              color: const Color(0xFF2B32B2).withValues(alpha: 0.1),
              image: service.imageUrl != null && service.imageUrl!.isNotEmpty
                  ? DecorationImage(
                      image: NetworkImage(service.imageUrl!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: service.imageUrl == null || service.imageUrl!.isEmpty
                ? Center(
                    child: Icon(Icons.handyman_rounded, size: 50, color: const Color(0xFF2B32B2).withValues(alpha: 0.4)),
                  )
                : null,
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        service.name,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isActive ? Colors.green.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        isBn ? (isActive ? 'সক্রিয়' : 'নিষ্ক্রিয়') : (isActive ? 'Active' : 'Inactive'),
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          color: isActive ? Colors.green.shade700 : Colors.grey.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  '৳${service.price.toStringAsFixed(0)} ${service.priceUnit}',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2B32B2),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  service.description,
                  style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade600),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.star_rounded, size: 16, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text(
                          isBn ? '${service.rating} (${service.bookingsCount} বুকিং)' : '${service.rating} (${service.bookingsCount} bookings)',
                          style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade700),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit_rounded, size: 20, color: Color(0xFF2B32B2)),
                          onPressed: () => _showAddServiceBottomSheet(context, serviceToEdit: service),
                          tooltip: isBn ? 'সম্পাদনা' : 'Edit',
                        ),
                        Switch(
                          value: isActive,
                          onChanged: (val) {
                            ref.read(serviceManagementProvider).toggleServiceStatus(service.id, service.status);
                          },
                          activeThumbColor: const Color(0xFF2B32B2),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AddEditServiceSheet extends ConsumerStatefulWidget {
  final ServiceModel? service;

  const AddEditServiceSheet({super.key, this.service});

  @override
  ConsumerState<AddEditServiceSheet> createState() => _AddEditServiceSheetState();
}

class _AddEditServiceSheetState extends ConsumerState<AddEditServiceSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descController;
  late TextEditingController _priceController;
  late TextEditingController _priceUnitController;
  late TextEditingController _imageUrlController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.service?.name ?? '');
    _descController = TextEditingController(text: widget.service?.description ?? '');
    _priceController = TextEditingController(text: widget.service?.price.toString() ?? '');
    _priceUnitController = TextEditingController(text: widget.service?.priceUnit ?? '/ঘণ্টা');
    _imageUrlController = TextEditingController(text: widget.service?.imageUrl ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _priceController.dispose();
    _priceUnitController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _saveService(bool isBn) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final serviceService = ref.read(serviceManagementProvider);
      final newService = ServiceModel(
        id: widget.service?.id ?? '',
        providerId: widget.service?.providerId ?? serviceService.currentUserId,
        name: _nameController.text.trim(),
        description: _descController.text.trim(),
        price: double.parse(_priceController.text),
        priceUnit: _priceUnitController.text.trim(),
        imageUrl: _imageUrlController.text.trim().isEmpty ? null : _imageUrlController.text.trim(),
        createdAt: widget.service?.createdAt ?? DateTime.now(),
        rating: widget.service?.rating ?? 0.0,
        bookingsCount: widget.service?.bookingsCount ?? 0,
        status: widget.service?.status ?? ServiceStatus.active,
      );

      if (widget.service == null) {
        await serviceService.addService(newService);
        Get.snackbar(
          isBn ? 'সফল' : 'Success',
          isBn ? 'নতুন সেবা যোগ করা হয়েছে' : 'New service added successfully',
          backgroundColor: Colors.green.shade100,
        );
      } else {
        await serviceService.updateService(newService);
        Get.snackbar(
          isBn ? 'সফল' : 'Success',
          isBn ? 'সেবা আপডেট করা হয়েছে' : 'Service updated successfully',
          backgroundColor: Colors.blue.shade100,
        );
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      Get.snackbar(
        isBn ? 'ত্রুটি' : 'Error',
        isBn ? 'সেবা সংরক্ষণ করতে সমস্যা হয়েছে' : 'Failed to save service',
        backgroundColor: Colors.red.shade100,
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isBn = LanguageProvider.isBn(context);

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        top: 24,
        left: 24,
        right: 24,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                widget.service == null
                    ? (isBn ? 'নতুন সেবা যোগ করুন' : 'Add New Service')
                    : (isBn ? 'সেবা সম্পাদনা করুন' : 'Edit Service'),
                style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF2B32B2)),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: isBn ? 'সেবার নাম' : 'Service Name',
                  prefixIcon: const Icon(Icons.handyman_rounded),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (val) => val!.isEmpty ? (isBn ? 'নাম প্রয়োজন' : 'Name is required') : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: isBn ? 'বিবরণ' : 'Description',
                  prefixIcon: const Icon(Icons.description_rounded),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (val) => val!.isEmpty ? (isBn ? 'বিবরণ প্রয়োজন' : 'Description is required') : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _priceController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: isBn ? 'মূল্য (৳)' : 'Price (৳)',
                        prefixIcon: const Icon(Icons.attach_money_rounded),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      validator: (val) => val!.isEmpty ? (isBn ? 'মূল্য প্রয়োজন' : 'Price is required') : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 1,
                    child: TextFormField(
                      controller: _priceUnitController,
                      decoration: InputDecoration(
                        labelText: isBn ? 'ইউনিট' : 'Unit',
                        hintText: isBn ? '/ঘণ্টা' : '/hr',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      validator: (val) => val!.isEmpty ? (isBn ? 'ইউনিট প্রয়োজন' : 'Unit is required') : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _imageUrlController,
                decoration: InputDecoration(
                  labelText: isBn ? 'ছবির লিংক (URL)' : 'Image URL',
                  hintText: 'https://example.com/image.jpg',
                  prefixIcon: const Icon(Icons.image_rounded),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : () => _saveService(isBn),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2B32B2),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Text(
                          widget.service == null
                              ? (isBn ? 'সংরক্ষণ করুন' : 'Save Service')
                              : (isBn ? 'আপডেট করুন' : 'Update Service'),
                          style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
