import 'package:chat_aeron/features/auth/domain/repositories/auth_repository.dart';

/// Use case responsible for signing out the currently authenticated user.
///
/// This class represents one business action:
/// "Sign Out".
class SignOutUseCase {
  final AuthRepository repository;

  const SignOutUseCase(this.repository);

  Future<void> call() {
    return repository.signOut();
  }
}
