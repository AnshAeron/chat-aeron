import 'package:chat_aeron/features/auth/domain/repositories/auth_repository.dart';

/// Use case responsible for sending an OTP to a phone number.
///
/// This class contains one business action only:
/// "Send OTP".
class SendOtpUseCase {
  final AuthRepository repository;

  const SendOtpUseCase(this.repository);

  Future<void> call({
    required String phoneNumber,
    required void Function(String verificationId) codeSent,
    required void Function(String errorMessage) verificationFailed,
  }) {
    return repository.sendOtp(
      phoneNumber: phoneNumber,
      codeSent: codeSent,
      verificationFailed: verificationFailed,
    );
  }
}
