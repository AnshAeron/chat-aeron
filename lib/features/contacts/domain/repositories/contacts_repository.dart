import 'package:chat_aeron/features/auth/domain/entities/user_entity.dart';

/// Repository contract for contacts.
abstract class ContactsRepository {
  /// Fetch all registered users except the current user.
  Future<List<UserEntity>> getContacts();

  /// Search registered users.
  Future<List<UserEntity>> searchContacts(String query);

  /// Realtime stream of registered users.
  Stream<List<UserEntity>> contactsStream();
}
