import '../models/models.dart';

class AuthException implements Exception {
  const AuthException(this.message);

  final String message;

  @override
  String toString() => message;
}

abstract class AuthRepository {
  Future<User> signIn(String email, String password);
}

/// Демо-сервер: правильний пароль для будь-якого email це student123.
class DemoAuthRepository implements AuthRepository {
  @override
  Future<User> signIn(String email, String password) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (password != 'student123') {
      throw const AuthException('Невірний email або пароль');
    }
    return User(email: email, name: email.split('@').first);
  }
}
