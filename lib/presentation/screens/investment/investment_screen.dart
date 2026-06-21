import 'package:flutter/material.dart';
import 'package:get/get.dart';

class InvestmentScreen extends StatelessWidget {
  const InvestmentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('বিনিয়োগ'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => Get.snackbar('তথ্য', 'বিনিয়োগ বিষয়ে আরও জানুন'),
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.attach_money,
                size: 128,
                color: Colors.green.withOpacity(0.3),
              ),
              const SizedBox(height: 24),
              Text(
                'মাইক্রো-ফিন্যান্সিং ও ক্রাউডফান্ডিং',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  'কৃষি ব্যবসায় বিনিয়োগ করুন এবং লাভ অর্জন করুন\n\nশীঘ্রই আসছে:',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              const SizedBox(height: 24),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.teal.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.teal.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFeature('💼 কৃষি প্রকল্পে বিনিয়োগ'),
                    const SizedBox(height: 12),
                    _buildFeature('📈 স্বচ্ছ রিটার্ন হিসাব'),
                    const SizedBox(height: 12),
                    _buildFeature('👥 সম্প্রদায় চালিত তহবিল'),
                    const SizedBox(height: 12),
                    _buildFeature('✅ প্রকল্প পর্যবেক্ষণ রিপোর্ট'),
                    const SizedBox(height: 12),
                    _buildFeature('🔒 নিরাপদ লেনদেন'),
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
          Get.snackbar('বিনিয়োগ চাই', 'এই বৈশিষ্ট্য শীঘ্রই উপলব্ধ হবে');
        },
        icon: const Icon(Icons.add),
        label: const Text('বিনিয়োগ চাই'),
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
