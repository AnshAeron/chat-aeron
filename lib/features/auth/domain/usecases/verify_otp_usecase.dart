import 'package:chat_aeron/features/auth/domain/entities/user_entity.dart';
import 'package:chat_aeron/features/auth/domain/repositories/auth_repository.dart';

/// Use case responsible for verifying the OTP entered by the user.
///
/// This class represents one business action:
/// "Verify OTP".
class VerifyOtpUseCase {
  final AuthRepository repository;

  const VerifyOtpUseCase(this.repository);

  Future<UserEntity> call({
    required String verificationId,
    required String smsCode,
  }) {
    return repository.verifyOtp(
      verificationId: verificationId,
      smsCode: smsCode,
    );
  }
}
