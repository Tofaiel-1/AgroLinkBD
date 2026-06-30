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

import '../../core/models/card_model.dart';
import '../../core/models/user_model.dart';
import 'qr_scanner_screen.dart';

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

      if (userDoc.exists && cardDoc.exists) {
        setState(() {
          _userModel = UserModel.fromJson(userDoc.data()!);
          _cardModel = CardModel.fromJson(cardDoc.data()!);
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading card data: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _shareCard() async {
    try {
      RenderRepaintBoundary boundary = _cardKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      final xFile = XFile.fromData(pngBytes, mimeType: 'image/png', name: 'sokol_card.png');
      await Share.shareXFiles([xFile], text: 'My Sokol Card');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error sharing: $e')));
    }
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
    if (_userModel == null || _cardModel == null) {
      return const Scaffold(body: Center(child: Text('Card Data not found.')));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Sokol Card'),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const QrScannerScreen())),
          )
        ],
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
                    )
                  ],
                ),
              ),
            ),
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
