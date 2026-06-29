import 'dart:async';

import 'package:chat_aeron/features/auth/data/datasources/firestore_user_datasource.dart';
import 'package:chat_aeron/features/auth/domain/entities/user_entity.dart';
import 'package:chat_aeron/features/auth/providers/auth_providers.dart';
import 'package:chat_aeron/features/chat/domain/entities/chat_entity.dart';
import 'package:chat_aeron/features/chat/domain/entities/message_entity.dart';
import 'package:chat_aeron/features/chat/domain/repositories/chat_repository.dart';
import 'package:chat_aeron/features/chat/providers/chat_providers.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

// ──────────────────────────────────────────
// Chat List Controller
// ──────────────────────────────────────────

class ChatListState {
  final List<ChatEntity> chats;
  final Map<String, UserEntity> userCache;
  final bool isLoading;
  final String? errorMessage;

  const ChatListState({
    this.chats = const [],
    this.userCache = const {},
    this.isLoading = false,
    this.errorMessage,
  });

  ChatListState copyWith({
    List<ChatEntity>? chats,
    Map<String, UserEntity>? userCache,
    bool? isLoading,
    String? errorMessage,
  }) {
    return ChatListState(
      chats: chats ?? this.chats,
      userCache: userCache ?? this.userCache,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class ChatListController extends StateNotifier<ChatListState> {
  final ChatRepository _chatRepository;
  final FirestoreUserDataSource _userDataSource;
  final String _currentUserId;
  StreamSubscription? _chatSubscription;

  ChatListController(
    this._chatRepository,
    this._userDataSource,
    this._currentUserId,
  ) : super(const ChatListState(isLoading: true)) {
    _listenToChats();
  }

  void _listenToChats() {
    _chatSubscription = _chatRepository.getChats(_currentUserId).listen(
      (chats) async {
        // Fetch user details for all chat participants
        final userCache = Map<String, UserEntity>.from(state.userCache);
        for (final chat in chats) {
          final otherUserId = chat.getOtherUserId(_currentUserId);
          if (!userCache.containsKey(otherUserId)) {
            final user = await _userDataSource.getUser(otherUserId);
            if (user != null) {
              userCache[otherUserId] = user.toEntity();
            }
          }
        }

        state = state.copyWith(
          chats: chats,
          userCache: userCache,
          isLoading: false,
        );
      },
      onError: (e) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: e.toString(),
        );
      },
    );
  }

  Future<String> startChat(String otherUserId) async {
    return await _chatRepository.getOrCreateChat(_currentUserId, otherUserId);
  }

  @override
  void dispose() {
    _chatSubscription?.cancel();
    super.dispose();
  }
}

final chatListControllerProvider =
    StateNotifierProvider<ChatListController, ChatListState>((ref) {
  final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
  return ChatListController(
    ref.read(chatRepositoryProvider),
    ref.read(firestoreUserDataSourceProvider),
    currentUserId,
  );
});

// ──────────────────────────────────────────
// Individual Chat Controller
// ──────────────────────────────────────────

class ChatState {
  final List<MessageEntity> messages;
  final bool isLoading;
  final String? errorMessage;
  final Map<String, bool> typingStatus;
  final MessageEntity? replyingTo;

  const ChatState({
    this.messages = const [],
    this.isLoading = false,
    this.errorMessage,
    this.typingStatus = const {},
    this.replyingTo,
  });

  ChatState copyWith({
    List<MessageEntity>? messages,
    bool? isLoading,
    String? errorMessage,
    Map<String, bool>? typingStatus,
    MessageEntity? replyingTo,
    bool clearReply = false,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      typingStatus: typingStatus ?? this.typingStatus,
      replyingTo: clearReply ? null : (replyingTo ?? this.replyingTo),
    );
  }
}

class ChatController extends StateNotifier<ChatState> {
  final ChatRepository _chatRepository;
  final String _chatId;
  final String _currentUserId;
  StreamSubscription? _messageSubscription;
  StreamSubscription? _typingSubscription;
  Timer? _typingTimer;

  ChatController(
    this._chatRepository,
    this._chatId,
    this._currentUserId,
  ) : super(const ChatState(isLoading: true)) {
    _listenToMessages();
    _listenToTyping();
    _markAsSeen();
  }

  void _listenToMessages() {
    _messageSubscription = _chatRepository.getMessages(_chatId).listen(
      (messages) {
        state = state.copyWith(messages: messages, isLoading: false);
        _markAsSeen();
      },
      onError: (e) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: e.toString(),
        );
      },
    );
  }

  void _listenToTyping() {
    _typingSubscription = _chatRepository.getTypingStatus(_chatId).listen(
      (status) {
        state = state.copyWith(typingStatus: status);
      },
    );
  }

  Future<void> _markAsSeen() async {
    await _chatRepository.markMessagesAsSeen(_chatId, _currentUserId);
    await _chatRepository.resetUnreadCount(_chatId, _currentUserId);
  }

  Future<void> sendTextMessage(String text) async {
    if (text.trim().isEmpty) return;

    final message = MessageEntity(
      messageId: const Uuid().v4(),
      chatId: _chatId,
      senderId: _currentUserId,
      text: text.trim(),
      type: MessageType.text,
      status: MessageStatus.sent,
      timestamp: DateTime.now(),
      replyToMessageId: state.replyingTo?.messageId,
      replyToText: state.replyingTo?.text,
      replyToSenderId: state.replyingTo?.senderId,
    );

    state = state.copyWith(clearReply: true);

    try {
      await _chatRepository.sendMessage(message);
      // Increment unread count for the other user
      // (We'd need the other user's ID here; handled via chat participants)
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }

    // Clear typing status after sending
    await _chatRepository.setTypingStatus(_chatId, _currentUserId, false);
  }

  void setReplyingTo(MessageEntity message) {
    state = state.copyWith(replyingTo: message);
  }

  void clearReply() {
    state = state.copyWith(clearReply: true);
  }

  void onTyping() {
    _chatRepository.setTypingStatus(_chatId, _currentUserId, true);

    _typingTimer?.cancel();
    _typingTimer = Timer(const Duration(seconds: 3), () {
      _chatRepository.setTypingStatus(_chatId, _currentUserId, false);
    });
  }

  Future<void> deleteForMe(String messageId) async {
    await _chatRepository.deleteMessageForMe(_chatId, messageId);
  }

  Future<void> deleteForEveryone(String messageId) async {
    await _chatRepository.deleteMessageForEveryone(_chatId, messageId);
  }

  @override
  void dispose() {
    _messageSubscription?.cancel();
    _typingSubscription?.cancel();
    _typingTimer?.cancel();
    _chatRepository.setTypingStatus(_chatId, _currentUserId, false);
    super.dispose();
  }
}

/// Family provider — one controller per chat
final chatControllerProvider =
    StateNotifierProvider.family<ChatController, ChatState, String>(
  (ref, chatId) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
    return ChatController(
      ref.read(chatRepositoryProvider),
      chatId,
      currentUserId,
    );
  },
);
