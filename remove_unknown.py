import sys
import re

file_path = "lib/presentation/screens/marketplace/marketplace_screen.dart"

with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

old_loop = """                for(var doc in docs) {
                  var data = doc.data() as Map<String, dynamic>;
                  allProducts.add({
                    'id': doc.id,
                    'name': data['title'] ?? 'Unknown',
                    'price': (data['price'] ?? 0).toDouble(),
                    'unit': data['unit'] ?? 'kg',
                    'farmer': 'AgroLink Farm',
                    'farmerId': data['userId'],
                    'location': data['location'] ?? 'Unknown',
                    'image': data['imageUrl'] ?? 'https://via.placeholder.com/150',
                    'rating': 4.5,
                    'category': data['category'] ?? 'other',
                    'badge': 'New',
                    'isVerified': true,
                  });
                }"""

new_loop = """                for(var doc in docs) {
                  var data = doc.data() as Map<String, dynamic>;
                  
                  // Skip products that don't have a proper title or are unknown
                  final title = data['title']?.toString().trim() ?? '';
                  if (title.isEmpty || title.toLowerCase() == 'unknown') {
                    continue;
                  }

                  allProducts.add({
                    'id': doc.id,
                    'name': title,
                    'price': (data['price'] ?? 0).toDouble(),
                    'unit': data['unit'] ?? 'kg',
                    'farmer': 'AgroLink Farm',
                    'farmerId': data['userId'],
                    'location': data['location'] ?? 'বাংলাদেশ',
                    'image': data['imageUrl'] ?? 'https://via.placeholder.com/150',
                    'rating': 4.5,
                    'category': data['category'] ?? 'other',
                    'badge': 'New',
                    'isVerified': true,
                  });
                }"""

if old_loop in content:
    content = content.replace(old_loop, new_loop)
    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(content)
    print("Successfully replaced loop")
else:
    print("Could not find loop to replace!")
