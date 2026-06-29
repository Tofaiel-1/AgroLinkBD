import sys

file_path = "lib/presentation/screens/marketplace/marketplace_screen.dart"

with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

import re

new_items = """                  {
                    'name': 'খাঁটি মধু (সুন্দরবন)',
                    'price': 1200,
                    'unit': 'কেজি',
                    'farmer': 'মৌয়াল সমবায়',
                    'location': 'খুলনা',
                    'image': 'https://res.cloudinary.com/dbbvlg2dz/image/upload/v1782756674/images_fhqvvm.jpg',
                    'rating': 4.9,
                    'category': 'spices',
                    'badge': 'Premium',
                    'isVerified': true,
                  },
                  {
                    'name': 'টাটকা বেগুন',
                    'price': 0,
                    'unit': 'কেজি',
                    'farmer': 'সবুজ এগ্রো',
                    'location': 'নরসিংদী',
                    'image': 'YOUR_IMAGE_LINK_HERE',
                    'rating': 4.2,
                    'category': 'vegetables',
                    'badge': 'Fresh',
                    'isVerified': true,
                  },
                  {
                    'name': 'সরিষার তেল (ঘানি ভাঙা)',
                    'price': 0,
                    'unit': 'লিটার',
                    'farmer': 'তৈল কল',
                    'location': 'জামালপুর',
                    'image': 'YOUR_IMAGE_LINK_HERE',
                    'rating': 4.9,
                    'category': 'spices',
                    'badge': 'Organic',
                    'isVerified': true,
                  },
                  {
                    'name': 'দেশি মুরগি',
                    'price': 0,
                    'unit': 'পিছ',
                    'farmer': 'গ্রামের খামার',
                    'location': 'কুমিল্লা',
                    'image': 'YOUR_IMAGE_LINK_HERE',
                    'rating': 4.7,
                    'category': 'meat',
                    'badge': null,
                    'isVerified': true,
                  },
                  {
                    'name': 'তরমুজ (বরিশাল)',
                    'price': 0,
                    'unit': 'পিছ',
                    'farmer': 'বরিশাল ফ্রুটস',
                    'location': 'বরিশাল',
                    'image': 'YOUR_IMAGE_LINK_HERE',
                    'rating': 4.8,
                    'category': 'fruits',
                    'badge': 'Summer Special',
                    'isVerified': true,
                  },
                  {
                    'name': 'ধনে পাতা (দেশি)',
                    'price': 0,
                    'unit': 'আঁটি',
                    'farmer': 'কৃষক বাজার',
                    'location': 'সাভার',
                    'image': 'YOUR_IMAGE_LINK_HERE',
                    'rating': 4.5,
                    'category': 'vegetables',
                    'badge': null,
                    'isVerified': false,
                  },"""

# Replace the last item (khanti modhu) with the new list that includes it and the new 5 items
pattern = re.compile(r"\{\s*'name':\s*'খাঁটি মধু \(সুন্দরবন\)'.*?\},", re.DOTALL)
if pattern.search(content):
    content = pattern.sub(new_items, content)
    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(content)
    print("Successfully added 5 new items")
else:
    print("Could not find Khanti Modhu in the file.")
