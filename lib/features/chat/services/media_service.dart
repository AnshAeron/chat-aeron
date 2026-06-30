import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class MediaService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadFile({required File file, required String path}) async {
    final ref = _storage.ref().child(path);

    final uploadTask = ref.putFile(file);

    final snapshot = await uploadTask;

    return await snapshot.ref.getDownloadURL();
  }
}
