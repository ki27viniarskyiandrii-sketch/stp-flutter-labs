import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:material_ui/material_ui.dart';

import '../data/auth_repository.dart';
import '../data/posts_repository.dart';
import '../data/storage_repository.dart';
import '../models/post.dart';
import 'post_form_screen.dart';

class PostsScreen extends StatelessWidget {
  const PostsScreen({
    super.key,
    required this.user,
    required this.auth,
    required this.posts,
    required this.storage,
  });

  final User user;
  final AuthRepository auth;
  final PostsRepository posts;
  final StorageRepository storage;

  void _showError(ScaffoldMessengerState messenger, Object e) {
    messenger.showSnackBar(
      SnackBar(content: Text('$e'), backgroundColor: Colors.red.shade700),
    );
  }

  Future<void> _delete(BuildContext context, Post post) async {
    // messenger беру одразу: Firestore спершу прибирає запис локально,
    // і картка разом зі своїм context зникає ще до відмови сервера
    final messenger = ScaffoldMessenger.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Видалити запис?'),
        content: Text('«${post.title}» буде видалено.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Скасувати')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Видалити')),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await posts.deletePost(post.id);
      // файл прибираємо тільки після того, як правила дозволили видалити документ
      if (post.imagePath != null) {
        await storage.delete(post.imagePath!).catchError((_) {});
      }
    } catch (e) {
      _showError(messenger, e);
    }
  }

  void _openForm(BuildContext context, {Post? post}) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => PostFormScreen(
        user: user,
        posts: posts,
        storage: storage,
        post: post,
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Записи'),
        actions: [
          Center(child: Text(user.email ?? '', style: const TextStyle(fontSize: 13))),
          IconButton(
            tooltip: 'Вийти',
            icon: const Icon(Icons.logout),
            onPressed: auth.signOut,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(context),
        icon: const Icon(Icons.add),
        label: const Text('Новий запис'),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: posts.watchPosts(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text('Не вдалося завантажити записи:\n${snapshot.error}',
                    textAlign: TextAlign.center),
              ),
            );
          }
          if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return const Center(child: Text('Записів ще немає. Додайте перший.'));
          }
          final items = docs.map(Post.fromDoc).toList();
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 88),
            itemCount: items.length,
            itemBuilder: (context, i) => _PostCard(
              post: items[i],
              mine: items[i].ownerId == user.uid,
              onEdit: () => _openForm(context, post: items[i]),
              onDelete: () => _delete(context, items[i]),
            ),
          );
        },
      ),
    );
  }
}

class _PostCard extends StatelessWidget {
  const _PostCard({
    required this.post,
    required this.mine,
    required this.onEdit,
    required this.onDelete,
  });

  final Post post;
  final bool mine;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (post.imageUrl != null)
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Image.network(
                post.imageUrl!,
                fit: BoxFit.cover,
                // у вебі картинка йде через <img>, тому CORS бакета не заважає
                webHtmlElementStrategy: WebHtmlElementStrategy.prefer,
                errorBuilder: (_, _, _) => const Center(child: Icon(Icons.broken_image)),
              ),
            ),
          ListTile(
            title: Text(post.title),
            subtitle: Text(post.text),
            // кнопки є в усіх записах, щоб перевірити правила Firestore
            trailing: PopupMenuButton<String>(
              onSelected: (v) => v == 'edit' ? onEdit() : onDelete(),
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'edit', child: Text('Редагувати')),
                PopupMenuItem(value: 'delete', child: Text('Видалити')),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Row(
              children: [
                Icon(mine ? Icons.person : Icons.person_outline,
                    size: 16, color: mine ? scheme.primary : scheme.outline),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    mine ? 'Мій запис' : post.ownerEmail,
                    style: TextStyle(color: mine ? scheme.primary : scheme.outline),
                  ),
                ),
                if (post.createdAt != null)
                  Text(
                    '${post.createdAt!.day.toString().padLeft(2, '0')}.'
                    '${post.createdAt!.month.toString().padLeft(2, '0')} '
                    '${post.createdAt!.hour.toString().padLeft(2, '0')}:'
                    '${post.createdAt!.minute.toString().padLeft(2, '0')}',
                    style: TextStyle(color: scheme.outline),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
