import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:material_ui/material_ui.dart';

import 'data/auth_repository.dart';
import 'data/posts_repository.dart';
import 'data/storage_repository.dart';
import 'firebase_options.dart';
import 'screens/auth_screen.dart';
import 'screens/posts_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // без цього виклику жоден сервіс Firebase не знає, до якого проєкту йти
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // Хмарний Storage працює тільки на Blaze, тому фото йдуть в емулятор.
  // Емулятор доступний через ту саму адресу, що і сторінка (tool/dev_server.js).
  if (kIsWeb && const bool.fromEnvironment('STORAGE_EMULATOR')) {
    await FirebaseStorage.instance.useStorageEmulator(Uri.base.host, 443);
  }
  runApp(FirebasePostsApp(
    auth: AuthRepository(),
    posts: PostsRepository(),
    storage: StorageRepository(),
  ));
}

class FirebasePostsApp extends StatelessWidget {
  const FirebasePostsApp({
    super.key,
    required this.auth,
    required this.posts,
    required this.storage,
  });

  final AuthRepository auth;
  final PostsRepository posts;
  final StorageRepository storage;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firebase Posts',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.deepOrange, useMaterial3: true),
      // екран сам перемикається, коли користувач входить або виходить
      home: StreamBuilder<User?>(
        stream: auth.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          final user = snapshot.data;
          if (user == null) return AuthScreen(auth: auth);
          return PostsScreen(
            key: ValueKey(user.uid),
            user: user,
            auth: auth,
            posts: posts,
            storage: storage,
          );
        },
      ),
    );
  }
}
