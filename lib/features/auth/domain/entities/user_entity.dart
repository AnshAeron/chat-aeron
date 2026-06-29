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

  const UserEntity({
    required this.uid,
    required this.phoneNumber,
    this.displayName,
    this.photoUrl,
  });

  UserEntity copyWith({
    String? uid,
    String? phoneNumber,
    String? displayName,
    String? photoUrl,
  }) {
    return UserEntity(
      uid: uid ?? this.uid,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }

  @override
  String toString() {
    return 'UserEntity(uid: $uid, phoneNumber: $phoneNumber, displayName: $displayName, photoUrl: $photoUrl)';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserEntity &&
          runtimeType == other.runtimeType &&
          uid == other.uid &&
          phoneNumber == other.phoneNumber &&
          displayName == other.displayName &&
          photoUrl == other.photoUrl;

  @override
  int get hashCode =>
      uid.hashCode ^
      phoneNumber.hashCode ^
      displayName.hashCode ^
      photoUrl.hashCode;
}
