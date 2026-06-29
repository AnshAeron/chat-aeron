import 'package:chat_aeron/features/auth/domain/usecases/send_otp_usecase.dart';
import 'package:chat_aeron/features/auth/domain/usecases/verify_otp_usecase.dart';
import 'package:chat_aeron/features/auth/providers/auth_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// ------------------------------------------------------------
/// Authentication State
/// ------------------------------------------------------------
class AuthState {
  final bool isLoading;
  final String? errorMessage;
  final bool isAuthenticated;

  const AuthState({
    this.isLoading = false,
    this.errorMessage,
    this.isAuthenticated = false,
  });

  AuthState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool? isAuthenticated,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    );
  }
}

/// ------------------------------------------------------------
/// Authentication Controller
/// ------------------------------------------------------------
class AuthController extends StateNotifier<AuthState> {
  final SendOtpUseCase _sendOtpUseCase;
  final VerifyOtpUseCase _verifyOtpUseCase;

  AuthController(this._sendOtpUseCase, this._verifyOtpUseCase)
    : super(const AuthState());

  /// Sends OTP to the given phone number.
  Future<void> signInWithPhone({
    required String phoneNumber,
    required void Function(String verificationId) onCodeSent,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    await _sendOtpUseCase(
      phoneNumber: phoneNumber,

      codeSent: (verificationId) {
        state = state.copyWith(isLoading: false);

        onCodeSent(verificationId);
      },

      verificationFailed: (message) {
        state = state.copyWith(isLoading: false, errorMessage: message);
      },
    );
  }

  /// Verifies the OTP entered by the user.
  Future<void> verifyOtp({
    required String verificationId,
    required String smsCode,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      await _verifyOtpUseCase(verificationId: verificationId, smsCode: smsCode);

      state = state.copyWith(isLoading: false, isAuthenticated: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }
}

/// ------------------------------------------------------------
/// Riverpod Provider
/// ------------------------------------------------------------
final authControllerProvider = StateNotifierProvider<AuthController, AuthState>(
  (ref) {
    return AuthController(
      ref.read(sendOtpUseCaseProvider),
      ref.read(verifyOtpUseCaseProvider),
    );
  },
);
