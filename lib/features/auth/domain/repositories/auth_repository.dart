import 'package:chat_aeron/features/auth/domain/entities/user_entity.dart';

/// Defines the contract for authentication operations.
///
/// The Domain layer depends only on this abstraction.
/// It has no knowledge of Firebase or any other backend.
///
/// The Data layer will provide the concrete implementation
/// (e.g., FirebaseAuthRepository).
abstract class AuthRepository {
  /// Sends an OTP to the provided phone number.
  ///
  /// [phoneNumber] should be in E.164 format
  /// (e.g., +919876543210).
  ///
  /// [codeSent] is invoked when Firebase successfully sends the OTP
  /// and returns a verification ID.
  ///
  /// [verificationFailed] is invoked if OTP sending fails.
  Future<void> sendOtp({
    required String phoneNumber,
    required void Function(String verificationId) codeSent,
    required void Function(String errorMessage) verificationFailed,
  });

  /// Verifies the OTP entered by the user.
  ///
  /// Returns the authenticated [UserEntity] on success.
  Future<UserEntity> verifyOtp({
    required String verificationId,
    required String smsCode,
  });

  /// Returns the currently authenticated user.
  ///
  /// Returns null if no user is signed in.
  Future<UserEntity?> getCurrentUser();

  /// Signs out the currently authenticated user.
  Future<void> signOut();
}
