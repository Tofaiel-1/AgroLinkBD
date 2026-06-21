import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TransportScreen extends StatelessWidget {
  const TransportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('পরিবহন সেবা')),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.local_shipping,
                size: 128,
                color: Colors.green.withOpacity(0.3),
              ),
              const SizedBox(height: 24),
              Text(
                'চালক নিলাম',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  'কৃষি পণ্য পরিবহনের জন্য সেরা চালক খুঁজুন\n\nশীঘ্রই আসছে:',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              const SizedBox(height: 24),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFeature('🚗 ড্রাইভার ম্যাচিং প্রযুক্তি'),
                    const SizedBox(height: 12),
                    _buildFeature('💰 বাস্তব সময়ে মূল্য নির্ধারণ'),
                    const SizedBox(height: 12),
                    _buildFeature('🗺️ GPS ট্র্যাকিং'),
                    const SizedBox(height: 12),
                    _buildFeature('⭐ ড্রাইভার রেটিং'),
                    const SizedBox(height: 12),
                    _buildFeature('📱 রিয়েল-টাইম আপডেট'),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Get.snackbar('পরিবহন চাই', 'এই বৈশিষ্ট্য শীঘ্রই উপলব্ধ হবে');
        },
        icon: const Icon(Icons.add),
        label: const Text('পরিবহন চাই'),
      ),
    );
  }

  Widget _buildFeature(String text) {
    return Row(
      children: [
        const SizedBox(width: 8),
        Expanded(
          child: Text(text, style: const TextStyle(fontSize: 14)),
        ),
      ],
    );
  }
}
