/// Represents a chat conversation between two users.
class ChatEntity {
  final String chatId;
  final List<String> participants;
  final String? lastMessage;
  final DateTime? lastMessageTime;
  final String? lastMessageSenderId;
  final String? lastMessageType;
  final Map<String, int> unreadCount;

  const ChatEntity({
    required this.chatId,
    required this.participants,
    this.lastMessage,
    this.lastMessageTime,
    this.lastMessageSenderId,
    this.lastMessageType,
    this.unreadCount = const {},
  });

  ChatEntity copyWith({
    String? chatId,
    List<String>? participants,
    String? lastMessage,
    DateTime? lastMessageTime,
    String? lastMessageSenderId,
    String? lastMessageType,
    Map<String, int>? unreadCount,
  }) {
    return ChatEntity(
      chatId: chatId ?? this.chatId,
      participants: participants ?? this.participants,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      lastMessageSenderId: lastMessageSenderId ?? this.lastMessageSenderId,
      lastMessageType: lastMessageType ?? this.lastMessageType,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }

  /// Get the other participant's UID (for 1:1 chats)
  String getOtherUserId(String currentUserId) {
    return participants.firstWhere(
      (id) => id != currentUserId,
      orElse: () => '',
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatEntity &&
          runtimeType == other.runtimeType &&
          chatId == other.chatId;

  @override
  int get hashCode => chatId.hashCode;
}
