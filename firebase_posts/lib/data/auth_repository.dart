import 'package:firebase_auth/firebase_auth.dart';

/// Помилка входу або реєстрації з текстом для користувача.
class AuthFailure implements Exception {
  const AuthFailure(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Переводить коди FirebaseAuthException у зрозумілі повідомлення.
String authErrorMessage(String code) {
  switch (code) {
    case 'invalid-email':
      return 'Невірний формат email';
    case 'user-disabled':
      return 'Цей акаунт заблоковано';
    case 'user-not-found':
    case 'wrong-password':
    case 'invalid-credential':
      return 'Невірний email або пароль';
    case 'email-already-in-use':
      return 'Акаунт з таким email вже існує';
    case 'weak-password':
      return 'Пароль занадто простий, потрібно мінімум 6 символів';
    case 'too-many-requests':
      return 'Забагато спроб, спробуйте пізніше';
    case 'network-request-failed':
      return 'Немає з’єднання з інтернетом';
    case 'operation-not-allowed':
      return 'Вхід за email і паролем вимкнено в Firebase';
    default:
      return 'Помилка автентифікації ($code)';
  }
}

class AuthRepository {
  AuthRepository({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;

  /// Потік з поточним користувачем: null, коли ніхто не увійшов.
  Stream<User?> authStateChanges() => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<User> signUp(String email, String password) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return cred.user!;
    } on FirebaseAuthException catch (e) {
      throw AuthFailure(authErrorMessage(e.code));
    }
  }

  Future<User> signIn(String email, String password) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return cred.user!;
    } on FirebaseAuthException catch (e) {
      throw AuthFailure(authErrorMessage(e.code));
    }
  }

  Future<void> signOut() => _auth.signOut();
}
