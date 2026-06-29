import 'package:chat_aeron/features/auth/domain/entities/user_entity.dart';
import 'package:chat_aeron/features/auth/providers/auth_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final userProvider = FutureProvider.family<UserEntity?, String>((
  ref,
  uid,
) async {
  final dataSource = ref.read(firestoreUserDataSourceProvider);

  final user = await dataSource.getUser(uid);

  return user?.toEntity();
});
