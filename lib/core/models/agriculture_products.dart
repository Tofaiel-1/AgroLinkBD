import 'package:flutter/material.dart';

class AgricultureProducts {
  // সকল কৃষি পণ্য সংজ্ঞা

  static const List<Map<String, dynamic>> vegetableProducts = [
    {
      'id': 'veg_001',
      'title': 'তাজা টমেটো',
      'bengaliName': 'তাজা টমেটো',
      'category': 'vegetables',
      'description':
          'সরাসরি আমাদের খামার থেকে তাজা লাল টমেটো। সম্পূর্ণ কোন কীটনাশক ছাড়াই।',
      'price': 45.00,
      'unit': 'kg',
      'image': 'assets/images/tajatomato.png',
      'rating': 4.8,
      'reviews': 125,
      'stock': 50,
      'seller': 'করিম ট্রেডার',
      'location': 'ঢাকা, বাংলাদেশ',
      'type': 'vegetable',
    },
    {
      'id': 'veg_002',
      'title': 'বাগানের পালং শাক',
      'bengaliName': 'বাগানের পালং শাক',
      'category': 'vegetables',
      'description': 'জৈব চাষ করা সবুজ পালং শাক। আয়রন এবং পুষ্টিতে ভরপুর।',
      'price': 35.00,
      'unit': 'bunch',
      'image': 'assets/images/palongshak.png',
      'rating': 4.7,
      'reviews': 98,
      'stock': 30,
      'seller': 'আলী খামার',
      'location': 'গাজীপুর, বাংলাদেশ',
      'type': 'vegetable',
    },
    {
      'id': 'veg_003',
      'title': 'টিটকা আলু',
      'bengaliName': 'টিটকা আলু',
      'category': 'vegetables',
      'description': 'উচ্চ মানের নতুন আলু। দীর্ঘস্থায়ী এবং সুস্বাদু।',
      'price': 30.00,
      'unit': 'kg',
      'image': 'assets/images/titka_alu.png',
      'rating': 4.9,
      'reviews': 156,
      'stock': 100,
      'seller': 'সাদেক ট্রেডার',
      'location': 'মুন্সিগঞ্জ, বাংলাদেশ',
      'type': 'vegetable',
    },
  ];

  static const List<Map<String, dynamic>> dairyProducts = [
    {
      'id': 'dairy_001',
      'title': 'গরুর খাঁটি দুধ',
      'bengaliName': 'গরুর খাঁটি দুধ',
      'category': 'dairy',
      'description':
          'সরাসরি খামার থেকে, কোন মিশ্রণ ছাড়াই খাঁটি দুধ। প্রতিদিন সতেজ।',
      'price': 50.00,
      'unit': 'litre',
      'image': 'assets/images/gorer_khati_dudh.png',
      'rating': 4.9,
      'reviews': 234,
      'stock': 40,
      'seller': 'ফরিদ ডেইরি খামার',
      'location': 'টাঙ্গাইল, বাংলাদেশ',
      'type': 'dairy',
    },
    {
      'id': 'dairy_002',
      'title': 'খাঁটি প্রাকৃতিক দুধ',
      'bengaliName': 'খাঁটি প্রাকৃতিক দুধ',
      'category': 'dairy',
      'description': 'কোন সংরক্ষণকারী বা কৃত্রিম উপাদান ছাড়াই প্রাকৃতিক দুধ।',
      'price': 55.00,
      'unit': 'litre',
      'image': 'assets/images/khatee_prakrity_dudh.png',
      'rating': 4.8,
      'reviews': 189,
      'stock': 35,
      'seller': 'ইকো ডেইরি',
      'location': 'রাজশাহী, বাংলাদেশ',
      'type': 'dairy',
    },
    {
      'id': 'dairy_003',
      'title': 'দেশি ঘি',
      'bengaliName': 'দেশি ঘি',
      'category': 'dairy',
      'description':
          'ঐতিহ্যবাহী পদ্ধতিতে রান্না করা খাঁটি দেশি ঘি। স্বাস্থ্যকর এবং সুস্বাদু।',
      'price': 450.00,
      'unit': 'kg',
      'image': 'assets/images/deshi_ghee.png',
      'rating': 4.9,
      'reviews': 267,
      'stock': 20,
      'seller': 'ঐতিহ্য ঘি প্রোডাক্ট',
      'location': 'কুমিল্লা, বাংলাদেশ',
      'type': 'dairy',
    },
    {
      'id': 'dairy_004',
      'title': 'ক্ষায়ের দই',
      'bengaliName': 'ক্ষায়ের দই',
      'category': 'dairy',
      'description':
          'ঘরে বানানো তাজা দই। প্রাকৃতিক উপাদান দিয়ে তৈরি, সুস্বাদু এবং স্বাস্থ্যকর।',
      'price': 60.00,
      'unit': 'kg',
      'image': 'assets/images/khayeer_doi.png',
      'rating': 4.7,
      'reviews': 145,
      'stock': 25,
      'seller': 'সাদি দই উৎপাদন',
      'location': 'সিলেট, বাংলাদেশ',
      'type': 'dairy',
    },
  ];

  static const List<Map<String, dynamic>> animalProducts = [
    {
      'id': 'animal_001',
      'title': 'চিকা ডিম',
      'bengaliName': 'চিকা ডিম',
      'category': 'animal_products',
      'description':
          'মুক্ত খামারে পালিত মুরগির তাজা ডিম। প্রোটিন সমৃদ্ধ এবং সম্পূর্ণ প্রাকৃতিক।',
      'price': 100.00,
      'unit': 'dozen',
      'image': 'assets/images/chika_egg.png',
      'rating': 4.8,
      'reviews': 312,
      'stock': 50,
      'seller': 'সবুজ ফার্ম ডিম',
      'location': 'নারায়ণগঞ্জ, বাংলাদেশ',
      'type': 'animal_products',
    },
  ];

  static const List<Map<String, dynamic>> otherProducts = [
    {
      'id': 'other_001',
      'title': 'মোনালী মধু',
      'bengaliName': 'মোনালী মধু',
      'category': 'honey',
      'description':
          'খাঁটি মৌমাছির তৈরি মধু। সম্পূর্ণ কোন ভেজাল ছাড়াই। স্বাস্থ্য উপকারী।',
      'price': 350.00,
      'unit': 'kg',
      'image': 'assets/images/monali_modhu.png',
      'rating': 4.9,
      'reviews': 421,
      'stock': 30,
      'seller': 'মৌমাছি কল্যাণ কেন্দ্র',
      'location': 'সুন্দরবন, খুলনা, বাংলাদেশ',
      'type': 'honey',
    },
    {
      'id': 'other_002',
      'title': 'খাঁটি চাল',
      'bengaliName': 'খাঁটি চাল',
      'category': 'grains',
      'description':
          'দেশীয় উন্নত জাতের চাল। সুস্বাদু এবং পুষ্টিকর। সম্পূর্ণ খাঁটি।',
      'price': 40.00,
      'unit': 'kg',
      'image': 'assets/images/khati_chaal.png',
      'rating': 4.7,
      'reviews': 198,
      'stock': 200,
      'seller': 'শস্য কল্যাণ',
      'location': 'রংপুর, বাংলাদেশ',
      'type': 'grains',
    },
  ];

  // সব পণ্য একসাথে
  static List<Map<String, dynamic>> getAllProducts() {
    return [
      ...vegetableProducts,
      ...dairyProducts,
      ...animalProducts,
      ...otherProducts,
    ];
  }

  // ক্যাটাগরি অনুযায়ী পণ্য
  static List<Map<String, dynamic>> getProductsByCategory(String category) {
    return getAllProducts()
        .where((product) => product['category'] == category)
        .toList();
  }

  // পণ্যের ধরন অনুযায়ী
  static List<Map<String, dynamic>> getProductsByType(String type) {
    return getAllProducts()
        .where((product) => product['type'] == type)
        .toList();
  }
}

// পণ্য কার্ড উইজেট
class ProductCard extends StatelessWidget {
  final Map<String, dynamic> product;
  final VoidCallback onTap;

  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ছবি
            Container(
              height: 120,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(12)),
                child: Image.asset(
                  product['image'],
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Center(
                      child: Icon(
                        Icons.image_not_supported,
                        color: Colors.grey[600],
                      ),
                    );
                  },
                ),
              ),
            ),
            // বিস্তারিত
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product['title'],
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      product['description'],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '৳${product['price']}/${product['unit']}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: Colors.green,
                          ),
                        ),
                        Row(
                          children: [
                            const Icon(Icons.star,
                                size: 12, color: Colors.amber),
                            const SizedBox(width: 2),
                            Text(
                              '${product['rating']}',
                              style: const TextStyle(fontSize: 10),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
