import 'dart:async';
import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:material_ui/material_ui.dart';

import '../data/posts_repository.dart';
import '../data/storage_repository.dart';
import '../models/post.dart';

/// Форма нового запису з фото. Якщо передано post, форма редагує текст.
class PostFormScreen extends StatefulWidget {
  const PostFormScreen({
    super.key,
    required this.user,
    required this.posts,
    required this.storage,
    this.post,
  });

  final User user;
  final PostsRepository posts;
  final StorageRepository storage;
  final Post? post;

  @override
  State<PostFormScreen> createState() => _PostFormScreenState();
}

class _PostFormScreenState extends State<PostFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _title = TextEditingController(text: widget.post?.title);
  late final _text = TextEditingController(text: widget.post?.text);

  XFile? _image;
  Uint8List? _imageBytes;
  double? _progress; // null, поки нічого не завантажується
  bool _saving = false;
  StreamSubscription<TaskSnapshot>? _sub;

  bool get _isEdit => widget.post != null;

  @override
  void dispose() {
    _sub?.cancel();
    _title.dispose();
    _text.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final file = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1600,
      imageQuality: 85,
    );
    if (file == null) return;
    final bytes = await file.readAsBytes();
    setState(() {
      _image = file;
      _imageBytes = bytes;
    });
  }

  String _contentType(XFile f) {
    if (f.mimeType != null) return f.mimeType!;
    final name = f.name.toLowerCase();
    if (name.endsWith('.png')) return 'image/png';
    if (name.endsWith('.webp')) return 'image/webp';
    return 'image/jpeg';
  }

  /// Завантажує фото і повертає шлях у Storage та downloadURL.
  Future<(String, String)> _uploadImage() async {
    final path = widget.storage.pathFor(widget.user.uid, _image!.name);
    final task = widget.storage.upload(
      path: path,
      contentType: _contentType(_image!),
      filePath: _image!.path,
      bytes: _imageBytes,
    );
    setState(() => _progress = 0);
    _sub = task.snapshotEvents.listen((s) {
      if (s.totalBytes > 0 && mounted) {
        setState(() => _progress = s.bytesTransferred / s.totalBytes);
      }
    });
    final done = await task; // чекаємо кінця завантаження
    await _sub?.cancel();
    final url = await done.ref.getDownloadURL();
    return (path, url);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      if (_isEdit) {
        await widget.posts.updatePost(widget.post!.id,
            title: _title.text, text: _text.text);
      } else {
        String? path;
        String? url;
        if (_image != null) {
          (path, url) = await _uploadImage();
        }
        await widget.posts.addPost(
          ownerId: widget.user.uid,
          ownerEmail: widget.user.email ?? '',
          title: _title.text,
          text: _text.text,
          imageUrl: url,
          imagePath: path,
        );
      }
      if (mounted) Navigator.of(context).pop();
    } on FirebaseException catch (e) {
      _showError(e.code == 'unauthorized'
          ? 'Storage не дозволив завантаження: перевірте розмір і тип файлу'
          : 'Помилка завантаження (${e.code})');
    } catch (e) {
      _showError('$e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _showError(String text) {
    if (!mounted) return;
    setState(() => _progress = null);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text), backgroundColor: Colors.red.shade700),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEdit ? 'Редагування' : 'Новий запис')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                TextFormField(
                  controller: _title,
                  enabled: !_saving,
                  maxLength: 100,
                  decoration: const InputDecoration(
                    labelText: 'Заголовок',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) =>
                      (v ?? '').trim().isEmpty ? 'Введіть заголовок' : null,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _text,
                  enabled: !_saving,
                  minLines: 3,
                  maxLines: 6,
                  decoration: const InputDecoration(
                    labelText: 'Текст',
                    border: OutlineInputBorder(),
                  ),
                ),
                if (!_isEdit) ...[
                  const SizedBox(height: 16),
                  if (_imageBytes != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: AspectRatio(
                        aspectRatio: 16 / 9,
                        child: Image.memory(_imageBytes!, fit: BoxFit.cover),
                      ),
                    ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: _saving ? null : _pickImage,
                    icon: const Icon(Icons.image_outlined),
                    label: Text(_image == null ? 'Додати фото' : 'Змінити фото'),
                  ),
                ],
                if (_progress != null) ...[
                  const SizedBox(height: 16),
                  LinearProgressIndicator(value: _progress),
                  const SizedBox(height: 4),
                  Text('Завантаження фото: ${(_progress! * 100).toStringAsFixed(0)}%'),
                ],
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: _saving ? null : _save,
                  child: Text(_isEdit ? 'Зберегти зміни' : 'Опублікувати'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
