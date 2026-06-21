import 'package:cloud_firestore/cloud_firestore.dart';
import '../exceptions/app_exceptions.dart';
import '../models/user_model.dart';

/// Chat message model
class ChatMessage {
  final String id;
  final String conversationId;
  final String senderId;
  final String senderName;
  final String senderImage;
  final String content;
  final List<String> imageUrls;
  final DateTime timestamp;
  final bool isRead;
  final String? replyToId;
  final int? replyCount;

  ChatMessage({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.senderName,
    required this.senderImage,
    required this.content,
    this.imageUrls = const [],
    required this.timestamp,
    this.isRead = false,
    this.replyToId,
    this.replyCount,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'conversationId': conversationId,
      'senderId': senderId,
      'senderName': senderName,
      'senderImage': senderImage,
      'content': content,
      'imageUrls': imageUrls,
      'timestamp': timestamp,
      'isRead': isRead,
      'replyToId': replyToId,
      'replyCount': replyCount ?? 0,
    };
  }

  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      id: map['id'] ?? '',
      conversationId: map['conversationId'] ?? '',
      senderId: map['senderId'] ?? '',
      senderName: map['senderName'] ?? '',
      senderImage: map['senderImage'] ?? '',
      content: map['content'] ?? '',
      imageUrls: List<String>.from(map['imageUrls'] ?? []),
      timestamp: (map['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isRead: map['isRead'] ?? false,
      replyToId: map['replyToId'],
      replyCount: map['replyCount'] ?? 0,
    );
  }
}

/// Conversation model
class Conversation {
  final String id;
  final List<String> participants;
  final String lastMessage;
  final DateTime lastMessageTime;
  final Map<String, bool> readStatus; // userId -> isRead
  final String? groupName;
  final String? groupImage;
  final bool isGroup;

  Conversation({
    required this.id,
    required this.participants,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.readStatus,
    this.groupName,
    this.groupImage,
    this.isGroup = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'participants': participants,
      'lastMessage': lastMessage,
      'lastMessageTime': lastMessageTime,
      'readStatus': readStatus,
      'groupName': groupName,
      'groupImage': groupImage,
      'isGroup': isGroup,
    };
  }

  factory Conversation.fromMap(Map<String, dynamic> map) {
    return Conversation(
      id: map['id'] ?? '',
      participants: List<String>.from(map['participants'] ?? []),
      lastMessage: map['lastMessage'] ?? '',
      lastMessageTime:
          (map['lastMessageTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
      readStatus: Map<String, bool>.from(map['readStatus'] ?? {}),
      groupName: map['groupName'],
      groupImage: map['groupImage'],
      isGroup: map['isGroup'] ?? false,
    );
  }
}

/// Chat service for real-time messaging
class ChatService {
  static final ChatService _instance = ChatService._internal();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  ChatService._internal();

  factory ChatService() {
    return _instance;
  }

  // ========== MESSAGE OPERATIONS ==========

  /// Send a new message
  Future<String> sendMessage({
    required String conversationId,
    required String senderId,
    required String senderName,
    required String senderImage,
    required String content,
    List<String> imageUrls = const [],
  }) async {
    try {
      final messageId = _firestore.collection('messages').doc().id;
      final timestamp = DateTime.now();

      final message = ChatMessage(
        id: messageId,
        conversationId: conversationId,
        senderId: senderId,
        senderName: senderName,
        senderImage: senderImage,
        content: content,
        imageUrls: imageUrls,
        timestamp: timestamp,
      );

      // Save message
      await _firestore
          .collection('messages')
          .doc(messageId)
          .set(message.toMap());

      // Update conversation
      await _firestore.collection('conversations').doc(conversationId).update({
        'lastMessage': content,
        'lastMessageTime': timestamp,
        'readStatus.$senderId': true,
      });

      return messageId;
    } catch (e) {
      throw FirestoreException.fromFirestore(e);
    }
  }

  /// Get messages for conversation
  Stream<List<ChatMessage>> getMessages(String conversationId, {int? limit}) {
    Query query = _firestore
        .collection('messages')
        .where('conversationId', isEqualTo: conversationId)
        .orderBy('timestamp', descending: true);

    if (limit != null) {
      query = query.limit(limit);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => ChatMessage.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }

  /// Mark message as read
  Future<void> markMessageAsRead(String messageId) async {
    try {
      await _firestore
          .collection('messages')
          .doc(messageId)
          .update({'isRead': true});
    } catch (e) {
      throw FirestoreException.fromFirestore(e);
    }
  }

  /// Delete message
  Future<void> deleteMessage(String messageId) async {
    try {
      await _firestore.collection('messages').doc(messageId).delete();
    } catch (e) {
      throw FirestoreException.fromFirestore(e);
    }
  }

  // ========== CONVERSATION OPERATIONS ==========

  /// Create or get 1-on-1 conversation
  Future<String> getOrCreateConversation(
    String currentUserId,
    String otherUserId,
    String otherUserName,
    String otherUserImage,
  ) async {
    try {
      // Create conversation ID from both user IDs (sorted for consistency)
      final ids = [currentUserId, otherUserId]..sort();
      final conversationId = '${ids[0]}_${ids[1]}';

      // Check if conversation exists
      final exists = await _firestore
          .collection('conversations')
          .doc(conversationId)
          .get();

      if (!exists.exists) {
        // Create new conversation
        final conversation = Conversation(
          id: conversationId,
          participants: [currentUserId, otherUserId],
          lastMessage: '',
          lastMessageTime: DateTime.now(),
          readStatus: {
            currentUserId: true,
            otherUserId: false,
          },
        );

        await _firestore
            .collection('conversations')
            .doc(conversationId)
            .set(conversation.toMap());
      }

      return conversationId;
    } catch (e) {
      throw FirestoreException.fromFirestore(e);
    }
  }

  /// Create group conversation
  Future<String> createGroupConversation({
    required String groupName,
    required List<String> participants,
    required String creatorId,
    String? groupImage,
  }) async {
    try {
      final conversationId = _firestore.collection('conversations').doc().id;

      final conversation = Conversation(
        id: conversationId,
        participants: participants,
        lastMessage: '',
        lastMessageTime: DateTime.now(),
        readStatus: {
          for (final userId in participants) userId: userId == creatorId,
        },
        groupName: groupName,
        groupImage: groupImage,
        isGroup: true,
      );

      await _firestore
          .collection('conversations')
          .doc(conversationId)
          .set(conversation.toMap());

      return conversationId;
    } catch (e) {
      throw FirestoreException.fromFirestore(e);
    }
  }

  /// Get all conversations for user
  Stream<List<Conversation>> getConversations(String userId) {
    return _firestore
        .collection('conversations')
        .where('participants', arrayContains: userId)
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map(
              (doc) => Conversation.fromMap(doc.data()))
          .toList();
    });
  }

  /// Mark conversation as read
  Future<void> markConversationAsRead(
      String conversationId, String userId) async {
    try {
      await _firestore
          .collection('conversations')
          .doc(conversationId)
          .update({'readStatus.$userId': true});
    } catch (e) {
      throw FirestoreException.fromFirestore(e);
    }
  }

  /// Delete conversation
  Future<void> deleteConversation(String conversationId) async {
    try {
      // Delete all messages in conversation
      final messages = await _firestore
          .collection('messages')
          .where('conversationId', isEqualTo: conversationId)
          .get();

      for (final msg in messages.docs) {
        await msg.reference.delete();
      }

      // Delete conversation
      await _firestore.collection('conversations').doc(conversationId).delete();
    } catch (e) {
      throw FirestoreException.fromFirestore(e);
    }
  }

  // ========== UNREAD COUNT ==========

  /// Get unread message count
  Future<int> getUnreadCount(String conversationId, String userId) async {
    try {
      final snapshot = await _firestore
          .collection('messages')
          .where('conversationId', isEqualTo: conversationId)
          .where('isRead', isEqualTo: false)
          .where('senderId', isNotEqualTo: userId)
          .count()
          .get();

      return snapshot.count ?? 0;
    } catch (e) {
      throw FirestoreException.fromFirestore(e);
    }
  }

  /// Get total unread count for user
  Stream<int> getTotalUnreadCount(String userId) {
    return _firestore
        .collection('conversations')
        .where('participants', arrayContains: userId)
        .snapshots()
        .asyncMap((snapshot) async {
      int totalUnread = 0;

      for (final doc in snapshot.docs) {
        final readStatus =
            (doc.data()['readStatus'] as Map<String, dynamic>?)?[userId] ??
                false;
        if (!readStatus) {
          totalUnread++;
        }
      }

      return totalUnread;
    });
  }
}
