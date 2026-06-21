import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MachineryRentalScreen extends StatelessWidget {
  const MachineryRentalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('যন্ত্রপাতি ভাড়া')),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.agriculture,
                size: 128,
                color: Colors.green.withOpacity(0.3),
              ),
              const SizedBox(height: 24),
              Text(
                'ট্র্যাক্টরের জন্য উবার',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  'সাশ্রয়ী কৃষি যন্ত্রপাতি ভাড়া করুন\n\nশীঘ্রই আসছে:',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              const SizedBox(height: 24),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFeature('🚜 ট্র্যাক্টর এবং কম্বাইন'),
                    const SizedBox(height: 12),
                    _buildFeature('👨‍🌾 পরিচালক সহ ভাড়া'),
                    const SizedBox(height: 12),
                    _buildFeature('💵 নমনীয় মূল্য বিকল্প'),
                    const SizedBox(height: 12),
                    _buildFeature('🛠️ রক্ষণাবেক্ষণ এবং বীমা অন্তর্ভুক্ত'),
                    const SizedBox(height: 12),
                    _buildFeature('📅 সহজ বুকিং সিস্টেম'),
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
          Get.snackbar('যন্ত্র নিবন্ধন', 'এই বৈশিষ্ট্য শীঘ্রই উপলব্ধ হবে');
        },
        icon: const Icon(Icons.add),
        label: const Text('যন্ত্র নিবন্ধন'),
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
