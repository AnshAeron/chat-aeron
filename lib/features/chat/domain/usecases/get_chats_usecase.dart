import 'package:chat_aeron/features/chat/domain/entities/chat_entity.dart';
import 'package:chat_aeron/features/chat/domain/repositories/chat_repository.dart';

class GetChatsUseCase {
  final ChatRepository repository;

  const GetChatsUseCase(this.repository);

  Stream<List<ChatEntity>> call(String userId) {
    return repository.getChats(userId);
  }
}
