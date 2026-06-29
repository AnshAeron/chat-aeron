import 'package:chat_aeron/features/chat/domain/entities/chat_entity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatModel extends ChatEntity {
  const ChatModel({
    required super.chatId,
    required super.participants,
    super.lastMessage,
    super.lastMessageTime,
    super.lastMessageSenderId,
    super.lastMessageType,
    super.unreadCount,
  });

  factory ChatModel.fromMap(Map<String, dynamic> map, String docId) {
    final unread = <String, int>{};
    if (map['unreadCount'] != null) {
      (map['unreadCount'] as Map<String, dynamic>).forEach((key, value) {
        unread[key] = (value as num).toInt();
      });
    }

    return ChatModel(
      chatId: docId,
      participants: List<String>.from(map['participants'] ?? []),
      lastMessage: map['lastMessage'],
      lastMessageTime: map['lastMessageTime'] != null
          ? (map['lastMessageTime'] as Timestamp).toDate()
          : null,
      lastMessageSenderId: map['lastMessageSenderId'],
      lastMessageType: map['lastMessageType'],
      unreadCount: unread,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'participants': participants,
      'lastMessage': lastMessage,
      'lastMessageTime': lastMessageTime != null
          ? Timestamp.fromDate(lastMessageTime!)
          : FieldValue.serverTimestamp(),
      'lastMessageSenderId': lastMessageSenderId,
      'lastMessageType': lastMessageType,
      'unreadCount': unreadCount,
    };
  }

  factory ChatModel.fromEntity(ChatEntity entity) {
    return ChatModel(
      chatId: entity.chatId,
      participants: entity.participants,
      lastMessage: entity.lastMessage,
      lastMessageTime: entity.lastMessageTime,
      lastMessageSenderId: entity.lastMessageSenderId,
      lastMessageType: entity.lastMessageType,
      unreadCount: entity.unreadCount,
    );
  }

  ChatEntity toEntity() {
    return ChatEntity(
      chatId: chatId,
      participants: participants,
      lastMessage: lastMessage,
      lastMessageTime: lastMessageTime,
      lastMessageSenderId: lastMessageSenderId,
      lastMessageType: lastMessageType,
      unreadCount: unreadCount,
    );
  }
}
