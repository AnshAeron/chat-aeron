import 'package:chat_aeron/features/auth/domain/entities/user_entity.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Data model representing a user received from Firebase.
///
/// This model converts Firebase's [User] into the application's
/// domain entity [UserEntity].
class UserModel extends UserEntity {
  const UserModel({
    required super.uid,
    required super.phoneNumber,
    super.displayName,
    super.photoUrl,
  });

  /// Creates a [UserModel] from a Firebase [User].
  factory UserModel.fromFirebaseUser(User user) {
    return UserModel(
      uid: user.uid,
      phoneNumber: user.phoneNumber ?? '',
      displayName: user.displayName,
      photoUrl: user.photoURL,
    );
  }

  /// Creates a [UserModel] from a [UserEntity].
  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      uid: entity.uid,
      phoneNumber: entity.phoneNumber,
      displayName: entity.displayName,
      photoUrl: entity.photoUrl,
    );
  }

  /// Converts this model back into a domain entity.
  UserEntity toEntity() {
    return UserEntity(
      uid: uid,
      phoneNumber: phoneNumber,
      displayName: displayName,
      photoUrl: photoUrl,
    );
  }

  /// Converts the model into a Firestore document.
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'phoneNumber': phoneNumber,
      'displayName': displayName,
      'photoUrl': photoUrl,
    };
  }

  /// Creates a model from a Firestore document.
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      displayName: map['displayName'],
      photoUrl: map['photoUrl'],
    );
  }
}
