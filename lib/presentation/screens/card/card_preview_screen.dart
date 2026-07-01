import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:ui' as ui;
import 'dart:typed_data';

import 'package:agrolinkbd/core/models/card_model.dart';
import 'package:agrolinkbd/core/models/user_model.dart';
import 'package:agrolinkbd/core/services/card_service.dart';
import 'qr_scanner_screen.dart';
import 'widgets/pending_requests_widget.dart';

class CardPreviewScreen extends StatefulWidget {
  const CardPreviewScreen({super.key});

  @override
  State<CardPreviewScreen> createState() => _CardPreviewScreenState();
}

class _CardPreviewScreenState extends State<CardPreviewScreen> {
  final GlobalKey _cardKey = GlobalKey();
  UserModel? _userModel;
  CardModel? _cardModel;
  bool _isLoading = true;
  bool _showWalletBalance = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    try {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final cardDoc = await FirebaseFirestore.instance.collection('cards').doc(uid).get();

      if (userDoc.exists) {
        _userModel = UserModel.fromJson(userDoc.data()!);
      }
      
      if (cardDoc.exists) {
        _cardModel = CardModel.fromJson(cardDoc.data()!);
      }
      
      if (mounted) {
        setState(() => _isLoading = false);
      }
      
      if (_cardModel != null && _cardModel!.walletPin == null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showSetPinDialog(uid);
        });
      }
    } catch (e) {
      print('Error loading card data: $e');
      setState(() => _isLoading = false);
    }
  }

  void _showAddMoneyDialog(String uid) {
    final amountController = TextEditingController();
    bool isProcessing = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Add Money to Wallet'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Deposit money from your main account into this card wallet.', style: TextStyle(fontSize: 14, color: Colors.grey)),
                const SizedBox(height: 16),
                TextField(
                  controller: amountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Amount (BDT)',
                    prefixIcon: Icon(Icons.money),
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: isProcessing ? null : () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: isProcessing ? null : () async {
                  final amount = double.tryParse(amountController.text);
                  if (amount == null || amount <= 0) return;
                  
                  setDialogState(() => isProcessing = true);
                  final success = await CardService().addMoneyToWallet(uid, amount);
                  
                  if (mounted) {
                    Navigator.pop(context);
                    if (success) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Money added successfully!'), backgroundColor: Colors.green));
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to add money.'), backgroundColor: Colors.red));
                    }
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: isProcessing ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('Add Money', style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        });
      }
    );
  }

  void _showSetPinDialog(String uid) {
    final pinController = TextEditingController();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('Setup Wallet PIN'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Please set a 4-digit PIN for your wallet to secure transactions.'),
              const SizedBox(height: 16),
              TextField(
                controller: pinController,
                keyboardType: TextInputType.number,
                maxLength: 4,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: '4-Digit PIN',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () async {
                if (pinController.text.length == 4) {
                  await CardService().setWalletPin(uid, pinController.text);
                  Navigator.pop(context);
                  _loadData(); // reload
                }
              },
              child: const Text('Set PIN'),
            ),
          ],
        );
      }
    );
  }

  Future<void> _shareCard() async {
    try {
      RenderRepaintBoundary boundary = _cardKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      final xFile = XFile.fromData(pngBytes, mimeType: 'image/png', name: 'sokol_card.png');
      await Share.shareXFiles([xFile], text: 'Card');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error sharing: $e')));
    }
  }

  void _verifyPinAndShowBalance() {
    final pinController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Enter Wallet PIN'),
          content: TextField(
            controller: pinController,
            obscureText: true,
            keyboardType: TextInputType.number,
            maxLength: 4,
            decoration: const InputDecoration(labelText: '4-Digit PIN', border: OutlineInputBorder()),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                if (pinController.text == _cardModel?.walletPin) {
                  Navigator.pop(context);
                  setState(() => _showWalletBalance = true);
                  Future.delayed(const Duration(seconds: 5), () {
                    if (mounted) setState(() => _showWalletBalance = false);
                  });
                } else {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Incorrect PIN!'), backgroundColor: Colors.red));
                }
              },
              child: const Text('Verify'),
            ),
          ],
        );
      }
    );
  }

  Future<void> _printCard() async {
    if (_cardModel == null || _userModel == null) return;
    
    final doc = pw.Document();
    doc.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Container(
              width: 400,
              height: 250,
              decoration: pw.BoxDecoration(
                color: PdfColors.green100,
                borderRadius: pw.BorderRadius.circular(20),
              ),
              padding: const pw.EdgeInsets.all(20),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    mainAxisAlignment: pw.MainAxisAlignment.center,
                    children: [
                      pw.Text(_userModel!.name, style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
                      pw.SizedBox(height: 10),
                      pw.Text('Role: ${_userModel!.userType.name.toUpperCase()}'),
                      pw.Text('Phone: ${_userModel!.phone}'),
                    ]
                  ),
                  pw.BarcodeWidget(
                    barcode: pw.Barcode.qrCode(),
                    data: _cardModel!.qrData,
                    width: 100,
                    height: 100,
                  )
                ]
              )
            )
          );
        },
      ),
    );
    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => doc.save());
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_userModel == null) {
      return const Scaffold(body: Center(child: Text('User Data not found. Please log in again.')));
    }
    
    if (_cardModel == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Activate Card')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.credit_card_off, size: 80, color: Colors.grey),
              const SizedBox(height: 16),
              const Text(
                'You do not have an active Card yet.',
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Activate Card', style: TextStyle(fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade700,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  elevation: 4,
                ),
                onPressed: () async {
                  setState(() => _isLoading = true);
                  final uid = FirebaseAuth.instance.currentUser?.uid;
                  if (uid != null) {
                    await CardService().createCard(uid);
                    await _loadData(); // reload the data
                  }
                },
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Card'),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const QrScannerScreen())),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const QrScannerScreen())),
        backgroundColor: Colors.green.shade700,
        icon: const Icon(Icons.qr_code_scanner, color: Colors.white),
        label: const Text('Scan QR & Request', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            RepaintBoundary(
              key: _cardKey,
              child: Container(
                width: 350,
                height: 200,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.green, Colors.teal],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 5))],
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const CircleAvatar(
                            radius: 30,
                            backgroundColor: Colors.white,
                            child: Icon(Icons.person, size: 40, color: Colors.green),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _userModel!.name,
                            style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _userModel!.userType.name.toUpperCase(),
                            style: const TextStyle(color: Colors.white70, fontSize: 14),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: List.generate(5, (index) => Icon(
                              index < _cardModel!.averageRating.round() ? Icons.star : Icons.star_border, 
                              color: Colors.amber, 
                              size: 16
                            )),
                          )
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                        child: QrImageView(
                          data: _cardModel!.qrData,
                          version: QrVersions.auto,
                          size: 100.0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Wallet Balance
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              width: 350,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2))],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Wallet Balance', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: _showWalletBalance ? null : _verifyPinAndShowBalance,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.green.shade200),
                          ),
                          child: Text(
                            _showWalletBalance ? '৳${_cardModel!.walletBalance.toStringAsFixed(2)}' : 'Tap for Balance',
                            style: TextStyle(fontSize: _showWalletBalance ? 22 : 16, fontWeight: FontWeight.bold, color: Colors.green),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: () => _showAddMoneyDialog(_userModel!.id),
                        child: const Text('+ Add Money', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 14)),
                      )
                    ],
                  ),
                ],
              ),
            ),
            
            // Pending Requests Widget
            const SizedBox(height: 16),
            const PendingRequestsWidget(),
            
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: _shareCard,
                  icon: const Icon(Icons.share),
                  label: const Text('Save / Share'),
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12)),
                ),
                ElevatedButton.icon(
                  onPressed: _printCard,
                  icon: const Icon(Icons.print),
                  label: const Text('Print Card'),
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12)),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Card(
              child: ListTile(
                leading: Icon(_cardModel!.verificationStatus ? Icons.verified : Icons.pending, color: _cardModel!.verificationStatus ? Colors.green : Colors.orange),
                title: Text(_cardModel!.verificationStatus ? 'Verified Member' : 'Verification Pending'),
                subtitle: Text('Card Version: ${_cardModel!.cardVersion}'),
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.location_on),
                title: const Text('Address'),
                subtitle: Text(_userModel!.address ?? 'Not provided'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
