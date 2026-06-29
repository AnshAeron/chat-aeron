import 'package:chat_aeron/features/chat/domain/entities/message_entity.dart';
import 'package:chat_aeron/features/chat/domain/repositories/chat_repository.dart';

class SendMessageUseCase {
  final ChatRepository repository;

  const SendMessageUseCase(this.repository);

  Future<void> call(MessageEntity message) {
    return repository.sendMessage(message);
  }
}
