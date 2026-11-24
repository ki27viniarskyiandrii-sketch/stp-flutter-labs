import 'package:cloud_firestore/cloud_firestore.dart';

/// Документ колекції posts.
class Post {
  const Post({
    required this.id,
    required this.title,
    required this.text,
    required this.ownerId,
    required this.ownerEmail,
    this.imageUrl,
    this.imagePath,
    this.createdAt,
  });

  final String id;
  final String title;
  final String text;
  final String ownerId;
  final String ownerEmail;
  final String? imageUrl;
  final String? imagePath;
  final DateTime? createdAt;

  factory Post.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? const {};
    return Post(
      id: doc.id,
      title: d['title'] as String? ?? '',
      text: d['text'] as String? ?? '',
      ownerId: d['ownerId'] as String? ?? '',
      ownerEmail: d['ownerEmail'] as String? ?? '',
      imageUrl: d['imageUrl'] as String?,
      imagePath: d['imagePath'] as String?,
      // поки сервер не поставив час, createdAt дорівнює null
      createdAt: (d['createdAt'] as Timestamp?)?.toDate(),
    );
  }
}
