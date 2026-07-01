import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:agrolinkbd/core/models/payment_request_model.dart';
import 'package:agrolinkbd/core/services/card_service.dart';

class PendingRequestsWidget extends StatelessWidget {
  const PendingRequestsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return const SizedBox.shrink();

    return StreamBuilder<List<PaymentRequestModel>>(
      stream: CardService().getIncomingRequests(uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        final requests = snapshot.data ?? [];
        if (requests.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                'Payment Requests',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: requests.length,
              itemBuilder: (context, index) {
                final request = requests[index];
                return _RequestTile(request: request, uid: uid);
              },
            ),
          ],
        );
      },
    );
  }
}

class _RequestTile extends StatefulWidget {
  final PaymentRequestModel request;
  final String uid;

  const _RequestTile({required this.request, required this.uid});

  @override
  State<_RequestTile> createState() => _RequestTileState();
}

class _RequestTileState extends State<_RequestTile> {
  bool _isProcessing = false;

  void _showPinDialog() {
    final pinController = TextEditingController();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('Enter Wallet PIN'),
          content: TextField(
            controller: pinController,
            obscureText: true,
            keyboardType: TextInputType.number,
            maxLength: 4,
            decoration: const InputDecoration(
              labelText: '4-Digit PIN',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final pin = pinController.text;
                if (pin.length != 4) return;
                
                Navigator.pop(context); // Close dialog
                setState(() => _isProcessing = true);
                
                try {
                  final success = await CardService().acceptPaymentRequest(
                    widget.request.requestId,
                    widget.uid,
                    pin,
                  );
                  
                  if (mounted) {
                    setState(() => _isProcessing = false);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(success ? 'Payment Successful' : 'Invalid PIN or Insufficient Balance'),
                        backgroundColor: success ? Colors.green : Colors.red,
                      )
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    setState(() => _isProcessing = false);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(e.toString()),
                        backgroundColor: Colors.red,
                      )
                    );
                  }
                }
              },
              child: const Text('Confirm'),
            ),
          ],
        );
      }
    );
  }

  void _rejectRequest() async {
    setState(() => _isProcessing = true);
    await CardService().rejectPaymentRequest(widget.request.requestId);
    if (mounted) {
      setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Colors.orange,
          child: Icon(Icons.receipt, color: Colors.white),
        ),
        title: Text('Amount: ৳${widget.request.amount.toStringAsFixed(2)}'),
        subtitle: Text(widget.request.note ?? 'No note'),
        trailing: _isProcessing 
          ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.red),
                  onPressed: _rejectRequest,
                ),
                ElevatedButton(
                  onPressed: _showPinDialog,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  child: const Text('Pay', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
      ),
    );
  }
}
