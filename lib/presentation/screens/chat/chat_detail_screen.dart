import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:agrolinkbd/core/theme/app_colors.dart';
import 'package:agrolinkbd/core/theme/app_typography.dart';
import 'package:agrolinkbd/core/theme/app_widgets.dart';
import 'package:agrolinkbd/core/providers/user_provider.dart';
import 'package:agrolinkbd/core/providers/chat_provider.dart';
import 'package:agrolinkbd/core/services/chat_service.dart';

class ChatDetailScreen extends StatefulWidget {
  final Conversation conversation;

  const ChatDetailScreen({
    Key? key,
    required this.conversation,
  }) : super(key: key);

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  late TextEditingController _messageController;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _messageController = TextEditingController();
    _scrollController = ScrollController();

    // Load messages
    context.read<ChatProvider>().loadMessages(widget.conversation.id);

    // Mark as read
    final userProvider = context.read<UserProvider>();
    if (userProvider.user != null) {
      context.read<ChatProvider>().markConversationAsRead(
          widget.conversation.id, userProvider.user!.id);
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final userProvider = context.read<UserProvider>();
    final chatProvider = context.read<ChatProvider>();

    if (userProvider.user == null) return;

    final success = await chatProvider.sendMessage(
      conversationId: widget.conversation.id,
      senderId: userProvider.user!.id,
      senderName: userProvider.user!.name,
      senderImage: userProvider.user!.profileImage ?? '',
      content: _messageController.text.trim(),
    );

    if (success) {
      _messageController.clear();
      // Scroll to bottom
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(chatProvider.error ?? 'বার্তা পাঠাতে ব্যর্থ')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
          color: AppColors.textPrimary,
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.conversation.groupName ??
                  widget.conversation.participants.join(', '),
              style: AppTypography.labelLarge(
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              'সক্রিয় এখন',
              style: AppTypography.bodySmall(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: _showConversationInfo,
            color: AppColors.textSecondary,
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages list
          Expanded(
            child: Consumer<ChatProvider>(
              builder: (context, chatProvider, _) {
                if (chatProvider.currentMessages.isEmpty) {
                  return const Center(
                    child: AppEmptyState(
                      icon: Icons.chat_bubble_outline,
                      title: 'কোন বার্তা নেই',
                      description: 'একটি বার্তা পাঠিয়ে কথোপকথন শুরু করুন',
                    ),
                  );
                }

                // Reverse list to show newest at bottom
                final messages = chatProvider.currentMessages.reversed.toList();

                return ListView.builder(
                  controller: _scrollController,
                  reverse: false,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 16,
                  ),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final userProvider = context.read<UserProvider>();
                    final isCurrentUser =
                        message.senderId == userProvider.user?.id;

                    return _MessageBubble(
                      message: message,
                      isCurrentUser: isCurrentUser,
                    );
                  },
                );
              },
            ),
          ),
          // Message input field
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'বার্তা লিখুন...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: const BorderSide(
                          color: AppColors.border,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.attach_file),
                        onPressed: () {
                          // TODO: Implement file attachment
                        },
                        color: AppColors.textSecondary,
                      ),
                    ),
                    maxLines: null,
                    textCapitalization: TextCapitalization.sentences,
                  ),
                ),
                const SizedBox(width: 8),
                FloatingActionButton(
                  mini: true,
                  onPressed: _sendMessage,
                  backgroundColor: AppColors.buyerPrimary,
                  child: const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showConversationInfo() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'কথোপকথনের তথ্য',
              style: AppTypography.h4(color: AppColors.textPrimary),
            ),
            const SizedBox(height: 16),
            if (widget.conversation.groupName != null) ...[
              Text(
                'গ্রুপ নাম: ${widget.conversation.groupName}',
                style: AppTypography.bodyMedium(),
              ),
              const SizedBox(height: 8),
            ],
            Text(
              'সদস্যরা: ${widget.conversation.participants.length}',
              style: AppTypography.bodyMedium(),
            ),
            const SizedBox(height: 16),
            AppElevatedButton(
              label: 'বন্ধ করুন',
              onPressed: () => Navigator.pop(context),
              width: double.infinity,
            ),
          ],
        ),
      ),
    );
  }
}

/// Message bubble widget
class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isCurrentUser;

  const _MessageBubble({
    Key? key,
    required this.message,
    required this.isCurrentUser,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final timeFormat = DateFormat('hh:mm a');

    return Align(
      alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isCurrentUser ? AppColors.buyerPrimary : AppColors.divider,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(12),
            topRight: const Radius.circular(12),
            bottomLeft: Radius.circular(isCurrentUser ? 12 : 0),
            bottomRight: Radius.circular(isCurrentUser ? 0 : 12),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          crossAxisAlignment:
              isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message.content,
              style: AppTypography.bodyMedium(
                color: isCurrentUser ? Colors.white : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              timeFormat.format(message.timestamp),
              style: AppTypography.labelSmall(
                color: isCurrentUser ? Colors.white70 : AppColors.textSecondary,
              ),
            ),
            if (isCurrentUser && message.isRead)
              Text(
                '✓✓ পড়েছেন',
                style: AppTypography.labelSmall(
                  color: Colors.white70,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
