import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class StorageRepository {
  StorageRepository({FirebaseStorage? storage})
      : _storage = storage ?? FirebaseStorage.instance;

  final FirebaseStorage _storage;

  /// Шлях файлу: `posts/uid/час_назва`. Папка uid потрібна для правил.
  String pathFor(String uid, String fileName) =>
      'posts/$uid/${DateTime.now().millisecondsSinceEpoch}_$fileName';

  /// Починає завантаження. На телефоні це putFile, у вебі файлу на диску
  /// немає, тому там байти йдуть через putData.
  UploadTask upload({
    required String path,
    required String contentType,
    String? filePath,
    Uint8List? bytes,
  }) {
    final ref = _storage.ref(path);
    final meta = SettableMetadata(contentType: contentType);
    if (!kIsWeb && filePath != null) {
      return ref.putFile(File(filePath), meta);
    }
    return ref.putData(bytes!, meta);
  }

  Future<String> downloadUrl(String path) => _storage.ref(path).getDownloadURL();

  Future<void> delete(String path) => _storage.ref(path).delete();
}
