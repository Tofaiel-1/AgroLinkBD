import sys

file_path = 'lib/presentation/screens/navigation/role_based_navigation.dart'

with open(file_path, 'r', encoding='utf-8') as f:
    lines = f.readlines()

# The file got duplicated. Lines 1 to 78 are the duplicate top half.
# The real file starts again at line 2.
# Let's find the correct top part.
# The actual file should start with imports.

correct_lines = []

# Wait, let's just restore it from scratch or manually fix it.
# Lines 1 to 78 are broken. Line 79 is "import 'package:agrolinkbd/presentation/screens/service_provider/service_provider_orders_screen.dart';"
# Line 80 is "/// Role-Based Navigation"
# So lines 1 to 78 are completely garbage. We need the original imports, but replacing BazaarHome with LoadBoardScreen for driver.

imports = """import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:agrolinkbd/core/providers/user_provider.dart';

// Role-specific dashboards
import 'package:agrolinkbd/presentation/screens/farmer/farmer_dashboard.dart';
import 'package:agrolinkbd/presentation/screens/buyer/buyer_dashboard.dart';
import 'package:agrolinkbd/presentation/screens/driver/driver_dashboard.dart';
import 'package:agrolinkbd/presentation/screens/driver/load_board/load_board_screen.dart';
import 'package:agrolinkbd/presentation/screens/service_provider/service_provider_dashboard.dart';

// Fallback screens
import 'package:agrolinkbd/presentation/screens/dashboard/enhanced_dashboard.dart';
import 'package:agrolinkbd/presentation/screens/profile/profile_settings.dart';
import 'package:agrolinkbd/presentation/screens/notifications/notification_center.dart';
import 'package:agrolinkbd/presentation/screens/notifications/driver_notifications.dart';
import 'package:agrolinkbd/presentation/screens/bazaar/bazaar_home.dart';
import 'package:agrolinkbd/presentation/screens/service_provider/service_provider_products_screen.dart';
import 'package:agrolinkbd/presentation/screens/service_provider/service_provider_orders_screen.dart';
"""

# Now write the rest of the file from line 81 onwards
rest_of_file = lines[80:]

with open(file_path, 'w', encoding='utf-8') as f:
    f.write(imports + '\n' + ''.join(rest_of_file))
print("Fixed role_based_navigation.dart")
