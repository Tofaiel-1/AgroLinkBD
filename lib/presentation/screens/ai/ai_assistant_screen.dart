import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:agrolinkbd/core/utils/responsive_helper.dart';

class AIAssistantScreen extends StatefulWidget {
  const AIAssistantScreen({super.key});

  @override
  State<AIAssistantScreen> createState() => _AIAssistantScreenState();
}

class _AIAssistantScreenState extends State<AIAssistantScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [
    {
      'text': 'Hello! I am your agricultural assistant. How can I help you?',
      'isUser': false,
      'time': 'এখন',
    },
  ];

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    setState(() {
      _messages.add({
        'text': _messageController.text,
        'isUser': true,
        'time': 'এখন',
      });

      // AI Response (dummy)
      Future.delayed(const Duration(seconds: 1), () {
        setState(() {
          _messages.add({
            'text':
                'আপনার প্রশ্নের উত্তর দিচ্ছি... এটি একটি ডেমো রেসপন্স। পরে AI integration করা হবে।',
            'isUser': false,
            'time': 'এখন',
          });
        });
      });
    });

    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E7D32),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.smart_toy, color: Colors.green.shade700),
            ),
            const SizedBox(width: 12),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI সহায়ক',
                  style: TextStyle(fontSize: 18),
                ),
                Text(
                  'অনলাইন',
                  style: TextStyle(fontSize: 12, color: Colors.white70),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Quick Actions
          Container(
            padding: ResponsiveHelper.getResponsivePadding(context),
            color: Colors.white,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildQuickAction('মাটি পরীক্ষা', Icons.science),
                  _buildQuickAction('রোগ নির্ণয়', Icons.health_and_safety),
                  _buildQuickAction('আবহাওয়া', Icons.cloud),
                  _buildQuickAction('Market Price', Icons.trending_up),
                ],
              ),
            ),
          ),

          // Messages
          Expanded(
            child: ListView.builder(
              padding: ResponsiveHelper.getResponsivePadding(context),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return _buildMessageBubble(
                  message['text'],
                  message['isUser'],
                  message['time'],
                );
              },
            ),
          ),

          // Input Field
          Container(
            padding: ResponsiveHelper.getResponsivePadding(context),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.mic, color: Colors.green.shade700),
                  onPressed: () {},
                ),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'আপনার প্রশ্ন লিখুন...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: Colors.green.shade700,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white, size: 20),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAction(String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ActionChip(
        avatar: Icon(icon, size: 18, color: Colors.green.shade700),
        label: Text(label),
        onPressed: () {
          _messageController.text = label;
        },
        backgroundColor: Colors.green.shade50,
      ),
    );
  }

  Widget _buildMessageBubble(String text, bool isUser, String time) {
    // Responsive max width: 75% on phone, 60% on tablet, 50% on desktop
    double maxWidth = ResponsiveHelper.isPhone(context)
        ? MediaQuery.of(context).size.width * 0.75
        : ResponsiveHelper.isTablet(context)
            ? MediaQuery.of(context).size.width * 0.6
            : MediaQuery.of(context).size.width * 0.5;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: ResponsiveHelper.isPhone(context)
            ? const EdgeInsets.only(bottom: 12)
            : const EdgeInsets.only(bottom: 16),
        padding: ResponsiveHelper.isPhone(context)
            ? const EdgeInsets.symmetric(horizontal: 16, vertical: 10)
            : const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        constraints: BoxConstraints(maxWidth: maxWidth),
        decoration: BoxDecoration(
          color: isUser ? Colors.green.shade700 : Colors.white,
          borderRadius: BorderRadius.circular(16).copyWith(
            bottomRight: isUser ? const Radius.circular(4) : null,
            bottomLeft: !isUser ? const Radius.circular(4) : null,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              text,
              style: TextStyle(
                color: isUser ? Colors.white : Colors.black87,
                fontSize: ResponsiveHelper.getResponsiveFontSize(context, 15),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              time,
              style: TextStyle(
                color: isUser ? Colors.white70 : Colors.grey,
                fontSize: ResponsiveHelper.getResponsiveFontSize(context, 11),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
