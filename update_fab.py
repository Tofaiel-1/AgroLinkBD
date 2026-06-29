import sys

file_path = "lib/presentation/screens/marketplace/marketplace_screen.dart"

with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

# Ensure we import Provider and UserProvider
if "import 'package:provider/provider.dart';" not in content:
    content = content.replace("import 'package:flutter/material.dart';", "import 'package:flutter/material.dart';\nimport 'package:provider/provider.dart';\nimport 'package:agrolinkbd/core/providers/user_provider.dart';\nimport 'package:agrolinkbd/core/models/user_model.dart';")

# Find the build method and add the provider check
build_start = content.find("  Widget build(BuildContext context) {")
if build_start != -1:
    new_build_start = """  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final isFarmer = userProvider.currentUser?.userType == UserType.farmer;
"""
    content = content[:build_start] + new_build_start + content[build_start + len("  Widget build(BuildContext context) {"):]

# Replace the FAB
old_fab = """      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Get.to(() => const AddProductScreen());
        },
        backgroundColor: const Color(0xFF1B5E20),
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text('পণ্য যোগ করুন', style: GoogleFonts.hindSiliguri(color: Colors.white, fontWeight: FontWeight.bold)),
      ),"""
new_fab = """      floatingActionButton: isFarmer ? FloatingActionButton.extended(
        onPressed: () {
          Get.to(() => const AddProductScreen());
        },
        backgroundColor: const Color(0xFF1B5E20),
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text('পণ্য যোগ করুন', style: GoogleFonts.hindSiliguri(color: Colors.white, fontWeight: FontWeight.bold)),
      ) : null,"""

if old_fab in content:
    content = content.replace(old_fab, new_fab)

with open(file_path, 'w', encoding='utf-8') as f:
    f.write(content)
print("Updated FAB for farmers")
