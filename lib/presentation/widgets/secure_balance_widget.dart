import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:agrolinkbd/core/controllers/user_controller.dart';

class SecureBalanceWidget extends StatefulWidget {
  final double balance;
  final String? pin;
  final String pinFieldType; // 'mainBalance' or 'walletBalance'
  final Color textColor;
  final double fontSize;
  final String label;

  const SecureBalanceWidget({
    super.key,
    required this.balance,
    required this.pin,
    this.pinFieldType = 'mainBalance',
    this.textColor = Colors.white,
    this.fontSize = 14.0,
    this.label = 'Tap for Balance',
  });

  @override
  State<SecureBalanceWidget> createState() => _SecureBalanceWidgetState();
}

class _SecureBalanceWidgetState extends State<SecureBalanceWidget> {
  bool _showBalance = false;

  void _requestPinReset() async {
    final userController = Get.isRegistered<UserController>()
        ? Get.find<UserController>()
        : Get.put(UserController());

    Navigator.pop(context); // Close PIN dialog
    try {
      await FirebaseFirestore.instance.collection('pin_reset_requests').add({
        'userId': FirebaseAuth.instance.currentUser!.uid,
        'userName': userController.userName,
        'type': widget.pinFieldType,
        'status': 'pending',
        'timestamp': FieldValue.serverTimestamp(),
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('PIN reset request sent to Admin.')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')));
      }
    }
  }

  void _showEnterPinDialog() {
    final pinController = TextEditingController();
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Enter PIN'),
            content: TextField(
              controller: pinController,
              obscureText: true,
              keyboardType: TextInputType.number,
              maxLength: 4,
              decoration: const InputDecoration(
                  labelText: '4-Digit PIN', border: OutlineInputBorder()),
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel')),
              TextButton(
                  onPressed: _requestPinReset,
                  child: const Text('Forgot PIN?',
                      style: TextStyle(color: Colors.red))),
              ElevatedButton(
                onPressed: () {
                  if (pinController.text == widget.pin) {
                    Navigator.pop(context);
                    setState(() => _showBalance = true);
                    Future.delayed(const Duration(seconds: 3), () {
                      if (mounted) setState(() => _showBalance = false);
                    });
                  } else {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Incorrect PIN!'),
                        backgroundColor: Colors.red));
                  }
                },
                child: const Text('Verify'),
              ),
            ],
          );
        });
  }

  void _showSetPinDialog() {
    final pinController = TextEditingController();
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Create Security PIN'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Set a 4-digit PIN to secure your balance.',
                    style: TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 12),
                TextField(
                  controller: pinController,
                  obscureText: true,
                  keyboardType: TextInputType.number,
                  maxLength: 4,
                  decoration: const InputDecoration(
                      labelText: '4-Digit PIN', border: OutlineInputBorder()),
                ),
              ],
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel')),
              ElevatedButton(
                onPressed: () async {
                  if (pinController.text.length == 4) {
                    Navigator.pop(context);
                    
                    String fieldToUpdate = widget.pinFieldType == 'mainBalance' 
                        ? 'mainBalancePin' 
                        : 'walletPin';
                    
                    // If it's a main balance, it's stored in users collection.
                    // If wallet balance, we assume it's in cards collection or users depending on logic.
                    // For now, let's update both in users collection to keep it simple, or explicitly use cards for wallet.
                    if (widget.pinFieldType == 'walletBalance') {
                      await FirebaseFirestore.instance
                          .collection('cards')
                          .doc(FirebaseAuth.instance.currentUser!.uid)
                          .set({fieldToUpdate: pinController.text}, SetOptions(merge: true));
                    } else {
                       await FirebaseFirestore.instance
                          .collection('users')
                          .doc(FirebaseAuth.instance.currentUser!.uid)
                          .update({fieldToUpdate: pinController.text});
                    }

                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('PIN created! You can now view your balance.')));
                  }
                },
                child: const Text('Save PIN'),
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (_showBalance) return;
        if (widget.pin == null || widget.pin!.isEmpty) {
          _showSetPinDialog();
        } else {
          _showEnterPinDialog();
        }
      },
      child: Text(
        _showBalance ? '৳${widget.balance.toStringAsFixed(0)}' : widget.label,
        style: TextStyle(
          color: widget.textColor,
          fontSize: widget.fontSize,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
