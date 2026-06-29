import 'package:chat_aeron/features/chat/domain/entities/chat_entity.dart';
import 'package:chat_aeron/features/chat/domain/entities/message_entity.dart';

abstract class ChatRepository {
  Stream<List<ChatEntity>> getChats(String userId);
  Stream<List<MessageEntity>> getMessages(String chatId);
  Future<String> getOrCreateChat(String currentUserId, String otherUserId);
  Future<void> sendMessage(MessageEntity message);
  Future<void> markMessagesAsSeen(String chatId, String currentUserId);
  Future<void> markMessagesAsDelivered(String chatId, String currentUserId);
  Future<void> deleteMessageForMe(String chatId, String messageId);
  Future<void> deleteMessageForEveryone(String chatId, String messageId);
  Future<void> setTypingStatus(String chatId, String userId, bool isTyping);
  Stream<Map<String, bool>> getTypingStatus(String chatId);
  Future<void> incrementUnreadCount(String chatId, String userId);
  Future<void> resetUnreadCount(String chatId, String userId);
}
