import 'package:flutter/material.dart';
import '../../core/models/user_model.dart';
import 'dynamic_profile_form.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  final List<Map<String, dynamic>> _roles = const [
    {'type': UserType.farmer, 'title': 'Farmer', 'icon': Icons.agriculture},
    {'type': UserType.buyer, 'title': 'Buyer', 'icon': Icons.shopping_cart},
    {'type': UserType.seller, 'title': 'Seller', 'icon': Icons.storefront},
    {'type': UserType.serviceProvider, 'title': 'Service Provider', 'icon': Icons.handyman},
    {'type': UserType.company, 'title': 'Company', 'icon': Icons.business},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select Your Role')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Choose how you want to use the Card ecosystem.',
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: _roles.length,
                itemBuilder: (context, index) {
                  final role = _roles[index];
                  return Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DynamicProfileForm(selectedRole: role['type'] as UserType),
                          ),
                        );
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(role['icon'] as IconData, size: 48, color: Colors.green),
                          const SizedBox(height: 16),
                          Text(
                            role['title'] as String,
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
