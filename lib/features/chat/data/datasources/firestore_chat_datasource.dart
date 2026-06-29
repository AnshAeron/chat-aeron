import 'package:chat_aeron/features/chat/data/models/chat_model.dart';
import 'package:chat_aeron/features/chat/data/models/message_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Handles all Firestore operations related to chats and messages.
class FirestoreChatDataSource {
  final FirebaseFirestore _firestore;

  FirestoreChatDataSource({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  static const String _chatsCollection = 'chats';
  static const String _messagesSubcollection = 'messages';

  /// Get a stream of all chats for a user, ordered by last message time
  Stream<List<ChatModel>> getChats(String userId) {
    return _firestore
        .collection(_chatsCollection)
        .where('participants', arrayContains: userId)
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ChatModel.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  /// Get a stream of messages for a specific chat, ordered by timestamp
  Stream<List<MessageModel>> getMessages(String chatId) {
    return _firestore
        .collection(_chatsCollection)
        .doc(chatId)
        .collection(_messagesSubcollection)
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => MessageModel.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  /// Generate a deterministic chat ID from two user IDs
  String getChatId(String userId1, String userId2) {
    final sorted = [userId1, userId2]..sort();
    return '${sorted[0]}_${sorted[1]}';
  }

  /// Create or get an existing chat between two users
  Future<String> getOrCreateChat(
    String currentUserId,
    String otherUserId,
  ) async {
    final chatId = getChatId(currentUserId, otherUserId);
    final chatDoc = await _firestore
        .collection(_chatsCollection)
        .doc(chatId)
        .get();

    if (!chatDoc.exists) {
      await _firestore.collection(_chatsCollection).doc(chatId).set({
        'participants': [currentUserId, otherUserId],
        'lastMessage': null,
        'lastMessageTime': FieldValue.serverTimestamp(),
        'lastMessageSenderId': null,
        'lastMessageType': null,
        'unreadCount': {currentUserId: 0, otherUserId: 0},
        'typing': {},
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    return chatId;
  }

  /// Send a message
  Future<void> sendMessage(MessageModel message) async {
    final batch = _firestore.batch();

    // Add message to subcollection
    final messageRef = _firestore
        .collection(_chatsCollection)
        .doc(message.chatId)
        .collection(_messagesSubcollection)
        .doc(message.messageId);

    batch.set(messageRef, message.toMap());

    // Update chat document with last message info
    final chatRef = _firestore.collection(_chatsCollection).doc(message.chatId);
    batch.update(chatRef, {
      'lastMessage': message.text ?? _getMediaTypeLabel(message.type.name),
      'lastMessageTime': Timestamp.fromDate(message.timestamp),
      'lastMessageSenderId': message.senderId,
      'lastMessageType': message.type.name,
    });

    await batch.commit();
  }

  /// Increment unread count for a user in a chat
  Future<void> incrementUnreadCount(String chatId, String userId) async {
    await _firestore.collection(_chatsCollection).doc(chatId).update({
      'unreadCount.$userId': FieldValue.increment(1),
    });
  }

  /// Reset unread count for a user in a chat
  Future<void> resetUnreadCount(String chatId, String userId) async {
    await _firestore.collection(_chatsCollection).doc(chatId).update({
      'unreadCount.$userId': 0,
    });
  }

  /// Update message status (sent → delivered → seen)
  Future<void> updateMessageStatus(
    String chatId,
    String messageId,
    String status,
  ) async {
    await _firestore
        .collection(_chatsCollection)
        .doc(chatId)
        .collection(_messagesSubcollection)
        .doc(messageId)
        .update({'status': status});
  }

  /// Batch update all unread messages as delivered
  Future<void> markMessagesAsDelivered(
    String chatId,
    String currentUserId,
  ) async {
    final messages = await _firestore
        .collection(_chatsCollection)
        .doc(chatId)
        .collection(_messagesSubcollection)
        .where('senderId', isNotEqualTo: currentUserId)
        .where('status', isEqualTo: 'sent')
        .get();

    final batch = _firestore.batch();
    for (final doc in messages.docs) {
      batch.update(doc.reference, {'status': 'delivered'});
    }
    await batch.commit();
  }

  /// Batch update all unread messages as seen
  Future<void> markMessagesAsSeen(String chatId, String currentUserId) async {
    final messages = await _firestore
        .collection(_chatsCollection)
        .doc(chatId)
        .collection(_messagesSubcollection)
        .where('senderId', isNotEqualTo: currentUserId)
        .where('status', whereIn: ['sent', 'delivered'])
        .get();

    final batch = _firestore.batch();
    for (final doc in messages.docs) {
      batch.update(doc.reference, {'status': 'seen'});
    }
    await batch.commit();
  }

  /// Delete a message for the current user only
  Future<void> deleteMessageForMe(String chatId, String messageId) async {
    await _firestore
        .collection(_chatsCollection)
        .doc(chatId)
        .collection(_messagesSubcollection)
        .doc(messageId)
        .update({'isDeleted': true});
  }

  /// Delete a message for everyone
  Future<void> deleteMessageForEveryone(String chatId, String messageId) async {
    await _firestore
        .collection(_chatsCollection)
        .doc(chatId)
        .collection(_messagesSubcollection)
        .doc(messageId)
        .update({
          'isDeletedForEveryone': true,
          'text': null,
          'mediaUrl': null,
          'mediaName': null,
        });
  }

  /// Set typing status
  Future<void> setTypingStatus(
    String chatId,
    String userId,
    bool isTyping,
  ) async {
    await _firestore.collection(_chatsCollection).doc(chatId).update({
      'typing.$userId': isTyping,
    });
  }

  /// Stream typing status
  Stream<Map<String, bool>> getTypingStatus(String chatId) {
    return _firestore.collection(_chatsCollection).doc(chatId).snapshots().map((
      doc,
    ) {
      final data = doc.data();
      if (data == null || data['typing'] == null) return <String, bool>{};
      return Map<String, bool>.from(data['typing'] as Map);
    });
  }

  String _getMediaTypeLabel(String type) {
    switch (type) {
      case 'image':
        return '📷 Photo';
      case 'video':
        return '🎥 Video';
      case 'audio':
        return '🎵 Voice message';
      case 'document':
        return '📄 Document';
      default:
        return '';
    }
  }
}
