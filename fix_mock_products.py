import sys

file_path = "lib/presentation/screens/marketplace/marketplace_screen.dart"

with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

import re

new_products = """allProducts.addAll([
                  {
                    'name': 'তাজা টমেটো (Premium)',
                    'price': 0,
                    'unit': 'কেজি',
                    'farmer': 'করিম ফার্ম',
                    'location': 'বগুড়া',
                    'image': 'YOUR_IMAGE_LINK_HERE',
                    'rating': 4.8,
                    'category': 'vegetables',
                    'badge': 'Hot',
                    'isVerified': true,
                  },
                  {
                    'name': 'দেশি পেঁয়াজ (Organic)',
                    'price': 0,
                    'unit': 'কেজি',
                    'farmer': 'রহিম এগ্রো',
                    'location': 'পাবনা',
                    'image': 'YOUR_IMAGE_LINK_HERE',
                    'rating': 4.5,
                    'category': 'vegetables',
                    'badge': 'Sale',
                    'isVerified': true,
                  },
                  {
                    'name': 'মিনিকেট চাল (সুপার)',
                    'price': 0,
                    'unit': 'কেজি',
                    'farmer': 'কৃষক সমবায়',
                    'location': 'দিনাজপুর',
                    'image': 'YOUR_IMAGE_LINK_HERE',
                    'rating': 4.9,
                    'category': 'grains',
                    'badge': null,
                    'isVerified': true,
                  },
                  {
                    'name': 'তাজা আলু (রংপুর)',
                    'price': 0,
                    'unit': 'কেজি',
                    'farmer': 'রংপুর ফার্ম',
                    'location': 'রংপুর',
                    'image': 'YOUR_IMAGE_LINK_HERE',
                    'rating': 4.3,
                    'category': 'vegetables',
                    'badge': null,
                    'isVerified': false,
                  },
                  {
                    'name': 'আম (হিমসাগর)',
                    'price': 0,
                    'unit': 'কেজি',
                    'farmer': 'রাজশাহী ফ্রুট',
                    'location': 'রাজশাহী',
                    'image': 'YOUR_IMAGE_LINK_HERE',
                    'rating': 4.9,
                    'category': 'fruits',
                    'badge': 'Top Rated',
                    'isVerified': true,
                  },
                  {
                    'name': 'রুই মাছ (হালদা)',
                    'price': 0,
                    'unit': 'কেজি',
                    'farmer': 'মৎস্য খামার',
                    'location': 'ময়মনসিংহ',
                    'image': 'YOUR_IMAGE_LINK_HERE',
                    'rating': 4.7,
                    'category': 'fish',
                    'badge': 'Fresh',
                    'isVerified': true,
                  },
                  {
                    'name': 'গরুর মাংস (দেশি)',
                    'price': 0,
                    'unit': 'কেজি',
                    'farmer': 'সততা এগ্রো',
                    'location': 'ঢাকা',
                    'image': 'YOUR_IMAGE_LINK_HERE',
                    'rating': 4.8,
                    'category': 'meat',
                    'badge': null,
                    'isVerified': true,
                  },
                  {
                    'name': 'ফার্মের ডিম',
                    'price': 0,
                    'unit': 'ডজন',
                    'farmer': 'পোলট্রি ফার্ম',
                    'location': 'গাজীপুর',
                    'image': 'YOUR_IMAGE_LINK_HERE',
                    'rating': 4.6,
                    'category': 'dairy',
                    'badge': null,
                    'isVerified': true,
                  },
                  {
                    'name': 'খাঁটি মধু (সুন্দরবন)',
                    'price': 0,
                    'unit': 'কেজি',
                    'farmer': 'মৌয়াল সমবায়',
                    'location': 'খুলনা',
                    'image': 'YOUR_IMAGE_LINK_HERE',
                    'rating': 4.9,
                    'category': 'spices',
                    'badge': 'Premium',
                    'isVerified': true,
                  },
                ]);"""

# Replace everything from allProducts.addAll([ to ]);
pattern = re.compile(r'allProducts\.addAll\(\[.*?\]\);', re.DOTALL)
if pattern.search(content):
    content = pattern.sub(new_products, content)
    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(content)
    print("Successfully replaced products")
else:
    print("Could not find allProducts.addAll in the file.")
