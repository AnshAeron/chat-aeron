import 'package:chat_aeron/features/chat/domain/entities/message_entity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel extends MessageEntity {
  const MessageModel({
    required super.messageId,
    required super.chatId,
    required super.senderId,
    super.text,
    required super.type,
    required super.status,
    required super.timestamp,
    super.mediaUrl,
    super.mediaName,
    super.replyToMessageId,
    super.replyToText,
    super.replyToSenderId,
    super.isDeleted,
    super.isDeletedForEveryone,
    super.forwardedFrom,
  });

  factory MessageModel.fromMap(Map<String, dynamic> map, String docId) {
    return MessageModel(
      messageId: docId,
      chatId: map['chatId'] ?? '',
      senderId: map['senderId'] ?? '',
      text: map['text'],
      type: MessageType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => MessageType.text,
      ),
      status: MessageStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => MessageStatus.sent,
      ),
      timestamp: map['timestamp'] != null
          ? (map['timestamp'] as Timestamp).toDate()
          : DateTime.now(),
      mediaUrl: map['mediaUrl'],
      mediaName: map['mediaName'],
      replyToMessageId: map['replyToMessageId'],
      replyToText: map['replyToText'],
      replyToSenderId: map['replyToSenderId'],
      isDeleted: map['isDeleted'] ?? false,
      isDeletedForEveryone: map['isDeletedForEveryone'] ?? false,
      forwardedFrom: map['forwardedFrom'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'chatId': chatId,
      'senderId': senderId,
      'text': text,
      'type': type.name,
      'status': status.name,
      'timestamp': FieldValue.serverTimestamp(),
      'mediaUrl': mediaUrl,
      'mediaName': mediaName,
      'replyToMessageId': replyToMessageId,
      'replyToText': replyToText,
      'replyToSenderId': replyToSenderId,
      'isDeleted': isDeleted,
      'isDeletedForEveryone': isDeletedForEveryone,
      'forwardedFrom': forwardedFrom,
    };
  }

  factory MessageModel.fromEntity(MessageEntity entity) {
    return MessageModel(
      messageId: entity.messageId,
      chatId: entity.chatId,
      senderId: entity.senderId,
      text: entity.text,
      type: entity.type,
      status: entity.status,
      timestamp: entity.timestamp,
      mediaUrl: entity.mediaUrl,
      mediaName: entity.mediaName,
      replyToMessageId: entity.replyToMessageId,
      replyToText: entity.replyToText,
      replyToSenderId: entity.replyToSenderId,
      isDeleted: entity.isDeleted,
      isDeletedForEveryone: entity.isDeletedForEveryone,
      forwardedFrom: entity.forwardedFrom,
    );
  }

  MessageEntity toEntity() {
    return MessageEntity(
      messageId: messageId,
      chatId: chatId,
      senderId: senderId,
      text: text,
      type: type,
      status: status,
      timestamp: timestamp,
      mediaUrl: mediaUrl,
      mediaName: mediaName,
      replyToMessageId: replyToMessageId,
      replyToText: replyToText,
      replyToSenderId: replyToSenderId,
      isDeleted: isDeleted,
      isDeletedForEveryone: isDeletedForEveryone,
      forwardedFrom: forwardedFrom,
    );
  }
}
