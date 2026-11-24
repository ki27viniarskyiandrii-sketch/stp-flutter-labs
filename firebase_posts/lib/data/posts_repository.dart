import 'package:cloud_firestore/cloud_firestore.dart';

/// Помилка роботи з Firestore з текстом для користувача.
class PostsFailure implements Exception {
  const PostsFailure(this.message);

  final String message;

  @override
  String toString() => message;
}

String firestoreErrorMessage(String code) {
  switch (code) {
    case 'permission-denied':
      return 'Немає доступу: змінювати і видаляти запис може лише його автор';
    case 'not-found':
      return 'Запис уже видалено';
    case 'unavailable':
      return 'Сервер недоступний, перевірте інтернет';
    default:
      return 'Помилка бази даних ($code)';
  }
}

class PostsRepository {
  PostsRepository({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _posts =>
      _db.collection('posts');

  /// Read: усі записи, нові зверху. Firestore сам надсилає зміни.
  Stream<QuerySnapshot<Map<String, dynamic>>> watchPosts() =>
      _posts.orderBy('createdAt', descending: true).snapshots();

  /// Create: ownerId береться з акаунта, а не з форми.
  Future<String> addPost({
    required String ownerId,
    required String ownerEmail,
    required String title,
    required String text,
    String? imageUrl,
    String? imagePath,
  }) async {
    try {
      final ref = await _posts.add({
        'title': title.trim(),
        'text': text.trim(),
        'ownerId': ownerId,
        'ownerEmail': ownerEmail,
        'imageUrl': imageUrl,
        'imagePath': imagePath,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return ref.id;
    } on FirebaseException catch (e) {
      throw PostsFailure(firestoreErrorMessage(e.code));
    }
  }

  /// Update: міняються тільки текстові поля, ownerId не чіпаємо.
  Future<void> updatePost(String id, {required String title, required String text}) async {
    try {
      await _posts.doc(id).update({
        'title': title.trim(),
        'text': text.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      throw PostsFailure(firestoreErrorMessage(e.code));
    }
  }

  /// Delete.
  Future<void> deletePost(String id) async {
    try {
      await _posts.doc(id).delete();
    } on FirebaseException catch (e) {
      throw PostsFailure(firestoreErrorMessage(e.code));
    }
  }
}
