import 'package:chat_aeron/features/auth/data/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Handles Firestore operations related to contacts.
class FirestoreContactsDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  FirestoreContactsDataSource({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _auth = auth ?? FirebaseAuth.instance;

  static const String usersCollection = 'users';

  /// Returns all registered users except the current user.
  Future<List<UserModel>> getContacts() async {
    final currentUid = _auth.currentUser?.uid;

    final snapshot = await _firestore
        .collection(usersCollection)
        .orderBy('displayName')
        .get();

    final contacts = snapshot.docs
        .where((doc) => doc.id != currentUid)
        .map((doc) => UserModel.fromMap(doc.data()))
        .toList();

    return contacts;
  }

  /// Search users by display name.
  Future<List<UserModel>> searchContacts(String query) async {
    final users = await getContacts();

    if (query.trim().isEmpty) {
      return users;
    }

    final lower = query.toLowerCase();

    return users.where((user) {
      return (user.displayName ?? '').toLowerCase().contains(lower) ||
          user.phoneNumber.toLowerCase().contains(lower);
    }).toList();
  }

  /// Returns a realtime stream of registered users.
  Stream<List<UserModel>> contactsStream() {
    final currentUid = _auth.currentUser?.uid;

    return _firestore
        .collection(usersCollection)
        .orderBy('displayName')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .where((doc) => doc.id != currentUid)
              .map((doc) => UserModel.fromMap(doc.data()))
              .toList(),
        );
  }
}
