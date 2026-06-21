import 'package:flutter/foundation.dart';
import '../services/chat_service.dart';
import '../exceptions/app_exceptions.dart';

/// Provider for managing chat state
class ChatProvider extends ChangeNotifier {
  final ChatService _chatService = ChatService();

  // ========== STATE VARIABLES ==========
  List<Conversation> _conversations = [];
  List<ChatMessage> _currentMessages = [];
  String? _selectedConversationId;
  bool _isLoading = false;
  String? _error;
  int _unreadCount = 0;

  // ========== GETTERS ==========
  List<Conversation> get conversations => _conversations;
  List<ChatMessage> get currentMessages => _currentMessages;
  String? get selectedConversationId => _selectedConversationId;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get unreadCount => _unreadCount;

  // ========== SEND MESSAGE ==========
  Future<bool> sendMessage({
    required String conversationId,
    required String senderId,
    required String senderName,
    required String senderImage,
    required String content,
    List<String> imageUrls = const [],
  }) async {
    try {
      _setLoading(true);
      _clearError();

      await _chatService.sendMessage(
        conversationId: conversationId,
        senderId: senderId,
        senderName: senderName,
        senderImage: senderImage,
        content: content,
        imageUrls: imageUrls,
      );

      _setLoading(false);
      return true;
    } on AppException catch (e) {
      _setError(e.message);
      _setLoading(false);
      return false;
    }
  }

  // ========== LOAD CONVERSATIONS ==========
  Future<bool> loadConversations(String userId) async {
    try {
      _setLoading(true);
      _clearError();

      _chatService.getConversations(userId).listen((conversations) {
        _conversations = conversations;
        notifyListeners();
      });

      _setLoading(false);
      return true;
    } on AppException catch (e) {
      _setError(e.message);
      _setLoading(false);
      return false;
    }
  }

  // ========== LOAD MESSAGES ==========
  Future<bool> loadMessages(String conversationId) async {
    try {
      _clearError();
      _selectedConversationId = conversationId;

      _chatService.getMessages(conversationId, limit: 50).listen((messages) {
        _currentMessages = messages;
        notifyListeners();
      });

      return true;
    } on AppException catch (e) {
      _setError(e.message);
      return false;
    }
  }

  // ========== CREATE OR GET CONVERSATION ==========
  Future<String?> getOrCreateConversation(
    String currentUserId,
    String otherUserId,
    String otherUserName,
    String otherUserImage,
  ) async {
    try {
      _clearError();

      final conversationId = await _chatService.getOrCreateConversation(
        currentUserId,
        otherUserId,
        otherUserName,
        otherUserImage,
      );

      return conversationId;
    } on AppException catch (e) {
      _setError(e.message);
      return null;
    }
  }

  // ========== MARK AS READ ==========
  Future<bool> markConversationAsRead(
      String conversationId, String userId) async {
    try {
      await _chatService.markConversationAsRead(conversationId, userId);
      return true;
    } on AppException catch (e) {
      _setError(e.message);
      return false;
    }
  }

  // ========== DELETE CONVERSATION ==========
  Future<bool> deleteConversation(String conversationId) async {
    try {
      _setLoading(true);
      await _chatService.deleteConversation(conversationId);
      _conversations.removeWhere((conv) => conv.id == conversationId);
      _setLoading(false);
      notifyListeners();
      return true;
    } on AppException catch (e) {
      _setError(e.message);
      _setLoading(false);
      return false;
    }
  }

  // ========== HELPER METHODS ==========
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  void clearMessages() {
    _currentMessages = [];
    _selectedConversationId = null;
    notifyListeners();
  }
}
