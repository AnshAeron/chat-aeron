import 'package:chat_aeron/features/chat/data/datasources/firestore_chat_datasource.dart';
import 'package:chat_aeron/features/chat/data/models/message_model.dart';
import 'package:chat_aeron/features/chat/domain/entities/chat_entity.dart';
import 'package:chat_aeron/features/chat/domain/entities/message_entity.dart';
import 'package:chat_aeron/features/chat/domain/repositories/chat_repository.dart';

class ChatRepositoryImpl implements ChatRepository {
  final FirestoreChatDataSource _dataSource;

  ChatRepositoryImpl(this._dataSource);

  @override
  Stream<List<ChatEntity>> getChats(String userId) {
    return _dataSource.getChats(userId).map(
      (models) => models.map((m) => m.toEntity()).toList(),
    );
  }

  @override
  Stream<List<MessageEntity>> getMessages(String chatId) {
    return _dataSource.getMessages(chatId).map(
      (models) => models.map((m) => m.toEntity()).toList(),
    );
  }

  @override
  Future<String> getOrCreateChat(String currentUserId, String otherUserId) {
    return _dataSource.getOrCreateChat(currentUserId, otherUserId);
  }

  @override
  Future<void> sendMessage(MessageEntity message) {
    return _dataSource.sendMessage(MessageModel.fromEntity(message));
  }

  @override
  Future<void> markMessagesAsSeen(String chatId, String currentUserId) {
    return _dataSource.markMessagesAsSeen(chatId, currentUserId);
  }

  @override
  Future<void> markMessagesAsDelivered(String chatId, String currentUserId) {
    return _dataSource.markMessagesAsDelivered(chatId, currentUserId);
  }

  @override
  Future<void> deleteMessageForMe(String chatId, String messageId) {
    return _dataSource.deleteMessageForMe(chatId, messageId);
  }

  @override
  Future<void> deleteMessageForEveryone(String chatId, String messageId) {
    return _dataSource.deleteMessageForEveryone(chatId, messageId);
  }

  @override
  Future<void> setTypingStatus(String chatId, String userId, bool isTyping) {
    return _dataSource.setTypingStatus(chatId, userId, isTyping);
  }

  @override
  Stream<Map<String, bool>> getTypingStatus(String chatId) {
    return _dataSource.getTypingStatus(chatId);
  }

  @override
  Future<void> incrementUnreadCount(String chatId, String userId) {
    return _dataSource.incrementUnreadCount(chatId, userId);
  }

  @override
  Future<void> resetUnreadCount(String chatId, String userId) {
    return _dataSource.resetUnreadCount(chatId, userId);
  }
}
