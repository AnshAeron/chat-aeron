import 'package:chat_aeron/features/auth/providers/auth_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// ------------------------------------------------------------
/// Splash Controller
/// ------------------------------------------------------------
///
/// Responsibilities:
/// - Initialize the application.
/// - Check authentication status.
/// - Return whether the user is authenticated so the UI can navigate.
/// ------------------------------------------------------------

class SplashController extends Notifier<void> {
  @override
  void build() {
    // Called when the provider is first created.
  }

  /// Starts the application initialization.
  ///
  /// Returns `true` if the user is already authenticated,
  /// `false` otherwise. The splash page uses this result
  /// to decide whether to navigate to Home or Login.
  Future<bool> initializeApp() async {
    await Future.delayed(const Duration(seconds: 2));

    try {
      final getCurrentUser = ref.read(getCurrentUserUseCaseProvider);
      final user = await getCurrentUser();
      return user != null;
    } catch (_) {
      return false;
    }
  }
}

/// Riverpod provider for the SplashController.
final splashControllerProvider = NotifierProvider<SplashController, void>(
  SplashController.new,
);
