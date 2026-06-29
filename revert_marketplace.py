import os

files = [
    "lib/presentation/screens/dashboard/buyer_dashboard_screen.dart",
    "lib/presentation/screens/dashboard/farmer_dashboard_screen.dart",
    "lib/presentation/screens/home/widgets/quick_actions_grid.dart",
    "lib/presentation/screens/profile/profile_screen.dart",
]

for file_path in files:
    if os.path.exists(file_path):
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
            
        content = content.replace("import 'package:agrolinkbd/presentation/screens/bazaar/bazaar_home.dart';", "import 'package:agrolinkbd/presentation/screens/marketplace/marketplace_screen.dart';")
        content = content.replace("Get.to(() => const BazaarHome())", "Get.to(() => const MarketplaceScreen())")
        
        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(content)
            
print("Reverted to MarketplaceScreen")
