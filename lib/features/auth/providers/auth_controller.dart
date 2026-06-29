import 'package:chat_aeron/features/auth/domain/usecases/send_otp_usecase.dart';
import 'package:chat_aeron/features/auth/providers/auth_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Authentication UI state.
class AuthState {
  final bool isLoading;
  final String? errorMessage;
  final String? verificationId;

  const AuthState({
    this.isLoading = false,
    this.errorMessage,
    this.verificationId,
  });

  AuthState copyWith({
    bool? isLoading,
    String? errorMessage,
    String? verificationId,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      verificationId: verificationId ?? this.verificationId,
    );
  }
}

/// Controls the authentication flow.
class AuthController extends StateNotifier<AuthState> {
  final SendOtpUseCase _sendOtpUseCase;

  AuthController(this._sendOtpUseCase) : super(const AuthState());

  Future<void> signInWithPhone(String phoneNumber) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    await _sendOtpUseCase(
      phoneNumber: phoneNumber,

      codeSent: (verificationId) {
        state = state.copyWith(
          isLoading: false,
          verificationId: verificationId,
        );
      },

      verificationFailed: (message) {
        state = state.copyWith(isLoading: false, errorMessage: message);
      },
    );
  }
}

/// AuthController Provider
final authControllerProvider = StateNotifierProvider<AuthController, AuthState>(
  (ref) {
    return AuthController(ref.read(sendOtpUseCaseProvider));
  },
);
