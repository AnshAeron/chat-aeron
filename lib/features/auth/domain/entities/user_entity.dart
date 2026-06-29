/// Represents the authenticated user inside the application.
///
/// This entity is independent of Firebase and any external data source.
///
/// The entire application should work with [UserEntity]
/// instead of Firebase's User object.
class UserEntity {
  /// Unique identifier of the user.
  final String uid;

  /// User's phone number.
  final String phoneNumber;

  /// User's display name.
  final String? displayName;

  /// User's profile picture URL.
  final String? photoUrl;

  /// User's about/status text.
  final String? about;

  /// Whether the user is currently online.
  final bool isOnline;

  /// Last time the user was seen online.
  final DateTime? lastSeen;

  /// When the user account was created.
  final DateTime? createdAt;

  const UserEntity({
    required this.uid,
    required this.phoneNumber,
    this.displayName,
    this.photoUrl,
    this.about,
    this.isOnline = false,
    this.lastSeen,
    this.createdAt,
  });

  UserEntity copyWith({
    String? uid,
    String? phoneNumber,
    String? displayName,
    String? photoUrl,
    String? about,
    bool? isOnline,
    DateTime? lastSeen,
    DateTime? createdAt,
  }) {
    return UserEntity(
      uid: uid ?? this.uid,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      about: about ?? this.about,
      isOnline: isOnline ?? this.isOnline,
      lastSeen: lastSeen ?? this.lastSeen,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'UserEntity(uid: $uid, phoneNumber: $phoneNumber, displayName: $displayName, photoUrl: $photoUrl, about: $about, isOnline: $isOnline)';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserEntity &&
          runtimeType == other.runtimeType &&
          uid == other.uid &&
          phoneNumber == other.phoneNumber &&
          displayName == other.displayName &&
          photoUrl == other.photoUrl &&
          about == other.about &&
          isOnline == other.isOnline;

  @override
  int get hashCode =>
      uid.hashCode ^
      phoneNumber.hashCode ^
      displayName.hashCode ^
      photoUrl.hashCode ^
      about.hashCode ^
      isOnline.hashCode;
}
