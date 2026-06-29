class AppConstants {
  AppConstants._();

  // Message types
  static const String textMessage = 'text';
  static const String imageMessage = 'image';
  static const String videoMessage = 'video';
  static const String audioMessage = 'audio';
  static const String documentMessage = 'document';

  // Message status
  static const String sent = 'sent';
  static const String delivered = 'delivered';
  static const String seen = 'seen';

  // Status/Stories
  static const int statusDurationHours = 24;

  // Typing
  static const int typingTimeoutSeconds = 3;

  // Presence
  static const String online = 'online';
  static const String offline = 'offline';
}
