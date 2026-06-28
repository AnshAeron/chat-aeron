import 'package:flutter_riverpod/flutter_riverpod.dart';

/// ------------------------------------------------------------
/// Splash Controller
/// ------------------------------------------------------------
///
/// Responsibilities:
/// - Initialize the application.
/// - Check authentication status.
/// - Initialize local storage.
/// - Decide where to navigate.
///
/// NOTE:
/// For now this is only a placeholder.
/// We will gradually add startup logic in the next steps.
/// ------------------------------------------------------------

class SplashController extends Notifier<void> {
  @override
  void build() {
    // Called when the provider is first created.
  }

  /// Starts the application initialization.
  Future<void> initializeApp() async {
    // TODO:
    // 1. Initialize Firebase
    // 2. Open Hive
    // 3. Check authentication
    // 4. Navigate to Home/Login
  }
}

/// Riverpod provider for the SplashController.
final splashControllerProvider = NotifierProvider<SplashController, void>(
  SplashController.new,
);
