import 'package:chat_aeron/features/chat/data/datasources/firestore_chat_datasource.dart';
import 'package:chat_aeron/features/chat/data/repositories/firestore_chat_repository.dart';
import 'package:chat_aeron/features/chat/domain/entities/chat_entity.dart';
import 'package:chat_aeron/features/chat/domain/entities/message_entity.dart';
import 'package:chat_aeron/features/chat/domain/repositories/chat_repository.dart';
import 'package:chat_aeron/features/chat/domain/usecases/get_chats_usecase.dart';
import 'package:chat_aeron/features/chat/domain/usecases/get_messages_usecase.dart';
import 'package:chat_aeron/features/chat/domain/usecases/send_message_usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// ------------------------------------------------------------
/// Data Source
/// ------------------------------------------------------------

final firestoreChatDataSourceProvider = Provider<FirestoreChatDataSource>((
  ref,
) {
  return FirestoreChatDataSource();
});

/// ------------------------------------------------------------
/// Repository
/// ------------------------------------------------------------

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return FirestoreChatRepository(ref.read(firestoreChatDataSourceProvider));
});

/// ------------------------------------------------------------
/// Use Cases
/// ------------------------------------------------------------

final sendMessageUseCaseProvider = Provider<SendMessageUseCase>((ref) {
  return SendMessageUseCase(ref.read(chatRepositoryProvider));
});

final getMessagesUseCaseProvider = Provider<GetMessagesUseCase>((ref) {
  return GetMessagesUseCase(ref.read(chatRepositoryProvider));
});

final getChatsUseCaseProvider = Provider<GetChatsUseCase>((ref) {
  return GetChatsUseCase(ref.read(chatRepositoryProvider));
});

/// ------------------------------------------------------------
/// Realtime Chat List
/// ------------------------------------------------------------

final chatsProvider = StreamProvider.family<List<ChatEntity>, String>((
  ref,
  userId,
) {
  return ref.read(getChatsUseCaseProvider).call(userId);
});

/// ------------------------------------------------------------
/// Realtime Messages
/// ------------------------------------------------------------

final messagesProvider = StreamProvider.family<List<MessageEntity>, String>((
  ref,
  chatId,
) {
  return ref.read(getMessagesUseCaseProvider).call(chatId);
});

/// ------------------------------------------------------------
/// Send Message Controller
/// ------------------------------------------------------------

class SendMessageController extends StateNotifier<AsyncValue<void>> {
  final SendMessageUseCase _sendMessageUseCase;

  SendMessageController(this._sendMessageUseCase)
    : super(const AsyncData(null));

  Future<void> send(MessageEntity message) async {
    state = const AsyncLoading();

    try {
      await _sendMessageUseCase(message);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}

final sendMessageControllerProvider =
    StateNotifierProvider<SendMessageController, AsyncValue<void>>((ref) {
      return SendMessageController(ref.read(sendMessageUseCaseProvider));
    });
