import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chat_aeron/features/auth/data/models/user_model.dart';

/// Handles all Firestore operations related to users.
class FirestoreUserDataSource {
  final FirebaseFirestore _firestore;

  FirestoreUserDataSource({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  static const String usersCollection = 'users';

  /// Creates or updates a user document.
  Future<void> saveUser(UserModel user) async {
    await _firestore
        .collection(usersCollection)
        .doc(user.uid)
        .set(user.toMap(), SetOptions(merge: true));
  }

  /// Retrieves a user document by UID.
  Future<UserModel?> getUser(String uid) async {
    final doc = await _firestore.collection(usersCollection).doc(uid).get();

    if (!doc.exists || doc.data() == null) {
      return null;
    }

    return UserModel.fromMap(doc.data()!);
  }
}
