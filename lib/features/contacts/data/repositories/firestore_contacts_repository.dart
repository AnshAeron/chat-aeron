import 'package:chat_aeron/features/auth/domain/entities/user_entity.dart';
import 'package:chat_aeron/features/contacts/data/datasources/firestore_contacts_datasource.dart';
import 'package:chat_aeron/features/contacts/domain/repositories/contacts_repository.dart';

/// Firestore implementation of ContactsRepository.
class FirestoreContactsRepository implements ContactsRepository {
  final FirestoreContactsDataSource _dataSource;

  FirestoreContactsRepository(this._dataSource);

  @override
  Future<List<UserEntity>> getContacts() async {
    final users = await _dataSource.getContacts();

    return users.map((user) => user.toEntity()).toList();
  }

  @override
  Future<List<UserEntity>> searchContacts(String query) async {
    final users = await _dataSource.searchContacts(query);

    return users.map((user) => user.toEntity()).toList();
  }

  @override
  Stream<List<UserEntity>> contactsStream() {
    return _dataSource.contactsStream().map(
      (users) => users.map((user) => user.toEntity()).toList(),
    );
  }
}
