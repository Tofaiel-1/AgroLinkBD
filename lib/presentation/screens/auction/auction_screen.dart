import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AuctionScreen extends StatelessWidget {
  const AuctionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('নিলাম'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => Get.snackbar('ইতিহাস', 'নিলাম ইতিহাস শীঘ্রই আসছে'),
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.gavel,
                size: 128,
                color: Colors.green.withOpacity(0.3),
              ),
              const SizedBox(height: 24),
              Text(
                'ডিজিটাল নিলাম',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  'লাইভ বিডিং এর মাধ্যমে সেরা মূল্য পান\n\nশীঘ্রই আসছে:',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              const SizedBox(height: 24),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.purple.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.purple.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFeature('🔴 লাইভ নিলাম ইভেন্ট'),
                    const SizedBox(height: 12),
                    _buildFeature('💬 রিয়েল-টাইম বিড আপডেট'),
                    const SizedBox(height: 12),
                    _buildFeature('📊 বাজার মূল্য তুলনা'),
                    const SizedBox(height: 12),
                    _buildFeature('🏆 বিজয়ীদের যাচাইকরণ'),
                    const SizedBox(height: 12),
                    _buildFeature('🚚 নিরাপদ ডেলিভারি ব্যবস্থা'),
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
          Get.snackbar('নিলাম শুরু করুন', 'এই বৈশিষ্ট্য শীঘ্রই উপলব্ধ হবে');
        },
        icon: const Icon(Icons.gavel),
        label: const Text('নিলাম শুরু করুন'),
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
