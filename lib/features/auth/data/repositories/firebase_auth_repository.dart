import 'package:chat_aeron/features/auth/data/datasources/firebase_auth_datasource.dart';
import 'package:chat_aeron/features/auth/data/datasources/firestore_user_datasource.dart';
import 'package:chat_aeron/features/auth/data/models/user_model.dart';
import 'package:chat_aeron/features/auth/domain/entities/user_entity.dart';
import 'package:chat_aeron/features/auth/domain/repositories/auth_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Firebase implementation of [AuthRepository].
///
/// This class acts as a bridge between the Domain layer and Firebase.
///
/// Responsibilities:
/// - Call Firebase through the Data Source
/// - Convert Firebase models into Domain entities
/// - Hide Firebase implementation details from the Domain layer
class FirebaseAuthRepository implements AuthRepository {
  final FirebaseAuthDataSource _dataSource;
  final FirestoreUserDataSource _userDataSource;

  FirebaseAuthRepository(this._dataSource, this._userDataSource);

  @override
  Future<void> sendOtp({
    required String phoneNumber,
    required void Function(String verificationId) codeSent,
    required void Function(String errorMessage) verificationFailed,
  }) async {
    try {
      await _dataSource.sendOtp(
        phoneNumber: phoneNumber,

        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto verification (Android only).
          //
          // We intentionally don't sign in here.
          // Manual OTP verification will be used.
        },

        verificationFailed: (FirebaseAuthException e) {
          verificationFailed(e.message ?? 'Failed to send OTP.');
        },

        codeSent: (String verificationId, int? resendToken) {
          codeSent(verificationId);
        },

        codeAutoRetrievalTimeout: (String verificationId) {
          // Nothing to do here.
        },
      );
    } on FirebaseAuthException catch (e) {
      verificationFailed(e.message ?? 'Authentication failed.');
    } catch (_) {
      verificationFailed('Something went wrong.');
    }
  }

  @override
  Future<UserEntity> verifyOtp({
    required String verificationId,
    required String smsCode,
  }) async {
    final credential = await _dataSource.verifyOtp(
      verificationId: verificationId,
      smsCode: smsCode,
    );

    final user = credential.user;

    if (user == null) {
      throw FirebaseAuthException(
        code: 'user-not-found',
        message: 'Authentication failed.',
      );
    }

    final userModel = UserModel.fromFirebaseUser(user);

    // Save the user to Firestore after successful OTP verification.
    await _userDataSource.saveUser(userModel);

    return userModel.toEntity();
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    final user = _dataSource.getCurrentUser();

    if (user == null) {
      return null;
    }

    return UserModel.fromFirebaseUser(user).toEntity();
  }

  @override
  Future<void> signOut() async {
    await _dataSource.signOut();
  }
}
