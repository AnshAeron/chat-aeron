import 'package:chat_aeron/features/chat/data/datasources/firestore_chat_datasource.dart';
import 'package:chat_aeron/features/chat/data/repositories/chat_repository_impl.dart';
import 'package:chat_aeron/features/chat/domain/repositories/chat_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Firestore Chat Data Source
final firestoreChatDataSourceProvider = Provider<FirestoreChatDataSource>((ref) {
  return FirestoreChatDataSource();
});

/// Chat Repository
final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepositoryImpl(ref.read(firestoreChatDataSourceProvider));
});
