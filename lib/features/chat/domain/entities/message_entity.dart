/// Represents the status of a message.
enum MessageStatus { sent, delivered, seen }

/// Represents the type of a message.
enum MessageType { text, image, video, audio, document }

/// Represents a single message in a chat.
class MessageEntity {
  final String messageId;
  final String chatId;
  final String senderId;
  final String? text;
  final MessageType type;
  final MessageStatus status;
  final DateTime timestamp;
  final String? mediaUrl;
  final String? mediaName;
  final String? replyToMessageId;
  final String? replyToText;
  final String? replyToSenderId;
  final bool isDeleted;
  final bool isDeletedForEveryone;
  final String? forwardedFrom;

  const MessageEntity({
    required this.messageId,
    required this.chatId,
    required this.senderId,
    this.text,
    required this.type,
    required this.status,
    required this.timestamp,
    this.mediaUrl,
    this.mediaName,
    this.replyToMessageId,
    this.replyToText,
    this.replyToSenderId,
    this.isDeleted = false,
    this.isDeletedForEveryone = false,
    this.forwardedFrom,
  });

  MessageEntity copyWith({
    String? messageId,
    String? chatId,
    String? senderId,
    String? text,
    MessageType? type,
    MessageStatus? status,
    DateTime? timestamp,
    String? mediaUrl,
    String? mediaName,
    String? replyToMessageId,
    String? replyToText,
    String? replyToSenderId,
    bool? isDeleted,
    bool? isDeletedForEveryone,
    String? forwardedFrom,
  }) {
    return MessageEntity(
      messageId: messageId ?? this.messageId,
      chatId: chatId ?? this.chatId,
      senderId: senderId ?? this.senderId,
      text: text ?? this.text,
      type: type ?? this.type,
      status: status ?? this.status,
      timestamp: timestamp ?? this.timestamp,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      mediaName: mediaName ?? this.mediaName,
      replyToMessageId: replyToMessageId ?? this.replyToMessageId,
      replyToText: replyToText ?? this.replyToText,
      replyToSenderId: replyToSenderId ?? this.replyToSenderId,
      isDeleted: isDeleted ?? this.isDeleted,
      isDeletedForEveryone: isDeletedForEveryone ?? this.isDeletedForEveryone,
      forwardedFrom: forwardedFrom ?? this.forwardedFrom,
    );
  }

  bool get isTextMessage => type == MessageType.text;
  bool get isMediaMessage => type != MessageType.text;
  bool get isSeen => status == MessageStatus.seen;
  bool get isDelivered => status == MessageStatus.delivered || isSeen;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MessageEntity &&
          runtimeType == other.runtimeType &&
          messageId == other.messageId;

  @override
  int get hashCode => messageId.hashCode;
}
