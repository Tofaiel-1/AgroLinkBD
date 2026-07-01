import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:agrolinkbd/core/services/card_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  final MobileScannerController _scannerController = MobileScannerController();
  bool _isProcessing = false;
  
  void _onDetect(BarcodeCapture capture) {
    if (_isProcessing) return;
    
    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      final rawValue = barcode.rawValue;
      if (rawValue != null && (rawValue.startsWith('sokol://pay') || rawValue.startsWith('agrolinkbd://pay'))) {
        setState(() => _isProcessing = true);
        _scannerController.stop();
        
        final uri = Uri.parse(rawValue);
        final payerUid = uri.queryParameters['uid'];
        
        if (payerUid != null) {
          _showRequestMoneySheet(payerUid);
          return;
        }
      }
    }
  }

  void _showRequestMoneySheet(String payerUid) {
    final amountController = TextEditingController();
    final noteController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            bool isPaying = false;
            
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 24, right: 24, top: 24
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('Request Money', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  Text('Requesting from UID: $payerUid', style: const TextStyle(color: Colors.grey)), // Ideally fetch name
                  const SizedBox(height: 24),
                  TextField(
                    controller: amountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Amount (BDT)',
                      prefixIcon: Icon(Icons.money),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: noteController,
                    decoration: const InputDecoration(
                      labelText: 'Note (Optional)',
                      prefixIcon: Icon(Icons.note),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green, padding: const EdgeInsets.all(16)),
                    onPressed: isPaying ? null : () async {
                      final amount = double.tryParse(amountController.text);
                      if (amount == null || amount <= 0) return;

                      setSheetState(() => isPaying = true);
                      
                      final currentUid = FirebaseAuth.instance.currentUser?.uid;
                      if (currentUid == null) return;

                      final success = await CardService().requestPayment(
                        requesterUid: currentUid,
                        payerUid: payerUid,
                        amount: amount,
                        note: noteController.text.isNotEmpty ? noteController.text : null,
                      );
                      
                      if (success) {
                        Navigator.pop(context); // close sheet
                        Navigator.pop(context); // close scanner
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Payment request sent successfully!'),
                            backgroundColor: Colors.green,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      } else {
                        setSheetState(() => isPaying = false);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Failed to send request. Please try again.'),
                            backgroundColor: Colors.red,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    },
                    child: isPaying
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('Send Request', style: TextStyle(color: Colors.white, fontSize: 16)),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          }
        );
      }
    ).then((_) {
      // If sheet is dismissed without paying, resume scanner
      if (mounted && _isProcessing) {
        setState(() => _isProcessing = false);
        _scannerController.start();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan Card')),
      body: MobileScanner(
        controller: _scannerController,
        onDetect: _onDetect,
      ),
    );
  }
}
