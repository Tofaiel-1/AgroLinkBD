import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';

class AiAssistantScreen extends StatefulWidget {
  const AiAssistantScreen({super.key});

  @override
  State<AiAssistantScreen> createState() => _AiAssistantScreenState();
}

class _AiAssistantScreenState extends State<AiAssistantScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [
    {
      'text': 'হ্যালো! আমি আপনার এআই ফার্মিং কনসালটেন্ট। আমি কীভাবে আপনাকে সাহায্য করতে পারি?',
      'isUser': false,
    },
  ];
  bool _isTyping = false;

  void _sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    
    setState(() {
      _messages.add({'text': text, 'isUser': true});
      _isTyping = true;
    });
    _messageController.clear();

    // Simulate AI response
    await Future.delayed(const Duration(seconds: 2));
    
    // Determine dynamic response based on input
    String aiResponse = 'আপনার প্রশ্নটি আমি বুঝতে পেরেছি। তবে এই বিষয়ে বিস্তারিত জানতে অনুগ্রহ করে আমাদের এক্সপার্টদের সাথে যোগাযোগ করুন।';
    
    if (text.toLowerCase().contains('কীটনাশক') || text.toLowerCase().contains('পোকা')) {
      aiResponse = 'কীটনাশক বা পোকার আক্রমণের জন্য আপনি জৈব বালাইনাশক বা নিম তেল ব্যবহার করতে পারেন। যদি আক্রমণ বেশি হয়, তবে বিশেষজ্ঞের পরামর্শে অনুমোদিত কীটনাশক স্প্রে করুন।';
    } else if (text.toLowerCase().contains('সার') || text.toLowerCase().contains('নিয়ম')) {
      aiResponse = 'সার প্রয়োগের ক্ষেত্রে মাটির আর্দ্রতা থাকা জরুরি। ইউরিয়া সার সাধারণত কয়েক কিস্তিতে দিতে হয়। সার দেওয়ার পর হালকা সেচ দিলে ভালো ফলাফল পাওয়া যায়।';
    } else if (text.toLowerCase().contains('বাজার') || text.toLowerCase().contains('দর')) {
      aiResponse = 'বাজার দর প্রতিদিন পরিবর্তিত হয়। তবে বর্তমান ট্রেণ্ড অনুযায়ী সবজির দাম কিছুটা ঊর্ধ্বমুখী। আপনি মার্কেটপ্লেস সেকশনে গিয়ে আজকের আপডেট দর দেখে নিতে পারেন।';
    } else if (text.toLowerCase().contains('হ্যালো') || text.toLowerCase().contains('হাই')) {
      aiResponse = 'হ্যালো! আমি প্রস্তুত আপনাকে সাহায্য করার জন্য। আপনার কৃষি বা সার্ভিস সম্পর্কিত যেকোনো প্রশ্ন করতে পারেন।';
    }

    setState(() {
      _isTyping = false;
      _messages.add({
        'text': aiResponse,
        'isUser': false,
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87),
          onPressed: () => Get.back(),
        ),
        title: Column(
          children: [
            Text(
              'স্মার্ট এআই কনসালটেন্ট',
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: const Color(0xFF1E293B), fontSize: 18),
            ),
            Text(
              'অনলাইনে আছেন',
              style: GoogleFonts.poppins(color: Colors.green, fontSize: 12),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert_rounded, color: Colors.black87),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Suggestions
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _buildSuggestionChip('কীটনাশক পরামর্শ'),
                  _buildSuggestionChip('সার প্রয়োগের নিয়ম'),
                  _buildSuggestionChip('বাজার দর'),
                ],
              ),
            ),
          ),
          
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length) {
                  return _buildTypingIndicator();
                }
                final msg = _messages[index];
                return _buildMessageBubble(msg['text'], msg['isUser']);
              },
            ),
          ),
          
          // Input Area
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5)),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F4F8),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.mic_none_rounded, color: Color(0xFF2B32B2)),
                      onPressed: () {},
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'আপনার প্রশ্ন লিখুন...',
                        hintStyle: GoogleFonts.poppins(color: Colors.grey.shade400, fontSize: 14),
                        filled: true,
                        fillColor: const Color(0xFFF0F4F8),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                      onSubmitted: _sendMessage,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFF2B32B2),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                      onPressed: () => _sendMessage(_messageController.text),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionChip(String text) {
    return GestureDetector(
      onTap: () => _sendMessage(text),
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF2B32B2).withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF2B32B2).withOpacity(0.2)),
        ),
        child: Text(
          text,
          style: GoogleFonts.poppins(color: const Color(0xFF2B32B2), fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildMessageBubble(String text, bool isUser) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isUser ? const Color(0xFF2B32B2) : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: isUser ? const Radius.circular(20) : const Radius.circular(4),
            bottomRight: isUser ? const Radius.circular(4) : const Radius.circular(20),
          ),
          boxShadow: [
            if (!isUser) BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Text(
          text,
          style: GoogleFonts.poppins(
            color: isUser ? Colors.white : const Color(0xFF1E293B),
            fontSize: 14,
            height: 1.4,
          ),
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
            bottomLeft: Radius.circular(4),
            bottomRight: Radius.circular(20),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDot(0),
            const SizedBox(width: 4),
            _buildDot(150),
            const SizedBox(width: 4),
            _buildDot(300),
          ],
        ),
      ),
    );
  }

  Widget _buildDot(int delay) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOutSine,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, -5 * (value)),
          child: Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Color(0xFF2B32B2),
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }
}
