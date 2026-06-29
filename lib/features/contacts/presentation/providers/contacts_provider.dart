import 'package:chat_aeron/features/auth/domain/entities/user_entity.dart';
import 'package:chat_aeron/features/contacts/data/datasources/firestore_contacts_datasource.dart';
import 'package:chat_aeron/features/contacts/data/repositories/firestore_contacts_repository.dart';
import 'package:chat_aeron/features/contacts/domain/repositories/contacts_repository.dart';
import 'package:chat_aeron/features/contacts/domain/usecases/get_contacts_usecases.dart';
import 'package:chat_aeron/features/contacts/domain/usecases/search_contacts_usecases.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// ------------------------------------------------------------
/// Data Source
/// ------------------------------------------------------------

final firestoreContactsDataSourceProvider =
    Provider<FirestoreContactsDataSource>((ref) {
      return FirestoreContactsDataSource();
    });

/// ------------------------------------------------------------
/// Repository
/// ------------------------------------------------------------

final contactsRepositoryProvider = Provider<ContactsRepository>((ref) {
  return FirestoreContactsRepository(
    ref.read(firestoreContactsDataSourceProvider),
  );
});

/// ------------------------------------------------------------
/// Use Cases
/// ------------------------------------------------------------

final getContactsUseCaseProvider = Provider<GetContactsUseCase>((ref) {
  return GetContactsUseCase(ref.read(contactsRepositoryProvider));
});

final searchContactsUseCaseProvider = Provider<SearchContactsUseCase>((ref) {
  return SearchContactsUseCase(ref.read(contactsRepositoryProvider));
});

/// ------------------------------------------------------------
/// Realtime Contacts
/// ------------------------------------------------------------

final contactsProvider = StreamProvider<List<UserEntity>>((ref) {
  return ref.read(getContactsUseCaseProvider).stream();
});

/// ------------------------------------------------------------
/// Search Contacts
/// ------------------------------------------------------------

final searchContactsProvider = FutureProvider.family<List<UserEntity>, String>((
  ref,
  query,
) {
  return ref.read(searchContactsUseCaseProvider).call(query);
});
