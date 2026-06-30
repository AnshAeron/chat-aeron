import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:chat_aeron/features/auth/data/datasources/firestore_user_datasource.dart';
import 'package:chat_aeron/features/auth/data/models/user_model.dart';

/// ------------------------------------------------------------
/// Authentication State
/// ------------------------------------------------------------
class AuthState {
  final bool isLoading;
  final String? errorMessage;
  final bool isAuthenticated;

  const AuthState({
    this.isLoading = false,
    this.errorMessage,
    this.isAuthenticated = false,
  });

  AuthState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool? isAuthenticated,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    );
  }
}

/// ------------------------------------------------------------
/// Authentication Controller (EMAIL LOGIN ONLY)
/// ------------------------------------------------------------
class AuthController extends StateNotifier<AuthState> {
  AuthController() : super(const AuthState());

  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// LOGIN (Email + Password)
  Future<void> login({required String email, required String password}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);

      state = state.copyWith(isLoading: false, isAuthenticated: true);
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.message);
    }
  }

  /// SIGN UP (Email + Password)
  Future<void> signUp({required String email, required String password}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user != null) {
        final userModel = UserModel(
          uid: user.uid,
          phoneNumber: user.phoneNumber ?? '',
          displayName: user.displayName ?? email.split('@')[0],
          photoUrl: user.photoURL,
          isOnline: true,
          createdAt: DateTime.now(),
        );

        await FirestoreUserDataSource().saveUser(userModel);
      }

      state = state.copyWith(isLoading: false, isAuthenticated: true);
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.message);
    }
  }

  /// LOGOUT
  Future<void> logout() async {
    await _auth.signOut();

    state = state.copyWith(isAuthenticated: false);
  }
}

/// ------------------------------------------------------------
/// Riverpod Provider
/// ------------------------------------------------------------
final authControllerProvider = StateNotifierProvider<AuthController, AuthState>(
  (ref) {
    return AuthController();
  },
);
