import 'package:chat_aeron/features/auth/domain/entities/user_entity.dart';
import 'package:chat_aeron/features/contacts/domain/repositories/contacts_repository.dart';

/// Use case responsible for fetching all registered contacts.
class GetContactsUseCase {
  final ContactsRepository repository;

  const GetContactsUseCase(this.repository);

  Future<List<UserEntity>> call() {
    return repository.getContacts();
  }

  Stream<List<UserEntity>> stream() {
    return repository.contactsStream();
  }
}
