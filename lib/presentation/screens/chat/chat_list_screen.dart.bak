import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:agrolinkbd/core/theme/app_colors.dart';
import 'package:agrolinkbd/core/theme/app_typography.dart';
import 'package:agrolinkbd/core/theme/app_widgets.dart';
import 'package:agrolinkbd/core/providers/user_provider.dart';
import 'package:agrolinkbd/core/providers/chat_provider.dart';
import 'chat_detail_screen.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({Key? key}) : super(key: key);

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadConversations();
  }

  void _loadConversations() {
    final userProvider = context.read<UserProvider>();
    if (userProvider.user != null) {
      context.read<ChatProvider>().loadConversations(userProvider.user!.id);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          'বার্তা',
          style: AppTypography.h4(color: AppColors.textPrimary),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: _showNewChatDialog,
            color: AppColors.buyerPrimary,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search field
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'সন্ধান করুন...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppColors.border,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              onChanged: (value) {
                setState(() => _searchQuery = value.toLowerCase());
              },
            ),
          ),
          // Conversations list
          Expanded(
            child: Consumer<ChatProvider>(
              builder: (context, chatProvider, _) {
                if (chatProvider.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.buyerPrimary,
                      ),
                    ),
                  );
                }

                if (chatProvider.conversations.isEmpty) {
                  return AppEmptyState(
                    icon: Icons.chat_bubble_outline,
                    title: 'কোন কথোপকথন নেই',
                    description: 'সরাসরি কথা বলার জন্য কাউকে খুঁজুন',
                    action: AppElevatedButton(
                      label: 'নতুন কথোপকথন শুরু করুন',
                      onPressed: _showNewChatDialog,
                      backgroundColor: AppColors.buyerPrimary,
                    ),
                  );
                }

                final filteredConversations =
                    chatProvider.conversations.where((conv) {
                  final searchTarget =
                      conv.groupName ?? conv.participants.join(' ');
                  return searchTarget.toLowerCase().contains(_searchQuery);
                }).toList();

                return ListView.builder(
                  itemCount: filteredConversations.length,
                  itemBuilder: (context, index) {
                    final conversation = filteredConversations[index];
                    return _ConversationCard(
                      conversation: conversation,
                      onTap: () => _openChat(conversation),
                      onLongPress: () => _showDeleteDialog(conversation.id),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _openChat(Conversation conversation) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatDetailScreen(conversation: conversation),
      ),
    );
  }

  void _showNewChatDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('নতুন চ্যাট শুরু করুন'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppTextField(
              label: 'ব্যবহারকারী খোঁজুন',
              hint: 'নাম বা ইমেল দিয়ে খোঁজুন',
              controller: TextEditingController(),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('বাতিল করুন'),
          ),
          AppElevatedButton(
            label: 'নতুন গ্রুপ',
            onPressed: () {
              Navigator.pop(context);
              // Show group creation dialog
            },
            width: 120,
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(String conversationId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('কথোপকথন মুছুন?'),
        content: const Text(
          'এই কথোপকথনটি চিরতরে মুছে ফেলা হবে। এটি পূর্বাবাস করা যাবে না।',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('বাতিল করুন'),
          ),
          TextButton(
            onPressed: () {
              context.read<ChatProvider>().deleteConversation(conversationId);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('কথোপকথন মুছে দেওয়া হয়েছে')),
              );
            },
            child: const Text(
              'মুছুন',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}

/// Individual conversation card
class _ConversationCard extends StatelessWidget {
  final Conversation conversation;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const _ConversationCard({
    Key? key,
    required this.conversation,
    required this.onTap,
    required this.onLongPress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final timeFormat = DateFormat('hh:mm a');
    final dateFormat = DateFormat('MMM d');
    final isToday =
        DateTime.now().difference(conversation.lastMessageTime).inDays == 0;
    final isYesterday =
        DateTime.now().difference(conversation.lastMessageTime).inDays == 1;

    String timeDisplay;
    if (isToday) {
      timeDisplay = timeFormat.format(conversation.lastMessageTime);
    } else if (isYesterday) {
      timeDisplay = 'গতকাল';
    } else {
      timeDisplay = dateFormat.format(conversation.lastMessageTime);
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        onTap: onTap,
        onLongPress: onLongPress,
        leading: _buildAvatar(),
        title: Row(
          children: [
            Expanded(
              child: Text(
                conversation.groupName ?? conversation.participants.join(', '),
                style: AppTypography.labelLarge(
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              timeDisplay,
              style: AppTypography.bodySmall(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  conversation.lastMessage.isEmpty
                      ? 'কোন বার্তা নেই'
                      : conversation.lastMessage,
                  style: AppTypography.bodySmall(
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              // Unread indicator
              if (conversation.readStatus['currentUserId'] == false)
                Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                    color: AppColors.buyerPrimary,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            PopupMenuItem(
              child: const Text('মুছুন'),
              onTap: () => onLongPress(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    if (conversation.groupImage != null) {
      return CircleAvatar(
        backgroundImage: NetworkImage(conversation.groupImage!),
        radius: 24,
      );
    }

    // Single chat avatar
    return CircleAvatar(
      radius: 24,
      backgroundColor: AppColors.buyerPrimary,
      child: Text(
        (conversation.groupName ?? conversation.participants.first)
            .substring(0, 1)
            .toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
