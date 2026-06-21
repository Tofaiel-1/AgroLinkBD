import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TransportRentalScreen extends StatelessWidget {
  const TransportRentalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final services = [
      {
        'name': 'ট্রাক ও পিকআপ',
        'price': '১৮০০',
        'unit': 'ঘন্টা',
        'icon': Icons.local_shipping,
        'description': 'পণ্য পরিবহনের জন্য',
      },
      {
        'name': 'কম্বাইন্ড হার্ভেস্টার',
        'price': '৫০০০',
        'unit': 'দিন',
        'icon': Icons.agriculture,
        'description': '৫ টন ক্ষমতা',
      },
      {
        'name': 'আইলান্ড ট্রাক',
        'price': '৩৫০০',
        'unit': 'দিন',
        'icon': Icons.fire_truck,
        'description': '৫ টন ক্ষমতা',
      },
      {
        'name': 'ট্রাক্টর ভাড়া',
        'price': '২৫০০',
        'unit': 'দিন',
        'icon': Icons.agriculture_outlined,
        'description': 'চাষাবাদের জন্য',
      },
    ];

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E7D32),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'পরিবহন ও যন্ত্র ভাড়া',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: services.length,
        itemBuilder: (context, index) {
          final service = services[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      service['icon'] as IconData,
                      size: 40,
                      color: Colors.green.shade700,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          service['name'] as String,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          service['description'] as String,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text(
                              '৳${service['price']}',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade700,
                              ),
                            ),
                            Text(
                              '/${service['unit']}',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D32),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'বুক করুন',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
