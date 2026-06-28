import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Represents the UI state of the authentication flow.
class AuthState {
  final bool isLoading;
  final String? errorMessage;

  const AuthState({
    this.isLoading = false,
    this.errorMessage,
  });

  AuthState copyWith({
    bool? isLoading,
    String? errorMessage,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

/// Controls the authentication flow.
///
/// Firebase and repository logic will be injected in later steps.
/// For now, this only manages UI state.
class AuthController extends StateNotifier<AuthState> {
  AuthController() : super(const AuthState());

  /// Placeholder for phone authentication.
  Future<void> signInWithPhone(String phoneNumber) async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
    );

    try {
      // Firebase authentication will be added later.

      await Future.delayed(const Duration(seconds: 1));

      state = state.copyWith(
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }
}

/// Riverpod provider for the authentication controller.
final authControllerProvider = StateNotifierProvider<AuthController, AuthState>(
  (ref) => AuthController(),
);
