import 'package:chat_aeron/features/chat/domain/entities/message_entity.dart';
import 'package:chat_aeron/features/chat/presentation/providers/chat_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

class ChatController extends StateNotifier<AsyncValue<void>> {
  ChatController(this.ref) : super(const AsyncData(null));

  final Ref ref;

  Future<void> sendTextMessage({
    required String chatId,
    required String senderId,
    required String text,
  }) async {
    if (text.trim().isEmpty) return;

    state = const AsyncLoading();

    try {
      final message = MessageEntity(
        messageId: const Uuid().v4(),
        chatId: chatId,
        senderId: senderId,
        text: text.trim(),
        type: MessageType.text,
        status: MessageStatus.sent,
        timestamp: DateTime.now(),
      );

      await ref.read(sendMessageControllerProvider.notifier).send(message);

      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}

final chatControllerProvider =
    StateNotifierProvider<ChatController, AsyncValue<void>>(
      (ref) => ChatController(ref),
    );
