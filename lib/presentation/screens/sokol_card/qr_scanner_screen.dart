import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../core/services/sokol_card_service.dart';

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
      if (rawValue != null && rawValue.startsWith('sokol://pay')) {
        setState(() => _isProcessing = true);
        _scannerController.stop();
        
        final uri = Uri.parse(rawValue);
        final receiverUid = uri.queryParameters['uid'];
        
        if (receiverUid != null) {
          _showPaymentSheet(receiverUid);
          return;
        }
      }
    }
  }

  void _showPaymentSheet(String receiverUid) {
    final amountController = TextEditingController();
    String selectedMethod = 'SokolWallet';

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
                  const Text('Payment Confirmation', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  Text('Paying to UID: $receiverUid', style: const TextStyle(color: Colors.grey)), // Ideally fetch name
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
                  DropdownButtonFormField<String>(
                    value: selectedMethod,
                    items: ['SokolWallet', 'BKash', 'Nagad', 'Bank'].map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
                    onChanged: (v) => setSheetState(() => selectedMethod = v!),
                    decoration: const InputDecoration(labelText: 'Payment Method', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green, padding: const EdgeInsets.all(16)),
                    onPressed: isPaying ? null : () async {
                      final amount = double.tryParse(amountController.text);
                      if (amount == null || amount <= 0) return;

                      setSheetState(() => isPaying = true);
                      
                      final success = await SokolCardService().processPayment(
                        receiverUid: receiverUid,
                        amount: amount,
                        paymentMethod: selectedMethod,
                      );
                      
                      if (mounted) {
                        Navigator.pop(context); // close sheet
                        Navigator.pop(context); // close scanner
                        
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(success ? 'Payment Successful!' : 'Payment Failed'),
                            backgroundColor: success ? Colors.green : Colors.red,
                          )
                        );
                      }
                    },
                    child: isPaying
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Confirm Payment', style: TextStyle(color: Colors.white, fontSize: 18)),
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
      appBar: AppBar(title: const Text('Scan Sokol Card')),
      body: MobileScanner(
        controller: _scannerController,
        onDetect: _onDetect,
      ),
    );
  }
}
