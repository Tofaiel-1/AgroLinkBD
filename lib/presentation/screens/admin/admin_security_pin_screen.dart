import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:agrolinkbd/core/providers/admin_provider.dart';

class AdminSecurityPinScreen extends StatefulWidget {
  const AdminSecurityPinScreen({super.key});

  @override
  State<AdminSecurityPinScreen> createState() => _AdminSecurityPinScreenState();
}

class _AdminSecurityPinScreenState extends State<AdminSecurityPinScreen> with SingleTickerProviderStateMixin {
  String _pin = '';
  int _attemptsLeft = 3;
  bool _isError = false;
  late AnimationController _shakeController;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  void _onKeyPress(String key) {
    if (_pin.length < 6) {
      setState(() {
        _pin += key;
        _isError = false;
      });
      
      if (_pin.length == 6) {
        _verifyPin();
      }
    }
  }

  void _onDelete() {
    if (_pin.isNotEmpty) {
      setState(() {
        _pin = _pin.substring(0, _pin.length - 1);
        _isError = false;
      });
    }
  }

  Future<void> _verifyPin() async {
    final provider = Provider.of<AdminProvider>(context, listen: false);
    final success = await provider.verifyPin(_pin);
    
    if (success) {
      // AppRouter will automatically pick up the state change and route to Dashboard
      Get.snackbar(
        'Access Granted',
        'Security PIN verified.',
        backgroundColor: Colors.green.withOpacity(0.9),
        colorText: Colors.white,
      );
    } else {
      _shakeController.forward(from: 0.0);
      setState(() {
        _pin = '';
        _isError = true;
        _attemptsLeft--;
      });
      
      if (_attemptsLeft <= 0) {
        Get.snackbar(
          'Security Breach',
          'Too many failed attempts. You have been forcefully logged out.',
          backgroundColor: Colors.red.withOpacity(0.9),
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
        );
        await provider.adminSignOut();
      } else {
        Get.snackbar(
          'Access Denied',
          'Incorrect PIN. $_attemptsLeft attempts remaining.',
          backgroundColor: Colors.orange.withOpacity(0.9),
          colorText: Colors.white,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0F19), // Deep Neon Dark
      body: SafeArea(
        child: Stack(
          children: [
            // Glowing Orbs
            Positioned(
              top: -50,
              left: -100,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFFEF4444).withOpacity(0.15)),
              ),
            ),
            Positioned(
              bottom: -150,
              right: -50,
              child: Container(
                width: 400,
                height: 400,
                decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFF8B5CF6).withOpacity(0.1)),
              ),
            ),
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
              child: Container(color: Colors.transparent),
            ),

            Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: AnimatedBuilder(
                    animation: _shakeController,
                    builder: (context, child) {
                      final dx = _isError ? 10 * (0.5 - (0.5 - _shakeController.value).abs()) * 2 : 0.0;
                      return Transform.translate(
                        offset: Offset(dx, 0),
                        child: child,
                      );
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Shield Icon
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.05),
                            border: Border.all(color: _isError ? Colors.redAccent.withOpacity(0.5) : const Color(0xFF8B5CF6).withOpacity(0.5)),
                            boxShadow: [
                              BoxShadow(
                                color: (_isError ? Colors.redAccent : const Color(0xFF8B5CF6)).withOpacity(0.2),
                                blurRadius: 30,
                                spreadRadius: 5,
                              )
                            ]
                          ),
                          child: Icon(Icons.admin_panel_settings_rounded, size: 50, color: _isError ? Colors.redAccent : Colors.white),
                        ),
                        const SizedBox(height: 30),
                        const Text(
                          'RESTRICTED ACCESS',
                          style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: 2),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Enter Master Security PIN to proceed',
                          style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 14),
                        ),
                        const SizedBox(height: 40),
                        
                        // PIN Dots
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(6, (index) {
                            final isFilled = index < _pin.length;
                            return Container(
                              margin: const EdgeInsets.symmetric(horizontal: 8),
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isFilled 
                                    ? (_isError ? Colors.redAccent : Colors.white) 
                                    : Colors.transparent,
                                border: Border.all(
                                  color: _isError ? Colors.redAccent : Colors.white.withOpacity(isFilled ? 1.0 : 0.2),
                                  width: 2,
                                ),
                                boxShadow: isFilled ? [
                                  BoxShadow(
                                    color: (_isError ? Colors.redAccent : Colors.white).withOpacity(0.5),
                                    blurRadius: 10,
                                    spreadRadius: 2,
                                  )
                                ] : null,
                              ),
                            );
                          }),
                        ),
                        
                        const SizedBox(height: 20),
                        if (_isError)
                          Text(
                            'Incorrect PIN. $_attemptsLeft attempts remaining.',
                            style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
                          ),
                        
                        const SizedBox(height: 40),
                        
                        // Keypad
                        _buildKeypad(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKeypad() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 320),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildKey('1'), _buildKey('2'), _buildKey('3'),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildKey('4'), _buildKey('5'), _buildKey('6'),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildKey('7'), _buildKey('8'), _buildKey('9'),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const SizedBox(width: 70), // Empty space for layout balance
              _buildKey('0'),
              _buildActionKey(
                icon: Icons.backspace_rounded,
                onTap: _onDelete,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKey(String value) {
    return GestureDetector(
      onTap: () => _onKeyPress(value),
      child: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(0.05),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Center(
          child: Text(
            value,
            style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w300),
          ),
        ),
      ),
    );
  }

  Widget _buildActionKey({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 70,
        height: 70,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.transparent,
        ),
        child: Center(
          child: Icon(icon, color: Colors.white.withOpacity(0.5), size: 28),
        ),
      ),
    );
  }
}
