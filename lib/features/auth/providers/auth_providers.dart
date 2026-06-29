import 'package:chat_aeron/features/auth/data/datasources/firebase_auth_datasource.dart';
import 'package:chat_aeron/features/auth/data/datasources/firestore_user_datasource.dart';
import 'package:chat_aeron/features/auth/data/repositories/firebase_auth_repository.dart';
import 'package:chat_aeron/features/auth/domain/repositories/auth_repository.dart';
import 'package:chat_aeron/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:chat_aeron/features/auth/domain/usecases/send_otp_usecase.dart';
import 'package:chat_aeron/features/auth/domain/usecases/sign_out_usecase.dart';
import 'package:chat_aeron/features/auth/domain/usecases/verify_otp_usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Firebase Authentication Data Source
final firebaseAuthDataSourceProvider = Provider<FirebaseAuthDataSource>((ref) {
  return FirebaseAuthDataSource();
});

/// Firestore User Data Source
final firestoreUserDataSourceProvider = Provider<FirestoreUserDataSource>((ref) {
  return FirestoreUserDataSource();
});

/// Authentication Repository
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return FirebaseAuthRepository(
    ref.read(firebaseAuthDataSourceProvider),
    ref.read(firestoreUserDataSourceProvider),
  );
});

/// Send OTP Use Case
final sendOtpUseCaseProvider = Provider<SendOtpUseCase>((ref) {
  return SendOtpUseCase(ref.read(authRepositoryProvider));
});

/// Verify OTP Use Case
final verifyOtpUseCaseProvider = Provider<VerifyOtpUseCase>((ref) {
  return VerifyOtpUseCase(ref.read(authRepositoryProvider));
});

/// Get Current User Use Case
final getCurrentUserUseCaseProvider = Provider<GetCurrentUserUseCase>((ref) {
  return GetCurrentUserUseCase(ref.read(authRepositoryProvider));
});

/// Sign Out Use Case
final signOutUseCaseProvider = Provider<SignOutUseCase>((ref) {
  return SignOutUseCase(ref.read(authRepositoryProvider));
});
