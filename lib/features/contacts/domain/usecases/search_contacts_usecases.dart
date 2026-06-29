import 'package:chat_aeron/features/auth/domain/entities/user_entity.dart';
import 'package:chat_aeron/features/contacts/domain/repositories/contacts_repository.dart';

/// Use case responsible for searching registered contacts.
class SearchContactsUseCase {
  final ContactsRepository repository;

  const SearchContactsUseCase(this.repository);

  Future<List<UserEntity>> call(String query) {
    return repository.searchContacts(query);
  }
}
