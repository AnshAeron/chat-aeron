import 'package:chat_aeron/features/auth/data/datasources/firestore_user_datasource.dart';
import 'package:chat_aeron/features/auth/data/models/user_model.dart';
import 'package:chat_aeron/features/auth/domain/entities/user_entity.dart';
import 'package:chat_aeron/features/auth/providers/auth_providers.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

/// Profile State
class ProfileState {
  final bool isLoading;
  final String? errorMessage;
  final UserEntity? user;
  final String? profileImagePath;

  const ProfileState({
    this.isLoading = false,
    this.errorMessage,
    this.user,
    this.profileImagePath,
  });

  ProfileState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
    UserEntity? user,
    String? profileImagePath,
  }) {
    return ProfileState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      user: user ?? this.user,
      profileImagePath: profileImagePath ?? this.profileImagePath,
    );
  }
}

/// Profile Controller
class ProfileController extends StateNotifier<ProfileState> {
  final FirestoreUserDataSource _userDataSource;
  final FirebaseAuth _auth;
  final FirebaseStorage _storage;
  final ImagePicker _picker = ImagePicker();

  ProfileController(this._userDataSource, this._auth, this._storage)
    : super(const ProfileState());

  /// Load the current user's profile from Firestore
  Future<void> loadCurrentUser() async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) return;

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final userModel = await _userDataSource.getUser(firebaseUser.uid);
      if (userModel != null) {
        state = state.copyWith(isLoading: false, user: userModel.toEntity());
      } else {
        // User exists in Auth but not Firestore yet
        state = state.copyWith(
          isLoading: false,
          user: UserEntity(
            uid: firebaseUser.uid,
            phoneNumber: firebaseUser.phoneNumber ?? '',
          ),
        );
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  /// Save profile during initial setup
  Future<void> saveProfile({required String displayName, String? about}) async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) return;

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      String? photoUrl;

      // Upload profile image if selected
      if (state.profileImagePath != null) {
        photoUrl = await _uploadProfileImage(
          firebaseUser.uid,
          state.profileImagePath!,
        );
      }

      final userModel = UserModel(
        uid: firebaseUser.uid,
        phoneNumber: firebaseUser.phoneNumber ?? '',
        displayName: displayName,
        photoUrl: photoUrl,
        about: about ?? 'Hey there! I am using ChatAeron',
        isOnline: true,
        createdAt: DateTime.now(),
      );

      await _userDataSource.saveUser(userModel);

      state = state.copyWith(isLoading: false, user: userModel.toEntity());
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  /// Update display name
  Future<void> updateDisplayName(String name) async {
    if (state.user == null) return;

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final updatedUser = state.user!.copyWith(displayName: name);
      final userModel = UserModel.fromEntity(updatedUser);
      await _userDataSource.saveUser(userModel);

      state = state.copyWith(isLoading: false, user: updatedUser);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  /// Update about text
  Future<void> updateAbout(String about) async {
    if (state.user == null) return;

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final updatedUser = state.user!.copyWith(about: about);
      final userModel = UserModel.fromEntity(updatedUser);
      await _userDataSource.saveUser(userModel);

      state = state.copyWith(isLoading: false, user: updatedUser);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  /// Pick profile image (placeholder - image_picker not yet added)
  Future<void> pickProfileImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (image == null) return;

    state = state.copyWith(profileImagePath: image.path);
  }

  Future<void> pickAndUploadProfileImage() async {
    final firebaseUser = _auth.currentUser;

    if (firebaseUser == null || state.user == null) return;

    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (image == null) return;

    state = state.copyWith(isLoading: true, profileImagePath: image.path);

    try {
      final photoUrl = await _uploadProfileImage(firebaseUser.uid, image.path);

      final updatedUser = state.user!.copyWith(photoUrl: photoUrl);

      await _userDataSource.saveUser(UserModel.fromEntity(updatedUser));

      state = state.copyWith(isLoading: false, user: updatedUser);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  /// Upload profile image to Firebase Storage
  Future<String> _uploadProfileImage(String uid, String filePath) async {
    final ref = _storage.ref().child('profile_pics').child('$uid.jpg');
    await ref.putFile(File(filePath));
    return await ref.getDownloadURL();
  }
}

/// Profile Controller Provider
final profileControllerProvider =
    StateNotifierProvider<ProfileController, ProfileState>((ref) {
      return ProfileController(
        ref.read(firestoreUserDataSourceProvider),
        FirebaseAuth.instance,
        FirebaseStorage.instance,
      );
    });
