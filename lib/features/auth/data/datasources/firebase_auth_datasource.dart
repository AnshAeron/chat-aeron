import 'package:firebase_auth/firebase_auth.dart';

/// Handles all direct interactions with Firebase Authentication.
///
/// This class is the only place where the Firebase Authentication SDK
/// should be accessed.
class FirebaseAuthDataSource {
  final FirebaseAuth _firebaseAuth;

  FirebaseAuthDataSource({FirebaseAuth? firebaseAuth})
    : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  /// Sends an OTP to the provided phone number.
  Future<void> sendOtp({
    required String phoneNumber,
    required PhoneCodeSent codeSent,
    required PhoneVerificationFailed verificationFailed,
    required PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout,
    required PhoneVerificationCompleted verificationCompleted,
  }) async {
    await _firebaseAuth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: verificationCompleted,
      verificationFailed: verificationFailed,
      codeSent: codeSent,
      codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
    );
  }

  /// Verifies the OTP entered by the user.
  Future<UserCredential> verifyOtp({
    required String verificationId,
    required String smsCode,
  }) async {
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );

    return _firebaseAuth.signInWithCredential(credential);
  }

  /// Returns the currently authenticated Firebase user.
  User? getCurrentUser() {
    return _firebaseAuth.currentUser;
  }

  /// Signs out the current user.
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}
