import os

files_to_update = [
    'lib/presentation/screens/dashboard_screen.dart'
]

for file_path in files_to_update:
    if not os.path.exists(file_path):
        continue
        
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
        
    if 'import \'package:agrolinkbd/presentation/screens/marketplace/marketplace_screen_new.dart\';' in content:
        content = content.replace(
            'import \'package:agrolinkbd/presentation/screens/marketplace/marketplace_screen_new.dart\';',
            'import \'package:agrolinkbd/presentation/screens/bazaar/bazaar_home.dart\';'
        )
        
    content = content.replace('MarketplaceScreenNew()', 'BazaarHome()')
    
    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(content)
    
    print(f"Updated {file_path}")

