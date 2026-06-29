import 'package:chat_aeron/features/auth/domain/entities/user_entity.dart';
import 'package:chat_aeron/features/auth/domain/repositories/auth_repository.dart';

/// Use case responsible for retrieving the currently authenticated user.
///
/// Returns null if no user is signed in.
class GetCurrentUserUseCase {
  final AuthRepository repository;

  const GetCurrentUserUseCase(this.repository);

  Future<UserEntity?> call() {
    return repository.getCurrentUser();
  }
}
