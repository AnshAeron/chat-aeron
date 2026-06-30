/// ------------------------------------------------------------
/// App Routes
/// ------------------------------------------------------------
///
/// This file contains all route path constants used throughout
/// the application.
///
/// WHY?
/// - Prevents hardcoded strings.
/// - Easy to rename routes.
/// - Reduces typo-related bugs.
/// - Keeps navigation consistent.
///
/// Production Rule:
/// Never write "/home" or "/chat" directly anywhere else.
/// Always use AppRoutes.home, AppRoutes.chat, etc.
/// ------------------------------------------------------------
library;

class AppRoutes {
  AppRoutes._();

  // Splash
  static const String splash = '/';

  // Authentication
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String otp = '/otp';
  static const String profileSetup = '/profile-setup';

  // Home
  static const String home = '/home';

  // Chat
  static const String chat = '/chat';

  // Contacts
  static const String contacts = '/contacts';

  // Groups
  static const String groups = '/groups';

  // Calls
  static const String calls = '/calls';

  // Status
  static const String status = '/status';

  // Profile
  static const String profile = '/profile';

  // Settings
  static const String settings = '/settings';

  // AI
  static const String ai = '/ai';
}
